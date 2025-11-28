CLASS zcl_payment_voucher DEFINITION
  PUBLIC
*  FINAL
  INHERITING FROM cx_rap_query_provider
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_ranges    TYPE TABLE OF ty_range_option,

           tt_returns   TYPE TABLE OF bapiret2,

           tt_phieu_chi TYPE TABLE OF zc_payment_voucher.

    "Custom Entities
    INTERFACES if_rap_query_provider.

    CLASS-DATA: gt_phieu_chi TYPE tt_phieu_chi.

    CLASS-METHODS: get_phieu_chi_1 IMPORTING ir_compaycode         TYPE tt_ranges
                                             ir_glaccount          TYPE tt_ranges
                                             ir_accountingdocument TYPE tt_ranges OPTIONAL
                                             ir_postingdate        TYPE tt_ranges
                                             ir_fiscalyear         TYPE tt_ranges OPTIONAL
                                             ir_documentdate       TYPE tt_ranges OPTIONAL
                                             ir_businesspartner    TYPE tt_ranges OPTIONAL
                                             ir_GeneralDirector    TYPE tt_ranges OPTIONAL
                                             ir_ChiefAccountant    TYPE tt_ranges OPTIONAL
                                             ir_Cashier            TYPE tt_ranges OPTIONAL
                                             ir_Receiver           TYPE tt_ranges OPTIONAL
                                             ir_PreparedBy         TYPE tt_ranges OPTIONAL
                                             ir_Name         TYPE tt_ranges OPTIONAL
                                   EXPORTING e_phieu_chi           TYPE tt_phieu_chi
                                             e_return              TYPE tt_returns .
    CLASS-METHODS append_unique_account IMPORTING iv_new_account   TYPE text10
                                        CHANGING  cv_target_string TYPE char256.
    CLASS-METHODS get_person_name
      IMPORTING
                iv_bp                 TYPE i_businesspartner-businesspartner
      RETURNING VALUE(rv_person_name) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PAYMENT_VOUCHER IMPLEMENTATION.


  METHOD append_unique_account.
    IF cv_target_string IS INITIAL.
      cv_target_string = iv_new_account.
    ELSE.
      FIND iv_new_account IN cv_target_string.
      IF sy-subrc <> 0 AND iv_new_account IS NOT INITIAL.
        cv_target_string = cv_target_string && ';' && iv_new_account.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_person_name.
    SELECT SINGLE FROM i_businesspartner
      FIELDS lastname
      WHERE businesspartner = @iv_bp
    INTO @rv_person_name.
  ENDMETHOD.


  METHOD get_phieu_chi_1.
    DATA: ls_return TYPE bapiret2.
    DATA(lo_common_app) = zcl_jp_common_core=>get_instance( ).
    DATA: lt_journalentry     TYPE TABLE OF i_journalentry,
          lt_journalentryitem TYPE TABLE OF i_journalentryitem.
    DATA: lv_check TYPE abap_bool VALUE abap_false.

    SELECT FROM i_journalentry
      FIELDS *
      WHERE companycode IN @ir_compaycode
        AND accountingdocument IN @ir_accountingdocument
        AND postingdate IN @ir_postingdate
        AND fiscalyear IN @ir_fiscalyear
        AND reversedocument = ''
      INTO CORRESPONDING FIELDS OF TABLE @lt_journalentry.
    IF lt_journalentry IS NOT INITIAL.
      SELECT FROM i_journalentryitem
      FIELDS *
*      FOR ALL ENTRIES IN @lt_journalentry
        WHERE companycode IN @ir_compaycode
          AND accountingdocument IN @ir_accountingdocument
          AND fiscalyear IN @ir_fiscalyear
          AND postingdate IN @ir_postingdate
          AND ledger = '0L'
          AND debitcreditcode IN ('S', 'H')
      INTO CORRESPONDING FIELDS OF TABLE @lt_journalentryitem.
      SELECT FROM i_operationalacctgdocitem
        FIELDS companycode, accountingdocument, fiscalyear, accountingdocumentitem,
          glaccount, operationalglaccount, isnegativeposting, debitcreditcode, supplier,
          documentitemtext, absoluteamountintransaccrcy, absoluteamountincocodecrcy
*          FOR ALL ENTRIES IN @lt_journalentry
        WHERE companycode IN @ir_compaycode
          AND accountingdocument IN @ir_accountingdocument
          AND fiscalyear IN @ir_fiscalyear
          AND postingdate IN @ir_postingdate
          AND debitcreditcode IN ('S', 'H')
        INTO TABLE @DATA(lt_bseg).
      SELECT FROM i_onetimeaccountsupplier AS a
        FIELDS *
*        FOR ALL ENTRIES IN @lt_journalentryitem
        WHERE companycode IN @ir_compaycode
          AND accountingdocument IN @ir_accountingdocument
          AND fiscalyear IN @ir_fiscalyear
*          AND accountingdocumentitem = @lt_journalentryitem-accountingdocumentitem
        INTO TABLE @DATA(lt_bsec) .
    ELSE.
      ls_return-type = 'E'.
      ls_return-message = 'Không có dữ liệu'.
      APPEND ls_return TO e_return.
      RETURN.
    ENDIF.

    CALL METHOD zcl_jp_common_core=>get_companycode_details_all
      IMPORTING
        o_companycode = DATA(lt_companycode_info).

    LOOP AT lt_journalentryitem ASSIGNING FIELD-SYMBOL(<fs_journalentryitem>).
      SHIFT <fs_journalentryitem>-glaccount LEFT DELETING LEADING '0'.
      CONDENSE <fs_journalentryitem>-glaccount.
    ENDLOOP.
    SORT lt_journalentry BY postingdate accountingdocument  ASCENDING.
    SORT lt_journalentryitem BY accountingdocument fiscalyear companycode glaccount debitcreditcode.
    SORT lt_bseg BY companycode accountingdocument fiscalyear glaccount debitcreditcode.
    SORT lt_bsec BY companycode accountingdocument fiscalyear accountingdocumentitem.
    DATA: ls_phieu_chi TYPE zc_payment_voucher,
          lv_stt       TYPE int4 VALUE IS INITIAL,
          lv_glaccount TYPE i_operationalacctgdocitem-glaccount,
          lv_index     TYPE sy-index,
          lv_bp        TYPE i_supplier-supplier.
    DATA: wa_document TYPE zst_document_info.
    LOOP AT lt_journalentry INTO DATA(ls_journalentry).
      " PAYMENT VOUCHER: PHIẾU CHI USE DEBITCREDITCODE = 'H'
      CLEAR: lv_check.
      READ TABLE lt_journalentryitem INTO DATA(ls_journalentryitem)
        WITH KEY accountingdocument = ls_journalentry-accountingdocument
             fiscalyear = ls_journalentry-fiscalyear
             companycode = ls_journalentry-companycode
             glaccount+0(3) = '111'
             debitcreditcode = 'H' BINARY SEARCH.
      IF sy-subrc = 0.
        lv_check = abap_true.
      ENDIF.
      IF lv_check = abap_true.
        ls_phieu_chi-companycode = ls_journalentry-companycode.
        ls_phieu_chi-postingdate = ls_journalentry-postingdate.
        ls_phieu_chi-accountingdocument = ls_journalentry-accountingdocument.
        ls_phieu_chi-fiscalyear = ls_journalentry-fiscalyear.
        ls_phieu_chi-accountingdocumenttype = ls_journalentry-accountingdocumenttype.
        ls_phieu_chi-transactioncurrency = ls_journalentry-transactioncurrency.
        ls_phieu_chi-creationuser = ls_journalentry-accountingdoccreatedbyuser.
        ls_phieu_chi-creationdate = ls_journalentry-accountingdocumentcreationdate.
        ls_phieu_chi-creationtime = ls_journalentry-creationtime.
        READ TABLE lt_bseg INTO DATA(ls_bseg)
          WITH KEY companycode = ls_journalentry-companycode
               accountingdocument = ls_journalentry-accountingdocument
               fiscalyear = ls_journalentry-fiscalyear
          BINARY SEARCH.
        IF sy-subrc = 0.
          lv_index = sy-tabix.
          LOOP AT lt_bseg INTO ls_bseg FROM lv_index.
            IF NOT ( ls_bseg-accountingdocument = ls_journalentry-accountingdocument
                 AND ls_bseg-fiscalyear = ls_journalentry-fiscalyear ).
              EXIT.
            ENDIF.
            lv_glaccount = ls_bseg-glaccount.
            SHIFT lv_glaccount LEFT DELETING LEADING '0'.
            CONDENSE lv_glaccount.
            IF ( ls_bseg-isnegativeposting IS INITIAL AND ls_bseg-debitcreditcode = 'S' ) OR
               ( ls_bseg-isnegativeposting IS NOT INITIAL AND ls_bseg-debitcreditcode = 'H' ).
              append_unique_account(
                EXPORTING iv_new_account   = lv_glaccount
                CHANGING cv_target_string = ls_phieu_chi-acc_s ).
              ls_phieu_chi-businesspartner = COND #( WHEN ls_phieu_chi-businesspartner IS INITIAL AND ls_bseg-supplier IS NOT INITIAL
                                                  THEN ls_bseg-supplier
                                                   ).
              ls_phieu_chi-diengiai = COND #( WHEN ls_phieu_chi-diengiai IS INITIAL AND ls_bseg-documentitemtext IS NOT INITIAL
                                             THEN ls_bseg-documentitemtext ).
              ls_phieu_chi-sotien = ls_phieu_chi-sotien + ls_bseg-absoluteamountincocodecrcy.
            ELSE.
              append_unique_account(
                EXPORTING iv_new_account   = lv_glaccount
                CHANGING cv_target_string = ls_phieu_chi-acc_h ).
              ls_phieu_chi-businesspartner = COND #( WHEN ls_phieu_chi-businesspartner IS INITIAL AND ls_bseg-supplier IS NOT INITIAL
                                                  THEN ls_bseg-supplier
                                                   ).
              ls_phieu_chi-diengiai = COND #( WHEN ls_phieu_chi-diengiai IS INITIAL AND ls_bseg-documentitemtext IS NOT INITIAL
                                             THEN ls_bseg-documentitemtext ).
            ENDIF.
            CLEAR lv_bp.

            IF ls_journalentry-AccountingDocumentType = 'SK'.
              READ TABLE lt_companycode_info INTO DATA(ls_companycode_info)
                WITH KEY companycode = ls_journalentry-companycode.
              IF sy-subrc = 0.
                ls_phieu_chi-diachi = ls_companycode_info-companycodeaddr.
              ENDIF.

              ls_phieu_chi-doituong = ls_journalentryitem-yy1_addittext2_jei.

*              SELECT SINGLE cashjournaldocumenttext2 FROM i_cashjournaldocument_2
*              WHERE companycode = @ls_journalentry-companycode
*                AND CashJournalDocumentInternalID = @ls_journalentry-originalreferencedocument(10)
*                AND fiscalyear = @ls_journalentry-fiscalyear
*                AND CashJournal = @ls_journalentry-originalreferencedocument+10(4)
*              INTO @DATA(lv_text2).
*              IF sy-subrc IS INITIAL.
*                ls_phieu_thu-doituong = lv_text2.
*              ENDIF.
            ELSE.
              lv_bp = ls_phieu_chi-businesspartner.
              SHIFT lv_bp LEFT DELETING LEADING '0'.
              CONDENSE lv_bp.
              READ TABLE lt_bsec INTO DATA(ls_bsec_match)
              WITH KEY companycode = ls_bseg-companycode
                       accountingdocument = ls_bseg-accountingdocument
                       fiscalyear = ls_bseg-fiscalyear
                       accountingdocumentitem = ls_bseg-accountingdocumentitem BINARY SEARCH.
              IF sy-subrc = 0 AND lv_bp+0(2) = '99'.
                ls_phieu_chi-doituong = ls_bsec_match-businesspartnername1 && ` ` && ls_bsec_match-businesspartnername2
                              && ` ` && ls_bsec_match-businesspartnername3 && ` ` && ls_bsec_match-businesspartnername4 .
                ls_phieu_chi-doituong = COND #(
                  WHEN ls_phieu_chi-doituong IS INITIAL
                  THEN get_person_name( iv_bp = ls_phieu_chi-businesspartner ) ).
                ls_phieu_chi-diachi = |{ ls_bsec_match-streetaddressname } { ls_bsec_match-cityname }|.
              ELSE.
                " Nếu có method lấy thông tin bp (supplier), thì gọi thêm để bổ sung
                wa_document-companycode = ls_journalentry-companycode.
                wa_document-accountingdocument = ls_journalentry-accountingdocument.
                wa_document-fiscalyear = ls_journalentry-fiscalyear.
                wa_document-supplier = ls_phieu_chi-businesspartner.
                lo_common_app->get_businesspartner_details(
                  EXPORTING
                    i_document = wa_document
                  IMPORTING
                    o_bpdetails = DATA(ls_supplier_detail)
                ).
                ls_phieu_chi-doituong = COND #(
                  WHEN ls_phieu_chi-doituong IS INITIAL
                  THEN get_person_name( iv_bp = ls_phieu_chi-businesspartner ) ).
                ls_phieu_chi-doituong = ls_supplier_detail-bpname.
                ls_phieu_chi-diachi = ls_supplier_detail-bpaddress.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
        IF ls_journalentryitem-documentitemtext IS NOT INITIAL.
          ls_phieu_chi-diengiai = ls_journalentryitem-documentitemtext.
        ENDIF.



        READ TABLE ir_generaldirector INTO DATA(ls_ge) INDEX 1.
        IF sy-subrc = 0 .
          ls_phieu_chi-generaldirector = ls_ge-low.
        ENDIF.

        READ TABLE ir_PreparedBy INTO DATA(ls_pe) INDEX 1.
        IF sy-subrc = 0 .
          ls_phieu_chi-PreparedBy = ls_pe-low.
        ENDIF.

        READ TABLE ir_cashier INTO DATA(ls_ca) INDEX 1.
        IF sy-subrc = 0 .
          ls_phieu_chi-Cashier = ls_ca-low.
        ENDIF.

        READ TABLE ir_chiefaccountant INTO DATA(ls_ch) INDEX 1.
        IF sy-subrc = 0 .
          ls_phieu_chi-ChiefAccountant = ls_ch-low.
        ENDIF.

        READ TABLE ir_receiver INTO DATA(ls_re) INDEX 1.
        IF sy-subrc = 0 .
          ls_phieu_chi-Receiver = ls_re-low.
        ENDIF.

        READ TABLE ir_Name INTO DATA(ls_name) INDEX 1.
        IF sy-subrc = 0 and  ls_name-low is not INITIAL.
          ls_phieu_chi-Doituong = ls_name-low.
          ls_phieu_chi-Name = ls_name-low.
        ENDIF.

        APPEND ls_phieu_chi TO e_phieu_chi.
        CLEAR: ls_phieu_chi, lv_glaccount.


      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
**--- Custom Entities ---**
    DATA: ls_page_info          TYPE zcl_jp_common_core=>st_page_info,

          ir_companycode        TYPE zcl_jp_common_core=>tt_ranges,
          ir_accountingdocument TYPE zcl_jp_common_core=>tt_ranges,
          ir_glaccount          TYPE zcl_jp_common_core=>tt_ranges,
          ir_fiscalyear         TYPE zcl_jp_common_core=>tt_ranges,
          ir_postingdate        TYPE zcl_jp_common_core=>tt_ranges,
          ir_documentdate       TYPE zcl_jp_common_core=>tt_ranges,
          ir_statussap          TYPE zcl_jp_common_core=>tt_ranges,
          ir_einvoicenumber     TYPE zcl_jp_common_core=>tt_ranges,
          ir_einvoicetype       TYPE zcl_jp_common_core=>tt_ranges,
          ir_currencytype       TYPE zcl_jp_common_core=>tt_ranges,
          ir_usertype           TYPE zcl_jp_common_core=>tt_ranges,
          ir_typeofdate         TYPE zcl_jp_common_core=>tt_ranges,
          ir_createdbyuser      TYPE zcl_jp_common_core=>tt_ranges,
          ir_enduser            TYPE zcl_jp_common_core=>tt_ranges,
          ir_testrun            TYPE zcl_jp_common_core=>tt_ranges,
          ir_businesspartner    TYPE zcl_jp_common_core=>tt_ranges,
          ir_GeneralDirector    TYPE zcl_jp_common_core=>tt_ranges,
          ir_ChiefAccountant    TYPE  zcl_jp_common_core=>tt_ranges,
          ir_PreparedBy         TYPE     zcl_jp_common_core=>tt_ranges,
          ir_Receiver           TYPE    zcl_jp_common_core=>tt_ranges,
          ir_Cashier            TYPE    zcl_jp_common_core=>tt_ranges,
          ir_Name            TYPE    zcl_jp_common_core=>tt_ranges
          .

    DATA: lt_returns TYPE tt_returns.
    DATA: lo_report_fi TYPE REF TO zcl_payment_voucher.

    FREE: lt_returns.


    "add hieudc7
    DATA(lo_paging) = io_request->get_paging( ).

    DATA(lv_page_size) = lo_paging->get_page_size( ).
    DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                                ELSE lv_page_size ).

    DATA(lo_filter) = io_request->get_filter( ).

    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_range).
        " Handle error
    ENDTRY.

    LOOP AT lt_filters INTO DATA(ls_filters).
      CASE ls_filters-name.
        WHEN 'GENERALDIRECTOR'.
          MOVE-CORRESPONDING ls_filters-range TO ir_GeneralDirector.
        WHEN 'CHIEFACCOUNTANT'.
          MOVE-CORRESPONDING ls_filters-range TO ir_ChiefAccountant.
        WHEN 'PREPAREDBY'.
          MOVE-CORRESPONDING ls_filters-range TO ir_PreparedBy.
        WHEN 'RECEIVER'.
          MOVE-CORRESPONDING ls_filters-range TO ir_Receiver.
        WHEN 'CASHIER'.
          MOVE-CORRESPONDING ls_filters-range TO ir_Cashier.
        WHEN 'NAME'.
          MOVE-CORRESPONDING ls_filters-range TO ir_Name.
      ENDCASE.
    ENDLOOP.
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    DATA(lv_entity_id) = io_request->get_entity_id( ).

    lo_report_fi = NEW #( ).

    DATA(lo_common_app) = zcl_jp_common_core=>get_instance( ).

    lo_common_app->get_fillter_app(
        EXPORTING
            io_request  = io_request
            io_response = io_response
        IMPORTING
            ir_companycode        = ir_companycode
            ir_accountingdocument = ir_accountingdocument
            ir_fiscalyear         = ir_fiscalyear
            ir_glaccount          = ir_glaccount
            ir_postingdate        = ir_postingdate
            ir_documentdate       = ir_documentdate
            ir_businesspartner     = ir_businesspartner
            wa_page_info          = ls_page_info
    ).

    IF ls_page_info-page_size < 0.
      ls_page_info-page_size = 50.
    ENDIF.

    DATA(max_rows) = COND #( WHEN ls_page_info-page_size = if_rap_query_paging=>page_size_unlimited THEN 0
               ELSE ls_page_info-page_size ).

    max_rows = ls_page_info-page_size + ls_page_info-offset.

    lo_report_fi->get_phieu_chi_1(
        EXPORTING
        ir_compaycode   = ir_companycode
        ir_glaccount    = ir_glaccount
        ir_accountingdocument = ir_accountingdocument
        ir_postingdate  = ir_postingdate
        ir_fiscalyear   = ir_fiscalyear
        ir_documentdate = ir_documentdate
        ir_GeneralDirector = ir_GeneralDirector
        ir_ChiefAccountant = ir_ChiefAccountant
        ir_PreparedBy = ir_PreparedBy
        ir_Cashier = ir_Cashier
        ir_Receiver = ir_Receiver
        ir_name = ir_Name
        IMPORTING
        e_phieu_chi = gt_phieu_chi
        e_return       = lt_returns
    ).

*    IF lt_returns IS NOT INITIAL.
*      READ TABLE lt_returns INTO DATA(ls_returns) INDEX 1.
*      RETURN.
*
*    ENDIF.

    DATA: lt_phieu_chi TYPE tt_phieu_chi.

    LOOP AT gt_phieu_chi INTO DATA(ls_phieu_chi).
      IF sy-tabix > ls_page_info-offset.
        IF sy-tabix > max_rows.
          EXIT.
        ELSE.
          APPEND ls_phieu_chi TO lt_phieu_chi.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( gt_phieu_chi ) ).
    ENDIF.

    IF io_request->is_data_requested( ).
      io_response->set_data( lt_phieu_chi ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.

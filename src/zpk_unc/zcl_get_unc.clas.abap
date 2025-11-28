CLASS zcl_get_unc DEFINITION
  PUBLIC
  FINAL
    INHERITING FROM cx_rap_query_provider
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_range TYPE TABLE OF ty_range_option,
           tt_data  TYPE TABLE OF zc_unc,
           gt_data  TYPE TABLE OF zc_unc.
    CLASS-DATA:
      o_fi_export_pdf TYPE REF TO zcl_jp_report_fi_export,
      o_gen_adobe     TYPE REF TO zcl_gen_adobe.

    CLASS-DATA:
     "Instance Singleton
     mo_instance      TYPE REF TO zcl_get_unc.

    TYPES:
      keys_unc     TYPE TABLE FOR ACTION IMPORT zc_unc~btnprintpdf,
      result_unc   TYPE TABLE FOR ACTION RESULT zc_unc~btnprintpdf,
      mapped_unc   TYPE RESPONSE FOR MAPPED EARLY zc_unc,
      failed_unc   TYPE RESPONSE FOR FAILED zc_unc,
      reported_unc TYPE RESPONSE FOR REPORTED EARLY zc_unc.

    CLASS-METHODS:
      btnPrintPDF_UNC IMPORTING keys     TYPE keys_unc
                      EXPORTING o_pdf    TYPE string
                      CHANGING  result   TYPE result_unc
                                mapped   TYPE mapped_unc
                                failed   TYPE failed_unc
                                reported TYPE reported_unc,

      btnPrintPDF_UNC_new IMPORTING keys     TYPE keys_unc
                          EXPORTING o_pdf    TYPE string
                          CHANGING  result   TYPE result_unc
                                    mapped   TYPE mapped_unc
                                    failed   TYPE failed_unc
                                    reported TYPE reported_unc.

    CLASS-METHODS:
      "Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_get_unc,

      convert_amount IMPORTING lv_amount  TYPE string
                               lv_curr    TYPE waers
                     CHANGING  lv_convert TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GET_UNC IMPLEMENTATION.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA: ls_page_info      TYPE zcl_get_fillter=>st_page_info,

          ir_bukrs          TYPE tt_range,
          ir_rundate        TYPE tt_range,
          ir_identification TYPE tt_range,
          ir_printdate      TYPE tt_range,
          ir_quydoi         TYPE tt_range,
          ir_tygia          TYPE tt_range,
          ir_ptstc          TYPE tt_range,
          ir_ptttm          TYPE tt_range,
          ir_ptttk          TYPE tt_range,
          ir_stk            TYPE tt_range,
          ir_noidung        TYPE tt_range.
    DATA: gw_printdate TYPE budat,
          gw_quydoi    TYPE char72,
          gw_tygia     TYPE char72,
          gw_ptstc     TYPE zde_checkbox,
          gw_ptttm     TYPE zde_checkbox,
          gw_ptttk     TYPE zde_checkbox,
          gw_noidung   TYPE zde_char255,
          gw_stk       TYPE c LENGTH 20.

    DATA: lt_data TYPE TABLE OF zc_unc,
          gt_data TYPE TABLE OF zc_unc.
    FREE: lt_data, gt_data.
    TRY.
* Khởi tạo đối tượng
        DATA(lo_unc)  = zcl_get_unc=>get_instance( ).

        DATA(lo_comcode) = zcl_jp_common_core=>get_instance(  ).

        DATA(lo_common_app) = zcl_get_fillter_unc=>get_instance( ).

*  Lấy tham số
        lo_common_app->get_fillter_app(
          EXPORTING
            io_request         = io_request
            io_response        = io_response
          IMPORTING
            ir_bukrs           = ir_bukrs
            ir_rundate         = ir_rundate
            ir_identification = ir_identification
            ir_printdate       = ir_printdate
            ir_quydoi          = ir_quydoi
            ir_tygia           = ir_tygia
            ir_ptstc           = ir_ptstc
            ir_ptttm           = ir_ptttm
            ir_ptttk           = ir_ptttk
            ir_stk             = ir_stk
            ir_noidung         = ir_noidung
            wa_page_info       = ls_page_info
        ).


        READ TABLE ir_quydoi INTO DATA(ls_range) INDEX 1.
        IF sy-subrc = 0.
          gw_quydoi = ls_range-low.
        ENDIF.
        READ TABLE ir_tygia INTO ls_range INDEX 1.
        IF sy-subrc = 0.
          gw_tygia = ls_range-low.
        ENDIF.
        READ TABLE ir_noidung INTO ls_range INDEX 1.
        IF sy-subrc = 0.
          gw_noidung = ls_range-low.
        ENDIF.
        READ TABLE ir_ptstc INTO ls_range INDEX 1.
        IF sy-subrc = 0.
          gw_ptstc = ls_range-low.
        ENDIF.
        READ TABLE ir_ptttk INTO ls_range INDEX 1.
        IF sy-subrc = 0.
          gw_ptttk = ls_range-low.
        ENDIF.
        READ TABLE ir_ptttm INTO ls_range INDEX 1.
        IF sy-subrc = 0.
          gw_ptttm = ls_range-low.
        ENDIF.

        READ TABLE ir_stk INTO ls_range INDEX 1.
        IF sy-subrc = 0.
          gw_stk = ls_range-low.
        ENDIF.

        READ TABLE ir_printdate INTO ls_range INDEX 1.
        IF sy-subrc = 0.
          gw_printdate = ls_range-low.
        ENDIF.
        IF gw_printdate IS INITIAL.
          gw_printdate = sy-datum.
        ENDIF.

        SELECT * FROM I_PaymentProposalPayment
            WHERE PaymentRunDate IN @ir_rundate
            AND PayingCompanyCode IN @ir_bukrs
            AND PaymentRunID IN @ir_identification
            AND PaymentRunIsProposal IS NOT INITIAL
            AND PaymentDocument IS NOT INITIAL
            AND NumberOfTextLines = 0
            INTO TABLE @DATA(gt_proposal).
        IF sy-subrc = 0.
          SORT gt_proposal BY PaymentRunDate PaymentRunID PaymentDocument.
          LOOP AT gt_proposal INTO DATA(gs_proposal).
            APPEND INITIAL LINE TO gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
            MOVE-CORRESPONDING gs_proposal TO <fs_data>.
            <fs_data>-CompanyCode = gs_proposal-PayingCompanyCode.
            <fs_data>-rundate = gs_proposal-PaymentRunDate.
            <fs_data>-PaymentDocument = gs_proposal-PaymentDocument.
            <fs_data>-Identification = gs_proposal-PaymentRunID.
            <fs_data>-printdate = gw_printdate.
            <fs_data>-quydoi    = gw_quydoi.
            <fs_data>-tygia     = gw_tygia.
            <fs_data>-ptstc     = gw_ptstc.
            <fs_data>-ptttk     = gw_ptttk.
            <fs_data>-ptttm     = gw_ptttm.
            <fs_data>-stk       = gw_stk.
            <fs_data>-noidung   = gw_noidung.
            <fs_data>-amount    = abs( gs_proposal-PaymentAmountInPaytCurrency ).
            <fs_data>-currency  = gs_proposal-PaymentCurrency.
            IF gs_proposal-Supplier IS INITIAL.
              <fs_data>-businessPartner = gs_proposal-Customer.
            ELSE.
              <fs_data>-businessPartner = gs_proposal-Supplier.
            ENDIF.
          ENDLOOP.
        ENDIF.

*          export data

        IF ls_page_info-page_size < 0.
          ls_page_info-page_size = 50.
        ENDIF.

        DATA(max_rows) = COND #( WHEN ls_page_info-page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                   ELSE ls_page_info-page_size ).

        max_rows = ls_page_info-page_size + ls_page_info-offset.

        LOOP AT gt_data INTO DATA(ls_data).
          IF sy-tabix > ls_page_info-offset.
            IF sy-tabix > max_rows.
              EXIT.
            ELSE.
              APPEND ls_data TO lt_data.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( gt_data ) ).
        ENDIF.

        IF io_request->is_data_requested( ).
          io_response->set_data( lt_data ).
        ENDIF.


      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

        RAISE EXCEPTION TYPE zcl_get_unc
          EXPORTING
            textid   = VALUE scx_t100key(
            msgid = exception_t100_key-msgid
            msgno = exception_t100_key-msgno
            attr1 = exception_t100_key-attr1
            attr2 = exception_t100_key-attr2
            attr3 = exception_t100_key-attr3
            attr4 = exception_t100_key-attr4 )
            previous = exception.
    ENDTRY.


  ENDMETHOD.


  METHOD btnprintpdf_unc.
*    DATA: xml     TYPE string,
*          sub1xml TYPE string,
*          sub2xml TYPE string,
*          sub3xml TYPE string,
*          sub4xml TYPE string,
*          sub5xml TYPE string.
*
*    READ TABLE keys INDEX 1 INTO DATA(k).
*
*    SELECT SINGLE * FROM I_PaymentProposalPayment
*            WHERE PaymentRunDate = @k-%key-rundate
*            AND PayingCompanyCode = @k-%key-CompanyCode
*            AND PaymentRunID = @k-%key-Identification
*            AND PaymentDocument = @k-%key-PaymentDocument
*            AND PaymentRunIsProposal = 'X'
*            INTO @DATA(ls_proposal).
*
*    sub1xml = sub1xml && |<Sub1>| &&
*                            |<Table1>| &&
*                                |<Row1>| &&
*                                    |<Cell2>{ k-%key-printdate+6(2) }/{ k-%key-printdate+4(2) }/{ k-%key-printdate+0(4) }</Cell2>| &&
*                                |</Row1>| &&
*                            |</Table1>| &&
*                         |</Sub1>|.
*
*    zcl_jp_common_core=>get_companycode_details(
*      EXPORTING
*        i_companycode = k-%key-CompanyCode
*      IMPORTING
*        o_companycode = DATA(ls_ccDetail)
*    ).
*
*    SELECT SINGLE
*           b~BankName,
*           b~BankBranch
*        FROM I_HouseBankBasic AS a
*        INNER JOIN I_Bank_2 AS b ON a~BankInternalID = b~BankInternalID
*        WHERE a~HouseBank = @ls_proposal-HouseBank
*        INTO @DATA(ls_bank).
*
*    DATA(lv_bank) = |{ ls_bank-BankName } - { ls_bank-BankBranch }|.
*
*    sub2xml = sub2xml && |<Sub2>| &&
*                            |<Table2>| &&
*                                |<Row1>| &&
*                                    |<Cell2>{ ls_ccdetail-companycodename }</Cell2>| &&
*                                |</Row1>| &&
*                                |<Row2>| &&
*                                    |<Cell2>{ ls_ccdetail-companycodeaddr }</Cell2>| &&
*                                |</Row2>| &&
*                                |<Row3>| &&
*                                    |<Cell2>{ ls_proposal-bankaccount }</Cell2>| &&
*                                |</Row3>| &&
*                                |<Row4>| &&
*                                    |<Cell2>{ lv_bank }</Cell2>| &&
*                                |</Row4>| &&
*                            |</Table2>| &&
*                         |</Sub2>|.
*
*
*
*    DATA(lv_amount) = |{ abs( ls_proposal-PaymentAmountInPaytCurrency ) }|.
*    DATA: lv_amountTXT TYPE string.
*    zcl_get_unc=>convert_amount(
*      EXPORTING
*        lv_amount  = lv_amount
*        lv_curr    = ls_proposal-PaymentCurrency
*      CHANGING
*        lv_convert = lv_amountTXT
*    ).
*
*    DATA(lo_amount_in_words) = NEW zcore_cl_amount_in_words( ).
*    DATA(lv_readamount) = lo_amount_in_words->read_amount(
*      EXPORTING
*        i_amount =  lv_amount * 100
*        i_lang   = 'VI'
*        i_waers  = ls_proposal-PaymentCurrency
*    ).
*
*    DATA: flag_ptstc TYPE char1,
*          flag_ptttm TYPE char1,
*          flag_ptttk TYPE char1.
*    IF k-%key-ptstc = 'X'.
*      flag_ptstc = 1.
*    ENDIF.
*    IF k-%key-ptttm = 'X'.
*      flag_ptttm = 1.
*    ENDIF.
*    IF k-%key-ptttk = 'X'.
*      flag_ptttk = 1.
*    ENDIF.
*
*    sub3xml = sub3xml && |<Sub3>| &&
*                            |<Table3>| &&
*                                |<Row1>| &&
*                                    |<Cell2>{ lv_amounttxt }</Cell2>| &&
*                                |</Row1>| &&
*                                |<Row2>| &&
*                                    |<Cell2>{ lv_readamount }</Cell2>| &&
*                                |</Row2>| &&
*                                |<Row4>| &&
*                                    |<Cell2>{ k-%key-quydoi }</Cell2>| &&
*                                    |<Cell4>{ k-%key-tygia }</Cell4>| &&
*                                |</Row4>| &&
*                                |<Row5>| &&
*                                    |<Cell1>{ flag_ptstc }</Cell1>| &&
*                                    |<Cell3>{ flag_ptttm }</Cell3>| &&
*                                |</Row5>| &&
*                                |<Row6>| &&
*                                    |<Cell1>{ flag_ptttk }</Cell1>| &&
*                                |</Row6>| &&
*                            |</Table3>| &&
*                         |</Sub3>|.
*
**    sub4
*    DATA: lv_name   TYPE string,
*          lv_addr   TYPE string,
*          lv_stk    TYPE string,
*          lv_bankth TYPE string.
*    DATA lv_noidung TYPE string.
*    SELECT *  FROM I_PaymentProposalItem
*            WHERE PayingCompanyCode = @ls_proposal-PayingCompanyCode
*            AND  PaymentDocument = @ls_proposal-PaymentDocument
*            AND  PaymentRunID = @ls_proposal-PaymentRunID
*            AND  PaymentRunDate = @ls_proposal-PaymentRunDate
*            AND  PaymentRunIsProposal IS NOT INITIAL
*            INTO TABLE @DATA(lT_item).
*    READ TABLE lt_item INTO DATA(ls_item) INDEX 1.
*    IF sy-subrc = 0.
*      SELECT SINGLE *
*      FROM I_OperationalAcctgDocItem
*      WHERE CompanyCode = @ls_item-PayingCompanyCode
*      AND   FiscalYear  = @ls_item-FiscalYear
*      AND   AccountingDocument = @ls_item-AccountingDocument
*      AND   AccountingDocumentItem = @ls_item-AccountingDocumentItem
*      INTO @DATA(ls_bseg).
*      IF ls_bseg-AddressAndBankIsSetManually = 'X'.
*        SELECT SINGLE * FROM I_JournalEntryItemOneTimeData
*            WITH PRIVILEGED ACCESS
*            WHERE CompanyCode = @ls_item-PayingCompanyCode
*              AND   FiscalYear  = @ls_item-FiscalYear
*              AND   AccountingDocument = @ls_item-AccountingDocument
*              AND   AccountingDocumentItem = @ls_item-AccountingDocumentItem
*              INTO @DATA(ls_bsec).
*        IF ls_bsec-BusinessType IS INITIAL.
*          lv_name = |{ ls_bsec-BusinessPartnerName1 } { ls_bsec-BusinessPartnerName2 } { ls_bsec-BusinessPartnerName3 } { ls_bsec-BusinessPartnerName4 }|.
*        ELSE.
*          lv_name = |{ ls_bsec-BusinessType }|.
*        ENDIF.
*
*        SELECT SINGLE countryname FROM I_CountryText
*            WHERE Country = @ls_bsec-Country
*            AND   Language = @sy-langu
*            INTO @DATA(lv_country).
*        lv_addr = |{ ls_bsec-StreetAddressName }, { ls_bsec-CityName }, { lv_country }|.
*
*        lv_stk = ls_bsec-BankAccount.
*        SELECT SINGLE
*           BankName
*        FROM I_Bank_2
*        WHERE BankInternalID = @ls_bsec-BankNumber
*        INTO @DATA(lv_bankname).
*        lv_bankth = |{ lv_bankname } - { ls_bsec-TaxID5 }|.
*      ELSE.
*        IF ls_bseg-BPBankAccountInternalID IS INITIAL.
*          SELECT SINGLE BankIdentification
*            FROM I_BusinessPartnerBank
*            WITH PRIVILEGED ACCESS
*            WHERE BusinessPartner = @ls_proposal-Supplier
*            INTO @DATA(lw_bankid).
*        ELSE.
*          lw_bankid = ls_bseg-BPBankAccountInternalID.
*        ENDIF.
*
*        SELECT SINGLE * FROM I_BusinessPartnerBank
*            WHERE BusinessPartner = @ls_proposal-Supplier
*            AND   BankIdentification = @lw_bankid
*            INTO @DATA(ls_supplierBank).
*
*        lv_name = |{ ls_supplierbank-BankAccountHolderName } { ls_supplierbank-BankAccountName }|.
*        SELECT SINGLE * FROM I_Address_2
*            WITH PRIVILEGED ACCESS
*            WHERE AddressID = @ls_proposal-AddressID
*            INTO @DATA(ls_addr).
*
**        zcl_jp_common_core=>get_address_id_details(
**          EXPORTING
**            addressid          = ls_proposal-AddressID
**          IMPORTING
**            o_addressiddetails = DATA(ls_addr)
**        ).
**        lv_addr = ls_addr-address.
*        SELECT SINGLE countryname FROM I_CountryText
*        WHERE Country = @ls_addr-Country
*        AND   Language = @sy-langu
*        INTO @DATA(lv_country_2).
*        lv_addr = |{ ls_addr-HouseNumber } { ls_addr-StreetName } { ls_addr-StreetPrefixName1  } { ls_addr-StreetPrefixName2 } { ls_addr-StreetSuffixName1 } { ls_addr-StreetSuffixName2 }, { ls_addr-CityName }, { lv_country_2 }|.
*
*        lv_stk = |{ ls_supplierbank-BankAccount }{ ls_supplierbank-BusinessPartnerExternalBankID }|.
*        SELECT SINGLE
*           BankName,
*           Branch
*        FROM I_Bank_2
*        WHERE BankInternalID = @ls_supplierbank-BankNumber
*        INTO @DATA(ls_bankname).
*        lv_bankth = |{ ls_bankname-BankName } - { ls_bankname-Branch }|.
*      ENDIF.
*    ENDIF.
*
*    sub4xml = sub4xml && |<Sub4>| &&
*                            |<Table4>| &&
*                                |<Row1>| &&
*                                    |<Cell2>{ lv_name }</Cell2>| &&
*                                |</Row1>| &&
*                                |<Row4>| &&
*                                    |<Cell2>{ lv_addr }</Cell2>| &&
*                                |</Row4>| &&
*                                |<Row5>| &&
*                                    |<Cell2>{ lv_stk }</Cell2>| &&
*                                |</Row5>| &&
*                                |<Row6>| &&
*                                    |<Cell2>{ lv_bankth }</Cell2>| &&
*                                |</Row6>| &&
*                            |</Table4>| &&
*                         |</Sub4>|.
*
**    sub5
*    IF k-%key-noidung IS INITIAL.
*      LOOP AT lt_item INTO ls_item.
*        IF lv_noidung IS INITIAL.
*          lv_noidung = ls_item-DocumentReferenceID.
*        ELSE.
*          lv_noidung = |{ lv_noidung }, { ls_item-DocumentReferenceID }|.
*        ENDIF.
*      ENDLOOP.
*      lv_noidung = |{ k-%key-rundate+6(2) }{ k-%key-rundate+4(2) }{ k-%key-rundate+0(4) }-{ k-%key-Identification }_CASLA TT cho HĐ số { lv_noidung }|.
*    ELSE.
*      lv_noidung = k-%key-noidung.
*    ENDIF.
*
*    sub5xml = sub5xml && |<Sub5>| &&
*                            |<Table5>| &&
*                                |<Row1>| &&
*                                    |<Cell2>{ lv_noidung }</Cell2>| &&
*                                |</Row1>| &&
*                            |</Table5>| &&
*                         |</Sub5>|.
*
*    xml = |<?xml version="1.0" encoding="UTF-8"?>| &&
*               |<form>| &&
*                    |{ sub1xml }| &&
*                    |{ sub2xml }| &&
*                    |{ sub3xml }| &&
*                    |{ sub4xml }| &&
*                    |{ sub5xml }| &&
*               |</form>|
*                .
*
*
*
*    DATA: ls_request TYPE zcl_gen_adobe=>ts_request.
*
*    ls_request-id = 'ZUNC'.
*    APPEND xml TO ls_request-data.
*
*    DATA(o_gen_adobe) = NEW zcl_gen_adobe( ).
*
*    DATA(lv_pdf) = o_gen_adobe->call_data( EXPORTING i_request = ls_request ).
*
*    o_pdf = lv_pdf.
*
*    DATA(filename) = |{ k-%key-Identification }_{ k-%key-CompanyCode }{ k-%key-rundate }|.
*
*    result = VALUE #( FOR key IN keys (
*                      %cid_ref = key-%cid_ref
*                      %tky     = key-%tky
*                      %param   = VALUE #( filecontent   = lv_pdf
*                                          filename      = filename
*                                          fileextension = 'pdf'
**                                          mimeType      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
*                                          mimetype      = 'application/pdf'
*                                         )
*                      ) ).
*    DATA: ls_mapped LIKE LINE OF mapped-zc_unc.
*    ls_mapped-%tky = k-%tky.
*    INSERT CORRESPONDING #( ls_mapped ) INTO TABLE mapped-zc_unc.
  ENDMETHOD.


  METHOD btnprintpdf_unc_new.
    TYPES: BEGIN OF lty_line,
             Cell1 TYPE String,
             Cell2 TYPE String,
             Cell3 TYPE string,
             Cell4 TYPE string,
           END OF lty_line,
           BEGIN OF ty_hdr_ctx,
             companycodename    TYPE string,
             companycodeaddr    TYPE string,
             postingdate        TYPE zde_char100,
             accountingdocument TYPE zde_char100,
             bpname             TYPE string,
             bpaddress          TYPE string,
             documentheadertext TYPE zde_char255,
           END OF ty_hdr_ctx,

           BEGIN OF ty_ftr_ctx,
             totalamount TYPE string,
             amounttext  TYPE string,
           END OF ty_ftr_ctx.

    DATA: lt_table1 TYPE STANDARD TABLE OF lty_line,
          lt_table2 TYPE STANDARD TABLE OF lty_line,
          lt_table3 TYPE STANDARD TABLE OF lty_line,
          lt_table4 TYPE STANDARD TABLE OF lty_line,
          lt_table5 TYPE STANDARD TABLE OF lty_line,
          lt_table6 TYPE STANDARD TABLE OF lty_line,
          ls_line   TYPE lty_line.
    DATA: lt_split TYPE TABLE OF string.
    DATA: ir_rundate TYPE tt_range,
          ir_id      TYPE tt_range,
          ir_doc     TYPE tt_range.

    READ TABLE keys INDEX 1 INTO DATA(k).

    IF k-%param-CompanyCode NE 'null'.
      DATA(lw_companycode) = k-%param-CompanyCode+0(4).
    ENDIF.
    IF k-%param-NoiDung NE 'null'.
      DATA(lw_noidung) = k-%param-NoiDung.
    ENDIF.
    IF k-%param-PrintDate NE 'null'.
      DATA(lw_printdate) = |{ k-%param-PrintDate+8(2) }/{ k-%param-PrintDate+5(2) }/{ k-%param-PrintDate+0(4) }|.
    ENDIF.
    IF k-%param-QuyDoi NE 'null'.
      DATA(lw_quydoi) = k-%param-QuyDoi.
    ENDIF.
    IF k-%param-TyGia NE 'null'.
      DATA(lw_tygia) = k-%param-TyGia.
    ENDIF.
    IF k-%param-ptstc = 'true'.
      DATA(lw_ptstc) = 1.
    ENDIF.
    IF k-%param-ptttm = 'true'.
      DATA(lw_ptttm) = 1.
    ENDIF.
    IF k-%param-ptttk = 'true'.
      DATA(lw_ptttk) = 1.
    ENDIF.

    IF k-%param-stk NE 'null'.
      DATA(lw_stk) = k-%param-stk.
    ENDIF.

    FREE: lt_split.
    SPLIT k-%param-RunDate AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO DATA(l_string).
      DATA(lw_date) = |{ l_string+0(4) }{ l_string+5(2) }{ l_string+8(2) }|.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = lw_date )        TO ir_rundate.
    ENDLOOP.

    FREE: lt_split.
    SPLIT k-%param-Identification AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO l_string.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_id.
    ENDLOOP.

    FREE: lt_split.
    SPLIT k-%param-PaymentDocument AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO l_string.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_doc.
    ENDLOOP.

    TYPES: BEGIN OF lty_range,
             rundate         TYPE budat,
             Identification  TYPE c LENGTH 6,
             PaymentDocument TYPE c LENGTH 10,
           END OF lty_range.
    DATA: lt_range TYPE TABLE OF lty_range.
    LOOP AT ir_rundate INTO DATA(ls_range).
      APPEND INITIAL LINE TO lt_range ASSIGNING FIELD-SYMBOL(<fs_range>).
      <fs_range>-rundate = ls_range-low.
      READ TABLE ir_doc INTO ls_range INDEX sy-tabix.
      IF sy-subrc = 0.
        <fs_range>-paymentdocument = ls_range-low.
      ENDIF.
      READ TABLE ir_id INTO ls_range INDEX sy-tabix.
      IF sy-subrc = 0.
        <fs_range>-identification = ls_range-low.
      ENDIF.
    ENDLOOP.

    CHECK lt_range[] IS NOT INITIAL.

    " map TABLE_ID -> ref
    DATA lt_refs TYPE zcl_ads_xml_builder=>tt_table_data_ref.


    DATA(o_gen_adobe) = NEW zcl_gen_adobe( ).
    DATA: ls_xml TYPE zcl_gen_adobe=>ty_gs_xml.

    DATA: xml     TYPE string,
          sub1xml TYPE string,
          sub2xml TYPE string,
          sub3xml TYPE string,
          sub4xml TYPE string,
          sub5xml TYPE string.

    sub1xml = sub1xml && |<Sub1>| &&
                            |<Table1>| &&
                                |<Row1>| &&
                                    |<Cell2>{ lw_printdate }</Cell2>| &&
                                |</Row1>| &&
                            |</Table1>| &&
                         |</Sub1>|.

    SELECT * FROM I_PaymentProposalPayment
            WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_range
            WHERE PaymentRunDate = @lt_range-rundate
            AND PayingCompanyCode = @lw_companycode
            AND PaymentRunID  = @lt_range-identification
            AND PaymentDocument = @lt_range-paymentdocument
            AND PaymentRunIsProposal IS NOT INITIAL
            INTO TABLE @DATA(lt_proposal).
    SORT lt_proposal BY PaymentRunDate PaymentRunID PaymentDocument.

    SELECT *  FROM I_PaymentProposalItem
            WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_range
            WHERE PayingCompanyCode = @lw_companycode
            AND PaymentRunID  = @lt_range-identification
            AND PaymentDocument = @lt_range-paymentdocument
            AND PaymentRunDate = @lt_range-rundate
            AND  PaymentRunIsProposal IS NOT INITIAL
            INTO TABLE @DATA(lT_item).

    DATA: lv_xml_data_string  TYPE string,
          lv_xml_data_xstring TYPE xstring,
          lv_xml_data         TYPE string.

    LOOP AT lt_proposal INTO DATA(ls_header).

      zcl_jp_common_core=>get_companycode_details(
    EXPORTING
      i_companycode = ls_header-PayingCompanyCode
    IMPORTING
      o_companycode = DATA(ls_ccDetail)
  ).

      SELECT SINGLE
             b~BankName,
             b~BankBranch
          FROM I_HouseBankBasic AS a
          INNER JOIN I_Bank_2 AS b ON a~BankInternalID = b~BankInternalID
          WHERE a~HouseBank = @ls_header-HouseBank
          INTO @DATA(ls_bank).

      SELECT SINGLE * FROM I_HouseBankAccountLinkage
            WHERE HouseBank = @ls_header-HouseBank
            AND CompanyCode = @ls_header-PayingCompanyCode
            AND HouseBankAccount = @ls_header-HouseBankAccount
            INTO @DATA(ls_banklinkage).
      if ls_banklinkage-GLAccount+0(3) = '113'.
        clear: ls_header-BankAccount.
      endif.
      DATA(lv_bank) = |{ ls_bank-BankName } - { ls_bank-BankBranch }|.

      sub2xml = sub2xml && |<Sub2>| &&
                              |<Table2>| &&
                                  |<Row1>| &&
                                      |<Cell2>{ ls_ccdetail-companycodename }</Cell2>| &&
                                  |</Row1>| &&
                                  |<Row2>| &&
                                      |<Cell2>{ ls_ccdetail-companycodeaddr }</Cell2>| &&
                                  |</Row2>| &&
                                  |<Row3>| &&
                                      |<Cell2>{ ls_header-bankaccount }</Cell2>| &&
                                  |</Row3>| &&
                                  |<Row4>| &&
                                      |<Cell2>{ lv_bank }</Cell2>| &&
                                  |</Row4>| &&
                              |</Table2>| &&
                           |</Sub2>|.



      DATA(lv_amount) = |{ abs( ls_header-PaymentAmountInPaytCurrency ) }|.
      DATA: lv_amountTXT TYPE string.
      zcl_get_unc=>convert_amount(
        EXPORTING
          lv_amount  = lv_amount
          lv_curr    = ls_header-PaymentCurrency
        CHANGING
          lv_convert = lv_amountTXT
      ).
      DATA lv_amount_tong TYPE fins_vwcur12.
      lv_amount_tong = |{ abs( ls_header-PaymentAmountInPaytCurrency ) }|.
      IF ls_header-PaymentCurrency = 'VND' OR ls_header-PaymentCurrency = 'JPY'.

        lv_amount_tong = lv_amount_tong * 100.
      ENDIF.

      DATA(lo_amount_in_words) = NEW zcore_cl_amount_in_words( ).
      DATA(lv_readamount) = lo_amount_in_words->read_amount_new(
        EXPORTING
          i_amount =  lv_amount_tong
          i_lang   = 'VI'
          i_waers  = ls_header-PaymentCurrency
      ).


      sub3xml = sub3xml && |<Sub3>| &&
                              |<Table3>| &&
                                  |<Row1>| &&
                                      |<Cell2>{ lv_amounttxt }</Cell2>| &&
                                  |</Row1>| &&
                                  |<Row2>| &&
                                      |<Cell2>{ lv_readamount }</Cell2>| &&
                                  |</Row2>| &&
                                  |<Row4>| &&
                                      |<Cell2>{ lw_quydoi }</Cell2>| &&
                                      |<Cell4>{ lw_tygia }</Cell4>| &&
                                  |</Row4>| &&
                                  |<Row5>| &&
                                      |<Cell1>{ lw_ptstc }</Cell1>| &&
                                      |<Cell3>{ lw_ptttm }</Cell3>| &&
                                  |</Row5>| &&
                                  |<Row6>| &&
                                      |<Cell1>{ lw_ptttk }</Cell1>| &&
                                      |<Cell3>{ lw_stk }</Cell3>| &&
                                  |</Row6>| &&
                              |</Table3>| &&
                           |</Sub3>|.

*    sub4
      DATA: lv_name   TYPE string,
            lv_addr   TYPE string,
            lv_stk    TYPE string,
            lv_bankth TYPE string.
      DATA lv_noidung TYPE string.
      READ TABLE lt_item INTO DATA(ls_item) WITH KEY PaymentDocument = ls_header-PaymentDocument  PaymentRunDate = ls_header-PaymentRunDate PaymentRunID = ls_header-PaymentRunID.
      IF sy-subrc = 0.
        SELECT SINGLE *
        FROM I_OperationalAcctgDocItem
        WHERE CompanyCode = @ls_item-PayingCompanyCode
        AND   FiscalYear  = @ls_item-FiscalYear
        AND   AccountingDocument = @ls_item-AccountingDocument
        AND   AccountingDocumentItem = @ls_item-AccountingDocumentItem
        INTO @DATA(ls_bseg).
        IF ls_bseg-AddressAndBankIsSetManually = 'X'.
          SELECT SINGLE * FROM I_JournalEntryItemOneTimeData
              WITH PRIVILEGED ACCESS
              WHERE CompanyCode = @ls_item-PayingCompanyCode
                AND   FiscalYear  = @ls_item-FiscalYear
                AND   AccountingDocument = @ls_item-AccountingDocument
                AND   AccountingDocumentItem = @ls_item-AccountingDocumentItem
                INTO @DATA(ls_bsec).
          IF ls_bsec-BusinessType IS INITIAL.
            lv_name = |{ ls_bsec-BusinessPartnerName1 } { ls_bsec-BusinessPartnerName2 } { ls_bsec-BusinessPartnerName3 } { ls_bsec-BusinessPartnerName4 }|.
          ELSE.
            lv_name = |{ ls_bsec-BusinessType }|.
          ENDIF.

          SELECT SINGLE countryname FROM I_CountryText
              WHERE Country = @ls_bsec-Country
              AND   Language = @sy-langu
              INTO @DATA(lv_country).
          lv_addr = |{ ls_bsec-StreetAddressName }, { ls_bsec-CityName }, { lv_country }|.

          lv_stk = ls_bsec-BankAccount.
          SELECT SINGLE
              BankName,
              Branch
           FROM I_Bank_2
           WHERE BankInternalID = @ls_bsec-BankNumber
           INTO @DATA(ls_bankname).
          IF ls_bankname-Branch IS NOT INITIAL.
            lv_bankth = |{ ls_bankname-BankName } - { ls_bankname-Branch }|.
          ELSE.
            lv_bankth = |{ ls_bankname-BankName }|.
          ENDIF.

        ELSE.
          IF ls_bseg-BPBankAccountInternalID IS INITIAL.
            SELECT SINGLE BankIdentification
              FROM I_BusinessPartnerBank
              WITH PRIVILEGED ACCESS
              WHERE BusinessPartner = @ls_header-Supplier
              INTO @DATA(lw_bankid).
          ELSE.
            lw_bankid = ls_bseg-BPBankAccountInternalID.
          ENDIF.

          SELECT SINGLE * FROM I_BusinessPartnerBank
              WHERE BusinessPartner = @ls_header-Supplier
              AND   BankIdentification = @lw_bankid
              INTO @DATA(ls_supplierBank).

          lv_name = |{ ls_supplierbank-BankAccountHolderName } { ls_supplierbank-BankAccountName }|.
          SELECT SINGLE * FROM I_Address_2
              WITH PRIVILEGED ACCESS
              WHERE AddressID = @ls_header-AddressID
              INTO @DATA(ls_addr).

*        zcl_jp_common_core=>get_address_id_details(
*          EXPORTING
*            addressid          = ls_proposal-AddressID
*          IMPORTING
*            o_addressiddetails = DATA(ls_addr)
*        ).
*        lv_addr = ls_addr-address.
*          SELECT SINGLE countryname FROM I_CountryText
*          WHERE Country = @ls_addr-Country
*          AND   Language = @sy-langu
*          INTO @DATA(lv_country_2).
*          lv_addr = |{ ls_addr-HouseNumber } { ls_addr-StreetName } { ls_addr-StreetPrefixName1  } { ls_addr-StreetPrefixName2 } { ls_addr-StreetSuffixName1 } { ls_addr-StreetSuffixName2 }, { ls_addr-CityName }, { lv_country_2 }|.

           DATA:ls_bp_in TYPE zst_document_info.
           ls_bp_in-accountingdocument = ls_bseg-AccountingDocument.
           ls_bp_in-companycode = ls_bseg-CompanyCode.
           ls_bp_in-fiscalyear = ls_bseg-FiscalYear.
           ls_bp_in-supplier = ls_bseg-Supplier.
           zcl_jp_common_core=>get_businesspartner_details(
             EXPORTING
               i_document  = ls_bp_in
             IMPORTING
               o_bpdetails = DATA(ls_bp_out)
           ).

           lv_addr = ls_bp_out-bpaddress.

          lv_stk = |{ ls_supplierbank-BankAccount }{ ls_supplierbank-BusinessPartnerExternalBankID }|.
          SELECT SINGLE
             BankName,
             Branch
          FROM I_Bank_2
          WHERE BankInternalID = @ls_supplierbank-BankNumber
          INTO @ls_bankname.
          IF ls_bankname-Branch IS NOT INITIAL.
            lv_bankth = |{ ls_bankname-BankName } - { ls_bankname-Branch }|.
          ELSE.
            lv_bankth = |{ ls_bankname-BankName }|.
          ENDIF.

        ENDIF.
      ENDIF.

      sub4xml = sub4xml && |<Sub4>| &&
                              |<Table4>| &&
                                  |<Row1>| &&
                                      |<Cell2>{ lv_name }</Cell2>| &&
                                  |</Row1>| &&
                                  |<Row4>| &&
                                      |<Cell2>{ lv_addr }</Cell2>| &&
                                  |</Row4>| &&
                                  |<Row5>| &&
                                      |<Cell2>{ lv_stk }</Cell2>| &&
                                  |</Row5>| &&
                                  |<Row6>| &&
                                      |<Cell2>{ lv_bankth }</Cell2>| &&
                                  |</Row6>| &&
                              |</Table4>| &&
                           |</Sub4>|.

*    sub5
      IF lw_noidung IS INITIAL.
        DATA(lv_cate) = ls_bseg-AccountingDocumentCategory.
        SELECT
            a~AccountingDocument,
            a~DocumentReferenceID,
            b~AccountingDocumentItem,
            b~AssignmentReference
            FROM I_JournalEntry AS a
            INNER JOIN I_OperationalAcctgDocItem AS b ON a~AccountingDocument = b~AccountingDocument
                                                     AND a~FiscalYear = b~FiscalYear
                                                     AND a~CompanyCode = b~CompanyCode
            FOR ALL ENTRIES IN @lt_item
            WHERE a~CompanyCode = @lt_item-PayingCompanyCode
            AND   a~FiscalYear  = @lt_item-FiscalYear
            AND   a~AccountingDocument = @lt_item-AccountingDocument
            AND   b~AccountingDocumentItem = @lt_item-AccountingDocumentItem
            INTO TABLE @DATA(lt_bseg).
        LOOP AT lt_item INTO ls_item WHERE PaymentDocument = ls_header-PaymentDocument AND PaymentRunDate = ls_header-PaymentRunDate AND PaymentRunID = ls_header-PaymentRunID.
          READ TABLE lt_bseg INTO DATA(ls_bseg_1) WITH KEY AccountingDocument = ls_item-AccountingDocument  AccountingDocumentItem = ls_item-AccountingDocumentItem.
          IF sy-subrc = 0.
            IF lv_cate = 'S' AND ls_bseg_1-AssignmentReference IS NOT INITIAL.
              IF lv_noidung IS INITIAL.
                lv_noidung = ls_bseg_1-AssignmentReference.
              ELSE.
                lv_noidung = |{ lv_noidung }, { ls_bseg_1-AssignmentReference }|.
              ENDIF.
            ELSEIF lv_cate <> 'S' AND ls_bseg_1-DocumentReferenceID IS NOT INITIAL.
              IF lv_noidung IS INITIAL.
                lv_noidung = ls_bseg_1-DocumentReferenceID.
              ELSE.
                lv_noidung = |{ lv_noidung }, { ls_bseg_1-DocumentReferenceID }|.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF lv_cate = 'S'.
          lv_noidung = |Thanh toán cho bill số { lv_noidung }|.
        ELSE.
          lv_noidung = |Thanh toán cho HĐ số { lv_noidung }|.
        ENDIF.

      ELSE.
        lv_noidung = lw_noidung.
      ENDIF.

      sub5xml = sub5xml && |<Sub5>| &&
                              |<Table5>| &&
                                  |<Row1>| &&
                                      |<Cell2>{ lv_noidung }</Cell2>| &&
                                  |</Row1>| &&
                              |</Table5>| &&
                           |</Sub5>|.

      xml = |<?xml version="1.0" encoding="UTF-8"?>| &&
         |<form>| &&
                    |{ sub1xml }| &&
                    |{ sub2xml }| &&
                    |{ sub3xml }| &&
                    |{ sub4xml }| &&
                    |{ sub5xml }| &&
         |</form>|
          .
      lv_xml_data_string    = cl_web_http_utility=>encode_x_base64(
                                cl_web_http_utility=>encode_utf8( xml )
                              ).
      lv_xml_data_xstring   = cl_web_http_utility=>decode_x_base64( lv_xml_data_string ).

      APPEND lv_xml_data_xstring TO ls_xml-data.

      CLEAR: xml, sub2xml, sub3xml, sub4xml, sub5xml, lv_xml_data, lv_xml_data_string, lv_xml_data_xstring, lv_noidung.
    ENDLOOP.


    DATA: str_pdf TYPE string.

    DATA(lv_pdf) = o_gen_adobe->print_pdf( EXPORTING i_xml   = ls_xml
                                                     iv_rpid = 'ZUNC'
                                           IMPORTING str_pdf = str_pdf ).

    o_pdf = lv_pdf.

    DATA: lv_filename TYPE string.

    lv_filename = |UyNhiemChi_{ sy-datlo }|.

    result = VALUE #(
                    FOR key IN keys (
*                       %cid_ref = key-%cid_ref
*                       %tky   = key-%tky
                    %cid   = k-%cid
                    %param = VALUE #( filecontent   = str_pdf
                                      filename      = lv_filename
                                      fileextension = 'pdf'
*                                              mimeType      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                      mimetype      = 'application/pdf'
                                      )
                    )
                    ).

    DATA: ls_mapped LIKE LINE OF mapped-zc_unc.
*    ls_mapped-%tky         = k-%tky.

    INSERT CORRESPONDING #( ls_mapped ) INTO TABLE mapped-zc_unc.
  ENDMETHOD.


  METHOD convert_amount.

    lv_convert = lv_amount.
    IF lv_curr = 'VND' OR lv_curr = 'JPY'.
      lv_convert = lv_convert * 100.
      SPLIT lv_convert AT '.' INTO lv_convert DATA(lv_del).
    ELSE.
      REPLACE ALL OCCURRENCES OF '.' IN lv_convert WITH ','.
    ENDIF.
    DATA flag_am TYPE char1.
    FIND '-' IN lv_amount.
    IF sy-subrc = 0.
      flag_am = 'X'.
      REPLACE ALL OCCURRENCES OF '-' IN lv_convert WITH ''.
    ENDIF.

    REPLACE ALL OCCURRENCES OF REGEX '(\d)(?=(\d{3})+(?!\d))'
    IN lv_convert WITH '$1.'.

    IF flag_am = 'X'.
      lv_convert = |-{ lv_convert }|.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

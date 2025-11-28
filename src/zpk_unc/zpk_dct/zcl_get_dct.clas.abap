CLASS zcl_get_dct DEFINITION
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
           BEGIN OF ty_bank,
             stk  TYPE c LENGTH 255,
             bank TYPE c LENGTH 255,
           END OF ty_bank,

           tt_range TYPE TABLE OF ty_range_option,
           tt_data  TYPE TABLE OF zc_dct,
           gt_data  TYPE TABLE OF zc_dct.
    TYPES: BEGIN OF lty_doc,
             CompanyCode                 TYPE bukrs,
             AccountingDocument          TYPE belnr_d,
             FiscalYear                  TYPE gjahr,
             DebitCreditCode             TYPE shkzg,
             Glaccount                   TYPE hkont,
             TransactionCurrency         TYPE waers,
             AmountInTransactionCurrency TYPE dmbtr,
             HouseBank                   TYPE hbkid,
             HouseBankAccount            TYPE hktid,
             DocumentItemText            TYPE sgtxt,
           END OF lty_doc.
    CLASS-DATA:
      o_fi_export_pdf TYPE REF TO zcl_jp_report_fi_export,
      o_gen_adobe     TYPE REF TO zcl_gen_adobe.

    CLASS-DATA:
     "Instance Singleton
     mo_instance      TYPE REF TO zcl_get_dct.

    TYPES:
      keys_dct     TYPE TABLE FOR ACTION IMPORT zc_dct~btnprintpdf,
      result_dct   TYPE TABLE FOR ACTION RESULT zc_dct~btnprintpdf,
      mapped_dct   TYPE RESPONSE FOR MAPPED EARLY zc_dct,
      failed_dct   TYPE RESPONSE FOR FAILED zc_dct,
      reported_dct TYPE RESPONSE FOR REPORTED EARLY zc_dct.

    CLASS-METHODS:
      btnPrintPDF_DCT IMPORTING keys     TYPE keys_dct
                      EXPORTING o_pdf    TYPE string
                      CHANGING  result   TYPE result_dct
                                mapped   TYPE mapped_dct
                                failed   TYPE failed_dct
                                reported TYPE reported_dct.


    CLASS-METHODS:
      "Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_get_dct,

      convert_amount IMPORTING lv_amount  TYPE string
                               lv_curr    TYPE waers
                     CHANGING  lv_convert TYPE string,

      get_bank_info IMPORTING zst_item  TYPE lty_doc
                    CHANGING  bank_info TYPE ty_bank.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GET_DCT IMPLEMENTATION.


  METHOD get_bank_info.
    IF zst_item-HouseBank IS INITIAL AND zst_item-HouseBankAccount IS INITIAL.
      SELECT SINGLE * FROM I_HouseBankAccountLinkage
            WHERE GLAccount = @zst_item-GLAccount
            AND CompanyCode = @zst_item-CompanyCode
            INTO @DATA(ls_banklinkage).
    ELSE.
      SELECT SINGLE * FROM I_HouseBankAccountLinkage
          WHERE HouseBank = @zst_item-HouseBank
          AND HouseBankAccount = @zst_item-HouseBankAccount
          AND CompanyCode = @zst_item-CompanyCode
          INTO @ls_banklinkage.
    ENDIF.
    bank_info-stk = ls_banklinkage-BankAccount.
    SELECT SINGLE * FROM I_Bank_2
             WHERE BankInternalID = @ls_banklinkage-BankInternalID
             INTO @DATA(ls_bank).
    IF sy-subrc = 0.
      IF ls_bank-BankBranch IS INITIAL.
        bank_info-bank = ls_bank-BankName.
      ELSE.
        bank_info-bank = |{ ls_bank-BankName } - { ls_bank-BankBranch }|.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
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


  METHOD btnprintpdf_dct.

    DATA: lt_split TYPE TABLE OF string.
    DATA: ir_doc     TYPE tt_range.

    READ TABLE keys INDEX 1 INTO DATA(k).

    IF k-%param-CompanyCode NE 'null'.
      DATA(lw_companycode) = k-%param-CompanyCode.
    ENDIF.
    IF k-%param-FiscalYear NE 'null'.
      DATA(lw_fiscalyear) = k-%param-FiscalYear.
    ENDIF.
    IF k-%param-stk NE 'null'.
      DATA(lw_stk) = k-%param-stk.
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

    FREE: lt_split.
    DATA: lw_belnr TYPE belnr_d.
    SPLIT k-%param-AccountingDocument AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO DATA(l_string).
      lw_belnr = |{ l_string ALPHA = IN }|.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = lw_belnr )        TO ir_doc.
    ENDLOOP.



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
    DATA: lv_xml_data_string  TYPE string,
          lv_xml_data_xstring TYPE xstring,
          lv_xml_data         TYPE string.
    DATA: lt_doc TYPE TABLE OF lty_doc.


    SELECT
            CompanyCode,
            FiscalYear,
            AccountingDocument,
            DebitCreditCode,
            Glaccount,
            TransactionCurrency,
            AmountInTransactionCurrency,
            HouseBank,
            HouseBankAccount,
            DocumentItemText
    FROM I_OperationalAcctgDocItem
    WHERE CompanyCode = @lw_companycode
    AND FiscalYear = @lw_fiscalyear
    AND AccountingDocument IN @ir_doc
    INTO CORRESPONDING FIELDS OF TABLE @lt_doc.

    SELECT
            SourceCompanyCode AS CompanyCode,
            SourceFiscalYear  AS FiscalYear,
            SourceAccountingDocument AS AccountingDocument,
            DebitCreditCode,
            Glaccount,
            TransactionCurrency,
            AmountInTransactionCurrency,
            HouseBank,
            HouseBankAccount,
            DocumentItemText
    FROM I_ParkedOplAcctgDocGLItem
    WHERE SourceCompanyCode = @lw_companycode
    AND SourceFiscalYear = @lw_fiscalyear
    AND SourceAccountingDocument IN @ir_doc
    APPENDING CORRESPONDING FIELDS OF TABLE @lt_doc.

    DATA(lt_header) = lt_doc[].
    SORT lt_header BY CompanyCode FiscalYear AccountingDocument.
    DELETE ADJACENT DUPLICATES FROM lt_header COMPARING CompanyCode FiscalYear AccountingDocument.

    DATA: lw_cc TYPE bukrs.
    lw_cc = lw_companycode.
    zcl_jp_common_core=>get_companycode_details(
                        EXPORTING
                            i_companycode = lw_cc
                        IMPORTING
                            o_companycode = DATA(ls_ccDetail)
                        ).


    LOOP AT lt_header INTO DATA(ls_header).

      sub1xml = sub1xml && |<Sub1>| &&
                              |<Table1>| &&
                                  |<Row1>| &&
                                      |<Cell2>{ lw_printdate }</Cell2>| &&
                                  |</Row1>| &&
                              |</Table1>| &&
                           |</Sub1>|.
      READ TABLE lt_doc INTO DATA(ls_trichno) WITH KEY AccountingDocument = ls_header-AccountingDocument CompanyCode = ls_header-CompanyCode
                                                       FiscalYear = ls_header-FiscalYear DebitCreditCode = 'H'.
      IF sy-subrc = 0.
        DATA: ls_bank_trichno TYPE ty_bank.
        zcl_get_dct=>get_bank_info(
          EXPORTING
            zst_item  = ls_trichno
          CHANGING
            bank_info = ls_bank_trichno
        ).
      ENDIF.

      sub2xml = sub2xml && |<Sub2>| &&
                              |<Table2>| &&
                                  |<Row1>| &&
                                      |<Cell2>{ ls_ccdetail-companycodename }</Cell2>| &&
                                  |</Row1>| &&
                                  |<Row2>| &&
                                      |<Cell2>{ ls_ccdetail-companycodeaddr }</Cell2>| &&
                                  |</Row2>| &&
                                  |<Row3>| &&
                                      |<Cell2>{ ls_bank_trichno-stk }</Cell2>| &&
                                  |</Row3>| &&
                                  |<Row4>| &&
                                      |<Cell2>{ ls_bank_trichno-bank }</Cell2>| &&
                                  |</Row4>| &&
                              |</Table2>| &&
                           |</Sub2>|.

      DATA(lv_amount) = |{ abs( ls_trichno-AmountInTransactionCurrency ) }|.
      DATA: lv_amountTXT TYPE string.
      zcl_get_dct=>convert_amount(
        EXPORTING
          lv_amount  = lv_amount
          lv_curr    = ls_header-TransactionCurrency
        CHANGING
          lv_convert = lv_amountTXT
      ).

      DATA: lv_amount_tong TYPE fins_vwcur12.
      lv_amount_tong = |{ abs( ls_trichno-AmountInTransactionCurrency ) }|.
      IF ls_header-TransactionCurrency = 'VND' OR ls_header-TransactionCurrency = 'JPY'.
        lv_amount_tong = lv_amount_tong * 100.
      ENDIF.

      DATA(lo_amount_in_words) = NEW zcore_cl_amount_in_words( ).
      DATA(lv_readamount) = lo_amount_in_words->read_amount_new(
        EXPORTING
          i_amount =  lv_amount_tong
          i_lang   = 'VI'
          i_waers  = ls_header-TransactionCurrency
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

      READ TABLE lt_doc INTO DATA(ls_nguoihuong) WITH KEY AccountingDocument = ls_header-AccountingDocument CompanyCode = ls_header-CompanyCode
                                                      FiscalYear = ls_header-FiscalYear DebitCreditCode = 'S'.
      IF sy-subrc = 0.
        DATA: ls_bank_nguoihuong TYPE ty_bank.
        zcl_get_dct=>get_bank_info(
          EXPORTING
            zst_item  = ls_nguoihuong
          CHANGING
            bank_info = ls_bank_nguoihuong
        ).
      ENDIF.

      sub4xml = sub4xml && |<Sub4>| &&
                              |<Table4>| &&
                                  |<Row1>| &&
                                      |<Cell2>{ ls_ccdetail-companycodename }</Cell2>| &&
                                  |</Row1>| &&
                                  |<Row4>| &&
                                      |<Cell2>{ ls_ccdetail-companycodeaddr }</Cell2>| &&
                                  |</Row4>| &&
                                  |<Row5>| &&
                                      |<Cell2>{ ls_bank_nguoihuong-stk }</Cell2>| &&
                                  |</Row5>| &&
                                  |<Row6>| &&
                                      |<Cell2>{ ls_bank_nguoihuong-bank }</Cell2>| &&
                                  |</Row6>| &&
                              |</Table4>| &&
                           |</Sub4>|.

      IF lw_noidung IS INITIAL.
        DATA(lv_noidung) = ls_trichno-DocumentItemText.
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

      CLEAR: xml, sub2xml, sub3xml, sub4xml, sub5xml, lv_xml_data, lv_xml_data_string, lv_xml_data_xstring, ls_nguoihuong, ls_trichno.
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

    DATA: ls_mapped LIKE LINE OF mapped-zc_dct.
*    ls_mapped-%tky         = k-%tky.

    INSERT CORRESPONDING #( ls_mapped ) INTO TABLE mapped-zc_dct.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA: ls_page_info TYPE zcl_get_fillter=>st_page_info,

          ir_bukrs     TYPE tt_range,
          ir_belnr     TYPE tt_range,
          ir_gjahr     TYPE tt_range,
          ir_stk       TYPE tt_range,
          ir_printdate TYPE tt_range,
          ir_quydoi    TYPE tt_range,
          ir_tygia     TYPE tt_range,
          ir_ptstc     TYPE tt_range,
          ir_ptttm     TYPE tt_range,
          ir_ptttk     TYPE tt_range,
          ir_noidung   TYPE tt_range.
    DATA: gw_printdate TYPE budat,
          gw_quydoi    TYPE char72,
          gw_tygia     TYPE char72,
          gw_ptstc     TYPE zde_checkbox,
          gw_ptttm     TYPE zde_checkbox,
          gw_ptttk     TYPE zde_checkbox,
          gw_noidung   TYPE zde_char255,
          gw_stk       TYPE c LENGTH 20.

    DATA: lt_data TYPE TABLE OF zc_dct,
          gt_data TYPE TABLE OF zc_dct,
          ls_data TYPE zc_dct.
    FREE: lt_data, gt_data.
    TRY.
* Khởi tạo đối tượng
        DATA(lo_dct)  = zcl_get_dct=>get_instance( ).

        DATA(lo_comcode) = zcl_jp_common_core=>get_instance(  ).

        DATA(lo_common_app) = zcl_get_fillter_dct=>get_instance( ).

*  Lấy tham số
        lo_common_app->get_fillter_app(
          EXPORTING
            io_request         = io_request
            io_response        = io_response
          IMPORTING
            ir_bukrs           = ir_bukrs
            ir_belnr           = ir_belnr
            ir_gjahr           = ir_gjahr
            ir_printdate       = ir_printdate
            ir_quydoi          = ir_quydoi
            ir_tygia           = ir_tygia
            ir_ptstc           = ir_ptstc
            ir_ptttm           = ir_ptttm
            ir_ptttk           = ir_ptttk
            ir_noidung         = ir_noidung
            ir_stk             = ir_stk
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

        SELECT * FROM zc_accountdoc_status
            WHERE CompanyCode IN @ir_bukrs
            AND FiscalYear IN @ir_gjahr
            AND AccountingDocument IN @ir_belnr
            INTO TABLE @DATA(lt_accounting).
        DATA: ir_key TYPE tt_range.
        LOOP AT lt_accounting ASSIGNING FIELD-SYMBOL(<fs_key>).
            <fs_key>-OriginalReferenceDocument = |{ <fs_key>-AccountingDocument }{ <fs_key>-CompanyCode }{ <fs_key>-FiscalYear }|.
        ENDLOOP.

        IF sy-subrc = 0.
          DATA: lt_doc TYPE TABLE OF lty_doc.

          SELECT * FROM I_WorkflowStatusOverview
            FOR ALL ENTRIES IN @lt_accounting
            WHERE SAPObjectNodeRepresentation = 'ToBeVerifiedGenJournalEntry'
            AND SAPBusinessObjectNodeKey1 = @lt_accounting-OriginalReferenceDocument
            INTO TABLE @DATA(lt_workflow).
          SORT lt_workflow BY SAPBusinessObjectNodeKey1.
          DATA: flag_del TYPE char1.
          LOOP AT lt_accounting INTO DATA(ls_accounting).
            flag_del = 'X'.

            IF ls_accounting-Category = ''
                OR ls_accounting-Category = 'L'
                OR ls_accounting-Category = 'U'.
              CLEAR: flag_del.
            ELSE.
              READ TABLE lt_workflow INTO DATA(ls_workflow) WITH KEY SAPBusinessObjectNodeKey1 = ls_accounting-OriginalReferenceDocument BINARY SEARCH.
              IF sy-subrc = 0 AND ls_workflow-WorkflowExternalStatus = 'STARTED'.
                CLEAR: flag_del.
              ENDIF.
            ENDIF.

            IF flag_del = 'X'.
              DELETE lt_accounting WHERE CompanyCode = ls_accounting-CompanyCode AND FiscalYear = ls_accounting-FiscalYear AND AccountingDocument = ls_accounting-AccountingDocument.
            ENDIF.
          ENDLOOP.

          SELECT
           CompanyCode,
           FiscalYear,
           AccountingDocument,
           DebitCreditCode,
           Glaccount,
           TransactionCurrency,
           AmountInTransactionCurrency,
           HouseBank,
           HouseBankAccount,
           DocumentItemText
       FROM I_OperationalAcctgDocItem
       FOR ALL ENTRIES IN @lt_accounting
       WHERE CompanyCode = @lt_accounting-companycode
       AND FiscalYear = @lt_accounting-fiscalyear
       AND AccountingDocument = @lt_accounting-AccountingDocument
       INTO CORRESPONDING FIELDS OF TABLE @lt_doc.

          SELECT
              SourceCompanyCode AS CompanyCode,
              SourceFiscalYear  AS FiscalYear,
              SourceAccountingDocument AS AccountingDocument,
              DebitCreditCode,
              Glaccount,
              TransactionCurrency,
              AmountInTransactionCurrency,
              HouseBank,
              HouseBankAccount,
              DocumentItemText
          FROM I_ParkedOplAcctgDocGLItem
          FOR ALL ENTRIES IN @lt_accounting
          WHERE SourceCompanyCode = @lt_accounting-companycode
          AND SourceFiscalYear = @lt_accounting-FiscalYear
          AND SourceAccountingDocument = @lt_accounting-AccountingDocument
          APPENDING CORRESPONDING FIELDS OF TABLE @lt_doc.


          LOOP AT lt_doc INTO DATA(ls_doc) WHERE GLAccount+0(3) <> '112'.
            DELETE lt_doc WHERE CompanyCode = ls_doc-CompanyCode AND FiscalYear = ls_doc-FiscalYear AND AccountingDocument = ls_doc-AccountingDocument.
            DELETE lt_accounting WHERE CompanyCode = ls_doc-CompanyCode AND FiscalYear = ls_doc-FiscalYear AND AccountingDocument = ls_doc-AccountingDocument.
          ENDLOOP.

        ENDIF.


        LOOP AT lt_accounting INTO ls_accounting.
          ls_data-AccountingDocument = ls_accounting-AccountingDocument.
          ls_data-CompanyCode = ls_accounting-CompanyCode.
          ls_data-FiscalYear  = ls_accounting-FiscalYear.
          ls_data-QuyDoi = gw_quydoi.
          ls_data-TyGia = gw_tygia.
          ls_data-ptstc = gw_ptstc.
          ls_data-ptttk = gw_ptttk.
          ls_data-ptttm = gw_ptttm.
          ls_data-PrintDate = gw_printdate.
          ls_data-stk = gw_stk.
          ls_data-NoiDung = gw_noidung.
          APPEND ls_data TO gt_data.
          CLEAR: ls_data.
        ENDLOOP.


*          export data
        IF ls_page_info-page_size < 0.
          ls_page_info-page_size = 50.
        ENDIF.

        DATA(max_rows) = COND #( WHEN ls_page_info-page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                   ELSE ls_page_info-page_size ).

        max_rows = ls_page_info-page_size + ls_page_info-offset.

        LOOP AT gt_data INTO ls_data.
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

        RAISE EXCEPTION TYPE zcl_get_dct
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
ENDCLASS.

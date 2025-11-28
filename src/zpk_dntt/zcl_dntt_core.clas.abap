CLASS zcl_dntt_core DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,


           BEGIN OF ty_page_info,
             paging           TYPE REF TO if_rap_query_paging,
             page_size        TYPE int8,
             offset           TYPE int8,
             requested_fields TYPE if_rap_query_request=>tt_requested_elements,
             sort_order       TYPE if_rap_query_request=>tt_sort_elements,
             ro_filter        TYPE REF TO if_rap_query_filter,
             entity_id        TYPE string,
           END OF ty_page_info,

           tt_range     TYPE TABLE OF ty_range_option,
           st_page_info TYPE ty_page_info.

    TYPES:
      keys     TYPE TABLE FOR ACTION IMPORT zc_dntt~btnprintpdf,
      result   TYPE TABLE FOR ACTION RESULT zc_dntt~btnprintpdf,
      mapped   TYPE RESPONSE FOR MAPPED EARLY zc_dntt,
      failed   TYPE RESPONSE FOR FAILED zc_dntt,
      reported TYPE RESPONSE FOR REPORTED EARLY zc_dntt.
    CLASS-DATA:
      o_fi_export_pdf TYPE REF TO zcl_jp_report_fi_export,
      o_gen_adobe     TYPE REF TO zcl_gen_adobe.

    CLASS-DATA:
     "Instance Singleton
     mo_instance      TYPE REF TO zcl_dntt_core.

    CLASS-METHODS:
      btnPrintPDF   IMPORTING keys     TYPE keys
                    EXPORTING o_pdf    TYPE string
                    CHANGING  result   TYPE result
                              mapped   TYPE mapped
                              failed   TYPE failed
                              reported TYPE reported,

      btnDisplayPDF   IMPORTING keys     TYPE keys
                      EXPORTING o_pdf    TYPE string
                      CHANGING  result   TYPE result
                                mapped   TYPE mapped
                                failed   TYPE failed
                                reported TYPE reported,

      get_bp_name IMPORTING i_businesspartner TYPE kunnr
                            i_bptype          TYPE char1
                  CHANGING  o_bpName          TYPE char255,

      convert_amount IMPORTING lv_amount  TYPE dmbtr
                               lv_curr    TYPE waers
                     CHANGING  lv_convert TYPE string,
      "Contructor khỏi tạo đối tượng
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_dntt_core,

      "Get fillter app
      get_fillter_app IMPORTING io_request   TYPE REF TO if_rap_query_request
                                io_response  TYPE REF TO if_rap_query_response
                      EXPORTING ir_bukrs     TYPE tt_range
                                ir_budat     TYPE tt_range
                                ir_sup       TYPE tt_range
                                ir_cus       TYPE tt_range
                                ir_gjahr     TYPE tt_range
                                ir_belnr     TYPE tt_range
                                ir_sodn      TYPE tt_range
                                ir_open      TYPE tt_range
                                ir_refer     TYPE tt_range
                                o_ngayDN     TYPE char255
                                o_hanHT      TYPE char255
                                o_nguoiDN    TYPE char255
                                o_phong      TYPE char255
                                o_time       TYPE char255
                                o_nguoilap   TYPE char255
                                o_ketoan     TYPE char255
                                o_banKS      TYPE char255
                                o_GD         TYPE char255
                                o_KTT        TYPE char255
                                o_TGD        TYPE char255
                                wa_page_info TYPE st_page_info
                      .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dntt_core IMPLEMENTATION.


  METHOD convert_amount.
    DATA(lv_amountTxt) = |{ lv_amount }|.
    lv_convert = lv_amounttxt.
    IF lv_curr = 'VND' OR lv_curr = 'JPY'.
      lv_convert = lv_convert * 100.
      SPLIT lv_convert AT '.' INTO lv_convert DATA(lv_del).
    ELSE.
      REPLACE ALL OCCURRENCES OF '.' IN lv_convert WITH ','.
    ENDIF.
    DATA flag_am TYPE char1.
    FIND '-' IN lv_amounttxt.
    IF sy-subrc = 0.
      flag_am = 'X'.
      REPLACE ALL OCCURRENCES OF '-' IN lv_convert WITH ''.
    ENDIF.

    REPLACE ALL OCCURRENCES OF REGEX '(\d)(?=(\d{3})+(?!\d))'
    IN lv_convert WITH '$1.'.

    IF flag_am = 'X'.
      lv_convert = |-{ lv_convert }|.
    ENDIF.

    CONDENSE lv_convert.
  ENDMETHOD.


  METHOD btnprintpdf.
    DATA(o_gen_adobe) = NEW zcl_gen_adobe( ).
    DATA: ls_xml TYPE zcl_gen_adobe=>ty_gs_xml.

    DATA: xml     TYPE string,
          sub1xml TYPE string,
          sub2xml TYPE string,
          sub3xml TYPE string,
          sub4xml TYPE string,
          sub5xml TYPE string,
          linexml TYPE string.
    DATA: lt_split TYPE TABLE OF string.
    DATA: ir_doc  TYPE tt_range,
          ir_year TYPE tt_range,
          ir_cc   TYPE tt_range.

    READ TABLE keys INDEX 1 INTO DATA(k).

    TYPES: BEGIN OF lty_acdoca,
             AccountingDocument TYPE belnr_d,
             FiscalYear         TYPE gjahr,
             CompanyCode        TYPE bukrs,
           END OF lty_acdoca.
    DATA: lt_para  TYPE TABLE OF lty_acdoca,
          lw_bukrs TYPE bukrs.

    SPLIT k-%param-CompanyCode AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO DATA(l_string).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_cc.
      lw_bukrs = l_string.
    ENDLOOP.

    FREE: lt_split.
    SPLIT k-%param-JournalEntry AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO l_string.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_doc.
    ENDLOOP.

    FREE: lt_split.
    SPLIT k-%param-FiscalYear AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO l_string.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_year.
    ENDLOOP.

    LOOP AT ir_cc INTO DATA(ls_range).
      APPEND INITIAL LINE TO lt_para ASSIGNING FIELD-SYMBOL(<fs_para>).
      <fs_para>-companycode = ls_range-low.
      READ TABLE ir_doc INTO ls_range INDEX sy-tabix.
      IF sy-subrc = 0.
        <fs_para>-accountingdocument = ls_range-low.
        <fs_para>-accountingdocument = |{ <fs_para>-accountingdocument ALPHA = IN }|.
      ENDIF.
      READ TABLE ir_year INTO ls_range INDEX sy-tabix.
      IF sy-subrc = 0.
        <fs_para>-fiscalyear = ls_range-low.
      ENDIF.
    ENDLOOP.

    IF k-%param-NgayDeNghi NE 'null' AND k-%param-NgayDeNghi NE '--'.
      DATA(lw_ngaydenghi) = |{ k-%param-NgayDeNghi+8(2) }/{ k-%param-NgayDeNghi+5(2) }/{ k-%param-NgayDeNghi+0(4) }|.
    ENDIF.
    IF k-%param-HanThanhToan NE 'null' AND k-%param-HanThanhToan NE '--'.
      DATA(lw_hanthanhtoan) = |{ k-%param-HanThanhToan+8(2) }/{ k-%param-HanThanhToan+5(2) }/{ k-%param-HanThanhToan+0(4) }|.
    ENDIF.
    IF k-%param-ThoiGianTH NE 'null' AND k-%param-ThoiGianTH NE '--'.
      DATA(lw_thoigianTH) = |{ k-%param-ThoiGianTH+8(2) }/{ k-%param-ThoiGianTH+5(2) }/{ k-%param-ThoiGianTH+0(4) }|.
    ENDIF.
    IF k-%param-NguoiDeNghi NE 'null'.
      DATA(lw_nguoidenghi) = k-%param-NguoiDeNghi.
    ENDIF.
    IF k-%param-PhongBan NE 'null'.
      DATA(lw_phongban) = k-%param-PhongBan.
    ENDIF.
    IF k-%param-NguoiLap NE 'null'.
      DATA(lw_nguoilap) = k-%param-NguoiLap.
    ENDIF.
    IF k-%param-KeToan NE 'null'.
      DATA(lw_ketoan) = k-%param-KeToan.
    ENDIF.
    IF k-%param-KeToanTruong NE 'null'.
      DATA(lw_ketoantruong) = k-%param-KeToanTruong.
    ENDIF.
    IF k-%param-BanKiemSoat NE 'null'.
      DATA(lw_bks) = k-%param-BanKiemSoat.
    ENDIF.
    IF k-%param-GIamDoc NE 'null'.
      DATA(lw_gd) = k-%param-GIamDoc.
    ENDIF.
    IF k-%param-TongGIamDoc NE 'null'.
      DATA(lw_tgd) = k-%param-TongGIamDoc.
    ENDIF.


    SELECT
    h~AccountingDocument,
    h~FiscalYear,
    h~CompanyCode,
    h~TransactionCurrency,
    h~AbsoluteExchangeRate,
    h~DocumentReferenceID,
    h~AccountingDocumentHeaderText,
    h~AccountingDocumentCategory,
    d~DocumentItemText,
    d~PaymentMethod,
    d~AmountInTransactionCurrency,
    d~Customer,
    d~Supplier,
    d~DebitCreditCode,
    d~Glaccount,
    d~BPBankAccountInternalID
    FROM I_JournalEntry AS h
    INNER JOIN I_OperationalAcctgDocItem AS d
    ON h~AccountingDocument = d~AccountingDocument
    AND h~FiscalYear = d~FiscalYear
    AND h~CompanyCode = d~CompanyCode
    FOR ALL ENTRIES IN @lt_para
    WHERE h~AccountingDocument = @lt_para-accountingdocument
    AND h~FiscalYear = @lt_para-fiscalyear
    AND h~CompanyCode = @lt_para-companycode
    INTO TABLE @DATA(lt_data).
    SORT lt_data BY AccountingDocument FiscalYear CompanyCode.

    DATA(lt_bp) = lt_data[].
    DATA(lt_doc) = lt_data[].

    SORT lt_bp BY Customer Supplier PaymentMethod TransactionCurrency.
    DELETE lt_bp WHERE Customer IS INITIAL AND Supplier IS INITIAL.
    DELETE ADJACENT DUPLICATES FROM lt_bp COMPARING Customer Supplier PaymentMethod TransactionCurrency.

    SORT lt_doc BY AccountingDocument FiscalYear CompanyCode Supplier DESCENDING Customer DESCENDING .
    DELETE ADJACENT DUPLICATES FROM lt_doc COMPARING AccountingDocument FiscalYear CompanyCode.

    DATA: lw_stt TYPE c LENGTH 4.
    LOOP AT lt_bp INTO DATA(ls_bp).
      DATA: lw_net_sum       TYPE dmbtr,
            lw_vat_sum       TYPE dmbtr,
            lw_total_sum     TYPE dmbtr,
            lw_net_sum_txt   TYPE string,
            lw_vat_sum_txt   TYPE string,
            lw_total_sum_txt TYPE string.

      CLEAR: lw_stt.
      DATA(lo_comcode) = zcl_jp_common_core=>get_instance(  ).
      lo_comcode->get_companycode_details(
        EXPORTING
          i_companycode = ls_bp-CompanyCode
        IMPORTING
          o_companycode = DATA(ls_companycode)
      ).
      SELECT SINGLE VATRegistration FROM I_CompanyCode
          WHERE CompanyCode = @ls_bp-CompanyCode
          INTO @DATA(lw_mst).

*       sub1
      sub1xml = sub1xml && |<Sub1>| &&
                                |<TextField1>{ ls_companycode-companycodename }</TextField1>| &&
                                |<TextField2>Địa chỉ: { ls_companycode-companycodeaddr }</TextField2>| &&
                                |<TextField3>Mã số thuế: { lw_mst }</TextField3>| &&
                                |<TextField4></TextField4>| &&
                           |</Sub1>|.

      LOOP AT lt_doc INTO DATA(ls_doc) WHERE PaymentMethod = ls_bp-PaymentMethod AND Supplier = ls_bp-Supplier AND Customer = ls_bp-Customer AND TransactionCurrency = ls_bp-TransactionCurrency.
        DATA: lw_bp TYPE kunnr.
        DATA(lw_ExchangeRate) = ls_doc-AbsoluteExchangeRate.
        IF ls_doc-customer IS INITIAL.
          lw_bp = ls_doc-Supplier.
        ELSE.
          lw_bp = ls_doc-Customer.
        ENDIF.
        DATA(lw_bankID) = ls_doc-BPBankAccountInternalID.
        IF lw_bankid IS INITIAL.
          SELECT SINGLE BankIdentification
            FROM I_BusinessPartnerBank
            WITH PRIVILEGED ACCESS
            WHERE BusinessPartner = @lw_bp
            INTO @lw_bankid.
        ENDIF.
        DATA(lw_payment) = ls_doc-PaymentMethod.
        IF ls_doc-DocumentItemText IS INITIAL.
          DATA(lw_diendai) = ls_doc-AccountingDocumentHeaderText.
        ELSE.
          lw_diendai = ls_doc-DocumentItemText.
        ENDIF.
        lw_diendai = |Thanh toán { lw_diendai }|.

        DATA: lw_vat      TYPE dmbtr,
              lw_net      TYPE dmbtr,
              lw_total    TYPE dmbtr,
              lw_vatTXT   TYPE String,
              lw_netTXT   TYPE String,
              lw_totalTXT TYPE String.
        LOOP AT lt_data INTO DATA(ls_data) WHERE AccountingDocument = ls_doc-AccountingDocument AND FiscalYear = ls_doc-FiscalYear AND CompanyCode = ls_doc-CompanyCode.
          IF ls_data-GLAccount+0(3) = '133' OR ls_data-GLAccount+0(3) = '333'.
            lw_vat = lw_vat + ls_data-AmountInTransactionCurrency.
          ENDIF.
          IF ls_data-AccountingDocumentCategory = 'S'.
            lw_total = lw_total + abs( ls_data-AmountInTransactionCurrency ).
          ELSE.
            IF ls_data-DebitCreditCode = 'S'.
              lw_total = lw_total + ls_data-AmountInTransactionCurrency.
            ENDIF.
          ENDIF.
        ENDLOOP.
        lw_total = abs( lw_total ).
        lw_vat = abs( lw_vat ).
        lw_net = lw_total - lw_vat.

        zcl_dntt_core=>convert_amount(
          EXPORTING
            lv_amount  = lw_net
            lv_curr    = ls_doc-TransactionCurrency
          CHANGING
            lv_convert = lw_netTXT
        ).
        zcl_dntt_core=>convert_amount(
          EXPORTING
            lv_amount  = lw_vat
            lv_curr    = ls_doc-TransactionCurrency
          CHANGING
            lv_convert = lw_vatTXT
        ).
        zcl_dntt_core=>convert_amount(
          EXPORTING
            lv_amount  = lw_total
            lv_curr    = ls_doc-TransactionCurrency
          CHANGING
            lv_convert = lw_totalTXT
        ).

        REPLACE ALL OCCURRENCES OF '&' IN ls_doc-DocumentReferenceID WITH '&amp;'.
        REPLACE ALL OCCURRENCES OF '<' IN ls_doc-DocumentReferenceID WITH '&lt;'.
        REPLACE ALL OCCURRENCES OF '>' IN ls_doc-DocumentReferenceID WITH '&gt;'.

        lw_stt = lw_stt + 1.
        CONDENSE lw_stt.
*        chỉ lấy ký tự sau dấu #
        find '#' in ls_doc-DocumentReferenceID.
        IF sy-subrc = 0.
          DATA: lw_split TYPE string.
          SPLIT ls_doc-DocumentReferenceID AT '#' INTO lw_split ls_doc-DocumentReferenceID .
        ENDIF.
        linexml = linexml &&
                                     |<Row3>| &&
                                         |<Cell1>{ lw_stt }</Cell1>| &&
                                         |<Cell2>{ ls_doc-DocumentReferenceID }</Cell2>| &&
                                         |<Cell3>{ lw_diendai }</Cell3>| &&
                                         |<Cell4>{ lw_nettxt }</Cell4>| &&
                                         |<Cell5>{ lw_vattxt }</Cell5>| &&
                                         |<Cell6>{ lw_totaltxt } { ls_doc-TransactionCurrency }</Cell6>| &&
                                     |</Row3>|
                                     .
        lw_net_sum = lw_net_sum + lw_net.
        lw_vat_sum = lw_vat_sum + lw_vat.
        lw_total_sum = lw_total_sum + lw_total.
        CLEAR: lw_vat, lw_vattxt, lw_net, lw_nettxt, lw_total, lw_totaltxt.
      ENDLOOP.

      zcl_dntt_core=>convert_amount(
        EXPORTING
          lv_amount  = lw_net_sum
          lv_curr    = ls_doc-TransactionCurrency
        CHANGING
          lv_convert = lw_net_sum_TXT
      ).
      zcl_dntt_core=>convert_amount(
        EXPORTING
          lv_amount  = lw_vat_sum
          lv_curr    = ls_doc-TransactionCurrency
        CHANGING
          lv_convert = lw_vat_sum_TXT
      ).
      zcl_dntt_core=>convert_amount(
        EXPORTING
          lv_amount  = lw_total_sum
          lv_curr    = ls_doc-TransactionCurrency
        CHANGING
          lv_convert = lw_total_sum_TXT
      ).

      sub4xml = sub4xml && |<Sub4>| &&
                                 |<Table4>| &&
                                     |{ linexml }| &&
                                     |<Row4>| &&
                                         |<Cell4>{ lw_net_sum_txt }</Cell4>| &&
                                         |<Cell5>{ lw_vat_sum_txt }</Cell5>| &&
                                         |<Cell6>{ lw_total_sum_txt } { ls_doc-TransactionCurrency }</Cell6>| &&
                                     |</Row4>| &&
                                 |</Table4>| &&
                             |</Sub4>|.

      DATA(lo_amount_in_words) = NEW zcore_cl_amount_in_words( ).
      IF ls_doc-TransactionCurrency = 'VND' OR ls_doc-TransactionCurrency = 'JPY'.
        lw_total_sum = lw_total_sum * 100.
      ENDIF.
      DATA(lv_readamount) = lo_amount_in_words->read_amount_new(
        EXPORTING
          i_amount =  lw_total_sum
          i_lang   = 'VI'
          i_waers  = ls_doc-TransactionCurrency
      ).

*      sub2
      SELECT SINGLE * FROM I_BusinessPartnerBank
                    WHERE BusinessPartner = @lw_bp
                    AND   BankIdentification = @lw_bankid
                    INTO @DATA(ls_supplierBank).


      DATA(lv_name) = |{ ls_supplierbank-BankAccountHolderName } { ls_supplierbank-BankAccountName }|.

      DATA(lv_stk) = |{ ls_supplierbank-BankAccount }{ ls_supplierbank-BusinessPartnerExternalBankID }|.

      IF ls_supplierbank-BankCountryKey <> 'VN'.
        DATA(lw_swiff) = ls_supplierbank-BankNumber.
      ENDIF.

      SELECT SINGLE
         BankName,
         Branch
      FROM I_Bank_2
      WHERE BankInternalID = @ls_supplierbank-BankNumber
      INTO @DATA(ls_bankname).
      IF ls_bankname-Branch IS NOT INITIAL.
        DATA(lv_bankth) = |{ ls_bankname-BankName } - { ls_bankname-Branch }|.
      ELSE.
        lv_bankth = |{ ls_bankname-BankName }|.
      ENDIF.

      DATA: lw_paymentTXT TYPE c LENGTH 20.
      IF lw_payment = 1.
        lw_paymentTXT = 'Tiền mặt'.
      ELSE.
        lw_paymenttxt = 'Chuyển khoản'.
      ENDIF.
      CONDENSE lw_paymenttxt.
      sub2xml = sub2xml && |<Sub2>| &&
                          |<Table2>| &&
                              |<Row1>| &&
                                  |<Cell2>{ lw_ngaydenghi }</Cell2>| &&
                                  |<Cell4>{ lw_hanthanhtoan }</Cell4>| &&
                              |</Row1>| &&
                              |<Row2>| &&
                                  |<Cell2>{ lw_nguoidenghi }</Cell2>| &&
                                  |<Cell4>{ lw_phongban }</Cell4>| &&
                              |</Row2>| &&
                              |<Row3>| &&
                                  |<Cell2>{ lw_paymenttxt }</Cell2>| &&
                              |</Row3>| &&
                              |<Row4>| &&
                                  |<Cell2>{ lv_name }</Cell2>| &&
                              |</Row4>| &&
                              |<Row5>| &&
                                  |<Cell2>{ lv_stk }</Cell2>| &&
                              |</Row5>| &&
                              |<Row6>| &&
                                  |<Cell2>{ lv_bankth }</Cell2>| &&
                              |</Row6>| &&
                              |<Row7>| &&
                                  |<Cell2>{ lw_swiff }</Cell2>| &&
                              |</Row7>| &&
                          |</Table2>| &&
                       |</Sub2>|.

*    sub3
*      IF lw_exchangerate <> 0.
*        DATA(lw_ratetxt) = |1 { ls_doc-TransactionCurrency } = { lw_exchangerate } VND|.
*      ENDIF.
      sub3xml = sub3xml && |<Sub3>| &&
                                      |<Table3>| &&
                                          |<Row2>| &&
                                              |<Cell2>{ lw_thoigianth }</Cell2>| &&
                                          |</Row2>| &&
                                          |<Row4>| &&
*                                              |<Cell2>{ lw_ratetxt }</Cell2>| &&
                                          |</Row4>| &&
                                      |</Table3>| &&
                                  |</Sub3>|.

*        sub 5
      sub5xml = sub5xml && |<Sub5>| &&
                            |<Table5>| &&
                                |<Row1>| &&
                                    |<Cell2>{ lv_readamount }</Cell2>| &&
                                |</Row1>| &&
                                |<Row2>| &&
                                    |<Cell2>{ lw_nguoilap }</Cell2>| &&
                                    |<Cell4>{ lw_gd }</Cell4>| &&
                                |</Row2>| &&
                                |<Row3>| &&
                                    |<Cell2>{ lw_ketoan }</Cell2>| &&
                                    |<Cell4>{ lw_ketoantruong }</Cell4>| &&
                                |</Row3>| &&
                                |<Row4>| &&
                                    |<Cell2>{ lw_bks }</Cell2>| &&
                                    |<Cell4>{ lw_tgd }</Cell4>| &&
                                |</Row4>| &&
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
      CLEAR: ls_supplierbank, ls_bankname, lw_vat_sum, lw_vat_sum_txt, lw_net_sum, lw_net_sum_txt, lw_total_sum, lw_total_sum_txt, lv_readamount, lv_name, lv_stk, lv_bankth, lw_paymenttxt.
      DATA: lv_xml_data_string  TYPE string,
            lv_xml_data_xstring TYPE xstring,
            lv_xml_data         TYPE string.
      lv_xml_data_string    = cl_web_http_utility=>encode_x_base64(
                                cl_web_http_utility=>encode_utf8( xml )
                              ).
      lv_xml_data_xstring   = cl_web_http_utility=>decode_x_base64( lv_xml_data_string ).

      APPEND lv_xml_data_xstring TO ls_xml-data.

      CLEAR: xml, sub1xml, sub2xml, sub3xml, sub4xml, sub5xml, linexml, lv_xml_data, lv_xml_data_string, lv_xml_data_xstring, lw_bankid, lw_bp.
    ENDLOOP.



    DATA: str_pdf TYPE string.

    DATA(lv_pdf) = o_gen_adobe->print_pdf( EXPORTING i_xml   = ls_xml
                                                     iv_rpid = 'ZDNTT'
                                           IMPORTING str_pdf = str_pdf ).

    o_pdf = lv_pdf.

    DATA: lv_filename TYPE string.

    lv_filename = |DeNghiTT_{ sy-datlo }|.

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

    DATA: ls_mapped LIKE LINE OF mapped-zc_dntt.
*    ls_mapped-%tky         = k-%tky.

    INSERT CORRESPONDING #( ls_mapped ) INTO TABLE mapped-zc_dntt.
  ENDMETHOD.


  METHOD get_bp_name.
    CHECK i_businesspartner IS NOT INITIAL.
    IF i_bptype = 'C'.
      SELECT SINGLE * FROM I_Customer WITH PRIVILEGED ACCESS
        WHERE Customer = @i_businesspartner
        INTO @DATA(ls_cus).
      IF sy-subrc = 0.
        o_bpname = ls_cus-BPCustomerFullName.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM I_Supplier WITH PRIVILEGED ACCESS
          WHERE Supplier = @i_businesspartner
          INTO @DATA(ls_sup).
      IF sy-subrc = 0.
        o_bpname = ls_sup-BPSupplierFullName.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_fillter_app.

    wa_page_info-paging            = io_request->get_paging( ).

    wa_page_info-page_size         = io_request->get_paging( )->get_page_size( ).

    wa_page_info-offset            = io_request->get_paging( )->get_offset( ).

    wa_page_info-requested_fields  = io_request->get_requested_elements( ).

    wa_page_info-sort_order        = io_request->get_sort_elements( ).

    wa_page_info-ro_filter         = io_request->get_filter( ).

    wa_page_info-entity_id         = io_request->get_entity_id( ).

    TRY.
        DATA(lr_ranges) = wa_page_info-ro_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.

    LOOP AT lr_ranges INTO DATA(ls_ranges).
      CASE ls_ranges-name.
        WHEN 'COMPANYCODE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_bukrs.
        WHEN 'SUPPLIER'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_sup.
        WHEN 'CUSTOMER'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_cus.
        WHEN 'FISCALYEAR'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_gjahr.
        WHEN 'JOURNALENTRY'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_belnr.
        WHEN 'POSTINGDATE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_budat.
        WHEN 'OPENITEM'.
          READ TABLE ls_ranges-range INTO DATA(ls_val) INDEX 1.
          IF ls_val-low = 'X'.
            ls_val-low = ''.
            APPEND ls_val TO ir_open.
          ENDIF.
        WHEN 'SODENGHI'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_sodn.
        WHEN 'REFERENCE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_refer.
        WHEN 'NGAYDENGHI'.
          READ TABLE ls_ranges-range INTO ls_val INDEX 1.
          IF ls_val-low IS INITIAL.
            ls_val-low = sy-datum.
          ENDIF.
          o_ngaydn = ls_val-low.
        WHEN 'HANTHANHTOAN'.
          READ TABLE ls_ranges-range INTO ls_val INDEX 1.
          READ TABLE ls_ranges-range INTO ls_val INDEX 1.
          IF ls_val-low IS INITIAL.
            ls_val-low = sy-datum.
          ENDIF.
          o_hanht = ls_val-low.
        WHEN 'NGUOIDENGHI'.
          READ TABLE ls_ranges-range INTO ls_val INDEX 1.
          o_nguoidn = ls_val-low.
        WHEN 'PHONGBAN'.
          READ TABLE ls_ranges-range INTO ls_val INDEX 1.
          o_phong = ls_val-low.
        WHEN 'THOIGIANTH'.
          READ TABLE ls_ranges-range INTO ls_val INDEX 1.
          READ TABLE ls_ranges-range INTO ls_val INDEX 1.
          IF ls_val-low IS INITIAL.
            ls_val-low = sy-datum.
          ENDIF.
          o_time = ls_val-low.
        WHEN 'NGUOILAP'.
          READ TABLE ls_ranges-range INTO ls_val INDEX 1.
          o_nguoilap = ls_val-low.
        WHEN 'KETOAN'.
          READ TABLE ls_ranges-range INTO ls_val INDEX 1.
          o_ketoan = ls_val-low.
        WHEN 'BANKIEMSOAT'.
          READ TABLE ls_ranges-range INTO ls_val INDEX 1.
          o_banks = ls_val-low.
        WHEN 'GIAMDOC'.
          READ TABLE ls_ranges-range INTO ls_val INDEX 1.
          o_gd = ls_val-low.
        WHEN 'KETOANTRUONG'.
          READ TABLE ls_ranges-range INTO ls_val INDEX 1.
          o_ktt = ls_val-low.
        WHEN 'TONGGIAMDOC'.
          READ TABLE ls_ranges-range INTO ls_val INDEX 1.
          o_tgd = ls_val-low.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD btndisplaypdf.
    DATA(o_gen_adobe) = NEW zcl_gen_adobe( ).
    DATA: ls_xml TYPE zcl_gen_adobe=>ty_gs_xml.

    DATA: xml     TYPE string,
          sub1xml TYPE string,
          sub2xml TYPE string,
          sub3xml TYPE string,
          sub4xml TYPE string,
          sub5xml TYPE string,
          linexml TYPE string.
    DATA: lt_split TYPE TABLE OF string.
    DATA: ir_doc  TYPE tt_range,
          ir_year TYPE tt_range,
          ir_sodn TYPE tt_range.

    READ TABLE keys INDEX 1 INTO DATA(k).

    TYPES: BEGIN OF lty_acdoca,
             AccountingDocument TYPE belnr_d,
             FiscalYear         TYPE gjahr,
             CompanyCode        TYPE bukrs,
           END OF lty_acdoca.
    DATA: lt_para  TYPE TABLE OF lty_acdoca,
          lw_bukrs TYPE bukrs.

    SPLIT k-%param-SoDeNghi AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO DATA(l_string).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_sodn.
    ENDLOOP.
    SORT ir_sodn BY low.
    DELETE ir_sodn WHERE low IS INITIAL.
    DELETE ADJACENT DUPLICATES FROM ir_sodn COMPARING low.

    SELECT * FROM ztb_dntt WHERE sodenghi IN @ir_sodn INTO TABLE @DATA(lt_db).
    SORT lt_db BY journalentry fiscalyear companycode.

    SELECT
    h~AccountingDocument,
    h~FiscalYear,
    h~CompanyCode,
    h~TransactionCurrency,
    h~AbsoluteExchangeRate,
    h~DocumentReferenceID,
    h~AccountingDocumentHeaderText,
    d~DocumentItemText,
    d~PaymentMethod,
    d~AmountInTransactionCurrency,
    d~Customer,
    d~Supplier,
    d~DebitCreditCode,
    d~Glaccount,
    d~BPBankAccountInternalID
    FROM I_JournalEntry AS h
    INNER JOIN I_OperationalAcctgDocItem AS d
    ON h~AccountingDocument = d~AccountingDocument
    AND h~FiscalYear = d~FiscalYear
    AND h~CompanyCode = d~CompanyCode
    FOR ALL ENTRIES IN @lt_db
    WHERE h~AccountingDocument = @lt_db-journalentry
    AND h~FiscalYear = @lt_db-fiscalyear
    AND h~CompanyCode = @lt_db-companycode
    INTO TABLE @DATA(lt_data).
    SORT lt_data BY AccountingDocument FiscalYear CompanyCode.

    DATA(lt_doc) = lt_data[].

    SORT lt_doc BY AccountingDocument FiscalYear CompanyCode Supplier DESCENDING Customer DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_doc COMPARING AccountingDocument FiscalYear CompanyCode.
    DATA: lw_stt TYPE c LENGTH 4.
    LOOP AT ir_sodn INTO DATA(ls_range).
      DATA: lw_net_sum       TYPE dmbtr,
            lw_vat_sum       TYPE dmbtr,
            lw_total_sum     TYPE dmbtr,
            lw_net_sum_txt   TYPE string,
            lw_vat_sum_txt   TYPE string,
            lw_total_sum_txt TYPE string.

      CLEAR lw_stt.
      READ TABLE lt_db INTO DATA(ls_header) WITH KEY sodenghi = ls_range-low.
      IF sy-subrc =  0.
        DATA(lw_ngaydenghi) = |{ ls_header-ngaydenghi+6(2) }/{ ls_header-NgayDeNghi+4(2) }/{ ls_header-NgayDeNghi+0(4) }|.
        DATA(lw_hanthanhtoan) = |{ ls_header-HanThanhToan+6(2) }/{ ls_header-HanThanhToan+4(2) }/{ ls_header-HanThanhToan+0(4) }|.
        DATA(lw_thoigianTH) = |{ ls_header-thoigianth+6(2) }/{ ls_header-ThoiGianTH+4(2) }/{ ls_header-ThoiGianTH+0(4) }|.
        DATA(lw_nguoidenghi) = ls_header-NguoiDeNghi.
        DATA(lw_phongban) = ls_header-PhongBan.
        DATA(lw_nguoilap) = ls_header-NguoiLap.
        DATA(lw_ketoan) = ls_header-KeToan.
        DATA(lw_ketoantruong) = ls_header-KeToanTruong.
        DATA(lw_bks) = ls_header-BanKiemSoat.
        DATA(lw_gd) = ls_header-GIamDoc.
        DATA(lw_tgd) = ls_header-TongGIamDoc.

        IF lw_ngaydenghi = '00/00/0000'.
          CLEAR: lw_ngaydenghi.
        ENDIF.
        IF lw_hanthanhtoan = '00/00/0000'.
          CLEAR: lw_hanthanhtoan.
        ENDIF.
        IF lw_thoigianTH = '00/00/0000'.
          CLEAR: lw_thoigianTH.
        ENDIF.

        DATA(lo_comcode) = zcl_jp_common_core=>get_instance(  ).
        lo_comcode->get_companycode_details(
          EXPORTING
            i_companycode = ls_header-companycode
          IMPORTING
            o_companycode = DATA(ls_companycode)
        ).
        SELECT SINGLE VATRegistration FROM I_CompanyCode
            WHERE CompanyCode = @ls_header-companycode
            INTO @DATA(lw_mst).
      ENDIF.

*       sub1
      sub1xml = sub1xml && |<Sub1>| &&
                                |<TextField1>{ ls_companycode-companycodename }</TextField1>| &&
                                |<TextField2>Địa chỉ: { ls_companycode-companycodeaddr }</TextField2>| &&
                                |<TextField3>Mã số thuế: { lw_mst }</TextField3>| &&
                                |<TextField4>No. { ls_range-low }</TextField4>| &&
                           |</Sub1>|.

      LOOP AT lt_db INTO DATA(ls_db) WHERE sodenghi = ls_range-low.
        READ TABLE lt_doc INTO DATA(ls_doc) WITH KEY AccountingDocument = ls_db-journalentry FiscalYear = ls_db-fiscalyear CompanyCode = ls_db-companycode.
        DATA: lw_bp TYPE kunnr.
        DATA(lw_ExchangeRate) = ls_doc-AbsoluteExchangeRate.
        IF ls_doc-customer IS INITIAL.
          lw_bp = ls_doc-Supplier.
        ELSE.
          lw_bp = ls_doc-Customer.
        ENDIF.
        DATA(lw_bankID) = ls_doc-BPBankAccountInternalID.
        IF lw_bankid IS INITIAL.
          SELECT SINGLE BankIdentification
            FROM I_BusinessPartnerBank
            WITH PRIVILEGED ACCESS
            WHERE BusinessPartner = @lw_bp
            INTO @lw_bankid.
        ENDIF.
        DATA(lw_payment) = ls_doc-PaymentMethod.
        IF ls_doc-DocumentItemText IS INITIAL.
          DATA(lw_diendai) = ls_doc-AccountingDocumentHeaderText.
        ELSE.
          lw_diendai = ls_doc-DocumentItemText.
        ENDIF.

        lw_diendai = |Thanh toán { lw_diendai }|.

        DATA: lw_vat      TYPE dmbtr,
              lw_net      TYPE dmbtr,
              lw_total    TYPE dmbtr,
              lw_vatTXT   TYPE String,
              lw_netTXT   TYPE String,
              lw_totalTXT TYPE String.
        LOOP AT lt_data INTO DATA(ls_data) WHERE AccountingDocument = ls_doc-AccountingDocument AND FiscalYear = ls_doc-FiscalYear AND CompanyCode = ls_doc-CompanyCode.
          IF ls_data-GLAccount+0(3) = '133' OR ls_data-GLAccount+0(3) = '333'.
            lw_vat = lw_vat + ls_data-AmountInTransactionCurrency.
          ENDIF.
          IF ls_data-DebitCreditCode = 'S'.
            lw_total = lw_total + ls_data-AmountInTransactionCurrency.
          ENDIF.
        ENDLOOP.
        lw_total = abs( lw_total ).
        lw_vat = abs( lw_vat ).
        lw_net = lw_total - lw_vat.

        zcl_dntt_core=>convert_amount(
          EXPORTING
            lv_amount  = lw_net
            lv_curr    = ls_doc-TransactionCurrency
          CHANGING
            lv_convert = lw_netTXT
        ).
        zcl_dntt_core=>convert_amount(
          EXPORTING
            lv_amount  = lw_vat
            lv_curr    = ls_doc-TransactionCurrency
          CHANGING
            lv_convert = lw_vatTXT
        ).
        zcl_dntt_core=>convert_amount(
          EXPORTING
            lv_amount  = lw_total
            lv_curr    = ls_doc-TransactionCurrency
          CHANGING
            lv_convert = lw_totalTXT
        ).

        REPLACE ALL OCCURRENCES OF '&' IN ls_doc-DocumentReferenceID WITH '&amp;'.
        REPLACE ALL OCCURRENCES OF '<' IN ls_doc-DocumentReferenceID WITH '&lt;'.
        REPLACE ALL OCCURRENCES OF '>' IN ls_doc-DocumentReferenceID WITH '&gt;'.
        lw_stt = lw_stt + 1.
        CONDENSE lw_stt.
*        chỉ lấy ký tự sau dấu #
        FIND '#' IN ls_doc-DocumentReferenceID.
        IF sy-subrc = 0.
          DATA: lw_split TYPE string.
          SPLIT ls_doc-DocumentReferenceID AT '#' INTO lw_split ls_doc-DocumentReferenceID .
        ENDIF.
        linexml = linexml &&
                                     |<Row3>| &&
                                         |<Cell1>{ lw_stt }</Cell1>| &&
                                         |<Cell2>{ ls_doc-DocumentReferenceID }</Cell2>| &&
                                         |<Cell3>{ lw_diendai }</Cell3>| &&
                                         |<Cell4>{ lw_nettxt }</Cell4>| &&
                                         |<Cell5>{ lw_vattxt }</Cell5>| &&
                                         |<Cell6>{ lw_totaltxt } { ls_doc-TransactionCurrency }</Cell6>| &&
                                     |</Row3>|
                                     .
        lw_net_sum = lw_net_sum + lw_net.
        lw_vat_sum = lw_vat_sum + lw_vat.
        lw_total_sum = lw_total_sum + lw_total.
        CLEAR: lw_vat, lw_vattxt, lw_net, lw_nettxt, lw_total, lw_totaltxt.
      ENDLOOP.

      zcl_dntt_core=>convert_amount(
        EXPORTING
          lv_amount  = lw_net_sum
          lv_curr    = ls_doc-TransactionCurrency
        CHANGING
          lv_convert = lw_net_sum_TXT
      ).
      zcl_dntt_core=>convert_amount(
        EXPORTING
          lv_amount  = lw_vat_sum
          lv_curr    = ls_doc-TransactionCurrency
        CHANGING
          lv_convert = lw_vat_sum_TXT
      ).
      zcl_dntt_core=>convert_amount(
        EXPORTING
          lv_amount  = lw_total_sum
          lv_curr    = ls_doc-TransactionCurrency
        CHANGING
          lv_convert = lw_total_sum_TXT
      ).

      sub4xml = sub4xml && |<Sub4>| &&
                                 |<Table4>| &&
                                     |{ linexml }| &&
                                     |<Row4>| &&
                                         |<Cell4>{ lw_net_sum_txt }</Cell4>| &&
                                         |<Cell5>{ lw_vat_sum_txt }</Cell5>| &&
                                         |<Cell6>{ lw_total_sum_txt } { ls_doc-TransactionCurrency }</Cell6>| &&
                                     |</Row4>| &&
                                 |</Table4>| &&
                             |</Sub4>|.

      DATA(lo_amount_in_words) = NEW zcore_cl_amount_in_words( ).
      IF ls_doc-TransactionCurrency = 'VND' OR ls_doc-TransactionCurrency = 'JPY'.
        lw_total_sum = lw_total_sum * 100.
      ENDIF.
      DATA(lv_readamount) = lo_amount_in_words->read_amount_new(
        EXPORTING
          i_amount =  lw_total_sum
          i_lang   = 'VI'
          i_waers  = ls_doc-TransactionCurrency
      ).

*      sub2
      SELECT SINGLE * FROM I_BusinessPartnerBank
                    WHERE BusinessPartner = @lw_bp
                    AND   BankIdentification = @lw_bankid
                    INTO @DATA(ls_supplierBank).


      DATA(lv_name) = |{ ls_supplierbank-BankAccountHolderName } { ls_supplierbank-BankAccountName }|.

      DATA(lv_stk) = |{ ls_supplierbank-BankAccount }{ ls_supplierbank-BusinessPartnerExternalBankID }|.

      IF ls_supplierbank-BankCountryKey <> 'VN'.
        DATA(lw_swiff) = ls_supplierbank-BankNumber.
      ENDIF.

      SELECT SINGLE
         BankName,
         Branch
      FROM I_Bank_2
      WHERE BankInternalID = @ls_supplierbank-BankNumber
      INTO @DATA(ls_bankname).
      IF ls_bankname-Branch IS NOT INITIAL.
        DATA(lv_bankth) = |{ ls_bankname-BankName } - { ls_bankname-Branch }|.
      ELSE.
        lv_bankth = |{ ls_bankname-BankName }|.
      ENDIF.

      DATA: lw_paymentTXT TYPE c LENGTH 20.
      IF lw_payment = 1.
        lw_paymentTXT = 'Tiền mặt'.
      ELSE.
        lw_paymenttxt = 'Chuyển khoản'.
      ENDIF.
      CONDENSE lw_paymenttxt.
      sub2xml = sub2xml && |<Sub2>| &&
                          |<Table2>| &&
                              |<Row1>| &&
                                  |<Cell2>{ lw_ngaydenghi }</Cell2>| &&
                                  |<Cell4>{ lw_hanthanhtoan }</Cell4>| &&
                              |</Row1>| &&
                              |<Row2>| &&
                                  |<Cell2>{ lw_nguoidenghi }</Cell2>| &&
                                  |<Cell4>{ lw_phongban }</Cell4>| &&
                              |</Row2>| &&
                              |<Row3>| &&
                                  |<Cell2>{ lw_paymenttxt }</Cell2>| &&
                              |</Row3>| &&
                              |<Row4>| &&
                                  |<Cell2>{ lv_name }</Cell2>| &&
                              |</Row4>| &&
                              |<Row5>| &&
                                  |<Cell2>{ lv_stk }</Cell2>| &&
                              |</Row5>| &&
                              |<Row6>| &&
                                  |<Cell2>{ lv_bankth }</Cell2>| &&
                              |</Row6>| &&
                              |<Row7>| &&
                                  |<Cell2>{ lw_swiff }</Cell2>| &&
                              |</Row7>| &&
                          |</Table2>| &&
                       |</Sub2>|.

*    sub3
*      IF lw_exchangerate <> 0.
*        DATA(lw_ratetxt) = |1 { ls_doc-TransactionCurrency } = { lw_exchangerate } VND|.
*      ENDIF.
      sub3xml = sub3xml && |<Sub3>| &&
                                      |<Table3>| &&
                                          |<Row2>| &&
                                              |<Cell2>{ lw_thoigianth }</Cell2>| &&
                                          |</Row2>| &&
                                          |<Row4>| &&
*                                              |<Cell2>{ lw_ratetxt }</Cell2>| &&
                                          |</Row4>| &&
                                      |</Table3>| &&
                                  |</Sub3>|.

*        sub 5
      sub5xml = sub5xml && |<Sub5>| &&
                            |<Table5>| &&
                                |<Row1>| &&
                                    |<Cell2>{ lv_readamount }</Cell2>| &&
                                |</Row1>| &&
                                |<Row2>| &&
                                    |<Cell2>{ lw_nguoilap }</Cell2>| &&
                                    |<Cell4>{ lw_gd }</Cell4>| &&
                                |</Row2>| &&
                                |<Row3>| &&
                                    |<Cell2>{ lw_ketoan }</Cell2>| &&
                                    |<Cell4>{ lw_ketoantruong }</Cell4>| &&
                                |</Row3>| &&
                                |<Row4>| &&
                                    |<Cell2>{ lw_bks }</Cell2>| &&
                                    |<Cell4>{ lw_tgd }</Cell4>| &&
                                |</Row4>| &&
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
      CLEAR: ls_supplierbank, ls_bankname, lw_vat_sum, lw_vat_sum_txt, lw_net_sum, lw_net_sum_txt, lw_total_sum, lw_total_sum_txt, lv_readamount, lv_name, lv_stk, lv_bankth, lw_paymenttxt.
      DATA: lv_xml_data_string  TYPE string,
            lv_xml_data_xstring TYPE xstring,
            lv_xml_data         TYPE string.
      lv_xml_data_string    = cl_web_http_utility=>encode_x_base64(
                                cl_web_http_utility=>encode_utf8( xml )
                              ).
      lv_xml_data_xstring   = cl_web_http_utility=>decode_x_base64( lv_xml_data_string ).

      APPEND lv_xml_data_xstring TO ls_xml-data.

      CLEAR: xml, sub1xml, sub2xml, sub3xml, sub4xml, sub5xml, linexml, lv_xml_data, lv_xml_data_string, lv_xml_data_xstring, lw_bankid, lw_bp.
    ENDLOOP.



    DATA: str_pdf TYPE string.

    DATA(lv_pdf) = o_gen_adobe->print_pdf( EXPORTING i_xml   = ls_xml
                                                     iv_rpid = 'ZDNTT'
                                           IMPORTING str_pdf = str_pdf ).

    o_pdf = lv_pdf.

    DATA: lv_filename TYPE string.

    lv_filename = |DeNghiTT_{ sy-datlo }|.

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

    DATA: ls_mapped LIKE LINE OF mapped-zc_dntt.
*    ls_mapped-%tky         = k-%tky.

    INSERT CORRESPONDING #( ls_mapped ) INTO TABLE mapped-zc_dntt.
  ENDMETHOD.
ENDCLASS.

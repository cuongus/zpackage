CLASS zcl_jp_report_fi_export DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_printqueue,
        companycode        TYPE bukrs,
        accountingdocument TYPE belnr_d,
        fiscalyear         TYPE gjahr,
        itemid             TYPE cl_print_queue_utils=>ty_itemid,
        content            TYPE xstring,
      END OF ty_printqueue,

      keys_pkt        TYPE TABLE FOR ACTION IMPORT zjp_c_phieuketoan_2~btnprintpdf,
      result_pkt      TYPE TABLE FOR ACTION RESULT zjp_c_phieuketoan_2~btnprintpdf,
      mapped_pkt      TYPE RESPONSE FOR MAPPED EARLY zjp_c_phieuketoan_2,
      failed_pkt      TYPE RESPONSE FOR FAILED EARLY zjp_c_phieuketoan_2,
      reported_pkt    TYPE RESPONSE FOR REPORTED EARLY zjp_c_phieuketoan_2,

      keys_prtqueue   TYPE TABLE FOR ACTION IMPORT zjp_c_phieuketoan_2~btnprintqueue,
      result_prtqueue TYPE TABLE FOR ACTION RESULT zjp_c_phieuketoan_2~btnprintqueue,

      reported_save   TYPE RESPONSE FOR REPORTED LATE zjp_c_phieuketoan_2.

    CLASS-DATA: gt_printqueue TYPE TABLE OF ty_printqueue,
                gs_printqueue TYPE ty_printqueue.

    TYPES: BEGIN OF ty_pkt_items,
             companycode               TYPE bukrs,
             accountingdocument        TYPE belnr_d,
             fiscalyear                TYPE gjahr,
             legderglitem              TYPE zde_char6,

             postingdate               TYPE budat,
             documentdate              TYPE bldat,
             accountingdocumenttype    TYPE blart,

             glaccount                 TYPE hkont,

             absoluteexchangerate      TYPE zde_dmbtr,

             documentitemtext          TYPE sgtxt,

             debitamountincompanycode  TYPE zde_dmbtr,

             creditamountincompanycode TYPE zde_dmbtr,

             companycodecurrency       TYPE waers,

             debitamountintransaction  TYPE zde_dmbtr,

             creditamountintransaction TYPE zde_dmbtr,

             transactioncurrency       TYPE waers,

             customer                  TYPE kunnr,
             supplier                  TYPE lifnr,

             debitcreditcode           TYPE shkzg,
             isnegativeposting         TYPE abap_boolean,
           END OF ty_pkt_items,

           BEGIN OF ty_pkt_items_ext,
             documentitemtext TYPE sgtxt,
             tkno             TYPE hkont,
             tkco             TYPE hkont,
             cocodeamount     TYPE zde_dmbtr,
           END OF ty_pkt_items_ext,

           BEGIN OF ty_sign,
             accountant TYPE zde_char255,
             createby   TYPE zde_char255,
           END OF ty_sign,

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
           END OF ty_ftr_ctx,

           tt_pkt_item_ext TYPE TABLE OF ty_pkt_items_ext,
           tt_sign         TYPE TABLE OF ty_sign.


    CLASS-DATA:
      ir_companycode        TYPE zcl_jp_get_data_report_fi=>tt_ranges,
      ir_accountingdocument TYPE zcl_jp_get_data_report_fi=>tt_ranges,
      ir_fiscalyear         TYPE zcl_jp_get_data_report_fi=>tt_ranges,
      ir_documentitem       TYPE zcl_jp_get_data_report_fi=>tt_ranges,
      ir_postingdate        TYPE zcl_jp_get_data_report_fi=>tt_ranges,
      ir_documentdate       TYPE zcl_jp_get_data_report_fi=>tt_ranges,
      ir_documenttype       TYPE zcl_jp_get_data_report_fi=>tt_ranges,
      ir_customer           TYPE zcl_jp_get_data_report_fi=>tt_ranges,
      ir_supplier           TYPE zcl_jp_get_data_report_fi=>tt_ranges,

      ir_accountant         TYPE zcl_jp_get_data_report_fi=>tt_ranges,
      ir_createby           TYPE zcl_jp_get_data_report_fi=>tt_ranges.

    CLASS-DATA:
      o_fi_export_pdf TYPE REF TO zcl_jp_report_fi_export,
      o_gen_adobe     TYPE REF TO zcl_gen_adobe.

    METHODS: constructor.

    CLASS-METHODS:
      btnprintpdf_pkt IMPORTING keys       TYPE keys_pkt
                                printqueue TYPE abap_boolean OPTIONAL
                      EXPORTING o_pdf      TYPE string
                      CHANGING  result     TYPE result_pkt
                                mapped     TYPE mapped_pkt
                                failed     TYPE failed_pkt
                                reported   TYPE reported_pkt,

      btnprintpdf_pkt_new IMPORTING keys       TYPE keys_pkt
                                    printqueue TYPE abap_boolean OPTIONAL
                          EXPORTING o_pdf      TYPE string
                          CHANGING  result     TYPE result_pkt
                                    mapped     TYPE mapped_pkt
                                    failed     TYPE failed_pkt
                                    reported   TYPE reported_pkt,

      btnprintqueue_pkt IMPORTING keys       TYPE keys_prtqueue
                                  printqueue TYPE abap_boolean OPTIONAL
                        EXPORTING o_pdf      TYPE string
                        CHANGING  result     TYPE result_prtqueue
                                  mapped     TYPE mapped_pkt
                                  failed     TYPE failed_pkt
                                  reported   TYPE reported_pkt,

      pkt_process_save CHANGING reported TYPE reported_save.

    METHODS: process_data IMPORTING ir_companycode        TYPE zcl_jp_common_core=>tt_ranges
                                    ir_accountingdocument TYPE zcl_jp_common_core=>tt_ranges
                                    ir_fiscalyear         TYPE zcl_jp_common_core=>tt_ranges
                                    ir_accountant         TYPE zcl_jp_common_core=>tt_ranges
                                    ir_createby           TYPE zcl_jp_common_core=>tt_ranges
                          EXPORTING et_items              TYPE tt_pkt_item_ext
                                    et_sign               TYPE tt_sign
                                    e_hdr                 TYPE ty_hdr_ctx
                                    e_ftr                 TYPE ty_ftr_ctx.

  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_JP_REPORT_FI_EXPORT IMPLEMENTATION.


  METHOD btnprintpdf_pkt.

    DATA: lt_pkt_item TYPE TABLE OF ty_pkt_items.

    DATA: lv_companycode        TYPE bukrs,
          lv_accountingdocument TYPE belnr_d,
          lv_fiscalyear         TYPE gjahr.

    DATA: lv_amounttext  TYPE string,
          lv_amounttotal TYPE zde_dmbtr,
          lv_sdate       TYPE string.

    READ TABLE keys INDEX 1 INTO DATA(k).

*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-companycode )        TO ir_companycode.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-accountingdocument ) TO ir_accountingdocument.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-fiscalyear )         TO ir_fiscalyear.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-accountant )         TO ir_accountant.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-createby )           TO ir_createby.

    DATA: headerxml TYPE string,
          rowsxml   TYPE string,
          footerxml TYPE string.

    DATA: xml TYPE string.

    DATA: lv_tkno TYPE zde_char10,
          lv_tkco TYPE zde_char10.

    DATA: i_document TYPE zst_document_info.

    " dữ liệu
    DATA: lt_items TYPE STANDARD TABLE OF ty_pkt_items_ext,  "Table1
          ls_items TYPE ty_pkt_items_ext.
    DATA lt_sign  TYPE STANDARD TABLE OF ty_sign.            "Table2 (nếu dùng Role/Name)
    " map TABLE_ID -> ref
    DATA lt_refs TYPE zcl_ads_xml_builder=>tt_table_data_ref.

    " header/footer context
    DATA ls_hdr TYPE ty_hdr_ctx.  "COMPANYCODENAME, ...
    DATA ls_ftr TYPE ty_ftr_ctx.  "TOTALAMOUNT, AMOUNTTEXT

    CREATE OBJECT: o_fi_export_pdf, o_gen_adobe.

    o_fi_export_pdf->process_data(
      EXPORTING
        ir_companycode        = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear         = ir_fiscalyear
        ir_accountant         = ir_accountant
        ir_createby           = ir_createby
      IMPORTING
        et_items              = lt_items
        et_sign               = lt_sign
        e_hdr                 = ls_hdr
        e_ftr                 = ls_ftr
    ).

    APPEND VALUE #( table_id = 'TABLE1' dref = REF #( lt_items ) ) TO lt_refs.
    APPEND VALUE #( table_id = 'TABLE2' dref = REF #( lt_sign  ) ) TO lt_refs.

    DATA(xml_auto) = zcl_ads_xml_builder=>build_xml_by_form(
      i_form_id     = 'zphieuketoan'
      i_header_ctx  = ls_hdr
      i_footer_ctx  = ls_ftr
      it_table_data = lt_refs ).

    DATA: ls_request TYPE zcl_gen_adobe=>ts_request.

*    DATA(lv_pdf) = o_gen_adobe->call_data( EXPORTING i_request = ls_request ).

    DATA: str_pdf TYPE string.

*    DATA(lv_pdf) = o_gen_adobe->print_pdf( EXPORTING iv_xml  = xml_auto
*                                                     iv_rpid = 'zphieuketoan'
*                                           IMPORTING str_pdf = str_pdf ).

*    o_pdf = lv_pdf.

    DATA: lv_name TYPE string.

*    lv_name = |PhieuKeToan_{ k-%tky-companycode }{ k-%tky-fiscalyear }{ k-%tky-accountingdocument }|.
*
*    result = VALUE #(
*                    FOR key IN keys (
**                      %cid_ref = key-%cid_ref
*                    %tky   = key-%tky
*                    %param = VALUE #( filecontent   = str_pdf
*                                      filename      = lv_name
*                                      fileextension = 'pdf'
**                                          mimeType      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
*                                      mimetype      = 'application/pdf'
*                                      )
*                    )
*                    ).
*
*    DATA: ls_mapped LIKE LINE OF mapped-zjp_c_phieuketoan_2.
*    ls_mapped-%tky         = k-%tky.

*    INSERT CORRESPONDING #( ls_mapped ) INTO TABLE mapped-zjp_c_phieuketoan_2.

  ENDMETHOD.


  METHOD btnprintqueue_pkt.

    DATA: lt_pkt_item TYPE TABLE OF ty_pkt_items.

    DATA: lv_companycode        TYPE bukrs,
          lv_accountingdocument TYPE belnr_d,
          lv_fiscalyear         TYPE gjahr.

    DATA: lv_amounttext  TYPE string,
          lv_amounttotal TYPE zde_dmbtr,
          lv_sdate       TYPE string.

    READ TABLE keys INDEX 1 INTO DATA(k).

    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-companycode )        TO ir_companycode.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-accountingdocument ) TO ir_accountingdocument.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-fiscalyear )         TO ir_fiscalyear.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-accountant )         TO ir_accountant.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-createby )           TO ir_createby.


*    READ TABLE lt_phieuketoan INTO DATA(ls_phieuketoan) INDEX 1.

    DATA: headerxml TYPE string,
          rowsxml   TYPE string,
          footerxml TYPE string.

    DATA: xml TYPE string.

    DATA: lv_tkno TYPE zde_char10,
          lv_tkco TYPE zde_char10.

    " dữ liệu
    DATA: lt_items TYPE STANDARD TABLE OF ty_pkt_items_ext,  "Table1
          ls_items TYPE ty_pkt_items_ext.
    DATA lt_sign  TYPE STANDARD TABLE OF ty_sign.            "Table2 (nếu dùng Role/Name)
    " map TABLE_ID -> ref
    DATA lt_refs TYPE zcl_ads_xml_builder=>tt_table_data_ref.

    " header/footer context
    DATA ls_hdr TYPE ty_hdr_ctx.  "COMPANYCODENAME, ...
    DATA ls_ftr TYPE ty_ftr_ctx.  "TOTALAMOUNT, AMOUNTTEXT

    CREATE OBJECT: o_fi_export_pdf, o_gen_adobe.

    o_fi_export_pdf->process_data(
      EXPORTING
        ir_companycode        = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear         = ir_fiscalyear
        ir_accountant         = ir_accountant
        ir_createby           = ir_createby
      IMPORTING
        et_items              = lt_items
        et_sign               = lt_sign
        e_hdr                 = ls_hdr
        e_ftr                 = ls_ftr
    ).

    APPEND VALUE #( table_id = 'TABLE1' dref = REF #( lt_items ) ) TO lt_refs.
    APPEND VALUE #( table_id = 'TABLE2' dref = REF #( lt_sign  ) ) TO lt_refs.

    DATA(xml_auto) = zcl_ads_xml_builder=>build_xml_by_form(
      i_form_id     = 'zphieuketoan'
      i_header_ctx  = ls_hdr
      i_footer_ctx  = ls_ftr
      it_table_data = lt_refs ).

    DATA: lv_name TYPE string.

    lv_name = |PKT_{ k-%tky-companycode }{ k-%tky-fiscalyear }{ k-%tky-accountingdocument }|.


    IF printqueue = 'X'.

*      DATA(iv_itemid) = o_gen_adobe->get_queue( iv_qname = 'PRINT_USER' ).
      DATA:
        lv_xml_data_string TYPE string,
        lv_xml_final       TYPE xstring.

      lv_xml_data_string    = cl_web_http_utility=>encode_x_base64(
                                cl_web_http_utility=>encode_utf8( xml )
                              ).
      lv_xml_final          = cl_web_http_utility=>decode_x_base64( lv_xml_data_string ).

      DATA(rv_pdf) = o_gen_adobe->render_4_pq(
        iv_qname = 'PRINT_USER'
        iv_xml   = xml_auto
        iv_rpid  = 'zphieuketoan'
      ).

      gs_printqueue-companycode = k-%tky-companycode.
      gs_printqueue-accountingdocument = k-%tky-accountingdocument.
      gs_printqueue-fiscalyear = k-%tky-fiscalyear.

      TRY.
          gs_printqueue-itemid  = cl_system_uuid=>create_uuid_c32_static( ).
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.

      gs_printqueue-content = rv_pdf.

      APPEND gs_printqueue TO gt_printqueue.
      CLEAR: gs_printqueue.
    ENDIF.

    DATA: ls_xml TYPE zcl_gen_adobe=>ty_gs_xml.

    APPEND xml_auto TO ls_xml-data.

    DATA(lv_pdf) = o_gen_adobe->print_pdf( EXPORTING i_xml = ls_xml iv_rpid = 'zphieuketoan' ).

    result = VALUE #(
                    FOR key IN keys (
*                      %cid_ref = key-%cid_ref
                    %tky   = key-%tky
                    %param = VALUE #( filecontent   = lv_pdf
                                      filename      = lv_name
                                      fileextension = 'pdf'
*                                          mimeType      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                      mimetype      = 'application/pdf'
                                      )
                    )
                    ).

    DATA: ls_mapped LIKE LINE OF mapped-zjp_c_phieuketoan_2.
    ls_mapped-%tky         = k-%tky.
    INSERT CORRESPONDING #( ls_mapped ) INTO TABLE mapped-zjp_c_phieuketoan_2.
  ENDMETHOD.


  METHOD pkt_process_save.

    DATA(o_gen_adobe) = NEW zcl_gen_adobe( ).

    LOOP AT gt_printqueue INTO gs_printqueue.
      o_gen_adobe->print_queue(
        EXPORTING
          iv_qname            = 'PRINT_USER'
          iv_print_data       = gs_printqueue-content
          iv_name_of_main_doc = |PKT_{ gs_printqueue-accountingdocument }|
          iv_itemid           = gs_printqueue-itemid
        IMPORTING
          ev_err_msg          = DATA(lv_err_msg)
        RECEIVING
          rv_itemid           = DATA(lv_itemid)
      ).
    ENDLOOP.
  ENDMETHOD.


  METHOD process_data.

    zcl_jp_get_data_report_fi=>get_phieuketoan(
      EXPORTING
        ir_companycode        = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear         = ir_fiscalyear
        ir_accountant         = ir_accountant
        ir_createby           = ir_createby
      IMPORTING
        e_phieuketoan         = DATA(pkt_header)
        e_phieuketoan_items   = DATA(pkt_items)
    ).

    " header/footer context
    DATA ls_hdr TYPE ty_hdr_ctx.  "COMPANYCODENAME, ...
    DATA ls_ftr TYPE ty_ftr_ctx.  "TOTALAMOUNT, AMOUNTTEXT
    DATA ls_items LIKE LINE OF et_items.
    DATA: lv_sdate       TYPE string,
          lv_amounttext  TYPE string,
          lv_amounttotal TYPE zde_dmbtr.

*-----------------------HEADER XML----------------------------*
    READ           TABLE pkt_header INDEX 1 INTO DATA(ls_phieuketoan).

    lv_sdate = |Ngày { ls_phieuketoan-postingdate+6(2) } tháng { ls_phieuketoan-postingdate+4(2) } năm { ls_phieuketoan-postingdate+0(4) }|.

    DATA: i_document TYPE zst_document_info.

    MOVE-CORRESPONDING ls_phieuketoan TO i_document.

    zcl_jp_common_core=>get_companycode_details(
      EXPORTING
        i_companycode = i_document-companycode
      IMPORTING
        o_companycode = DATA(ls_companycode)
    ).

    e_hdr-companycodename = ls_companycode-companycodename.
    e_hdr-companycodeaddr = ls_companycode-companycodeaddr.

    e_hdr-accountingdocument = |Số: { ls_phieuketoan-accountingdocument }|.

    SELECT SINGLE accountingdocumentheadertext FROM i_journalentry
    WHERE companycode      = @ls_phieuketoan-companycode
    AND accountingdocument = @ls_phieuketoan-accountingdocument
    AND fiscalyear         = @ls_phieuketoan-fiscalyear
    INTO @e_hdr-documentheadertext.

    e_hdr-postingdate = lv_sdate.

    zcl_jp_common_core=>get_businesspartner_details(
      EXPORTING
        i_document  = i_document
      IMPORTING
        o_bpdetails = DATA(ls_bpdetails)
    ).

    DATA(lv_bpname) = ls_bpdetails-bpname.
    DATA(lv_bpaddr) = ls_bpdetails-bpaddress.

    e_hdr-bpname    = lv_bpname.
    e_hdr-bpaddress = lv_bpaddr.

*------------------------BODY XML-----------------------------------------*
    LOOP AT pkt_items INTO DATA(ls_phieuketoanitems).

      ls_items-documentitemtext = ls_phieuketoanitems-documentitemtext.

      IF ls_phieuketoanitems-debitcreditcode = 'H'.
        ls_items-tkco = ls_phieuketoanitems-glaccount.
      ELSE.
        ls_items-tkno = ls_phieuketoanitems-glaccount.
      ENDIF.

      IF ls_phieuketoanitems-debitamountincompanycode IS NOT INITIAL.
        ls_items-cocodeamount = ls_phieuketoanitems-debitamountincompanycode * 100.
      ELSE.
        ls_items-cocodeamount = ls_phieuketoanitems-creditamountincompanycode * 100.
      ENDIF.

      lv_amounttotal = lv_amounttotal + ls_phieuketoanitems-creditamountincompanycode * 100.

      APPEND ls_items TO et_items.
      CLEAR: ls_items.
    ENDLOOP.

*----------------------Footer XML----------------------------------*
    lv_amounttotal = abs( lv_amounttotal ).

    DATA(amount_in_words) = NEW zcore_cl_amount_in_words( ).

    lv_amounttext = amount_in_words->read_amount(
      EXPORTING
        i_amount = lv_amounttotal
        i_lang   = 'VI'
        i_waers  = 'VND'
    ).

    e_ftr-totalamount = lv_amounttotal.
    e_ftr-amounttext = |Viết bằng chữ: { lv_amounttext }|.

    READ TABLE ir_accountant INDEX 1 INTO DATA(ls_range).
    DATA(lv_accountant) = ls_range-low.

    READ TABLE ir_createby INDEX 1 INTO ls_range.
    DATA(lv_createby) = ls_range-low.

    APPEND VALUE #( accountant = lv_accountant createby = lv_createby ) TO et_sign.

  ENDMETHOD.


  METHOD constructor.
    CALL METHOD super->constructor.

    o_fi_export_pdf = COND #( WHEN o_fi_export_pdf IS BOUND
                             THEN o_fi_export_pdf
                             ELSE NEW zcl_jp_report_fi_export( ) ).

    o_gen_adobe = COND #( WHEN o_gen_adobe IS BOUND
                              THEN o_gen_adobe
                              ELSE NEW zcl_gen_adobe( ) ).
  ENDMETHOD.


  METHOD btnprintpdf_pkt_new.

    DATA: lt_pkt_item TYPE TABLE OF ty_pkt_items.

    DATA: lv_companycode        TYPE bukrs,
          lv_accountingdocument TYPE belnr_d,
          lv_fiscalyear         TYPE gjahr.

    DATA: lv_amounttext  TYPE string,
          lv_amounttotal TYPE zde_dmbtr,
          lv_sdate       TYPE string.

    DATA: lt_split TYPE TABLE OF string.

    READ TABLE keys INDEX 1 INTO DATA(k).

*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-companycode )        TO ir_companycode.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-accountingdocument ) TO ir_accountingdocument.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-fiscalyear )         TO ir_fiscalyear.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-accountant )         TO ir_accountant.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%tky-createby )           TO ir_createby.
    IF k-%param-accountant NE 'null'.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%param-accountant )         TO ir_accountant.
    ENDIF.

    IF k-%param-preparedby NE 'null'.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%param-preparedby )         TO ir_createby.
    ENDIF.

    FREE: lt_split.
    SPLIT k-%param-companycode AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO DATA(l_string).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_companycode.
    ENDLOOP.

    FREE: lt_split.
    SPLIT k-%param-accountingdocument AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO l_string.
      lv_accountingdocument = l_string.
      lv_accountingdocument = |{ lv_accountingdocument ALPHA = IN } |.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_accountingdocument )        TO ir_accountingdocument.
    ENDLOOP.

    FREE: lt_split.
    SPLIT k-%param-fiscalyear AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO l_string.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_fiscalyear.
    ENDLOOP.

    DATA: headerxml TYPE string,
          rowsxml   TYPE string,
          footerxml TYPE string.

    DATA: xml TYPE string.

    DATA: lv_tkno TYPE zde_char10,
          lv_tkco TYPE zde_char10.

    DATA: i_document TYPE zst_document_info.

    " dữ liệu
    DATA: lt_items TYPE STANDARD TABLE OF ty_pkt_items_ext,  "Table1
          ls_items TYPE ty_pkt_items_ext.
    DATA lt_sign  TYPE STANDARD TABLE OF ty_sign.            "Table2 (nếu dùng Role/Name)
    " map TABLE_ID -> ref
    DATA lt_refs TYPE zcl_ads_xml_builder=>tt_table_data_ref.

    " header/footer context
    DATA ls_hdr TYPE ty_hdr_ctx.  "COMPANYCODENAME, ...
    DATA ls_ftr TYPE ty_ftr_ctx.  "TOTALAMOUNT, AMOUNTTEXT

    CREATE OBJECT: o_fi_export_pdf, o_gen_adobe.
    DATA: ls_xml TYPE zcl_gen_adobe=>ty_gs_xml.

    SELECT companycode,
           accountingdocument,
           fiscalyear
    FROM i_journalentry
    WHERE companycode IN @ir_companycode
      AND fiscalyear IN @ir_fiscalyear
      AND accountingdocument IN @ir_accountingdocument
    INTO TABLE @DATA(lt_journalentry).

    SORT lt_journalentry BY companycode fiscalyear accountingdocument ASCENDING.

    LOOP AT lt_journalentry INTO DATA(ls_journalentry).
      FREE: ir_companycode, ir_accountingdocument, ir_fiscalyear.

      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_journalentry-companycode )        TO ir_companycode.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_journalentry-accountingdocument ) TO ir_accountingdocument.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_journalentry-fiscalyear )         TO ir_fiscalyear.

      o_fi_export_pdf->process_data(
        EXPORTING
          ir_companycode        = ir_companycode
          ir_accountingdocument = ir_accountingdocument
          ir_fiscalyear         = ir_fiscalyear
          ir_accountant         = ir_accountant
          ir_createby           = ir_createby
        IMPORTING
          et_items              = lt_items
          et_sign               = lt_sign
          e_hdr                 = ls_hdr
          e_ftr                 = ls_ftr
      ).

      APPEND VALUE #( table_id = 'TABLE1' dref = REF #( lt_items ) ) TO lt_refs.
      APPEND VALUE #( table_id = 'TABLE2' dref = REF #( lt_sign  ) ) TO lt_refs.

      DATA(xml_auto) = zcl_ads_xml_builder=>build_xml_by_form(
        i_form_id     = 'zphieuketoan'
        i_header_ctx  = ls_hdr
        i_footer_ctx  = ls_ftr
        it_table_data = lt_refs ).

      APPEND xml_auto TO ls_xml-data.

      CLEAR: xml_auto, ls_hdr, ls_ftr.
      FREE: lt_refs, lt_items, lt_sign.
    ENDLOOP.

    DATA: str_pdf TYPE string.

    DATA(lv_pdf) = o_gen_adobe->print_pdf( EXPORTING i_xml   = ls_xml
                                                     iv_rpid = 'zphieuketoan'
                                           IMPORTING str_pdf = str_pdf ).

    o_pdf = lv_pdf.

    DATA: lv_name TYPE string.

    lv_name = |PhieuKeToan_{ sy-datlo }|.

    result = VALUE #(
                    FOR key IN keys (
*                       %cid_ref = key-%cid_ref
*                       %tky   = key-%tky
                    %cid   = k-%cid
                    %param = VALUE #( filecontent   = str_pdf
                                      filename      = lv_name
                                      fileextension = 'pdf'
*                                              mimeType      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                      mimetype      = 'application/pdf'
                                      )
                    )
                    ).

    DATA: ls_mapped LIKE LINE OF mapped-zjp_c_phieuketoan_2.
*    ls_mapped-%tky         = k-%tky.

    INSERT CORRESPONDING #( ls_mapped ) INTO TABLE mapped-zjp_c_phieuketoan_2.

  ENDMETHOD.
ENDCLASS.

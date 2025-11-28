CLASS zcl_payment_voucher_ex_pdf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      keys_pkt     TYPE TABLE FOR ACTION IMPORT zc_payment_voucher~btnprintpdf,
      result_pkt   TYPE TABLE FOR ACTION RESULT zc_payment_voucher~btnprintpdf,
      mapped_pkt   TYPE RESPONSE FOR MAPPED EARLY zc_payment_voucher,
      failed_pkt   TYPE RESPONSE FOR FAILED EARLY zc_payment_voucher,
      reported_pkt TYPE RESPONSE FOR REPORTED EARLY zc_payment_voucher.

    CLASS-METHODS:
      btnPrintPDF_PKT IMPORTING keys     TYPE keys_pkt
*                                ir_compaycode TYPE tt_ranges
                      EXPORTING o_pdf    TYPE string
                      CHANGING  result   TYPE result_pkt
                                mapped   TYPE mapped_pkt
                                failed   TYPE failed_pkt
                                reported TYPE reported_pkt.


  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA:
      ir_companycode        TYPE zcl_payment_voucher=>tt_ranges,
      ir_accountingdocument TYPE zcl_payment_voucher=>tt_ranges,
      ir_fiscalyear         TYPE zcl_payment_voucher=>tt_ranges,
      ir_glaccount          TYPE zcl_payment_voucher=>tt_ranges,
      ir_documentitem       TYPE zcl_payment_voucher=>tt_ranges,
      ir_postingdate        TYPE zcl_payment_voucher=>tt_ranges,
      ir_documentdate       TYPE zcl_payment_voucher=>tt_ranges,
      ir_documenttype       TYPE zcl_payment_voucher=>tt_ranges,
      ir_customer           TYPE zcl_payment_voucher=>tt_ranges,
      ir_GeneralDirector    TYPE zcl_receipt_voucher=>tt_ranges,
      ir_ChiefAccountant    TYPE zcl_receipt_voucher=>tt_ranges,
      ir_Cashier            TYPE zcl_receipt_voucher=>tt_ranges,
      ir_Receiver           TYPE zcl_receipt_voucher=>tt_ranges,
      ir_Name           TYPE zcl_receipt_voucher=>tt_ranges,
      ir_PreparedBy         TYPE zcl_receipt_voucher=>tt_ranges,
      ir_supplier           TYPE zcl_receipt_voucher=>tt_ranges.

    TYPES: BEGIN OF ty_document_key,
             companycode        TYPE bukrs,
             AccountingDocument TYPE belnr_d,
             fiscalyear         TYPE mjahr,
             ChiefAccountant    TYPE string,
             Receiver           TYPE string,
             director           TYPE string,
             PreparedBy         TYPE string,
             cashier            TYPE string,
             name            TYPE string,
           END OF ty_document_key.

    TYPES: tt_doc_keys TYPE STANDARD TABLE OF ty_document_key WITH EMPTY KEY.

ENDCLASS.



CLASS ZCL_PAYMENT_VOUCHER_EX_PDF IMPLEMENTATION.


  METHOD btnprintpdf_pkt.

    "fix
    "hieudc7 fix
    DATA: lt_doc_keys    TYPE tt_doc_keys,
          ls_doc_key     TYPE ty_document_key,
          lt_split_ad    TYPE TABLE OF string,
          lt_split_fy    TYPE TABLE OF string,
          lt_split_cc    TYPE TABLE OF string,
          lv_account_doc TYPE string,
          lv_fy_str      TYPE string,
          lv_cc          TYPE string,
          lv_index       TYPE i.
    READ TABLE keys INDEX 1 INTO DATA(k).

    " Parse AccountingDocument (comma-separated)
    IF k-%param-AccountingDocument IS NOT INITIAL AND k-%param-AccountingDocument NE 'null'.
      SPLIT k-%param-AccountingDocument AT ',' INTO TABLE lt_split_ad.
    ELSE.
      RETURN.
    ENDIF.

    " Parse CompanyCode
    IF k-%param-CompanyCode IS NOT INITIAL AND k-%param-CompanyCode NE 'null'.
      SPLIT k-%param-CompanyCode AT ',' INTO TABLE lt_split_cc.
    ELSE.
      RETURN.
    ENDIF.

    " Parse FiscalYear (comma-separated)
    IF k-%param-fiscalyear IS NOT INITIAL AND k-%param-fiscalyear NE 'null'.
      SPLIT k-%param-fiscalyear AT ',' INTO TABLE lt_split_fy.
    ELSE.
      DATA(lv_default_fy) = sy-datum+0(4).
      DO lines( lt_split_ad ) TIMES.
        APPEND lv_default_fy TO lt_split_fy.
      ENDDO.
    ENDIF.

    " Nếu số dòng không khớp, nhân giá trị đầu tiên ra bằng số document
    IF lines( lt_split_cc ) <> lines( lt_split_ad ).
      IF lines( lt_split_cc ) = 1.
        READ TABLE lt_split_cc INDEX 1 INTO lv_cc.
        CLEAR lt_split_cc.
        DO lines( lt_split_ad ) TIMES.
          APPEND lv_cc TO lt_split_cc.
        ENDDO.
      ELSE.
        RETURN.
      ENDIF.
    ENDIF.

    " Validate counts match or use first FY for all
    IF lines( lt_split_ad ) <> lines( lt_split_fy ).
      IF lines( lt_split_fy ) = 1.
        READ TABLE lt_split_fy INDEX 1 INTO lv_fy_str.
        CLEAR lt_split_fy.
        DO lines( lt_split_ad ) TIMES.
          APPEND lv_fy_str TO lt_split_fy.
        ENDDO.
      ELSE.
        RETURN.
      ENDIF.
    ENDIF.

    " Get scalar parameters
    DATA(lv_ChiefAccountant) = COND string( WHEN k-%param-ChiefAccountant IS NOT INITIAL AND k-%param-ChiefAccountant NE 'null'
                                             THEN k-%param-ChiefAccountant ELSE '' ).
    DATA(lv_GeneralDirector)       = COND string( WHEN k-%param-GeneralDirector IS NOT INITIAL AND k-%param-GeneralDirector NE 'null'
                                             THEN k-%param-GeneralDirector ELSE '' ).
    DATA(lv_PreparedBy)         = COND string( WHEN k-%param-PreparedBy IS NOT INITIAL AND k-%param-PreparedBy NE 'null'
                                             THEN k-%param-PreparedBy ELSE '' ).
    DATA(lv_cashier)          = COND string( WHEN k-%param-cashier IS NOT INITIAL AND k-%param-cashier NE 'null'
                                             THEN k-%param-cashier ELSE '' ).
    DATA(lv_Receiver)          = COND string( WHEN k-%param-Receiver IS NOT INITIAL AND k-%param-Receiver NE 'null'
                                          THEN k-%param-Receiver ELSE '' ).
    DATA(lv_Name)          = COND string( WHEN k-%param-Name IS NOT INITIAL AND k-%param-Name NE 'null'
                                          THEN k-%param-Name ELSE '' ).

    " Build document keys list
    lv_index = 0.
    LOOP AT lt_split_ad INTO lv_account_doc.
      lv_index = lv_index + 1.

      CONDENSE lv_account_doc NO-GAPS.
      IF lv_account_doc IS INITIAL.
        CONTINUE.
      ENDIF.
      READ  TABLE lt_split_cc INDEX lv_index INTO lv_cc.
      READ TABLE lt_split_fy INDEX lv_index INTO lv_fy_str.
      CONDENSE lv_fy_str NO-GAPS.
      CONDENSE lv_cc NO-GAPS.

      CLEAR ls_doc_key.
      ls_doc_key-companycode = lv_cc.
      ls_doc_key-accountingdocument = lv_account_doc.
      ls_doc_key-fiscalyear       = lv_fy_str.
      ls_doc_key-chiefaccountant = lv_chiefaccountant.
      ls_doc_key-preparedby       = lv_preparedby.
      ls_doc_key-director         = lv_generaldirector.
      ls_doc_key-cashier          = lv_cashier.
      ls_doc_key-receiver = lv_receiver.
      ls_doc_key-name = lv_Name.
      APPEND ls_doc_key TO lt_doc_keys.
    ENDLOOP.

*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%key-companycode ) TO ir_companycode.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%key-accountingdocument ) TO ir_accountingdocument.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%key-fiscalyear ) TO ir_fiscalyear.
*APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%key-GeneralDirector ) TO ir_generaldirector.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%key-ChiefAccountant ) TO ir_chiefaccountant.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%key-PreparedBy ) TO ir_preparedby.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%key-Cashier ) TO ir_cashier.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%key-Receiver ) TO ir_receiver.

    LOOP AT lt_doc_keys INTO DATA(ls_key).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-companycode ) TO ir_companycode.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-accountingdocument ) TO ir_accountingdocument.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-fiscalyear )         TO ir_fiscalyear.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-chiefaccountant )    TO ir_chiefaccountant.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-director )           TO ir_generaldirector.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-preparedby )         TO ir_preparedby.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-cashier )            TO ir_cashier.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-receiver )           TO ir_receiver.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-name )           TO ir_Name.

    ENDLOOP.


    "2. get data from class
    zcl_payment_voucher=>get_phieu_chi_1(
      EXPORTING
        ir_compaycode         = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear         = ir_fiscalyear
        ir_glaccount          = ir_glaccount
        ir_postingdate        = ir_postingdate
        ir_generaldirector  = ir_generaldirector
        ir_chiefaccountant = ir_chiefaccountant
        ir_cashier =   ir_cashier
        ir_receiver = ir_receiver
        ir_preparedby = ir_preparedby
        ir_name = ir_Name
      IMPORTING
        e_phieu_chi           = DATA(lt_phieuketoan)
        e_return              = DATA(lt_return)
    ).

    DATA: lv_companycode TYPE bukrs.

    lv_companycode = k-%param-CompanyCode.

    zcl_jp_common_core=>get_companycode_details(
      EXPORTING
        i_companycode = lv_companycode
      IMPORTING
        o_companycode = DATA(ls_companycode)
    ).


    "ExportPDF
    DATA: headerxml TYPE string,
          rowsxml   TYPE string,
          bannerxml TYPE string,
          middlexml TYPE string,
          footerxml TYPE string.

    DATA: xml TYPE string.
    DATA: ls_request TYPE zcl_gen_adobe=>ts_request.
    DATA(o_gen_adobe) = NEW zcl_gen_adobe( ).

    LOOP AT lt_phieuketoan INTO DATA(ls_data).
      " gán ngày tháng
*      <DATA(lv_dd) = ls_data-CreationDate+6(2).
*      DATA(lv_mm) = ls_data-CreationDate+4(2).
*      DATA(>lv_yyyy) = ls_data-CreationDate(4).
      DATA:lv_amountText TYPE string.

*      DATA(lv_date_str) = |Ngày { lv_dd } tháng { lv_mm } năm { lv_yyyy }|.


       DATA(lv_dd_1) = ls_data-PostingDate+6(2).
      DATA(lv_mm_1) = ls_data-PostingDate+4(2).
      DATA(lv_yyyy_1) = ls_data-PostingDate(4).

      DATA(lv_date_str_1) = |Ngày { lv_dd_1 } tháng { lv_mm_1 } năm { lv_yyyy_1 }|.


      "format số tiền
      DATA(lv_amount) = ls_data-sotien * 100.
      DATA:lv_text  TYPE string.
      lv_text = |{ lv_amount }|.
      REPLACE ALL OCCURRENCES OF REGEX '(\d)(?=(\d{3})+(?!\d))'
             IN lv_text WITH '$1.'.

      " đọc tiền bằng chữ
      DATA:lv_amount_for_read TYPE zde_dmbtr.
      lv_amount_for_read = ls_data-sotien * 100.
      ls_data-sotien = abs( ls_data-sotien ).
      DATA(lo_amount_in_words) = NEW zcore_cl_amount_in_words( ).
      lv_amounttext = lo_amount_in_words->read_amount(
        EXPORTING
          i_amount = lv_amount_for_read
          i_lang   = 'VI'
          i_waers  = 'VND'
      ).

      "loại bỏ khoảng trắng
      DATA(lv_doituong) = ls_data-doituong.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_doituong WITH ' '.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN lv_doituong WITH ' '.
      CONDENSE lv_doituong.
      ls_data-doituong = lv_doituong.

      headerxml =
         |<HeaderSection>| &&
             |<CompanyName>{ ls_companycode-companycodename }</CompanyName>| &&
             |<CompanyAddress>{ ls_companycode-companycodeaddr }</CompanyAddress>| &&
             |<Title>PHIẾU CHI</Title>| &&
             |<PostingDate> { lv_date_str_1 }</PostingDate>| &
         |</HeaderSection>|.

      middlexml =
                   |<MiddleSection>| &&
                     |<SoPhieu>{ ls_data-accountingdocument }</SoPhieu>| &&
                     |<AccS>{ ls_data-acc_s }</AccS>| &&
                     |<AccH>{ ls_data-acc_h }</AccH>| &&
                 |</MiddleSection>|.

      rowsXML =
      |<ContentSection>| &&
             |<Doituong>  { ls_data-Doituong }</Doituong>| &&
             |<DiaChi>  { ls_data-DiaChi }</DiaChi>| &&
             |<Diengiai>  { ls_data-Diengiai }</Diengiai>| &&
             |<sotien>{ lv_text } VND</sotien>| &&
             |<sotienchu>  { lv_amounttext }</sotienchu>| &&
             |<Kemtheo>Chứng từ gốc </Kemtheo>| &&
             |<Nhandu>  { lv_amounttext }</Nhandu>| &&
             |<Date>  { lv_date_str_1 }</Date>| &&

         |</ContentSection>|.





      bannerxml = bannerxml &&
        |<Row2>| &&
            |<ChanKy1>{  ls_data-generaldirector }</ChanKy1>| &&
             |<ChanKy2>{ ls_data-ChiefAccountant } </ChanKy2>| &&
              |<ChanKy3> { ls_data-PreparedBy }</ChanKy3>| &&
               |<ChanKy4> { ls_data-Receiver }</ChanKy4>| &&
                |<ChanKy5>{ ls_data-Cashier } </ChanKy5>| &&
        |</Row2>|.



      xml = |<?xml version="1.0" encoding="UTF-8"?>| &&
                 |<form1>| &&
                 |<main>| &&
                 |{  headerxml }| &&
                 |{  middlexml }| &&
                 |{ rowsXML }| &&
                  |<FooterSection>| &&
                 |<Table1>| &&
                    |{ bannerxml }| &&
                |</Table1>| &&
                 |</FooterSection>| &&
                 |</main>| &&

                 |<main_2>| &&
                 |{  headerxml }| &&
                 |{  middlexml }| &&
                 |{ rowsXML }| &&
                  |<FooterSection>| &&
                 |<Table1>| &&
                    |{ bannerxml }| &&
                |</Table1>| &&
                 |</FooterSection>| &&
                 |</main_2>| &&
                 |</form1>|.
      APPEND xml TO ls_request-data.

      CLEAR: xml, headerxml ,middlexml,rowsXML, bannerxml.

    ENDLOOP.


    DATA: str_pdf TYPE string.
*    DATA(o_gen_adobe) = NEW zcl_gen_adobe( ).
    ls_request-id = 'zphieuchi'.
    DATA(lv_pdf) = o_gen_adobe->call_data( EXPORTING i_request = ls_request
    IMPORTING o_pdf_string = str_pdf ).

    o_pdf = lv_pdf.
    DATA: lv_filename TYPE string.

    lv_filename = |PhieuChi_{ ls_data-CompanyCode }{ ls_data-FiscalYear }{ ls_data-AccountingDocument }|.

    result = VALUE #( FOR key IN keys (
        %cid   = key-%cid
        %param = VALUE #(
          filecontent   = str_pdf
          filename      = lv_filename
          fileextension = 'pdf'
          mimetype      = 'application/pdf'
        )
      ) ).


    DATA: ls_mapped LIKE LINE OF mapped-zc_payment_voucher.
*    ls_mapped-%tky         = k-%tky.
    INSERT CORRESPONDING #( ls_mapped ) INTO TABLE mapped-zc_payment_voucher.

*    DATA: ls_request TYPE zcl_gen_adobe=>ts_request.
*
*    ls_request-id = 'zphieuchi'.
*    APPEND xml TO ls_request-data.
*
*    DATA(o_gen_adobe) = NEW zcl_gen_adobe( ).
*
*    DATA(lv_pdf) = o_gen_adobe->call_data( EXPORTING i_request = ls_request ).
*
*    o_pdf = lv_pdf.
*
*    DATA: lv_name TYPE string.
*
*    lv_name = |PhieuChi_{ ls_data-CompanyCode }{ ls_data-FiscalYear }{ ls_data-AccountingDocument }|.
*
*
*    result = VALUE #( FOR key IN keys (
**                      %cid_ref = key-%cid_ref
*                      %tky     = key-%tky
*                      %param   = VALUE #( filecontent   = lv_pdf
*                                          filename      = lv_name
*                                          fileextension = 'pdf'
**                                          mimeType      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
*                                          mimetype      = 'application/pdf'
*                                         )
*                      ) ).
*    DATA: ls_mapped LIKE LINE OF mapped-zc_payment_voucher.
*    ls_mapped-%tky = k-%tky.
*    INSERT CORRESPONDING #( ls_mapped ) INTO TABLE mapped-zc_payment_voucher.
  ENDMETHOD.
ENDCLASS.

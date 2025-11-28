CLASS zcl_einvoice_data DEFINITION
  PUBLIC
  INHERITING FROM cx_rap_query_provider
*  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "Custom Entities
    INTERFACES if_rap_query_provider.

    "Read Entities

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_ranges          TYPE TABLE OF ty_range_option,

           tt_returns         TYPE TABLE OF bapiret2,

           wa_document        TYPE zjp_c_hddt_h,

           tt_hddt_h          TYPE TABLE OF zjp_a_hddt_h,

           tt_einvoice_header TYPE TABLE OF zjp_c_hddt_h,
           tt_einvoice_item   TYPE TABLE OF zjp_c_hddt_i.

    CLASS-DATA: gr_companycode         TYPE tt_ranges,
                gr_accountingdocument  TYPE tt_ranges,
                gr_fiscalyear          TYPE tt_ranges,
                gr_period              TYPE tt_ranges,
                gr_postingdate         TYPE tt_ranges,
                gr_documentdate        TYPE tt_ranges,
                gr_customer            TYPE tt_ranges,

                gr_datetype            TYPE tt_ranges,
                gr_einvoicetype        TYPE tt_ranges,
                gr_statussap           TYPE tt_ranges,
                gr_createdbyuser       TYPE tt_ranges,
                gr_enduser             TYPE tt_ranges,

                gr_usertype            TYPE tt_ranges,

                gr_documenttype        TYPE tt_ranges,
                gr_documentsource      TYPE tt_ranges,
                gr_fiscalyearsource    TYPE tt_ranges,
                gr_fiscalperiod        TYPE tt_ranges,
                gr_transactioncurrency TYPE tt_ranges,

                gr_billingtype         TYPE tt_ranges,

                mo_instance            TYPE REF TO zcl_einvoice_data,

                go_jp_common_core      TYPE REF TO zcl_jp_common_core,

                gt_einvoice_headers    TYPE tt_einvoice_header,
                gt_einvoice_items      TYPE tt_einvoice_item,

                go_einvoice_data       TYPE REF TO zcl_einvoice_data.
    .

    CLASS-METHODS:
      "Contructor.
      get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_einvoice_data,

      "get data einvoice.
      get_einvoice_data IMPORTING ir_companycode         TYPE tt_ranges
                                  ir_accountingdocument  TYPE tt_ranges OPTIONAL
                                  ir_billingdocument     TYPE tt_ranges OPTIONAL
                                  ir_fiscalyear          TYPE tt_ranges
                                  ir_period              TYPE tt_ranges OPTIONAL
                                  ir_postingdate         TYPE tt_ranges OPTIONAL
                                  ir_documentdate        TYPE tt_ranges OPTIONAL

                                  ir_customer            TYPE tt_ranges OPTIONAL

                                  ir_einvoicetype        TYPE tt_ranges
                                  ir_statussap           TYPE tt_ranges OPTIONAL
                                  ir_einvoicenumber      TYPE tt_ranges OPTIONAL

                                  ir_createdbyuser       TYPE tt_ranges OPTIONAL "Created einvoice from SAP
                                  ir_enduser             TYPE tt_ranges OPTIONAL "Created document in SAP
                                  ir_usertype            TYPE tt_ranges
                                  ir_typeofdate          TYPE tt_ranges
                                  ir_currencytype        TYPE tt_ranges

                                  ir_documenttype        TYPE tt_ranges OPTIONAL
                                  ir_documentsource      TYPE tt_ranges OPTIONAL
                                  ir_fiscalyearsource    TYPE tt_ranges OPTIONAL
                                  ir_fiscalperiod        TYPE tt_ranges OPTIONAL
                                  ir_transactioncurrency TYPE tt_ranges OPTIONAL

                                  ir_billingtype         TYPE tt_ranges OPTIONAL

                                  ir_testrun             TYPE tt_ranges OPTIONAL

                        EXPORTING it_einvoice_header     TYPE tt_einvoice_header
                                  it_einvoice_item       TYPE tt_einvoice_item
                                  it_returns             TYPE tt_returns
                        RAISING
                                  cx_abap_context_info_error
                        ,

      getdate_einvoice IMPORTING i_document TYPE wa_document
                       EXPORTING e_document TYPE wa_document
                                 o_date     TYPE zde_einv_date
                                 o_time     TYPE zde_einv_time
                       RAISING
                                 cx_abap_context_info_error,

      "get_logging
      get_logging_invoice IMPORTING i_input           TYPE any
                                    i_belnrsrc        TYPE belnr_d OPTIONAL
                                    i_gjahrsrc        TYPE gjahr OPTIONAL
                                    it_a_hddt_h       TYPE tt_hddt_h
                                    iv_testrun        TYPE string
                          CHANGING  e_einvoice_header TYPE wa_document,

      "get_header_invoice
      get_header_invoice IMPORTING i_input           TYPE any
                                   iv_testrun        TYPE string
                                   iv_usertype       TYPE string
                                   iv_currencytype   TYPE string
                                   iv_typeofdate     TYPE string
                                   ir_companycode    TYPE tt_ranges
                                   iv_einvoicetype   TYPE string
                         CHANGING  e_einvoice_header TYPE wa_document,

      "get_billing_text
      get_billing_text IMPORTING i_billing      TYPE i_billingdocument-billingdocument
                                 id_text        TYPE char10
                       RETURNING VALUE(rv_text) TYPE string,

      "Read ranges index 1.
      read_ranges IMPORTING it_ranges TYPE tt_ranges
                  EXPORTING o_value   TYPE string
                  .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EINVOICE_DATA IMPLEMENTATION.


  METHOD getdate_einvoice.
    MOVE-CORRESPONDING i_document TO e_document.

    CASE e_document-typeofdate.
      WHEN '01'. "Posting Date
        e_document-einvoicedatecreate = e_document-postingdate.
        e_document-einvoicetimecreate = '090000'.
      WHEN '02'. "Document Date
        e_document-einvoicedatecreate = e_document-documentdate.
        e_document-einvoicetimecreate = '090000'.
      WHEN '03'. "Entry Date
        e_document-einvoicedatecreate = e_document-accountingdocumentcreationdate.
        e_document-einvoicetimecreate = '090000'.
      WHEN '04'. "System Date
        DATA(time_zone) = cl_abap_context_info=>get_user_time_zone(  ).

        DATA(lv_datlo) = xco_cp=>sy->date( )->as( xco_cp_time=>format->abap )->value.
        DATA(lv_timlo) = xco_cp=>sy->time( )->as( xco_cp_time=>format->abap )->value.

        e_document-einvoicedatecreate = lv_datlo.
        e_document-einvoicetimecreate = lv_timlo.
    ENDCASE.

    o_date = e_document-einvoicedatecreate.
    o_time = e_document-einvoicetimecreate.

  ENDMETHOD.


  METHOD get_einvoice_data.
    DATA:
      wa_document         TYPE zst_document_info,
      wa_customer_details TYPE zst_businesspartner_info.

    DATA: lr_glaccount TYPE tt_ranges.

    DATA: lt_einvoice_header TYPE tt_einvoice_header,
          ls_einvoice_header LIKE LINE OF lt_einvoice_header,
          lt_einvoice_item   TYPE tt_einvoice_item,
          ls_einvoice_item   LIKE LINE OF lt_einvoice_item.

    DATA: ls_returns TYPE bapiret2.

    DATA: lv_index TYPE int4 VALUE IS INITIAL,
          lv_count TYPE int4 VALUE IS INITIAL.

    DATA: lv_usertype     TYPE string,
          lv_currencytype TYPE string,
          lv_typeofdate   TYPE string,
          lv_einvoicetype TYPE string,
          lv_testrun      TYPE string.

    DATA: lv_fiscalyear TYPE gjahr VALUE IS INITIAL,
          lv_taxcode    TYPE zde_taxcode VALUE IS INITIAL.

    DATA: lo_einvoice_data TYPE REF TO zcl_einvoice_data.

    CREATE OBJECT lo_einvoice_data.

**--Create Common
    CREATE OBJECT go_jp_common_core.

**--Lấy cấu hình GLACCT
    SELECT * FROM zjp_hd_glacc
    WHERE companycode IN @ir_companycode
    INTO TABLE @DATA(lt_hd_glacc).
    IF sy-subrc NE 0.
      "Message Error!
      ls_returns-type = 'E'.
      ls_returns-message = TEXT-001.
*      APPEND ls_returns TO it_returns.
      CLEAR: ls_returns.
    ENDIF.

    "1 - TK hạch toán "2 - TK thuế
    LOOP AT lt_hd_glacc INTO DATA(ls_hd_glacc) WHERE glacctype EQ '1'.
      APPEND VALUE #( sign = 'I' option = 'CP' low = ls_hd_glacc-glaccount ) TO lr_glaccount.
    ENDLOOP.

**--Lấy cấu hình
    lo_einvoice_data->read_ranges(
      EXPORTING
        it_ranges = ir_currencytype[]
      IMPORTING
        o_value   = lv_currencytype ).

    lo_einvoice_data->read_ranges(
      EXPORTING
        it_ranges = ir_typeofdate[]
      IMPORTING
        o_value   = lv_typeofdate ).

    lo_einvoice_data->read_ranges(
      EXPORTING
        it_ranges = ir_usertype[]
      IMPORTING
        o_value   = lv_usertype ).

    lo_einvoice_data->read_ranges(
      EXPORTING
        it_ranges = ir_einvoicetype[]
      IMPORTING
        o_value   = lv_einvoicetype ).

    lo_einvoice_data->read_ranges(
      EXPORTING
        it_ranges = ir_testrun[]
      IMPORTING
        o_value   = lv_testrun ).

    DATA: lr_einvoicetype TYPE tt_ranges.
    IF lv_einvoicetype IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_einvoicetype ) TO lr_einvoicetype.
    ENDIF.

*    IF NOT ( ir_billingdocument IS NOT INITIAL AND ir_accountingdocument IS INITIAL ).
**--Lấy Data BKPF
    SELECT
             a~companycode ,
             a~accountingdocument,
             a~fiscalyear,
             a~billingdocument,
*             a~accountingdocumentitem,
             b~fiscalperiod,
             a~postingdate,
             a~documentdate,
             b~accountingdocumentcreationdate,
             a~financialaccounttype,
             a~accountingdocumenttype,
*             a~postingkey,
*             a~debitcreditcode,
*             a~glaccount,
             a~customer,
*             a~taxcode,
*             a~product,
             a~companycodecurrency,
             a~transactioncurrency,
             c~einvoicenumber,
             c~einvoiceserial,
             c~einvoiceform,
             b~absoluteexchangerate,
             b~accountingdocumentheadertext,
             b~reversedocument,
             b~reversedocumentfiscalyear,
             b~isreversal,
             b~isreversed
      FROM i_journalentry WITH PRIVILEGED ACCESS AS b

      INNER JOIN i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
          ON  b~companycode        = a~companycode
          AND b~accountingdocument = a~accountingdocument
          AND b~fiscalyear         = a~fiscalyear

      LEFT OUTER JOIN zjp_a_hddt_h AS c
          ON  b~companycode        = c~companycode
          AND b~accountingdocument = c~accountingdocument
          AND b~fiscalyear         = c~fiscalyear

      WHERE a~companycode         IN @ir_companycode
        AND a~accountingdocument  IN @ir_accountingdocument
        AND a~fiscalyear          IN @ir_fiscalyear
        AND a~fiscalperiod        IN @ir_period
        AND a~postingdate         IN @ir_postingdate
        AND a~documentdate        IN @ir_documentdate
        AND a~customer            IN @ir_customer
        AND b~fiscalperiod        IN @ir_fiscalperiod
        AND b~transactioncurrency IN @ir_transactioncurrency
        AND a~accountingdocumenttype IN @ir_documenttype
*        AND a~GLAccount           IN @lr_glaccount
*        AND a~BillingDocument     IN @ir_billingdocument
        AND b~accountingdoccreatedbyuser IN @ir_enduser

        AND a~financialaccounttype EQ 'D'
  "Trường hợp chứng từ huỷ chưa phát hành hoá đơn ko lấy lên
        AND b~isreversal     NE 'X' "--> "Loại chứng từ huỷ
        AND ( ( b~isreversed NE 'X' ) "--> "Loại bỏ chứng từ gốc đã huỷ
  "Trường hợp huỷ chứng từ sau khi đã phát hành hoá đơn vẫn lấy lên
        OR ( b~isreversed EQ 'X' AND c~einvoicenumber NE '' ) )

        AND (
              ( ( a~taxcode LIKE 'O%' OR   a~taxcode = '**' )
                 AND b~accountingdocumenttype NE 'DK'
               )
           OR ( b~accountingdocumenttype EQ 'DK' ) "Case tự điền billing vào refkey 1 của document item
         )

      INTO TABLE @DATA(lt_bkpf)

      .

*    ENDIF.

    SORT lt_bkpf BY companycode accountingdocument fiscalyear ASCENDING billingdocument DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_bkpf COMPARING companycode accountingdocument fiscalyear.

    "Log data E-Invoice Header
    SELECT * FROM zjp_a_hddt_h
    WHERE companycode           IN @ir_companycode
      AND fiscalyear            IN @ir_fiscalyear
      AND accountingdocument    IN @ir_accountingdocument
      AND customer              IN @ir_customer
      AND einvoicenumber        IN @ir_einvoicenumber
      AND statussap             IN @ir_statussap
      AND postingdate           IN @ir_postingdate
      AND documentdate          IN @ir_documentdate
      AND createdbyuser         IN @ir_createdbyuser
      ORDER BY companycode, accountingdocument, fiscalyear
    INTO TABLE @DATA(lt_a_hddt_h).

    IF lt_a_hddt_h IS NOT INITIAL.
      "Log data E-Invoice Item
      SELECT * FROM zjp_a_hddt_i
      FOR ALL ENTRIES IN @lt_a_hddt_h
      WHERE companycode         = @lt_a_hddt_h-companycode
        AND accountingdocument  = @lt_a_hddt_h-accountingdocument
        AND fiscalyear          = @lt_a_hddt_h-fiscalyear
      INTO TABLE @DATA(lt_a_hddt_i).
    ENDIF.

    SORT lt_bkpf BY companycode accountingdocument billingdocument fiscalyear ASCENDING.

    CHECK lt_bkpf IS NOT INITIAL.

**---Lấy Data BSEG
    SELECT a~companycode ,
           a~accountingdocument,
           a~fiscalyear,
           a~billingdocument,
           a~accountingdocumentitem,
           a~postingdate,
           a~documentdate,
           a~financialaccounttype,
           a~accountingdocumenttype,
           a~postingkey,
           a~debitcreditcode,
           a~glaccount,
           a~customer,
           a~supplier,
           a~taxcode,
           a~product,
           a~documentitemtext,
           a~baseunit,
           a~quantity,
           a~amountintransactioncurrency, "
           a~amountincompanycodecurrency, "Local
           a~companycodecurrency,
           a~transactioncurrency,
           a~paymentmethod,
           a~profitcenter,
           a~reference1idbybusinesspartner,
           a~isnegativeposting
*           a~YY1_Text2_COB
*           a~yy1_longtext_cob as LongText
    FROM i_operationalacctgdocitem AS a
    FOR ALL ENTRIES IN @lt_bkpf
    WHERE a~companycode = @lt_bkpf-companycode
      AND a~accountingdocument = @lt_bkpf-accountingdocument
      AND a~accountingdocumenttype IN @ir_documenttype
      AND a~fiscalyear = @lt_bkpf-fiscalyear
      AND ( ( a~glaccount IN @lr_glaccount
              AND a~financialaccounttype EQ 'S'
              AND a~accountingdocumenttype NE 'DK'
              AND a~taxcode IS NOT INITIAL
            )
            OR ( a~accountingdocumenttype EQ 'DK' )
        )
    INTO TABLE @DATA(lt_bseg).
**-----------------------------------------------------------------------**

    SELECT
        companycode,
        fiscalyear,
        accountingdocument,
        ledger,
        glaccount,
        debitcreditcode,
        accountingdocumenttype,
        accountingdocumentitem,
        yy1_text2_cob
     FROM i_glaccountlineitem
     FOR ALL ENTRIES IN @lt_bkpf
     WHERE companycode = @lt_bkpf-companycode
     AND accountingdocument = @lt_bkpf-accountingdocument
     AND fiscalyear = @lt_bkpf-fiscalyear
     AND ledger = '0L'
     AND yy1_text2_cob NE ''
     INTO TABLE @DATA(lt_bseg_text).

    SORT lt_bseg_text BY companycode accountingdocument fiscalyear accountingdocumentitem ASCENDING.

    SORT lt_bseg BY companycode accountingdocument billingdocument accountingdocumentitem fiscalyear ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING companycode accountingdocument billingdocument accountingdocumentitem fiscalyear.

    DATA: lv_billingdocument TYPE zde_char10,
          lv_refkey1         TYPE zde_char14.

    LOOP AT lt_bseg INTO DATA(ls_bseg) WHERE accountingdocumenttype = 'DK'
        AND financialaccounttype = 'K' AND supplier CP '00000067*' AND reference1idbybusinesspartner NE ''.
      CLEAR: lv_count.
      READ TABLE lt_bkpf ASSIGNING FIELD-SYMBOL(<lfs_bkpf>) WITH KEY companycode = ls_bseg-companycode
          accountingdocument = ls_bseg-accountingdocument
          fiscalyear = ls_bseg-fiscalyear BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_index = sy-tabix.

*        lv_refkey1 = |{ ls_bseg-Reference1IDByBusinessPartner ALPHA = IN }|.
*        lv_billingdocument = lv_refkey1+0(10).

        lv_billingdocument = |{ ls_bseg-reference1idbybusinesspartner ALPHA = IN }|.

        SELECT COUNT(*) FROM i_billingdocument
        WHERE billingdocument = @lv_billingdocument
        INTO @lv_count.
        IF lv_count NE 0.
          <lfs_bkpf>-billingdocument = lv_billingdocument.
        ENDIF.

        IF <lfs_bkpf>-einvoicenumber = ''.
          CLEAR: lv_count.
          SELECT COUNT(*) FROM i_billingdocument
          WHERE billingdocument = @lv_billingdocument
            AND billingdocumentiscancelled = 'X'
          INTO @lv_count.
          IF lv_count NE 0.
            DELETE lt_bkpf INDEX lv_index.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF ir_billingdocument IS NOT INITIAL.
      DELETE lt_bkpf WHERE billingdocument NOT IN ir_billingdocument.
    ENDIF.

**--Lấy data VAT
    TYPES: BEGIN OF lty_sumvat,
             companycode               TYPE bukrs,
             accountingdocument        TYPE belnr_d,
             fiscalyear                TYPE gjahr,
             taxcode                   TYPE zde_taxcode,
             debitcreditcode           TYPE shkzg,
             transactioncurrency       TYPE waers,
             companycodecurrency       TYPE waers,
             sumvatamountintransaction TYPE zde_dmbtr,
             sumvatamountincompanyco   TYPE zde_dmbtr,
           END OF lty_sumvat.

    DATA: lt_sumvat   TYPE TABLE OF lty_sumvat,
          lt_sumvat_t TYPE TABLE OF lty_sumvat.

    DATA: lv_paymentmethod TYPE zde_paymentmethod VALUE IS INITIAL.

    FREE: lr_glaccount.
    "1 - TK hạch toán "2 - TK thuế
    LOOP AT lt_hd_glacc INTO ls_hd_glacc WHERE glacctype = '2'.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_hd_glacc-glaccount ) TO lr_glaccount.
    ENDLOOP.

    SELECT companycode,
           accountingdocument,
           fiscalyear,
           taxcode,
           debitcreditcode,
           transactioncurrency,
           companycodecurrency,
           amountintransactioncurrency  AS sumvatamountintransaction, "
           amountincompanycodecurrency  AS sumvatamountincompanyco "Local
      FROM i_operationalacctgdocitem
      WHERE companycode         IN @ir_companycode
        AND accountingdocument  IN @ir_accountingdocument
        AND fiscalyear          IN @ir_fiscalyear
        AND glaccount           IN @lr_glaccount
        AND ( taxcode LIKE 'O%' OR taxcode = '**' )
        INTO CORRESPONDING FIELDS OF TABLE @lt_sumvat
        .
**-----------------------------------------------------------------------**

**SORT Table
    SORT lt_a_hddt_h BY companycode accountingdocument billingdocument fiscalyear ASCENDING.
    SORT lt_bseg BY companycode accountingdocument fiscalyear accountingdocumentitem ASCENDING.

    DATA: ls_a_hddt_h LIKE LINE OF lt_a_hddt_h.
    DATA: lv_customer TYPE kunnr.

**--------------------------PROCESS FI DOCUMENT NOT BILLING DOCUMENT------------------------***
    LOOP AT lt_bkpf INTO DATA(ls_bkpf) WHERE billingdocument IS INITIAL.
      lv_index = sy-tabix.
      CLEAR: lv_count, lv_taxcode.
      CLEAR: ls_einvoice_header.
      CLEAR: ls_a_hddt_h.
      CLEAR: lv_paymentmethod.
      CLEAR: lv_customer.

*  DATA: lv_fwste  TYPE zde_dmbtr.

**---Trường hợp Document Chưa Phát hành thành công -> Lấy data từ bkpf, bseg

      lo_einvoice_data->get_header_invoice(
        EXPORTING
          i_input           = ls_bkpf
          iv_testrun        = lv_testrun
          iv_usertype       = lv_usertype
          iv_currencytype   = lv_currencytype
          iv_typeofdate     = lv_typeofdate
          ir_companycode    = ir_companycode
          iv_einvoicetype   = lv_einvoicetype
        CHANGING
          e_einvoice_header = ls_einvoice_header
      ).

      READ TABLE lt_bseg TRANSPORTING NO FIELDS
      WITH KEY companycode        = ls_bkpf-companycode
               accountingdocument = ls_bkpf-accountingdocument
               fiscalyear         = ls_bkpf-fiscalyear BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_index = sy-tabix.

        LOOP AT lt_bseg INTO ls_bseg FROM lv_index.
          IF NOT ( ls_bseg-companycode        EQ ls_bkpf-companycode AND
                   ls_bseg-accountingdocument EQ ls_bkpf-accountingdocument AND
                   ls_bseg-fiscalyear         EQ ls_bkpf-fiscalyear ).
            EXIT.
          ENDIF.

*          CALL FUNCTION 'RECP_FI_TAX_CALCULATE'
*            EXPORTING
*              ic_bukrs    = ls_bseg-CompanyCode
*              ic_mwskz    = ls_bseg-TaxCode
*              ic_waers    = ls_bseg-CompanyCodeCurrency
*            IMPORTING
*              ep_tax_rate = lv_fwste.
          lv_count = lv_count + 1.

* -- Tự lấy Accounting Document Source và Fiscal Year Source
          IF ls_bkpf-accountingdocumenttype NE 'DK'.
            SELECT SINGLE
              invoicereference,
              invoicereferencefiscalyear
            FROM i_operationalacctgdocitem
            WHERE companycode        = @ls_bkpf-companycode
              AND accountingdocument = @ls_bkpf-accountingdocument
              AND fiscalyear         = @ls_bkpf-fiscalyear
              AND invoicereference NE ''
              AND invoicereferencefiscalyear NE ''
            INTO @DATA(ls_infosource).
            IF sy-subrc EQ 0.
              ls_einvoice_header-accountingdocumentsource = ls_infosource-invoicereference.
              ls_einvoice_header-fiscalyearsource         = ls_infosource-invoicereferencefiscalyear.
            ELSE.
              CLEAR: ls_infosource.
            ENDIF.
          ENDIF.
*------------------    -------    -----------    -----------------------*
          ls_einvoice_item-companycode        = ls_bkpf-companycode.
          ls_einvoice_item-accountingdocument = ls_bkpf-accountingdocument.
          ls_einvoice_item-fiscalyear         = ls_bkpf-fiscalyear.

          ls_einvoice_item-accountingdocumentitem = ls_bseg-accountingdocumentitem.
          ls_einvoice_item-itemeinvoice           = lv_count.
          IF ls_bseg-customer IS NOT INITIAL.
            lv_customer = ls_bseg-customer.
          ENDIF.
          "Mã Hàng hóa
          ls_einvoice_item-product                = ls_bseg-product.
          "Tên hàng hóa
*          ls_einvoice_item-longtext               = ls_bseg-longtext.
          ls_einvoice_item-documentitemtext       = ls_bseg-documentitemtext.

          "Đơn vị
          ls_einvoice_item-baseunit = ls_bseg-baseunit.
          "Số lượng
          ls_einvoice_item-quantity = ls_bseg-quantity.
          "Text Đơn vị
          SELECT SINGLE unitofmeasurelongname FROM i_unitofmeasuretext
          WHERE unitofmeasure = @ls_bseg-baseunit
            AND language = 'E'
          INTO @ls_einvoice_item-unitofmeasurelongname.

          "Tax Percentage
          DATA: lv_currency TYPE zjp_hd_taxcode-currency.

          CASE lv_currencytype.
            WHEN '1'. "Transaction currency
              lv_currency = ls_bkpf-transactioncurrency.
            WHEN '2'. "Companycode currency
              lv_currency = ls_bkpf-companycodecurrency.
            WHEN OTHERS.
          ENDCASE.

          SELECT SINGLE taxpercentage FROM zjp_hd_taxcode
          WHERE companycode  = @ls_bkpf-companycode
*            AND currency     = @lv_currency
            AND taxcode      = @ls_bseg-taxcode
          INTO @ls_einvoice_item-taxpercentage.
          IF sy-subrc NE 0.
            "Message Error!
            ls_returns-type = 'E'.
            ls_returns-message = TEXT-003.
*            APPEND ls_returns TO it_returns.
            CLEAR: ls_returns.
          ENDIF.

          "Số tiền
          ls_bseg-amountintransactioncurrency = ls_bseg-amountintransactioncurrency * ( -1 ).
          ls_bseg-amountincompanycodecurrency = ls_bseg-amountincompanycodecurrency * ( -1 ).

          "Amount - Transaction Currency
          "VAT - Transaction Currency
          IF ls_bseg-transactioncurrency = 'VND'. "Nếu VND thì làm tròn

            ls_einvoice_item-amountintransaccrcy  = ls_bseg-amountintransactioncurrency * 100.
            ls_einvoice_item-vatamountintransaccrcy   = round( val = ls_bseg-amountintransactioncurrency * 100 * ls_einvoice_item-taxpercentage / 100 dec = 0 ).

          ELSE.
            IF ls_bseg-transactioncurrency = 'USD' OR ls_bseg-transactioncurrency = 'EUR' OR ls_bseg-transactioncurrency = 'GBP'.

              ls_einvoice_item-amountintransaccrcy  = ls_bseg-amountintransactioncurrency.
              ls_einvoice_item-vatamountintransaccrcy   = ls_bseg-amountintransactioncurrency * ls_einvoice_item-taxpercentage / 100 .

            ELSE.
              ls_einvoice_item-amountintransaccrcy  = ls_bseg-amountintransactioncurrency * 100.
              ls_einvoice_item-vatamountintransaccrcy   = ls_bseg-amountintransactioncurrency * 100 * ls_einvoice_item-taxpercentage / 100 .
            ENDIF.
          ENDIF.
          "Total - Transaction Currency
          ls_einvoice_item-totalamountintransaccrcy   = ls_einvoice_item-amountintransaccrcy + ls_einvoice_item-vatamountintransaccrcy.

          "Amount Local - CompanyCode Currency
          ls_einvoice_item-amountincocodecrcy = ls_bseg-amountincompanycodecurrency * 100.
          "VAT Local - CompanyCode Currency
          IF ls_bseg-transactioncurrency = 'VND'. "Nếu VND thì làm tròn
            ls_einvoice_item-vatamountincocodecrcy  = round( val = ls_bseg-amountincompanycodecurrency * 100 * ls_einvoice_item-taxpercentage / 100 dec = 0 ).
          ELSE.
            ls_einvoice_item-vatamountincocodecrcy  = ls_bseg-amountincompanycodecurrency * 100 * ls_einvoice_item-taxpercentage / 100 .
          ENDIF.

          "Total Local - CompanyCode Currency
          ls_einvoice_item-totalamountincocodecrcy   = ls_einvoice_item-amountincocodecrcy + ls_einvoice_item-vatamountincocodecrcy.

          IF ls_bseg-quantity NE 0.
            "Price
            ls_einvoice_item-priceintransaccrcy = ls_einvoice_item-amountintransaccrcy / ls_bseg-quantity.
            "Price Local
            ls_einvoice_item-priceincocodecrcy = ls_einvoice_item-amountincocodecrcy / ls_bseg-quantity.
          ENDIF.

**--Header Amount
          "CompanyCode Amount
          ls_einvoice_header-amountincocodecrcy = ls_einvoice_header-amountincocodecrcy + ls_einvoice_item-amountincocodecrcy.
          ls_einvoice_header-vatamountincocodecrcy = ls_einvoice_header-vatamountincocodecrcy + ls_einvoice_item-vatamountincocodecrcy.
          ls_einvoice_header-totalamountincocodecrcy = ls_einvoice_header-totalamountincocodecrcy + ls_einvoice_item-totalamountincocodecrcy.

          "Transaction Amount
          ls_einvoice_header-amountintransaccrcy = ls_einvoice_header-amountintransaccrcy + ls_einvoice_item-amountintransaccrcy.
          ls_einvoice_header-vatamountintransaccrcy = ls_einvoice_header-vatamountintransaccrcy + ls_einvoice_item-vatamountintransaccrcy.
          ls_einvoice_header-totalamountintransaccrcy = ls_einvoice_header-totalamountintransaccrcy + ls_einvoice_item-totalamountintransaccrcy.

**--Payment Method
          IF lv_paymentmethod IS INITIAL.
            SELECT SINGLE paymentmethod FROM i_operationalacctgdocitem
            WHERE companycode        = @ls_bkpf-companycode
              AND accountingdocument = @ls_bkpf-accountingdocument
              AND fiscalyear         = @ls_bkpf-fiscalyear
              AND paymentmethod NE ''
            INTO @lv_paymentmethod
                .
          ENDIF.
**--Taxcode
          IF lv_taxcode IS INITIAL.
            lv_taxcode = ls_bseg-taxcode.
          ELSE.
          ENDIF.

          IF lv_taxcode NE ls_bseg-taxcode.
            ls_einvoice_header-taxcode = 'Nhiều loại'.
          ELSE.
            ls_einvoice_header-taxcode = lv_taxcode.
          ENDIF.

          ls_einvoice_item-taxcode = ls_bseg-taxcode.

**--Profit Center
          IF ls_einvoice_header-profitcenter IS INITIAL.
            ls_einvoice_header-profitcenter = ls_bseg-profitcenter.
          ENDIF.

          ls_einvoice_item-currencytype = lv_currencytype.
          ls_einvoice_item-usertype     = lv_usertype.
          ls_einvoice_item-typeofdate   = lv_typeofdate.

          ls_einvoice_item-einvoicetype = lv_einvoicetype.
          ls_einvoice_item-einvoiceform = ls_einvoice_header-einvoiceform.
          ls_einvoice_item-einvoiceserial = ls_einvoice_header-einvoiceserial.
**--------------------------------------------------------------------------------------------**
**-----------------------Xử lý số lượng âm ---------------**
          IF ls_einvoice_item-amountincocodecrcy < 0.
            ls_einvoice_item-quantity = ls_einvoice_item-quantity * -1.
          ENDIF.
**---------------text---------
          IF ls_bkpf-accountingdocumenttype = 'GC'.
            SELECT SINGLE * FROM i_producttext
            WHERE product = @ls_bseg-product
              AND language = 'E'
            INTO @DATA(ls_producttext).
            IF sy-subrc NE 0.
              CLEAR: ls_producttext.

              READ TABLE lt_bseg_text INTO DATA(ls_bseg_text) WITH KEY companycode            = ls_bseg-companycode
                                                         accountingdocument     = ls_bseg-accountingdocument
                                                         fiscalyear             = ls_bseg-fiscalyear
                                                         accountingdocumentitem = ls_bseg-accountingdocumentitem
                                                         BINARY SEARCH.
              IF sy-subrc EQ 0.
                IF ls_einvoice_item-documentitemtext IS INITIAL.
                  ls_einvoice_item-documentitemtext = ls_bseg_text-yy1_text2_cob.
                ELSE.
                  ls_einvoice_item-documentitemtext = ls_einvoice_item-documentitemtext && ` ` && ls_bseg_text-yy1_text2_cob.
                ENDIF.
              ENDIF.

            ELSE.
              ls_einvoice_item-documentitemtext = |Chi phí gia công { ls_producttext-productname }|.
            ENDIF.

          ELSE.

            READ TABLE lt_bseg_text INTO ls_bseg_text WITH KEY companycode            = ls_bseg-companycode
                                                               accountingdocument     = ls_bseg-accountingdocument
                                                               fiscalyear             = ls_bseg-fiscalyear
                                                               accountingdocumentitem = ls_bseg-accountingdocumentitem
                                                               BINARY SEARCH.
            IF sy-subrc EQ 0.
              IF ls_einvoice_item-documentitemtext IS INITIAL.
                ls_einvoice_item-documentitemtext = ls_bseg_text-yy1_text2_cob.
              ELSE.
                ls_einvoice_item-documentitemtext = ls_einvoice_item-documentitemtext && ` ` && ls_bseg_text-yy1_text2_cob.
              ENDIF.
            ENDIF.

          ENDIF.
*----------------------------
          APPEND ls_einvoice_item TO lt_einvoice_item.
          CLEAR: ls_einvoice_item.

        ENDLOOP.
      ELSE.

        DELETE lt_bkpf INDEX lv_index.

        CONTINUE.

      ENDIF.

**--Payment Method Text
      SELECT SINGLE paymtext FROM zjp_hd_payment WHERE zlsch       = @lv_paymentmethod
                                                   AND companycode = @ls_einvoice_header-companycode
      INTO @ls_einvoice_header-paymentmethod.
      IF sy-subrc NE 0.
        "Message Error!
        ls_returns-type = 'E'.
        ls_returns-message = TEXT-004.
*        APPEND ls_returns TO it_returns.
        CLEAR: ls_returns.
      ENDIF.

**--Exchange rate
      IF ls_bkpf-transactioncurrency = 'VND'.
        ls_einvoice_header-absoluteexchangerate = 1.
      ELSE.
        IF ls_bkpf-transactioncurrency = 'USD' OR ls_bkpf-transactioncurrency = 'EUR' OR ls_bkpf-transactioncurrency = 'GBP'.
          ls_einvoice_header-absoluteexchangerate = ls_bkpf-absoluteexchangerate * 1000.
        ELSE.
          ls_einvoice_header-absoluteexchangerate = ls_bkpf-absoluteexchangerate .
        ENDIF.
      ENDIF.

***---- get logging einvoice
      lo_einvoice_data->get_logging_invoice(
        EXPORTING
          i_input           = ls_bkpf
          i_belnrsrc        = ls_einvoice_header-AccountingDocumentSource
          i_gjahrsrc        = ls_einvoice_header-FiscalYearSource
          it_a_hddt_h       = lt_a_hddt_h
          iv_testrun        = lv_testrun
        CHANGING
          e_einvoice_header = ls_einvoice_header
      ).

      ls_einvoice_header-companycodecurrency = ls_bkpf-companycodecurrency.
      ls_einvoice_header-transactioncurrency = ls_bkpf-transactioncurrency.

      IF ir_statussap IS NOT INITIAL AND ls_einvoice_header-statussap NOT IN ir_statussap.
        CONTINUE.
      ENDIF.

      IF ir_fiscalyearsource IS NOT INITIAL AND ls_einvoice_header-fiscalyearsource NOT IN ir_fiscalyearsource.
        CONTINUE.
      ENDIF.

      IF ir_documentsource IS NOT INITIAL.
        IF ls_einvoice_header-accountingdocumentsource NOT IN ir_documentsource.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF NOT ls_einvoice_header-einvoicenumber IN ir_einvoicenumber[].
        CONTINUE.
      ENDIF.

      IF ir_billingtype IS NOT INITIAL AND ls_einvoice_header-billingdocumenttype NOT IN ir_billingtype.
        CONTINUE.
      ENDIF.

      APPEND ls_einvoice_header TO lt_einvoice_header.
**-----------------------------------------------------------------------**
      CLEAR: ls_einvoice_header.
**-----------------------------------------------------------------------**
    ENDLOOP.

**--Xử lý số tiền thuế - làm tròn
    lt_sumvat_t = lt_sumvat.

    FREE: lt_sumvat.
    LOOP AT lt_sumvat_t INTO DATA(ls_sumvat).
      IF ls_sumvat-transactioncurrency = 'USD' OR ls_sumvat-transactioncurrency = 'EUR'
      OR ls_sumvat-transactioncurrency = 'GBP'.

        ls_sumvat-sumvatamountintransaction = ls_sumvat-sumvatamountintransaction * ( -1 ).
      ELSE.
        ls_sumvat-sumvatamountintransaction = ls_sumvat-sumvatamountintransaction * ( -1 ) * 100.
      ENDIF.
      ls_sumvat-sumvatamountincompanyco = ls_sumvat-sumvatamountincompanyco * ( -1 ) * 100.
      COLLECT ls_sumvat INTO lt_sumvat.
      CLEAR: ls_sumvat.
    ENDLOOP.

    SORT lt_sumvat BY companycode accountingdocument fiscalyear taxcode ASCENDING.

    TYPES: BEGIN OF lty_item_hd,
             companycode              TYPE bukrs,
             accountingdocument       TYPE belnr_d,
             fiscalyear               TYPE gjahr,
             taxcode                  TYPE zde_taxcode,
             accountingdocumentitem   TYPE buzei,
             priceincocodecrcy        TYPE zde_dmbtr,
             companycodecurrency      TYPE waers,
             amountincocodecrcy       TYPE zde_dmbtr,
             vatamountincocodecrcy    TYPE zde_dmbtr,
             totalamountincocodecrcy  TYPE zde_dmbtr,
             transactioncurrency      TYPE waers,
             priceintransaccrcy       TYPE zde_dmbtr,
             amountintransaccrcy      TYPE zde_dmbtr,
             vatamountintransaccrcy   TYPE zde_dmbtr,
             totalamountintransaccrcy TYPE zde_dmbtr,
           END OF lty_item_hd.

    DATA: lt_item_hd TYPE TABLE OF lty_item_hd,
          ls_item_hd TYPE lty_item_hd.

    DATA: lv_cl_vatintransaction TYPE zde_dmbtr,
          lv_cl_vatincompanycode TYPE zde_dmbtr.

    MOVE-CORRESPONDING lt_einvoice_item TO lt_item_hd.

    SORT lt_item_hd BY companycode accountingdocument fiscalyear taxcode accountingdocumentitem ASCENDING.

    LOOP AT lt_item_hd "INTO DATA(ls_templine)
      INTO DATA(lt_group) GROUP BY ( companycode        = lt_group-companycode
                                     accountingdocument = lt_group-accountingdocument
                                     fiscalyear         = lt_group-fiscalyear
                                     taxcode            = lt_group-taxcode )
                                     .
      lv_index = sy-tabix.

*      MOVE-CORRESPONDING ls_templine TO ls_item_hd.

      LOOP AT GROUP lt_group INTO ls_item_hd.
        lv_cl_vatintransaction = lv_cl_vatintransaction + ls_item_hd-vatamountintransaccrcy.
        lv_cl_vatincompanycode = lv_cl_vatincompanycode + ls_item_hd-vatamountincocodecrcy.
      ENDLOOP.

*      AT END OF taxcode.
      READ TABLE lt_sumvat INTO ls_sumvat WITH KEY companycode = ls_item_hd-companycode
                                                   accountingdocument = ls_item_hd-accountingdocument
                                                   fiscalyear = ls_item_hd-fiscalyear
                                                   taxcode = ls_item_hd-taxcode BINARY SEARCH.
      IF sy-subrc EQ 0.

        READ TABLE lt_einvoice_header ASSIGNING FIELD-SYMBOL(<ls_einvoice_h>)
        WITH KEY companycode = ls_item_hd-companycode
        accountingdocument   = ls_item_hd-accountingdocument
        fiscalyear           = ls_item_hd-fiscalyear BINARY SEARCH.
        IF sy-subrc EQ 0.
          IF ls_sumvat-sumvatamountintransaction NE 0.
            <ls_einvoice_h>-vatamountintransaccrcy = <ls_einvoice_h>-vatamountintransaccrcy
                                                   + ls_sumvat-sumvatamountintransaction - lv_cl_vatintransaction.

            <ls_einvoice_h>-totalamountintransaccrcy = <ls_einvoice_h>-amountintransaccrcy + <ls_einvoice_h>-vatamountintransaccrcy.
          ENDIF.
          IF ls_sumvat-sumvatamountincompanyco NE 0.

            <ls_einvoice_h>-vatamountincocodecrcy = <ls_einvoice_h>-vatamountincocodecrcy
                                                  + ls_sumvat-sumvatamountincompanyco - lv_cl_vatincompanycode.

            <ls_einvoice_h>-totalamountincocodecrcy = <ls_einvoice_h>-amountincocodecrcy + <ls_einvoice_h>-vatamountincocodecrcy.
          ENDIF.

        ENDIF.
      ENDIF.

      READ TABLE lt_einvoice_item ASSIGNING FIELD-SYMBOL(<ls_einvoice_i>) WITH KEY companycode = ls_item_hd-companycode
      accountingdocument      = ls_item_hd-accountingdocument
      fiscalyear              = ls_item_hd-fiscalyear
      accountingdocumentitem  = ls_item_hd-accountingdocumentitem BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF ls_sumvat-sumvatamountintransaction NE 0.
          <ls_einvoice_i>-vatamountintransaccrcy = <ls_einvoice_i>-vatamountintransaccrcy
                                                 + ls_sumvat-sumvatamountintransaction - lv_cl_vatintransaction.

          <ls_einvoice_i>-totalamountintransaccrcy = <ls_einvoice_i>-amountintransaccrcy + <ls_einvoice_i>-vatamountintransaccrcy.
        ENDIF.
        IF ls_sumvat-sumvatamountincompanyco NE 0.

          <ls_einvoice_i>-vatamountincocodecrcy = <ls_einvoice_i>-vatamountincocodecrcy
                                                + ls_sumvat-sumvatamountincompanyco - lv_cl_vatincompanycode.

          <ls_einvoice_i>-totalamountincocodecrcy = <ls_einvoice_i>-amountincocodecrcy + <ls_einvoice_i>-vatamountincocodecrcy.
        ENDIF.
      ENDIF.

      CLEAR: lv_cl_vatincompanycode, lv_cl_vatintransaction, ls_item_hd.
*      ENDAT.

    ENDLOOP.

**-----------------------END PROCESS FI DOCUMENT NOT BILLING DOCUMENT------------------------**


*-----------Trường hợp chứng chừ có billing document hoặc là billing document-----------***
*    IF NOT ( ir_billingdocument IS INITIAL AND ir_accountingdocument IS NOT INITIAL ).
*      SELECT
*          a~CompanyCode,
*          a~FiscalYear,
*          a~BillingDocument,
*          a~BillingDocumentDate,
*          a~PayerParty
*      FROM I_BillingDocument AS a INNER JOIN zjp_a_hddt_h AS b ON a~BillingDocument = b~billingdocument
*      WHERE a~BillingDocument IN @ir_billingdocument
*      AND a~BillingDocument NOT IN (
*        SELECT BillingDocument FROM @lt_bkpf AS alias_bkpf WHERE BillingDocument NE ''
*      )
*      AND ( a~BillingDocumentIsCancelled EQ '' OR ( a~BillingDocument EQ 'X' AND b~einvoicenumber NE '' ) )
*      AND a~PayerParty IN @ir_customer
*      AND a~BillingDocumentDate IN @ir_postingdate
**      AND a~BillingDocumentType IN (  )
*      AND a~FiscalYear IN @ir_fiscalyear
*      AND a~FiscalPeriod IN @ir_fiscalperiod
*      AND b~statussap IN @ir_statussap
*      INTO TABLE @DATA(lt_billingdocument).
*
*      IF sy-subrc EQ 0.
*
*      ENDIF.
*    ENDIF.

    IF lt_bkpf IS NOT INITIAL.
      SELECT
      billingdocument,
      fiscalyear,
      fiscalperiod,
      billingdocumenttype,
      pricingdocument,
      paymentmethod,
      accountingexchangerate,
      documentreferenceid,
      soldtoparty,
      payerparty
      FROM i_billingdocument
      FOR ALL ENTRIES IN @lt_bkpf
      WHERE billingdocument = @lt_bkpf-billingdocument
      INTO TABLE @DATA(lt_billingdoc_h).

      IF sy-subrc EQ 0.
        SELECT a~billingdocument,
               a~billingdocumentitem,
               a~conditiontype,
               a~conditionratevalue,
               a~conditionamount,
               a~conditioncurrency,
               a~taxcode
         FROM i_billingdocumentitemprcgelmnt AS a
         FOR ALL ENTRIES IN @lt_billingdoc_h
         WHERE a~billingdocument = @lt_billingdoc_h-billingdocument
         AND a~conditiontype IN ( 'ZPR1', 'TTX1' )
         INTO TABLE @DATA(lt_pricingdocument).

      ENDIF.

      SELECT billingdocument, billingdocumentitem, salesdocumentitemcategory, product, baseunit, billingquantity, billingdocumentitemtext
      FROM i_billingdocumentitem
      FOR ALL ENTRIES IN @lt_bkpf
      WHERE billingdocument = @lt_bkpf-billingdocument
      INTO TABLE @DATA(lt_billingdoc_i).

    ENDIF.

*    IF lt_billingdocument IS NOT INITIAL.
*
*    ENDIF.

    SORT lt_billingdoc_h BY billingdocument ASCENDING.
    SORT lt_billingdoc_i BY billingdocument billingdocumentitem ASCENDING.
    SORT lt_pricingdocument BY billingdocument billingdocumentitem ASCENDING.

    DATA: lv_mwskz TYPE zde_char10,
          lv_tax_t TYPE zde_char10.

    DATA: lv_amount      TYPE zde_dmbtr,
          lv_vat         TYPE zde_dmbtr,
          lv_currencysap TYPE waers.

    LOOP AT lt_bkpf INTO ls_bkpf WHERE billingdocument IS NOT INITIAL.
      CLEAR: ls_einvoice_header.
      CLEAR: lv_count.

      READ TABLE lt_billingdoc_h INTO DATA(ls_billingdoc_h) WITH KEY billingdocument = ls_bkpf-billingdocument BINARY SEARCH.
      IF sy-subrc NE 0.
        CLEAR: ls_billingdoc_h.

      ELSE.

        ls_einvoice_header-billingdocumenttype = ls_billingdoc_h-billingdocumenttype.

        ls_einvoice_header-paymentmethod = ls_billingdoc_h-paymentmethod.

        IF ls_bkpf-accountingdocumenttype = 'RV' AND ls_billingdoc_h-soldtoparty NE ls_billingdoc_h-payerparty
        AND ( ls_billingdoc_h-payerparty = '0000006720' OR ls_billingdoc_h-payerparty = '0000006710' ) .
          DATA(lv_contract) = zcl_einvoice_data=>get_billing_text( i_billing = ls_billingdoc_h-billingdocument
                                                                   id_text   = 'Z011' ).
          ls_einvoice_header-contractno = lv_contract.
          CLEAR: lv_contract.
        ELSE.
          ls_einvoice_header-contractno = ls_billingdoc_h-documentreferenceid.
        ENDIF.

        DATA(lv_text_src) = zcl_einvoice_data=>get_billing_text( i_billing = ls_billingdoc_h-billingdocument
                                                                 id_text   = 'TX05' ).

        " Kiểu field đích trong I_BILLINGDOCUMENT (VBELN_VF: CHAR 10, ALPHA)
        DATA lv_billing_src TYPE char10.

        " Mặc định: không tìm thấy -> clear
        CLEAR ls_einvoice_header-accountingdocumentsource.

        TRY.
            " Chỉ xử lý khi lv_text_src toàn là số (có thể lẫn khoảng trắng)
            DATA(lv_clean) = condense( val = lv_text_src ).

            IF lv_clean IS NOT INITIAL AND lv_clean CO '0123456789'.
              " Chuẩn hoá ALPHA IN về độ dài 10
              lv_billing_src = |{ lv_clean ALPHA = IN WIDTH = 10 }|.

              " Tra cứu an toàn
              SELECT SINGLE accountingdocument
                FROM i_billingdocument
                WHERE billingdocument = @lv_billing_src
                INTO @ls_einvoice_header-accountingdocumentsource.
            ENDIF.

          CATCH cx_sy_conversion_no_number
                cx_sy_open_sql_db
                cx_sy_move_cast_error INTO DATA(lx).

            " Tùy chọn: ghi log rồi bỏ qua
            " cl_abap_logger=>log( ... ).
            CLEAR ls_einvoice_header-accountingdocumentsource.
        ENDTRY.

        ls_einvoice_header-fiscalyearsource = ls_bkpf-fiscalyear.
      ENDIF.

      READ TABLE lt_billingdoc_i TRANSPORTING NO FIELDS WITH KEY billingdocument = ls_bkpf-billingdocument
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_index = sy-tabix.
        LOOP AT lt_billingdoc_i INTO DATA(ls_billingdoc_i) FROM lv_index.

          CLEAR: lv_amount, lv_vat, lv_currencysap.

          IF ls_billingdoc_i-billingdocument NE ls_bkpf-billingdocument.
            EXIT.
          ENDIF.

          lv_count = lv_count + 1.

          ls_einvoice_item-accountingdocument = ls_bkpf-accountingdocument.
          ls_einvoice_item-companycode        = ls_bkpf-companycode.
          ls_einvoice_item-fiscalyear         = ls_bkpf-fiscalyear.

          ls_einvoice_item-accountingdocumentitem   = ls_billingdoc_i-billingdocumentitem+3(3).
*          ls_einvoice_item-CompanyCodeCurrency      = ls_bkpf-CompanyCodeCurrency.
          ls_einvoice_item-companycodecurrency      = 'VND'.
*          ls_einvoice_item-TransactionCurrency      = ls_bkpf-TransactionCurrency.
          ls_einvoice_item-product                  = ls_billingdoc_i-product.
          ls_einvoice_item-documentitemtext         = ls_billingdoc_i-billingdocumentitemtext.
          ls_einvoice_item-baseunit                 = ls_billingdoc_i-baseunit.
          ls_einvoice_item-quantity                 = ls_billingdoc_i-billingquantity.

          SELECT SINGLE unitofmeasurelongname FROM i_unitofmeasuretext
          WHERE unitofmeasure = @ls_billingdoc_i-baseunit
          AND language = 'E'
          INTO @ls_einvoice_item-unitofmeasurelongname.

          CLEAR: lv_mwskz, lv_tax_t.

          READ TABLE lt_pricingdocument TRANSPORTING NO FIELDS WITH KEY billingdocument = ls_billingdoc_i-billingdocument
          billingdocumentitem = ls_billingdoc_i-billingdocumentitem BINARY SEARCH.
          IF sy-subrc EQ 0.
            LOOP AT lt_pricingdocument INTO DATA(ls_pricingdocument) FROM sy-tabix.
              IF NOT ( ls_pricingdocument-billingdocument = ls_billingdoc_i-billingdocument
                AND ls_pricingdocument-billingdocumentitem = ls_billingdoc_i-billingdocumentitem ).
                EXIT.
              ENDIF.

              IF lv_currencysap IS INITIAL.
                lv_currencysap = ls_pricingdocument-conditioncurrency.
              ENDIF.

              CASE ls_pricingdocument-conditiontype.

                WHEN 'ZPR1'.
                  lv_amount = abs( ls_pricingdocument-conditionamount ).
                  ls_einvoice_item-transactioncurrency = ls_pricingdocument-conditioncurrency.
                WHEN 'TTX1'.
                  lv_vat = abs( ls_pricingdocument-conditionamount ).

                  lv_mwskz = ls_pricingdocument-taxcode.
                  ls_einvoice_item-taxpercentage = ls_pricingdocument-conditionratevalue.

                WHEN OTHERS.

              ENDCASE.
            ENDLOOP.
          ENDIF.

          IF ls_billingdoc_h-billingdocumenttype = 'F2'.
            lv_amount = lv_amount * 1.
            lv_vat = lv_vat * 1.
          ELSEIF ls_billingdoc_h-billingdocumenttype = 'CBRE'.
            lv_amount = lv_amount * -1.
            lv_vat = lv_vat * -1.
          ELSEIF ls_billingdoc_h-billingdocumenttype = 'G2' OR ls_billingdoc_h-billingdocumenttype = 'L2'.
            IF ls_billingdoc_i-salesdocumentitemcategory = 'L2N'.
              lv_amount = lv_amount * 1.
              lv_vat = lv_vat * 1.
            ELSEIF ls_billingdoc_i-salesdocumentitemcategory = 'G2N'.
              lv_amount = lv_amount * -1.
              lv_vat = lv_vat * -1.
            ENDIF.
          ENDIF.

          IF lv_currencysap = 'VND'.
            lv_amount = lv_amount * 100.
            lv_vat = lv_vat * 100.

            ls_einvoice_header-absoluteexchangerate = 1.

            ls_einvoice_item-amountincocodecrcy = lv_amount.
            ls_einvoice_item-vatamountincocodecrcy = lv_vat.

            ls_einvoice_item-amountintransaccrcy = lv_amount.
            ls_einvoice_item-vatamountintransaccrcy = lv_vat.
          ELSE.
*            lv_amount = lv_amount * 100.
*            lv_vat = lv_vat * 100.

            ls_einvoice_header-absoluteexchangerate = ls_billingdoc_h-accountingexchangerate.
            IF lv_currencysap = 'USD' OR lv_currencysap = 'EUR' OR lv_currencysap = 'GBP'.
              ls_einvoice_header-absoluteexchangerate = ls_billingdoc_h-accountingexchangerate * 1000.
            ELSE.
              ls_einvoice_header-absoluteexchangerate = ls_billingdoc_h-accountingexchangerate .
            ENDIF.

            ls_einvoice_item-amountincocodecrcy = lv_amount * ls_einvoice_header-absoluteexchangerate.
            ls_einvoice_item-vatamountincocodecrcy = lv_vat * ls_einvoice_header-absoluteexchangerate.

            ls_einvoice_item-amountintransaccrcy = lv_amount.
            ls_einvoice_item-vatamountintransaccrcy = lv_vat.

          ENDIF.

          IF ls_einvoice_item-quantity NE 0.
            ls_einvoice_item-priceincocodecrcy = ls_einvoice_item-amountincocodecrcy / ls_einvoice_item-quantity.
            ls_einvoice_item-priceintransaccrcy = ls_einvoice_item-amountintransaccrcy / ls_einvoice_item-quantity.
          ENDIF.

**-----------------------Xử lý số tiền âm ---------------------------
          IF ls_einvoice_item-amountincocodecrcy < 0.
            ls_einvoice_item-quantity = ls_einvoice_item-quantity * -1.
          ENDIF.

**-------------------------------------------------------------------

**--Payment Method Text
          SELECT SINGLE paymtext FROM zjp_hd_payment WHERE zlsch       = @ls_billingdoc_h-paymentmethod
                                                       AND companycode = @ls_bkpf-companycode
          INTO @ls_einvoice_header-paymentmethod.
          IF sy-subrc NE 0.
            "Message Error!
            ls_returns-type = 'E'.
            ls_returns-message = TEXT-004.
*        APPEND ls_returns TO it_returns.
            CLEAR: ls_returns.
          ENDIF.

*          SELECT SINGLE paymentmethodname FROM i_paymentmethod
*          WHERE country = 'VN'
*            AND paymentmethod = @ls_billingdoc_h-paymentmethod
*          INTO @ls_einvoice_header-paymentmethod.

          ls_einvoice_header-amountincocodecrcy = ls_einvoice_header-amountincocodecrcy + ls_einvoice_item-amountincocodecrcy.
          ls_einvoice_header-amountintransaccrcy = ls_einvoice_header-amountintransaccrcy + ls_einvoice_item-amountintransaccrcy.

          ls_einvoice_header-vatamountincocodecrcy = ls_einvoice_header-vatamountincocodecrcy + ls_einvoice_item-vatamountincocodecrcy.
          ls_einvoice_header-vatamountintransaccrcy = ls_einvoice_header-vatamountintransaccrcy + ls_einvoice_item-vatamountintransaccrcy.

          ls_einvoice_header-transactioncurrency = lv_currencysap.

          ls_einvoice_item-totalamountintransaccrcy = ls_einvoice_item-amountintransaccrcy + ls_einvoice_item-vatamountintransaccrcy.
          ls_einvoice_item-totalamountincocodecrcy = ls_einvoice_item-amountincocodecrcy + ls_einvoice_item-vatamountincocodecrcy.

          APPEND ls_einvoice_item TO lt_einvoice_item.
          CLEAR: ls_einvoice_item.

          IF lv_count = 1.
            ls_einvoice_header-taxcode = lv_mwskz.
          ENDIF.

          IF lv_mwskz NE ls_einvoice_header-taxcode.
            ls_einvoice_header-taxcode = 'Nhiều loại'.
          ENDIF.

        ENDLOOP.

      ENDIF.

      lo_einvoice_data->get_header_invoice(
        EXPORTING
          i_input           = ls_bkpf
          iv_testrun        = lv_testrun
          iv_usertype       = lv_usertype
          iv_currencytype   = lv_currencytype
          iv_typeofdate     = lv_typeofdate
          ir_companycode    = ir_companycode
          iv_einvoicetype   = lv_einvoicetype
        CHANGING
          e_einvoice_header = ls_einvoice_header
      ).

      ls_einvoice_header-companycodecurrency = 'VND'.

      ls_einvoice_header-totalamountincocodecrcy = ls_einvoice_header-amountincocodecrcy + ls_einvoice_header-vatamountincocodecrcy.
      ls_einvoice_header-totalamountintransaccrcy = ls_einvoice_header-amountintransaccrcy + ls_einvoice_header-vatamountintransaccrcy.

      lo_einvoice_data->get_logging_invoice(
        EXPORTING
          i_input           = ls_bkpf
          i_belnrsrc        = ls_einvoice_header-AccountingDocumentSource
          i_gjahrsrc        = ls_einvoice_header-FiscalYearSource
          it_a_hddt_h       = lt_a_hddt_h
          iv_testrun        = lv_testrun
        CHANGING
          e_einvoice_header = ls_einvoice_header
      ).

      IF ir_statussap IS NOT INITIAL AND ls_einvoice_header-statussap NOT IN ir_statussap.
        CONTINUE.
      ENDIF.

      IF ir_fiscalyearsource IS NOT INITIAL AND ls_einvoice_header-fiscalyearsource NOT IN ir_fiscalyearsource.
        CONTINUE.
      ENDIF.

      IF ir_documentsource IS NOT INITIAL.
        IF ls_einvoice_header-accountingdocumentsource NOT IN ir_documentsource.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF NOT ls_einvoice_header-einvoicenumber IN ir_einvoicenumber[].
        CONTINUE.
      ENDIF.

      IF ir_billingtype IS NOT INITIAL AND ls_einvoice_header-billingdocumenttype NOT IN ir_billingtype.
        CONTINUE.
      ENDIF.

      APPEND ls_einvoice_header TO lt_einvoice_header.
      CLEAR: ls_einvoice_header.
    ENDLOOP.
**---------------------END PROCESS BILLING DOCUMENT----------------------**

*    IF ir_statussap[] IS NOT INITIAL.
*      DELETE lt_einvoice_header WHERE statussap NOT IN ir_statussap.
*    ENDIF.
*
*    IF ir_einvoicenumber[] IS NOT INITIAL.
*      DELETE lt_einvoice_header WHERE einvoicenumber NOT IN ir_einvoicenumber.
*    ENDIF.

***----Export data---***
    it_einvoice_header = lt_einvoice_header.
    it_einvoice_item = lt_einvoice_item.
  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                               THEN mo_instance
                                               ELSE NEW #( ) ).
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

          ir_customer           TYPE zcl_jp_common_core=>tt_ranges,

          ir_buzei              TYPE zcl_jp_common_core=>tt_ranges,

          ir_billingdocument    TYPE zcl_jp_common_core=>tt_ranges
          .

    DATA: lt_einvoice_header TYPE tt_einvoice_header,
          lt_einvoice_item   TYPE tt_einvoice_item.

    DATA: lt_returns TYPE tt_returns.

    FREE: lt_einvoice_header, lt_einvoice_item, lt_returns.

    DATA(lv_entity_id) = io_request->get_entity_id( ).

    TRY.
        go_einvoice_data  = zcl_einvoice_data=>get_instance( ).

        DATA(lo_common_app) = zcl_jp_common_core=>get_instance( ).

        lo_common_app->get_fillter_app(
          EXPORTING
            io_request             = io_request
            io_response            = io_response
          IMPORTING
            ir_companycode         = ir_companycode
            ir_accountingdocument  = ir_accountingdocument
            ir_fiscalyear          = ir_fiscalyear
*           ir_glaccount           = ir_glaccount
            ir_buzei               = ir_buzei
            ir_postingdate         = ir_postingdate
            ir_documentdate        = ir_documentdate
            ir_statussap           = ir_statussap
            ir_einvoicenumber      = ir_einvoicenumber
            ir_einvoicetype        = ir_einvoicetype
            ir_currencytype        = ir_currencytype
            ir_usertype            = ir_usertype
            ir_typeofdate          = ir_typeofdate
            ir_createdbyuser       = ir_createdbyuser
            ir_enduser             = ir_enduser
            ir_testrun             = ir_testrun
            ir_documenttype        = gr_documenttype
            ir_documentsource      = gr_documentsource
            ir_fiscalyearsource    = gr_fiscalyearsource
            ir_fiscalperiod        = gr_fiscalperiod
            ir_transactioncurrency = gr_transactioncurrency
            ir_customer            = ir_customer
            ir_billingdocument     = ir_billingdocument
            ir_billingtype         = gr_billingtype
            wa_page_info           = ls_page_info
        ).

        DELETE ir_companycode WHERE low = '0000' OR low = ''.
        DELETE ir_accountingdocument WHERE low = '0000' OR low = ''.
        DELETE ir_fiscalyear WHERE low = '0000' OR low = ''.

        DELETE gr_fiscalyearsource WHERE low = '0000' OR low = ''.
        DELETE gr_documentsource WHERE low = '0000' OR low = ''.
        DELETE ir_usertype WHERE low = ''.
        DELETE ir_einvoicetype WHERE low = ''.
        DELETE ir_currencytype WHERE low = ''.
        DELETE ir_einvoicenumber WHERE low = ''.

*        AUTHORITY-CHECK OBJECT 'ZOBJECT***'
*          ID 'ACTVT' FIELD '03'
*          ID 'LV_FIELD' FIELD lv_field.
*        IF sy-subrc NE 0.

*        ENDIF.

        go_einvoice_data->get_einvoice_data(
          EXPORTING
            ir_companycode         = ir_companycode
            ir_accountingdocument  = ir_accountingdocument
            ir_fiscalyear          = ir_fiscalyear
            ir_postingdate         = ir_postingdate
            ir_documentdate        = ir_documentdate
            ir_statussap           = ir_statussap
            ir_einvoicenumber      = ir_einvoicenumber
            ir_einvoicetype        = ir_einvoicetype
            ir_currencytype        = ir_currencytype
            ir_usertype            = ir_usertype
            ir_typeofdate          = ir_typeofdate
            ir_createdbyuser       = ir_createdbyuser
            ir_enduser             = ir_enduser
            ir_testrun             = ir_testrun
            ir_documenttype        = gr_documenttype
            ir_documentsource      = gr_documentsource
            ir_fiscalyearsource    = gr_fiscalyearsource
            ir_fiscalperiod        = gr_fiscalperiod
            ir_transactioncurrency = gr_transactioncurrency
            ir_billingdocument     = ir_billingdocument
            ir_customer            = ir_customer
            ir_billingtype         = gr_billingtype
          IMPORTING
            it_einvoice_header     = gt_einvoice_headers
            it_einvoice_item       = gt_einvoice_items
            it_returns             = lt_returns
        ).


        IF lt_returns IS NOT INITIAL.
*          READ TABLE lt_returns INTO DATA(ls_returns) INDEX 1.
*
*          RAISE EXCEPTION TYPE zcl_einvoice_data
*              MESSAGE ID ''
*              TYPE ls_returns-type
*              NUMBER ''
*              WITH |{ ls_returns-message }|.
*          RETURN.

        ENDIF.

        IF ls_page_info-page_size < 0.
          ls_page_info-page_size = 50.
        ENDIF.

        DATA(max_rows) = COND #( WHEN ls_page_info-page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                   ELSE ls_page_info-page_size ).

        max_rows = ls_page_info-page_size + ls_page_info-offset.

        CASE lv_entity_id.
          WHEN 'ZJP_C_HDDT_H' OR 'EINVOICE_HEADERS'. ""---EInvoice Headers
            LOOP AT gt_einvoice_headers INTO DATA(ls_einvoice_h).
              IF sy-tabix > ls_page_info-offset.
                IF sy-tabix > max_rows.
                  EXIT.
                ELSE.
                  APPEND ls_einvoice_h TO lt_einvoice_header.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF io_request->is_total_numb_of_rec_requested( ).
              io_response->set_total_number_of_records( lines( gt_einvoice_headers ) ).
            ENDIF.

            IF io_request->is_data_requested( ).
              io_response->set_data( lt_einvoice_header ).
            ENDIF.
          WHEN 'ZJP_C_HDDT_I' OR 'EINVOICE_ITEMS'. ""---EInvoice Items
            LOOP AT gt_einvoice_items INTO DATA(ls_einvoice_i).
              IF sy-tabix > ls_page_info-offset.
                IF sy-tabix > max_rows.
                  EXIT.
                ELSE.
                  APPEND ls_einvoice_i TO lt_einvoice_item.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF ir_buzei IS NOT INITIAL.
              DELETE gt_einvoice_items WHERE accountingdocumentitem NOT IN ir_buzei.
            ENDIF.

            IF io_request->is_total_numb_of_rec_requested( ).
              io_response->set_total_number_of_records( lines( gt_einvoice_items ) ).
            ENDIF.

            IF io_request->is_data_requested( ).
              io_response->set_data( lt_einvoice_item ).
            ENDIF.
        ENDCASE.

      CATCH cx_root INTO DATA(exception).

        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

        RAISE EXCEPTION TYPE zcl_einvoice_data
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


  METHOD read_ranges.
    READ TABLE it_ranges INTO DATA(wa_ranges) INDEX 1.
    IF sy-subrc EQ 0.
      o_value = wa_ranges-low.
    ELSE.
      CLEAR: o_value.
    ENDIF.
  ENDMETHOD.


  METHOD get_logging_invoice.
    TYPES: BEGIN OF lty_bkpf,
             companycode         TYPE bukrs,
             accountingdocument  TYPE belnr_d,
             fiscalyear          TYPE gjahr,
             billingdocument     TYPE zde_char10,
             customer            TYPE kunnr,
             companycodecurrency TYPE waers,
             transactioncurrency TYPE waers,
           END OF lty_bkpf.

    DATA: ls_bkpf TYPE lty_bkpf.
    DATA: wa_document         TYPE zst_document_info,
          wa_customer_details TYPE zst_businesspartner_info.

    MOVE-CORRESPONDING i_input TO ls_bkpf.

    "Status SAP
    e_einvoice_header-statussap = '01'.

    "Currency
*    e_einvoice_header-companycodecurrency = ls_bkpf-CompanyCodeCurrency.
*    e_einvoice_header-transactioncurrency = ls_bkpf-TransactionCurrency.

**--SID Code
    IF ls_bkpf-billingdocument IS INITIAL.
      e_einvoice_header-sid = |{ sy-sysid }{ sy-mandt }{ ls_bkpf-companycode }{ ls_bkpf-accountingdocument }{ ls_bkpf-fiscalyear }|.
    ELSE.
      e_einvoice_header-sid = |{ sy-sysid }{ sy-mandt }{ ls_bkpf-companycode }{ ls_bkpf-billingdocument }{ ls_bkpf-fiscalyear }|.
    ENDIF.

**--SID system
    e_einvoice_header-idsys = 'VIETTEL'.

**--Get Customer Information
    e_einvoice_header-customer = ls_bkpf-customer.

    CLEAR: wa_customer_details, wa_document.

    wa_document-companycode           = ls_bkpf-companycode.
    wa_document-accountingdocument    = ls_bkpf-accountingdocument.
    wa_document-fiscalyear            = ls_bkpf-fiscalyear.
    wa_document-customer              = ls_bkpf-customer.

    IF ls_bkpf-customer IS NOT INITIAL.
      go_jp_common_core->get_businesspartner_details(
        EXPORTING
          i_document  = wa_document
        IMPORTING
          o_bpdetails = wa_customer_details
      ).
      "--Customer Name
      e_einvoice_header-customername          = wa_customer_details-bpname.
      "--Customer Address
      e_einvoice_header-customeraddress       = wa_customer_details-bpaddress.
      "--Customer Email
      e_einvoice_header-emailaddress          = wa_customer_details-emailaddress.
      "--Customer ID
      e_einvoice_header-identificationnumber  = wa_customer_details-identificationnumber.
      "--Customer Phone
      e_einvoice_header-telephonenumber       = wa_customer_details-telephonenumber.
    ENDIF.

*** Get log
    READ TABLE it_a_hddt_h INTO DATA(ls_a_hddt_h)
    WITH KEY companycode        = ls_bkpf-companycode
             accountingdocument = ls_bkpf-accountingdocument
             billingdocument    = ls_bkpf-billingdocument
             fiscalyear         = ls_bkpf-fiscalyear BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF ls_a_hddt_h-messagetype = 'S'.
**---Trường hợp Document Phát hành thành công -> Lấy data từ bảng log hddt

**--TestRun Flag
        IF iv_testrun IS INITIAL.

          e_einvoice_header-typeofdate               = ls_a_hddt_h-typeofdate.
          e_einvoice_header-usertype                 = ls_a_hddt_h-usertype.
          e_einvoice_header-currencytype             = ls_a_hddt_h-currencytype.

          e_einvoice_header-einvoicenumber           = ls_a_hddt_h-einvoicenumber.

          e_einvoice_header-einvoiceform             = ls_a_hddt_h-einvoiceform.
          e_einvoice_header-einvoiceserial           = ls_a_hddt_h-einvoiceserial.
          e_einvoice_header-einvoicetype             = ls_a_hddt_h-einvoicetype.

          e_einvoice_header-createdtime              = ls_a_hddt_h-createdtime.
          e_einvoice_header-createddate              = ls_a_hddt_h-createddate.
          e_einvoice_header-createdbyuser            = ls_a_hddt_h-createdbyuser.

          e_einvoice_header-mscqt                    = ls_a_hddt_h-mscqt.
          e_einvoice_header-invdat                   = ls_a_hddt_h-invdat.
          e_einvoice_header-reservationcode          = ls_a_hddt_h-reservationcode.

          e_einvoice_header-statussap                = ls_a_hddt_h-statussap.
          e_einvoice_header-statusinvres             = ls_a_hddt_h-statusinvres.
          e_einvoice_header-statuscqtres             = ls_a_hddt_h-statuscqtres.

          e_einvoice_header-frdate                   = ls_a_hddt_h-frdate.
          e_einvoice_header-todate                   = ls_a_hddt_h-todate.
          e_einvoice_header-zmapp                    = ls_a_hddt_h-zmapp.

        ENDIF.

*          APPEND ls_a_hddt_h TO lt_einvoice_header.

*          CLEAR: ls_a_hddt_h.

*          READ TABLE lt_a_hddt_i TRANSPORTING NO FIELDS
*          WITH KEY companycode        = ls_bkpf-CompanyCode
*                   accountingdocument = ls_bkpf-AccountingDocument
*                   fiscalyear         = ls_bkpf-FiscalYear BINARY SEARCH.
*          IF sy-subrc EQ 0.
*            lv_index = sy-tabix.
*            LOOP AT lt_a_hddt_i INTO DATA(ls_a_hddt_i) FROM lv_index.
*              IF NOT ( ls_a_hddt_i-companycode        EQ ls_bkpf-CompanyCode AND
*                       ls_a_hddt_i-accountingdocument EQ ls_bkpf-AccountingDocument AND
*                       ls_a_hddt_i-fiscalyear         EQ ls_bkpf-FiscalYear ).
*                EXIT.
*              ENDIF.
*
*              APPEND ls_a_hddt_i TO lt_einvoice_item.
*              CLEAR: ls_a_hddt_i.
*            ENDLOOP.
*          ENDIF.
*
*          CONTINUE.
**-----------------------------------------------------------------------**
      ELSE.

      ENDIF.

      IF ls_a_hddt_h-accountingdocumentsource IS NOT INITIAL.
        e_einvoice_header-accountingdocumentsource = ls_a_hddt_h-accountingdocumentsource.
      ENDIF.

      IF ls_a_hddt_h-fiscalyearsource IS NOT INITIAL.
        e_einvoice_header-fiscalyearsource         = ls_a_hddt_h-fiscalyearsource.
      ENDIF.

      e_einvoice_header-adjusttype               = ls_a_hddt_h-adjusttype.

      e_einvoice_header-frdate                   = ls_a_hddt_h-frdate.
      e_einvoice_header-todate                   = ls_a_hddt_h-todate.
      e_einvoice_header-zmapp                    = ls_a_hddt_h-zmapp.

      e_einvoice_header-messagetype              = ls_a_hddt_h-messagetype.
      e_einvoice_header-messagetext              = ls_a_hddt_h-messagetext.
    ENDIF.

**--Status SAP
    IF ls_a_hddt_h-messagetype = 'E'.
      e_einvoice_header-statussap = '03'.
      e_einvoice_header-messagetype = 'E'.
    ELSE.

    ENDIF.

    SELECT SINGLE description FROM zjp_hd_config
    WHERE id_sys = '001'
     AND id_domain = 'STATUSSAP'
     AND value = @e_einvoice_header-statussap
     INTO @e_einvoice_header-descriptionstatussap.

*        OK → sap-icon://accept (xanh) – Criticality = 3
*
*        WARN → sap-icon://alert (vàng) – Criticality = 2
*
*        ERR → sap-icon://error (đỏ) – Criticality = 1
*
*        Khác → sap-icon://question-mark (xám) – Criticality = 0

    CASE e_einvoice_header-statussap.
      WHEN '01'.
        e_einvoice_header-criticality = 0.
        e_einvoice_header-statusiconurl = 'sap-icon://horizontal-grip'.
      WHEN '02'.
        e_einvoice_header-criticality = 2.
        e_einvoice_header-statusiconurl = 'sap-icon://message-success'.
      WHEN '03'.
        e_einvoice_header-criticality = 2.
        e_einvoice_header-statusiconurl = 'sap-icon://status-error'.
      WHEN '06'.
        e_einvoice_header-criticality = 3.
        e_einvoice_header-statusiconurl = 'sap-icon://journey-change'.
      WHEN '07'.
        e_einvoice_header-criticality = 3.
        e_einvoice_header-statusiconurl = 'sap-icon://cancel'.
      WHEN '10'.
        e_einvoice_header-criticality = 2.
        e_einvoice_header-statusiconurl = 'sap-icon://message-success'.
      WHEN '98'.
        e_einvoice_header-criticality = 2.
        e_einvoice_header-statusiconurl = 'sap-icon://message-success'.
      WHEN '99'.
        e_einvoice_header-criticality = 3.
        e_einvoice_header-statusiconurl = 'sap-icon://message-success'.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.


  METHOD get_header_invoice.
    TYPES: BEGIN OF lty_bkpf,
             companycode                    TYPE i_journalentry-companycode,
             accountingdocument             TYPE i_journalentry-accountingdocument,
             billingdocument                TYPE i_operationalacctgdocitem-billingdocument,
             fiscalyear                     TYPE i_journalentry-fiscalyear,
             fiscalperiod                   TYPE i_journalentry-fiscalperiod,
             postingdate                    TYPE i_journalentry-postingdate,
             documentdate                   TYPE i_journalentry-documentdate,
             accountingdocumenttype         TYPE i_journalentry-accountingdocumenttype,
             accountingdocumentcreationdate TYPE i_journalentry-accountingdocumentcreationdate,
             accountingdocumentheadertext   TYPE i_journalentry-accountingdocumentheadertext,
             isreversed                     TYPE i_journalentry-isreversed,
             isreversal                     TYPE i_journalentry-isreversal,
             customer                       TYPE i_customer-customer,
           END OF lty_bkpf.

    DATA: ls_bkpf TYPE lty_bkpf.
    FIELD-SYMBOLS: <lv_value> TYPE any.

    MOVE-CORRESPONDING i_input TO ls_bkpf.

**--TestRun Flag
    IF iv_testrun IS NOT INITIAL.
      e_einvoice_header-testrun = iv_testrun.
    ENDIF.

**--Process Data HDDT Header

    e_einvoice_header-companycode        = ls_bkpf-companycode.
    e_einvoice_header-accountingdocument = ls_bkpf-accountingdocument.
    e_einvoice_header-billingdocument    = ls_bkpf-billingdocument.
    e_einvoice_header-fiscalyear         = ls_bkpf-fiscalyear.
    e_einvoice_header-fiscalperiod       = ls_bkpf-fiscalperiod.

    e_einvoice_header-postingdate        = ls_bkpf-postingdate.
    e_einvoice_header-documentdate       = ls_bkpf-documentdate.

    e_einvoice_header-accountingdocumenttype         = ls_bkpf-accountingdocumenttype.
    e_einvoice_header-accountingdocumentcreationdate = ls_bkpf-accountingdocumentcreationdate.
    e_einvoice_header-accountingdocumentheadertext   = ls_bkpf-accountingdocumentheadertext.

    e_einvoice_header-xreversed                      = ls_bkpf-isreversed.
    e_einvoice_header-xreversing                     = ls_bkpf-isreversal.

    e_einvoice_header-customer                       = ls_bkpf-customer.

**--
    e_einvoice_header-usertype       = iv_usertype.
    e_einvoice_header-currencytype   = iv_currencytype.
    e_einvoice_header-typeofdate     = iv_typeofdate.

**--Time CREATE
    TRY.
        zcl_einvoice_data=>getdate_einvoice(
          EXPORTING
            i_document = e_einvoice_header
          IMPORTING
            e_document = e_einvoice_header
        ).
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    DATA: lv_fiscalyear   TYPE gjahr,
          lr_einvoicetype TYPE zcl_einvoice_data=>tt_ranges.

    lv_fiscalyear = e_einvoice_header-einvoicedatecreate+0(4).

***" Get Form-Serial SInvoice
*      IF lv_einvoicetype IS NOT INITIAL.
    SELECT SINGLE * FROM zjp_hd_serial
    WHERE companycode   IN @ir_companycode
      AND einvoicetype  IN @lr_einvoicetype
      AND fiscalyear    EQ @lv_fiscalyear
      INTO @DATA(ls_hd_serial)
      .
    IF sy-subrc NE 0.
      "MESSAGE Error!
*      ls_returns-type = 'E'.
*      ls_returns-message = TEXT-002.
*      APPEND ls_returns TO it_returns.
*      CLEAR: ls_returns.
    ELSE.
      e_einvoice_header-einvoiceform   = ls_hd_serial-einvoiceform.
      e_einvoice_header-einvoiceserial = ls_hd_serial-einvoiceserial.
      e_einvoice_header-einvoicetype   = ls_hd_serial-einvoicetype.
    ENDIF.
*      ENDIF.

    e_einvoice_header-uuidfilter = |currencytype={ iv_currencytype }-typeofdate={ iv_typeofdate }-testrun={ iv_testrun }-einvoicetype={ iv_einvoicetype }|.

  ENDMETHOD.


  METHOD get_billing_text.

*Response Body
*
*{
*  "@odata.context": "../../$metadata#BillingDocumentText",
*  "@odata.metadataEtag": "W/\"20251027041216\"",
*  "value": [
*    {
*      "@odata.etag": "W/\"SADL-202509160222568751640C~20250916022256.8751640\"",
*      "BillingDocument": "90000118",
*      "Language": "EN",
*      "LongTextID": "Z011",
*      "LongText": "SHĐUT#000132",
*      "SAP__Messages": []
*    }
*  ]
*}

    TYPES: BEGIN OF lty_value,
             billingdocument TYPE i_billingdocument-billingdocument,
             language        TYPE char2,
             longtextid      TYPE char10,
             longtext        TYPE string,
           END OF lty_value,

           BEGIN OF lty_response,
             value TYPE STANDARD TABLE OF lty_value WITH EMPTY KEY,
           END OF lty_response.

    DATA: ls_response TYPE lty_response.

    " Call External API
    DATA: lv_url  TYPE string,
          lv_pref TYPE string.
    " Replace with actual URL
    TRY.
        DATA(lv_host) = cl_abap_context_info=>get_system_url( ).
        SPLIT lv_host AT '.' INTO lv_host lv_pref.
        CONCATENATE lv_host `-api` `.` lv_pref INTO lv_host.
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    lv_url = |https://{ lv_host }/sap/opu/odata4/sap/api_billingdocument/srvd_a2x/sap/billingdocument/0001/BillingDocument/{ i_billing }/_Text?$top=50|.


    TRY.
        "create http destination by url; API endpoint for API sandbox
        DATA(lo_http_destination) =
          cl_http_destination_provider=>create_by_url(
          i_url = lv_url ).

        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_http_destination ).

*-- SET HTTP Header Fields

        lo_http_client->get_http_request( )->set_header_fields( VALUE #(
            ( name = |Accept-Encoding| value = |gzip,deflate| )
            ( name = |Content-Type|    value = |text/xml;charset=UTF-8| )
            ( name = |SOAPAction|      value = |http://sap.com/xi/SAPSCORE/SFIN/JournalEntryBulkChangeRequest_In/JournalEntryBulkChangeRequest_InRequest| )
            ( name = |Host|            value = |my428927-api.s4hana.cloud.sap| )
            ( name = |Connection|      value = |Keep-Alive| )
            ( name = |User-Agent|      value = |Apache-HttpClient/4.5.5 (Java/16.0.2)| )
        ) ).

        DATA: lv_username TYPE string,
              lv_password TYPE string.

        lv_username = `INBOUND_COMM_USER_BTP_EXTENSION`.
        lv_password = `DCg=#-}.v-qnz&wFz2025`.

*-- Passing the Accept value in header which is a mandatory field
        lo_http_client->get_http_request( )->set_header_field( i_name = |username| i_value = lv_username ).
        lo_http_client->get_http_request( )->set_header_field( i_name = |password| i_value = lv_password ).
*-- Authorization
        lo_http_client->get_http_request( )->set_authorization_basic( i_username = lv_username i_password = lv_password ).
        lo_http_client->get_http_request( )->set_content_type( |text/xml;charset=UTF-8| ).

        lo_http_client->get_http_request( )->set_version( version = if_web_http_request=>co_protocol_version_1_1 ).
*-- Send request ->
*        lo_http_client->get_http_request( )->set_text( lv_xml ).
**-- POST

*-- Response ->
        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>get
                                                     ).

        DATA(code) = lo_response->get_status( )-code.
        DATA(reason) = lo_response->get_status( )-reason.
        DATA(lv_body)  = lo_response->get_text( ).

      CATCH cx_root INTO DATA(lx_exception).

    ENDTRY.

    IF lv_body IS NOT INITIAL.
      /ui2/cl_json=>deserialize(
        EXPORTING
          json        = lv_body
*         jsonx       =
          pretty_name = /ui2/cl_json=>pretty_mode-none
*         assoc_arrays     =
*         assoc_arrays_opt =
*         name_mappings    =
*         conversion_exits =
*         hex_as_base64    =
        CHANGING
          data        = ls_response
      ).

    ELSE.
      rv_text = ''.
    ENDIF.

    READ TABLE ls_response-value INTO DATA(ls_value) WITH KEY longtextid = id_text.
    IF sy-subrc EQ 0.
      rv_text = ls_value-longtext.
    ELSE.
      rv_text = ''.
    ENDIF.

  ENDMETHOD.
ENDCLASS.

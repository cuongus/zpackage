CLASS zcl_jp_get_data_report_fi DEFINITION
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

           tt_ranges             TYPE TABLE OF ty_range_option,

           tt_returns            TYPE TABLE OF bapiret2,

           tt_soquytienmat       TYPE TABLE OF zjp_c_soquytienmat,

           tt_bangcandoiphatsinh TYPE TABLE OF zjp_c_bangcandoiphatsinh,

           tt_phieuketoan        TYPE TABLE OF zjp_c_phieuketoan,

           tt_phieuketoan_items  TYPE TABLE OF zjp_c_phieuketoan_items,

           tt_pkt_pdf            TYPE TABLE OF zjp_c_pkt_pdfdoc.

    "Custom Entities
    INTERFACES if_rap_query_provider.

    CLASS-DATA: gt_soquytienmat       TYPE tt_soquytienmat,

                gt_bangcandoiphatsinh TYPE tt_bangcandoiphatsinh,

                gt_phieuketoan        TYPE tt_phieuketoan,

                gt_phieuketoan_items  TYPE tt_phieuketoan_items,

                gt_pkt_pdf            TYPE tt_pkt_pdf.

    CLASS-METHODS: get_soquytienmat IMPORTING ir_companycode        TYPE tt_ranges
                                              ir_glaccount          TYPE tt_ranges
                                              ir_accountingdocument TYPE tt_ranges OPTIONAL
                                              ir_postingdate        TYPE tt_ranges
                                              ir_fiscalyear         TYPE tt_ranges OPTIONAL
                                              ir_documentdate       TYPE tt_ranges OPTIONAL
                                              ir_businesspartner    TYPE tt_ranges OPTIONAL
                                    EXPORTING e_soquytienmat        TYPE tt_soquytienmat
                                              e_return              TYPE tt_returns .

    CLASS-METHODS: get_bangcandoiphatsinh IMPORTING ir_companycode        TYPE tt_ranges
                                                    ir_glaccount          TYPE tt_ranges
                                                    ir_accountingdocument TYPE tt_ranges OPTIONAL
                                                    ir_postingdate        TYPE tt_ranges
                                                    ir_fiscalyear         TYPE tt_ranges OPTIONAL
                                                    ir_documentdate       TYPE tt_ranges OPTIONAL
                                                    ir_businesspartner    TYPE tt_ranges OPTIONAL
                                          EXPORTING e_bangcandoiphatsinh  TYPE tt_bangcandoiphatsinh
                                                    e_return              TYPE tt_returns .

    CLASS-METHODS: get_phieuketoan IMPORTING ir_companycode        TYPE tt_ranges
                                             ir_accountingdocument TYPE tt_ranges
                                             ir_fiscalyear         TYPE tt_ranges
                                             ir_accountant         TYPE tt_ranges OPTIONAL
                                             ir_createby           TYPE tt_ranges OPTIONAL
                                             ir_documentitem       TYPE tt_ranges OPTIONAL
                                             ir_postingdate        TYPE tt_ranges OPTIONAL
                                             ir_documentdate       TYPE tt_ranges OPTIONAL
                                             ir_documenttype       TYPE tt_ranges OPTIONAL
                                             ir_customer           TYPE tt_ranges OPTIONAL
                                             ir_supplier           TYPE tt_ranges OPTIONAL



                                   EXPORTING e_phieuketoan         TYPE tt_phieuketoan
                                             e_phieuketoan_items   TYPE tt_phieuketoan_items
                                             e_return              TYPE tt_returns .

    CLASS-METHODS get_pkt_pdf IMPORTING ir_companycode        TYPE tt_ranges
                                        ir_accountingdocument TYPE tt_ranges
                                        ir_fiscalyear         TYPE tt_ranges
                                        ir_accountant         TYPE tt_ranges
                                        ir_createby           TYPE tt_ranges
                              EXPORTING
                                        e_pkt_pdt             TYPE tt_pkt_pdf.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_JP_GET_DATA_REPORT_FI IMPLEMENTATION.


  METHOD get_bangcandoiphatsinh.

*    SELECT
*        CompanyCode,
*        accountingdocument,
*        GLAccount,
*        companycodecurrency,
*        DebitCreditCode,
*        AmountInCompanyCodeCurrency,
*        postingdate
*    FROM I_GLAccountLineItem
*    WHERE CompanyCode  IN @ir_companycode
**      AND AccountingDocument IN @ir_accountingdocument
**      AND FiscalYear   IN @ir_fiscalyear
*      AND PostingDate  IN @ir_postingdate
*
*      AND GLAccount    = '1120101001'
*      AND Ledger = '0L'
*    INTO TABLE @DATA(lt_check).

    SELECT
        companycode,
        glaccount,
        companycodecurrency,
        debitcreditcode,
        SUM( amountincompanycodecurrency ) AS amountincompanycodecurrency
    FROM i_glaccountlineitem
    WHERE companycode  IN @ir_companycode
*      AND AccountingDocument IN @ir_accountingdocument
*      AND FiscalYear   IN @ir_fiscalyear
      AND postingdate  IN @ir_postingdate
      AND glaccount    IN @ir_glaccount
      AND accountingdocument NOT LIKE 'B%'
      AND glaccount   NOT LIKE 'CE%'
      AND glaccount   NOT LIKE '9999999101'
      AND glaccount   NOT LIKE '9999999102'
      AND glaccount   NOT LIKE '0021900000'
      AND glaccount   NOT LIKE '99999999%'
      AND ledger = '0L'
    GROUP BY companycode, glaccount, companycodecurrency, debitcreditcode
    INTO TABLE @DATA(lt_glaccountlineitem).

    DATA: ls_postingdate LIKE LINE OF ir_postingdate,
          lv_startdate   TYPE budat.

    READ TABLE ir_postingdate INTO ls_postingdate INDEX 1.
    IF sy-subrc EQ 0.
      lv_startdate = ls_postingdate-low.
    ENDIF.

    SELECT
        companycode,
        glaccount,
        companycodecurrency,
        SUM( amountincompanycodecurrency ) AS amountincompanycodecurrency
    FROM i_glaccountlineitem
    WHERE companycode  IN @ir_companycode
      AND postingdate  LT @lv_startdate
      AND glaccount    IN @ir_glaccount
        AND glaccount   NOT LIKE 'CE%'
      AND ledger = '0L'
    GROUP BY companycode, glaccount, companycodecurrency
    INTO TABLE @DATA(lt_startbalancegl).

***Sort
    SORT lt_startbalancegl BY companycode glaccount .
    SORT lt_glaccountlineitem BY companycode glaccount debitcreditcode ASCENDING.

    DATA: ls_bangcandoiphatsinh LIKE LINE OF e_bangcandoiphatsinh.

    READ TABLE ir_postingdate INDEX 1 INTO DATA(ls_date).

    DATA(lv_low) = |{ ls_date-low+6(2) }/{ ls_date-low+4(2) }/{ ls_date-low+0(4) }|.
    DATA(lv_high) = |{ ls_date-high+6(2) }/{ ls_date-high+4(2) }/{ ls_date-high+0(4) }|.

    LOOP AT lt_glaccountlineitem INTO DATA(ls_glaccountlineitem).
      MOVE-CORRESPONDING ls_glaccountlineitem TO ls_bangcandoiphatsinh.
      IF ls_glaccountlineitem-debitcreditcode = 'S'.
        ls_bangcandoiphatsinh-debitbalanceofreportingperiod = ls_glaccountlineitem-amountincompanycodecurrency.
      ELSE.
        ls_bangcandoiphatsinh-creditbalanceofreportingperiod = ls_glaccountlineitem-amountincompanycodecurrency.
      ENDIF.

      ls_bangcandoiphatsinh-postingdatefrom = ls_postingdate-low.
      ls_bangcandoiphatsinh-postingdateto = ls_postingdate-high.

      zcl_jp_common_core=>get_companycode_details(
        EXPORTING
          i_companycode = ls_glaccountlineitem-companycode
        IMPORTING
          o_companycode = DATA(ls_companycode)
      ).

      ls_bangcandoiphatsinh-companycodename = ls_companycode-companycodename.
      ls_bangcandoiphatsinh-companycodeaddr = ls_companycode-companycodeaddr.

      CLEAR: ls_companycode.

      IF ls_date-low IS NOT INITIAL AND ls_date-high IS NOT INITIAL.
        ls_bangcandoiphatsinh-periodtext = |Từ ngày { lv_low }  đến ngày { lv_high }|.
      ENDIF.

      IF ls_date-high IS INITIAL.
        ls_bangcandoiphatsinh-periodtext = |Ngày { lv_low }|.
      ENDIF.

      IF ls_date-low IS INITIAL.
        ls_bangcandoiphatsinh-periodtext = |Đến ngày { lv_high }|.
      ENDIF.

      COLLECT ls_bangcandoiphatsinh INTO e_bangcandoiphatsinh.
      CLEAR: ls_bangcandoiphatsinh.
    ENDLOOP.

    LOOP AT e_bangcandoiphatsinh ASSIGNING FIELD-SYMBOL(<fs_bangcandoiphatsinh>).
      READ TABLE lt_startbalancegl INTO DATA(ls_startbalancegl) WITH KEY companycode = <fs_bangcandoiphatsinh>-companycode
          glaccount = <fs_bangcandoiphatsinh>-glaccount
          BINARY SEARCH.
      IF sy-subrc EQ 0.

      ELSE.

      ENDIF.

      <fs_bangcandoiphatsinh>-startingbalanceincompanycode = ls_startbalancegl-amountincompanycodecurrency.
      <fs_bangcandoiphatsinh>-endingbalanceincompanycode = ls_startbalancegl-amountincompanycodecurrency
          + <fs_bangcandoiphatsinh>-debitbalanceofreportingperiod
          + <fs_bangcandoiphatsinh>-creditbalanceofreportingperiod .

      SELECT SINGLE glaccountlongname FROM i_glaccounttextincompanycode
      WHERE companycode = @<fs_bangcandoiphatsinh>-companycode
      AND glaccount = @<fs_bangcandoiphatsinh>-glaccount
      AND language = 'E'
      INTO @<fs_bangcandoiphatsinh>-glaccountname.

*      SELECT SINGLE PlainLongText
*   FROM tbkkc_glacc_text
*   WHERE TextObjectCategory = 'SKB1'
*     AND TextObjectType     = '0001'
*     AND TextObjectKey      = @<fs_bangcandoiphatsinh>-GLAccount
*     AND Language           = 'E'
*   INTO @<fs_bangcandoiphatsinh>-GLAccountName.

      CLEAR: ls_startbalancegl.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_phieuketoan.
    DATA: ls_phieuketoan       TYPE zjp_c_phieuketoan,
          ls_phieuketoan_items TYPE zjp_c_phieuketoan_items.

    DATA: lt_phieuketoan       TYPE tt_phieuketoan,
          lt_phieuketoan_items TYPE tt_phieuketoan_items.

    SELECT
          companycode ,
          accountingdocument ,
          fiscalyear ,
          ledgergllineitem ,

          postingdate ,
          documentdate ,
          accountingdocumenttype ,

          glaccount ,
          documentitemtext ,
          debitcreditcode ,

          companycodecurrency ,
          amountincompanycodecurrency ,

          transactioncurrency ,
          amountintransactioncurrency ,

          customer ,
          supplier,

          accountingdoccreatedbyuser,
          creationdate ,
          creationdatetime,

          isreversal,
          isreversed
    FROM i_glaccountlineitem

    WHERE companycode IN @ir_companycode
      AND accountingdocument IN @ir_accountingdocument
      AND fiscalyear IN @ir_fiscalyear
      AND postingdate IN @ir_postingdate
      AND documentdate IN @ir_documentdate
      AND accountingdocumenttype IN @ir_documenttype
      AND isreversal EQ ''
      AND isreversed EQ ''
      AND ledger = '0L'
      AND ledgergllineitem IN @ir_documentitem
      INTO TABLE @DATA(lt_data).

    SORT lt_data BY companycode accountingdocument fiscalyear postingdate documentdate ledgergllineitem ASCENDING.

    DATA: lv_index TYPE int4.

    DATA: lv_ktt TYPE string,
          lv_nlp TYPE string.

*----Chân ký ------------
    READ TABLE ir_accountant INDEX 1 INTO DATA(ls_range).
    lv_ktt = ls_range-low.

    READ TABLE ir_createby INDEX 1 INTO ls_range.
    lv_nlp = ls_range-low.
*------------------------

    LOOP AT lt_data INTO DATA(ls_data).

      IF ls_data-transactioncurrency NE ls_data-companycodecurrency.
        SELECT SINGLE absoluteexchangerate FROM i_journalentry
        WHERE companycode = @ls_data-companycode
          AND accountingdocument = @ls_data-accountingdocument
          AND fiscalyear = @ls_data-fiscalyear
        INTO @DATA(lv_exchangerate).

      ENDIF.

      READ TABLE lt_phieuketoan ASSIGNING FIELD-SYMBOL(<lfs_phieuketoan>) WITH KEY companycode = ls_data-companycode
           accountingdocument = ls_data-accountingdocument
           fiscalyear = ls_data-fiscalyear.
      IF sy-subrc NE 0.
        ls_phieuketoan-companycode = ls_data-companycode.
        ls_phieuketoan-accountingdocument = ls_data-accountingdocument.
        ls_phieuketoan-fiscalyear = ls_data-fiscalyear.
        ls_phieuketoan-postingdate = ls_data-postingdate.
        ls_phieuketoan-documentdate = ls_data-documentdate.

        IF ( ls_data-debitcreditcode = 'S' AND ls_data-amountincompanycodecurrency < 0 )

        OR ( ls_data-debitcreditcode = 'H' AND ls_data-amountincompanycodecurrency > 0 ).

          ls_phieuketoan-isnegativeposting = 'X'.

        ENDIF.

        IF lv_exchangerate IS NOT INITIAL.
          ls_phieuketoan-absoluteexchangerate = lv_exchangerate * 1000.
        ENDIF.

        ls_phieuketoan-accountingdocumenttype = ls_data-accountingdocumenttype.
        ls_phieuketoan-transactioncurrency = ls_data-transactioncurrency.
        ls_phieuketoan-companycodecurrency = ls_data-companycodecurrency.

        ls_phieuketoan-customer = ls_data-customer.
        ls_phieuketoan-supplier = ls_data-supplier.

        ls_phieuketoan-creationbyuser = ls_data-accountingdoccreatedbyuser.
        ls_phieuketoan-creationdate = ls_data-creationdate.
        ls_phieuketoan-creationdatetime = ls_data-creationdatetime.

**---------Chân ký--------
        ls_phieuketoan-accountant = lv_ktt.
        ls_phieuketoan-createby = lv_nlp.

        APPEND ls_phieuketoan TO lt_phieuketoan.
        CLEAR: ls_phieuketoan.
      ELSE.
        lv_index = sy-tabix.
        IF <lfs_phieuketoan>-customer IS INITIAL AND <lfs_phieuketoan>-supplier IS INITIAL.
          <lfs_phieuketoan>-customer = ls_data-customer.
          <lfs_phieuketoan>-supplier = ls_data-supplier.
        ENDIF.
      ENDIF.

      ls_phieuketoan_items-companycode = ls_data-companycode.
      ls_phieuketoan_items-accountingdocument = ls_data-accountingdocument.
      ls_phieuketoan_items-fiscalyear = ls_data-fiscalyear.
      ls_phieuketoan_items-accountingdocumenttype = ls_data-accountingdocumenttype.

      ls_phieuketoan_items-postingdate = ls_data-postingdate.
      ls_phieuketoan_items-documentdate = ls_data-documentdate.

      ls_phieuketoan_items-legderglitem = ls_data-ledgergllineitem.

      ls_phieuketoan_items-glaccount = ls_data-glaccount.
      ls_phieuketoan_items-documentitemtext = ls_data-documentitemtext.

      IF ls_phieuketoan_items-documentitemtext IS INITIAL.
        SELECT SINGLE accountingdocumentheadertext FROM i_journalentry
        WHERE companycode = @ls_data-companycode
          AND accountingdocument = @ls_data-accountingdocument
          AND fiscalyear = @ls_data-fiscalyear
        INTO @ls_phieuketoan_items-documentitemtext.
      ENDIF.

      IF ( ls_data-debitcreditcode = 'S' AND ls_data-amountincompanycodecurrency < 0 )

      OR ( ls_data-debitcreditcode = 'H' AND ls_data-amountincompanycodecurrency > 0 ).

        ls_phieuketoan_items-isnegativeposting = 'X'.

      ENDIF.

      IF ls_phieuketoan_items-isnegativeposting = '' AND ls_data-debitcreditcode = 'H'.
        ls_data-amountincompanycodecurrency = abs( ls_data-amountincompanycodecurrency ).
        ls_data-amountintransactioncurrency = abs( ls_data-amountintransactioncurrency ).
      ELSEIF ls_phieuketoan_items-isnegativeposting = 'X' AND ls_data-debitcreditcode = 'H'.
        ls_data-amountincompanycodecurrency =  ls_data-amountincompanycodecurrency  * -1.
        ls_data-amountintransactioncurrency =  ls_data-amountintransactioncurrency  * -1.
      ENDIF.

      IF lv_exchangerate IS NOT INITIAL.
        ls_phieuketoan_items-absoluteexchangerate = lv_exchangerate * 1000.
      ENDIF.

      ls_phieuketoan_items-transactioncurrency = ls_data-transactioncurrency.
      ls_phieuketoan_items-companycodecurrency = ls_data-companycodecurrency.

      IF ls_data-debitcreditcode = 'S'.
        ls_phieuketoan_items-debitamountincompanycode = ls_data-amountincompanycodecurrency.
        ls_phieuketoan_items-debitamountintransaction = ls_data-amountintransactioncurrency.
      ELSE.
        ls_phieuketoan_items-creditamountincompanycode = ls_data-amountincompanycodecurrency .
        ls_phieuketoan_items-creditamountintransaction = ls_data-amountintransactioncurrency .
      ENDIF.

      ls_phieuketoan_items-debitcreditcode = ls_data-debitcreditcode.

      ls_phieuketoan_items-customer = ls_data-customer.
      ls_phieuketoan_items-supplier = ls_data-supplier.

      APPEND ls_phieuketoan_items TO lt_phieuketoan_items.
      CLEAR: ls_phieuketoan_items.

      CLEAR: lv_exchangerate.

    ENDLOOP.

    IF ir_customer IS NOT INITIAL.
      DELETE lt_phieuketoan WHERE customer NOT IN ir_customer.
    ENDIF.

    IF ir_supplier IS NOT INITIAL.
      DELETE lt_phieuketoan WHERE supplier NOT IN ir_supplier.
    ENDIF.

    MOVE-CORRESPONDING lt_phieuketoan TO e_phieuketoan.
    MOVE-CORRESPONDING lt_phieuketoan_items TO e_phieuketoan_items.

  ENDMETHOD.


  METHOD get_soquytienmat.

    DATA: ls_return TYPE bapiret2.
    DATA(lo_common_app) = zcl_jp_common_core=>get_instance( ).
    DATA: lv_bukrs TYPE bukrs.

    LOOP AT ir_companycode INTO DATA(ls_range).
      lv_bukrs = ls_range-low.
      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
        ID 'ACTVT' FIELD '03'
        ID 'BUKRS' FIELD lv_bukrs.
      IF sy-subrc NE 0.
        APPEND VALUE #(
             type       = 'E' "bapi_mtype  char(1) Message type: S Success, E Error, W Warning, I Info, A Abort
             id         = 'ZMMFIRP' "symsgid char(20)    Message Class
             number     = '001' "symsgno numc(3) Message Number
             message    = |You are not Authorization CompanyCode { lv_bukrs }| "bapi_msg    char(220)   Message Text
*                    Column log_no   balognr char(20)    Application Log: Log Number
*                    Column log_msg_no   balmnr  numc(6) Application Log: Internal Message Serial Number
             message_v1 = |{ lv_bukrs }|   "symsgv  char(50)    Message Variable
*                    Column message_v2   symsgv  char(50)    Message Variable
*                    Column message_v3   symsgv  char(50)    Message Variable
*                    Column message_v4   symsgv  char(50)    Message Variable
        ) TO e_return.
*              RETURN.
      ENDIF.
    ENDLOOP.

    IF e_return IS NOT INITIAL.
      RETURN.
    ENDIF.

    SELECT
        a~companycode,
        a~accountingdocument,
        a~fiscalyear,
        a~ledgergllineitem,
        a~accountingdocumentitem,
        a~postingdate,
        a~documentdate,
        a~customer,
        a~supplier,
        a~glaccount,
        a~companycodecurrency,
        a~transactioncurrency,
        a~documentitemtext,
        a~debitcreditcode,
*        a~isnegativeposting,
        a~amountincompanycodecurrency,
        a~amountintransactioncurrency,
        b~documentreferenceid,
        b~accountingdocumenttype,
        b~reversedocument,
        b~reversedocumentfiscalyear,
        b~accountingdoccreatedbyuser,
        b~accountingdocumentcreationdate,
        b~creationtime
    FROM i_glaccountlineitem AS a INNER JOIN i_journalentry AS b
        ON a~companycode = b~companycode
        AND a~accountingdocument = b~accountingdocument
        AND a~fiscalyear = b~fiscalyear
    WHERE a~companycode  IN @ir_companycode
      AND a~accountingdocument IN @ir_accountingdocument
      AND a~postingdate  IN @ir_postingdate
      AND a~documentdate IN @ir_documentdate
      AND a~glaccount    IN @ir_glaccount
      AND a~fiscalyear   IN @ir_fiscalyear
      AND (  a~customer IN @ir_businesspartner OR a~supplier IN @ir_businesspartner )
      AND a~ledger = '0L'
      AND a~glaccount LIKE '111%'
    INTO TABLE @DATA(lt_data).

***""" Message Lỗi
    IF sy-subrc NE 0.
      ls_return-type = 'E'.
      ls_return-message = 'Không có dữ liệu'.
*      APPEND ls_return TO e_return.
*      EXIT.
    ENDIF.

    SORT lt_data BY companycode accountingdocument fiscalyear ASCENDING.

    DATA: lv_index TYPE sy-tabix.
    DATA: lt_data_temp LIKE lt_data.
    lt_data_temp = lt_data.

*    LOOP AT lt_data INTO DATA(ls_data) WHERE ReverseDocument IS NOT INITIAL.
*      lv_index = sy-tabix.
*      READ TABLE lt_data INTO DATA(ls_data_temp) WITH KEY CompanyCode = ls_data-CompanyCode
*          AccountingDocument = ls_data-ReverseDocument
*          FiscalYear = ls_data-ReverseDocumentFiscalYear BINARY SEARCH.
*      IF sy-subrc EQ 0.
*        DELETE lt_data INDEX lv_index.
*
*        READ TABLE lt_data_temp TRANSPORTING NO FIELDS WITH KEY CompanyCode = ls_data_temp-CompanyCode
*        AccountingDocument = ls_data_temp-AccountingDocument
*        FiscalYear = ls_data_temp-FiscalYear BINARY SEARCH.
*        IF sy-subrc EQ 0.
*        ELSE.
*          lv_index = sy-tabix.
*          IF lv_index = 0.
*            INSERT ls_data_temp INTO lt_data_temp INDEX 1.
*          ELSE.
*            INSERT ls_data_temp INTO lt_data_temp INDEX lv_index.
*          ENDIF.
*        ENDIF.
*      ELSE.
*        READ TABLE lt_data_temp TRANSPORTING NO FIELDS WITH KEY CompanyCode = ls_data-CompanyCode
*        AccountingDocument = ls_data-AccountingDocument
*        FiscalYear = ls_data-FiscalYear BINARY SEARCH.
*        IF sy-subrc EQ 0.
*          DELETE lt_data INDEX lv_index.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.

    LOOP AT lt_data INTO DATA(ls_data) WHERE reversedocument IS NOT INITIAL.
      lv_index = sy-tabix.
      READ TABLE lt_data_temp INTO DATA(ls_data_temp) WITH KEY companycode = ls_data-companycode
          accountingdocument = ls_data-reversedocument
          fiscalyear = ls_data-reversedocumentfiscalyear BINARY SEARCH.
      IF sy-subrc EQ 0.
        DELETE lt_data INDEX lv_index.
      ELSE.
      ENDIF.
    ENDLOOP.

*    SELECT * FROM firud_cf_off_acc
*    WITH PRIVILEGED ACCESS
*    into table @data(lt_firud_cf_off_acc).

    SELECT
        a~companycode,
        a~accountingdocument,
        a~fiscalyear,
        a~ledgergllineitem,
        a~accountingdocumentitem,
        a~postingdate,
        a~documentdate,
        a~glaccount,
        a~financialaccounttype,
        a~debitcreditcode,
        b~documentreferenceid,
        a~customer,
        a~supplier,
        a~offsettingaccount,
        a~offsettingaccounttype,
        a~offsettingledgergllineitem,
        a~amountincompanycodecurrency,
        a~amountintransactioncurrency
    FROM i_glaccountlineitem AS a INNER JOIN i_journalentry AS b
        ON a~companycode = b~companycode
        AND a~accountingdocument = b~accountingdocument
        AND a~fiscalyear = b~fiscalyear
    FOR ALL ENTRIES IN @lt_data
    WHERE a~companycode = @lt_data-companycode
      AND a~accountingdocument = @lt_data-accountingdocument
      AND a~fiscalyear = @lt_data-fiscalyear
      AND a~ledger = '0L'
      AND a~offsettingledgergllineitem NE ''
    INTO TABLE @DATA(lt_offsettingaccount).

    SORT lt_offsettingaccount BY companycode accountingdocument fiscalyear offsettingledgergllineitem ASCENDING.

    SELECT
          a~bukrs,
          a~gjahr,
          a~belnr,
          a~docln,
          a~offs_item,
          b~glaccount,
          b~customer,
          b~supplier,
          c~documentreferenceid,
          a~drcrk,
          a~racct,
          a~lokkt,
          a~ktop2,
          a~blart,
          a~budat,
          a~rmvct,
          a~mwskz,
          a~rfarea,
          a~buzei,
          a~hsl,
          a~rhcur,
          a~ksl,
          a~rkcur
     FROM zfirud_cf_off AS a
     INNER JOIN i_glaccountlineitem AS b ON a~bukrs = b~companycode
                                        AND a~docln = b~ledgergllineitem
                                        AND a~belnr = b~accountingdocument
                                        AND a~gjahr = b~fiscalyear
                                        AND a~rldnr = b~ledger
     INNER JOIN i_journalentry AS c ON a~bukrs = c~companycode
                                   AND a~belnr = c~accountingdocument
                                   AND a~gjahr = c~fiscalyear
    FOR ALL ENTRIES IN @lt_data
    WHERE a~bukrs = @lt_data-companycode
      AND a~belnr = @lt_data-accountingdocument
      AND a~gjahr = @lt_data-fiscalyear
      AND b~ledger = '0L'
      AND a~rldnr = '0L'
    INTO TABLE @DATA(lt_firud_cf_off).


***""" Tính số dư đầu kỳ
    lo_common_app->get_glaccount_balance(
      EXPORTING
        ir_companycode = ir_companycode
        ir_glaccount   = ir_glaccount
        ir_date        = ir_postingdate
      IMPORTING
        o_startbalance = DATA(lt_startbalance)
        o_endbalance   = DATA(lt_endbalance)
    ).

    SORT lt_startbalance BY companycode glaccount ASCENDING.
    SORT lt_endbalance BY companycode glaccount ASCENDING.

    READ TABLE lt_startbalance INTO DATA(ls_startbalance) INDEX 1.

***""" Sort data.
    SORT lt_data BY companycode fiscalyear postingdate documentdate accountingdocument ledgergllineitem ASCENDING.
    SORT lt_offsettingaccount BY companycode accountingdocument fiscalyear offsettingledgergllineitem ASCENDING.
    SORT lt_firud_cf_off BY bukrs belnr gjahr offs_item ASCENDING.
***"""------------------------------------------------------------------"""***
    DATA: ls_soquytienmat TYPE zjp_c_soquytienmat,
          lv_stt          TYPE int4 VALUE IS INITIAL.

    DATA: wa_document TYPE zst_document_info.
    DATA: lv_debitcocode  TYPE dmbtr,
          lv_creditcocode TYPE dmbtr,
          lv_debittrans   TYPE dmbtr,
          lv_credittrans  TYPE dmbtr.

    CLEAR: lv_index.

    READ TABLE ir_postingdate INDEX 1 INTO DATA(ls_date).

    DATA(lv_low) = |{ ls_date-low+6(2) }/{ ls_date-low+4(2) }/{ ls_date-low+0(4) }|.
    DATA(lv_high) = |{ ls_date-high+6(2) }/{ ls_date-high+4(2) }/{ ls_date-high+0(4) }|.

    LOOP AT lt_data INTO ls_data.

      lv_stt = lv_stt + 1.

      lo_common_app->get_companycode_details(
        EXPORTING
          i_companycode = ls_data-companycode
        IMPORTING
          o_companycode = DATA(ls_companycode)
      ).

      ls_soquytienmat-companycodename = ls_companycode-companycodename.
      ls_soquytienmat-companycodeaddr = ls_companycode-companycodeaddr.

      CLEAR: ls_companycode.

      lo_common_app->get_glaccount_details(
        EXPORTING
          companycode = ls_data-companycode
          glaccount   = ls_data-glaccount
        IMPORTING
          o_glaccount = DATA(ls_glaccount)
      ).

      ls_soquytienmat-glaccoutname = ls_data-glaccount && ` - ` && ls_glaccount-glaccountname.

      IF ls_date-low IS NOT INITIAL AND ls_date-high IS NOT INITIAL.
        ls_soquytienmat-periodtext = |Từ ngày { lv_low }  đến ngày { lv_high }|.
      ENDIF.

      IF ls_date-high IS INITIAL.
        ls_soquytienmat-periodtext = |Ngày { lv_low }|.
      ENDIF.

      IF ls_date-low IS INITIAL.
        ls_soquytienmat-periodtext = |Đến ngày { lv_high }|.
      ENDIF.

      ls_soquytienmat-startingbalanceincocode = ls_startbalance-amountincompanycode.
      ls_soquytienmat-startingbalanceintrans = ls_startbalance-amountintransaction.

      ls_soquytienmat-stt                    = lv_stt.
      ls_soquytienmat-companycode            = ls_data-companycode.
      ls_soquytienmat-accountingdocument     = ls_data-accountingdocument.
      ls_soquytienmat-fiscalyear             = ls_data-fiscalyear.
      ls_soquytienmat-accountingdocumentitem = ls_data-accountingdocumentitem.
      ls_soquytienmat-postingdate            = ls_data-postingdate.
      ls_soquytienmat-documentdate           = ls_data-documentdate.

      ls_soquytienmat-accountingdocumenttype = ls_data-accountingdocumenttype.
      ls_soquytienmat-glaccount              = ls_data-glaccount.

      ls_soquytienmat-debitcreditcode        = ls_data-debitcreditcode.
      ls_soquytienmat-companycodecurrency    = ls_data-companycodecurrency.
      ls_soquytienmat-transactioncurrency    = ls_data-transactioncurrency.

      wa_document-companycode                = ls_data-companycode.
      wa_document-accountingdocument         = ls_data-accountingdocument.
      wa_document-fiscalyear                 = ls_data-fiscalyear.

      IF ls_data-customer IS NOT INITIAL.
*        wa_document-customer = ls_data-Customer.
*
*        lo_common_app->get_businesspartner_details(
*            EXPORTING
*            i_document = wa_document
*            IMPORTING
*            o_BPdetails = DATA(ls_BP_detail)
*        ).
*
*        ls_soquytienmat-Doituong = ls_BP_detail-BPname.

      ELSEIF ls_data-supplier IS NOT INITIAL.
*        wa_document-supplier = ls_data-Supplier.
*
*        lo_common_app->get_businesspartner_details(
*            EXPORTING
*            i_document = wa_document
*            IMPORTING
*            o_BPdetails = ls_BP_detail
*        ).
*        ls_soquytienmat-Doituong = ls_BP_detail-BPname.
      ENDIF.

      ls_soquytienmat-businesspartner = wa_document-customer.
      ls_soquytienmat-diengiai        = ls_data-documentitemtext.

*      ls_soquytienmat-IsNegativePosting = ls_data-IsNegativePosting.

      ls_soquytienmat-creationuser    = ls_data-accountingdoccreatedbyuser.
      ls_soquytienmat-creationdate    = ls_data-accountingdocumentcreationdate.
      ls_soquytienmat-creationtime    = ls_data-creationtime.

      IF ( ls_data-debitcreditcode = 'S' AND ls_data-amountincompanycodecurrency < 0 )
      OR ( ls_data-debitcreditcode = 'H' AND ls_data-amountintransactioncurrency > 0 ).
        ls_soquytienmat-isnegativeposting = 'X'.
      ENDIF.

      READ TABLE lt_offsettingaccount INTO DATA(ls_offsettingaccount)
      WITH KEY companycode = ls_data-companycode
               accountingdocument = ls_data-accountingdocument
               fiscalyear = ls_data-fiscalyear
               offsettingledgergllineitem = ls_data-ledgergllineitem BINARY SEARCH.
      IF sy-subrc EQ 0.
        ls_soquytienmat-offsettingaccount = ls_offsettingaccount-glaccount.
        IF ls_offsettingaccount-customer IS NOT INITIAL.
          ls_soquytienmat-businesspartner = ls_offsettingaccount-customer.
          wa_document-customer = ls_offsettingaccount-customer.

          lo_common_app->get_businesspartner_details(
            EXPORTING
              i_document  = wa_document
            IMPORTING
              o_bpdetails = DATA(ls_bp_detail)
          ).

          ls_soquytienmat-doituong = ls_bp_detail-bpname.
        ELSE.
          ls_soquytienmat-businesspartner = ls_offsettingaccount-supplier.
          wa_document-supplier = ls_offsettingaccount-supplier.

          lo_common_app->get_businesspartner_details(
            EXPORTING
              i_document  = wa_document
            IMPORTING
              o_bpdetails = ls_bp_detail
          ).
          ls_soquytienmat-doituong = ls_bp_detail-bpname.
        ENDIF.

        IF ls_data-debitcreditcode = 'S'.
          ls_soquytienmat-debitamountincocode =  abs( ls_offsettingaccount-amountincompanycodecurrency ).
          ls_soquytienmat-debitamountintrans =  abs( ls_offsettingaccount-amountintransactioncurrency ).

          ls_soquytienmat-sohieuctthu = ls_offsettingaccount-documentreferenceid.
          ls_soquytienmat-soctthu = ls_offsettingaccount-accountingdocument.

          IF ls_soquytienmat-isnegativeposting IS NOT INITIAL.
            ls_soquytienmat-debitamountincocode = ls_soquytienmat-debitamountincocode * -1.
            ls_soquytienmat-debitamountintrans = ls_soquytienmat-debitamountintrans * -1.
          ENDIF.
        ELSE.
          ls_soquytienmat-creditamountincocode =  ls_offsettingaccount-amountincompanycodecurrency .
          ls_soquytienmat-creditamountintrans =  ls_offsettingaccount-amountintransactioncurrency .

          ls_soquytienmat-sohieuctchi = ls_offsettingaccount-documentreferenceid.
          ls_soquytienmat-soctchi = ls_offsettingaccount-accountingdocument.
        ENDIF.

        ls_soquytienmat-balanceincocode = ls_soquytienmat-debitamountincocode - ls_soquytienmat-creditamountincocode
                                          + ls_startbalance-amountincompanycode.
        ls_soquytienmat-balanceintrans =  ls_soquytienmat-debitamountintrans - ls_soquytienmat-creditamountintrans
                                          + ls_startbalance-amountintransaction.

        ls_startbalance-amountincompanycode =  ls_soquytienmat-balanceincocode.
        ls_startbalance-amountintransaction =  ls_soquytienmat-balanceintrans.

        APPEND ls_soquytienmat TO e_soquytienmat.

        CLEAR: ls_soquytienmat, wa_document.

        CONTINUE.
      ELSE.
        READ TABLE lt_firud_cf_off TRANSPORTING NO FIELDS WITH KEY bukrs = ls_data-companycode
          belnr = ls_data-accountingdocument
          gjahr = ls_data-fiscalyear
          offs_item = ls_data-ledgergllineitem BINARY SEARCH.
        IF sy-subrc EQ 0.
          lv_index = sy-tabix.
          LOOP AT lt_firud_cf_off INTO DATA(ls_firud_cf_off) FROM lv_index.
            IF NOT ( ls_firud_cf_off-bukrs = ls_data-companycode AND
             ls_firud_cf_off-belnr = ls_data-accountingdocument AND
             ls_firud_cf_off-gjahr = ls_data-fiscalyear AND
             ls_firud_cf_off-offs_item = ls_data-ledgergllineitem
             ) .
              EXIT.
            ENDIF.
            ls_soquytienmat-offsettingaccount = ls_firud_cf_off-glaccount.
            IF ls_firud_cf_off-customer IS NOT INITIAL.
              ls_soquytienmat-businesspartner = ls_firud_cf_off-customer.
              wa_document-customer = ls_firud_cf_off-customer.

              lo_common_app->get_businesspartner_details(
                EXPORTING
                  i_document  = wa_document
                IMPORTING
                  o_bpdetails = ls_bp_detail
              ).

              ls_soquytienmat-doituong = ls_bp_detail-bpname.
            ELSE.
              ls_soquytienmat-businesspartner = ls_firud_cf_off-supplier.
              wa_document-supplier = ls_firud_cf_off-supplier.

              lo_common_app->get_businesspartner_details(
                EXPORTING
                  i_document  = wa_document
                IMPORTING
                  o_bpdetails = ls_bp_detail
              ).
              ls_soquytienmat-doituong = ls_bp_detail-bpname.
            ENDIF.

            IF ls_data-debitcreditcode = 'S'.
              ls_soquytienmat-debitamountincocode = abs( ls_firud_cf_off-hsl ).
              ls_soquytienmat-debitamountintrans = abs( ls_firud_cf_off-ksl ).

              IF ls_soquytienmat-isnegativeposting IS NOT INITIAL.
                ls_soquytienmat-debitamountincocode = ls_soquytienmat-debitamountincocode * -1.
                ls_soquytienmat-debitamountintrans = ls_soquytienmat-debitamountintrans * -1.
              ENDIF.

              ls_soquytienmat-sohieuctthu = ls_firud_cf_off-documentreferenceid.
              ls_soquytienmat-soctthu = ls_firud_cf_off-belnr.
            ELSE.
              ls_soquytienmat-creditamountincocode = abs( ls_firud_cf_off-hsl ).
              ls_soquytienmat-creditamountintrans = abs( ls_firud_cf_off-ksl ).

              ls_soquytienmat-sohieuctchi = ls_firud_cf_off-documentreferenceid.
              ls_soquytienmat-soctchi = ls_firud_cf_off-belnr.
            ENDIF.

            ls_soquytienmat-balanceincocode = ls_soquytienmat-debitamountincocode - ls_soquytienmat-creditamountincocode
                                          + ls_startbalance-amountincompanycode.
            ls_soquytienmat-balanceintrans =  ls_soquytienmat-debitamountintrans - ls_soquytienmat-creditamountintrans
                                          + ls_startbalance-amountintransaction.

            ls_startbalance-amountincompanycode =  ls_soquytienmat-balanceincocode.
            ls_startbalance-amountintransaction =  ls_soquytienmat-balanceintrans.

            APPEND ls_soquytienmat TO e_soquytienmat.
            CLEAR: ls_soquytienmat, wa_document.
          ENDLOOP.

          CLEAR: ls_soquytienmat, wa_document.
          CONTINUE.
        ENDIF.
      ENDIF.

      CLEAR: ls_bp_detail.

      "S - Debit = Nợ <-> Thu / H - Credit = Có <-> Chi
*      IF ls_data-IsNegativePosting IS NOT INITIAL.
*        IF ls_data-DebitCreditCode = 'S'.
*          ls_soquytienmat-CreditAmountInCoCode = ls_data-AbsoluteAmountInCoCodeCrcy * -1.
*          ls_soquytienmat-CreditAmountInTrans = ls_data-AbsoluteAmountInTransacCrcy * -1.
*
*          ls_soquytienmat-sohieuCTchi = ls_data-DocumentReferenceID.
*        ELSE.
*          ls_soquytienmat-DebitAmountInCoCode = ls_data-AbsoluteAmountInCoCodeCrcy * -1.
*          ls_soquytienmat-DebitAmountInTrans = ls_data-AbsoluteAmountInTransacCrcy * -1.
*
*          ls_soquytienmat-sohieuCTthu = ls_data-DocumentReferenceID.
*        ENDIF.
*
*        ls_soquytienmat-BalanceInCoCode = ls_soquytienmat-DebitAmountInCoCode + ls_soquytienmat-CreditAmountInCoCode
*                       + ls_startbalance-amountincompanycode.
*        ls_soquytienmat-BalanceInTrans = ls_soquytienmat-DebitAmountInTrans + ls_soquytienmat-CreditAmountInTrans
*                       + ls_startbalance-amountintransaction.
*      ELSE.
*        IF ls_data-DebitCreditCode = 'S'.
*          ls_soquytienmat-DebitAmountInCoCode = ls_data-AbsoluteAmountInCoCodeCrcy.
*          ls_soquytienmat-DebitAmountInTrans = ls_data-AbsoluteAmountInTransacCrcy.
*
*          ls_soquytienmat-sohieuCTthu = ls_data-DocumentReferenceID.
*        ELSE.
*          ls_soquytienmat-CreditAmountInCoCode = ls_data-AbsoluteAmountInCoCodeCrcy.
*          ls_soquytienmat-CreditAmountInTrans = ls_data-AbsoluteAmountInTransacCrcy.
*
*          ls_soquytienmat-sohieuCTchi = ls_data-DocumentReferenceID.
*        ENDIF.
*
*        ls_soquytienmat-BalanceInCoCode = ls_soquytienmat-DebitAmountInCoCode - ls_soquytienmat-CreditAmountInCoCode
*                       + ls_startbalance-amountincompanycode.
*        ls_soquytienmat-BalanceInTrans = ls_soquytienmat-DebitAmountInTrans - ls_soquytienmat-CreditAmountInTrans
*                       + ls_startbalance-amountintransaction.
*      ENDIF.

      IF ls_data-debitcreditcode = 'S'.
        ls_soquytienmat-debitamountincocode = ls_data-amountincompanycodecurrency.
        ls_soquytienmat-debitamountintrans = ls_data-amountintransactioncurrency.

        ls_soquytienmat-sohieuctthu = ls_data-documentreferenceid.
        ls_soquytienmat-soctthu = ls_data-accountingdocument.
      ELSE.
        ls_soquytienmat-creditamountincocode = abs( ls_data-amountincompanycodecurrency ).
        ls_soquytienmat-creditamountintrans = abs( ls_data-amountintransactioncurrency ).

        ls_soquytienmat-sohieuctchi = ls_data-documentreferenceid.
        ls_soquytienmat-sohieuctchi = ls_data-accountingdocument.
      ENDIF.

      ls_soquytienmat-balanceincocode = ls_data-amountincompanycodecurrency + ls_startbalance-amountincompanycode.
      ls_soquytienmat-balanceintrans =  ls_data-amountintransactioncurrency + ls_startbalance-amountintransaction.

      "Số dư
*      READ TABLE lt_startbalance ASSIGNING FIELD-SYMBOL(<fs_startbalance>)
*      WITH KEY companycode = ls_soquytienmat-CompanyCode
*               glaccount = ls_soquytienmat-GLAccount BINARY SEARCH.
*      IF sy-subrc EQ 0.

      ls_startbalance-amountincompanycode =  ls_soquytienmat-balanceincocode.
      ls_startbalance-amountintransaction =  ls_soquytienmat-balanceintrans.

*      ENDIF.

      APPEND ls_soquytienmat TO e_soquytienmat.

      CLEAR: ls_soquytienmat, wa_document.

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

          ir_supplier           TYPE zcl_jp_common_core=>tt_ranges,
          ir_customer           TYPE zcl_jp_common_core=>tt_ranges,
          ir_documenttype       TYPE zcl_jp_common_core=>tt_ranges,

          ir_documentitem       TYPE zcl_jp_common_core=>tt_ranges,

          ir_accountant         TYPE zcl_jp_common_core=>tt_ranges,
          ir_createby           TYPE zcl_jp_common_core=>tt_ranges.
    .

    DATA: lt_returns TYPE tt_returns.
    DATA: lo_report_fi TYPE REF TO zcl_jp_get_data_report_fi.

    FREE: lt_returns.

    TRY.

        DATA(lt_req_elements) = io_request->get_requested_elements( ).

        DATA(lt_aggr_element) = io_request->get_aggregation( )->get_aggregated_elements( ).

        DATA(lv_entity_id) = io_request->get_entity_id( ).

        lo_report_fi = NEW #( ).

        DATA(lo_common_app) = zcl_jp_common_core=>get_instance( ).

        lo_common_app->get_fillter_app(
          EXPORTING
            io_request            = io_request
            io_response           = io_response
          IMPORTING
            ir_companycode        = ir_companycode
            ir_accountingdocument = ir_accountingdocument
            ir_fiscalyear         = ir_fiscalyear
            ir_glaccount          = ir_glaccount
            ir_postingdate        = ir_postingdate
            ir_documentdate       = ir_documentdate
*           ir_statussap          = ir_statussap
*           ir_einvoicenumber     = ir_einvoicenumber
*           ir_einvoicetype       = ir_einvoicetype
*           ir_currencytype       = ir_currencytype
*           ir_usertype           = ir_usertype
*           ir_typeofdate         = ir_typeofdate
*           ir_createdbyuser      = ir_createdbyuser
*           ir_enduser            = ir_enduser
*           ir_testrun            = ir_testrun
            ir_accountant         = ir_accountant
            ir_createby           = ir_createby
            ir_businesspartner    = ir_businesspartner
            ir_documenttype       = ir_documenttype
            ir_customer           = ir_customer
            ir_supplier           = ir_supplier
            ir_documentitem       = ir_documentitem
            wa_page_info          = ls_page_info
        ).

        IF ls_page_info-page_size < 0.
          ls_page_info-page_size = 50.
        ENDIF.

        DATA(max_rows) = COND #( WHEN ls_page_info-page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                   ELSE ls_page_info-page_size ).

        max_rows = ls_page_info-page_size + ls_page_info-offset.

        CASE lv_entity_id.

          WHEN 'ZJP_C_SOQUYTIENMAT'.
            lo_report_fi->get_soquytienmat(
              EXPORTING
                ir_companycode        = ir_companycode
                ir_glaccount          = ir_glaccount
                ir_accountingdocument = ir_accountingdocument
                ir_postingdate        = ir_postingdate
                ir_fiscalyear         = ir_fiscalyear
                ir_documentdate       = ir_documentdate
              IMPORTING
                e_soquytienmat        = gt_soquytienmat
                e_return              = lt_returns
            ).

            IF lt_returns IS NOT INITIAL.
              READ TABLE lt_returns INTO DATA(ls_returns) INDEX 1.

*              RAISE EXCEPTION TYPE zcl_jp_get_data_report_fi
*                  MESSAGE ID 'ZMMFIRP'
*                  TYPE ls_returns-type
*                  NUMBER '001'
*                  WITH |{ ls_returns-message }|.
              RAISE EXCEPTION TYPE zcl_jp_get_data_report_fi
                EXPORTING
                  textid = VALUE scx_t100key(
                           msgid = 'ZMMFIRP'
                           msgno = '001'
                           attr1 = ls_returns-message_v1        " -> &1
*                           attr2 = ls_returns-message   " -> &2 (tuỳ chọn)
                         ).
              RETURN.

            ENDIF.

            DATA: lt_soquytienmat TYPE tt_soquytienmat.

*        LOOP AT gt_soquytienmat INTO DATA(ls_soquytienmat).
*          IF sy-tabix > ls_page_info-offset.
*            IF sy-tabix > max_rows.
*              EXIT.
*            ELSE.
*              APPEND ls_soquytienmat TO lt_soquytienmat.
*            ENDIF.
*          ENDIF.
*        ENDLOOP.


            IF io_request->is_total_numb_of_rec_requested( ).
              io_response->set_total_number_of_records( lines( gt_soquytienmat ) ).
            ENDIF.

            IF io_request->is_data_requested( ).
*          io_response->set_data( lt_soquytienmat ).
              io_response->set_data( gt_soquytienmat ).
            ENDIF.

          WHEN 'ZJP_C_BANGCANDOIPHATSINH'.

            TRY.
                DATA(lr_ranges) = ls_page_info-ro_filter->get_as_ranges( ).
              CATCH cx_rap_query_filter_no_range.
                "handle exception
            ENDTRY.
            READ TABLE lr_ranges WITH KEY  name = 'SUBLEVEL' INTO DATA(ls_ranges).
            IF sy-subrc IS INITIAL.
              READ TABLE ls_ranges-range INDEX 1 INTO DATA(ls_sublevel).
            ENDIF.

            lo_report_fi->get_bangcandoiphatsinh(
              EXPORTING
                ir_companycode        = ir_companycode
                ir_glaccount          = ir_glaccount
                ir_accountingdocument = ir_accountingdocument
                ir_postingdate        = ir_postingdate
                ir_fiscalyear         = ir_fiscalyear
                ir_documentdate       = ir_documentdate
              IMPORTING
                e_bangcandoiphatsinh  = gt_bangcandoiphatsinh
                e_return              = lt_returns
            ).
            DATA: lt_bangcandoiphatsinh TYPE tt_bangcandoiphatsinh.

            IF ls_sublevel-low IS NOT INITIAL.
              SELECT * FROM ztb_sub_level
                WHERE sublevel = @ls_sublevel-low
                  INTO TABLE @DATA(lt_sub_level).
*          DATA(lt_companycode) = gt_bangcandoiphatsinh.
*          SORT lt_companycode BY CompanyCode.
*          DELETE ADJACENT DUPLICATES FROM lt_companycode COMPARING CompanyCode.
*
*          LOOP AT lt_companycode INTO DATA(ls_companycode).
              LOOP AT lt_sub_level INTO DATA(ls_sublevel_data).
                LOOP AT gt_bangcandoiphatsinh INTO DATA(ls_bangcandoiphatsinh). "WHERE CompanyCode = ls_companycode-CompanyCode.
                  IF ls_bangcandoiphatsinh-glaccount CP |{ ls_sublevel_data-gl_account }*|.
                    ls_bangcandoiphatsinh-glaccount = ls_sublevel_data-gl_account.
                    ls_bangcandoiphatsinh-glaccountname = ls_sublevel_data-ztext.
                    COLLECT ls_bangcandoiphatsinh INTO lt_bangcandoiphatsinh.
                  ENDIF.
                ENDLOOP.
              ENDLOOP.
*          ENDLOOP.
              SORT lt_bangcandoiphatsinh BY companycode glaccount.
              gt_bangcandoiphatsinh = lt_bangcandoiphatsinh.
              CLEAR lt_bangcandoiphatsinh.
            ENDIF.

*        LOOP AT gt_bangcandoiphatsinh INTO ls_bangcandoiphatsinh.
*          IF sy-tabix > ls_page_info-offset.
*            IF sy-tabix > max_rows.
*              EXIT.
*            ELSE.
*              APPEND ls_bangcandoiphatsinh TO lt_bangcandoiphatsinh.
*            ENDIF.
*          ENDIF.
*        ENDLOOP.

            " 4. Sorting
            DATA(sort_order) = VALUE abap_sortorder_tab(
              FOR sort_element IN io_request->get_sort_elements( )
                                  ( name = sort_element-element_name descending = sort_element-descending ) ).
            IF sort_order IS NOT INITIAL.
              SORT gt_bangcandoiphatsinh BY (sort_order).
            ENDIF.

            DATA(lv_total_records) = lines( gt_bangcandoiphatsinh ).

            DATA: lt_result TYPE tt_bangcandoiphatsinh.
            lt_result = gt_bangcandoiphatsinh.
            DATA(lo_paging) = io_request->get_paging( ).
            IF lo_paging IS BOUND.
              DATA(top) = lo_paging->get_page_size( ).
              IF top < 0. " -1 means all records
                top = lv_total_records.
              ENDIF.
              DATA(skip) = lo_paging->get_offset( ).

              IF skip >= lv_total_records.
                CLEAR lt_result. " Offset is beyond the total number of records
              ELSEIF top = 0.
                CLEAR lt_result. " No records requested
              ELSE.
                " Calculate the actual range to keep
                DATA(lv_start_index) = skip + 1. " ABAP uses 1-based indexing
                DATA(lv_end_index) = skip + top.

                " Ensure end index doesn't exceed table size
                IF lv_end_index > lv_total_records.
                  lv_end_index = lv_total_records.
                ENDIF.

                " Create a new table with only the required records
                DATA: lt_paged_result LIKE lt_result.
                CLEAR lt_paged_result.

                " Copy only the required records
                DATA(lv_index) = lv_start_index.
                WHILE lv_index <= lv_end_index.
                  APPEND lt_result[ lv_index ] TO lt_paged_result.
                  lv_index = lv_index + 1.
                ENDWHILE.

                lt_result = lt_paged_result.
              ENDIF.
            ENDIF.
            " 6. Set response
            IF io_request->is_data_requested( ).
              io_response->set_data( lt_result ).
            ENDIF.

            IF io_request->is_total_numb_of_rec_requested( ).
              io_response->set_total_number_of_records( lines( gt_bangcandoiphatsinh ) ).
            ENDIF.

          WHEN 'ZJP_C_PHIEUKETOAN' OR 'ZJP_C_PHIEUKETOAN_2'.
            lo_report_fi->get_phieuketoan(
              EXPORTING
                ir_companycode        = ir_companycode
*               ir_glaccount          = ir_glaccount
                ir_accountingdocument = ir_accountingdocument
                ir_postingdate        = ir_postingdate
                ir_fiscalyear         = ir_fiscalyear
                ir_documentdate       = ir_documentdate
                ir_documenttype       = ir_documenttype
                ir_customer           = ir_customer
                ir_supplier           = ir_supplier
                ir_accountant         = ir_accountant
                ir_createby           = ir_createby
              IMPORTING
                e_phieuketoan         = gt_phieuketoan
                e_return              = lt_returns
            ).

            DATA: lt_phieuketoan TYPE tt_phieuketoan.

            LOOP AT gt_phieuketoan INTO DATA(ls_phieuketoan).
              IF sy-tabix > ls_page_info-offset.
                IF sy-tabix > max_rows.
                  EXIT.
                ELSE.
                  APPEND ls_phieuketoan TO lt_phieuketoan.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF io_request->is_total_numb_of_rec_requested( ).
              io_response->set_total_number_of_records( lines( gt_phieuketoan ) ).
            ENDIF.

            IF io_request->is_data_requested( ).
              io_response->set_data( lt_phieuketoan ).
            ENDIF.
          WHEN 'ZJP_C_PHIEUKETOAN_ITEMS' OR 'ZJP_C_PHIEUKETOAN_ITEMS_2'.
            lo_report_fi->get_phieuketoan(
              EXPORTING
                ir_companycode        = ir_companycode
*               ir_glaccount          = ir_glaccount
                ir_accountingdocument = ir_accountingdocument
                ir_postingdate        = ir_postingdate
                ir_fiscalyear         = ir_fiscalyear
                ir_documentdate       = ir_documentdate
                ir_documentitem       = ir_documentitem
                ir_accountant         = ir_accountant
                ir_createby           = ir_createby
              IMPORTING
                e_phieuketoan         = gt_phieuketoan
                e_phieuketoan_items   = gt_phieuketoan_items
                e_return              = lt_returns
            ).

            DATA: lt_phieuketoan_items TYPE tt_phieuketoan_items.

            LOOP AT gt_phieuketoan_items INTO DATA(ls_phieuketoan_items).
              IF sy-tabix > ls_page_info-offset.
                IF sy-tabix > max_rows.
                  EXIT.
                ELSE.
                  APPEND ls_phieuketoan_items TO lt_phieuketoan_items.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF io_request->is_total_numb_of_rec_requested( ).
              io_response->set_total_number_of_records( lines( gt_phieuketoan_items ) ).
            ENDIF.

            IF io_request->is_data_requested( ).
              io_response->set_data( lt_phieuketoan_items ).
            ENDIF.

          WHEN 'ZJP_C_PKT_PDFDOC'.
            lo_report_fi->get_pkt_pdf(
              EXPORTING
                ir_companycode        = ir_companycode
                ir_accountingdocument = ir_accountingdocument
                ir_fiscalyear         = ir_fiscalyear
                ir_accountant         = ir_accountant
                ir_createby           = ir_createby
              IMPORTING
                e_pkt_pdt             = gt_pkt_pdf
            ).

            DATA: lt_pkt_pdf TYPE tt_pkt_pdf.

            LOOP AT gt_pkt_pdf INTO DATA(ls_pk_pdf).
              IF sy-tabix > ls_page_info-offset.
                IF sy-tabix > max_rows.
                  EXIT.
                ELSE.
                  APPEND ls_pk_pdf TO lt_pkt_pdf.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF io_request->is_total_numb_of_rec_requested( ).
              io_response->set_total_number_of_records( lines( gt_pkt_pdf ) ).
            ENDIF.

            IF io_request->is_data_requested( ).
              io_response->set_data( lt_pkt_pdf ).
            ENDIF.

          WHEN OTHERS.

        ENDCASE.

      CATCH cx_root INTO DATA(exception).

*        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).
*
*        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.
*
*        RAISE EXCEPTION TYPE zcl_jp_get_data_report_fi
*          EXPORTING
*            textid   = VALUE scx_t100key(
*            msgid = exception_t100_key-msgid
*            msgno = exception_t100_key-msgno
*            attr1 = exception_t100_key-attr1
*            attr2 = exception_t100_key-attr2
*            attr3 = exception_t100_key-attr3
*            attr4 = exception_t100_key-attr4 )
*            previous = exception.

        IF cl_message_helper=>get_latest_t100_exception( exception ) IS BOUND.
          " Đã là T100 rồi → ném lại nguyên trạng, KHÔNG wrap
          RAISE EXCEPTION exception.
        ELSE.
          " Không phải T100 → wrap về 1 T100 của bạn
          RAISE EXCEPTION TYPE zcl_jp_get_data_report_fi
            EXPORTING
              textid = VALUE scx_t100key(
                        msgid = 'ZMMFIRP' msgno = '999'
                        attr1 = exception->get_text( ) ).
        ENDIF.
    ENDTRY.
  ENDMETHOD.


  METHOD get_pkt_pdf.
    DATA(lo_rp_fi_export) = NEW zcl_jp_report_fi_export( ).

    DATA: ls_pkt_pdf LIKE LINE OF gt_pkt_pdf.

    SELECT
        companycode,
        accountingdocument,
        fiscalyear
    FROM i_journalentry
    WHERE companycode IN @ir_companycode
    AND accountingdocument IN @ir_accountingdocument
    AND fiscalyear IN @ir_fiscalyear
    INTO TABLE @DATA(lt_data).

    DATA: lr_companycode        TYPE zcl_jp_common_core=>tt_ranges,
          lr_accountingdocument TYPE zcl_jp_common_core=>tt_ranges,
          lr_fiscalyear         TYPE zcl_jp_common_core=>tt_ranges.

    DATA lt_refs TYPE zcl_ads_xml_builder=>tt_table_data_ref.
    DATA(o_gen_adobe) = NEW zcl_gen_adobe( ).

    LOOP AT lt_data INTO DATA(ls_data).
      FREE: lr_accountingdocument, lr_companycode, lr_fiscalyear.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_data-companycode ) TO lr_companycode.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_data-accountingdocument ) TO lr_accountingdocument.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_data-fiscalyear ) TO lr_fiscalyear.

      lo_rp_fi_export->process_data(
        EXPORTING
          ir_companycode        = lr_companycode
          ir_accountingdocument = lr_accountingdocument
          ir_fiscalyear         = lr_fiscalyear
          ir_accountant         = ir_accountant
          ir_createby           = ir_createby
        IMPORTING
          et_items              = DATA(lt_items)
          et_sign               = DATA(lt_sign)
          e_hdr                 = DATA(ls_hdr)
          e_ftr                 = DATA(ls_ftr)
      ).

      APPEND VALUE #( table_id = 'TABLE1' dref = REF #( lt_items ) ) TO lt_refs.
      APPEND VALUE #( table_id = 'TABLE2' dref = REF #( lt_sign  ) ) TO lt_refs.

      DATA(xml_auto) = zcl_ads_xml_builder=>build_xml_by_form(
        i_form_id     = 'zphieuketoan'
        i_header_ctx  = ls_hdr
        i_footer_ctx  = ls_ftr
        it_table_data = lt_refs ).

      DATA: ls_request TYPE zcl_gen_adobe=>ts_request.

      DATA: ls_xml TYPE zcl_gen_adobe=>ty_gs_xml.

      APPEND xml_auto TO ls_xml-data.

      DATA(lv_pdf) = o_gen_adobe->print_pdf( EXPORTING i_xml   = ls_xml
                                                       iv_rpid = 'zphieuketoan'
                                                      ).

      ls_pkt_pdf-companycode = ls_data-companycode.
      ls_pkt_pdf-accountingdocument = ls_data-accountingdocument.
      ls_pkt_pdf-fiscalyear = ls_data-fiscalyear.

      ls_pkt_pdf-filename = |PKT_{ ls_data-accountingdocument }|.
      ls_pkt_pdf-mimetype = 'application/pdf'.
      ls_pkt_pdf-fileextension = 'pdf'.
      ls_pkt_pdf-content = lv_pdf.

      APPEND ls_pkt_pdf TO gt_pkt_pdf.
      CLEAR: ls_pkt_pdf.

      FREE: lt_items, lt_sign.
      CLEAR: ls_hdr, ls_ftr.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.

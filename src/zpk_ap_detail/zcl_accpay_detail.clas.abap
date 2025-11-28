CLASS zcl_accpay_detail DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
    " Define line item structure internally
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_ranges TYPE TABLE OF ty_range_option.

    TYPES: BEGIN OF ty_line_item,
             posting_date        TYPE budat,
             document_number     TYPE belnr_d,
             document_date       TYPE bldat,
             contra_account      TYPE saknr,
             item_text           TYPE sgtxt,
             profit_center       TYPE prctr,
             debit_amount        TYPE wrbtr,
             credit_amount       TYPE wrbtr,
             balance             TYPE wrbtr,
             closingdebit        TYPE wrbtr,
             closingcredit       TYPE wrbtr,
             debit_amount_tran   TYPE wrbtr,
             credit_amount_tran  TYPE wrbtr,
             balance_tran        TYPE wrbtr,
             closingdebit_tran   TYPE wrbtr,
             closingcredit_tran  TYPE wrbtr,
             companycodecurrency TYPE waers,
             transactioncurrency TYPE waers,
           END OF ty_line_item.

    TYPES: ty_ledgergllineitem TYPE c LENGTH 6.

    TYPES: tt_line_items TYPE TABLE OF zst_line_item_detail.

    TYPES: BEGIN OF ty_journal_item,
             companycode                    TYPE i_journalentryitem-companycode,
             fiscalyear                     TYPE i_journalentryitem-fiscalyear,
             accountingdocument             TYPE i_journalentryitem-accountingdocument,
             isreversed                     TYPE i_journalentryitem-isreversed,
             reversalreferencedocument      TYPE i_journalentryitem-reversalreferencedocument,
             reversalreferencedocumentcntxt TYPE i_journalentryitem-reversalreferencedocumentcntxt,
             ledgergllineitem               TYPE i_journalentryitem-ledgergllineitem,
             accountingdocumentitem         TYPE i_journalentryitem-accountingdocumentitem,
             postingdate                    TYPE i_journalentryitem-postingdate,
             documentdate                   TYPE i_journalentryitem-documentdate,
             glaccount                      TYPE i_journalentryitem-glaccount,
             supplier                       TYPE i_journalentryitem-supplier,
             amountincompanycodecurrency    TYPE i_journalentryitem-amountincompanycodecurrency,
             amountintransactioncurrency    TYPE i_journalentryitem-amountintransactioncurrency,
             debitcreditcode                TYPE i_journalentryitem-debitcreditcode,
             accountingdocumenttype         TYPE i_journalentryitem-accountingdocumenttype,
             documentitemtext               TYPE i_journalentryitem-documentitemtext,
             addtext2                       TYPE c LENGTH 40,
             profitcenter                   TYPE i_journalentryitem-profitcenter,
             companycodecurrency            TYPE i_journalentryitem-companycodecurrency,
             transactioncurrency            TYPE i_journalentryitem-transactioncurrency,
           END OF ty_journal_item.

    TYPES: tt_journal_items TYPE TABLE OF ty_journal_item.

    TYPES: BEGIN OF ty_in_faglfcv,
             ccode           TYPE zui_in_faglfcv-ccode,
             account         TYPE zui_in_faglfcv-account,
             gl_account      TYPE zui_in_faglfcv-gl_account,
             doc_number      TYPE zui_in_faglfcv-doc_number,
             keydate         TYPE zui_in_faglfcv-keydate,
             debit_faglfcv   TYPE zui_in_faglfcv-posting_amount,
             credit_faglfcv  TYPE zui_in_faglfcv-posting_amount,
             currency        TYPE zui_in_faglfcv-currency,
             target_currency TYPE zui_in_faglfcv-target_currency,
           END OF ty_in_faglfcv,

           tt_in_faglfcv TYPE TABLE OF ty_in_faglfcv.

    METHODS get_company_info
      IMPORTING iv_bukrs           TYPE bukrs
      EXPORTING ev_company_name    TYPE text100
                ev_company_address TYPE char256.

    METHODS get_business_partner_name
      IMPORTING iv_business_partner TYPE text10
      RETURNING VALUE(rv_name)      TYPE text100.

    METHODS get_opening_balance
      IMPORTING iv_bukrs        TYPE bukrs
                iv_racct        TYPE saknr
                iv_partner      TYPE text10
                iv_date         TYPE datum
                iv_currency     TYPE waers
      EXPORTING ev_debit        TYPE wrbtr
                ev_credit       TYPE wrbtr
                ev_balance      TYPE wrbtr
                ev_debit_tran   TYPE wrbtr
                ev_credit_tran  TYPE wrbtr
                ev_balance_tran TYPE wrbtr.

    METHODS process_period_data
      IMPORTING it_journal_items     TYPE tt_journal_items
                it_in_faglfcv        TYPE tt_in_faglfcv
                iv_bukrs             TYPE bukrs
                iv_racct             TYPE saknr
                iv_partner           TYPE text10
                iv_date_from         TYPE datum
                iv_date_to           TYPE datum
                iv_currency          TYPE waers
      EXPORTING et_line_items        TYPE tt_line_items
                ev_debit_total       TYPE wrbtr
                ev_credit_total      TYPE wrbtr
                ev_debit_total_tran  TYPE wrbtr
                ev_credit_total_tran TYPE wrbtr.

    METHODS get_contra_account
      IMPORTING iv_bukrs                  TYPE bukrs
                iv_accountingdoc          TYPE belnr_d
                iv_fiscalyear             TYPE gjahr
                iv_racct                  TYPE saknr
                iv_lineitem               TYPE ty_ledgergllineitem
                iv_AccountingDocumentItem TYPE buzei
      RETURNING VALUE(rv_contra)          TYPE saknr.

    METHODS determine_account_nature
      IMPORTING iv_glaccount     TYPE saknr
      RETURNING VALUE(rv_nature) TYPE char1_run_type.

    METHODS convert_line_items_to_json
      IMPORTING it_line_items  TYPE tt_line_items
      RETURNING VALUE(rv_json) TYPE string.

ENDCLASS.



CLASS zcl_accpay_detail IMPLEMENTATION.


  METHOD convert_line_items_to_json.
    " Convert internal table to JSON string
    DATA: lo_writer TYPE REF TO cl_sxml_string_writer.

    lo_writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).

    CALL TRANSFORMATION id
      SOURCE line_items = it_line_items
      RESULT XML lo_writer.

    rv_json = cl_abap_conv_codepage=>create_in( )->convert( lo_writer->get_output( ) ).

  ENDMETHOD.


  METHOD determine_account_nature.
    " Determine if account is debit or credit nature based on GL account number
    DATA: lv_first_char TYPE c LENGTH 1,
          lv_first_two  TYPE c LENGTH 2,
          lv_first_four TYPE c LENGTH 4.
    " remove leading zeros for accurate classification
    DATA(lv_glaccount) = |{ iv_glaccount ALPHA = OUT  }|.
    lv_first_char = lv_glaccount(1).
    lv_first_two = lv_glaccount(2).
    lv_first_four = lv_glaccount(4).

    " Special handling for certain accounts
    IF lv_first_four = '1312'.
      rv_nature = 'C'. " Credit nature
      RETURN.
    ELSEIF lv_first_four = '3312'.
      rv_nature = 'D'. " Debit nature
      RETURN.
    ENDIF.

    " Standard account classification
    IF lv_first_char = '1' OR lv_first_char = '2' OR
       lv_first_char = '6' OR lv_first_char = '8' OR
       lv_first_two = 'Z1'.
      rv_nature = 'D'. " Debit nature (Assets, Expenses)
    ELSE.
      rv_nature = 'C'. " Credit nature (Liabilities, Revenue, Equity)
    ENDIF.

  ENDMETHOD.


  METHOD get_business_partner_name.
    DATA: lv_name TYPE string.

    " First try to get from I_BusinessPartner
    SELECT SINGLE businesspartnername
      FROM i_businesspartner
      WHERE businesspartner = @iv_business_partner
      INTO @lv_name.

    IF lv_name IS NOT INITIAL.
      rv_name = lv_name.
      RETURN.
    ENDIF.

    " If not found, try supplier master
    SELECT SINGLE suppliername
      FROM i_supplier
      WHERE supplier = @iv_business_partner
      INTO @lv_name.

    IF lv_name IS NOT INITIAL.
      rv_name = lv_name.
      RETURN.
    ENDIF.

    " If not found, try customer master
    SELECT SINGLE customername
      FROM i_customer
      WHERE customer = @iv_business_partner
      INTO @lv_name.

    IF lv_name IS NOT INITIAL.
      rv_name = lv_name.
      RETURN.
    ENDIF.

    " If still nothing found, return the BP number
    rv_name = |BP: { iv_business_partner }|.
  ENDMETHOD.


  METHOD get_company_info.
    SELECT SINGLE
              companycode,
              addressid,
              vatregistration,
              currency,
              companycodename
    FROM i_companycode
    WHERE companycode = @iv_bukrs
    INTO @DATA(ls_company).
    .

    zcl_jp_common_core=>get_address_id_details(
      EXPORTING
        addressid            = ls_company-addressid
      IMPORTING
        o_addressiddetails = DATA(ls_addressid_dtails)
    ).

    ev_company_name = ls_company-companycodename.
    ev_company_address = ls_addressid_dtails-address.

  ENDMETHOD.


  METHOD get_contra_account.
    " Get other line items from the same document
    SELECT SINGLE glaccount, amountincompanycodecurrency
      FROM I_GLAccountLineItem
      WHERE companycode = @iv_bukrs
        AND accountingdocument = @iv_accountingdoc
        AND fiscalyear = @iv_fiscalyear
        AND OffsettingLedgerGLLineItem = @iv_lineitem
*        AND ledgergllineitem <> @iv_lineitem
*        AND glaccount <> @iv_racct
        AND ledger = '0L'
      INTO @DATA(ls_contra).
    IF sy-subrc = 0.
      rv_contra = ls_contra-glaccount.
      RETURN.
    ELSE.
      SELECT SINGLE * FROM zfirud_cf_off
       WITH PRIVILEGED ACCESS
       WHERE bukrs = @iv_bukrs
       AND belnr = @iv_accountingdoc
       AND gjahr = @iv_fiscalyear
       AND rldnr =  '0L'
       AND racct = @iv_racct
       INTO @DATA(ls_cf_off).
      IF sy-subrc = 0.
        SELECT SINGLE * FROM zfirud_cf_off
          WITH PRIVILEGED ACCESS
          WHERE bukrs = @iv_bukrs
          AND belnr = @iv_accountingdoc
          AND gjahr = @iv_fiscalyear
          AND rldnr =  '0L'
          AND offs_item = @ls_cf_off-docln
          INTO @DATA(ls_cf_off_1).
        IF sy-subrc = 0.
          rv_contra = ls_cf_off_1-racct.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD get_opening_balance.
    DATA: lv_total_amount TYPE i_journalentryitem-amountincompanycodecurrency.

    DATA: lt_where_clauses TYPE TABLE OF string.

    APPEND | supplier = @iv_partner| TO lt_where_clauses.
    APPEND |AND postingdate < @iv_date| TO lt_where_clauses.
    APPEND |AND companycode = @iv_bukrs| TO lt_where_clauses.
    APPEND |AND ledger = '0L'| TO lt_where_clauses.
    APPEND |AND financialaccounttype = 'K'| TO lt_where_clauses.
    APPEND |AND supplier IS NOT NULL| TO lt_where_clauses.
    APPEND |AND debitcreditcode IN ('S', 'H')| TO lt_where_clauses.
    APPEND |AND glaccount = @iv_racct| TO lt_where_clauses.

    IF iv_currency IS NOT INITIAL.
      APPEND |AND transactioncurrency = @iv_currency| TO lt_where_clauses.
    ENDIF.

    SELECT supplier AS bp,
           companycode AS rbukrs,
           SUM( CASE WHEN debitcreditcode = 'S' THEN amountincompanycodecurrency ELSE 0 END ) AS open_debit,
           SUM( CASE WHEN debitcreditcode = 'H' THEN amountincompanycodecurrency ELSE 0 END ) AS open_credit,
           SUM( CASE WHEN debitcreditcode = 'S' THEN amountintransactioncurrency ELSE 0 END ) AS open_debit_tran,
           SUM( CASE WHEN debitcreditcode = 'H' THEN amountintransactioncurrency ELSE 0 END ) AS open_credit_tran,
           transactioncurrency,
           companycodecurrency,
           glaccount
      FROM i_journalentryitem
      WHERE (lt_where_clauses)
      GROUP BY supplier, companycode, transactioncurrency, companycodecurrency, glaccount
      INTO TABLE @DATA(lt_open_balances).

***bổ sung logic lấy thêm từ chức năng đánh giá chênh lệch tỷ giá***
    FREE: lt_where_clauses.

    APPEND | account = @iv_partner| TO lt_where_clauses.
    APPEND |AND keydate < @iv_date| TO lt_where_clauses.
    APPEND |AND ccode = @iv_bukrs| TO lt_where_clauses.
    APPEND |AND account IS NOT NULL| TO lt_where_clauses.
    APPEND |AND debcred_ind IN ('S', 'H')| TO lt_where_clauses.
    APPEND |AND gl_account = @iv_racct| TO lt_where_clauses.

    IF iv_currency IS NOT INITIAL.
      APPEND |AND currency = @iv_currency| TO lt_where_clauses.
    ENDIF.

*    SELECT account AS bp,
*           ccode AS rbukrs,
*           gl_account,
*           posting_amount AS chenh_lech,
*           MAX( keydate ) AS max_keydate,
*           currency,
*           target_currency
*      FROM zui_in_faglfcv
*      WHERE (lt_where_clauses)
*      GROUP BY account, ccode, gl_account, posting_amount, currency, target_currency
*      INTO TABLE @DATA(lt_open_balances_faglfcv).

    SELECT account AS bp,
           ccode AS rbukrs,
           gl_account,
           SUM( CASE WHEN debcred_ind = 'S' THEN posting_amount ELSE 0 END ) AS open_debit_faglfcv,
           SUM( CASE WHEN debcred_ind = 'H' THEN posting_amount ELSE 0 END ) AS open_credit_faglfcv,
           currency,
           target_currency
      FROM zui_in_faglfcv
      WHERE (lt_where_clauses)
      GROUP BY account, ccode, gl_account, currency, target_currency
      INTO TABLE @DATA(lt_open_balances_faglfcv).
********************************************************************

    SORT lt_open_balances_faglfcv BY bp rbukrs .
    READ TABLE lt_open_balances_faglfcv INTO DATA(ls_open_balances_faglfcv) WITH KEY bp = iv_partner rbukrs = iv_bukrs.

    SORT lt_open_balances BY bp rbukrs.
    READ TABLE lt_open_balances INTO DATA(ls_open_balance) WITH KEY bp = iv_partner rbukrs = iv_bukrs.
    IF sy-subrc = 0.
      ev_balance = ls_open_balance-open_debit + ls_open_balance-open_credit + ls_open_balances_faglfcv-open_debit_faglfcv + ls_open_balances_faglfcv-open_credit_faglfcv.
      IF ev_balance < 0.
        ev_credit = ev_balance * -1.
        ev_debit = 0.
      ELSE.
        ev_debit = ev_balance.
        ev_credit = 0.
      ENDIF.
    ENDIF.
    ev_balance_tran = ls_open_balance-open_debit_tran + ls_open_balance-open_credit_tran.
    IF ev_balance_tran < 0.
      ev_credit_tran = ev_balance_tran * -1.
      ev_debit_tran = 0.
    ELSE.
      ev_debit_tran = ev_balance_tran.
      ev_credit_tran = 0.
    ENDIF.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA: lt_result TYPE TABLE OF zc_accpay_detail,
          ls_result TYPE zc_accpay_detail.

    DATA:
      lt_journal_items      TYPE tt_journal_items,
      ls_journal_item       TYPE ty_journal_item,
      lt_journal_items_temp TYPE tt_journal_items,

      lt_line_items         TYPE tt_line_items.

    TRY.
        " Get request details
        DATA(lo_filter) = io_request->get_filter( ).
        DATA(lt_filters) = lo_filter->get_as_ranges( ).

        " Extract filter values
        DATA(lr_bukrs) = lt_filters[ name = 'COMPANYCODE' ]-range.
        DATA(lr_racct) = lt_filters[ name = 'GLACCOUNTNUMBER' ]-range.
        DATA(lr_date_from) = lt_filters[ name = 'POSTINGDATEFROM' ]-range.
        DATA(lr_date_to) = lt_filters[ name = 'POSTINGDATETO' ]-range.
*        DATA(lr_currency) = lt_filters[ name = 'TRANSACTIONCURRENCY' ]-range."[ 1 ]-low.

      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_range).
        " Handle error
        RETURN.
    ENDTRY.
    " Safely extract optional filters and check if provided
    DATA: lv_partner_provided      TYPE abap_bool,
          lv_profitcenter_provided TYPE abap_bool,
          lv_currency_prov         TYPE abap_bool,
          lr_partner               TYPE RANGE OF i_journalentryitem-supplier,
          lr_profitcenter          TYPE RANGE OF i_journalentryitem-profitcenter,
          lr_currency              TYPE RANGE OF i_journalentryitem-TransactionCurrency.

    TRY.
        DATA(lr_currency_raw) = lt_filters[ name = 'TRANSACTIONCURRENCY' ]-range.
        LOOP AT lr_currency_raw ASSIGNING FIELD-SYMBOL(<fs_currency>).
          IF <fs_currency>-low IS NOT INITIAL.
            <fs_currency>-low = |{ <fs_currency>-low ALPHA = IN WIDTH = 5 }|.
          ENDIF.
          IF <fs_currency>-high IS NOT INITIAL.
            <fs_currency>-high = |{ <fs_currency>-high ALPHA = IN WIDTH = 5 }|.
          ENDIF.
        ENDLOOP.
        MOVE-CORRESPONDING lr_currency_raw TO lr_currency.
        lv_currency_prov = abap_true.
      CATCH cx_sy_itab_line_not_found.
        CLEAR lr_currency.
    ENDTRY.

    TRY.
        DATA(lr_partner_raw) = lt_filters[ name = 'BUSINESSPARTNER' ]-range.
        LOOP AT lr_partner_raw ASSIGNING FIELD-SYMBOL(<fs_partner>).
          IF <fs_partner>-low IS NOT INITIAL.
            <fs_partner>-low = |{ <fs_partner>-low ALPHA = IN WIDTH = 10 }|.
          ENDIF.
          IF <fs_partner>-high IS NOT INITIAL.
            <fs_partner>-high = |{ <fs_partner>-high ALPHA = IN WIDTH = 10 }|.
          ENDIF.
        ENDLOOP.
        MOVE-CORRESPONDING lr_partner_raw TO lr_partner.
        lv_partner_provided = abap_true.
      CATCH cx_sy_itab_line_not_found.
        CLEAR lr_partner.
    ENDTRY.

    TRY.
        DATA(lr_profitcenter_raw) = lt_filters[ name = 'PROFITCENTER' ]-range.
        LOOP AT lr_profitcenter_raw ASSIGNING FIELD-SYMBOL(<fs_profitcenter>).
          <fs_profitcenter>-low = |{ <fs_profitcenter>-low ALPHA = IN WIDTH = 10 }|.
          IF <fs_profitcenter>-high IS NOT INITIAL.
            <fs_profitcenter>-high = |{ <fs_profitcenter>-high ALPHA = IN WIDTH = 10 }|.
          ENDIF.
        ENDLOOP.
        MOVE-CORRESPONDING lr_profitcenter_raw TO lr_profitcenter.
        lv_profitcenter_provided = abap_true.
      CATCH cx_sy_itab_line_not_found.
        CLEAR lr_profitcenter.
    ENDTRY.

    DATA: lv_bukrs           TYPE bukrs,
          lv_racct           TYPE saknr,
          lv_partner         TYPE text10,
          lv_date_from       TYPE datum,
          lv_date_to         TYPE datum,
          lv_company_name    TYPE zc_accpay_detail-companyname,
          lv_company_address TYPE char256,
          lv_closing         TYPE zc_accpay_detail-closingcredit.

    " Get single values
    lv_bukrs = lr_bukrs[ 1 ]-low.
    lv_date_from = lr_date_from[ 1 ]-low.
    lv_date_to = COND #( WHEN lr_date_to[ 1 ]-low IS NOT INITIAL
                          THEN lr_date_to[ 1 ]-low
                          ELSE lv_date_from ).

    DATA: lw_company          TYPE bukrs,
          ls_companycode_info TYPE zst_companycode_info.

    lw_company = lr_bukrs[ 1 ]-low.
    CALL METHOD zcl_jp_common_core=>get_companycode_details
      EXPORTING
        i_companycode = lw_company
      IMPORTING
        o_companycode = ls_companycode_info.

    DATA: lt_where_clauses TYPE TABLE OF string.

    APPEND | companycode = '{ lv_bukrs }'| TO lt_where_clauses.
    APPEND |AND glaccount IN @lr_racct| TO lt_where_clauses.
    APPEND |AND postingdate BETWEEN '{ lv_date_from }' AND '{ lv_date_to }'| TO lt_where_clauses.
    APPEND |AND ledger = '0L'| TO lt_where_clauses.
    APPEND |AND financialaccounttype = 'K'| TO lt_where_clauses.
    APPEND |AND accountingdocument NOT LIKE 'B%'| TO lt_where_clauses.

    IF lv_partner_provided = abap_true.
      APPEND |AND supplier IN @lr_partner| TO lt_where_clauses.
    ENDIF.

    IF lv_profitcenter_provided = abap_true.
      APPEND |AND profitcenter IN @lr_profitcenter| TO lt_where_clauses.
    ENDIF.

    READ TABLE lr_currency INTO DATA(ls_curr) INDEX 1.

    IF lv_currency_prov = abap_true AND ls_curr-low NE 'VND'.
      APPEND |AND transactioncurrency IN @lr_currency| TO lt_where_clauses.
    ENDIF.

    SELECT companycode,
           fiscalyear,
           accountingdocument,
           IsReversed,
           ReversalReferenceDocument,
           ReversalReferenceDocumentCntxt,
           ledgergllineitem,
           AccountingDocumentItem,
           postingdate,
           documentdate,
           glaccount,
           supplier,
           amountincompanycodecurrency,
           amountintransactioncurrency,
           companycodecurrency,
           transactioncurrency,
           debitcreditcode,
           accountingdocumenttype,
           documentitemtext,
           profitcenter,
           yy1_text2_cob AS addtext2
        FROM I_JournalEntryItem
        WHERE (lt_where_clauses)
        INTO CORRESPONDING FIELDS OF TABLE @lt_journal_items.
    SORT lt_journal_items BY CompanyCode AccountingDocument FiscalYear ASCENDING.

    IF sy-subrc EQ 0.
      SELECT companycode,
             FiscalYear,
             AccountingDocument,
             IsReversal,
             IsReversed,
             ReverseDocument,
             OriginalReferenceDocument,
             postingdate
          FROM i_journalentry
          FOR ALL ENTRIES IN @lt_journal_items
          WHERE companycode = @lt_journal_items-companycode
          AND AccountingDocument = @lt_journal_items-accountingdocument
          AND FiscalYear = @lt_journal_items-fiscalyear
*        AND postingdate BETWEEN @lv_date_from AND @lv_date_to
          INTO TABLE @DATA(lt_journal_headers).
      SORT lt_journal_headers BY CompanyCode AccountingDocument FiscalYear ASCENDING.
    ENDIF.

    " loại bỏ cặp chứng từ hủy cùng kỳ.
    DATA: lt_huy       LIKE lt_journal_items,
          ls_huy       LIKE LINE OF lt_huy,
          lv_index_huy TYPE sy-tabix,

          lv_length    TYPE n LENGTH 3,
          lv_docnum    TYPE i_journalentryitem-AccountingDocument,
          lv_year      TYPE i_journalentryitem-FiscalYear.

    lt_huy = lt_journal_items.


    SORT lt_huy BY CompanyCode AccountingDocument FiscalYear ASCENDING.

    LOOP AT lt_huy INTO DATA(ls_check_item) WHERE isreversed IS NOT INITIAL.
      lv_index_huy = sy-tabix.

      READ TABLE lt_journal_headers INTO DATA(ls_check_header) WITH KEY CompanyCode = ls_check_item-companycode
                                                                        AccountingDocument = ls_check_item-accountingdocument
                                                                        FiscalYear = ls_check_item-fiscalyear BINARY SEARCH.

      IF sy-subrc = 0.
        lv_length = strlen( ls_check_header-OriginalReferenceDocument ) - 4.
        lv_docnum = ls_check_header-OriginalReferenceDocument(lv_length).
        lv_year = ls_check_header-OriginalReferenceDocument+lv_length.

        IF lv_docnum IS NOT INITIAL.
          DELETE lt_journal_items WHERE reversalreferencedocument = lv_docnum AND fiscalyear = lv_year.
          IF sy-subrc = 0.
            DELETE lt_journal_items WHERE accountingdocument = ls_check_item-accountingdocument AND fiscalyear = lv_year.
          ENDIF.
        ENDIF.
      ENDIF.

      CLEAR: ls_check_item, ls_check_header, lv_length, lv_docnum, lv_year.
    ENDLOOP.

    SORT lt_journal_items BY companycode glaccount supplier companycodecurrency transactioncurrency.

***bổ sung logic lấy thêm từ chức năng đánh giá chênh lệch tỷ giá***
    FREE: lt_where_clauses.

    APPEND | ccode = '{ lv_bukrs }'| TO lt_where_clauses.
    APPEND |AND gl_account IN @lr_racct| TO lt_where_clauses.
*    APPEND |AND keydate <= '{ lv_date_to }'| TO lt_where_clauses.
    APPEND |AND keydate BETWEEN '{ lv_date_from }' AND '{ lv_date_to }'| TO lt_where_clauses.

    IF lv_partner_provided = abap_true.
      APPEND |AND account IN @lr_partner| TO lt_where_clauses.
    ENDIF.

    IF lv_currency_prov = abap_true AND ls_curr-low NE 'VND'.
      APPEND |AND currency in @lr_currency| TO lt_where_clauses.
    ENDIF.

*    SELECT
*          ccode,
*          account,
*          gl_account,
*          doc_number,
*          MAX( keydate ) AS max_keydate,
*          debcred_ind,
*          posting_amount,
*          currency,
*          target_currency
*        FROM zui_in_faglfcv
*        WHERE (lt_where_clauses)
*        GROUP BY ccode, account, gl_account, doc_number, debcred_ind, posting_amount, currency, target_currency
*        INTO TABLE @DATA(lt_in_faglfcv).

    SELECT
          ccode,
          account,
          gl_account,
          doc_number,
          keydate,
          SUM( CASE WHEN debcred_ind = 'S' THEN posting_amount ELSE 0 END ) AS debit_faglfcv,
          SUM( CASE WHEN debcred_ind = 'H' THEN posting_amount ELSE 0 END ) AS credit_faglfcv,
          currency,
          target_currency
        FROM zui_in_faglfcv
        WHERE (lt_where_clauses)
        GROUP BY ccode, account, gl_account, doc_number, keydate, currency, target_currency
        INTO TABLE @DATA(lt_in_faglfcv).
    SORT lt_in_faglfcv BY ccode account gl_account currency target_currency ASCENDING.
********************************************************************

    DATA: lt_each_page           TYPE tt_journal_items,
          lt_each_page_faglfcv   TYPE tt_in_faglfcv,
          lv_last_creadit_amount TYPE wrbtr,
          lv_last_debit_amount   TYPE wrbtr.

    DATA(lo_common_app) = zcl_jp_common_core=>get_instance( ).
*    lấy diễn giải cho type zp
    DATA(lt_typezp) = lt_journal_items[].
    DELETE lt_typezp WHERE accountingdocumenttype <> 'ZP'.
    SORT lt_typezp BY companycode accountingdocument fiscalyear.
    DELETE ADJACENT DUPLICATES FROM lt_typezp COMPARING companycode accountingdocument fiscalyear.
    IF lt_typezp[] IS NOT INITIAL.
      SELECT
            headers~CompanyCode AS bukrs,
            headers~AccountingDocument AS belnr,
            headers~FiscalYear AS gjahr,
            headers~DocumentReferenceID,
            items~ClearingJournalEntry,
            items~AssignmentReference,
            headers~AccountingDocumentCategory,
            items~LedgerGLLineItem AS lineItem
          FROM I_JournalEntryItem AS items

          INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                              AND items~AccountingDocument = headers~AccountingDocument
                                              AND items~FiscalYear         = headers~FiscalYear
          FOR ALL ENTRIES IN @lt_typezp
          WHERE headers~CompanyCode          = @lv_bukrs
            AND items~Ledger                 = '0L'
            AND items~ClearingJournalEntry = @lt_typezp-accountingdocument
            AND items~ClearingDate = @lt_typezp-postingdate
            AND headers~AccountingDocumentType <> 'ZP'
            INTO TABLE @DATA(lt_clear).

      SELECT
      headers~CompanyCode AS bukrs,
      headers~AccountingDocument AS belnr,
      headers~FiscalYear AS gjahr,
      headers~DocumentReferenceID,
      items~ClearingJournalEntry,
      items~AssignmentReference,
      headers~AccountingDocumentCategory,
      items~AccountingDocumentItem AS lineItem
    FROM I_OperationalAcctgDocItem AS items

    INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                        AND items~AccountingDocument = headers~AccountingDocument
                                        AND items~FiscalYear         = headers~FiscalYear
    FOR ALL ENTRIES IN @lt_typezp
    WHERE headers~CompanyCode          = @lv_bukrs
      AND headers~LedgerGroup          = '0L'
*        AND items~                    IN @ir_rldnr
      AND items~ClearingJournalEntry = @lt_typezp-accountingdocument
      AND items~ClearingDate = @lt_typezp-postingdate
      AND headers~AccountingDocumentType <> 'ZP'
      APPENDING TABLE @lt_clear.
    ENDIF.


    SORT lt_clear BY bukrs belnr gjahr lineitem.
    DELETE ADJACENT DUPLICATES FROM lt_clear COMPARING bukrs belnr gjahr lineitem.
    DATA: ls_acdoca TYPE ty_journal_item.
*    lay dien giai
    DATA: lw_diengiai TYPE c LENGTH 255.
    LOOP AT lt_journal_items ASSIGNING FIELD-SYMBOL(<fs_acdoca>) WHERE accountingdocumenttype = 'RE' OR accountingdocumenttype = 'ZP' OR accountingdocumenttype = 'RV'.
      MOVE-CORRESPONDING <fs_acdoca> TO ls_acdoca.
      AT NEW Fiscalyear.
        CLEAR: lw_diengiai.
        IF ls_acdoca-accountingdocumenttype = 'RE' OR ls_acdoca-accountingdocumenttype = 'RV'.
          LOOP AT lt_journal_items INTO DATA(ls_tmp) WHERE companycode = ls_acdoca-companycode AND accountingdocument = ls_acdoca-accountingdocument AND fiscalyear = ls_acdoca-fiscalyear
                                                AND ( documentitemtext IS NOT INITIAL OR addtext2 IS NOT INITIAL ).
            lw_diengiai = |{ ls_tmp-documentitemtext } { ls_tmp-addtext2 }| .
            CONDENSE lw_diengiai.
            EXIT.
          ENDLOOP.
        ELSE.
          LOOP AT lt_clear INTO DATA(ls_clear) WHERE ClearingJournalEntry = ls_acdoca-accountingdocument.
            IF ls_clear-AccountingDocumentCategory = 'S'.
              IF ls_clear-AssignmentReference IS NOT INITIAL.
                IF lw_diengiai IS INITIAL.
                  lw_diengiai = ls_clear-AssignmentReference.
                ELSE.
                  lw_diengiai = |{ lw_diengiai }, { ls_clear-AssignmentReference }|.
                ENDIF.
              ENDIF.
            ELSE.
              lw_diengiai = ls_clear-DocumentReferenceID.
            ENDIF.
          ENDLOOP.
          IF ls_clear-AccountingDocumentCategory = 'S'.
            lw_diengiai = |Thanh toán cho bill số { lw_diengiai }|.
          ELSE.
            lw_diengiai = |Thanh toán cho HĐ số { lw_diengiai }|.
          ENDIF.
        ENDIF.
      ENDAT.

      IF <fs_acdoca>-accountingdocumenttype = 'ZP'.
        <fs_acdoca>-documentitemtext = lw_diengiai.
      ELSE.
        IF <fs_acdoca>-documentitemtext IS INITIAL.
          <fs_acdoca>-documentitemtext = lw_diengiai.
        ENDIF.
      ENDIF.

    ENDLOOP.
    LOOP AT lt_journal_items ASSIGNING <fs_acdoca> WHERE accountingdocumenttype <> 'RE' AND accountingdocumenttype <> 'ZP' AND accountingdocumenttype <> 'RV'.
      IF <fs_acdoca>-documentitemtext IS NOT INITIAL OR <fs_acdoca>-addtext2 IS NOT INITIAL.
        <fs_acdoca>-documentitemtext = |{ <fs_acdoca>-documentitemtext } { <fs_acdoca>-addtext2 }| .
        CONDENSE <fs_acdoca>-documentitemtext.
      ENDIF.
    ENDLOOP.
    " Process period data
    LOOP AT lt_journal_items INTO DATA(lg_journal_items)
    GROUP BY (
        companycode = lg_journal_items-companycode
        glaccount = lg_journal_items-glaccount
        supplier =  lg_journal_items-supplier
        transactioncurrency = lg_journal_items-transactioncurrency
        companycodecurrency = lg_journal_items-companycodecurrency
    )
    ASSIGNING FIELD-SYMBOL(<group>).
      " For each group, process the journal items
      LOOP AT GROUP <group> INTO DATA(ls_item).
        APPEND ls_item TO lt_each_page.
      ENDLOOP.

      LOOP AT lt_in_faglfcv INTO DATA(ls_in_faglfcv) WHERE ccode = <group>-companycode
                                                     AND account = <group>-supplier
                                                     AND gl_account = <group>-glaccount
                                                     AND currency = <group>-transactioncurrency
                                                     AND target_currency = <group>-companycodecurrency.
        APPEND ls_in_faglfcv TO lt_each_page_faglfcv.
      ENDLOOP.

      READ TABLE lr_currency INTO DATA(ls_currency) INDEX 1.

*      ls_result-companyname = lv_company_name.

      ls_result-companyname = ls_companycode_info-companycodename.
      ls_result-companyaddress = ls_companycode_info-companycodeaddr. "new

      ls_result-transactioncurrency = <group>-transactioncurrency.
      ls_result-companycodecurrency = <group>-companycodecurrency.
      lv_racct = <group>-glaccount.
      lv_partner = <group>-supplier.

      " Get opening balance
      get_opening_balance(
        EXPORTING
          iv_bukrs = lv_bukrs
          iv_racct = lv_racct
          iv_partner = lv_partner
          iv_date = lv_date_from
          iv_currency = ls_result-transactioncurrency "  ls_currency-low
        IMPORTING
          ev_debit = ls_result-openingdebitbalance
          ev_credit = ls_result-openingcreditbalance
*          ev_balance = ls_result-openingbalance
          ev_debit_tran = ls_result-openingdebitbalancetran
          ev_credit_tran = ls_result-openingcreditbalancetran
*          ev_balance_tran = ls_result-OpeningBalanceTran
      ).

      process_period_data(
        EXPORTING
          it_journal_items = lt_each_page
          it_in_faglfcv = lt_each_page_faglfcv
          iv_bukrs = lv_bukrs
          iv_racct = lv_racct
          iv_partner = lv_partner
          iv_date_from = lv_date_from
          iv_date_to = lv_date_to
          iv_currency = ls_result-transactioncurrency
        IMPORTING
          et_line_items = lt_line_items
          ev_debit_total = ls_result-debitamountduringperiod
          ev_credit_total = ls_result-creditamountduringperiod
          ev_debit_total_tran = ls_result-debitamountduringperiodtran
          ev_credit_total_tran = ls_result-creditamountduringperiodtran
      ).

      " Nếu tran curency = 'VND', bỏ tran amount chỉ lấy company amount.
      LOOP AT lt_line_items ASSIGNING FIELD-SYMBOL(<fs_line_items>).
        IF ls_result-transactioncurrency = 'VND' OR ls_curr-low = 'VND'.
          CLEAR:
          <fs_line_items>-debit_amount_tran,
          <fs_line_items>-credit_amount_tran,
          <fs_line_items>-balance_tran,
          <fs_line_items>-closingcredit_tran,
          <fs_line_items>-closingdebit_tran.
        ENDIF.
      ENDLOOP.

      " Convert line items to JSON
      ls_result-lineitemsjson = convert_line_items_to_json( lt_line_items ).

      " Calculate closing balance based on account nature
      DATA(lv_account_nature) = determine_account_nature( lv_racct ).

      lv_closing = ls_result-openingdebitbalance - ls_result-openingcreditbalance +
          ls_result-debitamountduringperiod - ls_result-creditamountduringperiod.
      IF lv_closing < 0.
        ls_result-closingcredit = lv_closing * -1.
      ELSE.
        ls_result-closingdebit = lv_closing.
      ENDIF.
      CLEAR lv_closing.
      " Calculate closing balance in transaction currency
      lv_closing = ls_result-openingdebitbalancetran - ls_result-openingcreditbalancetran +
          ls_result-debitamountduringperiodtran - ls_result-creditamountduringperiodtran.
      IF lv_closing < 0.
        ls_result-closingcredittran = lv_closing * -1.
      ELSE.
        ls_result-closingdebittran = lv_closing.
      ENDIF.

      " Set key fields
      ls_result-companycode = lv_bukrs.
      ls_result-glaccountnumber = lv_racct.
      ls_result-businesspartner = lv_partner.
      ls_result-postingdatefrom = lv_date_from.
      ls_result-postingdateto = lv_date_to.

      " Get business partner name
*      ls_result-businesspartnername = get_business_partner_name( lv_partner ).

      DATA: ls_businesspartner_details TYPE zst_document_info.

      ls_businesspartner_details-supplier = lv_partner.
      ls_businesspartner_details-companycode = lv_bukrs.

      lo_common_app->get_businesspartner_details(
        EXPORTING
            i_document = ls_businesspartner_details
        IMPORTING
            o_bpdetails = DATA(ls_bp_details)
      ).

      ls_result-businesspartnername = ls_bp_details-bpname.

      APPEND ls_result TO lt_result.
      CLEAR: lt_each_page, lt_each_page_faglfcv, lt_line_items, ls_result, ls_bp_details.
    ENDLOOP.

    " Thêm để lấy số không có phát sinh
    DATA: lt_where_clauses_open TYPE TABLE OF string.

    APPEND | supplier IN @lr_partner| TO lt_where_clauses_open.
    APPEND |AND postingdate < '{ lv_date_from }'| TO lt_where_clauses_open.
    APPEND |AND companycode IN @lr_bukrs| TO lt_where_clauses_open.
    APPEND |AND ledger = '0L'| TO lt_where_clauses_open.
    APPEND |AND financialaccounttype = 'K'| TO lt_where_clauses_open.
    APPEND |AND supplier IS NOT NULL| TO lt_where_clauses_open.
    APPEND |AND debitcreditcode IN ('S', 'H')| TO lt_where_clauses_open.
    APPEND |AND glaccount IN @lr_racct| TO lt_where_clauses_open.

    IF lr_currency IS NOT INITIAL AND ls_curr-low NE 'VND'.
      APPEND |AND transactioncurrency IN @lr_currency| TO lt_where_clauses_open.
    ENDIF.

    " 3. Fetch open and end balances in bulk
    SELECT supplier AS bp,
           companycode AS rbukrs,
           SUM( CASE WHEN debitcreditcode = 'S' THEN amountincompanycodecurrency ELSE 0 END ) AS open_debit,
           SUM( CASE WHEN debitcreditcode = 'H' THEN amountincompanycodecurrency ELSE 0 END ) AS open_credit,
           SUM( CASE WHEN debitcreditcode = 'S' THEN amountintransactioncurrency ELSE 0 END ) AS open_debit_tran,
           SUM( CASE WHEN debitcreditcode = 'H' THEN amountintransactioncurrency ELSE 0 END ) AS open_credit_tran,
           companycodecurrency,
           transactioncurrency,
           glaccount
      FROM i_journalentryitem
      WHERE (lt_where_clauses_open)
      GROUP BY supplier, companycode, transactioncurrency, companycodecurrency, glaccount
      INTO TABLE @DATA(lt_open_balances).

***bổ sung logic lấy thêm từ chức năng đánh giá chênh lệch tỷ giá***
    " lấy sinh dư đầu kỳ
    FREE: lt_where_clauses_open.

    APPEND | account IN @lr_partner| TO lt_where_clauses_open.
    APPEND |AND keydate < '{ lv_date_from }'| TO lt_where_clauses_open.
    APPEND |AND ccode IN @lr_bukrs| TO lt_where_clauses_open.
    APPEND |AND account IS NOT NULL| TO lt_where_clauses_open.
    APPEND |AND debcred_ind IN ('S', 'H')| TO lt_where_clauses_open.
    APPEND |AND gl_account IN @lr_racct| TO lt_where_clauses_open.

    IF lr_currency IS NOT INITIAL AND ls_curr-low NE 'VND'.
      APPEND |AND currency IN @lr_currency| TO lt_where_clauses_open.
    ENDIF.

    SELECT account AS bp,
           ccode AS rbukrs,
           SUM( CASE WHEN debcred_ind = 'S' THEN posting_amount ELSE 0 END ) AS open_debit_faglfcv,
           SUM( CASE WHEN debcred_ind = 'H' THEN posting_amount ELSE 0 END ) AS open_credit_faglfcv,
           currency,
           target_currency,
           gl_account
      FROM zui_in_faglfcv
      WHERE (lt_where_clauses_open)
      GROUP BY account, ccode, currency, target_currency, gl_account
      INTO TABLE @DATA(lt_open_balances_faglfcv).
    SORT lt_open_balances_faglfcv BY rbukrs bp gl_account currency target_currency ASCENDING.
********************************************************************

    SORT lt_result BY CompanyCode BusinessPartner GLAccountNumber TransactionCurrency CompanyCodeCurrency ASCENDING.

    LOOP AT lt_open_balances  INTO DATA(ls_ko_phat_sinh).
      READ TABLE lt_result WITH KEY CompanyCode = ls_ko_phat_sinh-rbukrs
                                    BusinessPartner = ls_ko_phat_sinh-bp
                                    GLAccountNumber = ls_ko_phat_sinh-GLAccount
                                    TransactionCurrency = ls_ko_phat_sinh-TransactionCurrency
                                    CompanyCodeCurrency = ls_ko_phat_sinh-CompanyCodeCurrency
                                    TRANSPORTING NO FIELDS.

      IF sy-subrc <> 0.
        ls_result-TransactionCurrency = ls_ko_phat_sinh-TransactionCurrency.
        ls_result-companycodecurrency = ls_ko_phat_sinh-CompanyCodeCurrency.

        ls_result-CompanyCode = ls_ko_phat_sinh-rbukrs.
        ls_result-companyname = ls_companycode_info-companycodename.
        ls_result-companyaddress = ls_companycode_info-companycodeaddr.
        ls_result-BusinessPartner = ls_ko_phat_sinh-bp.

        CLEAR: ls_businesspartner_details, ls_bp_details.

        ls_businesspartner_details-companycode = ls_ko_phat_sinh-rbukrs.
        ls_businesspartner_details-supplier = ls_ko_phat_sinh-bp.

        lo_common_app->get_businesspartner_details(
          EXPORTING
              i_document = ls_businesspartner_details
          IMPORTING
              o_bpdetails = ls_bp_details
        ).

*        ls_result-businesspartnername = get_business_partner_name( ls_ko_phat_sinh-bp ).
        ls_result-businesspartnername = ls_bp_details-bpname.
        ls_result-GLAccountNumber = ls_ko_phat_sinh-GLAccount.

        DATA: ls_line_item  LIKE LINE OF lt_line_items,
              lv_chenh_lech TYPE zui_in_faglfcv-posting_amount.

        READ TABLE lt_open_balances_faglfcv INTO DATA(ls_open_balances_faglfcv) WITH KEY rbukrs = ls_ko_phat_sinh-rbukrs
                                                                                         bp = ls_ko_phat_sinh-bp
                                                                                         gl_account = ls_ko_phat_sinh-GLAccount
                                                                                         currency = ls_ko_phat_sinh-TransactionCurrency
                                                                                         target_currency = ls_ko_phat_sinh-CompanyCodeCurrency
                                                                                         BINARY SEARCH.

        CLEAR: lv_chenh_lech.
        lv_chenh_lech = ls_open_balances_faglfcv-open_debit_faglfcv + ls_open_balances_faglfcv-open_credit_faglfcv.

        IF ls_ko_phat_sinh-open_debit + ls_ko_phat_sinh-open_credit + lv_chenh_lech > 0.
          ls_result-openingdebitbalance = ls_ko_phat_sinh-open_debit + ls_ko_phat_sinh-open_credit + lv_chenh_lech.
          ls_result-openingcreditbalance = 0.
        ELSEIF ls_ko_phat_sinh-open_debit + ls_ko_phat_sinh-open_credit + lv_chenh_lech < 0.
          ls_result-openingdebitbalance = 0.
          ls_result-openingcreditbalance = abs( ls_ko_phat_sinh-open_debit + ls_ko_phat_sinh-open_credit + lv_chenh_lech ).
        ENDIF.

        ls_result-openingdebitbalancetran = ls_ko_phat_sinh-open_debit_tran.
        ls_result-openingcreditbalancetran = ls_ko_phat_sinh-open_credit_tran * -1.

        ls_result-closingdebit = ls_result-openingdebitbalance.
        ls_result-ClosingDebitTran = ls_result-OpeningDebitBalanceTran.
        ls_result-closingcredit = ls_result-openingcreditbalance.
        ls_result-closingcredittran = ls_result-openingcreditbalancetran.

*        READ TABLE lt_in_faglfcv INTO DATA(ls_ko_phat_sinh_faglfcv) WITH KEY ccode = ls_ko_phat_sinh-rbukrs
*                                                                             account = ls_ko_phat_sinh-bp
*                                                                             gl_account = ls_ko_phat_sinh-GLAccount
*                                                                             currency = ls_ko_phat_sinh-TransactionCurrency
*                                                                             target_currency = ls_ko_phat_sinh-CompanyCodeCurrency
*                                                                             BINARY SEARCH.

        LOOP AT lt_in_faglfcv INTO DATA(ls_ko_phat_sinh_faglfcv) WHERE ccode = ls_ko_phat_sinh-rbukrs
                                                                   AND account = ls_ko_phat_sinh-bp
                                                                   AND gl_account = ls_ko_phat_sinh-GLAccount
                                                                   AND currency = ls_ko_phat_sinh-TransactionCurrency
                                                                   AND target_currency = ls_ko_phat_sinh-CompanyCodeCurrency.

          ls_line_item-posting_date = ls_ko_phat_sinh_faglfcv-keydate.
*          ls_line_item-document_number = ls_ko_phat_sinh_faglfcv-doc_number.
          ls_line_item-document_number = ||.
          ls_line_item-document_date = ls_ko_phat_sinh_faglfcv-keydate.
          ls_line_item-transactioncurrency = ls_ko_phat_sinh_faglfcv-currency.
          ls_line_item-companycodecurrency = ls_ko_phat_sinh_faglfcv-target_currency.
          ls_line_item-item_text = |Đánh giá chênh lệch tỷ giá|.

          CLEAR: lv_chenh_lech.
          lv_chenh_lech = ls_ko_phat_sinh_faglfcv-debit_faglfcv + ls_ko_phat_sinh_faglfcv-credit_faglfcv.

          IF lv_chenh_lech > 0.
            ls_line_item-contra_account = '5151001010'.

            ls_line_item-debit_amount = lv_chenh_lech.
            ls_result-DebitAmountDuringPeriod = ls_result-DebitAmountDuringPeriod + ls_line_item-debit_amount.
          ELSE.
            ls_line_item-contra_account = '6351001000'.

            ls_line_item-credit_amount = lv_chenh_lech * -1.
            ls_result-CreditAmountDuringPeriod = ls_result-CreditAmountDuringPeriod + ls_line_item-credit_amount.
          ENDIF.

          IF ls_ko_phat_sinh_faglfcv-keydate+6(2) = 1.
            IF lv_chenh_lech < 0.
              ls_line_item-contra_account = '5151001010'.
            ELSE.
              ls_line_item-contra_account = '6351001000'.
            ENDIF.
          ENDIF.

          IF ls_result-closingcredit - ls_result-closingdebit - lv_chenh_lech > 0.
            ls_result-closingcredit = ls_result-closingcredit - ls_result-closingdebit - lv_chenh_lech.
            ls_result-closingdebit = 0.
          ELSEIF ls_result-closingcredit - ls_result-closingdebit - lv_chenh_lech < 0.
            ls_result-closingcredit = 0.
            ls_result-closingdebit = abs( ls_result-closingcredit - ls_result-closingdebit - lv_chenh_lech ).
          ENDIF.

          ls_line_item-debit_amount = COND #( WHEN ls_ko_phat_sinh_faglfcv-target_currency = 'VND'
                                              THEN ls_line_item-debit_amount * 100
                                              ELSE ls_line_item-debit_amount ).
          ls_line_item-credit_amount = COND #( WHEN ls_ko_phat_sinh_faglfcv-target_currency = 'VND'
                                               THEN ls_line_item-credit_amount * 100
                                               ELSE ls_line_item-credit_amount ).

          APPEND ls_line_item TO lt_line_items.
          CLEAR: ls_line_item.
        ENDLOOP.

        " Convert line items to JSON
        ls_result-lineitemsjson = convert_line_items_to_json( lt_line_items ).

        ls_result-postingdatefrom = lv_date_from.
        ls_result-postingdateto = lv_date_to.

        APPEND ls_result TO lt_result.
        CLEAR: ls_result, ls_ko_phat_sinh, ls_open_balances_faglfcv, ls_ko_phat_sinh_faglfcv, ls_line_item, lt_line_items.
      ENDIF.
    ENDLOOP.

    " Nếu tran curency = 'VND', bỏ tran amount chỉ lấy company amount.
    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
      IF <fs_result>-TransactionCurrency = 'VND' OR ls_curr-low = 'VND'.
        CLEAR:
        <fs_result>-OpeningCreditBalanceTran,
        <fs_result>-OpeningDebitBalanceTran,
        <fs_result>-CreditAmountDuringPeriodTran,
        <fs_result>-DebitAmountDuringPeriodTran,
        <fs_result>-ClosingCreditTran,
        <fs_result>-ClosingDebitTran.
      ENDIF.
    ENDLOOP.

    " 4. Sorting
    DATA(sort_order) = VALUE abap_sortorder_tab(
      FOR sort_element IN io_request->get_sort_elements( )
      ( name = sort_element-element_name descending = sort_element-descending ) ).
    IF sort_order IS NOT INITIAL.
      SORT lt_result BY (sort_order).
    ENDIF.

    DATA(lv_total_records) = lines( lt_result ).

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
      io_response->set_total_number_of_records( lines( lt_result ) ).
    ENDIF.
  ENDMETHOD.


  METHOD process_period_data.
    DATA: ls_line_item       TYPE zst_line_item_detail,
          lv_running_balance TYPE wrbtr.

    CLEAR: et_line_items, ev_debit_total, ev_credit_total.

    " Sort by date and document
    DATA(lt_journal_items) = it_journal_items.
    SORT lt_journal_items BY postingdate accountingdocument.

    DATA(lt_in_faglfcv) = it_in_faglfcv.
    SORT lt_in_faglfcv BY ccode account gl_account.

    DATA: lt_where_clauses TYPE TABLE OF string.

    APPEND | supplier = @iv_partner| TO lt_where_clauses.
    APPEND |AND postingdate < @iv_date_from| TO lt_where_clauses.
    APPEND |AND companycode = @iv_bukrs| TO lt_where_clauses.
    APPEND |AND ledger = '0L'| TO lt_where_clauses.
    APPEND |AND financialaccounttype = 'K'| TO lt_where_clauses.
    APPEND |AND supplier IS NOT NULL| TO lt_where_clauses.
    APPEND |AND debitcreditcode IN ('S', 'H')| TO lt_where_clauses.
    APPEND |AND glaccount = @iv_racct| TO lt_where_clauses.

    IF iv_currency IS NOT INITIAL.
      APPEND |AND transactioncurrency = @iv_currency| TO lt_where_clauses.
    ENDIF.

    SELECT supplier AS bp,
           companycode AS rbukrs,
           SUM( CASE WHEN debitcreditcode = 'S' THEN amountincompanycodecurrency ELSE 0 END ) AS open_debit,
           SUM( CASE WHEN debitcreditcode = 'H' THEN amountincompanycodecurrency ELSE 0 END ) AS open_credit,
           SUM( CASE WHEN debitcreditcode = 'S' THEN amountintransactioncurrency ELSE 0 END ) AS open_debit_tran,
           SUM( CASE WHEN debitcreditcode = 'H' THEN amountintransactioncurrency ELSE 0 END ) AS open_credit_tran,
           transactioncurrency,
           companycodecurrency,
           glaccount
      FROM i_journalentryitem
      WHERE  (lt_where_clauses)
      GROUP BY supplier, companycode, transactioncurrency, companycodecurrency, glaccount
      INTO TABLE @DATA(lt_open_balances).
    SORT lt_open_balances BY bp rbukrs.
    READ TABLE lt_open_balances INTO DATA(ls_open_balance) WITH KEY bp = iv_partner rbukrs = iv_bukrs.

    " Get account nature for balance calculation
    DATA(lv_account_nature) = determine_account_nature( iv_racct ).

    LOOP AT lt_journal_items INTO DATA(ls_item).
      CLEAR ls_line_item.

      ls_line_item-posting_date = ls_item-postingdate.
      ls_line_item-document_number = ls_item-accountingdocument.
      ls_line_item-document_date = ls_item-documentdate.
      ls_line_item-transactioncurrency = iv_currency.
      ls_line_item-companycodecurrency = ls_item-companycodecurrency.
      ls_line_item-profit_center = ls_item-profitcenter.

      " Get contra account
      ls_line_item-contra_account = get_contra_account(
        iv_bukrs = ls_item-companycode
        iv_accountingdoc = ls_item-accountingdocument
        iv_fiscalyear = ls_item-fiscalyear
        iv_racct = ls_item-glaccount
        iv_lineitem = ls_item-ledgergllineitem
        iv_accountingdocumentitem = ls_item-accountingdocumentitem ).

      " Set text
      ls_line_item-item_text = ls_item-documentitemtext.

      IF ls_line_item-item_text IS INITIAL.
        SELECT SINGLE accountingdocumentheadertext
          FROM I_JournalEntry
          WHERE CompanyCode = @ls_item-companycode
          AND AccountingDocument = @ls_item-accountingdocument
          INTO @DATA(ls_doc_header_text).

        ls_line_item-item_text = ls_doc_header_text.
      ENDIF.

      " Determine debit/credit amounts
      IF ls_item-debitcreditcode = 'S'.
        ls_line_item-debit_amount = ls_item-amountincompanycodecurrency .
        ev_debit_total = ev_debit_total + ls_line_item-debit_amount.
        " transaction currency
        ls_line_item-debit_amount_tran = ls_item-amountintransactioncurrency.
        ev_debit_total_tran = ev_debit_total_tran + ls_line_item-debit_amount_tran.
      ELSE.
        ls_line_item-credit_amount = ls_item-amountincompanycodecurrency * -1.
        ev_credit_total = ev_credit_total + ls_line_item-credit_amount.
        " transaction currency
        ls_line_item-credit_amount_tran = ls_item-amountintransactioncurrency * -1.
        ev_credit_total_tran = ev_credit_total_tran + ls_line_item-credit_amount_tran.
      ENDIF.

      IF ls_open_balance-open_debit + ls_open_balance-open_credit + ev_debit_total - ev_credit_total > 0.
        ls_line_item-closingdebit = ls_open_balance-open_debit + ls_open_balance-open_credit + ev_debit_total - ev_credit_total.
        ls_line_item-closingcredit = 0.
      ELSE.
        ls_line_item-closingcredit = ( ls_open_balance-open_debit + ls_open_balance-open_credit + ev_debit_total - ev_credit_total ) * -1.
        ls_line_item-closingdebit = 0.
      ENDIF.

      " transaction currency closing amounts
      IF ls_open_balance-open_debit_tran + ls_open_balance-open_credit_tran + ev_debit_total_tran - ev_credit_total_tran > 0.
        ls_line_item-closingdebit_tran = ls_open_balance-open_debit_tran + ls_open_balance-open_credit_tran + ev_debit_total_tran - ev_credit_total_tran.
        ls_line_item-closingcredit_tran = 0.
      ELSE.
        ls_line_item-closingcredit_tran = ( ls_open_balance-open_debit_tran + ls_open_balance-open_credit_tran + ev_debit_total_tran - ev_credit_total_tran ) * -1.
        ls_line_item-closingdebit_tran = 0.
      ENDIF.

      ls_line_item-debit_amount = COND #( WHEN ls_line_item-companycodecurrency = 'VND'
                                          THEN ls_line_item-debit_amount * 100
                                          ELSE ls_line_item-debit_amount ).
      ls_line_item-credit_amount = COND #( WHEN ls_line_item-companycodecurrency = 'VND'
                                           THEN ls_line_item-credit_amount * 100
                                           ELSE ls_line_item-credit_amount ).
      ls_line_item-debit_amount_tran = COND #( WHEN ls_line_item-transactioncurrency = 'VND'
                                               THEN ls_line_item-debit_amount_tran * 100
                                               ELSE ls_line_item-debit_amount_tran ).
      ls_line_item-credit_amount_tran = COND #( WHEN ls_line_item-transactioncurrency = 'VND'
                                                THEN ls_line_item-credit_amount_tran * 100
                                                ELSE ls_line_item-credit_amount_tran ).
      ls_line_item-closingdebit = COND #( WHEN ls_line_item-companycodecurrency = 'VND'
                                          THEN ls_line_item-closingdebit * 100
                                          ELSE ls_line_item-closingdebit ).
      ls_line_item-closingcredit = COND #( WHEN ls_line_item-companycodecurrency = 'VND'
                                           THEN ls_line_item-closingcredit * 100
                                           ELSE ls_line_item-closingcredit ).
      ls_line_item-closingdebit_tran = COND #( WHEN ls_line_item-transactioncurrency = 'VND'
                                               THEN ls_line_item-closingdebit_tran * 100
                                               ELSE ls_line_item-closingdebit_tran ).
      ls_line_item-closingcredit_tran = COND #( WHEN ls_line_item-transactioncurrency = 'VND'
                                                THEN ls_line_item-closingcredit_tran * 100
                                                ELSE ls_line_item-closingcredit_tran ).
      APPEND ls_line_item TO et_line_items.
      CLEAR: ls_line_item.
    ENDLOOP.

    IF lt_in_faglfcv IS NOT INITIAL.
      DATA: lv_chenh_lech TYPE zui_in_faglfcv-posting_amount.

      LOOP AT lt_in_faglfcv INTO DATA(ls_in_faglfcv).
        lv_chenh_lech = ls_in_faglfcv-debit_faglfcv + ls_in_faglfcv-credit_faglfcv.

        ls_line_item-posting_date = ls_in_faglfcv-keydate.
*        ls_line_item-document_number = ls_in_faglfcv-doc_number.
        ls_line_item-document_number = ||.
        ls_line_item-document_date = ls_in_faglfcv-keydate.
        ls_line_item-transactioncurrency = ls_in_faglfcv-currency.
        ls_line_item-companycodecurrency = ls_in_faglfcv-target_currency.
        ls_line_item-item_text = |Đánh giá chênh lệch tỷ giá|.

        IF lv_chenh_lech > 0.
          ls_line_item-contra_account = '5151001010'.

          ls_line_item-debit_amount = lv_chenh_lech.
          ev_debit_total = ev_debit_total + ls_line_item-debit_amount.
        ELSE.
          ls_line_item-contra_account = '6351001000'.

          ls_line_item-credit_amount = lv_chenh_lech * -1.
          ev_credit_total = ev_credit_total + ls_line_item-credit_amount.
        ENDIF.

        IF ls_in_faglfcv-keydate+6(2) = 1.
          IF lv_chenh_lech < 0.
            ls_line_item-contra_account = '5151001010'.
          ELSE.
            ls_line_item-contra_account = '6351001000'.
          ENDIF.
        ENDIF.

        IF ls_open_balance-open_debit + ls_open_balance-open_credit + lv_chenh_lech + ev_debit_total - ev_credit_total > 0.
          ls_line_item-closingdebit = ls_open_balance-open_debit + ls_open_balance-open_credit + lv_chenh_lech + ev_debit_total - ev_credit_total.
          ls_line_item-closingcredit = 0.
        ELSE.
          ls_line_item-closingcredit = ( ls_open_balance-open_debit + ls_open_balance-open_credit + lv_chenh_lech + ev_debit_total - ev_credit_total ) * -1.
          ls_line_item-closingdebit = 0.
        ENDIF.

        ls_line_item-debit_amount = COND #( WHEN ls_in_faglfcv-target_currency = 'VND'
                                            THEN ls_line_item-debit_amount * 100
                                            ELSE ls_line_item-debit_amount ) .
        ls_line_item-credit_amount = COND #( WHEN ls_in_faglfcv-target_currency = 'VND'
                                             THEN ls_line_item-credit_amount * 100
                                             ELSE ls_line_item-credit_amount ) .

        APPEND ls_line_item TO et_line_items.
        CLEAR: ls_line_item.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

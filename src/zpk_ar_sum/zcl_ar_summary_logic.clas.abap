CLASS zcl_ar_summary_logic DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ar_summary_logic IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TYPES: BEGIN OF lty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF lty_range_option.

    DATA: lt_result        TYPE TABLE OF zc_accrec_summary,
          lv_start_date    TYPE zc_accrec_summary-p_start_date,
          lv_end_date      TYPE zc_accrec_summary-p_end_date,
          lt_range         TYPE TABLE OF lty_range_option,
          lv_compcode_prov TYPE abap_bool,
          lv_bpgroup_prov  TYPE abap_bool,
          lv_account_prov  TYPE abap_bool,
          lv_partner_prov  TYPE abap_bool,
          lv_currency_prov TYPE abap_bool,
          lr_companycode   TYPE RANGE OF i_journalentryitem-companycode,
          lr_bpgroup       TYPE RANGE OF i_businesspartner-businesspartnergrouping,
          lr_account       TYPE RANGE OF i_journalentryitem-glaccount,
          lr_partner       TYPE RANGE OF i_journalentryitem-Customer,
          lv_currency      TYPE zc_accrec_summary-rhcur,
          lr_currency      TYPE RANGE OF i_journalentryitem-TransactionCurrency.
    CLEAR: lt_result.

    " 1. Extract filter parameters
    CHECK io_request IS BOUND.
    TRY.
        DATA(lo_filter) = io_request->get_filter( ).
        CHECK lo_filter IS BOUND.
        DATA(lt_filter_ranges) = lo_filter->get_as_ranges( ).

        " Mandatory date filters
        READ TABLE lt_filter_ranges INTO DATA(ls_start_date) WITH KEY name = 'P_START_DATE'.
        IF sy-subrc = 0 AND ls_start_date-range IS NOT INITIAL.
          lv_start_date = ls_start_date-range[ 1 ]-low.
        ENDIF.

        READ TABLE lt_filter_ranges INTO DATA(ls_end_date) WITH KEY name = 'P_END_DATE'.
        IF sy-subrc = 0 AND ls_end_date-range IS NOT INITIAL.
          lv_end_date = ls_end_date-range[ 1 ]-low.
        ENDIF.
        "Mandatory currency filter
*        READ TABLE lt_filter_ranges INTO DATA(ls_currency) WITH KEY name = 'RHCUR'.
*        IF sy-subrc = 0 AND ls_currency-range IS NOT INITIAL.
*          lv_currency = ls_currency-range[ 1 ]-low.
*        ENDIF.

        " Optional filters with ALPHA conversion
        TRY.
            DATA(lr_currency_raw) = lt_filter_ranges[ name = 'RHCUR' ]-range.
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
            DATA(lr_compcode_raw) = lt_filter_ranges[ name = 'RBUKRS' ]-range.
            LOOP AT lr_compcode_raw ASSIGNING FIELD-SYMBOL(<fs_compcode>).
              IF <fs_compcode>-low IS NOT INITIAL.
                <fs_compcode>-low = |{ <fs_compcode>-low ALPHA = IN WIDTH = 4 }|.
              ENDIF.
              IF <fs_compcode>-high IS NOT INITIAL.
                <fs_compcode>-high = |{ <fs_compcode>-high ALPHA = IN WIDTH = 4 }|.
              ENDIF.
            ENDLOOP.
            MOVE-CORRESPONDING lr_compcode_raw TO lr_companycode.
            lv_compcode_prov = abap_true.
          CATCH cx_sy_itab_line_not_found.
            CLEAR lr_companycode.
        ENDTRY.

        TRY.
            DATA(lr_partner_raw) = lt_filter_ranges[ name = 'BP' ]-range.
            LOOP AT lr_partner_raw ASSIGNING FIELD-SYMBOL(<fs_partner>).
              IF <fs_partner>-low IS NOT INITIAL.
                <fs_partner>-low = |{ <fs_partner>-low ALPHA = IN WIDTH = 10 }|.
              ENDIF.
              IF <fs_partner>-high IS NOT INITIAL.
                <fs_partner>-high = |{ <fs_partner>-high ALPHA = IN WIDTH = 10 }|.
              ENDIF.
            ENDLOOP.
            MOVE-CORRESPONDING lr_partner_raw TO lr_partner.
            lv_partner_prov = abap_true.
          CATCH cx_sy_itab_line_not_found.
            CLEAR lr_partner.
        ENDTRY.

        TRY.
            DATA(lr_account_raw) = lt_filter_ranges[ name = 'ACCOUNTNUMBER' ]-range.
            LOOP AT lr_account_raw ASSIGNING FIELD-SYMBOL(<fs_account>).
              IF <fs_account>-low IS NOT INITIAL.
                <fs_account>-low = |{ <fs_account>-low ALPHA = IN WIDTH = 10 }|.
              ENDIF.
              IF <fs_account>-high IS NOT INITIAL.
                <fs_account>-high = |{ <fs_account>-high ALPHA = IN WIDTH = 10 }|.
              ENDIF.
            ENDLOOP.
            MOVE-CORRESPONDING lr_account_raw TO lr_account.
            lv_account_prov = abap_true.
          CATCH cx_sy_itab_line_not_found.
            CLEAR lr_account.
        ENDTRY.

        TRY.
            DATA(lr_bpgroup_raw) = lt_filter_ranges[ name = 'BP_GR' ]-range.
            LOOP AT lr_bpgroup_raw ASSIGNING FIELD-SYMBOL(<fs_bpgr>).
              IF <fs_bpgr>-low IS NOT INITIAL.
                <fs_bpgr>-low = |{ <fs_bpgr>-low ALPHA = IN WIDTH = 4 }|.
              ENDIF.
              IF <fs_bpgr>-high IS NOT INITIAL.
                <fs_bpgr>-high = |{ <fs_bpgr>-high ALPHA = IN WIDTH = 4 }|.
              ENDIF.
            ENDLOOP.
            MOVE-CORRESPONDING lr_bpgroup_raw TO lr_bpgroup.
            lv_bpgroup_prov = abap_true.
          CATCH cx_sy_itab_line_not_found.
            CLEAR lr_bpgroup.
        ENDTRY.

      CATCH cx_rap_query_filter_no_range INTO DATA(lx_filter_error).
        " Log error or raise message for debugging
        RETURN.
    ENDTRY.

    DATA: lw_company          TYPE bukrs,
          ls_companycode_info TYPE zst_companycode_info.
    lw_company = lr_companycode[ 1 ]-low.
    CALL METHOD zcl_jp_common_core=>get_companycode_details
      EXPORTING
        i_companycode = lw_company
      IMPORTING
        o_companycode = ls_companycode_info.

    DATA: lt_where_clauses TYPE TABLE OF string.
    APPEND | postingdate >= @lv_start_date AND postingdate <= @lv_end_date| TO lt_where_clauses.
    APPEND |AND financialaccounttype = 'D'| TO lt_where_clauses.
    APPEND |AND customer IS NOT NULL| TO lt_where_clauses.
    APPEND |AND debitcreditcode IN ('S', 'H')| TO lt_where_clauses.
    APPEND |AND ledger = '0L'| TO lt_where_clauses.

    IF lv_compcode_prov = abap_true.
      APPEND |AND companycode IN @lr_companycode| TO lt_where_clauses.
    ENDIF.
    IF lv_partner_prov = abap_true.
      APPEND |AND customer IN @lr_partner| TO lt_where_clauses.
    ENDIF.
    IF lv_account_prov = abap_true.
      APPEND |AND glaccount IN @lr_account| TO lt_where_clauses.
    ENDIF.

    READ TABLE lr_currency INTO DATA(ls_curr) INDEX 1.

    IF lv_currency_prov = abap_true AND ls_curr-low NE 'VND'.
      APPEND |AND transactioncurrency IN @lr_currency| TO lt_where_clauses.
    ENDIF.

    " 2. Aggregate customer data from I_JournalEntryItem
    " select total debit and credit amounts for each customer, company code, currency, and GL account in period
    SELECT companycode AS rbukrs,
           customer AS bp,
           transactioncurrency AS rhcur,
           glaccount AS accountnumber,
           CompanyCodeCurrency,
           SUM( CASE WHEN debitcreditcode = 'S' THEN amountincompanycodecurrency ELSE 0 END ) AS total_debit,
           SUM( CASE WHEN debitcreditcode = 'H' THEN amountincompanycodecurrency ELSE 0 END ) AS total_credit,
           SUM( CASE WHEN debitcreditcode = 'S' THEN AmountInTransactionCurrency ELSE 0 END ) AS total_debit_tran,
           SUM( CASE WHEN debitcreditcode = 'H' THEN AmountInTransactionCurrency ELSE 0 END ) AS total_credit_tran
      FROM i_journalentryitem
      WHERE (lt_where_clauses)
      GROUP BY companycode, customer, transactioncurrency, glaccount, CompanyCodeCurrency
      INTO TABLE @DATA(lt_items).
    SORT lt_items BY bp.

    DATA: ls_items LIKE LINE OF lt_items.

    SELECT companycode AS rbukrs,
           customer AS bp,
           transactioncurrency AS rhcur,
           glaccount AS accountnumber,
           fiscalyear,
           accountingdocument,
           isreversed,
           reversalreferencedocument,
           reversalreferencedocumentcntxt,
           debitcreditcode,
           amountincompanycodecurrency,
           amountintransactioncurrency,
           transactioncurrency,
           companycodecurrency
        FROM i_journalentryitem
        WHERE (lt_where_clauses)
        INTO TABLE @DATA(lt_items_temp).
    SORT lt_items_temp BY rbukrs accountnumber fiscalyear ASCENDING.

    SELECT companycode,
           FiscalYear,
           AccountingDocument,
           IsReversal,
           IsReversed,
           ReverseDocument,
           OriginalReferenceDocument
        FROM i_journalentry
        FOR ALL ENTRIES IN @lt_items_temp
        WHERE companycode = @lt_items_temp-rbukrs
        AND AccountingDocument = @lt_items_temp-accountingdocument
        AND FiscalYear = @lt_items_temp-fiscalyear
        INTO TABLE @DATA(lt_journal_headers).
    SORT lt_journal_headers BY CompanyCode AccountingDocument FiscalYear ASCENDING.

    " loại bỏ cặp chứng từ hủy cùng kỳ.
    DATA: lt_huy       LIKE lt_items_temp,
          ls_huy       LIKE LINE OF lt_huy,
          lv_index_huy TYPE sy-tabix,

          lv_length    TYPE n LENGTH 3,
          lv_docnum    TYPE i_journalentryitem-AccountingDocument,
          lv_year      TYPE i_journalentryitem-FiscalYear.

    lt_huy = lt_items_temp.


    SORT lt_huy BY rbukrs AccountingDocument FiscalYear ASCENDING.

    LOOP AT lt_huy INTO DATA(ls_check_item) WHERE isreversed IS NOT INITIAL.
      lv_index_huy = sy-tabix.

      READ TABLE lt_journal_headers INTO DATA(ls_check_header) WITH KEY CompanyCode = ls_check_item-rbukrs
                                                                        AccountingDocument = ls_check_item-accountingdocument
                                                                        FiscalYear = ls_check_item-fiscalyear BINARY SEARCH.

      IF sy-subrc = 0.
        lv_length = strlen( ls_check_header-OriginalReferenceDocument ) - 4.
        lv_docnum = ls_check_header-OriginalReferenceDocument(lv_length).
        lv_year = ls_check_header-OriginalReferenceDocument+lv_length.

        IF lv_docnum IS NOT INITIAL.
          DELETE lt_items_temp WHERE reversalreferencedocument = lv_docnum AND fiscalyear = lv_year.
          IF sy-subrc = 0.
            DELETE lt_items_temp WHERE accountingdocument = ls_check_item-accountingdocument AND fiscalyear = lv_year.
          ENDIF.
        ENDIF.
      ENDIF.

      CLEAR: ls_check_item, ls_check_header, lv_length, lv_docnum, lv_year.
    ENDLOOP.

    FREE: lt_items.

    LOOP AT lt_items_temp INTO DATA(lg_journal_items)
    GROUP BY (
        companycode = lg_journal_items-rbukrs
        glaccount = lg_journal_items-accountnumber
        customer =  lg_journal_items-bp
        companycodecurrency = lg_journal_items-companycodecurrency
        transactioncurrency = lg_journal_items-rhcur
    )
    ASSIGNING FIELD-SYMBOL(<group>).

      ls_items-rbukrs = <group>-companycode.
      ls_items-bp = <group>-customer.
      ls_items-accountnumber = <group>-glaccount.
      ls_items-CompanyCodeCurrency = <group>-companycodecurrency .
      ls_items-rhcur = <group>-transactioncurrency.

      LOOP AT lt_items_temp INTO DATA(ls_items_temp) WHERE rbukrs = <group>-companycode
                                                     AND accountnumber = <group>-glaccount
                                                     AND bp = <group>-customer
                                                     AND CompanyCodeCurrency = <group>-companycodecurrency
                                                     AND TransactionCurrency = <group>-transactioncurrency.

        IF ls_items_temp-debitcreditcode = 'S'.
          ls_items-total_debit = ls_items-total_debit + ls_items_temp-amountincompanycodecurrency.
          ls_items-total_debit_tran = ls_items-total_debit_tran + ls_items_temp-amountintransactioncurrency.
        ELSEIF ls_items_temp-debitcreditcode = 'H'.
          ls_items-total_credit = ls_items-total_credit + ls_items_temp-amountincompanycodecurrency.
          ls_items-total_credit_tran = ls_items-total_credit_tran + ls_items_temp-amountintransactioncurrency.
        ENDIF.

        CLEAR: ls_items_temp.
      ENDLOOP.

      APPEND ls_items TO lt_items.
      CLEAR: ls_items, lg_journal_items.
    ENDLOOP.

    DATA: lt_where_clauses_open TYPE TABLE OF string.

    APPEND |customer IN @lr_partner| TO lt_where_clauses_open.
    APPEND |AND postingdate < @lv_start_date| TO lt_where_clauses_open.
    APPEND |AND companycode IN @lr_companycode| TO lt_where_clauses_open.
    APPEND |AND ledger = '0L'| TO lt_where_clauses_open.
    APPEND |AND financialaccounttype = 'D'| TO lt_where_clauses_open.
    APPEND |AND customer IS NOT NULL| TO lt_where_clauses_open.
    APPEND |AND debitcreditcode IN ('S', 'H')| TO lt_where_clauses_open.
    APPEND |AND glaccount IN @lr_account| TO lt_where_clauses_open.

    IF lr_currency IS NOT INITIAL.
      APPEND |AND transactioncurrency IN @lr_currency| TO lt_where_clauses_open.
    ENDIF.

    " 3. Fetch open and end balances in bulk
    SELECT customer AS bp,
           companycode AS rbukrs,
           SUM( CASE WHEN debitcreditcode = 'S' THEN amountincompanycodecurrency ELSE 0 END ) AS open_debit,
           SUM( CASE WHEN debitcreditcode = 'H' THEN amountincompanycodecurrency ELSE 0 END ) AS open_credit,
           SUM( CASE WHEN debitcreditcode = 'S' THEN AmountInTransactionCurrency ELSE 0 END ) AS open_debit_tran,
           SUM( CASE WHEN debitcreditcode = 'H' THEN AmountInTransactionCurrency ELSE 0 END ) AS open_credit_tran,
           CompanyCodeCurrency,
           transactioncurrency,
           glaccount
      FROM i_journalentryitem
      WHERE (lt_where_clauses_open)
      GROUP BY customer, companycode, transactioncurrency, CompanyCodeCurrency, glaccount
      INTO TABLE @DATA(lt_open_balances).

    SORT lt_open_balances BY rbukrs bp glaccount transactioncurrency companycodecurrency ASCENDING.

    " 4. Fetch customer details
    SELECT customer AS bp,
           customername AS bp_name,
           businesspartnername1 AS bp_name_1,
           businesspartnername2 AS bp_name_2,
           businesspartnername3 AS bp_name_3,
           businesspartnername4 AS bp_name_4
      FROM i_customer
      WHERE customer IN @lr_partner
      INTO TABLE @DATA(lt_customers).
    SORT lt_customers BY bp.

    SELECT b~businesspartner AS bp,
           b~businesspartnergrouping AS bp_gr,
           t~businesspartnergroupingtext AS bp_gr_title
      FROM i_businesspartner AS b
      LEFT OUTER JOIN i_businesspartnergroupingtext AS t
        ON t~businesspartnergrouping = b~businesspartnergrouping
        AND t~language = @sy-langu
      WHERE b~businesspartner IN @lr_partner
        AND b~businesspartnergrouping IN @lr_bpgroup
      INTO TABLE @DATA(lt_bp_groups).
    SORT lt_bp_groups BY bp.

    DATA(lo_common_app) = zcl_jp_common_core=>get_instance( ).

    " 5. Build result table
    LOOP AT lt_items INTO DATA(ls_item).
      DATA(ls_result) = VALUE zc_accrec_summary(
          companyname = ls_companycode_info-companycodename
          companyaddr = ls_companycode_info-companycodeaddr
          rbukrs = ls_item-rbukrs
          bp = ls_item-bp
          rhcur = ls_item-rhcur
          companycodecurrency = ls_item-CompanyCodeCurrency
          accountnumber = ls_item-accountnumber
          total_debit = ls_item-total_debit
          total_credit = ls_item-total_credit
          total_debit_tran = ls_item-total_debit_tran
          total_credit_tran = ls_item-total_credit_tran
          p_start_date = lv_start_date
          p_end_date = lv_end_date
      ).

      " Assign open balances
      READ TABLE lr_currency INTO DATA(ls_currency) INDEX 1.
      READ TABLE lt_open_balances INTO DATA(ls_open) WITH KEY rbukrs = ls_item-rbukrs
                                                              bp = ls_item-bp
                                                              glaccount = ls_item-accountnumber
                                                              TransactionCurrency = ls_item-rhcur
                                                              CompanyCodeCurrency = ls_item-CompanyCodeCurrency
                                                              BINARY SEARCH.
      IF sy-subrc = 0.
        DATA(lv_index) = sy-tabix.

        ls_result-open_debit = ls_open-open_debit.
        ls_result-open_credit = ls_open-open_credit.
        ls_result-open_debit_tran = ls_open-open_debit_tran.
        ls_result-open_credit_tran = ls_open-open_credit_tran.

        DELETE lt_open_balances INDEX lv_index.
      ENDIF.


      " Assign customer name
      READ TABLE lt_customers INTO DATA(ls_customer) WITH KEY bp = ls_item-bp BINARY SEARCH.
*      IF sy-subrc = 0.
*        ls_result-bp_name = ls_customer-bp_name.
*      ENDIF.

      DATA: ls_businesspartner_details TYPE zst_document_info.

      ls_businesspartner_details-supplier = ls_result-bp.
      ls_businesspartner_details-companycode = ls_result-rbukrs.

      lo_common_app->get_businesspartner_details(
        EXPORTING
            i_document = ls_businesspartner_details
        IMPORTING
            o_bpdetails = DATA(ls_bp_details)
      ).

      ls_result-bp_name = ls_bp_details-bpname.

      " Assign business partner group and title
      READ TABLE lt_bp_groups INTO DATA(ls_bp_group) WITH KEY bp = ls_item-bp BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-bp_gr = ls_bp_group-bp_gr.
        ls_result-bp_gr_title = ls_bp_group-bp_gr_title.
      ENDIF.

      APPEND ls_result TO lt_result.
      CLEAR ls_result.
    ENDLOOP.

    IF lv_bpgroup_prov = abap_true.
      DELETE lt_result WHERE bp_gr IS INITIAL.
    ENDIF.

    DATA: lv_open_amount TYPE zc_accrec_summary-open_debit,
          lv_end_amount  TYPE zc_accrec_summary-end_debit.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
      lv_open_amount = <fs_result>-open_credit + <fs_result>-open_debit.
      IF lv_open_amount >= 0.
        CLEAR <fs_result>-open_credit.
        <fs_result>-open_debit = lv_open_amount.
      ELSE.
        CLEAR <fs_result>-open_debit.
        <fs_result>-open_credit = lv_open_amount.
      ENDIF.
      CLEAR lv_open_amount.
      lv_end_amount = <fs_result>-open_credit + <fs_result>-open_debit
                      + <fs_result>-total_credit + <fs_result>-total_debit.
      IF lv_end_amount >= 0.
        CLEAR <fs_result>-end_credit.
        <fs_result>-end_debit = lv_end_amount.
      ELSE.
        CLEAR <fs_result>-end_debit.
        <fs_result>-end_credit = lv_end_amount.
      ENDIF.
      CLEAR lv_end_amount.
      " transaction currency amounts
      lv_open_amount = <fs_result>-open_credit_tran + <fs_result>-open_debit_tran.
      IF lv_open_amount >= 0.
        CLEAR <fs_result>-open_credit_tran.
        <fs_result>-open_debit_tran = lv_open_amount.
      ELSE.
        CLEAR <fs_result>-open_debit_tran.
        <fs_result>-open_credit_tran = lv_open_amount.
      ENDIF.
      CLEAR lv_open_amount.
      lv_end_amount = <fs_result>-open_credit_tran + <fs_result>-open_debit_tran
                      + <fs_result>-total_credit_tran + <fs_result>-total_debit_tran.
      IF lv_end_amount >= 0.
        CLEAR <fs_result>-end_credit_tran.
        <fs_result>-end_debit_tran = lv_end_amount.
      ELSE.
        CLEAR <fs_result>-end_debit_tran.
        <fs_result>-end_credit_tran = lv_end_amount.
      ENDIF.
      CLEAR lv_end_amount.
    ENDLOOP.

    " lấy thêm số không phát sinh
    LOOP AT lt_open_balances  INTO DATA(ls_ko_phat_sinh).

      ls_result-rhcur               = ls_ko_phat_sinh-TransactionCurrency.
      ls_result-companycodecurrency = ls_ko_phat_sinh-CompanyCodeCurrency.

      ls_result-bp = ls_ko_phat_sinh-bp.

*      READ TABLE lt_customers INTO ls_customer WITH KEY bp = ls_result-bp BINARY SEARCH.
*      IF sy-subrc = 0.
*        ls_result-bp_name = ls_customer-bp_name.
*      ENDIF.

      " Assign business partner group and title
      READ TABLE lt_bp_groups INTO ls_bp_group WITH KEY bp = ls_result-bp BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-bp_gr = ls_bp_group-bp_gr.
        ls_result-bp_gr_title = ls_bp_group-bp_gr_title.
      ENDIF.

      ls_result-rbukrs = ls_ko_phat_sinh-rbukrs.
      ls_result-AccountNumber = ls_ko_phat_sinh-GLAccount.
      ls_result-open_debit = ls_ko_phat_sinh-open_debit.
      ls_result-open_credit = ls_ko_phat_sinh-open_credit.
      ls_result-open_debit_tran = ls_ko_phat_sinh-open_debit_tran.
      ls_result-open_credit_tran = ls_ko_phat_sinh-open_credit_tran.

      ls_result-end_debit = ls_ko_phat_sinh-open_debit.
      ls_result-end_credit = ls_ko_phat_sinh-open_credit.
      ls_result-end_debit_tran = ls_ko_phat_sinh-open_debit_tran.
      ls_result-end_credit_tran = ls_ko_phat_sinh-open_credit_tran.

      CLEAR: ls_businesspartner_details, ls_bp_details.

      ls_businesspartner_details-customer = ls_result-bp.
      ls_businesspartner_details-companycode = ls_result-rbukrs.

      lo_common_app->get_businesspartner_details(
        EXPORTING
            i_document = ls_businesspartner_details
        IMPORTING
            o_bpdetails = ls_bp_details
      ).

      ls_result-bp_name = ls_bp_details-bpname.

      ls_result-p_start_date = lv_start_date.
      ls_result-p_end_date = lv_end_date.

      APPEND ls_result TO lt_result.
      CLEAR: ls_result, ls_customer, ls_bp_group.
    ENDLOOP.

    " 5. Change sign for all balance amounts
    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_temp>).
      <lfs_temp>-open_credit = abs( <lfs_temp>-open_credit ).
      <lfs_temp>-total_credit = <lfs_temp>-total_credit * -1.
      <lfs_temp>-end_credit = abs( <lfs_temp>-end_credit ).
      " Transaction currency amounts
      <lfs_temp>-open_credit_tran = abs( <lfs_temp>-open_credit_tran ).
      <lfs_temp>-total_credit_tran = <lfs_temp>-total_credit_tran * -1.
      <lfs_temp>-end_credit_tran = abs( <lfs_temp>-end_credit_tran ).
    ENDLOOP.

    " Remove amount if tran currency = 'VND'
    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_final>).
      IF <fs_final>-rhcur = 'VND' OR ls_curr-low = 'VND'.
        CLEAR:
        <fs_final>-open_credit_tran,
        <fs_final>-open_debit_tran,
        <fs_final>-end_credit_tran,
        <fs_final>-end_debit_tran,
        <fs_final>-total_credit_tran,
        <fs_final>-total_debit_tran.
      ENDIF.
    ENDLOOP.

***bổ sung logic lấy thêm từ chức năng đánh giá chênh lệch tỷ giá***
    " lấy sinh dư đầu kỳ
    FREE: lt_where_clauses_open.

    APPEND | account IN @lr_partner| TO lt_where_clauses_open.
    APPEND |AND keydate < @lv_start_date| TO lt_where_clauses_open.
    APPEND |AND ccode IN @lr_companycode| TO lt_where_clauses_open.
    APPEND |AND account IS NOT NULL| TO lt_where_clauses_open.
    APPEND |AND debcred_ind IN ('S', 'H')| TO lt_where_clauses_open.
    APPEND |AND gl_account IN @lr_account| TO lt_where_clauses_open.

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
    SORT lt_open_balances_faglfcv BY rbukrs bp gl_account ASCENDING.

    " lấy sinh trong kỳ
    FREE: lt_where_clauses_open.

    APPEND | account IN @lr_partner| TO lt_where_clauses_open.
    APPEND |AND keydate BETWEEN '{ lv_start_date }' AND '{ lv_end_date }'| TO lt_where_clauses_open.
    APPEND |AND ccode IN @lr_companycode| TO lt_where_clauses_open.
    APPEND |AND account IS NOT NULL| TO lt_where_clauses_open.
    APPEND |AND debcred_ind IN ('S', 'H')| TO lt_where_clauses_open.
    APPEND |AND gl_account IN @lr_account| TO lt_where_clauses_open.

    IF lr_currency IS NOT INITIAL AND ls_curr-low NE 'VND'.
      APPEND |AND currency IN @lr_currency| TO lt_where_clauses_open.
    ENDIF.

    SELECT account AS bp,
           ccode AS rbukrs,
           SUM( CASE WHEN debcred_ind = 'S' THEN posting_amount ELSE 0 END ) AS total_debit_faglfcv,
           SUM( CASE WHEN debcred_ind = 'H' THEN posting_amount ELSE 0 END ) AS total_credit_faglfcv,
           currency,
           target_currency,
           gl_account
      FROM zui_in_faglfcv
      WHERE (lt_where_clauses_open)
      GROUP BY account, ccode, currency, target_currency, gl_account
      INTO TABLE @DATA(lt_total_faglfcv).
    SORT lt_total_faglfcv BY rbukrs bp gl_account ASCENDING.

    SELECT account AS bp,
           ccode AS rbukrs,
           debcred_ind,
           posting_amount,
           currency,
           target_currency,
           gl_account
      FROM zui_in_faglfcv
      WHERE (lt_where_clauses_open)
      INTO TABLE @DATA(lt_total_faglfcv_2).
    SORT lt_total_faglfcv BY rbukrs bp gl_account ASCENDING.
********************************************************************

    DATA: lt_result_temp LIKE lt_result,
          ls_result_temp LIKE LINE OF lt_result_temp.

    LOOP AT lt_result INTO DATA(lg_result_gom)
    GROUP BY (
        companycode = lg_result_gom-rbukrs
        glaccount = lg_result_gom-accountnumber
        customer =  lg_result_gom-bp
        companycodecurrency = lg_result_gom-companycodecurrency
    ) ASSIGNING FIELD-SYMBOL(<group_gom>).
      ls_result_temp-rbukrs = <group_gom>-companycode.
      ls_result_temp-bp = <group_gom>-customer.
      ls_result_temp-accountnumber = <group_gom>-glaccount.
      ls_result_temp-CompanyCodeCurrency = <group_gom>-companycodecurrency .
*      ls_result_temp-rhcur = <group_gom>-transactioncurrency.

      LOOP AT lt_result INTO ls_result WHERE rbukrs = <group_gom>-companycode
                                       AND bp = <group_gom>-customer
                                       AND AccountNumber = <group_gom>-glaccount.

        ls_result_temp-bp_gr = ls_result-bp_gr.
        ls_result_temp-companyname = ls_result-companyname.
        ls_result_temp-companyaddr = ls_result-companyaddr.

        IF ls_result_temp-rhcur IS INITIAL AND ls_result-rhcur NE 'VND'.
          ls_result_temp-rhcur = ls_result-rhcur.
        ENDIF.

        ls_result_temp-bp_gr_title = ls_result-bp_gr_title.
        ls_result_temp-bp_name = ls_result-bp_name.

        ls_result_temp-open_debit = ls_result_temp-open_debit + ls_result-open_debit.
        ls_result_temp-open_debit_tran = ls_result_temp-open_debit_tran + ls_result-open_debit_tran.
        ls_result_temp-open_credit = ls_result_temp-open_credit + ls_result-open_credit.
        ls_result_temp-open_credit_tran = ls_result_temp-open_credit_tran + ls_result-open_credit_tran.

        ls_result_temp-total_debit = ls_result_temp-total_debit + ls_result-total_debit.
        ls_result_temp-total_debit_tran = ls_result_temp-total_debit_tran + ls_result-total_debit_tran.
        ls_result_temp-total_credit = ls_result_temp-total_credit + ls_result-total_credit.
        ls_result_temp-total_credit_tran = ls_result_temp-total_credit_tran + ls_result-total_credit_tran.

        ls_result_temp-end_debit = ls_result_temp-end_debit + ls_result-end_debit.
        ls_result_temp-end_debit_tran = ls_result_temp-end_debit_tran + ls_result-end_debit_tran.
        ls_result_temp-end_credit = ls_result_temp-end_credit + ls_result-end_credit.
        ls_result_temp-end_credit_tran = ls_result_temp-end_credit_tran + ls_result-end_credit_tran.

        ls_result_temp-p_start_date = ls_result-p_start_date.
        ls_result_temp-p_end_date = ls_result-p_end_date.

        CLEAR ls_result.
      ENDLOOP.

      DATA lv_chenh_lech TYPE zc_accpay_summary-open_credit.
      DATA lv_chenh_lech_total TYPE zc_accpay_summary-open_credit.

      READ TABLE lt_open_balances_faglfcv INTO DATA(ls_open_balances_faglfcv) WITH KEY rbukrs = <group_gom>-companycode
                                                                                       bp = <group_gom>-customer
                                                                                       gl_account = <group_gom>-glaccount.

      IF ls_open_balances_faglfcv IS NOT INITIAL.
        lv_chenh_lech = ls_open_balances_faglfcv-open_credit_faglfcv + ls_open_balances_faglfcv-open_debit_faglfcv.
      ENDIF.

      READ TABLE lt_total_faglfcv INTO DATA(ls_total_faglfcv) WITH KEY rbukrs = <group_gom>-companycode
                                                                       bp = <group_gom>-customer
                                                                       gl_account = <group_gom>-glaccount.

      CLEAR: ls_total_faglfcv-total_credit_faglfcv, ls_total_faglfcv-total_debit_faglfcv.

      LOOP AT lt_total_faglfcv_2 INTO DATA(ls_total_faglfcv_2) WHERE rbukrs = <group_gom>-companycode
                                                                 AND bp = <group_gom>-customer
                                                                 AND gl_account = <group_gom>-glaccount.

        IF ls_total_faglfcv_2-posting_amount > 0.
          ls_total_faglfcv-total_debit_faglfcv = ls_total_faglfcv-total_debit_faglfcv + ls_total_faglfcv_2-posting_amount.
        ELSE.
          ls_total_faglfcv-total_credit_faglfcv = ls_total_faglfcv-total_credit_faglfcv + ls_total_faglfcv_2-posting_amount.
        ENDIF.
      ENDLOOP.

      IF ls_total_faglfcv IS NOT INITIAL.
        lv_chenh_lech_total = ls_total_faglfcv-total_credit_faglfcv + ls_total_faglfcv-total_debit_faglfcv.
      ENDIF.

      " tính dư đầu kỳ theo company code thêm chênh lệch
      IF ( ls_result_temp-open_credit - ls_result_temp-open_debit - lv_chenh_lech ) > 0.
        ls_result_temp-open_credit = ls_result_temp-open_credit - ls_result_temp-open_debit - lv_chenh_lech.
        ls_result_temp-open_debit = 0.
      ELSEIF ( ls_result_temp-open_credit - ls_result_temp-open_debit - lv_chenh_lech ) < 0.
        ls_result_temp-open_debit = abs( ls_result_temp-open_credit - ls_result_temp-open_debit - lv_chenh_lech ).
        ls_result_temp-open_credit = 0.
      ENDIF.

      " tính dư đầu kỳ theo transaction currency thêm chênh lệch
      IF ( ls_result_temp-open_credit_tran - ls_result_temp-open_debit_tran ) > 0.
        ls_result_temp-open_credit_tran = ls_result_temp-open_credit_tran - ls_result_temp-open_debit_tran.
        ls_result_temp-open_debit_tran = 0.
      ELSEIF ( ls_result_temp-open_credit_tran - ls_result_temp-open_debit_tran ) < 0.
        ls_result_temp-open_debit_tran = abs( ls_result_temp-open_credit_tran - ls_result_temp-open_debit_tran ).
        ls_result_temp-open_credit_tran = 0.
      ENDIF.

      " tính tổng phát sinh trong kỳ thêm chênh lệch
      ls_result_temp-total_debit = abs( ls_result_temp-total_debit + ls_total_faglfcv-total_debit_faglfcv ).
      ls_result_temp-total_credit = abs( ls_result_temp-total_credit - ls_total_faglfcv-total_credit_faglfcv ).

      " tính cuối kỳ theo company currency thêm chênh lệch
      IF ( ls_result_temp-end_credit - ls_result_temp-end_debit - lv_chenh_lech - lv_chenh_lech_total ) > 0.
        ls_result_temp-end_credit = ls_result_temp-end_credit - ls_result_temp-end_debit - lv_chenh_lech - lv_chenh_lech_total.
        ls_result_temp-end_debit = 0.
      ELSEIF ( ls_result_temp-end_credit - ls_result_temp-end_debit - lv_chenh_lech - lv_chenh_lech_total ) < 0.
        ls_result_temp-end_debit = abs( ls_result_temp-end_credit - ls_result_temp-end_debit - lv_chenh_lech - lv_chenh_lech_total ).
        ls_result_temp-end_credit = 0.
      ENDIF.

      " tính cuối kỳ theo transaction currency thêm chênh lệch
      IF ( ls_result_temp-end_credit_tran - ls_result_temp-end_debit_tran ) > 0.
        ls_result_temp-end_credit_tran = ls_result_temp-end_credit_tran - ls_result_temp-end_debit_tran.
        ls_result_temp-end_debit_tran = 0.
      ELSEIF ( ls_result_temp-end_credit_tran - ls_result_temp-end_debit_tran ) < 0.
        ls_result_temp-end_debit_tran = abs( ls_result_temp-end_credit_tran - ls_result_temp-end_debit_tran ).
        ls_result_temp-end_credit_tran = 0.
      ENDIF.

      IF ls_result_temp-rhcur IS INITIAL.
        ls_result_temp-rhcur = 'VND'.
      ENDIF.

      APPEND ls_result_temp TO lt_result_temp.
      CLEAR: ls_result_temp.
    ENDLOOP.

    lt_result = CORRESPONDING #( lt_result_temp ).

    SORT lt_result BY bp ASCENDING.
    " 6. Apply sorting
    DATA(sort_order) = VALUE abap_sortorder_tab(
      FOR sort_element IN io_request->get_sort_elements( )
      ( name = sort_element-element_name descending = sort_element-descending ) ).
    IF sort_order IS NOT INITIAL.
      SORT lt_result BY (sort_order).
    ENDIF.

    " 7. Apply paging
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
        CLEAR lv_index.
        lv_index = lv_start_index.
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
ENDCLASS.

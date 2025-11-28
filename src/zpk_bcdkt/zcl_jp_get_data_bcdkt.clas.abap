CLASS zcl_jp_get_data_bcdkt DEFINITION
  PUBLIC
  INHERITING FROM cx_rap_query_provider
*  FINAL
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
           tt_data  TYPE TABLE OF zi_bcdkt.

    CLASS-DATA: gt_data       TYPE TABLE OF zi_bcdkt,
                gt_detail     TYPE TABLE OF zi_bcdkt,
                gs_data       TYPE zi_bcdkt,
                gw_date_dk    TYPE I_JournalEntry-PostingDate,
                gw_date_ck    TYPE I_JournalEntry-PostingDate,
                gw_curr       TYPE I_CompanyCode-Currency,
                gt_fsv        TYPE TABLE OF I_GLAccountHierarchyNode,
                gt_acc        TYPE TABLE OF I_GLAccountHierarchyNode,
                gt_faglflext  TYPE TABLE OF  I_JournalEntry,
                gw_period     TYPE monat,
                gw_gjahr      TYPE I_JournalEntry-FiscalYear,
                gw_budat_pre  TYPE I_JournalEntry-PostingDate,
                gw_budat_last TYPE I_JournalEntry-PostingDate,
                gw_bukrs      TYPE bukrs,
                gs_bukrs      TYPE zst_companycode_info,
                p_detail      TYPE char1_run_type.


    CLASS-DATA:
      "Instance Singleton
      mo_instance      TYPE REF TO zcl_jp_get_data_bcdkt.

    CLASS-METHODS:
      "Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_jp_get_data_bcdkt,

      get_parameter IMPORTING ir_monat   TYPE tt_range
                              ir_type    TYPE tt_range
                              ir_gjahr   TYPE tt_range
                              ir_detail  TYPE tt_range
                    EXPORTING period     TYPE monat
                              gjahr      TYPE I_JournalEntry-FiscalYear
                              budat_pre  TYPE I_JournalEntry-PostingDate
                              budat_last TYPE I_JournalEntry-PostingDate,

      process_data IMPORTING ir_bukrs  TYPE tt_range
                             ir_rldnr  TYPE tt_range
                             ir_gjahr  TYPE tt_range
                             ir_monat  TYPE tt_range
                             ir_type   TYPE tt_range
                             ir_detail TYPE tt_range
                   EXPORTING gt_data   TYPE tt_data.
    CLASS-METHODS:
*      find_children  IMPORTING
*                               parentNode TYPE zi_bcdkt-HierarchyNode
*                     CHANGING  SoDK       TYPE dmbtr
*                               SoCK       TYPE dmbtr
*                               lt_data    TYPE tt_data.
      find_children  IMPORTING parentNode TYPE zi_bcdkt-HierarchyNode
                     CHANGING  lt_data    TYPE tt_data.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_jp_get_data_bcdkt IMPLEMENTATION.


  METHOD process_data.
    DATA: lw_hsl_dky TYPE dmbtr,
          lw_hsl_cky TYPE dmbtr,
          ls_glacc   TYPE LINE OF tt_range,
          lr_glacc   TYPE tt_range,
          lr_glac1   TYPE tt_range.
    DATA: gw_hso TYPE numc5.
* Khởi tạo đối tượng
    DATA(lo_bcdkt)  = zcl_jp_get_data_bcdkt=>get_instance( ).

    DATA(lo_comcode) = zcl_jp_common_core=>get_instance(  ).
    lo_bcdkt->get_parameter(
    EXPORTING
      ir_monat  = ir_monat
      ir_type   = ir_type
      ir_gjahr  = ir_gjahr
      ir_detail = ir_detail
    IMPORTING
      period = gw_period
      gjahr  = gw_gjahr
      budat_pre = gw_budat_pre
      budat_last = gw_budat_last
  ).

*        // lay ten cty
    READ TABLE ir_bukrs INTO DATA(ls_bukrs) INDEX 1.
    IF sy-subrc = 0.
      gw_bukrs = ls_bukrs-low.
    ENDIF.
    lo_comcode->get_companycode_details(
      EXPORTING
        i_companycode = gw_bukrs
      IMPORTING
        o_companycode = gs_bukrs
    ).

    CLEAR: gt_data[], gt_detail[].


    "lấy currency code của bukrs
    SELECT SINGLE currency
         FROM I_CompanyCode
         WITH PRIVILEGED ACCESS
         WHERE CompanyCode IN @ir_bukrs
         INTO @gw_curr.
    IF gw_curr = 'VND'.
      gw_hso = 100.
    ELSE.
      gw_hso = 1.
    ENDIF.
*         GLACCOUNT IN C.CODE
    SELECT * FROM I_GLAccountInCompanyCode
        WITH PRIVILEGED ACCESS
        WHERE CompanyCode IN @ir_bukrs
        INTO TABLE @DATA(gt_skb1).
    SORT gt_skb1 BY GLAccount.
*          "FSV
    SELECT * FROM I_GLAccountHierarchyNode
    WITH PRIVILEGED ACCESS
        WHERE GLAccountHierarchy = 'ZBS'
        INTO TABLE @gt_fsv.
    SORT gt_fsv BY HierarchyNode.

*        chi tieu 421b
    DATA: gs_fsv TYPE I_GLAccountHierarchyNode.
    gs_fsv-GLAccount = '5*'.
    gs_fsv-ParentNode = '04212'.
    gs_fsv-ChartOfAccounts = 'CP'.
    gs_fsv-SignIsInverted = '+'.
    APPEND gs_fsv TO gt_fsv.
    CLEAR: gs_fsv.

    gs_fsv-GLAccount = '60*'.
    gs_fsv-ParentNode = '04212'.
    gs_fsv-ChartOfAccounts = 'CP'.
    gs_fsv-SignIsInverted = '+'.
    APPEND gs_fsv TO gt_fsv.
    CLEAR: gs_fsv.
    gs_fsv-GLAccount = '61*'.
    gs_fsv-ParentNode = '04212'.
    gs_fsv-ChartOfAccounts = 'CP'.
    gs_fsv-SignIsInverted = '+'.
    APPEND gs_fsv TO gt_fsv.
    CLEAR: gs_fsv.
    gs_fsv-GLAccount = '63*'.
    gs_fsv-ParentNode = '04212'.
    gs_fsv-ChartOfAccounts = 'CP'.
    gs_fsv-SignIsInverted = '+'.
    APPEND gs_fsv TO gt_fsv.
    CLEAR: gs_fsv.
    gs_fsv-GLAccount = '64*'.
    gs_fsv-ParentNode = '04212'.
    gs_fsv-ChartOfAccounts = 'CP'.
    gs_fsv-SignIsInverted = '+'.
    APPEND gs_fsv TO gt_fsv.
    CLEAR: gs_fsv.
    gs_fsv-GLAccount = '65*'.
    gs_fsv-ParentNode = '04212'.
    gs_fsv-ChartOfAccounts = 'CP'.
    gs_fsv-SignIsInverted = '+'.
    APPEND gs_fsv TO gt_fsv.
    CLEAR: gs_fsv.
    gs_fsv-GLAccount = '66*'.
    gs_fsv-ParentNode = '04212'.
    gs_fsv-ChartOfAccounts = 'CP'.
    gs_fsv-SignIsInverted = '+'.
    APPEND gs_fsv TO gt_fsv.
    CLEAR: gs_fsv.
    gs_fsv-GLAccount = '67*'.
    gs_fsv-ParentNode = '04212'.
    gs_fsv-ChartOfAccounts = 'CP'.
    gs_fsv-SignIsInverted = '+'.
    APPEND gs_fsv TO gt_fsv.
    CLEAR: gs_fsv.
    gs_fsv-GLAccount = '68*'.
    gs_fsv-ParentNode = '04212'.
    gs_fsv-ChartOfAccounts = 'CP'.
    gs_fsv-SignIsInverted = '+'.
    APPEND gs_fsv TO gt_fsv.
    CLEAR: gs_fsv.
    gs_fsv-GLAccount = '69*'.
    gs_fsv-ParentNode = '04212'.
    gs_fsv-ChartOfAccounts = 'CP'.
    gs_fsv-SignIsInverted = '+'.
    APPEND gs_fsv TO gt_fsv.
    CLEAR: gs_fsv.

    gs_fsv-GLAccount = '7*'.
    gs_fsv-ParentNode = '04212'.
    gs_fsv-ChartOfAccounts = 'CP'.
    gs_fsv-SignIsInverted = '+'.
    APPEND gs_fsv TO gt_fsv.
    CLEAR: gs_fsv.

    gs_fsv-GLAccount = '811*'.
    gs_fsv-ParentNode = '04212'.
    gs_fsv-ChartOfAccounts = 'CP'.
    gs_fsv-SignIsInverted = '+'.
    APPEND gs_fsv TO gt_fsv.
    CLEAR: gs_fsv.

    gs_fsv-GLAccount = '821*'.
    gs_fsv-ParentNode = '04212'.
    gs_fsv-ChartOfAccounts = 'CP'.
    gs_fsv-SignIsInverted = '+'.
    APPEND gs_fsv TO gt_fsv.
    CLEAR: gs_fsv.

    gt_acc[] = gt_fsv[].
    DELETE gt_fsv WHERE GLAccount IS NOT INITIAL.
    DELETE gt_acc WHERE GLAccount IS INITIAL.

    IF gt_fsv[] IS NOT INITIAL.
      "text cho item
      SELECT HierarchyNode,
             HierarchyNodeText
          FROM I_FinancialStatementHierNodeT
          WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @gt_fsv
          WHERE FinancialStatementHierarchy = @gt_fsv-GLAccountHierarchy
          AND HierarchyNode = @gt_fsv-HierarchyNode
          AND Language = 'E'
          INTO TABLE @DATA(lt_txt).
      SORT lt_txt BY HierarchyNode.
    ENDIF.

*        Build hierarchy
    DELETE gt_fsv WHERE HierarchyNode = '0ZBS' OR ParentNode = '0ZBS'.
    LOOP AT gt_fsv INTO DATA(ls_fsv).
      gs_data-HierarchyNode = ls_fsv-HierarchyNode.
      READ TABLE lt_txt INTO DATA(ls_txt) WITH KEY HierarchyNode = ls_fsv-HierarchyNode BINARY SEARCH.
      IF sy-subrc = 0.
        gs_data-HierarchyNode_TXT = ls_txt-HierarchyNodeText.
      ENDIF.
      gs_data-parentNode = ls_fsv-ParentNode.
      IF gs_data-HierarchyNode = '0100' OR gs_data-HierarchyNode = '0200'.
        gs_data-parentNode = '0270'.
      ELSEIF gs_data-HierarchyNode = '0200' OR gs_data-HierarchyNode = '0300'.
        gs_data-parentNode = '0440'.
      ENDIF.
      APPEND gs_data TO gt_data.
      CLEAR: ls_fsv, gs_data.
    ENDLOOP.

    gs_data-HierarchyNode = '0270'.
    gs_data-HierarchyNode_TXT = 'TỔNG CỘNG TÀI SẢN ( 270 = 100 + 200 )'.
    APPEND gs_data TO gt_data.

    gs_data-HierarchyNode = '0440'.
    gs_data-HierarchyNode_TXT = 'TỔNG CỘNG NGUỒN VỐN ( 440 = 300 + 400 )'.
    APPEND gs_data TO gt_data.

    "lấy gl account
    DELETE gt_acc WHERE ParentNode = '00NOTASSGND'.
*        LOOP AT gt_acc INTO ls_fsv WHERE ParentNode = '0131' OR ParentNode = '0136'
*                                      OR ParentNode = '0311' OR ParentNode = '0319'
*                                      OR ParentNode = '0313' OR ParentNode = '0314'.
*          ls_glacc-sign   = 'I'.
*          ls_glacc-option = 'BT'.
*          ls_glacc-low = ls_fsv-GLAccount.
*          ls_glacc-high = ls_fsv-GLAccount.
*          APPEND ls_glacc TO lr_glacc.
*        ENDLOOP.


    LOOP AT gt_acc INTO ls_fsv.
      ls_glacc-sign   = 'I'.
      IF ls_fsv-ChartOfAccounts = 'CP'.
        ls_glacc-option = 'CP'.
      ELSE.
        ls_glacc-option = 'EQ'.
      ENDIF.
      ls_glacc-low = ls_fsv-GLAccount.
      ls_glacc-high = ls_fsv-SignIsInverted.
      APPEND ls_glacc TO lr_glacc.
    ENDLOOP.

    DATA: lw_ergsl_0    TYPE zi_bcdkt-HierarchyNode,
          lw_ergsl_1    TYPE zi_bcdkt-HierarchyNode,
          lw_dmbtr_dk_0 TYPE dmbtr,
          lw_dmbtr_dk_1 TYPE dmbtr,
          lw_dmbtr_ck_0 TYPE dmbtr,
          lw_dmbtr_ck_1 TYPE dmbtr.
    DATA: ir_hkont  TYPE tt_range,
          ls_hkont  TYPE ty_range_option,
          lw_parent TYPE zi_bcdkt-HierarchyNode.
    LOOP AT lr_glacc INTO ls_glacc.

      CLEAR: ir_hkont[], lw_parent.
      MOVE-CORRESPONDING ls_glacc TO ls_hkont.
      CLEAR: ls_hkont-high.
      APPEND ls_hkont TO ir_hkont.
      CLEAR: ls_hkont.
      READ TABLE gt_acc INTO gs_fsv WITH KEY GLAccount = ls_glacc-low.
      IF sy-subrc = 0.
        lw_parent = gs_fsv-ParentNode.
      ENDIF.
      DATA: lw_budat_first TYPE budat.
      CLEAR: lw_budat_first.
      IF lw_parent = '04212' OR lw_parent = '04211'.
        lw_budat_first = |{ gw_gjahr - 1 }0101|.
*      ELSE.
*        lw_budat_first = |{ gw_gjahr - 1 }0101|.
      ENDIF.
      IF lw_parent <> '04211'.
        SELECT
          items~glaccount,
          headers~FiscalYear,
          headers~postingdate,
          headers~FiscalPeriod,
          headers~AccountingDocument,
          items~AmountInCompanyCodeCurrency,
          items~customer,
          items~supplier,
          items~segment,
          items~ClearingDate,
          items~FinancialAccountType,
          item1~Reference1IDByBusinessPartner
              FROM I_JournalEntryItem AS items
              INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                                  AND items~AccountingDocument = headers~AccountingDocument
                                                  AND items~FiscalYear         = headers~FiscalYear
              LEFT JOIN i_operationalacctgdocitem AS item1 ON item1~CompanyCode        = items~CompanyCode
                                                            AND item1~AccountingDocument = items~AccountingDocument
                                                            AND item1~FiscalYear         = items~FiscalYear
                                                            AND item1~AccountingDocumentItem = items~AccountingDocumentItem


              WHERE headers~CompanyCode          IN  @ir_bukrs
              AND headers~PostingDate          < @gw_budat_last
              AND headers~PostingDate          >= @lw_budat_first
              AND headers~LedgerGroup               IN  @ir_rldnr
              AND items~Ledger                    IN @ir_rldnr
              AND items~GLAccount              IN @ir_hkont
              AND ( items~ClearingDate > @gw_budat_pre OR items~ClearingDate IS INITIAL )
              AND headers~JournalEntryReprocessingStatus <> 'S'
              AND headers~AccountingDocumentType <> ''

              INTO TABLE @DATA(gt_acdoca)
              OPTIONS PRIVILEGED ACCESS.
      ELSE.
        SELECT
    items~glaccount,
    items~FiscalYear,
    items~postingdate,
    items~FiscalPeriod,
    items~AccountingDocument,
    items~AmountInCompanyCodeCurrency,
    items~customer,
    items~supplier,
    items~segment,
    items~ClearingDate,
    items~FinancialAccountType
*        item1~Reference1IDByBusinessPartner
        FROM i_glaccountlineitem AS items


        WHERE items~CompanyCode          IN  @ir_bukrs
        AND items~PostingDate          < @gw_budat_last
        AND items~PostingDate          >= @lw_budat_first
        AND items~SourceLedger               IN  @ir_rldnr
        AND items~Ledger                    IN @ir_rldnr
        AND items~GLAccount              IN @ir_hkont
        AND ( items~ClearingDate > @gw_budat_pre OR items~ClearingDate IS INITIAL )
        INTO CORRESPONDING FIELDS OF TABLE @gt_acdoca
        OPTIONS PRIVILEGED ACCESS.
      ENDIF.
      LOOP AT gt_acdoca ASSIGNING FIELD-SYMBOL(<gf_acdoca>) WHERE Supplier IS INITIAL AND Customer IS INITIAL.
        IF <gf_acdoca>-GLAccount+0(1) = '1'.
          <gf_acdoca>-Customer = <gf_acdoca>-Reference1IDByBusinessPartner.
        ELSEIF <gf_acdoca>-GLAccount+0(1) = '3'.
          <gf_acdoca>-Supplier = <gf_acdoca>-Reference1IDByBusinessPartner.
        ENDIF.
      ENDLOOP.

      LOOP AT gt_acdoca ASSIGNING <gf_acdoca> WHERE ( GLAccount+0(1) = '5' OR GLAccount+0(1) = '6'
                                                OR GLAccount+0(1) = '7' OR GLAccount+0(3) = '811' OR  GLAccount+0(3) = '821' ).
        CLEAR: <gf_acdoca>-Supplier, <gf_acdoca>-Customer.
      ENDLOOP.
      IF ( lw_parent <= '0232' AND lw_parent >= '0222' ) OR lw_parent = '0112' OR lw_parent = '0141'.
        LOOP AT gt_acdoca ASSIGNING <gf_acdoca>.
          CLEAR: <gf_acdoca>-Supplier, <gf_acdoca>-Customer.
        ENDLOOP.
      ENDIF.

      LOOP AT gt_acdoca INTO DATA(ls_acdoca_tmp)
            GROUP BY (
            customer   = ls_acdoca_tmp-Customer
            supplier   = ls_acdoca_tmp-Supplier
            GLAccount  = ls_acdoca_tmp-GLAccount
                    ) ASSIGNING FIELD-SYMBOL(<lt_group_acdoca>).
        LOOP AT GROUP <lt_group_acdoca> INTO DATA(ls_acdoca).
          READ TABLE gt_skb1 INTO DATA(ls_skb1) WITH KEY GLAccount = ls_acdoca-GLAccount BINARY SEARCH.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          IF lw_parent <> '04211' AND lw_parent <> '04212'.
            IF ls_acdoca-PostingDate <= gw_budat_pre. "dau ky
              lw_hsl_dky = lw_hsl_dky + ls_acdoca-AmountInCompanyCodeCurrency * gw_hso.
            ENDIF.
            IF ( ls_acdoca-ClearingDate IS INITIAL OR ls_acdoca-ClearingDate >= gw_budat_last ). "cuoi ky
              lw_hsl_cky = lw_hsl_cky + ls_acdoca-AmountInCompanyCodeCurrency * gw_hso.
            ENDIF.
          ELSE.
            IF ls_acdoca-PostingDate <= gw_budat_pre. "dau ky
              lw_hsl_dky = lw_hsl_dky + ls_acdoca-AmountInCompanyCodeCurrency * gw_hso.
            ELSE.
              IF ( ls_acdoca-ClearingDate IS INITIAL OR ls_acdoca-ClearingDate >= gw_budat_last ). "cuoi ky
                lw_hsl_cky = lw_hsl_cky + ls_acdoca-AmountInCompanyCodeCurrency * gw_hso.
              ENDIF.
            ENDIF.
          ENDIF.

        ENDLOOP.

        IF ls_glacc-high = '-'.
          lw_hsl_dky = lw_hsl_dky * -1.
          lw_hsl_cky = lw_hsl_cky * -1.
        ENDIF.


        IF lw_parent = '0131'.
          IF ls_acdoca-FinancialAccountType <> 'S'.
            lw_ergsl_0 = '0131'.
            lw_ergsl_1 = '0312'.
          ELSEIF ls_acdoca-GLAccount = '1319002010' OR ls_acdoca-GLAccount = '1319002020'.
            lw_ergsl_0 = '0312'.
            lw_ergsl_1 = '0312'.
          ELSE.
            lw_ergsl_0 = '0131'.
            lw_ergsl_1 = '0131'.
          ENDIF.
        ELSEIF lw_parent  = '0311'.
          IF ls_acdoca-FinancialAccountType <> 'S'.
            lw_ergsl_0 = '0132'.
            lw_ergsl_1 = '0311'.
          ELSEIF ls_acdoca-GLAccount = '3319002010' OR ls_acdoca-GLAccount = '3319002020'.
            lw_ergsl_0 = '0132'.
            lw_ergsl_1 = '0132'.
          ELSE.
            lw_ergsl_0 = '0311'.
            lw_ergsl_1 = '0311'.
          ENDIF.
        ELSEIF lw_parent = '0136'.
          IF ls_acdoca-GLAccount+0(4) = '1388'.
            lw_ergsl_0 = '0136'.
            lw_ergsl_1 = '0319'.
          ELSE.
            lw_ergsl_0 = '0136'.
            lw_ergsl_1 = '0136'.
          ENDIF.
        ELSEIF lw_parent  = '0319'.
          IF ls_acdoca-GLAccount+0(3) = '338'.
            lw_ergsl_0 = '0136'.
            lw_ergsl_1 = '0319'.
          ELSE.
            lw_ergsl_0 = '0319'.
            lw_ergsl_1 = '0319'.
          ENDIF.
        ELSEIF lw_parent  = '0314'.
          IF ls_acdoca-GLAccount+0(3) = '334'.
            lw_ergsl_0 = '0136'.
            lw_ergsl_1 = '0314'.
          ELSE.
            lw_ergsl_0 = '0314'.
            lw_ergsl_1 = '0314'.
          ENDIF.
        ELSEIF lw_parent  = '0313'.
          IF ls_acdoca-GLAccount+0(3) = '333'.
            lw_ergsl_0 = '0153'.
            lw_ergsl_1 = '0313'.
          ELSE.
            lw_ergsl_0 = '0313'.
            lw_ergsl_1 = '0313'.
          ENDIF.
        ENDIF.

        IF lw_hsl_dky > 0.
          lw_dmbtr_dk_0 = lw_hsl_dky.
        ELSE.
          lw_dmbtr_dk_1 = lw_hsl_dky.
        ENDIF.

        IF lw_hsl_cky > 0.
          lw_dmbtr_ck_0 = lw_hsl_cky.
        ELSE.
          lw_dmbtr_ck_1 = lw_hsl_cky.
        ENDIF.

        IF lw_ergsl_0 IS INITIAL AND lw_ergsl_1 IS INITIAL.
          READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<ls_fagl_011zc>) WITH KEY HierarchyNode = lw_parent.
          IF sy-subrc = 0.
            <ls_fagl_011zc>-SoDK = <ls_fagl_011zc>-SoDK + lw_hsl_dky.
            <ls_fagl_011zc>-SoCK = <ls_fagl_011zc>-SoCK + lw_hsl_cky.

            APPEND INITIAL LINE TO gt_detail ASSIGNING FIELD-SYMBOL(<fs_detail>).
            MOVE-CORRESPONDING <ls_fagl_011zc> TO <fs_detail>.
            <fs_detail>-kunnr = ls_acdoca-Customer.
            IF <fs_detail>-kunnr IS INITIAL.
              <fs_detail>-kunnr = ls_acdoca-Supplier.
            ENDIF.
            <fs_detail>-glaccount = ls_acdoca-GLAccount.
            <fs_detail>-SoDK = lw_hsl_dky.
            <fs_detail>-SoCK = lw_hsl_cky.
          ENDIF.
        ENDIF.

        IF lw_ergsl_0 IS NOT INITIAL.
          READ TABLE gt_data ASSIGNING <ls_fagl_011zc> WITH KEY HierarchyNode = lw_ergsl_0.
          IF sy-subrc = 0.
            <ls_fagl_011zc>-SoDK = <ls_fagl_011zc>-SoDK + lw_dmbtr_dk_0.
            <ls_fagl_011zc>-SoCK = <ls_fagl_011zc>-SoCK + lw_dmbtr_ck_0.

            APPEND INITIAL LINE TO gt_detail ASSIGNING <fs_detail>.
            MOVE-CORRESPONDING <ls_fagl_011zc> TO <fs_detail>.
            <fs_detail>-kunnr = ls_acdoca-Customer.
            IF <fs_detail>-kunnr IS INITIAL.
              <fs_detail>-kunnr = ls_acdoca-Supplier.
            ENDIF.
            <fs_detail>-glaccount = ls_acdoca-GLAccount.
            <fs_detail>-SoDK = lw_dmbtr_dk_0.
            <fs_detail>-SoCK = lw_dmbtr_ck_0.
          ENDIF.
        ENDIF.

        IF lw_ergsl_1 IS NOT INITIAL.
          READ TABLE gt_data ASSIGNING <ls_fagl_011zc> WITH KEY HierarchyNode = lw_ergsl_1.
          IF sy-subrc = 0.
            <ls_fagl_011zc>-SoDK = <ls_fagl_011zc>-SoDK + lw_dmbtr_dk_1.
            <ls_fagl_011zc>-SoCK = <ls_fagl_011zc>-SoCK + lw_dmbtr_ck_1.

            APPEND INITIAL LINE TO gt_detail ASSIGNING <fs_detail>.
            MOVE-CORRESPONDING <ls_fagl_011zc> TO <fs_detail>.
            <fs_detail>-kunnr = ls_acdoca-Customer.
            IF <fs_detail>-kunnr IS INITIAL.
              <fs_detail>-kunnr = ls_acdoca-Supplier.
            ENDIF.
            <fs_detail>-glaccount = ls_acdoca-GLAccount.
            <fs_detail>-SoDK = lw_dmbtr_dk_1.
            <fs_detail>-SoCK = lw_dmbtr_ck_1.
          ENDIF.
        ENDIF.

        CLEAR:  lw_hsl_dky,
                lw_hsl_cky,
                lw_ergsl_0,
                lw_ergsl_1,
                lw_dmbtr_dk_0,
                lw_dmbtr_dk_1,
                lw_dmbtr_ck_0,
                lw_dmbtr_ck_1.


      ENDLOOP.


    ENDLOOP.

*    read table gt_data assigning field-symbol(<fs_4211>) with key HierarchyNode = '04211'.
*    READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs_4212>) WITH KEY HierarchyNode = '04212'.
*    <fs_4211>-SoDK = <fs_4211>-SoDK + <fs_4212>-SoDK.
*    CLEAR: <fs_4212>-SoDK.

    DO 5 TIMES.
      LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
        READ TABLE gt_data TRANSPORTING NO FIELDS WITH KEY parentNode = <fs_data>-HierarchyNode.
        IF sy-subrc = 0.
          CLEAR: <fs_data>-SoCK, <fs_data>-SoDK.
        ENDIF.
        LOOP AT gt_data INTO gs_data WHERE parentNode = <fs_data>-HierarchyNode.
          <fs_data>-SoCK = <fs_data>-SoCK + gs_data-SoCK.
          <fs_data>-SoDK = <fs_data>-SoDK + gs_data-SoDK.
        ENDLOOP.
      ENDLOOP.
    ENDDO.

    IF p_detail = 'X'.
      DATA: ls_4211 TYPE zi_bcdkt.
      DELETE gt_detail WHERE SoCK IS INITIAL AND SoDK IS INITIAL.
*      LOOP AT gt_detail ASSIGNING <fs_detail> WHERE HierarchyNode = '04212'.
*        MOVE-CORRESPONDING <fs_detail> TO ls_4211.
*        READ TABLE gt_detail ASSIGNING FIELD-SYMBOL(<fs_trans>) WITH KEY HierarchyNode = '04211' glaccount = <fs_detail>-glaccount kunnr = <fs_detail>-kunnr.
*        IF sy-subrc = 0.
*          <fs_trans>-SoDK = <fs_trans>-SoDK + <fs_detail>-SoDK.
*        ELSE.
*          ls_4211-HierarchyNode = <fs_4211>-HierarchyNode.
*          ls_4211-HierarchyNode_TXT = <fs_4211>-HierarchyNode_TXT.
*          ls_4211-SoCK = 0.
*          APPEND ls_4211 TO gt_detail.
*        ENDIF.
*        CLEAR: <fs_detail>-SoDK.
*        CLEAR: ls_4211.
*      ENDLOOP.

      APPEND LINES OF gt_detail TO gt_data.
    ENDIF.

    SORT gt_data BY HierarchyNode glaccount kunnr.

    LOOP AT gt_data ASSIGNING <FS_Data>.
*          <fs_data>-HierarchyNode = <fs_data>-HierarchyNode+1(3).
      SHIFT <fs_data>-HierarchyNode LEFT DELETING LEADING '0'.
      <fs_data>-CCname = gs_bukrs-companycodename.
      <fs_data>-CCadrr = gs_bukrs-companycodeaddr.
      IF <fs_data>-HierarchyNode = '420' OR <fs_data>-HierarchyNode = '320' OR <fs_data>-HierarchyNode = '340'.
        <fs_data>-type = ''.
      ELSEIF <fs_data>-HierarchyNode+2(1) = '0' .
        <fs_data>-type = '1'.
      ELSEIF <fs_data>-HierarchyNode_TXT(1) = '-'.
        <fs_data>-type = '2'.
      ELSE.
        <fs_data>-type = ''.
      ENDIF.
      IF <fs_data>-HierarchyNode >= '300'.
        <fs_data>-SoCK = <fs_data>-SoCK * -1.
        <fs_data>-SoDK = <fs_data>-SoDK * -1.
      ENDIF.
    ENDLOOP.




  ENDMETHOD.


  METHOD find_children.

  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD get_parameter.

    DATA lw_year_next TYPE numc4.
    DATA lw_month_next TYPE numc2.

    READ TABLE ir_type INTO DATA(ls_type) INDEX 1.
    READ TABLE ir_monat INTO DATA(ls_monat) INDEX 1.
    READ TABLE ir_gjahr INTO DATA(ls_gjahr) INDEX 1.
    READ TABLE ir_detail INTO DATA(ls_detail) INDEX 1.
    IF ls_detail-low = 'X' OR ls_detail-low = 'true'.
      p_detail = 'X'.
    ENDIF.
    CASE ls_type-low.
      WHEN 1.
        period = ls_monat-low.
      WHEN 2.
        period = 3.
      WHEN 3.
        period = 6.
      WHEN 4.
        period = 6.
      WHEN 5.
        period = 9.
      WHEN 6.
        period = 12.
      WHEN 7.
        period = 16.
    ENDCASE.

    gjahr = ls_gjahr-low.

    budat_pre = |{ ls_gjahr-low - 1 }1231|.

    lw_month_next = period + 1.
    lw_year_next  = ls_gjahr-low.
    IF lw_month_next > 12.
      lw_month_next = 1.
      lw_year_next  = lw_year_next + 1.
    ENDIF.
    budat_last = lw_year_next && lw_month_next && `01`.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
**--- Custom Entities ---**
    DATA: ls_page_info TYPE zcl_get_fillter=>st_page_info,

          ir_bukrs     TYPE tt_range,
          ir_rldnr     TYPE tt_range,
          ir_gjahr     TYPE tt_range,
          ir_monat     TYPE tt_range,
          ir_type      TYPE tt_range,
          ir_detail    TYPE tt_range,
          ls_glacc     TYPE LINE OF tt_range,
          lr_glacc     TYPE tt_range,
          lr_glac1     TYPE tt_range.
    DATA: lt_data    TYPE TABLE OF zi_bcdkt,
          lt_data_ct TYPE TABLE OF zi_bcdkt.
    DATA: lw_hsl_dky TYPE dmbtr,
          lw_hsl_cky TYPE dmbtr.
    DATA: gw_hso TYPE numc5.
    FREE: lt_data, lr_glacc.
    TRY.
* Khởi tạo đối tượng
        DATA(lo_bcdkt)  = zcl_jp_get_data_bcdkt=>get_instance( ).

        DATA(lo_comcode) = zcl_jp_common_core=>get_instance(  ).

        DATA(lo_common_app) = zcl_get_fillter=>get_instance( ).

*  Lấy tham số
        lo_common_app->get_fillter_app(   EXPORTING
                                            io_request    = io_request
                                            io_response   = io_response
                                          IMPORTING
                                            ir_bukrs  = ir_bukrs
                                            ir_rldnr  = ir_rldnr
                                            ir_gjahr  = ir_gjahr
                                            ir_monat  = ir_monat
                                            ir_type   = ir_type
                                            ir_detail = ir_detail
                                            wa_page_info  = ls_page_info
                                        ).

        READ TABLE ir_rldnr INTO DATA(ls_rldnr) INDEX 1.
        IF ls_rldnr-low = '0L'.
          ls_rldnr-low = ''.
          APPEND ls_rldnr TO ir_rldnr.
        ENDIF.
        lo_bcdkt->process_data(
          EXPORTING
                                            ir_bukrs  = ir_bukrs
                                            ir_rldnr  = ir_rldnr
                                            ir_gjahr  = ir_gjahr
                                            ir_monat  = ir_monat
                                            ir_type   = ir_type
                                            ir_detail = ir_detail
          IMPORTING
            gt_data   = gt_data
        ).

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

        RAISE EXCEPTION TYPE zcl_jp_get_data_bcdkt
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

CLASS zcl_jp_get_data_kqhdkd DEFINITION
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

           tt_range          TYPE TABLE OF ty_range_option,
           ir_rep_period     TYPE TABLE OF ty_range_option,
           ir_com_period     TYPE TABLE OF ty_range_option,
           ir_rep_period_acc TYPE TABLE OF ty_range_option,
           ir_com_period_acc TYPE TABLE OF ty_range_option,
           tt_data           TYPE TABLE OF zc_kqhdkd.

    CLASS-DATA: gt_data       TYPE TABLE OF zc_kqhdkd,
                gt_hierarchy  TYPE TABLE OF zc_kqhdkd,
                gs_data       TYPE zc_kqhdkd,
                gs_bukrs      TYPE zst_companycode_info,
                gs_hierarchy  TYPE zc_kqhdkd,
                gw_bukrs      TYPE bukrs,
                gw_date_dk    TYPE I_JournalEntry-PostingDate,
                gw_date_ck    TYPE I_JournalEntry-PostingDate,
                gw_curr       TYPE I_CompanyCode-Currency,
                gt_fsv        TYPE TABLE OF I_GLAccountHierarchyNode,
                gt_acc        TYPE TABLE OF I_GLAccountHierarchyNode,
                gs_acc        TYPE I_GLAccountHierarchyNode,
                gt_faglflext  TYPE TABLE OF  I_JournalEntry,
                gw_period     TYPE monat,
                gw_gjahr      TYPE I_JournalEntry-FiscalYear,
                gw_c_gjahr    TYPE I_JournalEntry-FiscalYear,
                gw_budat_pre  TYPE I_JournalEntry-PostingDate,
                gw_budat_last TYPE I_JournalEntry-PostingDate,
                p_detail      TYPE char1_run_type.


    CLASS-DATA:
      "Instance Singleton
      mo_instance      TYPE REF TO zcl_jp_get_data_kqhdkd.

    CLASS-METHODS:
      "Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_jp_get_data_kqhdkd,

      get_parameter IMPORTING ir_monat          TYPE tt_range
                              ir_type           TYPE tt_range
                              ir_gjahr          TYPE tt_range
                              ir_detail         TYPE tt_range
                    EXPORTING period            TYPE monat
                              gjahr             TYPE I_JournalEntry-FiscalYear
                              c_gjahr           TYPE I_JournalEntry-FiscalYear
                              budat_pre         TYPE I_JournalEntry-PostingDate
                              budat_last        TYPE I_JournalEntry-PostingDate
                              ir_rep_period     TYPE tt_range
                              ir_com_period     TYPE tt_range
                              ir_rep_period_acc TYPE tt_range
                              ir_com_period_acc TYPE tt_range.
    CLASS-METHODS:
      find_parent  IMPORTING
                             parentNode TYPE zc_kqhdkd-HierarchyNode
                   CHANGING  sokynay    TYPE dmbtr
                             sokytruoc  TYPE dmbtr
                             lkkynay    TYPE dmbtr
                             lkkytruoc  TYPE dmbtr
                             lt_data    TYPE tt_data.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_JP_GET_DATA_KQHDKD IMPLEMENTATION.


  METHOD find_parent.

    DATA: lw_sokynay   TYPE zc_kqhdkd-sokynay,
          lw_sokytruoc TYPE zc_kqhdkd-sokytruoc,
          lw_lkkynay   TYPE zc_kqhdkd-lkkynay,
          lw_lkkytruoc TYPE zc_kqhdkd-lkkytruoc,
          lw_node      TYPE zc_kqhdkd-HierarchyNode.

    LOOP AT gt_hierarchy ASSIGNING FIELD-SYMBOL(<fs_child>) WHERE HierarchyNode = parentnode.
      " CLEAR: lw_sokynay, lw_sokytruoc, lw_lkkynay,lw_lkkytruoc.
      lw_node = <fs_child>-parentnode.
      <fs_child>-sokynay = <fs_child>-sokynay + sokynay.
      <fs_child>-sokytruoc = <fs_child>-sokytruoc + sokytruoc.
      <fs_child>-lkkynay = <fs_child>-lkkynay + lkkynay.
      <fs_child>-lkkytruoc = <fs_child>-lkkytruoc + lkkytruoc.
      lw_sokynay = <fs_child>-sokynay.
      lw_sokytruoc = <fs_child>-sokytruoc.
      lw_lkkynay = <fs_child>-lkkynay.
      lw_lkkytruoc = <fs_child>-lkkytruoc.
      mo_instance->find_parent(
        EXPORTING
          parentnode = lw_node
        CHANGING
          sokynay    = sokynay
          sokytruoc  = sokytruoc
          lkkynay    = lkkynay
          lkkytruoc  = lkkytruoc
          lt_data    = lt_data
      ).
    ENDLOOP.

  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD get_parameter.
*         TYPES: BEGIN OF ty_range_option,
*             sign   TYPE c LENGTH 1,
*             option TYPE c LENGTH 2,
*             low    TYPE string,
*             high   TYPE string,
*           END OF ty_range_option,
*
*           tt_range TYPE TABLE OF ty_range_option,
    DATA lw_year_next TYPE numc4.
    DATA: lw_c_year         TYPE numc4,
          ls_rep_period     TYPE ty_range_option,
          ls_com_period     TYPE ty_range_option,
          ls_rep_period_acc TYPE ty_range_option,
          ls_com_period_acc TYPE ty_range_option.
    DATA lw_month_next TYPE numc2.

    READ TABLE ir_type INTO DATA(ls_type) INDEX 1.
    READ TABLE ir_monat INTO DATA(ls_monat) INDEX 1.
    READ TABLE ir_gjahr INTO DATA(ls_gjahr) INDEX 1.
*    READ TABLE ir_detail INTO DATA(ls_detail) INDEX 1.
*    IF ls_detail-low = 'Yes'.
*      p_detail = 'X'.
*    ENDIF.
*--------------------------------*
    gjahr = ls_gjahr-low.
    c_gjahr = gjahr - 1.
*  lw_c_year = ls_gjahr-low - 1.
    IF ls_type-low = '08'.
      ls_rep_period-sign     = 'I'.
      ls_rep_period-option   = 'BT'.
      ls_rep_period-low      = '01'.
      ls_rep_period-high     = '16'.
      APPEND ls_rep_period TO ir_rep_period.
      ls_com_period-sign     = 'I'.
      ls_com_period-option   = 'BT'.
      ls_com_period-low      = '01'.
      ls_com_period-high     = '16'.
      APPEND ls_com_period TO ir_com_period.
      " Period
    ELSEIF ls_type-low NE '01' AND ls_type-low NE '06' AND ls_type-low NE '07' AND ls_type-low NE '08'. " nam, thang. 6 thang dau nam cuoi nam
      ls_rep_period-sign     = 'I'.
      ls_rep_period-option   = 'BT'.
      IF ls_type-low = '02'.
        ls_rep_period-low = '01'.
        ls_rep_period-high = '03'.
      ELSEIF ls_type-low = '03'.
        ls_rep_period-low = '04'.
        ls_rep_period-high = '06'.
      ELSEIF ls_type-low = '04'.
        ls_rep_period-low = '07'.
        ls_rep_period-high = '09'.
      ELSEIF ls_type-low = '05'.
        ls_rep_period-low = '10'.
        ls_rep_period-high = '12'.
      ENDIF.
      APPEND ls_rep_period TO ir_rep_period.
      " Compare Period
      ls_com_period-sign     = 'I'.
      ls_com_period-option   = 'BT'.
      IF ls_type-low = '02'.
        ls_com_period-low = '01'.
        ls_com_period-high = '03'.
      ELSEIF ls_type-low = '03'.
        ls_com_period-low = '04'.
        ls_com_period-high = '06'.
      ELSEIF ls_type-low = '04'.
        ls_com_period-low = '07'.
        ls_com_period-high = '09'.
      ELSEIF ls_type-low = '05'.
        ls_com_period-low = '10'.
        ls_com_period-high = '12'.
      ENDIF.
      APPEND ls_com_period TO ir_com_period.
    ELSEIF ls_type-low = '01'..
      ls_com_period-sign     = 'I'.
      ls_com_period-option   = 'BT'.
      ls_com_period-low      = ls_monat-low.
      ls_com_period-high     = ls_monat-low.
      APPEND ls_com_period TO ir_com_period.
      APPEND ls_com_period TO ir_rep_period.
    ELSE.
      IF ls_type-low = '06'. " 6 thang dau nam
        " Period
        ls_rep_period-sign     = 'I'.
        ls_rep_period-option   = 'BT'.
        ls_rep_period-low      = '01'.
        ls_rep_period-high     = '06'.
        APPEND ls_rep_period TO ir_rep_period.
        " Compare Period
        ls_com_period-sign     = 'I'.
        ls_com_period-option   = 'BT'.
        ls_com_period-low      = '01'.
        ls_com_period-high     = '06'.
        APPEND ls_com_period TO ir_com_period.
      ENDIF.

      IF ls_type-low = '07'. " 6 thang cuoi nam.
        " Period
        ls_rep_period-sign     = 'I'.
        ls_rep_period-option   = 'BT'.
        ls_rep_period-low      = '07'.
        ls_rep_period-high     = '12'.
        APPEND ls_rep_period TO ir_rep_period.
        " Compare Period
        ls_com_period-sign     = 'I'.
        ls_com_period-option   = 'BT'.
        ls_com_period-low      = '07'.
        ls_com_period-high     = '12'.
        APPEND ls_com_period TO ir_com_period.
      ENDIF.
    ENDIF.
    " Get Period Accumulated Information
    LOOP AT ir_rep_period INTO ls_rep_period.
      MOVE-CORRESPONDING ls_rep_period TO ls_rep_period_acc.
      ls_rep_period_acc-low = '01'.
      APPEND ls_rep_period_acc TO ir_rep_period_acc.
    ENDLOOP.

    LOOP AT ir_com_period INTO ls_com_period.
      MOVE-CORRESPONDING ls_com_period TO ls_com_period_acc.
      ls_com_period_acc-low = '01'.
      APPEND ls_com_period_acc TO ir_com_period_acc.
    ENDLOOP.
*--------------------------------*
    CHECK 1 = 2.
    CASE ls_type-low.
      WHEN 01.
        period = ls_monat-low.
      WHEN 02.
        period = 3.
      WHEN 03.
        period = 6.
      WHEN 04.
        period = 6.
      WHEN 05.
        period = 9.
      WHEN 06.
        period = 12.
      WHEN 07.
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
    DATA: ls_page_info      TYPE zcl_get_fillter=>st_page_info,

          ir_bukrs          TYPE tt_range,
          ir_rldnr          TYPE tt_range,
          ir_prctr          TYPE tt_range,
          ir_monat          TYPE tt_range,
          ir_gjahr          TYPE tt_range,
          ir_rep_period     TYPE tt_range,
          ir_com_period     TYPE tt_range,
          ir_rep_period_acc TYPE tt_range,
          ir_com_period_acc TYPE tt_range,
          ir_type           TYPE tt_range,
          ir_detail         TYPE tt_range,
          ls_glacc          TYPE LINE OF tt_range,
          ls_type           TYPE LINE OF tt_range,
          lr_glacc          TYPE tt_range.
    DATA: lt_data    TYPE TABLE OF zc_kqhdkd,
          lt_data_ct TYPE TABLE OF zc_kqhdkd.
    FREE: lt_data, lr_glacc.
    TRY.
* Khởi tạo đối tượng
        DATA(lo_kqhdkd)  = zcl_jp_get_data_kqhdkd=>get_instance( ).
        DATA(lo_comcode) = zcl_jp_common_core=>get_instance(  ).
        DATA(lo_common_app) = zcl_get_fillter_kqhdkd=>get_instance( ).

*  Lấy tham số
        lo_common_app->get_fillter_app(   EXPORTING
                                            io_request    = io_request
                                            io_response   = io_response
                                          IMPORTING
                                            ir_bukrs  = ir_bukrs
                                            ir_prctr  = ir_prctr
                                            ir_gjahr  = ir_gjahr
                                            ir_monat  = ir_monat
                                            ir_type   = ir_type
                                            ir_detail = ir_detail
                                            wa_page_info  = ls_page_info
                                        ).
        lo_kqhdkd->get_parameter(
          EXPORTING
            ir_monat  = ir_monat
            ir_type   = ir_type
            ir_gjahr  = ir_gjahr
            ir_detail = ir_detail
          IMPORTING
            period = gw_period
            gjahr  = gw_gjahr
            c_gjahr  = gw_c_gjahr
            budat_pre = gw_budat_pre
            budat_last = gw_budat_last
            ir_rep_period  =    ir_rep_period
            ir_com_period  =    ir_com_period
            ir_rep_period_acc = ir_rep_period_acc
            ir_com_period_acc = ir_com_period_acc
        ).
*----------------------------*
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
*----------------------------*
        CLEAR: gt_data[],gt_hierarchy[],lt_data[].
        "lấy currency code của bukrs
        SELECT SINGLE currency
             FROM I_CompanyCode
             WHERE CompanyCode IN @ir_bukrs
             INTO @gw_curr.
*         GLACCOUNT IN C.CODE
        SELECT * FROM I_GLAccountInCompanyCode
            WHERE CompanyCode IN @ir_bukrs
            INTO TABLE @DATA(gt_skb1).
*          "FSV
        SELECT * FROM I_GLAccountHierarchyNode
            WHERE GLAccountHierarchy = 'ZPL'
            INTO TABLE @gt_fsv.
        SORT gt_fsv BY HierarchyNode.
        gt_acc[] = gt_fsv[].
        DELETE gt_fsv WHERE GLAccount IS NOT INITIAL.
        DELETE gt_acc WHERE GLAccount IS INITIAL.

        IF gt_fsv[] IS NOT INITIAL.
          "text cho item
          SELECT HierarchyNode,
                 HierarchyNodeText
              FROM I_FinancialStatementHierNodeT
              FOR ALL ENTRIES IN @gt_fsv
              WHERE FinancialStatementHierarchy = @gt_fsv-GLAccountHierarchy
              AND HierarchyNode = @gt_fsv-HierarchyNode
              AND Language = 'E'
              INTO TABLE @DATA(lt_txt).
          SORT lt_txt BY HierarchyNode.
        ENDIF.

*        Build hierarchy
        DELETE gt_fsv WHERE HierarchyNode = '0ZPL'.
        DELETE gt_fsv WHERE ParentNode = '0ZPL' AND HierarchyNode ne '060'.
        LOOP AT gt_fsv INTO DATA(ls_fsv).
          gs_data-HierarchyNode = ls_fsv-HierarchyNode.
          READ TABLE lt_txt INTO DATA(ls_txt) WITH KEY HierarchyNode = ls_fsv-HierarchyNode BINARY SEARCH.
          IF sy-subrc = 0.
            gs_data-HierarchyNode_TXT = ls_txt-HierarchyNodeText.
          ENDIF.
          gs_data-parentNode = ls_fsv-ParentNode.
          APPEND gs_data TO gt_hierarchy.
          APPEND gs_data TO gt_data.
        ENDLOOP.

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
*--------------------------------------*
        SELECT
                 headers~LedgerGroup,
                 headers~AccountingDocumentType,
                 items~CompanyCode,
                 items~AccountingDocument,
                 items~FiscalYear,
                 items~glaccount,
                 items~AmountInCompanyCodeCurrency AS hsl,
                 items~ProfitCenter
               FROM I_JournalEntryItem AS items
               INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                                   AND items~AccountingDocument = headers~AccountingDocument
                                                   AND items~FiscalYear         = headers~FiscalYear
               WHERE headers~CompanyCode IN  @ir_bukrs
               AND headers~FiscalYear = @gw_gjahr
               AND ( headers~LedgerGroup = '0L' OR headers~LedgerGroup = '' )
               AND headers~AccountingDocumentType <> ''
               AND headers~AccountingDocumentType <> 'Z3'
               AND headers~FiscalPeriod IN @ir_rep_period
               AND ( items~Ledger = '0L' OR items~Ledger = '' )
               AND  ( items~glaccount LIKE '5%' OR items~glaccount LIKE '6%' OR items~glaccount LIKE '7%' OR items~glaccount LIKE '8%' )
               AND  items~ProfitCenter IN @ir_prctr
               INTO TABLE @DATA(gt_hsl_detail).
*--------------------------------------*
* Ky nay
        SELECT
             items~glaccount,
             SUM( items~AmountInCompanyCodeCurrency ) AS hsl
           FROM I_JournalEntryItem AS items
           INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                               AND items~AccountingDocument = headers~AccountingDocument
                                               AND items~FiscalYear         = headers~FiscalYear
           WHERE headers~CompanyCode IN  @ir_bukrs
           AND headers~FiscalYear = @gw_gjahr
           AND ( headers~LedgerGroup = '0L' OR headers~LedgerGroup = '' )
           AND headers~AccountingDocumentType <> ''
           AND headers~AccountingDocumentType <> 'Z3'
           AND headers~FiscalPeriod IN @ir_rep_period
           AND ( items~Ledger = '0L' OR items~Ledger = '' )
           AND  ( items~glaccount LIKE '5%' OR items~glaccount LIKE '6%' OR items~glaccount LIKE '7%' OR items~glaccount LIKE '8%' )
           AND  items~ProfitCenter IN @ir_prctr
           GROUP BY items~glaccount
           INTO TABLE @DATA(gt_hsl).
* ky truoc
        SELECT
             items~glaccount,
             SUM( items~AmountInCompanyCodeCurrency ) AS hsl
           FROM I_JournalEntryItem AS items
           INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                               AND items~AccountingDocument = headers~AccountingDocument
                                               AND items~FiscalYear         = headers~FiscalYear
           WHERE headers~CompanyCode IN  @ir_bukrs
           AND headers~FiscalYear = @gw_c_gjahr
           AND ( headers~LedgerGroup = '0L' OR headers~LedgerGroup = '' )
           AND headers~AccountingDocumentType <> ''
           AND headers~AccountingDocumentType <> 'Z3'
           AND headers~FiscalPeriod IN @ir_com_period
           AND ( items~Ledger = '0L' OR items~Ledger = '' )
           AND  ( items~glaccount LIKE '5%' OR items~glaccount LIKE '6%' OR items~glaccount LIKE '7%' OR items~glaccount LIKE '8%' )
           AND  items~ProfitCenter IN @ir_prctr
           GROUP BY items~glaccount
           INTO TABLE @DATA(gt_hslc).
        READ TABLE ir_type INTO ls_type INDEX 1.
*        IF ls_type-low NE '06' AND ls_type-low NE '07' AND ls_type-low NE '08'.
        " Lk ky nay
        SELECT
          items~glaccount,
          SUM( items~AmountInCompanyCodeCurrency ) AS hsl
        FROM I_JournalEntryItem AS items
        INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                            AND items~AccountingDocument = headers~AccountingDocument
                                            AND items~FiscalYear         = headers~FiscalYear
        WHERE headers~CompanyCode IN  @ir_bukrs
        AND headers~FiscalYear = @gw_gjahr
        AND ( headers~LedgerGroup = '0L' OR headers~LedgerGroup = '' )
        AND headers~AccountingDocumentType <> ''
        AND headers~AccountingDocumentType <> 'Z3'
        AND headers~FiscalPeriod IN @ir_rep_period_acc
        AND ( items~Ledger = '0L' OR items~Ledger = '' )
        AND  ( items~glaccount LIKE '5%' OR items~glaccount LIKE '6%' OR items~glaccount LIKE '7%' OR items~glaccount LIKE '8%' )
        AND  items~ProfitCenter IN @ir_prctr
        GROUP BY items~glaccount
        INTO TABLE @DATA(gt_hsl_1).
        " LK ky truoc
        SELECT
          items~glaccount,
          SUM( items~AmountInCompanyCodeCurrency ) AS hsl
        FROM I_JournalEntryItem AS items
        INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                            AND items~AccountingDocument = headers~AccountingDocument
                                            AND items~FiscalYear         = headers~FiscalYear
        WHERE headers~CompanyCode IN  @ir_bukrs
        AND headers~FiscalYear = @gw_c_gjahr
        AND ( headers~LedgerGroup = '0L' OR headers~LedgerGroup = '' )
        AND headers~AccountingDocumentType <> ''
        AND headers~AccountingDocumentType <> 'Z3'
        AND headers~FiscalPeriod IN @ir_com_period_acc
        AND ( items~Ledger = '0L' OR items~Ledger = '' )
        AND  ( items~glaccount LIKE '5%' OR items~glaccount LIKE '6%' OR items~glaccount LIKE '7%' OR items~glaccount LIKE '8%' )
        AND  items~ProfitCenter IN @ir_prctr
        GROUP BY items~glaccount
        INTO TABLE @DATA(gt_hslc_1).
*        ENDIF.
*---------------------------------------* Process data
        DATA: lv_total TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency,
              lv_index TYPE int4 VALUE IS INITIAL,
              ls_hsl   LIKE LINE OF gt_hsl_1,
              lv_racct TYPE i_operationalacctgdocitem-glaccount,
              lv_count TYPE int4.
        CLEAR: lv_total.
        DO 2 TIMES.
          IF sy-index = 1.
            lv_racct = '7111001000'.
          ELSE.
            lv_racct = '8111001000'.
          ENDIF.
          READ TABLE gt_hsl_1 INTO ls_hsl WITH KEY glaccount = lv_racct.
          IF sy-subrc EQ 0.
            lv_index = sy-tabix.
            lv_total = lv_total + ls_hsl-hsl.
            DELETE gt_hsl_1 INDEX lv_index.
            CLEAR: ls_hsl.
          ENDIF.
        ENDDO.
        IF lv_total > 0. "+CT32
          ls_hsl-glaccount = '8111001000'.
          ls_hsl-hsl = lv_total.
          APPEND ls_hsl TO gt_hsl_1.
        ELSEIF lv_total < 0. "+CT31
          ls_hsl-glaccount = '7111001000'.
          ls_hsl-hsl = lv_total.
          APPEND ls_hsl TO gt_hsl_1.
        ENDIF.

        CLEAR: lv_total.
        DO 2 TIMES.
          IF sy-index = 1.
            lv_racct = '7111001000'.
          ELSE.
            lv_racct = '8111001000'.
          ENDIF.
          READ TABLE gt_hslc_1 INTO ls_hsl WITH KEY glaccount = lv_racct.
          IF sy-subrc EQ 0.
            lv_index = sy-tabix.
            lv_total = lv_total + ls_hsl-hsl.
            DELETE gt_hslc_1 INDEX lv_index.
            CLEAR: ls_hsl.
          ENDIF.
        ENDDO.
        IF lv_total > 0. "+CT32
          ls_hsl-glaccount = '8111001000'.
          ls_hsl-hsl = lv_total.
          APPEND ls_hsl TO gt_hslc_1.
        ELSEIF lv_total < 0. "+CT31
          ls_hsl-glaccount = '7111001000'.
          ls_hsl-hsl = lv_total.
          APPEND ls_hsl TO gt_hslc_1.
        ENDIF.
*---------------------------------------*
        DATA: lw_hsl    TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency,
              lw_hslc   TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency,
              lw_hsl_1  TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency,
              lw_hslc_1 TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency,
              lw_ergsl  TYPE I_GLAccountHierarchyNode-ParentNode.
* FIELD-SYMBOLS <ls_fagl_011zc> TYPE zc_kqhdkd.
* FIELD-SYMBOLS <ls_fagl_011zc_tmp> TYPE zc_kqhdkd.
        LOOP AT gt_hsl INTO ls_hsl.
          LOOP AT gt_acc ASSIGNING FIELD-SYMBOL(<fs_acc>)
            WHERE glaccount = ls_hsl-glaccount.
            CLEAR:  lw_hsl,
                    lw_hslc,
                    lw_hsl_1,
                    lw_hslc_1,
                    lw_ergsl.
            lw_hsl = lw_hsl + ls_hsl-hsl.

            lw_ergsl = <fs_acc>-parentNode.

            IF lw_ergsl IS NOT INITIAL.
              READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<ls_fagl_011zc_tmp>) WITH KEY HierarchyNode = lw_ergsl.
              IF sy-subrc IS INITIAL.
                <ls_fagl_011zc_tmp>-sokynay = <ls_fagl_011zc_tmp>-sokynay  + lw_hsl.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDLOOP.

        LOOP AT gt_hslc INTO ls_hsl.
          LOOP AT gt_acc ASSIGNING <fs_acc>
             WHERE glaccount = ls_hsl-glaccount.
            CLEAR:  lw_hsl,
                    lw_hslc,
                    lw_hsl_1,
                    lw_hslc_1,
                    lw_ergsl.

            lw_hslc = lw_hslc + ls_hsl-hsl.
            lw_ergsl = <fs_acc>-parentNode.

            IF lw_ergsl IS NOT INITIAL.
              READ TABLE gt_data ASSIGNING <ls_fagl_011zc_tmp> WITH KEY HierarchyNode = lw_ergsl .
              IF sy-subrc IS INITIAL.
                <ls_fagl_011zc_tmp>-sokytruoc = <ls_fagl_011zc_tmp>-sokytruoc + lw_hslc.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDLOOP.

        LOOP AT gt_hsl_1 INTO ls_hsl.
          LOOP AT gt_acc ASSIGNING <fs_acc>
             WHERE glaccount = ls_hsl-glaccount.
            CLEAR:  lw_hsl,
                    lw_hslc,
                    lw_hsl_1,
                    lw_hslc_1,
                    lw_ergsl.
            lw_hsl_1 = lw_hsl_1 + ls_hsl-hsl.
            lw_ergsl = <fs_acc>-parentNode.

            IF lw_ergsl IS NOT INITIAL.
              READ TABLE gt_data ASSIGNING <ls_fagl_011zc_tmp> WITH KEY HierarchyNode = lw_ergsl .
              IF sy-subrc IS INITIAL.
                <ls_fagl_011zc_tmp>-lkkynay = <ls_fagl_011zc_tmp>-lkkynay  + lw_hsl_1.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDLOOP.


        LOOP AT gt_hslc_1 INTO ls_hsl.
          LOOP AT gt_acc ASSIGNING <fs_acc>
          WHERE glaccount = ls_hsl-glaccount.
            CLEAR:  lw_hsl,
                    lw_hslc,
                    lw_hsl_1,
                    lw_hslc_1,
                    lw_ergsl.
            lw_hslc_1 = lw_hslc_1 + ls_hsl-hsl.
            lw_ergsl = <fs_acc>-parentNode.

            IF lw_ergsl IS NOT INITIAL.
              READ TABLE gt_data ASSIGNING <ls_fagl_011zc_tmp> WITH KEY HierarchyNode = lw_ergsl.
              IF sy-subrc IS INITIAL.
                <ls_fagl_011zc_tmp>-lkkytruoc = <ls_fagl_011zc_tmp>-lkkytruoc  + lw_hslc_1.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
*---------------------------------------*
        DATA: lw_hsl_kynay     TYPE dmbtr,
              lw_hsl_kytruoc   TYPE dmbtr,
              lw_hsl_lkkynay   TYPE dmbtr,
              lw_hsl_lkkytruoc TYPE dmbtr.
        LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
          READ TABLE gt_acc INTO gs_acc WITH KEY ParentNode = <fs_data>-HierarchyNode.
          IF sy-subrc NE 0. " Chỉ loop nhưng line con
            CONTINUE.
          ENDIF.
          READ TABLE gt_hierarchy ASSIGNING FIELD-SYMBOL(<fs_hierarchy>)  WITH KEY HierarchyNode = <fs_data>-HierarchyNode.
          IF sy-subrc = 0.
            <fs_hierarchy>-sokynay = <fs_data>-sokynay.
            <fs_hierarchy>-sokytruoc = <fs_data>-sokytruoc.
            <fs_hierarchy>-lkkynay = <fs_data>-lkkynay.
            <fs_hierarchy>-lkkytruoc = <fs_data>-lkkytruoc.
            lw_hsl_kynay = <fs_data>-sokynay.
            lw_hsl_kytruoc = <fs_data>-sokytruoc.
            lw_hsl_lkkynay =  <fs_data>-lkkynay.
            lw_hsl_lkkytruoc =  <fs_data>-lkkytruoc.
            lo_kqhdkd->find_parent(
              EXPORTING
                parentnode = <fs_data>-parentnode
              CHANGING
                sokynay        = lw_hsl_kynay
                sokytruoc      = lw_hsl_kytruoc
                lkkynay        = lw_hsl_lkkynay
                lkkytruoc      = lw_hsl_lkkytruoc
                lt_data        = gt_data
            ).
          ENDIF.
        ENDLOOP.
        " Update sign
        LOOP AT gt_hierarchy ASSIGNING FIELD-SYMBOL(<fs_hier>).
          READ TABLE gt_fsv INTO ls_fsv WITH KEY HierarchyNode = <fs_hier>-HierarchyNode.
          IF  sy-subrc = 0 AND ls_fsv-SignIsInverted = 'X'.
            <fs_hier>-sokynay  = 0 - <fs_hier>-sokynay.
            <fs_hier>-sokytruoc = 0 - <fs_hier>-sokytruoc.
            <fs_hier>-lkkynay  = 0 - <fs_hier>-lkkynay.
            <fs_hier>-lkkytruoc = 0 - <fs_hier>-lkkytruoc.
          ENDIF.
          IF <fs_hier>-HierarchyNode = '001' OR <fs_hier>-HierarchyNode = '010' OR <fs_hier>-HierarchyNode = '020'
          OR <fs_hier>-HierarchyNode = '030'  OR <fs_hier>-HierarchyNode = '040'  OR <fs_hier>-HierarchyNode = '050'
          OR <fs_hier>-HierarchyNode = '060' OR <fs_hier>-HierarchyNode = '070'.
            <fs_hier>-type = '1'.
          ENDIF.
        ENDLOOP.
        DELETE gt_hierarchy WHERE HierarchyNode = 24.
*---------------------------------------*
*        IF  gt_hierarchy IS INITIAL.
*          gs_data-CCadrr = '1670'.
*          gs_data-CCname =  'test'.
*          gs_data-HierarchyNode_TXT = 'abc'.
*          gs_data-sokynay = 1000.
*          gs_data-sokytruoc = 1000.
*          gs_data-lkkynay = 1000.
*          gs_data-lkkytruoc = 1000.
*          APPEND gs_data TO gt_hierarchy.
*          gs_data-CCadrr = '1670'.
*          gs_data-CCname =  'test'.
*          gs_data-HierarchyNode_TXT = 'ab1'.
*          gs_data-sokynay = 2000.
*          gs_data-sokytruoc = 1000.
*          gs_data-lkkynay = 1000.
*          gs_data-lkkytruoc = 1000.
*          APPEND gs_data TO gt_hierarchy.
*        ENDIF.

*        SORT gt_data BY HierarchyNode kunnr glaccount.


*          export data
*------------------------------------*
        IF ls_page_info-page_size < 0.
          ls_page_info-page_size = 50.
        ENDIF.

        DATA(max_rows) = COND #( WHEN ls_page_info-page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                   ELSE ls_page_info-page_size ).

        max_rows = ls_page_info-page_size + ls_page_info-offset.

        LOOP AT gt_hierarchy INTO DATA(ls_data).
          IF sy-tabix > ls_page_info-offset.
            IF sy-tabix > max_rows.
              EXIT.
            ELSE.
              ls_data-CCadrr = gs_bukrs-companycodeaddr.
              ls_data-CCname = gs_bukrs-companycodename.
              ls_data-sokynay = ls_data-sokynay * 100.
              ls_data-sokytruoc = ls_data-sokytruoc * 100.
              ls_data-lkkynay = ls_data-lkkynay * 100.
              ls_data-lkkytruoc = ls_data-lkkytruoc * 100.
              APPEND ls_data TO lt_data.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        IF io_request->is_data_requested( ).
          io_response->set_data( lt_data ).
        ENDIF.

      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

        RAISE EXCEPTION TYPE zcl_jp_get_data_kqhdkd
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

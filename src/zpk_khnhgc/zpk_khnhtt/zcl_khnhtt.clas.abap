CLASS zcl_khnhtt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider.

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE c LENGTH 45,
             high   TYPE c LENGTH 45,
           END OF ty_range_option,
           tt_ranges  TYPE TABLE OF ty_range_option WITH EMPTY KEY,

           gty_khnhtt TYPE STANDARD TABLE OF zc_khNHTT.

*main logic
    CLASS-METHODS get_ns_thang
      IMPORTING
        ir_hierarchy TYPE tt_ranges
        ir_plant     TYPE tt_ranges
        lv_monthfr   TYPE zde_period
      EXPORTING
        e_ns_thang   TYPE gty_khnhtt.

    CLASS-DATA: lt_khnhtt TYPE TABLE OF zc_khnhtt.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_khnhtt IMPLEMENTATION.

  METHOD get_ns_thang.
    DATA: lt_data TYPE TABLE OF zc_khnhtt,
          ls_data TYPE zc_khnhtt.

*logic

    DATA: lv_year_cap     TYPE gjahr,
          lv_year_from    TYPE d,
          lv_year_to      TYPE d,
          lv_wd           TYPE p LENGTH 5 DECIMALS 0,
          lv_week_num     TYPE i,
          lv_dfrom        TYPE d,
          lv_dto          TYPE d,
          lv_daily        TYPE p LENGTH 15 DECIMALS 2,
          lv_productivity TYPE p LENGTH 15 DECIMALS 0
          .

    DATA:
      lv_monthto TYPE n LENGTH 6,
      lv_year    TYPE n LENGTH 4,
      lv_month   TYPE n LENGTH 2.

    lv_year  = lv_monthfr(4).    "2025
    lv_month = lv_monthfr+4(2).  "11

    lv_month = lv_month + 11.    "22
    WHILE lv_month > 12.
      lv_month = lv_month - 12.  "10
      lv_year = lv_year + 1.     "2026
    ENDWHILE.
    lv_monthto = |{ lv_year }{ lv_month ALIGN = RIGHT PAD = '0' WIDTH = 2 }|.

    SELECT weeknum, zper, zyear, zdatefr, zdateto
    FROM ZR_ZWeekTP
    WHERE zper >= @lv_monthfr
    AND zper <= @lv_monthto
    INTO TABLE @DATA(lt_weektp).
    SORT lt_weektp BY zyear weeknum ASCENDING.

    READ TABLE lt_weektp INTO DATA(ls_first_week) INDEX 1.
    READ TABLE lt_weektp INTO DATA(ls_last_week) INDEX lines( lt_weektp ).
    DATA:
      lr_weeks   TYPE tt_ranges,
      lr_years   TYPE tt_ranges,
      ls_year    LIKE LINE OF lr_years,
      ls_week    LIKE LINE OF lr_weeks,
      lv_week_fr TYPE i,
      lv_year_fr TYPE gjahr
      .

    ls_week-sign = 'I'.
    ls_week-option = 'EQ'.
    ls_week-low = ls_first_week-Weeknum.
    APPEND ls_week TO lr_weeks.

    ls_year-sign = 'I'.
    ls_year-option = 'EQ'.
    ls_year-low = ls_first_week-zyear.
    APPEND ls_year TO lr_years.

    lv_week_fr = ls_week-low.
    lv_year_fr = ls_year-low.


*lấy kế hoạch theo tuần


    DATA: lr_date TYPE tt_ranges.
*

    TYPES: BEGIN OF lty_hierarchy4,
             producthierarchy4 TYPE zde_char50,
           END OF lty_hierarchy4.

    DATA: lt_hierarchy4 TYPE STANDARD TABLE OF lty_hierarchy4 WITH DEFAULT KEY.

    TYPES: BEGIN OF lty_salesorder,
             producthierarchy3     TYPE i_produnivhierarchynodebasic-parentnode,
             producthierarchy4     TYPE i_produnivhierarchynodebasic-hierarchynode,

             hierarchynodelevel    TYPE i_produnivhierarchynodebasic-hierarchynodelevel,

             product               TYPE i_salesorderitem-product,
             plant                 TYPE i_salesorderitem-plant,

             salesorder            TYPE i_salesorderitem-salesorder,
             salesorderitem        TYPE i_salesorderitem-salesorderitem,

             orderquantity         TYPE i_salesorderitem-orderquantity,
             orderquantityunit     TYPE i_salesorderitem-orderquantityunit,
             deliverystatus        TYPE i_salesorderitem-deliverystatus,

             requesteddeliverydate TYPE i_salesorderscheduleline-requesteddeliverydate,
           END OF lty_salesorder.

    DATA: lt_salesorder TYPE STANDARD TABLE OF lty_salesorder WITH EMPTY KEY.

    SELECT
        hierarchy4~parentnode AS producthierarchy3,
        hierarchy4~hierarchynode AS producthierarchy4,

        hierarchy4~hierarchynodelevel,

        salesorder~product,
        salesorder~plant,

        salesorder~salesorder,
        salesorder~salesorderitem,

        salesorder~orderquantity,
        salesorder~orderquantityunit,
        salesorder~deliverystatus,

        scheduleline~requesteddeliverydate

    FROM i_salesorderitem AS salesorder

    INNER JOIN i_salesorderscheduleline AS scheduleline
    ON scheduleline~salesorder = salesorder~salesorder
    AND scheduleline~salesorderitem = salesorder~salesorderitem

    INNER JOIN i_produnivhierarchynodebasic AS hierarchy4
    ON hierarchy4~product = salesorder~product
    AND hierarchy4~prodhierarchyvaliditystartdate <= salesorder~creationdate
    AND hierarchy4~prodhierarchyvalidityenddate >= salesorder~creationdate

    WHERE scheduleline~requesteddeliverydate IN @lr_date
      AND salesorder~deliverystatus IN ( 'A', 'B' )

      AND salesorder~plant IN @ir_plant

      AND hierarchy4~produnivhierarchy = 'PH_MANUFACTURING'
*
*      AND hierarchy4~hierarchynode  IN @ir_hierarchy4
      AND hierarchy4~hierarchynodelevel = '000004'

      AND hierarchy4~parentnode     IN @ir_hierarchy

      AND scheduleline~requesteddeliverydate <= @ls_last_week-Zdateto
      AND scheduleline~requesteddeliverydate >= @ls_first_week-Zdatefr

    INTO CORRESPONDING FIELDS OF TABLE @lt_salesorder.

    IF sy-subrc EQ 0.
*      MOVE-CORRESPONDING lt_salesorder TO lt_hierarchy4.
*
*      SORT lt_hierarchy4 BY producthierarchy4 ASCENDING.
*      DELETE ADJACENT DUPLICATES FROM lt_hierarchy4 COMPARING producthierarchy4.
    ENDIF.

    TYPES: BEGIN OF lty_agg,
             producthierarchy3 TYPE i_produnivhierarchynodebasic-parentnode,
             producthierarchy4 TYPE i_produnivhierarchynodebasic-hierarchynode,
             plant             TYPE werks_d,
             week              TYPE zde_char2,
             year              TYPE char4,
             orderqty_sum      TYPE p LENGTH 15 DECIMALS 0,
           END OF lty_agg.

    DATA: ls_agg TYPE lty_agg,
          lt_agg TYPE TABLE OF lty_agg.

    LOOP AT lt_salesorder ASSIGNING FIELD-SYMBOL(<ls>).

      CLEAR ls_agg.

      ls_agg-producthierarchy3 = <ls>-producthierarchy3.
      ls_agg-producthierarchy4 = <ls>-producthierarchy4.
      ls_agg-plant             = <ls>-plant.

      " ABAP built-in function (dùng được trong expression, không phải SQL)
      ls_agg-year = <ls>-requesteddeliverydate+0(4).
      zcl_iso_week=>get_iso_week(
        EXPORTING
          i_date     = <ls>-requesteddeliverydate
        IMPORTING
          e_week = Data(week) ).

      ls_agg-week = week+4(2).
      " Giá trị cần cộng
      ls_agg-orderqty_sum = <ls>-orderquantity.

      " COLLECT: nếu key đã tồn tại thì tự động cộng vào field numeric
      COLLECT ls_agg INTO lt_agg.
    ENDLOOP.

    SORT lt_agg BY producthierarchy3 plant year week ASCENDING.

*------------------------------------
*tính năng suất tuần

    TYPES: BEGIN OF lty_ns,
             producthierarchy3 TYPE zde_char50,
             plant             TYPE werks_d,
             year              TYPE char4,
             week              TYPE zde_char2,
             ns_value          TYPE string,
           END OF lty_ns.
    DATA : lt_ns TYPE TABLE OF lty_ns,
           ls_ns LIKE LINE OF lt_ns.

    SELECT *
      FROM zui_kbnlngc
*      WHERE workcenter    IN @ir_workcenter
        WHERE hierarchynode IN @ir_hierarchy
        AND plant         IN @ir_plant
      INTO TABLE @DATA(lt_kbnlngc).

    "Lấy khai báo số ngày làm việc theo tuần/năm

    SELECT kbsnlv~*
      FROM zui_kbsnlv AS kbsnlv
      INNER JOIN @lt_weektp AS wtp
        ON  wtp~weeknum  = kbsnlv~week
        AND wtp~zyear    = kbsnlv~zyear
      WHERE kbsnlv~plant IN @ir_plant
      INTO TABLE @DATA(lt_kbsnlv).

    LOOP AT lt_kbnlngc INTO DATA(ls_kbnlngc).

      LOOP AT lt_kbsnlv INTO DATA(ls_kbsnlv)
           WHERE workcenter = ls_kbnlngc-workcenter
             AND plant      = ls_kbnlngc-plant.

        lv_year_cap = ls_kbsnlv-zyear.
        lv_week_num = CONV i( ls_kbsnlv-week ).

        lv_dfrom = zcl_week_util=>get_monday_of_week(
          iv_year = lv_year_cap
          iv_week = lv_week_num ).

        lv_dto = zcl_week_util=>get_sunday_of_week(
          iv_year = lv_year_cap
          iv_week = lv_week_num ).

        DATA(lt_cap) = zcl_kbsn_ns_tuan=>load_capacities(
          iv_wc    = ls_kbnlngc-workcenter
          iv_node  = ls_kbnlngc-hierarchynode
          iv_plant = ls_kbnlngc-plant
*          iv_yfrom = |{ lv_year_cap }0101|
*          iv_yto   = |{ lv_year_cap }1231| )
          iv_yfrom = ls_first_week-zdatefr
          iv_yto   = ls_last_week-zdateto ).

        lv_daily = zcl_kbsn_ns_tuan=>find_daily_for_week(
          it_cap       = lt_cap
          iv_week_from = lv_dfrom
          iv_week_to   = lv_dto ).

        lv_wd = ls_kbsnlv-workingdays.
        DATA lv_result TYPE p DECIMALS 0.
        lv_result = lv_wd * lv_daily.

        CLEAR ls_ns.
        ls_ns-producthierarchy3 = ls_kbnlngc-hierarchynode.
        ls_ns-plant             = ls_kbnlngc-plant.
        ls_ns-year              = lv_year_cap.
        ls_ns-week              = ls_kbsnlv-week.
        ls_ns-ns_value          = lv_result.

        collect ls_ns INTO  lt_ns.

      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_agg INTO ls_agg.

      READ TABLE lt_weektp INTO DATA(ls_weektp_match)
           WITH KEY zyear = ls_agg-year
                    weeknum = ls_agg-week.

      IF sy-subrc = 0.
        lv_month = ls_weektp_match-zper.
      ELSE.
        CONTINUE.
      ENDIF.

      CLEAR ls_data.
      ls_data-ct01 = ls_agg-producthierarchy3.
      ls_data-ct03 = ls_agg-plant.
      ls_data-ct05 = lv_month.
      ls_data-ct06 = ls_agg-week.
      ls_data-ct07 = ls_agg-orderqty_sum.
      READ TABLE lt_ns INTO ls_ns
     WITH KEY producthierarchy3 = ls_agg-producthierarchy3
              plant             = ls_agg-plant
              year              = ls_agg-year
              week              = ls_agg-week.

      IF sy-subrc = 0.
        ls_data-ct08 = ls_ns-ns_value.
      ELSE.
        ls_data-ct08 = 0.
      ENDIF.

      ls_data-ct09 = ls_data-ct08 - ls_data-ct07.

      APPEND ls_data TO lt_data.

    ENDLOOP.

    e_ns_thang = lt_data.


  ENDMETHOD.

  METHOD if_rap_query_provider~select.

    DATA: ir_hierarchy TYPE tt_ranges,
          ir_plant     TYPE tt_ranges,
          lv_monthfr   TYPE zde_period.
*get filter
    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
*parse filter
    LOOP AT lt_filters INTO DATA(ls_filters).
      CASE ls_filters-name.
        WHEN 'CT01'.
          MOVE-CORRESPONDING ls_filters-range TO ir_hierarchy.
        WHEN 'CT03'.
          MOVE-CORRESPONDING ls_filters-range TO ir_plant.
        WHEN 'MONTH_FROM'.
          READ TABLE ls_filters-range INDEX 1 INTO DATA(ls_monthfr).
          lv_monthfr = ls_monthfr-low.
      ENDCASE.
    ENDLOOP.
* build data
    zcl_khnhtt=>get_ns_thang(
  EXPORTING
    ir_hierarchy  = ir_hierarchy
    ir_plant      = ir_plant
    lv_monthfr = lv_monthfr
  IMPORTING
    e_ns_thang           = lt_khnhtt

).

    LOOP AT lt_khnhtt ASSIGNING FIELD-SYMBOL(<fs_khnhtt>).
      SELECT SINGLE produnivhierarchynodetext
  FROM i_produnivhiernodetext_2
  WHERE language = 'E'
    AND hierarchynode = @<fs_khnhtt>-ct01
    AND produnivhierarchy = 'PH_MANUFACTURING'
  INTO @<fs_khnhtt>-ct02.

      SELECT SINGLE plantname
FROM i_plant
WHERE plant = @<fs_khnhtt>-ct03
INTO @<fs_khnhtt>-ct04.
    ENDLOOP.

    " Sorting
    DATA(sort_order) = VALUE abap_sortorder_tab(
      FOR sort_element IN io_request->get_sort_elements( )
      ( name = sort_element-element_name descending = sort_element-descending ) ).
    IF sort_order IS NOT INITIAL.
      SORT lt_khnhtt BY (sort_order).
    ENDIF.

    " Paging
    DATA(lv_total_records) = lines( lt_khnhtt ).
    DATA(lt_result) = lt_khnhtt.
    DATA(lo_paging) = io_request->get_paging( ).

    IF lo_paging IS BOUND.
      DATA(top) = lo_paging->get_page_size( ).
      IF top < 0. " -1 means all records
        top = lv_total_records.
      ENDIF.
      DATA(skip) = lo_paging->get_offset( ).

      IF skip >= lv_total_records.
        CLEAR lt_result.
      ELSEIF top = 0.
        CLEAR lt_result.
      ELSE.
        DATA(lv_start_index) = skip + 1.
        DATA(lv_end_index) = skip + top.

        IF lv_end_index > lv_total_records.
          lv_end_index = lv_total_records.
        ENDIF.

        DATA: lt_paged_result LIKE lt_result.
        CLEAR lt_paged_result.

        DATA(lv_index) = lv_start_index.
        WHILE lv_index <= lv_end_index.
          APPEND lt_result[ lv_index ] TO lt_paged_result.
          lv_index = lv_index + 1.
        ENDWHILE.

        lt_result = lt_paged_result.
      ENDIF.
    ENDIF.

    " Return data
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_khnhtt ) ).
    ENDIF.

    IF io_request->is_data_requested( ).
      io_response->set_data( lt_result ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

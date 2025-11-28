CLASS zcl_kbsn_ns_tuan DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  INHERITING FROM cx_rap_query_provider.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_ranges,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE c LENGTH 45,
             high   TYPE c LENGTH 45,
           END OF ty_ranges,

           BEGIN OF ty_returns,
             msgty TYPE symsgty,  "char(1) Message Type
             msgid TYPE symsgid,  "char(20) Message Class
             msgno TYPE symsgno,  "numc(3) Message Number
             msgv1 TYPE symsgv,   "char(50) Message Variable
             msgv2 TYPE symsgv,   "char(50) Message Variable
             msgv3 TYPE symsgv,   "char(50) Message Variable
             msgv4 TYPE symsgv,
           END OF ty_returns,

           gty_kbsn_lamviec TYPE STANDARD TABLE OF zcs_kbsn_lamviec WITH EMPTY KEY,
           gty_kbnln_gc     TYPE STANDARD TABLE OF zui_kbnlngc     WITH EMPTY KEY,
           tt_ranges        TYPE STANDARD TABLE OF ty_ranges       WITH EMPTY KEY,
           tt_returns       TYPE STANDARD TABLE OF ty_returns      WITH EMPTY KEY.

    DATA gt_kbsn_lamviec TYPE gty_kbsn_lamviec.

    "Main logic
    CLASS-METHODS get_ns_tuan
      IMPORTING
        ir_workcenter    TYPE tt_ranges OPTIONAL
        ir_hierarchynode TYPE tt_ranges OPTIONAL
        ir_plant         TYPE tt_ranges OPTIONAL
        ir_week          TYPE tt_ranges OPTIONAL
        ir_year          TYPE tt_ranges OPTIONAL
        iv_week_from     TYPE i
        iv_year_from     TYPE gjahr
      EXPORTING
        et_data          TYPE gty_kbsn_lamviec
        et_returns       TYPE tt_returns.

    " Helpers
    CLASS-METHODS get_week_range
      IMPORTING iv_year      TYPE gjahr
                iv_week      TYPE i
      EXPORTING ev_date_from TYPE d
                ev_date_to   TYPE d.

    CLASS-METHODS load_capacities
      IMPORTING iv_wc         TYPE zui_kbnlngc-workcenter
                iv_node       TYPE zui_kbnlngc-hierarchynode
                iv_plant      TYPE zui_kbnlngc-plant
                iv_yfrom      TYPE d
                iv_yto        TYPE d
      RETURNING VALUE(rt_cap) TYPE gty_kbnln_gc.

    CLASS-METHODS find_daily_for_week
      IMPORTING it_cap        TYPE gty_kbnln_gc
                iv_week_from  TYPE d
                iv_week_to    TYPE d
      RETURNING VALUE(rv_day) TYPE zui_kbnlngc-dailyproductivity.

    "Custom Entity / Query Provider
    INTERFACES if_rap_query_provider.

    "Get Filter Ranges
    METHODS get_provided_ranges
      IMPORTING
        io_request       TYPE REF TO if_rap_query_request
      EXPORTING
        er_workcenter    TYPE tt_ranges
        er_plant         TYPE tt_ranges
        er_hierarchynode TYPE tt_ranges
        er_week          TYPE tt_ranges
        er_year          TYPE tt_ranges
      RAISING
        cx_rap_query_prov_not_impl
        cx_rap_query_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_kbsn_ns_tuan IMPLEMENTATION.


  METHOD get_ns_tuan.
    "*======================================================================
    "* Main: Tính năng suất theo tuần, map vào W1..W54
    "*======================================================================

    TYPES: BEGIN OF lty_data,
             workcenter           TYPE arbpl,
             hierarchynode        TYPE zde_char50,
             plant                TYPE werks_d,
             week                 TYPE zde_char2,
             zyear                TYPE char4,
             w1workingdays        TYPE zui_kbsnlv-workingdays,
             w1dailyproductivity  TYPE zui_kbnlngc-dailyproductivity,
             w2workingdays        TYPE zui_kbsnlv-workingdays,
             w2dailyproductivity  TYPE zui_kbnlngc-dailyproductivity,
             w3workingdays        TYPE zui_kbsnlv-workingdays,
             w3dailyproductivity  TYPE zui_kbnlngc-dailyproductivity,
             w4workingdays        TYPE zui_kbsnlv-workingdays,
             w4dailyproductivity  TYPE zui_kbnlngc-dailyproductivity,
             w5workingdays        TYPE zui_kbsnlv-workingdays,
             w5dailyproductivity  TYPE zui_kbnlngc-dailyproductivity,
             w6workingdays        TYPE zui_kbsnlv-workingdays,
             w6dailyproductivity  TYPE zui_kbnlngc-dailyproductivity,
             w7workingdays        TYPE zui_kbsnlv-workingdays,
             w7dailyproductivity  TYPE zui_kbnlngc-dailyproductivity,
             w8workingdays        TYPE zui_kbsnlv-workingdays,
             w8dailyproductivity  TYPE zui_kbnlngc-dailyproductivity,
             w9workingdays        TYPE zui_kbsnlv-workingdays,
             w9dailyproductivity  TYPE zui_kbnlngc-dailyproductivity,
             w10workingdays       TYPE zui_kbsnlv-workingdays,
             w10dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w11workingdays       TYPE zui_kbsnlv-workingdays,
             w11dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w12workingdays       TYPE zui_kbsnlv-workingdays,
             w12dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w13workingdays       TYPE zui_kbsnlv-workingdays,
             w13dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w14workingdays       TYPE zui_kbsnlv-workingdays,
             w14dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w15workingdays       TYPE zui_kbsnlv-workingdays,
             w15dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w16workingdays       TYPE zui_kbsnlv-workingdays,
             w16dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w17workingdays       TYPE zui_kbsnlv-workingdays,
             w17dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w18workingdays       TYPE zui_kbsnlv-workingdays,
             w18dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w19workingdays       TYPE zui_kbsnlv-workingdays,
             w19dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w20workingdays       TYPE zui_kbsnlv-workingdays,
             w20dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w21workingdays       TYPE zui_kbsnlv-workingdays,
             w21dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w22workingdays       TYPE zui_kbsnlv-workingdays,
             w22dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w23workingdays       TYPE zui_kbsnlv-workingdays,
             w23dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w24workingdays       TYPE zui_kbsnlv-workingdays,
             w24dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w25workingdays       TYPE zui_kbsnlv-workingdays,
             w25dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w26workingdays       TYPE zui_kbsnlv-workingdays,
             w26dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w27workingdays       TYPE zui_kbsnlv-workingdays,
             w27dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w28workingdays       TYPE zui_kbsnlv-workingdays,
             w28dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w29workingdays       TYPE zui_kbsnlv-workingdays,
             w29dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w30workingdays       TYPE zui_kbsnlv-workingdays,
             w30dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w31workingdays       TYPE zui_kbsnlv-workingdays,
             w31dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w32workingdays       TYPE zui_kbsnlv-workingdays,
             w32dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w33workingdays       TYPE zui_kbsnlv-workingdays,
             w33dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w34workingdays       TYPE zui_kbsnlv-workingdays,
             w34dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w35workingdays       TYPE zui_kbsnlv-workingdays,
             w35dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w36workingdays       TYPE zui_kbsnlv-workingdays,
             w36dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w37workingdays       TYPE zui_kbsnlv-workingdays,
             w37dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w38workingdays       TYPE zui_kbsnlv-workingdays,
             w38dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w39workingdays       TYPE zui_kbsnlv-workingdays,
             w39dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w40workingdays       TYPE zui_kbsnlv-workingdays,
             w40dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w41workingdays       TYPE zui_kbsnlv-workingdays,
             w41dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w42workingdays       TYPE zui_kbsnlv-workingdays,
             w42dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w43workingdays       TYPE zui_kbsnlv-workingdays,
             w43dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w44workingdays       TYPE zui_kbsnlv-workingdays,
             w44dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w45workingdays       TYPE zui_kbsnlv-workingdays,
             w45dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w46workingdays       TYPE zui_kbsnlv-workingdays,
             w46dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w47workingdays       TYPE zui_kbsnlv-workingdays,
             w47dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w48workingdays       TYPE zui_kbsnlv-workingdays,
             w48dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w49workingdays       TYPE zui_kbsnlv-workingdays,
             w49dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w50workingdays       TYPE zui_kbsnlv-workingdays,
             w50dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w51workingdays       TYPE zui_kbsnlv-workingdays,
             w51dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w52workingdays       TYPE zui_kbsnlv-workingdays,
             w52dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w53workingdays       TYPE zui_kbsnlv-workingdays,
             w53dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
             w54workingdays       TYPE zui_kbsnlv-workingdays,
             w54dailyproductivity TYPE zui_kbnlngc-dailyproductivity,
           END OF lty_data.

    DATA: lt_data TYPE TABLE OF lty_data.

    DATA(yearfrom) = CONV gjahr( ir_year[ 1 ]-low ).
    DATA(yearto)   = CONV gjahr( ir_year[ 1 ]-high ).

    DATA(weekfrom) = CONV i( ir_week[ 1 ]-low ).
    DATA(weekto)   = CONV i( ir_week[ 1 ]-high ).

    IF yearto IS INITIAL.
      yearto = yearfrom.
    ENDIF.

    IF weekto IS INITIAL.
      weekto = weekfrom.
    ENDIF.

    DATA: lr_lweek TYPE tt_ranges.

    DATA: s_weekfrom TYPE zde_char2,
          s_weekto   TYPE zde_char2.

    IF weekfrom < 10.
      s_weekfrom = `0` && weekfrom.
    ELSE.
      s_weekfrom = weekfrom.
    ENDIF.

    IF weekto < 10.
      s_weekto = `0` && weekto.
    ELSE.
      s_weekto = weekto.
    ENDIF.

    APPEND VALUE #( sign = 'I' option = 'BT' low = yearfrom && s_weekfrom high = yearto && s_weekto ) TO lr_lweek.

    "Lấy master năng lực gia công
    SELECT *
      FROM zui_kbnlngc
      WHERE workcenter    IN @ir_workcenter
        AND hierarchynode IN @ir_hierarchynode
        AND plant         IN @ir_plant
      INTO TABLE @DATA(lt_kbnlngc).

    "Lấy khai báo số ngày làm việc theo tuần/năm
    SELECT *
      FROM zui_kbsnlv
      WHERE workcenter    IN @ir_workcenter
        AND plant         IN @ir_plant
*        AND week          IN @ir_week
*        AND Zyear    IN @ir_year
      AND lweek IN @lr_lweek
      INTO TABLE @DATA(lt_kbsnlv).

    DATA ls_kbsn_lamviec TYPE lty_data.

    "Base index: W1 ứng với (iv_year_from, iv_week_from)
    DATA lv_base_idx TYPE i.
    lv_base_idx = iv_year_from * 54 + iv_week_from.

    LOOP AT lt_kbnlngc INTO DATA(ls_kbnlngc).

      LOOP AT lt_kbsnlv INTO DATA(ls_kbsnlv)
           WHERE workcenter = ls_kbnlngc-workcenter
             AND plant      = ls_kbnlngc-plant.

        "===== Chuẩn bị khoảng năm để load capacities một lần =====
        DATA(lv_year) = ls_kbsnlv-zyear.
        DATA lv_year_from TYPE d.
        DATA lv_year_to   TYPE d.
        lv_year_from = |{ lv_year }0101|.
        lv_year_to   = |{ lv_year }1231|.

        "Load tất cả dòng năng lực của nhà gia công cho năm đó
        DATA(lt_cap) = zcl_kbsn_ns_tuan=>load_capacities(
          iv_wc    = ls_kbnlngc-workcenter
          iv_node  = ls_kbnlngc-hierarchynode
          iv_plant = ls_kbnlngc-plant
          iv_yfrom = lv_year_from
          iv_yto   = lv_year_to ).

        "===== Tính index W? tương ứng với tuần hiện tại =====
        DATA: lv_week_num  TYPE i,
              lv_abs_index TYPE i,
              lv_w_col     TYPE i.

        lv_week_num  = CONV i( ls_kbsnlv-week ).
        lv_abs_index = lv_year * 54 + lv_week_num.
        lv_w_col     = lv_abs_index - lv_base_idx + 1. "W1 = week_from

        "Ngoài khoảng 1..54 thì bỏ qua
        IF lv_w_col < 1 OR lv_w_col > 54.
          CONTINUE.
        ENDIF.

        "===== Lấy workingdays và ghi vào W?workingdays =====
        TYPES ty_p_wd TYPE p LENGTH 5 DECIMALS 0.   "tối đa 99999 ngày
        DATA lv_wd TYPE ty_p_wd.
        lv_wd = ls_kbsnlv-workingdays.

        ASSIGN COMPONENT |W{ lv_w_col }workingdays|
               OF STRUCTURE ls_kbsn_lamviec
               TO FIELD-SYMBOL(<wd>).
        IF sy-subrc <> 0 OR <wd> IS NOT ASSIGNED.
          CONTINUE.
        ENDIF.
        <wd> = lv_wd.

        "===== Tính khoảng ngày của tuần hiện tại =====
        DATA lv_dfrom TYPE d.
        DATA lv_dto   TYPE d.
        get_week_range(
          EXPORTING
            iv_year      = lv_year
            iv_week      = lv_week_num
          IMPORTING
            ev_date_from = lv_dfrom
            ev_date_to   = lv_dto ).

        "===== Tìm daily productivity có hiệu lực trong tuần =====
        DATA(lv_daily) = find_daily_for_week(
          it_cap       = lt_cap
          iv_week_from = lv_dfrom
          iv_week_to   = lv_dto ).

        "===== Kết quả: ns = ngày làm việc * daily =====
        DATA lv_result TYPE p DECIMALS 0.
        lv_result = lv_wd * lv_daily.

        "Ghi vào W?dailyproductivity
        ASSIGN COMPONENT |W{ lv_w_col }dailyproductivity|
               OF STRUCTURE ls_kbsn_lamviec
               TO FIELD-SYMBOL(<wres>).
        IF sy-subrc = 0 AND <wres> IS ASSIGNED.
          <wres> = lv_result.
        ENDIF.

      ENDLOOP.

      IF ls_kbsn_lamviec IS NOT INITIAL.
        ls_kbsn_lamviec-workcenter    = ls_kbnlngc-workcenter.
        ls_kbsn_lamviec-plant         = ls_kbnlngc-plant.
        ls_kbsn_lamviec-hierarchynode = ls_kbnlngc-hierarchynode.
        COLLECT ls_kbsn_lamviec INTO lt_data.
      ENDIF.

      CLEAR ls_kbsn_lamviec.
    ENDLOOP.

    MOVE-CORRESPONDING lt_data TO et_data.

  ENDMETHOD.


  METHOD get_week_range.
    "*======================================================================
    "* Helper: Tính khoảng ngày của 1 tuần
    "*======================================================================

    "*Giản lược: W1 = 01.01..07.01, W2 = 08.01..14.01, ...
    DATA lv_start TYPE d.
    lv_start = |{ iv_year }0101|.

    DATA lv_off TYPE i.
    lv_off = ( iv_week - 1 ) * 7.

    ev_date_from = lv_start + lv_off.
    ev_date_to   = ev_date_from + 6.
  ENDMETHOD.


  METHOD load_capacities.
    "*======================================================================
    "* Helper: Load năng lực gia công theo năm & key
    "*======================================================================

    SELECT *
      FROM zui_kbnlngc
      WHERE workcenter    = @iv_wc
        AND hierarchynode = @iv_node
        AND plant         = @iv_plant
        AND todate       >= @iv_yfrom
        AND fromdate     <= @iv_yto
      INTO TABLE @rt_cap.

    IF rt_cap IS NOT INITIAL.
      SORT rt_cap BY fromdate ASCENDING todate ASCENDING.
    ENDIF.
  ENDMETHOD.


  METHOD find_daily_for_week.
    "*======================================================================
    "* Helper: Tìm dailyproductivity cho tuần [iv_week_from..iv_week_to]
    "*======================================================================

    rv_day = 0.

    IF it_cap IS INITIAL.
      RETURN.
    ENDIF.

    "1) Ưu tiên record bao phủ nguyên đầu tuần (from <= start <= to)
    LOOP AT it_cap ASSIGNING FIELD-SYMBOL(<c>).
      IF <c>-fromdate <= iv_week_from AND <c>-todate >= iv_week_from.
        rv_day = <c>-dailyproductivity.
        RETURN.
      ENDIF.
    ENDLOOP.

    "2) Nếu không có, lấy record nào giao với [start..end]
    LOOP AT it_cap ASSIGNING <c>.
      IF <c>-fromdate <= iv_week_to AND <c>-todate >= iv_week_from.
        rv_day = <c>-dailyproductivity.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    "*======================================================================
    "* Query Provider: SELECT
    "*======================================================================

    TRY.
        DATA(lo_paging)        = io_request->get_paging( ).
        DATA(lt_sort_elements) = io_request->get_sort_elements( ).

        get_provided_ranges(
          EXPORTING
            io_request       = io_request
          IMPORTING
            er_workcenter    = DATA(ir_workcenter)
            er_plant         = DATA(ir_plant)
            er_hierarchynode = DATA(ir_hierarchynode)
            er_week          = DATA(ir_week)
            er_year          = DATA(ir_year)
        ).

        DATA: lv_check   TYPE abap_boolean VALUE abap_false,
              lt_returns TYPE tt_returns.

        "=== Check week_from -> week_to <= 54 tuần =====================
        DATA: lv_idx_from TYPE i,
              lv_idx_to   TYPE i,
              lv_span     TYPE i.

        DATA(year_from) = CONV gjahr( ir_year[ 1 ]-low ).
        DATA(year_to)   = CONV gjahr( ir_year[ 1 ]-high ).

        DATA(week_from) = CONV i( ir_week[ 1 ]-low ).
        DATA(week_to)   = CONV i( ir_week[ 1 ]-high ).

        IF year_to IS INITIAL.
          year_to = year_from.
        ENDIF.

        IF week_to IS INITIAL.
          week_to = week_from.
        ENDIF.

        "Convert (year, week) -> chỉ số tuần tuyệt đối
        lv_idx_from = year_from * 52 + week_from.
        lv_idx_to   = year_to   * 52 + week_to.

        "from > to -> error
        IF lv_idx_to < lv_idx_from.
          APPEND VALUE #( msgno = '001' ) TO lt_returns.
          lv_check = abap_true.
        ENDIF.

        "Số tuần trong khoảng (cả 2 đầu)
        lv_span = lv_idx_to - lv_idx_from + 1.

        "Không quá 54 tuần
        IF lv_span > 54.
          APPEND VALUE #( msgno = '002' ) TO lt_returns.
          lv_check = abap_true.
        ENDIF.

        IF lv_check = abap_true.
          "Không cần xử lý tiếp → raise exception từ lt_returns (nếu muốn)
          READ TABLE lt_returns INDEX 1 INTO DATA(ls_return).
          IF sy-subrc = 0.
            RAISE EXCEPTION TYPE zcl_kbsn_ns_tuan
              EXPORTING
                textid = VALUE scx_t100key(
                           msgid = 'ZMMKHNHGC'
                           msgno = ls_return-msgno
                           attr1 = CONV string( ls_return-msgv1 ) ).
          ENDIF.
          RETURN.
        ENDIF.

        "=== Lấy dữ liệu chính ========================================
        get_ns_tuan(
          EXPORTING
            ir_workcenter    = ir_workcenter
            ir_plant         = ir_plant
            ir_hierarchynode = ir_hierarchynode
            ir_week          = ir_week
            ir_year          = ir_year
            iv_week_from     = week_from
            iv_year_from     = year_from
          IMPORTING
            et_data          = gt_kbsn_lamviec
            et_returns       = lt_returns
        ).

        IF lt_returns IS NOT INITIAL.
          READ TABLE lt_returns INDEX 1 INTO DATA(ls_return2).
          RAISE EXCEPTION TYPE zcl_kbsn_ns_tuan
            EXPORTING
              textid = VALUE scx_t100key(
                         msgid = 'ZMMKHNHGC'
                         msgno = ls_return2-msgno
                         attr1 = CONV string( ls_return2-msgv1 ) ).
        ENDIF.

        "=== Paging ====================================================
        DATA lt_temp TYPE gty_kbsn_lamviec.

        DATA(page_size) = lo_paging->get_page_size( ).
        DATA(offset)    = lo_paging->get_offset( ).

        DATA(max_rows) = COND #( WHEN page_size = if_rap_query_paging=>page_size_unlimited
                                 THEN 0
                                 ELSE page_size ).

        max_rows = page_size + offset.

        LOOP AT gt_kbsn_lamviec INTO DATA(ls_kbsn_lamviec).
          IF sy-tabix > offset.
            IF max_rows > 0 AND sy-tabix > max_rows.
              EXIT.
            ELSE.
              APPEND ls_kbsn_lamviec TO lt_temp.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( gt_kbsn_lamviec ) ).
        ENDIF.

        IF io_request->is_data_requested( ).
          io_response->set_data( lt_temp ).
        ENDIF.

      CATCH cx_root INTO DATA(exception).

        IF cl_message_helper=>get_latest_t100_exception( exception ) IS BOUND.
          RAISE EXCEPTION exception.
        ELSE.
          RAISE EXCEPTION TYPE zcl_kbsn_ns_tuan
            EXPORTING
              textid = VALUE scx_t100key(
                         msgid = 'ZMMKHNHGC'
                         msgno = '999'
                         attr1 = exception->get_text( ) ).
        ENDIF.

    ENDTRY.

  ENDMETHOD.


  METHOD get_provided_ranges.
    "*======================================================================
    "* Helper: đọc filter ranges từ request
    "*======================================================================
    TRY.
        DATA(lt_ranges) = io_request->get_filter( )->get_as_ranges( ).

        LOOP AT lt_ranges REFERENCE INTO DATA(lr_range).

          CASE lr_range->name.

            WHEN 'WORKCENTER'.
              LOOP AT lr_range->range REFERENCE INTO DATA(lr_range_entry).
                INSERT VALUE #(
                  sign   = lr_range_entry->sign
                  option = lr_range_entry->option
                  low    = CONV #( lr_range_entry->low )
                  high   = CONV #( lr_range_entry->high ) )
                  INTO TABLE er_workcenter.
              ENDLOOP.

            WHEN 'PLANT'.
              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.
                INSERT VALUE #(
                  sign   = lr_range_entry->sign
                  option = lr_range_entry->option
                  low    = CONV #( lr_range_entry->low )
                  high   = CONV #( lr_range_entry->high ) )
                  INTO TABLE er_plant.
              ENDLOOP.

            WHEN 'HIERARCHYNODE'.
              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.
                INSERT VALUE #(
                  sign   = lr_range_entry->sign
                  option = lr_range_entry->option
                  low    = CONV #( lr_range_entry->low )
                  high   = CONV #( lr_range_entry->high ) )
                  INTO TABLE er_hierarchynode.
              ENDLOOP.

            WHEN 'WEEK'.
              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.
                INSERT VALUE #(
                  sign   = lr_range_entry->sign
                  option = lr_range_entry->option
                  low    = CONV #( lr_range_entry->low )
                  high   = CONV #( lr_range_entry->high ) )
                  INTO TABLE er_week.
              ENDLOOP.

            WHEN 'ZYEAR'.
              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.
                INSERT VALUE #(
                  sign   = lr_range_entry->sign
                  option = lr_range_entry->option
                  low    = CONV #( lr_range_entry->low )
                  high   = CONV #( lr_range_entry->high ) )
                  INTO TABLE er_year.
              ENDLOOP.

            WHEN OTHERS.
              "ignore

          ENDCASE.

        ENDLOOP.

      CATCH cx_rap_query_filter_no_range INTO DATA(lx_previous).
        "tuỳ bạn xử lý thêm
    ENDTRY.
  ENDMETHOD.

ENDCLASS.


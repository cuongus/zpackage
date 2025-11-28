CLASS zcl_get_khnhtw DEFINITION
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

           tt_ranges         TYPE STANDARD TABLE OF ty_ranges       WITH EMPTY KEY,
           tt_returns        TYPE STANDARD TABLE OF ty_returns      WITH EMPTY KEY,

           gty_khnhtw_header TYPE STANDARD TABLE OF zcs_knhntw_header WITH EMPTY KEY,
           gty_pb_khnhtw     TYPE STANDARD TABLE OF zcs_knhntw_item WITH EMPTY KEY.

    CLASS-DATA: gt_header TYPE gty_khnhtw_header,
                gt_item   TYPE gty_pb_khnhtw.

    CLASS-METHODS: get_pb_khnhtw IMPORTING ir_companycode       TYPE tt_ranges OPTIONAL
                                           ir_version           TYPE tt_ranges OPTIONAL
                                           ir_producthierarchy3 TYPE tt_ranges OPTIONAL
                                           ir_plant             TYPE tt_ranges OPTIONAL
                                           ir_weekfrom          TYPE tt_ranges OPTIONAL
                                           ir_weekto            TYPE tt_ranges OPTIONAL
                                 EXPORTING et_header            TYPE gty_khnhtw_header
                                           et_item              TYPE gty_pb_khnhtw
                                           et_returns           TYPE tt_returns.

    "Custom Entity / Query Provider
    INTERFACES    if_rap_query_provider.

    "Get Filter Ranges
    METHODS get_provided_ranges
      IMPORTING
        io_request           TYPE REF TO if_rap_query_request
      EXPORTING
        er_companycode       TYPE tt_ranges
        er_version           TYPE tt_ranges
        er_producthierarchy3 TYPE tt_ranges
        er_plant             TYPE tt_ranges
        er_weekfrom          TYPE tt_ranges
        er_weekto            TYPE tt_ranges
      RAISING
        cx_rap_query_prov_not_impl
        cx_rap_query_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_get_khnhtw IMPLEMENTATION.

  METHOD get_provided_ranges.
    "*======================================================================
    "* Helper: đọc filter ranges từ request
    "*======================================================================
    TRY.
        DATA(lt_ranges) = io_request->get_filter( )->get_as_ranges( ).

        LOOP AT lt_ranges REFERENCE INTO DATA(lr_range).

          CASE lr_range->name.

            WHEN 'COMPANYCODE'.
              LOOP AT lr_range->range REFERENCE INTO DATA(lr_range_entry).
                INSERT VALUE #(
                  sign   = lr_range_entry->sign
                  option = lr_range_entry->option
                  low    = CONV #( lr_range_entry->low )
                  high   = CONV #( lr_range_entry->high ) )
                  INTO TABLE er_companycode.
              ENDLOOP.

            WHEN 'PRODUCTHIERARCHY3'.
              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.
                INSERT VALUE #(
                  sign   = lr_range_entry->sign
                  option = lr_range_entry->option
                  low    = CONV #( lr_range_entry->low )
                  high   = CONV #( lr_range_entry->high ) )
                  INTO TABLE er_producthierarchy3.
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

            WHEN 'WEEKFROM'.
              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.
                INSERT VALUE #(
                  sign   = lr_range_entry->sign
                  option = lr_range_entry->option
                  low    = CONV #( lr_range_entry->low )
                  high   = CONV #( lr_range_entry->high ) )
                  INTO TABLE er_weekfrom.
              ENDLOOP.

            WHEN 'WEEKTO'.
              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.
                INSERT VALUE #(
                  sign   = lr_range_entry->sign
                  option = lr_range_entry->option
                  low    = CONV #( lr_range_entry->low )
                  high   = CONV #( lr_range_entry->high ) )
                  INTO TABLE er_weekto.
              ENDLOOP.

            WHEN OTHERS.
              "ignore

          ENDCASE.

        ENDLOOP.

      CATCH cx_rap_query_filter_no_range INTO DATA(lx_previous).
        "tuỳ bạn xử lý thêm
    ENDTRY.
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
            io_request           = io_request
          IMPORTING
            er_companycode       = DATA(ir_companycode)
            er_version           = DATA(ir_version)
            er_producthierarchy3 = DATA(ir_producthierarchy3)
            er_plant             = DATA(ir_plant)
            er_weekfrom          = DATA(ir_weekfrom)
            er_weekto            = DATA(ir_weekto)
        ).

        DATA: lv_check   TYPE abap_boolean VALUE abap_false,
              lt_returns TYPE tt_returns.

        "=== Check week_from -> week_to <= 54 tuần =====================
        DATA: lv_idx_from TYPE i,
              lv_idx_to   TYPE i,
              lv_span     TYPE i.

        DATA(yearfrom) = CONV gjahr( ir_weekfrom[ 1 ]-low+3(4) ).
        DATA(yearto)   = CONV gjahr( ir_weekto[ 1 ]-low+3(4) ).

        DATA(weekfrom) = CONV i( ir_weekfrom[ 1 ]-low+0(2) ).
        DATA(weekto)   = CONV i( ir_weekto[ 1 ]-low+0(2) ).

        IF yearto IS INITIAL.
          yearto = yearfrom.
        ENDIF.

        IF weekto IS INITIAL.
          weekto = weekfrom.
        ENDIF.

        "Convert (year, week) -> chỉ số tuần tuyệt đối
        lv_idx_from = yearfrom * 52 + weekfrom.
        lv_idx_to   = yearto   * 52 + weekto.

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
            RAISE EXCEPTION TYPE zcl_get_khnhtw
              EXPORTING
                textid = VALUE scx_t100key(
                           msgid = 'ZMMKHNHGC'
                           msgno = ls_return-msgno
                           attr1 = CONV string( ls_return-msgv1 ) ).
          ENDIF.
          RETURN.
        ENDIF.

        "=== Lấy dữ liệu chính ========================================
        get_pb_khnhtw(
          EXPORTING
            ir_companycode       = ir_companycode
            ir_version           = ir_version
            ir_producthierarchy3 = ir_producthierarchy3
            ir_plant             = ir_plant
            ir_weekfrom          = ir_weekfrom
            ir_weekto            = ir_weekto
          IMPORTING
            et_header            = gt_header
            et_item              = gt_item
            et_returns           = lt_returns
        ).

        IF lt_returns IS NOT INITIAL.
          READ TABLE lt_returns INDEX 1 INTO DATA(ls_return2).
          RAISE EXCEPTION TYPE zcl_get_khnhtw
            EXPORTING
              textid = VALUE scx_t100key(
                         msgid = 'ZMMKHNHGC'
                         msgno = ls_return2-msgno
                         attr1 = CONV string( ls_return2-msgv1 ) ).
        ENDIF.

        "=== Paging ====================================================
        DATA lt_temp TYPE gty_pb_khnhtw.

        DATA(page_size) = lo_paging->get_page_size( ).
        DATA(offset)    = lo_paging->get_offset( ).

        DATA(max_rows) = COND #( WHEN page_size = if_rap_query_paging=>page_size_unlimited
                                 THEN 0
                                 ELSE page_size ).

        max_rows = page_size + offset.

        DATA: lt_htemp TYPE gty_khnhtw_header,
              lt_itemp TYPE gty_pb_khnhtw.

        DATA(entity_id) = io_request->get_entity_id( ).

        CASE entity_id.

          WHEN 'ZCS_KHNHTW_HEADER'.

            LOOP AT gt_header INTO DATA(ls_header).
              IF sy-tabix > offset.
                IF max_rows > 0 AND sy-tabix > max_rows.
                  EXIT.
                ELSE.
                  APPEND ls_header TO lt_htemp.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF io_request->is_total_numb_of_rec_requested( ).
              io_response->set_total_number_of_records( lines( gt_header ) ).
            ENDIF.

            IF io_request->is_data_requested( ).
              io_response->set_data( lt_htemp ).
            ENDIF.

          WHEN 'ZCS_KHNHTW_ITEM'.

            LOOP AT gt_item INTO DATA(ls_item).
              IF sy-tabix > offset.
                IF max_rows > 0 AND sy-tabix > max_rows.
                  EXIT.
                ELSE.
                  APPEND ls_item TO lt_itemp.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF io_request->is_total_numb_of_rec_requested( ).
              io_response->set_total_number_of_records( lines( gt_item ) ).
            ENDIF.

            IF io_request->is_data_requested( ).
              io_response->set_data( lt_itemp ).
            ENDIF.

          WHEN OTHERS.

        ENDCASE.

      CATCH cx_root INTO DATA(exception).

        IF cl_message_helper=>get_latest_t100_exception( exception ) IS BOUND.
          RAISE EXCEPTION exception.
        ELSE.
          RAISE EXCEPTION TYPE zcl_get_khnhtw
            EXPORTING
              textid = VALUE scx_t100key(
                         msgid = 'ZMMKHNHGC'
                         msgno = '999'
                         attr1 = exception->get_text( ) ).
        ENDIF.

    ENDTRY.

  ENDMETHOD.

  METHOD get_pb_khnhtw.

    TYPES: BEGIN OF lty_nstuan,
             hierarchynode        TYPE zde_char50,
             plant                TYPE werks_d,
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
           END OF lty_nstuan.
    DATA: lt_nstuan_tp TYPE STANDARD TABLE OF lty_nstuan.

    DATA(yearfrom) = CONV gjahr( ir_weekfrom[ 1 ]-low+3(4) ).
    DATA(yearto)   = CONV gjahr( ir_weekto[ 1 ]-low+3(4) ).

    DATA(weekfrom) = CONV i( ir_weekfrom[ 1 ]-low+0(2) ).
    DATA(weekto)   = CONV i( ir_weekto[ 1 ]-high+0(2) ).

    IF yearto IS INITIAL.
      yearto = yearfrom.
    ENDIF.

    IF weekto IS INITIAL.
      weekto = weekfrom.
    ENDIF.

    DATA: lr_week  TYPE tt_ranges,
          lr_year  TYPE tt_ranges,
          lr_lweek TYPE tt_ranges.

    APPEND VALUE #( sign = 'I' option = 'BT' low = weekfrom high = weekto ) TO lr_week.
    APPEND VALUE #( sign = 'I' option = 'BT' low = yearfrom high = yearto ) TO lr_year.

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

    SELECT * FROM zr_ui_pbkhnh
    WHERE companycode IN @ir_companycode
      AND version IN @ir_version
      AND producthierarchy3 IN @ir_producthierarchy3
      AND plant IN @ir_plant

    INTO TABLE @DATA(lt_pbkhnh_tw).

    zcl_kbsn_ns_tuan=>get_ns_tuan(
      EXPORTING
*        ir_workcenter   type zcl_kbsn_ns_tuan=>tt_ranges optional
        ir_hierarchynode = ir_producthierarchy3
        ir_plant         = ir_plant
        ir_week          = lr_week
        ir_year          = lr_year
        iv_week_from     = weekfrom
        iv_year_from     = yearfrom
      IMPORTING
        et_data          = DATA(lt_nstuan)
        et_returns       = DATA(lt_returns)
    ).

    DATA: lt_item   TYPE STANDARD TABLE OF zcs_knhntw_item,
          ls_item   LIKE LINE OF gt_item,

          lt_header TYPE STANDARD TABLE OF zcs_knhntw_header,
          ls_header LIKE LINE OF gt_header.

    DATA: ls_nstuan_tp TYPE lty_nstuan.

    LOOP AT lt_nstuan INTO DATA(ls_nstuan).
      MOVE-CORRESPONDING ls_nstuan TO ls_nstuan_tp.

      COLLECT ls_nstuan_tp INTO lt_nstuan_tp.
    ENDLOOP.

    SORT lt_nstuan_tp BY hierarchynode plant ASCENDING.

    "Base index: W1 ứng với (iv_year_from, iv_week_from)
    DATA lv_base_idx TYPE i.
    lv_base_idx = yearfrom * 54 + weekfrom.

    LOOP AT lt_pbkhnh_tw INTO DATA(ls_pbkhnh_tw).

      "===== Tính index W? tương ứng với tuần hiện tại =====
      DATA: lv_week_num  TYPE i,
            lv_abs_index TYPE i,
            lv_w_col     TYPE i.

      lv_week_num  = CONV i( ls_pbkhnh_tw-week ).
      lv_abs_index = ls_pbkhnh_tw-zyear * 54 + lv_week_num.
      lv_w_col     = lv_abs_index - lv_base_idx + 1. "W1 = week_from

      ASSIGN COMPONENT |W{ lv_w_col }RECEIVINGPLANT| OF STRUCTURE ls_item
      TO FIELD-SYMBOL(<lv_value>).
      IF <lv_value> IS ASSIGNED.
        <lv_value> = ls_pbkhnh_tw-receivingplan.
      ENDIF.

      ls_item-companycode       = ls_pbkhnh_tw-companycode.
      ls_item-version           = ls_pbkhnh_tw-version.
      ls_item-versionname       = ls_pbkhnh_tw-versionname.
      ls_item-producthierarchy3 = ls_pbkhnh_tw-producthierarchy3.
      ls_item-plant             = ls_pbkhnh_tw-plant.

      COLLECT ls_item INTO lt_item.
      CLEAR: ls_item.
    ENDLOOP.

    DATA: lv_index TYPE i.

    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
      lv_index = 1.
      READ TABLE lt_nstuan_tp INTO ls_nstuan_tp WITH KEY hierarchynode = <fs_item>-producthierarchy3
                                                         plant         = <fs_item>-plant BINARY SEARCH.
      IF sy-subrc EQ 0.
        DO 54 TIMES.
          ASSIGN COMPONENT |W{ lv_index }receivingplan| OF STRUCTURE <fs_item>
          TO <lv_value>.

          ASSIGN COMPONENT |W{ lv_index }dailyproductivity| OF STRUCTURE <fs_item>
          TO FIELD-SYMBOL(<lv_value1>).

          ASSIGN COMPONENT |W{ lv_index }dailyproductivity| OF STRUCTURE ls_nstuan_tp
          TO FIELD-SYMBOL(<lv_value2>).

          ASSIGN COMPONENT |W{ lv_index }Variance| OF STRUCTURE <fs_item>
          TO FIELD-SYMBOL(<lv_value3>).

          IF <lv_value2> IS ASSIGNED.
            <lv_value1> = <lv_value2>.

            <lv_value3> = <lv_value1> - <lv_value>.
          ENDIF.

          UNASSIGN: <lv_value>, <lv_value1>, <lv_value2>, <lv_value3>.
        ENDDO.
      ENDIF.

      MOVE-CORRESPONDING ls_item TO ls_header.
      APPEND ls_header TO lt_header.
    ENDLOOP.

    MOVE-CORRESPONDING lt_item TO et_item.
    MOVE-CORRESPONDING lt_header TO et_header.

  ENDMETHOD.

ENDCLASS.

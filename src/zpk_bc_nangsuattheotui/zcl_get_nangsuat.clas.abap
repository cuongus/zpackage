CLASS zcl_get_nangsuat DEFINITION
  PUBLIC
  FINAL
    INHERITING FROM cx_rap_query_provider
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           BEGIN OF ty_range_month,
             month   TYPE monat,
             year    TYPE gjahr,
             start_w TYPE n LENGTH 2,
             end_w   TYPE n LENGTH 2,
             start_d TYPE d,
             end_d   TYPE d,
             maxweek TYPE n LENGTH 2,
           END OF ty_range_month,

           BEGIN OF ty_range_week,
             month    TYPE monat,
             year     TYPE gjahr,
             week     TYPE n LENGTH 2,
             weekyear TYPE gjahr,
             sdate    TYPE d,
             edate    TYPE d,
           END OF ty_range_week,

           tt_range_month TYPE TABLE OF ty_range_month,
           tt_range_week  TYPE TABLE OF ty_range_week,
           tt_range       TYPE TABLE OF ty_range_option,
           gt_data        TYPE TABLE OF zc_bc_nangsuat.

    CLASS-METHODS:
      get_first_monday_of_year
        IMPORTING iv_year    TYPE gjahr
        CHANGING  cv_date    TYPE d
                  cv_maxweek TYPE numc5,
      get_range_week IMPORTING monat    TYPE monat
                               gjahr    TYPE gjahr
                     CHANGING  tt_month TYPE tt_range_month
                               tt_week  TYPE tt_range_week.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_get_nangsuat IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    DATA: ls_page_info      TYPE zcl_fillter_nangsuat=>st_page_info.
    DATA: lt_data TYPE TABLE OF zc_bc_nangsuat,
          ls_data TYPE zc_bc_nangsuat,
          gt_Data TYPE TABLE OF zc_bc_nangsuat.
    DATA: ir_node  TYPE tt_range,
          ir_plant TYPE tt_range,
          o_monat  TYPE monat,
          o_year   TYPE gjahr.
    DATA: month_range TYPE tt_range_month,
          week_range  TYPE tt_range_week.
    TRY.

        zcl_fillter_nangsuat=>get_fillter_app(
          EXPORTING
            io_request   = io_request
            io_response  = io_response
          IMPORTING
            ir_node     = ir_node
            ir_plant     = ir_plant
            o_monat     = o_monat
            o_year      = o_year
            wa_page_info = ls_page_info
        ).

        zcl_get_nangsuat=>get_range_week(
          EXPORTING
            monat    = o_monat
            gjahr    = o_year
          CHANGING
            tt_month = month_range
            tt_week  = week_range
        ).

        DATA: next_year TYPE gjahr.
        next_year = o_year + 1.

        "Lấy master năng lực gia công
        SELECT *
          FROM zui_kbnlngc
          WHERE produnivhierarchynode IN @ir_node
            AND plant         IN @ir_plant
          INTO TABLE @DATA(lt_kbnlngc).
        SORT lt_kbnlngc BY produnivhierarchynode plant.

*        lấy workingday của 2 năm
        SELECT *
            FROM zui_kbsnlv
            WHERE plant IN @ir_plant
            AND ( zyear = @o_year OR zyear = @next_year )
            INTO TABLE @DATA(lt_wokingday).
        DATA: lw_stt TYPE n LENGTH 2.
        DATA(lt_list) = lt_kbnlngc[].
        DELETE ADJACENT DUPLICATES FROM lt_list COMPARING produnivhierarchynode plant.

        DATA: start_date   TYPE d,
              end_date     TYPE d,
              workingdays  TYPE n LENGTH 2,
              start_week   TYPE n LENGTH 2,
              end_week     TYPE n LENGTH 2,
              current_week TYPE n LENGTH 2,
              current_year TYPE gjahr.

        LOOP AT lt_list INTO DATA(ls_list).
          ls_data-produnivhierarchynode = ls_list-produnivhierarchynode.
          SELECT SINGLE HierarchyNodeDesc
           FROM zi_sanpham
           WITH PRIVILEGED ACCESS
           WHERE produnivhierarchynode = @ls_list-produnivhierarchynode
           INTO @DATA(lw_text).
          IF sy-subrc = 0.
            ls_data-PRODUNIVHIERARCHYNODE_txt = lw_text.
          ENDIF.
          ls_data-Plant = ls_list-plant.
          SELECT SINGLE PlantName
          FROM I_PlantStdVH
          WHERE Plant = @ls_list-plant
          INTO @DATA(lw_name).
          IF sy-subrc = 0.
            ls_data-plant_txt = lw_name.
          ENDIF.
          LOOP AT month_range INTO DATA(ls_month_range).
            lw_stt = lw_stt + 1.
            DATA(lw_fieldname) = |month_{ lw_stt }|.
            ASSIGN COMPONENT lw_fieldname OF STRUCTURE ls_data TO FIELD-SYMBOL(<fs_value>).
            IF <fs_value> IS ASSIGNED.
              LOOP AT week_range INTO DATA(ls_week_range) WHERE month = ls_month_range-month AND year = ls_month_range-year.

                LOOP AT lt_kbnlngc INTO DATA(ls_kbnlgc) WHERE plant = ls_list-plant AND produnivhierarchynode = ls_list-produnivhierarchynode
                                                          AND ( ( fromdate <= ls_week_range-sdate AND todate >= ls_week_range-edate )
                                                          OR ( fromdate <= ls_week_range-edate AND todate >= ls_week_range-edate AND fromdate >= ls_week_range-sdate )
                                                          OR ( fromdate <= ls_week_range-sdate AND todate >= ls_week_range-sdate AND todate <= ls_week_range-edate )
                                                          OR ( fromdate >= ls_week_range-sdate AND todate <= ls_week_range-edate ) )
                                                          .
                  READ TABLE lt_wokingday INTO DATA(ls_workingday) WITH KEY plant = ls_kbnlgc-plant
                                                                            workcenter = ls_kbnlgc-workcenter
                                                                            week = ls_week_range-week
                                                                            zyear = ls_week_range-year.
                  IF sy-subrc = 0.
*                  lấy ngày cuối cùng làm việc của tuần
                    ls_week_range-edate = ls_week_range-sdate + ls_workingday-workingdays - 1.

                    IF ls_kbnlgc-fromdate <= ls_week_range-sdate AND ls_kbnlgc-todate >= ls_week_range-edate.
                      workingdays = ls_workingday-workingdays.
                    ELSEIF ls_kbnlgc-fromdate <= ls_week_range-edate AND ls_kbnlgc-todate >= ls_week_range-edate AND ls_kbnlgc-fromdate >= ls_week_range-sdate.
                      workingdays = ls_kbnlgc-fromdate - ls_week_range-sdate + 1.
                    ELSEIF ls_kbnlgc-fromdate >= ls_week_range-sdate AND ls_kbnlgc-todate <= ls_week_range-edate.
                      workingdays = ls_kbnlgc-todate - ls_kbnlgc-fromdate + 1.
                    ELSEIF ls_kbnlgc-fromdate <= ls_week_range-sdate AND ls_kbnlgc-todate >= ls_week_range-sdate AND ls_kbnlgc-todate <= ls_week_range-edate.
                      workingdays = ls_week_range-edate - ls_kbnlgc-todate + 1.
                    ELSE.
                      workingdays = 0.
                    ENDIF.
                    <fs_value> = <fs_value> + workingdays * ls_kbnlgc-dailyproductivity.
                  ENDIF.
                ENDLOOP.

              ENDLOOP.
              UNASSIGN <fs_value>.
            ENDIF.
          ENDLOOP.
          CLEAR: lw_stt.
          APPEND ls_data TO gt_data.
          CLEAR: ls_data.
        ENDLOOP.

*          export data
        IF ls_page_info-page_size < 0.
          ls_page_info-page_size = 50.
        ENDIF.

        DATA(max_rows) = COND #( WHEN ls_page_info-page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                   ELSE ls_page_info-page_size ).

        max_rows = ls_page_info-page_size + ls_page_info-offset.

        LOOP AT gt_data INTO ls_data.
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

        RAISE EXCEPTION TYPE zcl_get_nangsuat
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
  METHOD get_range_week.
    DATA(lw_month) = monat.
    DATA(lw_year) = gjahr.
    DATA first_day_month TYPE d.
    DATA: first_day_of_motnh TYPE d,
          start_date         TYPE d.
    DATA: max_week TYPE numc5.
    DATA: ls_range_week TYPE LINE OF tt_range_week.

    first_day_month = |{ gjahr }{ monat }01|.

*    tim thu 2 đầu tiên của năm
    zcl_get_nangsuat=>get_first_monday_of_year(
          EXPORTING
            iv_year = gjahr
          CHANGING
            cv_date = start_date
            cv_maxweek = max_week
        ).

    IF start_date = |{ gjahr }0101|.
      DATA(start_week) = 1.
    ELSE.
      start_week = 2.
    ENDIF.


    WHILE start_date < first_day_month.
      start_date = start_date + 7.
      start_week = start_week + 1.
    ENDWHILE.

*    IF first_day_month < start_date.
*      start_date = start_date - 7.
*      start_week = start_week - 1.
*    ENDIF.

    DO 12 TIMES.
      APPEND INITIAL LINE TO tt_month ASSIGNING FIELD-SYMBOL(<fs_range>).
      <fs_range>-month = lw_month.
      <fs_range>-year = lw_year.
      <fs_range>-start_d = start_date.
      <fs_range>-start_w = start_week.
      <fs_range>-maxweek = max_week.

      ls_range_week-month = lw_month.
      ls_range_week-year = lw_year.

      lw_month = lw_month + 1.
      IF lw_month > 12.
        lw_month = 1.
        lw_year = lw_year + 1.
      ENDIF.

      first_day_month = |{ lw_year }{ lw_month }01|.
      WHILE start_date < first_day_month.
        ls_range_week-sdate = start_date.
        ls_range_week-edate = start_date + 6.
        ls_range_week-week = start_week.
        ls_range_week-weekyear = ls_range_week-year.
        IF start_week > max_week.
          ls_range_week-week = start_week - max_week.
          ls_range_week-weekyear = ls_range_week-year + 1.
        ENDIF.
        APPEND ls_range_week TO tt_week.

        start_date = start_date + 7.
        start_week = start_week + 1.
      ENDWHILE.

*      IF first_day_month < start_date.
*        start_date = start_date - 7.
*        start_week = start_week - 1.
*      ENDIF.

      IF start_week > max_week.
        start_week = start_week - max_week.
      ENDIF.

      <fs_range>-end_d = start_date - 1.
      <fs_range>-end_w = start_week - 1.
      IF <fs_range>-end_w = 0.
        <fs_range>-end_w = max_week.
      ENDIF.

    ENDDO.

  ENDMETHOD.
  METHOD get_first_monday_of_year.
    DATA: lv_date    TYPE d,
          lv_day     TYPE i,
          lv_month   TYPE i,
          lv_year    TYPE i,
          k          TYPE i,
          j          TYPE i,
          h          TYPE i,
          lv_weekday TYPE i.

    "Ngày đầu tiên của năm"
    lv_date = |{ iv_year }0101|.   "01/01/năm"

    "Tách ngày/tháng/năm"
    lv_day   = lv_date+6(2).
    lv_month = lv_date+4(2).
    lv_year  = lv_date(4).

    "Điều chỉnh cho Jan, Feb (theo Zeller)"
    IF lv_month = 1 OR lv_month = 2.
      lv_month = lv_month + 12.
      lv_year  = lv_year - 1.
    ENDIF.

    k = lv_year MOD 100.
    j = lv_year DIV 100.

    h = ( lv_day
        + ( ( 13 * ( lv_month + 1 ) ) DIV 5 )
        + k
        + ( k DIV 4 )
        + ( j DIV 4 )
        + ( 5 * j ) ) MOD 7.

    "Chuyển đổi: 0=Saturday, 1=Sunday, 2=Monday..."
    CASE h.
      WHEN 0.
        lv_weekday = 6. "Saturday
      WHEN 1.
        lv_weekday = 7. "Sunday
      WHEN 2.
        lv_weekday = 1. "Monday
      WHEN 3.
        lv_weekday = 2. "Tuesday
      WHEN 4.
        lv_weekday = 3. "Wednesday
      WHEN 5.
        lv_weekday = 4. "Thursday
      WHEN 6.
        lv_weekday = 5. "Friday
    ENDCASE.

    "Nếu đã là Thứ Hai thì giữ nguyên, ngược lại cộng thêm số ngày cần thiết"
    IF lv_weekday = 1.
      cv_date = lv_date.
    ELSE.
      cv_date = lv_date + ( 8 - lv_weekday ).
    ENDIF.

    DATA:
      lv_leap TYPE abap_bool.
    IF ( iv_year MOD 400 = 0 ) OR
   ( iv_year MOD 4 = 0 AND iv_year MOD 100 <> 0 ).
      lv_leap = abap_true.
    ELSE.
      lv_leap = abap_false.
    ENDIF.
*        Một năm có 53 tuần nếu:
*        Ngày 01/01 rơi vào thứ Năm, hoặc
*        Năm nhuận và 01/01 rơi vào thứ Tư.
    IF ( lv_leap = abap_true AND lv_weekday = 3 ) OR ( lv_leap = abap_false AND lv_weekday = 4 ).
      cv_maxweek = 53.
    ELSE.
      cv_maxweek = 52.
    ENDIF.



  ENDMETHOD.
ENDCLASS.

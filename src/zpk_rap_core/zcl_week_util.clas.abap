CLASS zcl_week_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    " Thứ 2 (first day) của tuần
    CLASS-METHODS get_monday_of_week
      IMPORTING
        iv_year        TYPE gjahr         " Năm, ví dụ '2025'
        iv_week        TYPE i             " Tuần: 1..53
      RETURNING
        VALUE(rv_date) TYPE d.     " Ngày (YYYYMMDD)

    " Chủ nhật (last day) của tuần
    CLASS-METHODS get_sunday_of_week
      IMPORTING
        iv_year        TYPE gjahr
        iv_week        TYPE i
      RETURNING
        VALUE(rv_date) TYPE d.

  PROTECTED SECTION.
  PRIVATE SECTION.

    " Tính Monday của Week 1 theo ISO
    CLASS-METHODS get_week_monday
      IMPORTING
        iv_year        TYPE gjahr
      RETURNING
        VALUE(rv_date) TYPE d.

    " Tính weekday theo công thức (1 = Mon ... 7 = Sun)
    CLASS-METHODS get_weekday
      IMPORTING
        iv_year_int       TYPE i
        iv_month          TYPE i
        iv_day            TYPE i
      RETURNING
        VALUE(rv_weekday) TYPE i.

ENDCLASS.



CLASS zcl_week_util IMPLEMENTATION.

  METHOD get_monday_of_week.

    DATA(lv_week1_monday) = get_week_monday( iv_year ).
    " Monday của week N = Monday week1 + (N-1)*7
    rv_date = lv_week1_monday + ( iv_week - 1 ) * 7.

  ENDMETHOD.

  METHOD get_sunday_of_week.

    " Sunday = Monday + 6
    rv_date = get_monday_of_week(
                iv_year = iv_year
                iv_week = iv_week ) + 6.

  ENDMETHOD.

  METHOD get_weekday.

    " Thuật toán Sakamoto: 0 = Sunday ... 6 = Saturday
    DATA(y) = iv_year_int.
    DATA(m) = iv_month.
    DATA(d) = iv_day.

    DATA lt_t TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    lt_t = VALUE #(
      ( 0 ) ( 3 ) ( 2 ) ( 5 ) ( 0 ) ( 3 )
      ( 5 ) ( 1 ) ( 4 ) ( 6 ) ( 2 ) ( 4 )
    ).

    IF m < 3.
      y = y - 1.
    ENDIF.

    DATA(idx) = m - 1.
    READ TABLE lt_t INDEX idx INTO DATA(tm).
    IF sy-subrc <> 0.
      tm = 0.
    ENDIF.

    DATA(res) = ( y + y / 4 - y / 100 + y / 400 + tm + d ) MOD 7.

    " Chuyển về 1..7 (Mon..Sun)
    IF res = 0.
      rv_weekday = 7.     " Sunday
    ELSE.
      rv_weekday = res.   " 1..6
    ENDIF.

  ENDMETHOD.

  METHOD get_week_monday.

    " Week được định nghĩa là tuần chứa ngày 4/1 (ISO 8601)
    DATA lv_year_int TYPE i.
    DATA lv_jan4     TYPE d.

    lv_year_int = CONV i( iv_year ).
    lv_jan4     = iv_year && '0104'.  " YYYY0104

    DATA(lv_weekday) = get_weekday(
      iv_year_int = lv_year_int
      iv_month    = 1
      iv_day      = 4 ).

    " Monday = Jan 4 - (weekday - 1)
    rv_date = lv_jan4 - ( lv_weekday - 1 ).

  ENDMETHOD.

ENDCLASS.

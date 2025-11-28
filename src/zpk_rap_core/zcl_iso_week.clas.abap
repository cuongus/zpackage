CLASS zcl_iso_week DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    CLASS-METHODS get_iso_week
      IMPORTING i_date     TYPE d
      EXPORTING e_week     TYPE zde_kweek
                e_weekyear TYPE i.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ISO_WEEK IMPLEMENTATION.


  METHOD get_iso_week.
    DATA: lv_week TYPE i.

    " 1) Thứ trong tuần của i_date (Mon=1..Sun=7), neo tại 19790101 (thứ Hai)
    DATA w TYPE i.
    w = ( ( i_date - '19790101' ) MOD 7 ) + 1.

    " 2) Chuyển sang THỨ NĂM của tuần hiện tại (quy tắc ISO)
    DATA d_thu TYPE d.
    d_thu = i_date + ( 4 - w ).

    " 3) Năm-tuần ISO là năm của ngày Thứ Năm nói trên
    e_weekyear = d_thu+0(4).

    " 4) Tìm THỨ HAI của tuần 1 (tuần chứa ngày 04/01 của e_weekyear)
    DATA first_thu     TYPE d.
    first_thu = |{ e_weekyear }0104|.

    DATA w_first_thu   TYPE i.
    w_first_thu = ( ( first_thu - '19790101' ) MOD 7 ) + 1.

    DATA week1_monday  TYPE d.
    week1_monday = first_thu - ( w_first_thu - 1 ).

    " 5) Số tuần ISO = số tuần tính từ week1_monday tới d_thu
    lv_week = ( ( d_thu - week1_monday ) DIV 7 ) + 1.

    IF lv_week < 10.
      e_week = e_weekyear && `0` && lv_week.
    ELSE.
      e_week = e_weekyear && lv_week.
    ENDIF.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
*    me->get_iso_week(
*      EXPORTING
*        i_date = '20250930'
*      IMPORTING
*        e_week = DATA(lv_week)
*    ).
  ENDMETHOD.
ENDCLASS.

CLASS lsc_zr_zweekyear01tp DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zr_zweekyear01tp IMPLEMENTATION.

  METHOD save_modified.
    DATA : lt_year TYPE STANDARD TABLE OF ztb_week_year,
           ls_year TYPE                   ztb_week_year.

    DATA : lt_week TYPE STANDARD TABLE OF ztb_week,
           lt_week_tmp TYPE STANDARD TABLE OF ztb_week,
           ls_week TYPE                   ztb_week.
    DATA: lw_field_name TYPE char72.

    TYPES: BEGIN OF ty_mapping,
             field_ent TYPE string,
             field_db  TYPE string,
           END OF ty_mapping.

    DATA: gt_mapping TYPE STANDARD TABLE OF ty_mapping WITH DEFAULT KEY.

    IF create-zweekyear IS NOT INITIAL.
      DATA: lv_date     TYPE d,
            lv_end_date TYPE d,
            lw_count TYPE int4.
      DATA: lw_zyear like ls_year-zyear.
      lt_year = CORRESPONDING #( create-zweekyear MAPPING FROM ENTITY ).
      LOOP AT lt_year ASSIGNING FIELD-SYMBOL(<lf_year>).
          lw_count = 0.
        <lf_year>-zdesc = `Năm ` && <lf_year>-zyear.

        lw_zyear = <lf_year>-zyear - 1.
        lv_date = lw_zyear && '1220'.
        lw_zyear = <lf_year>-zyear + 1.
        lv_end_date = lw_zyear && '0110'.
        WHILE lv_date <= lv_end_date.
          CALL METHOD zcl_iso_week=>get_iso_week
            EXPORTING
              i_date     = lv_date
            IMPORTING
              e_week     = DATA(lw_week)
              e_weekyear = DATA(lw_year).
          IF ls_week-zweek is not INITIAL and lw_week <> ls_week-zweek .
            ls_week-zdateto = lv_date - 1.
            ls_week-weekchar = ls_week-zweek+4(2) && '/' && ls_week-zyear.
            ls_week-weeknum = ls_week-zweek+4(2).
            ls_week-lastweek = ls_week-zweek - 1.
            ls_week-zdesc = `Tuần ` && ls_week-zweek+4(2) && ` Năm ` && ls_week-zyear.
            APPEND ls_week TO lt_week.
            CLEAR ls_week.
            lw_count = 1.
          ENDIF.

          IF ls_week-zdatefr IS INITIAL.
            ls_week-zdatefr = lv_date.
          ENDIF.
          ls_week-zyear = lw_year.
          ls_week-zweek = lw_week.
          lw_count = lw_count + 1.
          lv_date = lv_date + 1.
          if lw_count = 4.
            ls_week-zper = lv_date(6).
          endif.
        ENDWHILE.

        ls_week-zdateto = lv_date - 1.
        ls_week-weekchar = ls_week-zweek+4(2) && '/' && ls_week-zyear.
        ls_week-weeknum = ls_week-zweek+4(2).
        ls_week-lastweek = ls_week-zweek - 1.
        ls_week-zdesc = `Tuần ` && ls_week-zweek+4(2) && ` Năm ` && ls_week-zyear.
        APPEND ls_week TO lt_week.
        CLEAR ls_week.
        DELETE lt_week WHERE zyear <> <lf_year>-zyear.
        APPEND LINES OF lt_week TO lt_week_tmp.
        CLEAR lt_week.
      ENDLOOP.


      INSERT ztb_week_year FROM TABLE @lt_year.
      MODIFY ztb_week FROM TABLE @lt_week_tmp.
      DELETE lt_week_tmp WHERE lastweek+4(2) <> '00'.
      LOOP AT lt_week_tmp ASSIGNING FIELD-SYMBOL(<lf_week>).
        lw_zyear = <lf_week>-zyear - 1.
        SELECT MAX( zweek ) FROM ztb_week
          WHERE zyear = @lw_zyear
          INTO @<lf_week>-lastweek .
      ENDLOOP.
      MODIFY ztb_week FROM TABLE @lt_week_tmp.
    ENDIF.

    LOOP AT delete-zweekyear INTO DATA(ls_detele)." WHERE HdrID IS NOT INITIAL.
      DELETE FROM ztb_week_year WHERE zyear = @ls_detele-Zyear.
    ENDLOOP.

    IF create-zweek IS NOT INITIAL.
      lt_week = CORRESPONDING #( create-zweek MAPPING FROM ENTITY ).
      INSERT ztb_week FROM TABLE @lt_week.
    ENDIF.

    LOOP AT delete-zweek INTO DATA(ls_detele_dtl)." WHERE HdrID IS NOT INITIAL AND DtlID IS NOT INITIAL.
      DELETE FROM ztb_week WHERE zyear = @ls_detele_dtl-Zyear AND zweek = @ls_detele_dtl-Zweek.
    ENDLOOP.

*    IF update-zrtbyear IS NOT INITIAL OR update-zrtbperiod IS NOT INITIAL.
*
**      MODIFY ztb_year FROM @ls_year.
**      MODIFY ztb_period FROM TABLE @lt_period.
*
*    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zweekyear DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZWeekYear
        RESULT result,
      CreateYearFrToS FOR MODIFY
        IMPORTING keys FOR ACTION ZWeekYear~CreateYearFrToS.
ENDCLASS.

CLASS lhc_zweekyear IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD CreateYearFrToS.
    DATA n TYPE i.
    DATA: lt_year TYPE TABLE FOR CREATE ZR_ZWeekYear01TP,
          ls_year TYPE STRUCTURE FOR CREATE ZR_ZWeekYear01TP.

    READ TABLE keys INTO DATA(ls_key) INDEX 1.
    DATA(lw_fr) = ls_key-%param-yearfr.
    DATA(lw_to) = ls_key-%param-yearto.
    IF lw_to - lw_fr > 50.
      RETURN.
    ENDIF.
    WHILE lw_fr <= lw_to.
      n += 1.
      ls_year = VALUE #(  %cid                   = |My%CID_{ n }|
                                      Zyear  = lw_fr  ) .
      APPEND ls_year TO lt_year.
      lw_fr = lw_fr + 1.
    ENDWHILE.

    IF lt_year[] IS NOT INITIAL.
      MODIFY ENTITIES OF ZR_ZWeekYear01TP IN LOCAL MODE
        ENTITY ZWeekYear
          CREATE FIELDS ( Zyear )
          WITH lt_year.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

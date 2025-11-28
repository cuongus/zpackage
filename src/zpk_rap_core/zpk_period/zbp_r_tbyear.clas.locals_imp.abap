CLASS lsc_zr_tbyear DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zr_tbyear IMPLEMENTATION.

  METHOD save_modified.
    DATA : lt_year TYPE STANDARD TABLE OF ztb_year,
           ls_year TYPE                   ztb_year.

    DATA : lt_period TYPE STANDARD TABLE OF ztb_period,
           ls_period TYPE                   ztb_period.
    DATA: lw_field_name TYPE char72.
    DATA: lw_month LIKE ls_period-zmonth.
    DATA: lw_month1 LIKE ls_period-zmonth.

    TYPES: BEGIN OF ty_mapping,
             field_ent TYPE string,
             field_db  TYPE string,
           END OF ty_mapping.

    DATA: gt_mapping TYPE STANDARD TABLE OF ty_mapping WITH DEFAULT KEY.


    IF create-zrtbyear IS NOT INITIAL.
      lt_year = CORRESPONDING #( create-zrtbyear MAPPING FROM ENTITY ).
      LOOP AT lt_year ASSIGNING FIELD-SYMBOL(<lf_year>).
        <lf_year>-zdesc = 'Năm' && <lf_year>-zyear.
        lw_month = 0.
        DO 12 TIMES.
          lw_month = lw_month + 1.
          ls_period-zmonth = lw_month.
          ls_period-zyear = <lf_year>-zyear.
          ls_period-zper = ls_period-zyear && ls_period-zmonth.
          ls_period-zdatefr = ls_period-zyear && ls_period-zmonth && '01'.
          ls_period-zdesc = `Tháng ` && lw_month && ` năm ` && ls_period-zyear.

          IF lw_month = 1.
            ls_period-lastper = |{ ls_period-zyear - 1 } 12|.
          ELSE.
            lw_month1 = lw_month - 1 .
            ls_period-lastper = |{ ls_period-zyear } { lw_month1 }|.
          ENDIF.
          zcl_utility=>last_day_of_month( EXPORTING i_date = ls_period-zdatefr  IMPORTING e_date = ls_period-zdateto  ) .
          APPEND ls_period TO lt_period.
          CLEAR: ls_period.
        ENDDO.
      ENDLOOP.
      INSERT ztb_year FROM TABLE @lt_year.
      MODIFY ztb_period FROM TABLE @lt_period.
    ENDIF.

    LOOP AT delete-zrtbyear INTO DATA(ls_detele)." WHERE HdrID IS NOT INITIAL.
      DELETE FROM ztb_year WHERE zyear = @ls_detele-Zyear.
    ENDLOOP.

    IF create-zrtbperiod IS NOT INITIAL.
      lt_period = CORRESPONDING #( create-zrtbperiod MAPPING FROM ENTITY ).
      INSERT ztb_period FROM TABLE @lt_period.
    ENDIF.

    LOOP AT delete-zrtbperiod INTO DATA(ls_detele_dtl)." WHERE HdrID IS NOT INITIAL AND DtlID IS NOT INITIAL.
      DELETE FROM ztb_period WHERE zyear = @ls_detele_dtl-Zyear AND zper = @ls_detele_dtl-Zper.
    ENDLOOP.

    IF update-zrtbyear IS NOT INITIAL OR update-zrtbperiod IS NOT INITIAL.

*      MODIFY ztb_year FROM @ls_year.
*      MODIFY ztb_period FROM TABLE @lt_period.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_zr_tbyear DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrTbyear
        RESULT result
        ,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR ZrTbyear RESULT result,
      CreateYearFrTo FOR MODIFY
            IMPORTING keys FOR ACTION ZrTbyear~CreateYearFrTo ,
      get_global_features FOR GLOBAL FEATURES
            IMPORTING REQUEST requested_features FOR ZrTbyear RESULT result,
      CreateYearFrToS FOR MODIFY
            IMPORTING keys FOR ACTION ZrTbyear~CreateYearFrToS.
    .

ENDCLASS.

CLASS lhc_zr_tbyear IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD get_instance_features.
  ENDMETHOD.



  METHOD CreateYearFrTo.
  ENDMETHOD.

  METHOD get_global_features.
    result-%action-CreateYearFrTo = if_abap_behv=>fc-o-enabled.
  ENDMETHOD.

  METHOD CreateYearFrToS.
    DATA n TYPE i.
    DATA: lt_year TYPE TABLE FOR CREATE zr_tbyear,
          ls_year TYPE STRUCTURE FOR CREATE zr_tbyear.

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
      MODIFY ENTITIES OF zr_tbyear IN LOCAL MODE
        ENTITY ZrTbyear
          CREATE FIELDS ( Zyear )
          WITH lt_year.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

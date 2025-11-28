CLASS zcl_behavior_dntt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_data TYPE TABLE OF ztb_dntt.
    CLASS-DATA: gt_data        TYPE TABLE OF ztb_dntt,
                gt_data_source TYPE TABLE OF zc_dntt,
                gw_err         TYPE char1.

    CLASS-METHODS:
      get_data_save IMPORTING it_data TYPE tt_data EXPORTING flg_e TYPE char1,
      save_data_db.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BEHAVIOR_DNTT IMPLEMENTATION.


  METHOD get_data_save.
    gt_data[] = it_data[].
*    MODIFY ztb_dntt FROM TABLE @gt_data.
*    COMMIT WORK AND WAIT.
    IF sy-subrc = 0.
      CLEAR: flg_e.
    ELSE.
      flg_e = 'X'.
    ENDIF.
    gw_err = flg_e.

  ENDMETHOD.


  METHOD save_data_db.
*    IF gw_err <> 'X'.
      MODIFY ztb_dntt FROM TABLE @gt_data.
*      COMMIT WORK AND WAIT.
*    ENDIF.
  ENDMETHOD.
ENDCLASS.

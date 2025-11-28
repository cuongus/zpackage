CLASS zjp_showfield DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.

    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZJP_SHOWFIELD IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    CASE iv_entity.

      WHEN 'ZJP_C_SOQUYTIENMAT'.

      WHEN OTHERS.

    ENDCASE.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    SELECT * FROM zui_kb_thue0
    INTO TABLE @DATA(lt_data).

    DELETE zui_kb_thue0 FROM TABLE @lt_data.
  ENDMETHOD.
ENDCLASS.

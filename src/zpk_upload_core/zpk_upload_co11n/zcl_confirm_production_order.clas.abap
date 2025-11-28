CLASS zcl_confirm_production_order DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CONFIRM_PRODUCTION_ORDER IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    SELECT * FROM zdataco11n
*    into TABLE @DATA(lt_data).
*
*    DELETE zdataco11n FROM TABLE @lt_data.

  ENDMETHOD.
ENDCLASS.

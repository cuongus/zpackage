CLASS zcl_kb_tsx DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .

    CLASS-METHODS data_valid_check
      IMPORTING
        i_workcenter      TYPE i_workcenter-WorkCenter OPTIONAL
        i_plant           TYPE i_workcenter-Plant OPTIONAL
      RETURNING
        VALUE(rv_respond) TYPE abap_boolean.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_KB_TSX IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
  ENDMETHOD.


  METHOD data_valid_check.

    IF i_workcenter IS NOT INITIAL AND i_plant IS NOT INITIAL.
      SELECT workcenter, plant
        FROM i_workcenter
        WITH PRIVILEGED ACCESS
        WHERE WorkCenter = @i_workcenter
        AND  plant = @i_plant
        INTO TABLE @DATA(lt_i_workcenter).

    ELSEIF i_workcenter IS NOT INITIAL AND i_plant IS INITIAL.
      SELECT workcenter, plant
        FROM i_workcenter
        WITH PRIVILEGED ACCESS
        WHERE WorkCenter = @i_workcenter
        INTO TABLE @lt_i_workcenter.

    ELSEIF i_workcenter IS INITIAL AND i_plant IS NOT INITIAL.
      SELECT workcenter, plant
        FROM i_workcenter
        WITH PRIVILEGED ACCESS
        WHERE plant = @i_plant
        INTO TABLE @lt_i_workcenter.
    ENDIF.

    IF lt_i_workcenter IS NOT INITIAL.
      rv_respond = abap_true.
    ENDIF.

  ENDMETHOD.
ENDCLASS.

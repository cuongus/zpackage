CLASS zcl_http_err_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS to_text
      IMPORTING i_x           TYPE REF TO cx_root
      RETURNING VALUE(r_text) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_HTTP_ERR_HELPER IMPLEMENTATION.


  METHOD to_text.
    DATA lx TYPE REF TO cx_root.
    lx = i_x.
    WHILE lx IS BOUND.
      r_text = COND string(
                 WHEN r_text IS INITIAL THEN lx->get_text( )
                 ELSE |{ r_text } -> { lx->get_text( ) }| ).
      lx = lx->previous.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.

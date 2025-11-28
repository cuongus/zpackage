CLASS zcx_http_call_failed DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  INHERITING FROM cx_static_check.

  PUBLIC SECTION.
    INTERFACES if_t100_message.
    DATA mv1 TYPE string. "map vào &1

    CONSTANTS:
      BEGIN OF msg_required,
        msgid TYPE symsgid VALUE 'ZC_HTTP',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'MV1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF msg_required.

    METHODS constructor
      IMPORTING
        VALUE(mv1) TYPE string OPTIONAL. "business transaction

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZCX_HTTP_CALL_FAILED IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( ).
    if_t100_message~t100key = msg_required.
    me->if_t100_message~t100key-attr1 = 'MV1'.
    me->mv1 = mv1.

  ENDMETHOD.
ENDCLASS.

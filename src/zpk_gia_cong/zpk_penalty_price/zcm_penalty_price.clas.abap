CLASS zcm_penalty_price DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .

    CONSTANTS:
      BEGIN OF from_date_before_to_date,
        msgid TYPE symsgid VALUE 'Z_MES_PENALTY_PRICE',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF from_date_before_to_date .
    CONSTANTS:
      BEGIN OF date_null,
        msgid TYPE symsgid VALUE 'Z_MES_PENALTY_PRICE',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF date_null .
*    CONSTANTS:
*      BEGIN OF customer_unknown,
*        msgid TYPE symsgid VALUE 'Z_MSG_ERROR_RATE_RP',
*        msgno TYPE symsgno VALUE '003',
*        attr1 TYPE scx_attrname VALUE '',
*        attr2 TYPE scx_attrname VALUE '',
*        attr3 TYPE scx_attrname VALUE '',
*        attr4 TYPE scx_attrname VALUE '',
*      END OF customer_unknown .

    METHODS constructor
      IMPORTING
        !severity TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL
        !fromdate TYPE dats OPTIONAL
        !todate   TYPE dats OPTIONAL.

    DATA fromdate TYPE dats READ-ONLY.
    DATA todate TYPE dats READ-ONLY.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCM_PENALTY_PRICE IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
    previous = previous
    ).
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->if_abap_behv_message~m_severity = !severity.
    me->fromdate = !fromdate.
    me->todate = !todate.
  ENDMETHOD.
ENDCLASS.

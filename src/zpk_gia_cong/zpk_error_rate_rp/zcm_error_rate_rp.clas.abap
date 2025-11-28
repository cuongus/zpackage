CLASS zcm_error_rate_rp DEFINITION
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
        msgid TYPE symsgid VALUE 'Z_MSG_ERROR_RATE_RP',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'fromdate',
        attr2 TYPE scx_attrname VALUE 'todate',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF from_date_before_to_date .
    CONSTANTS:
      BEGIN OF date_null,
        msgid TYPE symsgid VALUE 'Z_MSG_ERROR_RATE_RP',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'fromdate',
        attr2 TYPE scx_attrname VALUE 'todate',
        attr3 TYPE scx_attrname VALUE 'curentdate',
        attr4 TYPE scx_attrname VALUE '',
      END OF date_null .
    CONSTANTS:
      BEGIN OF duplicate_deduction_percent,
        msgid TYPE symsgid VALUE 'Z_MSG_ERROR_RATE_RP',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'fromdate',
        attr2 TYPE scx_attrname VALUE 'todate',
        attr3 TYPE scx_attrname VALUE 'deductionpercent',
        attr4 TYPE scx_attrname VALUE '',
      END OF duplicate_deduction_percent .

    CONSTANTS:
      BEGIN OF duplicate_error_code,
        msgid TYPE symsgid VALUE 'Z_MSG_ERROR_RATE_RP',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'fromdate',
        attr2 TYPE scx_attrname VALUE 'todate',
        attr3 TYPE scx_attrname VALUE 'errorcode',
        attr4 TYPE scx_attrname VALUE 'errordescription',
      END OF duplicate_error_code .

    METHODS constructor
      IMPORTING
        !severity         TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        !textid           LIKE if_t100_message=>t100key OPTIONAL
        !previous         LIKE previous OPTIONAL
        !errorcode        TYPE c OPTIONAL
        !errordescription TYPE c OPTIONAL
        !deductionpercent TYPE zde_dec_5_2 OPTIONAL
        !fromdate         TYPE datum OPTIONAL
        !todate           TYPE datum OPTIONAL.

    DATA:
      errorcode        TYPE zde_char_5 READ-ONLY,
      errordescription TYPE zde_char_255 READ-ONLY,
      deductionpercent TYPE zde_dec_5_2 READ-ONLY,
      fromdate         TYPE datum READ-ONLY,
      todate           TYPE datum READ-ONLY,
      curentdate       TYPE datum READ-ONLY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCM_ERROR_RATE_RP IMPLEMENTATION.


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
    me->errorcode = !errorcode.
    me->errordescription = !errordescription.
    me->deductionpercent = !deductionpercent.
    me->fromdate = !fromdate.
    me->todate = !todate.
    me->curentdate = cl_abap_context_info=>get_system_date( ).
  ENDMETHOD.
ENDCLASS.

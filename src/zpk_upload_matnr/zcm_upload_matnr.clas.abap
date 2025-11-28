CLASS zcm_upload_matnr DEFINITION
  PUBLIC
      INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .


    CONSTANTS:
      BEGIN OF erro_mess,
        msgid TYPE symsgid VALUE 'Z_MES_UPLOAD_MATNR',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'erro',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF erro_mess .


    METHODS constructor
      IMPORTING
        !severity   TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        !textid     LIKE if_t100_message=>t100key OPTIONAL
        !previous   LIKE previous OPTIONAL


        !erro   TYPE string OPTIONAL.
*        !workcenter TYPE zde_char_8 OPTIONAL
*        !plant      TYPE zde_char_4 OPTIONAL
*        !machineid  TYPE zde_char_10 OPTIONAL
*        !teamid     TYPE zde_char_255 OPTIONAL
*        !fromdate   TYPE datum OPTIONAL
*        !todate     TYPE datum OPTIONAL.

    DATA:
      erro  TYPE string READ-ONLY.
*      workcenter TYPE c LENGTH 8 READ-ONLY,
*      plant      TYPE c LENGTH 4 READ-ONLY,
*      machineid  TYPE c LENGTH 10 READ-ONLY,
*      teamid     TYPE c LENGTH 255 READ-ONLY,
*      fromdate   TYPE datum READ-ONLY,
*      todate     TYPE datum READ-ONLY,
*      curentdate TYPE datum READ-ONLY.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCM_UPLOAD_MATNR IMPLEMENTATION.


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
    me->erro = !erro.
*    me->workcenter = !workcenter.
*    me->plant = !plant.
*    me->machineid = !machineid.
*    me->teamid = !teamid.
*    me->fromdate = !fromdate.
*    me->todate = !todate.
*    me->curentdate = cl_abap_context_info=>get_system_date( ).
  ENDMETHOD.
ENDCLASS.

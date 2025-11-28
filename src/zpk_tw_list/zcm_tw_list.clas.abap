CLASS zcm_tw_list DEFINITION
  PUBLIC
    INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .


    CONSTANTS:
      BEGIN OF from_date_before_to_date,
        msgid TYPE symsgid VALUE 'Z_MSG_TW_LIST',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'fromdate',
        attr2 TYPE scx_attrname VALUE 'todate',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF from_date_before_to_date .

    CONSTANTS:
      BEGIN OF date_invalid,
        msgid TYPE symsgid VALUE 'Z_MSG_TW_LIST',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'fromdate',
        attr2 TYPE scx_attrname VALUE 'todate',
        attr3 TYPE scx_attrname VALUE 'curentdate',
        attr4 TYPE scx_attrname VALUE '',
      END OF date_invalid .

    CONSTANTS:
      BEGIN OF existed_worker_id,
        msgid TYPE symsgid VALUE 'Z_MSG_TW_LIST',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'workerid',
        attr2 TYPE scx_attrname VALUE 'fromdate',
        attr3 TYPE scx_attrname VALUE 'todate',
        attr4 TYPE scx_attrname VALUE '',
      END OF existed_worker_id .

    CONSTANTS:
      BEGIN OF existed_machine_id,
        msgid TYPE symsgid VALUE 'Z_MSG_TW_LIST',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'machineid',
        attr2 TYPE scx_attrname VALUE 'fromdate',
        attr3 TYPE scx_attrname VALUE 'todate',
        attr4 TYPE scx_attrname VALUE '',
      END OF existed_machine_id .

    CONSTANTS:
      BEGIN OF existed_team_id,
        msgid TYPE symsgid VALUE 'Z_MSG_TW_LIST',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'teamid',
        attr2 TYPE scx_attrname VALUE 'fromdate',
        attr3 TYPE scx_attrname VALUE 'todate',
        attr4 TYPE scx_attrname VALUE '',
      END OF existed_team_id .

    CONSTANTS:
      BEGIN OF invalid_worcenter,
        msgid TYPE symsgid VALUE 'Z_MSG_TW_LIST',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE 'workcenter',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_worcenter .

    CONSTANTS:
      BEGIN OF invalid_plant,
        msgid TYPE symsgid VALUE 'Z_MSG_TW_LIST',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE 'plant',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_plant .

    CONSTANTS:
      BEGIN OF workcenter_plant_notmatch,
        msgid TYPE symsgid VALUE 'Z_MSG_TW_LIST',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE 'workcenter',
        attr2 TYPE scx_attrname VALUE 'plant',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF workcenter_plant_notmatch .

    METHODS constructor
      IMPORTING
        !severity   TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        !textid     LIKE if_t100_message=>t100key OPTIONAL
        !previous   LIKE previous OPTIONAL


        !workerid   TYPE zde_char_8 OPTIONAL
        !workcenter TYPE zde_char_8 OPTIONAL
        !plant      TYPE zde_char_4 OPTIONAL
        !machineid  TYPE zde_char_10 OPTIONAL
        !teamid     TYPE zde_char_255 OPTIONAL
        !fromdate   TYPE datum OPTIONAL
        !todate     TYPE datum OPTIONAL.

    DATA:
      workerid   TYPE c LENGTH 8 READ-ONLY,
      workcenter TYPE c LENGTH 8 READ-ONLY,
      plant      TYPE c LENGTH 4 READ-ONLY,
      machineid  TYPE c LENGTH 10 READ-ONLY,
      teamid     TYPE c LENGTH 255 READ-ONLY,
      fromdate   TYPE datum READ-ONLY,
      todate     TYPE datum READ-ONLY,
      curentdate TYPE datum READ-ONLY.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCM_TW_LIST IMPLEMENTATION.


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
    me->workerid = !workerid.
    me->workcenter = !workcenter.
    me->plant = !plant.
    me->machineid = !machineid.
    me->teamid = !teamid.
    me->fromdate = !fromdate.
    me->todate = !todate.
    me->curentdate = cl_abap_context_info=>get_system_date( ).
  ENDMETHOD.
ENDCLASS.

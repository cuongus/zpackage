CLASS zcl_validate_kb_tdnc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM cx_static_check.

  PUBLIC SECTION.

    DATA v1 TYPE string.

    INTERFACES if_t100_message.

    CONSTANTS:
      BEGIN OF msg_required,
        msgid TYPE symsgid VALUE 'ZKBTDNC_MSG',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'V1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF msg_required.

    METHODS constructor
      IMPORTING
        VALUE(v1) TYPE string OPTIONAL. "business transaction

    METHODS: validate_machineid IMPORTING i_order     TYPE i_productionorderoperation_2-productionorder
                                          i_operation TYPE i_productionorderoperation_2-productionorderoperation
                                          i_machineid TYPE string OPTIONAL
                                RAISING   zcl_validate_kb_tdnc,

      validate_teamid IMPORTING i_order     TYPE i_productionorderoperation_2-productionorder
                                i_operation TYPE i_productionorderoperation_2-productionorderoperation
                                i_teamid    TYPE string OPTIONAL
                      RAISING   zcl_validate_kb_tdnc,

      validate_workerid IMPORTING i_order     TYPE i_productionorderoperation_2-productionorder
                                  i_operation TYPE i_productionorderoperation_2-productionorderoperation
                                  i_workerid  TYPE string OPTIONAL
                        RAISING   zcl_validate_kb_tdnc,

      get_workcenter IMPORTING i_order              TYPE i_productionorderoperation_2-productionorder
                               i_operation          TYPE i_productionorderoperation_2-productionorderoperation
                     RETURNING VALUE(rv_workcenter) TYPE i_productionorderoperation_2-workcenterinternalid.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VALIDATE_KB_TDNC IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( ).
    if_t100_message~t100key = msg_required.
    me->if_t100_message~t100key-attr1 = 'V1'.
    me->v1 = v1.
  ENDMETHOD.


  METHOD validate_machineid.
    DATA(lv_workcenter) = me->get_workcenter( i_order = i_order i_operation = i_operation ).

    SELECT COUNT(*) FROM
    zi_kb_somay
    WHERE workcenter = @lv_workcenter
      AND machineid = @i_machineid
    INTO @DATA(lv_count).

    IF lv_count IS INITIAL.
      " gợi ý nội dung V1: bạn có thể truyền ngắn gọn hoặc đầy đủ
      RAISE EXCEPTION NEW zcl_validate_kb_tdnc( v1 = |Machine ID "{ i_machineid }" (WC { lv_workcenter }) không tồn tại|
                                                ).
    ENDIF.
  ENDMETHOD.


  METHOD validate_teamid.
    DATA(lv_workcenter) = me->get_workcenter( i_order = i_order i_operation = i_operation ).

    SELECT COUNT(*) FROM
    zi_kb_tsx
    WHERE workcenter = @lv_workcenter
      AND teamid     = @i_teamid
    INTO @DATA(lv_count).

    IF lv_count IS INITIAL.
      RAISE EXCEPTION NEW zcl_validate_kb_tdnc( v1 = |Team ID "{ i_teamid }" (WC { lv_workcenter }) không tồn tại|
                                                ).
    ENDIF.
  ENDMETHOD.


  METHOD validate_workerid.
    DATA(lv_workcenter) = me->get_workcenter( i_order = i_order i_operation = i_operation ).

    SELECT COUNT(*) FROM
    zi_kb_nhancong
    WHERE workcenter = @lv_workcenter
      AND workerid   = @i_workerid
    INTO @DATA(lv_count).

    IF lv_count IS INITIAL.
      RAISE EXCEPTION NEW zcl_validate_kb_tdnc( v1 = |Worker ID "{ i_workerid }" (WC { lv_workcenter }) không tồn tại|
                                                ).
    ENDIF.
  ENDMETHOD.


  METHOD get_workcenter.

    SELECT SINGLE  workcenterinternalid FROM i_productionorderoperation_2
    WHERE productionorder = @i_order
     AND productionorderoperation = @i_operation
     INTO @rv_workcenter.

  ENDMETHOD.
ENDCLASS.

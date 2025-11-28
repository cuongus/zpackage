CLASS lhc_ZI_KB_SOMAY DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_kb_somay RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_kb_somay RESULT result.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_kb_somay~validatedates.

    METHODS validatemachineid FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_kb_somay~validatemachineid.

    METHODS validateworkcenter FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_kb_somay~validateworkcenter.

ENDCLASS.

CLASS lhc_ZI_KB_SOMAY IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD validateDates.
    " Read relevant instance data
    READ ENTITIES OF zi_kb_somay IN LOCAL MODE
      ENTITY zi_kb_somay
        FIELDS ( FromDate ToDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_kb_somay).

    LOOP AT lt_kb_somay INTO DATA(ls_kb_somay).
      APPEND VALUE #(  %tky        = ls_kb_somay-%tky
                        %state_area = 'VALIDATE_DATES' )
         TO reported-zi_kb_somay.

      IF ls_kb_somay-FromDate > ls_kb_somay-ToDate.
        APPEND VALUE #( %tky = ls_kb_somay-%tky ) TO failed-zi_kb_somay.
        APPEND VALUE #( %tky               = ls_kb_somay-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg               = NEW zcm_tw_list(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_tw_list=>from_date_before_to_date
                                                 fromdate = ls_kb_somay-FromDate
                                                 todate   = ls_kb_somay-ToDate )
                        %element-FromDate = if_abap_behv=>mk-on
                        %element-ToDate   = if_abap_behv=>mk-on )
            TO reported-zi_kb_somay.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatemachineid.
    " Read relevant instance data
    READ ENTITIES OF zi_kb_somay IN LOCAL MODE
      ENTITY zi_kb_somay
        FIELDS ( WorkCenter MachineId FromDate ToDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_kb_somay).

    SELECT *
    FROM ztb_kb_somay
         FOR ALL ENTRIES IN @lt_kb_somay
         WHERE machine_id = @lt_kb_somay-machineid
         AND work_center = @lt_kb_somay-workcenter
         INTO TABLE @DATA(lt_boolean).

    IF sy-subrc EQ 0.
      LOOP AT lt_kb_somay INTO DATA(ls_kb_somay).
        READ TABLE lt_boolean INTO DATA(ls_boolean) INDEX 1.

        IF ( ls_boolean-from_date >= ls_kb_somay-FromDate AND ls_kb_somay-ToDate >= ls_boolean-to_date ) OR
           ( ls_boolean-from_date <= ls_kb_somay-FromDate AND ls_kb_somay-FromDate <= ls_boolean-to_date ) OR
           ( ls_boolean-from_date <= ls_kb_somay-ToDate AND ls_kb_somay-ToDate <= ls_boolean-to_date ).
          APPEND VALUE #(  %tky        = ls_kb_somay-%tky
                            %state_area = 'VALIDATE_WORKER_ID' )
             TO reported-zi_kb_somay.

          APPEND VALUE #( %tky = ls_kb_somay-%tky ) TO failed-zi_kb_somay.
          APPEND VALUE #( %tky               = ls_kb_somay-%tky
                          %state_area        = 'VALIDATE_WORKER_ID'
                          %msg               = NEW zcm_tw_list(
                                                   severity  = if_abap_behv_message=>severity-error
                                                   textid    = zcm_tw_list=>existed_machine_id
                                                   machineid = ls_kb_somay-MachineId
                                                   fromdate = ls_kb_somay-FromDate
                                                   todate = ls_kb_somay-ToDate
                                                   )
                          %element-MachineId = if_abap_behv=>mk-on
                          %element-FromDate = if_abap_behv=>mk-on
                          %element-ToDate = if_abap_behv=>mk-on
                          )
              TO reported-zi_kb_somay.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD validateWorkCenter.
    " Read relevant instance data
    READ ENTITIES OF zi_kb_somay IN LOCAL MODE
      ENTITY zi_kb_somay
        FIELDS ( WorkCenter ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_kb_somay).

    LOOP AT lt_kb_somay INTO DATA(ls_kb_somay).
      DATA(lv_respond) = zcl_kb_somay=>data_valid_check( i_workcenter = ls_kb_somay-WorkCenter ).

      IF lv_respond NE abap_true.
        APPEND VALUE #(  %tky        = ls_kb_somay-%tky
                          %state_area = 'VALIDATE_WORKERCENTER' )
           TO reported-zi_kb_somay.

        APPEND VALUE #( %tky = ls_kb_somay-%tky ) TO failed-zi_kb_somay.
        APPEND VALUE #( %tky               = ls_kb_somay-%tky
                        %state_area        = 'VALIDATE_WORKERCENTER'
                        %msg               = NEW zcm_tw_list(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_tw_list=>invalid_worcenter
                                                 workcenter = ls_kb_somay-workcenter )
                        %element-WorkCenter = if_abap_behv=>mk-on )
            TO reported-zi_kb_somay.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

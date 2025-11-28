CLASS lhc_ZI_KB_TSX DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_kb_tsx RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_kb_tsx RESULT result.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_kb_tsx~validatedates.

    METHODS validateteamid FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_kb_tsx~validateteamid.

    METHODS validateworkcenter FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_kb_tsx~validateworkcenter.

    METHODS validateplant FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_kb_tsx~validateplant.

    METHODS validateworkcenterplant FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_kb_tsx~validateworkcenterplant.


ENDCLASS.

CLASS lhc_ZI_KB_TSX IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD validateDates.
    " Read relevant instance data
    READ ENTITIES OF zi_kb_tsx IN LOCAL MODE
      ENTITY zi_kb_tsx
        FIELDS ( FromDate ToDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_kb_tsx).

    LOOP AT lt_kb_tsx INTO DATA(ls_kb_tsx).
      APPEND VALUE #(  %tky        = ls_kb_tsx-%tky
                        %state_area = 'VALIDATE_DATES' )
         TO reported-zi_kb_tsx.

      IF ls_kb_tsx-FromDate > ls_kb_tsx-ToDate.
        APPEND VALUE #( %tky = ls_kb_tsx-%tky ) TO failed-zi_kb_tsx.
        APPEND VALUE #( %tky               = ls_kb_tsx-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg               = NEW zcm_tw_list(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_tw_list=>from_date_before_to_date
                                                 fromdate = ls_kb_tsx-FromDate
                                                 todate   = ls_kb_tsx-ToDate )
                        %element-FromDate = if_abap_behv=>mk-on
                        %element-ToDate   = if_abap_behv=>mk-on )
            TO reported-zi_kb_tsx.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateteamid.
    " Read relevant instance data
    READ ENTITIES OF zi_kb_tsx IN LOCAL MODE
      ENTITY zi_kb_tsx
        FIELDS ( WorkCenter TeamId Plant FromDate ToDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_kb_tsx).

    SELECT *
    FROM ztb_kb_tsx
         FOR ALL ENTRIES IN @lt_kb_tsx
         WHERE team_id = @lt_kb_tsx-teamid
         AND work_center = @lt_kb_tsx-workcenter
         AND plant = @lt_kb_tsx-plant
         INTO TABLE @DATA(lt_boolean).

    IF sy-subrc EQ 0.
      LOOP AT lt_kb_tsx INTO DATA(ls_kb_tsx).
        READ TABLE lt_boolean INTO DATA(ls_boolean) INDEX 1.

        IF ( ls_boolean-from_date >= ls_kb_tsx-FromDate AND ls_kb_tsx-ToDate >= ls_boolean-to_date ) OR
           ( ls_boolean-from_date <= ls_kb_tsx-FromDate AND ls_kb_tsx-FromDate <= ls_boolean-to_date ) OR
           ( ls_boolean-from_date <= ls_kb_tsx-ToDate AND ls_kb_tsx-ToDate <= ls_boolean-to_date ).
          APPEND VALUE #(  %tky        = ls_kb_tsx-%tky
                            %state_area = 'VALIDATE_WORKER_ID' )
             TO reported-zi_kb_tsx.

          APPEND VALUE #( %tky = ls_kb_tsx-%tky ) TO failed-zi_kb_tsx.
          APPEND VALUE #( %tky               = ls_kb_tsx-%tky
                          %state_area        = 'VALIDATE_WORKER_ID'
                          %msg               = NEW zcm_tw_list(
                                                   severity  = if_abap_behv_message=>severity-error
                                                   textid    = zcm_tw_list=>existed_team_id
                                                teamid = ls_kb_tsx-TeamId
                                                fromdate = ls_kb_tsx-FromDate
                                                todate = ls_kb_tsx-ToDate
                                                )
                          %element-TeamId = if_abap_behv=>mk-on
                          %element-FromDate = if_abap_behv=>mk-on
                          %element-ToDate = if_abap_behv=>mk-on
                          )
              TO reported-zi_kb_tsx.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD validateWorkCenter.
    " Read relevant instance data
    READ ENTITIES OF zi_kb_tsx IN LOCAL MODE
      ENTITY zi_kb_tsx
        FIELDS ( WorkCenter ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_kb_tsx).

    LOOP AT lt_kb_tsx INTO DATA(ls_kb_tsx).
      DATA(lv_respond) = zcl_kb_tsx=>data_valid_check( i_workcenter = ls_kb_tsx-WorkCenter ).

      IF lv_respond NE abap_true.
        APPEND VALUE #(  %tky        = ls_kb_tsx-%tky
                          %state_area = 'VALIDATE_WORKERCENTER' )
           TO reported-zi_kb_tsx.

        APPEND VALUE #( %tky = ls_kb_tsx-%tky ) TO failed-zi_kb_tsx.
        APPEND VALUE #( %tky               = ls_kb_tsx-%tky
                        %state_area        = 'VALIDATE_WORKERCENTER'
                        %msg               = NEW zcm_tw_list(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_tw_list=>invalid_worcenter
                                                 workcenter = ls_kb_tsx-workcenter )
                        %element-WorkCenter = if_abap_behv=>mk-on )
            TO reported-zi_kb_tsx.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatePlant.
    " Read relevant instance data
    READ ENTITIES OF zi_kb_tsx IN LOCAL MODE
      ENTITY zi_kb_tsx
        FIELDS ( Plant ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_kb_tsx).

    LOOP AT lt_kb_tsx INTO DATA(ls_kb_tsx).
      DATA(lv_respond) = zcl_kb_tsx=>data_valid_check( i_plant = ls_kb_tsx-Plant ).

      IF lv_respond NE abap_true.

        APPEND VALUE #(  %tky        = ls_kb_tsx-%tky
                          %state_area = 'VALIDATE_PLANT' )
           TO reported-zi_kb_tsx.

        APPEND VALUE #( %tky = ls_kb_tsx-%tky ) TO failed-zi_kb_tsx.
        APPEND VALUE #( %tky               = ls_kb_tsx-%tky
                        %state_area        = 'VALIDATE_PLANT'
                        %msg               = NEW zcm_tw_list(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_tw_list=>invalid_plant
                                                 plant = ls_kb_tsx-plant )
                        %element-Plant = if_abap_behv=>mk-on )
            TO reported-zi_kb_tsx.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateWorkCenterPlant.
    " Read relevant instance data
    READ ENTITIES OF zi_kb_tsx IN LOCAL MODE
      ENTITY zi_kb_tsx
        FIELDS ( WorkCenter Plant ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_kb_tsx).

    LOOP AT lt_kb_tsx INTO DATA(ls_kb_tsx).
      DATA(lv_respond) = zcl_kb_tsx=>data_valid_check( i_workcenter = ls_kb_tsx-WorkCenter
                                                            i_plant = ls_kb_tsx-Plant ).

      IF lv_respond NE abap_true.

        APPEND VALUE #(  %tky        = ls_kb_tsx-%tky
                          %state_area = 'VALIDATE_WORKCENTER_PLANT' )
           TO reported-zi_kb_tsx.

        APPEND VALUE #( %tky = ls_kb_tsx-%tky ) TO failed-zi_kb_tsx.
        APPEND VALUE #( %tky               = ls_kb_tsx-%tky
                        %state_area        = 'VALIDATE_WORKCENTER_PLANT'
                        %msg               = NEW zcm_tw_list(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_tw_list=>workcenter_plant_notmatch
                                                 workcenter = ls_kb_tsx-WorkCenter
                                                 plant = ls_kb_tsx-plant )
                        %element-WorkCenter = if_abap_behv=>mk-on
                        %element-Plant = if_abap_behv=>mk-on )
            TO reported-zi_kb_tsx.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

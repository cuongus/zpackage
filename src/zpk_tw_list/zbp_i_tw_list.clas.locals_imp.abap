CLASS lhc_team_worker_list_i DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

*    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
*      IMPORTING REQUEST requested_authorizations FOR team_worker_list_i RESULT result.

    METHODS autoFill FOR DETERMINE ON MODIFY
      IMPORTING keys FOR team_worker_list_i~autoFill.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR team_worker_list_i~validateDates.

    METHODS validateWorkerId FOR VALIDATE ON SAVE
      IMPORTING keys FOR team_worker_list_i~validateWorkerId.

ENDCLASS.

CLASS lhc_team_worker_list_i IMPLEMENTATION.

*  METHOD get_global_authorizations.
*  ENDMETHOD.


  METHOD autofill.
    " Read relevant instance data
    READ ENTITIES OF zi_tw_list IN LOCAL MODE
      ENTITY team_worker_list_i
        FIELDS ( WorkCenter Plant ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_team_worker_list).
  ENDMETHOD.


  METHOD validateDates.
    " Read relevant instance data
    READ ENTITIES OF zi_tw_list IN LOCAL MODE
      ENTITY team_worker_list_i
        FIELDS ( FromDate ToDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_team_worker_list).

    LOOP AT lt_team_worker_list INTO DATA(ls_team_worker_list).
      APPEND VALUE #(  %tky        = ls_team_worker_list-%tky
                        %state_area = 'VALIDATE_DATES' )
         TO reported-team_worker_list_i.

      IF ls_team_worker_list-FromDate > ls_team_worker_list-ToDate.
        APPEND VALUE #( %tky = ls_team_worker_list-%tky ) TO failed-team_worker_list_i.
        APPEND VALUE #( %tky               = ls_team_worker_list-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg               = NEW zcm_tw_list(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_tw_list=>from_date_before_to_date
                                                 fromdate = ls_team_worker_list-FromDate
                                                 todate   = ls_team_worker_list-ToDate )
                        %element-FromDate = if_abap_behv=>mk-on
                        %element-ToDate   = if_abap_behv=>mk-on )
            TO reported-team_worker_list_i.

*      ELSEIF ls_team_worker_list-FromDate < cl_abap_context_info=>get_system_date( )
*          OR ls_team_worker_list-ToDate < cl_abap_context_info=>get_system_date( ).
*        APPEND VALUE #( %tky               = ls_team_worker_list-%tky ) TO failed-team_worker_list_i.
*        APPEND VALUE #( %tky               = ls_team_worker_list-%tky
*                        %state_area        = 'VALIDATE_DATES'
*                        %msg               = NEW zcm_tw_list(
*                                                 severity  = if_abap_behv_message=>severity-error
*                                                 textid    = zcm_tw_list=>date_invalid
*                                                 fromdate = ls_team_worker_list-FromDate )
*                        %element-FromDate = if_abap_behv=>mk-on
*                        %element-ToDate = if_abap_behv=>mk-on )
*            TO reported-team_worker_list_i.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateWorkerId.
    " Read relevant instance data
    READ ENTITIES OF zi_tw_list IN LOCAL MODE
      ENTITY team_worker_list_i
        FIELDS ( WorkerId ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_team_worker_list).

    SELECT *
    FROM ztb_tw_list
         FOR ALL ENTRIES IN @lt_team_worker_list
         WHERE worker_id = @lt_team_worker_list-WorkerId
         INTO TABLE @DATA(lt_boolean).

    IF sy-subrc EQ 0.
      LOOP AT lt_team_worker_list INTO DATA(ls_team_worker_list).
        APPEND VALUE #(  %tky        = ls_team_worker_list-%tky
                          %state_area = 'VALIDATE_WORKER_ID' )
           TO reported-team_worker_list_i.

        APPEND VALUE #( %tky = ls_team_worker_list-%tky ) TO failed-team_worker_list_i.
        APPEND VALUE #( %tky               = ls_team_worker_list-%tky
                        %state_area        = 'VALIDATE_WORKER_ID'
                        %msg               = NEW zcm_tw_list(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_tw_list=>existed_worker_id
                                                 workerid = ls_team_worker_list-WorkerId )
                        %element-WorkerId = if_abap_behv=>mk-on )
            TO reported-team_worker_list_i.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

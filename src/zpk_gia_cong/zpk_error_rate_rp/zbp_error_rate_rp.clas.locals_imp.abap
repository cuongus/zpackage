CLASS lhc_report DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
*    METHODS get_instance_features FOR INSTANCE FEATURES
*      IMPORTING keys REQUEST requested_features FOR ErrorRateRP RESULT result.

    METHODS modifydate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ErrorRateRP~modifydates.

    METHODS validateErrorCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR ErrorRateRP~validateErrorCode.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR ErrorRateRP~validateDates.

    METHODS existedValue FOR VALIDATE ON SAVE
      IMPORTING keys FOR ErrorRateRP~existedValue.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ErrorRateRP RESULT result.

    METHODS Copy FOR MODIFY
      IMPORTING keys FOR ACTION ErrorRateRP~Copy." RESULT result.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ErrorRateRP RESULT result.
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR ErrorRateRP RESULT result.

*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR ErrorRateRP RESULT result.

ENDCLASS.

CLASS lhc_report IMPLEMENTATION.

*  METHOD get_instance_features.
  " Read the travel status of the existing travels
*    READ ENTITIES OF zi_error_rate_rp IN LOCAL MODE
*      ENTITY ErrorRateRP
*        FIELDS ( DeductionPercent ) WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_ErrorRateRP)
*      FAILED failed.
*  ENDMETHOD.

  METHOD modifydate.
    " Read relevant travel instance data
    READ ENTITIES OF zi_error_rate_rp IN LOCAL MODE
      ENTITY ErrorRateRP
        FIELDS ( ValidFrom ValidTo ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ErrorRateRP).

    " Remove all travel instance data with defined status
    DELETE lt_ErrorRateRP WHERE ValidFrom IS NOT INITIAL OR ValidTo IS NOT INITIAL.
    CHECK lt_ErrorRateRP IS NOT INITIAL.

    " Set default travel status
    MODIFY ENTITIES OF zi_error_rate_rp IN LOCAL MODE
    ENTITY ErrorRateRP
      UPDATE
        FIELDS ( ValidFrom validto )
        WITH VALUE #( FOR travel IN lt_ErrorRateRP
                      ( %tky         = travel-%tky
                        ValidFrom = cl_abap_context_info=>get_system_date( )
                        ValidTo = cl_abap_context_info=>get_system_date( ) ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

  METHOD validateErrorCode.
*    READ ENTITIES OF zi_error_rate_rp IN LOCAL MODE
*      ENTITY ErrorRateRP
*        FIELDS ( ErrorCode ErrorDescription ErrorRateFrom DeductionPercent ValidFrom ValidTo ) WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_ErrorRateRP).
*
*    SELECT *
*    FROM ztb_error_rate
*    FOR ALL ENTRIES IN @lt_ErrorRateRP
*    WHERE error_code = @lt_ErrorRateRP-ErrorCode
*    AND error_description = @lt_ErrorRateRP-ErrorDescription
*    AND error_rate_from = @lt_errorraterp-ErrorRateFrom
*    AND deduction_percent = @lt_errorraterp-DeductionPercent
*    AND valid_from = @lt_ErrorRateRP-ValidFrom
*    AND valid_to = @lt_ErrorRateRP-ValidTo
*    INTO TABLE @DATA(lt_error_rate_tb).
*    IF sy-subrc EQ 0.
*      LOOP AT lt_ErrorRateRP INTO DATA(ls_ErrorRateRP).
*        APPEND VALUE #(  %tky        = ls_ErrorRateRP-%tky
*                  %state_area = 'VALIDATE_ERROR_CODE' )
*            TO reported-ErrorRateRP.
*
*        APPEND VALUE #( %tky = ls_ErrorRateRP-%tky ) TO failed-ErrorRateRP.
*        APPEND VALUE #( %tky               = ls_ErrorRateRP-%tky
*                        %state_area        = 'VALIDATE_ERROR_CODE'
*                        %msg               = NEW zcm_error_rate_rp(
*                                                 severity  = if_abap_behv_message=>severity-error
*                                                 textid    = zcm_error_rate_rp=>duplicate_error_code
*                                                 errorcode = ls_ErrorRateRP-ErrorCode
*                                                 errordescription = ls_ErrorRateRP-ErrorDescription
*                                                 fromdate = ls_ErrorRateRP-ValidFrom
*                                                 todate   = ls_ErrorRateRP-ValidTo )
*                        %element-ErrorCode = if_abap_behv=>mk-on
*                        %element-DeductionPercent = if_abap_behv=>mk-on
*                        %element-ErrorRateFrom = if_abap_behv=>mk-on
*                        %element-ErrorDescription = if_abap_behv=>mk-on )
*            TO reported-ErrorRateRP.
*      ENDLOOP.
*    ENDIF.
    READ ENTITIES OF zi_error_rate_rp IN LOCAL MODE
                 ENTITY ErrorRateRP
                 ALL FIELDS
                 WITH CORRESPONDING #( keys )
                 RESULT DATA(lt_read_data).

    LOOP AT lt_read_data INTO DATA(ls_read_data).
      APPEND VALUE #(  %tky           = ls_read_data-%tky
                    %state_area    = 'CHECKDATA'
                  ) TO reported-errorraterp.
      IF ls_read_data-ValidFrom = '99991231'.
        CONTINUE.
      ENDIF.
      SELECT * FROM zi_error_rate_rp
          WHERE ErrorCode = @ls_read_data-ErrorCode
              AND ErrorRateFrom = @ls_read_data-ErrorRateFrom
              AND uuid <> @ls_read_data-uuid
              AND ( ( ValidFrom <= @ls_read_data-ValidTo AND ValidTo >= @ls_read_data-ValidFrom ) )
            INTO TABLE @DATA(lt_check).
      IF sy-subrc IS INITIAL.
        APPEND VALUE #(  %tky = ls_read_data-%tky ) TO failed-errorraterp.
        APPEND VALUE #( %tky          = ls_read_data-%tky
                        %state_area   = 'CHECKDATA'
                        %msg          = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Đã tồn tại mã lỗi này trong khoảng từ ngày đến ngày' )
                        %element-ErrorCode = if_abap_behv=>mk-on
                      ) TO reported-errorraterp.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDates.
    " Read relevant travel instance data
    READ ENTITIES OF zi_error_rate_rp IN LOCAL MODE
      ENTITY ErrorRateRP
        FIELDS ( ValidFrom ValidTo ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ErrorRateRP).

    LOOP AT lt_ErrorRateRP INTO DATA(ls_ErrorRateRP).
      APPEND VALUE #(  %tky        = ls_ErrorRateRP-%tky
                        %state_area = 'VALIDATE_DATES' )
         TO reported-ErrorRateRP.

      IF ls_ErrorRateRP-ValidTo < ls_ErrorRateRP-ValidFrom.
        APPEND VALUE #( %tky = ls_ErrorRateRP-%tky ) TO failed-ErrorRateRP.
        APPEND VALUE #( %tky               = ls_ErrorRateRP-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg               = NEW zcm_error_rate_rp(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_error_rate_rp=>from_date_before_to_date
                                                 fromdate = ls_ErrorRateRP-ValidFrom
                                                 todate   = ls_ErrorRateRP-ValidTo )
                        %element-ValidFrom = if_abap_behv=>mk-on
                        %element-ValidTo   = if_abap_behv=>mk-on )
            TO reported-ErrorRateRP.

*      ELSEIF ls_ErrorRateRP-ValidFrom < cl_abap_context_info=>get_system_date( )
*          OR ls_ErrorRateRP-ValidTo < cl_abap_context_info=>get_system_date( ).
*        APPEND VALUE #( %tky               = ls_ErrorRateRP-%tky ) TO failed-ErrorRateRP.
*        APPEND VALUE #( %tky               = ls_ErrorRateRP-%tky
*                        %state_area        = 'VALIDATE_DATES'
*                        %msg               = NEW zcm_error_rate_rp(
*                                                 severity  = if_abap_behv_message=>severity-error
*                                                 textid    = zcm_error_rate_rp=>date_null
*                                                 fromdate = ls_ErrorRateRP-ValidFrom )
*                        %element-ValidFrom = if_abap_behv=>mk-on
*                        %element-ValidTo = if_abap_behv=>mk-on )
*            TO reported-ErrorRateRP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD existedValue.
*    READ ENTITIES OF zi_error_rate_rp IN LOCAL MODE
*    ENTITY ErrorRateRP
*      FIELDS (  ErrorCode ErrorRateFrom DeductionPercent ValidFrom ValidTo ) WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_ErrorRateRP).
*
*    SELECT *
*    FROM ztb_error_rate
*    FOR ALL ENTRIES IN @lt_ErrorRateRP
*    WHERE error_code = @lt_ErrorRateRP-ErrorCode
*    AND error_rate_from = @lt_ErrorRateRP-ErrorRateFrom
*    AND deduction_percent = @lt_ErrorRateRP-DeductionPercent
*    AND valid_from = @lt_ErrorRateRP-ValidFrom
*    AND valid_to = @lt_ErrorRateRP-ValidTo
*    INTO TABLE @DATA(lt_error_rate_tb).
*    IF sy-subrc EQ 0.
*      LOOP AT lt_ErrorRateRP INTO DATA(ls_ErrorRateRP).
*        APPEND VALUE #(  %tky        = ls_ErrorRateRP-%tky
*                  %state_area = 'VALIDATE_DEDUCTION_PERCENT' )
*            TO reported-ErrorRateRP.
*
*        APPEND VALUE #( %tky = ls_ErrorRateRP-%tky ) TO failed-ErrorRateRP.
*        APPEND VALUE #( %tky               = ls_ErrorRateRP-%tky
*                        %state_area        = 'VALIDATE_DEDUCTION_PERCENT'
*                        %msg               = NEW zcm_error_rate_rp(
*                                                 severity  = if_abap_behv_message=>severity-error
*                                                 textid    = zcm_error_rate_rp=>duplicate_deduction_percent
*                                                 deductionpercent = ls_ErrorRateRP-DeductionPercent
*                                                 fromdate = ls_ErrorRateRP-ValidFrom
*                                                 todate   = ls_ErrorRateRP-ValidTo )
*                        %element-DeductionPercent = if_abap_behv=>mk-on )
*            TO reported-ErrorRateRP.
*      ENDLOOP.
*    ENDIF.
  ENDMETHOD.

*  METHOD get_instance_authorizations.

*  ENDMETHOD.

  METHOD get_instance_features.

  ENDMETHOD.

  METHOD Copy.
    DATA: lt_create TYPE TABLE FOR CREATE zi_error_rate_rp.
    READ ENTITIES OF zi_error_rate_rp IN LOCAL MODE
      ENTITY ErrorRateRP
        ALL FIELDS
         WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data_read)
      FAILED failed.
    LOOP AT lt_data_read INTO DATA(ls_data_read).
      DATA(lw_index) = sy-tabix.
      APPEND INITIAL LINE TO lt_create ASSIGNING FIELD-SYMBOL(<lf_create>).
      <lf_create>-%cid = lw_index.
      <lf_create>-%data-DeductionPercent = ls_data_read-DeductionPercent .
      <lf_create>-%data-ErrorCode = ls_data_read-ErrorCode.
      <lf_create>-%data-ErrorDescription = ls_data_read-ErrorDescription.
      <lf_create>-%data-ErrorRateFrom = ls_data_read-ErrorRateFrom.
      <lf_create>-%data-ValidFrom = '99991231'."ls_data_read-ValidFrom.
      <lf_create>-%data-ValidTo = '99991231'." ls_data_read-ValidTo.

    ENDLOOP.

    MODIFY ENTITIES OF zi_error_rate_rp IN LOCAL MODE
      ENTITY ErrorRateRP
        CREATE
          FIELDS ( DeductionPercent ErrorCode ErrorDescription ErrorRateFrom ValidFrom ValidTo )
          WITH CORRESPONDING #( lt_create )
      REPORTED DATA(create_reported)
      FAILED failed.

    READ ENTITIES OF zi_error_rate_rp IN LOCAL MODE
      ENTITY ErrorRateRP
        ALL FIELDS
         WITH CORRESPONDING #( create_reported-errorraterp )
      RESULT DATA(lt_data_read_cr)
      FAILED failed.

*    result = VALUE #( ).

*    LOOP AT lt_data_read_cr INTO DATA(ls_cr).
*      APPEND VALUE #( %tky = ls_cr-%tky %param = ls_cr ) TO result.
*    ENDLOOP.

*    LOOP AT lt_data_read INTO DATA(ls_rd).
*      APPEND VALUE #( %tky = ls_rd-%tky %param = ls_rd ) TO result.
*    ENDLOOP.
  ENDMETHOD.

*  METHOD get_instance_authorizations.
*  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

ENDCLASS.

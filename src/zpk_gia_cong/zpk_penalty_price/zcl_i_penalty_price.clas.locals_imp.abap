CLASS lhc_Penalty_price DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Penalty_price~validateDates.

    METHODS defaultdate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Penalty_price~defaultdate.

    METHODS require FOR VALIDATE ON SAVE
      IMPORTING keys FOR Penalty_price~require.

    METHODS code_period FOR VALIDATE ON SAVE
      IMPORTING keys FOR Penalty_price~code_period.

ENDCLASS.

CLASS lhc_Penalty_price IMPLEMENTATION.

  METHOD validateDates.

*    READ ENTITIES OF zi_penalty_price_1 IN LOCAL MODE
*       ENTITY penalty_price
*         FIELDS ( ValidFrom ValidTo ) WITH CORRESPONDING #( keys )
*       RESULT DATA(lt_penaltyprice).
*
*    LOOP AT lt_penaltyprice INTO DATA(ls_penaltyprice).
*      APPEND VALUE #(  %tky        = ls_penaltyprice-%tky
*                        %state_area = 'VALIDATE_DATES' )
*         TO reported-penalty_price.
*
*      IF ls_penaltyprice-ValidTo < ls_penaltyprice-ValidFrom.
*        APPEND VALUE #( %tky = ls_penaltyprice-%tky ) TO failed-penalty_price.
*        APPEND VALUE #( %tky               = ls_penaltyprice-%tky
*                        %state_area        = 'VALIDATE_DATES'
*                        %msg               = NEW zcm_penalty_price(
*                                                 severity  = if_abap_behv_message=>severity-error
*                                                 textid    = zcm_penalty_price=>from_date_before_to_date
*                                                 fromdate = ls_penaltyprice-ValidFrom
*                                                 todate   = ls_penaltyprice-ValidTo )
*                        %element-ValidFrom = if_abap_behv=>mk-on
*                        %element-ValidTo   = if_abap_behv=>mk-on ) TO reported-penalty_price.
*
*      ELSEIF ls_penaltyprice-ValidFrom < cl_abap_context_info=>get_system_date( )
*          OR ls_penaltyprice-ValidTo < cl_abap_context_info=>get_system_date( ).
*        APPEND VALUE #( %tky               = ls_penaltyprice-%tky ) TO failed-penalty_price.
*        APPEND VALUE #( %tky               = ls_penaltyprice-%tky
*                        %state_area        = 'VALIDATE_DATES'
*                        %msg               = NEW zcm_penalty_price(
*                                                 severity  = if_abap_behv_message=>severity-error
*                                                 textid    = zcm_penalty_price=>date_null
*                                                 fromdate = ls_penaltyprice-ValidFrom )
*                        %element-ValidFrom = if_abap_behv=>mk-on ) TO reported-penalty_price.
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.

  METHOD defaultdate.
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    READ ENTITIES OF zi_penalty_price_1 IN LOCAL MODE
         ENTITY penalty_price
           FIELDS ( ValidFrom ValidTo ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_penaltyprice).

    CHECK lt_penaltyprice IS NOT INITIAL.

    MODIFY ENTITIES OF zi_penalty_price_1 IN LOCAL MODE
      ENTITY penalty_price
        UPDATE
          FIELDS ( ValidFrom ValidTo )
          WITH VALUE #(
            FOR travel IN  lt_penaltyprice
            ( %tky      = travel-%tky
              ValidFrom = COND #( WHEN travel-ValidFrom IS INITIAL THEN lv_today ELSE travel-ValidFrom )
              ValidTo   = COND #( WHEN travel-ValidTo   IS INITIAL THEN lv_today ELSE travel-ValidTo )
            )
          )
      REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD require.

    LOOP AT keys INTO DATA(key).
      READ ENTITY IN LOCAL MODE zi_penalty_price_1
        FIELDS ( ErrorCode ErrorType PenaltyPrice ValidFrom ValidTo )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_result).
      LOOP AT lt_result INTO DATA(ls_result).

        IF ls_result-ErrorCode    IS INITIAL OR
           ls_result-ErrorType    IS INITIAL OR
           ls_result-PenaltyPrice IS INITIAL OR
           ls_result-ValidFrom    IS INITIAL OR
           ls_result-ValidTo      IS INITIAL.

          APPEND VALUE #( %msg = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = 'Vui lòng nhập tất cả các trường'
                                )
                          %key = key ) TO reported-Penalty_price.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD code_period.
    LOOP AT keys INTO DATA(key).
      READ ENTITY IN LOCAL MODE zi_penalty_price_1
        FIELDS ( ErrorCode ErrorType ValidFrom ValidTo )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_new_entry).

      LOOP AT lt_new_entry INTO DATA(ls_new_entry).
        "Check map 1-1
        SELECT SINGLE error_type
          FROM ztb_penalty_1
          WHERE error_code = @ls_new_entry-ErrorCode
          INTO @DATA(existing_error_type).

        IF sy-subrc = 0 AND existing_error_type <> ls_new_entry-ErrorType.
          APPEND VALUE #(
            %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-error
                      text     = |Mã lỗi { ls_new_entry-ErrorCode } đã gắn với loại lỗi "{ existing_error_type }".|
                    )
            %key = key
          ) TO reported-penalty_price.
          CONTINUE.
        ENDIF.

*         Check kỳ (khoảng ngày)
        SELECT error_code, valid_from, valid_to
          FROM ztb_penalty_1
          WHERE error_code = @ls_new_entry-ErrorCode
            AND valid_from <= @ls_new_entry-ValidFrom
            AND valid_to   >= @ls_new_entry-ValidTo
          INTO TABLE @DATA(lt_existing).

        IF lines( lt_existing ) > 0.
          LOOP AT lt_existing INTO DATA(ls_exist).
            APPEND VALUE #(
              %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Đã có khoảng ngày { ls_exist-valid_from } - { ls_exist-valid_to }|
                      )
              %key = key
            ) TO reported-penalty_price.
          ENDLOOP.
        ENDIF.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.

CLASS lhc_zr_tbdg_btp_bs DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrTbdgBtpBs
        RESULT result,
      check_data FOR VALIDATE ON SAVE
        IMPORTING keys FOR ZrTbdgBtpBs~check_data.
ENDCLASS.

CLASS lhc_zr_tbdg_btp_bs IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD check_data.
    READ ENTITIES OF zr_tbdg_btp_bs IN LOCAL MODE
             ENTITY ZrTbdgBtpBs
             ALL FIELDS
             WITH CORRESPONDING #( keys )
             RESULT DATA(lt_read_data).

    LOOP AT lt_read_data INTO DATA(ls_read_data).
      APPEND VALUE #(  %tky           = ls_read_data-%tky
                    %state_area    = 'CHECKDATA'
                  ) TO reported-zrtbdgbtpbs.
      IF ls_read_data-Material IS NOT INITIAL.
        SELECT * FROM zr_tbdg_btp_bs
            WHERE Material = @ls_read_data-Material AND id <> @ls_read_data-id
              INTO TABLE @DATA(lt_check).
        IF sy-subrc IS INITIAL.
          APPEND VALUE #(  %tky = ls_read_data-%tky ) TO failed-zrtbdgbtpbs.
          APPEND VALUE #( %tky          = ls_read_data-%tky
                          %state_area   = 'CHECKDATA'
                          %msg          = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = 'Đã tồn tại Material này' )
                          %element-Material = if_abap_behv=>mk-on
                        ) TO reported-zrtbdgbtpbs.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

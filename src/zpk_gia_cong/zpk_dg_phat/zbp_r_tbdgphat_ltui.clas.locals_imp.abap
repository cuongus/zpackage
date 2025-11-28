CLASS LHC_ZR_TBDGPHAT_LTUI DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrTbdgphatLtui
        RESULT result,
      check_data FOR VALIDATE ON SAVE
            IMPORTING keys FOR ZrTbdgphatLtui~check_data.
ENDCLASS.

CLASS LHC_ZR_TBDGPHAT_LTUI IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.
  METHOD check_data.
  READ ENTITIES OF zr_tbdgphat_ltui IN LOCAL MODE
           ENTITY ZrTbdgphatLtui
           ALL FIELDS
           WITH CORRESPONDING #( keys )
           RESULT DATA(lt_read_data).

    LOOP AT lt_read_data INTO DATA(ls_read_data).
      APPEND VALUE #(  %tky           = ls_read_data-%tky
                    %state_area    = 'CHECKDATA'
                  ) TO reported-zrtbdgphatltui.
        SELECT * FROM zr_tbdgphat_ltui
            WHERE Errorcode = @ls_read_data-Errorcode and Loaitui = @ls_read_data-Loaitui
                AND uuid <> @ls_read_data-uuid
              INTO TABLE @DATA(lt_check).
        IF sy-subrc IS INITIAL.
          APPEND VALUE #(  %tky = ls_read_data-%tky ) TO failed-zrtbdgphatltui.
          APPEND VALUE #( %tky          = ls_read_data-%tky
                          %state_area   = 'CHECKDATA'
                          %msg          = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = 'Đã tồn tại dữ liệu này' )
                          %element-Errorcode = if_abap_behv=>mk-on
                        ) TO reported-zrtbdgphatltui.
        ENDIF.

        SELECT * FROM zc_loai_tui_1
            WHERE ProdUnivHierarchyNode = @ls_read_data-Loaitui
              INTO TABLE @DATA(lt_loai_tui_1).
        IF sy-subrc IS not INITIAL.
          APPEND VALUE #(  %tky = ls_read_data-%tky ) TO failed-zrtbdgphatltui.
          APPEND VALUE #( %tky          = ls_read_data-%tky
                          %state_area   = 'CHECKDATA'
                          %msg          = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = 'Mã loại túi không đúng' )
                          %element-Errorcode = if_abap_behv=>mk-on
                        ) TO reported-zrtbdgphatltui.
        ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

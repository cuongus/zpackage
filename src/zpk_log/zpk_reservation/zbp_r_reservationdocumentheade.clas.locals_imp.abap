CLASS lhc_reservationdocumentitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS zzvalidateItem FOR VALIDATE ON SAVE
      IMPORTING keys FOR ReservationDocumentItem~zzvalidateItem.

ENDCLASS.

CLASS lhc_reservationdocumentitem IMPLEMENTATION.

  METHOD zzvalidateItem.
    READ ENTITIES OF i_reservationdocumenttp IN LOCAL MODE
        ENTITY reservationdocumentitem
         ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_items).

    LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_res_item>).
      APPEND VALUE #(  %tky           = <ls_res_item>-%tky
                    %state_area    = 'zzvalidateItem'
                  ) TO reported-reservationdocumentitem.
      IF <ls_res_item>-YY1_TeamPlant_RES <> '' AND <ls_res_item>-YY1_TeamPlant_RES <> <ls_res_item>-Plant.
        APPEND VALUE #( %tky          = <ls_res_item>-%tky
                        %state_area   = 'zzvalidateItem'
                        %msg          = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'Phải nhập plant tổ sản xuất bằng plant của reservation' )
            %element-reservationitem = if_abap_behv=>mk-on
            %path-reservationdocument-%is_draft   = <ls_res_item>-%is_draft
            %path-reservationdocument-reservation = <ls_res_item>-reservation
          )
          TO reported-reservationdocumentitem.

        APPEND VALUE #( %tky = <ls_res_item>-%tky ) TO failed-reservationdocumentitem.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

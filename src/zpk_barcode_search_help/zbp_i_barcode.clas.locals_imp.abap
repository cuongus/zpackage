CLASS lhc_ZI_BARCODE DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_barcode RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_barcode RESULT result.

    METHODS require FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_barcode~require.

    METHODS role FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_barcode~role.

    METHODS validatePlantSloc FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_barcode~validatePlantSloc.

    METHODS validateUniqueMaNv FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_barcode~validateUniqueMaNv.

ENDCLASS.

CLASS lhc_ZI_BARCODE IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD require.

*  LOOP AT keys INTO DATA(key).
    READ ENTITY IN LOCAL MODE zi_barcode
      FIELDS ( MaNv NameNv Plant Role StorageLocation )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).
    LOOP AT lt_result INTO DATA(ls_result).

      IF ls_result-MaNv    IS INITIAL OR
         ls_result-NameNv    IS INITIAL OR
         ls_result-Plant IS INITIAL OR
         ls_result-Role    IS INITIAL OR
         ls_result-StorageLocation      IS INITIAL.

        DATA(lo_msg) = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Vui lòng nhập tất cả các trường' ).

        IF lo_msg IS BOUND.
          APPEND VALUE #(
            %tky = ls_result-%tky
            %msg = lo_msg
          ) TO reported-zi_barcode.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-zi_barcode.
        ENDIF.

      ENDIF.
    ENDLOOP.
*    ENDLOOP.
  ENDMETHOD.

  METHOD role.

    READ ENTITY IN LOCAL MODE zi_barcode
          FIELDS ( Role )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_result).

    LOOP AT lt_result INTO DATA(ls_result).
      IF ls_result-Role IS NOT INITIAL AND ls_result-Role <> 'Thủ kho' AND ls_result-Role <> 'QC'.


        DATA(lo_msg) = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = |Role { ls_result-Role } không hợp lệ| ).

        IF lo_msg IS BOUND.
          APPEND VALUE #(
            %tky = ls_result-%tky
            %msg = lo_msg
          ) TO reported-zi_barcode.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-zi_barcode.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validatePlantSloc.

    READ ENTITY IN LOCAL MODE zi_barcode
          FIELDS ( Plant StorageLocation )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_result).

    LOOP AT lt_result INTO DATA(ls_result).

      SELECT SINGLE plant
        FROM I_StorageLocationStdVH
        WHERE plant = @ls_result-Plant
          AND StorageLocation = @ls_result-StorageLocation
        INTO @DATA(existing_mapping).

      IF sy-subrc <> 0.

        DATA(lo_msg) = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = |Plant { ls_result-Plant } không hợp lệ với Storage Location { ls_result-StorageLocation }| ).

        IF lo_msg IS BOUND.
          APPEND VALUE #(
            %tky = ls_result-%tky
            %msg = lo_msg
          ) TO reported-zi_barcode.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-zi_barcode.
        ENDIF.
*
      ENDIF.


    ENDLOOP.
  ENDMETHOD.

  METHOD validateUniqueMaNv.
    READ ENTITY IN LOCAL MODE zi_barcode
         FIELDS ( MaNv )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_new_entry).

    LOOP AT lt_new_entry INTO DATA(ls_result).

      DATA(lv_manv) = ls_result-MaNv.
      CONDENSE lv_manv NO-GAPS.


      IF lv_manv IS INITIAL OR strlen( lv_manv ) <> 6 .

        DATA(lo_msg) = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = |Mã nhân viên { lv_manv } phải gồm 6 kí tự | ).

        IF lo_msg IS BOUND.
          APPEND VALUE #(
            %tky = ls_result-%tky
            %msg = lo_msg
          ) TO reported-zi_barcode.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-zi_barcode.
        ENDIF.
        CONTINUE.

*      ELSEIF lv_manv CA 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.
*
*        DATA(lo_msg_1) = new_message_with_text(
*                         severity = if_abap_behv_message=>severity-error
*                         text     = |Mã nhân viên { lv_manv } chỉ được nhập số| ).
*
*        IF lo_msg_1 IS BOUND.
*          APPEND VALUE #(
*            %tky = ls_result-%tky
*            %msg = lo_msg
*          ) TO reported-zi_barcode.
*          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-zi_barcode.
*        ENDIF.
*        CONTINUE.

      ENDIF.

      SELECT SINGLE ma_nv
        FROM ztb_barcode
        WHERE ma_nv = @ls_result-MaNv
        AND line_id <> @ls_result-LineId
        INTO @DATA(existing_ma_nv).

      IF sy-subrc = 0.

        DATA(lo_msg_1) = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = |Mã nhân viên { lv_manv } đã tồn tại| ).

        IF lo_msg_1 IS BOUND.
          APPEND VALUE #(
            %tky = ls_result-%tky
            %msg = lo_msg_1
          ) TO reported-zi_barcode.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-zi_barcode.
        ENDIF.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

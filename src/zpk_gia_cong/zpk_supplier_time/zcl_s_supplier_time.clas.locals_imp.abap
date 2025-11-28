CLASS lhc_Supplier_time DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS require FOR VALIDATE ON SAVE
      IMPORTING keys FOR Supplier_time~require.

    METHODS year
      FOR DETERMINATION Supplier_time~year
      IMPORTING keys FOR Supplier_time.

    METHODS partner_name
      FOR DETERMINATION Supplier_time~partner_name
      IMPORTING keys FOR Supplier_time.


    METHODS partner_check FOR VALIDATE ON SAVE
      IMPORTING keys FOR Supplier_time~partner_check.

ENDCLASS.

CLASS lhc_Supplier_time IMPLEMENTATION.

  METHOD require.

    LOOP AT keys INTO DATA(key).
      READ ENTITY IN LOCAL MODE zi_supplier_time
        FIELDS ( CodeProcessing ValidFrom )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_result).
      LOOP AT lt_result INTO DATA(ls_result).

        IF ls_result-CodeProcessing   IS INITIAL OR
           ls_result-ValidFrom    IS INITIAL.

          APPEND VALUE #( %msg = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = 'Vui lòng nhập các trường'
                                )
                          %key = key ) TO reported-supplier_time.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD year.

    DATA: lv_today      TYPE d,
          lv_days_diff  TYPE i,
           lv_years_diff TYPE decfloat16,
           lv_years_char  TYPE char10.
*          lv_years_diff TYPE p LENGTH 8 DECIMALS 2.

    lv_today = cl_abap_context_info=>get_system_date( ).

    LOOP AT keys INTO DATA(key).
      READ ENTITY IN LOCAL MODE zi_supplier_time
        FIELDS ( ValidFrom YearProcessing )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_result).

      LOOP AT lt_result INTO DATA(ls_result).
        IF ls_result-ValidFrom IS NOT INITIAL.

          lv_days_diff = lv_today - ls_result-ValidFrom.
          lv_years_diff = lv_days_diff / 365 .
          ls_result-YearProcessing = lv_years_diff.

          MODIFY ENTITY zi_supplier_time
            UPDATE FIELDS ( YearProcessing )
            WITH VALUE #( ( %tky = ls_result-%tky
                            YearProcessing = ls_result-YearProcessing ) ).

        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD partner_name.

    LOOP AT keys INTO DATA(key).
      READ ENTITY IN LOCAL MODE zi_supplier_time
        FIELDS ( CodeProcessing NameProcrssing )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_result).

      LOOP AT lt_result INTO DATA(ls_result).
        IF ls_result-CodeProcessing IS NOT INITIAL.

          SELECT SINGLE BusinessPartnerName
            FROM I_BusinessPartnerVH
            WHERE BusinessPartner = @ls_result-CodeProcessing
            INTO @DATA(lv_name).

          IF sy-subrc = 0.

            MODIFY ENTITY zi_supplier_time
              UPDATE FIELDS ( NameProcrssing )
              WITH VALUE #( ( %tky = ls_result-%tky
                              NameProcrssing = lv_name ) ).


          ENDIF.

        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

   METHOD partner_check.

    LOOP AT keys INTO DATA(key).
      READ ENTITY IN LOCAL MODE zi_supplier_time
        FIELDS ( CodeProcessing )
        WITH VALUE #( ( %tky = key-%tky ) )
        RESULT DATA(lt_result).

      LOOP AT lt_result INTO DATA(ls_result).
        IF ls_result-CodeProcessing IS NOT INITIAL.

          SELECT SINGLE BusinessPartner
            FROM I_BusinessPartnerVH
            WHERE BusinessPartner = @ls_result-CodeProcessing
            INTO @DATA(lv_bp).

          IF sy-subrc <> 0.
            APPEND VALUE #(
              %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text     = |Mã gia công { ls_result-CodeProcessing } không tồn tại trong danh mục|
                     )
              %key = key ) TO reported-supplier_time.
          ENDIF.

          select SINGLE CodeProcessing from zi_supplier_time
            where CodeProcessing = @ls_result-CodeProcessing and LineId <> @ls_result-LineId
            INTO @DATA(lv_code).
          IF sy-subrc = 0 AND lv_code IS NOT INITIAL.
              APPEND VALUE #(
                %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text     = |Mã gia công { ls_result-CodeProcessing } đã tồn tại trong danh mục|
                         )
                %key = key ) TO reported-supplier_time.
           ENDIF.
       ENDIF.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

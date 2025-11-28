CLASS lhc_ZI_CONTAINER DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zi_container.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zi_container.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zi_container.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_container RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zi_container.

ENDCLASS.

CLASS lhc_ZI_CONTAINER IMPLEMENTATION.

  METHOD create.
    LOOP AT entities INTO DATA(ls_entity).

      DATA: lv_date           TYPE d,
            lv_week           TYPE i,
            lv_year           TYPE i,
            lv_thu4           TYPE d,
            lv_week1_monday   TYPE d,
            lv_diff           TYPE i,
            lv_d              TYPE i,
            lv_m              TYPE i,
            lv_y              TYPE i,
            lv_k              TYPE i,
            lv_j              TYPE i,
            lv_w              TYPE i,
            lv_container_week TYPE string,
            lv_tuan           TYPE string,
            lv_dow            TYPE i.

      IF ls_entity-SalesOrderItem IS NOT INITIAL.
        SELECT
           SalesOrder,SalesOrderItem,Material,salesorderitemtext,orderquantity,sdprocessstatus,plant,BaseUnit
        FROM i_salesorderitem
         WHERE  SalesOrder = @ls_entity-SalesOrder
         AND SalesOrderItem = @ls_entity-SalesOrderItem
           INTO TABLE @DATA(gt_data).
      ELSE.

        SELECT
             SalesOrder,SalesOrderItem,Material,salesorderitemtext,orderquantity,sdprocessstatus,plant,BaseUnit
          FROM i_salesorderitem
           WHERE  SalesOrder = @ls_entity-SalesOrder
             INTO TABLE @gt_data.

      ENDIF.

      IF sy-subrc <> 0.
        APPEND VALUE #(
         %key = ls_entity-%key
         %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |Sales Order không hợp lệ.|
                 )
       ) TO reported-zi_container.
      ELSE.

*
        DATA:lv_matnr TYPE matnr.
        DATA: lv_matnr_1 TYPE string.
*        lv_matnr = 0.

        SELECT MAX( matnr )
       FROM ztb_container
       INTO @DATA(lv_max_matnr).

        IF lv_max_matnr IS INITIAL.
          lv_matnr_1 = 1.
        ELSE.
          lv_matnr_1 = lv_max_matnr + 1.
        ENDIF.


        SORT gt_data BY SalesOrder SalesOrderItem.
        LOOP AT gt_data INTO DATA(gs_data).

          DATA:lv_counter TYPE i.

          SELECT MAX( counter )
          FROM ztb_container
          WHERE sales_order      = @gs_data-SalesOrder
            AND sales_order_item = @gs_data-SalesOrderItem
          INTO @DATA(lv_max_counter).

          IF sy-subrc = 0 AND lv_max_counter IS NOT INITIAL.
            lv_counter = lv_max_counter + 1.
          ELSE.
            lv_counter = 1.
          ENDIF.

          lv_matnr_1 = lv_matnr_1 + 1.
          lv_matnr = |{ lv_matnr_1 ALPHA = IN WIDTH = 18 }|.

*          lv_matnr = lv_matnr + 1 .
*          lv_matnr_1 = |{ lv_matnr ALPHA = IN WIDTH = 18 }|.
          CONDENSE lv_matnr.

          SELECT SINGLE *
          FROM i_salesorderscheduleline
          WHERE SalesOrder = @gs_data-SalesOrder
          AND SalesOrderItem =  @gs_data-SalesOrderItem
          AND IsRequestedDelivSchedLine = 'X'
          AND DelivBlockReasonForSchedLine = ''
          INTO @DATA(ls_sale).

          "tính tuần
          lv_year = ls_sale-RequestedDeliveryDate(4).
          lv_thu4 = |{ lv_year }0104|.
          lv_y = lv_thu4(4).
          lv_m = lv_thu4+4(2).
          lv_d = lv_thu4+6(2).
          IF lv_m = 1 OR lv_m = 2.
            lv_m = lv_m + 12.
            lv_y = lv_y - 1.
          ENDIF.
          lv_k = lv_y MOD 100.
          lv_j = lv_y DIV 100.
          lv_w = ( lv_d
             + ( 13 * ( lv_m + 1 ) ) DIV 5
             + lv_k
             + ( lv_k DIV 4 )
             + ( lv_j DIV 4 )
             + 5 * lv_j ) MOD 7.
          IF lv_w = 0.
            lv_dow = 6.
          ELSEIF lv_w = 1.
            lv_dow = 7.
          ELSE.
            lv_dow = lv_w - 1.
          ENDIF.
          lv_week1_monday = lv_thu4 - ( lv_dow - 1 ).

          lv_diff = lv_date - lv_week1_monday.
          IF lv_diff < 0.
            lv_week = 53.
          ELSE.
            lv_week = lv_diff DIV 7 + 1.
          ENDIF.

          lv_container_week = |{ lv_week }/{ lv_year }|.
          lv_tuan = |{ lv_week }/{ lv_year }|.

          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
          DATA(ls_ztb) = VALUE ztb_container(
           uuid           = lv_uuid
           sales_order           = gs_data-SalesOrder
           sales_order_item       = gs_data-SalesOrderItem
           counter = lv_counter
           sales_order_quan  = gs_data-OrderQuantity
           open_quan = ls_sale-ScheduleLineOrderQuantity
           Uom    = gs_data-BaseUnit
           week = lv_tuan
           container_week = lv_container_week
           container_date = ls_entity-ContainerDate
           container_number = ls_entity-ContainerNumber
           container = ls_entity-Container
           container_quan = ls_sale-ScheduleLineOrderQuantity
           note = ls_entity-Note
*           edit = 'X'
           matnr =  lv_matnr
          ).

          INSERT ztb_container FROM @ls_ztb.

        ENDLOOP.
      ENDIF.



    ENDLOOP.
  ENDMETHOD.

  METHOD update.

    LOOP AT entities INTO DATA(ls_entity).
      DATA(lv_check) = 'X'.
      SELECT SINGLE uuid
        FROM ztb_container
        WHERE sales_order           = @ls_entity-SalesOrder
          AND sales_order_item      = @ls_entity-SalesOrderItem
          AND matnr  = @ls_entity-Matnr

        INTO @DATA(lv_existing_uuid).

      IF sy-subrc = 0.

        UPDATE ztb_container SET note = @ls_entity-Note , edit = @lv_check , container_date = @ls_entity-ContainerDate
        , container_number = @ls_entity-ContainerNumber, container = @ls_entity-Container
          WHERE uuid = @lv_existing_uuid.

      ELSE.

*        DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(ls_ztb) = VALUE ztb_container(
            uuid           = ls_entity-Uuid
*            client         = sy-mandt
            sales_order           = ls_entity-SalesOrder
            sales_order_item       = ls_entity-SalesOrderItem
            matnr  = ls_entity-Matnr
            note = ls_entity-Note
            container_date = ls_entity-ContainerDate
            container_number = ls_entity-ContainerNumber
            container = ls_entity-Container
            edit = lv_check
        ).

        INSERT ztb_container FROM @ls_ztb.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_entity).
      DELETE FROM ztb_container
     WHERE uuid = @ls_entity-uuid
       AND sales_order = @ls_entity-SalesOrder
       AND matnr = @ls_entity-Matnr
       AND sales_order_item = @ls_entity-SalesOrderItem.
    ENDLOOP.

  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_CONTAINER DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_CONTAINER IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

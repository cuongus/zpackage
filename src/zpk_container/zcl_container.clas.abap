CLASS zcl_container DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_container IMPLEMENTATION.
  METHOD if_rap_query_provider~select.

    DATA: lt_data           TYPE TABLE OF  zc_container,
          lt_result         TYPE TABLE OF zc_container,
          lt_container_temp TYPE TABLE OF ztb_container,
          ls_data           TYPE zc_container.

    DATA: lv_date         TYPE d,
          lv_week         TYPE i,
          lv_year         TYPE i,
          lv_thu4         TYPE d,
          lv_week1_monday TYPE d,
          lv_diff         TYPE i,
          lv_d            TYPE i,
          lv_m            TYPE i,
          lv_y            TYPE i,
          lv_k            TYPE i,
          lv_j            TYPE i,
          lv_w            TYPE i,
          lv_dow          TYPE i.

    DATA: lv_sale_order      TYPE RANGE OF i_salesorderitem-SalesOrder,
          lv_plant           TYPE RANGE OF i_plant-Plant,
          lv_matnr           TYPE RANGE OF  i_salesorderitem-Product,
          lv_sale_order_item TYPE RANGE OF i_salesorderitem-SalesOrderItem.

    DATA(lo_filter) = io_request->get_filter( ).

    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_range).
        " Handle error
    ENDTRY.

    LOOP AT lt_filters INTO DATA(ls_filters).
      CASE ls_filters-name.
        WHEN 'SALESORDER'.
          MOVE-CORRESPONDING ls_filters-range TO lv_sale_order .
        WHEN 'SALESORDERITEM'.
          MOVE-CORRESPONDING ls_filters-range TO lv_sale_order_item.
        WHEN 'PLANT'.
          MOVE-CORRESPONDING ls_filters-range TO lv_plant.
        WHEN 'MATNR'.
          MOVE-CORRESPONDING ls_filters-range TO lv_matnr.

      ENDCASE.
    ENDLOOP.

    SELECT *
    FROM ztb_container
      WHERE  sales_order IN @lv_sale_order
      AND sales_order_item IN @lv_sale_order_item
      AND matnr IN @lv_matnr
      AND counter <> ''
    INTO TABLE @DATA(lt_container).


    SORT lt_container BY sales_order sales_order_item.
    DATA(lv_stt) = 1.
    LOOP AT lt_container INTO DATA(ls_container).


      ls_data-Uuid = ls_container-uuid.
      ls_data-SalesOrder = ls_container-sales_order.
      ls_data-SalesOrderItem = ls_container-sales_order_item.
      ls_data-Counter = ls_container-counter.
      ls_data-SalesOrderQuan = ls_container-sales_order_quan.
      ls_data-OpenQuan = ls_container-open_quan.
      ls_data-Uom = ls_container-uom.
      ls_data-Week = ls_container-week.
      ls_data-ContainerWeek = ls_container-container_week.
      ls_data-ContainerDate = ls_container-container_date.
      ls_data-Container = ls_container-container.
      ls_data-ContainerNumber = ls_container-container_number.
      ls_data-ContainerQuan = ls_container-container_quan.
      ls_data-Note = ls_container-note.
      ls_data-Stt = lv_stt.
*      ls_data-Edit = 'X'.
      ls_data-Matnr = ls_container-Matnr.
      CONDENSE ls_data-Matnr.
      APPEND ls_data TO lt_data.
      lv_stt = lv_stt + 1.
      CLEAR: ls_data.
    ENDLOOP.


*    "TH select từ cds view
    SELECT
        SalesOrder,SalesOrderItem,Material,salesorderitemtext,orderquantity,sdprocessstatus,plant,BaseUnit
     FROM i_salesorderitem
      WHERE  SalesOrder IN @lv_sale_order
      AND SalesOrderItem IN @lv_sale_order_item
      AND Material IN @lv_matnr

        INTO TABLE @DATA(gt_data).

    SORT gt_data BY SalesOrder SalesOrderItem.

    LOOP AT gt_data INTO DATA(gs_data).
      ls_data-Stt = lv_stt.
      DATA(lv_uuid_1) = cl_system_uuid=>create_uuid_x16_static( ).
      ls_data-Uuid = lv_uuid_1.
      ls_data-SalesOrder = gs_data-SalesOrder.
      ls_data-SalesOrderItem = gs_data-SalesOrderItem.
      ls_data-SalesOrderQuan = gs_data-OrderQuantity.
      ls_data-Matnr = gs_data-Material.
      ls_data-Uom = gs_data-BaseUnit.

      SELECT SINGLE ScheduleLineOrderQuantity,RequestedDeliveryDate
      FROM i_salesorderscheduleline
      WHERE SalesOrder = @gs_data-SalesOrder
      AND SalesOrderItem =  @gs_data-SalesOrderItem
      AND IsRequestedDelivSchedLine = 'X'
      AND DelivBlockReasonForSchedLine = ''
      INTO @DATA(ls_sale).

      ls_data-OpenQuan = ls_sale-ScheduleLineOrderQuantity.
      ls_data-ContainerQuan = ls_sale-ScheduleLineOrderQuantity.

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
      ls_data-Week = |{ lv_week }/{ lv_year }|.
      ls_data-ContainerWeek = |{ lv_week }/{ lv_year }|.

      "TH chỉnh sửa CDSview

      SELECT SINGLE *
      FROM ztb_container
      WHERE edit = 'X'
      AND sales_order = @gs_data-SalesOrder
      AND sales_order_item = @gs_data-SalesOrderItem
      INTO @DATA(ls_edit).

      IF ls_edit IS NOT INITIAL.
        ls_data-Note = ls_edit-note.
        ls_data-ContainerQuan = ls_edit-container_quan.
        ls_data-ContainerNumber = ls_edit-container_number.
        ls_data-Container = ls_edit-container.
      ENDIF.



      APPEND ls_data TO lt_data.
      lv_stt = lv_stt + 1.
      SORT lt_data BY SalesOrder SalesOrderItem Counter.
      CLEAR: ls_data,ls_sale,lv_year,lv_week, lv_thu4,lv_y,lv_m,lv_d,lv_k,lv_j,lv_w,lv_dow,lv_week1_monday,lv_diff,ls_edit.

*      DELETE FROM ztb_container.  " Xóa toàn bộ bảng
*      COMMIT WORK.

    ENDLOOP.




    DATA(sort_order) = VALUE abap_sortorder_tab(
             FOR sort_element IN io_request->get_sort_elements( )
             ( name = sort_element-element_name
               descending = sort_element-descending ) ).

    IF sort_order IS NOT INITIAL.
      SORT lt_data BY (sort_order).
    ENDIF.

    "--- Apply paging ---
    DATA(lv_total_records) = lines( lt_data ).

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.


    DATA(lo_paging) = io_request->get_paging( ).
    IF lo_paging IS BOUND.
      DATA(top) = lo_paging->get_page_size( ).
      IF top < 0. " -1 = lấy hết
        top = lv_total_records.
      ENDIF.
      DATA(skip) = lo_paging->get_offset( ).

      IF skip >= lv_total_records.
        CLEAR lt_data.
      ELSEIF top = 0.
        CLEAR lt_data.
      ELSE.
        DATA(lv_start_index) = skip + 1.
        DATA(lv_end_index)   = skip + top.

        IF lv_end_index > lv_total_records.
          lv_end_index = lv_total_records.
        ENDIF.

        DATA: lt_paged_result LIKE lt_data.
        CLEAR lt_paged_result.

        DATA(lv_index) = lv_start_index.
        WHILE lv_index <= lv_end_index.
          APPEND lt_data[ lv_index ] TO lt_paged_result.
          lv_index = lv_index + 1.
*          IF lv_index > 1.
*            EXIT.
*          ENDIF.
        ENDWHILE.

*        lt_barcore = lt_paged_result.
      ENDIF.
    ENDIF.

    IF io_request->is_data_requested( ).
      io_response->set_data( lt_paged_result ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

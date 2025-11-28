CLASS zcl_upload_matnr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_UPLOAD_MATNR IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA: lt_data   TYPE TABLE OF  zc_upload_matnr,
          lt_result TYPE TABLE OF zc_upload_matnr,
          ls_data   TYPE zc_upload_matnr.

    DATA(lo_filter) = io_request->get_filter( ).

    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_range).
        " Handle error
    ENDTRY.

    SELECT
        *
     FROM ztb_upload_matnr
*   WHERE  plant IN @lv_plant
*   AND StorageLocation IN @lv_store_loca
*   AND FiscalYear IN @lv_document_year
*   AND PhysicalInventoryDocument IN @lv_pid
*   AND Material IN @lv_matnr
*   AND PhysicalInventoryDocumentItem IN   @lv_pid_item
        INTO TABLE @DATA(gt_data).

    LOOP AT gt_data INTO DATA(gs_data).

      ls_data-DocumentDate = gs_data-doc_date.
      ls_data-PostingDate = gs_data-post_date.
      ls_data-MaterialHeaderText = gs_data-matnr_header_text.
      ls_data-ControlPosting = gs_data-ctrl_post.
      ls_data-GoodsMovementCode           = gs_data-good_code.
      ls_data-MaterialSequenceNumber      = gs_data-matnr_seque_numr.
      ls_data-Reservation                 = gs_data-resevation.
      ls_data-ReservationItem             = gs_data-resevation_item.
      ls_data-GoodsMovementType           = gs_data-good_type.
      ls_data-Material                    = gs_data-matnr.
      ls_data-Plant                       = gs_data-plant.
      ls_data-StorageLocation             = gs_data-storage_location.
      ls_data-Batch                       = gs_data-batch.
      ls_data-ValuationType               = gs_data-valuation_type.
      ls_data-Quantity         = gs_data-quantity.
      ls_data-Unit                   = gs_data-unit.
      ls_data-CostCenter                  = gs_data-cost_center.
      ls_data-FixedAsset                  = gs_data-fixed_asset.
      ls_data-SalesOrder                  = gs_data-sales_order.
      ls_data-SalesOrderItem              = gs_data-sales_order_item.
      ls_data-SpecialStock                = gs_data-spe_stok.
      ls_data-MaterialDocumentItemText    = gs_data-matnr_doc_item_text.
      ls_data-WarehouseNumber               = gs_data-warehouse_number.
      ls_data-StorageBin              = gs_data-store_bin.

      APPEND ls_data TO lt_data.
      CLEAR: ls_data.
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

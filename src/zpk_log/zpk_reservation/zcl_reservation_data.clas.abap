CLASS zcl_reservation_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,


           tt_ranges TYPE TABLE OF ty_range_option.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_reservation_data IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA: lt_data TYPE TABLE OF zi_reservation.
    DATA: ls_page_info TYPE zcl_jp_common_core=>st_page_info.
*
*    TRY.
*        DATA(lo_so_cttgnh)  = zcl_data_bc_xnt=>get_instance( ).
*
*        DATA(lo_common_app) = zcl_jp_common_core=>get_instance( ).

*        lo_common_app->get_fillter_app(
*            EXPORTING
*                io_request  = io_request
*                io_response = io_response
*            IMPORTING
*                wa_page_info          = ls_page_info
*        ).
*
**        DATA(lr_filters) = io_request->get_filter( ).
**        lr_filters->get_as_tree
*
*        TRY.
*            DATA(lr_ranges) = ls_page_info-ro_filter->get_as_ranges( ).
*          CATCH cx_rap_query_filter_no_range.
*            "handle exception
*        ENDTRY.
*
*        DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
*
*
*        SELECT * FROM I_ReservationDocumentItemTP
*        WHERE (lv_sql_filter)
*        INTO CORRESPONDING FIELDS OF TABLE @lt_data.
*
*
*        DATA(sort_order) = VALUE abap_sortorder_tab(
*              FOR sort_element IN io_request->get_sort_elements( )
*              ( name = sort_element-element_name
*                descending = sort_element-descending ) ).
*
*        IF sort_order IS NOT INITIAL.
*          SORT lt_data BY (sort_order).
*        ENDIF.
*
*        "--- Apply paging ---
*        DATA(lv_total_records) = lines( lt_data ).
*
*        IF io_request->is_total_numb_of_rec_requested( ).
*          io_response->set_total_number_of_records( lines( lt_data ) ).
*        ENDIF.
*
*
*        DATA(lo_paging) = io_request->get_paging( ).
*        IF lo_paging IS BOUND.
*          DATA(top) = lo_paging->get_page_size( ).
*          IF top < 0. " -1 = lấy hết
*            top = lv_total_records.
*          ENDIF.
*          DATA(skip) = lo_paging->get_offset( ).
*
*          IF skip >= lv_total_records.
*            CLEAR lt_data.
*          ELSEIF top = 0.
*            CLEAR lt_data.
*          ELSE.
*            DATA(lv_start_index) = skip + 1.
*            DATA(lv_end_index)   = skip + top.
*
*            IF lv_end_index > lv_total_records.
*              lv_end_index = lv_total_records.
*            ENDIF.
*
*            DATA: lt_paged_result LIKE lt_data.
*            CLEAR lt_paged_result.
*
*            DATA(lv_index) = lv_start_index.
*            WHILE lv_index <= lv_end_index.
*              APPEND lt_data[ lv_index ] TO lt_paged_result.
*              lv_index = lv_index + 1.
**          IF lv_index > 1.
**            EXIT.
**          ENDIF.
*            ENDWHILE.
*
**        lt_barcore = lt_paged_result.
*          ENDIF.
*        ENDIF.
*
*        IF io_request->is_data_requested( ).
*          io_response->set_data( lt_paged_result ).
*        ENDIF.

      ENDMETHOD.
ENDCLASS.

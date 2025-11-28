CLASS zcl_get_filter_bkhdvgtt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_range TYPE TABLE OF ty_range_option,

           BEGIN OF ty_page_info,
             paging           TYPE REF TO if_rap_query_paging,
             page_size        TYPE int8,
             offset           TYPE int8,
             requested_fields TYPE if_rap_query_request=>tt_requested_elements,
             sort_order       TYPE if_rap_query_request=>tt_sort_elements,
             ro_filter        TYPE REF TO if_rap_query_filter,
             entity_id        TYPE string,
           END OF ty_page_info,

           st_page_info TYPE ty_page_info.

    CLASS-METHODS get_fillter_app
      IMPORTING io_request      TYPE REF TO if_rap_query_request
                io_response     TYPE REF TO if_rap_query_response
      EXPORTING ir_bukrs        TYPE tt_range
                ir_posting_date TYPE tt_range
                ir_fiscalyear   TYPE tt_range
                ir_docnum       TYPE tt_range
                ir_prctr        TYPE tt_range
                wa_page_info    TYPE st_page_info.

  PRIVATE SECTION.

ENDCLASS.

CLASS zcl_get_filter_bkhdvgtt IMPLEMENTATION.

METHOD get_fillter_app.

  wa_page_info = VALUE #(
    paging            = io_request->get_paging( )
    page_size         = io_request->get_paging( )->get_page_size( )
    offset            = io_request->get_paging( )->get_offset( )
    requested_fields  = io_request->get_requested_elements( )
    sort_order        = io_request->get_sort_elements( )
    ro_filter         = io_request->get_filter( )
    entity_id         = io_request->get_entity_id( )
  ).

  TRY.
      DATA(lr_ranges) = wa_page_info-ro_filter->get_as_ranges( ).
    CATCH cx_rap_query_filter_no_range.
      RETURN.
  ENDTRY.

  LOOP AT lr_ranges INTO DATA(ls_range).
    CASE ls_range-name.
      WHEN 'BUKRS'.
        MOVE-CORRESPONDING ls_range-range TO ir_bukrs.
      WHEN 'POSTING_DATE'.
        MOVE-CORRESPONDING ls_range-range TO ir_posting_date.
      WHEN 'FISCALYEAR'.
        MOVE-CORRESPONDING ls_range-range TO ir_fiscalyear.
      WHEN 'DOCNUM'.
        MOVE-CORRESPONDING ls_range-range TO ir_docnum.
      WHEN 'PRCTR'.
        MOVE-CORRESPONDING ls_range-range TO ir_prctr.
    ENDCASE.
  ENDLOOP.

ENDMETHOD.

ENDCLASS.


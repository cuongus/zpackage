CLASS zcl_fillter_nangsuat DEFINITION
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


           BEGIN OF ty_page_info,
             paging           TYPE REF TO if_rap_query_paging,
             page_size        TYPE int8,
             offset           TYPE int8,
             requested_fields TYPE if_rap_query_request=>tt_requested_elements,
             sort_order       TYPE if_rap_query_request=>tt_sort_elements,
             ro_filter        TYPE REF TO if_rap_query_filter,
             entity_id        TYPE string,
           END OF ty_page_info,

           tt_range     TYPE TABLE OF ty_range_option,
           st_page_info TYPE ty_page_info.

    CLASS-METHODS:
      "Get fillter app
      get_fillter_app IMPORTING io_request   TYPE REF TO if_rap_query_request
                                io_response  TYPE REF TO if_rap_query_response
                      EXPORTING ir_node      TYPE tt_range
                                ir_plant     TYPE tt_range
                                o_monat      TYPE monat
                                o_year       TYPE gjahr
                                wa_page_info TYPE st_page_info.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_fillter_nangsuat IMPLEMENTATION.
  METHOD get_fillter_app.
    wa_page_info-paging            = io_request->get_paging( ).

    wa_page_info-page_size         = io_request->get_paging( )->get_page_size( ).

    wa_page_info-offset            = io_request->get_paging( )->get_offset( ).

    wa_page_info-requested_fields  = io_request->get_requested_elements( ).

    wa_page_info-sort_order        = io_request->get_sort_elements( ).

    wa_page_info-ro_filter         = io_request->get_filter( ).

    wa_page_info-entity_id         = io_request->get_entity_id( ).

    TRY.
        DATA(lr_ranges) = wa_page_info-ro_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.

    LOOP AT lr_ranges INTO DATA(ls_ranges).
      CASE ls_ranges-name.
        WHEN 'PRODUNIVHIERARCHYNODE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_node.
        WHEN 'PLANT'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_plant.
        WHEN 'MONAT'.
          READ TABLE ls_ranges-range INTO DATA(ls_val) INDEX 1.
          o_monat = ls_val-low.
        WHEN 'GJAHR'.
          READ TABLE ls_ranges-range INTO ls_val INDEX 1.
          o_year = ls_val-low.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

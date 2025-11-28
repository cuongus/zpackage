CLASS zcl_get_fillter_snkc DEFINITION
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

    CLASS-DATA:
     "Instance Singleton
     mo_instance      TYPE REF TO zcl_get_fillter_snkc.

    CLASS-METHODS:
      "Contructor khỏi tạo đối tượng
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_get_fillter_snkc,

      "Get fillter app
      get_fillter_app IMPORTING io_request   TYPE REF TO if_rap_query_request
                                io_response  TYPE REF TO if_rap_query_response
                      EXPORTING ir_bukrs     TYPE tt_range
                                ir_racct     TYPE tt_range
                                ir_date      TYPE tt_range
                                ir_belnr     TYPE tt_range
                                ir_blart     TYPE tt_range
                                wa_page_info TYPE st_page_info
                      .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GET_FILLTER_SNKC IMPLEMENTATION.


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
        WHEN 'BUKRS'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_bukrs.
        WHEN 'RACCT'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_racct.
        WHEN 'DATE_TS'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_date.
        WHEN 'BELNR'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_belnr.
        WHEN 'BLART'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_blart.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

  endmethod.


    METHOD get_instance.
      mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                             THEN mo_instance
                                             ELSE NEW #( ) ).
    ENDMETHOD.
ENDCLASS.

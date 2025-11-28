CLASS zcl_get_fillter_kqhdkd DEFINITION
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
     mo_instance      TYPE REF TO zcl_get_fillter_kqhdkd.

    CLASS-METHODS:
      "Contructor khỏi tạo đối tượng
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_get_fillter_kqhdkd,

      "Get fillter app
      get_fillter_app IMPORTING io_request   TYPE REF TO if_rap_query_request
                                io_response  TYPE REF TO if_rap_query_response
                      EXPORTING ir_bukrs     TYPE tt_range
                                ir_prctr     TYPE tt_range
                                ir_gjahr     TYPE tt_range
                                ir_monat     TYPE tt_range
                                ir_type      TYPE tt_range
                                ir_Detail    TYPE tt_range
                                wa_page_info TYPE st_page_info
                      .


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GET_FILLTER_KQHDKD IMPLEMENTATION.


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
        WHEN 'PRCTR'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_prctr.
        WHEN 'GJAHR'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_gjahr.
        WHEN 'MONAT'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_monat.
        WHEN 'TYPE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_type.
        WHEN 'SHOWDETAIL'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_Detail.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.
ENDCLASS.

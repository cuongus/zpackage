CLASS zcl_to_doi_sx DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM cx_rap_query_provider .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES: ty_gt_vh_nhancong TYPE STANDARD TABLE OF zc_kb_nhancong_vh WITH DEFAULT KEY,
           ty_gt_vh_somay    TYPE STANDARD TABLE OF zc_kb_somay_vh WITH DEFAULT KEY,
           ty_gt_vh_tsx      TYPE STANDARD TABLE OF zc_to_doi_cf WITH DEFAULT KEY.

    TYPES: ty_machineid  TYPE RANGE OF zc_kb_somay_vh-machineid,
           ty_shift      TYPE RANGE OF zc_tw_list_vh-shift,
           ty_teamid     TYPE RANGE OF zc_kb_tsx_vh-teamid,
           ty_workcenter TYPE RANGE OF zc_kb_nhancong_vh-workcenter,
           ty_workerid   TYPE RANGE OF zc_kb_nhancong_vh-workerid,
           ty_plant       TYPE RANGE OF ZC_TO_DOI_CF-plant.

    METHODS determine_vh_somay

      IMPORTING

        ir_machineid                 TYPE ty_machineid OPTIONAL

        ir_shift                     TYPE ty_shift OPTIONAL

        ir_teamid                    TYPE ty_teamid OPTIONAL

        ir_workerid                  TYPE ty_workerid OPTIONAL

        ir_workcenter                TYPE ty_workcenter OPTIONAL

        io_paging                    TYPE REF TO if_rap_query_paging

        it_sort_elements             TYPE if_rap_query_request=>tt_sort_elements

        iv_search_expression         TYPE string
      RETURNING
        VALUE(rt_value_help_entries) TYPE ty_gt_vh_somay.

    METHODS determine_vh_tsx

      IMPORTING

        ir_machineid                 TYPE ty_machineid OPTIONAL

        ir_shift                     TYPE ty_shift OPTIONAL

        ir_teamid                    TYPE ty_teamid OPTIONAL

        ir_workerid                  TYPE ty_workerid OPTIONAL

        ir_workcenter                TYPE ty_workcenter OPTIONAL

        ir_plant                     TYPE ty_plant OPTIONAL

        io_paging                    TYPE REF TO if_rap_query_paging

        it_sort_elements             TYPE if_rap_query_request=>tt_sort_elements

        iv_search_expression         TYPE string
      RETURNING
        VALUE(rt_value_help_entries) TYPE ty_gt_vh_tsx.

    METHODS determine_vh_nhancong

      IMPORTING

        ir_machineid                 TYPE ty_machineid OPTIONAL

        ir_shift                     TYPE ty_shift OPTIONAL

        ir_teamid                    TYPE ty_teamid OPTIONAL

        ir_workerid                  TYPE ty_workerid OPTIONAL

        ir_workcenter                TYPE ty_workcenter OPTIONAL

        io_paging                    TYPE REF TO if_rap_query_paging

        it_sort_elements             TYPE if_rap_query_request=>tt_sort_elements

        iv_search_expression         TYPE string
      RETURNING
        VALUE(rt_value_help_entries) TYPE ty_gt_vh_nhancong.

    METHODS get_provided_ranges

      IMPORTING io_request    TYPE REF TO if_rap_query_request

      EXPORTING

                er_machineid  TYPE ty_machineid

                er_shift      TYPE ty_shift

                er_teamid     TYPE ty_teamid

                er_workerid   TYPE ty_workerid

                er_workcenter TYPE ty_workcenter

                er_plant      TYPE ty_plant

      RAISING   cx_rap_query_prov_not_impl

                cx_rap_query_provider.

ENDCLASS.



CLASS ZCL_TO_DOI_SX IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA: lt_vh_nhancong TYPE STANDARD TABLE OF zc_kb_nhancong_vh,
          lt_vh_somay    TYPE STANDARD TABLE OF zc_kb_somay_vh,
          lt_to_doi_cf      TYPE STANDARD TABLE OF zc_to_doi_cf.

    DATA(lo_paging) = io_request->get_paging( ).

    DATA(lt_sort_elements) = io_request->get_sort_elements( ).

    "io_request->get_requested_elements( )  --> could be used for optimizations

    DATA(lv_search_expression) = io_request->get_search_expression( )."Basic search term

    get_provided_ranges(
      EXPORTING
        io_request   = io_request
      IMPORTING
        er_machineid = DATA(ir_machineid)
        er_shift     = DATA(ir_shift)
        er_teamid    = DATA(ir_teamid)
        er_workerid  = DATA(ir_workerid)
        er_workcenter = DATA(ir_workcenter)
        er_plant     = DATA(ir_plant)
    ).

    DATA(lv_entity_id) = io_request->get_entity_id( ).

    TRY.
        CASE lv_entity_id.
          WHEN 'ZC_TO_DOI_CF'.
            lt_to_doi_cf = determine_vh_tsx( ir_teamid            = ir_teamid
                                            ir_workcenter       = ir_workcenter
                                            ir_plant           = ir_plant
                                          io_paging            = lo_paging
                                          it_sort_elements     = lt_sort_elements
                                          iv_search_expression = lv_search_expression
                                          ).

            io_response->set_data( lt_to_doi_cf ).

            io_response->set_total_number_of_records(  lines( lt_to_doi_cf ) ).
        ENDCASE.

      CATCH cx_root INTO DATA(exception).

        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

        RAISE EXCEPTION TYPE zcl_einvoice_data
          EXPORTING
            textid   = VALUE scx_t100key(
            msgid = exception_t100_key-msgid
            msgno = exception_t100_key-msgno
            attr1 = exception_t100_key-attr1
            attr2 = exception_t100_key-attr2
            attr3 = exception_t100_key-attr3
            attr4 = exception_t100_key-attr4 )
            previous = exception.
    ENDTRY.

  ENDMETHOD.


  METHOD get_provided_ranges.

    TRY.

        DATA(lt_ranges)     = io_request->get_filter( )->get_as_ranges(  ).

        LOOP AT lt_ranges REFERENCE INTO DATA(lr_range).

          CASE lr_range->name.

            WHEN 'MACHINEID'.

              LOOP AT lr_range->range REFERENCE INTO DATA(lr_range_entry).

                INSERT VALUE #( sign = lr_range_entry->sign          option = lr_range_entry->option

                                low  = CONV #( lr_range_entry->low ) high   = CONV #( lr_range_entry->high ) )

                                INTO TABLE er_machineid.

              ENDLOOP.

            WHEN 'SHIFT'.

              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.

                INSERT VALUE #( sign = lr_range_entry->sign          option = lr_range_entry->option

                                low  = CONV #( lr_range_entry->low ) high   = CONV #( lr_range_entry->high ) )

                                INTO TABLE er_shift.

              ENDLOOP.

            WHEN 'TEAMID'.

              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.

                INSERT VALUE #( sign = lr_range_entry->sign          option = lr_range_entry->option

                                low  = CONV #( lr_range_entry->low ) high   = CONV #( lr_range_entry->high ) )

                                INTO TABLE er_teamid.

              ENDLOOP.

            WHEN 'WORKERID'.

              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.

                INSERT VALUE #( sign = lr_range_entry->sign          option = lr_range_entry->option

                                low  = CONV #( lr_range_entry->low ) high   = CONV #( lr_range_entry->high ) )

                                INTO TABLE er_workerid.

              ENDLOOP.

            WHEN 'WORKCENTER'.

              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.

                INSERT VALUE #( sign = lr_range_entry->sign          option = lr_range_entry->option

                                low  = CONV #( lr_range_entry->low ) high   = CONV #( lr_range_entry->high ) )

                                INTO TABLE er_workcenter.

              ENDLOOP.

            WHEN OTHERS.

          ENDCASE.

        ENDLOOP.

      CATCH cx_rap_query_filter_no_range INTO DATA(lx_previous).

        "Exception handling needed - not implemented yet

    ENDTRY.

  ENDMETHOD.


  METHOD determine_vh_nhancong.

    SELECT * FROM zc_kb_nhancong
    WHERE workerid   IN @ir_workerid
      AND workcenter IN @ir_workcenter
    INTO TABLE @DATA(lt_kb_nhancong).

    LOOP AT lt_kb_nhancong INTO DATA(ls_kb_nhancong).
      INSERT CORRESPONDING #( ls_kb_nhancong ) INTO TABLE rt_value_help_entries.
    ENDLOOP.

  ENDMETHOD.


  METHOD determine_vh_somay.

    SELECT * FROM zc_kb_somay
    WHERE machineid  IN @ir_machineid
      AND workcenter IN @ir_workcenter
    INTO TABLE @DATA(lt_kb_somay).

    LOOP AT lt_kb_somay INTO DATA(ls_kb_somay).
      INSERT CORRESPONDING #( ls_kb_somay ) INTO TABLE rt_value_help_entries.
    ENDLOOP.

  ENDMETHOD.


  METHOD determine_vh_tsx.

    SELECT * FROM zc_kb_tsx
    WHERE teamid     IN @ir_teamid
      AND workcenter IN @ir_workcenter
      AND plant      IN @ir_plant
    INTO TABLE @DATA(lt_kb_tsx).

    LOOP AT lt_kb_tsx INTO DATA(ls_kb_tsx).
      INSERT CORRESPONDING #( ls_kb_tsx ) INTO TABLE rt_value_help_entries.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.

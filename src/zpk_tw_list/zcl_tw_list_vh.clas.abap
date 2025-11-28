CLASS zcl_tw_list_vh DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES: ty_gt_value_help_entry TYPE STANDARD TABLE OF zc_tw_list_vh WITH DEFAULT KEY,
           ty_gs_value_help_entry TYPE zc_tw_list_vh.

    TYPES: ty_machineid TYPE RANGE OF zc_tw_list_vh-MachineId,
           ty_shift     TYPE RANGE OF zc_tw_list_vh-Shift,
           ty_teamid    TYPE RANGE OF zc_tw_list_vh-TeamId,
           ty_workerid  TYPE RANGE OF zc_tw_list_vh-WorkerId.



    METHODS determine_allowed_approvers

      IMPORTING

        ir_machineid                 TYPE ty_machineid

        ir_shift                     TYPE ty_shift

        ir_teamid                    TYPE ty_teamid

        ir_workerid                  TYPE ty_workerid

        io_paging                    TYPE REF TO if_rap_query_paging

        it_sort_elements             TYPE if_rap_query_request=>tt_sort_elements

        iv_search_expression         TYPE string

      RETURNING

        VALUE(rt_value_help_entries) TYPE ty_gt_value_help_entry.

    METHODS get_allowed_list_via_http

      IMPORTING

        ir_machineid              TYPE ty_machineid

        ir_shift                  TYPE ty_shift

        ir_teamid                 TYPE ty_teamid

        ir_workerid               TYPE ty_workerid

        io_paging                 TYPE REF TO if_rap_query_paging

        it_sort_elements          TYPE if_rap_query_request=>tt_sort_elements

      RETURNING

        VALUE(lt_value_help_list) TYPE ty_gt_value_help_entry.

    METHODS process_descr_only_request

      IMPORTING

        io_response TYPE REF TO if_rap_query_response.

    METHODS get_provided_ranges

      IMPORTING io_request   TYPE REF TO if_rap_query_request

      EXPORTING

                er_machineid TYPE ty_machineid

                er_shift     TYPE ty_shift

                er_teamid    TYPE ty_teamid

                er_workerid  TYPE ty_workerid

      RAISING   cx_rap_query_prov_not_impl

                cx_rap_query_provider.

    METHODS is_descriptions_only_request

      IMPORTING
                io_request                      TYPE REF TO if_rap_query_request

                ir_machineid                    TYPE ty_machineid

                ir_shift                        TYPE ty_shift

                ir_teamid                       TYPE ty_teamid

                ir_workerid                     TYPE ty_workerid

      RETURNING

                VALUE(rv_is_descr_only_request) TYPE abap_bool

      RAISING   cx_rap_query_prov_not_impl

                cx_rap_query_provider.
ENDCLASS.



CLASS ZCL_TW_LIST_VH IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA lt_value_help_entries TYPE STANDARD TABLE OF zc_tw_list_vh.

    DATA ls_value_help_entry   TYPE zc_tw_list_vh.

    DATA(lo_paging) = io_request->get_paging( ).

    DATA(lt_sort_elements) = io_request->get_sort_elements( ) .



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
    ).

    IF is_descriptions_only_request(
        io_request = io_request
        ir_machineid         = ir_machineid
        ir_shift             = ir_shift
        ir_teamid            = ir_teamid
        ir_workerid          = ir_workerid ).

      process_descr_only_request(
        io_response = io_response ).
    ELSE.
      lt_value_help_entries = determine_allowed_approvers(
        ir_machineid         = ir_machineid
        ir_shift             = ir_shift
        ir_teamid            = ir_teamid
        ir_workerid          = ir_workerid
        io_paging            = lo_paging
        it_sort_elements     = lt_sort_elements
        iv_search_expression = lv_search_expression
      ).

      io_response->set_data( lt_value_help_entries ).

      io_response->set_total_number_of_records(  lines( lt_value_help_entries ) ).
    ENDIF.
**********************************************************************

* How to implement exception handling:

*  "! @raising cx_rap_query_prov_not_impl | Should be raised if the provider lacks the ability to fulfill the request at hand

*  "!                                       in its current state of implementation.

*  "! @raising cx_rap_query_provider      | General failure. Must be raised if an error prevents successful query processing.

**********************************************************************
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

            WHEN OTHERS.

          ENDCASE.

        ENDLOOP.

      CATCH cx_rap_query_filter_no_range INTO DATA(lx_previous).

        "Exception handling needed - not implemented yet

    ENDTRY.

  ENDMETHOD.


  METHOD is_descriptions_only_request.
    rv_is_descr_only_request = abap_false.

    DATA(lt_requested) = io_request->get_requested_elements( ).

    IF lines( lt_requested ) = 1.
      READ TABLE lt_requested INDEX 1 INTO DATA(ls_requested).
      IF ls_requested = 'TEAMNAME' OR ls_requested = 'WORKERNAME'.
*        rv_is_descr_only_request = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD determine_allowed_approvers.

* HTTP call to SAP BTP service for allowed approvers

**********************************************************************

*    lt_allowed_approvers_emails = get_allowed_apprvs_via_http(
*
*        it_emailaddress_range       = it_emailaddress_range
*
*        it_company_code_range       = it_company_code_range
*
*        io_paging                   = io_paging
*
*        it_sort_elements            = it_sort_elements
*
*    )."Note: for simplicity reasons we do not respect name filtering and we do ignore the search expression

**********************************************************************

    SELECT * FROM zc_tw_list
    WHERE MachineId IN @ir_machineid
    AND Shift IN @ir_shift
    AND TeamId IN @ir_teamid
    AND WorkerId IN @ir_workerid
    INTO TABLE @DATA(lt_tw_list).

    LOOP AT lt_tw_list INTO DATA(ls_tw_list).
      INSERT CORRESPONDING #( ls_tw_list ) INTO TABLE rt_value_help_entries.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_allowed_list_via_http.

    TRY.

        " Create http client

*        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
*          comm_scenario = ‘add your DATA here’
*          service_id    = ‘add your DATA here’ ).
*
*        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
*
*
*
*
*
*        DATA(lo_client_proxy) = cl_web_odata_client_factory=>create_v2_remote_proxy(
*          iv_service_definition_name = ‘add your DATA here’
*          io_http_client             = lo_http_client
*          iv_relative_service_root   = ‘add your DATA here’ ).
*
*
*
*        " Navigate to the resource and create a request for the read operation
*
*        DATA(lo_request) = lo_client_proxy->create_resource_for_entity_set( ‘add your DATA here’ )->create_request_for_read( ).
*
*
*
*        " Create the filter
*
*        DATA(lo_filter_factory) = lo_request->create_filter_factory( ).
*
*        IF it_company_code_range IS NOT INITIAL.
*
*          DATA(lo_company_code_filter) = lo_filter_factory->create_by_range(
*            iv_property_path = 'COMPANYCODE'
*            it_range         = it_company_code_range ).
*
*          IF it_emailaddress_range IS NOT INITIAL.
*
*            DATA(lo_concatenated_filter) = lo_company_code_filter->and( lo_filter_factory->create_by_range(
*
*              iv_property_path = 'EMAIL'
*
*              it_range         = it_emailaddress_range )  ).
*
*            lo_request->set_filter( lo_concatenated_filter ).
*
*          ELSE.
*
*            lo_request->set_filter( lo_company_code_filter ).
*
*          ENDIF.
*
*        ENDIF.
*
*
*
*        lo_request->set_top( io_paging->get_page_size(  ) )->set_skip( io_paging->get_offset(  ) ).
*
*
*
*        DATA lt_sort_order TYPE /iwbep/if_cp_runtime_types=>ty_t_sort_order.
*
*        LOOP AT it_sort_elements REFERENCE INTO DATA(lr_sort_element).
*
*          IF lr_sort_element->element_name IS NOT INITIAL.
*
*            IF lr_sort_element->element_name = 'EMAILADDRESS'.
*
*              DATA(lv_property_path) = 'EMAIL'.
*
*            ELSE.
*
*              lv_property_path = lr_sort_element->element_name.
*
*            ENDIF.
*
*            INSERT VALUE #(
*
*              property_path = CONV #( lv_property_path )
*
*              descending    = lr_sort_element->descending ) INTO TABLE lt_sort_order.
*
*          ENDIF.
*
*        ENDLOOP.
*
*        lo_request->set_orderby( CONV #( lt_sort_order ) ).
*
*
*
*        " Execute the request and retrieve the business data
*
*        DATA(lo_response) = lo_request->execute( ).
*
*        lo_response->get_business_data( IMPORTING et_business_data = lt_allowed_approvers ).
*
*
*
*
*
*        LOOP AT lt_allowed_approvers REFERENCE INTO DATA(lr_allowed_approver).
*
*          INSERT lr_allowed_approver->Email INTO TABLE rt_allowed_approvers_emails.
*
*        ENDLOOP.


      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).

        " Handle remote Exception

        " It contains details about the problems of your http(s) connection



      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).

        " Handle Exception



      CATCH cx_web_http_client_error INTO DATA(lx_http_client_error).

        "handle exception

      CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).

        "handle exception

    ENDTRY.
  ENDMETHOD.


  METHOD process_descr_only_request.
    DATA: lt_value_help_entries TYPE STANDARD TABLE OF zc_tw_list_vh,
          ls_value_help_entry   TYPE zc_tw_list_vh.

    CLEAR: ls_value_help_entry.

    APPEND ls_value_help_entry TO lt_value_help_entries.

    io_response->set_data( lt_value_help_entries ).

    io_response->set_total_number_of_records(  lines(  lt_value_help_entries ) ).
  ENDMETHOD.
ENDCLASS.

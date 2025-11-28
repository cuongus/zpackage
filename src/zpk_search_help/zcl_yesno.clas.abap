CLASS zcl_yesno DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_YESNO IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA business_data TYPE TABLE OF zc_yesno .

    DATA business_data_line TYPE zc_yesno .

    DATA(top)     = io_request->get_paging( )->get_page_size( ).
    DATA(skip)    = io_request->get_paging( )->get_offset( ).

    DATA(requested_fields)  = io_request->get_requested_elements( ).

    DATA(sort_order)    = io_request->get_sort_elements( ).

    TRY.
        DATA(filter_condition_string) = io_request->get_filter( )->get_as_sql_string( ).
*        DATA(filter_condition_ranges) = io_request->get_filter( )->get_as_ranges(  ).

        business_data_line-zvalue         = 'X'.
        business_data_line-description = 'Yes'.
        APPEND business_data_line TO business_data.
        CLEAR: business_data_line.

        business_data_line-zvalue         = ''.
        business_data_line-description = 'No'.
        APPEND business_data_line TO business_data.
        CLEAR: business_data_line.

        select * from @business_data as data
         WHERE (filter_condition_string)
         INTO TABLE @DATA(lt_data).

*        READ TABLE filter_condition_ranges WITH KEY name = 'ZVALUE'
*               INTO DATA(ls_zvalue).
*        IF sy-subrc = 0.
*            DELETE business_data WHERE zvalue not in ls_zvalue-range.
*        ENDIF.

        io_response->set_total_number_of_records( lines( lt_data ) ).
        io_response->set_data( lt_data ).

      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

        "do some exception handling

    ENDTRY.
  ENDMETHOD.
ENDCLASS.

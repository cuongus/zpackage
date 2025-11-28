CLASS zcl_tw_list_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .

    TYPES: BEGIN OF ty_range_from_to,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_from_to,
           tt_ranges TYPE TABLE OF ty_range_from_to.

    CLASS-DATA:
      mo_instance    TYPE REF TO zcl_c_log_in.

    CLASS-METHODS:
      " Constructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_c_log_in.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TW_LIST_API IMPLEMENTATION.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD if_rap_query_provider~select.

    DATA: ls_page_info   TYPE zcl_jp_common_core=>st_page_info.

    TRY.

        DATA(lo_common_app) = zcl_jp_common_core=>get_instance( ).

        lo_common_app->get_fillter_app(
            EXPORTING
                io_request  = io_request
                io_response = io_response
            IMPORTING
                wa_page_info          = ls_page_info
        ).

        TRY.
            DATA(lr_ranges) = ls_page_info-ro_filter->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range.
            " Handle exception
        ENDTRY.

        DATA(lv_postingdate) = io_request->get_parameters(  ).

        READ TABLE lr_ranges WITH KEY  name = 'POSTINGDATE' INTO DATA(ls_ranges).
        IF sy-subrc IS INITIAL.
          READ TABLE ls_ranges-range INDEX 1 INTO DATA(ls_r_POSTINGDATE).
        ENDIF.

        DATA: lt_data TYPE TABLE OF ztb_tw_list.

        SELECT *
            FROM ztb_tw_list
            WHERE from_date < @ls_r_postingdate-low
            AND to_date > @ls_r_postingdate-low
            INTO TABLE @lt_data.

        IF sy-subrc NE 0.
          " Error message
        ENDIF.

          DATA(lw_json_body) = /ui2/cl_json=>serialize(
                     data = lt_data
                     compress = abap_true
                     pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

*          DATA(lv_base64) =  cl_web_http_utility=>encode_base64( lw_json_body ).
*          <lf_data>-authorizations    =   lv_base64.
*        ENDIF.

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        IF io_request->is_data_requested( ).
          io_response->set_data( lt_data ).
        ENDIF.

      CATCH cx_root INTO DATA(exception).
*        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).
*
*        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.
*
*        RAISE EXCEPTION TYPE zcl_c_log_in
*          EXPORTING
*            textid   = VALUE scx_t100key(
*            msgid = exception_t100_key-msgid
*            msgno = exception_t100_key-msgno
*            attr1 = exception_t100_key-attr1
*            attr2 = exception_t100_key-attr2
*            attr3 = exception_t100_key-attr3
*            attr4 = exception_t100_key-attr4 )
*            previous = exception.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

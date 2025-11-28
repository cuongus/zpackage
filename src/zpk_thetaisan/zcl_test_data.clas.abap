CLASS zcl_test_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.
    CLASS-METHODS:
      "Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_test_data.
    CLASS-DATA:
        "Instance Singleton
        mo_instance      TYPE REF TO zcl_test_data.
*    TYPES: tt_invoice TYPE TABLE OF ztb_cat_rev_log.
*    CLASS-DATA : gt_invoice        TYPE TABLE OF ztb_cat_rev_log,
*                 gs_invoice        TYPE   ztb_cat_rev_log,
*                 gt_invoice_result TYPE TABLE OF ztb_cat_rev_log,
*                 gs_invoice_result TYPE   ztb_cat_rev_log.
*    CLASS-METHODS post_je IMPORTING im_invoice TYPE tt_invoice
*                          EXPORTING ex_result  TYPE tt_invoice.

ENDCLASS.



CLASS ZCL_TEST_DATA IMPLEMENTATION.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
*    thông tin nhà cung cấp
*    zcl_jp_common_core=>get_bp_info_new(
*       EXPORTING
*           i_businesspartner = ls_po_h-Supplier
*       IMPORTING
*           o_bp_info = DATA(ls_supplier)
*
*    ).
    DATA: lv_url  TYPE string, " Replace with actual URL
          lv_pref TYPE string,
          i_xml   TYPE string.
*          lv_uuid TYPE string VALUE `urn:uuid:{{$randomUUID}}`.
    TRY.
        DATA(lv_host) = cl_abap_context_info=>get_system_url( ).
        SPLIT lv_host AT '.' INTO lv_host lv_pref.
        CONCATENATE lv_host `-api` `.` lv_pref INTO lv_host.
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.
    DATA: lv_seq     TYPE string,
          lv_bukrs   TYPE bukrs,
          lv_belnr   TYPE belnr_d,
          lv_gjahr   TYPE gjahr,
          lv_date    TYPE string,
          lv_id      TYPE string,
          lv_date_ph TYPE zde_char20,
          lv_buzei   TYPE zde_char3.
    DATA: lw_substr    TYPE string,
          lw_docnumstr TYPE string,
          lw_exit      TYPE char1,
          lw_docnum    TYPE char10,
          lw_log       TYPE char256,
          lw_itemstr   TYPE string.
    DATA(system_uuid) = cl_system_uuid=>create_uuid_c36_static( ).

    DATA(lv_current_date) = cl_abap_context_info=>get_system_date( ).
    DATA(lv_current_time) = cl_abap_context_info=>get_system_time( ).
    DATA(lv_timezone) = cl_abap_context_info=>get_user_time_zone( ).

    lv_id  = |MSG_{ lv_current_date+0(4) }-{ lv_current_date+4(2) }-{ lv_current_date+6(2) }_API|.
    lv_date    = |{ lv_current_date+0(4) }-{ lv_current_date+4(2) }-{ lv_current_date+6(2) }T{ lv_current_time+0(2) }:{ lv_current_time+2(2) }:{ lv_current_time+4(2) }.1234567Z|.
    TRY.
        DATA(lv_uuid) = cl_system_uuid=>create_uuid_c36_static( ).
      CATCH cx_uuid_error INTO DATA(lx_uuid).
    ENDTRY.


    TRY.

        DATA: lv_username TYPE string,
              lv_password TYPE string.

        lv_username = |INBOUND_COMM_USER_BTP_EXTENSION|.
        lv_password = `DCg=#-}.v-qnz&wFz2025`.      "create http destination by url; API endpoint for API sandbox
        lv_url = |https://my426501-api.s4hana.cloud.sap:443/sap/opu/odata4/sap/api_fixedasset/srvd_a2x/sap/fixedasset/0001/FixedAsset/6710/000010000000/0000|.
        DATA(lo_http_destination) =
          cl_http_destination_provider=>create_by_url(
          i_url = lv_url ).

        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_http_destination ).

*-- SET HTTP Header Fields

        lo_http_client->get_http_request( )->set_header_fields( VALUE #(
            ( name = |Accept-Encoding| value = |gzip,deflate| )
            ( name = |Content-Type|    value = |text/xml;charset=UTF-8| )
*            ( name = |SOAPAction|      value = |http://sap.com/xi/SAPSCORE/SFIN/JournalEntryCreateRequestConfirmation_In/JournalEntryCreateRequestConfirmation_InRequest| )
            ( name = |Host|            value = lv_host )
            ( name = |Connection|      value = |Keep-Alive| )
            ( name = |User-Agent|      value = |Apache-HttpClient/4.5.5 (Java/16.0.2)| )
        ) ).

*        DATA: lv_username TYPE string,
*              lv_password TYPE string.

        lv_username = |INBOUND_COMM_USER_BTP_EXTENSION|.
        lv_password = `DCg=#-}.v-qnz&wFz2025`.

*-- Passing the Accept value in header which is a mandatory field
        lo_http_client->get_http_request( )->set_header_field( i_name = |username| i_value = lv_username ).
        lo_http_client->get_http_request( )->set_header_field( i_name = |password| i_value = lv_password ).
*-- Authorization
        lo_http_client->get_http_request( )->set_authorization_basic( i_username = lv_username i_password = lv_password ).
        lo_http_client->get_http_request( )->set_content_type( |text/xml;charset=UTF-8| ).

        lo_http_client->get_http_request( )->set_version( version = if_web_http_request=>co_protocol_version_1_1 ).
*-- Send request ->
*        lo_http_client->get_http_request( )->set_text( i_xml ).
**-- POST
*        lo_http_client->execute( i_method = if_web_http_client=>post
*                                 ).
        lo_http_client->execute( i_method = if_web_http_client=>get
).
*-- Response ->
        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>get
                                                     ).
        DATA(code) = lo_response->get_status( )-code.
        DATA(reason) = lo_response->get_status( )-reason.
        DATA(lv_body)  = lo_response->get_text( ).
**********************************************************************
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

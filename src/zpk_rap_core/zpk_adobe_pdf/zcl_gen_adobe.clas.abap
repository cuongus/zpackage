CLASS zcl_gen_adobe DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_logo_request,
        row  TYPE string, "Row Id XML
        name TYPE string,
      END OF   ty_logo_request,

      BEGIN OF ty_request,
        id   TYPE string,
        logo TYPE TABLE OF ty_logo_request WITH EMPTY KEY,
        data TYPE STANDARD TABLE OF string WITH EMPTY KEY,
      END OF ty_request,

      BEGIN OF ty_xml,
        logo TYPE TABLE OF ty_logo_request WITH EMPTY KEY,
        data TYPE STANDARD TABLE OF xstring WITH EMPTY KEY,
      END OF ty_xml,

      BEGIN OF ty_response,
        file_content TYPE zde_adobe_attachment,
      END OF ty_response,

      ty_gs_xml  TYPE ty_xml,

      ts_request TYPE ty_request.

    METHODS: get_pdf IMPORTING request  TYPE string OPTIONAL "ty_request
                     EXPORTING pdf64    TYPE string
                               response TYPE string.
    METHODS:
      call_data IMPORTING i_request      TYPE ts_request OPTIONAL
                EXPORTING o_pdf_string   TYPE string
                RETURNING VALUE(respone) TYPE xstring.

    METHODS: get_queue IMPORTING iv_qname         TYPE cl_print_queue_utils=>ty_pqname
                       RETURNING VALUE(rv_itemid) TYPE cl_print_queue_utils=>ty_itemid.

    METHODS: render_4_pq IMPORTING iv_xml        TYPE xstring
                                   iv_rpid       TYPE string
                                   iv_qname      TYPE cl_print_queue_utils=>ty_pqname
                         RETURNING VALUE(rv_pdf) TYPE  xstring.

    METHODS: print_pdf IMPORTING i_xml         TYPE ty_gs_xml
                                 iv_rpid       TYPE string
                       EXPORTING str_pdf       TYPE string
                       RETURNING VALUE(rv_pdf) TYPE xstring.

    METHODS: print_queue IMPORTING iv_qname            TYPE cl_print_queue_utils=>ty_pqname
                                   iv_print_data       TYPE cl_print_queue_utils=>ty_print_data
                                   iv_name_of_main_doc TYPE cl_print_queue_utils=>ty_doc_name
                                   iv_itemid           TYPE cl_print_queue_utils=>ty_itemid OPTIONAL
                                   iv_pages            TYPE cl_print_queue_utils=>ty_page_count DEFAULT 0
                                   iv_number_of_copies TYPE cl_print_queue_utils=>ty_nr_copies DEFAULT 1
                                   it_attachment_data  TYPE cl_print_queue_utils=>ty_attachment_data_info_tab OPTIONAL
                         EXPORTING ev_err_msg          TYPE cl_print_queue_utils=>ty_msg
                         RETURNING VALUE(rv_itemid)    TYPE cl_print_queue_utils=>ty_itemid.


  PROTECTED SECTION.
  PRIVATE SECTION.
    "table Logo
    TYPES: BEGIN OF ty_logo_base64,
             row    TYPE int1,
             base64 TYPE string,
             name   TYPE c LENGTH 50,
           END   OF ty_logo_base64.

    DATA: gt_logo_base64 TYPE STANDARD TABLE OF ty_logo_base64 WITH KEY row,
          gs_logo_base64 LIKE LINE OF gt_logo_base64.

    DATA:
      request_method     TYPE string,
      request_body       TYPE string,
      request_data       TYPE ty_request,
      request_adobe_body TYPE string.

    DATA:
      response_data TYPE ty_response,
      response_body TYPE string,
      lv_pdf        TYPE string.

ENDCLASS.



CLASS ZCL_GEN_ADOBE IMPLEMENTATION.


  METHOD call_data.
    DATA:
      lv_xdp_layout       TYPE xstring,
      lv_xml_data_string  TYPE string,
      lv_xml_data_xstring TYPE xstring,
      lv_xml_data         TYPE string,
      lv_return           TYPE xstring.

    MOVE-CORRESPONDING i_request TO request_data.
    "template a
    SELECT SINGLE file_content
        FROM zcore_tb_temppdf
        WHERE id = @request_data-id
        INTO @response_data-file_content.

    lv_xdp_layout = response_data-file_content.

    DATA(lv_pdf_merge) = cl_rspo_pdf_merger=>create_instance( ).

    " if logo exist
    IF request_data-logo IS NOT INITIAL.

      DATA: lw_logo_xstring TYPE xstring.
      MOVE-CORRESPONDING request_data-logo TO gt_logo_base64.

      SELECT
      logo~row,
      logo~name,
      zcore_tb_temppdf~file_content
      FROM zcore_tb_temppdf
      INNER JOIN @gt_logo_base64 AS logo
              ON zcore_tb_temppdf~id = logo~name
      ORDER BY logo~row
      INTO TABLE @DATA(lt_logo_file_content).
      IF sy-subrc = 0.
        LOOP AT gt_logo_base64 ASSIGNING FIELD-SYMBOL(<lfs_logo>).
          READ TABLE lt_logo_file_content INTO DATA(ls_logo_file_content)
            WITH KEY row = <lfs_logo>-row
                     BINARY SEARCH.
          IF sy-subrc = 0.
            lw_logo_xstring = ls_logo_file_content-file_content.
            DATA(lw_logo) = cl_web_http_utility=>encode_x_base64( lw_logo_xstring ).

            <lfs_logo>-base64 = lw_logo.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDIF.


    LOOP AT request_data-data INTO lv_xml_data.

      DATA(index) = sy-tabix.
      "change base
      IF gt_logo_base64 IS NOT INITIAL.
        READ TABLE gt_logo_base64 INTO DATA(ls_logo)
           WITH TABLE KEY row = index.
        IF sy-subrc = 0.
          REPLACE ALL OCCURRENCES OF '<LOGO/>' IN lv_xml_data WITH |<LOGO>{ ls_logo-base64 }</LOGO>|.
          REPLACE ALL OCCURRENCES OF '<LOGO></LOGO>' IN lv_xml_data WITH |<LOGO>{ ls_logo-base64 }</LOGO>|.
        ENDIF.
      ENDIF.

*      DATA(index) = sy-tabix.
*      "change base
*      IF gt_logo IS NOT INITIAL.
*        READ TABLE gt_logo INTO DATA(ls_logo)
*            WITH TABLE KEY row = index.
*        IF sy-subrc = 0.
*          REPLACE ALL OCCURRENCES OF '<LOGO/>' IN lv_xml_data WITH |<LOGO>{ ls_logo-base64 }</LOGO>|.
*          REPLACE ALL OCCURRENCES OF '<LOGO></LOGO>' IN lv_xml_data WITH |<LOGO>{ ls_logo-base64 }</LOGO>|.
*        ENDIF.
*      ENDIF.


      lv_xml_data_string    = cl_web_http_utility=>encode_x_base64(
                                cl_web_http_utility=>encode_utf8( lv_xml_data )
                              ).
      lv_xml_data_xstring   = cl_web_http_utility=>decode_x_base64( lv_xml_data_string ).

      TRY.
          "render PDF
          cl_fp_ads_util=>render_pdf( EXPORTING iv_xml_data     = lv_xml_data_xstring
                                                iv_xdp_layout   = lv_xdp_layout
                                                iv_locale       = 'de_DE'
                                                is_options      = VALUE #( embed_fonts = 'X' )
                                      IMPORTING ev_pdf          = DATA(ev_pdf)
                                                ev_pages        = DATA(ev_pages)
                                                ev_trace_string = DATA(ev_trace_string)
                                               ).
          "add PDF will merge
          lv_pdf_merge->add_document( ev_pdf ).

        CATCH cx_fp_ads_util INTO DATA(lx_fp_ads_util).
          "handle exception
          DATA(lv_error) = lx_fp_ads_util->get_longtext( ).
      ENDTRY.
    ENDLOOP.

    CHECK ev_pdf IS NOT INITIAL.

    TRY.
        "merge PDF
        lv_return   = lv_pdf_merge->merge_documents( ).
        lv_pdf      = cl_web_http_utility=>encode_x_base64( lv_return ).
      CATCH cx_rspo_pdf_merger INTO DATA(lx_rspo_pdf_merger).
        "handle exception
        lv_error = lx_fp_ads_util->get_longtext( ).
    ENDTRY.

    o_pdf_string = lv_pdf.

    RETURN lv_return.
  ENDMETHOD.


  METHOD get_pdf.
    DATA: ls_respone TYPE ty_response.
    "request_data = request.
    /ui2/cl_json=>deserialize(
      EXPORTING
        json = request       " JSON string
      CHANGING
        data = request_data  " Data to serialize
    ).
    TRY.
        DATA(lv_response) = call_data(  ).
      CATCH cx_web_http_client_error.
        "handle exception
    ENDTRY.
*    xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
*   ( xco_cp_json=>transformation->camel_case_to_underscore ) ) )->write_to( REF #( ls_respone ) ).
*
    pdf64 = ls_respone-file_content.
    response = lv_response.
  ENDMETHOD.


  METHOD print_queue.

    "uncomment the following line for console output; prerequisite: code snippet is implementation of if_oo_adt_classrun~main
    "out->write( |response:  { lv_response }| ).

    cl_print_queue_utils=>create_queue_item_by_data(
      EXPORTING
        "Name of the print queue where result should be stored
        iv_qname            = iv_qname
        iv_print_data       = iv_print_data
        iv_name_of_main_doc = iv_name_of_main_doc
        iv_itemid           = iv_itemid
        iv_number_of_copies = iv_number_of_copies
      IMPORTING
        ev_err_msg          = ev_err_msg
      RECEIVING
        rv_itemid           = rv_itemid
    ).

  ENDMETHOD.


  METHOD get_queue.
    DATA: lv_itemid TYPE cl_print_queue_utils=>ty_itemid.

    DATA: ls_resp_data TYPE zst_resp_prt_queue.

    DATA: lv_url  TYPE string, "'https://my426501-api.s4hana.cloud.sap:443/sap/opu/odata/sap/API_CLOUD_PRINT_PULL_SRV/Get_PrintQueuesOfUser'
          lv_pref TYPE string.
    TRY.
        DATA(lv_host) = cl_abap_context_info=>get_system_url( ).
        SPLIT lv_host AT '.' INTO lv_host lv_pref.
        CONCATENATE lv_host `-api` `.` lv_pref INTO lv_host.
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    lv_url = |https://{ lv_host }:443/sap/opu/odata/sap/API_CLOUD_PRINT_PULL_SRV/Get_PrintQueuesOfUser|.

    TRY.
        "create http destination by url; API endpoint for API sandbox
        DATA(lo_http_destination) =
          cl_http_destination_provider=>create_by_url( lv_url ).

        "create HTTP client by destination
        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

        "adding headers
        DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
        lo_web_http_request->set_header_fields( VALUE #(
        ( name = 'config_authType'    value = 'Basic' )
        ( name = 'config_packageName' value = 'S4HANACloudABAPPlatform' )
        ( name = 'config_actualUrl'   value = |https://{ lv_host }:443/sap/opu/odata/sap/API_CLOUD_PRINT_PULL_SRV| )
        ( name = 'config_urlPattern'  value = 'https://{host}:{port}/sap/opu/odata/sap/API_CLOUD_PRINT_PULL_SRV' )
        ( name = 'config_apiName'     value = 'API_CLOUD_PRINT_PULL_SRV' )
        ( name = 'DataServiceVersion' value = '2.0' )
        ( name = 'Accept'             value = 'application/json' )
        ) ).

        DATA: lv_username TYPE string,
              lv_password TYPE string.

*-- Passing the Accept value in header which is a mandatory field
        lo_web_http_client->get_http_request( )->set_header_field( i_name = |username| i_value = lv_username ).
        lo_web_http_client->get_http_request( )->set_header_field( i_name = |password| i_value = lv_password ).

*-- Authorization
        lo_web_http_client->get_http_request( )->set_authorization_basic( i_username = lv_username i_password = lv_password ).
        lo_web_http_client->get_http_request( )->set_content_type( |text/xml;charset=UTF-8| ).

        lo_web_http_client->get_http_request( )->set_version( version = if_web_http_request=>co_protocol_version_1_1 ).

        "set request method and execute request
        DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>get ).
        DATA(lv_response) = lo_web_http_response->get_text( ).

        /ui2/cl_json=>deserialize(
          EXPORTING
            json        = lv_response
*           jsonx       =
            pretty_name = /ui2/cl_json=>pretty_mode-none
*           assoc_arrays     =
*           assoc_arrays_opt =
*           name_mappings    =
*           conversion_exits =
*           hex_as_base64    =
          CHANGING
            data        = ls_resp_data
        ).

        READ TABLE ls_resp_data-d-results INTO DATA(ls_results) WITH KEY qname = iv_qname.
        IF sy-subrc EQ 0.
          lv_itemid = ls_results-nrofnewitems + 1.
        ENDIF.

      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
        "error handling
    ENDTRY.

    rv_itemid = lv_itemid.
  ENDMETHOD.


  METHOD render_4_pq.

    DATA: lv_xdp_layout      TYPE xstring.

    SELECT SINGLE file_content
        FROM zcore_tb_temppdf
        WHERE id = @iv_rpid
        INTO @DATA(lv_file_content).

    lv_xdp_layout = lv_file_content.


    TRY.
        cl_fp_ads_util=>render_4_pq(
          EXPORTING
            iv_locale       = 'en_US'
            iv_pq_name      = iv_qname "<= Name of the print queue where result should be stored
            iv_xml_data     = iv_xml
            iv_xdp_layout   = lv_xdp_layout
            is_options      = VALUE #(
              trace_level = 4 "Use 0 in production environment
        )
          IMPORTING
            ev_trace_string = DATA(lv_trace)
            ev_pdl          = DATA(lv_pdf)
        ).
      CATCH cx_fp_ads_util.
        "handle exception
    ENDTRY.

    rv_pdf = lv_pdf.
  ENDMETHOD.


  METHOD print_pdf.
    DATA(lv_pdf_merge) = cl_rspo_pdf_merger=>create_instance( ).

    DATA: lv_xdp_layout TYPE xstring.
    DATA: lv_xml_final TYPE xstring.

*-- "Get template a
    SELECT SINGLE file_content
        FROM zcore_tb_temppdf
        WHERE id = @iv_rpid
        INTO @DATA(lv_xdp_file).

*    lv_xml_final   = cl_web_http_utility=>decode_x_base64( iv_xml ).
*    lv_xml_final = iv_xml.

*-- "Create PDF
    LOOP AT i_xml-data INTO DATA(l_xstring).
      lv_xml_final = l_xstring.

      lv_xdp_layout = lv_xdp_file.

      TRY.
          "render PDF
          cl_fp_ads_util=>render_pdf( EXPORTING iv_xml_data     = lv_xml_final
                                                iv_xdp_layout   = lv_xdp_layout
                                                iv_locale       = 'de_DE'
                                                is_options      = VALUE #( embed_fonts = 'X' )
                                      IMPORTING ev_pdf          = DATA(ev_pdf)
                                                ev_pages        = DATA(ev_pages)
                                                ev_trace_string = DATA(ev_trace_string)
                                               ).
          "add PDF will merge
          lv_pdf_merge->add_document( ev_pdf ).

        CATCH cx_fp_ads_util INTO DATA(lx_fp_ads_util).
          "handle exception
          DATA(lv_error) = lx_fp_ads_util->get_longtext( ).
      ENDTRY.

    ENDLOOP.

    DATA: lv_return           TYPE xstring.

    IF ev_pdf IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        "merge PDF
        lv_return   = lv_pdf_merge->merge_documents( ).
        lv_pdf      = cl_web_http_utility=>encode_x_base64( lv_return ).
      CATCH cx_rspo_pdf_merger INTO DATA(lx_rspo_pdf_merger).
        "handle exception
        lv_error = lx_fp_ads_util->get_longtext( ).
    ENDTRY.

    str_pdf = lv_pdf.

    rv_pdf = lv_return.

  ENDMETHOD.
ENDCLASS.

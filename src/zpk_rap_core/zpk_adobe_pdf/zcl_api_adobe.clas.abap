CLASS zcl_api_adobe DEFINITION
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

      BEGIN OF ty_response,
        file_content TYPE zde_adobe_attachment,
      END OF ty_response.

    METHODS: get_pdf IMPORTING request  TYPE string "ty_request
                     EXPORTING pdf64    TYPE string
                               response TYPE string.

    INTERFACES if_http_service_extension .
    CONSTANTS:
      method_post TYPE string VALUE 'POST',
      method_get  TYPE string VALUE 'GET'.

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

*    "table logo
*    TYPES: BEGIN OF ty_logo,
*             row    TYPE int1,
*             base64 TYPE string,
*             name   TYPE c LENGTH 50,
*           END OF   ty_logo.

*    DATA: gt_logo TYPE STANDARD TABLE OF ty_logo WITH KEY row,
*          gs_logo LIKE LINE OF gt_logo.

    DATA:
      request_method     TYPE string,
      request_body       TYPE string,
      request_data       TYPE ty_request,
      request_adobe_body TYPE string.

    DATA:
      response_data TYPE ty_response,
      response_body TYPE string,
      lv_pdf        TYPE string.

    METHODS:
      call_data RETURNING VALUE(respone) TYPE string
                RAISING
                          cx_web_http_client_error.
ENDCLASS.



CLASS ZCL_API_ADOBE IMPLEMENTATION.


  METHOD call_data.
    DATA:
      lv_xdp_layout       TYPE xstring,
      lv_xml_data_string  TYPE string,
      lv_xml_data_xstring TYPE xstring,
      lv_xml_data         TYPE string,
      lv_return           TYPE xstring.

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
          cl_fp_ads_util=>render_pdf( EXPORTING iv_xml_data      = lv_xml_data_xstring
                                                iv_xdp_layout    = lv_xdp_layout
                                                iv_locale        = 'de_DE'
                                                is_options       = VALUE #( embed_fonts = 'X' )
                                      IMPORTING ev_pdf           = DATA(ev_pdf)
                                                ev_pages         = DATA(ev_pages)
                                                ev_trace_string  = DATA(ev_trace_string)
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

    RETURN lv_pdf.
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
    xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
   ( xco_cp_json=>transformation->camel_case_to_underscore ) ) )->write_to( REF #( ls_respone ) ).
    pdf64 = ls_respone-file_content.
    response = lv_response.
  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    request_method = request->get_header_field( i_name = '~request_method' ).
    request_body = request->get_text( ).

    TRY.
        CASE request_method.
          WHEN method_post.

            TRY.
                xco_cp_json=>data->from_string( request_body )->apply( VALUE #(
              ( xco_cp_json=>transformation->camel_case_to_underscore )
              ( xco_cp_json=>transformation->boolean_to_abap_bool ) )
               )->write_to( REF #( request_data ) ).
                response->set_text( call_data( ) ).
              CATCH cx_root INTO DATA(lx_root).
                response->set_text( i_text = |{ lx_root->get_longtext( ) }| ).
                RETURN.
            ENDTRY.
          WHEN method_get.
        ENDCASE.
      CATCH cx_http_dest_provider_error.
        "handle exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

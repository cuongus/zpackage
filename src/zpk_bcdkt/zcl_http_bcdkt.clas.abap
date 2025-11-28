CLASS zcl_http_bcdkt DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-DATA: g_companycode TYPE string,
                g_ledger      TYPE string,
                g_fiscalYear  TYPE string,
                g_thang       TYPE string,
                g_loaibc      TYPE string,
                g_chitiet     TYPE string,
                lo_http_cl    TYPE REF TO zcl_http_bcdkt.
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_range TYPE TABLE OF ty_range_option,
           tt_data  TYPE TABLE OF zi_bcdkt.
    CLASS-METHODS:
      handle_clear,
      get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_http_bcdkt.

    CONSTANTS: c_header_content TYPE string VALUE 'content-type',
               c_content_type   TYPE string VALUE 'application/json, charset=utf-8'.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_BCDKT IMPLEMENTATION.


  METHOD get_instance.
    lo_http_cl = ro_instance = COND #( WHEN lo_http_cl IS BOUND
                                               THEN lo_http_cl
                                               ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD handle_clear.
    CLEAR: g_companycode, g_ledger, g_fiscalyear, g_thang, g_loaibc, g_chitiet.
  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    TYPES: BEGIN OF lty_split,
             string TYPE zde_char100,
           END OF lty_split.
    DATA: lt_split  TYPE TABLE OF lty_split,
          ir_bukrs  TYPE tt_range,
          ir_rldnr  TYPE tt_range,
          ir_gjahr  TYPE tt_range,
          ir_monat  TYPE tt_range,
          ir_type   TYPE tt_range,
          ir_detail TYPE tt_range.
    DATA: gt_data TYPE tt_data,
          lv_json TYPE string.
    me->get_instance( ).

    me->handle_clear( ).

    DATA: lt_parts TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    DATA(lv_req_body) = request->get_text( ).

    DATA(lv_method) = request->get_header_field( '~request_method' ).

    DATA(lv_uri) = request->get_header_field( '~request_uri' ).

    SPLIT lv_uri AT '?' INTO DATA(lv_path) DATA(lv_query_string).

    SPLIT lv_query_string AT '&' INTO TABLE lt_parts.

    LOOP AT lt_parts INTO DATA(lv_pair).
      SPLIT lv_pair AT '=' INTO DATA(lv_key) DATA(lv_val).
      CASE lv_key.
        WHEN 'companycode'.
          g_companycode = lv_val.
        WHEN 'ledger'.
          g_ledger = lv_val.
        WHEN 'fiscalyear'.
          g_fiscalyear = lv_val.
        WHEN 'thang'.
          g_thang = lv_val.
        WHEN 'loaibc'.
          g_loaibc = lv_val.
        WHEN 'chitiet'.
          g_chitiet = lv_val.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

    SPLIT g_companycode AT '%2C' INTO TABLE lt_split.
    LOOP AT lt_split INTO DATA(ls_split).
      APPEND VALUE #(  sign = 'I' option = 'EQ' low = ls_split-string ) TO ir_bukrs.
    ENDLOOP.
    SPLIT g_ledger AT '%2C' INTO TABLE lt_split.
    LOOP AT lt_split INTO ls_split.
      APPEND VALUE #(  sign = 'I' option = 'EQ' low = ls_split-string ) TO ir_rldnr.
    ENDLOOP.
    SPLIT g_fiscalyear AT '%2C' INTO TABLE lt_split.
    LOOP AT lt_split INTO ls_split.
      APPEND VALUE #(  sign = 'I' option = 'EQ' low = ls_split-string ) TO ir_gjahr.
    ENDLOOP.
    SPLIT g_thang AT '%2C' INTO TABLE lt_split.
    LOOP AT lt_split INTO ls_split.
      APPEND VALUE #(  sign = 'I' option = 'EQ' low = ls_split-string ) TO ir_monat.
    ENDLOOP.
    SPLIT g_loaibc AT '%2C' INTO TABLE lt_split.
    LOOP AT lt_split INTO ls_split.
      APPEND VALUE #(  sign = 'I' option = 'EQ' low = ls_split-string ) TO ir_type.
    ENDLOOP.
    SPLIT g_chitiet AT '%2C' INTO TABLE lt_split.
    LOOP AT lt_split INTO ls_split.
      APPEND VALUE #(  sign = 'I' option = 'EQ' low = ls_split-string ) TO ir_detail.
    ENDLOOP.

    DATA(lo_bcdkt) = zcl_jp_get_data_bcdkt=>get_instance( ).

    READ TABLE ir_rldnr INTO DATA(ls_rldnr) INDEX 1.
    IF ls_rldnr-low = '0L'.
      ls_rldnr-low = ''.
      APPEND ls_rldnr TO ir_rldnr.
    ENDIF.

    lo_bcdkt->process_data(
      EXPORTING
        ir_bukrs  = ir_bukrs
        ir_rldnr  = ir_rldnr
        ir_gjahr  = ir_gjahr
        ir_monat  = ir_monat
        ir_type   = ir_type
        ir_detail = ir_detail
      IMPORTING
        gt_data   = gt_data
    ).

    lv_json = xco_cp_json=>data->from_abap( gt_data )->apply( VALUE #(
    ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).

*** Response
    response->set_status('200').

*** Setup -> Response content-type json
    response->set_header_field( i_name = c_header_content
      i_value = c_content_type ).

    response->set_text( lv_json ).


  ENDMETHOD.
ENDCLASS.

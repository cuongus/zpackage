CLASS zcl_job_del_planned_order DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_apj_rt_run.
    INTERFACES if_oo_adt_classrun.  " chạ ai tin tôi là sẽ không thể debug cái job nếu không có interface này ;-;
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

*    DATA:
*      ir_plant TYPE RANGE OF i_plannedorder-ProductionPlant,
**          ir_sales_order TYPE RANGE OF i_plannedorder-SalesOrder,
*      ir_mrp   TYPE RANGE OF i_plannedorder-MRPController.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS: delete_planned_order
      IMPORTING iv_planned_order TYPE i_plannedorder-PlannedOrder.
ENDCLASS.



CLASS ZCL_JOB_DEL_PLANNED_ORDER IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
*    et_parameter_def = VALUE #(
**        ( selname = 'S_SALESO'
**        kind = if_apj_dt_exec_object=>select_option datatype = 'C'
**        length = 8
**        param_text = 'Sales Order'
**        changeable_ind = abap_true )
*
*        ( selname = 'S_PLANT'
*        kind = if_apj_dt_exec_object=>select_option datatype = 'C'
*        length = 4
*        param_text = 'Production Plant'
*        changeable_ind = abap_true )
*
*        ( selname = 'S_MRP'
*        kind = if_apj_dt_exec_object=>select_option datatype = 'C'
*        length = 3
*        param_text = 'MRP Controller'
*        changeable_ind = abap_true )
*        ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA: lt_order TYPE TABLE OF i_plannedorder,
          ls_order LIKE LINE OF lt_order.

*    LOOP AT it_parameters INTO DATA(ls_parameter).
*      CASE ls_parameter-selname.
**        WHEN 'S_SALESO'.
**          APPEND VALUE #( sign   = ls_parameter-sign
**                         option = ls_parameter-option
**                         low    = ls_parameter-low
**                         high   = ls_parameter-high ) TO ir_sales_order.
*
*        WHEN 'S_PLANT'.
*          APPEND VALUE #( sign = ls_parameter-sign
*                          option = ls_parameter-option
*                          low = ls_parameter-low
*                          high = ls_parameter-high ) TO ir_plant.
*
*        WHEN 'S_MRP'.
*          APPEND VALUE #( sign = ls_parameter-sign
*                          option = ls_parameter-option
*                          low = ls_parameter-low
*                          high = ls_parameter-high ) TO ir_mrp.
*      ENDCASE.
*    ENDLOOP.


*    SELECT * FROM i_plannedorder
*      WHERE SalesOrder IS INITIAL
*      AND MRPController IN @ir_mrp
*      AND ProductionPlant IN @ir_plant
*      INTO TABLE @lt_order.

    SELECT * FROM i_plannedorder
      WHERE SalesOrder IS INITIAL
      AND MRPController IN ( 201, 202, 203, 204, 205, 206, 207, 208, 211, 212, 213, 214, 215, 217, 220 )
      AND ProductionPlant IN ( 6711, 6712, 6721, 6722 )
      INTO TABLE @lt_order.

    IF lt_order IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_order INTO ls_order.
      delete_planned_order( iv_planned_order = ls_order-PlannedOrder ).
    ENDLOOP.

  ENDMETHOD.


  METHOD delete_planned_order.
    DATA: ls_api_auth    TYPE ztb_api_auth,
          ls_data        TYPE i_plannedorder,
          lv_pldorder    TYPE string,
          lv_pldorderhdr TYPE string,
          lv_url         TYPE string,
          lw_username    TYPE string,
          lw_password    TYPE string,
          lv_api_key     TYPE string VALUE 'GDkFoA6ElwZNhvwBAidM7Wq9tkxSL4hf',
          xcrsf_token    TYPE string,
          cookie         TYPE string.

    SELECT SINGLE * FROM ztb_api_auth
      WHERE systemid = 'CASLA'
      INTO @ls_api_auth.

    CHECK sy-subrc = 0.

    SELECT SINGLE * FROM i_plannedorder
      WHERE PlannedOrder = @iv_planned_order
      INTO @ls_data.

    CHECK sy-subrc = 0.

    lw_username = ls_api_auth-api_user.
    lw_password = ls_api_auth-api_password.
    lv_pldorder = ls_data-ProductionVersion.
    lv_pldorderhdr = ls_data-PlannedOrder.

    lv_url = |https://{ ls_api_auth-api_url }/sap/opu/odata4/sap/api_plannedorder/srvd_a2x/sap/plannedorder/{ lv_pldorder }/PlannedOrderHeader/{ lv_pldorderhdr }|.

    TRY.
        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( lv_url ).
        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
        DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).

        lo_web_http_request->set_header_fields( VALUE #(
           ( name = 'Accept'             value = 'application/json' )
           ( name = 'DataServiceVersion' value = '2.0' )
           ( name = 'Content-Type'       value = 'application/json' )
           ( name = 'x-csrf-token'       value = 'fetch' )
           ( name = 'username'           value = 'PB9_LO' )
           ( name = 'password'           value = 'Qwertyuiop@1234567890' )
        ) ).

        lo_web_http_request->set_authorization_basic(
          i_username = lw_username
          i_password = lw_password
        ).

        lo_web_http_request->set_header_field( i_name = 'APIKey' i_value = lv_api_key ).
        lo_web_http_request->set_header_field(
          i_name = 'config_actualUrl'
          i_value = |https://{ ls_api_auth-api_url }/sap/opu/odata4/sap/api_plannedorder/srvd_a2x/sap/plannedorder/{ lv_pldorder }|
        ).
        lo_web_http_request->set_header_field( i_name = 'config_apiName' i_value = |PLANNEDORDER_{ lv_pldorder }| ).
        lo_web_http_request->set_header_field( i_name = 'config_authType' i_value = 'Basic' ).
        lo_web_http_request->set_header_field( i_name = 'config_packageName' i_value = 'SAPS4HANACloud' ).
        lo_web_http_request->set_version( version = if_web_http_request=>co_protocol_version_1_1 ).

        DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>get ).

        xcrsf_token = lo_web_http_response->get_header_field( i_name = 'x-csrf-token' ).
        cookie = lo_web_http_response->get_header_field( i_name = 'set-cookie' ).

        IF xcrsf_token IS NOT INITIAL.
          lo_web_http_request->set_header_field( i_name = 'x-csrf-token' i_value = xcrsf_token ).

          IF cookie IS NOT INITIAL.
            lo_web_http_request->set_header_field( i_name = 'cookie' i_value = cookie ).
          ENDIF.

          lo_web_http_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

          lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>delete ).
          DATA(lv_status) = lo_web_http_response->get_status( )-code.
          DATA(lv_reason) = lo_web_http_response->get_status( )-reason.

        ENDIF.

      CATCH cx_root.

    ENDTRY.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
 "Khai báo biến job
    DATA(lo_job) = NEW zcl_job_del_planned_order( ).

    "Gọi trực tiếp method execute để test
    lo_job->if_apj_rt_exec_object~execute(
      EXPORTING
        it_parameters = VALUE #( )
    ).

    out->write( |Debug: Job Delete Planned Order executed.| ).
  ENDMETHOD.
ENDCLASS.

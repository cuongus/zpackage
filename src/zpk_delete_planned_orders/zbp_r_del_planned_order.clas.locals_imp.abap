CLASS lhc_ZrDelPlannedOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZrDelPlannedOrder RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ZrDelPlannedOrder RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ ZrDelPlannedOrder RESULT result.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR ACTION ZrDelPlannedOrder~delete.

ENDCLASS.

CLASS lhc_ZrDelPlannedOrder IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD delete.
    READ TABLE keys INTO DATA(k) INDEX 1.


    SELECT SINGLE * FROM ztb_api_auth
      WHERE systemid = 'CASLA'
      INTO @DATA(ls_api_auth).


    SELECT SINGLE * FROM i_plannedorder
      WHERE PlannedOrder = @k-planned_Order
      INTO @DATA(ls_data).

    DATA: lv_pldorder    TYPE string,
          lv_pldorderhdr TYPE string,
          lv_response    TYPE string,
          lw_username    TYPE string,
          lw_password    TYPE string,
          lv_api_key     TYPE string VALUE 'GDkFoA6ElwZNhvwBAidM7Wq9tkxSL4hf',
          xcrsf_token    TYPE string,
          cookie         TYPE string,
          status_code    TYPE i,
          reason         TYPE string,
          lv_body        TYPE string,
          error_message  TYPE string.


    lw_username = ls_api_auth-api_user.
    lw_password = ls_api_auth-api_password.


    lv_pldorder = ls_data-ProductionVersion.
    lv_pldorderhdr = ls_data-PlannedOrder.


    DATA(lv_url) = |https://{ ls_api_auth-api_url }/sap/opu/odata4/sap/api_plannedorder/srvd_a2x/sap/plannedorder/{ lv_pldorder }/PlannedOrderHeader/{ lv_pldorderhdr }|.

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


        lo_web_http_request->set_authorization_basic( i_username = lw_username i_password = lw_password ).


        lo_web_http_request->set_header_field( i_name = 'APIKey'         i_value = lv_api_key ).
        lo_web_http_request->set_header_field( i_name = 'config_actualUrl'
                                                i_value = |https://{ ls_api_auth-api_url }/sap/opu/odata4/sap/api_plannedorder/srvd_a2x/sap/plannedorder/{ lv_pldorder }| ).
        lo_web_http_request->set_header_field( i_name = 'config_apiName'     i_value = |PLANNEDORDER_{ lv_pldorder }| ).
        lo_web_http_request->set_header_field( i_name = 'config_authType'    i_value = 'Basic' ).
        lo_web_http_request->set_header_field( i_name = 'config_packageName' i_value = 'SAPS4HANACloud' ).

        lo_web_http_request->set_version( version = if_web_http_request=>co_protocol_version_1_1 ).


        DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>get ).


        xcrsf_token = lo_web_http_response->get_header_field( i_name = 'x-csrf-token' ).
        cookie = lo_web_http_response->get_header_field( i_name = 'set-cookie' ).



        IF xcrsf_token IS NOT INITIAL.

          " Set CSRF token in header for DELETE request
          lo_web_http_request->set_header_field( i_name = 'x-csrf-token' i_value = xcrsf_token ).


          IF cookie IS NOT INITIAL.
            lo_web_http_request->set_header_field( i_name = 'cookie' i_value = cookie ).
          ENDIF.


          lo_web_http_request->set_header_field( i_name = 'If-Match' i_value = '*' ).


          lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>delete ).


          status_code = lo_web_http_response->get_status( )-code.
          reason = lo_web_http_response->get_status( )-reason.
          lv_body = lo_web_http_response->get_text( ).
          lv_response = lv_body.


*          IF status_code = 204 OR status_code = 200.
*
*
*          ELSEIF status_code >= 400.
*
*
*          ENDIF.
*
*        ELSE.
*
*          error_message = 'Failed to retrieve CSRF token from server'.
*
        ENDIF.

      CATCH cx_root INTO DATA(lx_exception).

        error_message = lx_exception->get_text( ).



    ENDTRY.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZR_DEL_PLANNED_ORDER DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZR_DEL_PLANNED_ORDER IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zcr_od_2 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      update FOR MODIFY
        IMPORTING
          entities FOR UPDATE  zcr_od_2,
      delete FOR MODIFY
        IMPORTING
          keys FOR DELETE  zcr_od_2,
      read FOR READ
        IMPORTING
                  keys   FOR READ  zcr_od_2
        RESULT    result,
      rba_zcr_od_gc FOR READ
        IMPORTING
                  keys_rba FOR READ  zcr_od_2\_zcr_od_gc
                    FULL result_requested
        RESULT    result
                    LINK association_links,
      cba_zcr_od_21 FOR MODIFY
        IMPORTING
          entities_cba FOR CREATE  zcr_od_2\_zcr_od_21,
      rba_zcr_od_21 FOR READ
        IMPORTING
                  keys_rba FOR READ  zcr_od_2\_zcr_od_21
                    FULL result_requested
        RESULT    result
                    LINK association_links,
      cba_zcr_od_3 FOR MODIFY
        IMPORTING
          entities_cba FOR CREATE  zcr_od_2\_zcr_od_3,
      rba_zcr_od_3 FOR READ
        IMPORTING
                  keys_rba FOR READ  zcr_od_2\_zcr_od_3
                    FULL result_requested
        RESULT    result
                    LINK association_links,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR zcr_od_2 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zcr_od_2 RESULT result.

    METHODS Set_SL_DongBo FOR MODIFY
      IMPORTING keys FOR ACTION zcr_od_2~Set_SL_DongBo.
    METHODS Update_OD FOR MODIFY
      IMPORTING keys FOR ACTION zcr_od_2~Update_OD.
ENDCLASS.

CLASS lhc_zcr_od_2 IMPLEMENTATION.
  METHOD update.
  ENDMETHOD.
  METHOD delete.
  ENDMETHOD.
  METHOD read.
  ENDMETHOD.
  METHOD rba_zcr_od_gc.
  ENDMETHOD.
  METHOD cba_zcr_od_21.
  ENDMETHOD.
  METHOD rba_zcr_od_21.
  ENDMETHOD.
  METHOD cba_zcr_od_3.
  ENDMETHOD.
  METHOD rba_zcr_od_3.
  ENDMETHOD.
  METHOD get_instance_features.
    select * from zc_cr_od_2
      for all entries in @keys
      where Purchaseorder = @keys-Purchaseorder
        and Purchaseorderitem = @keys-Purchaseorderitem
        and Outbounddelivery = @keys-Outbounddelivery
        into table @DATA(lt_read_data_dtl).
    result = VALUE #( FOR ls_read_data_dtl IN lt_read_data_dtl
                   ( %tky-OutboundDelivery                           = ls_read_data_dtl-OutboundDelivery
                     %tky-Purchaseorder                             = ls_read_data_dtl-Purchaseorder
                     %tky-Purchaseorderitem                         = ls_read_data_dtl-Purchaseorderitem
                     %features-%action-Update_OD = COND #( WHEN ( ls_read_data_dtl-OverallGoodsMovementStatus <> 'A' )
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                  ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD Set_SL_DongBo.
    DATA: lt_cr TYPE TABLE FOR CREATE zr_tbcrod_2,
          ls_cr TYPE STRUCTURE FOR CREATE zr_tbcrod_2.
    DATA: lt_ud TYPE TABLE FOR UPDATE zr_tbcrod_2,
          ls_ud TYPE STRUCTURE FOR UPDATE zr_tbcrod_2.
    DATA: lw_count TYPE i.

*    READ TABLE keys INTO DATA(ls_key) INDEX 1.

*    READ ENTITIES OF zr_zcr_od_gc02tp IN LOCAL MODE
*      ENTITY zcr_od_2
*      ALL FIELDS
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_data_read).

    LOOP AT keys INTO DATA(ls_data).
      lw_count += 1.
      SELECT SINGLE * FROM zr_tbcrod_2
          WHERE Purchaseorder = @ls_data-Purchaseorder
            AND Purchaseorderitem = @ls_data-Purchaseorderitem
            AND Outbounddelivery = @ls_data-Outbounddelivery
           INTO @DATA(ls_ZR_TBCROD_2).
      IF sy-subrc IS NOT INITIAL.
        ls_cr-%cid = 'HDR' && lw_count.
        ls_cr-Outbounddelivery = ls_data-Outbounddelivery.
        ls_cr-Purchaseorder = ls_data-Purchaseorder.
        ls_cr-Purchaseorderitem = ls_data-Purchaseorderitem.
        ls_cr-Sldongbo = ls_data-%param-soluong.
        APPEND ls_cr TO lt_cr.
      ELSE.
        ls_ud-Outbounddelivery = ls_data-Outbounddelivery.
        ls_ud-Purchaseorder = ls_data-Purchaseorder.
        ls_ud-Purchaseorderitem = ls_data-Purchaseorderitem.
        ls_ud-Sldongbo = ls_data-%param-soluong.
        APPEND ls_ud TO lt_ud.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zr_tbcrod_2
     ENTITY ZrTbcrod2
       CREATE
             FIELDS ( Purchaseorderitem Purchaseorder Outbounddelivery Sldongbo )
               WITH lt_cr
               REPORTED DATA(update_reported1).
    MODIFY ENTITIES OF zr_tbcrod_2
     ENTITY ZrTbcrod2
       UPDATE
             FIELDS (  Sldongbo )
               WITH lt_ud
               REPORTED DATA(update_reported2).
    "return result entities
*    result = VALUE #( FOR ls_for IN keys ( %tky   = ls_for-%tky
*                                                  %param = ls_for ) ).
  ENDMETHOD.

  METHOD Update_OD.

    DATA: lw_username    TYPE string,
          lw_password    TYPE string,
          lv_json_header TYPE string,
          lv_json_item   TYPE string,
          lw_json_body   TYPE string,
          e_response     TYPE string,
          lv_response    TYPE string,
          lv_url         TYPE string,
          lv_url_get     TYPE string,
          e_code         TYPE i.
    DATA: lw_date  TYPE zde_Date,
          lw_count TYPE int4.

    SELECT SINGLE * FROM ztb_api_auth
      WHERE systemid = 'CASLA'
          INTO @DATA(ls_api_auth).

    lw_username = ls_api_auth-api_user.
    lw_password = ls_api_auth-api_password.
    LOOP AT keys INTO DATA(key).

      SELECT SINGLE * FROM zc_cr_od_2
        WHERE Purchaseorder = @key-Purchaseorder
           AND Purchaseorderitem = @key-Purchaseorderitem
           AND Outbounddelivery = @key-Outbounddelivery
        INTO @DATA(ls_ZC_CR_OD_2).

      SELECT * FROM zc_cr_od_21
        WHERE Purchaseorder = @key-Purchaseorder
            AND Purchaseorderitem = @key-Purchaseorderitem
            AND Outbounddelivery = @key-Outbounddelivery
        INTO TABLE @DATA(lt_ZC_CR_OD_21).

      lv_url = |https://{ ls_api_auth-api_url }/sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/$batch|.
      TRY.

          "ghép 2 mã json cùng body
          lw_json_body =
            |--batch_123\r\n|
            && |Content-Type: multipart/mixed; boundary=changeset\r\n|
            && |Odata-Version: 2.0\r\n|
            && |Odata-MaxVersion: 2.0\r\n\r\n|
            && |--changeset\r\n|
            && |Content-Type: application/http\r\n|
            && |Content-Transfer-Encoding: binary\r\n|
            && |Content-ID: 1\r\n\r\n|
            && |PATCH A_OutbDeliveryHeader('{ ls_ZC_CR_OD_2-OutboundDelivery }') HTTP/1.1\r\n|
            && |Content-Type: application/json\r\n|
            && |If-match: * \r\n\r\n|
            && |\{ "YY1_SLDongBo_DLH": "{ ls_ZC_CR_OD_2-sldongbo }", "YY1_ODGoc_DLH": "{ ls_ZC_CR_OD_2-OutboundDelivery }" \}|
            && |\r\n\r\n|
            && |--changeset\r\n|.
          lw_count = 1.
          LOOP AT lt_ZC_CR_OD_21 INTO DATA(ls_ZC_CR_OD_21).
            lw_count += 1.
            lw_json_body = lw_json_body && |Content-Type: application/http\r\n|
            && |Content-Transfer-Encoding: binary\r\n|
            && |Content-ID: { lw_count } \r\n\r\n|
            && |PATCH A_OutbDeliveryItem(|
            && |DeliveryDocument='{ ls_ZC_CR_OD_2-OutboundDelivery }',|
            && |DeliveryDocumentItem='{ ls_ZC_CR_OD_21-OutboundDeliveryItem }') HTTP/1.1\r\n|
            && |Content-Type: application/json\r\n|
            && |If-match: * \r\n\r\n|
            && |\{ "d": \{ "ActualDeliveryQuantity": "{ ls_ZC_CR_OD_21-SoLuong }" \}\}|
            && |\r\n\r\n|
            && |--changeset--\r\n|
            .
          ENDLOOP.

          lw_json_body = lw_json_body && |--batch_123--|.

          DATA(lo_http_destination_batch) =
                      cl_http_destination_provider=>create_by_url( lv_url ).
          DATA(lo_web_http_client_batch) =
               cl_web_http_client_manager=>create_by_http_destination( lo_http_destination_batch ).
          DATA(lo_web_http_request_batch) = lo_web_http_client_batch->get_http_request( ).
          lo_web_http_request_batch->set_header_fields( VALUE #(
             ( name = 'DataServiceVersion' value = '2.0' )
             ( name = 'Accept' value = 'application/json' )
          ) ).

          lo_web_http_request_batch->set_authorization_basic( i_username = lw_username i_password = lw_password ).
*          lo_web_http_request->set_content_type( |application/json| ).
          lo_web_http_request_batch->set_header_field( i_name = 'Accept' i_value = 'multipart/mixed' ).
          lo_web_http_request_batch->set_content_type( |multipart/mixed; boundary=batch_123| ).
          lo_web_http_request_batch->set_header_field( i_name = 'x-csrf-token' i_value = 'Fetch' ).
          DATA(lo_response_batch) = lo_web_http_client_batch->execute( i_method = if_web_http_client=>get ).
          DATA(lv_token_batch)    = lo_response_batch->get_header_field( 'x-csrf-token' ).

          lo_web_http_request_batch->set_header_field( i_name = 'x-csrf-token' i_value = lv_token_batch ).

          lo_web_http_request_batch->set_text( lw_json_body ).
          "set request method and execute request
          DATA(lo_web_http_response) = lo_web_http_client_batch->execute( if_web_http_client=>post ).
          lv_response = lo_web_http_response->get_text( ).

          /ui2/cl_json=>deserialize(
            EXPORTING json = lv_response
            CHANGING  data = e_response ).
          DATA(lv_status) = lo_web_http_response->get_status( ).
          e_code = lv_status-code.

        CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.

      ENDTRY.

      DATA: lv_success   TYPE abap_bool VALUE abap_true,
            lv_error_msg TYPE string,
            lv_line      TYPE string,
            lt_lines     TYPE STANDARD TABLE OF string.


      SPLIT lv_response AT cl_abap_char_utilities=>newline INTO TABLE lt_lines.

      LOOP AT lt_lines INTO lv_line.
        " Kiểm tra HTTP status
        IF lv_line CS 'HTTP/1.1 400'
        OR lv_line CS 'HTTP/1.1 404'
        OR lv_line CS 'HTTP/1.1 412'
        OR lv_line CS 'HTTP/1.1 500'
        OR lv_line CS 'HTTP/1.1 422'.
          lv_success = abap_false.
        ENDIF.

        IF lv_line CS '"message"'.
          FIND REGEX '"message"\s*:\s*"([^"]+)"' IN lv_line SUBMATCHES lv_error_msg.
        ENDIF.
      ENDLOOP.


      IF lv_success = abap_true.
        APPEND VALUE #(
         %tky = key-%tky
         %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-success
                   text     = |Update thành công.|
                 )
       ) TO reported-zcr_od_2.
      ELSE.
        APPEND VALUE #(
           %tky = key-%tky
           %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = |Update thất bại: { lv_error_msg }|
                   )
         ) TO reported-zcr_od_2.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

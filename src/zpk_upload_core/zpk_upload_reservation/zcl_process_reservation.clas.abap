CLASS zcl_process_reservation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF file_status,
        open      TYPE c LENGTH 1 VALUE 'M', "Not process
        accepted  TYPE c LENGTH 1 VALUE 'A', "Accepted
        rejected  TYPE c LENGTH 1 VALUE 'X', "Rejected
        completed TYPE c LENGTH 1 VALUE 'D', "Done
        inprocess TYPE c LENGTH 1 VALUE 'P', "In Process
        error     TYPE c LENGTH 1 VALUE 'E', "Error
        success   TYPE c LENGTH 1 VALUE 'S', "Success
      END OF file_status.

    TYPES:
      BEGIN OF ty_return,
        uuid    TYPE sysuuid_x16,
        msgid   TYPE string,
        msgno   TYPE symsgno,
        msgtext TYPE string,
        type    TYPE abap_boolean,
        v1      TYPE string,
        v2      TYPE string,
        v3      TYPE string,
        v4      TYPE string,
        v5      TYPE string,
      END OF ty_return,

      BEGIN OF ty_ranges,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE c LENGTH 50,
        high   TYPE c LENGTH 50,
      END OF ty_ranges,

      tt_gty_return     TYPE TABLE OF ty_return,
      tt_gty_ranges     TYPE STANDARD TABLE OF ty_ranges WITH EMPTY KEY,

      keys_post         TYPE TABLE FOR ACTION IMPORT zi_mn_reservation\\datafile~postreser,  "[ derived type... ]
      result_post       TYPE TABLE FOR ACTION RESULT zi_mn_reservation\\datafile~postreser, "[ derived type... ]

      tt_mapped_early   TYPE RESPONSE FOR MAPPED EARLY zi_mn_reservation,
      tt_failed_early   TYPE RESPONSE FOR FAILED EARLY zi_mn_reservation,
      tt_reported_early TYPE RESPONSE FOR REPORTED EARLY zi_mn_reservation.

    INTERFACES if_oo_adt_classrun.

    CLASS-METHODS: post_reservation
      IMPORTING keys     TYPE  keys_post
      CHANGING  result   TYPE result_post
                mapped   TYPE tt_mapped_early
                failed   TYPE tt_failed_early
                reported TYPE tt_reported_early
                e_return TYPE tt_gty_return,

      process_ranges IMPORTING i_string        TYPE string
                     RETURNING VALUE(e_ranges) TYPE tt_gty_ranges,

      call_external_api IMPORTING i_input       TYPE string
                        RETURNING VALUE(e_body) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PROCESS_RESERVATION IMPLEMENTATION.


  METHOD post_reservation.

    TYPES: BEGIN OF lty_item,
             product                        TYPE string,
             matlcomprequirementdate        TYPE string,
             plant                          TYPE string,
             goodsmovementisallowed         TYPE string,
             storagelocation                TYPE string,
             batch                          TYPE string,
             valuationtype                  TYPE string,
             entryunit                      TYPE string,
             reservationitemisfinallyissued TYPE string,
             reservationitmismarkedfordeltn TYPE string,
             resvnitmrequiredqtyinentryunit TYPE zui_reservation-quantity,
             yy1_salesorderitem_res         TYPE string,
             yy1_salesorderso_res           TYPE string,
           END OF lty_item,

           BEGIN OF lty_reservation,
             goodsmovementtype            TYPE string,
             costcenter                   TYPE string,
             issuingorreceivingplant      TYPE string,
             issuingorreceivingstorageloc TYPE string,
             reservationdate              TYPE string,
             ischeckedagainstfactorycal   TYPE string,
             _reservationdocumentitem     TYPE STANDARD TABLE OF lty_item WITH EMPTY KEY,
           END OF lty_reservation,

           BEGIN OF lty_res_item,
             reservation                    TYPE string,
             reservationitem                TYPE string,
             recordtype                     TYPE string,
             product                        TYPE string,
             requirementtype                TYPE string,
             matlcomprequirementdate        TYPE string,
             plant                          TYPE string,
             goodsmovementisallowed         TYPE string,
             storagelocation                TYPE string,
             batch                          TYPE string,
             valuationtype                  TYPE string,
             debitcreditcode                TYPE string,
             baseunit                       TYPE string,
             glaccount                      TYPE string,
             resvnaccountisenteredmanually  TYPE string,
             goodsmovementtype              TYPE string,
             entryunit                      TYPE string,
             supplier                       TYPE string,
             resvnitmrequiredqtyinbaseunit  TYPE string,
             reservationitemisfinallyissued TYPE string,
             reservationitmismarkedfordeltn TYPE string,
             resvnitmrequiredqtyinentryunit TYPE string,
             resvnitmwithdrawnqtyinbaseunit TYPE string,
             goodsrecipientname             TYPE string,
             unloadingpointname             TYPE string,
             reservationitemtext            TYPE string,
             confdqtyforatpinbaseuom        TYPE string,
             yy1_salesorderitem_res         TYPE string,
             yy1_salesorderitem_rest        TYPE string,
             yy1_salesorderso_res           TYPE string,
           END OF lty_res_item,

           BEGIN OF lty_response,
             documentsequenceno           TYPE zui_reservation-documentsequenceno,
             reservation                  TYPE string,
             goodsmovementtype            TYPE string,
             costcenter                   TYPE string,
             assetnumber                  TYPE string,
             assetsubnumber               TYPE string,
             issuingorreceivingplant      TYPE string,
             issuingorreceivingstorageloc TYPE string,
             salesorder                   TYPE string,
             salesorderitem               TYPE string,
             salesorderscheduleline       TYPE string,
             reservationdate              TYPE string,
             ischeckedagainstfactorycal   TYPE string,
             wbselement                   TYPE string,
             controllingarea              TYPE string,
             orderid                      TYPE string,
             userid                       TYPE string,
             creationdatetime             TYPE string,
             lastchangedbyuser            TYPE string,
             lastchangedatetime           TYPE string,
             resvnverificationcompanycode TYPE string,
             _reservationdocumentitem     TYPE STANDARD TABLE OF lty_res_item WITH EMPTY KEY,
           END OF lty_response.

*{
*    "error": {
*        "code": "M7/502",
*        "message": "Base date 10/02/2025 is earlier than current date 10/28/2025",
*        "target": "ReservationDate",
*        "@SAP__common.longtextUrl": "../../../../default/iwbep/common/0001/T100Longtexts(MessageClass='M7',MessageNumber='502',Variable1='10%2F02%2F2025',Variable2='10%2F28%2F2025',Variable3='',Variable4='')/Documentation",
*        "@SAP__common.ExceptionCategory": "Provider_Application_Error",
*        "details": [
*            {
*                "code": "M7/505",
*                "message": "Reqmnt date 10/02/2025 is earlier than current date 10/28/2025",
*                "target": "_ReservationDocumentItem(Reservation='75485',ReservationItem='1',RecordType='')/MatlCompRequirementDate",
*                "@SAP__common.longtextUrl": "../../../../default/iwbep/common/0001/T100Longtexts(MessageClass='M7',MessageNumber='505',Variable1='10%2F02%2F2025',Variable2='10%2F28%2F2025',Variable3='',Variable4='')/Documentation",
*                "@SAP__common.Severity": "warning",
*                "@SAP__common.numericSeverity": 3
*            }
*        ],
*        "innererror": {
*            "ErrorDetails": {
*                "@SAP__common.Application": {
*                    "ComponentId": "MM-IM-VDM-RSV",
*                    "ServiceRepository": "SRVD_A2X",
*                    "ServiceId": "API_RESERVATION_DOCUMENT_2",
*                    "ServiceVersion": "0001"
*                },
*                "@SAP__common.TransactionId": "963C5B3B2D410150E0069003D493D657",
*                "@SAP__common.Timestamp": "20251028070238.063017",
*                "@SAP__common.ErrorResolution": {
*                    "Analysis": "Use ADT feed reader \"SAP Gateway Error Log\" or run transaction /IWFND/ERROR_LOG on SAP Gateway hub system and search for entries with the timestamp above for more details",
*                    "Note": "See SAP Note 1797736 for error analysis (https://service.sap.com/sap/support/notes/1797736)"
*                }
*            }
*        }
*    }
*}

    TYPES:

      BEGIN OF lty_error,
        documentsequenceno TYPE zui_reservation-documentsequenceno,
        code               TYPE string,
        message            TYPE string,
        target             TYPE string,
      END OF lty_error,

      BEGIN OF lty_resp_error,
        error TYPE lty_error,
      END OF lty_resp_error.

    DATA: ls_reservation TYPE lty_reservation,
          ls_response    TYPE lty_response,
          lt_response    TYPE STANDARD TABLE OF lty_response WITH EMPTY KEY,

          ls_resp_error  TYPE lty_resp_error,
          ls_error       TYPE lty_error,
          lt_error       TYPE STANDARD TABLE OF lty_error WITH EMPTY KEY.

    DATA lt_mappings TYPE /ui2/cl_json=>name_mappings.

    lt_mappings = VALUE #(
      ( abap = 'GOODSMOVEMENTTYPE'              json = 'GoodsMovementType' )
      ( abap = 'ISSUINGORRECEIVINGPLANT'        json = 'IssuingOrReceivingPlant' )
      ( abap = 'ISSUINGORRECEIVINGSTORAGELOC'   json = 'IssuingOrReceivingStorageLoc' )
      ( abap = 'RESERVATIONDATE'                json = 'ReservationDate' )
      ( abap = 'ISCHECKEDAGAINSTFACTORYCAL'     json = 'IsCheckedAgainstFactoryCal' )
      ( abap = 'COSTCENTER'                     json = 'CostCenter' )
      ( abap = '_RESERVATIONDOCUMENTITEM'       json = '_ReservationDocumentItem' )
      ( abap = 'PRODUCT'                        json = 'Product' )
      ( abap = 'MATLCOMPREQUIREMENTDATE'        json = 'MatlCompRequirementDate' )
      ( abap = 'PLANT'                          json = 'Plant' )
      ( abap = 'GOODSMOVEMENTISALLOWED'         json = 'GoodsMovementIsAllowed' )
      ( abap = 'STORAGELOCATION'                json = 'StorageLocation' )
      ( abap = 'BATCH'                          json = 'Batch' )
      ( abap = 'VALUATIONTYPE'                  json = 'ValuationType' )
      ( abap = 'ENTRYUNIT'                      json = 'EntryUnit' )
      ( abap = 'RESERVATIONITEMISFINALLYISSUED' json = 'ReservationItemIsFinallyIssued' )
      ( abap = 'RESERVATIONITMISMARKEDFORDELTN' json = 'ReservationItmIsMarkedForDeltn' )
      ( abap = 'RESVNITMREQUIREDQTYINENTRYUNIT' json = 'ResvnItmRequiredQtyInEntryUnit' )
      ( abap = 'YY1_SALESORDERITEM_RES'         json = 'YY1_SalesOrderItem_RES' )
      ( abap = 'YY1_SALESORDERSO_RES'           json = 'YY1_SalesOrderSO_RES' )
    ).

    READ TABLE keys INDEX 1 INTO DATA(k).

    DATA(lr_docseq) = zcl_process_reservation=>process_ranges( i_string = k-%param-documentsequenceno ).
    DATA(lr_uuidfile) = zcl_process_reservation=>process_ranges( i_string = k-%param-uuidfile ).

    SELECT * FROM zi_data_reservation
    WHERE documentsequenceno IN @lr_docseq
      AND uuidfile IN @lr_uuidfile
      AND reservation EQ ''
    INTO TABLE @DATA(lt_data_reservation).
    IF sy-subrc EQ 0.

    ELSE.
      "Message lỗi
      APPEND VALUE #(
*        uuid    =
       msgid = 'ZUPRESER'
       msgno = '002'
*        msgtext
*        type
*        v1
*        v2
*        v3
*        v4
*        v5
      ) TO e_return.

      RETURN.
    ENDIF.

    SORT lt_data_reservation BY documentsequenceno ASCENDING.

    DATA: lv_header_filled TYPE abap_bool VALUE abap_false,
          ls_item          TYPE lty_item.

    LOOP AT lt_data_reservation ASSIGNING FIELD-SYMBOL(<row>) WHERE reservation IS INITIAL
        GROUP BY ( docseq      = <row>-documentsequenceno
                 ) ASCENDING
     REFERENCE INTO DATA(grp).
      CLEAR: lv_header_filled.

      " 1) Lấy record đầu nhóm làm header
      DATA(first) = grp->*.

      "Process Json
      LOOP AT GROUP grp INTO DATA(ls_grp).

        IF lv_header_filled = abap_false.
          ls_reservation-goodsmovementtype = ls_grp-goodsmovementtype.
*          ls_reservation-issuingorreceivingplant = ls_grp-plant.
          ls_reservation-issuingorreceivingstorageloc = ls_grp-receivingissuing.
          ls_reservation-costcenter = ls_grp-costcenter.

          DATA(lv_res_dats) = ls_grp-basedate.
          IF lv_res_dats IS INITIAL.
            lv_res_dats = sy-datlo.
          ENDIF.

          ls_reservation-reservationdate = |{ lv_res_dats+0(4) }-{ lv_res_dats+4(2) }-{ lv_res_dats+6(2) }|.
          ls_reservation-ischeckedagainstfactorycal = 'true'.

          "Flag Header
          lv_header_filled = abap_true.
        ENDIF.

        "Process Item
        ls_item-product                 = ls_grp-materialnumber.

        DATA(lv_dats) = ls_grp-requirementdate.
        IF lv_dats IS INITIAL.
          lv_dats = sy-datlo.
        ENDIF.

        ls_item-matlcomprequirementdate = |{ lv_dats+0(4) }-{ lv_dats+4(2) }-{ lv_dats+6(2) }|.

        ls_item-plant                   = ls_grp-plant.
        ls_item-goodsmovementisallowed  = 'true'.
        ls_item-storagelocation         = ls_grp-storagelocation.
        ls_item-batch                   = ls_grp-batch.
        ls_item-valuationtype           = ls_grp-valuationtype.
        ls_item-entryunit               = ls_grp-unitofmeasure.

        ls_item-reservationitemisfinallyissued = 'false'.
        ls_item-reservationitmismarkedfordeltn = 'false'.
        ls_item-resvnitmrequiredqtyinentryunit = ls_grp-quantity.

        IF ls_grp-salesorderitem IS NOT INITIAL.
          ls_item-yy1_salesorderitem_res         = ls_grp-salesorderitem.
        ENDIF.

        ls_item-yy1_salesorderso_res           = ls_grp-salesorder.

        APPEND ls_item TO ls_reservation-_reservationdocumentitem.
        CLEAR: ls_item.

      ENDLOOP.

      "Create Json
      /ui2/cl_json=>serialize(
        EXPORTING
          data          = ls_reservation
*         pretty_name   = /ui2/cl_json=>pretty_mode-low_case
          name_mappings = lt_mappings
        RECEIVING
          r_json        = DATA(lv_request)
      ).

      REPLACE ALL OCCURRENCES OF |"true"| IN lv_request WITH |true|.
      REPLACE ALL OCCURRENCES OF |"false"| IN lv_request WITH |false|.

      "Call External API.
      DATA(lv_response) = zcl_process_reservation=>call_external_api( i_input = lv_request ).

      "Read Json.
      /ui2/cl_json=>deserialize(
        EXPORTING
          json        = lv_response
*         jsonx       =
          pretty_name = /ui2/cl_json=>pretty_mode-none
*         assoc_arrays     =
*         assoc_arrays_opt =
*         name_mappings    =
*         conversion_exits =
*         hex_as_base64    =
        CHANGING
          data        = ls_response
      ).

      /ui2/cl_json=>deserialize(
        EXPORTING
          json        = lv_response
*         jsonx       =
          pretty_name = /ui2/cl_json=>pretty_mode-none
*         assoc_arrays     =
*         assoc_arrays_opt =
*         name_mappings    =
*         conversion_exits =
*         hex_as_base64    =
        CHANGING
          data        = ls_resp_error
      ).

      "Process Response.
      IF ls_response-reservation IS NOT INITIAL.
        ls_response-documentsequenceno = first-docseq.

        APPEND ls_response TO lt_response.

      ENDIF.

      IF ls_resp_error IS NOT INITIAL.
        ls_error-documentsequenceno = first-docseq.

        ls_error-code    = ls_resp_error-error-code.
        ls_error-message = ls_resp_error-error-message.
        ls_error-target  = ls_resp_error-error-target.

        APPEND ls_error TO lt_error.
      ENDIF.

      "clear variable.
      CLEAR: ls_response, ls_reservation, ls_error, ls_resp_error.
      CLEAR: lv_request, lv_response.
    ENDLOOP.

    SORT lt_response BY documentsequenceno ASCENDING.

** "" Success Post
    IF lt_response IS NOT INITIAL.
      LOOP AT lt_data_reservation ASSIGNING FIELD-SYMBOL(<ls_data_reservation>).

        READ TABLE lt_response INTO ls_response
        WITH KEY documentsequenceno = <ls_data_reservation>-documentsequenceno BINARY SEARCH.
        IF sy-subrc EQ 0.
          <ls_data_reservation>-reservation = ls_response-reservation.
          <ls_data_reservation>-messagetype = file_status-success.
          <ls_data_reservation>-messagetext = TEXT-001.
        ENDIF.

      ENDLOOP.
    ENDIF.

** "" Error Post
    IF lt_error IS NOT INITIAL.
      LOOP AT lt_data_reservation ASSIGNING <ls_data_reservation>.

        READ TABLE lt_error INTO ls_error
        WITH KEY documentsequenceno = <ls_data_reservation>-documentsequenceno BINARY SEARCH.
        IF sy-subrc EQ 0.

          <ls_data_reservation>-messagetype = file_status-error.
          <ls_data_reservation>-messagetext = ls_error-code && ` ` && ls_error-message && `\ ` && ls_error-target.
        ENDIF.

      ENDLOOP.
    ENDIF.

    DATA: lt_head_upd TYPE TABLE FOR UPDATE zi_mn_reservation,
          ls_head_upd LIKE LINE OF lt_head_upd,

          lt_item_upd TYPE TABLE FOR UPDATE zi_mn_reservation\\datafile,
          ls_item_upd LIKE LINE OF lt_item_upd.


    LOOP AT lt_data_reservation ASSIGNING FIELD-SYMBOL(<line>)
    GROUP BY ( uuidfile      = <line>-uuidfile
             ) ASCENDING
      REFERENCE INTO DATA(gr_udp).
      CLEAR: lv_header_filled.

      " 1) Lấy record đầu nhóm làm header
      DATA(first_h) = gr_udp->*.

      APPEND VALUE #(
          %key-uuid = first_h-uuidfile
          " ví dụ: đổi Status
          status    = file_status-inprocess     "inprocess
      ) TO lt_head_upd.

      LOOP AT GROUP gr_udp INTO DATA(ls_udp).
        APPEND VALUE #(
          %key-uuid   = ls_udp-uuid            " KHÓA CỦA ITEM
          reservation = ls_udp-reservation
          messagetype = ls_udp-messagetype
          messagetext = ls_udp-messagetext
        ) TO lt_item_upd.
      ENDLOOP.

    ENDLOOP.
** "" Modify Entity

    MODIFY ENTITIES OF zi_mn_reservation IN LOCAL MODE
      ENTITY managefile
        UPDATE FIELDS ( status )
        WITH lt_head_upd

      ENTITY datafile
        UPDATE FIELDS ( reservation messagetype messagetext )
        WITH lt_item_upd

      REPORTED DATA(lt_reported)
      FAILED   DATA(lt_failed).

  ENDMETHOD.


  METHOD process_ranges.

    DATA: lt_string TYPE TABLE OF string.
    SPLIT i_string AT ',' INTO TABLE lt_string.

    LOOP AT lt_string INTO DATA(lv_string).
      REPLACE ALL OCCURRENCES OF '-' IN lv_string WITH ''.
      TRANSLATE lv_string TO UPPER CASE.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_string ) TO e_ranges.
    ENDLOOP.

  ENDMETHOD.


  METHOD call_external_api.

    " Call External API
    DATA: lv_url  TYPE string,
          lv_pref TYPE string.
    " Replace with actual URL
    TRY.
        DATA(lv_host) = cl_abap_context_info=>get_system_url( ).
        SPLIT lv_host AT '.' INTO lv_host lv_pref.
        CONCATENATE lv_host `-api` `.` lv_pref INTO lv_host.
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    lv_url = |https://{ lv_host }/sap/opu/odata4/sap/api_reservation_document/srvd_a2x/sap/apireservationdocument/0001/ReservationDocument|.


    TRY.
        "create http destination by url; API endpoint for API sandbox
        DATA(lo_http_destination) =
          cl_http_destination_provider=>create_by_url(
          i_url = lv_url ).

        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_http_destination ).

*-- SET HTTP Header Fields

        lo_http_client->get_http_request( )->set_header_fields( VALUE #(
            ( name = 'Accept'             value = 'application/json' )
            ( name = 'DataServiceVersion' value = '2.0' )
            ( name = 'Content-Type'       value = 'application/json' )
            ( name = 'config_apiName'     value = 'CE_APIRESERVATIONDOCUMENT_0001' )
            ( name = 'x-csrf-token'       value = 'fetch' )
        ) ).

        DATA: lv_username TYPE string,
              lv_password TYPE string.

*        lv_username = `PB9_LO`.
*        lv_password = `Qwertyuiop@1234567890`.

        SELECT SINGLE * FROM ztb_api_auth INTO @DATA(ls_api_auth).
        IF sy-subrc EQ 0.
          lv_username = ls_api_auth-api_user.
          lv_password = ls_api_auth-api_password.
        ENDIF.

*-- Passing the Accept value in header which is a mandatory field
        lo_http_client->get_http_request( )->set_header_field( i_name = |username| i_value = lv_username ).
        lo_http_client->get_http_request( )->set_header_field( i_name = |password| i_value = lv_password ).
*-- Authorization
        lo_http_client->get_http_request( )->set_authorization_basic( i_username = lv_username i_password = lv_password ).
        lo_http_client->get_http_request( )->set_content_type( |application/json| ).

        lo_http_client->get_http_request( )->set_version( version = if_web_http_request=>co_protocol_version_1_1 ).

*-- Get x-csrf-token

        DATA(lo_web_http_response) = lo_http_client->execute( if_web_http_client=>get ).
        DATA(lv_response) = lo_web_http_response->get_text( ).

        DATA(xcrsf_token) = lo_web_http_response->get_header_field( i_name = 'x-csrf-token' ).
        DATA(cookie) = lo_web_http_response->get_header_field( i_name = 'set-cookie' ).

        IF xcrsf_token IS NOT INITIAL.
          lo_http_client->get_http_request( )->set_header_field( i_name = 'x-csrf-token'  i_value = xcrsf_token ).

          "Quan trọng: gửi lại cookie của response GET
          IF cookie IS NOT INITIAL.
            lo_http_client->get_http_request( )->set_header_field( i_name = 'set-cookie' i_value = cookie ).
          ENDIF.
        ENDIF.

*-- Send request ->
        lo_http_client->get_http_request( )->set_text( i_input ).
**-- POST
*-- Response ->
        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post
                                                     ).

        DATA(code) = lo_response->get_status( )-code.
        DATA(reason) = lo_response->get_status( )-reason.
        DATA(lv_body)  = lo_response->get_text( ).

      CATCH cx_root INTO DATA(lx_exception).

    ENDTRY.

    IF lv_body IS NOT INITIAL.
      e_body = lv_body.
    ELSE.
      e_body = ''.
    ENDIF.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

*    SELECT * FROM zui_reservation
*    INTO TABLE @DATA(lt_data).
*
*    DELETE zui_reservation FROM TABLE @lt_data.

  ENDMETHOD.
ENDCLASS.

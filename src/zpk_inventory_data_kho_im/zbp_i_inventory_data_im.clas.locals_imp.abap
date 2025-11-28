CLASS lhc_ZI_INVENTORY_DATA_IM DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.


    TYPES:

      BEGIN OF ty_range_option,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE string,
        high   TYPE string,
      END OF ty_range_option,

      tt_ranges TYPE TABLE OF ty_range_option,

      BEGIN OF ty_parameter_line,
        pid            TYPE string,
        pid_item       TYPE string,
        document_year  TYPE string,
        plant          TYPE string,
        store_location TYPE string,
        material       TYPE string,
        convert_sap_no TYPE string,
        pi_status      TYPE string,
        api_status     TYPE string,
        uuid           TYPE string,
      END OF ty_parameter_line,
      tt_parameters TYPE STANDARD TABLE OF ty_parameter_line WITH EMPTY KEY,

      BEGIN OF ty_template_download,
        pid              TYPE string,
        pid_item         TYPE string,
        documentyear     TYPE string,
        warehouse_number TYPE string,
        convert_sap_no   TYPE string,
        material         TYPE string,
        batch            TYPE string,
        sales_order      TYPE string,
        sales_order_item TYPE string,
        spe_stok_num     TYPE string,
        store_type       TYPE string,
        storage_bin      TYPE string,
        api_status       TYPE string,
        uuid             TYPE string,
      END OF ty_template_download,

      ty_t_template_download TYPE STANDARD TABLE OF ty_template_download WITH EMPTY KEY,

      BEGIN OF ty_file_upload,
        convert_sap_no       TYPE string,
        pid                  TYPE string,
        pid_item             TYPE string,
        fiscal_year          TYPE string,
        doc_date             TYPE string,
        plan_count_date      TYPE string,
        plant                TYPE string,
        storage_location     TYPE string,
        material             TYPE string,
        material_description TYPE string,
        batch                TYPE string,
        spe_stok             TYPE string,
        spe_stok_num         TYPE string,
        sales_order          TYPE string,
        sales_order_item     TYPE string,
        stock_type           TYPE string,
        book_qty             TYPE string,
        book_qty_uom         TYPE string,
        pda_qty              TYPE string,
        counted_qty          TYPE string,
        counted_qty_uom      TYPE string,
        entered_qty_pi       TYPE string,
        entered_qty_uom      TYPE string,
        zero_count           TYPE string,
        diff_qty             TYPE string,
        api_status           TYPE string,
        api_message          TYPE string,
        pda_date             TYPE string,
        pda_time             TYPE string,
        counter              TYPE string,
        api_date             TYPE string,
        api_time             TYPE string,
        pi_status            TYPE string,
        user_upload          TYPE string,
        upload_time          TYPE string,
        upload_date          TYPE string,
        upload_status        TYPE string,
        upload_message       TYPE string,
      END OF ty_file_upload,

      ty_t_file_upload TYPE STANDARD TABLE OF ty_file_upload WITH EMPTY KEY,

      BEGIN OF ty_s_message,
        msgty TYPE c LENGTH 1,  " Message Type (E, I, W, S, A, X)
        msgid TYPE sy-msgid,  " Message Class
        msgno TYPE sy-msgno,  " Message Number
        msgv1 TYPE sy-msgv1,  " Message Variable 1
        msgv2 TYPE sy-msgv2,  " Message Variable 2
        msgv3 TYPE sy-msgv3,  " Message Variable 3
        msgv4 TYPE sy-msgv4,  " Message Variable 4
        text  TYPE string,  " Final message text
      END OF ty_s_message,

      ty_t_messages        TYPE STANDARD TABLE OF ty_s_message WITH EMPTY KEY,

      tt_zc_inventory_data TYPE TABLE OF zc_inventory_data_im.

    CONSTANTS:
      BEGIN OF file_status,
        open      TYPE c LENGTH 1 VALUE 'M', "Not process
        accepted  TYPE c LENGTH 1 VALUE 'A', "Accepted
        rejected  TYPE c LENGTH 1 VALUE 'X', "Rejected
        completed TYPE c LENGTH 1 VALUE 'D', "Done
      END OF file_status.

    CONSTANTS c_excel_base TYPE d VALUE '18991230'.

    CONSTANTS: c_apiname  TYPE string VALUE '/sap/opu/odata/sap/API_PRODUCTION_ORDER_2_SRV',
               c_username TYPE string VALUE 'PB9_LO',
               c_password TYPE string VALUE 'Qwertyuiop@1234567890'.

    CONSTANTS: lc_crlf TYPE string VALUE cl_abap_char_utilities=>cr_lf.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zi_inventory_data_im.

    METHODS update FOR MODIFY
      IMPORTING keys FOR UPDATE zi_inventory_data_im.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_inventory_data_im RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zi_inventory_data_im.

    METHODS Count FOR MODIFY
      IMPORTING keys FOR ACTION zi_inventory_data_im~Count.
*
    METHODS CreatePI FOR MODIFY
      IMPORTING keys FOR ACTION zi_inventory_data_im~CreatePI RESULT result.
    .

    TYPES: BEGIN OF ty_document_key,
             docnum           TYPE ztb_inven_im1-pid,
             plant            TYPE werks_d,
             pid              TYPE belnr_d,
             piditem          TYPE mjahr,
             DocumantYear     TYPE gjahr,
             Uuid             TYPE string,
             Storage_location TYPE lgort_d,
             Material         TYPE matnr,
             ConvertSapNo     TYPE  ztb_inven_im1-convert_sap_no,
           END OF ty_document_key.

    TYPES: tt_doc_keys TYPE STANDARD TABLE OF ty_document_key WITH EMPTY KEY.


    METHODS DownloadFile FOR MODIFY
      IMPORTING keys FOR ACTION zi_inventory_data_im~DownloadFile RESULT result.

    METHODS UploadFile FOR MODIFY
      IMPORTING keys FOR ACTION zi_inventory_data_im~UploadFile.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_inventory_data_im RESULT result.

    METHODS UpdateCount FOR MODIFY
      IMPORTING keys FOR ACTION zi_inventory_data_im~UpdateCount RESULT result.

    METHODS convert_date IMPORTING i_date         TYPE string
                         RETURNING VALUE(rv_dats) TYPE string.

    METHODS data_valid_check
      IMPORTING
        iv_file_upload TYPE ty_file_upload
        iv_db_check    TYPE tt_zc_inventory_data
      EXPORTING
        e_respond      TYPE ty_file_upload.

    CLASS-DATA:
      ir_year     TYPE zcl_inventory_data_im=>tt_ranges,
      ir_pid      TYPE zcl_inventory_data_im=>tt_ranges,
      ir_plant    TYPE zcl_inventory_data_im=>tt_ranges,
      ir_pid_item TYPE zcl_inventory_data_im=>tt_ranges.


ENDCLASS.

CLASS lhc_ZI_INVENTORY_DATA_IM IMPLEMENTATION.

  METHOD create.
  ENDMETHOD.

  METHOD update.

*    DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
*    LOOP AT keys INTO DATA(ls_entity).
*      DATA(ls_ztb) = VALUE ztb_inven_im1(
*         pid                          = ls_entity-Pid
*         plant                        = ls_entity-Plant
*         pid_item                     = ls_entity-Pid_item
*         document_year                = ls_entity-DocumantYear
*         counted_qty                  = ls_entity-CountedQty
*         uuid = ls_entity-Uuid
*      ).
*
*      UPDATE ztb_inven_im1 SET counted_qty = @ls_ztb-counted_qty
*        WHERE pid   = @ls_ztb-pid
*          AND pid_item = @ls_ztb-pid_item
*          AND plant = @ls_ztb-plant
*          AND uuid = @ls_ztb-uuid
**          AND client       =  @sy-mandt
*          AND document_year    = @ls_ztb-document_year.
*
*      IF sy-subrc <> 0.
*        INSERT ztb_inven_im1 FROM @ls_ztb.
*
*      ENDIF.
*
*    ENDLOOP.
    LOOP AT keys INTO DATA(ls_entity).

      READ TABLE keys INDEX 1 INTO DATA(k).

      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%key-DocumantYear ) TO ir_year.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%key-Pid ) TO ir_pid.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%key-plant ) TO ir_plant.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-%key-Pid_item ) TO ir_pid_item.
      DATA:lv_pi_status TYPE string.

      SELECT
        *
          FROM i_physinvtrydocitem
          WHERE  plant IN @ir_plant
          AND FiscalYear IN @ir_year
          AND PhysicalInventoryDocument IN @ir_pid
          AND PhysicalInventoryDocumentItem IN   @ir_pid_item
          INTO TABLE @DATA(lt_data).

      READ TABLE lt_data INTO DATA(ls_data) INDEX 1.

      SELECT SINGLE
        *
         FROM i_physinvtrydocheader
         WHERE Plant = @ls_data-Plant
         AND StorageLocation = @ls_data-StorageLocation
         AND PhysicalInventoryDocument = @ls_data-PhysicalInventoryDocument
         INTO @DATA(lw_DOCHEADER).

      IF lw_DOCHEADER-PhysInvtryAdjustmentPostingSts = 'X'.
        lv_pi_status = 'Adjusted'.
      ELSEIF lw_DOCHEADER-PhysicalInventoryCountStatus = 'X' OR ls_data-PhysicalInventoryItemIsCounted = 'X'.
        lv_pi_status = 'Counted'.
      ELSEIF lw_DOCHEADER-PhysicalInventoryCountStatus = 'A' AND ls_data-QuantityInUnitOfEntry IS NOT INITIAL.
        lv_pi_status = 'Counted'.
      ELSEIF lw_DOCHEADER-PhysicalInventoryCountStatus = 'A' AND ls_data-QuantityInUnitOfEntry IS INITIAL.
        lv_pi_status = 'Not Counted'.
      ELSE.
        lv_pi_status = 'Not Counted'.
      ENDIF.

      IF lv_pi_status = 'Adjusted'.
        APPEND VALUE #(
          %tky = ls_entity-%tky
          %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = |Record này đã được Post, không thể chỉnh sửa.|
                  )
        ) TO reported-zi_inventory_data_im.

*        APPEND VALUE #( %tky = ls_entity-%tky )
*          TO failed-zi_inventory_data_im.
*        CONTINUE.
      ELSE.
        DATA(lv_check) = 'X'.
        SELECT SINGLE uuid
          FROM ztb_inven_im1
          WHERE pid            = @ls_entity-pid
            AND pid_item       = @ls_entity-pid_item
            AND document_year  = @ls_entity-DocumantYear
            AND plant          = @ls_entity-Plant
          INTO @DATA(lv_existing_uuid).

        IF sy-subrc = 0.

          UPDATE ztb_inven_im1 SET counted_qty = @ls_entity-countedqty , edit = @lv_check
            WHERE uuid = @lv_existing_uuid.

        ELSE.

          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
          DATA(ls_ztb) = VALUE ztb_inven_im1(
            uuid           = lv_uuid
*            client         = sy-mandt
            pid            = ls_entity-pid
            pid_item       = ls_entity-pid_item
            document_year  = ls_entity-DocumantYear
            plant          = ls_entity-Plant
            counted_qty    = ls_entity-countedqty
            edit = lv_check
          ).

          INSERT ztb_inven_im1 FROM @ls_ztb.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD Count.

    TYPES: BEGIN OF ty_physinv_d,
             _Material                      TYPE matnr,           " Mã vật tư
             _Batch                         TYPE charg_d,         " Lô hàng
             InventorySpecialStockType      TYPE char1,           " Loại tồn kho đặc biệt (E/K/Q...)
             PhysicalInventoryStockType     TYPE char1,           " Loại tồn kho kiểm kê
             SalesOrder                     TYPE vbeln_va,        " Đơn hàng bán
             SalesOrderItem                 TYPE posnr_va,        " Dòng đơn hàng
             Supplier                       TYPE lifnr,           " Nhà cung cấp (có thể rỗng)
             Customer                       TYPE kunnr,           " Khách hàng (có thể rỗng)
             CountedByUser                  TYPE syuname,         " Người đếm
             PhysicalInventoryLastCountDate TYPE string,         " Dạng "/Date(…)/"
             Quantity                       TYPE string,
             PhysicalInventoryItemIsZero    TYPE abap_bool,         " Dạng chuỗi vì API nhận JSON text
             _Unit_Of_Entry                 TYPE meins,           " Đơn vị
             _Quantity_In_Unit_Of_Entry     TYPE string,

           END OF ty_physinv_d.

    TYPES: BEGIN OF ty_physinv,
             d TYPE ty_physinv_d,
           END OF ty_physinv.

    DATA: lw_username TYPE string,
          lw_password TYPE string,
          ls_physinv  TYPE ty_physinv,
          e_response  TYPE string,
          gs_data     TYPE zc_inventory_data_im,
          e_code      TYPE i.
    DATA: lw_date TYPE zde_Date.

    LOOP AT keys INTO DATA(key).
*    READ TABLE lt_data INTO DATA(ls_data) INDEX 1.
      DATA:lv_pi_status TYPE string.

      SELECT SINGLE
   *
         FROM i_physinvtrydocitem
         WHERE  plant = @key-plant
         AND FiscalYear = @key-DocumantYear
         AND PhysicalInventoryDocument = @key-Pid
         AND PhysicalInventoryDocumentItem = @key-pid_item
         INTO @DATA(ls_data).

      SELECT SINGLE
     *
      FROM i_physinvtrydocheader
      WHERE Plant = @ls_data-Plant
      AND StorageLocation = @ls_data-StorageLocation
      AND PhysicalInventoryDocument = @ls_data-PhysicalInventoryDocument
      INTO @DATA(lw_DOCHEADER).


      IF lw_DOCHEADER-PhysInvtryAdjustmentPostingSts = 'X'.
        lv_pi_status = 'Adjusted'.
      ELSEIF lw_DOCHEADER-PhysicalInventoryCountStatus = 'X' OR ls_data-PhysicalInventoryItemIsCounted = 'X'.
        lv_pi_status = 'Counted'.
      ELSEIF lw_DOCHEADER-PhysicalInventoryCountStatus = 'A' AND ls_data-QuantityInUnitOfEntry IS NOT INITIAL.
        lv_pi_status = 'Counted'.
      ELSEIF lw_DOCHEADER-PhysicalInventoryCountStatus = 'A' AND ls_data-QuantityInUnitOfEntry IS INITIAL.
        lv_pi_status = 'Not Counted'.
      ELSE.
        lv_pi_status = 'Not Counted'.
      ENDIF.

      SELECT SINGLE counted_qty,pda_qty,edit,api_status
                  FROM ztb_inven_im1
                  WHERE pid        = @key-Pid
                    AND pid_item  = @key-pid_item
                    AND document_year  = @key-DocumantYear
                  INTO @DATA(ls_inven_im1).



      DATA: lv_zero  TYPE abap_bool,
            lv_count TYPE string.

      IF ls_inven_im1-api_status = 'S' AND ls_inven_im1-edit <> 'X'.
        lv_count = ls_inven_im1-pda_qty.
        IF ls_inven_im1-pda_qty = 0.
          lv_zero = abap_true.
        ELSE.
          lv_zero = abap_false.
        ENDIF.

      ELSEIF ls_inven_im1-edit = 'X' AND ls_inven_im1-api_status <> 'S'.
        lv_count = ls_inven_im1-counted_qty.
        IF ls_inven_im1-counted_qty = 0.
          lv_zero = abap_true.
        ELSE.
          lv_zero = abap_false.
        ENDIF.

      ELSEIF ls_inven_im1-edit = 'X' AND ls_inven_im1-api_status = 'S'.
        lv_count = ls_inven_im1-counted_qty.
        IF ls_inven_im1-counted_qty = 0.
          lv_zero = abap_true.
        ELSE.
          lv_zero = abap_false.
        ENDIF.

      ENDIF.

      DATA: lv_tsl       TYPE timestampl,
            lv_epoch     TYPE timestampl VALUE '19700101000000',
            lv_diff      TYPE decfloat34,
            lv_ms        TYPE p LENGTH 16 DECIMALS 0,
            rv_json_date TYPE string.

      SELECT SINGLE count_date,convert_sap_no,pi_status,edit,upload_status,api_status
FROM ztb_inven_im1
WHERE  plant = @key-plant
  AND document_year = @key-DocumantYear
  AND pid = @key-Pid
  AND pid_item = @key-pid_item
  INTO @DATA(ls_im1).

      IF ls_im1-api_status = 'S'.
        lv_tsl = |{ ls_im1-count_date }000000|.

        lv_diff = cl_abap_tstmp=>subtract(
                     tstmp1 = lv_tsl
                     tstmp2 = lv_epoch ).

        lv_ms = lv_diff * 1000.

        rv_json_date = |/Date({ lv_ms })/|.

      ELSEIF ls_im1-edit = 'X'.
        lv_tsl = |{ ls_im1-count_date }000000|.

        lv_diff = cl_abap_tstmp=>subtract(
                     tstmp1 = lv_tsl
                     tstmp2 = lv_epoch ).

        lv_ms = lv_diff * 1000.

        rv_json_date = |/Date({ lv_ms })/|.
      ELSEIF ls_im1-upload_status = 'S'.
        lv_tsl = |{ ls_im1-count_date }000000|.

        lv_diff = cl_abap_tstmp=>subtract(
                     tstmp1 = lv_tsl
                     tstmp2 = lv_epoch ).

        lv_ms = lv_diff * 1000.

        rv_json_date = |/Date({ lv_ms })/|.
      ELSE.

        lv_tsl = |{ ls_data-PhysicalInventoryLastCountDate }000000|.

        lv_diff = cl_abap_tstmp=>subtract(
                     tstmp1 = lv_tsl
                     tstmp2 = lv_epoch ).

        lv_ms = lv_diff * 1000.

        rv_json_date = |/Date({ lv_ms })/|.
      ENDIF.


      lw_date = xco_cp=>sy->moment( xco_cp_time=>time_zone->user )->date->as( xco_cp_time=>format->abap )->value.
      ls_physinv-d-_material                       = ls_data-material.
      ls_physinv-d-_batch                          = ls_data-batch.
*    ls_physinv-d-inventoryspecialstocktype      = ls_data-inventoryspecialstocktype.
*    ls_physinv-d-physicalinventorystocktype     = ls_data-physicalinventorystocktype.
*    ls_physinv-d-salesorder                     = ls_data-salesorder.
*    ls_physinv-d-salesorderitem                 = ls_data-salesorderitem.
*    ls_physinv-d-countedbyuser                  = sy-uname.
*      ls_physinv-d-physicalinventorylastcountdate = zcl_utility=>to_json_date( iv_date = ls_count_date ).
      ls_physinv-d-physicalinventorylastcountdate = rv_json_date.
*    '/Date(1760058000000)/'.
      ls_physinv-d-physicalinventoryitemiszero = lv_zero.
      ls_physinv-d-_unit_of_entry                    = ls_data-unitofentry.
      ls_physinv-d-_quantity_in_unit_of_entry          = lv_count .
      CONDENSE ls_physinv-d-_quantity_in_unit_of_entry NO-GAPS.

      DATA(lw_json_body) = /ui2/cl_json=>serialize(
                      data = ls_physinv
                      compress = abap_true
                      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

      REPLACE ALL OCCURRENCES OF 'physicalinventorylastcountdate'
         IN lw_json_body WITH 'PhysicalInventoryLastCountDate'.
      REPLACE ALL OCCURRENCES OF 'physicalinventoryitemiszero'
      IN lw_json_body WITH 'PhysicalInventoryItemIsZero'.

      DATA: lo_http_client  TYPE REF TO if_web_http_client,
            response        TYPE string,
            lv_response     TYPE string,
*          lv_token        TYPE string,
            lv_url          TYPE string,
            lv_doc          TYPE string,
            lv_item         TYPE string,
            lv_year         TYPE string,
            ls_odata_return TYPE zst_odata_return.

      SELECT SINGLE * FROM ztb_api_auth
    WHERE systemid = 'CASLA'
  INTO @DATA(ls_api_auth).

      lw_username = ls_api_auth-api_user.
      lw_password = ls_api_auth-api_password.

      lv_doc        = ls_data-PhysicalInventoryDocument.
      lv_item       = ls_data-PhysicalInventoryDocumentItem.
      lv_year       = ls_data-FiscalYear.

      lv_url = |https://{ ls_api_auth-api_url }/sap/opu/odata/sap/API_PHYSICAL_INVENTORY_DOC_SRV/|
              && |A_PhysInventoryDocItem(FiscalYear='{ lv_year }',|
              && |PhysicalInventoryDocument='{ lv_doc }',|
              && |PhysicalInventoryDocumentItem='{ lv_item }')|.

      TRY.

          DATA(lo_http_destination) =
               cl_http_destination_provider=>create_by_url( lv_url ).
          DATA(lo_web_http_client) =
               cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
          DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
          lo_web_http_request->set_header_fields( VALUE #(
             ( name = 'DataServiceVersion' value = '2.0' )
             ( name = 'Accept' value = 'application/json' )
          ) ).

          "Authorization
          lo_web_http_request->set_header_field(  i_name = 'username' i_value = 'PB9_LO' ).
          lo_web_http_request->set_header_field(  i_name = 'password' i_value = 'Qwertyuiop@1234567890' ).

          lo_web_http_request->set_authorization_basic( i_username = lw_username i_password = lw_password ).
          lo_web_http_request->set_content_type( |application/json| ).
          lo_web_http_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
          lo_web_http_request->set_header_field( i_name = 'x-csrf-token' i_value = 'Fetch' ).
          lo_web_http_request->set_header_field( i_name = 'If-Match' i_value = '' ).

          DATA(lo_response) = lo_web_http_client->execute( i_method = if_web_http_client=>get ).
          DATA(lv_token)    = lo_response->get_header_field( 'x-csrf-token' ).
          DATA(lv_Match)    = lo_response->get_header_field( 'etag' ).
          lo_web_http_request->set_header_field( i_name = 'x-csrf-token' i_value = lv_token ).
          lo_web_http_request->set_header_field( i_name = 'If-Match' i_value = lv_Match ).

          lo_web_http_request->set_text( lw_json_body ).
          "set request method and execute request
          DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>patch ).
          lv_response = lo_web_http_response->get_text( ).

          /ui2/cl_json=>deserialize(
            EXPORTING json = lv_response
            CHANGING  data = e_response ).
          DATA(lv_status) = lo_web_http_response->get_status( ).
          e_code = lv_status-code.

        CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.

      ENDTRY.

      IF lv_pi_status = 'Adjusted'.
        APPEND VALUE #(
           %tky = key-%tky
           %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-success
                     text     = |Record này đã được Post, không thể chỉnh sửa|
                   )
         ) TO reported-zi_inventory_data_im.

      ELSE.

        IF lv_response IS INITIAL.
          APPEND VALUE #(
            %tky = key-%tky
            %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-success
                      text     = |Đã Count thành công.|
                    )
          ) TO reported-zi_inventory_data_im.
        ELSE.
          APPEND VALUE #(
            %tky = key-%tky
            %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-error
                      text     = |Count thất bại: { lv_response }|
                    )
          ) TO reported-zi_inventory_data_im.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD CreatePi.

    TYPES: BEGIN OF ty_physinv_item,
             FiscalYear                     TYPE string,
             PhysicalInventoryDocumentItem  TYPE string,
             Material                       TYPE string,
             Batch                          TYPE string,
             InventorySpecialStockType      TYPE string,
             SalesOrder                     TYPE string,
             SalesOrderItem                 TYPE string,
             Supplier                       TYPE string,
             Customer                       TYPE string,
             WBSElement                     TYPE string,
             LastChangeUser                 TYPE string,
             LastChangeDate                 TYPE string,
             CountedByUser                  TYPE string,
             PhysicalInventoryLastCountDate TYPE string,
             AdjustmentPostingMadeByUser    TYPE string,
             PostingDate                    TYPE string,
             PhysicalInventoryItemIsCounted TYPE abap_bool,
             PhysInvtryDifferenceIsPosted   TYPE abap_bool,
             PhysInvtryItemIsRecounted      TYPE abap_bool,
             PhysInvtryItemIsDeleted        TYPE abap_bool,
             IsHandledInAltvUnitOfMsr       TYPE abap_bool,
             CycleCountType                 TYPE string,
             IsValueOnlyMaterial            TYPE abap_bool,
             PhysInventoryReferenceNumber   TYPE string,
             MaterialDocument               TYPE string,
             MaterialDocumentYear           TYPE string,
             MaterialDocumentItem           TYPE string,
             PhysInvtryRecountDocument      TYPE string,
             PhysicalInventoryItemIsZero    TYPE abap_bool,
             ReasonForPhysInvtryDifference  TYPE string,
             BookQtyBfrCountInMatlBaseUnit  TYPE string,
             Quantity                       TYPE string,
             QuantityInUnitOfEntry          TYPE string,

           END OF ty_physinv_item.

    TYPES: ty_t_physinv_item TYPE STANDARD TABLE OF ty_physinv_item WITH EMPTY KEY.

    TYPES : BEGIN OF ty_results,
              results TYPE ty_t_physinv_item,
            END OF ty_results.

    TYPES: BEGIN OF ty_physinv_header,
             FiscalYear                    TYPE string,
             InventoryTransactionType      TYPE string,
             Plant                         TYPE string,
             StorageLocation               TYPE string,
             InventorySpecialStockType     TYPE string,
             DocumentDate                  TYPE string,
             PhysInventoryPlannedCountDate TYPE string,
             Physicalitem                  TYPE ty_results,
*             results                          TYPE ty_physinv_d,
           END OF ty_physinv_header.

    DATA: lw_username TYPE string,
          lw_password TYPE string,
*          ls_physinv  TYPE ty_physinv_header,
          e_response  TYPE string,
          gs_data     TYPE zc_inventory_data_im,
          e_code      TYPE i,
          lw_date     TYPE zde_Date.

    DATA: ls_physinv   TYPE ty_physinv_header,
          ls_physinv_1 TYPE ty_physinv_header,
          ls_item      TYPE ty_physinv_item,
          lt_items     TYPE ty_t_physinv_item.


    DATA: lt_doc_keys TYPE tt_doc_keys,
          ls_doc_key  TYPE ty_document_key,
          lt_plant    TYPE TABLE OF string,
          lt_pid      TYPE TABLE OF string,
          lt_pid_item TYPE TABLE OF string,
          lt_year     TYPE TABLE OF string,
          lt_uuid     TYPE TABLE OF string,
          lt_stloc    TYPE TABLE OF string,
          lt_sapno    TYPE TABLE OF string,
          lt_mat      TYPE TABLE OF string.


    READ TABLE keys INDEX 1 INTO DATA(k).

    "=== Split từng parameter (chuỗi CSV) ===
    IF k-%param-Plant IS NOT INITIAL AND k-%param-Plant NE 'null'.
      SPLIT k-%param-Plant AT ',' INTO TABLE lt_plant.
    ENDIF.

*    IF k-%param-Pid IS NOT INITIAL AND k-%param-Pid NE 'null'.
*      SPLIT k-%param-Pid AT ',' INTO TABLE lt_pid.
*    ENDIF.
*
*    IF k-%param-Piditem IS NOT INITIAL AND k-%param-Piditem NE 'null'.
*      SPLIT k-%param-Piditem AT ',' INTO TABLE lt_pid_item.
*    ENDIF.

    IF k-%param-DocumantYear IS NOT INITIAL AND k-%param-DocumantYear NE 'null'.
      SPLIT k-%param-DocumantYear AT ',' INTO TABLE lt_year.
    ENDIF.

    IF k-%param-ConvertSapNo IS NOT INITIAL AND k-%param-ConvertSapNo NE 'null'.
      SPLIT k-%param-ConvertSapNo AT ',' INTO TABLE lt_sapno.
    ENDIF.

    IF k-%param-Storagelocation IS NOT INITIAL AND k-%param-Storagelocation NE 'null'.
      SPLIT k-%param-Storagelocation AT ',' INTO TABLE lt_stloc.
    ENDIF.

    IF k-%param-Material IS NOT INITIAL AND k-%param-Material NE 'null'.
      SPLIT k-%param-Material AT ',' INTO TABLE lt_mat.
    ENDIF.

    DATA: lv_plant        TYPE string,
          lv_year_1       TYPE string,
          lv_uuid         TYPE string,
          lv_sapno        TYPE string,
          lv_stloc        TYPE string,
          lv_mat          TYPE string,
          lv_tmp          TYPE string,
          lv_fy_str       TYPE string,
          lv_header_built TYPE abap_bool VALUE abap_false,
          lv_index        TYPE i.


*    " Plant
*    IF lines( lt_plant ) <> lines( lt_sapno ).
*      IF lines( lt_plant ) = 1.
*        READ TABLE lt_plant INDEX 1 INTO lv_plant.
*        CLEAR lt_plant.
*        DO lines( lt_sapno ) TIMES.
*          APPEND lv_plant TO lt_plant.
*        ENDDO.
*      ELSE.
*
*      ENDIF.
*    ENDIF.
*
*    " Storage Location
*    IF lines( lt_stloc ) <> lines( lt_sapno ).
*      IF lines( lt_stloc ) = 1.
*        READ TABLE lt_stloc INDEX 1 INTO lv_stloc.
*        CLEAR lt_stloc.
*        DO lines( lt_sapno ) TIMES.
*          APPEND lv_stloc TO lt_stloc.
*        ENDDO.
*      ELSE.
*
*      ENDIF.
*    ENDIF.
*
*    " Document Year
*    IF lines( lt_year ) <> lines( lt_sapno ).
*      IF lines( lt_year ) = 1.
*        READ TABLE lt_year INDEX 1 INTO lv_year_1.
*        CLEAR lt_year.
*        DO lines( lt_sapno ) TIMES.
*          APPEND lv_year_1 TO lt_year.
*        ENDDO.
*      ELSE.
*
*      ENDIF.
*    ENDIF.
*
*    " Material
*    IF lines( lt_mat ) <> lines( lt_sapno ).
*      IF lines( lt_mat ) = 1.
*        READ TABLE lt_mat INDEX 1 INTO lv_mat.
*        CLEAR lt_mat.
*        DO lines( lt_sapno ) TIMES.
*          APPEND lv_mat TO lt_mat.
*        ENDDO.
*      ELSE.
*
*      ENDIF.
*    ENDIF.
*
*    IF lt_sapno IS NOT INITIAL.
*
*      CLEAR lt_doc_keys.
*      lv_index = 0.
*
*      LOOP AT lt_sapno INTO lv_sapno.
*        lv_index = lv_index + 1.
*
*        READ TABLE lt_year  INDEX lv_index INTO lv_year_1.
*        READ TABLE lt_stloc INDEX lv_index INTO lv_stloc.
*        READ TABLE lt_mat   INDEX lv_index INTO lv_mat.
*        READ TABLE lt_plant INDEX lv_index INTO lv_plant.
*
*        CONDENSE: lv_plant NO-GAPS,
*                  lv_year_1 NO-GAPS,
*                  lv_sapno NO-GAPS,
*                  lv_stloc NO-GAPS,
*                  lv_mat NO-GAPS.
*
*        CLEAR ls_doc_key.
*        ls_doc_key-plant             = lv_plant.
*        ls_doc_key-documantyear      = lv_year_1.
*        ls_doc_key-convertsapno      = lv_sapno.
*        ls_doc_key-storage_location  = lv_stloc.
*        ls_doc_key-material          = lv_mat.
*
*        APPEND ls_doc_key TO lt_doc_keys.
*        CLEAR: lv_plant, lv_mat, lv_sapno, lv_stloc, lv_year_1.
*      ENDLOOP.
*
*    ELSE.

*        APPEND VALUE #(
*
*               %msg = new_message_with_text(
*                         severity = if_abap_behv_message=>severity-success
*                         text     = |Chứng từ kiểm kê đã tồn tại, không thể tạo thêm|
*                       )
*             ) TO reported-zi_inventory_data_im.
**      ENDLOOP.
*
*      APPEND VALUE #(
*                          plant          = lv_plant
*                         material = lv_mat
*                         convertsapno = lv_sapno
*                         documantyear = lv_year_1
*                         storagelocation  = lv_stloc
*                          %action-createpi = if_abap_behv=>mk-on
*                        ) TO failed-zi_inventory_data_im.
*
*      RETURN.
*
*    ENDIF.

    " --- Normalize (round-robin) and build lt_doc_keys (SAP Cloud friendly) ---
    IF lt_sapno IS NOT INITIAL.

      DATA(lv_count) = lines( lt_sapno ).

      " normalize lt_plant -> round-robin to lv_count
      DATA(lt_tmp) = VALUE string_table( ).
      DATA(lv_size) = lines( lt_plant ).
      IF lv_size > 0.
        DO lv_count TIMES.
          DATA(lv_idx) = ( ( sy-index - 1 ) MOD lv_size ) + 1.
          READ TABLE lt_plant INDEX lv_idx INTO DATA(lv_val).
          APPEND lv_val TO lt_tmp.
        ENDDO.
        lt_plant = lt_tmp.
      ELSE.
        " if no plant provided, fill with empty strings
        CLEAR lt_tmp.
        DO lv_count TIMES.
          APPEND '' TO lt_tmp.
        ENDDO.
        lt_plant = lt_tmp.
      ENDIF.

      " normalize lt_stloc -> round-robin
      CLEAR lt_tmp.
      lv_size = lines( lt_stloc ).
      IF lv_size > 0.
        DO lv_count TIMES.
          DATA(lv_idx2) = ( ( sy-index - 1 ) MOD lv_size ) + 1.
          READ TABLE lt_stloc INDEX lv_idx2 INTO DATA(lv_val2).
          APPEND lv_val2 TO lt_tmp.
        ENDDO.
        lt_stloc = lt_tmp.
      ELSE.
        CLEAR lt_tmp.
        DO lv_count TIMES.
          APPEND '' TO lt_tmp.
        ENDDO.
        lt_stloc = lt_tmp.
      ENDIF.

      " normalize lt_mat -> round-robin
      CLEAR lt_tmp.
      lv_size = lines( lt_mat ).
      IF lv_size > 0.
        DO lv_count TIMES.
          DATA(lv_idx3) = ( ( sy-index - 1 ) MOD lv_size ) + 1.
          READ TABLE lt_mat INDEX lv_idx3 INTO DATA(lv_val3).
          APPEND lv_val3 TO lt_tmp.
        ENDDO.
        lt_mat = lt_tmp.
      ELSE.
        CLEAR lt_tmp.
        DO lv_count TIMES.
          APPEND '' TO lt_tmp.
        ENDDO.
        lt_mat = lt_tmp.
      ENDIF.

      " normalize lt_year -> round-robin (if lt_year empty, leave empty strings)
      CLEAR lt_tmp.
      lv_size = lines( lt_year ).
      IF lv_size > 0.
        DO lv_count TIMES.
          DATA(lv_idx4) = ( ( sy-index - 1 ) MOD lv_size ) + 1.
          READ TABLE lt_year INDEX lv_idx4 INTO DATA(lv_val4).
          APPEND lv_val4 TO lt_tmp.
        ENDDO.
        lt_year = lt_tmp.
      ELSE.
        CLEAR lt_tmp.
        DO lv_count TIMES.
          APPEND '' TO lt_tmp.
        ENDDO.
        lt_year = lt_tmp.
      ENDIF.

      " Build lt_doc_keys (aligned indices)
      CLEAR lt_doc_keys.
      lv_index = 0.

      LOOP AT lt_sapno INTO lv_sapno.
        lv_index = lv_index + 1.

        READ TABLE lt_year  INDEX lv_index INTO lv_year_1.
        READ TABLE lt_stloc INDEX lv_index INTO lv_stloc.
        READ TABLE lt_mat   INDEX lv_index INTO lv_mat.
        READ TABLE lt_plant INDEX lv_index INTO lv_plant.

        CONDENSE lv_plant NO-GAPS.
        CONDENSE lv_year_1 NO-GAPS.
        CONDENSE lv_sapno NO-GAPS.
        CONDENSE lv_stloc NO-GAPS.
        CONDENSE lv_mat NO-GAPS.

        CLEAR ls_doc_key.
        ls_doc_key-plant            = lv_plant.
        ls_doc_key-documantyear     = lv_year_1.
        ls_doc_key-convertsapno     = lv_sapno.
        ls_doc_key-storage_location = lv_stloc.
        ls_doc_key-material         = lv_mat.

        APPEND ls_doc_key TO lt_doc_keys.
        CLEAR: lv_plant, lv_mat, lv_sapno, lv_stloc, lv_year_1.
      ENDLOOP.

    ENDIF.


*    LOOP AT lt_doc_keys INTO DATA(ls_keys).
*
*      SELECT SINGLE *
*    FROM ztb_inven_im1
*   WHERE api_status = 'A'
*     AND plant = @ls_keys-plant
*     AND storage_location = @ls_keys-storage_location
**     AND uuid = @ls_keys-uuid
*AND convert_sap_no = @ls_keys-convertsapno
*   INTO @DATA(ls_data).
*
*
*      IF lv_header_built = abap_false.
*        "header
*        CLEAR ls_physinv.
*        lw_date = xco_cp=>sy->moment( xco_cp_time=>time_zone->user )->date->as( xco_cp_time=>format->abap )->value.
*        ls_physinv-fiscalyear                       = ''. "ls_data-document_year.
*        ls_physinv-inventorytransactiontype                         = 'IB'.
*        ls_physinv-plant = ls_data-plant.
*        ls_physinv-storagelocation = ls_data-storage_location.
*        ls_physinv-inventoryspecialstocktype = ''. "ls_data-spe_stok.
*        ls_physinv-documentdate =  zcl_utility=>to_json_date( iv_date = lw_date ).
*        ls_physinv-physinventoryplannedcountdate = zcl_utility=>to_json_date( iv_date = lw_date ).
*        lv_header_built = abap_true.
*      ENDIF.
*
*      CLEAR: ls_item.
*      "item
*      ls_item-fiscalyear                     = ''. "ls_data-document_year.
*      ls_item-physicalinventorydocumentitem   = ''.
*      ls_item-material                        = ls_data-material.
*      ls_item-batch                           = ls_data-batch. "ls_data-batch.
*      ls_item-inventoryspecialstocktype       = ''.
*      ls_item-salesorder                      = ''.
*      ls_item-salesorderitem                  = ''.
*      ls_item-supplier                        = ''.
*      ls_item-customer                        = ''.
*      ls_item-wbselement                      = ''.
*      ls_item-lastchangeuser                  = ''.
*      ls_item-lastchangedate                  = ''.
*      ls_item-countedbyuser                   = ''.
*      ls_item-physicalinventorylastcountdate   = ''.
*      ls_item-adjustmentpostingmadebyuser     = ''.
*      ls_item-postingdate                     = ''.
*      ls_item-physicalinventoryitemiscounted   = abap_false.
*      ls_item-physinvtrydifferenceisposted     = abap_false.
*      ls_item-physinvtryitemisrecounted        = abap_false.
*      ls_item-physinvtryitemisdeleted          = abap_false.
*      ls_item-ishandledinaltvunitofmsr         = abap_true.
*      ls_item-cyclecounttype                   = ''.
*      ls_item-isvalueonlymaterial              = abap_false.
*      ls_item-physinventoryreferencenumber     = ''.
*      ls_item-materialdocument                 = ''.
*      ls_item-materialdocumentyear             = '0000'.
*      ls_item-materialdocumentitem             = '0'.
*      ls_item-physinvtryrecountdocument        = ''.
*      ls_item-physicalinventoryitemiszero      = abap_false.
*      ls_item-reasonforphysinvtrydifference    = '0'.
*      ls_item-bookqtybfrcountinmatlbaseunit    = '0'.
*      ls_item-quantity                         = '0'.
*      ls_item-quantityinunitofentry            = '0'.
*
*      APPEND ls_item TO lt_items.
*
*    ENDLOOP.
*
*    "gán vào bảng
*    ls_physinv-physicalitem-results = lt_items.
*
*    DATA(lw_json_body) = /ui2/cl_json=>serialize(
*                   data = ls_physinv
*                   compress = abap_true
*                   pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).



    DATA: lt_data        TYPE STANDARD TABLE OF ztb_inven_im1,
*          lt_items       TYPE STANDARD TABLE OF your_item_type,
          lt_json_bodies TYPE STANDARD TABLE OF string,
          lw_json_body   TYPE string.

    " Lấy toàn bộ dữ liệu các dòng đã chọn
    SELECT *
      FROM ztb_inven_im1
      FOR ALL ENTRIES IN @lt_doc_keys
      WHERE api_status = 'A'
        AND convert_sap_no = @lt_doc_keys-convertsapno
      INTO TABLE @lt_data.

    SORT lt_data BY plant storage_location.

    DATA: lv_curr_plant TYPE ztb_inven_im1-plant,
          lv_curr_sloc  TYPE ztb_inven_im1-storage_location.

    CLEAR: lt_items, lv_curr_plant, lv_curr_sloc.

    LOOP AT lt_data INTO DATA(ls_data).


      " Nếu sang Plant/Sloc khác thì build JSON cho nhóm trước
      IF lv_curr_plant IS NOT INITIAL AND
         ( ls_data-plant <> lv_curr_plant OR ls_data-storage_location <> lv_curr_sloc ).

        CLEAR ls_physinv.
        lw_date = xco_cp=>sy->moment( xco_cp_time=>time_zone->user )->date->as( xco_cp_time=>format->abap )->value.
        ls_physinv-fiscalyear                     = ''.
        ls_physinv-inventorytransactiontype       = 'IB'.
        ls_physinv-plant                          = lv_curr_plant.
        ls_physinv-storagelocation                = lv_curr_sloc.
        ls_physinv-inventoryspecialstocktype      = ''.
        ls_physinv-documentdate                   = zcl_utility=>to_json_date( iv_date = lw_date ).
        ls_physinv-physinventoryplannedcountdate  = zcl_utility=>to_json_date( iv_date = lw_date ).
        ls_physinv-physicalitem-results           = lt_items.

        lw_json_body = /ui2/cl_json=>serialize(
                          data = ls_physinv
                          compress = abap_true
                          pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

        APPEND lw_json_body TO lt_json_bodies.
        CLEAR lt_items.
      ENDIF.

      " Gán lại nhóm hiện tại
      lv_curr_plant = ls_data-plant.
      lv_curr_sloc  = ls_data-storage_location.

      " Tạo item
      CLEAR ls_item.
      ls_item-material = ls_data-material.
      ls_item-batch    = ls_data-batch.
      ls_item-physicalinventoryitemiscounted = abap_false.
      ls_item-ishandledinaltvunitofmsr       = abap_true.
      ls_item-isvalueonlymaterial            = abap_false.
      ls_item-reasonforphysinvtrydifference  = '0'.
      ls_item-bookqtybfrcountinmatlbaseunit  = '0'.
      ls_item-quantity                       = '0'.
      ls_item-quantityinunitofentry          = '0'.
      APPEND ls_item TO lt_items.
    ENDLOOP.

    " Build group cuối cùng
    IF lt_items IS NOT INITIAL.
      CLEAR ls_physinv.
      lw_date = xco_cp=>sy->moment( xco_cp_time=>time_zone->user )->date->as( xco_cp_time=>format->abap )->value.
      ls_physinv-fiscalyear                     = ''.
      ls_physinv-inventorytransactiontype       = 'IB'.
      ls_physinv-plant                          = lv_curr_plant.
      ls_physinv-storagelocation                = lv_curr_sloc.
      ls_physinv-inventoryspecialstocktype      = ''.
      ls_physinv-documentdate                   = zcl_utility=>to_json_date( iv_date = lw_date ).
      ls_physinv-physinventoryplannedcountdate  = zcl_utility=>to_json_date( iv_date = lw_date ).
      ls_physinv-physicalitem-results           = lt_items.

      lw_json_body = /ui2/cl_json=>serialize(
                        data = ls_physinv
                        compress = abap_true
                        pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

      APPEND lw_json_body TO lt_json_bodies.
    ENDIF.


    TYPES: BEGIN OF ty_created_doc,
             docnum       TYPE string,
             convert_keys TYPE string,
             sloc         TYPE string,

           END OF ty_created_doc.

    DATA: lt_created_docs TYPE STANDARD TABLE OF ty_created_doc,
          ls_created_doc  TYPE ty_created_doc.


    LOOP AT lt_json_bodies INTO lw_json_body .

*      " Lấy nhóm convert_sap_no tương ứng với JSON đang xử lý
*      CLEAR ls_created_doc.
*      LOOP AT lt_data INTO DATA(ls_temp)
*           WHERE plant = lv_curr_plant AND storage_location = lv_curr_sloc.
*        APPEND ls_temp-convert_sap_no TO ls_created_doc-convert_keys.
*      ENDLOOP.


      REPLACE ALL OCCURRENCES OF 'fiscalyear'                        IN lw_json_body WITH 'FiscalYear'.
      REPLACE ALL OCCURRENCES OF 'inventorytransactiontype'          IN lw_json_body WITH 'InventoryTransactionType'.
      REPLACE ALL OCCURRENCES OF 'plant'                             IN lw_json_body WITH 'Plant'.
      REPLACE ALL OCCURRENCES OF 'storagelocation'                   IN lw_json_body WITH 'StorageLocation'.
      REPLACE ALL OCCURRENCES OF 'inventoryspecialstocktype'         IN lw_json_body WITH 'InventorySpecialStockType'.
      REPLACE ALL OCCURRENCES OF 'documentdate'                      IN lw_json_body WITH 'DocumentDate'.
      REPLACE ALL OCCURRENCES OF 'physinventoryplannedcountdate'     IN lw_json_body WITH 'PhysInventoryPlannedCountDate'.
      REPLACE ALL OCCURRENCES OF 'physicalitem'                      IN lw_json_body WITH 'to_PhysicalInventoryDocumentItem'.
      REPLACE ALL OCCURRENCES OF 'results'                           IN lw_json_body WITH 'results'.

      REPLACE ALL OCCURRENCES OF 'physicalinventorydocumentitem'      IN lw_json_body WITH 'PhysicalInventoryDocumentItem'.
      REPLACE ALL OCCURRENCES OF 'material'                           IN lw_json_body WITH 'Material'.
      REPLACE ALL OCCURRENCES OF 'batch'                              IN lw_json_body WITH 'Batch'.
      REPLACE ALL OCCURRENCES OF 'salesorder'                         IN lw_json_body WITH 'SalesOrder'.
      REPLACE ALL OCCURRENCES OF 'salesorderitem'                     IN lw_json_body WITH 'SalesOrderItem'.
      REPLACE ALL OCCURRENCES OF 'supplier'                           IN lw_json_body WITH 'Supplier'.
      REPLACE ALL OCCURRENCES OF 'customer'                           IN lw_json_body WITH 'Customer'.
      REPLACE ALL OCCURRENCES OF 'wbselement'                         IN lw_json_body WITH 'WBSElement'.
      REPLACE ALL OCCURRENCES OF 'lastchangeuser'                     IN lw_json_body WITH 'LastChangeUser'.
      REPLACE ALL OCCURRENCES OF 'lastchangedate'                     IN lw_json_body WITH 'LastChangeDate'.
      REPLACE ALL OCCURRENCES OF 'countedbyuser'                      IN lw_json_body WITH 'CountedByUser'.
      REPLACE ALL OCCURRENCES OF 'physicalinventorylastcountdate'     IN lw_json_body WITH 'PhysicalInventoryLastCountDate'.
      REPLACE ALL OCCURRENCES OF 'adjustmentpostingmadebyuser'        IN lw_json_body WITH 'AdjustmentPostingMadeByUser'.
      REPLACE ALL OCCURRENCES OF 'postingdate'                        IN lw_json_body WITH 'PostingDate'.
      REPLACE ALL OCCURRENCES OF 'physicalinventoryitemiscounted'     IN lw_json_body WITH 'PhysicalInventoryItemIsCounted'.
      REPLACE ALL OCCURRENCES OF 'physinvtrydifferenceisposted'       IN lw_json_body WITH 'PhysInvtryDifferenceIsPosted'.
      REPLACE ALL OCCURRENCES OF 'physinvtryitemisrecounted'          IN lw_json_body WITH 'PhysInvtryItemIsRecounted'.
      REPLACE ALL OCCURRENCES OF 'physinvtryitemisdeleted'            IN lw_json_body WITH 'PhysInvtryItemIsDeleted'.
      REPLACE ALL OCCURRENCES OF 'ishandledinaltvunitofmsr'           IN lw_json_body WITH 'IsHandledInAltvUnitOfMsr'.
      REPLACE ALL OCCURRENCES OF 'cyclecounttype'                     IN lw_json_body WITH 'CycleCountType'.
      REPLACE ALL OCCURRENCES OF 'isvalueonlymaterial'                IN lw_json_body WITH 'IsValueOnlyMaterial'.
      REPLACE ALL OCCURRENCES OF 'physinventoryreferencenumber'       IN lw_json_body WITH 'PhysInventoryReferenceNumber'.
      REPLACE ALL OCCURRENCES OF 'materialdocument'                   IN lw_json_body WITH 'MaterialDocument'.
      REPLACE ALL OCCURRENCES OF 'Materialdocumentyear'               IN lw_json_body WITH 'MaterialDocumentYear'.
      REPLACE ALL OCCURRENCES OF 'Materialdocumentitem'               IN lw_json_body WITH 'MaterialDocumentItem'.
      REPLACE ALL OCCURRENCES OF 'physinvtryrecountdocument'          IN lw_json_body WITH 'PhysInvtryRecountDocument'.
      REPLACE ALL OCCURRENCES OF 'physicalinventoryitemiszero'        IN lw_json_body WITH 'PhysicalInventoryItemIsZero'.
      REPLACE ALL OCCURRENCES OF 'reasonforphysinvtrydifference'      IN lw_json_body WITH 'ReasonForPhysInvtryDifference'.
      REPLACE ALL OCCURRENCES OF 'bookqtybfrcountinmatlbaseunit'      IN lw_json_body WITH 'BookQtyBfrCountInMatlBaseUnit'.
      REPLACE ALL OCCURRENCES OF 'quantity'                           IN lw_json_body WITH 'Quantity'.
      REPLACE ALL OCCURRENCES OF 'Quantityinunitofentry'              IN lw_json_body WITH 'QuantityInUnitOfEntry'.

      DATA: lo_http_client  TYPE REF TO if_web_http_client,
            response        TYPE string,
            lv_response     TYPE string,
*          lv_token        TYPE string,
            lv_url          TYPE string,
            lv_doc          TYPE string,
            lv_item         TYPE string,
            lv_year         TYPE string,
            ls_odata_return TYPE zst_odata_return.

      SELECT SINGLE * FROM ztb_api_auth
    WHERE systemid = 'CASLA'
  INTO @DATA(ls_api_auth).

      lw_username = ls_api_auth-api_user.
      lw_password = ls_api_auth-api_password.

      lv_url = |https://{ ls_api_auth-api_url }/sap/opu/odata/sap/API_PHYSICAL_INVENTORY_DOC_SRV/A_PhysInventoryDocHeader|.

      TRY.

          DATA(lo_http_destination) =
               cl_http_destination_provider=>create_by_url( lv_url ).

          DATA(lo_web_http_client) =
               cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
          DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
          lo_web_http_request->set_header_fields( VALUE #(
             ( name = 'DataServiceVersion' value = '2.0' )
             ( name = 'Accept' value = 'application/json' )
          ) ).

          "Authorization
          lo_web_http_request->set_header_field(  i_name = 'username' i_value = 'PB9_LO' ).
          lo_web_http_request->set_header_field(  i_name = 'password' i_value = 'Qwertyuiop@1234567890' ).

          lo_web_http_request->set_authorization_basic( i_username = lw_username i_password = lw_password ).
          lo_web_http_request->set_content_type( |application/json| ).
          lo_web_http_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
          lo_web_http_request->set_header_field( i_name = 'x-csrf-token' i_value = 'Fetch' ).
*          lo_web_http_request->set_header_field( i_name = 'If-Match' i_value = '' ).

          DATA(lo_response) = lo_web_http_client->execute( i_method = if_web_http_client=>get ).
          DATA(lv_token)    = lo_response->get_header_field( 'x-csrf-token' ).
          DATA(lv_Match)    = lo_response->get_header_field( 'etag' ).
          lo_web_http_request->set_header_field( i_name = 'x-csrf-token' i_value = lv_token ).


**          lo_web_http_request->set_header_field( i_name = 'If-Match' i_value = lv_Match ).

          lo_web_http_request->set_text( lw_json_body ).

          DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>post ).
          lv_response = lo_web_http_response->get_text( ).

          /ui2/cl_json=>deserialize(
            EXPORTING json = lv_response
            CHANGING  data = e_response ).
          DATA(lv_status) = lo_web_http_response->get_status( ).
          DATA(lv_body)   = lo_web_http_response->get_text( ).
          e_code = lv_status-code.

        CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.

      ENDTRY.

      IF lv_status-code = '201'.
        DATA(lv_docnum) = VALUE string( ).
        FIND REGEX '"PhysicalInventoryDocument":"([^"]+)"' IN lv_body SUBMATCHES lv_docnum.
        CONDENSE lv_docnum NO-GAPS.
        IF lv_docnum IS NOT INITIAL.

          LOOP AT lt_doc_keys ASSIGNING FIELD-SYMBOL(<ls_key>)
      WHERE plant = lv_curr_plant
        AND storage_location = lv_curr_sloc.
            <ls_key>-docnum = lv_docnum.
          ENDLOOP.

          APPEND VALUE #(
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-success
                     text     = |Đã tạo thành công chứng từ { lv_docnum }|
                   )
          ) TO reported-zi_inventory_data_im.

        ENDIF.


      ELSE.
        DATA(lv_errmsg) = VALUE string( ).
        FIND REGEX '"message":\{"lang":"[^"]*","value":"([^"]+)"' IN lv_body SUBMATCHES lv_errmsg.
        IF lv_errmsg IS INITIAL.
          lv_errmsg = lv_body.
        ENDIF.

        APPEND VALUE #(

     %msg = new_message_with_text(
               severity = if_abap_behv_message=>severity-error
               text     = |Lỗi khi tạo chứng từ cho convert SAP No { ls_data-convert_sap_no }|
            )
   ) TO reported-zi_inventory_data_im.

        APPEND VALUE #(
                            plant          = lv_plant
                           material = lv_mat
                           convertsapno = lv_sapno
                           documantyear = lv_year_1
                           storagelocation  = lv_stloc
                            %action-createpi = if_abap_behv=>mk-on
                          ) TO failed-zi_inventory_data_im.

        RETURN.

      ENDIF.
    ENDLOOP.

    DATA(lv_counter) = 0.
    SORT lt_doc_keys BY docnum.
    LOOP AT lt_doc_keys INTO DATA(ls_created).

      AT NEW docnum.

        lv_counter = 1.
      ENDAT.

      SELECT SINGLE uuid
     FROM ztb_inven_im1
     WHERE convert_sap_no = @ls_created-convertsapno
     INTO @DATA(lv_existing_uuid).

      DATA(lv_pid_item) = |{ lv_counter WIDTH = 3 ALIGN = RIGHT PAD = '0' }|.

      UPDATE ztb_inven_im1
  SET pid         = @ls_created-docnum,
        pid_item    = @lv_pid_item,
      api_status  = 'S',
      pi_status   = 'Not Counted',
      api_message = 'Success'
  WHERE uuid = @lv_existing_uuid.

      lv_counter = lv_counter + 1.
*      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD DownloadFile.
    DATA:
      lt_file TYPE STANDARD TABLE OF ty_file_upload WITH DEFAULT KEY,
      ls_file TYPE ty_file_upload.

    "XCOライブラリを使用したExcelファイルの書き込み
    DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
    DATA(lo_worksheet) = lo_write_access->get_workbook(
        )->worksheet->at_position( 1 ).

    DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
                               )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                               )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'AH' )
                               )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
                               )->get_pattern( ).

    "1 Đọc key từ RAP Action
    READ TABLE keys INDEX 1 INTO DATA(k).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    "ヘッダの設定（すべての項目はstring型）
    lt_file = VALUE #(
*       Header Line  ===========================================================================================================
                       (
                         convert_sap_no       = 'Convert SAP No'
                         pid                  = 'PID'
                         pid_item             = 'PID Item'
                         fiscal_year          = 'Document Year'
                         doc_date             = 'Document Date'
                         plan_count_date      = 'Plan Count Date'
                         plant                = 'Plant'
                         storage_location     = 'Storage location'
                         material             = 'Material'
                         material_description = 'Material Description'
                         batch                = 'Batch'
                         spe_stok             = 'Special Stock'
                         spe_stok_num         = 'Supplier’s Account Number'
                         sales_order          = 'Sales Order'
                         sales_order_item     = 'Item no. of Sales Order'
                         stock_type           = 'Stock Type'
                         book_qty             = 'Book Quantity'
                         book_qty_uom         = 'Book Qty UoM'
                         pda_qty              = 'PDA Quantity'
                         counted_qty          = 'Counted Quantity'
                         counted_qty_uom      = 'Counted Qty UoM'
                         entered_qty_pi       = 'Entered Qty in PI'
                         entered_qty_uom      = 'Entered Qty UoM'
                         zero_count           = 'Zero Count'
                         diff_qty             = 'Difference Quantity'
                         api_status           = 'API Status'
                         api_message          = 'API Message'
                         pda_date             = 'PDA Date'
                         pda_time             = 'PDA Time'
                         counter              = 'Counter'
                         api_date             = 'API Date'
                         api_time             = 'API Time'
                         pi_status            = 'PI Status'
                         user_upload          = 'User Upload'
                       )
                     ).

    DATA:
      lt_template_download TYPE STANDARD TABLE OF ty_template_download,
      ls_template_download TYPE ty_template_download,

      lr_pid               TYPE tt_ranges,
      lr_pid_item          TYPE tt_ranges,
      lr_documentyear      TYPE tt_ranges,
      lr_plant             TYPE tt_ranges,
      lr_store_location    TYPE tt_ranges,
*      lr_store_type        TYPE tt_ranges,
      lr_material          TYPE tt_ranges,
      lr_convert_sap_no    TYPE tt_ranges,
      lr_pi_status         TYPE tt_ranges,
      lr_api_status        TYPE tt_ranges,
      lr_uuid              TYPE tt_ranges
      .

    DATA:
      lt_parameters TYPE tt_parameters,
      ls_parameter  TYPE ty_parameter_line.

    " Get keys from FE
    IF k-%param IS NOT INITIAL.
      SPLIT k-%param-pid AT ',' INTO TABLE DATA(lt_pid_split).
      SPLIT k-%param-pid_item AT ',' INTO TABLE DATA(lt_pid_item_split).
      SPLIT k-%param-documentyear AT ',' INTO TABLE DATA(lt_documentyear_split).
      SPLIT k-%param-plant AT ',' INTO TABLE DATA(lt_plant_split).
      SPLIT k-%param-store_location AT ',' INTO TABLE DATA(lt_store_location_split).
*      SPLIT k-%param-store_type AT ',' INTO TABLE DATA(lt_store_type_split).
      SPLIT k-%param-material AT ',' INTO TABLE DATA(lt_material_split).
      SPLIT k-%param-convert_sap_no AT ',' INTO TABLE DATA(lt_convert_sap_no_split).
      SPLIT k-%param-pi_status AT ',' INTO TABLE DATA(lt_pi_status_split).
      SPLIT k-%param-api_status AT ',' INTO TABLE DATA(lt_api_status_split).
      SPLIT k-%param-uuid AT ',' INTO TABLE DATA(lt_uuid_split).

      DATA(lv_max) = lines( lt_pid_split ) + 1.

      DO lv_max TIMES.
        DATA(lv_idx) = sy-index.

        ls_parameter-pid            = VALUE #( lt_pid_split[ lv_idx ] OPTIONAL ).
        ls_parameter-pid_item       = VALUE #( lt_pid_item_split[ lv_idx ] OPTIONAL ).
        ls_parameter-document_year  = VALUE #( lt_documentyear_split[ lv_idx ] OPTIONAL ).
        ls_parameter-plant          = VALUE #( lt_plant_split[ lv_idx ] OPTIONAL ).
        ls_parameter-store_location = VALUE #( lt_store_location_split[ lv_idx ] OPTIONAL ).
        ls_parameter-material       = VALUE #( lt_material_split[ lv_idx ] OPTIONAL ).
        ls_parameter-convert_sap_no = VALUE #( lt_convert_sap_no_split[ lv_idx ] OPTIONAL ).
        ls_parameter-pi_status      = VALUE #( lt_pi_status_split[ lv_idx ] OPTIONAL ).
        ls_parameter-api_status     = VALUE #( lt_api_status_split[ lv_idx ] OPTIONAL ).
        ls_parameter-uuid           = VALUE #( lt_uuid_split[ lv_idx ] OPTIONAL ).

        APPEND ls_parameter TO lt_parameters.
        CLEAR ls_parameter.
      ENDDO.

      DELETE lt_parameters WHERE table_line IS INITIAL OR pi_status NE 'Not Counted'.

      DATA:
        lv_pid_c10     TYPE c LENGTH 10,
        lv_pid_item_c6 TYPE c LENGTH 6,
        lv_matnr_c18   TYPE c LENGTH 18
        .

      LOOP AT lt_parameters ASSIGNING FIELD-SYMBOL(<fs_parameters>).
        lv_pid_c10 = |{ <fs_parameters>-pid ALPHA = IN }|.
        <fs_parameters>-pid = lv_pid_c10.

        lv_pid_item_c6 = |{ <fs_parameters>-Pid_item ALPHA = IN }|.
        <fs_parameters>-Pid_item = lv_pid_item_c6.

        lv_matnr_c18 = |{ <fs_parameters>-Material ALPHA = IN }|.
        <fs_parameters>-Material = lv_matnr_c18.
      ENDLOOP.

      " Field keys in to range for select
      LOOP AT lt_pid_split INTO DATA(ls_pid_split).
*        IF ls_pid_split IS NOT INITIAL.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_pid_split ) TO lr_pid.
*        ENDIF.
      ENDLOOP.

      LOOP AT lt_pid_item_split INTO DATA(ls_pid_item_split).
*        IF ls_pid_item_split IS NOT INITIAL.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_pid_item_split ) TO lr_pid_item.
*        ENDIF.
      ENDLOOP.

      LOOP AT lt_documentyear_split INTO DATA(ls_documentyear_split).
*        IF ls_documentyear_split IS NOT INITIAL.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_documentyear_split ) TO lr_documentyear.
*        ENDIF.
      ENDLOOP.

      LOOP AT lt_plant_split INTO DATA(ls_plant_split).
*        IF ls_plant_split IS NOT INITIAL.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_plant_split ) TO lr_plant.
*        ENDIF.
      ENDLOOP.

      LOOP AT lt_store_location_split INTO DATA(ls_store_location_split).
*        IF ls_store_location_split IS NOT INITIAL.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_store_location_split ) TO lr_store_location.
*        ENDIF.
      ENDLOOP.

*      LOOP AT lt_store_type_split INTO DATA(ls_store_type_split).
*        IF ls_store_type_split IS NOT INITIAL.
*          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_store_type_split ) TO lr_store_type.
*        ENDIF.
*      ENDLOOP.

      LOOP AT lt_material_split INTO DATA(ls_material_split).
*        IF ls_material_split IS NOT INITIAL.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_material_split ) TO lr_material.
*        ENDIF.
      ENDLOOP.

      LOOP AT lt_convert_sap_no_split INTO DATA(ls_convert_sap_no_split).
*        IF ls_convert_sap_no_split IS NOT INITIAL.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_convert_sap_no_split ) TO lr_convert_sap_no.
*        ENDIF.
      ENDLOOP.

      LOOP AT lt_pi_status_split INTO DATA(ls_pi_status_split).
*        IF ls_pi_status_split IS NOT INITIAL.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_pi_status_split ) TO lr_pi_status.
*        ENDIF.
      ENDLOOP.

      LOOP AT lt_api_status_split INTO DATA(ls_api_status_split).
*        IF ls_api_status_split IS NOT INITIAL.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_api_status_split ) TO lr_api_status.
*        ENDIF.
      ENDLOOP.
    ENDIF.

    " Call method get for IM data
    CALL METHOD zcl_get_inventory_data_im=>get_im_data
      EXPORTING
        iv_pid            = lr_pid
        iv_pid_item       = lr_pid_item
        iv_document_year  = lr_documentyear
        iv_plant          = lr_plant
        iv_store_loca     = lr_store_location
        iv_matnr          = lr_material
        iv_convert_sap_no = lr_convert_sap_no
        iv_pi_status      = lr_pi_status
      IMPORTING
        ev_result         = DATA(lt_data_get).

    SORT lt_data_get BY pid pid_item DocumantYear Plant Storagelocation Material ConvertSapNo PiStatus.

    DELETE lt_data_get WHERE pid IS INITIAL AND pid_item IS INITIAL OR PiStatus NE 'Not Counted'.

    LOOP AT lt_parameters INTO ls_parameter.
      READ TABLE lt_data_get INTO DATA(ls_data_get) WITH KEY pid = ls_parameter-pid
                                                             pid_item = ls_parameter-pid_item
                                                             DocumantYear = ls_parameter-document_year
                                                             Plant = ls_parameter-plant
                                                             Storagelocation = ls_parameter-store_location
                                                             Material = ls_parameter-material
                                                             ConvertSapNo = ls_parameter-convert_sap_no
                                                             PiStatus = ls_parameter-pi_status.
      IF sy-subrc = 0.
        ls_file-convert_sap_no       = ls_data_get-ConvertSapNo.
        ls_file-pid                  = ls_data_get-Pid.
        ls_file-pid_item             = ls_data_get-Pid_item.
        ls_file-fiscal_year          = ls_data_get-DocumantYear.
        ls_file-doc_date             = ls_data_get-DocDate.
        ls_file-plan_count_date      = ls_data_get-Plantcountdate.
        ls_file-plant                = ls_data_get-Plant.
        ls_file-storage_location     = ls_data_get-Storagelocation.
        ls_file-material             = ls_data_get-Material.
        ls_file-material_description = ls_data_get-MaterialDescription.
        ls_file-batch                = ls_data_get-Batch.
        ls_file-spe_stok             = ls_data_get-Spestok.
        ls_file-spe_stok_num         = ls_data_get-Spestoknum.
        ls_file-sales_order          = ls_data_get-Salesorder.
        ls_file-sales_order_item     = ls_data_get-SalesOrderItem.
        ls_file-stock_type           = ls_data_get-StockType.
        ls_file-book_qty             = ls_data_get-BookQty.
        ls_file-book_qty_uom         = ls_data_get-BookQtyUom.
        ls_file-pda_qty              = ls_data_get-PdaQty.
        ls_file-counted_qty          = ls_data_get-CountedQty.
        ls_file-counted_qty_uom      = ls_data_get-CountedQtyUom.
        ls_file-entered_qty_pi       = ls_data_get-EnteredQtyPi.
        ls_file-entered_qty_uom      = ls_data_get-EnteredQtyUom.
        ls_file-zero_count           = ls_data_get-ZeroCount.
        ls_file-diff_qty             = ls_data_get-DiffQty.
        ls_file-api_status           = ls_data_get-ApiStatus.
        ls_file-api_message          = ls_data_get-ApiMessage.
        ls_file-pda_date             = ls_data_get-PdaDate.
        ls_file-pda_time             = ls_data_get-PdaTime.
        ls_file-counter              = ls_data_get-Counter.
        ls_file-api_date             = ls_data_get-ApiDate.
        ls_file-api_time             = ls_data_get-ApiTime.
        ls_file-pi_status            = ls_data_get-PiStatus.
        ls_file-user_upload          = ls_data_get-UserUpload.

        APPEND ls_file TO lt_file.
        CLEAR: ls_file, ls_data_get.
      ENDIF.
    ENDLOOP.

    lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_from( REF #( lt_file )
        )->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    result = VALUE #( FOR key IN keys (
                      %cid   = key-%cid
                      %param = VALUE #( filecontent   = lv_file_content
                                        filename      = 'xldl_kiem_ke_template_im'
                                        fileextension = 'xlsx'
                                        mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                      ) ).
  ENDMETHOD.

  METHOD UploadFile.
    DATA: lv_fail TYPE abap_boolean.

    DATA: lt_file   TYPE STANDARD TABLE OF ty_file_upload,

          lt_file_u TYPE TABLE OF ztb_inven_im1,
          ls_file_u LIKE LINE OF lt_file_u,

          lt_file_c TYPE TABLE FOR UPDATE zi_inventory_data_im,
          ls_file_c LIKE LINE OF lt_file_c.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_keys>) INDEX 1.

    CHECK sy-subrc = 0.

    DATA(lv_filecontent) = <ls_keys>-%param-filecontent.

    "xcoライブラリを使用したexcelファイルの読み取り
    FINAL(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_filecontent )->read_access( ).
    FINAL(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

    FINAL(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    FINAL(lo_execute) = lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_file ) ).

    lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
               )->if_xco_xlsx_ra_operation~execute( ).

    IF lt_file IS NOT INITIAL.
      DELETE lt_file INDEX 1.
    ENDIF.

    " Convert timestamp to date & time
    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).   " YYYYMMDD
    DATA(lv_time) = cl_abap_context_info=>get_system_time( ).   " HHMMSS

    DATA:
      lv_text           TYPE string VALUE '',

      lr_pid            TYPE tt_ranges,
      lr_pid_item       TYPE tt_ranges,
      lr_documentyear   TYPE tt_ranges,
      lr_plant          TYPE tt_ranges,
      lr_store_location TYPE tt_ranges,
*      lr_store_type        TYPE tt_ranges,
      lr_material       TYPE tt_ranges,
      lr_convert_sap_no TYPE tt_ranges,
      lr_pi_status      TYPE tt_ranges,
      lr_api_status     TYPE tt_ranges,
      lr_uuid           TYPE tt_ranges
      .

    "Process data Raw
    LOOP AT lt_file INTO DATA(ls_file).
      IF ls_file-pid IS INITIAL AND ls_file-pid_item IS INITIAL OR ls_file-pi_status NE 'Not Counted'.
        " Trường hợp chúng từ ko có PID và PID Item hoặc không thuộc PI status có quyền chỉnh sửa.
      ELSE.
        " Field keys in to range for select
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-pid ) TO lr_pid.

        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-Pid_item ) TO lr_pid_item.

        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-fiscal_year ) TO lr_documentyear.

        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-Plant ) TO lr_plant.

        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-storage_location ) TO lr_store_location.

        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-Material ) TO lr_material.

        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-convert_sap_no ) TO lr_convert_sap_no.

        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-pi_status ) TO lr_pi_status.

        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-api_status ) TO lr_api_status.

        ls_file_u-convert_sap_no   = ls_file-convert_sap_no.
        ls_file_u-pid              = ls_file-pid.
        ls_file_u-Pid_item         = ls_file-pid_item.
        ls_file_u-document_year    = ls_file-fiscal_year.
        ls_file_u-doc_date         = ls_file-doc_date.
        ls_file_u-plant_count_date = ls_file-plan_count_date.
        ls_file_u-plant            = ls_file-plant.
        ls_file_u-storage_location = ls_file-storage_location.
        ls_file_u-Material         = ls_file-material.

        ls_file_u-batch            = ls_file-batch.
        ls_file_u-spe_stok         = ls_file-spe_stok.
        ls_file_u-spe_stok_num     = ls_file-spe_stok_num.
        ls_file_u-sales_order      = ls_file-sales_order.
        ls_file_u-sales_order_item = ls_file-sales_order_item.


        ls_file_u-counted_qty      = ls_file-counted_qty.          " Update
        ls_file_u-counted_qty_uom  = ls_file-counted_qty_uom .     " Update
        ls_file_u-zero_count       = ls_file-zero_count .          " Update

        ls_file_u-pi_status            = ls_file-pi_status.
        ls_file_u-action_type          = 'U'.

        APPEND ls_file_u TO lt_file_u.
        CLEAR: ls_file_u.
      ENDIF.
    ENDLOOP.

    DATA: lv_index       TYPE int4,
          ls_export_data TYPE ty_file_upload.

    DATA: lv_prefix TYPE string,
          lv_filter TYPE string.

    DATA: lt_results TYPE ztt_resp_results_get_lsx.

    CALL METHOD zcl_get_inventory_data_im=>get_im_data
      EXPORTING
        iv_pid            = lr_pid
        iv_pid_item       = lr_pid_item
        iv_document_year  = lr_documentyear
        iv_plant          = lr_plant
        iv_store_loca     = lr_store_location
        iv_matnr          = lr_material
        iv_convert_sap_no = lr_convert_sap_no
        iv_pi_status      = lr_pi_status
      IMPORTING
        ev_result         = DATA(lt_data_get).

    SORT lt_data_get BY Pid Pid_item DocumantYear Plant Storagelocation Material.

    DELETE lt_data_get WHERE pid IS INITIAL AND pid_item IS INITIAL.

    LOOP AT lt_file_u ASSIGNING FIELD-SYMBOL(<lfs_file_u>).
      lv_index = sy-tabix.

      READ TABLE lt_data_get INTO DATA(ls_data_get) WITH KEY pid = <lfs_file_u>-pid
                                                             pid_item = <lfs_file_u>-pid_item
                                                             DocumantYear = <lfs_file_u>-document_year
                                                             Plant = <lfs_file_u>-plant
                                                             Storagelocation = <lfs_file_u>-storage_location
                                                             Material = <lfs_file_u>-material.

      IF sy-subrc = 0 AND ls_data_get-PiStatus = 'Not Counted'.
*        ls_export_data = CORRESPONDING #( ls_data_get ).

        ls_export_data-convert_sap_no = <lfs_file_u>-convert_sap_no.
        ls_export_data-pid = <lfs_file_u>-pid.
        ls_export_data-pid_item = <lfs_file_u>-pid_item.
        ls_export_data-fiscal_year = <lfs_file_u>-document_year.
        ls_export_data-material = <lfs_file_u>-material.
        ls_export_data-plant = <lfs_file_u>-plant.
        ls_export_data-storage_location = <lfs_file_u>-storage_location.
        ls_export_data-batch = <lfs_file_u>-batch.
        ls_export_data-spe_stok = <lfs_file_u>-spe_stok.
        ls_export_data-spe_stok_num = <lfs_file_u>-spe_stok_num.
        ls_export_data-sales_order = <lfs_file_u>-sales_order.
        ls_export_data-sales_order_item = <lfs_file_u>-sales_order_item.

        me->data_valid_check(
          EXPORTING
              iv_file_upload = ls_export_data
              iv_db_check = lt_data_get
          IMPORTING
              e_respond = DATA(ls_valid_check_respond)
         ).

        IF ls_valid_check_respond-upload_status = 'S'. " Successfully upload data
          IF <lfs_file_u>-counted_qty IS INITIAL.
            <lfs_file_u>-zero_count = 'X'.
*          ELSE.
*            <lfs_file_u>-Zero_Count = ls_data_get-ZeroCount.
          ENDIF.

          <lfs_file_u>-Upload_Status = ls_valid_check_respond-upload_status.
          <lfs_file_u>-Upload_Message = ls_valid_check_respond-upload_message.

        ELSEIF ls_valid_check_respond-upload_status = 'F'.

          <lfs_file_u>-Counted_Qty = ls_data_get-CountedQty.
          <lfs_file_u>-Counted_Qty_Uom = ls_data_get-CountedQtyUom.
          <lfs_file_u>-Zero_Count = ls_data_get-ZeroCount.

          <lfs_file_u>-Upload_Status = ls_valid_check_respond-upload_status.
          <lfs_file_u>-Upload_Message = ls_valid_check_respond-upload_message.
        ENDIF.

        CLEAR: ls_data_get, ls_export_data.
      ENDIF.
    ENDLOOP.

    DATA: lt_inventory_upload TYPE TABLE OF ztb_inven_im1,
          ls_inventory_upload TYPE ztb_inven_im1.

    CLEAR ls_file_u.

    LOOP AT lt_file_u INTO ls_file_u.
      CLEAR ls_data_get.
      IF ls_file_u-pid IS NOT INITIAL AND ls_file_u-pid_item IS NOT INITIAL.
        READ TABLE lt_data_get INTO ls_data_get WITH KEY  pid = ls_file_u-pid
                                                          pid_item = ls_file_u-pid_item
                                                          DocumantYear = ls_file_u-document_year
                                                          Plant = ls_file_u-plant
                                                          Storagelocation = ls_file_u-storage_location
                                                          Material = ls_file_u-material.
      ELSE.
        SORT lt_data_get BY ConvertSapNo.
        READ TABLE lt_data_get INTO ls_data_get WITH KEY  ConvertSapNo = ls_file_u-convert_sap_no.
      ENDIF.


*  uuid
      IF ls_file_u-pid IS NOT INITIAL AND ls_file_u-pid_item IS NOT INITIAL.
        SELECT SINGLE *
            FROM ztb_inven_im1
            WHERE pid = @ls_data_get-pid
            AND pid_item = @ls_data_get-pid_item
            AND document_year = @ls_data_get-DocumantYear
            INTO @DATA(ls_inventory_db).

      ELSE.

        SELECT SINGLE *
            FROM ztb_inven_im1
            WHERE convert_sap_no = @ls_data_get-ConvertSapNo
            INTO @ls_inventory_db.
      ENDIF.

      IF ls_inventory_db IS NOT INITIAL.
        ls_inventory_upload-uuid = ls_inventory_db-uuid.
      ELSE.
        TRY.
            DATA(lv_cid) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "Error handling
        ENDTRY.
        ls_inventory_upload-uuid = lv_cid.
      ENDIF.

*  convert_sap_no
      ls_inventory_upload-convert_sap_no = ls_data_get-convertsapno.
*  plant
      ls_inventory_upload-plant = ls_data_get-plant.
*  pid
      ls_inventory_upload-pid = ls_data_get-pid.
*  pid_item
      ls_inventory_upload-pid_item = ls_data_get-pid_item.
*  document_year
      ls_inventory_upload-document_year = ls_data_get-DocumantYear.
*  phys_inv_doc
      ls_inventory_upload-phys_inv_doc = ls_data_get-Phys_inv_doc.
*  storage_location
      ls_inventory_upload-storage_location = ls_data_get-Storagelocation.
*  material
      ls_inventory_upload-material = ls_data_get-material.
*  doc_date
      ls_inventory_upload-doc_date = ls_data_get-docdate.
*  pda_date
      ls_inventory_upload-pda_date = ls_data_get-pdadate.
*  pi_status
      ls_inventory_upload-pi_status = ls_data_get-pistatus.
*  plant_count_date
      ls_inventory_upload-plant_count_date = ls_data_get-Plantcountdate.
*  count_date
      ls_inventory_upload-count_date = ls_data_get-countdate.
*  material_description
      ls_inventory_upload-material_description = ls_data_get-materialdescription.
*  batch
      ls_inventory_upload-batch = ls_data_get-batch.
*  sales_order
      ls_inventory_upload-sales_order = ls_data_get-salesorder.
*  sales_order_item
      ls_inventory_upload-sales_order_item = ls_data_get-salesorderitem.
*  spe_stok
      ls_inventory_upload-spe_stok = ls_data_get-Spestok.
*  spe_stok_num
      ls_inventory_upload-spe_stok_num = ls_data_get-Spestoknum.
*  stock_type
      ls_inventory_upload-stock_type = ls_data_get-stocktype.
*  book_qty
      ls_inventory_upload-book_qty = ls_data_get-bookqty.
*  book_qty_uom
      ls_inventory_upload-book_qty_uom = ls_data_get-bookqtyuom.
*  pda_qty
      ls_inventory_upload-pda_qty = ls_data_get-pdaqty.
*  entered_qty_pi
      ls_inventory_upload-entered_qty_pi = ls_data_get-enteredqtypi.
*  entered_qty_uom
      ls_inventory_upload-entered_qty_uom = ls_data_get-enteredqtyuom.



      IF ls_file_u-upload_status EQ 'S' AND ls_data_get-PiStatus = 'Not Counted'.
*  counted_qty
        ls_inventory_upload-counted_qty = ls_file_u-counted_qty.               " Update
*  counted_qty_uom
        ls_inventory_upload-counted_qty_uom = ls_file_u-counted_qty_uom.       " Update
*  zero_count
        ls_inventory_upload-zero_count = ls_file_u-zero_count.                 " Update
      ELSE.
*  counted_qty
        ls_inventory_upload-counted_qty = ls_data_get-countedqty.              " Reverse
*  counted_qty_uom
        ls_inventory_upload-counted_qty_uom = ls_data_get-countedqtyuom.       " Reverse
*  zero_count
        ls_inventory_upload-zero_count = ls_data_get-zerocount.                " Reverse
      ENDIF.



*  diff_qty
      ls_inventory_upload-diff_qty = ls_data_get-diffqty.
*  api_status
      ls_inventory_upload-api_status = ls_data_get-apistatus.
*  api_message
      ls_inventory_upload-api_message = ls_data_get-apimessage.
*  pda_time
      ls_inventory_upload-pda_time = ls_data_get-pdatime.
*  counter
      ls_inventory_upload-counter = ls_data_get-counter.
*  api_date
      ls_inventory_upload-api_date = ls_data_get-apidate.
*  api_time
      ls_inventory_upload-api_time = ls_data_get-apitime.
*  user_upload
      ls_inventory_upload-user_upload = ls_file_u-user_upload.
*  upload_time
      ls_inventory_upload-upload_time = lv_date.
*  upload_date
      ls_inventory_upload-upload_date = lv_time.



      IF ls_data_get-PiStatus = 'Not Counted'.
*  upload_status
        ls_inventory_upload-upload_status = ls_file_u-upload_status.
*  upload_message
        ls_inventory_upload-upload_message = ls_file_u-upload_message.
      ELSE.
*  upload_status
        ls_inventory_upload-upload_status = |F|.
*  upload_message
        ls_inventory_upload-upload_message = |Chứng từ kiểm kê { ls_data_get-pid }, Line Item { ls_data_get-pid_item } có PI Status không hợp lệ!|.
      ENDIF.




**  created_by
*        ls_inventory_upload-created_by = ls_inventory_db-created_by.
**  created_at
*        ls_inventory_upload-created_at = ls_inventory_db-created_at.
**  last_changed_by
*        ls_inventory_upload-last_changed_by = ls_inventory_db-last_changed_by.
**  last_changed_at
*        ls_inventory_upload-last_changed_at = ls_inventory_db-last_changed_at.
*  action_type
      ls_inventory_upload-action_type = |U|.
*  edit
      ls_inventory_upload-edit = ls_data_get-edit.


      APPEND ls_inventory_upload TO lt_inventory_upload.
      CLEAR: ls_inventory_upload, ls_data_get, ls_file_u.
    ENDLOOP.

    MODIFY ztb_inven_im1 FROM TABLE @lt_inventory_upload.
  ENDMETHOD.

  METHOD convert_date.
    DATA: lv_serial TYPE decfloat34,
          lv_days_i TYPE i,
          lv_dats   TYPE d.

    lv_serial = CONV decfloat34( i_date ).

    lv_days_i = CONV i( lv_serial ).

    lv_dats = c_excel_base + lv_days_i.     "ngày là DATS YYYYMMDD

    rv_dats = CONV string( lv_dats ).
  ENDMETHOD.

  METHOD data_valid_check.
    DATA:
*      lv_status  TYPE string,
      lv_message TYPE string,
      lv_boolean TYPE abap_boolean VALUE abap_false.

    IF iv_file_upload IS NOT INITIAL.
      e_respond = iv_file_upload.
      DATA(lt_data_get) = iv_db_check.

      SORT lt_data_get BY pid pid_item DocumantYear ASCENDING.
      READ TABLE lt_data_get INTO DATA(ls_inventory) WITH KEY pid = e_respond-pid pid_item = e_respond-pid_item DocumantYear = e_respond-fiscal_year.

      " check data mismatch
      IF ls_inventory-ConvertSapNo <> e_respond-convert_sap_no.
        lv_boolean = abap_true.

        IF e_respond-upload_message IS NOT INITIAL.
          e_respond-upload_message =  e_respond-upload_message && ', Convert SAP Number ' && e_respond-convert_sap_no &&  ' không tồn tại'.
        ELSE.
          e_respond-upload_message =  e_respond-upload_message && ' Convert SAP Number ' && e_respond-convert_sap_no &&  ' không tồn tại'.
        ENDIF.
      ENDIF.

      IF ls_inventory-pid <> e_respond-pid.
        lv_boolean = abap_true.

        IF e_respond-upload_message IS NOT INITIAL.
          e_respond-upload_message =  e_respond-upload_message && ', Chứng từ kiểm kê ' && e_respond-pid &&  ' không tồn tại'.
        ELSE.
          e_respond-upload_message =  e_respond-upload_message && ' Chứng từ kiểm kê ' && e_respond-pid &&  ' không tồn tại'.
        ENDIF.
      ENDIF.

      IF ls_inventory-pid_item <> e_respond-pid_item.
        lv_boolean = abap_true.

        IF e_respond-upload_message IS NOT INITIAL.
          e_respond-upload_message =  e_respond-upload_message && ', Line item ' && e_respond-pid_item && ' của chứng từ kiểm kê ' && e_respond-pid &&  ' không tồn tại'.
        ELSE.
          e_respond-upload_message =  e_respond-upload_message && ' Line item ' && e_respond-pid_item && ' của chứng từ kiểm kê ' && e_respond-pid &&  ' không tồn tại'.
        ENDIF.
      ENDIF.

      IF ls_inventory-DocumantYear <> e_respond-fiscal_year.
        lv_boolean = abap_true.

        IF e_respond-upload_message IS NOT INITIAL.
          e_respond-upload_message =  e_respond-upload_message && ', Document Year ' && e_respond-fiscal_year && ' không đồng nhất'.
        ELSE.
          e_respond-upload_message =  e_respond-upload_message && ' Document Year ' && e_respond-fiscal_year && ' không đồng nhất'.
        ENDIF.
      ENDIF.

      IF ls_inventory-material <> e_respond-material.
        lv_boolean = abap_true.

        IF e_respond-upload_message IS NOT INITIAL.
          e_respond-upload_message =  e_respond-upload_message && ', Material ' && e_respond-material && ' không đồng nhất'.
        ELSE.
          e_respond-upload_message =  e_respond-upload_message && ' Material ' && e_respond-material && ' không đồng nhất'.
        ENDIF.
      ENDIF.

      IF ls_inventory-plant <> e_respond-plant.
        lv_boolean = abap_true.

        IF e_respond-upload_message IS NOT INITIAL.
          e_respond-upload_message =  e_respond-upload_message && ', Plant ' && e_respond-batch && ' không đồng nhất'.
        ELSE.
          e_respond-upload_message =  e_respond-upload_message && ' Plant ' && e_respond-batch && ' không đồng nhất'.
        ENDIF.
      ENDIF.

      IF ls_inventory-Storagelocation <> e_respond-storage_location.
        lv_boolean = abap_true.

        IF e_respond-upload_message IS NOT INITIAL.
          e_respond-upload_message =  e_respond-upload_message && ', Storage Location ' && e_respond-batch && ' không đồng nhất'.
        ELSE.
          e_respond-upload_message =  e_respond-upload_message && ' Storage Location ' && e_respond-batch && ' không đồng nhất'.
        ENDIF.
      ENDIF.

      IF ls_inventory-batch <> e_respond-batch.
        lv_boolean = abap_true.

        IF e_respond-upload_message IS NOT INITIAL.
          e_respond-upload_message =  e_respond-upload_message && ', Batch ' && e_respond-batch && ' không đồng nhất'.
        ELSE.
          e_respond-upload_message =  e_respond-upload_message && ' Batch ' && e_respond-batch && ' không đồng nhất'.
        ENDIF.
      ENDIF.

      IF ls_inventory-Spestok <> e_respond-spe_stok.
        lv_boolean = abap_true.

        IF e_respond-upload_message IS NOT INITIAL.
          e_respond-upload_message =  e_respond-upload_message && ', Special Stock ' && e_respond-batch && ' không đồng nhất'.
        ELSE.
          e_respond-upload_message =  e_respond-upload_message && ' Special Stock ' && e_respond-batch && ' không đồng nhất'.
        ENDIF.
      ENDIF.

      IF ls_inventory-Spestoknum <> e_respond-spe_stok_num.
        lv_boolean = abap_true.

        IF e_respond-upload_message IS NOT INITIAL.
          e_respond-upload_message =  e_respond-upload_message && ', Supplier’s Account Number ' && e_respond-batch && ' không đồng nhất'.
        ELSE.
          e_respond-upload_message =  e_respond-upload_message && ' Supplier’s Account Number ' && e_respond-batch && ' không đồng nhất'.
        ENDIF.
      ENDIF.

      IF ls_inventory-Salesorder <> e_respond-sales_order.
        lv_boolean = abap_true.

        IF e_respond-upload_message IS NOT INITIAL.
          e_respond-upload_message =  e_respond-upload_message && ', Sales Order ' && e_respond-batch && ' không đồng nhất'.
        ELSE.
          e_respond-upload_message =  e_respond-upload_message && ' Sales Order ' && e_respond-batch && ' không đồng nhất'.
        ENDIF.
      ENDIF.

      IF ls_inventory-SalesOrderItem <> e_respond-sales_order_item.
        lv_boolean = abap_true.

        IF e_respond-upload_message IS NOT INITIAL.
          e_respond-upload_message =  e_respond-upload_message && ', Item no. of Sales Order ' && e_respond-batch && ' không đồng nhất'.
        ELSE.
          e_respond-upload_message =  e_respond-upload_message && ' Item no. of Sales Order ' && e_respond-batch && ' không đồng nhất'.
        ENDIF.
      ENDIF.

      " if lv_boolean true, e_respond-upload_status = 'E'
      IF lv_boolean = abap_true.
        e_respond-upload_status = 'F'.   " Error
      ELSE.
        e_respond-upload_status = 'S'.   " Success
        e_respond-upload_message = 'Success'.
      ENDIF.

    ELSE.
      e_respond-upload_status = 'F'.   " Error
      e_respond-upload_message = 'Upload fail, data not excited'.
      " return message not found.
    ENDIF.
  ENDMETHOD.

  METHOD UpdateCount.
    READ TABLE keys INDEX 1 INTO DATA(k).

    DATA: lt_inventory_update TYPE TABLE OF ztb_inven_im1,
          ls_inventory_update TYPE ztb_inven_im1.

    DATA:
      lr_pid            TYPE tt_ranges,
      lr_pid_item       TYPE tt_ranges,
      lr_documentyear   TYPE tt_ranges,
      lr_plant          TYPE tt_ranges,
      lr_store_location TYPE tt_ranges,
      lr_material       TYPE tt_ranges,
      lr_convert_sap_no TYPE tt_ranges,
      lr_pi_status      TYPE tt_ranges,
      lr_api_status     TYPE tt_ranges,
      lr_uuid           TYPE tt_ranges.

    IF k-pid IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-pid ) TO lr_pid.
    ENDIF.
    IF k-pid_item IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-pid_item ) TO lr_pid_item.
    ENDIF.
    IF k-DocumantYear IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-DocumantYear ) TO lr_documentyear.
    ENDIF.
    IF k-plant IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-plant ) TO lr_plant.
    ENDIF.
    IF k-Storagelocation IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-Storagelocation ) TO lr_store_location.
    ENDIF.
    IF k-material IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-material ) TO lr_material.
    ENDIF.
    IF k-ConvertSapNo IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-ConvertSapNo ) TO lr_convert_sap_no.
    ENDIF.

    " Call method get for IM data
    CALL METHOD zcl_get_inventory_data_im=>get_im_data
      EXPORTING
        iv_pid            = lr_pid
        iv_pid_item       = lr_pid_item
        iv_document_year  = lr_documentyear
        iv_plant          = lr_plant
        iv_store_loca     = lr_store_location
        iv_matnr          = lr_material
        iv_convert_sap_no = lr_convert_sap_no
      IMPORTING
        ev_result         = DATA(lt_data_get).

    SORT lt_data_get BY pid pid_item DocumantYear Plant Storagelocation Material ConvertSapNo.
    READ TABLE lt_data_get INTO DATA(ls_data_get) WITH KEY pid = k-pid
                                                           pid_item = k-pid_item
                                                           DocumantYear = k-DocumantYear
                                                           Plant = k-plant
                                                           Storagelocation = k-Storagelocation
                                                           Material = k-material
                                                           ConvertSapNo = k-ConvertSapNo.
    IF ls_data_get-PiStatus = 'Adjusted'.
      " Throw message PI status không hợp lệ
      APPEND VALUE #(
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |PI Status không hợp lệ để thực hiện Change Count!|
        )
      ) TO reported-zi_inventory_data_im.

      APPEND VALUE #(
        %tky = k-%tky
      ) TO failed-zi_inventory_data_im.

      RETURN.

    ELSE.

*  uuid
      IF ls_data_get-pid IS NOT INITIAL AND ls_data_get-pid_item IS NOT INITIAL.
        SELECT SINGLE *
            FROM ztb_inven_im1
            WHERE pid = @ls_data_get-pid
            AND pid_item = @ls_data_get-pid_item
            AND document_year = @ls_data_get-DocumantYear
            INTO @DATA(ls_inventory_db).

      ELSE.

        SELECT SINGLE *
            FROM ztb_inven_im1
            WHERE convert_sap_no = @ls_data_get-ConvertSapNo
            INTO @ls_inventory_db.
      ENDIF.

      IF ls_inventory_db IS NOT INITIAL.
        ls_inventory_update-uuid = ls_inventory_db-uuid.
      ELSE.
        TRY.
            DATA(lv_cid) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "Error handling
        ENDTRY.
        ls_inventory_update-uuid = lv_cid.
      ENDIF.

*  convert_sap_no
      ls_inventory_update-convert_sap_no = ls_data_get-convertsapno.
*  plant
      ls_inventory_update-plant = ls_data_get-plant.
*  pid
      ls_inventory_update-pid = ls_data_get-pid.
*  pid_item
      ls_inventory_update-pid_item = ls_data_get-pid_item.
*  document_year
      ls_inventory_update-document_year = ls_data_get-DocumantYear.
*  phys_inv_doc
      ls_inventory_update-phys_inv_doc = ls_data_get-Phys_inv_doc.
*  storage_location
      ls_inventory_update-storage_location = ls_data_get-Storagelocation.
*  material
      ls_inventory_update-material = ls_data_get-material.
*  doc_date
      ls_inventory_update-doc_date = ls_data_get-docdate.
*  pda_date
      ls_inventory_update-pda_date = ls_data_get-pdadate.
*  pi_status
      ls_inventory_update-pi_status = ls_data_get-pistatus.
*  plant_count_date
      ls_inventory_update-plant_count_date = ls_data_get-Plantcountdate.



      IF k-%param-counted_date IS NOT INITIAL.
*  count_date
        ls_inventory_update-count_date = k-%param-counted_date.
      ELSE.
        ls_inventory_update-count_date = ls_data_get-countdate.
      ENDIF.



*  material_description
      ls_inventory_update-material_description = ls_data_get-materialdescription.
*  batch
      ls_inventory_update-batch = ls_data_get-batch.
*  sales_order
      ls_inventory_update-sales_order = ls_data_get-salesorder.
*  sales_order_item
      ls_inventory_update-sales_order_item = ls_data_get-salesorderitem.
*  spe_stok
      ls_inventory_update-spe_stok = ls_data_get-Spestok.
*  spe_stok_num
      ls_inventory_update-spe_stok_num = ls_data_get-Spestoknum.
*  stock_type
      ls_inventory_update-stock_type = ls_data_get-stocktype.
*  book_qty
      ls_inventory_update-book_qty = ls_data_get-bookqty.
*  book_qty_uom
      ls_inventory_update-book_qty_uom = ls_data_get-bookqtyuom.
*  pda_qty
      ls_inventory_update-pda_qty = ls_data_get-pdaqty.
*  entered_qty_pi
      ls_inventory_update-entered_qty_pi = ls_data_get-enteredqtypi.
*  entered_qty_uom
      ls_inventory_update-entered_qty_uom = ls_data_get-enteredqtyuom.



      IF k-%param-counted_qty IS NOT INITIAL.
*  counted_qty
        ls_inventory_update-counted_qty = k-%param-counted_qty.                 " Update
      ELSE.
        ls_inventory_update-counted_qty = ls_data_get-CountedQty.
      ENDIF.



*  counted_qty_uom
      ls_inventory_update-counted_qty_uom = ls_data_get-countedqtyuom.



      IF ls_inventory_update-counted_qty > 0.
*  zero_count
        ls_inventory_update-zero_count = ||.
      ELSEIF ls_inventory_update-counted_qty = 0.
*  zero_count
        ls_inventory_update-zero_count = |X|.
      ENDIF.



*  diff_qty
      ls_inventory_update-diff_qty = ls_data_get-diffqty.
*  api_status
      ls_inventory_update-api_status = ls_data_get-apistatus.
*  api_message
      ls_inventory_update-api_message = ls_data_get-apimessage.
*  pda_time
      ls_inventory_update-pda_time = ls_data_get-pdatime.
*  counter
      ls_inventory_update-counter = ls_data_get-counter.
*  api_date
      ls_inventory_update-api_date = ls_data_get-apidate.
*  api_time
      ls_inventory_update-api_time = ls_data_get-apitime.
*  user_upload
      ls_inventory_update-user_upload = ls_data_get-UserUpload.
*  upload_time
      ls_inventory_update-upload_time = ls_data_get-uploadtime.
*  upload_date
      ls_inventory_update-upload_date = ls_data_get-uploaddate.
*  upload_status
      ls_inventory_update-upload_status = ls_data_get-uploadstatus.
*  upload_message
      ls_inventory_update-upload_message = ls_data_get-uploadmessage.
**  created_by
*        ls_inventory_upload-created_by = ls_inventory_db-created_by.
**  created_at
*        ls_inventory_upload-created_at = ls_inventory_db-created_at.
**  last_changed_by
*        ls_inventory_upload-last_changed_by = ls_inventory_db-last_changed_by.
**  last_changed_at
*        ls_inventory_upload-last_changed_at = ls_inventory_db-last_changed_at.
*  action_type
      ls_inventory_update-action_type = ls_data_get-ActionType.
*  edit
      ls_inventory_update-edit = |X|.

      APPEND ls_inventory_update TO lt_inventory_update.
      CLEAR: ls_inventory_update, ls_data_get.

    ENDIF.

    MODIFY ztb_inven_im1 FROM TABLE @lt_inventory_update.

    CLEAR lt_data_get.

    " Call method get for IM data
    CALL METHOD zcl_get_inventory_data_im=>get_im_data
      EXPORTING
        iv_pid            = lr_pid
        iv_pid_item       = lr_pid_item
        iv_document_year  = lr_documentyear
        iv_plant          = lr_plant
        iv_store_loca     = lr_store_location
        iv_matnr          = lr_material
        iv_convert_sap_no = lr_convert_sap_no
      IMPORTING
        ev_result         = lt_data_get.

    SORT lt_data_get BY pid pid_item DocumantYear Plant Storagelocation Material ConvertSapNo.
    READ TABLE lt_data_get INTO ls_data_get WITH KEY pid = k-pid
                                                     pid_item = k-pid_item
                                                     DocumantYear = k-DocumantYear
                                                     Plant = k-plant
                                                     Storagelocation = k-Storagelocation
                                                     Material = k-material
                                                     ConvertSapNo = k-ConvertSapNo.

    IF ls_data_get IS INITIAL.
      SORT lt_data_get BY ConvertSapNo.
      READ TABLE lt_data_get INTO ls_data_get WITH KEY  ConvertSapNo = k-ConvertSapNo.
    ENDIF.

    result = VALUE #( FOR key IN keys ( Uuid = k-Uuid
                                        pid = k-pid
                                        Pid_item = k-pid_item
                                        DocumantYear = k-DocumantYear
                                        Plant = k-Plant
                                        Storagelocation = k-Storagelocation
                                        ConvertSapNo = k-ConvertSapNo
                                        Material = k-Material
                                        %param = CORRESPONDING #( ls_data_get )
                                      )
                ).

    IF k-%param-counted_qty IS INITIAL AND k-%param-counted_date IS INITIAL.
      " Throw success message
      APPEND VALUE #(
        %tky = k-%tky
        %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-information
                  text     = |C...Cả 2 đều...trống ???|
                )
      ) TO reported-zi_inventory_data_im.
    ELSE.
      " Throw success message
      APPEND VALUE #(
        %tky = k-%tky
        %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-success
                  text     = |Updated successfully!|
                )
      ) TO reported-zi_inventory_data_im.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_INVENTORY_DATA_IM DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_INVENTORY_DATA_IM IMPLEMENTATION.

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

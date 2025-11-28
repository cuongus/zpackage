CLASS lhc_ZI_INVENTORY_DATA_ROOT DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:

      BEGIN OF ty_range_option,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE string,
        high   TYPE string,
      END OF ty_range_option,

      tt_ranges TYPE TABLE OF ty_range_option,

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
        procedure            TYPE string,
        count_date           TYPE string,
        warehouse_number     TYPE string,
        storage_type         TYPE string,
        storage_bin          TYPE string,
        material             TYPE string,
        material_description TYPE string,
        batch                TYPE string,
        spe_stok             TYPE string,
        spe_stok_num         TYPE string,
        sales_order          TYPE string,
        sales_order_item     TYPE string,
        stock_type           TYPE string,
        book_quantity        TYPE string,
        book_qty_uom         TYPE string,
        pda_quantity         TYPE string,
        counted_quantity     TYPE string,   " Update
        counted_qty_uom      TYPE string,   " Update
        entered_qty_in_pi    TYPE string,
        entered_qty_uom      TYPE string,
        zero_count           TYPE string,   " Update
        difference_quantity  TYPE string,
        api_status           TYPE string,
        api_message          TYPE string,
        pda_date             TYPE string,
        pda_time             TYPE string,
        counter              TYPE string,
        api_date             TYPE string,
        api_time             TYPE string,
        pi_status            TYPE string,
        user_upload          TYPE string,
        upload_time          TYPE string,   " Tự sinh ra
        upload_date          TYPE string,   " Tự sinh ra
        upload_status        TYPE string,   " Tự sinh ra
        upload_message       TYPE string,   " Tự sinh ra
        action_type          TYPE string,
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

      tt_zc_inventory_data TYPE TABLE OF zc_inventory_data.

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
      IMPORTING entities FOR CREATE zi_inventory_data_root.

    METHODS update FOR MODIFY
      IMPORTING keys FOR UPDATE zi_inventory_data_root.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_inventory_data_root RESULT result.

*    METHODS lock FOR LOCK
*      IMPORTING keys FOR LOCK zi_inventory_data_root.

    METHODS Count FOR MODIFY
      IMPORTING keys FOR ACTION zi_inventory_data_root~Count.

    METHODS PostAPI FOR MODIFY
      IMPORTING keys FOR ACTION zi_inventory_data_root~PostAPI.

    METHODS CreatPI FOR MODIFY
      IMPORTING keys FOR ACTION zi_inventory_data_root~CreatePI.

    METHODS DownloadFile FOR MODIFY
      IMPORTING keys FOR ACTION zi_inventory_data_root~DownloadFile RESULT result.

    METHODS UploadFile FOR MODIFY
      IMPORTING keys FOR ACTION zi_inventory_data_root~UploadFile.

*    METHODS get_instance_features FOR INSTANCE FEATURES
*      IMPORTING keys REQUEST requested_features FOR ZI_INVENTORY_DATA_ROOT RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_inventory_data_root RESULT result.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zi_inventory_data_root.
    METHODS updatecount FOR MODIFY
      IMPORTING keys FOR ACTION zi_inventory_data_root~updatecount RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_inventory_data_root RESULT result.

    METHODS convert_date IMPORTING i_date         TYPE string
                         RETURNING VALUE(rv_dats) TYPE string.

    METHODS data_valid_check
      IMPORTING
        iv_file_upload TYPE ty_file_upload
        iv_db_check    TYPE tt_zc_inventory_data
      EXPORTING
        e_respond      TYPE ty_file_upload.

ENDCLASS.

CLASS lhc_ZI_INVENTORY_DATA_ROOT IMPLEMENTATION.

  METHOD update.

    LOOP AT keys INTO DATA(key).
      DATA:lv_pi_status TYPE string.

      SELECT *
          FROM i_ewm_physinvtryitemrow
          WHERE   EWMWarehouse = @key-Warehouse_number
          AND PhysicalInventoryDocNumber  = @key-Pid
          AND PhysicalInventoryItemNumber  = @key-Pid_item
          AND PhysicalInventoryDocYear  = @key-DocumentYear
          AND LineIndexOfPInvItem  = @key-LineIndexOfPInvItem
          INTO TABLE @DATA(lt_data).

      READ TABLE lt_data INTO DATA(ls_data) INDEX 1.

      SELECT SINGLE *
          FROM i_ewm_physicalinventoryitem
          WHERE PhysicalInventoryDocNumber = @ls_data-PhysicalInventoryDocNumber
          AND EWMWarehouse = @ls_data-EWMWarehouse
          INTO @DATA(lW_INVENTORYITEM).


      IF lw_INVENTORYITEM-EWMPhysicalInventoryStatus = 'POST' OR lw_INVENTORYITEM-EWMPhysicalInventoryStatus = 'RECO'.
        APPEND VALUE #(
*          %tky = ls_entity-%tky
          %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = |Record này đã được Post, không thể chỉnh sửa.|
                  )
        ) TO reported-zi_inventory_data_root.

      ELSE.
        DATA(lv_check) = 'X'.

        SELECT SINGLE uuid
            FROM ztb_inventory1
            WHERE pid = @key-pid
            AND pid_item = @key-pid_item
            AND document_year = @key-DocumentYear
            AND plant = @key-Plant
            INTO @DATA(lv_existing_uuid).
        IF sy-subrc = 0.
          UPDATE ztb_inventory1 SET counted_qty = @key-countedqty , edit = @lv_check WHERE uuid = @lv_existing_uuid.
        ELSE.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
          DATA(ls_ztb) = VALUE ztb_inventory1(
            uuid           = lv_uuid
*            client         = sy-mandt
            pid            = key-pid
            pid_item       = key-pid_item
            document_year  = key-DocumentYear
            lineindexofpinvitem = key-LineIndexOfPInvItem
            edit = lv_check
            warehouse_number  = key-Warehouse_number
            counted_qty    = key-countedqty
          ).

          INSERT ztb_inventory1 FROM @ls_ztb.
        ENDIF.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

*  METHOD lock.
*  ENDMETHOD.

  METHOD Count.
    TYPES: BEGIN OF ty_whse_header,
             odata_etag                     TYPE string,
             EWMWarehouse                   TYPE string,
             PhysicalInventoryDocNumber     TYPE string,
             physicalinventorydocyear       TYPE string,
             physicalinventoryitemnumber    TYPE string,
             physicalinventorydocumentuuid  TYPE string,
             physicalinventorydocumenttype  TYPE string,
             ewmphysinvtrydifferencereason  TYPE string,
             ewmphysicalinventorypriority   TYPE string,
             physicalinventorystatustext    TYPE string,
             physinventorycrtnutcdatetime   TYPE string,
             pinvcountedutcdatetime         TYPE string,
             physicalinventorycountusername TYPE string,
             warehouseorder                 TYPE string,
             pinvdocumentitemisprinted      TYPE abap_bool,
             physicalinventoryisblock       TYPE abap_bool,
             pinvbookquantityisfreeze       TYPE abap_bool,
             ewmstoragetype                 TYPE string,
             ewmstoragebin                  TYPE string,
             physicalinventoryarea          TYPE string,
             activityarea                   TYPE string,
             productuuid                    TYPE string,
             product                        TYPE string,
             batchuuid                      TYPE string,
             batch                          TYPE string,
             ewmstocktype                   TYPE string,
             ewmstockusage                  TYPE string,
             ewmstockowner                  TYPE string,
             stockownername                 TYPE string,
             entitledtodisposeparty         TYPE string,
             nameofentitledtodisposeparty   TYPE string,
             stockdocumentcategory          TYPE string,
             stockdocumentnumber            TYPE string,
             stockitemnumber                TYPE string,
             wbselementexternalid           TYPE string,
             wbselementinternalid           TYPE string,
             specialstockidfgsalesorder     TYPE string,
             specialstockidfgsalesorderitem TYPE string,
             physicalinventoryrefdocyear    TYPE string,
             ewmrefphysicalinventorydoc     TYPE string,
             physicalinventoryrefdocitem    TYPE string,
             pinvfreedefinedreftext         TYPE string,
             pinvitemchgutcdatetime         TYPE string,
             sap__messages                  TYPE string,
           END OF ty_whse_header.


    TYPES: BEGIN OF ty_whse_item,
             odata_etag                     TYPE string,
             ewmwarehouse                   TYPE string,
             physicalinventorydocnumber     TYPE string,
             physicalinventorydocyear       TYPE string,
             physicalinventoryitemnumber    TYPE string,
             lineindexofpinvitem            TYPE i,
             pinvquantitysequence           TYPE i,
             physicalinventoryitemlevel     TYPE i,
             pinvitemparenttype             TYPE string,
             ewmstoragebin                  TYPE string,
             ewmstoragetype                 TYPE string,
             parenthandlingunitnumber       TYPE string,
             physicalinventoryitemtype      TYPE string,
             handlingunitnumber             TYPE string,
             product                        TYPE string,
             productuuid                    TYPE string,
             batchuuid                      TYPE string,
             batch                          TYPE string,
             serialnumberrequiredlevel      TYPE string,
             ewmstocktype                   TYPE string,
             ewmstockowner                  TYPE string,
             stockownerpartnerrole          TYPE string,
             ewmstockusage                  TYPE string,
             entitledtodisposeparty         TYPE string,
             entitledtodisposepartnerrole   TYPE string,
             stockdocumentcategory          TYPE string,
             stockdocumentnumber            TYPE string,
             stockitemnumber                TYPE string,
             wbselementexternalid           TYPE string,
             wbselementinternalid           TYPE string,
             specialstockidfgsalesorder     TYPE string,
             specialstockidfgsalesorderitem TYPE string,
             documentreltdstockdoccat       TYPE string,
             whsequalityinspectiontype      TYPE string,
             qualityinspectiondocuuid       TYPE string,
             stockidentificationnumber      TYPE string,
             documentreltdstockdocuuid      TYPE string,
             documentreltdstockdocitemuuid  TYPE string,
             whsetaskgoodsreceiptdatetime   TYPE string,
             shelflifeexpirationdate        TYPE string, "null có thể để string
             countryoforigin                TYPE string,
             MatlBatchIsInRstrcdUseStock    TYPE abap_bool,
             HndlgUnitItemCountedIsEmpty    TYPE abap_bool,
             HndlgUnitItemCountedIsComplete TYPE abap_bool,
             HndlgUnitItemCountedIsNotExist:TYPE abap_bool,

             packagingmaterial              TYPE string,
             handlingunittype               TYPE string,
             ewmstoragebinisempty           TYPE abap_bool,
             pinviszerocount                TYPE abap_bool,
             requestedquantityunit          TYPE string,
             requestedquantity              TYPE decfloat16,
             pinvitemchgutcdatetime         TYPE string,
             sap__messages                  TYPE string,
           END OF ty_whse_item.



    DATA: lw_username    TYPE string,
          lw_password    TYPE string,
          ls_whse_header TYPE ty_whse_header,
          ls_whse_item   TYPE ty_whse_item,
          lv_json_header TYPE string,
          lv_json_item   TYPE string,
          lw_json_body   TYPE string,
          e_response     TYPE string,
*          gs_data     TYPE zc_inventory_data_im,
          e_code         TYPE i.
    DATA: lw_date TYPE zde_Date.

    SELECT SINGLE * FROM ztb_api_auth
      WHERE systemid = 'CASLA'
          INTO @DATA(ls_api_auth).

    lw_username = ls_api_auth-api_user.
    lw_password = ls_api_auth-api_password.
    LOOP AT keys INTO DATA(key).

      SELECT SINGLE *
           FROM i_ewm_physinvtryitemrow
           WHERE   EWMWarehouse = @key-Warehouse_number
               AND PhysicalInventoryDocNumber  = @key-Pid
               AND PhysicalInventoryItemNumber  = @key-Pid_item
               AND PhysicalInventoryDocYear  = @key-DocumentYear
               AND LineIndexOfPInvItem  = @key-LineIndexOfPInvItem
           INTO @DATA(ls_data).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      SELECT SINGLE
 *
    FROM i_ewm_physicalinventoryitem
    WHERE PhysicalInventoryDocNumber = @ls_data-PhysicalInventoryDocNumber
 AND   EWMWarehouse = @ls_data-EWMWarehouse
 AND PhysicalInventoryItemNumber = @ls_data-PhysicalInventoryItemNumber
    INTO @DATA(ls_INVENTORYITEM).

*      SELECT SINGLE * FROM ztb_inventory1
*        WHERE pid = @key-pid
*          AND pid_item = @key-pid_item
*          AND document_year = @key-DocumentYear
*          AND warehouse_number = @key-warehouse_number
*          AND lineindexofpinvitem = @key-lineindexofpinvitem
*          INTO @DATA(ls_inventory).

      DATA:lv_uuid32       TYPE string,
           lv_uuid32_1     TYPE string,
           lv_uuid_1       TYPE string,
           lv_uuid32_batch TYPE string,
           lv_uuid_batch   TYPE string,
           lv_uuid         TYPE string.

      lv_uuid32 = ls_data-PhysicalInventoryDocumentUUID.
      lv_uuid = lv_uuid32+0(8) && '-' &&
                lv_uuid32+8(4) && '-' &&
                lv_uuid32+12(4) && '-' &&
                lv_uuid32+16(4) && '-' &&
                lv_uuid32+20(12).


      lv_uuid32_1 = ls_data-ProductUUID.
      lv_uuid_1 = lv_uuid32_1+0(8) && '-' &&
                lv_uuid32_1+8(4) && '-' &&
                lv_uuid32_1+12(4) && '-' &&
                lv_uuid32_1+16(4) && '-' &&
                lv_uuid32_1+20(12).


      lv_uuid32_batch = ls_data-BatchUUID.
      lv_uuid_batch = lv_uuid32_batch+0(8) && '-' &&
                lv_uuid32_batch+8(4) && '-' &&
                lv_uuid32_batch+12(4) && '-' &&
               lv_uuid32_batch+16(4) && '-' &&
                lv_uuid32_batch+20(12).

      DATA:lv_phys_crtn    TYPE string,
           lv_pinv_counted TYPE string.
*DATA(lv_pinv_chg) TYPE string.

*      DATA:lv_phys_crtn_s TYPE string.
*      lv_phys_crtn_s = |{ ls_inventoryitem-PhysInventoryCrtnUTCDateTime }|.
*      lv_phys_crtn = lv_phys_crtn_s+0(4) && '-' &&
*                     lv_phys_crtn_s+4(2) && '-' &&
*                     lv_phys_crtn_s+6(2) && 'T' &&
*                     lv_phys_crtn_s+8(2) && ':' &&
*                     lv_phys_crtn_s+10(2) && ':' &&
*                     lv_phys_crtn_s+12(2) && '.' &&
*                     lv_phys_crtn_s+15(3) && 'Z'.

*      DATA:lv_phys_crtn_s_cou TYPE string.
*      lv_phys_crtn_s_cou = |{ ls_inventoryitem-PInvCountedUTCDateTime }|.
*      lv_pinv_counted  = lv_phys_crtn_s_cou+0(4) && '-' &&
*                     lv_phys_crtn_s_cou+4(2) && '-' &&
*                     lv_phys_crtn_s_cou+6(2) && 'T' &&
*                     lv_phys_crtn_s_cou+8(2) && ':' &&
*                     lv_phys_crtn_s_cou+10(2) && ':' &&
*                     lv_phys_crtn_s_cou+12(2) && '.' &&
*                     lv_phys_crtn_s_cou+15(3) && 'Z'.

*DATA(lw_test) = zcl_utility=>to_api_date( sy-datum ).

      SELECT SINGLE count_date,convert_sap_no,pi_status,edit,upload_status,api_status,counter
      FROM ztb_inventory1
      WHERE pid = @key-Pid
      AND pid_item = @key-Pid_item
      AND warehouse_number = @key-Warehouse_number
      INTO @DATA(ls_invent).

      DATA: lv_count_date   TYPE tzntstmpl,
            lv_date         TYPE d,
            lv_timestamp    TYPE timestampl,
            lv_time         TYPE t,
            lv_Counter      TYPE string,
            lv_stok_doc_num TYPE string.

      IF ls_data-EWMWarehouse = '1130'.
        lv_stok_doc_num = | 000000000000000000000000000{ ls_data-SpecialStockIdfgSalesOrder } |.
      ELSEIF ls_data-EWMWarehouse = '1110'.
        IF ls_data-SpecialStockIdfgSalesOrder IS NOT INITIAL.
          lv_stok_doc_num = ls_data-SpecialStockIdfgSalesOrder.
        ELSE.
          lv_stok_doc_num = ''.
        ENDIF.
      ENDIF.


      IF ls_invent-api_status = 'S' OR ls_invent-edit = 'X' OR ls_invent-upload_status = 'S'.

        lv_date = ls_invent-count_date.
        lv_time = '000000'.
        CONVERT DATE lv_date TIME lv_time INTO TIME STAMP lv_count_date TIME ZONE sy-zonlo.

      ELSE.
        lv_count_date = ls_inventoryitem-pinvcountedutcdatetime.
      ENDIF.

      IF ls_invent-api_status = 'S' OR ls_invent-upload_status = 'S'.

        lv_Counter = ls_invent-counter.

      ELSE.
        lv_Counter = ls_INVENTORYITEM-PhysicalInventoryCountUserName.
      ENDIF.




      IF lv_count_date IS INITIAL .
        APPEND VALUE #(
              %tky = key-%tky
              %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Count thất bại: Thiếu trường CountDate|
                      )
            ) TO reported-zi_inventory_data_root.
        RETURN.
      ELSEIF lv_Counter IS INITIAL.
        APPEND VALUE #(
              %tky = key-%tky
              %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Count thất bại: Thiếu trường Counter|
                      )
            ) TO reported-zi_inventory_data_root.
        RETURN.
      ENDIF.

      DATA(lv_doc_num) = | {  ls_data-PhysicalInventoryDocNumber ALPHA = OUT } |.
      DATA(lv_doc_item) = | {  ls_data-PhysicalInventoryItemNumber ALPHA = OUT } |.
      CONDENSE lv_doc_item NO-GAPS.
      CONDENSE lv_doc_num NO-GAPS.

      DATA lv_now TYPE tzntstmpl.
      GET TIME STAMP FIELD lv_now.

      DATA: lo_http_client  TYPE REF TO if_web_http_client,
            response        TYPE string,
            lv_response     TYPE string,
            lv_warehouse    TYPE string,
            lv_line_index   TYPE string,
            lv_quantity_seq TYPE string,
            lv_url          TYPE string,
            lv_url_get      TYPE string,
            lv_doc          TYPE string,
            lv_item         TYPE string,
            lv_year         TYPE string,
            ls_odata_return TYPE zst_odata_return.

      lv_url = |https://{ ls_api_auth-api_url }/sap/opu/odata4/sap/api_whse_physinvtryitem_2/srvd_a2x/sap/whsephysicalinventorydoc/0001/$batch|.
      lv_url_get = |https://{ ls_api_auth-api_url }/sap/opu/odata4/sap/api_whse_physinvtryitem_2/srvd_a2x/sap/whsephysicalinventorydoc/0001/WhsePhysicalInventoryItem|
     && |(EWMWarehouse='{ ls_data-EWMWarehouse }',|
       && |PhysicalInventoryDocNumber='{ lv_doc_num }',|
       && |PhysicalInventoryDocYear='{ ls_data-PhysicalInventoryDocYear }',|
       && |PhysicalInventoryItemNumber='{ lv_doc_item }')/_WhsePhysicalInventoryCntItem|.

      TRY.
*
          DATA(lo_http_destination) =
           cl_http_destination_provider=>create_by_url( lv_url_get ).
          DATA(lo_web_http_client) =
              cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
          DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).

          lo_web_http_request->set_header_fields( VALUE #(
             ( name = 'Accept' value = 'application/json' )
             ( name = 'DataServiceVersion' value = '4.0' )
             ( name = 'OData-Version' value = '4.0' )
             ( name = 'x-csrf-token' value = 'Fetch' )
          ) ).

          lo_web_http_request->set_authorization_basic(
              i_username = lw_username
              i_password = lw_password
          ).

          DATA(lo_response) = lo_web_http_client->execute( i_method = if_web_http_client=>get ).
          DATA(lv_token)    = lo_response->get_header_field( 'x-csrf-token' ).

          DATA(lv_json) = lo_response->get_text( ).

          DATA:lv_match TYPE string.
          FIND REGEX '"@odata\.etag"\s*:\s*"((?:\\.|[^"])*)"' IN lv_json SUBMATCHES lv_match.
          REPLACE ALL OCCURRENCES OF '\"' IN lv_match WITH '"'.

          "json mã header
          ls_whse_header-odata_etag                    = lv_Match.
          ls_whse_header-EWMWarehouse                   = ls_data-EWMWarehouse.
          ls_whse_header-PhysicalInventoryDocNumber     = lv_doc_num.
          ls_whse_header-PhysicalInventoryDocYear       = ls_data-PhysicalInventoryDocYear.
          ls_whse_header-PhysicalInventoryItemNumber    = lv_doc_item.
          ls_whse_header-PhysicalInventoryDocumentUUID  = lv_uuid.
          ls_whse_header-PhysicalInventoryDocumentType  = ls_data-PhysicalInventoryDocumentType.
          ls_whse_header-EWMPhysInvtryDifferenceReason  = 'STD'.
          ls_whse_header-EWMPhysicalInventoryPriority   = ls_INVENTORYITEM-EWMPhysicalInventoryPriority.
          ls_whse_header-PhysicalInventoryStatusText    = ls_INVENTORYITEM-EWMPhysicalInventoryStatus.
          ls_whse_header-PhysInventoryCrtnUTCDateTime   = zcl_utility=>tzntstmpl_to_iso8601( ls_INVENTORYITEM-PhysInventoryCrtnUTCDateTime )."'2017-04-13T15:51:04Z'.
          ls_whse_header-PInvCountedUTCDateTime         = zcl_utility=>tzntstmpl_to_iso8601( lv_count_date ).
          ls_whse_header-PhysicalInventoryCountUserName = lv_Counter.
          ls_whse_header-WarehouseOrder                 = ls_inventoryitem-WarehouseOrder.
          ls_whse_header-PInvDocumentItemIsPrinted      = abap_true.
          ls_whse_header-PhysicalInventoryIsBlock       = abap_true.
          ls_whse_header-PInvBookQuantityIsFreeze       = abap_false.
          ls_whse_header-EWMStorageType                 = ls_data-EWMStockType.
          ls_whse_header-EWMStorageBin                  = ls_data-EWMStorageBin.
          ls_whse_header-PhysicalInventoryArea         = ls_data-EWMStorageType && '_' && ls_data-EWMStorageBin(4). "vd: 1110_K001
          ls_whse_header-ActivityArea                  = ls_data-EWMStorageType.
          ls_whse_header-ProductUUID                   = lv_uuid_1.
          ls_whse_header-Product                       = ls_data-Product.
          ls_whse_header-BatchUUID                     =  lv_uuid_batch.
          ls_whse_header-Batch                         = ls_data-Batch .
          ls_whse_header-EWMStockType                  = ls_data-EWMStockType.
          ls_whse_header-EWMStockUsage                 = ls_data-EWMStockUsage.
          ls_whse_header-EWMStockOwner                 = ls_data-EWMStockOwner.
          ls_whse_header-StockOwnerName                = 'Nhà máy CASLA 1'.
          ls_whse_header-EntitledToDisposeParty        = ls_data-EntitledToDisposeParty.
          ls_whse_header-NameOfEntitledToDisposeParty  = 'Nhà máy CASLA 1'.
          ls_whse_header-StockDocumentCategory         = ls_data-StockDocumentCategory.
          ls_whse_header-StockDocumentNumber           = lv_stok_doc_num. "'000000000000000000000000000' && ls_data-SpecialStockIdfgSalesOrder.
          ls_whse_header-StockItemNumber               = ls_data-SpecialStockIdfgSalesOrder.
          ls_whse_header-WBSElementExternalID          = ls_data-WBSElementExternalID.
          ls_whse_header-WBSElementInternalID          = ls_data-WBSElementInternalID.
          ls_whse_header-SpecialStockIdfgSalesOrder    = ls_data-SpecialStockIdfgSalesOrder.
          ls_whse_header-SpecialStockIdfgSalesOrderItem = ls_data-SpecialStockIdfgSalesOrderItem.
          ls_whse_header-PhysicalInventoryRefDocYear   = '0000'.
          ls_whse_header-EWMRefPhysicalInventoryDoc    = '0'.
          ls_whse_header-PhysicalInventoryRefDocItem   = '0'.
          ls_whse_header-PInvFreeDefinedRefText        = ''.
          ls_whse_header-PInvItemChgUTCDateTime        = zcl_utility=>tzntstmpl_to_iso8601( lv_now )."''2025-10-09T09:11:19.050944Z'.
          ls_whse_header-SAP__Messages                  = VALUE #( ).

          " Convert header to JSON
          lv_json_header = /ui2/cl_json=>serialize(
              data        = ls_whse_header
              compress    = abap_true
              pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

          REPLACE ALL OCCURRENCES OF 'odataEtag'                  IN lv_json_header WITH '@odata.etag'.
          REPLACE ALL OCCURRENCES OF 'ewmwarehouse'              IN lv_json_header WITH 'EWMWarehouse'.
          REPLACE ALL OCCURRENCES OF 'physicalinventorydocnumber' IN lv_json_header WITH 'PhysicalInventoryDocNumber'.
          REPLACE ALL OCCURRENCES OF 'physicalinventorydocyear'  IN lv_json_header WITH 'PhysicalInventoryDocYear'.
          REPLACE ALL OCCURRENCES OF 'physicalinventoryitemnumber' IN lv_json_header WITH 'PhysicalInventoryItemNumber'.
          REPLACE ALL OCCURRENCES OF 'physicalinventorydocumentuuid' IN lv_json_header WITH 'PhysicalInventoryDocumentUUID'.
          REPLACE ALL OCCURRENCES OF 'physicalinventorydocumenttype' IN lv_json_header WITH 'PhysicalInventoryDocumentType'.
          REPLACE ALL OCCURRENCES OF 'ewmphysinvtrydifferencereason' IN lv_json_header WITH 'EWMPhysInvtryDifferenceReason'.
          REPLACE ALL OCCURRENCES OF 'ewmphysicalinventorypriority' IN lv_json_header WITH 'EWMPhysicalInventoryPriority'.
          REPLACE ALL OCCURRENCES OF 'physicalinventorystatustext' IN lv_json_header WITH 'PhysicalInventoryStatusText'.
          REPLACE ALL OCCURRENCES OF 'physinventorycrtnutcdatetime' IN lv_json_header WITH 'PhysInventoryCrtnUTCDateTime'.
          REPLACE ALL OCCURRENCES OF 'pinvcountedutcdatetime' IN lv_json_header WITH 'PInvCountedUTCDateTime'.
          REPLACE ALL OCCURRENCES OF 'physicalinventorycountusername' IN lv_json_header WITH 'PhysicalInventoryCountUserName'.
          REPLACE ALL OCCURRENCES OF 'warehouseorder' IN lv_json_header WITH 'WarehouseOrder'.
          REPLACE ALL OCCURRENCES OF 'pinvdocumentitemisprinted' IN lv_json_header WITH 'PInvDocumentItemIsPrinted'.
          REPLACE ALL OCCURRENCES OF 'physicalinventoryisblock' IN lv_json_header WITH 'PhysicalInventoryIsBlock'.
          REPLACE ALL OCCURRENCES OF 'pinvbookquantityisfreeze' IN lv_json_header WITH 'PInvBookQuantityIsFreeze'.
          REPLACE ALL OCCURRENCES OF 'ewmstoragetype' IN lv_json_header WITH 'EWMStorageType'.
          REPLACE ALL OCCURRENCES OF 'ewmstoragebin' IN lv_json_header WITH 'EWMStorageBin'.
          REPLACE ALL OCCURRENCES OF 'physicalinventoryarea' IN lv_json_header WITH 'PhysicalInventoryArea'.
          REPLACE ALL OCCURRENCES OF 'activityarea' IN lv_json_header WITH 'ActivityArea'.
          REPLACE ALL OCCURRENCES OF 'productuuid' IN lv_json_header WITH 'ProductUUID'.
          REPLACE ALL OCCURRENCES OF 'product' IN lv_json_header WITH 'Product'.
          REPLACE ALL OCCURRENCES OF 'batchuuid' IN lv_json_header WITH 'BatchUUID'.
          REPLACE ALL OCCURRENCES OF 'batch' IN lv_json_header WITH 'Batch'.
          REPLACE ALL OCCURRENCES OF 'ewmstocktype' IN lv_json_header WITH 'EWMStockType'.
          REPLACE ALL OCCURRENCES OF 'ewmstockusage' IN lv_json_header WITH 'EWMStockUsage'.
          REPLACE ALL OCCURRENCES OF 'ewmstockowner' IN lv_json_header WITH 'EWMStockOwner'.
          REPLACE ALL OCCURRENCES OF 'stockownername' IN lv_json_header WITH 'StockOwnerName'.
          REPLACE ALL OCCURRENCES OF 'entitledtodisposeparty' IN lv_json_header WITH 'EntitledToDisposeParty'.
          REPLACE ALL OCCURRENCES OF 'nameofEntitledToDisposeParty' IN lv_json_header WITH 'NameOfEntitledToDisposeParty'.
          REPLACE ALL OCCURRENCES OF 'stockdocumentcategory' IN lv_json_header WITH 'StockDocumentCategory'.
          REPLACE ALL OCCURRENCES OF 'stockdocumentnumber' IN lv_json_header WITH 'StockDocumentNumber'.
          REPLACE ALL OCCURRENCES OF 'stockitemnumber' IN lv_json_header WITH 'StockItemNumber'.
          REPLACE ALL OCCURRENCES OF 'wbselementexternalid' IN lv_json_header WITH 'WBSElementExternalID'.
          REPLACE ALL OCCURRENCES OF 'wbselementinternalid' IN lv_json_header WITH 'WBSElementInternalID'.
          REPLACE ALL OCCURRENCES OF 'specialstockidfgsalesorder' IN lv_json_header WITH 'SpecialStockIdfgSalesOrder'.
          REPLACE ALL OCCURRENCES OF 'SpecialStockIdfgSalesOrderitem' IN lv_json_header WITH 'SpecialStockIdfgSalesOrderItem'.
          REPLACE ALL OCCURRENCES OF 'physicalinventoryrefdocyear' IN lv_json_header WITH 'PhysicalInventoryRefDocYear'.
          REPLACE ALL OCCURRENCES OF 'ewmrefphysicalinventorydoc' IN lv_json_header WITH 'EWMRefPhysicalInventoryDoc'.
          REPLACE ALL OCCURRENCES OF 'physicalinventoryrefdocitem' IN lv_json_header WITH 'PhysicalInventoryRefDocItem'.
          REPLACE ALL OCCURRENCES OF 'pinvfreedefinedreftext' IN lv_json_header WITH 'PInvFreeDefinedRefText'.
          REPLACE ALL OCCURRENCES OF 'pinvitemchgutcdatetime' IN lv_json_header WITH 'PInvItemChgUTCDateTime'.
          REPLACE ALL OCCURRENCES OF 'sap__messages' IN lv_json_header WITH 'SAP__Messages'.


          DATA(lv_time_iso) = zcl_utility=>tzntstmpl_to_iso8601( lv_now ).
          REPLACE REGEX '\.\d+Z$' IN lv_time_iso WITH 'Z'.

          SELECT SINGLE counted_qty,pda_qty,edit,api_status,upload_status,counted_qty_uom
          FROM ztb_inventory1
        WHERE pid = @key-pid
          AND pid_item = @key-pid_item
          AND document_year = @key-DocumentYear
          AND warehouse_number = @key-warehouse_number
*          AND lineindexofpinvitem = @key-lineindexofpinvitem
          INTO @DATA(ls_inventory).

          DATA: lv_zero      TYPE abap_bool,
                lv_count     TYPE string,
                ls_count_oum TYPE meins.

          IF ls_inventory-counted_qty_uom IS NOT INITIAL.
            IF ls_inventory-counted_qty_uom = 'ST'.
              ls_count_oum = 'PC'.
            ELSE.
              ls_count_oum = ls_inventory-counted_qty_uom.
            ENDIF.

          ELSE.
            SELECT SINGLE UnitOfMeasure_E FROM I_UnitOfMeasure
                WHERE UnitOfMeasureSAPCode = @ls_Data-EWMPhysInvtryBookQtyUnit
          INTO @DATA(ls_UOM).
            IF ls_uom = 'ST'.
              ls_count_oum = 'PC'.
            ELSE.
              ls_count_oum = ls_uom.
            ENDIF.
          ENDIF.

          IF ls_inventory-api_status = 'S' AND ls_inventory-edit <> 'X' AND ls_inventory-upload_status <> 'S'.
            lv_count = ls_inventory-pda_qty.
            IF ls_inventory-pda_qty = 0.
              lv_zero = abap_true.
            ELSE.
              lv_zero = abap_false.
            ENDIF.

          ELSEIF ls_inventory-edit = 'X' AND ls_inventory-api_status <> 'S'.
            lv_count = ls_inventory-counted_qty.
            IF ls_inventory-counted_qty = 0.
              lv_zero = abap_true.
            ELSE.
              lv_zero = abap_false.
            ENDIF.
          ELSEIF ls_inventory-edit = 'X' AND ls_inventory-api_status = 'S'.
            lv_count = ls_inventory-counted_qty.
            IF ls_inventory-counted_qty = 0.
              lv_zero = abap_true.
            ELSE.
              lv_zero = abap_false.
            ENDIF.

          ELSEIF ls_inventory-upload_status = 'S' .
            lv_count = ls_inventory-counted_qty.
            IF ls_inventory-counted_qty = 0.
              lv_zero = abap_true.
            ELSE.
              lv_zero = abap_false.
            ENDIF.
          ENDIF.

*          DATA: lv_zero TYPE abap_bool.
*          IF  ls_inventory = 0.
*            lv_zero = abap_true.
*          ELSE.
*            lv_zero = abap_false.
*          ENDIF.


          "json mã item
          ls_whse_item-odata_etag                    = lv_Match.
          ls_whse_item-EWMWarehouse                  = ls_data-EWMWarehouse.
          ls_whse_item-PhysicalInventoryDocNumber    = lv_doc_num.
          ls_whse_item-PhysicalInventoryDocYear      = ls_data-PhysicalInventoryDocYear.
          ls_whse_item-PhysicalInventoryItemNumber   = lv_doc_item.
          ls_whse_item-LineIndexOfPInvItem           = ls_data-LineIndexOfPInvItem.
          ls_whse_item-PInvQuantitySequence          = ls_data-PInvQuantitySequence.
          ls_whse_item-PhysicalInventoryItemLevel    = ls_data-PhysicalInventoryItemLevel.
          ls_whse_item-PInvItemParentType            = ls_data-PInvItemParentType.
          ls_whse_item-EWMStorageBin                 = ls_data-EWMStorageBin.
          ls_whse_item-EWMStorageType                = ls_data-EWMStorageType.
          ls_whse_item-ParentHandlingUnitNumber      = ls_data-ParentHandlingUnitNumber.
          ls_whse_item-PhysicalInventoryItemType     = ls_data-PhysicalInventoryItemType.
          ls_whse_item-HandlingUnitNumber            = ls_data-HandlingUnitNumber.
          ls_whse_item-Product                       = ls_data-Product.
          ls_whse_item-ProductUUID                   = lv_uuid_1.
          ls_whse_item-BatchUUID                     = lv_uuid_batch.
          ls_whse_item-Batch                         = ls_data-Batch.
          ls_whse_item-SerialNumberRequiredLevel     = ls_data-SerialNumberRequiredLevel.
          ls_whse_item-EWMStockType                  = ls_data-EWMStockType.
          ls_whse_item-EWMStockOwner                 = ls_data-EWMStockOwner.
          ls_whse_item-StockOwnerPartnerRole         = ls_data-StockOwnerPartnerRole.
          ls_whse_item-EWMStockUsage                 = ls_data-EWMStockUsage.
          ls_whse_item-EntitledToDisposeParty        = ls_data-EntitledToDisposeParty.
          ls_whse_item-EntitledToDisposePartnerRole  = ls_data-EntitledToDisposePartnerRole.
          ls_whse_item-StockDocumentCategory         = ls_data-StockDocumentCategory.
          ls_whse_item-StockDocumentNumber           = lv_stok_doc_num.   "'000000000000000000000000000' && ls_data-SpecialStockIdfgSalesOrder..
          ls_whse_item-StockItemNumber               = ls_data-SpecialStockIdfgSalesOrderItem.
          ls_whse_item-WBSElementExternalID          = ls_data-WBSElementExternalID.
          ls_whse_item-WBSElementInternalID          = ls_data-WBSElementInternalID.
          ls_whse_item-SpecialStockIdfgSalesOrder    = ls_data-SpecialStockIdfgSalesOrder.
          ls_whse_item-SpecialStockIdfgSalesOrderItem = ls_data-SpecialStockIdfgSalesOrderItem.
          ls_whse_item-DocumentReltdStockDocCat      = ''.
          ls_whse_item-WhseQualityInspectionType     = ls_data-WhseQualityInspectionType.
          ls_whse_item-QualityInspectionDocUUID      = '00000000-0000-0000-0000-000000000000'.
          ls_whse_item-StockIdentificationNumber     = ls_data-StockIdentificationNumber."''.
          ls_whse_item-DocumentReltdStockDocUUID     = '00000000-0000-0000-0000-000000000000'.
          ls_whse_item-DocumentReltdStockDocItemUUID = '00000000-0000-0000-0000-000000000000'.
          ls_whse_item-WhseTaskGoodsReceiptDateTime  = lv_time_iso."'2025-10-08T09:03:17Z'.
          ls_whse_item-ShelfLifeExpirationDate       = ''."ls_data-ShelfLifeExpirationDate. "''.
          ls_whse_item-CountryOfOrigin               = ls_data-CountryOfOrigin."''.
          ls_whse_item-matlbatchisinrstrcdusestock  = ls_data-MatlBatchIsInRstrcdUseStock. "abap_false.
          ls_whse_item-HndlgUnitItemCountedIsComplete  = ls_data-HndlgUnitItemCountedIsComplete. "abap_false.
          ls_whse_item-HndlgUnitItemCountedIsEmpty   = ls_data-HndlgUnitItemCountedIsEmpty. "abap_false.
          ls_whse_item-HndlgUnitItemCountedIsNotExist = ls_data-HndlgUnitItemCountedIsNotExist. " abap_false.
          ls_whse_item-PackagingMaterial             = ls_data-PackagingMaterial. "''.
          ls_whse_item-HandlingUnitType              = ls_data-HandlingUnitType. "''.
          ls_whse_item-EWMStorageBinIsEmpty          = ls_data-EWMStorageBinIsEmpty. "abap_false.
          ls_whse_item-PInvIsZeroCount               = lv_zero.
          ls_whse_item-RequestedQuantityUnit         = ls_count_oum.
          ls_whse_item-RequestedQuantity             = lv_count.
          ls_whse_item-PInvItemChgUTCDateTime        = zcl_utility=>tzntstmpl_to_iso8601( lv_now ).."'2025-10-09T09:11:19.050944Z'.
          ls_whse_item-SAP__Messages                 = VALUE #( ).
          " Convert item to JSON
          lv_json_item = /ui2/cl_json=>serialize(
              data        = ls_whse_item
              compress    = abap_true
              pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

          "----- Replace keys Item JSON -----
          REPLACE ALL OCCURRENCES OF 'odataEtag' IN lv_json_item WITH '@odata.etag'.
          REPLACE ALL OCCURRENCES OF 'ewmwarehouse' IN lv_json_item WITH 'EWMWarehouse'.
          REPLACE ALL OCCURRENCES OF 'physicalinventorydocnumber' IN lv_json_item WITH 'PhysicalInventoryDocNumber'.
          REPLACE ALL OCCURRENCES OF 'physicalinventorydocyear' IN lv_json_item WITH 'PhysicalInventoryDocYear'.
          REPLACE ALL OCCURRENCES OF 'physicalinventoryitemnumber' IN lv_json_item WITH 'PhysicalInventoryItemNumber'.
          REPLACE ALL OCCURRENCES OF 'lineindexofpinvitem' IN lv_json_item WITH 'LineIndexOfPInvItem'.
          REPLACE ALL OCCURRENCES OF 'pinvquantitysequence' IN lv_json_item WITH 'PInvQuantitySequence'.
          REPLACE ALL OCCURRENCES OF 'physicalinventoryitemlevel' IN lv_json_item WITH 'PhysicalInventoryItemLevel'.
          REPLACE ALL OCCURRENCES OF 'pinvitemparenttype' IN lv_json_item WITH 'PInvItemParentType'.
          REPLACE ALL OCCURRENCES OF 'ewmstoragebin' IN lv_json_item WITH 'EWMStorageBin'.
          REPLACE ALL OCCURRENCES OF 'ewmstoragetype' IN lv_json_item WITH 'EWMStorageType'.
          REPLACE ALL OCCURRENCES OF 'parenthandlingunitnumber' IN lv_json_item WITH 'ParentHandlingUnitNumber'.
          REPLACE ALL OCCURRENCES OF 'physicalinventoryitemtype' IN lv_json_item WITH 'PhysicalInventoryItemType'.
          REPLACE ALL OCCURRENCES OF 'handlingunitnumber' IN lv_json_item WITH 'HandlingUnitNumber'.
          REPLACE ALL OCCURRENCES OF 'product' IN lv_json_item WITH 'Product'.
          REPLACE ALL OCCURRENCES OF 'Productuuid' IN lv_json_item WITH 'ProductUUID'.
          REPLACE ALL OCCURRENCES OF 'batchuuid' IN lv_json_item WITH 'BatchUUID'.
          REPLACE ALL OCCURRENCES OF 'batch' IN lv_json_item WITH 'Batch'.
          REPLACE ALL OCCURRENCES OF 'serialnumberrequiredlevel' IN lv_json_item WITH 'SerialNumberRequiredLevel'.
          REPLACE ALL OCCURRENCES OF 'ewmstocktype' IN lv_json_item WITH 'EWMStockType'.
          REPLACE ALL OCCURRENCES OF 'ewmstockowner' IN lv_json_item WITH 'EWMStockOwner'.
          REPLACE ALL OCCURRENCES OF 'stockownerpartnerrole' IN lv_json_item WITH 'StockOwnerPartnerRole'.
          REPLACE ALL OCCURRENCES OF 'ewmstockusage' IN lv_json_item WITH 'EWMStockUsage'.
          REPLACE ALL OCCURRENCES OF 'entitledtodisposeparty' IN lv_json_item WITH 'EntitledToDisposeParty'.
          REPLACE ALL OCCURRENCES OF 'entitledtodisposepartnerrole' IN lv_json_item WITH 'EntitledToDisposePartnerRole'.
          REPLACE ALL OCCURRENCES OF 'stockdocumentcategory' IN lv_json_item WITH 'StockDocumentCategory'.
          REPLACE ALL OCCURRENCES OF 'stockdocumentnumber' IN lv_json_item WITH 'StockDocumentNumber'.
          REPLACE ALL OCCURRENCES OF 'stockitemnumber' IN lv_json_item WITH 'StockItemNumber'.
          REPLACE ALL OCCURRENCES OF 'wbselementexternalid' IN lv_json_item WITH 'WBSElementExternalID'.
          REPLACE ALL OCCURRENCES OF 'wbselementinternalid' IN lv_json_item WITH 'WBSElementInternalID'.
          REPLACE ALL OCCURRENCES OF 'specialstockidfgsalesorder' IN lv_json_item WITH 'SpecialStockIdfgSalesOrder'.
          REPLACE ALL OCCURRENCES OF 'SpecialStockIdfgSalesOrderitem' IN lv_json_item WITH 'SpecialStockIdfgSalesOrderItem'.
          REPLACE ALL OCCURRENCES OF 'documentreltdstockdoccat' IN lv_json_item WITH 'DocumentReltdStockDocCat'.
          REPLACE ALL OCCURRENCES OF 'whsequalityinspectiontype' IN lv_json_item WITH 'WhseQualityInspectionType'.
          REPLACE ALL OCCURRENCES OF 'qualityinspectiondocuuid' IN lv_json_item WITH 'QualityInspectionDocUUID'.
          REPLACE ALL OCCURRENCES OF 'stockidentificationnumber' IN lv_json_item WITH 'StockIdentificationNumber'.
          REPLACE ALL OCCURRENCES OF 'documentreltdstockdocuuid' IN lv_json_item WITH 'DocumentReltdStockDocUUID'.
          REPLACE ALL OCCURRENCES OF 'documentreltdstockdocitemuuid' IN lv_json_item WITH 'DocumentReltdStockDocItemUUID'.
          REPLACE ALL OCCURRENCES OF 'whsetaskgoodsreceiptdatetime' IN lv_json_item WITH 'WhseTaskGoodsReceiptDateTime'.
          REPLACE ALL OCCURRENCES OF 'shelflifeexpirationdate' IN lv_json_item WITH 'ShelfLifeExpirationDate'.
          REPLACE ALL OCCURRENCES OF 'countryoforigin' IN lv_json_item WITH 'CountryOfOrigin'.
          REPLACE ALL OCCURRENCES OF 'matlbatchisinrstrcdusestock' IN lv_json_item WITH 'MatlBatchIsInRstrcdUseStock'.
          REPLACE ALL OCCURRENCES OF 'hndlgunititemcountediscomplete' IN lv_json_item WITH 'HndlgUnitItemCountedIsComplete'.
          REPLACE ALL OCCURRENCES OF 'hndlgunititemcountedisempty' IN lv_json_item WITH 'HndlgUnitItemCountedIsEmpty'.
          REPLACE ALL OCCURRENCES OF 'hndlgunititemcountedisnotexist' IN lv_json_item WITH 'HndlgUnitItemCountedIsNotExist'.
          REPLACE ALL OCCURRENCES OF 'packagingmaterial' IN lv_json_item WITH 'PackagingMaterial'.
          REPLACE ALL OCCURRENCES OF 'handlingunittype' IN lv_json_item WITH 'HandlingUnitType'.
          REPLACE ALL OCCURRENCES OF 'ewmstoragebinisempty' IN lv_json_item WITH 'EWMStorageBinIsEmpty'.
          REPLACE ALL OCCURRENCES OF 'pinviszerocount' IN lv_json_item WITH 'PInvIsZeroCount'.
          REPLACE ALL OCCURRENCES OF 'requestedquantityunit' IN lv_json_item WITH 'RequestedQuantityUnit'.
          REPLACE ALL OCCURRENCES OF 'requestedquantity' IN lv_json_item WITH 'RequestedQuantity'.
          REPLACE ALL OCCURRENCES OF 'pinvitemchgutcdatetime' IN lv_json_item WITH 'PInvItemChgUTCDateTime'.
          REPLACE ALL OCCURRENCES OF 'sap__messages' IN lv_json_item WITH 'SAP__Messages'.

          "ghép 2 mã json cùng body
          lw_json_body =
        |--batch_123\r\n|
        && |Content-Type: multipart/mixed; boundary=changeset\r\n|
        && |Odata-Version: 4.0\r\n|
        && |Odata-MaxVersion: 4.0\r\n\r\n|
        && |--changeset\r\n|
        && |Content-Type: application/http\r\n|
        && |Content-Transfer-Encoding: binary\r\n|
        && |Content-ID: 1\r\n\r\n|
        && |PUT WhsePhysicalInventoryItem(|
        && |EWMWarehouse='{ ls_data-EWMWarehouse }',|
        && |PhysicalInventoryDocNumber='{ lv_doc_num }',|
        && |PhysicalInventoryDocYear='{ ls_data-PhysicalInventoryDocYear }',|
        && |PhysicalInventoryItemNumber='{ lv_doc_item }'|
        && |) HTTP/1.1\r\n|
        && |Content-Type: application/json\r\n|
        && |If-match: { lv_Match } \r\n\r\n|
        && lv_json_header
        && |\r\n\r\n|
        && |--changeset\r\n|
        && |Content-Type: application/http\r\n|
        && |Content-Transfer-Encoding: binary\r\n|
        && |Content-ID: 2\r\n\r\n|
        && |PUT WhsePhysicalInventoryCountItem(|
        && |EWMWarehouse='{ ls_data-EWMWarehouse }',|
        && |PhysicalInventoryDocNumber='{ lv_doc_num }',|
        && |PhysicalInventoryDocYear='{ ls_data-PhysicalInventoryDocYear }',|
        && |PhysicalInventoryItemNumber='{ lv_doc_item }',|
        && |LineIndexOfPInvItem={ ls_data-LineIndexOfPInvItem },|
        && |PInvQuantitySequence={ ls_data-PInvQuantitySequence }|
        && |) HTTP/1.1\r\n|
        && |Content-Type: application/json\r\n|
        && |If-match: { lv_Match } \r\n\r\n|
        && lv_json_item
        && |\r\n\r\n|
        && |--changeset--\r\n|
        && |--batch_123--|.


*          lo_web_http_request->set_header_field( i_name = 'If-Match' i_value = lv_Match ).

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

      IF ls_INVENTORYITEM-EWMPhysicalInventoryStatus = 'POST' OR ls_INVENTORYITEM-EWMPhysicalInventoryStatus = 'RECO'.
        APPEND VALUE #(
          %tky = key-%tky
          %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-success
                    text     = |Record này đã được Post, không thể chỉnh sửa.|
                  )
        ) TO reported-zi_inventory_data_root.
      ELSE.

        IF lv_success = abap_true.
          APPEND VALUE #(
           %tky = key-%tky
           %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-success
                     text     = |Đã Count thành công.|
                   )
         ) TO reported-zi_inventory_data_root.
        ELSE.
          APPEND VALUE #(
             %tky = key-%tky
             %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text     = |Count thất bại: { lv_error_msg }|
                     )
           ) TO reported-zi_inventory_data_root.
        ENDIF.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD PostAPI.
  ENDMETHOD.

  METHOD Creatpi.
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
                               )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'AI' )
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
                         procedure            = 'Procedure'
                         count_date           = 'Count date'
                         warehouse_number     = 'Warehouse Number'
                         storage_type         = 'Storage Type'
                         storage_bin          = 'Storage Bin'
                         material             = 'Material'
                         material_description = 'Material Description'
                         batch                = 'Batch'
                         spe_stok             = 'Special Stock'
                         spe_stok_num         = 'Supplier’s Account Number'
                         sales_order          = 'Sales Order'
                         sales_order_item     = 'Item no. of Sales Order'
                         stock_type           = 'Stock Type'
                         book_quantity        = 'Book Quantity'
                         book_qty_uom         = 'Book Qty UoM'
                         pda_quantity         = 'PDA Quantity'
                         counted_quantity     = 'Counted Quantity'
                         counted_qty_uom      = 'Counted Qty UoM'
                         entered_qty_in_pi    = 'Entered Qty in PI'
                         entered_qty_uom      = 'Entered Qty UoM'
                         zero_count           = 'Zero Count'
                         difference_quantity  = 'Difference Quantity'
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
      lr_convert_sap_no    TYPE tt_ranges,
      lr_warehouse_number  TYPE tt_ranges,
      lr_material          TYPE tt_ranges,
      lr_api_status        TYPE tt_ranges
      .

    " Get keys from FE
    IF k-%param IS NOT INITIAL.
      SPLIT k-%param-pid AT ',' INTO TABLE DATA(lt_pid_split).
      SPLIT k-%param-pid_item AT ',' INTO TABLE DATA(lt_pid_item_split).
      SPLIT k-%param-DocumentYear AT ',' INTO TABLE DATA(lt_documentyear_split).
      SPLIT k-%param-Convert_Sap_No AT ',' INTO TABLE DATA(lt_convert_sap_no_split).
      SPLIT k-%param-Warehouse_number AT ',' INTO TABLE DATA(lt_warehouse_number_split).
      SPLIT k-%param-Material AT ',' INTO TABLE DATA(lt_material_split).
      SPLIT k-%param-API_Status AT ',' INTO TABLE DATA(lt_api_status).

      " Field keys in to range for select
      LOOP AT lt_pid_split INTO DATA(ls_pid_split).
        IF ls_pid_split IS NOT INITIAL.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_pid_split ) TO lr_pid.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_pid_item_split INTO DATA(ls_pid_item_split).
        IF ls_pid_item_split IS NOT INITIAL.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_pid_item_split ) TO lr_pid_item.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_documentyear_split INTO DATA(ls_documentyear_split).
        IF ls_documentyear_split IS NOT INITIAL.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_documentyear_split ) TO lr_documentyear.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_convert_sap_no_split INTO DATA(ls_convert_sap_no_split).
        IF ls_convert_sap_no_split IS NOT INITIAL.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_convert_sap_no_split ) TO lr_convert_sap_no.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_Warehouse_number_split INTO DATA(ls_Warehouse_number_split).
        IF ls_Warehouse_number_split IS NOT INITIAL.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_Warehouse_number_split ) TO lr_warehouse_number.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_material_split INTO DATA(ls_material_split).
        IF ls_material_split IS NOT INITIAL.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_material_split ) TO lr_material.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_api_status INTO DATA(ls_api_status).
        IF ls_api_status IS NOT INITIAL.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_api_status ) TO lr_api_status.
        ENDIF.
      ENDLOOP.
    ENDIF.

    " Call method get for WM data
    CALL METHOD zcl_get_inventory_data_wm=>get_wm_data
      EXPORTING
        iv_pid              = lr_pid
        iv_pid_item         = lr_pid_item
        iv_document_year    = lr_documentyear
        iv_warehouse_number = lr_warehouse_number
        iv_matnr            = lr_material
      IMPORTING
        ev_result           = DATA(lt_data_get).

    DATA: lv_index TYPE sy-tabix.

    DELETE lt_data_get WHERE pid IS INITIAL AND pid_item IS INITIAL OR PiStatus NE 'ACTI'.

    " Fill data for exporting
    LOOP AT lt_data_get INTO DATA(ls_data_get).
      ls_file-convert_sap_no       = ls_data_get-ConvertSapNo.
      ls_file-pid                  = ls_data_get-Pid.
      ls_file-pid_item             = ls_data_get-Pid_item.
      ls_file-fiscal_year          = ls_data_get-DocumentYear.
      ls_file-procedure            = ls_data_get-Proce.
      ls_file-count_date           = ls_data_get-CountDate.
      ls_file-warehouse_number     = ls_data_get-Warehouse_number.
      ls_file-storage_type         = ls_data_get-StoreType.
      ls_file-storage_bin          = ls_data_get-StorageBin.
      ls_file-material             = ls_data_get-Material.
      ls_file-material_description = ls_data_get-MaterialDescription.
      ls_file-batch                = ls_data_get-Batch.
      ls_file-spe_stok             = ls_data_get-SpecialStock.
      ls_file-spe_stok_num         = ls_data_get-SpecialStockNumber.
      ls_file-sales_order          = ls_data_get-Salesorder.
      ls_file-sales_order_item     = ls_data_get-SalesOrderItem.
      ls_file-stock_type           = ls_data_get-StockType.
      ls_file-book_quantity        = ls_data_get-BookQty.
      ls_file-book_qty_uom         = ls_data_get-BookQtyUom.
      ls_file-pda_quantity         = ls_data_get-PdaQty.
      ls_file-counted_quantity     = ls_data_get-CountedQty.
      ls_file-counted_qty_uom      = ls_data_get-CountedQtyUom.
      ls_file-entered_qty_in_pi    = ls_data_get-EnteredQtyPi.
      ls_file-entered_qty_uom      = ls_data_get-EnteredQtyUom.
      ls_file-zero_count           = ls_data_get-ZeroCount.
      ls_file-difference_quantity  = ls_data_get-DiffQty.
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
    ENDLOOP.

    lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_from( REF #( lt_file )
        )->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    " Return file content for download
    result = VALUE #( FOR key IN keys (
                      %cid   = key-%cid
                      %param = VALUE #( filecontent   = lv_file_content
                                        filename      = 'xldl_kiem_ke_template'
                                        fileextension = 'xlsx'
                                        mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                      ) ).
  ENDMETHOD.

  METHOD UploadFile.
    DATA: lv_fail TYPE abap_boolean VALUE abap_false.

    DATA: lt_file   TYPE STANDARD TABLE OF ty_file_upload,

          lt_file_u TYPE TABLE OF ztb_inventory1,
          ls_file_u LIKE LINE OF lt_file_u,

          lt_file_c TYPE TABLE FOR CREATE zi_inventory_data_root,
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
      lv_text             TYPE string VALUE '',

      lr_pid              TYPE tt_ranges,
      lr_pid_item         TYPE tt_ranges,
      lr_documentyear     TYPE tt_ranges,
      lr_convert_sap_no   TYPE tt_ranges,
      lr_warehouse_number TYPE tt_ranges,
      lr_material         TYPE tt_ranges,
      lr_api_status       TYPE tt_ranges.

    "Process data Raw
    LOOP AT lt_file INTO DATA(ls_file).
      IF ls_file-pid IS INITIAL AND ls_file-pid_item IS INITIAL OR ls_file-pi_status NE 'ACTI'.
        " Trường hợp chúng từ ko có PID và PID Item hoặc không thuộc PI status có quyền chỉnh sửa.
      ELSE.
        IF ls_file-pid IS NOT INITIAL.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-pid ) TO lr_pid.
        ENDIF.

        IF ls_file-pid_item IS NOT INITIAL.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-pid_item ) TO lr_pid_item.
        ENDIF.

        IF ls_file-fiscal_year IS NOT INITIAL.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-fiscal_year ) TO lr_documentyear.
        ENDIF.

        IF ls_file-convert_sap_no IS NOT INITIAL.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-convert_sap_no ) TO lr_convert_sap_no.
        ENDIF.

        IF ls_file-warehouse_number IS NOT INITIAL.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-warehouse_number ) TO lr_warehouse_number.
        ENDIF.

        IF ls_file-material IS NOT INITIAL.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-material ) TO lr_material.
        ENDIF.

        IF ls_file-api_status IS NOT INITIAL.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-api_status ) TO lr_api_status.
        ENDIF.

        ls_file_u-convert_sap_no       = ls_file-convert_sap_no.
        ls_file_u-pid                  = ls_file-pid.
        ls_file_u-pid_item             = ls_file-pid_item.
        ls_file_u-document_year        = ls_file-fiscal_year.
*      ls_file_u-proce                = ls_file-procedure.
*      ls_file_u-count_date           = ls_file-count_date.
        ls_file_u-warehouse_number     = ls_file-warehouse_number.
        ls_file_u-store_type           = ls_file-storage_type.
        ls_file_u-storage_bin          = ls_file-storage_bin.
        ls_file_u-material             = ls_file-material.
*      ls_file_u-material_description = ls_file-material_description.
        ls_file_u-batch                = ls_file-batch.
*      ls_file_u-spe_stok             = ls_file-spe_stok.
        ls_file_u-spe_stok_num         = ls_file-spe_stok_num.
        ls_file_u-sales_order          = ls_file-sales_order.
        ls_file_u-sales_order_item     = ls_file-sales_order_item.
*      ls_file_u-stock_type           = ls_file-stock_type.
*      ls_file_u-book_qty             = ls_file-book_quantity.
*      ls_file_u-book_qty_uom         = ls_file-book_qty_uom.
*      ls_file_u-pda_qty              = ls_file-pda_quantity.
        ls_file_u-counted_qty          = ls_file-counted_quantity.                         " UPDATE
        ls_file_u-counted_qty_uom      = ls_file-counted_qty_uom .                         " UPDATE
*      ls_file_u-entered_qty_pi       = ls_file-entered_qty_in_pi.
*      ls_file_u-entered_qty_uom      = ls_file-entered_qty_uom.
        ls_file_u-zero_count           = ls_file-zero_count .                              " UPDATE
*      ls_file_u-diff_qty             = ls_file-difference_quantity.
*      ls_file_u-api_status           = ls_file-api_status.
*      ls_file_u-api_message          = ls_file-api_message.
*      ls_file_u-pda_date             = ls_file-pda_date.
*      ls_file_u-pda_time             = ls_file-pda_time.
*      ls_file_u-counter              = ls_file-counter.
*      ls_file_u-api_date             = ls_file-api_date.
*      ls_file_u-api_time             = ls_file-api_time.
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

    " Call method get for WM data
    CALL METHOD zcl_get_inventory_data_wm=>get_wm_data
      EXPORTING
        iv_pid              = lr_pid
        iv_pid_item         = lr_pid_item
        iv_document_year    = lr_documentyear
        iv_warehouse_number = lr_warehouse_number
        iv_matnr            = lr_material
*       iv_api_status       = lr_api_status
      IMPORTING
        ev_result           = DATA(lt_data_get).

    SORT lt_data_get BY Pid Pid_item DocumentYear Warehouse_number Material.

    DELETE lt_data_get WHERE pid IS INITIAL AND pid_item IS INITIAL.

    LOOP AT lt_file_u ASSIGNING FIELD-SYMBOL(<lfs_file_u>).
      lv_index = sy-tabix.

      READ TABLE lt_data_get INTO DATA(ls_data_get) WITH KEY pid = <lfs_file_u>-pid
                                                             Pid_item = <lfs_file_u>-pid_item
                                                             DocumentYear = <lfs_file_u>-document_year
                                                             Warehouse_number = <lfs_file_u>-warehouse_number
                                                             Material = <lfs_file_u>-material.
      IF sy-subrc = 0 AND ls_data_get-PiStatus = 'ACTI'.
*        ls_export_data = CORRESPONDING #( ls_data_get ).

        ls_export_data-convert_sap_no = <lfs_file_u>-convert_sap_no.
        ls_export_data-pid = <lfs_file_u>-pid.
        ls_export_data-pid_item = <lfs_file_u>-pid_item.
        ls_export_data-fiscal_year = <lfs_file_u>-document_year.
        ls_export_data-warehouse_number = <lfs_file_u>-warehouse_number.
        ls_export_data-storage_type = <lfs_file_u>-store_type.
        ls_export_data-storage_bin = <lfs_file_u>-storage_bin.
        ls_export_data-material = <lfs_file_u>-material.
        ls_export_data-batch = <lfs_file_u>-batch.
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
          IF <lfs_file_u>-Counted_Qty IS INITIAL.
            <lfs_file_u>-Zero_Count = 'X'.
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

    DATA: lt_inventory_upload TYPE TABLE OF ztb_inventory1,
          ls_inventory_upload TYPE ztb_inventory1.

    CLEAR ls_file_u.

    LOOP AT lt_file_u INTO ls_file_u.
      CLEAR ls_data_get.
      IF ls_file_u-pid IS NOT INITIAL AND ls_file_u-pid_item IS NOT INITIAL.
        READ TABLE lt_data_get INTO ls_data_get WITH KEY  pid = ls_file_u-pid
                                                          Pid_item = ls_file_u-pid_item
                                                          DocumentYear = ls_file_u-document_year
                                                          Warehouse_number = ls_file_u-warehouse_number
                                                          Material = ls_file_u-material.
      ELSE.
        SORT lt_data_get BY ConvertSapNo.
        READ TABLE lt_data_get INTO ls_data_get WITH KEY  ConvertSapNo = ls_file_u-convert_sap_no.
      ENDIF.


*  uuid
      IF ls_file_u-pid IS NOT INITIAL AND ls_file_u-pid_item IS NOT INITIAL.
        SELECT SINGLE *
            FROM ztb_inventory1
            WHERE pid = @ls_data_get-pid
            AND pid_item = @ls_data_get-pid_item
            AND document_year = @ls_data_get-DocumentYear
            INTO @DATA(ls_inventory_db).

      ELSE.

        SELECT SINGLE *
            FROM ztb_inventory1
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

*  pid
      ls_inventory_upload-pid = ls_data_get-pid.
*  pid_item
      ls_inventory_upload-pid_item = ls_data_get-pid_item.
*  warehouse_number
      ls_inventory_upload-warehouse_number = ls_data_get-warehouse_number.
*  lineindexofpinvitem
      ls_inventory_upload-lineindexofpinvitem = ls_data_get-LineIndexOfPInvItem.
*  document_year
      ls_inventory_upload-document_year = ls_data_get-documentyear.
*  plant
      ls_inventory_upload-plant = ls_data_get-plant.
*  storage_location
      ls_inventory_upload-storage_location = ls_data_get-storage_location.
*  storage_bin
      ls_inventory_upload-storage_bin = ls_data_get-storagebin.
*  store_type
      ls_inventory_upload-store_type = ls_data_get-storetype.
*  phys_inv_doc
      ls_inventory_upload-phys_inv_doc = ls_data_get-physinvdoc.
*  material
      ls_inventory_upload-material = ls_data_get-material.
*  doc_date
      ls_inventory_upload-doc_date = ls_data_get-docdate.
*  pda_date
      ls_inventory_upload-pda_date = ls_data_get-pdadate.
*  pi_status
      ls_inventory_upload-pi_status = ls_data_get-pistatus.
*  convert_sap_no
      ls_inventory_upload-convert_sap_no = ls_data_get-convertsapno.
*  proce
      ls_inventory_upload-proce = ls_data_get-proce.
*  count_date
      ls_inventory_upload-count_date = ls_data_get-countdate.
*  count_time
      ls_inventory_upload-count_time = ls_data_get-counttime.
*  material_description
      ls_inventory_upload-material_description = ls_data_get-materialdescription.
*  batch
      ls_inventory_upload-batch = ls_data_get-batch.
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



      IF ls_file_u-upload_status EQ 'S' AND ls_data_get-PiStatus = 'ACTI'.
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
**  physical_item_number
*          ls_inventory_upload-physical_item_number = ls_inventory_fe-physical_item_number.
*  user_upload
      ls_inventory_upload-user_upload = ls_file_u-user_upload.
*  upload_time
      ls_inventory_upload-upload_time = lv_date.
*  upload_date
      ls_inventory_upload-upload_date = lv_time.



      IF ls_data_get-PiStatus = 'ACTI'.
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



*  spe_stok
      ls_inventory_upload-spe_stok = ls_data_get-SpecialStock.
*  spe_stok_num
      ls_inventory_upload-spe_stok_num = ls_data_get-SpecialStockNumber.
*  sales_order
      ls_inventory_upload-sales_order = ls_data_get-salesorder.
*  sales_order_item
      ls_inventory_upload-sales_order_item = ls_data_get-salesorderitem.
**  created_by
*        ls_inventory_upload-created_by = ls_inventory_db-created_by.
**  created_at
*        ls_inventory_upload-created_at = ls_inventory_db-created_at.
**  last_changed_by
*        ls_inventory_upload-last_changed_by = ls_inventory_db-last_changed_by.
**  last_changed_at
*        ls_inventory_upload-last_changed_at = ls_inventory_db-last_changed_at.
*  edit
      ls_inventory_upload-edit = ls_data_get-edit.
*  action_type
      ls_inventory_upload-action_type = |U|.

      APPEND ls_inventory_upload TO lt_inventory_upload.
      CLEAR: ls_inventory_upload, ls_data_get, ls_file_u.
    ENDLOOP.

    MODIFY ztb_inventory1 FROM TABLE @lt_inventory_upload.
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

      SORT lt_data_get BY pid pid_item documentyear ASCENDING.
      READ TABLE lt_data_get INTO DATA(ls_inventory) WITH KEY pid = e_respond-pid pid_item = e_respond-pid_item documentyear = e_respond-fiscal_year.
      IF sy-subrc = 0.
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

        IF ls_inventory-DocumentYear <> e_respond-fiscal_year.
          lv_boolean = abap_true.

          IF e_respond-upload_message IS NOT INITIAL.
            e_respond-upload_message =  e_respond-upload_message && ', Document Year ' && e_respond-fiscal_year && ' không đồng nhất'.
          ELSE.
            e_respond-upload_message =  e_respond-upload_message && ' Document Year ' && e_respond-fiscal_year && ' không đồng nhất'.
          ENDIF.
        ENDIF.

        IF ls_inventory-warehouse_number <> e_respond-warehouse_number.
          lv_boolean = abap_true.

          IF e_respond-upload_message IS NOT INITIAL.
            e_respond-upload_message =  e_respond-upload_message && ', Warehouse Number ' && e_respond-warehouse_number && ' không đồng nhất'.
          ELSE.
            e_respond-upload_message =  e_respond-upload_message && ' Warehouse Number ' && e_respond-warehouse_number && ' không đồng nhất'.
          ENDIF.
        ENDIF.

        IF ls_inventory-StoreType <> e_respond-storage_type.
          lv_boolean = abap_true.

          IF e_respond-upload_message IS NOT INITIAL.
            e_respond-upload_message =  e_respond-upload_message && ', Storage Type ' && e_respond-storage_type && ' không đồng nhất'.
          ELSE.
            e_respond-upload_message =  e_respond-upload_message && ' Storage Type ' && e_respond-storage_type && ' không đồng nhất'.
          ENDIF.
        ENDIF.

        IF ls_inventory-StorageBin <> e_respond-storage_bin.
          lv_boolean = abap_true.

          IF e_respond-upload_message IS NOT INITIAL.
            e_respond-upload_message =  e_respond-upload_message && ', Storage Bin ' && e_respond-storage_bin && ' không đồng nhất'.
          ELSE.
            e_respond-upload_message =  e_respond-upload_message && ' Storage Bin ' && e_respond-storage_bin && ' không đồng nhất'.
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

        IF ls_inventory-batch <> e_respond-batch.
          lv_boolean = abap_true.

          IF e_respond-upload_message IS NOT INITIAL.
            e_respond-upload_message =  e_respond-upload_message && ', Batch ' && e_respond-batch && ' không đồng nhất'.
          ELSE.
            e_respond-upload_message =  e_respond-upload_message && ' Batch ' && e_respond-batch && ' không đồng nhất'.
          ENDIF.
        ENDIF.

        IF ls_inventory-SpecialStockNumber <> e_respond-spe_stok_num.
          lv_boolean = abap_true.

          IF e_respond-upload_message IS NOT INITIAL.
            e_respond-upload_message =  e_respond-upload_message && ', Supplier’s Account Number ' && e_respond-spe_stok_num && ' không đồng nhất'.
          ELSE.
            e_respond-upload_message =  e_respond-upload_message && ' Supplier’s Account Number ' && e_respond-spe_stok_num && ' không đồng nhất'.
          ENDIF.
        ENDIF.

        IF ls_inventory-Salesorder <> e_respond-sales_order.
          lv_boolean = abap_true.

          IF e_respond-upload_message IS NOT INITIAL.
            e_respond-upload_message =  e_respond-upload_message && ', Sales Order ' && e_respond-sales_order && ' không đồng nhất'.
          ELSE.
            e_respond-upload_message =  e_respond-upload_message && ' Sales Order ' && e_respond-sales_order && ' không đồng nhất'.
          ENDIF.
        ENDIF.

        IF ls_inventory-SalesOrderItem <> e_respond-sales_order_item.
          lv_boolean = abap_true.

          IF e_respond-upload_message IS NOT INITIAL.
            e_respond-upload_message =  e_respond-upload_message && ', Item no. of Sales Order ' && e_respond-sales_order_item && ' không đồng nhất'.
          ELSE.
            e_respond-upload_message =  e_respond-upload_message && ' Item no. of Sales Order ' && e_respond-sales_order_item && ' không đồng nhất'.
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
        e_respond-upload_message = 'Upload fail, data not exist'.
        " return message not found.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD UpdateCount.
    READ TABLE keys INDEX 1 INTO DATA(k).

    DATA: lt_inventory_update TYPE TABLE OF ztb_inventory1,
          ls_inventory_update TYPE ztb_inventory1.

    DATA:
      lr_pid                 TYPE tt_ranges,
      lr_pid_item            TYPE tt_ranges,
      lr_documentyear        TYPE tt_ranges,
      lr_convert_sap_no      TYPE tt_ranges,
      lr_warehouse_number    TYPE tt_ranges,
      lr_material            TYPE tt_ranges,
      lr_lineindexofpinvitem TYPE tt_ranges,
      lr_uuid                TYPE tt_ranges
      .

    IF k-Pid IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-Pid ) TO lr_pid.
    ENDIF.
    IF k-Pid_item IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-Pid_item ) TO lr_pid_item.
    ENDIF.
    IF k-DocumentYear IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-DocumentYear ) TO lr_documentyear.
    ENDIF.
    IF k-ConvertSapNo IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-ConvertSapNo ) TO lr_convert_sap_no.
    ENDIF.
    IF k-Warehouse_number IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-Warehouse_number ) TO lr_warehouse_number.
    ENDIF.
*    IF k-Material IS NOT INITIAL.
*      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-Material ) TO lr_material.
*    ENDIF.
    IF k-LineIndexOfPInvItem IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-LineIndexOfPInvItem ) TO lr_lineindexofpinvitem.
    ENDIF.
    IF k-Uuid IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = k-Uuid ) TO lr_uuid.
    ENDIF.

    " Call method get for WM data
    CALL METHOD zcl_get_inventory_data_wm=>get_wm_data
      EXPORTING
        iv_pid              = lr_pid
        iv_pid_item         = lr_pid_item
        iv_document_year    = lr_documentyear
        iv_warehouse_number = lr_warehouse_number
        iv_matnr            = lr_material
*       iv_api_status       = lr_api_status
      IMPORTING
        ev_result           = DATA(lt_data_get).

    SORT lt_data_get BY Pid Pid_item DocumentYear Warehouse_number Material.
    READ TABLE lt_data_get INTO DATA(ls_data_get) WITH KEY  pid = k-Pid
                                                      Pid_item = k-Pid_item
                                                      DocumentYear = k-DocumentYear
                                                      Warehouse_number = k-Warehouse_number.
*                                                      Material = k-Material.

    IF ls_data_get-PiStatus = 'POST' OR ls_data_get-PiStatus = 'RECO'.
      " Throw message PI status không hợp lệ
      APPEND VALUE #(
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |PI Status không hợp lệ để thực hiện Change Count!|
        )
      ) TO reported-zi_inventory_data_root.

      APPEND VALUE #(
        %tky = k-%tky
      ) TO failed-zi_inventory_data_root.
      RETURN.

    ELSE.

*  uuid
      IF ls_data_get-pid IS NOT INITIAL AND ls_data_get-pid IS NOT INITIAL.
        SELECT SINGLE *
            FROM ztb_inventory1
            WHERE pid = @ls_data_get-pid
            AND pid_item = @ls_data_get-pid_item
            AND document_year = @ls_data_get-DocumentYear
            INTO @DATA(ls_inventory_db).

      ELSE.

        SELECT SINGLE *
            FROM ztb_inventory1
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

*  pid
      ls_inventory_update-pid = ls_data_get-pid.
*  pid_item
      ls_inventory_update-pid_item = ls_data_get-pid_item.
*  warehouse_number
      ls_inventory_update-warehouse_number = ls_data_get-warehouse_number.
*  document_year
      ls_inventory_update-document_year = ls_data_get-DocumentYear.
*  plant
      ls_inventory_update-plant = ls_data_get-plant.
*  storage_location
      ls_inventory_update-storage_location = ls_data_get-storage_location.
*  storage_bin
      ls_inventory_update-storage_bin = ls_data_get-StorageBin.
*  store_type
      ls_inventory_update-store_type = ls_data_get-StoreType.
*  phys_inv_doc
      ls_inventory_update-phys_inv_doc = ls_data_get-PhysInvDoc.
*  material
      ls_inventory_update-material = ls_data_get-material.
*  doc_date
      ls_inventory_update-doc_date = ls_data_get-DocDate.
*  pda_date
      ls_inventory_update-pda_date = ls_data_get-PdaDate.
*  pi_status
      ls_inventory_update-pi_status = ls_data_get-PiStatus.
*  convert_sap_no
      ls_inventory_update-convert_sap_no = ls_data_get-ConvertSapNo.
*  proce
      ls_inventory_update-proce = ls_data_get-proce.



      IF k-%param-counted_date IS NOT INITIAL.
*  count_date
        ls_inventory_update-count_date = k-%param-counted_date.
      ELSE.
*  count_date
        ls_inventory_update-count_date = ls_data_get-CountDate.
      ENDIF.



*  count_time
      ls_inventory_update-count_time = ls_data_get-CountTime.
*  material_description
      ls_inventory_update-material_description = ls_data_get-MaterialDescription.
*  batch
      ls_inventory_update-batch = ls_data_get-batch.
*  stock_type
      ls_inventory_update-stock_type = ls_data_get-StockType.
*  book_qty
      ls_inventory_update-book_qty = ls_data_get-BookQty.
*  book_qty_uom
      ls_inventory_update-book_qty_uom = ls_data_get-BookQtyUom.
*  pda_qty
      ls_inventory_update-pda_qty = ls_data_get-PdaQty.



      IF k-%param-counted_qty IS NOT INITIAL.
*  counted_qty
        ls_inventory_update-counted_qty = k-%param-counted_qty.                 " Update
      ELSE.
*  counted_qty
        ls_inventory_update-counted_qty = ls_data_get-CountedQty.
      ENDIF.



*  counted_qty_uom
      ls_inventory_update-counted_qty_uom = ls_data_get-CountedQtyUom.
*  entered_qty_pi
      ls_inventory_update-entered_qty_pi = ls_data_get-EnteredQtyPi.
*  entered_qty_uom
      ls_inventory_update-entered_qty_uom = ls_data_get-EnteredQtyUom.



      IF ls_inventory_update-counted_qty > 0.
*  zero_count
        ls_inventory_update-zero_count = ||.
      ELSEIF ls_inventory_update-counted_qty = 0.
*  zero_count
        ls_inventory_update-zero_count = |X|.
      ENDIF.



*  diff_qty
      ls_inventory_update-diff_qty = ls_data_get-DiffQty.
*  api_status
      ls_inventory_update-api_status = ls_data_get-ApiStatus.
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
*  physical_item_number
      ls_inventory_update-physical_item_number = ls_data_get-PhysInvDoc.
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
*  spe_stok
      ls_inventory_update-spe_stok = ls_data_get-SpecialStock.
*  spe_stok_num
      ls_inventory_update-spe_stok_num = ls_data_get-SpecialStockNumber.
*  sales_order
      ls_inventory_update-sales_order = ls_data_get-salesorder.
*  sales_order_item
      ls_inventory_update-sales_order_item = ls_data_get-SalesOrderItem.
*  created_by
*  created_at
*  last_changed_by
*  last_changed_at
*  edit
      ls_inventory_update-edit = |X|.
*  action_type
      ls_inventory_update-action_type = ls_data_get-ActionType.

      APPEND ls_inventory_update TO lt_inventory_update.
      CLEAR: ls_inventory_update, ls_data_get.
    ENDIF.

    MODIFY ztb_inventory1 FROM TABLE @lt_inventory_update.

    CLEAR lt_data_get.

    " Call method get for WM data
    CALL METHOD zcl_get_inventory_data_wm=>get_wm_data
      EXPORTING
        iv_pid              = lr_pid
        iv_pid_item         = lr_pid_item
        iv_document_year    = lr_documentyear
        iv_warehouse_number = lr_warehouse_number
        iv_matnr            = lr_material
*       iv_api_status       = lr_api_status
      IMPORTING
        ev_result           = lt_data_get.

    CLEAR ls_data_get.

    SORT lt_data_get BY Pid Pid_item DocumentYear Warehouse_number Material.
    READ TABLE lt_data_get INTO ls_data_get WITH KEY  pid = k-Pid
                                                      Pid_item = k-Pid_item
                                                      DocumentYear = k-DocumentYear
                                                      Warehouse_number = k-Warehouse_number.
*                                                      Material = k-Material.
    IF ls_data_get IS INITIAL.
      SORT lt_data_get BY ConvertSapNo.
      READ TABLE lt_data_get INTO ls_data_get WITH KEY  ConvertSapNo = k-ConvertSapNo.
    ENDIF.

    result = VALUE #( FOR key IN keys ( pid = k-pid
                                        Pid_item = k-pid_item
                                        Warehouse_number = k-Warehouse_number
                                        DocumentYear = k-DocumentYear
                                        LineIndexOfPInvItem = k-LineIndexOfPInvItem
                                        Uuid = k-Uuid
                                        ConvertSapNo = k-ConvertSapNo
*                                        Material = k-Material
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
      ) TO reported-zi_inventory_data_root.
    ELSE.
      " Throw success message
      APPEND VALUE #(
        %tky = k-%tky
        %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-success
                  text     = |Updated successfully!|
                )
      ) TO reported-zi_inventory_data_root.
    ENDIF.
  ENDMETHOD.

*  METHOD get_instance_features.
*  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_INVENTORY_DATA_ROOT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_INVENTORY_DATA_ROOT IMPLEMENTATION.

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

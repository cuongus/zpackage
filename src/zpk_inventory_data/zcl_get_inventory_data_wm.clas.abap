CLASS zcl_get_inventory_data_wm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:

      BEGIN OF ty_range_option,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE string,
        high   TYPE string,
      END OF ty_range_option,

      tt_ranges            TYPE TABLE OF ty_range_option,

      tt_zc_inventory_data TYPE TABLE OF zc_inventory_data
      .

    CLASS-METHODS get_wm_data
      IMPORTING
        iv_pid              TYPE tt_ranges OPTIONAL
        iv_pid_item         TYPE tt_ranges OPTIONAL
        iv_document_year    TYPE tt_ranges OPTIONAL
        iv_Warehouse_Number TYPE tt_ranges OPTIONAL
        iv_line_index       TYPE tt_ranges OPTIONAL
        iv_store_type       TYPE tt_ranges OPTIONAL
        iv_matnr            TYPE tt_ranges OPTIONAL
        iv_sto_bin          TYPE tt_ranges OPTIONAL
        iv_phys_inv_doc     TYPE tt_ranges OPTIONAL
        iv_pi_status        TYPE tt_ranges OPTIONAL
        iv_api_status       TYPE tt_ranges OPTIONAL
        iv_convert_sap_no   TYPE tt_ranges OPTIONAL
      EXPORTING
        ev_result           TYPE tt_zc_inventory_data
      .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GET_INVENTORY_DATA_WM IMPLEMENTATION.


  METHOD get_wm_data.
    DATA:
      lt_data   TYPE TABLE OF  zc_inventory_data,
      lt_result TYPE TABLE OF zc_inventory_data,
      ls_data   TYPE zc_inventory_data.

    DATA:

      lv_pid              TYPE RANGE OF i_ewm_physinvtryitemrow-PhysicalInventoryDocNumber,
      lv_pid_item         TYPE RANGE OF i_ewm_physinvtryitemrow-PhysicalInventoryItemNumber,
      lv_document_year    TYPE RANGE OF i_ewm_physinvtryitemrow-PhysicalInventoryDocYear,
      lv_Warehouse_Number TYPE RANGE OF i_ewm_physinvtryitemrow-EWMWarehouse,
      lv_line_index       TYPE RANGE OF i_ewm_physinvtryitemrow-LineIndexOfPInvItem,
      lv_store_type       TYPE RANGE OF i_ewm_physinvtryitemrow-EWMStorageType,
      lv_matnr            TYPE RANGE OF zc_inventory_data-Material,
      lv_sto_bin          TYPE RANGE OF i_ewm_physinvtryitemrow-EWMStorageBin,
      lv_phys_inv_doc     TYPE RANGE OF zc_inventory_data-PhysInvDoc,
      lv_pi_status        TYPE RANGE OF zc_inventory_data-PiStatus,
      lv_api_status       TYPE RANGE OF zc_inventory_data-ApiStatus,
      lv_convert_sap_no   TYPE RANGE OF zc_inventory_data-ConvertSapNo.


    " Fill data in to ranges
    lv_pid = CORRESPONDING #( iv_pid ).
    lv_pid_item = CORRESPONDING #( iv_pid_item ).
    lv_document_year = CORRESPONDING #( iv_document_year ).
    lv_Warehouse_Number = CORRESPONDING #( iv_Warehouse_Number ).
    lv_line_index = CORRESPONDING #( iv_line_index ).
    lv_store_type = CORRESPONDING #( iv_store_type ).
    lv_matnr = CORRESPONDING #( iv_matnr ).
    lv_sto_bin = CORRESPONDING #( iv_sto_bin ).
    lv_phys_inv_doc = CORRESPONDING #( iv_phys_inv_doc ).
    lv_pi_status = CORRESPONDING #( iv_pi_status ).
    lv_api_status = CORRESPONDING #( iv_api_status ).
    lv_convert_sap_no = CORRESPONDING #( iv_convert_sap_no ).

    DATA:
        lv_matnr_c18 TYPE c LENGTH 18.

    LOOP AT lv_matnr ASSIGNING FIELD-SYMBOL(<fs_matnr>).
      lv_matnr_c18 = |{ <fs_matnr>-low ALPHA = IN }|.
      <fs_matnr>-low = lv_matnr_c18.
    ENDLOOP.

    SELECT
            a~PhysicalInventoryDocNumber,
            a~PhysicalInventoryItemNumber,
            a~PhysicalInventoryDocYear,
            a~EWMWarehouse,
            a~EWMStorageBin,
            a~EWMStorageType,
            a~Product,
            a~LineIndexOfPInvItem,
            a~PhysicalInventoryDocumentType,
            a~ActivityArea,
            a~EWMStockType,
            a~Batch,
            a~StockDocumentCategory,
            a~EWMStockUsage,
            a~EWMStockOwner,
            a~SpecialStockIdfgSalesOrder,
            a~SpecialStockIdfgSalesOrderItem,
            a~EWMPhysInvtryBookQuantity,
            a~EWMPhysInvtryCountedQuantity,
            a~EWMPhysInvtryCountedQtyUnit,
            a~EWMPhysInvtryEnteredQuantity,
            a~EWMPhysInvtryEnteredQtyUnit,
            a~EWMPhysInvtryBookQtyUnit,
            a~PInvIsZeroCount,
            b~EWMPhysicalInventoryStatus,
            b~PInvCountedUTCDateTime
*            b~PInvCountedUTCDateTime,
*            b~PhysicalInventoryCountUserName
        FROM i_ewm_physinvtryitemrow AS a
        INNER JOIN i_ewm_physicalinventoryitem AS b
        ON a~PhysicalInventoryDocNumber = b~PhysicalInventoryDocNumber
        AND a~PhysicalInventoryItemNumber = b~PhysicalInventoryItemNumber
        AND a~EWMWarehouse = b~EWMWarehouse
        WHERE a~EWMWarehouse IN @lv_Warehouse_Number
        AND a~EWMStorageBin IN @lv_sto_bin
        AND a~PhysicalInventoryDocNumber IN @lv_pid
        AND a~PhysicalInventoryDocNumber IN @lv_phys_inv_doc
        AND a~PhysicalInventoryItemNumber IN @lv_pid_item
        AND a~PhysicalInventoryDocYear IN @lv_document_year
        AND a~LineIndexOfPInvItem IN @lv_line_index
        AND a~EWMStorageType IN @lv_store_type
        AND a~Product IN @lv_matnr
        AND b~EWMPhysicalInventoryStatus IN @lv_pi_status
        INTO TABLE @DATA(gt_data).

    SORT gt_data BY PhysicalInventoryDocNumber PhysicalInventoryItemNumber.

    DATA: lt_matnr_nozero TYPE RANGE OF ztb_inventory1-material,
          ls_matnr        LIKE LINE OF lv_matnr,
          ls_nozero       LIKE LINE OF lt_matnr_nozero.

    CLEAR lt_matnr_nozero.

    LOOP AT lv_matnr INTO ls_matnr.
      ls_nozero-sign   = ls_matnr-sign.
      ls_nozero-option = ls_matnr-option.

      " Bỏ leading zeros (ABAP Cloud không cho CALL FUNCTION)
      DATA(lv_clean_low)  = |{ ls_matnr-low ALPHA = OUT }|.
      DATA(lv_clean_high) = |{ ls_matnr-high ALPHA = OUT }|.

      ls_nozero-low  = lv_clean_low.
      ls_nozero-high = lv_clean_high.

      APPEND ls_nozero TO lt_matnr_nozero.
    ENDLOOP.

    " TH A tạo chứng từ k có PID và PID item
    SELECT *
        FROM ztb_inventory1
        WHERE api_status = 'A'
        AND warehouse_number IN @lv_warehouse_number
        AND pid IN @lv_pid
        AND pid_item IN @lv_pid_item
        AND store_type IN @lv_store_type
        AND material IN @lt_matnr_nozero
        INTO TABLE @DATA(lt_status).

    DATA(lv_stt) = 1.

    LOOP AT lt_status INTO DATA(ls_status).
      ls_data-Uuid = ls_status-uuid.
      ls_data-ConvertSapNo = ls_status-convert_sap_no.
      ls_data-pid = ''.
      ls_data-pid_item = ''.
      ls_data-DocumentYear = ls_status-document_year.
*        ls_data-DocDate = ls_status-doc_date.
      ls_data-Proce = ls_status-proce.
      ls_data-CountDate = ls_status-count_date.
      ls_data-Warehouse_number = ls_status-warehouse_number.
      ls_data-StoreType = ls_status-store_type.
      ls_data-StorageBin = ls_status-storage_bin.
*        ls_data-Plant = ls_status-storage_location.
      ls_data-Material = ls_status-material.

      DATA(lv_matnr_status) = |{ ls_status-material ALPHA = IN }|.
      DATA(lv_matnr18) = lv_matnr_status+22(18).

      SELECT SINGLE
            ProductName
          FROM i_producttext
          WHERE Language = 'E'
          AND Product = @lv_matnr18
          INTO @DATA(lw_product_1).

      ls_data-MaterialDescription = lw_product_1.
      ls_data-Batch = ls_status-batch.
      ls_data-SpecialStock = ls_status-spe_stok.
*      ls_data-SpecialStockNumber = ls_status-spe_stok_num.
      ls_data-Salesorder = ls_status-sales_order.
      ls_data-SalesOrderItem = ls_status-sales_order_item.
      ls_data-StockType = ls_status-stock_type.
      ls_data-BookQty = ls_status-book_qty.
      ls_data-BookQtyUom = ls_status-book_qty_uom.
      ls_data-PdaQty = ls_status-pda_qty.
      ls_data-CountedQty = ls_status-pda_qty.

      IF ls_status-counted_qty_uom = 'PC'.
        ls_data-CountedQtyUom = 'ST'.
      ELSE.
        ls_data-CountedQtyUom = ls_status-counted_qty_uom.
      ENDIF.

      ls_data-EnteredQtyPi = ls_status-entered_qty_pi.
      ls_data-EnteredQtyUom = ls_status-entered_qty_uom.
      ls_data-ZeroCount = ls_status-zero_count.
      ls_data-DiffQty = ls_status-diff_qty.
      ls_data-ApiStatus = ls_status-api_status.
      ls_data-ApiMessage = ls_status-api_message.
      ls_data-PdaDate = ls_status-pda_date.
      ls_data-PdaTime = ls_status-pda_time.
      ls_data-Counter = ls_status-counter.
      ls_data-ApiDate = ls_status-api_date.
      ls_data-ApiTime = ls_status-api_time.
      ls_data-PiStatus = ls_status-pi_status.
      ls_data-UserUpload = ls_status-user_upload.
      ls_data-UploadTime = ls_status-upload_time.
      ls_data-UploadMessage = ls_status-upload_message.
      ls_data-UploadStatus = ls_status-upload_status.

      ls_data-DiffQty = ls_status-book_qty - ls_status-pda_qty.
      ls_data-Stt = lv_stt.

      APPEND ls_data TO lt_data.
      lv_stt = lv_stt + 1.
      CLEAR: ls_status,ls_data.
    ENDLOOP.

*    DELETE ADJACENT DUPLICATES FROM gt_data COMPARING PhysicalInventoryDocNumber PhysicalInventoryItemNumber LineIndexOfPInvItem.

    DATA: lv_timestamp TYPE timestampl,
          lv_date      TYPE d,
          lv_time      TYPE t,
          lv_date_text TYPE budat,
          lv_time_text TYPE string.


    LOOP AT gt_data INTO DATA(gs_data).
      ls_data-Stt = lv_stt.

      SELECT SINGLE
              PInvCountedUTCDateTime,
              PhysicalInventoryCountUserName,
              EWMPhysicalInventoryStatus
          FROM i_ewm_physicalinventoryitem
          WHERE PhysicalInventoryDocNumber = @gs_data-PhysicalInventoryDocNumber
          AND EWMWarehouse = @gs_data-EWMWarehouse
          AND PhysicalInventoryItemNumber = @gs_data-PhysicalInventoryItemNumber
          AND EWMPhysicalInventoryStatus = @gs_data-EWMPhysicalInventoryStatus
          INTO @DATA(lw_INVENTORYITEM).

      SELECT SINGLE ProductName
          FROM i_producttext
          WHERE Language = 'E'
          AND Product = @gs_Data-Product
          INTO @DATA(lw_product).

      SELECT SINGLE *
          FROM ztb_inventory1
          WHERE pid = @gs_data-PhysicalInventoryDocNumber
          AND pid_item = @gs_data-PhysicalInventoryItemNumber
          AND warehouse_number = @gs_data-EWMWarehouse
          AND document_year = @gs_data-PhysicalInventoryDocYear
*          AND lineindexofpinvitem = @gs_data-LineIndexOfPInvItem
*          AND spe_stok = @gs_data-StockDocumentCategory
*          AND sales_order = @gs_data-SpecialStockIdfgSalesOrder
*          AND sales_order_item = @gs_data-SpecialStockIdfgSalesOrderItem
          INTO @DATA(ls_inventory1).

      "dữ liệu chung
      lv_timestamp = lw_inventoryitem-pinvcountedutcdatetime.
      CONVERT TIME STAMP lv_timestamp TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time.
      DATA(lv_year) = lv_date+0(4).
      DATA(lv_month) = lv_date+4(2).
      DATA(lv_day) = lv_date+6(2).

      ls_data-LineIndexOfPInvItem = gs_data-LineIndexOfPInvItem.
      CONDENSE ls_data-LineIndexOfPInvItem NO-GAPS.

      ls_Data-DocumentYear = gs_data-PhysicalInventoryDocYear.
      ls_data-proce = gs_data-PhysicalInventoryDocumentType.
      ls_data-Warehouse_Number =  gs_data-EWMWarehouse.
      ls_data-StoreType = gs_Data-ActivityArea.
      ls_data-StockType = gs_data-EWMStockType.
      ls_Data-material = gs_Data-Product.
      ls_data-batch = gs_data-Batch.
      ls_data-SpecialStock = gs_data-StockDocumentCategory.
      ls_data-Salesorder = gs_data-SpecialStockIdfgSalesOrder.
      ls_data-SalesOrderItem = gs_data-SpecialStockIdfgSalesOrderItem.

      IF ls_Data-material IS NOT INITIAL.
        ls_data-MaterialDescription = lw_product.
        ls_data-StorageBin = gs_data-EWMStorageBin.
      ELSE.
        ls_data-MaterialDescription = ''.
        ls_data-StorageBin = ''.
      ENDIF.

      ls_data-BookQty = gs_Data-EWMPhysInvtryBookQuantity.
      ls_data-BookQtyUom  = gs_Data-EWMPhysInvtryBookQtyUnit.
      ls_data-EnteredQtyPi  = gs_Data-EWMPhysInvtryEnteredQuantity.
      ls_data-EnteredQtyUom = gs_Data-EWMPhysInvtryEnteredQtyUnit.
      ls_data-PiStatus = lw_INVENTORYITEM-EWMPhysicalInventoryStatus.


      "TH post API thành công
      IF ls_inventory1-api_status = 'S' AND ls_inventory1-edit <> 'X' AND ls_inventory1-upload_status <> 'S'.
        ls_data-pid = gs_data-PhysicalInventoryDocNumber.
        ls_data-pid_item = gs_data-PhysicalInventoryItemNumber.
        ls_data-ConvertSapNo = ls_inventory1-convert_sap_no.
        ls_data-CountDate = ls_inventory1-count_date.
        ls_data-PdaQty = ls_inventory1-pda_qty.

        IF ls_inventory1-counted_qty_uom = 'PC'.
          ls_data-CountedQtyUom  = gs_Data-EWMPhysInvtryBookQtyUnit.
        ELSE.
          ls_data-CountedQtyUom = ls_inventory1-counted_qty_uom.
        ENDIF.

        ls_data-Counter = ls_inventory1-counter.
        ls_data-CountedQty = ls_inventory1-pda_qty.
        ls_data-ApiStatus = ls_inventory1-api_status.
        ls_data-ApiMessage = ls_inventory1-api_message.
        ls_data-ApiDate = ls_inventory1-api_date.
        ls_data-ApiTime = ls_inventory1-api_time.
        ls_data-PdaDate = ls_inventory1-pda_date.
        ls_data-PdaTime = ls_inventory1-pda_time.
        ls_data-DiffQty = gs_Data-EWMPhysInvtryBookQuantity - ls_inventory1-pda_qty.
        ls_data-ZeroCount = gs_Data-PInvIsZeroCount.

        " TH vừa post API thành công và chỉnh sửa cột quantity trên màn hình
      ELSEIF  ls_inventory1-edit = 'X' AND ls_inventory1-api_status = 'S'.
        ls_data-CountedQty = ls_inventory1-counted_qty.
        ls_data-pid = gs_data-PhysicalInventoryDocNumber.
        ls_data-pid_item = gs_data-PhysicalInventoryItemNumber.
        ls_data-ApiStatus = ls_inventory1-api_status.
        ls_data-ApiMessage = ls_inventory1-api_message.
        ls_data-CountedQtyUom = gs_Data-EWMPhysInvtryCountedQtyUnit.
        ls_data-PdaQty = ls_inventory1-pda_qty.
        ls_data-ConvertSapNo = ls_inventory1-convert_sap_no.
        ls_data-DiffQty = gs_Data-EWMPhysInvtryBookQuantity - ls_inventory1-counted_qty.
        ls_data-ZeroCount = gs_Data-PInvIsZeroCount.

        " TH chỉnh sửa cột quantity trên màn hình
      ELSEIF ls_inventory1-edit = 'X'.
        ls_data-CountedQty = ls_inventory1-counted_qty.
        ls_data-pid = gs_data-PhysicalInventoryDocNumber.
        ls_data-pid_item = gs_data-PhysicalInventoryItemNumber.
        ls_data-ZeroCount = ls_inventory1-zero_count.
        ls_data-CountDate = ls_inventory1-count_date.
        ls_data-DiffQty = gs_Data-EWMPhysInvtryBookQuantity - ls_inventory1-counted_qty.

        " TH post API lỗi
      ELSEIF ls_inventory1-api_status = 'E' AND ls_inventory1-edit <> 'X' .

        ls_data-pid = gs_data-PhysicalInventoryDocNumber.
        ls_data-pid_item = gs_data-PhysicalInventoryItemNumber.
        ls_data-ConvertSapNo = ls_inventory1-convert_sap_no.
        ls_data-ApiStatus = ls_inventory1-api_status.
        ls_data-ApiMessage = ls_inventory1-api_message.
        ls_data-ApiDate = ls_inventory1-api_date.
        ls_data-ApiTime = ls_inventory1-api_time.
        ls_data-counter = lw_INVENTORYITEM-PhysicalInventoryCountUserName.
        ls_data-CountDate = lv_date_text.
        ls_data-DiffQty = gs_Data-EWMPhysInvtryBookQuantity - gs_Data-EWMPhysInvtryCountedQuantity.
        ls_data-ZeroCount = gs_Data-PInvIsZeroCount.

        "TH upload thành công
      ELSEIF ls_inventory1-upload_status = 'S'.
        ls_data-pid = gs_data-PhysicalInventoryDocNumber.
        ls_data-pid_item = gs_data-PhysicalInventoryItemNumber.
        ls_data-ConvertSapNo = ls_inventory1-convert_sap_no.
        ls_data-CountedQty = ls_inventory1-counted_qty.

        IF ls_inventory1-counted_qty_uom = 'PC'.
          ls_data-CountedQtyUom  = gs_Data-EWMPhysInvtryBookQtyUnit.

        ELSE.
          ls_data-CountedQtyUom = ls_inventory1-counted_qty_uom.

        ENDIF.
        ls_data-UploadTime = ls_inventory1-upload_time.
        ls_data-UploadMessage = ls_inventory1-upload_message.
        ls_data-UploadStatus = ls_inventory1-upload_status.
        ls_data-UploadDate = ls_inventory1-upload_date.
        ls_data-UserUpload = ls_inventory1-user_upload.
        ls_data-DiffQty = gs_Data-EWMPhysInvtryBookQuantity - ls_inventory1-counted_qty.
        ls_data-ZeroCount = gs_Data-PInvIsZeroCount.
        ls_data-CountDate = ls_inventory1-count_date.


        "TH upload lỗi
      ELSEIF ls_inventory1-upload_status = 'F'.
        ls_data-pid = gs_data-PhysicalInventoryDocNumber.
        ls_data-pid_item = gs_data-PhysicalInventoryItemNumber.

        ls_data-UploadTime = ls_inventory1-upload_time.
        ls_data-UploadMessage = ls_inventory1-upload_message.
        ls_data-UploadStatus = ls_inventory1-upload_status.
        ls_data-UploadDate = ls_inventory1-upload_date.
        ls_data-ZeroCount = gs_Data-PInvIsZeroCount.

        "TH cả upload, cả post API thành công
      ELSEIF ls_inventory1-upload_status = 'S' AND ls_inventory1-api_status = 'S' AND ls_inventory1-edit <> 'X'.

        ls_data-pid = gs_data-PhysicalInventoryDocNumber.
        ls_data-pid_item = gs_data-PhysicalInventoryItemNumber.
        ls_data-ConvertSapNo = ls_inventory1-convert_sap_no.
        ls_data-CountedQty = ls_inventory1-counted_qty.

        IF ls_inventory1-counted_qty_uom = 'PC'.
          ls_data-CountedQtyUom  = gs_Data-EWMPhysInvtryBookQtyUnit.
        ELSE.
          ls_data-CountedQtyUom = ls_inventory1-counted_qty_uom.
        ENDIF.
        ls_data-UploadTime = ls_inventory1-upload_time.
        ls_data-UploadMessage = ls_inventory1-upload_message.
        ls_data-UploadStatus = ls_inventory1-upload_status.
        ls_data-UploadDate = ls_inventory1-upload_date.
        ls_data-UserUpload = ls_inventory1-user_upload.
        ls_data-ApiStatus = ls_inventory1-api_status.
        ls_data-ApiMessage = ls_inventory1-api_message.
        ls_data-ApiDate = ls_inventory1-api_date.
        ls_data-ApiTime = ls_inventory1-api_time.
        ls_data-PdaDate = ls_inventory1-pda_date.
        ls_data-PdaTime = ls_inventory1-pda_time.
        ls_data-DiffQty = gs_Data-EWMPhysInvtryBookQuantity - ls_inventory1-counted_qty.
        ls_data-ZeroCount = gs_Data-PInvIsZeroCount.

        "TH lấy dữ liệu từ CDSview
      ELSE.
        lv_date_text = lv_date.
        lv_time_text = |{ lv_time TIME = ISO }|.
        ls_data-pid = gs_data-PhysicalInventoryDocNumber.
        ls_data-pid_item = gs_data-PhysicalInventoryItemNumber.
        ls_data-CountDate = lv_date_text.
        ls_data-DiffQty = gs_Data-EWMPhysInvtryBookQuantity - gs_Data-EWMPhysInvtryCountedQuantity.
        ls_data-CountedQtyUom = gs_Data-EWMPhysInvtryCountedQtyUnit.
        ls_data-counter = lw_INVENTORYITEM-PhysicalInventoryCountUserName.
        ls_data-CountedQty    = gs_Data-EWMPhysInvtryCountedQuantity.
      ENDIF.

      APPEND ls_data TO lt_data.
      lv_stt = lv_stt + 1.
      CLEAR: ls_data, gs_Data, lw_INVENTORYITEM,lv_timestamp,lv_date_text,lv_date_text,lv_date,lv_time,ls_inventory1.
    ENDLOOP.

    IF lv_convert_sap_no[] IS NOT INITIAL .
      DELETE lt_data  WHERE ConvertSapNo NOT IN lv_convert_sap_no.
    ENDIF.

    IF lv_api_status[] IS NOT INITIAL.
      DELETE lt_data WHERE apistatus NOT IN lv_api_status.
    ENDIF.

    ev_result = lt_data.
  ENDMETHOD.
ENDCLASS.

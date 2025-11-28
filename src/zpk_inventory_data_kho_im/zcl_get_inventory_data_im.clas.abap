CLASS zcl_get_inventory_data_im DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:

      BEGIN OF ty_range_option,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE string,
        high   TYPE string,
      END OF ty_range_option,

      tt_ranges               TYPE TABLE OF ty_range_option,

      tt_zc_inventory_data_im TYPE TABLE OF zc_inventory_data_im
      .

    CLASS-METHODS get_im_data
      IMPORTING
        iv_pid            TYPE tt_ranges OPTIONAL
        iv_pid_item       TYPE tt_ranges OPTIONAL
        iv_document_year  TYPE tt_ranges OPTIONAL
        iv_plant          TYPE tt_ranges OPTIONAL
        iv_store_loca     TYPE tt_ranges OPTIONAL
*        iv_store_type     TYPE tt_ranges OPTIONAL
        iv_matnr          TYPE tt_ranges OPTIONAL
*        iv_matnr_1        TYPE tt_ranges OPTIONAL
        iv_convert_sap_no TYPE tt_ranges OPTIONAL
        iv_pi_status      TYPE tt_ranges OPTIONAL
        iv_api_status     TYPE tt_ranges OPTIONAL
      EXPORTING
        ev_result         TYPE tt_zc_inventory_data_im
      .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GET_INVENTORY_DATA_IM IMPLEMENTATION.


  METHOD get_im_data.
    DATA:
      lt_data   TYPE TABLE OF  zc_inventory_data_im,
      lt_result TYPE TABLE OF zc_inventory_data_im,
      ls_data   TYPE zc_inventory_data_im.

    DATA:
      lv_pid            TYPE RANGE OF i_physinvtrydocitem-PhysicalInventoryDocument,
      lv_pid_item       TYPE RANGE OF i_physinvtrydocitem-PhysicalInventoryDocumentItem,
      lv_document_year  TYPE RANGE OF i_physinvtrydocitem-FiscalYear,
      lv_plant          TYPE RANGE OF i_physinvtrydocitem-Plant,
      lv_store_loca     TYPE RANGE OF i_physinvtrydocitem-StorageLocation,
      lv_store_type     TYPE RANGE OF i_ewm_physinvtryitemrow-EWMStorageType,
      lv_matnr          TYPE RANGE OF i_physinvtrydocitem-Material,
      lv_matnr_1        TYPE RANGE OF ztb_inven_im1-material,
      lv_convert_sap_no TYPE RANGE OF zc_inventory_data_im-ConvertSapNo,
      lv_pi_status      TYPE RANGE OF zc_inventory_data_im-PiStatus,
      lv_api_status     TYPE RANGE OF zc_inventory_data_im-ApiStatus
      .

    " Fill data in to ranges
    lv_pid = CORRESPONDING #( iv_pid ).
    lv_pid_item = CORRESPONDING #( iv_pid_item ).
    lv_document_year = CORRESPONDING #( iv_document_year ).
    lv_store_loca = CORRESPONDING #( iv_store_loca ).
    lv_plant = CORRESPONDING #( iv_plant ).
    lv_matnr = CORRESPONDING #( iv_matnr ).
    lv_convert_sap_no = CORRESPONDING #( iv_convert_sap_no ).
    lv_pi_status = CORRESPONDING #( iv_pi_status ).
    lv_api_status = CORRESPONDING #( iv_api_status ).

    DATA:
      lv_matnr_c18   TYPE c LENGTH 18,
      lv_pid_c10     TYPE c LENGTH 10,
      lv_pid_item_c3 TYPE c LENGTH 3
      .

    LOOP AT lv_pid ASSIGNING FIELD-SYMBOL(<fs_pid>).
      lv_pid_c10 = |{ <fs_pid>-low ALPHA = IN }|.
      <fs_pid>-low = lv_pid_c10.
    ENDLOOP.

    LOOP AT lv_pid_item ASSIGNING FIELD-SYMBOL(<fs_pid_item>).
      lv_pid_item_c3 = |{ <fs_pid_item>-low ALPHA = IN }|.
      <fs_pid_item>-low = lv_pid_item_c3.
    ENDLOOP.

    LOOP AT lv_matnr ASSIGNING FIELD-SYMBOL(<fs_matnr>).
      lv_matnr_c18 = |{ <fs_matnr>-low ALPHA = IN }|.
      <fs_matnr>-low = lv_matnr_c18.
    ENDLOOP.

    " Select từ CDS view
    SELECT *
        FROM i_physinvtrydocitem
        WHERE  plant IN @lv_plant
        AND StorageLocation IN @lv_store_loca
        AND FiscalYear IN @lv_document_year
        AND PhysicalInventoryDocument IN @lv_pid
        AND Material IN @lv_matnr
        AND PhysicalInventoryDocumentItem IN   @lv_pid_item
        INTO TABLE @DATA(gt_data).

    DELETE gt_data WHERE PhysInvtryItemIsDeleted = 'X'.
    SORT gt_data BY PhysicalInventoryDocument PhysicalInventoryDocumentItem.

    DATA: lt_matnr_nozero TYPE RANGE OF ztb_inven_im1-material,
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

    SELECT *
        FROM ztb_inven_im1
        WHERE api_status = 'A'
        AND plant IN @lv_plant
        AND storage_location IN @lv_store_loca
         AND pid IN @lv_pid
        AND pid_item IN @lv_pid_item
        AND material IN @lt_matnr_nozero
        INTO TABLE @DATA(lt_status).

    LOOP AT lt_status INTO DATA(ls_status).
      ls_data-Uuid = ls_status-uuid.
      ls_data-ConvertSapNo = ls_status-convert_sap_no.
      ls_data-pid = ''.
      ls_data-pid_item = ''.
      ls_data-DocumantYear = ls_status-document_year.
      ls_data-DocDate = ls_status-doc_date.
      ls_data-Plantcountdate = ls_status-plant_count_date.
      ls_data-Countdate  = ls_status-count_date.
      ls_data-Plant = ls_status-plant.
      ls_data-Storagelocation = ls_status-storage_location.
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
      ls_data-Spestok = ls_status-spe_stok.
      ls_data-Spestoknum = ls_status-spe_stok_num.
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

*      ls_data-CountedQtyUom = ls_status-counted_qty_uom.
      ls_data-EnteredQtyPi = ls_status-entered_qty_pi.
      ls_data-EnteredQtyUom = ls_status-entered_qty_uom.
      ls_data-ZeroCount = ls_status-zero_count.

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
      ls_data-DiffQty = ls_status-book_qty - ls_status-pda_qty .
      APPEND ls_data TO lt_data.
      CLEAR: ls_status,ls_data.
    ENDLOOP.

    LOOP AT gt_data INTO DATA(gs_data).

      SELECT SINGLE *
          FROM i_physinvtrydocheader
          WHERE Plant = @gs_data-Plant
          AND StorageLocation = @gs_data-StorageLocation
          AND PhysicalInventoryDocument = @gs_data-PhysicalInventoryDocument
          INTO @DATA(lw_DOCHEADER).

      SELECT SINGLE
            ProductName
          FROM i_producttext
          WHERE Language = 'E'
          AND Product = @gs_Data-Material
          INTO @DATA(lw_product).

      ls_Data-DocumantYear = gs_data-FiscalYear.
      ls_data-Countdate = gs_data-PhysicalInventoryLastCountDate.
      ls_data-DocDate = lw_DOCHEADER-DocumentDate.
      ls_data-plant =  gs_Data-Plant .
      ls_data-StorageLocation =  gs_data-StorageLocation.
      ls_Data-material = gs_Data-Material.
      ls_data-MaterialDescription = lw_product.
      ls_data-batch = gs_data-Batch.
      ls_data-Spestok = gs_data-InventorySpecialStockType.

      IF lw_DOCHEADER-PhysInvtryAdjustmentPostingSts = 'X'.
        ls_data-PiStatus = 'Adjusted'.
      ELSEIF lw_DOCHEADER-PhysicalInventoryCountStatus = 'X' OR gs_data-PhysicalInventoryItemIsCounted = 'X'.
        ls_data-PiStatus = 'Counted'.
      ELSEIF lw_DOCHEADER-PhysicalInventoryCountStatus = 'A' AND gs_data-QuantityInUnitOfEntry IS NOT INITIAL.
        ls_data-PiStatus = 'Counted'.
      ELSEIF lw_DOCHEADER-PhysicalInventoryCountStatus = 'A' AND gs_data-QuantityInUnitOfEntry IS INITIAL.
        ls_data-PiStatus = 'Not Counted'.
      ELSE.
        ls_data-PiStatus = 'Not Counted'.
      ENDIF.

      SELECT SINGLE *
          FROM i_stockquantitycurrentvalue_2( p_displaycurrency = 'VND' )
          WHERE Product = @gs_Data-Material
          AND Plant = @gs_Data-Plant
          AND StorageLocation = @gs_data-StorageLocation
          AND Batch = @gs_data-Batch
          AND Supplier = @gs_data-Supplier
          AND SDDocument = @gs_data-SalesOrder
          AND SDDocumentItem = @gs_data-SalesOrderItem
          INTO @DATA(ls_bookqty).

      ls_data-Plantcountdate = lw_DOCHEADER-PhysInventoryPlannedCountDate.
      ls_data-Spestoknum = gs_data-Supplier.
      ls_data-StockType = gs_data-PhysicalInventoryStockType.
*      ls_data-BookQty      =  gs_data-QuantityInUnitOfEntry.
*      ls_data-BookQtyUom = gs_Data-UnitOfEntry.
      ls_data-BookQty      = ls_bookqty-MatlWrhsStkQtyInMatlBaseUnit.
      ls_data-BookQtyUom = ls_bookqty-MaterialBaseUnit.

      ls_data-Counter = gs_data-CountedByUser.
      ls_data-Salesorder = gs_data-SalesOrder.
      ls_data-SalesOrderItem = gs_data-SalesOrderItem.

      SELECT SINGLE *
          FROM ztb_inven_im1
          WHERE pid = @gs_data-PhysicalInventoryDocument
          AND pid_item = @gs_data-PhysicalInventoryDocumentItem
          AND document_year = @gs_data-FiscalYear
          INTO @DATA(ls_inven_im1).

      " TH post API thành công
      IF ls_inven_im1-api_status = 'S' AND ls_inven_im1-edit <> 'X' AND ls_inven_im1-upload_status <> 'S'.
        ls_data-pid = gs_data-PhysicalInventoryDocument.
        ls_data-pid_item = gs_data-PhysicalInventoryDocumentItem.
        ls_data-ConvertSapNo = ls_inven_im1-convert_sap_no.
        ls_data-Plantcountdate = ls_inven_im1-plant_count_date.
        ls_data-PdaQty = ls_inven_im1-pda_qty.
*        ls_data-CountedQtyUom = ls_inven_im1-counted_qty_uom.
        ls_data-Counter = ls_inven_im1-counter.
        ls_data-CountedQty = ls_inven_im1-pda_qty.
        ls_data-ApiStatus = ls_inven_im1-api_status.
        ls_data-ApiMessage = ls_inven_im1-api_message.
        ls_data-Countdate  = ls_inven_im1-count_date.
        ls_data-ApiDate = ls_inven_im1-api_date.
        ls_data-ApiTime = ls_inven_im1-api_time.
        ls_data-PdaDate = ls_inven_im1-pda_date.
        ls_data-PdaTime = ls_inven_im1-pda_time.
        ls_data-ZeroCount = gs_Data-PhysicalInventoryItemIsZero.

        IF ls_inven_im1-counted_qty_uom = 'PC'.
          ls_data-CountedQtyUom  = gs_Data-UnitOfEntry.
        ELSE.
          ls_data-CountedQtyUom = ls_inven_im1-counted_qty_uom.
        ENDIF.

        ls_data-DiffQty = ls_data-BookQty - ls_inven_im1-pda_qty.

        " TH change count và post API thành công
      ELSEIF ls_inven_im1-edit = 'X' AND ls_inven_im1-api_status = 'S'.
        ls_data-pid = gs_data-PhysicalInventoryDocument.
        ls_data-pid_item = gs_data-PhysicalInventoryDocumentItem.
        ls_data-ApiStatus = ls_inven_im1-api_status.
        ls_data-ApiMessage = ls_inven_im1-api_message.
        ls_data-Countdate  = ls_inven_im1-count_date.
        ls_data-CountedQty    = ls_inven_im1-counted_qty.
        ls_data-CountedQtyUom = gs_Data-UnitOfEntry.
        ls_data-PdaQty = ls_inven_im1-pda_qty.
        ls_data-ConvertSapNo = ls_inven_im1-convert_sap_no.
        ls_data-DiffQty = ls_data-BookQty - ls_inven_im1-pda_qty.
        ls_data-ZeroCount = gs_Data-PhysicalInventoryItemIsZero.
        ls_data-Counter = ls_inven_im1-counter.

        "TH post lỗi
      ELSEIF ls_inven_im1-api_status = 'E' AND ls_inven_im1-edit <> 'X' .
        ls_data-pid = gs_data-PhysicalInventoryDocument.
        ls_data-pid_item = gs_data-PhysicalInventoryDocumentItem.
        ls_data-ConvertSapNo = ls_inven_im1-convert_sap_no.
        ls_data-ApiDate = ls_inven_im1-api_date.
        ls_data-ApiTime = ls_inven_im1-api_time.
*        ls_data-PdaDate = ls_inven_im1-pda_date.
*        ls_data-PdaTime = ls_inven_im1-pda_time.

        ls_data-ApiStatus = ls_inven_im1-api_status.
        ls_data-ApiMessage = ls_inven_im1-api_message.
        ls_data-ZeroCount = gs_Data-PhysicalInventoryItemIsZero.

        "TH chỉ change count
      ELSEIF ls_inven_im1-edit = 'X'.
        ls_data-pid = gs_data-PhysicalInventoryDocument.
        ls_data-pid_item = gs_data-PhysicalInventoryDocumentItem.
        ls_data-CountedQty    = ls_inven_im1-counted_qty.
        ls_data-ZeroCount = ls_inven_im1-zero_count.
        ls_data-DiffQty = ls_data-BookQty - ls_inven_im1-counted_qty.
        ls_data-Countdate  = ls_inven_im1-count_date.

        "TH upload thành công
      ELSEIF ls_inven_im1-upload_status = 'S'.
        ls_data-pid = gs_data-PhysicalInventoryDocument.
        ls_data-pid_item = gs_data-PhysicalInventoryDocumentItem.
        ls_data-ConvertSapNo = ls_inven_im1-convert_sap_no.
        ls_data-CountedQty = ls_inven_im1-counted_qty.
        IF ls_inven_im1-counted_qty_uom = 'PC'.
          ls_data-CountedQtyUom  = gs_Data-UnitOfEntry.
        ELSE.
          ls_data-CountedQtyUom = ls_inven_im1-counted_qty_uom.
        ENDIF.
        ls_data-UploadTime = ls_inven_im1-upload_time.
        ls_data-UploadMessage = ls_inven_im1-upload_message.
        ls_data-UploadStatus = ls_inven_im1-upload_status.
        ls_data-UploadDate = ls_inven_im1-upload_date.
        ls_data-UserUpload = ls_inven_im1-user_upload.
        ls_data-DiffQty =  ls_data-BookQty - ls_inven_im1-counted_qty.
        ls_data-ZeroCount = gs_Data-PhysicalInventoryItemIsZero.
        ls_data-CountDate = ls_inven_im1-count_date.

        "TH upload lỗi
      ELSEIF ls_inven_im1-upload_status = 'F'.
        ls_data-pid = gs_data-PhysicalInventoryDocument.
        ls_data-pid_item = gs_data-PhysicalInventoryDocumentItem.

        ls_data-UploadTime = ls_inven_im1-upload_time.
        ls_data-UploadMessage = ls_inven_im1-upload_message.
        ls_data-UploadStatus = ls_inven_im1-upload_status.
        ls_data-UploadDate = ls_inven_im1-upload_date.
        ls_data-ZeroCount = gs_Data-PhysicalInventoryItemIsZero.

        "TH cả upload, cả post API thành công
      ELSEIF ls_inven_im1-upload_status = 'S' AND ls_inven_im1-api_status = 'S' AND ls_inven_im1-edit <> 'X'.

        ls_data-pid = gs_data-PhysicalInventoryDocument.
        ls_data-pid_item = gs_data-PhysicalInventoryDocumentItem.
        ls_data-ConvertSapNo = ls_inven_im1-convert_sap_no.
        ls_data-CountedQty = ls_inven_im1-counted_qty.

        IF ls_inven_im1-counted_qty_uom = 'PC'.
          ls_data-CountedQtyUom  = gs_Data-UnitOfEntry.
        ELSE.
          ls_data-CountedQtyUom = ls_inven_im1-counted_qty_uom.
        ENDIF.

        ls_data-UploadTime = ls_inven_im1-upload_time.
        ls_data-UploadMessage = ls_inven_im1-upload_message.
        ls_data-UploadStatus = ls_inven_im1-upload_status.
        ls_data-UploadDate = ls_inven_im1-upload_date.
        ls_data-UserUpload = ls_inven_im1-user_upload.
        ls_data-ApiStatus = ls_inven_im1-api_status.
        ls_data-ApiMessage = ls_inven_im1-api_message.
        ls_data-ApiDate = ls_inven_im1-api_date.
        ls_data-ApiTime = ls_inven_im1-api_time.
        ls_data-PdaDate = ls_inven_im1-pda_date.
        ls_data-PdaTime = ls_inven_im1-pda_time.
        ls_data-DiffQty = ls_data-BookQty  - ls_inven_im1-counted_qty.
        ls_data-ZeroCount = gs_Data-PhysicalInventoryItemIsZero.

        " TH select từ CDS view
      ELSE.
        ls_data-pid = gs_data-PhysicalInventoryDocument.
        ls_data-pid_item = gs_data-PhysicalInventoryDocumentItem.

        ls_data-CountedQtyUom = gs_Data-UnitOfEntry.
        ls_data-CountedQty    = gs_Data-Quantity.
        ls_data-ZeroCount = gs_Data-PhysicalInventoryItemIsZero.
        ls_data-DiffQty = ls_data-BookQty - ls_data-CountedQty.
*        ls_data-Countdate = gs_data-PhysicalInventoryLastCountDate.
*        ls_Data-DocumantYear = gs_data-FiscalYear.
      ENDIF.

      ls_data-EnteredQtyPi  =  gs_data-QuantityInUnitOfEntry.
      ls_data-EnteredQtyUom = gs_data-UnitOfEntry.
*      ls_data-DiffQty = ls_data-BookQty - ls_data-CountedQty.

      APPEND ls_data TO lt_data.
      CLEAR: ls_data, gs_Data, lw_DOCHEADER,ls_inven_im1,ls_bookqty.
    ENDLOOP.

    IF lv_convert_sap_no[] IS NOT INITIAL .
      DELETE lt_data  WHERE ConvertSapNo NOT IN lv_convert_sap_no.
    ENDIF.

*    IF lv_matnr_1[] IS NOT INITIAL.
*      DELETE lt_data WHERE Material NOT IN lv_matnr_1.
*    ENDIF.

    IF lv_pi_status[] IS NOT INITIAL.
      DELETE lt_data WHERE PiStatus NOT IN lv_pi_status.
    ENDIF.

    IF lv_api_status[] IS NOT INITIAL.
      DELETE lt_data WHERE apistatus NOT IN lv_api_status.
    ENDIF.


    ev_result = lt_data.
  ENDMETHOD.
ENDCLASS.

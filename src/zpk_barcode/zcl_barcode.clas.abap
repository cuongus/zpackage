CLASS zcl_barcode DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,


           tt_ranges  TYPE TABLE OF ty_range_option,

           tt_returns TYPE TABLE OF bapiret2,

           tt_barcore TYPE TABLE OF zc_barcode.

*    CLASS-DATA: gv_option TYPE zde_barcode.

    INTERFACES if_rap_query_provider.

    CLASS-DATA: lt_barcore TYPE tt_barcore.

    CLASS-METHODS: get_inbound_delivery IMPORTING ir_plant            TYPE tt_ranges
                                                  ir_vas              TYPE tt_ranges OPTIONAL
                                                  ir_quantity         TYPE tt_ranges OPTIONAL
                                                  ir_lineindex        TYPE tt_ranges OPTIONAL
                                                  ir_document         TYPE tt_ranges OPTIONAL
                                                  ir_document_item    TYPE tt_ranges OPTIONAL
                                                  ir_delivery         TYPE tt_ranges OPTIONAL
                                                  ir_production_Order TYPE tt_ranges OPTIONAL
                                                  ir_matnr_document   TYPE tt_ranges OPTIONAL
                                                  ir_matnr_number     TYPE tt_ranges OPTIONAL
                                                  ir_option           TYPE tt_ranges OPTIONAL
                                                  ir_keeper           TYPE tt_ranges OPTIONAL
                                                  ir_sloc             TYPE tt_ranges OPTIONAL
                                                  ir_so               TYPE tt_ranges OPTIONAL
                                                  ir_soi              TYPE tt_ranges OPTIONAL
                                                  ir_batch            TYPE tt_ranges OPTIONAL
                                                  ir_qc               TYPE tt_ranges OPTIONAL
                                                  ir_header           TYPE tt_ranges OPTIONAL
                                                  ir_supplier         TYPE tt_ranges OPTIONAL
                                                  ir_print_multi      TYPE tt_ranges OPTIONAL


                                        EXPORTING e_barcore           TYPE tt_barcore
                                                  e_return            TYPE tt_returns .

*    CLASS-METHODS append_unique_account IMPORTING iv_new_account   TYPE text10
*                                        CHANGING  cv_target_string TYPE char256.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_barcode IMPLEMENTATION.


  METHOD get_inbound_delivery.

    DATA: lt_data    TYPE TABLE OF zc_barcode,
          ls_data    TYPE zc_barcode,
          lt_barcore TYPE TABLE OF zc_barcode.


    TYPES: BEGIN OF ty_material,
             material            TYPE matnr,
             materialdescription TYPE maktx,
           END OF ty_material.

    DATA ls_Material_description TYPE ty_material.
    DATA: ls_qc          TYPE ty_range_option,
          ls_ke          TYPE ty_range_option,
          ls_print_multi TYPE ty_range_option,
*          ls_vas TYPE ty_range_option,
*          ls_supplier TYPE ty_range_option,
*          ls_ TYPE ty_range_option,
          ls_header      TYPE ty_range_option.

*    READ TABLE ir_option INTO DATA(ls_op) INDEX 1.
*    IF  sy-subrc = 0.
*    ls_data-option_name = ls_op-low.
*      APPEND ls_data TO e_barcore .
*    ENDIF.

    LOOP AT ir_option INTO DATA(ls_option).


      CASE ls_option-low.
        WHEN '1'.

          " select TH  Inbound delivery
          SELECT InboundDelivery,InboundDeliveryItem,CreationDate,CreatedByUser,Material,MaterialByCustomer,Plant,StorageLocation,QuantityIsFixed,BaseUnit,Batch,GoodsMovementStatus,DeliveryDocumentItemText,OriginalDeliveryQuantity,InventoryValuationType
          FROM i_inbounddeliveryitem
            WHERE Plant IN @ir_plant
            AND InboundDelivery IN @ir_delivery
             AND InboundDelivery IN @ir_document
            AND InboundDeliveryItem IN  @ir_document_item
            AND batch IN @ir_batch
            AND Material IN @ir_matnr_number
            AND StorageLocation IN @ir_sloc

          INTO TABLE @DATA(lt_inbound).
          LOOP AT lt_inbound INTO DATA(ls_inbound).
            ls_data-lineindex = sy-tabix.

            READ TABLE ir_qc INTO ls_qc INDEX 1.
            IF sy-subrc = 0 .
              ls_data-qc = ls_qc-low.
            ENDIF.

            READ TABLE ir_header INTO ls_header INDEX 1.
            IF sy-subrc = 0 .
              ls_data-header_type = ls_header-low.
            ENDIF.

            READ TABLE ir_print_multi INTO ls_print_multi INDEX 1.
            IF sy-subrc = 0 .
              ls_data-print_multi = ls_print_multi-low.
            ENDIF.

            READ TABLE ir_keeper INTO ls_ke INDEX 1.
            IF sy-subrc = 0 .
              ls_data-keeper = ls_ke-low.
            ENDIF.



            SELECT SINGLE supplier,ActualGoodsMovementDate,OverallGoodsMovementStatus
             FROM  i_inbounddelivery
             WHERE InboundDelivery = @ls_inbound-InboundDelivery
             INTO @DATA(ls_supplier).

            ls_data-Supplier = ls_supplier-Supplier.
            ls_data-Delivery_date = ls_supplier-ActualGoodsMovementDate.
            ls_data-status = ls_supplier-OverallGoodsMovementStatus.

            ls_data-Document = ls_inbound-InboundDelivery.
            ls_data-Document_Item = ls_inbound-InboundDeliveryItem.
            ls_data-Create_on = ls_inbound-CreationDate.
            ls_data-Create_by = ls_inbound-CreatedByUser.
            ls_data-matnr_number = ls_inbound-Material.
            ls_data-Material_description = ls_inbound-DeliveryDocumentItemText.
            ls_data-plant = ls_inbound-Plant.
            ls_data-Storage_Location = ls_inbound-StorageLocation.
            ls_data-Quantity = ls_inbound-OriginalDeliveryQuantity.
            ls_data-Unit = ls_inbound-BaseUnit.
            ls_data-batch =  ls_inbound-Batch.
            ls_data-status =  ls_inbound-GoodsMovementStatus.
            ls_data-ValuationType = ls_inbound-InventoryValuationType.
            ls_data-option_name = ls_option-low.
            APPEND ls_data TO e_barcore .
            CLEAR ls_data.
          ENDLOOP.



        WHEN '2'.

          " select TH Production Order
          SELECT a~ProductionOrder,
                 a~OrderActualEndDate,
                 a~OrderActualStartDate,
                 b~Product,
                 b~ProductionPlant,
                 b~StorageLocation,
                 b~PlannedTotalQty,
                 b~BaseUnit,
                 b~SalesOrder,
                 b~SalesOrderItem,
                 b~ActualDeliveryDate,
                 b~Batch,
                 b~OrderIsReleased
          FROM i_productionorder AS a
          INNER JOIN i_productionorderitem AS b
            ON a~ProductionOrder = b~ProductionOrder
          WHERE a~ProductionPlant IN @ir_plant
            AND a~ProductionOrder IN @ir_production_order
            AND a~ProductionOrder IN @ir_document
            AND b~Product IN @ir_matnr_number
            AND b~StorageLocation IN @ir_sloc
          INTO TABLE @DATA(lt_product_join).
          LOOP AT lt_product_join INTO DATA(ls_product_join).
            ls_data-lineindex = sy-tabix.

            READ TABLE ir_qc INTO ls_qc INDEX 1.
            IF sy-subrc = 0.
              ls_data-qc = ls_qc-low.
            ENDIF.

            READ TABLE ir_header INTO ls_header INDEX 1.
            IF sy-subrc = 0.
              ls_data-header_type = ls_header-low.
            ENDIF.

            READ TABLE ir_print_multi INTO ls_print_multi INDEX 1.
            IF sy-subrc = 0.
              ls_data-print_multi = ls_print_multi-low.
            ENDIF.

            READ TABLE ir_keeper INTO ls_ke INDEX 1.
            IF sy-subrc = 0.
              ls_data-keeper = ls_ke-low.
            ENDIF.


            ls_data-Document = ls_product_join-ProductionOrder.
            ls_data-Create_on = ls_product_join-OrderActualEndDate.
            ls_data-matnr_number = ls_product_join-Product.


            SELECT SINGLE MaterialDescription
              FROM c_bommaterialvh
              WHERE Material = @ls_product_join-Product
              INTO @ls_data-Material_description.


            IF ls_product_join-OrderIsReleased = 'X'.
              ls_data-Production_Order_Status = 'Released'.
            ELSE.
              ls_data-Production_Order_Status = ''.
            ENDIF.

            ls_data-batch = ls_product_join-Batch.
            ls_data-plant = ls_product_join-ProductionPlant.
            ls_data-Storage_Location = ls_product_join-StorageLocation.
            ls_data-Quantity = ls_product_join-PlannedTotalQty.
            ls_data-Unit = ls_product_join-BaseUnit.
            ls_data-Sale_Order = ls_product_join-SalesOrder.
            ls_data-Sale_Order_item = ls_product_join-SalesOrderItem.
            ls_data-Start_date = ls_product_join-OrderActualStartDate.
            ls_data-End_date = ls_product_join-ActualDeliveryDate.
            ls_data-option_name = ls_option-low.

            APPEND ls_data TO e_barcore.
            CLEAR ls_data.
          ENDLOOP.

        WHEN '3'.

          " select TH Material Document
          SELECT MaterialDocument,MaterialDocumentItem,SpecialStockIdfgSalesOrder,SpecialStockIdfgSalesOrderitem,Material,Plant,StorageLocation,QuantityInEntryUnit,EntryUnit,Batch,SalesOrder,SalesOrderItem,PostingDate,InventoryValuationType
          FROM  i_materialdocumentitem_2
          WHERE Plant IN @ir_plant
          AND  MaterialDocument IN @ir_matnr_document
          AND MaterialDocument IN @ir_document
          AND StorageLocation IN @ir_sloc
          AND Material IN @ir_matnr_number
          AND batch IN @ir_batch
          INTO TABLE @DATA(lt_matnr_doc).

          LOOP AT lt_matnr_doc INTO DATA(ls_matnr_doc).
            ls_data-lineindex = sy-tabix.

            READ TABLE ir_qc INTO ls_qc INDEX 1.
            IF sy-subrc = 0 .
              ls_data-qc = ls_qc-low.
            ENDIF.

            READ TABLE ir_header INTO ls_header INDEX 1.
            IF sy-subrc = 0 .
              ls_data-header_type = ls_header-low.
            ENDIF.

            READ TABLE ir_print_multi INTO ls_print_multi INDEX 1.
            IF sy-subrc = 0 .
              ls_data-print_multi = ls_print_multi-low.
            ENDIF.

            READ TABLE ir_keeper INTO ls_ke INDEX 1.
            IF sy-subrc = 0 .
              ls_data-keeper = ls_ke-low.
            ENDIF.

            ls_data-Document = ls_matnr_doc-MaterialDocument.
            ls_data-Document_Item = ls_matnr_doc-MaterialDocumentItem.
            ls_data-matnr_number = ls_matnr_doc-Material.

            SELECT SINGLE MaterialDescription
             FROM  c_bommaterialvh
             WHERE Material = @ls_matnr_doc-Material
             INTO @ls_Material_description.
            ls_data-Material_description = ls_Material_description.
            ls_data-plant = ls_matnr_doc-Plant.
            ls_data-Sale_Order = ls_matnr_doc-SpecialStockIdfgSalesOrder.
            ls_data-Sale_Order_item = ls_matnr_doc-SpecialStockIdfgSalesOrderItem.
            ls_data-Storage_Location = ls_matnr_doc-StorageLocation.
            ls_data-Quantity = ls_matnr_doc-QuantityInEntryUnit.
            ls_data-Unit = ls_matnr_doc-EntryUnit.
            ls_data-batch = ls_matnr_doc-Batch.
*            ls_data-Sale_Order = ls_matnr_doc-SalesOrder.
*            ls_data-Sale_Order_item = ls_matnr_doc-SalesOrderItem.
            ls_data-Posting_Date = ls_matnr_doc-PostingDate.
            ls_data-ValuationType = ls_matnr_doc-InventoryValuationType.
            ls_data-option_name = ls_option-low.
            APPEND ls_data TO e_barcore .
            CLEAR ls_data.
          ENDLOOP.
        WHEN '4'.

          "select TH Material
*          SELECT Material,Batch,plant
*          FROM i_batch
*          WHERE Plant IN @ir_plant
*          AND Material IN @ir_matnr_number
**           AND Material IN @ir_matnr_number
*          INTO TABLE @DATA(lt_matnr).

          SELECT Product,plant,BaseUnit
                    FROM i_productplantbasic
                    WHERE Plant IN @ir_plant
                    AND Product IN @ir_matnr_number
*           AND Material IN @ir_matnr_number
                    INTO TABLE @DATA(lt_matnr).

          LOOP AT lt_matnr INTO DATA(ls_matnr).
            ls_data-lineindex = sy-tabix.

            READ TABLE ir_qc INTO ls_qc INDEX 1.
            IF sy-subrc = 0 .
              ls_data-qc = ls_qc-low.
            ENDIF.

            READ TABLE ir_header INTO ls_header INDEX 1.
            IF sy-subrc = 0 .
              ls_data-header_type = ls_header-low.
            ENDIF.

            READ TABLE ir_print_multi INTO ls_print_multi INDEX 1.
            IF sy-subrc = 0 .
              ls_data-print_multi = ls_print_multi-low.
            ENDIF.

            READ TABLE ir_keeper INTO ls_ke INDEX 1.
            IF sy-subrc = 0 .
              ls_data-keeper = ls_ke-low.
            ENDIF.
            ls_data-matnr_number = ls_matnr-Product.

            SELECT SINGLE MaterialDescription
            FROM c_bommaterialvh
            WHERE Material = @ls_matnr-Product
             INTO @ls_Material_description.

            ls_data-Material_description = ls_Material_description.

            SELECT SINGLE ValuationType
            FROM i_productvaluationbasic
            WHERE Product = @ls_matnr-Product
*            AND Plant IN @ir_plant
            INTO @DATA(ls_ValuationType).

            ls_data-ValuationType = ls_valuationtype.
            ls_data-plant = ls_matnr-Plant.
            ls_data-Unit = ls_matnr-BaseUnit.

            SELECT SINGLE Batch
          FROM i_batch
          WHERE Plant = @ls_matnr-Plant
          AND Material = @ls_matnr-Product
*           AND Material IN @ir_matnr_number
          INTO @DATA(ls_batch).

            ls_data-batch = ls_batch.
            ls_data-option_name = ls_option-low.
            APPEND ls_data TO e_barcore .
            CLEAR ls_data.
          ENDLOOP.

        WHEN '5'.
          READ TABLE ir_quantity INTO DATA(ls_qty) INDEX 1.
          READ TABLE ir_vas INTO DATA(ls_vas) INDEX 1.
          READ TABLE ir_vas INTO DATA(ls_vas_1) INDEX 1.

          IF ls_vas_1-low IS INITIAL.
            "select TH Material Stock
            SELECT *
            FROM i_stockquantitycurrentvalue_2(
            p_displaycurrency = 'VND' )
            WHERE Plant IN @ir_plant
            AND Batch IN @ir_batch
            AND Product IN @ir_matnr_number
            AND StorageLocation IN @ir_sloc
            AND SDDocument IN @ir_so
            AND SDDocumentItem IN @ir_soi
            AND ValuationAreaType = '1'
*          AND MatlWrhsStkQtyInMatlBaseUnit = @ls_qty-low
            AND MatlWrhsStkQtyInMatlBaseUnit > 0
            INTO TABLE @DATA(lt_matnr_stock).

          ELSE.

            SELECT *
              FROM i_stockquantitycurrentvalue_2(
              p_displaycurrency = 'VND' )
              WHERE Plant IN @ir_plant
*              AND Batch IN @ir_batch
              AND Product IN @ir_matnr_number
              AND StorageLocation IN @ir_sloc
              AND SDDocument IN @ir_so
              AND SDDocumentItem IN @ir_soi
              AND supplier IN @ir_supplier
              AND batch IN @ir_vas
              AND ValuationAreaType = '1'
*              AND MatlWrhsStkQtyInMatlBaseUnit = @ls_qty-low
              AND MatlWrhsStkQtyInMatlBaseUnit > 0
              INTO TABLE @lt_matnr_stock.
          ENDIF.

          LOOP AT lt_matnr_stock INTO DATA(ls_matnr_stock).
            ls_data-lineindex = sy-tabix.

            READ TABLE ir_qc INTO ls_qc INDEX 1.
            IF sy-subrc = 0 .
              ls_data-qc = ls_qc-low.
            ENDIF.

            READ TABLE ir_header INTO ls_header INDEX 1.
            IF sy-subrc = 0 .
              ls_data-header_type = ls_header-low.
            ENDIF.

            READ TABLE ir_print_multi INTO ls_print_multi INDEX 1.
            IF sy-subrc = 0 .
              ls_data-print_multi = ls_print_multi-low.
            ENDIF.

            READ TABLE ir_keeper INTO ls_ke INDEX 1.
            IF sy-subrc = 0 .
              ls_data-keeper = ls_ke-low.
            ENDIF.

            ls_data-matnr_number = ls_matnr_stock-Product.

            SELECT SINGLE MaterialDescription
            FROM c_bommaterialvh
            WHERE Material = @ls_matnr_stock-Product
             INTO @ls_Material_description.

            IF ls_matnr_stock-Batch = 'ND'
            OR ls_matnr_stock-Batch = 'NK'.
              ls_data-ValuationType = ls_matnr_stock-Batch.
            ELSE.
              SELECT SINGLE inventoryvaluationtype
                FROM I_Batch
                WHERE material = @ls_matnr_stock-Product
                  AND Batch   = @ls_matnr_stock-Batch
                  AND plant = @ls_matnr_stock-plant
                INTO @ls_data-ValuationType.
            ENDIF.
            ls_data-Material_description = ls_Material_description.
            ls_data-plant = ls_matnr_stock-Plant.
            ls_data-Storage_Location = ls_matnr_stock-StorageLocation.
            ls_data-Quantity = ls_matnr_stock-MatlWrhsStkQtyInMatlBaseUnit.
            ls_data-Unit = ls_matnr_stock-MaterialBaseUnit.
            IF ls_matnr_stock-Batch = 'ND'
            OR ls_matnr_stock-Batch = 'NK'.
              ls_data-batch = ''.
            ELSE.
              ls_data-batch = ls_matnr_stock-Batch.
            ENDIF.
            ls_data-Sale_Order = ls_matnr_stock-SDDocument.
            ls_data-Sale_Order_item = ls_matnr_stock-SDDocumentItem.
            ls_data-option_name = ls_option-low.
            ls_data-Supplier = ls_matnr_stock-Supplier.
*            ls_data-ValuationType  = ls_matnr_stock-WBSElementInternalID.
            ls_data-customer = ls_matnr_stock-Customer.
            ls_data-StockOwner =  ls_matnr_stock-SpecialStockIdfgStockOwner.
            ls_data-StockType = ls_matnr_stock-InventoryStockType.
            ls_data-currencCy = ls_matnr_stock-StockValueInCCCrcy.
            ls_data-vas = ls_matnr_stock-Batch.
*            ls_Data-ValuationType = ls_matnr_stock-ValuationAreaType.
            APPEND ls_data TO lt_data .
            CLEAR ls_data.
          ENDLOOP.

*          IF ir_lineindex IS NOT INITIAL.
*            DATA:
*              lt_e_barcore_temp_5 TYPE tt_barcore,
*              ls_e_barcore_temp_5 TYPE LINE OF tt_barcore.
*
*READ TABLE ir_supplier INTO ls_header INDEX 1.
*
*            SORT lt_data BY Supplier vas Storage_Location batch.
*
*              READ TABLE lt_data INTO ls_e_barcore_temp_5 WITH KEY Supplier = ir_supplier.
*              IF sy-subrc = 0.
*                APPEND ls_e_barcore_temp TO lt_e_barcore_temp.
*              ENDIF.
*
*            FREE: lt_data.
**            e_barcore = CORRESPONDING #( lt_e_barcore_temp ).
*            APPEND LINES OF lt_e_barcore_temp TO e_barcore.
*          ELSE.
          APPEND LINES OF lt_data TO e_barcore.

*          ENDIF.


      ENDCASE.
    ENDLOOP.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.

*    DATA: lt_result  TYPE TABLE OF zc_barcode,
*          lt_barcore TYPE TABLE OF zc_barcode,
*          lt_returns TYPE tt_returns.

    DATA: ir_plant           TYPE tt_ranges,
          ir_delivery        TYPE tt_ranges,
          ir_productionorder TYPE tt_ranges,
          ir_document        TYPE tt_ranges,
          ir_document_item   TYPE tt_ranges,
          ir_matnr_document  TYPE tt_ranges,
          ir_option          TYPE tt_ranges,
          ir_qc              TYPE tt_ranges,
          ir_keeper          TYPE tt_ranges,
          ir_batch           TYPE tt_ranges,
          ir_header          TYPE tt_ranges,
          ir_sloc            TYPE tt_ranges,
          ir_print_multi     TYPE tt_ranges,
          ir_matnr_number    TYPE tt_ranges.

*    DATA:lv_option TYPE string.
    "--- Get filters ---
    DATA(lo_filter) = io_request->get_filter( ).


    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        CLEAR lt_filters.
    ENDTRY.

    LOOP AT lt_filters INTO DATA(ls_filters).
      CASE ls_filters-name.
        WHEN 'PLANT'.
          MOVE-CORRESPONDING ls_filters-range TO ir_plant.


        WHEN 'OPTION_NAME'.
          MOVE-CORRESPONDING ls_filters-range TO ir_option.

        WHEN 'DELIVERY'.
          MOVE-CORRESPONDING ls_filters-range TO ir_delivery.

        WHEN 'BATCH'.
          MOVE-CORRESPONDING ls_filters-range TO ir_batch.


        WHEN 'PRODUCTION_ORDER'.
          MOVE-CORRESPONDING ls_filters-range TO ir_productionorder.


        WHEN 'MATNR_DOCUMENT'.
          MOVE-CORRESPONDING ls_filters-range TO ir_matnr_document.


        WHEN 'MATNR_NUMBER'.
          MOVE-CORRESPONDING ls_filters-range TO ir_matnr_number.

        WHEN 'STORAGE_LOCATION'.
          MOVE-CORRESPONDING ls_filters-range TO ir_sloc.

        WHEN 'QC'.
          MOVE-CORRESPONDING ls_filters-range TO ir_qc.

        WHEN 'HEADER_TYPE'.
          MOVE-CORRESPONDING ls_filters-range TO ir_header.

        WHEN 'PRINT_MULTI'.
          MOVE-CORRESPONDING ls_filters-range TO ir_print_multi.

        WHEN 'KEEPER'.
          MOVE-CORRESPONDING ls_filters-range TO ir_keeper.


      ENDCASE.
    ENDLOOP.

    "--- Build data ---
    zcl_barcode=>get_inbound_delivery(
      EXPORTING
        ir_plant            = ir_plant
        ir_delivery         = ir_delivery
        ir_production_Order = ir_productionorder
        ir_document =   ir_document
        ir_document_item = ir_document_item
        ir_matnr_document   = ir_matnr_document
        ir_matnr_number     = ir_matnr_number
        ir_sloc = ir_sloc
        ir_option = ir_option
        ir_batch = ir_batch
        ir_qc = ir_qc
        ir_header = ir_header
        ir_print_multi = ir_print_multi
        ir_keeper = ir_keeper
      IMPORTING
        e_barcore           = lt_barcore
*        e_return            = lt_returns
    ).

    "--- Apply sorting ---
    DATA(sort_order) = VALUE abap_sortorder_tab(
      FOR sort_element IN io_request->get_sort_elements( )
      ( name = sort_element-element_name
        descending = sort_element-descending ) ).

    IF sort_order IS NOT INITIAL.
      SORT lt_barcore BY (sort_order).
    ENDIF.

    "--- Apply paging ---
    DATA(lv_total_records) = lines( lt_barcore ).

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_barcore ) ).
    ENDIF.


    DATA(lo_paging) = io_request->get_paging( ).
    IF lo_paging IS BOUND.
      DATA(top) = lo_paging->get_page_size( ).
      IF top < 0. " -1 = lấy hết
        top = lv_total_records.
      ENDIF.
      DATA(skip) = lo_paging->get_offset( ).

      IF skip >= lv_total_records.
        CLEAR lt_barcore.
      ELSEIF top = 0.
        CLEAR lt_barcore.
      ELSE.
        DATA(lv_start_index) = skip + 1.
        DATA(lv_end_index)   = skip + top.

        IF lv_end_index > lv_total_records.
          lv_end_index = lv_total_records.
        ENDIF.

        DATA: lt_paged_result LIKE lt_barcore.
        CLEAR lt_paged_result.

        DATA(lv_index) = lv_start_index.
        WHILE lv_index <= lv_end_index.
          APPEND lt_barcore[ lv_index ] TO lt_paged_result.
          lv_index = lv_index + 1.
*          IF lv_index > 1.
*            EXIT.
*          ENDIF.
        ENDWHILE.

*        lt_barcore = lt_paged_result.
      ENDIF.
    ENDIF.

    IF io_request->is_data_requested( ).
      io_response->set_data( lt_paged_result ).
    ENDIF.


  ENDMETHOD.
ENDCLASS.

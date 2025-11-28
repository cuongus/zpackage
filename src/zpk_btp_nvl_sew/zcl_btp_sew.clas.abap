CLASS zcl_btp_sew DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_btp_sew IMPLEMENTATION.
  METHOD if_rap_query_provider~select.

    DATA: lt_data   TYPE TABLE OF  zc_btp_sew,
          lt_result TYPE TABLE OF zc_btp_sew,
          ls_data   TYPE zc_btp_sew.


    DATA: lv_sale_order      TYPE RANGE OF i_salesorderitem-SalesOrder,
          lv_sale_order_item TYPE RANGE OF i_salesorderitem-SalesOrderItem,
          lv_matnr           TYPE RANGE OF i_salesorderitem-Product,
*          lv_matnr_1        TYPE RANGE OF  ztb_inven_im1-material,
          lv_status          TYPE RANGE OF i_salesorderitem-sdprocessstatus.
*          lv_api_status     TYPE RANGE OF zc_inventory_data_im-ApiStatus,
*          lv_convert_sap_no TYPE RANGE OF zc_inventory_data_im-ConvertSapNo,
*          lv_pid_item       TYPE RANGE OF i_physinvtrydocitem-PhysicalInventoryDocumentItem.

    DATA(lo_filter) = io_request->get_filter( ).

    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_range).
        " Handle error
    ENDTRY.

    LOOP AT lt_filters INTO DATA(ls_filters).
      CASE ls_filters-name.
        WHEN 'SALESORDER'.
          MOVE-CORRESPONDING ls_filters-range TO lv_sale_order .
        WHEN 'SALESORDERITEM'.
          MOVE-CORRESPONDING ls_filters-range TO lv_sale_order_item.
        WHEN 'MATERIAL'.
          MOVE-CORRESPONDING ls_filters-range TO lv_matnr.
        WHEN 'STATUS'.
          MOVE-CORRESPONDING ls_filters-range TO lv_status.
      ENDCASE.
    ENDLOOP.

    TYPES: BEGIN OF ty_component,
             Material                TYPE i_productionordercomponent-material,
             RequiredQuantity        TYPE i_productionordercomponent-requiredquantity,
             WithdrawnQuantity       TYPE i_productionordercomponent-withdrawnquantity,
             billofmaterialcomponent TYPE i_slsordbillofmaterialitemtp_2-billofmaterialcomponent,
             componentdescription    TYPE  i_slsordbillofmaterialitemtp_2-componentdescription,

           END OF ty_component.

    TYPES: ty_component_table TYPE STANDARD TABLE OF ty_component
           WITH DEFAULT KEY.

    TYPES: ty_prod_component_table TYPE STANDARD TABLE OF ty_component
           WITH DEFAULT KEY.

    TYPES: ty_posub_table TYPE STANDARD TABLE OF ty_component
           WITH DEFAULT KEY.


    SELECT
        SalesOrder,SalesOrderItem,Material,salesorderitemtext,orderquantity,sdprocessstatus,plant,StorageLocation
     FROM i_salesorderitem
      WHERE  SalesOrder IN @lv_sale_order
      AND SalesOrderItem IN @lv_sale_order_item
      AND Product IN @lv_matnr
      AND SDProcessStatus IN @lv_status
        INTO TABLE @DATA(gt_data).

    SORT gt_data BY SalesOrder SalesOrderItem.

    DATA: lv_date         TYPE d,
          lv_week         TYPE i,
          lv_year         TYPE i,
          lv_thu4         TYPE d,
          lv_week1_monday TYPE d,
          lv_diff         TYPE i,
          lv_d            TYPE i,
          lv_m            TYPE i,
          lv_y            TYPE i,
          lv_k            TYPE i,
          lv_j            TYPE i,
          lv_w            TYPE i,
          lv_dow          TYPE i,
          lv_stt          TYPE i VALUE 0.

    LOOP AT gt_data INTO DATA(gs_data).

*          ls_data-SalesOrder = gs_data-SalesOrder.
*          ls_data-SalesOrderItem = gs_data-SalesOrderItem.
*          ls_data-Material = gs_data-Material.
*          ls_data-MaterialName = gs_data-salesorderitemtext.
*          ls_data-Quantity = gs_data-orderquantity.
*          ls_data-Status = gs_data-sdprocessstatus.
*          ls_data-Plant = gs_data-Plant.

      SELECT billofmaterialcomponent,componentdescription
      FROM  i_slsordbillofmaterialitemtp_2
        WHERE SalesOrder = @gs_data-SalesOrder
          AND SalesOrderItem = @gs_data-SalesOrderItem
          AND Material = @gs_data-Material
          AND  isassembly = 'X'
          INTO TABLE @DATA(lt_matnr_btp).


      IF lt_matnr_btp IS NOT INITIAL .
        LOOP AT lt_matnr_btp INTO DATA(lw_matnr_btp).
*          ls_data-SalesOrder = gs_data-SalesOrder.
*          ls_data-SalesOrderItem = gs_data-SalesOrderItem.
*          ls_data-Material = gs_data-Material.
*          ls_data-MaterialName = gs_data-salesorderitemtext.
*          ls_data-Quantity = gs_data-orderquantity.
*          ls_data-Status = gs_data-sdprocessstatus.
*          ls_data-Plant = gs_data-Plant.
*          ls_data-MaterialBtp = lw_matnr_btp-BillOfMaterialComponent.
*          ls_data-MaterialBtpName = lw_matnr_btp-ComponentDescription.


          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).


          ls_data-Uuid = lv_uuid.
          SELECT SINGLE plannedorder
            FROM i_plannedorder
            WHERE SalesOrder      = @gs_data-SalesOrder
              AND SalesOrderItem  = @gs_data-SalesOrderItem
              AND Material        = @lw_matnr_btp-billofmaterialcomponent
            INTO @DATA(lv_planned_order).

          IF lv_planned_order IS NOT INITIAL.
            SELECT material, requiredquantity
              FROM i_plannedordercomponent
              WHERE PlannedOrder = @lv_planned_order
              INTO TABLE @DATA(lt_planned_components).

            DELETE ADJACENT DUPLICATES FROM lt_planned_components
              COMPARING material.
          ELSE.
            lt_planned_components = VALUE ty_component_table( ).
          ENDIF.

          SELECT SINGLE productionorder
            FROM i_productionorder
            WHERE SalesOrder            = @gs_data-SalesOrder
              AND SalesOrderItem        = @gs_data-SalesOrderItem
              AND BillOfOperationsMaterial = @lw_matnr_btp-billofmaterialcomponent
            INTO @DATA(lv_prod_order).

          IF lv_prod_order IS NOT INITIAL.
            SELECT material, requiredquantity, withdrawnquantity
              FROM i_productionordercomponent
              WHERE ProductionOrder = @lv_prod_order
              INTO TABLE @DATA(lt_prod_components).
          ELSE.
            lt_prod_components = VALUE ty_prod_component_table( ).
          ENDIF.


          SELECT SINGLE purchaseorder, purchaseorderitem
            FROM i_purordaccountassignmentapi01
            WHERE orderid          = @lv_prod_order
              AND purchaseorder    = @gs_data-SalesOrder
              AND purchaseorderitem = @gs_data-SalesOrderItem
            INTO @DATA(ls_po_account).

          IF ls_po_account IS NOT INITIAL.
            SELECT material, requiredquantity, withdrawnquantity
              FROM i_posubcontractingcompapi01
              WHERE material          = @lw_matnr_btp-billofmaterialcomponent
                AND purchaseorder     = @ls_po_account-purchaseorder
                AND purchaseorderitem = @ls_po_account-purchaseorderitem
              INTO TABLE @DATA(lt_posub_components).
          ELSE.
            lt_posub_components = VALUE ty_posub_table( ).
          ENDIF.

          DATA(lt_all_components) = VALUE ty_component_table( ).

          LOOP AT lt_planned_components INTO DATA(ls_pl_orig).
            DATA(ls_pl) = VALUE ty_component(
              Material                = ls_pl_orig-Material
              RequiredQuantity        = ls_pl_orig-RequiredQuantity
*              WithdrawnQuantity       = ls_pl_orig-
              billofmaterialcomponent = lw_matnr_btp-BillOfMaterialComponent
              componentdescription    = lw_matnr_btp-ComponentDescription
            ).
            APPEND ls_pl TO lt_all_components.

          ENDLOOP.

          LOOP AT lt_prod_components INTO DATA(ls_pr_orig).
            DATA(ls_pr) = VALUE ty_component(
              Material                = ls_pr_orig-Material
              RequiredQuantity        = ls_pr_orig-RequiredQuantity
              WithdrawnQuantity       = ls_pr_orig-WithdrawnQuantity
              billofmaterialcomponent = lw_matnr_btp-BillOfMaterialComponent
              componentdescription    = lw_matnr_btp-ComponentDescription
            ).
            APPEND ls_pr TO lt_all_components.
          ENDLOOP.

          LOOP AT lt_posub_components INTO DATA(ls_ps_orig).
            DATA(ls_ps) = VALUE ty_component(
              Material                = ls_ps_orig-Material
              RequiredQuantity        = ls_ps_orig-RequiredQuantity
              WithdrawnQuantity       = ls_ps_orig-WithdrawnQuantity
              billofmaterialcomponent = lw_matnr_btp-BillOfMaterialComponent
              componentdescription    = lw_matnr_btp-ComponentDescription
            ).
            APPEND ls_ps TO lt_all_components.
          ENDLOOP.

          SORT lt_all_components BY material.
          DELETE ADJACENT DUPLICATES FROM lt_all_components COMPARING material.

          LOOP AT lt_all_components INTO DATA(ls_comp).
            ls_data-SalesOrder = gs_data-SalesOrder.
            ls_data-SalesOrderItem = gs_data-SalesOrderItem.
            ls_data-Material = gs_data-Material.
            ls_data-MaterialName = gs_data-salesorderitemtext.
            ls_data-Quantity = gs_data-orderquantity.
            ls_data-Status = gs_data-sdprocessstatus.
            ls_data-Plant = gs_data-Plant.
            ls_data-MaterialBtp = ls_comp-BillOfMaterialComponent.
            ls_data-MaterialBtpName = ls_comp-ComponentDescription.

            ls_data-Component = ls_comp-Material.


            SELECT SINGLE producttype
           FROM i_product
           WHERE Product = @ls_comp-Material
           INTO @DATA(lv_productype).
            ls_data-MaterialType = lv_productype.

            SELECT SINGLE bomheaderquantityinbaseunit
              FROM i_salesorderbillofmaterialtp_2
              WHERE SalesOrder     = @gs_data-SalesOrder
                AND SalesOrderItem = @gs_data-SalesOrderItem
                AND Material       = @ls_comp-billofmaterialcomponent
              INTO @DATA(lv_base).

            SELECT SINGLE billofmaterialitemquantity, billofmaterialitemunit
              FROM i_slsordbillofmaterialitemtp_2
              WHERE SalesOrder              = @gs_data-SalesOrder
                AND SalesOrderItem          = @gs_data-SalesOrderItem
                AND Material                = @ls_comp-billofmaterialcomponent
                AND billofmaterialcomponent = @ls_comp-Material
              INTO @DATA(lv_item).

            ls_data-BomQty = lv_item-BillOfMaterialItemQuantity / lv_base * gs_data-OrderQuantity.

            IF lv_item-BillOfMaterialItemUnit IS NOT INITIAL.
              ls_data-Uom = lv_item-BillOfMaterialItemUnit.
            ELSE.
              SELECT SINGLE baseunit
                FROM i_product
                WHERE Product = @ls_comp-billofmaterialcomponent
                INTO @DATA(lv_unit).
              ls_data-Uom = lv_unit.
            ENDIF.

            DATA(lv_salesorder_nozero) =
                |{ gs_data-SalesOrder ALPHA = OUT }|.

            SELECT SINGLE purchaseorder, purchaseorderitem
           FROM i_purchaseorderitemapi01
           WHERE RequirementTracking = @lv_salesorder_nozero
       AND Material = @ls_comp-Material
       INTO @DATA(lw_PURCHASEORDER).

            SELECT SINGLE purchasinghistorydocument,purchasinghistorydocumentitem,purchasinghistorydocumentyear
            FROM i_purchaseorderhistoryapi01
            WHERE PurchaseOrder = @lw_PURCHASEORDER-PurchaseOrder
            AND PurchaseOrderItem = @lw_purchaseorder-PurchaseOrderItem
            INTO @DATA(lw_purchaseorder01).

            SELECT SINGLE productionorder
          FROM i_productionorder
          WHERE SalesOrder            = @gs_data-SalesOrder
            AND SalesOrderItem        = @gs_data-SalesOrderItem
            AND BillOfOperationsMaterial = @ls_comp-Material
          INTO @lv_prod_order.

            DATA: BEGIN OF lw_quantity_unit,
                    quantityinbaseunit TYPE i_materialdocumentitem_2-quantityinbaseunit,
                    debitcreditcode    TYPE i_materialdocumentitem_2-debitcreditcode,
                  END OF lw_quantity_unit.


            IF ls_data-MaterialType = 'ZNVL'.
              SELECT SINGLE quantityinbaseunit,debitcreditcode
              FROM i_materialdocumentitem_2
              WHERE MaterialDocument = @lw_purchaseorder01-PurchasingHistoryDocument
              AND MaterialDocumentItem = @lw_purchaseorder01-PurchasingHistoryDocumentItem
              AND MaterialDocumentYear = @lw_purchaseorder01-PurchasingHistoryDocumentYear
              INTO @lw_quantity_unit.

              IF lw_quantity_unit-DebitCreditCode = 'H'.
                ls_data-QtyReceived = lw_quantity_unit-QuantityInBaseUnit * -1.
              ELSEIF lw_quantity_unit-DebitCreditCode = 'S'.
                ls_data-QtyReceived = lw_quantity_unit-QuantityInBaseUnit.
              ENDIF.

            ELSEIF ls_data-MaterialType <> 'ZNVL'.

              IF lv_prod_order IS NOT INITIAL .
                SELECT SINGLE quantityinbaseunit,debitcreditcode
                        FROM i_materialdocumentitem_2
                        WHERE OrderID = @lv_prod_order
                        AND GoodsMovementType IN ( '101', '102' )
                        INTO @lw_quantity_unit.
              ENDIF.

              IF lw_quantity_unit-DebitCreditCode = 'H'.
                ls_data-QtyReceived = lw_quantity_unit-QuantityInBaseUnit  * -1.
              ELSEIF lw_quantity_unit-DebitCreditCode = 'S'.
                ls_data-QtyReceived = lw_quantity_unit-QuantityInBaseUnit.
              ENDIF.
            ENDIF.


            DATA:lv_REQUIREDQUANTITY_1  TYPE i_plannedordercomponent-requiredquantity,
                 lv_withdrawnquantity_2 TYPE string,
                 lv_withdrawnquantity_3 TYPE string.

            "nhu cầu NVL

            DATA: lv_need_plndorder TYPE string,
                  lv_need_prodorder TYPE string,
                  lv_need_subcon    TYPE string,
                  lv_total_need     TYPE string.

            " 1. NHU CẦU ĐỊNH MỨC PLANNED ORDER
            SELECT plannedorder
              FROM i_plannedorder
              WHERE salesorder     = @gs_data-SalesOrder
                AND salesorderitem = @gs_data-SalesOrderItem
                AND material       = @lw_matnr_btp-billofmaterialcomponent
              INTO TABLE @DATA(lt_plannedorder).

            IF lt_plannedorder IS NOT INITIAL.
              SELECT requiredquantity
                FROM i_plannedordercomponent
                FOR ALL ENTRIES IN @lt_plannedorder
                WHERE plannedorder = @lt_plannedorder-PlannedOrder
                  AND material     = @lw_matnr_btp-billofmaterialcomponent
                  AND matlcompismarkedfordeletion = ''
               INTO TABLE @DATA(lt_plan_comp).

              LOOP AT lt_plan_comp INTO DATA(ls_plan_comp).
                lv_need_plndorder += ls_plan_comp-requiredquantity.
              ENDLOOP.

            ENDIF.

            " 2. NHU CẦU CÒN LẠI PRODUCTION ORDER
            SELECT productionorder
              FROM i_productionorder
              WHERE salesorder     = @gs_data-SalesOrder
                AND salesorderitem = @gs_data-SalesOrderItem
                   AND BillOfOperationsMaterial = @ls_comp-billofmaterialcomponent
              INTO TABLE @DATA(lt_prodorder).

            IF lt_prodorder IS NOT INITIAL.
              SELECT requiredquantity,
                     withdrawnquantity
                FROM i_productionordercomponent
                FOR ALL ENTRIES IN @lt_prodorder
                WHERE productionorder = @lt_prodorder-productionorder
                  AND matlcompismarkedfordeletion = ''
                  AND reservationisfinallyissued  = ''
                INTO TABLE @DATA(lt_prod_comp).

              LOOP AT lt_prod_comp INTO DATA(ls_prod_comp).
                lv_need_prodorder += ls_prod_comp-requiredquantity - ls_prod_comp-withdrawnquantity.
              ENDLOOP.

            ENDIF.

            " 3. NHU CẦU CÒN LẠI PO GIA CÔNG
            IF lt_prodorder IS NOT INITIAL.

              SELECT purchaseorder,
                     purchaseorderitem
                FROM i_purordaccountassignmentapi01
                FOR ALL ENTRIES IN @lt_prodorder
                WHERE orderid = @lt_prodorder-productionorder
                INTO TABLE @DATA(lt_po_link).

              IF lt_po_link IS NOT INITIAL.

                SELECT requiredquantity,
                       withdrawnquantity
                  FROM i_posubcontractingcompapi01
                  FOR ALL ENTRIES IN @lt_po_link
                  WHERE material          = @ls_comp-Material
                    AND purchaseorder     = @lt_po_link-purchaseorder
                    AND purchaseorderitem = @lt_po_link-purchaseorderitem
                  INTO TABLE @DATA(lt_subcon_comp).

                LOOP AT lt_subcon_comp INTO DATA(ls_subcon_comp).
                  lv_need_subcon += ls_subcon_comp-requiredquantity - ls_subcon_comp-withdrawnquantity.
                ENDLOOP.

              ENDIF.

            ENDIF.
            " 4. TỔNG SỐ LƯỢNG CẦN NVL
            ls_data-RequiredQty = lv_need_plndorder
                          + lv_need_prodorder
                          + lv_need_subcon.

            "tồn kho hiện tại
            SELECT SINGLE MatlWrhsStkQtyInMatlBaseUnit
            FROM i_stockquantitycurrentvalue_2( p_displaycurrency = 'VND' )
            WHERE Product = @gs_data-Material
            AND Plant = @gs_data-Plant
            AND StorageLocation = @gs_data-StorageLocation
            AND SDDocument = @gs_data-SalesOrder
            AND ValuationAreaType = '1'
            INTO @DATA(ls_tonkho).

            ls_data-StockCurrent = ls_tonkho.

            "tính tuần
            SELECT SINGLE DeliveryDate
              FROM i_salesorderscheduleline
              WHERE SalesOrder     = @gs_data-SalesOrder
                AND SalesOrderItem = @gs_data-SalesOrderItem
                AND IsConfirmedDelivSchedLine = 'X'
              INTO @lv_date.
            lv_year = lv_date(4).
            lv_thu4 = |{ lv_year }0104|.
            lv_y = lv_thu4(4).
            lv_m = lv_thu4+4(2).
            lv_d = lv_thu4+6(2).
            IF lv_m = 1 OR lv_m = 2.
              lv_m = lv_m + 12.
              lv_y = lv_y - 1.
            ENDIF.
            lv_k = lv_y MOD 100.
            lv_j = lv_y DIV 100.
            lv_w = ( lv_d
               + ( 13 * ( lv_m + 1 ) ) DIV 5
               + lv_k
               + ( lv_k DIV 4 )
               + ( lv_j DIV 4 )
               + 5 * lv_j ) MOD 7.
            IF lv_w = 0.
              lv_dow = 6.
            ELSEIF lv_w = 1.
              lv_dow = 7.
            ELSE.
              lv_dow = lv_w - 1.
            ENDIF.
            lv_week1_monday = lv_thu4 - ( lv_dow - 1 ).

            lv_diff = lv_date - lv_week1_monday.
            IF lv_diff < 0.
              lv_week = 53.
            ELSE.
              lv_week = lv_diff DIV 7 + 1.
            ENDIF.
            ls_data-DeliveryWeek = |{ lv_week }/{ lv_year }|.


            " TH người dùng sửa dữ liệu
            SELECT SINGLE estimated_qty,Estimated_Date,prod_week
            FROM ztb_btl_sew
            WHERE sales_order = @gs_data-SalesOrder
            AND sales_order_item = @gs_data-SalesOrderItem
            AND component = @ls_comp-Material
            INTO @DATA(lw_btl_sew).

            IF lw_btl_sew IS NOT INITIAL.
              ls_data-EstimatedQty = lw_btl_sew-estimated_qty.
              ls_data-ProdWeek = lw_btl_sew-prod_week.
              ls_data-EstimatedDate = lw_btl_sew-estimated_date.
            ELSE.
              ls_data-EstimatedQty = ''.
              ls_data-ProdWeek = ''.
              ls_data-EstimatedDate = ''.
            ENDIF.

            lv_stt = lv_stt + 1.
            ls_data-stt = lv_stt.
            APPEND ls_data TO lt_data.
            CLEAR: lv_date,lv_need_subcon, lv_need_prodorder , lv_need_plndorder ,ls_tonkho,
            lw_matnr_btp,lv_prod_order,ls_data,lv_unit,lw_quantity_unit,lv_base,lw_btl_sew,
            lv_planned_order,lv_item,ls_po_account,ls_comp,lw_PURCHASEORDER,lw_purchaseorder01,lv_productype.
          ENDLOOP.

        ENDLOOP.
      ELSE.
        ls_data-SalesOrder = gs_data-SalesOrder.
        ls_data-SalesOrderItem = gs_data-SalesOrderItem.
        ls_data-Material = gs_data-Material.
        ls_data-MaterialName = gs_data-salesorderitemtext.
        ls_data-Quantity = gs_data-orderquantity.
        ls_data-Status = gs_data-sdprocessstatus.
        ls_data-Plant = gs_data-Plant.

        SELECT SINGLE DeliveryDate
             FROM i_salesorderscheduleline
             WHERE SalesOrder     = @gs_data-SalesOrder
               AND SalesOrderItem = @gs_data-SalesOrderItem
             INTO @lv_date.

        lv_year = lv_date(4).
        lv_thu4 = |{ lv_year }0104|.

        lv_y = lv_thu4(4).
        lv_m = lv_thu4+4(2).
        lv_d = lv_thu4+6(2).

        IF lv_m = 1 OR lv_m = 2.
          lv_m = lv_m + 12.
          lv_y = lv_y - 1.
        ENDIF.

        lv_k = lv_y MOD 100.
        lv_j = lv_y DIV 100.

        lv_w = ( lv_d
           + ( 13 * ( lv_m + 1 ) ) DIV 5
           + lv_k
           + ( lv_k DIV 4 )
           + ( lv_j DIV 4 )
           + 5 * lv_j ) MOD 7.

        IF lv_w = 0.
          lv_dow = 6.
        ELSEIF lv_w = 1.
          lv_dow = 7.
        ELSE.
          lv_dow = lv_w - 1.
        ENDIF.
        lv_week1_monday = lv_thu4 - ( lv_dow - 1 ).


        lv_diff = lv_date - lv_week1_monday.

        IF lv_diff < 0.
          lv_week = 53.
        ELSE.
          lv_week = lv_diff DIV 7 + 1.
        ENDIF.

        ls_data-DeliveryWeek = |{ lv_week }/{ lv_year }|.

        lv_stt = lv_stt + 1.
        ls_data-stt = lv_stt.
        APPEND ls_data TO lt_data.
        CLEAR: lv_date,lv_base,lw_matnr_btp,lw_btl_sew,lv_prod_order,lv_planned_order,lv_item,ls_po_account,ls_comp,lw_PURCHASEORDER,lw_purchaseorder01,lv_productype.
      ENDIF.
    ENDLOOP.

    SELECT SalesOrder
  FROM i_salesorderpartner
  WHERE Customer IN ('0000006710','0000006720')
  INTO TABLE @DATA(lt_block_so).


    "--- Nếu có SO bị chặn thì xóa toàn bộ dòng lt_data có SO đó ---
    IF lt_block_so IS NOT INITIAL.
      LOOP AT lt_block_so INTO DATA(lv_so).
        DELETE lt_data WHERE SalesOrder = lv_so.
      ENDLOOP.
    ENDIF.



    DATA(sort_order) = VALUE abap_sortorder_tab(
             FOR sort_element IN io_request->get_sort_elements( )
             ( name = sort_element-element_name
               descending = sort_element-descending ) ).

    IF sort_order IS NOT INITIAL.
      SORT lt_data BY (sort_order).
    ENDIF.

    "--- Apply paging ---
    DATA(lv_total_records) = lines( lt_data ).

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.


    DATA(lo_paging) = io_request->get_paging( ).
    IF lo_paging IS BOUND.
      DATA(top) = lo_paging->get_page_size( ).
      IF top < 0. " -1 = lấy hết
        top = lv_total_records.
      ENDIF.
      DATA(skip) = lo_paging->get_offset( ).

      IF skip >= lv_total_records.
        CLEAR lt_data.
      ELSEIF top = 0.
        CLEAR lt_data.
      ELSE.
        DATA(lv_start_index) = skip + 1.
        DATA(lv_end_index)   = skip + top.

        IF lv_end_index > lv_total_records.
          lv_end_index = lv_total_records.
        ENDIF.

        DATA: lt_paged_result LIKE lt_data.
        CLEAR lt_paged_result.

        DATA(lv_index) = lv_start_index.
        WHILE lv_index <= lv_end_index.
          APPEND lt_data[ lv_index ] TO lt_paged_result.
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

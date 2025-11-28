CLASS zcl_bctp_cus_qry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_bctp_cus_qry IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TYPES: BEGIN OF ty_po_ngc,
             SalesOrder     TYPE vbeln,
             SalesOrderItem TYPE  posnr,
             PurchaseOrder  TYPE ebeln,
             Supplier       TYPE lifnr,
           END OF ty_po_ngc.
    DATA(lv_top)     = io_request->get_paging( )->get_page_size( ).
    IF lv_top < 0.
      lv_top = 1.
    ENDIF.

    DATA(lv_skip)    = io_request->get_paging( )->get_offset( ).

    DATA(lt_sort)    = io_request->get_sort_elements( ).

    DATA : lv_orderby TYPE string.
    LOOP AT lt_sort INTO DATA(ls_sort).
      IF ls_sort-descending = abap_true.
        lv_orderby = |'{ lv_orderby } { ls_sort-element_name } DESCENDING '|.
      ELSE.
        lv_orderby = |'{ lv_orderby } { ls_sort-element_name } ASCENDING '|.
      ENDIF.
    ENDLOOP.
    IF lv_orderby IS INITIAL.
      lv_orderby = 'SalesOrder'.
    ENDIF.

    DATA: lv_sale_order      TYPE RANGE OF i_salesorderitem-SalesOrder,
          lv_sale_order_item TYPE RANGE OF i_salesorderitem-SalesOrderItem.

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
      ENDCASE.
    ENDLOOP.

    DATA(lv_conditions) =  io_request->get_filter( )->get_as_sql_string( ).
    DATA: lt_data TYPE STANDARD TABLE OF zdd_bctp WITH EMPTY KEY.
    DATA: lt_data_n TYPE STANDARD TABLE OF zdd_bctp WITH EMPTY KEY.

    SELECT a~SalesOrder, a~SalesOrderItem, a~SDProcessStatus, a~Product AS Material, p~ProductName AS MaterialName,
           a~orderquantity, pl~Plant AS zPlant, pl~PlantName
    FROM i_salesorderitem AS a
    INNER JOIN I_ProductText AS p
    ON a~Product = p~Product
    AND p~Language = 'E'
    INNER JOIN I_Plant AS pl
    ON a~Plant = pl~Plant
    AND pl~Language = 'E'
    WHERE  a~SalesOrder IN @lv_sale_order
      AND a~SalesOrderItem IN @lv_sale_order_item
      AND NOT EXISTS ( SELECT 1
      FROM i_salesorderitempartner AS ip
      WHERE ip~SalesOrder = a~SalesOrder
      AND ip~SalesOrderItem = a~SalesOrderItem
      AND ( ip~Customer = '0000006710' OR ip~Customer = '0000006720' ) )
*    WHERE (lv_conditions)
    INTO CORRESPONDING FIELDS OF TABLE @lt_data.

*    DATA lt_po_result TYPE STANDARD TABLE OF ty_po_ngc WITH EMPTY KEY.

    IF lt_data IS NOT INITIAL.

      SELECT
          prod~SalesOrder         ,
          prod~SalesOrderItem     ,
*          prod~ProductionOrderType,
          poi~PurchaseOrder,
*          op~ProductionOrder,
*          op~PurchaseRequisition,
*          op~PurchaseRequisitionItem,
          po~Supplier
        FROM I_ProductionOrderItem               AS prod
          INNER JOIN I_ProductionOrderOperation_2 AS op
            ON op~ProductionOrder = prod~ProductionOrder
            AND op~ProductionOrderType IN ('1014','2014')
            AND op~PurchaseRequisition IS NOT INITIAL
            AND op~PurchaseRequisitionItem IS NOT INITIAL
          INNER JOIN i_purchaseorderitemapi01    AS poi
            ON poi~PurchaseRequisition     = op~PurchaseRequisition
           AND poi~PurchaseRequisitionItem = op~PurchaseRequisitionItem
          INNER JOIN I_PurchaseOrderAPI01        AS po
            ON po~PurchaseOrder = poi~PurchaseOrder
        FOR ALL ENTRIES IN @lt_data
        WHERE prod~SalesOrder     = @lt_data-SalesOrder
          AND prod~SalesOrderItem = @lt_data-SalesOrderItem

        INTO TABLE @DATA(lt_po_result).
      SORT lt_po_result BY salesorder salesorderitem.

      IF sy-subrc = 0.
        SELECT BusinessPartner, bplastnamesearchhelp
        FROM  i_businesspartner AS n
        FOR ALL ENTRIES IN @lt_po_result
        WHERE n~BusinessPartner = @lt_po_result-supplier
        INTO TABLE @DATA(lt_bp).
        SORT lt_bp BY BusinessPartner.

        SELECT so_po, bs08, SUM( Ct12 ) AS TongCai, SUM( Ct23 ) AS TongCong, SUM( Ct40 ) AS Loi1, SUM( Ct47 ) AS loi2
        FROM ztb_bb_gc
        INNER JOIN @lt_po_result AS po
        ON so_po = po~purchaseorder
        WHERE bs08 IS INITIAL
        GROUP BY so_po, bs08
        INTO TABLE @DATA(lt_bb_gc).
        SORT lt_bb_gc BY so_po.
      ENDIF.

    ENDIF.
    DATA: lw_check TYPE abap_bool.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      DATA(ls_new) = <lfs_data>.
      LOOP AT lt_po_result INTO DATA(ls_po_result)
           WHERE salesorder     = <lfs_data>-SalesOrder
             AND salesorderitem = <lfs_data>-SalesOrderItem.

        "--- copy 1 dòng mới dựa trên dòng gốc ---"

        lw_check = abap_true.
        ls_new-supplier = ls_po_result-supplier.
        ls_new-purchaseorder = ls_po_result-purchaseorder.
        "Lấy tên BP"
        READ TABLE lt_bp INTO DATA(ls_bp)
             WITH KEY BusinessPartner = ls_new-supplier
             BINARY SEARCH.
        IF sy-subrc = 0.
          ls_new-SupplierName = ls_bp-BPLastNameSearchHelp.
        ENDIF.

        "--- xử lý gc ---"
        CLEAR: ls_new-sl_thu_ve_tong_cai,
               ls_new-tong_cong,
               ls_new-hang_loi_phe,
               ls_new-hang_phe.

        LOOP AT lt_bb_gc INTO DATA(ls_bb_gc)
             WHERE so_po = ls_po_result-purchaseorder.

          IF ls_bb_gc-bs08 IS INITIAL.
            ls_new-sl_thu_ve_tong_cai = ls_bb_gc-tongcai.
            ls_new-tong_cong          = ls_bb_gc-tongcong.
          ENDIF.

          ls_new-hang_phe += ls_bb_gc-loi1 + ls_bb_gc-loi2.

        ENDLOOP.


        APPEND ls_new TO lt_data_n.
      ENDLOOP.
      "--- append vào lt_data_new ---"
      IF lw_check = abap_false.
        APPEND ls_new TO lt_data_n.
      ENDIF.

    ENDLOOP.
    lt_data[] = lt_data_n[].

    SELECT *
    FROM @lt_data AS t
    WHERE (lv_conditions)
    ORDER BY (lv_orderby)
    INTO TABLE @lt_data.
    CLEAR lt_data_n.

    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.

    DATA: lt_paged_data TYPE STANDARD TABLE OF zdd_bctp WITH EMPTY KEY.

    SELECT *
    FROM @lt_data AS a
    ORDER BY (lv_orderby)
    INTO TABLE @lt_paged_data
    UP TO @lv_top ROWS OFFSET @lv_skip.

    SELECT *
    FROM ztb_so_gia_cong AS so_gc
    FOR ALL ENTRIES IN @lt_paged_data
    WHERE salesorder = @lt_paged_data-SalesOrder
    AND salesorderitem = @lt_paged_data-SalesOrderItem
    AND purcharseorder = @lt_paged_data-PurchaseOrder
    INTO TABLE @DATA(lt_so_gc).
    SORT lt_so_gc BY salesorder salesorderitem purcharseorder.

    LOOP AT lt_paged_data ASSIGNING FIELD-SYMBOL(<lfs_page_data>).
      READ TABLE lt_so_gc INTO DATA(ls_so_gc)
        WITH KEY salesorder = <lfs_page_data>-salesorder
              salesorderitem = <lfs_page_data>-salesorderitem
              purcharseorder = <lfs_page_data>-purchaseorder BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_page_data>-sl_btp_tra_ve = ls_so_gc-sl_btp_tra_ve.
        <lfs_page_data>-hang_loi_phe  = ls_so_gc-hang_loi_phe.
        <lfs_page_data>-sl_dong_bo_btp = ls_so_gc-sl_dong_bo_btp.
      ENDIF.
    ENDLOOP.

    IF io_request->is_data_requested( ).
      io_response->set_data( lt_paged_data ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS zcl_xnt_hv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_c_nxt TYPE TABLE OF zc_bc_xnt_hv.
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_ranges TYPE TABLE OF ty_range_option.


    CLASS-METHODS: get_xnt_ps
      IMPORTING
                i_datefr    TYPE zde_date
                i_dateto    TYPE zde_date
                ir_material TYPE tt_ranges OPTIONAL
                ir_plant    TYPE tt_ranges OPTIONAL
                ir_supplier TYPE tt_ranges OPTIONAL
                ir_orderid  TYPE tt_ranges OPTIONAL
                ir_batch    TYPE tt_ranges OPTIONAL
                ir_evaltype TYPE tt_ranges OPTIONAL
      EXPORTING e_nxt       TYPE tt_c_nxt.

    CLASS-METHODS: get_xnt
      IMPORTING
                i_datefr    TYPE zde_date
                i_dateto    TYPE zde_date
                ir_material TYPE tt_ranges OPTIONAL
                ir_plant    TYPE tt_ranges OPTIONAL
                ir_supplier TYPE tt_ranges OPTIONAL
                ir_orderid  TYPE tt_ranges OPTIONAL
                ir_batch    TYPE tt_ranges OPTIONAL
                ir_evaltype TYPE tt_ranges OPTIONAL
      EXPORTING e_nxt       TYPE tt_c_nxt.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_XNT_HV IMPLEMENTATION.


  METHOD get_xnt_ps.
    DATA: ls_nxt TYPE zc_bc_xnt_hv.
    SELECT MaterialDocumentYear, MaterialDocument, MaterialDocumentItem,  OrderID,  PurchaseOrder,
           PurchaseOrderItem, GoodsMovementType,Supplier, mdi~Material,plant,
           InventorySpecialStockType, QuantityInBaseUnit, MaterialBaseUnit, isautomaticallycreated,
           YY1_LNhapTra_MMI, YY1_LenhGiaCong_MMI, Batch, InventoryValuationType
     FROM zc_materialdocumentitem_2 AS mdi
      LEFT JOIN ztb_mat_type ON mdi~material = ztb_mat_type~material AND ztb_mat_type~mattype = '1'
      WHERE PostingDate <= @i_dateto
      AND PostingDate >= @i_datefr
      AND ( InventorySpecialStockType = 'O' or  GoodsMovementType = 'Y21' )
*      AND isautomaticallycreated = 'X'
*      AND reversedmaterialdocumentitem = ''
      AND reversedmaterialdocument = ''
      AND GoodsMovementType IN ('541','542','543','X43')
      AND mdi~Material IN @ir_material
      AND plant IN @ir_plant
      AND Supplier IN @ir_supplier
      AND Batch IN @ir_batch
      AND InventoryValuationType IN @ir_evaltype
      AND ztb_mat_type~material IS NULL
      INTO TABLE @DATA(lt_MATERIALDOCUMENTITEM).
    SORT lt_MATERIALDOCUMENTITEM BY MaterialDocumentYear MaterialDocument MaterialDocumentItem.
    LOOP AT lt_MATERIALDOCUMENTITEM ASSIGNING FIELD-SYMBOL(<ls_MATERIALDOCUMENTITEM>).
      CLEAR ls_nxt.
      IF <ls_MATERIALDOCUMENTITEM>-YY1_LenhGiaCong_MMI IS NOT INITIAL.
        ls_nxt-orderid = <ls_MATERIALDOCUMENTITEM>-YY1_LenhGiaCong_MMI .
      ELSEIF <ls_MATERIALDOCUMENTITEM>-OrderID IS NOT INITIAL.
        ls_nxt-orderid = <ls_MATERIALDOCUMENTITEM>-OrderID .
      ELSEIF <ls_MATERIALDOCUMENTITEM>-PurchaseOrder IS NOT INITIAL." AND <ls_materialdocumentitem>-PurchaseOrderItem IS NOT INITIAL.
        SELECT SINGLE orderid
        FROM i_purordaccountassignmentapi01
        WHERE PurchaseOrder = @<ls_MATERIALDOCUMENTITEM>-PurchaseOrder "AND purchaseOrderItem = @<ls_MATERIALDOCUMENTITEM>-PurchaseOrderItem
        INTO @ls_nxt-orderid.
      ENDIF.
      IF ls_nxt-orderid IS INITIAL OR ls_nxt-orderid NOT IN ir_orderid.
        CONTINUE.
      ENDIF.
      SELECT SINGLE SalesOrder, SalesOrderItem FROM zi_productionorder
       WHERE ProductionOrder = @ls_nxt-orderid AND ProductionOrderType IN ( '1014', '2012' )
       INTO @DATA(ls_productionorder).
      IF sy-subrc IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE e_nxt ASSIGNING FIELD-SYMBOL(<ls_nxt>)
        WITH KEY orderid = ls_nxt-orderid
                   supplier = <ls_MATERIALDOCUMENTITEM>-Supplier
                material = <ls_MATERIALDOCUMENTITEM>-Material
                plant    = <ls_MATERIALDOCUMENTITEM>-plant
                batch    = <ls_MATERIALDOCUMENTITEM>-Batch
                inventoryvaluationtype = <ls_MATERIALDOCUMENTITEM>-InventoryValuationType.
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO e_nxt ASSIGNING <ls_nxt>.
        <ls_nxt>-orderid = ls_nxt-orderid.
        <ls_nxt>-material = <ls_MATERIALDOCUMENTITEM>-Material.
        <ls_nxt>-supplier = <ls_MATERIALDOCUMENTITEM>-Supplier.
        <ls_nxt>-plant = <ls_MATERIALDOCUMENTITEM>-plant.
        <ls_nxt>-MaterialBaseUnit = <ls_MATERIALDOCUMENTITEM>-MaterialBaseUnit.
        <ls_nxt>-Batch = <ls_MATERIALDOCUMENTITEM>-Batch.
        <ls_nxt>-InventoryValuationType = <ls_MATERIALDOCUMENTITEM>-InventoryValuationType.
        IF ls_productionorder-SalesOrder IS NOT INITIAL.
          <ls_nxt>-SalesOrder = ls_productionorder-SalesOrder && '/' && ls_productionorder-SalesOrderItem.
        ENDIF.

        SELECT SINGLE OrderIsTechnicallyCompleted
            FROM I_MfgOrderWithStatus
            WHERE  manufacturingorder = @ls_nxt-orderid
            INTO @DATA(lv_OrderIsTechnicallyCompleted).
        IF sy-subrc = 0 AND lv_OrderIsTechnicallyCompleted = 'X'.
          <ls_nxt>-DonHangVet = 'X'.
        ENDIF.
      ENDIF.
      IF <ls_MATERIALDOCUMENTITEM>-GoodsMovementType = '541'.
*       CT7
        <ls_nxt>-XuatTKy = <ls_nxt>-XuatTKy + <ls_MATERIALDOCUMENTITEM>-QuantityInBaseUnit.
      ELSEIF <ls_MATERIALDOCUMENTITEM>-GoodsMovementType = '543'.
*      CT9A
        <ls_nxt>-SLBTPNVLDaNhapVe = <ls_nxt>-SLBTPNVLDaNhapVe + <ls_MATERIALDOCUMENTITEM>-QuantityInBaseUnit.
      ELSEIF <ls_MATERIALDOCUMENTITEM>-GoodsMovementType = '542'.
        IF <ls_MATERIALDOCUMENTITEM>-YY1_LNhapTra_MMI = '1'.
*        CT9
          <ls_nxt>-NhapTraBTPDat = <ls_nxt>-NhapTraBTPDat + <ls_MATERIALDOCUMENTITEM>-QuantityInBaseUnit.
        ELSEIF <ls_MATERIALDOCUMENTITEM>-YY1_LNhapTra_MMI = '2'.
*        CT11
          <ls_nxt>-NhapTraBTPLoiCTy = <ls_nxt>-NhapTraBTPLoiCTy + <ls_MATERIALDOCUMENTITEM>-QuantityInBaseUnit.
        ELSEIF <ls_MATERIALDOCUMENTITEM>-YY1_LNhapTra_MMI = '3'.
*        CT11A
          <ls_nxt>-NhapTraBTPLoiGC = <ls_nxt>-NhapTraBTPLoiGC + <ls_MATERIALDOCUMENTITEM>-QuantityInBaseUnit.
        ENDIF.
      ELSEIF <ls_MATERIALDOCUMENTITEM>-GoodsMovementType = 'X43'.
*      CT11B
        <ls_nxt>-NhapTruBTPThieu = <ls_nxt>-NhapTruBTPThieu + <ls_MATERIALDOCUMENTITEM>-QuantityInBaseUnit.
      ENDIF.
    ENDLOOP.

    SELECT MaterialDocumentYear, MaterialDocument, MaterialDocumentItem,  OrderID,  PurchaseOrder,
          PurchaseOrderItem, GoodsMovementType,Supplier, mdi~Material,plant,
          InventorySpecialStockType, QuantityInBaseUnit, MaterialBaseUnit, isautomaticallycreated,
          YY1_LNhapTra_MMI, YY1_LenhGiaCong_MMI, Batch, InventoryValuationType
    FROM zc_materialdocumentitem_2 AS mdi
    INNER JOIN ztb_mat_type ON mdi~material = ztb_mat_type~material AND ztb_mat_type~mattype = '1'
     WHERE PostingDate <= @i_dateto
     AND PostingDate >= @i_datefr
     AND InventorySpecialStockType = 'O'
*      AND isautomaticallycreated = 'X'
*      AND reversedmaterialdocumentitem = ''
     AND reversedmaterialdocument = ''
     AND GoodsMovementType IN ('541','Y27')
     AND mdi~Material IN @ir_material
     AND plant IN @ir_plant
     AND Supplier IN @ir_supplier
*      AND YY1_LenhGiaCong_MMI = ''
     INTO TABLE @DATA(lt_MATERIALDOCUMENTITEM_vb).
    SORT lt_MATERIALDOCUMENTITEM_vb BY MaterialDocumentYear MaterialDocument MaterialDocumentItem.
    LOOP AT lt_MATERIALDOCUMENTITEM_vb ASSIGNING <ls_MATERIALDOCUMENTITEM>.
      CLEAR ls_nxt.
      READ TABLE e_nxt ASSIGNING <ls_nxt>
        WITH KEY orderid = <ls_MATERIALDOCUMENTITEM>-YY1_LenhGiaCong_MMI
                 supplier = <ls_MATERIALDOCUMENTITEM>-Supplier
                material = <ls_MATERIALDOCUMENTITEM>-Material
                plant    = <ls_MATERIALDOCUMENTITEM>-plant
                Batch   = <ls_MATERIALDOCUMENTITEM>-Batch
                inventoryvaluationtype = <ls_MATERIALDOCUMENTITEM>-InventoryValuationType.
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO e_nxt ASSIGNING <ls_nxt>.
        <ls_nxt>-orderid = <ls_MATERIALDOCUMENTITEM>-YY1_LenhGiaCong_MMI.
        <ls_nxt>-material = <ls_MATERIALDOCUMENTITEM>-Material.
        <ls_nxt>-supplier = <ls_MATERIALDOCUMENTITEM>-Supplier.
        <ls_nxt>-plant = <ls_MATERIALDOCUMENTITEM>-plant.
        <ls_nxt>-MaterialBaseUnit = <ls_MATERIALDOCUMENTITEM>-MaterialBaseUnit.
        <ls_nxt>-Batch = <ls_MATERIALDOCUMENTITEM>-Batch.
        <ls_nxt>-InventoryValuationType = <ls_MATERIALDOCUMENTITEM>-InventoryValuationType.
      ENDIF.
      IF <ls_MATERIALDOCUMENTITEM>-GoodsMovementType = '541' .
*       CT7
        <ls_nxt>-XuatTKy = <ls_nxt>-XuatTKy + <ls_MATERIALDOCUMENTITEM>-QuantityInBaseUnit.
      ELSEIF <ls_MATERIALDOCUMENTITEM>-GoodsMovementType = 'Y27'.
        <ls_nxt>-NhapTraBTPDat = <ls_nxt>-NhapTraBTPDat + <ls_MATERIALDOCUMENTITEM>-QuantityInBaseUnit.
      ENDIF.

    ENDLOOP.

    LOOP AT e_nxt ASSIGNING <ls_nxt>.
*    CT10
      <ls_nxt>-BTPLoi = <ls_nxt>-NhapTraBTPLoiCTy + <ls_nxt>-NhapTraBTPLoiGC." + <ls_nxt>-NhapTruBTPThieu.
*      CT8
      <ls_nxt>-NhapTKy = <ls_nxt>-SLBTPNVLDaNhapVe + <ls_nxt>-NhapTraBTPDat + <ls_nxt>-BTPLoi.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_xnt.
    DATA: ls_nxt TYPE zc_bc_xnt_hv.
    DATA: lw_ky_truoc TYPE zde_period,
          lw_ky_nay   TYPE zde_period.
    DATA: lw_datefr TYPE zde_date,
          lw_dateto TYPE zde_date.

    lw_ky_nay =  i_datefr(6).
    SELECT SINGLE * FROM ztb_period WHERE zper = @lw_ky_nay INTO @DATA(ls_ky_nay) .
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    SELECT * FROM ztb_nxt_hv
      WHERE  zper = @ls_ky_nay-lastper
      AND Material IN @ir_material
      AND plant IN @ir_plant
      AND Supplier IN @ir_supplier
      AND orderid IN @ir_orderid
      AND Batch IN @ir_batch
      AND InventoryValuationType IN @ir_evaltype
      INTO TABLE @DATA(lt_nxt_ky_truoc).
    IF i_datefr+6(2) <> '01'.
      lw_datefr = i_datefr(6) && '01'.
      lw_dateto = i_datefr - 1.
      CALL METHOD get_xnt_ps
        EXPORTING
          i_datefr    = lw_datefr
          i_dateto    = lw_dateto
          ir_material = ir_material
          ir_plant    = ir_plant
          ir_supplier = ir_supplier
          ir_orderid  = ir_orderid
          ir_batch    = ir_batch
          ir_evaltype = ir_evaltype
        IMPORTING
          e_nxt       = DATA(lt_nxt_ps_kt).
      LOOP AT lt_nxt_ps_kt ASSIGNING FIELD-SYMBOL(<ls_nxt_ps_kt>) .
        READ TABLE lt_nxt_ky_truoc ASSIGNING  FIELD-SYMBOL(<ls_nxt_ky_truoc>)
        WITH KEY orderid = <ls_nxt_ps_kt>-orderid
                supplier = <ls_nxt_ps_kt>-supplier
              material = <ls_nxt_ps_kt>-material
              plant    = <ls_nxt_ps_kt>-plant
              batch    = <ls_nxt_ps_kt>-batch
              inventoryvaluationtype = <ls_nxt_ps_kt>-inventoryvaluationtype.
        IF sy-subrc = 0.
          <ls_nxt_ky_truoc>-quantityinbaseunit = <ls_nxt_ky_truoc>-quantityinbaseunit + <ls_nxt_ps_kt>-XuatTKy - <ls_nxt_ps_kt>-NhapTKy.
        ELSE.
          APPEND INITIAL LINE TO lt_nxt_ky_truoc ASSIGNING <ls_nxt_ky_truoc>.
          <ls_nxt_ky_truoc>-orderid = <ls_nxt_ps_kt>-orderid.
          <ls_nxt_ky_truoc>-supplier = <ls_nxt_ps_kt>-supplier.
          <ls_nxt_ky_truoc>-material = <ls_nxt_ps_kt>-material.
          <ls_nxt_ky_truoc>-plant = <ls_nxt_ps_kt>-plant.
          <ls_nxt_ky_truoc>-batch = <ls_nxt_ps_kt>-batch.
          <ls_nxt_ky_truoc>-inventoryvaluationtype = <ls_nxt_ps_kt>-inventoryvaluationtype.
          <ls_nxt_ky_truoc>-quantityinbaseunit = <ls_nxt_ps_kt>-XuatTKy - <ls_nxt_ps_kt>-NhapTKy.
          <ls_nxt_ky_truoc>-materialbaseunit = <ls_nxt_ps_kt>-MaterialBaseUnit.
        ENDIF.
      ENDLOOP.
    ENDIF.

    lw_datefr = i_datefr.
    lw_dateto = i_dateto.
    CALL METHOD get_xnt_ps
      EXPORTING
        i_datefr    = lw_datefr
        i_dateto    = lw_dateto
        ir_material = ir_material
        ir_plant    = ir_plant
        ir_supplier = ir_supplier
        ir_orderid  = ir_orderid
        ir_batch    = ir_batch
        ir_evaltype = ir_evaltype
      IMPORTING
        e_nxt       = DATA(lt_nxt_ps).
    LOOP AT lt_nxt_ky_truoc ASSIGNING <ls_nxt_ky_truoc>.
      READ TABLE lt_nxt_ps ASSIGNING FIELD-SYMBOL(<ls_nxt_ps>)
      WITH KEY orderid = <ls_nxt_ky_truoc>-orderid
              supplier = <ls_nxt_ky_truoc>-supplier
            material = <ls_nxt_ky_truoc>-material
            batch    = <ls_nxt_ky_truoc>-batch
            plant    = <ls_nxt_ky_truoc>-plant
            inventoryvaluationtype = <ls_nxt_ky_truoc>-inventoryvaluationtype.
      IF sy-subrc = 0.
        <ls_nxt_ps>-DauKy = <ls_nxt_ps>-DauKy + <ls_nxt_ky_truoc>-quantityinbaseunit.
      ELSE.
        APPEND INITIAL LINE TO lt_nxt_ps ASSIGNING <ls_nxt_ps>.
        <ls_nxt_ps>-orderid = <ls_nxt_ky_truoc>-orderid.
        <ls_nxt_ps>-supplier = <ls_nxt_ky_truoc>-supplier.
        <ls_nxt_ps>-material = <ls_nxt_ky_truoc>-material.
        <ls_nxt_ps>-plant = <ls_nxt_ky_truoc>-plant.
        <ls_nxt_ps>-Batch = <ls_nxt_ky_truoc>-batch.
        <ls_nxt_ps>-InventoryValuationType = <ls_nxt_ky_truoc>-inventoryvaluationtype.
        <ls_nxt_ps>-DauKy = <ls_nxt_ky_truoc>-quantityinbaseunit.
        <ls_nxt_ps>-MaterialBaseUnit = <ls_nxt_ky_truoc>-materialbaseunit.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_nxt_ps ASSIGNING <ls_nxt_ps>.
      <ls_nxt_ps>-ct11c = <ls_nxt_ps>-DauKy + <ls_nxt_ps>-XuatTKy - <ls_nxt_ps>-NhapTKy.
      <ls_nxt_ps>-TonCuoi = <ls_nxt_ps>-ct11c - <ls_nxt_ps>-NhapTruBTPThieu.
    ENDLOOP.

    MOVE-CORRESPONDING lt_nxt_ps TO e_nxt.

  ENDMETHOD.
ENDCLASS.

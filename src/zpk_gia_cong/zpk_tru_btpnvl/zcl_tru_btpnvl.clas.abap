CLASS zcl_tru_btpnvl DEFINITION
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

           tt_ranges TYPE TABLE OF ty_range_option.


    TYPES: tt_tru_thie_dtl TYPE STANDARD TABLE OF ztb_tru_thie_dtl,
           tt_tru_thie_th  TYPE STANDARD TABLE OF ztb_tru_thie_th.

    CLASS-METHODS: get_tru_thieu
      IMPORTING
                i_tru_thieu    TYPE ztb_tru_thieu
      EXPORTING e_tru_thie_dtl TYPE tt_tru_thie_dtl
                e_tru_thie_th  TYPE tt_tru_thie_th
      .

    CLASS-METHODS: update_tru_thieu_dtl
      CHANGING
        c_tru_thie_dtl TYPE ztb_tru_thie_dtl.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_tru_btpnvl IMPLEMENTATION.


  METHOD get_tru_thieu.
    DATA: ls_tru_thie_dtl TYPE ztb_tru_thie_dtl,
          lt_tru_thie_dtl TYPE TABLE OF ztb_tru_thie_dtl.
    DATA: lw_dtl_cr TYPE zde_flag.
    DATA: lw_lenhsx TYPE zde_char20.


    SELECT * FROM ztb_dg_btp_thieu
    INTO TABLE @DATA(lt_dg_btp_thieu).

    SELECT SINGLE * FROM zr_tbperiod
        WHERE Zper = @i_tru_thieu-zper
        INTO  @DATA(ls_tbperiod).
    IF sy-subrc <> 0.
      RETURN. " No records found
    ENDIF.

    DATA: lw_tyle TYPE zde_dec_5_2.
    lw_tyle = 5 / 100.
    SELECT * FROM ztb_tyle_config
    WHERE type = '01' AND validfrom <=  @i_tru_thieu-ngaylapbang AND validto >= @i_tru_thieu-ngaylapbang
    INTO TABLE @DATA(lt_tyle_config).
*    IF sy-subrc = 0.
*      lw_tyle = ls_tyle_config-tyle.
*    ENDIF.

    SELECT * FROM ztb_tru_thie_dtl
    WHERE hdr_id = @i_tru_thieu-hdr_id
    INTO TABLE @DATA(lt_dtl_db).
    SORT lt_dtl_db BY material supplier.

    SELECT MaterialDocumentYear, MaterialDocument, MaterialDocumentItem,  OrderID,  PurchaseOrder,
             PurchaseOrderItem, GoodsMovementType,Supplier, mdi~Material,plant,
           InventorySpecialStockType, QuantityInBaseUnit, MaterialBaseUnit, isautomaticallycreated,
           YY1_LNhapTra_MMI, YY1_LenhGiaCong_MMI
     FROM zc_materialdocumentitem_2 AS mdi
     LEFT JOIN ztb_mat_type ON mdi~material = ztb_mat_type~material AND ztb_mat_type~mattype = '1'
      WHERE PostingDate <= @ls_tbperiod-zdateto
      AND PostingDate >= @ls_tbperiod-zdatefr
      AND PostingDate <= @i_tru_thieu-ngaylapbang
*      AND InventorySpecialStockType = 'O'
      AND reversedmaterialdocument = ''
      AND GoodsMovementType IN ('X43','543')
      AND CompanyCode = @i_tru_thieu-bukrs
      AND ztb_mat_type~material IS NULL
      INTO TABLE @DATA(lt_MATERIALDOCUMENTITEM).
    SORT lt_MATERIALDOCUMENTITEM BY MaterialDocumentYear MaterialDocument MaterialDocumentItem.

    LOOP AT lt_MATERIALDOCUMENTITEM ASSIGNING FIELD-SYMBOL(<ls_MATERIALDOCUMENTITEM>).
      IF <ls_MATERIALDOCUMENTITEM>-YY1_LenhGiaCong_MMI IS NOT INITIAL.
        lw_lenhsx = <ls_MATERIALDOCUMENTITEM>-YY1_LenhGiaCong_MMI .
      ELSEIF <ls_MATERIALDOCUMENTITEM>-OrderID IS NOT INITIAL.
        lw_lenhsx = <ls_MATERIALDOCUMENTITEM>-OrderID .
      ELSEIF <ls_MATERIALDOCUMENTITEM>-PurchaseOrder IS NOT INITIAL." AND <ls_materialdocumentitem>-PurchaseOrderItem IS NOT INITIAL.
        SELECT SINGLE orderid
        FROM zi_purordaccountassignment
        WHERE PurchaseOrder = @<ls_MATERIALDOCUMENTITEM>-PurchaseOrder "AND purchaseOrderItem = @<ls_MATERIALDOCUMENTITEM>-PurchaseOrderItem
        INTO @lw_lenhsx.
      ENDIF.
      IF lw_lenhsx IS INITIAL .
        CONTINUE.
      ENDIF.
      SELECT SINGLE SalesOrder, SalesOrderItem FROM zc_productionorder
         WHERE ProductionOrder = @lw_lenhsx AND ProductionOrderType IN ( '1014', '2012' )
         INTO @DATA(ls_productionorder).
      IF sy-subrc IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE lt_tru_thie_dtl ASSIGNING FIELD-SYMBOL(<lf_tru_thie_dtl>)
      WITH KEY supplier = <ls_MATERIALDOCUMENTITEM>-Supplier
               material = <ls_MATERIALDOCUMENTITEM>-Material.
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_tru_thie_dtl ASSIGNING <lf_tru_thie_dtl>.
        <lf_tru_thie_dtl>-material = <ls_MATERIALDOCUMENTITEM>-Material.
        <lf_tru_thie_dtl>-supplier = <ls_MATERIALDOCUMENTITEM>-Supplier.
        <lf_tru_thie_dtl>-materialbaseunit = <ls_MATERIALDOCUMENTITEM>-materialbaseunit.
      ENDIF.
      IF <ls_MATERIALDOCUMENTITEM>-GoodsMovementType = 'X43' AND <ls_MATERIALDOCUMENTITEM>-InventorySpecialStockType = 'O'.
        <lf_tru_thie_dtl>-thieu += <ls_MATERIALDOCUMENTITEM>-QuantityInBaseUnit.
*      ELSEIF <ls_MATERIALDOCUMENTITEM>-GoodsMovementType = 'Y21'.
*        <lf_tru_thie_dtl>-thua += <ls_MATERIALDOCUMENTITEM>-QuantityInBaseUnit.
      ELSEIF <ls_MATERIALDOCUMENTITEM>-GoodsMovementType = '543'  AND <ls_MATERIALDOCUMENTITEM>-InventorySpecialStockType = 'O'.
        <lf_tru_thie_dtl>-nhap += <ls_MATERIALDOCUMENTITEM>-QuantityInBaseUnit.
      ENDIF.
    ENDLOOP.

    SELECT MaterialDocumentYear, MaterialDocument, MaterialDocumentItem,  OrderID,
            PurchaseOrder, PurchaseOrderItem, GoodsMovementType,Supplier, mdi~Material,plant,
           InventorySpecialStockType, QuantityInBaseUnit, MaterialBaseUnit, isautomaticallycreated,
           YY1_LNhapTra_MMI, YY1_LenhGiaCong_MMI
     FROM zc_materialdocumentitem_2 AS mdi
     INNER JOIN ztb_mat_type ON mdi~material = ztb_mat_type~material AND ztb_mat_type~mattype = '1'
      WHERE PostingDate <= @ls_tbperiod-zdateto
      AND PostingDate >= @ls_tbperiod-zdatefr
      AND PostingDate <= @i_tru_thieu-ngaylapbang
      AND InventorySpecialStockType = 'O'
      AND reversedmaterialdocument = ''
      AND GoodsMovementType IN ('541','Y27')
      AND CompanyCode = @i_tru_thieu-bukrs
      INTO TABLE @DATA(lt_MATERIALDOCUMENTITEM_vb).
    SORT lt_MATERIALDOCUMENTITEM_vb BY MaterialDocumentYear MaterialDocument MaterialDocumentItem.

    LOOP AT lt_MATERIALDOCUMENTITEM_vb ASSIGNING <ls_MATERIALDOCUMENTITEM>.
      IF <ls_MATERIALDOCUMENTITEM>-YY1_LenhGiaCong_MMI IS NOT INITIAL.
        lw_lenhsx = <ls_MATERIALDOCUMENTITEM>-YY1_LenhGiaCong_MMI .
*      ELSEIF <ls_MATERIALDOCUMENTITEM>-OrderID IS NOT INITIAL.
*        lw_lenhsx = <ls_MATERIALDOCUMENTITEM>-OrderID .
*      ELSEIF <ls_MATERIALDOCUMENTITEM>-PurchaseOrder IS NOT INITIAL." AND <ls_materialdocumentitem>-PurchaseOrderItem IS NOT INITIAL.
*        SELECT SINGLE orderid
*        FROM zi_purordaccountassignment
*        WHERE PurchaseOrder = @<ls_MATERIALDOCUMENTITEM>-PurchaseOrder "AND purchaseOrderItem = @<ls_MATERIALDOCUMENTITEM>-PurchaseOrderItem
*        INTO @lw_lenhsx.
      ENDIF.
*      IF lw_lenhsx IS INITIAL .
*        CONTINUE.
*      ENDIF.
*      IF lw_lenhsx IS NOT INITIAL .
*        SELECT SINGLE SalesOrder, SalesOrderItem FROM zc_productionorder
*           WHERE ProductionOrder = @lw_lenhsx AND ProductionOrderType IN ( '1014', '2012' )
*           INTO @ls_productionorder.
*        IF sy-subrc IS NOT INITIAL.
*          CONTINUE.
*        ENDIF.
*      ENDIF.

      READ TABLE lt_tru_thie_dtl ASSIGNING <lf_tru_thie_dtl>
      WITH KEY supplier = <ls_MATERIALDOCUMENTITEM>-Supplier
               material = <ls_MATERIALDOCUMENTITEM>-Material.
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_tru_thie_dtl ASSIGNING <lf_tru_thie_dtl>.
        <lf_tru_thie_dtl>-material = <ls_MATERIALDOCUMENTITEM>-Material.
        <lf_tru_thie_dtl>-supplier = <ls_MATERIALDOCUMENTITEM>-Supplier.
        <lf_tru_thie_dtl>-materialbaseunit = <ls_MATERIALDOCUMENTITEM>-materialbaseunit.
        <lf_tru_thie_dtl>-vobao = 'X'.
      ENDIF.
      IF <ls_MATERIALDOCUMENTITEM>-GoodsMovementType = '541' .
        <lf_tru_thie_dtl>-thieu += <ls_MATERIALDOCUMENTITEM>-QuantityInBaseUnit.
      ELSEIF <ls_MATERIALDOCUMENTITEM>-GoodsMovementType = 'Y27' .
        <lf_tru_thie_dtl>-nhap += <ls_MATERIALDOCUMENTITEM>-QuantityInBaseUnit.
        <lf_tru_thie_dtl>-thieu -= <ls_MATERIALDOCUMENTITEM>-QuantityInBaseUnit.
      ENDIF.
    ENDLOOP.

    DATA:
      ir_material TYPE tt_ranges,
      ir_supplier TYPE tt_ranges,
      lt_data     TYPE TABLE OF zc_bc_xnt.
    IF lt_tru_thie_dtl IS NOT INITIAL.
      SELECT Product, ProductGroup FROM zc_Product
          FOR ALL ENTRIES IN @lt_tru_thie_dtl
          WHERE Product = @lt_tru_thie_dtl-material
          INTO TABLE @DATA(lt_Product).
      SORT lt_Product BY Product.

      LOOP AT lt_tru_thie_dtl INTO ls_tru_thie_dtl.
        APPEND INITIAL LINE TO ir_material ASSIGNING FIELD-SYMBOL(<ls_material>).
        <ls_material>-sign = 'I'.
        <ls_material>-option = 'EQ'.
        <ls_material>-low = ls_tru_thie_dtl-material.
        APPEND INITIAL LINE TO ir_supplier ASSIGNING FIELD-SYMBOL(<ls_supplier>).
        <ls_supplier>-sign = 'I'.
        <ls_supplier>-option = 'EQ'.
        <ls_supplier>-low = ls_tru_thie_dtl-supplier.
      ENDLOOP.

      CALL METHOD zcl_xnt=>get_xnt
        EXPORTING
          i_datefr    = ls_tbperiod-zdatefr
          i_dateto    = i_tru_thieu-ngaylapbang
          ir_material = ir_material
          ir_supplier = ir_supplier
        IMPORTING
          e_nxt       = lt_data.

    ENDIF.

    LOOP AT lt_tru_thie_dtl ASSIGNING <lf_tru_thie_dtl>.
      READ TABLE lt_dtl_db INTO DATA(ls_dtl_db)
      WITH KEY material = <lf_tru_thie_dtl>-material
               supplier = <lf_tru_thie_dtl>-supplier.
      IF sy-subrc IS INITIAL.
        <lf_tru_thie_dtl>-hdr_id = ls_dtl_db-hdr_id.
        <lf_tru_thie_dtl>-dtl_id = ls_dtl_db-dtl_id.
*        <lf_tru_thie_dtl>-duocphep = ls_dtl_db-duocphep.
      ELSE.
        TRY.
            DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error INTO DATA(lx_uuid).

        ENDTRY.
        <lf_tru_thie_dtl>-hdr_id = i_tru_thieu-hdr_id.
        <lf_tru_thie_dtl>-dtl_id = lv_uuid.
*        <lf_tru_thie_dtl>-duocphep = lw_tyle.
      ENDIF.

      READ TABLE lt_Product INTO DATA(ls_Product)
            WITH KEY Product = <lf_tru_thie_dtl>-material.

      READ TABLE lt_tyle_config INTO DATA(ls_tyle_config)
        WITH KEY material = <lf_tru_thie_dtl>-material.
      IF sy-subrc IS NOT INITIAL.
        READ TABLE lt_tyle_config INTO ls_tyle_config
        WITH KEY material = ''
            productgroup = ls_Product-ProductGroup.
      ENDIF.
      IF sy-subrc IS INITIAL.
        <lf_tru_thie_dtl>-duocphep = ls_tyle_config-tyle.
      ENDIF.
      DATA: lw_ct18a            TYPE zc_bc_xnt-ct18,
            lw_SLBTPNVLDaNhapVe TYPE zc_bc_xnt-SLBTPNVLDaNhapVe.

      LOOP AT lt_data INTO DATA(ls_xnt)
       WHERE material = <lf_tru_thie_dtl>-material AND
               supplier = <lf_tru_thie_dtl>-supplier
*               DonHangVet = 'X'
       .
*      IF sy-subrc IS INITIAL.
        <lf_tru_thie_dtl>-thua += ls_xnt-ct20.
        <lf_tru_thie_dtl>-loi += ls_xnt-NhapTraBTPLoiGC.
        IF ls_xnt-ct18a <> 0.
          lw_ct18a += ls_xnt-ct18a.
        ELSE.
          lw_SLBTPNVLDaNhapVe += ls_xnt-SLBTPNVLDaNhapVe.
        ENDIF.
*      ENDIF.
      ENDLOOP.

      IF <lf_tru_thie_dtl>-vobao <> 'X'.
*        IF lw_ct18a <> 0.
        <lf_tru_thie_dtl>-nhap = lw_ct18a + lw_SLBTPNVLDaNhapVe.
*        ELSE.
*          <lf_tru_thie_dtl>-nhap = lw_SLBTPNVLDaNhapVe.
*        ENDIF.
      ENDIF.

      CLEAR: lw_ct18a, lw_SLBTPNVLDaNhapVe.

      DATA: lv_result TYPE abap_bool.
      READ TABLE lt_dg_btp_thieu
          INTO DATA(ls_dg_btp_thieu)
          WITH KEY material = <lf_tru_thie_dtl>-material.
      IF sy-subrc IS INITIAL.
        <lf_tru_thie_dtl>-dongiatru = ls_dg_btp_thieu-price.
      ELSE.
        CLEAR lv_result.

        SELECT * FROM zc_product_charact
          WHERE ClfnObjectID = @<lf_tru_thie_dtl>-material
          INTO TABLE @DATA(lt_product_charact).
        LOOP AT lt_product_charact INTO DATA(ls_product_charact).
          LOOP AT lt_dg_btp_thieu
            INTO ls_dg_btp_thieu
            WHERE material = '' AND (  productgroup = ls_Product-ProductGroup OR productgroup = '' ).
            IF ls_dg_btp_thieu-charcvalue = ls_product_charact-CharcValue.
              lv_result = 'X'.
            ELSE.
              lv_result = zcl_utility=>check_rule(
                  iv_rule  = |{ ls_dg_btp_thieu-charcvalue }|
                  iv_value = |{ ls_product_charact-CharcValue }|
                ).
            ENDIF.

            IF lv_result = 'X'.
              <lf_tru_thie_dtl>-characteristic = ls_dg_btp_thieu-characteristic.
              <lf_tru_thie_dtl>-charcvalue = ls_product_charact-CharcValue.
              <lf_tru_thie_dtl>-dongiatru = ls_dg_btp_thieu-price.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF lv_result = 'X'.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF lv_result = ''.
          READ TABLE lt_dg_btp_thieu
            INTO ls_dg_btp_thieu
            WITH KEY material = ''
                   productgroup = ls_Product-ProductGroup
                      charcvalue = ''.
          IF sy-subrc IS INITIAL.
            <lf_tru_thie_dtl>-characteristic = ls_dg_btp_thieu-characteristic.
            <lf_tru_thie_dtl>-charcvalue = ''.
            <lf_tru_thie_dtl>-dongiatru = ls_dg_btp_thieu-price.
          ENDIF.
        ENDIF.
      ENDIF.

*      CALL METHOD zcl_tru_btpnvl=>update_tru_thieu_dtl
*        CHANGING
*          c_tru_thie_dtl = <lf_tru_thie_dtl>.

      CLEAR ls_Product.
    ENDLOOP.
    DELETE lt_tru_thie_dtl WHERE dongiatru = 0.
    DELETE lt_tru_thie_dtl WHERE thieu = 0 AND thua = 0 AND Nhap = 0.
    SORT lt_tru_thie_dtl BY supplier material.
    LOOP AT lt_tru_thie_dtl INTO ls_tru_thie_dtl.
      IF ls_tru_thie_dtl-vobao = ''.
        CLEAR ls_tru_thie_dtl-material.
      ENDIF.
      READ TABLE e_tru_thie_th ASSIGNING FIELD-SYMBOL(<lf_tru_thie_th>)
      WITH KEY supplier = ls_tru_thie_dtl-supplier
      characteristic = ls_tru_thie_dtl-characteristic
      material = ls_tru_thie_dtl-material.
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO e_tru_thie_th ASSIGNING <lf_tru_thie_th>.
        <lf_tru_thie_th>-hdr_id = i_tru_thieu-hdr_id.
        TRY.
            lv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error INTO lx_uuid.

        ENDTRY.
        <lf_tru_thie_th>-dtl_id = lv_uuid.
        <lf_tru_thie_th>-supplier = ls_tru_thie_dtl-supplier.
        <lf_tru_thie_th>-characteristic = ls_tru_thie_dtl-characteristic.
        <lf_tru_thie_th>-Charcvalue = ls_tru_thie_dtl-Charcvalue.
        <lf_tru_thie_th>-material = ls_tru_thie_dtl-material.
        <lf_tru_thie_th>-duocphep = ls_tru_thie_dtl-duocphep.
        <lf_tru_thie_th>-dongiatru = ls_tru_thie_dtl-dongiatru.
      ENDIF.

      <lf_tru_thie_th>-thieu += ls_tru_thie_dtl-thieu.
      <lf_tru_thie_th>-thieu -= ls_tru_thie_dtl-thua.
      <lf_tru_thie_th>-loi += ls_tru_thie_dtl-loi.
      <lf_tru_thie_th>-nhap += ls_tru_thie_dtl-nhap.
    ENDLOOP.

    LOOP AT e_tru_thie_th ASSIGNING <lf_tru_thie_th>.
      <lf_tru_thie_th>-slduocphep = <lf_tru_thie_th>-nhap * <lf_tru_thie_th>-duocphep / 100.

      IF <lf_tru_thie_th>-thieu < 0.
        <lf_tru_thie_th>-sltru = 0.
      ELSE.
        <lf_tru_thie_th>-sltru = <lf_tru_thie_th>-thieu - <lf_tru_thie_th>-slduocphep.
        IF <lf_tru_thie_th>-sltru < 0.
          <lf_tru_thie_th>-sltru = 0.
        ENDIF.
      ENDIF.
      <lf_tru_thie_th>-tongsltru = <lf_tru_thie_th>-sltru + <lf_tru_thie_th>-loi.

      <lf_tru_thie_th>-tongtientru = <lf_tru_thie_th>-tongsltru * <lf_tru_thie_th>-dongiatru.
    ENDLOOP.

    e_tru_thie_dtl = lt_tru_thie_dtl.
  ENDMETHOD.


  METHOD update_tru_thieu_dtl.
    c_tru_thie_dtl-slduocphep = c_tru_thie_dtl-nhap * c_tru_thie_dtl-duocphep / 100.
    c_tru_thie_dtl-slduocphep = round(
              val = c_tru_thie_dtl-slduocphep
              dec = 0
            ).
    IF c_tru_thie_dtl-thua > 0.
      c_tru_thie_dtl-sltru = c_tru_thie_dtl-thua * -1.
    ELSE.
      c_tru_thie_dtl-sltru = c_tru_thie_dtl-thieu - c_tru_thie_dtl-slduocphep.
      IF c_tru_thie_dtl-sltru < 0.
        c_tru_thie_dtl-sltru = 0.
      ENDIF.
    ENDIF.
    c_tru_thie_dtl-tongtientru = c_tru_thie_dtl-sltru * c_tru_thie_dtl-dongiatru.
  ENDMETHOD.
ENDCLASS.

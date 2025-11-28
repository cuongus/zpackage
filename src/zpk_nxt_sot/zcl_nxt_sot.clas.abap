CLASS zcl_nxt_sot DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_c_nxt_sot_dtl TYPE TABLE OF zc_nxt_sot_dtl,
           tt_c_nxt_sot_hdr TYPE TABLE OF zc_nxt_sot_hdr.
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_ranges TYPE TABLE OF ty_range_option.

    CLASS-METHODS: get_xnt_sot_dtl
      IMPORTING
                ir_datefr     TYPE zde_date
                ir_dateto     TYPE zde_date
                ir_material   TYPE tt_ranges OPTIONAL
                ir_plant      TYPE tt_ranges OPTIONAL
                ir_sloc       TYPE tt_ranges OPTIONAL
                ir_vendor     TYPE tt_ranges OPTIONAL
      EXPORTING e_nxt_sot_dtl TYPE tt_c_nxt_sot_dtl.


    CLASS-METHODS: get_xnt_sot_ps
      IMPORTING
                ir_datefr     TYPE zde_date
                ir_dateto     TYPE zde_date
                ir_material   TYPE tt_ranges OPTIONAL
                ir_plant      TYPE tt_ranges OPTIONAL
                ir_sloc       TYPE tt_ranges OPTIONAL
                ir_vendor     TYPE tt_ranges OPTIONAL
      EXPORTING e_nxt_sot_dtl TYPE tt_c_nxt_sot_dtl
                e_nxt_sot_hdr TYPE tt_c_nxt_sot_hdr.

    CLASS-METHODS: get_xnt_sot
      IMPORTING
                ir_datefr     TYPE zde_date
                ir_dateto     TYPE zde_date
                ir_material   TYPE tt_ranges OPTIONAL
                ir_plant      TYPE tt_ranges OPTIONAL
                ir_sloc       TYPE tt_ranges OPTIONAL
                ir_vendor     TYPE tt_ranges OPTIONAL
      EXPORTING e_nxt_sot_dtl TYPE tt_c_nxt_sot_dtl
                e_nxt_sot_hdr TYPE tt_c_nxt_sot_hdr.

    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_nxt_sot IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

  ENDMETHOD.


  METHOD get_xnt_sot_ps.
    DATA: ls_hdr TYPE LINE OF tt_c_nxt_sot_hdr,
          ls_dtl TYPE LINE OF tt_c_nxt_sot_dtl.
    SELECT materialdocumentyear, postingdate, materialdocument, materialdocumentitem, goodsmovementtype, material,
     quantityinbaseunit, plant, storagelocation, supplier, materialbaseunit
  FROM i_materialdocumentitem_2 AS a
  WHERE a~goodsmovementtype IN ('Y17', 'X35')
        AND a~material IN @ir_material
        AND a~supplier IN @ir_vendor
        AND a~plant IN @ir_plant
        AND a~storagelocation IN @ir_sloc
        AND a~postingdate <= @ir_dateto
        AND a~postingdate >= @ir_datefr
    AND NOT EXISTS (
      SELECT 1 FROM i_materialdocumentitem_2 AS b
      WHERE b~goodsmovementtype IN ('Y18', 'X36')
      AND b~reversedmaterialdocument = a~materialdocument
      AND b~material = a~material
    )
  INTO TABLE @DATA(lt_matdoc).
*tạo table rồi xóa lặp cho hdr
    DATA: lt_matdoc_unique LIKE lt_matdoc.
    lt_matdoc_unique = lt_matdoc.
    SORT lt_matdoc_unique BY material plant storagelocation materialbaseunit.
    DELETE ADJACENT DUPLICATES FROM lt_matdoc_unique
      COMPARING material plant storagelocation materialbaseunit.
*xử lý hdr và dtl ứng với nó
    LOOP AT lt_matdoc_unique ASSIGNING FIELD-SYMBOL(<ls_matdoc_unique>).
      CLEAR ls_hdr.

      ls_hdr-ct01 = <ls_matdoc_unique>-Material.

      SELECT SINGLE productDescription
      FROM i_productdescription_2
      WHERE Product = @<ls_matdoc_unique>-Material
      AND language = 'E'
      INTO @ls_hdr-ct02.

      ls_hdr-ct03 = <ls_matdoc_unique>-MaterialBaseUnit.
      ls_hdr-ct04 = <ls_matdoc_unique>-Plant.

      SELECT SINGLE plantname
      FROM i_cnsldtnplantt
      WHERE plant = @<ls_matdoc_unique>-Plant
      AND language = 'E'
      INTO @ls_hdr-ct05.

      ls_hdr-ct06 = <ls_matdoc_unique>-StorageLocation.

      SELECT SINGLE storagelocationname
      FROM i_storagelocation
      WHERE plant = @<ls_matdoc_unique>-Plant
      AND storagelocation = @<ls_matdoc_unique>-StorageLocation
      INTO @ls_hdr-ct07.

      DATA: lv_ton_dau TYPE zc_nxt_sot_hdr-ct09,
            lv_nhap    TYPE zc_nxt_sot_hdr-ct10,
            lv_xuat    TYPE zc_nxt_sot_hdr-ct11.

      LOOP AT lt_matdoc INTO DATA(ls_matdoc)
    WHERE material         = <ls_matdoc_unique>-material
      AND plant            = <ls_matdoc_unique>-plant
      AND storagelocation  = <ls_matdoc_unique>-storagelocation
      AND supplier         = <ls_matdoc_unique>-supplier
      AND materialbaseunit = <ls_matdoc_unique>-materialbaseunit.
* xử lý tồn đầu cuối
        IF ls_matdoc-postingdate <= ir_dateto
           AND ls_matdoc-postingdate >= ir_datefr.

          IF ls_matdoc-goodsmovementtype = 'Y17'.
            lv_nhap = lv_nhap + ls_matdoc-quantityinbaseunit.
          ENDIF.

          IF ls_matdoc-goodsmovementtype = 'X35'.
            lv_xuat = lv_xuat + ls_matdoc-quantityinbaseunit.
          ENDIF.
        ENDIF.

        CLEAR ls_dtl.
        ls_dtl-ct01 = ls_matdoc-MaterialDocumentYear.
        ls_dtl-ct02 = ls_matdoc-PostingDate.
        ls_dtl-ct03 = ls_matdoc-MaterialDocument.
        ls_dtl-ct04 = ls_matdoc-MaterialDocumentItem.
        ls_dtl-ct05 = ls_matdoc-GoodsMovementType.
        ls_dtl-ct06 = ls_matdoc-Material.
        ls_dtl-ct07 = ls_matdoc-quantityinbaseunit.
        ls_dtl-ct08 = ls_matdoc-plant.
        ls_dtl-ct09 = ls_matdoc-StorageLocation.
        ls_dtl-ct10 = ls_matdoc-supplier.
        APPEND ls_dtl TO e_nxt_sot_dtl.

      ENDLOOP.
      ls_hdr-ct08 = lv_ton_dau.
      ls_hdr-ct09 = lv_nhap.
      ls_hdr-ct10 = lv_xuat.
      ls_hdr-ct11 = lv_ton_dau + lv_nhap - lv_xuat.
      ls_hdr-ct12 = <ls_matdoc_unique>-Supplier.

      SELECT SINGLE businesspartnerfullname
      FROM i_businesspartner
      WHERE businesspartner = @<ls_matdoc_unique>-Supplier
      INTO @ls_hdr-ct13.

      APPEND ls_hdr TO e_nxt_sot_hdr.
      FREE: lv_nhap, lv_xuat, lv_ton_dau.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_xnt_sot.
    DATA: ls_nxt TYPE zc_nxt_sot_hdr.
    DATA: lw_ky_truoc TYPE zde_period,
          lw_ky_nay   TYPE zde_period.
    DATA: lw_datefr TYPE zde_date,
          lw_dateto TYPE zde_date.

    lw_ky_nay =  ir_datefr(6).
    SELECT SINGLE * FROM ztb_period WHERE zper = @lw_ky_nay INTO @DATA(ls_ky_nay) .
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    SELECT * FROM ztb_nxt_sot
      WHERE  zper = @ls_ky_nay-lastper
      AND Material IN @ir_material
      AND plant IN @ir_plant
      AND vendor IN @ir_vendor
      AND  sloc IN @ir_sloc
      INTO TABLE @DATA(lt_nxt_ky_truoc).
    IF ir_datefr+6(2) <> '01'.
      lw_datefr = ir_datefr(6) && '01'.
      lw_dateto = ir_datefr - 1.
      CALL METHOD get_xnt_sot_ps
        EXPORTING
          ir_datefr     = lw_datefr
          ir_dateto     = lw_dateto
          ir_material   = ir_material
          ir_plant      = ir_plant
          ir_sloc       = ir_sloc
          ir_vendor     = ir_vendor
        IMPORTING
          e_nxt_sot_hdr = DATA(lt_nxt_ps_kt).
      LOOP AT lt_nxt_ps_kt ASSIGNING FIELD-SYMBOL(<ls_nxt_ps_kt>) .
        READ TABLE lt_nxt_ky_truoc ASSIGNING  FIELD-SYMBOL(<ls_nxt_ky_truoc>)
        WITH KEY material = <ls_nxt_ps_kt>-ct06
                sloc = <ls_nxt_ps_kt>-ct09

              plant    = <ls_nxt_ps_kt>-ct08.
        IF sy-subrc = 0.
          <ls_nxt_ky_truoc>-stock_qty = <ls_nxt_ky_truoc>-stock_qty + <ls_nxt_ps_kt>-ct11.
        ELSE.
          APPEND INITIAL LINE TO lt_nxt_ky_truoc ASSIGNING <ls_nxt_ky_truoc>.
          <ls_nxt_ky_truoc>-vendor = <ls_nxt_ps_kt>-ct12.
          <ls_nxt_ky_truoc>-material = <ls_nxt_ps_kt>-ct01.
          <ls_nxt_ky_truoc>-plant = <ls_nxt_ps_kt>-ct04.
          <ls_nxt_ky_truoc>-sloc = <ls_nxt_ps_kt>-ct06.
          <ls_nxt_ky_truoc>-stock_qty = <ls_nxt_ps_kt>-ct11.
          <ls_nxt_ky_truoc>-materialbaseunit = <ls_nxt_ps_kt>-ct03.
        ENDIF.
      ENDLOOP.
    ENDIF.

    lw_datefr = ir_datefr.
    lw_dateto = ir_dateto.
    CALL METHOD get_xnt_sot_ps
      EXPORTING
        ir_datefr     = lw_datefr
        ir_dateto     = lw_dateto
        ir_material   = ir_material
        ir_plant      = ir_plant
        ir_vendor     = ir_vendor
        ir_sloc       = ir_sloc
      IMPORTING
        e_nxt_sot_hdr = DATA(lt_nxt_ps).
    LOOP AT lt_nxt_ky_truoc ASSIGNING <ls_nxt_ky_truoc>.
      READ TABLE lt_nxt_ps ASSIGNING FIELD-SYMBOL(<ls_nxt_ps>)
      WITH KEY ct01 = <ls_nxt_ky_truoc>-material
              ct12 = <ls_nxt_ky_truoc>-vendor
            ct06 = <ls_nxt_ky_truoc>-sloc
            ct04    = <ls_nxt_ky_truoc>-plant.
      IF sy-subrc = 0.
        <ls_nxt_ps>-ct08 = <ls_nxt_ps>-ct08 + <ls_nxt_ky_truoc>-stock_qty.
      ELSE.
        APPEND INITIAL LINE TO lt_nxt_ps ASSIGNING <ls_nxt_ps>.
        <ls_nxt_ps>-ct12 = <ls_nxt_ky_truoc>-vendor.
        <ls_nxt_ps>-ct01 = <ls_nxt_ky_truoc>-material.
        <ls_nxt_ps>-ct04 = <ls_nxt_ky_truoc>-plant.
        <ls_nxt_ps>-ct06 = <ls_nxt_ky_truoc>-sloc.
        <ls_nxt_ps>-ct08 = <ls_nxt_ky_truoc>-stock_qty.
        <ls_nxt_ps>-ct03 = <ls_nxt_ky_truoc>-materialbaseunit.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_nxt_ps ASSIGNING <ls_nxt_ps>.
      <ls_nxt_ps>-ct11 = <ls_nxt_ps>-ct08 + <ls_nxt_ps>-ct09 - <ls_nxt_ps>-ct10.
      <ls_nxt_ps>-DateFR = ir_datefr.
      <ls_nxt_ps>-DateTO = ir_dateto.
    ENDLOOP.

    MOVE-CORRESPONDING lt_nxt_ps TO e_nxt_sot_hdr.

  ENDMETHOD.

  METHOD get_xnt_sot_dtl.
    DATA: ls_dtl TYPE LINE OF tt_c_nxt_sot_dtl.
    SELECT materialdocumentyear, postingdate, materialdocument, materialdocumentitem, goodsmovementtype, material,
     quantityinbaseunit, plant, storagelocation, supplier, materialbaseunit
  FROM i_materialdocumentitem_2 AS a
  WHERE a~goodsmovementtype IN ('Y17', 'X35')
        AND a~material IN @ir_material
        AND a~supplier IN @ir_vendor
        AND a~plant IN @ir_plant
        AND a~storagelocation IN @ir_sloc
        AND a~postingdate <= @ir_dateto
        AND a~postingdate >= @ir_datefr
    AND NOT EXISTS (
      SELECT 1 FROM i_materialdocumentitem_2 AS b
      WHERE b~goodsmovementtype IN ('Y18', 'X36')
      AND b~reversedmaterialdocument = a~materialdocument
      AND b~material = a~material
    )
  INTO TABLE @DATA(lt_matdoc).

    LOOP AT lt_matdoc INTO DATA(ls_matdoc).
      CLEAR ls_dtl.
      ls_dtl-ct01 = ls_matdoc-MaterialDocumentYear.
      ls_dtl-ct02 = ls_matdoc-PostingDate.
      ls_dtl-ct03 = ls_matdoc-MaterialDocument.
      ls_dtl-ct04 = ls_matdoc-MaterialDocumentItem.
      ls_dtl-ct05 = ls_matdoc-GoodsMovementType.
      ls_dtl-ct06 = ls_matdoc-Material.
      IF ls_matdoc-goodsmovementtype = 'Y17'.
        ls_dtl-ct07 = ls_matdoc-quantityinbaseunit.
      ELSEIF ls_matdoc-goodsmovementtype = 'X35'.
        ls_dtl-ct07 = ls_matdoc-quantityinbaseunit * -1.
      ENDIF.
*        ls_dtl-ct07 = ls_matdoc-quantityinbaseunit.
      ls_dtl-materialbaseunit = ls_matdoc-MaterialBaseUnit.
      ls_dtl-ct08 = ls_matdoc-plant.
      ls_dtl-ct09 = ls_matdoc-StorageLocation.
      ls_dtl-ct10 = ls_matdoc-supplier.
      SELECT SINGLE businesspartnerfullname
FROM i_businesspartner
WHERE businesspartner = @ls_matdoc-Supplier
INTO @ls_dtl-ct11.

        select single MaterialDocumentHeaderText
        from I_MATERIALDOCUMENTHEADER_2
        where materialdocument = @ls_matdoc-MaterialDocumentItem
        into @ls_dtl-ct12.

      APPEND ls_dtl TO e_nxt_sot_dtl.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

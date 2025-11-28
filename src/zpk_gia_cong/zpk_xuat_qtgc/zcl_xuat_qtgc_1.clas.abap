CLASS zcl_xuat_qtgc_1 DEFINITION
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

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_XUAT_QTGC_1 IMPLEMENTATION.


METHOD if_rap_query_provider~select.
  DATA: lt_data         TYPE TABLE OF zc_xuat_qtgc,
        ls_data         TYPE zc_xuat_qtgc,

        lv_period       TYPE RANGE OF zr_tbdcgc_hdr-zper,
        lv_company_code TYPE RANGE OF zr_tbdcgc_hdr-bukrs,
        lv_lan          TYPE RANGE OF zr_tbdcgc_hdr-lan,
        lv_ngaylapbang  TYPE RANGE OF zr_tbdcgc_hdr-ngaylapbang,
        lv_gc_id        TYPE RANGE OF zr_tbdcgc_hdr-Supplier,
        lv_gc_name      TYPE RANGE OF zr_tbdcgc_hdr-SearchTerm1.

  DATA: ir_supplier TYPE tt_ranges.

  " Get paging parameters
  DATA(lo_paging) = io_request->get_paging( ).
  DATA(lv_offset) = lo_paging->get_offset( ).
  DATA(lv_page_size) = lo_paging->get_page_size( ).
  DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
                              THEN 0
                              ELSE lv_page_size ).

  DATA(lo_filter) = io_request->get_filter( ).

  TRY.
      DATA(lt_filters) = lo_filter->get_as_ranges( ).
    CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_range).
      " Handle error
  ENDTRY.

  LOOP AT lt_filters INTO DATA(ls_filters).
    CASE ls_filters-name.
      WHEN 'ZPER'.
        MOVE-CORRESPONDING ls_filters-range TO lv_period.
      WHEN 'LAN'.
        MOVE-CORRESPONDING ls_filters-range TO lv_lan.
      WHEN 'BUKRS'.
        MOVE-CORRESPONDING ls_filters-range TO lv_company_code.
      WHEN 'GIACONG_ID'.
        MOVE-CORRESPONDING ls_filters-range TO lv_gc_id.
        MOVE-CORRESPONDING ls_filters-range TO ir_supplier.
      WHEN 'GIACONG_NAME'.
        MOVE-CORRESPONDING ls_filters-range TO lv_gc_name.
      WHEN 'DATELAPBANG'.
        MOVE-CORRESPONDING ls_filters-range TO lv_ngaylapbang.
    ENDCASE.
  ENDLOOP.

  SELECT *
  FROM zr_tbdcgc_hdr
  WHERE zper IN @lv_period
  AND lan IN @lv_lan
  AND Bukrs IN @lv_company_code
  AND supplier IN @lv_gc_id
  AND ngaylapbang IN @lv_ngaylapbang
  INTO TABLE @DATA(lt_tbdcgc_hdr).

  IF sy-subrc = 0.
    SELECT *
    FROM zr_tbdcgc_dtl
    FOR ALL ENTRIES IN @lt_tbdcgc_hdr
    WHERE HdrID = @lt_tbdcgc_hdr-HdrID
    INTO TABLE @DATA(lt_tbdcgc_dtl).

    DATA: tt_c_nxt TYPE TABLE OF zc_bc_xnt.
    DATA: lv_datefr TYPE zde_date,
          lv_dateto TYPE zde_date.

    READ TABLE lv_period INTO DATA(ls_period) INDEX 1.
    READ TABLE lv_ngaylapbang INTO DATA(ls_ngaylapbang) INDEX 1.

    lv_datefr = ls_period-low && '01'.
    lv_dateto = ls_ngaylapbang-low.

    CALL METHOD zcl_xnt=>get_xnt
      EXPORTING
        i_datefr    = lv_datefr
        i_dateto    = lv_dateto
        ir_supplier = ir_supplier
      IMPORTING
        e_nxt       = tt_c_nxt.

    LOOP AT tt_c_nxt ASSIGNING FIELD-SYMBOL(<fs_tt_c_nxt>).
      SELECT SINGLE ProductDescription FROM I_ProductDescription
        WHERE Product = @<fs_tt_c_nxt>-material
        INTO @<fs_tt_c_nxt>-ProductDescription.

      SELECT SINGLE SearchTerm1 FROM I_BusinessPartner
        WHERE BusinessPartner = @<fs_tt_c_nxt>-supplier
        INTO @<fs_tt_c_nxt>-SupplierName.

      SELECT SINGLE Product FROM i_productionorderitem
        WHERE ProductionOrder = @<fs_tt_c_nxt>-orderid
        INTO @<fs_tt_c_nxt>-BTPSauMay.

      SELECT SINGLE * FROM zc_Product
        WHERE Product = @<fs_tt_c_nxt>-material
        INTO @DATA(ls_product).
      IF sy-subrc = 0.
        <fs_tt_c_nxt>-productgroup = ls_product-ProductGroup.
        <fs_tt_c_nxt>-ProductGroupName = ls_product-ProductGroupName.
      ENDIF.

      SELECT SINGLE ProductName FROM i_producttext
        WHERE Product = @<fs_tt_c_nxt>-BTPSauMay
        INTO @<fs_tt_c_nxt>-TenBTPSauMay.
    ENDLOOP.

    SORT tt_c_nxt BY orderid ASCENDING material ASCENDING supplier ASCENDING.
  ELSE.
    " table empty return message
  ENDIF.

  LOOP AT lt_tbdcgc_hdr INTO DATA(ls_tbdcgc_hdr).
    CLEAR ls_data.
    ls_data-hdr_id = ls_tbdcgc_hdr-HdrID.
    ls_data-zper = ls_tbdcgc_hdr-Zper.
    ls_data-lan = ls_tbdcgc_hdr-lan.
    ls_data-bukrs = ls_tbdcgc_hdr-Bukrs.
    ls_data-datelapbang = ls_tbdcgc_hdr-ngaylapbang.
    ls_data-giacong_id = ls_tbdcgc_hdr-Supplier.
    ls_data-giacongname = ls_tbdcgc_hdr-SearchTerm1.

    DATA(lv_has_dtl) = abap_false.

    LOOP AT lt_tbdcgc_dtl INTO DATA(ls_tbdcgc_dtl)
      WHERE hdrid = ls_tbdcgc_hdr-hdrid.

      lv_has_dtl = abap_true.

      ls_data-trutien_btp = ls_tbdcgc_hdr-Ct02.
      ls_data-tile_btp = ls_tbdcgc_hdr-Ct021.
      ls_data-tongtien_bs = ls_tbdcgc_hdr-ct04.
      ls_data-vobao = ls_tbdcgc_hdr-ct05.
      ls_data-congtrukhac = ls_tbdcgc_hdr-ct06.
      ls_data-truloibb = ls_tbdcgc_hdr-Ct07.
      ls_data-hotro = ls_tbdcgc_hdr-ct08.
      ls_data-tongcongno = ls_tbdcgc_hdr-ct09.
      ls_data-chenhlechno = ls_tbdcgc_hdr-ct10.
      ls_data-tongtienthanhtoan = ls_tbdcgc_hdr-ct11.
      ls_data-sotienxhd = ls_tbdcgc_hdr-ct12.
      ls_data-congnocanxuat = ls_tbdcgc_hdr-ct13.
      ls_data-chitietcongtru = ls_tbdcgc_hdr-ctcongtrukhac.

      ls_data-datenhaphang = ls_tbdcgc_dtl-Ngaynhaphang.
      ls_data-sobb = ls_tbdcgc_dtl-Sobbgc.
      ls_data-sopo = ls_tbdcgc_dtl-Sopo.
      ls_data-saleorder = ls_tbdcgc_dtl-SalesOrder.
      ls_data-lenhsanxuat = ls_tbdcgc_dtl-OrderID.
      ls_data-material_id = ls_tbdcgc_dtl-Material.
      ls_data-production_name = ls_tbdcgc_dtl-ProductDescription.
      ls_data-dc_ct09 = ls_tbdcgc_dtl-Ct09.
      ls_data-dc_ct10 = ls_tbdcgc_dtl-Ct10.
      ls_data-dc_ct11 = ls_tbdcgc_dtl-ct11.
      ls_data-dc_ct12 = ls_tbdcgc_dtl-ct12.
      ls_data-dc_ct13 = ls_tbdcgc_dtl-Ct13.
      ls_data-dc_ct14 = ls_tbdcgc_dtl-ct14.
      ls_data-dc_ct15 = ls_tbdcgc_dtl-ct15.
      ls_data-dc_ct16 = ls_tbdcgc_dtl-ct16.
      ls_data-dc_ct17 = ls_tbdcgc_dtl-ct17.
      ls_data-dc_ct18 = ls_tbdcgc_dtl-ct18.
      ls_data-dc_ct19 = ls_tbdcgc_dtl-ct18.
      ls_data-dc_ct20 = ls_tbdcgc_dtl-ct20.
      ls_data-dc_ct21 = ls_tbdcgc_dtl-ct21.
      ls_data-dc_ct22 = ls_tbdcgc_dtl-ct22.
      ls_data-dc_ct23 = ls_tbdcgc_dtl-ct23.
      ls_data-dc_ct24 = ls_tbdcgc_dtl-ct24.
      ls_data-dc_ct25 = ls_tbdcgc_dtl-ct25.
      ls_data-dc_ct26 = ls_tbdcgc_dtl-ct26.
      ls_data-dc_ct27 = ls_tbdcgc_dtl-ct27.
      ls_data-dc_ct28 = ls_tbdcgc_dtl-ct28.
      ls_data-dc_ct29 = ls_tbdcgc_dtl-ct29.
      ls_data-dc_ct30 = ls_tbdcgc_dtl-ct30.
      ls_data-dc_ct31 = ls_tbdcgc_dtl-ct31.
      ls_data-dc_ct32 = ls_tbdcgc_dtl-ct32.
      ls_data-dc_ct33 = ls_tbdcgc_dtl-ct33.
      ls_data-ghi_chu = ls_tbdcgc_dtl-ghichu.

      " Xử lý XNT data
      DATA(lv_found_xnt) = abap_false.

      LOOP AT tt_c_nxt INTO DATA(ls_xnt)
        WHERE orderid = ls_tbdcgc_dtl-orderid
          AND supplier = ls_tbdcgc_hdr-supplier.

        lv_found_xnt = abap_true.

        ls_data-mahang = ls_xnt-material.
        ls_data-tenhang = ls_xnt-ProductDescription.
        ls_data-materialgroup = ls_xnt-productgroup.
        ls_data-materialgroupname = ls_xnt-ProductGroupName.
        ls_data-plant = ls_xnt-plant.
        ls_data-xnt_supplier = ls_xnt-supplier.
        ls_data-xnt_SupplierName = ls_xnt-SupplierName.

        ls_data-tondau = ls_xnt-DauKy.
        ls_data-xuattky = ls_xnt-XuatTKy.
        ls_data-nhaptky = ls_xnt-NhapTKy.
        ls_data-btpdanhapve = ls_xnt-SLBTPNVLDaNhapVe.
        ls_data-nhaptrabtpdat = ls_xnt-NhapTraBTPDat.
        ls_data-btploi = ls_xnt-btploi.
        ls_data-btploicty = ls_xnt-NhapTraBTPLoiCTy.
        ls_data-btploigc = ls_xnt-NhapTraBTPLoiGC.
        ls_data-btpthieu = ls_xnt-NhapTruBTPThieu.
        ls_data-toncuoi = ls_xnt-TonCuoi.
        ls_data-mbaseunit = ls_xnt-materialbaseunit.
        ls_data-donhangvet = ls_xnt-DonHangVet.
        ls_data-BTPSauMay = ls_xnt-BTPSauMay.
        ls_data-TenBTPSauMay = ls_xnt-TenBTPSauMay.
        ls_data-SalesOrder = ls_xnt-SalesOrder.

        APPEND ls_data TO lt_data.
      ENDLOOP.

      IF lv_found_xnt = abap_false.
        APPEND ls_data TO lt_data.
      ENDIF.

    ENDLOOP.

    IF lv_has_dtl = abap_false.
      APPEND ls_data TO lt_data.
    ENDIF.

  ENDLOOP.

  " Get total count before paging
  DATA(lv_total_records) = lines( lt_data ).

  " Sorting
  DATA(sort_order) = VALUE abap_sortorder_tab(
    FOR sort_element IN io_request->get_sort_elements( )
    ( name = sort_element-element_name descending = sort_element-descending ) ).
  IF sort_order IS NOT INITIAL.
    SORT lt_data BY (sort_order).
  ENDIF.

  " Apply paging - extract only the requested page
  IF lv_max_rows > 0.
    DATA: lt_paged_data TYPE TABLE OF zc_xuat_qtgc.
    DATA: lv_from TYPE i,
          lv_to   TYPE i.

    lv_from = lv_offset + 1.
    lv_to = lv_offset + lv_page_size.

    IF lv_to > lines( lt_data ).
  lv_to = lines( lt_data ).
ENDIF.

    " Extract the page subset
    LOOP AT lt_data INTO ls_data FROM lv_from TO lv_to.
      APPEND ls_data TO lt_paged_data.
    ENDLOOP.

    " Return only the paged data
    IF io_request->is_data_requested( ).
      io_response->set_data( it_data = lt_paged_data ).
    ENDIF.
  ELSE.
    " Return all data if unlimited
    IF io_request->is_data_requested( ).
      io_response->set_data( it_data = lt_data ).
    ENDIF.
  ENDIF.

  " Return total count if requested
  IF io_request->is_total_numb_of_rec_requested( ).
    io_response->set_total_number_of_records( lines( lt_data ) ).
  ENDIF.
ENDMETHOD.
ENDCLASS.

CLASS zcl_xuat_qtgc_dongia DEFINITION
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



CLASS ZCL_XUAT_QTGC_DONGIA IMPLEMENTATION.


METHOD if_rap_query_provider~select.
  DATA: lt_data         TYPE TABLE OF zc_xuat_qtgc_dongia,
        ls_data         TYPE zc_xuat_qtgc_dongia,

        lv_period       TYPE RANGE OF zr_tbdcgc_hdr-zper,
        lv_company_code TYPE RANGE OF zr_tbdcgc_hdr-bukrs,
        lv_lan          TYPE RANGE OF zr_tbdcgc_hdr-lan,
        lv_ngaylapbang  TYPE RANGE OF zr_tbdcgc_hdr-ngaylapbang,
        lv_gc_id        TYPE RANGE OF zr_tbdcgc_hdr-supplier,
        lv_gc_name      TYPE RANGE OF zr_tbdcgc_hdr-searchterm1.

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
    AND bukrs IN @lv_company_code
    AND supplier IN @lv_gc_id
    AND ngaylapbang IN @lv_ngaylapbang
  INTO TABLE @DATA(lt_tbdcgc_hdr).

  IF sy-subrc = 0.
    SELECT *
    FROM zr_tbdcgc_dtl
    FOR ALL ENTRIES IN @lt_tbdcgc_hdr
    WHERE hdrid = @lt_tbdcgc_hdr-hdrid
    INTO TABLE @DATA(lt_tbdcgc_dtl).
  ENDIF.

  LOOP AT lt_tbdcgc_hdr INTO DATA(ls_tbdcgc_hdr).
    CLEAR ls_data.
    ls_data-hdr_id = ls_tbdcgc_hdr-hdrid.
    ls_data-zper = ls_tbdcgc_hdr-zper.
    ls_data-lan = ls_tbdcgc_hdr-lan.
    ls_data-bukrs = ls_tbdcgc_hdr-bukrs.
    ls_data-datelapbang = ls_tbdcgc_hdr-ngaylapbang.
    ls_data-giacong_id = ls_tbdcgc_hdr-supplier.
    ls_data-giacongname = ls_tbdcgc_hdr-searchterm1.

    DATA(lv_has_dtl) = abap_false.

    LOOP AT lt_tbdcgc_dtl INTO DATA(ls_tbdcgc_dtl)
      WHERE hdrid = ls_tbdcgc_hdr-hdrid.

      lv_has_dtl = abap_true.

      ls_data-trutien_btp = ls_tbdcgc_hdr-ct02.
      ls_data-tile_btp = ls_tbdcgc_hdr-ct021.
      ls_data-tongtien_bs = ls_tbdcgc_hdr-ct04.
      ls_data-vobao = ls_tbdcgc_hdr-ct05.
      ls_data-congtrukhac = ls_tbdcgc_hdr-ct07.
      ls_data-hotro = ls_tbdcgc_hdr-ct08.
      ls_data-tongcongno = ls_tbdcgc_hdr-ct09.
      ls_data-chenhlechno = ls_tbdcgc_hdr-ct10.
      ls_data-tongtienthanhtoan = ls_tbdcgc_hdr-ct11.
      ls_data-sotienxhd = ls_tbdcgc_hdr-ct12.
      ls_data-congnocanxuat = ls_tbdcgc_hdr-ct13.
      ls_data-chitietcongtru = ls_tbdcgc_hdr-ctcongtrukhac.

      ls_data-datenhaphang = ls_tbdcgc_dtl-ngaynhaphang.
      ls_data-sobb = ls_tbdcgc_dtl-sobbgc.
      ls_data-sopo = ls_tbdcgc_dtl-sopo.
      ls_data-saleorder = ls_tbdcgc_dtl-salesorder.
      ls_data-lenhsanxuat = ls_tbdcgc_dtl-orderid.
      ls_data-material_id = ls_tbdcgc_dtl-material.
      ls_data-production_name = ls_tbdcgc_dtl-productdescription.

      ls_data-dc_ct09 = ls_tbdcgc_dtl-ct09.
      ls_data-dc_ct10 = ls_tbdcgc_dtl-ct10.
      ls_data-dc_ct11 = ls_tbdcgc_dtl-ct11.
      ls_data-dc_ct12 = ls_tbdcgc_dtl-ct12.
      ls_data-dc_ct13 = ls_tbdcgc_dtl-ct13.
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

      SELECT PurchaseOrderItem
        FROM I_PurchaseOrderItemAPI01
        WHERE PurchaseOrder = @ls_tbdcgc_dtl-sopo
          AND PurchasingDocumentDeletionCode = ''
        INTO TABLE @DATA(lt_poitems).

      IF sy-subrc = 0.
        LOOP AT lt_poitems INTO DATA(ls_poitem).
          ls_data-poitem = ls_poitem-purchaseorderitem.

          CLEAR ls_data-congdoan.
          SELECT SINGLE PlainLongText
            FROM I_PurchaseOrderItemNoteTP_2
            WHERE PurchaseOrder = @ls_tbdcgc_dtl-sopo
              AND PurchaseOrderItem = @ls_poitem-purchaseorderitem
              AND TextObjectType = 'F01'
              AND Language = 'E'
            INTO @ls_data-congdoan.

          IF sy-subrc <> 0.
            SELECT SINGLE PurchaseOrderItemText
              FROM I_PurchaseOrderItemAPI01
              WHERE PurchaseOrder = @ls_tbdcgc_dtl-sopo
                AND PurchaseOrderItem = @ls_poitem-purchaseorderitem
              INTO @ls_data-congdoan.
          ENDIF.

          SELECT SINGLE NetPriceAmount
            FROM ZI_PurchaseOrderItemAPI01
            WHERE PurchaseOrder = @ls_tbdcgc_dtl-sopo
              AND PurchaseOrderItem = @ls_poitem-purchaseorderitem
            INTO @DATA(lw_NetPriceAmount).

          IF sy-subrc = 0.
            ls_data-dongia = lw_NetPriceAmount * 100.
          ELSE.
            CLEAR ls_data-dongia.
          ENDIF.

          APPEND ls_data TO lt_data.
        ENDLOOP.
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
    DATA: lt_paged_data TYPE TABLE OF zc_xuat_qtgc_dongia.
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

CLASS zcl_xuat_qtgc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,
           tt_ranges TYPE TABLE OF ty_range_option.

    INTERFACES if_rap_query_provider.

  PRIVATE SECTION.
    METHODS:
      query_header
        IMPORTING io_request  TYPE REF TO if_rap_query_request
                  io_response TYPE REF TO if_rap_query_response
        RAISING   cx_rap_query_provider.

    TYPES: tt_xuat_qtgc_dtl    TYPE TABLE OF zi_xuat_qtgc_dtl,
           tt_qtgc_xnt         TYPE TABLE OF zi_qtgc_xnt,
           tt_xuat_qtgc_dongia TYPE TABLE OF zi_xuat_qtgc_dongia.

    METHODS convert_line_items_to_json
      IMPORTING it_line_items  TYPE tt_xuat_qtgc_dtl
      RETURNING VALUE(rv_json) TYPE string.

    METHODS convert_line_items_to_json_2
      IMPORTING it_line_items  TYPE tt_qtgc_xnt
      RETURNING VALUE(rv_json) TYPE string.

    METHODS convert_line_items_to_json_3
      IMPORTING it_line_items  TYPE tt_xuat_qtgc_dongia
      RETURNING VALUE(rv_json) TYPE string.
ENDCLASS.



CLASS ZCL_XUAT_QTGC IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    TRY.
        CASE io_request->get_entity_id( ).
          WHEN 'ZC_XUAT_QTGC_1'.        " Header entity
            query_header( io_request = io_request io_response = io_response ).
          WHEN OTHERS.
            " Không xử lý entity khác
            RETURN.
        ENDCASE.

      CATCH cx_rap_query_provider INTO DATA(lx_query).
        RAISE EXCEPTION lx_query.
    ENDTRY.
  ENDMETHOD.


  METHOD query_header.
    DATA: lt_header TYPE TABLE OF zc_xuat_qtgc_1,
          ls_header TYPE zc_xuat_qtgc_1.

    DATA: ir_supplier TYPE tt_ranges.

    DATA: lt_lineitemjson  TYPE TABLE OF zi_xuat_qtgc_dtl,
          ls_lineitemjson  TYPE zi_xuat_qtgc_dtl,

          lt_lineitemjson2 TYPE TABLE OF zi_qtgc_xnt,
          ls_lineitemjson2 TYPE zi_qtgc_xnt,

          lt_lineitemjson3 TYPE TABLE OF zi_xuat_qtgc_dongia,
          ls_lineitemjson3 TYPE zi_xuat_qtgc_dongia.

    " Khai báo range filter
    DATA: lv_period       TYPE RANGE OF zr_tbdcgc_hdr-zper,
          lv_company_code TYPE RANGE OF zr_tbdcgc_hdr-bukrs,
          lv_lan          TYPE RANGE OF zr_tbdcgc_hdr-lan,
          lv_ngaylapbang  TYPE RANGE OF zr_tbdcgc_hdr-ngaylapbang,
          lv_gc_id        TYPE RANGE OF zr_tbdcgc_hdr-supplier,
          lv_hdr_id       TYPE RANGE OF zr_tbdcgc_hdr-hdrid.

    " Get paging parameters
    DATA(lo_paging) = io_request->get_paging( ).
    DATA(lv_offset) = lo_paging->get_offset( ).
    DATA(lv_page_size) = lo_paging->get_page_size( ).
    DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
                                THEN 0
                                ELSE lv_page_size ).

    " Lấy filter từ request
    DATA(lo_filter) = io_request->get_filter( ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.

    " Parse filters
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
        WHEN 'DATELAPBANG'.
          MOVE-CORRESPONDING ls_filters-range TO lv_ngaylapbang.
        WHEN 'HDR_ID'.
          MOVE-CORRESPONDING ls_filters-range TO lv_hdr_id.
      ENDCASE.
    ENDLOOP.

    " Select dữ liệu header
    SELECT *
      FROM zr_tbdcgc_hdr
      WHERE zper IN @lv_period
        AND lan IN @lv_lan
        AND bukrs IN @lv_company_code
        AND supplier IN @lv_gc_id
        AND ngaylapbang IN @lv_ngaylapbang
        AND hdrid IN @lv_hdr_id
      INTO TABLE @DATA(lt_tbdcgc_hdr)
      UP TO @lv_max_rows ROWS.

    " Build output
    LOOP AT lt_tbdcgc_hdr INTO DATA(ls_hdr).
      ls_header = VALUE #(
        hdr_id = ls_hdr-hdrid
        zper = ls_hdr-zper
        datelapbang = ls_hdr-ngaylapbang
        lan = ls_hdr-lan
        bukrs = ls_hdr-bukrs
        giacong_id = ls_hdr-supplier
        giacongname = ls_hdr-searchterm1
        trutien_btp = ls_hdr-ct02
        tile_btp = ls_hdr-ct021
        tongtien_bs = ls_hdr-ct04
        vobao = ls_hdr-ct05
        congtrukhac = ls_hdr-ct06
        truloibb = ls_hdr-ct07
        hotro = ls_hdr-ct08
        tongcongno = ls_hdr-ct09
        chenhlechno = ls_hdr-ct10
        tongtienthanhtoan = ls_hdr-ct11
        sotienxhd = ls_hdr-ct12
        congnocanxuat = ls_hdr-ct13
        chitietcongtru = ls_hdr-ctcongtrukhac
      ).
      APPEND ls_header TO lt_header.
      CLEAR ls_header.
    ENDLOOP.

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

    SELECT *
        FROM zr_tbdcgc_dtl
        FOR ALL ENTRIES IN @lt_tbdcgc_hdr
        WHERE HdrID = @lt_tbdcgc_hdr-HdrID
        INTO TABLE @DATA(lt_tbdcgc_dtl).


    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
      CLEAR: lt_lineitemjson, lt_lineitemjson2, lt_lineitemjson3.


      LOOP AT lt_tbdcgc_dtl INTO DATA(ls_tbdcgc_dtl)
            WHERE hdrid = <fs_header>-hdr_id.
        ls_lineitemjson-datenhaphang = ls_tbdcgc_dtl-Ngaynhaphang.
        ls_lineitemjson-sobb = ls_tbdcgc_dtl-Sobbgc.
        ls_lineitemjson-sopo = ls_tbdcgc_dtl-Sopo.
        ls_lineitemjson-saleorder = ls_tbdcgc_dtl-SalesOrder.
        ls_lineitemjson-lenhsanxuat = ls_tbdcgc_dtl-OrderID.
        ls_lineitemjson-material_id = ls_tbdcgc_dtl-Material.
        ls_lineitemjson-production_name = ls_tbdcgc_dtl-ProductDescription.
        ls_lineitemjson-dc_ct09 = ls_tbdcgc_dtl-Ct09.
        ls_lineitemjson-dc_ct10 = ls_tbdcgc_dtl-Ct10.
        ls_lineitemjson-dc_ct11 = ls_tbdcgc_dtl-ct11.
        ls_lineitemjson-dc_ct12 = ls_tbdcgc_dtl-ct12.
        ls_lineitemjson-dc_ct13 = ls_tbdcgc_dtl-Ct13.
        ls_lineitemjson-dc_ct14 = ls_tbdcgc_dtl-ct14.
        ls_lineitemjson-dc_ct15 = ls_tbdcgc_dtl-ct15.
        ls_lineitemjson-dc_ct16 = ls_tbdcgc_dtl-ct16.
        ls_lineitemjson-dc_ct17 = ls_tbdcgc_dtl-ct17.
        ls_lineitemjson-dc_ct18 = ls_tbdcgc_dtl-ct18.
        ls_lineitemjson-dc_ct19 = ls_tbdcgc_dtl-ct18.
        ls_lineitemjson-dc_ct20 = ls_tbdcgc_dtl-ct20.
        ls_lineitemjson-dc_ct21 = ls_tbdcgc_dtl-ct21.
        ls_lineitemjson-dc_ct22 = ls_tbdcgc_dtl-ct22.
        ls_lineitemjson-dc_ct23 = ls_tbdcgc_dtl-ct23.
        ls_lineitemjson-dc_ct24 = ls_tbdcgc_dtl-ct24.
        ls_lineitemjson-dc_ct25 = ls_tbdcgc_dtl-ct25.
        ls_lineitemjson-dc_ct26 = ls_tbdcgc_dtl-ct26.
        ls_lineitemjson-dc_ct27 = ls_tbdcgc_dtl-ct27.
        ls_lineitemjson-dc_ct28 = ls_tbdcgc_dtl-ct28.
        ls_lineitemjson-dc_ct29 = ls_tbdcgc_dtl-ct29.
        ls_lineitemjson-dc_ct30 = ls_tbdcgc_dtl-ct30.
        ls_lineitemjson-dc_ct31 = ls_tbdcgc_dtl-ct31.
        ls_lineitemjson-dc_ct32 = ls_tbdcgc_dtl-ct32.
        ls_lineitemjson-dc_ct33 = ls_tbdcgc_dtl-ct33.
        ls_lineitemjson-ghi_chu = ls_tbdcgc_dtl-ghichu.

        APPEND ls_lineitemjson TO lt_lineitemjson.
        CLEAR ls_lineitemjson.
      ENDLOOP.

      <fs_header>-lineitemsjson = convert_line_items_to_json( lt_lineitemjson ).

      DATA(lt_tbdcgc_dtl_temp_2) = lt_tbdcgc_dtl.
      DELETE lt_tbdcgc_dtl_temp_2 WHERE hdrid <> <fs_header>-hdr_id.
      DELETE ADJACENT DUPLICATES FROM lt_tbdcgc_dtl_temp_2 COMPARING OrderID.

      LOOP AT lt_tbdcgc_dtl_temp_2 INTO DATA(ls_tbdcgc_dtl_temp_2).
    LOOP AT tt_c_nxt INTO DATA(ls_xnt)
        WHERE supplier = <fs_header>-giacong_id
        AND orderid = ls_tbdcgc_dtl_temp_2-orderid.


        ls_lineitemjson2-mahang = ls_xnt-material.
        ls_lineitemjson2-tenhang = ls_xnt-ProductDescription.
        ls_lineitemjson2-materialgroup = ls_xnt-productgroup.
        ls_lineitemjson2-materialgroupname = ls_xnt-ProductGroupName.
        ls_lineitemjson2-plant = ls_xnt-plant.
        ls_lineitemjson2-xnt_supplier = ls_xnt-supplier.
        ls_lineitemjson2-xnt_SupplierName = ls_xnt-SupplierName.
        ls_lineitemjson2-tondau = ls_xnt-DauKy.
        ls_lineitemjson2-xuattky = ls_xnt-XuatTKy.
        ls_lineitemjson2-xnt_lenhsanxuat = ls_xnt-orderid.
        ls_lineitemjson2-nhaptky = ls_xnt-NhapTKy.
        ls_lineitemjson2-btpdanhapve = ls_xnt-SLBTPNVLDaNhapVe.
        ls_lineitemjson2-nhaptrabtpdat = ls_xnt-NhapTraBTPDat.
        ls_lineitemjson2-btploi = ls_xnt-btploi.
        ls_lineitemjson2-btploicty = ls_xnt-NhapTraBTPLoiCTy.
        ls_lineitemjson2-btploigc = ls_xnt-NhapTraBTPLoiGC.
        ls_lineitemjson2-btpthieu = ls_xnt-NhapTruBTPThieu.
        ls_lineitemjson2-toncuoi = ls_xnt-TonCuoi.
        ls_lineitemjson2-mbaseunit = ls_xnt-materialbaseunit.
        ls_lineitemjson2-donhangvet = ls_xnt-DonHangVet.
        ls_lineitemjson2-BTPSauMay = ls_xnt-BTPSauMay.
        ls_lineitemjson2-tontruocvet = ls_xnt-ct11c.
        ls_lineitemjson2-TenBTPSauMay = ls_xnt-TenBTPSauMay.
        ls_lineitemjson2-SalesOrder = ls_xnt-SalesOrder.

        APPEND ls_lineitemjson2 TO lt_lineitemjson2.
        CLEAR ls_lineitemjson2.
      ENDLOOP.
      endloop.

      <fs_header>-lineitemsjson2 = convert_line_items_to_json_2( lt_lineitemjson2 ).

      DATA(lt_tbdcgc_dtl_temp) = lt_tbdcgc_dtl.
      DELETE lt_tbdcgc_dtl_temp WHERE hdrid <> <fs_header>-hdr_id.
      DELETE ADJACENT DUPLICATES FROM lt_tbdcgc_dtl_temp COMPARING sopo.

      IF lt_tbdcgc_dtl_temp IS NOT INITIAL.
        SELECT PurchaseOrderItem, purchaseorder
          FROM I_PurchaseOrderItemAPI01
          FOR ALL ENTRIES IN @lt_tbdcgc_dtl_temp
          WHERE PurchaseOrder = @lt_tbdcgc_dtl_temp-sopo
          AND PurchasingDocumentDeletionCode = ''
          INTO TABLE @DATA(lt_poitems).
      ENDIF.

      LOOP AT lt_tbdcgc_dtl_temp INTO DATA(ls_tbdcgc_dtl_temp)
       WHERE hdrid = <fs_header>-hdr_id.
        LOOP AT lt_poitems INTO DATA(ls_poitem)
        WHERE PurchaseOrder = ls_tbdcgc_dtl_temp-sopo.
          ls_lineitemjson3-poitem = ls_poitem-purchaseorderitem.
          ls_lineitemjson3-production_name = ls_tbdcgc_dtl_temp-ProductDescription.
          ls_lineitemjson3-material_id = ls_tbdcgc_dtl_temp-Material.
          ls_lineitemjson3-sopo = ls_tbdcgc_dtl_temp-sopo.

*          select SINGLE orderID
*            from I_PURORDACCOUNTASSIGNMENTAPI01
*            where PurchaseOrder = @ls_tbdcgc_dtl_temp-sopo
*            into @DATA(ls_orderID).
*
*          select Single product
*          from I_PRODUCTIONORDERITEM
*          where ProductionOrder = @ls_orderID
*          into @data(ls_productnumber).
*          ls_lineitemjson3-dongia_mahang = ls_productnumber.
*
*          select single productName
*          from I_PRODUCTTEXT
*          where Product = @ls_productnumber
*          into @ls_lineitemjson3-dongia_tenhang.

          SELECT SINGLE PlainLongText
            FROM I_PurchaseOrderItemNoteTP_2
            WHERE PurchaseOrder = @ls_tbdcgc_dtl_temp-sopo
              AND PurchaseOrderItem = @ls_poitem-purchaseorderitem
              AND TextObjectType = 'F01'
              AND Language = 'E'
            INTO @ls_lineitemjson3-congdoan.

          IF sy-subrc <> 0.
            SELECT SINGLE PurchaseOrderItemText
              FROM I_PurchaseOrderItemAPI01
              WHERE PurchaseOrder = @ls_tbdcgc_dtl_temp-sopo
                AND PurchaseOrderItem = @ls_poitem-purchaseorderitem
              INTO @ls_lineitemjson3-congdoan.
          ENDIF.

          SELECT SINGLE NetPriceAmount
            FROM ZI_PurchaseOrderItemAPI01
            WHERE PurchaseOrder = @ls_tbdcgc_dtl_temp-sopo
              AND PurchaseOrderItem = @ls_poitem-purchaseorderitem
            INTO @DATA(lw_NetPriceAmount).

          IF sy-subrc = 0.
            ls_lineitemjson3-dongia = lw_NetPriceAmount * 100.
          ELSE.
            CLEAR ls_lineitemjson3-dongia.
          ENDIF.

          APPEND ls_lineitemjson3 TO lt_lineitemjson3.
          CLEAR ls_lineitemjson3.
        ENDLOOP.
      ENDLOOP.

      <fs_header>-lineitemsjson3 = convert_line_items_to_json_3( lt_lineitemjson3 ).

    ENDLOOP.


    " Get total count before paging
    DATA(lv_total_records) = lines( lt_header ).

    " Sort theo request
    DATA(sort_order) = VALUE abap_sortorder_tab(
      FOR sort_element IN io_request->get_sort_elements( )
      ( name = sort_element-element_name descending = sort_element-descending ) ).
    IF sort_order IS NOT INITIAL.
      SORT lt_header BY (sort_order).
    ENDIF.

    " Apply paging - extract only the requested page
    IF lv_max_rows > 0.
      DATA: lt_paged_data TYPE TABLE OF zc_xuat_qtgc_1.
      DATA: lv_from TYPE i,
            lv_to   TYPE i.

      lv_from = lv_offset + 1.
      lv_to = lv_offset + lv_page_size.

      IF lv_to > lines( lt_header ).
        lv_to = lines( lt_header ).
      ENDIF.

      " Extract the page subset
      LOOP AT lt_header INTO ls_header FROM lv_from TO lv_to.
        APPEND ls_header TO lt_paged_data.
      ENDLOOP.

      " Return only the paged data
      IF io_request->is_data_requested( ).
        io_response->set_data( it_data = lt_paged_data ).
      ENDIF.
    ELSE.
      " Return all data if unlimited
      IF io_request->is_data_requested( ).
        io_response->set_data( it_data = lt_header ).
      ENDIF.
    ENDIF.

    " Return total count if requested
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_header ) ).
    ENDIF.
  ENDMETHOD.


  METHOD convert_line_items_to_json.
    " Convert internal table to JSON string
    DATA: lo_writer TYPE REF TO cl_sxml_string_writer.

    lo_writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).

    CALL TRANSFORMATION id
      SOURCE line_items = it_line_items
      RESULT XML lo_writer.

    rv_json = cl_abap_conv_codepage=>create_in( )->convert( lo_writer->get_output( ) ).

  ENDMETHOD.


  METHOD convert_line_items_to_json_2.
    " Convert internal table to JSON string
    DATA: lo_writer TYPE REF TO cl_sxml_string_writer.

    lo_writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).

    CALL TRANSFORMATION id
      SOURCE line_items = it_line_items
      RESULT XML lo_writer.

    rv_json = cl_abap_conv_codepage=>create_in( )->convert( lo_writer->get_output( ) ).
  ENDMETHOD.


  METHOD convert_line_items_to_json_3.
    " Convert internal table to JSON string
    DATA: lo_writer TYPE REF TO cl_sxml_string_writer.

    lo_writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).

    CALL TRANSFORMATION id
      SOURCE line_items = it_line_items
      RESULT XML lo_writer.

    rv_json = cl_abap_conv_codepage=>create_in( )->convert( lo_writer->get_output( ) ).
  ENDMETHOD.
ENDCLASS.

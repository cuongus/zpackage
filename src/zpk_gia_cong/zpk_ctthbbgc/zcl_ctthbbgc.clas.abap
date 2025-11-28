CLASS zcl_ctthbbgc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA:
          gt_result            TYPE TABLE OF zc_ctthbbgc.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CTTHBBGC IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA:
      lt_result            TYPE TABLE OF zc_ctthbbgc,
      lt_data              TYPE TABLE OF zc_ctthbbgc,
      ls_data              TYPE zc_ctthbbgc,

      lv_lsx_gc            TYPE RANGE OF zr_tbbb_gc-orderid,
      lv_po_subcontracting TYPE RANGE OF zr_tbbb_gc-sopo,
      lv_so_number         TYPE RANGE OF zr_tbbb_gc-salesorder,
      lv_item_id           TYPE RANGE OF zr_tbbb_gc-material,
      lv_gc_id             TYPE RANGE OF zr_tbbb_gc-supplier,
      lv_gc_name           TYPE RANGE OF zr_tbbb_gc-suppliername,
      lv_report_no         TYPE RANGE OF zr_tbbb_gc-sobb,
      lv_import_date       TYPE RANGE OF zr_tbbb_gc-ngaynhaphang,
      lv_entry_date        TYPE RANGE OF zr_tbbb_gc-ngaynhapkho
      .

    DATA:
      lv_sum_1000 TYPE n LENGTH 10.
    .

    DATA(lo_paging) = io_request->get_paging( ).
*    DATA(lv_offset) = lo_paging->get_offset( ).

    DATA(lv_page_size) = lo_paging->get_page_size( ).
    DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                                ELSE lv_page_size ).


    DATA(lo_filter) = io_request->get_filter( ).

    DATA(lo_aggregation) = io_request->get_aggregation( ).

    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_range).
        " Handle error
    ENDTRY.

    LOOP AT lt_filters INTO DATA(ls_filters).
      CASE ls_filters-name.
        WHEN 'LSX_GC'.
          MOVE-CORRESPONDING ls_filters-range TO lv_lsx_gc.
        WHEN 'PO_SUBCONTRACTING'.
          MOVE-CORRESPONDING ls_filters-range TO lv_po_subcontracting.
        WHEN 'SO_NUMBER'.
          MOVE-CORRESPONDING ls_filters-range TO lv_so_number.
        WHEN 'ITEM_ID'.
          MOVE-CORRESPONDING ls_filters-range TO lv_item_id.
        WHEN 'GC_ID'.
          MOVE-CORRESPONDING ls_filters-range TO lv_gc_id.
        WHEN 'GC_NAME'.
          MOVE-CORRESPONDING ls_filters-range TO lv_gc_name.
        WHEN 'REPORT_NO'.
          MOVE-CORRESPONDING ls_filters-range TO lv_report_no.
        WHEN 'IMPORT_DATE'.
          MOVE-CORRESPONDING ls_filters-range TO lv_import_date.
        WHEN 'ENTRY_DATE'.
          MOVE-CORRESPONDING ls_filters-range TO lv_entry_date.
      ENDCASE.
    ENDLOOP.

    SELECT *
        FROM zr_tbbb_gc
        WHERE OrderID IN @lv_lsx_gc
        AND SoPo IN @lv_po_subcontracting
        AND SalesOrder IN @lv_so_number
        AND Material IN @lv_item_id
        AND Supplier IN @lv_gc_id
        AND SupplierName IN @lv_gc_name
        AND SoBb IN @lv_report_no
        AND NgayNhapHang IN @lv_import_date
        AND NgayNhapKho IN @lv_entry_date
        INTO TABLE @DATA(lt_tbbb_gc).
*    SORT lt_tbbb_gc BY CreatedAt.

    IF sy-subrc = 0.
      SELECT *
          FROM zr_tbgc_loi
          FOR ALL ENTRIES IN @lt_tbbb_gc
          WHERE HdrID = @lt_tbbb_gc-HdrID
          INTO TABLE @DATA(lt_tbgc_loi).
      SORT lt_tbgc_loi BY HdrID.
    ELSE.
      " table empty return message
    ENDIF.

    LOOP AT lt_tbbb_gc INTO DATA(ls_tbbb_gc).

      ls_data-hdr_id = ls_tbbb_gc-HdrID.
      ls_data-line_num = sy-tabix.
      ls_data-lsx_gc = ls_tbbb_gc-OrderID.
      ls_data-po_Subcontracting = ls_tbbb_gc-SoPo.
      ls_data-company_code = ls_tbbb_gc-companycode.
      ls_data-so_number = ls_tbbb_gc-SalesOrder.

      IF ls_tbbb_gc-LoaiHang = 1.
        ls_data-item_type = 'Hàng Ống'.
      ELSEIF ls_tbbb_gc-LoaiHang = 2.
        ls_data-item_type = 'Hàng Viền'.
      ENDIF.

      ls_data-item_id = ls_tbbb_gc-Material.
      ls_data-item_desc = ls_tbbb_gc-ProductDescription.
      ls_data-gc_id = ls_tbbb_gc-Supplier.
      ls_data-gc_name = ls_tbbb_gc-SupplierName.
      ls_data-report_no = ls_tbbb_gc-SoBb.

      IF strlen( ls_tbbb_gc-NgayNhapHang ) >= 5.
        ls_data-import_date = ls_tbbb_gc-NgayNhapHang.
      ENDIF.
      IF strlen( ls_tbbb_gc-NgayNhapKho ) >= 5.
        ls_data-entry_date = ls_tbbb_gc-NgayNhapKho.
      ENDIF.
*      ls_data-entry_date = |{ ls_data-entry_date+4(2) }/{ ls_data-entry_date+6(2) }/{ ls_data-entry_date(4) }|.
*      IF ls_tbbb_gc-NgayNhapKho IS INITIAL.
*        CLEAR: ls_data-entry_date.
*      ENDIF.

      ls_data-amount_on_paper = ls_tbbb_gc-Ct12.
      ls_data-amount_check = ls_tbbb_gc-Ct13.

      ls_data-report_date_lap = ls_tbbb_gc-NgayLapBb.
      ls_data-report_date = ls_tbbb_gc-NgayTraBb.

      LOOP AT lt_tbgc_loi INTO DATA(ls_tbgc_loi) WHERE HdrID = ls_tbbb_gc-HdrID.

        IF ls_tbgc_loi-LoaiLoi = 'A'.

          CASE ls_tbgc_loi-ErrorCode.
            WHEN 1.
              ls_data-insect = ls_tbgc_loi-SlLoi.
              ls_data-tile_insect = ls_tbgc_loi-tile.
            WHEN 2.
              ls_data-dirty = ls_tbgc_loi-SlLoi.
              ls_data-tile_dirty = ls_tbgc_loi-tile.
            WHEN 3.
              ls_data-no_strap = ls_tbgc_loi-SlLoi.
              ls_data-tile_no_strap = ls_tbgc_loi-tile.
            WHEN 4.
              ls_data-bottom_edge_defect = ls_tbgc_loi-SlLoi.
              ls_data-tile_bed = ls_tbgc_loi-tile.
            WHEN 5.
              ls_data-strap_defect = ls_tbgc_loi-SlLoi.
              ls_data-tile_strap_def = ls_tbgc_loi-tile.
            WHEN 6.
              ls_data-seam_failure = ls_tbgc_loi-SlLoi.
              ls_data-tile_seam_fail = ls_tbgc_loi-tile.
            WHEN 7.
              ls_data-fabric_defects = ls_tbgc_loi-SlLoi.
              ls_data-tile_fab_def = ls_tbgc_loi-tile.
          ENDCASE.

        ELSEIF ls_tbgc_loi-LoaiLoi = 'B'.

          CASE ls_tbgc_loi-ErrorCode.
            WHEN 1.
              ls_data-light_stain = ls_tbgc_loi-SlLoi.
              ls_data-tile_light_stain = ls_tbgc_loi-tile.
            WHEN 2.
              ls_data-hem_fold_miss_4mm = ls_tbgc_loi-SlLoi.
              ls_data-tile_hem_fold_miss_4mm = ls_tbgc_loi-tile.
            WHEN 3.
              ls_data-bottom_seam_miss_4mm = ls_tbgc_loi-SlLoi.
              ls_data-tile_seam_miss_4mm = ls_tbgc_loi-tile.
            WHEN 4.
              ls_data-bottom_edge_not_meet_requi = ls_tbgc_loi-SlLoi.
              ls_data-tile_bottom_edge = ls_tbgc_loi-tile.
          ENDCASE.

          IF ls_tbgc_loi-LoaiHang = 1.

            CASE ls_tbgc_loi-ErrorCode.
              WHEN 5.
                ls_data-bottom_miss_center = ls_tbgc_loi-SlLoi.
                ls_data-tile_bottom_miss_center = ls_tbgc_loi-tile.
              WHEN 6.
                ls_data-strap_off_seam = ls_tbgc_loi-SlLoi.
                ls_data-tile_strap_off_seam = ls_tbgc_loi-tile.
              WHEN 7.
                ls_data-strap_defects = ls_tbgc_loi-SlLoi.
                ls_data-tile_strap_defects = ls_tbgc_loi-tile.
              WHEN 8.
                ls_data-strap_unenven_10mm = ls_tbgc_loi-SlLoi.
                ls_data-tile_strap_unenven_10mm = ls_tbgc_loi-tile.
              WHEN 9.
                ls_data-strap_out_of_spec = ls_tbgc_loi-SlLoi.
                ls_data-tile_strap_out_of_spec = ls_tbgc_loi-tile.
              WHEN 10.
                ls_data-improper_trimming = ls_tbgc_loi-SlLoi.
                ls_data-tile_improper_trimming = ls_tbgc_loi-tile.
              WHEN 11.
                ls_data-fold_misalign_un_1_5cm = ls_tbgc_loi-SlLoi.
                ls_data-tile_fold_misalign_un_1_5cm = ls_tbgc_loi-tile.
              WHEN 12.
                ls_data-fold_misalign_ov_1_5cm = ls_tbgc_loi-SlLoi.
                ls_data-tile_fold_misalign_ov_1_5cm = ls_tbgc_loi-tile.
              WHEN 13.
                ls_data-wrinkled = ls_tbgc_loi-SlLoi.
                ls_data-tile_wrinkled = ls_tbgc_loi-tile.
              WHEN 14.
                ls_data-defect_stitch_opening = ls_tbgc_loi-SlLoi.
                ls_data-tile_defect_stitch_opening = ls_tbgc_loi-tile.
              WHEN 15.
                ls_data-incorrect_stitch_pitch_1mm = ls_tbgc_loi-SlLoi.
                ls_data-tile_incorrect_stitch_pitch = ls_tbgc_loi-tile.
              WHEN 16.
                ls_data-incorrect_label = ls_tbgc_loi-SlLoi.
                ls_data-tile_incorrect_label = ls_tbgc_loi-tile.
              WHEN 17.
                ls_data-short_quan_bundle = ls_tbgc_loi-SlLoi.
                ls_data-tile_short_quan_bundle = ls_tbgc_loi-tile.
              WHEN 18.
                ls_data-excess_quan_bundle = ls_tbgc_loi-SlLoi.
                ls_data-tile_excess_quan_bundle = ls_tbgc_loi-tile.
            ENDCASE.

          ENDIF.

          IF ls_tbgc_loi-LoaiHang = 2.

            CASE ls_tbgc_loi-ErrorCode.
              WHEN 5.
                ls_data-strap_off_seam = ls_tbgc_loi-SlLoi.
                ls_data-tile_strap_off_seam = ls_tbgc_loi-tile.
              WHEN 6.
                ls_data-strap_defects = ls_tbgc_loi-SlLoi.
                ls_data-tile_strap_defects = ls_tbgc_loi-tile.
              WHEN 7.
                ls_data-strap_unenven_10mm = ls_tbgc_loi-SlLoi.
                ls_data-tile_strap_unenven_10mm = ls_tbgc_loi-tile.
              WHEN 8.
                ls_data-strap_thread_break = ls_tbgc_loi-SlLoi.
                ls_data-tile_strap_thread_break = ls_tbgc_loi-tile.
              WHEN 9.
                ls_data-improper_trimming = ls_tbgc_loi-SlLoi.
                ls_data-tile_improper_trimming = ls_tbgc_loi-tile.
              WHEN 10.
                ls_data-fold_misalign_un_1_5cm = ls_tbgc_loi-SlLoi.
                ls_data-tile_fold_misalign_un_1_5cm = ls_tbgc_loi-tile.
              WHEN 11.
                ls_data-fold_misalign_ov_1_5cm = ls_tbgc_loi-SlLoi.
                ls_data-tile_fold_misalign_ov_1_5cm = ls_tbgc_loi-tile.
              WHEN 12.
                ls_data-wrinkled = ls_tbgc_loi-SlLoi.
                ls_data-tile_wrinkled = ls_tbgc_loi-tile.
              WHEN 13.
                ls_data-defect_stitch_opening = ls_tbgc_loi-SlLoi.
                ls_data-tile_defect_stitch_opening = ls_tbgc_loi-tile.
              WHEN 14.
                ls_data-incorrect_stitch_pitch_1mm = ls_tbgc_loi-SlLoi.
                ls_data-tile_incorrect_stitch_pitch = ls_tbgc_loi-tile.
              WHEN 15.
                ls_data-body_side_misalign_4mm = ls_tbgc_loi-SlLoi.
                ls_data-tile_body_side_misalign = ls_tbgc_loi-tile.
              WHEN 16.
                ls_data-twisted_body_binding = ls_tbgc_loi-SlLoi.
                ls_data-tile_twisted_body_binding = ls_tbgc_loi-tile.
              WHEN 17.
                ls_data-incorrect_label = ls_tbgc_loi-SlLoi.
                ls_data-tile_incorrect_label = ls_tbgc_loi-tile.
              WHEN 18.
                ls_data-short_quan_bundle = ls_tbgc_loi-SlLoi.
                ls_data-tile_short_quan_bundle = ls_tbgc_loi-tile.
              WHEN 19.
                ls_data-excess_quan_bundle = ls_tbgc_loi-SlLoi.
                ls_data-tile_excess_quan_bundle = ls_tbgc_loi-tile.
              WHEN 20.
                ls_data-zipper_defect = ls_tbgc_loi-SlLoi.
                ls_data-tile_zipper_defect = ls_tbgc_loi-tile.
              WHEN 21.
                ls_data-broken_zipper = ls_tbgc_loi-SlLoi.
                ls_data-tile_broken_zipper = ls_tbgc_loi-tile.
            ENDCASE.

          ENDIF.
        ENDIF.

      ENDLOOP.

      ls_data-ko_tem_may = ls_tbbb_gc-bs01.
      ls_data-ko_tem_dan = ls_tbbb_gc-bs02.
      ls_data-ko_tem_treo = ls_tbbb_gc-bs03.
      ls_data-ko_tem_ban = ls_tbbb_gc-bs04.
      ls_data-thieu_tam_bia = ls_tbbb_gc-bs05.

      ls_data-sl_hang_chap = ls_tbbb_gc-Ct16.
      ls_data-cham_sau_count = ls_tbbb_gc-Ct321.
      ls_data-cham_sau_kh = ls_tbbb_gc-Ct322.
      ls_data-tp_100_do_gc = ls_tbbb_gc-Ct323.
      ls_data-tp_100_do_cty_kh = ls_tbbb_gc-Ct324.
      ls_data-tong_loi_cty = ls_tbbb_gc-Ct40.

      lv_sum_1000 = ls_tbbb_gc-Ct47.

      IF lv_sum_1000 < 1000.
        ls_data-loi_gc_un_1000 = lv_sum_1000.
      ELSE.
        ls_data-loi_gc_ov_1000 = lv_sum_1000.
      ENDIF.

      ls_data-contrung_divat = ls_tbbb_gc-bs06.
      ls_data-chi_nhung_dau = ls_tbbb_gc-bs07.

      ls_data-low_quality = ls_tbbb_gc-Ct22.
      ls_data-tyleKCLCt26 = ls_tbbb_gc-Ct26.
      ls_data-Ct28 = ls_tbbb_gc-Ct28.
      ls_data-Ct30 = ls_tbbb_gc-Ct30.
      ls_data-Ct32 = ls_tbbb_gc-Ct32.
      ls_data-not_met_table_1 = ls_tbbb_gc-Ct19.
      ls_data-not_met_table_2_mid = ls_tbbb_gc-Ct20.
      ls_data-not_met_table_2_high = ls_tbbb_gc-Ct21.
*      ls_data-not_met_table_2_total = ls_data-not_met_table_2_mid + ls_data-not_met_table_2_high.
      ls_data-not_met_table_2_total = ls_tbbb_gc-Ct23.

*      DATA ten_percent TYPE p LENGTH 3 DECIMALS 2 VALUE '10.00'.

*      LOOP AT lt_tbgc_loi INTO DATA(ls_count_exceeds_10) WHERE HdrID = ls_tbbb_gc-HdrID.
*       if ls_count_exceeds_10-tile >= ten_percent.
*        ls_data-defect_rate_exceeds_10 = ls_data-defect_rate_exceeds_10 + 1 .
*       ENDIF.
*      ENDLOOP.

*      ls_data-defect_rate_exceeds_10 = ls_tbbb_gc-Ct25.
      ls_data-defect_rate_exceeds_10 = ls_tbbb_gc-Ct22.
      ls_data-Total_quality_passed = ls_tbbb_gc-Ct18.

      ls_data-total = ls_tbbb_gc-Ct23.
      ls_data-note = ls_tbbb_gc-GhiChu.

      " Convert the data to the response structure
      APPEND ls_data TO lt_data.
      CLEAR: ls_data, ls_tbbb_gc.

    ENDLOOP.

    gt_result = lt_data.

    " Sorting
    DATA(sort_order) = VALUE abap_sortorder_tab(
      FOR sort_element IN io_request->get_sort_elements( )
      ( name = sort_element-element_name descending = sort_element-descending ) ).
    IF sort_order IS NOT INITIAL.
      SORT lt_data BY (sort_order).
    ENDIF.

    DATA(lv_total_records) = lines( lt_data ).
    lt_result = lt_data.
*        DATA(lo_paging) = io_request->get_paging( ).
    IF lo_paging IS BOUND.
      DATA(top) = lo_paging->get_page_size( ).
      IF top < 0. " -1 means all records
        top = lv_total_records.
      ENDIF.
      DATA(skip) = lo_paging->get_offset( ).

      IF skip >= lv_total_records.
        CLEAR lt_result. " Offset is beyond the total number of records
      ELSEIF top = 0.
        CLEAR lt_result. " No records requested
      ELSE.
        " Calculate the actual range to keep
        DATA(lv_start_index) = skip + 1. " ABAP uses 1-based indexing
        DATA(lv_end_index) = skip + top.

        " Ensure end index doesn't exceed table size
        IF lv_end_index > lv_total_records.
          lv_end_index = lv_total_records.
        ENDIF.

        " Create a new table with only the required records
        DATA: lt_paged_result LIKE lt_result.
        CLEAR lt_paged_result.

        " Copy only the required records
        DATA(lv_index) = lv_start_index.
        WHILE lv_index <= lv_end_index.
          APPEND lt_result[ lv_index ] TO lt_paged_result.
          lv_index = lv_index + 1.
        ENDWHILE.

        lt_result = lt_paged_result.
      ENDIF.
    ENDIF.

    " Return data if requested
    IF io_request->is_data_requested( ).
      io_response->set_data( it_data = lt_result ).
    ENDIF.

*   " Return total count if requested
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

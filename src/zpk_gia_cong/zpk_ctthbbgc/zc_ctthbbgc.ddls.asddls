@EndUserText.label: 'BC chi tiết, TH BBGC'
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_CTTHBBGC'

define custom entity ZC_CTTHBBGC
{
  key hdr_id                      : sysuuid_x16; // UUID
  key line_num                    : abap.int4; // Số TT
  key report_no                   : zde_so_bb_gc; // Số biên bản

      lsx_gc                      : aufnr; // LSX gia công
      po_Subcontracting           : lifnr;     // PO gia công
      company_code                : bukrs;     // Company code
      so_number                   : ebeln;     // Số SO
      item_type                   : abap.char(10); // Kiểu hàng
      item_id                     : matnr; // Mã hàng hóa
      item_desc                   : abap.char(255); // Mô tả mã hàng
      gc_id                       : lifnr; // Mã nhà GC
      gc_name                     : name1_gp; // Tên nhà GC
      import_date                 : abap.dats; // Ngày nhập hàng
      entry_date                  : abap.dats; // Ngày nhập kho
      @Aggregation.default        : #SUM
      amount_on_paper             : abap.dec(10,0); // SL nhập theo chứng từ
      @Aggregation.default        : #SUM
      amount_check                : abap.dec(10,0); // Số lượng kiểm
      
      tyleKCLCt26            : abap.dec(5,2);
      
      Ct28        : abap.dec(5,2);
      
      Ct30           : abap.dec(5,2);
      
      Ct32           : abap.dec(5,2);
    
      report_date_lap             : abap.dats; // Ngày lập biên bản
      report_date                 : abap.dats; // Ngày trả biên bản
      @Aggregation.default        : #SUM
      insect                      : abap.dec(10,0); // Lỗi côn trùng
      tile_insect                 : abap.dec(5,2);
      @Aggregation.default        : #SUM
      dirty                       : abap.dec(10,0); // Bẩn
      tile_dirty                  : abap.dec(5,2);
      @Aggregation.default        : #SUM
      no_strap                    : abap.dec(10,0); // Không may quai
      tile_no_strap               : abap.dec(5,2);
      @Aggregation.default        : #SUM
      bottom_edge_defect          : abap.dec(10,0); // Sụt đáy/viền
      tile_bed                    : abap.dec(5,2);
      @Aggregation.default        : #SUM
      strap_defect                : abap.dec(10,0); // Lỗi quai (làm tụt quai khi thử tải 30kg)
      tile_strap_def              : abap.dec(5,2);
      @Aggregation.default        : #SUM
      seam_failure                : abap.dec(10,0); // May vỡ mặt manh
      tile_seam_fail              : abap.dec(5,2);
      @Aggregation.default        : #SUM
      fabric_defects              : abap.dec(10,0); // Máy cào xước màng, rách manh, rách góc
      tile_fab_def                : abap.dec(5,2);
      @Aggregation.default        : #SUM
      light_stain                 : abap.dec(10,0); // Bẩn nhẹ
      tile_light_stain            : abap.dec(5,2);
      @Aggregation.default        : #SUM
      hem_fold_miss_4mm           : abap.dec(10,0); // Gấp miệng sai 4mm
      tile_hem_fold_miss_4mm      : abap.dec(5,2);
      @Aggregation.default        : #SUM
      bottom_seam_miss_4mm        : abap.dec(10,0); // Chắp đáy sai 4mm
      tile_seam_miss_4mm          : abap.dec(5,2);
      @Aggregation.default        : #SUM
      bottom_edge_not_meet_requi  : abap.dec(10,0); // Lỗi đáy/viền không đạt
      tile_bottom_edge            : abap.dec(5,2);
      @Aggregation.default        : #SUM
      bottom_miss_center          : abap.dec(10,0); // Lỗi may lệch tâm đáy
      tile_bottom_miss_center     : abap.dec(5,2);
      @Aggregation.default        : #SUM
      strap_off_seam              : abap.dec(10,0); // May trượt mí quai
      tile_strap_off_seam         : abap.dec(5,2);
      @Aggregation.default        : #SUM
      strap_defects               : abap.dec(10,0); // Lệch quai, vặn quai
      tile_strap_defects          : abap.dec(5,2);
      @Aggregation.default        : #SUM
      strap_unenven_10mm          : abap.dec(10,0); // May quai không bằng đầu 10mm
      tile_strap_unenven_10mm     : abap.dec(5,2);
      @Aggregation.default        : #SUM
      strap_out_of_spec           : abap.dec(10,0); // May quai sai thông số
      tile_strap_out_of_spec      : abap.dec(5,2);
      @Aggregation.default        : #SUM
      strap_thread_break          : abap.dec(10,0); // Đứt chỉ quai
      tile_strap_thread_break     : abap.dec(5,2);
      @Aggregation.default        : #SUM
      improper_trimming           : abap.dec(10,0); // Hàng cắt chỉ không đạt
      tile_improper_trimming      : abap.dec(5,2);
      @Aggregation.default        : #SUM
      fold_misalign_un_1_5cm      : abap.dec(10,0); // Gấp lệch 1-1.5cm
      tile_fold_misalign_un_1_5cm : abap.dec(5,2);
      @Aggregation.default        : #SUM
      fold_misalign_ov_1_5cm      : abap.dec(10,0); // Gấp lệch >1.5cm
      tile_fold_misalign_ov_1_5cm : abap.dec(5,2);
      @Aggregation.default        : #SUM
      wrinkled                    : abap.dec(10,0); // Nhăn nhàu
      tile_wrinkled               : abap.dec(5,2);
      @Aggregation.default        : #SUM
      defect_stitch_opening       : abap.dec(10,0); // Sùi chỉ miệng, đứt chỉ miệng
      tile_defect_stitch_opening  : abap.dec(5,2);
      @Aggregation.default        : #SUM
      incorrect_stitch_pitch_1mm  : abap.dec(10,0); // May sai bước chỉ > 1mm
      tile_incorrect_stitch_pitch : abap.dec(5,2);
      @Aggregation.default        : #SUM
      body_side_misalign_4mm      : abap.dec(10,0); // Lệch thân và hông > 4mm
      tile_body_side_misalign     : abap.dec(5,2);
      @Aggregation.default        : #SUM
      twisted_body_binding        : abap.dec(10,0); // Viền vặn thân
      tile_twisted_body_binding   : abap.dec(5,2);
      @Aggregation.default        : #SUM
      incorrect_label             : abap.dec(10,0); // Thiếu tem, sai tem, thẻ bài
      tile_incorrect_label        : abap.dec(5,2);
      @Aggregation.default        : #SUM
      short_quan_bundle           : abap.dec(10,0); // Thiếu số lượng trong bó
      tile_short_quan_bundle      : abap.dec(5,2);
      @Aggregation.default        : #SUM
      excess_quan_bundle          : abap.dec(10,0); // Thừa số lượng trong bó
      tile_excess_quan_bundle     : abap.dec(5,2);
      @Aggregation.default        : #SUM
      zipper_defect               : abap.dec(10,0); // Bật viền, bật đầu khóa
      tile_zipper_defect          : abap.dec(5,2);
      @Aggregation.default        : #SUM
      broken_zipper               : abap.dec(10,0); // Khóa hỏng
      tile_broken_zipper          : abap.dec(5,2);
@Aggregation.default        : #SUM
      ko_tem_may                  : abap.dec(10,0); // Số lượng hàng nhập không tem may
      @Aggregation.default        : #SUM
      ko_tem_dan                  : abap.dec(10,0); // Số lượng hàng nhập không tem dán
      @Aggregation.default        : #SUM
      ko_tem_treo                 : abap.dec(10,0); // Số lượng hàng nhập không tem treo
      @Aggregation.default        : #SUM
      ko_tem_ban                  : abap.dec(10,0); // Số lượng hàng nhập không tem bắn
      @Aggregation.default        : #SUM
      thieu_tam_bia               : abap.dec(10,0); // Số lượng hàng nhập thiếu tấm bìa

      @Aggregation.default        : #SUM
      sl_hang_chap                : abap.dec(10,0); // SL hàng chắp
      @Aggregation.default        : #SUM
      cham_sau_count              : abap.dec(10,0); // Hàng trả chậm sau cont không xuất được hàng
      @Aggregation.default        : #SUM
      cham_sau_kh                 : abap.dec(10,0); // Hàng trả chậm sau KH nhưng xuất được hàng
      @Aggregation.default        : #SUM
      tp_100_do_gc                : abap.dec(10,0); // Hàng TP trả về phải kiểm 100% do lỗi gia công
      @Aggregation.default        : #SUM
      tp_100_do_cty_kh            : abap.dec(10,0); // Hàng TP trả về phải kiểm 100% do lỗi công ty và hàng KK
      @Aggregation.default        : #SUM
      tong_loi_cty                : abap.dec(10,0); // Tổng lỗi công ty
      @Aggregation.default        : #SUM
      loi_gc_un_1000              : abap.dec(10,0); // Tổng lỗi gia công dưới 1000 túi
      @Aggregation.default        : #SUM
      loi_gc_ov_1000              : abap.dec(10,0); // Tổng lỗi gia công trên 1000 túi

      contrung_divat              : zde_check; // Biên bảng hiện trường: côn trùng, dị vật:
      chi_nhung_dau               : zde_check; // Biên bản hiện trường: chỉ nhúng dầu!:
      @Aggregation.default        : #SUM
      low_quality                 : abap.dec(10,0); // Lỗi kém CL
      @Aggregation.default        : #SUM
      not_met_table_1             : abap.dec(10,0); // Không đạt bảng I
      @Aggregation.default        : #SUM
      not_met_table_2_mid         : abap.dec(10,0); // Không đạt bảng II (Lỗi nghiêm trọng)
      @Aggregation.default        : #SUM
      not_met_table_2_high        : abap.dec(10,0); // Không đạt bảng II (ĐBNT)
      @Aggregation.default        : #SUM
      not_met_table_2_total       : abap.dec(10,0); // Tổng số lượng hàng ko đạt bảng II
      @Aggregation.default        : #SUM
      defect_rate_exceeds_10      : abap.dec(10,0); // Tổng số lượng hàng kém chất lượng trên 10%
      @Aggregation.default        : #SUM
      Total_quality_passed        : abap.dec(10,0); // Tổng số lượng hàng đạt
      @Aggregation.default        : #SUM
      total                       : abap.dec(10,0); // Tổng Cộng
      note                        : abap.char(255); // Ghi chú

}

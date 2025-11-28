@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Báo cáo chi tiết lỗi gia công'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zc_bc_bbgc
  as select from ZR_TBBB_GC as hdr
  association [1..1] to zc_gc_loi_report as loi on loi.HdrID = hdr.HdrID
{
  key hdr.HdrID          as hdr_id,
      OrderID            as lsx_gc,
      SoPo               as po_subcontracting,
      CompanyCode        as company_code,
      SalesOrder         as so_number,

      /* Item type theo loại hàng */
      case LoaiHang
        when '1' then 'Hàng Ống'
        when '2' then 'Hàng Viền'
        else 'Khác'
      end                as item_type,

      Material           as item_id,
      ProductDescription as item_desc,
      Supplier           as gc_id,
      SupplierName       as gc_name,
      SoBb               as report_no,

      /* Chỉ lấy ngày nếu có độ dài >= 5 */
      case when length( NgayNhapHang ) >= 5
           then NgayNhapHang
           else null
      end                as import_date,

      case when length( NgayNhapKho ) >= 5
           then NgayNhapKho
           else null
      end                as entry_date,

      /* Các chỉ tiêu chính */
      @Aggregation.default        : #SUM
      Ct12               as amount_on_paper,
      @Aggregation.default        : #SUM
      Ct13               as amount_check,
      NgayLapBb          as report_date_lap,
      NgayTraBb          as report_date,

      bs01               as ko_tem_may,
      bs02               as ko_tem_dan,
      bs03               as ko_tem_treo,
      bs04               as ko_tem_ban,
      bs05               as thieu_tam_bia,

      Ct16               as sl_hang_chap,
      Ct321              as cham_sau_count,
      Ct322              as cham_sau_kh,
      Ct323              as tp_100_do_gc,
      Ct324              as tp_100_do_cty_kh,
      Ct40               as tong_loi_cty,

      /* Phân loại lỗi < 1000 hay > 1000 */
      case when Ct47 < 1000
           then Ct47
           else 0
      end                as loi_gc_un_1000,

      case when Ct47 >= 1000
           then Ct47
           else 0
      end                as loi_gc_ov_1000,

      bs06               as contrung_divat,
      bs07               as chi_nhung_dau,
      @Aggregation.default        : #SUM
      Ct22               as low_quality,
      Ct26               as tyleKCLCt26,
      Ct28               as Ct28,
      Ct30               as Ct30,
      Ct32               as Ct32,
      @Aggregation.default        : #SUM
      Ct19               as not_met_table_1,
      @Aggregation.default        : #SUM
      Ct20               as not_met_table_2_mid,
      @Aggregation.default        : #SUM
      Ct21               as not_met_table_2_high,
      @Aggregation.default        : #SUM
      Ct23               as not_met_table_2_total,

      /* Tỷ lệ lỗi vượt quá 10% */
      Ct22               as defect_rate_exceeds_10,
      @Aggregation.default        : #SUM
      Ct18               as total_quality_passed,
      @Aggregation.default        : #SUM
      Ct23               as total,
      GhiChu             as note,
      @Aggregation.default        : #SUM
      loi.insect,
      loi.tile_insect,
      @Aggregation.default        : #SUM
      loi.dirty,
      loi.tile_dirty,
      @Aggregation.default        : #SUM
      loi.no_strap,
      loi.tile_no_strap,
      @Aggregation.default        : #SUM
      loi.bottom_edge_defect,
      loi.tile_bed,
      @Aggregation.default        : #SUM
      loi.strap_defect,
      loi.tile_strap_def,
      @Aggregation.default        : #SUM
      loi.seam_failure,
      loi.tile_seam_fail,
      @Aggregation.default        : #SUM
      loi.fabric_defects,
      loi.tile_fab_def,
      @Aggregation.default        : #SUM
      loi.light_stain,
      loi.tile_light_stain,
      @Aggregation.default        : #SUM
      loi.hem_fold_miss_4mm,
      loi.tile_hem_fold_miss_4mm,
      @Aggregation.default        : #SUM
      loi.bottom_seam_miss_4mm,
      loi.tile_seam_miss_4mm,
      @Aggregation.default        : #SUM
      loi.bottom_edge_not_meet_requi,
      loi.tile_bottom_edge,
      @Aggregation.default        : #SUM
      loi.bottom_miss_center,
      loi.tile_bottom_miss_center,
      @Aggregation.default        : #SUM
      loi.strap_off_seam,
      loi.tile_strap_off_seam,
      @Aggregation.default        : #SUM
      loi.strap_defects,
      loi.tile_strap_defects,
      @Aggregation.default        : #SUM
      loi.strap_unenven_10mm,
      loi.tile_strap_unenven_10mm,
      @Aggregation.default        : #SUM
      loi.strap_out_of_spec,
      loi.tile_strap_out_of_spec,
      @Aggregation.default        : #SUM
      loi.strap_thread_break,
      loi.tile_strap_thread_break,
      @Aggregation.default        : #SUM
      loi.improper_trimming,
      loi.tile_improper_trimming,
      @Aggregation.default        : #SUM
      loi.fold_misalign_un_1_5cm,
      loi.tile_fold_misalign_un_1_5cm,
      @Aggregation.default        : #SUM
      loi.fold_misalign_ov_1_5cm,
      loi.tile_fold_misalign_ov_1_5cm,
      @Aggregation.default        : #SUM
      loi.wrinkled,
      loi.tile_wrinkled,
      @Aggregation.default        : #SUM
      loi.defect_stitch_opening,
      loi.tile_defect_stitch_opening,
      @Aggregation.default        : #SUM
      loi.incorrect_stitch_pitch_1mm,
      loi.tile_incorrect_stitch_pitch,
      @Aggregation.default        : #SUM
      loi.body_side_misalign_4mm,
      loi.tile_body_side_misalign,
      @Aggregation.default        : #SUM
      loi.twisted_body_binding,
      loi.tile_twisted_body_binding,
      @Aggregation.default        : #SUM
      loi.incorrect_label,
      loi.tile_incorrect_label,
      @Aggregation.default        : #SUM
      loi.short_quan_bundle,
      loi.tile_short_quan_bundle,
      @Aggregation.default        : #SUM
      loi.excess_quan_bundle,
      loi.tile_excess_quan_bundle,
      @Aggregation.default        : #SUM
      loi.zipper_defect,
      loi.tile_zipper_defect,
      @Aggregation.default        : #SUM
      loi.broken_zipper,
      loi.tile_broken_zipper
}

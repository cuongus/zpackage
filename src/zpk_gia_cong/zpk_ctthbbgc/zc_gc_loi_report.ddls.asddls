@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Làm phẳng bảng lỗi gia công'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zc_gc_loi_report as select from ZR_TBGC_LOI
{

    key HdrID,
    
    /* ========== Nhóm A ========== */
    sum( case when LoaiLoi = 'A' and ErrorCode = '001' then SlLoi else 0 end ) as insect,
    sum( case when LoaiLoi = 'A' and ErrorCode = '001' then tile else 0 end )   as tile_insect,

    sum( case when LoaiLoi = 'A' and ErrorCode = '002' then SlLoi else 0 end ) as dirty,
    sum( case when LoaiLoi = 'A' and ErrorCode = '002' then tile else 0 end )   as tile_dirty,

    sum( case when LoaiLoi = 'A' and ErrorCode = '003' then SlLoi else 0 end ) as no_strap,
    sum( case when LoaiLoi = 'A' and ErrorCode = '003' then tile else 0 end )   as tile_no_strap,

    sum( case when LoaiLoi = 'A' and ErrorCode = '004' then SlLoi else 0 end ) as bottom_edge_defect,
    sum( case when LoaiLoi = 'A' and ErrorCode = '004' then tile else 0 end )   as tile_bed,

    sum( case when LoaiLoi = 'A' and ErrorCode = '005' then SlLoi else 0 end ) as strap_defect,
    sum( case when LoaiLoi = 'A' and ErrorCode = '005' then tile else 0 end )   as tile_strap_def,

    sum( case when LoaiLoi = 'A' and ErrorCode = '006' then SlLoi else 0 end ) as seam_failure,
    sum( case when LoaiLoi = 'A' and ErrorCode = '006' then tile else 0 end )   as tile_seam_fail,

    sum( case when LoaiLoi = 'A' and ErrorCode = '007' then SlLoi else 0 end ) as fabric_defects,
    sum( case when LoaiLoi = 'A' and ErrorCode = '007' then tile else 0 end )   as tile_fab_def,

    /* ========== Nhóm B ========== */
    sum( case when LoaiLoi = 'B' and ErrorCode = '001' then SlLoi else 0 end ) as light_stain,
    sum( case when LoaiLoi = 'B' and ErrorCode = '001' then tile else 0 end )   as tile_light_stain,

    sum( case when LoaiLoi = 'B' and ErrorCode = '002' then SlLoi else 0 end ) as hem_fold_miss_4mm,
    sum( case when LoaiLoi = 'B' and ErrorCode = '002' then tile else 0 end )   as tile_hem_fold_miss_4mm,

    sum( case when LoaiLoi = 'B' and ErrorCode = '003' then SlLoi else 0 end ) as bottom_seam_miss_4mm,
    sum( case when LoaiLoi = 'B' and ErrorCode = '003' then tile else 0 end )   as tile_seam_miss_4mm,

    sum( case when LoaiLoi = 'B' and ErrorCode = '004' then SlLoi else 0 end ) as bottom_edge_not_meet_requi,
    sum( case when LoaiLoi = 'B' and ErrorCode = '004' then tile else 0 end )   as tile_bottom_edge,
    
    -- ========== Nhóm lỗi cho Loại hàng 1 & 2 ==========
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '005')
              then SlLoi else 0 end) as bottom_miss_center,
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '005')
              then tile else 0 end) as tile_bottom_miss_center,

    -- strap_off_seam: LoaiHang=1,Error=6 OR LoaiHang=2,Error=5
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '006')
              or (LoaiHang = '2' and ErrorCode = '005')
              then SlLoi else 0 end) as strap_off_seam,
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '006')
              or (LoaiHang = '2' and ErrorCode = '005')
              then tile else 0 end) as tile_strap_off_seam,

    -- strap_defects: LoaiHang=1,Error=7 OR LoaiHang=2,Error=6
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '007')
              or (LoaiHang = '2' and ErrorCode = '006')
              then SlLoi else 0 end) as strap_defects,
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '007')
              or (LoaiHang = '2' and ErrorCode = '006')
              then tile else 0 end) as tile_strap_defects,

    -- strap_unenven_10mm: LoaiHang=1,Error=8 OR LoaiHang=2,Error=7
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '008')
              or (LoaiHang = '2' and ErrorCode = '007')
              then SlLoi else 0 end) as strap_unenven_10mm,
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '008')
              or (LoaiHang = '2' and ErrorCode = '007')
              then tile else 0 end) as tile_strap_unenven_10mm,

    -- strap_out_of_spec (chỉ loại 1)
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '009')
              then SlLoi else 0 end) as strap_out_of_spec,
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '009')
              then tile else 0 end) as tile_strap_out_of_spec,

    -- strap_thread_break (chỉ loại 2, error=8)
    sum(case 
            when (LoaiHang = '2' and ErrorCode = '008')
              then SlLoi else 0 end) as strap_thread_break,
    sum(case 
            when (LoaiHang = '2' and ErrorCode = '008')
              then tile else 0 end) as tile_strap_thread_break,

    -- improper_trimming: LoaiHang=1,Error=10 OR LoaiHang=2,Error=9
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '010')
              or (LoaiHang = '2' and ErrorCode = '009')
              then SlLoi else 0 end) as improper_trimming,
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '010')
              or (LoaiHang = '2' and ErrorCode = '009')
              then tile else 0 end) as tile_improper_trimming,

    -- fold_misalign_un_1_5cm: LoaiHang=1,Error=11 OR LoaiHang=2,Error=10
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '011')
              or (LoaiHang = '2' and ErrorCode = '010')
              then SlLoi else 0 end) as fold_misalign_un_1_5cm,
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '011')
              or (LoaiHang = '2' and ErrorCode = '010')
              then tile else 0 end) as tile_fold_misalign_un_1_5cm,

    -- fold_misalign_ov_1_5cm: LoaiHang=1,Error=12 OR LoaiHang=2,Error=11
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '012')
              or (LoaiHang = '2' and ErrorCode = '011')
              then SlLoi else 0 end) as fold_misalign_ov_1_5cm,
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '012')
              or (LoaiHang = '2' and ErrorCode = '011')
              then tile else 0 end) as tile_fold_misalign_ov_1_5cm,

    -- wrinkled: LoaiHang=1,Error=13 OR LoaiHang=2,Error=12
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '013')
              or (LoaiHang = '2' and ErrorCode = '012')
              then SlLoi else 0 end) as wrinkled,
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '013')
              or (LoaiHang = '2' and ErrorCode = '012')
              then tile else 0 end) as tile_wrinkled,

    -- defect_stitch_opening: LoaiHang=1,Error=14 OR LoaiHang=2,Error=13
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '014')
              or (LoaiHang = '2' and ErrorCode = '013')
              then SlLoi else 0 end) as defect_stitch_opening,
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '014')
              or (LoaiHang = '2' and ErrorCode = '013')
              then tile else 0 end) as tile_defect_stitch_opening,

    -- incorrect_stitch_pitch_1mm: LoaiHang=1,Error=15 OR LoaiHang=2,Error=14
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '015')
              or (LoaiHang = '2' and ErrorCode = '014')
              then SlLoi else 0 end) as incorrect_stitch_pitch_1mm,
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '015')
              or (LoaiHang = '2' and ErrorCode = '014')
              then tile else 0 end) as tile_incorrect_stitch_pitch,

    -- body_side_misalign_4mm (chỉ loại 2)
    sum(case 
            when (LoaiHang = '2' and ErrorCode = '015')
              then SlLoi else 0 end) as body_side_misalign_4mm,
    sum(case 
            when (LoaiHang = '2' and ErrorCode = '015')
              then tile else 0 end) as tile_body_side_misalign,

    -- twisted_body_binding (chỉ loại 2)
    sum(case 
            when (LoaiHang = '2' and ErrorCode = '016')
              then SlLoi else 0 end) as twisted_body_binding,
    sum(case 
            when (LoaiHang = '2' and ErrorCode = '016')
              then tile else 0 end) as tile_twisted_body_binding,

    -- incorrect_label: LoaiHang=1,Error=16 OR LoaiHang=2,Error=17
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '016')
              or (LoaiHang = '2' and ErrorCode = '017')
              then SlLoi else 0 end) as incorrect_label,
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '016')
              or (LoaiHang = '2' and ErrorCode = '017')
              then tile else 0 end) as tile_incorrect_label,

    -- short_quan_bundle: LoaiHang=1,Error=17 OR LoaiHang=2,Error=18
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '017')
              or (LoaiHang = '2' and ErrorCode = '018')
              then SlLoi else 0 end) as short_quan_bundle,
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '017')
              or (LoaiHang = '2' and ErrorCode = '018')
              then tile else 0 end) as tile_short_quan_bundle,

    -- excess_quan_bundle: LoaiHang=1,Error=18 OR LoaiHang=2,Error=19
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '018')
              or (LoaiHang = '2' and ErrorCode = '019')
              then SlLoi else 0 end) as excess_quan_bundle,
    sum(case 
            when (LoaiHang = '1' and ErrorCode = '018')
              or (LoaiHang = '2' and ErrorCode = '019')
              then tile else 0 end) as tile_excess_quan_bundle,

    -- zipper_defect (chỉ loại 2)
    sum(case 
            when (LoaiHang = '2' and ErrorCode = '020')
              then SlLoi else 0 end) as zipper_defect,
    sum(case 
            when (LoaiHang = '2' and ErrorCode = '020')
              then tile else 0 end) as tile_zipper_defect,

    -- broken_zipper (chỉ loại 2)
    sum(case 
            when (LoaiHang = '2' and ErrorCode = '021')
              then SlLoi else 0 end) as broken_zipper,
    sum(case 
            when (LoaiHang = '2' and ErrorCode = '021')
              then tile else 0 end) as tile_broken_zipper
} group by HdrID

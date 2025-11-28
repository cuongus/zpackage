CLASS zcl_nxt_sot_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_NXT_SOT_TEST IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.
DATA: lr_material TYPE zcl_nxt_sot=>tt_ranges,
      lr_plant    TYPE zcl_nxt_sot=>tt_ranges,
      lr_sloc     TYPE zcl_nxt_sot=>tt_ranges,
      lt_hdr TYPE zcl_nxt_sot=>tt_c_nxt_sot_hdr,
      lt_dtl TYPE zcl_nxt_sot=>tt_c_nxt_sot_dtl,
      lr_vendor   TYPE zcl_nxt_sot=>tt_ranges.

" --- TẠO RANGE TEST ---
APPEND VALUE #( sign = 'I' option = 'EQ' low = '000000000400003323' ) TO lr_material.
APPEND VALUE #( sign = 'I' option = 'EQ' low = '671K' ) TO lr_plant.


zcl_nxt_sot=>get_xnt_sot_ps(
  EXPORTING
      ir_datefr = '20251001'
      ir_dateto = '20251031'
      ir_material = lr_material
      ir_plant    = lr_plant
      ir_sloc     = lr_sloc
      ir_vendor   = lr_vendor
  IMPORTING
      e_nxt_sot_hdr = lt_hdr
      e_nxt_sot_dtl = lt_dtl ).

ENDMETHOD.
ENDCLASS.

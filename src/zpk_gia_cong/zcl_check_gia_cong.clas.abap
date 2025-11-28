CLASS zcl_check_gia_cong DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CHECK_GIA_CONG IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA: lw_date TYPE char13.
    DATA: lw_date_1 TYPE char13.
    DATA: num8 TYPE n LENGTH 8.
    SELECT * FROM ztb_bb_gc INTO TABLE @DATA(lt_bb_gc).
    LOOP AT lt_bb_gc INTO DATA(ls_bb_gc).
    out->write( '/' ).
      lw_date = ls_bb_gc-ngay_nhap_kho.
      TRY.

          cl_abap_datfm=>conv_date_ext_to_int(
            EXPORTING
              im_datext    = lw_date
              im_datfmdes  = '5'
      IMPORTING
        ex_datint    = DATA(date)
                 ).
          num8 = date.
        CATCH cx_abap_datfm_no_date cx_abap_datfm_invalid_date cx_abap_datfm_format_unknown cx_abap_datfm_ambiguous INTO DATA(oref).
          out->write( oref->if_message~get_text( ) ).
      ENDTRY.

      out->write( num8 ).
      out->write( ls_bb_gc-so_bb ).
      out->write( lw_date ).
      out->write( ls_bb_gc-ngay_nhap_hang ).
      out->write( ls_bb_gc-ngay_nhap_kho ).

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.

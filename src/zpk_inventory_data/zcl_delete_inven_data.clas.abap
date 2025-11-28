CLASS zcl_delete_inven_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DELETE_INVEN_DATA IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    DELETE FROM ztb_inventory_im.
*    DELETE FROM ztb_inventory.
*
*    DELETE FROM ztb_xetduyet_hdr.
*    DELETE FROM ztb_xetduyet_dtl.
*
*    DELETE FROM ztbxtduyet_hdr_d.
*    DELETE FROM ztbxtduyet_dtl_d.
*    update ztb_xuat_hd set trangthai = '1' WHERE hdr_id = 'FA163EF80C7E1FD0A4D97D6CF5BD68C5'.
*    update ztb_bb_gc set trangthai = '0'.
    COMMIT WORK.
    out->write( |Complete| ).
  ENDMETHOD.
ENDCLASS.

CLASS zcl_update_partner DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_UPDATE_PARTNER IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    SELECT * FROM ztb_dcgc_hdr
        WHERE  partnerfunc = ''
        INTO TABLE @DATA(lt_data).
    LOOP AT lt_data INTO DATA(ls_data).
      SELECT SINGLE ReferenceSupplier
      FROM zI_SupplierPartnerFunc
      WHERE Supplier = @ls_data-supplier AND PurchasingOrganization = @ls_data-bukrs
      INTO @DATA(lv_partnerfunc).
      IF sy-subrc IS INITIAL.
        UPDATE ztb_dcgc_hdr SET partnerfunc = @lv_partnerfunc
        WHERE  hdr_id = @ls_data-hdr_id.
      ENDIF.

    ENDLOOP.
    COMMIT WORK.
    out->write( |Complete| ).
  ENDMETHOD.
ENDCLASS.

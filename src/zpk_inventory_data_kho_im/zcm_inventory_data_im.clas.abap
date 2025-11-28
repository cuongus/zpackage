CLASS zcm_inventory_data_im DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCM_INVENTORY_DATA_IM IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    DATA(lo_scope_api) = cl_aps_bc_scope_change_api=>create_instance( ).
*
*    lo_scope_api->scope(
*    EXPORTING it_object_scope = VALUE #(
*    pgmid = if_aps_bc_scope_change_api=>gc_tadir_pgmid-R3TR
*    scope_state = if_aps_bc_scope_change_api=>gc_scope_state-ON
*
** Space template
*   ( object = if_aps_bc_scope_change_api=>gc_tadir_object-UIST obj_name = 'Z_INVENTORY_DATA_IM' )
*
** Page template
*    ( object = if_aps_bc_scope_change_api=>gc_tadir_object-UIPG obj_name = 'Z_INVENTORY_DATA_IM' )
*    )
*
*            iv_simulate = abap_false
*            iv_force = abap_false
*    IMPORTING et_object_result = DATA(lt_results)
*            et_message = DATA(lt_messages) ).





*    SELECT *
*    FROM ztb_inven_im1
*    WHERE pid IS NOT INITIAL
*    AND pid_item IS NOT INITIAL
*    and edit <> 'X'
*    INTO TABLE @DATA(lt_data).
*
*    SORT lt_data BY api_status DESCENDING convert_sap_no DESCENDING.
*    DELETE ADJACENT DUPLICATES FROM lt_data COMPARING pid pid_item document_year.
*
*    DELETE FROM ztb_inven_im1.
*    INSERT ztb_inven_im1 FROM TABLE @lt_data.





*    DELETE FROM ztb_inven_im1.
*
*    DATA: lt_insert TYPE TABLE OF ztb_inven_im1.
*    DATA: ls_insert TYPE ztb_inven_im1.
*
*    SELECT * FROM ztb_inven_im2 INTO TABLE @DATA(lt_data).
*
*    LOOP AT lt_data INTO DATA(ls_data).
*      ls_insert-uuid = ls_data-uuid.
*      ls_insert-convert_sap_no = ls_data-convert_sap_no.
*      ls_insert-plant = ls_data-plant.
*      ls_insert-pid = ls_data-pid.
*      ls_insert-pid_item = ls_data-pid_item.
*      ls_insert-document_year = ls_data-document_year.
*      ls_insert-phys_inv_doc = ls_data-phys_inv_doc.
*      ls_insert-storage_location = ls_data-storage_location.
*      ls_insert-material = ls_data-material.
*      ls_insert-doc_date = ls_data-doc_date.
*      ls_insert-pda_date = ls_data-pda_date.
*      ls_insert-pi_status = ls_data-pi_status.
*      ls_insert-plant_count_date = ls_data-plant_count_date.
*      ls_insert-count_date = ls_data-count_date.
*      ls_insert-material_description = ls_data-material_description.
*      ls_insert-batch = ls_data-batch.
*      ls_insert-sales_order = ls_data-sales_order.
*      ls_insert-sales_order_item = ls_data-sales_order_item.
*      ls_insert-spe_stok = ls_data-spe_stok.
*      ls_insert-spe_stok_num = ls_data-spe_stok_num.
*      ls_insert-stock_type = ls_data-stock_type.
*      ls_insert-book_qty = ls_data-book_qty.
*      ls_insert-book_qty_uom = ls_data-book_qty_uom.
*      ls_insert-pda_qty = ls_data-pda_qty.
*      ls_insert-counted_qty = ls_data-counted_qty.
*      ls_insert-counted_qty_uom = ls_data-counted_qty_uom.
*      ls_insert-entered_qty_pi = ls_data-entered_qty_pi.
*      ls_insert-entered_qty_uom = ls_data-entered_qty_uom.
*      ls_insert-zero_count = ls_data-zero_count.
*      ls_insert-diff_qty = ls_data-diff_qty.
*      ls_insert-api_status = ls_data-api_status.
*      ls_insert-api_message = ls_data-api_message.
*      ls_insert-pda_time = ls_data-pda_time.
*      ls_insert-counter = ls_data-counter.
*      ls_insert-api_date = ls_data-api_date.
*      ls_insert-api_time = ls_data-api_time.
*      ls_insert-user_upload = ls_data-user_upload.
*      ls_insert-upload_time = ls_data-upload_time.
*      ls_insert-upload_date = ls_data-upload_date.
*      ls_insert-upload_status = ls_data-upload_status.
*      ls_insert-upload_message = ls_data-upload_message.
*      ls_insert-edit = ls_data-edit.
*
*      APPEND ls_insert TO lt_insert.
*      CLEAR: ls_data, ls_insert.
*    ENDLOOP.
*
*    INSERT ztb_inven_im1 FROM TABLE @lt_insert.
*
*    IF sy-subrc = 0.
*      out->write( |Insert OK: { lines( lt_insert ) } rows.| ).
*    ELSE.
*      out->write( |Insert FAILED. sy-subrc={ sy-subrc }| ).
*    ENDIF.





*    SELECT * FROM ztb_inven_im1 INTO TABLE @DATA(lt_data).
*
*    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>) WHERE counted_qty_uom = '***'.
*      <fs_data>-counted_qty_uom = 'CAI'.
*    ENDLOOP.
*
*    MODIFY ztb_inven_im1 FROM TABLE @lt_data.
*    COMMIT WORK.


  ENDMETHOD.
ENDCLASS.

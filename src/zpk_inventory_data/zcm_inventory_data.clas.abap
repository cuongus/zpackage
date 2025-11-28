CLASS zcm_inventory_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCM_INVENTORY_DATA IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    DATA(lo_scope_api) = cl_aps_bc_scope_change_api=>create_instance( ).
*
*    lo_scope_api->scope(
*    EXPORTING it_object_scope = VALUE #(
*    pgmid = if_aps_bc_scope_change_api=>gc_tadir_pgmid-R3TR
*    scope_state = if_aps_bc_scope_change_api=>gc_scope_state-ON
*
** Space template
*   ( object = if_aps_bc_scope_change_api=>gc_tadir_object-UIST obj_name = 'Z_INVENTORY_DATA' )
*
** Page template
*    ( object = if_aps_bc_scope_change_api=>gc_tadir_object-UIPG obj_name = 'Z_INVENTORY_DATA' )
*    )
*
*            iv_simulate = abap_false
*            iv_force = abap_false
*    IMPORTING et_object_result = DATA(lt_results)
*            et_message = DATA(lt_messages) ).

    SELECT * FROM ztb_inventory1 INTO TABLE @DATA(lt_data).

*    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
*      <fs_data>-pi_status = 'ACTI'.
*    ENDLOOP.

*    SORT lt_data BY convert_sap_no pid pid_item.

    DELETE lt_data INDEX 14.

    DELETE FROM ztb_inventory1.
    INSERT ztb_inventory1 FROM TABLE @lt_data.

*    MODIFY ztb_inventory1 FROM TABLE @lt_data.
    COMMIT WORK.
  ENDMETHOD.
ENDCLASS.

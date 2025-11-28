CLASS lhc_ZI_BTP_SEW DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zi_btp_sew.

    METHODS update FOR MODIFY
      IMPORTING keys FOR UPDATE zi_btp_sew.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zi_btp_sew.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_btp_sew RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zi_btp_sew.

ENDCLASS.

CLASS lhc_ZI_BTP_SEW IMPLEMENTATION.

  METHOD create.

  ENDMETHOD.

  METHOD update.

    LOOP AT keys INTO DATA(ls_keys).

      SELECT SINGLE uuid
           FROM ztb_btl_sew
           WHERE sales_order            = @ls_keys-SalesOrder
             AND sales_order_item       = @ls_keys-SalesOrderItem
             AND component  = @ls_keys-Component
           INTO @DATA(lv_existing_uuid).

      IF sy-subrc = 0.

        UPDATE ztb_btl_sew SET estimated_qty = @ls_keys-EstimatedQty,estimated_date = @ls_keys-EstimatedDate,
                               prod_week = @ls_keys-ProdWeek
          WHERE uuid = @lv_existing_uuid.

      ELSE.

        DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(ls_ztb) = VALUE ztb_btl_sew(
          uuid           = lv_uuid
          sales_order            = ls_keys-SalesOrder
          sales_order_item       = ls_keys-SalesOrderItem
          component  = ls_keys-Component
          estimated_qty = ls_keys-EstimatedQty
          estimated_date = Ls_keys-EstimatedDate
          prod_week = ls_keys-ProdWeek
        ).

        INSERT ztb_btl_sew FROM @ls_ztb.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_BTP_SEW DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_BTP_SEW IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

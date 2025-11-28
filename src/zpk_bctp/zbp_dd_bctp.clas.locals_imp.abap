CLASS lhc_ZDD_BCTP DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zdd_bctp RESULT result.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zdd_bctp.

    METHODS read FOR READ
      IMPORTING keys FOR READ zdd_bctp RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zdd_bctp.

ENDCLASS.

CLASS lhc_ZDD_BCTP IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD update.

    DATA lt_update TYPE STANDARD TABLE OF ztb_so_gia_cong.
    IF entities IS NOT INITIAL.
      SELECT * FROM ztb_so_gia_cong
        FOR ALL ENTRIES IN @entities
        WHERE salesorder     = @entities-salesorder
          AND salesorderitem = @entities-salesorderitem
          AND purcharseorder = @entities-purchaseorder "Lưu ý kiểm tra đúng tên cột key
        INTO TABLE @DATA(lt_db_data).
    ENDIF.

    LOOP AT entities INTO DATA(ls_update).

      IF ls_update-sl_btp_tra_ve  < 0
     OR ls_update-sl_dong_bo_btp < 0
     OR ls_update-hang_loi_phe   < 0.

        "Trả message lỗi về UI (Fail)
*        failed-zdd_bctp = VALUE #(
*          (  %update = |Số lượng không được nhỏ hơn 0|
*                   )
*          )
*        .
        reported-zdd_bctp = VALUE #(
        (
        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                            text = 'Không được nhập dữ liệu âm' )
        )
        ).
        CONTINUE.  "Không cho update dòng này
      ENDIF.

      READ TABLE lt_db_data INTO DATA(ls_db)
       WITH KEY salesorder     = ls_update-salesorder
                salesorderitem = ls_update-salesorderitem
                purcharseorder = ls_update-purchaseorder.

      IF sy-subrc = 0.
        " === TRƯỜNG HỢP UPDATE (Đã có dữ liệu trong DB) ===

        APPEND VALUE ztb_so_gia_cong(
          " Key thì luôn lấy từ ls_update
          salesorder       = ls_update-salesorder
          salesorderitem   = ls_update-salesorderitem
          purcharseorder   = ls_update-purchaseorder

          " LOGIC QUAN TRỌNG: Kiểm tra xem có thay đổi không?
          " Cách 1: Chuẩn RAP - Dùng %control (Nếu table entities của bạn có %control)
          " Nếu người dùng có nhập liệu field này -> lấy mới. Không nhập -> lấy cũ.
          sl_btp_tra_ve    = COND #( WHEN ls_update-%control-sl_btp_tra_ve = if_abap_behv=>mk-on
                                     THEN ls_update-sl_btp_tra_ve
                                     ELSE ls_db-sl_btp_tra_ve )

          sl_dong_bo_btp   = COND #( WHEN ls_update-%control-sl_dong_bo_btp = if_abap_behv=>mk-on
                                     THEN ls_update-sl_dong_bo_btp
                                     ELSE ls_db-sl_dong_bo_btp )

          hang_loi_phe     = COND #( WHEN ls_update-%control-hang_loi_phe = if_abap_behv=>mk-on
                                     THEN ls_update-hang_loi_phe
                                     ELSE ls_db-hang_loi_phe )

          " Thông tin Audit: Update thì giữ nguyên ngày tạo cũ, chỉ đổi ngày sửa
          created_by       = ls_db-created_by
          created_on       = ls_db-created_on
          created_at       = ls_db-created_at

          changed_by       = cl_abap_context_info=>get_user_technical_name( )
          changed_on       = cl_abap_context_info=>get_system_date( )

        ) TO lt_update.

      ELSE.
        " === TRƯỜNG HỢP CREATE (Chưa có trong DB - nếu luồng này cho phép tạo mới) ===
        " Code như cũ của bạn cho phần tạo mới
        APPEND VALUE ztb_so_gia_cong(
           salesorder       = ls_update-salesorder
           salesorderitem   = ls_update-salesorderitem
           purcharseorder   = ls_update-purchaseorder
           sl_btp_tra_ve    = ls_update-sl_btp_tra_ve
           sl_dong_bo_btp   = ls_update-sl_dong_bo_btp
           hang_loi_phe     = ls_update-hang_loi_phe
           created_by       = cl_abap_context_info=>get_user_technical_name( )
           created_on       = cl_abap_context_info=>get_system_date( )
           created_at       = cl_abap_context_info=>get_system_time( )
           changed_by       = cl_abap_context_info=>get_user_technical_name( )
           changed_on       = cl_abap_context_info=>get_system_date( )
         ) TO lt_update.
      ENDIF.

    ENDLOOP.

    DATA(lo_buffer) = zcl_buffer_bctp=>get_instance( ).
    lo_buffer->set_update_value( lt_update ).

  ENDMETHOD.

  METHOD read.

  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZDD_BCTP DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZDD_BCTP IMPLEMENTATION.

  METHOD finalize.

  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    DATA lt_update TYPE STANDARD TABLE OF ztb_so_gia_cong.

    DATA(lo_buffer) = zcl_buffer_bctp=>get_instance( ).
    lo_buffer->get_update_value(
      IMPORTING et_update = lt_update
    ).

    IF lt_update IS NOT INITIAL.
      MODIFY ztb_so_gia_cong FROM TABLE @lt_update.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup.
    DATA(lo_buffer) = zcl_buffer_bctp=>get_instance( ).
    lo_buffer->clear_update( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

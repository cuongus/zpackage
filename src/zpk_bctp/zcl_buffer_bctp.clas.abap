CLASS zcl_buffer_bctp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: tt_update TYPE STANDARD TABLE OF ztb_so_gia_cong.
    " Singleton: trả về instance duy nhất
    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_buffer_bctp.

    " Lưu dữ liệu UPDATE vào buffer
    METHODS set_update_value
      IMPORTING it_update TYPE tt_update.

    " Lấy dữ liệu từ buffer
    METHODS get_update_value
      EXPORTING et_update TYPE tt_update.

    " Xóa buffer
    METHODS clear_update.

  PRIVATE SECTION.
    " Instance duy nhất
    CLASS-DATA go_instance TYPE REF TO zcl_buffer_bctp.

    " Buffer lưu toàn bộ update
    DATA gt_update TYPE STANDARD TABLE OF ztb_so_gia_cong.

ENDCLASS.

CLASS zcl_buffer_bctp IMPLEMENTATION.

  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      CREATE OBJECT go_instance.
    ENDIF.
    ro_instance = go_instance.
  ENDMETHOD.


  METHOD set_update_value.
    " Lưu vào internal buffer
    gt_update = it_update.
  ENDMETHOD.


  METHOD get_update_value.
    et_update = gt_update.
  ENDMETHOD.


  METHOD clear_update.
    CLEAR gt_update.
  ENDMETHOD.

ENDCLASS.


CLASS zcl_error_rate_rp_test_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ERROR_RATE_RP_TEST_DATA IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*    DATA lt_error_code TYPE STANDARD TABLE OF ztb_error_code.
*    DATA ls_error_code TYPE ztb_error_code.
*
*    " Delete existing entries
*    DELETE FROM ztb_error_code.
*
*    CLEAR: lt_error_code, ls_error_code.
*
*    " Define entries
*    ls_error_code-error_code = '02_02'.
*    ls_error_code-error_description = 'Bảng 2 - lỗi đặc biệt nghiêm trọng'.
*    APPEND ls_error_code TO lt_error_code.
*
*    ls_error_code-error_code = '03_01'.
*    ls_error_code-error_description = 'Tỷ lệ trừ hàng kém chất lượng >10%'.
*    APPEND ls_error_code TO lt_error_code.
*
*    ls_error_code-error_code = '04_01'.
*    ls_error_code-error_description = 'Tỷ lệ trừ hàng phải kiểm lại 100% do lỗi gia công'.
*    APPEND ls_error_code TO lt_error_code.
*
*    ls_error_code-error_code = '05_01'.
*    ls_error_code-error_description = 'Tỷ lệ trừ máy, kiểm, vận chuyển hàng không đạt.'.
*    APPEND ls_error_code TO lt_error_code.
*
*    ls_error_code-error_code = '06_01'.
*    ls_error_code-error_description = 'Trừ tiền Hàng trả chậm sau KH nhưng xuất được hàng (sau khi sếp duyệt)'.
*    APPEND ls_error_code TO lt_error_code.
*
*    ls_error_code-error_code = '07_01'.
*    ls_error_code-error_description = 'Tỷ lệ trừ BTP thiếu'.
*    APPEND ls_error_code TO lt_error_code.
*
*    ls_error_code-error_code = '08_01'.
*    ls_error_code-error_description = 'Tỷ lệ trừ hàng không đạt không xuất được cont'.
*    APPEND ls_error_code TO lt_error_code.
*
*    ls_error_code-error_code = '09_01'.
*    ls_error_code-error_description = 'Tỷ lệ trừ hàng TP sau cont không xuất được'.
*    APPEND ls_error_code TO lt_error_code.
*
*    " Insert entries into DB
*    INSERT ztb_error_code FROM TABLE @lt_error_code.
*    IF sy-subrc <> 0.
*      " If insert is successful, output success message
*      out->write( 'Inserted entries into ztb_error_code successfully!' ).
*
*      " Commit to persist changes
*      COMMIT WORK.
*    ELSE.
*      " If insert fails, output error message
*      out->write( 'Error inserting entries into ztb_error_code!' ).
*    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_zi_data_kb_thue0 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_data_kb_thue0 IMPLEMENTATION.

  METHOD save_modified.


  ENDMETHOD.

ENDCLASS.

CLASS lhc_datakbthue0 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES: BEGIN OF ty_file_upload,
             stt             TYPE string,
             companycode     TYPE string,
             type            TYPE string, "Điền 1 hoặc 2"
             mauhd           TYPE string,
             docreferenceid  TYPE string,
             invoicedate     TYPE string,
             postingdate     TYPE string,
             supplier        TYPE string,
             customer        TYPE string,
             itemtext        TYPE string,
             soluong         TYPE string,
             dvt             TYPE string,
             doanhsovnd      TYPE string,
             dongiavnd       TYPE string,
             doanhsonguyente TYPE string,
             loaitiente      TYPE string,
             dongianguyente  TYPE string,
             tenmavanglai    TYPE string,
             mstmavanglai    TYPE string,
             note            TYPE string,
           END OF ty_file_upload.


    CONSTANTS: c_object TYPE cl_numberrange_runtime=>nr_object VALUE 'ZBS_KBT0'.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR datakbthue0 RESULT result.

    METHODS checkduplicate FOR VALIDATE ON SAVE
      IMPORTING keys FOR datakbthue0~checkduplicate.

    METHODS numbering FOR DETERMINE ON SAVE
      IMPORTING keys FOR datakbthue0~numbering.

    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR datakbthue0 RESULT result.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE datakbthue0.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE datakbthue0.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE datakbthue0.

    METHODS calculateprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR datakbthue0~calculateprice.
    METHODS recalcprice FOR MODIFY
      IMPORTING keys FOR ACTION datakbthue0~recalcprice.

    METHODS setdefaultvnd FOR DETERMINE ON MODIFY
      IMPORTING keys FOR datakbthue0~setdefaultvnd.

    METHODS getdefaultsforcreate FOR READ
      IMPORTING keys FOR FUNCTION datakbthue0~getdefaultsforcreate RESULT result.

    METHODS downloadfile FOR MODIFY
      IMPORTING keys FOR ACTION datakbthue0~downloadfile RESULT result.

    METHODS fileupload FOR MODIFY
      IMPORTING keys FOR ACTION datakbthue0~fileupload RESULT result.

    METHODS checkrequired FOR VALIDATE ON SAVE
      IMPORTING keys FOR datakbthue0~checkrequired.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE datakbthue0.

    METHODS convert_date IMPORTING i_date         TYPE string
                         RETURNING VALUE(rv_dats) TYPE string.

    CONSTANTS c_excel_base TYPE d VALUE '18991230'.
ENDCLASS.

CLASS lhc_datakbthue0 IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    LOOP AT entities
                 ASSIGNING FIELD-SYMBOL(<f_entities>)
                 WHERE uuid IS NOT INITIAL.

      APPEND CORRESPONDING #( <f_entities> ) TO mapped-datakbthue0.

    ENDLOOP.

    DATA(lt_file) = entities.
    DELETE lt_file WHERE uuid IS NOT INITIAL.

    IF lt_file IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_file ASSIGNING <f_entities>.

      TRY.
          <f_entities>-uuid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).

          APPEND VALUE #( %cid      = <f_entities>-%cid
                          %key      = <f_entities>-%key
                          %is_draft = <f_entities>-%is_draft )
               TO mapped-datakbthue0.
        CATCH cx_uuid_error.
          APPEND VALUE #( %cid      = <f_entities>-%cid
                          %key      = <f_entities>-%key
                          %is_draft = <f_entities>-%is_draft )
            TO reported-datakbthue0.

          APPEND VALUE #( %cid      = <f_entities>-%cid
                          %key      = <f_entities>-%key
                          %is_draft = <f_entities>-%is_draft )
            TO failed-datakbthue0.

      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD checkduplicate.
    "Đọc dữ liệu người dùng đang save
    READ ENTITIES OF zi_data_kb_thue0 IN LOCAL MODE
      ENTITY datakbthue0
      FIELDS ( uuid companycode documentreferenceid invoicedate supplier )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_new).

    IF lt_new IS INITIAL.
      RETURN.
    ENDIF.

    "Tìm bản ghi trùng trong bảng persistent (ngoại trừ chính nó khi update)
    TYPES: BEGIN OF ty_hit,
             uuid                TYPE sysuuid_x16,
             companycode         TYPE zui_kb_thue0-companycode,
             documentreferenceid TYPE zui_kb_thue0-documentreferenceid,
             invoicedate         TYPE zui_kb_thue0-invoicedate,
             supplier            TYPE zui_kb_thue0-supplier,
           END OF ty_hit.

    DATA lt_hit TYPE STANDARD TABLE OF ty_hit.

    "FOR ALL ENTRIES để dò theo từng cặp người dùng nhập
    SELECT uuid, companycode, documentreferenceid, invoicedate, supplier
      FROM zui_kb_thue0
      FOR ALL ENTRIES IN @lt_new
      WHERE companycode         = @lt_new-companycode
        AND documentreferenceid = @lt_new-documentreferenceid
        AND invoicedate         = @lt_new-invoicedate
        AND supplier            = @lt_new-supplier
        AND uuid <> @lt_new-uuid          "loại chính nó khi update
      INTO TABLE @lt_hit.

    IF lt_hit IS INITIAL.
      RETURN.
    ENDIF.

    "Map lại theo %tky để báo lỗi từng dòng
    LOOP AT lt_new ASSIGNING FIELD-SYMBOL(<ls_new>).

      READ TABLE lt_hit WITH KEY companycode         = <ls_new>-companycode
                                 documentreferenceid = <ls_new>-documentreferenceid
                                 invoicedate         = <ls_new>-invoicedate
                                 supplier            = <ls_new>-supplier
           TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.

        "1) Chặn save
        APPEND VALUE #( %tky = <ls_new>-%tky ) TO failed-datakbthue0.

        "2) Trả message + bôi đỏ field
        APPEND VALUE #(
          %tky     = <ls_new>-%tky
          %msg     = new_message(
                        id       = 'ZKBTHUE0'         "tạo message class của bạn
                        number   = '001'         "ví dụ: 'Đã tồn tại bản ghi TaxCode &1, TaxNo &2'
                        v1       = <ls_new>-companycode
                        v2       = <ls_new>-documentreferenceid
                        v3       = <ls_new>-invoicedate
                        v4       = <ls_new>-supplier
                        severity = if_abap_behv_message=>severity-error )
          %element-companycode           = if_abap_behv=>mk-on
          %element-documentreferenceid   = if_abap_behv=>mk-on
          %element-invoicedate           = if_abap_behv=>mk-on
          %element-supplier              = if_abap_behv=>mk-on
        ) TO reported-datakbthue0.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD numbering.
    DATA: lv_year TYPE cl_numberrange_runtime=>nr_toyear.

    READ ENTITIES OF zi_data_kb_thue0 IN LOCAL MODE
    ENTITY datakbthue0
    FIELDS ( uuid companycode postingdate documentnumber )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_new).

    LOOP AT lt_new ASSIGNING FIELD-SYMBOL(<ls>).
      lv_year = <ls>-postingdate+0(4).
      IF lv_year IS INITIAL.
        lv_year = sy-datlo+0(4).
      ELSE.
      ENDIF.

      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr = '01'
              object      = c_object
              toyear      = <ls>-postingdate+0(4)
            IMPORTING
              number      = DATA(ld_number)
              returncode  = DATA(ld_rcode) ).
        CATCH cx_number_ranges.
          "handle exception
      ENDTRY.

      DATA lv_raw   TYPE string.
      DATA lv_len   TYPE i.
      DATA lv_off   TYPE i.
      DATA lv_str9  TYPE string.  "kết quả dạng string length = 9

      " Lấy phần chữ số từ ld_number (loại bỏ ký tự khác số nếu có)
      lv_raw = CONV string( ld_number ).
      REPLACE ALL OCCURRENCES OF REGEX '[^0-9]' IN lv_raw WITH ''.
      lv_len = strlen( lv_raw ).

      IF lv_len >= 9.
        lv_off  = lv_len - 9.          "tách offset ra biến riêng
        lv_str9 = lv_raw+lv_off(9).    "lấy 9 ký tự cuối
      ELSE.
        lv_str9 = |{ lv_raw WIDTH = 9 ALIGN = RIGHT PAD = '0' }|. "pad đủ 9
      ENDIF.
      MODIFY ENTITIES OF zi_data_kb_thue0 IN LOCAL MODE
        ENTITY datakbthue0
        UPDATE FIELDS ( documentnumber )
        WITH VALUE #( ( %tky = <ls>-%tky documentnumber = 'N' && lv_str9 ) ).

*      APPEND VALUE #(
*                      %key      = <ls>-%key
*                      %is_draft = <ls>-%is_draft
*       ) to reported-datakbthue0.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_features.
  ENDMETHOD.

  METHOD precheck_create.
*    LOOP AT entities ASSIGNING FIELD-SYMBOL(<e>).
**      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
**        ID 'BUKRS' FIELD <e>-companycode
**        ID 'ACTVT' FIELD '01'.    " create
**      CHECK sy-subrc <> 0.
*      IF ( <e>-customer IS INITIAL AND <e>-supplier IS INITIAL )
*        or ( <e>-customer IS NOT INITIAL AND <e>-supplier IS NOT INITIAL ).
*
*      APPEND VALUE #( %cid = <e>-%cid ) TO failed-datakbthue0.
*        APPEND VALUE #(
*                        %cid                 = <e>-%cid
*                        %element-companycode = if_abap_behv=>mk-on
*                        %msg                 = new_message_with_text( text = |Check required for Supplier or Customer|
*                        ) ) TO reported-datakbthue0.
*
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<e>).
      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
        ID 'BUKRS' FIELD <e>-companycode
        ID 'ACTVT' FIELD '02'.    " change
      CHECK sy-subrc <> 0.
      APPEND VALUE #( %cid                 = <e>-%cid_ref ) TO failed-datakbthue0.
      APPEND VALUE #(
                      %cid                 = <e>-%cid_ref
                      %element-companycode = if_abap_behv=>mk-on
                      %msg                 = new_message_with_text( text = |Not authorized for company code { <e>-companycode }|
                      ) ) TO reported-datakbthue0.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
    READ ENTITY IN LOCAL MODE zi_data_kb_thue0
    FIELDS ( companycode ) WITH CORRESPONDING #( keys )
    RESULT DATA(rows).
    LOOP AT rows ASSIGNING FIELD-SYMBOL(<r>).
      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
        ID 'BUKRS' FIELD <r>-companycode
        ID 'ACTVT' FIELD '06'.    " delete
      CHECK sy-subrc <> 0.

      READ TABLE keys WITH KEY draft COMPONENTS %tky = <r>-%tky ASSIGNING FIELD-SYMBOL(<k>).

      APPEND VALUE #( %cid = <k>-%cid_ref ) TO failed-datakbthue0.

      APPEND VALUE #(
        %cid                 = <k>-%cid_ref
        %element-companycode = if_abap_behv=>mk-on
        %msg                 = new_message_with_text( text = |Not authorized for company code { <r>-companycode }|
        ) ) TO reported-datakbthue0.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculateprice.

    MODIFY ENTITIES OF zi_data_kb_thue0 IN LOCAL MODE
        ENTITY datakbthue0
          EXECUTE recalcprice
          FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD recalcprice.


    " Lấy dữ liệu các bản ghi đang được sửa
    READ ENTITIES OF zi_data_kb_thue0 IN LOCAL MODE
      ENTITY datakbthue0
      FIELDS ( doanhsonguyente doanhsovnd quantity dongianguyente dongiavnd loaitiente )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_rows).

    LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<ls>).

      " Chỉ tính lại khi có thay đổi số tiền/quantity (tránh ghi đè không cần thiết)
      DATA(lv_change_relevant) = abap_false.
      READ TABLE keys ASSIGNING FIELD-SYMBOL(<lk>)
           WITH KEY %tky = <ls>-%tky.
      IF sy-subrc = 0.
        IF <lk>-%is_draft                = abap_true. "create lần đầu
          lv_change_relevant = abap_true.
        ENDIF.
      ENDIF.

      IF lv_change_relevant = abap_false.
*        CONTINUE.
      ENDIF.

      " Tránh chia 0
      DATA(lv_qty) = CONV decfloat34( <ls>-quantity ).

      DATA: lv_dg_nt   TYPE decfloat34.
      DATA: lv_dg_vnd TYPE decfloat34.

      IF lv_qty IS INITIAL.
        lv_dg_nt  = 0.
        lv_dg_vnd = 0.
      ELSE.
        " Đơn giá = Doanh số / Số lượng
        lv_dg_nt  = CONV decfloat34( <ls>-doanhsonguyente ) / lv_qty.
        lv_dg_vnd = CONV decfloat34( <ls>-doanhsovnd )      / lv_qty * 100.
      ENDIF.

      " --- Làm tròn theo loại tiền tệ ---
      DATA(lv_curr) = to_upper( <ls>-loaitiente ).
      " Yêu cầu: nếu loại tiền tệ là VND → Đơn giá nguyên tệ không có số thập phân
      " --- Làm tròn ---
      IF lv_curr = 'VND'.
        " yêu cầu: Đơn giá nguyên tệ không có số thập phân
        lv_dg_nt = lv_dg_nt * 100.
        lv_dg_nt  = round( val = lv_dg_nt  dec = 0  mode = cl_abap_math=>round_half_up ).
      ELSE.
        " ngoại tệ: ví dụ 2 số lẻ
        lv_dg_nt  = round( val = lv_dg_nt  dec = 5  mode = cl_abap_math=>round_half_up ).
      ENDIF.

      " VND: đơn giá VND thường 0 lẻ
      lv_dg_vnd   = round( val = lv_dg_vnd dec = 0  mode = cl_abap_math=>round_half_up ).

      " (Tuỳ chọn) làm tròn theo tiền tệ nếu cần:
      " lv_dg_nt  = cl_abap_math=>round( val = lv_dg_nt  dec = 2 ).
      " lv_dg_vnd = cl_abap_math=>round( val = lv_dg_vnd dec = 0 ). "VND thường 0 lẻ

      " Ghi ngược lại 2 field đơn giá
      MODIFY ENTITIES OF zi_data_kb_thue0 IN LOCAL MODE
        ENTITY datakbthue0
        UPDATE FIELDS ( dongianguyente dongiavnd )
        WITH VALUE #(
          ( %tky           = <ls>-%tky
            dongianguyente = lv_dg_nt
            dongiavnd      = lv_dg_vnd
          )
      )
        FAILED   DATA(ls_failed)
        REPORTED DATA(ls_reported).

    ENDLOOP.

  ENDMETHOD.

  METHOD setdefaultvnd.

    "Lấy các bản ghi vừa tạo
    READ ENTITIES OF zi_data_kb_thue0 IN LOCAL MODE
      ENTITY datakbthue0
      FIELDS ( loaitienvnd )
      WITH CORRESPONDING #( keys )
      RESULT DATA(rows).

    "Chỉ set cho những bản ghi mà LoaiTienVND còn trống
    IF rows IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zi_data_kb_thue0 IN LOCAL MODE
      ENTITY datakbthue0
      UPDATE FIELDS ( loaitienvnd )
      WITH VALUE #(
                    FOR r IN rows
                    WHERE ( loaitienvnd IS INITIAL )
                          ( %tky = r-%tky loaitienvnd = 'VND' )
    )
      FAILED DATA(ls_failed) REPORTED DATA(ls_reported).

  ENDMETHOD.

  METHOD getdefaultsforcreate.

    "Loop qua các instance đang được tạo (chỉ có %cid)
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<k>).

      "Chèn dòng tương ứng vào RESULT, map theo %cid
      INSERT VALUE #( %cid = <k>-%cid ) INTO TABLE result
        ASSIGNING FIELD-SYMBOL(<r>).

      "Prefill giá trị mặc định cho UI
      <r>-%param-loaitienvnd = 'VND'.

    ENDLOOP.

  ENDMETHOD.

  METHOD downloadfile.
    DATA lt_file TYPE STANDARD TABLE OF ty_file_upload WITH DEFAULT KEY.

    "XCOライブラリを使用したExcelファイルの書き込み
    DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
    DATA(lo_worksheet) = lo_write_access->get_workbook(
        )->worksheet->at_position( 1 ).

    DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
                               )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                               )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'F' )
                               )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
                               )->get_pattern( ).

    "ヘッダの設定（すべての項目はstring型）

    lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_from( REF #( lt_file )
        )->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    SELECT SINGLE * FROM zcore_tb_temppdf
    WHERE id = 'zuploadkbt0'
    INTO @DATA(ls_tb_temppdf).
    IF sy-subrc NE 0.
      DATA(lv_exist) = abap_false.
    ELSE.
      lv_exist = abap_true.
    ENDIF.

    IF NOT lv_exist IS NOT INITIAL.
      result = VALUE #( FOR key IN keys (
                        %cid   = key-%cid
                        %param = VALUE #( filecontent   = lv_file_content
                                          filename      = 'TemplateUpload'
                                          fileextension = 'xlsx'
                                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                        ) ).
    ELSE.
      result = VALUE #( FOR key IN keys (
                        %cid   = key-%cid
                        %param = VALUE #( filecontent   = ls_tb_temppdf-file_content
                                          filename      = 'TemplateUpload'
                                          fileextension = 'xlsx'
                                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                        ) ).
    ENDIF.
  ENDMETHOD.

  METHOD fileupload.

    DATA: lt_file TYPE STANDARD TABLE OF ty_file_upload.

    DATA: lt_file_c TYPE TABLE FOR CREATE zi_data_kb_thue0,
          ls_file_c LIKE LINE OF lt_file_c.

    DATA: lt_check TYPE TABLE OF zr_kbt0_upload,
          ls_check LIKE LINE OF lt_check.

    READ TABLE keys INDEX 1 INTO DATA(k).

    IF sy-subrc EQ 0.
      FINAL(lv_filecontent) = k-%param-filecontent.
    ENDIF.

    "XCOライブラリを使用したExcelファイルの読み取り
    FINAL(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_filecontent )->read_access( ).
    FINAL(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

    FINAL(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    FINAL(lo_execute) = lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_file ) ).

    lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
               )->if_xco_xlsx_ra_operation~execute( ).

    DELETE lt_file WHERE stt IS INITIAL AND companycode IS INITIAL AND type IS INITIAL
                     AND mauhd IS INITIAL AND docreferenceid IS INITIAL AND invoicedate IS INITIAL
                     AND postingdate IS INITIAL AND supplier IS INITIAL AND customer IS INITIAL
                     AND itemtext IS INITIAL AND doanhsonguyente IS INITIAL AND doanhsovnd IS INITIAL
                     AND loaitiente IS INITIAL.

    IF lt_file IS NOT INITIAL.
      DO 1 TIMES.
        DELETE lt_file INDEX 1.
      ENDDO.
    ENDIF.

    LOOP AT lt_file ASSIGNING FIELD-SYMBOL(<l>).
      IF <l>-invoicedate IS NOT INITIAL.
        <l>-invoicedate = me->convert_date( i_date = <l>-invoicedate ).
      ENDIF.

      IF <l>-postingdate IS NOT INITIAL.
        <l>-postingdate = me->convert_date( i_date = <l>-postingdate ).
      ENDIF.
    ENDLOOP.

    DATA: lv_cnt TYPE int4.

    DATA: lv_header_filled TYPE abap_bool VALUE abap_false,
          ls_header        LIKE LINE OF lt_file.

    DATA: lv_fail TYPE abap_bool VALUE abap_false.

    SORT lt_file BY companycode type mauhd docreferenceid invoicedate stt ASCENDING.

    LOOP AT lt_file ASSIGNING FIELD-SYMBOL(<r>)
                    GROUP BY ( companycode = <r>-companycode
                               type = <r>-type
                               mauhd = <r>-mauhd
                               docreferenceid = <r>-docreferenceid
                               invoicedate = <r>-invoicedate )
                 ASCENDING
                 REFERENCE INTO DATA(grp).

      lv_cnt = 0.

      DATA(first) = grp->*.

      lv_header_filled = abap_false.

      lv_fail = abap_false.

      LOOP AT GROUP grp INTO DATA(ls_grp).
        lv_cnt += 1.

        IF lv_header_filled = abap_false.
          lv_header_filled = abap_true.
          MOVE-CORRESPONDING ls_grp TO ls_header.
        ENDIF.

        MOVE-CORRESPONDING ls_grp TO ls_check.

        IF lv_cnt > 1.

          ls_check-messagetype = 'E'.
          ls_check-messagetext = |Dòng { ls_grp-stt } Trùng với dòng { ls_header-stt } trong file Upload|.

          lv_fail = abap_true.

*          APPEND VALUE #(
*                %msg = new_message(
*                         id       = 'ZUPFIDOC'          "message class của bạn
*                         number   = '003'               "vd: 001 'Không tìm thấy tổ hợp {&1}/{&2}/{&3}/{&4}'
**                     V1       =
**                     V2       =
**                     V3       =
**                     V4       =
*                         severity = if_abap_behv_message=>severity-error )
*                " (optional) highlight các field
*              ) TO reported-datakbthue0.

          APPEND VALUE #(
*            %tky         = <ls_data>-%tky
            %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = ls_check-messagetext )
          ) TO reported-datakbthue0.

        ENDIF.

        SELECT COUNT(*) FROM zui_kb_thue0
        WHERE companycode = @ls_grp-companycode
          AND type = @ls_grp-type
          AND mauhd = @ls_grp-mauhd
          AND documentreferenceid = @ls_grp-docreferenceid
          AND invoicedate = @ls_grp-invoicedate
          INTO @DATA(lv_count).
        IF sy-subrc EQ 0.
          ls_check-messagetype = 'E'.
          ls_check-messagetext = |Dòng { ls_grp-stt } đã tồn tại|.

          lv_fail = abap_true.

          APPEND VALUE #(
*            %tky         = <ls_data>-%tky
          %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = ls_check-messagetext )
          ) TO reported-datakbthue0.
        ENDIF.

        IF ls_grp-companycode IS INITIAL OR
        ls_grp-type IS INITIAL OR
        ls_grp-mauhd IS INITIAL OR
        ls_grp-docreferenceid IS INITIAL OR
        ls_grp-invoicedate IS INITIAL OR
        ls_grp-itemtext IS INITIAL OR
        ls_grp-doanhsonguyente IS INITIAL OR
        ls_grp-doanhsovnd IS INITIAL OR
        ls_grp-loaitiente IS INITIAL.

          ls_check-messagetype = 'E'.
          ls_check-messagetext = |STT: { ls_grp-stt } Check required field|.

          lv_fail = abap_true.

          APPEND VALUE #(
*            %tky         = <ls_data>-%tky
          %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = ls_check-messagetext )
          ) TO reported-datakbthue0.
        ENDIF.

        IF ls_grp-customer IS INITIAL AND ls_grp-supplier IS INITIAL.

          ls_check-messagetype = 'E'.
          ls_check-messagetext = |STT: { ls_grp-stt } Check required Customer or Supplier|.

          lv_fail = abap_true.

          APPEND VALUE #(
*            %tky         = <ls_data>-%tky
          %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = ls_check-messagetext )
          ) TO reported-datakbthue0.

        ENDIF.

        IF ls_grp-customer IS NOT INITIAL AND ls_grp-supplier IS NOT INITIAL.

          ls_check-messagetype = 'E'.
          ls_check-messagetext = |STT: { ls_grp-stt } Check required Customer or Supplier|.

          lv_fail = abap_true.

          APPEND VALUE #(
*            %tky         = <ls_data>-%tky
          %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = ls_check-messagetext )
          ) TO reported-datakbthue0.

        ENDIF.

        IF ls_grp-customer IS NOT INITIAL.
          ls_grp-customer = |{ ls_grp-customer ALPHA = IN WIDTH = 10 }|.

          SELECT COUNT(*) FROM i_customercompany
          WHERE customer = @ls_grp-customer
            AND companycode = @ls_grp-companycode
          INTO @lv_count.
          IF sy-subrc NE 0.
            ls_check-messagetype = 'E'.
            ls_check-messagetext = |STT: { ls_grp-stt } Does not exist Customer { ls_grp-customer }|.

            lv_fail = abap_true.

            APPEND VALUE #(
*            %tky         = <ls_data>-%tky
              %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = ls_check-messagetext )
            ) TO reported-datakbthue0.

          ENDIF.
        ENDIF.

        IF ls_grp-supplier IS NOT INITIAL.
          ls_grp-supplier = |{ ls_grp-supplier ALPHA = IN WIDTH = 10 }|.

          SELECT COUNT(*) FROM i_suppliercompany
                    WHERE supplier = @ls_grp-supplier
                      AND companycode = @ls_grp-companycode
                    INTO @lv_count.
          IF sy-subrc NE 0.
            ls_check-messagetype = 'E'.
            ls_check-messagetext = |STT: { ls_grp-stt } Does not exist Supplier { ls_grp-supplier }|.

            lv_fail = abap_true.

            APPEND VALUE #(
*            %tky         = <ls_data>-%tky
              %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = ls_check-messagetext )
            ) TO reported-datakbthue0.

          ENDIF.
        ENDIF.

        SELECT COUNT(*) FROM i_companycode
        WHERE companycode = @ls_grp-companycode
        INTO @lv_count.
        IF sy-subrc NE 0.
          ls_check-messagetype = 'E'.
          ls_check-messagetext = |STT: { ls_grp-stt } Does not exist Company Code { ls_grp-companycode }|.

          lv_fail = abap_true.

          APPEND VALUE #(
*            %tky         = <ls_data>-%tky
          %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = ls_check-messagetext )
          ) TO reported-datakbthue0.
        ENDIF.

        IF ls_grp-soluong IS NOT INITIAL AND ls_grp-dongiavnd IS INITIAL.
          ls_grp-dongiavnd = ls_grp-doanhsovnd / ls_grp-soluong.
        ENDIF.

        IF ls_grp-soluong IS NOT INITIAL AND ls_grp-dongianguyente IS INITIAL.
          ls_grp-dongianguyente = ls_grp-doanhsonguyente / ls_grp-soluong.
        ENDIF.

        DATA:
          ld_internal_number TYPE zui_kb_thue0-doanhsovnd,
          ld_output          TYPE char20.

        ls_grp-doanhsovnd = ls_grp-doanhsovnd / 100.

        IF ls_grp-loaitiente = 'VND'.
          ls_grp-doanhsonguyente = ls_grp-doanhsonguyente / 100.
        ENDIF.

        IF lv_fail = abap_false.
          ls_file_c = VALUE #(
              companycode         = ls_grp-companycode
              type                = ls_grp-type
              mauhd               = ls_grp-mauhd
              documentreferenceid = ls_grp-docreferenceid
              postingdate         = ls_grp-postingdate
              invoicedate         = ls_grp-invoicedate
              supplier            = ls_grp-supplier
              customer            = ls_grp-customer
              itemtext            = ls_grp-itemtext
              doanhsovnd          = ls_grp-doanhsovnd
              dongiavnd           = ls_grp-dongiavnd
              loaitienvnd         = 'VND'
              quantity            = ls_grp-soluong
              baseunit            = ls_grp-dvt
              doanhsonguyente     = ls_grp-doanhsonguyente
              dongianguyente      = ls_grp-dongianguyente
              loaitiente          = ls_grp-loaitiente
              tenmavanglai        = ls_grp-tenmavanglai
              mstmavanglai        = ls_grp-mstmavanglai
              note                = ls_grp-note
          ).

          APPEND ls_file_c TO lt_file_c.
          CLEAR: ls_file_c.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

    IF lv_fail = abap_false.

      MODIFY ENTITIES OF zi_data_kb_thue0 IN LOCAL MODE
        ENTITY datakbthue0
        CREATE AUTO FILL CID FIELDS (
                            companycode         "= ls_grp-companycode
                            type                "= ls_grp-type
                            mauhd               "= ls_grp-mauhd
                            documentreferenceid "= ls_grp-docreferenceid
                            postingdate         "= ls_grp-postingdate
                            invoicedate         "= ls_grp-invoicedate
                            supplier            "= ls_grp-supplier
                            customer            "= ls_grp-customer
                            itemtext            "= ls_grp-itemtext
                            doanhsovnd          "= ls_grp-doanhsovnd
                            dongiavnd           "= ls_grp-dongiavnd
                            loaitienvnd         "= ls_grp-loai
                            quantity            "= ls_grp-soluong
                            baseunit            "= ls_grp-dvt
                            doanhsonguyente     "= ls_grp-doanhsonguyente
                            dongianguyente      "= ls_grp-dongianguyente
                            loaitiente          "= ls_grp-loaitiente
                            tenmavanglai        "= ls_grp-tenmavanglai
                            mstmavanglai        "= ls_grp-mstmavanglai
                            note
                          ) WITH lt_file_c
        MAPPED DATA(lt_mapped_create)
        REPORTED DATA(lt_mapped_reported)
        FAILED DATA(lt_failed_create).

    ENDIF.

  ENDMETHOD.

  METHOD convert_date.
    " i_date  : có thể là serial Excel (ví dụ 45234) hoặc chuỗi 'DD/MM/YYYY' (có thể kèm giờ)
    " rv_dats : type string (YYYYMMDD). Có thể đổi sang TYPE d nếu muốn.

    DATA: lv_serial TYPE decfloat34,
          lv_days_i TYPE i,
          lv_dats   TYPE d.

    DATA: lv_text TYPE string.
    lv_text = CONV string( i_date ).
    CONDENSE lv_text NO-GAPS.

    IF lv_text CS '/' OR lv_text CS '-' OR lv_text CS '.'.
      "--- Trường hợp chuỗi ngày (ưu tiên DD/MM/YYYY, chấp nhận dd/mm/yyyy HH:MM[:SS]) ---
      "   Cắt bỏ phần giờ nếu có
      SPLIT lv_text AT space INTO lv_text DATA(lv_time_ignored).

      "   Cho phép dấu phân cách là '/' hoặc '-'
      DATA(lv_sep) =  COND string( WHEN lv_text CS '-' THEN '-'
                                   WHEN lv_text CS '.' THEN '.'
                                   ELSE '/' ) .

      DATA: lv_dd_raw TYPE string,
            lv_mm_raw TYPE string,
            lv_yy_raw TYPE string.

      SPLIT lv_text AT lv_sep INTO lv_dd_raw lv_mm_raw lv_yy_raw.

      "   Một số file có dd/mm/yy → xử lý 2 chữ số năm
      DATA:lv_dd   TYPE i,
           lv_mm   TYPE i,
           lv_yyyy TYPE i.

      lv_dd   = CONV i( lv_dd_raw ).
      lv_mm   = CONV i( lv_mm_raw ).
      lv_yyyy = CONV i( lv_yy_raw ).

      IF strlen( lv_yy_raw ) = 2.
        " Quy ước: 00–69 → 2000–2069; 70–99 → 1970–1999 (tuỳ chính sách của bạn)
        IF lv_yyyy <= 69.
          lv_yyyy = lv_yyyy + 2000.
        ELSE.
          lv_yyyy = lv_yyyy + 1900.
        ENDIF.
      ENDIF.

      "   Kiểm tra hợp lệ đơn giản
      IF lv_dd BETWEEN 1 AND 31 AND
         lv_mm BETWEEN 1 AND 12 AND
         lv_yyyy BETWEEN 1900 AND 9999.

        "   Build YYYYMMDD
        DATA(lv_date_str) = |{ lv_yyyy WIDTH = 4 ALIGN = RIGHT PAD = '0' }{ lv_mm WIDTH = 2 ALIGN = RIGHT PAD = '0' }{ lv_dd WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.
        lv_dats = lv_date_str.               " move to type D
        rv_dats = CONV string( lv_dats ).    " trả ra string YYYYMMDD

      ELSE.
        " Không hợp lệ → tuỳ chọn: trả initial hoặc RAISE
        CLEAR rv_dats.
        " RAISE EXCEPTION NEW cx_sy_conversion_no_date( ).
      ENDIF.

    ELSE.
      "--- Trường hợp serial Excel ---
      "  Lưu ý: Excel base = 1899-12-30 (đã trừ bug Feb-1900)
      "  c_excel_base là hằng type d = '18991230' (ví dụ)
      lv_serial = CONV decfloat34( i_date ).
      lv_days_i = CONV i( lv_serial ).
      lv_dats   = c_excel_base + lv_days_i.
      rv_dats   = CONV string( lv_dats ).
    ENDIF.
  ENDMETHOD.

  METHOD checkrequired.
    "Đọc dữ liệu người dùng đang save
    READ ENTITIES OF zi_data_kb_thue0 IN LOCAL MODE
      ENTITY datakbthue0
      FIELDS ( uuid companycode documentreferenceid invoicedate supplier )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_new).

    IF lt_new IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE keys INDEX 1 INTO DATA(k).

    LOOP AT lt_new INTO DATA(ls_new).
      IF ( ls_new-customer IS INITIAL AND ls_new-supplier IS INITIAL )
        OR ( ls_new-customer IS NOT INITIAL AND ls_new-supplier IS NOT INITIAL ).

        APPEND VALUE #( %tky = ls_new-%tky ) TO failed-datakbthue0.
        APPEND VALUE #(
                        %tky              = ls_new-%tky
                        %element-customer = if_abap_behv=>mk-on
                        %element-supplier = if_abap_behv=>mk-on
                        %msg              = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Check required for Supplier or Customer|
                        ) ) TO reported-datakbthue0.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

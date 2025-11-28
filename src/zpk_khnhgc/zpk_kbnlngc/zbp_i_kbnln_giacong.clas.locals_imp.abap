CLASS lhc_kbnlngiacong DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF file_status,
        open      TYPE c LENGTH 1 VALUE 'M', "Not process
        accepted  TYPE c LENGTH 1 VALUE 'A', "Accepted
        rejected  TYPE c LENGTH 1 VALUE 'X', "Rejected
        completed TYPE c LENGTH 1 VALUE 'D', "Done
        inprocess TYPE c LENGTH 1 VALUE 'P', "In process
        error     TYPE c LENGTH 1 VALUE 'E', "Error
        success   TYPE c LENGTH 1 VALUE 'S', "Success
      END OF file_status.

    CONSTANTS c_excel_base TYPE d VALUE '18991230'.

    TYPES: BEGIN OF ty_file_upload,
             workcenter        TYPE string,
             hierarchynode     TYPE string,
             plant             TYPE string,
             dailyproductivity TYPE string,
             fromdate          TYPE string,
             todate            TYPE string,
           END OF ty_file_upload,

           tt_file  TYPE STANDARD TABLE OF ty_file_upload WITH EMPTY KEY,
           tt_years TYPE STANDARD TABLE OF gjahr WITH EMPTY KEY.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR kbnlngiacong RESULT result.

    METHODS precheckdata FOR MODIFY
      IMPORTING keys FOR ACTION kbnlngiacong~precheckdata RESULT result.

    METHODS downloadfile FOR MODIFY
      IMPORTING keys FOR ACTION kbnlngiacong~downloadfile RESULT result.

    METHODS fileupload FOR MODIFY
      IMPORTING keys FOR ACTION kbnlngiacong~fileupload.

    METHODS updatekbsnlamviec FOR DETERMINE ON SAVE
      IMPORTING keys FOR kbnlngiacong~updatekbsnlamviec.

    METHODS updatecds FOR DETERMINE ON MODIFY
      IMPORTING keys FOR kbnlngiacong~updatecds.

    METHODS getdefaultsforcreate FOR READ
      IMPORTING keys FOR FUNCTION kbnlngiacong~getdefaultsforcreate RESULT result.

    METHODS checkdata FOR VALIDATE ON SAVE
      IMPORTING keys FOR kbnlngiacong~checkdata.

    METHODS checkdataoncreate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR kbnlngiacong~checkdataoncreate.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE kbnlngiacong.

    METHODS getexceldata IMPORTING iv_content     TYPE xstring
                         RETURNING VALUE(et_file) TYPE tt_file.

    METHODS convert_date IMPORTING i_date         TYPE string
                         RETURNING VALUE(rv_dats) TYPE string.

    METHODS close_previous_interval
      IMPORTING
        is_new TYPE zi_kbnln_giacong.   " cấu trúc runtime của entity (projection)

    METHODS get_years_between IMPORTING iv_from TYPE d iv_to TYPE d
  RETURNING VALUE(rt_years) TYPE tt_years.

ENDCLASS.

CLASS lhc_kbnlngiacong IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    LOOP AT entities
                ASSIGNING FIELD-SYMBOL(<f_entities>)
                WHERE uuid IS NOT INITIAL.

      APPEND CORRESPONDING #( <f_entities> ) TO mapped-kbnlngiacong.

    ENDLOOP.

    DATA(lt_file) = entities.

    DELETE lt_file WHERE uuid IS NOT INITIAL.

    IF lt_file IS INITIAL.
      RETURN.
    ENDIF.


    LOOP AT lt_file ASSIGNING <f_entities>.

      TRY.
          <f_entities>-uuid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
          IF <f_entities>-produnivhierarchynode+0(1) = '0'.
            <f_entities>-hierarchynode = <f_entities>-produnivhierarchynode.
          ELSE.
            <f_entities>-hierarchynode = `0` && <f_entities>-produnivhierarchynode.
          ENDIF.

        CATCH cx_uuid_error.

          APPEND VALUE #( %cid      = <f_entities>-%cid
                          %key      = <f_entities>-%key
                          %is_draft = <f_entities>-%is_draft
          )
                 TO reported-kbnlngiacong.

          APPEND VALUE #( %cid      = <f_entities>-%cid
                          %key      = <f_entities>-%key
                          %is_draft = <f_entities>-%is_draft )
                 TO failed-kbnlngiacong.

          EXIT.
      ENDTRY.

      APPEND VALUE #( %cid      = <f_entities>-%cid
                      %key      = <f_entities>-%key
                      %is_draft = <f_entities>-%is_draft )
       TO mapped-kbnlngiacong.

    ENDLOOP.

  ENDMETHOD.

  METHOD precheckdata.
    TYPES: BEGIN OF lty_check,
             data    TYPE ty_file_upload,
             msgtype TYPE zde_char1,
             msgtext TYPE string,
           END OF lty_check.

    DATA: lt_check TYPE STANDARD TABLE OF lty_check WITH EMPTY KEY,
          ls_check LIKE LINE OF lt_check.

    READ TABLE keys INDEX 1 INTO DATA(k).

    DATA(lt_file) = me->getexceldata( iv_content = k-%param-filecontent ).
    DATA ls_file LIKE LINE OF lt_file.

    LOOP AT lt_file INTO ls_file.
      MOVE-CORRESPONDING ls_file TO ls_check-data.

      SELECT COUNT(*) FROM i_workcenter
      WHERE workcenter = @ls_file-workcenter
        AND plant = @ls_file-plant
      INTO @DATA(lv_count).
      IF sy-subrc NE 0.
        ls_check-msgtype = file_status-error.
        ls_check-msgtext = |Does not exist WorkCenter { ls_file-workcenter } - Plant { ls_file-plant }|.
      ENDIF.

      SELECT COUNT(*) FROM i_plant
      WHERE plant = @ls_file-plant
      INTO @lv_count.
      IF sy-subrc NE 0.
        ls_check-msgtype = file_status-error.
        ls_check-msgtext = |Does not exist Plant { ls_file-plant }|.
      ENDIF.

*      IF ls_file-hierarchynode+0(1) NE '0'.
*        ls_file-hierarchynode = `0` && ls_file-hierarchynode.
*      ENDIF.

      SELECT COUNT(*) FROM i_produnivhierarchynodebasic
      WHERE produnivhierarchynode = @ls_file-hierarchynode
        AND produnivhierarchy = 'PH_MANUFACTURING'
        AND hierarchynodelevel = '000003'
      INTO @lv_count.
      IF sy-subrc NE 0.
        ls_check-msgtype = file_status-error.
        ls_check-msgtext = |Does not exist Product { ls_file-hierarchynode }|.
      ENDIF.

      IF ls_file-fromdate IS INITIAL.
        ls_check-msgtype = file_status-error.
        ls_check-msgtext = |Check Required from date|.

      ELSE.
        DATA(lv_frdate) = me->convert_date( i_date = ls_file-fromdate ).
      ENDIF.

      IF ls_file-todate IS INITIAL.

      ELSE.
        DATA(lv_todate) = me->convert_date( i_date = ls_file-todate ).
      ENDIF.

      ls_check-data-fromdate = |{ lv_frdate+6(2) }/{ lv_frdate+4(2) }/{ lv_frdate+0(4) }|.
      ls_check-data-todate = |{ lv_todate+6(2) }/{ lv_todate+4(2) }/{ lv_todate+0(4) }|.

      APPEND ls_check TO lt_check.

    ENDLOOP.

    DATA lt_map TYPE /ui2/cl_json=>name_mappings.
*** Create JSON
    DATA(json) = /ui2/cl_json=>serialize(
      data = lt_check
*     name_mappings = lt_map
    ).

    DATA: lv_name TYPE string.
    lv_name = |Precheck_{ sy-datlo }|.

    result = VALUE #(
                FOR key IN keys (
*                       %cid_ref = key-%cid_ref
*                       %tky   = key-%tky
                %cid   = key-%cid
                %param = VALUE #( filecontent   = json
                                  filename      = lv_name
                                  fileextension = 'json'
*                                              mimeType      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                  mimetype      = 'application/json'
                                  )
                )
    ).

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
*    LT_FILE = VALUE #(

*                     ).

    lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_from( REF #( lt_file )
        )->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    SELECT SINGLE * FROM zcore_tb_temppdf
    WHERE id = 'zkbnlngc'
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
                                          filename      = 'TemplateUploadKBNLNGC'
                                          fileextension = 'xlsx'
                                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                        ) ).
    ELSE.
      result = VALUE #( FOR key IN keys (
                        %cid   = key-%cid
                        %param = VALUE #( filecontent   = ls_tb_temppdf-file_content
                                          filename      = 'TemplateUploadKBNLNGC'
                                          fileextension = 'xlsx'
                                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                        ) ).
    ENDIF.

  ENDMETHOD.

  METHOD fileupload.

    DATA: lt_file_c TYPE TABLE FOR CREATE zi_kbnln_giacong,
          ls_file_c LIKE LINE OF lt_file_c.

    READ TABLE keys INDEX 1 INTO DATA(k).

    DATA(lt_file) = me->getexceldata( iv_content = k-%param-filecontent ).
    DATA ls_file LIKE LINE OF lt_file.

    LOOP AT lt_file INTO ls_file.

      IF ls_file-fromdate IS NOT INITIAL.
        DATA(lv_frdate) = me->convert_date( i_date = ls_file-fromdate ).
      ENDIF.

      IF ls_file-todate IS NOT INITIAL.
        DATA(lv_todate) = me->convert_date( i_date = ls_file-todate ).
      ELSE.
        lv_todate = '99991231'.
      ENDIF.

      IF ls_file-hierarchynode+0(1) NE '0'.
        DATA(lv_hierarchynode) = `0` && ls_file-hierarchynode.
      ELSE.
        lv_hierarchynode = ls_file-hierarchynode.
      ENDIF.

      TRY.
          " <f_file> là bản ghi cha đọc từ READ ENTITIES
          ls_file_c = VALUE #(
*            uuid    type sysuuid_x16
            workcenter            = ls_file-workcenter      "type arbpl
            hierarchynode         = lv_hierarchynode   "type abap.char(50)
            plant                 = ls_file-plant           "type werks_d
            produnivhierarchynode = ls_file-hierarchynode
            dailyproductivity     = ls_file-dailyproductivity "type p length 8 decimals 0
            fromdate              = lv_frdate        "type d
            todate                = lv_todate        "type d

*            createdby   "type abp_creation_user
*            createdat   "type abp_creation_tstmpl
*            locallastchangedby  "type abp_locinst_lastchange_user
*            locallastchangedat  "type abp_locinst_lastchange_tstmpl
*            lastchangedat   "type abp_lastchange_tstmpl

          ).

        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.

      APPEND ls_file_c TO lt_file_c.
      CLEAR: ls_file_c.

    ENDLOOP.

    IF lt_file_c IS NOT INITIAL.
      MODIFY ENTITIES OF zi_kbnln_giacong IN LOCAL MODE
        ENTITY kbnlngiacong
        CREATE AUTO FILL CID FIELDS (
*                          uuid
                           workcenter          "type arbpl
                           hierarchynode       "type abap.char(50)
                           plant               "type werks_d
                           produnivhierarchynode
                           dailyproductivity   "type p length 8 decimals 0
                           fromdate            "type d
                           todate              "type d
                        ) WITH lt_file_c
        MAPPED DATA(lt_mapped_create)
        REPORTED DATA(lt_reported_create)
        FAILED DATA(lt_failed_create).
    ENDIF.

  ENDMETHOD.

  METHOD updatekbsnlamviec.

    " 1) Đọc các dòng GiaCông vừa tác động
    READ ENTITIES OF zi_kbnln_giacong IN LOCAL MODE
      ENTITY kbnlngiacong
        FIELDS ( uuid workcenter hierarchynode plant produnivhierarchynode fromdate todate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_gc).

    IF lt_gc IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_gc ASSIGNING FIELD-SYMBOL(<ls>).
      IF <ls>-hierarchynode IS INITIAL.
        <ls>-hierarchynode = '0' && <ls>-produnivhierarchynode.

        MODIFY ENTITIES OF zi_kbnln_giacong IN LOCAL MODE
        ENTITY kbnlngiacong
        UPDATE FIELDS ( hierarchynode )
        WITH VALUE #(
          ( %tky          = <ls>-%tky
            hierarchynode = <ls>-hierarchynode
          )
        )
        FAILED   DATA(ls_failed)
        REPORTED DATA(ls_reported).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD convert_date.
    " i_date  : có thể là serial Excel (ví dụ 45234) hoặc chuỗi 'DD/MM/YYYY' (có thể kèm giờ)
    " rv_dats : type string (YYYYMMDD). Có thể đổi sang TYPE d nếu muốn.

    CLEAR: rv_dats.

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

  METHOD getexceldata.

    DATA: lt_file TYPE STANDARD TABLE OF ty_file_upload.

    FINAL(lv_filecontent) = iv_content.

    CHECK sy-subrc = 0.

    "XCOライブラリを使用したExcelファイルの読み取り
    FINAL(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_filecontent )->read_access( ).
    FINAL(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

    FINAL(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    FINAL(lo_execute) = lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_file ) ).

    lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
               )->if_xco_xlsx_ra_operation~execute( ).

    IF lt_file IS NOT INITIAL.
      DELETE lt_file INDEX 1.
    ENDIF.

    IF lt_file IS NOT INITIAL.
      MOVE-CORRESPONDING lt_file TO et_file.
    ENDIF.
  ENDMETHOD.

  METHOD updatecds.
    " Đọc các bản ghi vừa được modify (có thay Fromdate/Todate)
    READ ENTITIES OF zi_kbnln_giacong IN LOCAL MODE
      ENTITY kbnlngiacong
        FIELDS ( uuid workcenter hierarchynode plant dailyproductivity fromdate todate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_now)
      FAILED  DATA(lt_failed_r)
      REPORTED DATA(lt_reported_r).

    DATA: ls_now TYPE zi_kbnln_giacong.

    LOOP AT lt_now ASSIGNING FIELD-SYMBOL(<ls_now>).
      " Chuẩn hóa ngày: nếu không cung cấp Todate thì coi như open-ended
      IF <ls_now>-todate IS INITIAL.
        <ls_now>-todate = '99991231'.
      ENDIF.

      MOVE-CORRESPONDING <ls_now> TO ls_now.
      " Đóng interval cũ (nếu có) theo logic hình minh họa
      me->close_previous_interval( is_new = ls_now ).
    ENDLOOP.
  ENDMETHOD.

  METHOD close_previous_interval.
    " is_new: dòng vừa tạo/sửa (đã có Fromdate, Todate)
    DATA(lv_wc)  = is_new-workcenter.
    DATA(lv_node) = is_new-hierarchynode.   " Loại hàng may
    DATA(lv_plant) = is_new-plant.
    DATA(lv_fnew) = is_new-fromdate.
    DATA(lv_uuid) = is_new-uuid.

    IF lv_fnew IS INITIAL.
      RETURN.
    ENDIF.

    " 1) Tìm 'dòng hiện hành' cùng key (workcenter/node/plant) có khoảng ngày giao với Fromdate mới.
    "    Ưu tiên: todate = 99991231 (open-ended). Nếu không, lấy dòng có ToDate > FromDate_mới.
    DATA: ls_prev TYPE zui_kbnlngc.

    " (a) Thử tìm dòng open-ended
    SELECT SINGLE *
      FROM zui_kbnlngc
      WHERE workcenter     = @lv_wc
        AND hierarchynode  = @lv_node
        AND plant          = @lv_plant
        AND uuid          <> @lv_uuid
        AND todate         = '99991231'
    INTO @ls_prev.

    " (b) Nếu không có open-ended, tìm dòng có ToDate > FromDate_mới (đang bao phủ hoặc vượt qua mốc)
    IF sy-subrc <> 0.
      CLEAR ls_prev.
      DATA lt_prev TYPE STANDARD TABLE OF zui_kbnlngc WITH EMPTY KEY.
      SELECT *
        FROM zui_kbnlngc
        WHERE workcenter    = @lv_wc
          AND hierarchynode = @lv_node
          AND plant         = @lv_plant
          AND uuid         <> @lv_uuid
          AND todate       >= @lv_fnew      " còn hiệu lực tại thời điểm F_new
          AND fromdate     <= @lv_fnew
        INTO TABLE @lt_prev.
      IF sy-subrc = 0.
        SORT lt_prev BY todate DESCENDING.
        READ TABLE lt_prev INDEX 1 INTO ls_prev.
      ENDIF.
    ENDIF.

    IF ls_prev IS INITIAL.
      RETURN. " không có dòng nào cần đóng → thoát
    ENDIF.

    " 2) Tính ngày kết thúc mới = Fromdate_mới - 1
    DATA(lv_new_end) = lv_fnew - 1.

    " 3) Chỉ update khi end mới thực sự nhỏ hơn todate hiện tại (tránh update lùi ngược/âm)
    IF lv_new_end IS INITIAL OR lv_new_end < ls_prev-fromdate.
      " Nếu khoảng mới bắt đầu trước hoặc bằng fromdate của dòng cũ → không hợp lệ để 'đóng'
      RETURN.
    ENDIF.

    IF ls_prev-todate > lv_new_end.
      " Update dòng cũ: ToDate = FromDate_mới - 1
      MODIFY ENTITIES OF zi_kbnln_giacong IN LOCAL MODE
        ENTITY kbnlngiacong
        UPDATE FIELDS ( todate )
        WITH VALUE #( ( uuid   = ls_prev-uuid
                        todate = lv_new_end ) )
        FAILED   DATA(lt_failed_u)
        REPORTED DATA(lt_reported_u).
    ENDIF.

  ENDMETHOD.

  METHOD get_years_between.

    DATA(lv_to)   = COND d( WHEN iv_to IS INITIAL THEN '99991231' ELSE iv_to ).

    DATA lv_y1 TYPE gjahr .  " YYYY từ iv_from
    DATA lv_y2 TYPE gjahr .    " YYYY từ iv_to

    lv_y1 = CONV gjahr( iv_from+0(4) ).
    lv_y2 = CONV gjahr( lv_to+0(4) ).

    DO lv_y2 - lv_y1 + 1 TIMES.
      APPEND lv_y1 TO rt_years.
      lv_y1 += 1.
    ENDDO.

  ENDMETHOD.

  METHOD getdefaultsforcreate.

    "Loop qua các instance đang được tạo (chỉ có %cid)
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<k>).

      "Chèn dòng tương ứng vào RESULT, map theo %cid
      INSERT VALUE #( %cid = <k>-%cid ) INTO TABLE result
        ASSIGNING FIELD-SYMBOL(<r>).

      "Prefill giá trị mặc định cho UI
      <r>-%param-todate = '99991231'.

    ENDLOOP.

  ENDMETHOD.

  METHOD checkdata.
    READ ENTITIES OF zi_kbnln_giacong IN LOCAL MODE
        ENTITY kbnlngiacong
        FIELDS ( uuid workcenter produnivhierarchynode plant )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_new).

    IF lt_new IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE keys INDEX 1 INTO DATA(k).

    LOOP AT lt_new INTO DATA(ls_new).
      SELECT COUNT(*) FROM i_workcenter
      WITH PRIVILEGED ACCESS
        WHERE workcenter = @ls_new-workcenter
          AND plant = @ls_new-plant
        INTO @DATA(lv_count).
      IF sy-subrc NE 0.
        APPEND VALUE #( %tky = ls_new-%tky ) TO failed-kbnlngiacong.
        APPEND VALUE #(
                        %tky                = ls_new-%tky
                        %element-workcenter = if_abap_behv=>mk-on
                        %element-plant      = if_abap_behv=>mk-on
                        %msg                = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Does not exist WorkCenter { ls_new-workcenter } - Plant { ls_new-plant }|
                        ) ) TO reported-kbnlngiacong.
      ENDIF.

      SELECT COUNT(*) FROM i_plant
      WITH PRIVILEGED ACCESS
      WHERE plant = @ls_new-plant
      INTO @lv_count.
      IF sy-subrc NE 0.
        APPEND VALUE #( %tky = ls_new-%tky ) TO failed-kbnlngiacong.
        APPEND VALUE #(
                        %tky           = ls_new-%tky
*                        %element-workcenter = if_abap_behv=>mk-on
                        %element-plant = if_abap_behv=>mk-on
                        %msg           = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Does not exist Plant { ls_new-plant }|
                        ) ) TO reported-kbnlngiacong.
      ENDIF.

      SELECT COUNT(*) FROM i_produnivhierarchynodebasic
      WITH PRIVILEGED ACCESS
      WHERE produnivhierarchynode = @ls_new-produnivhierarchynode
        AND produnivhierarchy = 'PH_MANUFACTURING'
        AND hierarchynodelevel = '000003'
      INTO @lv_count.
      IF sy-subrc NE 0.
        APPEND VALUE #( %tky = ls_new-%tky ) TO failed-kbnlngiacong.
        APPEND VALUE #(
                        %tky                           = ls_new-%tky
                        %element-produnivhierarchynode = if_abap_behv=>mk-on
                        %msg                           = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Does not exist Product { ls_new-produnivhierarchynode }|
                        ) ) TO reported-kbnlngiacong.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD checkdataoncreate.

*    READ ENTITIES OF zi_kbnln_giacong IN LOCAL MODE
*          ENTITY kbnlngiacong
*          FIELDS ( uuid workcenter produnivhierarchynode plant )
*          WITH CORRESPONDING #( keys )
*          RESULT DATA(lt_new).
*
*    IF lt_new IS INITIAL.
*      RETURN.
*    ENDIF.
*
*    READ TABLE keys INDEX 1 INTO DATA(k).
*
*    LOOP AT lt_new INTO DATA(ls_new).
*      SELECT COUNT(*) FROM i_workcenter
*      WITH PRIVILEGED ACCESS
*        WHERE workcenter = @ls_new-workcenter
*          AND plant = @ls_new-plant
*        INTO @DATA(lv_count).
*      IF sy-subrc NE 0.
**        APPEND VALUE #( %tky = ls_new-%tky ) TO failed-kbnlngiacong.
*        APPEND VALUE #(
*                        %tky                = ls_new-%tky
*                        %element-workcenter = if_abap_behv=>mk-on
*                        %element-plant      = if_abap_behv=>mk-on
*                        %msg                = new_message_with_text(
*                        severity = if_abap_behv_message=>severity-error
*                        text     = |Does not exist WorkCenter { ls_new-workcenter } - Plant { ls_new-plant }|
*                        ) ) TO reported-kbnlngiacong.
*      ENDIF.
*
*      SELECT COUNT(*) FROM i_plant
*      WITH PRIVILEGED ACCESS
*      WHERE plant = @ls_new-plant
*      INTO @lv_count.
*      IF sy-subrc NE 0.
**        APPEND VALUE #( %tky = ls_new-%tky ) TO failed-kbnlngiacong.
*        APPEND VALUE #(
*                        %tky           = ls_new-%tky
**                        %element-workcenter = if_abap_behv=>mk-on
*                        %element-plant = if_abap_behv=>mk-on
*                        %msg           = new_message_with_text(
*                        severity = if_abap_behv_message=>severity-error
*                        text     = |Does not exist Plant { ls_new-plant }|
*                        ) ) TO reported-kbnlngiacong.
*      ENDIF.
*
*      SELECT COUNT(*) FROM i_produnivhierarchynodebasic
*      WITH PRIVILEGED ACCESS
*      WHERE produnivhierarchynode = @ls_new-produnivhierarchynode
*        AND produnivhierarchy = 'PH_MANUFACTURING'
*        AND hierarchynodelevel = '000003'
*      INTO @lv_count.
*      IF sy-subrc NE 0.
**        APPEND VALUE #( %tky = ls_new-%tky ) TO failed-kbnlngiacong.
*        APPEND VALUE #(
*                        %tky                           = ls_new-%tky
*                        %element-produnivhierarchynode = if_abap_behv=>mk-on
*                        %msg                           = new_message_with_text(
*                        severity = if_abap_behv_message=>severity-error
*                        text     = |Does not exist Product { ls_new-produnivhierarchynode }|
*                        ) ) TO reported-kbnlngiacong.
*      ENDIF.
*
*    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_kbnln_giacong DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_kbnln_giacong IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

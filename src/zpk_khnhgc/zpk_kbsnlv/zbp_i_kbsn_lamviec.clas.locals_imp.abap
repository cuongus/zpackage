CLASS lsc_zi_kbsn_lamviec DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

  PRIVATE SECTION.

    METHODS log_changes
      IMPORTING
        iv_bo_name TYPE string
        iv_op      TYPE char1
        iv_uuid    TYPE sysuuid_x16
        is_old     TYPE zui_kbsnlv       " persistence struct BEFORE
        is_new     TYPE zui_kbsnlv       " persistence struct AFTER
        iv_reqid   TYPE sysuuid_x16.

    METHODS to_string
      IMPORTING i_any     TYPE any
      RETURNING VALUE(rv) TYPE string.

ENDCLASS.

CLASS lsc_zi_kbsn_lamviec IMPLEMENTATION.

  METHOD save_modified.

    TRY.
        DATA(lv_reqid) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.

    "=== CREATE ================================================================
    IF create-kbsnlamviec IS NOT INITIAL.
      " Đọc bản ghi vừa được chèn từ DB (để lấy hình AFTER chuẩn)
      SELECT * FROM zui_kbsnlv
        FOR ALL ENTRIES IN @create-kbsnlamviec
        WHERE uuid = @create-kbsnlamviec-uuid
        INTO TABLE @DATA(lt_after_c).

      LOOP AT lt_after_c ASSIGNING FIELD-SYMBOL(<a>).
        log_changes(
          iv_bo_name = 'ZI_KBSN_LAMVIEC'
          iv_op      = 'C'
          iv_uuid    = <a>-uuid
          is_old     = VALUE zui_kbsnlv( )        " rỗng
          is_new     = <a>
          iv_reqid   = lv_reqid ).
      ENDLOOP.
    ENDIF.

    "=== UPDATE ================================================================
    IF update-kbsnlamviec IS NOT INITIAL.
      " Trước khi update, framework đã ghi DB; để so sánh cần both BEFORE & AFTER
      " -> lấy BEFORE bằng SELECT theo keys trong update (trước SAVE bạn có thể cache; ở đây đơn giản dùng change log sau)
      " Cách làm: đọc DB hiện tại là AFTER, và đọc BEFORE bằng bảng shadow? Không có.
      " => Giải pháp thực dụng: dùng bản "before image" từ me->update-kbsnlamviec (chứa các field mới),
      "    còn BEFORE lấy từ DB trước khi gọi MODIFY? Trong saver, thời điểm này DB đã new.
      " -> Vì vậy ta SELECT 2 lần: lt_after_u (DB hiện tại), lt_before_u (DB trước? không còn).
      " => Cách đúng: đọc BEFORE ở đầu save_modified TRƯỚC khi bạn chỉnh gì vào DB.
      " Managed + additional save: DB write do framework làm sau saver, nên Ở ĐÂY DB vẫn là BEFORE. (Quan trọng!)
      " Do đó, đọc bây giờ chính là BEFORE.

      " 1) BEFORE
      SELECT * FROM zui_kbsnlv
        FOR ALL ENTRIES IN @update-kbsnlamviec
        WHERE uuid = @update-kbsnlamviec-uuid
        INTO TABLE @DATA(lt_before_u).

      " 2) AFTER: merge before với giá trị mới từ update-kbsnlamviec (vì DB chưa update).
      DATA lt_after_u TYPE STANDARD TABLE OF zui_kbsnlv WITH EMPTY KEY.
      lt_after_u = lt_before_u.
      LOOP AT update-kbsnlamviec ASSIGNING FIELD-SYMBOL(<u>).
        READ TABLE lt_after_u ASSIGNING FIELD-SYMBOL(<au>) WITH KEY uuid = <u>-uuid.
        IF sy-subrc = 0.
          " Áp các field có control flag = 'X' (chỉ field được update)
          " me->update-kbsnlamviec là entity runtime, có %control-<field>
          ASSIGN COMPONENT 'W1WORKINGDAYS' OF STRUCTURE <u>-%control TO FIELD-SYMBOL(<ctrl_any>).
          " Lặp động tất cả component của <u>
          DATA(lo_desc) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( <u> ) ).
          LOOP AT lo_desc->components ASSIGNING FIELD-SYMBOL(<cmp>).
            DATA(lv_name) = <cmp>-name.
            " bỏ các technical (%key, %control, v.v.)
            IF lv_name CP '%*'. CONTINUE. ENDIF.

            ASSIGN COMPONENT lv_name OF STRUCTURE <u>-%control TO FIELD-SYMBOL(<cflag>).
            IF sy-subrc = 0 AND <cflag> IS ASSIGNED AND <cflag> = abap_true.
              ASSIGN COMPONENT lv_name OF STRUCTURE <u> TO FIELD-SYMBOL(<val_new>).
              ASSIGN COMPONENT lv_name OF STRUCTURE <au> TO FIELD-SYMBOL(<val_after>).
              IF <val_new> IS ASSIGNED AND <val_after> IS ASSIGNED.
                <val_after> = <val_new>.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

      " 3) So sánh & log
      LOOP AT lt_before_u ASSIGNING FIELD-SYMBOL(<b>).
        READ TABLE lt_after_u ASSIGNING <au> WITH KEY uuid = <b>-uuid.
        IF sy-subrc = 0.
          log_changes(
            iv_bo_name = 'ZI_KBSN_LAMVIEC'
            iv_op      = 'U'
            iv_uuid    = <b>-uuid
            is_old     = <b>
            is_new     = <au>
            iv_reqid   = lv_reqid ).
        ENDIF.
      ENDLOOP.
    ENDIF.

    "=== DELETE ================================================================
    IF delete-kbsnlamviec IS NOT INITIAL.
      " BEFORE là DB hiện tại (chưa Physically delete)
      SELECT * FROM zui_kbsnlv
        FOR ALL ENTRIES IN @delete-kbsnlamviec
        WHERE uuid = @delete-kbsnlamviec-uuid
        INTO TABLE @DATA(lt_before_d).

      LOOP AT lt_before_d ASSIGNING FIELD-SYMBOL(<d>).
        log_changes(
          iv_bo_name = 'ZI_KBSN_LAMVIEC'
          iv_op      = 'D'
          iv_uuid    = <d>-uuid
          is_old     = <d>
          is_new     = VALUE zui_kbsnlv( )     " rỗng
          iv_reqid   = lv_reqid ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD log_changes.
    DATA(lo_desc) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( is_new ) ).

    DATA lt_log TYPE STANDARD TABLE OF zui_chg_log WITH EMPTY KEY.

    " vòng lặp toàn bộ field (loại technical, time stamps tùy ý)
    LOOP AT lo_desc->components ASSIGNING FIELD-SYMBOL(<cmp>).
      DATA(lv_name) = <cmp>-name.
      IF lv_name CP '%*'. CONTINUE. ENDIF.       " bỏ %key, %control
      " (tuỳ chọn) bỏ các cột audit của chính BO
      IF lv_name = 'LAST_CHANGED_AT' OR lv_name = 'LOCAL_LAST_CHANGED_AT'
       OR lv_name = 'CREATED_AT' OR lv_name = 'CREATED_BY'
       OR lv_name = 'LAST_CHANGED_BY' OR lv_name = 'LOCAL_LAST_CHANGED_BY'.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT lv_name OF STRUCTURE is_old TO FIELD-SYMBOL(<old>).
      ASSIGN COMPONENT lv_name OF STRUCTURE is_new TO FIELD-SYMBOL(<new>).

      DATA lv_old  TYPE string.
      DATA lv_new  TYPE string.

      " --- Old value ---
      IF <old> IS ASSIGNED.
        TRY.
            " cố gắng serialize cho mọi kiểu (date, time, packed, etc.)
            lv_old = /ui2/cl_json=>serialize( data = <old> ).
          CATCH cx_root.
            " fallback: ép sang chuỗi
            lv_old = |{ <old> }|.
        ENDTRY.
      ELSE.
        lv_old = ``.
      ENDIF.

      " --- New value ---
      IF <new> IS ASSIGNED.
        TRY.
            lv_new = /ui2/cl_json=>serialize( data = <new> ).
          CATCH cx_root.
            lv_new = |{ <new> }|.
        ENDTRY.
      ELSE.
        lv_new = ``.
      ENDIF.

      IF iv_op = 'C' AND lv_new IS INITIAL.
        CONTINUE. " tạo mới nhưng field rỗng -> khỏi log
      ENDIF.

      IF iv_op = 'U' AND lv_old = lv_new.
        CONTINUE. " không đổi
      ENDIF.

      TRY.
          APPEND VALUE zui_chg_log(
            log_id     = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( )
            req_id     = iv_reqid
            bo_name    = iv_bo_name
            operation  = iv_op
            entity_key = iv_uuid
            field_name = lv_name
            old_value  = COND string( WHEN iv_op = 'C' THEN '' ELSE lv_old )
            new_value  = COND string( WHEN iv_op = 'D' THEN '' ELSE lv_new )
            changed_by = cl_abap_context_info=>get_user_technical_name( )
            changed_at = cl_abap_context_info=>get_system_time( )
          ) TO lt_log.
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.

    ENDLOOP.

    IF lt_log IS NOT INITIAL.
      INSERT zui_chg_log FROM TABLE @lt_log.
    ENDIF.

  ENDMETHOD.


  METHOD to_string.
    TRY.
        rv = /ui2/cl_json=>serialize( data = i_any ). " nhanh gọn cho mọi kiểu
      CATCH cx_root.
        rv = |{ i_any }|.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_kbsnlamviec DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES: gty_kbnln_gc TYPE STANDARD TABLE OF zui_kbnlngc WITH EMPTY KEY.

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
             workcenter     TYPE string,
*             hierarchynode  TYPE string,
             plant          TYPE string,
             zyear          TYPE string,
             w1workingdays  TYPE string,
             w2workingdays  TYPE string,
             w3workingdays  TYPE string,
             w4workingdays  TYPE string,
             w5workingdays  TYPE string,
             w6workingdays  TYPE string,
             w7workingdays  TYPE string,
             w8workingdays  TYPE string,
             w9workingdays  TYPE string,
             w10workingdays TYPE string,
             w11workingdays TYPE string,
             w12workingdays TYPE string,
             w13workingdays TYPE string,
             w14workingdays TYPE string,
             w15workingdays TYPE string,
             w16workingdays TYPE string,
             w17workingdays TYPE string,
             w18workingdays TYPE string,
             w19workingdays TYPE string,
             w20workingdays TYPE string,
             w21workingdays TYPE string,
             w22workingdays TYPE string,
             w23workingdays TYPE string,
             w24workingdays TYPE string,
             w25workingdays TYPE string,
             w26workingdays TYPE string,
             w27workingdays TYPE string,
             w28workingdays TYPE string,
             w29workingdays TYPE string,
             w30workingdays TYPE string,
             w31workingdays TYPE string,
             w32workingdays TYPE string,
             w33workingdays TYPE string,
             w34workingdays TYPE string,
             w35workingdays TYPE string,
             w36workingdays TYPE string,
             w37workingdays TYPE string,
             w38workingdays TYPE string,
             w39workingdays TYPE string,
             w40workingdays TYPE string,
             w41workingdays TYPE string,
             w42workingdays TYPE string,
             w43workingdays TYPE string,
             w44workingdays TYPE string,
             w45workingdays TYPE string,
             w46workingdays TYPE string,
             w47workingdays TYPE string,
             w48workingdays TYPE string,
             w49workingdays TYPE string,
             w50workingdays TYPE string,
             w51workingdays TYPE string,
             w52workingdays TYPE string,
             w53workingdays TYPE string,
             w54workingdays TYPE string,
           END OF ty_file_upload,

           tt_file TYPE STANDARD TABLE OF ty_file_upload WITH EMPTY KEY.

    CONSTANTS c_mime TYPE string VALUE
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR kbsnlamviec RESULT result.

    METHODS downloadfile FOR MODIFY
      IMPORTING keys FOR ACTION kbsnlamviec~downloadfile RESULT result.

    METHODS fileupload FOR MODIFY
      IMPORTING keys FOR ACTION kbsnlamviec~fileupload.

    METHODS precheckdata FOR MODIFY
      IMPORTING keys FOR ACTION kbsnlamviec~precheckdata RESULT result.
    METHODS checkdata FOR VALIDATE ON SAVE
      IMPORTING keys FOR kbsnlamviec~checkdata.

    METHODS checkworkingdays FOR VALIDATE ON SAVE
      IMPORTING keys FOR kbsnlamviec~checkworkingdays.

    METHODS workingdays FOR DETERMINE ON SAVE
      IMPORTING keys FOR kbsnlamviec~workingdays.

    METHODS lweek FOR DETERMINE ON SAVE
      IMPORTING keys FOR kbsnlamviec~lweek.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE kbsnlamviec.

    METHODS getexceldata IMPORTING iv_content     TYPE xstring
                         RETURNING VALUE(et_file) TYPE tt_file.

    METHODS convert_date IMPORTING i_date         TYPE string
                         RETURNING VALUE(rv_dats) TYPE string.

    METHODS is_valid_iso_week
      IMPORTING
        iv_week         TYPE char2       " week 1..53
        iv_year         TYPE i       " calendar year (fiscal year nếu trùng calendar)
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    METHODS  get_weekday
      IMPORTING
        iv_date       TYPE d       " YYYYMMDD
      RETURNING
        VALUE(rv_dow) TYPE i. " 1=Mon ... 7=Sun

    " Helpers
    METHODS get_week_range
      IMPORTING iv_year      TYPE gjahr
                iv_week      TYPE i
      EXPORTING ev_date_from TYPE d
                ev_date_to   TYPE d.

    METHODS load_capacities
      IMPORTING iv_wc         TYPE zui_kbnlngc-workcenter
                iv_node       TYPE zui_kbnlngc-hierarchynode
                iv_plant      TYPE zui_kbnlngc-plant
                iv_yfrom      TYPE d
                iv_yto        TYPE d
      RETURNING VALUE(rt_cap) TYPE gty_kbnln_gc.

    METHODS find_daily_for_week
      IMPORTING it_cap        TYPE gty_kbnln_gc
                iv_week_from  TYPE d
                iv_week_to    TYPE d
      RETURNING VALUE(rv_day) TYPE zui_kbnlngc-dailyproductivity.

ENDCLASS.

CLASS lhc_kbsnlamviec IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    LOOP AT entities
                  ASSIGNING FIELD-SYMBOL(<f_entities>)
                  WHERE uuid IS NOT INITIAL.

      APPEND CORRESPONDING #( <f_entities> ) TO mapped-kbsnlamviec.

    ENDLOOP.

    DATA(lt_file) = entities.

    DELETE lt_file WHERE uuid IS NOT INITIAL.

    IF lt_file IS INITIAL.
      RETURN.
    ENDIF.


    LOOP AT lt_file ASSIGNING <f_entities>.

      TRY.
          <f_entities>-uuid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
        CATCH cx_uuid_error.

          APPEND VALUE #( %cid      = <f_entities>-%cid
                          %key      = <f_entities>-%key
                          %is_draft = <f_entities>-%is_draft
          )
                 TO reported-kbsnlamviec.

          APPEND VALUE #( %cid      = <f_entities>-%cid
                          %key      = <f_entities>-%key
                          %is_draft = <f_entities>-%is_draft )
                 TO failed-kbsnlamviec.

          EXIT.
      ENDTRY.

      APPEND VALUE #( %cid      = <f_entities>-%cid
                      %key      = <f_entities>-%key
                      %is_draft = <f_entities>-%is_draft )
       TO mapped-kbsnlamviec.

    ENDLOOP.

  ENDMETHOD.

  METHOD downloadfile.

    DATA(lo_doc)   = xco_cp_xlsx=>document->empty( ).
    DATA(lo_write) = lo_doc->write_access( ).
    DATA(lo_ws)    = lo_write->get_workbook( )->worksheet->at_position( 1 ).
    lo_ws->set_name( 'WorkingDaysTemplate' ).

    DATA(lo_cur) = lo_ws->cursor( io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'B' )
                                  io_row    = xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
                                  ).

    "===== Header =====================================================
    DATA lt_head TYPE STANDARD TABLE OF string.
    APPEND 'Workcenter' TO lt_head.
    APPEND 'HierarchyNode' TO lt_head.
    APPEND 'Plant' TO lt_head.
    APPEND 'Zyear' TO lt_head.
    DO 54 TIMES.
      APPEND |W{ sy-index }workingdays| TO lt_head.
    ENDDO.

    DATA(lv_col) = 1.

    LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<h>).

      "--- 1. Lấy cell qua cursor
      DATA(lo_cell) = lo_cur->get_cell( ).

      "--- 2. Ghi chuỗi
      lo_cell->value->write_from( <h> ).

      "--- 3. In đậm header (nếu system support)
*      lo_cell->apply_styles( xco_cp_xlsx_styles=>font( )->bold( ) ).

      "--- 4. Đặt độ rộng cột
      lo_ws->column( xco_cp_xlsx=>coordinate->for_numeric_value( lv_col ) )->set_width( COND f( WHEN lv_col <= 4 THEN 18 ELSE 12 ) ).

      lv_col += 1.
    ENDLOOP.

    " 5) Lấy file content
    DATA(lv_xlsx) = lo_write->get_file_content( ).

    " 6) Trả về action result (ZI_FILE_ABS)
    result = VALUE #(
               FOR k IN keys (
               %cid   = k-%cid
               %param = VALUE #( filecontent   = lv_xlsx
                                 filename      = 'Template_WorkingDays'
                                 fileextension = 'xlsx'
                                 mimetype      = c_mime ) ) ).
  ENDMETHOD.

  METHOD fileupload.
    DATA: lt_file_c TYPE TABLE FOR CREATE zi_kbsn_lamviec,
          ls_file_c LIKE LINE OF lt_file_c,

          lt_file_u TYPE TABLE FOR UPDATE zi_kbsn_lamviec,
          ls_file_u LIKE LINE OF lt_file_u.

    TYPES: BEGIN OF lty_keys,
             workcenter TYPE zi_kbsn_lamviec-workcenter,
             plant      TYPE zi_kbsn_lamviec-plant,
             week       TYPE zi_kbsn_lamviec-week,
             zyear      TYPE zi_kbsn_lamviec-zyear,
           END OF lty_keys.

    DATA: lt_keys TYPE STANDARD TABLE OF lty_keys WITH EMPTY KEY.

    READ TABLE keys INDEX 1 INTO DATA(k).

    DATA(lt_file) = me->getexceldata( iv_content = k-%param-filecontent ).
    DATA ls_file LIKE LINE OF lt_file.

    MOVE-CORRESPONDING lt_file TO lt_keys.

    SELECT * FROM zi_kbsn_lamviec
    FOR ALL ENTRIES IN @lt_keys
    WHERE workcenter    = @lt_keys-workcenter
      AND plant         = @lt_keys-plant
      AND zyear    = @lt_keys-zyear
    INTO TABLE @DATA(lt_check).

    DATA: lv_check TYPE abap_boolean VALUE abap_false.
    DATA: lt_temp TYPE TABLE OF zi_kbsn_lamviec,
          ls_temp TYPE zi_kbsn_lamviec.
    DATA: lv_index TYPE int1,
          lv_field TYPE string.

    LOOP AT lt_file INTO ls_file.
      lv_index = 1.

      DO 54 TIMES.

        lv_field = |w{ lv_index }workingdays|.

        ls_temp-workcenter = ls_file-workcenter.
        ls_temp-plant = ls_file-plant.
        ls_temp-zyear = ls_file-zyear.
        ls_temp-week = lv_index.

        DATA: zyear TYPE i.
        zyear = ls_file-zyear.

        DATA(lv_boolen) = me->is_valid_iso_week( iv_week = ls_temp-week iv_year = zyear ).

        IF lv_boolen = abap_false.
          CONTINUE.
        ENDIF.

        ASSIGN COMPONENT lv_field OF STRUCTURE ls_file TO FIELD-SYMBOL(<lv_value>).
        IF sy-subrc EQ 0 AND <lv_value> IS ASSIGNED AND <lv_value> IS NOT INITIAL.
          ls_temp-workingdays = <lv_value>.
          APPEND ls_temp TO lt_temp.
        ENDIF.

        CLEAR: ls_temp.
        UNASSIGN <lv_value>.

        lv_index += 1.

      ENDDO.
    ENDLOOP.

    SORT lt_check BY workcenter plant week zyear ASCENDING.

    LOOP AT lt_temp INTO ls_temp.

      lv_check = abap_false.

      READ TABLE lt_check INTO DATA(ls_check)
      WITH KEY workcenter    = ls_temp-workcenter
               plant         = ls_temp-plant
               week          = ls_temp-week
               zyear    = ls_temp-zyear
      BINARY SEARCH.

      IF sy-subrc NE 0.
        CLEAR: ls_check.
      ELSE.
        lv_check = abap_true.
      ENDIF.

      TRY.

          " CREATE ENTITIES
          ls_file_c = VALUE #(
*            uuid    type sysuuid_x16
            workcenter  = ls_temp-workcenter                "type arbpl
            plant       = ls_temp-plant                     "type werks_d
            week        = ls_temp-week
            zyear       = ls_temp-zyear
            workingdays = ls_temp-workingdays

*            createdby   "type abp_creation_user
*            createdat   "type abp_creation_tstmpl
*            locallastchangedby  "type abp_locinst_lastchange_user
*            locallastchangedat  "type abp_locinst_lastchange_tstmpl
*            lastchangedat   "type abp_lastchange_tstmpl

          ).


          " UPDATE ENTITIES
          ls_file_u = VALUE #(
            uuid        = ls_check-uuid
            workcenter  = ls_temp-workcenter                "type arbpl
            plant       = ls_temp-plant                     "type werks_d
            week        = ls_temp-week
            zyear       = ls_temp-zyear
            workingdays = ls_temp-workingdays

*            createdby   "type abp_creation_user
*            createdat   "type abp_creation_tstmpl
*            locallastchangedby  "type abp_locinst_lastchange_user
*            locallastchangedat  "type abp_locinst_lastchange_tstmpl
*            lastchangedat   "type abp_lastchange_tstmpl

          ).

        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.

      IF lv_check = abap_false.
        APPEND ls_file_c TO lt_file_c.
      ELSE.
        APPEND ls_file_u TO lt_file_u.
      ENDIF.

      CLEAR: ls_file_c, ls_file_u.

    ENDLOOP.

    IF lt_file_c IS NOT INITIAL.
      MODIFY ENTITIES OF zi_kbsn_lamviec IN LOCAL MODE
        ENTITY kbsnlamviec
        CREATE AUTO FILL CID FIELDS (
*                          uuid
           workcenter          "type arbpl
           plant               "type werks_d
           week
           zyear
           workingdays
                        ) WITH lt_file_c
        MAPPED DATA(lt_mapped_create)
        REPORTED DATA(lt_reported_create)
        FAILED DATA(lt_failed_create).
    ENDIF.

    "UPDATE ENTITES

    IF lt_file_u IS NOT INITIAL.
      MODIFY ENTITIES OF zi_kbsn_lamviec IN LOCAL MODE
        ENTITY kbsnlamviec
        UPDATE FIELDS (
*                          uuid
*           workcenter          "type arbpl
*           hierarchynode       "type abap.char(50)
*           plant               "type werks_d
*           Zyear
            workingdays
                        ) WITH lt_file_u
        MAPPED lt_mapped_create
        REPORTED lt_reported_create
        FAILED lt_failed_create.
    ENDIF.

  ENDMETHOD.

  "* Tính khoảng tuần từ năm + số tuần (giả định W1 = 01/01..01/07)
  METHOD get_week_range.
    DATA lv_start TYPE d.
    lv_start = |{ iv_year }0101|.
    " offset = (week-1)*7
    DATA lv_off TYPE i.
    lv_off = ( iv_week - 1 ) * 7.
    ev_date_from = lv_start + lv_off.
    ev_date_to   = ev_date_from + 6.
  ENDMETHOD.


  "* Load tất cả dòng năng lực hiệu lực trong năm cho key WC/Node/Plant
  METHOD load_capacities.
    SELECT *
      FROM zui_kbnlngc
      WHERE workcenter    = @iv_wc
        AND hierarchynode = @iv_node
        AND plant         = @iv_plant
        AND todate       >= @iv_yfrom
        AND fromdate     <= @iv_yto
      INTO TABLE @rt_cap.

    " Sắp xếp để tìm kiếm thuận tiện
    IF rt_cap IS NOT INITIAL.
      SORT rt_cap BY fromdate ASCENDING todate ASCENDING.
    ENDIF.
  ENDMETHOD.


  "* Tìm Dailyproductivity cho tuần (ưu tiên record phủ tuần_start, nếu không có lấy record giao bất kỳ)
  METHOD find_daily_for_week.
    rv_day = 0.

    IF it_cap IS INITIAL.
      RETURN.
    ENDIF.

    " 1) ưu tiên record bao phủ nguyên tuần_start (from <= start <= to)
    READ TABLE it_cap ASSIGNING FIELD-SYMBOL(<c>)
         WITH KEY fromdate = iv_week_from BINARY SEARCH.
    " Không thể tìm trực tiếp theo =, dùng vòng lặp tuần tự:
    LOOP AT it_cap ASSIGNING <c>.
      IF <c>-fromdate <= iv_week_from AND <c>-todate >= iv_week_from.
        rv_day = <c>-dailyproductivity.
        RETURN.
      ENDIF.
    ENDLOOP.

    " 2) nếu không có, chọn record nào giao với [start..end]
    LOOP AT it_cap ASSIGNING <c>.
      IF <c>-fromdate <= iv_week_to AND <c>-todate >= iv_week_from.
        rv_day = <c>-dailyproductivity.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheckdata.

    TYPES: BEGIN OF lty_check,
             msgtype TYPE zde_char1,
             msgtext TYPE string,
             data    TYPE ty_file_upload,
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

*      SELECT COUNT(*) FROM i_produnivhierarchynodebasic
*      WHERE hierarchynode = @ls_file-hierarchynode
*        AND produnivhierarchy = 'PH_MANUFACTURING'
*        AND hierarchynodelevel = '000003'
*      INTO @lv_count.
*      IF sy-subrc NE 0.
*        ls_check-msgtype = file_status-error.
*        ls_check-msgtext = |Does not exist Product { ls_file-hierarchynode }|.
*      ENDIF.

      DATA: lv_index TYPE i.
      lv_index = 1.
      DO 54 TIMES.
        ASSIGN COMPONENT |w{ lv_index }workingdays| OF STRUCTURE ls_file TO FIELD-SYMBOL(<lv_value>).
        IF <lv_value> IS ASSIGNED.
          IF <lv_value> > 7 OR <lv_value> < 0.
            ls_check-msgtype = file_status-error.
            ls_check-msgtext = |Số ngày làm việc { <lv_value> } không hợp lệ|.

            EXIT.
          ENDIF.
        ENDIF.
        lv_index += 1.
      ENDDO.

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

  METHOD checkdata.
    READ ENTITIES OF zi_kbsn_lamviec IN LOCAL MODE
          ENTITY kbsnlamviec
          FIELDS ( uuid workcenter plant week zyear )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_new).

    IF lt_new IS INITIAL.
      RETURN.
    ENDIF.

    "Tìm bản ghi trùng trong bảng persistent (ngoại trừ chính nó khi update)
    TYPES: BEGIN OF ty_hit,
             uuid       TYPE sysuuid_x16,
             workcenter TYPE zui_kbsnlv-workcenter,
             plant      TYPE zui_kbsnlv-plant,
             week       TYPE zui_kbsnlv-week,
             zyear      TYPE zui_kbsnlv-zyear,
           END OF ty_hit.

    DATA lt_hit TYPE STANDARD TABLE OF ty_hit.

    "FOR ALL ENTRIES để dò theo từng cặp người dùng nhập
    SELECT uuid, workcenter, plant, week, zyear
      FROM zui_kbsnlv
      FOR ALL ENTRIES IN @lt_new
      WHERE workcenter = @lt_new-workcenter
        AND plant      = @lt_new-plant
        AND week       = @lt_new-week
        AND zyear = @lt_new-zyear
        AND uuid <> @lt_new-uuid          "loại chính nó khi update
      INTO TABLE @lt_hit.

    IF lt_hit IS INITIAL.
      RETURN.
    ENDIF.

    "Map lại theo %tky để báo lỗi từng dòng
    LOOP AT lt_new ASSIGNING FIELD-SYMBOL(<ls_new>).

      READ TABLE lt_hit WITH KEY workcenter = <ls_new>-workcenter
                                 plant      = <ls_new>-plant
                                 week       = <ls_new>-week
                                 zyear = <ls_new>-zyear
           TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.

        "1) Chặn save
        APPEND VALUE #( %tky = <ls_new>-%tky ) TO failed-kbsnlamviec.

        "2) Trả message + bôi đỏ field
        APPEND VALUE #(
          %tky     = <ls_new>-%tky
          %msg     = new_message(
                        id       = 'ZMMKHNHGC'         "tạo message class của bạn
                        number   = '003'         "ví dụ: 'Đã tồn tại bản ghi TaxCode &1, TaxNo &2'
                        v1       = <ls_new>-workcenter
                        v2       = <ls_new>-plant
                        v3       = <ls_new>-week
                        v4       = <ls_new>-plant
                        severity = if_abap_behv_message=>severity-error )

          %element-workcenter = if_abap_behv=>mk-on
          %element-plant      = if_abap_behv=>mk-on
          %element-week       = if_abap_behv=>mk-on
          %element-zyear = if_abap_behv=>mk-on
        ) TO reported-kbsnlamviec.

      ENDIF.
    ENDLOOP.

    READ TABLE keys INDEX 1 INTO DATA(k).

    LOOP AT lt_new INTO DATA(ls_new).
      SELECT COUNT(*) FROM i_workcenter
      WITH PRIVILEGED ACCESS
        WHERE workcenter = @ls_new-workcenter
          AND plant = @ls_new-plant
        INTO @DATA(lv_count).
      IF sy-subrc NE 0.
        APPEND VALUE #( %tky = ls_new-%tky ) TO failed-kbsnlamviec.
        APPEND VALUE #(
                        %tky                = ls_new-%tky
                        %element-workcenter = if_abap_behv=>mk-on
                        %element-plant      = if_abap_behv=>mk-on
                        %msg                = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Does not exist WorkCenter { ls_new-workcenter } - Plant { ls_new-plant }|
                        ) ) TO reported-kbsnlamviec.
      ENDIF.

      SELECT COUNT(*) FROM i_plant
      WITH PRIVILEGED ACCESS
      WHERE plant = @ls_new-plant
      INTO @lv_count.
      IF sy-subrc NE 0.
        APPEND VALUE #( %tky = ls_new-%tky ) TO failed-kbsnlamviec.
        APPEND VALUE #(
                        %tky           = ls_new-%tky
*                        %element-workcenter = if_abap_behv=>mk-on
                        %element-plant = if_abap_behv=>mk-on
                        %msg           = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Does not exist Plant { ls_new-plant }|
                        ) ) TO reported-kbsnlamviec.
      ENDIF.

      DATA: zyear TYPE i.
      zyear = ls_new-zyear.

      DATA(lv_boolen) = me->is_valid_iso_week( iv_week = ls_new-week iv_year = zyear ).

      IF lv_boolen = abap_false.
        APPEND VALUE #( %tky = ls_new-%tky ) TO failed-kbsnlamviec.
        APPEND VALUE #(
                        %tky           = ls_new-%tky
                        %element-week  = if_abap_behv=>mk-on
                        %element-zyear = if_abap_behv=>mk-on
                        %msg           = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Tuần '{ ls_new-week }/{ ls_new-zyear }' không hợp lệ|
                        ) ) TO reported-kbsnlamviec.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD checkworkingdays.
    READ ENTITIES OF zi_kbsn_lamviec IN LOCAL MODE
        ENTITY kbsnlamviec
        FIELDS ( uuid workcenter plant week zyear )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_new).

    IF lt_new IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE keys INDEX 1 INTO DATA(k).

    LOOP AT lt_new INTO DATA(ls_new).
      IF ls_new-workingdays > 7 OR ls_new-workingdays < 0.
        APPEND VALUE #( %tky = ls_new-%tky ) TO failed-kbsnlamviec.
        APPEND VALUE #(
                        %tky                 = ls_new-%tky
                        %element-workingdays = if_abap_behv=>mk-on
                        %msg                 = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Số ngày làm việc '{ ls_new-workingdays }' không hợp lệ|
                        ) ) TO reported-kbsnlamviec.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_valid_iso_week.

    DATA: lv_week    TYPE i,
          lv_year    TYPE i,
          lv_date    TYPE d,
          lv_dow     TYPE i,
          lv_is_leap TYPE abap_bool.

    lv_week = CONV i( iv_week ).
    lv_year = iv_year.

    " 1) Check range thô
    IF lv_week < 1 OR lv_week > 53.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    " 2) 1..52 luôn ok
    IF lv_week <= 52.
      rv_valid = abap_true.
      RETURN.
    ENDIF.

    " 3) Đến đây chỉ còn week = 53 → check theo ISO

    " 3.1: tính năm nhuận (Gregorian)
    IF ( lv_year MOD 400 = 0 )
       OR ( lv_year MOD 4 = 0 AND lv_year MOD 100 <> 0 ).
      lv_is_leap = abap_true.
    ELSE.
      lv_is_leap = abap_false.
    ENDIF.

    " 3.2: lấy weekday của 01.01.iv_year
    DATA(lv_year4) = |{ lv_year WIDTH = 4 ALIGN = RIGHT PAD = '0' }|.
    lv_date = CONV d( lv_year4 && '0101' ).
    lv_dow  = get_weekday( lv_date ).

    " ISO: năm có tuần 53 nếu
    " - 01.01 là Thursday (dow = 4),
    " hoặc
    " - năm nhuận và 01.01 là Wednesday (dow = 3)
    IF lv_dow = 4
       OR ( lv_is_leap = abap_true AND lv_dow = 3 ).
      rv_valid = abap_true.
    ELSE.
      rv_valid = abap_false.
    ENDIF.

  ENDMETHOD.

  METHOD get_weekday.
    " Tính thứ trong tuần bằng Zeller's congruence (Gregorian)
    DATA: lv_year  TYPE i,
          lv_month TYPE i,
          lv_day   TYPE i,
          lv_m     TYPE i,
          lv_y     TYPE i,
          lv_k     TYPE i,
          lv_j     TYPE i,
          lv_h     TYPE i.

    lv_year  = iv_date(4).
    lv_month = iv_date+4(2).
    lv_day   = iv_date+6(2).

    " Zeller: Jan, Feb = 13,14 của năm trước
    IF lv_month = 1 OR lv_month = 2.
      lv_month = lv_month + 12.
      lv_year  = lv_year - 1.
    ENDIF.

    lv_m = lv_month.
    lv_y = lv_year.
    lv_k = lv_y MOD 100.
    lv_j = lv_y / 100.

    lv_h = lv_day
        + ( 13 * ( lv_m + 1 ) ) / 5
        + lv_k
        + lv_k / 4
        + lv_j / 4
        + 5 * lv_j.

    lv_h = lv_h MOD 7.
    " Zeller: 0=Sat 1=Sun 2=Mon ... 6=Fri
    " Convert: 1=Mon ... 7=Sun
    rv_dow = ( lv_h + 5 ) MOD 7 + 1.
  ENDMETHOD.

  METHOD workingdays.

    " Lấy dữ liệu các bản ghi đang được sửa
    READ ENTITIES OF zi_kbsn_lamviec IN LOCAL MODE
      ENTITY kbsnlamviec
      FIELDS ( workingdays )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_rows).

    LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<ls>).

      IF <ls>-workingdays IS INITIAL.
        <ls>-workingdays = 0.
      ENDIF.
      " Ghi ngược lại 2 field
*      MODIFY ENTITIES OF zi_kbsn_lamviec IN LOCAL MODE
*        ENTITY kbsnlamviec
*        UPDATE FIELDS ( workingdays )
*        WITH VALUE #(
*          ( %tky        = <ls>-%tky
*            workingdays = <ls>-workingdays
*          )
*      )
*        FAILED   DATA(ls_failed)
*        REPORTED DATA(ls_reported).

    ENDLOOP.
  ENDMETHOD.

  METHOD lweek.


    " Lấy dữ liệu các bản ghi đang được sửa
    READ ENTITIES OF zi_kbsn_lamviec IN LOCAL MODE
      ENTITY kbsnlamviec
      FIELDS ( week zyear )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_rows).

    LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<ls>).

      IF <ls>-week < 10.
        <ls>-lweek = <ls>-zyear && `0` && <ls>-week.
      ELSE.
        <ls>-lweek = <ls>-zyear && <ls>-week.
      ENDIF.

      " Ghi ngược lại 2 field
      MODIFY ENTITIES OF zi_kbsn_lamviec IN LOCAL MODE
        ENTITY kbsnlamviec
        UPDATE FIELDS ( lweek )
        WITH VALUE #(
          ( %tky  = <ls>-%tky
            lweek = <ls>-lweek
          )
      )
        FAILED   DATA(ls_failed)
        REPORTED DATA(ls_reported).

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

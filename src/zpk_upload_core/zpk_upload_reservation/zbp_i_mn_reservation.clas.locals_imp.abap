CLASS lhc_managefile DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_file_upload,
             documentsequenceno TYPE string,
             basedate           TYPE string,
             costcenter         TYPE string,
             goodsmovementtype  TYPE string,
             plant              TYPE string,
             receivingissuing   TYPE string,
             storagelocation    TYPE string,
             materialnumber     TYPE string,
             quantity           TYPE string,
             unitofmeasure      TYPE string,
             batch              TYPE string,
             salesorder         TYPE string,
             salesorderitem     TYPE string,
             valuationtype      TYPE string,
             requirementdate    TYPE string,
             glaccountnumber    TYPE string,
             msgtype            TYPE string,
             msgtext            TYPE string,
           END OF ty_file_upload.

    CONSTANTS c_excel_base TYPE d VALUE '18991230'.

    CONSTANTS:
      BEGIN OF file_status,
        open      TYPE c LENGTH 1 VALUE 'M', "Not process
        accepted  TYPE c LENGTH 1 VALUE 'A', "Accepted
        rejected  TYPE c LENGTH 1 VALUE 'X', "Rejected
        completed TYPE c LENGTH 1 VALUE 'D', "Done
        inprocess TYPE c LENGTH 1 VALUE 'P', "In Process
        error     TYPE c LENGTH 1 VALUE 'E', "Error
        success   TYPE c LENGTH 1 VALUE 'S', " Success
      END OF file_status.

    METHODS convert_date IMPORTING i_date         TYPE string
                         RETURNING VALUE(rv_dats) TYPE string.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR managefile RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR managefile RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE managefile.

    METHODS setstatustoopen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR managefile~setstatustoopen.

    METHODS getexceldata FOR DETERMINE ON SAVE
      IMPORTING keys FOR managefile~getexceldata.

    METHODS downloadfile FOR MODIFY
      IMPORTING keys FOR ACTION managefile~downloadfile RESULT result.

    METHODS fileupload FOR MODIFY
      IMPORTING keys FOR ACTION managefile~fileupload.


ENDCLASS.

CLASS lhc_managefile IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    LOOP AT entities
             ASSIGNING FIELD-SYMBOL(<f_entities>)
             WHERE uuid IS NOT INITIAL.

      APPEND CORRESPONDING #( <f_entities> ) TO mapped-managefile.

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
                          %is_draft = <f_entities>-%is_draft )
                 TO reported-managefile.
          APPEND VALUE #( %cid      = <f_entities>-%cid
                          %key      = <f_entities>-%key
                          %is_draft = <f_entities>-%is_draft )
                 TO failed-managefile.
          EXIT.

      ENDTRY.

      APPEND VALUE #( %cid      = <f_entities>-%cid
                      %key      = <f_entities>-%key
                      %is_draft = <f_entities>-%is_draft )
             TO mapped-managefile.
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

    lo_worksheet->select( lo_selection_pattern
    )->row_stream(
    )->operation->write_from( REF #( lt_file )
    )->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    SELECT SINGLE * FROM zcore_tb_temppdf
      WHERE id = 'zuploadreservation'
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
                                          filename      = 'TemplateUploadReservation_EN'
                                          fileextension = 'xlsx'
                                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                        ) ).
    ELSE.
      result = VALUE #( FOR key IN keys (
                        %cid   = key-%cid
                        %param = VALUE #( filecontent   = ls_tb_temppdf-file_content
                                          filename      = 'TemplateUploadReservation_EN'
                                          fileextension = 'xlsx'
                                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                        ) ).
    ENDIF.

  ENDMETHOD.

  METHOD fileupload.

    DATA lt_file TYPE STANDARD TABLE OF ty_file_upload.

    DATA: lt_mn_file TYPE TABLE FOR CREATE zi_mn_reservation,
          ls_mn_file LIKE LINE OF lt_mn_file,

          lt_file_c  TYPE TABLE FOR CREATE zi_mn_reservation\_datareservation,
          ls_file_c  LIKE LINE OF lt_file_c.

    DATA: lt_keys TYPE TABLE FOR READ IMPORT zi_data_reservation.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<k>) INDEX 1.

    CHECK sy-subrc = 0.

    IF <k>-%param-filecontent IS INITIAL.
      RETURN.
    ENDIF.

    ls_mn_file-attachment = <k>-%param-filecontent.
    ls_mn_file-filename   = <k>-%param-filename.
    ls_mn_file-mimetype   = <k>-%param-mimetype.

    APPEND ls_mn_file TO lt_mn_file.

    IF lt_mn_file IS NOT INITIAL.
      MODIFY ENTITIES OF zi_mn_reservation IN LOCAL MODE
        ENTITY managefile
        CREATE AUTO FILL CID FIELDS (
*                          uuid
*                          zcount
                          status
                          attachment
                          mimetype
                          filename
                          countline
                          createdbyuser
                          createddate
                          changedbyuser
                          changeddate
                        ) WITH lt_mn_file
        MAPPED DATA(lt_mapped_create)
        REPORTED DATA(lt_reported_create)
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

  METHOD getexceldata.

    DATA: lt_file TYPE STANDARD TABLE OF ty_file_upload.
    DATA: lt_file_c TYPE TABLE FOR CREATE zi_mn_reservation\\managefile\_datareservation,
          ls_file_c LIKE LINE OF lt_file_c.

    " Read the parent instance
    READ ENTITIES OF zi_mn_reservation IN LOCAL MODE
         ENTITY managefile
         ALL FIELDS WITH
         CORRESPONDING #( keys )
         RESULT FINAL(lt_record).

    " Get attachment value from the instance
    IF lt_record IS INITIAL.
      RETURN.
    ELSE.
      FINAL(lv_filecontent) = lt_record[ 1 ]-attachment.
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

    IF lt_file IS NOT INITIAL.
      DO 2 TIMES.
        DELETE lt_file INDEX 1.
      ENDDO.
    ENDIF.

    DATA: lv_fail    TYPE abap_boolean VALUE abap_false,
          lv_msgtext TYPE zde_char255,
          lv_msgtype TYPE zde_char1.

    DELETE lt_file WHERE documentsequenceno IS INITIAL
                     AND goodsmovementtype  IS INITIAL
                     AND plant              IS INITIAL
                     AND receivingissuing   IS INITIAL
                     AND storagelocation    IS INITIAL
                     AND materialnumber     IS INITIAL
                     AND quantity           IS INITIAL.

    READ TABLE lt_record ASSIGNING FIELD-SYMBOL(<f_file>) INDEX 1.

    DATA(lt_check) = lt_file.

*    SORT lt_check BY documentsequenceno ASCENDING.
*    DELETE ADJACENT DUPLICATES FROM lt_check COMPARING documentsequenceno .

    LOOP AT lt_file INTO DATA(ls_file).

      FINAL(lv_tabix) = sy-tabix.

      TRY.
          ls_file_c-uuid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.

      TRY.

          ls_file-msgtype = file_status-open.

          IF ls_file-basedate IS NOT INITIAL.
            DATA(lv_basedate) = me->convert_date( i_date = ls_file-basedate ).
          ENDIF.

          IF ls_file-requirementdate IS NOT INITIAL.
            DATA(lv_requirementdate) = me->convert_date( i_date = ls_file-requirementdate ).
          ENDIF.

          IF ls_file-goodsmovementtype IS INITIAL OR
             ls_file-plant IS INITIAL OR
             ls_file-receivingissuing IS INITIAL OR
             ls_file-storagelocation IS INITIAL OR
             ls_file-materialnumber IS INITIAL OR
             ls_file-quantity IS INITIAL.

*            DATA(lv_msgtype) = 'E'.
*            lv_msgtext = TEXT-001.
          ENDIF.

          IF ( ls_file-goodsmovementtype = '201' AND ls_file-goodsmovementtype = 'Y23' ).
*            lv_msgtype = 'E'.
*            lv_msgtext = TEXT-001.
          ENDIF.

*          READ TABLE lt_check TRANSPORTING NO FIELDS WITH KEY receivingissuing = ls_file-receivingissuing
*                                                              storagelocation = ls_file-storagelocation BINARY SEARCH.
*
*          IF sy-subrc NE 0.
*            lv_msgtype = file_status-error.
*            lv_msgtext = TEXT-002.
*          ENDIF.

          IF lv_msgtype = file_status-error.
            DATA(lv_criticality) = 1.
          ENDIF.

          " <f_file> là bản ghi cha đọc từ READ ENTITIES
          ls_file_c = VALUE #(
            %tky    = <f_file>-%tky                  "<<< BẮT BUỘC: trỏ về instance cha trong buffer
*          %is_draft = <f_file>-%is_draft          " (tuỳ chọn, framework suy ra từ %tky)
            %target = VALUE #( (
                               %cid               = lv_tabix
*          uuid               = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( )   "nếu key con tự cấp; nếu early numbering thì bỏ
*          uuidfile           = <f_file>-uuid      "<<< BỎ: framework sẽ gán FK dựa vào %tky
                               documentsequenceno = ls_file-documentsequenceno
                               basedate           = lv_basedate
                               costcenter         = ls_file-costcenter
                               goodsmovementtype  = ls_file-goodsmovementtype
                               plant              = ls_file-plant
                               receivingissuing   = ls_file-receivingissuing
                               storagelocation    = ls_file-storagelocation
                               materialnumber     = ls_file-materialnumber
                               quantity           = ls_file-quantity
                               unitofmeasure      = ls_file-unitofmeasure
                               batch              = ls_file-batch
                               salesorder         = ls_file-salesorder
                               salesorderitem     = ls_file-salesorderitem
                               valuationtype      = ls_file-valuationtype
                               requirementdate    = lv_requirementdate
                               glaccount          = ls_file-glaccountnumber
                               messagetype        = lv_msgtype
                               criticality        = lv_criticality
                               messagetext        = lv_msgtext
                               ) )
          ).
        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.

      APPEND ls_file_c TO lt_file_c.
      CLEAR: ls_file_c.
      CLEAR: lv_basedate, lv_requirementdate.
    ENDLOOP.

    CHECK lv_fail IS INITIAL.

    IF lt_file_c IS NOT INITIAL.

      MODIFY ENTITIES OF zi_mn_reservation IN LOCAL MODE
      ENTITY managefile
      CREATE BY \_datareservation FIELDS (
*                          uuid
                          documentsequenceno
                          messagetype
                          criticality
                          messagetext
                          basedate
                          costcenter
                          goodsmovementtype
                          plant
                          receivingissuing
                          storagelocation
                          materialnumber
                          quantity
                          unitofmeasure
                          batch
                          salesorder
                          salesorderitem
                          valuationtype
                          requirementdate
                          glaccount
                        ) WITH lt_file_c
      MAPPED DATA(lt_mapped_create)
      REPORTED DATA(lt_mapped_reported)
      FAILED DATA(lt_failed_create).

    ENDIF.

    "Update Status C for table Header
    MODIFY ENTITIES OF zi_mn_reservation IN LOCAL MODE
      ENTITY managefile
        UPDATE FIELDS ( status countline )
        WITH VALUE #( FOR ls_record IN lt_record (
                      %tky      = ls_record-%tky
                      countline = lines( lt_file )
                      status    = file_status-open ) ).

  ENDMETHOD.

  METHOD setstatustoopen.

    READ ENTITIES OF zi_mn_reservation IN LOCAL MODE
       ENTITY managefile
         FIELDS ( status )
         WITH CORRESPONDING #( keys )
       RESULT DATA(lt_file).

    "If Status is already set, do nothing
    DELETE lt_file WHERE status IS NOT INITIAL.
    CHECK lt_file IS NOT INITIAL.

*    READ TABLE lt_file INDEX 1 ASSIGNING FIELD-SYMBOL(<lfs_file>).

    DATA lv_cnt1 TYPE i.
    DATA lv_cnt2 TYPE i.
    DATA lv_next TYPE i.

    " lấy max không cộng sẵn
    SELECT SINGLE MAX( zcount )
      FROM zui_mco11n
      WHERE createdbyuser = @sy-uname
      INTO @lv_cnt1.

    SELECT SINGLE MAX( zcount )
      FROM zud_mco11n
      WHERE createdbyuser = @sy-uname
      INTO @lv_cnt2.

    lv_next = COND i( WHEN lv_cnt1 >= lv_cnt2 THEN lv_cnt1 + 1 ELSE lv_cnt2 + 1 ).

    MODIFY ENTITIES OF zi_mn_reservation IN LOCAL MODE
      ENTITY managefile
        UPDATE FIELDS ( status zcount )
        WITH VALUE #( FOR ls_file IN lt_file ( %tky   = ls_file-%tky
                                               status = file_status-open
                                               zcount = lv_next ) ).

  ENDMETHOD.

ENDCLASS.

CLASS lhc_datafile DEFINITION INHERITING FROM cl_abap_behavior_handler.
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

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR datafile RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR datafile RESULT result.

    METHODS postreser FOR MODIFY
      IMPORTING keys FOR ACTION datafile~postreser RESULT result.

    METHODS setstatustoupdate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR datafile~setstatustoupdate.


ENDCLASS.

CLASS lhc_datafile IMPLEMENTATION.

  METHOD get_instance_features.

    " Đọc các trường cần để quyết định enable/disable
    READ ENTITIES OF zi_mn_reservation IN LOCAL MODE
      ENTITY datafile
        FIELDS ( reservation messagetype )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_rows).

    LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<row>).

      " Đã có số reservation => coi như đã post
      DATA(lv_posted) = xsdbool( <row>-reservation IS NOT INITIAL ).

      IF lv_posted = abap_true.
        " Tắt sửa + tắt nút Edit (draft action)
        APPEND VALUE #(
          %tky    = <row>-%tky
          %update = if_abap_behv=>fc-o-disabled
          %delete = if_abap_behv=>fc-o-disabled
        ) TO result.
      ELSE.
        " Cho phép (tuỳ bạn, có thể bỏ nhánh này – mặc định là enabled)
        APPEND VALUE #(
          %tky    = <row>-%tky
          %update = if_abap_behv=>fc-o-enabled
        ) TO result.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD postreser.

    TYPES:
      BEGIN OF ty_return,
        uuid    TYPE sysuuid_x16,
        msgid   TYPE string,
        msgno   TYPE symsgno,
        msgtext TYPE string,
        type    TYPE abap_boolean,
        v1      TYPE string,
        v2      TYPE string,
        v3      TYPE string,
        v4      TYPE string,
        v5      TYPE string,
      END OF ty_return,

      BEGIN OF ty_ranges,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE c LENGTH 50,
        high   TYPE c LENGTH 50,
      END OF ty_ranges,

      tt_gty_return TYPE TABLE OF ty_return.

    DATA: lt_return TYPE tt_gty_return.

    zcl_process_reservation=>post_reservation(
      EXPORTING
        keys     = keys
      CHANGING
        result   = result
        mapped   = mapped
        failed   = failed
        reported = reported
        e_return = lt_return
    ).

    LOOP AT lt_return INTO DATA(ls_return).
      APPEND VALUE #(
        %msg = new_message(
                 id       = 'ZUPRESER'                "message class của bạn
                 number   = ls_return-msgno               "vd: 001 'Không tìm thấy tổ hợp {&1}/{&2}/{&3}/{&4}'
*                         V1       =
*                         V2       =
*                         V3       =
*                         V4       =
                 severity = if_abap_behv_message=>severity-error )
        " (optional) highlight các field
      ) TO reported-datafile.
    ENDLOOP.

  ENDMETHOD.

  METHOD setstatustoupdate.
    READ TABLE keys INDEX 1 INTO DATA(k).

    READ ENTITIES OF zi_mn_reservation IN LOCAL MODE
    ENTITY datafile BY \_managefile
    FIELDS ( uuid )                               "chỉ cần lấy key parent
    WITH CORRESPONDING #( keys )
    RESULT DATA(parents).

    IF parents IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE parents INDEX 1 INTO DATA(wa_parent).

    "Lấy danh sách parent duy nhất
    READ ENTITIES OF zi_mn_reservation IN LOCAL MODE
    ENTITY managefile BY \_datareservation
    ALL FIELDS WITH VALUE #( ( %tky = wa_parent-%tky ) )
    RESULT DATA(childs).

    "--- (tuỳ chọn) kiểm tra all reserved và set DONE ---
    DATA(all_have) = abap_true.
    LOOP AT childs ASSIGNING FIELD-SYMBOL(<c>).
      IF <c>-reservation IS INITIAL.
        all_have = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF all_have = abap_true.
      MODIFY ENTITIES OF zi_mn_reservation IN LOCAL MODE
        ENTITY managefile
        UPDATE FIELDS ( status )
        WITH VALUE #( ( %tky = wa_parent-%tky status = file_status-completed ) )
        FAILED DATA(ls_failed) REPORTED DATA(ls_reported).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_mn_reservation DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_mn_reservation IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

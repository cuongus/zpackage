CLASS lhc_managefile DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES: BEGIN OF ty_file_upload,
*             PRODUCTIONPLANT             TYPE STRING,
             postingdate                 TYPE string,
             manufacturingorder          TYPE string,
             manufacturingorderoperation TYPE string,
             workcenter                  TYPE string,
             optotalconfirmedyieldqty    TYPE string,
             quantity                    TYPE string,
             baseunit                    TYPE string,
             finalconfirmationtype       TYPE string,
             variancereasoncode          TYPE string,
             confirmationtext            TYPE string,
             confirmedexecutionstartdate TYPE string,
             confirmedexecutionstarttime TYPE string,
             confirmedexecutionenddate   TYPE string,
             confirmedexecutionendtime   TYPE string,
             shift                       TYPE string,
             machineid                   TYPE string,
             teamid                      TYPE string,
             workerid                    TYPE string,
           END OF ty_file_upload,

           BEGIN OF ty_qty_at,
             manufacturingorder          TYPE string,
             manufacturingorderoperation TYPE string,
             opconfirmedworkquantity1    TYPE zde_qty,
             opconfirmedworkquantity2    TYPE zde_qty,
             opconfirmedworkquantity3    TYPE zde_qty,
             opconfirmedworkquantity4    TYPE zde_qty,
             opconfirmedworkquantity5    TYPE zde_qty,
             opconfirmedworkquantity6    TYPE zde_qty,
             opworkquantityunit1         TYPE zde_char5,
             opworkquantityunit2         TYPE zde_char5,
             opworkquantityunit3         TYPE zde_char5,
             opworkquantityunit4         TYPE zde_char5,
             opworkquantityunit5         TYPE zde_char5,
             opworkquantityunit6         TYPE zde_char5,
           END OF ty_qty_at.

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

    CONSTANTS: c_apiname  TYPE string VALUE '/sap/opu/odata/sap/API_PRODUCTION_ORDER_2_SRV'.

    CLASS-DATA: c_username TYPE string,
                c_password TYPE string.


    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR managefile RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE managefile.

    METHODS downloadfile FOR MODIFY
      IMPORTING keys FOR ACTION managefile~downloadfile RESULT result.

    METHODS fileupload FOR MODIFY
      IMPORTING keys FOR ACTION managefile~fileupload.

    METHODS setstatustoopen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR managefile~setstatustoopen.

    METHODS getexceldata FOR DETERMINE ON SAVE
      IMPORTING keys FOR managefile~getexceldata.

    METHODS convert_date IMPORTING i_date         TYPE string
                         RETURNING VALUE(rv_dats) TYPE string.

    METHODS convert_time IMPORTING iv_time         TYPE string
                         RETURNING VALUE(rv_uzeit) TYPE timn.

    METHODS get_lsx_confirm IMPORTING i_prefix          TYPE string
                                      i_filter          TYPE string
                            EXPORTING tt_results        TYPE ztt_resp_results_get_lsx
                            RETURNING VALUE(rv_confirm) TYPE abap_boolean
                            RAISING
                                      zcx_http_call_failed.

    METHODS get_operations IMPORTING i_prefix          TYPE string
                                     i_filter          TYPE string
                           EXPORTING tt_results        TYPE ztt_resp_results_get_lsx
                           RETURNING VALUE(rv_confirm) TYPE abap_boolean
                           RAISING
                                     zcx_http_call_failed.

    METHODS get_time_milis IMPORTING i_date           TYPE zde_dats OPTIONAL
                                     i_time           TYPE zde_tims OPTIONAL
                           EXPORTING e_current_millis TYPE zde_numc15
                           RAISING
                                     cx_abap_context_info_error.

    METHODS call_external_api IMPORTING i_prefix  TYPE string
                                        i_filter  TYPE string OPTIONAL
                                        i_context TYPE string OPTIONAL
                                        i_method  TYPE string
                              EXPORTING e_context TYPE string
                              RAISING
                                        zcx_http_call_failed.

ENDCLASS.

CLASS lhc_managefile IMPLEMENTATION.

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
                          %is_draft = <f_entities>-%is_draft
          )
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

    "ヘッダの設定（すべての項目はstring型）
*    LT_FILE = VALUE #(
*************Line One
*                       (
**                         PRODUCTIONPLANT             = 'Plant'
*                       POSTINGDATE                 = 'Confirmed date'
*                       MANUFACTURINGORDER          = 'Production order'
*                       MANUFACTURINGORDEROPERATION = 'Operation'
*                       WORKCENTER                  = 'Work Center'
*                       OPTOTALCONFIRMEDYIELDQTY    = 'Confirmed Quantity'
*                       VARIANCEREASONCODE          = 'Reason for Variance'
*                       CONFIRMATIONTEXT            = 'Text'
*                       CONFIRMEDEXECUTIONSTARTDATE = 'Ngày bắt đầu'
*                       CONFIRMEDEXECUTIONSTARTTIME = 'Thời gian bắt đầu'
*                       CONFIRMEDEXECUTIONENDDATE   = 'Ngày kết thúc'
*                       CONFIRMEDEXECUTIONENDTIME   = 'Thời gian kết thúc'
*                       SHIFT                       = 'Ca'
*                       MachineID                   = 'Máy'
*                       TEAMID                      = 'Mã tổ'
*                       WORKERID                    = 'Mã nhân viên'
*                       )
*************Line Two
*                       (
**                         PRODUCTIONPLANT             = '6711'
*                       POSTINGDATE                 = '13/09/2025'
*                       MANUFACTURINGORDER          = '10070000021'
*                       MANUFACTURINGORDEROPERATION = '0020'
*                       WORKCENTER                  = '67110011'
*                       OPTOTALCONFIRMEDYIELDQTY    = '10'
*                       VARIANCEREASONCODE          = 'X'
*                       CONFIRMATIONTEXT            = ''
*                       CONFIRMEDEXECUTIONSTARTDATE = '29/08/2025'
*                       CONFIRMEDEXECUTIONSTARTTIME = '7:00:00'
*                       CONFIRMEDEXECUTIONENDDATE   = '29/08/2025'
*                       CONFIRMEDEXECUTIONENDTIME   = '24:00:00'
*                       SHIFT                       = '3'
*                       MachineID                   = 'M1'
*                       TEAMID                      = 'Tổ sản xuất 1'
*                       WORKERID                    = 'CL00001' )
*                     ).

    lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_from( REF #( lt_file )
        )->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    SELECT SINGLE * FROM zcore_tb_temppdf
    WHERE id = 'zco11n'
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
                                          filename      = 'CO11NTemplate'
                                          fileextension = 'xlsx'
                                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                        ) ).
    ELSE.
      result = VALUE #( FOR key IN keys (
                        %cid   = key-%cid
                        %param = VALUE #( filecontent   = ls_tb_temppdf-file_content
                                          filename      = 'CO11NTemplate'
                                          fileextension = 'xlsx'
                                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                        ) ).
    ENDIF.

  ENDMETHOD.

  METHOD fileupload.

    DATA lt_file TYPE STANDARD TABLE OF ty_file_upload.

    DATA: lt_mn_file TYPE TABLE FOR CREATE zim_confirm_production_order,
          ls_mn_file LIKE LINE OF lt_mn_file,

          lt_file_c  TYPE TABLE FOR CREATE zim_confirm_production_order\_datafile,
          ls_file_c  LIKE LINE OF lt_file_c.

    DATA: lt_keys TYPE TABLE FOR READ IMPORT zim_confirm_production_order.

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
      MODIFY ENTITIES OF zim_confirm_production_order IN LOCAL MODE
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

  METHOD setstatustoopen.


    READ ENTITIES OF zim_confirm_production_order IN LOCAL MODE
     ENTITY managefile
       FIELDS ( status )
       WITH CORRESPONDING #( keys )
     RESULT DATA(lt_file).

    "If Status is already set, do nothing
    DELETE lt_file WHERE status IS NOT INITIAL.
    DELETE lt_file WHERE status = 'X'.

    CHECK lt_file IS NOT INITIAL.

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

    MODIFY ENTITIES OF zim_confirm_production_order IN LOCAL MODE
      ENTITY managefile
        UPDATE FIELDS ( status zcount )
        WITH VALUE #( FOR ls_file IN lt_file ( %tky   = ls_file-%tky
                                               status = file_status-open
                                               zcount = lv_next ) ).


  ENDMETHOD.

  METHOD getexceldata.


    DATA: lt_file TYPE STANDARD TABLE OF ty_file_upload.

    DATA: lt_file_c TYPE TABLE FOR CREATE zim_confirm_production_order\\managefile\_datafile,
          ls_file_c LIKE LINE OF lt_file_c.

    " Read the parent instance
    READ ENTITIES OF zim_confirm_production_order IN LOCAL MODE
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
    "create new entity
*    lt_file_C = CORRESPONDING #( LT_FILE ).

    DATA lv_time   TYPE t.
    DATA lv_date   TYPE d.  "ngày gốc đọc cùng hàng
    DATA lv_text   TYPE string VALUE ''.

    DATA lv_index TYPE int4.

    DATA: lr_machineid TYPE RANGE OF zc_kb_somay-machineid,
          lr_teamid    TYPE RANGE OF zc_kb_tsx-teamid,
          lr_workerid  TYPE RANGE OF zc_kb_nhancong-workerid.

    READ TABLE lt_record ASSIGNING FIELD-SYMBOL(<f_file>) INDEX 1.

    DATA: lt_data_file TYPE TABLE OF ziu_confirm_production_order,
          ls_data_file LIKE LINE OF lt_data_file.

    "Process data Raw
    LOOP AT lt_file INTO DATA(ls_file).
*      LS_FILE_C-PRODUCTIONPLANT   = LS_FILE-PRODUCTIONPLANT.
      ls_data_file-postingdate = me->convert_date( i_date = ls_file-postingdate ).

      ls_file-manufacturingorder = |{ ls_file-manufacturingorder ALPHA = IN WIDTH = 12 }|.

      SELECT SINGLE earliestscheduledwaitstartdate,
                    earliestscheduledwaitstarttime,
                    earliestscheduledwaitenddate,
                    earliestscheduledwaitendtime
                 FROM i_productionorderoperation_2
                 WITH PRIVILEGED ACCESS
      WHERE productionorder = @ls_file-manufacturingorder
      AND productionorderoperation = @ls_file-manufacturingorderoperation
      INTO @DATA(ls_productionorderoperation_2).
      IF sy-subrc NE 0.
        CLEAR: ls_productionorderoperation_2.
      ENDIF.

      IF ls_file-confirmedexecutionstartdate IS NOT INITIAL.
        ls_data_file-confirmedexecutionstartdate = me->convert_date( i_date = ls_file-confirmedexecutionstartdate ).
      ELSE.
        ls_data_file-confirmedexecutionstartdate = ls_productionorderoperation_2-earliestscheduledwaitstartdate.
      ENDIF.

      IF ls_file-confirmedexecutionenddate IS NOT INITIAL.
        ls_data_file-confirmedexecutionenddate   = me->convert_date( i_date = ls_file-confirmedexecutionenddate ).
      ELSE.
        ls_data_file-confirmedexecutionenddate = ls_productionorderoperation_2-earliestscheduledwaitenddate.
      ENDIF.

      IF ls_file-confirmedexecutionstarttime IS NOT INITIAL.
        ls_data_file-confirmedexecutionstarttime = me->convert_time( iv_time = ls_file-confirmedexecutionstarttime ).
      ELSE.
        ls_data_file-confirmedexecutionstarttime = ls_productionorderoperation_2-earliestscheduledwaitstarttime.
      ENDIF.

      IF ls_file-confirmedexecutionendtime IS NOT INITIAL.
        ls_data_file-confirmedexecutionendtime   = me->convert_time( iv_time = ls_file-confirmedexecutionendtime ).
      ELSE.
        ls_data_file-confirmedexecutionendtime = ls_productionorderoperation_2-earliestscheduledwaitendtime.
      ENDIF.

      ls_data_file-manufacturingorder          = ls_file-manufacturingorder.
      ls_data_file-manufacturingorderoperation = ls_file-manufacturingorderoperation.
      ls_data_file-workcenter                  = ls_file-workcenter.
      ls_data_file-optotalconfirmedyieldqty    = ls_file-optotalconfirmedyieldqty .

      ls_data_file-quantity                    = ls_file-quantity .

      TRANSLATE ls_file-baseunit TO UPPER CASE.
      ls_data_file-baseunit                    = ls_file-baseunit.

      ls_data_file-finalconfirmationtype       = ls_file-finalconfirmationtype .
      ls_data_file-variancereasoncode          = ls_file-variancereasoncode.
      ls_data_file-confirmationtext            = ls_file-confirmationtext.

      ls_data_file-shift       = ls_file-shift .
      ls_data_file-machineid   = ls_file-machineid.
      ls_data_file-teamid      = ls_file-teamid.
      ls_data_file-workerid    = ls_file-workerid.

      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-machineid ) TO lr_machineid.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-teamid ) TO lr_teamid.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_file-workerid ) TO lr_workerid.

      APPEND ls_data_file TO lt_data_file.
      CLEAR: ls_data_file.

    ENDLOOP.

*    lv_fail = abap_false.

    SORT lr_machineid BY low ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lr_machineid COMPARING low.

    SORT lr_teamid BY low ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lr_teamid COMPARING low.

    SORT lr_workerid BY low ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lr_workerid COMPARING low.

    IF lr_machineid IS NOT INITIAL.
      SELECT * FROM zc_kb_somay
      WHERE machineid IN @lr_machineid
      INTO TABLE @DATA(lt_kb_somay).
    ENDIF.

    IF lr_teamid IS NOT INITIAL.
      SELECT * FROM zc_kb_tsx
        WHERE teamid IN @lr_teamid
        INTO TABLE @DATA(lt_kb_tsx).
    ENDIF.

    IF lr_workerid IS NOT INITIAL.
      SELECT * FROM zc_kb_nhancong
       WHERE workerid IN @lr_workerid
       INTO TABLE @DATA(lt_kb_nhancong).
    ENDIF.

    DATA: lv_prefix TYPE string,
          lv_filter TYPE string.

    DATA: lt_results TYPE ztt_resp_results_get_lsx.

    SORT lt_kb_nhancong BY workcenter workerid ASCENDING.
    SORT lt_kb_somay BY workcenter machineid ASCENDING.
    SORT lt_kb_tsx BY workcenter teamid ASCENDING.

    LOOP AT lt_data_file ASSIGNING FIELD-SYMBOL(<lfs_file_c>).
      lv_index = sy-tabix.
      CLEAR: lv_prefix.
      IF <lfs_file_c>-manufacturingorder IS NOT INITIAL.

        lv_prefix = |/A_ProductionOrder_2|.                  "hoặc dùng Accept header\r\n| &
        lv_filter = |ManufacturingOrder eq '{ <lfs_file_c>-manufacturingorder }' | &&
                    |and OrderIsReleased eq 'X' and OrderIsConfirmed eq '' and OrderIsDeleted eq '' and OrderIsTechnicallyCompleted eq '' and OrderIsClosed eq '' and OrderIsMarkedForDeletion eq ''|
                    .

        TRY.
            DATA(rv_confirm) = me->get_lsx_confirm(
              EXPORTING
                i_prefix   = lv_prefix
                i_filter   = lv_filter
              IMPORTING
                tt_results = lt_results
            ).

            IF rv_confirm = abap_false.
              <lfs_file_c>-message = 'LSX không đủ điều kiện để xác nhận công đoạn'.
              <lfs_file_c>-messagetype = file_status-error.
*              <lfs_file_c>-status = 'E'. "Error
            ELSE.
              READ TABLE lt_results INDEX 1 INTO DATA(ls_results).
              IF sy-subrc EQ 0.
                <lfs_file_c>-confirmationunit = ls_results-productionunit.
              ENDIF.
            ENDIF.
          CATCH zcx_http_call_failed.
            "handle exception
        ENDTRY.
      ENDIF.

      CLEAR: rv_confirm, ls_results.
      FREE: lt_results.

      IF <lfs_file_c>-manufacturingorderoperation IS NOT INITIAL.

        lv_prefix = |/A_ProductionOrderOperation_2|.                  "hoặc dùng Accept header\r\n| &
        lv_filter = |ManufacturingOrder eq '{ <lfs_file_c>-manufacturingorder }' | &&
                    |and ManufacturingOrderOperation eq '{ <lfs_file_c>-manufacturingorderoperation }' |
                    .
        TRY.
            rv_confirm = me->get_operations(
              EXPORTING
                i_prefix   = lv_prefix
                i_filter   = lv_filter
              IMPORTING
                tt_results = lt_results
            ).

            IF rv_confirm IS INITIAL.
              <lfs_file_c>-message = 'Sai thông tin Operation'.
              <lfs_file_c>-messagetype = file_status-error.
*              <lfs_file_c>-status = 'E'. "Error
            ELSE.
              READ TABLE lt_results INDEX 1 INTO ls_results.
              IF sy-subrc EQ 0.

              ENDIF.
            ENDIF.
          CATCH zcx_http_call_failed.
            "handle exception
        ENDTRY.
      ENDIF.

      CLEAR: rv_confirm.

      IF <lfs_file_c>-workcenter IS NOT INITIAL.

        lv_prefix = |/A_ProductionOrderOperation_2|.                  "hoặc dùng Accept header\r\n| &
        lv_filter = |ManufacturingOrder eq '{ <lfs_file_c>-manufacturingorder }' | &&
                    |and ManufacturingOrderOperation eq '{ <lfs_file_c>-manufacturingorder }' | &&
                    |and WorkCenter eq '{ <lfs_file_c>-workcenter }'|
                    .
        IF ls_results-workcenter NE <lfs_file_c>-workcenter.
          <lfs_file_c>-message = 'Sai Work Center'.
          <lfs_file_c>-messagetype = file_status-error.
*          <lfs_file_c>-status = 'E'. "Error
        ENDIF.
      ELSE.
        <lfs_file_c>-workcenter = ls_results-workcenter.
      ENDIF.

      CLEAR: rv_confirm, ls_results.
      FREE: lt_results.

      IF <lfs_file_c>-finalconfirmationtype NE '' AND <lfs_file_c>-finalconfirmationtype NE 'X'.
        <lfs_file_c>-message = 'Final Confirm Validate 2 giá trị: Trống hoặc X'.
        <lfs_file_c>-messagetype = file_status-error.
*        <lfs_file_c>-status = 'E'. "Error
      ENDIF.

      IF <lfs_file_c>-variancereasoncode NE 'Z001'
      AND <lfs_file_c>-variancereasoncode NE 'Z002'
      AND <lfs_file_c>-variancereasoncode NE 'Z003'
      AND <lfs_file_c>-variancereasoncode NE 'Z004'
      AND <lfs_file_c>-variancereasoncode NE 'Z005' AND <lfs_file_c>-variancereasoncode NE ''.
        <lfs_file_c>-message = 'Validate VarianceReasonCode với 5 giá trị: Z001, Z002, Z003, Z004, Z005'.
        <lfs_file_c>-messagetype = file_status-error.
*        <lfs_file_c>-status = 'E'. "Error
      ENDIF.

*      READ TABLE LT_TW_LIST TRANSPORTING NO FIELDS WITH KEY MachineId = <LFS_FILE_C>-MachineID
*                                                            Shift = <LFS_FILE_C>-Shift
*                                                            TeamId = <LFS_FILE_C>-TeamID
*                                                            WorkerId = <LFS_FILE_C>-WorkerID
*                                                            BINARY SEARCH.
*      IF SY-SUBRC NE 0.
*        LV_FAIL = ABAP_TRUE.

      "1) Ghi message để FE hiển thị
*        APPEND VALUE #(
*          %MSG = NEW_MESSAGE(
*                   ID       = 'ZCO11N'                "message class của bạn
*                   NUMBER   = '001'               "vd: 001 'Không tìm thấy tổ hợp {&1}/{&2}/{&3}/{&4}'
*                   V1       = <LFS_FILE_C>-MachineID
*                   V2       = <LFS_FILE_C>-Shift
*                   V3       = <LFS_FILE_C>-TeamID
*                   V4       = <LFS_FILE_C>-WorkerID
*                   SEVERITY = IF_ABAP_BEHV_MESSAGE=>SEVERITY-ERROR )
*          " (optional) highlight các field
*          %ELEMENT-MachineID = IF_ABAP_BEHV=>MK-ON
*          %ELEMENT-Shift     = IF_ABAP_BEHV=>MK-ON
*          %ELEMENT-TeamID    = IF_ABAP_BEHV=>MK-ON
*          %ELEMENT-WorkerID  = IF_ABAP_BEHV=>MK-ON
*        ) TO REPORTED-ConfirmProductionOrder.

*        <LFS_FILE_C>-Message = |Does not exist MachineID: { <LFS_FILE_C>-MachineID } Shift: { <LFS_FILE_C>-Shift } TeamID: { <LFS_FILE_C>-TeamID } Worker: { <LFS_FILE_C>-WorkerID }|.
*        <LFS_FILE_C>-MessageType = 'E'.
*        <LFS_FILE_C>-Status = 'X'.
*      ENDIF.

      READ TABLE lt_kb_somay TRANSPORTING NO FIELDS WITH KEY workcenter = <lfs_file_c>-workcenter
                                                             machineid = <lfs_file_c>-machineid BINARY SEARCH.
      IF sy-subrc NE 0 AND <lfs_file_c>-machineid IS NOT INITIAL.
*        <lfs_file_c>-status = 'E'.
        <lfs_file_c>-messagetype = file_status-error.
        <lfs_file_c>-message = `Không tồn tại Số Máy: ` && <lfs_file_c>-machineid.
      ENDIF.

      READ TABLE lt_kb_tsx TRANSPORTING NO FIELDS WITH KEY  workcenter = <lfs_file_c>-workcenter
                                                            teamid = <lfs_file_c>-teamid BINARY SEARCH.
      IF sy-subrc NE 0 AND <lfs_file_c>-teamid IS NOT INITIAL.
*        <lfs_file_c>-status = 'E'.
        <lfs_file_c>-messagetype = file_status-error.
        <lfs_file_c>-message = `Không tồn tại Tổ Sản Xuất: ` && <lfs_file_c>-machineid.
      ENDIF.

      READ TABLE lt_kb_nhancong TRANSPORTING NO FIELDS WITH KEY workcenter = <lfs_file_c>-workcenter
                                                                workerid = <lfs_file_c>-workerid BINARY SEARCH.
      IF sy-subrc NE 0 AND <lfs_file_c>-workerid IS NOT INITIAL.
*        <lfs_file_c>-status = 'E'.
        <lfs_file_c>-messagetype = file_status-error.
        <lfs_file_c>-message = `Không tồn tại Nhân Công: ` && <lfs_file_c>-workerid.
      ENDIF.

      IF <lfs_file_c>-shift IS NOT INITIAL
      AND <lfs_file_c>-shift NE '1'
      AND <lfs_file_c>-shift NE '2'
      AND <lfs_file_c>-shift NE '3'.
*        <lfs_file_c>-status = 'E'.
        <lfs_file_c>-messagetype = file_status-error.
        <lfs_file_c>-message = `Không tồn tại Ca: ` && <lfs_file_c>-shift.
      ENDIF.

    ENDLOOP.

    LOOP AT lt_data_file INTO ls_data_file.
      lv_index = sy-tabix.

      TRY.
          " <f_file> là bản ghi cha đọc từ READ ENTITIES
          ls_file_c = VALUE #(
            %tky    = <f_file>-%tky                  "<<< BẮT BUỘC: trỏ về instance cha trong buffer
*          %is_draft = <f_file>-%is_draft          " (tuỳ chọn, framework suy ra từ %tky)
            %target = VALUE #( (
                               %cid                        = lv_index
*          uuid               = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( )   "nếu key con tự cấp; nếu early numbering thì bỏ
*          uuidfile           = <f_file>-uuid      "<<< BỎ: framework sẽ gán FK dựa vào %tky
                               postingdate                 = ls_data_file-postingdate
                               confirmedexecutionstartdate = ls_data_file-confirmedexecutionstartdate
                               confirmedexecutionenddate   = ls_data_file-confirmedexecutionenddate

                               confirmedexecutionstarttime = ls_data_file-confirmedexecutionstarttime
                               confirmedexecutionendtime   = ls_data_file-confirmedexecutionendtime

                               manufacturingorder          = ls_data_file-manufacturingorder
                               manufacturingorderoperation = ls_data_file-manufacturingorderoperation
                               workcenter                  = ls_data_file-workcenter
                               optotalconfirmedyieldqty    = ls_data_file-optotalconfirmedyieldqty

                               quantity                    = ls_data_file-quantity
                               baseunit                    = ls_data_file-baseunit

                               finalconfirmationtype       = ls_data_file-finalconfirmationtype
                               variancereasoncode          = ls_data_file-variancereasoncode
                               confirmationtext            = ls_data_file-confirmationtext

                               shift                       = ls_data_file-shift
                               machineid                   = ls_data_file-machineid
                               teamid                      = ls_data_file-teamid
                               workerid                    = ls_data_file-workerid

                               message                     = ls_data_file-message
                               messagetype                 = ls_data_file-messagetype
                               ) )
          ).
        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.

      APPEND ls_file_c TO lt_file_c.
      CLEAR: ls_file_c.

    ENDLOOP.

*    IF NOT lv_fail IS NOT INITIAL.
    MODIFY ENTITIES OF zim_confirm_production_order IN LOCAL MODE
    ENTITY managefile
    CREATE BY \_datafile FIELDS (
                                  productionplant
                                  postingdate
                                  manufacturingorder
                                  manufacturingorderoperation
                                  workcenter
                                  optotalconfirmedyieldqty
                                  quantity
                                  baseunit
                                  finalconfirmationtype
                                  variancereasoncode
                                  confirmationtext
                                  confirmedexecutionstartdate
                                  confirmedexecutionstarttime
                                  confirmedexecutionenddate
                                  confirmedexecutionendtime
                                  machineid
                                  shift
                                  teamid
                                  workerid
                                  confirmationunit
*                                    status
                                  message
                                  messagetype
                                ) WITH lt_file_c
    MAPPED DATA(lt_mapped_create)
    REPORTED DATA(lt_mapped_reported)
    FAILED DATA(lt_failed_create).
*    ENDIF.

    "Update Status C for table Header
    MODIFY ENTITIES OF zim_confirm_production_order IN LOCAL MODE
      ENTITY managefile
        UPDATE FIELDS ( status countline )
        WITH VALUE #( FOR ls_record IN lt_record (
                      %tky      = ls_record-%tky
                      countline = lines( lt_file )
                      status    = file_status-open ) ).

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

  METHOD convert_time.

    " I_TIME: giá trị thời gian từ Excel (vd 0.3125, 0.708333…)
    " RV_UZEIT: kiểu T/UZEIT (HHMMSS)

    DATA: lv_dec     TYPE decfloat34,
          lv_seconds TYPE i,
          lv_h       TYPE i,
          lv_m       TYPE i,
          lv_s       TYPE i,
          lv_text    TYPE string.

    " Ép kiểu + chỉ lấy phần thập phân (phòng khi ô có cả ngày+giờ)
    lv_dec = CONV decfloat34( iv_time ).
    lv_dec = lv_dec - floor( lv_dec ).

    " Quy đổi ra số giây trong ngày
    lv_seconds = round( val = lv_dec * 86400 dec = 0 ).

    " Chuẩn hóa: 24:00 -> 00:00
    IF lv_seconds >= 86400.
      lv_seconds = 0.
    ENDIF.

    lv_h = lv_seconds DIV 3600.
    lv_m = ( lv_seconds MOD 3600 ) DIV 60.
    lv_s = lv_seconds MOD 60.

    " Zero-pad từng thành phần bằng WIDTH + PAD
    DATA: lv_hs TYPE zde_char2,
          lv_ms TYPE zde_char2,
          lv_ss TYPE zde_char2.

    lv_hs = lv_h.
    lv_ms = lv_m.
    lv_ss = lv_s.

    lv_hs = |{ lv_hs ALPHA = IN }|.
    lv_ms = |{ lv_ms ALPHA = IN }|.
    lv_ss = |{ lv_ss ALPHA = IN }|.

    lv_text = |{ lv_hs }{ lv_ms }{ lv_ss }|.
    rv_uzeit = lv_text.  " '073000', '170000', …

  ENDMETHOD.

  METHOD get_lsx_confirm.
    DATA: ls_resp_data TYPE zst_resp_get_lsx.

    me->call_external_api(
      EXPORTING
        i_prefix  = i_prefix
        i_filter  = i_filter
        i_method  = 'GET'
      IMPORTING
        e_context = DATA(lv_context)
    ).

    IF lv_context IS INITIAL.
      RETURN abap_false.
    ENDIF.

    FIELD-SYMBOLS: <ls_resp_data> TYPE any.
    /ui2/cl_json=>deserialize(
      EXPORTING
        json        = lv_context
*       jsonx       =
        pretty_name = /ui2/cl_json=>pretty_mode-none
*       assoc_arrays     =
*       assoc_arrays_opt =
*       name_mappings    =
*       conversion_exits =
*       hex_as_base64    =
      CHANGING
        data        = ls_resp_data
    ).

    IF ls_resp_data-d-__count = '0'.
      RETURN abap_false.
    ELSE.
      tt_results = ls_resp_data-d-results.

      RETURN abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_operations.
    DATA: ls_resp_data TYPE zst_resp_get_lsx.

    me->call_external_api(
      EXPORTING
        i_prefix  = i_prefix
        i_filter  = i_filter
        i_method  = 'GET'
      IMPORTING
        e_context = DATA(lv_context)
    ).

    IF lv_context IS INITIAL.
      RETURN abap_false.
    ENDIF.

    FIELD-SYMBOLS: <ls_resp_data> TYPE any.
    /ui2/cl_json=>deserialize(
      EXPORTING
        json        = lv_context
*       jsonx       =
        pretty_name = /ui2/cl_json=>pretty_mode-none
*       assoc_arrays     =
*       assoc_arrays_opt =
*       name_mappings    =
*       conversion_exits =
*       hex_as_base64    =
      CHANGING
        data        = ls_resp_data
    ).

    IF ls_resp_data-d-__count = '0'.
*      RETURN ABAP_FALSE.
      rv_confirm = ''.
    ELSE.
      tt_results = ls_resp_data-d-results.

      RETURN abap_true.
*      READ TABLE LS_RESP_DATA-D-RESULTS INDEX 1 INTO DATA(LS_RESULTS).
*      RV_CONFIRM = LS_RESULTS-WORKCENTER.
    ENDIF.
  ENDMETHOD.

  METHOD get_time_milis.

    DATA: date_1970        TYPE zde_dats VALUE '19700101',
          millis_in_day    TYPE zde_numc15 VALUE '86400000',
          millis_in_hour   TYPE zde_numc15 VALUE '3600000',
          millis_in_min    TYPE zde_numc15 VALUE '60000',
          millis_in_sec    TYPE zde_numc15 VALUE '1000',
          current_date     TYPE zde_dats,
          current_ts       TYPE timestampl,
          current_ts_s(22),
          sec_fraction     TYPE f.

    DATA: lv_time TYPE zde_tims.
*  GET TIME STAMP FIELD current_ts.
    DATA(lv_tzone) = cl_abap_context_info=>get_user_time_zone( ).

    IF i_time = '240000'.
      lv_time = '000000'.
    ELSE.
      lv_time = i_time.
    ENDIF.

    CONVERT DATE i_date TIME lv_time DAYLIGHT SAVING TIME 'X'
            INTO TIME STAMP DATA(time_stamp) TIME ZONE lv_tzone.

    current_ts = time_stamp.

    current_ts_s = current_ts.
    current_date = current_ts_s(8).
    sec_fraction = current_ts_s+14(8).

    e_current_millis = ( current_date - date_1970 ) * millis_in_day +
    current_ts_s+8(2) * millis_in_hour +
    current_ts_s+10(2) * millis_in_min +
    current_ts_s+12(2) * millis_in_sec +
    sec_fraction * millis_in_sec.

  ENDMETHOD.

  METHOD call_external_api.
    DATA: lv_url   TYPE string, " Replace with actual URL
          lv_query TYPE string,
          lv_pref  TYPE string,
          i_xml    TYPE string.
*          lv_uuid TYPE string VALUE `urn:uuid:{{$randomUUID}}`.
    TRY.
        DATA(lv_host) = cl_abap_context_info=>get_system_url( ).
        SPLIT lv_host AT '.' INTO lv_host lv_pref.
        CONCATENATE lv_host `-api` `.` lv_pref INTO lv_host.
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    SELECT SINGLE * FROM ztb_api_auth
    WITH PRIVILEGED ACCESS
    WHERE systemid = 'CASLA'
    INTO @DATA(ls_api_auth).

    IF sy-subrc EQ 0.
      c_username = ls_api_auth-api_user.
      c_password = ls_api_auth-api_password.
    ENDIF.

    "Post $Batch request
    lv_url = |https://{ lv_host }{ c_apiname }{ i_prefix }?$inlinecount=allpages|.

    TRY.
        "create http destination by url; API endpoint for API sandbox
        DATA(lo_http_destination) =
          cl_http_destination_provider=>create_by_url( lv_url ).

        "create HTTP client by destination
        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

        "adding headers
        DATA(lo_request) = lo_web_http_client->get_http_request( ).

        lo_request->set_header_fields( VALUE #(
        ( name = 'config_authType'    value = 'Basic' )
        ( name = 'config_packageName' value = 'S4HANACloudABAPPlatform' )
        ( name = 'config_actualUrl'   value = |https://{ lv_host }{ c_apiname }| )
        ( name = 'config_urlPattern'  value = 'https://{host}:{port}' && c_apiname )
        ( name = 'config_apiName'     value = c_apiname )
        ( name = 'DataServiceVersion' value = '2.0' )
        ( name = 'Accept'             value = 'application/json' )
        ) ).

        IF i_method = 'GET'.
*-- filter
          lo_request->set_form_field(  i_name = '$filter' i_value = i_filter ).
        ENDIF.

*-- Passing the Accept value in header which is a mandatory field
        lo_web_http_client->get_http_request( )->set_header_field( i_name = |username| i_value = c_username ).
        lo_web_http_client->get_http_request( )->set_header_field( i_name = |password| i_value = c_password ).

*-- Authorization
        lo_web_http_client->get_http_request( )->set_authorization_basic( i_username = c_username i_password = c_password ).
        lo_web_http_client->get_http_request( )->set_content_type( |text/xml;charset=UTF-8| ).

        lo_web_http_client->get_http_request( )->set_version( version = if_web_http_request=>co_protocol_version_1_1 ).

        "set request method and execute request
        CASE i_method.
          WHEN 'GET'.
            lo_web_http_client->execute( i_method = if_web_http_client=>get
                                         ).

            DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>get ).
          WHEN 'POST'.
*-- Send request ->
            lo_web_http_client->execute( i_method = if_web_http_client=>post
                                         ).

            lo_web_http_client->get_http_request( )->set_text( i_context ).
            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>post ).
          WHEN OTHERS.
            e_context = 'Not valid Methods'.
            RETURN.
        ENDCASE.

        DATA(lv_response) = lo_web_http_response->get_text( ).
        DATA(code) = lo_web_http_response->get_status( )-code.
        DATA(reason) = lo_web_http_response->get_status( )-reason.

        e_context = lv_response.

        "error handling
      CATCH cx_http_dest_provider_error
            cx_web_http_client_error
            cx_web_message_error INTO DATA(lx_msg).
*
        DATA(lv_err_text) = zcl_http_err_helper=>to_text( lx_msg ).

        RAISE EXCEPTION NEW zcx_http_call_failed( mv1 = lv_err_text ).

    ENDTRY.
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
        inprocess TYPE c LENGTH 1 VALUE 'P', "In Process
        error     TYPE c LENGTH 1 VALUE 'E', "Error
        success   TYPE c LENGTH 1 VALUE 'S', "Success
      END OF file_status.

    CONSTANTS: c_apiname  TYPE string VALUE '/sap/opu/odata/sap/API_PRODUCTION_ORDER_2_SRV'.

    CLASS-DATA: c_username TYPE string,
                c_password TYPE string.

    CONSTANTS: lc_crlf TYPE string VALUE cl_abap_char_utilities=>cr_lf.

    TYPES: BEGIN OF ty_qty_at,
             manufacturingorder          TYPE string,
             manufacturingorderoperation TYPE string,
             opconfirmedworkquantity1    TYPE zde_qty,
             opconfirmedworkquantity2    TYPE zde_qty,
             opconfirmedworkquantity3    TYPE zde_qty,
             opconfirmedworkquantity4    TYPE zde_qty,
             opconfirmedworkquantity5    TYPE zde_qty,
             opconfirmedworkquantity6    TYPE zde_qty,
             opworkquantityunit1         TYPE zde_char5,
             opworkquantityunit2         TYPE zde_char5,
             opworkquantityunit3         TYPE zde_char5,
             opworkquantityunit4         TYPE zde_char5,
             opworkquantityunit5         TYPE zde_char5,
             opworkquantityunit6         TYPE zde_char5,
           END OF ty_qty_at,

           tt_qty_at                   TYPE TABLE OF ty_qty_at,

           tt_confirm_production_order TYPE TABLE OF ziu_confirm_production_order,

           BEGIN OF ty_return,
             manufacturingorder          TYPE string,
             manufacturingorderoperation TYPE string,
             msgtype                     TYPE string,
             msgtext                     TYPE string,
           END OF ty_return,

           tt_return TYPE TABLE OF ty_return,

           BEGIN OF ty_error,
             msgtype TYPE string,
             msgtext TYPE string,
           END OF ty_error.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR datafile RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR datafile RESULT result.

    METHODS postconfirm FOR MODIFY
      IMPORTING keys FOR ACTION datafile~postconfirm RESULT result.

    METHODS setstatustoupdate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR datafile~setstatustoupdate.

    METHODS cal_api_calc_qty_at IMPORTING i_context TYPE string
                                EXPORTING tt_qty_at TYPE tt_qty_at.

    METHODS cal_confirm_lsx IMPORTING i_context                   TYPE string
                            EXPORTING
                                      tt_confirm_production_order TYPE tt_confirm_production_order
                                      tt_return                   TYPE tt_return.

    METHODS call_post_batch IMPORTING i_prefix  TYPE string
                                      i_context TYPE string
                            EXPORTING e_context TYPE string
                                      e_header  TYPE string
                                      e_return  TYPE ty_error.

    METHODS get_xcrsf_token IMPORTING i_prefix      TYPE string
                            EXPORTING xcrsf_token   TYPE string
                                      cookie        TYPE string
                            CHANGING  i_http_client TYPE REF TO if_web_http_client.

    METHODS date_millis IMPORTING iv_date        TYPE dats OPTIONAL
                                  iv_time        TYPE timn OPTIONAL
                        RETURNING VALUE(rv_date) TYPE string.

    METHODS time_iso IMPORTING iv_time        TYPE timn OPTIONAL
                     RETURNING VALUE(rv_time) TYPE string.
ENDCLASS.

CLASS lhc_datafile IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD postconfirm.


    DATA lt_map TYPE /ui2/cl_json=>name_mappings.
    DATA: ls_req_prodnordconf2 TYPE zst_request_prodnordconf2.

    READ TABLE keys INDEX 1 INTO DATA(k).

    lt_map = VALUE #(
      ( abap = 'ORDER_ID'                json = 'OrderID' )
      ( abap = 'SEQUENCE'                json = 'Sequence' )
      ( abap = 'ORDER_OPERATION'         json = 'OrderOperation' )
      ( abap = 'FINAL_CONFIRMATION_TYPE' json = 'FinalConfirmationType' )
      ( abap = 'WORK_CENTER'             json = 'WorkCenter' )
      ( abap = 'POSTING_DATE'            json = 'PostingDate' )
      ( abap = 'CONFIRMATION_YIELD_QTY'  json = 'ConfirmationYieldQuantity' )
      ( abap = 'YY1_QUANTITY_CFM'        json = 'YY1_Quantity_CFM' )
      ( abap = 'YY1_QUANTITY_CFMU'       json = 'YY1_Quantity_CFMU' )
      ( abap = 'VARIANCE_REASON_CODE'    json = 'VarianceReasonCode' )
      ( abap = 'CONFIRMATION_TEXT'       json = 'ConfirmationText' )
      ( abap = 'START_DATE'              json = 'ConfirmedExecutionStartDate' )
      ( abap = 'START_TIME'              json = 'ConfirmedExecutionStartTime' )
      ( abap = 'END_DATE'                json = 'ConfirmedExecutionEndDate' )
      ( abap = 'END_TIME'                json = 'ConfirmedExecutionEndTime' )
      ( abap = 'OP_WORK_UNIT1'           json = 'OpWorkQuantityUnit1' )
      ( abap = 'OP_CONF_WORK_QTY1'       json = 'OpConfirmedWorkQuantity1' )
      ( abap = 'OP_WORK_UNIT2'           json = 'OpWorkQuantityUnit2' )
      ( abap = 'OP_CONF_WORK_QTY2'       json = 'OpConfirmedWorkQuantity2' )
      ( abap = 'OP_WORK_UNIT3'           json = 'OpWorkQuantityUnit3' )
      ( abap = 'OP_CONF_WORK_QTY3'       json = 'OpConfirmedWorkQuantity3' )
      ( abap = 'OP_WORK_UNIT4'           json = 'OpWorkQuantityUnit4' )
      ( abap = 'OP_CONF_WORK_QTY4'       json = 'OpConfirmedWorkQuantity4' )
      ( abap = 'OP_WORK_UNIT5'           json = 'OpWorkQuantityUnit5' )
      ( abap = 'OP_CONF_WORK_QTY5'       json = 'OpConfirmedWorkQuantity5' )
      ( abap = 'OP_WORK_UNIT6'           json = 'OpWorkQuantityUnit6' )
      ( abap = 'OP_CONF_WORK_QTY6'       json = 'OpConfirmedWorkQuantity6' )
      ( abap = 'YY1_TOSANXUAT_CFM'       json = 'YY1_ToSanXuat_CFM' )
      ( abap = 'YY1_NHANCONG_CFM'        json = 'YY1_NhanCong_CFM' )
      ( abap = 'YY1_CASX_CFM'            json = 'YY1_CaSx_CFM' )
      ( abap = 'YY1_SOMAY_CFM'           json = 'YY1_SoMay_CFM' )
    ).

    DATA: lv_context TYPE string.
    DATA: lv_response TYPE string.
    DATA: lv_id TYPE int4.

    DATA(lv_batch_boundary)     = 'batch_123'.
    DATA(lv_changeset_boundary) = 'changeset_abc'.

    SELECT * FROM ziu_confirm_production_order
    WITH PRIVILEGED ACCESS

    WHERE messagetype NE 'S'
    AND uuid = @k-uuid
    INTO TABLE @DATA(lt_confirm_production_order) .
    IF sy-subrc NE 0.
      APPEND VALUE #(
            %msg = new_message(
                     id       = 'ZCO11N'                "message class của bạn
                     number   = '002'               "vd: 001 'Không tìm thấy tổ hợp {&1}/{&2}/{&3}/{&4}'
*                     V1       =
*                     V2       =
*                     V3       =
*                     V4       =
                     severity = if_abap_behv_message=>severity-error )
            " (optional) highlight các field
          ) TO reported-managefile.
    ENDIF.

    DATA: lt_keys TYPE TABLE FOR READ IMPORT ziu_confirm_production_order.

*    LOOP AT lt_confirm_production_order INTO DATA(ls_confirm_production_order).
*      APPEND VALUE #( uuid = ls_confirm_production_order-uuid ) TO lt_keys.
*    ENDLOOP.

    DATA: lv_optotalconfirmedyieldqty TYPE int4.

    LOOP AT lt_confirm_production_order INTO DATA(ls_confirm_production_order).

      lv_optotalconfirmedyieldqty = ls_confirm_production_order-optotalconfirmedyieldqty.

      lv_id = sy-tabix.
      IF lv_id = 1.
        lv_context = |--{ lv_changeset_boundary }{ lc_crlf }|
                     && |Content-Type: application/http{ lc_crlf }|
                     && |Content-Transfer-Encoding: binary{ lc_crlf }|
                     && |Content-ID: { lv_id }{ lc_crlf }{ lc_crlf }|
                     && |POST /sap/opu/odata/sap/API_PROD_ORDER_CONFIRMATION_2_SRV/GetConfProposal?|
                     && |OrderID='{ ls_confirm_production_order-manufacturingorder }'&OrderOperation='{ ls_confirm_production_order-manufacturingorderoperation }'&Sequence='0'|
                     && |&ConfirmationUnit='{ ls_confirm_production_order-confirmationunit }'&ConfirmationYieldQuantity={ lv_optotalconfirmedyieldqty }|
                     && |&ConfirmationScrapQuantity=0M&ConfirmationReworkQuantity=0M&$format=json HTTP/1.1{ lc_crlf }{ lc_crlf }|
                     && |Accept: application/json{ lc_crlf }|
                     && |Content-Type: application/json{ lc_crlf }|
                     && |Content-Length: 0{ lc_crlf }{ lc_crlf }|.
      ELSE.
        lv_context = lv_context && |--{ lv_changeset_boundary }{ lc_crlf }|
                   && |Content-Type: application/http{ lc_crlf }|
                   && |Content-Transfer-Encoding: binary{ lc_crlf }|
                   && |Content-ID: { lv_id }{ lc_crlf }{ lc_crlf }|
                   && |POST /sap/opu/odata/sap/API_PROD_ORDER_CONFIRMATION_2_SRV/GetConfProposal?|
                   && |OrderID='{ ls_confirm_production_order-manufacturingorder }'&OrderOperation='{ ls_confirm_production_order-manufacturingorderoperation }'&Sequence='0'|
                   && |&ConfirmationUnit='{ ls_confirm_production_order-confirmationunit }'&ConfirmationYieldQuantity={ lv_optotalconfirmedyieldqty }|
                   && |&ConfirmationScrapQuantity=0M&ConfirmationReworkQuantity=0M&$format=json HTTP/1.1{ lc_crlf }{ lc_crlf }|
                   && |Accept: application/json{ lc_crlf }|
                   && |Content-Type: application/json{ lc_crlf }|
                   && |Content-Length: 0{ lc_crlf }{ lc_crlf }|.
      ENDIF.

      CLEAR: lv_optotalconfirmedyieldqty.
    ENDLOOP.

    " -- 2.3) Gộp changeset
    DATA(lv_changeset) =
         |--{ lv_batch_boundary }{ lc_crlf }|
      && |Content-Type: multipart/mixed; boundary={ lv_changeset_boundary }{ lc_crlf }{ lc_crlf }|
      && lv_context
      && |--{ lv_changeset_boundary }--{ lc_crlf }|.

    " -- 2.4) Hoàn chỉnh batch body
    DATA(lv_body) = lv_changeset &&
                    |--{ lv_batch_boundary }--|. " lưu ý: phần cuối không thêm CRLF nữa cũng được

    "-- Call API tính AT.
    me->cal_api_calc_qty_at( EXPORTING i_context = lv_body  IMPORTING tt_qty_at = DATA(tt_qty_at)  ).

    SORT tt_qty_at BY  manufacturingorder manufacturingorderoperation ASCENDING.
    "--Call API confirm
*    ME->CALL_POST_BATCH( EXPORTING I_CONTEXT = LV_CONTEXT  IMPORTING E_CONTEXT = LV_RESPONSE ).

    LOOP AT lt_confirm_production_order ASSIGNING FIELD-SYMBOL(<fs_confirm_production_order>).
      lv_id = sy-tabix.

      CLEAR: lv_context, lv_changeset, lv_body.

      READ TABLE tt_qty_at INTO DATA(ls_qty_at) WITH KEY manufacturingorder = <fs_confirm_production_order>-manufacturingorder
                                                         manufacturingorderoperation = <fs_confirm_production_order>-manufacturingorderoperation BINARY SEARCH.

      IF sy-subrc EQ 0.
        <fs_confirm_production_order>-opconfirmedworkquantity1 = ls_qty_at-opconfirmedworkquantity1.
        <fs_confirm_production_order>-opconfirmedworkquantity2 = ls_qty_at-opconfirmedworkquantity2.
        <fs_confirm_production_order>-opconfirmedworkquantity3 = ls_qty_at-opconfirmedworkquantity3.
        <fs_confirm_production_order>-opconfirmedworkquantity4 = ls_qty_at-opconfirmedworkquantity4.
        <fs_confirm_production_order>-opconfirmedworkquantity5 = ls_qty_at-opconfirmedworkquantity5.
        <fs_confirm_production_order>-opconfirmedworkquantity6 = ls_qty_at-opconfirmedworkquantity6.
        <fs_confirm_production_order>-opworkquantityunit1      = ls_qty_at-opworkquantityunit1.
        <fs_confirm_production_order>-opworkquantityunit2      = ls_qty_at-opworkquantityunit2.
        <fs_confirm_production_order>-opworkquantityunit3      = ls_qty_at-opworkquantityunit3.
        <fs_confirm_production_order>-opworkquantityunit4      = ls_qty_at-opworkquantityunit4.
        <fs_confirm_production_order>-opworkquantityunit5      = ls_qty_at-opworkquantityunit5.
        <fs_confirm_production_order>-opworkquantityunit6      = ls_qty_at-opworkquantityunit6.

        CLEAR: ls_req_prodnordconf2.

        ls_req_prodnordconf2-order_id  = <fs_confirm_production_order>-manufacturingorder.
        ls_req_prodnordconf2-sequence                = '0'.
        ls_req_prodnordconf2-order_operation         = <fs_confirm_production_order>-manufacturingorderoperation.
        ls_req_prodnordconf2-final_confirmation_type = <fs_confirm_production_order>-finalconfirmationtype.
        ls_req_prodnordconf2-work_center             = <fs_confirm_production_order>-workcenter.

*  /Date(1758412800000)/
        ls_req_prodnordconf2-posting_date            = me->date_millis( iv_date = <fs_confirm_production_order>-postingdate ).

        lv_optotalconfirmedyieldqty                  = ls_confirm_production_order-optotalconfirmedyieldqty.
        ls_req_prodnordconf2-confirmation_yield_qty  = lv_optotalconfirmedyieldqty.
        CONDENSE ls_req_prodnordconf2-confirmation_yield_qty NO-GAPS.

        lv_optotalconfirmedyieldqty                  = ls_confirm_production_order-quantity.
        ls_req_prodnordconf2-yy1_quantity_cfm         = lv_optotalconfirmedyieldqty.

        ls_req_prodnordconf2-yy1_quantity_cfmu       = ls_confirm_production_order-baseunit.

        CONDENSE ls_req_prodnordconf2-yy1_quantity_cfm NO-GAPS.

        ls_req_prodnordconf2-variance_reason_code    = <fs_confirm_production_order>-variancereasoncode.
        ls_req_prodnordconf2-confirmation_text       = <fs_confirm_production_order>-confirmationtext.

        IF <fs_confirm_production_order>-confirmedexecutionstartdate IS NOT INITIAL AND <fs_confirm_production_order>-confirmedexecutionstarttime IS NOT INITIAL.
          ls_req_prodnordconf2-start_date = me->date_millis( iv_date = <fs_confirm_production_order>-confirmedexecutionstartdate
                                                             iv_time = <fs_confirm_production_order>-confirmedexecutionstarttime ).
        ENDIF.
*  PT09H51M04S
        IF <fs_confirm_production_order>-confirmedexecutionstarttime IS NOT INITIAL.
          ls_req_prodnordconf2-start_time              = me->time_iso( iv_time = <fs_confirm_production_order>-confirmedexecutionstarttime ).
        ENDIF.

        IF <fs_confirm_production_order>-confirmedexecutionenddate IS NOT INITIAL AND <fs_confirm_production_order>-confirmedexecutionendtime IS NOT INITIAL.
          ls_req_prodnordconf2-end_date = me->date_millis( iv_date = <fs_confirm_production_order>-confirmedexecutionenddate
                                                           iv_time = <fs_confirm_production_order>-confirmedexecutionendtime ).
        ENDIF.

        IF <fs_confirm_production_order>-confirmedexecutionendtime IS NOT INITIAL.
          ls_req_prodnordconf2-end_time                = me->time_iso( iv_time = <fs_confirm_production_order>-confirmedexecutionendtime ).
        ENDIF.

        ls_req_prodnordconf2-op_work_unit1           = <fs_confirm_production_order>-opworkquantityunit1.
        ls_req_prodnordconf2-op_conf_work_qty1       = <fs_confirm_production_order>-opconfirmedworkquantity1.
        CONDENSE ls_req_prodnordconf2-op_conf_work_qty1 NO-GAPS.

        ls_req_prodnordconf2-op_work_unit2           = <fs_confirm_production_order>-opworkquantityunit2.
        ls_req_prodnordconf2-op_conf_work_qty2       = <fs_confirm_production_order>-opconfirmedworkquantity2.
        CONDENSE ls_req_prodnordconf2-op_conf_work_qty2 NO-GAPS.

        ls_req_prodnordconf2-op_work_unit3           = <fs_confirm_production_order>-opworkquantityunit3.
        ls_req_prodnordconf2-op_conf_work_qty3       = <fs_confirm_production_order>-opconfirmedworkquantity3.
        CONDENSE ls_req_prodnordconf2-op_conf_work_qty3 NO-GAPS.

        ls_req_prodnordconf2-op_work_unit4           = <fs_confirm_production_order>-opworkquantityunit4.
        ls_req_prodnordconf2-op_conf_work_qty4       = <fs_confirm_production_order>-opconfirmedworkquantity4.
        CONDENSE ls_req_prodnordconf2-op_conf_work_qty4 NO-GAPS.

        ls_req_prodnordconf2-op_work_unit5           = <fs_confirm_production_order>-opworkquantityunit5.
        ls_req_prodnordconf2-op_conf_work_qty5       = <fs_confirm_production_order>-opconfirmedworkquantity5.
        CONDENSE ls_req_prodnordconf2-op_conf_work_qty5 NO-GAPS.

        ls_req_prodnordconf2-op_work_unit6           = <fs_confirm_production_order>-opworkquantityunit6.
        ls_req_prodnordconf2-op_conf_work_qty6       = <fs_confirm_production_order>-opconfirmedworkquantity6.
        CONDENSE ls_req_prodnordconf2-op_conf_work_qty6 NO-GAPS.

        ls_req_prodnordconf2-yy1_casx_cfm       = ls_confirm_production_order-shift.
        ls_req_prodnordconf2-yy1_nhancong_cfm   = ls_confirm_production_order-workerid.
        ls_req_prodnordconf2-yy1_somay_cfm      = ls_confirm_production_order-machineid.
        ls_req_prodnordconf2-yy1_tosanxuat_cfm  = ls_confirm_production_order-teamid.

**Process Json ***
        DATA(json) = /ui2/cl_json=>serialize(
          data          = ls_req_prodnordconf2
          name_mappings = lt_map ).

        lv_context = |--{ lv_changeset_boundary }{ lc_crlf }|
                     && |Content-Type: application/http{ lc_crlf }|
                     && |Content-Transfer-Encoding: binary{ lc_crlf }|
                     && |Content-ID: { lv_id }{ lc_crlf }{ lc_crlf }|
                     && |POST ProdnOrdConf2 HTTP/1.1{ lc_crlf }|
                     && |Accept: application/json{ lc_crlf }|
                     && |Content-Type: application/json{ lc_crlf }{ lc_crlf }|
                     && |{ json }{ lc_crlf }{ lc_crlf }|
                     .

        " -- 2.3) Gộp changeset
        lv_changeset =
             |--{ lv_batch_boundary }{ lc_crlf }|
          && |Content-Type: multipart/mixed; boundary={ lv_changeset_boundary }{ lc_crlf }{ lc_crlf }|
          && lv_context
          && |--{ lv_changeset_boundary }--{ lc_crlf }|.

        " -- 2.4) Hoàn chỉnh batch body
        lv_body = lv_changeset &&
                        |--{ lv_batch_boundary }--|. " lưu ý: phần cuối không thêm CRLF nữa cũng được


        "-- Call API Confirmation.
        me->cal_confirm_lsx( EXPORTING i_context                   = lv_body
                             IMPORTING tt_confirm_production_order = DATA(et_confirm_production_order)
                                       tt_return                   = DATA(et_return) ).

        READ TABLE et_confirm_production_order TRANSPORTING NO FIELDS INDEX 1.
        IF sy-subrc EQ 0.
*          <fs_confirm_production_order>-status        = 'S'.
          <fs_confirm_production_order>-messagetype   = file_status-success.
          <fs_confirm_production_order>-message       = 'Post Confirmation Successfull!'.
        ENDIF.

        READ TABLE et_return INDEX 1 INTO DATA(ls_return).
        IF sy-subrc EQ 0.
*          <fs_confirm_production_order>-status        = 'E'.
          <fs_confirm_production_order>-messagetype   = file_status-error.
          <fs_confirm_production_order>-message       = ls_return-msgtext.
        ENDIF.
        FREE: et_confirm_production_order, et_return.

      ENDIF.
    ENDLOOP.

    DATA: lt_head_upd TYPE TABLE FOR UPDATE zim_confirm_production_order.

    DATA: lt_update TYPE TABLE FOR UPDATE zim_confirm_production_order\\datafile.

    SORT et_confirm_production_order BY manufacturingorder manufacturingorderoperation ASCENDING.

    LOOP AT lt_confirm_production_order ASSIGNING <fs_confirm_production_order>.
      IF sy-tabix = 1.
        APPEND VALUE #(
            %key-uuid = <fs_confirm_production_order>-uuidfile
            " ví dụ: đổi Status
            status    = file_status-inprocess     "inprocess
        ) TO lt_head_upd.
      ENDIF.
*      READ TABLE ET_CONFIRM_PRODUCTION_ORDER TRANSPORTING NO FIELDS WITH KEY Manufacturingorder = <FS_CONFIRM_PRODUCTION_ORDER>-Manufacturingorder
*                                                                             Manufacturingorderoperation = <FS_CONFIRM_PRODUCTION_ORDER>-Manufacturingorderoperation BINARY SEARCH.
*      IF SY-SUBRC EQ 0.
*        <FS_CONFIRM_PRODUCTION_ORDER>-Status        = 'S'.
*        <FS_CONFIRM_PRODUCTION_ORDER>-MessageType   = 'S'.
*        <FS_CONFIRM_PRODUCTION_ORDER>-Message       = 'Post Confirmation Successfull!'.
*      ENDIF.

      APPEND VALUE #(
        %tky-uuid                   = <fs_confirm_production_order>-uuid
*        %CID_REF                    = K-%CID
*%is_draft
        uuid                        = <fs_confirm_production_order>-uuid
*        status                      = <fs_confirm_production_order>-status
        productionplant             = <fs_confirm_production_order>-productionplant
        postingdate                 = <fs_confirm_production_order>-postingdate
        manufacturingorder          = <fs_confirm_production_order>-manufacturingorder
        manufacturingorderoperation = <fs_confirm_production_order>-manufacturingorderoperation
        workcenter                  = <fs_confirm_production_order>-workcenter
        optotalconfirmedyieldqty    = <fs_confirm_production_order>-optotalconfirmedyieldqty
        finalconfirmationtype       = <fs_confirm_production_order>-finalconfirmationtype
        variancereasoncode          = <fs_confirm_production_order>-variancereasoncode
        confirmationtext            = <fs_confirm_production_order>-confirmationtext
        confirmedexecutionstartdate = <fs_confirm_production_order>-confirmedexecutionstartdate
        confirmedexecutionstarttime = <fs_confirm_production_order>-confirmedexecutionstarttime
        confirmedexecutionenddate   = <fs_confirm_production_order>-confirmedexecutionenddate
        confirmedexecutionendtime   = <fs_confirm_production_order>-confirmedexecutionendtime
        machineid                   = <fs_confirm_production_order>-machineid
        shift                       = <fs_confirm_production_order>-shift
        teamid                      = <fs_confirm_production_order>-teamid
        workerid                    = <fs_confirm_production_order>-workerid
        confirmationunit            = <fs_confirm_production_order>-confirmationunit
        opconfirmedworkquantity1    = <fs_confirm_production_order>-opconfirmedworkquantity1
        opconfirmedworkquantity2    = <fs_confirm_production_order>-opconfirmedworkquantity2
        opconfirmedworkquantity3    = <fs_confirm_production_order>-opconfirmedworkquantity3
        opconfirmedworkquantity4    = <fs_confirm_production_order>-opconfirmedworkquantity4
        opconfirmedworkquantity5    = <fs_confirm_production_order>-opconfirmedworkquantity5
        opconfirmedworkquantity6    = <fs_confirm_production_order>-opconfirmedworkquantity6
        opworkquantityunit1         = <fs_confirm_production_order>-opworkquantityunit1
        opworkquantityunit2         = <fs_confirm_production_order>-opworkquantityunit2
        opworkquantityunit3         = <fs_confirm_production_order>-opworkquantityunit3
        opworkquantityunit4         = <fs_confirm_production_order>-opworkquantityunit4
        opworkquantityunit5         = <fs_confirm_production_order>-opworkquantityunit5
        opworkquantityunit6         = <fs_confirm_production_order>-opworkquantityunit6
        messagetype                 = <fs_confirm_production_order>-messagetype
        message                     = <fs_confirm_production_order>-message
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF zim_confirm_production_order IN LOCAL MODE
      ENTITY managefile
      UPDATE FIELDS ( status )
        WITH lt_head_upd
      ENTITY datafile
      UPDATE FIELDS (
*          status
          workcenter
          confirmationunit
          opconfirmedworkquantity1
          opconfirmedworkquantity2
          opconfirmedworkquantity3
          opconfirmedworkquantity4
          opconfirmedworkquantity5
          opconfirmedworkquantity6
          opworkquantityunit1
          opworkquantityunit2
          opworkquantityunit3
          opworkquantityunit4
          opworkquantityunit5
          opworkquantityunit6
          messagetype
          message
      ) WITH lt_update
      MAPPED mapped
      REPORTED reported
      FAILED failed.

      IF mapped IS INITIAL.
        mapped-managefile = VALUE #(
            FOR ls IN lt_update (
            %tky-uuid = ls-uuid
            uuid      = ls-uuid
            )
        ).
      ENDIF.

      result = VALUE #(
        FOR ls IN lt_update
        ( %tky-uuid                          = ls-uuid
          uuid                               = ls-uuid

          %param-%tky-uuid                   = ls-uuid
          %param-uuid                        = ls-uuid
*          %param-status                      = ls-status
          %param-productionplant             = ls-productionplant
          %param-postingdate                 = ls-postingdate
          %param-manufacturingorder          = ls-manufacturingorder
          %param-manufacturingorderoperation = ls-manufacturingorderoperation
          %param-workcenter                  = ls-workcenter
          %param-optotalconfirmedyieldqty    = ls-optotalconfirmedyieldqty
          %param-finalconfirmationtype       = ls-finalconfirmationtype
          %param-variancereasoncode          = ls-variancereasoncode
          %param-confirmationtext            = ls-confirmationtext
          %param-confirmedexecutionstartdate = ls-confirmedexecutionstartdate
          %param-confirmedexecutionstarttime = ls-confirmedexecutionstarttime
          %param-confirmedexecutionenddate   = ls-confirmedexecutionenddate
          %param-confirmedexecutionendtime   = ls-confirmedexecutionendtime
          %param-machineid                   = ls-machineid
          %param-shift                       = ls-shift
          %param-teamid                      = ls-teamid
          %param-workerid                    = ls-workerid
          %param-confirmationunit            = ls-confirmationunit
          %param-opconfirmedworkquantity1    = ls-opconfirmedworkquantity1
          %param-opconfirmedworkquantity2    = ls-opconfirmedworkquantity2
          %param-opconfirmedworkquantity3    = ls-opconfirmedworkquantity3
          %param-opconfirmedworkquantity4    = ls-opconfirmedworkquantity4
          %param-opconfirmedworkquantity5    = ls-opconfirmedworkquantity5
          %param-opconfirmedworkquantity6    = ls-opconfirmedworkquantity6
          %param-opworkquantityunit1         = ls-opworkquantityunit1
          %param-opworkquantityunit2         = ls-opworkquantityunit2
          %param-opworkquantityunit3         = ls-opworkquantityunit3
          %param-opworkquantityunit4         = ls-opworkquantityunit4
          %param-opworkquantityunit5         = ls-opworkquantityunit5
          %param-opworkquantityunit6         = ls-opworkquantityunit6
          %param-messagetype                 = ls-messagetype
          %param-message                     = ls-message
        )
      ).

    ENDIF.


*    /UI2/CL_JSON=>DESERIALIZE(
*      EXPORTING
*        JSON        = LV_RESPONSE
**       jsonx       =
*        PRETTY_NAME = /UI2/CL_JSON=>PRETTY_MODE-NONE
**       assoc_arrays     =
**       assoc_arrays_opt =
**       name_mappings    =
**       conversion_exits =
**       hex_as_base64    =
*      CHANGING
*        DATA        = LS_RESP_DATA
*    ).


  ENDMETHOD.

  METHOD call_post_batch.

    DATA: lv_url   TYPE string, " Replace with actual URL
          lv_query TYPE string,
          lv_pref  TYPE string,
          i_xml    TYPE string.
*          lv_uuid TYPE string VALUE `urn:uuid:{{$randomUUID}}`.
    TRY.
        DATA(lv_host) = cl_abap_context_info=>get_system_url( ).
        SPLIT lv_host AT '.' INTO lv_host lv_pref.
        CONCATENATE lv_host `-api` `.` lv_pref INTO lv_host.
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    SELECT SINGLE * FROM ztb_api_auth
    WITH PRIVILEGED ACCESS
    WHERE systemid = 'CASLA'
    INTO @DATA(ls_api_auth).

    IF sy-subrc EQ 0.
      c_username = ls_api_auth-api_user.
      c_password = ls_api_auth-api_password.
    ENDIF.

    "'https://my426501-api.s4hana.cloud.sap:443/sap/opu/odata/sap/API_PRODUCTION_ORDER_2_SRV/$batch'
    lv_url = |https://{ lv_host }|.

    TRY.
        "create http destination by url; API endpoint for API sandbox
        DATA(lo_http_destination) =
          cl_http_destination_provider=>create_by_url( lv_url ).

        "alternatively create HTTP destination via destination service
        "cl_http_destination_provider=>create_by_cloud_destination( i_name = '<...>'
        "                            i_service_instance_name = '<...>' )
        "SAP Help: https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/f871712b816943b0ab5e04b60799e518.html

        "create HTTP client by destination
        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

*-- Get x-csrf-token
        me->get_xcrsf_token(
          EXPORTING
            i_prefix      = i_prefix
          IMPORTING
            xcrsf_token   = DATA(lv_token)
            cookie        = DATA(lv_cookie)
          CHANGING
            i_http_client = lo_web_http_client
        ).

*        LO_WEB_HTTP_CLIENT = CL_WEB_HTTP_CLIENT_MANAGER=>CREATE_BY_HTTP_DESTINATION( LO_HTTP_DESTINATION ) .

        "adding headers
        DATA(lo_request) = lo_web_http_client->get_http_request( ).

        lo_request->set_uri_path( |{ i_prefix }/$batch| ).

        lo_request->set_header_fields( VALUE #(
        ( name = 'config_authType'    value = 'Basic' )
        ( name = 'config_packageName' value = 'SAPS4HANACloud' )
*        ( NAME = 'config_actualUrl'   VALUE = |https://{ LV_HOST }{ C_APINAME }| )
*        ( NAME = 'config_urlPattern'  VALUE = 'https://{host}:{port}' && C_APINAME )
*        ( NAME = 'config_apiName'     VALUE = 'API_PRODUCTION_ORDER_2_SRV' )
        ( name = 'Content-Type'       value = 'multipart/mixed;boundary=batch_123' )
        ( name = 'DataServiceVersion' value = '2.0' )
        ( name = 'Accept'             value = '*/*' )
        ( name = 'x-csrf-token'       value = 'fetch' )
        ) ).

*-- Passing the Accept value in header which is a mandatory field
        lo_request->set_header_field( i_name = |username| i_value = c_username ).
        lo_request->set_header_field( i_name = |password| i_value = c_password ).

*-- Authorization
        lo_request->set_authorization_basic( i_username = c_username i_password = c_password ).
*        LO_REQUEST->SET_CONTENT_TYPE( |text/xml;charset=UTF-8| ).

        lo_request->set_version( version = if_web_http_request=>co_protocol_version_1_1 ).

        IF lv_token IS NOT INITIAL.
*-- Set x-csrf-toke // set cookie
          lo_request->set_header_field( i_name = 'x-csrf-token'  i_value = lv_token ).

          "Quan trọng: gửi lại cookie của response GET
          IF lv_cookie IS NOT INITIAL.
            lo_request->set_header_field( i_name = 'set-cookie' i_value = lv_cookie ).
          ENDIF.

*-- Send Request
          lo_request->set_text( i_context ).

          "set request method and execute request
          DATA(lo_response) = lo_web_http_client->execute( if_web_http_client=>post ).

          DATA(lv_response) = lo_response->get_text( ).

          "Get header Content-type
          e_header = lo_response->get_header_field( 'Content-Type' ).

          IF lo_response->get_status( )-code NE 200.
            e_return-msgtype = 'E'.
            e_return-msgtext = lo_response->get_status( )-code && ` ` && lo_response->get_status( )-reason
            && ` - ` && e_context.
          ENDIF.

        ENDIF.
      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
        "error handling
    ENDTRY.

    e_context = lv_response.
    "uncomment the following line for console output; prerequisite: code snippet is implementation of if_oo_adt_classrun~main
    "out->write( |response:  { lv_response }| ).
  ENDMETHOD.

  METHOD cal_api_calc_qty_at.

    DATA: ls_response TYPE string,
          lt_string   TYPE TABLE OF string.

    DATA: ls_resp_getconfproposal TYPE zst_resp_getconfproposal,
          lt_qty_at               TYPE tt_qty_at,
          ls_qty_at               LIKE LINE OF lt_qty_at.

    me->call_post_batch(
      EXPORTING
        i_prefix  = '/sap/opu/odata/sap/API_PROD_ORDER_CONFIRMATION_2_SRV'
        i_context = i_context
      IMPORTING
        e_context = ls_response
    ).

    SPLIT ls_response AT lc_crlf INTO TABLE lt_string.

    LOOP AT lt_string INTO DATA(lv_string).
      CLEAR: ls_resp_getconfproposal.

      /ui2/cl_json=>deserialize(
        EXPORTING
          json        = lv_string
*         jsonx       =
          pretty_name = /ui2/cl_json=>pretty_mode-none
*         assoc_arrays     =
*         assoc_arrays_opt =
*         name_mappings    =
*         conversion_exits =
*         hex_as_base64    =
        CHANGING
          data        = ls_resp_getconfproposal
      ).

      IF ls_resp_getconfproposal IS NOT INITIAL.
        ls_qty_at-manufacturingorder          = |{ ls_resp_getconfproposal-d-getconfproposal-orderid ALPHA = IN WIDTH = 12 }|.
        ls_qty_at-manufacturingorderoperation = ls_resp_getconfproposal-d-getconfproposal-orderoperation.
        ls_qty_at-opconfirmedworkquantity1    = ls_resp_getconfproposal-d-getconfproposal-opconfirmedworkquantity1.
        ls_qty_at-opconfirmedworkquantity2    = ls_resp_getconfproposal-d-getconfproposal-opconfirmedworkquantity2.
        ls_qty_at-opconfirmedworkquantity3    = ls_resp_getconfproposal-d-getconfproposal-opconfirmedworkquantity3.
        ls_qty_at-opconfirmedworkquantity4    = ls_resp_getconfproposal-d-getconfproposal-opconfirmedworkquantity4.
        ls_qty_at-opconfirmedworkquantity5    = ls_resp_getconfproposal-d-getconfproposal-opconfirmedworkquantity5.
        ls_qty_at-opconfirmedworkquantity6    = ls_resp_getconfproposal-d-getconfproposal-opconfirmedworkquantity6.
        ls_qty_at-opworkquantityunit1         = ls_resp_getconfproposal-d-getconfproposal-opworkquantityunit1.
        ls_qty_at-opworkquantityunit2         = ls_resp_getconfproposal-d-getconfproposal-opworkquantityunit2.
        ls_qty_at-opworkquantityunit3         = ls_resp_getconfproposal-d-getconfproposal-opworkquantityunit3.
        ls_qty_at-opworkquantityunit4         = ls_resp_getconfproposal-d-getconfproposal-opworkquantityunit4.
        ls_qty_at-opworkquantityunit5         = ls_resp_getconfproposal-d-getconfproposal-opworkquantityunit5.
        ls_qty_at-opworkquantityunit6         = ls_resp_getconfproposal-d-getconfproposal-opworkquantityunit6.

        APPEND ls_qty_at TO lt_qty_at.
        CLEAR: ls_qty_at.
      ENDIF.
    ENDLOOP.

    tt_qty_at = lt_qty_at.
  ENDMETHOD.

  METHOD cal_confirm_lsx.

    DATA: ls_response TYPE string,
          lt_string   TYPE TABLE OF string.

    DATA: ls_resp_confirm_lsx TYPE zst_resp_confirm_lsx,
          ls_error            TYPE zst_error_confirm_lsx.

    DATA: ls_confirm_production_order LIKE LINE OF tt_confirm_production_order.

    me->call_post_batch(
      EXPORTING
        i_prefix  = '/sap/opu/odata/sap/API_PROD_ORDER_CONFIRMATION_2_SRV'
        i_context = i_context
      IMPORTING
        e_context = ls_response
    ).

    SPLIT ls_response AT lc_crlf INTO TABLE lt_string.

    LOOP AT lt_string INTO DATA(lv_string).
      CLEAR: ls_resp_confirm_lsx.

      /ui2/cl_json=>deserialize(
        EXPORTING
          json        = lv_string
*         jsonx       =
          pretty_name = /ui2/cl_json=>pretty_mode-none
*         assoc_arrays     =
*         assoc_arrays_opt =
*         name_mappings    =
*         conversion_exits =
*         hex_as_base64    =
        CHANGING
          data        = ls_resp_confirm_lsx
      ).

      IF ls_resp_confirm_lsx IS NOT INITIAL.
        MOVE-CORRESPONDING ls_resp_confirm_lsx-d TO ls_confirm_production_order.
        ls_confirm_production_order-manufacturingorder = ls_resp_confirm_lsx-d-orderid.
        ls_confirm_production_order-manufacturingorderoperation = ls_resp_confirm_lsx-d-orderoperation.

        APPEND ls_confirm_production_order TO tt_confirm_production_order.
        CLEAR: ls_confirm_production_order.

      ELSE.
        /ui2/cl_json=>deserialize(
          EXPORTING
            json        = lv_string
*           jsonx       =
            pretty_name = /ui2/cl_json=>pretty_mode-none
*           assoc_arrays     =
*           assoc_arrays_opt =
*           name_mappings    =
*           conversion_exits =
*           hex_as_base64    =
          CHANGING
            data        = ls_error
        ).

        IF ls_error IS NOT INITIAL.

          APPEND VALUE #( msgtype = 'E' msgtext = ls_error-error-message-value ) TO tt_return.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_xcrsf_token.

    DATA: lv_url  TYPE string,
          lv_pref TYPE string. "Get Token
    "Get x-csrf-token
    TRY.
        DATA(lv_host) = cl_abap_context_info=>get_system_url( ).
        SPLIT lv_host AT '.' INTO lv_host lv_pref.
        CONCATENATE lv_host `-api` `.` lv_pref INTO lv_host.
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    "'https://my426501-api.s4hana.cloud.sap:443/sap/opu/odata/sap/API_PRODUCTION_ORDER_2_SRV/A_ProductionOrder_2?$inlinecount=allpages&$top=50'
*    LV_URL = |https://{ LV_HOST }{ C_APINAME }{ I_PREFIX }|.

    SELECT SINGLE * FROM ztb_api_auth
    WITH PRIVILEGED ACCESS
    WHERE systemid = 'CASLA'
    INTO @DATA(ls_api_auth).

    IF sy-subrc EQ 0.
      c_username = ls_api_auth-api_user.
      c_password = ls_api_auth-api_password.
    ENDIF.

    TRY.
        "create http destination by url; API endpoint for API sandbox
*        DATA(LO_HTTP_DESTINATION) =
*          CL_HTTP_DESTINATION_PROVIDER=>CREATE_BY_URL( LV_URL ).

        "alternatively create HTTP destination via destination service
        "cl_http_destination_provider=>create_by_cloud_destination( i_name = '<...>'
        "                            i_service_instance_name = '<...>' )
        "SAP Help: https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/f871712b816943b0ab5e04b60799e518.html

        "create HTTP client by destination
*        DATA(LO_WEB_HTTP_CLIENT) = CL_WEB_HTTP_CLIENT_MANAGER=>CREATE_BY_HTTP_DESTINATION( LO_HTTP_DESTINATION ) .

        "adding headers
        DATA(lo_response) = i_http_client->get_http_request( ).
        lo_response->set_uri_path( i_prefix ).
*
        lo_response->set_header_fields( VALUE #(
        ( name = 'config_authType'    value = 'Basic' )
        ( name = 'config_packageName' value = 'SAPS4HANACloud' )
        ( name = 'config_actualUrl'   value = |https://{ lv_host }{ c_apiname }| )
        ( name = 'config_urlPattern'  value = 'https://{host}:{port}' && c_apiname )
        ( name = 'config_apiName'     value = 'API_PRODUCTION_ORDER_2_SRV' )
        ( name = 'x-csrf-token'       value = 'fetch' )
        ( name = 'DataServiceVersion' value = '2.0' )
        ( name = 'Accept'             value = 'application/json' )
        ) ).

*-- Passing the Accept value in header which is a mandatory field
        lo_response->set_header_field( i_name = |username| i_value = c_username ).
        lo_response->set_header_field( i_name = |password| i_value = c_password ).

*-- Authorization
        lo_response->set_authorization_basic( i_username = c_username i_password = c_password ).
        lo_response->set_content_type( |text/xml;charset=UTF-8| ).

        lo_response->set_version( version = if_web_http_request=>co_protocol_version_1_1 ).

        "set request method and execute request
        DATA(lo_web_http_response) = i_http_client->execute( if_web_http_client=>get ).
        DATA(lv_response) = lo_web_http_response->get_text( ).

        xcrsf_token = lo_web_http_response->get_header_field( i_name = 'x-csrf-token' ).
        cookie = lo_web_http_response->get_header_field( i_name = 'set-cookie' ).

*        I_HTTP_CLIENT->CLOSE( ).
*        FREE: I_HTTP_CLIENT.

      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
        "error handling
    ENDTRY.

  ENDMETHOD.

  METHOD date_millis.
    DATA: date_1970        TYPE zde_dats VALUE '19700101',
          millis_in_day    TYPE zde_numc15 VALUE '86400000',
          millis_in_hour   TYPE zde_numc15 VALUE '3600000',
          millis_in_min    TYPE zde_numc15 VALUE '60000',
          millis_in_sec    TYPE zde_numc15 VALUE '1000',
          current_date     TYPE zde_dats,
          current_ts       TYPE timestampl,
          current_ts_s(22),
          sec_fraction     TYPE f.

    DATA: lv_millis TYPE zde_numc15,
          lv_time   TYPE timn.

*  GET TIME STAMP FIELD current_ts.
    TRY.
        DATA(lv_tzone) = cl_abap_context_info=>get_user_time_zone( ).
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    IF iv_time = '240000'.
      lv_time = '000000'.
    ELSE.
      lv_time = iv_time.
    ENDIF.

    CONVERT DATE iv_date TIME lv_time DAYLIGHT SAVING TIME 'X'
            INTO TIME STAMP DATA(time_stamp) TIME ZONE lv_tzone.

    current_ts = time_stamp.

    current_ts_s = current_ts.
    current_date = current_ts_s(8).
    sec_fraction = current_ts_s+14(8).

    lv_millis = ( current_date - date_1970 ) * millis_in_day +
    current_ts_s+8(2) * millis_in_hour +
    current_ts_s+10(2) * millis_in_min +
    current_ts_s+12(2) * millis_in_sec +
    sec_fraction * millis_in_sec.

    rv_date = |/Date({ lv_millis })/|.
  ENDMETHOD.

  METHOD time_iso.
    DATA: lv_time TYPE timn.
    IF iv_time = '240000'.
      lv_time = '000000'.
    ELSE.
      lv_time = iv_time.
    ENDIF.
    rv_time = |PT{ lv_time+0(2) }H{ lv_time+2(2) }M{ lv_time+4(2) }S|.
  ENDMETHOD.

  METHOD setstatustoupdate.
    READ TABLE keys INDEX 1 INTO DATA(k).

    READ ENTITIES OF zim_confirm_production_order IN LOCAL MODE
    ENTITY datafile BY \_managefile
    FIELDS ( uuid )                               "chỉ cần lấy key parent
    WITH CORRESPONDING #( keys )
    RESULT DATA(parents).

    IF parents IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE parents INDEX 1 INTO DATA(wa_parent).

    "Lấy danh sách parent duy nhất
    READ ENTITIES OF zim_confirm_production_order IN LOCAL MODE
    ENTITY managefile BY \_datafile
    ALL FIELDS WITH VALUE #( ( %tky = wa_parent-%tky ) )
    RESULT DATA(childs).

    "--- (tuỳ chọn) kiểm tra all reserved và set DONE ---
    DATA(all_have) = abap_true.
    LOOP AT childs ASSIGNING FIELD-SYMBOL(<c>).
      IF <c>-messagetype NE file_status-success.
        all_have = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF all_have = abap_true.
      MODIFY ENTITIES OF zim_confirm_production_order IN LOCAL MODE
        ENTITY managefile
        UPDATE FIELDS ( status )
        WITH VALUE #( ( %tky = wa_parent-%tky status = file_status-completed ) )
        FAILED DATA(ls_failed) REPORTED DATA(ls_reported).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

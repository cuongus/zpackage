CLASS zcl_einvoice_process DEFINITION
  PUBLIC
*  INHERITING FROM zcl_einvoice_data
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:

      BEGIN OF ty_range_option,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE string,
        high   TYPE string,
      END OF ty_range_option,

      tt_ranges  TYPE TABLE OF ty_range_option,

      tt_returns TYPE TABLE OF bapiret2,

      BEGIN OF ty_message,
        companycode        TYPE bukrs,
        accountingdocument TYPE belnr_d,
        fiscalyear         TYPE gjahr,
        billingdocument    TYPE zde_vbeln_vf,
        msgtype            TYPE sy-msgty,
        msgtext            TYPE string,
      END OF ty_message,

      BEGIN OF ty_param,
        accountingdocumentsource TYPE belnr_d,
        fiscalyearsource         TYPE gjahr,
        adjusttype               TYPE zde_adjusttype,
      END OF ty_param,

      tt_message            TYPE TABLE OF ty_message,

      wa_document           TYPE zjp_c_hddt_h,

**--Database
      wa_items              TYPE zjp_c_hddt_i,
      wa_hd_userpass        TYPE zjp_hd_userpass,
      wa_hd_serial          TYPE zjp_hd_serial,

      wa_param              TYPE ty_param,

      tt_headers            TYPE TABLE OF zjp_c_hddt_h,
      tt_items              TYPE TABLE OF zjp_c_hddt_i,

**--Behavior Variables

      "Action Read
      tt_header_read        TYPE TABLE FOR READ IMPORT zjp_c_hddt_h\\hddt_headers,
      tt_result_readh       TYPE TABLE FOR READ RESULT zjp_c_hddt_h\\hddt_headers,

      tt_items_read         TYPE TABLE FOR READ IMPORT zjp_c_hddt_h\\hddt_items,
      tt_result_readi       TYPE TABLE FOR READ RESULT zjp_c_hddt_h\\hddt_items,

      "Action Integration
      tt_header_integration TYPE TABLE FOR ACTION IMPORT zjp_c_hddt_h\\hddt_headers~integration,
      tt_result_integration TYPE TABLE FOR ACTION RESULT zjp_c_hddt_h\\hddt_headers~integration,

      "Action Search
      tt_search             TYPE TABLE FOR ACTION IMPORT zjp_c_hddt_h\\hddt_headers~search,
      tt_search_result      TYPE TABLE FOR ACTION RESULT zjp_c_hddt_h\\hddt_headers~search,

      "Action Adjust
      tt_adjust             TYPE TABLE FOR ACTION IMPORT zjp_c_hddt_h\\hddt_headers~adjust,
      tt_adjust_result      TYPE TABLE FOR ACTION RESULT zjp_c_hddt_h\\hddt_headers~adjust,

      "Mapping
      tt_mapping            TYPE TABLE FOR ACTION IMPORT zjp_c_hddt_h\\hddt_headers~mapping,
      tt_mapping_result     TYPE TABLE FOR ACTION RESULT zjp_c_hddt_h\\hddt_headers~mapping,

      "Common
      tt_mapped_early       TYPE RESPONSE FOR MAPPED EARLY zjp_c_hddt_h,
      tt_failed_early       TYPE RESPONSE FOR FAILED EARLY zjp_c_hddt_h,
      tt_reported_early     TYPE RESPONSE FOR REPORTED EARLY zjp_c_hddt_h,
      tt_reported_late      TYPE RESPONSE FOR REPORTED LATE zjp_c_hddt_h,

      tt_preview            TYPE TABLE FOR ACTION IMPORT zjp_c_hddt_h\\hddt_headers~previewdraft,
      tt_preview_result     TYPE TABLE FOR ACTION RESULT zjp_c_hddt_h\\hddt_headers~previewdraft,

      tt_getjson            TYPE TABLE FOR ACTION IMPORT zjp_c_hddt_h\\hddt_headers~getjson, "[ derived type... ]
      tt_getjson_result     TYPE TABLE FOR ACTION RESULT zjp_c_hddt_h\\hddt_headers~getjson "[ derived type... ]
      .



    .

    CLASS-DATA:
      go_einvoice_process   TYPE REF TO zcl_einvoice_process,

      gv_action             TYPE zde_action_invoice,

      gs_document           TYPE wa_document,
      gs_userpass           TYPE wa_hd_userpass,
      gs_formserial         TYPE wa_hd_serial,
      gs_status             TYPE wa_document,
      gs_docsrc             TYPE wa_document,

      gs_json               TYPE string,
      gs_return             TYPE bapiret2,
      gv_testrun            TYPE abap_boolean,

      ir_companycode        TYPE tt_ranges,
      ir_accountingdocument TYPE tt_ranges,
      ir_fiscalyear         TYPE tt_ranges,

      ir_currencytype       TYPE tt_ranges,
      ir_einvoicetype       TYPE tt_ranges,
      ir_usertype           TYPE tt_ranges,
      ir_typeofdate         TYPE tt_ranges,

      ir_testrun            TYPE tt_ranges,

      gt_headers            TYPE TABLE OF wa_document,
      gt_items              TYPE tt_items,

      gt_adjust_doc         TYPE TABLE OF wa_document.

    CLASS-DATA:
      go_viettel_sinvoice TYPE REF TO zcl_manage_viettel_einvoices,
      go_einvoice_data    TYPE REF TO zcl_einvoice_data.

    METHODS constructor .

    CLASS-METHODS get_instance
      RETURNING VALUE(ro) TYPE REF TO zcl_einvoice_process.

    CLASS-METHODS:

      clear_variables ,

      get_keys      IMPORTING keys                  TYPE ANY TABLE
                    EXPORTING ir_companycode        TYPE tt_ranges
                              ir_accountingdocument TYPE tt_ranges
                              ir_fiscalyear         TYPE tt_ranges

                              ir_currencytype       TYPE tt_ranges
                              ir_einvoicetype       TYPE tt_ranges
                              ir_usertype           TYPE tt_ranges
                              ir_typeofdate         TYPE tt_ranges

                              ir_testrun            TYPE tt_ranges,

      get_password IMPORTING i_document   TYPE wa_document
                   EXPORTING e_document   TYPE wa_document
                             e_userpass   TYPE wa_hd_userpass
                             e_formserial TYPE wa_hd_serial
                             e_return     TYPE bapiret2
                   RAISING
                             cx_abap_context_info_error,

      move_log          IMPORTING i_input  TYPE wa_document
                        EXPORTING o_output TYPE wa_document
                        CHANGING  c_items  TYPE tt_items,

      process_integration_einvoice IMPORTING i_document            TYPE wa_document OPTIONAL
                                             i_action              TYPE zde_action_invoice OPTIONAL
                                             i_param               TYPE wa_param OPTIONAL
                                             ir_companycode        TYPE tt_ranges OPTIONAL
                                             ir_accountingdocument TYPE tt_ranges OPTIONAL
                                             ir_fiscalyear         TYPE tt_ranges OPTIONAL

                                             ir_currencytype       TYPE tt_ranges
                                             ir_einvoicetype       TYPE tt_ranges
                                             ir_usertype           TYPE tt_ranges
                                             ir_typeofdate         TYPE tt_ranges
                                             ir_testrun            TYPE tt_ranges OPTIONAL

                                   EXPORTING e_headers             TYPE tt_headers
                                             e_items               TYPE tt_items
                                             e_docsrc              TYPE tt_headers
                                             e_return              TYPE tt_message
                                   RAISING
                                             cx_abap_context_info_error,

      check_adjust_document IMPORTING i_document TYPE wa_document
                            EXPORTING e_return   TYPE bapiret2,

      read_header IMPORTING keys     TYPE tt_header_read "table for read import zcs_rap_einv_entry\\hddt_headers
                  CHANGING  result   TYPE tt_result_readh "table for read result zcs_rap_einv_entry\\hddt_headers
                            failed   TYPE tt_failed_early "response for failed early zi_rap_einv_header
                            reported TYPE tt_reported_early, "response for reported early zi_rap_einv_header

      read_items IMPORTING keys     TYPE tt_items_read "table for read import zcs_rap_einv_entry\\hddt_items
                 CHANGING  result   TYPE tt_result_readi "table for read result zcs_rap_einv_entry\\hddt_items
                           failed   TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
                           reported TYPE tt_reported_early, "response for reported early zcs_rap_einv_entry

      "Action Integration EInvoices
      handle_integration_einvoice
        IMPORTING keys     TYPE tt_header_integration "table for action import zcs_rap_einv_entry\\hddt_headers~inteeinv
        CHANGING  result   TYPE tt_result_integration "table for action result zcs_rap_einv_entry\\hddt_headers~inteeinv
                  mapped   TYPE tt_mapped_early "response for mapped early zcs_rap_einv_entry
                  failed   TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
                  reported TYPE tt_reported_early "response for reported early zcs_rap_einv_entry
                  e_return TYPE tt_message
        RAISING
                  cx_abap_context_info_error, "Return message error

      "Action Search EInvoices
      handle_search_einvoice IMPORTING keys     TYPE tt_search "table for action import zcs_rap_einv_entry\\hddt_headers~updatesteinv
                                       o_hddt_h TYPE REF TO zbp_jp_c_hddt_h OPTIONAL
                             CHANGING  result   TYPE tt_search_result "table for action result zcs_rap_einv_entry\\hddt_headers~updatesteinv
                                       mapped   TYPE tt_mapped_early "response for mapped early zcs_rap_einv_entry
                                       failed   TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
                                       reported TYPE tt_reported_early "response for reported early zcs_rap_einv_entry
                                       e_return TYPE tt_message, "Return message error


      "Action Adjust EInvoices
      handle_adjust_einvoice_v2 IMPORTING keys     TYPE tt_adjust "table for action import zcs_rap_einv_entry\\einvoicesheader~adjusteinv
                                CHANGING  result   TYPE tt_adjust_result "table for action result zcs_rap_einv_entry\\einvoicesheader~adjusteinv
                                          mapped   TYPE tt_mapped_early "response for mapped early zcs_rap_einv_entry
                                          failed   TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
                                          reported TYPE tt_reported_early "response for reported early zcs_rap_einv_entry
                                          e_return TYPE tt_message
                                RAISING
                                          cx_abap_context_info_error, "Return message error

      "Common Methods
      save_einvoice
        CHANGING reported TYPE tt_reported_late "response for reported late zcs_rap_einv_entry
        ,

      "Action Mapping EInvoices
      handle_mapping_einvoice IMPORTING keys     TYPE tt_mapping "table for action import zcs_rap_einv_entry\\einvoicesheader~mapping
                              CHANGING  result   TYPE tt_mapping_result "table for action result zcs_rap_einv_entry\\einvoicesheader~mapping
                                        mapped   TYPE tt_mapped_early "response for mapped early zcs_rap_einv_entry
                                        failed   TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
                                        reported TYPE tt_reported_early "response for reported early zcs_rap_einv_entry
                                        e_return TYPE tt_message,

      cleanup,
      cleanup_finalize,

      handle_preview_draft IMPORTING keys     TYPE tt_preview "table for action import zjp_c_hddt_h\\hddt_headers~previewdraft    [ derived type... ]
                           CHANGING  result   TYPE tt_preview_result "table for action result zjp_c_hddt_h\\hddt_headers~previewdraft    [ derived type... ]
                                     mapped   TYPE tt_mapped_early "response for mapped early zjp_c_hddt_h [ derived type... ]
                                     failed   TYPE tt_failed_early "response for failed early zjp_c_hddt_h [ derived type... ]
                                     reported TYPE tt_reported_early "response for reported early zjp_c_hddt_h   [ derived type... ]
                                     e_return TYPE tt_message,

      handle_get_json IMPORTING keys     TYPE tt_getjson "table for action import zjp_c_hddt_h\\hddt_headers~getjson [ derived type... ]
                      CHANGING  result   TYPE tt_getjson_result "table for action result zjp_c_hddt_h\\hddt_headers~getjson [ derived type... ]
                                mapped   TYPE tt_mapped_early "response for mapped early zjp_c_hddt_h [ derived type... ]
                                failed   TYPE tt_failed_early "response for failed early zjp_c_hddt_h [ derived type... ]
                                reported TYPE tt_reported_early "response for reported early zjp_c_hddt_h   [ derived type... ]
                                e_return TYPE tt_message
                      .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EINVOICE_PROCESS IMPLEMENTATION.


  METHOD check_adjust_document.
    DATA: lv_count TYPE int4.

    IF i_document-accountingdocumentsource IS NOT INITIAL AND i_document-fiscalyearsource IS NOT INITIAL AND i_document-adjusttype IS NOT INITIAL.

**--Check Không điều chỉnh/thay thế chứng từ khác Customer
      SELECT SINGLE * FROM zjp_a_hddt_h
      WHERE companycode      = @i_document-companycode
      AND accountingdocument = @i_document-accountingdocumentsource
      AND fiscalyear         = @i_document-fiscalyearsource
      INTO @DATA(ls_check).
      IF sy-subrc EQ 0.
        IF ls_check-customer NE i_document-customer.
          e_return-type     = 'E'.
          e_return-message  = TEXT-008.
        ENDIF.

      ENDIF.

**--Check Trạng thái chứng từ &1 - &2 không hợp lệ
      lv_count = 0.
      SELECT COUNT( 1 )
      FROM zjp_a_hddt_h
      WHERE companycode      = @i_document-companycode
      AND accountingdocument = @i_document-accountingdocumentsource
      AND fiscalyear         = @i_document-fiscalyearsource
      AND statussap IN ('98','99','06','10')
      INTO @lv_count.
      IF lv_count = 0.
        e_return-type    = 'E'.
        e_return-message = TEXT-003.
        e_return-message = replace( val  = TEXT-003
                                    sub  = '&1'
                                    with = i_document-accountingdocumentsource
                                    ).
        e_return-message = replace( val  = TEXT-003
                                    sub  = '&2'
                                    with = i_document-fiscalyearsource
                                    ).
      ELSE.

        lv_count = 0.
**--Trường hợp thay thế chứng từ --> Check Hủy chứng từ &1 - &2 trước khi thay thế
        IF i_document-adjusttype = '3'.
          SELECT COUNT( 1 )
          FROM i_journalentry
          WHERE companycode         = @i_document-companycode
            AND accountingdocument  = @i_document-accountingdocumentsource
            AND fiscalyear          = @i_document-fiscalyearsource
            AND reversedocument NE ''
            INTO @lv_count.
          IF lv_count = 0.
            e_return-type = 'E'.
            e_return-message = replace( val  = TEXT-007
                                        sub  = '&1'
                                        with = i_document-accountingdocumentsource
                                        ).

            e_return-message = replace( val  = TEXT-007
                                        sub  = '&2'
                                        with = i_document-fiscalyearsource
                                        ).
          ELSE.
            SELECT COUNT( 1 )
            FROM i_billingdocument
            WHERE billingdocument = @i_document-billingdocument
            AND billingdocumentiscancelled NE ''
            INTO @lv_count.
            IF lv_count = 0.
              e_return-type = 'E'.
              e_return-message = replace( val  = TEXT-007
                                          sub  = '&1'
                                          with = i_document-billingdocument
                                          ).

              e_return-message = replace( val  = TEXT-007
                                          sub  = '&2'
                                          with = i_document-fiscalyearsource
                                          ).
            ENDIF.
          ENDIF.
        ENDIF.

**--Check Không điều chỉnh/thay thế chứng từ khác loại tiền tệ
        lv_count = 0.
        IF i_document-accountingdocument NE ''.
          SELECT COUNT( 1 )
              FROM zjp_a_hddt_h INNER JOIN i_journalentry
              ON zjp_a_hddt_h~companycode          = i_journalentry~companycode
              AND zjp_a_hddt_h~accountingdocument  = i_journalentry~accountingdocument
              AND zjp_a_hddt_h~fiscalyear          = i_journalentry~fiscalyear

              WHERE zjp_a_hddt_h~companycode       = @i_document-companycode
              AND zjp_a_hddt_h~accountingdocument  = @i_document-accountingdocumentsource
              AND zjp_a_hddt_h~fiscalyear          = @i_document-fiscalyearsource
              AND i_journalentry~transactioncurrency = @i_document-transactioncurrency
              INTO @lv_count.
        ELSE.
          SELECT COUNT( 1 )
              FROM zjp_a_hddt_h INNER JOIN i_billingdocument
              ON zjp_a_hddt_h~billingdocument       = i_billingdocument~billingdocument
              WHERE zjp_a_hddt_h~companycode        = @i_document-companycode
              AND zjp_a_hddt_h~billingdocument      = @i_document-accountingdocumentsource
              AND zjp_a_hddt_h~fiscalyear           = @i_document-fiscalyearsource
              AND i_billingdocument~transactioncurrency = @i_document-transactioncurrency
              INTO @lv_count.
        ENDIF.

        IF lv_count = 0.
          e_return-type = 'E'.
          e_return-message = TEXT-004.
        ELSE.
        ENDIF.

**--Check Không điều chỉnh/thay thế chứng từ đã bị thay thế
        lv_count = 0.
        SELECT COUNT( 1 )
        FROM zjp_a_hddt_h
        WHERE companycode       = @i_document-companycode
        AND accountingdocument  = @i_document-accountingdocumentsource
        AND fiscalyear          = @i_document-fiscalyearsource
        AND statussap IN ('07')
        AND fiscalyearsource NE ''
        INTO @lv_count.
        IF lv_count NE 0.
          e_return-type     = 'E'.
          e_return-message  = TEXT-005.
        ENDIF.

      ENDIF.

    ELSEIF i_document-accountingdocumentsource IS INITIAL AND i_document-fiscalyearsource IS INITIAL AND i_document-adjusttype IS INITIAL.

    ELSE.
      e_return-type = 'E'.
      e_return-message = TEXT-006.
    ENDIF.
  ENDMETHOD.


  METHOD cleanup.

    "Call SOAP Over HTTP
    TRY.
        zsc_call_service_com_0002=>get_instance( )->change_journal_entry_http(
        i_header = gt_headers
        i_items  = gt_items
         ).
      CATCH cx_uuid_error cx_abap_context_info_error.
        "handle exception
    ENDTRY.

  ENDMETHOD.


  METHOD cleanup_finalize.

  ENDMETHOD.


  METHOD clear_variables.
    CLEAR: gv_action, gs_document, gs_userpass, gs_formserial, gs_status, gs_json, gs_docsrc,
    gs_return, gv_testrun.

  ENDMETHOD.


  METHOD constructor .

    CALL METHOD super->constructor.

    go_einvoice_data = COND #( WHEN go_einvoice_data IS BOUND
                             THEN go_einvoice_data
                             ELSE NEW zcl_einvoice_data( ) ).

    go_viettel_sinvoice = COND #( WHEN go_viettel_sinvoice IS BOUND
                                  THEN go_viettel_sinvoice
                                  ELSE NEW zcl_manage_viettel_einvoices( ) ).
  ENDMETHOD.


  METHOD get_keys.

    FREE: ir_companycode, ir_accountingdocument, ir_fiscalyear,
          ir_currencytype, ir_einvoicetype, ir_usertype, ir_typeofdate.

    DATA: lv_uuidfilter TYPE string.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
      ASSIGN COMPONENT '%tky-Companycode' OF STRUCTURE <lfs_keys> TO FIELD-SYMBOL(<lv_value>).
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO ir_companycode.
      ENDIF.

      ASSIGN COMPONENT '%tky-Accountingdocument' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO ir_accountingdocument.
      ENDIF.

      ASSIGN COMPONENT '%tky-Fiscalyear' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO ir_fiscalyear.
      ENDIF.

      ASSIGN COMPONENT '%tky-currencytype' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO ir_currencytype.
      ENDIF.

      ASSIGN COMPONENT '%tky-einvoicetype' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO ir_einvoicetype.
      ENDIF.

      ASSIGN COMPONENT '%tky-usertype' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO ir_usertype.
      ENDIF.

      ASSIGN COMPONENT '%tky-typeofdate' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO ir_typeofdate.
      ENDIF.

      ASSIGN COMPONENT '%tky-testrun' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO ir_testrun.
      ENDIF.

      ASSIGN COMPONENT '%tky-UUidFilter' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        lv_uuidfilter = <lv_value>.
      ENDIF.

    ENDLOOP.

    DATA: lt_parts TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    IF lv_uuidfilter IS NOT INITIAL.
      SPLIT lv_uuidfilter AT '-' INTO TABLE lt_parts.
    ENDIF.

    LOOP AT lt_parts INTO DATA(lv_pair).
      SPLIT lv_pair AT '=' INTO DATA(lv_key) DATA(lv_val).
      CASE lv_key.
        WHEN 'currencytype'.
          IF lv_val IS NOT INITIAL.
            APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_val ) TO ir_currencytype.
          ENDIF.
        WHEN 'typeofdate'.
          IF lv_val IS NOT INITIAL.
            APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_val ) TO ir_typeofdate.
          ENDIF.
        WHEN 'testrun'.
          IF lv_val IS NOT INITIAL.
            APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_val ) TO ir_testrun.
          ENDIF.
        WHEN 'einvoicetype'.
          IF lv_val IS NOT INITIAL.
            APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_val ) TO ir_einvoicetype.
          ENDIF.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_password.

    DATA: lv_fiscalyear TYPE gjahr.
    DATA: lr_usertype TYPE tt_ranges.

    IF i_document-usertype IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = i_document-usertype ) TO lr_usertype.
    ENDIF.

    SELECT * FROM zjp_hd_userpass WHERE companycode = @i_document-companycode
                                           AND usertype    IN @lr_usertype
    INTO TABLE @DATA(lt_userpass).
    IF sy-subrc NE 0.
      e_return-type = 'E'.
      e_return-message = TEXT-001.
    ELSE.
      READ TABLE lt_userpass INTO DATA(ls_userpass) INDEX 1.

      MOVE-CORRESPONDING ls_userpass TO e_userpass.
    ENDIF.

    go_einvoice_data->getdate_einvoice(
      EXPORTING
        i_document = i_document
      IMPORTING
        e_document = e_document
    ).

    lv_fiscalyear = e_document-einvoicedatecreate+0(4).

    SELECT SINGLE * FROM zjp_hd_serial WHERE companycode  = @i_document-companycode
                                         AND einvoicetype = @i_document-einvoicetype
                                         AND fiscalyear   = @lv_fiscalyear
    INTO CORRESPONDING FIELDS OF @e_formserial.
    IF sy-subrc NE 0.
      e_return-type = 'E'.
      e_return-message = TEXT-002 && ` ` && lv_fiscalyear.
    ENDIF.

  ENDMETHOD.


  METHOD handle_adjust_einvoice_v2.

    TYPES: BEGIN OF lty_adjust,
             companycode        TYPE bukrs,
             accountingdocument TYPE belnr_d,
             fiscalyear         TYPE gjahr,
           END OF lty_adjust.
    DATA: ls_adjust TYPE lty_adjust.

    DATA: ls_result         LIKE LINE OF result,
          ls_mapped_headers LIKE LINE OF mapped-hddt_headers.

    DATA: ls_param TYPE zpr_adjust_einvoice.

    DATA: it_headers TYPE TABLE OF wa_document,
          it_items   TYPE TABLE OF wa_items.

    " 1) Lấy instance đang được bấm
    READ TABLE keys INDEX 1 INTO DATA(k).

    " 2) ... làm nghiệp vụ của bạn ...
    go_einvoice_process = zcl_einvoice_process=>get_instance( ).

    go_einvoice_process->clear_variables( ).

    ls_param-belnrsource = k-%param-belnrsource.
    ls_param-gjahrsource = k-%param-gjahrsource.
    ls_param-adjtype     = k-%param-adjtype.

**" Get data from keys entities
    go_einvoice_process->get_keys(
      EXPORTING
        keys                  = keys
      IMPORTING
        ir_companycode        = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear         = ir_fiscalyear
        ir_einvoicetype       = ir_einvoicetype
        ir_currencytype       = ir_currencytype
        ir_usertype           = ir_usertype
        ir_typeofdate         = ir_typeofdate
        ir_testrun            = ir_testrun
    ).
**""
    go_einvoice_data->get_einvoice_data(
      EXPORTING
        ir_companycode        = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear         = ir_fiscalyear
        ir_einvoicetype       = ir_einvoicetype
        ir_currencytype       = ir_currencytype
        ir_usertype           = ir_usertype
        ir_typeofdate         = ir_typeofdate
        ir_testrun            = ir_testrun
      IMPORTING
        it_einvoice_header    = gt_headers
        it_einvoice_item      = gt_items
    ).

    LOOP AT gt_headers ASSIGNING FIELD-SYMBOL(<fs_header>).

      <fs_header>-accountingdocumentsource = ls_param-belnrsource.
      <fs_header>-fiscalyearsource = ls_param-gjahrsource.
      <fs_header>-adjusttype = ls_param-adjtype.

      go_einvoice_process->check_adjust_document(
        EXPORTING
          i_document = <fs_header>
        IMPORTING
          e_return   = gs_return
      ).
      IF gs_return-type = 'E'.
        <fs_header>-accountingdocumentsource = ''.
        <fs_header>-fiscalyearsource         = ''.
        <fs_header>-adjusttype               = ''.

        APPEND VALUE #( companycode        = <fs_header>-companycode
                        accountingdocument = <fs_header>-accountingdocument
                        fiscalyear         = <fs_header>-fiscalyear
                        billingdocument    = <fs_header>-billingdocument
                        msgtype            = gs_return-type
                        msgtext            = gs_return-message ) TO e_return.
      ENDIF.

      " 3) Trả lại kết quả bắt buộc cho action result [1] $self
      ls_result-%tky = k-%tky.

      MOVE-CORRESPONDING <fs_header> TO ls_result-%param-%data.

      APPEND ls_result  TO result.

      ls_mapped_headers-%tky = k-%tky.

      APPEND ls_mapped_headers TO mapped-hddt_headers.

    ENDLOOP.

  ENDMETHOD.


  METHOD handle_integration_einvoice.

    DATA: ls_mapped_headers  LIKE LINE OF mapped-hddt_headers,
          ls_mapped_item     LIKE LINE OF mapped-hddt_items,

          ls_reported_header LIKE LINE OF reported-hddt_headers,
          ls_reported_items  LIKE LINE OF reported-hddt_items.

    DATA: ls_result LIKE LINE OF result.

    DATA: it_headers TYPE TABLE OF wa_document,
          it_items   TYPE TABLE OF wa_items.

    FREE: ir_companycode, ir_accountingdocument, ir_fiscalyear.

    go_einvoice_process = zcl_einvoice_process=>get_instance( ).

    go_einvoice_process->clear_variables( ).

    go_einvoice_process->get_keys(
      EXPORTING
        keys                  = keys
      IMPORTING
        ir_companycode        = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear         = ir_fiscalyear
        ir_einvoicetype       = ir_einvoicetype
        ir_currencytype       = ir_currencytype
        ir_usertype           = ir_usertype
        ir_typeofdate         = ir_typeofdate
        ir_testrun            = ir_testrun
    ).

    go_einvoice_process->process_integration_einvoice(
      EXPORTING
*       i_action              = ''
        ir_companycode        = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear         = ir_fiscalyear
        ir_einvoicetype       = ir_einvoicetype
        ir_currencytype       = ir_currencytype
        ir_usertype           = ir_usertype
        ir_typeofdate         = ir_typeofdate
        ir_testrun            = ir_testrun
      IMPORTING
        e_headers             = gt_headers
        e_items               = gt_items
        e_docsrc              = gt_adjust_doc
        e_return              = e_return
    ).

    LOOP AT gt_headers ASSIGNING FIELD-SYMBOL(<fs_header>).

      MOVE-CORRESPONDING <fs_header> TO ls_result-%tky.
      MOVE-CORRESPONDING <fs_header> TO ls_result-%key.

      MOVE-CORRESPONDING <fs_header> TO ls_result.
      MOVE-CORRESPONDING <fs_header> TO ls_mapped_headers.

      ls_mapped_headers-%tky                 = ls_result-%tky.

      MOVE-CORRESPONDING <fs_header> TO ls_result-%param.

      IF gs_docsrc IS NOT INITIAL.
        APPEND gs_docsrc TO gt_adjust_doc.
      ENDIF.

      INSERT CORRESPONDING #( ls_result ) INTO TABLE result.
      INSERT CORRESPONDING #( ls_mapped_headers ) INTO TABLE mapped-hddt_headers.

    ENDLOOP.

  ENDMETHOD.


  METHOD handle_search_einvoice.

    DATA: ls_mapped_headers  LIKE LINE OF mapped-hddt_headers,
          ls_mapped_item     LIKE LINE OF mapped-hddt_items,

          ls_reported_header LIKE LINE OF reported-hddt_headers,
          ls_reported_items  LIKE LINE OF reported-hddt_items.

    DATA: ls_result LIKE LINE OF result.

    DATA: it_headers TYPE TABLE OF wa_document,
          it_items   TYPE TABLE OF wa_items.

    DATA(o_abap_behavior_handler) = NEW cl_abap_behavior_handler( ).

    " 1) Lấy instance đang được bấm
    READ TABLE keys INDEX 1 INTO DATA(k).

    " 2) ... làm nghiệp vụ của bạn ...
    go_einvoice_process = zcl_einvoice_process=>get_instance( ).

**" Get data from keys entities
    go_einvoice_process->get_keys(
      EXPORTING
        keys                  = keys
      IMPORTING
        ir_companycode        = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear         = ir_fiscalyear
        ir_einvoicetype       = ir_einvoicetype
        ir_currencytype       = ir_currencytype
        ir_usertype           = ir_usertype
        ir_typeofdate         = ir_typeofdate
        ir_testrun            = ir_testrun
    ).
**""

    TRY.
        go_einvoice_data->get_einvoice_data(
          EXPORTING
            ir_companycode        = ir_companycode
            ir_accountingdocument = ir_accountingdocument
            ir_fiscalyear         = ir_fiscalyear
            ir_einvoicetype       = ir_einvoicetype
            ir_currencytype       = ir_currencytype
            ir_usertype           = ir_usertype
            ir_typeofdate         = ir_typeofdate
            ir_testrun            = ir_testrun
          IMPORTING
            it_einvoice_header    = it_headers
            it_einvoice_item      = gt_items
        ).
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    LOOP AT it_headers ASSIGNING FIELD-SYMBOL(<fs_header>).
*      IF <fs_header>-usertype IS NOT INITIAL.
      MOVE-CORRESPONDING <fs_header> TO gs_document.

      TRY.
          go_einvoice_process->get_password(
            EXPORTING
              i_document = gs_document
            IMPORTING
              e_userpass = gs_userpass
          ).
        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.

      gv_action = 'SEARCH_INVOICE'.

      gs_document-suppliertax = gs_userpass-suppliertax.

      CASE <fs_header>-idsys.
        WHEN 'VIETTEL'.
          go_viettel_sinvoice->search_sinvoices(
            EXPORTING
              i_action   = gv_action
              i_einvoice = gs_document
              i_userpass = gs_userpass
            IMPORTING
              e_return   = gs_return
              e_status   = gs_status
              e_docsrc   = gs_docsrc
          ).
        WHEN 'FPT'.

        WHEN OTHERS.
      ENDCASE.


      SELECT SINGLE * FROM zjp_a_hddt_h
      WITH PRIVILEGED ACCESS
      WHERE companycode              = @<fs_header>-companycode
        AND accountingdocumentsource = @<fs_header>-accountingdocument
        AND fiscalyearsource         = @<fs_header>-fiscalyear
        AND einvoicenumber    NE ''
      INTO @DATA(ls_adjust).
      IF sy-subrc EQ 0 AND ls_adjust-einvoicenumber IS NOT INITIAL
      AND ( ls_adjust-statussap = '99' OR ls_adjust-statussap = '98' ).
        CASE ls_adjust-adjusttype.
          WHEN '3'. "Thay thế
*            <fs_header>-Iconsap = '@20@'.
            <fs_header>-statussap = '07'.
            <fs_header>-messagetext = 'Hóa đơn đã bị thay thế'.
          WHEN '1' OR '2'. "Điều chỉnh tiền
*            <fs_header>-Iconsap = '@4K@'.
            <fs_header>-statussap = '06'.
            <fs_header>-messagetext = 'Hóa đơn đã bị điều chỉnh'.
          WHEN OTHERS.
        ENDCASE.
      ELSE.

        go_einvoice_process->move_log(
          EXPORTING
            i_input  = gs_status
          IMPORTING
            o_output = <fs_header>
          CHANGING
            c_items  = gt_items
        ).

      ENDIF.

      IF gs_docsrc IS NOT INITIAL.
        APPEND gs_docsrc TO gt_adjust_doc.
      ENDIF.

*      ELSE.
*        <fs_header>-statussap = '01'.
*        <fs_header>-messagetype = ''.
*        <fs_header>-messagetext = ''.
*      ENDIF.

      " 3) Trả lại kết quả bắt buộc cho action result [1] $self
      ls_result-%tky = k-%tky.
*
      MOVE-CORRESPONDING <fs_header> TO ls_result-%param.

      INSERT CORRESPONDING #( ls_result )  INTO TABLE result.

      ls_mapped_headers-%tky = k-%tky.

      INSERT CORRESPONDING #( ls_mapped_headers )  INTO TABLE mapped-hddt_headers.

*      MOVE-CORRESPONDING <fs_header> TO ls_reported_header-%element.

**      " 3b) Đẩy trạng thái enable (features) ngay trong reported
*      APPEND VALUE #( %tky                = k-%tky
*                      %state_area         = if_abap_behv=>state_area_all
*                      %action-integration = if_abap_behv=>fc-o-enabled
*                      %action-search      = if_abap_behv=>fc-o-enabled
*                      %action-adjust      = if_abap_behv=>fc-o-enabled
*                      %action-mapping     = if_abap_behv=>fc-o-enabled
*                      %element            = ls_reported_header-%element
*                    )
*             TO reported-hddt_headers.
*
**      " 3c) Nếu bật authorization master (instance), đẩy quyền luôn
*      APPEND VALUE #( %tky                = k-%tky
*                      %state_area         = if_abap_behv=>state_area_all
*                      %action-search      = if_abap_behv=>auth-allowed
*                      %action-integration = if_abap_behv=>auth-allowed
*                      %action-adjust      = if_abap_behv=>auth-allowed
*                      %action-mapping     = if_abap_behv=>auth-allowed
*                      %element            = ls_reported_header-%element
*                    )
*             TO reported-hddt_headers.

    ENDLOOP.

    MOVE-CORRESPONDING it_headers TO gt_headers.

  ENDMETHOD.


  METHOD process_integration_einvoice.

    DATA: it_headers TYPE tt_headers,
          gt_items   TYPE tt_items.

    go_einvoice_process = zcl_einvoice_process=>get_instance( ).

    go_einvoice_data->get_einvoice_data(
      EXPORTING
        ir_companycode        = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear         = ir_fiscalyear
        ir_einvoicetype       = ir_einvoicetype
        ir_currencytype       = ir_currencytype
        ir_usertype           = ir_usertype
        ir_typeofdate         = ir_typeofdate
        ir_testrun            = ir_testrun
      IMPORTING
        it_einvoice_header    = it_headers
        it_einvoice_item      = gt_items
    ).

    LOOP AT it_headers ASSIGNING FIELD-SYMBOL(<fs_header>).

      go_einvoice_process->clear_variables( ).

*      gv_action = i_action.
      IF <fs_header>-adjusttype = '1'.
        gv_action = 'ADJUST_INVOICE'.
      ELSEIF <fs_header>-adjusttype = '2'.
        gv_action = 'REPLACE_INVOICE'.
      ELSE.
        gv_action = 'CREATE_INVOICE'.
      ENDIF.

      IF <fs_header>-statussap = '01' OR <fs_header>-statussap = '03'.
        IF <fs_header>-einvoicenumber IS INITIAL.

          IF <fs_header>-xreversed IS INITIAL AND <fs_header>-xreversing IS INITIAL.

            MOVE-CORRESPONDING <fs_header> TO gs_document.

            go_einvoice_process->get_password(
              EXPORTING
                i_document = gs_document
              IMPORTING
                e_userpass = gs_userpass
            ).

            IF gv_action CP 'ADJUST_INVOICE*' OR gv_action CP 'REPLACE_INVOICE*'.

*              SELECT SINGLE * FROM zjp_a_hddt_h
*              WHERE companycode = @<fs_header>-companycode
*                AND accountingdocument = @<fs_header>-accountingdocument
*                AND fiscalyear = @<fs_header>-fiscalyearsource
*                AND statussap IN ( '98', '99', '10' )
*                INTO @DATA(ls_check).
*              IF sy-subrc NE 0.
*                gs_return-type = 'E'.
*
*                RETURN.
*              ENDIF.

              IF i_param IS NOT INITIAL.
                <fs_header>-accountingdocumentsource = i_param-accountingdocumentsource.
                <fs_header>-fiscalyearsource         = i_param-fiscalyearsource.
                <fs_header>-adjusttype               = i_param-adjusttype.
              ENDIF.

              go_einvoice_process->check_adjust_document(
                EXPORTING
                  i_document = <fs_header>
                IMPORTING
                  e_return   = gs_return
              ).

              IF gs_return-type EQ 'E'.

*                <fs_header>-accountingdocumentsource = ''.
*                <fs_header>-fiscalyearsource         = ''.
*                <fs_header>-adjusttype               = ''.

                APPEND VALUE #( companycode        = <fs_header>-companycode
                                accountingdocument = <fs_header>-accountingdocument
                                fiscalyear         = <fs_header>-fiscalyear
                                billingdocument    = <fs_header>-billingdocument
                                msgtype            = gs_return-type
                                msgtext            = gs_return-message ) TO e_return.
              ELSE.
                IF gs_return-type EQ 'W'.
                  APPEND VALUE #( companycode        = <fs_header>-companycode
                                  accountingdocument = <fs_header>-accountingdocument
                                  fiscalyear         = <fs_header>-fiscalyear
                                  billingdocument    = <fs_header>-billingdocument
                                  msgtype            = gs_return-type
                                  msgtext            = gs_return-message ) TO e_return.
                ENDIF.

                IF <fs_header>-accountingdocumentsource IS NOT INITIAL.

                  go_einvoice_process->get_password(
                    EXPORTING
                      i_document = <fs_header>
                    IMPORTING
                      e_userpass = gs_userpass
                      e_return   = gs_return
                  ).

                  MOVE-CORRESPONDING <fs_header> TO gs_document.

**--Adjust/Replace EInvoice
                  CASE gs_document-idsys.
                    WHEN 'VIETTEL'.
                      go_viettel_sinvoice->adjust_sinvoices(
                        EXPORTING
                          i_action   = gv_action
                          i_einvoice = gs_document
                          i_items    = gt_items
                          i_userpass = gs_userpass
                        IMPORTING
                          e_status   = gs_status
                          e_docsrc   = gs_docsrc
                          e_json     = gs_json
                          e_return   = gs_return
                      ).
                    WHEN 'FPT'.

                    WHEN OTHERS.
                  ENDCASE.

                  go_einvoice_process->move_log(
                    EXPORTING
                      i_input  = gs_status
                    IMPORTING
                      o_output = <fs_header>
                    CHANGING
                      c_items  = gt_items
                  ).

                  IF gs_return-type           = 'E'.
*                    <fs_header>-Iconsap      = '@0A@'.
                    <fs_header>-statussap    = '03'.
                    <fs_header>-messagetype  = gs_return-type.
                    <fs_header>-messagetext  = gs_return-message.
                  ENDIF.
                ELSE. "End Check Accounting Document Source

                  <fs_header>-accountingdocumentsource = ''.
                  <fs_header>-fiscalyearsource         = ''.
                  <fs_header>-adjusttype               = ''.
                ENDIF.
              ENDIF.

            ELSEIF gv_action CP 'CREATE_INVOICE*'.
**--Create New EInvoice
              CASE gs_document-idsys.
                WHEN 'VIETTEL'.
                  go_viettel_sinvoice->create_sinvoices(
                    EXPORTING
                      i_action   = gv_action
                      i_einvoice = gs_document
                      i_items    = gt_items
                      i_userpass = gs_userpass
                    IMPORTING
                      e_status   = gs_status
                      e_docsrc   = gs_docsrc
                      e_json     = gs_json
                      e_return   = gs_return
                  ).
                WHEN 'FPT'.

                WHEN OTHERS.
              ENDCASE.

            ENDIF. "End IF Case Create new OR Adjust Invoice

            go_einvoice_process->move_log(
              EXPORTING
                i_input  = gs_status
              IMPORTING
                o_output = <fs_header>
              CHANGING
                c_items  = gt_items
            ).

            IF gs_return-type = 'E'.
*              <fs_header>-Iconsap     = '@0A@'.
              <fs_header>-statussap   = '03'.
              <fs_header>-messagetype = gs_return-type.
              <fs_header>-messagetext = gs_return-message.

            ENDIF.

          ELSE.  "End check reverse
            <fs_header>-statussap     = '03'.
            <fs_header>-messagetype   = 'E'.
            <fs_header>-messagetext   = 'Document Is Reversal/Reversed'.
          ENDIF.

        ELSE. "End check EInvoice Number
          <fs_header>-accountingdocumentsource = ''.
          <fs_header>-fiscalyearsource         = ''.
          <fs_header>-adjusttype               = ''.

          APPEND VALUE #( companycode        = <fs_header>-companycode
                          accountingdocument = <fs_header>-accountingdocument
                          fiscalyear         = <fs_header>-fiscalyear
                          billingdocument    = <fs_header>-billingdocument
                          msgtype            = 'E'
                          msgtext            = TEXT-012 ) TO e_return.
        ENDIF.

      ELSE. "End check status
        <fs_header>-accountingdocumentsource = ''.
        <fs_header>-fiscalyearsource = ''.
        <fs_header>-adjusttype = ''.

        APPEND VALUE #( companycode        = <fs_header>-companycode
                        accountingdocument = <fs_header>-accountingdocument
                        fiscalyear         = <fs_header>-fiscalyear
                        billingdocument    = <fs_header>-billingdocument
                        msgtype            = 'E'
                        msgtext            = TEXT-010 ) TO e_return.
      ENDIF.

      IF gs_docsrc IS NOT INITIAL.
        APPEND gs_docsrc TO e_docsrc.
      ENDIF.

    ENDLOOP.

    MOVE-CORRESPONDING it_headers   TO e_headers.
    MOVE-CORRESPONDING gt_items     TO e_items.

  ENDMETHOD.


  METHOD move_log.
    o_output-einvoicenumber        = i_input-einvoicenumber .
    o_output-einvoiceserial        = i_input-einvoiceserial .
    o_output-einvoiceform          = i_input-einvoiceform .
    o_output-einvoicetype          = i_input-einvoicetype .
    o_output-mscqt                 = i_input-mscqt .
    o_output-link                  = i_input-link .
    o_output-einvoicedatecancel    = i_input-einvoicedatecreate .
    o_output-einvoicetimecreate    = i_input-einvoicetimecreate .
    o_output-einvoicedatecancel    = i_input-einvoicedatecancel .
    o_output-statussap             = i_input-statussap .
    o_output-statusinvres          = i_input-statusinvres .
    o_output-statuscqtres          = i_input-statuscqtres .
    o_output-invdat                = i_input-invdat.
    o_output-reservationcode       = i_input-reservationcode.
    o_output-messagetype           = i_input-messagetype .
    o_output-messagetext           = i_input-messagetext .
    o_output-createdbyuser         = i_input-createdbyuser.
    o_output-createddate           = i_input-createddate.
    o_output-createdtime           = i_input-createdtime.

    o_output-zmapp                 = i_input-zmapp.
    o_output-frdate                = i_input-frdate.
    o_output-todate                = i_input-todate.

    LOOP AT c_items ASSIGNING FIELD-SYMBOL(<fs_items>) WHERE companycode = i_input-companycode
                                                         AND accountingdocument = i_input-accountingdocument
                                                         AND fiscalyear = i_input-fiscalyear.

      <fs_items>-statussap = i_input-statussap.
    ENDLOOP.

    SELECT SINGLE description FROM zjp_hd_config
    WHERE id_sys = '001'
     AND id_domain = 'STATUSSAP'
     AND value = @o_output-statussap
     INTO @o_output-descriptionstatussap.

*        OK → sap-icon://accept (xanh) – Criticality = 3
*
*        WARN → sap-icon://alert (vàng) – Criticality = 2
*
*        ERR → sap-icon://error (đỏ) – Criticality = 1
*
*        Khác → sap-icon://question-mark (xám) – Criticality = 0

    CASE o_output-statussap.
      WHEN '01'.
        o_output-criticality = 0.
        o_output-statusiconurl = 'sap-icon://horizontal-grip'.
      WHEN '02'.
        o_output-criticality = 2.
        o_output-statusiconurl = 'sap-icon://message-success'.
      WHEN '03'.
        o_output-criticality = 2.
        o_output-statusiconurl = 'sap-icon://status-error'.
      WHEN '06'.
        o_output-criticality = 3.
        o_output-statusiconurl = 'sap-icon://journey-change'.
      WHEN '07'.
        o_output-criticality = 3.
        o_output-statusiconurl = 'sap-icon://cancel'.
      WHEN '10'.
        o_output-criticality = 2.
        o_output-statusiconurl = 'sap-icon://message-success'.
      WHEN '98'.
        o_output-criticality = 2.
        o_output-statusiconurl = 'sap-icon://message-success'.
      WHEN '99'.
        o_output-criticality = 3.
        o_output-statusiconurl = 'sap-icon://message-success'.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.


  METHOD read_header.

  ENDMETHOD.


  METHOD read_items.

  ENDMETHOD.


  METHOD save_einvoice.

    DATA: ls_hddt_h TYPE zjp_a_hddt_h.

    SORT gt_headers    BY companycode accountingdocument billingdocument fiscalyear ASCENDING.
    SORT gt_adjust_doc BY companycode accountingdocument billingdocument fiscalyear ASCENDING.

    SORT gt_items BY companycode accountingdocument billingdocument fiscalyear accountingdocumentitem ASCENDING.

    LOOP AT gt_headers INTO DATA(ls_header).

      READ TABLE gt_adjust_doc TRANSPORTING NO FIELDS WITH KEY
        companycode         = ls_header-companycode
        accountingdocument  = ls_header-accountingdocument
*        BillingDocument     = ls_header-BillingDocument
        fiscalyear          = ls_header-fiscalyear
        BINARY SEARCH.
      IF sy-subrc EQ 0.
        CONTINUE.
      ENDIF.

      MOVE-CORRESPONDING ls_header TO ls_hddt_h.

      SELECT COUNT(*) FROM zjp_a_hddt_h
      WHERE companycode        = @ls_header-companycode
        AND accountingdocument = @ls_header-accountingdocument
        AND fiscalyear         = @ls_header-fiscalyear
*        AND billingdocument    = @ls_header-BillingDocument
        INTO @DATA(lv_count).
      IF sy-subrc NE 0.
        CLEAR: lv_count.
      ENDIF.

      IF lv_count = 0.
        MODIFY zjp_a_hddt_h FROM @ls_hddt_h.
      ELSE.
        UPDATE zjp_a_hddt_h SET
*                                CustomerName                = @ls_header-CustomerName ,
*                                CustomerAddress             = @ls_header-CustomerAddress ,
*                                EmailAddress                = @ls_header-EmailAddress ,
*                                identificationnumber        = @ls_header-identificationnumber ,
*                                telephonenumber             = @ls_header-telephonenumber ,
                                typeofdate                  = @ls_header-typeofdate ,
                                usertype                    = @ls_header-usertype ,
                                accountingdocumentsource    = @ls_header-accountingdocumentsource ,
                                fiscalyearsource            = @ls_header-fiscalyearsource ,
                                adjusttype                  = @ls_header-adjusttype ,
                                currencytype                = @ls_header-currencytype ,
                                paymentmethod               = @ls_header-paymentmethod ,
                                einvoicenumber              = @ls_header-einvoicenumber ,
                                einvoiceserial              = @ls_header-einvoiceserial ,
                                einvoiceform                = @ls_header-einvoiceform ,
                                einvoicetype                = @ls_header-einvoicetype ,
                                mscqt                       = @ls_header-mscqt ,
                                link                        = @ls_header-link ,
                                einvoicedatecreate          = @ls_header-einvoicedatecreate ,
                                einvoicetimecreate          = @ls_header-einvoicetimecreate ,
                                einvoicedatecancel          = @ls_header-einvoicedatecancel ,
                                statussap                   = @ls_header-statussap ,
                                statusinvres                = @ls_header-statusinvres ,
                                statuscqtres                = @ls_header-statuscqtres ,
                                messagetype                 = @ls_header-messagetype ,
                                messagetext                 = @ls_header-messagetext,
                                invdat                      = @ls_header-invdat,
                                reservationcode             = @ls_header-reservationcode,

                                zmapp                       = @ls_header-zmapp,
                                frdate                      = @ls_header-frdate,
                                todate                      = @ls_header-todate
*                                xreversed                   = @ls_header-xreversed,
*                                xreversing                  = @ls_header-xreversing
      WHERE companycode         = @ls_header-companycode
        AND accountingdocument  = @ls_header-accountingdocument
        AND fiscalyear          = @ls_header-fiscalyear
*        AND billingdocument     = @ls_header-BillingDocument
        .
      ENDIF.

    ENDLOOP.

    LOOP AT gt_adjust_doc INTO DATA(ls_adjust_doc).
      UPDATE zjp_a_hddt_h SET
*                              iconsap       = @ls_adjust_doc-Iconsap ,
                              statussap     = @ls_adjust_doc-statussap ,
                              messagetext   = @ls_adjust_doc-messagetext

      WHERE companycode          = @ls_adjust_doc-companycode
        AND accountingdocument   = @ls_adjust_doc-accountingdocument
        AND fiscalyear           = @ls_adjust_doc-fiscalyear
        AND billingdocument      = @ls_adjust_doc-billingdocument.
    ENDLOOP.

*    LOOP AT gt_items INTO DATA(ls_ietms).
*
*      SELECT COUNT(*) FROM zjp_a_hddt_i
*            WHERE companycode        = @ls_ietms-companycode
*              AND accountingdocument = @ls_ietms-accountingdocument
*              AND fiscalyear         = @ls_ietms-fiscalyear
*              INTO @lv_count.
*      IF sy-subrc NE 0.
*        CLEAR: lv_count.
*      ENDIF.
*
*      IF lv_count = 0.
*        MODIFY zjp_a_hddt_i FROM @ls_ietms.
*      ELSE.
*        IF ls_ietms-statussap = '01' OR ls_ietms-statussap = '03'.
*          MODIFY zjp_a_hddt_i FROM @ls_ietms.
*        ENDIF.
*      ENDIF.
*
*    ENDLOOP.

  ENDMETHOD.


  METHOD handle_mapping_einvoice.

    DATA: ls_result LIKE LINE OF result.

    DATA: it_headers TYPE TABLE OF wa_document,
          it_items   TYPE TABLE OF wa_items.

    go_einvoice_process = zcl_einvoice_process=>get_instance( ).

**" Get data from keys entities
    go_einvoice_process->get_keys(
      EXPORTING
        keys                  = keys
      IMPORTING
        ir_companycode        = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear         = ir_fiscalyear
        ir_einvoicetype       = ir_einvoicetype
        ir_currencytype       = ir_currencytype
        ir_usertype           = ir_usertype
        ir_typeofdate         = ir_typeofdate
        ir_testrun            = ir_testrun
    ).
**""

    TRY.
        go_einvoice_data->get_einvoice_data(
          EXPORTING
            ir_companycode        = ir_companycode
            ir_accountingdocument = ir_accountingdocument
            ir_fiscalyear         = ir_fiscalyear
            ir_einvoicetype       = ir_einvoicetype
            ir_currencytype       = ir_currencytype
            ir_usertype           = ir_usertype
            ir_typeofdate         = ir_typeofdate
            ir_testrun            = ir_testrun
          IMPORTING
            it_einvoice_header    = it_headers
            it_einvoice_item      = gt_items
        ).
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    READ TABLE keys INDEX 1 INTO DATA(ls_keys).

    LOOP AT it_headers ASSIGNING FIELD-SYMBOL(<fs_header>).
*      IF <fs_header>-usertype IS NOT INITIAL.

      IF <fs_header>-statussap = '03' OR <fs_header>-statussap = '01'.
        <fs_header>-zmapp = ls_keys-%param-einvoiceno.
        <fs_header>-frdate = ls_keys-%param-fromdate.
        <fs_header>-todate = ls_keys-%param-todate.
      ELSE.
*        CONTINUE.
      ENDIF.

      MOVE-CORRESPONDING <fs_header> TO gs_document.

      TRY.
          go_einvoice_process->get_password(
            EXPORTING
              i_document = gs_document
            IMPORTING
              e_userpass = gs_userpass
          ).
        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.

      gv_action = 'SEARCH_INVOICE'.

      gs_document-suppliertax = gs_userpass-suppliertax.

      CASE <fs_header>-idsys.
        WHEN 'VIETTEL'.
          go_viettel_sinvoice->search_sinvoices(
            EXPORTING
              i_action   = gv_action
              i_einvoice = gs_document
              i_userpass = gs_userpass
            IMPORTING
              e_return   = gs_return
              e_status   = gs_status
              e_docsrc   = gs_docsrc
          ).
        WHEN 'FPT'.

        WHEN OTHERS.
      ENDCASE.


      SELECT SINGLE * FROM zjp_a_hddt_h
      WITH PRIVILEGED ACCESS
      WHERE companycode              = @<fs_header>-companycode
        AND accountingdocumentsource = @<fs_header>-accountingdocument
        AND fiscalyearsource         = @<fs_header>-fiscalyear
        AND einvoicenumber    NE ''
      INTO @DATA(ls_adjust).
      IF sy-subrc EQ 0 AND ls_adjust-einvoicenumber IS NOT INITIAL
      AND ( ls_adjust-statussap = '99' OR ls_adjust-statussap = '98' ).
        CASE ls_adjust-adjusttype.
          WHEN '3'. "Thay thế
*            <fs_header>-Iconsap = '@20@'.
            <fs_header>-statussap = '07'.
            <fs_header>-messagetext = 'Hóa đơn đã bị thay thế'.
          WHEN '1' OR '2'. "Điều chỉnh tiền
*            <fs_header>-Iconsap = '@4K@'.
            <fs_header>-statussap = '06'.
            <fs_header>-messagetext = 'Hóa đơn đã bị điều chỉnh'.
          WHEN OTHERS.
        ENDCASE.
      ELSE.

        go_einvoice_process->move_log(
          EXPORTING
            i_input  = gs_status
          IMPORTING
            o_output = <fs_header>
          CHANGING
            c_items  = gt_items
        ).

      ENDIF.

      IF gs_docsrc IS NOT INITIAL.
        APPEND gs_docsrc TO gt_adjust_doc.
      ENDIF.

*      ELSE.
*        <fs_header>-statussap = '01'.
*        <fs_header>-messagetype = ''.
*        <fs_header>-messagetext = ''.
*      ENDIF.


      MOVE-CORRESPONDING <fs_header> TO ls_result-%tky.
      MOVE-CORRESPONDING <fs_header> TO ls_result-%key.
      MOVE-CORRESPONDING <fs_header> TO ls_result-%param.

      INSERT CORRESPONDING #( ls_result ) INTO TABLE result.

    ENDLOOP.

    MOVE-CORRESPONDING it_headers TO gt_headers.

  ENDMETHOD.


  METHOD get_instance.
    IF go_einvoice_process IS BOUND.
    ELSE.
      CREATE OBJECT go_einvoice_process.  " gọi constructor đúng một lần
    ENDIF.
    ro = go_einvoice_process.
  ENDMETHOD.


  METHOD handle_preview_draft.

    READ TABLE keys INDEX 1 INTO DATA(k).

    go_einvoice_process = zcl_einvoice_process=>get_instance( ).

    go_einvoice_process->clear_variables( ).

    go_einvoice_process->get_keys(
      EXPORTING
        keys                  = keys
      IMPORTING
        ir_companycode        = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear         = ir_fiscalyear
        ir_einvoicetype       = ir_einvoicetype
        ir_currencytype       = ir_currencytype
        ir_usertype           = ir_usertype
        ir_typeofdate         = ir_typeofdate
        ir_testrun            = ir_testrun
    ).

    TRY.
        go_einvoice_data->get_einvoice_data(
          EXPORTING
            ir_companycode        = ir_companycode
            ir_accountingdocument = ir_accountingdocument
            ir_fiscalyear         = ir_fiscalyear
            ir_einvoicetype       = ir_einvoicetype
            ir_currencytype       = ir_currencytype
            ir_usertype           = ir_usertype
            ir_typeofdate         = ir_typeofdate
            ir_testrun            = ir_testrun
          IMPORTING
            it_einvoice_header    = DATA(lt_headers)
            it_einvoice_item      = DATA(lt_items)
            it_returns            = DATA(lt_returns)
        ).

      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    LOOP AT lt_headers INTO DATA(ls_header).
      ls_header-testrun = 'X'.
      TRY.
          go_einvoice_process->get_password(
            EXPORTING
              i_document = ls_header
            IMPORTING
              e_userpass = DATA(ls_userpass)
              e_return   = DATA(ls_return)
          ).
        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.

      TRY.
          IF ls_header-adjusttype IS NOT INITIAL.
            go_viettel_sinvoice->adjust_sinvoices(
              EXPORTING
                i_action   = 'ADJUST'
                i_einvoice = ls_header
                i_items    = lt_items
                i_userpass = ls_userpass
              IMPORTING
*               e_status   = gs_status
*               e_docsrc   = gs_docsrc
                e_json     = DATA(lv_json)
                e_return   = ls_return
            ).
          ELSE.
            go_viettel_sinvoice->create_sinvoices(
              EXPORTING
                i_action   = 'CREATE'
                i_einvoice = ls_header
                i_items    = lt_items
                i_userpass = ls_userpass
              IMPORTING
*               e_status   = gs_status
*               e_docsrc   = gs_docsrc
                e_json     = lv_json
                e_return   = ls_return
            ).
          ENDIF.

          SELECT SINGLE url_value FROM zjp_hddt_url WHERE action = 'PreviewInvoiceDraft'
            AND id_sys = 'VIETTEL' INTO @DATA(lv_url) PRIVILEGED ACCESS.

          go_viettel_sinvoice->post_sinvoices(
            EXPORTING
              i_userpass = ls_userpass
              i_context  = lv_json
              i_prefix   = lv_url
            IMPORTING
              e_context  = DATA(lv_context)
              e_return   = ls_return ).

        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.
    ENDLOOP.

    TYPES: BEGIN OF lty_context,
             errorcode   TYPE string,
             description TYPE string,
             filetobytes TYPE string,
           END OF lty_context.

    DATA: ls_context TYPE lty_context.
    DATA: lv_name TYPE zde_char100.

    lv_name = 'Preview_Draft_Sinvoice'.

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
        data        = ls_context
    ).

    IF ls_return IS NOT INITIAL.
      APPEND VALUE #(
          companycode        = k-companycode
          accountingdocument = k-accountingdocument
          fiscalyear         = k-fiscalyear
          billingdocument    = k-billingdocument
          msgtype            = ls_return-type
          msgtext            = ls_return-message
      ) TO e_return.

      result = VALUE #(
                FOR key IN keys (
*                      %cid_ref = key-%cid_ref
                %tky   = key-%tky
                %param = VALUE #( filecontent   = ls_return-message
                                  filename      = lv_name
                                  fileextension = 'pdf'
*                                          mimeType      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                  mimetype      = 'application/pdf'
                                  )
                )
      ).
    ELSE.
      result = VALUE #(
                  FOR key IN keys (
*                      %cid_ref = key-%cid_ref
                  %tky   = key-%tky
                  %param = VALUE #( filecontent   = ls_context-filetobytes
                                    filename      = lv_name
                                    fileextension = 'pdf'
*                                          mimeType      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                    mimetype      = 'application/pdf'
                                    )
                  )
      ).
    ENDIF.
  ENDMETHOD.


  METHOD handle_get_json.

    DATA: lv_name TYPE zde_char100.

    READ TABLE keys INDEX 1 INTO DATA(k).

    go_einvoice_process = zcl_einvoice_process=>get_instance( ).

    go_einvoice_process->clear_variables( ).

    go_einvoice_process->get_keys(
      EXPORTING
        keys                  = keys
      IMPORTING
        ir_companycode        = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear         = ir_fiscalyear
        ir_einvoicetype       = ir_einvoicetype
        ir_currencytype       = ir_currencytype
        ir_usertype           = ir_usertype
        ir_typeofdate         = ir_typeofdate
        ir_testrun            = ir_testrun
    ).

    TRY.
        go_einvoice_data->get_einvoice_data(
          EXPORTING
            ir_companycode        = ir_companycode
            ir_accountingdocument = ir_accountingdocument
            ir_fiscalyear         = ir_fiscalyear
            ir_einvoicetype       = ir_einvoicetype
            ir_currencytype       = ir_currencytype
            ir_usertype           = ir_usertype
            ir_typeofdate         = ir_typeofdate
            ir_testrun            = ir_testrun
          IMPORTING
            it_einvoice_header    = DATA(lt_headers)
            it_einvoice_item      = DATA(lt_items)
            it_returns            = DATA(lt_returns)
        ).

      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    LOOP AT lt_headers INTO DATA(ls_header).
      ls_header-testrun = 'X'.
      TRY.
          go_einvoice_process->get_password(
            EXPORTING
              i_document = ls_header
            IMPORTING
              e_userpass = DATA(ls_userpass)
              e_return   = DATA(ls_return)
          ).
        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.

      TRY.
          IF ls_header-adjusttype IS NOT INITIAL.
            go_viettel_sinvoice->adjust_sinvoices(
              EXPORTING
                i_action   = 'ADJUST'
                i_einvoice = ls_header
                i_items    = lt_items
                i_userpass = ls_userpass
              IMPORTING
*               e_status   = gs_status
*               e_docsrc   = gs_docsrc
                e_json     = DATA(lv_json)
                e_return   = ls_return
            ).
          ELSE.
            go_viettel_sinvoice->create_sinvoices(
              EXPORTING
                i_action   = 'CREATE'
                i_einvoice = ls_header
                i_items    = lt_items
                i_userpass = ls_userpass
              IMPORTING
*               e_status   = gs_status
*               e_docsrc   = gs_docsrc
                e_json     = lv_json
                e_return   = ls_return
            ).
          ENDIF.

*          SELECT SINGLE url_value FROM zjp_hddt_url WHERE action = 'PreviewInvoiceDraft'
*            AND id_sys = 'VIETTEL' INTO @DATA(lv_url) PRIVILEGED ACCESS.
*
*          go_viettel_sinvoice->post_sinvoices(
*            EXPORTING
*              i_userpass = ls_userpass
*              i_context  = lv_json
*              i_prefix   = lv_url
*            IMPORTING
*              e_context  = DATA(lv_context)
*              e_return   = ls_return ).

        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.
    ENDLOOP.

    lv_name = k-companycode &&
              k-accountingdocument &&
              k-fiscalyear .

    IF ls_return IS NOT INITIAL.
      APPEND VALUE #(
          companycode        = k-companycode
          accountingdocument = k-accountingdocument
          fiscalyear         = k-fiscalyear
          billingdocument    = k-billingdocument
          msgtype            = ls_return-type
          msgtext            = ls_return-message
      ) TO e_return.

      result = VALUE #(
                FOR key IN keys (
*                      %cid_ref = key-%cid_ref
                %tky   = key-%tky
                %param = VALUE #( filecontent   = ls_return-message
                                  filename      = lv_name
                                  fileextension = 'pdf'
*                                          mimeType      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                  mimetype      = 'application/pdf'
                                  )
                )
      ).
    ELSE.
      result = VALUE #(
                  FOR key IN keys (
*                      %cid_ref = key-%cid_ref
                  %tky   = key-%tky
                  %param = VALUE #( filecontent   = lv_json
                                    filename      = lv_name
                                    fileextension = 'pdf'
*                                          mimeType      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                    mimetype      = 'application/pdf'
                                    )
                  )
      ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.

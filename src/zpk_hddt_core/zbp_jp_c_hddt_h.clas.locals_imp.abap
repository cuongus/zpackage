CLASS lhc_hddt_headers DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR hddt_headers RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR hddt_headers RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ hddt_headers RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK hddt_headers.

    METHODS rba_einvoiceitems FOR READ
      IMPORTING keys_rba FOR READ hddt_headers\_einvoiceitems FULL result_requested RESULT result LINK association_links.

    METHODS adjust FOR MODIFY
      IMPORTING keys FOR ACTION hddt_headers~adjust RESULT result.

    METHODS integration FOR MODIFY
      IMPORTING keys FOR ACTION hddt_headers~integration RESULT result.

    METHODS search FOR MODIFY
      IMPORTING keys FOR ACTION hddt_headers~search RESULT result.

    METHODS mapping FOR MODIFY
      IMPORTING keys FOR ACTION hddt_headers~mapping RESULT result.

    METHODS getdefaultsfor_systemdate_adj FOR READ
      IMPORTING keys FOR FUNCTION hddt_headers~getdefaultsfor_systemdate_adj RESULT result.

    METHODS previewdraft FOR MODIFY
      IMPORTING keys FOR ACTION hddt_headers~previewdraft RESULT result.

    METHODS getjson FOR MODIFY
      IMPORTING keys FOR ACTION hddt_headers~getjson RESULT result.

ENDCLASS.

CLASS lhc_hddt_headers IMPLEMENTATION.

  METHOD get_instance_features.
    " (tùy chọn) đọc cờ xem UI có thực sự yêu cầu action nào không
*    DATA(req_search)      = requested_features-%action-Search.
*    DATA(req_integration) = requested_features-%action-Integration.
*    DATA(req_adjust)      = requested_features-%action-Adjust.
*    DATA(req_mapping)     = requested_features-%action-Mapping.
*
*    LOOP AT keys INTO DATA(key).
*      APPEND VALUE #(
*        %tky = key-%tky
*
*        " Nếu bạn muốn tôn trọng requested_features:
*        %action-Search      = COND abp_behv_op_ctrl(
*                                WHEN req_search = if_abap_behv=>mk-on
*                                THEN if_abap_behv=>fc-o-enabled
*                                ELSE if_abap_behv=>fc-o-disabled )
*        %action-Integration = COND abp_behv_op_ctrl(
*                                WHEN req_integration = if_abap_behv=>mk-on
*                                THEN if_abap_behv=>fc-o-enabled
*                                ELSE if_abap_behv=>fc-o-disabled )
*        %action-Adjust      = COND abp_behv_op_ctrl(
*                                WHEN req_adjust = if_abap_behv=>mk-on
*                                THEN if_abap_behv=>fc-o-enabled
*                                ELSE if_abap_behv=>fc-o-disabled )
*        %action-Mapping     = COND abp_behv_op_ctrl(
*                                WHEN req_mapping = if_abap_behv=>mk-on
*                                THEN if_abap_behv=>fc-o-enabled
*                                ELSE if_abap_behv=>fc-o-disabled )
*      ) TO result.
*    ENDLOOP.

*    LOOP AT keys INTO DATA(key).
*      APPEND VALUE #(
*        %tky                = key-%tky
*        %action-Search      = if_abap_behv=>fc-o-enabled
*        %action-Integration = if_abap_behv=>fc-o-enabled
*        %action-Adjust      = if_abap_behv=>fc-o-enabled
*        %action-Mapping     = if_abap_behv=>fc-o-enabled
*      ) TO result.
*    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_authorizations.
*    LOOP AT keys INTO DATA(k).
*      APPEND VALUE #(
*        %tky                = k-%tky
*
*        " QUAN TRỌNG: quyền cho các action
*        %action-Integration = if_abap_behv=>auth-allowed
*        %action-Search      = if_abap_behv=>auth-allowed
*        %action-Adjust      = if_abap_behv=>auth-allowed
*        %action-Mapping     = if_abap_behv=>auth-allowed
*      ) TO result.
*    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    zcl_einvoice_process=>read_header(
      EXPORTING
        keys     = keys
      CHANGING
        result   = result
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD lock.

    TRY.
        DATA(lock) = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZLOCK_HDDT_H' ).
      CATCH cx_abap_lock_failure INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
      TRY.
          lock->enqueue(
*              it_table_mode =
            it_parameter = VALUE #( ( name = 'COMPANYCODE'     value = REF #( <lfs_keys>-companycode ) )
                                    ( name = 'ACCTDOCUMENT'    value = REF #( <lfs_keys>-accountingdocument ) )
                                    ( name = 'FISCALYEAR'      value = REF #( <lfs_keys>-fiscalyear ) )
                                    ( name = 'BILLINGDOCUMENT' value = REF #( <lfs_keys>-billingdocument ) )
                                  )
*           _scope       =
*           _wait        =
          ).
        CATCH cx_abap_foreign_lock INTO DATA(foreign_lock).
          APPEND VALUE #(
              companycode        = keys[ 1 ]-companycode
              accountingdocument = keys[ 1 ]-accountingdocument
              fiscalyear         = keys[ 1 ]-fiscalyear
              billingdocument    = keys[ 1 ]-billingdocument
              %msg               = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = 'Record is locked by ' && foreign_lock->user_name
              )
          ) TO reported-hddt_headers.

        CATCH cx_abap_lock_failure INTO exception.
          RAISE SHORTDUMP exception.
*          APPEND VALUE #( %msg = new_message_with_text(
*                          severity = if_abap_behv_message=>severity-error
*                          text     = exception->get_text( ) ) )
*          TO reported-hddt_headers.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD rba_einvoiceitems.

  ENDMETHOD.

  METHOD adjust.

    TYPES: BEGIN OF ty_message,
             companycode        TYPE bukrs,
             accountingdocument TYPE belnr_d,
             fiscalyear         TYPE gjahr,
             billingdocument    TYPE zde_vbeln_vf,
             msgtype            TYPE sy-msgty,
             msgtext            TYPE string,
           END OF ty_message,
           tt_message TYPE TABLE OF ty_message.

    DATA: tt_return TYPE tt_message.
    FREE: tt_return.

    TRY.
        zcl_einvoice_process=>handle_adjust_einvoice_v2(
          EXPORTING
            keys     = keys
          CHANGING
            result   = result
            mapped   = mapped
            failed   = failed
            reported = reported
            e_return = tt_return
        ).
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    READ TABLE keys INDEX 1 INTO DATA(k).

    IF tt_return IS NOT INITIAL.
      LOOP AT tt_return INTO DATA(ls_return) WHERE msgtype = 'E' OR msgtype = 'W'.
        IF ls_return-msgtype = 'E'.
          INSERT VALUE #(
                 companycode        = ls_return-companycode
                 accountingdocument = ls_return-accountingdocument
                 fiscalyear         = ls_return-fiscalyear
                 billingdocument    = ls_return-billingdocument
                 %msg               = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = ls_return-msgtext )
                        ) INTO TABLE reported-hddt_headers.
        ELSEIF ls_return-msgtype = 'W'.
          INSERT VALUE #(
                 companycode        = ls_return-companycode
                 accountingdocument = ls_return-accountingdocument
                 fiscalyear         = ls_return-fiscalyear
                 billingdocument    = ls_return-billingdocument
                 %msg               = new_message_with_text( severity = if_abap_behv_message=>severity-warning
                                                             text     = ls_return-msgtext )
                        ) INTO TABLE reported-hddt_headers.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD integration.

    TYPES: BEGIN OF ty_message,
             companycode        TYPE bukrs,
             accountingdocument TYPE belnr_d,
             fiscalyear         TYPE gjahr,
             billingdocument    TYPE zde_vbeln_vf,
             msgtype            TYPE sy-msgty,
             msgtext            TYPE string,
           END OF ty_message,
           tt_message TYPE TABLE OF ty_message.

    DATA: tt_return TYPE tt_message.
    FREE: tt_return.

    TRY.
        zcl_einvoice_process=>handle_integration_einvoice(
          EXPORTING
            keys     = keys
          CHANGING
            result   = result
            mapped   = mapped
            failed   = failed
            reported = reported
            e_return = tt_return
        ).
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    IF tt_return IS NOT INITIAL.
      LOOP AT tt_return INTO DATA(ls_return) WHERE msgtype = 'E'.
        INSERT VALUE #(
               companycode        = ls_return-companycode
               accountingdocument = ls_return-accountingdocument
               fiscalyear         = ls_return-fiscalyear
               %msg               = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                           text     = ls_return-msgtext )
                      ) INTO TABLE reported-hddt_headers.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD search.

    TYPES: BEGIN OF ty_message,
             companycode        TYPE bukrs,
             accountingdocument TYPE belnr_d,
             fiscalyear         TYPE gjahr,
             billingdocument    TYPE zde_vbeln_vf,
             msgtype            TYPE sy-msgty,
             msgtext            TYPE string,
           END OF ty_message,
           tt_message TYPE TABLE OF ty_message.

    DATA: tt_return TYPE tt_message.
    FREE: tt_return.

    zcl_einvoice_process=>handle_search_einvoice(
      EXPORTING
        keys     = keys
      CHANGING
        result   = result
        mapped   = mapped
        failed   = failed
        reported = reported
        e_return = tt_return
    ).

    LOOP AT reported-hddt_headers ASSIGNING FIELD-SYMBOL(<fs_reported>).
      <fs_reported>-%msg = new_message_with_text(
        severity = if_abap_behv_message=>severity-success
        text     = |Đã cập nhật trạng thái| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD mapping.

    TYPES: BEGIN OF ty_message,
             companycode        TYPE bukrs,
             accountingdocument TYPE belnr_d,
             fiscalyear         TYPE gjahr,
             billingdocument    TYPE zde_vbeln_vf,
             msgtype            TYPE sy-msgty,
             msgtext            TYPE string,
           END OF ty_message,
           tt_message TYPE TABLE OF ty_message.

    DATA: tt_return TYPE tt_message.
    FREE: tt_return.

    TRY.
        zcl_einvoice_process=>handle_mapping_einvoice(
          EXPORTING
            keys     = keys
          CHANGING
            result   = result
            mapped   = mapped
            failed   = failed
            reported = reported
            e_return = tt_return
        ).
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    IF tt_return IS NOT INITIAL.
      LOOP AT tt_return INTO DATA(ls_return) WHERE msgtype = 'E' OR msgtype = 'W'.
        IF ls_return-msgtype = 'E'.
          INSERT VALUE #(
                 companycode        = ls_return-companycode
                 accountingdocument = ls_return-accountingdocument
                 fiscalyear         = ls_return-fiscalyear
                 %msg               = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = ls_return-msgtext )
                        ) INTO TABLE reported-hddt_headers.
        ELSEIF ls_return-msgtype = 'W'.
          INSERT VALUE #(
                 companycode        = ls_return-companycode
                 accountingdocument = ls_return-accountingdocument
                 fiscalyear         = ls_return-fiscalyear
                 %msg               = new_message_with_text( severity = if_abap_behv_message=>severity-warning
                                                             text     = ls_return-msgtext )
                        ) INTO TABLE reported-hddt_headers.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD getdefaultsfor_systemdate_adj.
    DATA: ls_result LIKE LINE OF result.
    READ TABLE keys INDEX 1 INTO DATA(k).

    ls_result-%tky = k-%tky.

    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).

    SELECT SINGLE * FROM zjp_a_hddt_h
    WHERE companycode           = @k-%key-companycode
        AND accountingdocument  = @k-%key-accountingdocument
        AND billingdocument     = @k-%key-billingdocument
        AND fiscalyear          = @k-%key-fiscalyear
    INTO @DATA(ls_a_hddt_h).
    IF ls_a_hddt_h-fiscalyearsource IS NOT INITIAL.
      ls_result-%param-gjahrsource = ls_a_hddt_h-fiscalyearsource.
    ELSE.
      ls_result-%param-gjahrsource = lv_date+0(4).
    ENDIF.

    INSERT CORRESPONDING #( ls_result ) INTO TABLE result.
  ENDMETHOD.

  METHOD previewdraft.

    TYPES: BEGIN OF ty_message,
             companycode        TYPE bukrs,
             accountingdocument TYPE belnr_d,
             fiscalyear         TYPE gjahr,
             billingdocument    TYPE zde_vbeln_vf,
             msgtype            TYPE sy-msgty,
             msgtext            TYPE string,
           END OF ty_message,
           tt_message TYPE TABLE OF ty_message.

    DATA: tt_return TYPE tt_message.
    FREE: tt_return.

    zcl_einvoice_process=>handle_preview_draft(
      EXPORTING
        keys     = keys
      CHANGING
        result   = result
        mapped   = mapped
        failed   = failed
        reported = reported
        e_return = tt_return
    ).

    IF tt_return IS NOT INITIAL.
      LOOP AT tt_return INTO DATA(ls_return) WHERE msgtype = 'E' OR msgtype = 'W'.
        IF ls_return-msgtype = 'E'.
          INSERT VALUE #(
                 companycode        = ls_return-companycode
                 accountingdocument = ls_return-accountingdocument
                 fiscalyear         = ls_return-fiscalyear
                 %msg               = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = ls_return-msgtext )
                        ) INTO TABLE reported-hddt_headers.
        ELSEIF ls_return-msgtype = 'W'.
          INSERT VALUE #(
                 companycode        = ls_return-companycode
                 accountingdocument = ls_return-accountingdocument
                 fiscalyear         = ls_return-fiscalyear
                 %msg               = new_message_with_text( severity = if_abap_behv_message=>severity-warning
                                                             text     = ls_return-msgtext )
                        ) INTO TABLE reported-hddt_headers.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD getjson.

    TYPES: BEGIN OF ty_message,
             companycode        TYPE bukrs,
             accountingdocument TYPE belnr_d,
             fiscalyear         TYPE gjahr,
             billingdocument    TYPE zde_vbeln_vf,
             msgtype            TYPE sy-msgty,
             msgtext            TYPE string,
           END OF ty_message,
           tt_message TYPE TABLE OF ty_message.

    DATA: tt_return TYPE tt_message.
    FREE: tt_return.

    zcl_einvoice_process=>handle_get_json(
      EXPORTING
        keys     = keys
      CHANGING
        result   = result
        mapped   = mapped
        failed   = failed
        reported = reported
        e_return = tt_return
    ).

    IF tt_return IS NOT INITIAL.
      LOOP AT tt_return INTO DATA(ls_return) WHERE msgtype = 'E' OR msgtype = 'W'.
        IF ls_return-msgtype = 'E'.
          INSERT VALUE #(
                 companycode        = ls_return-companycode
                 accountingdocument = ls_return-accountingdocument
                 fiscalyear         = ls_return-fiscalyear
                 %msg               = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = ls_return-msgtext )
                        ) INTO TABLE reported-hddt_headers.
        ELSEIF ls_return-msgtype = 'W'.
          INSERT VALUE #(
                 companycode        = ls_return-companycode
                 accountingdocument = ls_return-accountingdocument
                 fiscalyear         = ls_return-fiscalyear
                 %msg               = new_message_with_text( severity = if_abap_behv_message=>severity-warning
                                                             text     = ls_return-msgtext )
                        ) INTO TABLE reported-hddt_headers.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_hddt_items DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ hddt_items RESULT result.

    METHODS rba_einvoicesheaders FOR READ
      IMPORTING keys_rba FOR READ hddt_items\_einvoicesheaders FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_hddt_items IMPLEMENTATION.

  METHOD read.
    zcl_einvoice_process=>read_items(
      EXPORTING
        keys     = keys
      CHANGING
        result   = result
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD rba_einvoicesheaders.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zjp_c_hddt_h DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zjp_c_hddt_h IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    zcl_einvoice_process=>save_einvoice(
      CHANGING
        reported = reported
    ).

  ENDMETHOD.

  METHOD cleanup.

    zcl_einvoice_process=>cleanup( ).

  ENDMETHOD.

  METHOD cleanup_finalize.

    zcl_einvoice_process=>cleanup( ).

  ENDMETHOD.

ENDCLASS.

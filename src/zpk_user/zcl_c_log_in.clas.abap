CLASS zcl_c_log_in DEFINITION
   PUBLIC
  INHERITING FROM cx_rap_query_provider
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_ranges TYPE TABLE OF ty_range_option.

    CLASS-DATA:
                 mo_instance    TYPE REF TO zcl_c_log_in.

    CLASS-METHODS:
      "Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_c_log_in.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_C_LOG_IN IMPLEMENTATION.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD if_rap_query_provider~select.

    DATA: ls_page_info   TYPE zcl_jp_common_core=>st_page_info
          .

    TRY.

        DATA(lo_common_app) = zcl_jp_common_core=>get_instance( ).

        lo_common_app->get_fillter_app(
            EXPORTING
                io_request  = io_request
                io_response = io_response
            IMPORTING
                wa_page_info          = ls_page_info
        ).
        TRY.
            DATA(lr_ranges) = ls_page_info-ro_filter->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range.
            "handle exception
        ENDTRY.

        DATA(lv_username) = io_request->get_parameters(  ).

        READ TABLE lr_ranges WITH KEY  name = 'USER_NAME' INTO DATA(ls_ranges).
        IF sy-subrc IS INITIAL.
          READ TABLE ls_ranges-range INDEX 1 INTO DATA(ls_USERNAMEr).
        ENDIF.

        READ TABLE lr_ranges WITH KEY  name = 'PASSWORD' INTO ls_ranges.
        IF sy-subrc IS INITIAL.
          READ TABLE ls_ranges-range INDEX 1 INTO DATA(ls_PASSo).
        ENDIF.

        DATA: lt_data          TYPE TABLE OF zc_login,
              ls_authorization TYPE zst_authorization,
              lt_authorization TYPE TABLE OF zst_authorization.

        APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<lf_data>).
        SELECT SINGLE * FROM ztb_user
                   WHERE zuser = @ls_USERNAMEr-low
          AND password = @ls_PASSo-low
           INTO @DATA(ls_user).
        IF sy-subrc IS NOT INITIAL.
          <lf_data>-status = 'E'.
          <lf_data>-message = 'Sai user/password'.
        ELSE.
          <lf_data>-status = 'S'.
          <lf_data>-message = 'Đăng nhập thành công'.

          SELECT * FROM ztb_user_role
          WHERE id = @ls_user-id
          INTO TABLE @DATA(lt_user_roles).
          IF lt_user_roles[] IS NOT INITIAL.
            SELECT * FROM ztb_roles
                FOR ALL ENTRIES IN @lt_user_roles
                WHERE zrole = @lt_user_roles-zrole
                INTO TABLE @DATA(lt_roles).
            IF lt_roles[] IS NOT INITIAL.
              SELECT * FROM ztb_roles_data
                  FOR ALL ENTRIES IN   @lt_roles
                  WHERE id = @lt_roles-id
                  INTO TABLE @DATA(lt_roles_data).
              SELECT * FROM ztb_roles_func
                  FOR ALL ENTRIES IN   @lt_roles
                  WHERE id = @lt_roles-id
                  INTO TABLE @DATA(lt_roles_fun).
            ENDIF.
          ENDIF.

         SORT lt_roles_data by werks lgort workcenter lgnum.
          DATA(lt_roles_tmp) = lt_roles[].
          SORT lt_roles_tmp BY zapp.
          DELETE ADJACENT DUPLICATES FROM lt_roles_tmp COMPARING zapp.
          LOOP AT lt_roles_tmp INTO DATA(ls_roles_tmp).
            ls_authorization-app =  ls_roles_tmp-zapp.
            ls_authorization-descript = ls_roles_tmp-zdesc.
            LOOP AT lt_roles INTO DATA(ls_roles) WHERE zapp = ls_roles_tmp-zapp.
              LOOP AT lt_roles_data INTO DATA(ls_roles_data) WHERE id = ls_roles-id.
                APPEND INITIAL LINE TO ls_authorization-data ASSIGNING FIELD-SYMBOL(<lf_roles_data>).
                <lf_roles_data>-workcenter = ls_roles_data-workcenter.
                <lf_roles_data>-ewmwarehouse = ls_roles_data-lgnum.
                <lf_roles_data>-storagelocation = ls_roles_data-lgort.
                <lf_roles_data>-plant = ls_roles_data-werks.
                SELECT SINGLE PlantName FROM I_Plant
                    WHERE Plant = @ls_roles_data-werks
                    INTO @<lf_roles_data>-plantname.
                SELECT SINGLE WorkCenterText
                   FROM I_WorkCenterText INNER JOIN i_workcenter
                 ON I_WorkCenterText~WorkCenterInternalID = i_workcenter~WorkCenterInternalID
                   WHERE i_workcenter~WorkCenter = @ls_roles_data-workcenter
                   INTO @<lf_roles_data>-workcentername.
                SELECT SINGLE StorageLocationName
                FROM I_StorageLocation
                  WHERE storagelocation = @ls_roles_data-lgort
                  AND Plant = @ls_roles_data-werks
                  INTO @<lf_roles_data>-storagelocationname.
              ENDLOOP.
              LOOP AT lt_roles_fun INTO DATA(ls_roles_fun) WHERE id = ls_roles-id.
                APPEND INITIAL LINE TO ls_authorization-function ASSIGNING FIELD-SYMBOL(<lf_roles_fun>).
                <lf_roles_fun>-function = ls_roles_fun-zfunc.
                <lf_roles_fun>-descript = ''.
              ENDLOOP.
            ENDLOOP.
            SORT ls_authorization-function BY function.
            DELETE ADJACENT DUPLICATES FROM ls_authorization-function COMPARING function.
          ENDLOOP.

          DATA(lw_json_body) = /ui2/cl_json=>serialize(
                     data = ls_authorization
                     compress = abap_true
                     pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

          DATA(lo_conv) = cl_abap_conv_codepage=>create_out(
                  codepage    = 'UTF-8'
                  replacement_char = '?'
                    ).

          DATA(lv_xstring) = lo_conv->convert( source = lw_json_body ).

*          DATA(lo_conv_to) = cl_abap_conv_codepage=>create_out(
*                     codepage = 'UTF-8' ).
*
*          DATA(lv_json_xstring) = lo_conv_to->convert( source = lw_json_body ).

          DATA(lv_utf8) =  cl_web_http_utility=>encode_utf8(  lw_json_body ).
          DATA(lv_base64) =  cl_web_http_utility=>encode_x_base64(  lv_utf8 ).
*             XCO_CP=>xstring( lw_json_body ).
*          DATA(ld_xstring) = xco_cp=>string( lw_json_body )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.
*          DATA(ld_xstring) = cl_abap_codepage=>convert_to( source = lw_json_body ).
          <lf_data>-authorizations    =  lv_base64.
        ENDIF.
        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        IF io_request->is_data_requested( ).
          io_response->set_data( lt_data ).
        ENDIF.

      CATCH cx_root INTO DATA(exception).

        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

        RAISE EXCEPTION TYPE zcl_c_log_in
          EXPORTING
            textid   = VALUE scx_t100key(
            msgid = exception_t100_key-msgid
            msgno = exception_t100_key-msgno
            attr1 = exception_t100_key-attr1
            attr2 = exception_t100_key-attr2
            attr3 = exception_t100_key-attr3
            attr4 = exception_t100_key-attr4 )
            previous = exception.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

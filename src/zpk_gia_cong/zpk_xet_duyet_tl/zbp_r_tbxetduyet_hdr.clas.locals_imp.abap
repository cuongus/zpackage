CLASS lhc_zrtbxetduyetdtl DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZrTbxetduyetDtl RESULT result.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zrtbxetduyetdtl RESULT result.

    METHODS update_tyle_dtl FOR MODIFY
      IMPORTING keys FOR ACTION zrtbxetduyetdtl~update_tyle_dtl RESULT result.

ENDCLASS.

CLASS lhc_zrtbxetduyetdtl IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zr_tbxetduyet_hdr IN LOCAL MODE
            ENTITY ZrTbxetduyetHdr
               FIELDS (  Trangthai )
               WITH CORRESPONDING #( keys )
             RESULT DATA(lt_read_data)
             FAILED failed.
    READ ENTITIES OF zr_tbxetduyet_hdr IN LOCAL MODE
            ENTITY ZrTbxetduyetDtl
               FIELDS (  DtlID )
               WITH CORRESPONDING #( keys )
             RESULT DATA(lt_read_data_dtl)
             FAILED failed.
    READ TABLE lt_read_data INTO DATA(ls_data_hdr) INDEX 1.

    result = VALUE #( FOR ls_read_data_dtl IN lt_read_data_dtl
                   ( %tky                           = ls_read_data_dtl-%tky

                     %features-%update = COND #( WHEN ls_data_hdr-Trangthai > '0'
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                     %features-%delete = COND #( WHEN ls_data_hdr-Trangthai > '0'
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                     %features-%action-update_tyle_dtl = COND #( WHEN ls_data_hdr-Trangthai > '0' OR ls_data_hdr-%is_draft = if_abap_behv=>mk-on
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )

                  ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD update_tyle_dtl.
    DATA: ls_update TYPE STRUCTURE FOR UPDATE zr_tbxetduyet_dtl,
          lt_update TYPE TABLE FOR UPDATE zr_tbxetduyet_dtl.
    DATA: lw_tyle_str TYPE zde_char10.
    READ TABLE keys INTO DATA(ls_keys) INDEX 1.
    READ ENTITIES OF zr_tbxetduyet_hdr IN LOCAL MODE
       ENTITY ZrTbxetduyetDtl
       ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(ZrTbxetduyetDTL).

    LOOP AT ZrTbxetduyetDTL INTO DATA(ls_dtl).

      ls_update-HdrID = ls_dtl-HdrID.
      ls_update-DtlID = ls_dtl-DtlID.

      lw_tyle_str = ls_keys-%param-ct411.
      IF lw_tyle_str IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
        ls_update-Ct411 = lw_tyle_str.
      ELSE.
        ls_update-Ct411 = ls_dtl-Ct411.
      ENDIF.

      lw_tyle_str = ls_keys-%param-ct421.
      IF lw_tyle_str IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
        ls_update-ct421 = lw_tyle_str.
      ELSE.
        ls_update-ct421 = ls_dtl-ct421.
      ENDIF.

      lw_tyle_str = ls_keys-%param-Ct431.
      IF lw_tyle_str IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
        ls_update-Ct431 = lw_tyle_str.
      ELSE.
        ls_update-Ct431 = ls_dtl-Ct431.
      ENDIF.

      lw_tyle_str = ls_keys-%param-Ct441.
      IF lw_tyle_str IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
        ls_update-Ct441 = lw_tyle_str.
      ELSE.
        ls_update-Ct441 = ls_dtl-Ct441.
      ENDIF.

      lw_tyle_str = ls_keys-%param-Ct451.
      IF lw_tyle_str IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
        ls_update-Ct451 = lw_tyle_str.
      ELSE.
        ls_update-Ct451 = ls_dtl-Ct451.
      ENDIF.

      lw_tyle_str = ls_keys-%param-Ct461.
      IF lw_tyle_str IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
        ls_update-Ct461 = lw_tyle_str.
      ELSE.
        ls_update-Ct461 = ls_dtl-Ct461.
      ENDIF.

      lw_tyle_str = ls_keys-%param-Ct471.
      IF lw_tyle_str IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
        ls_update-Ct471 = lw_tyle_str.
      ELSE.
        ls_update-Ct471 = ls_dtl-Ct471.
      ENDIF.

      lw_tyle_str = ls_keys-%param-Ct481.
      IF lw_tyle_str IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
        ls_update-Ct481 = lw_tyle_str.
      ELSE.
        ls_update-Ct481 = ls_dtl-Ct481.
      ENDIF.

      lw_tyle_str = ls_keys-%param-Ct491.
      IF lw_tyle_str IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
        ls_update-Ct491 = lw_tyle_str.
      ELSE.
        ls_update-Ct491 = ls_dtl-Ct491.
      ENDIF.

      lw_tyle_str = ls_keys-%param-Ct501.
      IF lw_tyle_str IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
        ls_update-Ct501 = lw_tyle_str.
      ELSE.
        ls_update-Ct501 = ls_dtl-Ct501.
      ENDIF.

      INSERT ls_update INTO TABLE lt_update.
    ENDLOOP.
    IF lt_update IS NOT INITIAL.
      "Register the action
      MODIFY ENTITIES OF zr_tbxetduyet_hdr IN LOCAL MODE
      ENTITY ZrTbxetduyetDtl
      UPDATE FIELDS ( ct411 ct421 ct431 ct441 ct451 ct461 ct471 ct481 ct491 ct501 )
      WITH lt_update
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported)
      MAPPED DATA(ls_mapped).
    ENDIF.
    CLEAR: lt_update.

    "return result entities
    result = VALUE #( FOR ls_for IN zrtbxetduyetdtl ( %tky   = ls_for-%tky
                                                  %param = ls_for ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_tbxetduyet_hdr DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zr_tbxetduyet_hdr IMPLEMENTATION.

  METHOD save_modified.
    DATA : lt_hdr TYPE STANDARD TABLE OF ztb_xetduyet_hdr,
           ls_hdr TYPE                   ztb_xetduyet_hdr.

    DATA : lt_dtl TYPE STANDARD TABLE OF ztb_xetduyet_dtl,
           ls_dtl TYPE                   ztb_xetduyet_dtl.

    DATA: lw_dat      TYPE zde_date,
          lw_datetime TYPE abp_locinst_lastchange_tstmpl.



    TYPES: BEGIN OF ty_mapping,
             field_ent TYPE string,
             field_db  TYPE string,
           END OF ty_mapping.
    DATA: lw_field_name TYPE char72.
    DATA: gt_mapping TYPE STANDARD TABLE OF ty_mapping WITH DEFAULT KEY.

    "Insert các cặp mapping
    APPEND VALUE #( field_ent = 'HdrID'         field_db = 'hdr_id' )         TO gt_mapping.
    APPEND VALUE #( field_ent = 'LoaiHang'      field_db = 'loai_hang' )     TO gt_mapping.
    APPEND VALUE #( field_ent = 'Zper'          field_db = 'zper' )          TO gt_mapping.
    APPEND VALUE #( field_ent = 'Ct05'          field_db = 'ct05' )          TO gt_mapping.
    APPEND VALUE #( field_ent = 'Zperdesc'      field_db = 'zperdesc' )      TO gt_mapping.
    APPEND VALUE #( field_ent = 'Zstatus'       field_db = 'zstatus' )       TO gt_mapping.
    APPEND VALUE #( field_ent = 'CreatedBy'     field_db = 'created_by' )    TO gt_mapping.
    APPEND VALUE #( field_ent = 'CreatedAt'     field_db = 'created_at' )    TO gt_mapping.
    APPEND VALUE #( field_ent = 'LastChangedBy' field_db = 'last_changed_by' ) TO gt_mapping.
    APPEND VALUE #( field_ent = 'LastChangedAt' field_db = 'last_changed_at' ) TO gt_mapping.

    LOOP AT gt_mapping ASSIGNING FIELD-SYMBOL(<fs_mapping>).
      TRANSLATE <fs_mapping>-field_ent TO UPPER CASE.
      TRANSLATE <fs_mapping>-field_db TO UPPER CASE.
    ENDLOOP.
    DATA: gt_mapping_dtl TYPE STANDARD TABLE OF ty_mapping WITH DEFAULT KEY.

    APPEND VALUE #( field_ent = 'CreatedBy'     field_db = 'created_by' )    TO gt_mapping_dtl.
    APPEND VALUE #( field_ent = 'CreatedAt'     field_db = 'created_at' )    TO gt_mapping_dtl.
    APPEND VALUE #( field_ent = 'LastChangedBy' field_db = 'last_changed_by' ) TO gt_mapping_dtl.
    APPEND VALUE #( field_ent = 'LastChangedAt' field_db = 'last_changed_at' ) TO gt_mapping_dtl.

    LOOP AT gt_mapping_dtl ASSIGNING  <fs_mapping>.
      TRANSLATE <fs_mapping>-field_ent TO UPPER CASE.
      TRANSLATE <fs_mapping>-field_db TO UPPER CASE.
    ENDLOOP.

    IF create-zrtbxetduyethdr IS NOT INITIAL.
      lt_hdr = CORRESPONDING #( create-zrtbxetduyethdr MAPPING FROM ENTITY ).
      LOOP AT lt_hdr INTO ls_hdr.
        lw_dat = xco_cp=>sy->moment( xco_cp_time=>time_zone->user )->date->as( xco_cp_time=>format->abap )->value.
        ls_hdr-sumdate = lw_dat.
*        GET TIME STAMP FIELD lw_datetime  .
        CONVERT DATE cl_abap_context_info=>get_system_date( ) TIME cl_abap_context_info=>get_system_time( )
        INTO TIME STAMP lw_datetime TIME ZONE 'UTC-7'.
        ls_hdr-sumdatetime = lw_datetime.
        SELECT SINGLE * FROM zr_tbperiod
          WHERE Zper = @ls_hdr-zper
          INTO  @DATA(ls_tbperiod).
        IF sy-subrc = 0.
          ls_hdr-zperdesc = ls_tbperiod-Zdesc.
        ENDIF.
        CALL METHOD zcl_gia_cong=>get_xet_duyet
          EXPORTING
            i_xetduyet_hdr  = ls_hdr
          IMPORTING
            e_xet_duyet_dtl = lt_dtl
            e_t_xd_dtl1 = DATA(lt_xd_dtl1_cr).

        INSERT ztb_xetduyet_hdr FROM @ls_hdr.
        INSERT ztb_xetduyet_dtl FROM TABLE @lt_dtl.
        INSERT ztb_xd_dtl1 FROM TABLE @lt_xd_dtl1_cr.
      ENDLOOP.
    ENDIF.

    LOOP AT delete-zrtbxetduyethdr INTO DATA(ls_detele)." WHERE HdrID IS NOT INITIAL.
      DELETE FROM ztb_xetduyet_hdr WHERE hdr_id = @ls_detele-HdrID.
    ENDLOOP.

    IF create-zrtbxetduyetdtl IS NOT INITIAL.
*      lt_dtl = CORRESPONDING #( create-zrtbxetduyetdtl MAPPING FROM ENTITY ).
*      INSERT ztb_xetduyet_dtl FROM TABLE @lt_dtl.
    ENDIF.

    LOOP AT delete-zrtbxetduyetdtl INTO DATA(ls_detele_dtl)." WHERE HdrID IS NOT INITIAL AND DtlID IS NOT INITIAL.
      DELETE FROM ztb_xetduyet_dtl WHERE hdr_id = @ls_detele_dtl-HdrID AND dtl_id = @ls_detele_dtl-DtlID.
      DELETE from ztb_xd_dtl1 WHERE hdr_id = @ls_detele_dtl-HdrID AND dtl_id = @ls_detele_dtl-DtlID.
    ENDLOOP.

    DATA update_struct TYPE REF TO cl_abap_structdescr.
    IF update-zrtbxetduyethdr IS NOT INITIAL.
      LOOP AT update-zrtbxetduyethdr INTO DATA(ls_zrtbxetduyethdr).
        IF ls_zrtbxetduyethdr-%control-Sumdate = if_abap_behv=>mk-on.
          SELECT SINGLE *
              FROM ztb_xetduyet_hdr WHERE hdr_id = @ls_zrtbxetduyethdr-HdrID INTO @ls_hdr.
          IF sy-subrc IS INITIAL.
            ls_hdr-sumdate = ls_zrtbxetduyethdr-Sumdate.
            ls_hdr-sumdatetime = ls_zrtbxetduyethdr-SumDateTime.
            CALL METHOD zcl_gia_cong=>get_xet_duyet
              EXPORTING
                i_xetduyet_hdr  = ls_hdr
              IMPORTING
                e_xet_duyet_dtl = lt_dtl
                e_t_xd_dtl1 = Data(lt_xd_dtl1).
            SELECT * FROM ztb_xetduyet_dtl
              WHERE hdr_id = @ls_hdr-hdr_id
              INTO TABLE @DATA(lt_existing_dtl).
            LOOP AT lt_existing_dtl INTO DATA(ls_existing_dtl).
              READ TABLE lt_dtl INTO DATA(ls_new_dtl)
                WITH KEY dtl_id = ls_existing_dtl-dtl_id.
              IF sy-subrc IS NOT INITIAL.
                DELETE FROM ztb_xetduyet_dtl WHERE hdr_id = @ls_hdr-hdr_id AND dtl_id = @ls_existing_dtl-dtl_id.
              ENDIF.
            ENDLOOP.
            select * from ztb_xd_dtl1
                WHERE hdr_id = @ls_hdr-hdr_id INTO TABLE @DATA(lt_xd_dtl1_db).
            LOOP AT lt_xd_dtl1 INTO DATA(ls_xd_dtl1_db).
              READ TABLE lt_xd_dtl1 INTO DATA(ls_xd_dtl1)
                WITH KEY dtl_id = ls_xd_dtl1_db-dtl_id.
              IF sy-subrc IS NOT INITIAL.
                DELETE FROM ztb_xd_dtl1 WHERE hdr_id = @ls_hdr-hdr_id AND dtl_id = @ls_xd_dtl1_db-dtl_id
                and bbgc_hdrid = @ls_xd_dtl1_db-bbgc_hdrid.
              ENDIF.
            ENDLOOP.
            MODIFY ztb_xd_dtl1 from TABLE @lt_xd_dtl1.
            MODIFY ztb_xetduyet_hdr FROM @ls_hdr.
            MODIFY ztb_xetduyet_dtl FROM TABLE @lt_dtl.
          ENDIF.
        ELSE.
          SELECT SINGLE * FROM ztb_xetduyet_hdr
           WHERE hdr_id = @ls_zrtbxetduyethdr-HdrID
           INTO @DATA(ls_xetduyet_hdr).
          IF sy-subrc IS INITIAL.
            SELECT * FROM ztb_xetduyet_dtl
              WHERE hdr_id = @ls_zrtbxetduyethdr-HdrID
              INTO TABLE @DATA(lt_xetduyet_dtl).
            update_struct ?= cl_abap_structdescr=>describe_by_data( ls_zrtbxetduyethdr-%control ).
            LOOP AT update_struct->components INTO DATA(field).
              IF ls_zrtbxetduyethdr-%control-(field-name) = if_abap_behv=>mk-on.
                READ TABLE gt_mapping ASSIGNING <fs_mapping>
                    WITH KEY field_ent = field-name.
                IF sy-subrc IS INITIAL.
                  lw_field_name = <fs_mapping>-field_db.
                ELSE.
                  lw_field_name = field-name.
                ENDIF.
                ls_xetduyet_hdr-(lw_field_name) = ls_zrtbxetduyethdr-(field-name).

              ENDIF.
            ENDLOOP.

            FREE update_struct.

            LOOP AT lt_xetduyet_dtl ASSIGNING FIELD-SYMBOL(<lf_dtl>).
              <lf_dtl>-ct05 = ls_xetduyet_hdr-ct05.
              IF <lf_dtl>-ct05 = 0.
                <lf_dtl>-ct06 = 0.
              ELSE.
                <lf_dtl>-ct06 = <lf_dtl>-ct04 / <lf_dtl>-ct05.
              ENDIF.
            ENDLOOP.
            MODIFY ztb_xetduyet_hdr FROM @ls_xetduyet_hdr.
            MODIFY ztb_xetduyet_dtl FROM TABLE @lt_xetduyet_dtl.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF update-zrtbxetduyetdtl IS NOT INITIAL.
      LOOP AT update-zrtbxetduyetdtl INTO DATA(ls_zrtbxetduyetdtlr).

        SELECT SINGLE * FROM ztb_xetduyet_dtl
          WHERE hdr_id = @ls_zrtbxetduyetdtlr-HdrID AND dtl_id = @ls_zrtbxetduyetdtlr-DtlID
          INTO @ls_dtl.
        IF sy-subrc IS INITIAL.
          update_struct ?= cl_abap_structdescr=>describe_by_data( ls_zrtbxetduyetdtlr-%control ).
          LOOP AT update_struct->components INTO field.
            IF ls_zrtbxetduyetdtlr-%control-(field-name) = if_abap_behv=>mk-on.
              READ TABLE gt_mapping_dtl ASSIGNING <fs_mapping>
                  WITH KEY field_ent = field-name.
              IF sy-subrc IS INITIAL.
                lw_field_name = <fs_mapping>-field_db.
              ELSE.
                lw_field_name = field-name.
              ENDIF.
              ls_dtl-(lw_field_name) = ls_zrtbxetduyetdtlr-(field-name).

            ENDIF.
          ENDLOOP.
          DATA: lt_xd_dtl1_ud TYPE STANDARD TABLE OF ztb_xd_dtl1.
          select * from ztb_xd_dtl1
              WHERE hdr_id = @ls_dtl-hdr_id AND dtl_id = @ls_dtl-dtl_id
              INTO TABLE @lt_xd_dtl1_ud.
          CALL METHOD zcl_gia_cong=>update_xet_duyet_dtl
            CHANGING
              c_xet_duyet_dtl = ls_dtl
              c_t_xd_dtl1 = lt_xd_dtl1_ud.

          FREE update_struct.
          MODIFY ztb_xd_dtl1 from table @lt_xd_dtl1_ud.
          MODIFY ztb_xetduyet_dtl FROM @ls_dtl.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_zr_tbxetduyet_hdr DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrTbxetduyetHdr
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR  ZrTbxetduyetHdr RESULT result,
      checkInputFields_Save FOR VALIDATE ON SAVE
        IMPORTING keys FOR ZrTbxetduyetHdr~checkInputFields_Save,
      UpdateData FOR MODIFY
        IMPORTING keys FOR ACTION ZrTbxetduyetHdr~UpdateData RESULT result,
      PheDuyet FOR MODIFY
        IMPORTING keys FOR ACTION ZrTbxetduyetHdr~PheDuyet RESULT result,
      HuyPheDuyet FOR MODIFY
        IMPORTING keys FOR ACTION ZrTbxetduyetHdr~HuyPheDuyet RESULT result,
      update_tyle FOR MODIFY
        IMPORTING keys FOR ACTION ZrTbxetduyetHdr~update_tyle RESULT result.

ENDCLASS.

CLASS lhc_zr_tbxetduyet_hdr IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zr_tbxetduyet_hdr IN LOCAL MODE
        ENTITY ZrTbxetduyetHdr
           FIELDS (  Trangthai )
           WITH CORRESPONDING #( keys )
         RESULT DATA(lt_read_data)
         FAILED failed.

    result = VALUE #( FOR ls_data_for IN lt_read_data
                   ( %tky                           = ls_data_for-%tky
*                     %features-%field-trangthai = if_abap_behv=>fc-f-read_only
                     %features-%action-PheDuyet = COND #( WHEN ls_data_for-Trangthai > '0' OR ls_data_for-%is_draft = if_abap_behv=>mk-on
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                     %features-%action-HuyPheDuyet = COND #( WHEN ls_data_for-Trangthai <> '1' OR ls_data_for-%is_draft = if_abap_behv=>mk-on
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                     %features-%action-UpdateData = COND #( WHEN ls_data_for-Trangthai > '0' OR ls_data_for-%is_draft = if_abap_behv=>mk-on
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                     %features-%update = COND #( WHEN ls_data_for-Trangthai > '0'
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                     %features-%delete = COND #( WHEN ls_data_for-Trangthai > '0'
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                      %features-%action-update_tyle = COND #( WHEN ls_data_for-Trangthai > '0' OR ls_data_for-%is_draft = if_abap_behv=>mk-on
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )

                  ) ).

  ENDMETHOD.

  METHOD checkInputFields_Save.
    READ ENTITIES OF zr_tbxetduyet_hdr IN LOCAL MODE
        ENTITY ZrTbxetduyetHdr
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(ZrTbxetduyetHdr).

    LOOP AT ZrTbxetduyetHdr INTO DATA(ls_hdr).
      APPEND VALUE #(  %tky           = ls_hdr-%tky
                    %state_area    = 'CHECK'
                  ) TO reported-ZrTbxetduyetHdr.
      IF ls_hdr-ngaylapbang IS INITIAL.
        APPEND VALUE #(  %tky = ls_hdr-%tky ) TO failed-zrtbxetduyethdr.
        APPEND VALUE #( %tky          = ls_hdr-%tky
                        %state_area   = 'CHECK'
                        %msg          = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Nhập ngày lập bảng' )
                        %element-ngaylapbang = if_abap_behv=>mk-on
                      ) TO reported-zrtbxetduyethdr.
      ENDIF.

      SELECT SINGLE * FROM I_CompanyCodeStdVH
        WHERE CompanyCode = @ls_hdr-Bukrs
        INTO @DATA(ls_CompanyCode).
      IF sy-subrc IS NOT INITIAL.
        APPEND VALUE #(  %tky = ls_hdr-%tky ) TO failed-zrtbxetduyethdr.
        APPEND VALUE #( %tky          = ls_hdr-%tky
                        %state_area   = 'CHECK'
                        %msg          = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Company code không đúng' )
                        %element-Zper = if_abap_behv=>mk-on
                      ) TO reported-zrtbxetduyethdr.
      ENDIF.

      SELECT SINGLE * FROM zvi_period
        WHERE Zper = @ls_hdr-Zper
        INTO @DATA(ls_per).
      IF sy-subrc IS NOT INITIAL.
        APPEND VALUE #(  %tky = ls_hdr-%tky ) TO failed-zrtbxetduyethdr.
        APPEND VALUE #( %tky          = ls_hdr-%tky
                        %state_area   = 'CHECK'
                        %msg          = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Kỳ không tồn tại' )
                        %element-Zper = if_abap_behv=>mk-on
                      ) TO reported-zrtbxetduyethdr.
      ENDIF.

      SELECT SINGLE *
        FROM ztb_xetduyet_hdr WHERE zper = @ls_hdr-Zper
        AND bukrs = @ls_hdr-Bukrs AND lan = @ls_hdr-lan AND hdr_id <> @ls_hdr-hdrid
        INTO @DATA(ls_xetduyet_hdr).
      IF sy-subrc IS INITIAL.
        APPEND VALUE #(  %tky = ls_hdr-%tky ) TO failed-zrtbxetduyethdr.
        APPEND VALUE #( %tky          = ls_hdr-%tky
                        %state_area   = 'CHECK'
                        %msg          = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = `Đã tồn tại bảng xét duyệt này trong kỳ` )
                        %element-Zper = if_abap_behv=>mk-on
                      ) TO reported-zrtbxetduyethdr.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD UpdateData.
    DATA : lt_dtl TYPE STANDARD TABLE OF ztb_xetduyet_dtl,
           ls_hdr TYPE                   ztb_xetduyet_hdr.
    DATA: lw_dat      TYPE zde_date,
          lw_datetime TYPE abp_locinst_lastchange_tstmpl.

    lw_dat = xco_cp=>sy->moment( xco_cp_time=>time_zone->user )->date->as( xco_cp_time=>format->abap )->value.
*    GET TIME STAMP FIELD lw_datetime.
    CONVERT DATE cl_abap_context_info=>get_system_date( ) TIME cl_abap_context_info=>get_system_time( )
        INTO TIME STAMP lw_datetime TIME ZONE 'UTC-7'.
    READ ENTITIES OF zr_tbxetduyet_hdr IN LOCAL MODE
     ENTITY ZrTbxetduyetHdr
     ALL FIELDS
     WITH CORRESPONDING #( keys )
     RESULT DATA(ZrTbxetduyetHdr).

    LOOP AT ZrTbxetduyetHdr INTO DATA(ls_ZrTbxetduyetHdr).
      ls_hdr = CORRESPONDING #( ls_ZrTbxetduyetHdr MAPPING FROM ENTITY ).
      MODIFY ENTITIES OF zr_tbxetduyet_hdr IN LOCAL MODE
    ENTITY ZrTbxetduyetHdr
      UPDATE FIELDS ( sumdate  SumDateTime )
      WITH VALUE #(
        ( %tky = ls_ZrTbxetduyetHdr-%tky
          sumdate =  lw_dat
          SumDateTime = lw_datetime ) ).
    ENDLOOP.

    "return result entities
    result = VALUE #( FOR xetduyetHdr IN ZrTbxetduyetHdr ( %tky   = xetduyetHdr-%tky
                                                  %param = xetduyetHdr ) ).

  ENDMETHOD.

  METHOD PheDuyet.

    READ ENTITIES OF zr_tbxetduyet_hdr IN LOCAL MODE
     ENTITY ZrTbxetduyetHdr
     ALL FIELDS
     WITH CORRESPONDING #( keys )
     RESULT DATA(ZrTbxetduyetHdr).

    LOOP AT ZrTbxetduyetHdr INTO DATA(ls_ZrTbxetduyetHdr) WHERE trangthai = '0'.

      DATA ls_PheDuyet TYPE STRUCTURE FOR ACTION IMPORT zr_tbdcgc_hdr~PheDuyet.
      DATA lt_PheDuyet TYPE TABLE FOR ACTION IMPORT zr_tbdcgc_hdr~PheDuyet.

      SELECT * FROM ztb_dcgc_hdr
          WHERE bukrs = @ls_ZrTbxetduyetHdr-Bukrs AND zper = @ls_ZrTbxetduyetHdr-Zper
          AND lan = @ls_ZrTbxetduyetHdr-Lan AND trangthai = '0'
          INTO TABLE @DATA(lt_dcgc_hdr).
      LOOP AT lt_dcgc_hdr INTO DATA(ls_dcgc_hdr).
        " The %cid (temporary primary key) has always to be supplied (is omitted in further examples)
        TRY.
            DATA(lv_cid) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "Error handling
        ENDTRY.

        ls_PheDuyet-%cid = lv_cid.
        ls_PheDuyet-%param-hdrid = ls_dcgc_hdr-hdr_id.

        INSERT ls_PheDuyet INTO TABLE lt_PheDuyet.
      ENDLOOP.
      IF lt_PheDuyet IS NOT INITIAL.
        "Register the action
        MODIFY ENTITIES OF zr_tbdcgc_hdr
        ENTITY ZrTbdcgcHdr
        EXECUTE PheDuyet FROM lt_PheDuyet
        FAILED DATA(ls_failed)
        REPORTED DATA(ls_reported)
        MAPPED DATA(ls_mapped).
      ENDIF.

      MODIFY ENTITIES OF zr_tbxetduyet_hdr IN LOCAL MODE
        ENTITY ZrTbxetduyetHdr
          UPDATE FIELDS ( trangthai )
          WITH VALUE #(
            ( %tky = ls_ZrTbxetduyetHdr-%tky
              trangthai =  '1' ) ).
    ENDLOOP.

    "return result entities
    result = VALUE #( FOR xetduyetHdr IN ZrTbxetduyetHdr ( %tky   = xetduyetHdr-%tky
                                                  %param = xetduyetHdr ) ).
  ENDMETHOD.

  METHOD HuyPheDuyet.
    READ ENTITIES OF zr_tbxetduyet_hdr IN LOCAL MODE
       ENTITY ZrTbxetduyetHdr
       ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(ZrTbxetduyetHdr).

    LOOP AT ZrTbxetduyetHdr INTO DATA(ls_ZrTbxetduyetHdr) WHERE trangthai = '1'.
      DATA ls_PheDuyet TYPE STRUCTURE FOR ACTION IMPORT zr_tbdcgc_hdr~HuyPheDuyet.
      DATA lt_PheDuyet TYPE TABLE FOR ACTION IMPORT zr_tbdcgc_hdr~HuyPheDuyet.

      SELECT * FROM ztb_dcgc_hdr
          WHERE bukrs = @ls_ZrTbxetduyetHdr-Bukrs AND zper = @ls_ZrTbxetduyetHdr-Zper
          AND lan = @ls_ZrTbxetduyetHdr-Lan AND trangthai = '1'
          INTO TABLE @DATA(lt_dcgc_hdr).
      LOOP AT lt_dcgc_hdr INTO DATA(ls_dcgc_hdr).
        " The %cid (temporary primary key) has always to be supplied (is omitted in further examples)
        TRY.
            DATA(lv_cid) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "Error handling
        ENDTRY.

        ls_PheDuyet-%cid = lv_cid.
        ls_PheDuyet-%param-hdrid = ls_dcgc_hdr-hdr_id.

        INSERT ls_PheDuyet INTO TABLE lt_PheDuyet.
      ENDLOOP.
      IF lt_PheDuyet IS NOT INITIAL.
        "Register the action
        MODIFY ENTITIES OF zr_tbdcgc_hdr
        ENTITY ZrTbdcgcHdr
        EXECUTE HuyPheDuyet FROM lt_PheDuyet
        FAILED DATA(ls_failed)
        REPORTED DATA(ls_reported)
        MAPPED DATA(ls_mapped).
      ENDIF.

      MODIFY ENTITIES OF zr_tbxetduyet_hdr IN LOCAL MODE
        ENTITY ZrTbxetduyetHdr
          UPDATE FIELDS ( trangthai )
          WITH VALUE #(
            ( %tky = ls_ZrTbxetduyetHdr-%tky
              trangthai =  '0' ) ).
    ENDLOOP.

    "return result entities
    result = VALUE #( FOR xetduyetHdr IN ZrTbxetduyetHdr ( %tky   = xetduyetHdr-%tky
                                                  %param = xetduyetHdr ) ).
  ENDMETHOD.

  METHOD update_tyle.
    DATA: ls_update TYPE STRUCTURE FOR UPDATE zr_tbxetduyet_dtl,
          lt_update TYPE TABLE FOR UPDATE zr_tbxetduyet_dtl.
    DATA: lw_tyle_str TYPE zde_char10.
    READ TABLE keys INTO DATA(ls_keys) INDEX 1.
    READ ENTITIES OF zr_tbxetduyet_hdr IN LOCAL MODE
       ENTITY ZrTbxetduyetHdr
       ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(ZrTbxetduyetHdr).

    LOOP AT ZrTbxetduyetHdr INTO DATA(ls_ZrTbxetduyetHdr).
      SELECT * FROM zr_tbxetduyet_dtl
          WHERE HdrID = @ls_ZrTbxetduyetHdr-HdrID
          INTO TABLE @DATA(lt_dtl).
      LOOP AT lt_dtl INTO DATA(ls_dtl).
        " The %cid (temporary primary key) has always to be supplied (is omitted in further examples)
*        TRY.
*            DATA(lv_cid) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
*          CATCH cx_uuid_error.
*            "Error handling
*        ENDTRY.

        ls_update-HdrID = ls_dtl-HdrID.
        ls_update-DtlID = ls_dtl-DtlID.
        lw_tyle_str = ls_keys-%param-ct411.
        IF lw_tyle_str IS NOT INITIAL.
          REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
          ls_update-Ct411 = lw_tyle_str.
        ELSE.
          ls_update-Ct411 = ls_dtl-Ct411.
        ENDIF.
        lw_tyle_str = ls_keys-%param-ct421.
        IF lw_tyle_str IS NOT INITIAL.
          REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
          ls_update-ct421 = lw_tyle_str.
        ELSE.
          ls_update-ct421 = ls_dtl-ct421.
        ENDIF.
        lw_tyle_str = ls_keys-%param-Ct431.
        IF lw_tyle_str IS NOT INITIAL.
          REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
          ls_update-Ct431 = lw_tyle_str.
        ELSE.
          ls_update-Ct431 = ls_dtl-Ct431.
        ENDIF.

        lw_tyle_str = ls_keys-%param-Ct441.
        IF lw_tyle_str IS NOT INITIAL.
          REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
          ls_update-Ct441 = lw_tyle_str.
        ELSE.
          ls_update-Ct441 = ls_dtl-Ct441.
        ENDIF.

        lw_tyle_str = ls_keys-%param-Ct451.
        IF lw_tyle_str IS NOT INITIAL.
          REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
          ls_update-Ct451 = lw_tyle_str.
        ELSE.
          ls_update-Ct451 = ls_dtl-Ct451.
        ENDIF.

        lw_tyle_str = ls_keys-%param-Ct461.
        IF lw_tyle_str IS NOT INITIAL.
          REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
          ls_update-Ct461 = lw_tyle_str.
        ELSE.
          ls_update-Ct461 = ls_dtl-Ct461.
        ENDIF.

        lw_tyle_str = ls_keys-%param-Ct471.
        IF lw_tyle_str IS NOT INITIAL.
          REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
          ls_update-Ct471 = lw_tyle_str.
        ELSE.
          ls_update-Ct471 = ls_dtl-Ct471.
        ENDIF.

        lw_tyle_str = ls_keys-%param-Ct481.
        IF lw_tyle_str IS NOT INITIAL.
          REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
          ls_update-Ct481 = lw_tyle_str.
        ELSE.
          ls_update-Ct481 = ls_dtl-Ct481.
        ENDIF.

        lw_tyle_str = ls_keys-%param-Ct491.
        IF lw_tyle_str IS NOT INITIAL.
          REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
          ls_update-Ct491 = lw_tyle_str.
        ELSE.
          ls_update-Ct491 = ls_dtl-Ct491.
        ENDIF.

        lw_tyle_str = ls_keys-%param-Ct501.
        IF lw_tyle_str IS NOT INITIAL.
          REPLACE ALL OCCURRENCES OF ',' IN lw_tyle_str WITH '.'.
          ls_update-Ct501 = lw_tyle_str.
        ELSE.
          ls_update-Ct501 = ls_dtl-Ct501.
        ENDIF.

        INSERT ls_update INTO TABLE lt_update.
      ENDLOOP.
      IF lt_update IS NOT INITIAL.
        "Register the action
        MODIFY ENTITIES OF zr_tbxetduyet_hdr IN LOCAL MODE
        ENTITY ZrTbxetduyetDtl
        UPDATE FIELDS ( ct411 ct421 ct431 ct441 ct451 ct461 ct471 ct481 ct491 ct501 )
        WITH lt_update
        FAILED DATA(ls_failed)
        REPORTED DATA(ls_reported)
        MAPPED DATA(ls_mapped).
      ENDIF.
      CLEAR: lt_dtl, lt_update.
    ENDLOOP.

    "return result entities
    result = VALUE #( FOR xetduyetHdr IN ZrTbxetduyetHdr ( %tky   = xetduyetHdr-%tky
                                                  %param = xetduyetHdr ) ).
  ENDMETHOD.

ENDCLASS.

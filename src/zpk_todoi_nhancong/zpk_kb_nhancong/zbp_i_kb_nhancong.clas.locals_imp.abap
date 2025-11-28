CLASS lhc_ZI_KB_NHANCONG DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

  TYPES:
       BEGIN OF ty_file_upload,
        convert_sap_no       TYPE string,
        pid                  TYPE string,
        pid_item             TYPE string,
        fiscal_year          TYPE string,
        doc_date             TYPE string,
        plan_count_date      TYPE string,
        plant                TYPE string,
        storage_location     TYPE string,
        material             TYPE string,

      END OF ty_file_upload,

      ty_t_file_upload TYPE STANDARD TABLE OF ty_file_upload WITH EMPTY KEY.
    METHODS DownloadFile FOR MODIFY
      IMPORTING keys FOR ACTION zi_kb_nhancong~DownloadFile RESULT result.

    METHODS UploadFile FOR MODIFY
      IMPORTING keys FOR ACTION zi_kb_nhancong~UploadFile.


    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_kb_nhancong RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_kb_nhancong RESULT result.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_kb_nhancong~validatedates.

    METHODS validateworkerid FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_kb_nhancong~validateworkerid.

    METHODS validateworkcenter FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_kb_nhancong~validateworkcenter.

    METHODS validateplant FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_kb_nhancong~validateplant.

    METHODS validateworkcenterplant FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_kb_nhancong~validateworkcenterplant.

ENDCLASS.

CLASS lhc_ZI_KB_NHANCONG IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  meTHOD downloadfile.
  enDMETHOD.

  METHOD uploadfile.
  DATA: lv_fail TYPE abap_boolean.

    DATA: lt_file   TYPE STANDARD TABLE OF ty_file_upload,

          lt_file_u TYPE TABLE OF ztb_inven_im1,
          ls_file_u LIKE LINE OF lt_file_u,

          lt_file_c TYPE TABLE FOR UPDATE zi_inventory_data_im,
          ls_file_c LIKE LINE OF lt_file_c.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_keys>) INDEX 1.

    CHECK sy-subrc = 0.

    DATA(lv_filecontent) = <ls_keys>-%param-filecontent.

    "xcoライブラリを使用したexcelファイルの読み取り
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

  ENDMETHOD.

  METHOD validateDates.
    " Read relevant instance data
    READ ENTITIES OF zi_kb_nhancong IN LOCAL MODE
      ENTITY zi_kb_nhancong
        FIELDS ( FromDate ToDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_kb_nhancong).

    LOOP AT lt_kb_nhancong INTO DATA(ls_kb_nhancong).
      APPEND VALUE #(  %tky        = ls_kb_nhancong-%tky
                        %state_area = 'VALIDATE_DATES' )
         TO reported-zi_kb_nhancong.

      IF ls_kb_nhancong-FromDate > ls_kb_nhancong-ToDate.
        APPEND VALUE #( %tky = ls_kb_nhancong-%tky ) TO failed-zi_kb_nhancong.
        APPEND VALUE #( %tky               = ls_kb_nhancong-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg               = NEW zcm_tw_list(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_tw_list=>from_date_before_to_date
                                                 fromdate = ls_kb_nhancong-FromDate
                                                 todate   = ls_kb_nhancong-ToDate )
                        %element-FromDate = if_abap_behv=>mk-on
                        %element-ToDate   = if_abap_behv=>mk-on )
            TO reported-zi_kb_nhancong.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateWorkerId.
    " Read relevant instance data
    READ ENTITIES OF zi_kb_nhancong IN LOCAL MODE
      ENTITY zi_kb_nhancong
        FIELDS ( WorkCenter WorkerId Plant FromDate ToDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_kb_nhancong).

    SELECT *
    FROM ztb_kb_nhancong
         FOR ALL ENTRIES IN @lt_kb_nhancong
         WHERE worker_id = @lt_kb_nhancong-workerid
         AND work_center = @lt_kb_nhancong-workcenter
         AND plant = @lt_kb_nhancong-plant
         INTO TABLE @DATA(lt_boolean).

    IF sy-subrc EQ 0.
      LOOP AT lt_kb_nhancong INTO DATA(ls_kb_nhancong).
        READ TABLE lt_boolean INTO DATA(ls_boolean) INDEX 1.

        IF ( ls_boolean-from_date >= ls_kb_nhancong-FromDate AND ls_kb_nhancong-ToDate >= ls_boolean-to_date ) OR
           ( ls_boolean-from_date <= ls_kb_nhancong-FromDate AND ls_kb_nhancong-FromDate <= ls_boolean-to_date ) OR
           ( ls_boolean-from_date <= ls_kb_nhancong-ToDate AND ls_kb_nhancong-ToDate <= ls_boolean-to_date ).
          APPEND VALUE #(  %tky        = ls_kb_nhancong-%tky
                            %state_area = 'VALIDATE_WORKER_ID' )
             TO reported-zi_kb_nhancong.

          APPEND VALUE #( %tky = ls_kb_nhancong-%tky ) TO failed-zi_kb_nhancong.
          APPEND VALUE #( %tky               = ls_kb_nhancong-%tky
                          %state_area        = 'VALIDATE_WORKER_ID'
                          %msg               = NEW zcm_tw_list(
                                                   severity  = if_abap_behv_message=>severity-error
                                                   textid    = zcm_tw_list=>existed_worker_id
                                                   workerid = ls_kb_nhancong-WorkerId
                                                   fromdate = ls_kb_nhancong-FromDate
                                                   todate = ls_kb_nhancong-ToDate
                                                   )
                          %element-WorkerId = if_abap_behv=>mk-on
                          %element-FromDate = if_abap_behv=>mk-on
                          %element-ToDate = if_abap_behv=>mk-on
                          )
              TO reported-zi_kb_nhancong.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD validateWorkCenter.
    " Read relevant instance data
    READ ENTITIES OF zi_kb_nhancong IN LOCAL MODE
      ENTITY zi_kb_nhancong
        FIELDS ( WorkCenter ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_kb_nhancong).

    LOOP AT lt_kb_nhancong INTO DATA(ls_kb_nhancong).
      DATA(lv_respond) = zcl_kb_nhancong=>data_valid_check( i_workcenter = ls_kb_nhancong-WorkCenter ).

      IF lv_respond NE abap_true.
        APPEND VALUE #(  %tky        = ls_kb_nhancong-%tky
                          %state_area = 'VALIDATE_WORKERCENTER' )
           TO reported-zi_kb_nhancong.

        APPEND VALUE #( %tky = ls_kb_nhancong-%tky ) TO failed-zi_kb_nhancong.
        APPEND VALUE #( %tky               = ls_kb_nhancong-%tky
                        %state_area        = 'VALIDATE_WORKERCENTER'
                        %msg               = NEW zcm_tw_list(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_tw_list=>invalid_worcenter
                                                 workcenter = ls_kb_nhancong-workcenter )
                        %element-WorkCenter = if_abap_behv=>mk-on )
            TO reported-zi_kb_nhancong.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatePlant.
    " Read relevant instance data
    READ ENTITIES OF zi_kb_nhancong IN LOCAL MODE
      ENTITY zi_kb_nhancong
        FIELDS ( Plant ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_kb_nhancong).

    LOOP AT lt_kb_nhancong INTO DATA(ls_kb_nhancong).
      DATA(lv_respond) = zcl_kb_nhancong=>data_valid_check( i_plant = ls_kb_nhancong-Plant ).

      IF lv_respond NE abap_true.

        APPEND VALUE #(  %tky        = ls_kb_nhancong-%tky
                          %state_area = 'VALIDATE_PLANT' )
           TO reported-zi_kb_nhancong.

        APPEND VALUE #( %tky = ls_kb_nhancong-%tky ) TO failed-zi_kb_nhancong.
        APPEND VALUE #( %tky               = ls_kb_nhancong-%tky
                        %state_area        = 'VALIDATE_PLANT'
                        %msg               = NEW zcm_tw_list(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_tw_list=>invalid_plant
                                                 plant = ls_kb_nhancong-plant )
                        %element-Plant = if_abap_behv=>mk-on )
            TO reported-zi_kb_nhancong.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateWorkCenterPlant.
    " Read relevant instance data
    READ ENTITIES OF zi_kb_nhancong IN LOCAL MODE
      ENTITY zi_kb_nhancong
        FIELDS ( WorkCenter Plant ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_kb_nhancong).

    LOOP AT lt_kb_nhancong INTO DATA(ls_kb_nhancong).
      DATA(lv_respond) = zcl_kb_nhancong=>data_valid_check( i_workcenter = ls_kb_nhancong-WorkCenter
                                                            i_plant = ls_kb_nhancong-Plant ).

      IF lv_respond NE abap_true.

        APPEND VALUE #(  %tky        = ls_kb_nhancong-%tky
                          %state_area = 'VALIDATE_WORKCENTER_PLANT' )
           TO reported-zi_kb_nhancong.

        APPEND VALUE #( %tky = ls_kb_nhancong-%tky ) TO failed-zi_kb_nhancong.
        APPEND VALUE #( %tky               = ls_kb_nhancong-%tky
                        %state_area        = 'VALIDATE_WORKCENTER_PLANT'
                        %msg               = NEW zcm_tw_list(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_tw_list=>workcenter_plant_notmatch
                                                 workcenter = ls_kb_nhancong-WorkCenter
                                                 plant = ls_kb_nhancong-plant )
                        %element-WorkCenter = if_abap_behv=>mk-on
                        %element-Plant = if_abap_behv=>mk-on )
            TO reported-zi_kb_nhancong.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

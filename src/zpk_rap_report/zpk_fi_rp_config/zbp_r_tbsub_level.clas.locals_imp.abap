CLASS lhc_zr_tbsub_level DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_file_up,
        sublevel   TYPE string,
        gl_account TYPE string,
        ztext      TYPE string,
      END OF ty_file_up,

      ty_t_file_up TYPE STANDARD TABLE OF ty_file_up WITH EMPTY KEY.

    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrTbsubLevel
        RESULT result,
      Download FOR MODIFY
        IMPORTING keys FOR ACTION ZrTbsubLevel~Download RESULT result.

    METHODS Upload FOR MODIFY
      IMPORTING keys FOR ACTION ZrTbsubLevel~Upload.
ENDCLASS.

CLASS lhc_zr_tbsub_level IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD Download.
    DATA LT_File TYPE STANDARD TABLE OF ty_file_up WITH DEFAULT KEY.

    "XCOライブラリを使用したExcelファイルの書き込み
    DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
    DATA(lo_worksheet) = lo_write_access->get_workbook(
        )->worksheet->at_position( 1 ).

    DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
                               )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                               )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'C' )
                               )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
                               )->get_pattern( ).

    READ TABLE keys INDEX 1 INTO DATA(k).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    "ヘッダの設定（すべての項目はstring型）
    lt_file = VALUE #(
************Line One
                       (
                     sublevel       = 'Subtotal at Level'
                     gl_account                  = 'GL Account'
                     ztext             = 'GL Account Long Text'
                       )
                        ).


    lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_from( REF #( lt_file )
        )->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    SELECT SINGLE *
    FROM zcore_tb_temppdf
    WHERE id = 'GL_SUB_LEVEL_TEMPLATE'
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
                                          filename      = 'GL_SUB_Level_template'
                                          fileextension = 'xlsx'
                                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                        ) ).
    ELSE.
      result = VALUE #( FOR key IN keys (
                        %cid   = key-%cid
                        %param = VALUE #( filecontent   = ls_tb_temppdf-file_content
                                          filename      = 'GL_SUB_Level_template'
                                          fileextension = 'xlsx'
                                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                        ) ).
    ENDIF.
  ENDMETHOD.

  METHOD Upload.
    DATA: lt_file   TYPE STANDARD TABLE OF ty_file_up.
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

    DATA: lt_tbsub_level_  TYPE TABLE FOR UPDATE zr_tbsub_level,
          ls_tbsub_level_c TYPE STRUCTURE FOR UPDATE zr_tbsub_level.
    DATA: lw_cid TYPE zde_numc_5.
    LOOP AT lt_file INTO DATA(ls_file).
      lw_cid += 1.
      SELECT SINGLE * FROM zr_tbsub_level
        WHERE Sublevel = @ls_file-sublevel
        AND GlAccount = @ls_file-gl_account
        INTO @DATA(ls_data).
      IF sy-subrc IS NOT INITIAL.
        ls_data-Sublevel = ls_file-Sublevel.
        ls_data-GlAccount = ls_file-gl_account.
        ls_data-Ztext = ls_file-ztext.

        MODIFY ENTITIES OF zr_tbsub_level IN LOCAL MODE
         ENTITY ZrTbsubLevel
           CREATE FIELDS ( GlAccount Sublevel Ztext )
           WITH VALUE #( (
             %cid = lw_cid
               GlAccount = ls_data-GlAccount
               Sublevel = ls_data-Sublevel
               Ztext = ls_data-ztext ) ).
      ENDIF.

      MODIFY ENTITIES OF zr_tbsub_level IN LOCAL MODE
          ENTITY ZrTbsubLevel
            UPDATE FIELDS ( Ztext )
            WITH VALUE #(
              ( %tky-GlAccount = ls_data-GlAccount
                %tky-Sublevel = ls_data-Sublevel
                Ztext = ls_file-ztext )
            ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

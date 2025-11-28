CLASS zcl_jp_get_data_lcttgt DEFINITION
  PUBLIC
  INHERITING FROM cx_rap_query_provider
*  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           BEGIN OF ty_rule,
             sequence  TYPE char20,
             item_desc TYPE char255,
             item_code TYPE char10,
             item_disp TYPE char10,
             fomulas   TYPE char255,
             display   TYPE char1,
             gl_acc    TYPE char255,
             offset_gl TYPE char255,
             data_type TYPE char2,
             sh_type   TYPE char2,
             doc_type  TYPE char20,
             zfont     TYPE char1,
             kynay     TYPE dmbtr,
             kytruoc   TYPE dmbtr,
           END OF ty_rule,

           tt_range TYPE TABLE OF ty_range_option,
           s_period TYPE TABLE OF ty_range_option,
           tt_data  TYPE TABLE OF zdd_lcttgt,
           tt_rule  TYPE TABLE OF ty_rule.

    CLASS-DATA:
      gt_data      TYPE TABLE OF zdd_lcttgt,
      gs_data      TYPE zdd_lcttgt,
      lw_date      TYPE budat,
      lw_date_kt   TYPE budat,
      c_gjahr      TYPE gjahr,
      lw_gjahr     TYPE gjahr,
      lw_datum     TYPE budat,
      p_gjahr      TYPE gjahr,
      ls_period    TYPE ty_range_option,
      ls_period_kt TYPE ty_range_option,
      lr_budat     TYPE tt_range,
      lr_budat_kt  TYPE tt_range,
      ls_budat     TYPE ty_range_option,
      ls_budat_kt  TYPE ty_range_option,
      lw_date_dk_n TYPE budat,
      lw_date_dk_t TYPE budat,
      lw_type      TYPE char2,
      lw_bukrs     TYPE bukrs,
      fomulas_ex   TYPE char255,
      hsl_ex_kn    TYPE dmbtr,
      hsl_ex_kt    TYPE dmbtr,
      "Instance Singleton
      mo_instance  TYPE REF TO zcl_jp_get_data_lcttgt.
    CLASS-METHODS:
      "Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_jp_get_data_lcttgt,

      get_parameter IMPORTING ir_bukrs     TYPE tt_range
                              ir_type      TYPE tt_range
                              ir_gjahr     TYPE tt_range
                    EXPORTING lw_gjahr     TYPE gjahr
                              s_period     TYPE tt_range
                              lw_date      TYPE budat
                              lw_date_kt   TYPE budat
                              lw_type      TYPE char2
                              lw_bukrs     TYPE bukrs
                              lr_budat     TYPE tt_range
                              lr_budat_kt  TYPE tt_range
                              lw_date_dk_n TYPE budat
                              lw_date_dk_t TYPE budat,

      get_hsl IMPORTING bukrs      TYPE bukrs
                        gl_acc     TYPE char255
                        offset_gl  TYPE char255
                        budat      TYPE tt_range
                        budat_kt   TYPE tt_range
                        budat_dk_n TYPE budat
                        budat_dk_t TYPE budat
                        date_n     TYPE budat
                        date_t     TYPE budat
                        data_type  TYPE char2
                        sh_type    TYPE char2
                        doc_type   TYPE char20
              EXPORTING kynay      TYPE dmbtr
                        kytruoc    TYPE dmbtr,

      get_fomulas IMPORTING tt_rule TYPE tt_rule
                            token   TYPE string
                            fomulas TYPE char255
                  EXPORTING
                            hsl_kn  TYPE dmbtr
                            hsl_kt  TYPE dmbtr.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_JP_GET_DATA_LCTTGT IMPLEMENTATION.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD get_parameter.
    READ TABLE ir_type INTO DATA(ls_type) INDEX 1.
    READ TABLE ir_gjahr INTO DATA(ls_gjahr) INDEX 1.
    READ TABLE ir_bukrs INTO DATA(ls_bukrs) INDEX 1.

*--------------------------------*
    lw_bukrs = ls_bukrs-low.
    lw_gjahr = ls_gjahr-low.
    lw_type = ls_type-low.
    p_gjahr = ls_gjahr-low + 1.
    lw_datum = |{ lw_datum }0101|.
    c_gjahr = ls_gjahr-low - 1.
    lw_date_dk_n = |{ ls_gjahr-low }0101|.
    lw_date_dk_t = |{ c_gjahr }0101|.
    ls_period-sign     = 'I'.
    ls_period-option   = 'BT'.
    ls_budat-sign      = 'I'.
    ls_budat-option    = 'BT'.
    ls_budat-low       = |{ ls_gjahr-low }0101|.
    ls_budat_kt-low    = |{ c_gjahr }0101|.
    ls_budat_kt-sign   = 'I'.
    ls_budat_kt-option = 'BT'.
    IF ls_type-low = 'Q1'.
      CONCATENATE ls_gjahr-low '0331' INTO lw_date.
      CONCATENATE c_gjahr '0331' INTO lw_date_kt.
      ls_period-low      = '01'.
      ls_period-high     = '03'.
      ls_budat-high      = lw_date.
      ls_budat_kt-high   = lw_date_kt.
      APPEND ls_budat_kt TO lr_budat_kt.
      APPEND ls_budat TO lr_budat.
      APPEND ls_period TO s_period.
    ELSEIF ls_type-low = 'Q2'.
      CONCATENATE ls_gjahr-low '0630' INTO lw_date.
      CONCATENATE c_gjahr '0630' INTO lw_date_kt.
      ls_period-low      = '01'.
      ls_period-high     = '06'.
      ls_budat-high      = lw_date.
      ls_budat_kt-high   = lw_date_kt.
      APPEND ls_budat_kt TO lr_budat_kt.
      APPEND ls_budat TO lr_budat.
      APPEND ls_period TO s_period.
    ELSEIF ls_type-low = 'Q3'.
      CONCATENATE ls_gjahr-low '0930' INTO lw_date.
      CONCATENATE c_gjahr '0930' INTO lw_date_kt.
      ls_period-low      = '01'.
      ls_period-high     = '09'.
      ls_budat-high      = lw_date.
      ls_budat_kt-high   = lw_date_kt.
      APPEND ls_budat_kt TO lr_budat_kt.
      APPEND ls_budat TO lr_budat.
      APPEND ls_period TO s_period.
    ELSE.
      CONCATENATE ls_gjahr-low '1231' INTO lw_date.
      CONCATENATE c_gjahr '1231' INTO lw_date_kt.
      ls_period-low      = '01'.
      ls_period-high     = '12'.
      ls_budat-high      = lw_date.
      ls_budat_kt-high   = lw_date_kt.
      APPEND ls_budat_kt TO lr_budat_kt.
      APPEND ls_budat TO lr_budat.
      APPEND ls_period TO s_period.
    ENDIF.

  ENDMETHOD.


  METHOD get_hsl.

    DATA: lt_gl_acc     TYPE TABLE OF string,
          lt_offset_acc TYPE TABLE OF string,
          lt_doc_acc    TYPE TABLE OF string,
          lt_gl         TYPE tt_range,
          lt_offset     TYPE tt_range,
          lt_doc_type   TYPE tt_range,
          lv_hkont      TYPE hkont,
          lv_lengt      TYPE int4.
    DATA: lo_amdp TYPE REF TO zcl_get_offset_lcttgt.


    SPLIT gl_acc AT ',' INTO TABLE lt_gl_acc.
    LOOP AT lt_gl_acc INTO DATA(ls_gl).
      IF strlen( ls_gl ) < 8.
        APPEND VALUE #( sign = 'I' option = 'CP' low = |{ ls_gl }*| ) TO lt_gl.
      ELSE.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_gl ) TO lt_gl.
      ENDIF.
      CLEAR: ls_gl.
    ENDLOOP.

    SPLIT offset_gl AT ',' INTO TABLE lt_offset_acc.
    LOOP AT lt_offset_acc INTO ls_gl.
      IF ls_gl IS INITIAL.
      ELSE.
        IF strlen( ls_gl ) < 8.
          APPEND VALUE #( sign = 'I' option = 'CP' low = |{ ls_gl }*| ) TO lt_offset.
        ELSE.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_gl ) TO lt_offset.
        ENDIF.
      ENDIF.
    ENDLOOP.

    SPLIT doc_type AT ',' INTO TABLE lt_doc_acc.
    LOOP AT lt_doc_acc INTO DATA(ls_doc).
      IF ls_doc CA '#'.
        APPEND VALUE #( sign = 'I' option = 'NE' low = ls_doc+1(2) ) TO lt_doc_type.
      ELSE.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_doc ) TO lt_doc_type.
      ENDIF.
      CLEAR: ls_doc.
    ENDLOOP.


    CREATE OBJECT lo_amdp.
    TRY.
        lo_amdp->sum_amount(
        EXPORTING
         ir_bukrs = lw_bukrs
         ir_gl_acc = lt_gl
         ir_offset_acc = lt_offset
         ir_budat = lr_budat
         ir_budat_kt = lr_budat_kt
         ir_budat_dk_n = lw_date_dk_n
         ir_budat_dk_t = lw_date_dk_t
         ir_date_n = lw_date
         ir_date_t = lw_date_kt
         ir_data_type = data_type
         ir_sh_type = sh_type
         ir_doc_type = lt_doc_type
        IMPORTING
         kynay = kynay
         kytruoc = kytruoc
        ).
    ENDTRY.

  ENDMETHOD.


  METHOD get_fomulas.
    DATA: lt_token_loop    TYPE TABLE OF string,
          lv_token_loop    TYPE string,
          hsl_kn_loop      TYPE dmbtr,
          hsl_kt_loop      TYPE dmbtr,
          lv_operator_loop TYPE char1.
    DATA(lo_lcttgt)  = zcl_jp_get_data_lcttgt=>get_instance( ).

    SPLIT fomulas AT '' INTO TABLE lt_token_loop.
    LOOP AT lt_token_loop INTO lv_token_loop.
      IF lv_token_loop CA '+-'.
        lv_operator_loop = lv_token_loop.
        CONTINUE.
      ENDIF.

      READ TABLE tt_rule INTO DATA(gs_rule) WITH KEY item_code = lv_token_loop.
      IF sy-subrc IS INITIAL.
        IF gs_rule-fomulas IS NOT INITIAL.
          lo_lcttgt->get_fomulas(
          EXPORTING
          tt_rule = tt_rule
          token = lv_token_loop
          fomulas = gs_rule-fomulas
          importing
          hsl_kn = hsl_kn
          hsl_kt = hsl_kt
          ).
        ELSE.
        ENDIF.
      ELSE.
        CONTINUE.
      ENDIF.

      CASE lv_operator_loop.
        WHEN '+' OR ''.
          hsl_ex_kn = hsl_ex_kn + gs_rule-kynay.
          hsl_ex_kt = hsl_ex_kt + gs_rule-kytruoc.
        WHEN '-'.
          hsl_ex_kn = hsl_ex_kn - gs_rule-kynay.
          hsl_ex_kn = hsl_ex_kn - gs_rule-kytruoc.
        WHEN OTHERS.
      ENDCASE.
      CLEAR: lv_token_loop, lv_operator_loop, gs_rule.
    ENDLOOP.

    hsl_kn = hsl_kn + hsl_ex_kn.
    hsl_kt = hsl_kt + hsl_ex_kt.
    clear: hsl_ex_kn, hsl_ex_kt.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.

    DATA: gw_60    TYPE dmbtr,
          gw_60_nt TYPE dmbtr.
    DATA: ls_page_info  TYPE zcl_fillter_lcttgt=>st_page_info,
          ir_bukrs      TYPE tt_range,
          ir_rldnr      TYPE tt_range,
          ir_gjahr      TYPE tt_range,
          s_period      TYPE tt_range,
          ir_type       TYPE tt_range,
          ls_type       TYPE LINE OF tt_range,
          gt_data_tt    TYPE TABLE OF  zc_bc_lctt_tt,
          lt_data       TYPE TABLE OF zdd_lcttgt,
          gt_rule       TYPE TABLE OF ty_rule,
          gs_rule       TYPE ty_rule,
          lv_operator   TYPE char1,
          lt_token      TYPE TABLE OF string,
          lv_token      TYPE string,
          lv_value      TYPE dmbtr,
          lv_token_loop TYPE string,
          lv_fomulas    TYPE char255,
          lv_flag       TYPE char1,
          lv_hsl_kn     TYPE dmbtr,
          lv_hsl_kt     TYPE dmbtr.
    FREE lt_data.
    TRY.
* Khởi tạo đối tượng
        DATA(lo_lcttgt)  = zcl_jp_get_data_lcttgt=>get_instance( ).
        DATA(lo_comcode) = zcl_jp_common_core=>get_instance(  ).
        DATA(lo_common_app) = zcl_fillter_lcttgt=>get_instance( ).
        DATA(lo_data_tructiep) = zcl_data_bclctt_tt=>get_instance( ).
*  Lấy tham số
        lo_common_app->get_fillter_app(
          EXPORTING
           io_request    = io_request
           io_response   = io_response
          IMPORTING
           ir_bukrs  = ir_bukrs
           ir_gjahr  = ir_gjahr
           ir_type   = ir_type
           wa_page_info  = ls_page_info
       ).
* Lấy parameter
        lo_lcttgt->get_parameter(
          EXPORTING
            ir_type   = ir_type
            ir_gjahr  = ir_gjahr
            ir_bukrs  = ir_bukrs
          IMPORTING
            lw_gjahr  = lw_gjahr
            s_period  = s_period
            lw_date   = lw_date
            lw_date_dk_n = lw_date_dk_n
            lw_date_dk_t = lw_date_dk_t
            lw_date_kt = lw_date_kt
            lw_type   = lw_type
            lw_bukrs  = lw_bukrs
            lr_budat = lr_budat
            lr_budat_kt = lr_budat_kt
        ).
* Submit lấy các chỉ tiêu của lưu chuyển tiền tệ trực tiếp
        lo_data_tructiep->get_bc_lctt_tt(
         EXPORTING
           ir_companycode = ir_bukrs
           ir_fiscalyear = ir_gjahr
           ir_budat = lr_budat
           ir_budat_nt = lr_budat_kt
         IMPORTING
           it_data = gt_data_tt
        ).

* get data config-- chi tieu 1-->19 tai khoan doi ung
        DATA(lo_data_retrieval) = cl_cbo_developer_access=>business_object( 'YY1_IN_CF'
          )->root_node(
          )->data_retrieval( ).

        DATA(lt_records) = lo_data_retrieval->get_records( )->resolve( ).

        LOOP AT lt_records ASSIGNING FIELD-SYMBOL(<fs_record>).
          DATA(ls_data_object) = <fs_record>->get_data_object(
            )->get_reference( ).
          gs_rule-sequence  = ls_data_object->('SEQUENCE').
          gs_rule-item_desc = ls_data_object->('ITEM_DESC').
          gs_rule-item_code = ls_data_object->('item_code').
          gs_rule-data_type = ls_data_object->('data_type').
          gs_rule-display = ls_data_object->('display').
          gs_rule-doc_type = ls_data_object->('doc_type').
          gs_rule-fomulas = ls_data_object->('fomulas').
          gs_rule-gl_acc = ls_data_object->('gl_acc').
          gs_rule-item_disp = ls_data_object->('item_disp').
          gs_rule-offset_gl = ls_data_object->('offset_gl').
          gs_rule-sh_type = ls_data_object->('sh_type').
          gs_rule-zfont = ls_data_object->('zfont').
          APPEND gs_rule TO gt_rule.
          CLEAR: gs_rule.
        ENDLOOP.


* Lấy tách đối ứng theo rule
        LOOP AT gt_rule ASSIGNING FIELD-SYMBOL(<fs_rule>) WHERE gl_acc IS NOT INITIAL.

          lo_lcttgt->get_hsl(
          EXPORTING
           bukrs  = lw_bukrs
           gl_acc = <fs_rule>-gl_acc
           offset_gl = <fs_rule>-offset_gl
           data_type = <fs_rule>-data_type
           sh_type = <fs_rule>-sh_type
           doc_type = <fs_rule>-doc_type
           budat = lr_budat
           budat_kt = lr_budat_kt
           budat_dk_n = lw_date_dk_n
           budat_dk_t = lw_date_dk_t
           date_n = lw_date
           date_t = lw_date_kt
          IMPORTING
           kynay = <fs_rule>-kynay
           kytruoc = <fs_rule>-kytruoc
           ).
        ENDLOOP.
* Sum các chỉ tiêu tổng
        LOOP AT gt_rule ASSIGNING <fs_rule> WHERE fomulas IS NOT INITIAL.
          SPLIT <fs_rule>-fomulas AT '' INTO TABLE lt_token.
          LOOP AT lt_token INTO lv_token.
            IF lv_token CA '+-'.
              lv_operator = lv_token.
              CONTINUE.
            ENDIF.

            READ TABLE gt_rule INTO gs_rule WITH KEY item_code = lv_token.
            IF sy-subrc IS INITIAL.
              IF gs_rule-fomulas IS NOT INITIAL.
*                REPLACE ALL OCCURRENCES OF lv_token IN <fs_rule>-fomulas WITH gs_rule-fomulas.
                lo_lcttgt->get_fomulas(
                EXPORTING
                tt_rule = gt_rule
                token = lv_token
                fomulas = gs_rule-fomulas
                IMPORTING
                hsl_kn = lv_hsl_kn
                hsl_kt = lv_hsl_kt
                ).
*                <fs_rule>-kynay = lv_hsl_kn.
*                <fs_rule>-kytruoc = lv_hsl_kt.
                gs_rule-kynay = lv_hsl_kn.
                gs_rule-kytruoc = lv_hsl_kt.
                CLEAR:lv_fomulas, lv_hsl_kn, lv_hsl_kt.
              ELSE.
              ENDIF.
            ELSE.
              CONTINUE.
            ENDIF.

            CASE lv_operator.
              WHEN '+' OR ''.
                <fs_rule>-kynay = <fs_rule>-kynay + gs_rule-kynay.
                <fs_rule>-kytruoc = <fs_rule>-kytruoc + gs_rule-kytruoc.
              WHEN '-'.
                <fs_rule>-kynay = <fs_rule>-kynay - gs_rule-kynay.
                <fs_rule>-kytruoc = <fs_rule>-kytruoc - gs_rule-kytruoc.
              WHEN OTHERS.
            ENDCASE.
            CLEAR: gs_rule.
          ENDLOOP.
          CLEAR: lt_token[], lv_token, lv_operator, hsl_ex_kn, hsl_ex_kt, lv_hsl_kn, lv_hsl_kt.
        ENDLOOP.

        DATA: lw_stt TYPE int4.
*        IF sy-uname = 'CB9980000016'.
*          LOOP AT gt_rule INTO gs_rule.
*            lw_stt = lw_stt + 1.
*            gs_data-stt = lw_stt.
*            gs_data-bukrs = lw_bukrs.
*            gs_data-gjahr = lw_gjahr.
*            gs_data-type = lw_type.
*            gs_data-HierarchyNode = gs_rule-item_disp.
*            gs_data-HierarchyNode_TXT = gs_rule-item_desc.
*            gs_data-sokynay = gs_rule-kynay.
*            gs_data-sokytruoc = gs_rule-kytruoc.
*            gs_data-currency_code = 'VND'.
*            gs_data-zfont = gs_rule-zfont.
*            APPEND gs_data TO gt_data.
*            CLEAR:gs_data, gs_rule.
*          ENDLOOP.
*        ELSE.
          LOOP AT gt_rule INTO gs_rule WHERE display IS NOT INITIAL.
            lw_stt = lw_stt + 1.
            gs_data-stt = lw_stt.
            gs_data-bukrs = lw_bukrs.
            gs_data-gjahr = lw_gjahr.
            gs_data-type = lw_type.
            gs_data-HierarchyNode = gs_rule-item_disp.
            gs_data-HierarchyNode_TXT = gs_rule-item_desc.
            gs_data-sokynay = gs_rule-kynay.
            gs_data-sokytruoc = gs_rule-kytruoc.
            gs_data-currency_code = 'VND'.
            gs_data-zfont = gs_rule-zfont.
            APPEND gs_data TO gt_data.
            CLEAR:gs_data, gs_rule.
          ENDLOOP.
*        ENDIF.

* HTIT thì không cần.
* Casla  chi tieu 20-->70 lay ben luu chuyen tien te truc tiep.
        DELETE gt_data_tt WHERE item_id < 90.

        LOOP AT gt_data_tt INTO DATA(gs_data_tt).
          gs_data-stt = sy-tabix + 200.
          gs_data-bukrs = lw_bukrs.
          gs_data-gjahr = lw_gjahr.
          gs_data-type = lw_type.
          gs_data-HierarchyNode = gs_data_tt-ma_so.
          gs_data-HierarchyNode_TXT = gs_data_tt-chi_tieu.
          gs_data-sokynay = gs_data_tt-ky_nay.
          gs_data-sokytruoc = gs_data_tt-ky_truoc.
          gs_data-currency_code = 'VND'.
          gs_data-zfont = gs_data_tt-Zfont.
          APPEND gs_data TO gt_data.
          CLEAR: gs_data, gs_data_tt.
        ENDLOOP.
*//////////////////////////////////////////////////////////////////////////
        READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs_data>) WITH KEY HierarchyNode = '09'.
        IF sy-subrc IS INITIAL.
          LOOP AT gt_data INTO gs_data WHERE HierarchyNode = '20'.
            <fs_data>-sokynay = <fs_data>-sokynay + gs_data-sokynay.
            <fs_data>-sokytruoc = <fs_data>-sokytruoc + gs_data-sokytruoc.
            CLEAR: gs_data.
          ENDLOOP.

          LOOP AT gt_data INTO gs_data WHERE HierarchyNode ='08' OR ( HierarchyNode >= '10' AND HierarchyNode <= '17' ).
            <fs_data>-sokynay = <fs_data>-sokynay - gs_data-sokynay.
            <fs_data>-sokytruoc = <fs_data>-sokytruoc - gs_data-sokytruoc.
            CLEAR: gs_data.
          ENDLOOP.

        ENDIF.
*        IF ls_page_info-page_size < 0.
*          ls_page_info-page_size = 50.
*        ENDIF.
*
*        DATA(max_rows) = COND #( WHEN ls_page_info-page_size = if_rap_query_paging=>page_size_unlimited THEN 0
*                   ELSE ls_page_info-page_size ).
*
*        max_rows = ls_page_info-page_size + ls_page_info-offset.

*        LOOP AT gt_data INTO DATA(ls_data).
*          IF sy-tabix > ls_page_info-offset.
*            IF sy-tabix > max_rows.
*              EXIT.
*            ELSE.
*              APPEND ls_data TO lt_data.
*              clear:ls_data.
*            ENDIF.
*          ENDIF.
*        ENDLOOP.

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( gt_data ) ).
        ENDIF.

        IF io_request->is_data_requested( ).
          io_response->set_data( gt_data ).
        ENDIF.

      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

        RAISE EXCEPTION TYPE zcl_jp_get_data_lcttgt
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

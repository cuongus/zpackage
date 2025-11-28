CLASS zcl_ads_xml_builder DEFINITION PUBLIC
FINAL
 CREATE PUBLIC.
  PUBLIC SECTION.

    TYPES: BEGIN OF ty_table_data_ref,
             table_id TYPE zxmlformtablecfg-table_id,
             dref     TYPE REF TO data,
           END OF ty_table_data_ref,
           tt_table_data_ref TYPE STANDARD TABLE OF ty_table_data_ref WITH EMPTY KEY.

    CONSTANTS:
      c_section_header  TYPE zxml_form_kv_map-zsection VALUE 'HEADER',
      c_section_footer  TYPE zxml_form_kv_map-zsection VALUE 'FOOTER',
      c_loc_header      TYPE zxmlformtablecfg-location  VALUE 'HEADER',
      c_loc_body        TYPE zxmlformtablecfg-location  VALUE 'BODY',
      c_loc_footer      TYPE zxmlformtablecfg-location  VALUE 'FOOTER',

      c_src_field       TYPE zxml_formrow_map-src_type VALUE 'FIELD',
      c_src_const       TYPE zxml_formrow_map-src_type VALUE 'CONST',

      c_fmt_text        TYPE zxml_formrow_map-fmt VALUE 'TEXT',
      c_fmt_date_vn     TYPE zxml_formrow_map-fmt VALUE 'DATE_VN',
      c_fmt_curr        TYPE zxml_formrow_map-fmt VALUE 'CURR',
      c_fmt_curr_x100vn TYPE zxml_formrow_map-fmt VALUE 'CURR_X100_VND'.

    " API chính: build XML theo form
    CLASS-METHODS build_xml_by_form
      IMPORTING
        i_form_id     TYPE zxml_form_cfg-form_id
        i_header_ctx  TYPE any OPTIONAL
        i_footer_ctx  TYPE any OPTIONAL
        it_table_data TYPE tt_table_data_ref    "mỗi row: TABLE_ID + REF #( itab )
      RETURNING
        VALUE(rv_xml) TYPE xstring.

    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_cfg_form,
        form_id      TYPE zxml_form_cfg-form_id,
        report_name  TYPE zxml_form_cfg-report_name,
        root_open    TYPE string,
        root_close   TYPE string,
        header_open  TYPE string,
        header_close TYPE string,
        footer_open  TYPE string,
        footer_close TYPE string,
      END OF ty_cfg_form.

    TYPES:
      BEGIN OF ty_cfg_table,
        form_id      TYPE zxmlformtablecfg-form_id,
        table_id     TYPE zxmlformtablecfg-table_id,
        container_id TYPE zxmlformtablecfg-container_id,
        seq          TYPE zxmlformtablecfg-seq,
        open_mode    TYPE zxmlformtablecfg-open_mode,  "OPEN|NONE|CLOSE|OPEN_CLOSE
        location     TYPE zxmlformtablecfg-location,   "HEADER|BODY|FOOTER
        table_open   TYPE string,
        row_open     TYPE string,
        row_close    TYPE string,
        table_close  TYPE string,
        name         TYPE zxmlformtablecfg-name,
        prefix_xml   TYPE string,
        suffix_xml   TYPE string,
      END OF ty_cfg_table,
      tt_cfg_table TYPE STANDARD TABLE OF ty_cfg_table WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_kv_map,
        form_id   TYPE zxml_form_kv_map-form_id,
        zsection  TYPE zxml_form_kv_map-zsection,   "HEADER/FOOTER
        seq       TYPE zxml_form_kv_map-seq,
        node_name TYPE string,
        src_type  TYPE string,
        src_name  TYPE string,
        fmt       TYPE string,
      END OF ty_kv_map,
      tt_kv_map TYPE STANDARD TABLE OF ty_kv_map WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_row_map,
        form_id  TYPE zxml_formrow_map-form_id,
        table_id TYPE zxml_formrow_map-table_id,
        row_kind TYPE zxml_formrow_map-row_kind,
        seq      TYPE zxml_formrow_map-seq,
        xml_name TYPE string,
        src_type TYPE string,
        src_name TYPE string,
        fmt      TYPE string,
      END OF ty_row_map,
      tt_row_map TYPE STANDARD TABLE OF ty_row_map WITH EMPTY KEY.

    CLASS-METHODS:

      load_form_cfg
        IMPORTING i_form_id TYPE zxml_form_cfg-form_id
        EXPORTING e_form    TYPE ty_cfg_form
                  et_tbl    TYPE tt_cfg_table
                  et_kv     TYPE tt_kv_map
                  et_row    TYPE tt_row_map,

      get_itab_ref
        IMPORTING i_table_id TYPE zxmlformtablecfg-table_id
                  it_refs    TYPE tt_table_data_ref
        RETURNING VALUE(ro)  TYPE REF TO data,

      write_kv_section
        IMPORTING io_wr     TYPE REF TO if_sxml_writer
                  it_kv     TYPE tt_kv_map
                  i_section TYPE zxml_form_kv_map-zsection
                  i_ctx     TYPE any,

      write_regions
        IMPORTING io_wr        TYPE REF TO if_sxml_writer
                  it_cfg_tbl   TYPE tt_cfg_table
                  it_row_map   TYPE tt_row_map
                  it_table_ref TYPE tt_table_data_ref
                  i_location   TYPE zxmlformtablecfg-location,

      read_value
        IMPORTING i_row     TYPE any
                  i_src     TYPE string
                  i_name    TYPE string
                  i_fmt     TYPE string
        RETURNING VALUE(rv) TYPE string,

      escape_xml
        IMPORTING i_text    TYPE string
        RETURNING VALUE(rv) TYPE string.

    CLASS-METHODS emit_open_tags
      IMPORTING io_wr TYPE REF TO if_sxml_writer
                i_seq TYPE string.        "vd: '<formTable><Table1>'

    CLASS-METHODS emit_close_tags
      IMPORTING io_wr TYPE REF TO if_sxml_writer
                i_seq TYPE string.        "vd: '</Table1></formTable>'
ENDCLASS.



CLASS ZCL_ADS_XML_BUILDER IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  ENDMETHOD.


  METHOD build_xml_by_form.
    DATA: ls_form TYPE ty_cfg_form,
          lt_tbl  TYPE tt_cfg_table,
          lt_kv   TYPE tt_kv_map,
          lt_row  TYPE tt_row_map.

    load_form_cfg(
      EXPORTING
        i_form_id = i_form_id
      IMPORTING
        e_form    = ls_form
        et_tbl    = lt_tbl
        et_kv     = lt_kv
        et_row    = lt_row ).

    " 1) Tạo writer string (class cụ thể)
    DATA lo_str TYPE REF TO cl_sxml_string_writer.
    lo_str = cl_sxml_string_writer=>create( ).

    " 2) Dùng interface để ghi (set_option, open/close element, write_value…)
    DATA lo_wr  TYPE REF TO if_sxml_writer.
    lo_wr = CAST if_sxml_writer( lo_str ).
    lo_wr->set_option( if_sxml_writer=>co_opt_linebreaks ).

    " 3) Dùng lo_wr ở các call phía dưới
    IF ls_form-root_open IS NOT INITIAL.
      emit_open_tags( io_wr = lo_wr i_seq = ls_form-root_open ).
    ENDIF.

    IF ls_form-header_open IS NOT INITIAL.
      emit_open_tags( io_wr = lo_wr i_seq = ls_form-header_open ).
    ENDIF.

    write_kv_section(
      io_wr     = lo_wr
      it_kv     = lt_kv
      i_section = c_section_header
      i_ctx     = i_header_ctx ).

    write_regions(
      io_wr        = lo_wr
      it_cfg_tbl   = lt_tbl
      it_row_map   = lt_row
      it_table_ref = it_table_data
      i_location   = c_loc_header ).

    IF ls_form-header_close IS NOT INITIAL.
      emit_close_tags( io_wr = lo_wr i_seq = ls_form-header_close ).
    ENDIF.

    " ===== BODY =====
    write_regions(
      io_wr        = lo_wr
      it_cfg_tbl   = lt_tbl
      it_row_map   = lt_row
      it_table_ref = it_table_data
      i_location   = c_loc_body ).

    " ===== FOOTER =====
    IF ls_form-footer_open IS NOT INITIAL.
      emit_open_tags( io_wr = lo_wr i_seq = ls_form-footer_open ).
    ENDIF.

    write_kv_section(
      io_wr     = lo_wr
      it_kv     = lt_kv
      i_section = c_section_footer
      i_ctx     = i_footer_ctx ).

    write_regions(
      io_wr        = lo_wr
      it_cfg_tbl   = lt_tbl
      it_row_map   = lt_row
      it_table_ref = it_table_data
      i_location   = c_loc_footer ).

    IF ls_form-footer_close IS NOT INITIAL.
      emit_close_tags( io_wr = lo_wr i_seq = ls_form-footer_close ).
    ENDIF.

    " ===== ROOT CLOSE =====
    IF ls_form-root_close IS NOT INITIAL.
      emit_close_tags( io_wr = lo_wr i_seq = ls_form-root_close ).
    ENDIF.

    " 2) Lấy XML ra (GET_OUTPUT của CL_SXML_STRING_WRITER)
    rv_xml = lo_str->get_output( ).
  ENDMETHOD.


  METHOD load_form_cfg.
    CLEAR: e_form, et_tbl, et_kv, et_row.

    " Form skeleton
    SELECT SINGLE form_id,
                  report_name,
                  root_open, root_close,
                  header_open, header_close,
                  footer_open, footer_close
      FROM zxml_form_cfg
      WHERE form_id = @i_form_id
      INTO CORRESPONDING FIELDS OF @e_form.

    " Tables (regions)
    SELECT form_id, table_id, container_id, seq, open_mode, location,
           table_open, row_open, row_close, table_close,
           name, prefix_xml, suffix_xml
      FROM zxmlformtablecfg
      WHERE form_id = @i_form_id
      ORDER BY seq
      INTO TABLE @et_tbl.

    " KV maps (header/footer)
    SELECT form_id, zsection, seq, node_name, src_type, src_name, fmt
      FROM zxml_form_kv_map
      WHERE form_id = @i_form_id
      ORDER BY zsection, seq
      INTO TABLE @et_kv.

    " Row maps
    SELECT form_id, table_id, row_kind, seq, xml_name, src_type, src_name, fmt
      FROM zxml_formrow_map
      WHERE form_id = @i_form_id
      ORDER BY table_id, row_kind, seq
      INTO TABLE @et_row
      .
  ENDMETHOD.


  METHOD get_itab_ref.
    CLEAR ro.  "khởi tạo về initial (ref rỗng)

    READ TABLE it_refs WITH KEY table_id = i_table_id INTO DATA(ls).
    IF sy-subrc = 0.
      ro = ls-dref.   "gán ref lấy được
    ENDIF.
  ENDMETHOD.


  METHOD write_kv_section.
    " io_wr phải khai báo:  TYPE REF TO if_sxml_writer
    DATA lt_this TYPE tt_kv_map.
    LOOP AT it_kv INTO DATA(ls_all) WHERE zsection = i_section.
      APPEND ls_all TO lt_this.
    ENDLOOP.

    LOOP AT lt_this INTO DATA(ls).
      DATA(lv) = read_value(
        i_row  = i_ctx
        i_src  = ls-src_type
        i_name = ls-src_name
        i_fmt  = ls-fmt ).

      " <NodeName>value</NodeName>
      io_wr->open_element( name = ls-node_name ).
      IF lv IS NOT INITIAL.
        io_wr->write_value( lv ).              "write_value tự escape XML
      ENDIF.
      io_wr->close_element( ).
    ENDLOOP.
  ENDMETHOD.


  METHOD write_regions.
    DATA lt_reg TYPE tt_cfg_table.
    LOOP AT it_cfg_tbl INTO DATA(ls_reg) WHERE location = i_location.
      APPEND ls_reg TO lt_reg.
    ENDLOOP.
    SORT lt_reg BY seq.

    LOOP AT lt_reg INTO ls_reg.
      " lấy itab
      DATA(lo_tabref) = get_itab_ref( i_table_id = ls_reg-table_id it_refs = it_table_ref ).
      IF lo_tabref IS INITIAL. CONTINUE. ENDIF.
      ASSIGN lo_tabref->* TO FIELD-SYMBOL(<lt_any>).
      IF sy-subrc <> 0. CONTINUE. ENDIF.

      " row map
      DATA lt_rowmap TYPE tt_row_map.
      LOOP AT it_row_map INTO DATA(lr) WHERE table_id = ls_reg-table_id.
        APPEND lr TO lt_rowmap.
      ENDLOOP.
      SORT lt_rowmap BY seq.
      IF lt_rowmap IS INITIAL. CONTINUE. ENDIF.

      " OPEN
      IF ls_reg-prefix_xml IS NOT INITIAL.
        emit_open_tags( io_wr = io_wr i_seq = ls_reg-prefix_xml ).
      ENDIF.

      IF ls_reg-open_mode = 'OPEN' OR ls_reg-open_mode = 'OPEN_CLOSE'.
        IF ls_reg-table_open IS NOT INITIAL.
          emit_open_tags( io_wr = io_wr i_seq = ls_reg-table_open ).
        ENDIF.
      ENDIF.

      " LOOP ROWS
      FIELD-SYMBOLS <row> TYPE any.
      LOOP AT <lt_any> ASSIGNING <row>.
        IF ls_reg-row_open IS NOT INITIAL.
          emit_open_tags( io_wr = io_wr i_seq = ls_reg-row_open ).
        ENDIF.

        LOOP AT lt_rowmap INTO lr.
          DATA(lv_val) = read_value( i_row  = <row>
                                     i_src  = lr-src_type
                                     i_name = lr-src_name
                                     i_fmt  = lr-fmt ).
          " <XmlName>Value</XmlName>
          io_wr->open_element( name = lr-xml_name ).
          IF lv_val IS NOT INITIAL.
            io_wr->write_value( lv_val ).              "write_value tự escape XML
          ENDIF.
          io_wr->close_element( ).
        ENDLOOP.

        IF ls_reg-row_close IS NOT INITIAL.
          emit_close_tags( io_wr = io_wr i_seq = ls_reg-row_close ).
        ENDIF.
      ENDLOOP.

      " CLOSE
      IF ls_reg-open_mode = 'CLOSE' OR ls_reg-open_mode = 'OPEN_CLOSE'.
        IF ls_reg-table_close IS NOT INITIAL.
          emit_close_tags( io_wr = io_wr i_seq = ls_reg-table_close ).
        ENDIF.
      ENDIF.
      IF ls_reg-suffix_xml IS NOT INITIAL.
        emit_close_tags( io_wr = io_wr i_seq = ls_reg-suffix_xml ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD read_value.
    DATA(lv) = ``.
    DATA: lv_num TYPE decfloat34.
    DATA: lv_numx TYPE decfloat34.

    CASE i_src.
      WHEN c_src_field.
        ASSIGN COMPONENT i_name OF STRUCTURE i_row TO FIELD-SYMBOL(<v>).
        IF sy-subrc = 0.
          CASE i_fmt.
            WHEN c_fmt_date_vn.
              DATA(ld) = CONV d( <v> ).
              IF ld IS NOT INITIAL.
                lv = |Ngày { ld+6(2) } tháng { ld+4(2) } năm { ld+0(4) }|.
              ENDIF.
            WHEN c_fmt_curr.
              IF <v> IS NOT INITIAL.
                lv_num = CONV decfloat34( <v> ).
                lv = |{ lv_num SIGN = LEFT DECIMALS = 2 }|.
              ENDIF.

            WHEN c_fmt_curr_x100vn.
              IF <v> IS NOT INITIAL.
                lv_numx = CONV decfloat34( <v> ) * 100.
                lv = |{ lv_numx SIGN = LEFT DECIMALS = 2 }|.
              ENDIF.
            WHEN c_fmt_text.              "<<< THÊM: TEXT
              lv = CONV string( <v> ).
          ENDCASE.
        ENDIF.
      WHEN OTHERS. "CONST
        lv = i_name.
    ENDCASE.
    rv = lv.
  ENDMETHOD.


  METHOD escape_xml.
    rv = i_text.
    REPLACE ALL OCCURRENCES OF '&'  IN rv WITH '&amp;'.
    REPLACE ALL OCCURRENCES OF '<'  IN rv WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '>'  IN rv WITH '&gt;'.
    REPLACE ALL OCCURRENCES OF '"'  IN rv WITH '&quot;'.
    REPLACE ALL OCCURRENCES OF '''' IN rv WITH '&apos;'.
  ENDMETHOD.


  METHOD emit_open_tags.
    "=== OPEN: chuyển chuỗi '<A><B>' thành các open_element tương ứng ===
    DATA(lv) = i_seq.

    WHILE lv CS '<'.
      DATA(beg)    = sy-fdpos.                         "vị trí '<'
      DATA(endpos) = find( val = lv sub = '>' ).       "vị trí '>'
      IF endpos < 0. EXIT. ENDIF.

      DATA(len)   = endpos - beg + 1.
      DATA(token) = substring( val = lv off = beg len = len ).  "<A>", "</A>", "<?xml ...?>", "<!--...-->"
      "Bỏ '<?...?>' (processing instruction) và '<!-- ... -->' (comment)
      IF token CP '<\?*>' OR token CP '<!--*-->'.
        lv = substring( val = lv off = endpos + 1 ).
        CONTINUE.
      ENDIF.

      "Lấy tên thẻ (bỏ '<' '>')
      DATA(name)  = substring( val = token off = 1 len = strlen( token ) - 2 ). "A hoặc /A hoặc 'subform name="X"'
      "Bỏ closing
      IF name(1) = '/'.
        lv = substring( val = lv off = endpos + 1 ).
        CONTINUE.
      ENDIF.

      "Cắt thuộc tính nếu có (đến khoảng trắng chuẩn)
      DATA spacec TYPE c LENGTH 1 VALUE cl_abap_char_utilities=>backspace.

      DATA(sp) = find( val = name sub = spacec ).
      IF sp >= 0.
        name = substring( val = name off = 0 len = sp ).
      ENDIF.

      IF name IS NOT INITIAL.
        io_wr->open_element( name = name ).
      ENDIF.

      "cắt bỏ token vừa xử lý
      lv = substring( val = lv off = endpos + 1 ).
    ENDWHILE.
  ENDMETHOD.


  METHOD emit_close_tags.
    "=== CLOSE: chuyển chuỗi '</B></A>' thành các close_element theo stack ===
    "Đếm số '</' trong chuỗi
    DATA(cnt) = count( val = i_seq sub = '</' ).
    DO cnt TIMES.
      io_wr->close_element( ).
    ENDDO.
  ENDMETHOD.
ENDCLASS.

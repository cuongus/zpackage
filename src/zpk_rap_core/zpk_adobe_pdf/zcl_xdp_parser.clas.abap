CLASS zcl_xdp_parser DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

    TYPES: BEGIN OF ty_node,
             depth     TYPE i,
             tag       TYPE string,   "tên local (đã bỏ namespace)
             name_attr TYPE string,   "giá trị attribute name (nếu có)
             path      TYPE string,   "ví dụ: /Form/Main/formHeader/FullName
             is_leaf   TYPE abap_bool,
           END OF ty_node.
    TYPES ty_t_node TYPE STANDARD TABLE OF ty_node WITH EMPTY KEY.

    TYPES: BEGIN OF ty_alias,
             from TYPE string,
             to   TYPE string,
           END OF ty_alias.
    TYPES ty_t_alias TYPE STANDARD TABLE OF ty_alias WITH EMPTY KEY.

    " Parse XDP -> list node; i_xdp: nội dung XDP (XSTRING UTF-8)
    CLASS-METHODS parse
      IMPORTING
        i_xdp_xstr    TYPE xstring
        i_filter_root TYPE string OPTIONAL  "ví dụ: '/Form/Main'
      RETURNING
        VALUE(rt)     TYPE ty_t_node
      RAISING
        cx_root.

    CLASS-METHODS build_template_from_nodes
      IMPORTING
        it_nodes      TYPE ty_t_node
        it_alias      TYPE ty_t_alias OPTIONAL   "vd: ( 'Createby' -> 'Createdby' )
        iv_root_trim  TYPE string     OPTIONAL   "mặc định '/xdp/template'
      RETURNING
        VALUE(rv_xml) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS node_name_local
      IMPORTING i_node    TYPE REF TO if_ixml_node
      RETURNING VALUE(rv) TYPE string.

    CLASS-METHODS attr_value
      IMPORTING i_node TYPE REF TO if_ixml_node i_attr TYPE string
      RETURNING VALUE(rv) TYPE string.

    CLASS-METHODS is_structural
      IMPORTING i_local_name TYPE string
      RETURNING VALUE(rv)    TYPE abap_bool.

    CLASS-METHODS traverse
      IMPORTING
        i_node  TYPE REF TO if_ixml_node
        i_path  TYPE string
        i_depth TYPE i
      CHANGING
        ct_rows TYPE ty_t_node.

ENDCLASS.



CLASS ZCL_XDP_PARSER IMPLEMENTATION.


  METHOD node_name_local.
    DATA(name) = i_node->get_name( ).
    FIND FIRST OCCURRENCE OF ':' IN name MATCH OFFSET DATA(off).
    rv = COND string( WHEN sy-subrc = 0 THEN name + off + 1 ELSE name ).
  ENDMETHOD.


  METHOD attr_value.
    DATA(lo_elem) = CAST if_ixml_element( i_node ).
    IF lo_elem IS BOUND.
      DATA(lo_attr) = lo_elem->get_attributes( ).
      IF lo_attr IS BOUND.
        DATA(lo_item) = lo_attr->get_named_item( i_attr ).
        IF lo_item IS BOUND.
          rv = lo_item->get_value( ).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD is_structural.
    "Các tag cấu trúc hay gặp trong XDP/LiveCycle
    DATA lt TYPE STANDARD TABLE OF zde_char100 WITH EMPTY KEY.
    lt = VALUE #( ( 'subform' )     ( 'subformSet' ) ( 'field' ) ( 'exclGroup' )
                  ( 'draw' )        ( 'occur' )      ( 'text' )  ( 'image' )
                  ( 'numericEdit' ) ( 'textEdit' )   ( 'dateTimeEdit' )
                  ( 'caption' )     ( 'ui' )         ( 'value' ) ( 'font' ) ( 'para' ) ).
    rv = xsdbool( line_exists( lt[ table_line = i_local_name ] ) ).
  ENDMETHOD.


  METHOD traverse.
    DATA(local)     = node_name_local( i_node ).
    DATA(name_attr) = attr_value( i_node = i_node i_attr = 'name' ).
    DATA(seg)       = COND string( WHEN name_attr IS NOT INITIAL THEN name_attr ELSE local ).
    DATA(new_path)  = COND string( WHEN i_path IS INITIAL THEN |/{ seg }| ELSE |{ i_path }/{ seg }| ).

    DATA(lo_list) = i_node->get_children( ).
    DATA(has_struct) = abap_false.

    "---- DUYỆT CON = iterator (Steampunk OK)
    IF lo_list IS BOUND.
      DATA(lo_it) = lo_list->create_iterator( ).
      DATA(lo_child) = lo_it->get_next( ).
      WHILE lo_child IS BOUND.
        IF is_structural( node_name_local( lo_child ) ) = abap_true.
          has_struct = abap_true.
          EXIT.
        ENDIF.
        lo_child = lo_it->get_next( ).
      ENDWHILE.
    ENDIF.

    APPEND VALUE ty_node(
      depth     = i_depth
      tag       = local
      name_attr = name_attr
      path      = new_path
      is_leaf   = xsdbool( has_struct = abap_false )
    ) TO ct_rows.

    "---- Đệ quy: cũng dùng iterator
    IF lo_list IS BOUND.
      DATA(lo_it2) = lo_list->create_iterator( ).
      DATA(lo_child2) = lo_it2->get_next( ).
      WHILE lo_child2 IS BOUND.
        traverse(
          EXPORTING
            i_node  = lo_child2
            i_path  = new_path
            i_depth = i_depth + 1
          CHANGING
            ct_rows = ct_rows ).
        lo_child2 = lo_it2->get_next( ).
      ENDWHILE.
    ENDIF.
  ENDMETHOD.


  METHOD parse.
    "=== Parse XDP (XSTRING) bằng SXML Reader – Cloud-safe ===

    "Stack để tính path & xác định leaf
    TYPES: BEGIN OF ty_stack,
             path      TYPE string,
             row_index TYPE i,
             has_child TYPE abap_bool,
           END OF ty_stack.
    DATA lt_stack TYPE STANDARD TABLE OF ty_stack WITH EMPTY KEY.
    DATA lt_all   TYPE ty_t_node.

    "1) Tạo reader từ XSTRING (không convert; KHÔNG có tham số TYPE)
    DATA(lo_reader) = cl_sxml_string_reader=>create(
      input           = i_xdp_xstr
      normalizing     = abap_false
      keep_whitespace = abap_false ).

    "2) Duyệt event
    DO.                                           "loop cho đến khi gặp FINAL
      TRY.
          lo_reader->next_node( ).                "không RETURNING
        CATCH cx_sxml_parse_error.
          EXIT.                                   "lỗi parse -> dừng
      ENDTRY.

      IF lo_reader->node_type = if_sxml_node=>co_nt_final.
        EXIT.
      ENDIF.

      CASE lo_reader->node_type.

        WHEN if_sxml_node=>co_nt_element_open.

          " local-name (bỏ prefix)
          DATA(lv_local) = lo_reader->name.
          FIND FIRST OCCURRENCE OF ':' IN lv_local MATCH OFFSET DATA(lv_off).
          IF sy-subrc = 0.
            lv_local = lv_local + lv_off + 1.
          ENDIF.

          " attribute name="..."
          DATA lv_attr_name TYPE string.
          TRY.
              lo_reader->get_attribute_value( name = 'name' ).  "KHÔNG RETURNING
              lv_attr_name =  lo_reader->value .   "=> đọc ở thuộc tính VALUE
            CATCH cx_sxml_parse_error cx_sxml_state_error.
              CLEAR lv_attr_name.
          ENDTRY.

          " path mới
          DATA(lv_seg)  = COND string( WHEN lv_attr_name IS NOT INITIAL THEN lv_attr_name ELSE lv_local ).
          DATA(lv_path) = COND string(
                            WHEN lt_stack IS INITIAL
                            THEN |/{ lv_seg }|
                            ELSE |{ lt_stack[ lines( lt_stack ) ]-path }/{ lv_seg }| ).

          " đánh dấu parent có child
          IF lines( lt_stack ) > 0.
            lt_stack[ lines( lt_stack ) ]-has_child = abap_true.
          ENDIF.

          " THÊM NODE HIỆN TẠI  → dùng kiểu dòng ty_node, KHÔNG phải ty_t_node
          APPEND VALUE ty_node(
            depth     = lines( lt_stack )
            tag       = lv_local
            name_attr = lv_attr_name
            path      = lv_path
            is_leaf   = abap_false ) TO lt_all.

          " push vào stack
          APPEND VALUE ty_stack(
            path      = lv_path
            row_index = lines( lt_all )
            has_child = abap_false ) TO lt_stack.

        WHEN if_sxml_node=>co_nt_element_close.
          "pop; nếu không có child -> leaf
          IF lt_stack IS NOT INITIAL.
            DATA(ls_top) = lt_stack[ lines( lt_stack ) ].
            DELETE lt_stack INDEX lines( lt_stack ).
            IF ls_top-has_child = abap_false AND ls_top-row_index > 0.
              lt_all[ ls_top-row_index ]-is_leaf = abap_true.
            ENDIF.
          ENDIF.

        WHEN OTHERS.
          "bỏ qua text/comment/attribute nodes
      ENDCASE.
    ENDDO.

    "3) Trả về (lọc nhánh nếu cần)
    IF i_filter_root IS SUPPLIED AND i_filter_root IS NOT INITIAL.
      LOOP AT lt_all ASSIGNING FIELD-SYMBOL(<r>) WHERE path CS i_filter_root.
        APPEND <r> TO rt.
      ENDLOOP.
    ELSE.
      rt = lt_all.
    ENDIF.
  ENDMETHOD.


  METHOD build_template_from_nodes.

    "--- 0) Tham số mặc định
    DATA(lv_trim) = COND string( WHEN iv_root_trim IS INITIAL THEN '/xdp/template' ELSE iv_root_trim ).

    "--- 1) Lọc field bindable: TAG = 'field'
    TYPES: BEGIN OF ty_field,
             path TYPE string,
             name TYPE string,
           END OF ty_field.
    TYPES ty_t_field TYPE STANDARD TABLE OF ty_field WITH EMPTY KEY.
    DATA lt_fields TYPE ty_t_field.

    LOOP AT it_nodes ASSIGNING FIELD-SYMBOL(<n>) WHERE tag = 'field' AND name_attr IS NOT INITIAL AND path IS NOT INITIAL.
      DATA(lv_path) = <n>-path.
      "chuẩn hoá: bỏ tiền tố /xdp/template
      IF lv_trim IS NOT INITIAL AND lv_path CS lv_trim.
        REPLACE FIRST OCCURRENCE OF lv_trim IN lv_path WITH ''.
      ENDIF.
      "đảm bảo path bắt đầu bằng '/'
      IF lv_path IS INITIAL OR lv_path(1) <> '/'.
        lv_path = |/{ lv_path }|.
      ENDIF.
      APPEND VALUE ty_field( path = lv_path name = <n>-name_attr ) TO lt_fields.
    ENDLOOP.

    "Không có field nào -> trả rỗng
    IF lt_fields IS INITIAL.
      RETURN.
    ENDIF.

    "--- 2) Áp alias tên field (nếu có)
    IF it_alias IS SUPPLIED AND it_alias IS NOT INITIAL.
      LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<f1>).
        READ TABLE it_alias ASSIGNING FIELD-SYMBOL(<a>) WITH KEY from = <f1>-name.
        IF sy-subrc = 0 AND <a>-to IS NOT INITIAL.
          <f1>-name = <a>-to.
          "Đổi segment cuối của path theo alias
          DATA(segments1) = VALUE stringtab( ).

          SPLIT <f1>-path AT '/' INTO TABLE segments1.
          DELETE segments1 WHERE table_line IS INITIAL.
          IF lines( segments1 ) > 0.
            segments1[ lines( segments1 ) ] = <f1>-name.
            DATA(lv_new) = ''.
            LOOP AT segments1 ASSIGNING FIELD-SYMBOL(<s>).
              lv_new = |{ lv_new }/{ <s> }|.
            ENDLOOP.
            <f1>-path = lv_new.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    "--- 3) Loại trùng đường dẫn, sắp xếp theo path
    SORT lt_fields BY path.
    DELETE ADJACENT DUPLICATES FROM lt_fields COMPARING path.

    "--- 4) Writer SXML
    " 1) Tạo writer string (class cụ thể)
    DATA lo_str TYPE REF TO cl_sxml_string_writer.
    lo_str = cl_sxml_string_writer=>create( ).

    " 2) Dùng interface để ghi (set_option, open/close element, write_value…)
    DATA lo_wr  TYPE REF TO if_sxml_writer.
    lo_wr = CAST if_sxml_writer( lo_str ).
    lo_wr->set_option( if_sxml_writer=>co_opt_linebreaks ).

    "Stack các segment đã mở
    DATA lt_stack TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv TYPE string.

    LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<f>).

      "Tách segment của path hiện tại
      DATA(segments) = VALUE stringtab( ).
      SPLIT <f>-path AT '/' INTO TABLE segments.
      DELETE segments WHERE table_line IS INITIAL.

      "Tìm prefix chung với stack
      DATA i TYPE i VALUE 0.
      WHILE i < lines( lt_stack ) AND i < lines( segments )
        AND lt_stack[ i + 1 ] = segments[ i + 1 ].
        i = i + 1.
      ENDWHILE.

      "Đóng tag dư
      DO lines( lt_stack ) - i TIMES.
        lo_wr->close_element( ).
        DELETE lt_stack INDEX lines( lt_stack ).
      ENDDO.

      "Mở các container thiếu (tất cả segment trừ lá)
      DO lines( segments ) - i - 1 TIMES.
        lo_wr->open_element( name = segments[ i + sy-index ] ).
        APPEND segments[ i + sy-index ] TO lt_stack.
      ENDDO.

      "Ghi lá với placeholder {FieldName}
      DATA(lv_leaf) = segments[ lines( segments ) ].

      lv = `{` && | && <f>-name && | && `}`.
      lo_wr->open_element( name = lv_leaf ).
      lo_wr->write_value( lv ).   "<<< sửa tại đây (hoặc dùng {{{ expr }}} )
      lo_wr->close_element( ).
    ENDLOOP.

    "Đóng phần còn mở
    WHILE lines( lt_stack ) > 0.
      lo_wr->close_element( ).
      DELETE lt_stack INDEX lines( lt_stack ).
    ENDWHILE.

    rv_xml = lo_str->get_output( ).

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

    SELECT SINGLE file_content FROM zcore_tb_temppdf
    WHERE id = 'zphieuketoan'
    INTO @DATA(lv_b64).

    DATA lv_xdp TYPE xstring.

    lv_xdp = lv_b64.

    TRY.
        DATA(nodes) = zcl_xdp_parser=>parse(
          i_xdp_xstr    = lv_xdp
          i_filter_root = '/Form/Main' ).

        DATA(lv_xml) = zcl_xdp_parser=>build_template_from_nodes(
          it_nodes     = nodes
          iv_root_trim = '/xdp/template' ).

      CATCH cx_root.
        "handle exception
    ENDTRY.

  ENDMETHOD.
ENDCLASS.

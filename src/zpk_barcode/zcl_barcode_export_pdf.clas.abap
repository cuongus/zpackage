CLASS zcl_barcode_export_pdf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      keys_pkt     TYPE TABLE FOR ACTION IMPORT zc_barcode~btnprintpdf,
      result_pkt   TYPE TABLE FOR ACTION RESULT zc_barcode~btnprintpdf,
      mapped_pkt   TYPE RESPONSE FOR MAPPED EARLY zc_barcode,
      failed_pkt   TYPE RESPONSE FOR FAILED EARLY zc_barcode,
      reported_pkt TYPE RESPONSE FOR REPORTED EARLY zc_barcode.

    CLASS-METHODS:
      btnPrintPDF IMPORTING keys     TYPE keys_pkt
                  EXPORTING o_pdf    TYPE string
                  CHANGING  result   TYPE result_pkt
                            mapped   TYPE mapped_pkt
                            failed   TYPE failed_pkt
                            reported TYPE reported_pkt.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA:
      ir_document      TYPE zcl_barcode=>tt_ranges,
      ir_lineindex     TYPE zcl_barcode=>tt_ranges,
      ir_document_item TYPE zcl_barcode=>tt_ranges,
      ir_plant         TYPE zcl_barcode=>tt_ranges,
      ir_qc            TYPE zcl_barcode=>tt_ranges,
      ir_keeper        TYPE zcl_barcode=>tt_ranges,
      ir_matnr_number  TYPE zcl_barcode=>tt_ranges,
      ir_batch         TYPE zcl_barcode=>tt_ranges,
      ir_header        TYPE zcl_barcode=>tt_ranges,
      ir_print_multi   TYPE zcl_barcode=>tt_ranges,
      ir_vas           TYPE zcl_barcode=>tt_ranges,
      ir_quantity      TYPE zcl_barcode=>tt_ranges,
      ir_sloc          TYPE zcl_barcode=>tt_ranges,
      ir_so            TYPE zcl_barcode=>tt_ranges,
      ir_soi           TYPE zcl_barcode=>tt_ranges,
      ir_supplier      TYPE zcl_barcode=>tt_ranges,
      ir_option        TYPE zcl_barcode=>tt_ranges.

    TYPES: BEGIN OF ty_document_key,
             Document      TYPE string,
             lineindex     TYPE string,
             Document_Item TYPE string,
             plant         TYPE string,
             option_name   TYPE string,
             matnr_number  TYPE matnr,
             batch         TYPE string,
             header_type   TYPE string,
             print_multi   TYPE string,
             qc            TYPE string,
             keeper        TYPE string,
             vas           TYPE string,
             sloc          TYPE string,
             so            TYPE string,
             Supplier      TYPE string,
             soi           TYPE string,
             Quantity      TYPE string,
           END OF ty_document_key.

    TYPES: tt_doc_keys TYPE STANDARD TABLE OF ty_document_key WITH EMPTY KEY.

    CLASS-METHODS:  normalize_comma_string
      IMPORTING
        iv_input         TYPE string
      RETURNING
        VALUE(rv_output) TYPE string.


ENDCLASS.



CLASS zcl_barcode_export_pdf IMPLEMENTATION.


  METHOD normalize_comma_string.
    rv_output = iv_input.
    DATA: lv_len      TYPE i,
          lv_last_pos TYPE i.

    " Kiểm tra chuỗi rỗng
    IF rv_output IS INITIAL.
      RETURN.
    ENDIF.

    " Xử lý dấu phẩy ở đầu
    IF rv_output(1) = ','.
      rv_output = | ,| && rv_output+1.
    ENDIF.

    " Xử lý hai dấu phẩy liên tiếp
    REPLACE ALL OCCURRENCES OF ',,' IN rv_output WITH ', ,'.

    " Xử lý dấu phẩy ở cuối (phải làm SAU khi đã xử lý đầu và giữa)
    lv_len = strlen( rv_output ).
    IF lv_len > 0.
      lv_last_pos = lv_len - 1.
      IF rv_output+lv_last_pos(1) = ','.
        rv_output = rv_output(lv_last_pos) && ', ,'.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD btnPrintPDF.

    DATA: lt_doc_keys           TYPE tt_doc_keys,
          ls_doc_key            TYPE ty_document_key,
          lt_split_doc          TYPE TABLE OF string,
          lt_split_line         TYPE TABLE OF string,
          lt_split_plant        TYPE TABLE OF string,
          lt_split_matnr_number TYPE TABLE OF string,
          lt_split_vas          TYPE TABLE OF string,
          lt_split_quantity     TYPE TABLE OF string,
          lt_split_batch        TYPE TABLE OF string,
          lt_split_doc_item     TYPE TABLE OF string,
          lt_split_sloc         TYPE TABLE OF string,
          lt_split_soi          TYPE TABLE OF string,
          lt_split_spl          TYPE TABLE OF string,
          lt_split_so           TYPE TABLE OF string,

          lv_lineindex          TYPE string,
          lv_doc                TYPE string,
          lv_plant              TYPE string,
          lv_matnr_number       TYPE string,
          lv_batch              TYPE string,
          lv_doc_item           TYPE string,
          lv_vas                TYPE string,
          lv_quantity           TYPE string,
          lv_sloc               TYPE string,
          lv_soi                TYPE string,
          lv_spl                TYPE string,
          lv_so                 TYPE string,
          lv_index              TYPE i.
    DATA: lv_copy_counter TYPE i VALUE 1.

    READ TABLE keys INDEX 1 INTO DATA(k).

    DATA(lv_print_qty) = COND i( WHEN k-%param-print_quantity IS NOT INITIAL
                                   AND k-%param-print_quantity NE 'null'
                                 THEN CONV i( k-%param-print_quantity )
                                 ELSE 1 ).

*Đảm bảo print_quantity >= 1
    IF lv_print_qty < 1.
      lv_print_qty = 1.
    ENDIF.

    IF k-%param-Document IS NOT INITIAL AND k-%param-Document NE 'null'.
      DATA(lv_document_1) = normalize_comma_string( k-%param-Document ).
      SPLIT lv_document_1 AT ',' INTO TABLE lt_split_doc.
    ENDIF.

    IF k-%param-Supplier IS NOT INITIAL AND k-%param-Supplier NE 'null'.
      DATA(lv_supplier_1) = normalize_comma_string( k-%param-Supplier ).
      SPLIT lv_supplier_1 AT ',' INTO TABLE lt_split_spl.
    ENDIF.

    IF k-%param-Storage_Location IS NOT INITIAL AND k-%param-Storage_Location NE 'null'.
      DATA(lv_sloc_1) = normalize_comma_string( k-%param-Storage_Location ).
      SPLIT lv_sloc_1 AT ',' INTO TABLE lt_split_sloc.
    ENDIF.

*    IF k-%param-Sale_Order IS NOT INITIAL AND k-%param-Sale_Order NE 'null'.
*      DATA(lv_so_1) = k-%param-Sale_Order.
*      REPLACE ALL OCCURRENCES OF ',,' IN lv_so_1 WITH ', ,'.
*      SPLIT lv_so_1 AT ',' INTO TABLE lt_split_so.
*    ENDIF.

    IF k-%param-Sale_Order IS NOT INITIAL AND k-%param-Sale_Order NE 'null'.
      DATA(lv_so_1) = normalize_comma_string( k-%param-Sale_Order ).
      SPLIT lv_so_1 AT ',' INTO TABLE lt_split_so.
    ENDIF.

    IF k-%param-Sale_Order_item IS NOT INITIAL AND k-%param-Sale_Order_item NE 'null'.
      DATA(lv_soi_1) = normalize_comma_string( k-%param-Sale_Order_item ).
      SPLIT lv_soi_1 AT ',' INTO TABLE lt_split_soi.
    ENDIF.

    IF k-%param-Document_Item IS NOT INITIAL AND k-%param-Document_Item NE 'null'.
      DATA(lv_document_item_1) = normalize_comma_string( k-%param-Document_Item ).
      SPLIT lv_document_item_1 AT ',' INTO TABLE lt_split_doc_item.
    ENDIF.

    IF k-%param-plant IS NOT INITIAL AND k-%param-plant NE 'null'.
      SPLIT k-%param-plant AT ',' INTO TABLE lt_split_plant.
    ELSE.
      RETURN.
    ENDIF.

    IF k-%param-lineindex IS NOT INITIAL AND k-%param-lineindex NE 'null'.
      SPLIT k-%param-lineindex AT ',' INTO TABLE lt_split_line.
    ELSE.
      RETURN.
    ENDIF.

    IF k-%param-matnr_number IS NOT INITIAL AND k-%param-matnr_number NE 'null'.
      DATA(lv_matnr_1) = normalize_comma_string( k-%param-matnr_number ).
      SPLIT lv_matnr_1 AT ',' INTO TABLE lt_split_matnr_number.
    ENDIF.

    "fix op 5
    IF k-%param-vas IS NOT INITIAL AND k-%param-vas NE 'null'.
      DATA(lv_vas_1) = normalize_comma_string( k-%param-vas ).
      SPLIT lv_vas_1 AT ',' INTO TABLE lt_split_vas.
    ENDIF.

    IF k-%param-quantity IS NOT INITIAL AND k-%param-quantity NE 'null'.
      DATA(lv_qty_1) = normalize_comma_string( k-%param-quantity ).
      SPLIT lv_qty_1 AT ',' INTO TABLE lt_split_quantity.
    ENDIF.

    IF k-%param-batch IS NOT INITIAL AND k-%param-batch NE 'null'.
      DATA(lv_batch_1) = normalize_comma_string( k-%param-batch ).
      "Tách chuỗi thành bảng
      SPLIT lv_batch_1 AT ',' INTO TABLE lt_split_batch.
    ENDIF.

    DATA(lv_keeper) = COND string( WHEN k-%param-keeper IS NOT INITIAL AND k-%param-keeper NE 'null'
                                             THEN k-%param-keeper ELSE '' ).
    DATA(lv_qc) = COND string( WHEN k-%param-qc IS NOT INITIAL AND k-%param-qc NE 'null'
                                             THEN k-%param-qc ELSE '' ).
    DATA(lv_header_type) = COND string( WHEN k-%param-header_type IS NOT INITIAL AND k-%param-header_type NE 'null'
                                             THEN k-%param-header_type ELSE '' ).
    DATA(lv_option_name) = COND string( WHEN k-%param-option_name IS NOT INITIAL AND k-%param-option_name NE 'null'
                                             THEN k-%param-option_name ELSE '' ).
    DATA(lv_print_multi) = COND string( WHEN k-%param-print_multi IS NOT INITIAL AND k-%param-print_multi NE 'null'
                                             THEN k-%param-print_multi ELSE '' ).

*    " Build document keys list
*    lv_index = 0.
*    LOOP AT lt_split_doc INTO lv_doc.
*      lv_index = lv_index + 1.
*
**lv_index = 0.
**LOOP AT lt_split_plant INTO lv_plant.
**  lv_index = lv_index + 1.
*
**      CONDENSE lv_doc NO-GAPS.
**      IF lv_doc IS INITIAL.
**        CONTINUE.
**      ENDIF.
*      READ TABLE lt_split_doc_item INDEX lv_index INTO lv_doc_item.
*      READ TABLE lt_split_plant INDEX lv_index INTO lv_plant.
*      READ TABLE lt_split_matnr_number INDEX lv_index INTO lv_matnr_number.
*      READ TABLE lt_split_batch INDEX lv_index INTO lv_batch.
**      CONDENSE lv_plant  NO-GAPS.
**      CONDENSE lv_matnr_number NO-GAPS.
**      CONDENSE lv_batch NO-GAPS.
**      CONDENSE lv_doc_item NO-GAPS.
*
*      CLEAR ls_doc_key.
*      ls_doc_key-document = lv_doc.
*      ls_doc_key-document_item = lv_doc_item.
*      ls_doc_key-plant       = lv_plant.
*      ls_doc_key-matnr_number = lv_matnr_number.
*      ls_doc_key-batch       = lv_batch.
*      ls_doc_key-header_type       = lv_header_type.
*      ls_doc_key-option_name       = lv_option_name.
*      ls_doc_key-print_multi       = lv_print_multi.
*      ls_doc_key-keeper       = lv_keeper.
*      ls_doc_key-qc       = lv_qc.
*
*      APPEND ls_doc_key TO lt_doc_keys.
*    ENDLOOP.

    lv_index = 0.
    CASE lv_option_name.
      WHEN '1' OR '2' OR '3' .
        LOOP AT lt_split_doc INTO lv_doc.
          lv_index = lv_index + 1.

          READ TABLE lt_split_doc_item INDEX lv_index INTO lv_doc_item.
          READ TABLE lt_split_plant INDEX lv_index INTO lv_plant.
          READ TABLE lt_split_matnr_number INDEX lv_index INTO lv_matnr_number.
          READ TABLE lt_split_batch INDEX lv_index INTO lv_batch.
          READ TABLE lt_split_sloc INDEX lv_index INTO lv_sloc.

          CLEAR ls_doc_key.
          ls_doc_key-document       = lv_doc.
          ls_doc_key-document_item  = lv_doc_item.
          ls_doc_key-plant          = lv_plant.
          ls_doc_key-matnr_number   = lv_matnr_number.
          ls_doc_key-batch          = lv_batch.
          ls_doc_key-sloc             = lv_sloc.
          ls_doc_key-header_type    = lv_header_type.
          ls_doc_key-option_name    = lv_option_name.
          ls_doc_key-print_multi    = lv_print_multi.
          ls_doc_key-keeper         = lv_keeper.
          ls_doc_key-qc             = lv_qc.

          APPEND ls_doc_key TO lt_doc_keys.
        ENDLOOP.

      WHEN '4'.
        LOOP AT lt_split_matnr_number INTO lv_matnr_number.
          lv_index = lv_index + 1.

          READ TABLE lt_split_doc INDEX lv_index INTO lv_doc.
          READ TABLE lt_split_doc_item INDEX lv_index INTO lv_doc_item.
          READ TABLE lt_split_plant INDEX lv_index INTO lv_plant.
          READ TABLE lt_split_batch INDEX lv_index INTO lv_batch.

          CLEAR ls_doc_key.
          ls_doc_key-document       = lv_doc.
          ls_doc_key-document_item  = lv_doc_item.
          ls_doc_key-plant          = lv_plant.
          ls_doc_key-matnr_number   = lv_matnr_number.
          ls_doc_key-batch          = lv_batch.
          ls_doc_key-header_type    = lv_header_type.
          ls_doc_key-option_name    = lv_option_name.
          ls_doc_key-print_multi    = lv_print_multi.
          ls_doc_key-keeper         = lv_keeper.
          ls_doc_key-qc             = lv_qc.

          APPEND ls_doc_key TO lt_doc_keys.
        ENDLOOP.

      WHEN '5'.
        LOOP AT lt_split_matnr_number INTO lv_matnr_number.
          lv_index = lv_index + 1.

          READ TABLE lt_split_doc INDEX lv_index INTO lv_doc.
          READ TABLE lt_split_doc_item INDEX lv_index INTO lv_doc_item.
          READ TABLE lt_split_plant INDEX lv_index INTO lv_plant.
          READ TABLE lt_split_batch INDEX lv_index INTO lv_batch.
          READ TABLE lt_split_line INDEX lv_index INTO lv_lineindex.
          READ TABLE lt_split_vas INDEX lv_index INTO lv_vas.
          READ TABLE lt_split_quantity INDEX lv_index INTO lv_quantity.
          READ TABLE lt_split_sloc INDEX lv_index INTO lv_sloc.
          READ TABLE lt_split_soi INDEX lv_index INTO lv_soi.
          READ TABLE lt_split_spl INDEX lv_index INTO lv_spl.
          READ TABLE lt_split_so INDEX lv_index INTO lv_so.


          CLEAR ls_doc_key.
          ls_doc_key-lineindex = lv_lineindex.
          ls_doc_key-document       = lv_doc.
          ls_doc_key-document_item  = lv_doc_item.
          ls_doc_key-plant          = lv_plant.
          ls_doc_key-matnr_number   = lv_matnr_number.
          ls_doc_key-batch          = lv_batch.
          ls_doc_key-header_type    = lv_header_type.
          ls_doc_key-option_name    = lv_option_name.
          ls_doc_key-print_multi    = lv_print_multi.
          ls_doc_key-supplier    = lv_spl.
          ls_doc_key-keeper         = lv_keeper.
          ls_doc_key-qc             = lv_qc.
          ls_doc_key-vas             = lv_vas.
          ls_doc_key-sloc             = lv_sloc.
          ls_doc_key-soi             = lv_soi.
          ls_doc_key-so             = lv_so.
          ls_doc_key-quantity       = lv_quantity.

          APPEND ls_doc_key TO lt_doc_keys.
        ENDLOOP.

    ENDCASE.

    DATA:
      lv_so_10 TYPE c LENGTH 10,
      lv_soi_6 TYPE c LENGTH 6.



    LOOP AT lt_doc_keys INTO DATA(ls_key).
      lv_so_10 = ls_key-so.
      IF lv_so_10 IS NOT INITIAL.
        ls_key-so = |{ lv_so_10 ALPHA = IN }|.
      ENDIF.

      lv_soi_6 = ls_key-soi.
      IF lv_soi_6 IS NOT INITIAL.
        ls_key-soi = |{ lv_soi_6 ALPHA = IN }|.
      ENDIF.

      DATA(lv_len_1) = strlen( ls_key-matnr_number ).
      DATA(lv_pad) = 18 - lv_len_1.
      DATA(lv_zeros) = repeat( val = '0' occ = lv_pad ).
      DATA(lv_matnr_conv) = lv_zeros && ls_key-matnr_number.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-Document ) TO ir_document.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-lineindex ) TO ir_lineindex.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-Document_Item ) TO ir_document_item.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-plant ) TO ir_plant.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-qc ) TO ir_qc.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-keeper ) TO ir_keeper.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-supplier ) TO ir_supplier.
*      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-matnr_number ) TO ir_matnr_number.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_matnr_conv ) TO ir_matnr_number.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-batch ) TO ir_batch.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-header_type ) TO ir_header.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-option_name ) TO ir_option.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-print_multi ) TO ir_print_multi.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-vas ) TO ir_vas.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-quantity ) TO ir_quantity.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-sloc ) TO ir_sloc.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-so ) TO ir_so.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_key-soi ) TO ir_soi.

      zcl_barcode=>get_inbound_delivery(
  EXPORTING
  ir_lineindex          = ir_lineindex
    ir_plant            = ir_plant
    ir_supplier         = ir_supplier
    ir_document         = ir_document
    ir_document_item    = ir_document_item
    ir_option           = ir_option
    ir_qc               = ir_qc
    ir_keeper           = ir_keeper
    ir_batch            = ir_batch
    ir_matnr_number     = ir_matnr_number
    ir_header           = ir_header
    ir_print_multi      = ir_print_multi
    ir_vas            = ir_vas
    ir_sloc            = ir_sloc
    ir_so         = ir_so
    ir_soi            = ir_soi
    ir_quantity       = ir_quantity
  IMPORTING
    e_barcore           = DATA(lt_barcode)
).
*      SORT lt_barcode.
*      DELETE ADJACENT DUPLICATES FROM lt_barcode.
*    SORT lt_barcode BY  .
*    DELETE ADJACENT DUPLICATES FROM lt_barcode COMPARING Document Document_Item batch.

      FREE: ir_document, ir_lineindex, ir_document_item, ir_plant, ir_qc,ir_vas, ir_quantity, ir_supplier,
            ir_keeper, ir_matnr_number, ir_batch, ir_header, ir_option, ir_print_multi,ir_sloc,ir_so,ir_soi.

    ENDLOOP.
*multiple lt_barcode
    DATA: lt_barcode_multiplied LIKE lt_barcode.
    IF lv_print_qty > 1.
      WHILE lv_copy_counter <= lv_print_qty.
        LOOP AT lt_barcode INTO DATA(ls_barcode_orig).
          APPEND ls_barcode_orig TO lt_barcode_multiplied.
        ENDLOOP.
        lv_copy_counter = lv_copy_counter + 1.
      ENDWHILE.
    ELSE.
      lt_barcode_multiplied = lt_barcode.
    ENDIF.


    lt_barcode = lt_barcode_multiplied.
    FREE lt_barcode_multiplied.

*    zcl_barcode=>get_inbound_delivery(
*      EXPORTING
*        ir_plant            = ir_plant
*        ir_document         = ir_document
*        ir_document_item    = ir_document_item
*        ir_option           = ir_option
*        ir_qc               = ir_qc
*        ir_keeper           = ir_keeper
*        ir_batch            = ir_batch
*        ir_matnr_number     = ir_matnr_number
*        ir_header           = ir_header
*        ir_print_multi      = ir_print_multi
*      IMPORTING
*        e_barcore           = DATA(lt_barcode)
*    ).

    SORT lt_barcode BY  Document Document_Item batch Material_description.
*    DELETE ADJACENT DUPLICATES FROM lt_barcode COMPARING Document Document_Item batch.


    DATA: lv_header    TYPE string,
          ls_name      TYPE string,
          qrxml        TYPE string,
          lv_date      TYPE dats,
          lv_matnr     TYPE char10,
          lv_solot     TYPE string,
          ls_qr        TYPE string,
          lv_date_text TYPE string,
          rowsxml      TYPE string,
          bannerxml    TYPE string.

    DATA: lv_xml_header TYPE string,
          lv_xml_footer TYPE string,
          lv_xml_body   TYPE string,
          xml           TYPE string.

    DATA: str_pdf TYPE string.


    DATA: lv_first_product_type TYPE string,
          lv_first_option       TYPE string,
          lv_first_print_multi  TYPE string,
          lv_template_id        TYPE string,
          lv_is_ccdc_template   TYPE abap_bool,
          lv_filename           TYPE string.


    lv_xml_header = |<?xml version="1.0" encoding="UTF-8"?><form1>|.
    lv_xml_footer = |</form1>|.


    LOOP AT lt_barcode INTO DATA(ls_barcode).

      lv_matnr = | { ls_barcode-matnr_number ALPHA = OUT } |.
      CONDENSE lv_matnr NO-GAPS.

      "xoa so 0
      DATA(lv_sale_order) = | { ls_barcode-Sale_Order ALPHA = OUT } |.
      DATA(lv_sale_order_item) = | { ls_barcode-Sale_Order_item ALPHA = OUT } |.
      CONDENSE lv_sale_order NO-GAPS.
      CONDENSE lv_sale_order_item NO-GAPS.


      SELECT SINGLE ProductType
        FROM c_bommaterialvh
        WHERE Product = @ls_barcode-matnr_number
        INTO @DATA(ls_Product_Type).

      SELECT SINGLE SearchTerm1
        FROM i_businesspartner
        WHERE BusinessPartner = @ls_barcode-Supplier
        INTO @DATA(ls_search_item).


      IF sy-tabix = 1.
        lv_first_product_type = ls_Product_Type.
        lv_first_option = ls_barcode-option_name.
        lv_first_print_multi = ls_barcode-print_multi.
      ENDIF.

      CASE ls_barcode-header_type.
        WHEN '01'.
          lv_header = 'TEM NGUYÊN VẬT LIỆU'.
        WHEN '02'.
          lv_header = 'TEM BTP'.
        WHEN '03'.
          lv_header = 'TEM BTP - IN OPP'.
        WHEN '04'.
          lv_header = 'TEM BTP - TRÁNG'.
        WHEN '05'.
          lv_header = 'TEM BTP - PPKD'.
        WHEN '06'.
          lv_header = 'TEM BTP - SỢI QUAI'.
        WHEN '07'.
          lv_header = 'TEM BTP - QUAI DỆT'.
        WHEN '08'.
          lv_header = 'TEM BTP - QUAI CẮT'.
        WHEN '09'.
          lv_header = 'TEM BTP - CẮT DẬP'.
        WHEN '10'.
          lv_header = 'TEM BTP - IN LƯỚI'.
        WHEN '11'.
          lv_header = 'TEM BTP - SỢI MANH'.
        WHEN '12'.
          lv_header = 'TEM BTP - MANH DỆT'.
        WHEN '13'.
          lv_header = 'TEM BTP - HẠT TÁI SINH VỎ BAO'.
        WHEN '14'.
          lv_header = 'TEM BTP - HẠT TÁI SINH VỎ BAO - TRỘN'.
        WHEN '15'.
          lv_header = 'TEM BTP - HẠT TÁI SINH PP'.
        WHEN '16'.
          lv_header = 'TEM BTP - HẠT TÁI SINH JUMBO'.
        WHEN '17'.
          lv_header = 'TEM TP - TÚI'.
        WHEN '18'.
          lv_header = 'TEM THÀNH PHẨM TÚI'.
        WHEN '19'.
          lv_header = 'TEM CÔNG CỤ DỤNG CỤ'.
      ENDCASE.

      IF ls_Product_Type = 'ZNVL'.
        ls_name = 'TÊN NVL'.
        IF ls_search_item IS NOT INITIAL AND ls_barcode-batch IS NOT INITIAL.
          lv_solot = | { ls_search_item } - { ls_barcode-batch } | .
        ELSEIF ls_search_item IS NOT INITIAL.
          lv_solot =  ls_search_item .
        ELSE .
          lv_solot = ls_barcode-batch .
        ENDIF.
        ls_qr = |{ lv_matnr }{ lv_solot }|.
      ELSEIF ls_Product_Type = 'ZBTP'.
        ls_name = 'TÊN BTP'.
        lv_solot = ls_barcode-batch .
*        ls_qr = |{ lv_matnr }{ lv_solot }{ lv_sale_order }{ lv_sale_order_item }|.
        ls_qr = |{ lv_matnr }{ lv_solot }{ ls_barcode-Sale_Order }{ ls_barcode-Sale_Order_item }|.
      ELSEIF ls_Product_Type = 'ZTP'.
        ls_name = 'TÊN TP'.
        lv_solot =  ls_barcode-batch  .
*        ls_qr = |{ lv_matnr }{ lv_solot }{ lv_sale_order }{ lv_sale_order_item }|.
        ls_qr = |{ lv_matnr }{ lv_solot }{ ls_barcode-Sale_Order }{ ls_barcode-Sale_Order_item }|.
      ELSEIF ls_Product_Type = 'ZCC'.
        ls_name = ls_barcode-Material_description.
        lv_solot = ls_barcode-batch  .
        ls_qr = |{ lv_matnr }{ ls_barcode-batch }|.
      ENDIF.

      IF ls_barcode-option_name = 1.
        lv_date = ls_barcode-Delivery_date.
      ELSEIF ls_barcode-option_name = 2.
        lv_date = ls_barcode-End_date.
      ELSEIF ls_barcode-option_name = 3.
        lv_date = ls_barcode-Posting_Date.
      ENDIF.

      IF lv_date IS NOT INITIAL.
        lv_date_text = |{ lv_date+6(2) }/{ lv_date+4(2) }/{ lv_date+0(4) }|.
      ENDIF.

      IF ls_barcode-batch = ls_barcode-ValuationType.
        CLEAR ls_barcode-batch.
      ENDIF.

      IF ls_barcode-Sale_Order IS NOT INITIAL AND ls_barcode-Sale_Order_item IS NOT INITIAL.
        ls_qr = | <S1>{ lv_matnr }<S1><S2>{ ls_barcode-batch }<S2><S3>{ ls_barcode-Sale_Order }{ ls_barcode-Sale_Order_item }<S3><S4>{ ls_barcode-ValuationType }<S4>|.
*        ls_qr = | <S1>{ lv_matnr }<S1><S2>{ ls_barcode-batch }<S2><S3>{ lv_sale_order }{ lv_sale_order_item }<S3><S4>{ ls_barcode-ValuationType }<S4>|.
      ELSE.
        ls_qr = | <S1>{ lv_matnr }<S1><S2>{ ls_barcode-batch }<S2><S3><S3><S4>{ ls_barcode-ValuationType }<S4>|.
      ENDIF.

      " Pad cho đủ 100 ký tự
      DATA(lv_max_len) = 100.
      DATA(lv_len) = strlen( ls_qr ).
      DATA(lv_spaces) = lv_max_len - lv_len.

      IF lv_spaces > 0.
        ls_qr = |{ ls_qr }{ repeat( val = ` ` occ = lv_spaces ) }|.
      ENDIF.

      REPLACE ALL OCCURRENCES OF '<' IN ls_qr WITH '&lt;'.
      REPLACE ALL OCCURRENCES OF '>' IN ls_qr WITH '&gt;'.


      IF ls_Product_Type = 'ZCC'  AND ( ls_barcode-option_name = 1
                                          OR ls_barcode-option_name = 3
                                          OR ls_barcode-option_name = 4 ).

        " Template CCDC
        xml = |<main>| &&
              |<Table1>| &&
              |<Row1>| &&
              |<header>{ lv_header }</header>| &&
              |</Row1>| &&
              |<Row2>| &&
              |<QR>| &&
              |<QRCode>{ ls_qr }</QRCode>| &&
              |</QR>| &&
              |<Table3>| &&
              |<Row1>| &&
              |<namecode>{ lv_matnr }</namecode>| &&
              |</Row1>| &&
              |<Row2>| &&
              |<name>{ ls_name }</name>| &&
              |</Row2>| &&
              |<Row3>| &&
              |<dvt>{ ls_barcode-Unit }</dvt>| &&
              |</Row3>| &&
              |</Table3>| &&
              |</Row2>| &&
              |</Table1>| &&
              |</main>|.

      ELSE.

        " Template Standard
        qrxml = |<QR>| &&
                |<QRCode>{ ls_qr }</QRCode>| &&
                |</QR>|.

        rowsxml = |<Row1>| &&
                  |<Date>{ lv_date_text }</Date>| &&
                  |</Row1>| &&
                  |<Row2>| &&
                  |<soluong></soluong>| &&
                  |<dvt>{ ls_barcode-Unit }</dvt>| &&
                  |</Row2>| &&
                  |<Row4>| &&
                  |<note></note>| &&
                  |</Row4>|.

        bannerxml = |<Row1>| &&
                    |<header>{ lv_header }</header>| &&
                    |</Row1>| &&
                    |<Row2>| &&
                    |<solot>{ lv_solot }</solot>| &&
                    |</Row2>| &&
                    |<Row3>| &&
                    |<namecode>{ lv_matnr }</namecode>| &&
                    |<name>{ ls_name }</name>| &&
                    |<name_1>{ ls_barcode-Material_description }</name_1>| &&
                    |</Row3>| &&
                    |<Row4>| &&
                    |{ qrxml }| &&
                    |<Table2>| &&
                    |<Row1>| &&
                    |<ngaynhap>NGÀY NHẬP</ngaynhap>| &&
                    |</Row1>| &&
                    |</Table2>| &&
                    |<Table3>| &&
                    |{ rowsxml }| &&
                    |</Table3>| &&
                    |</Row4>| &&
                    |<Row5>| &&
                    |<thukho>THỦ KHO</thukho>| &&
                    |</Row5>| &&
                    |<Row6>| &&
                    |<namethukho>{ ls_barcode-keeper }</namethukho>| &&
                    |<qc>{ ls_barcode-qc }</qc>| &&
                    |</Row6>| &&
                    |<Row7>| &&
                    |<solotBIG>{ ls_barcode-Material_description }</solotBIG>| &&
                    |</Row7>|
                    .

        xml = |<main>| &&
              |<Table1>| &&
              |{ bannerxml }| &&
              |</Table1>| &&
              |</main>|.

      ENDIF.


      lv_xml_body = lv_xml_body && xml.

      " Clear các biến tạm
      CLEAR: xml, qrxml, rowsxml, bannerxml.

    ENDLOOP.


    DATA(lv_final_xml) = lv_xml_header && lv_xml_body && lv_xml_footer.


    IF lv_first_product_type = 'ZCC'
       AND ( lv_first_option = 1
          OR lv_first_option = 3
          OR lv_first_option = 4 ).

      " Template CCDC
      CASE lv_first_print_multi.
        WHEN '1'.
          lv_template_id = 'zbarcode_ccdc'.
        WHEN '2'.
          lv_template_id = 'zbarcode_ccdc_x2'.
        WHEN '3'.
          lv_template_id = 'zbarcode_ccdc_x4'.
        WHEN '4'.
          lv_template_id = 'zbarcode_ccdc_x6'.
        WHEN '5'.
          lv_template_id = 'zbarcode_ccdc_x12'.
        WHEN OTHERS.
          lv_template_id = 'zbarcode_ccdc'.
      ENDCASE.

      lv_is_ccdc_template = abap_true.
      lv_filename = |Barcode_CCDC_{ lv_matnr }|.

    ELSE.

*Template Standard - kiểm tra header_type để chọn template phù hợp
      DATA: lv_first_header_type TYPE string.
      READ TABLE lt_barcode INDEX 1 INTO DATA(ls_first_barcode).
      IF sy-subrc = 0.
        lv_first_header_type = ls_first_barcode-header_type.
      ENDIF.
      IF lv_first_header_type = '03'
        OR lv_first_header_type = '04'
        OR lv_first_header_type = '05'
        OR lv_first_header_type = '12'.
        CASE lv_first_print_multi.
          WHEN '1'.
            lv_template_id = 'zbarcode2'.
          WHEN '2'.
            lv_template_id = 'zbarcode2x2'.
          WHEN '3'.
            lv_template_id = 'zbarcode2x4'.
          WHEN '4'.
            lv_template_id = 'zbarcode2x6'.
          WHEN '5'.
            lv_template_id = 'zbarcode2x6'.
          WHEN OTHERS.
            lv_template_id = 'zbarcode2'.
        ENDCASE.
        else.
        " Template Standard
        CASE lv_first_print_multi.
          WHEN '1'.
            lv_template_id = 'zbarcode'.
          WHEN '2'.
            lv_template_id = 'zbarcodex2'.
          WHEN '3'.
            lv_template_id = 'zbarcodex4'.
          WHEN '4'.
            lv_template_id = 'zbarcodex6'.
          WHEN '5'.
            lv_template_id = 'zbarcodex6'.
          WHEN OTHERS.
            lv_template_id = 'zbarcode'.
        ENDCASE.
        ENDIF.

        lv_is_ccdc_template = abap_false.


        READ TABLE lt_barcode INDEX 1 INTO ls_barcode.
        IF sy-subrc = 0.
          lv_filename = |Barcode_{ ls_barcode-Document }_{ ls_barcode-Document_Item }_{ lv_matnr }_{ ls_barcode-batch }|.
        ELSE.
          lv_filename = |Barcode_MultiRecords|.
        ENDIF.

      ENDIF.


      DATA: ls_request TYPE zcl_gen_adobe=>ts_request.

      ls_request-id = lv_template_id.
      CLEAR ls_request-data.
      APPEND lv_final_xml TO ls_request-data.

      DATA(o_gen_adobe) = NEW zcl_gen_adobe( ).
      DATA(lv_pdf) = o_gen_adobe->call_data(
        EXPORTING i_request = ls_request
        IMPORTING o_pdf_string = str_pdf
      ).

      o_pdf = lv_pdf.


      result = VALUE #( FOR key IN keys (
                          %cid   = key-%cid
                          %param   = VALUE #( filecontent   = str_pdf
                                              filename      = lv_filename
                                              fileextension = 'pdf'
                                              mimetype      = 'application/pdf'
                                             )
                          ) ).

      DATA: ls_mapped LIKE LINE OF mapped-zc_barcode.
      INSERT CORRESPONDING #( ls_mapped ) INTO TABLE mapped-zc_barcode.

    ENDMETHOD.
ENDCLASS.

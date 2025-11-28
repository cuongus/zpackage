CLASS zcl_pdf_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      keys_pnk     TYPE TABLE FOR ACTION IMPORT zc_goods_receipt_form~btnprintpdf,
      result_pnk   TYPE TABLE FOR ACTION RESULT zc_goods_receipt_form~btnprintpdf,
      mapped_pnk   TYPE RESPONSE FOR MAPPED EARLY zc_goods_receipt_form,
      failed_pnk   TYPE RESPONSE FOR FAILED EARLY zc_goods_receipt_form,
      reported_pnk TYPE RESPONSE FOR REPORTED EARLY zc_goods_receipt_form.

    CLASS-METHODS:
      btnprintpdf_pnk IMPORTING keys     TYPE keys_pnk
                      EXPORTING o_pdf    TYPE xstring
                      CHANGING  result   TYPE result_pnk
                                mapped   TYPE mapped_pnk
                                failed   TYPE failed_pnk
                                reported TYPE reported_pnk.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_document_key,
             materialdocument TYPE mblnr,
             fiscalyear       TYPE mjahr,
             shipper          TYPE string,
             cashier          TYPE string,
             department       TYPE string,
             director         TYPE string,
           END OF ty_document_key.

    TYPES: tt_doc_keys TYPE STANDARD TABLE OF ty_document_key WITH EMPTY KEY.

    CLASS-METHODS:
      build_xml_for_one_document
        IMPORTING
          i_materialdocument TYPE mblnr
          i_fiscalyear       TYPE mjahr
          i_shipper          TYPE string
          i_cashier          TYPE string
          i_department       TYPE string
          i_director         TYPE string
        RETURNING
          VALUE(rv_xml)      TYPE string.

ENDCLASS.



CLASS ZCL_PDF_REPORT IMPLEMENTATION.


  METHOD btnprintpdf_pnk.
    DATA: lt_doc_keys   TYPE tt_doc_keys,
          ls_doc_key    TYPE ty_document_key,
          lt_split_md   TYPE TABLE OF string,
          lt_split_fy   TYPE TABLE OF string,
          lv_matdoc_str TYPE string,
          lv_fy_str     TYPE string,
          lv_index      TYPE i.


    READ TABLE keys INDEX 1 INTO DATA(k).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " Parse MaterialDocument (comma-separated)
    IF k-%param-materialdocument IS NOT INITIAL AND k-%param-materialdocument NE 'null'.
      SPLIT k-%param-materialdocument AT ',' INTO TABLE lt_split_md.
    ELSE.
      RETURN.
    ENDIF.

    " Parse FiscalYear (comma-separated)
    IF k-%param-fiscalyear IS NOT INITIAL AND k-%param-fiscalyear NE 'null'.
      SPLIT k-%param-fiscalyear AT ',' INTO TABLE lt_split_fy.
    ELSE.
      DATA(lv_default_fy) = sy-datum+0(4).
      DO lines( lt_split_md ) TIMES.
        APPEND lv_default_fy TO lt_split_fy.
      ENDDO.
    ENDIF.

    " Validate counts match or use first FY for all
    IF lines( lt_split_md ) <> lines( lt_split_fy ).
      IF lines( lt_split_fy ) = 1.
        READ TABLE lt_split_fy INDEX 1 INTO lv_fy_str.
        CLEAR lt_split_fy.
        DO lines( lt_split_md ) TIMES.
          APPEND lv_fy_str TO lt_split_fy.
        ENDDO.
      ELSE.
        RETURN.
      ENDIF.
    ENDIF.

    " Get scalar parameters
    DATA(lv_shipper)    = COND string( WHEN k-%param-shipper IS NOT INITIAL AND k-%param-shipper NE 'null'
                                       THEN k-%param-shipper ELSE '' ).
    DATA(lv_cashier)    = COND string( WHEN k-%param-cashier IS NOT INITIAL AND k-%param-cashier NE 'null'
                                       THEN k-%param-cashier ELSE '' ).
    DATA(lv_department) = COND string( WHEN k-%param-department IS NOT INITIAL AND k-%param-department NE 'null'
                                       THEN k-%param-department ELSE '' ).
    DATA(lv_director)   = COND string( WHEN k-%param-director IS NOT INITIAL AND k-%param-director NE 'null'
                                       THEN k-%param-director ELSE '' ).

    " Build document keys list
    lv_index = 0.
    LOOP AT lt_split_md INTO lv_matdoc_str.
      lv_index = lv_index + 1.

      CONDENSE lv_matdoc_str NO-GAPS.
      IF lv_matdoc_str IS INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE lt_split_fy INDEX lv_index INTO lv_fy_str.
      CONDENSE lv_fy_str NO-GAPS.

      CLEAR ls_doc_key.
      ls_doc_key-materialdocument = |{ lv_matdoc_str ALPHA = IN }|.
      ls_doc_key-fiscalyear       = lv_fy_str.
      ls_doc_key-shipper          = lv_shipper.
      ls_doc_key-cashier          = lv_cashier.
      ls_doc_key-department       = lv_department.
      ls_doc_key-director         = lv_director.

      APPEND ls_doc_key TO lt_doc_keys.
    ENDLOOP.

    " Remove duplicates
    SORT lt_doc_keys BY materialdocument fiscalyear.
    DELETE ADJACENT DUPLICATES FROM lt_doc_keys COMPARING materialdocument fiscalyear.

    IF lt_doc_keys IS INITIAL.
      RETURN.
    ENDIF.


    DATA: ls_request TYPE zcl_gen_adobe=>ts_request.
    ls_request-id = 'zphieunhapkho'.

    LOOP AT lt_doc_keys INTO ls_doc_key.
      DATA(lv_xml_one) = build_xml_for_one_document(
        i_materialdocument = ls_doc_key-materialdocument
        i_fiscalyear       = ls_doc_key-fiscalyear
        i_shipper          = ls_doc_key-shipper
        i_cashier          = ls_doc_key-cashier
        i_department       = ls_doc_key-department
        i_director         = ls_doc_key-director
      ).

      IF lv_xml_one IS NOT INITIAL.
        APPEND lv_xml_one TO ls_request-data.
      ENDIF.
    ENDLOOP.

    IF ls_request-data IS INITIAL.
      RETURN.
    ENDIF.
    DATA: str_pdf TYPE string.

    DATA(o_gen_adobe) = NEW zcl_gen_adobe( ).
    DATA(lv_pdf) = o_gen_adobe->call_data( EXPORTING i_request    = ls_request
                                           IMPORTING o_pdf_string = str_pdf ).

    o_pdf = lv_pdf.


    DATA(lv_filename) = COND string(
      WHEN lines( lt_doc_keys ) = 1
      THEN |PhieuNhapKho_{ lt_doc_keys[ 1 ]-materialdocument ALPHA = OUT }_{ lt_doc_keys[ 1 ]-fiscalyear }|
      ELSE |PhieuNhapKho_{ sy-datum }{ sy-uzeit }|
    ).

    result = VALUE #( FOR key IN keys (
                      %cid   = key-%cid
                      %param = VALUE #(
                                        filecontent   = str_pdf
                                        filename      = lv_filename
                                        fileextension = 'pdf'
                                        mimetype      = 'application/pdf'
                                        )
                      ) ).

    DATA: ls_mapped LIKE LINE OF mapped-zc_goods_receipt_form.
    INSERT CORRESPONDING #( ls_mapped ) INTO TABLE mapped-zc_goods_receipt_form.

  ENDMETHOD.


  METHOD build_xml_for_one_document.

    DATA: ir_materialdocument TYPE zcl_goods_receipt_form_query=>tt_ranges,
          ir_fiscalyear       TYPE zcl_goods_receipt_form_query=>tt_ranges.

    APPEND VALUE #( sign = 'I' option = 'EQ' low = i_materialdocument ) TO ir_materialdocument.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = i_fiscalyear )       TO ir_fiscalyear.


    SELECT FROM i_materialdocumentitem_2 AS a
       INNER JOIN i_goodsmovementtype AS b
          ON a~goodsmovementtype = b~goodsmovementtype
        LEFT OUTER JOIN i_goodsmovementtypet AS m
          ON b~goodsmovementtype = m~goodsmovementtype
         AND m~language = @sy-langu
       LEFT OUTER JOIN i_materialdocumentheader_2 AS c
          ON a~materialdocument = c~materialdocument
         AND a~materialdocumentyear = c~materialdocumentyear
       LEFT OUTER JOIN i_productdescription AS d
          ON a~material = d~product
         AND d~language = @sy-langu
       LEFT OUTER JOIN i_unitofmeasuretext AS e
          ON a~entryunit = e~unitofmeasure
         AND e~language = @sy-langu
       LEFT OUTER JOIN i_supplier AS f
          ON a~supplier = f~supplier
       LEFT OUTER JOIN i_plant AS g
          ON a~plant = g~plant
       LEFT OUTER JOIN i_purchaseorderitemapi01 AS h
          ON a~purchaseorder = h~purchaseorder
          AND a~purchaseorderitem = h~purchaseorderitem
       LEFT OUTER JOIN i_reservationdocumentitem AS i
           ON a~reservation = i~reservation
             AND a~reservationitem = i~reservationitem
       LEFT OUTER JOIN i_salesdocumentitem AS j
           ON a~specialstockidfgsalesorder = j~salesdocument
             AND a~specialstockidfgsalesorderitem = j~salesdocumentitem
       LEFT OUTER JOIN i_manufacturingorderitem AS k
           ON a~orderid = k~manufacturingorder
             AND a~orderitem = k~manufacturingorderitem
       LEFT OUTER JOIN i_deliverydocumentitem AS l
           ON a~deliverydocument = l~deliverydocument
             AND a~deliverydocumentitem = l~deliverydocumentitem
       FIELDS a~materialdocument,
              a~materialdocumentyear,
              a~materialdocumentitem,
              a~material,
              a~batch,
              a~specialstockidfgsalesorder,
              a~specialstockidfgsalesorderitem,
              a~quantityinentryunit,
              a~quantityinbaseunit,
              b~goodsmovementtype,
              m~goodsmovementtypename,
              h~orderquantity,
              i~resvnitmrequiredqtyinentryunit,
              j~orderquantity AS so_quantity,
              k~mfgorderitemplannedtotalqty,
              l~actualdeliveryquantity,
              l~originaldeliveryquantity,
              a~totalgoodsmvtamtincccrcy,
              a~companycodecurrency,
              a~plant,
              a~companycode,
              a~purchaseorder,
              a~purchaseorderitem,
              a~reservation,
              a~reservationitem,
              a~deliverydocument,
              a~deliverydocumentitem,
              a~orderid,
              a~orderitem,
              c~documentdate,
              c~postingdate,
              c~materialdocumentheadertext,
              d~productdescription AS materialname,
              e~unitofmeasurelongname,
              e~unitofmeasure,
              f~suppliername AS suppliername,
              g~plantname
        WHERE a~materialdocument IN @ir_materialdocument
*         AND a~isautomaticallycreated <> 'X'
         AND a~materialdocumentyear IN @ir_fiscalyear
*         AND b~debitcreditcode = 'S'
         AND a~debitcreditcode = 'S'
         AND a~reversedmaterialdocument = ''
         AND NOT EXISTS (
           SELECT reversedmaterialdocument
           FROM i_materialdocumentitem_2 AS x
           WHERE a~materialdocument = x~reversedmaterialdocument
             AND a~materialdocumentyear = x~reversedmaterialdocumentyear
             AND a~materialdocumentitem = x~reversedmaterialdocumentitem
         )
     INTO TABLE @DATA(lt_data).

    IF lt_data IS INITIAL.
      RETURN.
    ENDIF.


    TYPES: BEGIN OF lty_po,
             purchaseorder    TYPE ebeln,
             reservation      TYPE rsnum,
             deliverydocument TYPE vbeln_vl,
             orderid          TYPE aufnr,
           END OF lty_po.

    DATA: lv_po_multi   TYPE string,
          lv_rev_multi  TYPE string,
          lv_po_curreny TYPE waers,
          lv_refer_po   TYPE char1,
          lt_po         TYPE TABLE OF lty_po,
          lt_rev        TYPE TABLE OF lty_po,
          lt_order      TYPE TABLE OF lty_po,
          lt_do         TYPE TABLE OF lty_po,
          ls_po         TYPE lty_po.

    LOOP AT lt_data INTO DATA(ls_data).
      ls_po-purchaseorder = ls_data-purchaseorder.
      ls_po-reservation = ls_data-reservation.
      ls_po-deliverydocument = ls_data-deliverydocument.
      ls_po-orderid = ls_data-orderid.
      APPEND ls_po TO lt_po.
    ENDLOOP.

    lt_rev[] = lt_po[].
    lt_do[] = lt_po[].
    lt_order[] = lt_po[].

    SORT lt_do BY deliverydocument.
    DELETE ADJACENT DUPLICATES FROM lt_do COMPARING deliverydocument.
    SORT lt_rev BY reservation.
    DELETE ADJACENT DUPLICATES FROM lt_rev COMPARING reservation.
    SORT lt_po BY purchaseorder ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_po COMPARING purchaseorder.
    SORT lt_order BY orderid ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_order COMPARING orderid.

    LOOP AT lt_do INTO ls_po.
      SHIFT ls_po-deliverydocument LEFT DELETING LEADING '0'.
      IF lv_rev_multi IS INITIAL.
        lv_rev_multi = ls_po-deliverydocument.
        CONDENSE lv_rev_multi.
      ELSE.
        lv_rev_multi = | { lv_rev_multi }/{ ls_po-deliverydocument } |.
        CONDENSE lv_rev_multi.
      ENDIF.
    ENDLOOP.

    IF lv_rev_multi IS INITIAL.
      LOOP AT lt_rev INTO ls_po.
        SHIFT ls_po-reservation LEFT DELETING LEADING '0'.
        IF lv_rev_multi IS INITIAL.
          lv_rev_multi = ls_po-reservation.
          CONDENSE lv_rev_multi.
        ELSE.
          lv_rev_multi = | { lv_rev_multi }/{ ls_po-reservation } |.
          CONDENSE lv_rev_multi.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lv_rev_multi IS INITIAL.
      LOOP AT lt_order INTO ls_po.
        SHIFT ls_po-orderid LEFT DELETING LEADING '0'.
        IF lv_rev_multi IS INITIAL.
          lv_rev_multi = ls_po-orderid.
          CONDENSE lv_rev_multi.
        ELSE.
          lv_rev_multi = | { lv_rev_multi }/{ ls_po-orderid } |.
          CONDENSE lv_rev_multi.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT lt_po INTO ls_po.
      IF lv_po_multi IS INITIAL.
        lv_po_multi = ls_po-purchaseorder.
        CONDENSE lv_po_multi.
      ELSE.
        lv_po_multi = | { lv_po_multi }/{ ls_po-purchaseorder } |.
        CONDENSE lv_po_multi.
      ENDIF.
    ENDLOOP.


    READ TABLE lt_data INDEX 1 INTO DATA(ls_first_row).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF ls_first_row-purchaseorder IS INITIAL.
      lv_refer_po = ''.
    ELSEIF ls_first_row-purchaseorder IS NOT INITIAL.
      lv_refer_po = 'X'.
    ENDIF.

    SELECT SINGLE storagelocation
      FROM i_materialdocumentheader_2
      WHERE materialdocument     = @ls_first_row-materialdocument
        AND materialdocumentyear = @ls_first_row-materialdocumentyear
      INTO @DATA(lv_storagelocation).

    SELECT SINGLE storagelocationname
      FROM i_storagelocation
      WHERE storagelocation = @lv_storagelocation
      AND plant = @ls_first_row-plant
      INTO @DATA(lv_storagelocationname)
      .

    DATA(lv_storage_text) = ||.
    IF ls_first_row-plant IS NOT INITIAL.
      lv_storage_text = | { ls_first_row-plant } |.
    ENDIF.

    IF lv_storage_text IS NOT INITIAL AND lv_storagelocation IS NOT INITIAL.
      lv_storage_text = | { lv_storage_text }/{ lv_storagelocation } - { lv_storagelocationname } |.
    ELSEIF lv_storagelocation IS NOT INITIAL.
      lv_storage_text = |{ lv_storagelocation } - { lv_storagelocationname }|.
    ENDIF.

    zcl_jp_common_core=>get_companycode_details(
      EXPORTING
        i_companycode = ls_first_row-companycode
      IMPORTING
        o_companycode = DATA(ls_companycode)
    ).

    DATA(lv_day)   = ls_first_row-postingdate+6(2).
    DATA(lv_month) = ls_first_row-postingdate+4(2).
    DATA(lv_year)  = ls_first_row-postingdate+0(4).
    DATA(lv_date_str) = |Ngày { lv_day } tháng { lv_month } năm { lv_year }|.

    DATA(lv_vendorname) = ls_first_row-suppliername.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_vendorname WITH space.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN lv_vendorname WITH space.
    CONDENSE lv_vendorname.

    DATA(lv_movement_type) = | { ls_first_row-goodsmovementtype } - { ls_first_row-goodsmovementtypename } |.


    DATA: lv_items_xml    TYPE string,
          lv_sum_unit     TYPE erfmg VALUE 0,
          lv_sum_po       TYPE menge_d VALUE 0,
          lv_total_amount TYPE p LENGTH 16 DECIMALS 2 VALUE 0.

    LOOP AT lt_data INTO DATA(ls_row).
      DATA: lv_qty_order TYPE string,
            lv_qty_entry TYPE string,
            lv_unitprice TYPE string,
            lv_amount    TYPE string,
            lv_uom       TYPE msehl.

      SELECT SINGLE unitofmeasure_e
        FROM i_unitofmeasure
        WHERE unitofmeasuresapcode = @ls_row-unitofmeasure
        INTO @lv_uom.

      DATA(lv_material_no) = |{ ls_row-material ALPHA = OUT }|.
      DATA(lv_batch_no) = |{ ls_row-batch ALPHA = OUT }|.
      DATA(lv_so_no) = |{ ls_row-specialstockidfgsalesorder ALPHA = OUT }|.
      DATA(lv_so_item) = |{ ls_row-specialstockidfgsalesorderitem ALPHA = OUT }|.

      DATA(lv_po_qty) = COND menge_d(
        WHEN ls_row-deliverydocument IS NOT INITIAL AND ls_row-deliverydocumentitem IS NOT INITIAL
        THEN ls_row-originaldeliveryquantity
        WHEN ls_row-purchaseorder IS NOT INITIAL AND ls_row-purchaseorderitem IS NOT INITIAL
        THEN ls_row-orderquantity
        WHEN ls_row-reservation IS NOT INITIAL AND ls_row-reservationitem IS NOT INITIAL
        THEN ls_row-resvnitmrequiredqtyinentryunit
        WHEN ls_row-specialstockidfgsalesorder IS NOT INITIAL AND ls_row-specialstockidfgsalesorderitem IS NOT INITIAL
        THEN ls_row-so_quantity
        WHEN ls_row-orderid IS NOT INITIAL AND ls_row-orderitem IS NOT INITIAL
        THEN ls_row-mfgorderitemplannedtotalqty
        ELSE 0
      ).

      DATA(lv_item_amount) = COND wrbtr(
        WHEN ls_row-companycodecurrency = 'VND'
        THEN ls_row-totalgoodsmvtamtincccrcy * 100
        ELSE ls_row-totalgoodsmvtamtincccrcy
      ).

      DATA(lv_unit_price) = COND wrbtr(
        WHEN ls_row-quantityinentryunit <> 0
        THEN COND #( WHEN ls_row-companycodecurrency = 'VND'
                     THEN round( val = ls_row-totalgoodsmvtamtincccrcy * 100 / ls_row-quantityinentryunit dec = 0 )
                     ELSE ls_row-totalgoodsmvtamtincccrcy / ls_row-quantityinentryunit )
        ELSE 0
      ).

      lv_sum_unit = lv_sum_unit + ls_row-quantityinentryunit.
      lv_sum_po = lv_sum_po + lv_po_qty.
      lv_total_amount = lv_total_amount + lv_item_amount.

      lv_qty_order = |{ lv_po_qty DECIMALS = 3 NUMBER = USER }|.
      lv_qty_entry = |{ ls_row-quantityinentryunit DECIMALS = 3 NUMBER = USER }|.
      lv_unitprice = |{ lv_unit_price DECIMALS = 0 NUMBER = USER }|.
      lv_amount = |{ lv_item_amount DECIMALS = 0 NUMBER = USER }|.


      IF lv_refer_po = ''.
        lv_unitprice = ''.
        lv_amount = ''.

      ELSE.
        SELECT SINGLE documentcurrency
          FROM i_purchaseorderapi01
          WHERE purchaseorder = @ls_row-purchaseorder
          INTO @lv_po_curreny.
        IF sy-subrc = 0 AND lv_po_curreny NE 'VND'.
          lv_unitprice = ''.
          lv_amount = ''.

        ENDIF.
      ENDIF.

      DATA(lv_salesorder_xml) = ``.
      IF lv_so_no IS NOT INITIAL OR lv_so_item IS NOT INITIAL.
        SHIFT lv_so_item LEFT DELETING LEADING '0'.
        lv_salesorder_xml = |<salesorder>{ lv_so_no }/{ lv_so_item }</salesorder>|.
      ENDIF.

      lv_items_xml = lv_items_xml &&
        |<Row1>| &&
        |<numberoforder>{ sy-tabix }</numberoforder>| &&
        |<materialnumber>{ lv_material_no }</materialnumber>| &&
        |<materialdescription>{ ls_row-materialname }</materialdescription>| &&
        |<batchnumber>{ lv_batch_no }</batchnumber>| &&
        lv_salesorder_xml &&
        |<unitofmeasurementtext>{ lv_uom }</unitofmeasurementtext>| &&
        |<purchaseorderquantity>{ lv_qty_order }</purchaseorderquantity>| &&
        |<quantityinunitofentry>{ lv_qty_entry }</quantityinunitofentry>| &&
        |<unitprice>{ lv_unitprice }</unitprice>| &&
        |<amountinlocalcurrency>{ lv_amount }</amountinlocalcurrency>| &&
        |</Row1>|.
    ENDLOOP.

    DATA(lv_sum_unit_o) = |{ lv_sum_unit DECIMALS = 3 NUMBER = USER }|.
    DATA(lv_sum_po_o) = |{ lv_sum_po DECIMALS = 3 NUMBER = USER }|.
    DATA(lv_total_amount_str) = |{ lv_total_amount DECIMALS = 0 NUMBER = USER }|.


    DATA: lv_amount_for_read TYPE zde_dmbtr.
    lv_amount_for_read = lv_total_amount.
    lv_total_amount = abs( lv_total_amount ).

    DATA(lo_amount_in_words) = NEW zcore_cl_amount_in_words( ).
    DATA(lv_amount_text) = lo_amount_in_words->read_amount(
      EXPORTING
        i_amount = lv_amount_for_read
        i_lang   = 'VI'
        i_waers  = 'VND'
    ).

    IF lv_total_amount = 0.
      lv_amount_text = ''.
    ENDIF.

    IF lv_refer_po = ''.
      lv_total_amount_str = ''.
      lv_amount_text = ''.
    ELSE.
      SELECT SINGLE documentcurrency
        FROM i_purchaseorderapi01
        WHERE purchaseorder = @ls_row-purchaseorder
        INTO @lv_po_curreny.
      IF sy-subrc = 0 AND lv_po_curreny NE 'VND'.
        lv_total_amount_str = ''.
        lv_amount_text = ''.
      ENDIF.
    ENDIF.



    REPLACE ALL OCCURRENCES OF '&' IN lv_vendorname WITH '&amp;'.
    REPLACE ALL OCCURRENCES OF '<' IN lv_vendorname WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '>' IN lv_vendorname WITH '&gt;'.
    REPLACE ALL OCCURRENCES OF '&' IN ls_companycode-companycodename WITH '&amp;'.
    REPLACE ALL OCCURRENCES OF '<' IN ls_companycode-companycodename WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '>' IN ls_companycode-companycodename WITH '&gt;'.
    REPLACE ALL OCCURRENCES OF '&' IN ls_companycode-companycodeaddr WITH '&amp;'.
    REPLACE ALL OCCURRENCES OF '<' IN ls_companycode-companycodeaddr WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '>' IN ls_companycode-companycodeaddr WITH '&gt;'.

    CONDENSE: lv_vendorname, lv_movement_type.

    REPLACE ALL OCCURRENCES OF '&' IN lv_vendorname WITH '&amp;'.
    REPLACE ALL OCCURRENCES OF '<' IN lv_vendorname WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '>' IN lv_vendorname WITH '&gt;'.

    rv_xml =
      |<?xml version="1.0" encoding="UTF-8"?>| &&
      |<form1>| &&
      |<Page1>| &&
      |<FooterNumber>123</FooterNumber>| &&
      |</Page1>| &&
      |<main>| &&
      |<HeaderSection>| &&
      |<CompanyName>{ ls_companycode-companycodename }</CompanyName>| &&
      |<CompanyAddress>{ ls_companycode-companycodeaddr }</CompanyAddress>| &&
      |<Title>PHIẾU NHẬP KHO</Title>| &&
      |<MaterialDocumentDate>{ lv_date_str }</MaterialDocumentDate>| &&
      |<MaterialDocument>{ ls_first_row-materialdocument }</MaterialDocument>| &&
      |<Reservation>{ lv_rev_multi }</Reservation>| &&
      |<PurchaseOrder>{ lv_po_multi }</PurchaseOrder>| &&
      |<Content1>{ i_shipper }</Content1>| &&
      |<Content2>{ lv_vendorname }</Content2>| &&
      |<Content3>{ lv_movement_type }</Content3>| &&
      |<Content4>{ lv_storage_text }</Content4>| &&
      |</HeaderSection>| &&
      |<MiddleSection>| &&
      |<Table1>| &&
      lv_items_xml &&
      |<FooterRow>| &&
      |<sumyc>{ lv_sum_po_o }</sumyc>| &&
      |<sumtn>{ lv_sum_unit_o }</sumtn>| &&
      |<totalamount>{ lv_total_amount_str }</totalamount>| &&
      |</FooterRow>| &&
      |</Table1>| &&
      |<amountinword>{ lv_amount_text }</amountinword>| &&
      |</MiddleSection>| &&
      |<FooterSection>| &&
      |<PostingDate></PostingDate>| &&
      |<Table2>| &&
      |<Row1>| &&
      |<ChanKy1>Người giao hàng</ChanKy1>| &&
      |</Row1>| &&
      |<Row3>| &&
      |<ChanKy1>{ i_shipper }</ChanKy1>| &&
      |<ChanKy2>{ i_cashier }</ChanKy2>| &&
      |<ChanKy3>{ i_department }</ChanKy3>| &&
      |<ChanKy4>{ i_director }</ChanKy4>| &&
      |</Row3>| &&
      |</Table2>| &&
      |</FooterSection>| &&
      |</main>| &&
      |</form1>|.

  ENDMETHOD.
ENDCLASS.

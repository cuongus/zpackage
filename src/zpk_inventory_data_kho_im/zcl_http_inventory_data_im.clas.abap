CLASS zcl_http_inventory_data_im DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_range_option,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE string,
        high   TYPE string,
      END OF ty_range_option,

      tt_ranges TYPE TABLE OF ty_range_option,

      BEGIN OF ty_request,
        convert_sap_no       TYPE string,
        pid                  TYPE string,
        pid_item             TYPE string,
        fiscal_year          TYPE string,
        document_date        TYPE string,
        plan_count_date      TYPE string,
*        count_date           TYPE string,
        material             TYPE string,
        material_description TYPE string,
        plant                TYPE string,
        storage_location     TYPE string,
        batch                TYPE string,
        sales_order          TYPE string,
        sales_order_item     TYPE string,
        Supplier             TYPE string,
        pda_quantity         TYPE string,
        counted_qty_uom      TYPE string,
        zero_count           TYPE string,
        api_status           TYPE string,
        api_message          TYPE string,
        pda_date             TYPE string,
        pda_time             TYPE string,
        counter              TYPE string,
        api_date             TYPE string,
        api_time             TYPE string,
      END OF ty_request,

      BEGIN OF ty_message,
        messtype   TYPE zde_char1,
        messagetxt TYPE string,
      END OF ty_message.

    TYPES: BEGIN OF ty_data,
             convert_sap_no       TYPE string,
             pid                  TYPE i_physinvtrydocitem-physicalinventorydocument,
             pid_item             TYPE c LENGTH 6, " i_physinvtrydocitem-physicalinventorydocumentitem,
             fiscal_year          TYPE i_physinvtrydocitem-fiscalyear,
             document_date        TYPE i_physinvtrydocheader-DocumentDate,
             plan_count_date      TYPE string,
*             count_date           TYPE i_physinvtrydocitem-physicalinventorylastcountdate,
             material             TYPE c LENGTH 18, " i_physinvtrydocitem-material,
             material_description TYPE i_producttext-productname,
             plant                TYPE i_physinvtrydocitem-plant,
             storage_location     TYPE i_physinvtrydocitem-storagelocation,
             batch                TYPE i_physinvtrydocitem-batch,
             sales_order          TYPE i_physinvtrydocitem-SalesOrder,       " New
             sales_order_item     TYPE string,     " New
             Supplier             TYPE i_physinvtrydocitem-Supplier,
             pda_quantity         TYPE string,
             counted_qty_uom      TYPE string,
             zero_count           TYPE string,
             api_status           TYPE string,
             api_message          TYPE string,
             pda_date             TYPE string,
             pda_time             TYPE string,
             counter              TYPE string,
             api_date             TYPE string,
             api_time             TYPE string,
             app_mess             TYPE string,
           END OF ty_data.

    CONSTANTS: c_header_content TYPE string VALUE 'content-type',
               c_content_type   TYPE string VALUE 'application/json, charset=utf-8'.

    DATA: g_json_string        TYPE string.
    DATA: gv_top      TYPE string,
          gv_pid      TYPE string,
          gv_pid_item TYPE string,
          gv_matnr    TYPE string,
          gv_from     TYPE string,
          gv_filter   TYPE string.

    METHODS: save_data_inventory IMPORTING iv_request TYPE string
                                 EXPORTING e_context  TYPE string.

    METHODS: get_data_inventory IMPORTING iv_filter TYPE string
                                          iv_top    TYPE string
                                EXPORTING e_context TYPE string.

    METHODS: get_data_inventory_1 IMPORTING iv_filter   TYPE string
                                            iv_pid      TYPE string
                                            iv_pid_item TYPE string
                                            iv_matnr    TYPE string
                                            iv_top      TYPE string
                                            iv_from     TYPE string
                                  EXPORTING e_context   TYPE string.

    TYPES:
           tt_pb TYPE STANDARD TABLE OF ztb_inven_im1.

    CLASS-METHODS: post_invoice_api
      IMPORTING
        i_hdr           TYPE ztb_inven_im1
        i_t_pb          TYPE tt_pb
      EXPORTING
        e_code          TYPE zde_return_cdoe
        e_suppliervoice TYPE zr_tbxuat_hd-supplier
        e_response      TYPE zst_odata_return.

ENDCLASS.



CLASS ZCL_HTTP_INVENTORY_DATA_IM IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA: lt_parts TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    DATA(lv_req_body) = request->get_text( ).

    DATA(lv_method) = request->get_header_field( '~request_method' ).

    DATA(lv_uri) = request->get_header_field( '~request_uri' ).

    SPLIT lv_uri AT '?' INTO DATA(lv_path) DATA(lv_query_string).

    SPLIT lv_query_string AT '&' INTO TABLE lt_parts.

    LOOP AT lt_parts INTO DATA(lv_pair).
      SPLIT lv_pair AT '=' INTO DATA(lv_key) DATA(lv_val).

      CASE lv_key.
        WHEN 'name'.
          DATA(lv_name) = lv_val.
        WHEN 'filter'.
          gv_filter = lv_val.
        WHEN 'top'.
          gv_top = lv_val.
        WHEN 'pid'.
          gv_pid = lv_val.
        WHEN 'pid_item'.
          gv_pid_item = lv_val.
        WHEN 'matnr'.
          gv_matnr = lv_val.
        WHEN 'from'.
          gv_from = lv_val.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

    CASE lv_method.

      WHEN 'post' OR 'POST'.
        me->save_data_inventory(
          EXPORTING
            iv_request = lv_req_body
          IMPORTING
            e_context  = g_json_string
        ).
      WHEN 'get' OR 'GET'.

        IF gv_pid IS NOT INITIAL OR gv_pid_item IS NOT INITIAL OR gv_matnr IS NOT INITIAL OR gv_top IS NOT INITIAL OR gv_from IS NOT INITIAL .

          me->get_data_inventory_1(
           EXPORTING
             iv_filter = gv_filter
             iv_pid    = gv_pid
             iv_pid_item = gv_pid_item
             iv_matnr = gv_matnr
             iv_top    = gv_top
             iv_from = gv_from
           IMPORTING
             e_context = g_json_string
         ).

        ELSEIF gv_pid IS INITIAL AND gv_pid_item IS INITIAL AND gv_matnr IS INITIAL AND  gv_top IS INITIAL AND gv_from IS INITIAL.
          DATA: lt_message TYPE TABLE OF ty_message,
                ls_message TYPE ty_message.

          ls_message-messtype  = 'E'.
          ls_message-messagetxt = 'Vui lòng nhập Params'.
          APPEND ls_message TO lt_message.

          /ui2/cl_json=>serialize(
            EXPORTING
              data     = lt_message
              compress = abap_true
            RECEIVING
              r_json   = g_json_string
          ).

        ELSE.
          me->get_data_inventory(
          EXPORTING
            iv_filter = gv_filter
            iv_top    = gv_top
          IMPORTING
            e_context = g_json_string
        ).
        ENDIF.


    ENDCASE.

*** Response
    response->set_status( '200' ).

*** Setup -> Response content-type json
    response->set_header_field( i_name  = c_header_content
                                i_value = c_content_type ).

    response->set_text( g_json_string ).

  ENDMETHOD.


  METHOD save_data_inventory.

    DATA:
      lv_fail            TYPE zde_char1,
      lv_counted         TYPE zde_char1,
      lv_pi_status       TYPE ztb_inven_im1-pi_status,
      lv_material_filter TYPE c LENGTH 18.

    DATA:
      lt_request TYPE TABLE OF ty_request,
      ls_request TYPE ty_request,

      lt_data    TYPE TABLE OF ty_data,
      ls_data    TYPE ty_data,

      ls_message TYPE ty_message,
      lt_message TYPE TABLE OF ty_message.

*    XCO_CP_JSON=>DATA->FROM_STRING( IV_REQUEST )->APPLY( value #(
*            ( XCO_CP_JSON=>TRANSFORMATION->PASCAL_CASE_TO_UNDERSCORE )
*    ) )->WRITE_TO( ref #( LT_REQUEST ) ).

    /ui2/cl_json=>deserialize(
      EXPORTING
        json        = iv_request
*       jsonx       =
        pretty_name = /ui2/cl_json=>pretty_mode-user
*       assoc_arrays     =
*       assoc_arrays_opt =
*       name_mappings    =
*       conversion_exits =
*       hex_as_base64    =
      CHANGING
        data        = lt_request
    ).

    LOOP AT lt_request INTO ls_request.
      MOVE-CORRESPONDING ls_request TO ls_data.

      DATA lv_convert_sap_no_temp TYPE c LENGTH 6.

      DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
      DATA(lv_time) = cl_abap_context_info=>get_system_time( ).

      DATA(lv_pattern) = |{ lv_date }%|.

      SELECT convert_sap_no
          FROM ztb_inven_im1
          WHERE convert_sap_no LIKE @lv_pattern
          INTO TABLE @DATA(lt_convert_sap_no).
      SORT lt_convert_sap_no BY convert_sap_no DESCENDING.

      READ TABLE lt_convert_sap_no INTO DATA(ls_convert_sap_no) INDEX 1.
      IF sy-subrc NE 0.
        ls_data-convert_sap_no = |{ lv_date }000000|.
      ELSE.
        ls_data-convert_sap_no = ls_convert_sap_no-convert_sap_no.
      ENDIF.

      ls_data-convert_sap_no = ls_data-convert_sap_no + 1.

      IF ls_data-pid IS INITIAL AND ls_data-pid_item IS INITIAL.
        ls_data-api_status = |A|.
        ls_data-api_message = |Adding: Tạo mới chứng từ để kiểm kê|.
      ELSE.

        ls_data-pid = |{ ls_data-pid ALPHA = IN }|.
        ls_data-pid_item = |{ ls_data-pid_item ALPHA = IN }|.

        lv_material_filter = ls_data-material.
        lv_material_filter = |{ lv_material_filter ALPHA = IN }|.
        CONDENSE ls_data-material.

        ls_data-sales_order = |{ ls_data-sales_order ALPHA = IN }|.

        SELECT SINGLE physicalinventorydocument
            FROM  i_physinvtrydocitem
            WHERE physicalinventorydocument = @ls_data-pid
            INTO @DATA(lv_pid).
        IF sy-subrc NE 0.
          ls_data-api_status = |E|.
          ls_data-api_message = |Error: Physical Inventory { ls_data-pid } not exist|.
        ELSE.

          SELECT SINGLE physicalinventorydocumentitem
              FROM  i_physinvtrydocitem
              WHERE physicalinventorydocument = @ls_data-pid
              AND physicalinventorydocumentitem = @ls_data-pid_item
              INTO @DATA(lv_pid_item).
          IF sy-subrc NE 0.
            ls_data-api_status = |E|.
            ls_data-api_message = |Error: Line Item { ls_data-pid_item } Physical Inventory { ls_data-pid } not exist|.
          ELSE.

            SELECT SINGLE fiscalyear
                FROM  i_physinvtrydocitem
                WHERE physicalinventorydocument = @ls_data-pid
                AND physicalinventorydocumentitem = @ls_data-pid_item
                INTO @DATA(lv_fiscalyear).
            IF lv_fiscalyear NE ls_data-fiscal_year.

              ls_data-api_status = |E|.
              ls_data-api_message = |Error: Document Year { ls_data-fiscal_year } for Physical Inventory { ls_data-pid } not exist|.
            ELSE.

              SELECT SINGLE material
                  FROM  i_physinvtrydocitem
                  WHERE physicalinventorydocument = @ls_data-pid
                  AND physicalinventorydocumentitem = @ls_data-pid_item
                  INTO @DATA(lv_material).
              IF lv_material NE lv_material_filter.

                ls_data-api_status = |E|.
                ls_data-api_message = |Error: Material number { ls_data-material } for Physical Inventory { ls_data-pid }, Physical Inventory Item { ls_data-pid_item } not exist|.
              ELSE.

                SELECT SINGLE productname
                    FROM i_producttext
                    WHERE product = @lv_material_filter
                    AND language = 'E'
                    INTO @ls_data-material_description.

                SELECT SINGLE plant
                    FROM i_physinvtrydocitem
                    WHERE physicalinventorydocument = @ls_data-pid
                    AND physicalinventorydocumentitem = @ls_data-pid_item
                    AND material = @lv_material_filter
                    INTO @DATA(lv_plant).
                IF lv_plant NE ls_data-plant.

                  ls_data-api_status = |E|.
                  ls_data-api_message = |Error: Material number { ls_data-material }, Plant { ls_data-plant } not exist for Physical Inventory { ls_data-pid }|.
                ELSE.

                  SELECT SINGLE storagelocation
                      FROM i_physinvtrydocitem
                      WHERE physicalinventorydocument = @ls_data-pid
                      AND physicalinventorydocumentitem = @ls_data-pid_item
                      AND material = @lv_material_filter
                      INTO @DATA(lv_sloc).
                  IF lv_sloc NE ls_data-storage_location.
                    ls_data-api_status = |E|.
                    ls_data-api_message = |Error: Material number { ls_data-material }, Storage Location { ls_data-storage_location } not exist for Physical Inventory { ls_data-pid }|.
                  ELSE.

                    SELECT SINGLE *
                      FROM i_physinvtrydocitem
                       WHERE  plant = @ls_data-plant
                       AND StorageLocation = @ls_data-storage_location
                       AND FiscalYear = @ls_data-fiscal_year
                       AND PhysicalInventoryDocument = @ls_data-pid
                       AND PhysicalInventoryDocumentItem = @ls_data-pid_item
                      INTO @DATA(ls_data_pi_status).

                    SELECT SINGLE *
                        FROM i_physinvtrydocheader
                        WHERE plant = @ls_data-plant
                        AND storagelocation = @ls_data-storage_location
                        AND physicalinventorydocument = @ls_data-pid
                        INTO @DATA(ls_docheader).

                    IF ls_DOCHEADER-PhysInvtryAdjustmentPostingSts = 'X'.
                      lv_pi_status = 'Adjusted'.
                    ELSEIF ls_DOCHEADER-PhysicalInventoryCountStatus = 'X' OR ls_data_pi_status-PhysicalInventoryItemIsCounted = 'X'.
                      lv_pi_status = 'Counted'.
                    ELSEIF ls_DOCHEADER-PhysicalInventoryCountStatus = 'A' AND ls_data_pi_status-QuantityInUnitOfEntry IS NOT INITIAL.
                      lv_pi_status = 'Counted'.
                    ELSEIF ls_DOCHEADER-PhysicalInventoryCountStatus = 'A' AND ls_data_pi_status-QuantityInUnitOfEntry IS INITIAL.
                      lv_pi_status = 'Not Counted'.
                    ELSE.
                      lv_pi_status = 'Not Counted'.
                    ENDIF.

                    IF lv_pi_status = 'Not Counted'.
                      SELECT SINGLE batch
                          FROM i_physinvtrydocitem
                          WHERE physicalinventorydocument = @ls_data-pid
                          AND physicalinventorydocumentitem = @ls_data-pid_item
                          AND material = @lv_material_filter
                          INTO @DATA(lv_batch).
                      IF lv_batch NE ls_data-batch.
                        ls_data-api_status = |E|.
                        ls_data-api_message = |Error: Material number { ls_data-material }, Batch { ls_data-batch } not exist for Physical Inventory { ls_data-pid }|.
                      ENDIF.

                      SELECT SINGLE supplier
                          FROM i_physinvtrydocitem
                          WHERE physicalinventorydocument = @ls_data-pid
                          AND physicalinventorydocumentitem = @ls_data-pid_item
                          AND material = @lv_material_filter
                          INTO @DATA(lv_spe_stok_num).
                      IF lv_spe_stok_num NE ls_data-Supplier.
                        ls_data-api_status = |E|.
                        ls_data-api_message = |Error: Material number { ls_data-material }, Supplier’s Account Number { ls_data-Supplier } not exist for Physical Inventory { ls_data-pid }|.
                      ENDIF.

                      SELECT SINGLE salesorder
                          FROM i_physinvtrydocitem
                          WHERE physicalinventorydocument = @ls_data-pid
                          AND physicalinventorydocumentitem = @ls_data-pid_item
                          AND material = @lv_material_filter
                          INTO @DATA(lv_sales_order).
                      IF lv_sales_order NE ls_data-sales_order.
                        ls_data-api_status = |E|.
                        ls_data-api_message = |Error: Material number { ls_data-material }, Sales Order { ls_data-sales_order } not exist for Physical Inventory { ls_data-pid }|.
                      ENDIF.

                      SELECT SINGLE SalesOrderItem
                          FROM i_physinvtrydocitem
                          WHERE physicalinventorydocument = @ls_data-pid
                          AND physicalinventorydocumentitem = @ls_data-pid_item
                          AND material = @lv_material_filter
                          INTO @DATA(lv_sales_order_item).
                      IF lv_sales_order_item NE ls_data-sales_order_item.
                        ls_data-api_status = |E|.
                        ls_data-api_message = |Error: Material number { ls_data-material }, Item no. of Sales Order { ls_data-sales_order_item } not exist for Physical Inventory { ls_data-pid }|.
                      ENDIF.

                      SELECT DISTINCT UnitOfEntry
                          FROM i_physinvtrydocitem
                          INTO TABLE @DATA(lt_check_uom).
                      SORT lt_check_uom BY UnitOfEntry.

                      READ TABLE lt_check_uom INTO DATA(ls_check_uom) WITH KEY UnitOfEntry = ls_data-counted_qty_uom BINARY SEARCH.
                      IF sy-subrc <> 0.
                        ls_data-api_status = |E|.
                        ls_data-api_message = |Error: Counted Qty UoM { ls_data-counted_qty_uom } not exist!|.
                      ENDIF.

                    ELSE.
                      ls_data-api_status = |C|.
                      ls_data-api_message = |Error: Chứng từ này đã được Count, không thể chỉnh sửa|.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF ls_data-api_status IS INITIAL.
        ls_data-api_status = |S|.
        ls_data-api_message = |Success|.
      ENDIF.

      APPEND ls_data TO lt_data.
      CLEAR: ls_data.
    ENDLOOP.

    DATA: lt_inventory      TYPE TABLE OF ztb_inven_im1,
          lt_inventory_temp TYPE TABLE OF ztb_inven_im1,
          ls_inventory      TYPE ztb_inven_im1.

    LOOP AT lt_data INTO ls_data.
      IF ls_data-pid IS NOT INITIAL AND ls_data-pid_item IS NOT INITIAL.
        SELECT SINGLE *
            FROM ztb_inven_im1
            WHERE pid = @ls_data-pid
            AND pid_item = @ls_data-pid_item
            AND document_year = @ls_data-fiscal_year
            INTO @DATA(ls_inventory_db).
      ELSE.
        SELECT SINGLE *
            FROM ztb_inven_im1
            WHERE document_year = @ls_data-fiscal_year
            AND material = @ls_data-material
            AND plant = @ls_data-plant
            AND storage_location = @ls_data-storage_location
            AND plant = @ls_data-plant
            AND batch = @ls_data-batch
            AND sales_order = @ls_data-sales_order
            AND sales_order_item = @ls_data-sales_order_item
            AND spe_stok = @ls_data-Supplier
            AND api_status = 'A'
            INTO @ls_inventory_db.
      ENDIF.

      IF ls_inventory_db IS NOT INITIAL.
        ls_inventory-uuid = ls_inventory_db-uuid.

      ELSE.
        TRY.
            DATA(lv_cid) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "Error handling
        ENDTRY.
        ls_inventory-uuid = lv_cid.
      ENDIF.

*  convert_sap_no
      ls_inventory-convert_sap_no = ls_data-convert_sap_no.
*  pid
      ls_inventory-pid = ls_data-pid.
*  pid_item
      ls_inventory-pid_item = ls_data-pid_item.
*  fiscal_year
      ls_inventory-document_year = ls_data-fiscal_year.
*  document_date
      ls_inventory-doc_date = ls_data-document_date.
*  plan_count_date
      ls_inventory-plant_count_date = ls_data-plan_count_date.
*  count_date
      ls_inventory-count_date = ls_data-plan_count_date.
*  material
      ls_inventory-material = ls_data-material.
*  material_description
      ls_inventory-material_description = ls_data-material_description.
*  plant
      ls_inventory-plant = ls_data-plant.
*  storage_location
      ls_inventory-storage_location = ls_data-storage_location.
*  batch
      ls_inventory-batch = ls_data-batch.
*  sales_order
      ls_inventory-sales_order = ls_data-sales_order.
*  sales_order_item
      ls_inventory-sales_order_item = ls_data-sales_order_item.
*  spe_stok_num
      ls_inventory-spe_stok_num = ls_data-Supplier.
*  pda_quantity
      ls_inventory-pda_qty = ls_data-pda_quantity.
*  counted_qty_uom
      ls_inventory-counted_qty_uom = ls_data-counted_qty_uom.
*  zero_count
      ls_inventory-zero_count = ls_data-zero_count.

      ls_inventory-api_status = ls_data-api_status.
      ls_inventory-api_message = ls_data-api_message.

      ls_inventory-pda_date = ls_data-pda_date.
      ls_inventory-pda_time = ls_data-pda_time.

      ls_inventory-counter = ls_data-counter.

      ls_inventory-api_date = lv_date.
      ls_inventory-api_time = lv_time.

      IF ls_inventory-api_status = |C|.
        ls_inventory-api_status = |E|.

        APPEND ls_inventory TO lt_inventory.
        CLEAR: ls_inventory.

      ELSEIF ls_inventory_db-api_status = |A| AND ls_inventory_db IS NOT INITIAL.
        ls_inventory-api_status = |E|.
        ls_inventory-api_message = |Đã tồn tại chứng từ được 'Adding', không thể ghi đè!|.

        APPEND ls_inventory TO lt_inventory_temp.
        CLEAR: ls_inventory.

      ELSEIF ls_inventory_db-api_status = |S|.
        ls_inventory-api_status = |E|.
        ls_inventory-api_message = |Chứng từ đã đẩy thành công, không thể ghi đè!|.

        APPEND ls_inventory TO lt_inventory_temp.
        CLEAR: ls_inventory.

      ELSE.
        APPEND ls_inventory TO lt_inventory.
        CLEAR: ls_inventory.

      ENDIF.
    ENDLOOP.

    MODIFY ztb_inven_im1 FROM TABLE @lt_inventory.
    COMMIT WORK.

    LOOP AT lt_inventory_temp INTO DATA(ls_inventory_temp).
      MOVE-CORRESPONDING ls_inventory_temp TO ls_inventory.
      APPEND ls_inventory TO lt_inventory.
    ENDLOOP.

    IF lt_message IS INITIAL.
      APPEND VALUE #( messtype = 'S' messagetxt = 'Success' ) TO lt_message.
    ELSE.

    ENDIF.

*    E_CONTEXT = XCO_CP_JSON=>DATA->FROM_ABAP( LT_DATA )->APPLY( value #(
*    ( XCO_CP_JSON=>TRANSFORMATION->UNDERSCORE_TO_PASCAL_CASE )
*    ) )->TO_STRING( ).

    /ui2/cl_json=>serialize(
      EXPORTING
        data        = lt_inventory                 " ABAP structure/table
        pretty_name = /ui2/cl_json=>pretty_mode-none " tuỳ chọn: giữ/camel/snake
        compress    = abap_true                " bỏ khoảng trắng
      RECEIVING
        r_json      = e_context                  " chuỗi JSON kết quả
    ).

  ENDMETHOD.


  METHOD get_data_inventory.

    DATA: lv_fail TYPE zde_char1 VALUE abap_false.

    DATA: lt_request TYPE TABLE OF ty_request,
          ls_request TYPE ty_request,

          lt_data    TYPE TABLE OF ty_data,
          ls_data    TYPE ty_data,

          ls_message TYPE ty_message,
          lt_message TYPE TABLE OF ty_message.

    DATA: lr_pid      TYPE RANGE OF ztb_inventory1-pid,
          pid_item    TYPE RANGE OF ztb_inventory1-pid_item,
          lr_material TYPE RANGE OF ztb_inventory1-material,
          lr_plant    TYPE RANGE OF ztb_inventory1-plant,
          lr_sloc     TYPE RANGE OF ztb_inventory1-storage_location.

    DATA: lv_top TYPE int4.

    IF iv_top IS INITIAL.
      lv_top = 10.
    ELSE.
      lv_top = iv_top.
    ENDIF.

    SELECT * FROM ztb_inven_im1
    WHERE pid IN @lr_pid
    AND material IN @lr_material
    AND plant IN @lr_plant
    AND storage_location IN @lr_sloc
    INTO TABLE @DATA(lt_inventory)
    UP TO @lv_top ROWS.

    IF sy-subrc NE 0.
      lv_fail = abap_true.
    ENDIF.

    LOOP AT lt_inventory INTO DATA(ls_inventory).
*  convert_sap_no
      ls_data-convert_sap_no = ls_inventory-convert_sap_no.
*  pid
      ls_data-pid = ls_inventory-pid.
*  pid_item
      ls_data-pid_item = ls_inventory-pid_item.
*  fiscal_year
      ls_data-fiscal_year = ls_inventory-document_year.
*  document_date
      ls_data-document_date = ls_inventory-doc_date.
*  plan_count_date
      ls_data-plan_count_date = ls_inventory-plant_count_date.
*  count_date
      ls_data-plan_count_date = ls_inventory-count_date.
*  material
      ls_data-material = ls_inventory-material.
*  material_description
      ls_data-material_description = ls_inventory-material_description.
*  plant
      ls_data-plant = ls_inventory-plant.
*  storage_location
      ls_data-storage_location = ls_inventory-storage_location.
*  batch
      ls_data-batch = ls_inventory-batch.
*  sales_order
      ls_data-sales_order = ls_inventory-sales_order.
*  sales_order_item
      ls_data-sales_order_item = ls_inventory-sales_order_item.
*  spe_stok_num
      ls_data-Supplier = ls_inventory-spe_stok_num.
*  pda_quantity
      ls_data-pda_quantity = ls_inventory-pda_qty.
*  counted_qty_uom
      ls_data-counted_qty_uom = ls_inventory-counted_qty_uom.
*  zero_count
      ls_data-zero_count = ls_inventory-zero_count.

      ls_data-api_status = ls_inventory-api_status.
      ls_data-api_message = ls_inventory-api_message.
      ls_data-pda_date = ls_inventory-pda_date.
      ls_data-pda_time = ls_inventory-pda_time.
      ls_data-counter = ls_inventory-counter.
      ls_data-api_date = ls_inventory-api_date.
      ls_data-api_time = ls_inventory-api_time.

      APPEND ls_data TO lt_data.
      CLEAR: ls_data.
    ENDLOOP.

    IF lv_fail = abap_true.
      APPEND VALUE #( messtype = 'E' messagetxt = 'No data!' ) TO lt_message.
      e_context = xco_cp_json=>data->from_abap( lt_message )->apply( VALUE #(
                                                                         ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).
    ELSE.

*      E_CONTEXT = XCO_CP_JSON=>DATA->FROM_ABAP( LT_DATA )->APPLY( value #(
*      ( XCO_CP_JSON=>TRANSFORMATION->UNDERSCORE_TO_PASCAL_CASE )
*      ) )->TO_STRING( ).
      /ui2/cl_json=>serialize(
        EXPORTING
          data        = lt_data                 " ABAP structure/table
          pretty_name = /ui2/cl_json=>pretty_mode-none " tuỳ chọn: giữ/camel/snake
          compress    = abap_true                " bỏ khoảng trắng
        RECEIVING
          r_json      = e_context                  " chuỗi JSON kết quả
      ).

    ENDIF.
  ENDMETHOD.


  METHOD get_data_inventory_1.
    DATA: lv_fail TYPE zde_char1 VALUE abap_false.
    DATA: lt_request  TYPE TABLE OF ty_request,
          ls_request  TYPE ty_request,

          lt_data     TYPE TABLE OF ty_data,
          ls_data     TYPE ty_data,

          ls_message  TYPE ty_message,
          lt_message  TYPE TABLE OF ty_message,
          ls_pid_item TYPE ztb_inven_im1-pid_item,
          ls_matnr    TYPE ztb_inven_im1-material,
          ls_pid      TYPE ztb_inven_im1-pid.

    DATA: lr_pid      TYPE  tt_ranges,
          lr_pid_item TYPE tt_ranges,
          lr_matnr    TYPE tt_ranges.

    DATA: lt_pid_raw    TYPE TABLE OF string,
          lv_pid_string TYPE string.

    IF iv_pid IS NOT INITIAL.

      lv_pid_string = iv_pid.
      SPLIT lv_pid_string AT '%20' INTO TABLE lt_pid_raw.

      LOOP AT lt_pid_raw INTO DATA(lv_single_pid).
        IF lv_single_pid IS NOT INITIAL.
          DATA(lv_pid_alpha) = |{ lv_single_pid ALPHA = IN }|.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_pid_alpha ) TO lr_pid.
        ENDIF.
      ENDLOOP.
    ENDIF.

    "==== Xử lý iv_from (from–to) ====
    IF iv_from IS NOT INITIAL.
      DATA(lv_from_to_str) = to_lower( condense( iv_from ) ).
      DATA(lv_pos) = sy-fdpos.
      FIND 'to' IN lv_from_to_str MATCH OFFSET lv_pos.

      IF sy-subrc = 0.
        DATA(lv_from) = lv_from_to_str+0(lv_pos).
        DATA(lv_to_start) = lv_pos + 2.
        DATA(lv_to) = lv_from_to_str+lv_to_start.

        IF lv_from IS NOT INITIAL AND lv_to IS NOT INITIAL.
          DATA:lv_from_alpha TYPE char10,
               lv_to_alpha   TYPE char10.

          lv_from_alpha = |{ lv_from ALPHA = IN }|.
          lv_to_alpha   = |{ lv_to   ALPHA = IN }|.
          APPEND VALUE #( sign = 'I' option = 'BT' low = lv_from_alpha high = lv_to_alpha ) TO lr_pid.
        ENDIF.
      ENDIF.
    ENDIF.

    IF iv_pid_item IS NOT INITIAL.
      ls_pid_item = |{ iv_pid_item ALPHA = IN }|.
      lr_pid_item = VALUE #( ( sign = 'I' option = 'EQ' low = iv_pid_item ) ).
    ENDIF.

    IF iv_matnr IS NOT INITIAL.
      ls_matnr = |{ iv_matnr ALPHA = IN }|.
      lr_matnr = VALUE #( ( sign = 'I' option = 'EQ' low = iv_matnr ) ).
    ENDIF.

    DATA: lv_top TYPE int4.



    CALL METHOD zcl_get_inventory_data_im=>get_im_data
      EXPORTING
        iv_pid      = lr_pid
        iv_pid_item = lr_pid_item
*       iv_document_year  = lr_documentyear
*       iv_plant    = lr_plant
*       iv_store_loca     = lr_store_location
        iv_matnr    = lr_matnr
*       iv_convert_sap_no = lr_convert_sap_no
*       iv_pi_status      = lr_pi_status
      IMPORTING
        ev_result   = DATA(lt_data_get).


    IF iv_top IS NOT INITIAL.
      lv_top = iv_top.
      IF lines( lt_data_get ) > lv_top.
        DELETE lt_data_get FROM lv_top + 1 TO lines( lt_data_get ).
      ENDIF.
    ENDIF.




    LOOP AT lt_data_get INTO DATA(ls_inventory).
*  convert_sap_no
*      ls_data-convert_sap_no = ls_inventory-ConvertSapNo.
**  pid
*      ls_data-pid = ls_inventory-pid.
**  pid_item
*      ls_data-pid_item = ls_inventory-pid_item.
**  fiscal_year
*      ls_data-fiscal_year = ls_inventory-DocumantYear.
***  document_date
**      ls_data-document_date = ls_inventory-doc_date.
***  plan_count_date
**      ls_data-plan_count_date = ls_inventory-plant_count_date.
**  count_date
*      ls_data-plan_count_date = ls_inventory-Countdate.
**  material
*      ls_data-material = ls_inventory-material.
**  material_description
*      ls_data-material_description = ls_inventory-MaterialDescription.
**  plant
*      ls_data-plant = ls_inventory-plant.
**  storage_location
*      ls_data-storage_location = ls_inventory-Storagelocation.
**  batch
*      ls_data-batch = ls_inventory-batch.
**  sales_order
*      ls_data-sales_order = ls_inventory-Salesorder.
**  sales_order_item
*      ls_data-sales_order_item = ls_inventory-SalesOrderItem.
**  spe_stok_num
*      ls_data-Supplier = ls_inventory-Spestoknum.
**  pda_quantity
*      ls_data-pda_quantity = ls_inventory-PdaQty.
**  counted_qty_uom
*      ls_data-counted_qty_uom = ls_inventory-CountedQtyUom.
**  zero_count
*      ls_data-zero_count = ls_inventory-ZeroCount.
*      IF ls_inventory-ApiStatus IS NOT INITIAL.
*        ls_data-api_status = ls_inventory-ApiStatus.
*      ELSE.
*        ls_data-api_status = 'null'.
*      ENDIF.
*
*      IF ls_inventory-ApiMessage IS NOT INITIAL.
*        ls_data-api_message = ls_inventory-ApiMessage.
*      ELSE.
*        ls_data-api_message = 'null'.
*      ENDIF.
*
*      ls_data-pda_date = ls_inventory-pdadate.
*      ls_data-pda_time = ls_inventory-pdatime.
*      ls_data-counter = ls_inventory-counter.
*      ls_data-api_date = ls_inventory-apidate.
*      ls_data-api_time = ls_inventory-apitime.

      IF ls_inventory-Pid IS NOT INITIAL.
        ls_data-pid  = |{ ls_inventory-pid ALPHA = OUT }|.
      ELSE.
        ls_data-pid = 'null'.
      ENDIF.

      IF ls_inventory-Pid_item IS NOT INITIAL.
        ls_data-pid_item  = |{ ls_inventory-Pid_item ALPHA = OUT }|.
      ELSE.
        ls_data-pid_item = 'null'.
      ENDIF.
      ls_data-material  = |{ ls_inventory-material ALPHA = OUT }|.

      ls_data-convert_sap_no       = COND string( WHEN ls_inventory-convertsapno IS INITIAL THEN 'null' ELSE ls_inventory-convertsapno ).
*      ls_data-pid                  = COND string( WHEN ls_inventory-pid IS INITIAL THEN 'null' ELSE ls_inventory-pid ).
*      ls_data-pid_item             = COND string( WHEN ls_inventory-pid_item IS INITIAL THEN 'null' ELSE ls_inventory-pid_item ).
      ls_data-fiscal_year          = COND string( WHEN ls_inventory-DocumantYear IS INITIAL THEN 'null' ELSE ls_inventory-DocumantYear ).
      ls_data-plan_count_date      = COND string( WHEN ls_inventory-countdate IS INITIAL THEN 'null' ELSE ls_inventory-countdate ).
*      ls_data-material             = COND string( WHEN ls_inventory-material IS INITIAL THEN 'null' ELSE ls_inventory-material ).
      ls_data-material_description = COND string( WHEN ls_inventory-materialdescription IS INITIAL THEN 'null' ELSE ls_inventory-materialdescription ).
      ls_data-plant                = COND string( WHEN ls_inventory-plant IS INITIAL THEN 'null' ELSE ls_inventory-plant ).
      ls_data-storage_location     = COND string( WHEN ls_inventory-storagelocation IS INITIAL THEN 'null' ELSE ls_inventory-storagelocation ).
      ls_data-batch                = COND string( WHEN ls_inventory-batch IS INITIAL THEN 'null' ELSE ls_inventory-batch ).
      ls_data-sales_order          = COND string( WHEN ls_inventory-salesorder IS INITIAL THEN 'null' ELSE ls_inventory-salesorder ).
      ls_data-sales_order_item          = COND string( WHEN ls_inventory-SalesOrderItem IS INITIAL THEN 'null' ELSE ls_inventory-SalesOrderItem ).
      ls_data-supplier             = COND string( WHEN ls_inventory-spestoknum IS INITIAL THEN 'null' ELSE ls_inventory-spestoknum ).
      ls_data-pda_quantity         = COND string( WHEN ls_inventory-pdaqty IS INITIAL THEN 'null' ELSE ls_inventory-pdaqty ).
      ls_data-counted_qty_uom      = COND string( WHEN ls_inventory-countedqtyuom IS INITIAL THEN 'null' ELSE ls_inventory-countedqtyuom ).
      ls_data-zero_count           = COND string( WHEN ls_inventory-zerocount IS INITIAL THEN 'null' ELSE ls_inventory-zerocount ).
      ls_data-api_status           = COND string( WHEN ls_inventory-apistatus IS INITIAL THEN 'null' ELSE ls_inventory-apistatus ).
      ls_data-api_message          = COND string( WHEN ls_inventory-apimessage IS INITIAL THEN 'null' ELSE ls_inventory-apimessage ).
      ls_data-pda_date             = COND string( WHEN ls_inventory-pdadate IS INITIAL THEN 'null' ELSE ls_inventory-pdadate ).
      ls_data-pda_time             = COND string( WHEN ls_inventory-pdatime IS INITIAL THEN 'null' ELSE ls_inventory-pdatime ).
      ls_data-counter              = COND string( WHEN ls_inventory-counter IS INITIAL THEN 'null' ELSE ls_inventory-counter ).
      ls_data-api_date             = COND string( WHEN ls_inventory-apidate IS INITIAL THEN 'null' ELSE ls_inventory-apidate ).
      ls_data-api_time             = COND string( WHEN ls_inventory-apitime IS INITIAL THEN 'null' ELSE ls_inventory-apitime ).


      APPEND ls_data TO lt_data.
      CLEAR: ls_data.
    ENDLOOP.

    IF lv_fail = abap_true.
      APPEND VALUE #( messtype = 'E' messagetxt = 'No data!' ) TO lt_message.
      e_context = xco_cp_json=>data->from_abap( lt_message )->apply( VALUE #(
                                                                         ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).
    ELSE.

*      E_CONTEXT = XCO_CP_JSON=>DATA->FROM_ABAP( LT_DATA )->APPLY( value #(
*      ( XCO_CP_JSON=>TRANSFORMATION->UNDERSCORE_TO_PASCAL_CASE )
*      ) )->TO_STRING( ).
      /ui2/cl_json=>serialize(
        EXPORTING
          data        = lt_data                 " ABAP structure/table
          pretty_name = /ui2/cl_json=>pretty_mode-none " tuỳ chọn: giữ/camel/snake
          compress    = abap_true                " bỏ khoảng trắng
        RECEIVING
          r_json      = e_context                  " chuỗi JSON kết quả
      ).

    ENDIF.

  ENDMETHOD.


  METHOD post_invoice_api.

    TYPES: BEGIN OF ty_physinv_d,
             material                       TYPE matnr,           " Mã vật tư
             batch                          TYPE charg_d,         " Lô hàng
             inventoryspecialstocktype      TYPE char1,           " Loại tồn kho đặc biệt (E/K/Q...)
             physicalinventorystocktype     TYPE char1,           " Loại tồn kho kiểm kê
             salesorder                     TYPE vbeln_va,        " Đơn hàng bán
             salesorderitem                 TYPE posnr_va,        " Dòng đơn hàng
             supplier                       TYPE lifnr,           " Nhà cung cấp (có thể rỗng)
             customer                       TYPE kunnr,           " Khách hàng (có thể rỗng)
             countedbyuser                  TYPE syuname,         " Người đếm
             physicalinventorylastcountdate TYPE string,          " Dạng "/Date(…)/"
             quantity                       TYPE string,          " Dạng chuỗi vì API nhận JSON text
             unitofentry                    TYPE meins,           " Đơn vị
             quantityinunitofentry          TYPE string,          " Số lượng đếm được
           END OF ty_physinv_d.

    TYPES: BEGIN OF ty_physinv,
             d TYPE ty_physinv_d,
           END OF ty_physinv.
    DATA: lw_username TYPE string,
          lw_password TYPE string.
    DATA: ls_physinv TYPE ty_physinv.



    DATA(lw_json_body) = /ui2/cl_json=>serialize(
      data        = ls_physinv
      compress    = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    " Nếu cần sửa key trong JSON thì thay ở đây, ví dụ:
    REPLACE ALL OCCURRENCES OF 'quantityinunitofentry'
       IN lw_json_body WITH 'QuantityInUnitOfEntry'.

    DATA: lo_http_client  TYPE REF TO if_web_http_client,
          response        TYPE string,
          lv_response     TYPE string,
          lv_token        TYPE string,
          lv_url          TYPE string,
          lv_doc          TYPE string VALUE '500001',
          lv_item         TYPE string VALUE '0001',
          lv_year         TYPE string VALUE '2025',
          ls_odata_return TYPE zst_odata_return.

    SELECT SINGLE * FROM ztb_api_auth
  WHERE systemid = 'CASLA'
INTO @DATA(ls_api_auth).

    lv_url = |https://{ ls_api_auth-api_url }/sap/opu/odata/sap/API_PHYSICAL_INVENTORY_DOC_SRV/|
            && |A_PhysInventoryDocItem(FiscalYear='{ lv_year }',|
            && |PhysicalInventoryDocument='{ lv_doc }',|
            && |PhysicalInventoryDocumentItem='{ lv_item }')|.

    TRY.

        DATA(lo_http_destination) =
          cl_http_destination_provider=>create_by_url( lv_url ).
        DATA(lo_web_http_client) =
          cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
        DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
        lo_web_http_request->set_header_fields( VALUE #(
           ( name = 'DataServiceVersion' value = '2.0' )
           ( name = 'Accept'             value = 'application/json' )
        ) ).

        lo_web_http_request->set_authorization_basic( i_username = lw_username i_password = lw_password ).
        lo_web_http_request->set_content_type( |application/json| ).
        lo_web_http_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
        lo_web_http_request->set_header_field( i_name = 'x-csrf-token' i_value = 'Fetch' ).

        DATA(lo_response) = lo_web_http_client->execute( i_method = if_web_http_client=>get ).
        lv_token    = lo_response->get_header_field( 'x-csrf-token' ).
        lo_web_http_request->set_header_field( i_name = 'x-csrf-token' i_value = lv_token ).

        lo_web_http_request->set_text( lw_json_body ).
        "set request method and execute request
        DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>post ).
        lv_response = lo_web_http_response->get_text( ).

        /ui2/cl_json=>deserialize(
          EXPORTING
            json = lv_response
          CHANGING
            data = e_response ).
        DATA(lv_status) = lo_web_http_response->get_status( ).
        e_code = lv_status-code.

      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.

    ENDTRY.
  ENDMETHOD.
ENDCLASS.

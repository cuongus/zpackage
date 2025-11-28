CLASS zcl_http_inventory_data DEFINITION
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
        uuid                 TYPE string,
        convert_sap_no       TYPE string,
        pid                  TYPE string,
        pid_item             TYPE string,
        fiscal_year          TYPE string,
        count_date           TYPE string,
        warehouse_number     TYPE string,
        material             TYPE string,
        material_description TYPE string,
        batch                TYPE string,
        sales_order          TYPE string, " New
        sales_order_item     TYPE string, " New
*        Supplier             TYPE string, " New
        storage_type         TYPE string,
        storage_bin          TYPE string,
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
             uuid                 TYPE ztb_inven_im1-uuid,
             convert_sap_no       TYPE c LENGTH 14,
             pid                  TYPE char7,
             pid_item             TYPE c LENGTH 6,    " new
             fiscal_year          TYPE i_ewm_physinvtryitemrow-physicalinventorydocyear,
             count_date           TYPE datum, "i_ewm_physicalinventoryitem-PInvCountedUTCDateTime,
             warehouse_number     TYPE i_ewm_physinvtryitemrow-ewmwarehouse,
             material             TYPE c LENGTH 18, "i_ewm_physinvtryitemrow-Product,
             material_description TYPE i_producttext-productname,
             batch                TYPE i_ewm_physinvtryitemrow-batch,
             sales_order          TYPE i_ewm_physinvtryitemrow-specialstockidfgsalesorder,     " new
             sales_order_item     TYPE string, " new
*             Supplier             TYPE i_ewm_physinvtryitemrow-stockdocumentcategory,          " new
             storage_type         TYPE i_ewm_physinvtryitemrow-ewmstoragetype,
             storage_bin          TYPE i_ewm_physinvtryitemrow-ewmstoragebin,
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
ENDCLASS.



CLASS ZCL_HTTP_INVENTORY_DATA IMPLEMENTATION.


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
        IF gv_pid IS NOT INITIAL OR gv_pid_item IS NOT INITIAL OR gv_matnr IS NOT INITIAL OR gv_top IS NOT INITIAL OR gv_from IS NOT INITIAL.

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

        ELSEIF gv_pid IS INITIAL AND gv_pid_item IS INITIAL AND gv_matnr IS  INITIAL AND  gv_top IS INITIAL AND gv_from IS INITIAL.
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

    DATA: lv_fail            TYPE zde_char1,
          lv_counted         TYPE zde_char1,
          lv_pi_status       TYPE ztb_inventory1-pi_status,

          lv_pid_cond        TYPE ty_data-pid,
          lv_pid_item_cond   TYPE ty_data-material,
          lv_material_filter TYPE ty_data-material.

    DATA: lt_request TYPE TABLE OF ty_request,
          ls_request TYPE ty_request,

          lt_data    TYPE TABLE OF ty_data,
          ls_data    TYPE ty_data,

          ls_message TYPE ty_message,
          lt_message TYPE TABLE OF ty_message.

*    xco_cp_json=>data->from_string( iv_request )->apply( VALUE #(
*            ( xco_cp_json=>transformation->pascal_case_to_underscore )
*    ) )->write_to( REF #( lt_request ) ).

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
          FROM ztb_inventory1
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
        lv_pid_cond = ls_data-pid.
        SHIFT lv_pid_cond LEFT DELETING LEADING '0'.

        lv_pid_item_cond = ls_data-pid_item.
        SHIFT lv_pid_item_cond LEFT DELETING LEADING '0'.

        lv_material_filter = ls_data-material.
        lv_material_filter = |{ lv_material_filter ALPHA = IN }|.
        CONDENSE ls_data-material.

        IF ls_data-sales_order_item IS NOT INITIAL.
          SHIFT ls_data-sales_order_item LEFT DELETING LEADING '0'.
        ENDIF.

        SELECT SINGLE physicalinventorydocnumber
            FROM  i_ewm_physinvtryitemrow
            WHERE physicalinventorydocnumber = @ls_data-pid
            INTO @DATA(lv_pid).
        IF sy-subrc NE 0.
          ls_data-api_status = |E|.
          ls_data-api_message = |Error: Physical Inventory { ls_data-pid } not exist|.
        ELSE.

          SELECT SINGLE physicalinventoryitemnumber
              FROM i_ewm_physinvtryitemrow
              WHERE physicalinventorydocnumber = @ls_data-pid
              AND physicalinventoryitemnumber = @ls_data-pid_item
              INTO @DATA(lv_pid_item).
          IF sy-subrc NE 0.
            ls_data-api_status = |E|.
            ls_data-api_message = |Error: Line Item { lv_pid_item_cond } for Physical Inventory { lv_pid_cond } not exist|.
          ELSE.

            SELECT SINGLE ewmwarehouse
                FROM i_ewm_physinvtryitemrow
                WHERE physicalinventorydocnumber = @ls_data-pid
                AND physicalinventoryitemnumber = @ls_data-pid_item
                AND ewmwarehouse = @ls_data-warehouse_number
                INTO @DATA(lv_warehouse_number).
            IF lv_warehouse_number NE ls_data-warehouse_number.
              ls_data-api_status = |E|.
              ls_data-api_message = |Error: Warehouse Number { ls_data-warehouse_number } for Physical Inventory { lv_pid_cond } not exist|.
            ELSE.

              SELECT SINGLE product
                  FROM i_ewm_physinvtryitemrow
                  WHERE physicalinventorydocnumber = @ls_data-pid
                  AND physicalinventoryitemnumber = @ls_data-pid_item
                  AND ewmwarehouse = @ls_data-warehouse_number
                  INTO @DATA(lv_material).
              IF lv_material NE lv_material_filter.
                ls_data-api_status = |E|.
                ls_data-api_message = |Error: Material number { ls_data-material } for Physical Inventory { lv_pid_cond } not exist|.
                ls_data-zero_count = 'X'.
              ELSE.

                SELECT SINGLE productname
                    FROM i_producttext
                    WHERE product = @lv_material
                    AND language = 'E'
                    INTO @ls_data-material_description.

                SELECT SINGLE EWMPhysicalInventoryStatus
                    FROM i_ewm_physicalinventoryitem
                    WHERE PhysicalInventoryDocNumber = @ls_data-pid
                    AND PhysicalInventoryItemNumber = @ls_data-pid_item
                    AND EWMWarehouse = @ls_data-warehouse_number
                    INTO @lv_pi_status.
                IF lv_pi_status IS NOT INITIAL.
                  IF lv_pi_status = 'ACTI'.
                    SELECT SINGLE PhysicalInventoryDocYear
                        FROM i_ewm_physinvtryitemrow
                        WHERE physicalinventorydocnumber = @ls_data-pid
                        INTO @DATA(lv_fiscal_year).
                    IF lv_fiscal_year NE ls_data-fiscal_year.
                      ls_data-api_status = |E|.
                      ls_data-api_message = |Error: Document Year { ls_data-fiscal_year } for Physical Inventory { lv_pid_cond } not exist|.
                    ENDIF.

                    SELECT SINGLE activityarea
                        FROM i_ewm_physinvtryitemrow
                        WHERE physicalinventorydocnumber = @ls_data-pid
                        AND physicalinventoryitemnumber = @ls_data-pid_item
                        AND product = @lv_material_filter
                        INTO @DATA(lv_storage_type).
                    IF lv_storage_type NE ls_data-storage_type.
                      ls_data-api_status = |E|.
                      ls_data-api_message = |Error: Material number { ls_data-material }, Storage Type { ls_data-storage_type } not exist for Physical Inventory { lv_pid_cond }|.
                    ENDIF.

*                    IF ls_data-count_date IS INITIAL.
*                      SELECT SINGLE PInvCountedUTCDateTime
*                          FROM i_ewm_physicalinventoryitem
*                          WHERE physicalinventorydocnumber = @ls_data-pid
*                          INTO @ls_data-count_date.
*                    ENDIF.

                    SELECT SINGLE ewmstoragebin
                        FROM i_ewm_physinvtryitemrow
                        WHERE physicalinventorydocnumber = @ls_data-pid
                        AND physicalinventoryitemnumber = @ls_data-pid_item
                        AND product = @lv_material_filter
                        INTO @DATA(lv_storage_bin).
                    IF lv_storage_bin NE ls_data-storage_bin.
                      ls_data-api_status = |E|.
                      ls_data-api_message = |Error: Material number { ls_data-material }, Storage Bin { ls_data-storage_bin } not exist for Physical Inventory { lv_pid_cond }|.
                    ENDIF.

                    SELECT SINGLE batch
                        FROM i_ewm_physinvtryitemrow
                        WHERE physicalinventorydocnumber = @ls_data-pid
                        AND physicalinventoryitemnumber = @ls_data-pid_item
                        AND product = @lv_material_filter
                        INTO @DATA(lv_batch).
                    IF lv_batch NE ls_data-batch.
                      ls_data-api_status = |E|.
                      ls_data-api_message = |Error: Material number { ls_data-material }, Batch { ls_data-batch } not exist for Physical Inventory { lv_pid_cond }|.
                    ENDIF.

                    SELECT SINGLE specialstockidfgsalesorder
                        FROM i_ewm_physinvtryitemrow
                        WHERE physicalinventorydocnumber = @ls_data-pid
                        AND physicalinventoryitemnumber = @ls_data-pid_item
                        AND product = @lv_material_filter
                        INTO @DATA(lv_sales_order).
                    IF lv_sales_order NE ls_data-sales_order.
                      ls_data-api_status = |E|.
                      ls_data-api_message = |Error: Material number { ls_data-material }, Sales Order { ls_data-sales_order } not exist for Physical Inventory { lv_pid_cond }|.
                    ENDIF.

                    SELECT SINGLE specialstockidfgsalesorderitem
                        FROM i_ewm_physinvtryitemrow
                        WHERE physicalinventorydocnumber = @ls_data-pid
                        AND physicalinventoryitemnumber = @ls_data-pid_item
                        AND product = @lv_material_filter
                        INTO @DATA(lv_sales_order_item).
                    IF lv_sales_order_item NE ls_data-sales_order_item.
                      ls_data-api_status = |E|.
                      ls_data-api_message = |Error: Material number { ls_data-material }, Item no. of Sales Order { ls_data-sales_order_item } not exist for Physical Inventory { lv_pid_cond }|.
                    ENDIF.

                    SELECT DISTINCT EWMPhysInvtryBookQtyUnit
                        FROM i_ewm_physinvtryitemrow
                        INTO TABLE @DATA(lt_check_uom).
                    SORT lt_check_uom BY EWMPhysInvtryBookQtyUnit.

                    READ TABLE lt_check_uom INTO DATA(ls_check_uom) WITH KEY EWMPhysInvtryBookQtyUnit = ls_data-counted_qty_uom BINARY SEARCH.
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

      IF  ls_data-api_status IS INITIAL.
        ls_data-api_status = |S|.
        ls_data-api_message = |Success|.
      ENDIF.

      APPEND ls_data TO lt_data.
      CLEAR: ls_data.
    ENDLOOP.

    DATA: lt_inventory      TYPE TABLE OF ztb_inventory1,
          lt_inventory_temp TYPE TABLE OF ztb_inventory1,
          ls_inventory      TYPE ztb_inventory1.

    LOOP AT lt_data INTO ls_data.
      IF ls_data-pid IS NOT INITIAL AND ls_data-pid_item IS NOT INITIAL.
        SELECT SINGLE *
            FROM ztb_inventory1
            WHERE pid = @ls_data-pid
            AND pid_item = @ls_data-pid_item
            AND document_year = @ls_data-fiscal_year
            INTO @DATA(ls_inventory_db).

      ELSE.
        SELECT SINGLE *
            FROM ztb_inventory1
            WHERE document_year = @ls_data-fiscal_year
            AND warehouse_number = @ls_data-warehouse_number
            AND material = @ls_data-material
            AND batch = @ls_data-batch
            AND sales_order = @ls_data-sales_order
            AND sales_order_item = @ls_data-sales_order_item
*            AND spe_stok_num = @ls_data-Supplier
            AND store_type = @ls_data-storage_type
            AND storage_bin = @ls_data-storage_bin
            AND api_status = 'A'
            INTO @ls_inventory_db.

      ENDIF.

*      SELECT SINGLE LineIndexOfPInvItem
*          FROM i_ewm_physinvtryitemrow
*          WHERE PhysicalInventoryDocNumber = @ls_data-pid
*          AND PhysicalInventoryItemNumber = @ls_data-pid_item
*          AND PhysicalInventoryDocYear = @ls_data-fiscal_year
*          AND ewmwarehouse = @ls_data-warehouse_number
*          AND specialstockidfgsalesorder = @ls_data-sales_order
*          AND specialstockidfgsalesorderitem = @ls_data-sales_order_item
**          AND stockdocumentcategory = @ls_data-Supplier
*          INTO @DATA(lv_line_index).

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
*  count_date
      ls_inventory-count_date = ls_data-count_date.
*  warehouse_number
      ls_inventory-warehouse_number = ls_data-warehouse_number.
*  material
      ls_inventory-material = ls_data-material.
*  material_description
      ls_inventory-material_description = ls_data-material_description.
*  batch
      ls_inventory-batch = ls_data-batch.
*  sales_order
      ls_inventory-sales_order = ls_data-sales_order.
*  sales_order_item
      ls_inventory-sales_order_item = ls_data-sales_order_item.
*  spe_stok_num
*      ls_inventory-spe_stok_num = ls_data-Supplier.
*  store_type
      ls_inventory-store_type = ls_data-storage_type.
*  storage_bin
      ls_inventory-storage_bin = ls_data-storage_bin.
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
        ls_inventory-api_message = |Đã tồn tại chứng từ được Adding, không thể ghi đè!|.

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

    MODIFY ztb_inventory1 FROM TABLE @lt_inventory.
    COMMIT WORK.

    LOOP AT lt_inventory_temp INTO DATA(ls_inventory_temp).
      MOVE-CORRESPONDING ls_inventory_temp TO ls_inventory.
      APPEND ls_inventory TO lt_inventory.
    ENDLOOP.

    IF lt_message IS INITIAL.
      APPEND VALUE #( messtype = 'S' messagetxt = 'Success' ) TO lt_message.
    ELSE.

    ENDIF.

*    e_context = xco_cp_json=>data->from_abap( lt_data )->apply( VALUE #(
*    ( xco_cp_json=>transformation->underscore_to_pascal_case )
*    ) )->to_string( ).

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

    SELECT * FROM ztb_inventory1
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
*  count_date
      ls_data-count_date = ls_inventory-count_date.
*  warehouse_number
      ls_data-warehouse_number = ls_inventory-warehouse_number.
*  material
      ls_data-material = ls_inventory-material.
*  material_description
      ls_data-material_description = ls_inventory-material_description.
*  batch
      ls_data-batch = ls_inventory-batch.
*  sales_order
      ls_data-sales_order = ls_inventory-sales_order.
*  sales_order_item
      ls_data-sales_order_item = ls_inventory-sales_order_item.
*  spe_stok_num
*      ls_data-Supplier = ls_inventory-spe_stok_num.
*  store_type
      ls_data-storage_type = ls_inventory-store_type.
*  storage_bin
      ls_data-storage_bin = ls_inventory-storage_bin.
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

*      e_context = xco_cp_json=>data->from_abap( lt_data )->apply( VALUE #(
*      ( xco_cp_json=>transformation->underscore_to_pascal_case )
*      ) )->to_string( ).

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
          ls_pid_item TYPE ztb_inventory1-pid_item,
          ls_matnr    TYPE ztb_inventory1-material,
          ls_pid      TYPE ztb_inventory1-pid.

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

    CALL METHOD zcl_get_inventory_data_wm=>get_wm_data
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
        ev_result   = DATA(lt_inventory).

    DATA: lv_top TYPE int4.
    IF iv_top IS NOT INITIAL.
      lv_top = iv_top.
      IF lines( lt_inventory ) > lv_top.
        DELETE lt_inventory FROM lv_top + 1 TO lines( lt_inventory ).
      ENDIF.
    ENDIF.

    LOOP AT lt_inventory INTO DATA(ls_inventory).
*
**  convert_sap_no
*      ls_data-convert_sap_no = ls_inventory-ConvertSapNo.
**  pid
*      ls_data-pid = ls_inventory-pid.
**  pid_item
*      ls_data-pid_item = ls_inventory-pid_item.
**  fiscal_year
*      ls_data-fiscal_year = ls_inventory-DocumentYear.
**  count_date
*      ls_data-count_date = ls_inventory-CountDate.
**  warehouse_number
*      ls_data-warehouse_number = ls_inventory-warehouse_number.
**  material
*      ls_data-material = ls_inventory-material.
**  material_description
*      ls_data-material_description = ls_inventory-MaterialDescription.
**  batch
*      ls_data-batch                = COND string( WHEN ls_inventory-batch IS INITIAL THEN 'null' ELSE ls_inventory-batch ).
**  sales_order
*      ls_data-sales_order = ls_inventory-Salesorder.
**  sales_order_item
*      ls_data-sales_order_item = ls_inventory-SalesOrderItem.
**  spe_stok_num
**      ls_data-Supplier = ls_inventory-spe_stok_num.
**  store_type
*      ls_data-storage_type = ls_inventory-StoreType.
**  storage_bin
*      ls_data-storage_bin = ls_inventory-storagebin.
**  pda_quantity
*      ls_data-pda_quantity = ls_inventory-pdaqty.
**  counted_qty_uom
*      ls_data-counted_qty_uom = ls_inventory-CountedQtyUom.
**  zero_count
*      ls_data-zero_count = ls_inventory-zerocount.
*
*      IF ls_inventory-apistatus IS NOT INITIAL .
*        ls_data-api_status = ls_inventory-apistatus.
*      ELSE.
*        ls_data-api_status = 'null'.
*      ENDIF.
*
*      IF ls_inventory-apimessage IS NOT INITIAL.
*        ls_data-api_message = ls_inventory-apimessage.
*      ELSE.
*        ls_data-api_message = 'null'.
*      ENDIF.
*
*      ls_data-pda_date = ls_inventory-pdadate.
*      ls_data-pda_time = ls_inventory-pdatime.
*
*      ls_data-counter = ls_inventory-counter.
*
*      ls_data-api_date             = COND string( WHEN ls_inventory-apidate IS INITIAL THEN 'null' ELSE ls_inventory-apidate ).
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
      ls_data-fiscal_year          = COND string( WHEN ls_inventory-documentyear IS INITIAL THEN 'null' ELSE ls_inventory-documentyear ).
      ls_data-count_date           = COND string( WHEN ls_inventory-countdate IS INITIAL THEN 'null' ELSE ls_inventory-countdate ).
      ls_data-warehouse_number     = COND string( WHEN ls_inventory-warehouse_number IS INITIAL THEN 'null' ELSE ls_inventory-warehouse_number ).
*      ls_data-material             = COND string( WHEN ls_inventory-material IS INITIAL THEN 'null' ELSE ls_inventory-material ).
      ls_data-material_description = COND string( WHEN ls_inventory-materialdescription IS INITIAL THEN 'null' ELSE ls_inventory-materialdescription ).
      ls_data-batch                = COND string( WHEN ls_inventory-batch IS INITIAL THEN 'null' ELSE ls_inventory-batch ).
      ls_data-sales_order          = COND string( WHEN ls_inventory-salesorder IS INITIAL THEN 'null' ELSE ls_inventory-salesorder ).
      ls_data-sales_order_item     = COND string( WHEN ls_inventory-salesorderitem IS INITIAL THEN 'null' ELSE ls_inventory-salesorderitem ).
      ls_data-storage_type         = COND string( WHEN ls_inventory-storetype IS INITIAL THEN 'null' ELSE ls_inventory-storetype ).
      ls_data-storage_bin          = COND string( WHEN ls_inventory-storagebin IS INITIAL THEN 'null' ELSE ls_inventory-storagebin ).
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

*      e_context = xco_cp_json=>data->from_abap( lt_data )->apply( VALUE #(
*      ( xco_cp_json=>transformation->underscore_to_pascal_case )
*      ) )->to_string( ).

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
ENDCLASS.

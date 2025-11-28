CLASS lhc_zr_tbmatnr_header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zr_tbmatnr_header
        RESULT result.


    METHODS DownloadFile FOR MODIFY
      IMPORTING keys FOR ACTION zr_tbmatnr_header~DownloadFile RESULT result.

    METHODS DownloadFile_1 FOR MODIFY
      IMPORTING keys FOR ACTION zr_tbmatnr_header~DownloadFile_1 RESULT result.


    TYPES: BEGIN OF ty_document_key,
             matnr_seque_numr TYPE string,
             matdoc           TYPE string,
             dtlid            TYPE string,
             option           TYPE string,
*             plant            TYPE werks_d,
*             pid              TYPE belnr_d,
*             piditem          TYPE mjahr,
*             DocumantYear     TYPE gjahr,
             Uuid             TYPE sysuuid_x16,
*             Storage_location TYPE lgort_d,
*             Material         TYPE matnr,
*             ConvertSapNo     TYPE  ztb_inven_im1-convert_sap_no,
           END OF ty_document_key.

    TYPES: tt_doc_keys TYPE STANDARD TABLE OF ty_document_key WITH EMPTY KEY.

*    METHODS Post FOR MODIFY
*      IMPORTING keys FOR ACTION zr_tbmatnr_header~Post RESULT result.

    METHODS Post FOR MODIFY
      IMPORTING keys FOR ACTION zr_tbmatnr_header~Count.

    TYPES:
      BEGIN OF ty_file_upload,
        document_date                 TYPE string,  " Document Date
        posting_date                  TYPE string,  " Posting Date
        material_document_header_text TYPE string,  " Material Document Header Text
        ctrlpostgforextwhsemgmtsyst   TYPE string,  " CtrlPostgForExtWhseMgmtSyst
        goods_movement_code           TYPE string,  " Goods Movement Code
        material_sequence_number      TYPE string,  " Material sequence number
        matnr_doc                     TYPE string,  " (Không nhập trong file)
        matnr_doc_item                TYPE string,  " (Không nhập trong file)
        reservation                   TYPE string,  " Reservation
        reservation_item              TYPE string,  " Reservation Item
        goods_movement_type           TYPE string,  " Goods Movement Type
        material                      TYPE string,  " Material
        plant                         TYPE string,  " Plant
        storage_location              TYPE string,  " Storage Location
        batch                         TYPE string,  " Batch
        valuation_type                TYPE string,  " Valuation Type
        quantity_in_entry_unit        TYPE string,  " Quantity in Entry Unit
        entry_unit                    TYPE string,  " Entry Unit
        cost_center                   TYPE string,  " Cost Center
        fixed_asset                   TYPE string,  " Fixed Asset
        special_stock                 TYPE string,  " Special Stock
        sales_order                   TYPE string,  " Sales Order
        sales_order_item              TYPE string,  " Sales Order Item
        vender                        TYPE string,
        order                         TYPE string,
        order_item                    TYPE string,
        material_document_item_text   TYPE string,  " Material Document Item Text
        ewm_warehouse                 TYPE string,  " EWM Warehouse
        ewm_storage_bin               TYPE string,  " EWM Storage Bin
      END OF ty_file_upload,

      ty_t_file_upload TYPE STANDARD TABLE OF ty_file_upload WITH EMPTY KEY.


    TYPES:
      BEGIN OF ty_file_upload_option2,
        document_date                 TYPE string,  " Document Date
        posting_date                  TYPE string,  " Posting Date
        material_document_header_text TYPE string,  " Material Document Header Text
        ctrlpostgforextwhsemgmtsyst   TYPE string,  " CtrlPostgForExtWhseMgmtSyst
        goods_movement_code           TYPE string,  " Goods Movement Code
        material_document             TYPE string,  " Material Document
        material_document_item        TYPE string,  " Material Document Item
        material_sequence_number      TYPE string,  " Material Sequence Number
        reservation                   TYPE string,  " Reservation
        reservation_item              TYPE string,  " Reservation Item
        goods_movement_type           TYPE string,  " Goods Movement Type
        from_material                 TYPE string,  " From Material
        from_plant                    TYPE string,  " From Plant
        from_storage_location         TYPE string,  " From Storage Location
        from_batch                    TYPE string,  " From Batch
        from_valuation_type           TYPE string,  " From Valuation Type
        special_stock                 TYPE string,  " Special Stock
        from_sales_order              TYPE string,  " From Sales Order
        from_sales_order_item         TYPE string,  " From Sales Order Item
        quantity_in_entry_unit        TYPE string,  " Quantity in Entry Unit
        entry_unit                    TYPE string,  " Entry Unit
        to_material                   TYPE string,  " To Material
        to_plant                      TYPE string,  " To Plant
        to_storage_location           TYPE string,  " To Storage Location
        to_batch                      TYPE string,  " To Batch
        to_valuation_type             TYPE string,  " To Valuation Type
        to_sales_order                TYPE string,  " To Sales Order
        to_sales_order_item           TYPE string,  " To Sales Order Item
        vendor                        TYPE string,  " Vendor
        loai_nhap_tra                 TYPE string,  " Loại nhập trả
        lenh_gia_cong                 TYPE string,  " Lệnh gia công
        material_document_item_text   TYPE string,  " Material Document Item Text
        ewm_warehouse                 TYPE string,  " EWM Warehouse
        ewm_storage_bin               TYPE string,  " EWM Storage Bin
      END OF ty_file_upload_option2,

      ty_t_file_upload_option2 TYPE STANDARD TABLE OF ty_file_upload_option2 WITH EMPTY KEY.




    TYPES: BEGIN OF ty_file_upload_1,
             document_date                 TYPE string,  " Document Date
             posting_date                  TYPE string,  " Posting Date
             material_document_header_text TYPE string,  " Material Document Header Text
             ctrlpostgforextwhsemgmtsyst   TYPE string,  " CtrlPostgForExtWhseMgmtSyst
             goods_movement_code           TYPE string,  " Goods Movement Code
             material_document             TYPE string,  " Material Document
             material_document_item        TYPE string,  " Material Document Item
             material_sequence_number      TYPE string,
             reservation                   TYPE string,  " Reservation
             reservation_item              TYPE string,  " Reservation Item
             goods_movement_type           TYPE string,  " Goods Movement Type
             from_material                 TYPE string,  " From Material
             from_plant                    TYPE string,  " From Plant
             from_storage_location         TYPE string,  " From Storage Location
             from_batch                    TYPE string,  " From Batch
             from_valuation_type           TYPE string,  " From Valuation Type
             special_stock                 TYPE string,  " Special Stock
             from_sales_order              TYPE string,  " From Sales Order
             from_sales_order_item         TYPE string,  " From Sales Order Item
             quantity_in_entry_unit        TYPE string,  " Quantity in Entry Unit
             entry_unit                    TYPE string,  " Entry Unit
             to_material                   TYPE string,  " To Material
             to_plant                      TYPE string,  " To Plant
             to_storage_location           TYPE string,  " To Storage Location
             to_batch                      TYPE string,  " To Batch
             to_valuation_type             TYPE string,  " To Valuation Type
             to_sales_order                TYPE string,  " To Sales Order
             to_sales_order_item           TYPE string,  " To Sales Order Item
             vendor                        TYPE string,  " Vendor
             loai_nhap_tra                 TYPE string,  " Loại nhập trả
             lenh_gia_cong                 TYPE string,  " Lệnh gia công
             material_document_item_text   TYPE string,  " Material Document Item Text
             ewm_warehouse                 TYPE string,  " EWM Warehouse
             ewm_storage_bin               TYPE string,  " EWM Storage Bin
           END OF ty_file_upload_1,
           ty_t_file_upload_1 TYPE STANDARD TABLE OF ty_file_upload_1 WITH EMPTY KEY.


    METHODS UploadFile FOR MODIFY
      IMPORTING keys FOR ACTION zr_tbmatnr_header~UploadFile.

    METHODS UploadFile_1 FOR MODIFY
      IMPORTING keys FOR ACTION zr_tbmatnr_header~UploadFile_1.


    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zr_tbmatnr_header RESULT result.
ENDCLASS.

CLASS lhc_zr_tbmatnr_header IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.


  METHOD downloadfile.
    DATA:
      lt_file TYPE STANDARD TABLE OF ty_file_upload WITH DEFAULT KEY,
      ls_file TYPE ty_file_upload.

    "XCOライブラリを使用したExcelファイルの書き込み
    DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
    DATA(lo_worksheet) = lo_write_access->get_workbook(
        )->worksheet->at_position( 1 ).


    DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
                               )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                               )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'AH' )
                               )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
                               )->get_pattern( ).


    "1 Đọc key từ RAP Action
    READ TABLE keys INDEX 1 INTO DATA(k).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    "ヘッダの設定（すべての項目はstring型）
    lt_file = VALUE #(
*       Header Line  ===========================================================================================================
                       (
                        document_date                 = 'Document Date'
                        posting_date                  = 'Posting Date'
                        material_document_header_text = 'Material Document Header Text'
                        ctrlpostgforextwhsemgmtsyst   = 'CtrlPostgForExtWhseMgmtSyst'
                        goods_movement_code           = 'Goods Movement Code'
                        material_sequence_number      = 'Material Sequence Number'
                        matnr_doc                     = 'Material Document'
                        matnr_doc_item                = 'Material Document Item'
                        reservation                   = 'Reservation'
                        reservation_item              = 'Reservation Item'
                        goods_movement_type           = 'Goods Movement Type'
                        material                      = 'Material'
                        plant                         = 'Plant'
                        storage_location              = 'Storage Location'
                        batch                         = 'Batch'
                        valuation_type                = 'Valuation Type'
                        quantity_in_entry_unit        = 'Quantity in Entry Unit'
                        entry_unit                    = 'Entry Unit'
                        cost_center                   = 'Cost Center'
                        fixed_asset                   = 'Fixed Asset'
                        special_stock                 = 'Special Stock'
                        sales_order                   = 'Sales Order'
                        sales_order_item              = 'Sales Order Item'
                        vender                        = 'Vendor'
                        order                         = 'Order'
                        order_item                    = 'Order Item'
                        material_document_item_text   = 'Material Document Item Text'
                        ewm_warehouse                 = 'EWM Warehouse'
                        ewm_storage_bin               = 'EWM Storage Bin'

                       )
                     ).

    lo_worksheet->select( lo_selection_pattern
)->row_stream(
)->operation->write_from( REF #( lt_file )
)->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    result = VALUE #( FOR key IN keys (
                      %cid   = key-%cid
                      %param = VALUE #( filecontent   = lv_file_content
                                        filename      = 'Tool_upload_migo_template_Nhập/Xuất_kho'
                                        fileextension = 'xlsx'
                                        mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                      ) ).

  ENDMETHOD.

  METHOD downloadfile_1.
    DATA:
      lt_file TYPE STANDARD TABLE OF ty_file_upload_1 WITH DEFAULT KEY,
      ls_file TYPE ty_file_upload.

    "XCOライブラリを使用したExcelファイルの書き込み
    DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
    DATA(lo_worksheet) = lo_write_access->get_workbook(
        )->worksheet->at_position( 1 ).


    DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
                               )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                               )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'AH' )
                               )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
                               )->get_pattern( ).



    "1 Đọc key từ RAP Action
    READ TABLE keys INDEX 1 INTO DATA(k).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    "ヘッダの設定（すべての項目はstring型）
    lt_file = VALUE #(
*       Header Line  ===========================================================================================================
                       (
                        document_date                 = 'Document Date'
                        posting_date                  = 'Posting Date'
                        material_document_header_text = 'Material Document Header Text'
                        ctrlpostgforextwhsemgmtsyst   = 'CtrlPostgForExtWhseMgmtSyst'
                        goods_movement_code           = 'Goods Movement Code'
                        material_sequence_number      = 'Material Sequence Number'
                        material_document             = 'Material Document'
                        material_document_item        = 'Material Document Item'
                        reservation                   = 'Reservation'
                        reservation_item              = 'Reservation Item'
                        goods_movement_type           = 'Goods Movement Type'
                        from_material                 = 'From Material'
                        from_plant                    = 'From Plant'
                        from_storage_location         = 'From Storage Location'
                        from_batch                    = 'From Batch'
                        from_valuation_type           = 'From Valuation Type'
                        special_stock                 = 'Special Stock'
                        from_sales_order              = 'From Sales Order'
                        from_sales_order_item         = 'From Sales Order Item'
                        quantity_in_entry_unit        = 'Quantity in Entry Unit'
                        entry_unit                    = 'Entry Unit'
                        to_material                   = 'To Material'
                        to_plant                      = 'To Plant'
                        to_storage_location           = 'To Storage Location'
                        to_batch                      = 'To Batch'
                        to_valuation_type             = 'To Valuation Type'
                        to_sales_order                = 'To Sales Order'
                        to_sales_order_item           = 'To Sales Order Item'
                        vendor                        = 'Vendor'
                        loai_nhap_tra                 = 'Loại nhập trả'
                        lenh_gia_cong                 = 'Lệnh gia công'
                        material_document_item_text   = 'Material Document Item Text'
                        ewm_warehouse                 = 'EWM Warehouse'
                        ewm_storage_bin               = 'EWM Storage Bin'

                       )
                     ).

    lo_worksheet->select( lo_selection_pattern
)->row_stream(
)->operation->write_from( REF #( lt_file )
)->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    result = VALUE #( FOR key IN keys (
                      %cid   = key-%cid
                      %param = VALUE #( filecontent   = lv_file_content
                                        filename      = 'Tool_upload_migo_template_Chuyển_kho'
                                        fileextension = 'xlsx'
                                        mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                      ) ).

  ENDMETHOD.

  METHOD uploadfile.
    DATA: lv_fail TYPE abap_boolean.

    DATA: lt_file   TYPE STANDARD TABLE OF ty_file_upload,
          lt_upload TYPE TABLE OF ztb_upload_matnr,
          ls_upload LIKE LINE OF lt_upload,
          ls_header TYPE ztb_matnr_header,
          lt_dtl    TYPE TABLE FOR CREATE zr_tbmatnr_header\_dtl,
          ls_dtl    TYPE STRUCTURE FOR CREATE zr_tbmatnr_header\_dtl.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_keys>) INDEX 1.

    CHECK sy-subrc = 0.

    DATA(lv_filecontent) = <ls_keys>-%param-filecontent.
    DATA(lv_filename)    = <ls_keys>-%param-filename. "👉 lấy tên file Excel
    DATA(lv_mimetype)  = <ls_keys>-%param-mimetype.

    "xcoライブラリを使用したexcelファイルの読み取り
    FINAL(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_filecontent )->read_access( ).
    FINAL(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

    FINAL(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    FINAL(lo_execute) = lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_file ) ).

    lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
               )->if_xco_xlsx_ra_operation~execute( ).

    READ TABLE lt_file INDEX 1 INTO DATA(ls_first_row).
    IF sy-subrc = 0.

      DATA(lv_first_col) = ls_first_row-material.

      IF lv_first_col IS INITIAL OR lv_first_col <> 'Material'.
        lv_fail = abap_true.
      ENDIF.

    ENDIF.

    IF lv_fail = abap_true.


      APPEND VALUE #(

    %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |File không đúng định dạng template!|
           )
  ) TO reported-zrtbmatnrheader.

      APPEND VALUE #(
                          %action-UploadFile = if_abap_behv=>mk-on
                        ) TO failed-zrtbmatnrheader.

      RETURN.
    ENDIF.

    IF lt_file IS NOT INITIAL.
      DELETE lt_file INDEX 1.
    ENDIF.

    "Tạo UUID cho header
    DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
    DATA(lv_hdr_cid)  = 'CID_HDR_001'.

    "Tạo HEADER
    MODIFY ENTITIES OF zr_tbmatnr_header
      IN LOCAL MODE
      ENTITY zrtbmatnrheader
        CREATE FIELDS ( Uuid FileName Attachment Mimetype )
        WITH VALUE #(
          ( %cid = lv_hdr_cid
            Uuid = lv_uuid
            FileName = lv_filename
            Attachment = lv_filecontent
            Mimetype = lv_mimetype
             )
        ).


    LOOP AT lt_file INTO DATA(ls_excel).

      CLEAR ls_upload.

      ls_upload-uuid = lv_uuid.
      ls_upload-doc_date             = ls_excel-document_date.
      ls_upload-post_date            = ls_excel-posting_date.
      ls_upload-matnr_header_text    = ls_excel-material_document_header_text.
      ls_upload-ctrl_post            = ls_excel-ctrlpostgforextwhsemgmtsyst.
      ls_upload-good_code            = ls_excel-goods_movement_code.
      ls_upload-matnr_seque_numr     = ls_excel-material_sequence_number.
      ls_upload-resevation           = ls_excel-reservation.
      ls_upload-resevation_item      = ls_excel-reservation_item.
      ls_upload-good_type            = ls_excel-goods_movement_type.
      ls_upload-matnr                = ls_excel-material.
      ls_upload-plant                = ls_excel-plant.
      ls_upload-storage_location     = ls_excel-storage_location.
      ls_upload-batch                = ls_excel-batch.
      ls_upload-valuation_type       = ls_excel-valuation_type.
      ls_upload-quantity             = ls_excel-quantity_in_entry_unit.
      ls_upload-unit                 = ls_excel-entry_unit.
      ls_upload-cost_center          = ls_excel-cost_center.
      ls_upload-fixed_asset          = ls_excel-fixed_asset.
      ls_upload-sales_order          = ls_excel-sales_order.
      ls_upload-sales_order_item     = ls_excel-sales_order_item.
      ls_upload-spe_stok             = ls_excel-special_stock.
      ls_upload-matnr_doc_item_text  = ls_excel-material_document_item_text.
      ls_upload-warehouse_number     = ls_excel-ewm_warehouse.
      ls_upload-store_bin            = ls_excel-ewm_storage_bin.
      ls_upload-vendor = ls_excel-vender.
      ls_upload-manu_order = ls_excel-order.
      ls_upload-manu_order_item = ls_excel-order_item.

*      ls_upload-form_matnr           = ls_excel-form_matnr.
*      ls_upload-form_batch           = ls_excel-form_batch.
*      ls_upload-form_plant           = ls_excel-form_plant.
*      ls_upload-form_batch           = ls_excel-form_batch.
*      ls_upload-form_sale_order = ls_excel-form_sales_order.
*      ls_upload-form_sale_item = ls_excel-form_sales_order_item.
*      ls_upload-to_sale_order = ls_excel-to_sales_order.
*      ls_upload-to_sale_item = ls_excel-to_sales_order_item.
*      ls_upload-to_matnr            = ls_excel-to_matnr.
*      ls_upload-to_batch            = ls_excel-to_batch.
*      ls_upload-to_plant             = ls_excel-to_plant.
*      ls_upload-to_sloc              = ls_excel-to_sloc.
      APPEND ls_upload TO lt_upload.
    ENDLOOP.
*
    LOOP AT lt_upload INTO DATA(ls_file).

      DATA(lv_dtlid) = cl_system_uuid=>create_uuid_x16_static( ).

      ls_dtl-Uuid = ls_file-uuid.
      ls_dtl-%target =  VALUE #(  ( %cid = 'CID_HDR_001'
                                  Uuid = lv_uuid
                                  DocDate = ls_file-doc_date
                                  PostDate = ls_file-post_date
                                  Batch = ls_file-batch
                                  MatnrHeaderText  = ls_file-matnr_header_text
                                  CtrlPost        = ls_file-ctrl_post
                                  MatnrSequeNumr = ls_file-matnr_seque_numr
                                  GoodCode        = ls_file-good_code
                                  Resevation      = ls_file-resevation
                                  ResevationItem  = ls_file-resevation_item
                                  GoodType        = ls_file-good_type
                                    Vendor = ls_file-vendor
                                    ManuOrder = ls_file-manu_order
                                    ManuOrderItem = ls_file-manu_order_item
                                  Matnr           = ls_file-matnr
                                  FormMatnr       = ls_file-form_matnr
                                  FormBatch       = ls_file-form_batch
                                  FormPlant       = ls_file-form_plant
                                  FormSloc        =  ls_file-form_sloc
                                  FormSaleOrder   = ls_file-form_sale_order
                                  FormSaleItem    = ls_file-form_sale_item
                                  ToSaleOrder     = ls_file-to_sale_order
                                  ToSaleItem      = ls_file-to_sale_item
                                  ToMatnr         = ls_file-to_matnr
                                  ToBatch         = ls_file-to_batch
                                  ToPlant         = ls_file-to_plant
                                  ToSloc          = ls_file-to_sloc
                                  Plant           = ls_file-plant
                                  StorageLocation = ls_file-storage_location
                                  ValuationType   = ls_file-valuation_type
                                  Quantity        = ls_file-quantity
                                  Unit            = ls_file-unit
                                  CostCenter      = ls_file-cost_center
                                  FixedAsset      = ls_file-fixed_asset
                                  SalesOrder      = ls_file-sales_order
                                  SalesOrderItem  = ls_file-sales_order_item
                                  SpeStok         = ls_file-spe_stok
                                  MatnrDocItemText = ls_file-matnr_doc_item_text
                                  WarehouseNumber = ls_file-warehouse_number
                                  StoreBin        = ls_file-store_bin

                                                    ) ) .
      APPEND ls_dtl TO lt_dtl.


      MODIFY ENTITIES OF zr_tbmatnr_header IN LOCAL MODE
              ENTITY zrtbmatnrheader
                CREATE BY \_dtl
                      FIELDS ( Batch Uuid DocDate PostDate MatnrHeaderText CtrlPost GoodCode
             Resevation ResevationItem GoodType Matnr Plant StorageLocation FormBatch FormMatnr FormPlant FormSloc MatnrSequeNumr
              ValuationType Quantity Unit CostCenter FixedAsset ToPlant ToSloc ToMatnr ToBatch FormSaleItem FormSaleOrder
             SalesOrder SalesOrderItem SpeStok MatnrDocItemText ToSaleOrder ToSaleItem Vendor ManuOrder ManuOrderItem
             WarehouseNumber StoreBin )
                        WITH lt_dtl
                        REPORTED DATA(update_reported1).

      CLEAR: ls_file,ls_dtl,lt_dtl.
    ENDLOOP.

  ENDMETHOD.

  METHOD uploadfile_1.
    DATA: lv_fail TYPE abap_boolean.

    DATA: lt_file   TYPE STANDARD TABLE OF ty_file_upload_option2,
          lt_upload TYPE TABLE OF ztb_upload_matnr,
          ls_upload LIKE LINE OF lt_upload,
          ls_header TYPE ztb_matnr_header,
          lt_dtl    TYPE TABLE FOR CREATE zr_tbmatnr_header\_dtl,
          ls_dtl    TYPE STRUCTURE FOR CREATE zr_tbmatnr_header\_dtl.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_keys>) INDEX 1.

    CHECK sy-subrc = 0.

    DATA(lv_filecontent) = <ls_keys>-%param-filecontent.
    DATA(lv_filename)    = <ls_keys>-%param-filename. "👉 lấy tên file Excel
    DATA(lv_mimetype)  = <ls_keys>-%param-mimetype.

    "xcoライブラリを使用したexcelファイルの読み取り
    FINAL(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_filecontent )->read_access( ).
    FINAL(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

    FINAL(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    FINAL(lo_execute) = lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_file ) ).

    lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
               )->if_xco_xlsx_ra_operation~execute( ).


    READ TABLE lt_file INDEX 1 INTO DATA(ls_first_row).
    IF sy-subrc = 0.

      DATA(lv_first_col) = ls_first_row-from_material.

      IF lv_first_col IS INITIAL OR lv_first_col <> 'From Material'.
        lv_fail = abap_true.
      ENDIF.

    ENDIF.

    IF lv_fail = abap_true.


      APPEND VALUE #(

    %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |File không đúng định dạng template!|
           )
  ) TO reported-zrtbmatnrheader.

      APPEND VALUE #(
                          %action-UploadFile_1 = if_abap_behv=>mk-on
                        ) TO failed-zrtbmatnrheader.

      RETURN.
    ENDIF.

    IF lt_file IS NOT INITIAL.
      DELETE lt_file INDEX 1.
    ENDIF.


    "Tạo UUID cho header
    DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
    DATA(lv_hdr_cid)  = 'CID_HDR_001'.

    "Tạo HEADER
    MODIFY ENTITIES OF zr_tbmatnr_header
      IN LOCAL MODE
      ENTITY zrtbmatnrheader
        CREATE FIELDS ( Uuid FileName Attachment Mimetype )
        WITH VALUE #(
          ( %cid = lv_hdr_cid
            Uuid = lv_uuid
            FileName = lv_filename
             Attachment = lv_filecontent
            Mimetype = lv_mimetype
            )
        ).


    LOOP AT lt_file INTO DATA(ls_excel).

      CLEAR ls_upload.

      ls_upload-uuid = lv_uuid.
      ls_upload-doc_date             = ls_excel-document_date.
      ls_upload-post_date            = ls_excel-posting_date.
      ls_upload-matnr_header_text    = ls_excel-material_document_header_text.
      ls_upload-ctrl_post            = ls_excel-ctrlpostgforextwhsemgmtsyst.
      ls_upload-good_code            = ls_excel-goods_movement_code.
      ls_upload-matnr_seque_numr     = ls_excel-material_sequence_number.
      ls_upload-resevation           = ls_excel-reservation.
      ls_upload-resevation_item      = ls_excel-reservation_item.
      ls_upload-good_type            = ls_excel-goods_movement_type.
*      ls_upload-matnr                = ls_excel-material.
*      ls_upload-plant                = ls_excel-plant.
*      ls_upload-storage_location     = ls_excel-storage_location.
*      ls_upload-batch                = ls_excel-batch.
*      ls_upload-valuation_type       = ls_excel-valuation_type.
      ls_upload-quantity             = ls_excel-quantity_in_entry_unit.

      IF ls_excel-entry_unit = 'PC'.
        ls_upload-unit                 = 'ST'.
      ELSE.
        ls_upload-unit                 = ls_excel-entry_unit.
      ENDIF.

*      ls_upload-cost_center          = ls_excel-cost_center.
*      ls_upload-fixed_asset          = ls_excel-fixed_asset.
*      ls_upload-sales_order          = ls_excel-sales_order.
*      ls_upload-sales_order_item     = ls_excel-sales_order_item.
      ls_upload-spe_stok             = ls_excel-special_stock.
      ls_upload-matnr_doc_item_text  = ls_excel-material_document_item_text.
      ls_upload-warehouse_number     = ls_excel-ewm_warehouse.
      ls_upload-store_bin            = ls_excel-ewm_storage_bin.
      ls_upload-form_matnr           = ls_excel-from_material.
      ls_upload-form_batch           = ls_excel-from_batch.
      ls_upload-form_plant           = ls_excel-from_plant.
      ls_upload-form_batch           = ls_excel-from_batch.
      ls_upload-form_sloc = ls_excel-from_storage_location.
      ls_upload-form_sale_order = ls_excel-from_sales_order.
      ls_upload-form_sale_item = ls_excel-from_sales_order_item.
      ls_upload-to_sale_order = ls_excel-to_sales_order.
      ls_upload-to_sale_item = ls_excel-to_sales_order_item.
      ls_upload-to_matnr            = ls_excel-to_material.
      ls_upload-to_batch            = ls_excel-to_batch.
      ls_upload-to_plant             = ls_excel-to_plant.
      ls_upload-to_sloc              = ls_excel-to_storage_location.
      APPEND ls_upload TO lt_upload.
    ENDLOOP.
*
    LOOP AT lt_upload INTO DATA(ls_file).

      DATA(lv_dtlid) = cl_system_uuid=>create_uuid_x16_static( ).

      ls_dtl-Uuid = ls_file-uuid.
      ls_dtl-%target =  VALUE #(  ( %cid = 'CID_HDR_001'
                                  Uuid = lv_uuid
                                  DocDate = ls_file-doc_date
                                  PostDate = ls_file-post_date
                                  Batch = ls_file-batch
                                  MatnrHeaderText  = ls_file-matnr_header_text
                                  MatnrSequeNumr = ls_file-matnr_seque_numr
                                  CtrlPost        = ls_file-ctrl_post
                                  GoodCode        = ls_file-good_code
                                  Resevation      = ls_file-resevation
                                  ResevationItem  = ls_file-resevation_item
                                  GoodType        = ls_file-good_type
                                  Matnr           = ls_file-matnr
                                  FormMatnr       = ls_file-form_matnr
                                  FormBatch       = ls_file-form_batch
                                  FormPlant       = ls_file-form_plant
                                  FormSloc        =  ls_file-form_sloc
                                  FormSaleOrder   = ls_file-form_sale_order
                                  FormSaleItem    = ls_file-form_sale_item
                                  ToSaleOrder     = ls_file-to_sale_order
                                  ToSaleItem      = ls_file-to_sale_item
                                  ToMatnr         = ls_file-to_matnr
                                  ToBatch         = ls_file-to_batch
                                  ToPlant         = ls_file-to_plant
                                  ToSloc          = ls_file-to_sloc
                                  Plant           = ls_file-plant
                                  StorageLocation = ls_file-storage_location
                                  ValuationType   = ls_file-valuation_type
                                  Quantity        = ls_file-quantity
                                  Unit            = ls_file-unit
                                  CostCenter      = ls_file-cost_center
                                  FixedAsset      = ls_file-fixed_asset
                                  SalesOrder      = ls_file-sales_order
                                  SalesOrderItem  = ls_file-sales_order_item
                                  SpeStok         = ls_file-spe_stok
                                  MatnrDocItemText = ls_file-matnr_doc_item_text
                                  WarehouseNumber = ls_file-warehouse_number
                                  StoreBin        = ls_file-store_bin

                                                    ) ) .
      APPEND ls_dtl TO lt_dtl.


      MODIFY ENTITIES OF zr_tbmatnr_header IN LOCAL MODE
              ENTITY zrtbmatnrheader
                CREATE BY \_dtl
                      FIELDS ( Batch Uuid DocDate PostDate MatnrHeaderText CtrlPost GoodCode MatnrSequeNumr
             Resevation ResevationItem GoodType Matnr Plant StorageLocation FormBatch FormMatnr FormPlant FormSloc
              ValuationType Quantity Unit CostCenter FixedAsset ToPlant ToSloc ToMatnr ToBatch FormSaleItem FormSaleOrder
             SalesOrder SalesOrderItem SpeStok MatnrDocItemText ToSaleOrder ToSaleItem
             WarehouseNumber StoreBin )
                        WITH lt_dtl
                        REPORTED DATA(update_reported1).

      CLEAR: ls_file,ls_dtl,lt_dtl.
    ENDLOOP.
  ENDMETHOD.

  METHOD Post.
    DATA: lt_uuid     TYPE TABLE OF string,
          lt_doc_keys TYPE tt_doc_keys,
          ls_doc_key  TYPE ty_document_key,
          lt_data     TYPE STANDARD TABLE OF ztb_upload_matnr,
          ls_data     TYPE ztb_upload_matnr,
          lv_uuid     TYPE string,
          lv_sequnr   TYPE string,
          lv_index    TYPE i.


    READ TABLE keys INDEX 1 INTO DATA(k).

*    IF k-%param-Uuid IS NOT INITIAL AND k-%param-Uuid NE 'null'.
*      SPLIT k-%param-Uuid AT ',' INTO TABLE lt_uuid.
*    ENDIF.

*     SELECT *
*      FROM ztb_upload_matnr
*      FOR ALL ENTRIES IN @lt_uuid
*      WHERE uuid in @lt_uuid
*        AND convert_sap_no = @lt_doc_keys-convertsapno
*      INTO TABLE @lt_data.

*    LOOP AT lt_uuid INTO DATA(ls_uuid).

*      REPLACE ALL OCCURRENCES OF '-' IN ls_uuid WITH ''.
*      TRANSLATE ls_uuid TO UPPER CASE.

    DATA(ls_uuid) = k-Uuid.
*
**      REPLACE ALL OCCURRENCES OF '-' IN k-Uuid WITH ''.
**      TRANSLATE k-Uuid TO UPPER CASE.
*
    ls_doc_key-uuid = ls_uuid.
    APPEND ls_doc_key TO lt_doc_keys.
    CLEAR: ls_uuid.

*    ENDLOOP.

    "resual
    TYPES: BEGIN OF ty_serial_number,
             Material                 TYPE matnr,
             SerialNumber             TYPE sernr,
             MaterialDocument         TYPE mblnr,
             MaterialDocumentItem     TYPE string,
             MaterialDocumentYear     TYPE mjahr,
             ManufacturerSerialNumber TYPE string,
             SerialNumberIsRecursive  TYPE char1,
           END OF ty_serial_number.

    TYPES: tt_serial_number TYPE STANDARD TABLE OF ty_serial_number WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_serial_wrapper,
             results TYPE tt_serial_number,
           END OF ty_serial_wrapper.

    "item
    TYPES: BEGIN OF ty_matdoc_item,
             MaterialDocumentYear           TYPE mjahr,
             MaterialDocument               TYPE mblnr,
             MaterialDocumentItem           TYPE string,
             Material                       TYPE matnr,
             Plant                          TYPE werks_d,
             StorageLocation                TYPE lgort_d,
             Batch                          TYPE charg_d,
             BatchBySupplier                TYPE string,
             GoodsMovementType              TYPE bwart,
             InventoryStockType             TYPE char1,
             InventoryValuationType         TYPE string,
             InventorySpecialStockType      TYPE char1,
             Supplier                       TYPE lifnr,
             Customer                       TYPE kunnr,
             SalesOrder                     TYPE vbeln_va,
             SalesOrderItem                 TYPE posnr_va,
             SalesOrderScheduleLine         TYPE char6,
             PurchaseOrder                  TYPE ebeln,
             PurchaseOrderItem              TYPE ebelp,
             WBSElement                     TYPE string,
             ManufacturingOrder             TYPE aufnr,
             ManufacturingOrderItem         TYPE string,
             GoodsMovementRefDocType        TYPE char3,
             GoodsMovementReasonCode        TYPE char4,
             Delivery                       TYPE vbeln_vl,
             DeliveryItem                   TYPE posnr_vl,
             AccountAssignmentCategory      TYPE knttp,
             CostCenter                     TYPE kostl,
             ControllingArea                TYPE kokrs,
             CostObject                     TYPE aufnr,
             GLAccount                      TYPE hkont,
             FunctionalArea                 TYPE fkber,
             ProfitabilitySegment           TYPE string,
             ProfitCenter                   TYPE prctr,
             MasterFixedAsset               TYPE anln1,
             FixedAsset                     TYPE anln2,
             MaterialBaseUnitISOCode        TYPE string,
             MaterialBaseUnitSAPCode        TYPE msehi,
             MaterialBaseUnit               TYPE meins,
             QuantityInBaseUnit             TYPE string,
             EntryUnitISOCode               TYPE string,
             EntryUnitSAPCode               TYPE msehi,
             EntryUnit                      TYPE meins,
             QuantityInEntryUnit            TYPE string,
             CompanyCodeCurrency            TYPE waers,
             GdsMvtExtAmtInCoCodeCrcy       TYPE string,
             SlsPrcAmtInclVATInCoCodeCrcy   TYPE string,
             FiscalYear                     TYPE gjahr,
             FiscalYearPeriod               TYPE monat,
             FiscalYearVariant              TYPE periv,
             IssgOrRcvgMaterial             TYPE matnr,
             IssgOrRcvgBatch                TYPE charg_d,
             IssuingOrReceivingPlant        TYPE werks_d,
             IssuingOrReceivingStorageLoc   TYPE lgort_d,
             IssuingOrReceivingStockType    TYPE char1,
             IssgOrRcvgSpclStockInd         TYPE char1,
             IssuingOrReceivingValType      TYPE string,
             MaterialDocumentItemText       TYPE sgtxt,
             GoodsRecipientName             TYPE string,
             UnloadingPointName             TYPE string,
             Reservation                    TYPE rsnum,
             ReservationItem                TYPE rspos,
             ReservationItemRecordType      TYPE char1,
             SpecialStockIdfgSalesOrder     TYPE vbeln_va,
             SpecialStockIdfgSalesOrderItem TYPE string,
             SpecialStockIdfgWBSElement     TYPE string,
             IsAutomaticallyCreated         TYPE abap_bool,
             MaterialDocumentLine           TYPE char6,
             MaterialDocumentParentLine     TYPE char6,
             HierarchyNodeLevel             TYPE char2,
             ReversedMaterialDocumentYear   TYPE mjahr,
             ReversedMaterialDocument       TYPE mblnr,
             ReversedMaterialDocumentItem   TYPE string,
             ReferenceDocumentFiscalYear    TYPE gjahr,
             InvtryMgmtRefDocumentItem      TYPE char6,
             InvtryMgmtReferenceDocument    TYPE char20,
             MaterialDocumentPostingType    TYPE char1,
             InventoryUsabilityCode         TYPE char1,
             EWMWarehouse                   TYPE string,
             EWMStorageBin                  TYPE string,
             DebitCreditCode                TYPE shkzg,
             to_MaterialDocumentHeader      TYPE REF TO data, " null
             to_SerialNumbers               TYPE ty_serial_wrapper,
           END OF ty_matdoc_item.

    TYPES: tt_matdoc_item TYPE STANDARD TABLE OF ty_matdoc_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_item_wrapper,
             results TYPE tt_matdoc_item,
           END OF ty_item_wrapper.


    TYPES: BEGIN OF ty_matdoc_payload,
             MaterialDocumentYear        TYPE mjahr,
             MaterialDocument            TYPE mblnr,
             InventoryTransactionType    TYPE char4,
             DocumentDate                TYPE string,
             PostingDate                 TYPE string,
             CreatedByUser               TYPE syuname,
             MaterialDocumentHeaderText  TYPE bktxt,
             ReferenceDocument           TYPE char20,
             VersionForPrintingSlip      TYPE char2,
             ManualPrintIsTriggered      TYPE char1,
             CtrlPostgForExtWhseMgmtSyst TYPE char1,
             GoodsMovementCode           TYPE bwart,
             to_MaterialDocumentItem     TYPE ty_item_wrapper,
           END OF ty_matdoc_payload.


    DATA: ls_payload          TYPE ty_matdoc_payload,
          ls_item             TYPE ty_matdoc_item,
          lw_date             TYPE zde_Date,
          lw_json_body        TYPE string,
          lt_json_bodies      TYPE TABLE OF string,
          lv_matnr_seque_numr TYPE string,
          lt_group            TYPE TABLE OF ztb_upload_matnr.
*          lv_final_json TYPE string.

    SELECT *
     FROM ztb_upload_matnr
     FOR ALL ENTRIES IN @lt_doc_keys
       WHERE uuid = @lt_doc_keys-uuid
     INTO TABLE @lt_data.

    READ TABLE lt_doc_keys INTO ls_doc_key INDEX 1.
    lv_uuid = ls_doc_key-uuid.
    CLEAR lt_doc_keys.

    LOOP AT lt_data INTO ls_data.
      CLEAR ls_doc_key.

      IF  ls_data-form_matnr IS NOT INITIAL.
        ls_doc_key-option = 'X'.
      ENDIF.

      ls_doc_key-uuid              = lv_uuid.
      ls_doc_key-dtlid = ls_data-dtlid.
      ls_doc_key-matnr_seque_numr = ls_data-matnr_seque_numr.
      APPEND ls_doc_key TO lt_doc_keys.
    ENDLOOP.

    SORT lt_data BY matnr_seque_numr.
    CLEAR: lv_matnr_seque_numr.
    LOOP AT lt_data INTO ls_data GROUP BY ls_data-matnr_seque_numr INTO DATA(ls_group).

      lv_matnr_seque_numr = ls_group.

*       ls_doc_key-matnr_seque_numr = ls_data-matnr_seque_numr.
*      APPEND ls_doc_key TO lt_doc_keys.

      READ TABLE lt_data INTO ls_data WITH KEY matnr_seque_numr = ls_group.
      lw_date = xco_cp=>sy->moment( xco_cp_time=>time_zone->user )->date->as( xco_cp_time=>format->abap )->value.

*      CLEAR ls_payload.
      " Header
      ls_payload = VALUE #(
        MaterialDocumentYear        = ''
        MaterialDocument            = ''
        InventoryTransactionType    = ''
        DocumentDate                = zcl_utility=>to_json_date( iv_date = ls_data-doc_date )
        PostingDate                 = zcl_utility=>to_json_date( iv_date = ls_data-post_date )
        CreatedByUser               = ''
        MaterialDocumentHeaderText  = ls_data-matnr_header_text
        ReferenceDocument           = ''
        VersionForPrintingSlip      = ''
        ManualPrintIsTriggered      = ''
        CtrlPostgForExtWhseMgmtSyst = ls_data-ctrl_post
        GoodsMovementCode           = ls_data-good_code
      ).


      DATA:lv_valuation           TYPE string,
           lv_matnr               TYPE string,
           lv_plant               TYPE string,
           lv_batch               TYPE string,
           lv_sloc                TYPE string,
           lv_sale_order          TYPE string,
           lv_sale_order_item     TYPE string,
           lv_spe_stok_order      TYPE string,
           ls_unit                TYPE meins,
           lv_spe_stok_order_item TYPE string.

      " Item
      LOOP AT GROUP ls_group INTO DATA(ls_item_row).

        SELECT SINGLE  InventoryValuationType, batch,Material
      FROM i_batch
      WHERE batch = @ls_item_row-batch
      AND Material = @ls_item_row-matnr
      INTO @DATA(ls_valuation).

        IF ls_item_row-batch IS INITIAL .
          lv_valuation = 'ND'.
        ELSE.
          lv_valuation = ls_valuation.
        ENDIF.


        IF ls_item_row-unit = 'ST'.
          ls_unit = 'PC'.
        ELSE.
          ls_unit = ls_item_row-unit.
        ENDIF.

        IF ls_item_row-form_matnr IS NOT INITIAL.
          lv_matnr = ls_item_row-form_matnr.
        ENDIF.

        IF ls_item_row-form_plant IS NOT INITIAL.
          lv_plant = ls_item_row-form_plant.
        ENDIF.

        IF ls_item_row-form_batch IS NOT INITIAL.
          lv_batch = ls_item_row-form_batch.
        ENDIF.

        IF ls_item_row-form_sloc IS NOT INITIAL.
          lv_sloc = ls_item_row-form_sloc.
        ENDIF.

        IF lv_matnr IS INITIAL AND ls_item_row-matnr IS NOT INITIAL.
          lv_matnr = ls_item_row-matnr.
          lv_plant     = ls_item_row-plant.
          lv_batch    = ls_item_row-batch.
          lv_sloc     = ls_item_row-storage_location.
        ENDIF.


*        IF ls_item_row-sales_order IS NOT INITIAL AND .
*          lv_sale_order = ls_item_row-sales_order.
*          lv_sale_order_item = ls_item_row-sales_order_item.
*        ENDIF.

        IF ls_item_row-spe_stok = 'E' AND ls_item_row-good_type = '413'.
          lv_spe_stok_order = ls_item_row-form_sale_order.
          lv_spe_stok_order_item = ls_item_row-form_sale_item.
          lv_sale_order = ls_item_row-to_sale_order.
          lv_sale_order_item = ls_item_row-to_sale_item.
        ELSEIF ls_item_row-to_sale_order IS NOT INITIAL AND ls_item_row-to_sale_item IS NOT INITIAL .
          lv_spe_stok_order = ls_item_row-to_sale_order.
          lv_spe_stok_order_item = ls_item_row-to_sale_item.
        ELSE.
          lv_spe_stok_order = ls_item_row-sales_order.
          lv_spe_stok_order_item  = ls_item_row-sales_order_item.
        ENDIF.

*      CLEAR ls_item.
        ls_item = VALUE ty_matdoc_item(
          Material                       = lv_matnr
          Plant                          = lv_plant
          StorageLocation                = lv_sloc
          Batch                          =  lv_batch
          GoodsMovementType              = ls_item_row-good_type
          InventoryValuationType         = ls_item_row-valuation_type
          InventorySpecialStockType      = ls_item_row-spe_stok
          SalesOrder                     = lv_sale_order
          SalesOrderItem                 =  lv_sale_order_item
          IssgOrRcvgMaterial             = ls_item_row-to_matnr
          IssgOrRcvgBatch                = ls_item_row-to_batch
          IssuingOrReceivingPlant        = ls_item_row-to_plant
          IssuingOrReceivingStorageLoc   = ls_item_row-to_sloc
          EntryUnit                      = ls_unit
          Supplier                       = ls_item_row-vendor
          ManufacturingOrder             = ls_item_row-manu_order
          manufacturingorderitem         = ls_item_row-manu_order_item
          QuantityInEntryUnit            =  ls_item_row-quantity
          Reservation                    = ls_item_row-resevation
          ReservationItem                = ls_item_row-resevation_item
          GdsMvtExtAmtInCoCodeCrcy       = ''
          CostCenter                     = ls_item_row-cost_center
          FixedAsset                     = ls_item_row-fixed_asset
          EWMWarehouse                   = ls_item_row-warehouse_number
          EWMStorageBin                  = ls_item_row-store_bin
          MaterialDocumentItemText       = ls_item_row-matnr_doc_item_text
          SpecialStockIdfgSalesOrder     = lv_spe_stok_order
          SpecialStockIdfgSalesOrderItem = lv_spe_stok_order_item
          QuantityInBaseUnit             = '0'
        ).
        CONDENSE: ls_item-QuantityInEntryUnit NO-GAPS.
        " Serial Numbers

        APPEND VALUE ty_serial_number(
          Material                     = ''
          SerialNumber                 = ''
          MaterialDocument             = ''
          MaterialDocumentItem         = ''
          MaterialDocumentYear         = ''
          ManufacturerSerialNumber     = ''
          SerialNumberIsRecursive      = ''
        ) TO ls_item-to_SerialNumbers-results.


*        APPEND VALUE ty_serial_number( ) TO ls_item-to_SerialNumbers-results.
        APPEND ls_item TO ls_payload-to_MaterialDocumentItem-results.
        CLEAR: ls_item ,ls_unit,lv_matnr,lv_sloc,lv_batch,lv_plant,ls_item_row,lv_spe_stok_order,lv_spe_stok_order_item, lv_sale_order_item,lv_spe_stok_order.

      ENDLOOP.

      "JSON
      lw_json_body = /ui2/cl_json=>serialize(
                        data        = ls_payload
                        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                        compress    = abap_true ).

*      APPEND lv_json_body TO lt_json_bodies.
*    ENDLOOP.
*      LOOP AT lt_json_bodies INTO lw_json_body.

      REPLACE ALL OCCURRENCES OF 'materialdocumentyear'           IN lw_json_body WITH 'MaterialDocumentYear'.
      REPLACE ALL OCCURRENCES OF 'materialdocument'               IN lw_json_body WITH 'MaterialDocument'.
      REPLACE ALL OCCURRENCES OF 'inventorytransactiontype'       IN lw_json_body WITH 'InventoryTransactionType'.
      REPLACE ALL OCCURRENCES OF 'documentdate'                   IN lw_json_body WITH 'DocumentDate'.
      REPLACE ALL OCCURRENCES OF 'postingdate'                    IN lw_json_body WITH 'PostingDate'.
      REPLACE ALL OCCURRENCES OF 'createdbyuser'                  IN lw_json_body WITH 'CreatedByUser'.
      REPLACE ALL OCCURRENCES OF 'MaterialDocumentheadertext'     IN lw_json_body WITH 'MaterialDocumentHeaderText'.
      REPLACE ALL OCCURRENCES OF 'referencedocument'              IN lw_json_body WITH 'ReferenceDocument'.
      REPLACE ALL OCCURRENCES OF 'versionforprintingslip'         IN lw_json_body WITH 'VersionForPrintingSlip'.
      REPLACE ALL OCCURRENCES OF 'manualprintistriggered'         IN lw_json_body WITH 'ManualPrintIsTriggered'.
      REPLACE ALL OCCURRENCES OF 'ctrlpostgforextwhsemgmtsyst'    IN lw_json_body WITH 'CtrlPostgForExtWhseMgmtSyst'.
      REPLACE ALL OCCURRENCES OF 'goodsmovementcode'              IN lw_json_body WITH 'GoodsMovementCode'.
      REPLACE ALL OCCURRENCES OF 'toMaterialdocumentitem'        IN lw_json_body WITH 'to_MaterialDocumentItem'.
      REPLACE ALL OCCURRENCES OF 'material'                       IN lw_json_body WITH 'Material'.
      REPLACE ALL OCCURRENCES OF 'plant'                          IN lw_json_body WITH 'Plant'.
      REPLACE ALL OCCURRENCES OF 'storagelocation'                IN lw_json_body WITH 'StorageLocation'.
      REPLACE ALL OCCURRENCES OF 'batch'                          IN lw_json_body WITH 'Batch'.
      REPLACE ALL OCCURRENCES OF 'batchbysupplier'                IN lw_json_body WITH 'BatchBySupplier'.
      REPLACE ALL OCCURRENCES OF 'goodsmovementtype'              IN lw_json_body WITH 'GoodsMovementType'.
      REPLACE ALL OCCURRENCES OF 'inventorystocktype'             IN lw_json_body WITH 'InventoryStockType'.
      REPLACE ALL OCCURRENCES OF 'inventoryvaluationtype'         IN lw_json_body WITH 'InventoryValuationType'.
      REPLACE ALL OCCURRENCES OF 'inventoryspecialstocktype'      IN lw_json_body WITH 'InventorySpecialStockType'.
      REPLACE ALL OCCURRENCES OF 'supplier'                       IN lw_json_body WITH 'Supplier'.
      REPLACE ALL OCCURRENCES OF 'customer'                       IN lw_json_body WITH 'Customer'.
      REPLACE ALL OCCURRENCES OF 'salesorder'                     IN lw_json_body WITH 'SalesOrder'.
      REPLACE ALL OCCURRENCES OF 'SalesOrderitem'                 IN lw_json_body WITH 'SalesOrderItem'.
      REPLACE ALL OCCURRENCES OF 'specialstockidfgSalesOrder'     IN lw_json_body WITH 'SpecialStockIdfgSalesOrder'.
      REPLACE ALL OCCURRENCES OF 'SpecialStockIdfgSalesOrderitem' IN lw_json_body WITH 'SpecialStockIdfgSalesOrderItem'.
      REPLACE ALL OCCURRENCES OF 'costcenter'                     IN lw_json_body WITH 'CostCenter'.
      REPLACE ALL OCCURRENCES OF 'fixedasset'                     IN lw_json_body WITH ' FixedAsset  '.
      REPLACE ALL OCCURRENCES OF 'entryunit'                      IN lw_json_body WITH 'EntryUnit'.
      REPLACE ALL OCCURRENCES OF 'quantityinEntryUnit'            IN lw_json_body WITH 'QuantityInEntryUnit'.
      REPLACE ALL OCCURRENCES OF 'quantityinbaseunit'             IN lw_json_body WITH 'QuantityInBaseUnit'.
      REPLACE ALL OCCURRENCES OF 'gdsmvtextamtincocodecrcy'       IN lw_json_body WITH 'GdsMvtExtAmtInCoCodeCrcy'.
      REPLACE ALL OCCURRENCES OF 'ewmwarehouse'                   IN lw_json_body WITH 'EWMWarehouse'.
      REPLACE ALL OCCURRENCES OF 'ewmstoragebin'                  IN lw_json_body WITH 'EWMStorageBin'.
      REPLACE ALL OCCURRENCES OF 'MaterialDocumentitemtext'       IN lw_json_body WITH 'MaterialDocumentItemText'.
      REPLACE ALL OCCURRENCES OF 'tomaterialdocumentheader'      IN lw_json_body WITH 'to_MaterialDocumentHeader'.
      REPLACE ALL OCCURRENCES OF 'toSerialnumbers'               IN lw_json_body WITH 'to_SerialNumbers'.
      REPLACE ALL OCCURRENCES OF 'manufacturerserialnumber'       IN lw_json_body WITH 'ManufacturerSerialNumber'.
      REPLACE ALL OCCURRENCES OF 'serialnumberisrecursive'        IN lw_json_body WITH 'SerialNumberIsRecursive'.
      REPLACE ALL OCCURRENCES OF 'fiscalyear'                     IN lw_json_body WITH 'FiscalYear'.
      REPLACE ALL OCCURRENCES OF 'fiscalyearperiod'               IN lw_json_body WITH 'FiscalYearPeriod'.
      REPLACE ALL OCCURRENCES OF 'fiscalyearvariant'              IN lw_json_body WITH 'FiscalYearVariant'.
      REPLACE ALL OCCURRENCES OF 'issgorrcvgMaterial'              IN lw_json_body WITH 'IssgOrRcvgMaterial'.
      REPLACE ALL OCCURRENCES OF 'issgorrcvgBatch'              IN lw_json_body WITH 'IssgOrRcvgBatch'.
      REPLACE ALL OCCURRENCES OF 'issuingorreceivingPlant'              IN lw_json_body WITH 'IssuingOrReceivingPlant'.
      REPLACE ALL OCCURRENCES OF 'issuingorreceivingstorageloc'              IN lw_json_body WITH 'IssuingOrReceivingStorageLoc'.
      REPLACE ALL OCCURRENCES OF 'manufacturingorder'              IN lw_json_body WITH 'ManufacturingOrder'.
      REPLACE ALL OCCURRENCES OF 'manufacturingorderitem'              IN lw_json_body WITH 'ManufacturingOrderItem'.


      DATA: lw_username TYPE string,
            lw_password TYPE string,
            lv_url      TYPE string,
            e_code      TYPE i,
            lv_response TYPE string,
            e_response  TYPE string.

      SELECT SINGLE * FROM ztb_api_auth
    WHERE systemid = 'CASLA'
  INTO @DATA(ls_api_auth).

      lw_username = ls_api_auth-api_user.
      lw_password = ls_api_auth-api_password.

      lv_url = |https://{ ls_api_auth-api_url }/sap/opu/odata/sap/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader|.

      TRY.

          DATA(lo_http_destination) =
               cl_http_destination_provider=>create_by_url( lv_url ).

          DATA(lo_web_http_client) =
               cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
          DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
          lo_web_http_request->set_header_fields( VALUE #(
             ( name = 'DataServiceVersion' value = '2.0' )
             ( name = 'Accept' value = 'application/json' )
          ) ).

          "Authorization
          lo_web_http_request->set_header_field(  i_name = 'username' i_value = 'PB9_LO' ).
          lo_web_http_request->set_header_field(  i_name = 'password' i_value = 'Qwertyuiop@1234567890' ).

          lo_web_http_request->set_authorization_basic( i_username = lw_username i_password = lw_password ).
          lo_web_http_request->set_content_type( |application/json| ).
          lo_web_http_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
          lo_web_http_request->set_header_field( i_name = 'x-csrf-token' i_value = 'Fetch' ).

          DATA(lo_response) = lo_web_http_client->execute( i_method = if_web_http_client=>get ).
          DATA(lv_token)    = lo_response->get_header_field( 'x-csrf-token' ).
          DATA(lv_Match)    = lo_response->get_header_field( 'etag' ).
          lo_web_http_request->set_header_field( i_name = 'x-csrf-token' i_value = lv_token ).


          lo_web_http_request->set_text( lw_json_body ).

          DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>post ).
          lv_response = lo_web_http_response->get_text( ).

          /ui2/cl_json=>deserialize(
            EXPORTING json = lv_response
            CHANGING  data = e_response ).
          DATA(lv_status) = lo_web_http_response->get_status( ).
          DATA(lv_body)   = lo_web_http_response->get_text( ).
          e_code = lv_status-code.

        CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.

      ENDTRY.
      DATA:lv_matdoc TYPE string.

      "status 201
      IF lv_status-code = '201'.
        FIND REGEX '"MaterialDocument":"([^"]+)"' IN lv_body
             SUBMATCHES lv_matdoc.
        IF lv_matdoc IS NOT INITIAL.
          APPEND VALUE #(
             %tky = k-%tky
             %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-success
                       text     = |Tạo thành công chứng từ { lv_matdoc }.|
                     )
           ) TO reported-zrtbmatnrheader.


          LOOP AT lt_doc_keys ASSIGNING FIELD-SYMBOL(<ls_key>) WHERE matnr_seque_numr = ls_group.

            <ls_key>-matdoc = lv_matdoc.

          ENDLOOP.
        ENDIF.


        " lỗi
      ELSE.

        DATA: lt_errmsgs TYPE STANDARD TABLE OF string,
              lv_msg     TYPE string,
              lv_json    TYPE string.

        lv_json = lv_response.

        DATA(match) = VALUE match_result( ).

        WHILE lv_json CS '"message"'.

          FIND FIRST OCCURRENCE OF REGEX '"message"\s*:\s*"([^"]+)"'
               IN lv_json
               RESULTS match.

          IF match-submatches IS NOT INITIAL.

            " Lấy vị trí submatch
            DATA(sub) = match-submatches[ 1 ].

            " Cắt chuỗi ra thành message
            lv_msg = substring(
                       val = lv_json
                       off = sub-offset
                       len = sub-length ).

            APPEND lv_msg TO lt_errmsgs.

            " Tiếp tục parse phần còn lại
            lv_json = substring(
                        val = lv_json
                        off = match-offset + match-length ).

          ELSE.
            EXIT.
          ENDIF.

        ENDWHILE.

        LOOP AT lt_errmsgs INTO lv_msg.

          DATA:lv_all_err TYPE string.
          lv_all_err = concat_lines_of( table = lt_errmsgs sep = ` , ` ).

        ENDLOOP.

        lv_uuid = k-Uuid.
        MODIFY ENTITIES OF zr_tbmatnr_header IN LOCAL MODE
  ENTITY zrtbmatnrheader
   UPDATE
     FIELDS ( Message )
     WITH VALUE #(
       ( Uuid = lv_uuid
         Message = lv_all_err )
     )
   REPORTED DATA(update_reported_1).

*        DATA:lv_errmsg TYPE string.
*        FIND REGEX '"message":\{"lang":"[^"]*","value":"([^"]+)"' IN lv_body
*             SUBMATCHES lv_errmsg.
*        IF lv_errmsg IS INITIAL.
*          lv_errmsg = lv_body.
*        ENDIF.
*        APPEND VALUE #(
*              %tky = k-%tky
*              %msg = new_message_with_text(
*                        severity = if_abap_behv_message=>severity-error
*                        text     = |Lỗi { lv_response }.|
*                      )
*            ) TO reported-zrtbmatnrheader.
      ENDIF.
    ENDLOOP.
*    ENDLOOP.

    IF lv_matdoc IS NOT INITIAL.
      DATA(lv_item_no) = 0.
      DATA: lv_dtlid TYPE string.
      SORT lt_doc_keys BY matdoc matnr_seque_numr.

      LOOP AT lt_doc_keys INTO DATA(ls_file).

        IF ls_file-option IS NOT INITIAL.
          AT NEW matdoc.
            lv_item_no = 1.
          ENDAT.

          lv_uuid   = ls_file-uuid.
          lv_dtlid = ls_file-dtlid.
          lv_sequnr = ls_file-matnr_seque_numr.

          " Update MatnrDoc và MatnrItem
          MODIFY ENTITIES OF zr_tbmatnr_header IN LOCAL MODE
            ENTITY Zrtbuploadmatnr
              UPDATE
                FIELDS ( MatnrDoc MatnrItem )
                WITH VALUE #(
                  ( Uuid          = lv_uuid
                   Dtlid = lv_dtlid
                    MatnrDoc      = ls_file-matdoc
                    MatnrItem     = lv_item_no )
                )
          REPORTED DATA(update_reported).

          lv_item_no = lv_item_no + 2.

        ELSE.


          AT NEW matdoc.
            lv_item_no = 1.
          ENDAT.

          lv_uuid   = ls_file-uuid.
          lv_dtlid = ls_file-dtlid.
          lv_sequnr = ls_file-matnr_seque_numr.

          " Update MatnrDoc và MatnrItem
          MODIFY ENTITIES OF zr_tbmatnr_header IN LOCAL MODE
            ENTITY Zrtbuploadmatnr
              UPDATE
                FIELDS ( MatnrDoc MatnrItem )
                WITH VALUE #(
                  ( Uuid          = lv_uuid
                   Dtlid = lv_dtlid
                    MatnrDoc      = ls_file-matdoc
                    MatnrItem     = lv_item_no )
                )
          REPORTED DATA(update_reported_2).

          lv_item_no = lv_item_no + 1.
        ENDIF.



      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

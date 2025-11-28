CLASS lhc_zr_tbupload_bomhd DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrTbuploadBomhd
        RESULT result.

    METHODS DownloadFile FOR MODIFY
      IMPORTING keys FOR ACTION zr_tbupload_bomhd~DownloadFile RESULT result.


    TYPES: BEGIN OF ty_document_key,
             matnr_seque_numr TYPE string,
             matdoc           TYPE string,
             dtlid            TYPE string,
             option           TYPE string,
             Uuid             TYPE sysuuid_x16,
           END OF ty_document_key.

    TYPES: tt_doc_keys TYPE STANDARD TABLE OF ty_document_key WITH EMPTY KEY.

    METHODS Post FOR MODIFY
      IMPORTING keys FOR ACTION zr_tbupload_bomhd~Post.

    TYPES:
      BEGIN OF ty_file_upload,
        sales_order             TYPE string,
        sales_order_item        TYPE string,
        material                TYPE string,
        plant                   TYPE string,
        bom_usage               TYPE string,
        material_variant        TYPE string,
        material_status         TYPE string,
        header_quan             TYPE string,
        header_unit             TYPE string,
        header_category         TYPE string,
        date                    TYPE string,
        bom_item_number         TYPE string,
        item_category           TYPE string,
        bom_component           TYPE string,
        quantity                TYPE string,
        unit                    TYPE string,
        indicator_net_scrap     TYPE string,
        component_scrap_percent TYPE string,
        indicator_costing       TYPE string,
        special                 TYPE string,
        location                TYPE string,
        alt_group               TYPE string,
        priority                TYPE string,
        alt_strategy            TYPE string,
        altprobability          TYPE string,
      END OF ty_file_upload,

      ty_t_file_upload TYPE STANDARD TABLE OF ty_file_upload WITH EMPTY KEY.

    METHODS UploadFile FOR MODIFY
      IMPORTING keys FOR ACTION zr_tbupload_bomhd~UploadFile.
ENDCLASS.

CLASS lhc_zr_tbupload_bomhd IMPLEMENTATION.
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
                        sales_order             = 'Sales Order'
                        sales_order_item        = 'Sales Order Item'
                        material                = 'Material'
                        plant                   = 'Plant'
                        bom_usage               = 'BillOfMaterialVariantUsage'
                        material_variant        = 'BillOfMaterialVariant'
                        material_status         = 'BillOfMaterialStatus'
                        header_quan             = 'BOMHeaderQuantity'
                        header_unit             = 'BOMHeaderUnit'
                        header_category         = 'BillOfMaterialCategory'
                        date                    = 'ValidityStartDate'
                        bom_item_number         = 'BillOfMaterialItemNumber'
                        item_category           = 'BillOfMaterialItemCategory'
                        bom_component           = 'BillOfMaterialComponent'
                        quantity                = 'BillOfMaterialItemQuantity'
                        unit                    = 'BillOfMaterialItemUnit'
                        indicator_net_scrap     = 'IsNetScrap'
                        component_scrap_percent = 'ComponentScrapInPercent'
                        indicator_costing       = 'BOMItemIsCostingRelevant'
                        special                 = 'SpecialProcurementType'
                        location                = 'ProdOrderIssueLocation'
                        alt_group               = 'AlternativeGroup'
                        priority                = 'AlternativePriority'
                        alt_strategy            = 'AlternativeStrategy'
                        altprobability          = 'UsageProbability'

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
                                        filename      = 'Upload_BOM'
                                        fileextension = 'xlsx'
                                        mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                      ) ).


  ENDMETHOD.



  METHOD uploadfile.
    DATA: lv_fail TYPE abap_boolean.

    DATA: lt_file   TYPE STANDARD TABLE OF ty_file_upload,
          lt_upload TYPE TABLE OF ztb_upload_bomit,
          ls_upload LIKE LINE OF lt_upload,
          ls_header TYPE ztb_upload_bomhd,
          lt_dtl    TYPE TABLE FOR CREATE zr_tbupload_bomhd\_dtl,
          ls_dtl    TYPE STRUCTURE FOR CREATE zr_tbupload_bomhd\_dtl.

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


    IF lt_file IS NOT INITIAL.
      DELETE lt_file INDEX 1.
    ENDIF.

    "Tạo UUID cho header
    DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
    DATA(lv_hdr_cid)  = 'CID_HDR_001'.

    "Tạo HEADER
    MODIFY ENTITIES OF zr_tbupload_bomhd
      IN LOCAL MODE
      ENTITY ZrTbuploadBomhd
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
      ls_upload-sales_order             = ls_excel-sales_order.
      ls_upload-sales_order_item            = ls_excel-sales_order_item.
      ls_upload-matnr    = ls_excel-material.
      ls_upload-plant           = ls_excel-plant.
      ls_upload-bom_usage            = ls_excel-bom_usage.
      ls_upload-material_variant = ls_excel-material_variant.
      ls_upload-material_status = ls_excel-material_status.
      ls_upload-header_quan = ls_excel-header_quan.
      ls_upload-header_unit = ls_excel-header_unit.
      ls_upload-header_category = ls_excel-header_category.
      ls_upload-bom_item_num     = ls_excel-bom_item_number.
      ls_upload-item_category           = ls_excel-item_category.
      ls_upload-bom_component      = ls_excel-bom_component.
      ls_upload-component_quan            = ls_excel-quantity.
      ls_upload-unit     = ls_excel-unit.
      ls_upload-net_scrap                = ls_excel-indicator_net_scrap.
      ls_upload-scrap_in_percen       = ls_excel-component_scrap_percent.
      ls_upload-relevancy            = ls_excel-indicator_costing.
      ls_upload-special_procurement                 = ls_excel-special.
      ls_upload-location          = ls_excel-location.
      ls_upload-alternativeitem_group          = ls_excel-alt_group.
      ls_upload-priority          = ls_excel-priority.
      ls_upload-alternative_strategy     = ls_excel-alt_strategy.
      ls_upload-alternative_usage            = ls_excel-altprobability.

      APPEND ls_upload TO lt_upload.
    ENDLOOP.


    LOOP AT lt_upload INTO DATA(ls_file).

      DATA(lv_dtlid) = cl_system_uuid=>create_uuid_x16_static( ).

      ls_dtl-Uuid = ls_file-uuid.
      ls_dtl-%target =  VALUE #(  ( %cid = 'CID_HDR_001'
                                  Uuid = lv_uuid
                                  SalesOrder = ls_file-sales_order
                                  SalesOrderItem      = ls_file-sales_order_item
                                  Matnr               = ls_file-matnr
                                  Plant               = ls_file-plant
                                  BomUsage            = ls_file-bom_usage
                                  MaterialVariant     = ls_file-material_variant
                                  MaterialStatus      = ls_file-material_status
                                  HeaderQuan = ls_file-header_quan
                                  HeaderUnit = ls_file-header_unit
                                  HeaderCategory = ls_file-header_category
                                  BomItemNum          = ls_file-bom_item_num
                                  ItemCategory        = ls_file-item_category
                                  BomComponent        = ls_file-bom_component
                                  ComponentQuan       = ls_file-component_quan
                                  Unit                = ls_file-unit
                                  NetScrap            = ls_file-net_scrap
                                  ScrapInPercen       = ls_file-scrap_in_percen
                                  Relevancy           = ls_file-relevancy
                                  SpecialProcurement  = ls_file-special_procurement
                                  Location            = ls_file-location
                                  AlternativeitemGroup = ls_file-alternativeitem_group
                                  Priority            = ls_file-priority
                                  AlternativeStrategy = ls_file-alternative_strategy
                                  AlternativeUsage    = ls_file-alternative_usage

                                                    ) ) .
      APPEND ls_dtl TO lt_dtl.


      MODIFY ENTITIES OF zr_tbupload_bomhd IN LOCAL MODE
              ENTITY ZrTbuploadBomhd
                CREATE BY \_dtl
                      FIELDS (  Uuid
                                SalesOrder
                                SalesOrderItem
                                Matnr
                                Plant
                                BomUsage
                                 MaterialVariant
                                 MaterialStatus
                                 HeaderQuan
                                 HeaderUnit
                                 HeaderCategory
                                BomItemNum
                                ItemCategory
                                BomComponent
                                ComponentQuan
                                Unit
                                NetScrap
                                ScrapInPercen
                                Relevancy
                                SpecialProcurement
                                Location
                                AlternativeitemGroup
                                Priority
                                AlternativeStrategy
                                AlternativeUsage )
                        WITH lt_dtl
                        REPORTED DATA(update_reported1).

      CLEAR: ls_file,ls_dtl,lt_dtl.
    ENDLOOP.

  ENDMETHOD.

  METHOD post.

    DATA: lt_uuid     TYPE TABLE OF string,
          lt_doc_keys TYPE tt_doc_keys,
          ls_doc_key  TYPE ty_document_key,
          lt_data     TYPE STANDARD TABLE OF ztb_upload_bomit,
          ls_data     TYPE ztb_upload_bomit,
          lv_uuid     TYPE string,
          lv_sequnr   TYPE string,
          lv_index    TYPE i.

    TYPES: BEGIN OF ty_bom_item,
             BillOfMaterialComponent    TYPE matnr,
             BillOfMaterialItemCategory TYPE char1,    "L, N, ...
             BillOfMaterialItemNumber   TYPE char4,    "0010
             BillOfMaterialItemUnit     TYPE string,
             BillOfMaterialItemQuantity TYPE string,
             IsNetScrap                 TYPE abap_bool,
             ComponentScrapInPercent    TYPE char3,
             BOMItemIsCostingRelevant   TYPE char1,
             SpecialProcurementType     TYPE char2,
             ProdOrderIssueLocation     TYPE lgort_d,
             AlternativeItemGroup       TYPE char2,
             AlternativeItemPriority    TYPE char2,
             AlternativeItemStrategy    TYPE char2,
             UsageProbabilityPercent    TYPE char3,
           END OF ty_bom_item.

    TYPES: ty_bom_item_tab TYPE STANDARD TABLE OF ty_bom_item WITH EMPTY KEY.

    TYPES: BEGIN OF ty_matdoc_payload,
             SalesOrder                  TYPE vbeln_va,
             SalesOrderItem              TYPE string,
             Material                    TYPE mblnr,
             Plant                       TYPE lgort_d,
             BillOfMaterialVariantUsage  TYPE string,
             BillOfMaterialCategory      TYPE string,
             BillOfMaterialVariant       TYPE string,
             ValidityStartDate           TYPE string,
             BillOfMaterialStatus        TYPE string,
             BOMHeaderQuantityInBaseUnit TYPE string,
             BOMHeaderBaseUnit           TYPE string,
             to_BillOfMaterialItem       TYPE ty_bom_item_tab,
           END OF ty_matdoc_payload.

    DATA: ls_payload   TYPE ty_matdoc_payload,
          lw_json_body TYPE string,
          ls_item      TYPE ty_bom_item.


    READ TABLE keys INDEX 1 INTO DATA(k).

    DATA(ls_uuid) = k-Uuid.
    ls_doc_key-uuid = ls_uuid.
    APPEND ls_doc_key TO lt_doc_keys.
    CLEAR: ls_uuid.

    SELECT *
     FROM ztb_upload_bomit
     FOR ALL ENTRIES IN @lt_doc_keys
       WHERE uuid = @lt_doc_keys-uuid
     INTO TABLE @lt_data.

    LOOP AT lt_data INTO ls_data.


      ls_payload-SalesOrder                  = ls_data-sales_order.
      ls_payload-SalesOrderItem              = ls_data-sales_order_item.
      ls_payload-Material                    = ls_data-matnr.
      ls_payload-Plant                       = ls_data-Plant.
      ls_payload-BillOfMaterialVariantUsage  = ls_data-bom_usage.
      ls_payload-BillOfMaterialCategory      = ls_data-header_category.
      ls_payload-BillOfMaterialVariant       = ls_data-material_variant.
      ls_payload-ValidityStartDate           = '/Date(1763424000000+0000)/'.
      ls_payload-BillOfMaterialStatus        = ls_data-material_variant.
      ls_payload-BOMHeaderQuantityInBaseUnit = ls_data-header_quan.
      ls_payload-BOMHeaderBaseUnit           = ls_data-header_unit.
      CONDENSE ls_payload-BOMHeaderQuantityInBaseUnit NO-GAPS.

      ls_item-BillOfMaterialComponent      = ls_data-bom_component.
      ls_item-BillOfMaterialItemCategory   = ls_data-item_category.
      ls_item-BillOfMaterialItemNumber     = '0010'. "ls_data-bom_item_num.
      ls_item-BillOfMaterialItemUnit       = ls_data-unit.
      ls_item-BillOfMaterialItemQuantity   = ls_data-component_quan.
       CONDENSE   ls_item-BillOfMaterialItemQuantity NO-GAPS.
      ls_item-IsNetScrap                   = abap_true.
      ls_item-ComponentScrapInPercent      = ls_data-scrap_in_percen.
      ls_item-BOMItemIsCostingRelevant     = ls_data-relevancy.
      ls_item-SpecialProcurementType       = ''.
      ls_item-ProdOrderIssueLocation       = ls_data-location.
      ls_item-AlternativeItemGroup         = ls_data-alternativeitem_group.
      ls_item-AlternativeItemPriority      = ls_data-priority.
      ls_item-AlternativeItemStrategy      = ls_data-alternative_strategy.
      ls_item-UsageProbabilityPercent      = ls_data-alternative_usage.

      APPEND ls_item TO ls_payload-to_BillOfMaterialItem.
    ENDLOOP.

    "JSON
    lw_json_body = /ui2/cl_json=>serialize(
                      data        = ls_payload
                      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                      compress    = abap_true ).

    REPLACE ALL OCCURRENCES OF 'salesorder'                   IN lw_json_body WITH 'SalesOrder'.
    REPLACE ALL OCCURRENCES OF 'SalesOrderitem'               IN lw_json_body WITH 'SalesOrderItem'.
    REPLACE ALL OCCURRENCES OF 'material'                     IN lw_json_body WITH 'Material'.
    REPLACE ALL OCCURRENCES OF 'plant'                        IN lw_json_body WITH 'Plant'.
    REPLACE ALL OCCURRENCES OF 'billofMaterialvariantusage'   IN lw_json_body WITH 'BillOfMaterialVariantUsage'.
    REPLACE ALL OCCURRENCES OF 'billofMaterialcategory'       IN lw_json_body WITH 'BillOfMaterialCategory'.
    REPLACE ALL OCCURRENCES OF 'billofMaterialvariant'        IN lw_json_body WITH 'BillOfMaterialVariant'.
    REPLACE ALL OCCURRENCES OF 'validitystartdate'            IN lw_json_body WITH 'ValidityStartDate'.
    REPLACE ALL OCCURRENCES OF 'billofMaterialstatus'         IN lw_json_body WITH 'BillOfMaterialStatus'.
    REPLACE ALL OCCURRENCES OF 'bomheaderquantityinbaseunit'  IN lw_json_body WITH 'BOMHeaderQuantityInBaseUnit'.
    REPLACE ALL OCCURRENCES OF 'bomheaderbaseunit'            IN lw_json_body WITH 'BOMHeaderBaseUnit'.
    REPLACE ALL OCCURRENCES OF 'toBillofMaterialitem'         IN lw_json_body WITH 'to_BillOfMaterialItem'.

    REPLACE ALL OCCURRENCES OF 'billofMaterialcomponent'      IN lw_json_body WITH 'BillOfMaterialComponent'.
    REPLACE ALL OCCURRENCES OF 'billofMaterialitemcategory'   IN lw_json_body WITH 'BillOfMaterialItemCategory'.
    REPLACE ALL OCCURRENCES OF 'billofMaterialitemnumber'     IN lw_json_body WITH 'BillOfMaterialItemNumber'.
    REPLACE ALL OCCURRENCES OF 'billofMaterialitemunit'       IN lw_json_body WITH 'BillOfMaterialItemUnit'.
    REPLACE ALL OCCURRENCES OF 'billofMaterialitemquantity'   IN lw_json_body WITH 'BillOfMaterialItemQuantity'.
    REPLACE ALL OCCURRENCES OF 'isnetscrap'                   IN lw_json_body WITH 'IsNetScrap'.
    REPLACE ALL OCCURRENCES OF 'componentscrapinpercent'      IN lw_json_body WITH 'ComponentScrapInPercent'.
    REPLACE ALL OCCURRENCES OF 'bomitemiscostingrelevant'     IN lw_json_body WITH 'BOMItemIsCostingRelevant'.
    REPLACE ALL OCCURRENCES OF 'specialProcurementType'       IN lw_json_body WITH 'SpecialProcurementType'.
    REPLACE ALL OCCURRENCES OF 'prodorderissuelocation'       IN lw_json_body WITH 'ProdOrderIssueLocation'.
    REPLACE ALL OCCURRENCES OF 'alternativeItemGroup'         IN lw_json_body WITH 'AlternativeItemGroup'.
    REPLACE ALL OCCURRENCES OF 'alternativeItemPriority'      IN lw_json_body WITH 'AlternativeItemPriority'.
    REPLACE ALL OCCURRENCES OF 'alternativeItemStrategy'      IN lw_json_body WITH 'AlternativeItemStrategy'.
    REPLACE ALL OCCURRENCES OF 'usageProbabilityPercent'      IN lw_json_body WITH 'UsageProbabilityPercent'.


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

    lv_url = |https://{ ls_api_auth-api_url }/sap/opu/odata/sap/API_ORDER_BILL_OF_MATERIAL_SRV/SalesOrderBOM|.

    TRY.

        DATA(lo_http_destination) =
             cl_http_destination_provider=>create_by_url( lv_url ).

        DATA(lo_web_http_client) =
             cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
        DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
        lo_web_http_request->set_header_fields( VALUE #(
*           ( name = 'DataServiceVersion' value = '2.0' )
*           ( name = 'Accept' value = 'application/json' )
        ) ).

        "Authorization
        lo_web_http_request->set_header_field(  i_name = 'username' i_value = 'PB9_LO' ).
        lo_web_http_request->set_header_field(  i_name = 'password' i_value = 'Qwertyuiop@1234567890' ).

        lo_web_http_request->set_authorization_basic( i_username = lw_username i_password = lw_password ).
        lo_web_http_request->set_content_type( |application/json| ).
*        lo_web_http_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
        lo_web_http_request->set_header_field( i_name = 'x-csrf-token' i_value = 'Fetch' ).

        DATA(lo_response) = lo_web_http_client->execute( i_method = if_web_http_client=>get ).
        DATA(lv_token)    = lo_response->get_header_field( 'x-csrf-token' ).
*        DATA(lv_Match)    = lo_response->get_header_field( 'etag' ).
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


  ENDMETHOD.
ENDCLASS.

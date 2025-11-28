CLASS zcl_jp_data_bangkevat DEFINITION
  PUBLIC
*  FINAL
INHERITING FROM cx_rap_query_provider
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_jp_data_bangkevat IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    "=== KHAI BÁO BIẾN CHÍNH ===
    DATA: ls_page_info      TYPE zcl_get_filter_bangkevat=>ty_page_info,
          ir_bukrs          TYPE zcl_get_filter_bangkevat=>tt_range,
          ir_posting_date   TYPE zcl_get_filter_bangkevat=>tt_range,
          ir_invoice_date   TYPE zcl_get_filter_bangkevat=>tt_range,
          ir_docnum         TYPE zcl_get_filter_bangkevat=>tt_range,
          ir_prctr          TYPE zcl_get_filter_bangkevat=>tt_range,
          ir_fiscalyear     TYPE zcl_get_filter_bangkevat=>tt_range,
          ir_symbol         TYPE zcl_get_filter_bangkevat=>tt_range,
          ir_tax            TYPE zcl_get_filter_bangkevat=>tt_range,
          lt_data           TYPE TABLE OF zc_bangkevat,
          lw_dc_tt_flag     TYPE char2,
          lw_text1          TYPE string,
          lw_text2          TYPE string,
          lw_text3          TYPE string,
          lw_text4          TYPE string,
          lt_data_1         TYPE TABLE OF zc_bangkevat,
          lt_condition_text TYPE TABLE OF I_PurOrdPricingElementTP_2,
          ls_condition_text TYPE I_PurOrdPricingElementTP_2,
          lt_po_itemtext    TYPE TABLE OF I_PurchaseOrderItemAPI01,
          ls_po_itemtext    TYPE I_PurchaseOrderItemAPI01,
          ls_data           TYPE zc_bangkevat,
          ls_postdate       TYPE LINE OF zcl_get_filter_bangkevat=>tt_range.

    "=== USER MAPPING ===
    TYPES: BEGIN OF ty_user_map,
             userid   TYPE abp_creation_user,
             username TYPE char80,
           END OF ty_user_map.

    TYPES: BEGIN OF ty_user_tmp,
             UserID         TYPE abp_creation_user,
             PersonFullName TYPE string,
           END OF ty_user_tmp.

    DATA: lt_user_map TYPE HASHED TABLE OF ty_user_map WITH UNIQUE KEY userid,
          lt_user_ids TYPE SORTED TABLE OF abp_creation_user WITH UNIQUE KEY table_line,
          lt_user_tmp TYPE TABLE OF ty_user_tmp.



    FREE: lt_data, lt_data_1.

    TRY.
        DATA(lo_common_app) = zcl_get_filter_bangkevat=>get_instance( ).

        "  LẤY FILTER TỪ UI (CompanyCode, PostingDate, ...)
*        zcl_get_filter_bangkevat=>get_instance( )->get_fillter_app(
        lo_common_app->get_fillter_app(
          EXPORTING
            io_request   = io_request
            io_response  = io_response
          IMPORTING
            ir_bukrs         = ir_bukrs
            ir_posting_date  = ir_posting_date
            ir_invoice_date  = ir_invoice_date
            ir_docnum        = ir_docnum
            ir_prctr         = ir_prctr
            ir_fiscalyear    = ir_fiscalyear
            ir_symbol        = ir_symbol
            ir_tax           = ir_tax
            wa_page_info     = ls_page_info
        ).
        " 🔹 Lấy giá trị CompanyCode từ tham số filter (ir_bukrs)
        DATA: lv_companycode TYPE bukrs,
              lv_taxcode     TYPE char5,
              lv_symbol      TYPE char20,
              ls_bukrs       LIKE LINE OF ir_bukrs,
              ls_tax         LIKE LINE OF ir_tax,
              ls_symbol      LIKE LINE OF ir_symbol.
        SELECT * FROM
        I_TaxCodeRate
        WHERE taxcode IN @ir_tax
        INTO TABLE @DATA(lt_taxcode).
        DELETE lt_taxcode WHERE taxcode NE 'I1' AND  taxcode NE 'I2'
                               AND taxcode NE 'I3' AND taxcode NE 'I3'.
        READ TABLE ir_bukrs INTO ls_bukrs INDEX 1.
        IF sy-subrc = 0.
          lv_companycode = ls_bukrs-low.
        ENDIF.
        READ TABLE ir_tax INTO ls_tax INDEX 1.
        IF sy-subrc = 0.
          lv_taxcode = ls_tax-low.
        ENDIF.
        READ TABLE ir_symbol INTO ls_symbol INDEX 1.
        IF sy-subrc = 0.
          lv_symbol = ls_symbol-low.
        ENDIF.

        zcl_jp_common_core=>get_companycode_details(
          EXPORTING
            i_companycode = lv_companycode
          IMPORTING
            o_companycode = DATA(ls_companycode)
        ).
        "  SELECT DỮ LIỆU CHÍNH TỪ I_JOURNALENTRYITEM
        SELECT
          headers~LedgerGroup,
          headers~AccountingDocumentType AS HeaderDocType,
          headers~ReversalReferenceDocument,
          headers~OriginalReferenceDocument,
          headers~ReverseDocumentFiscalYear,
          headers~IsReversal,
          headers~IsReversed,
          headers~FiscalYear AS HeaderFiscalYear,
          headers~DocumentReferenceID,
          items~AccountingDocCreatedByUser,
          items~SourceLedger,
          items~CompanyCode,
          items~AccountingDocument,
          items~AccountingDocumentitem,
          items~FiscalYear AS ItemFiscalYear,
          items~LedgerGLLineItem,
          items~Ledger,
          items~FinancialTransactionType,
          items~FinancialAccountType,
          items~BusinessTransactionType,
          items~ReferenceDocumentType,
          items~ReferenceDocument,
          items~ProfitCenter,
          items~TransactionCurrency,
          items~AmountInTransactionCurrency,
          items~CompanyCodeCurrency,
          items~AmountInCompanyCodeCurrency,
          items~GLAccount,
          headers~PostingDate,
          headers~DocumentDate,
          headers~accountingdocumentheadertext,
          items~DocumentItemText,
          items~yy1_text2_cob,
          items~TaxCode

        FROM i_journalentryitem AS items
        INNER JOIN i_journalentry AS headers
          ON  items~CompanyCode        = headers~CompanyCode
          AND items~AccountingDocument = headers~AccountingDocument
          AND items~FiscalYear         = headers~FiscalYear
        WHERE headers~CompanyCode        IN @ir_bukrs
          AND headers~FiscalYear         IN @ir_fiscalyear
          AND headers~PostingDate        IN @ir_posting_date
          AND headers~DocumentDate       IN @ir_invoice_date
          AND headers~AccountingDocument IN @ir_docnum
          AND items~ProfitCenter         IN @ir_prctr
AND ( items~Ledger = '0L' OR items~Ledger = '' )
          AND ( headers~LedgerGroup = '0L' OR headers~LedgerGroup = '' )
          AND headers~AccountingDocumentType <> ''
          AND headers~AccountingDocumentType <> 'Z3'
          AND items~TaxCode LIKE 'I%'
          AND items~TaxCode <> 'IN'
          AND items~TaxCode IN @ir_tax
*          AND items~GLAccount LIKE '1331%'
        INTO TABLE @DATA(gt_hsl_detail).

        "  LOẠI CẶP CHỨNG TỪ ĐẢO / BỊ ĐẢO NGƯỢC THEO FS
        DATA: lt_filtered   LIKE gt_hsl_detail,
              lt_hsl_full   LIKE gt_hsl_detail,
              lt_hsl_tax    LIKE gt_hsl_detail,
              lt_hsl_tmp    LIKE gt_hsl_detail,
              lw_item       TYPE zde_item,
              lt_hsl_line   LIKE gt_hsl_detail,
              ls_doc1       LIKE LINE OF gt_hsl_detail,
              ls_doc2       LIKE LINE OF gt_hsl_detail,
              lv_key10      TYPE string,
              lv_refdoc     TYPE string,
              lv_in_range_1 TYPE abap_bool,
              lv_in_range_2 TYPE abap_bool.
        SORT gt_hsl_detail BY CompanyCode AccountingDocument TaxCode.
        lt_hsl_tmp = gt_hsl_detail.
        SORT lt_hsl_tmp BY CompanyCode AccountingDocument.
        DELETE ADJACENT DUPLICATES FROM lt_hsl_tmp COMPARING CompanyCode AccountingDocument.
        " Check huy
*        SORT gt_hsl_detail BY CompanyCode AccountingDocument." taxcode.
*        DELETE ADJACENT DUPLICATES FROM gt_hsl_detail COMPARING CompanyCode AccountingDocument." taxcode.
        lt_filtered = gt_hsl_detail.

        LOOP AT lt_hsl_tmp INTO ls_doc1 WHERE IsReversed = 'X'.


          READ TABLE lt_hsl_tmp INTO ls_doc2
               WITH KEY CompanyCode        = ls_doc1-CompanyCode
*                AccountingDocument = lv_refdoc
                        ReversalReferenceDocument = ls_doc1-OriginalReferenceDocument(10).

          IF sy-subrc = 0.
            DELETE gt_hsl_detail WHERE AccountingDocument = ls_doc1-AccountingDocument
                         OR AccountingDocument = ls_doc2-AccountingDocument.
          ENDIF.

        ENDLOOP.
        "
        lt_hsl_full = gt_hsl_detail.
        lt_hsl_tax = gt_hsl_detail.
        lt_hsl_line = gt_hsl_detail.
        " delete line khac line thue voi chung tu co thue
        DELETE lt_hsl_tax WHERE GLAccount NP '1331*'.
        DELETE lt_hsl_line WHERE GLAccount CP '1331*'.
        DELETE ADJACENT DUPLICATES FROM lt_hsl_tax COMPARING CompanyCode AccountingDocument TaxCode.
        DELETE ADJACENT DUPLICATES FROM lt_hsl_line COMPARING CompanyCode AccountingDocument TaxCode.
        CLEAR : gt_hsl_detail.
        APPEND LINES OF lt_hsl_tax TO gt_hsl_detail. " mặc định lấy line Thuế.
        LOOP AT lt_hsl_line INTO DATA(ls_line).
          READ TABLE gt_hsl_detail INTO DATA(ls_line_tax) WITH KEY CompanyCode = ls_line-CompanyCode
AccountingDocument = ls_line-AccountingDocument
                                                                taxcode = ls_line-taxcode.
          IF sy-subrc NE 0.
            APPEND ls_line TO gt_hsl_detail.
          ENDIF.
        ENDLOOP.
        SORT gt_hsl_detail BY CompanyCode AccountingDocument TaxCode.
        IF gt_hsl_detail IS NOT INITIAL.
          SELECT I_OperationalAcctgDocItem~companycode,
                 I_OperationalAcctgDocItem~AccountingDocument,
                 I_OperationalAcctgDocItem~AccountingDocumentitem,
                 I_OperationalAcctgDocItem~TaxBaseAmountInCoCodeCrcy
          FROM I_OperationalAcctgDocItem
          FOR ALL ENTRIES IN @gt_hsl_detail
          WHERE CompanyCode = @gt_hsl_detail-CompanyCode
          AND   AccountingDocument = @gt_hsl_detail-AccountingDocument
          INTO TABLE @DATA(lt_taxbase).
        ENDIF.
        SORT lt_taxbase BY companycode AccountingDocument AccountingDocumentitem.
*        SORT lt_hsl_tax BY CompanyCode AccountingDocument GLAccount.
*        DELETE ADJACENT DUPLICATES FROM lt_hsl_tax COMPARING CompanyCode AccountingDocument GLAccount.
*        LOOP AT gt_hsl_detail INTO ls_doc1.
*          READ TABLE lt_hsl_tax INTO ls_doc2 WITH KEY CompanyCode = ls_doc1-CompanyCode
*                                                      AccountingDocument = ls_doc1-AccountingDocument.
*          IF sy-subrc = 0.
*            DELETE gt_hsl_detail WHERE CompanyCode = ls_doc2-CompanyCode AND AccountingDocument = ls_doc2-AccountingDocument AND GLAccount NP '1331*'.
*          ENDIF.
*        ENDLOOP.

*        SORT gt_hsl_detail BY CompanyCode AccountingDocument." taxcode.
*        DELETE ADJACENT DUPLICATES FROM gt_hsl_detail COMPARING CompanyCode AccountingDocument." taxcode.
*        lt_filtered = gt_hsl_detail.
*
*        LOOP AT gt_hsl_detail INTO ls_doc1 WHERE IsReversed = 'X'.
*
*
*          READ TABLE lt_hsl_full INTO ls_doc2
*               WITH KEY CompanyCode        = ls_doc1-CompanyCode
**                AccountingDocument = lv_refdoc
*                        ReversalReferenceDocument = ls_doc1-OriginalReferenceDocument(10).
*
*          IF sy-subrc = 0.
*            DELETE lt_filtered WHERE AccountingDocument = ls_doc1-AccountingDocument
*                         OR AccountingDocument = ls_doc2-AccountingDocument.
*          ENDIF.
*
*        ENDLOOP.

        " Cập nhật lại danh sách
*        gt_hsl_detail = lt_filtered.

        DELETE lt_hsl_full WHERE ( FinancialAccountType = 'S' AND GLAccount CP '11*' )
                       OR ( FinancialTransactionType = 'D' )
                       OR ( FinancialTransactionType = 'K' ).


        "  LẤY THÊM DỮ LIỆU TỪ BẢNG ZUI_KB_THUE0
        SELECT
            tax~client,
            tax~uuid,
            tax~documentnumber,
            tax~companycode,
            tax~mauhd,
            tax~documentreferenceid,
            tax~postingdate,
            tax~invoicedate,
            tax~supplier,
            tax~itemtext,
            tax~doanhsovnd,
            tax~tenmavanglai,
            tax~mstmavanglai,
            tax~createdbyuser,
            tax~createddate,
            tax~changedbyuser,
            tax~changeddate,
            tax~loaitiente,
            tax~loaitienvnd
          FROM zui_kb_thue0 AS tax
          WHERE tax~companycode     IN @ir_bukrs
            AND tax~postingdate     IN @ir_posting_date
            AND tax~invoicedate     IN @ir_invoice_date
            AND tax~documentnumber  IN @ir_docnum
            AND tax~type = '1'
          INTO TABLE @DATA(gt_thue0_detail).
        IF gt_hsl_detail IS NOT INITIAL.
          SELECT FROM i_onetimeaccountsupplier AS a
           FIELDS *
              FOR ALL ENTRIES IN @gt_hsl_detail
              WHERE companycode           = @gt_hsl_detail-companycode
                AND accountingdocument    = @gt_hsl_detail-accountingdocument
                AND fiscalyear            = @gt_hsl_detail-itemfiscalyear
*                AND accountingdocumentitem = @gt_hsl_detail-LedgerGLLineItem
              INTO TABLE @DATA(lt_bsec).
          SORT lt_bsec BY companycode accountingdocument fiscalyear accountingdocumentitem.
        ENDIF.

        "=== THU THẬP USER ID CẦN MAPPING ===
        LOOP AT gt_hsl_detail INTO DATA(ls_u1).
          IF ls_u1-AccountingDocCreatedByUser IS NOT INITIAL.
            INSERT ls_u1-AccountingDocCreatedByUser INTO TABLE lt_user_ids.
          ENDIF.
        ENDLOOP.

        LOOP AT gt_thue0_detail INTO DATA(ls_u2).
          IF ls_u2-createdbyuser IS NOT INITIAL.
            INSERT ls_u2-createdbyuser INTO TABLE lt_user_ids.
          ENDIF.
        ENDLOOP.

        DELETE lt_user_ids WHERE table_line IS INITIAL.



        "=== LẤY USERNAME TỪ I_BusinessUser ===
        IF lt_user_ids IS NOT INITIAL.
          SELECT UserID, PersonFullName
            FROM I_BusinessUser
            FOR ALL ENTRIES IN @lt_user_ids
            WHERE UserID = @lt_user_ids-table_line
            INTO TABLE @lt_user_tmp.

          LOOP AT lt_user_tmp INTO DATA(ls_u3).
            INSERT VALUE ty_user_map(
              userid   = ls_u3-UserID
              username = ls_u3-PersonFullName
            ) INTO TABLE lt_user_map.
          ENDLOOP.
        ENDIF.


        "=== TH1: GHÉP DỮ LIỆU TỪ MANAGE JOURNAL ENTRIES ===
        LOOP AT gt_hsl_detail INTO DATA(ls_row).
          CLEAR ls_data.
          MOVE-CORRESPONDING ls_row TO ls_data.

          " 🔹 Gán Tax Code (I1, I2, I3, ...)
          ls_data-taxcode = ls_row-TaxCode.


          " 🔹 Lấy số chứng từ (Document Number)
          ls_data-docnum = ls_row-AccountingDocument.
          ls_data-sochungtu = ls_row-AccountingDocument.

          "=== LẤY USER CREATED BY (JOURNAL ENTRY) ===
          READ TABLE lt_user_map
               WITH TABLE KEY userid = ls_row-AccountingDocCreatedByUser
INTO DATA(ls_user1).

          IF sy-subrc = 0.
            ls_data-hachtoan_user = ls_user1-username.
          ELSE.
            ls_data-hachtoan_user = ls_row-AccountingDocCreatedByUser.
          ENDIF.

          " 🔹 Lấy thêm FinancialAccountType, OffsettingAccountType, ReferenceDocumentFiscalYear
          SELECT SINGLE
              CompanyCode,
              AccountingDocument,
              FiscalYear,
              FinancialAccountType,
              OffsettingAccountType,
              ReferenceDocument,
              Supplier,
              InvoiceReference,
              InvoiceReferenceFiscalYear
            FROM i_journalentryitem
            WHERE CompanyCode        = @ls_row-CompanyCode
              AND AccountingDocument = @ls_row-AccountingDocument
              AND FiscalYear         = @ls_row-ItemFiscalYear
*              AND LedgerGLLineItem   = @ls_row-LedgerGLLineItem
              AND FinancialAccountType = 'K'
            INTO @DATA(ls_more).
          IF sy-subrc = 0.
            " 🧩 Nếu AccountType = K thì lấy thông tin Supplier hoặc One-time Account
            IF ls_more-FinancialAccountType = 'K' AND ls_more-FinancialAccountType IS NOT INITIAL.

              " 1️⃣ Ưu tiên lấy từ One-time Account (I_ONETIMEACCOUNTSUPPLIER)
              READ TABLE lt_bsec INTO DATA(ls_bsec_match)
                WITH KEY companycode           = ls_row-companycode
                         accountingdocument    = ls_row-accountingdocument
                         fiscalyear            = ls_row-itemfiscalyear.
*                         accountingdocumentitem = ls_row-ledgergllineitem
*                BINARY SEARCH.

              IF sy-subrc = 0.
                " Có dữ liệu One-time account → Lấy Name1–4
                ls_data-tendonvi = |{ ls_bsec_match-businesspartnername1 } { ls_bsec_match-businesspartnername2 } { ls_bsec_match-businesspartnername3 } { ls_bsec_match-businesspartnername4 }|.
                ls_data-masothue = ls_bsec_match-TaxID1. " nếu bảng này có mã số thuế
              ELSE.
                " 2️⃣ Nếu không có One-time → lấy thông tin Supplier thông thường
                zcl_jp_common_core=>get_bp_info_new(
                   EXPORTING
                      i_businesspartner = ls_more-Supplier
                   IMPORTING
                      o_bp_info = DATA(ls_supplier)
                ).

                ls_data-tendonvi = ls_supplier-bpname.
                ls_data-masothue = ls_supplier-mst.
              ENDIF.
            ELSE.
              CLEAR ls_data-tendonvi.
            ENDIF.
          ENDIF.
          " Gán lại vào cấu trúc dữ liệu chính
          ls_data-financial_account_type  = ls_more-FinancialAccountType.
          ls_data-offsetting_account_type = ls_more-OffsettingAccountType.
          ls_data-refdoc_fiscal_year      = ls_more-FiscalYear.


          " 🔸 Mẫu HĐ: mặc định = 1 (theo FS)
          ls_data-mauhd = '1'.

          " 🔹 TH1: Lấy tháng từ PostingDate
          IF ls_row-postingdate IS NOT INITIAL.
            ls_data-thang = ls_row-postingdate+4(2).
          ENDIF.

          " 🔹 Lấy ký hiệu HĐ, số HĐ = phần trước, sau dấu '#' trong DocumentReferenceID
          IF ls_row-ReferenceDocument IS NOT INITIAL.
            DATA(lv_doc_ref) = ls_row-DocumentReferenceID.
            SPLIT lv_doc_ref AT '#' INTO ls_data-kyhieu_hd ls_data-sohd.
          ENDIF.

          " 🔹 Gán tên công ty, địa chỉ, khoảng thời gian
          ls_data-ten_cty    = ls_companycode-companycodename.
          ls_data-diachi_cty = ls_companycode-companycodeaddr.
          READ TABLE ir_posting_date INTO ls_postdate INDEX 1.
          IF sy-subrc = 0.
            ls_data-tungay  = ls_postdate-low.
            ls_data-denngay = ls_postdate-high.
          ENDIF.

          " 🔹 Lấy ngày chứng từ theo FS
          ls_data-ngayhd = ls_row-DocumentDate.

          " 🔹 Xác định tên hàng theo FS (TH1, TH2)
          DATA: ls_doc_line  LIKE LINE OF gt_hsl_detail,
                lt_doc_lines LIKE TABLE OF ls_doc_line,
                ls_1331      LIKE LINE OF gt_hsl_detail,
                lv_potext    TYPE string.

*lt_doc_lines = VALUE #(
*  FOR wa IN gt_hsl_full
*  WHERE ( CompanyCode = ls_row-CompanyCode
*          AND AccountingDocument = ls_row-AccountingDocument )
*  ( wa )
*).
*   READ TABLE lt_hsl_tax into ls_doc1 with KEY   CompanyCode        = ls_row-CompanyCode
*                                                 AccountingDocument = ls_row-AccountingDocument.
*    if sy-subrc = 0. " Co line thue
          "TH1: Có dòng 1331* có Item Text

          LOOP AT lt_hsl_full INTO ls_doc_line
               WHERE CompanyCode        = ls_row-CompanyCode
                 AND AccountingDocument = ls_row-AccountingDocument
                 AND GLAccount CP '1331*'
                 AND TaxCode            = ls_row-TaxCode
                 AND DocumentItemText   IS NOT INITIAL.
            ls_data-tenhang = | { ls_doc_line-DocumentItemText } { ls_doc_line-yy1_text2_cob } |.
            CONDENSE ls_data-tenhang.  "loai bo dau cach"
            EXIT.
          ENDLOOP.

          IF ls_data-tenhang IS INITIAL.
            "TH2: Không có dòng 1331*
            " Ưu tiên 1: dòng Account Type = S có cùng TaxCode và có Item Text
            LOOP AT lt_hsl_full INTO ls_doc1     WHERE CompanyCode        = ls_row-CompanyCode
                 AND AccountingDocument = ls_row-AccountingDocument
                 AND GLAccount NP '1331*'
                 AND ( FinancialAccountType = 'S' OR FinancialAccountType = 'A' OR FinancialAccountType = 'M' )
                 AND TaxCode            = ls_row-TaxCode
                 AND DocumentItemText   IS NOT INITIAL.
*              ls_data-tenhang = Ls_doc1-DocumentItemText.
              ls_data-tenhang = | { Ls_doc1-DocumentItemText } { Ls_doc1-yy1_text2_cob } |.
              CONDENSE ls_data-tenhang.  "loai bo dau cach"
              EXIT.
            ENDLOOP.


            " Ưu tiên 2: Nếu vẫn trống → check ReferenceDocumentType = RMRP
            IF ls_data-tenhang IS INITIAL AND ls_row-ReferenceDocumentType = 'RMRP' AND strlen( ls_row-OriginalReferenceDocument ) >= 14.
              SELECT * FROM I_SuplrInvcItemPurOrdRefAPI01
              WHERE SupplierInvoice = @ls_row-OriginalReferenceDocument(10)
              AND   FiscalYear = @ls_row-OriginalReferenceDocument+10(4)
              AND   TaxCode = @ls_row-TaxCode
              INTO TABLE @DATA(lt_porefer).
              IF lt_porefer IS INITIAL.
                ls_data-tenhang = ls_row-accountingdocumentheadertext.
              ELSE. " Case có PO
                CLEAR : lt_condition_text,lt_po_itemtext.
                READ TABLE lt_porefer INTO DATA(ls_potype) INDEX 1.
                SELECT SINGLE purchaseordertype
                FROM I_PurchaseOrderAPI01
                WHERE PurchaseOrder = @ls_potype-PurchaseOrder
                INTO @DATA(lw_potype).
                IF lw_potype NE 'ZPO4'. " Khac may gia cong
                  LOOP AT lt_porefer INTO DATA(ls_porefer).
                    IF ls_porefer-SuplrInvcDeliveryCostCndnType IS NOT INITIAL.
                      SELECT SINGLE *
                        FROM I_PurOrdPricingElementTP_2
                        WHERE purchaseorder = @ls_porefer-PurchaseOrder
                        AND PurchaseOrderItem = @ls_porefer-PurchaseOrderItem
                        AND ConditionType = @ls_porefer-SuplrInvcDeliveryCostCndnType
                        INTO CORRESPONDING FIELDS OF @ls_condition_text.
                      APPEND ls_condition_text TO lt_condition_text.
                    ELSE.
                      SELECT SINGLE *
                        FROM I_PurchaseOrderItemAPI01
                        WHERE purchaseorder = @ls_porefer-PurchaseOrder
                        AND PurchaseOrderItem = @ls_porefer-PurchaseOrderItem
                        INTO CORRESPONDING FIELDS OF @ls_po_itemtext.
                      APPEND ls_po_itemtext TO lt_po_itemtext.
                    ENDIF.
                  ENDLOOP.
                  SORT lt_condition_text BY ConditionType.
                  DELETE ADJACENT DUPLICATES FROM lt_condition_text COMPARING ConditionType.
                  SORT lt_po_itemtext BY purchaseorder PurchaseOrderItem.
                  DELETE ADJACENT DUPLICATES FROM lt_po_itemtext COMPARING purchaseorder PurchaseOrderItem.
                  LOOP AT lt_condition_text INTO ls_condition_text.
                    IF ls_data-tenhang IS INITIAL.
                      ls_data-tenhang = ls_condition_text-ConditionTypeName.
                    ELSE.
                      CONCATENATE ls_data-tenhang ls_condition_text-ConditionTypeName INTO ls_data-tenhang SEPARATED BY ', '.
                    ENDIF.
                  ENDLOOP.
                  LOOP AT lt_po_itemtext INTO ls_po_itemtext.
                    IF ls_data-tenhang IS INITIAL.
                      ls_data-tenhang = ls_po_itemtext-PurchaseOrderItemText.
                    ELSE.
                      CONCATENATE ls_data-tenhang ls_po_itemtext-PurchaseOrderItemText INTO ls_data-tenhang SEPARATED BY ', '.
                    ENDIF.
                  ENDLOOP.
                ELSE. " May gia cong lay o app xuat hoa don
                  SELECT productdescription
                  FROM ztb_xn_xuat_hd AS a
                  INNER JOIN ztb_xuat_hd AS b
                  ON a~hdr_id = b~hdr_id
                  WHERE supplierinvoice = @ls_row-OriginalReferenceDocument(10)
                  INTO TABLE @DATA(lt_des).
                  SORT lt_des BY productdescription.
                  DELETE ADJACENT DUPLICATES FROM lt_des COMPARING productdescription.
                  LOOP AT  lt_des INTO DATA(ls_des).
                    IF ls_data-tenhang IS INITIAL.
                      ls_data-tenhang = ls_des-productdescription.
                    ELSE.
                      CONCATENATE ls_data-tenhang ls_des-productdescription INTO ls_data-tenhang SEPARATED BY ', '.
                    ENDIF.
                  ENDLOOP.
                  IF ls_data-tenhang IS NOT INITIAL.
                    CONCATENATE 'Chi phí gia công túi' ls_data-tenhang INTO ls_data-tenhang SEPARATED BY ''.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
            IF ls_data-tenhang IS INITIAL AND ls_row-ReferenceDocumentType NE 'RMRP'.
              ls_data-tenhang = ls_row-accountingdocumentheadertext.
            ENDIF.
          ENDIF.
          "🔹 GỘP TH1 & TH2: Cộng tổng tất cả các dòng có cùng TaxCode trong chứng từ
          "   Bao gồm cả dòng G/L 1331* và dòng Account Type = S hoặc A
          CLEAR ls_data-doanhso.
          lw_item = |{ ls_row-AccountingDocumentItem ALPHA = IN }|.
          IF ls_row-GLAccount CP '1331*'. " Line thue
            READ TABLE lt_taxbase INTO DATA(ls_taxbase) WITH KEY   CompanyCode = ls_row-CompanyCode
                                                                   AccountingDocument = ls_row-AccountingDocument
AccountingDocumentItem = lw_item.
            IF sy-subrc = 0.
              ls_data-doanhso = ls_data-doanhso + ls_taxbase-TaxBaseAmountInCoCodeCrcy.
            ENDIF.
          ELSE. " Line thuong
            LOOP AT lt_hsl_full INTO DATA(ls_line_full)
                 WHERE CompanyCode        = ls_row-CompanyCode
                   AND AccountingDocument = ls_row-AccountingDocument
                   AND TaxCode            = ls_row-TaxCode
                   AND ( FinancialAccountType = 'S' OR FinancialAccountType = 'A' OR FinancialAccountType = 'M' )
                   AND GLAccount NP '11*'.
              ls_data-doanhso += ls_line_full-AmountInCompanyCodeCurrency.
            ENDLOOP.
          ENDIF.
*          LOOP AT lt_hsl_full INTO DATA(ls_line_full)
*               WHERE CompanyCode        = ls_row-CompanyCode
*                 AND AccountingDocument = ls_row-AccountingDocument
*                 AND TaxCode            = ls_row-TaxCode
*                 AND ( FinancialAccountType = 'S' OR FinancialAccountType = 'A' )
*                 AND GLAccount NP '1331*'.
*            ls_data-doanhso += ls_line_full-AmountInCompanyCodeCurrency.
*          ENDLOOP.

          " 🔹 TÍNH THUẾ GTGT (TH1/TH2)
          CLEAR ls_data-thue_gtgt.

          " Kiểm tra có dòng 1331* không
          DATA(lv_has_1331) = abap_false.
          LOOP AT lt_hsl_full INTO DATA(ls_chk_1331)
               WHERE CompanyCode        = ls_row-CompanyCode
                 AND AccountingDocument = ls_row-AccountingDocument
                 AND GLAccount CP '1331*'.
            lv_has_1331 = abap_true.
            EXIT.
          ENDLOOP.

          IF lv_has_1331 = abap_true.
            " Nếu có dòng 1331* thì subtotal AmountInCompanyCodeCurrency các dòng 1331* theo TaxCode
            LOOP AT lt_hsl_full INTO DATA(ls_tax1331)
                 WHERE CompanyCode        = ls_row-CompanyCode
                   AND AccountingDocument = ls_row-AccountingDocument
                   AND GLAccount CP '1331*'
                   AND TaxCode            = ls_row-TaxCode.
              ls_data-thue_gtgt += ls_tax1331-AmountInCompanyCodeCurrency.
            ENDLOOP.
          ELSE.
            " Nếu không có dòng 1331* thì mặc định = 0
            ls_data-thue_gtgt = 0.
          ENDIF.

          "=== GHI CHÚ TH1 ===
          DATA(lv_has_tax_line) = abap_false.

          LOOP AT lt_hsl_full INTO DATA(ls_tmp)
              WHERE CompanyCode        = ls_row-CompanyCode
                AND AccountingDocument = ls_row-AccountingDocument
                AND GLAccount CP '1331*'.
            lv_has_tax_line = abap_true.
            EXIT.
          ENDLOOP.
          " Logic check dieu chinh/ thay the ghi chu
          CLEAR : lw_dc_tt_flag.
          IF strlen( ls_row-AccountingDocumentHeaderText ) >= 2.
            IF ls_row-AccountingDocumentHeaderText(2) = 'TT'.
              lw_dc_tt_flag = 'TT'.
            ELSEIF ls_row-AccountingDocumentHeaderText(2) = 'DC' OR ls_row-AccountingDocumentHeaderText(2) = 'ĐC'.
              lw_dc_tt_flag = 'DC'.
            ENDIF.
          ENDIF.
          "
          IF ls_more-InvoiceReference IS NOT INITIAL AND ls_more-InvoiceReference NE 'V'.
            SELECT SINGLE DocumentReferenceID,
                          DocumentDate
            FROM I_journalentry
            WHERE companycode = @ls_more-CompanyCode
            AND   FiscalYear = @ls_more-InvoiceReferenceFiscalYear
            AND   AccountingDocument = @ls_more-InvoiceReference
            INTO @DATA(ls_ghichu).
            IF sy-subrc = 0 AND ls_ghichu-DocumentReferenceID IS NOT INITIAL AND lw_dc_tt_flag = 'DC'.
              ls_data-ghichu = |Hóa đơn { ls_row-DocumentReferenceID } điều chỉnh cho hóa đơn { ls_ghichu-DocumentReferenceID } ngày { ls_ghichu-DocumentDate+6(2) } tháng { ls_ghichu-DocumentDate+4(2) } năm { ls_ghichu-DocumentDate(4) } |.
            ELSEIF sy-subrc = 0 AND ls_ghichu-DocumentReferenceID IS NOT INITIAL AND lw_dc_tt_flag = 'TT'.
              ls_data-ghichu = |Hóa đơn { ls_row-DocumentReferenceID } thay thế cho hóa đơn { ls_ghichu-DocumentReferenceID } ngày { ls_ghichu-DocumentDate+6(2) } tháng { ls_ghichu-DocumentDate+4(2) } năm { ls_ghichu-DocumentDate(4) } |.
            ELSEIF sy-subrc = 0 AND ls_ghichu-DocumentReferenceID IS NOT INITIAL.
              ls_data-ghichu = |Hóa đơn { ls_row-DocumentReferenceID } thay thế/điều chỉnh cho hóa đơn { ls_ghichu-DocumentReferenceID } ngày { ls_ghichu-DocumentDate+6(2) } tháng { ls_ghichu-DocumentDate+4(2) } năm { ls_ghichu-DocumentDate(4) } |.
            ENDIF.
          ELSE.
            CLEAR : lw_text1,lw_text2,lw_text3,lw_text4.
            SPLIT ls_row-AccountingDocumentHeaderText AT ' ' INTO lw_text1 lw_text2 lw_text3 lw_text4.
            IF strlen( lw_text4 ) >= 8 AND lw_dc_tt_flag = 'DC'.
              ls_data-ghichu = |Điều chỉnh cho hóa đơn { lw_text3 } ngày { lw_text4(2) } tháng { lw_text4+3(2) } năm 20{ lw_text4+6(2) } |.
            ELSEIF strlen( lw_text4 ) >= 8 AND lw_dc_tt_flag = 'TT'.
              ls_data-ghichu = |Thay thế cho hóa đơn { lw_text3 } ngày { lw_text4(2) } tháng { lw_text4+3(2) } năm 20{ lw_text4+6(2) } |.
            ENDIF.
          ENDIF.
          CLEAR : ls_more.
*          IF lv_has_tax_line = abap_true.
*            ls_data-ghichu = 'Hóa đơn hợp lệ – có dòng thuế 1331*'.
*          ELSE.
*            ls_data-ghichu = 'Chứng từ không có dòng thuế 1331*'.
*          ENDIF.

          " 🔹 TÍNH THUẾ SUẤT (TH1)
          CLEAR ls_data-thuesuat.

          CASE ls_row-taxcode.
            WHEN 'I1'.
              ls_data-thuesuat = '0'.
            WHEN 'I2'.
              ls_data-thuesuat = '5'.
            WHEN 'I3'.
              ls_data-thuesuat = '8'.
            WHEN 'I4'.
              ls_data-thuesuat = '10'.
            WHEN 'IK'.
              " Tính (14)/(12)*100%
              DATA(lv_tax_amount) = ls_data-thue_gtgt.
              DATA(lv_base_amount) = ls_data-doanhso.

*              LOOP AT lt_hsl_full INTO DATA(ls_tax_line)
*                   WHERE CompanyCode        = ls_row-CompanyCode
*                     AND AccountingDocument = ls_row-AccountingDocument
*                     AND GLAccount CP '3331*'
*                     AND TaxCode            = ls_row-TaxCode.
*                lv_tax_amount += ls_tax_line-AmountInCompanyCodeCurrency.
*              ENDLOOP.

              IF lv_base_amount <> 0.
                ls_data-thuesuat = ( lv_tax_amount / lv_base_amount ) * 100.
              ELSE.
                ls_data-thuesuat = 0.
              ENDIF.

            WHEN OTHERS.
              CLEAR ls_data-thuesuat.
          ENDCASE.

          ls_data-currency_code = ls_row-CompanyCodeCurrency.
          ls_data-bukrs = ls_row-CompanyCode.
          ls_data-belnr = ls_row-AccountingDocument.
          ls_data-item  = ls_row-AccountingDocumentItem.
          APPEND ls_data TO lt_data.
          CLEAR : ls_data.
        ENDLOOP.


        "=== TH2: GHÉP DỮ LIỆU TỪ BẢNG HẠCH TOÁN THUẾ 0% ===
        READ TABLE lt_taxcode INTO DATA(ls_taxcode) WITH KEY taxcode = 'I1'.
        IF sy-subrc NE 0.
          CLEAR: gt_thue0_detail.
        ENDIF.
        LOOP AT gt_thue0_detail INTO DATA(ls_thue0).
          CLEAR ls_data.
          MOVE-CORRESPONDING ls_thue0 TO ls_data.

          " 🔹 Gán Tax Code cho thuế 0%
          ls_data-taxcode = 'I1'.

          " 🔹 Lấy số chứng từ (Document Number)
          ls_data-docnum = ls_thue0-documentnumber.
          ls_data-sochungtu = ls_thue0-documentnumber.
          " 🔸 Mẫu HĐ: lấy từ bảng zui_kb_thue0
          ls_data-mauhd = ls_thue0-mauhd.

          " 🔹 Lấy tháng từ PostingDate
          IF ls_thue0-postingdate IS NOT INITIAL.
            ls_data-thang = ls_thue0-postingdate+4(2).
          ENDIF.

          " 🔹 Lấy ký hiệu HĐ, số HĐ = phần trước, sau dấu '#' trong DocumentReferenceID
          IF ls_thue0-documentreferenceid IS NOT INITIAL.
            DATA(lv_doc_ref2) = ls_thue0-DocumentReferenceID.
            SPLIT lv_doc_ref2 AT '#' INTO ls_data-kyhieu_hd ls_data-sohd.
          ENDIF.

          " 🔹 Gán thông tin công ty & khoảng thời gian
          ls_data-ten_cty    = ls_companycode-companycodename.
          ls_data-diachi_cty = ls_companycode-companycodeaddr.
          READ TABLE ir_posting_date INTO ls_postdate INDEX 1.
          IF sy-subrc = 0.
            ls_data-tungay  = ls_postdate-low.
            ls_data-denngay = ls_postdate-high.
          ENDIF.

          " 🔹 Lấy ngày chứng từ theo FS
          ls_data-ngayhd = ls_thue0-invoicedate.

          " 🔹 TH1: Ưu tiên lấy tên mã vãng lai nếu có
          IF ls_thue0-tenmavanglai IS NOT INITIAL.
            ls_data-tendonvi = ls_thue0-tenmavanglai.
            ls_data-masothue = ls_thue0-mstmavanglai.
          ELSE.
            " 🔹 TH2: Nếu trống → lấy Supplier Master như TH1
            IF ls_thue0-supplier IS NOT INITIAL.
              zcl_jp_common_core=>get_bp_info_new(
                 EXPORTING
                    i_businesspartner = ls_thue0-supplier
                 IMPORTING
                    o_bp_info = DATA(ls_supplier2)
              ).
              ls_data-tendonvi = ls_supplier2-bpname.
              ls_data-masothue = ls_supplier2-mst.
            ENDIF.
          ENDIF.

          " 🔹 Lấy Item Text từ zui_kb_thue0
          ls_data-tenhang = ls_thue0-itemtext.

          " 🔹 TH2: Hạch toán thuế 0% => luôn hiển thị 0%
          ls_data-thuesuat = '0'.

          " 🔹 TH3: Thuế GTGT theo chức năng Hạch toán thuế 0%
          " 🔹 Gán Doanh số theo Doanh số quy đổi VND
          ls_data-doanhso   = ls_thue0-doanhsovnd.

          " 🔹 Thuế GTGT của bảng thuế suất 0% luôn bằng 0
          ls_data-thue_gtgt = 0.

          "=== USER CREATED BY FOR TAX 0% ===
          READ TABLE lt_user_map
               WITH TABLE KEY userid = ls_thue0-createdbyuser
               INTO DATA(ls_user2).

          IF sy-subrc = 0.
            ls_data-hachtoan_user = ls_user2-username.
          ELSE.
            ls_data-hachtoan_user = ls_thue0-createdbyuser.
          ENDIF.

          "Check dòng hiện tại có trong bảng thuế 0%"
          READ TABLE gt_thue0_detail INTO DATA(ls_t0)
            WITH KEY companycode     = ls_row-companycode
                     documentnumber  = ls_row-accountingdocument.

          IF sy-subrc = 0.
            ls_data-ghichu = ls_t0-itemtext.  "Lấy luôn ghi chú"
          ENDIF.

          " ✅ Đảm bảo hiển thị số 0 khi export ra Excel
          IF ls_data-thue_gtgt IS INITIAL.
            ls_data-thue_gtgt = 0.
          ENDIF.

          " 🔹 Gán mã tiền tệ
          ls_data-currency_code = ls_thue0-loaitienvnd.
          ls_data-bukrs = ls_thue0-companycode.
          ls_data-belnr = ls_thue0-documentnumber.
          APPEND ls_data TO lt_data.
          CLEAR ls_data.

        ENDLOOP.
        IF lv_symbol IS NOT INITIAL.
          DELETE lt_data WHERE kyhieu_hd NE lv_symbol.
        ENDIF.

*        "=== TÍNH TỔNG THEO TỪNG NHÓM THUẾ SUẤT ===
        DATA: lt_summary TYPE TABLE OF zc_bangkevat,
              ls_summary TYPE zc_bangkevat.
*
*        SORT lt_data BY taxcode.
*
        DATA(lv_current_taxcode) = ''.
        DATA(lv_sum_doanhso)     = 0.
        DATA(lv_sum_thuegtgt)    = 0.

*        LOOP AT lt_data INTO ls_data.
*
*          " Cộng dồn trong nhóm
*          lv_sum_doanhso  += ls_data-doanhso.
*          lv_sum_thuegtgt += ls_data-thue_gtgt.
*
*        ENDLOOP.

*        CLEAR ls_summary.
*        ls_summary-thang     = 'TỔNG CỘNG'.
*        ls_summary-currency_code     = 'VND'.
*        ls_summary-doanhso   = lv_sum_doanhso.
*        ls_summary-thue_gtgt = lv_sum_thuegtgt.
*        APPEND ls_summary TO lt_data.
*
*        IF ls_page_info-page_size < 0.
*          ls_page_info-page_size = 50.
*        ENDIF.

        DATA(max_rows) = COND #( WHEN ls_page_info-page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                   ELSE ls_page_info-page_size ).

        max_rows = ls_page_info-page_size + ls_page_info-offset.

        LOOP AT lt_data INTO ls_data.
          IF sy-tabix > ls_page_info-offset.
            IF sy-tabix > max_rows.
              EXIT.
            ELSE.
              APPEND ls_data TO lt_data_1.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        IF io_request->is_data_requested( ).
          io_response->set_data( lt_data_1 ).
        ENDIF.


      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

        RAISE EXCEPTION TYPE zcl_jp_data_bangkevat
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


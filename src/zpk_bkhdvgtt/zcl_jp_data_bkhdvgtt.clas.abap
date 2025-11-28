CLASS zcl_jp_data_bkhdvgtt DEFINITION
  PUBLIC
*  FINAL
  INHERITING FROM cx_rap_query_provider
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.


CLASS zcl_jp_data_bkhdvgtt IMPLEMENTATION.

  METHOD if_rap_query_provider~select.

    " 1. KHAI BÁO BIẾN
    TYPES: BEGIN OF ty_user_map,
             userid   TYPE abp_creation_user,
             username TYPE char80,
           END OF ty_user_map,

           BEGIN OF ty_user_tmp,
             userid         TYPE abp_creation_user,
             personfullname TYPE string,
           END OF ty_user_tmp.

    DATA: ls_page_info    TYPE zcl_get_filter_bkhdvgtt=>ty_page_info,
          ir_bukrs        TYPE zcl_get_filter_bkhdvgtt=>tt_range,
          ir_posting_date TYPE zcl_get_filter_bkhdvgtt=>tt_range,
          ir_fiscalyear   TYPE zcl_get_filter_bkhdvgtt=>tt_range,
          ir_docnum       TYPE zcl_get_filter_bkhdvgtt=>tt_range,
          ir_prctr        TYPE zcl_get_filter_bkhdvgtt=>tt_range,
          lt_data         TYPE STANDARD TABLE OF zc_bkhdvgtt WITH EMPTY KEY,
          lt_data_paged   TYPE STANDARD TABLE OF zc_bkhdvgtt WITH EMPTY KEY,
          ls_data         TYPE zc_bkhdvgtt,
          lt_user_map     TYPE HASHED TABLE OF ty_user_map WITH UNIQUE KEY userid,
          lt_user_ids     TYPE SORTED TABLE OF abp_creation_user WITH UNIQUE KEY table_line,
          lt_user_tmp     TYPE TABLE OF ty_user_tmp.

    TRY.

        " 2. LẤY FILTER
        DATA(lo_filter) = NEW zcl_get_filter_bkhdvgtt( ).

        lo_filter->get_fillter_app(
          EXPORTING
            io_request      = io_request
            io_response     = io_response
          IMPORTING
            ir_bukrs        = ir_bukrs
            ir_posting_date = ir_posting_date
            ir_fiscalyear   = ir_fiscalyear
            ir_docnum       = ir_docnum
            ir_prctr        = ir_prctr
            wa_page_info    = ls_page_info
        ).

        " 3. LẤY COMPANY CODE
        DATA(lv_companycode) =
          COND bukrs(
            WHEN line_exists( ir_bukrs[ 1 ] ) THEN ir_bukrs[ 1 ]-low
            ELSE ''
          ).

        zcl_jp_common_core=>get_companycode_details(
          EXPORTING i_companycode = lv_companycode
          IMPORTING o_companycode = DATA(ls_companycode)
        ).

        "=== GÁN TÊN CÔNG TY – ĐỊA CHỈ – MÃ SỐ THUẾ ===
        ls_data-ten_cty    = ls_companycode-companycodename.
        ls_data-diachi_cty = ls_companycode-companycodeaddr.
        ls_data-mst_cty    = ls_companycode-vatregistration.


        " 4. SELECT CHÍNH
        SELECT
                    h~CompanyCode,
                    h~AccountingDocument,
                    h~FiscalYear,
                    h~PostingDate,
                    h~DocumentDate,
                    h~DocumentReferenceID,
                    h~OriginalReferenceDocument,
                    h~ReversalReferenceDocument,
                    h~ReverseDocumentFiscalYear,
                    h~AccountingDocumentType,
                    h~ReferenceDocumentType,
                    h~IsReversal,
                    h~IsReversed,
                    i~AccountingDocumentItem,
                    i~GLAccount,
                    i~AmountInCompanyCodeCurrency,
                    i~TaxCode,
                    i~ProfitCenter,
                    i~AccountingDocCreatedByUser,
                    i~DocumentItemText,
                    i~FinancialAccountType,
                    i~NetDueDate,
                    i~CompanyCodeCurrency
                  FROM i_journalentryitem AS i
                  INNER JOIN i_journalentry AS h
                    ON  i~CompanyCode       = h~CompanyCode
                    AND i~AccountingDocument = h~AccountingDocument
                    AND i~FiscalYear         = h~FiscalYear
                  WHERE h~CompanyCode        IN @ir_bukrs
                    AND h~PostingDate        IN @ir_posting_date
                    AND h~FiscalYear         IN @ir_fiscalyear
                    AND h~AccountingDocument IN @ir_docnum
                    AND i~ProfitCenter       IN @ir_prctr
                    AND ( i~Ledger = '0L' OR i~Ledger = '' )
                    AND ( h~LedgerGroup = '0L' OR h~LedgerGroup = '' )
*                    AND i~FinancialAccountType <> 'S'
                    AND h~IsReversal = ''
                    AND h~IsReversed = ''
                    AND h~AccountingDocumentType <> 'AB'
                  INTO TABLE @DATA(gt_raw).

        " 5. LẤY ONE-TIME ACCOUNT
        IF gt_raw IS NOT INITIAL.

          SELECT *
            FROM i_onetimeaccountsupplier
            FOR ALL ENTRIES IN @gt_raw
            WHERE CompanyCode        = @gt_raw-CompanyCode
              AND AccountingDocument = @gt_raw-AccountingDocument
              AND FiscalYear         = @gt_raw-FiscalYear
            INTO TABLE @DATA(lt_bsec).

        ENDIF.

        " 6. LOẠI CẶP CHỨNG TỪ HỦY/ĐẢO
        DATA(lt_docs) = gt_raw.

        SORT lt_docs BY CompanyCode AccountingDocument.
        DELETE ADJACENT DUPLICATES FROM lt_docs COMPARING CompanyCode AccountingDocument.

        DATA lt_delete TYPE RANGE OF belnr_d.

        LOOP AT lt_docs INTO DATA(ls_doc)
          WHERE ReversalReferenceDocument IS NOT INITIAL.

          DATA(lv_ref) = ls_doc-ReversalReferenceDocument.

          IF ls_doc-ReferenceDocumentType = 'RMRP'.

            READ TABLE lt_docs INTO DATA(ls_pair)
              WITH KEY
                CompanyCode             = ls_doc-CompanyCode
                OriginalReferenceDocument = |{ lv_ref+0(10) }|
ReferenceDocumentType   = 'RMRP'.

          ELSE.

            READ TABLE lt_docs INTO ls_pair
              WITH KEY
                CompanyCode        = ls_doc-CompanyCode
                AccountingDocument = lv_ref
                FiscalYear         = ls_doc-ReverseDocumentFiscalYear.

          ENDIF.
IF sy-subrc = 0
             AND ls_doc-PostingDate  IN ir_posting_date
             AND ls_pair-PostingDate IN ir_posting_date.

            APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_doc-AccountingDocument ) TO lt_delete.
            APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_pair-AccountingDocument ) TO lt_delete.

          ENDIF.

        ENDLOOP.

        IF lt_delete IS NOT INITIAL.
          DELETE gt_raw WHERE AccountingDocument IN lt_delete.
        ENDIF.

        " 7. GHÉP DỮ LIỆU CHÍNH (BẢN ĐÃ SỬA)
        TYPES: BEGIN OF ty_key,
                 companycode        TYPE bukrs,
                 accountingdocument TYPE belnr_d,
                 fiscalyear         TYPE gjahr,
               END OF ty_key.

        DATA lt_docs_unique TYPE SORTED TABLE OF ty_key
              WITH UNIQUE KEY companycode accountingdocument fiscalyear.

        DATA ls_doc_key TYPE ty_key.

        LOOP AT gt_raw INTO DATA(ls_row_key).
          ls_doc_key-companycode        = ls_row_key-CompanyCode.
          ls_doc_key-accountingdocument = ls_row_key-AccountingDocument.
          ls_doc_key-fiscalyear         = ls_row_key-FiscalYear.
          INSERT ls_doc_key INTO TABLE lt_docs_unique.
        ENDLOOP.

        LOOP AT lt_docs_unique INTO ls_doc_key.

          CLEAR ls_data.

          "=== Gắn lại thông tin công ty sau khi CLEAR ===
          ls_data-ten_cty    = ls_companycode-companycodename.
          ls_data-diachi_cty = ls_companycode-companycodeaddr.
          ls_data-mst_cty    = ls_companycode-vatregistration.


          "=== lấy dòng bất kỳ để map header
          READ TABLE gt_raw INTO DATA(ls_row)
            WITH KEY
              CompanyCode        = ls_doc_key-companycode
              AccountingDocument = ls_doc_key-accountingdocument
              FiscalYear         = ls_doc_key-fiscalyear.

          MOVE-CORRESPONDING ls_row TO ls_data.
          "=== NGÀY CHỨNG TỪ
          ls_data-ngaychungtu_goc = ls_row-DocumentDate.

          "=== NGÀY HÓA ĐƠN (Journal Entry Date)
          ls_data-ngayhoadon = ls_row-DocumentDate.

          "=== SỐ HÓA ĐƠN THEO FS ===
          DATA(lv_ref2) = ls_row-DocumentReferenceID.

          IF lv_ref2 CS '#'.
            SPLIT lv_ref2 AT '#' INTO DATA(lv_before) DATA(lv_after).
            CONDENSE lv_after.
            ls_data-sohoadon = lv_after.
          ELSE.
            ls_data-sohoadon = lv_ref2.
          ENDIF.

          ls_data-sochungtu_hoadon = ls_doc_key-accountingdocument.


          "=== LẤY SUPPLIER
          SELECT SINGLE Supplier
            FROM i_journalentryitem
            WHERE CompanyCode        = @ls_doc_key-companycode
              AND AccountingDocument = @ls_doc_key-accountingdocument
              AND FiscalYear         = @ls_doc_key-fiscalyear
              AND FinancialAccountType = 'K'
            INTO @DATA(lv_supplier).

          "=== LẤY SỐ CHỨNG TỪ THANH TOÁN (Clearing Journal Entry) ===
          DATA(lv_clear_doc) = ''.

          SELECT SINGLE ClearingJournalEntry
FROM i_journalentryitem
            WHERE CompanyCode              = @ls_doc_key-companycode
              AND Supplier                 = @lv_supplier
              AND ClearingDate IS NOT NULL
              AND ClearingJournalEntry IS NOT NULL
              AND AccountingDocument <> @ls_doc_key-accountingdocument
            INTO @lv_clear_doc.

          ls_data-sochungtu_tt = lv_clear_doc.

          "=== NGÀY CHỨNG TỪ THANH TOÁN (Lấy từ Clearing Journal Entry) ===
CLEAR ls_data-ngaychungtu_tt.

IF ls_data-sochungtu_tt IS NOT INITIAL.

  SELECT SINGLE DocumentDate
    FROM i_journalentry
    WHERE CompanyCode        = @ls_doc_key-companycode
      AND AccountingDocument = @ls_data-sochungtu_tt
      AND FiscalYear         = @ls_doc_key-fiscalyear
    INTO @ls_data-ngaychungtu_tt.

ENDIF.

          "=== GHÉP TÊN + MÃ SỐ THUẾ
          READ TABLE lt_bsec INTO DATA(ls_bsec_match)
            WITH KEY
              companycode        = ls_doc_key-companycode
              accountingdocument = ls_doc_key-accountingdocument
              fiscalyear         = ls_doc_key-fiscalyear.

          IF sy-subrc = 0.

            ls_data-tendonvi =
              |{ ls_bsec_match-BusinessPartnerName1 } {
                 ls_bsec_match-BusinessPartnerName2 } {
                 ls_bsec_match-BusinessPartnerName3 } {
                 ls_bsec_match-BusinessPartnerName4 }|.

            CONDENSE ls_data-tendonvi.
            ls_data-masothue = ls_bsec_match-TaxID1.

          ELSEIF lv_supplier IS NOT INITIAL.

            zcl_jp_common_core=>get_bp_info_new(
              EXPORTING i_businesspartner = lv_supplier
              IMPORTING o_bp_info         = DATA(ls_bp)
            ).

*            ls_data-tendonvi = ls_bp-bpname.
*            ls_data-masothue = ls_bp-mst.

*            ls_data-bukrs = ls_row-CompanyCode.
*            ls_data-belnr = ls_row-AccountingDocument.
*            ls_data-gjahr = ls_row-FiscalYear.
*            ls_data-posting_date = ls_row-PostingDate.

          ENDIF.

          ls_data-tendonvi = ls_bp-bpname.
          ls_data-masothue = ls_bp-mst.
          ls_data-bukrs = ls_row-CompanyCode.
          ls_data-belnr = ls_row-AccountingDocument.
          ls_data-gjahr = ls_row-FiscalYear.
          ls_data-posting_date = ls_row-PostingDate.


          "=== TÍNH TIỀN HÀNG THEO LOGIC TH1 / TH2 ===

          DATA(lv_tien_1331) = 0.
          DATA(lv_tien_s)    = 0.

          "--- TH1: Kiểm tra có line G/L 1331* hay không
          LOOP AT gt_raw INTO DATA(ls_tmp)
            WHERE CompanyCode        = ls_doc_key-companycode
              AND AccountingDocument = ls_doc_key-accountingdocument
              AND FiscalYear         = ls_doc_key-fiscalyear
              AND GLAccount CP '1331*'.

            lv_tien_1331 = ls_tmp-AmountInCompanyCodeCurrency.
            EXIT.
          ENDLOOP.

          IF lv_tien_1331 <> 0.

            "=== TH1: Lấy base amount của dòng 1331*
ls_data-tienhang = lv_tien_1331.

          ELSE.

            "=== TH2: subtotal các dòng S
            LOOP AT gt_raw INTO ls_tmp
              WHERE CompanyCode        = ls_doc_key-companycode
                AND AccountingDocument = ls_doc_key-accountingdocument
                AND FiscalYear         = ls_doc_key-fiscalyear
                AND FinancialAccountType = 'S'.

              lv_tien_s = lv_tien_s + ls_tmp-AmountInCompanyCodeCurrency.
            ENDLOOP.

            ls_data-tienhang = lv_tien_s.

          ENDIF.


          "=== THUẾ SUẤT ===
          DATA(lv_taxcode) = ls_row-TaxCode.
          DATA(lv_rate)    = 0.

          IF lv_taxcode IS NOT INITIAL.

            "--- TH1: Các mã thuế cố định ---
            CASE lv_taxcode.
              WHEN 'I1'.
                lv_rate = 0.
              WHEN 'I2'.
                lv_rate = 5.
              WHEN 'I3'.
                lv_rate = 8.
              WHEN 'I4'.
                lv_rate = 10.

                "--- TH2: IK = (tienthue / tienhang) * 100 ---
              WHEN 'IK'.
                IF ls_data-tienhang <> 0.
                  lv_rate = ( ls_data-tienthue / ls_data-tienhang ) * 100.
                ELSE.
                  lv_rate = 0.
                ENDIF.

              WHEN OTHERS.
                lv_rate = 0.
            ENDCASE.

          ENDIF.

          ls_data-thuesuat = lv_rate.


          "=== TIỀN THUẾ (THEO TK 1331*) ===
          DATA(lv_tax_1331) = 0.

          "TH1: Nếu có dòng 1331* → lấy AmountInCompanyCodeCurrency chính dòng đó
          LOOP AT gt_raw INTO ls_tmp
            WHERE CompanyCode        = ls_doc_key-companycode
              AND AccountingDocument = ls_doc_key-accountingdocument
              AND FiscalYear         = ls_doc_key-fiscalyear
              AND GLAccount CP '1331*'.

            lv_tax_1331 = ls_tmp-AmountInCompanyCodeCurrency.
            EXIT.
          ENDLOOP.

          IF lv_tax_1331 <> 0.
            "TH1: Lấy đúng số tiền tại dòng 1331*
            ls_data-tienthue = lv_tax_1331.
          ELSE.
            "TH2: Không có 1331* → tiền thuế = 0
            ls_data-tienthue = 0.
          ENDIF.

          "=== THÀNH TIỀN (Tiền hàng + Tiền thuế) ===
          ls_data-thanhtien = ls_data-tienhang + ls_data-tienthue.



*          "=== TIỀN UNC (TK 112*) ===
*          SELECT SUM( AmountInCompanyCodeCurrency )
*            FROM i_journalentryitem
*            WHERE CompanyCode        = @ls_doc_key-companycode
*              AND AccountingDocument = @ls_doc_key-accountingdocument
*              AND FiscalYear         = @ls_doc_key-fiscalyear
*              AND GLAccount LIKE  '112*'
*            INTO @ls_data-sotien_uncc.
*
*          IF ls_data-sotien_uncc IS INITIAL.
*            ls_data-sotien_uncc = 0.
*          ENDIF.
*
*          "=== THANH TOÁN BÙ TRỪ (TK 131*) ===
*          SELECT SUM( AmountInCompanyCodeCurrency )
*            FROM i_journalentryitem
*            WHERE CompanyCode        = @ls_doc_key-companycode
*              AND AccountingDocument = @ls_doc_key-accountingdocument
*              AND FiscalYear         = @ls_doc_key-fiscalyear
*              AND GLAccount LIKE  '131*'
*            INTO @ls_data-thanhtoan_butru.
*
*          IF ls_data-thanhtoan_butru IS INITIAL.
*            ls_data-thanhtoan_butru = 0.
*          ENDIF.
*
*          "=== THANH TOÁN TIỀN MẶT (TK 111*) ===
*          SELECT SUM( AmountInCompanyCodeCurrency )
*            FROM i_journalentryitem
*            WHERE CompanyCode        = @ls_doc_key-companycode
*              AND AccountingDocument = @ls_doc_key-accountingdocument
*              AND FiscalYear         = @ls_doc_key-fiscalyear
*              AND GLAccount LIKE  '111*'
*            INTO @ls_data-thanhtoan_tienmat.
*
*          IF ls_data-thanhtoan_tienmat IS INITIAL.
*            ls_data-thanhtoan_tienmat = 0.
*          ENDIF.

          "=== TÀI KHOẢN THANH TOÁN (lấy TK 112*) ===
*          SELECT SINGLE GLAccount
*            FROM i_journalentryitem
*            WHERE CompanyCode        = @ls_doc_key-companycode
*              AND AccountingDocument = @ls_doc_key-accountingdocument
*              AND FiscalYear         = @ls_doc_key-fiscalyear
*              AND GLAccount LIKE  '112*'
*            INTO @ls_data-taikhoan_tt.

          "=== TÀI KHOẢN NHÀ CUNG CẤP ===
          ls_data-taikhoan_ncc = lv_supplier.


          "=== TÍNH SỐ TIỀN CHƯA THANH TOÁN DO CHƯA ĐẾN HẠN ===
          DATA(lv_due) = 0.

          " 1. Tìm dòng có FinancialAccountType = 'K' của chứng từ này
          READ TABLE gt_raw INTO DATA(ls_due)
            WITH KEY
              CompanyCode        = ls_doc_key-companycode
              AccountingDocument = ls_doc_key-accountingdocument
              FiscalYear         = ls_doc_key-fiscalyear
              FinancialAccountType = 'K'.

          IF sy-subrc = 0.

            " 2. Kiểm tra điều kiện NetDueDate > PostingDate (tham số)
            IF ls_due-NetDueDate > ls_data-posting_date.

              " 3. CHƯA ĐẾN HẠN = (16) - (21) - (22) - (23)
              lv_due =
                  ls_data-thanhtoan_hoadon   " (16) tiền phải trả NCC
                - ls_data-thanhtoan_butru    " (21)
                - ls_data-thanhtoan_tienmat  " (22)
                - ls_data-sotien_uncc.       " (23)

              ls_data-chuattoan_chuadenhan = lv_due.

            ENDIF.

          ENDIF.


          APPEND ls_data TO lt_data.

        ENDLOOP.

        " 8. TỪ NGÀY – ĐẾN NGÀY
        DATA(lv_tungay) = VALUE dats( ).
        DATA(lv_denngay) = VALUE dats( ).

        IF ir_posting_date IS NOT INITIAL.

          lv_tungay = ir_posting_date[ 1 ]-low.

          LOOP AT ir_posting_date ASSIGNING FIELD-SYMBOL(<d>)
            WHERE high IS NOT INITIAL.
            lv_denngay = <d>-high.
            EXIT.
          ENDLOOP.
IF lv_denngay IS INITIAL.
            lv_denngay = ir_posting_date[ 1 ]-high.
          ENDIF.

        ENDIF.

        LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls>).
          <ls>-tungay  = lv_tungay.
          <ls>-denngay = lv_denngay.
        ENDLOOP.

        " 9. SORT + ĐÁNH STT
        SORT lt_data BY ngayhoadon sohoadon.

        DATA(lv_stt) = 0.

        LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_stt>).
          lv_stt = lv_stt + 1.
          <ls_stt>-stt = lv_stt.
        ENDLOOP.

        " 10. PHÂN TRANG
        DATA(lv_skip) = ls_page_info-offset.

        DATA(lv_top) = COND #(
WHEN ls_page_info-page_size = if_rap_query_paging=>page_size_unlimited
            THEN 0
            ELSE ls_page_info-page_size
        ).

        LOOP AT lt_data INTO ls_data FROM lv_skip + 1.
          IF lv_top > 0 AND sy-tabix > lv_skip + lv_top.
            EXIT.
          ENDIF.
          APPEND ls_data TO lt_data_paged.
        ENDLOOP.

        " 11. SET RESPONSE
        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        IF io_request->is_data_requested( ).
          io_response->set_data( lt_data_paged ).
        ENDIF.

      CATCH cx_root INTO DATA(lx).
        RAISE EXCEPTION TYPE zcl_jp_data_bkhdvgtt
          EXPORTING
            previous = lx.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.

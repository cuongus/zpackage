CLASS zcl_get_dntt DEFINITION
  PUBLIC
  FINAL
    INHERITING FROM cx_rap_query_provider
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_range TYPE TABLE OF ty_range_option,
           tt_data  TYPE TABLE OF zc_dntt,
           gt_data  TYPE TABLE OF zc_dntt,
           tt_para  TYPE TABLE OF zst_dntt_para.

    CLASS-DATA:
     "Instance Singleton

     mo_instance      TYPE REF TO zcl_get_dntt.



    CLASS-METHODS:
      "Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_get_dntt.



  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_get_dntt IMPLEMENTATION.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA: ls_page_info      TYPE zcl_get_fillter=>st_page_info.
    DATA: lt_data TYPE TABLE OF zc_dntt,
          gt_data TYPE TABLE OF zc_dntt.

    DATA: ir_bukrs   TYPE tt_range,
          ir_budat   TYPE tt_range,
          ir_sup     TYPE tt_range,
          ir_cus     TYPE tt_range,
          ir_gjahr   TYPE tt_range,
          ir_belnr   TYPE tt_range,
          ir_sodn    TYPE tt_range,
          ir_open    TYPE tt_range,
          ir_refer   TYPE tt_range,
          o_ngayDN   TYPE char255,
          o_hanHT    TYPE char255,
          o_nguoiDN  TYPE char255,
          o_phong    TYPE char255,
          o_time     TYPE char255,
          o_nguoilap TYPE char255,
          o_ketoan   TYPE char255,
          o_banKS    TYPE char255,
          o_GD       TYPE char255,
          o_KTT      TYPE char255,
          o_TGD      TYPE char255.

    FREE: lt_data, gt_data.
    TRY.
        DATA(lo_unc)  = zcl_get_dntt=>get_instance( ).

        DATA(lo_comcode) = zcl_jp_common_core=>get_instance(  ).

        DATA(lo_common_app) = zcl_dntt_core=>get_instance( ).

        lo_common_app->get_fillter_app(
          EXPORTING
            io_request   = io_request
            io_response  = io_response
          IMPORTING
            ir_bukrs     = ir_bukrs
            ir_budat     = ir_budat
            ir_sup       = ir_sup
            ir_cus       = ir_cus
            ir_gjahr     = ir_gjahr
            ir_belnr     = ir_belnr
            ir_sodn      = ir_sodn
            ir_open      = ir_open
            ir_refer     = ir_refer
            o_ngaydn     = o_ngaydn
            o_hanht      = o_hanht
            o_nguoidn    = o_nguoidn
            o_phong      = o_phong
            o_time       = o_time
            o_nguoilap   = o_nguoilap
            o_ketoan     = o_ketoan
            o_banks      = o_banks
            o_gd         = o_gd
            o_ktt        = o_ktt
            o_tgd        = o_tgd
            wa_page_info = ls_page_info
        ).


        IF ir_sodn[] IS INITIAL.
          SELECT
            h~companycode,
            h~fiscalyear,
            h~accountingdocument,
            h~AccountingDocumentType,
            h~PostingDate,
            h~TransactionCurrency,
            h~DocumentReferenceID,
            h~AccountingDocumentHeaderText AS headerTXT,
            h~AccountingDocumentCategory,
            d~supplier,
            d~customer,
            d~ClearingJournalEntry,
            d~DocumentItemText AS itemTXT
            FROM I_JournalEntry AS h
            INNER JOIN I_OperationalAcctgDocItem AS d
            ON h~AccountingDocument = d~AccountingDocument
            AND h~FiscalYear = d~FiscalYear
            AND h~CompanyCode = d~CompanyCode
            WHERE h~CompanyCode IN @ir_bukrs
            AND h~FiscalYear IN @ir_gjahr
            AND h~AccountingDocument IN @ir_belnr
            AND h~PostingDate IN @ir_budat
            AND d~Customer IN @ir_cus
            AND d~Supplier IN @ir_sup
            AND d~ClearingJournalEntry IN @ir_open
            AND ( d~FinancialAccountType = 'D' OR d~FinancialAccountType = 'K' )
            AND d~DebitCreditCode = 'H'
            AND h~DocumentReferenceID IN @ir_refer
            AND ( h~Ledger = '0L' OR h~Ledger = '' )
            INTO TABLE @DATA(lt_acdoca).

          SELECT
            *
            FROM ztb_dntt
            WHERE companycode IN @ir_bukrs
            AND fiscalyear IN @ir_gjahr
            AND journalentry IN @ir_belnr
            AND sodenghi IN @ir_sodn
            AND Customer IN @ir_cus
            AND supplier IN @ir_sup
            AND openitemtxt IN @ir_open
            AND reference IN @ir_refer
            AND postingdate IN @ir_budat
            INTO TABLE @DATA(lt_log).
          SORT lt_log BY journalentry fiscalyear companycode.

        ELSE.
          LOOP AT ir_open ASSIGNING FIELD-SYMBOL(<fs_range>).
            <fs_range>-low = 'Yes'.
          ENDLOOP.
          SELECT
              *
              FROM ztb_dntt
              WHERE companycode IN @ir_bukrs
              AND fiscalyear IN @ir_gjahr
              AND journalentry IN @ir_belnr
              AND sodenghi IN @ir_sodn
              AND Customer IN @ir_cus
              AND supplier IN @ir_sup
              AND openitemtxt IN @ir_open
              AND reference IN @ir_refer
              AND postingdate IN @ir_budat
              INTO TABLE @lt_log.
          IF lt_log[] IS NOT INITIAL.
            SORT lt_log BY journalentry fiscalyear companycode.
            SELECT
            h~companycode,
            h~fiscalyear,
            h~accountingdocument,
            h~AccountingDocumentType,
            h~PostingDate,
            h~TransactionCurrency,
            h~DocumentReferenceID,
            h~AccountingDocumentHeaderText AS headerTXT,
            h~AccountingDocumentCategory,
            d~supplier,
            d~customer,
            d~ClearingJournalEntry,
            d~DocumentItemText AS itemTXT
            FROM I_JournalEntry AS h
            INNER JOIN I_OperationalAcctgDocItem AS d
            ON h~AccountingDocument = d~AccountingDocument
            AND h~FiscalYear = d~FiscalYear
            AND h~CompanyCode = d~CompanyCode

            FOR ALL ENTRIES IN @lt_log
            WHERE h~CompanyCode = @lt_log-companycode
            AND h~FiscalYear = @lt_log-fiscalyear
            AND h~AccountingDocument = @lt_log-journalentry
            AND h~PostingDate IN @ir_budat
            AND d~Customer IN @ir_cus
            AND d~Supplier IN @ir_sup
            AND d~ClearingJournalEntry IN @ir_open
            AND ( ( d~FinancialAccountType = 'D' AND h~AccountingDocumentType = 'DZ' AND d~SpecialGLCode = 'A' ) OR ( d~FinancialAccountType = 'K' ) )
            AND d~DebitCreditCode = 'H'
            AND h~DocumentReferenceID IN @ir_refer
            AND ( h~Ledger = '0L' OR h~Ledger = '' )
            INTO TABLE @lt_acdoca.
          ENDIF.
        ENDIF.

        IF lt_acdoca[] IS NOT INITIAL.
          SORT lt_acdoca BY CompanyCode FiscalYear AccountingDocument Supplier Customer.
          DELETE ADJACENT DUPLICATES FROM lt_acdoca COMPARING CompanyCode FiscalYear AccountingDocument Supplier Customer.

          SELECT
              companycode,
              fiscalyear,
              accountingdocument,
              glaccount,
              DebitCreditCode,
              AmountInTransactionCurrency
              FROM I_OperationalAcctgDocItem
              FOR ALL ENTRIES IN @lt_acdoca
              WHERE CompanyCode = @lt_acdoca-CompanyCode
              AND FiscalYear = @lt_acdoca-FiscalYear
              AND AccountingDocument = @lt_acdoca-AccountingDocument
*                AND ( Ledger = '0L' OR Ledger = '' )
              INTO TABLE @DATA(lt_amount).

          LOOP AT lt_acdoca INTO DATA(ls_acdoca).
            APPEND INITIAL LINE TO gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
            MOVE-CORRESPONDING ls_acdoca TO <fs_data>.
            READ TABLE lt_log INTO DATA(ls_log) WITH KEY journalentry = ls_acdoca-AccountingDocument fiscalyear = ls_acdoca-FiscalYear companycode = ls_acdoca-CompanyCode BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_data>-SoDeNghi = ls_log-sodenghi.
            ENDIF.

            <fs_data>-JournalEntry = ls_acdoca-AccountingDocument.
            IF ls_acdoca-ClearingJournalEntry IS INITIAL.
              <fs_data>-OpenItemTXT = 'Yes'.
            ELSE.
              <fs_data>-OpenItemTXT = 'No'.
            ENDIF.
            IF ls_acdoca-itemtxt IS INITIAL.
              <fs_data>-DienGiai = ls_acdoca-headertxt.
            ELSE.
              <fs_data>-DienGiai = ls_acdoca-itemtxt.
            ENDIF.
            <fs_data>-DienGiai = |Thanh toán { <fs_data>-DienGiai }|.

*        chỉ lấy ký tự sau dấu #
            FIND '#' IN ls_acdoca-DocumentReferenceID.
            IF sy-subrc = 0.
              DATA: lw_split TYPE string.
              SPLIT ls_acdoca-DocumentReferenceID AT '#' INTO lw_split ls_acdoca-DocumentReferenceID .
            ENDIF.

            <fs_data>-Reference = ls_acdoca-DocumentReferenceID.

            <fs_data>-Currency = ls_acdoca-TransactionCurrency.

            LOOP AT lt_amount INTO DATA(ls_amount) WHERE AccountingDocument = ls_acdoca-AccountingDocument
                                                     AND FiscalYear         = ls_acdoca-FiscalYear
                                                     AND CompanyCode        = ls_acdoca-CompanyCode.
              IF ls_amount-GLAccount+0(3) = '133' OR ls_amount-GLAccount+0(3) = '333' .
                <fs_data>-VATAmount = <fs_data>-VATAmount + ls_amount-AmountInTransactionCurrency.
              ENDIF.
              IF ls_acdoca-AccountingDocumentCategory = 'S'.
                <fs_data>-TotalAmount = <fs_data>-TotalAmount + abs( ls_amount-AmountInTransactionCurrency ).
              ELSE.
                IF ls_amount-DebitCreditCode = 'S'.
                  <fs_data>-TotalAmount = <fs_data>-TotalAmount + ls_amount-AmountInTransactionCurrency.
                ENDIF.
              ENDIF.
            ENDLOOP.
            <fs_data>-TotalAmount = abs( <fs_data>-TotalAmount ).
            <fs_data>-VATAmount = abs( <fs_data>-VATAmount ).
            <fs_data>-NetAmount = <fs_data>-TotalAmount - <fs_data>-VATAmount.
          ENDLOOP.
        ENDIF.



*        IF o_ngaydn IS INITIAL.
*          o_ngaydn = sy-datum.
*        ENDIF.
*        IF o_hanht IS INITIAL.
*          o_hanht = sy-datum.
*        ENDIF.
*        IF o_time IS INITIAL.
*          o_time = sy-datum.
*        ENDIF.




        LOOP AT gt_data ASSIGNING <fs_data>.
          <fs_data>-NgayDeNghi = o_ngaydn.
          <fs_data>-HanThanhToan = o_hanht.
          <fs_data>-ThoiGianTH = o_time.
          <fs_data>-NguoiDeNghi = o_nguoidn.
          <fs_data>-NguoiLap = o_nguoilap.
          <fs_data>-KeToan = o_ketoan.
          <fs_data>-KeToanTRuong = o_ktt.
          <fs_data>-GiamDoc = o_gd.
          <fs_data>-TongGIamDoc = o_tgd.
          <fs_data>-PhongBan = o_phong.
          <fs_data>-BanKiemSoat = o_banks.
          IF o_nguoidn IS INITIAL.
            SELECT SINGLE * FROM I_BusinessPartner
                        WHERE BusinessPartner = @sy-uname+2(10)
                        INTO @DATA(ls_user).
            <fs_data>-NguoiDeNghi = ls_user-BusinessPartnerFullName.
          ENDIF.


          lo_common_app->get_bp_name(
            EXPORTING
              i_businesspartner = <fs_data>-Supplier
              i_bptype          = 'S'
            CHANGING
              o_bpname          = <fs_data>-SupplierName
          ).

          lo_common_app->get_bp_name(
            EXPORTING
              i_businesspartner = <fs_data>-Customer
              i_bptype          = 'C'
            CHANGING
              o_bpname          = <fs_data>-CustomerName
          ).

          <fs_data>-Net = <fs_data>-NetAmount.
          <fs_data>-vat = <fs_data>-VATAmount.
          <fs_data>-total = <fs_data>-TotalAmount.

        ENDLOOP.


*          export data
        IF ls_page_info-page_size < 0.
          ls_page_info-page_size = 50.
        ENDIF.

        DATA(max_rows) = COND #( WHEN ls_page_info-page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                   ELSE ls_page_info-page_size ).

        max_rows = ls_page_info-page_size + ls_page_info-offset.

        LOOP AT gt_data INTO DATA(ls_data).
          IF sy-tabix > ls_page_info-offset.
            IF sy-tabix > max_rows.
              EXIT.
            ELSE.
              APPEND ls_data TO lt_data.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( gt_data ) ).
        ENDIF.

        IF io_request->is_data_requested( ).
          io_response->set_data( lt_data ).
        ENDIF.
      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

        RAISE EXCEPTION TYPE zcl_get_dntt
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

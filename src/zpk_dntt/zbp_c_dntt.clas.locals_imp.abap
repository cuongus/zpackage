CLASS lhc_ZC_DNTT DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zc_dntt RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zc_dntt RESULT result.

    METHODS btnSaveDoc FOR MODIFY
      IMPORTING keys FOR ACTION zc_dntt~btnSaveDoc RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zc_dntt RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zc_dntt.

    METHODS btnPrintPDF FOR MODIFY
      IMPORTING keys FOR ACTION zc_dntt~btnPrintPDF RESULT result.

    METHODS btnDisplayPDF FOR MODIFY
      IMPORTING keys FOR ACTION zc_dntt~btnDisplayPDF RESULT result.

    METHODS create_doc FOR MODIFY
      IMPORTING keys FOR ACTION zc_dntt~create_doc.

*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE zc_dntt.

ENDCLASS.

CLASS lhc_ZC_DNTT IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

*  METHOD delete.
*    READ TABLE keys INTO DATA(key) INDEX 1.
*  ENDMETHOD.

  METHOD btnSaveDoc.
    READ TABLE keys INDEX 1 INTO DATA(k).
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_range TYPE TABLE OF ty_range_option.

    DATA: lt_para TYPE TABLE OF zst_dntt_para,
          ls_para TYPE zSt_dntt_para,
          ir_doc  TYPE tt_range,
          ir_year TYPE tt_range,
          ir_cc   TYPE tt_range,
          ir_sup  TYPE tt_range,
          ir_cus  TYPE tt_range,
          ir_op   TYPE tt_range.


    SPLIT k-%param-CompanyCode AT ',' INTO TABLE DATA(lt_split).
    LOOP AT lt_split INTO DATA(l_string).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_cc.
    ENDLOOP.

    FREE: lt_split.
    SPLIT k-%param-JournalEntry AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO l_string.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_doc.
    ENDLOOP.

    FREE: lt_split.
    SPLIT k-%param-FiscalYear AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO l_string.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_year.
    ENDLOOP.

    FREE: lt_split.
    SPLIT k-%param-Customer AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO l_string.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_cus.
    ENDLOOP.

    FREE: lt_split.
    SPLIT k-%param-Supplier AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO l_string.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_sup.
    ENDLOOP.

    FREE: lt_split.
    SPLIT k-%param-OpenItemTXT AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO l_string.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_op.
    ENDLOOP.

    LOOP AT ir_cc INTO DATA(ls_range).
*      APPEND INITIAL LINE TO lt_para ASSIGNING FIELD-SYMBOL(<fs_para>).
      DATA(lw_index) = sy-tabix.
      ls_para-companycode = ls_range-low.
      READ TABLE ir_doc INTO ls_range INDEX lw_index.
      IF sy-subrc = 0.
        ls_para-journalentry = ls_range-low.
        ls_para-journalentry = |{ ls_para-journalentry ALPHA = IN }|.
      ENDIF.
      READ TABLE ir_year INTO ls_range INDEX lw_index.
      IF sy-subrc = 0.
        ls_para-fiscalyear = ls_range-low.
      ENDIF.

      READ TABLE ir_cus INTO ls_range INDEX lw_index.
      IF sy-subrc = 0.
        ls_para-customer = ls_range-low.
        ls_para-customer = |{ ls_para-customer ALPHA = IN }|.
      ENDIF.

      READ TABLE ir_sup INTO ls_range INDEX lw_index.
      IF sy-subrc = 0.
        ls_para-supplier = ls_range-low.
        ls_para-supplier = |{ ls_para-supplier ALPHA = IN }|.
      ENDIF.

      READ TABLE ir_op INTO ls_range INDEX lw_index.
      IF sy-subrc = 0.
        ls_para-openitemtxt = ls_range-low.
      ENDIF.

      APPEND ls_para TO lt_para.
      CLEAR: ls_para.
    ENDLOOP.

    IF k-%param-NgayDeNghi NE 'null' AND k-%param-NgayDeNghi NE '--'.
      DATA(lw_ngaydenghi) = |{ k-%param-NgayDeNghi+0(4) }{ k-%param-NgayDeNghi+5(2) }{ k-%param-NgayDeNghi+8(2) }|.
    ELSE.
      lw_ngaydenghi = '00000000'.
    ENDIF.
    IF k-%param-HanThanhToan NE 'null' AND k-%param-HanThanhToan NE '--'..
      DATA(lw_hanthanhtoan) = |{ k-%param-HanThanhToan+0(4) }{ k-%param-HanThanhToan+5(2) }{ k-%param-HanThanhToan+8(2) }|.
    ELSE.
      lw_hanthanhtoan = '00000000'.
    ENDIF.
    IF k-%param-ThoiGianTH NE 'null' AND k-%param-ThoiGianTH NE '--'.
      DATA(lw_thoigianTH) = |{ k-%param-ThoiGianTH+0(4) }{ k-%param-ThoiGianTH+5(2) }{ k-%param-ThoiGianTH+8(2) }|.
    ELSE.
      lw_thoigianTH = '00000000'.
    ENDIF.
    IF k-%param-NguoiDeNghi NE 'null'.
      DATA(lw_nguoidenghi) = k-%param-NguoiDeNghi.
    ENDIF.
    IF k-%param-PhongBan NE 'null'.
      DATA(lw_phongban) = k-%param-PhongBan.
    ENDIF.
    IF k-%param-NguoiLap NE 'null'.
      DATA(lw_nguoilap) = k-%param-NguoiLap.
    ENDIF.
    IF k-%param-KeToan NE 'null'.
      DATA(lw_ketoan) = k-%param-KeToan.
    ENDIF.
    IF k-%param-KeToanTruong NE 'null'.
      DATA(lw_ketoantruong) = k-%param-KeToanTruong.
    ENDIF.
    IF k-%param-BanKiemSoat NE 'null'.
      DATA(lw_bks) = k-%param-BanKiemSoat.
    ENDIF.
    IF k-%param-GIamDoc NE 'null'.
      DATA(lw_gd) = k-%param-GIamDoc.
    ENDIF.
    IF k-%param-TongGIamDoc NE 'null'.
      DATA(lw_tgd) = k-%param-TongGIamDoc.
    ENDIF.


    SELECT
        h~AccountingDocument,
        h~FiscalYear,
        h~CompanyCode,
        h~DocumentReferenceID,
        h~PostingDate,
        h~TransactionCurrency,
        d~paymentmethod
        FROM I_JournalEntry AS h
    INNER JOIN I_OperationalAcctgDocItem AS d
    ON h~AccountingDocument = d~AccountingDocument
    AND h~FiscalYear = d~FiscalYear
    AND h~CompanyCode = d~CompanyCode
        FOR ALL ENTRIES IN @lt_para
        WHERE h~AccountingDocument = @lt_para-journalentry
        AND h~FiscalYear = @lt_para-fiscalyear
        AND h~CompanyCode = @lt_para-companycode
        AND ( h~Ledger = '0L' OR h~Ledger = '' )
        INTO TABLE @DATA(lt_acdoca) .
    SORT lt_acdoca BY AccountingDocument FiscalYear CompanyCode.

    DATA: lt_data TYPE TABLE OF ztb_dntt.
    LOOP AT lt_para ASSIGNING FIELD-SYMBOL(<fs_para>).

      READ TABLE lt_acdoca INTO DATA(ls_Acdoca) WITH KEY AccountingDocument = <fs_para>-journalentry CompanyCode = <fs_para>-companycode FiscalYear = <fs_para>-fiscalyear BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_para>-paymentmethod = ls_acdoca-PaymentMethod.
        <fs_para>-currency = ls_acdoca-TransactionCurrency.
        <fs_para>-postingdate = ls_acdoca-PostingDate.
        <fs_para>-reference = ls_acdoca-DocumentReferenceID.
      ENDIF.
    ENDLOOP.
    SORT lt_para BY customer supplier currency companycode fiscalyear journalentry.
    DATA: ev_num TYPE n LENGTH 20.
    DATA: lv_sodn TYPE zde_sodn,
          lv_tmp  TYPE n LENGTH 6.
    DATA: lv_string TYPE string.
    LOOP AT lt_para INTO DATA(ls_tmp).
      AT NEW currency.
        TRY.
            CLEAR: lv_sodn, lv_tmp.
            cl_numberrange_runtime=>number_get(
              EXPORTING
                object          = 'ZNR_SODN'
                nr_range_nr     = '1'
                toyear         = sy-datum+0(4)
                quantity        = 1
              IMPORTING
                number          = ev_num
            ).
            lv_tmp = ev_num.
            lv_sodn = |{ sy-datum+0(4) }{ lv_tmp }|.

            IF lv_string IS INITIAL.
              lv_string = lv_sodn.
            ELSE.
              lv_sodn = |{ lv_string }, { lv_sodn }|.
            ENDIF.

          CATCH cx_number_ranges INTO DATA(lx_obj).
            DATA(error) = lx_obj->get_longtext( ).
        ENDTRY.
      ENDAT.
      APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<fs_Data>).
      MOVE-CORRESPONDING ls_tmp TO <fs_data>.
      <fs_data>-sodenghi = lv_sodn.
      <fs_data>-NgayDeNghi = lw_ngaydenghi.
      <fs_data>-HanThanhToan = lw_hanthanhtoan.
      <fs_data>-ThoiGianTH = lw_thoigianth.
      <fs_data>-NguoiDeNghi = lw_nguoidenghi.
      <fs_data>-NguoiLap = lw_nguoilap.
      <fs_data>-KeToan = lw_ketoan.
      <fs_data>-KeToanTRuong = lw_ketoantruong.
      <fs_data>-GiamDoc = lw_gd.
      <fs_data>-TongGIamDoc = lw_tgd.
      <fs_data>-PhongBan = lw_phongban.
      <fs_data>-BanKiemSoat = lw_bks.
    ENDLOOP.
    DATA: flg_e TYPE char1.

    zcl_behavior_dntt=>get_data_save(
      EXPORTING
        it_data = lt_data
      IMPORTING
        flg_e   = flg_e
    ).

    IF lv_string IS NOT INITIAL.
      lv_string = |Tạo thành công số đề nghị { lv_string }|.
    ENDIF.

    result = VALUE #(
                    FOR key IN keys (

                    %cid   = k-%cid
                    %param = VALUE #( filecontent   = lv_string
                                      filename      = flg_e
                                      fileextension = 'pdf'
                                      mimetype      = 'application/pdf'
                                      )
                    )
                    ).

*    APPEND VALUE #( %msg = new_message_with_text(
*    severity = if_abap_behv_message=>severity-success
*    text     = |Hoàn thành, Kiểm tra lại kết quả!|
*    ) ) TO reported-zc_dntt.

  ENDMETHOD.

  METHOD btnPrintPDF.
    zcl_dntt_core=>btnprintpdf(
          EXPORTING
            keys     = keys
*      IMPORTING
*        O_PDF    = LV_FILE_CONTENT
          CHANGING
            result   = result
            mapped   = mapped
            failed   = failed
            reported = reported
        ).
  ENDMETHOD.

  METHOD btnDisplayPDF.
    zcl_dntt_core=>btndisplaypdf(
          EXPORTING
            keys     = keys
*      IMPORTING
*        O_PDF    = LV_FILE_CONTENT
          CHANGING
            result   = result
            mapped   = mapped
            failed   = failed
            reported = reported
        ).
  ENDMETHOD.

  METHOD create_doc.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZC_DNTT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZC_DNTT IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    zcl_behavior_dntt=>save_data_db( ).
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

CLASS zcl_get_data_scttk DEFINITION
  PUBLIC
  INHERITING FROM cx_rap_query_provider
*  FINAL
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
           tt_data  TYPE TABLE OF zce_jp_dd_scttk.

    DATA: p_cantru TYPE char05.

    CLASS-DATA: gt_data_pre TYPE TABLE OF zce_jp_dd_scttk,
                gt_data     TYPE TABLE OF zce_jp_dd_scttk,
                gt_detail   TYPE TABLE OF zce_jp_dd_scttk,
                gs_data     TYPE zce_jp_dd_scttk,
                gs_data_pre TYPE zce_jp_dd_scttk,
                gs_detail   TYPE zce_jp_dd_scttk,
                gw_bukrs    TYPE bukrs,
                gs_bukrs    TYPE zst_companycode_info.
    CLASS-DATA: gw_budat_pre TYPE I_JournalEntry-PostingDate,
                gw_SoDK      TYPE dmbtr.

    CLASS-DATA:
      "Instance Singleton
      mo_instance
      TYPE REF TO zcl_get_data_scttk.

    CLASS-METHODS:
      "Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_get_data_scttk,

      get_parameter IMPORTING ir_date   TYPE tt_range
                              ir_cantru TYPE tt_range
                    EXPORTING period    TYPE monat
                              gjahr     TYPE I_JournalEntry-FiscalYear
                              budat_pre TYPE I_JournalEntry-PostingDate
                              can_tru   TYPE char05,

      get_data_scttk IMPORTING ir_bukrs  TYPE tt_range
                               ir_racct  TYPE tt_range
                               ir_date   TYPE tt_range
                               ir_cantru TYPE tt_range
                     EXPORTING gt_data   TYPE tt_data.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_get_data_scttk IMPLEMENTATION.


  METHOD get_data_scttk.

    DATA: p_cantru TYPE char05,
          ir_rldnr TYPE tt_range,
          gw_hso   TYPE numc4.
    DATA(lo_scttk)  = zcl_get_data_scttk=>get_instance( ).

    DATA(lo_common_app) = zcl_get_fillter_scttk=>get_instance( ).

    DATA(lo_comcode) = zcl_jp_common_core=>get_instance(  ).

    lo_scttk->get_parameter(
      EXPORTING
        ir_date  = ir_date
        ir_cantru = ir_cantru
      IMPORTING
        budat_pre = gw_budat_pre
        can_tru   = p_cantru
    ).

    CLEAR: gt_data[], gt_detail[].

    DATA: ls_rldnr TYPE LINE OF tt_range.
    ls_rldnr-option = 'EQ'.
    ls_rldnr-sign = 'I'.

    ls_rldnr-low = '0L'.
    APPEND ls_rldnr TO ir_rldnr.

    ls_rldnr-low = ''.
    APPEND ls_rldnr TO ir_rldnr.

    READ TABLE ir_bukrs INTO DATA(ls_bukrs) INDEX 1.
    IF sy-subrc = 0.
      gw_bukrs = ls_bukrs-low.
    ENDIF.
    lo_comcode->get_companycode_details(
      EXPORTING
        i_companycode = gw_bukrs
      IMPORTING
        o_companycode = gs_bukrs
    ).


    "lấy currency code của bukrs
    SELECT SINGLE currency
         FROM I_CompanyCode
         WITH PRIVILEGED ACCESS
         WHERE CompanyCode IN @ir_bukrs
         INTO @DATA(gw_curr).
    IF gw_curr = 'VND'.
      gw_hso = 100.
    ELSE.
      gw_hso = 1.
    ENDIF.


*        get data i_operationalacctgdocitem
    SELECT
      headers~CompanyCode AS bukrs,
      headers~AccountingDocument AS belnr,
      headers~FiscalYear AS gjahr,
      headers~AccountingDocumentType AS blart,
      headers~accountingdocumentheadertext,
      items~LedgerGLLineItem AS buzei,
      items~glaccount AS racct,
      items~AmountInCompanyCodeCurrency AS dmbtr,
      items~PostingDate AS budat,
      items~DocumentDate AS bldat,
      items~DebitCreditCode AS shkzg,
      item1~IsNegativePosting AS xnegp,
      items~DocumentItemText AS sgtxt,
      items~yy1_text2_cob AS addtext2,
      headers~IsReversal,
      headers~IsReversed,
      headers~ReverseDocument,
      items~Customer AS kunnr,
      items~Supplier AS lifnr,
      items~FinancialAccountType,
      headers~ReferenceDocumentType AS awtyp,
      headers~DocumentReferenceID
*        FROM i_operationalacctgdocitem AS items
    FROM I_JournalEntryItem AS items

    INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                        AND items~AccountingDocument = headers~AccountingDocument
                                        AND items~FiscalYear         = headers~FiscalYear
    LEFT JOIN i_operationalacctgdocitem AS item1 ON item1~CompanyCode        = items~CompanyCode
                                                          AND item1~AccountingDocument = items~AccountingDocument
                                                          AND item1~FiscalYear         = items~FiscalYear
                                                          AND item1~AccountingDocumentItem = items~AccountingDocumentItem

    WHERE headers~CompanyCode          IN  @ir_bukrs
      AND items~PostingDate            IN  @ir_date
      AND headers~LedgerGroup              IN  @ir_rldnr
      AND items~Ledger                    IN @ir_rldnr
      AND items~GLAccount              IN  @ir_racct
      AND headers~AccountingDocumentType <> 'CO'
      INTO TABLE @DATA(gt_acdoca)
      OPTIONS PRIVILEGED ACCESS.


    "lay so dau ky cua racct
    SELECT
      headers~CompanyCode AS bukrs,
      headers~AccountingDocument AS belnr,
      headers~FiscalYear AS gjahr,
*      headers~accountingdocumentheadertext,
      items~glaccount AS racct,
      items~AmountInCompanyCodeCurrency AS dmbtr,
      items~PostingDate AS budat,
      items~DocumentDate AS bldat,
      items~DebitCreditCode AS shkzg,
      item1~IsNegativePosting AS xnegp,
      items~DocumentItemText AS sgtxt

*        FROM i_operationalacctgdocitem AS items
    FROM I_JournalEntryItem AS items
    INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                        AND items~AccountingDocument = headers~AccountingDocument
                                        AND items~FiscalYear         = headers~FiscalYear
    LEFT JOIN i_operationalacctgdocitem AS item1 ON item1~CompanyCode        = items~CompanyCode
                                                          AND item1~AccountingDocument = items~AccountingDocument
                                                          AND item1~FiscalYear         = items~FiscalYear
                                                          AND item1~AccountingDocumentItem = items~AccountingDocumentItem
    WHERE headers~CompanyCode          IN  @ir_bukrs
      AND items~PostingDate            <=  @gw_budat_pre
      AND headers~LedgerGroup               IN  @ir_rldnr
      AND items~Ledger                    IN @ir_rldnr
      AND items~GLAccount              IN  @ir_racct
      AND headers~AccountingDocumentType <> 'CO'
      INTO TABLE @DATA(gt_data_pre)
      OPTIONS PRIVILEGED ACCESS.

    CLEAR: gw_SoDK.
    LOOP AT gt_data_pre INTO DATA(gs_data_pre).
      IF gs_data_pre-shkzg = 'S'.
        gw_SoDK = gw_SoDK + gs_data_pre-dmbtr * gw_hso.
      ELSE.
        gw_SoDK = gw_SoDK - gs_data_pre-dmbtr * gw_hso * -1.
      ENDIF.
    ENDLOOP.

    IF p_cantru = 'X'.
      DATA(lt_acdoca) = gt_acdoca[].
      SORT lt_acdoca BY belnr gjahr bukrs racct kunnr lifnr.
      DELETE ADJACENT DUPLICATES FROM lt_acdoca COMPARING belnr gjahr bukrs racct kunnr lifnr.
      DELETE lt_acdoca WHERE FinancialAccountType <> 'K' AND FinancialAccountType <> 'D'.
      LOOP AT lt_acdoca INTO DATA(ls_loai).
        LOOP AT gt_acdoca INTO DATA(ls_ctu) WHERE bukrs = ls_loai-bukrs
                                        AND belnr = ls_loai-belnr
                                        AND gjahr = ls_loai-gjahr
                                        AND racct = ls_loai-racct
                                        AND kunnr = ls_loai-kunnr
                                        AND lifnr = ls_loai-lifnr
                                        AND shkzg <> ls_loai-shkzg.
          EXIT.
        ENDLOOP.
        IF sy-subrc = 0.
          DELETE gt_acdoca WHERE bukrs = ls_loai-bukrs
                                        AND belnr = ls_loai-belnr
                                        AND gjahr = ls_loai-gjahr
                                        AND racct = ls_loai-racct.
        ENDIF.
      ENDLOOP.
*          case acount type = S
      lt_acdoca = gt_acdoca[].
      DELETE ADJACENT DUPLICATES FROM lt_acdoca COMPARING belnr gjahr bukrs racct.
      DELETE lt_acdoca WHERE FinancialAccountType <> 'S'.
      LOOP AT lt_acdoca INTO ls_loai.
        LOOP AT gt_acdoca INTO ls_ctu WHERE bukrs = ls_loai-bukrs
                                        AND belnr = ls_loai-belnr
                                        AND gjahr = ls_loai-gjahr
                                        AND racct = ls_loai-racct
                                        AND shkzg <> ls_loai-shkzg.
          EXIT.
        ENDLOOP.
        IF sy-subrc = 0.
          DELETE gt_acdoca WHERE bukrs = ls_loai-bukrs
                                        AND belnr = ls_loai-belnr
                                        AND gjahr = ls_loai-gjahr
                                        AND racct = ls_loai-racct.
        ENDIF.
      ENDLOOP.

    ENDIF.


    "loai ctu huy
    LOOP AT gt_acdoca INTO DATA(ls_acdoca).
      IF ls_acdoca-awtyp = 'RMRP'.
        LOOP AT gt_acdoca INTO DATA(ls_rev) WHERE belnr <> ls_acdoca-belnr AND gjahr = ls_acdoca-gjahr AND DocumentReferenceID = ls_acdoca-DocumentReferenceID.

          DELETE gt_acdoca WHERE belnr = ls_acdoca-belnr AND gjahr = ls_acdoca-gjahr AND bukrs = ls_acdoca-bukrs.
          DELETE gt_acdoca WHERE belnr = ls_rev-belnr AND gjahr = ls_rev-gjahr AND bukrs = ls_rev-bukrs.
          EXIT.
        ENDLOOP.
*      ELSEIF ls_acdoca-awtyp = 'AUAK' OR ls_acdoca-awtyp = 'MKPF'.
      ELSE.
        IF ls_acdoca-IsReversed IS NOT INITIAL.
          READ TABLE gt_acdoca INTO ls_rev WITH KEY ReverseDocument = ls_acdoca-belnr gjahr = ls_acdoca-gjahr IsReversal = 'X'.
          IF sy-subrc = 0.
            DELETE gt_acdoca WHERE belnr = ls_acdoca-belnr AND gjahr = ls_acdoca-gjahr AND bukrs = ls_acdoca-bukrs.
            DELETE gt_acdoca WHERE belnr = ls_rev-belnr AND gjahr = ls_rev-gjahr AND bukrs = ls_rev-bukrs..
          ENDIF.
        ENDIF.
*

      ENDIF.
    ENDLOOP.


*        tach doi ung
*lay tu zfirud_cf_off
    IF gt_acdoca[] IS NOT INITIAL.
      SELECT * FROM zfirud_cf_off
         WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @gt_acdoca
         WHERE bukrs = @gt_acdoca-bukrs
         AND belnr = @gt_acdoca-belnr
         AND gjahr = @gt_acdoca-gjahr
         AND rldnr IN @ir_rldnr
         AND racct IN @ir_racct
         INTO TABLE @DATA(lt_cf_off).
      IF sy-subrc = 0.
        SELECT * FROM zfirud_cf_off
        WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_cf_off
            WHERE bukrs = @lt_cf_off-bukrs
         AND belnr = @lt_cf_off-belnr
         AND gjahr = @lt_cf_off-gjahr
         AND offs_item = @lt_cf_off-docln
         INTO TABLE @DATA(gt_cf_off).
      ENDIF.

      SELECT companycode AS bukrs,
             AccountingDocument AS belnr,
             fiscalyear AS gjahr,
             ledgergllineitem AS docln,
             OffsettingLedgerGLLineItem AS offs_item,
             AmountInCompanyCodeCurrency AS hsl,
             glaccount AS racct,
             DocumentItemText AS sgtxt
             FROM I_GLAccountLineItem
             WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @gt_acdoca
             WHERE CompanyCode = @gt_acdoca-bukrs
             AND Ledger IN @ir_rldnr
             AND FiscalYear = @gt_acdoca-gjahr
             AND AccountingDocument = @gt_acdoca-belnr
             AND OffsettingLedgerGLLineItem = @gt_acdoca-buzei
             INTO TABLE @DATA(gt_glitem).

    ENDIF.

    SORT gt_acdoca BY budat bldat belnr.

    DATA(lt_typezp) = gt_acdoca[].
    DELETE lt_typezp WHERE blart <> 'ZP'.
    SORT lt_typezp BY bukrs belnr gjahr.
    DELETE ADJACENT DUPLICATES FROM lt_typezp COMPARING bukrs belnr gjahr.

    IF lt_typezp[] IS NOT INITIAL.
      SELECT
            headers~CompanyCode AS bukrs,
            headers~AccountingDocument AS belnr,
            headers~FiscalYear AS gjahr,
            headers~DocumentReferenceID,
            items~ClearingJournalEntry,
            items~AssignmentReference,
            headers~AccountingDocumentCategory,
            items~LedgerGLLineItem AS lineItem
          FROM I_JournalEntryItem AS items

          INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                              AND items~AccountingDocument = headers~AccountingDocument
                                              AND items~FiscalYear         = headers~FiscalYear
          FOR ALL ENTRIES IN @lt_typezp
          WHERE headers~CompanyCode          IN  @ir_bukrs
            AND headers~LedgerGroup              IN  @ir_rldnr
            AND items~Ledger                    IN @ir_rldnr
            AND items~ClearingJournalEntry = @lt_typezp-belnr
            AND items~ClearingDate = @lt_typezp-budat
            AND headers~AccountingDocumentType <> 'ZP'
            INTO TABLE @DATA(lt_clear).

      SELECT
      headers~CompanyCode AS bukrs,
      headers~AccountingDocument AS belnr,
      headers~FiscalYear AS gjahr,
      headers~DocumentReferenceID,
      items~ClearingJournalEntry,
      items~AssignmentReference,
      headers~AccountingDocumentCategory,
      items~AccountingDocumentItem AS lineItem
    FROM I_OperationalAcctgDocItem AS items

    INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                        AND items~AccountingDocument = headers~AccountingDocument
                                        AND items~FiscalYear         = headers~FiscalYear
    FOR ALL ENTRIES IN @lt_typezp
    WHERE headers~CompanyCode          IN  @ir_bukrs
      AND headers~LedgerGroup              IN  @ir_rldnr
*        AND items~                    IN @ir_rldnr
      AND items~ClearingJournalEntry = @lt_typezp-belnr
      AND items~ClearingDate = @lt_typezp-budat
      AND headers~AccountingDocumentType <> 'ZP'
      APPENDING TABLE @lt_clear.
    ENDIF.
*    lay dien giai
    DATA: lw_diengiai TYPE c LENGTH 255.
    LOOP AT gt_acdoca ASSIGNING FIELD-SYMBOL(<fs_acdoca>) WHERE blart = 'RE' OR blart = 'ZP' OR blart = 'RV'.
      MOVE-CORRESPONDING <fs_acdoca> TO ls_acdoca.
      AT NEW gjahr.
        CLEAR: lw_diengiai.
        IF ls_acdoca-blart = 'RE' OR ls_acdoca-blart = 'RV'.
          LOOP AT gt_acdoca INTO DATA(ls_tmp) WHERE bukrs = ls_acdoca-bukrs AND belnr = ls_acdoca-belnr AND gjahr = ls_acdoca-gjahr
                                                AND ( sgtxt IS NOT INITIAL OR addtext2 IS NOT INITIAL ).
            lw_diengiai = |{ ls_tmp-sgtxt } { ls_tmp-addtext2 }| .
            CONDENSE lw_diengiai.
            EXIT.
          ENDLOOP.
        ELSE.
          LOOP AT lt_clear INTO DATA(ls_clear) WHERE ClearingJournalEntry = ls_acdoca-belnr.
            IF ls_clear-AccountingDocumentCategory = 'S'.
              IF ls_clear-AssignmentReference IS NOT INITIAL.
                IF lw_diengiai IS INITIAL.
                  lw_diengiai = ls_clear-AssignmentReference.
                ELSE.
                  lw_diengiai = |{ lw_diengiai }, { ls_clear-AssignmentReference }|.
                ENDIF.
              ENDIF.
            ELSE.
              lw_diengiai = ls_clear-DocumentReferenceID.
            ENDIF.
          ENDLOOP.
          IF ls_clear-AccountingDocumentCategory = 'S'.
            lw_diengiai = |Thanh toán cho bill số { lw_diengiai }|.
          ELSE.
            lw_diengiai = |Thanh toán cho HĐ số { lw_diengiai }|.
          ENDIF.
        ENDIF.
      ENDAT.

      IF <fs_acdoca>-blart = 'ZP'.
        <fs_acdoca>-sgtxt = lw_diengiai.
      ELSE.
        IF <fs_acdoca>-sgtxt IS INITIAL.
          <fs_acdoca>-sgtxt = lw_diengiai.
        ENDIF.
      ENDIF.

    ENDLOOP.

    LOOP AT gt_acdoca ASSIGNING <fs_acdoca> WHERE blart <> 'RE' AND blart <> 'ZP' AND blart <> 'RV'.
      IF <fs_acdoca>-sgtxt IS NOT INITIAL OR <fs_acdoca>-addtext2 IS NOT INITIAL.
        <fs_acdoca>-sgtxt = |{ <fs_acdoca>-sgtxt } { <fs_acdoca>-addtext2 }| .
        CONDENSE <fs_acdoca>-sgtxt.
      ENDIF.
    ENDLOOP.


    LOOP AT gt_acdoca INTO ls_acdoca ."into data(gs_data).
      LOOP AT gt_glitem INTO DATA(gs_glitem) WHERE bukrs = ls_acdoca-bukrs AND belnr = ls_acdoca-belnr AND gjahr = ls_acdoca-gjahr AND offs_item = ls_acdoca-buzei.
        APPEND INITIAL LINE TO gt_data  ASSIGNING FIELD-SYMBOL(<fs_data>).
        MOVE-CORRESPONDING gs_glitem TO <fs_data>.
        <fs_data>-CCname = gs_bukrs-companycodename.
        <fs_data>-CCadrr = gs_bukrs-companycodeaddr.
        <fs_data>-sgtxt = ls_acdoca-sgtxt.

        IF <fs_data>-sgtxt IS INITIAL.
          <fs_data>-sgtxt = ls_acdoca-AccountingDocumentHeaderText.
        ENDIF.

        <fs_data>-hkont = gs_glitem-racct.
        <fs_data>-budat = ls_acdoca-budat.
*        <fs_data>-bldat = ls_acdoca-bldat.
*        <fs_data>-blart = ls_acdoca-blart.
        <fs_data>-SoDK = gw_SoDK.
        IF ls_acdoca-shkzg = 'S'.
          <fs_data>-PsNo = gs_glitem-hsl * gw_hso * - 1.
        ELSE.
          <fs_data>-PsCo = gs_glitem-hsl * gw_hso.
        ENDIF.
        <fs_data>-SoCK = <fs_data>-SoDK + <fs_data>-PsNo - <fs_data>-PsCo.
        IF <fs_data>-SoCK > 0.
          <fs_data>-DuNo = <fs_data>-SoCK.
        ELSE.
          <fs_data>-DuCo = <fs_data>-SoCK * -1.
        ENDIF.
        gw_SoDK = <fs_data>-SoCK.
      ENDLOOP.
      IF sy-subrc <> 0.
        LOOP AT lt_cf_off INTO DATA(ls_doiung) WHERE bukrs = ls_acdoca-bukrs AND belnr = ls_acdoca-belnr AND gjahr = ls_acdoca-gjahr AND racct = ls_acdoca-racct.
          LOOP AT gt_cf_off INTO DATA(ls_cf_off) WHERE  bukrs = ls_acdoca-bukrs AND belnr = ls_acdoca-belnr AND gjahr = ls_acdoca-gjahr AND offs_item = ls_doiung-docln.
            APPEND INITIAL LINE TO gt_data  ASSIGNING <fs_data>.
            MOVE-CORRESPONDING ls_cf_off TO <fs_data>.
            <fs_data>-CCname = gs_bukrs-companycodename.
            <fs_data>-CCadrr = gs_bukrs-companycodeaddr.
            <fs_data>-sgtxt = ls_acdoca-sgtxt.

            IF <fs_data>-sgtxt IS INITIAL.
              <fs_data>-sgtxt = ls_acdoca-AccountingDocumentHeaderText.
            ENDIF.

            <fs_data>-hkont = ls_cf_off-racct.
            <fs_data>-budat = ls_acdoca-budat.
*            <fs_data>-bldat = ls_acdoca-bldat.
*            <fs_data>-blart = ls_acdoca-blart.
            <fs_data>-SoDK = gw_SoDK.
            IF ls_doiung-drcrk = 'S'.
              <fs_data>-PsNo = ls_cf_off-hsl * gw_hso * - 1.
            ELSE.
              <fs_data>-PsCo = ls_cf_off-hsl * gw_hso.
            ENDIF.
            <fs_data>-SoCK = <fs_data>-SoDK + <fs_data>-PsNo - <fs_data>-PsCo.
            IF <fs_data>-SoCK > 0.
              <fs_data>-DuNo = <fs_data>-SoCK.
            ELSE.
              <fs_data>-DuCo = <fs_data>-SoCK * -1.
            ENDIF.
            gw_SoDK = <fs_data>-SoCK.
          ENDLOOP.
*          không phân biệt đc nên chỉ lấy 1 lần xong xóa
          DELETE gt_acdoca WHERE bukrs = ls_acdoca-bukrs AND belnr = ls_acdoca-belnr AND gjahr = ls_acdoca-gjahr AND racct = ls_acdoca-racct.
        ENDLOOP.
        IF sy-subrc <> 0.
          APPEND INITIAL LINE TO gt_data  ASSIGNING <fs_data>.
          MOVE-CORRESPONDING ls_acdoca TO <fs_data>.
          <fs_data>-CCname = gs_bukrs-companycodename.
          <fs_data>-CCadrr = gs_bukrs-companycodeaddr.
          <fs_data>-SoDK = gw_SoDK.
          IF <fs_data>-shkzg = 'S'.
            <fs_data>-PsNo = <fs_data>-dmbtr * gw_hso.
          ELSE.
            <fs_data>-PsCo = <fs_data>-dmbtr * gw_hso * -1.
          ENDIF.
          <fs_data>-SoCK = <fs_data>-SoDK + <fs_data>-PsNo - <fs_data>-PsCo.
          IF <fs_data>-SoCK > 0.
            <fs_data>-DuNo = <fs_data>-SoCK.
          ELSE.
            <fs_data>-DuCo = <fs_data>-SoCK * -1.
          ENDIF.
          gw_SoDK = <fs_data>-SoCK.
        ENDIF.
      ENDIF.
    ENDLOOP.

    DELETE gt_data WHERE PsCo IS INITIAL AND PsNo IS INITIAL.
  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD get_parameter.

    READ TABLE ir_date INTO DATA(ls_date) INDEX 1.
    budat_pre = |{ ls_date-low - 1 }|.

    READ TABLE ir_cantru INTO DATA(ls_cantru) INDEX 1.
    IF ls_cantru-low = 'X' OR ls_cantru-low = 'true'.
      can_tru = 'X'.
    ENDIF.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
**--- Custom Entities ---**
    DATA: ls_page_info TYPE zcl_get_fillter_scttk=>st_page_info,

          ir_bukrs     TYPE tt_range,
          ir_rldnr     TYPE tt_range,
          ir_racct     TYPE tt_range,
          ir_date      TYPE tt_range,
          ir_cantru    TYPE tt_range,
          ls_glacc     TYPE LINE OF tt_range,
          lr_glacc     TYPE tt_range,
          lr_glac1     TYPE tt_range.
    DATA: lt_data    TYPE TABLE OF zce_jp_dd_scttk,
          lt_data_ct TYPE TABLE OF zce_jp_dd_scttk.
    DATA: gw_hso TYPE numc5.
    FREE: lt_data, lr_glacc.

    TRY.
* Khởi tạo đối tượng
        DATA(lo_scttk)  = zcl_get_data_scttk=>get_instance( ).

        DATA(lo_common_app) = zcl_get_fillter_scttk=>get_instance( ).

        DATA(lo_comcode) = zcl_jp_common_core=>get_instance(  ).

*  Lấy tham số
        lo_common_app->get_fillter_app(   EXPORTING
                                            io_request    = io_request
                                            io_response   = io_response
                                          IMPORTING
                                            ir_bukrs  = ir_bukrs
                                            ir_racct  = ir_racct
                                            ir_date   = ir_date
                                            ir_cantru = ir_cantru
                                            wa_page_info  = ls_page_info
                                        ).

        lo_scttk->get_data_scttk(
          EXPORTING
            ir_bukrs  = ir_bukrs
            ir_racct  = ir_racct
            ir_date   = ir_date
            ir_cantru = ir_cantru
          IMPORTING
            gt_data   = gt_data
        ).


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

        RAISE EXCEPTION TYPE zcl_get_data_scttk
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

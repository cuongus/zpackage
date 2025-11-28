CLASS zcl_data_bclctt_Tt DEFINITION
  PUBLIC
  INHERITING FROM cx_rap_query_provider
*  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "Custom Entities
    INTERFACES if_rap_query_provider.

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_ranges     TYPE TABLE OF ty_range_option,

           tt_BC_LCTT_TT TYPE TABLE OF zc_bc_lctt_tt.

    "Variable
    CLASS-DATA: gt_data TYPE TABLE OF zc_bc_lctt_tt.

    CLASS-DATA: gr_companycode TYPE tt_ranges,
                gr_fiscalyear  TYPE tt_ranges,
                mo_instance    TYPE REF TO zcl_data_bclctt_Tt.

    CLASS-METHODS:
      "Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_data_bclctt_Tt,

      "Method

      "Method Get Data From journal entry
      get_bc_lctt_tt IMPORTING ir_companycode TYPE tt_ranges
                               ir_fiscalyear  TYPE tt_ranges
                               ir_budat       TYPE tt_ranges
                               ir_budat_nt    TYPE tt_ranges
                     EXPORTING it_data        TYPE tt_BC_LCTT_TT.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DATA_BCLCTT_TT IMPLEMENTATION.


  METHOD get_bc_lctt_tt.
    DATA: rt_cf_id    TYPE tt_ranges,
          ls_rt_cf_id TYPE ty_range_option.
    DATA: lt_glaccount TYPE tt_ranges.

    DATA: ls_data LIKE LINE OF it_data.
    DATA(lo_report_processor) = zcl_report_processor=>get_instance( ).
    DATA: ls_report_data TYPE zst_report_data,
          lt_report_data TYPE TABLE OF zst_report_data,
          lt_data_p      TYPE TABLE OF zst_report_data,
          lt_data_tmp    TYPE TABLE OF zst_report_data.

    APPEND INITIAL LINE TO lt_glaccount ASSIGNING FIELD-SYMBOL(<lf_glaccount>).
    <lf_glaccount>-sign = 'I'.
    <lf_glaccount>-option = 'CP'.
    <lf_glaccount>-low = '11*'.

    APPEND INITIAL LINE TO lt_glaccount ASSIGNING <lf_glaccount>.
    <lf_glaccount>-sign = 'I'.
    <lf_glaccount>-option = 'CP'.
    <lf_glaccount>-low = '1281*'.

    ls_rt_cf_id-sign = 'I'.
    ls_rt_cf_id-option = 'CP'.

    lo_report_processor->get_config( EXPORTING i_rp_code = 'ZCF1' IMPORTING et_rp_item = DATA(lt_rp_config) ).

    READ TABLE ir_fiscalyear INTO DATA(ls_fiscalyear) INDEX 1.
    DATA: lw_fiscalyear TYPE zde_numc4.
    lw_fiscalyear = ls_fiscalyear-low.
    SORT lt_rp_config BY item_id.
    LOOP AT lt_rp_config INTO DATA(ls_rp_config).
      ls_rt_cf_id-low = ls_rp_config-item_cond && '*'.
      APPEND ls_rt_cf_id TO rt_cf_id.
    ENDLOOP.

    SELECT
           SUM( items~AmountInCompanyCodeCurrency ) AS AmountInCompanyCodeCurrency,
           items~CompanyCodeCurrency,
           substring( YY1_CashFlow_COB, 1, 2 ) AS YY1_CashFlow_COB
         FROM i_glaccountlineitem AS items
         INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                             AND items~AccountingDocument = headers~AccountingDocument
                                             AND items~FiscalYear         = headers~FiscalYear

         WHERE headers~CompanyCode          IN @ir_companycode
*           AND headers~FiscalYear           IN @ir_fiscalyear
           AND headers~PostingDate IN @ir_budat
           AND substring( items~YY1_CashFlow_COB, 1, 2 ) IN @rt_cf_id
           AND items~YY1_CashFlow_COB <> ''
           AND items~GLAccount IN @lt_glaccount
           AND items~Ledger = '0L'
         GROUP BY substring( YY1_CashFlow_COB, 1, 2 ), items~CompanyCodeCurrency
         INTO TABLE @DATA(lt_data_nn).
    SELECT
        SUM( items~AmountInCompanyCodeCurrency ) AS AmountInCompanyCodeCurrency,
        items~CompanyCodeCurrency,
        substring( YY1_CashFlow_COB, 1, 2 ) AS YY1_CashFlow_COB
      FROM i_glaccountlineitem AS items
      INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                          AND items~AccountingDocument = headers~AccountingDocument
                                          AND items~FiscalYear         = headers~FiscalYear

      WHERE headers~CompanyCode          IN @ir_companycode
*        AND headers~FiscalYear           IN @ir_fiscalyear
        AND headers~PostingDate IN @ir_budat_nt
        AND substring( items~YY1_CashFlow_COB, 1, 2 ) IN @rt_cf_id
        AND items~YY1_CashFlow_COB <> ''
        AND items~GLAccount IN @lt_glaccount
           AND items~Ledger = '0L'
      GROUP BY substring( YY1_CashFlow_COB, 1, 2 ), items~CompanyCodeCurrency
      INTO TABLE @DATA(lt_data_nt).

    SELECT
       SUM( items~AmountInCompanyCodeCurrency ) AS AmountInCompanyCodeCurrency,
       items~CompanyCodeCurrency
     FROM i_glaccountlineitem AS items
     INNER JOIN i_journalentry AS headers ON items~CompanyCode        = headers~CompanyCode
                                         AND items~AccountingDocument = headers~AccountingDocument
                                         AND items~FiscalYear         = headers~FiscalYear

     WHERE headers~CompanyCode          IN @ir_companycode
       AND headers~FiscalYear < @lw_fiscalyear
*       AND substring( items~YY1_CashFlow_COB, 1, 2 ) IN @rt_cf_id
*       AND items~YY1_CashFlow_COB <> ''
       AND items~GLAccount IN @lt_glaccount
          AND items~Ledger = '0L'
     GROUP BY items~CompanyCodeCurrency
     INTO TABLE @DATA(lt_data_dk).
    READ TABLE lt_data_dk INTO DATA(ls_data_dk) INDEX 1.
    LOOP AT lt_rp_config INTO ls_rp_config WHERE item_cond <> ''.
      CLEAR: ls_report_data.
      ls_report_data-item_id = ls_rp_config-item_id.
      ls_report_data-item_code = ls_rp_config-item_code1.

      IF ls_rp_config-item_cond = 'DK'.
        ls_report_data-col1 = ls_data_dk-AmountInCompanyCodeCurrency.
        ls_report_data-currency = ls_data_dk-CompanyCodeCurrency.
      ELSE.
        READ TABLE lt_data_nn INTO DATA(ls_data_nn) WITH KEY YY1_CashFlow_COB = ls_rp_config-item_cond.
        IF sy-subrc IS INITIAL.
          ls_report_data-col1 = ls_data_nn-AmountInCompanyCodeCurrency.
          ls_report_data-currency = ls_data_nn-CompanyCodeCurrency.
        ENDIF.
        READ TABLE lt_data_nt INTO DATA(ls_data_nt) WITH KEY YY1_CashFlow_COB = ls_rp_config-item_cond.
        IF sy-subrc IS INITIAL.
          ls_report_data-col2 = ls_data_nt-AmountInCompanyCodeCurrency.
          ls_report_data-currency = ls_data_nt-CompanyCodeCurrency.
        ENDIF.
      ENDIF.

      COLLECT ls_report_data INTO lt_report_data.
    ENDLOOP.

    DELETE lt_report_data WHERE currency IS INITIAL.
    LOOP AT lt_report_data INTO ls_report_data.
      CLEAR: lt_data_p.
      CALL METHOD lo_report_processor->parent_row( EXPORTING is_row = ls_report_data IMPORTING et_rows = lt_data_p ).
      APPEND LINES OF lt_data_p TO lt_data_tmp.
    ENDLOOP.

    LOOP AT lt_data_tmp INTO ls_report_data.
      COLLECT ls_report_data INTO lt_report_data.
    ENDLOOP.

    LOOP AT lt_rp_config INTO ls_rp_config.
      CLEAR: ls_data.
      ls_data-chi_tieu = ls_rp_config-item_desc.
      CONDENSE ls_data-chi_tieu.
      ls_data-ma_so = ls_rp_config-display_code.
      CONDENSE ls_data-ma_so.
      ls_data-item_id = ls_rp_config-item_id.
      ls_data-Zfont = ls_rp_config-font.
      CONDENSE ls_data-Zfont.
      READ TABLE lt_report_data INTO ls_report_data WITH KEY item_id = ls_rp_config-item_id.
      IF sy-subrc IS INITIAL.
        ls_data-ky_nay = ls_report_data-col1.
        ls_data-ky_truoc = ls_report_data-col2.
        ls_data-currency = ls_report_data-currency.
      ENDIF.
      ls_data-FiscalYear = ir_fiscalyear[ 1 ]-low.

      ls_data-per_fr = ir_budat[ 1 ]-low+4(2).
      ls_data-per_to = ir_budat_nt[ 1 ]-high+4(2).

      APPEND ls_data TO it_data.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD if_rap_query_provider~select.

**--- Custom Entities ---**
    DATA: ls_page_info   TYPE zcl_jp_common_core=>st_page_info,

          ir_companycode TYPE tt_ranges,
          ir_fiscalyear  TYPE tt_ranges,
          lr_budat       TYPE tt_ranges,
          lr_budat_nt    TYPE tt_ranges
          .

    DATA: lt_data TYPE tt_BC_LCTT_TT.
    FREE: lt_data.

    TRY.
        DATA(lo_so_cttgnh)  = zcl_data_bclctt_Tt=>get_instance( ).

        DATA(lo_common_app) = zcl_jp_common_core=>get_instance( ).

        lo_common_app->get_fillter_app(
            EXPORTING
                io_request  = io_request
                io_response = io_response
            IMPORTING
                ir_companycode        = ir_companycode
                ir_fiscalyear         = ir_fiscalyear
                wa_page_info          = ls_page_info
        ).

        TRY.
            DATA(lr_ranges) = ls_page_info-ro_filter->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range.
            "handle exception
        ENDTRY.
        READ TABLE ir_fiscalyear INTO DATA(ls_fiscalyear) INDEX 1 .

        READ TABLE lr_ranges WITH KEY  name = 'PER_FR' INTO DATA(ls_ranges).
        IF sy-subrc IS INITIAL.
          READ TABLE ls_ranges-range INDEX 1 INTO DATA(ls_per_fr).
        ENDIF.

*        READ TABLE lr_ranges WITH KEY  name = 'PER_TO' INTO ls_ranges.
*        IF sy-subrc IS INITIAL.
*          READ TABLE ls_ranges-range INDEX 1 INTO DATA(ls_per_to).
*        ENDIF.
*
*        IF ls_per_to-low IS INITIAL.
*          ls_per_to-low = ls_per_fr-low.
*        ENDIF.

        DATA: lw_Date_fr TYPE d,
              lw_Date_to TYPE d.

        IF ls_per_fr-low >= 12.
          ls_per_fr-low = 12.
        ENDIF.

*        IF ls_per_to-low >= 12.
*          ls_per_to-low = 12.
*        ENDIF.

        lw_Date_fr = ls_fiscalyear-low && '01' && '01' .
        lw_Date_to = ls_fiscalyear-low && ls_per_fr-low && '01' .

        zcl_utility=>last_day_of_month( EXPORTING i_date = lw_Date_to IMPORTING e_date = lw_Date_to ) .

        APPEND INITIAL LINE TO lr_budat ASSIGNING FIELD-SYMBOL(<lf_budat>).
        <lf_budat>-option = 'BT'.
        <lf_budat>-sign = 'I'.
        <lf_budat>-low = lw_Date_fr.
        <lf_budat>-high = lw_Date_to.


        DATA: lw_year TYPE zde_numc4.
        lw_year = ls_fiscalyear-low.
        lw_year = lw_year - 1.

        lw_Date_fr = lw_year && '01' && '01' .
        lw_Date_to = lw_year && ls_per_fr-low && '01' .
        zcl_utility=>last_day_of_month( EXPORTING i_date = lw_Date_to IMPORTING e_date = lw_Date_to ) .

        APPEND INITIAL LINE TO lr_budat_nt ASSIGNING <lf_budat>.
        <lf_budat>-option = 'BT'.
        <lf_budat>-sign = 'I'.
        <lf_budat>-low = lw_Date_fr.
        <lf_budat>-high = lw_Date_to.

        lo_so_cttgnh->get_bc_lctt_tt(
            EXPORTING
                ir_companycode        = ir_companycode
                ir_fiscalyear         = ir_fiscalyear
                ir_budat               = lr_budat
                ir_budat_nt    = lr_budat_nt
            IMPORTING
                it_data               = gt_data
        ).

        LOOP AT gt_data INTO DATA(ls_data) WHERE Currency IS NOT INITIAL.
          DATA(lw_Currency) = ls_data-Currency.
          EXIT.
        ENDLOOP.

        DATA: lw_company          TYPE bukrs,
              ls_companycode_info TYPE zst_companycode_info.
        lw_company = ir_companycode[ 1 ]-low.
        CALL METHOD zcl_jp_common_core=>get_companycode_details
          EXPORTING
            i_companycode = lw_company
          IMPORTING
            o_companycode = ls_companycode_info.


        LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<lf_Data>).
          <lf_Data>-CompanyCode = ir_companycode[ 1 ]-low.
          <lf_Data>-FiscalYear = ir_fiscalyear[ 1 ]-low.
          <lf_Data>-per_fr = ls_per_fr-low .
*          <lf_Data>-per_to = ls_per_to-low.
          <lf_Data>-Currency = lw_Currency."'VND'.
          <lf_Data>-companyName = ls_companycode_info-companycodename.
          <lf_Data>-companyaddr = ls_companycode_info-companycodeaddr.
        ENDLOOP.

*        IF ls_page_info-page_size < 0.
*          ls_page_info-page_size = 50.
*        ENDIF.
*
*        DATA(max_rows) = COND #( WHEN ls_page_info-page_size = if_rap_query_paging=>page_size_unlimited THEN 0
*                   ELSE ls_page_info-page_size ).
*
*        max_rows = ls_page_info-page_size + ls_page_info-offset.
*
*        LOOP AT gt_data INTO ls_data.
*          IF sy-tabix > ls_page_info-offset.
*            IF sy-tabix > max_rows.
*              EXIT.
*            ELSE.
*              APPEND ls_data TO lt_data.
*            ENDIF.
*          ENDIF.
*        ENDLOOP.

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( gt_data ) ).
        ENDIF.

        IF io_request->is_data_requested( ).
          io_response->set_data( gt_data ).
        ENDIF.

      CATCH cx_root INTO DATA(exception).

        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

        RAISE EXCEPTION TYPE zcl_data_bclctt_Tt
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

CLASS zcl_jp_data_thetaisan DEFINITION
  PUBLIC
  INHERITING FROM cx_rap_query_provider
*  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
*  PUBLIC
*  FINAL
*INHERITING FROM cx_rap_query_provider
*  CREATE PUBLIC.
*
*  PUBLIC SECTION.
*    INTERFACES if_rap_query_provider.
*  PROTECTED SECTION.
*  PRIVATE SECTION.

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_range TYPE TABLE OF ty_range_option.
    TYPES:
      BEGIN OF gty_item,
        CompanyCode(10)         TYPE c,
        MasterFixedAsset(12)    TYPE c,
        FixedAsset(4)           TYPE c,
        AssetIsAcquiredUsed(10) TYPE c,
      END OF gty_item,
      tt_pdf TYPE TABLE OF zc_thetaisan.

    TYPES: BEGIN OF ty_inputs,
             value TYPE STANDARD TABLE OF gty_item WITH EMPTY KEY,
           END OF ty_inputs.
    CLASS-DATA: gt_data  TYPE TABLE OF zc_thetaisan,
                gt_data1 TYPE TABLE OF zc_thetaisan,
                gw_bukrs TYPE bukrs,
                gs_bukrs TYPE zst_companycode_info,
                gs_data  TYPE zc_thetaisan.

    TYPES:
      keys     TYPE TABLE FOR ACTION IMPORT zc_thetaisan~btnprintpdf,
      result   TYPE TABLE FOR ACTION RESULT zc_thetaisan~btnprintpdf,
      mapped   TYPE RESPONSE FOR MAPPED EARLY zc_thetaisan,
      failed   TYPE RESPONSE FOR FAILED zc_thetaisan,
      reported TYPE RESPONSE FOR REPORTED EARLY zc_thetaisan.
    CLASS-DATA:
      "Instance Singleton
      mo_instance      TYPE REF TO zcl_jp_data_thetaisan.

    CLASS-METHODS:
      "Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_jp_data_thetaisan.
    CLASS-METHODS:
      convert_amount IMPORTING lv_amount  TYPE string
                               lv_curr    TYPE waers
                     CHANGING  lv_convert TYPE string,
      btnPrintPDF     IMPORTING keys     TYPE keys
                      EXPORTING o_pdf    TYPE string
                      CHANGING  result   TYPE result
                                mapped   TYPE mapped
                                failed   TYPE failed
                                reported TYPE reported,

      get_data_pdf CHANGING  tt_data      TYPE tt_pdf,
      get_tinhtrangsudung IMPORTING im_company              TYPE bukrs
*                                    im_mainasset TYPE anln1
*                                    im_subasset  TYPE anln2
                          RETURNING VALUE(e_context_status) TYPE string.

    CLASS-METHODS: call_odata_asset_history IMPORTING i_bukrs          TYPE bukrs

                                            RETURNING VALUE(e_context) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_jp_data_thetaisan IMPLEMENTATION.
  METHOD get_data_pdf.
    DATA:
      lt_req TYPE TABLE OF gty_item,
      ls_req TYPE ty_inputs.
    DATA: ls_resp_assethistory TYPE zst_resp_assethistory.

    TYPES: BEGIN OF ty_data_raw,
             companycode              TYPE bukrs,
             assetdepreciationarea    TYPE zde_txt25,
             masterfixedasset         TYPE anln1,
             fixedasset               TYPE anln2,
             ledger                   TYPE I_JournalEntryItem-Ledger,
             assetaccountingkeyfigure TYPE zde_txt25,
             accountingdocument       TYPE I_JournalEntryItem-AccountingDocument,
             ledgergllineitem         TYPE I_JournalEntryItem-LedgerGLLineItem,
             debitcreditcode          TYPE I_JournalEntryItem-DebitCreditCode,
             currencyrole             TYPE zde_txt25,
             keyfigureiszerobalance   TYPE zde_txt25,
             displaycurrency          TYPE waers,
             amountindisplaycurrency  TYPE dmbtr,
           END OF ty_data_raw,
           ty_gt_data_raw TYPE TABLE OF ty_data_raw.

    READ TABLE tt_data INTO DATA(ls_bukrs) INDEX 1.
    IF sy-subrc = 0.
      gw_bukrs = ls_bukrs-companycode.
    ENDIF.
    DATA(lo_comcode) = zcl_jp_common_core=>get_instance(  ).
    lo_comcode->get_companycode_details(
      EXPORTING
        i_companycode = gw_bukrs
      IMPORTING
        o_companycode = gs_bukrs
    ).

*----------------------------* Lay du lieu master data
    SELECT a~companycode,
           a~MasterFixedAsset,
           a~FixedAsset,
           a~AssetClass,
           b~costcenter,
           a~fixedassetdescription,
           a~assetadditionaldescription,
           a~yy1_evaluationgroup1_faa
    FROM I_FixedAsset AS a INNER JOIN I_FixedAssetAssgmt AS b
    ON a~companycode = b~CompanyCode
    AND a~MasterFixedAsset = b~MasterFixedAsset
    AND a~FixedAsset = b~FixedAsset
    FOR ALL ENTRIES IN @tt_data
    WHERE a~CompanyCode = @tt_data-companycode
    AND   a~MasterFixedAsset = @tt_data-mainasset
    AND   a~FixedAsset = @tt_data-subasset
    INTO TABLE @DATA(lt_asset).
    IF lt_asset IS NOT INITIAL.
      CLEAR: tt_data[].
      SELECT *
      FROM I_FixedAssetForLedger
      FOR ALL ENTRIES IN @lt_asset
      WHERE CompanyCode = @lt_asset-CompanyCode
      AND   MasterFixedAsset = @lt_asset-MasterFixedAsset
      AND   FixedAsset = @lt_asset-FixedAsset
      AND   Ledger = '0L'
      INTO TABLE @DATA(lt_asset_date).

      SELECT *
      FROM I_AssetValuationForLedger
      FOR ALL ENTRIES IN @lt_asset
      WHERE CompanyCode = @lt_asset-CompanyCode
      AND   MasterFixedAsset = @lt_asset-MasterFixedAsset
      AND   FixedAsset = @lt_asset-FixedAsset
      AND   Ledger = '0L'
      INTO TABLE @DATA(lt_asset_plan).

*----------------------------*
      " Lay status
      DATA(lv_response_status) = get_tinhtrangsudung( im_company      = gw_bukrs ).
      /ui2/cl_json=>deserialize(
        EXPORTING
          json        = lv_response_status
*               jsonx       =
          pretty_name = /ui2/cl_json=>pretty_mode-none
        CHANGING
          data        = ls_req
      ).
      IF ls_req IS NOT INITIAL.
        MOVE-CORRESPONDING ls_req-value TO lt_req.
        DELETE lt_req WHERE companycode NE gw_bukrs.
        LOOP AT lt_req ASSIGNING FIELD-SYMBOL(<fs_convert>).
          <fs_convert>-masterfixedasset = |{ <fs_convert>-masterfixedasset ALPHA = IN }|.
          <fs_convert>-fixedasset = |{ <fs_convert>-fixedasset ALPHA = IN }|.
        ENDLOOP.
        SORT lt_req BY companycode masterfixedasset fixedasset.
      ENDIF.
      " Lay value nguyen gia
      DATA(lv_response) = call_odata_asset_history( i_bukrs      = ls_bukrs-companycode ).

      /ui2/cl_json=>deserialize(
        EXPORTING
          json        = lv_response
*       jsonx       =
          pretty_name = /ui2/cl_json=>pretty_mode-none
        CHANGING
          data        = ls_resp_assethistory
      ).
      DATA: lt_fr_dataraw TYPE ty_gt_data_raw.
      IF ls_resp_assethistory IS NOT INITIAL.
        MOVE-CORRESPONDING ls_resp_assethistory-d-results TO lt_fr_dataraw.
      ENDIF.
      DELETE lt_fr_dataraw WHERE ledger NE '0L'.
      DELETE lt_fr_dataraw WHERE AssetDepreciationArea NE '01'.
      DELETE lt_fr_dataraw WHERE ( assetaccountingkeyfigure NE '700110' and assetaccountingkeyfigure NE '9790110').
      DELETE lt_fr_dataraw WHERE currencyrole NE '10'.
      DELETE lt_fr_dataraw WHERE keyfigureiszerobalance = 'X'.
      LOOP AT lt_fr_dataraw ASSIGNING FIELD-SYMBOL(<ls_convert>).
        <ls_convert>-masterfixedasset = |{ <ls_convert>-masterfixedasset ALPHA = IN }|.
        <ls_convert>-fixedasset = |{ <ls_convert>-fixedasset ALPHA = IN }|.
      ENDLOOP.
    ENDIF.
*        Xu ly du lieu.
    SORT lt_asset BY CompanyCode MasterFixedAsset FixedAsset.
    SORT lt_asset_date BY CompanyCode MasterFixedAsset FixedAsset.
    LOOP AT lt_asset INTO DATA(ls_asset).
      gs_data-CCadrr = gs_bukrs-companycodeaddr.
      gs_data-CCname = gs_bukrs-companycodename.
      gs_data-companycode = ls_asset-CompanyCode.
      gs_data-mainasset   = ls_asset-MasterFixedAsset.
      gs_data-subasset    = ls_asset-FixedAsset.
      gs_data-assetclass  = ls_asset-AssetClass.
      SELECT SINGLE AssetClassName
      FROM I_AssetClassText
      WHERE AssetClass = @ls_asset-AssetClass AND Language = 'E'
      INTO @DATA(lw_assettext).
      IF sy-subrc = 0.
        gs_data-assetclasstext = |{ gs_data-assetclass }({ lw_assettext })|.
      ENDIF.
      gs_data-costcenter  = ls_asset-CostCenter.
      SELECT SINGLE CostCenterName
        FROM I_CostCenterText
        WHERE CostCenter = @ls_asset-CostCenter AND Language = 'E'
        INTO @DATA(lw_CostCenterName).
      IF sy-subrc = 0.
        gs_data-CostCentertext = |{ gs_data-CostCenter }({ lw_CostCenterName })|.
      ENDIF.
      gs_data-descrip     = ls_asset-fixedassetdescription.
      gs_data-adddescrip  = ls_asset-AssetAdditionalDescription.
      gs_data-noisudung   = ls_asset-yy1_evaluationgroup1_faa.
      SELECT SINGLE description
        FROM I_CustomFieldCodeListText
        WHERE code = @ls_asset-yy1_evaluationgroup1_faa AND Language = 'E'
        AND customfieldID = 'YY1_EVALUATIONGROUP1'
        INTO @DATA(lw_codeName).
      IF sy-subrc = 0.
        gs_data-noisudung = |{ gs_data-noisudung }({ lw_codeName })|.
      ENDIF.
      READ TABLE lt_asset_date INTO DATA(ls_asset_date) WITH KEY companycode = ls_asset-CompanyCode
                                                                 MasterFixedAsset   = ls_asset-MasterFixedAsset
                                                                 FixedAsset    = ls_asset-FixedAsset BINARY SEARCH.
      IF sy-subrc = 0.
        gs_data-ngaysudung = ls_asset_date-AssetCapitalizationDate.
        gs_data-ngayghitang = ls_asset_date-AcquisitionValueDate.
      ENDIF.
      READ TABLE lt_asset_plan INTO DATA(ls_asset_plan) WITH KEY companycode = ls_asset-CompanyCode
                                                       MasterFixedAsset   = ls_asset-MasterFixedAsset
                                                       FixedAsset    = ls_asset-FixedAsset.
      IF sy-subrc = 0.
        gs_data-sothangkhauhao = ls_asset_plan-PlannedUsefulLifeInYears * 12 + ls_asset_plan-PlannedUsefulLifeInPeriods.
      ENDIF.
      " Lay used status
      READ TABLE lt_req INTO DATA(ls_status) WITH KEY  companycode  = ls_asset-CompanyCode
                                                      masterfixedasset = ls_asset-MasterFixedAsset
                                                      FixedAsset        = ls_asset-FixedAsset.
      IF ls_status-assetisacquiredused = 'X' AND sy-subrc = 0.
        gs_data-hientrang = 'Mua thanh lý'.
      ELSEIF ls_status-assetisacquiredused = '' AND sy-subrc = 0.
        gs_data-hientrang = 'Mua mới'.
      ENDIF.
      " Nguyen gia
      LOOP AT lt_fr_dataraw INTO DATA(ls_fr_dataraw) WHERE  companycode  = ls_asset-CompanyCode
                                                     AND masterfixedasset = ls_asset-MasterFixedAsset
                                                 AND FixedAsset        = ls_asset-FixedAsset.
        IF ls_fr_dataraw-displaycurrency = 'VND'.
          gs_data-nguyengia = gs_data-nguyengia + ( ls_fr_dataraw-amountindisplaycurrency / 100 ).
        ELSE.
          gs_data-nguyengia = gs_data-nguyengia + ls_fr_dataraw-amountindisplaycurrency.
        ENDIF.
      ENDLOOP.
      "
*      gs_data-currency_code = 'VND'.
      APPEND gs_data TO tt_data.
      CLEAR : gs_data.
    ENDLOOP.
  ENDMETHOD.

  METHOD convert_amount.

    lv_convert = lv_amount.
    IF lv_curr = 'VND' OR lv_curr = 'JPY'.
      lv_convert = lv_convert * 100.
      SPLIT lv_convert AT '.' INTO lv_convert DATA(lv_del).
    ELSE.
      REPLACE ALL OCCURRENCES OF '.' IN lv_convert WITH ','.
    ENDIF.
    DATA flag_am TYPE char1.
    FIND '-' IN lv_amount.
    IF sy-subrc = 0.
      flag_am = 'X'.
      REPLACE ALL OCCURRENCES OF '-' IN lv_convert WITH ''.
    ENDIF.

    REPLACE ALL OCCURRENCES OF REGEX '(\d)(?=(\d{3})+(?!\d))'
    IN lv_convert WITH '$1.'.

    IF flag_am = 'X'.
      lv_convert = |-{ lv_convert }|.
    ENDIF.
  ENDMETHOD.

  METHOD btnprintpdf.
    READ TABLE keys INTO DATA(k) INDEX 1.
    DATA: lt_split TYPE TABLE OF string,
          ir_cc    TYPE tt_range,
          ir_main  TYPE tt_range,
          ir_sub   TYPE tt_range.
    DATA: lt_data TYPE TABLE OF zc_thetaisan.
    FREE: lt_split.
    SPLIT k-%param-companycode AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO DATA(l_string).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_cc.
    ENDLOOP.

    FREE: lt_split.
    SPLIT k-%param-mainasset AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO l_string.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_main.
    ENDLOOP.

    FREE: lt_split.
    SPLIT k-%param-subasset AT ',' INTO TABLE lt_split.
    LOOP AT lt_split INTO l_string.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = l_string )        TO ir_sub.
    ENDLOOP.

    LOOP AT ir_cc INTO DATA(ls_range).
      APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      <fs_data>-companycode = ls_range-low.
      READ TABLE ir_main INTO ls_range INDEX sy-tabix.
      IF sy-subrc = 0.
        <fs_data>-mainasset = ls_range-low.
        <fs_data>-mainasset = |{ <fs_data>-mainasset ALPHA = IN }|.
      ENDIF.
      READ TABLE ir_sub INTO ls_range INDEX sy-tabix.
      IF sy-subrc = 0.
        <fs_data>-subasset = ls_range-low.
        <fs_data>-subasset = |{ <fs_data>-subasset ALPHA = IN }|.
      ENDIF.
    ENDLOOP.

    zcl_jp_data_thetaisan=>get_data_pdf(
      CHANGING
        tt_data = lt_data
    ).
    DATA(o_gen_adobe) = NEW zcl_gen_adobe( ).
    DATA: ls_xml TYPE zcl_gen_adobe=>ty_gs_xml.
    DATA: xml     TYPE string,
          sub1xml TYPE string,
          sub2xml TYPE string.
    DATA: lv_xml_data_string  TYPE string,
          lv_xml_data_xstring TYPE xstring,
          lv_xml_data         TYPE string.

    LOOP AT lt_data INTO DATA(ls_data).
       ls_data-mainasset = |{ ls_data-mainasset ALPHA = OUT }|.
       ls_data-subasset = |{ ls_data-subasset ALPHA = OUT }|.
       CONDENSE ls_data-mainasset.
       CONDENSE ls_data-subasset.
      sub1xml = sub1xml && |<sub1>| &&
                                |<Table1>| &&
                                    |<Row1>| &&
                                        |<Cell1>{ ls_data-CCname }</Cell1>| &&
                                    |</Row1>| &&
                                    |<Row2>| &&
                                        |<Cell1>{ ls_data-CCadrr }</Cell1>| &&
                                        |<Cell3>{ ls_data-mainasset }-{ ls_data-subasset }</Cell3>| &&
                                    |</Row2>| &&
                                |</Table1>| &&
                            |</sub1>|.

      DATA(lv_amount) = |{ ls_data-nguyengia }|.
      DATA: lv_amountTXT TYPE string.
      zcl_get_unc=>convert_amount(
        EXPORTING
          lv_amount  = lv_amount
          lv_curr    = 'VND'
        CHANGING
          lv_convert = lv_amountTXT
      ).

      sub2xml = sub2xml && |<sub2>| &&
                                |<Table2>| &&
                                    |<Row1>| &&
                                        |<Cell2>{ ls_data-descrip }{ ls_data-adddescrip }</Cell2>| &&
                                        |<Cell4>{ ls_data-ngayghitang+6(2) }/{ ls_data-ngayghitang+4(2) }/{ ls_data-ngayghitang+0(4) }</Cell4>| &&
                                    |</Row1>| &&
                                    |<Row2>| &&
                                        |<Cell2>{ ls_data-costcentertext }</Cell2>| &&
                                        |<Cell4>{ ls_data-ngaysudung+6(2) }/{ ls_data-ngaysudung+4(2) }/{ ls_data-ngaysudung+0(4) }</Cell4>| &&
                                    |</Row2>| &&
                                    |<Row3>| &&
                                        |<Cell2>{ ls_data-assetclasstext }</Cell2>| &&
                                        |<Cell4>{ lv_amounttxt }</Cell4>| &&
                                    |</Row3>| &&
                                    |<Row4>| &&
                                        |<Cell2>{ ls_data-hientrang }</Cell2>| &&
                                        |<Cell4>{ ls_data-sothangkhauhao }</Cell4>| &&
                                    |</Row4>| &&
                                |</Table2>| &&
                            |</sub2>|.

      xml = |<?xml version="1.0" encoding="UTF-8"?>| &&
           |<form>| &&
                      |{ sub1xml }| &&
                      |{ sub2xml }| &&
           |</form>|
            .
      lv_xml_data_string    = cl_web_http_utility=>encode_x_base64(
                                cl_web_http_utility=>encode_utf8( xml )
                              ).
      lv_xml_data_xstring   = cl_web_http_utility=>decode_x_base64( lv_xml_data_string ).

      APPEND lv_xml_data_xstring TO ls_xml-data.

      CLEAR: xml, sub2xml, sub1xml, lv_amounttxt.
    ENDLOOP.

    DATA: str_pdf TYPE string.

    DATA(lv_pdf) = o_gen_adobe->print_pdf( EXPORTING i_xml   = ls_xml
                                                     iv_rpid = 'zthetaisan'
                                           IMPORTING str_pdf = str_pdf ).

    o_pdf = lv_pdf.

    DATA: lv_filename TYPE string.

    lv_filename = |The_tai_san_{ sy-datlo }|.

    result = VALUE #(
                    FOR key IN keys (
*                       %cid_ref = key-%cid_ref
*                       %tky   = key-%tky
                    %cid   = k-%cid
                    %param = VALUE #( filecontent   = str_pdf
                                      filename      = lv_filename
                                      fileextension = 'pdf'
*                                              mimeType      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                      mimetype      = 'application/pdf'
                                      )
                    )
                    ).

    DATA: ls_mapped LIKE LINE OF mapped-zc_thetaisan.
*    ls_mapped-%tky         = k-%tky.

    INSERT CORRESPONDING #( ls_mapped ) INTO TABLE mapped-zc_thetaisan.

  ENDMETHOD.
  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
**--- Custom Entities ---**
* TYPES: tt_inputs TYPE STANDARD TABLE OF ty_inputs.
    DATA:
      lt_req TYPE TABLE OF gty_item,
      ls_req TYPE ty_inputs.
    DATA: ls_resp_assethistory TYPE zst_resp_assethistory.
    DATA: ls_page_info  TYPE zcl_get_fillter_thetaisan=>st_page_info,
          ir_bukrs      TYPE tt_range,
          ir_mainasset  TYPE tt_range,
          ir_subasset   TYPE tt_range,
          ir_assetclass TYPE tt_range,
          ir_costcenter TYPE tt_range,
          ir_desc       TYPE tt_range,
          ir_add        TYPE tt_range.

    TYPES: BEGIN OF ty_data_raw,
             companycode              TYPE bukrs,
             assetdepreciationarea    TYPE zde_txt25,
             masterfixedasset         TYPE anln1,
             fixedasset               TYPE anln2,
             ledger                   TYPE I_JournalEntryItem-Ledger,
             assetaccountingkeyfigure TYPE zde_txt25,
             accountingdocument       TYPE I_JournalEntryItem-AccountingDocument,
             ledgergllineitem         TYPE I_JournalEntryItem-LedgerGLLineItem,
             debitcreditcode          TYPE I_JournalEntryItem-DebitCreditCode,
             currencyrole             TYPE zde_txt25,
             keyfigureiszerobalance   TYPE zde_txt25,
             displaycurrency          TYPE waers,
             amountindisplaycurrency  TYPE dmbtr,
           END OF ty_data_raw,
           ty_gt_data_raw TYPE TABLE OF ty_data_raw.
    TRY.
* Khởi tạo đối tượng
        DATA(lo_thetaisan)  = zcl_jp_data_thetaisan=>get_instance( ).
        DATA(lo_comcode) = zcl_jp_common_core=>get_instance(  ).
        DATA(lo_common_app) = zcl_get_fillter_thetaisan=>get_instance( ).

*  Lấy tham số
        lo_common_app->get_fillter_app(   EXPORTING
                                            io_request    = io_request
                                            io_response   = io_response
                                          IMPORTING
                                            ir_bukrs  = ir_bukrs
                                            ir_mainasset  = ir_mainasset
                                            ir_subasset  = ir_subasset
                                            ir_assetclass  = ir_assetclass
                                            ir_costcenter   = ir_costcenter
                                            ir_desc         = ir_desc
                                            ir_add          = ir_add
                                            wa_page_info  = ls_page_info
                                        ).
*----------------------------*
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
*----------------------------*
        " Lay status
        DATA(lv_response_status) = get_tinhtrangsudung( im_company      = gw_bukrs ).
        /ui2/cl_json=>deserialize(
          EXPORTING
            json        = lv_response_status
*               jsonx       =
            pretty_name = /ui2/cl_json=>pretty_mode-none
          CHANGING
            data        = ls_req
        ).
        IF ls_req IS NOT INITIAL.
          MOVE-CORRESPONDING ls_req-value TO lt_req.
          DELETE lt_req WHERE companycode NE gw_bukrs.
          LOOP AT lt_req ASSIGNING FIELD-SYMBOL(<fs_convert>).
            <fs_convert>-masterfixedasset = |{ <fs_convert>-masterfixedasset ALPHA = IN }|.
            <fs_convert>-fixedasset = |{ <fs_convert>-fixedasset ALPHA = IN }|.
          ENDLOOP.
          SORT lt_req BY companycode masterfixedasset fixedasset.
        ENDIF.
        " Lay value nguyen gia
        DATA(lv_response) = call_odata_asset_history( i_bukrs      = gs_bukrs-companycode ).

        /ui2/cl_json=>deserialize(
          EXPORTING
            json        = lv_response
*       jsonx       =
            pretty_name = /ui2/cl_json=>pretty_mode-none
          CHANGING
            data        = ls_resp_assethistory
        ).
        DATA: lt_fr_dataraw TYPE ty_gt_data_raw.
        IF ls_resp_assethistory IS NOT INITIAL.
          MOVE-CORRESPONDING ls_resp_assethistory-d-results TO lt_fr_dataraw.
        ENDIF.
        DELETE lt_fr_dataraw WHERE ledger NE '0L'.
        DELETE lt_fr_dataraw WHERE AssetDepreciationArea NE '01'.
        DELETE lt_fr_dataraw WHERE assetaccountingkeyfigure NE '10700110'.
        DELETE lt_fr_dataraw WHERE currencyrole NE '10'.
        DELETE lt_fr_dataraw WHERE keyfigureiszerobalance = 'X'.
        LOOP AT lt_fr_dataraw ASSIGNING FIELD-SYMBOL(<ls_convert>).
          <ls_convert>-masterfixedasset = |{ <ls_convert>-masterfixedasset ALPHA = IN }|.
          <ls_convert>-fixedasset = |{ <ls_convert>-fixedasset ALPHA = IN }|.
        ENDLOOP.
*----------------------------* Lay du lieu master data
        CLEAR: gt_data[].
        SELECT a~companycode,
               a~MasterFixedAsset,
               a~FixedAsset,
               a~AssetClass,
               b~costcenter,
               a~fixedassetdescription,
               a~assetadditionaldescription,
               a~yy1_evaluationgroup1_faa
        FROM I_FixedAsset AS a INNER JOIN I_FixedAssetAssgmt AS b
        ON a~companycode = b~CompanyCode
        AND a~MasterFixedAsset = b~MasterFixedAsset
        AND a~FixedAsset = b~FixedAsset
        WHERE a~CompanyCode IN @ir_bukrs
        AND   a~MasterFixedAsset IN @ir_mainasset
        AND   a~FixedAsset IN @ir_subasset
        AND   a~AssetClass IN @ir_assetclass
        AND   b~CostCenter IN @ir_costcenter
        AND   a~FixedAssetDescription IN @ir_desc
        AND   a~assetadditionaldescription IN @ir_add
        INTO TABLE @DATA(lt_asset).
        IF lt_asset IS NOT INITIAL.
          SELECT *
          FROM I_FixedAssetForLedger
          FOR ALL ENTRIES IN @lt_asset
          WHERE CompanyCode = @lt_asset-CompanyCode
          AND   MasterFixedAsset = @lt_asset-MasterFixedAsset
          AND   FixedAsset = @lt_asset-FixedAsset
          AND   Ledger = '0L'
          INTO TABLE @DATA(lt_asset_date).

          SELECT *
          FROM I_AssetValuationForLedger
          FOR ALL ENTRIES IN @lt_asset
          WHERE CompanyCode = @lt_asset-CompanyCode
          AND   MasterFixedAsset = @lt_asset-MasterFixedAsset
          AND   FixedAsset = @lt_asset-FixedAsset
          AND   Ledger = '0L'
          INTO TABLE @DATA(lt_asset_plan).
        ENDIF.
*        Xu ly du lieu.
        SORT lt_asset BY CompanyCode MasterFixedAsset FixedAsset.
        SORT lt_asset_date BY CompanyCode MasterFixedAsset FixedAsset.
        LOOP AT lt_asset INTO DATA(ls_asset).
          gs_data-companycode = ls_asset-CompanyCode.
          gs_data-mainasset   = ls_asset-MasterFixedAsset.
          gs_data-subasset    = ls_asset-FixedAsset.
          gs_data-assetclass  = ls_asset-AssetClass.
          SELECT SINGLE AssetClassName
          FROM I_AssetClassText
          WHERE AssetClass = @ls_asset-AssetClass AND Language = 'E'
          INTO @DATA(lw_assettext).
          IF sy-subrc = 0.
            gs_data-assetclasstext = |{ gs_data-assetclass }({ lw_assettext })|.
          ENDIF.
          gs_data-costcenter  = ls_asset-CostCenter.
          SELECT SINGLE CostCenterName
            FROM I_CostCenterText
            WHERE CostCenter = @ls_asset-CostCenter AND Language = 'E'
            INTO @DATA(lw_CostCenterName).
          IF sy-subrc = 0.
            gs_data-CostCentertext = |{ gs_data-CostCenter }({ lw_CostCenterName })|.
          ENDIF.
          gs_data-descrip     = ls_asset-fixedassetdescription.
          gs_data-adddescrip  = ls_asset-AssetAdditionalDescription.
          gs_data-noisudung   = ls_asset-yy1_evaluationgroup1_faa.
          SELECT SINGLE description
            FROM I_CustomFieldCodeListText
            WHERE code = @ls_asset-yy1_evaluationgroup1_faa AND Language = 'E'
            AND customfieldID = 'YY1_EVALUATIONGROUP1'
            INTO @DATA(lw_codeName).
          IF sy-subrc = 0.
            gs_data-noisudung = |{ gs_data-noisudung }({ lw_codeName })|.
          ENDIF.
          READ TABLE lt_asset_date INTO DATA(ls_asset_date) WITH KEY companycode = ls_asset-CompanyCode
                                                                     MasterFixedAsset   = ls_asset-MasterFixedAsset
                                                                     FixedAsset    = ls_asset-FixedAsset BINARY SEARCH.
          IF sy-subrc = 0.
            gs_data-ngaysudung = ls_asset_date-AssetCapitalizationDate.
            gs_data-ngayghitang = ls_asset_date-AcquisitionValueDate.
          ENDIF.
          READ TABLE lt_asset_plan INTO DATA(ls_asset_plan) WITH KEY companycode = ls_asset-CompanyCode
                                                           MasterFixedAsset   = ls_asset-MasterFixedAsset
                                                           FixedAsset    = ls_asset-FixedAsset.
          IF sy-subrc = 0.
            gs_data-sothangkhauhao = ls_asset_plan-PlannedUsefulLifeInYears * 12 + ls_asset_plan-PlannedUsefulLifeInPeriods.
          ENDIF.
          " Lay used status
          READ TABLE lt_req INTO DATA(ls_status) WITH KEY  companycode  = ls_asset-CompanyCode
                                                          masterfixedasset = ls_asset-MasterFixedAsset
                                                          FixedAsset        = ls_asset-FixedAsset.
          IF ls_status-assetisacquiredused = 'X' AND sy-subrc = 0.
            gs_data-hientrang = 'Mua thanh lý'.
          ELSEIF ls_status-assetisacquiredused = '' AND sy-subrc = 0.
            gs_data-hientrang = 'Mua mới'.
          ENDIF.
          " Nguyen gia
          LOOP AT lt_fr_dataraw INTO DATA(ls_fr_dataraw) WHERE  companycode  = ls_asset-CompanyCode
                                                         AND masterfixedasset = ls_asset-MasterFixedAsset
                                                     AND FixedAsset        = ls_asset-FixedAsset.
            IF ls_fr_dataraw-displaycurrency = 'VND'.
              gs_data-nguyengia = gs_data-nguyengia + ( ls_fr_dataraw-amountindisplaycurrency / 100 ).
            ELSE.
              gs_data-nguyengia = gs_data-nguyengia + ls_fr_dataraw-amountindisplaycurrency.
            ENDIF.
          ENDLOOP.
          "
          gs_data-currency_code = 'VND'.
          APPEND gs_data TO gt_data.
          CLEAR : gs_data.
        ENDLOOP.

*------------------------------------*
*        IF ls_page_info-page_size < 0.
*          ls_page_info-page_size = 50.
*        ENDIF.
*
*        DATA(max_rows) = COND #( WHEN ls_page_info-page_size = if_rap_query_paging=>page_size_unlimited THEN 0
*                   ELSE ls_page_info-page_size ).
*
*        max_rows = ls_page_info-page_size + ls_page_info-offset.
*
*        IF io_request->is_total_numb_of_rec_requested( ).
*          io_response->set_total_number_of_records( lines( gt_data ) ).
*        ENDIF.
*
*        IF io_request->is_data_requested( ).
*          io_response->set_data( gt_data ).
*        ENDIF.

        IF ls_page_info-page_size < 0.
          ls_page_info-page_size = 50.
        ENDIF.

        DATA(max_rows) = COND #( WHEN ls_page_info-page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                   ELSE ls_page_info-page_size ).

        max_rows = ls_page_info-page_size + ls_page_info-offset.

        LOOP AT gt_data INTO gs_data.
          IF sy-tabix > ls_page_info-offset.
            IF sy-tabix > max_rows.
              EXIT.
            ELSE.
              APPEND gs_data TO gt_data1.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( gt_data ) ).
        ENDIF.

        IF io_request->is_data_requested( ).
          io_response->set_data( gt_data1 ).
        ENDIF.

      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

        RAISE EXCEPTION TYPE zcl_jp_data_thetaisan
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


  METHOD get_tinhtrangsudung.
    DATA: lv_url   TYPE string, " Replace with actual URL
          lv_pref  TYPE string,
          lv_asset TYPE string,
          lv_str   TYPE string,
          i_xml    TYPE string.
    DATA: lv_username TYPE string,
          lv_password TYPE string.
*          lv_uuid TYPE string VALUE `urn:uuid:{{$randomUUID}}`.
    lv_asset = |?$top=1000000|.
    TRY.
        DATA(lv_host) = cl_abap_context_info=>get_system_url( ).
        SPLIT lv_host AT '.' INTO lv_host lv_pref.
        CONCATENATE lv_host `-api` `.` lv_pref INTO lv_host.
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.
    TRY.
        lv_username = |INBOUND_COMM_USER_BTP_EXTENSION|.
        lv_password = `DCg=#-}.v-qnz&wFz2025`.      "create http destination by url; API endpoint for API sandbox
        lv_url = |https://{ lv_host }:443/sap/opu/odata4/sap/api_fixedasset/srvd_a2x/sap/fixedasset/0001/FixedAsset{  lv_asset }|.
        DATA(lo_http_destination) =
          cl_http_destination_provider=>create_by_url(
          i_url = lv_url ).
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_http_destination ).

*-- SET HTTP Header Fields

        lo_http_client->get_http_request( )->set_header_fields( VALUE #(
            ( name = |Accept-Encoding| value = |gzip,deflate| )
            ( name = |Content-Type|    value = |text/xml;charset=UTF-8| )
            ( name = |Host|            value = lv_host )
            ( name = |Connection|      value = |Keep-Alive| )
            ( name = |User-Agent|      value = |Apache-HttpClient/4.5.5 (Java/16.0.2)| )
        ) ).

        lv_username = |INBOUND_COMM_USER_BTP_EXTENSION|.
        lv_password = `DCg=#-}.v-qnz&wFz2025`.

*-- Passing the Accept value in header which is a mandatory field
        lo_http_client->get_http_request( )->set_header_field( i_name = |username| i_value = lv_username ).
        lo_http_client->get_http_request( )->set_header_field( i_name = |password| i_value = lv_password ).
*-- Authorization
        lo_http_client->get_http_request( )->set_authorization_basic( i_username = lv_username i_password = lv_password ).
        lo_http_client->get_http_request( )->set_content_type( |text/xml;charset=UTF-8| ).

        lo_http_client->get_http_request( )->set_version( version = if_web_http_request=>co_protocol_version_1_1 ).
        lo_http_client->execute( i_method = if_web_http_client=>get
).
*-- Response ->
        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>get
                                                     ).
        DATA(code) = lo_response->get_status( )-code.
        DATA(reason) = lo_response->get_status( )-reason.
        DATA(lv_body)  = lo_response->get_text( ).
        e_context_status = lv_body.
*        IF code = '200'.
*          SPLIT lv_body AT 'AssetIsAcquiredUsed' INTO  lv_body lv_str.
*          IF lv_str IS NOT INITIAL.
*            CLEAR : lv_body.
*            SPLIT lv_str AT ',' INTO  lv_body lv_str.
*            IF lv_body CS 'false'.
*              ex_tinhtrang = 'Mua mới'.
*            ELSEIF lv_body CS 'true'.
*              ex_tinhtrang = 'Mua thanh lý'.
*            ENDIF.
*          ENDIF.
*        ENDIF.
**********************************************************************
    ENDTRY.
  ENDMETHOD.


  METHOD call_odata_asset_history.
    DATA: lv_url   TYPE string, " Replace with actual URL
          lv_query TYPE string,
          lv_pref  TYPE string,
          lv_date  TYPE sy-datum,
          lv_time  TYPE sy-uzeit,
          i_filter TYPE string,
          i_xml    TYPE string.
*          lv_uuid TYPE string VALUE `urn:uuid:{{$randomUUID}}`.

    CONSTANTS: c_kfset   TYPE string VALUE 'AHS'.

    DATA: lv_year   TYPE string,
          lv_period TYPE string,
          lv_keydt  TYPE string.
    DATA: lv_utc_tstmp  TYPE timestamp.
    CONSTANTS: c_username TYPE string VALUE 'INBOUND_COMM_USER_BTP_EXTENSION',
               c_password TYPE string VALUE 'DCg=#-}.v-qnz&wFz2025'.
    GET TIME STAMP FIELD lv_utc_tstmp.

    CONVERT TIME STAMP CONV timestamp( lv_utc_tstmp )
        TIME ZONE 'UTC+7'
        INTO DATE lv_date
             TIME lv_time.
*-- Get Param
*    READ TABLE ir_companycode INDEX 1 INTO DATA(ls_range).
*    IF sy-subrc EQ 0.
    DATA(lv_companycode) = i_bukrs.
*    ENDIF.

    lv_year = lv_date(4).
    lv_period = lv_date+4(2).
    CONCATENATE lv_date(4) lv_date+4(2) lv_date+6(2) INTO lv_keydt SEPARATED BY '-'.
    TRY.
        DATA(lv_host) = cl_abap_context_info=>get_system_url( ).
        SPLIT lv_host AT '.' INTO lv_host lv_pref.
        CONCATENATE lv_host `-api` `.` lv_pref INTO lv_host.
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    "Post $Batch request
    lv_url = |https://{ lv_host }/sap/opu/odata/sap/YY1_ASSETHISTORY_CDS_CDS|    &&
             |/YY1_ASSETHISTORY_CDS(P_AssetAccountingKeyFigureSet='AHS',| &&
             |P_FiscalYear='{ lv_year }',P_FiscalPeriod='{ lv_period }',|    &&
             |P_KeyDate=datetime'{ lv_keydt }T00:00:00')/Results?$format=json|.

    TRY.
        "create http destination by url; API endpoint for API sandbox
        DATA(lo_http_destination) =
          cl_http_destination_provider=>create_by_url( lv_url ).

        "create HTTP client by destination
        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

        "adding headers
        DATA(lo_request) = lo_web_http_client->get_http_request( ).

        lo_request->set_header_fields( VALUE #(
        ( name = 'config_authType'    value = 'Basic' )
        ( name = 'config_packageName' value = 'S4HANACloudABAPPlatform' )
*        ( name = 'config_actualUrl'   value = |https://{ lv_host }{ c_apiname }| )
*        ( name = 'config_urlPattern'  value = 'https://{host}:{port}' && c_apiname )
*        ( name = 'config_apiName'     value = c_apiname )
        ( name = 'DataServiceVersion' value = '2.0' )
        ( name = 'Accept'             value = 'application/json' )
        ) ).

*-- Param
*        lo_request->set_form_field(
*          i_name  = ''
*          i_value = ''
*        ).

*-- filter
        IF lv_companycode EQ 0.
          i_filter = |CompanyCode eq { lv_companycode }|.
          lo_request->set_form_field(  i_name = '$filter' i_value = i_filter ).
        ENDIF.
*-- Passing the Accept value in header which is a mandatory field
        lo_request->set_header_field( i_name = |username| i_value = c_username ).
        lo_request->set_header_field( i_name = |password| i_value = c_password ).

*-- Authorization
        lo_request->set_authorization_basic( i_username = c_username i_password = c_password ).
        lo_request->set_content_type( |text/xml;charset=UTF-8| ).

        lo_request->set_version( version = if_web_http_request=>co_protocol_version_1_1 ).

        "set request method and execute request
        lo_web_http_client->execute( i_method = if_web_http_client=>get ).

        DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>get ).

        DATA(lv_response) = lo_web_http_response->get_text( ).
        DATA(code) = lo_web_http_response->get_status( )-code.
        DATA(reason) = lo_web_http_response->get_status( )-reason.

        e_context = lv_response.

        "error handling
      CATCH cx_http_dest_provider_error
            cx_web_http_client_error
            cx_web_message_error .
*

    ENDTRY.
  ENDMETHOD.
ENDCLASS.

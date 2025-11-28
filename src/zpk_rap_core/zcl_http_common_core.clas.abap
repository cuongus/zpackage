CLASS zcl_http_common_core DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_ranges TYPE TABLE OF ty_range_option,

           BEGIN OF ty_inputs_cocode,
             companycode TYPE bukrs,
             addressid   TYPE ad_addrnum,
             language    TYPE zde_char1,
           END OF ty_inputs_cocode.

    TYPES: BEGIN OF ty_resp_cocode,
             include TYPE zst_companycode_info,
           END OF ty_resp_cocode,

           BEGIN OF ty_resp_addrid,
             include TYPE zst_addresid_info,
           END OF ty_resp_addrid.

    INTERFACES if_http_service_extension .

    CLASS-METHODS:
      get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_jp_common_core,

      handle_unknown_case CHANGING cv_message TYPE string,

      handle_get_companycode CHANGING  cv_message  TYPE string,

      handle_get_addressid CHANGING cv_message TYPE string,

      handle_get_glaccount CHANGING cv_message TYPE string,

      handle_get_openingbalance CHANGING cv_message TYPE string,

      handle_get_endingbalance CHANGING cv_message TYPE string,

      handle_post_cfid_temp IMPORTING uv_message TYPE string OPTIONAL
                            CHANGING  cv_message TYPE string,

      handle_post_sinvoicedata IMPORTING uv_message TYPE string OPTIONAL
                               CHANGING  cv_message TYPE string,

      handle_post_firud_cf_off_acc IMPORTING uv_message TYPE string
                                   CHANGING  cv_message TYPE string,

      handle_get_soquytienmat CHANGING cv_message TYPE string,

      handle_get_bangcandoiphatsinh CHANGING cv_message TYPE string,

      handle_get_phieuketoan CHANGING cv_message TYPE string,

      handle_get_phieuketoan_header CHANGING cv_message TYPE string,

      handle_get_salesorder CHANGING cv_message TYPE string,

      get_bp_info_new    IMPORTING i_businesspartner TYPE kunnr
                         EXPORTING o_bp_info         TYPE zst_bp_info.
    METHODS:
      handle_clear.

    CONSTANTS: c_header_content TYPE string VALUE 'content-type',
               c_content_type   TYPE string VALUE 'application/json, charset=utf-8'.

    CLASS-DATA: g_addressid          TYPE string,
                g_companycode        TYPE string,
                g_date               TYPE string,
                g_fromdate           TYPE string,
                g_todate             TYPE string,
                g_glaccount          TYPE string,
                g_fiscalyear         TYPE string,
                g_accountingdocument TYPE string,
                g_char10             TYPE zde_char10,
                "Response Get Companycode
                es_resp_cocode       TYPE ty_resp_cocode,
                "Response Get Address ID
                es_resp_addrid       TYPE ty_resp_addrid,

                g_json_string        TYPE string,

                g_reservation        TYPE string,
                g_reservationitem    TYPE string,

                o_jp_common          TYPE REF TO zcl_jp_common_core.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_COMMON_CORE IMPLEMENTATION.


  METHOD get_bp_info_new.
    SELECT SINGLE * FROM I_BusinessPartner WHERE BusinessPartner = @i_businesspartner  INTO @DATA(ls_bp) .
    SELECT SINGLE *
        FROM I_Businesspartneraddressusage AS a
        WHERE a~BusinessPartner = @i_businesspartner
        AND a~AddressUsage = 'XXDEFAULT'
        INTO @DATA(ls_usage).

    o_bp_info-businesspartner = i_businesspartner.
    SELECT addresseefullname ,                          "#EC CI_NOFIELD
     OrganizationName1,
     OrganizationName2,
     OrganizationName3,
     OrganizationName4,
     housenumber ,
     streetname ,
     streetprefixname1 ,
     streetprefixname2 ,
     streetsuffixname1 ,
     streetsuffixname2 ,
     districtname ,
     cityname ,
     country
     FROM i_address_2
     WITH PRIVILEGED ACCESS
     WHERE addressid = @ls_usage-AddressNumber ORDER BY PRIMARY KEY
     INTO TABLE @DATA(lt_address_2) .

    READ TABLE lt_address_2 INTO DATA(ls_address_2) INDEX 1.

    o_bp_info-addressid = ls_usage-AddressNumber.

*    name
    o_bp_info-bpname = |{ ls_address_2-OrganizationName1 } { ls_address_2-OrganizationName2 } { ls_address_2-OrganizationName3 } { ls_address_2-OrganizationName4 }|.
    REPLACE ALL OCCURRENCES OF |, , , , , ,| IN o_bp_info-bpname WITH |,|.
    REPLACE ALL OCCURRENCES OF |, , , , ,| IN o_bp_info-bpname WITH |,|.
    REPLACE ALL OCCURRENCES OF |, , , ,| IN o_bp_info-bpname WITH |,|.
    REPLACE ALL OCCURRENCES OF |, , ,| IN o_bp_info-bpname WITH |,|.
    REPLACE ALL OCCURRENCES OF |, ,| IN o_bp_info-bpname WITH |,|.

*    địa chỉ
    o_bp_info-bpaddr =
    |{ ls_address_2-StreetName }, { ls_address_2-StreetPrefixName1 }, { ls_address_2-StreetPrefixName2 }, { ls_address_2-StreetSuffixName1 }, { ls_address_2-DistrictName }, { ls_address_2-CityName }|.

    REPLACE ALL OCCURRENCES OF |, , , , , ,| IN o_bp_info-bpaddr WITH |,|.
    REPLACE ALL OCCURRENCES OF |, , , , ,| IN o_bp_info-bpaddr WITH |,|.
    REPLACE ALL OCCURRENCES OF |, , , ,| IN o_bp_info-bpaddr WITH |,|.
    REPLACE ALL OCCURRENCES OF |, , ,| IN o_bp_info-bpaddr WITH |,|.
    REPLACE ALL OCCURRENCES OF |, ,| IN o_bp_info-bpaddr WITH |,|.


    SHIFT o_bp_info-bpaddr LEFT DELETING LEADING ','.
    SHIFT o_bp_info-bpaddr RIGHT DELETING TRAILING ','.
    SHIFT o_bp_info-bpaddr LEFT DELETING LEADING ''.

    "Customer Email
    SELECT SINGLE EmailAddress FROM I_AddressEmailAddress_2 "#EC CI_NOFIELD
    WITH PRIVILEGED ACCESS
    WHERE AddressID = @ls_usage-AddressNumber
    INTO @o_bp_info-email
    .

    "Customer Telephone
    SELECT * FROM I_AddressPhoneNumber_2                "#EC CI_NOFIELD
    WITH PRIVILEGED ACCESS
    WHERE AddressID = @ls_usage-AddressNumber
    INTO TABLE @DATA(lt_phone).
    LOOP AT lt_phone INTO DATA(ls_phone).
      IF ls_phone-PhoneNumberType = 3.
        o_bp_info-mobilephone = ls_phone-PhoneAreaCodeSubscriberNumber.
      ELSE.
        o_bp_info-telephone = ls_phone-PhoneAreaCodeSubscriberNumber.
      ENDIF.
    ENDLOOP.

    "fax number
    SELECT SINGLE faxareacodesubscribernumber FROM I_AddressFaxNumber_2 "#EC CI_NOFIELD
   WITH PRIVILEGED ACCESS
   WHERE AddressID = @ls_usage-AddressNumber
   INTO @o_bp_info-fax.

*    tax number
    SELECT SINGLE BPTaxNumber FROM I_Businesspartnertaxnumber "#EC CI_NOFIELD
    WITH PRIVILEGED ACCESS
    WHERE BusinessPartner = @i_businesspartner
    AND BPTaxType = 'VN1'
    INTO @o_bp_info-mst.

*    thông tin ngân hàng
    SELECT SINGLE * FROM I_BusinessPartnerBank WHERE BusinessPartner = @i_businesspartner INTO @DATA(ls_bpBank).
    o_bp_info-stk = ls_bpbank-BankAccount.
    o_bp_info-tentk = ls_bpbank-BankAccountName.
    o_bp_info-banknumber = ls_bpbank-BankNumber.
    o_bp_info-bankname = ls_bpbank-BankName.
    o_bp_info-bankaddr = ls_bpbank-CityName.
    o_bp_info-swift    = ls_bpbank-SWIFTCode.
    o_bp_info-bankcountrykey = ls_bpbank-BankCountryKey.



  ENDMETHOD.


  METHOD get_instance.
    o_jp_common = ro_instance = COND #( WHEN o_jp_common IS BOUND
                                               THEN o_jp_common
                                               ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD handle_clear.
    CLEAR: g_addressid, g_companycode, g_json_string,
           g_glaccount, g_date.

    CLEAR: es_resp_addrid, es_resp_cocode.
  ENDMETHOD.


  METHOD handle_get_addressid.

    DATA: lv_addressid TYPE ad_addrnum.

    lv_addressid = g_addressid.
    o_jp_common->get_address_id_details(
                EXPORTING
                addressid = lv_addressid
                IMPORTING
                o_addressiddetails = DATA(ls_addressiddetails)
            ).

    cv_message = xco_cp_json=>data->from_abap( ls_addressiddetails )->apply( VALUE #(
        ( xco_cp_json=>transformation->underscore_to_pascal_case )
        ) )->to_string( ).

  ENDMETHOD.


  METHOD handle_get_bangcandoiphatsinh.
    TYPES: BEGIN OF lty_split,
             string TYPE zde_char100,
           END OF lty_split,

           BEGIN OF lty_bangcandoiphatsinh,
             CompanyCode                    TYPE bukrs,
             GLAccount                      TYPE hkont,
             CompanyCodeCurrency            TYPE waers,
             GLAccountName                  TYPE zde_char100,
             PostingdateFrom                TYPE budat,
             PostingdateTo                  TYPE budat,
             StartingBalanceInCompanyCode   TYPE zde_dmbtr,
             DebitBalanceofReportingPeriod  TYPE zde_dmbtr,
             CreditBalanceofReportingPeriod TYPE zde_dmbtr,
             EndingBalanceInCompanyCode     TYPE zde_dmbtr,
           END OF lty_bangcandoiphatsinh.

    DATA: et_bangcandoiphatsinh TYPE TABLE OF lty_bangcandoiphatsinh.

    DATA: ir_companycode  TYPE tt_ranges,
          ir_postingdate  TYPE tt_ranges,
          ir_glaccount    TYPE tt_ranges,
          ir_documentdate TYPE tt_ranges,
          ir_fiscalyear   TYPE tt_ranges.

    DATA: lv_fromdate TYPE budat, "DD/MM/YYYY
          lv_todate   TYPE budat.

    DATA: lt_split TYPE TABLE OF lty_split.

    SPLIT g_companycode AT '%2C' INTO TABLE lt_split.
    LOOP AT lt_split INTO DATA(ls_split).
      APPEND VALUE #(  sign = 'I' option = 'CP' low = ls_split-string ) TO ir_companycode.
    ENDLOOP.

    SPLIT g_glaccount AT '%2C' INTO TABLE lt_split.
    LOOP AT lt_split INTO ls_split.
      APPEND VALUE #(  sign = 'I' option = 'CP' low = ls_split-string ) TO ir_glaccount.
    ENDLOOP.

    lv_fromdate = g_fromdate.
    lv_todate = g_todate.

    APPEND VALUE #( sign = 'I' option = 'BT' low = lv_fromdate high = lv_todate ) TO ir_postingdate.

    DATA(o_jp_fi_report) = NEW zcl_jp_get_data_report_fi( ).

    o_jp_fi_report->get_bangcandoiphatsinh(
        EXPORTING
        ir_companycode = ir_companycode
        ir_glaccount  = ir_glaccount
        ir_postingdate = ir_postingdate
        IMPORTING
        e_bangcandoiphatsinh = DATA(lt_bangcandoiphatsinh)
    ).

    MOVE-CORRESPONDING lt_bangcandoiphatsinh TO et_bangcandoiphatsinh.

    LOOP AT et_bangcandoiphatsinh ASSIGNING FIELD-SYMBOL(<fs_bangcandoiphatsinh>).
      <fs_bangcandoiphatsinh>-DebitBalanceofReportingPeriod = <fs_bangcandoiphatsinh>-DebitBalanceofReportingPeriod * 100.
      <fs_bangcandoiphatsinh>-CreditBalanceofReportingPeriod = <fs_bangcandoiphatsinh>-CreditBalanceofReportingPeriod * 100.
      <fs_bangcandoiphatsinh>-StartingBalanceInCompanyCode = <fs_bangcandoiphatsinh>-StartingBalanceInCompanyCode * 100.
      <fs_bangcandoiphatsinh>-EndingBalanceInCompanyCode = <fs_bangcandoiphatsinh>-EndingBalanceInCompanyCode * 100.
    ENDLOOP.

    cv_message = xco_cp_json=>data->from_abap( et_bangcandoiphatsinh )->apply( VALUE #(
    ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).

  ENDMETHOD.


  METHOD handle_get_companycode.
    DATA: lv_companycode TYPE bukrs.
    lv_companycode = g_companycode.

    o_jp_common->get_companycode_details(
                EXPORTING
                i_companycode = lv_companycode
                IMPORTING
                o_companycode = DATA(ls_companycode)
            ).

    cv_message = xco_cp_json=>data->from_abap( ls_companycode )->apply( VALUE #(
          ( xco_cp_json=>transformation->underscore_to_pascal_case )
          ) )->to_string( ).

  ENDMETHOD.


  METHOD handle_get_endingbalance.
    DATA: ir_companycode TYPE o_jp_common->tt_ranges,
          ir_glaccount   TYPE o_jp_common->tt_ranges,
          ir_date        TYPE o_jp_common->tt_ranges.

    APPEND VALUE #( sign = 'I' option = 'EQ' low = g_companycode ) TO ir_companycode.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = g_glaccount ) TO ir_glaccount.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = '' high = g_date ) TO ir_date.

    o_jp_common->get_glaccount_balance(
       EXPORTING
        ir_companycode = ir_companycode
        ir_glaccount = ir_glaccount
        ir_date      = ir_date
       IMPORTING
        o_startbalance = DATA(lt_startBalance)
        o_endbalance = DATA(lt_endBalance) ).

    LOOP AT lt_endBalance ASSIGNING FIELD-SYMBOL(<fs_endBalance>).
      IF <fs_endbalance>-companycodecurrency = 'VND'.
        <fs_endbalance>-amountincompanycode = <fs_endbalance>-amountincompanycode * 100.
      ENDIF.

      IF <fs_endbalance>-transactioncurrency = 'VND'.
        <fs_endbalance>-amountintransaction = <fs_endbalance>-amountintransaction * 100.
      ENDIF.
    ENDLOOP.

    READ TABLE lt_endbalance INDEX 1 INTO DATA(ls_endbalance).

    cv_message = xco_cp_json=>data->from_abap( ls_endbalance )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).
  ENDMETHOD.


  METHOD handle_get_glaccount.

    DATA: lv_companycode TYPE bukrs,
          lv_glaccount   TYPE hkont.

    lv_companycode = g_companycode.
    lv_glaccount = |{ g_glaccount ALPHA = IN }|.
    o_jp_common->get_glaccount_details(
        EXPORTING
        companycode = lv_companycode
        glaccount = lv_glaccount
        IMPORTING
        o_glaccount = DATA(ls_glaccount)
    ).

    cv_message = xco_cp_json=>data->from_abap( ls_glaccount )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).

  ENDMETHOD.


  METHOD handle_get_openingbalance.
    DATA: ir_companycode TYPE o_jp_common->tt_ranges,
          ir_glaccount   TYPE o_jp_common->tt_ranges,
          ir_date        TYPE o_jp_common->tt_ranges.

    APPEND VALUE #( sign = 'I' option = 'EQ' low = g_companycode ) TO ir_companycode.

    g_char10 = |{ g_glaccount ALPHA = IN }|.

    APPEND VALUE #( sign = 'I' option = 'EQ' low = g_char10 ) TO ir_glaccount.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = g_date ) TO ir_date.

    o_jp_common->get_glaccount_balance(
       EXPORTING
        ir_companycode = ir_companycode
        ir_glaccount = ir_glaccount
        ir_date      = ir_date
       IMPORTING
        o_startbalance = DATA(lt_startBalance) ).

    LOOP AT lt_startbalance ASSIGNING FIELD-SYMBOL(<fs_startBalance>).
      IF <fs_startbalance>-companycodecurrency = 'VND'.
        <fs_startbalance>-amountincompanycode = <fs_startbalance>-amountincompanycode * 100.
      ENDIF.

      IF <fs_startbalance>-transactioncurrency = 'VND'.
        <fs_startbalance>-amountintransaction = <fs_startbalance>-amountintransaction * 100.
      ENDIF.
    ENDLOOP.

    READ TABLE lt_startbalance INDEX 1 INTO DATA(ls_startbalance).

    cv_message = xco_cp_json=>data->from_abap( ls_startbalance )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).

  ENDMETHOD.


  METHOD handle_get_soquytienmat.
    TYPES: BEGIN OF lty_soquytienmat,
             CompanyCode            TYPE bukrs,
             AccountingDocument     TYPE belnr_d,
             FiscalYear             TYPE gjahr,
             AccountingDocumentItem TYPE buzei,
             stt                    TYPE int4,
             AccountingDocumentType TYPE blart,

             PostingDate            TYPE budat,

             DocumentDate           TYPE bldat,

             GLAccount              TYPE hkont,
             DebitCreditCode        TYPE shkzg,

             CompanyCodeCurrency    TYPE waers,
             TransactionCurrency    TYPE waers,

             businesspartner        TYPE zde_char10,
             Doituong               TYPE zde_bp_name,

             SoHieuCTThu            TYPE xblnr,
             SoHieuCTChi            TYPE xblnr,
             Diengiai               TYPE zde_char255,

             OffsettingAccount      TYPE hkont,

             DebitAmountInCoCode    TYPE zde_dmbtr,
             CreditAmountInCoCode   TYPE zde_dmbtr,

             DebitAmountInTrans     TYPE zde_dmbtr,
             CreditAmountInTrans    TYPE zde_dmbtr,


             BalanceInCoCode        TYPE zde_dmbtr,
             BalanceInTrans         TYPE zde_dmbtr,

             IsNegativePosting      TYPE abap_boolean,

             GhiChu                 TYPE zde_char255,

             CreationUser           TYPE abp_creation_user,
             CreationDate           TYPE abp_creation_date,
             CreationTime           TYPE abp_creation_time,
           END OF lty_soquytienmat.

    DATA: et_soquytienmat TYPE TABLE OF lty_soquytienmat.

    DATA: ir_companycode  TYPE tt_ranges,
          ir_postingdate  TYPE tt_ranges,
          ir_glaccount    TYPE tt_ranges,
          ir_documentdate TYPE tt_ranges,
          ir_fiscalyear   TYPE tt_ranges.

    DATA: lv_fromdate TYPE budat, "DD/MM/YYYY
          lv_todate   TYPE budat.

*    lv_fromdate = g_fromdate+6(4) && g_fromdate+3(2) && g_fromdate+0(2).
*    lv_todate = g_todate+6(4) && g_todate+3(2) && g_todate+0(2).

    lv_fromdate = g_fromdate.
    lv_todate = g_todate.

    APPEND VALUE #( sign = 'I' option = 'EQ' low = g_companycode ) TO ir_companycode.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = g_glaccount ) TO ir_glaccount.
    APPEND VALUE #( sign = 'I' option = 'BT' low = lv_fromdate high = lv_todate ) TO ir_postingdate.

    DATA(o_jp_fi_report) = NEW zcl_jp_get_data_report_fi( ).

    o_jp_fi_report->get_soquytienmat(
        EXPORTING
        ir_companycode = ir_companycode
        ir_glaccount = ir_glaccount
        ir_postingdate = ir_postingdate
        IMPORTING
        e_soquytienmat = DATA(lt_soquytienmat)
    ).

    MOVE-CORRESPONDING lt_soquytienmat TO et_soquytienmat.

    LOOP AT et_soquytienmat ASSIGNING FIELD-SYMBOL(<fs_soquytienmat>).
      IF <fs_soquytienmat>-CompanyCodeCurrency = 'VND'.
        <fs_soquytienmat>-DebitAmountInCoCode = <fs_soquytienmat>-DebitAmountInCoCode * 100.
        <fs_soquytienmat>-CreditAmountInCoCode = <fs_soquytienmat>-CreditAmountInCoCode * 100.
        <fs_soquytienmat>-BalanceInCoCode = <fs_soquytienmat>-BalanceInCoCode * 100.
      ENDIF.

      IF <fs_soquytienmat>-TransactionCurrency = 'VND'.
        <fs_soquytienmat>-DebitAmountInTrans = <fs_soquytienmat>-DebitAmountInTrans * 100.
        <fs_soquytienmat>-CreditAmountInTrans = <fs_soquytienmat>-CreditAmountInTrans * 100.
        <fs_soquytienmat>-BalanceInTrans = <fs_soquytienmat>-BalanceInTrans * 100.
      ENDIF.

    ENDLOOP.

    cv_message = xco_cp_json=>data->from_abap( et_soquytienmat )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
          ) )->to_string( ).

  ENDMETHOD.


  METHOD handle_post_cfid_temp.
    DATA: lt_request TYPE TABLE OF zst_cfid_request.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json        = uv_message
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

    DATA: lt_cfid_temp TYPE TABLE OF ztb_cfid_temp,
          ls_cfid_temp TYPE ztb_cfid_temp.

    SELECT * FROM ztb_cfid_temp INTO TABLE @DATA(lt_cfid_deleted).
    IF sy-subrc EQ 0.
      DELETE ztb_cfid_temp FROM TABLE @lt_cfid_deleted.
    ENDIF.

*    READ TABLE lt_request INTO DATA(ls_request) INDEX 1.
*    LOOP AT ls_request-items INTO DATA(ls_items).
*      ls_cfid_temp-cfid = ls_items-cashflowid.
*      ls_cfid_temp-documentitem = ls_items-row.
*      ls_cfid_temp-ztype = ls_request-activetab.
*      APPEND ls_cfid_temp TO lt_cfid_temp.
*      CLEAR: ls_cfid_temp.
*    ENDLOOP.

    IF lt_cfid_temp IS NOT INITIAL.
      MODIFY ztb_cfid_temp FROM TABLE @lt_cfid_temp.
    ENDIF.

  ENDMETHOD.


  METHOD handle_post_firud_cf_off_acc.

    TYPES: BEGIN OF lty_request,
             rldnr     TYPE fins_ledger,
             bukrs     TYPE bukrs,
             gjahr     TYPE gjahr,
             belnr     TYPE belnr_d,
             docln     TYPE zde_char6,
             offs_item TYPE zde_char6,
             drcrk     TYPE shkzg,
             racct     TYPE hkont,
             lokkt     TYPE zde_char10,
             ktop2     TYPE zde_char10,
             blart     TYPE blart,
             budat     TYPE zde_char16,
             rmvct     TYPE rmvct,
             mwskz     TYPE mwskz,
             rfarea    TYPE zde_char16,
             buzei     TYPE buzei,
             hsl       TYPE zde_dmbtr,
             rhcur     TYPE hwaer,
             ksl       TYPE zde_dmbtr,
             rkcur     TYPE waers,
           END OF lty_request.

    DATA: ls_request      TYPE lty_request,
          lt_request      TYPE TABLE OF lty_request,

          ls_firud_cf_off TYPE zfirud_cf_off,
          lt_firud_cf_off TYPE TABLE OF zfirud_cf_off.


*    xco_cp_json=>data->from_string( uv_message )->apply( VALUE #(
*     ( xco_cp_json=>transformation->pascal_case_to_underscore )
*    ) )->write_to( REF #( lt_request ) ).

    /ui2/cl_json=>deserialize(
      EXPORTING
        json        = uv_message
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

    LOOP AT lt_request ASSIGNING FIELD-SYMBOL(<fs_request>).
      IF <fs_request>-rhcur = 'VND'.
        <fs_request>-hsl = <fs_request>-hsl / 100.
      ENDIF.

      IF <fs_request>-rkcur = 'VND'.
        <fs_request>-ksl = <fs_request>-ksl / 100.
      ENDIF.

      <fs_request>-belnr = |{ <fs_request>-belnr ALPHA = IN }|.
      <fs_request>-budat = <fs_request>-budat+6(4) && <fs_request>-budat+3(2) && <fs_request>-budat+0(2).
    ENDLOOP.

    IF lt_request IS NOT INITIAL.
      MOVE-CORRESPONDING lt_request TO lt_firud_cf_off.
      MODIFY zfirud_cf_off FROM TABLE @lt_firud_cf_off.
    ENDIF.

    DATA: e_message TYPE zde_char100.
    IF sy-subrc EQ 0.
      e_message = 'Save data successfull!'.

      cv_message = xco_cp_json=>data->from_abap( e_message )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
          ) )->to_string( ).
    ENDIF.
  ENDMETHOD.


  METHOD handle_post_sinvoicedata.

    DATA(o_einvoice_data)    = NEW zcl_einvoice_data( ).
    DATA(o_einvoice_process) = NEW zcl_einvoice_process( ).
    DATA(o_sinvoice)         = NEW zcl_manage_viettel_einvoices( ).

    TYPES: BEGIN OF lty_request,
             companycode        TYPE bukrs,
             accountingdocument TYPE belnr_d,
             fiscalyear         TYPE gjahr,
             usertype           TYPE zjp_a_hddt_h-usertype,
             currencytype       TYPE zjp_a_hddt_h-currencytype,
             typeofdate         TYPE zjp_a_hddt_h-typeofdate,
             einvoicetype       TYPE zjp_a_hddt_h-einvoicetype,
           END OF lty_request.

    DATA: ls_request TYPE lty_request.

    DATA: ls_page_info          TYPE zcl_jp_common_core=>st_page_info,

          ir_companycode        TYPE zcl_jp_common_core=>tt_ranges,
          ir_accountingdocument TYPE zcl_jp_common_core=>tt_ranges,
          ir_glaccount          TYPE zcl_jp_common_core=>tt_ranges,
          ir_fiscalyear         TYPE zcl_jp_common_core=>tt_ranges,
          ir_postingdate        TYPE zcl_jp_common_core=>tt_ranges,
          ir_documentdate       TYPE zcl_jp_common_core=>tt_ranges,
          ir_statussap          TYPE zcl_jp_common_core=>tt_ranges,
          ir_einvoicenumber     TYPE zcl_jp_common_core=>tt_ranges,
          ir_einvoicetype       TYPE zcl_jp_common_core=>tt_ranges,
          ir_currencytype       TYPE zcl_jp_common_core=>tt_ranges,
          ir_usertype           TYPE zcl_jp_common_core=>tt_ranges,
          ir_typeofdate         TYPE zcl_jp_common_core=>tt_ranges,
          ir_createdbyuser      TYPE zcl_jp_common_core=>tt_ranges,
          ir_enduser            TYPE zcl_jp_common_core=>tt_ranges,
          ir_testrun            TYPE zcl_jp_common_core=>tt_ranges
          .

    "first deserialize the request
    xco_cp_json=>data->from_string( uv_message )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore )
    ) )->write_to( REF #( ls_request ) ).

    APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_request-companycode ) TO ir_companycode.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_request-accountingdocument ) TO ir_accountingdocument.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_request-fiscalyear ) TO ir_fiscalyear.

    APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_request-usertype ) TO ir_usertype.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_request-currencytype ) TO ir_currencytype.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_request-einvoicetype ) TO ir_einvoicetype.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_request-typeofdate ) TO ir_typeofdate.

    TRY.
        o_einvoice_data->get_einvoice_data(
          EXPORTING
            ir_companycode        = ir_companycode
            ir_accountingdocument = ir_accountingdocument
            ir_fiscalyear         = ir_fiscalyear
            ir_postingdate        = ir_postingdate
            ir_documentdate       = ir_documentdate
            ir_statussap          = ir_statussap
            ir_einvoicenumber     = ir_einvoicenumber
            ir_einvoicetype       = ir_einvoicetype
            ir_currencytype       = ir_currencytype
            ir_usertype           = ir_usertype
            ir_typeofdate         = ir_typeofdate
            ir_createdbyuser      = ir_createdbyuser
            ir_enduser            = ir_enduser
            ir_testrun            = ir_testrun
          IMPORTING
            it_einvoice_header    = DATA(lt_headers)
            it_einvoice_item      = DATA(lt_items)
            it_returns            = DATA(lt_returns)
        ).

      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    LOOP AT lt_headers INTO DATA(ls_header).
      ls_header-testrun = 'X'.
      TRY.
          o_einvoice_process->get_password(
            EXPORTING
              i_document = ls_header
            IMPORTING
              e_userpass = DATA(ls_userpass)
              e_return   = DATA(ls_return)
          ).
        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.

      TRY.
          IF ls_header-adjusttype IS NOT INITIAL.
            o_sinvoice->adjust_sinvoices(
              EXPORTING
                i_action   = 'ADJUST'
                i_einvoice = ls_header
                i_items    = lt_items
                i_userpass = ls_userpass
              IMPORTING
*               e_status   = gs_status
*               e_docsrc   = gs_docsrc
                e_json     = DATA(lv_json)
                e_return   = ls_return
            ).
          ELSE.
            o_sinvoice->create_sinvoices(
              EXPORTING
                i_action   = 'CREATE'
                i_einvoice = ls_header
                i_items    = lt_items
                i_userpass = ls_userpass
              IMPORTING
*               e_status   = gs_status
*               e_docsrc   = gs_docsrc
                e_json     = lv_json
                e_return   = ls_return
            ).
          ENDIF.

          SELECT SINGLE url_value FROM zjp_hddt_url WHERE action = 'PreviewInvoiceDraft'
            AND id_sys = 'VIETTEL' INTO @DATA(lv_url) PRIVILEGED ACCESS.

          o_sinvoice->post_sinvoices(
            EXPORTING
              i_userpass = ls_userpass
              i_context  = lv_json
              i_prefix   = lv_url
            IMPORTING
              e_context  = DATA(lv_context)
              e_return   = ls_return ).

        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.
    ENDLOOP.

    IF ls_return IS INITIAL.
      cv_message = cv_message = xco_cp_json=>data->from_abap( lv_context )->apply( VALUE #(
    ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).
    ELSE.
      cv_message = xco_cp_json=>data->from_abap( ls_return )->apply( VALUE #(
    ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).
    ENDIF.

  ENDMETHOD.


  METHOD handle_unknown_case.
    " Xử lý khi method không tồn tại
    DATA(lv_message) =  'Invalid method or parameter'.

    cv_message = xco_cp_json=>data->from_abap( lv_message )->apply( VALUE #(
        ( xco_cp_json=>transformation->underscore_to_pascal_case )
        ) )->to_string( ).
  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.

    DATA: lt_parameters TYPE abap_parmbind_tab.
    DATA: ls_line LIKE LINE OF lt_parameters.
    FIELD-SYMBOLS: <lv_value> TYPE any.

    me->get_instance( ).

    me->handle_clear( ).

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
        WHEN 'companycode'.
          g_companycode = lv_val.
        WHEN 'addressid'.
          g_addressid = lv_val.
        WHEN 'date'.
          g_date = lv_val.
        WHEN 'fromdate'.
          g_fromdate = lv_val.
        WHEN 'todate'.
          g_todate = lv_val.
        WHEN 'glaccount'.
*          g_glaccount = |{ lv_val ALPHA = IN }|.
          g_glaccount = lv_val.
        WHEN 'accountingdocument'.
*          g_accountingdocument = |{ lv_val ALPHA = IN }|.
          g_accountingdocument = lv_val.
        WHEN 'fiscalyear'.
          g_fiscalyear = lv_val.
        WHEN 'resNo'.
          g_reservation = lv_val.
        WHEN 'resItm'.
          g_reservationitem = lv_val.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

    IF lv_method = 'post' OR lv_method = 'POST'.
*    CASE lv_name.
*      WHEN 'sinvoicedata' OR 'firud_cf_off_acc'.
      ls_line-name  = 'UV_MESSAGE' .
      ls_line-kind  = cl_abap_objectdescr=>exporting .
      ls_line-value = REF #( lv_req_body ).
      INSERT ls_line INTO TABLE lt_parameters .
*      WHEN OTHERS.
*
*    ENDCASE.
    ENDIF.

    DATA(lv_dyn_method) = |handle_{ to_lower( lv_method ) }_{ to_lower( lv_name ) }|.
    TRANSLATE lv_dyn_method TO UPPER CASE.

*    lt_parameters = VALUE #(
*    ( name = 'CV_MESSAGE'
*      kind = cl_abap_objectdescr=>changing
*      value = REF #( g_json_string ) )
*    ).

    ls_line-name  = 'CV_MESSAGE' .
    ls_line-kind  = cl_abap_objectdescr=>changing .
    ls_line-value = REF #( g_json_string ).
    INSERT ls_line INTO TABLE lt_parameters .

    DATA(lo_self) = NEW zcl_http_common_core( ).
*** Call Methods:
    TRY.
        CALL METHOD lo_self->(lv_dyn_method)
          PARAMETER-TABLE lt_parameters.
      CATCH cx_sy_dyn_call_illegal_method INTO DATA(lx_dyn).
        " Trường hợp method không tồn tại
        CALL METHOD lo_self->('HANDLE_UNKNOWN_CASE')
          PARAMETER-TABLE lt_parameters.
    ENDTRY.

*** Response
    response->set_status('200').

*** Setup -> Response content-type json
    response->set_header_field( i_name = c_header_content
      i_value = c_content_type ).

    response->set_text( g_json_string ).

  ENDMETHOD.


  METHOD handle_get_phieuketoan.
    DATA: ir_companycode        TYPE tt_ranges,
          ir_accountingdocument TYPE tt_ranges,
          ir_fiscalyear         TYPE tt_ranges.

    TYPES: BEGIN OF lty_phieuketoan_items,
             CompanyCode               TYPE bukrs,
             AccountingDocument        TYPE belnr_d,
             FiscalYear                TYPE gjahr,
             LegderGLItem              TYPE zde_char6,

             PostingDate               TYPE budat,
             DocumentDate              TYPE bldat,
             AccountingDocumentType    TYPE blart,

             GLAccount                 TYPE hkont,

             AbsoluteExchangeRate      TYPE zde_dmbtr,

             DocumentItemText          TYPE sgtxt,

             DebitAmountInCompanyCode  TYPE zde_dmbtr,

             CreditAmountInCompanyCode TYPE zde_dmbtr,

             CompanyCodeCurrency       TYPE waers,

             DebitAmountInTransaction  TYPE zde_dmbtr,

             CreditAmountInTransaction TYPE zde_dmbtr,

             TransactionCurrency       TYPE waers,

             Customer                  TYPE kunnr,
             Supplier                  TYPE lifnr,

             DebitCreditCode           TYPE shkzg,
             IsNegativePosting         TYPE abap_boolean,
           END OF lty_phieuketoan_items.

    DATA: et_phieuketoan_items TYPE TABLE OF lty_phieuketoan_items.

    APPEND VALUE #( sign = 'I' option = 'EQ' low = g_companycode ) TO ir_companycode.

    APPEND VALUE #( sign = 'I' option = 'EQ' low = g_fiscalyear ) TO ir_fiscalyear.

    g_char10 = |{ g_accountingdocument ALPHA = IN }|.

    APPEND VALUE #( sign = 'I' option = 'EQ' low = g_char10 ) TO ir_accountingdocument.

    DATA(o_jp_fi_report) = NEW zcl_jp_get_data_report_fi( ).

    o_jp_fi_report->get_phieuketoan(
        EXPORTING
        ir_companycode = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear = ir_fiscalyear
        IMPORTING
        e_phieuketoan = DATA(lt_phieuketoan)
        e_phieuketoan_items = DATA(lt_phieuketoan_items)

    ).

    MOVE-CORRESPONDING lt_phieuketoan_items TO et_phieuketoan_items.

    LOOP AT et_phieuketoan_items ASSIGNING FIELD-SYMBOL(<fs_phieuketoan_items>).
      IF <fs_phieuketoan_items>-companycodecurrency = 'VND'.
        <fs_phieuketoan_items>-debitamountincompanycode = <fs_phieuketoan_items>-debitamountincompanycode * 100.
        <fs_phieuketoan_items>-creditamountincompanycode = <fs_phieuketoan_items>-creditamountincompanycode * 100.
      ENDIF.

      IF <fs_phieuketoan_items>-transactioncurrency = 'VND'.
        <fs_phieuketoan_items>-debitamountintransaction = <fs_phieuketoan_items>-debitamountintransaction * 100.
        <fs_phieuketoan_items>-creditamountintransaction = <fs_phieuketoan_items>-creditamountintransaction * 100.
      ENDIF.
    ENDLOOP.

    cv_message = xco_cp_json=>data->from_abap( et_phieuketoan_items )->apply( VALUE #(
    ( xco_cp_json=>transformation->underscore_to_pascal_case )
        ) )->to_string( ).
  ENDMETHOD.


  METHOD handle_get_phieuketoan_header.

    DATA: ir_companycode        TYPE tt_ranges,
          ir_accountingdocument TYPE tt_ranges,
          ir_fiscalyear         TYPE tt_ranges.

    TYPES: BEGIN OF lty_request,
             companycodename TYPE string,
             companycodeaddr TYPE string,
             bpname          TYPE string,
             bpaddr          TYPE string,
             sdate           TYPE string,
           END OF lty_request.

    DATA: ls_request TYPE lty_request.

    APPEND VALUE #( sign = 'I' option = 'EQ' low = g_companycode ) TO ir_companycode.

    APPEND VALUE #( sign = 'I' option = 'EQ' low = g_fiscalyear ) TO ir_fiscalyear.

    g_char10 = |{ g_accountingdocument ALPHA = IN }|.

    APPEND VALUE #( sign = 'I' option = 'EQ' low = g_char10 ) TO ir_accountingdocument.

    DATA(o_jp_fi_report) = NEW zcl_jp_get_data_report_fi( ).

    o_jp_fi_report->get_phieuketoan(
        EXPORTING
        ir_companycode = ir_companycode
        ir_accountingdocument = ir_accountingdocument
        ir_fiscalyear = ir_fiscalyear
        IMPORTING
        e_phieuketoan = DATA(lt_phieuketoan)
        e_phieuketoan_items = DATA(lt_phieuketoan_items)

    ).

    READ TABLE lt_phieuketoan INTO DATA(ls_phieuketoan) INDEX 1.

    ls_request-sdate = |Ngày { ls_phieuketoan-PostingDate+6(2) } tháng { ls_phieuketoan-PostingDate+4(2) } năm { ls_phieuketoan-PostingDate+0(4) }|.

    o_jp_common->get_companycode_details(
        EXPORTING
        i_companycode = ls_phieuketoan-CompanyCode
        IMPORTING
        o_companycode = DATA(ls_companycode)
    ).

    ls_request-companycodename = ls_companycode-companycodename.
    ls_request-companycodeaddr = ls_companycode-companycodeaddr.

    DATA: i_document TYPE zst_document_info.

    MOVE-CORRESPONDING ls_phieuketoan TO i_document.

    o_jp_common->get_businesspartner_details(
        EXPORTING
        i_document = i_document
        IMPORTING
        o_bpdetails = DATA(ls_bpdetails)
    ).

    ls_request-bpname = ls_bpdetails-bpname.
    ls_request-bpaddr = ls_bpdetails-bpaddress.

    cv_message = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
    ( xco_cp_json=>transformation->underscore_to_pascal_case )
        ) )->to_string( ).
  ENDMETHOD.


  METHOD handle_get_salesorder.
*    DATA: lv_reservation     TYPE rsnum,
*          lv_reservationitem TYPE rspos.
*
*    lv_reservation = |{ g_reservation ALPHA = IN }|.
*    lv_reservationitem = |{ g_reservationitem ALPHA = IN }|.
*
*    DATA: lr_resitem TYPE tt_ranges.
*    IF lv_reservationitem IS NOT INITIAL.
*      APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_reservationitem ) TO lr_resitem.
*    ENDIF.
*
*    SELECT Reservation ,
*           ReservationItem,
*           YY1_SalesOrderSO_RES AS SalesOrder ,
*           YY1_SalesOrderItem_RES AS SalesOrderItem
*    FROM I_ReservationDocumentItemTP
*    WHERE Reservation = @lv_reservation
*    AND ReservationItem IN @lr_resitem
*    INTO TABLE @DATA(lt_ResDocItemTP).
*
*    SORT lt_resdocitemtp BY Reservation ReservationItem ASCENDING.
*    READ TABLE lt_resdocitemtp INDEX 1 INTO DATA(ls_resdocitemtp).
*
*    cv_message = xco_cp_json=>data->from_abap( ls_resdocitemtp )->apply( VALUE #(
*    ( xco_cp_json=>transformation->underscore_to_pascal_case )
*        ) )->to_string( ).
  ENDMETHOD.
ENDCLASS.

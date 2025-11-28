CLASS zcl_jp_common_core DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           BEGIN OF ty_page_info,
             paging           TYPE REF TO if_rap_query_paging,
             page_size        TYPE int8,
             offset           TYPE int8,
             requested_fields TYPE if_rap_query_request=>tt_requested_elements,
             sort_order       TYPE if_rap_query_request=>tt_sort_elements,
             ro_filter        TYPE REF TO if_rap_query_filter,
             entity_id        TYPE string,
           END OF ty_page_info,

           BEGIN OF ty_balance,
             companycode         TYPE bukrs,
             glaccount           TYPE hkont,
             amountincompanycode TYPE zde_dmbtr,
             amountintransaction TYPE zde_dmbtr,
             companycodecurrency TYPE waers,
             transactioncurrency TYPE waers,
           END OF ty_balance,

           BEGIN OF zy_fins_acdoc_header_in,
             companycode                  TYPE bukrs,
             accountingdocument           TYPE belnr_d,
             fiscalyear                   TYPE gjahr,
             transactioncode              TYPE tcode,
             accountingdocumenttype       TYPE blart,
             postingdate                  TYPE budat,
             documentdate                 TYPE bldat,
             accountingdocumentheadertext TYPE zde_char100,
           END OF zy_fins_acdoc_header_in,

           BEGIN OF zy_fins_acdoc_item_in,
             accountingdocumentitem     TYPE buzei,
             clearingaccountingdocument TYPE augbl,
             postingkey                 TYPE bschl,
             financialaccounttype       TYPE koart,
             debitcreditcode            TYPE shkzg,
             businessarea               TYPE gsber,
             taxcode                    TYPE mwskz,
           END OF zy_fins_acdoc_item_in,

*           BEGIN OF ty_is_fields_in,
*             cashjournal            TYPE char4,
*             companycode            TYPE char4,
*             fiscalyear             TYPE char4,
*             postingnumber          TYPE zde_char10,
*             receiptrecipient       TYPE char35,
*             documentnumber         TYPE char16,
*             cashjournaltransaction TYPE char25,
*             documentstatus         TYPE char2,
*             yy1_cashflow_cob       TYPE char2,
*           END OF ty_is_fields_in,

           tt_ranges    TYPE TABLE OF ty_range_option,
           st_page_info TYPE ty_page_info,

           tt_balance   TYPE TABLE OF ty_balance,

           BEGIN OF ty_is_field_in,
             cashjournal                 TYPE char4, "cjnr    char(4) Cash Journal Number
             companycode                 TYPE bukrs,   "char(4) Company Code
             fiscalyear                  TYPE gjahr,   "numc(4) Fiscal Year
             postingnumber               TYPE  belnr_d, "char(10)    Cash Journal Document Number
*                Column cashhreceipt cjamount    curr(23,2)  Cash Journal Amount Field with +/- Sign
*                Column cashhpayment cjamount    curr(23,2)  Cash Journal Amount Field with +/- Sign
*                Column cashhnetamount   cjnet_amount    curr(23,2)  Cash Journal Document Net Amount - Document Currency
*                Column cashhnetamountwt cjnet_payment_wt    curr(23,2)  Net Payment Amount (Withholding Tax Deducted)
*                Column cashhtotalamount cjamount    curr(23,2)  Cash Journal Amount Field with +/- Sign
*                Column taxhamount   fwste   curr(23,2)  Tax Amount in Document Currency
*                Column receiptrecipient cjbpname    char(35)    Name of Receipt Recipient
*                Column documentdate bldat   dats(8) Document Date in Document
             documentnumber              TYPE xblnr1,  "char(16)    Reference Document Number
             postingdate                 TYPE budat,   "dats(8) Posting Date in the Document
*                Column documentstatus   cjdocstat   char(2) Cash Journal Entry Document Status
*                Column accountant   usnam   char(12)    User Name
*                Column printindicator   cjprintind  char(1) Cash Journal Print Indicator
*                Column taxcode  mwskz   char(2) Tax on Sales/Purchases Code
*                Column taxcalculationdate   txdat   dats(8) Date for Determining Tax Rates
*                Column taxrate  msatz_f05l  dec(7,3)    Tax rate
*                Column cashjournaltransaction   cjtranstxt  char(25)    Cash Journal Business Transaction
*                Column positiontext cjpostext   char(50)    Cash Journal Line Item Text
*                Column processstatus    cjdocstat   char(2) Cash Journal Entry Document Status
*                Column vendor   lifnr   char(10)    Account Number of Supplier
*                Column customer kunnr   char(10)    Customer Number
*                Column displaynumber    cjbelnr_disp    char(10)    Cash Journal Document Number for Display
*                Column temporarynumber  cjbelnr_temp    char(10)    Temporary Number for Cash Journal Document
*                Column businessarea gsber   char(4) Business Area
*                Column partnerbusinessarea  pargb   char(4) Trading Partner's Business Area
*                Column tradingpartner   rassc   char(6) Company ID of Trading Partner
*                Column transactiontype  rmvct   char(3) Transaction Type
*                Column functionalarea   fkber   char(16)    Functional Area
*                Column controllingarea  kokrs   char(4) Controlling Area
*                Column costcenter   kostl   char(10)    Cost Center
*                Column activitytype lstar   char(6) Activity Type
*                Column ordernumber  aufnr   char(12)    Order Number
*                Column orderposition    co_posnr    numc(4) Number of Order Item
*                Column accountingindicator  bemot   char(2) Accounting Indicator
*                Column costobject   kstrg   char(12)    Cost Object
*                Column businessprocess  co_prznr    char(12)    Business Process
*                Column profitcenter prctr   char(10)    Profit Center
*                Column partnerprofitcenter  pprctr  char(10)    Partner Profit Center
*                Column wbselement   ps_psp_pnr  numc(8) Work Breakdown Structure Element (WBS Element)
*                Column networknumber    nplnr   char(12)    Network Number for Account Assignment
*                Column operation    vornr   char(4) Activity Number
*                Column mainasset    bf_anln1    char(12)    Main Asset Number
*                Column subasset bf_anln2    char(4) Asset Subnumber
*                Column referencedate    bf_bzdat    dats(8) Reference Date
*                Column assettransactiontype bf_anbwa    char(3) Asset transaction type
*                Column plant    werks_d char(4) Plant
*                Column valuationtype    bwtar_d char(10)    Valuation Type
*                Column valuationarea    bwkey   char(4) Valuation Area
*                Column material matnr   char(40)    Material Number
*                Column origingroup  hrkft   char(4) Origin Group as Subdivision of Cost Element
*                Column originmaterial   hkmat   char(1) Material-related origin
*                Column salesorder   kdauf   char(10)    Sales Order Number
*                Column deliveryschedule kdein   numc(4) Delivery schedule for sales order
*                Column salesorderitem   kdpos   numc(6) Item Number in Sales Order
*                Column jointventure jv_name char(6) Joint Venture
*                Column recoveryindicator    jv_recind   char(2) Recovery Indicator
*                Column recoveryindicatormanual  jv_recid_m  char(1) Indicator: Recovery Indicator Set Manually.
*                Column equitygroup  jv_egroup   char(3) Equity Group
*                Column equitytype   jv_etype    char(3) Equity Type
*                Column partneraccount   jv_part char(10)    Partner account number
*                Column jointventureindicator    jv_condcod  char(2) Joint Venture Indicator (Condition Key)
*                Column flagcrpcalculation   jv_crpcal   char(1) Flag CRP Calculation: Yes or NO
*                Column financialmanagementarea  fikrs   char(4) Financial Management Area
*                Column fundscenter  fistl   char(16)    Funds Center
*                Column financialposition    fipos   char(14)    Commitment Item
*                Column commitmentitem   fm_fipex    char(24)    Commitment Item
*                Column fund bp_geber    char(10)    Fund
*                Column earmarkeddocument    kblnr_fi    char(10)    Document Number for Earmarked Funds
*                Column earmarkeditem    kblpos  numc(3) Earmarked Funds: Document Item
*                Column fundcomplete refseterlk  char(1) Used earmarked funds are set to "Completed".
*                Column personnelnumber  pernr_d numc(8) Personnel Number
*                Column profitabilityobject  rkeobjnr_numc   numc(10)    Deprecated: Profitability Segment
*                Column realestateobject imkey   char(8) Internal Key for Real Estate Object
*                Column accountassignmentcategory    kontt_fi    char(2) Account Assignment Category for Industry Solution
*                Column accountassignmentstring  kontl_fi    char(50)    Acct assignment string for industry-specific acct assignmnts
*                Column leaseoutnumer    smive   char(13)    Lease-Out Number
*                Column grantnumber  gm_grant_nbr    char(20)    Grant
*                Column referencedatesettlement  dabrbez dats(8) Reference date for settlement
*                Column budgetperiod fm_budget_period    char(10)    Budget Period
*                Column fiscalperiod monat   numc(2) Fiscal Period
*                Column sourcesystem fins_cfin_logsystem_sender  char(10)    Source System
*                Column taxjurisdiction  txjcd   char(15)    Tax Jurisdiction
             firstadditionalheaderfield  TYPE char100, "cjdoctext100    "char(100)   Additional Field 1 for Cash Journal Document Header
             secondadditionalheaderfield TYPE char30, "cjdoctext30 "char(30)    Additional Field 2 for Cash Journal Document Header
*                Column linenumer    cjlinenumb  int4(10)    Line Number in Cash Journal Document Table
*                Column meansofpayment   cjmofpaym   char(1) Cash Journal Means of Payment
*                Column checknumber  scknr_eb    numc(13)    13-Digit Check Number
*                Column checkissuer  cjcheckissuer   char(14)    Check Issuer (Cash Journal)
*                Column bankkey  bankk   char(15)    Bank Keys
*                Column bankaccount  bankn35 char(35)    Bank account number
*                Column bankcountry  banks   char(3) Bank Country/Region Key
*                Column checklot cjcheckstack    char(8) Number of Check Lot in Cash Journal
*                Column checkstatus  cjcheckstatus   char(1) Posting Status for Checks in Cash Journal
*                Column checkfiscalyear  cjcheckstackfy  numc(4) Fiscal Year of Check Deposit
*                Column addtionaltext    cjcjtext30  char(30)    Additional Field for Cash Journal
*                Column valuedate    valut   dats(8) Value Date
*                Column assignmentnumber dzuonr  char(18)    Assignment Number
*                Column lineselection    boolean char(1) Boolean Variable (X = True, - = False, Space = Unknown)
*                Column branch   filkd   char(10)    Account Number of the Branch
*                Column reversaldocument cjrevbelnr  char(10)    Reversal Document Number for Cash Journal Document
*                Column exchangerate kursf   dec(9,5)    Exchange Rate
*                Column businessplace    bupla   char(4) Business Place
*                Column sectioncode  secco   char(4) Section Code
*                Column positionnumber   cjbuzei numc(3) Number of Line Item within Cash Journal Document
*                Column positiontype cjpostype   char(2) Cash Journal Item Type
*                Column cashpreceipt cjamount    curr(23,2)  Cash Journal Amount Field with +/- Sign
*                Column cashppayment cjamount    curr(23,2)  Cash Journal Amount Field with +/- Sign
*                Column cashpnetamount   cjnet_amount    curr(23,2)  Cash Journal Document Net Amount - Document Currency
*                Column cashpnetamountwt cjnet_payment_wt    curr(23,2)  Net Payment Amount (Withholding Tax Deducted)
*                Column taxpamount   wmwst   curr(23,2)  Tax Amount in Document Currency
*                Column splitinformation cjdocsplit  char(1) Split Information for Cash Journal Document
*                Column statecentralbank lzbkz   char(3) State Central Bank Indicator
*                Column supplyingcountry landl   char(3) Supplying Country/Region
*                Column taxbaseamount    fwbas   curr(23,2)  Tax Base Amount in Document Currency
*                Column generalledgeraccount hkont   char(10)    General Ledger Account
*                Column segment  fb_segment  char(10)    Segment for Segmental Reporting
*                Column partnersegment   fb_psegment char(10)    Partner Segment for Segmental Reporting
*                Column taxreportingdate vatdate dats(8) Tax Reporting Date
*                Column manualtax    boolean char(1) Boolean Variable (X = True, - = False, Space = Unknown)
*                Column vatnumber    stceg   char(20)    VAT Registration Number
*                Column specialglindicator   umskz   char(1) Special G/L Indicator
*                Column cpdblocked   boolean char(1) Boolean Variable (X = True, - = False, Space = Unknown)
*                Column housebank    hbkid   char(5) Short Key for a House Bank
*                Column accountdetails   hktid   char(5) ID for Account Details
*                Column iban iban    char(34)    IBAN (International Bank Account Number)
*                Column bankcontrolkey   bkont   char(2) Bank Control Key
*                Column dummy_incl_eew_cobl  cfd_dummy   char(1) Custom Fields: Dummy for Use in Extension Includes
*                Column yy1_text2_cob    yy1_text2   char(40)    Text2
*                Column yy1_cashflow_cob yy1_cashflow    char(2) CashFlow
*                Column yy1_department1_cob  yy1_department1 char(20)    Department
*                Column fulfilldate  fot_fulfilldate dats(8) Tax Fulfillment Date
           END OF ty_is_field_in,

           z_fins_acdoc_header_in TYPE zy_fins_acdoc_header_in,
           z_fins_acdoc_item_in   TYPE zy_fins_acdoc_item_in,
           tt_company_addr_info   TYPE TABLE OF zst_companycode_info.
    .

    DATA v1 TYPE string.

    INTERFACES if_t100_message.

    CONSTANTS:
      BEGIN OF msg_required,
        msgid TYPE symsgid VALUE 'ZCFID_MSG',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'V1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF msg_required.

    METHODS constructor
      IMPORTING
        VALUE(v1) TYPE string OPTIONAL. "business transaction

    INTERFACES if_oo_adt_classrun.

    CLASS-DATA:
      "Instance Singleton
      mo_instance             TYPE REF TO zcl_jp_common_core,

      "Table customer info
      gt_businesspartner_info TYPE SORTED TABLE OF zst_businesspartner_info WITH UNIQUE KEY bpnumber.

    CLASS-METHODS:
      "Contructor
      get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_jp_common_core,

      "Get fillter app
      get_fillter_app IMPORTING io_request             TYPE REF TO if_rap_query_request
                                io_response            TYPE REF TO if_rap_query_response

                      EXPORTING ir_companycode         TYPE tt_ranges
                                ir_accountingdocument  TYPE tt_ranges
                                ir_glaccount           TYPE tt_ranges
                                ir_fiscalyear          TYPE tt_ranges
                                ir_buzei               TYPE tt_ranges
                                ir_postingdate         TYPE tt_ranges
                                ir_documentdate        TYPE tt_ranges

                                ir_statussap           TYPE tt_ranges
                                ir_einvoicenumber      TYPE tt_ranges
                                ir_einvoicetype        TYPE tt_ranges
                                ir_currencytype        TYPE tt_ranges
                                ir_usertype            TYPE tt_ranges
                                ir_typeofdate          TYPE tt_ranges

                                ir_createdbyuser       TYPE tt_ranges
                                ir_enduser             TYPE tt_ranges
                                ir_testrun             TYPE tt_ranges

                                ir_businesspartner     TYPE tt_ranges

                                ir_documenttype        TYPE tt_ranges
                                ir_customer            TYPE tt_ranges
                                ir_supplier            TYPE tt_ranges

                                ir_documentitem        TYPE tt_ranges

                                ir_documentsource      TYPE tt_ranges
                                ir_fiscalyearsource    TYPE tt_ranges
                                ir_fiscalperiod        TYPE tt_ranges
                                ir_transactioncurrency TYPE tt_ranges

                                ir_billingdocument     TYPE tt_ranges

                                ir_billingtype         TYPE tt_ranges

                                ir_accountant          TYPE tt_ranges
                                ir_createby            TYPE tt_ranges

                                wa_page_info           TYPE st_page_info

                      ,

      "Method get BusinessPartner info
      get_businesspartner_details IMPORTING i_document  TYPE zst_document_info OPTIONAL
                                  EXPORTING o_bpdetails TYPE zst_businesspartner_info,

      "Method get Company Code info
      get_companycode_details IMPORTING i_companycode TYPE bukrs
                              EXPORTING o_companycode TYPE zst_companycode_info,

      "Method get all Company Code info
      get_companycode_details_all
        EXPORTING o_companycode TYPE tt_company_addr_info,

      "Method get Address ID
      get_address_id_details IMPORTING addressid          TYPE ad_addrnum
                             EXPORTING o_addressiddetails TYPE zst_addresid_info,

      "Method get GLAccount Details
      get_glaccount_details IMPORTING glaccount   TYPE hkont
                                      companycode TYPE bukrs
                            EXPORTING o_glaccount TYPE zst_glaccount_info,

      "Method get Số dư đầu kỳ/Cuối kỳ GLaccount
      get_glaccount_balance IMPORTING ir_companycode TYPE tt_ranges
                                      ir_glaccount   TYPE tt_ranges
                                      ir_date        TYPE tt_ranges

                            EXPORTING o_startbalance TYPE tt_balance
                                      o_endbalance   TYPE tt_balance
                            ,

      get_last_day IMPORTING i_date TYPE zde_date
                   EXPORTING o_date TYPE zde_date,

      get_cfid IMPORTING g_accountingdocheader TYPE z_fins_acdoc_header_in
                         g_accoutingdocitem    TYPE z_fins_acdoc_item_in
               EXPORTING o_cfid                TYPE ztb_cfid_temp
                         text2                 TYPE ztb_cfid_temp-text2,

      save_addtext2 IMPORTING is_field_in TYPE ty_is_field_in
      ,

      post_cfid IMPORTING is_fields_in TYPE string
                RAISING
                          zcl_jp_common_core,

      get_bp_info_new    IMPORTING i_businesspartner TYPE kunnr
                         EXPORTING o_bp_info         TYPE zst_bp_info.

    METHODS get_week_of_date
      IMPORTING
        date_analyzed      TYPE zde_date
      RETURNING
        VALUE(week_number) TYPE i.

  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS get_first_day_of_year_for_date
      IMPORTING
        date_analyzed            TYPE zde_date
      RETURNING
        VALUE(first_day_of_year) TYPE zde_date.

    METHODS get_daynumber_of_date
      IMPORTING
        date_analyzed     TYPE zde_date
      RETURNING
        VALUE(day_number) TYPE i.

ENDCLASS.



CLASS ZCL_JP_COMMON_CORE IMPLEMENTATION.


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


  METHOD get_address_id_details.

    "Customer Address
    SELECT addresseefullname ,                          "#EC CI_NOFIELD
     organizationname1,
     organizationname2,
     organizationname3,
     organizationname4,
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
     WHERE addressid = @addressid ORDER BY PRIMARY KEY
     INTO TABLE @DATA(lt_address_2) .

    READ TABLE lt_address_2 INTO DATA(ls_address_2) INDEX 1.

*    o_addressiddetails-addressname = ls_address_2-AddresseeFullName.
*    o_addressiddetails-addressname = |{ ls_address_2-organizationname1 } { ls_address_2-organizationname2 } { ls_address_2-organizationname3 } { ls_address_2-organizationname4 }|.
    o_addressiddetails-addressname = |{ ls_address_2-organizationname2 }{ ls_address_2-organizationname3 }{ ls_address_2-organizationname4 }|.
    IF o_addressiddetails-addressname IS INITIAL.
      o_addressiddetails-addressname = ls_address_2-organizationname1.
    ENDIF.
    o_addressiddetails-address =
    |{ ls_address_2-housenumber }{ ls_address_2-streetname }{ ls_address_2-streetprefixname1 }{ ls_address_2-streetprefixname2 }{ ls_address_2-streetsuffixname1 }{ ls_address_2-districtname }, { ls_address_2-cityname }|.

    REPLACE ALL OCCURRENCES OF `, , , , , , ,` IN o_addressiddetails-address WITH `,`.
    REPLACE ALL OCCURRENCES OF `, , , , , ,` IN o_addressiddetails-address WITH `,`.
    REPLACE ALL OCCURRENCES OF `, , , , ,` IN o_addressiddetails-address WITH `,`.
    REPLACE ALL OCCURRENCES OF `, , , ,` IN o_addressiddetails-address WITH `,`.
    REPLACE ALL OCCURRENCES OF `, , ,` IN o_addressiddetails-address WITH `,`.
    REPLACE ALL OCCURRENCES OF `, ,` IN o_addressiddetails-address WITH `,`.
    REPLACE ALL OCCURRENCES OF `,,` IN o_addressiddetails-address WITH `,`.


    SHIFT o_addressiddetails-address LEFT DELETING LEADING `,`.
    SHIFT o_addressiddetails-address RIGHT DELETING TRAILING `,`.
    SHIFT o_addressiddetails-address LEFT DELETING LEADING space.

    "Customer Email
    SELECT SINGLE emailaddress FROM i_addrcurdefaultemailaddress "#EC CI_NOFIELD
    WITH PRIVILEGED ACCESS
    WHERE addressid = @addressid
    INTO @o_addressiddetails-emailaddress
    .

    "Customer Telephone
    SELECT SINGLE phoneareacodesubscribernumber FROM i_addrcurdfltlandlinephonenmbr "#EC CI_NOFIELD
    WITH PRIVILEGED ACCESS
    WHERE addressid = @addressid
    INTO @o_addressiddetails-telephonenumber
    .

    o_addressiddetails-country = ls_address_2-country.

  ENDMETHOD.


  METHOD get_businesspartner_details.

    CLEAR: o_bpdetails.

    DATA: lv_url TYPE string VALUE IS INITIAL. "API read BP Details
    DATA: lv_country TYPE land1 VALUE IS INITIAL.

    "--- Kiểm tra mã Business partner có phải là khách vãng lai - onetime?
    IF i_document-customer IS NOT INITIAL.
      SELECT SINGLE isonetimeaccount FROM i_customer WHERE customer = @i_document-customer "#EC CI_NOFIELD
        INTO @DATA(lv_xcpdk).
    ELSE.
      SELECT SINGLE isonetimeaccount FROM i_supplier WHERE customer = @i_document-supplier "#EC CI_NOFIELD
        INTO @lv_xcpdk.
    ENDIF.

    IF sy-subrc NE 0.
      CLEAR: lv_xcpdk.
    ENDIF.

    IF lv_xcpdk IS NOT INITIAL.
      SELECT SINGLE                                     "#EC CI_NOFIELD
            businesspartnername1 AS name1,
            businesspartnername2 AS name2,
            businesspartnername3 AS name3,
            businesspartnername4 AS name4,
            streetaddressname AS stras,
            cityname AS ort01,
            taxid1 AS stcd1,
            accountingclerkinternetaddress AS intad,
            country AS land1
        FROM i_onetimeaccountcustomer
        WHERE accountingdocument = @i_document-accountingdocument AND
              companycode        = @i_document-companycode AND
              fiscalyear         = @i_document-fiscalyear
        INTO @DATA(ls_bsec).

      IF sy-subrc EQ 0. "Nếu Mã khách lẻ

        o_bpdetails-bpname = |{ ls_bsec-name2 } { ls_bsec-name3 } { ls_bsec-name4 } | .
        IF ls_bsec-name2 IS INITIAL AND ls_bsec-name3 IS INITIAL AND ls_bsec-name4 IS INITIAL.
          o_bpdetails-bpname = ls_bsec-name1 .
        ENDIF.
        o_bpdetails-bpaddress = |{ ls_bsec-stras }{ ls_bsec-ort01 }| .
        o_bpdetails-identificationnumber  = ls_bsec-stcd1.
        o_bpdetails-emailaddress = ls_bsec-intad.
        "Country
        lv_country = ls_bsec-land1.

        IF lv_country = 'VN'.
          o_bpdetails-bpaddress = |{ o_bpdetails-bpaddress }, Việt Nam|.
        ELSE.
          SELECT SINGLE countryname FROM i_countrytext
          WHERE country = @lv_country
          INTO @DATA(lv_countryname).
          IF sy-subrc = 0.
            o_bpdetails-bpaddress = |{ o_bpdetails-bpaddress }, { lv_countryname }|.
          ENDIF.
        ENDIF.
        REPLACE ALL OCCURRENCES OF `,,` IN o_bpdetails-bpaddress WITH `,`.

      ENDIF.

    ELSE. "Trường hợp Businesspartner ko phải là khách vãng lai

      IF i_document-customer IS NOT INITIAL.
        READ TABLE gt_businesspartner_info INTO o_bpdetails WITH KEY bpnumber = i_document-customer BINARY SEARCH.
      ELSE.
        READ TABLE gt_businesspartner_info INTO o_bpdetails WITH KEY bpnumber = i_document-supplier BINARY SEARCH.
      ENDIF.

      IF sy-subrc NE 0.
        DATA(lv_index) = sy-index.

        IF i_document-customer IS NOT INITIAL.
          SELECT SINGLE cus~customer AS bpnumber,       "#EC CI_NOFIELD
                        cus~addressid,
                        cus~vatregistration,
                        cus~isonetimeaccount,
                        cus~createdbyuser,
                        cus~creationdate,
                        bp~creationtime,
                        cus~country
          FROM i_customer AS cus
          INNER JOIN i_businesspartner AS bp ON cus~customer = bp~businesspartner
          WHERE cus~customer = @i_document-customer
          INTO CORRESPONDING FIELDS OF @o_bpdetails
          .
        ELSE.
          SELECT SINGLE supp~supplier AS bpnumber,      "#EC CI_NOFIELD
                        supp~addressid,
                        supp~vatregistration,
                        supp~isonetimeaccount,
                        supp~createdbyuser,
                        supp~creationdate,
                        bp~creationtime,
                        supp~country
          FROM i_supplier AS supp
          INNER JOIN i_businesspartner AS bp ON supp~supplier = bp~businesspartner
          WHERE supp~supplier = @i_document-supplier
          INTO CORRESPONDING FIELDS OF @o_bpdetails
          .
        ENDIF.

        lv_country = o_bpdetails-country.

        "Customer Identification Number
        IF i_document-customer IS NOT INITIAL.
          SELECT SINGLE bpidentificationnumber FROM i_bupaidentification "#EC CI_NOFIELD
              WHERE businesspartner = @i_document-customer
               AND bpidentificationtype = 'VATRU'
              INTO @o_bpdetails-identificationnumber
              .
        ELSE.
          SELECT SINGLE bpidentificationnumber FROM i_bupaidentification "#EC CI_NOFIELD
            WHERE businesspartner = @i_document-supplier
             AND bpidentificationtype = 'VATRU'
            INTO @o_bpdetails-identificationnumber
            .
        ENDIF.

        "Customer Address
        zcl_jp_common_core=>get_address_id_details(
          EXPORTING
            addressid          = o_bpdetails-addressid
          IMPORTING
            o_addressiddetails = DATA(ls_addressid)
        ).
**-----------------------------------------------------------------------**
        o_bpdetails-bpname          = ls_addressid-addressname.
        o_bpdetails-bpaddress       = ls_addressid-address.
        o_bpdetails-emailaddress    = ls_addressid-emailaddress.
        o_bpdetails-telephonenumber = ls_addressid-telephonenumber.

        IF lv_country = 'VN'.
          o_bpdetails-bpaddress = |{ o_bpdetails-bpaddress }, Việt Nam|.
        ELSE.
          SELECT SINGLE countryname FROM i_countrytext
          WHERE country = @lv_country
          INTO @lv_countryname.
          IF sy-subrc = 0.
            o_bpdetails-bpaddress = |{ o_bpdetails-bpaddress }, { lv_countryname }|.
          ENDIF.
        ENDIF.
        REPLACE ALL OCCURRENCES OF `,,` IN o_bpdetails-bpaddress WITH `,`.

        INSERT o_bpdetails INTO TABLE gt_businesspartner_info.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD get_companycode_details.

    SELECT SINGLE                                       "#EC CI_NOFIELD
              companycode,
              companycodename,
              addressid,
              vatregistration,
              currency,
              country
*              createdbyuser,
*              creationdate,
*              creationtime
    FROM i_companycode
    WHERE companycode = @i_companycode
    INTO @DATA(ls_companycode)
    .                                                   "#EC CI_NOFIELD

    MOVE-CORRESPONDING ls_companycode TO o_companycode.

    zcl_jp_common_core=>get_address_id_details(
      EXPORTING
        addressid          = o_companycode-addressid
      IMPORTING
        o_addressiddetails = DATA(ls_addressiddetails)
    ).

*    o_companycode-companycodename = ls_addressiddetails-addressname.
    IF ls_companycode-country = 'VN'.
      ls_addressiddetails-address = |{ ls_addressiddetails-address }, Việt Nam|.
    ELSE.
      SELECT SINGLE countryname FROM i_countrytext
      WHERE country = @ls_companycode-country
      INTO @DATA(lv_countryname).
      IF sy-subrc = 0.
        ls_addressiddetails-address = |{ ls_addressiddetails-address }, { lv_countryname }|.
      ENDIF.
    ENDIF.

    o_companycode-companycodeaddr = ls_addressiddetails-address.
    o_companycode-email           = ls_addressiddetails-emailaddress.
    o_companycode-telephone       = ls_addressiddetails-telephonenumber.

  ENDMETHOD.


  METHOD get_fillter_app.

    wa_page_info-paging            = io_request->get_paging( ).

    wa_page_info-page_size         = io_request->get_paging( )->get_page_size( ).

    wa_page_info-offset            = io_request->get_paging( )->get_offset( ).

    wa_page_info-requested_fields  = io_request->get_requested_elements( ).

    wa_page_info-sort_order        = io_request->get_sort_elements( ).

    wa_page_info-ro_filter         = io_request->get_filter( ).

    wa_page_info-entity_id         = io_request->get_entity_id( ).

    TRY.
        DATA(lr_ranges) = wa_page_info-ro_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.

    DATA: ls_postingdate LIKE LINE OF ir_postingdate.

    LOOP AT lr_ranges INTO DATA(ls_ranges).

      CASE ls_ranges-name.
        WHEN 'COMPANYCODE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_companycode.
        WHEN 'ACCOUNTINGDOCUMENT'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_accountingdocument.
        WHEN 'FISCALYEAR'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_fiscalyear.
        WHEN 'ACCOUNTINGDOCUMENTITEM'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_buzei.
        WHEN 'CASHACCOUNTING' OR 'GLACCOUNT'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_glaccount.
        WHEN 'POSTINGDATE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_postingdate.
        WHEN 'DOCUMENTDATE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_documentdate.
        WHEN 'EINVOICENUMBER'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_einvoicenumber.
        WHEN 'EINVOICETYPE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_einvoicetype.
        WHEN 'CURRENCYTYPE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_currencytype.
        WHEN 'STATUSSAP'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_statussap.
        WHEN 'TYPEOFDATE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_typeofdate.
        WHEN 'USERTYPE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_usertype.
        WHEN 'CREATEDBYUSER'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_createdbyuser.
        WHEN 'ENDUSER'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_enduser.
        WHEN 'TESTRUN'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_testrun.
        WHEN 'DOITUONG'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_businesspartner.
        WHEN 'POSTINGDATEFROM'.
          READ TABLE ls_ranges-range INTO DATA(ls_range) INDEX 1.
          ls_postingdate-low = ls_range-low.
        WHEN 'POSTINGDATETO'.
          READ TABLE ls_ranges-range INTO ls_range INDEX 1.
          ls_postingdate-high = ls_range-low.
        WHEN 'ACCOUNTINGDOCUMENTTYPE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_documenttype.
        WHEN 'CUSTOMER'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_customer.
        WHEN 'SUPPLIER'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_supplier.
        WHEN 'LEGDERGLITEM'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_documentitem.
        WHEN 'TRANSACTIONCURRENCY'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_transactioncurrency.
        WHEN 'FISCALPERIOD'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_fiscalperiod.
        WHEN 'ACCOUTINGDOCUMENTSOURCE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_documentsource.
        WHEN 'FISCALYEARSOURCE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_fiscalyearsource.
        WHEN 'ACCOUNTANT'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_accountant.
        WHEN 'CREATEBY'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_createby.
        WHEN 'BILLINGDOCUMENT'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_billingdocument.
        WHEN 'BILLINGDOCUMENTTYPE'.
          MOVE-CORRESPONDING ls_ranges-range TO ir_billingtype.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

    IF ls_postingdate-high IS NOT INITIAL.
      ls_postingdate-option = 'BT'.
    ELSE.
      ls_postingdate-option = 'EQ'.
    ENDIF.

    ls_postingdate-sign = 'I'.
    IF ls_postingdate-low IS NOT INITIAL OR ls_postingdate-high IS NOT INITIAL.
      APPEND ls_postingdate TO ir_postingdate.
    ENDIF.

  ENDMETHOD.


  METHOD get_glaccount_balance.

    FREE: o_endbalance, o_startbalance.

    DATA: lv_startdate TYPE budat VALUE IS INITIAL,
          lv_enddate   TYPE budat VALUE IS INITIAL.

    DATA: ls_balance TYPE ty_balance.

    READ TABLE ir_date INTO DATA(ls_date) INDEX 1.

    lv_startdate = ls_date-low.
    lv_enddate = ls_date-high.

    IF lv_startdate IS NOT INITIAL.

      SELECT
          companycode,
          glaccount,
          debitcreditcode,
          companycodecurrency,
          transactioncurrency,
       SUM( amountincompanycodecurrency ) AS amountincompanycode ,
       SUM( amountintransactioncurrency ) AS amountintransaction
      FROM i_glaccountlineitem
      WHERE companycode        IN @ir_companycode
        AND glaccount          IN @ir_glaccount
        AND postingdate        LT @lv_startdate
        AND ledger = '0L'
      GROUP BY companycode, glaccount, debitcreditcode, companycodecurrency, transactioncurrency
      INTO TABLE @DATA(lt_startbalance)
     .

      LOOP AT lt_startbalance INTO DATA(ls_startbalance).
        MOVE-CORRESPONDING ls_startbalance TO ls_balance.
        COLLECT ls_balance INTO o_startbalance.
        CLEAR: ls_balance.
      ENDLOOP.

    ENDIF.

    IF lv_enddate IS NOT INITIAL.

      SELECT
           companycode,
           glaccount,
           debitcreditcode,
           companycodecurrency,
           transactioncurrency,
       SUM( amountincompanycodecurrency ) AS amountincompanycode ,
       SUM( amountintransactioncurrency ) AS amountintransaction
       FROM i_glaccountlineitem
       WHERE companycode        IN @ir_companycode
         AND glaccount          IN @ir_glaccount
         AND postingdate        LE @lv_enddate
         AND ledger = '0L'
       GROUP BY companycode, glaccount, debitcreditcode, companycodecurrency, transactioncurrency
       INTO TABLE @DATA(lt_endbalance)
      .

      LOOP AT lt_endbalance INTO DATA(ls_endbalance).
        MOVE-CORRESPONDING ls_endbalance TO ls_balance.
        COLLECT ls_balance INTO o_endbalance.
        CLEAR: ls_balance.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.


  METHOD get_glaccount_details.
    CLEAR: o_glaccount.

    SELECT SINGLE a~glaccount, b~glaccountname, a~glaccountcurrency, a~createdbyuser, a~creationdate
    FROM i_glaccountincompanycode AS a INNER JOIN i_glaccounttextincompanycode AS b
    ON a~glaccount = b~glaccount
    AND a~companycode = b~companycode
    WHERE a~glaccount = @glaccount
    AND a~companycode = @companycode
    INTO CORRESPONDING FIELDS OF @o_glaccount
    .

  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    SELECT * FROM ztb_cfid_temp INTO TABLE @DATA(lt_delete).
    DELETE ztb_cfid_temp FROM TABLE @lt_delete.

*    DATA(o_firu_cash) = new cl_firu_cash_flow_off_acc( ).

*    SELECT * FROM zdataco11n INTO TABLE @DATA(lt_data).
*    DELETE zdataco11n FROM TABLE @lt_data.

*    SELECT
*    i_cashjournaldocument_2~companycode,
*    i_cashjournaldocument_2~cashjournal,
*    i_cashjournaldocument_2~fiscalyear,
*    i_cashjournaldocument_2~cashjournaldocumentinternalid,
*    i_cashjournaldocument_2~language,
*    i_cashjournaldocument_2~currency,
*    i_cashjournaldocument_2~documentdate,
*    i_cashjournaldocument_2~taxamountintranscrcy,
*    i_cashjournaldocument_2~cashjournaldocumentnetamount,
*    i_cashjournaldocument_2~whldgtaxdeductednetpaymentamt,
*    i_cashjournaldocument_2~cashjournalreceiptamount,
*    i_cashjournaldocument_2~cashjournalpaymentamount,
*    i_cashjournaldocument_2~amountintransactioncurrency,
*    i_cashjournaldocument_2~receiptrecipientname,
*    i_cashjournaldocument_2~authorizationgroup,
*    i_cashjournaldocument_2~cashjournaldocument,
*    i_cashjournaldocument_2~accountingdocexternalreference,
*    i_cashjournaldocument_2~postingdate,
*    i_cashjournaldocument_2~cashjournaldocumentstatus,
*    i_cashjournaldocument_2~createdbyuser,
*    i_cashjournaldocument_2~cashjournalisprinted,
*    i_cashjournaldocument_2~taxrate,
*    i_cashjournaldocument_2~cashjournaldocumenttext1,
*    i_cashjournaldocument_2~cashjournaldocumenttext2,
*    i_cashjournaldocument_2~cheque,
*    i_cashjournaldocument_2~cashjournalchequeissuer,
*    i_cashjournaldocument_2~bankkey,
*    i_cashjournaldocument_2~bankaccount,
*    i_cashjournaldocument_2~bankcountry,
*    i_cashjournaldocument_2~cashjournalchequelot,
*    i_cashjournaldocument_2~cashjournalchequepostingsts,
*    i_cashjournaldocument_2~cashjournalreversaldocument,
*    i_cashjournaldocument_2~exchangerate,
*    i_cashjournaldocument_2~businessplace,
*    i_cashjournaldocument_2~businesssectioncode,
*    i_cashjournaldocument_2~cashjournaldocumentissplit,
*    i_cashjournaldocument_2~statecentralbankpaymentreason,
*    i_cashjournaldocument_2~supplyingcountry,
*    i_cashjournaldocument_2~chequelotfiscalyear,
*    i_cashjournaldocument_2~valuedate,
*    i_cashjournaldocument_2~taxreportingdate
*     FROM i_cashjournaldocument_2
*     INTO TABLE @DATA(lt_data).
  ENDMETHOD.


  METHOD get_cfid.
    CLEAR: o_cfid.
    DATA: ls_cfid_temp TYPE ztb_cfid_temp.

    SELECT * FROM ztb_cfid_temp
    INTO TABLE @DATA(lt_cfid_temp).

    SORT lt_cfid_temp BY row_abs ASCENDING.

    READ TABLE lt_cfid_temp INTO ls_cfid_temp INDEX 1.
    IF sy-subrc EQ 0.
      text2 = ls_cfid_temp-text2.

      ls_cfid_temp-zcount = ls_cfid_temp-zcount + 1.

      IF g_accountingdocheader-transactioncode = 'FBCJ' AND
         ( g_accountingdocheader-accountingdocumentheadertext NE 'TRANSFER JOURNAL TO BANK' ).

        IF ls_cfid_temp-transact_name = 'VENDOR' AND g_accoutingdocitem-debitcreditcode = 'H'.
          o_cfid = ls_cfid_temp.
*          DELETE ztb_cfid_temp FROM @ls_cfid_temp.
        ELSEIF ls_cfid_temp-transact_name = 'CUSTOMER' AND g_accoutingdocitem-debitcreditcode = 'S'.
          o_cfid = ls_cfid_temp.
*          DELETE ztb_cfid_temp FROM @ls_cfid_temp.
        ENDIF.

      ENDIF.

      IF ls_cfid_temp-zcount = 2.
        DELETE ztb_cfid_temp FROM @ls_cfid_temp.
      ELSE.
        MODIFY ztb_cfid_temp FROM @ls_cfid_temp.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD get_last_day.
    " 1) Get the date object for any date (e.g. today):

    DATA(lo_date) = xco_cp=>sy->date( )->overwrite(
       iv_year  = i_date+0(4)
       iv_month = i_date+4(2)
       iv_day   = i_date+6(2) ).

    " 2) Compute the 1st of next month and then subtract one day:
    DATA(lv_last_day) = lo_date->overwrite( iv_day   = 1 )->add( iv_month = 1 )->subtract( iv_day   = 1 )->as( xco_cp_time=>format->abap )->value.

    IF lv_last_day IS NOT INITIAL.
      o_date = lv_last_day.
    ENDIF.
  ENDMETHOD.


  METHOD get_daynumber_of_date.
    day_number = ( ( date_analyzed - '19790101' ) MOD 7 ) + 1.
  ENDMETHOD.


  METHOD get_first_day_of_year_for_date.
    first_day_of_year = |{ date_analyzed+0(4) }0101|.
  ENDMETHOD.


  METHOD get_week_of_date.
    DATA(first_day_of_year)         = get_first_day_of_year_for_date( date_analyzed ).
    DATA(day_number_first_day_year) = get_daynumber_of_date( first_day_of_year ).
    DATA(number_day_to_sunday)      = 7 - day_number_first_day_year.

    week_number = ( ( date_analyzed - first_day_of_year - number_day_to_sunday ) DIV 7 ) + 1.
  ENDMETHOD.


  METHOD post_cfid.

*    DATA: lt_cfid_temp TYPE TABLE OF ztb_cfid_temp,
*          ls_cfid_temp TYPE ztb_cfid_temp.
*
*    DATA: lv_v1 TYPE string.
*
*    SELECT * FROM ztb_cfid_temp INTO TABLE @DATA(lt_cfid_deleted).
*    IF sy-subrc EQ 0.
*      DELETE ztb_cfid_temp FROM TABLE @lt_cfid_deleted.
*    ENDIF.

*    IF is_fields_in-cashjournaltransaction = 'VENDOR'.
*      lv_v1 = is_fields_in-cashjournaltransaction.
*      IF   is_fields_in-yy1_cashflow_cob IS INITIAL AND ( sy-ucomm = 'POST' OR sy-ucomm = 'POST_ALL' ).
*        RAISE EXCEPTION NEW zcl_jp_common_core( v1 = 'VENDOR' ). "CUSTOMER/VENDOR
*      ENDIF.
*
*      ls_cfid_temp-cfid = is_fields_in-yy1_cashflow_cob.
*      ls_cfid_temp-documentitem = 1.
*      ls_cfid_temp-ztype = 'CashPayments'.
*
*      APPEND ls_cfid_temp TO lt_cfid_temp.
*      CLEAR: ls_cfid_temp.
*    ELSEIF is_fields_in-cashjournaltransaction = 'CUSTOMER' AND ( sy-ucomm = 'POST' OR sy-ucomm = 'POST_ALL' ).
*      lv_v1 = is_fields_in-cashjournaltransaction.
*      IF   is_fields_in-yy1_cashflow_cob IS INITIAL.
*        RAISE EXCEPTION NEW zcl_jp_common_core( v1 = 'CUSTOMER' ). "CUSTOMER/VENDOR
*      ENDIF.
*
*      ls_cfid_temp-cfid = is_fields_in-yy1_cashflow_cob.
*      ls_cfid_temp-documentitem = 1.
*      ls_cfid_temp-ztype = 'CashReceipts'.
*
*      APPEND ls_cfid_temp TO lt_cfid_temp.
*      CLEAR: ls_cfid_temp.
*    ENDIF.
*
*    IF lt_cfid_temp IS NOT INITIAL.
*      MODIFY ztb_cfid_temp FROM TABLE @lt_cfid_temp.
*    ENDIF.
  ENDMETHOD.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( ).
    if_t100_message~t100key = msg_required.
    me->if_t100_message~t100key-attr1 = 'V1'.
    me->v1 = v1.
  ENDMETHOD.


  METHOD get_companycode_details_all.
    CLEAR o_companycode.
    SELECT                                              "#EC CI_NOFIELD
              companycode,
              companycodename,
              addressid,
              vatregistration,
              currency,
              country
*              createdbyuser,
*              creationdate,
*              creationtime
    FROM i_companycode
    INTO TABLE @DATA(lt_companycode)
    .                                                   "#EC CI_NOFIELD

    LOOP AT lt_companycode INTO DATA(ls_companycode).
      APPEND INITIAL LINE TO o_companycode ASSIGNING FIELD-SYMBOL(<fs_companycode>).
      MOVE-CORRESPONDING ls_companycode TO <fs_companycode>.

      zcl_jp_common_core=>get_address_id_details(
        EXPORTING
          addressid          = <fs_companycode>-addressid
        IMPORTING
          o_addressiddetails = DATA(ls_addressiddetails)
      ).

*    o_companycode-companycodename = ls_addressiddetails-addressname.
      IF ls_companycode-country = 'VN'.
        ls_addressiddetails-address = |{ ls_addressiddetails-address }, Việt Nam|.
      ELSE.
        SELECT SINGLE countryname FROM i_countrytext
        WHERE country = @ls_companycode-country
        INTO @DATA(lv_countryname).
        IF sy-subrc = 0.
          ls_addressiddetails-address = |{ ls_addressiddetails-address }, { lv_countryname }|.
        ENDIF.
      ENDIF.

      <fs_companycode>-companycodeaddr = ls_addressiddetails-address.
      <fs_companycode>-email           = ls_addressiddetails-emailaddress.
      <fs_companycode>-telephone       = ls_addressiddetails-telephonenumber.
    ENDLOOP.
  ENDMETHOD.


  METHOD save_addtext2.
*       SELECT * FROM ztb_addtext2
*       into TABLE @data(lt_addtext2).
  ENDMETHOD.
ENDCLASS.

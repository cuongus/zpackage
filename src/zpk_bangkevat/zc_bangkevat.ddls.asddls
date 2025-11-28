@EndUserText.label: 'CDS View for Purchase Invoices 01-2/GTGT-TT28'
@ObjectModel: {
    query: { implementedBy: 'ABAP:ZCL_JP_DATA_BANGKEVAT' }
}
@Metadata.allowExtensions: true

define custom entity ZC_BANGKEVAT
{

      /* ==== Key Information ==== */

      //  @EndUserText.label: 'Company Code'
      //  @Consumption.filter: { mandatory: true, multipleSelections: true }
  key bukrs                   : bukrs; // Company Code

      @EndUserText.label      : 'Document Number'
      @Consumption.filter     : { mandatory: false, multipleSelections: true }
      @Consumption.filter     : { hidden: true }
  key belnr                   : belnr_d; // Accounting Document Number

      //  @EndUserText.label: 'Fiscal Year'
      //  @Consumption.filter: { mandatory: true, multipleSelections: false, selectionType: #SINGLE }
  key gjahr                   : gjahr; // Fiscal Year

      //  @EndUserText.label: 'Month'
      @Consumption.filter     : { hidden: true }
  key monat                   : monat; // Month

      @EndUserText.label      : 'Document ID'
      @Consumption.filter     : { mandatory: false, multipleSelections: true }
  key docnum                  : belnr_d; // Internal Document ID

      @EndUserText.label      : 'Profit Center'
      @Consumption.filter     : { hidden: true }
  key prctr                   : abap.char(10); // Profit Center

      @EndUserText.label      : 'Posting Date'
      @Consumption.filter     : { mandatory: true, multipleSelections: false, selectionType: #INTERVAL }
  key posting_date            : datum; // Posting Date

      @EndUserText.label      : 'Invoice Date'
      @Consumption.filter     : { mandatory: false, multipleSelections: false, selectionType: #INTERVAL }
  key invoice_date            : datum; // Invoice Date

      @EndUserText.label      : 'Company Name'
      @Consumption.filter     : { hidden: true }
  key ten_cty                 : abap.char(100); // Company Name

      @EndUserText.label      : 'Company Address'
      @Consumption.filter     : { hidden: true }
  key diachi_cty              : abap.char(255); // Company Address

      @EndUserText.label      : 'From Date'
      @Consumption.filter     : { hidden: true }
  key tungay                  : datum; // From Date

      @EndUserText.label      : 'To Date'
      @Consumption.filter     : { hidden: true }
  key denngay                 : datum; // To Date

      @EndUserText.label      : 'Item'
      @Consumption.filter     : { hidden: true }
  key item                    : zde_item;


      /* ==== Main Display Fields ==== */

      @EndUserText.label      : 'Month'
      @Consumption.filter     : { mandatory: false, multipleSelections: true }
      @Consumption.filter     : { hidden: true }
      thang                   : abap.char(30);

      @EndUserText.label      : 'Invoice Form'
      @Consumption.filter     : { hidden: true }
      mauhd                   : abap.char(5);

      @EndUserText.label      : 'Invoice Symbol'
      @Consumption.filter     : { mandatory: false, multipleSelections: true }
      kyhieu_hd               : abap.char(20);

      @EndUserText.label      : 'Invoice Number'
      @Consumption.filter     : { hidden: true }
      sohd                    : abap.char(20);

      @EndUserText.label      : 'Invoice Date Display'
      @Consumption.filter     : { hidden: true }
      ngayhd                  : datum;

      @EndUserText.label      : 'Customer / Vendor Name'
      @Consumption.filter     : { hidden: true }
      tendonvi                : abap.char(100);

      @EndUserText.label      : 'Tax Code'
      @Consumption.filter     : { mandatory: false, multipleSelections: true }
      masothue                : abap.char(20);

      @EndUserText.label      : 'Tax Code (I*)'
      @Consumption.filter     : { hidden: true }
      taxcode                 : abap.char(2);

      @EndUserText.label      : 'Goods / Service Description'
      @Consumption.filter     : { hidden: true }
      tenhang                 : abap.char(255);

      @EndUserText.label      : 'Sales Amount'
      @Consumption.filter     : { hidden: true }
      @Semantics.amount.currencyCode: 'currency_code'
      doanhso                 : dmbtr;

      @EndUserText.label      : 'VAT Rate (%)'
      @Consumption.filter     : { hidden: true }
      thuesuat                : abap.dec(5,2);

      @EndUserText.label      : 'VAT Amount'
      @Consumption.filter     : { hidden: true }
      @Semantics.amount.currencyCode: 'currency_code'
      thue_gtgt               : dmbtr;

      @EndUserText.label      : 'Remarks'
      @Consumption.filter     : { hidden: true }
      ghichu                  : abap.char(100);

      /* ==== Số chứng từ (theo FS hướng dẫn) ==== */
      @EndUserText.label      : 'Số chứng từ'
      @Consumption.filter     : { hidden: true }
      sochungtu               : belnr_d;

      /* ==== User hạch toán ==== */
      @EndUserText.label      : 'User hạch toán'
      @Consumption.filter     : { hidden: true }
      hachtoan_user           : abap.char(80);


      /* ==== Company Information ==== */
      //  @EndUserText.label: 'Currency Code'
      @Consumption.filter     : { hidden: true }
      currency_code           : waers;

      /* ==== Totals ==== */
      @EndUserText.label      : 'Total Sales Amount'
      @Consumption.filter     : { hidden: true }
      @Semantics.amount.currencyCode: 'currency_code'
      tong_doanhso            : dmbtr;

      @EndUserText.label      : 'Total VAT Amount'
      @Consumption.filter     : { hidden: true }
      @Semantics.amount.currencyCode: 'currency_code'
      tong_thuegtgt           : dmbtr;

      /* ==== Additional Fields ==== */
      //  @EndUserText.label: 'Financial Account Type'
      @Consumption.filter     : { hidden: true }
      financial_account_type  : abap.char(2);

      @EndUserText.label      : 'Offsetting Account Type'
      @Consumption.filter     : { hidden: true }
      offsetting_account_type : abap.char(2);

      //  @EndUserText.label: 'Reference Document Fiscal Year'
      @Consumption.filter     : { hidden: true }
      refdoc_fiscal_year      : gjahr;
}

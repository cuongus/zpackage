@EndUserText.label: 'CDS View for Purchase Invoices Payment Merge (01-2/GTGT-TT28)'
@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_JP_DATA_BKHDVGTT'
    }
}
@Metadata.allowExtensions: true

define custom entity ZC_BKHDVGTT
{

  /* ==== Key Fields ==== */
  @EndUserText.label: 'Company Code'
  @Consumption.filter: { mandatory: true, multipleSelections: true }
  key bukrs             : bukrs;

  @EndUserText.label: 'Accounting Document'
  key belnr             : belnr_d;

  @EndUserText.label: 'Fiscal Year'
  key gjahr             : gjahr;

  @EndUserText.label: 'Posting Date'
  @Consumption.filter     : { mandatory: true, multipleSelections: false, selectionType: #INTERVAL }
  key posting_date      : datum;

  /* ==== Header Info ==== */
  @EndUserText.label: 'Company Name'
  key ten_cty               : abap.char(100);

  @EndUserText.label: 'Company Address'
  key diachi_cty            : abap.char(255);

  @EndUserText.label: 'Tax Code of Company'
  key mst_cty               : abap.char(30);

  @EndUserText.label: 'From Date'
  key tungay                : datum;

  @EndUserText.label: 'To Date'
  key denngay               : datum;


  /* ==== Main Display Fields ==== */
  @EndUserText.label: 'Serial No.'
  stt                   : abap.int4;

  @EndUserText.label: 'Vendor Name'
  tendonvi              : abap.char(100);

  @EndUserText.label: 'Vendor Tax Code'
  masothue              : abap.char(30);

  @EndUserText.label: 'Vendor Bank Account'
  taikhoan_ncc          : abap.char(50);

  @EndUserText.label: 'Invoice Document No.'
  sochungtu_hoadon      : belnr_d;

  @EndUserText.label: 'Invoice Number'
  sohoadon              : abap.char(30);

  @EndUserText.label: 'Invoice Date'
  ngayhoadon            : datum;
  
  @EndUserText.label: 'Journal Entry Date'
  ngaychungtu_goc : datum;
  
  @EndUserText.label: 'Goods/Service Description'
  tenhang               : abap.char(255);

  @EndUserText.label: 'Sales Amount (Base Amount)'
  @Semantics.amount.currencyCode: 'currency_code'
  tienhang              : dmbtr;

  @EndUserText.label: 'VAT Rate (%)'
  thuesuat              : abap.dec(5,2);

  @EndUserText.label: 'VAT Amount'
  @Semantics.amount.currencyCode: 'currency_code'
  tienthue              : dmbtr;

  @EndUserText.label: 'Total Amount'
  @Semantics.amount.currencyCode: 'currency_code'
  thanhtien             : dmbtr;

  @EndUserText.label: 'Clearing Document'
  sochungtu_tt          : belnr_d;

  @EndUserText.label: 'Clearing Document Date'
  ngaychungtu_tt        : datum;

  @EndUserText.label: 'Paid Amount (Bank Transfer)'
  @Semantics.amount.currencyCode: 'currency_code'
  sotien_uncc           : dmbtr;

  @EndUserText.label: 'Bank Account Used for Payment'
  taikhoan_tt           : abap.char(50);

  @EndUserText.label: 'Amount Paid for Invoice'
  @Semantics.amount.currencyCode: 'currency_code'
  thanhtoan_hoadon      : dmbtr;

  @EndUserText.label: 'Offset Payment Amount'
  @Semantics.amount.currencyCode: 'currency_code'
  thanhtoan_butru       : dmbtr;

  @EndUserText.label: 'Cash Payment Amount'
  @Semantics.amount.currencyCode: 'currency_code'
  thanhtoan_tienmat     : dmbtr;

  @EndUserText.label: 'Unpaid Amount (Not Due Yet)'
  @Semantics.amount.currencyCode: 'currency_code'
  chuattoan_chuadenhan  : dmbtr;

  @EndUserText.label: 'Remarks'
  ghichu                : abap.char(255);

  @EndUserText.label: 'Currency Code'
  currency_code         : waers;
}

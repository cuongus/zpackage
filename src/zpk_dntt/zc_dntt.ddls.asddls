@EndUserText.label: 'Đề nghị thanh toán'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_GET_DNTT' }
    }

@Metadata.allowExtensions: true


define root custom entity ZC_DNTT
  // with parameters parameter_name : parameter_type
{
  key CompanyCode            : bukrs;
  key JournalEntry           : belnr_d;
  key FiscalYear             : gjahr;
  @ObjectModel.text.element: [ 'SupplierName' ]
  key Supplier               : kunnr;
  @ObjectModel.text.element: [ 'CustomerName' ]
  key Customer               : kunnr;
  key Reference              : xblnr;
      @Consumption.filter    : { selectionType: #INTERVAL }
  key NgayDeNghi             : budat;
      @Consumption.filter    : { selectionType: #INTERVAL }
  key HanThanhToan           : budat;
  key NguoiDeNghi            : abap.char( 255 );
  key PhongBan               : abap.char( 255 );
      @Consumption.filter    : { selectionType: #INTERVAL }
  key ThoiGianTH             : budat;
  key NguoiLap               : abap.char( 255 );
  key KeToan                 : abap.char( 255 );
  key BanKiemSoat            : abap.char( 255 );
  key GiamDoc                : abap.char( 255 );
  key KeToanTruong           : abap.char( 255 );
  key TongGIamDoc            : abap.char( 255 );
  @UI.hidden: true
  key Net                    : abap.dec( 23, 2 );
  @UI.hidden: true
  key VAT                    : abap.dec( 23, 2 );
  @UI.hidden: true
  key total                  : abap.dec( 23, 2 );
  key DienGiai               : abap.char( 255 );
      @Consumption.filter    : { selectionType: #INTERVAL }
  key PostingDate            : budat;
  key SoDeNghi               : zde_sodn;
  key Currency               : waers;
  key AccountingDocumentType : blart;
  key OpenItemTXT            : abap.char( 5 );
      OpenItem               : abap_boolean;
      @Semantics.amount.currencyCode: 'Currency'
      NetAmount              : dmbtr;
      @Semantics.amount.currencyCode: 'Currency'
      VATAmount              : dmbtr;
      @Semantics.amount.currencyCode: 'Currency'
      TotalAmount            : dmbtr;
      @UI.hidden: true
      CustomerName           : abap.char( 255 );
      @UI.hidden: true
      SupplierName           : abap.char( 255 );


}

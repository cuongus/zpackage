@EndUserText.label: 'CDS View for phiếu Thu'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_RECEIPT_VOUCHER'
@Metadata.allowExtensions: true
define root custom entity ZC_RECEIPT_VOUCHER
  // with parameters parameter_name : parameter_type
{
      @Consumption.filter    : {
      mandatory              : true
      }
      @Consumption.valueHelpDefinition:[
      { entity               : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
      }]
  key CompanyCode            : bukrs;
  key AccountingDocument     : belnr_d;
  key FiscalYear             : gjahr;
      //      "chân ký
  key GeneralDirector        : abap.string;
  key ChiefAccountant        : abap.string;
  key PreparedBy             : abap.string;
  key Receiver               : abap.string;
  key Cashier                : abap.string;
 key Name                : abap.string;
      AccountingDocumentType : blart;

      @Consumption.filter    : {
      mandatory              : true,
      selectionType          : #INTERVAL,
      multipleSelections     : false
      }
      PostingDate            : abap.dats;
      TransactionCurrency    : waers;

      businesspartner        : abap.char(10);
      Doituong               : zde_bp_name;
      DiaChi                 : abap.char(255);
      acc_h                  : abap.char(256);
      acc_s                  : abap.char(256);
      Diengiai               : abap.char(255);

      @Semantics             : { amount : {currencyCode: 'TransactionCurrency'} }
      sotien                 : dmbtr;

      CreationUser           : abp_creation_user;
      CreationDate           : abp_creation_date;
      CreationTime           : abp_creation_time;



      _CompanyCode           : association [1..1] to I_CompanyCode on $projection.CompanyCode = _CompanyCode.CompanyCode;


}

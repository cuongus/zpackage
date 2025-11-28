@EndUserText.label: 'Phiếu kế toán'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_JP_GET_DATA_REPORT_FI' }
    }
@Metadata.allowExtensions: true
@Search.searchable: true
define root custom entity ZJP_C_PHIEUKETOAN
  // with parameters parameter_name : parameter_type
{
      @Search.defaultSearchElement: true
      @Consumption.filter    : { mandatory: true }
      @Consumption.valueHelpDefinition:[
      { entity               : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
      }]
  key CompanyCode            : bukrs;

  key AccountingDocument     : belnr_d;
      @Consumption.filter    : { mandatory: true }
  key FiscalYear             : gjahr;
  key Accountant             : abap.char(255);
  key CreateBy               : abap.char(255);
      PostingDate            : budat;
      DocumentDate           : bldat;
      AccountingDocumentType : blart;
      AbsoluteExchangeRate   : zde_dmbtr;
      Customer               : kunnr;
      Supplier               : lifnr;
      //      DocumentHeaderText          : bktxt;
      //      @Semantics                  : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      //      AmountInCompanyCodeCurrency : dmbtr;
      CompanyCodeCurrency    : waers;
      //      @Semantics                  : { amount : {currencyCode: 'TransactionCurrency'} }
      //      AmountInTransactionCurrency : dmbtr;
      TransactionCurrency    : waers;
      //      AbsoluteExchangeRate        : zde_exchangerate;
      IsNegativePosting      : abap_boolean;

      CreationByUser         : abp_creation_user;
      CreationDate           : abp_creation_date;
      CreationDateTime       : abp_creation_tstmpl;

      _PhieuketoanItems      : composition [0..*] of ZJP_C_PHIEUKETOAN_ITEMS;
}

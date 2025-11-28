@EndUserText.label: 'Phiếu kế toán Items'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_JP_GET_DATA_REPORT_FI' }
    }
@Metadata.allowExtensions: true
@Search.searchable: true
define custom entity ZJP_C_PHIEUKETOAN_ITEMS
  // with parameters parameter_name : parameter_type
{
      @Search.defaultSearchElement: true
  key CompanyCode               : bukrs;
  key AccountingDocument        : belnr_d;
  key FiscalYear                : gjahr;
  key Accountant                : abap.char(255);
  key CreateBy                  : abap.char(255);
  key LegderGLItem              : abap.char(6);

      PostingDate               : budat;
      DocumentDate              : bldat;
      AccountingDocumentType    : blart;

      GLAccount                 : hkont;

      DocumentItemText          : sgtxt;

      AbsoluteExchangeRate      : zde_dmbtr;

      @Semantics                : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      DebitAmountInCompanyCode  : dmbtr;
      @Semantics                : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      CreditAmountInCompanyCode : dmbtr;

      CompanyCodeCurrency       : waers;

      @Semantics                : { amount : {currencyCode: 'TransactionCurrency'} }
      DebitAmountInTransaction  : dmbtr;

      @Semantics                : { amount : {currencyCode: 'TransactionCurrency'} }
      CreditAmountInTransaction : dmbtr;

      TransactionCurrency       : waers;

      DebitCreditCode           : shkzg;

      Customer                  : kunnr;
      Supplier                  : lifnr;
      IsNegativePosting         : abap_boolean;

      _Phieuketoan              : association to parent ZJP_C_PHIEUKETOAN on  $projection.CompanyCode        = _Phieuketoan.CompanyCode
                                                                          and $projection.AccountingDocument = _Phieuketoan.AccountingDocument
                                                                          and $projection.FiscalYear         = _Phieuketoan.FiscalYear
                                                                          and $projection.Accountant         = _Phieuketoan.Accountant
                                                                          and $projection.CreateBy           = _Phieuketoan.CreateBy;

}

@EndUserText.label: 'Parameters for phiếu thu'
@Metadata.allowExtensions: true
define abstract entity ZBR_RECEIPT_VOUCHER
{
  CompanyCode        :  abap.string(0);
  AccountingDocument : abap.string(0);

  FiscalYear         : abap.string(0);

  //      "chân ký
  GeneralDirector    : abap.string(0);

  ChiefAccountant    : abap.string(0);

  PreparedBy         : abap.string(0);

  Receiver           : abap.string(0);

  Cashier            : abap.string(0);
  
  Name            : abap.string(0);
}

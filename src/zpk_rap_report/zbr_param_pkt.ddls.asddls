@EndUserText.label: 'Parameters for btn Phiếu kế toán'
@Metadata.allowExtensions: true
define abstract entity zbr_param_pkt
  //  with parameters parameter_name : parameter_type
{
  CompanyCode        : abap.string(0);

  AccountingDocument : abap.string(0);

  FiscalYear         : abap.string(0);

  Accountant         : abap.string(0);

  Preparedby         : abap.string(0);

  PrintQueue         : abap.char(4);
}

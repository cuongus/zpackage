// Define parameter entity
@EndUserText.label: 'Parameters for issue goods'
@Metadata.allowExtensions: true
define abstract entity zbr_param_issue
{
  MaterialDocument : abap.string(0);
  FiscalYear       : abap.string(0);
  HeadOfDepartment : abap.string(0);
  Cashier          : abap.string(0);
  Director         : abap.string(0);
  Department       : abap.string(0);
}

// Define parameter entity
@EndUserText.label: 'Parameters for receipt goods'
@Metadata.allowExtensions: true
define abstract entity zbr_param_receipt
{
  MaterialDocument : abap.string(0); 
  FiscalYear       : abap.string(0); 
  Shipper          : abap.string(0); 
  Cashier          : abap.string(0); 
  Director         : abap.string(0); 
  Department       : abap.string(0); 
}

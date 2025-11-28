@EndUserText.label: 'Parameters for Mapping Invoice'
define abstract entity zpr_mapp_einvoice
  //  with parameters parameter_name : parameter_type
{
  @EndUserText.label: 'S-Invoice Number'
  einvoiceno : abap.char(50);
  @EndUserText.label: 'From date'
  fromdate       : abap.dats;
  @EndUserText.label: 'To date'
  todate         : abap.dats;

}

@EndUserText.label: 'Parameters for update count button'
@Metadata.allowExtensions: true
define abstract entity zbr_param_updatecount
{

  @EndUserText.label: 'Counted Quantity'
  counted_qty  : abap.string(0);
  @EndUserText.label: 'Counted Date'
  counted_date : abap.dats;

}

// Define parameter entity
@EndUserText.label: 'Parameters for issue goods'
@Metadata.allowExtensions: true
define abstract entity ZBR_INVENTORY_IM
{
  Plant            : abap.string(0);
  Pid              : abap.string(0);
  Piditem         : abap.string(0);
  DocumantYear     : abap.string(0);
  Uuid             : abap.string(0);
  Storagelocation : abap.string(0);
  Material         : abap.string(0);
  ConvertSapNo  : abap.string(0);
}

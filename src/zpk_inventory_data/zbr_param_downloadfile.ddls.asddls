@EndUserText.label: 'Parameters for dowload file template'
@Metadata.allowExtensions: true
define abstract entity zbr_param_downloadfile
{

  Pid              : abap.string(0);
  Pid_item         : abap.string(0);
  DocumentYear     : abap.string(0);
  Convert_Sap_No   : abap.string(0);
  Warehouse_number : abap.string(0);
  Material         : abap.string(0);
  Batch            : abap.string(0);
  Sales_Order      : abap.string(0);
  Sales_Order_Item : abap.string(0);
  Spe_Stok_Num     : abap.string(0);
  Store_Type       : abap.string(0);
  Storage_Bin      : abap.string(0);
  API_Status       : abap.string(0);
  Uuid             : abap.string(0);

}

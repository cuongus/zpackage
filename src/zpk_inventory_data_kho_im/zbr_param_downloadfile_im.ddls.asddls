@EndUserText.label: 'Parameters for dowload file template'
@Metadata.allowExtensions: true
define abstract entity zbr_param_downloadfile_IM
{

  Pid            : abap.string(0);
  Pid_item       : abap.string(0);
  DocumentYear   : abap.string(0);
  Plant          : abap.string(0);
  Store_Location : abap.string(0);
  Material       : abap.string(0);
  Convert_Sap_No : abap.string(0);
  Pi_Status      : abap.string(0);
  API_Status     : abap.string(0);
  Uuid           : abap.string(0);

}

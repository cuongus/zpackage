@EndUserText.label: 'Upload file action'
define abstract entity ZI_FILE_ABS
  //  with parameters parameter_name : parameter_type
{

  mimeType      : abap.string(0);
  fileName      : abap.string(0);
  fileContent   : abap.rawstring(0);
  fileExtension : abap.string(0);

}

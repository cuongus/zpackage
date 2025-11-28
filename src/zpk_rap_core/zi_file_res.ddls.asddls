@EndUserText.label: 'Result action'
define abstract entity ZI_FILE_RES
  //  with parameters parameter_name : parameter_type
{
  mimeType      : abap.string(0);
  fileName      : abap.string(0);
  fileContent   : abap.string(0);
  fileExtension : abap.string(0);
}


@EndUserText.label: 'Upload file action'
define abstract entity ZBR_BARCODE
{
  mimeType      : abap.string(0);
  fileName      : abap.string(0);
//  fileContent   : abap.rawstring(0);
fileContent   : abap.string(0);
  fileExtension : abap.string(0);
}

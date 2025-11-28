@EndUserText.label: 'Upload file action'
define abstract entity ZC_BTN_DCT
{
  mimeType      : abap.string(0);
  fileName      : abap.string(0);
  fileContent   : abap.string(0);
  fileExtension : abap.string(0);
}

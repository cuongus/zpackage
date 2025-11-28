@EndUserText.label: 'Upload file action'
define abstract entity ZABS_INVENTORY_IM
{
  mimeType      : abap.string(0);
  fileName      : abap.string(0);
  fileContent   : abap.string(0);
  fileExtension : abap.string(0);

  docnum       : abap.string(0);
  messageType   : abap.string(0);
}

@EndUserText.label: 'Parameters for barcode'
@Metadata.allowExtensions: true
define abstract entity ZBR_BARCODE_1
{
lineindex : abap.string(0);
Document : abap.string(0);
Document_Item : abap.string(0);
plant : abap.string(0);
qc : abap.string(0);
keeper : abap.string(0);
OPTION_NAME : abap.string(0);
matnr_number : abap.string(0);
batch : abap.string(0);
header_type : abap.string(0);
print_multi : abap.string(0);
vas : abap.string(0);
Storage_Location : abap.string(0);
Sale_Order : abap.string(0);
Sale_Order_item : abap.string(0);
Quantity : abap.string(0);
print_quantity : abap.string(0);
Supplier : abap.string(0);
}

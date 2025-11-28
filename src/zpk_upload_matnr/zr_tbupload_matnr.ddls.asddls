@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBUPLOAD_MATNR'
@EndUserText.label: 'Tool Upload MIGO'
define view entity ZR_TBUPLOAD_MATNR
  as select from ztb_upload_matnr
  
   association to parent ZR_TBMATNR_HEADER as _hdr on  $projection.UUID = _hdr.Uuid
//                                                and $projection.MatnrSequeNumr = _hdr.
{
//  key client as Client,
  key uuid as UUID,
  key dtlid as Dtlid,
 matnr_seque_numr as MatnrSequeNumr,
 
  option_name as OptionName,
  matnr_doc as MatnrDoc,
  matnr_item as MatnrItem,
  doc_date as DocDate,
  post_date as PostDate,
  matnr_header_text as MatnrHeaderText,
  ctrl_post as CtrlPost,
  good_code as GoodCode,
  resevation as Resevation,
  resevation_item as ResevationItem,
  good_type as GoodType,
  matnr as Matnr,
  plant as Plant,
  storage_location as StorageLocation,
  batch as Batch,
  valuation_type as ValuationType,
  quantity as Quantity,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_UnitOfMeasureStdVH', 
    entity.element: 'UnitOfMeasure', 
    useForValidation: true
  } ]
  unit as Unit,
  cost_center as CostCenter,
  fixed_asset as FixedAsset,
  sales_order as SalesOrder,
  sales_order_item as SalesOrderItem,
  spe_stok as SpeStok,
  matnr_doc_item_text as MatnrDocItemText,
  warehouse_number as WarehouseNumber,
  store_bin as StoreBin,
  form_matnr as FormMatnr,
  form_plant as FormPlant,
  form_sloc as FormSloc,
  form_batch as FormBatch,
  form_value_type as FormValueType,
  form_sale_order as FormSaleOrder,
  form_sale_item as FormSaleItem,
  to_matnr as ToMatnr,
  to_plant as ToPlant,
  to_sloc as ToSloc,
  to_batch as ToBatch,
  to_value_type as ToValueType,
  to_sale_order as ToSaleOrder,
  to_sale_item as ToSaleItem,
  vendor as Vendor,
  manu_order as ManuOrder,
   manu_order_item as ManuOrderItem,
  return_type as ReturnType,
  machining_orders as MachiningOrders,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
   _hdr
}

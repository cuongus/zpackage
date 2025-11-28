@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forZCR_OD_21'
define view entity ZR_ZCR_OD_21TP
  as select from ZC_CR_OD_21 as ZCR_OD_21
  association to parent ZR_ZCR_OD_201TP as _ZCR_OD_2 on $projection.PurchaseOrder = _ZCR_OD_2.PurchaseOrder 
    and $projection.PurchaseOrderItem = _ZCR_OD_2.PurchaseOrderItem and $projection.OutboundDelivery = _ZCR_OD_2.OutboundDelivery
  association [1] to ZR_ZCR_OD_GC02TP as _ZCR_OD_GC on $projection.PurchaseOrder = _ZCR_OD_GC.PurchaseOrder 
    and $projection.PurchaseOrderItem = _ZCR_OD_GC.PurchaseOrderItem
{
  key PurchaseOrder as PurchaseOrder,
  key PurchaseOrderItem as PurchaseOrderItem,
  key OutboundDelivery as OutboundDelivery,
  key OutboundDeliveryItem as OutboundDeliveryItem,
  sldongbo as sldongbo,
  PlannedGoodsIssueDate as PlannedGoodsIssueDate,
  YY1_NgayDuKienThu_DLH as YY1_NgayDuKienThu_DLH,
  Supplier as Supplier,
  SupplierName as SupplierName,
  Product as Product,
  ProductDescription as ProductDescription,
  BaseUnit as BaseUnit,
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  SoLuong as SoLuong,
  _ZCR_OD_2,
  _ZCR_OD_GC
}

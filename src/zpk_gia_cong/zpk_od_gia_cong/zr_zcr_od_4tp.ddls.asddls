@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forZCR_OD_4'
define view entity ZR_ZCR_OD_4TP
  as select from ZC_CR_OD_4 as ZCR_OD_4
//  association to parent ZR_ZCR_OD_301TP as _ZCR_OD_3 on $projection.PurchaseOrder = _ZCR_OD_3.PurchaseOrder 
//    and $projection.PurchaseOrderItem = _ZCR_OD_3.PurchaseOrderItem and $projection.OutboundDelivery = _ZCR_OD_3.OutboundDelivery 
//    and $projection.OutboundDeliveryItem = _ZCR_OD_3.OutboundDeliveryItem
  association to parent ZR_ZCR_OD_201TP as _ZCR_OD_2 on $projection.PurchaseOrder = _ZCR_OD_2.PurchaseOrder 
  and $projection.PurchaseOrderItem = _ZCR_OD_2.PurchaseOrderItem and $projection.OutboundDelivery = _ZCR_OD_2.OutboundDelivery
  association [1] to ZR_ZCR_OD_GC02TP as _ZCR_OD_GC on $projection.PurchaseOrder = _ZCR_OD_GC.PurchaseOrder and $projection.PurchaseOrderItem = _ZCR_OD_GC.PurchaseOrderItem
{
  key PurchaseOrder as PurchaseOrder,
  key PurchaseOrderItem as PurchaseOrderItem,
  key OutboundDelivery as OutboundDelivery,
  key OutboundDeliveryItem as OutboundDeliveryItem,
  key OutboundDeliveryBS as OutboundDeliveryBS,
  YY1_SLDongBo_DLH as YY1_SLDongBo_DLH,
  PlannedGoodsIssueDate as PlannedGoodsIssueDate,
  YY1_NgayDuKienThu_DLH as YY1_NgayDuKienThu_DLH,
  Supplier as Supplier,
  SupplierName as SupplierName,
  Product as Product,
  ProductDescription as ProductDescription,
  DeliveryQuantityUnit as DeliveryQuantityUnit,
  @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
  ActualDeliveryQuantity as ActualDeliveryQuantity,
  mabtp as mabtp,
  tenbtp as tenbtp,
  YY1_ODGoc_DLH as YY1_ODGoc_DLH,
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  SoLuong as SoLuong,
  OverallGoodsMovementStatus,
  GoodsMovementStatus,
  HoanThanh,
  Status,
  BaseUnit as BaseUnit,
  _ZCR_OD_2,
  _ZCR_OD_GC
}

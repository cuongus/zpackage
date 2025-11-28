@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forZCR_OD_3'
define view entity ZR_ZCR_OD_301TP
  as select from ZC_CR_OD_3 as ZCR_OD_3
  association to parent ZR_ZCR_OD_201TP as _ZCR_OD_2 on $projection.PurchaseOrder = _ZCR_OD_2.PurchaseOrder and $projection.PurchaseOrderItem = _ZCR_OD_2.PurchaseOrderItem and $projection.OutboundDelivery = _ZCR_OD_2.OutboundDelivery
  association [1] to ZR_ZCR_OD_GC02TP as _ZCR_OD_GC on $projection.PurchaseOrder = _ZCR_OD_GC.PurchaseOrder and $projection.PurchaseOrderItem = _ZCR_OD_GC.PurchaseOrderItem
//  composition [0..*] of ZR_ZCR_OD_4TP as _ZCR_OD_4
{
  key PURCHASEORDER as PurchaseOrder,
  key PURCHASEORDERITEM as PurchaseOrderItem,
  key OUTBOUNDDELIVERY as OutboundDelivery,
  key OUTBOUNDDELIVERYITEM as OutboundDeliveryItem,
  YY1_SLDONGBO_DLH as YY1_SLDongBo_DLH,
  PLANNEDGOODSISSUEDATE as PlannedGoodsIssueDate,
  YY1_NGAYDUKIENTHU_DLH as YY1_NgayDuKienThu_DLH,
  SUPPLIER as Supplier,
  SUPPLIERNAME as SupplierName,
  PRODUCT as Product,
  PRODUCTDESCRIPTION as ProductDescription,
  DELIVERYQUANTITYUNIT as DeliveryQuantityUnit,
  @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
  ACTUALDELIVERYQUANTITY as ActualDeliveryQuantity,
  MABTP as mabtp,
  TENBTP as tenbtp,
  YY1_ODGOC_DLH as YY1_ODGoc_DLH,
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  SOLUONG as SoLuong,
  BASEUNIT as BaseUnit,
//  _ZCR_OD_4,
  _ZCR_OD_2,
  _ZCR_OD_GC
}

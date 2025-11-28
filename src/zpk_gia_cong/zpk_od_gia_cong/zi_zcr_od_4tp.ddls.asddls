@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forZCR_OD_4'
define view entity ZI_ZCR_OD_4TP
  as projection on ZR_ZCR_OD_4TP as ZCR_OD_4
{
  key PurchaseOrder,
  key PurchaseOrderItem,
  key OutboundDelivery,
  key OutboundDeliveryItem,
  key OutboundDeliveryBS,
  YY1_SLDongBo_DLH,
  PlannedGoodsIssueDate,
  YY1_NgayDuKienThu_DLH,
  Supplier,
  SupplierName,
  Product,
  ProductDescription,
  DeliveryQuantityUnit,
  ActualDeliveryQuantity,
  mabtp,
  tenbtp,
  YY1_ODGoc_DLH,
  SoLuong,
  BaseUnit,
//  _ZCR_OD_2 : redirected to parent ZI_ZCR_OD_301TP,
_ZCR_OD_2 : redirected to parent ZI_ZCR_OD_201TP,
  _ZCR_OD_GC : redirected to ZI_ZCR_OD_GC02TP
}

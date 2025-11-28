@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forZCR_OD_3'
define view entity ZI_ZCR_OD_301TP
  as projection on ZR_ZCR_OD_301TP as ZCR_OD_3
{
  key PurchaseOrder,
  key PurchaseOrderItem,
  key OutboundDelivery,
  key OutboundDeliveryItem,
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
//  _ZCR_OD_4 : redirected to composition child ZI_ZCR_OD_4TP,
  _ZCR_OD_2 : redirected to parent ZI_ZCR_OD_201TP,
  _ZCR_OD_GC : redirected to ZI_ZCR_OD_GC02TP
}

@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forZCR_OD_21'
define view entity ZI_ZCR_OD_21TP
  as projection on ZR_ZCR_OD_21TP as ZCR_OD_21
{
  key PurchaseOrder,
  key PurchaseOrderItem,
  key OutboundDelivery,
  key OutboundDeliveryItem,
  sldongbo,
  PlannedGoodsIssueDate,
  YY1_NgayDuKienThu_DLH,
  Supplier,
  SupplierName,
  Product,
  ProductDescription,
  BaseUnit,
  SoLuong,
  _ZCR_OD_2 : redirected to parent ZI_ZCR_OD_201TP,
  _ZCR_OD_GC : redirected to ZI_ZCR_OD_GC02TP
}

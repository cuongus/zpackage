@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forZCR_OD_2'
define view entity ZI_ZCR_OD_201TP
  as projection on ZR_ZCR_OD_201TP as ZCR_OD_2
{
  key PurchaseOrder,
  key PurchaseOrderItem,
  key OutboundDelivery,
  Product,
  ProductDescription,
  Supplier,
  SupplierName,
  sldongbo,
  YY1_SLDongBo_DLH,
  PlannedGoodsIssueDate,
  YY1_NgayDuKienThu_DLH,
  OverallGoodsMovementStatus,
  OrderQuantity,
  PurchaseOrderQuantityUnit,
  YY1_ODGoc_DLH,
  _ZCR_OD_21 : redirected to composition child ZI_ZCR_OD_21TP,
  _ZCR_OD_3 : redirected to composition child ZI_ZCR_OD_301TP,
  _ZCR_OD_4 : redirected to composition child ZI_ZCR_OD_4TP,
  _ZCR_OD_GC : redirected to parent ZI_ZCR_OD_GC02TP
}

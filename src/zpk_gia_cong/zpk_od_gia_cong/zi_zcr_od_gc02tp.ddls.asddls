@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forZCR_OD_GC'
define root view entity ZI_ZCR_OD_GC02TP
  provider contract TRANSACTIONAL_INTERFACE
  as projection on ZR_ZCR_OD_GC02TP as ZCR_OD_GC
{
  key PurchaseOrder,
  key PurchaseOrderItem,
  Product,
  ProductDescription,
  Supplier,
  SupplierName,
  OrderQuantity,
  PurchaseOrderQuantityUnit,
  OrderID,
  SalesOrder,
  SalesOrderItem,
  _ZCR_OD_2 : redirected to composition child ZI_ZCR_OD_201TP
}

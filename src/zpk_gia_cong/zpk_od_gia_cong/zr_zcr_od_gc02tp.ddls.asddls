@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forZCR_OD_GC'
define root view entity ZR_ZCR_OD_GC02TP
  as select from ZC_CR_OD_GC as ZCR_OD_GC
  composition [0..*] of ZR_ZCR_OD_201TP as _ZCR_OD_2
{
  key PURCHASEORDER as PurchaseOrder,
  key PURCHASEORDERITEM as PurchaseOrderItem,
  PRODUCT as Product,
  PRODUCTDESCRIPTION as ProductDescription,
  SUPPLIER as Supplier,
  SUPPLIERNAME as SupplierName,
  @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
  ORDERQUANTITY as OrderQuantity,
  PURCHASEORDERQUANTITYUNIT as PurchaseOrderQuantityUnit,
  ORDERID as OrderID,
  SALESORDER as SalesOrder,
  SALESORDERITEM as SalesOrderItem,
  _ZCR_OD_2
}

@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forZCR_OD_GC'
@ObjectModel.semanticKey: [ 'PurchaseOrder' ]
@Search.searchable: true
define root view entity ZC_ZCR_OD_GC02TP
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_ZCR_OD_GC02TP as ZCR_OD_GC
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key PurchaseOrder,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key PurchaseOrderItem,
  Product,
  ProductDescription,
  Supplier,
  SupplierName,
  @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
  OrderQuantity,
  @Semantics.unitOfMeasure: true
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_UnitOfMeasure', 
      element: 'UnitOfMeasure'
    }, 
    useForValidation: true
  } ]
  PurchaseOrderQuantityUnit,
  OrderID,
  SalesOrder,
  SalesOrderItem,
  _ZCR_OD_2 : redirected to composition child ZC_ZCR_OD_201TP
}

@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forZCR_OD_3'
@ObjectModel.semanticKey: [ 'OutboundDeliveryItem' ]
@Search.searchable: true
define view entity ZC_ZCR_OD_301TP
  as projection on ZR_ZCR_OD_301TP as ZCR_OD_3
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key PurchaseOrder,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key PurchaseOrderItem,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key OutboundDelivery,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key OutboundDeliveryItem,
  YY1_SLDongBo_DLH,
  PlannedGoodsIssueDate,
  YY1_NgayDuKienThu_DLH,
  Supplier,
  SupplierName,
  Product,
  ProductDescription,
  @Semantics.unitOfMeasure: true
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_UnitOfMeasure', 
      element: 'UnitOfMeasure'
    }, 
    useForValidation: true
  } ]
  DeliveryQuantityUnit,
  @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
  ActualDeliveryQuantity,
  mabtp,
  tenbtp,
  YY1_ODGoc_DLH,
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  SoLuong,
  @Semantics.unitOfMeasure: true
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_UnitOfMeasure', 
      element: 'UnitOfMeasure'
    }, 
    useForValidation: true
  } ]
  BaseUnit,
//  _ZCR_OD_4 : redirected to composition child ZC_ZCR_OD_4TP,
  _ZCR_OD_2 : redirected to parent ZC_ZCR_OD_201TP,
  _ZCR_OD_GC : redirected to ZC_ZCR_OD_GC02TP
}

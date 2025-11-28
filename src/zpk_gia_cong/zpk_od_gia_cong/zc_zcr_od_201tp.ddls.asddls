@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forZCR_OD_2'
@ObjectModel.semanticKey: [ 'OutboundDelivery' ]
@Search.searchable: true
define view entity ZC_ZCR_OD_201TP
  as projection on ZR_ZCR_OD_201TP as ZCR_OD_2
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
  Product,
  ProductDescription,
  Supplier,
  SupplierName,
  sldongbo,
  YY1_SLDongBo_DLH,
  PlannedGoodsIssueDate,
  YY1_NgayDuKienThu_DLH,
  OverallGoodsMovementStatus,
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
  YY1_ODGoc_DLH,
  status,
  _ZCR_OD_21 : redirected to composition child ZC_ZCR_OD_21TP,
  _ZCR_OD_4 : redirected to composition child ZI_ZCR_OD_4TP,
  _ZCR_OD_3 : redirected to composition child ZC_ZCR_OD_301TP,
  _ZCR_OD_GC : redirected to parent ZC_ZCR_OD_GC02TP
}

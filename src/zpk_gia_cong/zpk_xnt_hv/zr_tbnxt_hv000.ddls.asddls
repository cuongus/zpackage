@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBNXT_HV'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBNXT_HV000
  as select from ZTB_NXT_HV
{
  key material as Material,
  key plant as Plant,
  key supplier as Supplier,
  key orderid as Orderid,
  key zper as Zper,
  key batch as Batch,
  key inventoryvaluationtype as Inventoryvaluationtype,
  @Semantics.quantity.unitOfMeasure: 'Materialbaseunit'
  quantityinbaseunit as Quantityinbaseunit,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_UnitOfMeasureStdVH', 
    entity.element: 'UnitOfMeasure', 
    useForValidation: true
  } ]
  materialbaseunit as Materialbaseunit,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt
}

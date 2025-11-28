@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'View entity for ZTB_NXT_SOT'
define root view entity ZR_TBNXT_SOT000
 as select from ztb_nxt_sot
{
    key material as Material,
    key plant as Plant,
    key zper as Zper,
    key sloc as Sloc,
    vendor as Vendor,
    @Semantics.quantity.unitOfMeasure: 'Materialbaseunit'
    stock_qty as StockQty,
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

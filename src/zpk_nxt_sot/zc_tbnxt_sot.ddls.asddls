@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for ZR_TBNXT_SOT000'

define root view entity ZC_TBNXT_SOT
  provider contract transactional_query
  as projection on ZR_TBNXT_SOT000
  association [1..1] to ZR_TBNXT_SOT000 as _BaseEntity on  $projection.Material = _BaseEntity.Material
                                                       and $projection.Plant    = _BaseEntity.Plant
                                                       and $projection.Sloc     = _BaseEntity.Sloc
                                                       and $projection.Zper     = _BaseEntity.Zper
{
  key Material,
  key Plant,
  key Zper,
  key Sloc,
      Vendor,
        @Semantics: {
    quantity.unitOfMeasure: 'Materialbaseunit'
  }
      StockQty,
        @Consumption: {
    valueHelpDefinition: [ {
      entity.element: 'UnitOfMeasure', 
      entity.name: 'I_UnitOfMeasureStdVH', 
      useForValidation: true
    } ]
  }
      Materialbaseunit,
        @Semantics: {
    user.createdBy: true
  }
      CreatedBy,
        @Semantics: {
    systemDateTime.createdAt: true
  }
      CreatedAt,
        @Semantics: {
    user.localInstanceLastChangedBy: true
  }
      LastChangedBy,
        @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
      LastChangedAt,
      _BaseEntity
}

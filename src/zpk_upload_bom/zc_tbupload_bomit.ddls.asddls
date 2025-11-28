@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBUPLOAD_BOMIT'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZC_TBUPLOAD_BOMIT
//  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TBUPLOAD_BOMIT
//  association [1..1] to ZR_TBUPLOAD_BOMIT as _BaseEntity on $projection.UUID = _BaseEntity.UUID and $projection.DTLID = _BaseEntity.DTLID
{
  key UUID,
  key Dtlid,
  SalesOrder,
  SalesOrderItem,
  Matnr,
  Plant,
  BomUsage,
  MaterialVariant,
  MaterialStatus,
  HeaderQuan,
  HeaderUnit,
  HeaderCategory,
  BomItemNum,
  ItemCategory,
  BomComponent,
  ComponentQuan,
  @Consumption: {
    valueHelpDefinition: [ {
      entity.element: 'UnitOfMeasure', 
      entity.name: 'I_UnitOfMeasureStdVH', 
      useForValidation: true
    } ]
  }
  Unit,
  NetScrap,
  ScrapInPercen,
  Relevancy,
  SpecialProcurement,
  Location,
  AlternativeitemGroup,
  Priority,
  AlternativeStrategy,
  AlternativeUsage,
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
    _hdr : redirected to parent ZC_TBUPLOAD_BOMHD
//  _BaseEntity
}

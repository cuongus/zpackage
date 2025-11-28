@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBTYLE_CONFIG'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBTYLE_CONFIG
  provider contract transactional_query
  as projection on ZR_TBTYLE_CONFIG
  association [1..1] to ZR_TBTYLE_CONFIG as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
      Type,
      Zdesc,
      @Consumption.valueHelpDefinition:[
               { entity                       : { name : 'zc_product_sh' , element: 'Product' } }
              ]
      material,
      @Consumption.valueHelpDefinition:[
           { entity                       : { name : 'zc_ProductGroup_SH' , element: 'ProductGroup' } }
          ]
      productgroup,
      Tyle,
      Validfrom,
      Validto,
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

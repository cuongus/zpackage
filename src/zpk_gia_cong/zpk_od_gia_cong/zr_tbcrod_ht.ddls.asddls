@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBCROD_HT'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBCROD_HT
  as select from ZTB_CROD_HT
{
  key outbounddelivery as Outbounddelivery,
  key product as Product,
  hoanthanh as Hoanthanh,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt
}

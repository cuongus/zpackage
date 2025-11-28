@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBCROD_2'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBCROD_2
  as select from ZTB_CROD_2
{
  key purchaseorder as Purchaseorder,
  key purchaseorderitem as Purchaseorderitem,
  key outbounddelivery as Outbounddelivery,
  sldongbo as Sldongbo,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt
}

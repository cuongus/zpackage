@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBTYLE_CONFIG'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBTYLE_CONFIG
  as select from ztb_tyle_config
{
  key uuid as UUID,
  type as Type,
  zdesc as Zdesc,
  material,
  productgroup,
  tyle as Tyle,
  validfrom as Validfrom,
  validto as Validto,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt
}

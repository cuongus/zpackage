@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBTEST1'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBTEST1
  as select from ZTB_TEST1
{
  key code as Code,
  name as Name,
  @Semantics.user.createdBy: true
  createdby as Createdby,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy
}

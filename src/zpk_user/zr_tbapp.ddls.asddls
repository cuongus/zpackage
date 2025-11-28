@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBAPP'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBAPP
  as select from ztb_app
  composition [0..*] of ZR_TBAPP_FUNC as _dtl
{
  key appid as Appid,
  zapp as Zapp,
  zdesc as Zdesc,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  _dtl
}

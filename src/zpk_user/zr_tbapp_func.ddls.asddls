@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBAPP_FUNC'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZR_TBAPP_FUNC
  as select from ztb_app_func
  association        to parent ZR_TBAPP as _hdr on  $projection.Appid = _hdr.Appid
{
  key appid as Appid,
  key dtlid as Dtlid,
  zfunc as Zfunc,
  zdesc as Zdesc,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  _hdr
}

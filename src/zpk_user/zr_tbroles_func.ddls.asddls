@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBROLES_FUNC'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZR_TBROLES_FUNC
  as select from ztb_roles_func
  association        to parent ZR_TBROLES as _hdr on  $projection.ID = _hdr.ID
{
  key id as ID,
  key dtlid as Dtlid,
  zfunc as Zfunc,
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

@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBROLES'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBROLES
  as select from ztb_roles
  composition [0..*] of ZR_TBROLES_FUNC as _dtl
  composition [0..*] of ZR_TBROLES_DATA as _dta
{
  key id as ID,
  zrole as Zrole,
  zdesc as Zdesc,
  zapp as Zapp,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  _dtl,
  _dta
}

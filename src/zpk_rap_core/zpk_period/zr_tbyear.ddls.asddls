@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBYEAR'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBYEAR
  as select from ztb_year
  composition [0..*] of ZR_TBPERIOD as _dtl
{
  key zyear as Zyear,
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

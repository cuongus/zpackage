@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forZWeekYear'
define root view entity ZR_ZWeekYear01TP
  as select from ZTB_WEEK_YEAR as ZWeekYear
  composition [0..*] of ZR_ZWeekTP as _ZWeek
{
  key ZYEAR as Zyear,
  ZDESC as Zdesc,
  @Semantics.user.createdBy: true
  CREATED_BY as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  CREATED_AT as CreatedAt,
  @Semantics.user.lastChangedBy: true
  LAST_CHANGED_BY as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  _ZWeek
}

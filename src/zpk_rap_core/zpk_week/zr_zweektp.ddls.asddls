@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forZWeek'
define view entity ZR_ZWeekTP
  as select from ztb_week as ZWeek
  association to parent ZR_ZWeekYear01TP as _ZWeekYear on $projection.Zyear = _ZWeekYear.Zyear
{
  key zyear as Zyear,
  key zweek as Zweek,
  zdesc as Zdesc,
  weeknum as Weeknum,
  weekchar as Weekchar,
  zdatefr as Zdatefr,
  zdateto as Zdateto,
  zper as Zper,
  lastweek as Lastweek,
  created_by as CreatedBy,
  created_at as CreatedAt,
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  _ZWeekYear
}

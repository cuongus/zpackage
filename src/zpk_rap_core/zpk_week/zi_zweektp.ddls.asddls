@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forZWeek'
define view entity ZI_ZWeekTP
  as projection on ZR_ZWeekTP as ZWeek
{
  key Zyear,
  key Zweek,
  Zdesc,
  Weeknum,
  Weekchar,
  Zdatefr,
  Zdateto,
  Zper,
  Lastweek,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  _ZWeekYear : redirected to parent ZI_ZWeekYear01TP
}

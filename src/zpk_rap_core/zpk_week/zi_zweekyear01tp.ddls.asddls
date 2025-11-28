@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forZWeekYear'
define root view entity ZI_ZWeekYear01TP
  provider contract TRANSACTIONAL_INTERFACE
  as projection on ZR_ZWeekYear01TP as ZWeekYear
{
  key Zyear,
  Zdesc,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  _ZWeek : redirected to composition child ZI_ZWeekTP
}

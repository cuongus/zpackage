@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forZWeek'
@ObjectModel.semanticKey: [ 'Zweek' ]
@Search.searchable: true
define view entity ZC_ZWeekTP
  as projection on ZR_ZWeekTP as ZWeek
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Zyear,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
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
  _ZWeekYear : redirected to parent ZC_ZWeekYear01TP
}

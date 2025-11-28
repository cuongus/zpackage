@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forZWeekYear'
@ObjectModel.semanticKey: [ 'Zyear' ]
@Search.searchable: true
define root view entity ZC_ZWeekYear01TP
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_ZWeekYear01TP as ZWeekYear
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Zyear,
  Zdesc,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  _ZWeek : redirected to composition child ZC_ZWeekTP
}

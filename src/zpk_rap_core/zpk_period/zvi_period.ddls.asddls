@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Period'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZVI_PERIOD as select distinct from ztb_period
{
    key zyear as Zyear,
    key zper as Zper,
    zdesc as Zdesc,
    zmonth as Zmonth,
    zdatefr as Zdatefr,
    zdateto as Zdateto
}

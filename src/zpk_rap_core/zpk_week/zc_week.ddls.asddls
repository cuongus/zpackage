@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ztb_week'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zc_week as select from ztb_week
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
    last_changed_at as LastChangedAt
}

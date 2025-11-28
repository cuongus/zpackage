@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Week Value Help'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WEEK_StdVH
  as select from ztb_week
{

      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @EndUserText.label: 'Year'
  key zyear   as Zyear,
      @UI.hidden: true
  key zweek   as Zweek,

      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      @EndUserText.label: 'Description'
      zdesc   as Zdesc,

      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @EndUserText.label: 'Week'
      weeknum as Weeknum,
      //      weekchar        as Weekchar,

      @UI.lineItem: [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      @EndUserText.label: 'Date From'
      zdatefr as Zdatefr,

      @UI.lineItem: [{ position: 50 }]
      @UI.identification: [{ position: 50 }]
      @EndUserText.label: 'Date To'
      zdateto as Zdateto
      //      zper            as Zper
      //      lastweek        as Lastweek,
      //      created_by      as CreatedBy,
      //      created_at      as CreatedAt,
      //      last_changed_by as LastChangedBy,
      //      last_changed_at as LastChangedAt
}

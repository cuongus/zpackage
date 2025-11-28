@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Type Of Date Text'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZJP_CFG_TYPEOFDATE
  as select from zjp_hd_config
{
      //  key id_sys        as IdSys,
      //  key id_domain     as IdDomain,
      @ObjectModel.text.element: [ 'DescriptionTypeOfDate' ]
  key value       as Value,
      @Semantics.text: true
      description as DescriptionTypeOfDate
      //      createdbyuser as Createdbyuser,
      //      createddate   as Createddate,
      //      changedbyuser as Changedbyuser,
      //      changeddate   as Changeddate
}
where
      id_domain = 'TYPEOFDATE'
  and id_sys    = '001'

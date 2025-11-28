@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status SAP Text'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zjp_cfg_statussap
  as select from zjp_hd_config
{
      //  key id_sys        as IdSys,
      //  key id_domain     as IdDomain,
      @ObjectModel.text.element: [ 'DescriptionStatusSAP' ]
  key value       as Value,
      @Semantics.text: true
      description as DescriptionStatusSAP
      //      createdbyuser as Createdbyuser,
      //      createddate   as Createddate,
      //      changedbyuser as Changedbyuser,
      //      changeddate   as Changeddate
}
where
      id_domain = 'STATUSSAP'
  and id_sys    = '001'

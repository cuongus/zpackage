@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Domain Read'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_DOMAIN_FIX_VAL_LOAIBC 
       as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDO_LOAIBC') {
    @UI.hidden  : true
    key domain_name,
    @UI.hidden  : true
    key value_position,
    @Semantics.language: true
    @UI.hidden  : true
    key language,
    value_low,
    @Semantics.text: true
    text
}

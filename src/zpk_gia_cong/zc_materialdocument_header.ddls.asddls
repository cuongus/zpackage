@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Document header'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zc_MaterialDocument_header as select from I_MaterialDocumentItem_2
{
    key MaterialDocumentYear,
    key MaterialDocument,
    max( YY1_BBCongDoan_MMI ) as YY1_BBCongDoan_MMI
} group by MaterialDocumentYear, MaterialDocument

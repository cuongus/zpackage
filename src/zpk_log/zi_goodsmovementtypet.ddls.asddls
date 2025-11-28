@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'I_GoodsMovementTypeT'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zI_GoodsMovementTypeT as select from I_GoodsMovementTypeT
{
    key GoodsMovementType,
    key Language,
    GoodsMovementTypeName,
    /* Associations */
    _GoodsMovementType,
    _Language
}

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'I_Product'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zc_Product as select from I_Product
association [0..1] to zc_ProductGroup_SH as _ProductGroup on $projection.ProductGroup = _ProductGroup.ProductGroup
{
    key Product,
    ProductGroup,
    _ProductGroup.ProductGroupName,
    BaseUnit
}

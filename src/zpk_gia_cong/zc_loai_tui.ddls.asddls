@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Loại túi'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zc_loai_tui as 
select from I_ProdUnivHierarchyNodeBasic as a
inner join zc_loai_tui_1 as z on z.HierarchyNode = substring(a.ParentNode,1,7)
{
    key a.Product,
    key a.ProdHierarchyValidityStartDate,
    key a.ProdHierarchyValidityEndDate,
    z.ProdUnivHierarchyNode,
    z.ProdUnivHierarchyNodeText
} where a.ProdUnivHierarchy = 'PH_MANUFACTURING'
 and a.Product <> ''

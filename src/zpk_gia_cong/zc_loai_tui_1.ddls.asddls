@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Loại túi'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zc_loai_tui_1 as select distinct 
 from I_ProdUnivHierarchyNodeBasic as d
inner join I_ProdUnivHierNodeText_2 as e on e.HierarchyNode = d.HierarchyNode and e.ProdUnivHierarchy = d.ProdUnivHierarchy
                                            and e.Language = $session.system_language
{
   key d.ProdUnivHierarchyNode,
   d.HierarchyNode,
    e.ProdUnivHierarchyNodeText
} where d.ProdUnivHierarchy = 'PH_MANUFACTURING' and d.HierarchyNodeLevel = '000003'

and d.ProdHierarchyValidityStartDate <= $session.user_date and d.ProdHierarchyValidityEndDate >= $session.user_date;

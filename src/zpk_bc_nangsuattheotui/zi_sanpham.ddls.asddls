@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sản phẩm'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_SANPHAM
  as select from I_ProdUnivHierarchyNodeBasic as H
    inner join   I_ProdUnivHierNodeText_2     as T on  H.HierarchyNode     = T.HierarchyNode
                                                   and H.ProdUnivHierarchy = T.ProdUnivHierarchy
{
  key H.ProdUnivHierarchyNode             as PRODUNIVHIERARCHYNODE,
      T.ProdUnivHierarchyNodeText as HierarchyNodeDesc
}
where
      T.Language           = 'E'
  and H.HierarchyNodeLevel = '000003'
  and H.ProdUnivHierarchy  = 'PH_MANUFACTURING'
  ;

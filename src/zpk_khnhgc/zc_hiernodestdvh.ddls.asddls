@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Hierarchy Node'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_HierNodeStdVH
  as select from I_ProdUnivHierNodeText_2
{
  key Language,
      @Consumption.filter: {
      selectionType : #SINGLE,          // 1 giá trị
      defaultValue  : 'PH_MANUFACTURING'  // <-- default như trên màn hình
      }
  key ProdUnivHierarchy,
        
  key HierarchyNode,
  key ProdHierarchyValidityEndDate,
      ProdHierarchyValidityStartDate,
      ProdUnivHierarchyNodeText,
      /* Associations */
      _ProductHierarchy,
      _ProductHierarchyNode
}

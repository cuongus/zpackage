@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Product Hierarchy Node'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZC_ProdUnivHierNodeStdVH
  as select from I_ProdUnivHierNodeText_2     as ProdUnivHierNodeText_2
    inner join   I_ProdUnivHierarchyNodeBasic as ProdUnivHierarchyNodeBasic on  ProdUnivHierarchyNodeBasic.HierarchyNode                = ProdUnivHierNodeText_2.HierarchyNode
                                                                            and ProdUnivHierarchyNodeBasic.ProdUnivHierarchy            = ProdUnivHierNodeText_2.ProdUnivHierarchy
                                                                            and ProdUnivHierarchyNodeBasic.ProdHierarchyValidityEndDate = ProdUnivHierNodeText_2.ProdHierarchyValidityEndDate
{
      @Semantics.language: true
      @UI.hidden: true
  key ProdUnivHierNodeText_2.Language                       as Language,
      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      @EndUserText.label: 'Prod Univ Hierarchy'

      //      @Consumption.filter: {
      //        selectionType : #SINGLE,          // 1 giá trị
      //        defaultValue  : 'PH_MANUFACTURING'  // <-- default như trên màn hình
      //      }
      @Consumption.filter.defaultValue: 'PH_MANUFACTURING'
  key ProdUnivHierNodeText_2.ProdUnivHierarchy              as ProdUnivHierarchy,
      @UI.hidden: true
  key ProdUnivHierNodeText_2.HierarchyNode                  as HierarchyNode,

      @UI.lineItem: [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      @EndUserText.label: 'Validity End Date'
  key ProdUnivHierNodeText_2.ProdHierarchyValidityEndDate   as ProdHierarchyValidityEndDate,

      ProdUnivHierNodeText_2.ProdHierarchyValidityStartDate as ProdHierarchyValidityStartDate,

      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @EndUserText.label: 'Product Hierarchy Node'
      ProdUnivHierarchyNodeBasic.ProdUnivHierarchyNode      as ProdUnivHierarchyNode,

      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @EndUserText.label: 'Description'
      ProdUnivHierNodeText_2.ProdUnivHierarchyNodeText      as ProdUnivHierarchyNodeText,
      /* Associations */
      ProdUnivHierNodeText_2._ProductHierarchy,
      ProdUnivHierNodeText_2._ProductHierarchyNode
}

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Hierarchy StdVH'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZI_ProdHierarchyBasic
  as select from I_ProdUnivHierarchyNodeBasic
  association [0..*] to I_ProdUnivHierNodeText_2 as _TextHierarchy3 on  $projection.ProdUnivHierarchy            = _TextHierarchy3.ProdUnivHierarchy
                                                                    and $projection.ProductHierarchy3            = _TextHierarchy3.HierarchyNode
                                                                    and $projection.ProdHierarchyValidityEndDate = _TextHierarchy3.ProdHierarchyValidityEndDate
                                                                    and $projection.Product                      = '' // we need this text assoc only for non-leaf nodes

  association [0..*] to I_ProdUnivHierNodeText_2 as _TextHierarchy4 on  $projection.ProdUnivHierarchy            = _TextHierarchy4.ProdUnivHierarchy
                                                                    and $projection.ProductHierarchy4            = _TextHierarchy4.HierarchyNode
                                                                    and $projection.ProdHierarchyValidityEndDate = _TextHierarchy4.ProdHierarchyValidityEndDate
                                                                    and $projection.Product                      = '' // we need this text assoc only for non-leaf nodes

{
      @UI.hidden: true
  key ProdUnivHierarchy,

      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @ObjectModel.text.element: [ 'ProductHierarchy4Name' ]
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @EndUserText.label: 'Product Hierarchy 4'
  key HierarchyNode                             as ProductHierarchy4,

      @UI.hidden: true
  key ProdHierarchyValidityEndDate,

      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @ObjectModel.text.element: [ 'ProductHierarchy3Name' ]
      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @EndUserText.label: 'Product Hierarchy 3'
      ParentNode                                as ProductHierarchy3,
      //      ProdUnivHierarchyNode,

      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @EndUserText.label: 'Product'
      Product,

      @UI.hidden: true
      _TextHierarchy3.ProdUnivHierarchyNodeText as ProductHierarchy3Name,
      @UI.hidden: true
      _TextHierarchy4.ProdUnivHierarchyNodeText as ProductHierarchy4Name,

      //      HierarchyNodeSequence,
      //      NodeType,
      //      HierarchyNodeLevel,
      //      HierarchyType,
      /* Associations */
      _Product,
      _ProductHierarchy,
      _Text,
      _TextHierarchy3,
      _TextHierarchy4
}

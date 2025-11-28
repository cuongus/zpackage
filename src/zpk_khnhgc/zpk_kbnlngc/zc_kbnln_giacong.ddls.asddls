@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection KB năng lực nhà gia công'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_KBNLN_GIACONG
  provider contract transactional_query
  as projection on ZI_KBNLN_GIACONG
{
  key Uuid,

      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity             : { name: 'ZC_WorkCenter', element: 'WorkCenter' },
      additionalBinding    : [{ localElement: 'Plant', element: 'Plant' }]
      }]
      @ObjectModel.text.element: [ 'WorkCenterText' ]
      Workcenter,

      //      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      //      @Consumption.valueHelpDefinition:[
      //      { entity             : { name: 'ZI_ProdHierarchyStdVH', element: 'HierarchyNode' }
      //      }]
      //      @ObjectModel.text.element: [ 'Description' ]
      HierarchyNode,

      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity             : { name: 'I_PlantStdVH', element: 'Plant' }
      }]
      @ObjectModel.text.element: [ 'PlantName' ]
      Plant,

      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity             : { name: 'ZC_ProdUnivHierNodeStdVH', element: 'ProdUnivHierarchyNode' }
      }]
      @ObjectModel.text.element: [ 'Description' ]
      ProdUnivHierarchynode,

      Dailyproductivity,

      //      @Consumption.valueHelpDefinition:[
      //      { entity             : { name: 'ZR_KBNLNGC_DATEVALID_stdVH', element: 'Todate' }
      //      }]
      Fromdate,
      Todate,

      //      WorkCenterInternalID,
      //      WorkCenterTypeCode,

      @Semantics.text: true
      _WorkCenter._Text[1: Language = $session.system_language ].WorkCenterText                  as WorkCenterText,

      @Semantics.text: true
      _Plant.PlantName                                                                           as PlantName,

      @Semantics.text: true
      _ProdUnivHierNodeText_2[1: Language = $session.system_language ].ProdUnivHierarchyNodeText as Description,


      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity             : { name: 'I_BusinessUserVH', element: 'UserID' }
      }]
      @ObjectModel.text.element: [ 'CreatedByName' ]
      CreatedBy,

      @Semantics.text: true
      _CreatebyUser.PersonFullName                                                               as CreatedByName,

      CreatedAt,

      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity             : { name: 'I_BusinessUserVH', element: 'UserID' }
      }]
      @ObjectModel.text.element: [ 'ChangedByName' ]
      LocalLastChangedBy,

      @Semantics.text: true
      _ChangebyUser.PersonFullName                                                               as ChangedByName,

      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _Plant,
      //      _WorkCenter,
      _ProdUnivHierNodeText_2
}

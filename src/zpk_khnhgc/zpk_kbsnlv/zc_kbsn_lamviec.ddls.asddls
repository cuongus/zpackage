@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection KB số ngày làm việc'

//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_KBSN_LAMVIEC
  provider contract transactional_query
  as projection on ZI_KBSN_LAMVIEC
{
  key Uuid,

      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity             : { name: 'ZC_WorkCenter', element: 'WorkCenter' },
      additionalBinding    : [{ localElement: 'Plant', element: 'Plant' }]
      }]
      @ObjectModel.text.element: [ 'WorkCenterText' ]
      Workcenter,

      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity             : { name: 'I_PlantStdVH', element: 'Plant' }
      }]
      @ObjectModel.text.element: [ 'PlantName' ]
      Plant,

      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity             : { name: 'ZR_WEEK_StdVH', element: 'Weeknum' },
      additionalBinding    : [{ localElement: 'Zyear', element: 'Zyear' }]
      }]
      //      @Consumption.filter : { multipleSelections: false }
      Week,

      LWeek,

      Zyear,

      Workingdays,

      @Semantics.text: true
      _WorkCenter._Text[1: Language = $session.system_language ].WorkCenterText as WorkCenterText,

      @Semantics.text: true
      _Plant.PlantName                                                          as PlantName,

      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity             : { name: 'I_BusinessUserVH', element: 'UserID' }
      }]
      @ObjectModel.text.element: [ 'CreatedByName' ]
      CreatedBy,

      @Semantics.text: true
      _CreatebyUser.PersonFullName                                              as CreatedByName,

      CreatedAt,

      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity             : { name: 'I_BusinessUserVH', element: 'UserID' }
      }]
      @ObjectModel.text.element: [ 'ChangedByName' ]
      LocalLastChangedBy,

      @Semantics.text: true
      _ChangebyUser.PersonFullName                                              as ChangedByName,

      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _Plant,
      _WorkCenter
}

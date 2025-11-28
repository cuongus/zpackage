@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Khai báo danh sách tổ đội, nhân công'
@Search.searchable: true
@Metadata.allowExtensions: true

define root view entity ZC_TW_LIST
  provider contract transactional_query
  as projection on ZI_TW_LIST as team_worker_list_c
{
  key UuID,

      WorkerId,
      @Consumption.valueHelpDefinition: [{
      entity: { name: 'I_WorkCenter', element: 'WorkCenter' },
      additionalBinding: [{ element: 'Plant', localElement: 'Plant'  }] }]
      @Search.defaultSearchElement: true
      WorkCenter,
      @Consumption.valueHelpDefinition: [{
      entity: { name: 'I_WorkCenter', element: 'Plant' },
      additionalBinding: [{ element: 'WorkCenter', localElement: 'WorkCenter' }] }]
      @Search.defaultSearchElement: true
      Plant,
      Shift,
      MachineId,
      TeamId,
      @Search.defaultSearchElement: true
      TeamName,
      @Search.defaultSearchElement: true
      WorkerName,
      FromDate,
      ToDate,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _Plant,
      _WorkCenter
}

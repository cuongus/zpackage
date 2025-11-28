@EndUserText.label: 'Data Definition - Khai báo danh sách nhân công theo xưởng'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true

 define root view entity ZC_KB_NHANCONG
   as projection on ZI_KB_NHANCONG as c_kb_nhancong
{
  key UuidNhancong,
  
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
      @Search.defaultSearchElement: true
      WorkerName,
      FromDate,
      ToDate,
      
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}

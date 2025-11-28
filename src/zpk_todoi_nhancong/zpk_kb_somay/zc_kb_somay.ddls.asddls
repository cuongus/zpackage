@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Definition - Khai báo danh sách máy theo xưởng'
@Search.searchable: true
@Metadata.allowExtensions: true

define root view entity ZC_KB_SOMAY
  as projection on ZI_KB_SOMAY as c_kb_somay
{
  key UuidSomay,

      @Consumption.valueHelpDefinition: [{
      entity: { name: 'I_WorkCenter', element: 'WorkCenter' } }]
      @Search.defaultSearchElement: true
      WorkCenter,
      @Search.defaultSearchElement: true
      MachineId,
      FromDate,
      ToDate,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}

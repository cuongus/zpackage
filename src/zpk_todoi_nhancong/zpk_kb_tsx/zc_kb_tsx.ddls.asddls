@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Definition - Khai báo danh sách tổ sản xuất theo xưởng'
@Search.searchable: true
@Metadata.allowExtensions: true

define root view entity ZC_KB_TSX
  as projection on ZI_KB_TSX as c_kb_tsx
{
  key UuidTsx,

      @Consumption.valueHelpDefinition: [{
      entity: { name: 'I_WorkCenter', element: 'WorkCenter' },
      additionalBinding: [{ element: 'Plant', localElement: 'Plant'  }] }]
      @Search.defaultSearchElement: true
      WorkCenter,
      @Consumption.valueHelpDefinition: [{
      entity: { name: 'I_WorkCenter', element: 'Plant' },
      additionalBinding: [{ element: 'WorkCenter', localElement: 'WorkCenter' }] }]
      Plant,
      TeamId,
      TeamName,
      FromDate,
      ToDate,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}

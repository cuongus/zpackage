@AbapCatalog.viewEnhancementCategory: [ #NONE ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'val help for order'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@Search.searchable: true
define view entity ZI_ORDERVH
  as select from I_PlannedOrder
{

  key PlannedOrder,
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Sales Order'
      SalesOrder,
      @Search.defaultSearchElement: true
      @EndUserText.label: 'MRP Controller'
      MRPController,
      @EndUserText.label: 'Production Plant'
               @Consumption.valueHelpDefinition:[
          { entity                       : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
          }]
      ProductionPlant
}

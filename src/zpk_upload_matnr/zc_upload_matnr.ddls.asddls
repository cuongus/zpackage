@EndUserText.label: 'data definition'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_UPLOAD_MATNR'
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_UPLOAD_MATNR
  as projection on ZI_UPLOAD_MATNR
{
  key MaterialDocument,
     
       @Consumption.valueHelpDefinition: [
          {
            entity: { name: 'ZJP_C_DOMAIN_FIX_VAL', element: 'description' },
            additionalBinding: [
              { element: 'domain_name', localConstant: 'ZDE_UPLOAD_MATNR', usage: #FILTER }
            ],
            distinctValues: true
          }
        ]
     key OptionName,
      key   MaterialSequenceNumber,
      MaterialDocumentItem,
 
      DocumentDate,
      PostingDate,
      MaterialHeaderText,
      Material,
      Plant,

      StorageLocation,
      Batch,
      ValuationType,
      Quantity,
      Unit,
      WarehouseNumber,
      StorageBin,
      SpecialStock,
      CostCenter,
      FixedAsset,
      SalesOrder,
      SalesOrderItem,
      GoodsMovementCode,
      GoodsMovementType,
      ControlPosting,
      Reservation,
      ReservationItem,
      MaterialDocumentItemText

}

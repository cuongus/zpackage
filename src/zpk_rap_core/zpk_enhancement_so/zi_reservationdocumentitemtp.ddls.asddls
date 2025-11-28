@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View I_ReservationDocumentItemTP'
//@ObjectModel.query.implementedBy: 'ABAP:ZCL_INVENTORY_DATA'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZI_ReservationDocumentItemTP
  provider contract transactional_query
  as projection on I_ReservationDocumentItemTP
{
  key Reservation,     //Readonly
  key ReservationItem, //Readonly
  key RecordType,      //Readonly
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_ProductStdVH', element: 'Product' } } ]
      Product,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_PlantStdVH', element: 'Plant' }} ]
      Plant,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_StorageLocationStdVH', element: 'StorageLocation' }} ]
      StorageLocation,
      GoodsMovementType,
      
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_BatchStdVH', element: 'Batch' },
                                additionalBinding: [{ element: 'Material', localElement: 'Product' },
                                                    { element: 'Plant', localElement: 'Plant' } ]} ]
      Batch,
      ValuationType,
      EntryUnit,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      ResvnItmRequiredQtyInEntryUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      ResvnItmWithdrawnQtyInBaseUnit,
      BaseUnit,
      MatlCompRequirementDate,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_GLAccountStdVH', element: 'GLAccount' } } ]
      GLAccount,
      ResvnAccountIsEnteredManually,
      ReservationItemText,
      GoodsRecipientName,
      UnloadingPointName,
      GoodsMovementIsAllowed,
      ReservationItmIsMarkedForDeltn,
      ReservationItemIsFinallyIssued,   
      YY1_SalesOrderItem_RES,
      YY1_SalesOrderSO_RES,
      YY1_CaSX_Re_RES,
      YY1_TeamPlant_RES,
      YY1_TeamWC_RES,
      YY1_TeamID_RES,
      /* Associations */
      _StorageLocation,
      _YY1_SalesOrder_RES
}

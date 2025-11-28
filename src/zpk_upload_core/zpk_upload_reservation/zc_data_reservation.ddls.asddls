@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View Data Reservation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.sapObjectNodeType.name: 'ZIDTRESERV'
@Metadata.allowExtensions: true

define view entity ZC_DATA_RESERVATION
  as projection on ZI_DATA_RESERVATION
{
  key Uuid,
      Uuidfile,
      Reservation,

      @ObjectModel.text.element: ['OverallStatusText']
      MessageType,

      Criticality,

      @EndUserText.label: 'Status'
      @Semantics.text: true
      _OverallStatus.description as OverallStatusText,
      MessageText,

      Documentsequenceno,
      Basedate,
      Costcenter,
      Goodsmovementtype,
      Plant,
      Receivingissuing,
      Storagelocation,
      Materialnumber,
      @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
      Quantity,
      Unitofmeasure,
      Batch,
      Salesorder,
      Salesorderitem,
      ValuationType,
      Requirementdate,
      Glaccount,

      CreatedByUser,
      CreatedDate,
      ChangedByUser,
      ChangedDate,

      /* Associations */
      _ManageFile : redirected to parent ZC_MN_RESERVATION
}

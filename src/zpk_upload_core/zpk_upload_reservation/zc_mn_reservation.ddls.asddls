@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage File Upload Reservation'
//@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.sapObjectNodeType.name: 'ZIMNRESERV'
@Metadata.allowExtensions: true
define root view entity ZC_MN_RESERVATION
  provider contract transactional_query
  as projection on ZI_MN_RESERVATION
{
  key Uuid,
      ZCount,
      @ObjectModel.text.element: ['OverallStatusText']
      Status,
      
      Criticality,
      
      @EndUserText.label: 'Status'
      @Semantics.text: true
      _OverallStatus.description as OverallStatusText,
      Attachment,
      Mimetype,
      Filename,
      Countline,
      Createdbyuser,
      Createddate,
      Changedbyuser,
      Changeddate,

      /* Associations */
      _DataReservation : redirected to composition child ZC_DATA_RESERVATION
}

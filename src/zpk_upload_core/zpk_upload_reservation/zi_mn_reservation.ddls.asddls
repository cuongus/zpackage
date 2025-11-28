@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage File Upload Reservation'
//@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.sapObjectNodeType.name: 'ZIMNRESERV'
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define root view entity ZI_MN_RESERVATION
  as select from zui_mreservation
  composition [0..*] of ZI_DATA_RESERVATION as _DataReservation
  association [0..1] to ZI_REQ_STA_VH       as _OverallStatus on $projection.Status = _OverallStatus.Status
{
  key uuid          as Uuid,
      zcount        as ZCount,
      status        as Status,

      case status
      when '' then 0
      when 'P' then 2
      when 'D' then 3
      else 0
      end           as Criticality,

      @Semantics.largeObject: { mimeType: 'Mimetype',
                      fileName: 'Filename',
                      contentDispositionPreference: #INLINE }
      attachment    as Attachment,

      @Semantics.mimeType: true
      mimetype      as Mimetype,

      filename      as Filename,

      countline     as Countline,
      @Semantics.user.createdBy: true
      createdbyuser as Createdbyuser,
      @Semantics.systemDateTime.createdAt: true
      createddate   as Createddate,
      @Semantics.user.lastChangedBy: true
      changedbyuser as Changedbyuser,
      @Semantics.systemDateTime.lastChangedAt: true
      changeddate   as Changeddate,
      //      _association_name // Make association public
      _DataReservation,
      _OverallStatus
}

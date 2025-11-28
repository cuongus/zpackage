@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage User Upload File FI'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_USER_UPLOAD_FI
  as select from zuser_upload_fi
//  composition [0..*] of ZI_USR_DATA_FILE  as _dataFile
  composition [0..*] of ZI_UUID_DATA_FILE1 as _previewData
  association [0..1] to ZI_REQ_STA_VH     as _OverallStatus on $projection.Status = _OverallStatus.Status

{
  key uuid          as Uuid,
  key end_user      as EndUser,
      zcnt          as ZCount,
      status        as Status,
      @Semantics.largeObject: { mimeType: 'Mimetype',
                            fileName: 'Filename',
                            contentDispositionPreference: #INLINE }
      attachment    as Attachment,
      
      @Semantics.mimeType: true
      mimetype      as Mimetype,
      
      @Semantics.user.createdBy: true
      filename      as Filename,
      
      @Semantics.user.createdBy: true
      createdbyuser as Createdbyuser,
      @Semantics.systemDateTime.createdAt: true
      createddate   as Createddate,
      @Semantics.user.lastChangedBy: true
      changedbyuser as Changedbyuser,
      @Semantics.systemDateTime.lastChangedAt: true
      changeddate   as Changeddate,
      
      _previewData,
      _OverallStatus
}

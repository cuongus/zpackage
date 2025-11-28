@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Manage User Upload'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_USER_UPLOAD_FI
  provider contract transactional_query
  as projection on ZR_USER_UPLOAD_FI
{
  key Uuid,
  key EndUser,
      ZCount,
      Status,
      Attachment,
      Mimetype,
      Filename,
      Createdbyuser,
      Createddate,
      Changedbyuser,
      Changeddate,
      /* Associations */
      _OverallStatus,
      _previewData : redirected to composition child ZC_UUID_DATA_FILE1
}

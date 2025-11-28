@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage file Upload CO11N'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCM_CONFIRM_PRODUCTION_ORDER
  provider contract transactional_query
  as projection on ZIM_CONFIRM_PRODUCTION_ORDER
{
  key Uuid,
      Zcount,
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

      _OverallStatus,
      _DataFile : redirected to composition child ZIC_CONFIRM_PRODUCTION_ORDER
}

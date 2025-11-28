@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage file Upload CO11N'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define root view entity ZIM_CONFIRM_PRODUCTION_ORDER
  as select from zui_mco11n
  //composition of target_data_source_name as _association_name
  association [0..1] to ZI_REQ_STA_VH                as _OverallStatus on $projection.Status = _OverallStatus.Status
  composition [0..*] of ZIU_Confirm_Production_Order as _DataFile
{
  key uuid          as Uuid,
      zcount        as Zcount,
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
      //    _association_name // Make association public
      _OverallStatus,
      _DataFile
}

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS KHNH theo tuần'
@Metadata.ignorePropagatedAnnotations: true
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define root view entity ZR_UI_PBKHNH
  as select from zui_pbkhnh

  association [0..1] to I_BusinessUserVH as _CreatebyUser on $projection.CreatedBy = _CreatebyUser.UserID

  association [0..1] to I_BusinessUserVH as _ChangebyUser on $projection.LocalLastChangedBy = _ChangebyUser.UserID

{
  key uuid                  as Uuid,
      version               as Version,
      versionname           as Versionname,
      companycode           as Companycode,
      producthierarchy3     as Producthierarchy3,
      plant                 as Plant,
      zyear                 as Zyear,
      week                  as Week,
      lweek                 as LWeek,
      receivingplan         as Receivingplan,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,

      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _CreatebyUser,
      _ChangebyUser

}

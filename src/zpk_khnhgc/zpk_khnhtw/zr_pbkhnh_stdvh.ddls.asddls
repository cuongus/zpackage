@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Version KHNH Value Help'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PBKHNH_StdVH
  as select distinct from zui_pbkhnh
  association [0..1] to I_CompanyCode as _CCode on $projection.Companycode = _CCode.CompanyCode
{
      @UI.hidden: true
  key uuid                   as Uuid,
      @EndUserText.label: 'Mã phiên bản'
      version                as Version,

      @EndUserText.label: 'Tên phiên bản'
      versionname            as Versionname,

      @EndUserText.label: 'Company Code'
      companycode            as Companycode,

      _CCode.CompanyCodeName as CompanyCodeName,
      //      producthierarchy3     as Producthierarchy3,
      //      plant                 as Plant,
      //      zyear                 as Zyear,
      //      week                  as Week,
      //      receivingplan         as Receivingplan,
      created_by             as CreatedBy,
      created_at             as CreatedAt,
      local_last_changed_by  as LocalLastChangedBy,
      local_last_changed_at  as LocalLastChangedAt,
      last_changed_at        as LastChangedAt,
      _CCode
}

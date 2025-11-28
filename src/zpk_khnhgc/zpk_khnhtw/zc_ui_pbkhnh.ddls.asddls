@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Project CDS KHNH theo tuần'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_UI_PBKHNH
  provider contract transactional_query
  as projection on ZR_UI_PBKHNH
{
  key Uuid,
      Version,
      Versionname,
      Companycode,
      Producthierarchy3,
      Plant,
      Zyear,
      Week,
      LWeek,
      Receivingplan,
      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt
}

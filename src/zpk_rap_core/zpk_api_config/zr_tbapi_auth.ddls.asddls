@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBAPI_AUTH'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBAPI_AUTH
  as select from ZTB_API_AUTH
{
  key systemid as Systemid,
  key api_user as ApiUser,
  api_password as ApiPassword,
  api_url as ApiUrl,
  api_token as ApiToken,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt
}

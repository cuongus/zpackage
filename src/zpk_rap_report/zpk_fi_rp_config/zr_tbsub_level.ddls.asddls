@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBSUB_LEVEL'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBSUB_LEVEL
  as select from ZTB_SUB_LEVEL
{
  key sublevel as Sublevel,
  key gl_account as GlAccount,
  ztext as Ztext,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt
}

@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBUSER'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBUSER
  as select from ztb_user
  composition [0..*] of ZR_TBUSER_ROLE as _dtl
{
  key id as ID,
  zuser as Zuser,
  zname as Zname,
  password as Password,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  _dtl
}

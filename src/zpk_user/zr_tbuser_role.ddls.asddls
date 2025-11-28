@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBUSER_ROLE'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZR_TBUSER_ROLE
  as select from ztb_user_role
  association        to parent ZR_TBUSER as _hdr on  $projection.ID = _hdr.ID
{
  key id as ID,
  key urid as Urid,
  zrole as Zrole,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  _hdr
}

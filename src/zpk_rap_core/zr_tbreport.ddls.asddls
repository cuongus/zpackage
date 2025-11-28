@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBREPORT'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBREPORT
  as select from ztb_report
  composition [0..*] of ZR_TBRP_ITEM as _dtl
    composition [0..*] of ZR_TBRP_COL as _col
{
  key rp_id as RpID,
  rp_code as RpCode,
  rp_name as RpName,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  _dtl,
  _col
}

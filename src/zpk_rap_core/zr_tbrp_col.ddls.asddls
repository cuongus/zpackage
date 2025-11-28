@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBRP_COL'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZR_TBRP_COL
  as select from ztb_rp_col
  association        to parent ZR_TBREPORT as _hdr on  $projection.RpID = _hdr.RpID
{
  key rp_id as RpID,
  key coluuid as ColUUID,
  col_id as ColID,
  col_desc as ColDesc,
  col_cond as ColCond,
  col_cond2 as ColCond2,
  col_cond3 as ColCond3,
  col_cond4 as ColCond4,
  formula as Formula,
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

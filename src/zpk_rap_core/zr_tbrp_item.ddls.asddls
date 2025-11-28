@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBRP_ITEM'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZR_TBRP_ITEM
  as select from ztb_rp_item
  association        to parent ZR_TBREPORT as _hdr on  $projection.RpID = _hdr.RpID
{
  key rp_id as RpID,
  key item_id as ItemID,
  item_code1 as ItemCode1,
  item_code as ItemCode,
  display_code as DisplayCode,
  item_desc as ItemDesc,
  item_cond as ItemCond,
  item_cond2 as ItemCond2,
  item_cond3 as ItemCond3,
  item_cond4 as ItemCond4,
  formula as Formula,
  display as Display,
  font as Font,
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

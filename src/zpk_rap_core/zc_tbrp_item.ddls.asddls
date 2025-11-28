@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBRP_ITEM'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZC_TBRP_ITEM
  as projection on ZR_TBRP_ITEM
  
{
  key RpID,
  key ItemID,
  ItemCode1,
  ItemCode,
  DisplayCode,
  ItemDesc,
  ItemCond,
  ItemCond2,
  ItemCond3,
  ItemCond4,
  Formula,
  Display,
  Font,
  @Semantics: {
    user.createdBy: true
  }
  CreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  CreatedAt,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  LastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LastChangedAt,
  _hdr  : redirected to parent ZC_TBREPORT
}

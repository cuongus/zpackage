@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBRP_COL'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZC_TBRP_COL
  as projection on ZR_TBRP_COL{
  key RpID,
  key ColUUID,
  ColID,
  ColDesc,
  ColCond,
  ColCond2,
  ColCond3,
  ColCond4,
  Formula,
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

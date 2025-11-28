@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBPERIOD'
}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZC_TBPERIOD
  as projection on ZR_TBPERIOD
{
  key Zyear,
  key Zper,
  Zdesc,
  zmonth,
  zdatefr,
  zdateto,
  LastPer,
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
  _hdr  : redirected to parent ZC_TBYEAR
}

@Metadata.allowExtensions: true
//@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBAPP_FUNC'
}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZC_TBAPP_FUNC
  as projection on ZR_TBAPP_FUNC
{
  key Appid,
  key Dtlid,
  Zfunc,
  Zdesc,
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
  _hdr  : redirected to parent ZC_TBAPP
}

@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBROLES'
}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_TBROLES
  provider contract transactional_query
  as projection on ZR_TBROLES
{
  key ID,
  @Search.defaultSearchElement: true
  Zrole,
  Zdesc,
  Zapp,
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
  _dtl : redirected to composition child ZC_TBROLES_FUNC,
  _dta : redirected to composition child ZC_TBROLES_DATA
}

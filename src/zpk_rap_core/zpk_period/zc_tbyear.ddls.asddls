@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBYEAR'
}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_TBYEAR
  provider contract transactional_query
  as projection on ZR_TBYEAR
  
{
  key Zyear,
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
  _dtl : redirected to composition child ZC_TBPERIOD
}

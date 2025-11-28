@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBREPORT'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBREPORT
  provider contract transactional_query
  as projection on ZR_TBREPORT
{ 
  key RpID,
  RpCode,
  RpName,
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
  _dtl : redirected to composition child ZC_TBRP_ITEM,
  _col : redirected to composition child ZC_TBRP_COL
}

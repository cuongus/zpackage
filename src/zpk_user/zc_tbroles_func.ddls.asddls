@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBROLES_FUNC'
}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZC_TBROLES_FUNC
  as projection on ZR_TBROLES_FUNC
{
  key ID,
  key Dtlid,
   @Consumption.valueHelpDefinition:[
      { entity                       : { name : 'zi_TB_APP_FUNC' , element: 'Zfunc' } }
     ]
  Zfunc,
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
  _hdr  : redirected to parent ZC_TBROLES
}

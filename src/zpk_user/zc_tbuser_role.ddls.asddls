@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBUSER_ROLE'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZC_TBUSER_ROLE
  as projection on ZR_TBUSER_ROLE
{
  key ID,
  key Urid,
       @Consumption.valueHelpDefinition:[
      { entity                       : { name : 'ZI_TB_ROLES' , element: 'Zrole' } }
     ]
  Zrole,
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
  _hdr  : redirected to parent ZC_TBUSER
}

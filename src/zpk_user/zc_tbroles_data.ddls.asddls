@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBROLES_DATA'
}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZC_TBROLES_DATA
  as projection on ZR_TBROLES_DATA
{
  key ID,
  key Dataid,
     @Consumption.valueHelpDefinition:[
      { entity                       : { name : 'I_Plant' , element: 'Plant' } }
     ]
  Werks,
     @Consumption.valueHelpDefinition:[
      { entity                       : { name : 'I_StorageLocation' , element: 'StorageLocation' } }
     ]
  Lgort,

//     @Consumption.valueHelpDefinition:[
//      { entity                       : { name : 'I_WorkCenterStdVH' , element: 'WorkCenter' } }
//     ]
  Workcenter,
//     @Consumption.valueHelpDefinition:[
//      { entity                       : { name : 'I_EWM_WarehouseNumber_2' , element: 'Zfunc' } }
//     ]
  Lgnum,
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

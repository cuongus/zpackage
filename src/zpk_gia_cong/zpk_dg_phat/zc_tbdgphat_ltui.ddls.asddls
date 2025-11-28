@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBDGPHAT_LTUI'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBDGPHAT_LTUI
  provider contract transactional_query
  as projection on ZR_TBDGPHAT_LTUI
  association [1..1] to ZR_TBDGPHAT_LTUI as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  @Consumption.valueHelpDefinition:[
          { entity                       : { name : 'ZJP_C_DOMAIN_FIX_VAL' , element: 'low' } ,
          additionalBinding              : [{ element: 'domain_name',
                    localConstant        : 'ZDE_MALOI', usage: #FILTER }]
                    , distinctValues     : true
          }]
  Errorcode,
  Errorname,
   @Consumption.valueHelpDefinition:[
       { entity                       : { name : 'zc_loai_tui_1' , element: 'ProdUnivHierarchyNode' } }
      ]
  Loaitui,
  LoaituiText,
  Penaltyprice,
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
  _BaseEntity
}

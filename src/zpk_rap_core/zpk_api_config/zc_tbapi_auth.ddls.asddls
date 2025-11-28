@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZTBAPI_AUTH'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBAPI_AUTH
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TBAPI_AUTH
  association [1..1] to ZR_TBAPI_AUTH as _BaseEntity on $projection.SYSTEMID = _BaseEntity.SYSTEMID and $projection.APIUSER = _BaseEntity.APIUSER
{
  key Systemid,
  key ApiUser,
  ApiPassword,
  ApiUrl,
  ApiToken,
  @Semantics: {
    User.Createdby: true
  }
  CreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  CreatedAt,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  LastChangedBy,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LastChangedAt,
  _BaseEntity
}

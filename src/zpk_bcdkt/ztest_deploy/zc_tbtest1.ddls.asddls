@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZTBTEST1'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBTEST1
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TBTEST1
  association [1..1] to ZR_TBTEST1 as _BaseEntity on $projection.CODE = _BaseEntity.CODE
{
  key Code,
  Name,
  @Semantics: {
    User.Createdby: true
  }
  Createdby,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LocalLastChangedAt,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  LastChangedAt,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  LastChangedBy,
  _BaseEntity
}

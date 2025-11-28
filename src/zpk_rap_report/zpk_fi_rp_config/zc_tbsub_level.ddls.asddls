@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZTBSUB_LEVEL'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBSUB_LEVEL
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TBSUB_LEVEL
  association [1..1] to ZR_TBSUB_LEVEL as _BaseEntity on $projection.SUBLEVEL = _BaseEntity.SUBLEVEL and $projection.GLACCOUNT = _BaseEntity.GLACCOUNT
{
  key Sublevel,
  key GlAccount,
  Ztext,
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

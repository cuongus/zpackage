@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZTBCROD_HT'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBCROD_HT
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TBCROD_HT
  association [1..1] to ZR_TBCROD_HT as _BaseEntity on $projection.OUTBOUNDDELIVERY = _BaseEntity.OUTBOUNDDELIVERY and $projection.PRODUCT = _BaseEntity.PRODUCT
{
  key Outbounddelivery,
  key Product,
  Hoanthanh,
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

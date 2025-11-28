@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZTBCROD_2'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBCROD_2
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TBCROD_2
  association [1..1] to ZR_TBCROD_2 as _BaseEntity on $projection.PURCHASEORDER = _BaseEntity.PURCHASEORDER and $projection.PURCHASEORDERITEM = _BaseEntity.PURCHASEORDERITEM and $projection.OUTBOUNDDELIVERY = _BaseEntity.OUTBOUNDDELIVERY
{
  key Purchaseorder,
  key Purchaseorderitem,
  key Outbounddelivery,
  Sldongbo,
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

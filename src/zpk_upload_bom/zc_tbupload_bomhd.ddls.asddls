@Metadata.allowExtensions: true
//@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBUPLOAD_BOMHD'
}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_TBUPLOAD_BOMHD
  provider contract transactional_query
  as projection on ZR_TBUPLOAD_BOMHD
//  association [1..1] to ZR_TBUPLOAD_BOMHD as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  FileName,
  Attachment,
  Mimetype,
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
  Message,
     _dtl : redirected to composition child ZC_TBUPLOAD_BOMIT
//  _BaseEntity
}

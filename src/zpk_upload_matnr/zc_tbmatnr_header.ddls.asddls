@Metadata.allowExtensions: true
//@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Tool Upload MIGO'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBMATNR_HEADER'
}
@AccessControl.authorizationCheck: #NOT_REQUIRED
//@ObjectModel.query.implementedBy: 'ABAP:ZCL_UPLOAD_MATNR'
define root view entity ZC_TBMATNR_HEADER
  provider contract transactional_query
  as projection on ZR_TBMATNR_HEADER
  //  association [1..1] to ZR_TBMATNR_HEADER as _BaseEntity on $projection.FILENAME = _BaseEntity.FILENAME
{
  key Uuid,

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

      _dtl : redirected to composition child ZC_TBUPLOAD_MATNR
      //  _BaseEntity
}

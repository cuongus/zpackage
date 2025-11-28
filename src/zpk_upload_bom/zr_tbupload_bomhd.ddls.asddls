@AccessControl.authorizationCheck: #NOT_REQUIRED
//@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBUPLOAD_BOMHD'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBUPLOAD_BOMHD
  as select from ztb_upload_bomhd
  composition [0..*] of ZR_TBUPLOAD_BOMIT as _dtl
{
  key uuid            as UUID,
      file_name       as FileName,
      @Semantics.largeObject: { mimeType: 'Mimetype',
                             fileName: 'Filename',
                             contentDispositionPreference: #INLINE }
      attachment      as Attachment,

      @Semantics.mimeType: true
      mimetype        as Mimetype,
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt,
      message         as Message,
      _dtl
}

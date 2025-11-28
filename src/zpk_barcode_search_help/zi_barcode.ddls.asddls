@EndUserText.label: 'PENALTY_PRICE - Interface'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_BARCODE
  as select from ztb_barcode
{
  key  line_id          as LineId,
  key  ma_nv            as MaNv,
       role             as Role,
       name_nv          as NameNv,
       plant            as Plant,
       storage_location as StorageLocation
       
//      @Semantics.user.createdBy: true
//      created_by      as CreatedBy,
//      @Semantics.systemDateTime.createdAt: true
//      created_at      as CreatedAt,
//      @Semantics.user.localInstanceLastChangedBy: true
//      last_changed_by as LastChangedBy,
//      @Semantics.systemDateTime.localInstanceLastChangedAt: true
//      last_changed_at as LastChangedAt

}

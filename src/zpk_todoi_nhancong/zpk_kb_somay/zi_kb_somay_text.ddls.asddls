@AbapCatalog.sqlViewName: 'ZI_KBSOMAY_TXT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Text Khai báo số máy'
@Metadata.ignorePropagatedAnnotations: true
define view zi_kb_somay_text
  as select from ztb_kb_somay
{
  key uuid_somay            as UuidSomay,
      work_center           as WorkCenter,
      machine_id            as MachineId
//      from_date             as FromDate,
//      to_date               as ToDate,
//      created_by            as CreatedBy,
//      created_at            as CreatedAt,
//      last_changed_by       as LastChangedBy,
//      last_changed_at       as LastChangedAt,
//      local_last_changed_at as LocalLastChangedAt
}

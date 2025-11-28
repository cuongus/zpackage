@EndUserText.label: 'Data Definition - Khai báo danh sách máy theo xưởng'
@AccessControl.authorizationCheck: #NOT_REQUIRED

define root view entity ZI_KB_SOMAY
  as select from ztb_kb_somay as i_kb_somay
{
  key uuid_somay            as UuidSomay,

      work_center           as WorkCenter,
      machine_id            as MachineId,
      from_date             as FromDate,
      to_date               as ToDate,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}

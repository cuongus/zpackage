@EndUserText.label: 'Data Definition - Khai báo danh sách nhân công theo xưởng'
@AccessControl.authorizationCheck: #CHECK

define root view entity ZI_KB_NHANCONG
  as select from ztb_kb_nhancong as i_kb_nhancong
{
  key uuid_nhancong         as UuidNhancong,
  
      work_center           as WorkCenter,
      plant                 as Plant,
      worker_id             as WorkerId,
      worker_name           as WorkerName,
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

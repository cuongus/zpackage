@EndUserText.label: 'Data Definition - Khai báo danh sách tổ sản xuất theo xưởng'
@AccessControl.authorizationCheck: #NOT_REQUIRED

define root view entity ZI_KB_TSX
  as select from ztb_kb_tsx as i_kb_tsx
{
  key uuid_tsx              as UuidTsx,

      work_center           as WorkCenter,
      plant                 as Plant,
      team_id               as TeamId,
      team_name             as TeamName,
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

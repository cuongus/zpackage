@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Khai báo danh sách tổ đội, nhân công'
@ObjectModel.usageType.serviceQuality: #B
@ObjectModel.usageType.dataClass: #MASTER
@ObjectModel.supportedCapabilities:
  [  #CDS_MODELING_DATA_SOURCE,
     #CDS_MODELING_ASSOCIATION_TARGET,
     #SQL_DATA_SOURCE                  ]
define root view entity ZI_TW_LIST
  as select from ztb_tw_list as team_worker_list_i

  association [1..*] to I_WorkCenter as _WorkCenter on  $projection.WorkCenter              = _WorkCenter.WorkCenter
                                                    and _WorkCenter.OperationControlProfile = 'YBP1'
  association [1..*] to I_WorkCenter as _Plant      on  $projection.Plant = _Plant.Plant
{
  key uuid                  as UuID,

      worker_id             as WorkerId,
      work_center           as WorkCenter,
      plant                 as Plant,
      shift                 as Shift,
      machine_id            as MachineId,
      team_id               as TeamId,
      team_name             as TeamName,
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
      local_last_changed_at as LocalLastChangedAt,

      /* Associations */
      _WorkCenter,
      _Plant
}

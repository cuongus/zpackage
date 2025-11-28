@AbapCatalog.sqlViewName: 'ZTW_LIST_VH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tổ đội, nhân công for VH'
@Metadata.ignorePropagatedAnnotations: true

@VDM.viewType: #BASIC

@ObjectModel: { dataCategory: #VALUE_HELP,
                representativeKey: 'Uuid',
                usageType.sizeCategory: #S,
                usageType.dataClass: #ORGANIZATIONAL,
                usageType.serviceQuality: #A,
                supportedCapabilities: [#VALUE_HELP_PROVIDER, #SEARCHABLE_ENTITY],
                modelingPattern: #VALUE_HELP_PROVIDER }

@ClientHandling.algorithm: #SESSION_VARIABLE

@Search.searchable: true
define view ZI_TW_LIST_VH
  as select from ztb_tw_list
{
  key uuid                  as Uuid,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
  key worker_id             as WorkerId,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
  key shift                 as Shift,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
  key machine_id            as MachineId,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
  key team_id               as TeamId,
      work_center           as WorkCenter,
      plant                 as Plant,
      team_name             as TeamName,
      worker_name           as WorkerName,
      from_date             as FromDate,
      to_date               as ToDate,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}

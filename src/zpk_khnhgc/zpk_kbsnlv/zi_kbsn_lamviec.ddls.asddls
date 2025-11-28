@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view KB Số ngày làm việc'
@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType.serviceQuality: #B
@ObjectModel.usageType.dataClass: #MASTER
@ObjectModel.supportedCapabilities:
  [  #CDS_MODELING_DATA_SOURCE,
     #CDS_MODELING_ASSOCIATION_TARGET,
     #SQL_DATA_SOURCE                  ]

/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define root view entity ZI_KBSN_LAMVIEC
  as select from zui_kbsnlv
  //composition of target_data_source_name as _association_name
  association [0..1] to I_WorkCenter     as _WorkCenter   on  $projection.Workcenter = _WorkCenter.WorkCenter
                                                          and $projection.Plant      = _WorkCenter.Plant

  association [0..1] to I_Plant          as _Plant        on  $projection.Plant = _Plant.Plant

  association [0..1] to I_BusinessUserVH as _CreatebyUser on  $projection.CreatedBy = _CreatebyUser.UserID

  association [0..1] to I_BusinessUserVH as _ChangebyUser on  $projection.LocalLastChangedBy = _ChangebyUser.UserID

{
  key uuid                  as Uuid,

      workcenter            as Workcenter,

      plant                 as Plant,

      week                  as Week,

      lweek                 as LWeek,

      zyear                 as Zyear,

      workingdays           as Workingdays,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,

      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      //  _association_name // Make association public
      _WorkCenter,
      _Plant,
      _CreatebyUser,
      _ChangebyUser
}

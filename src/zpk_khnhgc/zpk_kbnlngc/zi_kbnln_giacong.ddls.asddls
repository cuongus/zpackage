@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view Khai báo năng lực nhà gia công'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.supportedCapabilities: [#SQL_DATA_SOURCE,
                                     #CDS_MODELING_DATA_SOURCE,
                                     #CDS_MODELING_ASSOCIATION_TARGET,
                                     #ANALYTICAL_DIMENSION,
                                     #EXTRACTION_DATA_SOURCE]
@ObjectModel.modelingPattern: #ANALYTICAL_DIMENSION
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #XL
@ObjectModel.usageType.dataClass: #MASTER
@VDM.viewType: #BASIC
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define root view entity ZI_KBNLN_GIACONG
  as select from zui_kbnlngc
  //  composition of target_data_source_name as _association_name
  association [0..1] to I_WorkCenter             as _WorkCenter             on  $projection.Workcenter = _WorkCenter.WorkCenter
                                                                            and $projection.Plant      = _WorkCenter.Plant

  association [0..1] to I_Plant                  as _Plant                  on  $projection.Plant = _Plant.Plant

  association [0..1] to I_ProdUnivHierNodeText_2 as _ProdUnivHierNodeText_2 on  $projection.HierarchyNode = _ProdUnivHierNodeText_2.HierarchyNode
    
  association [0..1] to I_BusinessUserVH as _CreatebyUser on $projection.CreatedBy = _CreatebyUser.UserID

  association [0..1] to I_BusinessUserVH as _ChangebyUser on $projection.LocalLastChangedBy = _ChangebyUser.UserID

{
  key  uuid                  as Uuid,
       @ObjectModel.foreignKey.association: '_WorkCenter'
       workcenter            as Workcenter,
       hierarchynode         as HierarchyNode,
       @ObjectModel.foreignKey.association: '_Plant'
       plant                 as Plant,

       @ObjectModel.foreignKey.association: '_ProdUnivHierNodeText_2'
       produnivhierarchynode as ProdUnivHierarchynode,
       dailyproductivity     as Dailyproductivity,

       fromdate              as Fromdate,
       todate                as Todate,

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

       //       _association_name // Make association public
       _WorkCenter,
       _Plant,
       _ProdUnivHierNodeText_2,
       _CreatebyUser,
       _ChangebyUser
}

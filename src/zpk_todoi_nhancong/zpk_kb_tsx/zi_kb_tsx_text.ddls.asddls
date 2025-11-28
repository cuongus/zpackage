@AbapCatalog.sqlViewName: 'ZI_KBTSX_TXT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Text KB TSX'
@ClientHandling.algorithm: #SESSION_VARIABLE
@ObjectModel.representativeKey: 'TeamId'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.usageType.dataClass: #CUSTOMIZING
@ObjectModel.usageType.serviceQuality: #X
@ObjectModel.usageType.sizeCategory: #S
@ObjectModel.supportedCapabilities: [#SQL_DATA_SOURCE,#CDS_MODELING_DATA_SOURCE,#CDS_MODELING_ASSOCIATION_TARGET,#LANGUAGE_DEPENDENT_TEXT]
@Search.searchable: true
@VDM.viewType: #BASIC
@Metadata.ignorePropagatedAnnotations: true
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view ZI_KB_TSX_TEXT
  as select from ztb_kb_tsx
{
      //  key uuid_tsx              as UuidTsx,
      //      work_center           as WorkCenter,
      //      plant                 as Plant,
      @ObjectModel.text.element: [ 'TeamName' ]
      @Search.defaultSearchElement: true
  key team_id   as TeamId,
      @Semantics.text: true
      team_name as TeamName
      //      from_date             as FromDate,
      //      to_date               as ToDate,
      //      created_by            as CreatedBy,
      //      created_at            as CreatedAt,
      //      last_changed_by       as LastChangedBy,
      //      last_changed_at       as LastChangedAt,
      //      local_last_changed_at as LocalLastChangedAt
}

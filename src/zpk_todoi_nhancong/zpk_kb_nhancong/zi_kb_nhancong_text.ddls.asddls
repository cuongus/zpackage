@AbapCatalog.sqlViewName: 'ZI_KBNHACONG_TXT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Text KB Nhân công'
@ClientHandling.algorithm: #SESSION_VARIABLE
@ObjectModel.representativeKey: 'WorkerId'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.usageType.dataClass: #CUSTOMIZING
@ObjectModel.usageType.serviceQuality: #X
@ObjectModel.usageType.sizeCategory: #S
@ObjectModel.supportedCapabilities: [#SQL_DATA_SOURCE,#CDS_MODELING_DATA_SOURCE,#CDS_MODELING_ASSOCIATION_TARGET,#LANGUAGE_DEPENDENT_TEXT]
@Search.searchable: true
@VDM.viewType: #BASIC
@Metadata.ignorePropagatedAnnotations: true
define view ZI_KB_NHANCONG_TEXT
  as select from ztb_kb_nhancong
{
      //    key uuid_nhancong as UuidNhancong,
      //    work_center as WorkCenter,
      //    plant as Plant,
      @ObjectModel.text.element: [ 'WorkerName' ]
      @Search.defaultSearchElement: true
  key worker_id   as WorkerId,
      @Semantics.text: true
      worker_name as WorkerName
      //    from_date as FromDate,
      //    to_date as ToDate,
      //    created_by as CreatedBy,
      //    created_at as CreatedAt,
      //    last_changed_by as LastChangedBy,
      //    last_changed_at as LastChangedAt,
      //    local_last_changed_at as LocalLastChangedAt
}

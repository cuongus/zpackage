@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'I_POSubcontractingCompAPI01'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zI_POSubcontractingCompAPI01 as select from I_POSubcontractingCompAPI01
{
    key PurchaseOrder,
    key PurchaseOrderItem,
    key PurchaseOrderScheduleLine,
    key ReservationItem,
    key RecordType,
    Reservation,
    Material,
    BaseUnit,
    @Semantics.quantity.unitOfMeasure: 'BaseUnit'
    RequiredQuantity,
    @Semantics.quantity.unitOfMeasure: 'BaseUnit'
    WithdrawnQuantity,
    QuantityIsFixed,
    RequirementDate,
    RequirementTime,
    Plant,
    LatestRequirementDate,
    OrderLevelValue,
    OrderPathValue,
    BillOfMaterialItemNumber,
    BillOfMaterialItemNumber_2,
    SortField,
    BOMItemCategory,
    MaterialComponentIsPhantomItem,
    IsBulkMaterialComponent,
    AccountAssignmentCategory,
    InventorySpecialStockType,
    ConsumptionPosting,
    InventorySpecialStockValnType,
    IsMaterialProvision,
    MaterialProvisionType,
    SalesOrder,
    SalesOrderItem,
    WBSElementInternalID,
    DebitCreditCode,
    ReservationIsFinallyIssued,
    EntryUnit,
    @Semantics.quantity.unitOfMeasure: 'EntryUnit'
    QuantityInEntryUnit,
    MaterialQtyToBaseQtyNmrtr,
    MaterialQtyToBaseQtyDnmntr,
    ComponentScrapInPercent,
    OperationScrapInPercent,
    IsNetScrap,
    LeadTimeOffset,
    QuantityDistributionKey,
    MaterialRevisionLevel,
    MaterialRevisionLevel_2,
    MaterialCompIsVariableSized,
    VariableSizeItemUnit,
    VariableSizeComponentUnit,
    UnitOfMeasureForSize1To3,
   
    FormulaKey,
    StorageLocation,
    ProductionSupplyArea,
    Batch,
    BOMItemDescription,
    BOMItemText2,
    ChangeNumber,
    /* Associations */
    _BaseUnit,
    _EntryUnit,
    _PurchaseOrder,
    _PurchaseOrderItem,
    _ScheduleLine,
    _VariableSize1To3Unit,
    _VariableSizeCompUnit
}

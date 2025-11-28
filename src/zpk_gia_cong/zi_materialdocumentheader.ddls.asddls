@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'I_MaterialDocumentHeader_2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zI_MaterialDocumentHeader as select from I_MaterialDocumentHeader_2
{
    key MaterialDocumentYear,
    key MaterialDocument,
    DocumentDate,
    PostingDate,
    AccountingDocumentType,
    InventoryTransactionType,
    CreatedByUser,
    CreationDate,
    CreationTime,
    MaterialDocumentHeaderText,
    DeliveryDocument,
    ReferenceDocument,
    BillOfLading,
    VersionForPrintingSlip,
    ManualPrintIsTriggered,
    CtrlPostgForExtWhseMgmtSyst,
    Plant,
    StorageLocation,
    IssuingOrReceivingPlant,
    IssuingOrReceivingStorageLoc,
    /* Associations */
    _AccountingDocumentType,
    _DeliveryDocument,
    _InventoryTransactionType,
    _IssuingOrReceivingStorageLoc,
    _MaterialDocumentItem,
    _MaterialDocumentYear,
    _StorageLocation,
    _User
}

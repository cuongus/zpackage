@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'I_MaterialDocumentHeader_2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zI_GOODS_ISSUE_FORM
 as select from I_MaterialDocumentHeader_2 as a
 inner join I_MaterialDocumentItem_2 as b on a.MaterialDocument = b.MaterialDocument //and b.Customer <> ''
       left outer join I_Customer as f
         on b.Customer = f.Customer
{
    key a.MaterialDocumentYear,
    key a.MaterialDocument,
    key b.MaterialDocumentItem,
    a.DocumentDate,
    a.PostingDate,
    a.AccountingDocumentType,
    a.InventoryTransactionType,
    a.CreatedByUser,
    a.CreationDate,
    a.CreationTime,
    a.MaterialDocumentHeaderText,
    a.DeliveryDocument,
    a.ReferenceDocument,
    a.BillOfLading,
    a.VersionForPrintingSlip,
    a.ManualPrintIsTriggered,
    a.CtrlPostgForExtWhseMgmtSyst,
    a.Plant,
    a.StorageLocation,
    a.IssuingOrReceivingPlant,
    a.IssuingOrReceivingStorageLoc,
    
          f.Customer,
      f.CustomerFullName
    /* Associations */
//    _AccountingDocumentType,
//    _DeliveryDocument,
//    _InventoryTransactionType,
//    _IssuingOrReceivingStorageLoc,
//    _MaterialDocumentItem,
//    _MaterialDocumentYear,
//    _StorageLocation,
//    _User
}

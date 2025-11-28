@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'i_materialdocumentitem_2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zc_materialdocumentitem_2
  as select from I_MaterialDocumentItem_2
  association [0..1] to I_MaterialDocumentItem_2 as revert on $projection.MaterialDocumentYear = revert.ReversedMaterialDocumentYear
    and $projection.MaterialDocument  = revert.ReversedMaterialDocument
    and $projection.MaterialDocumentItem  = revert.ReversedMaterialDocumentItem
  association [0..1] to I_Product as _Product on $projection.Material = _Product.Product
  association [0..1] to zc_MaterialDocument_header as _header on $projection.MaterialDocumentYear = _header.MaterialDocumentYear
    and $projection.MaterialDocument = _header.MaterialDocument
{
  key MaterialDocumentYear,
  key MaterialDocument,
  key MaterialDocumentItem,
      Material,
      _Product.ProductGroup,
      Plant,
      StorageLocation,
      StorageType,
      StorageBin,
      Batch,
      ShelfLifeExpirationDate,
      ManufactureDate,
      Supplier,
      SalesOrder,
      SalesOrderItem,
      SalesOrderScheduleLine,
      WBSElementInternalID,
      Customer,
      InventorySpecialStockType,
      InventoryStockType,
      StockOwner,
      GoodsMovementType,
      DebitCreditCode,
      InventoryUsabilityCode,
      @Semantics.quantity.unitOfMeasure: 'Materialbaseunit'
      QuantityInBaseUnit,
      MaterialBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      QuantityInEntryUnit,
      EntryUnit,
      PostingDate,
      DocumentDate,
      ReservationItemRecordType,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      TotalGoodsMvtAmtInCCCrcy,
      CompanyCodeCurrency,
      InventoryValuationType,
      ReservationIsFinallyIssued,
      PurchaseOrder,
      PurchaseOrderItem,
      ProjectNetwork,
      OrderID,
      OrderItem,
      MaintOrderRoutingNumber,
      MaintOrderOperationCounter,
      Reservation,
      ReservationItem,
      DeliveryDocument,
      DeliveryDocumentItem,
      ReversedMaterialDocumentYear,
      ReversedMaterialDocument,
      ReversedMaterialDocumentItem,
      RvslOfGoodsReceiptIsAllowed,
      GoodsRecipientName,
      GoodsMovementReasonCode,
      UnloadingPointName,
      CostCenter,
      GLAccount,
      ServicePerformer,
      PersonWorkAgreement,
      AccountAssignmentCategory,
      WorkItem,
      ServicesRenderedDate,
      IssgOrRcvgMaterial,
      IssuingOrReceivingPlant,
      IssuingOrReceivingStorageLoc,
      IssgOrRcvgBatch,
      IssgOrRcvgSpclStockInd,
      IssuingOrReceivingValType,
      CompanyCode,
      BusinessArea,
      ControllingArea,
      FiscalYearPeriod,
      FiscalYearVariant,
      GoodsMovementRefDocType,
      IsCompletelyDelivered,
      MaterialDocumentItemText,
      IsAutomaticallyCreated,
      SerialNumbersAreCreatedAutomly,
      GoodsReceiptType,
      ConsumptionPosting,
      MultiAcctAssgmtOriglMatlDocItm,
      MultipleAccountAssignmentCode,
      GoodsMovementIsCancelled,
      IssuingOrReceivingStockType,
      ManufacturingOrder,
      ManufacturingOrderItem,
      MaterialDocumentLine,
      MaterialDocumentParentLine,
      SpecialStockIdfgSalesOrder,
      SpecialStockIdfgSalesOrderItem,
      SpecialStockIdfgWBSElement,
      @Semantics.quantity.unitOfMeasure: 'OrderPriceUnit'
      QtyInPurchaseOrderPriceUnit,
      OrderPriceUnit,
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      QuantityInDeliveryQtyUnit,
      DeliveryQuantityUnit,
      ProfitCenter,
      ProductStandardID,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      GdsMvtExtAmtInCoCodeCrcy,
      ReferenceDocumentFiscalYear,
      InvtryMgmtReferenceDocument,
      InvtryMgmtRefDocumentItem,
      EWMWarehouse,
      EWMStorageBin,
      MaterialDocumentPostingType,
      OriginalMaterialDocumentItem,
      YY1_LNhapTra_MMI,
      _header.YY1_BBCongDoan_MMI,
      case
        when YY1_Lnhgiacng_MMI <> ''
            then YY1_Lnhgiacng_MMI
        else YY1_LnhgiacngDelivery_MMI
      end as YY1_LenhGiaCong_MMI

} where revert.MaterialDocument is null

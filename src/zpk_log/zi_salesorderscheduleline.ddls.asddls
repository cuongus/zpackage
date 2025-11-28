@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZI_SALESORDERSCHEDULELINE'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_SALESORDERSCHEDULELINE
  as select from I_SalesOrderScheduleLine
{
  key SalesOrder,
  key SalesOrderItem,
  key ScheduleLine,
      ScheduleLineCategory,
      OrderQuantityUnit,
      OrderToBaseQuantityDnmntr,
      OrderToBaseQuantityNmrtr,
      BaseUnit,
      DeliveryDate,
      IsRequestedDelivSchedLine,
      RequestedDeliveryDate,
      RequestedDeliveryTime,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      ScheduleLineOrderQuantity,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      CorrectedQtyInOrderQtyUnit,
      IsConfirmedDelivSchedLine,
      ConfirmedDeliveryDate,
      ConfirmedDeliveryTime,
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      ConfdOrderQtyByMatlAvailCheck,
      ConfdSchedLineReqdDelivDate,
      ProductAvailabilityDate,
      ProductAvailabilityTime,
      ProductAvailCheckRqmtDate,
      ProdAvailabilityCheckRqmtType,
      ProdAvailyCheckPlanningType,
      ScheduleLineConfirmationStatus,
      OrderSchedulingGroup,
      PlannedOrder,
      OrderID,
      PurchaseRequisition,
      PurchaseRequisitionItem,
      PurchasingOrderType,
      PurchasingDocumentCategory,
      DeliveryCreationDate,
      TransportationPlanningDate,
      TransportationPlanningTime,
      GoodsIssueDate,
      LoadingDate,
      GoodsIssueTime,
      LoadingTime,
      ItemIsDeliveryRelevant,
      DelivBlockReasonForSchedLine,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      OpenReqdDelivQtyInOrdQtyUnit,
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      OpenReqdDelivQtyInBaseUnit,
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      OpenConfdDelivQtyInOrdQtyUnit,
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      OpenConfdDelivQtyInBaseUnit,
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      DeliveredQtyInOrderQtyUnit,
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      DeliveredQuantityInBaseUnit,
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      RequestedRqmtQtyInBaseUnit,
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      ConfirmedRqmtQtyInBaseUnit,
      GoodsMovementType,
       @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      OpenDeliveryNetAmount,
      TransactionCurrency,
      TradeCmplncLegalCtrlChkSts,
      /* Associations */
      _BaseUnit,
      _DelivBlockReasonForSchedLine,
      _GoodsMovementType,
      _ManufacturingOrder,
      _OrderID,
      _OrderQuantityUnit,
      _ProdAvailabilityCheckRqmtType,
      _SalesOrder,
      _SalesOrderItem,
      _ScheduleLineCategory,
      _ScheduleLineConfStatus,
      _TradeCmplncLegalCtrlChkSts,
      _TransactionCurrency
}

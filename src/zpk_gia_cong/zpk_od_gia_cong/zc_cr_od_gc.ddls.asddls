@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Danh sách PO gia công'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_CR_OD_GC
  as select from    I_PurchaseOrderAPI01           as Po
    inner join      I_PurchaseOrderItemAPI01       as PoItem  on  Po.PurchaseOrder                 = PoItem.PurchaseOrder
                                                              and PoItem.PurchaseOrderItemCategory = '3'
    inner join      I_BusinessPartner              as bus     on Po.Supplier = bus.BusinessPartner
    left outer join I_PurOrdAccountAssignmentAPI01 as Pur     on  Po.PurchaseOrder         = Pur.PurchaseOrder
                                                              and PoItem.PurchaseOrderItem = Pur.PurchaseOrderItem
    left outer join I_ProductionOrderItem          as PurItem on Pur.OrderID = PurItem.ProductionOrder
    left outer join I_ProductDescription           as Pdes    on  PurItem.Product = Pdes.Product
                                                              and Pdes.Language   = 'E'
{
      @Search.defaultSearchElement: true
  key Po.PurchaseOrder,
  key PoItem.PurchaseOrderItem,
      PurItem.Product                                                 as Product,
      Pdes.ProductDescription,
      Po.Supplier                                                     as Supplier,
      bus.SearchTerm1                                                 as SupplierName,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      PoItem.OrderQuantity,
      PoItem.PurchaseOrderQuantityUnit,
      Pur.OrderID                                              as OrderID,
      PurItem.SalesOrder,
      PurItem.SalesOrderItem
}
where
  Po.PurchaseOrderType = 'ZPO4'

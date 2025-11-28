@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Danh sách lệnh xuất gia công'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CR_OD_2 as select from ZC_CR_OD_GC as ZC_CR_OD_GC
inner join zI_OutboundDeliveryItem_PO as OutboundDeliveryItem
    on ZC_CR_OD_GC.PurchaseOrder = OutboundDeliveryItem.PurchaseOrder
     and ZC_CR_OD_GC.PurchaseOrderItem = OutboundDeliveryItem.PurchaseOrderItem
inner join I_DeliveryDocument as OutboundDelivery
    on OutboundDeliveryItem.OutboundDelivery = OutboundDelivery.DeliveryDocument
left outer join ztb_crod_2 as crod_2_tb on crod_2_tb.purchaseorder = ZC_CR_OD_GC.PurchaseOrder
    and crod_2_tb.purchaseorderitem = ZC_CR_OD_GC.PurchaseOrderItem and crod_2_tb.outbounddelivery = OutboundDelivery.DeliveryDocument
{
    key ZC_CR_OD_GC.PurchaseOrder,
    key ZC_CR_OD_GC.PurchaseOrderItem,
    key OutboundDeliveryItem.OutboundDelivery,
    ZC_CR_OD_GC.Product,
    ZC_CR_OD_GC.ProductDescription,
    ZC_CR_OD_GC.Supplier,
    ZC_CR_OD_GC.SupplierName,
    crod_2_tb.sldongbo,
    OutboundDelivery.YY1_SLDongBo_DLH,
    OutboundDelivery.PlannedGoodsIssueDate,
    OutboundDelivery.YY1_NgayDuKienThu_DLH,
    OutboundDelivery.OverallGoodsMovementStatus,
    @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
    ZC_CR_OD_GC.OrderQuantity,
    ZC_CR_OD_GC.PurchaseOrderQuantityUnit,
    OutboundDelivery.YY1_ODGoc_DLH
    
    
}

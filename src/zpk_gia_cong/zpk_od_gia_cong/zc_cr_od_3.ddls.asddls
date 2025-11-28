@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Danh sách lệnh xuất gia công'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CR_OD_3 as select from ZC_CR_OD_2 as ZC_CR_OD_2
inner join I_OutboundDeliveryItem as OutboundDeliveryItem
    on ZC_CR_OD_2.OutboundDelivery = OutboundDeliveryItem.OutboundDelivery
 inner join I_ProductDescription           as Pdes    on  OutboundDeliveryItem.Product = Pdes.Product
                                                              and Pdes.Language   = 'E'
 left outer join I_POSubcontractingCompAPI01 on ZC_CR_OD_2.PurchaseOrder = I_POSubcontractingCompAPI01.PurchaseOrder
                                             and ZC_CR_OD_2.PurchaseOrderItem = I_POSubcontractingCompAPI01.PurchaseOrderItem
                                             and I_POSubcontractingCompAPI01.Material = OutboundDeliveryItem.Product
{
    key ZC_CR_OD_2.PurchaseOrder,
    key ZC_CR_OD_2.PurchaseOrderItem,
    key ZC_CR_OD_2.OutboundDelivery,
    key OutboundDeliveryItem.OutboundDeliveryItem,
    ZC_CR_OD_2.YY1_SLDongBo_DLH,
    ZC_CR_OD_2.PlannedGoodsIssueDate,
    ZC_CR_OD_2.YY1_NgayDuKienThu_DLH,
    ZC_CR_OD_2.Supplier,
    ZC_CR_OD_2.SupplierName,
    OutboundDeliveryItem.Product,
    Pdes.ProductDescription,
    OutboundDeliveryItem.DeliveryQuantityUnit,
    @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
    OutboundDeliveryItem.ActualDeliveryQuantity,
    ZC_CR_OD_2.Product as mabtp,
    ZC_CR_OD_2.ProductDescription as tenbtp,
    ZC_CR_OD_2.YY1_ODGoc_DLH,
    @Semantics.quantity.unitOfMeasure: 'BaseUnit'
    cast( I_POSubcontractingCompAPI01.RequiredQuantity / ZC_CR_OD_2.OrderQuantity * ZC_CR_OD_2.sldongbo as menge_d ) as SoLuong,
    OutboundDeliveryItem.BaseUnit,
    ZC_CR_OD_2.OverallGoodsMovementStatus,
    OutboundDeliveryItem.GoodsMovementStatus
    
}

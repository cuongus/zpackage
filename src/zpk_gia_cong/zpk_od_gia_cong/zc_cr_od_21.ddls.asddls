@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Danh sách lệnh xuất gia công'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CR_OD_21 as select from ZC_CR_OD_2 as ZC_CR_OD_2
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
    ZC_CR_OD_2.sldongbo,
    ZC_CR_OD_2.PlannedGoodsIssueDate,
    ZC_CR_OD_2.YY1_NgayDuKienThu_DLH,
    ZC_CR_OD_2.Supplier,
    ZC_CR_OD_2.SupplierName,
    OutboundDeliveryItem.Product,
    Pdes.ProductDescription,
    OutboundDeliveryItem.BaseUnit,
    @Semantics.quantity.unitOfMeasure: 'BaseUnit'
    cast( I_POSubcontractingCompAPI01.RequiredQuantity / ZC_CR_OD_2.OrderQuantity * ZC_CR_OD_2.sldongbo as menge_d ) as SoLuong
    
}

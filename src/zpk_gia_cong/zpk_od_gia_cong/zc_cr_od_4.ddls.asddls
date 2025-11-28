@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Screen 4: Tạo OD bổ sung'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
} 
define view entity ZC_CR_OD_4 as select from ZC_CR_OD_3 as odgoc
inner join ZC_CR_OD_3 as odbs on odbs.YY1_ODGoc_DLH = odgoc.OutboundDelivery 
    and odbs.Product = odgoc.Product
left outer join ZC_CR_OD_slxuat as slxuat on slxuat.YY1_ODGoc_DLH = odgoc.OutboundDelivery
    and slxuat.Product = odgoc.Product
left outer join ZR_TBCROD_HT as ht on 
     ht.Outbounddelivery = odgoc.OutboundDelivery
    and ht.Product = odgoc.Product
{
    key odgoc.PurchaseOrder,
    key odgoc.PurchaseOrderItem,
    key odgoc.OutboundDelivery,
    key odgoc.OutboundDeliveryItem,
    key odbs.OutboundDelivery as OutboundDeliveryBS,
    odgoc.YY1_SLDongBo_DLH,
    odgoc.PlannedGoodsIssueDate,
    odgoc.YY1_NgayDuKienThu_DLH,
    odgoc.Supplier,
    odgoc.SupplierName,
    odgoc.Product,
    odgoc.ProductDescription,
    odgoc.DeliveryQuantityUnit,
    @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
    slxuat.TotalActualDeliveryQuantity as ActualDeliveryQuantity,
    odgoc.mabtp,
    odgoc.tenbtp,
    odgoc.YY1_ODGoc_DLH,
     @Semantics.quantity.unitOfMeasure: 'BaseUnit'
    odgoc.SoLuong,
    odgoc.BaseUnit,
    @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
    cast( 
        case 
            when odgoc.PurchaseOrder = odbs.OutboundDelivery 
                then odgoc.SoLuong - slxuat.TotalActualDeliveryQuantity 
            else 0         
        end 
    as menge_d ) as SoLuongCanBS,
   odgoc.OverallGoodsMovementStatus,
   odgoc.GoodsMovementStatus,
   cast( 
        case 
            when ( slxuat.TotalActualDeliveryQuantity is null or ( odgoc.SoLuong - slxuat.TotalActualDeliveryQuantity > 0 ) ) 
                and ( ht.Hoanthanh is null or ( ht.Hoanthanh = '' ) )
                then '' 
            else 'X'   
        end 
    as zde_checkbox ) as HoanThanh,   
   
   cast( 
        case 
            when odgoc.OverallGoodsMovementStatus = 'A'
                then 'Not yet'
            when ( slxuat.TotalActualDeliveryQuantity is null or ( odgoc.SoLuong - slxuat.TotalActualDeliveryQuantity > 0 ) ) 
                and ( ht.Hoanthanh is null or ( ht.Hoanthanh = '' ) )
                then 'In progess' 
            else 'Complete'   
        end 
    as abap.char(20) ) as Status
}

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Danh sách lệnh xuất gia công'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CR_OD_slxuat as select from I_DeliveryDocument as OutboundDelivery
inner join I_OutboundDeliveryItem as OutboundDeliveryItem
    on OutboundDelivery.DeliveryDocument = OutboundDeliveryItem.OutboundDelivery
{
    key OutboundDelivery.YY1_ODGoc_DLH as YY1_ODGoc_DLH,
    key OutboundDeliveryItem.Product,
    OutboundDeliveryItem.DeliveryQuantityUnit,
    @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
    sum(OutboundDeliveryItem.ActualDeliveryQuantity) as TotalActualDeliveryQuantity
}
where OutboundDelivery.YY1_ODGoc_DLH <> '' and OutboundDeliveryItem.GoodsMovementStatus = 'C'
group by OutboundDelivery.YY1_ODGoc_DLH, OutboundDeliveryItem.Product,OutboundDeliveryItem.DeliveryQuantityUnit

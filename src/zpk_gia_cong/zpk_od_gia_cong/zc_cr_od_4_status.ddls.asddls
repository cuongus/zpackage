@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Screen 4: Tạo OD bổ sung'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
} 
define view entity ZC_CR_OD_4_STATUS as select from ZC_CR_OD_2 as ZC_CR_OD_2
association [0..1] to ZC_CR_OD_4 as a on 
     ZC_CR_OD_2.PurchaseOrder = a.PurchaseOrder and ZC_CR_OD_2.PurchaseOrderItem = a.PurchaseOrderItem and 
     ZC_CR_OD_2.OutboundDelivery = a.OutboundDelivery and a.Status = 'Not yet'
association [0..1] to ZC_CR_OD_4 as b on 
     ZC_CR_OD_2.PurchaseOrder = b.PurchaseOrder and ZC_CR_OD_2.PurchaseOrderItem = b.PurchaseOrderItem and 
     ZC_CR_OD_2.OutboundDelivery = b.OutboundDelivery and b.Status = 'In progess'
association [0..1] to ZC_CR_OD_4 as c on 
     ZC_CR_OD_2.PurchaseOrder = c.PurchaseOrder and ZC_CR_OD_2.PurchaseOrderItem = c.PurchaseOrderItem and 
     ZC_CR_OD_2.OutboundDelivery = c.OutboundDelivery and c.Status = 'Complete'
{
    key ZC_CR_OD_2.PurchaseOrder,
    key ZC_CR_OD_2.PurchaseOrderItem,
    key ZC_CR_OD_2.OutboundDelivery,
   cast( 
        case 
            when ( a.Status is null )
                then '' 
            else 'X'   
        end 
    as zde_checkbox ) as Notyet,   
   cast( 
        case 
            when ( b.Status is null )
                then '' 
            else 'X'   
        end 
    as zde_checkbox ) as Inprogess, 
    cast( 
        case 
            when ( b.Status is null )
                then '' 
            else 'X'   
        end 
    as zde_checkbox ) as Complete
}

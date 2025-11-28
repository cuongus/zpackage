@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'I_OutboundDeliveryItem distinct PO'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zI_OutboundDeliveryItem_PO as select distinct from I_OutboundDeliveryItem
{
    key OutboundDelivery,
    key PurchaseOrder,
    key PurchaseOrderItem
}

@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forZCR_OD_2'
define view entity ZR_ZCR_OD_201TP
  as select from ZC_CR_OD_2 as ZCR_OD_2
  association to parent ZR_ZCR_OD_GC02TP as _ZCR_OD_GC on $projection.PurchaseOrder = _ZCR_OD_GC.PurchaseOrder and $projection.PurchaseOrderItem = _ZCR_OD_GC.PurchaseOrderItem
  composition [0..*] of ZR_ZCR_OD_21TP as _ZCR_OD_21
  composition [0..*] of ZR_ZCR_OD_301TP as _ZCR_OD_3
  composition [0..*] of ZR_ZCR_OD_4TP as _ZCR_OD_4
  association [0..1] to ZC_CR_OD_4_STATUS as status on ZCR_OD_2.PurchaseOrder = status.PurchaseOrder and ZCR_OD_2.PurchaseOrderItem = status.PurchaseOrderItem
                                                         and ZCR_OD_2.OutboundDelivery = status.OutboundDelivery 
{
  key PurchaseOrder as PurchaseOrder,
  key PurchaseOrderItem as PurchaseOrderItem,
  key OutboundDelivery as OutboundDelivery,
  Product as Product,
  ProductDescription as ProductDescription,
  Supplier as Supplier,
  SupplierName as SupplierName,
  sldongbo as sldongbo,
  YY1_SLDongBo_DLH as YY1_SLDongBo_DLH,
  PlannedGoodsIssueDate as PlannedGoodsIssueDate,
  YY1_NgayDuKienThu_DLH as YY1_NgayDuKienThu_DLH,
  OverallGoodsMovementStatus as OverallGoodsMovementStatus,
  @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
  OrderQuantity as OrderQuantity,
  PurchaseOrderQuantityUnit as PurchaseOrderQuantityUnit,
  YY1_ODGoc_DLH as YY1_ODGoc_DLH,
  cast( case
    when status.Notyet <> ''
        then 'Not yet'
    when status.Inprogess <> ''
        then 'In progess'
    when status.Complete <> ''
        then 'Complete'
    else 'Not yet'
  end as abap.char(20) ) as status,
    
  _ZCR_OD_21,
  _ZCR_OD_3,
  _ZCR_OD_GC,
  _ZCR_OD_4
}

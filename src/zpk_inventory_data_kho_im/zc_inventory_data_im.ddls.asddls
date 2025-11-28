@EndUserText.label: 'data definition'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_INVENTORY_DATA_IM'
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_INVENTORY_DATA_IM
  as projection on ZI_INVENTORY_DATA_IM
{
         @Consumption.filter  : { mandatory: true, multipleSelections: true }
  key    Plant,
  key    Pid,
  key    Pid_item,
  key    DocumantYear,
  key    Uuid,
  key    Storagelocation,
  key    Material, // mã hàng
  key    ConvertSapNo,
         Phys_inv_doc, //     chứng từ kiểm kê
         //       @Consumption.filter  : { mandatory: true, multipleSelections: true }



         @Consumption.filter    : {

           selectionType          : #INTERVAL,
           multipleSelections     : false
           }
         DocDate, // ngày chứng từ
         @Consumption.filter    : {

           selectionType          : #INTERVAL,
           multipleSelections     : false
           }
         PdaDate, //ngày quyets kiểm kê
         PiStatus, // trạng thái

         //      IM


         Plantcountdate,
         Countdate,
         MaterialDescription,
         Batch,
         Spestok,
         Spestoknum,
         StockType,
         @Semantics.quantity.unitOfMeasure : 'BookQtyUom'
         BookQty,
         BookQtyUom,
         @Semantics.quantity.unitOfMeasure : 'CountedQtyUom'
         PdaQty,
         @Semantics.quantity.unitOfMeasure : 'CountedQtyUom'
         CountedQty,
         CountedQtyUom,
         @Semantics.quantity.unitOfMeasure : 'EnteredQtyUom'
         EnteredQtyPi,
         EnteredQtyUom,
         ZeroCount,
         @Semantics.quantity.unitOfMeasure : 'BookQtyUom'
         DiffQty,
         ApiStatus,
         ApiMessage,
         PdaTime,
         Counter,
         ApiDate,
         ApiTime,

         UserUpload,
         UploadTime,
         UploadDate,
         UploadStatus,
         UploadMessage,

         Salesorder,
         //       Uuid,
         SalesOrderItem,
         //       SuppliersAccountNumber,
         ActionType,
         edit

}

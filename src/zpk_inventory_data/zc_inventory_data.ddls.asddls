@EndUserText.label: 'Xưbkjfhdksjfk'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_INVENTORY_DATA'
//@ObjectModel.query.implementedBy: 'ABAP:ZBP_I_INVENTORY_DATA_ROOT'
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZC_INVENTORY_DATA
  //  provider contract transactional_query
  as projection on ZI_INVENTORY_DATA_ROOT
{

         //tham số
  key    Pid,
  key    Pid_item,
         @Consumption.filter  : { mandatory: true, multipleSelections: true }
  key    Warehouse_number,
  key    DocumentYear,
  key    LineIndexOfPInvItem,
  key    Uuid,
  key    ConvertSapNo,
   key Stt,
     Material,
 
       StoreType,
         StorageBin,
 

         Plant,
         Storage_location,



         @Consumption.filter    : {

         selectionType          : #INTERVAL,
         multipleSelections     : false
         }
         DocDate,
         @Consumption.filter    : {

         selectionType          : #INTERVAL,
         multipleSelections     : false
         }
         PdaDate,
         PiStatus,
         PhysInvDoc,

         Proce,
         CountDate,
         CountTime,
         MaterialDescription,
         Batch,
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
         Quandemo,
         UserUpload,
         UploadTime,
         UploadDate,
         UploadStatus,
         UploadMessage,

         SpecialStock,
         SpecialStockNumber,
         Salesorder,
         SalesOrderItem,
         ActionType,
         Edit

}

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'data definition'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_INVENTORY_DATA_IM
  as select from ztb_inven_im1

{

  key       plant                as Plant,
  key       pid                  as Pid,
  key       pid_item             as Pid_item,
  key       document_year        as DocumantYear,
  key       uuid                 as Uuid,
  key       storage_location     as Storagelocation,
  key       material             as Material,
  key       convert_sap_no       as ConvertSapNo,
            phys_inv_doc         as Phys_inv_doc,


            doc_date             as DocDate,
            pda_date             as PdaDate,
            pi_status            as PiStatus,


            plant_count_date     as Plantcountdate,
            count_date           as Countdate,
            material_description as MaterialDescription,
            batch                as Batch,
            spe_stok             as Spestok,
            spe_stok_num         as Spestoknum,
            stock_type           as StockType,
            @Semantics.quantity.unitOfMeasure : 'BookQtyUom'
            book_qty             as BookQty,
            book_qty_uom         as BookQtyUom,
            @Semantics.quantity.unitOfMeasure : 'CountedQtyUom'
            pda_qty              as PdaQty,
            @Semantics.quantity.unitOfMeasure : 'CountedQtyUom'
            counted_qty          as CountedQty,
            counted_qty_uom      as CountedQtyUom,
            @Semantics.quantity.unitOfMeasure : 'EnteredQtyUom'
            entered_qty_pi       as EnteredQtyPi,
            entered_qty_uom      as EnteredQtyUom,
            zero_count           as ZeroCount,
            @Semantics.quantity.unitOfMeasure : 'BookQtyUom'
            diff_qty             as DiffQty,
            api_status           as ApiStatus,
            api_message          as ApiMessage,
            pda_time             as PdaTime,
            counter              as Counter,
            api_date             as ApiDate,
            api_time             as ApiTime,

            user_upload          as UserUpload,
            upload_time          as UploadTime,
            upload_date          as UploadDate,
            upload_status        as UploadStatus,
            upload_message       as UploadMessage,

            sales_order          as Salesorder,
            //            uuid                 as Uuid,
            sales_order_item     as SalesOrderItem,
            //            suppliers_acc_num as SuppliersAccountNumber,
            action_type          as ActionType,
            edit                 as edit
}

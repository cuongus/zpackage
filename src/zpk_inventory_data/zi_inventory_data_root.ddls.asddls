@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'data definition'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZI_INVENTORY_DATA_ROOT
  as select from ztb_inventory1
{


  key       pid                  as Pid,
  key       pid_item             as Pid_item,
  key       warehouse_number     as Warehouse_number,
  key       document_year        as DocumentYear,
  key       lineindexofpinvitem  as LineIndexOfPInvItem,
  key       uuid                 as Uuid,
  key       convert_sap_no       as ConvertSapNo,
  key       stt                  as Stt,
            material             as Material,
            store_type           as StoreType,
            storage_bin          as StorageBin,


            plant                as Plant,
            storage_location     as Storage_location,



            doc_date             as DocDate,
            pda_date             as PdaDate,
            pi_status            as PiStatus,
            phys_inv_doc         as PhysInvDoc,

            proce                as Proce,
            count_date           as CountDate,
            count_time           as CountTime,
            material_description as MaterialDescription,
            batch                as Batch,
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

            quan_demo            as Quandemo,

            user_upload          as UserUpload,
            upload_time          as UploadTime,
            upload_date          as UploadDate,
            upload_status        as UploadStatus,
            upload_message       as UploadMessage,

            spe_stok             as SpecialStock,
            spe_stok_num         as SpecialStockNumber,

            sales_order          as Salesorder,
            sales_order_item     as SalesOrderItem,
            edit                 as Edit,
            @Semantics.user.createdBy: true
            created_by           as CreatedBy,
            @Semantics.systemDateTime.createdAt: true
            created_at           as CreatedAt,
            @Semantics.user.localInstanceLastChangedBy: true
            last_changed_by      as LastChangedBy,
            @Semantics.systemDateTime.localInstanceLastChangedAt: true
            last_changed_at      as LastChangedAt,
            action_type          as ActionType
}

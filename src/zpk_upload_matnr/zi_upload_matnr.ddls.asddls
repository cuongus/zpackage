@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'data definition'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_UPLOAD_MATNR
  as select from ztb_upload_matnr

{

  key matnr_doc           as MaterialDocument,
  key option_name as OptionName,
    key matnr_seque_numr as MaterialSequenceNumber ,
  matnr_item          as MaterialDocumentItem,


      doc_date            as DocumentDate,
      post_date           as PostingDate,


      matnr_header_text   as MaterialHeaderText,
      matnr               as Material,


      plant               as Plant,
      storage_location    as StorageLocation,
      batch               as Batch,
      valuation_type      as ValuationType,
      quantity            as Quantity,
      unit                as Unit,
      warehouse_number    as WarehouseNumber,
      store_bin           as StorageBin,
      spe_stok            as SpecialStock,


      cost_center         as CostCenter,
      fixed_asset         as FixedAsset,


      sales_order         as SalesOrder,
      sales_order_item    as SalesOrderItem,
      good_code           as GoodsMovementCode,
      good_type           as GoodsMovementType,
      ctrl_post           as ControlPosting,
      resevation          as Reservation,
      resevation_item     as ReservationItem,


      matnr_doc_item_text as MaterialDocumentItemText
}

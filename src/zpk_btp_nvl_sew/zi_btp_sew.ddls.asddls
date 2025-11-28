@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'data definition'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_BTP_SEW
  as select from ztb_btl_sew
  //composition of target_data_source_name as _association_name
{
  key     uuid              as Uuid,
  key     sales_order       as SalesOrder,
  key     sales_order_item  as SalesOrderItem,
  key     component         as Component,
  key     stt               as Stt,
          material_btp      as MaterialBtp,
          material          as Material,
          material_name     as MaterialName,
          plant             as Plant,
          quantity          as Quantity,
          status            as Status,

          material_btp_name as MaterialBtpName,
          bom_qty           as BomQty,
          required_qty      as RequiredQty,
          uom               as Uom,
          stock_current     as StockCurrent,
          qty_received      as QtyReceived,
          prod_week         as ProdWeek,
          delivery_week     as DeliveryWeek,
          nvl_week          as NvlWeek,
          estimated_qty     as EstimatedQty,
          estimated_date    as EstimatedDate,
          material_type     as MaterialType

          //    _association_name // Make association public
}

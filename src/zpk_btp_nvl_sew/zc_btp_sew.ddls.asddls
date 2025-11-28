@EndUserText.label: 'data definition'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_BTP_SEW'
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_BTP_SEW
  as projection on ZI_BTP_SEW
{
  key  Uuid,
  key  SalesOrder,
  key  SalesOrderItem,
  key  Component,
  key  Stt,
       MaterialBtp, // mã btp sau may
       Material,     //mã thành phẩm
       MaterialName, // tên thành phẩm
       Plant,
       Quantity,     // số lượng trên SO
       Status, // trạng thái

       MaterialBtpName, // tên btp sau may
       BomQty,          // định mức trong bom
       RequiredQty,     // Nhu cầu NVL cần
       Uom,             //đơn vị tính
       StockCurrent, //tồn khi hiện tại
       QtyReceived, // số lượng trả về
       
        @Consumption.valueHelpDefinition:[
      { entity                : { name: 'zc_week', element: 'Weekchar' }
      }]
       ProdWeek, // tuần sản xuất
       DeliveryWeek, // tuần giao hàng
       NvlWeek, // tuần NVL
       EstimatedQty, // số lượng dự kiến hàng
       EstimatedDate, // dự kiến ngày về
       MaterialType   // matnr type


}

@AccessControl.authorizationCheck: #MANDATORY
//@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBCONTAINER'
@EndUserText.label: 'Kế hoạch đóng Container'
define root view entity ZR_TBCONTAINER
  as select from ztb_container
  composition [0..*] of ZR_TBCONTAINER_IT as _dtl
  //  association [0..*] to I_SalesOrderItem  as _SOItems on $projection.SalesOrder = _SOItems.SalesOrder
{
  key uuid              as UUID,
      sales_order       as SalesOrder,
      sales_order_item  as SalesOrderItem,
      counter           as Counter,
      plant             as Plant,
      doc_date          as DocDate,
      product_hierarchy as ProductHierarchy,
      container_week    as ContainerWeek, // tuần đóng con
      container_date    as ContainerDate, // ngày đóng con
      container_number  as ContainerNumber, // số con
      container         as Container,     // số chì
      container_quan    as ContainerQuan, // số lượng đóng con
      note              as Note, // ghi chú
      open_quan         as OpenQuan, // open quantity
      sales_order_quan  as SalesOrderQuan, // sales order quantity
      uom               as Uom,
      week              as Week, //tuần giao hàng
      @Semantics.user.createdBy: true
      created_by        as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at        as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by   as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at   as LastChangedAt,
      _dtl
      //      _SOItems
}

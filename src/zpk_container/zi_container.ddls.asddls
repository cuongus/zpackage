@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'data definition'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_CONTAINER
  as select from ztb_container
{
  key uuid              as Uuid,
  key sales_order       as SalesOrder,
  key sales_order_item  as SalesOrderItem,
  key stt               as Stt,
  key matnr             as Matnr,
      counter           as Counter,

      plant             as Plant,
      doc_date          as Docdate,
      product_hierarchy as ProductHierarchy,
      container_week    as ContainerWeek,
      container_date    as ContainerDate,
      container_number  as ContainerNumber,
      container         as Container,
      container_quan    as ContainerQuan,
      note              as Note,
      open_quan         as OpenQuan, // open quantity
      sales_order_quan  as SalesOrderQuan, // sales order quantity
      uom               as Uom,
      week              as Week,
      created_by        as CreatedBy,
      created_at        as CreatedAt,
      last_changed_by   as LastChangedBy,
      last_changed_at   as LastChangedAt,
      edit              as Edit,
      creat             as Creat


}

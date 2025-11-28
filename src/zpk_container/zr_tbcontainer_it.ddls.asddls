@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBCONTAINER_IT'
@EndUserText.label: 'Kế hoạch đóng Container'
define view entity ZR_TBCONTAINER_IT
  as select from ztb_container_it

  association to parent ZR_TBCONTAINER as _hdr on $projection.UUID = _hdr.UUID
{
  key uuid              as UUID,
  key dtlid             as Dtlid,
      sales_order       as SalesOrder,
      sales_order_item  as SalesOrderItem,
      counter           as Counter,
      plant             as Plant,
      doc_date          as DocDate,
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
      @Semantics.user.createdBy: true
      created_by        as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at        as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by   as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at   as LastChangedAt,
      _hdr
}

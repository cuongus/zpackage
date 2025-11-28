@EndUserText.label: 'data definition'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_CONTAINER'
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_CONTAINER
  as projection on ZI_CONTAINER
{
  key   Uuid,
  key   SalesOrder,
  key   SalesOrderItem,
  key   Stt,
  key   Matnr,
        Counter,


        //      @Consumption.filter  : { mandatory: true, multipleSelections: true }
        Plant,
        //      @Consumption.filter  : { mandatory: true, multipleSelections: true }
        ProductHierarchy,

        @Consumption.filter    : {

              selectionType          : #INTERVAL,
              multipleSelections     : false
              }
        Docdate,
        ContainerWeek,
        ContainerDate,
        ContainerNumber,
        Container,
        ContainerQuan,
        Note,
        SalesOrderQuan,
        Week,
        Uom,
        OpenQuan,
        CreatedBy,
        CreatedAt,
        LastChangedBy,
        LastChangedAt,
        Edit,
        Creat


}

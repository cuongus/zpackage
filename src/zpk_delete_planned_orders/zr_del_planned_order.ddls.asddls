@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'DELETE PLANNED ORDER'
define root view entity ZR_DEL_PLANNED_ORDER
  as select from I_PlannedOrder
{
  key PlannedOrder    as planned_Order,

      SalesOrder      as sale_order,
      MRPController   as mrp_controller,
      ProductionPlant as production_plant,
      Material        as btnDelete
}

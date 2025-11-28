@EndUserText.label: 'Planned order'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_DEL_PLANNED_ORDER 
provider contract transactional_query
as projection on ZR_DEL_PLANNED_ORDER
{
    key planned_Order,
    sale_order,
    mrp_controller,
    production_plant,
    btnDelete
}

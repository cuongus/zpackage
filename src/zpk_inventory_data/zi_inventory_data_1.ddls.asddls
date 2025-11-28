@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'data definition'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_INVENTORY_DATA_1
  as select from I_EWM_PhysInvtryItemRow

{

  key   PhysicalInventoryDocNumber  as Pid,
  key   LineIndexOfPInvItem         as Pid_item,
  key   PhysicalInventoryDocYear    as DocumentYear,
  key   EWMWarehouse                as Warehouse_Number,
  key   PhysicalInventoryItemNumber as PhysicalInventoryItemNumber,

        EWMStorageBin               as StorageBin,
        Batch

}

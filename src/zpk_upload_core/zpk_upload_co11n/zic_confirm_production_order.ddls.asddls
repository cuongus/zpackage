@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Upload Confirmation Production Order'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define view entity ZIC_CONFIRM_PRODUCTION_ORDER
  as projection on ZIU_Confirm_Production_Order
{
  key Uuid,
      Uuidfile,
      
      @ObjectModel.text.element: ['OverallStatusText']
      MessageType,
      
      Criticality,
      
      Message,

      Productionplant,
      Postingdate,
      Manufacturingorder,
      Manufacturingorderoperation,
      Workcenter,
      Optotalconfirmedyieldqty,
      
      Quantity,
      BaseUnit,
      
      Finalconfirmationtype,
      Variancereasoncode,
      Confirmationtext,
      Confirmedexecutionstartdate,
      Confirmedexecutionstarttime,
      Confirmedexecutionenddate,
      Confirmedexecutionendtime,

      MachineID,
      Shift,

      //      @ObjectModel.text.association: '_TSXText'
      @ObjectModel.text.element: [ '_TSXText.TeamName' ]
      TeamID,

      //      @ObjectModel.text.association: '_NhancongTXT'
      @ObjectModel.text.element: [ '_NhancongTXT.WorkerName' ]
      WorkerID,

      ConfirmationUnit,

      OpConfirmedWorkQuantity1,

      OpConfirmedWorkQuantity2,

      OpConfirmedWorkQuantity3,

      OpConfirmedWorkQuantity4,

      OpConfirmedWorkQuantity5,

      OpConfirmedWorkQuantity6,

      OpWorkQuantityUnit1,

      OpWorkQuantityUnit2,

      OpWorkQuantityUnit3,

      OpWorkQuantityUnit4,

      OpWorkQuantityUnit5,

      OpWorkQuantityUnit6,

      @EndUserText.label: 'Status'
      @Semantics.text: true
      _OverallStatus.description as OverallStatusText,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      _OverallStatus,
      _TSXText,
      _NhancongTXT,
      _ManageFile : redirected to parent ZCM_CONFIRM_PRODUCTION_ORDER
}

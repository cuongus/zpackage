@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Upload Confirmation Production Order'
@Metadata.ignorePropagatedAnnotations: true
/*+[hideWarning] { "IDS" as [ "CARDINALITY_CHECK" ]  } */
define view entity ZIU_Confirm_Production_Order
  as select from zdataco11n
  association [0..1] to ZI_MSGT_STA_VH                      as _OverallStatus on $projection.MessageType = _OverallStatus.Status
  association [0..1] to ZI_KB_TSX_TEXT                      as _TSXText       on $projection.TeamID = _TSXText.TeamId
  association [0..1] to ZI_KB_NHANCONG_TEXT                 as _NhancongTXT   on $projection.WorkerID = _NhancongTXT.WorkerId
  association        to parent ZIM_CONFIRM_PRODUCTION_ORDER as _ManageFile    on $projection.Uuidfile = _ManageFile.Uuid
{
  key uuid                        as Uuid,
      uuidfile                    as Uuidfile,

      messagetype                 as MessageType,
      
      case messagetype
      when '' then 0
      when 'E' then 1
      when 'S' then 3
      else 0
      end                         as Criticality,

      message                     as Message,

      productionplant             as Productionplant,
      postingdate                 as Postingdate,
      manufacturingorder          as Manufacturingorder,
      manufacturingorderoperation as Manufacturingorderoperation,
      workcenter                  as Workcenter,
      optotalconfirmedyieldqty    as Optotalconfirmedyieldqty,

      yy1_quantity_cfm            as Quantity,
      yy1_quantity_cfmu           as BaseUnit,

      finalconfirmationtype       as Finalconfirmationtype,
      variancereasoncode          as Variancereasoncode,
      confirmationtext            as Confirmationtext,
      confirmedexecutionstartdate as Confirmedexecutionstartdate,
      confirmedexecutionstarttime as Confirmedexecutionstarttime,
      confirmedexecutionenddate   as Confirmedexecutionenddate,
      confirmedexecutionendtime   as Confirmedexecutionendtime,

      yy1_somay_cfm               as MachineID,

      yy1_casx_cfm                as Shift,

      @ObjectModel.text.association: '_TSXText'
      yy1_tosanxuat_cfm           as TeamID,

      @ObjectModel.text.association: '_NhancongTXT'
      yy1_nhancong_cfm            as WorkerID,

      confirmationunit            as ConfirmationUnit,

      opcfworkqty1                as OpConfirmedWorkQuantity1,

      opcfworkqty2                as OpConfirmedWorkQuantity2,

      opcfworkqty3                as OpConfirmedWorkQuantity3,

      opcfworkqty4                as OpConfirmedWorkQuantity4,

      opcfworkqty5                as OpConfirmedWorkQuantity5,

      opcfworkqty6                as OpConfirmedWorkQuantity6,

      opworkqtyunit1              as OpWorkQuantityUnit1,

      opworkqtyunit2              as OpWorkQuantityUnit2,

      opworkqtyunit3              as OpWorkQuantityUnit3,

      opworkqtyunit4              as OpWorkQuantityUnit4,

      opworkqtyunit5              as OpWorkQuantityUnit5,

      opworkqtyunit6              as OpWorkQuantityUnit6,

      @Semantics.user.createdBy: true
      created_by                  as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at                  as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by             as LastChangedBy,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at       as LocalLastChangedAt,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at             as LastChangedAt,
      //    _association_name // Make association public
      _OverallStatus,
      _TSXText,
      _NhancongTXT,
      _ManageFile
}

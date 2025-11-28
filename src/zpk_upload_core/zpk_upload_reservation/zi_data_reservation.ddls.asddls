@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Views Data Upload Reservation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.sapObjectNodeType.name: 'ZIDTRESERV'
@Metadata.allowExtensions: true
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define view entity ZI_DATA_RESERVATION
  as select from zui_reservation
  association        to parent ZI_MN_RESERVATION as _ManageFile    on $projection.Uuidfile = _ManageFile.Uuid
  association [0..1] to ZI_MSGT_STA_VH           as _OverallStatus on $projection.MessageType = _OverallStatus.Status
{
  key uuid               as Uuid,
      uuidfile           as Uuidfile,
      reservation        as Reservation,

      msgtype            as MessageType,

      case msgtype
      when '' then 0
      when 'E' then 1
      when 'S' then 3
      else 0
      end                as Criticality,

      msgtext            as MessageText,

      documentsequenceno as Documentsequenceno,
      basedate           as Basedate,
      costcenter         as Costcenter,
      goodsmovementtype  as Goodsmovementtype,
      plant              as Plant,
      receivingissuing   as Receivingissuing,
      storagelocation    as Storagelocation,
      materialnumber     as Materialnumber,
      @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
      quantity           as Quantity,
      unitofmeasure      as Unitofmeasure,
      batch              as Batch,
      salesorder         as Salesorder,
      salesorderitem     as Salesorderitem,
      valuationtype      as ValuationType,
      requirementdate    as Requirementdate,
      glaccount          as Glaccount,

      @Semantics.user.createdBy: true
      createdbyuser      as CreatedByUser,
      @Semantics.systemDateTime.createdAt: true
      createddate        as CreatedDate,
      @Semantics.user.lastChangedBy: true
      changedbyuser      as ChangedByUser,
      @Semantics.systemDateTime.lastChangedAt: true
      changeddate        as ChangedDate,
      //    _association_name // Make association public
      _ManageFile,
      _OverallStatus
}

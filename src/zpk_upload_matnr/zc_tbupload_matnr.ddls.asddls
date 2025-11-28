@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Tool Upload MIGO'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBUPLOAD_MATNR'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZC_TBUPLOAD_MATNR
  //  provider contract transactional_query
  as projection on ZR_TBUPLOAD_MATNR
  //  association [1..1] to ZR_TBUPLOAD_MATNR as _BaseEntity on $projection.MATNRSEQUENUMR = _BaseEntity.MATNRSEQUENUMR and $projection.UUID = _BaseEntity.UUID
{
      //    key Client,
  key UUID,
  key Dtlid,
  MatnrSequeNumr,
      OptionName,
      MatnrDoc,
      MatnrItem,
      DocDate,
      PostDate,
      MatnrHeaderText,
      CtrlPost,
      GoodCode,
      Resevation,
      ResevationItem,
      GoodType,
      Matnr,
      Plant,
      StorageLocation,
      Batch,
      ValuationType,
      Quantity,
      @Consumption: {
        valueHelpDefinition: [ {
          entity.element: 'UnitOfMeasure',
          entity.name: 'I_UnitOfMeasureStdVH',
          useForValidation: true
        } ]
      }
      Unit,
      CostCenter,
      FixedAsset,
      SalesOrder,
      SalesOrderItem,
      SpeStok,
      MatnrDocItemText,
      WarehouseNumber,
      StoreBin,
      FormMatnr,
      FormPlant,
      FormSloc,
      FormBatch,
      FormValueType,
      FormSaleOrder,
      FormSaleItem,
      ToMatnr,
      ToPlant,
      ToSloc,
      ToBatch,
      ToValueType,
      ToSaleOrder,
      ToSaleItem,
      Vendor,
      ManuOrder,
      ManuOrderItem,
      ReturnType,
      MachiningOrders,
      @Semantics: {
        user.createdBy: true
      }
      CreatedBy,
      @Semantics: {
        systemDateTime.createdAt: true
      }
      CreatedAt,
      @Semantics: {
        user.localInstanceLastChangedBy: true
      }
      LastChangedBy,
      @Semantics: {
        systemDateTime.localInstanceLastChangedAt: true
      }
      LastChangedAt,
      _hdr : redirected to parent ZC_TBMATNR_HEADER
      //  _BaseEntity
}

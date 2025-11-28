@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Data Definition-Search help for CTTHBBGC'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #XXL,
    dataClass: #MIXED
}

define view entity ZI_CTTHBBGC_SH
  as select distinct from ZR_TBBB_GC
{
  key SoBb,
      OrderID,
      SoPo,
      CompanyCode,
      SalesOrder,
      Material,
      Supplier,
      SupplierName,

      NgayNhapHang,
      NgayNhapKho
}

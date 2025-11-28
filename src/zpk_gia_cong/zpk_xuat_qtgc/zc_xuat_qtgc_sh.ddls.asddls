@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'search help for XUAT QTGC'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_XUAT_QTGC_SH
  as select from ZR_TBDCGC_HDR
{
  key HdrID,
      Zper,
      ngaylapbang
}

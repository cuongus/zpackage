@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CT09'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zc_ct09
  as select from ZR_TBXETDUYET_HDR
    inner join   ZR_TBXETDUYET_DTL on ZR_TBXETDUYET_HDR.HdrID = ZR_TBXETDUYET_DTL.HdrID
{
 // key     ZR_TBXETDUYET_HDR.HdrID,
//  key     ztb_xd_dtl1.material,
  key     ZR_TBXETDUYET_HDR.Bukrs,
  key     ZR_TBXETDUYET_HDR.Zper,
  key     ZR_TBXETDUYET_HDR.lan,
  key     ZR_TBXETDUYET_DTL.Supplier,
          sum( ZR_TBXETDUYET_DTL.Ct23 - ZR_TBXETDUYET_DTL.Ct26 - ZR_TBXETDUYET_DTL.Ct28 - ZR_TBXETDUYET_DTL.Ct29 ) * 3 / 1000 as ct09_trubs
}
group by
 // ZR_TBXETDUYET_HDR.HdrID,
//  ztb_xd_dtl1.material,
  ZR_TBXETDUYET_HDR.Bukrs,
  ZR_TBXETDUYET_HDR.Zper,
  ZR_TBXETDUYET_HDR.lan,
  ZR_TBXETDUYET_DTL.Supplier

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CT09'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CT091
  as select from ztb_tru_bs
    inner join   ztb_tru_bs_dt1 on ztb_tru_bs.hdr_id = ztb_tru_bs_dt1.hdr_id
    inner join   zc_ct09         on  ztb_tru_bs.bukrs        = zc_ct09.Bukrs
                                 and ztb_tru_bs.zper         = zc_ct09.Zper
                                 and ztb_tru_bs.lan          = zc_ct09.lan
//                                 and ztb_tru_bs_dtl.material = zc_ct09.material
                                 and ztb_tru_bs_dt1.supplier = zc_ct09.Supplier
{ 
  key     ztb_tru_bs.hdr_id as HdrID,
  key     ztb_tru_bs_dt1.dtl_id as DtlID,
          cast( zc_ct09.ct09_trubs  as abap.dec(23,0) ) as ct09_trubs,
          cast( 
      case
            when ztb_tru_bs_dt1.ct04 - zc_ct09.ct09_trubs > 0 then ztb_tru_bs_dt1.ct04 - zc_ct09.ct09_trubs
            else 0
        end         as abap.dec(23,0)     )                           as ct05a
} 

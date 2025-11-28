@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBTRU_BS_DTL'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZR_TBTRU_BS_DT1
  as select from ztb_tru_bs_dt1
  association        to parent ZR_TBTRU_BS as _hdr  on  $projection.HdrID = _hdr.HdrID
  association [0..1] to I_BusinessPartner  as _BP   on  $projection.Supplier = _BP.BusinessPartner
  association [0..1] to ZC_CT091           as _ct09 on  $projection.HdrID = _ct09.HdrID
                                                    and $projection.DtlID = _ct09.DtlID
{
  key hdr_id           as HdrID,
  key dtl_id           as DtlID,
      supplier         as Supplier,
      _BP.SearchTerm1  as SupplierName,
      ct04,
      _ct09.ct09_trubs as ct05,
      _ct09.ct05a,      
      ct05b,
      cast( ( _ct09.ct05a + ct05b )  as abap.dec(23,0) ) as ct06, 
      @Semantics.user.createdBy: true
      created_by       as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at       as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by  as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at  as LastChangedAt,
      _hdr
}

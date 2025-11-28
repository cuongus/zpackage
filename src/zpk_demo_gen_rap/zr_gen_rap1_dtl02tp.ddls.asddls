@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forgen_rap1_dtl'
define view entity ZR_gen_rap1_dtl02TP
  as select from ZTB_GEN1_DTL as gen_rap1_dtl
  association to parent ZR_demo_gen102TP as _demo_gen1 on $projection.HdrID = _demo_gen1.HdrID
{
  key DTL_ID as DtlID,
  HDR_ID as HdrID,
  NGAYNHAPHANG as Ngaynhaphang,
  SOBBGC as Sobbgc,
  SOPO as Sopo,
  CT09 as Ct09,
  CT10 as Ct10,
  CT11 as Ct11,
  CT12 as Ct12,
  CT13 as Ct13,
  CT14 as Ct14,
  CT15 as Ct15,
  CT16 as Ct16,
  CT17 as Ct17,
  CT18 as Ct18,
  CT19 as Ct19,
  CT20 as Ct20,
  CT21 as Ct21,
  CT22 as Ct22,
  CT23 as Ct23,
  CT24 as Ct24,
  CT25 as Ct25,
  CT26 as Ct26,
  CT27 as Ct27,
  CT27A as Ct27a,
  CT27B as Ct27b,
  CT28 as Ct28,
  CT29 as Ct29,
  CT30 as Ct30,
  CT31 as Ct31,
  CT32 as Ct32,
  CT33 as Ct33,
  GHICHU as Ghichu,
  CREATED_BY as CreatedBy,
  CREATED_AT as CreatedAt,
  LAST_CHANGED_BY as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  _demo_gen1
}

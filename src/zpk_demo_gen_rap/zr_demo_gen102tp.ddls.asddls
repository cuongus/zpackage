@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View fordemo_gen1'
define root view entity ZR_demo_gen102TP
  as select from ZTB_GEN1_HDR as demo_gen1
  composition [0..*] of ZR_gen_rap1_dtl02TP as _gen_rap1_dtl
{
  key HDR_ID as HdrID,
  ZPER as Zper,
  ZPERDESC as Zperdesc,
  LAN as Lan,
  BUKRS as Bukrs,
  NGAYLAPBANG as Ngaylapbang,
  TRANGTHAI as Trangthai,
  SUPPLIER as Supplier,
  PARTNERFUNC as Partnerfunc,
  SUMDATE as Sumdate,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  SUMDATETIME as Sumdatetime,
  CT01 as Ct01,
  CT011 as Ct011,
  CT02 as Ct02,
  CT021 as Ct021,
  CT03 as Ct03,
  CT031 as Ct031,
  CT03A as Ct03a,
  CT03A1 as Ct03a1,
  CT03B as Ct03b,
  CT03B1 as Ct03b1,
  CT04 as Ct04,
  CT05 as Ct05,
  CT06 as Ct06,
  CT07 as Ct07,
  CT08 as Ct08,
  CT09 as Ct09,
  CT10 as Ct10,
  CT11 as Ct11,
  CT12 as Ct12,
  CT13 as Ct13,
  CTCONGTRUKHAC as Ctcongtrukhac,
  @Semantics.user.createdBy: true
  CREATED_BY as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  CREATED_AT as CreatedAt,
  LAST_CHANGED_BY as LastChangedBy,
  LAST_CHANGED_AT as LastChangedAt,
  _gen_rap1_dtl
}

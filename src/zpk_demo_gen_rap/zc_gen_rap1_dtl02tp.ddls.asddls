@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forgen_rap1_dtl'
@ObjectModel.semanticKey: [ 'DtlID' ]
@Search.searchable: true
define view entity ZC_gen_rap1_dtl02TP
  as projection on ZR_gen_rap1_dtl02TP as gen_rap1_dtl
{
  key DtlID,
  HdrID,
  Ngaynhaphang,
  Sobbgc,
  Sopo,
  Ct09,
  Ct10,
  Ct11,
  Ct12,
  Ct13,
  Ct14,
  Ct15,
  Ct16,
  Ct17,
  Ct18,
  Ct19,
  Ct20,
  Ct21,
  Ct22,
  Ct23,
  Ct24,
  Ct25,
  Ct26,
  Ct27,
  Ct27a,
  Ct27b,
  Ct28,
  Ct29,
  Ct30,
  Ct31,
  Ct32,
  Ct33,
  Ghichu,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  _demo_gen1 : redirected to parent ZC_demo_gen102TP
}

@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View fordemo_gen1'
@ObjectModel.semanticKey: [ 'HdrID' ]
@Search.searchable: true
define root view entity ZC_demo_gen102TP
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_demo_gen102TP as demo_gen1
{
  key HdrID,
  Zper,
  Zperdesc,
  Lan,
  Bukrs,
  Ngaylapbang,
  Trangthai,
  Supplier,
  Partnerfunc,
  Sumdate,
  Sumdatetime,
  Ct01,
  Ct011,
  Ct02,
  Ct021,
  Ct03,
  Ct031,
  Ct03a,
  Ct03a1,
  Ct03b,
  Ct03b1,
  Ct04,
  Ct05,
  Ct06,
  Ct07,
  Ct08,
  Ct09,
  Ct10,
  Ct11,
  Ct12,
  Ct13,
  Ctcongtrukhac,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  _gen_rap1_dtl : redirected to composition child ZC_gen_rap1_dtl02TP
}

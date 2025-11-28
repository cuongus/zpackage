@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View CFID Temp'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_CFID_TEMP
  provider contract transactional_query
  as projection on ZI_CFID_TEMP
{

  key DPostingNumb,
  key PostingNumber,
  key FiscalYear,
  key RowAbs,
      FStatus,
      Text1,
      Text2,
      TransactName,
      Createtionby,
      Createtiondate
}

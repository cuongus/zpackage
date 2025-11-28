@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View CFID Temp'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_CFID_TEMP
  as select from ztb_cfid_temp
  //composition of target_data_source_name as _association_name
{
 
  key    d_posting_numb as DPostingNumb,
  key    posting_number as PostingNumber,
  key    fiscalyear     as FiscalYear,
  key    row_abs        as RowAbs,
         f_status       as FStatus,
         text1          as Text1,
         text2          as Text2,
         transact_name  as TransactName,
         @Semantics.user.createdBy: true
         createtionby   as Createtionby,
         @Semantics.systemDateTime.createdAt: true
         createtiondate as Createtiondate
         //    _association_name // Make association public
}

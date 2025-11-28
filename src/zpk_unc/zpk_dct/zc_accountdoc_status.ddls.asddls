@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'search help for accounting document'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZC_ACCOUNTDOC_STATUS
  as select from    I_JournalEntry           as _Header
{
  key  _Header.AccountingDocument,
  key  _Header.CompanyCode,
  key  _Header.FiscalYear,
  @UI.hidden: true
      cast( _Header.OriginalReferenceDocument as abap.char( 70 ) ) as OriginalReferenceDocument,
  @UI.hidden: true
       _Header.AccountingDocumentCategory as category

}
where
  (
    (
         _Header.AccountingDocumentCategory = 'Z'
      or _Header.AccountingDocumentCategory = 'V'
    )
    and(
         _Header.TransactionCode            = 'FBDC_P001'
      or _Header.TransactionCode            = 'FBDC_P050'
      or _Header.TransactionCode            = 'FBDC_P051'
    )
  )

  or(
    (
         _Header.AccountingDocumentCategory = ''
      or _Header.AccountingDocumentCategory = 'L'
      or _Header.AccountingDocumentCategory = 'U'
    )
    and(
         _Header.TransactionCode            = 'FBVB'
    )
    --and  _Status.WorkItem                   <> '000000000000'
  )

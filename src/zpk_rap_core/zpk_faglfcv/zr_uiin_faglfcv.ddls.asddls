@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZUIIN_FAGLFCV'
@EndUserText.label: '###GENERATED Core Data Service Entity'
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define root view entity ZR_UIIN_FAGLFCV
  as select from zui_in_faglfcv
  association [0..1] to I_OperationalAcctgDocItem as _AcctgDocItem on  $projection.Ccode     = _AcctgDocItem.CompanyCode
                                                                   and $projection.DocNumber = _AcctgDocItem.AccountingDocument
                                                                   and $projection.DocLine   = _AcctgDocItem.AccountingDocumentItem
{
  key ccode                 as Ccode,
  key doc_number            as DocNumber,
  key fiscal_year           as FiscalYear,
  key doc_line              as DocLine,
  key doc_number_cl         as DocNumberCl,
  key fiscal_yearcl         as FiscalYearCl,
  key keydate               as Keydate,
      ledger                as Ledger,
      ledger_group          as LedgerGroup,
      target_ccode          as TargetCcode,
      valuation_group       as ValuationGroup,
      account_type          as AccountType,
      gl_account            as GlAccount,
      group_account         as GroupAccount,
      account               as Account,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_CurrencyStdVH',
        entity.element: 'Currency',
        useForValidation: true
      } ]
      currency              as Currency,
      nr                    as Nr,
      ja                    as Ja,
      buz                   as Buz,
      debcred_ind           as DebcredInd,
      @Semantics.amount.currencyCode: 'Currency'
      source_amount         as SourceAmount,
      @Semantics.amount.currencyCode: 'Currency'
      target_amount         as TargetAmount,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_CurrencyStdVH',
        entity.element: 'Currency',
        useForValidation: true
      } ]
      target_currency       as TargetCurrency,
      @Semantics.amount.currencyCode: 'Currency'
      lc_amount_val         as LcAmountVal,
      @Semantics.amount.currencyCode: 'Currency'
      hedged_amount         as HedgedAmount,
      hedged_rate           as HedgedRate,
      valuation_rate        as ValuationRate,
      valu_xuse_md_fxr      as ValuXuseMdFxr,
      special_gl_ind        as SpecialGlInd,
      orig_rate             as OrigRate,
      doc_type              as DocType,
      doc_header_text       as DocHeaderText,

      posting_date          as PostingDate,
      document_date         as DocumentDate,

      clearing_document     as ClearingDocument,
      @Semantics.amount.currencyCode: 'Currency'
      valu_diff_old         as ValuDiffOld,
      @Semantics.amount.currencyCode: 'Currency'
      valu_diff_new         as ValuDiffNew,
      @Semantics.amount.currencyCode: 'TargetCurrency'
      posting_amount        as PostingAmount,
      @Semantics.amount.currencyCode: 'Currency'
      real_diff             as RealDiff,
      vbund                 as Vbund,
      account_text          as AccountText,
      @Semantics.amount.currencyCode: 'CurrRem2'
      valu_diff_rem2        as ValuDiffRem2,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_CurrencyStdVH',
        entity.element: 'Currency',
        useForValidation: true
      } ]
      curr_rem2             as CurrRem2,
      @Semantics.amount.currencyCode: 'CurrRem3'
      valu_diff_rem3        as ValuDiffRem3,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_CurrencyStdVH',
        entity.element: 'Currency',
        useForValidation: true
      } ]
      curr_rem3             as CurrRem3,
      @Semantics.amount.currencyCode: 'CurrRem4'
      valu_diff_rem4        as ValuDiffRem4,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_CurrencyStdVH',
        entity.element: 'Currency',
        useForValidation: true
      } ]
      curr_rem4             as CurrRem4,
      @Semantics.amount.currencyCode: 'CurrRem5'
      valu_diff_rem5        as ValuDiffRem5,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_CurrencyStdVH',
        entity.element: 'Currency',
        useForValidation: true
      } ]
      curr_rem5             as CurrRem5,
      @Semantics.amount.currencyCode: 'CurrRem6'
      valu_diff_rem6        as ValuDiffRem6,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_CurrencyStdVH',
        entity.element: 'Currency',
        useForValidation: true
      } ]
      curr_rem6             as CurrRem6,
      @Semantics.amount.currencyCode: 'CurrRem7'
      valu_diff_rem7        as ValuDiffRem7,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_CurrencyStdVH',
        entity.element: 'Currency',
        useForValidation: true
      } ]
      curr_rem7             as CurrRem7,
      @Semantics.amount.currencyCode: 'CurrRem8'
      valu_diff_rem8        as ValuDiffRem8,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_CurrencyStdVH',
        entity.element: 'Currency',
        useForValidation: true
      } ]
      curr_rem8             as CurrRem8,
      @Semantics.amount.currencyCode: 'CurrRem9'
      valu_diff_rem9        as ValuDiffRem9,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_CurrencyStdVH',
        entity.element: 'Currency',
        useForValidation: true
      } ]
      curr_rem9             as CurrRem9,
      @Semantics.amount.currencyCode: 'CurrRem10'
      valu_diff_rem10       as ValuDiffRem10,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_CurrencyStdVH',
        entity.element: 'Currency',
        useForValidation: true
      } ]
      curr_rem10            as CurrRem10,
      xloss                 as Xloss,
      custvend_name         as CustvendName,
      hrate                 as Hrate,
      htext                 as Htext,
      maturity              as Maturity,
      maturity_unit         as MaturityUnit,
      int_valurate_c        as IntValurateC,
      accas                 as Accas,
      pprctr                as Pprctr,
      prctr                 as Prctr,
      psegment              as Psegment,
      rbusa                 as Rbusa,
      rfarea                as Rfarea,
      sbusa                 as Sbusa,
      segment               as Segment,
      valobjtype            as Valobjtype,
      valobj_id             as ValobjID,
      valsobj_id            as ValsobjID,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _AcctgDocItem
}

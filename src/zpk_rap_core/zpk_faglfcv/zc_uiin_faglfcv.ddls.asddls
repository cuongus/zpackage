@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZUIIN_FAGLFCV'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_UIIN_FAGLFCV
  provider contract transactional_query
  as projection on ZR_UIIN_FAGLFCV
  association [1..1] to ZR_UIIN_FAGLFCV as _BaseEntity on  $projection.Ccode      = _BaseEntity.Ccode
                                                       and $projection.DocNumber  = _BaseEntity.DocNumber
                                                       and $projection.FiscalYear = _BaseEntity.FiscalYear
                                                       and $projection.DocLine    = _BaseEntity.DocLine
{

           @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
           @Consumption.valueHelpDefinition:[
           { entity             : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
           }]
  key      Ccode,
  key      DocNumber,
  key      FiscalYear,
  key      DocLine,
  key      DocNumberCl,
  key      FiscalYearCl,
  key      Keydate,
           Ledger,
           LedgerGroup,
           TargetCcode,
           ValuationGroup,
           AccountType,
           GlAccount,
           GroupAccount,
           Account,
           @Consumption: {
             valueHelpDefinition: [ {
               entity.element: 'Currency',
               entity.name: 'I_CurrencyStdVH',
               useForValidation: true
             } ]
           }
           Currency,
           Nr,
           Ja,
           Buz,
           _AcctgDocItem.DebitCreditCode as DebcredInd,
           @Semantics: {
             amount.currencyCode: 'Currency'
           }
           SourceAmount,
           @Semantics: {
             amount.currencyCode: 'Currency'
           }
           TargetAmount,
           @Consumption: {
             valueHelpDefinition: [ {
               entity.element: 'Currency',
               entity.name: 'I_CurrencyStdVH',
               useForValidation: true
             } ]
           }
           TargetCurrency,
           @Semantics: {
             amount.currencyCode: 'Currency'
           }
           LcAmountVal,
           @Semantics: {
             amount.currencyCode: 'Currency'
           }
           HedgedAmount,
           HedgedRate,
           ValuationRate,
           ValuXuseMdFxr,
           SpecialGlInd,
           OrigRate,
           DocType,
           DocHeaderText,

           @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
           @Consumption.valueHelpDefinition:[
           { entity             : { name: 'I_CustomerCompanyVH', element: 'Customer' },
           additionalBinding    : [{ localElement: 'Ccode', element: 'CompanyCode' }]
           }]
           _AcctgDocItem.Customer        as Customer,

           @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
           @Consumption.valueHelpDefinition:[
           { entity             : { name: 'I_SupplierCompanyVH', element: 'Supplier' },
           additionalBinding    : [{ localElement: 'Ccode', element: 'CompanyCode' }]
           }]
           _AcctgDocItem.Supplier        as Supplier,

           _AcctgDocItem.PostingDate     as PostingDate,
           _AcctgDocItem.DocumentDate    as DocumentDate,

           ClearingDocument,
           @Semantics: {
             amount.currencyCode: 'Currency'
           }
           ValuDiffOld,
           @Semantics: {
             amount.currencyCode: 'Currency'
           }
           ValuDiffNew,
           @Semantics: {
             amount.currencyCode: 'TargetCurrency'
           }
           PostingAmount,
           @Semantics: {
             amount.currencyCode: 'Currency'
           }
           RealDiff,
           Vbund,
           AccountText,
           @Semantics: {
             amount.currencyCode: 'CurrRem2'
           }
           ValuDiffRem2,
           @Consumption: {
             valueHelpDefinition: [ {
               entity.element: 'Currency',
               entity.name: 'I_CurrencyStdVH',
               useForValidation: true
             } ]
           }
           CurrRem2,
           @Semantics: {
             amount.currencyCode: 'CurrRem3'
           }
           ValuDiffRem3,
           @Consumption: {
             valueHelpDefinition: [ {
               entity.element: 'Currency',
               entity.name: 'I_CurrencyStdVH',
               useForValidation: true
             } ]
           }
           CurrRem3,
           @Semantics: {
             amount.currencyCode: 'CurrRem4'
           }
           ValuDiffRem4,
           @Consumption: {
             valueHelpDefinition: [ {
               entity.element: 'Currency',
               entity.name: 'I_CurrencyStdVH',
               useForValidation: true
             } ]
           }
           CurrRem4,
           @Semantics: {
             amount.currencyCode: 'CurrRem5'
           }
           ValuDiffRem5,
           @Consumption: {
             valueHelpDefinition: [ {
               entity.element: 'Currency',
               entity.name: 'I_CurrencyStdVH',
               useForValidation: true
             } ]
           }
           CurrRem5,
           @Semantics: {
             amount.currencyCode: 'CurrRem6'
           }
           ValuDiffRem6,
           @Consumption: {
             valueHelpDefinition: [ {
               entity.element: 'Currency',
               entity.name: 'I_CurrencyStdVH',
               useForValidation: true
             } ]
           }
           CurrRem6,
           @Semantics: {
             amount.currencyCode: 'CurrRem7'
           }
           ValuDiffRem7,
           @Consumption: {
             valueHelpDefinition: [ {
               entity.element: 'Currency',
               entity.name: 'I_CurrencyStdVH',
               useForValidation: true
             } ]
           }
           CurrRem7,
           @Semantics: {
             amount.currencyCode: 'CurrRem8'
           }
           ValuDiffRem8,
           @Consumption: {
             valueHelpDefinition: [ {
               entity.element: 'Currency',
               entity.name: 'I_CurrencyStdVH',
               useForValidation: true
             } ]
           }
           CurrRem8,
           @Semantics: {
             amount.currencyCode: 'CurrRem9'
           }
           ValuDiffRem9,
           @Consumption: {
             valueHelpDefinition: [ {
               entity.element: 'Currency',
               entity.name: 'I_CurrencyStdVH',
               useForValidation: true
             } ]
           }
           CurrRem9,
           @Semantics: {
             amount.currencyCode: 'CurrRem10'
           }
           ValuDiffRem10,
           @Consumption: {
             valueHelpDefinition: [ {
               entity.element: 'Currency',
               entity.name: 'I_CurrencyStdVH',
               useForValidation: true
             } ]
           }
           CurrRem10,
           Xloss,
           CustvendName,
           Hrate,
           Htext,
           Maturity,
           MaturityUnit,
           IntValurateC,
           Accas,
           Pprctr,
           Prctr,
           Psegment,
           Rbusa,
           Rfarea,
           Sbusa,
           Segment,
           Valobjtype,
           ValobjID,
           ValsobjID,

           @Semantics: {
             user.createdBy: true
           }
           CreatedBy,
           @Semantics: {
             systemDateTime.createdAt: true
           }
           CreatedAt,
           @Semantics: {
             user.localInstanceLastChangedBy: true
           }
           LocalLastChangedBy,
           @Semantics: {
             systemDateTime.localInstanceLastChangedAt: true
           }
           LocalLastChangedAt,
           @Semantics: {
             systemDateTime.lastChangedAt: true
           }
           LastChangedAt,
           _BaseEntity
}

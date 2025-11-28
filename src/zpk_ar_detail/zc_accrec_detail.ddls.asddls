@EndUserText.label: 'GL Account Partner Ledger'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_ACCREC_DETAIL'
@Metadata.allowExtensions: true
define custom entity ZC_ACCREC_DETAIL
{
      @Consumption.filter          : { mandatory: true, multipleSelections: false }
  key CompanyCode                  : bukrs;
      @Consumption.filter          : { mandatory: true, multipleSelections: true }
  key GLAccountNumber              : saknr;
  key BusinessPartner              : text10;
  key ProfitCenter                 : prctr;
      @Consumption.filter          : { mandatory: true, multipleSelections: false }
  key PostingDateFrom              : budat;
      @Consumption.filter          : { mandatory: true, multipleSelections: false }
  key PostingDateTo                : budat;

  key CompanyName                  : abap.char(255);
  key CompanyAddress               : abap.char(255);
      @Consumption.filter          : { mandatory: false, multipleSelections: false }
  key TransactionCurrency          : waers;
  key CompanyCodeCurrency          : waers;

      BusinessPartnerName          : abap.char(255);

      // Opening balances (before period)
      @Semantics.amount.currencyCode:'TransactionCurrency'
      OpeningDebitBalanceTran      : abap.curr(23,2);
      @Semantics.amount.currencyCode:'CompanyCodeCurrency'
      OpeningDebitBalance          : abap.curr(23,2);

      @Semantics.amount.currencyCode:'TransactionCurrency'
      OpeningCreditBalanceTran     : abap.curr(23,2);
      @Semantics.amount.currencyCode:'CompanyCodeCurrency'
      OpeningCreditBalance         : abap.curr(23,2);

      // Period totals
      @Semantics.amount.currencyCode:'TransactionCurrency'
      DebitAmountDuringPeriodTran  : abap.curr(23,2);
      @Semantics.amount.currencyCode:'CompanyCodeCurrency'
      DebitAmountDuringPeriod      : abap.curr(23,2);

      @Semantics.amount.currencyCode:'TransactionCurrency'
      CreditAmountDuringPeriodTran : abap.curr(23,2);
      @Semantics.amount.currencyCode:'CompanyCodeCurrency'
      CreditAmountDuringPeriod     : abap.curr(23,2);

      // Closing debit balance
      @Semantics.amount.currencyCode:'TransactionCurrency'
      ClosingDebitTran             : abap.curr(23,2);
      @Semantics.amount.currencyCode:'CompanyCodeCurrency'
      ClosingDebit                 : abap.curr(23,2);
      // Closing credit balance
      @Semantics.amount.currencyCode:'TransactionCurrency'
      ClosingCreditTran            : abap.curr(23,2);
      @Semantics.amount.currencyCode:'CompanyCodeCurrency'
      ClosingCredit                : abap.curr(23,2);

      // Line items as JSON string (workaround for structure limitation)
      LineItemsJson                : abap.string;
}

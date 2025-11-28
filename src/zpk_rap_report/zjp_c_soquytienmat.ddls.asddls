@EndUserText.label: 'CDS View for Sổ quỹ tiền mặt'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_JP_GET_DATA_REPORT_FI' }
    }
@Metadata.allowExtensions: true
@Search.searchable: true
define root custom entity zjp_c_soquytienmat
  // with parameters parameter_name : parameter_type
{
      @Search.defaultSearchElement : true
      @Consumption.filter          : {
      mandatory                    : true
      }
      @Consumption.valueHelpDefinition:[
      { entity                     : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
      }]
  key CompanyCode                  : bukrs;
  key AccountingDocument           : belnr_d;
  key FiscalYear                   : gjahr;
  key AccountingDocumentItem       : buzei;
      stt                          : int4;
      AccountingDocumentType       : blart;

      @Consumption.filter          : {
      mandatory                    : true,
      selectionType                : #INTERVAL,
      multipleSelections           : false
      }
      PostingDate                  : abap.dats;

      @Consumption.filter          : {
      selectionType                : #INTERVAL,
      multipleSelections           : false
      }
      DocumentDate                 : bldat;


      @Consumption.filter          : {
      mandatory                    : true,
      selectionType                : #SINGLE
      }

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_GLACCOUNTSTDVH', element: 'GLAccount'},
      additionalBinding            : [{ localElement: 'CompanyCode', element: 'CompanyCode' }] }]

      @ObjectModel.text.element    : [ '_I_GLACCOUNTSTDVH._Text' ]
      GLAccount                    : hkont;
      DebitCreditCode              : shkzg;

      CompanyCodeCurrency          : waers;
      TransactionCurrency          : waers;

      @ObjectModel.text.element    : [ 'Doituong' ]
      businesspartner              : abap.char(10);
      Doituong                     : zde_bp_name;

      SoHieuCTThu                  : xblnr;
      SoHieuCTChi                  : xblnr;
      Diengiai                     : abap.char(255);

      OffsettingAccount            : hkont;

      @Semantics                   : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      StartingBalanceInCoCode      : dmbtr;
      @Semantics                   : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      DebitAmountInCoCode          : dmbtr;
      @Semantics                   : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      CreditAmountInCoCode         : dmbtr;

      @Semantics                   : { amount : {currencyCode: 'TransactionCurrency'} }
      StartingBalanceInTrans       : wrbtr;
      @Semantics                   : { amount : {currencyCode: 'TransactionCurrency'} }
      DebitAmountInTrans           : wrbtr;
      @Semantics                   : { amount : {currencyCode: 'TransactionCurrency'} }
      CreditAmountInTrans          : wrbtr;


      @Semantics                   : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      BalanceInCoCode              : dmbtr;
      @Semantics                   : { amount : {currencyCode: 'TransactionCurrency'} }
      BalanceInTrans               : wrbtr;

      IsNegativePosting            : abap.char(1);

      GhiChu                       : abap.char(255);

      CompanyCodeName              : abap.char(500);
      CompanyCodeAddr              : abap.char(500);
      GLAccoutName                 : abap.char(100);
      PeriodText                   : abap.char(100);

      SoCTThu                      : belnr_d;
      SoCTChi                      : belnr_d;

      CreationUser                 : abp_creation_user;
      CreationDate                 : abp_creation_date;
      CreationTime                 : abp_creation_time;

      _CompanyCode                 : association [1..1] to I_CompanyCode on $projection.CompanyCode = _CompanyCode.CompanyCode;

      _I_GLACCOUNTSTDVH            : association [1..1] to I_GLAccountStdVH on  $projection.CompanyCode = _I_GLACCOUNTSTDVH.CompanyCode
                                                                            and $projection.GLAccount   = _I_GLACCOUNTSTDVH.GLAccount;

      // do not use: #DEPRECATED  ; use _JournalEntryItemOneTimeData

      //      _OneTimeAccountBP            : association [0..1] to I_OneTimeAccountBP on  $projection.CompanyCode            = _OneTimeAccountBP.CompanyCode
      //                                                                              and $projection.FiscalYear             = _OneTimeAccountBP.FiscalYear
      //                                                                              and $projection.AccountingDocument     = _OneTimeAccountBP.AccountingDocument
      //                                                                              and $projection.AccountingDocumentItem = _OneTimeAccountBP.AccountingDocumentItem;

      _JournalEntryItemOneTimeData : association [0..1] to I_JournalEntryItemOneTimeData on  $projection.CompanyCode            = _JournalEntryItemOneTimeData.CompanyCode
                                                                                         and $projection.FiscalYear             = _JournalEntryItemOneTimeData.FiscalYear
                                                                                         and $projection.AccountingDocument     = _JournalEntryItemOneTimeData.AccountingDocument
                                                                                         and $projection.AccountingDocumentItem = _JournalEntryItemOneTimeData.AccountingDocumentItem;


}

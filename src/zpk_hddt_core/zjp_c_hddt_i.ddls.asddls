@EndUserText.label: 'Projection CDS for HDDT Items'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_EINVOICE_DATA' }
    }
@Metadata.allowExtensions: true
@Search.searchable: true
define custom entity ZJP_C_HDDT_I
  // with parameters parameter_name : parameter_type
{
      @Search.defaultSearchElement   : true
  key CompanyCode              : bukrs;
  key AccountingDocument       : belnr_d;

  key BillingDocument          : zde_vbeln_vf;

  key FiscalYear               : gjahr;

  key AccountingDocumentItem   : buzei;

  key CurrencyType             : zde_currtype;
  key TypeOfDate               : zde_typeofdate;
  key testrun                  : abap_boolean;
  key EinvoiceType             : zde_einvoicetype;

      AdjustType               : zde_adjusttype;
      AccountingDocumentSource : belnr_d;
      FiscalYearSource         : gjahr;

      Usertype                 : zde_usertype;

      EinvoiceForm             : zde_einvoiceform;
      EinvoiceSerial           : zde_einvoiceserial;

      EinvoiceNumber           : zde_einvoicenumber;

      statussap                : zde_statussap;
      TaxCode                  : zde_taxcode;
      TaxPercentage            : zde_dmbtr;
      ItemEinvoice             : buzei;
      Product                  : matnr;
      Longtext                 : zde_txt255;
      DocumentItemText         : abap.char(500);
      Quantity                 : zde_menge;
      BaseUnit                 : meins;
      UnitofMeasureLongname    : zde_txt25;
      CompanyCodeCurrency      : waers;
      priceInCoCodeCrcy        : zde_dmbtr_5;
      AmountInCoCodeCrcy       : zde_dmbtr;
      VatAmountInCoCodeCrcy    : zde_dmbtr;
      TotalAmountInCoCodeCrcy  : zde_dmbtr;
      TransactionCurrency      : waers;
      priceintransaccrcy       : zde_dmbtr_5;
      AmountInTransacCrcy      : zde_dmbtr;
      VatAmountInTransacCrcy   : zde_dmbtr;
      TotalAmountInTransacCrcy : zde_dmbtr;

      _EInvoicesHeaders        : association to parent ZJP_C_HDDT_H on  $projection.CompanyCode        = _EInvoicesHeaders.CompanyCode

                                                                    and $projection.AccountingDocument = _EInvoicesHeaders.AccountingDocument

                                                                    and $projection.BillingDocument    = _EInvoicesHeaders.BillingDocument

                                                                    and $projection.FiscalYear         = _EInvoicesHeaders.FiscalYear

                                                                    and $projection.CurrencyType       = _EInvoicesHeaders.CurrencyType
                                                                    and $projection.TypeOfDate         = _EInvoicesHeaders.TypeOfDate
                                                                    and $projection.testrun            = _EInvoicesHeaders.testrun
                                                                    and $projection.EinvoiceType       = _EInvoicesHeaders.EinvoiceType;
}

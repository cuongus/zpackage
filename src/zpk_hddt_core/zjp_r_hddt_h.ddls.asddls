@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View for Hóa đơn Status S'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZJP_R_HDDT_H
  as select from zjp_a_hddt_h
{
  key companycode        as CompanyCode,
  key accountingdocument as AccountingDocument,
  key billingdocument    as BillingDocument,
  key fiscalyear         as FiscalYear,
      //      idsys                          as Idsys,
      //      testrun                        as Testrun,
      //      StatusIconUrl                  as StatusIconUrl,

      postingdate        as Postingdate,
      documentdate       as Documentdate,
      suppliertax        as Suppliertax,
      customer           as Customer,
      paymentmethod      as Paymentmethod,
      //      profitcenter                   as Profitcenter,
      //      adjusttype                     as Adjusttype,
      //      accountingdocumentsource       as Accountingdocumentsource,
      //      fiscalyearsource               as Fiscalyearsource,
      //      currencytype                   as Currencytype,
      //      taxcode                        as Taxcode,
      //      companycodecurrency            as Companycodecurrency,
      //      amountincocodecrcy             as Amountincocodecrcy,
      //      vatamountincocodecrcy          as Vatamountincocodecrcy,
      //      totalamountincocodecrcy        as Totalamountincocodecrcy,
      //      transactioncurrency            as Transactioncurrency,
      //      amountintransaccrcy            as Amountintransaccrcy,
      //      vatamountintransaccrcy         as Vatamountintransaccrcy,
      //      totalamountintransaccrcy       as Totalamountintransaccrcy,
      //      usertype                       as Usertype,
      //      typeofdate                     as Typeofdate,
      einvoiceform       as Einvoiceform,
      einvoiceserial     as Einvoiceserial,
      einvoicetype       as Einvoicetype,
      einvoicenumber     as Einvoicenumber,
      //      sid                            as Sid,
      //      einvoicetimecreate             as Einvoicetimecreate,
      //      einvoicedatecreate             as Einvoicedatecreate,
      //      einvoicedatecancel             as Einvoicedatecancel,
      //      link                           as Link,
      //      mscqt                          as Mscqt,
      //      statussap                      as Statussap,
      //      statusinvres                   as Statusinvres,
      //      statuscqtres                   as Statuscqtres,
      //      messagetype                    as Messagetype,
      //      messagetext                    as Messagetext,
      createdbyuser      as Createdbyuser,
      createddate        as Createddate,
      createdtime        as Createdtime
} where statussap = '98' or 
        statussap = '99' or 
        statussap = '10' or 
        statussap = '06' or
        statussap = '07'

@EndUserText.label: 'Projection CDS for HDDT Headers'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_EINVOICE_DATA'
            }
    }
@Metadata.allowExtensions: true
@Search.searchable: true
define root custom entity ZJP_C_HDDT_H
  // with parameters parameter_name : parameter_type
{
      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity                       : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
      }]
      @Consumption.filter            : { mandatory:  true}

  key CompanyCode                    : bukrs;

  key AccountingDocument             : belnr_d;

  key BillingDocument                : zde_vbeln_vf;

      @Search.defaultSearchElement   : true
      @Consumption.filter            : { mandatory:  true }
  key FiscalYear                     : gjahr;

      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity                       : { name : 'ZJP_C_DOMAIN_FIX_VAL' , element: 'low' } ,
      additionalBinding              : [{ element: 'domain_name',
                localConstant        : 'CURRTYPE', usage: #FILTER }]
                , distinctValues     : true
      }]
      @Consumption.filter            : { mandatory: true, defaultValue: '1', selectionType: #SINGLE}
  key CurrencyType                   : zde_currtype;

      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity                       : { name : 'ZJP_C_DOMAIN_FIX_VAL' , element: 'low' } ,
      additionalBinding              : [{ element: 'domain_name',
                localConstant        : 'TYPEOFDATE', usage: #FILTER }]
                , distinctValues     : true
      }]
      @Consumption.filter            : { mandatory:  true, defaultValue: '04', selectionType: #SINGLE}

  key TypeOfDate                     : zde_typeofdate;

      @Search.defaultSearchElement   : true
  key testrun                        : abap_boolean;

      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity                       : { name : 'ZJP_R_HD_SERIAL' , element: 'EinvoiceType' }
      }]
      @Consumption.filter            : { mandatory:  true, selectionType: #SINGLE}
  key EinvoiceType                   : zde_einvoicetype;

      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity                       : { name : 'ZJP_C_DOMAIN_FIX_VAL' , element: 'low' } ,
      additionalBinding              : [{ element: 'domain_name',
                localConstant        : 'USERTYPE', usage: #FILTER }]
                , distinctValues     : true
      }]
      @Consumption.filter            : { selectionType: #SINGLE}
      Usertype                       : zde_usertype;

      UUidFilter                     : abap.char(100);

      AdjustType                     : zde_adjusttype;

      AccountingDocumentSource       : belnr_d;
      FiscalYearSource               : gjahr;

      BillingDocumentType            : fkart;

      EinvoiceForm                   : zde_einvoiceform;
      EinvoiceSerial                 : zde_einvoiceserial;

      EinvoiceNumber                 : zde_einvoicenumber;

      @Search.defaultSearchElement   : true
      //ID System Integration Invoice
      IDSys                          : abap.char(10);

      IconSap                        : abap.char(5);

      @Semantics.imageUrl            : true
      StatusIconUrl                  : abap.char(50);

      @Consumption.filter.hidden     : true
      Criticality                    : abap.int1;

      contractNo                     : abap.char(30);

      AccountingDocumentType         : blart;
      FiscalPeriod                   : monat;
      PostingDate                    : budat;
      DocumentDate                   : bldat;
      AccountingDocumentCreationDate : abp_creation_date;
      AbsoluteExChangeRate           : zde_exchangerate;
      SupplierTax                    : zde_id_number;
      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity                       : { name : 'I_CustomerCompanyVH' , element: 'Customer' } ,
      additionalBinding              : [{ element: 'CompanyCode'}]
                , distinctValues     : true
      }]
      @ObjectModel.text.element      : [ 'CustomerName' ]
      Customer                       : zde_kunnr;
      CustomerName                   : zde_bp_name;

      CustomerAddress                : zde_bp_address;

      IdentificationNumber           : zde_id_number;

      EmailAddress                   : zde_email;
      TelephoneNumber                : zde_telephone;

      PaymentMethod                  : zde_payment;

      ProfitCenter                   : prctr;

      AccountingDocumentHeaderText   : bktxt;

      taxcode                        : zde_taxcode;
      CompanycodeCurrency            : waers;
      AmountInCoCodeCrcy             : zde_dmbtr;
      VatAmountInCoCodeCrcy          : zde_dmbtr;
      TotalAmountInCoCodeCrcy        : zde_dmbtr;
      TransactionCurrency            : waers;
      AmountInTransacCrcy            : zde_dmbtr;
      VatAmountInTransacCrcy         : zde_dmbtr;
      TotalAmountInTransacCrcy       : zde_dmbtr;

      SID                            : zde_sid;
      ZMAPP                          : abap.char(25);
      frdate                         : abap.dats;
      todate                         : abap.dats;

      EinvoiceTimeCreate             : zde_einv_time;
      EinvoiceDateCreate             : zde_einv_date;
      EinvoiceDateCancel             : zde_einv_datecancel;
      Link                           : zde_link;
      MSCQT                          : zde_mscqt;

      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity                       : { name : 'ZJP_C_DOMAIN_FIX_VAL' , element: 'low' } ,
      additionalBinding              : [{ element: 'domain_name',
                localConstant        : 'STATUSSAP', usage: #FILTER }]
                , distinctValues     : true
      }]
      @Consumption.filter            : { selectionType: #SINGLE}
      @ObjectModel.text.element      : [ 'descriptionStatusSap' ]
      StatusSAP                      : zde_statussap;

      descriptionStatusSap           : zde_char100;

      StatusInvRes                   : zde_statusinvres;

      StatusCQTRes                   : zde_statuscqtres;

      xreversed                      : abap_boolean;
      xreversing                     : abap_boolean;

      MessageType                    : zde_messagetype;
      MessageText                    : zde_messagetext;

      invdat                         : abap.char(30);
      reservationcode                : abap.char(100);

      CreatedByUser                  : abp_creation_user;
      CreatedDate                    : abp_creation_date;
      CreatedTime                    : abp_creation_time;

      _EInvoiceItems                 : composition [0..*] of ZJP_C_HDDT_I;

      _CompanyCode                   : association [0..1] to I_CompanyCodeStdVH on _CompanyCode.CompanyCode = $projection.CompanyCode;

      _Customer                      : association [0..1] to I_Customer on _Customer.Customer = $projection.Customer;

      //      _ConfigUsertype                : association [0..1] to ZJP_CFG_USERTYPE on _ConfigUsertype.Value = $projection.Usertype;

      _ConfigTypeOfDate              : association [0..1] to ZJP_CFG_TYPEOFDATE on _ConfigTypeOfDate.Value = $projection.TypeOfDate;

      //      _ConfigStatusINVRES            : association [0..1] to ZJP_CFG_STATUSINV on _ConfigStatusINVRES.Value = $projection.StatusInvRes;
      //
      //      _ConfigStatusCQT               : association [0..1] to ZJP_CFG_STATUSCQT on _ConfigStatusCQT.Value = $projection.StatusCQTRes;

      _ConfigAdjType                 : association [0..1] to ZJP_CFG_ADJTYPE on _ConfigAdjType.Value = $projection.AdjustType;

      _ConfigStatusSAP               : association [0..1] to zjp_cfg_statussap on _ConfigStatusSAP.Value = $projection.StatusSAP;

}

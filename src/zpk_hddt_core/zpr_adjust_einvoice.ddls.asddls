@EndUserText.label: 'Parameter Action Adjust EInvoices'
define abstract entity zpr_adjust_einvoice
  //  with parameters parameter_name : parameter_type
{
  @UI.defaultValue  : #( 'ELEMENT_OF_REFERENCED_ENTITY: CompanyCode')
  @UI.hidden        : true
  CompanyCodeSource : bukrs;
  @Consumption.valueHelpDefinition: [{ entity: {name: 'ZJP_R_HDDT_H' , element: 'AccountingDocument' },
     additionalBinding     : [{ localElement: 'GJAHRSource', element: 'FiscalYear' },
                               { localElement: 'CompanyCodeSource', element: 'CompanyCode' }]
    }]
  @UI.defaultValue  : #( 'ELEMENT_OF_REFERENCED_ENTITY: AccountingDocumentSource')
  @EndUserText.label: 'Adjust Document'
  BELNRSource       : belnr_d;

//  @UI.defaultValue  : #( 'ELEMENT_OF_REFERENCED_ENTITY: FiscalYearSource')
  @EndUserText.label: 'Adjust Fiscal Year'
  GJAHRSource       : gjahr;

  @Consumption.valueHelpDefinition: [
  { entity          : { name : 'ZJP_C_DOMAIN_FIX_VAL' , element: 'low' } ,
  additionalBinding : [{ element: 'domain_name',
                  localConstant: 'ADJUSTTYPE', usage: #FILTER }]
                  , distinctValues: true
  }]
  @Consumption.filter      : { mandatory: true, selectionType: #SINGLE}
  @UI.defaultValue  : #( 'ELEMENT_OF_REFERENCED_ENTITY: ADJUSTTYPE')
  @EndUserText.label: 'Adjust Type'
  ADJtype           : zde_adjusttype;

}

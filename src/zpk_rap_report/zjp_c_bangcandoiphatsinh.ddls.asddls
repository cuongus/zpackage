@EndUserText.label: 'Bảng cân đối số phát sinh'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_JP_GET_DATA_REPORT_FI' }
    }
@Metadata.allowExtensions: true
@Search.searchable: true
define custom entity ZJP_C_BANGCANDOIPHATSINH
  // with parameters parameter_name : parameter_type
{
      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity                       : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
      }]
  key CompanyCode                    : bukrs;
      @Consumption.valueHelpDefinition:[{ entity: { name: 'I_GLACCOUNTSTDVH', element: 'GLAccount'},
              additionalBinding      : [{ localElement: 'CompanyCode', element: 'CompanyCode' }] }]
  key GLAccount                      : hkont;
  key CompanyCodeCurrency            : waers;

      GLAccountName                  : abap.char(150);

      @Consumption.filter            : {
      mandatory                      : true,
      selectionType                  : #SINGLE,
      multipleSelections             : false
      }
      PostingdateFrom                : budat;



      @Consumption.filter            : {
      mandatory                      : true,
      selectionType                  : #SINGLE,
      multipleSelections             : false
      }
      PostingdateTo                  : budat;

      @Consumption.valueHelpDefinition:[
      { entity                       : { name: 'ZR_TBSUB_LEVEL_SH', element: 'Sublevel' }
      }]
      @Consumption.filter            : {
      mandatory                      : false,
      selectionType                  : #SINGLE,
      multipleSelections             : false
      }
      sublevel                       : zde_sub_level;

      //      @DefaultAggregation: #SUM
      @Semantics                     : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      StartingBalanceInCompanyCode   : dmbtr;

      //      @DefaultAggregation: #SUM
      @Semantics                     : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      DebitBalanceofReportingPeriod  : dmbtr;

      //      @DefaultAggregation: #SUM
      @Semantics                     : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      CreditBalanceofReportingPeriod : dmbtr;

      //      @DefaultAggregation: #SUM
      @Semantics                     : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      EndingBalanceInCompanyCode     : dmbtr;

      FinancialStatementItem         : abap.char(10);

      CompanyCodeName                : abap.char(500);
      CompanyCodeAddr                : abap.char(500);
      PeriodText                     : abap.char(100);
}

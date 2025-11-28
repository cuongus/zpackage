@EndUserText.label: 'Ủy nhiệm chi'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_GET_DCT' }
    }

@Metadata.allowExtensions: true


define root custom entity ZC_DCT
  // with parameters parameter_name : parameter_type
{
  key CompanyCode        : bukrs;
  key FiscalYear         : gjahr;
  key AccountingDocument : belnr_d;
      @Consumption.filter: { selectionType: #INTERVAL }
  key PrintDate          : budat;
  key QuyDoi             : abap.char( 50 );
  key TyGia              : abap.char( 50 );
  key PTSTC              : abap_boolean;
  key PTTTM              : abap_boolean;
  key PTTTK              : abap_boolean;
  key STK                : abap.char( 20 );
  key NoiDung            : abap.char( 255 );
      //  currency                  : waers;
      //  @Semantics.amount.currencyCode: 'currency'
      //  amount                : abap.curr( 23, 2 );



}

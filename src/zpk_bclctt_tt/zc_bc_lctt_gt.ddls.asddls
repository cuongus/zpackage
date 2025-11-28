@EndUserText.label: 'Báo cáo lưu chuyển tiền tệ theo phương pháp gián tiếp'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_DATA_BCLCTT_GT' }
    }
@Metadata.allowExtensions: true
define custom entity ZC_BC_LCTT_GT
  // with parameters parameter_name : parameter_type
{ 
 @Consumption.valueHelpDefinition:[
      { entity                       : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
      }]
  key CompanyCode  : bukrs;
  key FiscalYear   : gjahr;
  key per_fr       : abap.numc( 2 );
  key per_to       : abap.numc( 2 );
  key item_id      : zde_item_id;
      CHI_TIEU     : zde_item_desc;
      MA_SO        : zde_item_code;
      THUYET_MINH  : abap.char( 10 );
      Currency     : waers;
//      @Aggregation.default         : #SUM
      @Semantics   : { amount : {currencyCode: 'Currency'} }
      KY_NAY       : dmbtr;

//      @Aggregation.default         : #SUM
      @Semantics   : { amount : {currencyCode: 'Currency'} }
      KY_TRUOC     : dmbtr;

      _CompanyCode : association [1..1] to I_CompanyCode on $projection.CompanyCode = _CompanyCode.CompanyCode;

}

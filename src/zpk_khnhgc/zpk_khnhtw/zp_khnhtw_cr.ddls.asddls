@EndUserText.label: 'Parameter Create PB_KHNHTW'
@Metadata.allowExtensions: true
define abstract entity ZP_KHNHTW_CR
  //  with parameters parameter_name : parameter_type
{
      @Consumption.valueHelpDefinition:[
      { entity    : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
      }]
      @EndUserText.label: 'Company Code'
  key companycode : bukrs;
      // ZR_PBKHNH_StdVH
      @Consumption.valueHelpDefinition:[
      { entity    : { name: 'ZR_PBKHNH_StdVH', element: 'Version' }
      }]
      @EndUserText.label: 'Version'
  key version     : abap.char(50);
      @EndUserText.label: 'Version name'
      versionname : abap.char(100);
      @Search     : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity    : { name: 'ZR_LONGWEEK_StdVH', element: 'Weekchar' }
      }]
      @EndUserText.label: 'Week from'
      weekfrom    : abap.char(7);

      @Search     : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity    : { name: 'ZR_LONGWEEK_StdVH', element: 'Weekchar' }
      }]
      @EndUserText.label: 'Week to'
      weekto      : abap.char(7);

}

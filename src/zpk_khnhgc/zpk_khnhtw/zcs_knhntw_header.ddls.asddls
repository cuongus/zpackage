@EndUserText.label: 'Kế hoạch nhận hàng theo tuần (Header)'
@Metadata.allowExtensions: true
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_GET_KHNHTW'
            }
    }
define root custom entity ZCS_KNHNTW_HEADER
  //  with parameters
  //    parameter_name : parameter_type
{
      @Consumption.valueHelpDefinition:[
      { entity           : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
      }]
  key companycode        : bukrs;
      // ZR_PBKHNH_StdVH
      @Consumption.valueHelpDefinition:[
      { entity           : { name: 'ZR_PBKHNH_StdVH', element: 'Version' }
      }]
  key version            : abap.char(50);
      versionname        : abap.char(100);
      @Search            : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity           : { name: 'ZR_LONGWEEK_StdVH', element: 'Weekchar' }
      }]
      weekfrom           : abap.char(7);

      @Search            : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity           : { name: 'ZR_LONGWEEK_StdVH', element: 'Weekchar' }
      }]
      weekto             : abap.char(7);
      createdby          : abp_creation_user;
      createdat          : abp_creation_tstmpl;
      locallastchangedby : abp_locinst_lastchange_user;
      locallastchangedat : abp_locinst_lastchange_tstmpl;
      lastchangedat      : abp_lastchange_tstmpl;
      _Item              : composition [0..1] of ZCS_KNHNTW_ITEM;
      _Comppanycode      : association [0..1] to I_CompanyCode on $projection.companycode = _Comppanycode.CompanyCode;
}

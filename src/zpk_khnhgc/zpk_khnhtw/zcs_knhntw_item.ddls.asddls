@EndUserText.label: 'Kế hoạch nhận hàng theo tuần (Item)'
@Metadata.allowExtensions: true
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_GET_KHNHTW'
            }
    }
define custom entity ZCS_KNHNTW_ITEM
  //  with parameters
  //    parameter_name : parameter_type
{
      @Consumption.valueHelpDefinition:[
      { entity              : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
      }]
  key companycode           : bukrs;
      // ZR_PBKHNH_StdVH
      @Consumption.valueHelpDefinition:[
      { entity              : { name: 'ZR_PBKHNH_StdVH', element: 'Version' }
      }]
  key version               : abap.char(50);

  key producthierarchy3     : abap.char(50);
  key plant                 : werks_d;
  
      versionname           : abap.char(100);
      @Search               : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity              : { name: 'ZR_LONGWEEK_StdVH', element: 'Weekchar' }
      }]
      weekfrom              : abap.char(7);

      @Search               : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity              : { name: 'ZR_LONGWEEK_StdVH', element: 'Weekchar' }
      }]
      weekto                : abap.char(7);

      producthierarchy3name : abap.char(100);

      plantname             : abap.char(100);

      w1receivingplan       : abap.dec( 15, 0 );
      w1dailyproductivity   : abap.dec( 15, 0 );
      w1Variance            : abap.dec( 15, 0 );

      w2receivingplan       : abap.dec( 15, 0 );
      w2dailyproductivity   : abap.dec( 15, 0 );
      w2Variance            : abap.dec( 15, 0 );

      w3receivingplan       : abap.dec( 15, 0 );
      w3dailyproductivity   : abap.dec( 15, 0 );
      w3Variance            : abap.dec( 15, 0 );

      w4receivingplan       : abap.dec( 15, 0 );
      w4dailyproductivity   : abap.dec( 15, 0 );
      w4Variance            : abap.dec( 15, 0 );

      w5receivingplan       : abap.dec( 15, 0 );
      w5dailyproductivity   : abap.dec( 15, 0 );
      w5Variance            : abap.dec( 15, 0 );

      w6receivingplan       : abap.dec( 15, 0 );
      w6dailyproductivity   : abap.dec( 15, 0 );
      w6Variance            : abap.dec( 15, 0 );

      w7receivingplan       : abap.dec( 15, 0 );
      w7dailyproductivity   : abap.dec( 15, 0 );
      w7Variance            : abap.dec( 15, 0 );

      w8receivingplan       : abap.dec( 15, 0 );
      w8dailyproductivity   : abap.dec( 15, 0 );
      w8Variance            : abap.dec( 15, 0 );

      w9receivingplan       : abap.dec( 15, 0 );
      w9dailyproductivity   : abap.dec( 15, 0 );
      w9Variance            : abap.dec( 15, 0 );

      w10receivingplan      : abap.dec( 15, 0 );
      w10dailyproductivity  : abap.dec( 15, 0 );
      w10Variance           : abap.dec( 15, 0 );

      w11receivingplan      : abap.dec( 15, 0 );
      w11dailyproductivity  : abap.dec( 15, 0 );
      w11Variance           : abap.dec( 15, 0 );

      w12receivingplan      : abap.dec( 15, 0 );
      w12dailyproductivity  : abap.dec( 15, 0 );
      w12Variance           : abap.dec( 15, 0 );

      w13receivingplan      : abap.dec( 15, 0 );
      w13dailyproductivity  : abap.dec( 15, 0 );
      w13Variance           : abap.dec( 15, 0 );

      w14receivingplan      : abap.dec( 15, 0 );
      w14dailyproductivity  : abap.dec( 15, 0 );
      w14Variance           : abap.dec( 15, 0 );

      w15receivingplan      : abap.dec( 15, 0 );
      w15dailyproductivity  : abap.dec( 15, 0 );
      w15Variance           : abap.dec( 15, 0 );

      w16receivingplan      : abap.dec( 15, 0 );
      w16dailyproductivity  : abap.dec( 15, 0 );
      w16Variance           : abap.dec( 15, 0 );

      w17receivingplan      : abap.dec( 15, 0 );
      w17dailyproductivity  : abap.dec( 15, 0 );
      w17Variance           : abap.dec( 15, 0 );

      w18receivingplan      : abap.dec( 15, 0 );
      w18dailyproductivity  : abap.dec( 15, 0 );
      w18Variance           : abap.dec( 15, 0 );

      w19receivingplan      : abap.dec( 15, 0 );
      w19dailyproductivity  : abap.dec( 15, 0 );
      w19Variance           : abap.dec( 15, 0 );

      w20receivingplan      : abap.dec( 15, 0 );
      w20dailyproductivity  : abap.dec( 15, 0 );
      w20Variance           : abap.dec( 15, 0 );

      w21receivingplan      : abap.dec( 15, 0 );
      w21dailyproductivity  : abap.dec( 15, 0 );
      w21Variance           : abap.dec( 15, 0 );

      w22receivingplan      : abap.dec( 15, 0 );
      w22dailyproductivity  : abap.dec( 15, 0 );
      w22Variance           : abap.dec( 15, 0 );

      w23receivingplan      : abap.dec( 15, 0 );
      w23dailyproductivity  : abap.dec( 15, 0 );
      w23Variance           : abap.dec( 15, 0 );

      w24receivingplan      : abap.dec( 15, 0 );
      w24dailyproductivity  : abap.dec( 15, 0 );
      w24Variance           : abap.dec( 15, 0 );

      w25receivingplan      : abap.dec( 15, 0 );
      w25dailyproductivity  : abap.dec( 15, 0 );
      w25Variance           : abap.dec( 15, 0 );

      w26receivingplan      : abap.dec( 15, 0 );
      w26dailyproductivity  : abap.dec( 15, 0 );
      w26Variance           : abap.dec( 15, 0 );

      w27receivingplan      : abap.dec( 15, 0 );
      w27dailyproductivity  : abap.dec( 15, 0 );
      w27Variance           : abap.dec( 15, 0 );

      w28receivingplan      : abap.dec( 15, 0 );
      w28dailyproductivity  : abap.dec( 15, 0 );
      w28Variance           : abap.dec( 15, 0 );

      w29receivingplan      : abap.dec( 15, 0 );
      w29dailyproductivity  : abap.dec( 15, 0 );
      w29Variance           : abap.dec( 15, 0 );

      w30receivingplan      : abap.dec( 15, 0 );
      w30dailyproductivity  : abap.dec( 15, 0 );
      w30Variance           : abap.dec( 15, 0 );

      w31receivingplan      : abap.dec( 15, 0 );
      w31dailyproductivity  : abap.dec( 15, 0 );
      w31Variance           : abap.dec( 15, 0 );

      w32receivingplan      : abap.dec( 15, 0 );
      w32dailyproductivity  : abap.dec( 15, 0 );
      w32Variance           : abap.dec( 15, 0 );

      w33receivingplan      : abap.dec( 15, 0 );
      w33dailyproductivity  : abap.dec( 15, 0 );
      w33Variance           : abap.dec( 15, 0 );

      w34receivingplan      : abap.dec( 15, 0 );
      w34dailyproductivity  : abap.dec( 15, 0 );
      w34Variance           : abap.dec( 15, 0 );

      w35receivingplan      : abap.dec( 15, 0 );
      w35dailyproductivity  : abap.dec( 15, 0 );
      w35Variance           : abap.dec( 15, 0 );

      w36receivingplan      : abap.dec( 15, 0 );
      w36dailyproductivity  : abap.dec( 15, 0 );
      w36Variance           : abap.dec( 15, 0 );

      w37receivingplan      : abap.dec( 15, 0 );
      w37dailyproductivity  : abap.dec( 15, 0 );
      w37Variance           : abap.dec( 15, 0 );

      w38receivingplan      : abap.dec( 15, 0 );
      w38dailyproductivity  : abap.dec( 15, 0 );
      w38Variance           : abap.dec( 15, 0 );

      w39receivingplan      : abap.dec( 15, 0 );
      w39dailyproductivity  : abap.dec( 15, 0 );
      w39Variance           : abap.dec( 15, 0 );

      w40receivingplan      : abap.dec( 15, 0 );
      w40dailyproductivity  : abap.dec( 15, 0 );
      w40Variance           : abap.dec( 15, 0 );

      w41receivingplan      : abap.dec( 15, 0 );
      w41dailyproductivity  : abap.dec( 15, 0 );
      w41Variance           : abap.dec( 15, 0 );

      w42receivingplan      : abap.dec( 15, 0 );
      w42dailyproductivity  : abap.dec( 15, 0 );
      w42Variance           : abap.dec( 15, 0 );

      w43receivingplan      : abap.dec( 15, 0 );
      w43dailyproductivity  : abap.dec( 15, 0 );
      w43Variance           : abap.dec( 15, 0 );

      w44receivingplan      : abap.dec( 15, 0 );
      w44dailyproductivity  : abap.dec( 15, 0 );
      w44Variance           : abap.dec( 15, 0 );

      w45receivingplan      : abap.dec( 15, 0 );
      w45dailyproductivity  : abap.dec( 15, 0 );
      w45Variance           : abap.dec( 15, 0 );

      w46receivingplan      : abap.dec( 15, 0 );
      w46dailyproductivity  : abap.dec( 15, 0 );
      w46Variance           : abap.dec( 15, 0 );

      w47receivingplan      : abap.dec( 15, 0 );
      w47dailyproductivity  : abap.dec( 15, 0 );
      w47Variance           : abap.dec( 15, 0 );

      w48receivingplan      : abap.dec( 15, 0 );
      w48dailyproductivity  : abap.dec( 15, 0 );
      w48Variance           : abap.dec( 15, 0 );

      w49receivingplan      : abap.dec( 15, 0 );
      w49dailyproductivity  : abap.dec( 15, 0 );
      w49Variance           : abap.dec( 15, 0 );

      w50receivingplan      : abap.dec( 15, 0 );
      w50dailyproductivity  : abap.dec( 15, 0 );
      w50Variance           : abap.dec( 15, 0 );

      w51receivingplan      : abap.dec( 15, 0 );
      w51dailyproductivity  : abap.dec( 15, 0 );
      w51Variance           : abap.dec( 15, 0 );

      w52receivingplan      : abap.dec( 15, 0 );
      w52dailyproductivity  : abap.dec( 15, 0 );
      w52Variance           : abap.dec( 15, 0 );

      w53receivingplan      : abap.dec( 15, 0 );
      w53dailyproductivity  : abap.dec( 15, 0 );
      w53Variance           : abap.dec( 15, 0 );

      w54receivingplan      : abap.dec( 15, 0 );
      w54dailyproductivity  : abap.dec( 15, 0 );
      w54Variance           : abap.dec( 15, 0 );

      createdby             : abp_creation_user;
      createdat             : abp_creation_tstmpl;
      locallastchangedby    : abp_locinst_lastchange_user;
      locallastchangedat    : abp_locinst_lastchange_tstmpl;
      lastchangedat         : abp_lastchange_tstmpl;

      _Header               : association to parent ZCS_KNHNTW_HEADER on  $projection.companycode = _Header.companycode
                                                                      and $projection.version     = _Header.version;

}

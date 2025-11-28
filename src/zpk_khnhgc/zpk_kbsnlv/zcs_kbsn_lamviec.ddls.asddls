@EndUserText.label: 'Báo cáo năng suất tuần'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_KBSN_NS_TUAN'
            }
    }
@Metadata.allowExtensions: true
@Search.searchable: true
define custom entity ZCS_KBSN_LAMVIEC
  // with parameters parameter_name : parameter_type
{
      @Search              : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity             : { name: 'ZC_WorkCenter', element: 'WorkCenter' },
      additionalBinding    : [{ localElement: 'plant', element: 'Plant' }]
      }]
  key workcenter           : arbpl;

      @Search              : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity             : { name: 'ZC_HierNodeStdVH', element: 'HierarchyNode' }
      }]
  key hierarchynode        : abap.char(50);

      @Search              : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Consumption.valueHelpDefinition:[
      { entity             : { name: 'I_PlantStdVH', element: 'Plant' }
      }]
  key plant                : werks_d;

      @Consumption.filter  : {
      mandatory            : true,
      selectionType        : #INTERVAL,
      multipleSelections   : false
      }
  key week                 : abap.char(2);

      @Consumption.filter  : {
      mandatory            : true,
      selectionType        : #INTERVAL,
      multipleSelections   : false
      }
  key Zyear                : gjahr;
      w1workingdays        : abap.numc(3);
      w1dailyproductivity  : abap.dec(15,0);
      w2workingdays        : abap.numc(3);
      w2dailyproductivity  : abap.dec(15,0);
      w3workingdays        : abap.numc(3);
      w3dailyproductivity  : abap.dec(15,0);
      w4workingdays        : abap.numc(3);
      w4dailyproductivity  : abap.dec(15,0);
      w5workingdays        : abap.numc(3);
      w5dailyproductivity  : abap.dec(15,0);
      w6workingdays        : abap.numc(3);
      w6dailyproductivity  : abap.dec(15,0);
      w7workingdays        : abap.numc(3);
      w7dailyproductivity  : abap.dec(15,0);
      w8workingdays        : abap.numc(3);
      w8dailyproductivity  : abap.dec(15,0);
      w9workingdays        : abap.numc(3);
      w9dailyproductivity  : abap.dec(15,0);
      w10workingdays       : abap.numc(3);
      w10dailyproductivity : abap.dec(15,0);
      w11workingdays       : abap.numc(3);
      w11dailyproductivity : abap.dec(15,0);
      w12workingdays       : abap.numc(3);
      w12dailyproductivity : abap.dec(15,0);
      w13workingdays       : abap.numc(3);
      w13dailyproductivity : abap.dec(15,0);
      w14workingdays       : abap.numc(3);
      w14dailyproductivity : abap.dec(15,0);
      w15workingdays       : abap.numc(3);
      w15dailyproductivity : abap.dec(15,0);
      w16workingdays       : abap.numc(3);
      w16dailyproductivity : abap.dec(15,0);
      w17workingdays       : abap.numc(3);
      w17dailyproductivity : abap.dec(15,0);
      w18workingdays       : abap.numc(3);
      w18dailyproductivity : abap.dec(15,0);
      w19workingdays       : abap.numc(3);
      w19dailyproductivity : abap.dec(15,0);
      w20workingdays       : abap.numc(3);
      w20dailyproductivity : abap.dec(15,0);
      w21workingdays       : abap.numc(3);
      w21dailyproductivity : abap.dec(15,0);
      w22workingdays       : abap.numc(3);
      w22dailyproductivity : abap.dec(15,0);
      w23workingdays       : abap.numc(3);
      w23dailyproductivity : abap.dec(15,0);
      w24workingdays       : abap.numc(3);
      w24dailyproductivity : abap.dec(15,0);
      w25workingdays       : abap.numc(3);
      w25dailyproductivity : abap.dec(15,0);
      w26workingdays       : abap.numc(3);
      w26dailyproductivity : abap.dec(15,0);
      w27workingdays       : abap.numc(3);
      w27dailyproductivity : abap.dec(15,0);
      w28workingdays       : abap.numc(3);
      w28dailyproductivity : abap.dec(15,0);
      w29workingdays       : abap.numc(3);
      w29dailyproductivity : abap.dec(15,0);
      w30workingdays       : abap.numc(3);
      w30dailyproductivity : abap.dec(15,0);
      w31workingdays       : abap.numc(3);
      w31dailyproductivity : abap.dec(15,0);
      w32workingdays       : abap.numc(3);
      w32dailyproductivity : abap.dec(15,0);
      w33workingdays       : abap.numc(3);
      w33dailyproductivity : abap.dec(15,0);
      w34workingdays       : abap.numc(3);
      w34dailyproductivity : abap.dec(15,0);
      w35workingdays       : abap.numc(3);
      w35dailyproductivity : abap.dec(15,0);
      w36workingdays       : abap.numc(3);
      w36dailyproductivity : abap.dec(15,0);
      w37workingdays       : abap.numc(3);
      w37dailyproductivity : abap.dec(15,0);
      w38workingdays       : abap.numc(3);
      w38dailyproductivity : abap.dec(15,0);
      w39workingdays       : abap.numc(3);
      w39dailyproductivity : abap.dec(15,0);
      w40workingdays       : abap.numc(3);
      w40dailyproductivity : abap.dec(15,0);
      w41workingdays       : abap.numc(3);
      w41dailyproductivity : abap.dec(15,0);
      w42workingdays       : abap.numc(3);
      w42dailyproductivity : abap.dec(15,0);
      w43workingdays       : abap.numc(3);
      w43dailyproductivity : abap.dec(15,0);
      w44workingdays       : abap.numc(3);
      w44dailyproductivity : abap.dec(15,0);
      w45workingdays       : abap.numc(3);
      w45dailyproductivity : abap.dec(15,0);
      w46workingdays       : abap.numc(3);
      w46dailyproductivity : abap.dec(15,0);
      w47workingdays       : abap.numc(3);
      w47dailyproductivity : abap.dec(15,0);
      w48workingdays       : abap.numc(3);
      w48dailyproductivity : abap.dec(15,0);
      w49workingdays       : abap.numc(3);
      w49dailyproductivity : abap.dec(15,0);
      w50workingdays       : abap.numc(3);
      w50dailyproductivity : abap.dec(15,0);
      w51workingdays       : abap.numc(3);
      w51dailyproductivity : abap.dec(15,0);
      w52workingdays       : abap.numc(3);
      w52dailyproductivity : abap.dec(15,0);
      w53workingdays       : abap.numc(3);
      w53dailyproductivity : abap.dec(15,0);
      w54workingdays       : abap.numc(3);
      w54dailyproductivity : abap.dec(15,0);

}

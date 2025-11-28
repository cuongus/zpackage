@EndUserText.label: 'Value Help Khai báo Tổ sản xuất'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XXS
@ObjectModel.query.implementedBy: 'ABAP:ZCL_TO_DOI_SX'

@Search.searchable: true
define custom entity ZC_TO_DOI_CF
  // with parameters parameter_name : parameter_type
{
      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
  key WorkCenter : arbpl;
      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
  key Plant      : werks_d;
      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
//     @ObjectModel.text.element: [ 'TeamName' ]
  key TeamId     : abap.char(10);

//      @Semantics.text: true
      TeamName   : abap.char(100);

}

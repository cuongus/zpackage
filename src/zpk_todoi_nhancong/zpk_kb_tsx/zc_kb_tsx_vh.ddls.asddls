@EndUserText.label: 'Value Help Khai báo Tổ sản xuất'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.query.implementedBy: 'ABAP:ZCL_KB_TDNC_VH'

@Search.searchable: true
define custom entity ZC_KB_TSX_VH
  // with parameters parameter_name : parameter_type
{
      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
  key WorkCenter : arbpl;
  
      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @ObjectModel.text.element: [ 'TeamName' ]      
  key TeamId     : abap.char(50);
  
      @Semantics.text: true
      TeamName   : abap.char(255);

}

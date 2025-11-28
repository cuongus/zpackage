@EndUserText.label: 'Value Help Khai báo danh sách nhân công'

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.query.implementedBy: 'ABAP:ZCL_KB_TDNC_VH'

@Search.searchable: true
define custom entity ZC_KB_NHANCONG_VH
  // with parameters parameter_name : parameter_type
{
      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @ObjectModel.text.element: [ 'WorkerName' ]
  key WorkerId   : abap.char(50);
  
      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      WorkCenter : arbpl;
      
      @Semantics.text: true
      WorkerName : abap.char(255);

}

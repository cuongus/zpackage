@EndUserText.label: 'Value Help Khai báo danh sách Số máy'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.query.implementedBy: 'ABAP:ZCL_KB_TDNC_VH'

@Search.searchable: true
define custom entity ZC_KB_SOMAY_VH
  // with parameters parameter_name : parameter_type
{

      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
  key MachineId  : abap.char(50);
  
      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      Workcenter : arbpl;

}

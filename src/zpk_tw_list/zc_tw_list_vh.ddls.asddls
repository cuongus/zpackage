@EndUserText.label: 'Tổ đội, nhân công VH'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.query.implementedBy: 'ABAP:ZCL_TW_LIST_VH'
@Search.searchable: true

define custom entity ZC_TW_LIST_VH
  // with parameters parameter_name : parameter_type
{
      //  key UuID       : sysuuid_x16;
      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @EndUserText.label: 'Mã Nhân Công'
      @ObjectModel.text.element: [ 'WorkerName' ]
  key WorkerId   : abap.char(8);
  
      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @EndUserText.label: 'Ca Làm Việc'
  key Shift      : abap.char(1);
  
      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @EndUserText.label: 'Mã Số Máy'
  key MachineId  : abap.char(10);
  
      @Search    : { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @ObjectModel.text.element: [ 'TeamName' ]
      @EndUserText.label: 'Mã Tổ'
  key TeamId     : abap.char(255);
  
      @EndUserText.label: 'Tổ Sản Xuất'
      TeamName   : abap.char(255);
      
      @EndUserText.label: 'Tên Nhân Công'
      WorkerName : abap.char(255);
      
      @EndUserText.label: 'Work Center'
      WorkCenter : arbpl;
      
      Plant      : werks_d;
      
      @EndUserText.label: 'Từ Ngày'
      FromDate   : datum;
      
      @EndUserText.label: 'Đến Ngày'
      ToDate     : datum;
}

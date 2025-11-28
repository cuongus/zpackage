@EndUserText.label: 'Penalty price'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_PENALTY_PRICE_1
  as projection on ZI_PENALTY_PRICE_1
{
  key LineId,

      @Search.defaultSearchElement: true
      ErrorCode, // Mã lỗi
      @Search.defaultSearchElement: true
      ErrorType,    // loại lỗi
      PenaltyPrice, // đơn giá phạt
      ValidFrom,    // từ ngày
      ValidTo // tới ngày
    
}

@EndUserText.label: 'Error Rate Report'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true

@UI.presentationVariant: [ {
  sortOrder: [{ by: 'ErrorCode', direction: #ASC }]  
} ] 

define root view entity ZC_ERROR_RATE_RP
  provider contract transactional_query
  as projection on ZI_ERROR_RATE_RP as C_errorRateReport
{

  key UuID, // Mã dòng

      @Search.defaultSearchElement: true
      ErrorCode,        // Mã lỗi
      @Search.defaultSearchElement: true
      ErrorDescription, // Diễn giải mã lỗi
      ErrorRateFrom,    // Tỷ lệ lỗi (%) trở lên
      DeductionPercent, // Tỷ lệ quy đổi trừ tiền (%)
      ValidFrom,        // Từ ngày
      ValidTo,          // Tới ngày
      
      LastChangedAt,
      LocalLastChangedAt

}

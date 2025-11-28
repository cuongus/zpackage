@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Error Rate RP View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ERROR_RATE_RP
  as select from ztb_error_rate as I_errorRateReport
{

  key uuid                  as UuID,

      error_code            as ErrorCode,
      error_description     as ErrorDescription,
      error_rate_from       as ErrorRateFrom,
      deduction_percent     as DeductionPercent,
      valid_from            as ValidFrom,
      valid_to              as ValidTo,
      
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt

}

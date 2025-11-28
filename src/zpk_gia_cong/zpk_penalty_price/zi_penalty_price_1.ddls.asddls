@EndUserText.label: 'PENALTY_PRICE - Interface'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_PENALTY_PRICE_1
  as select from ztb_penalty_1 

{	

  key line_id               as LineId,
      error_code            as ErrorCode,
      error_type            as ErrorType,
      penalty_price         as PenaltyPrice,
      valid_from            as ValidFrom,
      valid_to              as ValidTo

}

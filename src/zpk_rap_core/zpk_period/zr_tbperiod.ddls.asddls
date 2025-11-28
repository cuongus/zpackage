@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBPERIOD'
@EndUserText.label: 'Period Detail Entity'
define view entity ZR_TBPERIOD
  as select from ztb_period
   association        to parent ZR_TBYEAR as _hdr on  $projection.Zyear = _hdr.Zyear
{
  key zyear                          as Zyear,
  key zper                           as Zper,
      zdesc                          as Zdesc,
      zmonth                          as zmonth,
      zdatefr                          as zdatefr,
      zdateto                          as zdateto,
      lastper as LastPer,
      @Semantics.user.createdBy: true
      created_by                     as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                     as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by                as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at                as LastChangedAt,

      _hdr
}

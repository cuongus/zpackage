@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for offset'
define root view entity zc_firud_cf_off
  as select from zfirud_cf_off
{
  key rldnr     as rldnr,
  key bukrs     as bukrs,
  key gjahr     as gjahr,
  key belnr     as belnr,
  key docln     as docln,
  key offs_item as offs_item,
      racct     as racct,
      blart     as blart,
      budat     as budat,
      hsl       as hsl,
      rhcur     as rhcur
}

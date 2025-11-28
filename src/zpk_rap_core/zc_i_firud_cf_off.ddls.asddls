@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view firud_cf_off'
@Metadata.allowExtensions: true
define root view entity ZC_i_firud_cf_off 
provider contract transactional_query
as projection on zc_firud_cf_off
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

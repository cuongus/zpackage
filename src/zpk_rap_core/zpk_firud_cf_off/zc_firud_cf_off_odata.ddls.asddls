@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View for ZFIRUD_CF_OFF'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZC_FIRUD_CF_OFF_ODATA
  provider contract transactional_query
  as projection on ZI_FIRUD_CF_OFF_ODATA
{
  key Rldnr,
  key Bukrs,
  key Gjahr,
  key Belnr,
  key Docln,
  key OffsItem,
      Drcrk,
      Racct,
      Lokkt,
      Ktop2,
      Blart,
      Budat,
      Rmvct,
      Mwskz,
      Rfarea,
      Buzei,
      @Semantics.amount.currencyCode: 'Rhcur'
      Hsl,
      Rhcur,
      @Semantics.amount.currencyCode: 'Rkcur'
      Ksl,
      Rkcur
}

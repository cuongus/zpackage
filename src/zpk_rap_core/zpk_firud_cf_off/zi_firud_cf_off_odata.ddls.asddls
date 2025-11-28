@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View for ZFIRUD_CF_OFF'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_FIRUD_CF_OFF_ODATA
  as select from zfirud_cf_off
  //  composition of target_data_source_name as _association_name
{
  key rldnr     as Rldnr,
  key bukrs     as Bukrs,
  key gjahr     as Gjahr,
  key belnr     as Belnr,
  key docln     as Docln,
  key offs_item as OffsItem,
      drcrk     as Drcrk,
      racct     as Racct,
      lokkt     as Lokkt,
      ktop2     as Ktop2,
      blart     as Blart,
      budat     as Budat,
      rmvct     as Rmvct,
      mwskz     as Mwskz,
      rfarea    as Rfarea,
      buzei     as Buzei,
      @Semantics.amount.currencyCode: 'Rhcur'
      hsl       as Hsl,
      rhcur     as Rhcur,
      @Semantics.amount.currencyCode: 'Rkcur'
      ksl       as Ksl,
      rkcur     as Rkcur
      //    _association_name // Make association public
}

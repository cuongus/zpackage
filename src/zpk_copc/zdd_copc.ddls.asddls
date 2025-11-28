@EndUserText.label: 'Luu chuyen tien te gian tiep'

@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_GET_DATA_CCS' }
    }

@Metadata.allowExtensions: true
define custom entity ZDD_COPC
  // with parameters parameter_name : parameter_type
{
  key bukrs             : bukrs;
  key werks             : werks_d;
  key gjahr             : gjahr;
  key period            : abap.dec(3,0);
  key matnr             : matnr;
  key vbeln             : vbeln;
  key posnr             : posnr;
      matkx             : maktx;
      CostComponent     : numc3;
      CostComponentName : char20;
      @Semantics.amount.currencyCode :'Currency'
      @Consumption.filter.hidden     : true
      StandardPrice     : dmbtr;
      @Semantics.amount.currencyCode :'Currency'
      @Consumption.filter.hidden     : true
      actualprice       : dmbtr;
      @Semantics.amount.currencyCode :'Currency'
      @Consumption.filter.hidden     : true
      variant           : dmbtr;
      currency          : waers;

}

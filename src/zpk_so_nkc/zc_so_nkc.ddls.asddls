@EndUserText.label: 'So chi tiet tai khoan'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_GET_DATA_SNKC' }
    }

@Metadata.allowExtensions: true



define custom entity ZC_SO_NKC
  // with parameters parameter_name : parameter_type
{
  key bukrs   : bukrs;
  key racct   : hkont;
  key belnr   : belnr_d;
      @Consumption.filter     : { hidden: true }
  key gjahr   : gjahr;
  key znum    : abap.int4;
      @Consumption.filter     : { hidden: true }
  key ccName  : abap.char( 50 );
      @Consumption.filter     : { hidden: true }
  key ccAdrr  : abap.char( 255 );
      @Consumption.filter     : { hidden: true }
  key mst     : abap.char( 50 );
      @Consumption.filter     : { hidden: true }
      kunnr   : kunnr;
      @Consumption.filter     : { hidden: true }
      bpName  : abap.char( 255 );
      @Consumption.filter: { selectionType: #INTERVAL }
      date_ts : budat;

      @Consumption.filter     : { hidden: true }
      budat   : budat;


      blart   : blart;
      @UI.hidden: true
      @Consumption.filter     : { hidden: true }
      bldat   : bldat;
      @Consumption.filter     : { hidden: true }
      hkont   : hkont;
      @Semantics.amount.currencyCode: 'waers'
      @Consumption.filter     : { hidden: true }
      PsNo    : dmbtr;
      @Semantics.amount.currencyCode: 'waers'
      @Consumption.filter     : { hidden: true }
      PsCo    : dmbtr;
      @Consumption.filter     : { hidden: true }
      sgtxt   : abap.char(50);

      @Semantics.amount.currencyCode: 'waers'
      @Consumption.filter     : { hidden: true }
      dmbtr   : dmbtr;
      @Consumption.filter     : { hidden: true }
      waers   : waers;
      @Consumption.filter     : { hidden: true }
      shkzg   : shkzg;


}

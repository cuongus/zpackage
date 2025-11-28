@EndUserText.label: 'So chi tiet tai khoan'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_GET_DATA_SCTTK' }
    }

@Metadata.allowExtensions: true

@UI.presentationVariant: [
  {
    maxItems : 10000,
    visualizations: [{type: #AS_LINEITEM }]
  }
]

define custom entity ZCE_JP_DD_SCTTK
// with parameters parameter_name : parameter_type
{
  key bukrs             : bukrs;
  key racct             : hkont;
  @Consumption.filter: { selectionType: #INTERVAL }
  key date_ts           : budat;
  key gjahr             : gjahr;
  key budat             : budat;
  key belnr             : belnr_d;
  key buzei             : buzei; 
  @Semantics.amount.currencyCode: 'waers'
  key DuNo              : dmbtr;
  @Semantics.amount.currencyCode: 'waers'
  key DuCo              : dmbtr; 
  key ccName            : abap.char( 50 );
  key ccAdrr            : abap.char( 255 );
//      blart             : blart;
//      bldat             : bldat;
      hkont             : hkont;
      @Semantics.amount.currencyCode: 'waers'
      SoDK              : dmbtr;
      @Semantics.amount.currencyCode: 'waers'
      PsNo              : dmbtr;
      @Semantics.amount.currencyCode: 'waers'
      PsCo              : dmbtr;
      @Semantics.amount.currencyCode: 'waers'
      SoCK              : dmbtr;
      @Semantics.amount.currencyCode: 'waers'
      dmbtr             : dmbtr;
      waers             : waers;
      shkzg             : shkzg;
      xnegp             : abap.char(1);
      sgtxt             : abap.char(50);
      tenNL             : abap.char(50);
      tenKT             : abap.char(50);
      can_tru           :  abap_boolean;
     
}

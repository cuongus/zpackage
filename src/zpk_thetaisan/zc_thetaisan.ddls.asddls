@EndUserText.label: 'CDS View for KQHDKD'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_JP_DATA_THETAISAN' }
    }
@Metadata.allowExtensions: true

define root custom entity ZC_THETAISAN
  // with parameters parameter_name : parameter_type

{

  key companycode    : bukrs;
  key mainasset      : anln1;
  key subasset       : anln2;
  key assetclass     : abap.char( 8 );
  key costcenter     : kostl;
  @UI.hidden: true
  key CCname         : abap.char( 100 );
  @UI.hidden: true
  key CCadrr         : abap.char( 100 );
      mataisan       : abap.char( 20 );
      descrip        : abap.char( 100 );
      adddescrip     : abap.char( 100 );
      tentaisan      : abap.char( 100 );
//      @UI.hidden: true
      noisudung      : abap.char( 100 );
      @UI.hidden: true
      hientrang      : zde_txt25;
//      @UI.hidden: true
      ngayghitang    : datum;
      @UI.hidden: true
      ngaysudung     : datum;
//      @UI.hidden: true
      @Semantics.amount.currencyCode: 'currency_code'
      nguyengia      : dmbtr;
//      @UI.hidden: true
      sothangkhauhao : abap.int2;
//      @UI.hidden: true
      currency_code  : waers;
      costcentertext : abap.char( 50 );
      assetclasstext : abap.char( 50 );


}

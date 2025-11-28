@EndUserText.label: 'CDS View for KQHDKD'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_JP_GET_DATA_KQHDKD' }
    }
@Metadata.allowExtensions: true

define custom entity ZC_KQHDKD
  // with parameters parameter_name : parameter_type

{

  key bukrs             : bukrs;
      //  key rldnr             : abap.char( 2 );
  key prctr             : abap.char( 10 );
  key gjahr             : gjahr;
  key monat             : monat;
  key type              : zde_loaibc;
      // key ShowDetail        : abap_boolean;
  key HierarchyNode     : abap.char( 10 );
      //  key kunnr             : kunnr;
  key glaccount         : hkont;
  key CCname            : abap.char( 100 );
  key CCadrr            : abap.char( 100 );
      HierarchyNode_TXT : abap.char( 50 );
      @Semantics.amount.currencyCode: 'currency_code'
      sokynay           : dmbtr;
      @Semantics.amount.currencyCode: 'currency_code'
      sokytruoc         : dmbtr;
      @Semantics.amount.currencyCode: 'currency_code'
      lkkynay           : dmbtr;
      @Semantics.amount.currencyCode: 'currency_code'
      lkkytruoc         : dmbtr;
      currency_code     : waers;
      parentNode        : abap.char( 10 );
      tenNL             : abap.char( 40 );
      tenKT             : abap.char( 40 );
      tenGD             : abap.char( 40 );


}



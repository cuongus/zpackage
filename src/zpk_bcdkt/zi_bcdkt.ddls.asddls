@EndUserText.label: 'CDS View for BCDKT'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_JP_GET_DATA_BCDKT' }
    }
@Metadata.allowExtensions: true

define custom entity ZI_BCDKT
  // with parameters parameter_name : parameter_type
  
{
    
  key bukrs             : bukrs;
  key rldnr             : abap.char( 2 );
  key gjahr             : gjahr;
  key monat             : monat;
  key type              : zde_type;
  key ShowDetail        : abap_boolean;
  key HierarchyNode     : abap.char( 10 );
  key kunnr             : kunnr;
  key glaccount         : hkont;
  key CCname            : abap.char( 100 );
  key CCadrr            : abap.char( 100 );
      HierarchyNode_TXT : abap.char( 50 );
      @Semantics.amount.currencyCode: 'currency_code'
      SoDK              : dmbtr;
      @Semantics.amount.currencyCode: 'currency_code'
      SoCK              : dmbtr;
      currency_code     : waers;
      parentNode        : abap.char( 40 );
      tenNL             : abap.char( 40 );
      tenKT             : abap.char( 40 );
      tenGD             : abap.char( 40 );


}

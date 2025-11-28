@EndUserText.label: 'Luu chuyen tien te gian tiep'

@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_JP_GET_DATA_LCTTGT' }
    }

@Metadata.allowExtensions: true

define custom entity ZDD_LCTTGT
// with parameters parameter_name : parameter_type
{
   key bukrs             : bukrs;
   key gjahr             : gjahr;
   key type              : zde_type_rp_indr;
   key stt               : numc4;
   key Zfont             : abap.char( 1 );   
   HierarchyNode         : abap.char( 10 );
   HierarchyNode_TXT     : abap.char( 100 );
   @Semantics.amount.currencyCode: 'currency_code'
      sokynay           : dmbtr;
      @Semantics.amount.currencyCode: 'currency_code'
      sokytruoc         : dmbtr;   
      currency_code     : waers;
        
      
      
}      

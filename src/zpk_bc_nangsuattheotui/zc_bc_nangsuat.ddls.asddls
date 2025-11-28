@EndUserText.label: 'CDS View for KQHDKD'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_GET_NANGSUAT' }
    }
@Metadata.allowExtensions: true

define root custom entity ZC_BC_NANGSUAT
  // with parameters parameter_name : parameter_type

{
  
  key PRODUNIVHIERARCHYNODE     : abap.char( 40 );
  key Plant             : werks_d;
      monat             : monat;
      gjahr             : gjahr;
      PRODUNIVHIERARCHYNODE_txt : abap.char( 255 );
      plant_txt         : abap.char( 255 );
      month_01          : abap.dec( 23, 2 );
      month_02          : abap.dec( 23, 2 );
      month_03          : abap.dec( 23, 2 );
      month_04          : abap.dec( 23, 2 );
      month_05          : abap.dec( 23, 2 );
      month_06          : abap.dec( 23, 2 );
      month_07          : abap.dec( 23, 2 );
      month_08          : abap.dec( 23, 2 );
      month_09          : abap.dec( 23, 2 );
      month_10          : abap.dec( 23, 2 );
      month_11          : abap.dec( 23, 2 );
      month_12          : abap.dec( 23, 2 );

}

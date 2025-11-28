@EndUserText.label: 'So chi tiet tai khoan'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_ROUTING_CORE' }
    }

@Metadata.allowExtensions: true



define custom entity ZC_UPLOAD_ROUTING_CORE
{
  key TasklistGroup   : bukrs;
  key GroupCounter   : hkont;
  key ActivityNumber   : belnr_d;
  status               : abap.char( 1 );
  message              : abap.char( 255 );

}

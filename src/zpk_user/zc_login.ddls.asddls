@EndUserText.label: 'Login'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_C_LOG_IN'
            }
    }
@Metadata.allowExtensions: true
define custom entity ZC_LOGIN
{
  key user_name           : zde_user;
  key password        : zde_passw;
  status : abap.char( 1 );
  message : abap.char( 100 );
  authorizations : abap.string( 0 );
}

@EndUserText.label: 'Parameters for thẻ tài sản'
@Metadata.allowExtensions: true
define abstract entity zbr_para_tts
  //  with parameters parameter_name : parameter_type
{
  companycode        : abap.string(0);

  mainasset            : abap.string(0);

  subasset     : abap.string(0);

}

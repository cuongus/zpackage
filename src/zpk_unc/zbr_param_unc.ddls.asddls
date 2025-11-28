@EndUserText.label: 'Parameters for ủy nhiệm chi'
@Metadata.allowExtensions: true
define abstract entity zbr_param_unc
  //  with parameters parameter_name : parameter_type
{
  CompanyCode        : abap.string(0);

  RunDate            : abap.string(0);

  Identification     : abap.string(0);

  PrintDate          : abap.string(0);

  QuyDoi             : abap.string(0);

  TyGia              : abap.string(0);
  
  PTSTC              : abap.string(0);
  
  PTTTM              : abap.string(0);
  
  PTTTK              : abap.string(0);
  
  NoiDung            : abap.string(0);
  
  PaymentDocument    : abap.string(0);
  
  STK                : abap.string(0);
}


@EndUserText.label: 'Interface - thời gia hoạt động nhà cung cấp'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_SUPPLIER_TIME
  as select from ztb_supplier
 
{
  key line_id         as LineId,
      code_processing as CodeProcessing,
      name_processing as NameProcrssing,
      valid_from      as ValidFrom,
      year_processing as YearProcessing,              
      note            as Note
      
}

@EndUserText.label: 'Value Help for QC'
//@AbapCatalog.sqlViewName: 'ZV_BARCODE_QC'
@ObjectModel.representativeKey: 'MaNv'
define view entity ZI_BARCODE_QC 
as select from ZI_BARCODE
{
     key MaNv,
      NameNv,
      Role
}
where Role = 'QC';

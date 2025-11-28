@EndUserText.label: 'Value Help for Thủ kho'
//@AbapCatalog.sqlViewName: 'ZV_BARCODE_TK'
@ObjectModel.representativeKey: 'MaNv'
define view entity ZI_BARCODE_TK
  as select from ZI_BARCODE
{
  key MaNv,
      NameNv,
      Role
}
where
  Role = 'Thủ kho';

@EndUserText.label: 'Parameters for ĐNTT'
@Metadata.allowExtensions: true
define abstract entity zbr_param_dntt
  //  with parameters parameter_name : parameter_type
{
  CompanyCode  : abap.string(0);

  JournalEntry : abap.string(0);

  FiscalYear   : abap.string(0);
  
  Customer     : abap.string(0);
  
  Supplier     : abap.string(0);
  
  OpenItemTXT     : abap.string(0);

  SoDeNghi     : abap.string(0);

  NgayDeNghi   : abap.string(0);

  HanThanhToan : abap.string(0);

  NguoiDeNghi  : abap.string(0);

  PhongBan     : abap.string(0);

  ThoiGianTH   : abap.string(0);

  NguoiLap     : abap.string(0);

  KeToan       : abap.string(0);

  BanKiemSoat  : abap.string(0);

  KeToanTruong : abap.string(0);

  GIamDoc      : abap.string(0);

  TongGIamDoc  : abap.string(0);
}

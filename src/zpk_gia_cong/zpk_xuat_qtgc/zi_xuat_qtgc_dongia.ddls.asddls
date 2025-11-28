@EndUserText.label: 'Child View ZI_XUAT_DQTGC_DONGIA'
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_XUAT_QTGC'
define custom entity ZI_XUAT_QTGC_DONGIA

{
  key hdr_id          : sysuuid_x16;
  key zper            : zde_period; // kỳ
  key datelapbang     : abap.dats; // ngày lập bảng
key dtl_id      : sysuuid_x16 ;

//      dongia_mahang  : matnr;
//      dongia_tenhang  : text40;
      
      sopo            : ebeln;
      material_id     : abap.char(40); // ma hang
      production_name : abap.char(255); // mo ta hang
      poitem          : ebeln; //po item
      congdoan        : abap.char(255); // cong doan
      dongia          : abap.dec(10,0); // dong gia
    
//      _hdr            : association to parent ZC_XUAT_QTGC_1 on  $projection.hdr_id = _hdr.hdr_id
//                                                             and $projection.zper   = _hdr.zper
//                                                             and $projection.datelapbang   = _hdr.datelapbang;
      
}

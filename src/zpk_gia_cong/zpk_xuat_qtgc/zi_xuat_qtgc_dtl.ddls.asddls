@EndUserText.label: 'Detail - QT Gia Công'
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_XUAT_QTGC'
define custom entity ZI_XUAT_QTGC_DTL

{
  key hdr_id          : sysuuid_x16;
//  key zper            : zde_period; // kỳ
//  key datelapbang       : abap.dats; // ngày lập bảng 
 key dtl_id      : sysuuid_x16 ;
      //phan dtl - qtgc
      datenhaphang    : abap.dats; //ngày nhập hàng
      sobb            : zde_so_bb_gc; // số biên bản gia công
      sopo            : ebeln; // số po
      lenhsanxuat     : aufnr; // LSX gia công
      saleorder       : ebeln; // so sale order
      dc_gc_id        : zde_ma_ngc; //dcgc ma nhà gc
      dc_gc_name      : name1_gp;   // dcgc ten nhà gc
      material_id     : abap.char(40); // ma hang
      production_name : abap.char(255); // mo ta hang
      dc_ct09         : abap.dec(10,0); // hàng đạt thực tế
      dc_ct10         : abap.dec(10,0); // bang 1
      dc_ct11         : abap.dec(10,0); // bang 2 nghiem trong
      dc_ct12         : abap.dec(10,0); // bang 2 dac biet nghiem trong
      dc_ct13         : abap.dec(10,0); // tong hang kem chat luong
      dc_ct14         : abap.dec(10,0); // tong hang kem chat luong >10%
      dc_ct15         : abap.dec(10,0); // tong hang dat va kem chat luong
      dc_ct16         : abap.dec(10,0); // tong hang thực nhận
      dc_ct17         : abap.dec(10,0); // dg may kiểm
      dc_ct18         : abap.dec(23,0); // tong may kiem
      dc_ct19         : abap.dec(23,0); // tong gia cong theo don gia
      dc_ct20         : abap.dec(23,0); // ty le tru hang
      dc_ct21         : abap.dec(23,0); // tru tien khong dat bang 2 nghiem trong
      dc_ct22         : abap.dec(10,2); // ti le tru dac biet nghiem trong
      dc_ct23         : abap.dec(23,0); // tru tien bang 2 dac biet nghiem trong
      dc_ct24         : abap.dec(23,0); // tru tien hang kem cl
      dc_ct29         : abap.dec(23,0); // tru tien hang khong xuat duoc
      dc_ct30         : abap.dec(23,0); // tru tien hang nhung xuat duoc
      dc_ct31         : abap.dec(23,0); // tru tien tra sau cont
      dc_ct32         : abap.dec(23,0); // tru tien hang kiem lai 100% do gia cong
      dc_ct33         : abap.dec(23,0); // may kiem van chuyen cho hang khong dat sau cont
      dc_ct25         : abap.dec(23,0); // don gia v/c
      dc_ct26         : abap.dec(23,0); // tong tien van chuyen
      dc_ct27         : abap.dec(23,0); // cong tru may thieu thua
      dc_ct28         : abap.dec(23,0); // tong tien nhan duoc
      ghi_chu         : abap.sstring(500);

//      _hdr            : association to parent ZC_XUAT_QTGC_1 on  $projection.hdr_id = _hdr.hdr_id
//                                                             and $projection.zper   = _hdr.zper
//                                                             and $projection.datelapbang   = _hdr.datelapbang;

}

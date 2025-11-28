@EndUserText.label: 'Header - QT Gia Công'
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_XUAT_QTGC'
define root custom entity ZC_XUAT_QTGC_1

{
  key hdr_id            : sysuuid_x16;
  key zper              : zde_period; // kỳ
  key datelapbang       : abap.dats;  // ngày lập bảng

      lan               : zde_lan; // lần
      bukrs             : bukrs; // company code

      giacong_id        : zde_ma_ngc; // Mã nhà GC
      giacongname       : name1_gp; // Tên nhà GC

      trutien_btp       : abap.dec(23,0); // tru tien btp thieu trong thang
      tile_btp          : abap.dec(5,2); // ti le btp
      tongtien_bs       : abap.dec(23,0); // tong tien cap bo sung trong thang
      vobao             : abap.dec(23,0); // vo bao
      congtrukhac       : abap.dec(23,0); // cong tru khac
      truloibb          : abap.dec(23,0); // tru tien loi bb
      hotro             : abap.dec(23,0); // ho tro
      tongcongno        : abap.dec(23,0); // tổng cộng nợ phát trinh trong kỳ
      chenhlechno       : abap.dec(23,0); // chênh lệch nợ chưa xuất hóa đơn kỳ trước
      tongtienthanhtoan : abap.dec(23,0); // tổng số tiền thanh toán cho công nợ trong kỳ
      sotienxhd         : abap.dec(23,0); // số tiền xuất hóa đơn trong kỳ
      congnocanxuat     : abap.dec(23,0); // công nợ cần xuất hóa đơn
      chitietcongtru    : abap.char(50); // chi tiết cộng trừ khác
      
      // Line items as JSON string (workaround for structure limitation)
      LineItemsJson                : abap.string;
      LineItemsJson2                : abap.string;
      LineItemsJson3                : abap.string;
      


//      _dtl              : composition [0..*] of ZI_XUAT_QTGC_DTL;
//      _xnt              : composition [0..*] of ZI_QTGC_XNT;
//      _dg               : composition [0..*] of ZI_XUAT_QTGC_DONGIA;


}

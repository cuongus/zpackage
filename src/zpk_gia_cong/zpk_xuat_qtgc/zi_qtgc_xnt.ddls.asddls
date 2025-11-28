@EndUserText.label: 'Xuất Nhập Tồn - QT Gia Công'
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_XUAT_QTGC'
define custom entity ZI_QTGC_XNT
  //  as select from zc_bc_xnt

{
  key mahang            : matnr; // mã hàng
      tenhang           : wgbez; // tên hàng
      materialgroup     : matkl; // material group
      materialgroupname : maktx; // material group name
      plant             : werks_d; // material description
      xnt_supplier      : elifn;
      xnt_SupplierName  : name1_gp;
      xnt_lenhsanxuat   : aufnr;
      @Semantics.quantity.unitOfMeasure : 'mbaseunit'
      tondau            : menge_d; // tồn đầu
      @Semantics.quantity.unitOfMeasure : 'mbaseunit'
      xuattky           : menge_d; // xuất trong kỳ
      @Semantics.quantity.unitOfMeasure : 'mbaseunit'
      nhaptky           : menge_d; // nhập trong kỳ
      @Semantics.quantity.unitOfMeasure : 'mbaseunit'
      btpdanhapve       : menge_d; // số lượng btp đã nhập về
      @Semantics.quantity.unitOfMeasure : 'mbaseunit'
      nhaptrabtpdat     : menge_d; // nhập trả btp đạt
      @Semantics.quantity.unitOfMeasure : 'mbaseunit'
      btploi            : menge_d; // btp lỗi
      @Semantics.quantity.unitOfMeasure : 'mbaseunit'
      btploicty         : menge_d; // btp lỗi do công ty
      @Semantics.quantity.unitOfMeasure : 'mbaseunit'
      btploigc          : menge_d; // btp lỗi do gia công
      @Semantics.quantity.unitOfMeasure : 'mbaseunit'
      btpthieu          : menge_d; // nhập trừ btp thiếu
      @Semantics.quantity.unitOfMeasure : 'mbaseunit'
      tontruocvet       : menge_d; // tồn trước đơn hàng vét
      @Semantics.quantity.unitOfMeasure : 'mbaseunit'
      toncuoi           : menge_d; // tồn cuối
      mbaseunit         : meins; // material base unit
      donhangvet        : abap.char( 1 ); // đơn hàng vét
      BTPSauMay         : matnr; // ma btp sau may
      TenBTPSauMay      : maktx; // ten btp sau may
      SalesOrder        : abap.char( 20 ); // ma don hang

      //      _hdr            : association to parent ZC_XUAT_QTGC_1 on  $projection.hdr_id = _hdr.hdr_id
      //                                                             and $projection.zper   = _hdr.zper
      //                                                             and $projection.datelapbang   = _hdr.datelapbang;
}

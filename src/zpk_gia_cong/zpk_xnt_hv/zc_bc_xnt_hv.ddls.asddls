@EndUserText.label: 'Báo cáo xuất nhập tồn'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_DATA_BC_XNT_HV' }
    }
@Metadata.allowExtensions: true
@UI.presentationVariant: [{
    sortOrder: [
      { by: 'orderid',   direction: #ASC },
      { by: 'supplier', direction: #ASC },
      { by: 'material', direction: #ASC }
    ]
}]

define root custom entity ZC_BC_XNT_hv
  // with parameters parameter_name : parameter_type
{
  key DateFR                 : abap.dats;
  key DateTo                 : abap.dats;
      @Consumption.valueHelpDefinition:[
          { entity           : { name : 'ZVI_PERIOD' , element: 'Zper' } }
         ]
  key zper                   : zde_period;
  key material               : matnr;
  key plant                  : werks_d;
  key supplier               : elifn;
  key orderid                : aufnr;
  key Batch                  : charg_d;
  key InventoryValuationType : bwtar_d;
      productgroup           : matkl;
      ProductGroupName       : maktx;
      ProductDescription     : wgbez;
      SupplierName           : name1_gp;

      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      //  CT6
      DauKy                  : menge_d;
      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      //  CT7
      XuatTKy                : menge_d;
      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      //  CT8
      NhapTKy                : menge_d;
      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      //  CT9A
      SLBTPNVLDaNhapVe       : menge_d;
      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      //  CT9
      NhapTraBTPDat          : menge_d;
      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      //  CT10
      BTPLoi                 : menge_d;
      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      //  CT11
      NhapTraBTPLoiCTy       : menge_d;
      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      //  CT11A
      NhapTraBTPLoiGC        : menge_d;
      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      CT11C                  : menge_d;
      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      //  CT11B
      NhapTruBTPThieu        : menge_d;
      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      //  CT12
      TonCuoi                : menge_d;
      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      CT18A                  : menge_d;

      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      CT18                   : menge_d;

      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      CT19                   : menge_d;

      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      CT20                   : menge_d;

      materialbaseunit       : meins;
      DonHangVet             : abap.char( 1 );
      SalesOrder             : abap.char( 20 );
      BTPSauMay              : matnr;
      TenBTPSauMay           : maktx;
}

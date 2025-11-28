@EndUserText.label: 'Custom entity for BCTP'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_BCTP_CUS_QRY'
@Metadata.allowExtensions: true
define root custom entity ZDD_BCTP
{
  key SalesOrder         : kdauf;
  key SalesOrderItem     : abap.numc(6);
  key PurchaseOrder      : ebeln;
  key zPlant              : werks_d;
  key Supplier           : abap.char(10);
  key Material           : abap.char(40);
      SDProcessStatus    : abap.char(2);

      MaterialName       : abap.char(80);
      PlantName          : abap.char(30);
      OrderQuantity      : abap.int4;
      sl_dong_bo_btp     : abap.int4;


      SupplierName       : abap.char(80);

      sl_xuat_dong_bo    : abap.int4;
      sl_thu_ve_tong_cai : abap.int4;
      tong_cong          : abap.int4;

      sl_con_lai_ngc     : abap.int4;

      sl_btp_tra_ve      : abap.int4;

      hang_phe           : abap.int4;
      hang_loi_phe       : abap.int4;

      created_by         : abap.char(12);
      created_on         : abap.dats;
      created_at         : abap.tims;

      changed_by         : abap.char(12);
      changed_on         : abap.dats;
}

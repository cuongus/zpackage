@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'View Data Khai báo thuế 0%'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define root view entity ZI_DATA_KB_THUE0
  as select from zui_kb_thue0
  //  composition of target_data_source_name as _association_name
  association [0..1] to ZI_MSGT_STA_VH      as _OverallStatus on  $projection.Type = _OverallStatus.Status
  association [0..1] to I_CustomerCompanyVH as _CustomerVH    on  $projection.Customer    = _CustomerVH.Customer
                                                              and $projection.Companycode = _CustomerVH.CompanyCode
  association [0..1] to I_SupplierCompanyVH as _SupplierVH    on  $projection.Supplier    = _SupplierVH.Supplier
                                                              and $projection.Companycode = _SupplierVH.CompanyCode
  association [0..1] to I_CompanyCodeStdVH  as _CompanyCode   on  $projection.Companycode = _CompanyCode.CompanyCode
{
  key uuid                as Uuid,
      documentnumber      as Documentnumber,
      companycode         as Companycode,
      type                as Type,
      mauhd               as Mauhd,
      documentreferenceid as Documentreferenceid,
      postingdate         as Postingdate,
      invoicedate         as Invoicedate,
      supplier            as Supplier,
      customer            as Customer,
      itemtext            as Itemtext,

      @Semantics.amount.currencyCode: 'LoaiTienVND'
      doanhsovnd          as Doanhsovnd,
      dongiavnd           as DonGiaVND,

      loaitienvnd         as LoaiTienVND,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      quantity            as Quantity,
      baseunit            as BaseUnit,

      @Semantics.amount.currencyCode: 'LoaiTienTe'
      doanhsonguyente     as DoanhSoNguyenTe,
      dongianguyente      as DonGiaNguyenTe,
      loaitiente          as LoaiTienTe,

      tenmavanglai        as TenMaVangLai,
      mstmavanglai        as MSTMavangLai,

      note                as Note,

      @Semantics.user.createdBy: true
      createdbyuser       as Createdbyuser,
      @Semantics.systemDateTime.createdAt: true
      createddate         as Createddate,

      @Semantics.user.lastChangedBy: true
      changedbyuser       as Changedbyuser,
      @Semantics.systemDateTime.lastChangedAt: true
      changeddate         as Changeddate,
      //      _association_name // Make association public

      _OverallStatus,
      _CompanyCode,
      _CustomerVH,
      _SupplierVH
}

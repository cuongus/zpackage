@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBXN_XUAT_HD'
@EndUserText.label: 'Xác nhận xuất hóa đơn'
define view entity ZR_TBXN_XUAT_HD
  as select from ztb_xn_xuat_hd
  association        to parent ZR_TBXUAT_HD as _hdr on $projection.HdrID = _hdr.HdrID
  association [0..1] to ZV_PO_GC            as _Po  on $projection.Sopo = _Po.PurchaseOrder
{
  key hdr_id             as HdrID,
  key xnhd_id            as XnhdID,
      material           as Material,
      productdescription as Productdescription,
      sopo               as Sopo,
      _Po.Supplier       as Supplier,
      _Po.SearchTerm1    as SupplierName1,
      @Semantics.quantity.unitOfMeasure: 'Materialbaseunit'
      soluong            as Soluong,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_UnitOfMeasureStdVH',
        entity.element: 'UnitOfMeasure',
        useForValidation: true
      } ]
      materialbaseunit   as Materialbaseunit,
      ct07               as Ct07,
      ct08               as Ct08,
      ct10               as Ct10,
      ct11               as Ct11,
      ct13               as Ct13,
      @Semantics.user.createdBy: true
      created_by         as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at         as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by    as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at    as LastChangedAt,
      _hdr
}

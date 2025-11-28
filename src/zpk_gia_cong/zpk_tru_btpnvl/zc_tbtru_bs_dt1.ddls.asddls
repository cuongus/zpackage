@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBTRU_BS_DTL'
}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZC_TBTRU_BS_DT1
  as projection on ZR_TBTRU_BS_DT1
{
  key HdrID,
  key DtlID,
  Supplier,
  SupplierName,
//  @ObjectModel.text.element: ['nhomctDesc']
//  nhomct,
//  nhomctDesc,
  ct04,
  ct05,
  ct05a,
  ct05b,
  ct06,
  @Semantics: {
    user.createdBy: true
  }
  CreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  CreatedAt,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  LastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LastChangedAt,
     _hdr  : redirected to parent ZC_TBTRU_BS
}

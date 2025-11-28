@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZTBNXT_HV'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBNXT_HV
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TBNXT_HV000
  association [1..1] to ZR_TBNXT_HV000 as _BaseEntity on $projection.MATERIAL = _BaseEntity.MATERIAL and $projection.PLANT = _BaseEntity.PLANT and $projection.SUPPLIER = _BaseEntity.SUPPLIER and $projection.ORDERID = _BaseEntity.ORDERID and $projection.ZPER = _BaseEntity.ZPER and $projection.BATCH = _BaseEntity.BATCH and $projection.INVENTORYVALUATIONTYPE = _BaseEntity.INVENTORYVALUATIONTYPE
{
  key Material,
  key Plant,
  key Supplier,
  key Orderid,
  key Zper,
  key Batch,
  key Inventoryvaluationtype,
  @Semantics: {
    Quantity.Unitofmeasure: 'Materialbaseunit'
  }
  Quantityinbaseunit,
  @Consumption: {
    Valuehelpdefinition: [ {
      Entity.Element: 'UnitOfMeasure', 
      Entity.Name: 'I_UnitOfMeasureStdVH', 
      Useforvalidation: true
    } ]
  }
  Materialbaseunit,
  @Semantics: {
    User.Createdby: true
  }
  CreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  CreatedAt,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  LastChangedBy,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LastChangedAt,
  _BaseEntity
}

@Metadata.allowExtensions: true
//@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Kế hoạch đóng Container'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBCONTAINER'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBCONTAINER
  provider contract transactional_query
  as projection on ZR_TBCONTAINER
//  association [1..1] to ZR_TBCONTAINER as _BaseEntity on $projection.UUID = _BaseEntity.UUID

{
  key UUID,
 SalesOrder,
 SalesOrderItem,
  Counter,
  Plant,
  DocDate,
  ProductHierarchy,
  ContainerWeek,
  ContainerDate,
  ContainerNumber,
  Container,
  ContainerQuan,
  Note,
   SalesOrderQuan,
  Week,
  Uom,
  OpenQuan,
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
  _dtl : redirected to composition child ZC_TBCONTAINER_IT
  
}

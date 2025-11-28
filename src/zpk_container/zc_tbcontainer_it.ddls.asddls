@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Kế hoạch đóng Container'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBCONTAINER_IT'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZC_TBCONTAINER_IT
  as projection on ZR_TBCONTAINER_IT
{
  key UUID,
  key Dtlid,

//      @Consumption.valueHelpDefinition:[
//        { entity                : { name: 'I_SalesOrderItem', element: 'SalesOrder' }
//        }]
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
      _hdr : redirected to parent ZC_TBCONTAINER
}

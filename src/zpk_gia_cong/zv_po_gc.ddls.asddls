@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Thông tin PO gia công'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
//@ObjectModel.representativeKey: 'PurchaseOrder'
//@Search.searchable: true
define view entity ZV_PO_GC as select distinct
from I_PurchaseOrderAPI01 as Po 
left outer join I_Supplier_VH as Sup on Po.Supplier = Sup.Supplier
left outer join I_BusinessPartner as bus on Po.Supplier = bus.BusinessPartner
left outer join I_PurOrdAccountAssignmentAPI01   as Pur on Po.PurchaseOrder = Pur.PurchaseOrder
left outer join I_ManufacturingOrderItem as Man on Pur.OrderID = Man.ManufacturingOrder
left outer join I_ProductDescription as Pdes on Man.Material = Pdes.Product 
left outer join I_SalesOrderItem as OrderItem on OrderItem.SalesOrder = Man.SalesOrder and OrderItem.SalesOrderItem = Man.SalesOrderItem
left outer join zc_loai_tui as Pro on OrderItem.Product = Pro.Product 

{ 
@Search.defaultSearchElement: true
    key Po.PurchaseOrder,
    max( Po.CompanyCode ) as CompanyCode,
    @Search.defaultSearchElement: true
    max( Po.Supplier ) as Supplier,
    @Search.defaultSearchElement: true
    max( Sup.SupplierName ) as SupplierName,
    max( bus.SearchTerm1 ) as SearchTerm1,
    max( Pur.OrderID ) as OrderID,
    max( Man.SalesOrder ) as SalesOrder,
    max( Man.Material ) as Material,
    max( Pdes.ProductDescription ) as ProductDescription,   
    max( OrderItem.Product ) as SalesOrderProduct,
    max( cast( Pro.ProdUnivHierarchyNode as abap.char( 24 ) ) ) as ProdUnivHierarchyNode,    
    max( cast( Pro.ProdUnivHierarchyNodeText as abap.char( 40 ) ) ) as ProdUnivHierarchyNodeText    
    
}

where Po.PurchaseOrderType = 'ZPO4'

group by Po.PurchaseOrder

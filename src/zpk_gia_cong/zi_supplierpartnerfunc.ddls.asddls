@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'I_SupplierPartnerFunc'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zI_SupplierPartnerFunc as 
select from I_SupplierPartnerFunc
association [0..1] to I_BusinessPartner as _BP on $projection.ReferenceSupplier = _BP.BusinessPartner
{
    key Supplier,
    key PurchasingOrganization,
    key SupplierSubrange,
    key Plant,
    key PartnerFunction,
    key PartnerCounter,
    DefaultPartner,
    CreationDate,
    CreatedByUser,
    PartnerFunctionType,
    ReferenceSupplier,
    _BP.SearchTerm1,
    ContactPerson,
    PersonnelNumber,
    AuthorizationGroup,
    /* Associations */
    _Plant,
    _PurchasingOrganization,
    _Supplier,
    _SupplierPartnerCounter,
    _SupplierPurchasing,
    _SupplierSubrange
} where PartnerFunction = 'RS' 

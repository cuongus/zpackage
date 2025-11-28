@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'I_StorageLocation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zI_StorageLocation as select from I_StorageLocation
{
    key Plant,
    key StorageLocation,
    StorageLocationName,
    SalesOrganization,
    DistributionChannel,
    Division,
    IsStorLocAuthznCheckActive,
    HandlingUnitIsRequired,
    ConfigDeprecationCode,
    /* Associations */
    _ConfignDeprecationCode,
    _Plant
}

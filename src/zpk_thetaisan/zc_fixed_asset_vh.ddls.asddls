@AbapCatalog.sqlViewName: 'ZVFIXASSTVH'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Fixed Asset'

@Search.searchable: true

define view ZC_Fixed_Asset_VH
  as select from I_FixedAsset
{
    key MasterFixedAsset,
    key FixedAsset,
    key CompanyCode,
        FixedAssetDescription,
        AssetAdditionalDescription
}

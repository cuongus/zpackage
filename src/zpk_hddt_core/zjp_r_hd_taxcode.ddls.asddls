@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Base CDS View for taxcode'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define root view entity ZJP_R_HD_TAXCODE
  as select from zjp_hd_taxcode
  //composition of target_data_source_name as _association_name
{
      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity                       : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
      }]
  key companycode   as Companycode,
      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity                       : { name: 'I_CurrencyStdVH', element: 'Currency' }
      }]
  key currency      as Currency,
  key taxcode       as Taxcode,
      taxpercentage as Taxpercentage,
      @Semantics.user.createdBy: true
      createdbyuser as Createdbyuser,
      @Semantics.systemDateTime.createdAt: true
      createddate   as Createddate,
      @Semantics.user.lastChangedBy: true
      changedbyuser as Changedbyuser,
      @Semantics.systemDateTime.lastChangedAt: true
      changeddate   as Changeddate
      //    _association_name // Make association public
}

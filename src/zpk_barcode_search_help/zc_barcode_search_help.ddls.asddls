@EndUserText.label: 'Barcode search help'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_BARCODE_SEARCH_HELP
  as projection on ZI_BARCODE

{
  key LineId,
        key    MaNv,
      NameNv,
      @Consumption.valueHelpDefinition: [
          {
            entity: { name: 'ZJP_C_DOMAIN_FIX_VAL', element: 'description' },
            additionalBinding: [
              { element: 'domain_name', localConstant: 'ZDE_BARCODE_SEARCH_HELP', usage: #FILTER }
            ],
            distinctValues: true
          }
        ]
      Role,




      @Consumption.valueHelpDefinition:[
      { entity                : { name: 'I_Plant', element: 'Plant' }
      }]
      Plant,

      // @Consumption.filter     : {
      ////               mandatory         : true
      //               }
      @Consumption.valueHelpDefinition:[
      { entity                : { name: 'I_StorageLocationStdVH', element: 'StorageLocation' }
      }]
      StorageLocation


}

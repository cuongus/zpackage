@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'data definition'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_SUPPLIER_TIME
  as projection on ZI_SUPPLIER_TIME
{

  key LineId,
      //@Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ 
      entity:{ name : 'I_BusinessPartnerVH' , element: 'BusinessPartner' }
       }]
      CodeProcessing,
      
      NameProcrssing,
      ValidFrom,
     
   YearProcessing,
      Note
}

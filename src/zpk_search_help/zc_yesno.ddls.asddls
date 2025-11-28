@EndUserText.label: 'Yes/No'
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.query.implementedBy: 'ABAP:ZCL_YESNO'
@ObjectModel.dataCategory: #VALUE_HELP
define custom entity zc_yesno
{
      @EndUserText.label     : 'Value'
      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{position: 10 }]
      @ObjectModel.text.element: ['description']
      key zvalue         : abap.char( 1 );
      
      @EndUserText.label     : 'Description'
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      description : abap.char(3);
  
}

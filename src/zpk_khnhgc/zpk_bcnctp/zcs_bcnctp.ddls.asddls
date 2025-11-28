@EndUserText.label: 'Báo cáo nhu cầu thành phẩm'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_GET_BCNCTP'
            }
    }
@Metadata.allowExtensions: true
//@Search.searchable: true
define custom entity ZCS_BCNCTP
  // with parameters parameter_name : parameter_type
{
      //  key key_element_name : key_element_type;

      @ObjectModel.text.element: [ 'ProductHierarchy3Name' ]
      @Consumption.valueHelpDefinition:[
      { entity              : { name: 'ZI_ProdHierarchyBasic', element: 'ProductHierarchy3' }
      }]
  key ProductHierarchy3     : abap.char(50);

      @Consumption.valueHelpDefinition:[
      { entity              : { name: 'ZI_ProdHierarchyBasic', element: 'ProductHierarchy4' },
      additionalBinding     : [{ localElement: 'ProductHierarchy3', element: 'ProductHierarchy3' }]
      }]
      @ObjectModel.text.element: [ 'ProductHierarchy4Name' ]
  key ProductHierarchy4     : abap.char(50);

      @ObjectModel.text.element: [ 'PlantName' ]
      @Consumption.valueHelpDefinition:[
      { entity              : { name: 'I_PlantStdVH', element: 'Plant' }
      }]
  key Plant                 : werks_d;

      @Semantics.text       : true
      ProductHierarchy3Name : abap.char(255);

      @Semantics.text       : true
      ProductHierarchy4Name : abap.char(255);

      @Semantics.text       : true
      PlantName             : abap.char(255);

      @Consumption.filter.mandatory: true
      Week                  : abap.char(2);
      @Consumption.filter.mandatory: true
      Zyear                 : gjahr;

      W1OrderQuantity       : abap.dec( 15, 0 );
      W2OrderQuantity       : abap.dec( 15, 0 );
      W3OrderQuantity       : abap.dec( 15, 0 );
      W4OrderQuantity       : abap.dec( 15, 0 );
      W5OrderQuantity       : abap.dec( 15, 0 );
      W6OrderQuantity       : abap.dec( 15, 0 );
      W7OrderQuantity       : abap.dec( 15, 0 );
      W8OrderQuantity       : abap.dec( 15, 0 );
      W9OrderQuantity       : abap.dec( 15, 0 );
      W10OrderQuantity      : abap.dec( 15, 0 );
      W11OrderQuantity      : abap.dec( 15, 0 );
      W12OrderQuantity      : abap.dec( 15, 0 );
      W13OrderQuantity      : abap.dec( 15, 0 );
      W14OrderQuantity      : abap.dec( 15, 0 );
      W15OrderQuantity      : abap.dec( 15, 0 );
      W16OrderQuantity      : abap.dec( 15, 0 );
      W17OrderQuantity      : abap.dec( 15, 0 );
      W18OrderQuantity      : abap.dec( 15, 0 );
      W19OrderQuantity      : abap.dec( 15, 0 );
      W20OrderQuantity      : abap.dec( 15, 0 );
      W21OrderQuantity      : abap.dec( 15, 0 );
      W22OrderQuantity      : abap.dec( 15, 0 );
      W23OrderQuantity      : abap.dec( 15, 0 );
      W24OrderQuantity      : abap.dec( 15, 0 );
      W25OrderQuantity      : abap.dec( 15, 0 );
      W26OrderQuantity      : abap.dec( 15, 0 );
      W27OrderQuantity      : abap.dec( 15, 0 );
      W28OrderQuantity      : abap.dec( 15, 0 );
      W29OrderQuantity      : abap.dec( 15, 0 );
      W30OrderQuantity      : abap.dec( 15, 0 );
      W31OrderQuantity      : abap.dec( 15, 0 );
      W32OrderQuantity      : abap.dec( 15, 0 );
      W33OrderQuantity      : abap.dec( 15, 0 );
      W34OrderQuantity      : abap.dec( 15, 0 );
      W35OrderQuantity      : abap.dec( 15, 0 );
      W36OrderQuantity      : abap.dec( 15, 0 );
      W37OrderQuantity      : abap.dec( 15, 0 );
      W38OrderQuantity      : abap.dec( 15, 0 );
      W39OrderQuantity      : abap.dec( 15, 0 );
      W40OrderQuantity      : abap.dec( 15, 0 );
      W41OrderQuantity      : abap.dec( 15, 0 );
      W42OrderQuantity      : abap.dec( 15, 0 );
      W43OrderQuantity      : abap.dec( 15, 0 );
      W44OrderQuantity      : abap.dec( 15, 0 );
      W45OrderQuantity      : abap.dec( 15, 0 );
      W46OrderQuantity      : abap.dec( 15, 0 );
      W47OrderQuantity      : abap.dec( 15, 0 );
      W48OrderQuantity      : abap.dec( 15, 0 );
      W49OrderQuantity      : abap.dec( 15, 0 );
      W50OrderQuantity      : abap.dec( 15, 0 );
      W51OrderQuantity      : abap.dec( 15, 0 );
      W52OrderQuantity      : abap.dec( 15, 0 );
      W53OrderQuantity      : abap.dec( 15, 0 );
      W54OrderQuantity      : abap.dec( 15, 0 );

}

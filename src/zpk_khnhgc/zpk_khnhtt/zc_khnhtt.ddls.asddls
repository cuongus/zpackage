@EndUserText.label: 'kế hoạch nhận hàng theo tháng'
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_KHNHTT'
define root custom entity ZC_KHNHTT

{
      @ObjectModel.text.element: [ 'ct01' ]
      @Consumption.valueHelpDefinition:[
      { entity              : { name: 'ZI_ProdHierarchyBasic', element: 'ProductHierarchy3' }
      }]
   key ct01: hryid; //Product Hierarchy 3
         @ObjectModel.text.element: [ 'ct03' ]
      @Consumption.valueHelpDefinition:[
      { entity              : { name: 'I_PlantStdVH', element: 'Plant' }
      }]
   key ct03: abap.char(4); //Plant
   key ct06 : zde_week_num; //tuần
   ct02 : abap.char(30); //Product Hierarchy 3 Name
   ct04 : abap.char(50); //Plant Name
   ct05 : abap.char(7); //Tháng
   
   ct07 : abap.numc( 13 ); // Kế hoạch nhận hàng
   ct08 : abap.numc( 13 ); // Năng lực của nhà gia công
   ct09 : abap.numc( 13 ); // Chênh lệch
   @Consumption.filter.mandatory: true
   month_from : abap.char(6);
}

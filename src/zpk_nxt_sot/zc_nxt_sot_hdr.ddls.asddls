@EndUserText.label: 'data definition - NXT Sọt hdr'
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_DATA_BC_NXT_SOT'

define root custom entity ZC_NXT_SOT_HDR
{
      @Consumption.valueHelpDefinition:[
           { entity                       : { name: 'ZVH_MATERIAL', element: 'Material' }
           }]
  key ct01     : matnr; // material

       @Consumption.valueHelpDefinition:[
           { entity                       : { name: 'I_Plant', element: 'Plant' }
           }]
                 @Consumption.filter     : {
            mandatory         : true
            }
  key ct04     : abap.char(4); //plant
        @Consumption.filter     : {
            mandatory         : true
            }
  key DateFR   : abap.dats;
        @Consumption.filter     : {
            mandatory         : true
            }
  key DateTo   : abap.dats;
          @Consumption.valueHelpDefinition:[
      { entity                : { name: 'I_BUSINESSPARTNER', element: 'BusinessPartner' }
      }]
  key ct12     : lifnr; //Vendor
        @Consumption.valueHelpDefinition:[
      { entity                : { name: 'i_storagelocation', element: 'StorageLocation' }
      }]
  key ct06     : lgort_d; //Storage Location
      ct02     : abap.char(40); // description
      ct03     : meins; // base unit measure

      ct05     : abap.char(30); //Plant Description

      ct07     : abap.char(30); //Storage Location Description
      ct08     : abap.dec(13,3); //Tồn đầu
      ct09     : abap.dec(13,3); //Nhập
      ct10     : abap.dec(13,3); //Xuất
      ct11     : abap.dec(13,3); //Tồn cuối
      
      ct13     : abap.char(30); //Vendor Name
      doc_date : budat;

      _dtl     : composition [0..*] of ZC_NXT_SOT_DTL;

}

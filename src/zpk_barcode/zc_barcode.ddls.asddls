@EndUserText.label: 'CDS View for in barcode'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_BARCODE'
@Metadata.allowExtensions: true
define root custom entity ZC_BARCODE
{
  key lineindex               : abap.char(6);
      @Consumption.filter     : {
            mandatory         : true
            }
      @Consumption.valueHelpDefinition:[
      { entity                : { name: 'I_Plant', element: 'Plant' }
      }]
  key plant                   : abap.char(4);
  key Document                : abap.char(20);
      //
  key Document_Item           : abap.string;
      //  key CompanyCode             : bukrs;

      // các nút để chọn
      @Consumption.valueHelpDefinition:[
        { entity              : { name : 'ZJP_C_DOMAIN_FIX_VAL' , element: 'low' } ,
        additionalBinding     : [{ element: 'domain_name',
                  localConstant        : 'ZDE_BARCODE', usage: #FILTER }]
                  , distinctValues     : true
        }]

  key OPTION_NAME             : zde_barcode;



      // màn hình tham số


      @Consumption.valueHelpDefinition:[
      { entity                : { name: 'I_InboundDelivery', element: 'InboundDelivery' }
      }]
  key Delivery                : vbeln; //Inbound delivery

      @Consumption.valueHelpDefinition:[
      { entity                : { name: 'I_PRODUCTIONORDER', element: 'ProductionOrder' }
      }]
  key Production_Order        : aufnr; //Production order

      @Consumption.valueHelpDefinition:[
      { entity                : { name: 'I_MATERIALDOCUMENTHEADER_2', element: 'MaterialDocument' }
      }]
  key matnr_document          : abap.char(10);

      @Consumption.valueHelpDefinition:[
      { entity                : { name: 'C_BOMMaterialVH', element: 'Material' }
      }]
  key matnr_number            : matnr;


  key batch                   : abap.char(10);
  key Document_type           : abap.string;
  key Storage_Location        : lgort_d;


      //      @Consumption.valueHelpDefinition:[
      //      { entity                : { name: 'ZI_BARCODE', element: 'MaNv' }
      //      }]

      @Consumption.valueHelpDefinition: [
        { entity              : { name: 'ZI_BARCODE_TK', element: 'MaNv' } }
      ]
  key keeper                  : abap.char(255);



      //      @Consumption.valueHelpDefinition:[
      //         { entity             : { name: 'ZI_BARCODE', element: 'Role' }
      //         }]
      @Consumption.valueHelpDefinition: [
        { entity              : { name: 'ZI_BARCODE_QC', element: 'MaNv' } }
      ]
  key qc                      : abap.char(255);
  key ValuationType           : abap.char(10);
  key Sale_Order              : kdauf;
  key Sale_Order_item         : kdpos;
  key Supplier                : abap.char(20);
  key Unit                    : meins;
  key customer                : abap.char(255);
  key StockOwner              : abap.char(255);
  key StockType               : abap.char(255);
  key CURRENCCY               : abap.dec(17,2);
  key AreaType                : abap.char(255);

      @Consumption.valueHelpDefinition:[
      { entity                : { name : 'ZJP_C_DOMAIN_FIX_VAL' , element: 'low' } ,
      additionalBinding       : [{ element: 'domain_name',
                localConstant : 'ZDE_HEADER_TYPE', usage: #FILTER }]
                , distinctValues     : true
      }]
  key header_type             : zde_header_type;

      @Consumption.valueHelpDefinition:[
      { entity                : { name : 'ZJP_C_DOMAIN_FIX_VAL' , element: 'low' } ,
      additionalBinding       : [{ element: 'domain_name',
               localConstant  : 'ZDE_PRINT_MULTI', usage: #FILTER }]
               , distinctValues     : true
      }]
  key print_multi             : zde_print_multi;
  key vas                     : abap.char(10);
  key Quantity                : abap.dec(13,3);

      Create_on               : abap.dats;
      Create_by               : abap.string;
      Material_description    : maktx;





      Production_Order_Status : abap.char(20);
      Start_date              : abap.dats;
      End_date                : abap.dats;
      Delivery_date           : abap.dats;

      Supplier_name           : abap.char(20);
      status                  : abap.char(20);
      Posting_Date            : abap.dats;
      //      Valuation_Type :abap.char(5);
}

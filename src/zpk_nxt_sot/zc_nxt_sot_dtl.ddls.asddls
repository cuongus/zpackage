@EndUserText.label: 'data definition - NXT Sọt dtl'
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_DATA_BC_NXT_SOT'
define custom entity ZC_NXT_SOT_DTL
{
  key ct06   : matnr; // material
  key ct03   : mblnr; // material document
  key DateFR : abap.dats;
  key DateTo : abap.dats;
  key ct08   : abap.char(4); //Plant
  key ct09   : lgort_d; //Storage Location
  key ct10   : lifnr; //Vendor
  ct11 : abap.char(30);
  ct12 : abap.char(30); // comment
  ct04   : mblpo;        //Material Document Item

      @Consumption.valueHelpDefinition:[
          { entity           : { name : 'ZVI_PERIOD' , element: 'Zper' } }
         ]
      zper   : zde_period;

      ct01   : abap.numc(4); //Material Document Year
      ct02   : budat; //Posting Date

      ct05   : bwart; //Movement Type
      @Semantics.quantity.unitOfMeasure : 'materialbaseunit'
      ct07   : abap.dec(13,3); //Stock Quantity
      materialbaseunit       : meins;

      _hdr   : association to parent ZC_NXT_SOT_HDR on  $projection.ct06   = _hdr.ct01
                                                    and $projection.ct08   = _hdr.ct04
                                                    and $projection.ct09   = _hdr.ct06
                                                    and $projection.ct10   = _hdr.ct12
                                                    and $projection.DateFR = _hdr.DateFR
                                                    and $projection.DateTo = _hdr.DateTo;
}

@EndUserText.label: 'Custom entity for Search Help'

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.query.implementedBy: 'ABAP:ZCL_OUTBOUNDDELIVERY'
define custom entity ZC_OutboundDelivery
{

      @Search: {defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.9}
  key OutboundDelivery : vbeln_vl; 

}

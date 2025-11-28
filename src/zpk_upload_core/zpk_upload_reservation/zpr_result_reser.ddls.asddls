@EndUserText.label: 'Parameter Reservation'
define abstract entity ZPR_RESULT_RESER
  //  with parameters parameter_name : parameter_type
{
  uuid               : sysuuid_x16;
  reservation        : abap.numc(10);

  msgtype            : abap.char(1);
  msgtext            : abap.char(255);

  documentsequenceno : abap.char(20);
  basedate           : abap.dats;
  costcenter         : abap.char(10);
  goodsmovementtype  : abap.char(3);
  plant              : abap.char(4);
  receivingissuing   : abap.char(4);
  storagelocation    : abap.char(4);
  materialnumber     : matnr;
  @Semantics.quantity.unitOfMeasure : 'unitofmeasure'
  quantity           : abap.quan(13,3);
  unitofmeasure      : meins;
  batch              : abap.char(10);
  salesorder         : abap.char(10);
  salesorderitem     : abap.numc(6);
  valuationtype      : abap.char(2);
  requirementdate    : abap.dats;
  glaccount          : hkont;

  createdbyuser      : abp_creation_user;
  createddate        : abp_creation_tstmpl;
  changedbyuser      : abp_lastchange_user;
  changeddate        : abp_lastchange_tstmpl;

}

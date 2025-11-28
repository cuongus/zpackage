@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Trừ BTP/NVL bổ sung'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBTRU_BS'
}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_TBTRU_BS
  provider contract transactional_query
  as projection on ZR_TBTRU_BS
{
  key HdrID,
      @Consumption.valueHelpDefinition:[
         { entity                       : { name : 'ZVI_PERIOD' , element: 'Zper' } }
        ]
      Zper,
      @Consumption.valueHelpDefinition:[
             { entity                       : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
             }]
      Bukrs,
      lan,
      ngaylapbang,
      Zperdesc,
      Sumdate,
      @Semantics: {
        systemDateTime.localInstanceLastChangedAt: true
      }
      Sumdatetime,
      @Semantics: {
        user.createdBy: true
      }
      CreatedBy,
      @Semantics: {
        systemDateTime.createdAt: true
      }
      CreatedAt,
      @Semantics: {
        user.localInstanceLastChangedBy: true
      }
      LastChangedBy,
      @Semantics: {
        systemDateTime.localInstanceLastChangedAt: true
      }
      LastChangedAt,
      _dtl : redirected to composition child ZC_TBTRU_BS_DTL,
      _dt1 : redirected to composition child ZC_TBTRU_BS_DT1
}

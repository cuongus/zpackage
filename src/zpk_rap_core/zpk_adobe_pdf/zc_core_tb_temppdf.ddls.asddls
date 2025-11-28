@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Template PDF'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_CORE_TB_TEMPPDF
  provider contract transactional_query
  as projection on ZI_CORE_TB_TEMPPDF
{
  key Id,
      FileContent,
      FileType,
      @Semantics.text: true
      FileName,      
      Lastchangeby,
      Lastchangedat
}

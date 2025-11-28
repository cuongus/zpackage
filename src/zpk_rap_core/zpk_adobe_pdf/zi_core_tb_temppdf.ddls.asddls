@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Template PDF'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_CORE_TB_TEMPPDF
  as select from zcore_tb_temppdf
  //composition of target_data_source_name as _association_name
{
  key id            as Id,
      @Semantics.largeObject: { mimeType: 'FileType',   //case-sensitive
                         fileName: 'FileName',   //case-sensitive
//                         acceptableMimeTypes: ['application/vnd.adobe.xdp+xml', 'image/png', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
                         contentDispositionPreference:  #INLINE  }
      file_content  as FileContent,
      
      @Semantics.mimeType: true
      file_type     as FileType,
      
      file_name     as FileName,    
      
      @Semantics.user.lastChangedBy: true
      lastchangeby as Lastchangeby,  
      
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat as Lastchangedat
      //    _association_name // Make association public
}

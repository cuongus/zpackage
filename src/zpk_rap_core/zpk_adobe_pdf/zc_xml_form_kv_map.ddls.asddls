@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection XML Form KV Map'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.sapObjectNodeType.name: 'ZND_XML_FORMKVMAP'
define view entity ZC_XML_FORM_KV_MAP
  //  provider contract transactional_query
  as projection on ZR_XML_FORM_KV_MAP
{
      @Search.defaultSearchElement: true
  key FormId,
  key Zsection,
  key Seq,
      NodeName,
      SrcType,
      SrcName,
      Fmt,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _XML_Form_CFG : redirected to parent ZC_XML_FORM_CFG
}

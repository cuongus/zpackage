@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection XML Form Table Config'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.sapObjectNodeType.name: 'ZND_XML_FORMTBLCFG'
define view entity ZC_XML_FORMTABLE_CFG
  //  provider contract transactional_query
  as projection on ZR_XML_FORMTABLE_CFG
{
      @Search.defaultSearchElement: true
  key FormId,
  key TableId,
  key ContainerId,
  key Seq,
      OpenMode,
      Location,
      TableOpen,
      RowOpen,
      RowClose,
      TableClose,
      Name,
      PrefixXml,
      SuffixXml,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _XML_Form_CFG : redirected to parent ZC_XML_FORM_CFG
}

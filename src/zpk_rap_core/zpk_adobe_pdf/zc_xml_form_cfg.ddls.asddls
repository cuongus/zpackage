@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection XML Form Config'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.sapObjectNodeType.name: 'ZND_XML_FORMCFG'
define root view entity ZC_XML_FORM_CFG
  provider contract transactional_query
  as projection on ZR_XML_FORM_CFG
{
      @Search.defaultSearchElement: true
  key FormId,
      ReportName,
      RootOpen,
      RootClose,
      HeaderOpen,
      HeaderClose,
      FooterOpen,
      FooterClose,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _XML_FormKV_Map    : redirected to composition child ZC_XML_FORM_KV_MAP,
      _XML_FormRow_Map   : redirected to composition child ZC_XML_FORMROW_MAP,
      _XML_FormTable_CFG : redirected to composition child ZC_XML_FORMTABLE_CFG
}

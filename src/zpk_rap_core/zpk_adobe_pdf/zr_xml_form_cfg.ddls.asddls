@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Views XML form Config'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.sapObjectNodeType.name: 'ZND_XML_FORMCFG'
define root view entity ZR_XML_FORM_CFG
  as select from zxml_form_cfg
  composition [0..*] of ZR_XML_FORM_KV_MAP   as _XML_FormKV_Map
  composition [0..*] of ZR_XML_FORMTABLE_CFG as _XML_FormTable_CFG
  composition [0..*] of ZR_XML_FORMROW_MAP   as _XML_FormRow_Map
{
  key form_id         as FormId,
      report_name     as ReportName,
      root_open       as RootOpen,
      root_close      as RootClose,
      header_open     as HeaderOpen,
      header_close    as HeaderClose,
      footer_open     as FooterOpen,
      footer_close    as FooterClose,
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      //      _association_name // Make association public
      _XML_FormKV_Map,
      _XML_FormTable_CFG,
      _XML_FormRow_Map
}

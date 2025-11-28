@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Views XML form KV Config'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.sapObjectNodeType.name: 'ZND_XML_FORMKVMAP'
define view entity ZR_XML_FORM_KV_MAP
  as select from zxml_form_kv_map
  association to parent ZR_XML_FORM_CFG as _XML_Form_CFG on $projection.FormId = _XML_Form_CFG.FormId
{
  key form_id         as FormId,
  key zsection        as Zsection,
  key seq             as Seq,
      node_name       as NodeName,
      src_type        as SrcType,
      src_name        as SrcName,
      fmt             as Fmt,
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      //      _association_name // Make association public
      _XML_Form_CFG
}

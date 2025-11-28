@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Views XML form Table Config'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.sapObjectNodeType.name: 'ZND_XML_FORMTBLCFG'
define view entity ZR_XML_FORMTABLE_CFG
  as select from zxmlformtablecfg
  association to parent ZR_XML_FORM_CFG as _XML_Form_CFG on $projection.FormId = _XML_Form_CFG.FormId
{
  key    form_id         as FormId,
  key    table_id        as TableId,
  key    container_id    as ContainerId,
  key    seq             as Seq,
         open_mode       as OpenMode,
         location        as Location,
         table_open      as TableOpen,
         row_open        as RowOpen,
         row_close       as RowClose,
         table_close     as TableClose,
         name            as Name,
         prefix_xml      as PrefixXml,
         suffix_xml      as SuffixXml,
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

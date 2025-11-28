@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'XML form Row Map'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.sapObjectNodeType.name: 'ZND_XML_FORMROWMAP'
define view entity ZR_XML_FORMROW_MAP
  as select from zxml_formrow_map
  association to parent ZR_XML_FORM_CFG as _XML_Form_CFG on $projection.FormId = _XML_Form_CFG.FormId
{
  key    form_id         as FormId,
  key    table_id        as TableId,
  key    row_kind        as Rowkind,
  key    seq             as Seq,
         xml_name        as XmlName,
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

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection XML Form Row Map'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.sapObjectNodeType.name: 'ZND_XML_FORMROWMAP'
define view entity ZC_XML_FORMROW_MAP
  //  provider contract transactional_query
  as projection on ZR_XML_FORMROW_MAP
{
        @Search.defaultSearchElement: true
  key   FormId,
  key   TableId,
  key   Rowkind,
  key   Seq,
        XmlName,
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

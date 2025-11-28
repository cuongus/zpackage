@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBUPLOAD_BOMIT'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZR_TBUPLOAD_BOMIT
  as select from ztb_upload_bomit

  association to parent ZR_TBUPLOAD_BOMHD as _hdr on $projection.UUID = _hdr.UUID
{
  key uuid                  as UUID,
  key dtlid                 as Dtlid,
      sales_order           as SalesOrder,
      sales_order_item      as SalesOrderItem,
      matnr                 as Matnr,
      plant                 as Plant,
      bom_usage             as BomUsage,
      material_variant      as MaterialVariant,
      material_status       as MaterialStatus,
      header_quan           as HeaderQuan,
      header_unit           as HeaderUnit,
      header_category       as HeaderCategory,
      bom_item_num          as BomItemNum,
      item_category         as ItemCategory,
      bom_component         as BomComponent,
      component_quan        as ComponentQuan,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_UnitOfMeasureStdVH',
        entity.element: 'UnitOfMeasure',
        useForValidation: true
      } ]
      unit                  as Unit,
      net_scrap             as NetScrap,
      scrap_in_percen       as ScrapInPercen,
      relevancy             as Relevancy,
      special_procurement   as SpecialProcurement,
      location              as Location,
      alternativeitem_group as AlternativeitemGroup,
      priority              as Priority,
      alternative_strategy  as AlternativeStrategy,
      alternative_usage     as AlternativeUsage,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,
      _hdr
}

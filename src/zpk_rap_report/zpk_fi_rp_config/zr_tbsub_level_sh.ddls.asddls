@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBSUB_LEVEL'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBSUB_LEVEL_SH
  as select distinct from ztb_sub_level
{
  key sublevel as Sublevel
}

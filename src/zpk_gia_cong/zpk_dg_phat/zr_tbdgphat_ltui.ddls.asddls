@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBDGPHAT_LTUI'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBDGPHAT_LTUI
  as select from ztb_dgphat_ltui
  association [0..1] to zc_loai_tui_1    as _loai_tui   on $projection.loaitui = _loai_tui.ProdUnivHierarchyNode
{
  key uuid as UUID,
  errorcode as Errorcode,
  cast(
           case
               when errorcode = '08_01' then 'Hàng không đạt không xuất được cont'
               when errorcode = '09_01' then 'Hàng trả sau cont'
               else ''
           end
           as zde_ten_loi
      )               as Errorname,
  loaitui as Loaitui,
  _loai_tui.ProdUnivHierarchyNodeText as LoaituiText,
  penaltyprice as Penaltyprice,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt
}

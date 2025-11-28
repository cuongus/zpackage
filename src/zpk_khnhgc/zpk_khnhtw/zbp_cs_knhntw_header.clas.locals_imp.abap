CLASS lhc_pbkhnhtw_header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR pbkhnhtw_header RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE pbkhnhtw_header.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE pbkhnhtw_header.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE pbkhnhtw_header.

    METHODS read FOR READ
      IMPORTING keys FOR READ pbkhnhtw_header RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK pbkhnhtw_header.

    METHODS rba_item FOR READ
      IMPORTING keys_rba FOR READ pbkhnhtw_header\_item FULL result_requested RESULT result LINK association_links.

    METHODS cba_item FOR MODIFY
      IMPORTING entities_cba FOR CREATE pbkhnhtw_header\_item.

    METHODS getrawdata FOR MODIFY
      IMPORTING keys FOR ACTION pbkhnhtw_header~getrawdata RESULT result.

ENDCLASS.

CLASS lhc_pbkhnhtw_header IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_item.
  ENDMETHOD.

  METHOD cba_item.
  ENDMETHOD.

  METHOD getrawdata.

    READ TABLE keys INDEX 1 INTO DATA(k).

    DATA(lv_companycode) = k-%param-companycode.
    DATA(lv_version)     = k-%param-version.
    DATA(lv_versionname) = k-%param-versionname.

    DATA(yearfrom) = CONV gjahr( k-%param-weekfrom+3(4) ).
    DATA(yearto)   = CONV gjahr( k-%param-weekto+3(4) ).

    DATA(weekfrom) = CONV i( k-%param-weekfrom+0(2) ).
    DATA(weekto)   = CONV i( k-%param-weekto+0(2) ).

    IF yearto IS INITIAL.
      yearto = yearfrom.
    ENDIF.

    IF weekto IS INITIAL.
      weekto = weekfrom.
    ENDIF.

    DATA: lr_week TYPE zcl_kbsn_ns_tuan=>tt_ranges,
          lr_year TYPE zcl_kbsn_ns_tuan=>tt_ranges.

    APPEND VALUE #( sign = 'I' option = 'BT' low = weekfrom high = weekto ) TO lr_week.
    APPEND VALUE #( sign = 'I' option = 'BT' low = yearfrom high = yearto ) TO lr_year.

    zcl_kbsn_ns_tuan=>get_ns_tuan(
      EXPORTING
*            ir_workcenter   type zcl_kbsn_ns_tuan=>tt_ranges optional
*            ir_hierarchynode    type zcl_kbsn_ns_tuan=>tt_ranges optional
*            ir_plant    type zcl_kbsn_ns_tuan=>tt_ranges optional
        ir_week      = lr_week
        ir_year      = lr_year
        iv_week_from = weekfrom
        iv_year_from = yearfrom
      IMPORTING
        et_data      = DATA(lt_nstuan)
        et_returns   = DATA(lt_returns)
    ).

    zcl_get_bcnctp=>get_bcnctp(
      EXPORTING
*        ir_hierarchy3   type zcl_get_bcnctp=>tt_ranges optional
*        ir_hierarchy4   type zcl_get_bcnctp=>tt_ranges optional
*        ir_plant    type zcl_get_bcnctp=>tt_ranges optional
        ir_week    = lr_week
        ir_year    = lr_year
      IMPORTING
        et_data    = DATA(lt_bcnctp)
        et_returns = lt_returns
    ).

    DATA: lt_item TYPE STANDARD TABLE OF zcs_knhntw_item,
          ls_item LIKE LINE OF lt_item.


    "Base index: W1 ứng với (iv_year_from, iv_week_from)
    DATA lv_base_idx TYPE i.
    lv_base_idx = yearfrom * 54 + weekfrom.

    LOOP AT lt_nstuan INTO DATA(ls_nstuan).

      CLEAR: ls_item.
      MOVE-CORRESPONDING ls_nstuan TO ls_item.

      ls_item-companycode = lv_companycode.
      ls_item-version     = lv_version.
      ls_item-versionname = lv_versionname.

      COLLECT ls_item INTO lt_item.

    ENDLOOP.

    LOOP AT lt_bcnctp INTO DATA(ls_bcnctp).
      CLEAR: ls_item.

      ls_item-companycode = lv_companycode.
      ls_item-version     = lv_version.
      ls_item-versionname = lv_versionname.

      ls_item-producthierarchy3 = ls_bcnctp-producthierarchy3.
      ls_item-plant             = ls_bcnctp-plant.

      ls_item-w1receivingplan  = ls_bcnctp-w1orderquantity.
      ls_item-w2receivingplan  = ls_bcnctp-w2orderquantity.
      ls_item-w3receivingplan  = ls_bcnctp-w3orderquantity.
      ls_item-w4receivingplan  = ls_bcnctp-w4orderquantity.
      ls_item-w5receivingplan  = ls_bcnctp-w5orderquantity.
      ls_item-w6receivingplan  = ls_bcnctp-w6orderquantity.
      ls_item-w7receivingplan  = ls_bcnctp-w7orderquantity.
      ls_item-w8receivingplan  = ls_bcnctp-w8orderquantity.
      ls_item-w9receivingplan  = ls_bcnctp-w9orderquantity.
      ls_item-w10receivingplan = ls_bcnctp-w10orderquantity.
      ls_item-w11receivingplan = ls_bcnctp-w11orderquantity.
      ls_item-w12receivingplan = ls_bcnctp-w12orderquantity.
      ls_item-w13receivingplan = ls_bcnctp-w13orderquantity.
      ls_item-w14receivingplan = ls_bcnctp-w14orderquantity.
      ls_item-w15receivingplan = ls_bcnctp-w15orderquantity.
      ls_item-w16receivingplan = ls_bcnctp-w16orderquantity.
      ls_item-w17receivingplan = ls_bcnctp-w17orderquantity.
      ls_item-w18receivingplan = ls_bcnctp-w18orderquantity.
      ls_item-w19receivingplan = ls_bcnctp-w19orderquantity.
      ls_item-w20receivingplan = ls_bcnctp-w20orderquantity.
      ls_item-w21receivingplan = ls_bcnctp-w21orderquantity.
      ls_item-w22receivingplan = ls_bcnctp-w22orderquantity.
      ls_item-w23receivingplan = ls_bcnctp-w23orderquantity.
      ls_item-w24receivingplan = ls_bcnctp-w24orderquantity.
      ls_item-w25receivingplan = ls_bcnctp-w25orderquantity.
      ls_item-w26receivingplan = ls_bcnctp-w26orderquantity.
      ls_item-w27receivingplan = ls_bcnctp-w27orderquantity.
      ls_item-w28receivingplan = ls_bcnctp-w28orderquantity.
      ls_item-w29receivingplan = ls_bcnctp-w29orderquantity.
      ls_item-w30receivingplan = ls_bcnctp-w30orderquantity.
      ls_item-w31receivingplan = ls_bcnctp-w31orderquantity.
      ls_item-w32receivingplan = ls_bcnctp-w32orderquantity.
      ls_item-w33receivingplan = ls_bcnctp-w33orderquantity.
      ls_item-w34receivingplan = ls_bcnctp-w34orderquantity.
      ls_item-w35receivingplan = ls_bcnctp-w35orderquantity.
      ls_item-w36receivingplan = ls_bcnctp-w36orderquantity.
      ls_item-w37receivingplan = ls_bcnctp-w37orderquantity.
      ls_item-w38receivingplan = ls_bcnctp-w38orderquantity.
      ls_item-w39receivingplan = ls_bcnctp-w39orderquantity.
      ls_item-w40receivingplan = ls_bcnctp-w40orderquantity.
      ls_item-w41receivingplan = ls_bcnctp-w41orderquantity.
      ls_item-w42receivingplan = ls_bcnctp-w42orderquantity.
      ls_item-w43receivingplan = ls_bcnctp-w43orderquantity.
      ls_item-w44receivingplan = ls_bcnctp-w44orderquantity.
      ls_item-w45receivingplan = ls_bcnctp-w45orderquantity.
      ls_item-w46receivingplan = ls_bcnctp-w46orderquantity.
      ls_item-w47receivingplan = ls_bcnctp-w47orderquantity.
      ls_item-w48receivingplan = ls_bcnctp-w48orderquantity.
      ls_item-w49receivingplan = ls_bcnctp-w49orderquantity.
      ls_item-w50receivingplan = ls_bcnctp-w50orderquantity.
      ls_item-w51receivingplan = ls_bcnctp-w51orderquantity.
      ls_item-w52receivingplan = ls_bcnctp-w52orderquantity.
      ls_item-w53receivingplan = ls_bcnctp-w53orderquantity.
      ls_item-w54receivingplan = ls_bcnctp-w54orderquantity.

      COLLECT ls_item INTO lt_item.

    ENDLOOP.

    DATA lt_map TYPE /ui2/cl_json=>name_mappings.

*** Create JSON
    DATA(json) = /ui2/cl_json=>serialize(
      data = lt_item
*     name_mappings = lt_map
    ).

    DATA: lv_name TYPE string.
    lv_name = |GetRawData_{ sy-datlo }|.

    result = VALUE #(
                FOR key IN keys (
*                       %cid_ref = key-%cid_ref
*                       %tky   = key-%tky
                %cid   = key-%cid
                %param = VALUE #( filecontent   = json
                                  filename      = lv_name
                                  fileextension = 'json'
*                                              mimeType      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                  mimetype      = 'application/json'
                                  )
                )
    ).

  ENDMETHOD.

ENDCLASS.

CLASS lhc_pbkhnhtw_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE pbkhnhtw_item.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE pbkhnhtw_item.

    METHODS read FOR READ
      IMPORTING keys FOR READ pbkhnhtw_item RESULT result.

    METHODS rba_header FOR READ
      IMPORTING keys_rba FOR READ pbkhnhtw_item\_header FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_pbkhnhtw_item IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_header.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zcs_knhntw_header DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zcs_knhntw_header IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

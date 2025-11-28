CLASS lhc_ZRTBNXTSOT000 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zrtbnxtsot000 RESULT result.

    METHODS CreateXNT FOR MODIFY
      IMPORTING keys FOR ACTION zrtbnxtsot000~CreateXNT.

ENDCLASS.

CLASS lhc_ZRTBNXTSOT000 IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD CreateXNT.
    DATA: n  TYPE i,
          n1 TYPE i.
    DATA: lt_bc_xnt TYPE TABLE OF ZC_nxt_sot_hdr,
          lt_xnt    TYPE TABLE OF ztb_nxt_sot.
    DATA: lt_nxt_cr TYPE TABLE FOR CREATE zr_tbnxt_sot000,
          ls_nxt_cr TYPE STRUCTURE FOR CREATE zr_tbnxt_sot000.
    DATA: lt_nxt_ud TYPE TABLE FOR UPDATE zr_tbnxt_sot000,
          ls_nxt_ud TYPE STRUCTURE FOR UPDATE zr_tbnxt_sot000.
    DATA: lt_nxt_dl TYPE TABLE FOR DELETE zr_tbnxt_sot000,
          ls_nxt_dl TYPE STRUCTURE FOR DELETE zr_tbnxt_sot000.

    READ TABLE keys INTO DATA(ls_key) INDEX 1.
    DATA(lw_fr) = ls_key-%param-perfr.
    DATA(lw_to) = ls_key-%param-perto.
    IF lw_to IS INITIAL OR lw_to < lw_fr.
      lw_to = lw_fr.
    ENDIF.

    WHILE lw_fr <= lw_to.
      SELECT SINGLE * FROM ztb_period
        WHERE zper = @lw_fr
        INTO @DATA(ls_period).
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      CALL METHOD zcl_nxt_sot=>get_xnt_sot
        EXPORTING
          ir_datefr     = ls_period-zdatefr
          ir_dateto     = ls_period-zdateto
        IMPORTING
          e_nxt_sot_hdr = lt_bc_xnt.

      SELECT * FROM ztb_nxt_sot WHERE zper = @lw_fr INTO TABLE @lt_xnt .
      LOOP AT lt_xnt INTO DATA(ls_xnt).
        READ TABLE lt_bc_xnt WITH KEY ct01 = ls_xnt-material
                                              ct04 = ls_xnt-plant
                                              ct12 = ls_xnt-vendor
                                              ct06 = ls_xnt-sloc
                              ASSIGNING FIELD-SYMBOL(<ls_bc_xnt>).
        IF sy-subrc IS NOT INITIAL.
          APPEND INITIAL LINE TO lt_nxt_dl ASSIGNING FIELD-SYMBOL(<ls_nxt_dl>).
          <ls_nxt_dl>-Zper = lw_fr.
          <ls_nxt_dl>-Material =  ls_xnt-Material.
          <ls_nxt_dl>-Plant =  ls_xnt-Plant.
          <ls_nxt_dl>-Sloc =  ls_xnt-sloc.

        ENDIF.
      ENDLOOP.

      n1 = 0.
      LOOP AT lt_bc_xnt INTO DATA(ls_bc_xnt).
        n1 = n1 + 1.
        READ TABLE lt_xnt WITH KEY material = ls_bc_xnt-ct01
                                              plant = ls_bc_xnt-ct04
                                              sloc = ls_bc_xnt-ct06
                                              vendor = ls_bc_xnt-ct12
                              ASSIGNING FIELD-SYMBOL(<ls_xnt>).
        IF sy-subrc IS NOT INITIAL.
          APPEND INITIAL LINE TO lt_nxt_cr ASSIGNING FIELD-SYMBOL(<ls_xnt_cr>).
          MOVE-CORRESPONDING ls_bc_xnt TO <ls_xnt_cr>.
          <ls_xnt_cr>-material = ls_bc_xnt-ct01.
          <ls_xnt_cr>-plant    = ls_bc_xnt-ct04.
          <ls_xnt_cr>-sloc     = ls_bc_xnt-ct06.
          <ls_xnt_cr>-Vendor   = ls_bc_xnt-ct12.
          <ls_xnt_cr>-Zper = lw_fr.
          <ls_xnt_cr>-StockQty = ls_bc_xnt-ct11.
          <ls_xnt_cr>-Materialbaseunit = ls_bc_xnt-ct03.
          <ls_xnt_cr>-%cid = 'CRXNT' && n && n1.
        ELSE.
          APPEND INITIAL LINE TO lt_nxt_ud ASSIGNING FIELD-SYMBOL(<ls_xnt_ud>).
          MOVE-CORRESPONDING ls_bc_xnt TO <ls_xnt_ud>.
          <ls_xnt_ud>-Zper = lw_fr.
          <ls_xnt_ud>-StockQty = ls_bc_xnt-ct11.
        ENDIF.
      ENDLOOP.

      IF lt_nxt_cr[] IS NOT INITIAL.
        MODIFY ENTITIES OF zr_tbnxt_sot000 IN LOCAL MODE
          ENTITY zrtbnxtsot000
            CREATE FIELDS ( Material Plant Zper Sloc Vendor StockQty Materialbaseunit )
            WITH lt_nxt_cr.
      ENDIF.

      IF lt_nxt_ud[] IS NOT INITIAL.
        MODIFY ENTITIES OF zr_tbnxt_sot000 IN LOCAL MODE
          ENTITY zrtbnxtsot000
            UPDATE FIELDS ( StockQty Materialbaseunit )
            WITH lt_nxt_ud.
      ENDIF.

      IF lt_nxt_dl[] IS NOT INITIAL.
        MODIFY ENTITIES OF zr_tbnxt_sot000 IN LOCAL MODE
            ENTITY zrtbnxtsot000
                DELETE
                FROM lt_nxt_dl.
      ENDIF.

      SELECT SINGLE * FROM ztb_period
        WHERE lastper = @lw_fr
        INTO @ls_period.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      lw_fr = ls_period-zper.

      n = n + 1.
      IF n > 12.
        EXIT.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.

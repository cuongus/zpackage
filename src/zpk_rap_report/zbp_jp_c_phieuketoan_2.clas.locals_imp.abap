CLASS lhc_zjp_c_phieuketoan_2 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zjp_c_phieuketoan_2 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zjp_c_phieuketoan_2 RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zjp_c_phieuketoan_2 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zjp_c_phieuketoan_2.

    METHODS rba_phieuketoanitems FOR READ
      IMPORTING keys_rba FOR READ zjp_c_phieuketoan_2\_phieuketoanitems FULL result_requested RESULT result LINK association_links.

    METHODS btnprintpdf FOR MODIFY
      IMPORTING keys FOR ACTION zjp_c_phieuketoan_2~btnprintpdf RESULT result.

    METHODS btnprintqueue FOR MODIFY
      IMPORTING keys FOR ACTION zjp_c_phieuketoan_2~btnprintqueue RESULT result.

ENDCLASS.

CLASS lhc_zjp_c_phieuketoan_2 IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_phieuketoanitems.
  ENDMETHOD.

  METHOD btnprintpdf.
*    DATA: LV_FILE_CONTENT TYPE STRING.

    zcl_jp_report_fi_export=>btnprintpdf_pkt_new(
      EXPORTING
        keys     = keys
*      IMPORTING
*       O_PDF    = LV_FILE_CONTENT
      CHANGING
        result   = result
        mapped   = mapped
        failed   = failed
        reported = reported
    ).

  ENDMETHOD.

  METHOD btnprintqueue.

    zcl_jp_report_fi_export=>btnprintqueue_pkt(
      EXPORTING
        keys       = keys
        printqueue = 'X'
*      IMPORTING
*       O_PDF      = LV_FILE_CONTENT
      CHANGING
        result     = result
        mapped     = mapped
        failed     = failed
        reported   = reported
    ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zjp_c_phieuketoan_items_2 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ zjp_c_phieuketoan_items_2 RESULT result.

    METHODS rba_phieuketoan FOR READ
      IMPORTING keys_rba FOR READ zjp_c_phieuketoan_items_2\_phieuketoan FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_zjp_c_phieuketoan_items_2 IMPLEMENTATION.

  METHOD read.
  ENDMETHOD.

  METHOD rba_phieuketoan.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zjp_c_phieuketoan_2 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zjp_c_phieuketoan_2 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    zcl_jp_report_fi_export=>pkt_process_save(
      CHANGING
        reported = reported
    ).
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

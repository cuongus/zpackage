CLASS lhc_ZC_BARCODE DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

*    METHODS get_instance_features FOR INSTANCE FEATURES
*      IMPORTING keys REQUEST requested_features FOR zc_barcode RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zc_barcode RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zc_barcode RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zc_barcode.

    METHODS btnPrintPDF FOR MODIFY
      IMPORTING keys FOR ACTION zc_barcode~btnPrintPDF RESULT result.

ENDCLASS.

CLASS lhc_ZC_BARCODE IMPLEMENTATION.

*  METHOD get_instance_features.
*  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD btnPrintPDF.

    zcl_barcode_export_pdf=>btnprintpdf(
      EXPORTING
        KEYS     = KEYS
*      IMPORTING
*        O_PDF    = LV_FILE_CONTENT
      CHANGING
        RESULT   = result
        MAPPED   = MAPPED
        FAILED   = FAILED
        REPORTED = REPORTED
    ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZC_BARCODE DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZC_BARCODE IMPLEMENTATION.

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

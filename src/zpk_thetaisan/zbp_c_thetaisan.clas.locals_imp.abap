CLASS lhc_ZC_THETAISAN DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zc_thetaisan RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zc_thetaisan RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zc_thetaisan.

    METHODS btnPrintPDF FOR MODIFY
      IMPORTING keys FOR ACTION zc_thetaisan~btnPrintPDF RESULT result.

ENDCLASS.

CLASS lhc_ZC_THETAISAN IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD btnPrintPDF.
      zcl_jp_data_thetaisan=>btnprintpdf(
        EXPORTING
          keys     = keys
*      IMPORTING
*        O_PDF    = LV_FILE_CONTENT
        CHANGING
          result   = result
          mapped   = mapped
          failed   = failed
          reported = reported
      ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZC_THETAISAN DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZC_THETAISAN IMPLEMENTATION.

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

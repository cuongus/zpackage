CLASS lhc_datapbkhnh DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR datapbkhnh RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE datapbkhnh.

    METHODS savedata FOR MODIFY
      IMPORTING keys FOR ACTION datapbkhnh~savedata RESULT result.

ENDCLASS.

CLASS lhc_datapbkhnh IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
  ENDMETHOD.

  METHOD savedata.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_ui_pbkhnh DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_ui_pbkhnh IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

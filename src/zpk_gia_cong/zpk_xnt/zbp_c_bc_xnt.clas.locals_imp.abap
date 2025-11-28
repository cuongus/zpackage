CLASS lhc_ZC_BC_XNT DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zc_bc_xnt RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zc_bc_xnt RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zc_bc_xnt.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zc_bc_xnt.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zc_bc_xnt.

    METHODS read FOR READ
      IMPORTING keys FOR READ zc_bc_xnt RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zc_bc_xnt.

ENDCLASS.

CLASS lhc_ZC_BC_XNT IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

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

ENDCLASS.

CLASS lsc_ZC_BC_XNT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZC_BC_XNT IMPLEMENTATION.

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

CLASS zcl_select_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SELECT_TEST IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

READ ENTITIES OF ZC_BC_XNT
     ENTITY zc_bc_xnt
     ALL FIELDS
     WITH VALUE #( ( zper = '202509' ) )
     RESULT DATA(lt_result).

    out->write( lt_result ).
  ENDMETHOD.
ENDCLASS.

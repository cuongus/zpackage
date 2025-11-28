CLASS zcl_get_data_ccs DEFINITION
  PUBLIC
  INHERITING FROM cx_rap_query_provider
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .

    CLASS-DATA:

    mo_instance  TYPE REF TO zcl_jp_get_data_lcttgt.


    CLASS-METHODS:

      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_jp_get_data_lcttgt.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GET_DATA_CCS IMPLEMENTATION.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD if_rap_query_provider~select.


  ENDMETHOD.
ENDCLASS.

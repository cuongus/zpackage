CLASS LHC_DEMO_GEN1 DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR demo_gen1
        RESULT result,
      CALCULATEHDRID FOR DETERMINE ON SAVE
        IMPORTING
          KEYS FOR  demo_gen1~CalculateHdrID .
ENDCLASS.

CLASS LHC_DEMO_GEN1 IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.
  METHOD CALCULATEHDRID.
  READ ENTITIES OF ZR_demo_gen102TP IN LOCAL MODE
    ENTITY demo_gen1
      ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(entities).
  DELETE entities WHERE HdrID IS NOT INITIAL.
  Check entities is not initial.
  "Dummy logic to determine object_id
  SELECT MAX( HDR_ID ) FROM ZTB_GEN1_HDR INTO @DATA(max_object_id).
  "Add support for draft if used in modify
  "SELECT SINGLE FROM FROM ZDEMO_GEN101D FIELDS MAX( HdrID ) INTO @DATA(max_orderid_draft). "draft table
  "if max_orderid_draft > max_object_id
  " max_object_id = max_orderid_draft.
  "ENDIF.
  MODIFY ENTITIES OF ZR_demo_gen102TP IN LOCAL MODE
    ENTITY demo_gen1
      UPDATE FIELDS ( HdrID )
        WITH VALUE #( FOR entity IN entities INDEX INTO i (
        %tky          = entity-%tky
        HdrID     = max_object_id + i
  ) ).
  ENDMETHOD.
ENDCLASS.

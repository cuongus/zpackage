class ZCO_SUPPLIER_INVOICE_ERPCREATE definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods SUPPLIER_INVOICE_ERPCREATE_REQ
    importing
      !INPUT type ZSUPPLIER_INVOICE_ERPCREATE_RE
    exporting
      !OUTPUT type ZSUPPLIER_INVOICE_ERPCREATE_CO
    raising
      CX_AI_SYSTEM_FAULT
      ZCX_STANDARD_MESSAGE_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZCO_SUPPLIER_INVOICE_ERPCREATE IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZCO_SUPPLIER_INVOICE_ERPCREATE'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method SUPPLIER_INVOICE_ERPCREATE_REQ.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'SUPPLIER_INVOICE_ERPCREATE_REQ'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.

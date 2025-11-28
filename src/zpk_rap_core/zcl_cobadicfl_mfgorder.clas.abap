CLASS zcl_cobadicfl_mfgorder DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS: get_data_order IMPORTING i_order          TYPE i_productionorder-productionorder OPTIONAL
                                            i_item           TYPE i_productionorderitem-productionorderitem OPTIONAL
                                            i_workcenter     TYPE i_workcenter-workcenter OPTIONAL
                                            i_product        TYPE i_manufacturingorder-product OPTIONAL
                                  EXPORTING sew              TYPE string
                                            producthierachy1 TYPE string
                                            producthierachy2 TYPE string
                                            producthierachy3 TYPE string
                                            producthierachy4 TYPE string
                                            producthierachy5 TYPE string
                                            producthierachy6 TYPE string
                                            quantity         TYPE zr_tbbb_gc-ct12
                                            quantityngc      TYPE zr_tbbb_gc-ct12.

    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_COBADICFL_MFGORDER IMPLEMENTATION.


  METHOD get_data_order.

    TYPES: BEGIN OF lty_producthierachy,
             producthierachy1 TYPE string,
             producthierachy2 TYPE string,
             producthierachy3 TYPE string,
             producthierachy4 TYPE string,
             producthierachy5 TYPE string,
             producthierachy6 TYPE string,
           END OF lty_producthierachy.

    DATA: ls_producthierachy TYPE lty_producthierachy.

    IF i_workcenter IS NOT INITIAL.
      SELECT SINGLE workcenterresponsible
      FROM i_workcenter
      WHERE workcenter = @i_workcenter
      INTO @sew.
    ENDIF.

    DATA: lv_field TYPE string.

    SELECT SINGLE product FROM i_manufacturingorder
    WHERE manufacturingorder = @i_order
*      AND productionorderitem = @i_item
    INTO @DATA(lv_product).

    IF sy-subrc EQ 0.

    ELSE.
      lv_product = i_product.
    ENDIF.

    IF lv_product IS NOT INITIAL.
      SELECT SINGLE * FROM i_produnivhierarchynodebasic
      WHERE product = @lv_product
      INTO @DATA(ls_produnivhierarchynodebasic).
      IF sy-subrc EQ 0.
        DO.
          DATA(lv_int) = CONV i( ls_produnivhierarchynodebasic-hierarchynodelevel ).
          lv_field = 'producthierachy' && lv_int.
          ASSIGN COMPONENT lv_field OF STRUCTURE ls_producthierachy TO FIELD-SYMBOL(<lv_value>).
          IF <lv_value> IS ASSIGNED.
            SELECT SINGLE * FROM i_produnivhiernodetext_2
            WHERE hierarchynode = @ls_produnivhierarchynodebasic-parentnode
            INTO @DATA(ls_produnivhiernodetext_2).
            IF sy-subrc EQ 0.
              <lv_value> = ls_produnivhiernodetext_2-produnivhierarchynodetext.
            ENDIF.
          ENDIF.

          SELECT SINGLE * FROM i_produnivhierarchynodebasic
          WHERE hierarchynode = @ls_produnivhierarchynodebasic-parentnode
          AND produnivhierarchy = 'PH_MANUFACTURING'
          INTO @ls_produnivhierarchynodebasic.
          IF sy-subrc NE 0.
            CLEAR: ls_produnivhierarchynodebasic.
          ENDIF.

          IF ls_produnivhierarchynodebasic-parentnode IS INITIAL.
            EXIT.
          ENDIF.
        ENDDO.
      ENDIF.
    ENDIF.

    SELECT
    orderid,
    SUM( ct12 ) AS quantity
    FROM zr_tbbb_gc
    WHERE orderid = @i_order
      AND sobbsub = '00'
    GROUP BY orderid
    INTO TABLE @DATA(lt_quantity)
    .
    IF sy-subrc EQ 0.
      READ TABLE lt_quantity INTO DATA(ls_quantity) INDEX 1.

      quantity = ls_quantity-quantity.
    ENDIF.

*    SELECT SINGLE OrderConfirmedYieldQty From I_ProductionOrder
*    WHERE ProductionOrder = @i_order
*    into @DATA(lv_ConfirmedYieldQty).
*    if sy-subrc EQ 0.
*        quantityngc = lv_confirmedyieldqty - quantity.
*    ENDIF.

    SELECT SINGLE optotalconfirmedyieldqty FROM i_manufacturingorderoperation
    WHERE manufacturingorder = @i_order
      AND manufacturingorderoperation = @i_item
    INTO @DATA(lv_confirmedyieldqty).
    IF sy-subrc EQ 0.
      quantityngc = lv_confirmedyieldqty - quantity.
    ENDIF.

    producthierachy1 = ls_producthierachy-producthierachy1.
    producthierachy2 = ls_producthierachy-producthierachy2.
    producthierachy3 = ls_producthierachy-producthierachy3.
    producthierachy4 = ls_producthierachy-producthierachy4.
    producthierachy5 = ls_producthierachy-producthierachy5.
    producthierachy6 = ls_producthierachy-producthierachy6.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
*    zcl_cobadicfl_mfgorder=>get_data_order(
*      EXPORTING
*        i_order          = '010140000005'
*        i_item           = '0001'
*      IMPORTING
*        producthierachy1 = DATA(lv_prdhie1)
*    ).
  ENDMETHOD.
ENDCLASS.

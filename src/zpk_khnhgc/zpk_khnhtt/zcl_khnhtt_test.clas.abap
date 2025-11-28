CLASS zcl_khnhtt_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_khnhtt_test IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.


    DATA lt_plant TYPE zcl_khnhtt=>tt_ranges.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = '6711' ) TO lt_plant.

    DATA lt_hierarchy TYPE zcl_khnhtt=>tt_ranges.
    APPEND VALUE #( sign = 'I' option = 'CP' low = '*' ) TO lt_hierarchy.

    DATA lv_monthfrom TYPE zde_period VALUE '202502'.

    DATA lt_result TYPE zcl_khnhtt=>gty_khnhtt.

    zcl_khnhtt=>get_ns_thang(
      EXPORTING
        ir_hierarchy = lt_hierarchy
        ir_plant     = lt_plant
        lv_monthfr   = lv_monthfrom
      IMPORTING
        e_ns_thang   = lt_result ).


  ENDMETHOD.

ENDCLASS.

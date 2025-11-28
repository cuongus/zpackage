CLASS zcx_ads_xml DEFINITION PUBLIC
  INHERITING FROM cx_static_check
  CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS cx_demo_xml_access TYPE zde_char32 VALUE 'FA163EE47BDD1EDA9FDD6BD8B822FA17' ##NO_TEXT.
    CLASS-METHODS create
      IMPORTING
        textid          LIKE textid
        previous        LIKE previous
        text_1          TYPE string
        text            TYPE string
      RETURNING
        VALUE(r_result) TYPE REF TO zcx_ads_xml.

    DATA text TYPE string .



    METHODS constructor
      IMPORTING
        textid   LIKE textid OPTIONAL
        previous LIKE previous OPTIONAL
        text     TYPE string OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCX_ADS_XML IMPLEMENTATION.


  METHOD create.

    r_result = NEW #(
      textid   = textid
      previous = previous
      text     = text_1
    ).

    r_result->text = text.

  ENDMETHOD.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( textid = textid previous = previous ).

    me->text = text.

  ENDMETHOD.
ENDCLASS.

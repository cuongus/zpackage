CLASS zcl_numfmt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS to_eu
      IMPORTING amount      TYPE decfloat34
                currency    TYPE waers
                i_sign      TYPE abap_boolean
      RETURNING VALUE(text) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_NUMFMT IMPLEMENTATION.


  METHOD to_eu.
    " 1) Keep sign and work with absolute
    DATA sign TYPE string VALUE ''.
    DATA abs  TYPE decfloat34.
    IF amount < 0.
      sign = '-'.
      abs  = - amount.
    ELSE.
      abs = amount.
    ENDIF.

    DATA(decimals) = COND i( WHEN currency = 'VND' THEN 0 ELSE 2 ).

    " 2) Normalize to a plain string with exactly 2 decimals (no grouping)
    DATA s TYPE string.
    s = |{ abs DECIMALS = decimals }|.           " e.g. '7876.09' or '7876,09' (locale)
    IF s CS ',' AND s NS '.'.
      REPLACE ALL OCCURRENCES OF ',' IN s WITH '.'. " normalize decimal to '.'
    ENDIF.

    " 3) Split integer/decimal parts
    DATA int_part TYPE string.
    DATA frac_part TYPE string.
    SPLIT s AT '.' INTO int_part frac_part.
    IF frac_part IS INITIAL. frac_part = '00'. ENDIF.

    " 4) Add thousand separators '.' to int_part
    DATA grouped TYPE string VALUE ''.
    DATA i TYPE i.
    DO strlen( int_part ) TIMES.
      i = strlen( int_part ) - sy-index.
      grouped = int_part+i(1) && grouped.
      IF ( ( sy-index MOD 3 ) = 0 ) AND ( i > 0 ).
        grouped = '.' && grouped.
      ENDIF.
    ENDDO.
    IF grouped IS INITIAL. grouped = '0'. ENDIF.

    " 5) Join with decimal comma and re-apply sign
    IF i_sign = abap_true.
      IF currency NE 'VND'.
        text = sign && grouped && ',' && frac_part.
      ELSE.
        text = sign && grouped .
      ENDIF.
    ELSE.
      IF currency NE 'VND'.
        text = grouped && ',' && frac_part.
      ELSE.
        text = grouped.
      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.

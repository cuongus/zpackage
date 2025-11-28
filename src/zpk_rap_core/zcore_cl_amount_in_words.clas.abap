CLASS zcore_cl_amount_in_words DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    INTERFACES if_http_service_extension.
    CONSTANTS:
      method_post TYPE string VALUE 'POST',
      method_get  TYPE string VALUE 'GET'.
    CLASS-METHODS:   read_amount IMPORTING i_amount          TYPE fins_vwcur12
                                           i_waers           TYPE waers
                                           i_lang            TYPE any DEFAULT 'VI'
                                 RETURNING VALUE(e_in_words) TYPE string,

      read_amount_new IMPORTING i_amount          TYPE fins_vwcur12
                                i_waers           TYPE waers
                                i_lang            TYPE any DEFAULT 'VI'
                      RETURNING VALUE(e_in_words) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ts_get_request,
        amount TYPE string,
        waers  TYPE string,
        lang   TYPE string,
      END OF ts_get_request,
      BEGIN OF ts_get_response,
        result TYPE string,
      END OF ts_get_response.
    DATA:
      request_method TYPE string,
      request_body   TYPE string,
      response_body  TYPE string,
      request_data   TYPE ts_get_request,
      response_data  TYPE ts_get_response.

    CLASS-METHODS:
      spell_amount_vi IMPORTING number        TYPE any
                      RETURNING VALUE(result) TYPE string,
      spell_amount_en IMPORTING number        TYPE any
                      RETURNING VALUE(result) TYPE string,
      read_single_number IMPORTING number        TYPE any
                                   lang          TYPE any
                         RETURNING VALUE(result) TYPE string.
ENDCLASS.



CLASS ZCORE_CL_AMOUNT_IN_WORDS IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    request_method = request->get_header_field( i_name = '~request_method' ).
    request_body = request->get_text( ).

    CASE request_method.
      WHEN method_get.
      WHEN method_post.
        DATA:
          i_waers  TYPE waers,
          i_amount TYPE fins_vwcur12,
          i_langu  TYPE string.

        TRY.
            xco_cp_json=>data->from_string( request_body )->apply( VALUE #(
          ( xco_cp_json=>transformation->camel_case_to_underscore )
          ( xco_cp_json=>transformation->boolean_to_abap_bool ) )
           )->write_to( REF #( request_data ) ).

            i_waers  = request_data-waers.
            i_amount = request_data-amount.
            i_langu  = request_data-lang.
            response_data-result = me->read_amount( i_waers  = i_waers
                                                    i_amount = i_amount
                                                    i_lang   = i_langu ).

            response_body = xco_cp_json=>data->from_abap( response_data )->apply( VALUE #(
            ( xco_cp_json=>transformation->underscore_to_pascal_case )
            ) )->to_string( ).

            response->set_text( i_text = response_body ).
          CATCH cx_root INTO DATA(lx_root).
            response->set_text( i_text = |{ lx_root->get_longtext( ) }| ).
            RETURN.
        ENDTRY.

    ENDCASE.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA: lt_amount TYPE TABLE OF fins_vwcur12.

*    APPEND '1.11' TO lt_amount.
*    APPEND '1.10' TO lt_amount.
*    APPEND '1.01' TO lt_amount.
*    APPEND '41.11' TO lt_amount.
*    APPEND '111' TO lt_amount.
*    APPEND '101' TO lt_amount.
*    APPEND '100' TO lt_amount.
*    APPEND '1111' TO lt_amount.
*    APPEND '1101' TO lt_amount.
*    APPEND '1011' TO lt_amount.
*    APPEND '1001' TO lt_amount.
*    APPEND '1000' TO lt_amount.
*    APPEND '1060' TO lt_amount.
    APPEND '64020.74' TO lt_amount.
*    APPEND '100000' TO lt_amount.
*    APPEND '909099009991' TO lt_amount.

    LOOP AT lt_amount INTO DATA(lv_amount).
      out->write( |{ lv_amount }| ).
*      out->write( |{ zcore_cl_amount_in_words=>read_amount_new( i_amount = lv_amount i_waers = 'VND' i_lang = 'VI' ) }| ).
*      out->write( |{ zcore_cl_amount_in_words=>read_amount( i_amount = lv_amount i_waers = 'VND' i_lang = 'EN' ) }| ).
      out->write( |{ zcore_cl_amount_in_words=>read_amount_new( i_amount = lv_amount i_waers = 'USD' i_lang = 'VI' ) }| ).
*      out->write( |{ zcore_cl_amount_in_words=>read_amount( i_amount = lv_amount i_waers = 'USD' i_lang = 'EN' ) }| ).
    ENDLOOP.
  ENDMETHOD.


  METHOD read_amount.
    DATA: lv_ext_num         TYPE string,
          lv_decimal         TYPE c,
          lv_integer_part    TYPE string,
          lv_fractional_part TYPE string.

    DATA: lv_amount_temp    TYPE n LENGTH 20,
          lv_integ_part_str TYPE string,
          lv_fract_part_str TYPE string,
          lv_off            TYPE int4.

    DATA: lv_first_char TYPE c LENGTH 1.

    lv_ext_num = i_amount.
    CONDENSE lv_ext_num.

    CASE i_lang.
      WHEN 'VI'.
        IF lv_ext_num = '0.00' OR lv_ext_num IS INITIAL.
          e_in_words = 'Không'.
        ELSE.
          lv_decimal = '.'.
          SPLIT lv_ext_num AT lv_decimal INTO lv_integer_part lv_fractional_part.

*          process integer part
          CONDENSE lv_integer_part.
          lv_amount_temp = lv_integer_part.
          IF lv_amount_temp > 0.
            lv_integ_part_str = spell_amount_vi( EXPORTING number = lv_integer_part ).
          ELSE.
            CLEAR: lv_integ_part_str.
          ENDIF.

*          process fractional part
          CONDENSE lv_fractional_part.
          lv_amount_temp = lv_fractional_part.
          IF lv_amount_temp > 0.
            lv_fract_part_str = spell_amount_vi( EXPORTING number = lv_amount_temp ).
            IF i_waers = 'VND'.
              DO strlen( lv_fractional_part ) TIMES.
                IF lv_fractional_part+lv_off(1) EQ '0'.
                  CONCATENATE 'không' lv_fract_part_str INTO lv_fract_part_str SEPARATED BY space.
                ELSE.
                  EXIT.
                ENDIF.
                lv_off += 1.
              ENDDO.
              CLEAR: lv_off.
            ENDIF.
          ELSE.
            CLEAR: lv_fract_part_str.
          ENDIF.

          IF lv_integ_part_str IS NOT INITIAL AND
             lv_fract_part_str IS NOT INITIAL.
            e_in_words = |{ lv_integ_part_str } lẻ { lv_fract_part_str }|.
          ELSEIF lv_integ_part_str IS NOT INITIAL.
            e_in_words = |{ lv_integ_part_str }|.
          ELSE.
            e_in_words = |không lẻ { lv_fract_part_str }|.
          ENDIF.
        ENDIF.
        IF i_waers = 'VND'.
          e_in_words = |{ e_in_words } đồng|.
        ELSEIF i_waers = 'USD'.
          e_in_words = |{ e_in_words } đô la Mỹ|.
        ENDIF.
      WHEN 'EN'.
        IF lv_ext_num = '0.00' OR lv_ext_num IS INITIAL.
          IF i_waers = 'VND'.
            e_in_words = 'zero Vietnamese dong'.
          ELSEIF i_waers = 'USD'.
            e_in_words = 'zero dollar'.
          ENDIF.
        ELSE.
          lv_decimal = '.'.
          SPLIT lv_ext_num AT lv_decimal INTO lv_integer_part lv_fractional_part.

*          process integer part
          CONDENSE lv_integer_part.
          lv_amount_temp = lv_integer_part.
          IF lv_amount_temp > 0.
            lv_integ_part_str = spell_amount_en( EXPORTING number = lv_integer_part ).
          ELSE.
            CLEAR: lv_integ_part_str.
          ENDIF.

*          process fractional part
          CONDENSE lv_fractional_part.
          lv_amount_temp = lv_fractional_part.
          IF lv_amount_temp > 0.
            lv_fract_part_str = spell_amount_en( EXPORTING number = lv_amount_temp ).
            IF i_waers = 'VND'.
              DO strlen( lv_fractional_part ) TIMES.
                IF lv_fractional_part+lv_off(1) EQ '0'.
                  CONCATENATE 'zero' lv_fract_part_str INTO lv_fract_part_str SEPARATED BY space.
                ELSE.
                  EXIT.
                ENDIF.
                lv_off += 1.
              ENDDO.
              CLEAR: lv_off.
            ENDIF.
          ELSE.
            CLEAR: lv_fract_part_str.
          ENDIF.

          IF lv_integ_part_str IS NOT INITIAL AND
             lv_fract_part_str IS NOT INITIAL.
            IF i_waers = 'VND'.
              e_in_words = |{ lv_integ_part_str } point { lv_fract_part_str } Vietnamese dong|.
            ELSEIF i_waers = 'USD'.
              IF lv_integ_part_str EQ 'one' AND
                 lv_fract_part_str EQ 'one'.
                e_in_words = |{ lv_integ_part_str } dollar and { lv_fract_part_str } cent|.
              ELSEIF lv_integ_part_str EQ 'one'.
                e_in_words = |{ lv_integ_part_str } dollar and { lv_fract_part_str } cents|.
              ELSEIF lv_fract_part_str EQ 'one'.
                e_in_words = |{ lv_integ_part_str } dollars and { lv_fract_part_str } cent|.
              ELSE.
                e_in_words = |{ lv_integ_part_str } dollars and { lv_fract_part_str } cents|.
              ENDIF.
            ENDIF.
          ELSEIF lv_integ_part_str IS NOT INITIAL.
            IF i_waers = 'VND'.
              e_in_words = |{ lv_integ_part_str } Vietnamese dong|.
            ELSEIF i_waers = 'USD'.
              IF lv_integ_part_str EQ 'one'.
                e_in_words = |{ lv_integ_part_str } dollar|.
              ELSE.
                e_in_words = |{ lv_integ_part_str } dollars|.
              ENDIF.
            ENDIF.
          ELSE.
            IF i_waers = 'VND'.
              e_in_words = |zero point { lv_fract_part_str } Vietnamese dong|.
            ELSEIF i_waers = 'USD'.
              IF lv_fract_part_str EQ 'one'.
                e_in_words = |{ lv_fract_part_str } cent|.
              ELSE.
                e_in_words = |{ lv_fract_part_str } cents|.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDCASE.

*    capitalize first character
    CONDENSE e_in_words.
    lv_first_char = e_in_words(1).
    TRANSLATE lv_first_char TO UPPER CASE.
    e_in_words = |{ lv_first_char }{ substring( val = e_in_words off = 1 len = strlen( e_in_words ) - 1 ) }|.
  ENDMETHOD.


  METHOD read_single_number.
    CASE lang.
      WHEN 'VI'.
        CASE number.
          WHEN '0'.
            result = ''.
          WHEN '1'.
            result = 'một'.
          WHEN '2'.
            result = 'hai'.
          WHEN '3'.
            result = 'ba'.
          WHEN '4'.
            result = 'bốn'.
          WHEN '5'.
            result = 'năm'.
          WHEN '6'.
            result = 'sáu'.
          WHEN '7'.
            result = 'bảy'.
          WHEN '8'.
            result = 'tám'.
          WHEN '9'.
            result = 'chín'.
          WHEN '10'.
            result = 'mười'.
          WHEN '11'.
            result = 'mười một'.
          WHEN '12'.
            result = 'mười hai'.
          WHEN '13'.
            result = 'mười ba'.
          WHEN '14'.
            result = 'mười bốn'.
          WHEN '15'.
            result = 'mười lăm'.
          WHEN '16'.
            result = 'mười sáu'.
          WHEN '17'.
            result = 'mười bảy'.
          WHEN '18'.
            result = 'mười tám'.
          WHEN '19'.
            result = 'mười chín'.
          WHEN '20'.
            result = 'hai mươi'.
          WHEN '30'.
            result = 'ba mươi'.
          WHEN '40'.
            result = 'bốn mươi'.
          WHEN '50'.
            result = 'năm mươi'.
          WHEN '60'.
            result = 'sáu mươi'.
          WHEN '70'.
            result = 'bảy mươi'.
          WHEN '80'.
            result = 'tám mươi'.
          WHEN '90'.
            result = 'chín mươi'.
        ENDCASE.
      WHEN 'EN'.
        CASE number.
          WHEN '0'.
            result = ''.
          WHEN '1'.
            result = 'one'.
          WHEN '2'.
            result = 'two'.
          WHEN '3'.
            result = 'three'.
          WHEN '4'.
            result = 'four'.
          WHEN '5'.
            result = 'five'.
          WHEN '6'.
            result = 'six'.
          WHEN '7'.
            result = 'seven'.
          WHEN '8'.
            result = 'eight'.
          WHEN '9'.
            result = 'nine'.
          WHEN '10'.
            result = 'ten'.
          WHEN '11'.
            result = 'eleven'.
          WHEN '12'.
            result = 'twelve'.
          WHEN '13'.
            result = 'thirteen'.
          WHEN '14'.
            result = 'fourteen'.
          WHEN '15'.
            result = 'fifteen'.
          WHEN '16'.
            result = 'sixteen'.
          WHEN '17'.
            result = 'seventeen'.
          WHEN '18'.
            result = 'eighteen'.
          WHEN '19'.
            result = 'nineteen'.
          WHEN '20'.
            result = 'twenty'.
          WHEN '30'.
            result = 'thirty'.
          WHEN '40'.
            result = 'forty'.
          WHEN '50'.
            result = 'fifty'.
          WHEN '60'.
            result = 'sixty'.
          WHEN '70'.
            result = 'seventy'.
          WHEN '80'.
            result = 'eighty'.
          WHEN '90'.
            result = 'ninety'.
        ENDCASE.
    ENDCASE.
  ENDMETHOD.


  METHOD spell_amount_en.
*    DATA: lv_amount1 TYPE int4,
*          lv_amount2 TYPE int4,
*          lv_return  TYPE string,
*          lv_return1 TYPE string,
*          lv_return2 TYPE string.
*    IF number = 0.
*      "lv_return = 'zero'.
*    ELSEIF number < 20.
*      lv_return = read_single_number( EXPORTING number = number
*                                                lang   = 'EN' ).
*      "return units[number]
*    ELSEIF number < 100.
*      lv_amount1 = number DIV 10.
*      lv_amount2 = number MOD 10.
*      lv_amount1 = lv_amount1 * 10.
*      lv_return1 = read_single_number( EXPORTING number = lv_amount1
*                                                 lang   = 'EN' ).
*      lv_return2 = read_single_number( EXPORTING number = lv_amount2
*                                                 lang   = 'EN' ).
*      CONCATENATE lv_return1 lv_return2 INTO lv_return SEPARATED BY space.
*      "return tens[number // 10] + (" " + units[number % 10] if number % 10 != 0 else "")
*    ELSEIF number < 1000.
*      lv_amount1 = number DIV 100.
*      lv_amount2 = number MOD 100.
*      lv_return1 = read_single_number( EXPORTING number = lv_amount1
*                                                 lang   = 'EN' ).
*      lv_return2 = spell_amount_en( EXPORTING number = lv_amount2 ).
*      CONCATENATE lv_return1 'hundred' lv_return2 INTO lv_return SEPARATED BY space.
*      "return units[number // 100] + " hundred" + (" and " + number_to_words(number % 100) if number % 100 != 0 else "")
*    ELSEIF number < 1000000.
*      lv_amount1 = number DIV 1000.
*      lv_amount2 = number MOD 1000.
*      lv_return1 = spell_amount_en( EXPORTING number = lv_amount1 ).
*      lv_return2 = spell_amount_en( EXPORTING number = lv_amount2 ).
*      CONCATENATE lv_return1 'thousand' lv_return2 INTO lv_return SEPARATED BY space.
*      "return number_to_words(number // 1000) + " thousand" + (" " + number_to_words(number % 1000) if number % 1000 != 0 else "")
*    ELSEIF number < 1000000000.
*      lv_amount1 = number DIV 1000000.
*      lv_amount2 = number MOD 1000000.
*      lv_return1 = spell_amount_en( EXPORTING number = lv_amount1 ).
*      lv_return2 = spell_amount_en( EXPORTING number = lv_amount2 ).
*      CONCATENATE lv_return1 'million' lv_return2 INTO lv_return SEPARATED BY space.
*      "return number_to_words(number // 1000000) + " million" + (" " + number_to_words(number % 1000000) if number % 1000000 != 0 else "")
*    ELSEIF number < 1000000000000.
*      lv_amount1 = number DIV 1000000000.
*      lv_amount2 = number MOD 1000000000.
*      lv_return1 = spell_amount_en( EXPORTING number = lv_amount1 ).
*      lv_return2 = spell_amount_en( EXPORTING number = lv_amount2 ).
*      CONCATENATE lv_return1 'billion' lv_return2 INTO lv_return SEPARATED BY space.
*      "return number_to_words(number // 1000000000) + " billion" + (" " + number_to_words(number % 1000000000) if number % 1000000000 != 0 else "")
*    ELSE.
*      lv_return = 'Number out of range'.
*      "return "Number out of range"
*    ENDIF.

    " Mở rộng tới trillion / quadrillion / quintillion
    DATA: lv_amount1 TYPE int8,
          lv_amount2 TYPE int8,
          lv_return  TYPE string,
          lv_return1 TYPE string,
          lv_return2 TYPE string.

    IF number = 0.
      "lv_return = 'zero'.
    ELSEIF number < 20.
      lv_return = read_single_number( EXPORTING number = number lang = 'EN' ).

    ELSEIF number < 100.
      lv_amount1 = number DIV 10.
      lv_amount2 = number MOD 10.
      lv_amount1 = lv_amount1 * 10.
      lv_return1 = read_single_number( EXPORTING number = lv_amount1 lang = 'EN' ).
      lv_return2 = read_single_number( EXPORTING number = lv_amount2 lang = 'EN' ).
      CONCATENATE lv_return1 lv_return2 INTO lv_return SEPARATED BY space.

    ELSEIF number < 1000.
      lv_amount1 = number DIV 100.
      lv_amount2 = number MOD 100.
      lv_return1 = read_single_number( EXPORTING number = lv_amount1 lang = 'EN' ).
      lv_return2 = spell_amount_en( EXPORTING number = lv_amount2 ).
      CONCATENATE lv_return1 'hundred' lv_return2 INTO lv_return SEPARATED BY space.

    ELSEIF number < 1000000.
      lv_amount1 = number DIV 1000.
      lv_amount2 = number MOD 1000.
      lv_return1 = spell_amount_en( EXPORTING number = lv_amount1 ).
      lv_return2 = spell_amount_en( EXPORTING number = lv_amount2 ).
      CONCATENATE lv_return1 'thousand' lv_return2 INTO lv_return SEPARATED BY space.

    ELSEIF number < 1000000000.
      lv_amount1 = number DIV 1000000.
      lv_amount2 = number MOD 1000000.
      lv_return1 = spell_amount_en( EXPORTING number = lv_amount1 ).
      lv_return2 = spell_amount_en( EXPORTING number = lv_amount2 ).
      CONCATENATE lv_return1 'million' lv_return2 INTO lv_return SEPARATED BY space.

    ELSEIF number < 1000000000000.                 " < 10^12
      lv_amount1 = number DIV 1000000000.
      lv_amount2 = number MOD 1000000000.
      lv_return1 = spell_amount_en( EXPORTING number = lv_amount1 ).
      lv_return2 = spell_amount_en( EXPORTING number = lv_amount2 ).
      CONCATENATE lv_return1 'billion' lv_return2 INTO lv_return SEPARATED BY space.

    ELSEIF number < 1000000000000000.              " < 10^15
      lv_amount1 = number DIV 1000000000000.
      lv_amount2 = number MOD 1000000000000.
      lv_return1 = spell_amount_en( EXPORTING number = lv_amount1 ).
      lv_return2 = spell_amount_en( EXPORTING number = lv_amount2 ).
      CONCATENATE lv_return1 'trillion' lv_return2 INTO lv_return SEPARATED BY space.

    ELSEIF number < 1000000000000000000.           " < 10^18
      lv_amount1 = number DIV 1000000000000000.
      lv_amount2 = number MOD 1000000000000000.
      lv_return1 = spell_amount_en( EXPORTING number = lv_amount1 ).
      lv_return2 = spell_amount_en( EXPORTING number = lv_amount2 ).
      CONCATENATE lv_return1 'quadrillion' lv_return2 INTO lv_return SEPARATED BY space.

    ELSE.
      lv_return = 'Number out of range'.
    ENDIF.

    RETURN lv_return.
  ENDMETHOD.


  METHOD spell_amount_vi.
*    DATA: lv_amount1 TYPE int4,
*          lv_amount2 TYPE int4,
*          lv_return  TYPE string,
*          lv_return1 TYPE string,
*          lv_return2 TYPE string,
*          lv_string  TYPE string,
*          lv_off     TYPE int4.
*    lv_string = number.
*    CONDENSE lv_string.
*
*    IF number = 0.
*      "lv_return = 'không'.
*    ELSEIF number < 20.
*      lv_return = read_single_number( EXPORTING number = number
*                                                lang   = 'VI' ).
*    ELSEIF number < 100 AND lv_string+1(1) EQ '1'.
*      lv_return = read_single_number( EXPORTING number = number - 1
*                                                lang   = 'VI' ).
*      CONCATENATE lv_return 'mốt' INTO lv_return SEPARATED BY space.
*    ELSEIF number < 100.
*      lv_amount1 = number DIV 10.
*      lv_amount2 = number MOD 10.
*      lv_amount1 = lv_amount1 * 10.
*      lv_return1 = read_single_number( EXPORTING number = lv_amount1
*                                                 lang   = 'VI' ).
*      lv_return2 = read_single_number( EXPORTING number = lv_amount2
*                                                 lang   = 'VI' ).
*      CONCATENATE lv_return1 lv_return2 INTO lv_return SEPARATED BY space.
*      "return tens[number // 10] + (" " + units[number % 10] if number % 10 != 0 else "")
*    ELSEIF number < 1000.
*      lv_amount1 = number DIV 100.
*      lv_amount2 = number MOD 100.
*      lv_return1 = read_single_number( EXPORTING number = lv_amount1
*                                                 lang   = 'VI' ).
*      lv_return2 = spell_amount_vi( EXPORTING number = lv_amount2 ).
*      IF lv_string+1(1) EQ '0' AND
*         lv_string+2(1) NE '0'.
*        CONCATENATE lv_return1 'trăm linh' lv_return2 INTO lv_return SEPARATED BY space.
*      ELSE.
*        CONCATENATE lv_return1 'trăm' lv_return2 INTO lv_return SEPARATED BY space.
*      ENDIF.
*      "return units[number // 100] + " trăm" + (" and " + number_to_words(number % 100) if number % 100 != 0 else "")
*    ELSEIF number < 1000000.
*      lv_amount1 = number DIV 1000.
*      lv_amount2 = number MOD 1000.
*      lv_return1 = spell_amount_vi( EXPORTING number = lv_amount1 ).
*      lv_return2 = spell_amount_vi( EXPORTING number = lv_amount2 ).
*      lv_off = strlen( lv_string ) - 3.
*      IF lv_string+lv_off(1) EQ '0'.
*        lv_off += 1.
*        IF lv_string+lv_off(1) EQ '0'.
*          lv_off += 1.
*          IF lv_string+lv_off(1) EQ '0'.
*            CONCATENATE lv_return1 'nghìn' lv_return2 INTO lv_return SEPARATED BY space.
*          ELSE.
*            CONCATENATE lv_return1 'nghìn không trăm linh' lv_return2 INTO lv_return SEPARATED BY space.
*          ENDIF.
*        ELSE.
*          CONCATENATE lv_return1 'nghìn không trăm' lv_return2 INTO lv_return SEPARATED BY space.
*        ENDIF.
*      ELSE.
*        CONCATENATE lv_return1 'nghìn' lv_return2 INTO lv_return SEPARATED BY space.
*      ENDIF.
*      "return number_to_words(number // 1000) + " nghìn" + (" " + number_to_words(number % 1000) if number % 1000 != 0 else "")
*    ELSEIF number < 1000000000.
*      lv_amount1 = number DIV 1000000.
*      lv_amount2 = number MOD 1000000.
*      lv_return1 = spell_amount_vi( EXPORTING number = lv_amount1 ).
*      lv_return2 = spell_amount_vi( EXPORTING number = lv_amount2 ).
*      CONCATENATE lv_return1 'triệu' lv_return2 INTO lv_return SEPARATED BY space.
*      "return number_to_words(number // 1000000) + " triệu" + (" " + number_to_words(number % 1000000) if number % 1000000 != 0 else "")
*    ELSEIF number < 1000000000000.
*      lv_amount1 = number DIV 1000000000.
*      lv_amount2 = number MOD 1000000000.
*      lv_return1 = spell_amount_vi( EXPORTING number = lv_amount1 ).
*      lv_return2 = spell_amount_vi( EXPORTING number = lv_amount2 ).
*      CONCATENATE lv_return1 'tỷ' lv_return2 INTO lv_return SEPARATED BY space.
*      "return number_to_words(number // 1000000000) + " tỷ" + (" " + number_to_words(number % 1000000000) if number % 1000000000 != 0 else "")
*    ELSE.
*      lv_return = 'Số tiền quá lớn'.
*      "return "Number out of range"
*    ENDIF.

    " Hỗ trợ tới 10^18 (tỷ tỷ)
    DATA: lv_amount1 TYPE int8,
          lv_amount2 TYPE int8,
          lv_return  TYPE string,
          lv_return1 TYPE string,
          lv_return2 TYPE string,
          lv_string  TYPE string,
          lv_off     TYPE int4.

    lv_string = number.
    CONDENSE lv_string.

    IF number = 0.
      "lv_return = 'không'.
    ELSEIF number < 20.
      lv_return = read_single_number( EXPORTING number = number lang = 'VI' ).

    ELSEIF number < 100 AND lv_string+1(1) EQ '1'.
      lv_return = read_single_number( EXPORTING number = number - 1 lang = 'VI' ).
      CONCATENATE lv_return 'mốt' INTO lv_return SEPARATED BY space.

    ELSEIF number < 100.
      lv_amount1 = number DIV 10.
      lv_amount2 = number MOD 10.
      lv_amount1 = lv_amount1 * 10.
      lv_return1 = read_single_number( EXPORTING number = lv_amount1 lang = 'VI' ).
      lv_return2 = read_single_number( EXPORTING number = lv_amount2 lang = 'VI' ).
      CONCATENATE lv_return1 lv_return2 INTO lv_return SEPARATED BY space.

    ELSEIF number < 1000.
      lv_amount1 = number DIV 100.
      lv_amount2 = number MOD 100.
      lv_return1 = read_single_number( EXPORTING number = lv_amount1 lang = 'VI' ).
      lv_return2 = spell_amount_vi( EXPORTING number = lv_amount2 ).
      IF lv_string+1(1) EQ '0' AND lv_string+2(1) NE '0'.
        CONCATENATE lv_return1 'trăm linh' lv_return2 INTO lv_return SEPARATED BY space.
      ELSE.
        CONCATENATE lv_return1 'trăm' lv_return2 INTO lv_return SEPARATED BY space.
      ENDIF.

    ELSEIF number < 1000000.                       " < 10^6
      lv_amount1 = number DIV 1000.
      lv_amount2 = number MOD 1000.
      lv_return1 = spell_amount_vi( EXPORTING number = lv_amount1 ).
      lv_return2 = spell_amount_vi( EXPORTING number = lv_amount2 ).
      lv_off = strlen( lv_string ) - 3.
      IF lv_string+lv_off(1) EQ '0'.
        lv_off += 1.
        IF lv_string+lv_off(1) EQ '0'.
          lv_off += 1.
          IF lv_string+lv_off(1) EQ '0'.
            CONCATENATE lv_return1 'nghìn' lv_return2 INTO lv_return SEPARATED BY space.
          ELSE.
            CONCATENATE lv_return1 'nghìn không trăm linh' lv_return2 INTO lv_return SEPARATED BY space.
          ENDIF.
        ELSE.
          CONCATENATE lv_return1 'nghìn không trăm' lv_return2 INTO lv_return SEPARATED BY space.
        ENDIF.
      ELSE.
        CONCATENATE lv_return1 'nghìn' lv_return2 INTO lv_return SEPARATED BY space.
      ENDIF.

    ELSEIF number < 1000000000.                    " < 10^9
      lv_amount1 = number DIV 1000000.
      lv_amount2 = number MOD 1000000.
      lv_return1 = spell_amount_vi( EXPORTING number = lv_amount1 ).
      lv_return2 = spell_amount_vi( EXPORTING number = lv_amount2 ).
      CONCATENATE lv_return1 'triệu' lv_return2 INTO lv_return SEPARATED BY space.

    ELSEIF number < 1000000000000.                 " < 10^12
      lv_amount1 = number DIV 1000000000.
      lv_amount2 = number MOD 1000000000.
      lv_return1 = spell_amount_vi( EXPORTING number = lv_amount1 ).
      lv_return2 = spell_amount_vi( EXPORTING number = lv_amount2 ).
      CONCATENATE lv_return1 'tỷ' lv_return2 INTO lv_return SEPARATED BY space.

    ELSEIF number < 1000000000000000.              " < 10^15  (nghìn tỷ)
      lv_amount1 = number DIV 1000000000000.
      lv_amount2 = number MOD 1000000000000.
      lv_return1 = spell_amount_vi( EXPORTING number = lv_amount1 ).
      lv_return2 = spell_amount_vi( EXPORTING number = lv_amount2 ).
      CONCATENATE lv_return1 'nghìn tỷ' lv_return2 INTO lv_return SEPARATED BY space.

    ELSEIF number < 1000000000000000000.           " < 10^18  (triệu tỷ)
      lv_amount1 = number DIV 1000000000000000.
      lv_amount2 = number MOD 1000000000000000.
      lv_return1 = spell_amount_vi( EXPORTING number = lv_amount1 ).
      lv_return2 = spell_amount_vi( EXPORTING number = lv_amount2 ).
      CONCATENATE lv_return1 'triệu tỷ' lv_return2 INTO lv_return SEPARATED BY space.

    ELSE.
      lv_return = 'Số tiền quá lớn'.  " > 10^18 mới báo
    ENDIF.

    RETURN lv_return.
  ENDMETHOD.


  METHOD read_amount_new.
    DATA: lv_ext_num         TYPE string,
          lv_decimal         TYPE c,
          lv_integer_part    TYPE string,
          lv_fractional_part TYPE string.

    DATA: lv_amount_temp    TYPE n LENGTH 20,
          lv_integ_part_str TYPE string,
          lv_fract_part_str TYPE string,
          lv_off            TYPE int4.

    DATA: lv_first_char TYPE c LENGTH 1.

    lv_ext_num = i_amount.
    CONDENSE lv_ext_num.

    CASE i_lang.
      WHEN 'VI'.
        IF lv_ext_num = '0.00' OR lv_ext_num IS INITIAL.
          e_in_words = 'Không'.
        ELSE.
          lv_decimal = '.'.
          SPLIT lv_ext_num AT lv_decimal INTO lv_integer_part lv_fractional_part.

          " --- PHẦN NGUYÊN ---
          CONDENSE lv_integer_part.
          lv_amount_temp = lv_integer_part.
          IF lv_amount_temp > 0.
            lv_integ_part_str = spell_amount_vi( EXPORTING number = lv_integer_part ).
          ELSE.
            CLEAR lv_integ_part_str.
          ENDIF.

          " --- PHẦN THẬP PHÂN ---
          CONDENSE lv_fractional_part.

          IF i_waers = 'USD' OR i_waers = 'EUR' OR i_waers = 'CNY'.
            DATA: lv_tien  TYPE string,
                  lv_donvi TYPE string.
            CASE i_waers.
              WHEN 'USD'.
                lv_tien = 'đô la Mỹ'.
                lv_donvi = 'xu'.

              WHEN 'EUR'.
                lv_tien = 'euro'.
                lv_donvi = 'xu'.
              WHEN 'CNY'.
                lv_tien = 'tệ'.
                lv_donvi = 'hào'.

            ENDCASE.
            " USD: luôn xét 2 chữ số thập phân (xu)
            DATA(lv_frac_norm) = lv_fractional_part.
            IF lv_frac_norm IS INITIAL.
              lv_frac_norm = '00'.
            ELSEIF strlen( lv_frac_norm ) = 1.
              CONCATENATE lv_frac_norm '0' INTO lv_frac_norm.
            ELSEIF strlen( lv_frac_norm ) > 2.
              lv_frac_norm = lv_frac_norm(2).
            ENDIF.

            lv_amount_temp = lv_frac_norm.
            IF lv_amount_temp > 0.
              lv_fract_part_str = spell_amount_vi( EXPORTING number = lv_amount_temp ).
            ELSE.
              CLEAR lv_fract_part_str.
            ENDIF.

            " --- GHÉP CÂU CHO USD ---
            IF lv_integ_part_str IS NOT INITIAL AND lv_fract_part_str IS NOT INITIAL.
              e_in_words = |{ lv_integ_part_str } { lv_tien } và { lv_fract_part_str } { lv_donvi }|.
            ELSEIF lv_integ_part_str IS NOT INITIAL.
              e_in_words = |{ lv_integ_part_str } { lv_tien }|.
            ELSE.
              " hiếm khi xảy ra: chỉ có phần xu
              e_in_words = |{ lv_fract_part_str } { lv_donvi }|.
            ENDIF.

          ELSE. " VND hoặc các đồng tiền khác (giữ cách đọc cũ)
            lv_amount_temp = lv_fractional_part.
            IF lv_amount_temp > 0.
              lv_fract_part_str = spell_amount_vi( EXPORTING number = lv_amount_temp ).
              IF i_waers = 'VND'.
                DO strlen( lv_fractional_part ) TIMES.
                  IF lv_fractional_part+lv_off(1) EQ '0'.
                    CONCATENATE 'không' lv_fract_part_str INTO lv_fract_part_str SEPARATED BY space.
                  ELSE.
                    EXIT.
                  ENDIF.
                  lv_off += 1.
                ENDDO.
                CLEAR lv_off.
              ENDIF.
            ELSE.
              CLEAR lv_fract_part_str.
            ENDIF.

            IF lv_integ_part_str IS NOT INITIAL AND lv_fract_part_str IS NOT INITIAL.
              e_in_words = |{ lv_integ_part_str } lẻ { lv_fract_part_str }|.
            ELSEIF lv_integ_part_str IS NOT INITIAL.
              e_in_words = |{ lv_integ_part_str }|.
            ELSE.
              e_in_words = |không lẻ { lv_fract_part_str }|.
            ENDIF.

            IF i_waers = 'VND'.
              e_in_words = |{ e_in_words } đồng|.
            ELSEIF i_waers = 'JPY'.
              " dự phòng: nếu đi nhánh này cho USD (không nên), vẫn thêm đơn vị
              e_in_words = |{ e_in_words } yên|.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN 'EN'.
        " (giữ nguyên logic tiếng Anh hiện tại)
        IF lv_ext_num = '0.00' OR lv_ext_num IS INITIAL.
          IF i_waers = 'VND'.
            e_in_words = 'zero Vietnamese dong'.
          ELSEIF i_waers = 'USD'.
            e_in_words = 'zero dollar'.
          ENDIF.
        ELSE.
          lv_decimal = '.'.
          SPLIT lv_ext_num AT lv_decimal INTO lv_integer_part lv_fractional_part.

          CONDENSE lv_integer_part.
          lv_amount_temp = lv_integer_part.
          IF lv_amount_temp > 0.
            lv_integ_part_str = spell_amount_en( EXPORTING number = lv_integer_part ).
          ELSE.
            CLEAR lv_integ_part_str.
          ENDIF.

          CONDENSE lv_fractional_part.
          " chuẩn hoá 2 chữ số cho USD trong tiếng Anh
          IF i_waers = 'USD'.
            DATA(lv_frac_norm_en) = lv_fractional_part.
            IF lv_frac_norm_en IS INITIAL.
              lv_frac_norm_en = '00'.
            ELSEIF strlen( lv_frac_norm_en ) = 1.
              CONCATENATE lv_frac_norm_en '0' INTO lv_frac_norm_en.
            ELSEIF strlen( lv_frac_norm_en ) > 2.
              lv_frac_norm_en = lv_frac_norm_en(2).
            ENDIF.
            lv_amount_temp = lv_frac_norm_en.
          ELSE.
            lv_amount_temp = lv_fractional_part.
          ENDIF.

          DATA(lv_fract_part_en) = ``.
          IF lv_amount_temp > 0.
            lv_fract_part_en = spell_amount_en( EXPORTING number = lv_amount_temp ).
          ENDIF.

          IF lv_integ_part_str IS NOT INITIAL AND lv_fract_part_en IS NOT INITIAL.
            IF i_waers = 'VND'.
              e_in_words = |{ lv_integ_part_str } point { lv_fract_part_en } Vietnamese dong|.
            ELSEIF i_waers = 'USD'.
              IF lv_integ_part_str EQ 'one' AND lv_fract_part_en EQ 'one'.
                e_in_words = |{ lv_integ_part_str } dollar and { lv_fract_part_en } cent|.
              ELSEIF lv_integ_part_str EQ 'one'.
                e_in_words = |{ lv_integ_part_str } dollar and { lv_fract_part_en } cents|.
              ELSEIF lv_fract_part_en EQ 'one'.
                e_in_words = |{ lv_integ_part_str } dollars and { lv_fract_part_en } cent|.
              ELSE.
                e_in_words = |{ lv_integ_part_str } dollars and { lv_fract_part_en } cents|.
              ENDIF.
            ENDIF.
          ELSEIF lv_integ_part_str IS NOT INITIAL.
            IF i_waers = 'VND'.
              e_in_words = |{ lv_integ_part_str } Vietnamese dong|.
            ELSEIF i_waers = 'USD'.
              IF lv_integ_part_str EQ 'one'.
                e_in_words = |{ lv_integ_part_str } dollar|.
              ELSE.
                e_in_words = |{ lv_integ_part_str } dollars|.
              ENDIF.
            ENDIF.
          ELSE.
            IF i_waers = 'VND'.
              e_in_words = |zero point { lv_fract_part_en } Vietnamese dong|.
            ELSEIF i_waers = 'USD'.
              IF lv_fract_part_en EQ 'one'.
                e_in_words = |{ lv_fract_part_en } cent|.
              ELSE.
                e_in_words = |{ lv_fract_part_en } cents|.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDCASE.

    " Viết hoa chữ cái đầu
    CONDENSE e_in_words.
    lv_first_char = e_in_words(1).
    TRANSLATE lv_first_char TO UPPER CASE.
    e_in_words = |{ lv_first_char }{ substring( val = e_in_words off = 1 len = strlen( e_in_words ) - 1 ) }|.
  ENDMETHOD.
ENDCLASS.

CLASS zcl_http_teamworkerlist DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_ranges TYPE TABLE OF ty_range_option.

    CLASS-DATA: g_WorkerId    TYPE zc_tw_list-WorkerId,
                g_WorkCenter  TYPE zc_tw_list-WorkCenter,
                g_Plant       TYPE zc_tw_list-Plant,
                g_Shift       TYPE zc_tw_list-Shift,
                g_MachineId   TYPE zc_tw_list-MachineId,
                g_TeamId      TYPE zc_tw_list-TeamId,
                g_Postingdate TYPE zde_date.

    CLASS-DATA: g_json_string TYPE string.

    CLASS-METHODS:

      handle_get_teamworkerlist CHANGING cv_message  TYPE string,
      HANDLE_GET_MachineId CHANGING cv_message  TYPE string,
      handle_get_teamid CHANGING cv_message  TYPE string,
      HANDLE_GET_WorkerId CHANGING cv_message  TYPE string.


    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS: c_header_content TYPE string VALUE 'content-type',
               c_content_type   TYPE string VALUE 'application/json, charset=utf-8'.
ENDCLASS.



CLASS ZCL_HTTP_TEAMWORKERLIST IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    DATA: lt_parameters TYPE abap_parmbind_tab.
    DATA: ls_line LIKE LINE OF lt_parameters.
    FIELD-SYMBOLS: <lv_value> TYPE any.


    DATA: lt_parts TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    DATA(lv_req_body) = request->get_text( ).

    DATA(lv_method) = request->get_header_field( '~request_method' ).

    DATA(lv_uri) = request->get_header_field( '~request_uri' ).

    SPLIT lv_uri AT '?' INTO DATA(lv_path) DATA(lv_query_string).

    SPLIT lv_query_string AT '&' INTO TABLE lt_parts.

    LOOP AT lt_parts INTO DATA(lv_pair).
      SPLIT lv_pair AT '=' INTO DATA(lv_key) DATA(lv_val).

      CASE lv_key.
        WHEN 'name'.
          DATA(lv_name) = lv_val.
        WHEN 'WorkerId'.
          g_workerid = lv_val.
        WHEN 'WorkCenter'.
          g_workcenter = lv_val.
        WHEN 'Plant'.
          g_plant = lv_val.
        WHEN 'Shift'.
          g_shift = lv_val.
        WHEN 'MachineId'.
          g_machineid = lv_val.
        WHEN 'TeamId'.
          g_teamid = lv_val.
        WHEN 'Postingdate'.
          G_Postingdate = lv_val.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

    IF lv_method = 'post' OR lv_method = 'POST'.
*    CASE lv_name.
*      WHEN 'sinvoicedata' OR 'firud_cf_off_acc'.
      ls_line-name  = 'UV_MESSAGE' .
      ls_line-kind  = cl_abap_objectdescr=>exporting .
      ls_line-value = REF #( lv_req_body ).
      INSERT ls_line INTO TABLE lt_parameters .
*      WHEN OTHERS.
*
*    ENDCASE.
    ENDIF.

    DATA(lv_dyn_method) = |handle_{ to_lower( lv_method ) }_{ to_lower( lv_name ) }|.
    TRANSLATE lv_dyn_method TO UPPER CASE.

*    lt_parameters = VALUE #(
*    ( name = 'CV_MESSAGE'
*      kind = cl_abap_objectdescr=>changing
*      value = REF #( g_json_string ) )
*    ).

    ls_line-name  = 'CV_MESSAGE' .
    ls_line-kind  = cl_abap_objectdescr=>changing .
    ls_line-value = REF #( g_json_string ).
    INSERT ls_line INTO TABLE lt_parameters .

    DATA(lo_self) = NEW zcl_http_teamworkerlist( ).
*** Call Methods:
    TRY.
        CALL METHOD lo_self->(lv_dyn_method)
          PARAMETER-TABLE lt_parameters.
      CATCH cx_sy_dyn_call_illegal_method INTO DATA(lx_dyn).
        " Trường hợp method không tồn tại
        CALL METHOD lo_self->('HANDLE_UNKNOWN_CASE')
          PARAMETER-TABLE lt_parameters.
    ENDTRY.

*** Response
    response->set_status('200').

*** Setup -> Response content-type json
    response->set_header_field( i_name  = c_header_content
                                i_value = c_content_type ).

    response->set_text( g_json_string ).
  ENDMETHOD.


  METHOD handle_get_teamworkerlist.
    DATA: et_tw_list TYPE TABLE OF zc_tw_list.

    DATA: lr_WorkerId    TYPE tt_ranges,
          lr_WorkCenter  TYPE tt_ranges,
          lr_Plant       TYPE tt_ranges,
          lr_Shift       TYPE tt_ranges,
          lr_MachineId   TYPE tt_ranges,
          lr_TeamId      TYPE tt_ranges,
          lr_Postingdate TYPE tt_ranges.

    DATA: lv_condition TYPE string.

    IF g_postingdate IS NOT INITIAL.
      lv_condition = |FromDate <= '{ g_postingdate }' and ToDate >= '{ g_postingdate }'|.
    ENDIF.

    IF g_workerid IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = g_workerid ) TO lr_workerid.
    ENDIF.

    IF g_workcenter IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = g_workcenter ) TO lr_workcenter.
    ENDIF.

    IF g_Plant IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = g_plant ) TO lr_plant.
    ENDIF.

    IF g_shift IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = g_shift ) TO lr_shift.
    ENDIF.

    IF g_machineid IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = g_machineid ) TO lr_machineid.
    ENDIF.

    IF g_teamid IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = g_teamid ) TO lr_teamid.
    ENDIF.

    SELECT * FROM zc_tw_list
    WHERE WorkerId IN @lr_workerid
    AND WorkCenter IN @lr_workcenter
    AND Plant IN @lr_plant
    AND Shift IN @lr_shift
    AND MachineId IN @lr_machineid
    AND TeamId IN @lr_teamid
    AND (lv_condition)
    INTO CORRESPONDING FIELDS OF TABLE @et_tw_list.

    cv_message = xco_cp_json=>data->from_abap( et_tw_list )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

  ENDMETHOD.


  METHOD handle_get_machineid.
    DATA: et_somay_list TYPE TABLE OF zc_kb_somay.

    DATA: lr_WorkCenter  TYPE tt_ranges,
          lr_MachineId   TYPE tt_ranges, "name default MachineId
          lr_Postingdate TYPE tt_ranges.

    DATA: lv_condition TYPE string.

    IF g_postingdate IS NOT INITIAL.
      lv_condition = |FromDate <= '{ g_postingdate }' and ToDate >= '{ g_postingdate }'|.
    ENDIF.

    IF g_workcenter IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = g_workcenter ) TO lr_workcenter.
    ENDIF.

    IF g_machineid IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = g_machineid ) TO lr_machineid.
    ENDIF.

    SELECT * FROM zc_kb_somay
    WHERE WorkCenter IN @lr_workcenter
    AND MachineId IN @lr_machineid
    AND (lv_condition)
    INTO CORRESPONDING FIELDS OF TABLE @et_somay_list.

    cv_message = xco_cp_json=>data->from_abap( et_somay_list )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).
  ENDMETHOD.


  METHOD handle_get_teamid.
    DATA: et_tsx_list TYPE TABLE OF zc_kb_tsx.

    DATA: lr_WorkCenter  TYPE tt_ranges,
          lr_TeamId      TYPE tt_ranges, "name default TeamId
          lr_Postingdate TYPE tt_ranges.

    DATA: lv_condition TYPE string.

    IF g_postingdate IS NOT INITIAL.
      lv_condition = |FromDate <= '{ g_postingdate }' and ToDate >= '{ g_postingdate }'|.
    ENDIF.

    IF g_workcenter IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = g_workcenter ) TO lr_workcenter.
    ENDIF.

    IF g_teamid IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = g_teamid ) TO lr_teamid.
    ENDIF.

    SELECT * FROM zc_kb_tsx
    WHERE WorkCenter IN @lr_workcenter
    AND TeamId IN @lr_teamid
    AND (lv_condition)
    INTO CORRESPONDING FIELDS OF TABLE @et_tsx_list.

    cv_message = xco_cp_json=>data->from_abap( et_tsx_list )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).
  ENDMETHOD.


  METHOD handle_get_workerid.
    DATA: et_nhancong_list TYPE TABLE OF zc_kb_nhancong.

    DATA: lr_WorkerId    TYPE tt_ranges, "name default WorkerId
          lr_WorkCenter  TYPE tt_ranges,
          lr_Postingdate TYPE tt_ranges.

    DATA: lv_condition TYPE string.

    IF g_postingdate IS NOT INITIAL.
      lv_condition = |FromDate <= '{ g_postingdate }' and ToDate >= '{ g_postingdate }'|.
    ENDIF.

    IF g_workerid IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = g_workerid ) TO lr_workerid.
    ENDIF.

    IF g_workcenter IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = g_workcenter ) TO lr_workcenter.
    ENDIF.

    SELECT * FROM zc_kb_nhancong
    WHERE WorkerId IN @lr_workerid
    AND WorkCenter IN @lr_workcenter
    AND (lv_condition)
    INTO CORRESPONDING FIELDS OF TABLE @et_nhancong_list.

    cv_message = xco_cp_json=>data->from_abap( et_nhancong_list )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).
  ENDMETHOD.
ENDCLASS.

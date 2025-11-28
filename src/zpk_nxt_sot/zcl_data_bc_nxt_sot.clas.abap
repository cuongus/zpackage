CLASS zcl_data_bc_nxt_sot DEFINITION
  PUBLIC
  INHERITING FROM cx_rap_query_provider
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,
           tt_ranges TYPE TABLE OF ty_range_option.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      "entity
      query_header
        IMPORTING io_request  TYPE REF TO if_rap_query_request
                  io_response TYPE REF TO if_rap_query_response
        RAISING   cx_rap_query_provider,

      query_detail
        IMPORTING io_request  TYPE REF TO if_rap_query_request
                  io_response TYPE REF TO if_rap_query_response
        RAISING   cx_rap_query_provider.
ENDCLASS.

CLASS zcl_data_bc_nxt_sot IMPLEMENTATION.

  METHOD if_rap_query_provider~select.
    "entity
    DATA(entity_id) = io_request->get_entity_id( ).
    TRY.
        CASE entity_id.
          WHEN 'ZC_NXT_SOT_HDR'.        "header
            query_header( io_request = io_request io_response = io_response ).

          WHEN 'ZC_NXT_SOT_DTL'.        "detail
            query_detail( io_request = io_request io_response = io_response ).

        ENDCASE.

      CATCH cx_rap_query_provider INTO DATA(lx_query).
        RAISE EXCEPTION lx_query.
    ENDTRY.
  ENDMETHOD.

  METHOD query_header.
    DATA: lt_header   TYPE TABLE OF zc_nxt_sot_hdr,
          ls_header   TYPE zc_nxt_sot_hdr,
          ir_material TYPE tt_ranges,
          ir_plant    TYPE tt_ranges,
          ir_sloc     TYPE tt_ranges,
          ir_vendor   TYPE tt_ranges.

    DATA: lv_datefr TYPE d,
          lv_dateto TYPE d.

    " Get filters
    DATA(lo_filter) = io_request->get_filter( ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.

    " Parse filters
    LOOP AT lt_filters INTO DATA(ls_filters).
      CASE ls_filters-name.
        WHEN 'DATEFR'.
          READ TABLE ls_filters-range INDEX 1 INTO DATA(ls_datefr).
          lv_datefr = ls_datefr-low.

        WHEN 'DATETO'.
          READ TABLE ls_filters-range INDEX 1 INTO DATA(ls_dateto).
          lv_dateto = ls_dateto-low.

        WHEN 'CT01'.  " Material
          MOVE-CORRESPONDING ls_filters-range TO ir_material.

        WHEN 'CT04'.  " Plant
          MOVE-CORRESPONDING ls_filters-range TO ir_plant.

        WHEN 'CT06'.  " Storage Location
          MOVE-CORRESPONDING ls_filters-range TO ir_sloc.

        WHEN 'CT12'.  " Vendor
          MOVE-CORRESPONDING ls_filters-range TO ir_vendor.

      ENDCASE.
    ENDLOOP.


    IF lv_datefr IS NOT INITIAL AND lv_dateto IS NOT INITIAL
       AND lv_datefr > lv_dateto.

             RAISE EXCEPTION TYPE zcl_jp_get_data_report_fi
        EXPORTING
          textid = VALUE #(
            msgid = '00'
            msgno = '208'
            attr1 = 'Vui lòng kiểm tra lại ngày nhập'
          ).


      " Must call get_paging() to satisfy RAP query requirements
      DATA(lo_paging_check) = io_request->get_paging( ).

      IF io_request->is_data_requested( ).
        io_response->set_data( lt_header ).
      ENDIF.

      IF io_request->is_total_numb_of_rec_requested( ).
        io_response->set_total_number_of_records( 0 ).
      ENDIF.
      RETURN.
    ENDIF.



    CALL METHOD zcl_nxt_sot=>get_xnt_sot
      EXPORTING
        ir_datefr     = lv_datefr
        ir_dateto     = lv_dateto
        ir_material   = ir_material
        ir_plant      = ir_plant
        ir_vendor     = ir_vendor
        ir_sloc       = ir_sloc
      IMPORTING
        e_nxt_sot_hdr = lt_header.

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
      SELECT SINGLE productDescription
      FROM i_productdescription_2
      WHERE Product = @<fs_header>-ct01
      AND language = 'E'
      INTO @<fs_header>-ct02.

      SELECT SINGLE plantname
    FROM i_cnsldtnplantt
    WHERE plant = @<fs_header>-ct04
    AND language = 'E'
    INTO @<fs_header>-ct05.

      SELECT SINGLE storagelocationname
      FROM i_storagelocation
      WHERE plant = @<fs_header>-ct04
      AND storagelocation = @<fs_header>-ct06
      INTO @<fs_header>-ct07.
            SELECT SINGLE businesspartnerfullname
      FROM i_businesspartner
      WHERE businesspartner = @<fs_header>-ct12
      INTO @<fs_header>-ct13.
    ENDLOOP.

    " Sorting
    DATA(sort_order) = VALUE abap_sortorder_tab(
      FOR sort_element IN io_request->get_sort_elements( )
      ( name = sort_element-element_name descending = sort_element-descending ) ).
    IF sort_order IS NOT INITIAL.
      SORT lt_header BY (sort_order).
    ENDIF.

    " Paging
    DATA(lv_total_records) = lines( lt_header ).
    DATA(lt_result) = lt_header.
    DATA(lo_paging) = io_request->get_paging( ).

    IF lo_paging IS BOUND.
      DATA(top) = lo_paging->get_page_size( ).
      IF top < 0. " -1 means all records
        top = lv_total_records.
      ENDIF.
      DATA(skip) = lo_paging->get_offset( ).

      IF skip >= lv_total_records.
        CLEAR lt_result.
      ELSEIF top = 0.
        CLEAR lt_result.
      ELSE.
        DATA(lv_start_index) = skip + 1.
        DATA(lv_end_index) = skip + top.

        IF lv_end_index > lv_total_records.
          lv_end_index = lv_total_records.
        ENDIF.

        DATA: lt_paged_result LIKE lt_result.
        CLEAR lt_paged_result.

        DATA(lv_index) = lv_start_index.
        WHILE lv_index <= lv_end_index.
          APPEND lt_result[ lv_index ] TO lt_paged_result.
          lv_index = lv_index + 1.
        ENDWHILE.

        lt_result = lt_paged_result.
      ENDIF.
    ENDIF.

    " Return data
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_header ) ).
    ENDIF.

    IF io_request->is_data_requested( ).
      io_response->set_data( lt_result ).
    ENDIF.

  ENDMETHOD.

  METHOD query_detail.
    DATA: lt_detail   TYPE TABLE OF zc_nxt_sot_dtl,
          ls_detail   TYPE zc_nxt_sot_dtl,
          ir_material TYPE tt_ranges,
          ir_plant    TYPE tt_ranges,
          ir_sloc     TYPE tt_ranges,
          ir_vendor   TYPE tt_ranges.

    DATA: lv_datefr TYPE d,
          lv_dateto TYPE d,
          lv_ct01   TYPE string,  " Parent material
          lv_ct04   TYPE string, " Parent plant
          lv_ct06   TYPE string,    " Parent storage location
          lv_ct12   TYPE string.      " Parent vendor

    " Get filters
    DATA(lo_filter) = io_request->get_filter( ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.

    " Parse filters - including parent keys
    LOOP AT lt_filters INTO DATA(ls_filters).
      CASE ls_filters-name.
        WHEN 'DATEFR'.
          READ TABLE ls_filters-range INDEX 1 INTO DATA(ls_datefr).
          lv_datefr = ls_datefr-low.

        WHEN 'DATETO'.
          READ TABLE ls_filters-range INDEX 1 INTO DATA(ls_dateto).
          lv_dateto = ls_dateto-low.

        WHEN 'CT06'.  " Material (parent key from header)
          READ TABLE ls_filters-range INDEX 1 INTO DATA(ls_ct06_filter).
          lv_ct01 = ls_ct06_filter-low.
          " Also use for detail filtering
          MOVE-CORRESPONDING ls_filters-range TO ir_material.

        WHEN 'CT08'.  " Plant (parent key from header)
          READ TABLE ls_filters-range INDEX 1 INTO DATA(ls_ct08_filter).
          lv_ct04 = ls_ct08_filter-low.
          " Also use for detail filtering
          MOVE-CORRESPONDING ls_filters-range TO ir_plant.

        WHEN 'CT09'.  " Storage Location (parent key from header)
          READ TABLE ls_filters-range INDEX 1 INTO DATA(ls_ct09_filter).
          lv_ct06 = ls_ct09_filter-low.
          " Also use for detail filtering
          MOVE-CORRESPONDING ls_filters-range TO ir_sloc.

        WHEN 'CT10'. "vendor (parent key from header)
          READ TABLE ls_filters-range INDEX 1 INTO DATA(ls_ct10_filter).
          lv_ct12 = ls_ct10_filter-low.
          " Also use for detail filtering
          MOVE-CORRESPONDING ls_filters-range TO ir_vendor.
          CONTINUE.

      ENDCASE.
    ENDLOOP.


    IF lv_datefr IS NOT INITIAL AND lv_dateto IS NOT INITIAL
       AND lv_datefr > lv_dateto.
      " Must call get_paging() to satisfy RAP query requirements
      DATA(lo_paging_check) = io_request->get_paging( ).

      IF io_request->is_data_requested( ).
        io_response->set_data( lt_detail ).
      ENDIF.

      IF io_request->is_total_numb_of_rec_requested( ).
        io_response->set_total_number_of_records( 0 ).
      ENDIF.
      RETURN.
    ENDIF.

    " Get detail data from business logic class
    CALL METHOD zcl_nxt_sot=>get_xnt_sot_dtl
      EXPORTING
        ir_datefr     = lv_datefr
        ir_dateto     = lv_dateto
        ir_material   = ir_material
        ir_plant      = ir_plant
        ir_vendor     = ir_vendor
        ir_sloc       = ir_sloc
      IMPORTING
        e_nxt_sot_dtl = lt_detail.

    LOOP AT lt_detail ASSIGNING FIELD-SYMBOL(<fs_detail>).
      <fs_detail>-DateFR = lv_datefr.
      <fs_detail>-DateTO = lv_dateto.
    ENDLOOP.

    " Sorting
    DATA(sort_order) = VALUE abap_sortorder_tab(
      FOR sort_element IN io_request->get_sort_elements( )
      ( name = sort_element-element_name descending = sort_element-descending ) ).
    IF sort_order IS NOT INITIAL.
      SORT lt_detail BY (sort_order).
    ENDIF.

    " Paging
    DATA(lv_total_records) = lines( lt_detail ).
    DATA(lt_result) = lt_detail.
    DATA(lo_paging) = io_request->get_paging( ).

    IF lo_paging IS BOUND.
      DATA(top) = lo_paging->get_page_size( ).
      IF top < 0.
        top = lv_total_records.
      ENDIF.
      DATA(skip) = lo_paging->get_offset( ).

      IF skip < lv_total_records AND top > 0.
        DATA(lv_start_index) = skip + 1.
        DATA(lv_end_index) = skip + top.

        IF lv_end_index > lv_total_records.
          lv_end_index = lv_total_records.
        ENDIF.

        DATA: lt_paged_result LIKE lt_result.
        CLEAR lt_paged_result.

        DATA(lv_index) = lv_start_index.
        WHILE lv_index <= lv_end_index.
          APPEND lt_result[ lv_index ] TO lt_paged_result.
          lv_index = lv_index + 1.
        ENDWHILE.

        lt_result = lt_paged_result.
      ELSE.
        CLEAR lt_result.
      ENDIF.
    ENDIF.

    " Return data
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_detail ) ).
    ENDIF.

    IF io_request->is_data_requested( ).
      io_response->set_data( lt_result ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

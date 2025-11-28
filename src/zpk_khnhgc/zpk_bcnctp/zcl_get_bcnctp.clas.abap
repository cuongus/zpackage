CLASS zcl_get_bcnctp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  INHERITING FROM cx_rap_query_provider.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_ranges,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE c LENGTH 45,
             high   TYPE c LENGTH 45,
           END OF ty_ranges,

           BEGIN OF ty_returns,
             msgty TYPE symsgty,  "char(1) Message Type
             msgid TYPE symsgid,  "char(20) Message Class
             msgno TYPE symsgno,  "numc(3) Message Number
             msgv1 TYPE symsgv,   "char(50) Message Variable
             msgv2 TYPE symsgv,   "char(50) Message Variable
             msgv3 TYPE symsgv,   "char(50) Message Variable
             msgv4 TYPE symsgv,
           END OF ty_returns,

           tt_ranges  TYPE STANDARD TABLE OF ty_ranges  WITH EMPTY KEY,
           tt_returns TYPE STANDARD TABLE OF ty_returns WITH EMPTY KEY,

           gty_bcnctp TYPE STANDARD TABLE OF zcs_bcnctp WITH EMPTY KEY.

    CLASS-DATA:
                 gt_bcnctp  TYPE gty_bcnctp.


    "Custom Entity / Query Provider
    INTERFACES if_rap_query_provider.

    CLASS-METHODS: get_bcnctp IMPORTING ir_hierarchy3 TYPE tt_ranges OPTIONAL
                                        ir_hierarchy4 TYPE tt_ranges OPTIONAL

                                        ir_plant      TYPE tt_ranges OPTIONAL
                                        ir_week       TYPE tt_ranges OPTIONAL
                                        ir_year       TYPE tt_ranges OPTIONAL
                              EXPORTING et_data       TYPE gty_bcnctp
                                        et_returns    TYPE tt_returns.


  PROTECTED SECTION.
  PRIVATE SECTION.
    "Get Filter Ranges
    METHODS get_provided_ranges
      IMPORTING
        io_request    TYPE REF TO if_rap_query_request
      EXPORTING
        er_hierarchy3 TYPE tt_ranges
        er_hierarchy4 TYPE tt_ranges
        er_plant      TYPE tt_ranges
        er_week       TYPE tt_ranges
        er_year       TYPE tt_ranges
      RAISING
        cx_rap_query_prov_not_impl
        cx_rap_query_provider.
ENDCLASS.



CLASS zcl_get_bcnctp IMPLEMENTATION.

  METHOD get_provided_ranges.
    "*======================================================================
    "* Helper: đọc filter ranges từ request
    "*======================================================================
    TRY.
        DATA(lt_ranges) = io_request->get_filter( )->get_as_ranges( ).

        LOOP AT lt_ranges REFERENCE INTO DATA(lr_range).

          CASE lr_range->name.

            WHEN 'PRODUCTHIERARCHY3'.
              LOOP AT lr_range->range REFERENCE INTO DATA(lr_range_entry).
                INSERT VALUE #(
                  sign   = lr_range_entry->sign
                  option = lr_range_entry->option
                  low    = CONV #( lr_range_entry->low )
                  high   = CONV #( lr_range_entry->high ) )
                  INTO TABLE er_hierarchy3.
              ENDLOOP.

            WHEN 'PRODUCTHIERARCHY4'.
              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.
                INSERT VALUE #(
                  sign   = lr_range_entry->sign
                  option = lr_range_entry->option
                  low    = CONV #( lr_range_entry->low )
                  high   = CONV #( lr_range_entry->high ) )
                  INTO TABLE er_hierarchy4.
              ENDLOOP.

            WHEN 'PLANT'.
              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.
                INSERT VALUE #(
                  sign   = lr_range_entry->sign
                  option = lr_range_entry->option
                  low    = CONV #( lr_range_entry->low )
                  high   = CONV #( lr_range_entry->high ) )
                  INTO TABLE er_plant.
              ENDLOOP.

            WHEN 'WEEK'.
              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.
                INSERT VALUE #(
                  sign   = lr_range_entry->sign
                  option = lr_range_entry->option
                  low    = CONV #( lr_range_entry->low )
                  high   = CONV #( lr_range_entry->high ) )
                  INTO TABLE er_week.
              ENDLOOP.

            WHEN 'ZYEAR'.
              LOOP AT lr_range->range REFERENCE INTO lr_range_entry.
                INSERT VALUE #(
                  sign   = lr_range_entry->sign
                  option = lr_range_entry->option
                  low    = CONV #( lr_range_entry->low )
                  high   = CONV #( lr_range_entry->high ) )
                  INTO TABLE er_year.
              ENDLOOP.

            WHEN OTHERS.
              "ignore

          ENDCASE.

        ENDLOOP.

      CATCH cx_rap_query_filter_no_range INTO DATA(lx_previous).
        "tuỳ bạn xử lý thêm
    ENDTRY.
  ENDMETHOD.

  METHOD if_rap_query_provider~select.

    "*======================================================================
    "* Query Provider: SELECT
    "*======================================================================

    TRY.
        DATA(lo_paging)        = io_request->get_paging( ).
        DATA(lt_sort_elements) = io_request->get_sort_elements( ).

        get_provided_ranges(
          EXPORTING
            io_request    = io_request
          IMPORTING
            er_hierarchy3 = DATA(ir_hierarchy3)
            er_hierarchy4 = DATA(ir_hierarchy4)
            er_plant      = DATA(ir_plant)
            er_week       = DATA(ir_week)
            er_year       = DATA(ir_year)
        ).

        DATA: lv_check   TYPE abap_boolean VALUE abap_false,
              lt_returns TYPE tt_returns.

        "=== Check week_from -> week_to <= 54 tuần =====================
        DATA: lv_idx_from TYPE i,
              lv_idx_to   TYPE i,
              lv_span     TYPE i.

        DATA(year_from) = CONV gjahr( ir_year[ 1 ]-low ).
        DATA(year_to)   = CONV gjahr( ir_year[ 1 ]-high ).

        DATA(week_from) = CONV i( ir_week[ 1 ]-low ).
        DATA(week_to)   = CONV i( ir_week[ 1 ]-high ).

        IF year_to IS INITIAL.
          year_to = year_from.
        ENDIF.

        IF week_to IS INITIAL.
          week_to = week_from.
        ENDIF.

        "Convert (year, week) -> chỉ số tuần tuyệt đối
        lv_idx_from = year_from * 52 + week_from.
        lv_idx_to   = year_to   * 52 + week_to.

        "from > to -> error
        IF lv_idx_to < lv_idx_from.
          APPEND VALUE #( msgno = '001' ) TO lt_returns.
          lv_check = abap_true.
        ENDIF.

        "Số tuần trong khoảng (cả 2 đầu)
        lv_span = lv_idx_to - lv_idx_from + 1.

        "Không quá 54 tuần
        IF lv_span > 54.
          APPEND VALUE #( msgno = '002' ) TO lt_returns.
          lv_check = abap_true.
        ENDIF.

        IF lv_check = abap_true.
          "Không cần xử lý tiếp → raise exception từ lt_returns (nếu muốn)
          READ TABLE lt_returns INDEX 1 INTO DATA(ls_return).
          IF sy-subrc = 0.
            RAISE EXCEPTION TYPE zcl_get_bcnctp
              EXPORTING
                textid = VALUE scx_t100key(
                           msgid = 'ZMMKHNHGC'
                           msgno = ls_return-msgno
                           attr1 = CONV string( ls_return-msgv1 ) ).
          ENDIF.
          RETURN.
        ENDIF.

        "=== Lấy dữ liệu chính ========================================
        get_bcnctp(
          EXPORTING
            ir_hierarchy3 = ir_hierarchy3
            ir_hierarchy4 = ir_hierarchy4
            ir_plant      = ir_plant
            ir_week       = ir_week
            ir_year       = ir_year
          IMPORTING
            et_data       = gt_bcnctp
            et_returns    = lt_returns
        ).

        IF lt_returns IS NOT INITIAL.
          READ TABLE lt_returns INDEX 1 INTO DATA(ls_return2).
          RAISE EXCEPTION TYPE zcl_get_bcnctp
            EXPORTING
              textid = VALUE scx_t100key(
                         msgid = 'ZMMKHNHGC'
                         msgno = ls_return2-msgno
                         attr1 = CONV string( ls_return2-msgv1 ) ).
        ENDIF.

        "=== Paging ====================================================
        DATA lt_temp TYPE gty_bcnctp.

        DATA(page_size) = lo_paging->get_page_size( ).
        DATA(offset)    = lo_paging->get_offset( ).

        DATA(max_rows) = COND #( WHEN page_size = if_rap_query_paging=>page_size_unlimited
                                 THEN 0
                                 ELSE page_size ).

        max_rows = page_size + offset.

        LOOP AT gt_bcnctp INTO DATA(ls_bcnctp).
          IF sy-tabix > offset.
            IF max_rows > 0 AND sy-tabix > max_rows.
              EXIT.
            ELSE.
              APPEND ls_bcnctp TO lt_temp.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( gt_bcnctp ) ).
        ENDIF.

        IF io_request->is_data_requested( ).
          io_response->set_data( lt_temp ).
        ENDIF.


      CATCH cx_root INTO DATA(exception).

        IF cl_message_helper=>get_latest_t100_exception( exception ) IS BOUND.
          RAISE EXCEPTION exception.
        ELSE.
          RAISE EXCEPTION TYPE zcl_get_bcnctp
            EXPORTING
              textid = VALUE scx_t100key(
                         msgid = 'ZMMKHNHGC'
                         msgno = '999'
                         attr1 = exception->get_text( ) ).
        ENDIF.

    ENDTRY.

  ENDMETHOD.

  METHOD get_bcnctp.

    DATA: lr_date TYPE tt_ranges.

    DATA: startdate TYPE d,
          enddate   TYPE d.

    DATA: weekfrom TYPE i,
          yearfrom TYPE gjahr,

          weekto   TYPE i,
          yearto   TYPE gjahr.

    yearfrom = ir_year[ 1 ]-low .
    yearto   = ir_year[ 1 ]-high.

    weekfrom = ir_week[ 1 ]-low .
    weekto   = ir_week[ 1 ]-high.

    IF yearto IS INITIAL.
      yearto = yearfrom.
    ENDIF.

    IF weekto IS INITIAL.
      weekto = weekfrom.
    ENDIF.

    startdate = zcl_week_util=>get_monday_of_week(
      iv_year = yearfrom
      iv_week = weekfrom ).

    enddate = zcl_week_util=>get_sunday_of_week(
      iv_year = yearto
      iv_week = weekto ).


    TYPES: BEGIN OF lty_hierarchy4,
             producthierarchy4 TYPE zde_char50,
           END OF lty_hierarchy4.

    DATA: lt_hierarchy4 TYPE STANDARD TABLE OF lty_hierarchy4 WITH DEFAULT KEY.

    TYPES: BEGIN OF lty_salesorder,
             producthierarchy3     TYPE i_produnivhierarchynodebasic-parentnode,
             producthierarchy4     TYPE i_produnivhierarchynodebasic-hierarchynode,

             hierarchynodelevel    TYPE i_produnivhierarchynodebasic-hierarchynodelevel,

             product               TYPE i_salesorderitem-product,
             plant                 TYPE i_salesorderitem-plant,

             salesorder            TYPE i_salesorderitem-salesorder,
             salesorderitem        TYPE i_salesorderitem-salesorderitem,

             orderquantity         TYPE i_salesorderitem-orderquantity,
             orderquantityunit     TYPE i_salesorderitem-orderquantityunit,
             deliverystatus        TYPE i_salesorderitem-deliverystatus,

             requesteddeliverydate TYPE i_salesorderscheduleline-requesteddeliverydate,
           END OF lty_salesorder.

    DATA: lt_salesorder TYPE STANDARD TABLE OF lty_salesorder WITH EMPTY KEY.

    SELECT
        hierarchy4~parentnode AS producthierarchy3,
        hierarchy4~hierarchynode AS producthierarchy4,

        hierarchy4~hierarchynodelevel,

        salesorder~product,
        salesorder~plant,

        salesorder~salesorder,
        salesorder~salesorderitem,

        salesorder~orderquantity,
        salesorder~orderquantityunit,
        salesorder~deliverystatus,

        scheduleline~requesteddeliverydate

    FROM i_salesorderitem AS salesorder

    INNER JOIN i_salesorderscheduleline AS scheduleline
    ON scheduleline~salesorder = salesorder~salesorder
    AND scheduleline~salesorderitem = salesorder~salesorderitem

    INNER JOIN i_produnivhierarchynodebasic AS hierarchy4
    ON hierarchy4~product = salesorder~product
    AND hierarchy4~prodhierarchyvaliditystartdate <= salesorder~creationdate
    AND hierarchy4~prodhierarchyvalidityenddate >= salesorder~creationdate

    WHERE scheduleline~requesteddeliverydate IN @lr_date
      AND salesorder~deliverystatus IN ( 'A', 'B' )

      AND salesorder~plant IN @ir_plant

      AND hierarchy4~produnivhierarchy = 'PH_MANUFACTURING'
*
      AND hierarchy4~hierarchynode  IN @ir_hierarchy4
      AND hierarchy4~hierarchynodelevel = '000004'

      AND hierarchy4~parentnode     IN @ir_hierarchy3

      AND scheduleline~requesteddeliverydate <= @enddate
      AND scheduleline~requesteddeliverydate >= @startdate

    INTO CORRESPONDING FIELDS OF TABLE @lt_salesorder.

    IF sy-subrc EQ 0.
*      MOVE-CORRESPONDING lt_salesorder TO lt_hierarchy4.
*
*      SORT lt_hierarchy4 BY producthierarchy4 ASCENDING.
*      DELETE ADJACENT DUPLICATES FROM lt_hierarchy4 COMPARING producthierarchy4.
    ENDIF.

    TYPES: BEGIN OF lty_agg,
             producthierarchy3 TYPE i_produnivhierarchynodebasic-parentnode,
             producthierarchy4 TYPE i_produnivhierarchynodebasic-hierarchynode,
             plant             TYPE werks_d,
             week              TYPE zde_char2,
             year              TYPE char4,
             orderqty_sum      TYPE p LENGTH 15 DECIMALS 0,
           END OF lty_agg.

    DATA: ls_agg TYPE lty_agg,
          lt_agg TYPE TABLE OF lty_agg.

    LOOP AT lt_salesorder ASSIGNING FIELD-SYMBOL(<ls>).

      CLEAR ls_agg.

      ls_agg-producthierarchy3 = <ls>-producthierarchy3.
      ls_agg-producthierarchy4 = <ls>-producthierarchy4.
      ls_agg-plant             = <ls>-plant.

      " ABAP built-in function (dùng được trong expression, không phải SQL)
      ls_agg-year = <ls>-requesteddeliverydate+0(4).

      zcl_iso_week=>get_iso_week(
        EXPORTING
          i_date = <ls>-requesteddeliverydate
        IMPORTING
          e_week = DATA(week) ).

      ls_agg-week = week+4(2).
      " Giá trị cần cộng
      ls_agg-orderqty_sum = <ls>-orderquantity.

      " COLLECT: nếu key đã tồn tại thì tự động cộng vào field numeric
      COLLECT ls_agg INTO lt_agg.

    ENDLOOP.

    SORT lt_agg BY producthierarchy3 producthierarchy4 plant ASCENDING.

    TYPES: BEGIN OF ty_matrix,
             producthierarchy3 TYPE lty_agg-producthierarchy3,
             producthierarchy4 TYPE lty_agg-producthierarchy4,
             plant             TYPE lty_agg-plant,

             w1orderquantity   TYPE lty_agg-orderqty_sum,
             w2orderquantity   TYPE lty_agg-orderqty_sum,
             w3orderquantity   TYPE lty_agg-orderqty_sum,
             w4orderquantity   TYPE lty_agg-orderqty_sum,
             w5orderquantity   TYPE lty_agg-orderqty_sum,
             w6orderquantity   TYPE lty_agg-orderqty_sum,
             w7orderquantity   TYPE lty_agg-orderqty_sum,
             w8orderquantity   TYPE lty_agg-orderqty_sum,
             w9orderquantity   TYPE lty_agg-orderqty_sum,
             w10orderquantity  TYPE lty_agg-orderqty_sum,
             w11orderquantity  TYPE lty_agg-orderqty_sum,
             w12orderquantity  TYPE lty_agg-orderqty_sum,
             w13orderquantity  TYPE lty_agg-orderqty_sum,
             w14orderquantity  TYPE lty_agg-orderqty_sum,
             w15orderquantity  TYPE lty_agg-orderqty_sum,
             w16orderquantity  TYPE lty_agg-orderqty_sum,
             w17orderquantity  TYPE lty_agg-orderqty_sum,
             w18orderquantity  TYPE lty_agg-orderqty_sum,
             w19orderquantity  TYPE lty_agg-orderqty_sum,
             w20orderquantity  TYPE lty_agg-orderqty_sum,
             w21orderquantity  TYPE lty_agg-orderqty_sum,
             w22orderquantity  TYPE lty_agg-orderqty_sum,
             w23orderquantity  TYPE lty_agg-orderqty_sum,
             w24orderquantity  TYPE lty_agg-orderqty_sum,
             w25orderquantity  TYPE lty_agg-orderqty_sum,
             w26orderquantity  TYPE lty_agg-orderqty_sum,
             w27orderquantity  TYPE lty_agg-orderqty_sum,
             w28orderquantity  TYPE lty_agg-orderqty_sum,
             w29orderquantity  TYPE lty_agg-orderqty_sum,
             w30orderquantity  TYPE lty_agg-orderqty_sum,
             w31orderquantity  TYPE lty_agg-orderqty_sum,
             w32orderquantity  TYPE lty_agg-orderqty_sum,
             w33orderquantity  TYPE lty_agg-orderqty_sum,
             w34orderquantity  TYPE lty_agg-orderqty_sum,
             w35orderquantity  TYPE lty_agg-orderqty_sum,
             w36orderquantity  TYPE lty_agg-orderqty_sum,
             w37orderquantity  TYPE lty_agg-orderqty_sum,
             w38orderquantity  TYPE lty_agg-orderqty_sum,
             w39orderquantity  TYPE lty_agg-orderqty_sum,
             w40orderquantity  TYPE lty_agg-orderqty_sum,
             w41orderquantity  TYPE lty_agg-orderqty_sum,
             w42orderquantity  TYPE lty_agg-orderqty_sum,
             w43orderquantity  TYPE lty_agg-orderqty_sum,
             w44orderquantity  TYPE lty_agg-orderqty_sum,
             w45orderquantity  TYPE lty_agg-orderqty_sum,
             w46orderquantity  TYPE lty_agg-orderqty_sum,
             w47orderquantity  TYPE lty_agg-orderqty_sum,
             w48orderquantity  TYPE lty_agg-orderqty_sum,
             w49orderquantity  TYPE lty_agg-orderqty_sum,
             w50orderquantity  TYPE lty_agg-orderqty_sum,
             w51orderquantity  TYPE lty_agg-orderqty_sum,
             w52orderquantity  TYPE lty_agg-orderqty_sum,
             w53orderquantity  TYPE lty_agg-orderqty_sum,
             w54orderquantity  TYPE lty_agg-orderqty_sum,
           END OF ty_matrix.

    DATA: lt_matrix TYPE HASHED TABLE OF ty_matrix
                   WITH UNIQUE KEY producthierarchy3 producthierarchy4 plant,
          ls_matrix TYPE ty_matrix.

    FIELD-SYMBOLS: <ls_matrix> TYPE ty_matrix.

    "Base index: W1 ứng với (iv_year_from, iv_week_from)
    DATA lv_base_idx TYPE i.
    lv_base_idx = yearfrom * 54 + weekfrom.

    LOOP AT lt_agg INTO ls_agg.
      CLEAR: ls_matrix.

      "===== Tính index W? tương ứng với tuần hiện tại =====
      DATA: lv_week_num  TYPE i,
            lv_abs_index TYPE i,
            lv_w_col     TYPE i.

      lv_week_num  = CONV i( ls_agg-week ).
      lv_abs_index = ls_agg-year * 54 + lv_week_num.
      lv_w_col     = lv_abs_index - lv_base_idx + 1. "W1 = week_from

      ls_matrix-producthierarchy3 = ls_agg-producthierarchy3.
      ls_matrix-producthierarchy4 = ls_agg-producthierarchy4.
      ls_matrix-plant             = ls_agg-plant.

      " Xác định tên field WnORDERQUANTITY
      DATA(lv_compname) = |W{ lv_w_col }ORDERQUANTITY|.

      ASSIGN COMPONENT lv_compname OF STRUCTURE ls_matrix TO fIELD-SYMBOL(<fs_quan>) .
      IF sy-subrc = 0.
        <fs_quan> = ls_agg-orderqty_sum.
      ELSE.
        " Nếu sai tên field sẽ vào đây (debug nếu cần)
      ENDIF.

      COLLECT ls_matrix INTO lt_matrix.

      UNASSIGN <fs_quan>.
    ENDLOOP.

    DATA: ls_data LIKE LINE OF et_data.

    LOOP AT lt_matrix INTO ls_matrix.
      CLEAR: ls_data.

      MOVE-CORRESPONDING ls_matrix TO ls_data.

      SELECT SINGLE produnivhierarchynodetext
      FROM i_produnivhiernodetext_2
      WHERE language = 'E'
        AND hierarchynode = @ls_matrix-producthierarchy3
        AND produnivhierarchy = 'PH_MANUFACTURING'
      INTO @ls_data-producthierarchy3name.

      SELECT SINGLE produnivhierarchynodetext
      FROM i_produnivhiernodetext_2
      WHERE language = 'E'
        AND hierarchynode = @ls_matrix-producthierarchy4
        AND produnivhierarchy = 'PH_MANUFACTURING'
      INTO @ls_data-producthierarchy4name.

      SELECT SINGLE plantname
      FROM i_plant
      WHERE plant = @ls_matrix-plant
      INTO @ls_data-plantname.

      APPEND ls_data TO et_data.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

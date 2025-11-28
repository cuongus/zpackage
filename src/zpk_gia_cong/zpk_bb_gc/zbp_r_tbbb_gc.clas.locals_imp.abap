CLASS lhc_zrtbgcloi DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZrTbgcLoi RESULT result.
    METHODS checkdtl FOR VALIDATE ON SAVE
      IMPORTING keys FOR zrtbgcloi~checkdtl.
*    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
*      IMPORTING REQUEST requested_authorizations FOR ZrTbgcLoi RESULT result.

*    METHODS createfrto FOR MODIFY
*      IMPORTING keys FOR ACTION zrtbgcloi~createfrto.

ENDCLASS.

CLASS lhc_zrtbgcloi IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zr_tbbb_gc IN LOCAL MODE
                ENTITY ZrTbbbGc
                   FIELDS (  Trangthai )
                   WITH CORRESPONDING #( keys )
                 RESULT DATA(lt_read_data)
                 FAILED failed.
    READ ENTITIES OF zr_tbbb_gc IN LOCAL MODE
            ENTITY ZrTbgcLoi
              ALL FIELDS
               WITH CORRESPONDING #( keys )
             RESULT DATA(lt_read_data_dtl)
             FAILED failed.
    READ TABLE lt_read_data INTO DATA(ls_data_hdr) INDEX 1.

    result = VALUE #( FOR ls_read_data_dtl IN lt_read_data_dtl
                   ( %tky                           = ls_read_data_dtl-%tky

                     %features-%update = COND #( WHEN ( ls_data_hdr-Trangthai > '1' AND ls_data_hdr-Trangthai <> '9' )
                                                     OR ls_data_hdr-SoBbBase <> ''
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                     %features-%delete = COND #( WHEN ls_data_hdr-Trangthai > '0' AND ls_data_hdr-Trangthai <> '9'
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                    %features-%field-Errordesc = COND #( WHEN ls_read_data_dtl-LoaiLoi IS NOT INITIAL AND ls_read_data_dtl-LoaiLoi <> 'C'
                                                              THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted )
                  ) ).

  ENDMETHOD.

  METHOD checkDtl.

    READ ENTITIES OF zr_tbbb_gc IN LOCAL MODE
       ENTITY ZrTbgcLoi
       ALL FIELDS
        WITH CORRESPONDING #(  keys )
       RESULT DATA(zr_read_Data).

*    LOOP AT zr_read_Data INTO DATA(ls_read_Data).
*      APPEND VALUE #(  %tky           = ls_read_Data-%tky
*                      %state_area    = 'CHECKDATA'
*                    ) TO reported-zrtbgcloi.
*      LOOP AT zr_read_Data INTO DATA(ls_read_Data_check)
*          WHERE ErrorCode =  ls_read_Data-ErrorCode
*            AND DtlID <> ls_read_Data-DtlID
*            AND ( LoaiLoi = 'C' OR LoaiLoi = '' ).
*        APPEND VALUE #( %tky          = ls_read_Data-%tky
*                        %state_area   = 'CHECKDATA'
*                        %msg          = new_message_with_text(
*                                severity = if_abap_behv_message=>severity-error
*                                text     = 'Trùng mã lỗi' )
*                        %element-ErrorCode = if_abap_behv=>mk-on
*                      ) TO reported-zrtbgcloi.
*         APPEND VALUE #(  %tky = ls_read_Data-%tky ) TO failed-zrtbgcloi.
*        EXIT.
*      ENDLOOP.
*    ENDLOOP.
  ENDMETHOD.

*  METHOD get_global_authorizations.
*  ENDMETHOD.

*  METHOD CreateFrTo.
*    READ TABLE keys INTO DATA(ls_key) INDEX 1.
*  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZrTbbbGc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_file_up_gen,
        SoBb        TYPE string,
        Ct23        TYPE string,
        NgayNhapKho TYPE string,
      END OF ty_file_up_gen,

      ty_t_file_up_gen TYPE STANDARD TABLE OF ty_file_up_gen WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_file_up_loi,
        SoBb TYPE string,
        Ct33 TYPE string,
        Ct34 TYPE string,
        Ct35 TYPE string,
        Ct36 TYPE string,
        Ct37 TYPE string,
        Ct38 TYPE string,
        Ct39 TYPE string,
        Ct41 TYPE string,
        Ct42 TYPE string,
        Ct43 TYPE string,
        Ct44 TYPE string,
        Ct45 TYPE string,
        Ct46 TYPE string,
      END OF ty_file_up_loi,

      ty_t_file_up_loi TYPE STANDARD TABLE OF ty_file_up_loi WITH EMPTY KEY.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZrTbbbGc RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ZrTbbbGc RESULT result.

    METHODS btnPrintPDF FOR MODIFY
      IMPORTING keys FOR ACTION ZrTbbbGc~btnPrintPDF RESULT result.

    METHODS Copy FOR MODIFY
      IMPORTING keys FOR ACTION ZrTbbbGc~Copy RESULT result.

    METHODS checkInputFields FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZrTbbbGc~checkInputFields.

    METHODS checkInputFields_u FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZrTbbbGc~checkInputFields_u.

    METHODS SetData_GC FOR DETERMINE ON SAVE
      IMPORTING keys FOR ZrTbbbGc~SetData_GC.

    METHODS checkInputFields_Save FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZrTbbbGc~checkInputFields_Save.
    METHODS CreateError FOR MODIFY
      IMPORTING keys FOR ACTION ZrTbbbGc~CreateError RESULT result.
    METHODS SetDefault FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZrTbbbGc~SetDefault.
    METHODS DownloadError FOR MODIFY
      IMPORTING keys FOR ACTION ZrTbbbGc~DownloadError RESULT result.

    METHODS DownloadGeneral FOR MODIFY
      IMPORTING keys FOR ACTION ZrTbbbGc~DownloadGeneral RESULT result.

    METHODS UploadError FOR MODIFY
      IMPORTING keys FOR ACTION ZrTbbbGc~UploadError.

    METHODS UploadGeneral FOR MODIFY
      IMPORTING keys FOR ACTION ZrTbbbGc~UploadGeneral.
    METHODS Close FOR MODIFY
      IMPORTING keys FOR ACTION ZrTbbbGc~Close RESULT result.

    METHODS Open FOR MODIFY
      IMPORTING keys FOR ACTION ZrTbbbGc~Open RESULT result.

ENDCLASS.

CLASS lhc_ZrTbbbGc IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zr_tbbb_gc IN LOCAL MODE
            ENTITY ZrTbbbGc
               FIELDS (  Trangthai SoBbBase )
               WITH CORRESPONDING #( keys )
             RESULT DATA(lt_read_data)
             FAILED failed.

    result = VALUE #( FOR ls_data_for IN lt_read_data
                   ( %tky                           = ls_data_for-%tky

                     %features-%update = COND #( WHEN ls_data_for-Trangthai > '1' AND ls_data_for-Trangthai <> '9'
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                     %features-%delete = COND #( WHEN ls_data_for-Trangthai > '1' AND ls_data_for-Trangthai <> '9'
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                     %features-%field-Ct12 = COND #( WHEN ls_data_for-SoBbBase <> ''
                                                              THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted  )
                    %features-%field-Ct13 = COND #( WHEN ls_data_for-SoBbBase <> ''
                                                              THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted  )
                   %features-%field-Ct23 = COND #( WHEN ls_data_for-Trangthai = '1'
                                                              THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted  )
                    %features-%field-NgayNhapHang = COND #( WHEN ls_data_for-Trangthai = '1'
                                                              THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted  )
                    %features-%field-NgayLapBb = COND #( WHEN ls_data_for-Trangthai = '1'
                                                              THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted  )
                   %features-%field-NgayNhapKho = COND #( WHEN ls_data_for-Trangthai = '1'
                                                              THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted  )

                   %features-%action-CreateError = COND #( WHEN ls_data_for-Trangthai = '1' OR ls_data_for-%is_draft = if_abap_behv=>mk-on
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                    %features-%action-Close = COND #( WHEN ls_data_for-Trangthai <> '1'
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                     %features-%action-Open = COND #( WHEN ls_data_for-Trangthai <> '2'
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )

                  ) ).

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD btnPrintPDF.

    zcl_bbgc_ex_pdf=>btnprintpdf_pkt(
     EXPORTING
       keys     = keys
*      IMPORTING
*        O_PDF    = LV_FILE_CONTENT
     CHANGING
       result   = result
       mapped   = mapped
       failed   = failed
       reported = reported
   ).
  ENDMETHOD.

  METHOD Copy.
    READ ENTITIES OF zr_tbbb_gc IN LOCAL MODE
        ENTITY ZrTbbbGc
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(zr_tbbb_gc).

    LOOP AT zr_tbbb_gc INTO DATA(ls_gc).
      TRY.
          DATA(lv_cid) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
        CATCH cx_uuid_error.
          "Error handling
      ENDTRY.
      ls_gc-SoBbBase = ls_gc-SoBb.
      ls_gc-NgayLapBb = zcl_utility=>get_current_date( ).
      MODIFY ENTITIES OF zr_tbbb_gc IN LOCAL MODE
      ENTITY ZrTbbbGc
      CREATE FIELDS ( SoBbBase SoPo  ct12 ct13 NgayLapBb )
           WITH VALUE #( (  %cid      = lv_cid
                            SoBbBase = ls_gc-SoBbBase
                            NgayLapBb = ls_gc-NgayLapBb
                            SoPo     = ls_gc-SoPo
                            Ct12     = ls_gc-Ct12
                            Ct13     = ls_gc-Ct13
                           ) )
            REPORTED DATA(ls_cr_reported).
    ENDLOOP.

*    result = VALUE #( FOR ls_for IN zr_tbbb_gc ( %tky   = ls_for-%tky
*                                                 %param = ls_for ) ).
  ENDMETHOD.

  METHOD checkInputFields.
    READ ENTITIES OF zr_tbbb_gc IN LOCAL MODE
       ENTITY ZrTbbbGc
       FIELDS ( SoPo )
       WITH CORRESPONDING #( keys )
       RESULT DATA(zr_tbbb_gc).

    LOOP AT zr_tbbb_gc INTO DATA(ls_gc).
      APPEND VALUE #(  %tky           = ls_gc-%tky
                      %state_area    = 'SoPO'
                    ) TO reported-zrtbbbgc.
      SELECT SINGLE * FROM zv_po_gc
        WHERE PurchaseOrder = @ls_gc-SoPo
        INTO @DATA(ls_po_check).
      IF sy-subrc IS NOT INITIAL.
*        APPEND VALUE #(  %tky = ls_gc-%tky ) TO failed-ZrTbbbGc.
        APPEND VALUE #( %tky          = ls_gc-%tky
                        %state_area   = 'SoPO'
                        %msg          = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Số PO gia công không tồn tại' )
                        %element-SoPo = if_abap_behv=>mk-on
                      ) TO reported-zrtbbbgc.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD checkInputFields_u.
  ENDMETHOD.

  METHOD SetData_GC.
    DATA: lt_dtl TYPE TABLE FOR CREATE zr_tbbb_gc\_dtl,
          ls_dtl TYPE STRUCTURE FOR CREATE zr_tbbb_gc\_dtl.
    DATA: lw_so_bb_num TYPE  ztb_bb_gc-so_bb_num,
          lw_so_bb_num5 TYPE  zde_numc_5,
          lw_so_bb_sub TYPE  ztb_bb_gc-so_bb_sub,
          lw_so_bb     TYPE  ztb_bb_gc-so_bb.

    "Read travel instances of the transferred keys
    READ ENTITIES OF zr_tbbb_gc IN LOCAL MODE
     ENTITY ZrTbbbGc
       ALL FIELDS
       WITH CORRESPONDING #( keys )
     RESULT DATA(GiaCong_data)
     FAILED DATA(read_failed).

    READ TABLE keys INTO DATA(ls_key) INDEX 1.
    READ TABLE GiaCong_data INTO DATA(ls_gia_cong) INDEX 1.
    CHECK sy-subrc IS INITIAL.
    CHECK ls_gia_cong-SoBbBase IS INITIAL.

*    SELECT so_bb_num, MAX( so_bb_sub ) AS so_bb_sub FROM ztb_bb_gc
*    WHERE loai_hang = @ls_gia_cong-LoaiHang AND so_po = @ls_gia_cong-SoPo
*     GROUP BY so_bb_num
*     INTO TABLE @DATA(lt_so_bb_sub).
*    IF sy-subrc IS INITIAL.
*      READ TABLE lt_so_bb_sub INDEX 1 INTO DATA(ls_so_bb_sub).
*      lw_so_bb_sub = ls_so_bb_sub-so_bb_sub + 1.
*      lw_so_bb_num = ls_so_bb_sub-so_bb_num.
*    ELSE.
    SELECT MAX( so_bb_num ) FROM ztb_bb_gc
        WHERE loai_hang = @ls_gia_cong-LoaiHang AND substring( ngay_nhap_hang, 1, 6 ) = @ls_gia_cong-NgayNhapHang(6)
         INTO @lw_so_bb_num.
    lw_so_bb_num = lw_so_bb_num + 1.
*    ENDIF.

    IF ls_gia_cong-LoaiHang = '1'.
      lw_so_bb = 'HO_' .
    ELSE.
      lw_so_bb = 'HV_'.
    ENDIF.
    lw_so_bb_num5 = lw_so_bb_num.
    lw_so_bb = lw_so_bb && ls_gia_cong-NgayNhapHang+2(2) && ls_gia_cong-NgayNhapHang+4(2) && '_' && lw_so_bb_num5.
*    IF lw_so_bb_sub IS NOT INITIAL.
*      lw_so_bb = lw_so_bb && '_' && lw_so_bb_sub.
*    ENDIF.

    "else set overall travel status to open ('O')
    MODIFY ENTITIES OF zr_tbbb_gc IN LOCAL MODE
      ENTITY ZrTbbbGc
        UPDATE FIELDS ( SoBb SoBbNum SoBbSub )
        WITH VALUE #(
          ( %tky = ls_gia_cong-%tky
            SoBb = lw_so_bb
            SoBbNum = lw_so_bb_num
            SoBbSub = lw_so_bb_sub )
        ).

    SELECT * FROM ztb_loi_h_dtl
    WHERE loai_hang = @ls_gia_cong-LoaiHang
    INTO TABLE @DATA(lt_loi).
    SORT lt_loi BY loai_loi error_code.
    LOOP AT lt_loi INTO DATA(ls_loi).
      ls_dtl-HdrID = ls_key-HdrID.
      ls_dtl-%target =  VALUE #(  ( %cid = 'Dtl' && sy-tabix
                                                    LoaiLoi = ls_loi-loai_loi
                                                    LoaiHang = ls_loi-loai_hang
                                                    ErrorCode = ls_loi-error_code
                                                    Errordesc = ls_loi-errordesc
                                                    Bangi = ls_loi-bangi
                                                    Bangii = ls_loi-bangii
                                                    ) ) .
      APPEND ls_dtl TO lt_dtl.
    ENDLOOP.

    "else set overall travel status to open ('O')
    MODIFY ENTITIES OF zr_tbbb_gc IN LOCAL MODE
     ENTITY ZrTbbbGc
       CREATE BY \_dtl
             FIELDS ( LoaiLoi  LoaiHang   ErrorCode Errordesc   Bangi    Bangii  )
               WITH lt_dtl
               REPORTED DATA(update_reported1).
  ENDMETHOD.

  METHOD checkInputFields_Save.
    CLEAR: reported-zrtbbbgc[].
    READ ENTITIES OF zr_tbbb_gc IN LOCAL MODE
      ENTITY ZrTbbbGc
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(zr_tbbb_gc).

    LOOP AT zr_tbbb_gc INTO DATA(ls_gc).
      APPEND VALUE #(  %tky           = ls_gc-%tky
                      %state_area    = 'CHECKDATA'
                    ) TO reported-zrtbbbgc.
      SELECT SINGLE * FROM zv_po_gc
        WHERE PurchaseOrder = @ls_gc-SoPo
        INTO @DATA(ls_po_check).
      IF sy-subrc IS NOT INITIAL. "AND sy-mandt <> '80'.
        APPEND VALUE #(  %tky = ls_gc-%tky ) TO failed-ZrTbbbGc.
        APPEND VALUE #( %tky          = ls_gc-%tky
                        %state_area   = 'CHECKDATA'
                        %msg          = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Số PO gia công không tồn tại' )
                        %element-SoPo = if_abap_behv=>mk-on
                      ) TO reported-zrtbbbgc.
      ENDIF.

      IF ls_gc-Ct12 IS  INITIAL.
        APPEND VALUE #(  %tky = ls_gc-%tky ) TO failed-ZrTbbbGc.
        APPEND VALUE #( %tky          = ls_gc-%tky
                        %state_area   = 'CHECKDATA'
                        %msg          = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Nhập Tổng cái' )
                        %element-Ct12 = if_abap_behv=>mk-on
                      ) TO reported-zrtbbbgc.
      ENDIF.

      IF  ls_gc-Ct13 IS  INITIAL.
        APPEND VALUE #(  %tky = ls_gc-%tky ) TO failed-ZrTbbbGc.
        APPEND VALUE #( %tky          = ls_gc-%tky
                        %state_area   = 'CHECKDATA'
                        %msg          = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Nhập Số lượng kiểm' )
                        %element-Ct13 = if_abap_behv=>mk-on
                      ) TO reported-zrtbbbgc.
      ENDIF.

      IF  ls_gc-NgayNhapHang IS  INITIAL.
        APPEND VALUE #(  %tky = ls_gc-%tky ) TO failed-ZrTbbbGc.
        APPEND VALUE #( %tky          = ls_gc-%tky
                        %state_area   = 'CHECKDATA'
                        %msg          = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Nhập ngày nhập hàng' )
                        %element-NgayNhapHang = if_abap_behv=>mk-on
                      ) TO reported-zrtbbbgc.
      ENDIF.

*       IF  ls_gc-NgayNhapHang IS  INITIAL.
*        APPEND VALUE #(  %tky = ls_gc-%tky ) TO failed-ZrTbbbGc.
*        APPEND VALUE #( %tky          = ls_gc-%tky
*                        %state_area   = 'CHECKDATA'
*                        %msg          = new_message_with_text(
*                                severity = if_abap_behv_message=>severity-error
*                                text     = 'Nhập ngày nhập hàng' )
*                        %element-Ct13 = if_abap_behv=>mk-on
*                      ) TO reported-zrtbbbgc.
*      ENDIF.
    ENDLOOP.

    READ ENTITIES OF zr_tbbb_gc IN LOCAL MODE
      ENTITY ZrTbgcLoi
      FIELDS ( LoaiLoi  ErrorCode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(ZrTbgcLoi).
    DELETE ZrTbgcLoi WHERE LoaiLoi = 'A' OR LoaiLoi = 'B'.
    LOOP AT ZrTbgcLoi INTO DATA(ls_loi).
      APPEND VALUE #(  %tky           = ls_gc-%tky
                      %state_area    = 'ErrorCode'
                    ) TO reported-zrtbgcloi.
      LOOP AT ZrTbgcLoi INTO DATA(ls_loi_check)
        WHERE ErrorCode = ls_loi-ErrorCode AND %tky <> ls_loi-%tky.

        APPEND VALUE #(  %tky = ls_loi-%tky ) TO failed-zrtbgcloi.
        APPEND VALUE #( %tky          = ls_loi-%tky
                        %state_area   = 'ErrorCode'
                        %msg          = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Trùng mã lỗi' )
                        %element-ErrorCode = if_abap_behv=>mk-on
                      ) TO reported-zrtbgcloi.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD CreateError.
    DATA: lt_dtl TYPE TABLE FOR CREATE zr_tbbb_gc\_dtl,
          ls_dtl TYPE STRUCTURE FOR CREATE zr_tbbb_gc\_dtl.
    DATA: lw_count TYPE i.
    READ TABLE keys INTO DATA(ls_key) INDEX 1.

    READ ENTITIES OF zr_tbbb_gc IN LOCAL MODE
          ENTITY ZrTbbbGc
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(zr_tbbb_gc).

    LOOP AT zr_tbbb_gc INTO DATA(ls_gc).
      SELECT * FROM zr_tbgc_loi
          WHERE hdrid = @ls_gc-hdrid
          INTO TABLE @DATA(zr_dtl).
      DATA(lw_from) = ls_key-%param-errorcodefr.
      DATA(lw_to)   = ls_key-%param-errorcodeto.
      WHILE lw_from <= lw_to.

        lw_count += 1.

        LOOP  AT zr_dtl INTO DATA(ls_dtl_check)
          WHERE HdrID = ls_gc-HdrID AND ErrorCode  = lw_from AND ( LoaiLoi = 'C' OR LoaiLoi = '' ).
          EXIT.
        ENDLOOP.
        IF sy-subrc IS NOT INITIAL.
          ls_dtl-HdrID = ls_key-HdrID.
          ls_dtl-%target =  VALUE #(  ( %cid = 'Dtl' && lw_count
                                                        LoaiLoi = 'C'
                                                        LoaiHang = ls_gc-loaihang
                                                        ErrorCode = lw_from
                                                        ) ) .
          APPEND ls_dtl TO lt_dtl.
        ENDIF.
        lw_from += 1.
      ENDWHILE.
    ENDLOOP.

    MODIFY ENTITIES OF zr_tbbb_gc IN LOCAL MODE
         ENTITY ZrTbbbGc
           CREATE BY \_dtl
                 FIELDS ( LoaiLoi  LoaiHang   ErrorCode   )
                   WITH lt_dtl
                   REPORTED DATA(update_reported1).

    "return result entities
    result = VALUE #( FOR ls_for IN zr_tbbb_gc ( %tky   = ls_for-%tky
                                                  %param = ls_for ) ).
  ENDMETHOD.

  METHOD SetDefault.
    "Read travel instances of the transferred keys
    DATA: lw_dat      TYPE zde_date.

    lw_dat = xco_cp=>sy->moment( xco_cp_time=>time_zone->user )->date->as( xco_cp_time=>format->abap )->value.
    READ ENTITIES OF zr_tbbb_gc IN LOCAL MODE
     ENTITY ZrTbbbGc
     ALL  FIELDS
       WITH CORRESPONDING #( keys )
     RESULT DATA(GiaCong_data)
     FAILED DATA(read_failed).

    READ TABLE keys INTO DATA(ls_key) INDEX 1.
    READ TABLE GiaCong_data INTO DATA(ls_gia_cong) INDEX 1.

    "else set overall travel status to open ('O')
    MODIFY ENTITIES OF zr_tbbb_gc IN LOCAL MODE
      ENTITY ZrTbbbGc
        UPDATE FIELDS ( NgayLapBb NgayNhapHang )
        WITH VALUE #(
          ( %tky = ls_gia_cong-%tky
            NgayLapBb = lw_dat
            NgayNhapHang = lw_dat )
        ).
  ENDMETHOD.


  METHOD DownloadError.
    DATA LT_File TYPE STANDARD TABLE OF ty_file_up_loi WITH DEFAULT KEY.

    "XCOライブラリを使用したExcelファイルの書き込み
    DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
    DATA(lo_worksheet) = lo_write_access->get_workbook(
        )->worksheet->at_position( 1 ).

    DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
                               )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                               )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'N' )
                               )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
                               )->get_pattern( ).

    READ TABLE keys INDEX 1 INTO DATA(k).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    "ヘッダの設定（すべての項目はstring型）
    lt_file = VALUE #(
************Line One
                       (
                     SoBb       = 'Biên bản số'
                     Ct33                  = 'Lỗi manh'
                     ct34             = 'Lỗi in'
                     ct35             = 'Bong keo'
                     ct36             = 'Bẩn manh'
                     ct37             = 'Lỗi côn trùng'
                     ct38             = 'Phế thử tải'
                     ct39             = 'Lỗi khác'
                     ct41             = 'Bẩn'
                     ct42             = 'Rách'
                     ct43             = 'Sai quy cách'
                     ct44             = 'May xấu'
                     ct45             = 'Lỗ chân kim'
                     ct46             = 'Nhàu nát'
                       ) ).
    DATA: lw_hdr_id TYPE zr_tbbb_gc-hdrid.
    IF k-%param-hdrid IS NOT INITIAL AND k-%param-hdrid NE 'null'.
      SPLIT k-%param-hdrid AT ',' INTO TABLE DATA(lt_hdrid_split).

      LOOP AT lt_hdrid_split INTO DATA(lv_hdrid_str).
        " Lấy header
        REPLACE ALL OCCURRENCES OF '-' IN lv_hdrid_str WITH ''.
        TRANSLATE lv_hdrid_str TO UPPER CASE.
        lw_hdr_id = lv_hdrid_str.
        SELECT SINGLE * FROM zr_tbbb_gc
          WHERE hdrid = @lv_hdrid_str
          INTO @DATA(ls_bbgc).
        IF sy-subrc IS INITIAL.
          APPEND INITIAL LINE TO lt_file ASSIGNING FIELD-SYMBOL(<fs_file>).
          <fs_file>-SoBb = ls_bbgc-SoBb.
          <fs_file>-Ct33 = ls_bbgc-Ct33.
          <fs_file>-Ct34 = ls_bbgc-Ct34.
          <fs_file>-Ct35 = ls_bbgc-Ct35.
          <fs_file>-Ct36 = ls_bbgc-Ct36.
          <fs_file>-Ct37 = ls_bbgc-Ct37.
          <fs_file>-Ct38 = ls_bbgc-Ct38.
          <fs_file>-Ct39 = ls_bbgc-Ct39.
          <fs_file>-Ct41 = ls_bbgc-Ct41.
          <fs_file>-Ct42 = ls_bbgc-Ct42.
          <fs_file>-Ct43 = ls_bbgc-Ct43.
          <fs_file>-Ct44 = ls_bbgc-Ct44.
          <fs_file>-Ct45 = ls_bbgc-Ct45.
          <fs_file>-Ct46 = ls_bbgc-Ct46.
        ENDIF.

      ENDLOOP.
    ENDIF.

    lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_from( REF #( lt_file )
        )->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    SELECT SINGLE *
    FROM zcore_tb_temppdf
    WHERE id = 'BBGC_TT_LOI'
    INTO @DATA(ls_tb_temppdf).

    IF sy-subrc NE 0.
      DATA(lv_exist) = abap_false.
    ELSE.
      lv_exist = abap_true.
    ENDIF.

    IF NOT lv_exist IS NOT INITIAL.
      result = VALUE #( FOR key IN keys (
                        %cid   = key-%cid
                        %param = VALUE #( filecontent   = lv_file_content
                                          filename      = 'BBGC_TT_Loi_template'
                                          fileextension = 'xlsx'
                                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                        ) ).
    ELSE.
      result = VALUE #( FOR key IN keys (
                        %cid   = key-%cid
                        %param = VALUE #( filecontent   = ls_tb_temppdf-file_content
                                          filename      = 'BBGC_TT_Loi_template'
                                          fileextension = 'xlsx'
                                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                        ) ).
    ENDIF.
  ENDMETHOD.

  METHOD DownloadGeneral.

    DATA LT_File TYPE STANDARD TABLE OF ty_file_up_gen WITH DEFAULT KEY.

    "XCOライブラリを使用したExcelファイルの書き込み
    DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
    DATA(lo_worksheet) = lo_write_access->get_workbook(
        )->worksheet->at_position( 1 ).

    DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
                               )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                               )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'C' )
                               )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
                               )->get_pattern( ).

    READ TABLE keys INDEX 1 INTO DATA(k).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    "ヘッダの設定（すべての項目はstring型）
    lt_file = VALUE #(
************Line One
                       (
                     SoBb       = 'Biên bản số'
                     Ct23                  = 'Tổng cộng'
                     ngaynhapkho             = 'Ngày nhập kho'
                       ) ).

    DATA: lw_hdr_id TYPE zr_tbbb_gc-hdrid.
    IF k-%param-hdrid IS NOT INITIAL AND k-%param-hdrid NE 'null'.
      SPLIT k-%param-hdrid AT ',' INTO TABLE DATA(lt_hdrid_split).

      LOOP AT lt_hdrid_split INTO DATA(lv_hdrid_str).
        " Lấy header
        REPLACE ALL OCCURRENCES OF '-' IN lv_hdrid_str WITH ''.
        TRANSLATE lv_hdrid_str TO UPPER CASE.
        lw_hdr_id = lv_hdrid_str.
        SELECT SINGLE * FROM zr_tbbb_gc
          WHERE hdrid = @lw_hdr_id
          INTO @DATA(ls_bbgc).
        IF sy-subrc IS INITIAL.
          APPEND INITIAL LINE TO lt_file ASSIGNING FIELD-SYMBOL(<fs_file>).
          <fs_file>-SoBb = ls_bbgc-SoBb.
          <fs_file>-Ct23 = ls_bbgc-Ct23.
          <fs_file>-NgayNhapKho = ls_bbgc-NgayNhapKho.
        ENDIF.

      ENDLOOP.
    ENDIF.

    lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_from( REF #( lt_file )
        )->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    SELECT SINGLE *
    FROM zcore_tb_temppdf
    WHERE id = 'BBGC_TT_CHUNG'
    INTO @DATA(ls_tb_temppdf).

    IF sy-subrc NE 0.
      DATA(lv_exist) = abap_false.
    ELSE.
      lv_exist = abap_true.
    ENDIF.

    IF NOT lv_exist IS NOT INITIAL.
      result = VALUE #( FOR key IN keys (
                        %cid   = key-%cid
                        %param = VALUE #( filecontent   = lv_file_content
                                          filename      = 'BBGC_TT_Chung_template'
                                          fileextension = 'xlsx'
                                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                        ) ).
    ELSE.
      result = VALUE #( FOR key IN keys (
                        %cid   = key-%cid
                        %param = VALUE #( filecontent   = ls_tb_temppdf-file_content
                                          filename      = 'BBGC_TT_Chung_template'
                                          fileextension = 'xlsx'
                                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                        ) ).
    ENDIF.
  ENDMETHOD.

  METHOD UploadError.
    DATA: lt_file   TYPE STANDARD TABLE OF ty_file_up_loi.
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_keys>) INDEX 1.

    CHECK sy-subrc = 0.

    DATA(lv_filecontent) = <ls_keys>-%param-filecontent.

    "xcoライブラリを使用したexcelファイルの読み取り
    FINAL(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_filecontent )->read_access( ).
    FINAL(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

    FINAL(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    FINAL(lo_execute) = lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_file ) ).

    lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
               )->if_xco_xlsx_ra_operation~execute( ).

    IF lt_file IS NOT INITIAL.
      DELETE lt_file INDEX 1.
    ENDIF.

    DATA: lt_zrtbbbgc_c TYPE TABLE FOR UPDATE zr_tbbb_gc,
          ls_zrtbbbgc_c TYPE STRUCTURE FOR UPDATE zr_tbbb_gc.

    LOOP AT lt_file INTO DATA(ls_file).
      SELECT SINGLE * FROM zr_tbbb_gc
        WHERE sobb = @ls_file-SoBb
        INTO @DATA(ls_zrtbbbgc).
      IF sy-subrc IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      ls_zrtbbbgc-Ct33 = ls_file-ct33.
      ls_zrtbbbgc-Ct34 = ls_file-ct34.
      ls_zrtbbbgc-Ct35 = ls_file-ct35.
      ls_zrtbbbgc-Ct36 = ls_file-ct36.
      ls_zrtbbbgc-Ct37 = ls_file-ct37.
      ls_zrtbbbgc-Ct38 = ls_file-ct38.
      ls_zrtbbbgc-Ct39 = ls_file-ct39.
      ls_zrtbbbgc-Ct41 = ls_file-ct41.
      ls_zrtbbbgc-Ct42 = ls_file-ct42.
      ls_zrtbbbgc-Ct43 = ls_file-ct43.
      ls_zrtbbbgc-Ct44 = ls_file-ct44.
      ls_zrtbbbgc-Ct45 = ls_file-ct45.
      ls_zrtbbbgc-Ct46 = ls_file-ct46.
      MODIFY ENTITIES OF zr_tbbb_gc IN LOCAL MODE
          ENTITY ZrTbbbGc
            UPDATE FIELDS ( ct33 ct34 ct35 ct36 ct37 ct38 ct39 ct41 ct42 ct43 ct44 ct45 ct46 )
            WITH VALUE #(
              ( %tky-HdrID = ls_zrtbbbgc-HdrID

                ct33 = ls_zrtbbbgc-Ct33
                ct34 = ls_zrtbbbgc-Ct34
                ct35 = ls_zrtbbbgc-Ct35
                ct36 = ls_zrtbbbgc-Ct36
                ct37 = ls_zrtbbbgc-Ct37
                ct38 = ls_zrtbbbgc-Ct38
                ct39 = ls_zrtbbbgc-Ct39
                ct41 = ls_zrtbbbgc-Ct41
                ct42 = ls_zrtbbbgc-Ct42
                ct43 = ls_zrtbbbgc-Ct43
                ct44 = ls_zrtbbbgc-Ct44
                ct45 = ls_zrtbbbgc-Ct45
                ct46 = ls_zrtbbbgc-Ct46 )
                   ).
    ENDLOOP.

  ENDMETHOD.

  METHOD UploadGeneral.
    DATA: lt_file   TYPE STANDARD TABLE OF ty_file_up_gen.
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_keys>) INDEX 1.

    CHECK sy-subrc = 0.

    DATA(lv_filecontent) = <ls_keys>-%param-filecontent.

    "xcoライブラリを使用したexcelファイルの読み取り
    FINAL(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_filecontent )->read_access( ).
    FINAL(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

    FINAL(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    FINAL(lo_execute) = lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_file ) ).

    lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
               )->if_xco_xlsx_ra_operation~execute( ).

    IF lt_file IS NOT INITIAL.
      DELETE lt_file INDEX 1.
    ENDIF.

    DATA: lt_zrtbbbgc_c TYPE TABLE FOR UPDATE zr_tbbb_gc,
          ls_zrtbbbgc_c TYPE STRUCTURE FOR UPDATE zr_tbbb_gc.

    LOOP AT lt_file INTO DATA(ls_file).
      SELECT SINGLE * FROM zr_tbbb_gc
        WHERE sobb = @ls_file-SoBb
        INTO @DATA(ls_zrtbbbgc).
      IF sy-subrc IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      TRY.

          cl_abap_datfm=>conv_date_ext_to_int(
            EXPORTING
              im_datext    = ls_file-NgayNhapKho
              im_datfmdes  = '5'
      IMPORTING
        ex_datint    = DATA(lw_date)
                 ).
        CATCH cx_abap_datfm_no_date cx_abap_datfm_invalid_date cx_abap_datfm_format_unknown cx_abap_datfm_ambiguous INTO DATA(oref).
          CONTINUE.
      ENDTRY.

      ls_zrtbbbgc-NgayNhapKho = lw_date.
      CLEAR lw_date.
      ls_zrtbbbgc-Ct23 = ls_file-Ct23.
      MODIFY ENTITIES OF zr_tbbb_gc IN LOCAL MODE
          ENTITY ZrTbbbGc
            UPDATE FIELDS ( ct23 NgayNhapKho )
            WITH VALUE #(
              ( %tky-HdrID = ls_zrtbbbgc-HdrID
                ct23 = ls_zrtbbbgc-Ct23
                NgayNhapKho = ls_zrtbbbgc-NgayNhapKho )
            ).
    ENDLOOP.


  ENDMETHOD.

  METHOD Close.
    READ ENTITIES OF zr_tbbb_gc IN LOCAL MODE
       ENTITY ZrTbbbGc
       ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_data_read).

    LOOP AT lt_data_read INTO DATA(ls_data_read) WHERE trangthai = '1'.

      MODIFY ENTITIES OF zr_tbbb_gc IN LOCAL MODE
        ENTITY ZrTbbbGc
          UPDATE FIELDS ( trangthai )
          WITH VALUE #(
            ( %tky = ls_data_read-%tky
              trangthai =  '2' ) ).
    ENDLOOP.

    "return result entities
    result = VALUE #( FOR ls_for IN lt_data_read ( %tky   = ls_for-%tky
                                                  %param = ls_for ) ).
  ENDMETHOD.

  METHOD Open.
    READ ENTITIES OF zr_tbbb_gc IN LOCAL MODE
     ENTITY ZrTbbbGc
     ALL FIELDS
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_data_read).

    LOOP AT lt_data_read INTO DATA(ls_data_read) WHERE trangthai = '2'.

      MODIFY ENTITIES OF zr_tbbb_gc IN LOCAL MODE
        ENTITY ZrTbbbGc
          UPDATE FIELDS ( trangthai )
          WITH VALUE #(
            ( %tky = ls_data_read-%tky
              trangthai =  '1' ) ).
    ENDLOOP.

    "return result entities
    result = VALUE #( FOR ls_for IN lt_data_read ( %tky   = ls_for-%tky
                                                  %param = ls_for ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZR_TBBB_GC DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZR_TBBB_GC IMPLEMENTATION.

  METHOD save_modified.
    DATA : lt_bb_gc    TYPE STANDARD TABLE OF ztb_bb_gc,
           lt_bb_gc_ud TYPE STANDARD TABLE OF ztb_bb_gc,
           ls_bb_gc    TYPE                   ztb_bb_gc,
           ls_bb_gc_db TYPE                   ztb_bb_gc,
           ls_bb_gc_ud TYPE                   ztb_bb_gc.

    DATA : lt_gc_loi TYPE STANDARD TABLE OF ztb_gc_loi,
           ls_gc_loi TYPE                   ztb_gc_loi.
    DATA: lw_field_name TYPE char72.

    TYPES: BEGIN OF ty_mapping,
             field_ent TYPE string,
             field_db  TYPE string,
           END OF ty_mapping.

    DATA: gt_mapping TYPE STANDARD TABLE OF ty_mapping WITH DEFAULT KEY.

    "Insert các cặp mapping
    APPEND VALUE #( field_ent = 'HdrID'         field_db = 'hdr_id' )         TO gt_mapping.
    APPEND VALUE #( field_ent = 'LoaiHang'      field_db = 'loai_hang' )     TO gt_mapping.
    APPEND VALUE #( field_ent = 'SoBb'          field_db = 'so_bb' )         TO gt_mapping.
    APPEND VALUE #( field_ent = 'SoBbNum'       field_db = 'so_bb_num' )     TO gt_mapping.
    APPEND VALUE #( field_ent = 'SoBbSub'       field_db = 'so_bb_sub' )     TO gt_mapping.
    APPEND VALUE #( field_ent = 'NgayLapBb'     field_db = 'ngay_lap_bb' )   TO gt_mapping.
    APPEND VALUE #( field_ent = 'SoPo'          field_db = 'so_po' )         TO gt_mapping.
    APPEND VALUE #( field_ent = 'NgayNhapHang'  field_db = 'ngay_nhap_hang' ) TO gt_mapping.
    APPEND VALUE #( field_ent = 'NgayTraBb'     field_db = 'ngay_tra_bb' )   TO gt_mapping.
    APPEND VALUE #( field_ent = 'NgayNhapKho'   field_db = 'ngay_nhap_kho' ) TO gt_mapping.
    APPEND VALUE #( field_ent = 'GhiChu'        field_db = 'ghi_chu' )       TO gt_mapping.
    APPEND VALUE #( field_ent = 'CreatedBy'     field_db = 'created_by' )    TO gt_mapping.
    APPEND VALUE #( field_ent = 'CreatedAt'     field_db = 'created_at' )    TO gt_mapping.
    APPEND VALUE #( field_ent = 'LastChangedBy' field_db = 'last_changed_by' ) TO gt_mapping.
    APPEND VALUE #( field_ent = 'LastChangedAt' field_db = 'last_changed_at' ) TO gt_mapping.
    LOOP AT gt_mapping ASSIGNING FIELD-SYMBOL(<fs_mapping>).
      TRANSLATE <fs_mapping>-field_ent TO UPPER CASE.
      TRANSLATE <fs_mapping>-field_db TO UPPER CASE.
    ENDLOOP.
    DATA: gt_mapping_loi TYPE STANDARD TABLE OF ty_mapping WITH DEFAULT KEY.

    "Insert các cặp mapping
    APPEND VALUE #( field_ent = 'HdrID'         field_db = 'hdr_id' )         TO gt_mapping_loi.
    APPEND VALUE #( field_ent = 'DtlID'         field_db = 'dtl_id' )         TO gt_mapping_loi.
    APPEND VALUE #( field_ent = 'LoaiHang'      field_db = 'loai_hang' )      TO gt_mapping_loi.
    APPEND VALUE #( field_ent = 'LoaiLoi'       field_db = 'loai_loi' )       TO gt_mapping_loi.
    APPEND VALUE #( field_ent = 'ErrorCode'     field_db = 'error_code' )     TO gt_mapping_loi.
    APPEND VALUE #( field_ent = 'SlLoi'         field_db = 'sl_loi' )         TO gt_mapping_loi.
    APPEND VALUE #( field_ent = 'CheckBangi'    field_db = 'check_bangi' )    TO gt_mapping_loi.
    APPEND VALUE #( field_ent = 'CheckBangii'   field_db = 'check_bangii' )   TO gt_mapping_loi.
    APPEND VALUE #( field_ent = 'GhiChu'        field_db = 'ghi_chu' )        TO gt_mapping_loi.
    APPEND VALUE #( field_ent = 'CreatedBy'     field_db = 'created_by' )     TO gt_mapping_loi.
    APPEND VALUE #( field_ent = 'CreatedAt'     field_db = 'created_at' )     TO gt_mapping_loi.
    APPEND VALUE #( field_ent = 'LastChangedBy' field_db = 'last_changed_by') TO gt_mapping_loi.
    APPEND VALUE #( field_ent = 'LastChangedAt' field_db = 'last_changed_at') TO gt_mapping_loi.

    LOOP AT gt_mapping_loi ASSIGNING  <fs_mapping>.
      TRANSLATE <fs_mapping>-field_ent TO UPPER CASE.
      TRANSLATE <fs_mapping>-field_db TO UPPER CASE.
    ENDLOOP.

    IF create-zrtbbbgc IS NOT INITIAL.
      lt_bb_gc = CORRESPONDING #( create-zrtbbbgc MAPPING FROM ENTITY ).

      LOOP AT lt_bb_gc INTO ls_bb_gc.
        IF ls_bb_gc-so_bb_base IS NOT INITIAL.
          DATA: lw_so_bb_sub TYPE ztb_bb_gc-so_bb_sub.
          lw_so_bb_sub = '00'.
          SELECT SINGLE * FROM ztb_bb_gc
            WHERE so_bb = @ls_bb_gc-so_bb_base
            INTO @DATA(ls_bb_gc_base).
          IF sy-subrc IS INITIAL.
            SELECT * FROM ztb_gc_loi
              WHERE hdr_id = @ls_bb_gc_base-hdr_id
              INTO TABLE @DATA(lt_gc_loi_base).

            SELECT so_bb_sub FROM ztb_bb_gc
              WHERE substring( so_bb,1,13 ) = @ls_bb_gc_base-so_bb(13)
              INTO TABLE @DATA(lt_bb_sub).
            DO 100 TIMES.
              lw_so_bb_sub = lw_so_bb_sub + 1.
              READ TABLE lt_bb_sub WITH KEY table_line = lw_so_bb_sub TRANSPORTING NO FIELDS.
              IF sy-subrc IS NOT INITIAL.
                EXIT.
              ENDIF.
            ENDDO.
            ls_bb_gc_base-hdr_id = ls_bb_gc-hdr_id.
            ls_bb_gc_base-so_bb_sub = lw_so_bb_sub.
            ls_bb_gc_base-ngay_lap_bb = ls_bb_gc-ngay_lap_bb.
            ls_bb_gc_base-so_bb_base = ls_bb_gc-so_bb_base.
            ls_bb_gc_base-so_bb = ls_bb_gc_base-so_bb(13) && '_' && lw_so_bb_sub.

            CLEAR:      ls_bb_gc_base-trangthai,
*                        ls_bb_gc_base-ngay_lap_bb,
                          ls_bb_gc_base-ngay_nhap_kho,
                          ls_bb_gc_base-ngay_tra_bb,
                          ls_bb_gc_base-ghi_chu,
                          ls_bb_gc_base-Ct16,
                          ls_bb_gc_base-Ct321,
                          ls_bb_gc_base-Ct322,
                          ls_bb_gc_base-Ct323,
                          ls_bb_gc_base-Ct324,
                          ls_bb_gc_base-bs01,
                          ls_bb_gc_base-bs02,
                          ls_bb_gc_base-bs03,
                          ls_bb_gc_base-bs04,
                          ls_bb_gc_base-bs05,
                          ls_bb_gc_base-bs06,
                          ls_bb_gc_base-bs07,
                          ls_bb_gc_base-Ct33,
                          ls_bb_gc_base-Ct34,
                          ls_bb_gc_base-Ct35,
                          ls_bb_gc_base-Ct36,
                          ls_bb_gc_base-Ct37,
                          ls_bb_gc_base-Ct38,
                          ls_bb_gc_base-Ct39,
                          ls_bb_gc_base-Ct23,
                          ls_bb_gc_base-ct41,
                          ls_bb_gc_base-ct42,
                          ls_bb_gc_base-ct43,
                          ls_bb_gc_base-ct44,
                          ls_bb_gc_base-ct45,
                          ls_bb_gc_base-ct46,
                          ls_bb_gc_base-ct47.

            INSERT ztb_bb_gc FROM  @ls_bb_gc_base.
            LOOP AT lt_gc_loi_base INTO DATA(ls_gc_loi_base).
              ls_gc_loi_base-hdr_id = ls_bb_gc-hdr_id.
              INSERT ztb_gc_loi FROM  @ls_gc_loi_base.
            ENDLOOP.
          ENDIF.
        ELSE.
          IF ls_bb_gc-ct12 IS NOT INITIAL.
            ls_bb_gc-ct14 = ls_bb_gc-ct13 / ls_bb_gc-ct12  * 100.
          ENDIF.

          INSERT ztb_bb_gc FROM  @ls_bb_gc.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT delete-zrtbbbgc INTO DATA(ls_detele)." WHERE HdrID IS NOT INITIAL.
      DELETE FROM ztb_bb_gc WHERE hdr_id = @ls_detele-HdrID.
    ENDLOOP.

    IF create-zrtbgcloi IS NOT INITIAL.
      lt_gc_loi = CORRESPONDING #( create-zrtbgcloi MAPPING FROM ENTITY ).
      LOOP AT lt_gc_loi ASSIGNING FIELD-SYMBOL(<lf_gc_loi>).
        IF <lf_gc_loi>-loai_loi = ''.
          <lf_gc_loi>-loai_loi = 'C'.
        ENDIF.
      ENDLOOP.
      INSERT ztb_gc_loi FROM TABLE @lt_gc_loi.
      SORT lt_gc_loi BY hdr_id.
      DELETE ADJACENT DUPLICATES FROM lt_gc_loi COMPARING hdr_id.
      LOOP AT lt_gc_loi INTO ls_gc_loi.
        SELECT SINGLE * FROM ztb_bb_gc
              WHERE hdr_id = @ls_gc_loi-hdr_id
              INTO @ls_bb_gc.
        IF sy-subrc IS INITIAL.
          APPEND ls_bb_gc TO lt_bb_gc_ud.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF delete-zrtbgcloi IS NOT INITIAL.
      LOOP AT delete-zrtbgcloi INTO DATA(ls_detele_dtl)." WHERE HdrID IS NOT INITIAL AND DtlID IS NOT INITIAL.
        DELETE FROM ztb_gc_loi WHERE hdr_id = @ls_detele_dtl-HdrID AND dtl_id = @ls_detele_dtl-DtlID.
      ENDLOOP.

      lt_gc_loi =  CORRESPONDING #( delete-zrtbgcloi MAPPING FROM ENTITY ).
      SORT lt_gc_loi BY hdr_id.
      DELETE ADJACENT DUPLICATES FROM lt_gc_loi COMPARING hdr_id.
      LOOP AT lt_gc_loi INTO ls_gc_loi.
        SELECT SINGLE * FROM ztb_bb_gc
              WHERE hdr_id = @ls_gc_loi-hdr_id
              INTO @ls_bb_gc.
        IF sy-subrc IS INITIAL.
          APPEND ls_bb_gc TO lt_bb_gc_ud.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT lt_bb_gc_ud INTO ls_bb_gc.
      CALL METHOD zcl_gia_cong=>update_bb_gc
        EXPORTING
          i_bb_gc = ls_bb_gc.
    ENDLOOP.

    DATA: lt_hdrid TYPE STANDARD TABLE OF ztb_bb_gc-hdr_id.

    IF update-zrtbbbgc IS NOT INITIAL OR update-zrtbgcloi IS NOT INITIAL.
      CLEAR lt_bb_gc.
      CLEAR lt_gc_loi.
      lt_gc_loi = CORRESPONDING #( update-zrtbgcloi MAPPING FROM ENTITY ).
      lt_bb_gc = CORRESPONDING #( update-zrtbbbgc MAPPING FROM ENTITY ).

      LOOP AT lt_bb_gc INTO ls_bb_gc.
        APPEND ls_bb_gc-hdr_id TO lt_hdrid.
      ENDLOOP.

      LOOP AT lt_gc_loi INTO ls_gc_loi.
        APPEND ls_gc_loi-hdr_id TO lt_hdrid.
      ENDLOOP.

      SORT lt_hdrid.
      DELETE ADJACENT DUPLICATES FROM lt_hdrid.
      LOOP AT lt_hdrid INTO DATA(lw_hdrid).
        SELECT SINGLE * FROM ztb_bb_gc
           WHERE hdr_id = @lw_hdrid
           INTO @ls_bb_gc .
        IF sy-subrc IS NOT INITIAL.
          CONTINUE.
        ENDIF.

        DATA update_struct TYPE REF TO cl_abap_structdescr.
        IF update-zrtbbbgc IS NOT INITIAL.
*        READ TABLE update-zrtbbbgc INDEX 1 INTO DATA(ls_update_zrtbbbgc).
          LOOP AT update-zrtbbbgc INTO DATA(ls_update_zrtbbbgc) WHERE HdrID = ls_bb_gc-hdr_id.
            SELECT SINGLE * FROM ztb_bb_gc
             WHERE hdr_id = @ls_bb_gc_ud-hdr_id
             INTO @ls_bb_gc .
            update_struct ?= cl_abap_structdescr=>describe_by_data( ls_update_zrtbbbgc-%control ).

            LOOP AT update_struct->components INTO DATA(field).

              IF ls_update_zrtbbbgc-%control-(field-name) = if_abap_behv=>mk-on.
                READ TABLE gt_mapping ASSIGNING <fs_mapping>
                    WITH KEY field_ent = field-name.
                IF sy-subrc IS INITIAL.
                  lw_field_name = <fs_mapping>-field_db.
                ELSE.
                  lw_field_name = field-name.
                ENDIF.
                ls_bb_gc-(lw_field_name) = ls_update_zrtbbbgc-(field-name).
              ENDIF.
            ENDLOOP.
          ENDLOOP.
          FREE update_struct.
        ENDIF.

        SELECT * FROM ztb_gc_loi
            WHERE hdr_id = @ls_bb_gc-hdr_id
            INTO TABLE @lt_gc_loi.

        IF update-zrtbgcloi IS NOT INITIAL.
*        READ TABLE update-zrtbgcloi INDEX 1 INTO DATA(ls_update_zrtbgcloi).
          LOOP AT update-zrtbgcloi INTO DATA(ls_update_zrtbgcloi) WHERE HdrID =  ls_bb_gc-hdr_id .
            update_struct ?= cl_abap_structdescr=>describe_by_data( ls_update_zrtbgcloi-%control ).
            LOOP AT update-zrtbgcloi INTO ls_update_zrtbgcloi.
              SELECT SINGLE * FROM ztb_bb_gc
                WHERE hdr_id = @ls_gc_loi-hdr_id
                INTO @ls_bb_gc .
              READ TABLE lt_gc_loi ASSIGNING <lf_gc_loi>
                  WITH KEY hdr_id = ls_update_zrtbgcloi-HdrID dtl_id = ls_update_zrtbgcloi-DtlID.
              IF sy-subrc IS INITIAL.
                LOOP AT update_struct->components INTO field.
                  IF ls_update_zrtbgcloi-%control-(field-name) = if_abap_behv=>mk-on.
                    READ TABLE gt_mapping_loi ASSIGNING <fs_mapping>
                      WITH KEY field_ent = field-name.
                    IF sy-subrc IS INITIAL.
                      lw_field_name = <fs_mapping>-field_db.
                    ELSE.
                      lw_field_name = field-name.
                    ENDIF.
                    <lf_gc_loi>-(lw_field_name) = ls_update_zrtbgcloi-(field-name).
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDLOOP.
          ENDLOOP.
        ENDIF.

        MODIFY ztb_bb_gc FROM @ls_bb_gc.
        MODIFY ztb_gc_loi FROM TABLE @lt_gc_loi.

        IF ls_bb_gc-trangthai = '0' OR ls_bb_gc-trangthai = '9'.
          CALL METHOD zcl_gia_cong=>update_bb_gc
            EXPORTING
              i_bb_gc = ls_bb_gc.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

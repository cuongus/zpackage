CLASS zcl_xuat_hd_ex_pdf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      keys_xhd     TYPE TABLE FOR ACTION IMPORT zr_tbxuat_hd~btnPrintPDF,
      result_xhd   TYPE TABLE FOR ACTION RESULT zr_tbxuat_hd~btnprintpdf,
      mapped_xhd   TYPE RESPONSE FOR MAPPED EARLY zr_tbxuat_hd,
      failed_xhd   TYPE RESPONSE FOR FAILED EARLY zr_tbxuat_hd,
      reported_xhd TYPE RESPONSE FOR REPORTED EARLY zr_tbxuat_hd.

    CLASS-METHODS:
      btnprintpdf_pkt
        IMPORTING keys     TYPE keys_xhd
        EXPORTING o_pdf    TYPE string
        CHANGING  result   TYPE result_xhd
                  mapped   TYPE mapped_xhd
                  failed   TYPE failed_xhd
                  reported TYPE reported_xhd.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_XUAT_HD_EX_PDF IMPLEMENTATION.


  METHOD btnprintpdf_pkt.
    "1 Đọc key từ RAP Action
    READ TABLE keys INDEX 1 INTO DATA(k).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*    select du lieu
    SELECT SINGLE * FROM zr_tbpb_hd
    WHERE HdrID = @k-%key-HdrID
    INTO @DATA(ls_tbpb).

    SELECT SINGLE * FROM zr_tbxuat_hd
    WHERE HdrID = @k-%key-hdrID
    INTO @DATA(ls_tbxuat).


    " Lấy địa chỉ chi tiết từ addressid
    zcl_jp_common_core=>get_companycode_details(
      EXPORTING
        i_companycode          = ls_tbxuat-Bukrs
      IMPORTING
        o_companycode = DATA(ls_addressid)
    ).


    SELECT SINGLE * FROM I_CoCodeCountryVATRegistration
    WHERE CompanyCode = @ls_tbxuat-Bukrs
    INTO @DATA(ls_cocode).

    SELECT * FROM ztb_xn_xuat_hd
    WHERE hdr_id = @ls_tbxuat-HdrID
    INTO TABLE @DATA(lt_pbhd).

*lấy thông tin company
    zcl_jp_common_core=>get_companycode_details(
      EXPORTING i_companycode = ls_tbxuat-bukrs
      IMPORTING o_companycode = DATA(ls_companycodeinfo)
    ).


    "--- Lấy thông tin Business Partner (Customer / Supplier)
    zcl_jp_common_core=>get_businesspartner_details(
      EXPORTING
        i_document = VALUE #(
                      supplier       = ls_tbxuat-invoicingparty
                       )
      IMPORTING
        o_BPdetails = DATA(ls_bpdetails)
    ).

    SELECT SINGLE * FROM I_BuPaIdentification
    WHERE BusinessPartner = @ls_tbxuat-invoicingparty
    INTO @DATA(ls_bpvat).

*replace các ký tự gây lỗi
    DATA(lv_bpname) = ls_bpdetails-bpname.
    REPLACE ALL OCCURRENCES OF '&' IN lv_bpname WITH '&amp;'.
    REPLACE ALL OCCURRENCES OF '<' IN lv_bpname WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '>' IN lv_bpname WITH '&gt;'.


    " Build XML

    DATA: headerxml TYPE string,
          table1xml TYPE string,
          xml       TYPE string.




    " Header
    headerxml =
      |<Header>| &&
      |<SoPhieu>Số phiếu: { ls_tbxuat-invoicingpartyName } - { ls_tbxuat-mahd }</SoPhieu>| &&
      |<DonViGGC>{ ls_addressid-CompanyCodeName }</DonViGGC>| &&
      |<DiaChiGGC>{ ls_addressid-companycodeaddr }</DiaChiGGC>| &&
      |<MstGGC>{ ls_cocode-VATRegistration }</MstGGC>| &&
      |<DonViNGC>{ lv_bpname }</DonViNGC>| &&
      |<DiaChiNGC> { ls_bpdetails-bpaddress }</DiaChiNGC>| &&
      |<MstNGC>{ ls_bpvat-BPIdentificationNumber }</MstNGC>| &&
|</Header>|.


    DATA: xml_row     TYPE string,
          lv_tongtien TYPE string,
          lv_dongia type string,
          lv_tongthue TYPE string.

*      SHIFT lv_tongtien LEFT DELETING LEADING '0'.
    LOOP AT lt_pbhd INTO DATA(ls_pbhd).


      SELECT SINGLE unitofmeasure_e
  FROM I_UnitOfMeasure

       WHERE UnitOfMeasureSAPCode = @ls_pbhd-materialbaseunit
        INTO @ls_pbhd-materialbaseunit .
        lv_dongia = ls_pbhd-ct11 / ls_pbhd-soluong.

      xml_row = xml_row &&
      |<Row1>| &&
          |<stt> { sy-tabix } </stt>| &&
          |<tenHangHoa>Chi phí gia công túi { ls_pbhd-productdescription }</tenHangHoa>| &&
          |<dvtMaterialBaseUnit> { ls_pbhd-materialbaseunit } </dvtMaterialBaseUnit>| &&
          |<soLuong> { ls_pbhd-soluong } </soLuong>| &&
          |<donGiaCt10> { lv_dongia } </donGiaCt10>| &&
          |<thanhTienCt11> { ls_pbhd-ct11 } </thanhTienCt11>| &&
       |</Row1>|.
      lv_tongtien = lv_tongtien + ls_pbhd-ct11.
    ENDLOOP.
    lv_tongthue = ls_tbxuat-Tongtienxnst - lv_tongtien.
    table1xml = |<Table1>| &&
          xml_row &&
          |<congTienHang> { lv_tongtien } </congTienHang>| &&
          |<thueGTGT> { lv_tongthue } </thueGTGT>| &&
          |<thuesuat> { ls_tbxuat-tilethuesuat }% </thuesuat>| &&
          |<tongThanhToan> { ls_tbxuat-Tongtienxnst } </tongThanhToan>| &&
                      |</Table1>|.



    "4. Gộp XML
    xml = |<?xml version="1.0" encoding="UTF-8"?>| &&
          |<form1>| &&
            |<Main>| &&
              |{ headerxml }| &&
              |{ table1xml }| &&
            |</Main>| &&
          |</form1>|.

    "5. Gọi Adobe Form
    DATA(ls_request) = VALUE zcl_gen_adobe=>ts_request( id = 'zxuathoadon' ).
    APPEND xml TO ls_request-data.

    DATA(o_gen_adobe) = NEW zcl_gen_adobe( ).
    DATA(lv_pdf) = o_gen_adobe->call_data( EXPORTING i_request = ls_request ).

    o_pdf = lv_pdf.

    "6. Trả file về cho RAP
    result = VALUE #( FOR key IN keys (
      %tky   = key-%tky
      %param = VALUE #(
                  filecontent   = lv_pdf
                  filename      = |xuathoadon_{ ls_tbxuat-mahd }|
                  fileextension = 'pdf'
                  mimetype      = 'application/pdf' )
    ) ).

    " Append vào sub-table mapped-zr_tbbb_gc
    APPEND VALUE #( %tky = k-%tky ) TO mapped-ZrTbxuatHd.

  ENDMETHOD.
ENDCLASS.

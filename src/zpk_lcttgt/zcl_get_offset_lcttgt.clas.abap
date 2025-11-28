CLASS zcl_get_offset_lcttgt DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_range TYPE TABLE OF ty_range_option.

    METHODS sum_amount
      IMPORTING VALUE(ir_bukrs)      TYPE bukrs
*                VALUE(ir_gjahr) TYPE gjahr
                VALUE(ir_gl_acc)     TYPE tt_range
                VALUE(ir_offset_acc) TYPE tt_range
                VALUE(ir_budat)      TYPE tt_range
                VALUE(ir_budat_kt)   TYPE tt_range
                VALUE(ir_budat_dk_n) TYPE budat
                VALUE(ir_budat_dk_t) TYPE budat
                VALUE(ir_date_n)     TYPE budat
                VALUE(ir_date_t)     TYPE budat
                VALUE(ir_data_type)  TYPE char2
                VALUE(ir_sh_type)    TYPE char2
                VALUE(ir_doc_type)   TYPE tt_range
      EXPORTING VALUE(kynay)         TYPE dmbtr
                VALUE(kytruoc)       TYPE dmbtr.

ENDCLASS.



CLASS ZCL_GET_OFFSET_LCTTGT IMPLEMENTATION.


  METHOD sum_amount.
    DATA: kynay_process     TYPE dmbtr,
          kytruoc_process   TYPE dmbtr,
          lv_condition      TYPE char255 VALUE IS INITIAL,
          lv_condition_kt   TYPE char255 VALUE IS INITIAL,
          lv_condition_p    TYPE char255 VALUE IS INITIAL,
          lv_condition_p_kt TYPE char255 VALUE IS INITIAL.

    IF ir_data_type = '01'.
      lv_condition = 'a~PostingDate IN @ir_budat'.
      lv_condition_kt = 'a~PostingDate IN @ir_budat_kt'.
      lv_condition_p = 'a~budat IN @ir_budat'.
      lv_condition_p_kt = 'a~budat IN @ir_budat_kt'.
    ELSEIF ir_data_type = '02'.
      lv_condition = 'a~PostingDate < @ir_budat_dk_n'.
      lv_condition_kt = 'a~PostingDate < @ir_budat_dk_t'.
      lv_condition_p = 'a~budat < @ir_budat_dk_n'.
      lv_condition_p_kt = 'a~budat < @ir_budat_dk_t'.
    ELSEIF ir_data_type = '03'.
      lv_condition = 'a~PostingDate <= @ir_date_n'.
      lv_condition_kt = 'a~PostingDate <= @ir_date_t'.
      lv_condition_p = 'a~budat <= @ir_date_n'.
      lv_condition_p_kt = 'a~budat <= @ir_date_t'.
    ENDIF.


    IF ir_offset_acc IS NOT INITIAL.

      SELECT SUM( a~AmountInCompanyCodeCurrency )
         FROM I_GLAccountLineItem AS a
         JOIN I_GLAccountLineItem AS b
           ON a~CompanyCode = b~CompanyCode
           AND a~FiscalYear = b~FiscalYear
           AND a~AccountingDocument = b~AccountingDocument
           AND a~LedgerGLLineItem = b~OffsettingLedgerGLLineItem
           AND b~LedgerGLLineItem = a~OffsettingLedgerGLLineItem
         WHERE a~CompanyCode = @ir_bukrs
*                 AND a~FiscalYear = @ir_gjahr
           AND a~GLAccount IN @ir_gl_acc
           AND b~GLAccount IN @ir_offset_acc
           AND (lv_condition)
           AND a~Ledger = '0L'
           and b~ledger = '0L'
           AND a~AccountingDocumentType IN @ir_doc_type
           AND a~AccountingDocumentType <> ''
           INTO @kynay.

      IF ir_data_type = '01'.
*Get data from tabel zfirud_cf_off
        SELECT SUM( a~hsl )
           FROM zfirud_cf_off AS a
           JOIN zfirud_cf_off AS b
             ON a~bukrs = b~bukrs
             AND a~gjahr = b~gjahr
             AND a~belnr = b~belnr
             AND a~docln = b~offs_item
             AND b~docln = a~offs_item
           WHERE a~bukrs = @ir_bukrs
*                 AND a~FiscalYear = @ir_gjahr
             AND a~racct IN @ir_gl_acc
             AND b~racct IN @ir_offset_acc
             AND (lv_condition_p)
             AND a~rldnr = '0L'
             AND a~blart IN @ir_doc_type
             INTO @kynay_process.

        kynay = kynay + kynay_process.
      ENDIF.

      SELECT SUM( a~AmountInCompanyCodeCurrency )
         FROM I_GLAccountLineItem AS a
         JOIN I_GLAccountLineItem AS b
           ON a~CompanyCode = b~CompanyCode
           AND a~FiscalYear = b~FiscalYear
           AND a~AccountingDocument = b~AccountingDocument
           AND a~LedgerGLLineItem = b~OffsettingLedgerGLLineItem
           AND b~LedgerGLLineItem = a~OffsettingLedgerGLLineItem
         WHERE a~CompanyCode = @ir_bukrs
*                 AND a~FiscalYear = @ir_gjahr
           AND a~GLAccount IN @ir_gl_acc
           AND b~GLAccount IN @ir_offset_acc
           AND (lv_condition_kt)
           AND a~Ledger = '0L'
           and b~ledger = '0L'
           AND a~AccountingDocumentType IN @ir_doc_type
           AND a~AccountingDocumentType <> ''
           INTO @kytruoc.
      IF ir_data_type = '01'.
*Get data from tabel zfirud_cf_off
        SELECT SUM( a~hsl )
           FROM zfirud_cf_off AS a
           JOIN zfirud_cf_off AS b
             ON a~bukrs = b~bukrs
             AND a~gjahr = b~gjahr
             AND a~belnr = b~belnr
             AND a~docln = b~offs_item
             AND b~docln = a~offs_item
           WHERE a~bukrs = @ir_bukrs
*                 AND a~FiscalYear = @ir_gjahr
             AND a~racct IN @ir_gl_acc
             AND b~racct IN @ir_offset_acc
             AND (lv_condition_p_kt)
             AND a~rldnr = '0L'
             AND a~blart IN @ir_doc_type
             INTO @kytruoc_process.

        kytruoc = kytruoc + kytruoc_process.
      ENDIF.
    ELSE.

      SELECT SUM( a~AmountInCompanyCodeCurrency )
         FROM I_GLAccountLineItem AS a
         WHERE a~CompanyCode = @ir_bukrs
*                 AND a~FiscalYear = @ir_gjahr
           AND a~GLAccount IN @ir_gl_acc
           AND (lv_condition)
           AND a~Ledger = '0L'
           AND a~AccountingDocumentType IN @ir_doc_type
           INTO @kynay.
      IF ir_data_type = '01'.
*Get data from tabel zfirud_cf_off
        SELECT SUM( a~hsl )
           FROM zfirud_cf_off AS a
           WHERE a~bukrs = @ir_bukrs
*                 AND a~FiscalYear = @ir_gjahr
             AND a~racct IN @ir_gl_acc
             AND (lv_condition_p)
             AND a~rldnr = '0L'
             AND a~blart IN @ir_doc_type
             INTO @kynay_process.

        kynay = kynay + kynay_process.
      ENDIF.
      SELECT SUM( a~AmountInCompanyCodeCurrency )
         FROM I_GLAccountLineItem AS a
         WHERE a~CompanyCode = @ir_bukrs
*                 AND a~FiscalYear = @ir_gjahr
           AND a~GLAccount IN @ir_gl_acc
           AND (lv_condition_kt)
           AND a~Ledger = '0L'
           AND a~AccountingDocumentType IN @ir_doc_type
           INTO @kytruoc.
      IF ir_data_type = '01'.
*Get data from tabel zfirud_cf_off
        SELECT SUM( a~hsl )
           FROM zfirud_cf_off AS a
           WHERE a~bukrs = @ir_bukrs
*                 AND a~FiscalYear = @ir_gjahr
             AND a~racct IN @ir_gl_acc
             AND (lv_condition_p_kt)
             AND a~rldnr = '0L'
             AND a~blart IN @ir_doc_type
             INTO @kytruoc_process.

        kytruoc = kytruoc + kytruoc_process.
      ENDIF.
    ENDIF.
    IF ir_sh_type = '04'.
      kynay = kynay * -1.
      kytruoc = kytruoc * -1.
    ENDIF.

  ENDMETHOD.
ENDCLASS.

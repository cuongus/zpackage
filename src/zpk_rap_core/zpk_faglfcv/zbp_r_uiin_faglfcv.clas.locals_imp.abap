CLASS lhc_zr_uiin_faglfcv DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_glmapp,
             glacct1 TYPE zr_uiin_faglfcv-glaccount,
             glacct2 TYPE zr_uiin_faglfcv-glaccount,
           END OF ty_glmapp,

           gty_glmapp TYPE STANDARD TABLE OF ty_glmapp WITH EMPTY KEY.


    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zruiinfaglfcv
        RESULT result,

      matchposteddocs FOR MODIFY
        IMPORTING keys FOR ACTION zruiinfaglfcv~matchposteddocs,

      get_glmapp RETURNING VALUE(rt_glmapp) TYPE gty_glmapp.

ENDCLASS.

CLASS lhc_zr_uiin_faglfcv IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD matchposteddocs.
    " keys: auto-generated table type FOR ACTION ...

    READ TABLE keys INDEX 1 INTO DATA(ls_key).
    IF sy-subrc <> 0.
      RETURN. "không có gì để làm
    ENDIF.

    " 1. Lấy tham số từ %PARAM
    DATA(lv_mimetype)      = ls_key-%param-mimetype.
    DATA(lv_filename)      = ls_key-%param-filename.
    DATA(lv_fileextension) = ls_key-%param-fileextension.
    DATA(lv_filecontent_b64) = ls_key-%param-filecontent.

    " (OPTIONAL) log thử cho chắc
*    cl_abap_logger=>log( |MatchPostedDocs: file={ lv_filename } type={ lv_mimetype } ext={ lv_fileextension }| ).

    " 2. Giải mã base64 -> STRING
    DATA lv_file_text  TYPE string.

    TRY.
        lv_file_text = cl_web_http_utility=>decode_base64(
          EXPORTING
            encoded = lv_filecontent_b64
        ).

      CATCH cx_root INTO DATA(lx_conv).
*        cl_abap_logger=>log( |Convert_from failed: { lx_conv->get_text( ) }| ).
        RETURN.
    ENDTRY.

    " Bây giờ lv_file_text chính là nội dung JSON dạng text
    " ================== PARSE JSON =======================

    DATA: lt_mapp TYPE /ui2/cl_json=>name_mappings.

    lt_mapp = VALUE #(
          ( abap = 'ItemRun'        json = 'ItemRun' )
          ( abap = 'ItemPost'       json = 'ItemPost' )
          ( abap = 'Ccode'          json = 'Ccode' )
          ( abap = 'DocNumber'      json = 'DocNumber' )
          ( abap = 'FiscalYear'     json = 'FiscalYear' )
          ( abap = 'DocLine'        json = 'DocLine' )
          ( abap = 'AccountType'    json = 'AccountType' )
          ( abap = 'GlAccount'      json = 'GlAccount' )
          ( abap = 'Account'        json = 'Account' )
          ( abap = 'Currency'       json = 'Currency' )
          ( abap = 'SourceAmount'   json = 'SourceAmount' )
          ( abap = 'TargetAmount'   json = 'TargetAmount' )
          ( abap = 'TargetCurrency' json = 'TargetCurrency' )
          ( abap = 'ValuationRate'  json = 'ValuationRate' )
          ( abap = 'OrigRate'       json = 'OrigRate' )
          ( abap = 'DocType'        json = 'DocType' )
          ( abap = 'DocumentDate'   json = 'DocumentDate' )
          ( abap = 'ValuDiffOld'    json = 'ValuDiffOld' )
          ( abap = 'ValuDiffNew'    json = 'ValuDiffNew' )
          ( abap = 'PostingAmount'  json = 'PostingAmount' )
          ( abap = 'CcodeOrig'      json = 'CcodeOrig' )
          ( abap = 'KeyDate'        json = 'KeyDate' )
          ( abap = 'Prctr'          json = 'Prctr' )
          ( abap = 'ModeTest'       json = 'ModeTest' )
          ( abap = 'ModeReset'      json = 'ModeReset' )
    ).

    TYPES: tt_item TYPE STANDARD TABLE OF zr_uiin_faglfcv WITH DEFAULT KEY.

    TYPES: BEGIN OF lty_request,
             itemrun   TYPE tt_item,
             itempost  TYPE tt_item,
             modetest  TYPE abap_boolean,
             modereset TYPE abap_boolean,
           END OF lty_request.



    DATA: it_request TYPE TABLE OF lty_request,
          wa_request TYPE lty_request.
    DATA: lt_itemrun  TYPE tt_item,
          lt_itempost TYPE tt_item.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json          = lv_file_text
*       jsonx         =
*       pretty_name   = /ui2/cl_json=>pretty_mode-user
*       assoc_arrays  =
*       assoc_arrays_opt =
        name_mappings = lt_mapp
*       conversion_exits =
*       hex_as_base64 =
      CHANGING
        data          = it_request
    ).

    READ TABLE it_request INTO wa_request INDEX 1.

    DATA: lt_keys   TYPE TABLE FOR READ IMPORT zr_uiin_faglfcv,

          lt_create TYPE TABLE FOR CREATE zr_uiin_faglfcv,
          ls_create LIKE LINE OF lt_create,
          lt_update TYPE TABLE FOR UPDATE zr_uiin_faglfcv,
          ls_update LIKE LINE OF lt_update.

    DATA: ls_fail   LIKE LINE OF failed-zruiinfaglfcv,
          ls_report LIKE LINE OF reported-zruiinfaglfcv.

    TYPES: BEGIN OF lty_mappcl,
             ccode         TYPE zr_uiin_faglfcv-ccode,
             docnumber     TYPE zr_uiin_faglfcv-docnumber,
             glaccount     TYPE zr_uiin_faglfcv-glaccount,
             glaccount_tg  TYPE zr_uiin_faglfcv-glaccount,
             prctr         TYPE zr_uiin_faglfcv-prctr,
             docnumbercl   TYPE zr_uiin_faglfcv-docnumbercl,
             postingdate   TYPE zr_uiin_faglfcv-postingdate,
             keydate       TYPE zr_uiin_faglfcv-keydate,
             postingdatecl TYPE zr_uiin_faglfcv-postingdate,
             currency      TYPE zr_uiin_faglfcv-currency,
             postingamount TYPE zr_uiin_faglfcv-postingamount,
           END OF lty_mappcl,

           BEGIN OF lty_doc,
             docnumber TYPE zr_uiin_faglfcv-docnumber,
           END OF lty_doc.


    DATA: lt_post   TYPE TABLE OF lty_mappcl,
          lt_run    TYPE TABLE OF lty_mappcl,
          lt_rever  TYPE TABLE OF lty_mappcl,
          ls_mappcl TYPE lty_mappcl.

    DATA: lt_doc TYPE TABLE OF lty_doc.

    DATA: lt_reverse TYPE tt_item.

    lt_itempost = wa_request-itempost.
    lt_reverse = wa_request-itempost.

    DELETE lt_itempost WHERE docheadertext CP 'Reverse Posting'.
    DELETE lt_reverse WHERE docheadertext NP 'Reverse Posting'.

    lt_itemrun = wa_request-itemrun.

    MOVE-CORRESPONDING lt_itempost TO lt_doc.

    DELETE ADJACENT DUPLICATES FROM lt_doc COMPARING docnumber.

    DATA(lv_count) = lines( lt_doc ).

    DATA: ls_itemrun LIKE LINE OF lt_itemrun.

*    SELECT * FROM i_transactiontypestdglacct
*    WITH PRIVILEGED ACCESS
*    INTO TABLE @DATA(lt_glacct).

    DATA: lt_glmapp TYPE gty_glmapp.

    lt_glmapp = me->get_glmapp( ).

    LOOP AT lt_itemrun ASSIGNING FIELD-SYMBOL(<itemrun>).
      SELECT SINGLE profitcenter FROM i_journalentryitem
        WHERE companycode = @<itemrun>-ccode
        AND accountingdocument = @<itemrun>-docnumber
        AND fiscalyear = @<itemrun>-fiscalyear
        AND accountingdocumentitem = @<itemrun>-docline
        INTO @<itemrun>-prctr.

      SHIFT <itemrun>-prctr LEFT DELETING LEADING '0'.
      CONDENSE <itemrun>-prctr NO-GAPS.
    ENDLOOP.

    LOOP AT lt_itemrun INTO ls_itemrun.
      ls_mappcl-ccode     = ls_itemrun-ccode.
*      ls_mappcl-docnumber = ls_itemrun-docnumber.
      ls_mappcl-keydate   = ls_itemrun-keydate.
      ls_mappcl-glaccount = ls_itemrun-glaccount.
*             ls_mappcl-docnumbercl
*      ls_mappcl-postingdate   = ls_itemrun-postingdate.
*             ls_mappcl-postingdatecl
      ls_mappcl-postingamount = ls_itemrun-postingamount.

      ls_mappcl-prctr = ls_itemrun-prctr.
      ls_mappcl-currency = ls_itemrun-currency.

      READ TABLE lt_glmapp INTO DATA(ls_glmapp) WITH KEY glacct1 = ls_itemrun-glaccount.
      IF sy-subrc EQ 0.
        ls_mappcl-glaccount_tg = ls_glmapp-glacct2.
      ENDIF.

      COLLECT ls_mappcl INTO lt_run.
      CLEAR: ls_mappcl.
    ENDLOOP.

*    LOOP AT lt_itempost INTO DATA(ls_itempost).
*      ls_mappcl-ccode = ls_itempost-ccode.
**      ls_mappcl-docnumber
*      ls_mappcl-docnumbercl = ls_itempost-docnumber.
*      ls_mappcl-glaccount = ls_itempost-glaccount.
*
**      READ TABLE lt_glmapp INTO ls_glmapp WITH KEY glacct2 = ls_itempost-glaccount.
**      IF sy-subrc EQ 0.
**        ls_mappcl-glaccount = ls_glmapp-glacct1.
**      ENDIF.
*
**      ls_mappcl-glaccount_tg = ls_itempost-glaccount.
*
*      ls_mappcl-prctr = ls_itempost-prctr.
*      ls_mappcl-currency = ls_itempost-currency.
**      ls_mappcl-postingdate
*      ls_mappcl-postingdatecl = ls_itempost-postingdate.
*      ls_mappcl-postingamount = ls_itempost-postingamount.
*
*      COLLECT ls_mappcl INTO lt_post.
*      CLEAR: ls_mappcl.
*    ENDLOOP.

    MOVE-CORRESPONDING lt_itempost TO lt_post.
    MOVE-CORRESPONDING lt_reverse TO lt_rever.

    SORT lt_post BY ccode docnumber postingdate ASCENDING.
    SORT lt_rever BY ccode docnumber postingdate ASCENDING.

    DELETE ADJACENT DUPLICATES FROM lt_post COMPARING ccode docnumber postingdate.
    DELETE ADJACENT DUPLICATES FROM lt_rever COMPARING ccode docnumber postingdate.

    LOOP AT lt_run ASSIGNING FIELD-SYMBOL(<fs_run>).
      READ TABLE lt_itempost INTO DATA(ls_itempost) WITH KEY ccode = <fs_run>-ccode
                                               glaccount     = <fs_run>-glaccount_tg
                                               postingdate   = <fs_run>-keydate
                                               prctr         = <fs_run>-prctr
                                               currency      = <fs_run>-currency
                                               postingamount = <fs_run>-postingamount.
      IF sy-subrc EQ 0.
        <fs_run>-docnumbercl = ls_itempost-docnumber.
        <fs_run>-postingdatecl = ls_itempost-postingdate.
      ENDIF.
    ENDLOOP.

*    LOOP AT lt_itemrun ASSIGNING FIELD-SYMBOL(<ls_itemrun>).
*      READ TABLE lt_run INTO ls_mappcl WITH KEY ccode       = <ls_itemrun>-ccode
*                                                glaccount   = <ls_itemrun>-glaccount
*                                                prctr       = <ls_itemrun>-prctr
*                                                currency    = <ls_itemrun>-currency
*                                                keydate     = <ls_itemrun>-keydate.
*      IF sy-subrc EQ 0.
*
*        <ls_itemrun>-docnumbercl = ls_mappcl-docnumbercl.
*        <ls_itemrun>-fiscalyearcl = ls_mappcl-postingdatecl+0(4).
*
*        MOVE-CORRESPONDING <ls_itemrun> TO ls_itemrun.
*
*        READ TABLE lt_post TRANSPORTING NO FIELDS WITH KEY ccode = ls_mappcl-ccode
*                                                       docnumber   = ls_mappcl-docnumbercl
*                                                       postingdate  = ls_mappcl-postingdatecl.
*        IF sy-subrc EQ 0.
*          DATA(lv_index) = sy-tabix.
*
*          READ TABLE lt_rever INTO DATA(ls_reverse) INDEX lv_index.
**          WITH KEY ccode = ls_mappcl-ccode
**                   docnumber   = ls_mappcl-docnumbercl + lv_count
**                   fiscalyear  = ls_mappcl-postingdatecl+0(4).
*          IF sy-subrc EQ 0.
*            ls_itemrun-docnumbercl    = ls_reverse-docnumber.
*            ls_itemrun-keydate        = ls_reverse-postingdate.
*            ls_itemrun-postingamount  = ls_itemrun-postingamount * -1.
*            ls_itemrun-fiscalyearcl   = ls_reverse-postingdate+0(4).
*            APPEND ls_itemrun TO lt_itemrun.
*            CLEAR: ls_itemrun.
*          ENDIF.
*
*        ENDIF.
*
*      ENDIF.
*    ENDLOOP.

    DATA: lt_itemrun2 LIKE lt_itemrun.

    LOOP AT lt_itemrun INTO ls_itemrun.
      ls_itemrun-keydate        = ls_itemrun-keydate + 1.
      ls_itemrun-postingamount  = ls_itemrun-postingamount * -1.
      APPEND ls_itemrun TO lt_itemrun2.
    ENDLOOP.

    APPEND LINES OF lt_itemrun2 TO lt_itemrun.

    LOOP AT lt_itemrun INTO DATA(ls_request).
      IF ls_request-doctype NE ''.
        IF ls_request-ccode IS INITIAL OR ls_request-postingdate IS INITIAL OR ls_request-postingamount IS INITIAL.
*            ls_report = VALUE #( %msg  = nEW m     ).

          RETURN.
        ENDIF.
      ELSE.
        IF ls_request-docnumber NE '$'.
          IF ls_request-docheadertext IS INITIAL "OR ls_request-doctype IS INITIAL
          .

            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

*    DELETE lt_itempost WHERE docheadertext CP 'Reverse Posting'.
    DELETE lt_itempost WHERE docnumber CP '$'.
    DELETE lt_itempost WHERE docnumber IS INITIAL.

    IF lt_itemrun IS NOT INITIAL.
      SELECT
        ccode,
        docnumber,

        fiscalyear,
        docline,
        docnumbercl,
        fiscalyearcl,
        keydate
        FROM zr_uiin_faglfcv
        FOR ALL ENTRIES IN @lt_itemrun
        WHERE ccode      = @lt_itemrun-ccode
        AND docnumber    = @lt_itemrun-docnumber
        AND fiscalyear   = @lt_itemrun-fiscalyear
        AND docline      = @lt_itemrun-docline
*        AND docnumbercl  = @lt_itemrun-docnumbercl
*        AND fiscalyearcl = @lt_itemrun-fiscalyearcl
        AND keydate = @lt_itemrun-keydate
        INTO CORRESPONDING FIELDS OF TABLE @lt_keys.
    ENDIF.

    IF wa_request-modereset = abap_true.

      READ ENTITIES OF zr_uiin_faglfcv IN LOCAL MODE
      ENTITY zruiinfaglfcv ALL FIELDS WITH lt_keys
      RESULT FINAL(lt_delete)
      FAILED FINAL(lt_failed_d).

      DATA: lt_ac_delete TYPE TABLE FOR DELETE zr_uiin_faglfcv.

      MOVE-CORRESPONDING lt_delete TO lt_ac_delete.

*      LOOP AT lt_keys INTO DATA(ls_keys).
      MODIFY ENTITIES OF zr_uiin_faglfcv IN LOCAL MODE
      ENTITY zruiinfaglfcv
      DELETE FROM lt_ac_delete
      FAILED DATA(delete_failed)
      REPORTED DATA(delete_reported).
*      ENDLOOP.

      RETURN.

    ELSE.

    ENDIF.

    READ ENTITIES OF zr_uiin_faglfcv IN LOCAL MODE
    ENTITY zruiinfaglfcv                    "tên entity trong BDEF
    ALL FIELDS
    WITH lt_keys
    RESULT   DATA(lt_read_result)
    FAILED   DATA(lt_read_failed)
    REPORTED DATA(lt_read_reported).

    SORT lt_read_result BY ccode docnumber fiscalyear docnumbercl fiscalyearcl ASCENDING.

    LOOP AT lt_itemrun INTO ls_request WHERE doctype NE ''.
      READ TABLE lt_read_result INTO DATA(ls_read_result) WITH KEY ccode    = ls_request-ccode
                                                               docnumber    = ls_request-docnumber
                                                               fiscalyear   = ls_request-fiscalyear
                                                               docnumbercl  = ls_request-docnumbercl
                                                               fiscalyearcl = ls_request-fiscalyearcl
                                                               keydate      = ls_request-keydate
                                                              BINARY SEARCH.
      IF sy-subrc EQ 0.
        ls_update = VALUE #(
          ccode            = ls_request-ccode
          docnumber        = ls_request-docnumber
          fiscalyear       = ls_request-fiscalyear
          docline          = ls_request-docline
          docnumbercl      = ls_request-docnumbercl
          fiscalyearcl     = ls_request-fiscalyearcl

          keydate          = ls_request-keydate

          ledger           = ls_request-ledger
          ledgergroup      = ls_request-ledgergroup
          targetccode      = ls_request-targetccode
          valuationgroup   = ls_request-valuationgroup

          accounttype      = ls_request-accounttype
          glaccount        = ls_request-glaccount
          groupaccount     = ls_request-groupaccount
          account          = ls_request-account
          currency         = ls_request-currency

          nr               = ls_request-nr
          ja               = ls_request-ja
          buz              = ls_request-buz
          debcredind       = ls_request-debcredind

          sourceamount     = ls_request-sourceamount
          targetamount     = ls_request-targetamount
          targetcurrency   = ls_request-targetcurrency
          lcamountval      = ls_request-lcamountval
          hedgedamount     = ls_request-hedgedamount
          hedgedrate       = ls_request-hedgedrate
          valuationrate    = ls_request-valuationrate
          valuxusemdfxr    = ls_request-valuxusemdfxr
          specialglind     = ls_request-specialglind
          origrate         = ls_request-origrate
          doctype          = ls_request-doctype
          postingdate      = ls_request-postingdate
          documentdate     = ls_request-documentdate
          clearingdocument = ls_request-clearingdocument

          valudiffold      = ls_request-valudiffold
          valudiffnew      = ls_request-valudiffnew
          postingamount    = ls_request-postingamount / 100
          realdiff         = ls_request-realdiff

          vbund            = ls_request-vbund
          accounttext      = ls_request-accounttext

          valudiffrem2     = ls_request-valudiffrem2
          currrem2         = ls_request-currrem2
          valudiffrem3     = ls_request-valudiffrem3
          currrem3         = ls_request-currrem3
          valudiffrem4     = ls_request-valudiffrem4
          currrem4         = ls_request-currrem4
          valudiffrem5     = ls_request-valudiffrem5
          currrem5         = ls_request-currrem5
          valudiffrem6     = ls_request-valudiffrem6
          currrem6         = ls_request-currrem6
          valudiffrem7     = ls_request-valudiffrem7
          currrem7         = ls_request-currrem7
          valudiffrem8     = ls_request-valudiffrem8
          currrem8         = ls_request-currrem8
          valudiffrem9     = ls_request-valudiffrem9
          currrem9         = ls_request-currrem9
          valudiffrem10    = ls_request-valudiffrem10
          currrem10        = ls_request-currrem10

          xloss            = ls_request-xloss
          custvendname     = ls_request-custvendname
          hrate            = ls_request-hrate
          htext            = ls_request-htext
          maturity         = ls_request-maturity
          maturityunit     = ls_request-maturityunit
          intvaluratec     = ls_request-intvaluratec
          accas            = ls_request-accas

          pprctr           = ls_request-pprctr
          prctr            = ls_request-prctr
          psegment         = ls_request-psegment
          rbusa            = ls_request-rbusa
          rfarea           = ls_request-rfarea
          sbusa            = ls_request-sbusa
          segment          = ls_request-segment

          valobjtype       = ls_request-valobjtype
          valobjid         = ls_request-valobjid
          valsobjid        = ls_request-valsobjid

        ).

        APPEND ls_update TO lt_update.
        CLEAR: ls_update.
      ELSE.
        ls_create = VALUE #(
          ccode            = ls_request-ccode
          docnumber        = ls_request-docnumber
          fiscalyear       = ls_request-fiscalyear
          docline          = ls_request-docline

          docnumbercl      = ls_request-docnumbercl
          fiscalyearcl     = ls_request-fiscalyearcl

          keydate          = ls_request-keydate

          ledger           = ls_request-ledger
          ledgergroup      = ls_request-ledgergroup
          targetccode      = ls_request-targetccode
          valuationgroup   = ls_request-valuationgroup

          accounttype      = ls_request-accounttype
          glaccount        = ls_request-glaccount
          groupaccount     = ls_request-groupaccount
          account          = ls_request-account
          currency         = ls_request-currency

          nr               = ls_request-nr
          ja               = ls_request-ja
          buz              = ls_request-buz
          debcredind       = ls_request-debcredind

          sourceamount     = ls_request-sourceamount
          targetamount     = ls_request-targetamount
          targetcurrency   = ls_request-targetcurrency
          lcamountval      = ls_request-lcamountval
          hedgedamount     = ls_request-hedgedamount
          hedgedrate       = ls_request-hedgedrate
          valuationrate    = ls_request-valuationrate
          valuxusemdfxr    = ls_request-valuxusemdfxr
          specialglind     = ls_request-specialglind
          origrate         = ls_request-origrate
          doctype          = ls_request-doctype
          postingdate      = ls_request-postingdate
          documentdate     = ls_request-documentdate
          clearingdocument = ls_request-clearingdocument

          valudiffold      = ls_request-valudiffold
          valudiffnew      = ls_request-valudiffnew
          postingamount    = ls_request-postingamount / 100
          realdiff         = ls_request-realdiff

          vbund            = ls_request-vbund
          accounttext      = ls_request-accounttext

          valudiffrem2     = ls_request-valudiffrem2
          currrem2         = ls_request-currrem2
          valudiffrem3     = ls_request-valudiffrem3
          currrem3         = ls_request-currrem3
          valudiffrem4     = ls_request-valudiffrem4
          currrem4         = ls_request-currrem4
          valudiffrem5     = ls_request-valudiffrem5
          currrem5         = ls_request-currrem5
          valudiffrem6     = ls_request-valudiffrem6
          currrem6         = ls_request-currrem6
          valudiffrem7     = ls_request-valudiffrem7
          currrem7         = ls_request-currrem7
          valudiffrem8     = ls_request-valudiffrem8
          currrem8         = ls_request-currrem8
          valudiffrem9     = ls_request-valudiffrem9
          currrem9         = ls_request-currrem9
          valudiffrem10    = ls_request-valudiffrem10
          currrem10        = ls_request-currrem10

          xloss            = ls_request-xloss
          custvendname     = ls_request-custvendname
          hrate            = ls_request-hrate
          htext            = ls_request-htext
          maturity         = ls_request-maturity
          maturityunit     = ls_request-maturityunit
          intvaluratec     = ls_request-intvaluratec
          accas            = ls_request-accas

          pprctr           = ls_request-pprctr
          prctr            = ls_request-prctr
          psegment         = ls_request-psegment
          rbusa            = ls_request-rbusa
          rfarea           = ls_request-rfarea
          sbusa            = ls_request-sbusa
          segment          = ls_request-segment

          valobjtype       = ls_request-valobjtype
          valobjid         = ls_request-valobjid
          valsobjid        = ls_request-valsobjid

        ).

        APPEND ls_create TO lt_create.
        CLEAR: ls_create.
      ENDIF.
    ENDLOOP.

    IF lt_create IS NOT INITIAL.
      MODIFY ENTITIES OF zr_uiin_faglfcv IN LOCAL MODE
         ENTITY zruiinfaglfcv
         CREATE AUTO FILL CID FIELDS (
                            ccode  "type bukrs
                            docnumber   "type belnr_d
                            fiscalyear  "type gjahr
                            docline "type buzei
                            docnumbercl "TYPE belnr_d
                            fiscalyearcl
                            keydate

                            ledger  "type c length 2
                            ledgergroup "TYPE c length 4
                            targetccode "TYPE c length 4
                            valuationgroup  "TYPE c length 40
                            accounttype "TYPE koart
                            glaccount   "TYPE hkont
                            groupaccount    "TYPE c length 10
                            account "TYPE hkont
                            currency    "TYPE waers
                            nr  "TYPE dzuonr
                            ja  "TYPE gjahr
                            buz "TYPE buzei
                            debcredind  "TYPE shkzg
                            sourceamount    "TYPE p length 13 decimals 2
                            targetamount    "TYPE p length 13 decimals 2
                            targetcurrency  "TYPE hwaer
                            lcamountval "TYPE p length 13 decimals 2
                            hedgedamount    "TYPE p length 13 decimals 2
                            hedgedrate  "TYPE p length 5 decimals 5
                            valuationrate   "TYPE p length 15 decimals 14
                            valuxusemdfxr   "TYPE c length 1
                            specialglind    "TYPE c length 1
                            origrate    "TYPE p length 15 decimals 14
                            doctype "TYPE blart
                            postingdate "TYPE budat
                            documentdate    "TYPE bldat
                            clearingdocument    "TYPE augbl
                            valudiffold "TYPE p length 13 decimals 2
                            valudiffnew "TYPE p length 13 decimals 2
                            postingamount   "TYPE p length 13 decimals 2
                            realdiff    "TYPE p length 13 decimals 2
                            vbund   "TYPE c length 6
                            accounttext "TYPE txt50_skat
                            valudiffrem2    "TYPE p length 13 decimals 2
                            currrem2    "TYPE hwae2
                            valudiffrem3    "TYPE p length 13 decimals 2
                            currrem3    "TYPE c length 5
                            valudiffrem4    "TYPE p length 13 decimals 2
                            currrem4    "TYPE c length 5
                            valudiffrem5    "TYPE p length 13 decimals 2
                            currrem5    "TYPE c length 5
                            valudiffrem6    "TYPE p length 13 decimals 2
                            currrem6    "TYPE c length 5
                            valudiffrem7    "TYPE p length 13 decimals 2
                            currrem7    "TYPE c length 5
                            valudiffrem8    "TYPE p length 13 decimals 2
                            currrem8    "TYPE c length 5
                            valudiffrem9    "TYPE p length 13 decimals 2
                            currrem9   "TYPE c length 5
                            valudiffrem10   "TYPE p length 13 decimals 2
                            currrem10   "TYPE c length 5
                            xloss   "TYPE c length 1
                            custvendname    "TYPE name1_gp
                            hrate   "TYPE p length 5 decimals 5
                            htext   "TYPE c length 70
                            maturity    "TYPE c length 4
                            maturityunit    "TYPE c length 1
                            intvaluratec    "TYPE c length 30
                            accas   "TYPE c length 30
                            pprctr  "TYPE pprctr
                            prctr   "TYPE prctr
                            psegment    "TYPE fb_psegment
                            rbusa   "TYPE gsber
                            rfarea  "TYPE fkber
                            sbusa   "TYPE c length 4
                            segment "TYPE fb_segment
                            valobjtype  "TYPE c length 4
                            valobjid    "TYPE c length 32
                            valsobjid   "TYPE c length 32
*                            createdby   "TYPE abp_creation_user
*                            createdat   "TYPE abp_creation_tstmpl
*                            locallastchangedby  "TYPE abp_locinst_lastchange_user
*                            locallastchangedat  "TYPE abp_locinst_lastchange_tstmpl
*                            lastchangedat   "TYPE abp_lastchange_tstmpl
                           ) WITH lt_create
         MAPPED DATA(lt_mapped_create)
         REPORTED DATA(lt_mapped_reported)
         FAILED DATA(lt_failed_create).
    ENDIF.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_uiin_faglfcv IN LOCAL MODE
               ENTITY zruiinfaglfcv
               UPDATE FIELDS (
*                                  ccode  "type bukrs
*                                  docnumber   "type belnr_d
*                                  fiscalyear  "type gjahr
*                                  docline "type buzei
*                                  docnumbercl "TYPE belnr_d
*                                  fiscalyearcl
                                  keydate
                                  ledger  "type c length 2
                                  ledgergroup "TYPE c length 4
                                  targetccode "TYPE c length 4
                                  valuationgroup  "TYPE c length 40
                                  accounttype "TYPE koart
                                  glaccount   "TYPE hkont
                                  groupaccount    "TYPE c length 10
                                  account "TYPE hkont
                                  currency    "TYPE waers
                                  nr  "TYPE dzuonr
                                  ja  "TYPE gjahr
                                  buz "TYPE buzei
                                  debcredind  "TYPE shkzg
                                  sourceamount    "TYPE p length 13 decimals 2
                                  targetamount    "TYPE p length 13 decimals 2
                                  targetcurrency  "TYPE hwaer
                                  lcamountval "TYPE p length 13 decimals 2
                                  hedgedamount    "TYPE p length 13 decimals 2
                                  hedgedrate  "TYPE p length 5 decimals 5
                                  valuationrate   "TYPE p length 15 decimals 14
                                  valuxusemdfxr   "TYPE c length 1
                                  specialglind    "TYPE c length 1
                                  origrate    "TYPE p length 15 decimals 14
                                  doctype "TYPE blart
                                  postingdate "TYPE budat
                                  documentdate    "TYPE bldat
                                  clearingdocument    "TYPE augbl
                                  valudiffold "TYPE p length 13 decimals 2
                                  valudiffnew "TYPE p length 13 decimals 2
                                  postingamount   "TYPE p length 13 decimals 2
                                  realdiff    "TYPE p length 13 decimals 2
                                  vbund   "TYPE c length 6
                                  accounttext "TYPE txt50_skat
                                  valudiffrem2    "TYPE p length 13 decimals 2
                                  currrem2    "TYPE hwae2
                                  valudiffrem3    "TYPE p length 13 decimals 2
                                  currrem3    "TYPE c length 5
                                  valudiffrem4    "TYPE p length 13 decimals 2
                                  currrem4    "TYPE c length 5
                                  valudiffrem5    "TYPE p length 13 decimals 2
                                  currrem5    "TYPE c length 5
                                  valudiffrem6    "TYPE p length 13 decimals 2
                                  currrem6    "TYPE c length 5
                                  valudiffrem7    "TYPE p length 13 decimals 2
                                  currrem7    "TYPE c length 5
                                  valudiffrem8    "TYPE p length 13 decimals 2
                                  currrem8    "TYPE c length 5
                                  valudiffrem9    "TYPE p length 13 decimals 2
                                  currrem9   "TYPE c length 5
                                  valudiffrem10   "TYPE p length 13 decimals 2
                                  currrem10   "TYPE c length 5
                                  xloss   "TYPE c length 1
                                  custvendname    "TYPE name1_gp
                                  hrate   "TYPE p length 5 decimals 5
                                  htext   "TYPE c length 70
                                  maturity    "TYPE c length 4
                                  maturityunit    "TYPE c length 1
                                  intvaluratec    "TYPE c length 30
                                  accas   "TYPE c length 30
                                  pprctr  "TYPE pprctr
                                  prctr   "TYPE prctr
                                  psegment    "TYPE fb_psegment
                                  rbusa   "TYPE gsber
                                  rfarea  "TYPE fkber
                                  sbusa   "TYPE c length 4
                                  segment "TYPE fb_segment
                                  valobjtype  "TYPE c length 4
                                  valobjid    "TYPE c length 32
                                  valsobjid   "TYPE c length 32
*                            createdby   "TYPE abp_creation_user
*                            createdat   "TYPE abp_creation_tstmpl
*                            locallastchangedby  "TYPE abp_locinst_lastchange_user
*                            locallastchangedat  "TYPE abp_locinst_lastchange_tstmpl
*                            lastchangedat   "TYPE abp_lastchange_tstmpl
                                 ) WITH lt_update
               MAPPED DATA(lt_mapped_update)
               REPORTED lt_mapped_reported
               FAILED lt_failed_create.
    ENDIF.

    DATA: ls_failed   LIKE LINE OF failed-zruiinfaglfcv,
          ls_reported LIKE LINE OF reported-zruiinfaglfcv.

    FREE: lt_create, lt_update.

  ENDMETHOD.

  METHOD get_glmapp.
    rt_glmapp = VALUE #(
        ( glacct1 = '3311001000' glacct2 = '3319003010' )
        ( glacct1 = '3388008000' glacct2 = '3389003000' )
        ( glacct1 = '3411001000' glacct2 = '3419003000' )
        ( glacct1 = '3411002000' glacct2 = '3419003000' )
        ( glacct1 = '3411003000' glacct2 = '3419003000' )
        ( glacct1 = '3412001000' glacct2 = '3419003000' )
        ( glacct1 = '3412002000' glacct2 = '3419003000' )
        ( glacct1 = '3441001000' glacct2 = '3449003000' )
        ( glacct1 = '1311001000' glacct2 = '1319003010' )
        ( glacct1 = '1311008000' glacct2 = '1319003010' )
        ( glacct1 = '1388008000' glacct2 = '1389003000' )
    ).
  ENDMETHOD.

ENDCLASS.

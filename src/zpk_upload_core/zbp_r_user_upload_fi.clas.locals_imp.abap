CLASS lhc_file DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR file RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR file RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE file.

    METHODS setStatusToOpen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR file~setStatusToOpen.

    METHODS getExcelData FOR DETERMINE ON SAVE
      IMPORTING keys FOR file~getExcelData.

    CONSTANTS:
      BEGIN OF file_status,
        open      TYPE c LENGTH 1 VALUE 'M', "Not process
        accepted  TYPE c LENGTH 1 VALUE 'A', "Accepted
        rejected  TYPE c LENGTH 1 VALUE 'X', "Rejected
        completed TYPE c LENGTH 1 VALUE 'D', "Done
      END OF file_status.

ENDCLASS.

CLASS lhc_file IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zr_user_upload_fi IN LOCAL MODE
          ENTITY file
          ALL FIELDS WITH
          CORRESPONDING #( keys )
          RESULT FINAL(lt_header)
          FAILED failed.

    result = VALUE #(
        FOR ls_header IN lt_header
        ( %tky          = ls_header-%tky
          %action-edit  = COND #( WHEN ls_header-status = file_status-completed
                                  THEN if_abap_behv=>fc-o-disabled
                                  ELSE if_abap_behv=>fc-o-enabled )
          %delete = COND #( WHEN ls_header-status = file_status-completed
                                  THEN if_abap_behv=>fc-o-disabled
                                  ELSE if_abap_behv=>fc-o-enabled )
          %update = COND #( WHEN ls_header-status = file_status-completed
                                  THEN if_abap_behv=>fc-o-disabled
                                  ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    LOOP AT entities
           ASSIGNING FIELD-SYMBOL(<f_entities>)
           WHERE uuid IS NOT INITIAL.

      APPEND CORRESPONDING #( <f_entities> ) TO mapped-file.

    ENDLOOP.

    DATA(lt_file) = entities.
    DELETE lt_file WHERE uuid IS NOT INITIAL.

    IF lt_file IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_file ASSIGNING <f_entities>.

      TRY.
          <f_entities>-uuid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
        CATCH cx_uuid_error.
          LOOP AT lt_file ASSIGNING <f_entities>.
            APPEND VALUE #( %cid      = <f_entities>-%cid
                            %key      = <f_entities>-%key
                            %is_draft = <f_entities>-%is_draft )
                   TO reported-file.
            APPEND VALUE #( %cid      = <f_entities>-%cid
                            %key      = <f_entities>-%key
                            %is_draft = <f_entities>-%is_draft )
                   TO failed-file.
          ENDLOOP.
          EXIT.
      ENDTRY.
      <f_entities>-enduser = sy-uname.

      " Get max requirement no
      SELECT SINGLE FROM zuser_upload_fi
        FIELDS MAX( zcnt ) + 1
        WHERE end_user = @sy-uname
        INTO @FINAL(max_cnt).

      SELECT SINGLE FROM zuser_upload_d
        FIELDS MAX( zcount ) + 1
        WHERE enduser = @sy-uname
        INTO @FINAL(max_cnt_d).

      IF max_cnt = max_cnt_d.
        <f_entities>-zcount = max_cnt + 1.
      ELSEIF max_cnt_d > max_cnt.
        <f_entities>-zcount = max_cnt_d.
      ELSE.
        <f_entities>-zcount = max_cnt.
      ENDIF.

      APPEND VALUE #( %cid      = <f_entities>-%cid
                      %key      = <f_entities>-%key
                      %is_draft = <f_entities>-%is_draft )
             TO mapped-file.
    ENDLOOP.
  ENDMETHOD.

  METHOD setStatusToOpen.
    READ ENTITIES OF zr_user_upload_fi IN LOCAL MODE
       ENTITY file
         FIELDS ( status )
         WITH CORRESPONDING #( keys )
       RESULT DATA(lt_file).

    "If Status is already set, do nothing
    DELETE lt_file WHERE status IS NOT INITIAL.
    CHECK lt_file IS NOT INITIAL.

    MODIFY ENTITIES OF zr_user_upload_fi IN LOCAL MODE
      ENTITY file
        UPDATE FIELDS ( status )
        WITH VALUE #( FOR ls_file IN lt_file ( %tky  = ls_file-%tky
                                              status = file_status-open ) ).
  ENDMETHOD.

  METHOD getExcelData.

    TYPES: BEGIN OF ty_excel,
             docseqno          TYPE string,
             companycode       TYPE string,
             reference         TYPE string,
             documentdate      TYPE string,
             postingdate       TYPE string,
             taxdetdate        TYPE string,
             documenttype      TYPE string,
             docheadertext     TYPE string,
             currency          TYPE string,
             translationdate   TYPE string,
             exchangerate      TYPE string,
             customer          TYPE string,
             vendor            TYPE string,
             glaccount         TYPE string,
             transactionamount TYPE string,
             localamount       TYPE string,
             paymentblock      TYPE string,
             baselinedate      TYPE string,
             cashdiscbase      TYPE string,
             cashdiscdays1     TYPE string,
             cdpercent1        TYPE string,
             cashdiscdays2     TYPE string,
             cdpercent2        TYPE string,
             paymentmethod     TYPE string,
             pmtsupplement     TYPE string,
             paymentreference  TYPE string,
             partnerbanktype   TYPE string,
             housebank         TYPE string,
             accountid         TYPE string,
             reasoncode        TYPE string,
             netpmttermperiod  TYPE string,
             reconaccount      TYPE string,
             title             TYPE string,
             name1             TYPE string,
             name2             TYPE string,
             name3             TYPE string,
             name4             TYPE string,
             street            TYPE string,
             city              TYPE string,
             postalcode        TYPE string,
             countryregion     TYPE string,
             region            TYPE string,
             emailaddress      TYPE string,
             bankcountry       TYPE string,
             bankkey           TYPE string,
             bankaccount       TYPE string,
             bankcontrolkey    TYPE string,
             taxtype           TYPE string,
             taxnumbertype     TYPE string,
             taxnumber1        TYPE string,
             taxnumber2        TYPE string,
             taxnumber3        TYPE string,
             taxnumber4        TYPE string,
             taxnumber5        TYPE string,
             naturalperson     TYPE string,
             itemtext          TYPE string,
             taxcode           TYPE string,
             taxctryregion     TYPE string,
             assignment        TYPE string,
             refkey1           TYPE string,
             refkey2           TYPE string,
             refkey3           TYPE string,
             valuedate         TYPE string,
             costcenter        TYPE string,
             profitcenter      TYPE string,
             orderno           TYPE string,
             reasoncode2       TYPE string,
             wbselement        TYPE string,
             functionalarea    TYPE string,
             taxcountry        TYPE string,
             taxamount         TYPE string,
             taxbasetrancurr   TYPE string,
             taxamountlocal    TYPE string,
             taxbaselocal      TYPE string,
             taxitemtext       TYPE string,
             providercontract  TYPE string,
             contractitem      TYPE string,
             customer2         TYPE string,
             customergroup     TYPE string,
             industry          TYPE string,
             countryregionkey  TYPE string,
             salesorg          TYPE string,
             distchannel       TYPE string,
             division          TYPE string,
             billingtype       TYPE string,
           END OF ty_excel,

           tt_row TYPE STANDARD TABLE OF ty_excel.

    DATA lt_rows   TYPE tt_row.
    DATA lt_data   TYPE HASHED TABLE OF zuuid_data_file1 WITH UNIQUE KEY uuid.
    DATA lt_create_preview TYPE TABLE FOR CREATE zr_user_upload_fi\\file\_previewData.
    DATA lt_update TYPE TABLE FOR UPDATE zr_user_upload_fi\\previewData.

    " Read the parent instance
    READ ENTITIES OF zr_user_upload_fi IN LOCAL MODE
         ENTITY file
         ALL FIELDS WITH
         CORRESPONDING #( keys )
         RESULT FINAL(lt_inv).

    " Get attachment value from the instance
    IF lt_inv IS INITIAL.
      RETURN.
    ELSE.
      FINAL(lv_attachment) = lt_inv[ 1 ]-attachment.
    ENDIF.

    FINAL(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_attachment )->read_access( ).
    FINAL(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

    FINAL(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    FINAL(lo_execute) = lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_rows ) ).

    lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
               )->if_xco_xlsx_ra_operation~execute( ).

    IF lt_rows IS INITIAL.
      RETURN.
    ELSE.

      DO 7 TIMES.
        DELETE lt_rows INDEX 1.
      ENDDO.
    ENDIF.

    CLEAR: lt_create_preview, lt_update.

    DATA: lv_localamount       TYPE zde_dmbtr,
          lv_transactionamount TYPE zde_dmbtr,
          lv_exchangerate      TYPE zde_dmbtr,
          lv_cashdiscbase      TYPE zde_dmbtr,
          lv_cdpercent1        TYPE zde_dmbtr,
          lv_cdpercent2        TYPE zde_dmbtr,
          lv_taxamount         TYPE zde_dmbtr,
          lv_taxbasetrancurr   TYPE zde_dmbtr,
          lv_taxamountlocal    TYPE zde_dmbtr,
          lv_taxbaselocal      TYPE zde_dmbtr.

    LOOP AT lt_inv ASSIGNING FIELD-SYMBOL(<f_file>).

      LOOP AT lt_rows INTO FINAL(ls_row).
        FINAL(lv_tabix) = sy-tabix.

        TRY.
            APPEND VALUE #(
                            %is_draft = <f_file>-%is_draft
                            enduser   = <f_file>-enduser
                            uuid  = <f_file>-uuid
                            %target   = VALUE #( ( %cid     = lv_tabix
                                                 %is_draft  = <f_file>-%is_draft
                                                 "uuid       = <f_file>-Uuid
                                                 useruuid   = <f_file>-uuid
                                                 enduser    = <f_file>-enduser

                                                docseqno        = ls_row-docseqno
                                                companycode     = ls_row-companycode
                                                reference       = ls_row-reference
                                                documentdate    = ls_row-documentdate
                                                postingdate     = ls_row-postingdate
                                                taxdetdate      = ls_row-taxdetdate
                                                documenttype    = ls_row-documenttype
                                                docheadertext   = ls_row-docheadertext
                                                currency        = ls_row-currency
                                                translationdate = ls_row-translationdate
                                                exchangerate    = conv #( ls_row-exchangerate )
                                                customer        = ls_row-customer
                                                vendor          = ls_row-vendor
                                                glaccount       = ls_row-glaccount
                                                transactionamount = conv #( ls_row-transactionamount )
                                                localamount     = conv #( ls_row-localamount )
                                                paymentblock    = ls_row-paymentblock
                                                baselinedate    = ls_row-baselinedate
                                                cashdiscbase    = conv #( ls_row-cashdiscbase )
                                                cashdiscdays1   = ls_row-cashdiscdays1
                                                cdpercent1      = conv #( ls_row-cdpercent1 )
                                                cashdiscdays2   = ls_row-cashdiscdays2
                                                cdpercent2      = conv #( ls_row-cdpercent2 )
                                                paymentmethod   = ls_row-paymentmethod
                                                pmtsupplement   = ls_row-pmtsupplement
                                                paymentreference = ls_row-paymentreference
                                                partnerbanktype = ls_row-partnerbanktype
                                                housebank       = ls_row-housebank
                                                accountid       = ls_row-accountid
                                                reasoncode      = ls_row-reasoncode
                                                netpmttermperiod = ls_row-netpmttermperiod
                                                reconaccount    = ls_row-reconaccount
                                                title           = ls_row-title
                                                name1           = ls_row-name1
                                                name2           = ls_row-name2
                                                name3           = ls_row-name3
                                                name4           = ls_row-name4
                                                street          = ls_row-street
                                                city            = ls_row-city
                                                postalcode      = ls_row-postalcode
                                                countryregion   = ls_row-countryregion
                                                region          = ls_row-region
                                                emailaddress    = ls_row-emailaddress
                                                bankcountry     = ls_row-bankcountry
                                                bankkey         = ls_row-bankkey
                                                bankaccount     = ls_row-bankaccount
                                                bankcontrolkey  = ls_row-bankcontrolkey
                                                taxtype         = ls_row-taxtype
                                                taxnumbertype   = ls_row-taxnumbertype
                                                taxnumber1      = ls_row-taxnumber1
                                                taxnumber2      = ls_row-taxnumber2
                                                taxnumber3      = ls_row-taxnumber3
                                                taxnumber4      = ls_row-taxnumber4
                                                taxnumber5      = ls_row-taxnumber5
                                                naturalperson   = ls_row-naturalperson
                                                itemtext        = ls_row-itemtext
                                                taxcode         = ls_row-taxcode
                                                taxctryregion   = ls_row-taxctryregion
                                                assignment      = ls_row-assignment
                                                refkey1         = ls_row-refkey1
                                                refkey2         = ls_row-refkey2
                                                refkey3         = ls_row-refkey3
                                                valuedate       = ls_row-valuedate
                                                costcenter      = ls_row-costcenter
                                                profitcenter    = ls_row-profitcenter
                                                orderno         = ls_row-orderno
                                                reasoncode2     = ls_row-reasoncode2
                                                wbselement      = ls_row-wbselement
                                                functionalarea  = ls_row-functionalarea
                                                taxcountry      = ls_row-taxcountry
                                                taxamount       = conv #( ls_row-taxamount )
                                                taxbasetrancurr = conv #( ls_row-taxbasetrancurr )
                                                taxamountlocal  = conv #( ls_row-taxamountlocal )
                                                taxbaselocal    = conv #( ls_row-taxbaselocal )
                                                taxitemtext     = ls_row-taxitemtext
                                                providercontract = ls_row-providercontract
                                                contractitem    = ls_row-contractitem
                                                customer2       = ls_row-customer2
                                                customergroup   = ls_row-customergroup
                                                industry        = ls_row-industry
                                                countryregionkey = ls_row-countryregionkey
                                                salesorg        = ls_row-salesorg
                                                distchannel     = ls_row-distchannel
                                                division        = ls_row-division
                                                billingtype     = ls_row-billingtype
                                                createdbyuser   = cl_abap_context_info=>get_user_business_partner_id( )
                                                createddate     = cl_abap_context_info=>get_system_date( )
                                                changedbyuser   = cl_abap_context_info=>get_user_business_partner_id( )
                                                changeddate     = cl_abap_context_info=>get_system_date( )
                                                ) ) )
                TO lt_create_preview.
          CATCH cx_abap_context_info_error.
            "handle exception
        ENDTRY.
      ENDLOOP.

    ENDLOOP.

    IF lt_create_preview IS NOT INITIAL.
      "Step 3: Update new data
      MODIFY ENTITIES OF zr_user_upload_fi IN LOCAL MODE
          ENTITY file
          CREATE BY \_previewData
          FIELDS (
                    enduser
                    docseqno
                    companycode
                    reference
                    documentdate
                    postingdate
                    taxdetdate
                    documenttype
                    docheadertext
                    currency
                    translationdate
                    exchangerate
                    customer
                    vendor
                    glaccount
                    transactionamount
                    localamount
                    paymentblock
                    baselinedate
                    cashdiscbase
                    cashdiscdays1
                    cdpercent1
                    cashdiscdays2
                    cdpercent2
                    paymentmethod
                    pmtsupplement
                    paymentreference
                    partnerbanktype
                    housebank
                    accountid
                    reasoncode
                    netpmttermperiod
                    reconaccount
                    title
                    name1
                    name2
                    name3
                    name4
                    street
                    city
                    postalcode
                    countryregion
                    region
                    emailaddress
                    bankcountry
                    bankkey
                    bankaccount
                    bankcontrolkey
                    taxtype
                    taxnumbertype
                    taxnumber1
                    taxnumber2
                    taxnumber3
                    taxnumber4
                    taxnumber5
                    naturalperson
                    itemtext
                    taxcode
                    taxctryregion
                    assignment
                    refkey1
                    refkey2
                    refkey3
                    valuedate
                    costcenter
                    profitcenter
                    orderno
                    reasoncode2
                    wbselement
                    functionalarea
                    taxcountry
                    taxamount
                    taxbasetrancurr
                    taxamountlocal
                    taxbaselocal
                    taxitemtext
                    providercontract
                    contractitem
                    customer2
                    customergroup
                    industry
                    countryregionkey
                    salesorg
                    distchannel
                    division
                    billingtype
                    createdbyuser
                    createddate
                    changedbyuser
                    changeddate
                      ) WITH lt_create_preview
                   MAPPED DATA(lt_pre_map)
                   REPORTED DATA(lt_pre_report)
                   FAILED DATA(lt_pre_fail).
    ENDIF.

    "Update Status C for table Header
    MODIFY ENTITIES OF zr_user_upload_fi IN LOCAL MODE
      ENTITY file
        UPDATE FIELDS ( status )
        WITH VALUE #( FOR ls_inv IN lt_inv (
                           %tky      = ls_inv-%tky
                           status    = file_status-completed ) ).
  ENDMETHOD.

ENDCLASS.

"! <p class="shorttext synchronized">Consumption model for client proxy - generated</p>
"! This class has been generated based on the metadata with namespace
"! <em>API_PHYSICAL_INVENTORY_DOC_SRV</em>
CLASS zbpa2x_inventory_data_kho_im DEFINITION
  PUBLIC
  INHERITING FROM /iwbep/cl_v4_abs_pm_model_prov
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      "! <p class="shorttext synchronized">Types for "OData Primitive Types"</p>
      BEGIN OF tys_types_for_prim_types,
        "! Used for primitive type BATCH
        batch                      TYPE c LENGTH 10,
        "! Used for primitive type DOCUMENT_DATE
        document_date              TYPE timestamp,
        "! Used for primitive type DOCUMENT_DATE_2
        document_date_2            TYPE timestamp,
        "! Used for primitive type FISCAL_YEAR
        fiscal_year                TYPE c LENGTH 4,
        "! Used for primitive type FISCAL_YEAR_2
        fiscal_year_2              TYPE c LENGTH 4,
        "! Used for primitive type FISCAL_YEAR_3
        fiscal_year_3              TYPE c LENGTH 4,
        "! Used for primitive type FISCAL_YEAR_4
        fiscal_year_4              TYPE c LENGTH 4,
        "! Used for primitive type MATERIAL
        material                   TYPE c LENGTH 40,
        "! Used for primitive type PHYSICAL_INVENTORY_DOCUMEN
        physical_inventory_documen TYPE c LENGTH 10,
        "! Used for primitive type PHYSICAL_INVENTORY_DOCUM_2
        physical_inventory_docum_2 TYPE c LENGTH 3,
        "! Used for primitive type PHYSICAL_INVENTORY_DOCUM_3
        physical_inventory_docum_3 TYPE c LENGTH 10,
        "! Used for primitive type PHYSICAL_INVENTORY_DOCUM_4
        physical_inventory_docum_4 TYPE c LENGTH 10,
        "! Used for primitive type PHYSICAL_INVENTORY_DOCUM_5
        physical_inventory_docum_5 TYPE c LENGTH 40,
        "! Used for primitive type PHYSICAL_INVENTORY_DOCUM_6
        physical_inventory_docum_6 TYPE c LENGTH 10,
        "! Used for primitive type PHYSICAL_INVENTORY_DOCUM_7
        physical_inventory_docum_7 TYPE c LENGTH 3,
        "! Used for primitive type PHYSICAL_INVENTORY_DOCUM_8
        physical_inventory_docum_8 TYPE c LENGTH 40,
        "! Used for primitive type PHYSICAL_INVENTORY_NUMBER
        physical_inventory_number  TYPE c LENGTH 16,
        "! Used for primitive type PHYSICAL_INVENTORY_NUMBE_2
        physical_inventory_numbe_2 TYPE c LENGTH 16,
        "! Used for primitive type PHYS_INVENTORY_PLANNED_COU
        phys_inventory_planned_cou TYPE timestamp,
        "! Used for primitive type PHYS_INVENTORY_PLANNED_C_2
        phys_inventory_planned_c_2 TYPE timestamp,
        "! Used for primitive type PHYS_INVENTORY_REFERENCE_2
        phys_inventory_reference_2 TYPE c LENGTH 16,
        "! Used for primitive type PHYS_INVENTORY_REFERENCE_N
        phys_inventory_reference_n TYPE c LENGTH 16,
        "! Used for primitive type PHYS_INVTRY_DOC_HAS_QTY_SN
        phys_invtry_doc_has_qty_sn TYPE abap_bool,
        "! Used for primitive type PHYS_INVTRY_DOC_HAS_QTY__2
        phys_invtry_doc_has_qty__2 TYPE abap_bool,
        "! Used for primitive type POSTING_DATE
        posting_date               TYPE timestamp,
        "! Used for primitive type POSTING_DATE_2
        posting_date_2             TYPE timestamp,
        "! Used for primitive type POSTING_IS_BLOCKED_FOR_PHY
        posting_is_blocked_for_phy TYPE abap_bool,
        "! Used for primitive type POSTING_IS_BLOCKED_FOR_P_2
        posting_is_blocked_for_p_2 TYPE abap_bool,
        "! Used for primitive type POSTING_THRESHOLD_VALUE
        posting_threshold_value    TYPE p LENGTH 8 DECIMALS 3,
        "! Used for primitive type POSTING_THRESHOLD_VALUE_2
        posting_threshold_value_2  TYPE p LENGTH 8 DECIMALS 3,
        "! Used for primitive type REASON_FOR_PHYS_INVTRY_DIF
        reason_for_phys_invtry_dif TYPE c LENGTH 4,
      END OF tys_types_for_prim_types.

    TYPES:
      "! <p class="shorttext synchronized">Parameters of function InitiateRecount</p>
      "! <em>with the internal name</em> INITIATE_RECOUNT
      BEGIN OF tys_parameters_1,
        "! PhysicalInventoryDocument
        physical_inventory_documen TYPE c LENGTH 10,
        "! FiscalYear
        fiscal_year                TYPE c LENGTH 4,
        "! PhysInventoryPlannedCountDate
        phys_inventory_planned_cou TYPE timestamp,
        "! DocumentDate
        document_date              TYPE timestamp,
        "! PhysicalInventoryNumber
        physical_inventory_number  TYPE c LENGTH 16,
        "! PhysInventoryReferenceNumber
        phys_inventory_reference_n TYPE c LENGTH 16,
        "! PhysicalInventoryDocumentDesc
        physical_inventory_docum_2 TYPE c LENGTH 40,
        "! PostingThresholdValue
        posting_threshold_value    TYPE p LENGTH 8 DECIMALS 3,
        "! PhysInvtryDocHasQtySnapshot
        phys_invtry_doc_has_qty_sn TYPE abap_bool,
        "! PostingIsBlockedForPhysInvtry
        posting_is_blocked_for_phy TYPE abap_bool,
      END OF tys_parameters_1,
      "! <p class="shorttext synchronized">List of TYS_PARAMETERS_1</p>
      tyt_parameters_1 TYPE STANDARD TABLE OF tys_parameters_1 WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">Parameters of function InitiateRecountOnItem</p>
      "! <em>with the internal name</em> INITIATE_RECOUNT_ON_ITEM
      BEGIN OF tys_parameters_2,
        "! PhysicalInventoryDocument
        physical_inventory_documen TYPE c LENGTH 10,
        "! FiscalYear
        fiscal_year                TYPE c LENGTH 4,
        "! PhysicalInventoryDocumentItem
        physical_inventory_docum_2 TYPE c LENGTH 3,
        "! PhysInventoryPlannedCountDate
        phys_inventory_planned_cou TYPE timestamp,
        "! DocumentDate
        document_date              TYPE timestamp,
        "! PhysicalInventoryNumber
        physical_inventory_number  TYPE c LENGTH 16,
        "! PhysInventoryReferenceNumber
        phys_inventory_reference_n TYPE c LENGTH 16,
        "! PhysicalInventoryDocumentDesc
        physical_inventory_docum_3 TYPE c LENGTH 40,
        "! PhysInvtryDocHasQtySnapshot
        phys_invtry_doc_has_qty_sn TYPE abap_bool,
        "! PostingIsBlockedForPhysInvtry
        posting_is_blocked_for_phy TYPE abap_bool,
      END OF tys_parameters_2,
      "! <p class="shorttext synchronized">List of TYS_PARAMETERS_2</p>
      tyt_parameters_2 TYPE STANDARD TABLE OF tys_parameters_2 WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">Parameters of function PostDifferences</p>
      "! <em>with the internal name</em> POST_DIFFERENCES
      BEGIN OF tys_parameters_3,
        "! PostingThresholdValue
        posting_threshold_value    TYPE p LENGTH 8 DECIMALS 3,
        "! PostingDate
        posting_date               TYPE timestamp,
        "! PhysicalInventoryDocument
        physical_inventory_documen TYPE c LENGTH 10,
        "! FiscalYear
        fiscal_year                TYPE c LENGTH 4,
      END OF tys_parameters_3,
      "! <p class="shorttext synchronized">List of TYS_PARAMETERS_3</p>
      tyt_parameters_3 TYPE STANDARD TABLE OF tys_parameters_3 WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">Parameters of function PostDifferencesOnItem</p>
      "! <em>with the internal name</em> POST_DIFFERENCES_ON_ITEM
      BEGIN OF tys_parameters_4,
        "! PhysicalInventoryDocumentItem
        physical_inventory_documen TYPE c LENGTH 3,
        "! Material
        material                   TYPE c LENGTH 40,
        "! PhysicalInventoryDocument
        physical_inventory_docum_2 TYPE c LENGTH 10,
        "! FiscalYear
        fiscal_year                TYPE c LENGTH 4,
        "! Batch
        batch                      TYPE c LENGTH 10,
        "! ReasonForPhysInvtryDifference
        reason_for_phys_invtry_dif TYPE c LENGTH 4,
        "! PostingDate
        posting_date               TYPE timestamp,
      END OF tys_parameters_4,
      "! <p class="shorttext synchronized">List of TYS_PARAMETERS_4</p>
      tyt_parameters_4 TYPE STANDARD TABLE OF tys_parameters_4 WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">A_PhysInventoryDocHeaderType</p>
      BEGIN OF tys_a_phys_inventory_doc_hea_2,
        "! <em>Key property</em> FiscalYear
        fiscal_year                TYPE c LENGTH 4,
        "! <em>Key property</em> PhysicalInventoryDocument
        physical_inventory_documen TYPE c LENGTH 10,
        "! InventoryTransactionType
        inventory_transaction_type TYPE c LENGTH 2,
        "! Plant
        plant                      TYPE c LENGTH 4,
        "! StorageLocation
        storage_location           TYPE c LENGTH 4,
        "! InventorySpecialStockType
        inventory_special_stock_ty TYPE c LENGTH 1,
        "! DocumentDate
        document_date              TYPE datn,
        "! PhysInventoryPlannedCountDate
        phys_inventory_planned_cou TYPE datn,
        "! PhysicalInventoryLastCountDate
        physical_inventory_last_co TYPE datn,
        "! PostingDate
        posting_date               TYPE datn,
        "! FiscalPeriod
        fiscal_period              TYPE c LENGTH 2,
        "! CreatedByUser
        created_by_user            TYPE c LENGTH 12,
        "! PostingIsBlockedForPhysInvtry
        posting_is_blocked_for_phy TYPE abap_bool,
        "! PhysicalInventoryCountStatus
        physical_inventory_count_s TYPE c LENGTH 1,
        "! PhysInvtryAdjustmentPostingSts
        phys_invtry_adjustment_pos TYPE c LENGTH 1,
        "! PhysInvtryDeletionStatus
        phys_invtry_deletion_statu TYPE c LENGTH 1,
        "! PhysInvtryDocHasQtySnapshot
        phys_invtry_doc_has_qty_sn TYPE abap_bool,
        "! PhysicalInventoryGroupType
        physical_inventory_group_t TYPE c LENGTH 2,
        "! PhysicalInventoryGroup
        physical_inventory_group   TYPE c LENGTH 10,
        "! PhysicalInventoryNumber
        physical_inventory_number  TYPE c LENGTH 16,
        "! PhysInventoryReferenceNumber
        phys_inventory_reference_n TYPE c LENGTH 16,
        "! PhysicalInventoryDocumentDesc
        physical_inventory_docum_2 TYPE c LENGTH 40,
        "! PhysicalInventoryType
        physical_inventory_type    TYPE c LENGTH 1,
        "! LastChangeDateTime
        last_change_date_time      TYPE timestampl,
        "! odata.etag
        etag                       TYPE string,
      END OF tys_a_phys_inventory_doc_hea_2,
      "! <p class="shorttext synchronized">List of A_PhysInventoryDocHeaderType</p>
      tyt_a_phys_inventory_doc_hea_2 TYPE STANDARD TABLE OF tys_a_phys_inventory_doc_hea_2 WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">A_PhysInventoryDocItemType</p>
      BEGIN OF tys_a_phys_inventory_doc_ite_2,
        "! <em>Key property</em> FiscalYear
        fiscal_year                TYPE c LENGTH 4,
        "! <em>Key property</em> PhysicalInventoryDocument
        physical_inventory_documen TYPE c LENGTH 10,
        "! <em>Key property</em> PhysicalInventoryDocumentItem
        physical_inventory_docum_2 TYPE c LENGTH 3,
        "! Plant
        plant                      TYPE c LENGTH 4,
        "! StorageLocation
        storage_location           TYPE c LENGTH 4,
        "! Material
        material                   TYPE c LENGTH 40,
        "! Batch
        batch                      TYPE c LENGTH 10,
        "! InventorySpecialStockType
        inventory_special_stock_ty TYPE c LENGTH 1,
        "! PhysicalInventoryStockType
        physical_inventory_stock_t TYPE c LENGTH 1,
        "! SalesOrder
        sales_order                TYPE c LENGTH 10,
        "! SalesOrderItem
        sales_order_item           TYPE c LENGTH 6,
        "! Supplier
        supplier                   TYPE c LENGTH 10,
        "! Customer
        customer                   TYPE c LENGTH 10,
        "! WBSElement
        wbselement                 TYPE c LENGTH 24,
        "! LastChangeUser
        last_change_user           TYPE c LENGTH 12,
        "! LastChangeDate
        last_change_date           TYPE datn,
        "! CountedByUser
        counted_by_user            TYPE c LENGTH 12,
        "! PhysicalInventoryLastCountDate
        physical_inventory_last_co TYPE datn,
        "! AdjustmentPostingMadeByUser
        adjustment_posting_made_by TYPE c LENGTH 12,
        "! PostingDate
        posting_date               TYPE datn,
        "! PhysicalInventoryItemIsCounted
        physical_inventory_item_is TYPE abap_bool,
        "! PhysInvtryDifferenceIsPosted
        phys_invtry_difference_is  TYPE abap_bool,
        "! PhysInvtryItemIsRecounted
        phys_invtry_item_is_recoun TYPE abap_bool,
        "! PhysInvtryItemIsDeleted
        phys_invtry_item_is_delete TYPE abap_bool,
        "! IsHandledInAltvUnitOfMsr
        is_handled_in_altv_unit_of TYPE abap_bool,
        "! CycleCountType
        cycle_count_type           TYPE c LENGTH 1,
        "! IsValueOnlyMaterial
        is_value_only_material     TYPE abap_bool,
        "! PhysInventoryReferenceNumber
        phys_inventory_reference_n TYPE c LENGTH 16,
        "! MaterialDocument
        material_document          TYPE c LENGTH 10,
        "! MaterialDocumentYear
        material_document_year     TYPE c LENGTH 4,
        "! MaterialDocumentItem
        material_document_item     TYPE c LENGTH 4,
        "! PhysInvtryRecountDocument
        phys_invtry_recount_docume TYPE c LENGTH 10,
        "! PhysicalInventoryItemIsZero
        physical_inventory_item__2 TYPE abap_bool,
        "! ReasonForPhysInvtryDifference
        reason_for_phys_invtry_dif TYPE c LENGTH 4,
        "! MaterialBaseUnit
        material_base_unit         TYPE c LENGTH 3,
        "! BookQtyBfrCountInMatlBaseUnit
        book_qty_bfr_count_in_matl TYPE p LENGTH 7 DECIMALS 3,
        "! Quantity
        quantity                   TYPE p LENGTH 7 DECIMALS 3,
        "! UnitOfEntry
        unit_of_entry              TYPE c LENGTH 3,
        "! QuantityInUnitOfEntry
        quantity_in_unit_of_entry  TYPE p LENGTH 7 DECIMALS 3,
        "! Currency
        currency                   TYPE c LENGTH 5,
        "! DifferenceAmountInCoCodeCrcy
        difference_amount_in_co_co TYPE p LENGTH 8 DECIMALS 3,
        "! EnteredSlsAmtInCoCodeCrcy
        entered_sls_amt_in_co_code TYPE p LENGTH 8 DECIMALS 3,
        "! SlsPriceAmountInCoCodeCrcy
        sls_price_amount_in_co_cod TYPE p LENGTH 8 DECIMALS 3,
        "! PhysInvtryCtAmtInCoCodeCrcy
        phys_invtry_ct_amt_in_co_c TYPE p LENGTH 8 DECIMALS 3,
        "! BookQtyAmountInCoCodeCrcy
        book_qty_amount_in_co_code TYPE p LENGTH 8 DECIMALS 3,
        "! LastChangeDateTime
        last_change_date_time      TYPE timestampl,
        "! odata.etag
        etag                       TYPE string,
      END OF tys_a_phys_inventory_doc_ite_2,
      "! <p class="shorttext synchronized">List of A_PhysInventoryDocItemType</p>
      tyt_a_phys_inventory_doc_ite_2 TYPE STANDARD TABLE OF tys_a_phys_inventory_doc_ite_2 WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">A_SerialNumberPhysInventoryDocType</p>
      BEGIN OF tys_a_serial_number_phys_inv_2,
        "! <em>Key property</em> Equipment
        equipment                  TYPE c LENGTH 18,
        "! <em>Key property</em> FiscalYear
        fiscal_year                TYPE c LENGTH 4,
        "! <em>Key property</em> PhysicalInventoryDocument
        physical_inventory_documen TYPE c LENGTH 10,
        "! <em>Key property</em> PhysicalInventoryDocumentItem
        physical_inventory_docum_2 TYPE c LENGTH 3,
        "! <em>Key property</em> SerialNumberPhysicalInvtryType
        serial_number_physical_inv TYPE c LENGTH 1,
        "! Material
        material                   TYPE c LENGTH 40,
        "! SerialNumber
        serial_number              TYPE c LENGTH 18,
        "! odata.etag
        etag                       TYPE string,
      END OF tys_a_serial_number_phys_inv_2,
      "! <p class="shorttext synchronized">List of A_SerialNumberPhysInventoryDocType</p>
      tyt_a_serial_number_phys_inv_2 TYPE STANDARD TABLE OF tys_a_serial_number_phys_inv_2 WITH DEFAULT KEY.


    CONSTANTS:
      "! <p class="shorttext synchronized">Internal Names of the entity sets</p>
      BEGIN OF gcs_entity_set,
        "! A_PhysInventoryDocHeader
        "! <br/> Collection of type 'A_PhysInventoryDocHeaderType'
        a_phys_inventory_doc_heade TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'A_PHYS_INVENTORY_DOC_HEADE',
        "! A_PhysInventoryDocItem
        "! <br/> Collection of type 'A_PhysInventoryDocItemType'
        a_phys_inventory_doc_item  TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'A_PHYS_INVENTORY_DOC_ITEM',
        "! A_SerialNumberPhysInventoryDoc
        "! <br/> Collection of type 'A_SerialNumberPhysInventoryDocType'
        a_serial_number_phys_inven TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'A_SERIAL_NUMBER_PHYS_INVEN',
      END OF gcs_entity_set .

    CONSTANTS:
      "! <p class="shorttext synchronized">Internal Names of the function imports</p>
      BEGIN OF gcs_function_import,
        "! InitiateRecount
        "! <br/> See structure type {@link ..tys_parameters_1} for the parameters
        initiate_recount         TYPE /iwbep/if_cp_runtime_types=>ty_operation_name VALUE 'INITIATE_RECOUNT',
        "! InitiateRecountOnItem
        "! <br/> See structure type {@link ..tys_parameters_2} for the parameters
        initiate_recount_on_item TYPE /iwbep/if_cp_runtime_types=>ty_operation_name VALUE 'INITIATE_RECOUNT_ON_ITEM',
        "! PostDifferences
        "! <br/> See structure type {@link ..tys_parameters_3} for the parameters
        post_differences         TYPE /iwbep/if_cp_runtime_types=>ty_operation_name VALUE 'POST_DIFFERENCES',
        "! PostDifferencesOnItem
        "! <br/> See structure type {@link ..tys_parameters_4} for the parameters
        post_differences_on_item TYPE /iwbep/if_cp_runtime_types=>ty_operation_name VALUE 'POST_DIFFERENCES_ON_ITEM',
      END OF gcs_function_import.

    CONSTANTS:
      "! <p class="shorttext synchronized">Internal Names of the bound functions</p>
      BEGIN OF gcs_bound_function,
         "! Dummy field - Structure must not be empty
         dummy TYPE int1 VALUE 0,
      END OF gcs_bound_function.

    CONSTANTS:
      "! <p class="shorttext synchronized">Internal names for complex types</p>
      BEGIN OF gcs_complex_type,
         "! Dummy field - Structure must not be empty
         dummy TYPE int1 VALUE 0,
      END OF gcs_complex_type.

    CONSTANTS:
      "! <p class="shorttext synchronized">Internal names for entity types</p>
      BEGIN OF gcs_entity_type,
        "! <p class="shorttext synchronized">Internal names for A_PhysInventoryDocHeaderType</p>
        "! See also structure type {@link ..tys_a_phys_inventory_doc_hea_2}
        BEGIN OF a_phys_inventory_doc_hea_2,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! to_PhysicalInventoryDocumentItem
            to_physical_inventory_docu TYPE /iwbep/if_v4_pm_types=>ty_internal_name VALUE 'TO_PHYSICAL_INVENTORY_DOCU',
          END OF navigation,
        END OF a_phys_inventory_doc_hea_2,
        "! <p class="shorttext synchronized">Internal names for A_PhysInventoryDocItemType</p>
        "! See also structure type {@link ..tys_a_phys_inventory_doc_ite_2}
        BEGIN OF a_phys_inventory_doc_ite_2,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! to_PhysicalInventoryDocument
            to_physical_inventory_docu TYPE /iwbep/if_v4_pm_types=>ty_internal_name VALUE 'TO_PHYSICAL_INVENTORY_DOCU',
            "! to_SerialNumbers
            to_serial_numbers          TYPE /iwbep/if_v4_pm_types=>ty_internal_name VALUE 'TO_SERIAL_NUMBERS',
          END OF navigation,
        END OF a_phys_inventory_doc_ite_2,
        "! <p class="shorttext synchronized">Internal names for A_SerialNumberPhysInventoryDocType</p>
        "! See also structure type {@link ..tys_a_serial_number_phys_inv_2}
        BEGIN OF a_serial_number_phys_inv_2,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF a_serial_number_phys_inv_2,
      END OF gcs_entity_type.


    METHODS /iwbep/if_v4_mp_basic_pm~define REDEFINITION.


  PRIVATE SECTION.

    "! <p class="shorttext synchronized">Model</p>
    DATA mo_model TYPE REF TO /iwbep/if_v4_pm_model.


    "! <p class="shorttext synchronized">Define A_PhysInventoryDocHeaderType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_a_phys_inventory_doc_hea_2 RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define A_PhysInventoryDocItemType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_a_phys_inventory_doc_ite_2 RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define A_SerialNumberPhysInventoryDocType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_a_serial_number_phys_inv_2 RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define InitiateRecount</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_initiate_recount RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define InitiateRecountOnItem</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_initiate_recount_on_item RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define PostDifferences</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_post_differences RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define PostDifferencesOnItem</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_post_differences_on_item RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define all primitive types</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS define_primitive_types RAISING /iwbep/cx_gateway.

ENDCLASS.



CLASS ZBPA2X_INVENTORY_DATA_KHO_IM IMPLEMENTATION.


  METHOD /iwbep/if_v4_mp_basic_pm~define.

    mo_model = io_model.
    mo_model->set_schema_namespace( 'API_PHYSICAL_INVENTORY_DOC_SRV' ) ##NO_TEXT.

    def_a_phys_inventory_doc_hea_2( ).
    def_a_phys_inventory_doc_ite_2( ).
    def_a_serial_number_phys_inv_2( ).
    def_initiate_recount( ).
    def_initiate_recount_on_item( ).
    def_post_differences( ).
    def_post_differences_on_item( ).
    define_primitive_types( ).

  ENDMETHOD.


  METHOD define_primitive_types.

    DATA lo_primitive_type TYPE REF TO /iwbep/if_v4_pm_prim_type.


    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'BATCH'
                            iv_element             = VALUE tys_types_for_prim_types-batch( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'DOCUMENT_DATE'
                            iv_element             = VALUE tys_types_for_prim_types-document_date( ) ).
    lo_primitive_type->set_edm_type( 'DateTimeOffset' ) ##NO_TEXT.
    lo_primitive_type->set_edm_type_v2( 'DateTime' ) ##NO_TEXT.

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'DOCUMENT_DATE_2'
                            iv_element             = VALUE tys_types_for_prim_types-document_date_2( ) ).
    lo_primitive_type->set_edm_type( 'DateTimeOffset' ) ##NO_TEXT.
    lo_primitive_type->set_edm_type_v2( 'DateTime' ) ##NO_TEXT.

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'FISCAL_YEAR'
                            iv_element             = VALUE tys_types_for_prim_types-fiscal_year( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'FISCAL_YEAR_2'
                            iv_element             = VALUE tys_types_for_prim_types-fiscal_year_2( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'FISCAL_YEAR_3'
                            iv_element             = VALUE tys_types_for_prim_types-fiscal_year_3( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'FISCAL_YEAR_4'
                            iv_element             = VALUE tys_types_for_prim_types-fiscal_year_4( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'MATERIAL'
                            iv_element             = VALUE tys_types_for_prim_types-material( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYSICAL_INVENTORY_DOCUMEN'
                            iv_element             = VALUE tys_types_for_prim_types-physical_inventory_documen( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYSICAL_INVENTORY_DOCUM_2'
                            iv_element             = VALUE tys_types_for_prim_types-physical_inventory_docum_2( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYSICAL_INVENTORY_DOCUM_3'
                            iv_element             = VALUE tys_types_for_prim_types-physical_inventory_docum_3( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYSICAL_INVENTORY_DOCUM_4'
                            iv_element             = VALUE tys_types_for_prim_types-physical_inventory_docum_4( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYSICAL_INVENTORY_DOCUM_5'
                            iv_element             = VALUE tys_types_for_prim_types-physical_inventory_docum_5( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYSICAL_INVENTORY_DOCUM_6'
                            iv_element             = VALUE tys_types_for_prim_types-physical_inventory_docum_6( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYSICAL_INVENTORY_DOCUM_7'
                            iv_element             = VALUE tys_types_for_prim_types-physical_inventory_docum_7( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYSICAL_INVENTORY_DOCUM_8'
                            iv_element             = VALUE tys_types_for_prim_types-physical_inventory_docum_8( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYSICAL_INVENTORY_NUMBER'
                            iv_element             = VALUE tys_types_for_prim_types-physical_inventory_number( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYSICAL_INVENTORY_NUMBE_2'
                            iv_element             = VALUE tys_types_for_prim_types-physical_inventory_numbe_2( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYS_INVENTORY_PLANNED_COU'
                            iv_element             = VALUE tys_types_for_prim_types-phys_inventory_planned_cou( ) ).
    lo_primitive_type->set_edm_type( 'DateTimeOffset' ) ##NO_TEXT.
    lo_primitive_type->set_edm_type_v2( 'DateTime' ) ##NO_TEXT.

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYS_INVENTORY_PLANNED_C_2'
                            iv_element             = VALUE tys_types_for_prim_types-phys_inventory_planned_c_2( ) ).
    lo_primitive_type->set_edm_type( 'DateTimeOffset' ) ##NO_TEXT.
    lo_primitive_type->set_edm_type_v2( 'DateTime' ) ##NO_TEXT.

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYS_INVENTORY_REFERENCE_2'
                            iv_element             = VALUE tys_types_for_prim_types-phys_inventory_reference_2( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYS_INVENTORY_REFERENCE_N'
                            iv_element             = VALUE tys_types_for_prim_types-phys_inventory_reference_n( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYS_INVTRY_DOC_HAS_QTY_SN'
                            iv_element             = VALUE tys_types_for_prim_types-phys_invtry_doc_has_qty_sn( ) ).
    lo_primitive_type->set_edm_type( 'Boolean' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'PHYS_INVTRY_DOC_HAS_QTY__2'
                            iv_element             = VALUE tys_types_for_prim_types-phys_invtry_doc_has_qty__2( ) ).
    lo_primitive_type->set_edm_type( 'Boolean' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'POSTING_DATE'
                            iv_element             = VALUE tys_types_for_prim_types-posting_date( ) ).
    lo_primitive_type->set_edm_type( 'DateTimeOffset' ) ##NO_TEXT.
    lo_primitive_type->set_edm_type_v2( 'DateTime' ) ##NO_TEXT.

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'POSTING_DATE_2'
                            iv_element             = VALUE tys_types_for_prim_types-posting_date_2( ) ).
    lo_primitive_type->set_edm_type( 'DateTimeOffset' ) ##NO_TEXT.
    lo_primitive_type->set_edm_type_v2( 'DateTime' ) ##NO_TEXT.

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'POSTING_IS_BLOCKED_FOR_PHY'
                            iv_element             = VALUE tys_types_for_prim_types-posting_is_blocked_for_phy( ) ).
    lo_primitive_type->set_edm_type( 'Boolean' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'POSTING_IS_BLOCKED_FOR_P_2'
                            iv_element             = VALUE tys_types_for_prim_types-posting_is_blocked_for_p_2( ) ).
    lo_primitive_type->set_edm_type( 'Boolean' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'POSTING_THRESHOLD_VALUE'
                            iv_element             = VALUE tys_types_for_prim_types-posting_threshold_value( ) ).
    lo_primitive_type->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_type->set_precision( 14 ) ##NUMBER_OK.
    lo_primitive_type->set_scale( 3 ) ##NUMBER_OK.

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'POSTING_THRESHOLD_VALUE_2'
                            iv_element             = VALUE tys_types_for_prim_types-posting_threshold_value_2( ) ).
    lo_primitive_type->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_type->set_precision( 14 ) ##NUMBER_OK.
    lo_primitive_type->set_scale( 3 ) ##NUMBER_OK.

    lo_primitive_type = mo_model->create_primitive_type_by_elem(
                            iv_primitive_type_name = 'REASON_FOR_PHYS_INVTRY_DIF'
                            iv_element             = VALUE tys_types_for_prim_types-reason_for_phys_invtry_dif( ) ).
    lo_primitive_type->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_type->set_scale_variable( ).

  ENDMETHOD.


  METHOD def_a_phys_inventory_doc_hea_2.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'A_PHYS_INVENTORY_DOC_HEA_2'
                                    is_structure              = VALUE tys_a_phys_inventory_doc_hea_2( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'A_PhysInventoryDocHeaderType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'A_PHYS_INVENTORY_DOC_HEADE' ).
    lo_entity_set->set_edm_name( 'A_PhysInventoryDocHeader' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'FISCAL_YEAR' ).
    lo_primitive_property->set_edm_name( 'FiscalYear' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_DOCUMEN' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryDocument' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'INVENTORY_TRANSACTION_TYPE' ).
    lo_primitive_property->set_edm_name( 'InventoryTransactionType' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 2 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT' ).
    lo_primitive_property->set_edm_name( 'Plant' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'STORAGE_LOCATION' ).
    lo_primitive_property->set_edm_name( 'StorageLocation' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'INVENTORY_SPECIAL_STOCK_TY' ).
    lo_primitive_property->set_edm_name( 'InventorySpecialStockType' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 1 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'DOCUMENT_DATE' ).
    lo_primitive_property->set_edm_name( 'DocumentDate' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Date' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).
    lo_primitive_property->set_edm_type_v2( 'DateTime' ) ##NO_TEXT.

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYS_INVENTORY_PLANNED_COU' ).
    lo_primitive_property->set_edm_name( 'PhysInventoryPlannedCountDate' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Date' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).
    lo_primitive_property->set_edm_type_v2( 'DateTime' ) ##NO_TEXT.

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_LAST_CO' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryLastCountDate' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Date' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).
    lo_primitive_property->set_edm_type_v2( 'DateTime' ) ##NO_TEXT.

    lo_primitive_property = lo_entity_type->get_primitive_property( 'POSTING_DATE' ).
    lo_primitive_property->set_edm_name( 'PostingDate' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Date' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).
    lo_primitive_property->set_edm_type_v2( 'DateTime' ) ##NO_TEXT.

    lo_primitive_property = lo_entity_type->get_primitive_property( 'FISCAL_PERIOD' ).
    lo_primitive_property->set_edm_name( 'FiscalPeriod' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 2 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'CREATED_BY_USER' ).
    lo_primitive_property->set_edm_name( 'CreatedByUser' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 12 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'POSTING_IS_BLOCKED_FOR_PHY' ).
    lo_primitive_property->set_edm_name( 'PostingIsBlockedForPhysInvtry' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Boolean' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_COUNT_S' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryCountStatus' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 1 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYS_INVTRY_ADJUSTMENT_POS' ).
    lo_primitive_property->set_edm_name( 'PhysInvtryAdjustmentPostingSts' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 1 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYS_INVTRY_DELETION_STATU' ).
    lo_primitive_property->set_edm_name( 'PhysInvtryDeletionStatus' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 1 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYS_INVTRY_DOC_HAS_QTY_SN' ).
    lo_primitive_property->set_edm_name( 'PhysInvtryDocHasQtySnapshot' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Boolean' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_GROUP_T' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryGroupType' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 2 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_GROUP' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryGroup' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_NUMBER' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryNumber' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 16 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYS_INVENTORY_REFERENCE_N' ).
    lo_primitive_property->set_edm_name( 'PhysInventoryReferenceNumber' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 16 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_DOCUM_2' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryDocumentDesc' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 40 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_TYPE' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryType' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 1 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'LAST_CHANGE_DATE_TIME' ).
    lo_primitive_property->set_edm_name( 'LastChangeDateTime' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'DateTimeOffset' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 7 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'ETAG' ).
    lo_primitive_property->set_edm_name( 'ETAG' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->use_as_etag( ).
    lo_primitive_property->set_is_technical( ).

    lo_navigation_property = lo_entity_type->create_navigation_property( 'TO_PHYSICAL_INVENTORY_DOCU' ).
    lo_navigation_property->set_edm_name( 'to_PhysicalInventoryDocumentItem' ) ##NO_TEXT.
    lo_navigation_property->set_target_entity_type_name( 'A_PHYS_INVENTORY_DOC_ITE_2' ).
    lo_navigation_property->set_target_multiplicity( /iwbep/if_v4_pm_types=>gcs_nav_multiplicity-to_many_optional ).

  ENDMETHOD.


  METHOD def_a_phys_inventory_doc_ite_2.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'A_PHYS_INVENTORY_DOC_ITE_2'
                                    is_structure              = VALUE tys_a_phys_inventory_doc_ite_2( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'A_PhysInventoryDocItemType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'A_PHYS_INVENTORY_DOC_ITEM' ).
    lo_entity_set->set_edm_name( 'A_PhysInventoryDocItem' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'FISCAL_YEAR' ).
    lo_primitive_property->set_edm_name( 'FiscalYear' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_DOCUMEN' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryDocument' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_DOCUM_2' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryDocumentItem' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT' ).
    lo_primitive_property->set_edm_name( 'Plant' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'STORAGE_LOCATION' ).
    lo_primitive_property->set_edm_name( 'StorageLocation' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'MATERIAL' ).
    lo_primitive_property->set_edm_name( 'Material' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 40 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'BATCH' ).
    lo_primitive_property->set_edm_name( 'Batch' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'INVENTORY_SPECIAL_STOCK_TY' ).
    lo_primitive_property->set_edm_name( 'InventorySpecialStockType' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 1 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_STOCK_T' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryStockType' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 1 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SALES_ORDER' ).
    lo_primitive_property->set_edm_name( 'SalesOrder' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SALES_ORDER_ITEM' ).
    lo_primitive_property->set_edm_name( 'SalesOrderItem' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 6 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SUPPLIER' ).
    lo_primitive_property->set_edm_name( 'Supplier' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'CUSTOMER' ).
    lo_primitive_property->set_edm_name( 'Customer' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'WBSELEMENT' ).
    lo_primitive_property->set_edm_name( 'WBSElement' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 24 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'LAST_CHANGE_USER' ).
    lo_primitive_property->set_edm_name( 'LastChangeUser' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 12 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'LAST_CHANGE_DATE' ).
    lo_primitive_property->set_edm_name( 'LastChangeDate' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Date' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).
    lo_primitive_property->set_edm_type_v2( 'DateTime' ) ##NO_TEXT.

    lo_primitive_property = lo_entity_type->get_primitive_property( 'COUNTED_BY_USER' ).
    lo_primitive_property->set_edm_name( 'CountedByUser' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 12 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_LAST_CO' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryLastCountDate' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Date' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).
    lo_primitive_property->set_edm_type_v2( 'DateTime' ) ##NO_TEXT.

    lo_primitive_property = lo_entity_type->get_primitive_property( 'ADJUSTMENT_POSTING_MADE_BY' ).
    lo_primitive_property->set_edm_name( 'AdjustmentPostingMadeByUser' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 12 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'POSTING_DATE' ).
    lo_primitive_property->set_edm_name( 'PostingDate' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Date' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).
    lo_primitive_property->set_edm_type_v2( 'DateTime' ) ##NO_TEXT.

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_ITEM_IS' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryItemIsCounted' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Boolean' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYS_INVTRY_DIFFERENCE_IS' ).
    lo_primitive_property->set_edm_name( 'PhysInvtryDifferenceIsPosted' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Boolean' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYS_INVTRY_ITEM_IS_RECOUN' ).
    lo_primitive_property->set_edm_name( 'PhysInvtryItemIsRecounted' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Boolean' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYS_INVTRY_ITEM_IS_DELETE' ).
    lo_primitive_property->set_edm_name( 'PhysInvtryItemIsDeleted' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Boolean' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'IS_HANDLED_IN_ALTV_UNIT_OF' ).
    lo_primitive_property->set_edm_name( 'IsHandledInAltvUnitOfMsr' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Boolean' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'CYCLE_COUNT_TYPE' ).
    lo_primitive_property->set_edm_name( 'CycleCountType' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 1 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'IS_VALUE_ONLY_MATERIAL' ).
    lo_primitive_property->set_edm_name( 'IsValueOnlyMaterial' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Boolean' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYS_INVENTORY_REFERENCE_N' ).
    lo_primitive_property->set_edm_name( 'PhysInventoryReferenceNumber' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 16 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'MATERIAL_DOCUMENT' ).
    lo_primitive_property->set_edm_name( 'MaterialDocument' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'MATERIAL_DOCUMENT_YEAR' ).
    lo_primitive_property->set_edm_name( 'MaterialDocumentYear' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'MATERIAL_DOCUMENT_ITEM' ).
    lo_primitive_property->set_edm_name( 'MaterialDocumentItem' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYS_INVTRY_RECOUNT_DOCUME' ).
    lo_primitive_property->set_edm_name( 'PhysInvtryRecountDocument' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_ITEM__2' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryItemIsZero' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Boolean' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'REASON_FOR_PHYS_INVTRY_DIF' ).
    lo_primitive_property->set_edm_name( 'ReasonForPhysInvtryDifference' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'MATERIAL_BASE_UNIT' ).
    lo_primitive_property->set_edm_name( 'MaterialBaseUnit' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'BOOK_QTY_BFR_COUNT_IN_MATL' ).
    lo_primitive_property->set_edm_name( 'BookQtyBfrCountInMatlBaseUnit' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 13 ) ##NUMBER_OK.
    lo_primitive_property->set_scale( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'QUANTITY' ).
    lo_primitive_property->set_edm_name( 'Quantity' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 13 ) ##NUMBER_OK.
    lo_primitive_property->set_scale( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'UNIT_OF_ENTRY' ).
    lo_primitive_property->set_edm_name( 'UnitOfEntry' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'QUANTITY_IN_UNIT_OF_ENTRY' ).
    lo_primitive_property->set_edm_name( 'QuantityInUnitOfEntry' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 13 ) ##NUMBER_OK.
    lo_primitive_property->set_scale( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'CURRENCY' ).
    lo_primitive_property->set_edm_name( 'Currency' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 5 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'DIFFERENCE_AMOUNT_IN_CO_CO' ).
    lo_primitive_property->set_edm_name( 'DifferenceAmountInCoCodeCrcy' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 14 ) ##NUMBER_OK.
    lo_primitive_property->set_scale( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'ENTERED_SLS_AMT_IN_CO_CODE' ).
    lo_primitive_property->set_edm_name( 'EnteredSlsAmtInCoCodeCrcy' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 14 ) ##NUMBER_OK.
    lo_primitive_property->set_scale( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SLS_PRICE_AMOUNT_IN_CO_COD' ).
    lo_primitive_property->set_edm_name( 'SlsPriceAmountInCoCodeCrcy' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 14 ) ##NUMBER_OK.
    lo_primitive_property->set_scale( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYS_INVTRY_CT_AMT_IN_CO_C' ).
    lo_primitive_property->set_edm_name( 'PhysInvtryCtAmtInCoCodeCrcy' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 14 ) ##NUMBER_OK.
    lo_primitive_property->set_scale( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'BOOK_QTY_AMOUNT_IN_CO_CODE' ).
    lo_primitive_property->set_edm_name( 'BookQtyAmountInCoCodeCrcy' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 14 ) ##NUMBER_OK.
    lo_primitive_property->set_scale( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'LAST_CHANGE_DATE_TIME' ).
    lo_primitive_property->set_edm_name( 'LastChangeDateTime' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'DateTimeOffset' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 7 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'ETAG' ).
    lo_primitive_property->set_edm_name( 'ETAG' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->use_as_etag( ).
    lo_primitive_property->set_is_technical( ).

    lo_navigation_property = lo_entity_type->create_navigation_property( 'TO_PHYSICAL_INVENTORY_DOCU' ).
    lo_navigation_property->set_edm_name( 'to_PhysicalInventoryDocument' ) ##NO_TEXT.
    lo_navigation_property->set_target_entity_type_name( 'A_PHYS_INVENTORY_DOC_HEA_2' ).
    lo_navigation_property->set_target_multiplicity( /iwbep/if_v4_pm_types=>gcs_nav_multiplicity-to_one ).

    lo_navigation_property = lo_entity_type->create_navigation_property( 'TO_SERIAL_NUMBERS' ).
    lo_navigation_property->set_edm_name( 'to_SerialNumbers' ) ##NO_TEXT.
    lo_navigation_property->set_target_entity_type_name( 'A_SERIAL_NUMBER_PHYS_INV_2' ).
    lo_navigation_property->set_target_multiplicity( /iwbep/if_v4_pm_types=>gcs_nav_multiplicity-to_many_optional ).

  ENDMETHOD.


  METHOD def_a_serial_number_phys_inv_2.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'A_SERIAL_NUMBER_PHYS_INV_2'
                                    is_structure              = VALUE tys_a_serial_number_phys_inv_2( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'A_SerialNumberPhysInventoryDocType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'A_SERIAL_NUMBER_PHYS_INVEN' ).
    lo_entity_set->set_edm_name( 'A_SerialNumberPhysInventoryDoc' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'EQUIPMENT' ).
    lo_primitive_property->set_edm_name( 'Equipment' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 18 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'FISCAL_YEAR' ).
    lo_primitive_property->set_edm_name( 'FiscalYear' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_DOCUMEN' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryDocument' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PHYSICAL_INVENTORY_DOCUM_2' ).
    lo_primitive_property->set_edm_name( 'PhysicalInventoryDocumentItem' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SERIAL_NUMBER_PHYSICAL_INV' ).
    lo_primitive_property->set_edm_name( 'SerialNumberPhysicalInvtryType' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 1 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'MATERIAL' ).
    lo_primitive_property->set_edm_name( 'Material' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 40 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SERIAL_NUMBER' ).
    lo_primitive_property->set_edm_name( 'SerialNumber' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 18 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'ETAG' ).
    lo_primitive_property->set_edm_name( 'ETAG' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->use_as_etag( ).
    lo_primitive_property->set_is_technical( ).

  ENDMETHOD.


  METHOD def_initiate_recount.

    DATA:
      lo_function        TYPE REF TO /iwbep/if_v4_pm_function,
      lo_function_import TYPE REF TO /iwbep/if_v4_pm_func_imp,
      lo_parameter       TYPE REF TO /iwbep/if_v4_pm_func_param,
      lo_return          TYPE REF TO /iwbep/if_v4_pm_func_return.


    lo_function = mo_model->create_function( 'INITIATE_RECOUNT' ).
    lo_function->set_edm_name( 'InitiateRecount' ) ##NO_TEXT.

    " Name of the runtime structure that represents the parameters of this operation
    lo_function->/iwbep/if_v4_pm_fu_advanced~set_parameter_structure_info( VALUE tys_parameters_1( ) ).

    lo_function_import = lo_function->create_function_import( 'INITIATE_RECOUNT' ).
    lo_function_import->set_edm_name( 'InitiateRecount' ) ##NO_TEXT.
    lo_function_import->/iwbep/if_v4_pm_func_imp_v2~set_http_method( 'POST' ).


    lo_parameter = lo_function->create_parameter( 'PHYSICAL_INVENTORY_DOCUMEN' ).
    lo_parameter->set_edm_name( 'PhysicalInventoryDocument' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYSICAL_INVENTORY_DOCUM_4' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'FISCAL_YEAR' ).
    lo_parameter->set_edm_name( 'FiscalYear' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'FISCAL_YEAR_3' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'PHYS_INVENTORY_PLANNED_COU' ).
    lo_parameter->set_edm_name( 'PhysInventoryPlannedCountDate' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYS_INVENTORY_PLANNED_COU' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'DOCUMENT_DATE' ).
    lo_parameter->set_edm_name( 'DocumentDate' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'DOCUMENT_DATE' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'PHYSICAL_INVENTORY_NUMBER' ).
    lo_parameter->set_edm_name( 'PhysicalInventoryNumber' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYSICAL_INVENTORY_NUMBER' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'PHYS_INVENTORY_REFERENCE_N' ).
    lo_parameter->set_edm_name( 'PhysInventoryReferenceNumber' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYS_INVENTORY_REFERENCE_N' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'PHYSICAL_INVENTORY_DOCUM_2' ).
    lo_parameter->set_edm_name( 'PhysicalInventoryDocumentDesc' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYSICAL_INVENTORY_DOCUM_5' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'POSTING_THRESHOLD_VALUE' ).
    lo_parameter->set_edm_name( 'PostingThresholdValue' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'POSTING_THRESHOLD_VALUE_2' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'PHYS_INVTRY_DOC_HAS_QTY_SN' ).
    lo_parameter->set_edm_name( 'PhysInvtryDocHasQtySnapshot' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYS_INVTRY_DOC_HAS_QTY_SN' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'POSTING_IS_BLOCKED_FOR_PHY' ).
    lo_parameter->set_edm_name( 'PostingIsBlockedForPhysInvtry' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'POSTING_IS_BLOCKED_FOR_PHY' ).
    lo_parameter->set_is_nullable( ).

    lo_return = lo_function->create_return( ).
    lo_return->set_entity_type( 'A_PHYS_INVENTORY_DOC_HEA_2' ).

  ENDMETHOD.


  METHOD def_initiate_recount_on_item.

    DATA:
      lo_function        TYPE REF TO /iwbep/if_v4_pm_function,
      lo_function_import TYPE REF TO /iwbep/if_v4_pm_func_imp,
      lo_parameter       TYPE REF TO /iwbep/if_v4_pm_func_param,
      lo_return          TYPE REF TO /iwbep/if_v4_pm_func_return.


    lo_function = mo_model->create_function( 'INITIATE_RECOUNT_ON_ITEM' ).
    lo_function->set_edm_name( 'InitiateRecountOnItem' ) ##NO_TEXT.

    " Name of the runtime structure that represents the parameters of this operation
    lo_function->/iwbep/if_v4_pm_fu_advanced~set_parameter_structure_info( VALUE tys_parameters_2( ) ).

    lo_function_import = lo_function->create_function_import( 'INITIATE_RECOUNT_ON_ITEM' ).
    lo_function_import->set_edm_name( 'InitiateRecountOnItem' ) ##NO_TEXT.
    lo_function_import->/iwbep/if_v4_pm_func_imp_v2~set_http_method( 'POST' ).


    lo_parameter = lo_function->create_parameter( 'PHYSICAL_INVENTORY_DOCUMEN' ).
    lo_parameter->set_edm_name( 'PhysicalInventoryDocument' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYSICAL_INVENTORY_DOCUM_6' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'FISCAL_YEAR' ).
    lo_parameter->set_edm_name( 'FiscalYear' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'FISCAL_YEAR_4' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'PHYSICAL_INVENTORY_DOCUM_2' ).
    lo_parameter->set_edm_name( 'PhysicalInventoryDocumentItem' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYSICAL_INVENTORY_DOCUM_7' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'PHYS_INVENTORY_PLANNED_COU' ).
    lo_parameter->set_edm_name( 'PhysInventoryPlannedCountDate' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYS_INVENTORY_PLANNED_C_2' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'DOCUMENT_DATE' ).
    lo_parameter->set_edm_name( 'DocumentDate' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'DOCUMENT_DATE_2' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'PHYSICAL_INVENTORY_NUMBER' ).
    lo_parameter->set_edm_name( 'PhysicalInventoryNumber' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYSICAL_INVENTORY_NUMBE_2' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'PHYS_INVENTORY_REFERENCE_N' ).
    lo_parameter->set_edm_name( 'PhysInventoryReferenceNumber' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYS_INVENTORY_REFERENCE_2' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'PHYSICAL_INVENTORY_DOCUM_3' ).
    lo_parameter->set_edm_name( 'PhysicalInventoryDocumentDesc' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYSICAL_INVENTORY_DOCUM_8' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'PHYS_INVTRY_DOC_HAS_QTY_SN' ).
    lo_parameter->set_edm_name( 'PhysInvtryDocHasQtySnapshot' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYS_INVTRY_DOC_HAS_QTY__2' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'POSTING_IS_BLOCKED_FOR_PHY' ).
    lo_parameter->set_edm_name( 'PostingIsBlockedForPhysInvtry' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'POSTING_IS_BLOCKED_FOR_P_2' ).
    lo_parameter->set_is_nullable( ).

    lo_return = lo_function->create_return( ).
    lo_return->set_entity_type( 'A_PHYS_INVENTORY_DOC_ITE_2' ).

  ENDMETHOD.


  METHOD def_post_differences.

    DATA:
      lo_function        TYPE REF TO /iwbep/if_v4_pm_function,
      lo_function_import TYPE REF TO /iwbep/if_v4_pm_func_imp,
      lo_parameter       TYPE REF TO /iwbep/if_v4_pm_func_param,
      lo_return          TYPE REF TO /iwbep/if_v4_pm_func_return.


    lo_function = mo_model->create_function( 'POST_DIFFERENCES' ).
    lo_function->set_edm_name( 'PostDifferences' ) ##NO_TEXT.

    " Name of the runtime structure that represents the parameters of this operation
    lo_function->/iwbep/if_v4_pm_fu_advanced~set_parameter_structure_info( VALUE tys_parameters_3( ) ).

    lo_function_import = lo_function->create_function_import( 'POST_DIFFERENCES' ).
    lo_function_import->set_edm_name( 'PostDifferences' ) ##NO_TEXT.
    lo_function_import->/iwbep/if_v4_pm_func_imp_v2~set_http_method( 'POST' ).


    lo_parameter = lo_function->create_parameter( 'POSTING_THRESHOLD_VALUE' ).
    lo_parameter->set_edm_name( 'PostingThresholdValue' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'POSTING_THRESHOLD_VALUE' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'POSTING_DATE' ).
    lo_parameter->set_edm_name( 'PostingDate' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'POSTING_DATE' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'PHYSICAL_INVENTORY_DOCUMEN' ).
    lo_parameter->set_edm_name( 'PhysicalInventoryDocument' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYSICAL_INVENTORY_DOCUMEN' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'FISCAL_YEAR' ).
    lo_parameter->set_edm_name( 'FiscalYear' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'FISCAL_YEAR' ).
    lo_parameter->set_is_nullable( ).

    lo_return = lo_function->create_return( ).
    lo_return->set_entity_type( 'A_PHYS_INVENTORY_DOC_HEA_2' ).

  ENDMETHOD.


  METHOD def_post_differences_on_item.

    DATA:
      lo_function        TYPE REF TO /iwbep/if_v4_pm_function,
      lo_function_import TYPE REF TO /iwbep/if_v4_pm_func_imp,
      lo_parameter       TYPE REF TO /iwbep/if_v4_pm_func_param,
      lo_return          TYPE REF TO /iwbep/if_v4_pm_func_return.


    lo_function = mo_model->create_function( 'POST_DIFFERENCES_ON_ITEM' ).
    lo_function->set_edm_name( 'PostDifferencesOnItem' ) ##NO_TEXT.

    " Name of the runtime structure that represents the parameters of this operation
    lo_function->/iwbep/if_v4_pm_fu_advanced~set_parameter_structure_info( VALUE tys_parameters_4( ) ).

    lo_function_import = lo_function->create_function_import( 'POST_DIFFERENCES_ON_ITEM' ).
    lo_function_import->set_edm_name( 'PostDifferencesOnItem' ) ##NO_TEXT.
    lo_function_import->/iwbep/if_v4_pm_func_imp_v2~set_http_method( 'POST' ).


    lo_parameter = lo_function->create_parameter( 'PHYSICAL_INVENTORY_DOCUMEN' ).
    lo_parameter->set_edm_name( 'PhysicalInventoryDocumentItem' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYSICAL_INVENTORY_DOCUM_2' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'MATERIAL' ).
    lo_parameter->set_edm_name( 'Material' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'MATERIAL' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'PHYSICAL_INVENTORY_DOCUM_2' ).
    lo_parameter->set_edm_name( 'PhysicalInventoryDocument' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'PHYSICAL_INVENTORY_DOCUM_3' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'FISCAL_YEAR' ).
    lo_parameter->set_edm_name( 'FiscalYear' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'FISCAL_YEAR_2' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'BATCH' ).
    lo_parameter->set_edm_name( 'Batch' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'BATCH' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'REASON_FOR_PHYS_INVTRY_DIF' ).
    lo_parameter->set_edm_name( 'ReasonForPhysInvtryDifference' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'REASON_FOR_PHYS_INVTRY_DIF' ).
    lo_parameter->set_is_nullable( ).

    lo_parameter = lo_function->create_parameter( 'POSTING_DATE' ).
    lo_parameter->set_edm_name( 'PostingDate' ) ##NO_TEXT.
    lo_parameter->set_primitive_type( 'POSTING_DATE_2' ).
    lo_parameter->set_is_nullable( ).

    lo_return = lo_function->create_return( ).
    lo_return->set_entity_type( 'A_PHYS_INVENTORY_DOC_ITE_2' ).

  ENDMETHOD.
ENDCLASS.

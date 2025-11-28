@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Work Center'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZC_WorkCenter
  as select from I_WorkCenter     as _WC
//    inner join   I_WorkCenterText as _TXT on  _TXT.WorkCenterInternalID = _WC.WorkCenterInternalID
//                                          and _TXT.WorkCenterTypeCode   = _WC.WorkCenterTypeCode
{
      //      @ObjectModel.text.association: '_Text'
      // Key
      @UI.hidden: true
  key _WC.WorkCenterInternalID    as WorkCenterInternalID,

      //      @ObjectModel.foreignKey.association: '_WorkCenterType'
      @UI.hidden: true
  key _WC.WorkCenterTypeCode      as WorkCenterTypeCode,

      // Attributes
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_WrkCtrBySemanticKeyStdVH', element: 'WorkCenter' } } ]
      @ObjectModel.foreignKey.association: '_WorkCenter'
      @ObjectModel.text.element: [ 'WorkCenterText' ]

      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      _WC.WorkCenter              as WorkCenter,

      @Semantics.text: true
      //      @UI.hidden: true
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      _WC._Text.WorkCenterText    as WorkCenterText,

      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      _WC.Plant                   as Plant,

      @UI.lineItem: [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      _WC._Plant.PlantName            as PlantName,

      @UI.hidden: true
      _WC.WorkCenterIsToBeDeleted as WorkCenterIsToBeDeleted,
      @UI.hidden: true
      _WC.WorkCenterIsLocked      as WorkCenterIsLocked,

      //      _WC.WorkCenterIsMntndForCosting,
      //      _WC.WorkCenterIsMntndForScheduling,
      //      _WC.NumberOfConfirmationSlips,
      //      _WC.AdvancedPlanningIsSupported,
      //      _WC.ShiftNoteType,
      //      _WC.ShiftReportType,
      //      _WC.WorkCenterLastChangedBy,
      //      _WC.WorkCenterLastChangeDateTime,
      //      _WC.WorkCenterCategoryCode,
      //      _WC.WorkCenterLocation,
      //      _WC.WorkCenterLocationGroup,
      //      _WC.WorkCenterUsage,
      //      _WC.WorkCenterResponsible,

      //      _WC.SupplyArea,
      //      _WC.CapacityInternalID,
      //      _WC.MachineType,
      //      _WC.OperationControlProfile,
      //      _WC.MatlCompIsMarkedForBackflush,
      //      _WC.WorkCenterSetupType,
      //      _WC.FreeDefinedTableFieldSemantic,
      //      _WC.ObjectInternalID,
      //      _WC.StandardTextInternalID,
      //      _WC.EmployeeWageType,
      //      _WC.EmployeeWageGroup,
      //      _WC.EmployeeSuitability,
      //      _WC.NumberOfTimeTickets,
      //      _WC.PlanVersion,
      //      _WC.WrkCtrHumRsceObjID,
      //      _WC.ValidityStartDate,
      //      _WC.ValidityEndDate,
      //      _WC.StandardTextIDIsReferenced,
      //      _WC.EmployeeWageTypeIsReferenced,
      //      _WC.NmbrOfTimeTicketsIsReferenced,
      //      _WC.EmployeeWageGroupIsReferenced,
      //      _WC.EmplSuitabilityIsReferenced,
      //      _WC.WorkCenterSetpTypeIsReferenced,
      //      _WC.OpControlProfileIsReferenced,
      //      _WC.NumberOfConfSlipsIsReferenced,
      //      _WC.WorkCenterStdQueueDurnUnit,
      //      _WC.WorkCenterStandardQueueDurn,
      //      _WC.WorkCenterMinimumQueueDurnUnit,
      //      _WC.WorkCenterMinimumQueueDuration,
      //      _WC.WorkCenterStandardWorkQtyUnit1,
      //      _WC.WorkCenterStandardWorkQtyUnit2,
      //      _WC.WorkCenterStandardWorkQtyUnit3,
      //      _WC.WorkCenterStandardWorkQtyUnit4,
      //      _WC.WorkCenterStandardWorkQtyUnit5,
      //      _WC.WorkCenterStandardWorkQtyUnit6,
      //      _WC.StandardWorkQuantityUnit,
      //      _WC.StandardWorkFormulaParamGroup,
      //      _WC.LaborTrackingIsRequired,
      //      _WC.WorkCenterFormulaParam1,
      //      _WC.WorkCenterFormulaParam2,
      //      _WC.WorkCenterFormulaParam3,
      //      _WC.WorkCenterFormulaParam4,
      //      _WC.WorkCenterFormulaParam5,
      //      _WC.WorkCenterFormulaParam6,
      //      _WC.WorkCenterFmlaParamValue1,
      //      _WC.WorkCenterFmlaParamValue2,
      //      _WC.WorkCenterFmlaParamValue3,
      //      _WC.WorkCenterFmlaParamValue4,
      //      _WC.WorkCenterFmlaParamValue5,
      //      _WC.WorkCenterFmlaParamValue6,
      //      _WC.WorkCenterFmlaParamUnit1,
      //      _WC.WorkCenterFmlaParamUnit2,
      //      _WC.WorkCenterFmlaParamUnit3,
      //      _WC.WorkCenterFmlaParamUnit4,
      //      _WC.WorkCenterFmlaParamUnit5,
      //      _WC.WorkCenterFmlaParamUnit6,
      //      _WC.WrkCtrStdValMaintRule1,
      //      _WC.WrkCtrStdValMaintRule2,
      //      _WC.WrkCtrStdValMaintRule3,
      //      _WC.WrkCtrStdValMaintRule4,
      //      _WC.WrkCtrStdValMaintRule5,
      //      _WC.WrkCtrStdValMaintRule6,
      //      _WC.WrkCtrSetupSchedgFmla,
      //      _WC.WrkCtrProcgSchedgFmla,
      //      _WC.WrkCtrTeardownSchedgFmla,
      //      _WC.WrkCtrIntProcgSchedgFmla,
      /* Associations */
      //      _WC._Capacity,
      //      _WC._CostCenter,
      //      _WC._EmployeeSuitability,
      //      _WC._EmployeeWageGroup,
      //      _WC._LastChangedByUser,
      //      _WC._MachineType,
      //      _WC._MinimumQueueDurationUnit,
      //      _WC._OperationControlProfile,
      _WC._Plant,
      //      _WC._ProductionResourceType,
      //      _WC._StandardQueueDurationUnit,
      //      _WC._StandardTextInternalID,
      //      _WC._StandardWorkFmlaParamGroup,
      //      _WC._StandardWorkFormulaParameter1,
      //      _WC._StandardWorkFormulaParameter2,
      //      _WC._StandardWorkFormulaParameter3,
      //      _WC._StandardWorkFormulaParameter4,
      //      _WC._StandardWorkFormulaParameter5,
      //      _WC._StandardWorkFormulaParameter6,
      //      _WC._StandardWorkQuantityUnit,
      //      _WC._SupplyArea,
      _WC._Text,
      //      _WC._ValidityEndDate,
      //      _WC._ValidityStartDate,
      _WC._WorkCenter
      //      _WC._WorkCenterCategory,
      //      _WC._WorkCenterCostCenter,
      //      _WC._WorkCenterFmlaParamUnit1,
      //      _WC._WorkCenterFmlaParamUnit2,
      //      _WC._WorkCenterFmlaParamUnit3,
      //      _WC._WorkCenterFmlaParamUnit4,
      //      _WC._WorkCenterFmlaParamUnit5,
      //      _WC._WorkCenterFmlaParamUnit6,
      //      _WC._WorkCenterLocation,
      //      _WC._WorkCenterLocationGroup,
      //      _WC._WorkCenterResponsible,
      //      _WC._WorkCenterSetupType,
      //      _WC._WorkCenterType,
      //      _WC._WorkCenterUsage,
      //      _WC._WorkQuantityUnit1,
      //      _WC._WorkQuantityUnit2,
      //      _WC._WorkQuantityUnit3,
      //      _WC._WorkQuantityUnit4,
      //      _WC._WorkQuantityUnit5,
      //      _WC._WorkQuantityUnit6,
      //      _WC._WrkCtrIntProcgSchedgFormula,
      //      _WC._WrkCtrProcgSchedgFormula,
      //      _WC._WrkCtrSchedgSetupFormula,
      //      _WC._WrkCtrTeardownSchedgFormula
}

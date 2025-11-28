@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View Data Khai báo thuế 0%'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
//@ObjectModel.usageType:{
//    serviceQuality: #X,
//    sizeCategory: #S,
//    dataClass: #MIXED
//}

define root view entity ZC_DATA_KB_THUE0
  provider contract transactional_query
  as projection on ZI_DATA_KB_THUE0

{
  key Uuid,
      Documentnumber,

      @ObjectModel.text.element: ['CompanyCodeName']
      @Search.defaultSearchElement:true
      @Search.fuzzinessThreshold:0.8
      @Search.ranking:#HIGH
      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_CompanyCodeStdVH',
                     element: 'CompanyCode' }
        }]
      Companycode,

      @Semantics.text: true
      _CompanyCode.CompanyCodeName as CompanyCodeName,

      @ObjectModel.text.element: ['TypeDescription']
      @Search.defaultSearchElement:true
      @Search.fuzzinessThreshold:0.8
      @Search.ranking:#HIGH
      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'ZI_KBT_TYPE_STA',
                     element: 'Status' },
          label: 'Type'
        }]

      //      @UI.textArrangement: #TEXT_ONLY
      Type,

      @Semantics.text: true
      _OverallStatus.description   as TypeDescription,

      Mauhd,
      Documentreferenceid,
      Postingdate,
      Invoicedate,

      @ObjectModel.text.element: [ 'SupplierName' ]
      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_SupplierCompanyVH',
                     element: 'Supplier' },
          additionalBinding              : [{ element: 'CompanyCode',
                localElement: 'Companycode' }]
       }]
      Supplier,

      @Semantics.text: true
      _SupplierVH.BPSupplierName   as SupplierName,

      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_CustomerCompanyVH',
                     element: 'Customer' },
          additionalBinding              : [{ element: 'CompanyCode',
                localElement: 'Companycode' }]
       }]
      Customer,

      @Semantics.text: true
      _CustomerVH.BPCustomerName   as CustomerName,

      Itemtext,

      @Semantics.amount.currencyCode: 'LoaiTienVND'
      Doanhsovnd,
      DonGiaVND,

      //      @Semantics.currencyCode: true
      LoaiTienVND,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      Quantity,

      //I_UnitOfMeasureStdVH
      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_UnitOfMeasureStdVH',
                     element: 'UnitOfMeasure' }
       }]
      @Semantics.unitOfMeasure: true
      BaseUnit,

      @Semantics.amount.currencyCode: 'LoaiTienTe'
      DoanhSoNguyenTe,
      DonGiaNguyenTe,

      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_CurrencyStdVH',
                     element: 'Currency' }
       }]

      //      @Semantics.currencyCode: true
      LoaiTienTe,

      TenMaVangLai,
      MSTMavangLai,
      
      Note,

      Createdbyuser,
      Createddate,
      Changedbyuser,
      Changeddate,

      _OverallStatus,
      _CompanyCode,
      _SupplierVH,
      _CustomerVH
}

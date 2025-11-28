@EndUserText.label: 'PDF Stream (Accounting Document)'
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_JP_GET_DATA_REPORT_FI' }
    }

define root custom entity ZJP_C_PKT_PDFDOC
  // with parameters parameter_name : parameter_type
{
      @Search.defaultSearchElement: true
  key CompanyCode        : bukrs;
      @Search.defaultSearchElement: true
  key AccountingDocument : belnr_d;
      @Search.defaultSearchElement: true
  key FiscalYear         : gjahr;
      @Search.defaultSearchElement: true
  key accountant         : abap.string;
      @Search.defaultSearchElement: true
  key createby           : abap.string;

      Content            : abap.rawstring;

      MimeType           : abap.string;

      FileName           : abap.string;
      fileExtension      : abap.string;


}

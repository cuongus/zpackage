@AbapCatalog.sqlViewName: 'ZDNTT_SH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Đề nghị thanh toán search help'
@Metadata.ignorePropagatedAnnotations: true
define view ZC_DNTT_SH as select from ztb_dntt
{   
    key journalentry as journalentry,
    key fiscalyear as fiscalyear,
    key companycode as companycode,
    sodenghi as Sodenghi,
    @EndUserText.label: 'Supplier'
    supplier as Supplier,
    @EndUserText.label: 'Customer'
    customer as Customer
}

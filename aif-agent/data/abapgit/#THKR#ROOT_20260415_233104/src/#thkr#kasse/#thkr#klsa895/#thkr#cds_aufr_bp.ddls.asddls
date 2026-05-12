@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection Aufrechnung BP'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity /THKR/CDS_AUFR_BP
  as select from I_Customer as cust
    inner join   I_Supplier as sup on  sup.BPSupplierFullName = cust.BPCustomerFullName
                                   and sup.BPAddrCityName     = cust.BPAddrCityName
                                   and sup.BPAddrStreetName   = cust.BPAddrStreetName
                                   and sup.PostalCode         = cust.PostalCode
{
  key cust.Customer        as debitor,
  key sup.Supplier         as kreditor,
      cust.BPCustomerFullName,
      sup.PostalCode
}

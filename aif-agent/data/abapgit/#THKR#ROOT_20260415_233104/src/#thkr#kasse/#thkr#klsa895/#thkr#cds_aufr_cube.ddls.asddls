@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection BSID'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity /THKR/CDS_AUFR_CUBE
  as select from /THKR/CDS_AUFR_BP       as bp
    inner join   /THKR/CDS_AUFR_CROSS_BS as BS on  BS.debitor  = bp.debitor
                                               and BS.kreditor = bp.kreditor
                                           
                                              {
  key bp.debitor,
  key bp.kreditor,
  key BS.deb_kassz,
  key BS.kre_kassz,
      BS.epl,
      BS.d_bukrs,
      BS.k_bukrs,
      bp.BPCustomerFullName as Name,
      BS.currency,
      @Semantics.amount.currencyCode : 'currency'
      BS.d_betrag           as Forderung,
      @Semantics.amount.currencyCode : 'currency'
      BS.k_betrag           as OffeneZahlung,
      bp.PostalCode         as plz
}

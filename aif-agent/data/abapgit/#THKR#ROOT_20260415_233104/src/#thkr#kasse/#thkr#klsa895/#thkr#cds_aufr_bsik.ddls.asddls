@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection Aufrechnung BSIK'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity /THKR/CDS_AUFR_BSIK
  as select from bsik_view as bsik
    join         fmifiit   as fmi on  fmi.bukrs   = bsik.bukrs
                                  and fmi.gjahr   = bsik.gjahr
                                  and fmi.knbelnr = bsik.belnr


  // inner join fmifiit as fmi on bsik.belnr = fmi.knbelnr //FI Belegnummer KNBELNR -> EPL
{
  key bsik.belnr      as belnr,
  key bsik.bukrs      as bukrs,
  key bsik.lifnr      as kreditor,
  key bsik.xblnr      as k_reference,
      fmi.fonds       as epl,
      bsik.waers      as currency,
      @Semantics.amount.currencyCode : 'currency'
      sum(bsik.wrbtr) as k_betrag
}
where
  bsik.xblnr <> ''
group by
  bsik.belnr,
  bsik.bukrs,
  bsik.xblnr,
  bsik.lifnr,
  fmi.fonds,
  bsik.waers

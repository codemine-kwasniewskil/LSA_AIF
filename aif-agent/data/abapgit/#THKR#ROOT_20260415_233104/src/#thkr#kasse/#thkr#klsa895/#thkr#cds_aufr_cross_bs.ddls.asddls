@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection Aufrechnung Cross BSID/BSIK'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity /THKR/CDS_AUFR_CROSS_BS
  as select from /THKR/CDS_AUFR_BSID as bsid
    cross join   /THKR/CDS_AUFR_BSIK as bsik

{
  key bsid.bukrs       as d_bukrs,
  key bsik.bukrs       as k_bukrs,
  key bsid.debitor,
  key bsik.kreditor,
  key bsid.d_reference as deb_kassz,
  key bsik.k_reference as kre_kassz,
      bsid.mahnbereich,
      bsid.currency,
      @Semantics.amount.currencyCode : 'currency'
      bsid.d_betrag,
      @Semantics.amount.currencyCode : 'currency'
      bsik.k_betrag,
      bsik.epl
}
where
        bsid.d_reference <> ''
  and   bsik.k_reference <> ''
  and   bsid.d_betrag    >  5
  and(
        bsid.mahnbereich <> 'SO'
    and bsid.mahnbereich <> 'S1'
    and bsid.mahnbereich <> 'S2'
    and bsid.mahnbereich <> 'M7'
    and bsid.mahnbereich <> 'KM'
    and bsid.mahnbereich <> 'KO'
  )

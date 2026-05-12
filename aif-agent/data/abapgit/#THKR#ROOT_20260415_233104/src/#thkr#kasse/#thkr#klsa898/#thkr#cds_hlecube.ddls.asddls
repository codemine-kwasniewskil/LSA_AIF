@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bericht Hinterlegung Erledigt'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #CONSUMPTION
@Analytics.dataCategory: #CUBE

define view entity /THKR/CDS_HLECUBE
  as select from /THKR/CDS_HLE_BJ as hlg
{
  key fikrs,
  key kassenzeichen,
  key epl,
  key fipex,
      kapitel,
      titel,
      aktenzeichen,
      kundenname,
      twaer,
      @Semantics.amount.currencyCode : 'twaer'
      sum(gezahlt)     as gezahlt,
      @Semantics.amount.currencyCode : 'twaer'
      sum(offenesSoll) as offenesSoll,
      verwendungszweck,
      max(erledigungsdatum)       as erledigungsdatum
}
group by
  kassenzeichen,
  aktenzeichen,
  fikrs,
  epl,
  titel,
  fipex,
  kapitel,
  verwendungszweck,
  kundenname,
  twaer

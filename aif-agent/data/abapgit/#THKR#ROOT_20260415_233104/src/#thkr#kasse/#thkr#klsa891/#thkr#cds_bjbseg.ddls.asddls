@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Belegjournal Projektion BSEG'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #BASIC
@Analytics.dataCategory: #FACT

define view entity /THKR/CDS_BJBSEG as select from bseg
{
  key bukrs,
  key belnr,
  key gjahr,
  koart,
  sgtxt,
  kunnr,
  lifnr,
  augbl,
  augdt,
  auggj,
  shkzg,
  gsber,
  rfccur,
  @Semantics.amount.currencyCode : 'RFCCUR'
  wrbtr,
  valut,
  bvtyp,
  maber
}
where
  (
       koart = 'D'
    or koart = 'K'
  )

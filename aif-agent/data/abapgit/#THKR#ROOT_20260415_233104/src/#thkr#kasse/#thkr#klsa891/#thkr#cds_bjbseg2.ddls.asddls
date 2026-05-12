@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Belegjournal Projektion BSEG 2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /THKR/CDS_BJBSEG2 as select from bseg
{
  key bukrs,
  key belnr,
  key gjahr,
  key buzei,
  sgtxt,
  kunnr,
  lifnr,
  augbl,
  augdt,
  gsber,
  auggj,
  maber
}

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: ';Mahnbereich/Hauptgruppe Cube'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #CONSUMPTION
@Analytics.dataCategory: #CUBE

define view entity /THKR/CDS_OMABERHGRCUBE
 with parameters
    p_gjahr : abap.numc( 4 )
  as select from /THKR/CDS_OMABERHGRCALC_SUM( p_gjahr : $parameters.p_gjahr ) as bj
{
  key   bj.maber,
  key   bj.hg,
        bj.twaer,
        bj.fipex,
        bj.bukrs,
        bj.AccountingDocumentType,
        bj.DocumentDate,
        count( distinct DocumentReferenceID ) as anzahl,
        @Semantics.amount.currencyCode : 'twaer'
        sum( betrag )   as betrag
}
group by
DocumentReferenceID,
  fipex,
  betrag,
  maber,
  hg,
  twaer,
  bukrs,
  AccountingDocumentType,
  DocumentDate

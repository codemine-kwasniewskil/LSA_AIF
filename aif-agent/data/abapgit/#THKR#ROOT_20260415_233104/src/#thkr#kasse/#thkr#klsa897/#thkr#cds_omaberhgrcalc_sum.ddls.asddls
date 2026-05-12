@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Mahnbereich/Hauptgruppe Cube'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #CONSUMPTION
@Analytics.dataCategory: #CUBE

define view entity /THKR/CDS_OMABERHGRCALC_SUM
  with parameters
    p_gjahr : abap.numc( 4 )
  as select from /THKR/CDS_OMABERHGRCALC as bj
{
  key   bj.maber,
  key   bj.hg,
        bj.grp,
        bj.twaer,
        bj.fipex,
        bj.DocumentReferenceID,
        bj.bukrs,
        bj.AccountingDocumentType,
        bj.DocumentDate,
        @Semantics.amount.currencyCode : 'twaer'
        sum( betrag ) as betrag
}
where
  bj.gjahr <= $parameters.p_gjahr
group by
  DocumentReferenceID,
  maber,
  hg,
  grp,
  fipex,
  twaer,
  bukrs,
  AccountingDocumentType,
  DocumentDate


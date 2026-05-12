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

define view entity /THKR/CDS_OMABERHGRCALC
  as select from /THKR/CDS_OMABERHGRBJCUBE as bj
{
    key   bj.maber,
    key   bj.hg,
       bj.grp,
       bj.twaer,
       bj.fipex,
       bj.DocumentReferenceID ,
       bj.gjahr,
       bj.bukrs,
       bj.AccountingDocumentType,
       bj.DocumentDate,
       @Semantics.amount.currencyCode : 'twaer'
       sum( betrag )                         as betrag
}
where bj.kunnr <> ' '
group by
  DocumentReferenceID,
  gjahr,
  maber,
  hg,
  grp,
  fipex,
  twaer,
  bukrs,
  AccountingDocumentType,
  DocumentDate
  

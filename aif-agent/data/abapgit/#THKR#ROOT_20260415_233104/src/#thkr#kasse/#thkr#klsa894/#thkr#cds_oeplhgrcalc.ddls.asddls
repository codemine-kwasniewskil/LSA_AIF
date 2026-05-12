@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Offene Posten Einzelplan/Haupgruppe Cube'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #CONSUMPTION
@Analytics.dataCategory: #CUBE

define view entity /THKR/CDS_OEPLHGRCALC
  as select from /THKR/CDS_OEPLHGRBJCUBE as bj
{
    key   bj.epl,
    key   bj.hg,
       bj.grp,
       bj.twaer,
       bj.fipex,
       bj.DocumentReferenceID ,
       bj.gjahr,
       bj.DocumentDate,
       @Semantics.amount.currencyCode : 'twaer'
       sum( betrag )                         as betrag
}
where bj.kunnr <> ' '
group by
  DocumentReferenceID,
  gjahr,
  epl,
  hg,
  grp,
  fipex,
  twaer,
  DocumentDate
  

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

define view entity /THKR/CDS_OEPLHGRCUBE
 with parameters
    p_gjahr : abap.numc( 4 )
  as select from /THKR/CDS_OEPLHGRCALC_SUM( p_gjahr : $parameters.p_gjahr ) as bj
{
  key   bj.epl,
  key   bj.hg,
        bj.twaer,
        bj.fipex,
        bj.DocumentDate,
        count( distinct DocumentReferenceID ) as anzahl,
        @Semantics.amount.currencyCode : 'twaer'
        sum( betrag )   as betrag
}
group by
DocumentReferenceID,
  fipex,
  betrag,
  epl,
  hg,
  twaer,
  DocumentDate

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Belegjournal Cube Valutadatum'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /THKR/CDS_BJBSEG3 as select from bkpf
inner join bseg     as bseg on  bkpf.bukrs = bseg.bukrs
                                 and bkpf.belnr = bseg.belnr
                                 and bkpf.gjahr = bseg.gjahr
{
  key bkpf.xblnr,
  key bkpf.bukrs,
  key bkpf.belnr,
  key bkpf.gjahr,
  bseg.valut
 }where
  (
    bkpf.blart like '%Z%' and
    bseg.valut is not null
  )
 

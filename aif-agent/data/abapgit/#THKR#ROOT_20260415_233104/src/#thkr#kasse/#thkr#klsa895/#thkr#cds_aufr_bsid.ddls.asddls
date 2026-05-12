@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection Aufrechnung BSID'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity /THKR/CDS_AUFR_BSID as select from bsid_view as bsid
{
  key bsid.bukrs as bukrs,
  key bsid.kunnr as debitor,
  key bsid.xblnr as d_reference,
  bsid.maber as mahnbereich,
  bsid.waers as currency,
  bsid.geber as epl, // raus , da nicht gefüllt!!!!
  @Semantics.amount.currencyCode : 'currency'
  sum(bsid.wrbtr) as d_betrag
} where  
        bsid.xblnr <> ''
    and bsid.wrbtr > 5
    and (   bsid.maber <> 'SO' 
        and bsid.maber <> 'S1' 
        and bsid.maber <> 'S2' 
        and bsid.maber <> 'M7' 
        and bsid.maber <> 'KM' 
        and bsid.maber <> 'KO' 
        ) 
  group by
    bsid.xblnr,
    bsid.bukrs,
    bsid.kunnr,
    bsid.maber,
    bsid.geber,
    bsid.waers
    

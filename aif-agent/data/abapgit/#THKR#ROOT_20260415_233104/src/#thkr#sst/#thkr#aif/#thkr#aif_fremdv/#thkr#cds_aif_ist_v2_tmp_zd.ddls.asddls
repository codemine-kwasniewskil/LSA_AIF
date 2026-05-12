@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cube IST Rückmeldungen V.2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity /THKR/CDS_AIF_IST_V2_TMP_ZD
  as select from     bkpf as k
    right outer join bseg as i    on  i.belnr   = k.belnr
                                  and i.bukrs   = k.bukrs
                                  and i.gjahr   = k.gjahr
                                  and (
                                     i.koart    = 'K'
                                     or i.koart = 'D'
                                   )
    right outer join bseg as i1s  on  i1s.belnr = i.belnr
                                  and i1s.bukrs = i.bukrs
                                  and i1s.gjahr = i.gjahr
                                  and (
                                     i1s.koart  = 'S'
                                   )
    right outer join bseg as i2dk on  i2dk.belnr <> i.belnr
                                  and i2dk.bukrs =  i.bukrs
                                  and i2dk.gjahr =  i.gjahr
                                  and i2dk.augbl =  k.belnr
                                  and i2dk.auggj =  k.gjahr
                                  and (
                                     i.koart     =  'K'
                                     or i.koart  =  'D'
                                   )
    right outer join bseg as i2s  on  i2s.belnr = i2dk.belnr
                                  and i2s.bukrs = i2dk.bukrs
                                  and i2s.gjahr = i2dk.gjahr
                                  and (
                                     i2s.koart  = 'S'
                                   )
    inner join       bkpf as k2   on  k2.belnr = i2dk.belnr
                                  and k2.bukrs = i2dk.bukrs
                                  and k2.gjahr = i2dk.gjahr

{
  key k.belnr,
  key k.bukrs,
  key k.gjahr,
      k.blart,
      k.cpudt,
      i.bschl,
      i.rfccur,
      @Semantics.amount.currencyCode : 'RFCCUR'
      i.wrbtr,
      i1s.valut    as zahlung_valut,
      i2dk.bukrs  as i2dkbukrs,
      i2dk.belnr  as i2dkbelnr,
      i2dk.gjahr  as i2dkgjahr,
      i2dk.bschl  as i2dkbschl,
      k2.xblnr    as k2xblnr,
      k2.xref1_hd,
      k2.belnr    as k1belnr,
      k2.bukrs    as k1bukr,
      k2.gjahr    as k1gjahr,
      k2.xref1_hd as k1xref1hd,
      k2.lotkz    as k1lotkz,
      i2s.valut
} //

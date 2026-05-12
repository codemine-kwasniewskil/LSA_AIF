@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cube IST Rückmeldungen V.2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity /THKR/CDS_AIF_IST_V2
  as select from     bkpf as pay_source_h
    inner join       bseg as pay_target_idk on  pay_target_idk.belnr   <> pay_source_h.belnr
                                            and pay_target_idk.bukrs   =  pay_source_h.bukrs
                                            and pay_target_idk.gjahr   =  pay_source_h.gjahr
                                            and pay_target_idk.augbl   =  pay_source_h.belnr
                                            and pay_target_idk.auggj   =  pay_source_h.gjahr
                                            and (
                                               pay_target_idk.koart    =  'K'
                                               or pay_target_idk.koart =  'D'
                                             )

    inner join       bseg as pay_source_idk on  pay_source_idk.belnr   = pay_target_idk.augbl
                                            and pay_source_idk.bukrs   = pay_target_idk.bukrs
                                            and pay_source_idk.gjahr   = pay_target_idk.gjahr
                                            and pay_source_idk.agzei   = pay_target_idk.agzei
                                            and (
                                               pay_source_idk.koart    = 'K'
                                               or pay_source_idk.koart = 'D'
                                             )
    right outer join bseg as pay_target_is  on  pay_target_is.belnr = pay_target_idk.belnr
                                            and pay_target_is.bukrs = pay_target_idk.bukrs
                                            and pay_target_is.gjahr = pay_target_idk.gjahr
                                            and (
                                               pay_target_is.koart  = 'S'
                                             )

  //      right outer join bseg as i2s  on  i2s.belnr = pay_target_idk.belnr
  //                                    and i2s.bukrs = pay_target_idk.bukrs
  //                                    and i2s.gjahr = pay_target_idk.gjahr
  //                                    and (
  //                                       i2s.koart  = 'S'
  //                                     )
    inner join       bkpf as k2             on  k2.belnr = pay_target_idk.belnr
                                            and k2.bukrs = pay_target_idk.bukrs
                                            and k2.gjahr = pay_target_idk.gjahr

  association [0..1] to /THKR/CDS_AIF_IST_RM_IBAN as _iban on  _iban.belnr = pay_source_h.belnr
                                                           and _iban.bukrs = pay_source_h.bukrs
                                                           and _iban.gjahr = pay_source_h.gjahr

  association [0..1] to I_BusinessPartner         as _bp   on  _bp.BusinessPartner = $projection.partner


{
  key pay_source_h.belnr    as ZAHL_BELNR,
  key pay_source_h.bukrs    as zahl_bukrs,
  key pay_source_h.gjahr    as ZAHL_GJAHR,
      pay_source_h.blart,
      pay_source_h.cpudt,
      pay_source_idk.bschl,
      pay_source_idk.rfccur as waers,
      @Semantics.amount.currencyCode : 'waers'
      pay_source_idk.wrbtr  as gezahlt,
      pay_source_idk.sgtxt,
      pay_target_is.valut   as valut,

      pay_target_idk.bukrs  as bukrs,
      pay_target_idk.belnr  as belnr,
      pay_target_idk.gjahr  as gjahr,
      pay_target_idk.bschl  as i2dkbschl,

      k2.xblnr              as xblnr,
      k2.xref1_hd,
      k2.lotkz              as lotkz,
      k2.budat,
      k2.bldat,
      k2.psoty,
      k2.bktxt,
      k2.psofn,
      k2.bvorg,
      k2.psobt,
      pay_target_is.fipos   as FIPEX,
      pay_target_is.fistl,
      pay_target_is.kostl,
      pay_target_is.fkber,
      pay_target_is.gsber   as geber,
      pay_target_is.hkont,
      pay_target_idk.kblnr,


      _iban._febep.piban    as iban,
      _iban._febep.paswi    as swift,
      _iban._febep.partn    as einzahler,
      _iban._febep.sgtxt    as verwendungszweck,

      case
            when pay_target_idk.kunnr is not initial then pay_target_idk.kunnr
            else pay_target_idk.lifnr
      end                   as partner,

      _bp
}

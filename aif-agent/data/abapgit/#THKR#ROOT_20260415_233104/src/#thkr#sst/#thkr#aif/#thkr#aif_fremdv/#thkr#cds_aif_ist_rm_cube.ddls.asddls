@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Belegjournal Cube'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #CONSUMPTION
@Analytics.dataCategory: #CUBE

define view entity /THKR/CDS_AIF_IST_RM_CUBE
  as select distinct from /THKR/CDS_BJFMIFIIT  as fmi
    left outer join       I_AccountingDocument as bkpf   on  fmi.bukrs   = bkpf.CompanyCode
                                                         and fmi.knbelnr = bkpf.AccountingDocument
                                                         and fmi.kngjahr = bkpf.FiscalYear


    left outer join       /THKR/CDS_BJBSEG     as bsegSI on  fmi.bukrs      = bsegSI.bukrs
                                                         and fmi.knbelnr    = bsegSI.belnr
                                                         and fmi.kngjahr    = bsegSI.gjahr
                                                         and (
                                                            fmi.wrttp       = '54'
                                                            or fmi.wrttp    = '57'
                                                          )
                                                         and (
                                                            bsegSI.koart    = 'K'
                                                            or bsegSI.koart = 'D'
                                                          )

    left outer join       /THKR/CDS_BJBSEG2    as bsegAN on  fmi.bukrs   = bsegAN.bukrs
                                                         and fmi.knbelnr = bsegAN.belnr
                                                         and fmi.kngjahr = bsegAN.gjahr
                                                         and fmi.knbuzei = bsegAN.buzei
                                                         and fmi.wrttp   = '61'

  ---------------------------------------------------------------
  association [0..1] to I_FinancialManagementArea     as _FMA     on  $projection.fikrs = _FMA.FinancialManagementArea
  association [0..1] to I_CommitmentItem              as _CI      on  $projection.Fipos = _CI.CommitmentItem
                                                                  and $projection.fikrs = _CI.FinancialManagementArea
                                                                  and $projection.hhj   = _CI.FinMgmtAreaFiscalYear
  association [0..1] to I_FiscalYearForFinMgmtArea    as _FYFFMA  on  $projection.hhj   = _FYFFMA.FinMgmtAreaFiscalYear
                                                                  and $projection.fikrs = _FYFFMA.FinancialManagementArea

  association [0..1] to I_CompanyCode                 as _CoCo    on  fmi.bukrs = _CoCo.CompanyCode

  association [0..1] to I_ControllingValueType        as _CVT     on  $projection.wrttp = _CVT.ControllingValueType

  association [0..*] to I_FundsCenter                 as _FC      on  $projection.fikrs  = _FC.FinancialManagementArea
                                                                  and $projection.Fistel = _FC.FundsCenter

  association [0..1] to /thkr/bpcube                  as _bp_kund on  _bp_kund.BPID = bsegSI.kunnr
                                                                  or  _bp_kund.BPID = bsegAN.kunnr
  association [0..1] to /thkr/bpcube                  as _bp_lief on  _bp_lief.BPID = bsegSI.lifnr
                                                                  or  _bp_lief.BPID = bsegAN.lifnr

  association [0..1] to /THKR/CDS_AIF_MI_UNION_IST_RM as _aif     on  $projection.Kassenzeichen = _aif.kassz
                                                                  and $projection.bukrs         = _aif.bukrs
                                                                  and $projection.hhj           = _aif.gjahr
                                                                  and $projection.lotkz         = _aif.lotkz
                                                                  and $projection.trbtr    = _aif.gezahlt
                                                                  

{
  key fmi.stunr,
      @ObjectModel.foreignKey.association: '_FMA'
  key fmi.fikrs,
      _FMA._Text[1: Language=$session.system_language].FinancialManagementAreaName,

      @ObjectModel.foreignKey.association: '_CI'
      fmi.fipex                       as Fipos,
      _CI._Text[1: Language=$session.system_language].CommitmentItemDescription,

      @ObjectModel.foreignKey.association: '_FC'
      fmi.fistl                       as Fistel,
      _FC._Text[1: Language=$session.system_language].FundsCenterDescription,

      @ObjectModel.foreignKey.association: '_CoCo'
      fmi.bukrs,
      _CoCo._ControllingAreaText.ControllingAreaName,
      substring(fmi.fipex, 1, 4 )     as kapitel,
      substring(fmi.fipex, 5, 5 )     as titel,
      @ObjectModel.foreignKey.association: '_FYFFMA'
      fmi.gjahr                       as hhj,
      fmi.zhldt,
      bkpf.DocumentReferenceID        as Kassenzeichen,
      bkpf.lotkz,
      bkpf.AccountingDocumentType,
      bkpf.Reference1InDocumentHeader as BelegSstKey,
      fmi.knbelnr,
      bsegSI.belnr                    as bsegsi_belnr,
      bsegAN.belnr                    as bsegan_belnr,
      fmi.kngjahr,
      fmi.knbuzei,
      fmi.wrttp,
      bkpf.AccountingDocCreatedByUser,
      fmi.twaer,
      bkpf.psofn,
      bkpf.psobt                      as kassendatum,
      fmi.btart,
      bsegSI.valut                    as valutadatum,
      bsegSI.bvtyp,
      bkpf.IntercompanyTransaction    as Zeitbuchnummer,
      bkpf.AccountingDocumentHeaderText as bktxt,
      @Semantics.amount.currencyCode : 'twaer'
      fmi.trbtr,

      case
       when _aif.SstKey is not null then 'X' else ''
      end                             as AlreadySent,

      // ----------------------------------------------------------------
      //Soll-Orginalbertrag
      @Semantics.text: true
      @EndUserText.label: 'Soll Originalbetrag'
      @Semantics.amount.currencyCode : 'twaer'
      case
        when fmi.wrttp =  '54' and fmi.btart = '0100' then fmi.trbtr
      end                             as sollOriginalbetrag,
      // ----------------------------------------------------------------
      //Gezahlt
      @Semantics.text: true
      @EndUserText.label: 'Gezahlt'
      @Semantics.amount.currencyCode : 'twaer'
      case
        when fmi.wrttp =  '57' and fmi.btart = '0250' then fmi.trbtr
        when fmi.wrttp =  '61' and fmi.btart = '0100' and bsegAN.augbl = '' then fmi.trbtr
        when fmi.wrttp =  '61' and fmi.btart = '0100' and bsegAN.augbl != '' then cast( 0 as abap.curr(22,2) )
      end                             as gezahlt,
      // ----------------------------------------------------------------
      //Stand Soll
      @Semantics.text: true
      @EndUserText.label: 'offenes Soll'
      @Semantics.amount.currencyCode : 'twaer'
      case
        when fmi.wrttp =  '54'  then fmi.trbtr
      end                             as offenesSoll,

      // ----------------------------------------------------------------
      // Ausgleichsbeleg Jahr
      case fmi.wrttp
        when '54'
           then bsegSI.auggj
        when '57'
           then bsegSI.auggj
        when '61'
           then bsegAN.auggj
      end                             as auggj,

      //Ausgleichsbeleg
      case fmi.wrttp
        when '54'
           then bsegSI.augbl
        when '57'
           then bsegSI.augbl
        when '61'
           then bsegAN.augbl
      end                             as augbl,
      // ----------------------------------------------------------------
      //Ausgleichsdatum
      case fmi.wrttp
        when '54'
           then bsegSI.augdt
        when '57'
           then bsegSI.augdt
        when '61'
           then bsegAN.augdt
      end                             as Einzahldatum,

      // ----------------------------------------------------------------
      //Erledigt = X
      case
        when (((fmi.wrttp = '54' or fmi.wrttp = '57') and bsegSI.augbl != '' )
            or  (fmi.wrttp = '61' and bsegAN.augbl != '')) then 'X'
      end                             as erledigt,

      // ----------------------------------------------------------------
      //TEXT
      case fmi.wrttp
        when '54' 
           then bsegSI.sgtxt
        when '57'
           then bsegSI.sgtxt
        when '61'
           then bsegAN.sgtxt
      end                             as aktenzeichen,
      // -----------------------------------------------------------------
      // Geschäftsbereich
      case fmi.wrttp
        when '54'
           then bsegSI.gsber
        when '57'
           then bsegSI.gsber
        when '61'
           then bsegAN.gsber
      end                             as dienstelle,
      // ----------------------------------------------------------------
      //Multiplipaktion * -1
      case
        when (fmi.wrttp = '54' or fmi.wrttp = '57') and bsegSI.shkzg = 'H' then cast(bsegSI.wrbtr * (-1) as abap.char( 30 ))
         when (fmi.wrttp = '54' or fmi.wrttp = '57') and bsegSI.shkzg = 'S' then cast(bsegSI.wrbtr as abap.char( 30 ))
      end                             as wrbtr,

      //      case
      //          when bsegSI.belnr <> '' then 'X'
      //          when bsegAN.belnr <> '' then 'X'
      //       end                            as pruefung,

      //      _bp_lief.BPName                 as lief,
      //      _bp_kund.BPName                 as kund,

      case
          when  _bp_lief.BPName is not null then _bp_lief.BPName else _bp_kund.BPName
      end                             as bpname,
      case
          when  _bp_lief.BPID is not null then _bp_lief.BPID else _bp_kund.BPID
      end                             as bpid,
      case
          when  _bp_lief.Street is not null then _bp_lief.Street else _bp_kund.Street
      end                             as bpadresse,
      case
          when  _bp_lief.HNum is not null then _bp_lief.HNum else _bp_kund.HNum
      end                             as bphousenumber,
      case
          when  _bp_lief.PLZ is not null then _bp_lief.PLZ else _bp_kund.PLZ
      end                             as bpplz,
      case
          when  _bp_lief.City is not null then _bp_lief.City else _bp_kund.City
      end                             as bpcity,
      case
          when  _bp_lief.BPCountryCode is not null then _bp_lief.BPCountryCode else _bp_kund.BPCountryCode
      end                             as BPcountrycode,

      _aif.SstKey,
      //      _iban,

      _FMA,
      _CI,
      _FYFFMA,
      _CoCo,
      _CVT,
      _FC


}
where
  (
       fmi.wrttp                       =  '54'
    or fmi.wrttp                       =  '57'
  )
  and(
       bsegSI.koart                    =  'K'
    or bsegSI.koart                    =  'D'
  )
  and  bkpf.Reference1InDocumentHeader != ''
//  )
//  or     fmi.wrttp    = '61'
//  and _aif.SstKey is not null

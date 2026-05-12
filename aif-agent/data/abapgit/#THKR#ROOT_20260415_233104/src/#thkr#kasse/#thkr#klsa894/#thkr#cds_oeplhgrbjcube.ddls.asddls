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

define view entity /THKR/CDS_OEPLHGRBJCUBE
  as select from    /THKR/CDS_OEPLHGRFMIFIIT as fmi
    left outer join I_AccountingDocument     as bkpf   on  fmi.bukrs   = bkpf.CompanyCode
                                                       and fmi.knbelnr = bkpf.AccountingDocument
                                                       and fmi.kngjahr = bkpf.FiscalYear


    left outer join /THKR/CDS_BJBSEG         as bsegSI on  fmi.bukrs      = bsegSI.bukrs
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

    left outer join /THKR/CDS_BJBSEG2        as bsegAN on  fmi.bukrs   = bsegAN.bukrs
                                                       and fmi.knbelnr = bsegAN.belnr
                                                       and fmi.kngjahr = bsegAN.gjahr
                                                       and fmi.knbuzei = bsegAN.buzei
                                                       and fmi.wrttp   = '61'

  ---------------------------------------------------------------
  //  association [0..1] to I_FinancialManagementArea  as _FMA    on  $projection.fikrs = _FMA.FinancialManagementArea
  //  association [0..1] to I_CommitmentItem           as _CI     on  $projection.fipex = _CI.CommitmentItem
  //                                                              and $projection.fikrs = _CI.FinancialManagementArea
  //                                                              and $projection.gjahr = _CI.FinMgmtAreaFiscalYear
  //  association [0..1] to I_FiscalYearForFinMgmtArea as _FYFFMA on  $projection.gjahr = _FYFFMA.FinMgmtAreaFiscalYear
  //                                                              and $projection.fikrs = _FYFFMA.FinancialManagementArea
  //
  //
  //  association [0..1] to I_CompanyCode              as _CoCo   on  fmi.bukrs = _CoCo.CompanyCode
  //
  //  association [0..1] to I_ControllingValueType     as _CVT    on  $projection.wrttp = _CVT.ControllingValueType
  //
  //  association [0..*] to I_FundsCenter              as _FC     on  $projection.fikrs = _FC.FinancialManagementArea
  //                                                              and $projection.fistl = _FC.FundsCenter
  //
  //  association [0..1] to I_BusinessPartner          as _buskun on  bsegSI.kunnr = _buskun.BusinessPartner
  //                                                              or  bsegAN.kunnr = _buskun.BusinessPartner
  //
  //
  //  association [0..1] to I_BusinessPartner          as _buslif on  bsegSI.lifnr = _buslif.BusinessPartner
  //                                                              or  bsegAN.lifnr = _buslif.BusinessPartner

{
  key fmi.stunr,

  key fmi.fikrs,
  key fmi.fonds                  as epl,
  key substring(fmi.fipex, 5, 1) as hg,
      substring(fmi.fipex, 5, 3) as grp,

      fmi.fipex,

      fmi.fistl,
      fmi.wrttp,
      fmi.bukrs,
      bkpf.DocumentReferenceID,
      fmi.gjahr,

      fmi.twaer,
      bkpf.DocumentDate,


      // ----------------------------------------------------------------
      //Soll-Orginalbertrag
      @Semantics.text: true
      @EndUserText.label: 'Soll Originalbetrag'
      @Semantics.amount.currencyCode : 'twaer'
      case
        when fmi.wrttp =  '54' and fmi.btart = '0100' then fmi.trbtr
      end                        as sollOriginalbetrag,
      // ----------------------------------------------------------------
      //Gezahlt
      @Semantics.text: true
      @EndUserText.label: 'Gezahlt'
      @Semantics.amount.currencyCode : 'twaer'
      case
        when fmi.wrttp =  '57' and fmi.btart = '0250' then fmi.trbtr
        when fmi.wrttp =  '61' and fmi.btart = '0100' and bsegAN.augbl = '' then fmi.trbtr
        when fmi.wrttp =  '61' and fmi.btart = '0100' and bsegAN.augbl != '' then cast( 0 as abap.curr(22,2) )
      end                        as gezahlt,
      // ----------------------------------------------------------------
      //Stand Soll
      @Semantics.text: true
      @EndUserText.label: 'offenes Soll'
      @Semantics.amount.currencyCode : 'twaer'
      case
        when fmi.wrttp =  '54'  then fmi.trbtr
      end                        as betrag,

      case
        when (((fmi.wrttp = '54' or fmi.wrttp = '57') and bsegSI.augbl != '' )  or  (fmi.wrttp = '61' and bsegAN.augbl != '')) then 'X'
      end                        as erledigt,

      case fmi.wrttp
        when '54'
      then bsegSI.kunnr
        when '57'
      then bsegSI.kunnr
        when '61'
      then bsegAN.kunnr
      end                        as kunnr

}
where
  (
    (
      (
            fmi.wrttp    =  '54'
        and fmi.trbtr    <> 0
      )
      or    fmi.wrttp    =  '57'
    )
    and(
            bsegSI.koart =  'K'
      or    bsegSI.koart =  'D'
    )
  )
  and(
            fmi.btart    <> '0300'
    and     fmi.btart    <> '0350'
  )
  or        fmi.wrttp    =  '61'

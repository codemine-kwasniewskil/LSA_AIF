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

define view entity /THKR/CDS_BJCUBE 
    as select from /THKR/CDS_BJFMIFIIT   as fmi
    left outer join I_AccountingDocument as bkpf   on  fmi.bukrs   = bkpf.CompanyCode
                                                   and fmi.knbelnr = bkpf.AccountingDocument
                                                   and fmi.kngjahr = bkpf.FiscalYear


    left outer join /THKR/CDS_BJBSEG     as bsegSI on  fmi.bukrs      = bsegSI.bukrs
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

    left outer join /THKR/CDS_BJBSEG2    as bsegAN on  fmi.bukrs   = bsegAN.bukrs
                                                   and fmi.knbelnr = bsegAN.belnr
                                                   and fmi.kngjahr = bsegAN.gjahr
                                                   and fmi.knbuzei = bsegAN.buzei
                                                   and fmi.wrttp   = '61'

  ---------------------------------------------------------------
  association [0..1] to I_FinancialManagementArea  as _FMA    on  $projection.fikrs = _FMA.FinancialManagementArea
  association [0..1] to I_CommitmentItem           as _CI     on  $projection.fipex = _CI.CommitmentItem
                                                              and $projection.fikrs = _CI.FinancialManagementArea
                                                              and $projection.gjahr = _CI.FinMgmtAreaFiscalYear
  association [0..1] to I_FiscalYearForFinMgmtArea as _FYFFMA on  $projection.gjahr = _FYFFMA.FinMgmtAreaFiscalYear
                                                              and $projection.fikrs = _FYFFMA.FinancialManagementArea


  association [0..1] to I_CompanyCode              as _CoCo   on  fmi.bukrs = _CoCo.CompanyCode

  association [0..1] to I_ControllingValueType     as _CVT    on  $projection.wrttp = _CVT.ControllingValueType

  association [0..*] to I_FundsCenter              as _FC     on  $projection.fikrs = _FC.FinancialManagementArea
                                                              and $projection.fistl = _FC.FundsCenter

  association [0..1] to I_BusinessPartner          as _buskun on  bsegSI.kunnr = _buskun.BusinessPartner
                                                              or  bsegAN.kunnr = _buskun.BusinessPartner


  association [0..1] to I_BusinessPartner          as _buslif on  bsegSI.lifnr = _buslif.BusinessPartner
                                                              or  bsegAN.lifnr = _buslif.BusinessPartner

{
  key fmi.stunr,
  @ObjectModel.foreignKey.association: '_FMA'
  key fmi.fikrs,
  _FMA._Text[1: Language=$session.system_language].FinancialManagementAreaName,

  @ObjectModel.foreignKey.association: '_CI'
  fmi.fipex,
  _CI._Text[1: Language=$session.system_language].CommitmentItemDescription,

  @ObjectModel.foreignKey.association: '_FC'
  fmi.fistl,
  _FC._Text[1: Language=$session.system_language].FundsCenterDescription,

  @ObjectModel.foreignKey.association: '_CVT'
  @ObjectModel.text.element: ['ControllingValueTypeName']
  fmi.wrttp,
  _CVT._Text[1: Language = $session.system_language].ControllingValueTypeName,

  @ObjectModel.foreignKey.association: '_CoCo'
  fmi.bukrs,
  _CoCo._ControllingAreaText.ControllingAreaName,

  @ObjectModel.foreignKey.association: '_FYFFMA'
  fmi.gjahr,
  
  bkpf.DocumentReferenceID,
  fmi.zhldt,
  bkpf.lotkz,
  bkpf.AccountingDocumentType,
  fmi.knbelnr,
  bsegSI.belnr                    as bsegsi_belnr,
  bsegAN.belnr                    as bsegan_belnr,
  fmi.kngjahr,
  fmi.knbuzei,
  bkpf.AccountingDocCreatedByUser,
  fmi.twaer,
  bkpf.psofn,
  fmi.btart,
  fmi.vrgng,
  bsegSI.maber,
  
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
  end       as gezahlt,
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
  // ----------------------------------------------------------------
  //Debitor
  @ObjectModel.foreignKey.association: '_buskun'
  case fmi.wrttp
    when '54'
       then bsegSI.kunnr
    when '57'
       then bsegSI.kunnr
    when '61'
       then bsegAN.kunnr
  end                             as kunnr,

  _buskun.BusinessPartnerFullName as kundenname,
  // ----------------------------------------------------------------
  //Kreditor
  @ObjectModel.foreignKey.association: '_buslif'
  case fmi.wrttp
    when '54'
       then bsegSI.lifnr
    when '57'
       then bsegSI.lifnr
    when '61'
       then bsegAN.lifnr
  end                             as lifnr,

  _buslif.BusinessPartnerFullName as lifname,
  // ----------------------------------------------------------------
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
  end                             as augdt,
  // ----------------------------------------------------------------
  //ERldedigt = X
  case
    when (((fmi.wrttp = '54' or fmi.wrttp = '57') and bsegSI.augbl != '' )  or  (fmi.wrttp = '61' and bsegAN.augbl != '')) then 'X'
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
  end                             as sgtxt,
  // -----------------------------------------------------------------
  // Geschäftsbereich
  case fmi.wrttp
    when '54'
       then bsegSI.gsber
    when '57'
       then bsegSI.gsber
    when '61'
       then bsegAN.gsber
  end                             as gsber,
  // ----------------------------------------------------------------
  //Multiplipaktion * -1
  case
    when (fmi.wrttp = '54' or fmi.wrttp = '57') and bsegSI.shkzg = 'H' then cast(bsegSI.wrbtr * (-1) as abap.char( 30 ))
     when (fmi.wrttp = '54' or fmi.wrttp = '57') and bsegSI.shkzg = 'S' then cast(bsegSI.wrbtr as abap.char( 30 ))
  end                             as wrbtr,

  case
      when bsegSI.belnr <> '' then 'X'
      when bsegAN.belnr <> '' then 'X'
   end                            as pruefung,

  bsegSI.kunnr                    as bsegSiKn,
  bsegSI.lifnr                    as bsegSiLi,
  bsegAN.kunnr                    as bsegAnKn,
  bsegAN.lifnr                    as bsegAnLi,

  _FMA,
  _CI,
  _FYFFMA,
  _CoCo,
  _CVT,
  _FC,
  _buskun,
  _buslif
}
where
  (
    (
         fmi.wrttp    = '54'
      or fmi.wrttp    = '57'
    )
    and(
         bsegSI.koart = 'K'
      or bsegSI.koart = 'D'
    )
  )
  or     fmi.wrttp    = '61'

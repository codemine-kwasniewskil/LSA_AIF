@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bericht Hinterlegung Gesamt'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #CONSUMPTION
@Analytics.dataCategory: #CUBE

/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define view entity /THKR/CDS_HLG_BJ
  as select from    /THKR/CDS_HLGFMIFIIT as fmi
    left outer join I_AccountingDocument as bkpf   on  fmi.bukrs   = bkpf.CompanyCode
                                                   and fmi.knbelnr = bkpf.AccountingDocument
                                                   and fmi.kngjahr = bkpf.FiscalYear

    left outer join /THKR/CDS_BJBSEG     as bsegSI on  fmi.bukrs   = bsegSI.bukrs
                                                   and fmi.knbelnr = bsegSI.belnr
                                                   and fmi.kngjahr = bsegSI.gjahr

    left outer join /THKR/CDS_BJBSEG2    as bsegAN on  fmi.bukrs   = bsegAN.bukrs
                                                   and fmi.knbelnr = bsegAN.belnr
                                                   and fmi.kngjahr = bsegAN.gjahr
                                                   and fmi.knbuzei = bsegAN.buzei
  //  and fmi.wrttp   = '61'

  association [0..1] to I_BusinessPartner as _buskun on bsegSI.kunnr = _buskun.BusinessPartner
                                                     or bsegAN.kunnr = _buskun.BusinessPartner

{


  key fmi.fikrs,
  key fmi.fonds                       as epl,
  key fmi.gjahr,
  key fmi.fipex,
      substring(fmi.fipex, 1, 4 )     as kapitel,
      substring(fmi.fipex, 5, 5 )     as titel,
      bkpf.DocumentReferenceID        as kassenzeichen,
      bkpf.psofn                      as aktenzeichen,
      _buskun.BusinessPartnerFullName as kundenname,
      fmi.twaer,
      //Soll-Orginalbertrag
      @Semantics.text: true
      @EndUserText.label: 'Soll Originalbetrag'
      @Semantics.amount.currencyCode : 'twaer'
      case
        when fmi.wrttp =  '54' and fmi.btart = '0100' then fmi.trbtr
      end                             as sollOriginalbetrag,
      //Gezahlt
      @Semantics.text: true
      @EndUserText.label: 'Gezahlt'
      @Semantics.amount.currencyCode : 'twaer'
      case
        when fmi.wrttp =  '57' and fmi.btart = '0250' then fmi.trbtr
        when fmi.wrttp =  '61' and fmi.btart = '0100' and bsegAN.augbl = '' then fmi.trbtr
        when fmi.wrttp =  '61' and fmi.btart = '0100' and bsegAN.augbl != '' then cast( 0 as abap.curr(22,2) )
      end                             as gezahlt,
      //Stand Soll
      @Semantics.text: true
      @EndUserText.label: 'offenes Soll'
      @Semantics.amount.currencyCode : 'twaer'
      case
        when fmi.wrttp =  '54'  then fmi.trbtr
      end                             as offenesSoll,
      // ----------------------------------------------------------------
      // ----------------------------------------------------------------
      //TEXT
      case fmi.wrttp
        when '54' then bsegSI.sgtxt
        when '57' then bsegSI.sgtxt
        when '61' then bsegAN.sgtxt
      end                             as verwendungszweck
}

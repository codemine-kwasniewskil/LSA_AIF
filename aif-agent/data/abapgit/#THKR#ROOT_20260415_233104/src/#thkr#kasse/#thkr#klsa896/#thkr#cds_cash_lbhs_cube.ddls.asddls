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
define view entity /THKR/CDS_CASH_LBHS_CUBE
  as select from    /THKR/CDS_HLGFMIFIIT as fmi
    left outer join /THKR/CDS_BJBSEG2    as bsegAN on  fmi.bukrs   = bsegAN.bukrs
                                                   and fmi.knbelnr = bsegAN.belnr
                                                   and fmi.kngjahr = bsegAN.gjahr
                                                   and fmi.knbuzei = bsegAN.buzei
  //  and fmi.wrttp   = '61'
  association [0..1] to I_CommitmentItem as _CI on  $projection.fipex = _CI.CommitmentItem
                                                and $projection.fikrs = _CI.FinancialManagementArea
                                                and $projection.gjahr = _CI.FinMgmtAreaFiscalYear


{


  key fmi.fikrs,
      //  key fmi.fonds                       as epl,
  key fmi.gjahr,
  key fmi.fipex,
      substring(fmi.fipex, 1, 4 )                                                                  as kapitel,
      substring(fmi.fipex, 5, 5 )                                                                  as titel,
      _CI._Text[1: Language=$session.system_language].CommitmentItemDescription                    as FiposText,
      _CI._Text[1: Language=$session.system_language].CommitmentItemDescription2                   as FiposText2,
      _CI._Text[1: Language=$session.system_language].CommitmentItemDescription3                   as FiposText3,
      concat( concat( _CI._Text[1: Language=$session.system_language].CommitmentItemDescription,
                      _CI._Text[1: Language=$session.system_language].CommitmentItemDescription2 ),
                      _CI._Text[1: Language=$session.system_language].CommitmentItemDescription3 ) as Bezeichnung,
      fmi.twaer,
      //Soll-Orginalbertrag
      @Semantics.text: true
      @EndUserText.label: 'Soll Originalbetrag'
      @Semantics.amount.currencyCode : 'twaer'
      case
        when fmi.wrttp =  '54' and fmi.btart = '0100' then fmi.trbtr
        else cast( 0 as abap.curr(22,2) )
      end                                                                                          as sollOriginalbetrag,
      //Gezahlt
      @Semantics.text: true
      @EndUserText.label: 'Gezahlt'
      @Semantics.amount.currencyCode : 'twaer'
      case
        when fmi.wrttp =  '57' and fmi.btart = '0250' then fmi.trbtr
        when fmi.wrttp =  '61' and fmi.btart = '0100' and bsegAN.augbl = '' then fmi.trbtr
        when fmi.wrttp =  '61' and fmi.btart = '0100' and bsegAN.augbl != '' then cast( 0 as abap.curr(22,2) )
        else cast( 0 as abap.curr(22,2) )
      end                                                                                          as gezahlt



      // ----------------------------------------------------------------
      // ----------------------------------------------------------------
      //TEXT
      //      case fmi.wrttp
      //        when '54' then bsegSI.sgtxt
      //        when '57' then bsegSI.sgtxt
      //        when '61' then bsegAN.sgtxt
      //      end                             as verwendungszweck
}

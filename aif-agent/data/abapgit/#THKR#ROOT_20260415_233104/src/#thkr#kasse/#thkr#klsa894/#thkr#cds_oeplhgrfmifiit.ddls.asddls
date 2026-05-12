@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Belegjournal Projektion FMIFIIT'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #BASIC
@Analytics.dataCategory: #FACT
define view entity /THKR/CDS_OEPLHGRFMIFIIT
  as select from fmifiit
{

  key fmbelnr,
  key fikrs,
  key fmbuzei,
  key btart,
  key rldnr,
  key gjahr,
  key stunr,
      fipex,
      wrttp,
      fistl,
      zhldt,
      vobelnr,
      knbelnr,
      vobukrs,
      vogjahr,
      perio,
      fonds,
      bukrs,
      kngjahr,
      sgtxt,
      concat('000', knbuzei)                   as knbuzei_awitem,
      concat(concat (knbelnr, bukrs), kngjahr) as refdocid,
      concat('0000000', knbuzei)               as knbuzei_refitemno,

      bus_area,
      prctr,
      hkont,
      stats,
      concat('KFS',concat(fikrs,fistl ))       as ZB_TMPL,

      substring(fipex, 1, 5)                   as fipex_4,
      @Semantics.amount.currencyCode : 'twaer'
      sum(fkbtr)                               as fkbtr,
      @Semantics.amount.currencyCode : 'twaer'
      case
            when (fkbtr < 0.0)
                then sum(fkbtr)
      end                                      as negativ,
      @Semantics.amount.currencyCode : 'twaer'
      case
           when (fkbtr > 0.0)
               then sum(fkbtr)
      end                                      as positiv,
      'K4'                                     as FiscalYearVariant,
      knbuzei,
      payflg,
      twaer,
      @Semantics.amount.currencyCode : 'twaer'
      sum(trbtr)                               as trbtr,
      //Bericht 847
      gnjhr,
      count(*)                                 as Anzahl
}
group by
  fikrs,
  gjahr,
  fipex,
  wrttp,
  fistl,
  zhldt,
  vobelnr,
  knbelnr,
  vobukrs,
  vogjahr,
  perio,
  fmbelnr,
  bukrs,
  kngjahr,
  sgtxt,
  payflg,
  knbuzei,
  bus_area,
  prctr,
  hkont,
  stats,
  rldnr,
  fkbtr,
  btart,
  twaer,
  //trbtr,
  stunr,
  fmbuzei,
  gnjhr,
  fonds

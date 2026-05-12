@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cube IST Rückmeldungen V.2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity /THKR/CDS_AIF_IST_RM_SEL_V2
  as select from /THKR/CDS_AIF_IST_V2 as base1
{
  key ZAHL_BELNR,
  key zahl_bukrs,
  key ZAHL_GJAHR,
      blart,
      cpudt,
      bschl,
      waers,
      @Semantics.amount.currencyCode : 'waers'
      gezahlt,
      sgtxt,
      valut,
      bukrs,
      belnr,
      gjahr,
      i2dkbschl,
      xblnr,
      xref1_hd,
      lotkz,
      budat,
      bldat,
      psoty,
      bktxt,
      psofn,
      bvorg,
      psobt,
      FIPEX,
      fistl,
      kostl,
      fkber,
      geber,
      hkont,
      kblnr,
      iban,
      swift,
      einzahler,
      verwendungszweck,
      partner,
      /* Associations */
      _bp.BusinessPartnerFullName              as BUSINESSPARTNER_NAME,
      _bp._DefaultAddress._Address.StreetName  as street,
      _bp._DefaultAddress._Address.HouseNumber as house_no,
      _bp._DefaultAddress._Address.PostalCode  as POSTL_COD1,
      _bp._DefaultAddress._Address.CityName    as city,
      _bp._DefaultAddress._Address._Country.Country  

}

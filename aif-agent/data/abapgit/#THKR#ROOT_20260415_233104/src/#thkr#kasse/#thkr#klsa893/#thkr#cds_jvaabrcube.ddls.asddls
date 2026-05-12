@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Offene Posten Einzelplan/Haupgruppe Cube'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #CONSUMPTION
@Analytics.dataCategory: #CUBE

define view entity /THKR/CDS_JVAABRCUBE
  as select from    /THKR/CDS_HLGFMIFIIT as fmi
    left outer join I_AccountingDocument as bkpf   on  fmi.bukrs   = bkpf.CompanyCode
                                                   and fmi.knbelnr = bkpf.AccountingDocument
                                                   and fmi.kngjahr = bkpf.FiscalYear


    left outer join /THKR/CDS_BJBSEG     as bsegSI on  fmi.bukrs   = bsegSI.bukrs
                                                   and fmi.knbelnr = bsegSI.belnr
                                                   and fmi.kngjahr = bsegSI.gjahr
                                                   and (
                                                      fmi.wrttp    = '54'
                                                    )
                                                   and (
                                                      bsegSI.koart = 'D'
                                                    )
{

  key fmi.fikrs,
  key fmi.gjahr,
  key fmi.fipex,
      substring(fmi.fipex, 1, 4 )     as kapitel,
      substring(fmi.fipex, 5, 5 )     as titel,
      //bkpf.DocumentReferenceID    as kassenzeichen,
      substring(bkpf.DocumentReferenceID,2 ,length(bkpf.DocumentReferenceID) ) as kassenzeichen,
      fmi.twaer,
      @Semantics.amount.currencyCode : 'twaer'
      fmi.trbtr                   as betrag,
      //Gezahlt

      // AD = A, AK = E      
      case
        when bkpf.AccountingDocumentType = 'AD' then 'E'
        when bkpf.AccountingDocumentType = 'AK' then 'A'
        else ''
      end                         as belegart,      

      @Semantics.text: true
      @EndUserText.label: 'Summe Annahmeanordnung'
      @Semantics.amount.currencyCode : 'twaer'
      case
        when bkpf.AccountingDocumentType = 'AD' then fmi.trbtr
        else cast( 0 as abap.curr(22,2) )
      end                         as aodebitor,
      @Semantics.text: true
      @EndUserText.label: 'Summe Auszahlungsanordnung'
      @Semantics.amount.currencyCode : 'twaer'
      case
        when bkpf.AccountingDocumentType = 'AK' then fmi.trbtr
        else cast( 0 as abap.curr(22,2) )
      end                         as aokreditor
}
where
(
       bkpf.AccountingDocumentType = 'AD'
    or bkpf.AccountingDocumentType = 'AK'
  )

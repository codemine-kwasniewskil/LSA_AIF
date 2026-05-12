@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'IBAN vom AUBL'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /THKR/CDS_AIF_IST_RM_IBAN
  as select from bkpf
  association [0..1] to febep as _febep on   _febep.kukey = $projection.kukey
                                        and  _febep.esnum = $projection.esnum
{
  key bukrs,
  key belnr,
  key gjahr,
      substring(bktxt,1,8) as kukey,
      substring(bktxt,9,5) as esnum,
      _febep
}

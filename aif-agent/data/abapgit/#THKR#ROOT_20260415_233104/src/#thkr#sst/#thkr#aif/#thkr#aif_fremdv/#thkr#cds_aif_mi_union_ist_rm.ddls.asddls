@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Union der Multiindextabellen für IST-Rückmeldung'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /THKR/CDS_AIF_MI_UNION_IST_RM
  as select from /thkr/mi_0004002
{
  key 'EMSA' as SstKey,
  key kassz,
  key belnr,
  key bukrs,
  key lotkz,
  key gjahr,
      waers,
      @Semantics.amount.currencyCode : 'waers'
      gezahlt
}
union select from /thkr/mi_0006002
{
  key    'ESTA' as SstKey,
  key    kassz,
  key    belnr,
  key    bukrs,
  key    lotkz,
  key    gjahr,
         waers,
         gezahlt
}
union select from /thkr/mi_0012002
{
  key   'ELVS' as SstKey,
  key   kassz,
  key   belnr,
  key   bukrs,
  key   lotkz,
  key   gjahr,
        waers,
        gezahlt
}
union select from /thkr/mi_0024002
{
  key   'BHOÜ' as SstKey,
  key   kassz,
  key   belnr,
  key   bukrs,
  key   lotkz,
  key   gjahr,
        waers,
        gezahlt
}
union select from /thkr/mi_0026002
{
  key    'KMER' as SstKey,
  key    kassz,
  key    belnr,
  key    bukrs,
  key    lotkz,
  key    gjahr,
         waers,
         gezahlt
}
union select from /thkr/mi_0027002
{
  key    'KLRP' as SstKey,
  key    kassz,
  key    belnr,
  key    bukrs,
  key    lotkz,
  key    gjahr,
         waers,
         gezahlt
}
union select from /thkr/mi_0030002
{
  key    'BIBK' as SstKey,
  key    kassz,
  key    belnr,
  key    bukrs,
  key    lotkz,
  key    gjahr,
         waers,
         gezahlt
}
union select from /thkr/mi_0031002
{
  key 'SHLÄ' as SstKey,
  key kassz,
  key belnr,
  key bukrs,
  key lotkz,
  key gjahr,
      waers,
      gezahlt
}
union select from /thkr/mi_0037002
{
  key 'SKNW' as SstKey,
  key kassz,
  key belnr,
  key bukrs,
  key lotkz,
  key gjahr,
      waers,
      gezahlt
}
union select from /thkr/mi_0038002
{
  key 'ECDA' as SstKey,
  key kassz,
  key belnr,
  key bukrs,
  key lotkz,
  key gjahr,
      waers,
      gezahlt
}
union select from /thkr/mi_0039002
{
  key 'AFBG' as SstKey,
  key kassz,
  key belnr,
  key bukrs,
  key lotkz,
  key gjahr,
      waers,
      gezahlt
}
union select from /thkr/mi_0013003
{
  key 'EDOA' as SstKey,
  key kassz,
  key belnr,
  key bukrs,
  key lotkz,
  key gjahr,
      waers,
      gezahlt
}

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Abfrage Deckungsgruppen'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /THKR/BCS_CVGRP_DESC as select from fmbasobjnr as fmbobj
    join fmcecgaddrs as _Rel on fmbobj.objnr = _Rel.addrobjnr
    join fmcecvgrp as _CvGrp on _Rel.cvrgrp = _CvGrp.cvrgrp
                             and _Rel.budcat = _CvGrp.budcat 
    inner join fmcecvgrpt as _CvGrpText on _CvGrp.cvrgrp = _CvGrpText.cvrgrp
                                       and _CvGrp.budcat = _CvGrpText.budcat
                                       and        'D' = _CvGrpText.langu
//    association [ 0..* ] to fmcecgaddrs as _Rel on  fmbobj.objnr = _Rel.addrobjnr
//    join fmcecvgrp as _CvGrp on $projection.CvGrp = _CvGrp.cvrgrp
//                                               and $projection.BudgetCat = _CvGrp.budcat 
{   
   key fmbobj.fund,
   key fmbobj.fundsctr,
   key fmbobj.cmmtitem,
   key fmbobj.objnr,
   _Rel.budcat as BudgetCat,
   _Rel.cvrgrp as CvGrp,  
   _CvGrp.cgautoind as CvGrpType,
   _CvGrp.fiscyear as FiscYear,
   case 
    when _CvGrp.cgautoind = 'A' then _CvGrp.aldnr
    when _CvGrp.cgautoind = 'M' then _CvGrp.budcat
    when _CvGrp.cgautoind = 'R' then _CvGrp.rbbldnr
   end as target_ledger,
 
   _CvGrpText.text
   
}

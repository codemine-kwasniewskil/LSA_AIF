@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Business Partner Search'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /thkr/bpcube
  as select from I_BusinessPartner as bp
  //association [1] to kn1 as _Debitor on $projection.
  association [1..*] to I_BuPaIdentification    as _IdNum    on  $projection.BPID = _IdNum.BusinessPartner
  association [1..*] to I_BusinessPartnerBank_2 as _Bank     on  $projection.BPID = _Bank.BusinessPartner
  association [0..*] to I_CustomerCompany       as _CustComp on  $projection.BPID = _CustComp.Customer
                                                             and 'X'              = _CustComp.PhysicalInventoryBlockInd
  association [0..1] to I_Customer              as _Cust     on  $projection.BPID = _Cust.Customer
  association [0..*] to I_SupplierCompany       as _SuppComp on  $projection.BPID = _SuppComp.Supplier
                                                             and 'X'              = _SuppComp.SupplierIsBlockedForPosting
  association [0..1] to I_Supplier              as _Supp     on  $projection.BPID = _Supp.Supplier
{
  key bp.BusinessPartner                                                                           as BPID,
  key bp.BusinessPartnerName                                                                       as BPName,
      bp.BusinessPartnerGrouping                                                                   as BPGroup,
      bp.BusinessPartnerType                                                                       as BPType,
      bp.IsMarkedForArchiving                                                                      as Archivvormerkung,
      // Concat Address:
      case
        when bp._DefaultAddress._Address.HouseNumber is null
            then  concat_with_space( concat_with_space( bp._DefaultAddress._Address.StreetName, bp._DefaultAddress._Address.PostalCode,1  )
                                    , bp._DefaultAddress._Address.CityName,1  )
        else
             concat_with_space( concat_with_space( concat_with_space( bp._DefaultAddress._Address.StreetName, bp._DefaultAddress._Address.HouseNumber, 1 )
                                    ,  bp._DefaultAddress._Address.PostalCode,1  )
                                          , bp._DefaultAddress._Address.CityName,1  )
      end                                                                                          as BPAddress,
      bp._DefaultAddress._Address._Country._Text[1: Language=$session.system_language].CountryName as BPCountry,
      bp._DefaultAddress._Address._Country.Country                                                 as BPCountryCode,
      //    concat_with_space( $projection.address, bp._DefaultAddress._Address._Country._Text[1: Language=$session.system_language].CountryName,1 ) as address_full,
      bp._DefaultAddress._Address.StreetName                                                       as Street,
      bp._DefaultAddress._Address.HouseNumber                                                      as HNum,
      bp._DefaultAddress._Address.PostalCode                                                       as PLZ,
      bp._DefaultAddress._Address.CityName                                                         as City,

      _IdNum.BPIdentificationType                                                                  as ID_Type,
      _IdNum.BPIdentificationNumber                                                                as ID_Num,
      case
             when _Bank.IBAN is not null then _Bank.IBAN
             else concat_with_space( _Bank.BankNumber,_Bank.BankAccount,1  )
      end                                                                                          as Bank,
      _Bank.IBAN                                                                                   as Iban,
      _Bank.SWIFTCode                                                                              as BIC,
      _Bank.BankName                                                                               as BankName,
      bp.BPBusinessArea                                                                            as BusinessArea,
      bp.BPInterface                                                                               as BPInterface,

      case
            when _Cust.PostingIsBlocked = 'X' or _Supp.PostingIsBlocked  = 'X' then 'X'
            else ''
      end                                                                                          as BlockedAll,
      _Cust.PostingIsBlocked                                                                       as CustBlockedAll,
      _CustComp.CompanyCode                                                                        as CustBlockedCompanyCode,
      _SuppComp.CompanyCode                                                                        as SuppBlockedCompanyCode,
      _Supp.PostingIsBlocked                                                                       as SuppBlockedAll
}

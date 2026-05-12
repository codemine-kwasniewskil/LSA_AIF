@AbapCatalog.sqlViewAppendName: '/THKR/EXTIACCDO'
@EndUserText.label: 'Extention for I_ACCOUNTINGDOCUMENT'
extend view I_AccountingDocument with /THKR/EXT_I_AccountingDocument
{
  bkpf.psoty,
  length(bkpf.bktxt) as bktxt_length,

  case length(bkpf.bktxt)
      when 13
          then cast(substring(bkpf.bktxt, 1, 8) as kukey_eb)
      else
          ''
  end                as kukey,
  case length(bktxt)
      when 13
          then cast(substring(bkpf.bktxt, 9, 5) as esnum_eb)
      else
          ''
  end                as esnum,
  bkpf.lotkz,
  bkpf.psofn,
  bkpf.monat,
  bkpf.xblnr,
  bkpf.psobt
}

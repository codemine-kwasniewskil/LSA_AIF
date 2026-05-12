@AbapCatalog.sqlViewAppendName: '/THKR/EXTIBP'
@EndUserText.label: 'Extension I_BusinessPartner'
extend view I_BusinessPartner with /thkr/ext_I_BusinessPartner
{
  but000./thkr/gsber as BPBusinessArea,
  but000./thkr/sst   as BPInterface
}

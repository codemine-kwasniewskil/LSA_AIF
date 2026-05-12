FUNCTION /thkr/_bupa_bupa_event_isdat.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------

*------------------------------Local Data------------------------------*
  DATA: ls_but000    TYPE but000,
        ls_bus_istat TYPE bus_istat,
        lt_bpidt_db  TYPE bpidt_storettype WITH HEADER LINE.
*-------------------------------Function Body--------------------------*

*-------------------------Global DAta for IDtypnumber------------------*
  gs_current_control-aktyp    = gv_aktyp.
  gs_current_control-xsave    = gv_xsave.
  gs_current_control-xinit    = gv_xinit.
  gs_current_control-xupdtask = gv_xupdtask.
  gs_current_control-xdinp    = gv_xdinp.
*----------get the planed change date from the central application-----*
  CALL FUNCTION 'BUP_BUPA_BUT000_GET'
    IMPORTING
      e_but000      = ls_but000
      e_but000_stat = ls_bus_istat.

  gs_current_control-valdt = ls_bus_istat-valdt.
  g_current_partner       = ls_but000-partner.
  g_current_type          = ls_but000-type.
  gv_partner = ls_but000-partner.
  ll_but000  = ls_but000.

  /thkr/s_inc1_but-/THKR/gsber = ls_but000-/THKR/gsber.
  gv_zzgsber                = ls_but000-/THKR/gsber.
  gv_gsberold              = ls_but000-/THKR/gsber.

  /thkr/s_inc1_but-/thkr/sst = ls_but000-/thkr/sst.
  gv_zzsst = ls_but000-/thkr/sst.




ENDFUNCTION.

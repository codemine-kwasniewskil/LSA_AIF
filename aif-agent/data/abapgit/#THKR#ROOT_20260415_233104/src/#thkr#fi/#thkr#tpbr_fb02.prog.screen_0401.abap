PROCESS BEFORE OUTPUT.

  MODULE init_ok.
  MODULE set_pf_status.
  MODULE debitor_lesen.
*
PROCESS AFTER INPUT.

  MODULE leave_100 AT EXIT-COMMAND.
  MODULE get_changes.
  MODULE check_changes_d.

  FIELD ok-code MODULE ok_verarb.

PROCESS ON VALUE-REQUEST.
  FIELD bseg-zterm MODULE f4_zterm.
  FIELD bseg-bvtyp MODULE f4_bvtyp.

PROCESS BEFORE OUTPUT.

  MODULE init_ok.
  MODULE set_pf_status.
  MODULE Kreditor_lesen.
*
PROCESS AFTER INPUT.


  FIELD bseg-bvtyp MODULE check_bvtyp.
  MODULE get_changes.
  MODULE check_changes_k.

  FIELD ok-code MODULE ok_verarb.


PROCESS ON VALUE-REQUEST.

  FIELD bseg-bvtyp MODULE f4_bvtyp.

PROCESS BEFORE OUTPUT.

  MODULE init_ok.
  MODULE set_pf_status.
  MODULE texte_lesen.
*
PROCESS AFTER INPUT.

  MODULE get_changes.
  MODULE check_changes_ausgegl.
  FIELD ok-code MODULE ok_verarb_ausgegl.

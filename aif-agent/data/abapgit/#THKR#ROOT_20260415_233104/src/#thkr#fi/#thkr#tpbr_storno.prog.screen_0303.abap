PROCESS BEFORE OUTPUT.

  MODULE set_pf_status_bearb.
  MODULE set_title_fi.
  MODULE init_ok.
*
PROCESS AFTER INPUT.

  MODULE leave at EXIT-COMMAND.

  FIELD ok-code MODULE okcod_verarbeitung.

PROCESS BEFORE OUTPUT.

  MODULE init_ok.
    MODULE set_pf_status.
      MODULE debitor_lesen.
        MODULE Mahnstufe.
*
PROCESS AFTER INPUT.

MODULE leave_100 AT EXIT-COMMAND.
  MODULE get_changes.
  MODULE check_changes_d_lok.

    FIELD ok-code MODULE ok_verarb.

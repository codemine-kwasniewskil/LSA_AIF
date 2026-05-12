"Name: \PR:RSEPALIST\FO:DISPLAY_RESULT\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/FI_SEPA_MANDATE_LIST_OD.
"Durch  Änderungen über die FSEPA_M4 können Probleme mit der Freigabe im Workflow auftreten.
"Deshalb wird die Änderung für alle Benutzer, die kein NFU sind, deaktiviert.
IF sy-tcode = 'FSEPA_M4' AND sy-uname NP 'NFU*'.

  IF gx_change_mode_justified = 'X'.
    CLEAR gx_change_mode_justified.
  ENDIF.

ENDIF.

ENDENHANCEMENT.

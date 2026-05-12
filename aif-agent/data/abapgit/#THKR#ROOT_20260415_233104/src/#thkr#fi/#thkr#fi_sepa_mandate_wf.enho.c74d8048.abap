"Name: \PR:SAPLSEPA_MANDATE_UI\FO:DYNPRO_MODIF\SE:END\EI
ENHANCEMENT 0 /THKR/FI_SEPA_MANDATE_WF.
"Beim Anlegen darf das Feld Status nicht eingabebereit sein.
"Außerdem wird der Status mit dem Wert "Zu bestätigen" befüllt.
  IF sy-uname(3) <> 'NFU'.
IF tstat-aktyp = '01'.

  LOOP AT SCREEN.
    IF screen-name = 'RFSEPA_WA-STATUS'.
      screen-input = 0.
      rfsepa_wa-status = '2'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ELSEIF tstat-aktyp = '02'.
  IF rfsepa_wa-glock IS NOT INITIAL and rfsepa_wa-status = '2'.

    LOOP AT SCREEN.
      IF screen-name = 'RFSEPA_WA-STATUS'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.
ENDIF.
ENDIF.
ENDENHANCEMENT.

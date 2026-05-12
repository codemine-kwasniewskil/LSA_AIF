"Name: \PR:SAPLFACS\FO:LOCK_CHECK\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/KASSE_NO_LOCK_CHECK.
"Deaktivierung Prüfung auf Buchungssperre für Kassenbenutzer, damit Mahnlauf dürchgeführt werden kann, falls BP gesperrt.
"Ausnahme für Kasse im Mahndruck
  IF sy-uname = '9999-KASSE' AND sy-cprog = 'SAPF150D2'.
    RETURN.
  ENDIF.
ENDENHANCEMENT.

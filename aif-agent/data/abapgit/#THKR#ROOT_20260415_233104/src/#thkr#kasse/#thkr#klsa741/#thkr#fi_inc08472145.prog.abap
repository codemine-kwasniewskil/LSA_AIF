*&---------------------------------------------------------------------*
*& Report /THKR/FI_INC08472145
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/fi_inc08472145 LINE-SIZE 80.

************************************************************************
* ELKO: Hilfprogramm zum Anpassen des Bündelungsart auf "0"
************************************************************************
* Beschreibung:
* Die Bündelungsart musste auf "0" geändert werden, damit bei FEBAN
* die Bündelungsnummer nicht sporadisch basierend auf ESNUM neu vergeben
* wird (einmalige Aktion im Rahmen INC08472145)


START-OF-SELECTION.

  UPDATE febip SET  bdart = space
   WHERE bdart = '2'.

  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.

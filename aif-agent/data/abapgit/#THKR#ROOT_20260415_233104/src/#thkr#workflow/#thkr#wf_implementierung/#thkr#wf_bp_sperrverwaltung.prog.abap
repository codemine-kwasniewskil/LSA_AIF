*&---------------------------------------------------------------------*
*& Report /THKR/WF_BP_SPERRVERWALTUNG
*&---------------------------------------------------------------------*
*& Dieser Report dient zum Korrigieren von Sperrflags von Geschäftspartnern
*&
*& Ersteller: ZHM000000038 - Andreas Baier
*&---------------------------------------------------------------------*
REPORT /thkr/wf_bp_sperrverwaltung.

INCLUDE /thkr/WF_BP_SPERRVERW_top.

LOAD-OF-PROGRAM.

  AUTHORITY-CHECK OBJECT 'S_TCODE'
   ID 'TCD' FIELD '/THKR/WF_BP_SPERRE'.
  IF sy-subrc <> 0.
    MESSAGE 'Keine Berechtigung für Transaktion /THKR/WF_BP_SPERRE.' TYPE 'E' DISPLAY LIKE 'S'.
  ENDIF.

START-OF-SELECTION.

  IF so_bp IS INITIAL.

    MESSAGE 'Bitte wählen Sie mindestens einen Geschäftspartner aus!' TYPE 'S' DISPLAY LIKE 'E'.
    gv_fehler = 'X'.
  ENDIF.

  IF pa_gp IS INITIAL AND pa_debi IS INITIAL
    AND pa_kred IS INITIAL.

    MESSAGE 'Bitte wählen Sie mindestens eine Geschätspartnerart aus!' TYPE 'S' DISPLAY LIKE 'E'.
    gv_fehler = 'X'.

  ENDIF.


  PERFORM get_bp.

  IF gv_fehler IS INITIAL.

    PERFORM process.

    PERFORM show_log.

  ENDIF.

  PERFORM clear.


  INCLUDE /thkr/WF_BP_SPERRVERW_f01.

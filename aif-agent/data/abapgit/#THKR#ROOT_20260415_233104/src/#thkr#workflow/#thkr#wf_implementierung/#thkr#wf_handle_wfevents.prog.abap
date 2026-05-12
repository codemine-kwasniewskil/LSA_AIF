*&---------------------------------------------------------------------*
*& Report /THKR/WF_HANDLE_WFEVENTS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*_______________________________________________________________________
* Funktion:
* Anhand des Selektionsparameters werden die relevanten Ereigniskopplungen
* aus der Datenbank gelesen. Man kann dann diese de-/aktivieren und das
* wird dann auf die Datenbank zurÃ¼ck geschrieben.
*_______________________________________________________________________
* Hinweise:
* Diese Report darf nur von bestimmten NFU Usern ausgefÃ¼hrt werden
*_______________________________________________________________________
* Erstellt:
* 26.01.2024  REPRO-GANZ  Thorsten Ganzer
*_______________________________________________________________________
* Ã„nderungen:
* #001
*_______________________________________________________________________

REPORT /THKR/WF_HANDLE_WFEVENTS MESSAGE-ID /THKR/WF.

" spezielle Feld-Symbole für Änderungszeiger
FIELD-SYMBOLS: <lv_feld> TYPE any,                          "#EC NEEDED
               <lt_itab> TYPE table.                        "#EC NEEDED

INCLUDE /thkr/wf_handle_wfevents_lcl.
" Datendefinition
INCLUDE /thkr/wf_handle_wfevents_top.

" Selektionsbild
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-b01.
  PARAMETERS: p_objtyp TYPE sibftypeid OBLIGATORY MATCHCODE OBJECT z_wf_swf_object.
SELECTION-SCREEN END OF BLOCK bl1.

*** Bei der Ausgabe des Selektionsbildes
INITIALIZATION.

  " Transaktion Berechtigungsprüfung
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD' FIELD gc_tcode.
  IF sy-subrc <> 0.
    MESSAGE e172(00) WITH gc_tcode.
  ENDIF.

*** Start-of-Selection
START-OF-SELECTION.

  " Lesen der Events zum Objekt
  SELECT * INTO TABLE @DATA(gt_events) FROM swfdvevtyp WHERE objtype = @p_objtyp.
  IF sy-subrc <> 0.
    MESSAGE s107 WITH p_objtyp DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " Aufbau Zeiger fÃ¼r Ã„nderungen im alv
  TRY.
      " Erzeugung der Datenstrukturen zur laufzeit
      CREATE DATA go_ref TYPE STANDARD TABLE OF swfdvevtyp.
      ASSIGN go_ref->* TO <lt_itab>.

      " Ãœbergabe der daten
      APPEND LINES OF gt_events TO <lt_itab>.

      " Fehler abfangen
    CATCH cx_sy_create_data_error.
  ENDTRY.

  " Ausgabe der relevanten events
  CALL SCREEN 0100.


** Includes
  INCLUDE /thkr/wf_handle_wfevents_o01.

  INCLUDE /thkr/wf_handle_wfevents_i01.

  INCLUDE /thkr/wf_handle_wfevents_f01.

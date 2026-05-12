*&---------------------------------------------------------------------*
*& Report /THKR/CHK_MIG_DUBLETTE_EGP                                   *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Beschreibung:                                                       *
*& Prüfung von Z001 - Einmal-GP zur Archivierung                       *
*&    - Offene Posten                                                  *
*&    - Anordnungen                                                    *
*&                                                                     *
*& Prüfung von Z009 - MIG-Einmal-GP und Dubletten                      *
*&    - Offene Posten                                                  *
*&    - Allg. Anordnungen                                              *
*&    - Daueranordnungen                                               *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:        Frank Brähler (Orexes GmbH)                           *
*& Datum:        25.02.2026                                            *
*&                                                                     *
*& l. Änderung:  13.04.2026                                            *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT /thkr/chk_mig_dublette_egp.

************************************************************************
* TOP - Include - Deklarationen                                        *
************************************************************************
INCLUDE /thkr/chk_mig_dublette_egp_top.

************************************************************************
* SCR - Include - Deklarationen                                        *
************************************************************************
INCLUDE /thkr/chk_mig_dublette_egp_scr.

************************************************************************
* FRM - Include - Formroutinen                                         *
************************************************************************
INCLUDE /thkr/chk_mig_dublette_egp_frm.

************************************************************************
* Start der Programmverarbeitung                                       *
************************************************************************
START-OF-SELECTION.
  PERFORM load_but.             "Daten zur Prüfung laden
  PERFORM check_dauer_belege.   "Prüfung auf Dauer-Anordnungen

END-OF-SELECTION.

************************************************************************
* Ausgabe für Write / Message setzen                                   *
************************************************************************
  IF p_test IS INITIAL.
    MOVE TEXT-prd TO gv_tstmsg.
  ELSE.
    MOVE TEXT-tst TO gv_tstmsg.
  ENDIF.

************************************************************************
* Bei Dialog ausgabe Begrenzung auf die ersten 3.000 Datensätze        *
************************************************************************
  IF sy-batch IS INITIAL.
    gv_maxsel = p_max.
  ELSE.
    CLEAR gv_maxsel.
  ENDIF.


  LOOP AT gt_dbbut INTO gs_dbbut.
************************************************************************
*   Wenn kein Test-KZ gesetzt ist, dann Update der Daten aus gt_dbbut  *
*   setzen des ARCHIV - Kennzeichen                                    *
************************************************************************
    IF p_test IS INITIAL.
      PERFORM set_xdele USING gs_dbbut.
    ENDIF.
    IF sy-batch IS INITIAL.
      WRITE: /5 gs_dbbut-partner,
                gc_tren,
                gs_dbbut-bpkind,
                gc_tren,
                gs_dbbut-bpext,
                gc_tren,
                gs_dbbut-/thkr/gsber,
                gc_tren,
                gs_dbbut-/thkr/sst,
                gc_tren,
                gs_dbbut-name_last,
                gc_tren,
                gs_dbbut-name_first,
                gc_tren,
                gv_tstmsg.
    ELSE.
      CONCATENATE gs_dbbut-partner     gc_tren
                  gs_dbbut-bpkind      gc_tren
                  gs_dbbut-bpext       gc_tren
                  gs_dbbut-/thkr/gsber gc_tren
                  gs_dbbut-/thkr/sst   gc_tren
                  gs_dbbut-name_last   gc_tren
                  gs_dbbut-name_first  gc_tren
                  gv_tstmsg
                INTO gv_string RESPECTING BLANKS.
      MESSAGE gv_string TYPE 'S'.
    ENDIF.
  ENDLOOP.

************************************************************************
* Initialisierung                                                      *
************************************************************************
INITIALIZATION.
  b1_titel = TEXT-t01.
  b2_titel = TEXT-t02.
  b3_titel = TEXT-t03.

  gs_sblart-sign   = 'I'.
  gs_sblart-option = 'EQ'.

  gs_sblart-low    = 'A0'.
  APPEND gs_sblart TO so_blart.

  gs_sblart-low    = 'A1'.
  APPEND gs_sblart TO so_blart.

  gs_sblart-low    = 'AN'.
  APPEND gs_sblart TO so_blart.

  gs_sblart-low    = 'AU'.
  APPEND gs_sblart TO so_blart.

  gs_sblart-low    = 'V0'.
  APPEND gs_sblart TO so_blart.

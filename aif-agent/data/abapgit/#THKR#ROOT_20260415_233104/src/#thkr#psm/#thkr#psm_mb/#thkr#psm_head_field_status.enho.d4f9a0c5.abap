"Name: \PR:SAPLFMFR\FO:SET_FIELD_STATUS_HEAD\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/PSM_HEAD_FIELD_STATUS.
"Wenn Erledigtkennzeichen auf Kopfebene gesetzt, dann darf das Feld nicht mehr geändert werden dürfen.
IF sy-TCODE = 'FMZ2' OR SY-TCODE = 'FMV2'.
  IF ( kbld-blart = 'AU' OR kbld-blart = 'AN'
     OR kbld-blart = 'MB' ).
  """"""
* Wenn das Feld schon in der Tabelle ist -> raus
  LOOP AT g_t_tablefields WHERE name = c_screen-name
                          OR name = c_screen-name+1.
  ENDLOOP.
  CHECK sy-subrc NE 0.

* Feldauswahlleiste verarbeiten
  PERFORM convert_fldpr TABLES t_fldpr
                      CHANGING c_screen.

* Begin insert for SAudi Arabia localisation
* For DATE_TO, use field status settings of DATE_FROM
  IF c_screen-name EQ 'KBLD-DATE_TO'.
    READ TABLE t_fldpr WITH KEY fname = 'KBLD-DATE_FROM' BINARY SEARCH.
    IF sy-subrc EQ 0.
      PERFORM set_field USING t_fldpr-kennz CHANGING c_screen.
    ENDIF.
  ENDIF.
* End insert for SAudi Arabia localisation

* Wenn das Erledigtkennzeichen auf Kopfebene gesetzt ist, werden die
* Kopfdaten nur angezeigt.
  IF kbld-fexec = con_true.
*     c_screen-name <> 'KBLD-FEXEC' AND
*     c_screen-name <> 'KBLD-KTEXT'.
    PERFORM set_field USING '*' CHANGING c_screen.
  ENDIF.

* Hauswährungsfelder
  IF kbld-hwaer = kbld-waers.          "/ Beleg in Hauswährung
    IF  c_screen-group2 = 'CUR'.
      PERFORM set_field USING '-' CHANGING c_screen.
    ENDIF.
  ENDIF.

* Budgetadresse ändern
  IF status2 = st2_cbud AND
     c_screen-group2 NE 'BUD'.
    PERFORM set_field USING '*' CHANGING c_screen.
  ENDIF.

* Beim Anlegen ist das Erledigtkennzeichen inaktiv
  IF status2 = st2_anl AND
       c_screen-name = 'KBLD-FEXEC'.
    c_screen-input = off.
  ENDIF.

* In Abbautransaktion werden die Kopfdaten nur angezeigt
  IF status2 = st2_cons.
    PERFORM set_field USING '*' CHANGING c_screen.
  ENDIF.

* Sonderbehandlung REDY-Felder
  IF c_screen-name CS 'REDY-'.
    REPLACE 'REDY-' WITH 'KBLD-' INTO c_screen-name.
    PERFORM convert_fldpr TABLES t_fldpr
                        CHANGING c_screen.
    REPLACE 'KBLD-' WITH 'REDY-' INTO c_screen-name.
  ENDIF.

* Budgetflags
  PERFORM screen_budget_flags USING    f_kblk
                              CHANGING c_screen.

*---------------------------------------------------------------------
* Belegtypen
  CHECK kbld-bltyp NE bty_mittel.      "/ 3.0 Mittelreserv.

*  Mittelsperre
  IF kbld-bltyp = bty_block AND
     ( c_screen-name CS 'KBLD-BLKKZ'
* -------------------------------------------------------
*   ESFM Development: Invoice verification as separated consumption
*                     Hide INV_CONS in blocking transactions
    OR  c_screen-name = 'KBLD-INV_CONS').
*   ESFM Develoment: End of modification
* -------------------------------------------------------
    PERFORM set_field USING '-' CHANGING c_screen.
  ENDIF.

* Umbuchung
  IF kbld-bltyp = bty_zahlung.
    IF c_screen-group3 = 'RES' OR
       c_screen-group3 = 'PRE' OR
       c_screen-group3 = 'UMB'.
      PERFORM set_field USING '-' CHANGING c_screen.
    ENDIF.
  ENDIF.

* Anzeigetransaktion
* Felder nicht eingabebereit, falls Anzeigetransaktion oder Genehmigen
  IF  status2 = st2_anz OR status2 = st2_app.
    PERFORM set_field USING '*' CHANGING c_screen.
  ENDIF.

* Workflow-Flag aus Belegartentabelle auswerten
  IF save_wf_start IS INITIAL.
    IF  c_screen-group1 = 'WFF'.       "/ Felder nur bei Workflow
      PERFORM set_field USING '-' CHANGING c_screen.
    ENDIF.
  ENDIF.

* Entscheidunggrund
  IF  c_screen-name = 'KBLD-FMREASON'
  AND NOT save_wf_start IS INITIAL
  AND status2     NE st2_anz
  AND status2     NE st2_app.
    IF  sy-binpt    = con_on.
      c_screen-input = on.
    ELSE.
      c_screen-input = off.
    ENDIF.
  ENDIF.

* Kostenrechnungskreisfelder ausblenden, wenn kein KOKRS
  IF kbld-kokrs IS INITIAL.
    IF c_screen-group2 = 'KOK'.
      PERFORM set_field USING '-' CHANGING c_screen.
    ENDIF.
  ENDIF.

* Finanzkreisfelder ausblenden, wenn kein FIKRS
  IF kbld-fikrs IS INITIAL.
    IF c_screen-group2 = 'FIK'.
      PERFORM set_field USING '-' CHANGING c_screen.
    ENDIF.
  ENDIF.

* Bei Vorerfassung kann das Buchungsdatum noch geändert werden
  IF f_kblk-mvstat = con_mvstat_prelim AND
     c_screen-name = 'KBLD-BUDAT' AND
     c_screen-active = on.
    IF status2 = st2_anl OR
       status2 = st2_aend.
      c_screen-input = on.
    ENDIF.
  ENDIF.

* folgende felder sind immer eingabebereit (Muß am Schluß stehen)
  IF c_screen-name = 'REDY-POSPOS'.
    c_screen-input = on.
  ENDIF.
  """""""
  RETURN.
  ENDIF.
  ENDIF.
ENDENHANCEMENT.

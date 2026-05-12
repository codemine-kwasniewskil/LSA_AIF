FUNCTION /thkr/feb_kontierng_allgao_902 .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_AUGLV)
*"     VALUE(I_FEBEP) LIKE  FEBEP STRUCTURE  FEBEP
*"     VALUE(I_FEBKO) LIKE  FEBKO STRUCTURE  FEBKO
*"     VALUE(I_AREA) TYPE  T033F-EIGR2
*"  TABLES
*"      T_FEBCL STRUCTURE  FEBCL
*"      T_FEBRE STRUCTURE  FEBRE
*"      T_FTCLEAR STRUCTURE  FTCLEAR
*"      T_FTPOST STRUCTURE  FTPOST
*"      T_FTTAX STRUCTURE  FTTAX
*"----------------------------------------------------------------------

* Nur für Anzahlungen mit Referenz auf eine allg.AO (MV)
* Kontierungen werden aus der Mittelvormerkung Position 1 gezogen
* Bei der Interpretation muss bereits eine MV ermittelt worden sein
* die Belegnummer der MVsteht auf FEBEP-FNAM1 und FEBEP_FVAL1
* Für buchungskreisübergreifende Belege muss der Buchungskreis auf den
* Buchungskreis der MV gesetzt werden, in der SK-Zeile bleibt BUKRS = 7000
*
* Falls keine Mittelvormerkung ermittelt werden konnte, wird T_FTPOST geleert.
* Das führt zum Fehler bei der Buchung und es wird keine Anzahlung erzeugt.


*--- Datendefintionen für Zusatzkontierungen
  DATA: lv_t033f TYPE t033f,
        lv_count TYPE ftpost-count.               " Buchungszeile

  DATA: lv_ftpost    TYPE ftpost,
        lv_tabix     TYPE sy-tabix,
        lv_tabix_bk  TYPE sy-tabix,
        l_kblnr      TYPE kblnr,
        l_xblnr      TYPE xblnr1,
        l_bukrs      TYPE bukrs,
        l_bukrs_orig TYPE bukrs,
        l_bschl      TYPE  bschl,
        l_koart      TYPE koart,
        l_change     TYPE xfeld.


  CHECK i_area = 2.  "nur für Buchungsbereich 2
  CHECK i_febep-intag = '902'.

*--- 1. Ermittlung der Buchungsart aus der Kontenfindung für Buchungsbereich 1 oder 2
  SELECT SINGLE * FROM t033f INTO lv_t033f  WHERE anwnd = '0001'
                                                AND eigr1 = i_febep-vgint
                                                AND eigr2 = i_area
                                                AND eigr3 = space
                                                AND eigr4 = space.

* Sonderhauptbuchkennzeichen für Anzahlung muss gefüllt sein
  CHECK lv_t033f-shbk1 IS NOT INITIAL OR lv_t033f-shbk2 IS NOT INITIAL.

* Feld für Referenz auf MV muss vorhanden sein
  READ TABLE t_ftpost ASSIGNING FIELD-SYMBOL(<po>)
                                WITH KEY stype = 'P'
                                         fnam  = 'BSEG-KBLNR'.
  IF sy-subrc <> 0.
    IF i_febep-fnam1 = 'BSEG-KBLNR' AND i_febep-fnam2 = 'BSEG-KBLPOS'.
      l_kblnr = i_febep-fval1.
    ENDIF.
  ELSE.
    l_kblnr = <po>-fval.
    lv_count = <po>-count.
  ENDIF.

  IF l_kblnr IS NOT INITIAL.
*   AllgAO für den Buchungskreis lesen
    SELECT SINGLE bukrs xblnr FROM kblk INTO ( l_bukrs, l_xblnr ) WHERE belnr = l_kblnr.
    IF sy-subrc <> 0.
*      l_bukrs = l_buk.
*    "Fehler beim Buchen provozieren
      CLEAR t_ftpost.
      REFRESH t_ftpost.
      RETURN.
    ENDIF.
  ELSE.
    CLEAR t_ftpost.
    REFRESH t_ftpost.
    RETURN.
  ENDIF.


* Repro-Roc Referenz-hier wird das Feld Referenz aktualisiert
  LOOP AT t_ftpost ASSIGNING <po> WHERE fnam = 'BKPF-XBLNR'.
    <po>-fval = l_xblnr.
    EXIT.
  ENDLOOP.


* Repro-Roc 20200803 wird gebraucht, falls nicht V0
* kann auch gesetzt werden bei V0
  lv_tabix = 1.
  lv_ftpost-stype = 'K'.
  lv_ftpost-count = '001'.
  lv_ftpost-fnam = 'BKPF-XMWST'.     " Mehrwertsteuer rechnen
  lv_ftpost-fval = 'X'.
  INSERT lv_ftpost INTO t_ftpost INDEX lv_tabix.

* Repro-ROC
*Haben wir 2 Buchungskreise?
  CLEAR l_change.
  READ TABLE t_ftpost WITH KEY stype = 'K'
                               count = '001'
                               fnam  = 'BKPF-BUKRS'
                               ASSIGNING <po>.
  IF <po>-fval <> l_bukrs.
    l_change = 'X'.
  ENDIF.

  IF l_change = 'X'.
* Buchungsschlüssel mit D oder K
    LOOP AT t_ftpost ASSIGNING <po> WHERE fnam = 'BSEG-BSCHL'.
      l_bschl = <po>-fval.
      SELECT SINGLE koart INTO l_koart FROM tbsl
        WHERE bschl = l_bschl.
      IF sy-subrc = 0 AND ( l_koart = gc_char_k OR l_koart = gc_char_d ).
        lv_count = <po>-count.
        EXIT.
      ENDIF.
    ENDLOOP.


* Buchungskreis für Belegbuchung ändern, wenn buchungskreisübergreifend
    LOOP AT t_ftpost ASSIGNING <po> WHERE fnam = 'BKPF-BUKRS'
                                     OR fnam = 'BSEG-BUKRS'.
*REPRO-ROC    IF <po>-fval = '7000' OR
      IF  <po>-fval <> l_bukrs.
        l_bukrs_orig =  <po>-fval.
        IF <po>-count = lv_count.  "REPRO-ROC
* nur Ändern, falls K oder D
* > (del) Reiner Gerdes: Buchungskreisübertragung unterbinden.
*          <po>-fval = l_bukrs.
* < (del) Reiner Gerdes: Buchungskreisübertragung unterbinden.

        ENDIF.
      ENDIF.
    ENDLOOP.


* Buchungskreisübergreifende Buchung: Buchungskreis 7000 in die SK-Zeile
* nach dem 2. Buchungsschlüssel - auf jeden Fall NEWBK füllen
    READ TABLE t_ftpost WITH KEY stype = 'P'
                                 count = '002'
                                 fnam  = 'BSEG-BSCHL'.
    lv_tabix_bk = sy-tabix + 1.

    lv_ftpost-stype = 'P'.
    lv_ftpost-count = '002'.
    lv_ftpost-fnam = 'RF05A-NEWBK'.     "'BSEG-BUKRS'.

    IF lv_count = '002'.
      lv_ftpost-fval = l_bukrs.
    ELSE.
      lv_ftpost-fval = l_bukrs_orig.
    ENDIF.
    INSERT lv_ftpost INTO t_ftpost INDEX lv_tabix_bk.
  ENDIF.

* Einfügeposition für Insert: vor dem Buchungsschlüssel der SK-Zeile,
* sonst anhängen
  IF lv_count = '001'.
    READ TABLE t_ftpost WITH KEY stype = 'P'
                                 count = '002'
                                 fnam  = 'BSEG-BSCHL'.
    lv_tabix = sy-tabix.
  ENDIF.

  lv_ftpost-stype = 'P'.
  lv_ftpost-count = lv_count.

* Referenzfelder auf allg.AO hinzufügen, falls nicht vorhanden
* BSEG-KBLNR - Belegnummer MV
  READ TABLE t_ftpost ASSIGNING <po> WITH KEY stype = 'P' count = lv_count
                                              fnam  = 'BSEG-KBLNR'.
  IF sy-subrc <> 0.
    lv_ftpost-fnam = 'BSEG-KBLNR'.
    lv_ftpost-fval = l_kblnr.
    IF lv_count = '001'.
      INSERT lv_ftpost INTO t_ftpost INDEX lv_tabix.
      ADD 1 TO lv_tabix.
    ELSE.
      APPEND lv_ftpost TO t_ftpost.
    ENDIF.
  ENDIF.

* BSEG-KBLPOS - Belegposition MV
  READ TABLE t_ftpost ASSIGNING <po> WITH KEY stype = 'P' count = lv_count
                                              fnam  = 'BSEG-KBLPOS'.
  IF sy-subrc <> 0.
    lv_ftpost-fnam = 'BSEG-KBLPOS'.
    lv_ftpost-fval = '001'.
    IF lv_count = '001'.
      INSERT lv_ftpost INTO t_ftpost INDEX lv_tabix.
      ADD 1 TO lv_tabix.
    ELSE.
      APPEND lv_ftpost TO t_ftpost.
    ENDIF.
  ENDIF.

* BSEG-MWSKZ - Steuerkennzeichen
  READ TABLE t_ftpost ASSIGNING <po> WITH KEY stype = 'P' count = lv_count
                                              fnam  = 'BSEG-MWSKZ'.
  IF sy-subrc <> 0.
*REPRO-ROC 20200617 falls bereits eingetragen, dann übernehmen
    IF i_febep-fnam3 = 'BSEG-MWSKZ'.
      lv_ftpost-fnam = 'BSEG-MWSKZ'.
      lv_ftpost-fval = i_febep-fval3.
* alte Lösung :
    ELSE.
      lv_ftpost-fnam = 'BSEG-MWSKZ'.
      lv_ftpost-fval = 'V0'.
    ENDIF.

    IF lv_count = '001'.
      INSERT lv_ftpost INTO t_ftpost INDEX lv_tabix.
      ADD 1 TO lv_tabix.
    ELSE.
      APPEND lv_ftpost TO t_ftpost.
    ENDIF.
  ENDIF.

* Alle Kontierungszeilen entfernen, falls vorhanden
  LOOP AT t_ftpost ASSIGNING <po> WHERE stype = 'P' AND fnam(5) = 'COBL-'.
    DELETE t_ftpost.
  ENDLOOP.

* > (ins) Reiner Gerdes: Sortierung der T_FTPOST und ergänzen
  IF sy-tcode EQ 'FF_5'
  OR sy-tcode EQ 'FF.5'
  OR sy-tcode EQ 'FEB_FILE_HANDLING'
  OR sy-tcode EQ 'SM37'
  OR sy-cprog EQ 'RFEBBU00'.
    CLEAR: lv_count, lv_ftpost, lv_tabix_bk.
    DATA lt_ftpost TYPE TABLE OF ftpost.
* Belegkopf füllen
    LOOP AT t_ftpost ASSIGNING FIELD-SYMBOL(<ls_post>)
         WHERE stype EQ 'K'.
      APPEND <ls_post> TO lt_ftpost.
      lv_count = '1'.
    ENDLOOP.
* Position 40 oder 50 vorziehen
    LOOP AT t_ftpost ASSIGNING <ls_post>
         WHERE stype EQ 'P'
         AND   count EQ '2'.
      CHECK <ls_post>-fnam NE 'RF05A-NEWBK'.
      DATA(ls_post) = <ls_post>.
      ls_post-count = lv_count.
      APPEND ls_post TO lt_ftpost.
    ENDLOOP.
* Position 40 oder 50 vorziehen
    LOOP AT t_ftpost ASSIGNING <ls_post>
         WHERE stype EQ 'P'
         AND   count EQ '1'
         AND   fval  NE 'RF05A-NEWBK'.
      CLEAR: ls_post.
      ls_post = <ls_post>.
      ls_post-count = '2'.
      APPEND ls_post TO lt_ftpost.
    ENDLOOP.
* Buchungskreis füllen
    LOOP AT t_ftpost ASSIGNING <ls_post>
       WHERE stype EQ 'P'
       AND   count EQ '2'
       AND   fnam  EQ 'BSEG-BSCHL'.
      lv_tabix_bk = sy-tabix + 1.

      lv_ftpost-stype = 'P'.
      lv_ftpost-count = '002'.
      lv_ftpost-fnam = 'RF05A-NEWBK'.     "'BSEG-BUKRS'.
      lv_ftpost-fval = l_bukrs.
      INSERT lv_ftpost INTO lt_ftpost INDEX lv_tabix_bk.
    ENDLOOP.

    CLEAR: t_ftpost.
    t_ftpost[] = lt_ftpost[].
    CLEAR: lt_ftpost.
  ENDIF.
* < (ins) Reiner Gerdes: Sortierung der T_FTPOST und ergänzen
ENDFUNCTION.

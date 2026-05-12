FUNCTION /thkr/feb_kontierng_allgao_901 .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_AUGLV)
*"     REFERENCE(I_FEBEP) LIKE  FEBEP STRUCTURE  FEBEP
*"     REFERENCE(I_FEBKO) LIKE  FEBKO STRUCTURE  FEBKO
*"     REFERENCE(I_AREA) TYPE  T033F-EIGR2
*"  TABLES
*"      T_FEBCL STRUCTURE  FEBCL
*"      T_FEBRE STRUCTURE  FEBRE
*"      T_FTCLEAR STRUCTURE  FTCLEAR
*"      T_FTPOST STRUCTURE  FTPOST
*"      T_FTTAX STRUCTURE  FTTAX
*"--------------------------------------------------------------------

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
  DATA: lv_t033f TYPE t033f.


  DATA: lv_ftpost   TYPE ftpost,
        lv_tabix_bk TYPE sy-tabix,
        l_kblnr     TYPE kblnr,
        l_bukrs     TYPE bukrs.

  CHECK i_area = 2.  "nur für Buchungsbereich 2
  CHECK i_febep-intag = '901'.

  CALL FUNCTION '/THKR/ELKO_CHECK_FTPOST'
    EXPORTING
      i_auglv                     = i_auglv
      i_febep                     = i_febep
      i_febko                     = i_febko
      i_area                      = i_area
* IMPORTING
*     E_RETURN                    =
    TABLES
      t_febcl                     = t_febcl
      t_febre                     = t_febre
      t_ftclear                   = t_ftclear
      t_ftpost                    = t_ftpost
      t_fttax                     = t_fttax.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

*--- 1. Ermittlung der Buchungsart aus der Kontenfindung für Buchungsbereich 1 oder 2
  SELECT SINGLE * FROM t033f INTO lv_t033f  WHERE anwnd = '0001'
                                                AND eigr1 = i_febep-vgint
                                                AND eigr2 = i_area
                                                AND eigr3 = space
                                                AND eigr4 = space.

* Sonderhauptbuchkennzeichen für Anzahlung muss gefüllt sein
  CHECK lv_t033f-shbk1 IS NOT INITIAL OR lv_t033f-shbk2 IS NOT INITIAL.

* Feld für Referenz auf MV muss vorhanden sein
  READ TABLE t_ftpost ASSIGNING FIELD-SYMBOL(<po>)       "#EC CI_STDSEQ
                                WITH KEY stype = 'P'
                                         fnam  = 'BSEG-KBLNR'.
  IF sy-subrc <> 0.
    IF i_febep-fnam1 = 'BSEG-KBLNR' AND i_febep-fnam2 = 'BSEG-KBLPOS'.
      l_kblnr = i_febep-fval1.
    ENDIF.
  ELSE.
    l_kblnr = <po>-fval.
  ENDIF.

  IF l_kblnr IS NOT INITIAL.
*   AllgAO für den Buchungskreis lesen
    SELECT SINGLE bukrs FROM kblk INTO l_bukrs WHERE belnr = l_kblnr.
    IF sy-subrc <> 0.
*      l_bukrs = l_buk.
*    "Fehler beim Buchen provozieren
      CLEAR t_ftpost.
      REFRESH t_ftpost.
      RETURN.
    ENDIF.
  ELSE.
*    l_bukrs = l_buk.
*    l_kblnr = '9999999999'.
*   "Fehler beim Buchen provozieren
    CLEAR t_ftpost.
    REFRESH t_ftpost.
    RETURN.
  ENDIF.

* Buchungskreisübergreifende Buchung: Buchungskreis 7000 in die SK-Zeile
  IF i_febko-bukrs = 'T999' AND l_bukrs <> 'T999'.

    READ TABLE t_ftpost WITH KEY stype = 'P'             "#EC CI_STDSEQ
                                 count = '002'
                                 fnam  = 'BSEG-BSCHL'.
    lv_tabix_bk = sy-tabix + 1.

    lv_ftpost-stype = 'P'.
    lv_ftpost-count = '002'.
    lv_ftpost-fnam = 'RF05A-NEWBK'.     "'BSEG-BUKRS'.
    lv_ftpost-fval = l_bukrs.
    INSERT lv_ftpost INTO t_ftpost INDEX lv_tabix_bk.
  ENDIF.

* Alle Kontierungszeilen entfernen, falls vorhanden
  LOOP AT t_ftpost ASSIGNING <po> WHERE stype = 'P' AND fnam(5) = 'COBL-'. "#EC CI_STDSEQ
    DELETE t_ftpost.
  ENDLOOP.


ENDFUNCTION.

FUNCTION /thkr/mig_fi_fm_account_determ.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_GJAHR) TYPE  PAYAC02-GJAHR
*"     VALUE(I_BUKRS) TYPE  PAYAC07-BUKRS
*"     VALUE(I_ACIND) TYPE  PAYAC01-ACIND DEFAULT SPACE
*"     VALUE(I_FIPEX) TYPE  FMCI-FIPEX OPTIONAL
*"     VALUE(I_GEBER) TYPE  PAYAC01-GEBER OPTIONAL
*"     VALUE(I_BUDGET_PD) TYPE  PAYAC01-BUDGET_PD OPTIONAL
*"     VALUE(I_FISTL) TYPE  PAYAC01-FISTL OPTIONAL
*"     VALUE(I_FKBER) TYPE  PAYAC01-FKBER OPTIONAL
*"     VALUE(I_PSOTY) TYPE  PAYAC01-PSOTY DEFAULT SPACE
*"     VALUE(I_SRTYPE) TYPE  PSO02-SRTYPE OPTIONAL
*"     VALUE(I_SAKNR) TYPE  PAYAC01-SAKNR DEFAULT SPACE
*"     VALUE(I_BLART) TYPE  PSO02-BLART DEFAULT SPACE
*"     VALUE(I_POPUP) TYPE  BOOLE-BOOLE OPTIONAL
*"  EXPORTING
*"     VALUE(E_SAKNR) LIKE  PAYAC01-SAKNR
*"  TABLES
*"      T_PAYAC01 STRUCTURE  PAYAC01 OPTIONAL
*"  EXCEPTIONS
*"      ACCOUNT_NOT_FOUND
*"      ACCOUNT_FREE_ASSIGNABLE
*"      ACCOUNT_NOT_POSSIBLE
*"      FIPEX_MULTIBLE_SAKNR
*"----------------------------------------------------------------------

* Kopie des Original Bausteins FI_FM_ACCOUNT_DETERMINE
* Dieser bringt aber immer ein Popup oder mit der Option I_POPUP
* immer den ersten Eintrag aus der Zuordnung Finanzposition zu Sachkonto
* Es soll bei bei nicht eindeutiger Zuordnung eine Fehlermeldung ausgelöst werden.



  TABLES: payac01.

  DATA: l_t_payac01_h  TYPE fipso_t_payac01  WITH HEADER LINE,
        l_t_payac01_h2 TYPE fipso_t_payac01  WITH HEADER LINE,
        l_t_payac01    TYPE fipso_t_payac01  WITH HEADER LINE.

  DATA: l_f_payac02    LIKE payac02,
        l_f_payac07    LIKE payac07,
        l_flg_possible LIKE boole-boole,
        l_flg_popup    LIKE boole-boole,
        l_gjhid        LIKE payac01-gjhid,
        l_bukfm        LIKE payac01-bukfm,
        l_fipex        LIKE payac01-fipex,
        l_fipex1       LIKE payac01-fipex,
        l_fipex2       LIKE payac01-fipex,
        l_saknr        LIKE payac01-saknr,
        l_subrc        LIKE sy-subrc,
        l_schleife     LIKE sy-tabix,
        l_exakt        LIKE boole-boole,
        l_exakt_mask   LIKE boole-boole,
        i1             LIKE syst-tabix,
        i2             LIKE syst-tabix,
        i3             LIKE payac01-prio1,
        l1             LIKE sy-tabix,
        l2             LIKE sy-tabix,
        l_digit1(1)    TYPE c,
        l_digit2(1)    TYPE c,
        l_con_plus(24) TYPE c VALUE '++++++++++++++++++++++++',
        l_old_fipex    TYPE payac01-fipex,
        l_old_i        TYPE sy-tabix,
        l_flg_appended TYPE boole-boole.

  CLEAR e_saknr.

* Bestimmung von GJHID mittels GJAHR aus Tabelle PAYAC02
  CALL FUNCTION 'FI_PSO_PAYAC02_READ2'
    EXPORTING
      i_gjahr   = i_gjahr
    IMPORTING
      e_payac02 = l_f_payac02.

  l_gjhid = l_f_payac02-gjhid.

* Bestimmung von BUKFM mittels BUKRS aus Tabelle PAYAC07
  CALL FUNCTION 'FI_PSO_PAYAC07_READ3'
    EXPORTING
      i_bukrs   = i_bukrs
    IMPORTING
      e_payac07 = l_f_payac07.

  l_bukfm = l_f_payac07-bukfm.

* Ermittlung des Sachkontos

* 0.) User Exit benutzen
  CLEAR sy-subrc.

  CALL CUSTOMER-FUNCTION '001'
    EXPORTING
      i_gjhid = l_gjhid
      i_bukfm = l_bukfm
      i_acind = i_acind
      i_fipos = i_fipex "Hier ist tatsaechl. fipex gewollt
      i_geber = i_geber
      i_fistl = i_fistl
      i_psoty = i_psoty
    IMPORTING
      e_saknr = e_saknr
    EXCEPTIONS
      OTHERS  = 1.
  l_subrc = sy-subrc.

* check if G/L account derived by customer is not
* set as "post automatically only"
  CALL FUNCTION 'FM_PSO_GL_NOT_AUTOM_ONLY_CHECK'
    EXPORTING
      i_bukrs = i_bukrs
      i_saknr = e_saknr.

  CHECK l_subrc <> 0 OR e_saknr IS INITIAL.

* call BAdI for G/L account derivation:
  PERFORM derive_gl_account_by_badi TABLES   t_payac01
                                    USING    i_gjahr
                                             l_gjhid
                                             i_bukrs
                                             l_bukfm
                                             i_fipex
                                             i_geber
                                             i_budget_pd
                                             i_fistl
                                             i_fkber
                                             i_popup
                                             i_psoty
                                             i_saknr
                                             i_blart
                                    CHANGING e_saknr.

  CHECK e_saknr IS INITIAL AND
        t_payac01[] IS INITIAL.

* Stundung
  IF i_psoty EQ '06'.
*   ALNK002537: now use gmvkz and srtype (instead of kontl)
    IF i_srtype NE '3'.
      CALL FUNCTION 'FI_PSO_PSO51_READ'
        EXPORTING
          i_gjhid = l_gjhid
          i_bukfm = l_bukfm
        IMPORTING
          e_saknr = e_saknr.
    ENDIF.
  ENDIF.

  CHECK e_saknr IS INITIAL.

* changes with release EA-PS 1.10: selection with FISTL=space and
* GEBER=space:
  CLEAR: i_fistl, i_geber.

*-----   1. Pruefen, ob exakter Eintrag vorhanden ist  -----------------

*-----check if table contents exist already
  READ TABLE g_t_payac01_ex INDEX 1.

  IF NOT sy-subrc IS INITIAL         OR
     g_t_payac01_ex-bukfm <> l_bukfm OR
     g_t_payac01_ex-gjhid <> l_gjhid.

*-----select all entries with fipex exact i.e. without '+'
    SELECT * FROM payac01 INTO TABLE g_t_payac01_ex
                                     WHERE bukfm EQ l_bukfm
                                     AND   gjhid EQ l_gjhid
                                     AND   fipex NOT LIKE '%+%'.

*-----sort table for binary search
    SORT g_t_payac01_ex BY fipex geber fistl acind psoty.
  ENDIF.

*-----refresh help table
  REFRESH l_t_payac01_h.

*-----   Pruefen, ob exakter Eintrag vorhanden ist  -----------------
* 1.1 Selektion mit fistl = space und geber = space.
  IF l_exakt EQ space.
    PERFORM find_exact_entries TABLES   g_t_payac01_ex
                                        l_t_payac01_h
                               USING    i_fipex
                                        space
                                        space
                                        i_psoty
                               CHANGING l_exakt.
  ENDIF.

* 1.2 Selektion mit fistl = space und geber = space und fipex = space.
  IF l_exakt EQ space.
    PERFORM find_exact_entries TABLES   g_t_payac01_ex
                                        l_t_payac01_h
                               USING    space
                                        space
                                        space
                                        i_psoty
                               CHANGING l_exakt.
  ENDIF.

*------   2. Es wurde kein exakter Eintrag gefunden  -------------------
*         => Maskierte Eintraege lesen und ueberpruefen

  IF l_exakt EQ space.

*-----check if table with masked fipex is already filled
    READ TABLE g_t_payac01_gen INDEX 1.

    IF NOT sy-subrc IS INITIAL         OR
       g_t_payac01_gen-bukfm <> l_bukfm OR
       g_t_payac01_gen-gjhid <> l_gjhid.

*-----select all entries with fipex contains '+'
      SELECT * FROM payac01 INTO TABLE g_t_payac01_gen
                                       WHERE bukfm EQ l_bukfm
                                       AND   gjhid EQ l_gjhid
                                       AND   fipex LIKE '%+%'.
    ENDIF.

* 2.2 Suche nach den passenden Finanzpositionen:
* (es wird Buchstabe fuer Buchstabe sowie Laenge verglichen)
    SORT g_t_payac01_gen BY fipex.
    LOOP AT g_t_payac01_gen
         WHERE ( fipex(1) = '+' OR
                 fipex(1) = i_fipex(1) ) AND
               saknr NE space.
      IF g_t_payac01_gen-fipex = l_old_fipex.
*       AT OLD fipex.
*       Adding the record for the same FIPEX if the first one was
*       fitting
        IF NOT l_flg_appended IS INITIAL.
          MOVE-CORRESPONDING g_t_payac01_gen TO l_t_payac01_h.
          l_t_payac01_h-prio1 = abs( l_t_payac01_h-prio1 - 999 ).
          l_t_payac01_h-i = l_old_i.
          APPEND l_t_payac01_h.
        ENDIF.
      ELSE.
*       AT NEW fipex.
*       prepare variables for the next loop (AT OLD fipex)
        l_old_fipex = g_t_payac01_gen-fipex.
        CLEAR: l_old_i,
               l_flg_appended.

        MOVE-CORRESPONDING g_t_payac01_gen TO l_t_payac01_h.
        l_t_payac01_h-prio1 = abs( l_t_payac01_h-prio1 - 999 ).
        CLEAR l_t_payac01_h-i.
        l_fipex1 = i_fipex.
        l_fipex2 = g_t_payac01_gen-fipex.
        l1 = strlen( l_fipex1 ).
        l2 = strlen( l_fipex2 ).
*       2.2.3 Die Kontenfindungstabellenfipex darf nicht kleiner
*       als die eingegebene Fipex sein:
*       Und die eingegebene Fipex darf auch nicht initial "note1434423
*       sein                                              "note1434423
*        IF l1 GT l2.                                     "note1434423
        IF l1 GT l2 OR l1 = 0.                            "note1434423
          CONTINUE.
        ENDIF.
*       2.2.4 Wenn die Kontenfindungstabellenfipex groesser als die
*       eingegebene Fipex ist, darf der offset nur aus +'sen bestehen!
        IF l1 LT l2.
          CLEAR l_fipex.
          MOVE l_fipex2+l1 TO l_fipex.
*         l_con_plus enthaelt nur +'se,d.h l_fipex muss lauter +'se
*         haben ausser ganz am Schluss duerfen Leerzeichen sein!
          IF l_con_plus NS l_fipex.
            CONTINUE.
          ENDIF.
        ENDIF.
*       2.2.5 Hier muessen jetzt die Buchstaben bis zur Laenge L1
*       verglichen werden:
        CLEAR l_fipex.
        MOVE l_fipex2(l1) TO l_fipex.
        IF l_fipex1 CP l_fipex.
*         2.3 es muss noch festgestellt werden, welche
*         Masierung am eindeutigsten ist
          l_schleife = 1.
          WHILE l_schleife LE l1.
            l_digit1 = l_fipex1.
            l_digit2 = l_fipex2.
            IF l_digit1 EQ l_digit2.
              l_t_payac01_h-i = l_t_payac01_h-i + 1. "Anz. gleiche Zeichen
            ENDIF.
*         naechster Buchstabe:
            SHIFT: l_fipex1, l_fipex2.
            l_schleife = l_schleife + 1.
          ENDWHILE.
        ELSE.
          CONTINUE.
        ENDIF.

*       Uebernahme nur bei mindestens einer Uebereinstimmung oder
*       wenn Maskierung nur aus +'sen besteht
        CHECK l_t_payac01_h-i NE 0       OR
              l_con_plus      CS g_t_payac01_gen-fipex.
        APPEND l_t_payac01_h.
*       set variables for the next loop (AT OLD fipex)
        l_flg_appended ='X'.
        l_old_i = l_t_payac01_h-i.
      ENDIF.

    ENDLOOP.

*---------    3. Ergebnis der Maskierung ueberpruefen:  ----------------

*   Aus den gefundenen SAKNR muss diejenige ausgesucht werden, bei der
*   der PSOTY am eindeutigsten ist d.h. sind keine SAKNR mit PSOTY =
*   I_PSOTY vorhanden, werden alle mit PSOTY = '00' verwendet.
    REFRESH l_t_payac01_h2.

*   Suche mit fistl = space und fonds = space.
    PERFORM find_gen_entries TABLES   l_t_payac01_h
                                      l_t_payac01_h2
                             USING    space
                                      space
                                      i_psoty
                             CHANGING l_exakt_mask.

*-----fill entries of l_t_payac01_h2 back into l_t_payac01_h
    REFRESH l_t_payac01_h .
    l_t_payac01_h[] = l_t_payac01_h2[].

  ENDIF.

*-----4. take those G/L accounts with highest priority (prio1)
*-----   and most matching letters of fipex (i)

*-----move relevant entries from l_t_payac01_h to l_t_payac01
  SORT l_t_payac01_h DESCENDING BY i prio1 acind psoty.
  REFRESH l_t_payac01.

  LOOP AT l_t_payac01_h.
    IF sy-tabix EQ 1.
      i3 = l_t_payac01_h-prio1.
      i2 = l_t_payac01_h-i.
    ELSE.
      IF i3 NE l_t_payac01_h-prio1 OR
         i2 NE l_t_payac01_h-i.
        EXIT.
      ENDIF.
    ENDIF.
    MOVE-CORRESPONDING l_t_payac01_h TO l_t_payac01.
    APPEND l_t_payac01.
  ENDLOOP.

  SORT l_t_payac01 BY saknr acind psoty.
  DELETE ADJACENT DUPLICATES FROM l_t_payac01 COMPARING saknr.

*-----GIVE BACK RESULTS OR RAISE ERRORS

  DESCRIBE TABLE l_t_payac01 LINES i1.
  IF i1 EQ 0.
*-----no account found
    CLEAR: e_saknr.
    MESSAGE e033(fq) RAISING account_not_found.

  ELSEIF i1 EQ 1.
*-----only one account found

    READ TABLE l_t_payac01 INDEX 1.
    IF i_saknr EQ space AND l_t_payac01-saknr EQ '*'.
*     account is freely assignable -> no exact account available
      MOVE: i_saknr TO e_saknr.
      MESSAGE e729(fq) RAISING account_free_assignable.

    ELSEIF i_saknr NE space AND l_t_payac01-saknr EQ '*'.
*     check if given account is not set as "post automatically only"
      CALL FUNCTION 'FM_PSO_GL_NOT_AUTOM_ONLY_CHECK'
        EXPORTING
          i_bukrs = i_bukrs
          i_saknr = i_saknr.
*     account is freely assignable -> take given account
      MOVE: i_saknr TO e_saknr.

    ELSEIF i_saknr NE space AND i_saknr NE l_t_payac01-saknr.
*     account given for check isn't the same -> error
      MOVE: l_t_payac01-saknr TO e_saknr.
      MESSAGE w778(fq) WITH i_saknr RAISING account_not_possible.

    ELSE.
*     take account which was found
      e_saknr = l_t_payac01-saknr.
*     export possible accounts:
      t_payac01   = l_t_payac01.
      t_payac01[] = l_t_payac01[].
    ENDIF.

*  ELSEIF i_popup EQ space.
**-----more than one document but no popup wanted
*
*    IF i_saknr EQ space.
**     no account given for check -> get first account without *
*      LOOP AT l_t_payac01 WHERE saknr NE '*'.
*        e_saknr = l_t_payac01-saknr.
*        EXIT.
*      ENDLOOP.
**     export possible accounts:
*      t_payac01   = l_t_payac01.
*      t_payac01[] = l_t_payac01[].
*
*    ELSE.
**     account given for check
*
**     export possible accounts:
*      t_payac01   = l_t_payac01.
*      t_payac01[] = l_t_payac01[].
*
**     account given -> check if account is allowed
*      PERFORM check_saknr_possible TABLES   l_t_payac01
*                                   USING    i_saknr
*                                   CHANGING l_flg_possible.
*      IF l_flg_possible = 'X'.
**       check if given account is not set as "post automatically only"
*        CALL FUNCTION 'FM_PSO_GL_NOT_AUTOM_ONLY_CHECK'
*          EXPORTING
*            i_bukrs = i_bukrs
*            i_saknr = i_saknr.
**       take given account
*        e_saknr = i_saknr.
*      ELSE.
*        e_saknr = i_saknr.
*        MESSAGE e778(fq) WITH i_saknr RAISING account_not_possible.
*      ENDIF.
*
*    ENDIF.
*
*  ELSE.                                " i_popup = 'X'
**-----more than one account -> send popup (if necessary)
*    l_flg_popup = ' '.
*
*    IF i_saknr EQ space.
**     no given account -> send popup
*      l_flg_popup = 'X'.
*    ELSE.
**     account given -> check if account is allowed
*      PERFORM check_saknr_possible TABLES   l_t_payac01
*                                   USING    i_saknr
*                                   CHANGING l_flg_possible.
*      IF l_flg_possible = 'X'.
**       -----------------------
**       normally no check for set as "automatically post only" for the
**       G/L account is needed here because the possible values are
**       already checked in customizing
**       in this case the check is needed only if wrong values exists in
**       cutomizing, beeing inserted before the correction
**       -----------------------
**       check if given account is not set as "post automatically only"
*        CALL FUNCTION 'FM_PSO_GL_NOT_AUTOM_ONLY_CHECK'
*          EXPORTING
*            i_bukrs = i_bukrs
*            i_saknr = i_saknr.
**       take given account -> no popup needed
*        e_saknr = i_saknr.
*      ELSE.
**       send popup
*        MESSAGE s778(fq) WITH i_saknr.
*        l_flg_popup = 'X'.
*      ENDIF.
*    ENDIF.
*
*    IF l_flg_popup = 'X'.
*      CALL FUNCTION 'FI_FM_ACCOUNT_DETERMINE_HLP'
*        EXPORTING
*          i_bukrs   = i_bukrs
*          i_fipex   = i_fipex
*          i_fistl   = i_fistl
*          i_geber   = i_geber
*        IMPORTING
*          e_saknr   = l_saknr
*        TABLES
*          t_payac01 = l_t_payac01
*        EXCEPTIONS
*          cancelled = 1
*          OTHERS    = 2.
*      IF l_saknr EQ space   AND    sy-subrc NE 1.
*        CLEAR: e_saknr.
*        MESSAGE e033(fq) RAISING account_not_found.
*      ENDIF.
*      IF l_saknr = '*'.
**       account is freely assignable -> no exact account choosen
*        MOVE: i_saknr TO e_saknr.
*        MESSAGE e729(fq) RAISING account_free_assignable.
*      ELSE.
*        e_saknr = l_saknr.
*      ENDIF.
*    ENDIF.

  ELSE.

    IF i_saknr IS NOT INITIAL.
*     account given for check

*     export possible accounts:
      t_payac01   = l_t_payac01.
      t_payac01[] = l_t_payac01[].

*     account given -> check if account is allowed
      PERFORM check_saknr_possible TABLES   l_t_payac01
                                   USING    i_saknr
                                   CHANGING l_flg_possible.
      IF l_flg_possible = 'X'.
*       check if given account is not set as "post automatically only"
        CALL FUNCTION 'FM_PSO_GL_NOT_AUTOM_ONLY_CHECK'
          EXPORTING
            i_bukrs = i_bukrs
            i_saknr = i_saknr.
*       take given account
        e_saknr = i_saknr.
      ELSE.
        e_saknr = i_saknr.
        MESSAGE e778(fq) WITH i_saknr RAISING account_not_possible.
      ENDIF.
    ELSE.
* mehrfachzuordnung
      MESSAGE e014(/thkr/mig) WITH i_fipex RAISING fipex_multible_saknr.
    ENDIF.
  ENDIF.                                                    "i1 eq 0

  IF e_saknr EQ space.
    MESSAGE e033(fq) RAISING account_not_found.
  ENDIF.

ENDFUNCTION.

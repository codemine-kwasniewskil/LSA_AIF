FUNCTION /thkr/wf_4a_process_bte1120.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BKDF) TYPE  BKDF OPTIONAL
*"  TABLES
*"      T_BKPF STRUCTURE  BKPF
*"      T_BSEG STRUCTURE  BSEG
*"      T_BKPFSUB STRUCTURE  BKPF_SUBST
*"      T_BSEGSUB STRUCTURE  BSEG_SUBST
*"      T_BSEC STRUCTURE  BSEC OPTIONAL
*"  CHANGING
*"     REFERENCE(I_BKDFSUB) TYPE  BKDF_SUBST OPTIONAL
*"----------------------------------------------------------------------
************************************************************************
*                        NSI Baden-Württemberg                         *
************************************************************************
*  SAP-Release : 700                        EA-PS-Release: 600         *
*  Objektname  : Z_NSI_4A_PROCESS_00001120                             *
*  Objekttyp   :                                                       *
*  Autor       : Sven Schaarschmidt               User-ID: NSI-SCHA    *
*  Auftraggeber: Marcus Schellenberger            User-ID:             *
*  Erstelldatum: 16.10.2008              Transportauftrag:             *
*  Beschreibung: Realisierung einer 4-Augen-Prüfung für die            *
*                Freigabe von Buchungsbelegen                          *
*                                                                      *
************************************************************************
*                          Änderungen                                  *
************************************************************************
*  Änd.-Nr.    :                               Änd.-Datum: 16.02.2009  *
*  Nr. OP-Liste:                         Transportauftrag: EL1K911292  *
*  Bearbeiter  : Sven Schaarschmidt               User-ID: NSI-SCHA    *
*  Auftraggeber:                                  User-ID:             *
*  Beschreibung: Bei gelöschten Zeilen in vorerfassten Belegen         *
*                verschieben sich die Zeilen zwischen Buchungssatz     *
*                und vorerfasstem Beleg. Es werden jetzt die gelöschten*
*                Zeilen ermittelt und allen vorerfassten Buchungs-     *
*                zeilen die echten zugeordent, so dass der Vergleich   *
*                der Buchungsdaten mit der richtigen Zeile des         *
*                vorerfassten Beleges erfolgt.                         *
*                                                                      *
* AMETZ20110615  Steuer rechenen brutto/netto                          *
*                                                                      *
************************************************************************
*  Änd.-Nr.    : HF20110616                    Änd.-Datum: 16.06.2011  *
*  Nr. OP-Liste:                         Transportauftrag:             *
*  Bearbeiter  : Holger Funke                     User-ID: NSI-FUNK    *
*  Auftraggeber: Holger Funke                     User-ID: NSI-FUNK    *
*  Beschreibung: Steuer rechnen brutto/netto rückgängig                *
*                Rundungsdifferenzen Steuer/Skonto angepasst           *
*                Vorzeitiges Schleifenende bei Fehler                  *
************************************************************************
************************************************************************
*  Änd.-Nr.    :                               Änd.-Datum: 01.03.2021  *
*  Nr. OP-Liste:                          Transportauftrag:            *
*  Bearbeiter  : Eugen Komlovski                  User-ID:   REPRO-KOE *
*  Auftraggeber: Marcus Schellenberger            User-ID:             *
*  Beschreibung: Übernahme ins EH2 +Anpassung + Customizing            *
************************************************************************
************************************************************************
*  Änd.-Nr.    :                               Änd.-Datum: 11.10.2023  *
*  Nr. OP-Liste:                          Transportauftrag:            *
*  Bearbeiter  : Thorsten Ganzer                  User-ID:   REPRO-GANZ*
*  Auftraggeber: Release 21b                      User-ID:             *
*  Beschreibung: Temporäre Lösung für Release                          *
************************************************************************
  DATA: l_postautomatic       TYPE /thkr/c4a_tcontr-postautomatic,
        l_postexclusive       TYPE /thkr/c4a_tcontr-postexclusive,
        l_checkresult         TYPE gtype_checkresult VALUE '00',
        l_checkrs_get_control TYPE gtype_checkresult VALUE '00'.

* Simulieren im Hauptbuch (FI-NGL) erlaubt
  IF sy-ucomm NE 'BL' AND sy-ucomm NE 'CANC'.


* Prüfung, ob Buchungskreis oder User oder Transaktion
* für die Prüfung ausgeschlossen wurden.
    PERFORM get_control  USING    t_bkpf-usnam
                                  t_bkpf-bukrs
                                  sy-tcode
                                  t_bkpf-tcode
                                  t_bseg-bschl
                                  t_bseg[]
                         CHANGING l_checkresult
                                  l_postautomatic
                                  l_postexclusive
                                  l_checkrs_get_control.

    IF l_checkresult EQ '00'.

      CASE l_postexclusive.

        WHEN OTHERS.
* erweitere Prüfung auf Vier-Augen
          CALL FUNCTION '/THKR/WF_4A_CHECK_PERMISSION'
            TABLES
              t_bkpf        = t_bkpf
              t_bseg        = t_bseg
              t_bsec        = t_bsec
            CHANGING
              c_checkresult = l_checkresult.

* "Normale" Vier-Augen-Prüfung aktiv.
* Zunächst checken ob der aktuelle User gleich Freigeber/Bucher.
          PERFORM check_user USING        sy-ucomm
                                          sy-uname
                                          t_bkpf-belnr
                                          t_bkpf-bukrs
                                          t_bkpf-gjahr
                             CHANGING     l_checkresult.


* bei der Freigabe dürfen keine Änderungen am Beleg vorgenommen werden!
          PERFORM check_change_posting  USING    t_bkpf[]
                                                 t_bseg[]
                                                 t_bsec[]
                                                 sy-ucomm
                                       CHANGING  l_checkresult.

          PERFORM check_head USING    t_bkpf[]
                             CHANGING l_checkresult.

      ENDCASE.

    ENDIF.

* Prüfung auf automatische Buchungszeilen
    IF l_postautomatic NE space AND l_checkresult EQ '00'.

      PERFORM check_automatic USING    t_bseg[]
                              CHANGING l_checkresult.

    ENDIF.

    " Prüfung ob alle zur Zeit verwendete Ausnahme-Tabellen gefüllt sind      " Prüfen
*      IF l_checkresult = '00' AND l_checkrs_get_control = '00'.     " Eugen K.
*          l_checkresult = '09'.
*      ENDIF.

  ENDIF.



*********************************************************************
***
*** Fehlercodes Checkresult
***
*** 01 - Beleg wurde nicht vorerfasst (kein vorerfasster gefunden)
*** 02 - letzter Änderer = aktueller Freigeber
*** 03 - Sachkontenzeile ungleich zu Vorerfassung
*** 04 - Kreditorenzeile ungleich zu Vorerfassung
*** 05 - Debitorenzeile ungleich zu Vorerfassung
*** 06 - Anlagenzeile ungleich zu Vorerfassung
*** 07 - Buchung enthält auch manuell erfasste Buchungszeilen
*** 08 - Belegkopf wurde verändert
*** 09 - 4 A/P verletzt, Buchung unmöglich
**** 10- 4 A/P verletzt, siehe Tabelle zom_4a_bschl
*********
*** 89 - Buchungschlüssel in Ausnahmetabelle (buchen erlaubt)
*** 90 - unbelegt (buchen erlaubt)
*** 91 - unbelegt (buchen erlaubt)
*** 92 - unbelegt (buchen erlaubt)
*** 93 - unbelegt (buchen erlaubt)
*** 94 - unbelegt (buchen erlaubt)
*** 95 - unbelegt (buchen erlaubt)
*** 96 - User in Ausnahmetabelle (buchen erlaubt)
*** 97 - Transaktion in Ausnahmetabelle (buchen erlaubt)
*** 98 - Buchungkreis nicht im Customizing (Meldung und buchen erlaubt)
*** 99 - Buchungskreis ohne aktives 4-Augen-Prinzip (buchen erlaubt)
*** 00 - kein Fehlercode ermittelbar (buchen erlaubt)
***
*********************************************************************

  CASE l_checkresult.

    WHEN '00' OR '99' OR '97' OR '96' OR '95' OR
         '94' OR '93' OR '92' OR '91' OR '90' OR '89'.
      "do nothing / Freigabe ok.
    WHEN '98'.
      MESSAGE i000(/thkr/wf_bte1120) DISPLAY LIKE 'I'.  " w
    WHEN '01'.
      MESSAGE e001(/thkr/wf_bte1120).
    WHEN '02'.
      MESSAGE e002(/thkr/wf_bte1120).
    WHEN '03'.
      MESSAGE e003(/thkr/wf_bte1120).
    WHEN '04'.
      MESSAGE e004(/thkr/wf_bte1120).
    WHEN '05'.
      MESSAGE e005(/thkr/wf_bte1120).
    WHEN '06'.
      MESSAGE e006(/thkr/wf_bte1120).
    WHEN '07'.
      MESSAGE e007(/thkr/wf_bte1120).
    WHEN '08'.
      MESSAGE e008(/thkr/wf_bte1120).
    WHEN '10'.
      MESSAGE e010(/thkr/wf_bte1120).
    WHEN '11'.
      MESSAGE e011(/thkr/wf_bte1120).

    WHEN OTHERS.
      MESSAGE e012(/thkr/wf_bte1120).

  ENDCASE.

ENDFUNCTION.                                             "#EC CI_VALPAR


*---------------------------------------------------------------------*
* FORMS
*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM get_control                                              *
*---------------------------------------------------------------------*
* Datum: 18.10.2008                 Eingefügt von: NSI-SCHA
*---------------------------------------------------------------------
* Ermitteln, ob User von der Prüfung ausgenommen ist
*---------------------------------------------------------------------
* Änderung: Ausnahme auch durch Programmnamen definiert
* Datum: 11.10.2023                Eingefügt von: REPRO-GANZ
* Inhalt: !!!!! Temporäre Lösung für Release 21b !!!!!
*         !!! Entgültige Lösung wird nach Frozen Zone eingebaut !!!
*         Das Programm "RERAPPRV" wird in die Ausnahme Logik fest
*         eingebaut.
*---------------------------------------------------------------------
FORM get_control
  USING    u_l_usnam              TYPE bkpf-usnam
           u_l_bukrs              TYPE bkpf-bukrs
           u_l_sytcode            TYPE sy-tcode
           u_l_bkpftcode          TYPE bkpf-tcode
           u_l_bschl              TYPE bseg-bschl
           lt_bseg                TYPE gtype_t_bseg
  CHANGING c_l_checkresult        TYPE gtype_checkresult
           c_l_postautomatic      TYPE /thkr/c4a_tcontr-postautomatic
           c_l_postexclusive      TYPE /thkr/c4a_tcontr-postexclusive
           c_l_checkrs_get_control TYPE gtype_checkresult.


  DATA: l_usnam            TYPE bkpf-usnam,
        u_l_usnam_tmp      TYPE bkpf-usnam,
        l_dtvon            TYPE sydatum,
        l_dtbis            TYPE sydatum,
        l_activ            TYPE c LENGTH 1,
        ls_4a_tcontrol     TYPE /thkr/c4a_tcontr, "T-Code und Sondervorgang
        lt_zom_4a_user_exe TYPE TABLE OF /thkr/c4a_userex,
        l_bschl            TYPE bseg-bschl,
        l_activ2           TYPE  c LENGTH 1,
        ls_4a_bschl        TYPE /thkr/c4a_bschl,
        lv_ind             TYPE i VALUE 0.


  CLEAR: l_usnam,
         l_dtvon,
         l_dtbis,
         l_activ,
         c_l_postautomatic,
         c_l_postexclusive,
         c_l_checkrs_get_control,
         l_bschl,
         l_activ2,
         ls_4a_bschl,
         lt_zom_4a_user_exe,
         lv_ind.

************************************************************************
*       Prüfung, ob Vier-Augen-Prinzip im Buchungskreis aktiv          *
************************************************************************

  SELECT SINGLE activ INTO l_activ
    FROM /thkr/c4a_bukrsa
    WHERE bukrs EQ u_l_bukrs.

  IF sy-subrc NE 0. "Buchungskreis nicht gefunden -> Tabelle pflegen!

    c_l_checkresult = '98'.
    "nur um sicherzustellen, was im Bukrs wirklich gewollt ist.

  ELSE.
    IF l_activ EQ space. "nicht aktiv gesetzt -> ausschließen!

      c_l_checkresult = '99'.

    ENDIF.

  ENDIF.

************************************************************************
*            Buchungsschlüssel Ausnahmen                               *
************************************************************************

  LOOP AT lt_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>).
    SELECT SINGLE * FROM /thkr/c4a_bschl INTO ls_4a_bschl WHERE bschl EQ <fs_bseg>-bschl.
    IF sy-subrc = 0.
      IF ls_4a_bschl-activ = 'X' AND c_l_checkresult EQ '00'.
        " Nichts machen. 4A/P-Prüfungen gehen weiter  ->  00 gilt weiter
        " lv_ind auf 1 setzen, um zu wissen, dass mind. einen X-Eitrag vorhanden ist.
        lv_ind = 1.
      ELSEIF ls_4a_bschl-activ = '' AND c_l_checkresult EQ '00'.
        c_l_checkresult = '10'.         " 4 A/P verletzt
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF c_l_checkresult EQ '00' AND lv_ind = 0.
    c_l_checkresult = '90'.     " Buchen erlaubt
  ENDIF.


************************************************************************
*    Ausnahme - User                                                   *
************************************************************************

  SELECT * FROM /thkr/c4a_userex INTO TABLE lt_zom_4a_user_exe WHERE bukrs = u_l_bukrs.

  LOOP AT lt_zom_4a_user_exe ASSIGNING FIELD-SYMBOL(<fs_user>).

*      IF <fs_user>-usnam CA '*'.
*        REPLACE '*' IN <fs_user>-usnam WITH ``.
*        ENDIF.

    IF ( u_l_usnam = <fs_user>-usnam OR u_l_usnam CP <fs_user>-usnam ). "cs

      IF <fs_user>-dtvon LE sy-datum AND <fs_user>-dtbis GE sy-datum
                                     AND ( c_l_checkresult EQ '00' OR c_l_checkresult EQ '10' ) .
        c_l_checkresult = '96'.
      ENDIF.

    ENDIF.
  ENDLOOP.


************************************************************************
*    Sonderbehanldung für Transaktion lesen                            *
************************************************************************

  CLEAR ls_4a_tcontrol.

  SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_4a_tcontrol "#EC CI_NOORDER
    FROM /thkr/c4a_tcontr
    WHERE  tcode EQ u_l_sytcode      "aktueller TCode SY oder
        OR tcode EQ u_l_bkpftcode .  "im Belegkopf (z.B. wg F110)

  IF ls_4a_tcontrol-postdirect NE space AND
     ( c_l_checkresult = '00' OR c_l_checkresult = '10' ).      " ? kritische Schl.

    c_l_checkresult = '97'. " Buchen erlaubt.

  ENDIF.

************************************************************************
*    Sonderbehanldung für Programme                                    *
* !!!!  Temporäre Lösung, ausführliche Lösung muss nach Frozen Zone    *
* !!!!  eingebaut werden                                               *
************************************************************************

  IF sy-cprog = 'RFRERAPPRV'.
    c_l_checkresult = '97'. " Buchen erlaubt.
  ENDIF.
************************************************************************


  c_l_postautomatic = ls_4a_tcontrol-postautomatic.
  c_l_postexclusive = ls_4a_tcontrol-postexclusive.
  c_l_checkrs_get_control =  c_l_checkresult.

ENDFORM.     "get_control

*---------------------------------------------------------------------*
*       FORM check_user                                               *
*---------------------------------------------------------------------*
* Datum: 20.10.2008                 Eingefügt von: NSI-SCHA
*---------------------------------------------------------------------
*       Freigabemechnismus realisieren
*       Vorerfasst darf durch jeden werden, der die Berechtigung
*       besitzt, zu buchen oder vorzuerfassen.
*---------------------------------------------------------------------
* Änderung:
* Datum: 00.00.0000                 Eingefügt von: xxxxxxxx
* Inhalt:
* xxx
*---------------------------------------------------------------------

FORM check_user
  USING    u_l_ucomm       TYPE sy-ucomm
           u_l_usnam       TYPE sy-uname
           u_l_belnr       TYPE bkpf-belnr
           u_l_bukrs       TYPE bkpf-bukrs
           u_l_gjahr       TYPE bkpf-gjahr
  CHANGING c_l_checkresult TYPE gtype_checkresult.

  DATA: l_user_lastchange LIKE vbkpf-usupd, "Letzer Änderer
        l_user_anleger    LIKE vbkpf-usnam, " Anleger des vorerf. Belegs
        l_anord_nummer    LIKE vbkpf-lotkz. " Anordnungsnummer

  IF c_l_checkresult EQ '00'.       "nur wenn noch kein Ablehnungsgrund

    CLEAR: l_user_lastchange, l_user_anleger, l_anord_nummer.

    SELECT SINGLE lotkz usnam usupd                     "#EC CI_NOORDER
      INTO (l_anord_nummer, l_user_anleger, l_user_lastchange)
      FROM vbkpf
      WHERE bukrs EQ u_l_bukrs
      AND belnr EQ u_l_belnr
      AND gjahr EQ u_l_gjahr.


    IF sy-subrc NE 0.    " "kein vorerfasster Beleg gefunden

      IF u_l_ucomm EQ 'BU' OR u_l_ucomm =  '' OR u_l_ucomm = 'POST' OR u_l_ucomm = 'GOBU'.   "buchen
        c_l_checkresult = '01'. "buchen ohne 4-Augen
      ENDIF.

    ELSE.               " vorerfasster Beleg gefunden

      IF l_anord_nummer NE '' .  " Sonderlogik für Anordnungen

        IF u_l_usnam EQ l_user_anleger  AND ( u_l_ucomm EQ 'BU' OR u_l_ucomm = 'POST' OR u_l_ucomm = ''  ).
          c_l_checkresult = '11'. "buchen ohne 4-Augen
        ELSE.
          c_l_checkresult = '00'. "buchen erlaubt
        ENDIF.

      ELSE.                      " Standardlogik für normale FI-Belege

        IF u_l_usnam EQ l_user_lastchange  AND ( u_l_ucomm EQ 'BU' OR u_l_ucomm = 'POST' OR u_l_ucomm = '' OR u_l_ucomm = 'GOBU' ).
          c_l_checkresult = '02'. "buchen ohne 4-Augen
        ELSE.
          c_l_checkresult = '00'. "buchen erlaubt
        ENDIF.

      ENDIF.

    ENDIF.


*    SELECT SINGLE lotkz INTO l_anord_nummer FROM vbkpf
*      WHERE bukrs EQ u_l_bukrs
*        AND belnr EQ u_l_belnr
*        AND gjahr EQ u_l_gjahr.
*
*
*    IF l_anord_nummer ne '' .  " Sonderlogik für Anordnungen
*
*       select SINGLE usnam
*         into l_user_anleger
*         from vbkpf
*         WHERE bukrs EQ u_l_bukrs
*         AND belnr EQ u_l_belnr
*         AND gjahr EQ u_l_gjahr.
*
*          IF sy-subrc NE 0.   "kein vorerfasster Beleg gefunden
*
*              IF u_l_ucomm EQ 'BU' OR u_l_ucomm =  '' OR u_l_ucomm = 'POST' .   "buchen
*                c_l_checkresult = '01'. "buchen ohne 4-Augen
*              ENDIF.
*
*          ELSE.
*
**Wenn der Vorerfasser gleich dem aktuellen Nutzer ist,
**dann ist auch das ein Fehler, wenn gebucht wird!
**Aber vorerfasst darf werden (OK-Code = 'BP')
**Auch die Prüfung auf Vollständigkeit (OK-Code = 'PBBP')
**ist möglich.
*
*              IF u_l_usnam EQ l_user_anleger  AND ( u_l_ucomm EQ 'BU' OR u_l_ucomm = 'POST' OR u_l_ucomm = ''  ).
*                c_l_checkresult = '11'. "buchen ohne 4-Augen
*              ELSE.
*                c_l_checkresult = '00'. "buchen erlaubt
*              ENDIF.
*
*          ENDIF.
*
*
*
*    ELSE.              " Standardlogik für normale Belege
*
*    SELECT SINGLE usupd
*      INTO l_user_lastchange
*      FROM vbkpf
*      WHERE bukrs EQ u_l_bukrs
*        AND belnr EQ u_l_belnr
*        AND gjahr EQ u_l_gjahr.
*
*
**Wenn nichts gefunden wurde, dann war der Beleg nicht vorerfasst.
**Damit ist es ein Fehler, wenn gebucht wird!
**Aber vorerfasst darf werden (OK-Code = 'BP')
**Auch die Prüfung auf Vollständigkeit (OK-Code = 'PBBP')
**ist möglich.
*    IF sy-subrc NE 0.   "kein vorerfasster Beleg gefunden
*
*      IF u_l_ucomm EQ 'BU' OR u_l_ucomm =  '' OR u_l_ucomm = 'POST' or  u_l_ucomm = 'GOBU' .   "buchen
*        c_l_checkresult = '01'. "buchen ohne 4-Augen
*      ENDIF.
*
*    ELSE.
*
**Wenn der Vorerfasser gleich dem aktuellen Nutzer ist,
**dann ist auch das ein Fehler, wenn gebucht wird!
**Aber vorerfasst darf werden (OK-Code = 'BP')
**Auch die Prüfung auf Vollständigkeit (OK-Code = 'PBBP')
**ist möglich.
*      IF u_l_usnam EQ l_user_lastchange  AND ( u_l_ucomm EQ 'BU' OR u_l_ucomm = 'POST' OR u_l_ucomm = '' or u_l_ucomm = 'GOBU' ).
*        c_l_checkresult = '02'. "buchen ohne 4-Augen
*      ELSE.
*        c_l_checkresult = '00'. "buchen erlaubt
*      ENDIF.
*
*    ENDIF.
*
*  ENDIF.   " sy-subrc EQ 0 Sonderlogik für Anordnungen, Else Standardlogik für normale Belege
  ENDIF.   " c_l_checkresult EQ '00'

ENDFORM.    "check_user

*---------------------------------------------------------------------*
*       FORM check_change_posting                                     *
*---------------------------------------------------------------------*
* Datum: 30.10.2008                 Eingefügt von: NSI-SCHA
*---------------------------------------------------------------------
*       Freigabemechnismus realisieren
*       Änderungen sind nicht erlaubt, wenn freigegeben wird
*---------------------------------------------------------------------
* Änderung:
* Datum: 00.00.0000                 Eingefügt von: xxxxxxxx
* Inhalt:
* xxx
*---------------------------------------------------------------------

FORM check_change_posting
     USING    u_t_bkpf        TYPE gtype_t_bkpf
              u_t_bseg        TYPE gtype_t_bseg
              u_t_bsec        TYPE gtype_t_bsec
              u_l_ucomm       TYPE sy-ucomm
     CHANGING c_l_checkresult TYPE gtype_checkresult.

  DATA: ls_bseg_post       TYPE bseg, "BSEG-Zeilen
        ls_vbseg_check_pk  TYPE gtype_s_bseg_check_ap_ar, "AR und AP
        ls_bseg_check_pk   TYPE gtype_s_bseg_check_ap_ar,
        l_skfbt            TYPE skfbt, "Skontobasisbertag

        ls_vbseg_check_sk  TYPE gtype_s_bseg_check_gl_aa, "GL und AA
        ls_bseg_check_sk   TYPE gtype_s_bseg_check_gl_aa,

        l_steuer           TYPE c LENGTH 1 VALUE space, "N=Netto/B=Brutto
        l_steuerbetrag     TYPE wmwst,

        ls_bkpf            TYPE bkpf,  "Kopf Buchung
        ls_vbkpf           TYPE vbkpf, "Kopf Vorerfassung

        l_check            TYPE gtype_flag VALUE space, "Flag
        l_check_subst_kont TYPE gtype_flag VALUE space,

*+HF20110616
        l_diff_betrag      TYPE wmwst,
        l_diff_max         TYPE wmwst,
*-HF20110616

        l_wrbtr            TYPE bseg-wrbtr, "Betrag

        ls_vbsec_check     TYPE bsec, "Individueller Regulierer
        ls_bsec_check      TYPE bsec.

*      l_buzei           TYPE bseg-buzei, "Buchungszeile Zähler für 0,00
*      l_buzei_diff      TYPE bseg-buzei.

*>>> Eingefügt 16.02.2009
  DATA: ls_buzei TYPE gtype_buzei_v_post,
        lt_buzei TYPE gtype_t_buzei_v_post.
*<<< Ende Einfügen 16.02.2009



  CLEAR: ls_bseg_post,
         ls_vbseg_check_pk, ls_bseg_check_pk,
         l_skfbt,

         ls_vbseg_check_sk, ls_bseg_check_sk,

         l_steuer, l_steuerbetrag,

         ls_bkpf, ls_vbkpf,

         l_check, l_check_subst_kont,

         l_wrbtr,

         ls_vbsec_check, ls_bsec_check.



  IF c_l_checkresult EQ '00'.

    LOOP AT u_t_bseg INTO ls_bseg_post.

      CLEAR: ls_vbseg_check_pk,
             ls_vbseg_check_sk,
             ls_bsec_check,
             ls_vbsec_check.

*+HF20110616
* Wenn einer falsch, dann braucht nicht mehr weiter geprüft zu werden
      IF c_l_checkresult NE '00'.
        EXIT.
      ENDIF.
*+HF20110616

      IF ls_bseg_post-xauto EQ space. "keine Prüfung automatischer Zeilen

* Art der Steuererfassung ermitteln, aber nur wenn neuer Beleg
* Außerdem die Buchungszeilen ermitteln.
        IF l_steuer EQ space OR
           ls_bseg_post-bukrs NE ls_bkpf-bukrs OR
           ls_bseg_post-belnr NE ls_bkpf-belnr OR
           ls_bseg_post-gjahr NE ls_bkpf-gjahr.

* Steuererfassung
          READ TABLE u_t_bkpf
            WITH KEY mandt = ls_bseg_post-mandt
                           bukrs = ls_bseg_post-bukrs
                           belnr = ls_bseg_post-belnr
                           gjahr = ls_bseg_post-gjahr
            INTO ls_bkpf.

          SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_vbkpf "#EC CI_ALL_FIELDS_NEEDED
            FROM vbkpf                                  "#EC CI_NOORDER
            WHERE bukrs EQ ls_bseg_post-bukrs
              AND belnr EQ ls_bseg_post-belnr
              AND gjahr EQ ls_bseg_post-gjahr.

          IF ls_vbkpf-xmwst EQ 'X'. "Kennzeichen Steuer rechnen?
            IF ls_vbkpf-xsnet EQ 'X'. "Kennzeichen auf netto rechnen?
              l_steuer = 'N'. "Steuer rechnen auf netto
            ELSE.
              l_steuer = 'B'.
            ENDIF.

          ELSE.

*+HF20110616 Restaurierung Zustand vor Änderung
* wenn kein Steuer rechnen gewählt ist, sind die Beträge Netto in den Sachkontenzeilen enthalten
* Kennzeichen xsnet ist dann irrelevant, da es nur bei Steuern rechnen zu berücksichtigen ist
            l_steuer = 'N'. "wenn kein rechnen, dann netto!

**---AMETZ 20110615 -------------------------------------------------------------*
**          l_steuer = 'N'. "wenn kein rechnen, dann netto!
*
*            IF ls_vbkpf-xsnet EQ 'X'. "Kennzeichen auf netto rechnen?
*              l_steuer = 'N'. "Steuer rechnen auf netto
*            ELSE.
*              l_steuer = 'B'.
*            ENDIF.
**---AMETZ 20110615 -------------------------------------------------------------*
*-HF20110616
          ENDIF.


*>>> Einfügen 16.02.2009
* Buchungszeilen
          CLEAR: lt_buzei, ls_buzei.

          PERFORM get_buzei_post USING ls_bseg_post-bukrs
                                       ls_bseg_post-belnr
                                       ls_bseg_post-gjahr
                                CHANGING lt_buzei.
*Ende Einfügen 16.12.2009

        ENDIF.

*>>> Einfügen 16.02.2009
        CLEAR: ls_buzei.
        READ TABLE lt_buzei INTO ls_buzei
          WITH KEY post_buzei = ls_bseg_post-buzei.
*<<< Ende Einfügen 16.02.2009

* Jetzt je nach Kontoart unterschiedliche Prüfungen
        CASE ls_bseg_post-koart.

* Kreditorenzeilen (ähnlich zu Debitoren)
          WHEN 'K'.

            SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_vbseg_check_pk "#EC CI_ALL_FIELDS_NEEDED
              FROM vbsegk                               "#EC CI_NOORDER
              WHERE bukrs EQ ls_bseg_post-bukrs
               AND belnr EQ ls_bseg_post-belnr
               AND gjahr EQ ls_bseg_post-gjahr
*>>> Einfügen 16.02.2009
*            AND buzei EQ ls_bseg_post-buzei.
                AND buzei EQ ls_buzei-vbuzei.
*<<< Ende Einfügen 16.02.2009
            ls_vbseg_check_pk-koart = 'K'.

            MOVE-CORRESPONDING ls_bseg_post TO ls_bseg_check_pk.

            IF ls_bseg_post-skfbt NE ls_bseg_post-wrbtr.

              SELECT SINGLE skfbt INTO l_skfbt          "#EC CI_NOORDER
                FROM vbsegk
                WHERE bukrs EQ ls_bseg_post-bukrs
                  AND belnr EQ ls_bseg_post-belnr
                  AND gjahr EQ ls_bseg_post-gjahr
*>>> Einfügen 16.02.2009
*            AND buzei EQ ls_bseg_post-buzei.
                 AND buzei EQ ls_buzei-vbuzei.
*<<< Ende Einfügen 16.02.2009

              IF sy-subrc EQ 0.
                IF ls_bseg_post-skfbt NE l_skfbt.
                  c_l_checkresult = '04'.
                ENDIF.
              ENDIF.

            ELSE.

              IF ls_vbseg_check_pk NE ls_bseg_check_pk.
                CLEAR: l_check_subst_kont.
                PERFORM check_subst_kont USING    ls_bseg_check_pk-gsber
                                                  ls_bseg_check_pk-prctr
                                                  ls_bseg_check_pk-segment
                                                  ls_vbseg_check_pk-gsber
                                                  ls_vbseg_check_pk-prctr
                                                  ls_vbseg_check_pk-segment
                                                  ls_vbseg_check_pk-geber
                                                  ls_vbseg_check_pk-umskz
                                                  ls_vbseg_check_pk-koart
                                                  ls_vbseg_check_pk-xauto
                                                  ls_vbseg_check_pk-bukrs
                                         CHANGING l_check_subst_kont.
                IF l_check_subst_kont NE space.
                  c_l_checkresult = '04'.  "Kreditorenzeile ungleich
                ENDIF.
              ENDIF.

            ENDIF.

            IF ls_bseg_post-xcpdd NE space AND c_l_checkresult EQ '00'.

              SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_vbsec_check "#EC CI_ALL_FIELDS_NEEDED
                FROM vbsec
                WHERE ausbk EQ ls_bseg_post-bukrs
                  AND belnr EQ ls_bseg_post-belnr
                  AND gjahr EQ ls_bseg_post-gjahr
*>>> Einfügen 16.02.2009
*            AND buzei EQ ls_bseg_post-buzei.
                  AND buzei EQ ls_buzei-vbuzei.
*<<< Ende Einfügen 16.02.2009

              IF sy-subrc NE 0.
                c_l_checkresult = '04'. "nichts gefunden Fehler!
              ELSE.
* Es wurde etwas gefunden, deshalb kann auch der Bukrs gesetzt werden.
                ls_vbsec_check-bukrs = ls_bseg_post-bukrs.
                READ TABLE u_t_bsec
                    WITH KEY mandt = ls_bseg_post-mandt
                             bukrs = ls_bseg_post-bukrs
                             belnr = ls_bseg_post-belnr
                             gjahr = ls_bseg_post-gjahr
*>>> Einfügen 16.02.2009
*                         buzei = ls_bseg_post-buzei
                             buzei = ls_buzei-vbuzei
*<<< Ende Einfügen 16.02.2009
                    INTO ls_bsec_check.

                IF sy-subrc NE 0 OR ls_vbsec_check NE ls_bsec_check.
                  c_l_checkresult = '04'.
                ENDIF.
              ENDIF.

            ENDIF.


* Debitorenzeilen (ähnlich zu Kreditoren)
          WHEN 'D'.
            SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_vbseg_check_pk "#EC CI_ALL_FIELDS_NEEDED
              FROM vbsegd                               "#EC CI_NOORDER
              WHERE bukrs EQ ls_bseg_post-bukrs
               AND belnr EQ ls_bseg_post-belnr
               AND gjahr EQ ls_bseg_post-gjahr
*>>> Einfügen 16.02.2009
*            AND buzei EQ ls_bseg_post-buzei.
                AND buzei EQ ls_buzei-vbuzei.
*<<< Ende Einfügen 16.02.2009
            ls_vbseg_check_pk-koart = 'D'.

            MOVE-CORRESPONDING ls_bseg_post TO ls_bseg_check_pk.

            IF ls_bseg_post-skfbt NE ls_bseg_post-wrbtr.

              SELECT SINGLE skfbt INTO l_skfbt          "#EC CI_NOORDER
                FROM vbsegd
                WHERE bukrs EQ ls_bseg_post-bukrs
                  AND belnr EQ ls_bseg_post-belnr
                  AND gjahr EQ ls_bseg_post-gjahr
*>>> Einfügen 16.02.2009
*            AND buzei EQ ls_bseg_post-buzei.
                 AND buzei EQ ls_buzei-vbuzei.
*<<< Ende Einfügen 16.02.2009

              IF sy-subrc EQ 0.
                IF ls_bseg_post-skfbt NE l_skfbt.
                  c_l_checkresult = '05'.  "Debitorenzeile ungleich
                ENDIF.
              ENDIF.

            ELSE.

              IF ls_vbseg_check_pk NE ls_bseg_check_pk.
                CLEAR: l_check_subst_kont.
                PERFORM check_subst_kont USING    ls_bseg_check_pk-gsber
                                                  ls_bseg_check_pk-prctr
                                                  ls_bseg_check_pk-segment
                                                  ls_vbseg_check_pk-gsber
                                                  ls_vbseg_check_pk-prctr
                                                  ls_vbseg_check_pk-segment
                                                  ls_vbseg_check_pk-geber
                                                  ls_vbseg_check_pk-umskz
                                                  ls_vbseg_check_pk-koart
                                                  ls_vbseg_check_pk-xauto
                                                  ls_vbseg_check_pk-bukrs
                                         CHANGING l_check_subst_kont.
                IF l_check_subst_kont NE space.
                  c_l_checkresult = '05'.  "Debitorenzeile ungleich
                ENDIF.
              ENDIF.

            ENDIF.

            IF ls_bseg_post-xcpdd NE space AND c_l_checkresult EQ '00'.

              SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_vbsec_check "#EC CI_ALL_FIELDS_NEEDED
                FROM vbsec
                WHERE ausbk EQ ls_bseg_post-bukrs
                  AND belnr EQ ls_bseg_post-belnr
                  AND gjahr EQ ls_bseg_post-gjahr
*>>> Einfügen 16.02.2009
*            AND buzei EQ ls_bseg_post-buzei.
                  AND buzei EQ ls_buzei-vbuzei.
*<<< Ende Einfügen 16.02.2009

              IF sy-subrc NE 0.
                c_l_checkresult = '05'. "nichts gefunden Fehler!
              ELSE.
* Es wurde etwas gefunden, deshalb kann auch der Bukrs gesetzt werden.
                ls_vbsec_check-bukrs = ls_bseg_post-bukrs.

                READ TABLE u_t_bsec
                    WITH KEY mandt = ls_bseg_post-mandt
                             bukrs = ls_bseg_post-bukrs
                             belnr = ls_bseg_post-belnr
                             gjahr = ls_bseg_post-gjahr
*>>> Einfügen 16.02.2009
*                         buzei = ls_bseg_post-buzei
                             buzei = ls_buzei-vbuzei
*<<< Ende Einfügen 16.02.2009
                    INTO ls_bsec_check.

                IF sy-subrc NE 0 OR ls_vbsec_check NE ls_bsec_check.
                  c_l_checkresult = '05'.
                ENDIF.
              ENDIF.

            ENDIF.


* Anlagenzeilen
          WHEN 'A'.

            SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_vbseg_check_sk "#EC CI_NOORDER
              FROM vbsega
              WHERE bukrs EQ ls_bseg_post-bukrs
                AND belnr EQ ls_bseg_post-belnr
                AND gjahr EQ ls_bseg_post-gjahr
*>>> Einfügen 16.02.2009
*            AND buzei EQ ls_bseg_post-buzei.
                AND buzei EQ ls_buzei-vbuzei.
*<<< Ende Einfügen 16.02.2009
            ls_vbseg_check_sk-koart = 'A'.

            IF sy-subrc NE 0.
              c_l_checkresult = '03'. "Anlagenzeile ungleich
            ELSE.


              MOVE-CORRESPONDING ls_bseg_post TO ls_bseg_check_sk.

* Die Felder sind  nicht immer gefüllt, und auch
* unterschiedlich zwischen Buchungsstruktur und vorerfasstem Beleg

              IF ls_vbseg_check_sk-hkont EQ space AND
                 ls_vbseg_check_sk-saknr NE space.
                ls_vbseg_check_sk-hkont = ls_vbseg_check_sk-saknr.
              ENDIF.

              IF ls_vbseg_check_sk-hkont NE space AND
                 ls_vbseg_check_sk-saknr EQ space.
                ls_vbseg_check_sk-saknr = ls_vbseg_check_sk-hkont.
              ENDIF.


              IF ls_bseg_check_sk-hkont EQ space AND
                 ls_bseg_check_sk-saknr NE space.
                ls_bseg_check_sk-hkont = ls_bseg_check_sk-saknr.
              ENDIF.

              IF ls_bseg_check_sk-hkont NE space AND
                 ls_bseg_check_sk-saknr EQ space.
                ls_bseg_check_sk-saknr = ls_bseg_check_sk-hkont.
              ENDIF.

* Prüfung auf Gleichheit
              IF ls_bseg_check_sk NE ls_vbseg_check_sk.
                CLEAR: l_check_subst_kont.
                PERFORM check_subst_kont USING    ls_bseg_check_sk-gsber
                                                  ls_bseg_check_sk-prctr
                                                  ls_bseg_check_sk-segment
                                                  ls_vbseg_check_sk-gsber
                                                  ls_vbseg_check_sk-prctr
                                                  ls_vbseg_check_sk-segment
                                                  ls_vbseg_check_sk-geber
                                                  ls_vbseg_check_sk-umskz
                                                  ls_vbseg_check_sk-koart
                                                  ls_vbseg_check_sk-xauto
                                                  ls_vbseg_check_sk-bukrs
                                         CHANGING l_check_subst_kont.
                IF l_check_subst_kont NE space.
                  c_l_checkresult = '06'.  "Anlagenzeile ungleich
                ENDIF.
              ENDIF.

* Nun muss auch noch der Betrag geprüft werden
              SELECT SINGLE wrbtr INTO l_wrbtr          "#EC CI_NOORDER
                FROM vbsega
                WHERE bukrs EQ ls_bseg_post-bukrs
                  AND belnr EQ ls_bseg_post-belnr
                  AND gjahr EQ ls_bseg_post-gjahr
*>>> Einfügen 16.02.2009
*             AND buzei EQ ls_bseg_post-buzei.
                 AND buzei EQ ls_buzei-vbuzei.
*<<< Ende Einfügen 16.02.2009

              PERFORM check_betrag_gl_aa USING ls_bseg_post-wrbtr
                                               ls_bseg_post-navfw
                                               ls_bseg_post-wskto
                                               ls_bseg_post-koart
                                               l_steuer
                                               l_wrbtr
                                               ls_bseg_post-bukrs
                                               ls_bseg_post-mwskz
*+HF20110616
*                                         CHANGING l_check.
                                          CHANGING l_check
                                                   l_diff_betrag.

              IF l_check NE '0'.
* Um genau zu prüfen, könnte man jetzt noch den gesamten Beleg aufaddieren
* falls es bei der Personenkontenzeile betragsmäßig nicht passt, was ja das
* kritischste wäre, fliegt der Beleg ohnehin mit anderem Prüfergebnis raus

                l_diff_max = lines( u_t_bseg ) / 100.
                IF l_diff_betrag >  l_diff_max. "Differenz größer als Zahl der Belegzeilen?
                  c_l_checkresult = '06'.      "Anlagenzeile ungleich
                ELSE.
* nix tun, das lassen wir zu
                ENDIF.
*              IF l_check NE '0'.
*                c_l_checkresult = '06'.    "Anlagenzeile ungleich
*-HF20110616
              ENDIF.
            ENDIF.

*Sachkontenzeilen
          WHEN 'S'.

            SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_vbseg_check_sk "#EC CI_NOORDER
              FROM vbsegs
              WHERE bukrs EQ ls_bseg_post-bukrs
                AND belnr EQ ls_bseg_post-belnr
                AND gjahr EQ ls_bseg_post-gjahr
*>>> Einfügen 16.02.2009
*            AND buzei EQ ls_bseg_post-buzei.
                AND buzei EQ ls_buzei-vbuzei.
*<<< Ende Einfügen 16.02.2009
            ls_vbseg_check_sk-koart = 'S'.

            MOVE-CORRESPONDING ls_bseg_post TO ls_bseg_check_sk.

* Die Felder sind  nicht immer gefüllt, und auch
* unterschiedlich zwischen Buchungsstruktur und vorerfasstem Beleg

            IF ls_vbseg_check_sk-hkont EQ space AND
               ls_vbseg_check_sk-saknr NE space.
              ls_vbseg_check_sk-hkont = ls_vbseg_check_sk-saknr.
            ENDIF.

            IF ls_vbseg_check_sk-hkont NE space AND
               ls_vbseg_check_sk-saknr EQ space.
              ls_vbseg_check_sk-saknr = ls_vbseg_check_sk-hkont.
            ENDIF.


            IF ls_bseg_check_sk-hkont EQ space AND
               ls_bseg_check_sk-saknr NE space.
              ls_bseg_check_sk-hkont = ls_bseg_check_sk-saknr.
            ENDIF.

            IF ls_bseg_check_sk-hkont NE space AND
               ls_bseg_check_sk-saknr EQ space.
              ls_bseg_check_sk-saknr = ls_bseg_check_sk-hkont.
            ENDIF.

*Prüfung auf Gleichheit
            IF ls_bseg_check_sk NE ls_vbseg_check_sk.
              CLEAR: l_check_subst_kont.
              PERFORM check_subst_kont USING    ls_bseg_check_sk-gsber
                                                ls_bseg_check_sk-prctr
                                                ls_bseg_check_sk-segment
                                                ls_vbseg_check_sk-gsber
                                                ls_vbseg_check_sk-prctr
                                                ls_vbseg_check_sk-segment
                                                ls_vbseg_check_sk-geber
                                                ls_vbseg_check_sk-umskz
                                                ls_vbseg_check_sk-koart
                                                ls_vbseg_check_sk-xauto
                                                ls_vbseg_check_sk-bukrs
                                       CHANGING l_check_subst_kont.
              IF l_check_subst_kont NE space.
                c_l_checkresult = '03'.  "Sachkontenzeile ungleich
              ENDIF.
            ENDIF.

* Nun muss auch noch der Betrag geprüft werden
            SELECT SINGLE wrbtr INTO l_wrbtr            "#EC CI_NOORDER
              FROM vbsegs
              WHERE bukrs EQ ls_bseg_post-bukrs
                AND belnr EQ ls_bseg_post-belnr
                AND gjahr EQ ls_bseg_post-gjahr
*>>> Einfügen 16.02.2009
*            AND buzei EQ ls_bseg_post-buzei.
                AND buzei EQ ls_buzei-vbuzei.
*<<< Ende Einfügen 16.02.2009

            PERFORM check_betrag_gl_aa USING ls_bseg_post-wrbtr
                                             ls_bseg_post-navfw
                                             ls_bseg_post-wskto
                                             ls_bseg_post-koart
                                             l_steuer
                                             l_wrbtr
                                             ls_bseg_post-bukrs
                                             ls_bseg_post-mwskz

*+HF20110616
*                                       CHANGING l_check.
                                       CHANGING l_check
                                                l_diff_betrag.

            IF l_check NE '0'.
* Um genau zu prüfen, könnte man jetzt noch den gesamten Beleg aufaddieren
* falls es bei der Personenkontenzeile betragsmäßig nicht passt, was ja das
* kritischste wäre, fliegt der Beleg ohnehin mit anderem Prüfergebnis raus

              l_diff_max = lines( u_t_bseg ) / 100.
              IF l_diff_betrag >  l_diff_max. "Differenz größer als Zahl der Belegzeilen?
                c_l_checkresult = '03'.      "Sachkontenzeile ungleich
              ELSE.
* nix tun, das lassen wir zu
              ENDIF.
*            IF l_check NE '0'.
*              c_l_checkresult = '03'.   "Sachkontenzeile ungleich
*-HF20110616
            ENDIF.


        ENDCASE.

      ENDIF.

    ENDLOOP.


  ENDIF.

ENDFORM.   "check_change_posting


*---------------------------------------------------------------------*
*       FORM check_betrag                                             *
*---------------------------------------------------------------------*
* Datum: 30.10.2008                 Eingefügt von: NSI-SCHA
*---------------------------------------------------------------------
*       Betrag prüfen
*
*---------------------------------------------------------------------
* Änderung:
* Datum: 00.00.0000                 Eingefügt von: xxxxxxxx
* Inhalt:
* xxx
*---------------------------------------------------------------------
* Fehlercode 1 = keine Übereinstimmung
* Fehlercode 0 = Übereinstimmung

FORM check_betrag_gl_aa
     USING    u_l_wrbtr      TYPE bseg-wrbtr
              u_l_navfw      TYPE bseg-navfw
              u_l_wskto      TYPE bseg-wskto
              u_l_koart      TYPE bseg-koart
              u_l_steuer     TYPE gtype_flag
              u_l_wrbtr_vbel TYPE bseg-wrbtr
              u_l_bukrs      TYPE bseg-bukrs
              u_l_mwskz      TYPE bseg-mwskz

*+HF20110616
*     CHANGING c_l_check       TYPE gtype_flag.
     CHANGING c_l_check        TYPE gtype_flag
              c_l_diff_betrag  TYPE bseg-wmwst.
*-HF20110616

  DATA: l_wrbtr_calc    TYPE bseg-wrbtr,
        l_t_tax         TYPE TABLE OF rtax1u38,
        l_t_tax_result  TYPE TABLE OF rtax1u38,
        l_s_tax         TYPE rtax1u38,
        l_s_tax_result  TYPE rtax1u38, "FBaustein CALCULATE_TAXES_NET
        l_nav           TYPE gtype_flag, "X=nicht abzugsfähig
        l_tax_amount    TYPE bseg-wrbtr,
        l_zwischensumme TYPE bseg-wrbtr.
***
  DATA: l_wrbtr_high TYPE bseg-wrbtr,
        l_wrbtr_low  TYPE bseg-wrbtr.

  CONSTANTS c_toleranz  TYPE bseg-wrbtr VALUE '0.03'.
***

  CLEAR: l_wrbtr_calc.

* Nur bei Sachkonten und Anlagen, nicht bei Kreditoren und Debitoren,
* da hier anders geprüft werden muss.
* Sachkonten unterscheiden sich in Erfassung und Buchung
* Brutto/Netto (Steuer) und Brutto/Netto (Skonto-Nettobelegart)
  IF u_l_mwskz NE space AND u_l_mwskz NE '**' AND
     ( u_l_koart EQ 'S' OR u_l_koart EQ 'A' ).


* Ermittlung, ob das Steuerkennzeichen abzugsfähig ist
* und Steuerbetrag.
    CLEAR: l_s_tax, l_t_tax, l_t_tax_result, l_s_tax_result.
    l_s_tax-posnr = 1.
    l_s_tax-bukrs = u_l_bukrs.
    l_s_tax-mwskz = u_l_mwskz.
    l_s_tax-wrbtr = u_l_wrbtr_vbel.
    APPEND l_s_tax TO l_t_tax.

    CALL FUNCTION 'CALCULATE_TAXES_NET'
      TABLES
        tax_item_in  = l_t_tax
        tax_item_out = l_t_tax_result.

    READ TABLE l_t_tax_result
      WITH KEY posnr = 1
      INTO l_s_tax_result.

    l_nav = l_s_tax_result-stazf.

*Betrag errechnen
    IF u_l_steuer EQ 'N'.               "Nettoerfassung (Steuer)

      IF l_nav NE space.  "nicht abzugsfähig.
* Nettoerfassung und nicht abzugsfähig
* Ermitteln Steuerbetrag zum Eingabebetrag
        CLEAR: l_s_tax, l_t_tax_result, l_s_tax_result.
        l_s_tax-posnr = 2.
        l_s_tax-bukrs = u_l_bukrs.
        l_s_tax-mwskz = u_l_mwskz.
        l_s_tax-wrbtr = u_l_wrbtr_vbel - u_l_wskto. "Netto-Skonto
        APPEND l_s_tax TO l_t_tax.

        CALL FUNCTION 'CALCULATE_TAXES_NET'
          TABLES
            tax_item_in  = l_t_tax
            tax_item_out = l_t_tax_result.

        READ TABLE l_t_tax_result
          WITH KEY posnr = 2
          INTO l_s_tax_result.
* Berechnung Erfassungsbetrag - Skonto + Steuerbetrag
        l_wrbtr_calc = u_l_wrbtr_vbel - u_l_wskto + l_s_tax_result-fwste.

      ELSE.

* Nettoerfassung und abzugsfähig
* Berechnung Erfassungsbetrag - Skonto
        l_wrbtr_calc = u_l_wrbtr_vbel - u_l_wskto.

      ENDIF.

    ELSE.

      IF l_nav NE space.  "nicht abzugsfähig.

* Bruttoerfassung und nicht abzugsfähig
* Nettobetrag aus dem (Brutto)Erfassungsbetrag ermitteln
        CLEAR: l_s_tax, l_t_tax_result, l_s_tax_result.
        l_s_tax-posnr = 2.
        l_s_tax-bukrs = u_l_bukrs.
        l_s_tax-mwskz = u_l_mwskz.
        l_s_tax-wrbtr = u_l_wrbtr_vbel. "netto-Skonto
        APPEND l_s_tax TO l_t_tax.

        CALL FUNCTION 'CALCULATE_TAXES_GROSS'
          TABLES
            tax_item_in  = l_t_tax
            tax_item_out = l_t_tax_result.

        READ TABLE l_t_tax_result
          WITH KEY posnr = 2
          INTO l_s_tax_result.

* skontiertes Nettobetrag = ermittelter Nettobetrag minus Skonto(netto)
        l_wrbtr_calc = l_s_tax_result-fwbas - u_l_wskto.

        CLEAR: l_s_tax, l_t_tax_result, l_s_tax_result.
        l_s_tax-posnr = 3.
        l_s_tax-bukrs = u_l_bukrs.
        l_s_tax-mwskz = u_l_mwskz.
        l_s_tax-wrbtr = l_wrbtr_calc. "netto-Skonto
        APPEND l_s_tax TO l_t_tax.

        CALL FUNCTION 'CALCULATE_TAXES_NET'
          TABLES
            tax_item_in  = l_t_tax
            tax_item_out = l_t_tax_result.

        READ TABLE l_t_tax_result
          WITH KEY posnr = 3
          INTO l_s_tax_result.

* Betrag = skontierter Nettobetrag + Steuer aus skontiertem Netto
        l_wrbtr_calc = l_wrbtr_calc + l_s_tax_result-fwste.

      ELSE.

* Bruttoerfassung und nicht abzugsfähig
* Nettobetrag aus dem (Brutto)Erfassungsbetrag ermitteln
        CLEAR: l_s_tax, l_t_tax_result, l_s_tax_result.
        l_s_tax-posnr = 2.
        l_s_tax-bukrs = u_l_bukrs.
        l_s_tax-mwskz = u_l_mwskz.
        l_s_tax-wrbtr = u_l_wrbtr_vbel. "Brutto
        APPEND l_s_tax TO l_t_tax.

        CALL FUNCTION 'CALCULATE_TAXES_GROSS'
          TABLES
            tax_item_in  = l_t_tax
            tax_item_out = l_t_tax_result.

        READ TABLE l_t_tax_result
          WITH KEY posnr = 2
          INTO l_s_tax_result.

* Endbetrag = Steuerbasis(Nettobetrag) - Skonto(netto)
        l_wrbtr_calc = l_s_tax_result-fwbas - u_l_wskto.

      ENDIF.

    ENDIF.

  ELSE.
* kein Steuerkennzeichen in der Sachkontenzeile angeben, dann
* Brutto (gleich Netto) - Skonto
    l_wrbtr_calc = u_l_wrbtr_vbel - u_l_wskto.

  ENDIF.

*** ACHTUNG: Krücke wegen Rundungsdifferenzen 0,03 Toleranz.
*** SAP-FI rechnet manchmal anders...
  l_wrbtr_high = u_l_wrbtr + c_toleranz.
  l_wrbtr_low  = u_l_wrbtr - c_toleranz.
***

  IF u_l_wrbtr EQ l_wrbtr_calc OR
*** ACHTUNG: Krücke wegen Rundungsdifferenzen 0,03 Toleranz!
*** SAP-FI rechnet manchmal anders...
    ( l_wrbtr_high GE l_wrbtr_calc AND l_wrbtr_low LE l_wrbtr_calc ).
***

    c_l_check = '0'.  " Übereinstimmung!

  ELSE.

    c_l_check = '1'.  " keine Übereinstimmung!

*+HF20110616
* Es wird hier auf Ebene der Belegzeilen gerechnet
* Dadurch können sich bei Steuer und Skonto aufaddierte Rundungsdifferenzen zum Gesamtbetrag
* des Beleges ergeben, die höher als die bisher vorgesehene Toleranz sind
    c_l_diff_betrag = abs( u_l_wrbtr - l_wrbtr_calc ).
*-HF20110616

  ENDIF.

ENDFORM.   "check_betrag

*---------------------------------------------------------------------*
*       FORM check_auotmatic                                          *
*---------------------------------------------------------------------*
* Datum: 05.11.2008                 Eingefügt von: NSI-SCHA
*---------------------------------------------------------------------
* Ermitteln, ob nur automatische Buchungszeilen
* außer, wenn auf Kursdifferenzen gebucht wird
*---------------------------------------------------------------------
* Änderung:
* Datum: 00.00.0000                 Eingefügt von: xxxxxxxx
* Inhalt:
* xxx
*---------------------------------------------------------------------
FORM check_automatic
  USING    u_t_bseg               TYPE gtype_t_bseg
  CHANGING c_l_checkresult        TYPE gtype_checkresult.

  DATA: ls_bseg   TYPE bseg,
        l_bukrs   TYPE bseg-bukrs,
        l_ktopl   TYPE t001-ktopl,
        l_t_t030h TYPE STANDARD TABLE OF t030h,
        l_s_t030h TYPE t030h.

  CLEAR: ls_bseg, l_bukrs, l_ktopl.

* Test aller Zeilen per Loop
  LOOP AT u_t_bseg INTO ls_bseg.

* Wenn schon Fehler gesetzt, kann Schleife beendet werden.
    IF c_l_checkresult NE '00'.
      EXIT.
    ENDIF.

* Ausnahme Kursdifferenzen, hier darf manuell gebucht werden
* (Prozessablauf erfordert dies in manchen Fällen)
* Zunächst Ermittlung der Konten.
    IF l_bukrs NE ls_bseg-bukrs.
      SELECT SINGLE ktopl INTO l_ktopl
        FROM t001
        WHERE bukrs EQ ls_bseg-bukrs.

      IF sy-subrc NE 0.
        c_l_checkresult = '07'.
      ELSE.
        CLEAR: l_t_t030h.
        SELECT * INTO CORRESPONDING FIELDS OF l_s_t030h "#EC CI_ALL_FIELDS_NEEDED
           FROM t030h                                   "#EC CI_GENBUFF
           WHERE ktopl EQ l_ktopl.                      "#EC CI_NOORDER
          APPEND l_s_t030h TO l_t_t030h.
        ENDSELECT.
      ENDIF.

    ENDIF.

    IF ls_bseg-xauto EQ space.
      LOOP AT l_t_t030h INTO l_s_t030h.
        IF ls_bseg-saknr NE l_s_t030h-lsrea AND
           ls_bseg-saknr NE l_s_t030h-lhrea AND
           ls_bseg-hkont NE l_s_t030h-lsrea AND
           ls_bseg-hkont NE l_s_t030h-lhrea.
          c_l_checkresult = '07'.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

ENDFORM.    "check_automatic

*---------------------------------------------------------------------*
*       FORM check_head                                          *
*---------------------------------------------------------------------*
* Datum: 06.11.2008                 Eingefügt von: NSI-SCHA
*---------------------------------------------------------------------
* Ermitteln, ob Kopf geändert wurde
*
*---------------------------------------------------------------------
* Änderung:
* Datum: 00.00.0000                 Eingefügt von: xxxxxxxx
* Inhalt:
* xxx
*---------------------------------------------------------------------
FORM check_head
  USING    u_t_bkpf               TYPE gtype_t_bkpf
  CHANGING c_l_checkresult        TYPE gtype_checkresult.

  DATA: l_s_bkpf        TYPE bkpf,
        l_s_vbkpf       TYPE bkpf,
        l_s_bkpf_check  TYPE gtype_s_bkpf_check,
        l_s_vbkpf_check TYPE gtype_s_bkpf_check.

  IF c_l_checkresult EQ '00'. "nicht prüfen, wenn bereits anderer Fehler

    LOOP AT u_t_bkpf INTO l_s_bkpf.

      MOVE-CORRESPONDING l_s_bkpf TO l_s_bkpf_check.

      CLEAR: l_s_vbkpf.
      SELECT SINGLE * INTO CORRESPONDING FIELDS OF l_s_vbkpf "#EC CI_ALL_FIELDS_NEEDED
        FROM vbkpf                                      "#EC CI_NOORDER
        WHERE bukrs EQ l_s_bkpf-bukrs
          AND belnr EQ l_s_bkpf-belnr
          AND gjahr EQ l_s_bkpf-gjahr.

      MOVE-CORRESPONDING l_s_vbkpf TO l_s_vbkpf_check.

      IF l_s_vbkpf_check NE l_s_bkpf_check.
        c_l_checkresult = '08'.
        EXIT.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.  "check_head

*---------------------------------------------------------------------*
*       FORM check_subst_kont                                         *
*---------------------------------------------------------------------*
* Datum: 22.11.2008                 Eingefügt von: NSI-SCHA
*---------------------------------------------------------------------
* Wurden die Kontierungen substitutiert?
*
*---------------------------------------------------------------------
* Änderung:
* Datum: 00.00.0000                 Eingefügt von: xxxxxxxx
* Inhalt:
* xxx
*---------------------------------------------------------------------
FORM check_subst_kont
  USING    u_l_bseg_gsber                TYPE bseg-gsber
           u_l_bseg_prctr                TYPE bseg-prctr
           u_l_bseg_segment              TYPE bseg-segment
           u_l_vbseg_gsber               TYPE bseg-gsber
           u_l_vbseg_prctr               TYPE bseg-prctr
           u_l_vbseg_segment             TYPE bseg-segment
           u_l_vbseg_geber               TYPE bseg-geber
           u_l_vbseg_umskz               TYPE bseg-umskz
           u_l_bseg_koart                TYPE bseg-koart
           u_l_xauto                     TYPE bseg-xauto
           u_l_vbseg_bukrs               TYPE bseg-bukrs
  CHANGING c_l_result                    TYPE gtype_flag.

  DATA: l_funcname TYPE rs38l_fnam,
        l_geber    TYPE bseg-geber,
        l_gsber    TYPE bseg-gsber,
        l_prctr    TYPE bseg-prctr,
        l_segment  TYPE bseg-segment.

  c_l_result = space. "kein Fehlerfall

  l_geber    = u_l_vbseg_geber.
  l_gsber    = u_l_vbseg_gsber.
  l_prctr    = u_l_vbseg_prctr.
  l_segment  = u_l_vbseg_segment.


* Ermittlung aktuelles Customizing für Substitution
* Substitution erfolgt in BAdI AC_DOCUMENT (beim Vorerfassen)
* in Substitutionsinclude ZNSI_RGGBS000 beim Buchen.
  SELECT SINGLE fname INTO l_funcname
    FROM /thkr/cssubstbad
    WHERE bukrs EQ u_l_vbseg_bukrs.

  IF sy-subrc EQ 0.

    CALL FUNCTION l_funcname
      EXPORTING
        i_bukrs   = u_l_vbseg_bukrs
        i_koart   = u_l_bseg_koart
        i_umskz   = u_l_vbseg_umskz
      CHANGING
        c_geber   = l_geber
        c_gsber   = l_gsber
        c_prctr   = l_prctr
        c_segment = l_segment.

    IF u_l_bseg_prctr NE l_prctr OR
       u_l_bseg_gsber NE l_gsber OR
       u_l_bseg_segment NE l_segment.
      c_l_result = '1'. "ungleich
    ENDIF.
  ENDIF.

ENDFORM.  "check_subst_kont

*---------------------------------------------------------------------*
*       FORM get_buzei_post                                           *
*---------------------------------------------------------------------*
* Datum: 16.02.2009                 Eingefügt von: NSI-SCHA
*---------------------------------------------------------------------
* "echte" Buchungszeilen bei Buchung ermitteln,
* wenn Zeilen im vorerfassten Beleg gelöscht wurden
*
*---------------------------------------------------------------------
* Änderung:
* Datum: 00.00.0000                 Eingefügt von: xxxxxxxx
* Inhalt:
* xxx
*---------------------------------------------------------------------
FORM get_buzei_post
  USING    u_l_bukrs                     TYPE bkpf-bukrs
           u_l_belnr                     TYPE bkpf-belnr
           u_l_gjahr                     TYPE bkpf-gjahr
  CHANGING c_t_buzei                     TYPE gtype_t_buzei_v_post.


  TYPES: BEGIN OF ltype_bseg_small,
           bukrs TYPE bseg-bukrs,
           belnr TYPE bseg-belnr,
           gjahr TYPE bseg-gjahr,
           buzei TYPE bseg-buzei,
           wrbtr TYPE bseg-wrbtr,
         END OF ltype_bseg_small.

  DATA: lt_bseg_small   TYPE TABLE OF ltype_bseg_small,
        ls_bseg_small   TYPE ltype_bseg_small,
        l_buzei_empty   TYPE bseg-buzei,
        ls_buzei_v_post TYPE gtype_buzei_v_post.

  CLEAR: ls_bseg_small, lt_bseg_small, l_buzei_empty, ls_buzei_v_post.

* Ermittlung aller vorerfasster Buchungszeilen
  SELECT * FROM vbsega
    INTO CORRESPONDING FIELDS OF ls_bseg_small
    WHERE bukrs EQ u_l_bukrs
      AND belnr EQ u_l_belnr
      AND gjahr EQ u_l_gjahr.
    APPEND ls_bseg_small TO lt_bseg_small.
  ENDSELECT.

  SELECT * FROM vbsegd
    INTO CORRESPONDING FIELDS OF ls_bseg_small
    WHERE bukrs EQ u_l_bukrs
      AND belnr EQ u_l_belnr
      AND gjahr EQ u_l_gjahr.
    APPEND ls_bseg_small TO lt_bseg_small.
  ENDSELECT.

  SELECT * FROM vbsegk
    INTO CORRESPONDING FIELDS OF ls_bseg_small
    WHERE bukrs EQ u_l_bukrs
      AND belnr EQ u_l_belnr
      AND gjahr EQ u_l_gjahr.
    APPEND ls_bseg_small TO lt_bseg_small.
  ENDSELECT.

  SELECT * FROM vbsegs
    INTO CORRESPONDING FIELDS OF ls_bseg_small
    WHERE bukrs EQ u_l_bukrs
      AND belnr EQ u_l_belnr
      AND gjahr EQ u_l_gjahr.
    APPEND ls_bseg_small TO lt_bseg_small.
  ENDSELECT.

* Sortieren nach Buchungszeilennummer
  SORT lt_bseg_small BY buzei.

* Prüfen, ob "leere" Zeilen vorhanden sind und neue Zeile schreiben.
  LOOP AT lt_bseg_small INTO ls_bseg_small.

    ls_buzei_v_post-vbuzei = ls_bseg_small-buzei.
    ls_buzei_v_post-post_buzei = ls_bseg_small-buzei - l_buzei_empty.

    IF ls_bseg_small-wrbtr EQ 0.
      l_buzei_empty = l_buzei_empty + 1.
      ls_buzei_v_post-post_buzei = 0.
    ENDIF.

    APPEND ls_buzei_v_post TO c_t_buzei.

  ENDLOOP.


ENDFORM.  "get_buzei_post

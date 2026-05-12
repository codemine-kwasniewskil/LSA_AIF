FUNCTION /THKR/WF_4A_CHECK_PERMISSION.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      T_BKPF STRUCTURE  BKPF
*"      T_BSEG STRUCTURE  BSEG
*"      T_BSEC STRUCTURE  BSEC
*"  CHANGING
*"     REFERENCE(C_CHECKRESULT) TYPE  /THKR/DTE_WF_CHECKRESULT OPTIONAL
*"----------------------------------------------------------------------
************************************************************************
*                        NSI Baden-Württemberg                         *
************************************************************************
*  SAP-Release : 700                        EA-PS-Release: 600         *
*  Objektname  : Z_NSI_4A_2_CHECK_PERMISSION                           *
*  Objekttyp   :                                                       *
*  Autor       : Sven Schaarschmidt               User-ID: NSI-SCHA    *
*  Auftraggeber: Marcus Schellenberger            User-ID:             *
*  Erstelldatum: 02.04.2009              Transportauftrag: EL1K911832  *
*  Beschreibung: Erweiterung der 4-Augen-Prüfung mit Prüfung auf       *
*                - bestimmte Transaktionen (Tabellen ZNSI_4A_2_TAGRPx) *
*                - Nutzer (Tabellen ZNSI_4A_2_AWGRPx)                  *
*                - Kontenintervalle (Tabellen ZNSI_4A_2_KTOINx)        *
*                - flexible Prüfungen (Tabellen ZNSI_4A_2_FLEXGx)      *
*                Die Prüfungen greifen jeweils in Kombination, indem   *
*                die Prüfungsrelevanten Kriterien Vorgängen zugeordnet *
*                werden. Nur wenn die Bedingungen eines Vorgangs       *
*                (Zeile) erfült sind, ist eine Buchung ohne            *
*                Vier-Augen-Prinzip möglich.                           *
*                                                                      *
************************************************************************
*                          Änderungen                                  *
************************************************************************
*  Änd.-Nr.    :                               Änd.-Datum:             *
*  Nr. OP-Liste:                         Transportauftrag: EL1K912361  *
*  Bearbeiter  : Schaarschmidt                    User-ID: NSI-SCHA    *
*  Auftraggeber:                                  User-ID:             *
*  Beschreibung: Ermittlung der Vorgänge korrigiert                    *
*                                                                      *
************************************************************************
*  Änd.-Nr.    : 1                             Änd.-Datum: 04.06.2009  *
*  Nr. OP-Liste:                         Transportauftrag: EL1K912464  *
*                                                          EL1K912468  *
*                                                          EL1K912471  *
*                                                          EL1K912473  *
*  Bearbeiter  : Schaarschmidt                    User-ID: NSI-SCHA    *
*  Auftraggeber:                                  User-ID:             *
*  Beschreibung: Für die Transaktion FB05 wird auch geprüft für        *
*                SY-UCOMM gleich SPACE oder gleich 'PA', da bei dieser *
*                Transaktion, wenn "Buchen" in der Maske               *
*                "OP bearbeiten" betätigt wird der OK-Code SPACE oder  *
*                'PA' im BTE ankommt.                                  *
*                OP-Bearbeitung:                                       *
*                Dynprodaten ->  Dynpro SAPDF05X, Bildnr. 6102         *
*                GUI-Daten -> Programmname: SAPDF05X, Status: ZTC      *
*                                                                      *
************************************************************************
DATA:  t_tagrp       TYPE gtype_t_tagrp,
       t_awgrp       TYPE gtype_t_awgrp,
       t_ktoin       TYPE gtype_t_ktoin,
       t_flexg       TYPE gtype_t_flexg,
       t_vorga       TYPE gtype_t_vorga.


IF c_checkresult EQ '00' "noch kein Grund zur Freigabe gefunden
   AND (    sy-ucomm EQ 'BU'     "Vorgang "BU" (buchen)
         OR (    sy-tcode EQ 'FB05' AND "Änderung 1 vom 04.06.2009
               ( sy-ucomm EQ space      "Änderung 1 vom 04.06.2009
              OR sy-ucomm EQ 'PA' ) ) ).  "Änderung 1 vom 04.06.2009

  CLEAR: t_tagrp, t_awgrp, t_ktoin, t_flexg, t_vorga.

  PERFORM get_customizing_data
    USING      sy-ucomm
               sy-tcode
               sy-uname
               t_bkpf[]
    CHANGING   t_tagrp[]
               t_awgrp[]
               t_ktoin[]
               t_flexg[]
               t_vorga[].

  PERFORM check_permission
    USING      sy-ucomm
               sy-tcode
               sy-uname
               t_bkpf[]
               t_bseg[]
               t_bsec[]
               t_vorga[]
               t_awgrp[]
               t_ktoin[]
               t_flexg[]
    CHANGING   c_checkresult.


ENDIF.

ENDFUNCTION.

*---------------------------------------------------------------------*
*       FORM get_customizing_data                                     *
*---------------------------------------------------------------------*
* Datum: 02.04.2009                    Eingefügt von: NSI-SCHA
*---------------------------------------------------------------------
* Ermitteln, des Customizing zur Prüfung
*---------------------------------------------------------------------
* Änderung:
* Datum: 00.00.0000                 Eingefügt von: xxxxxxxx
* Inhalt:
* xxx
*---------------------------------------------------------------------
FORM get_customizing_data
  USING    u_l_syucomm            TYPE sy-ucomm
           u_l_sytcode            TYPE sy-tcode
           u_l_syuname            TYPE sy-uname
           u_t_bkpf               TYPE gtype_t_bkpf
  CHANGING c_t_tagrp              TYPE gtype_t_tagrp
           c_t_awgrp              TYPE gtype_t_awgrp
           c_t_ktoin              TYPE gtype_t_ktoin
           c_t_flexg              TYPE gtype_t_flexg
           c_t_vorga              TYPE gtype_t_vorga.

  DATA: ls_bkpf    TYPE bkpf,
        ls_tagrp   TYPE /THKR/C4A_tagrp2,
        ls_vorga   TYPE /THKR/C4A_vorga2,
        ls_flexg   TYPE /THKR/C4A_flexg2,
        ls_ktoin   TYPE /THKR/C4A_ktoin2,
        ls_awgrp   TYPE /THKR/C4A_awgrp2.


*  IF u_l_syucomm EQ 'BU'  "Nur beim Buchen prüfen! "Änderung 1/4.6.09

* Ermitteln der relevanten Transaktionsgruppen
    LOOP AT u_t_bkpf INTO ls_bkpf.

      SELECT * INTO CORRESPONDING FIELDS OF ls_tagrp
        FROM /THKR/C4A_tagrp2.

        CHECK ( u_l_sytcode CP ls_tagrp-tcode OR
                ls_bkpf-tcode CP ls_tagrp-tcode ).

        APPEND ls_tagrp TO c_t_tagrp.

      ENDSELECT.

    ENDLOOP.

* Ermitteln der relevanten Vorgänge aus den Transaktionsgruppen
    LOOP AT c_t_tagrp INTO ls_tagrp.

      SELECT * INTO ls_vorga                   "EL1K912361
        FROM /THKR/C4A_vorga2
        WHERE tagrp  EQ ls_tagrp-tagrp
          AND cpuvon LE sy-datum   " Gültigkeitszeitraum
          AND cpubis GE sy-datum.

        APPEND ls_vorga TO c_t_vorga.         "EL1K912361

      ENDSELECT.

    ENDLOOP.
    CLEAR: ls_vorga.                          "EL1K912361

* Ermitteln der relevanten Vorgänge aus den Transaktionsgruppen
    LOOP AT c_t_vorga INTO ls_vorga.

      SELECT * INTO CORRESPONDING FIELDS OF ls_awgrp
        FROM /THKR/C4A_awgrp2
        WHERE awgrp  EQ ls_vorga-awgrp
          AND cpuvon LE sy-datum   " Gültigkeitszeitraum
          AND cpubis GE sy-datum.

        APPEND ls_awgrp TO c_t_awgrp.

      ENDSELECT.

      SELECT * INTO CORRESPONDING FIELDS OF ls_flexg
        FROM /THKR/C4A_flexg2
        WHERE flexg  EQ ls_vorga-flexg
          AND cpuvon LE sy-datum   " Gültigkeitszeitraum
          AND cpubis GE sy-datum.

        APPEND ls_flexg TO c_t_flexg.

      ENDSELECT.

      SELECT * INTO CORRESPONDING FIELDS OF ls_ktoin
        FROM /THKR/C4A_ktoin2
        WHERE ktoint EQ ls_vorga-ktoint.

        APPEND ls_ktoin TO c_t_ktoin.

      ENDSELECT.

    ENDLOOP.

*  ENDIF. "Änderung 1/4.6.09

ENDFORM.     "get_customizing_data

*---------------------------------------------------------------------*
*       FORM check_permission                                         *
*---------------------------------------------------------------------*
* Datum: 02.04.2009                    Eingefügt von: NSI-SCHA
*---------------------------------------------------------------------
* Prüfen der Berechtigung
*---------------------------------------------------------------------
* Änderung:
* Datum: 00.00.0000                 Eingefügt von: xxxxxxxx
* Inhalt:
* xxx
*---------------------------------------------------------------------
FORM check_permission
  USING    u_l_syucomm            TYPE sy-ucomm
           u_l_sytcode            TYPE sy-tcode
           u_l_syuname            TYPE sy-uname
           u_t_bkpf               TYPE gtype_t_bkpf
           u_t_bseg               TYPE gtype_t_bseg
           u_t_bsec               TYPE gtype_t_bsec
           u_t_vorga              TYPE gtype_t_vorga
           u_t_awgrp              TYPE gtype_t_awgrp
           u_t_ktoin              TYPE gtype_t_ktoin
           u_t_flexg              TYPE gtype_t_flexg
  CHANGING c_l_checkresult        TYPE gtype_checkresult.


  DATA: l_bkpf      TYPE bkpf,
        l_vorga     TYPE /THKR/C4A_vorga2,
        l_awgrp     TYPE /THKR/C4A_awgrp2.

  IF c_l_checkresult EQ '00'.

*   Vorgänge prüfen
    LOOP AT u_t_vorga INTO l_vorga.

      CHECK c_l_checkresult NE '95'. "Wurde 95 bereits in vorher
                                     "gehendem Durchlauf gesetzt,
                                     "ist die Buchung erlaubt.
                                     "Keine weitere Prüfung nötig.

*   Prüfung für jeden Beleg durchführen.
      LOOP AT u_t_bkpf INTO l_bkpf.

        PERFORM check_permission_awgrp
          USING u_l_syuname
                l_bkpf
                u_t_awgrp[]
                l_vorga-awgrp
          CHANGING c_l_checkresult.

        PERFORM check_permission_ktoin
          USING l_bkpf
                u_t_bseg[]
                u_t_ktoin[]
                l_vorga-ktoint
          CHANGING c_l_checkresult.

        PERFORM check_permission_flexg_top
          USING l_bkpf
                u_t_bseg[]
                u_t_bsec[]
                u_t_flexg[]
                l_vorga-flexg
          CHANGING c_l_checkresult.

      ENDLOOP.

      IF c_l_checkresult(1) EQ '2'.
        c_l_checkresult = '00'. "Aufgrund von Prüfungen wurde Beleg
                              "nicht für direkte Buchung zugelassen
      ELSE.
        c_l_checkresult = '95'. "Buchungsfreigabe für den Beleg ist
                              "gegeben worde, da kein Ablehnungsgrund
                              "gefunden wurde
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.     "check_permission

*---------------------------------------------------------------------*
*       FORM check_permission_awgrp                                   *
*---------------------------------------------------------------------*
* Datum: 06.04.2009                    Eingefügt von: NSI-SCHA
*---------------------------------------------------------------------
* Prüfen der Berechtigung
*---------------------------------------------------------------------
* Änderung:
* Datum: 00.00.0000                 Eingefügt von: xxxxxxxx
* Inhalt:
* xxx
*---------------------------------------------------------------------
FORM check_permission_awgrp
  USING    u_l_syuname            TYPE sy-uname
           u_l_bkpf               TYPE bkpf
           u_t_awgrp              TYPE gtype_t_awgrp
           u_l_awgrp              TYPE /THKR/DTE_WF_awgrp
  CHANGING c_l_checkresult        TYPE gtype_checkresult.

  DATA: r_uname_chk  TYPE RANGE OF bkpf-usnam,
        rl_uname_chk LIKE LINE OF r_uname_chk,
        r_uname_sel  TYPE RANGE OF bkpf-usnam,
        rl_uname_sel LIKE LINE OF r_uname_sel,
        l_awgrp      TYPE /THKR/C4A_awgrp2,
        l_uname      TYPE usr02-bname.

* Range zum Prüfen löschen für erneuten Aufbau
  CLEAR: r_uname_chk.

* Aufbau der Range für die erlaubten User.
  LOOP AT u_t_awgrp INTO l_awgrp.

    IF l_awgrp-awgrp EQ u_l_awgrp. "Nutzergruppe gleich

      IF l_awgrp-cpuvon LE sy-datum AND
         l_awgrp-cpubis GE sy-datum. "Gültigkeit zeitlich

        IF l_awgrp-userclass NE space. "Nutzergruppe vorhanden

          "Range für Selektion aufbauen
          CLEAR: r_uname_sel.
          IF l_awgrp-userbis EQ space.
            IF l_awgrp-uservon CA '*+' OR l_awgrp-uservon EQ space.
              l_awgrp-uservon = '*'.
              rl_uname_sel-option = 'CP'.
            ELSE.
              rl_uname_sel-option = 'EQ'.
            ENDIF.
          ELSE.
            rl_uname_sel-option = 'BT'.
          ENDIF.
          rl_uname_sel-sign = 'I'.
          rl_uname_sel-low = l_awgrp-uservon.
          rl_uname_sel-high = l_awgrp-userbis.
          APPEND rl_uname_sel TO r_uname_sel.

          "Range für Check aufbauen
          rl_uname_chk-sign = 'I'.
          rl_uname_chk-option = 'EQ'.
          rl_uname_chk-high = space.

          SELECT bname INTO l_uname  "User muss in Wertebereich
            FROM usr02               "und Nutzergruppe passen. "#EC CI_GENBUFF
            WHERE bname IN r_uname_sel
              AND class EQ l_awgrp-userclass.

            rl_uname_chk-low = l_uname.
            APPEND rl_uname_chk TO r_uname_chk.

          ENDSELECT.

        ELSE. "Nutzergruppe vorhanden

          "Range für Check aufbauen
          IF l_awgrp-userbis EQ space.
            IF l_awgrp-uservon CA '*+'.
              rl_uname_chk-option = 'CP'.
            ELSE.
              rl_uname_chk-option = 'EQ'.
            ENDIF.
          ELSE.
            rl_uname_chk-option = 'BT'.
          ENDIF.
          rl_uname_chk-sign = 'I'.
          rl_uname_chk-low = l_awgrp-uservon.
          rl_uname_chk-high = l_awgrp-userbis.
          APPEND rl_uname_chk TO r_uname_chk.

        ENDIF. "Nutzergruppe vorhanden

      ENDIF. "Gültigkeit zeitlich

    ENDIF.  "Nutzergruppe gleich

  ENDLOOP.

* Jetzt prüfen, ob der User auch berechtigt ist.
  IF u_l_bkpf-usnam IN r_uname_chk.
    "do nothing
  ELSE.
    c_l_checkresult = '21'.
    "User im Beleg nicht berechtigt für sofortige Buchung
  ENDIF.

ENDFORM.     "check_permission_awgrp


*---------------------------------------------------------------------*
*       FORM check_permission_ktoin                                   *
*---------------------------------------------------------------------*
* Datum: 06.04.2009                    Eingefügt von: NSI-SCHA
*---------------------------------------------------------------------
* Prüfen der Berechtigung
*---------------------------------------------------------------------
* Änderung:
* Datum: 00.00.0000                 Eingefügt von: xxxxxxxx
* Inhalt:
* xxx
*---------------------------------------------------------------------
FORM check_permission_ktoin
  USING    u_l_bkpf               TYPE bkpf
           u_t_bseg               TYPE gtype_t_bseg
           u_t_ktoin              TYPE gtype_t_ktoin
           u_l_ktoint             TYPE /THKR/DTE_WF_ktoint
  CHANGING c_l_checkresult        TYPE gtype_checkresult.

  DATA: r_ktoin_chk  TYPE RANGE OF agkon,
        rl_ktoin_chk LIKE LINE OF r_ktoin_chk,
        l_ktoin      TYPE /THKR/C4A_ktoin2,
        l_bseg       TYPE bseg,
        l_strlen     TYPE i,
        l_stat_d     TYPE gtype_flag VALUE '0',"0 nicht gepr., 9_erlaubt
        l_stat_k     TYPE gtype_flag VALUE '0',"0 nicht gepr., 9_erlaubt
        l_stat_s     TYPE gtype_flag VALUE '0',"0 nicht gepr., 9_erlaubt
        l_koarten    TYPE c LENGTH 3 VALUE space. "Koart im Beleg

  LOOP AT u_t_ktoin INTO l_ktoin
    WHERE ktoint EQ u_l_ktoint.

    l_strlen = strlen( l_ktoin-ktovon ).
    WHILE l_strlen LT 10
      AND l_ktoin-ktovon(l_strlen) CO '0123456789'.
      SHIFT l_ktoin-ktovon RIGHT BY 1 PLACES.
      l_ktoin-ktovon(1) = '0'.
      l_strlen = strlen( l_ktoin-ktovon ).
    ENDWHILE.

    IF l_ktoin-ktobis NE space.
      l_strlen = strlen( l_ktoin-ktobis ).
      WHILE l_strlen LT 10
        AND l_ktoin-ktobis(l_strlen) CO '0123456789'.
        SHIFT l_ktoin-ktobis RIGHT BY 1 PLACES.
        l_ktoin-ktobis(1) = '0'.
        l_strlen = strlen( l_ktoin-ktobis ).
      ENDWHILE.
    ENDIF.

    "Range für check aufbauen.
    "Jeden Eintrag einzeln prüfen, weil unt. Kontoarten.
    CLEAR: r_ktoin_chk.
    rl_ktoin_chk-sign = 'I'.
    IF l_ktoin-ktobis EQ space.
      IF l_ktoin-ktovon CA '*+'.
        rl_ktoin_chk-option = 'CP'.
      ELSE.
        rl_ktoin_chk-option = 'EQ'.
      ENDIF.
    ELSE.
      rl_ktoin_chk-option = 'BT'.
    ENDIF.
    rl_ktoin_chk-low = l_ktoin-ktovon.
    rl_ktoin_chk-high = l_ktoin-ktobis.
    APPEND rl_ktoin_chk TO r_ktoin_chk.

    "Prüfen des Beleges
    LOOP AT u_t_bseg INTO l_bseg
      WHERE bukrs EQ u_l_bkpf-bukrs AND
            belnr EQ u_l_bkpf-belnr AND
            gjahr EQ u_l_bkpf-gjahr.

      CHECK l_bseg-wrbtr NE 0.

      IF l_koarten NA l_bseg-koart.
        CONCATENATE l_koarten l_bseg-koart INTO l_koarten.
      ENDIF.

      IF l_bseg-koart EQ l_ktoin-koart. "nur bei gleicher Kontoart

        CASE l_bseg-koart. "unt. Prüfungen je Kontoart
          WHEN 'S' OR 'M'.
            IF l_bseg-hkont IN r_ktoin_chk.
              l_stat_s = '1'.  "erlaubt
            ELSE.
              IF l_stat_s EQ '0'.
                l_stat_s = '9'. "nicht erlaubt (Sachkonto)
              ENDIF.
            ENDIF.

          WHEN 'D'.
            IF l_bseg-kunnr IN r_ktoin_chk.
              l_stat_d = '1'.  "erlaubt
            ELSE.
              IF l_stat_d EQ '0'.
                l_stat_d = '9'. "nicht erlaubt (Sachkonto)
              ENDIF.
            ENDIF.

          WHEN 'K'.
            IF l_bseg-lifnr IN r_ktoin_chk.
              l_stat_k = '1'.  "erlaubt
            ELSE.
              IF l_stat_k EQ '0'.
                l_stat_k = '9'. "nicht erlaubt (Sachkonto)
              ENDIF.
            ENDIF.

          WHEN OTHERS.
            "do nothing
            "Kontoarten M und A werden aktuell nicht behandelt.

         ENDCASE.

       ENDIF.

    ENDLOOP.

  ENDLOOP.

  IF ( l_stat_s EQ '9' OR l_stat_s EQ '0' )
     AND c_l_checkresult(1) NE '2'
     AND l_koarten CA 'S'.
    c_l_checkresult = '22'. "Sachkonto nicht erlaubt
  ENDIF.
  IF ( l_stat_d EQ '9' OR l_stat_d EQ '0' )
     AND c_l_checkresult(1) NE '2'
     AND l_koarten CA 'D'.
    c_l_checkresult = '23'. "Debitor nicht erlaubt
  ENDIF.
  IF ( l_stat_k EQ '9' OR l_stat_k EQ '0' )
     AND c_l_checkresult(1) NE '2'
     AND l_koarten CA 'K'.
    c_l_checkresult = '24'. "Kreditor nicht erlaubt
  ENDIF.

ENDFORM.     "check_permission_ktoin

*---------------------------------------------------------------------*
*       FORM check_permission_ flexg_top                              *
*---------------------------------------------------------------------*
* Datum: 07.04.2009                    Eingefügt von: NSI-SCHA
*---------------------------------------------------------------------
* Prüfen der Berechtigung
*---------------------------------------------------------------------
* Änderung:
* Datum: 00.00.0000                 Eingefügt von: xxxxxxxx
* Inhalt:
* xxx
*---------------------------------------------------------------------
  FORM check_permission_flexg_top
    USING u_l_bkpf TYPE bkpf
          u_t_bseg TYPE gtype_t_bseg
          u_t_bsec TYPE gtype_t_bsec
          u_t_flexg TYPE gtype_t_flexg
          u_l_flexg TYPE /THKR/DTE_WF_flexgruppe
    CHANGING c_l_checkresult TYPE /THKR/DTE_WF_checkresult.

    TYPES: BEGIN OF ltype_fieldstatus,
             tabname   TYPE tabname,
             fieldname TYPE name_komp,
             status    TYPE gtype_flag,
           END OF ltype_fieldstatus,

           ltype_t_fieldstatus TYPE TABLE OF ltype_fieldstatus.

    DATA: l_bseg          TYPE bseg,
          l_bsec          TYPE bsec,
          l_flexg         TYPE /THKR/C4A_flexg2,
          l_result        TYPE /THKR/DTE_WF_checkresult VALUE '00',
          l_flag_bsec     TYPE gtype_flag VALUE space,
          l_f_fieldstatus TYPE ltype_fieldstatus,
          l_t_fieldstatus TYPE ltype_t_fieldstatus,
              "0 = ungeprüft, 1 = prüfung erfolglos, 9 = buchen erlaubt
          l_field_exist   TYPE gtype_flag.
              " space = nicht vorhanden(neu); X = vorhanden.

    LOOP AT u_t_flexg INTO l_flexg
      WHERE flexg  EQ u_l_flexg
        AND cpuvon LE sy-datum
        AND cpubis GE sy-datum.

      READ TABLE l_t_fieldstatus WITH KEY "Feld schon geprüft?
        tabname   = l_flexg-tablename
        fieldname = l_flexg-fieldname
        INTO l_f_fieldstatus.

      IF sy-subrc NE space. "Setzen des aktuellen Status
        l_f_fieldstatus-tabname   = l_flexg-tablename.
        l_f_fieldstatus-fieldname = l_flexg-fieldname.
        l_f_fieldstatus-status    = 0.
        l_field_exist = space.
      ELSE.
        l_field_exist = 'X'.
      ENDIF.

      LOOP AT u_t_bseg INTO l_bseg
        WHERE bukrs EQ u_l_bkpf-bukrs
          AND belnr EQ u_l_bkpf-belnr
          AND gjahr EQ u_l_bkpf-gjahr.

        IF l_flexg-tablename EQ 'BKPF'. "passt Kopf zur Prüfung?
          CHECK l_flexg-logik EQ '0K'.
        ENDIF.
        IF l_flexg-tablename EQ 'BSEG'. "passt Koart zur Prüfung?
          CHECK ( l_flexg-logik(1) EQ 'D' AND l_bseg-koart EQ 'D' ) OR
                ( l_flexg-logik(1) EQ 'K' AND l_bseg-koart EQ 'K' ) OR
                ( l_flexg-logik(1) EQ 'S' AND l_bseg-koart EQ 'S' ) OR
                ( l_flexg-logik(1) EQ 'A' AND l_bseg-koart EQ 'A' ) OR
                  l_flexg-logik(1) EQ '0'.
        ENDIF.
        IF l_flexg-tablename EQ 'BSEC'. "passt Koart zur Prüfung?
          CHECK ( l_flexg-logik(1) EQ 'D' AND l_bseg-koart EQ 'D' ) OR
                ( l_flexg-logik(1) EQ 'K' AND l_bseg-koart EQ 'K' ) OR
                  l_flexg-logik(1) EQ '0'.
        ENDIF.

        READ TABLE u_t_bsec INTO l_bsec
          WITH KEY bukrs = l_bseg-bukrs
                   belnr = l_bseg-belnr
                   gjahr = l_bseg-gjahr
                   buzei = l_bseg-buzei.

        IF sy-subrc EQ 0.
          l_flag_bsec = 'X'.
        ELSE.
          CLEAR: l_bsec.
          l_flag_bsec = space.
        ENDIF.

        PERFORM check_permission_flexg_001
          USING l_flexg    "Prüfung des Feldes.
                u_l_bkpf
                l_bseg
                l_bsec
                l_flag_bsec
          CHANGING l_result.

        CASE l_f_fieldstatus-tabname.
          WHEN 'BKPF'.
            IF l_result EQ '00'. "Prüfergebnis umsetzen
              l_f_fieldstatus-status = '9'. "erfolgreich
            ELSE.
              IF l_f_fieldstatus-status NE '9'.
                l_f_fieldstatus-status = '1'. "nicht erfolgreich
              ENDIF.
            ENDIF.

          WHEN 'BSEG'.
            IF l_flexg-logik(2) EQ '0'. "Alle Zeilen müssen passen
              IF l_result EQ '00' AND l_f_fieldstatus-status NE '1'.
                l_f_fieldstatus-status = '9'. "erfolgreich.
              ELSE.
                l_f_fieldstatus-status = '1'. "nicht erfolgreich.
              ENDIF.
            ELSE.
              IF l_result EQ '00'.
                l_f_fieldstatus-status = '9'. "erfolgreich.
              ELSE.
                IF l_f_fieldstatus-status NE '9'. "nicht wenn schon ok
                  l_f_fieldstatus-status = '1'. "nicht erfolgreich.
                ENDIF.
              ENDIF.
            ENDIF.

          WHEN 'BSEC'.
            IF l_flag_bsec EQ 'X'.
              IF l_flexg-logik(2) EQ '0'. "Alle Zeilen müssen passen
                IF l_result EQ '00' AND l_f_fieldstatus-status NE '1'.
                  l_f_fieldstatus-status = '9'. "erfolgreich.
                ELSE.
                  l_f_fieldstatus-status = '1'. "nicht erfolgreich.
                ENDIF.
              ELSE.
                IF l_result EQ '00'.
                  l_f_fieldstatus-status = '9'. "erfolgreich.
                ELSE.
                  IF l_f_fieldstatus-status NE '9'. "nicht wenn schon ok
                    l_f_fieldstatus-status = '1'. "nicht erfolgreich.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

          WHEN OTHERS.
             "nicht definiert, kann nach Tabelle nicht vorkommen

        ENDCASE.


        IF l_field_exist EQ space. "Prüfergebnis ablegen
          APPEND l_f_fieldstatus TO l_t_fieldstatus.
          l_field_exist = 'X'.
        ELSE.
          MODIFY TABLE l_t_fieldstatus FROM l_f_fieldstatus.
        ENDIF.

      ENDLOOP. "bseg

    ENDLOOP. "u_t_flexg

    READ TABLE l_t_fieldstatus  "fehlerhafte herausfinden
      WITH KEY status = '1'
      TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0 AND c_l_checkresult(1) NE '2'.
      c_l_checkresult = '25'. "flexible Prüfung nicht erfolgreich
    ENDIF.

  ENDFORM.

*---------------------------------------------------------------------*
*       FORM check_permission_flexg_001                               *
*---------------------------------------------------------------------*
* Datum: 07.04.2009                    Eingefügt von: NSI-SCHA
*---------------------------------------------------------------------
* Prüfen der Berechtigung
*---------------------------------------------------------------------
* Änderung:
* Datum: 00.00.0000                 Eingefügt von: xxxxxxxx
* Inhalt:
* xxx
*---------------------------------------------------------------------
FORM check_permission_flexg_001
  USING u_l_flexg     TYPE /THKR/C4A_flexg2
        u_l_bkpf      TYPE bkpf
        u_l_bseg      TYPE bseg
        u_l_bsec      TYPE bsec
        u_l_flag_bsec TYPE gtype_flag
  CHANGING c_l_result TYPE /THKR/DTE_WF_checkresult.

  DATA: BEGIN OF lf_range, "Struktur zum Füllen der Range auf flexg
          sign   TYPE /THKR/C4A_flexg2-sign,
          option TYPE /THKR/C4A_flexg2-soption,
          low    TYPE /THKR/C4A_flexg2-low,
          high   TYPE /THKR/C4A_flexg2-high,
        END OF lf_range.
  DATA: l_position TYPE dd03l-position,
        l_ref_post TYPE REF TO data. "new 08.04.2009

  FIELD-SYMBOLS: <lf_field_post>  TYPE any,
                 <lf_struct_post> TYPE any.

* >>> Start: Mit freundlicher Unterstützung von Andreas Loch.
  TYPE-POOLS:
  abap.

  DATA:
    g_type         TYPE dd03l-rollname,
    g_dref         TYPE REF TO data,
    gf_component   TYPE abap_componentdescr,
    gt_components  TYPE abap_component_tab,
    go_structdescr TYPE REF TO cl_abap_structdescr,
    go_tabledescr  TYPE REF TO cl_abap_tabledescr,
    go_datadescr   TYPE REF TO cl_abap_datadescr.

  FIELD-SYMBOLS:
    <gf_range>     TYPE ANY,
    <gr_range>     TYPE INDEX TABLE.

*  PARAMETERS:
*    p_table        TYPE dd02d-dbtabname,
*    p_field        TYPE dd03d-fieldname.

*  START-OF-SELECTION.

    SELECT SINGLE rollname "#EC CI_NOORDER
           INTO g_type
           FROM dd03l
           WHERE tabname   EQ u_l_flexg-tablename AND
                 fieldname EQ u_l_flexg-fieldname.
    CHECK sy-subrc IS INITIAL.

*   Komponenten der Range-Struktur -> GT_COMPONENTS
    MOVE 'SIGN' TO gf_component-name.
    gf_component-type ?= cl_abap_elemdescr=>get_c( p_length = 1 ).
    INSERT gf_component INTO TABLE gt_components.

    MOVE 'OPTION' TO gf_component-name.
    gf_component-type ?= cl_abap_elemdescr=>get_c( p_length = 2 ).
    INSERT gf_component INTO TABLE gt_components.

    MOVE 'LOW' TO gf_component-name.
    gf_component-type ?= cl_abap_elemdescr=>describe_by_name( g_type ).
    INSERT gf_component INTO TABLE gt_components.

    MOVE 'HIGH' TO gf_component-name.
    gf_component-type ?= cl_abap_elemdescr=>describe_by_name( g_type ).
    INSERT gf_component INTO TABLE gt_components.

*   Range-Struktur erzeugen -> <GF_RANGE>
    go_structdescr ?= cl_abap_structdescr=>create( gt_components ).
    CREATE DATA g_dref TYPE HANDLE go_structdescr.
    ASSIGN g_dref->* TO <gf_range>.

*   Range-Tabelle erzeugen -> <GR_RANGE>
    go_datadescr ?= go_structdescr.
    go_tabledescr ?= cl_abap_tabledescr=>create( go_datadescr ).
    CREATE DATA g_dref TYPE HANDLE go_tabledescr.
    ASSIGN g_dref->* TO <gr_range>.

* <<< Ende: Mit freundlicher Unterstützung von Andreas Loch

    MOVE-CORRESPONDING u_l_flexg TO lf_range.
    MOVE u_l_flexg-soption TO lf_range-option.

    MOVE-CORRESPONDING lf_range TO <gf_range>.
    APPEND <gf_range> TO <gr_range>.


* Feld ermitteln
    SELECT SINGLE position INTO l_position "#EC CI_NOORDER
      FROM dd03l
      WHERE tabname EQ u_l_flexg-tablename
        AND fieldname EQ u_l_flexg-fieldname.
    CHECK sy-subrc IS INITIAL.
    CHECK u_l_flexg-tablename EQ 'BSEG' OR "Nur Belegfelder prüfen.
          u_l_flexg-tablename EQ 'BSEC' OR
          u_l_flexg-tablename EQ 'BKPF'.


    CREATE DATA l_ref_post TYPE (u_l_flexg-tablename). "new 08.04.2009
    CASE u_l_flexg-tablename.

      WHEN 'BSEG'.
        ASSIGN u_l_bseg TO <lf_struct_post>.
        MOVE-CORRESPONDING u_l_bseg TO <lf_struct_post>.

      WHEN 'BSEC'.
        ASSIGN u_l_bsec TO <lf_struct_post>.
        MOVE-CORRESPONDING u_l_bsec TO <lf_struct_post>.

      WHEN 'BKPF'.
        ASSIGN l_ref_post->* TO <lf_struct_post>. "new 08.04.2009
*        ASSIGN u_l_bsec TO <lf_struct_post>. "new 08.04.2009
        MOVE-CORRESPONDING u_l_bkpf TO <lf_struct_post>.

    ENDCASE.

    ASSIGN COMPONENT l_position OF STRUCTURE <lf_struct_post>
          TO <lf_field_post>.

* Vergleichen
    IF <lf_field_post> IN <gr_range>.
      c_l_result = '00'.  "Prüfung erfolgreich
    ELSE.
      IF u_l_flexg-tablename EQ 'BSEC' AND u_l_flag_bsec EQ space.
        "do nothing
      ELSE.
        c_l_result = '99'.  "Prüfung nicht erfolgreich
      ENDIF.
    ENDIF.

ENDFORM. "check_permission_flexg_001

*----------------------------------------------------------------------*
*   INCLUDE IHHPLDYH                                                   *
*----------------------------------------------------------------------*

*------------- Konstanten ----------------------------------------------
  CONSTANTS CON_DUMMY_HST(24) VALUE 'XXXXXXXXXXXXXXXXXXXXXXXX'.

*------------- Ende Konstanten -----------------------------------------

*-------------- Feldsymbole --------------------------------------------

* "/ Field-Symbols fuer dynamische HHStellen-Struktur.
  FIELD-SYMBOLS: <PRAEFIX>,
                  <GLD>, <EPL>, <ABSCHN>, <UABSCH>,
                  <GRUPPE>, <HGR>, <GRP>, <UGR>,
                  <MASS>, <HMASS>, <MASSN>, <UMASS>,
                  <OBJ>,
                  <PRUEFZ>.

*-------------- Ende Feldsymbole ---------------------------------------

*--------------- Globale Variablen / Felder ----------------------------
  "/ Puffer fuer dynamische HHStellen

* data g_fsfipex like ifmhhpl-fipex.
 DATA G_FSFIPEX LIKE FMPG-FIPEX.

* "/ Feld fuer die Laengen der Teilelemente
  DATA : BEGIN OF G_F_FMHHST_LEN,
         PRAEFIX_LEN TYPE I,
         GLD_LEN TYPE I,
         EPL_LEN TYPE I,
         ABSCHN_LEN TYPE I,
         UABSCH_LEN TYPE I,
         GRUPPE_LEN TYPE I,
         HGR_LEN TYPE I,
         GRP_LEN TYPE I,
         UGR_LEN TYPE I,
         MASS_LEN TYPE I,
         HMASS_LEN TYPE I,
         MASSN_LEN TYPE I,
         UMASS_LEN TYPE I,
         OBJ_LEN TYPE I,
         PRUEFZ_LEN TYPE I,
      END OF G_F_FMHHST_LEN.

* "/ Feld fuer die Position der Teilelemente
  DATA : BEGIN OF G_F_FMHHST_POS,
         PRAEFIX TYPE I,
         GLD TYPE I,
         EPL TYPE I,
         ABSCHN TYPE I,
         UABSCH TYPE I,
         GRUPPE TYPE I,
         HGR TYPE I,
         GRP TYPE I,
         UGR TYPE I,
         MASS TYPE I,
         HMASS TYPE I,
         MASSN TYPE I,
         UMASS TYPE I,
         OBJ TYPE I,
         PRUEFZ TYPE I,
      END OF G_F_FMHHST_POS.

  DATA: BEGIN OF G_F_FMHHST_DEFAULT,
          PRAEFIX LIKE IFMHHST-PRAEFIX,
          GLD LIKE IFMHHST-GLD,
          EPL LIKE IFMHHST-EPL,
          ABSCHN LIKE IFMHHST-ABSCHN,
          UABSCH LIKE IFMHHST-UABSCH,
          GRUPPE LIKE IFMHHST-GRUPPE,
          HGR LIKE IFMHHST-HGR,
          GRP LIKE IFMHHST-GRP,
          UGR LIKE IFMHHST-UGR,
          MASS LIKE IFMHHST-MASS,
          HMASS LIKE IFMHHST-HMASS,
          MASSN LIKE IFMHHST-MASSN,
          UMASS LIKE IFMHHST-UMASS,
          OBJ LIKE IFMHHST-OBJ,
          PRUEFZ LIKE IFMHHST-PRUEFZ,
        END OF G_F_FMHHST_DEFAULT.

*--------- Ende Globale Variablen / Felder -----------------------------

*&---------------------------------------------------------------------*
*&      Form  INIT_DYN_HHST
*&---------------------------------------------------------------------*
*     Initialisieren der Haushaltsstellenstruktur.                     *
*----------------------------------------------------------------------*
  FORM INIT_DYN_HHST.

* "/ Datendeklaration
    TABLES FMDYNHST.

    DATA : BEGIN OF L_T_FMDYNHST OCCURS 20.
            INCLUDE STRUCTURE FMDYNHST.
    DATA : END OF L_T_FMDYNHST.

    DATA : L_FLG_DYNHST, L_FLG_GLD, L_FLG_EPL, L_FLG_ABSCHN,
           L_FLG_UABSCH, L_FLG_GRUPPE, L_FLG_HGR, L_FLG_GRP,
           L_FLG_UGR, L_FLG_MASS, L_FLG_HMASS, L_FLG_MASSN,
           L_FLG_UMASS, L_FLG_OBJ.

    DATA : L_FLG_SUCCESS VALUE 'X'.

    DATA : L_PRAEFIX TYPE I, L_PRAEFIX_LEN TYPE I,
           L_GLD TYPE I, L_GLD_LEN TYPE I,
           L_EPL TYPE I, L_EPL_LEN TYPE I,
           L_ABSCHN TYPE I, L_ABSCHN_LEN TYPE I,
           L_UABSCH TYPE I, L_UABSCH_LEN TYPE I,
           L_GRUPPE TYPE I, L_GRUPPE_LEN TYPE I,
           L_HGR TYPE I, L_HGR_LEN TYPE I,
           L_GRP TYPE I, L_GRP_LEN TYPE I,
           L_UGR TYPE I, L_UGR_LEN TYPE I,
           L_MASS TYPE I, L_MASS_LEN TYPE I,
           L_HMASS TYPE I, L_HMASS_LEN TYPE I,
           L_MASSN TYPE I, L_MASSN_LEN TYPE I,
           L_UMASS TYPE I, L_UMASS_LEN TYPE I,
           L_OBJ TYPE I, L_OBJ_LEN TYPE I,
           L_PRUEFZ TYPE I, L_PRUEFZ_LEN TYPE I.

* "/ Initialisierungen
    CLEAR : L_FLG_DYNHST, L_FLG_GLD, L_FLG_EPL, L_FLG_ABSCHN,
           L_FLG_UABSCH, L_FLG_GRUPPE, L_FLG_HGR, L_FLG_GRP,
           L_FLG_UGR, L_FLG_MASS, L_FLG_HMASS, L_FLG_MASSN,
           L_FLG_UMASS, L_FLG_OBJ.

    CLEAR G_F_FMHHST_LEN.

* "/ Einlesen der Pflegeviewdaten in interne Tabelle.
    SELECT * INTO TABLE L_T_FMDYNHST FROM FMDYNHST.
    IF SY-SUBRC = 0.
* "/ Lesen der einzelnen Teilemente.

* "/ Praefix
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'PRAEFIX'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_PRAEFIX = L_T_FMDYNHST-STARTPOS - 1.
          L_PRAEFIX_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

* "/ organisatorische Gliederung
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'GLD'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_FLG_GLD = 'X'.
          L_GLD = L_T_FMDYNHST-STARTPOS - 1.
          L_GLD_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

* "/ Einzelplan
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'EPL'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_FLG_EPL = 'X'.
          L_EPL = L_T_FMDYNHST-STARTPOS - 1.
          L_EPL_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

* "/ Abschnitt
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'ABSCHN'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_FLG_ABSCHN = 'X'.
          L_ABSCHN = L_T_FMDYNHST-STARTPOS - 1.
          L_ABSCHN_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

* "/ Unterabschnitt
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'UABSCH'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_FLG_UABSCH = 'X'.
          L_UABSCH = L_T_FMDYNHST-STARTPOS - 1.
          L_UABSCH_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

* "/ sachliche Gliederung
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'GRUPPE'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_FLG_GRUPPE = 'X'.
          L_GRUPPE = L_T_FMDYNHST-STARTPOS - 1.
          L_GRUPPE_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

* "/ Hauptgruppe
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'HGR'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_FLG_HGR = 'X'.
          L_HGR = L_T_FMDYNHST-STARTPOS - 1.
          L_HGR_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

* "/ Gruppe
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'GRP'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_FLG_GRP = 'X'.
          L_GRP = L_T_FMDYNHST-STARTPOS - 1.
          L_GRP_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

* "/ Untergruppe
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'UGR'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_FLG_UGR = 'X'.
          L_UGR = L_T_FMDYNHST-STARTPOS - 1.
          L_UGR_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

 "/ Massnahme
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'MASS'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_FLG_MASS = 'X'.
          L_MASS = L_T_FMDYNHST-STARTPOS - 1.
          L_MASS_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

* "/ Haupt-Massnahme
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'HMASS'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_FLG_HMASS = 'X'.
          L_HMASS = L_T_FMDYNHST-STARTPOS - 1.
          L_HMASS_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

* "/ Massnahme ( Teilelement)
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'MASSN'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_FLG_MASSN = 'X'.
          L_MASSN = L_T_FMDYNHST-STARTPOS - 1.
          L_MASSN_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

* "/ Unter-Massnahme
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'UMASS'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_FLG_UMASS = 'X'.
          L_UMASS = L_T_FMDYNHST-STARTPOS - 1.
          L_UMASS_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

* "/ Objekt
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'OBJ'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_FLG_OBJ = 'X'.
          L_OBJ = L_T_FMDYNHST-STARTPOS - 1.
          L_OBJ_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

* "/ Pruefziffer
      READ TABLE L_T_FMDYNHST WITH KEY KURZBEZ = 'PRUEFZ'.
      IF SY-SUBRC = 0.
        IF L_T_FMDYNHST-STARTPOS > 0 AND L_T_FMDYNHST-LENGTH > 0.
          L_FLG_DYNHST = 'X'.
          L_PRUEFZ = L_T_FMDYNHST-STARTPOS - 1.
          L_PRUEFZ_LEN = L_T_FMDYNHST-LENGTH.
        ENDIF.
      ENDIF.

    ENDIF.

    IF L_FLG_DYNHST IS INITIAL.
* "/ Wurden keine Teilelemente gepflegt, wird folgender
* "/ Haushaltsstellenaufbau eingestellt.
* "/
* "/  Bezeichnung        Position    Laenge
* "/ --------------------------------------
* "/  org. Gliederung      1           4
* "/  sachl. Gliederung    5           3
* "/  Massnahme            8           4
* "/  Pruefziffer          12          1
* "/
* "/         z.B.:              2410 379 4000 1
* "/                    Gliederung  Gruppe  Massnahme  Pruefziffer
* "/ Wegen des Offsets (Felder beginnen mit Poisition '0' , nicht
* "/ mit '1'), werden die Positionen um '1' subtrahiert.
      L_PRAEFIX = 0.
      L_PRAEFIX_LEN = 0.
      L_GLD = 0.
      L_GLD_LEN = 4.
      L_EPL = 0.
      L_EPL_LEN = 1.
      L_ABSCHN = 0.
      L_ABSCHN_LEN = 2.
      L_UABSCH = 0.
      L_UABSCH_LEN = 4.
      L_GRUPPE = 4.
      L_GRUPPE_LEN = 3.
      L_HGR = 4.
      L_HGR_LEN = 1.
      L_GRP = 4.
      L_GRP_LEN = 2.
      L_UGR = 4.
      L_UGR_LEN = 3.
      L_MASS = 7.
      L_MASS_LEN = 4.
      L_HMASS = 7.
      L_HMASS_LEN = 1.
      L_MASSN = 7.
      L_MASSN_LEN = 2.
      L_UMASS = 7.
      L_UMASS_LEN = 4.
      L_OBJ = 0.
      L_OBJ_LEN = 0.
      L_PRUEFZ = 11.
      L_PRUEFZ_LEN = 1.

      MESSAGE S602(FO).
*   Default-Initialisierung der Teilelemente der Haushaltsstelle.

    ELSE.

* "/ Sind diverse Felder nicht geplegt, kann dies zu
* "/ Verwirrungen führen, daher Nachricht ausgeben.
      IF L_FLG_GLD IS INITIAL.
        CLEAR L_FLG_SUCCESS.
        MESSAGE I601(FO) WITH 'GLD'.
*   Teilelement & der Haushaltsstelle nicht gepflegt ( siehe IMG ).
      ENDIF.

      IF L_FLG_EPL IS INITIAL.
        CLEAR L_FLG_SUCCESS.
        MESSAGE I601(FO) WITH 'EPL'.
*   Teilelement & der Haushaltsstelle nicht gepflegt ( siehe IMG ).
      ENDIF.

      IF L_FLG_ABSCHN IS INITIAL.
        CLEAR L_FLG_SUCCESS.
        MESSAGE I601(FO) WITH 'ABSCHN'.
*   Teilelement & der Haushaltsstelle nicht gepflegt ( siehe IMG ).
      ENDIF.

      IF L_FLG_UABSCH IS INITIAL.
        CLEAR L_FLG_SUCCESS.
        MESSAGE I601(FO) WITH 'UABSCH'.
*   Teilelement & der Haushaltsstelle nicht gepflegt ( siehe IMG ).
      ENDIF.

      IF L_FLG_GRUPPE IS INITIAL.
        CLEAR L_FLG_SUCCESS.
        MESSAGE I601(FO) WITH 'GRUPPE'.
*   Teilelement & der Haushaltsstelle nicht gepflegt ( siehe IMG ).
      ENDIF.

      IF L_FLG_HGR IS INITIAL.
        CLEAR L_FLG_SUCCESS.
        MESSAGE I601(FO) WITH 'HGR'.
*   Teilelement & der Haushaltsstelle nicht gepflegt ( siehe IMG ).
      ENDIF.

      IF L_FLG_GRP IS INITIAL.
        CLEAR L_FLG_SUCCESS.
        MESSAGE I601(FO) WITH 'GRP'.
*   Teilelement & der Haushaltsstelle nicht gepflegt ( siehe IMG ).
      ENDIF.

      IF L_FLG_UGR IS INITIAL.
        CLEAR L_FLG_SUCCESS.
        MESSAGE I601(FO) WITH 'UGR'.
*   Teilelement & der Haushaltsstelle nicht gepflegt ( siehe IMG ).
      ENDIF.
** Not used in LSA, avoid message!
*      IF L_FLG_MASS IS INITIAL.
*        CLEAR L_FLG_SUCCESS.
*        MESSAGE I601(FO) WITH 'MASS'.
**   Teilelement & der Haushaltsstelle nicht gepflegt ( siehe IMG ).
*      ENDIF.

      IF L_FLG_SUCCESS = 'X'.
*      message s600(fo).
*   Initialisierung der Teilemente der Haushaltsstelle abgeschlossen.
      ENDIF.

    ENDIF.

************************************************************************

* "/ Setzen der Field-Symbols

    IF L_PRAEFIX_LEN > 0.
      ASSIGN G_FSFIPEX+L_PRAEFIX(L_PRAEFIX_LEN) TO <PRAEFIX>.
    ENDIF.
    IF L_GLD_LEN > 0.
      ASSIGN G_FSFIPEX+L_GLD(L_GLD_LEN) TO <GLD>.
    ENDIF.
    IF L_EPL_LEN > 0.
      ASSIGN G_FSFIPEX+L_EPL(L_EPL_LEN) TO <EPL>.
    ENDIF.
    IF L_ABSCHN_LEN > 0.
      ASSIGN G_FSFIPEX+L_ABSCHN(L_ABSCHN_LEN) TO <ABSCHN>.
    ENDIF.
    IF L_UABSCH_LEN > 0.
      ASSIGN G_FSFIPEX+L_UABSCH(L_UABSCH_LEN) TO <UABSCH>.
    ENDIF.
    IF L_GRUPPE_LEN > 0.
      ASSIGN G_FSFIPEX+L_GRUPPE(L_GRUPPE_LEN) TO <GRUPPE>.
    ENDIF.
    IF L_HGR_LEN > 0.
      ASSIGN G_FSFIPEX+L_HGR(L_HGR_LEN) TO <HGR>.
    ENDIF.
    IF L_GRP_LEN > 0.
      ASSIGN G_FSFIPEX+L_GRP(L_GRP_LEN) TO <GRP>.
    ENDIF.
    IF L_UGR_LEN > 0.
      ASSIGN G_FSFIPEX+L_UGR(L_UGR_LEN) TO <UGR>.
    ENDIF.
    IF L_MASS_LEN > 0.
      ASSIGN G_FSFIPEX+L_MASS(L_MASS_LEN) TO <MASS>.
    ENDIF.
    IF L_HMASS_LEN > 0.
      ASSIGN G_FSFIPEX+L_HMASS(L_HMASS_LEN) TO <HMASS>.
    ENDIF.
    IF L_MASSN_LEN > 0.
      ASSIGN G_FSFIPEX+L_MASSN(L_MASSN_LEN) TO <MASSN>.
    ENDIF.
    IF L_UMASS_LEN > 0.
      ASSIGN G_FSFIPEX+L_UMASS(L_UMASS_LEN) TO <UMASS>.
    ENDIF.
    IF L_OBJ_LEN > 0.
      ASSIGN G_FSFIPEX+L_OBJ(L_OBJ_LEN) TO <OBJ>.
    ENDIF.

    IF L_PRUEFZ_LEN > 0.
      ASSIGN G_FSFIPEX+L_PRUEFZ(L_PRUEFZ_LEN) TO <PRUEFZ>.
    ENDIF.

* "/ Setzen der einzelnen Teilelement-Laengen.
    G_F_FMHHST_LEN-PRAEFIX_LEN = L_PRAEFIX_LEN.
    G_F_FMHHST_LEN-GLD_LEN     = L_GLD_LEN.
    G_F_FMHHST_LEN-EPL_LEN     = L_EPL_LEN.
    G_F_FMHHST_LEN-ABSCHN_LEN  = L_ABSCHN_LEN.
    G_F_FMHHST_LEN-UABSCH_LEN  = L_UABSCH_LEN.
    G_F_FMHHST_LEN-GRUPPE_LEN  = L_GRUPPE_LEN.
    G_F_FMHHST_LEN-HGR_LEN     = L_HGR_LEN.
    G_F_FMHHST_LEN-GRP_LEN     = L_GRP_LEN.
    G_F_FMHHST_LEN-UGR_LEN     = L_UGR_LEN.
    G_F_FMHHST_LEN-MASS_LEN    = L_MASS_LEN.
    G_F_FMHHST_LEN-HMASS_LEN    = L_HMASS_LEN.
    G_F_FMHHST_LEN-MASSN_LEN    = L_MASSN_LEN.
    G_F_FMHHST_LEN-UMASS_LEN    = L_UMASS_LEN.
    G_F_FMHHST_LEN-OBJ_LEN    = L_OBJ_LEN.
    G_F_FMHHST_LEN-PRUEFZ_LEN  = L_PRUEFZ_LEN.

* "/ Setzen der einzelnen Teilelement-Positionen.
    G_F_FMHHST_POS-PRAEFIX = L_PRAEFIX.
    G_F_FMHHST_POS-GLD     = L_GLD.
    G_F_FMHHST_POS-EPL     = L_EPL.
    G_F_FMHHST_POS-ABSCHN  = L_ABSCHN.
    G_F_FMHHST_POS-UABSCH  = L_UABSCH.
    G_F_FMHHST_POS-GRUPPE  = L_GRUPPE.
    G_F_FMHHST_POS-HGR     = L_HGR.
    G_F_FMHHST_POS-GRP     = L_GRP.
    G_F_FMHHST_POS-UGR     = L_UGR.
    G_F_FMHHST_POS-MASS    = L_MASS.
    G_F_FMHHST_POS-HMASS   = L_HMASS.
    G_F_FMHHST_POS-MASSN   = L_MASSN.
    G_F_FMHHST_POS-UMASS   = L_UMASS.
    G_F_FMHHST_POS-OBJ     = L_OBJ.
    G_F_FMHHST_POS-PRUEFZ  = L_PRUEFZ.

* "/ Setze der Default Haushaltsstelle ( wird zm Aufbau von
* "/ Sortierschluesseln verwendet).
    G_FSFIPEX = CON_DUMMY_HST.
    G_F_FMHHST_DEFAULT-GLD = <GLD>.
    G_F_FMHHST_DEFAULT-GRUPPE = <GRUPPE>.

    G_F_FMHHST_DEFAULT-PRAEFIX = <PRAEFIX>.
    G_F_FMHHST_DEFAULT-EPL = <EPL>.
    G_F_FMHHST_DEFAULT-ABSCHN = <ABSCHN>.
    G_F_FMHHST_DEFAULT-UABSCH = <UABSCH>.
    G_F_FMHHST_DEFAULT-HGR = <HGR>.
    G_F_FMHHST_DEFAULT-GRP = <GRP>.
    G_F_FMHHST_DEFAULT-UGR = <UGR>.
    G_F_FMHHST_DEFAULT-MASS = <MASS>.
    G_F_FMHHST_DEFAULT-HMASS = <HMASS>.
    G_F_FMHHST_DEFAULT-MASSN = <MASSN>.
    G_F_FMHHST_DEFAULT-UMASS = <UMASS>.
    G_F_FMHHST_DEFAULT-OBJ = <OBJ>.
    G_F_FMHHST_DEFAULT-PRUEFZ = <PRUEFZ>.

  ENDFORM.                             " INIT_DYN_HHST
*&---------------------------------------------------------------------*
*&      Form  GET_HHST_PREFIX
*&---------------------------------------------------------------------*
*       Ermittlung der HHst-Praefix-Laenge                             *
*----------------------------------------------------------------------*
FORM GET_HHST_PREFIX USING    U_KURZBEZ       LIKE FMDYNHST-KURZBEZ
                              U_LFDNR         LIKE FMDYNHST-LFDNR
                     CHANGING C_PREFIX_LENGTH LIKE FMDYNHST-STARTPOS.

  C_PREFIX_LENGTH = 0.
* Einlesen der Pflegeviewdaten fuer Einzelplan
  SELECT SINGLE * FROM  FMDYNHST
                  WHERE LFDNR   = U_LFDNR AND
                        KURZBEZ = U_KURZBEZ.

  IF SY-SUBRC = 0 AND FMDYNHST-STARTPOS > 0.
    C_PREFIX_LENGTH = FMDYNHST-STARTPOS - 1.
  ENDIF.

ENDFORM.                    " GET_HHST_PREFIX

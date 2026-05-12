*----------------------------------------------------------------------*
*   INCLUDE I_RFUMS_TABLES                                             *
*----------------------------------------------------------------------*
TYPE-POOLS glt0.                                            "877045

*----------------------------------------------------------------------*
* Interne Tabellen & Feldleisten, die mit dem ALV ausgegeben werden    *
*----------------------------------------------------------------------*

* ----- begin of deletion 930100 -----                       "930100
* Informationen zu den Summenzeilen von Ausgangs- und Vorsteuer
*TYPES: BEGIN OF ty_steuer_sum,
*         bukrs LIKE bset-bukrs,        "Buchungskreis
*         mwskz LIKE bset-mwskz,        "Umsatzsteuerkennzeichen
*         ktosl LIKE bset-ktosl,        "Vorgangsschlüssel
*         psatz LIKE rfums_alv-psatz,   "Prozentsatz der Steuer
*         text1 LIKE t007s-text1,       "Steuerbezeichnung
*         hwbas LIKE rfums_alv-hwbas,   "Steuerbasisbetrag in Hausw.
*         hwgross LIKE rfums_alv-hwgross,   "Brutto Steuerbasis in HW.
*         fwbas LIKE rfums_alv-fwbas,   "Steuerbasisbetrag in Fremdw.
*         hwaer LIKE bkpf-hwaer,        "Hauswährung
*         fwaer LIKE rfums_alv-fwaer,   "Fremdwährung
*         hwste_r TYPE rfums_alv-hwste3,"Steuerbetrag in HW, gerundet
*         tkont LIKE bset-hkont,         "Steuerkonto  "OP-13
*       END OF ty_steuer_sum.
*
** Summenblatt der Ausgangssteuer pro Buchungskreis
*TYPES: BEGIN OF ty_auste_sum.
*INCLUDE TYPE ty_steuer_sum.
*TYPES:   hwste LIKE rfums_alv-hwauste, "Ausgangssteuer in Hausw.
*         fwste LIKE rfums_alv-fwauste, "Ausgangssteuer in Fremdw.
*         hwnaf LIKE rfums_alv-hwanaf,  "n. abzuführende Steuer in HW
*         hwnaf_r LIKE rfums_alv-hwanaf3, "ger. n. abzuf, Steuer in HW
*         fwnaf LIKE rfums_alv-fwanaf,  "n. abzuführende Steuer in FW
*         hwsteaa like rfums_alv-hwaustea,"abzuf. ausgangsst "OP-03
*         fwsteaa LIKE rfums_alv-fwaustea,"abzuf. ausg.St FW  "783666
*       END OF ty_auste_sum.
*
** Summenblatt der Vorsteuer pro Buchungskreis
*TYPES: BEGIN OF ty_voste_sum.
*INCLUDE TYPE ty_steuer_sum.
*TYPES:   hwste LIKE rfums_alv-hwvoste, "Vorsteuer in Hausw.
*         fwste LIKE rfums_alv-fwvoste, "Vorsteuer in Fremdw.
*         hwnaf LIKE rfums_alv-hwnaf,   "nicht abzugsf. Steuer Hausw.
*         hwnaf_r LIKE rfums_alv-hwnaf3,"ger. nicht abzugsf. Steuer HW
*         fwnaf LIKE rfums_alv-fwnaf,   "nicht abzugsf. Steuer Fremdw.
*         hwsteaa like rfums_alv-hwvostea,"abzuf. vorsteuer "OP-03
*         fwsteaa LIKE rfums_alv-fwvostea,"abzuführ. Vorst. FW  "783666
*       END OF ty_voste_sum.
*
** Summenblatt pro Buchungskreis
*TYPES: BEGIN OF ty_bukrs,
*         bukrs LIKE bset-bukrs,        "Buchungskreis
*         mwskz LIKE bset-mwskz,        "Umsatzsteuerkennzeichen
*         ktosl LIKE bset-ktosl,        "Vorgangsschlüssel
*         psatz LIKE rfums_alv-psatz,   "Prozentsatz der Steuer
*         text1 LIKE t007s-text1,       "Steuerbezeichnung
*         hwbas LIKE rfums_alv-hwbas,   "Steuerbasisbetrag in Hausw.
*         fwbas LIKE rfums_alv-fwbas,   "Steuerbasisbetrag in Fremdw.
*         hwvor LIKE rfums_alv-hwvoste2,"Abzugsfä. Vorsteuer in Hausw.
*         hwvor_r LIKE rfums_alv-hwvoste3,"Ger. Abzugsf. Vorsteuer HW
*         fwvor LIKE rfums_alv-fwvoste2,"Abzugsfä. Vorsteuer in FW
*         hwaus LIKE rfums_alv-hwauste2,"Abzufüh. Aus.-Steuer Hausw.
*         hwaus_r LIKE rfums_alv-hwauste3,"Ger. Abzufüh. Aus.-Steuer HW
*         fwaus LIKE rfums_alv-fwauste2,"Abzufüh. Aus.-Steuer Fremdw.
*         hwsld LIKE rfums_alv-hwsaldo, "Saldo in Hauswährung
*         hwsld_r LIKE rfums_alv-hwsaldo3, "Gerund. Saldo in Hauswährung
*         fwsld LIKE rfums_alv-fwsaldo, "Saldo in Fremdwährung
*         hwaer LIKE t001-waers,        "Hauswährung
*         fwaer LIKE t001-waers,        "Fremdwährung
*         sdiff LIKE rfums_alv-sdiff,   "Differenz zur Steuer in HW
*         sdiff_r LIKE rfums_alv-hwsdiff3, "RundungsDifferenz in HW
*       END OF ty_bukrs.
*
** Tabelle der Einzelposten mit Steuerdifferenzen pro Buchungskreis
*TYPES: BEGIN OF ty_sdiff_ep,
*         bukrs LIKE bkpf-bukrs,        "Buchungskreis
*         gjahr LIKE bkpf-gjahr,        "Geschäftsjahr
*         belnr LIKE bkpf-belnr,        "Belegnummer
*         mwskz LIKE bset-mwskz,        "Mehrwertsteuerkennzeichen
*         hwste2 LIKE rfums_alv-hwste2, "Berechnete Steuer
*         sdiff LIKE rfums_alv-sdiff,   "Differenz zur Steuer in HW
*         hwaer LIKE t001-waers,        "Hauswährung
*         prozt LIKE rfums_alv-prozt,   "Abweichung in Prozent
*      END OF ty_sdiff_ep.
*
** Tabelle über die Ausgabetabellen pro Buchungskreis
*DATA: BEGIN OF gt_alv OCCURS 0,
*        bukrs LIKE bkpf-bukrs,
*        t_auste_ep  TYPE rfums_tax_item OCCURS 0, "Augangssteuer, Ein.p.
*        t_auste_sum TYPE ty_auste_sum OCCURS 0,   "Augangssteuer, Summe
*        t_voste_ep  TYPE rfums_tax_item OCCURS 0, "Vorsteuer, Einzelpos.
*        t_voste_sum TYPE ty_voste_sum OCCURS 0,   "Vorsteuer, Summe
*        t_sdiff_ep  TYPE ty_sdiff_ep  OCCURS 0,   "Steuerdiffer., Ein.p.
*        t_bukrs     TYPE ty_bukrs     OCCURS 0,   "Summe über den Bukrs
*      END OF gt_alv.
*
*field-symbols <gt_alv> like line of gt_alv.
*
** Summenblatt über alle Buchungskreise
*TYPES: BEGIN OF ty_bukrs_sum,
*         bukrs LIKE bset-bukrs,        "Buchungskreis
*         hwaer LIKE t001-waers,        "Hauswährung
*         mwskz LIKE bset-mwskz,        "Umsatzsteuerkennzeichen
*         ktosl LIKE bset-ktosl,        "Vorgangsschlüssel
*         shkzg LIKE bset-shkzg,        "Soll-Haben-Kennzeichen
*         psatz LIKE rfums_alv-psatz,   "Prozentsatz der Steuer
*         text1 LIKE t007s-text1,       "Steuerbezeichnung
*         hwbas LIKE rfums_alv-hwbas,   "Steuerbasisbetrag
*         hwvor LIKE rfums_alv-hwvoste2,"Abzugsfähige Vorsteuer
*         hwaus LIKE rfums_alv-hwauste2,"Abzuführende Ausgangssteuer
*         hwsld LIKE rfums_alv-hwsaldo, "Saldo
*         sdiff LIKE rfums_alv-sdiff,   "Differenz zur Steuer in HW
*       END OF ty_bukrs_sum.
*DATA: gt_bukrs_sum TYPE ty_bukrs_sum OCCURS 0.
* ----- end of deletion 930100 -----                         "930100

* Tabelle über die Ausgabetabellen pro Buchungskreis         "930100
DATA gt_alv TYPE STANDARD TABLE OF rfums_tax_gt_alv         "930100
     INITIAL SIZE 0 WITH HEADER LINE.                       "930100

FIELD-SYMBOLS <gt_alv> LIKE LINE OF gt_alv.                 "930100

* Summenblatt über alle Buchungskreise                       "930100
DATA gt_bukrs_sum TYPE line_ty_bukrs_sum OCCURS 0.          "930100


DATA: BEGIN OF s_isocodes,
        bukrs TYPE t001-bukrs,
        intca TYPE t005-intca,
      END OF s_isocodes.                                    "566949

TYPES tt_isocodes LIKE s_isocodes OCCURS 0.                 "566949

DATA gt_isocodes TYPE tt_isocodes.                          "566949


DATA:
* Buchungszeilen, die durch die Batch-Input-Mappe erzeugt werden
  gt_bi_items       TYPE TABLE OF tax_rep_batch_input_document,
* Neue Ausgabetabelle: Enthält alte gt_bi_items + Kontierungen
  gt_bi_items_split TYPE TABLE OF tax_rep_batch_input_doc_split, "877045
* Buchungskreise, für die der Formulardruck vorbereitet wurde
  gt_company_code   TYPE TABLE OF tax_rep_company_code,
* Info zu den Meldungen für elektronische Steuermeldung     "751603
  gt_euva_list      TYPE TABLE OF fot_s_umsl,               "751603
* Tabelle der Funktionscodes, die im ALV deaktiviert werden
  gt_excluding      TYPE slis_t_extab,
* Pro Beleg eine Aufwands- und eine Personenzeile aus der BSEG
  gt_more_bseg      TYPE SORTED TABLE OF rfums_bseg
                    WITH UNIQUE KEY bukrs
                                    belnr
                                    gjahr
                                    koart.

*----------------------------------------------------------------------*
* Tabellen                                                             *
*----------------------------------------------------------------------*
TABLES:
  bhdgd,                               "Batch-Heading
  bkpf,                                "Belegkopf
  bsec,                                "Belegsegment CPD-Daten
  bseg,                                "Belegsegment Buchhaltung
  bset,                                "Belegsteuerdaten
  j_1bbranch,                      "#EC NEEDED    "Geschaeftsorte Korea
  rfdt,                                "für 4.0-Umsetzung
  sscrfields,                          "Felder v. Selektionsbild
  t001,                                "Buchungskreise
  t001r,                               "Rundungsregeln pro Bukrs,Währung
  t001z,                               "weitere Buchungskreisangaben
  t005,                                "Land des Buchungskreises
  t007a,                               "Steuerart des Umsatzsteuerkennz.
  t007f,                               "Umsatzsteuerkreise
  t007k,                               "Gruppierung für Druck
  t007s,                               "Bezeichnung Steuerkennzeichen
  t685a,                               "Reisekosten?
  ttxd,                 "#EC NEEDED    "nie Bukrs mit Jurisdictionscode
  taltwar,                             "<<<< euro
  umsv,                                "Aufnahme von Bukrs-Steuersalden
  "  für Formulardruck
  umsvz,                               "Zeitraum der Umsatzsteuer-
  "  Voranmeldung für Formulardruck
  b0sg,                                                     "455755
  a003,                                                     "OP-20
  tcurf,                                                    "455681
  tax_appli.                                                "447075

*----------------------------------------------------------------------*
* Interne Tabellen (TAB)                                               *
*----------------------------------------------------------------------*
TYPES t_tax_appli TYPE STANDARD TABLE OF tax_appli.         "447075

DATA: it_tax_appli TYPE t_tax_appli,                        "447075
      is_tax_appli LIKE tax_appli.

DATA:
* Auszug aus der Buchungskreistabelle
  BEGIN OF tab_001 OCCURS 5,
    bukrs LIKE t001-bukrs,         "Buchungskreis
    land1 LIKE t001-land1,         "Land
    waers LIKE t001-waers,         "Hauswährung
    kalsm LIKE t005-kalsm,         "Kalkulationsschema (aus T005)
    butxt TYPE t001-butxt,         "Text
    periv TYPE t001-periv,         "Geschäftsjahresvariante  "751603
    stceg TYPE t001-stceg,                                  "1035054
    adrnr TYPE t001-adrnr,                                  "1035054
  END OF tab_001,

  BEGIN OF t_knumh OCCURS 5,                              "OP-20
    aland LIKE t005-land1,                                "OP-20
    mwskz LIKE bset-mwskz,                                "OP-20
    kschl LIKE a003-kschl,                                "OP-20
    knumh LIKE a003-knumh,                                "OP-20
    kbetr LIKE konp-kbetr,                                "OP-20
  END OF t_knumh,                                         "OP-20

  BEGIN OF it_coco_calcproc OCCURS 5,          "481176
    bukrs LIKE bkpf-bukrs,                                  "481176
    land1 LIKE t005-land1,                                  "481176
  END OF it_coco_calcproc,                     "481176

* Umsatzsteuertabelle
  BEGIN OF tab_007a OCCURS 15.
    INCLUDE STRUCTURE t007a.
DATA: text1 LIKE t007s-text1,
  END OF tab_007a,

* Bolle Doganle: G/L-Accounts from BSEG per Item
  BEGIN OF tab_bd_gl_accounts OCCURS 5,
    hkont TYPE bseg-hkont,
  END OF tab_bd_gl_accounts.

* List of BP-addresses per tax code for stock transfers     "1686870
TYPES:                                                      "1686870
  BEGIN OF ty_wia_adrnr,                                    "1686870
    tax_country TYPE fot_tax_country,
    mwskz       TYPE mwskz,                                 "1686870
    adrnr       TYPE adrnr,                                 "1686870
    stceg       TYPE stceg,                                 "1686870
  END OF ty_wia_adrnr.                                      "1686870
DATA:                                                       "1686870
  gs_wia_adrnr TYPE ty_wia_adrnr,                           "1686870
  gt_wia_adrnr TYPE TABLE OF ty_wia_adrnr.                  "1686870

* List of discount amounts per tax code                     "1868787
TYPES:                                                      "1868787
  BEGIN OF ty_discounts,                                    "1868787
    tax_country TYPE fot_tax_country,
    mwskz       TYPE mwskz,                                 "1868787
    txdat_from  TYPE fot_txdat_from,
    ktosl       TYPE ktosl,                                 "1868787
    dmbtr       TYPE dmbtr,                                 "1868787
    wrbtr       TYPE wrbtr,                                 "1868787
  END OF ty_discounts.                                      "1868787
DATA:                                                       "1868787
  gs_discounts TYPE ty_discounts,                           "1868787
  gt_discounts TYPE TABLE OF ty_discounts.                  "1868787

* G/L-Accounts per tax code
TYPES:
  BEGIN OF ty_glaccount,
    hkont       LIKE bseg-hkont,
    tax_country TYPE fot_tax_country,
    mwskz       LIKE bseg-mwskz,
    txdat_from  LIKE bseg-txdat_from,
    koart       LIKE bseg-koart,                            "992241
  END OF ty_glaccount.                                 "OP-30
* interne Struktur zur Tabelle it_gl_account
DATA: is_glaccount TYPE ty_glaccount.                       "OP-30
DATA: it_glaccount TYPE TABLE OF ty_glaccount WITH KEY hkont tax_country mwskz,
      "OP-30

      BEGIN OF tab_007b OCCURS 5.
        INCLUDE STRUCTURE t007b.
DATA: END OF tab_007b,

* Auszug aus der Konditionentabelle (Position)               "OP-20
BEGIN OF tab_konp OCCURS 15,                                "OP-20
  knumh LIKE konp-knumh,                 "Konditionssatznummer "OP-20
  kbetr LIKE konp-kbetr,                 "Prozentsatz          "OP-20
END OF tab_konp,                                            "OP-20

* Auszug aus der Debitoren-/Kreditorendatei für die Anschriftsdaten
BEGIN OF tab_adrs,
  nummr    LIKE kna1-kunnr,           "Kontokorrent-Kontonummer
  xblck    LIKE kna1-cvp_xblck,                             "2073571
  stcd1    LIKE kna1-stcd1,           "Steuercode-1
  stcd2    LIKE kna1-stcd2,           "Steuercode-2
  stceg    LIKE kna1-stceg,           "Umsatzsteuer-Identifik.-nr.
  name1    LIKE kna1-name1,           "Name
  ort01    LIKE kna1-ort01,           "Geschäftspartner-Ort
  pstlz    LIKE kna1-pstlz,           "Geschäftspartner-Postleitzahl
  name2    LIKE kna1-name2,           "Name
  name3    LIKE kna1-name3,           "Name
  name4    LIKE kna1-name4,           "Name
  stras    LIKE kna1-stras,           "Street
  country  LIKE t005-intca,           "Country ISO code    "1335702
  countryt LIKE t005t-landx,          "Country Name        "1335702
  stcd3    LIKE kna1-stcd3,           "Steuercode-3        "1683630
  stcd4    LIKE kna1-stcd4,           "Steuercode-4        "1683630
END OF tab_adrs,

* Tabelle mit Einzelposten-Informationen je Beleg
tab_ep TYPE TABLE OF rfums_tab_ep WITH HEADER LINE,

* Tabelle für BSET-Update mit Zeilen, die aus TAB_EP gelöscht werden
      BEGIN OF tab_bset_key OCCURS 50,
        bukrs LIKE bset-bukrs,
        belnr LIKE bset-belnr,
        gjahr LIKE bset-gjahr,
        buzei LIKE bset-buzei,
      END OF tab_bset_key,

* Tabelle für das Summenblatt Vorsteuer/Ausgangssteuer
      BEGIN OF tab_mwart OCCURS 5,
        mwart       LIKE t007a-mwart,          "Umsatzsteuerart
        tax_country TYPE fot_tax_country,
        mwskz       LIKE bset-mwskz,           "Umsatzsteuerkennzeichen
        txdat_from  LIKE bset-txdat_from,
        lstml       LIKE bset-lstml,           "Meldeland "N2390821
        ktosl       LIKE bset-ktosl,           "Vorgangsschlüssel
        waers       LIKE bkpf-waers,           "Währungsschlüssel
        psatz(7)    TYPE c,                    "Prozentsatz
        shkzg       LIKE bset-shkzg,           "Soll-Haben-Kennzeichen
        hwbas       TYPE aflex17d2o20n,        " AFLE enablment. Previously p(9),                    "Steuerbasisbetrag in Hausw.
        fwbas       TYPE aflex17d2o20n,        " AFLE enablment. Previously p(9)p,                    "Steuerbasisbetrag in Belegw.
        hwste       TYPE aflex15d2o21s,        "AFLE enablement. Previously p(8),                    "Steuerbetrag in Hausw.
        fwste       TYPE aflex15d2o21s,        "AFLE enablement. Previously p(8),p,                    "Steuerbetrag in Fremdw.
        hwnaf       TYPE aflex15d2o21s,        "AFLE enablement. Previously p(8),p,                    "nicht abzugsf. Steuer Hausw.
        fwnaf       TYPE aflex15d2o21s,        "AFLE enablement. Previously p(8),p,                    "nicht abzugsf. Steuer Belegw.
        hwste_r     TYPE rfums_alv-hwste3,       "Steuerbetrag in HW, gerundet
        hwnaf_r     TYPE rfums_alv-hwnaf3,       "n. abzu. Steuer in HW, gerundet
        hwsteaa     TYPE aflex15d2o21s,          "abzugsf./abzuf. Steuer"OP-03 AFLE enablement (8) type p,
        tkont       LIKE bset-hkont,           "Steuerkonto   "OP-13
      END OF tab_mwart,

* Tabelle für das Summenblatt Steuersaldo je Buchungskreis
      BEGIN OF tab_bukrs OCCURS 5,
        tax_country TYPE fot_tax_country,
        mwskz       LIKE bset-mwskz,           "Umsatzsteuerkennzeichen
        txdat_from  LIKE bset-txdat_from,
        lstml       LIKE bset-lstml,           "Meldeland "N2390821
        ktosl       LIKE bset-ktosl,           "Vorgangsschlüssel
        waers       LIKE bkpf-waers,           "Währungsschlüssel
        psatz(7)    TYPE c,                    "Prozentsatz
        shkzg       LIKE bset-shkzg,           "Soll-Haben-Kennzeichen
        hwbas       TYPE aflex17d2o22s,      "AFLE enablement. Previously p(9),                    "Steuerbasisbetrag in Hausw.
        fwbas       TYPE aflex17d2o22s,      "AFLE enablement. Previously p(9),                    "Steuerbasisbetrag in Belegw.
        hwaus       TYPE aflex15d2o21s,      "AFLE enablement. Previously p(8),                    "abzuführ. Ausg.st. in Hausw.
        fwaus       TYPE aflex15d2o21s,      "AFLE enablement. Previously p(8),                    "abzuführ. Ausg.st. in Fremdw.
        hwvor       TYPE aflex15d2o21s,      "AFLE enablement. Previously p(8),                    "abzugsf. Vorsteuer in Hausw.
        fwvor       TYPE aflex15d2o21s,      "AFLE enablement. Previously p(8),                    "abzugsf. Vorsteuer in Belegw.
        hwaus_r     TYPE rfums_alv-hwauste3,   "abzuführ. ger. Ausg.st. in HW
        hwvor_r     TYPE rfums_alv-hwvoste3,   "abzugsf. ger. Vorsteuer in HW
        sdiff       TYPE aflex15d2o21s,      "AFLE enablement. Previously p(8),                    "Steuerkontrolle in Hausw.
        negp        LIKE bseg-xnegp,                                "OP-07
      END OF tab_bukrs,

* Tabelle für das Summenblatt Mandant, aufgeteilt nach Hauswährungen
      BEGIN OF tab_hwaer OCCURS 5,
        hwaer       LIKE t001-waers,           "Hauswährung
        bukrs       LIKE t001-bukrs,           "Buchungskreis
        tax_country TYPE fot_tax_country,
        mwskz       LIKE bset-mwskz,           "Umsatzsteuerkennzeichen
        txdat_from  LIKE bset-txdat_from,
        lstml       LIKE bset-lstml,           "Meldeland "N2390821
        ktosl       LIKE bset-ktosl,           "Vorgangsschlüssel
        psatz(7)    TYPE c,                    "Prozentsatz
        shkzg       LIKE bset-shkzg,           "Soll-Haben-Kennzeichen
        hwbas       TYPE aflex17d2o22s,        "(9)  TYPE p,   AFLE enablement                 "Steuerbasisbetrag in Hausw.
        hwaus       TYPE aflex15d2o21s,        "(8)  TYPE p,                    "abzuführ. Ausg.st. in Hausw.
        hwvor       TYPE aflex15d2o21s,        "(8)  TYPE p,                    "abzugsf. Vorsteuer in Hausw.
        sdiff       TYPE aflex15d2o21s,        "(8)  TYPE p,                    "Steuerkontrolle in Hausw.
      END OF tab_hwaer,

* Tabelle für die Zahllastsalden für Batch-Input
      BEGIN OF tab_bi OCCURS 5,
        bukrs LIKE bkpf-bukrs,
        hkont LIKE bset-hkont,
        saldo LIKE tab_hwaer-hwvor,
        adaa  TYPE glt0_addaa,                              "877045
      END OF tab_bi,

* Tabelle für die Steuersalden pro Buchungskreis,
*   Umsatzsteuerkennzeichen und Vorgangsschlüssel
      BEGIN OF tab_umsv OCCURS 200.
        INCLUDE STRUCTURE umsv.
DATA: END OF tab_umsv,

* Tabelle der fortlaufenden Nummern pro Buchungskreis + Steuerart (A/V)
tab_trvor TYPE TABLE OF trvor,

* Tabelle für die Steuerkontrolle:
*   Zulässiger Rundungsfehler pro Steuerkennzeichen in einem Beleg
*   (hängt auch von der Anzahl der Zeilen im Beleg mit diesem Stkz. ab)
      BEGIN OF tab_diff OCCURS 10,
        tax_country TYPE fot_tax_country,
        mwskz       LIKE bset-mwskz,           "Steuerkennzeichen
        txdat_from  LIKE bset-txdat_from,
        flg_fc      TYPE xfeld,                "Belegwaehrung       "1104702
        rndbl(8)    TYPE p,                    "zul. Rundgsfehler (Belegzeilen)
        rndst(8)    TYPE p,                    "zul. Rundgsfehler (Steuerzeilen)
      END OF tab_diff,

* Rundungsregeln pro Buchungskreis und Währung
      BEGIN OF tab_001r OCCURS 50.
        INCLUDE STRUCTURE t001r.
DATA: END OF tab_001r,

* Steuersatz und Steuerbetrag für ein Steuerkennzeichen
BEGIN OF tab_rtax1u15 OCCURS 10.
  INCLUDE STRUCTURE rtax1u15.
DATA: END OF tab_rtax1u15,

* Memory für die aus TAB_RTAX1U15 ermittelten Prozentsätze
BEGIN OF tab_rtax OCCURS 50,
  land1       LIKE t001-land1,                              "2211586
  tax_country TYPE fot_tax_country,
  mwskz       LIKE bset-mwskz,
  txdat_from  LIKE bset-txdat_from,
* ktosl     LIKE bset-ktosl,
  kschl       LIKE bset-kschl,
  wmwst(8)    TYPE p,
  msatz(4)    TYPE p,
END OF tab_rtax,

* Tabelle für Korrektur ESE 100%                             "859167
BEGIN OF gt_ese_bset OCCURS 5,                               "859167
  tax_country TYPE fot_tax_country,
  mwskz       LIKE bset-mwskz,                              "859167
  txdat_from  LIKE bset-txdat_from,
  txgrp       LIKE bset-txgrp,                              "859167
  shkzg       LIKE bset-shkzg,                              "859167
  hwste       LIKE bset-hwste,                              "859167
  fwste       LIKE bset-fwste,                              "859167
  hwbas       LIKE bset-hwbas,                              "859167
  fwbas       LIKE bset-fwbas,                              "859167
  kbetr       LIKE bset-kbetr,                              "859167
  kschl       LIKE bset-kschl,                              "912777
  ktosl       LIKE bset-ktosl,                              "1017516
  lstml       LIKE bset-lstml,                              "1035054
END OF gt_ese_bset,                                          "859167

* Tabelle der Parameter und Select-Options und ihrer Werte
gt_selection_fields TYPE TABLE OF rsparams,

      it_tcurf            LIKE tcurf OCCURS 10.             "455681

* Extract from complete BSEG per document                   "2290231
TYPES:                                                      "2290231
  BEGIN OF ty_bseg_doc,                                     "2290231
    tax_country TYPE fot_tax_country,
    mwskz       LIKE bseg-mwskz,                            "2290231
    txdat       LIKE bseg-txdat,
    txdat_from  LIKE bseg-txdat_from,
    mwart       LIKE bseg-mwart,                            "2290231
    txgrp       LIKE bseg-txgrp,                            "2290231
    shkzg       LIKE bseg-shkzg,                            "2290231
    xnegp       LIKE bseg-xnegp,                            "2290231
    koart       LIKE bseg-koart,                            "2290231
    umsks       LIKE bseg-umsks,                            "2290231
    hkont       LIKE bseg-hkont,                            "2290231
  END OF ty_bseg_doc.                                       "2290231
DATA:                                                       "2290231
  gs_bseg_doc TYPE ty_bseg_doc,                             "2290231
  gt_bseg_doc TYPE TABLE OF ty_bseg_doc.                    "2290231

* Tabellen für Elektronische Voranmeldung                "751603
DATA:                                                       "751603
  gt_fotdeclsta TYPE TABLE OF fotdeclsta,                   "751603
  gt_decl_help  TYPE TABLE OF fot_s_decl_help,              "751603
  gt_fottbukrs  TYPE TABLE OF fottbukrs.                    "751603

DATA:
  gt_umsv_not_mapped TYPE if_fot_atr_dclitm_builder=>tt_tax_balance_not_mapped.


*----------------------------------------------------------------------*
* Feldleisten                                                          *
*----------------------------------------------------------------------*
DATA:

* Feldleiste mit Einzelposten-Informationen
  BEGIN OF ep,
    bukrs        LIKE bkpf-bukrs,         "Buchungskreis
    bupla        LIKE bset-bupla,         "Geschäftsort   "OP-01
    bktxt        LIKE bkpf-bktxt,         "Belegkopf-Text
    blart        LIKE bkpf-blart,         "Belegart
    bldat        LIKE bkpf-bldat,         "Belegdatum
    xmwst        TYPE bkpf-xmwst,         "Steuer automatisch gerechnet
    mwart        LIKE t007a-mwart,        "Umsatzsteuerart
    tax_country  LIKE bset-tax_country,
    mwskz        LIKE bset-mwskz,         "Umsatzsteuerkennzeichen
    txdat        LIKE bset-txdat,
    txdat_from   LIKE bset-txdat_from,
    ktosl        LIKE bset-ktosl,         "Vorgangsschlüssel
    buper(6)     TYPE n,                  "Buchungsperiode
    waers        LIKE bkpf-waers,         "Währungsschlüssel
    budat        LIKE bkpf-budat,         "Buchungsdatum
    gjahr        LIKE bsec-gjahr,         "Geschäftsjahr
    belnr        LIKE bkpf-belnr,         "Belegnummer
    buzei        LIKE bsec-buzei,         "Buchungszeile
    xblnr        LIKE bkpf-xblnr,         "Referenz-Belegnummer
    qunum(13)    TYPE c,                  "Quittungsnummer (Sortierung 4)
    qutyp(4)     TYPE c,                  "Quittungstyp (Sortierung 4)
    qudat(10)    TYPE c,                  "Quittungsdatum (Sortierung 4)
    psatz(7)     TYPE c,                  "Prozentsatz
    koart        LIKE bseg-koart,         "Kontoart
    tkont        LIKE bset-hkont,         "Steuerkonto
    hkont        LIKE bset-hkont,         "Sachkonto
    ktnra        LIKE bseg-kunnr,         "Kontonummer Debitor/Kreditor
    bcode        TYPE bcode,              "Branch Code Thailand     "2097858
    zuonr        TYPE bseg-zuonr,         "Zuordnungsnummer
    xcpdk        LIKE kna1-xcpdk,         "Flag: CPD-Konto?
    stceg        TYPE bseg-stceg,         "Umsatzsteuer-Identifikationsnr.
    shkzg        LIKE bset-shkzg,         "Soll-Haben-Kennzeichen
    hwbas        TYPE aflex15d2o21s,      "AFLE enablement. Previously p(8),                  "Steuerbasisbetrag in Hausw.
    fwbas        TYPE aflex15d2o21s,      "AFLE enablement. Previously p(8),                  "Steuerbasisbetrag in Belegw.
    hwste        TYPE aflex15d2o21s,      "AFLE enablement. Previously p(8),                  "Steuerbetrag in Hausw.
    fwste        TYPE aflex15d2o21s,      "AFLE enablement. Previously p(8),                  "Steuerbetrag in Fremdw.
    hwnaf        TYPE aflex15d2o21s,      "AFLE enablement. Previously p(8),                  "nicht abzugsf. Steuer Hausw.
    fwnaf        TYPE aflex15d2o21s,      "AFLE enablement. Previously p(8),                  "nicht abzugsf. Steuer Belegw.
    sdiff        TYPE aflex15d2o21s,      "AFLE enablement. Previously p(8),                  "Steuerkontrolle in Hausw.
    hwste_r      TYPE rfums_alv-hwste3,   "Steuerbetrag in HW, gerundet
    hwnaf_r      TYPE rfums_alv-hwnaf3,   "nicht abzugsfähige Steuer, ger.
    lstml        LIKE bset-lstml,                           "N2390821
    egbld        LIKE bset-egbld,         "MOSS cntry of consumption     "2101269
    eglld        LIKE bset-eglld,         "MOSS cntry of establishment   "2101269
    user_field_a TYPE user_field_a,
    user_field_b TYPE user_field_b,
    hwsteaa      TYPE aflex15d2o21s,        "(8)  TYPE p,       "OP-01
    hwgross      LIKE bset-hwbas,                                "OP-03
**  negp    like bseg-xnegp,                        "OP-07  "2290231
    text1        LIKE t007s-text1,                               "OP-08
    ex_rate      LIKE bkpf-kursf,              "OP-19 "Wechselkurs
    tx_rate      LIKE bkpf-txkrs,                           "2586837
    augdt        LIKE bseg-augdt,
    awtyp        LIKE bkpf-awtyp,                           "2277019
    awkey        LIKE bkpf-awkey,                           "2277019
    foc_invoice  TYPE xfeld,      "free of charge invoice    "2277019
    reindat      LIKE bkpf-reindat,                         "2438600
    fwsteaa      TYPE aflex15d2o21s,        "(8)  TYPE p,     "783666
    xblnr_alt    LIKE bkpf-xblnr_alt,                       "792331
    wia_adrnr    TYPE adrnr,                                "1035054
    vatdate      LIKE bkpf-vatdate,                         "1023317
    fulfilldate  TYPE fot_fulfilldate,
    sdiff_fc     TYPE aflex15d2o21s, "AFLE enablement. Previously p(8),                 "1104702
    disco_hw     TYPE discohw,                              "1868787
    disco_fw     TYPE discofw,                              "1868787
    venture      TYPE  jv_name,
    equity_group TYPE  jv_egroup,
  END OF ep,


* Feldleiste für Übergabe des selektierten Zeitraums an Druckreport
  fle_umsvz TYPE umsvz.

* Optimization
TABLES:
  bosg.

TYPES : gt_bukrs_sum    LIKE  TABLE OF line_ty_bukrs_sum, "Begin of SRF "2445729
        gt_company_code LIKE TABLE OF tax_rep_company_code,
        gt_euva_list    LIKE TABLE OF fot_s_umsl.

TYPES : BEGIN OF srf_cmp_ins,
          gt_alv_srf      TYPE rfums_tax_gt_alv,
          gt_bukrs_sum    LIKE gt_bukrs_sum,
          gt_company_code LIKE gt_company_code,
          gt_euva_list    LIKE gt_euva_list,
        END OF srf_cmp_ins.

TYPES: BEGIN OF srf_cmp_alv,
         g_repid      TYPE sy-repid,
         it_layout    TYPE slis_layout_alv,
         it_fieldcat  TYPE slis_t_fieldcat_alv,
         it_excluding TYPE  slis_t_extab,
         it_sort      TYPE slis_t_sortinfo_alv,
         i_save       TYPE c,
         is_variant   TYPE disvariant,
         it_events    TYPE slis_t_event,
         is_print     TYPE slis_print_alv,
         var_handl    TYPE slis_handl,
         bhdgd1       TYPE bhdgd,
         final        TYPE srf_cmp_ins,
       END OF srf_cmp_alv.

DATA: gs_srf_cmp_alv     TYPE srf_cmp_alv,
      gt_srf_cmp_alv     TYPE STANDARD TABLE OF srf_cmp_alv WITH HEADER LINE,
      srf_prg            TYPE disextract,
      gt_selection_field TYPE TABLE OF rsparams.

FIELD-SYMBOLS <itab> TYPE STANDARD TABLE. "End of SRF       "2445729

DATA: ls_gsber   TYPE anlz-gsber,
      ls_prctr   TYPE prctr,
      ls_segment TYPE anlz-segment.

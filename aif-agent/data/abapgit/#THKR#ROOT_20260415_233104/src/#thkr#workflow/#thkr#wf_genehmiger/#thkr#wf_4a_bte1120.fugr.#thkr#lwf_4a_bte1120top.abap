FUNCTION-POOL /THKR/WF_4A_BTE1120.          "MESSAGE-ID ..

************************************************************************
*                        NSI Baden-Württemberg                         *
************************************************************************
*  SAP-Release : 700                        EA-PS-Release: 600         *                                     *
*  Objekttyp   :                                                       *
*  Autor       : Sven Schaarschmidt               User-ID: NSI-SCHA    *
*  Auftraggeber: Marcus Schellenberger            User-ID:             *
*  Erstelldatum: 26.11.2008              Transportauftrag: EL1K910150  *
*                                                          EL1K909808
*            *
*  Beschreibung: Realisierung einer 4-Augen-Prüfung für die            *
*                Freigabe von Buchungsbelegen                          *
*                                                                      *
************************************************************************
*                          Änderungen                                  *
************************************************************************
*  Änd.-Nr.    : 001                           Änd.-Datum: 16.02.2009  *
*  Nr. OP-Liste:                         Transportauftrag: EL1K911291  *
*  Bearbeiter  : Sven Schaarschmidt               User-ID: NSI-SCHA    *
*  Auftraggeber:                                  User-ID:             *
*  Beschreibung: Struktur anpassen für Prüfung bei gelöschten          *
*                Zeilen in vorerfassten Belegen                        *
*                                                                      *
************************************************************************
*  Änd.-Nr.    : 002                           Änd.-Datum: 02.04.2009  *
*  Nr. OP-Liste:                         Transportauftrag: EL1K911832  *
*  Bearbeiter  : Sven Schaarschmidt               User-ID: NSI-SCHA    *
*  Auftraggeber:                                  User-ID:             *
*  Beschreibung: Datenelement für Checkresult genutzt, da in           *
*                ZNSI_4A_2_CHECK_PERMISSION auch genutzt.              *
*                Erweiterung der Struktur für erweiterte Vier-Augen-   *
*                Prüfung.                                              *
*                                                                      *
************************************************************************

TYPES: gtype_flag        TYPE c LENGTH 1,
       gtype_t_bseg      TYPE STANDARD TABLE OF bseg,
       gtype_t_bkpf      TYPE STANDARD TABLE OF bkpf,
       gtype_checkresult TYPE /THKR/DTE_WF_CHECKRESULT,
       gtype_t_bsec      TYPE STANDARD TABLE OF bsec.


*   Felder für Prüfung in Personenkontenzeilen
TYPES: BEGIN OF gtype_s_bseg_check_ap_ar,
    BUKRS TYPE BUKRS, "Buchungskreis
    BELNR TYPE BELNR_D, "Belegnummer eines Buchhaltungsbeleges
    GJAHR TYPE GJAHR, "Geschäftsjahr
    BUZEI TYPE BUZEI, "Nummer der Buchungszeile
    BSCHL TYPE BSCHL, "Buchungsschlüssel
    UMSKZ TYPE UMSKZ, "Sonderhauptbuch-Kennzeichen
    UMSKS TYPE UMSKS, "Vorgangsklasse Sonderhauptbuch
    ZUMSK TYPE DZUMSK, "Ziel-Sonderhauptbuch-Kennzeichen
    SHKZG TYPE SHKZG, "Soll-/Haben-Kennzeichen
    GSBER TYPE GSBER, "Geschäftsbereich
    PARGB TYPE PARGB, "Geschäftsbereich des Geschäftspartners
    WRBTR TYPE WRBTR, "Betrag in Belegwährung
    ZUONR TYPE DZUONR, "Zuordnungsnummer
    SGTXT TYPE SGTXT, "Positionstext
    KOSTL TYPE KOSTL, "Kostenstelle
    AUFNR TYPE AUFNR, "Auftragsnummer
    XCPDD TYPE XCPDD, "Kennzeichen: Adresse und Bankdaten indi
    KUNNR TYPE KUNNR, "Debitorennummer 1
    LIFNR TYPE LIFNR, "Kontonummer des Lieferanten
    ZFBDT TYPE DZFBDT, "Basisdatum für Fälligkeitsberechnung
    ZTERM TYPE DZTERM, "Zahlungsbedingungsschlüssel
    ZBD1T TYPE DZBD1T, "Skonto Tage 1
    ZBD2T TYPE DZBD2T, "Skonto Tage 2
    ZBD3T TYPE DZBD3T, "Frist für Nettokondition
    ZBD1P TYPE DZBD1P, "Skonto Prozent 1
    ZBD2P TYPE DZBD2P, "Skonto Prozent 2
*   SKFBT TYPE SKFBT, "Skontofähiger Betrag in Belegwährung
    WSKTO TYPE WSKTO, "Skontobetrag in Belegwährung
    ZLSCH TYPE SCHZW_BSEG, "Zahlweg
    ZLSPR TYPE DZLSPR, "Schlüssel für Zahlungssperre
    ZBFIX TYPE DZBFIX, "Fixierte Zahlungskondition
    HBKID TYPE HBKID, "Kurzschlüssel für eine Hausbank
    BVTYP TYPE BVTYP, "Partnerbanktyp
    REBZG TYPE REBZG, "Belegnummer Rechnung, zu Vorgang gehört
    REBZJ TYPE REBZJ, "GJ zugehörigen Rechnung,
    REBZZ TYPE REBZZ, "Buchungsposition Rechnung
    REBZT TYPE REBZT, "Art des Folgebelegs
    LZBKZ TYPE LZBKZ, "Landeszentralbank-Kennzeichen
    LANDL TYPE LANDL, "Lieferland
    MSCHL TYPE MSCHL, "Mahnschlüssel
    MANSP TYPE MANSP, "Mahnsperre
    MADAT TYPE MADAT, "Datum der letzten Mahnung
    MANST TYPE MAHNS_D, "Mahnstufe
    MABER TYPE MABER, "Mahnbereich
    FIPOS TYPE FIPOS, "Finanzposition
    FISTL TYPE FISTL, "Finanzstelle
    GEBER TYPE BP_GEBER, "Fonds
    XREF1 TYPE XREF1, "Referenzschlüssel des Geschäftspartners
    XREF2 TYPE XREF2, "Referenzschlüssel des Geschäftspartners
    XREF3 TYPE XREF3, "Referenzschlüssel zur Belegposition
    DTWS1 TYPE DTAT16,  "Weisung 1
    DTWS2 TYPE DTAT17,  "Weisung 2
    DTWS3 TYPE DTAT18,  "Weisung 3
    DTWS4 TYPE DTAT19,  "Weisung 4
    SEGMENT TYPE FB_SEGMENT, "Segment
    PSEGMENT TYPE FB_PSEGMENT, "Partnersegment
    PRCTR TYPE PRCTR, "Profitcenter
    HKONT TYPE HKONT, " Hauptbuchkonto
    KOART TYPE KOART, "Kontoart
    XAUTO TYPE XAUTO, " automatische Zeile
END OF gtype_s_bseg_check_ap_ar.

* Prüfung von Sachkonten und Anlagenzeilen
TYPES: BEGIN OF gtype_s_bseg_check_gl_aa,
    BUKRS TYPE BUKRS, "Buchungskreis
    BELNR TYPE BELNR_D, "Belegnummer eines Buchhaltungsbeleges
    GJAHR TYPE GJAHR, "Geschäftsjahr
    BUZEI TYPE BUZEI, "Nummer der Buchungszeile
*   BUZID TYPE BUZID, "Identifikation der Buchungszeile
**    AUGDT TYPE AUGDT, "Datum des Ausgleichs
**    AUGCP TYPE AUGCP, "Tag der Erfassung des Ausgleichs
**    AUGBL TYPE AUGBL, "Belegnummer des Ausgleichsbelegs
    BSCHL TYPE BSCHL, "Buchungsschlüssel
    KOART TYPE KOART, "Kontoart
    UMSKZ TYPE UMSKZ, "Sonderhauptbuch-Kennzeichen
*   UMSKS TYPE UMSKS, "Vorgangsklasse Sonderhauptbuch
*   ZUMSK TYPE DZUMSK, "Ziel-Sonderhauptbuch-Kennzeichen
    SHKZG TYPE SHKZG, "Soll-/Haben-Kennzeichen
    GSBER TYPE GSBER, "Geschäftsbereich
    PARGB TYPE PARGB, "Geschäftsbereich des Geschäftspartners
    MWSKZ TYPE MWSKZ, "Umsatzsteuerkennzeichen
*   QSSKZ TYPE QSSKZ, "Quellensteuerkennzeichen
*   WRBTR TYPE WRBTR, "Betrag in Belegwährung
*   TXBFW TYPE TXBFW, "Urspr. Steuerbasisbetr Belegwährung
*   WMWST TYPE WMWST, "Steuerbetrag in Belegwährung
*   FWBAS TYPE FWBAS, "Steuerbasisbetrag in Belegwährung
*   FWZUZ TYPE FWZUZ, "Zusatzsteuer in Belegwährung
*   SHZUZ TYPE SHZUZ, "Soll/Haben-Zusatz für Skonto
*   MWART TYPE MWART, "Steuerart
    VALUT TYPE VALUT, "Valutadatum
    ZUONR TYPE DZUONR, "Zuordnungsnummer
*   SGTXT TYPE SGTXT, "Positionstext - wird nicht geprüft wegen Subst.
*   ZINKZ TYPE DZINKZ, "Ausnahme von der Verzinsung
*   VBUND TYPE RASSC, "Partner Gesellschaftsnummer
*   BEWAR TYPE RMVCT, "Bewegungsart
**    ALTKT TYPE BILKT_SKA1, "Konzernkontonummer
**    FDLEV TYPE FDLEV, "Finanzdispo-Ebene
**    FDGRP TYPE FDGRP, "Dispositionsgruppe
**    FDWBT TYPE FDWBT, "Dispositionsbetrag in Beleg-
**    FDTAG TYPE FDTAG, "Dispositions-Datum
**    FKONT TYPE FIPLS, "Finanzplanposition
*     KOKRS TYPE KOKRS, "Kostenrechnungskreis
    KOSTL TYPE KOSTL, "Kostenstelle
    AUFNR TYPE AUFNR, "Auftragsnummer
*   VBELN TYPE VBELN_VF, "Faktura
*   VBEL2 TYPE VBELN_VA, "Verkaufsbeleg
*   POSN2 TYPE POSNR_VA, "Verkaufsbelegposition
**    ETEN2 TYPE ETENR, "Einteilungsnummer
    ANLN1 TYPE ANLN1, "Anlagen-Hauptnummer
    ANLN2 TYPE ANLN2, "Anlagenunternummer
    ANBWA TYPE ANBWA, "Anlagen-Bewegungsart
    BZDAT TYPE BZDAT, "Bezugsdatum
**    PERNR TYPE PERNR_D, "Personalnummer
**    XUMSW TYPE XUMSW, "Kennzeichen: Position umsatzwirksam ?
**    XHRES TYPE XHRES, "Kennzeichen: Hauptbuchkonto resident ?
**    XKRES TYPE XKRES, "Kennzeichen: Einzelpostenanzeige
**    XOPVW TYPE XOPVW, "Kennzeichen: Offene-Postenverwaltung ?
*   XCPDD TYPE XCPDD, "Kennzeichen: Adresse und Bankdaten indi
**    XSKST TYPE XSKST, "Kennzeichen: Stat Buchung Kostenstelle
**    XSAUF TYPE XSAUF, "Kennzeichen: Buchung Auftrag stati
**    XSPRO TYPE XSPRO, "Kennzeichen: Buchung Projekt stati
**    XSERG TYPE XSERG, "Kennzeichen: Buchung Ergebnistatistisch
**    XFAKT TYPE XFAKT, "Kennzeichen: Faktura Update erfolgt ?
**    XUMAN TYPE XUMAN, "Kennzeichen: Umbuchung aus Anzahlung ?
*   XANET TYPE XANET, "Kennzeichen: Nettoverfahren ?
**    XSKRL TYPE XSKRL, "Kennzeichen: nicht skontorelevant ?
**    XINVE TYPE XINVE, "Kennzeichen: Investitionsgüter ?
**    XPANZ TYPE XPANZ, "Position anzeigen
    XAUTO TYPE XAUTO, "Kennzeichen: Position automatisch
**    XNCOP TYPE XNCOP, "Kennzeichen: Posten nicht kopierbar ?
**    XZAHL TYPE XZAHL, "Kennzeichen: Zahlungsvorgang ?
    SAKNR TYPE SAKNR, "Nummer des Sachkontos
    HKONT TYPE HKONT, "Sachkonto der Hauptbuchhaltung
*   KUNNR TYPE KUNNR, "Debitorennummer 1
*   LIFNR TYPE LIFNR, "Kontonummer des Lieferanten
**    FILKD TYPE FILKD, "Kontonummer der Filiale
**    XBILK TYPE XBILK, "Kennzeichen: Konto ist Bestandskonto?
**    GVTYP TYPE GVTYP, "Erfolgskontentyp
**    HZUON TYPE HZUON, "Zuordnungsnummer für SHB
    ZFBDT TYPE DZFBDT, "Basisdatum für Fälligkeitsberechnung
*   ZTERM TYPE DZTERM, "Zahlungsbedingungsschlüssel
*   ZBD1T TYPE DZBD1T, "Skonto Tage 1
*   ZBD2T TYPE DZBD2T, "Skonto Tage 2
*   ZBD3T TYPE DZBD3T, "Frist für Nettokondition
*   ZBD1P TYPE DZBD1P, "Skonto Prozent 1
*   ZBD2P TYPE DZBD2P, "Skonto Prozent 2
*   SKFBT TYPE SKFBT, "Skontofähiger Betrag in Belegwährung
*   WSKTO TYPE WSKTO, "Skontobetrag in Belegwährung
*   ZLSCH TYPE SCHZW_BSEG, "Zahlweg
*   ZLSPR TYPE DZLSPR, "Schlüssel für Zahlungssperre
*   ZBFIX TYPE DZBFIX, "Fixierte Zahlungskondition
*   HBKID TYPE HBKID, "Kurzschlüssel für eine Hausbank
*   BVTYP TYPE BVTYP, "Partnerbanktyp
**    NEBTR TYPE NEBTR, "Nettobetrag der Zahlung
**    MWSK1 TYPE MWSKX, "Steuerkennzeichen für Aufteilung
**    WRBT1 TYPE WRBTX, "Betrag Fremdwährung Steueraufteilung
**    MWSK2 TYPE MWSKX, "Steuerkennzeichen Aufteilung
**    WRBT2 TYPE WRBTX, "Betrag Fremdwährung Steueraufteilung
**    MWSK3 TYPE MWSKX, "Steuerkennzeichen für Aufteilung
**    WRBT3 TYPE WRBTX, "Betrag Fremdwährung Steueraufteilung
*   REBZG TYPE REBZG, "Belegnummer Rechnung, zu Vorgang gehört
*   REBZJ TYPE REBZJ, "GJ zugehörigen Rechnung,
*        	REBZZ TYPE REBZZ, "Buchungsposition Rechnung
**    REBZT TYPE REBZT, "Art des Folgebelegs
**    ZOLLT TYPE DZOLLT, "Zolltarifnummer
**    ZOLLD TYPE DZOLLD, "Zoll-Datum
*   LZBKZ TYPE LZBKZ, "Landeszentralbank-Kennzeichen
*   LANDL TYPE LANDL, "Lieferland
**    DIEKZ TYPE DIEKZ, "Dienstleistungskennzeichen
**    SAMNR TYPE SAMNR, "Rechnungslisten-Nummer
**    ABPER TYPE ABPER_RF, "Abrechnungsperiode
**    VRSKZ TYPE VRSKZ, "Versicherungskennzeichen
**    VRSDT TYPE VRSDT, "Versicherungsdatum
**    DISBN TYPE DISBN, "Belegnummer des Wechselver
**    DISBJ TYPE DISBJ, "GJ Wechselverwendungsbelegs
**    DISBZ TYPE DISBZ, "Buzei Wechselverwendungsbelegs
**    WVERW TYPE WVERW, "Art der Wechselverwendung
**    ANFBN TYPE ANFBN, "Belegnummer der Wechselanforderung
**    ANFBJ TYPE ANFBJ, "GJWechselanforderungsbelegs
**    ANFBU TYPE ANFBU, "Buchungskreis
**    ANFAE TYPE ANFAE, "Fälligkeit der Wechselanforderung
**    BLNBT TYPE BLNBT, "Basisbetrag Ermittlung Präferenzbetrags
**    BLNPZ TYPE BLNPZ, "Präferenz-Prozentsatz
*   MSCHL TYPE MSCHL, "Mahnschlüssel
*   MANSP TYPE MANSP, "Mahnsperre
*   MADAT TYPE MADAT, "Datum der letzten Mahnung
*   MANST TYPE MAHNS_D, "Mahnstufe
*   MABER TYPE MABER, "Mahnbereich
**    ESRNR TYPE ESRNR, "ESR-Teilnehmernummer
**    ESRRE TYPE ESRRE, "ESR-Referenznummer
**    ESRPZ TYPE ESRPZ, "ESR-Prüfziffer
**    KLIBT TYPE KLIBT, "Betrag für Kreditkontrolle
**    QSZNR TYPE QSZNR, "Nummer des Zertifikats übe
**    QBSHB TYPE QBSHB, "Quellsteuer-Betrag ( in Belegwährung )
**    QSFBT TYPE QSFBT, "Quellsteuerfr Betrag (Belegwährung )
*   MATNR TYPE MATNR, "Materialnummer
*   WERKS TYPE WERKS_D, "Werk
*   MENGE TYPE MENGE_D, "Menge
*   MEINS TYPE MEINS, "Basismengeneinheit
*   ERFMG TYPE ERFMG, "Menge in Erfassungsmengeneinheit
*   ERFME TYPE ERFME, "Erfassungsmengeneinheit
*   BPMNG TYPE BPMNG, "Menge in Bestellpreismengeneinheit
*   BPRME TYPE BPRME, "Bestellpreismengeneinheit
*   EBELN TYPE EBELN, "Belegnummer des Einkaufsbelegs
*   EBELP TYPE EBELP, "Positionsnummer des Einkaufsbelegs
*   ZEKKN TYPE DZEKKN, "Laufende Nummer der Kontierung
*   ELIKZ TYPE ELIKZ, "Endlieferungskennzeichen
*   VPRSV TYPE VPRSV, "Preissteuerungskennzeichen
*   PEINH TYPE PEINH, "Preiseinheit
**    BWKEY TYPE BWKEY, "Bewertungskreis
**    BWTAR TYPE BWTAR_D, "Bewertungsart
**    BUSTW TYPE BUSTW, "Buchungsstring für Werte
**    REWWR TYPE REFWR, "erfasster Rechnungswert in Fremdwährung
**    BUALT TYPE BUALT, "Buchungsbetrag in alternativer
**    PSALT TYPE PSALT, "Alternative Preissteuerung
**    NPREI TYPE NPREI, "Neuer Preis
**    TBTKZ TYPE TBTKZ, "Kennzeichen: Nachbelastung
**    SPGRP TYPE SPGRP, "Sperrgrund Preis
**    SPGRM TYPE SPGRM, "Sperrgrund Menge
**    SPGRT TYPE SPGRT, "Sperrgrund Termin
**    SPGRG TYPE SPGRG, "Sperrgrund Bestellpreismenge
**    SPGRV TYPE SPGRV, "Sperrgrund Projektbudget
**    SPGRQ TYPE SPGRQ, "Sperrgrund manuell
**    STCEG TYPE STCEG, "Umsatzsteuer-Identifikationsnummer
**    EGBLD TYPE EGBLD, "Bestimmungsland für Warenlieferung
**    EGLLD TYPE EGLLD, "Lieferland bei Warenlieferung
**    RSTGR TYPE RSTGR, "Differenzgrund bei Zahlungen
**    RYACQ TYPE RYACQ, "Zugangsjahr
**    RPACQ TYPE RPACQ, "Zugangsperiode
**    RDIFF TYPE RDIFF, "Realisierter Kursgewinn / Kursverlust
    PRCTR TYPE PRCTR, "Profitcenter
*   XHKOM TYPE XHKOM, "Kz: Hauptbuchkonto manuell kontiert ?
**    VNAME TYPE JV_NAME, "Joint Venture
**    RECID TYPE JV_RECIND, "Kostentyp
**    EGRUP TYPE JV_EGROUP, "Beteiligungsgruppe
**    VPTNR TYPE JV_PART, "Kundennummer des Partners
**    VERTT TYPE RANTYP, "Vertragsart
**    VERTN TYPE RANL, "Vertragsnummer
**    VBEWA TYPE SBEWART, "Bewegungsart
**    DEPOT TYPE RLDEPO, "Depot
**    TXJCD TYPE TXJCD, "Steuerstandort
**    IMKEY TYPE IMKEY, "Interner Schlüssel für Immobilienobjekt
**    DABRZ TYPE DABRBEZ, "Bezugsdatum für Abrechnung
**    POPTS TYPE POPTSATZ, "Optionssatz Immobilien
    FIPOS TYPE FIPOS, "Finanzposition
**    KSTRG TYPE KSTRG, "Kostenträger
**    NPLNR TYPE NPLNR, "Netzplannummer für Kontierung
**    AUFPL TYPE AUFPL_CH, "Plannummer zu Vorgängen im Auftrag
**    APLZL TYPE APLZL_CH, "Allgemeiner Zähler des Auftrags
    PROJK TYPE PS_PSP_PNR, "Projektstrukturplanelement
**    PAOBJNR TYPE RKEOBJNR, "Nummer für Ergebnisobjekte (CO-PA)
**    PASUBNR TYPE RKESUBNR, "Änderungshistorie Ergebnisobjekte
**    SPGRS TYPE SPGRS, "Sperrgrund Betragshöhe
**    SPGRC TYPE SPGRC, "Sperrgrund Qualität
**    BTYPE TYPE JV_BILIND, "Abrechnungstyp
**    ETYPE TYPE JV_ETYPE, "Beteiligungsklasse
**    XEGDR TYPE XEGDR, "Kennzeichen: Dreiecksgeschäft
**    LNRAN TYPE LNRAN, "Nummer des Anlagen-Einzelpostens
**    HRKFT TYPE HRKFT, "Herkunftsgruppe als Untergliederung
**    GLUPM TYPE GLUPM, "Fortschreibungsmethode für FM - FI-CA
**    XRAGL TYPE XRAGL, "Kennzeichen: Ausgleich zurückgenommen
**    UZAWE TYPE UZAWE, "Zusatz zum Zahlweg
**    LOKKT TYPE ALTKT_SKB1, "Alternative Kontonummer
    FISTL TYPE FISTL, "Finanzstelle
    GEBER TYPE BP_GEBER, "Fonds
*        	STBUK TYPE STBUK, "Steuer-Buchungskreis
    PPRCT TYPE PPRCTR, "Partnerprofitcenter
*   XREF1 TYPE XREF1, "Referenzschlüssel des Geschäftspartners
*   XREF2 TYPE XREF2, "Referenzschlüssel des Geschäftspartners
*   KBLNR TYPE KBLNR_FI, "Belegnummer Mittelvormerkung
*   KBLPOS TYPE KBLPOS, "Belegposition Mittelvormerkung
**    STTAX TYPE STTAX, "Steuerbetrag als statistische
**    FKBER TYPE FKBER_SHORT, "Funktionsbereich
**    OBZEI TYPE OBZEI, "Nummer der Buchungszeile im
**    XNEGP TYPE XNEGP, "Kennzeichen: Negativbuchung
**    RFZEI TYPE RFZEI_CC, "Zahlungskarten-Position
**    CCBTC TYPE CCBTC, "Zahlungskarten: Abrechnungslauf
**    KKBER TYPE KKBER, "Kreditkontrollbereich
**    EMPFB TYPE EMPFB, "Zahlungsempfänger / Regulierer
*   XREF3 TYPE XREF3, "Referenzschlüssel zur Belegposition
*   DTWS1 TYPE DTAT16,  "Weisung 1
*   DTWS2 TYPE DTAT17,  "Weisung 2
*   DTWS3 TYPE DTAT18,  "Weisung 3
*   DTWS4 TYPE DTAT19,  "Weisung 4
**    GRICD TYPE J_1AGICD_D, "Tätigkeitskennzeichen
**    GRIRG TYPE REGIO, "Region
**    GITYP TYPE J_1ADTYP_D, "Verteilungsart für Lohnsteuer
**    XPYPR TYPE XPYPR, "Kennzeichen: Zahlungsauftrag
**    KIDNO TYPE KIDNO, "Zahlungsreferenz
**    ABSBT TYPE ABSBT, "Kreditmanagement: Abgesicherter Betrag
**    IDXSP TYPE J_1AINDXSP, "Inflationsindex
**    LINFV TYPE J_1ALINFVL, "Letztes Anpassungsdatum
**    KONTT TYPE KONTT_FI, "Kontierungstyp für Branchenlösung
**    KONTL TYPE KONTL_FI, "Kontierungsleiste
**    TXDAT TYPE TXDAT, "Datum zur Ermittlung der Steuersätze
**    AGZEI TYPE AGZEI, "Ausgleichsposition
**    PYCUR TYPE PYCUR, "Währung für die maschinelle Zahlung
**    PYAMT TYPE PYAMT, "Betrag in Zahlwährung
**    BUPLA TYPE BUPLA, "Geschäftsort
**    SECCO TYPE SECCO, "Quellensteuersektion
**    LSTAR TYPE LSTAR, "Leistungsart
**      CESSION_KZ TYPE CESSION_KZ, "Zessionskennzeichen
**    PRZNR TYPE CO_PRZNR, "Geschäftsprozeß
**    PENDAYS TYPE PDAYS, "Anzahl Tage für Strafzinsberechnung
**    PENRC TYPE PENRC, "Grund für die verspätete Zahlung
**    GRANT_NBR TYPE GM_GRANT_NBR, "Förderung
**    FKBER_LONG TYPE FKBER, "Funktionsbereich
**    GMVKZ TYPE FM_GMVKZ, "Posten in Vollstreckung
**    SRTYPE TYPE FM_SRTYPE, "Art der Nebenforderung
**    INTRENO TYPE VVINTRENO, "Interne Immobilien
**    MEASURE TYPE FM_MEASURE, "Haushaltsprogramm
**    AUGGJ TYPE AUGGJ, "Geschäftsjahr des Ausgleichsbelegs
**    PPA_EX_IND TYPE EXCLUDE_FLG, "Exklusiv / Inklusiv Flag
**    DOCLN TYPE DOCLN6, "Sechsstellige Buchungszeile für Ledger
    SEGMENT TYPE FB_SEGMENT, "Segment
    PSEGMENT TYPE FB_PSEGMENT, "Partnersegment
**    PFKBER TYPE SFKBER, "Funktionsbereich des Partners
**    HKTID TYPE HKTID, "Kurzschlüssel für eine Kontenverbindung
**    KSTAR TYPE KSTAR, "Kostenart
**    PRODPER TYPE JV_PRODPER, "Produktionsmonat
END OF gtype_s_bseg_check_gl_aa.

TYPES: BEGIN OF gtype_s_bkpf_check,
  bukrs TYPE bukrs,
  belnr TYPE belnr,
  gjahr TYPE gjahr,
  xblnr TYPE xblnr,
  bktxt TYPE bktxt,
  budat TYPE budat,
  bldat TYPE bldat,
  monat TYPE monat,
  blart TYPE blart,
END OF gtype_s_bkpf_check.

TYPES: gtype_t_bkpf_check TYPE STANDARD TABLE OF gtype_s_bkpf_check.

*TYPES: BEGIN OF gtype_s_bseg_check,
*   BUKRS TYPE BUKRS, "Buchungskreis
*   BELNR TYPE BELNR_D, "Belegnummer eines Buchhaltungsbeleges
*   GJAHR TYPE GJAHR, "Geschäftsjahr
*   BUZEI TYPE BUZEI, "Nummer der Buchungszeile
*   BUZID TYPE BUZID, "Identifikation der Buchungszeile
**    AUGDT TYPE AUGDT, "Datum des Ausgleichs
**    AUGCP TYPE AUGCP, "Tag der Erfassung des Ausgleichs
**    AUGBL TYPE AUGBL, "Belegnummer des Ausgleichsbelegs
*   BSCHL TYPE BSCHL, "Buchungsschlüssel
*   KOART TYPE KOART, "Kontoart
*   UMSKZ TYPE UMSKZ, "Sonderhauptbuch-Kennzeichen
*   UMSKS TYPE UMSKS, "Vorgangsklasse Sonderhauptbuch
*   ZUMSK TYPE DZUMSK, "Ziel-Sonderhauptbuch-Kennzeichen
*   SHKZG TYPE SHKZG, "Soll-/Haben-Kennzeichen
*   GSBER TYPE GSBER, "Geschäftsbereich
*   PARGB TYPE PARGB, "Geschäftsbereich des Geschäftspartners
*   MWSKZ TYPE MWSKZ, "Umsatzsteuerkennzeichen
*   QSSKZ TYPE QSSKZ, "Quellensteuerkennzeichen
*   WRBTR TYPE WRBTR, "Betrag in Belegwährung
*   TXBFW TYPE TXBFW, "Urspr. Steuerbasisbetr Belegwährung
*   WMWST TYPE WMWST, "Steuerbetrag in Belegwährung
*   FWBAS TYPE FWBAS, "Steuerbasisbetrag in Belegwährung
*   FWZUZ TYPE FWZUZ, "Zusatzsteuer in Belegwährung
*   SHZUZ TYPE SHZUZ, "Soll/Haben-Zusatz für Skonto
*   MWART TYPE MWART, "Steuerart
*   VALUT TYPE VALUT, "Valutadatum
*   ZUONR TYPE DZUONR, "Zuordnungsnummer
*   SGTXT TYPE SGTXT, "Positionstext
*   ZINKZ TYPE DZINKZ, "Ausnahme von der Verzinsung
*   VBUND TYPE RASSC, "Partner Gesellschaftsnummer
*   BEWAR TYPE RMVCT, "Bewegungsart
**    ALTKT TYPE BILKT_SKA1, "Konzernkontonummer
**    FDLEV TYPE FDLEV, "Finanzdispo-Ebene
**    FDGRP TYPE FDGRP, "Dispositionsgruppe
**    FDWBT TYPE FDWBT, "Dispositionsbetrag in Beleg-
**    FDTAG TYPE FDTAG, "Dispositions-Datum
**    FKONT TYPE FIPLS, "Finanzplanposition
*     KOKRS TYPE KOKRS, "Kostenrechnungskreis
*   KOSTL TYPE KOSTL, "Kostenstelle
*   AUFNR TYPE AUFNR, "Auftragsnummer
*   VBELN TYPE VBELN_VF, "Faktura
*   VBEL2 TYPE VBELN_VA, "Verkaufsbeleg
*   POSN2 TYPE POSNR_VA, "Verkaufsbelegposition
**    ETEN2 TYPE ETENR, "Einteilungsnummer
*   ANLN1 TYPE ANLN1, "Anlagen-Hauptnummer
*   ANLN2 TYPE ANLN2, "Anlagenunternummer
*   ANBWA TYPE ANBWA, "Anlagen-Bewegungsart
*   BZDAT TYPE BZDAT, "Bezugsdatum
**    PERNR TYPE PERNR_D, "Personalnummer
**    XUMSW TYPE XUMSW, "Kennzeichen: Position umsatzwirksam ?
**    XHRES TYPE XHRES, "Kennzeichen: Hauptbuchkonto resident ?
**    XKRES TYPE XKRES, "Kennzeichen: Einzelpostenanzeige
**    XOPVW TYPE XOPVW, "Kennzeichen: Offene-Postenverwaltung ?
*   XCPDD TYPE XCPDD, "Kennzeichen: Adresse und Bankdaten indi
**    XSKST TYPE XSKST, "Kennzeichen: Stat Buchung Kostenstelle
**    XSAUF TYPE XSAUF, "Kennzeichen: Buchung Auftrag stati
**    XSPRO TYPE XSPRO, "Kennzeichen: Buchung Projekt stati
**    XSERG TYPE XSERG, "Kennzeichen: Buchung Ergebnistatistisch
**    XFAKT TYPE XFAKT, "Kennzeichen: Faktura Update erfolgt ?
**    XUMAN TYPE XUMAN, "Kennzeichen: Umbuchung aus Anzahlung ?
**    XANET TYPE XANET, "Kennzeichen: Nettoverfahren ?
**    XSKRL TYPE XSKRL, "Kennzeichen: nicht skontorelevant ?
**    XINVE TYPE XINVE, "Kennzeichen: Investitionsgüter ?
**    XPANZ TYPE XPANZ, "Position anzeigen
**    XAUTO TYPE XAUTO, "Kennzeichen: Position automatisch
**    XNCOP TYPE XNCOP, "Kennzeichen: Posten nicht kopierbar ?
**    XZAHL TYPE XZAHL, "Kennzeichen: Zahlungsvorgang ?
**    SAKNR TYPE SAKNR, "Nummer des Sachkontos
**    HKONT TYPE HKONT, "Sachkonto der Hauptbuchhaltung
*   KUNNR TYPE KUNNR, "Debitorennummer 1
*   LIFNR TYPE LIFNR, "Kontonummer des Lieferanten
**    FILKD TYPE FILKD, "Kontonummer der Filiale
**    XBILK TYPE XBILK, "Kennzeichen: Konto ist Bestandskonto?
**    GVTYP TYPE GVTYP, "Erfolgskontentyp
**    HZUON TYPE HZUON, "Zuordnungsnummer für SHB
*   ZFBDT TYPE DZFBDT, "Basisdatum für Fälligkeitsberechnung
*   ZTERM TYPE DZTERM, "Zahlungsbedingungsschlüssel
*   ZBD1T TYPE DZBD1T, "Skonto Tage 1
*   ZBD2T TYPE DZBD2T, "Skonto Tage 2
*   ZBD3T TYPE DZBD3T, "Frist für Nettokondition
*   ZBD1P TYPE DZBD1P, "Skonto Prozent 1
*   ZBD2P TYPE DZBD2P, "Skonto Prozent 2
*   SKFBT TYPE SKFBT, "Skontofähiger Betrag in Belegwährung
*   WSKTO TYPE WSKTO, "Skontobetrag in Belegwährung
*   ZLSCH TYPE SCHZW_BSEG, "Zahlweg
*   ZLSPR TYPE DZLSPR, "Schlüssel für Zahlungssperre
*   ZBFIX TYPE DZBFIX, "Fixierte Zahlungskondition
*   HBKID TYPE HBKID, "Kurzschlüssel für eine Hausbank
*   BVTYP TYPE BVTYP, "Partnerbanktyp
**    NEBTR TYPE NEBTR, "Nettobetrag der Zahlung
**    MWSK1 TYPE MWSKX, "Steuerkennzeichen für Aufteilung
**    WRBT1 TYPE WRBTX, "Betrag Fremdwährung Steueraufteilung
**    MWSK2 TYPE MWSKX, "Steuerkennzeichen Aufteilung
**    WRBT2 TYPE WRBTX, "Betrag Fremdwährung Steueraufteilung
**    MWSK3 TYPE MWSKX, "Steuerkennzeichen für Aufteilung
**    WRBT3 TYPE WRBTX, "Betrag Fremdwährung Steueraufteilung
*   REBZG TYPE REBZG, "Belegnummer Rechnung, zu Vorgang gehört
*   REBZJ TYPE REBZJ, "GJ zugehörigen Rechnung,
*        	REBZZ TYPE REBZZ, "Buchungsposition Rechnung
**    REBZT TYPE REBZT, "Art des Folgebelegs
**    ZOLLT TYPE DZOLLT, "Zolltarifnummer
**    ZOLLD TYPE DZOLLD, "Zoll-Datum
*   LZBKZ TYPE LZBKZ, "Landeszentralbank-Kennzeichen
*   LANDL TYPE LANDL, "Lieferland
**    DIEKZ TYPE DIEKZ, "Dienstleistungskennzeichen
**    SAMNR TYPE SAMNR, "Rechnungslisten-Nummer
**    ABPER TYPE ABPER_RF, "Abrechnungsperiode
**    VRSKZ TYPE VRSKZ, "Versicherungskennzeichen
**    VRSDT TYPE VRSDT, "Versicherungsdatum
**    DISBN TYPE DISBN, "Belegnummer des Wechselver
**    DISBJ TYPE DISBJ, "GJ Wechselverwendungsbelegs
**    DISBZ TYPE DISBZ, "Buzei Wechselverwendungsbelegs
**    WVERW TYPE WVERW, "Art der Wechselverwendung
**    ANFBN TYPE ANFBN, "Belegnummer der Wechselanforderung
**    ANFBJ TYPE ANFBJ, "GJWechselanforderungsbelegs
**    ANFBU TYPE ANFBU, "Buchungskreis
**    ANFAE TYPE ANFAE, "Fälligkeit der Wechselanforderung
**    BLNBT TYPE BLNBT, "Basisbetrag Ermittlung Präferenzbetrags
**    BLNPZ TYPE BLNPZ, "Präferenz-Prozentsatz
*   MSCHL TYPE MSCHL, "Mahnschlüssel
*   MANSP TYPE MANSP, "Mahnsperre
*   MADAT TYPE MADAT, "Datum der letzten Mahnung
*   MANST TYPE MAHNS_D, "Mahnstufe
*   MABER TYPE MABER, "Mahnbereich
**    ESRNR TYPE ESRNR, "ESR-Teilnehmernummer
**    ESRRE TYPE ESRRE, "ESR-Referenznummer
**    ESRPZ TYPE ESRPZ, "ESR-Prüfziffer
**    KLIBT TYPE KLIBT, "Betrag für Kreditkontrolle
**    QSZNR TYPE QSZNR, "Nummer des Zertifikats übe
**    QBSHB TYPE QBSHB, "Quellsteuer-Betrag ( in Belegwährung )
**    QSFBT TYPE QSFBT, "Quellsteuerfr Betrag (Belegwährung )
*   MATNR TYPE MATNR, "Materialnummer
*   WERKS TYPE WERKS_D, "Werk
*   MENGE TYPE MENGE_D, "Menge
*   MEINS TYPE MEINS, "Basismengeneinheit
*   ERFMG TYPE ERFMG, "Menge in Erfassungsmengeneinheit
*   ERFME TYPE ERFME, "Erfassungsmengeneinheit
*   BPMNG TYPE BPMNG, "Menge in Bestellpreismengeneinheit
*   BPRME TYPE BPRME, "Bestellpreismengeneinheit
*   EBELN TYPE EBELN, "Belegnummer des Einkaufsbelegs
*   EBELP TYPE EBELP, "Positionsnummer des Einkaufsbelegs
*   ZEKKN TYPE DZEKKN, "Laufende Nummer der Kontierung
*   ELIKZ TYPE ELIKZ, "Endlieferungskennzeichen
*   VPRSV TYPE VPRSV, "Preissteuerungskennzeichen
*   PEINH TYPE PEINH, "Preiseinheit
**    BWKEY TYPE BWKEY, "Bewertungskreis
**    BWTAR TYPE BWTAR_D, "Bewertungsart
**    BUSTW TYPE BUSTW, "Buchungsstring für Werte
**    REWWR TYPE REFWR, "erfasster Rechnungswert in Fremdwährung
**    BUALT TYPE BUALT, "Buchungsbetrag in alternativer
**    PSALT TYPE PSALT, "Alternative Preissteuerung
**    NPREI TYPE NPREI, "Neuer Preis
**    TBTKZ TYPE TBTKZ, "Kennzeichen: Nachbelastung
**    SPGRP TYPE SPGRP, "Sperrgrund Preis
**    SPGRM TYPE SPGRM, "Sperrgrund Menge
**    SPGRT TYPE SPGRT, "Sperrgrund Termin
**    SPGRG TYPE SPGRG, "Sperrgrund Bestellpreismenge
**    SPGRV TYPE SPGRV, "Sperrgrund Projektbudget
**    SPGRQ TYPE SPGRQ, "Sperrgrund manuell
**    STCEG TYPE STCEG, "Umsatzsteuer-Identifikationsnummer
**    EGBLD TYPE EGBLD, "Bestimmungsland für Warenlieferung
**    EGLLD TYPE EGLLD, "Lieferland bei Warenlieferung
**    RSTGR TYPE RSTGR, "Differenzgrund bei Zahlungen
**    RYACQ TYPE RYACQ, "Zugangsjahr
**    RPACQ TYPE RPACQ, "Zugangsperiode
**    RDIFF TYPE RDIFF, "Realisierter Kursgewinn / Kursverlust
*   PRCTR TYPE PRCTR, "Profitcenter
*   XHKOM TYPE XHKOM, "Kz: Hauptbuchkonto manuell kontiert ?
**    VNAME TYPE JV_NAME, "Joint Venture
**    RECID TYPE JV_RECIND, "Kostentyp
**    EGRUP TYPE JV_EGROUP, "Beteiligungsgruppe
**    VPTNR TYPE JV_PART, "Kundennummer des Partners
**    VERTT TYPE RANTYP, "Vertragsart
**    VERTN TYPE RANL, "Vertragsnummer
**    VBEWA TYPE SBEWART, "Bewegungsart
**    DEPOT TYPE RLDEPO, "Depot
**    TXJCD TYPE TXJCD, "Steuerstandort
**    IMKEY TYPE IMKEY, "Interner Schlüssel für Immobilienobjekt
**    DABRZ TYPE DABRBEZ, "Bezugsdatum für Abrechnung
**    POPTS TYPE POPTSATZ, "Optionssatz Immobilien
*     FIPOS TYPE FIPOS, "Finanzposition
**    KSTRG TYPE KSTRG, "Kostenträger
**    NPLNR TYPE NPLNR, "Netzplannummer für Kontierung
**    AUFPL TYPE AUFPL_CH, "Plannummer zu Vorgängen im Auftrag
**    APLZL TYPE APLZL_CH, "Allgemeiner Zähler des Auftrags
*   PROJK TYPE PS_PSP_PNR, "Projektstrukturplanelement
**    PAOBJNR TYPE RKEOBJNR, "Nummer für Ergebnisobjekte (CO-PA)
**    PASUBNR TYPE RKESUBNR, "Änderungshistorie Ergebnisobjekte
**    SPGRS TYPE SPGRS, "Sperrgrund Betragshöhe
**    SPGRC TYPE SPGRC, "Sperrgrund Qualität
**    BTYPE TYPE JV_BILIND, "Abrechnungstyp
**    ETYPE TYPE JV_ETYPE, "Beteiligungsklasse
**    XEGDR TYPE XEGDR, "Kennzeichen: Dreiecksgeschäft
**    LNRAN TYPE LNRAN, "Nummer des Anlagen-Einzelpostens
**    HRKFT TYPE HRKFT, "Herkunftsgruppe als Untergliederung
**    GLUPM TYPE GLUPM, "Fortschreibungsmethode für FM - FI-CA
**    XRAGL TYPE XRAGL, "Kennzeichen: Ausgleich zurückgenommen
**    UZAWE TYPE UZAWE, "Zusatz zum Zahlweg
**    LOKKT TYPE ALTKT_SKB1, "Alternative Kontonummer
*   FISTL TYPE FISTL, "Finanzstelle
*   GEBER TYPE BP_GEBER, "Fonds
*        	STBUK TYPE STBUK, "Steuer-Buchungskreis
*   PPRCT TYPE PPRCTR, "Partnerprofitcenter
*   XREF1 TYPE XREF1, "Referenzschlüssel des Geschäftspartners
*   XREF2 TYPE XREF2, "Referenzschlüssel des Geschäftspartners
*   KBLNR TYPE KBLNR_FI, "Belegnummer Mittelvormerkung
*   KBLPOS TYPE KBLPOS, "Belegposition Mittelvormerkung
**    STTAX TYPE STTAX, "Steuerbetrag als statistische
**    FKBER TYPE FKBER_SHORT, "Funktionsbereich
**    OBZEI TYPE OBZEI, "Nummer der Buchungszeile im
**    XNEGP TYPE XNEGP, "Kennzeichen: Negativbuchung
**    RFZEI TYPE RFZEI_CC, "Zahlungskarten-Position
**    CCBTC TYPE CCBTC, "Zahlungskarten: Abrechnungslauf
**    KKBER TYPE KKBER, "Kreditkontrollbereich
**    EMPFB TYPE EMPFB, "Zahlungsempfänger / Regulierer
*   XREF3 TYPE XREF3, "Referenzschlüssel zur Belegposition
*   DTWS1 TYPE DTAT16,  "Weisung 1
*   DTWS2 TYPE DTAT17,  "Weisung 2
*   DTWS3 TYPE DTAT18,  "Weisung 3
*   DTWS4 TYPE DTAT19,  "Weisung 4
**    GRICD TYPE J_1AGICD_D, "Tätigkeitskennzeichen
**    GRIRG TYPE REGIO, "Region
**    GITYP TYPE J_1ADTYP_D, "Verteilungsart für Lohnsteuer
**    XPYPR TYPE XPYPR, "Kennzeichen: Zahlungsauftrag
**    KIDNO TYPE KIDNO, "Zahlungsreferenz
**    ABSBT TYPE ABSBT, "Kreditmanagement: Abgesicherter Betrag
**    IDXSP TYPE J_1AINDXSP, "Inflationsindex
**    LINFV TYPE J_1ALINFVL, "Letztes Anpassungsdatum
**    KONTT TYPE KONTT_FI, "Kontierungstyp für Branchenlösung
**    KONTL TYPE KONTL_FI, "Kontierungsleiste
**    TXDAT TYPE TXDAT, "Datum zur Ermittlung der Steuersätze
**    AGZEI TYPE AGZEI, "Ausgleichsposition
**    PYCUR TYPE PYCUR, "Währung für die maschinelle Zahlung
**    PYAMT TYPE PYAMT, "Betrag in Zahlwährung
**    BUPLA TYPE BUPLA, "Geschäftsort
**    SECCO TYPE SECCO, "Quellensteuersektion
**    LSTAR TYPE LSTAR, "Leistungsart
**      CESSION_KZ TYPE CESSION_KZ, "Zessionskennzeichen
**    PRZNR TYPE CO_PRZNR, "Geschäftsprozeß
**    PENDAYS TYPE PDAYS, "Anzahl Tage für Strafzinsberechnung
**    PENRC TYPE PENRC, "Grund für die verspätete Zahlung
**    GRANT_NBR TYPE GM_GRANT_NBR, "Förderung
**    FKBER_LONG TYPE FKBER, "Funktionsbereich
**    GMVKZ TYPE FM_GMVKZ, "Posten in Vollstreckung
**    SRTYPE TYPE FM_SRTYPE, "Art der Nebenforderung
**    INTRENO TYPE VVINTRENO, "Interne Immobilien
**    MEASURE TYPE FM_MEASURE, "Haushaltsprogramm
**    AUGGJ TYPE AUGGJ, "Geschäftsjahr des Ausgleichsbelegs
**    PPA_EX_IND TYPE EXCLUDE_FLG, "Exklusiv / Inklusiv Flag
**    DOCLN TYPE DOCLN6, "Sechsstellige Buchungszeile für Ledger
*   SEGMENT TYPE FB_SEGMENT, "Segment
*   PSEGMENT TYPE FB_PSEGMENT, "Partnersegment
**    PFKBER TYPE SFKBER, "Funktionsbereich des Partners
**    HKTID TYPE HKTID, "Kurzschlüssel für eine Kontenverbindung
**    KSTAR TYPE KSTAR, "Kostenart
**    PRODPER TYPE JV_PRODPER, "Produktionsmonat
*END OF gtype_s_bseg_check.

TYPES: BEGIN OF gtype_buzei_v_post,
         vbuzei LIKE bseg-buzei,
         post_buzei LIKE bseg-buzei,
       END OF gtype_buzei_v_post.

TYPES: gtype_t_buzei_v_post TYPE STANDARD TABLE OF gtype_buzei_v_post.

* Ergänzung für Erweiterung der Vier-Augen-Prüfung
TYPES: gtype_t_tagrp TYPE STANDARD TABLE OF /THKR/C4A_tagrp2,
       gtype_t_awgrp TYPE STANDARD TABLE OF /THKR/C4A_awgrp2,
       gtype_t_ktoin TYPE STANDARD TABLE OF /THKR/C4A_ktoin2,
       gtype_t_flexg TYPE STANDARD TABLE OF /THKR/C4A_flexg2,
       gtype_t_vorga TYPE STANDARD TABLE OF /THKR/C4A_vorga2.
* INCLUDE /THKR/LWF_4A_BTE1120D...           " Local class definition

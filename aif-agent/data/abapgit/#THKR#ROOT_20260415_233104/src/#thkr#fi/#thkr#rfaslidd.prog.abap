**********************************************************************
*                                                                    *
*       Include RFASLIDD mit Daten-Deklarationsteil für die          *
*       Zusammenfassende Meldung (RFASLMxx und RFASLDxx)             *
*                                                                    *
**********************************************************************



*---------------------------------------------------------------------*
*       Deklarationsteil (Tables- und Data-Anweisungen)               *
*---------------------------------------------------------------------*
TABLES:
  aslm,                                "SAPscript-Übergabetabelle
  bhdgd,                               "Batch-Heading
  bkpf,                                "Belegkopf
  bsec,                                "Belegsegment CPD-Daten  YHR-01
  bseg,                                "Belegsegment
  bsega,                               "Belegsegment (Beträge)
  bset,                                "Betrag aus Steuerzeilen
  itcpo,                               "SAPscript Parameter OPEN
  itcpp,                               "SAPscript Parameter CLOSE
  kna1,                                "Debitoren-Adressinformation
  knas,                                "Kundenstamm (allgemeiner Teil
  "EG-Steuernummern) "530539
  vbrk,                                "Faktura: Kopfdaten  "530539
  vbpa,                                "Vertriebsbeleg: Partner "530539
  lfa1,                                "Kreditoren-Adressinformation
  sadr,                                "Adresse Buchungskreis
  stxh,                                "Formulare
  t001,                                "Buchungskreis
  t001n,                               "Vermerke bei WiA
  t001z,                               "Zulassungsvermerke
  t005,                                "Land (Kalkulationsschema)
  t007a,                               "Mehrwertsteuerkennzeichen
  t007f,                               "Umsatzsteuerkreise
  t100,                                "Messages
  tcurx,                               "Dezimalstellen
  tsp03,                               "Drucker
  tcurc,                               "Währungen
  tcurt,                               "Währungsbezeichnung
  pri_params,                          "Druckparameter
  sscrfields,
  bosg,                                "Oberstes Hierarchiesegment BRF          "3046753
  bsegh.                               "Hilfstabelle Reportauswertungsprogramme "3046753

TABLES: taltwar.

CONSTANTS gc_filename                                       "n1517472
  TYPE fileintern                                           "n1517472
  VALUE 'FI_TAX'.                                           "n1517472

FIELD-SYMBOLS: <fs_repid> TYPE syrepid.

CONSTANTS: gc_external_audit_scenario TYPE scen_name VALUE 'EXTERNAL_AUDIT',
           gc_saisacc_doc             TYPE tabname VALUE '/SAIS/ACC_DOC'.

DATA: gv_external_audit_check TYPE abap_bool VALUE abap_false,
      gt_granted_intv         TYPE RANGE OF dats.

DATA gd_pertyp TYPE aslmpertyp.                             "870277

DATA: gs_sadr_adobe      TYPE sadr,                                  "PDF
      gt_aslm_adobe      TYPE aslm_t,                                "PDF
      gs_aslm_adobe      LIKE LINE OF gt_aslm_adobe,                 "PDF
      gd_pdf_form, gd_scr_form TYPE c,                          "PDF
      gs_t001_adobe      TYPE t001,                                  "PDF
      gt_idxparams_adobe TYPE tfpdara.                          "PDF

DATA:
  flg_bset(1)      TYPE c,             "BSET interpretieren ist möglich
  flg_liste(1)     TYPE c,             "Titel für die Liste
  flg_umkrs(1)     TYPE c,             "Umsatzsteuerkreise selektiert
  flg_xwia(1)      TYPE c,             "Werke im Ausland aktiv
  flg_txa_active   TYPE abap_bool,     "Tax Abroad active
  flg_txa_act_test TYPE abap_bool,     "Tax Abroad active (flag for test only)
  hlp_buzei        LIKE bseg-buzei,    "Buchungszeile mit USt-ID-Nr.
  hlp_datum        TYPE d,             "Datum
  hlp_dmshb        LIKE bsega-dmshb,   "Bemessungsgrundlage
  hlp_ind(1)       TYPE c,             "Indikator Ware/Dienstl.
  hlp_xegcos       TYPE xegcos,        "Konsignation                  "2854595
  hlp_stceg_orig   TYPE stceg_orig,    "UIN orig. Erwerber            "2854595
  hlp_name1_orig   TYPE name1_orig,    "Name orig. Erwerber           "2854595
  hlp_koart        LIKE bseg-koart,    "Kontoart
  hlp_ktnra        LIKE bseg-kunnr,    "Debitoren-/Kreditorennummer
  hlp_line1(132)   TYPE c,             "erste Überschriftszeile
  hlp_line2(132)   TYPE c,             "zweite Überschriftszeile
  hlp_stceg        LIKE bseg-stceg,    "USt-ID-Nr.
  hlp_subtr(3)     TYPE p,             "Verminderung der laufenden Nr.
  hlp_text(132)    TYPE c,             "Text zur Ausgabe
  hlp_umkrs        LIKE t007f-umkrs,   "Umsatzsteuerkreis
  hlp_xegdr        LIKE bseg-xegdr,    "Dreiecksgeschäft
  hlp_zeilen(2)    TYPE p,             "Anzahl Tabelleneinträge
  hlp_euro(1)      TYPE c,             "Meldung in EURO (für DE)
  hlp_dekr         TYPE c,             "Debi- oder Kreditorenrechnung
  hlp_name1        LIKE kna1-name1,                         "530539
  hlp_stras        LIKE kna1-stras,                         "530539
  hlp_ort01        LIKE kna1-ort01,                         "530539
  hlp_pstlz        LIKE kna1-pstlz,                         "530539
  print_par        TYPE itcpo,
  index            TYPE i,                                  "530539
  xumsw            TYPE c,                                  "590441
  ls_dd02v_wa_bseg TYPE dd02v,                              "3046753
  ls_dd02v_wa_bset TYPE dd02v.                              "3046753

* data related to authority checks in optimized case        "3046753
DATA: gd_cnt_no_auth TYPE i,                                "3046753
      gr_auth_gsber  TYPE RANGE OF bseg-gsber,              "3046753
      gr_auth_blart  TYPE RANGE OF bkpf-blart.              "3046753

DATA: gr_auth_fkber TYPE RANGE OF bseg-fkber.
*  BEGIN OF hex00,
*    hex(4) TYPE x VALUE '00000000',
*  END OF hex00,

CLASS: cl_abap_char_utilities DEFINITION LOAD.              "635026

DATA: BEGIN OF low_value,                                   "635026
        space TYPE c,                                       "635026
        low   TYPE c,                                       "635026
      END   OF low_value.                                   "635026
low_value-low   = cl_abap_char_utilities=>minchar.          "635026

DATA: BEGIN OF hex00,                                       "635026
        x00(4) TYPE c,                                      "635026
      END OF hex00.                                         "635026
TRANSLATE hex00    USING low_value.                         "635026

DATA: tab_bset       TYPE TABLE OF bset,                    "2252566
      gd_tax_auditor TYPE xfeld.                            "2252566

DATA: BEGIN OF mikfi,                "Info in der Mikrofichezeile
        bukrs    LIKE bkpf-bukrs,    "(Einzelpostenliste)
        stceg    LIKE bseg-stceg,
        belnr    LIKE bkpf-belnr,
        buzei(3) TYPE n,
      END OF mikfi,

      BEGIN OF tab OCCURS 5,               "Tabelle mit den Informationen
        bukrs    LIKE bkpf-bukrs,    "für die Zusammenfassende Meldung
        lfdnr(8) TYPE n,
        belnr    LIKE bkpf-belnr,                         "YHR-01
        gjahr    LIKE bkpf-gjahr,                         "YHR-01
        stceg    LIKE bseg-stceg,
        koart    LIKE bseg-koart,
        ktnra    LIKE bseg-kunnr,
        dmshb    LIKE bsega-dmshb,
        ind(1)   TYPE c,
        xegdr    LIKE bseg-xegdr,
        name1    LIKE kna1-name1,                           "530539
        stras    LIKE kna1-stras,                           "530539
        ort01    LIKE kna1-ort01,                           "530539
        pstlz    LIKE kna1-pstlz,                           "530539
        xegcos   TYPE xegcos,                               "2898168
      END OF tab,

      BEGIN OF tab_bseg OCCURS 5,          "Tabelle mit den Informationen
        buzei       LIKE bseg-buzei,    "aus der Belegzeile
        stceg       LIKE bseg-stceg,
        dmshb       LIKE bsega-dmshb,
        tax_country LIKE bseg-tax_country,
        mwskz       LIKE bseg-mwskz,
        txdat_from  LIKE bseg-txdat_from,
        ind(1)      TYPE c,
        xegdr       LIKE bseg-xegdr,
        xbset(1)    TYPE c,             "X - Steuerbetrag aus BSET
        bschl       TYPE bseg-bschl,                        "N601415
        koart       TYPE bseg-koart,                        "N601415
        umskz       TYPE bseg-umskz,                        "N601415
        shkzg       TYPE bseg-shkzg,                        "N601415
        gsber       TYPE bseg-gsber,
        fkber       TYPE bseg-fkber,                    "N601415
        dmbtr       TYPE bseg-dmbtr,                        "N601415
        wrbtr       TYPE bseg-wrbtr,                        "N601415
        hwbas       TYPE bseg-hwbas,                        "N601415
        fwbas       TYPE bseg-fwbas,                        "N601415
        valut       TYPE bseg-valut,                        "N601415
        zuonr       TYPE bseg-zuonr,                        "N601415
        sgtxt       TYPE bseg-sgtxt,                        "N601415
        kokrs       TYPE bseg-kokrs,                        "N601415
        kostl       TYPE bseg-kostl,                        "N601415
        aufnr       TYPE bseg-aufnr,                        "N601415
        vbeln       TYPE bseg-vbeln,                        "N601415
        vbel2       TYPE bseg-vbel2,                        "N601415
        posn2       TYPE bseg-posn2,                        "N601415
        zfbdt       TYPE bseg-zfbdt,                        "N601415
        eglld       TYPE bseg-eglld,                        "N601415
        egbld       TYPE bseg-egbld,                        "N601415
        stbuk       TYPE bseg-stbuk,                        "N601415
        umsks       TYPE bseg-umsks,                        "1434854
        rebzt       TYPE xfeld,                             "1434854
      END OF tab_bseg,

      BEGIN OF tab_output OCCURS 4,        "Listdatasets bei der Ausgabe:
        bukrs(20) TYPE c,             "Flag 1  Einzelpostenliste
        flag(1)   TYPE n,             " 2  Zusammenfassende Meldung
        name(6)   TYPE c,             " 3  Brief zum Datentraeger
        spono     LIKE sy-spono,      " 4  Datentraeger
        file      LIKE rfpdo1-allgunix,   " 5  Fehlermeldungen
        busobj    TYPE saeanwdid,         " 6  Archiv ZM    "766359
        dokart    TYPE saeobjart,                           "766359
        objid     TYPE saeobjid,                            "766359
        fica_num  TYPE num8,          " 8  FI-CA Interface  "1413492
        fica_msg  TYPE char128,       " 8  FI-CA Interface  "1413492
      END OF tab_output,

      BEGIN OF tab_t001 OCCURS 5.          "Daten zum Buchungskreis
        INCLUDE STRUCTURE t001.
DATA: END OF tab_t001,

BEGIN OF tab_t005 OCCURS 5,            "Land zum Buchungskreis
  land1 LIKE t005-land1,      "(Kalkulationsschema für T007A)
  kalsm LIKE t005-kalsm,
END OF tab_t005,

BEGIN OF tab_t007a OCCURS 10,          "Info, ob es sich um Umsätze in
  kalsm LIKE t007a-kalsm,     "der EG handelt
  mwskz LIKE t007a-mwskz,
  mwart LIKE t007a-mwart,
  egrkz LIKE t007a-egrkz,
  lstml LIKE t007a-lstml,
END OF tab_t007a,

BEGIN OF err_stceg OCCURS 1,           "USt-ID-Nr. des Debitoren ist
  bukrs LIKE bkpf-bukrs,      "nicht gefüllt, daher keine
  belnr LIKE bkpf-belnr,      "Behandlung der Belegposition
  buzei LIKE bseg-buzei,
END OF err_stceg.

DATA: gs_tab_bseg_dk LIKE LINE OF tab_bseg.                 "949656

* table for all customer/vendor items                       "982700
DATA: BEGIN OF gt_dk_items OCCURS 2,                        "982700
        buzei LIKE bseg-buzei,                              "982700
        koart LIKE bseg-koart,                              "982700
        lifnr LIKE bseg-lifnr,                              "982700
        kunnr LIKE bseg-kunnr,                              "982700
        stceg LIKE bseg-stceg,                              "982700
      END OF gt_dk_items.                                   "982700
DATA: BEGIN OF gs_s_mwskz,                                  "1527382
        tax_country LIKE bseg-tax_country,
        mwskz       LIKE bseg-mwskz,                        "1527382
      END OF gs_s_mwskz.                                    "1527382
DATA: gt_s_mwskz LIKE STANDARD TABLE OF gs_s_mwskz.         "1527382

DATA gt_teurb TYPE STANDARD TABLE OF teurb WITH DEFAULT KEY. "3299454
* DMEE-Daten

DATA: t_epost TYPE TABLE OF asl_item.
DATA: epost TYPE asl_item_s.

* global parameter to receive info from selection screen    "1434854
* parameter par_down which exists only in some reports.     "1434854
DATA: gd_par_down TYPE xfeld,                               "1434854
      hlp_umsks   TYPE umsks,   "to signify all DP items    "1434854
      hlp_rebzt   TYPE rebzt.   "to signify dp clearing     "1434854
DATA: gd_par_conv TYPE aslmconv,      "activate conversion  "1736708
      gd_par_exty TYPE kurst,         "exchange rate type   "1736708
      gd_par_exdt TYPE wwert_d.       "translation date     "1736708

* Archiving of SAPscript form                                   "766359
DATA: gs_valid     TYPE c,                                  "766359
      gs_arparams  LIKE arc_params,                         "766359
      gs_prparams  LIKE pri_params,                         "766359
      gs_idxparams LIKE toa_dara,                           "766359
      hlp_prtxt    TYPE pri_params-prtxt,                   "766359
      hlp_copies   TYPE pri_params-prcop.                   "766359

DATA: report_id TYPE syrepid.                               "983616
*--->>> EOL-0083 24.04.2024
DATA: gv_report_id TYPE syrepid VALUE '/THKR/RFASLM00'.
*---<<<

DATA: gd_vatdate_active TYPE xvatdate,                      "1023317
      gd_blocked_addr   TYPE cvp_xblck.                     "2169661
DATA: gv_in_cloud TYPE abap_bool,
      gv_filename TYPE string,
      gv_codepage TYPE abap_encod.
"SFIN Application log
* Data Declaration
DATA: gs_rjet_item_odata  TYPE fac_s_rjet_item_odata,
      gt_message          TYPE bapirettab,
      gt_message_all      TYPE bapirettab,
      gv_simulation       TYPE abap_bool,
      gt_log_handle       TYPE bal_t_logh,
      gs_ballog           TYPE bal_s_log,
      gs_appl_log_message TYPE bal_s_msg,
      gs_message          TYPE bapiret2,
      gv_log_handle       TYPE balloghndl,
      gv_timestampc(14)   TYPE c,
      gv_message          TYPE string.
*---------------------------------------------------------------------*
*       Field-Groups für den Extrakt                                  *
*---------------------------------------------------------------------*
FIELD-GROUPS:
  header,
  daten.

INSERT
  bkpf-bukrs
  bseg-stceg
  hlp_ind
  hlp_xegcos                                                "2854595
  hlp_stceg_orig                                            "2854595
  bseg-xegdr
  bkpf-gjahr
  bkpf-belnr
  bseg-buzei
  hlp_umkrs
INTO header.

INSERT
  bkpf-budat
  bkpf-monat
  hlp_dmshb
  hlp_koart
  hlp_ktnra
  hlp_name1                                                 "530539
  hlp_stras                                                 "530539
  hlp_ort01                                                 "530539
  hlp_pstlz                                                 "530539
  hlp_umsks                                                 "1434854
  hlp_rebzt                                                 "1434854
  hlp_name1_orig                                            "2854595
INTO daten.



*---------------------------------------------------------------------*
*       Selektionsparameter                                           *
*---------------------------------------------------------------------*
begin_of_block 1.
*--->>> EOL-0083 24.04.2024
SELECT-OPTIONS: s_gsber FOR bseg-gsber OBLIGATORY,
                s_prctr FOR bseg-prctr.
*---<<<

PARAMETERS:
  par_xalw TYPE fot_lw_to_alw                               "3299454
                       MODIF ID alw.                        "3299454
SELECTION-SCREEN:
BEGIN OF LINE,
COMMENT 01(30) TEXT-010 FOR FIELD par_quar,
POSITION POS_LOW.
PARAMETERS:
  par_quar LIKE rfpdo-aslmquar.        "Berichtsquartal
SELECTION-SCREEN:
* COMMENT 35(1) text-011 FOR FIELD par_jahr.                "870277
COMMENT 36(1) TEXT-011 FOR FIELD par_jahr.                  "870277
PARAMETERS:
  par_jahr TYPE bkpf-gjahr.        "Berichtsjahr
SELECTION-SCREEN
END OF LINE.

SELECTION-SCREEN:                                           "870277
BEGIN OF LINE,                                              "870277
COMMENT 01(30) TEXT-012 FOR FIELD par_mona                  "870277
  MODIF ID mon,                                             "870277
POSITION POS_LOW.                                           "870277
PARAMETERS:                                                 "870277
  par_mona TYPE aslmmona MODIF ID mon.     "Berichtsmonat   "870277
SELECTION-SCREEN:                                           "870277
COMMENT 36(1) TEXT-011 FOR FIELD par_jamo                   "870277
  MODIF ID mon.                                             "870277
PARAMETERS:                                                 "870277
  par_jamo TYPE bkpf-gjahr MODIF ID mon.   "Berichtsjahr    "870277
SELECTION-SCREEN                                            "870277
END OF LINE.                                                "870277

PARAMETERS:                                                 "1023317
  p_bybudt TYPE aslmbudat RADIOBUTTON GROUP dsel            "1023317
           DEFAULT 'X',                                     "1023317
  p_byvtdt TYPE aslmvatdt RADIOBUTTON GROUP dsel.           "1023317
SELECT-OPTIONS:                                             "1023317
  sel_vtdt FOR bkpf-vatdate.       "VAT Due date            "1023317

SELECT-OPTIONS:
  sel_lstm FOR bset-lstml              "Steuermeldeland
    NO-EXTENSION NO INTERVALS MODIF ID wia,
  sel_taxc FOR bseg-tax_country NO-EXTENSION NO INTERVALS MODIF ID txa,
  sel_mwkz FOR bseg-mwskz,             "Mehrwertsteuerkennzeichen
  so_stceg FOR bseg-stceg,                                  "2778393
  sel_ukrs FOR t007f-umkrs.            "Umsatzsteuerkreis
PARAMETERS:                                                 "1402105
  par_del TYPE aslmdelivery            "Sel. EG-Delivery    "1402105
          DEFAULT 'X'                                       "1402105
          MODIF ID del.                                     "1402105
PARAMETERS:                                                 "1384895
  par_srv TYPE aslmservice             "Sel. EG-Service     "1384895
*         DEFAULT space.                           "1384895 "2252566
          DEFAULT 'X'.                                      "2252566
end_of_block 1.

SELECTION-SCREEN:                                           "1413492
BEGIN OF BLOCK fica                                         "1413492
WITH FRAME TITLE TEXT-070.            "FI-CA Interface    "1413492
PARAMETERS:                                                 "1413492
  par_fica TYPE aslmfica,                                   "1413492
  par_dest TYPE rfcdest,                                    "1413492
  p_ficaep TYPE aslmfica_ep.                                "1465562
SELECTION-SCREEN                                            "1413492
END OF BLOCK fica.                                          "1413492

begin_of_block 2.
PARAMETERS:
  par_bset LIKE rfpdo2-aslmbset,   "X - BSET statt BSEG
  par_epos LIKE rfpdo-allgepos,    "X - Ausweis Einzelpostenebene
  par_lsep LIKE rfpdo-allglsep,    "X - Listseparations gewünscht
  par_mikf LIKE rfpdo-allgmikf NO-DISPLAY, "X - Mikrofichezeile ausgeben (not used anymore)
  par_kna1 TYPE aslm_read_kna          "Fallback Read STCEG "1750935
           DEFAULT 'X'.                                     "1750935
PARAMETERS:
  par_i_xi TYPE fot_xi_in_lines,
  par_h_xi TYPE fot_xi_in_header.

* par_pril     LIKE tsp01-rqdest.  "Druckername für die Liste

*Hidden parameter for CHECK MODE function which will be checked
*in UI Application JOB apps.
PARAMETERS p_applog
  TYPE flag
  NO-DISPLAY.

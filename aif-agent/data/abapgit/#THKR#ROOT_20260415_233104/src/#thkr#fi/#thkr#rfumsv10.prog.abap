************************************************************************
*                                                                      *
*      Zusatzliste zur Umsatzsteuer-Voranmeldung (RFUMSV10)            *
*                                                                      *
************************************************************************
* Dieser Report basiert auf der alten Zusatzliste, welche nun den      *
* Namen RFUMSV10_P trägt.                                              *
************************************************************************
*  OP-02: note 359386 Überschrift pro Buchungskreis                    *
*----------------------------------------------------------------------*
*  OP-03: note 386534 Belege aus dem TR und RE                         *
*----------------------------------------------------------------------*
*  OP-04: note 403312 Falsche Anmerkung                                *
*----------------------------------------------------------------------*
*  OP-05: note 411040 Einkaufskontenabwicklung                         *
*----------------------------------------------------------------------*
*  KS-01: note 713336 Unterdrückung Summenliste bei sel_hkon           *
************************************************************************

REPORT /thkr/rfumsv10
  LINE-COUNT (1)
  LINE-SIZE 132
  NO STANDARD PAGE HEADING
  MESSAGE-ID f7.


TYPE-POOLS: slis.


*----------------------------------------------------------------------*
* Tabellen                                                             *
*----------------------------------------------------------------------*
TABLES:
  bhdgd,                                   "#EC NEEDED   "Batch-Heading
  bkpf,                                "Belegkopf
  bseg,                                "Belegsegment Buchhaltung
  bset,                                "Belegsteuerdaten
  fimsg,                               "Fehlermeldungen
  skb1,                                "Sachkonto
  sscrfields,                          "Selection-Screen Felder
  t001,                                "Buchungskreise
  taltwar,                             "<<<< euro
  t005,                                "Land des Buchungskreises
  t007a,                               "Steuerart des Umsatzsteuerkennz.
  t007b,                               "Vorgangsschlüssel Umsatzsteuer
  t007f,                               "Umsatzsteuerkreise              "N1542782
  ttxd,                                "Jurisdictioncodes Kalk.Schema   "N1542782
  t007s,                               "Bezeichnung Steuerkennzeichen
  t001k,                               "valuation grouping key
  t030,                                "account determination
  mbew,                                "material master
  ekkn.                                "accountdeteremination

*----------------------------------------------------------------------*
DEFINE selection_screen_line.
  SELECTION-SCREEN: BEGIN OF LINE.
  PARAMETERS &3 LIKE &4 DEFAULT 'X'.
* selection-screen: comment (30) &1 for field &3.           "2065903
  SELECTION-SCREEN: COMMENT (28) &1 FOR FIELD &3.           "2065903
  SELECTION-SCREEN: COMMENT pos_low(10) TEXT-311
                    FOR FIELD &2.  "neu

  PARAMETERS &2 LIKE rfums_alv-variante.
  SELECTION-SCREEN:
      POSITION POS_HIGH.

  SELECTION-SCREEN: PUSHBUTTON (15) TEXT-310
                    USER-COMMAND &5.
  SELECTION-SCREEN END OF LINE.
END-OF-DEFINITION.



*----------------------------------------------------------------------*
* Selektionsparameter                                                  *
*----------------------------------------------------------------------*
*--->>> EOL-0083 24.04.2024
SELECTION-SCREEN BEGIN OF BLOCK repro WITH FRAME TITLE TEXT-004. "REPRO_ZF.
  SELECT-OPTIONS:
  s_gsber     FOR bseg-gsber,
  s_prctr     FOR bseg-prctr,
  s_segmt     FOR bseg-segment.
SELECTION-SCREEN END OF BLOCK repro.
*---<<<
begin_of_block 1.
SELECT-OPTIONS:
  sel_ukrs FOR t007f-umkrs,            "Umsatzsteuerkreise  "N1542782
  sel_mona FOR bkpf-monat,             "Geschäftsmonate
  sel_taxc FOR bset-tax_country NO-EXTENSION NO INTERVALS MODIF ID txa,       "Tax country
  sel_mwkz FOR bset-mwskz,             "Umsatzsteuerkennzeichen
  sel_bldt FOR bkpf-bldat,             "Belegdatum
  sel_vtdt FOR bkpf-vatdate,           "Steuermeldedatum    "1023317
  sel_hkon FOR bseg-hkont MATCHCODE OBJECT sako. "Sachkonto
PARAMETERS:
  par_xsau LIKE rfpdo1-umsvxaru,       "Ausgangssteuer selekt.
  par_xsvo LIKE rfpdo1-umsvxaru.       "Vorsteuer selektieren
PARAMETERS:                                                 "2101269
  par_moss LIKE rfpdo1-sel_moss.       "sel. MOSS-taxcodes       "2101269
end_of_block 1.

begin_of_block 2.
PARAMETERS:
  par_altk LIKE rfpdo1-allgaltk,       "Alternative Kontonummer
  par_eink LIKE t001-xeink,            "Ersetzen Einkaufskonto
  par_rbuv TYPE umsvrbuv,              "Ersetzen Bukrs-Verr."1132306
  par_dist TYPE distr_tax DEFAULT 'X', "Steuer verteilen?   "3028017
  par_line LIKE rfpdo1-allgline.       "Zusatzüberschrift
SELECTION-SCREEN: SKIP.
*                  BEGIN OF LINE,
*                  COMMENT 1(20) text-312,              "Output Lists
*                  COMMENT pos_low(20) text-311         "Display variant
*                    FOR FIELD par_var1,                     "#EC NEEDED
*                  END OF LINE.
selection_screen_line:
       TEXT-301 par_var1 par_lis1 rfpdo-umsvxaus      con1, "#EC NEEDED
       TEXT-302 par_var2 par_lis2 rfpdo-umsvxvor      con2, "#EC NEEDED
       TEXT-303 par_var3 par_lis3 rfums_alv-umsvxasu  con3, "#EC NEEDED
       TEXT-304 par_var4 par_lis4 rfums_alv-umsvxvsu  con4, "#EC NEEDED
* ----- begin "984821
       TEXT-305 par_var5 par_lis5 rfums_alv-umsvxsu   con5. "#EC NEEDED
* ----- end "984821
end_of_block 2.

PARAMETERS: p_check TYPE xfeld NO-DISPLAY. "Check mode indicator for SAPJ


*----------------------------------------------------------------------*
* Konstanten                                                           *
*----------------------------------------------------------------------*
* Name of the handle for the display variant (ALV)
CONSTANTS:
*--->>> EOL-0083 24.04.2024
  c_rldnr_0l      TYPE fagl_rldnr VALUE '0L',
*---<<<
  c_handle_1      TYPE slis_handl VALUE 'HAN1',
  c_handle_2      TYPE slis_handl VALUE 'HAN2',
  c_handle_3      TYPE slis_handl VALUE 'HAN3',
  c_handle_4      TYPE slis_handl VALUE 'HAN4',
  c_handle_5      TYPE slis_handl VALUE 'HAN5',             "984821
  c_struc_name_12 TYPE dd02l-tabname VALUE 'RFUMS_ALV_VAT',
  c_struc_name_3  TYPE dd02l-tabname VALUE 'RFUMS_ALV_OUTPUT_VAT',
  c_struc_name_4  TYPE dd02l-tabname VALUE 'RFUMS_ALV_INPUT_VAT',
  c_struc_name_5  TYPE dd02l-tabname VALUE 'RFUMS_ALV_TOTAL_VAT'. "984821

CONSTANTS c_1_year_in_days TYPE int2 VALUE 365.


*----------------------------------------------------------------------*
* Interne Tabellen (TAB)                                               *
*----------------------------------------------------------------------*

* Tabelle über die Ausgabetabellen pro Buchungskreis
DATA: BEGIN OF gt_master_table OCCURS 0,
        bukrs         TYPE bkpf-bukrs,
        t_output_item TYPE rfums_alv_vat OCCURS 0,
        t_input_item  TYPE rfums_alv_vat OCCURS 0,
        t_output_sum  TYPE rfums_alv_output_vat OCCURS 0,
        t_input_sum   TYPE rfums_alv_input_vat  OCCURS 0,
        t_totals      TYPE rfums_alv_total_vat  OCCURS 0,   "984821
      END OF gt_master_table.

* Tabelle für Aufruf der Funktion 'TAX_REP_PRINT_N_ALV_LISTS'
DATA: gt_pointer_master_table TYPE TABLE OF tax_alv_table.

* Feldkataloge                                              "984821
DATA: gt_fieldcat_12 TYPE slis_t_fieldcat_alv,              "984821
      gt_fieldcat_3  TYPE slis_t_fieldcat_alv,              "984821
      gt_fieldcat_4  TYPE slis_t_fieldcat_alv,              "984821
      gt_fieldcat_5  TYPE slis_t_fieldcat_alv.              "984821
FIELD-SYMBOLS: <gt_fieldcat> TYPE slis_t_fieldcat_alv.      "984821

* Auszug aus der Buchungskreistabelle
DATA: BEGIN OF tab_001 OCCURS 5,
        bukrs  LIKE t001-bukrs,     "Buchungskreis
        land1  LIKE t001-land1,     "Land
        waers  LIKE t001-waers,     "Hauswährung
        kalsm  LIKE t005-kalsm,     "Kalkulationsschema
        xtxjcd TYPE xfeld,          "Steuerstandortcodes "1129096
      END OF tab_001,

* Umsatzsteuertabelle
      BEGIN OF tab_007a OCCURS 15.
        INCLUDE STRUCTURE t007a.
DATA: text1 LIKE t007s-text1,
      END OF tab_007a,

* Vorgangsschlüsseltabelle
      BEGIN OF tab_007b OCCURS 5.
        INCLUDE STRUCTURE t007b.
DATA: END OF tab_007b,

* Fehlerprotokoll im Batch
BEGIN OF tfimsg OCCURS 10.
  INCLUDE STRUCTURE fimsg.
DATA: END OF tfimsg,

* Summen je Steuerkennzeichen
BEGIN OF ep_sum OCCURS 30,
  bukrs       TYPE bukrs,                                   "984821
  tax_country TYPE fot_tax_country,  "RITA
  mwskz       LIKE bseg-mwskz,           "Umsatzsteuerkennzeichen
  txdat_from  LIKE bseg-txdat_from,   "TDT
  ktosl       LIKE bset-ktosl,           "Vorgangsschlüssel   "2526464
  umsks       LIKE bseg-umsks,           "A - Anzahlung
  dmbtr       TYPE aflex16d2o22s,    "AFLE enablement original (8)type p,
END OF ep_sum,

* Liste mwwskz, ktosl innerhalb eines belegs                "2526464
BEGIN OF bset_ktosl OCCURS 30,                              "2526464
  tax_country TYPE fot_tax_country,  "RITA
  mwskz       LIKE bseg-mwskz,           "Umsatzsteuerkennz.  "2526464
  txdat_from  LIKE bseg-txdat_from, "TDT
  ktosl       LIKE bset-ktosl,           "Vorgangsschlüssel   "2526464
END OF bset_ktosl,                                          "2526464

* Summen der Steuerzeilen
BEGIN OF tab_bset_sum OCCURS 50,
  bukrs       LIKE bkpf-bukrs,           "Buchungskreis
  mwart       LIKE t007a-mwart,          "Umsatzsteuerart
  tax_country TYPE fot_tax_country,  "RITA
  mwskz       LIKE bseg-mwskz,           "Umsatzsteuerkennzeichen
  txdat_from  LIKE bseg-txdat_from,  "TDT
*  umsks     LIKE bseg-umsks,           "A - Anzahlung    "552412
  ktosl       LIKE bset-ktosl,           "Vorgangsschlüssel
  hwbas       LIKE bset-hwbas,                              "552412
  hwste       TYPE aflex16d2o22s,    "AFLE enablement original (8)type p,
  stgrp       LIKE t007b-stgrp,          "Art der Steuer
  stbkz       LIKE t007b-stbkz,          "Buchungskennzeichen
*  shkzg     like bset-shkzg,                     "533153    "820861
END OF tab_bset_sum,

gt_bset_pack TYPE SORTED TABLE OF bset                      "3075765
               WITH UNIQUE KEY bukrs belnr gjahr buzei, "2747095 zum Paketweise einlesen "3075765

* Alternative / Ausgabe-Kontonummer
  BEGIN OF tab_konto OCCURS 30,
    bukrs LIKE bkpf-bukrs,
    hkont LIKE bseg-hkont,
    sakan LIKE ska1-sakan,
  END OF tab_konto,

  BEGIN OF mm_table OCCURS 50,           "for active parameter par_eink
    matnr LIKE bseg-matnr,                "material number
    wrxs  LIKE t030-konts,                "G/R I/R -g/l-account D
    wrxh  LIKE t030-konth,                "G/R I/R -g/l-account C
    eins  LIKE t030-konts,                "purchasing g/l-account D
    einh  LIKE t030-konth,                "purchasing g/l-account c
    fr1s  LIKE t030-konts,                "freight g/l-account D
    fr1h  LIKE t030-konth,                "freight g/l-account c
    fr2s  LIKE t030-konts,                "freight 2 g/l-account D
    fr2h  LIKE t030-konth,                "freight 2 g/l-account c
    fr3s  LIKE t030-konts,                "freight 3 g/l-account d
    fr3h  LIKE t030-konth,                "freight 4 g/l-account c
    fr4s  LIKE t030-konts,                "freight 4 g/l-account d
    fr4h  LIKE t030-konth,                "freight 4 g/l-account c
    rues  LIKE t030-konts,                "provisions g/l-account d
    rueh  LIKE t030-konth,                "provisions g/l-account c
    fres  LIKE t030-konts,                "offset for FR1-RUE D
    freh  LIKE t030-konth,                "offset for FR1-RUE D
  END OF mm_table,



*----------------------------------------------------------------------*
* Felder                                                               *
*----------------------------------------------------------------------*

* ----- begin delete "984821
** Einzelposten
*BEGIN OF ep,
*  bukrs     LIKE bkpf-bukrs,           "Buchungskreis
*  mwart     LIKE t007a-mwart,          "Umsatzsteuerart
*  mwskz     LIKE bseg-mwskz,           "Umsatzsteuerkennzeichen
*  umsks     LIKE bseg-umsks,           "A - Anzahlung
*  hkont     LIKE bseg-hkont,           "Sachkonto
*  buper(6)  TYPE n,                    "Buchungsperiode
*  budat     LIKE bkpf-budat,           "Buchungsdatum
*  belnr     LIKE bkpf-belnr,           "Belegnummer
*  buzei     LIKE bseg-buzei,           "Buchungszeile
*  xblnr     LIKE bkpf-xblnr,           "Referenz-Belegnummer
*  dmbtr(7)  TYPE p,                    "Basisbetrag in Hauswährung
*END OF ep,
* ----- end delete "984821

* Hilfsfelder
  hlp_error      LIKE skb1-xkres,      "X - Fehler bei alt. Kontonummer
  hlp_tabix      LIKE sy-tabix,        "Index für den Insert
  hlp_datum_low  LIKE bkpf-budat,      "Datumsuntergrenze der Selektion
  hlp_datum_high LIKE bkpf-budat,      "Datumsobergrenze
  hlp_bwmod      LIKE t001k-bwmod,     "mod key
  hlp_bklas      LIKE mbew-bklas,      "value class
  hlp_repid      LIKE sy-repid,        "Report name
  hlp_brutto     LIKE bset-hwbas,                           "OP-04
  hlp_umsks      LIKE bseg-umsks,                           "OP-04
  l_wrxmod       TYPE wrxmod,                               "OP-05
  i_egrkz        LIKE t007a-egrkz,                          "509652
  i_kalsm        LIKE t005-kalsm,                           "509652

* Druckzeilen, Überschriften
  txt_buper(7)   TYPE c,               "aufbereitete Periode
  txt_datum(8)   TYPE c.               "aufbereitetes Datum

* data related to HANA/de-cluster optimizations             "2711917
DATA: gd_cnt_no_auth TYPE i,                                "2711917
      gr_auth_blart  TYPE RANGE OF bkpf-blart,              "2711917
      gr_auth_gsber  TYPE RANGE OF bseg-gsber.              "2711917

DATA gd_via_ldb TYPE abap_bool.                             "2158177
**DATA gd_selection_stopped TYPE xfeld.            "1066663 "2158177
DATA gd_distribute_tax TYPE xfeld.                          "1129096

DATA:gt_message_all TYPE bapirettab,  "SFIN Application log
     gv_message     TYPE string.

*----------------------------------------------------------------------*
* Field-Groups                                                         *
*----------------------------------------------------------------------*
FIELD-SYMBOLS: <s_master_table> LIKE gt_master_table.

* Hilfsfeld fuer Einkaufskontenabwicklung                 "843610
DATA purch_acc_found TYPE xfeld.                            "843610

* global data for BAdI FI_TAX_UMSV10_01                     "2260949
DATA: g_badi_01    TYPE REF TO fi_tax_umsv10_01,            "2260949
      gt_bkpf_cufi TYPE rsfs_struc_tt,                      "2260949
      gt_bseg_cufi TYPE rsfs_struc_tt,                      "2260949
      gt_bset_cufi TYPE rsfs_struc_tt.                      "2260949

* Table for single items per document                       "984821
DATA: BEGIN OF gt_bas OCCURS 5.                             "984821
        INCLUDE STRUCTURE rfums_alv_vat.                        "984821
*DATA:  mwart     TYPE mwart,                      "984821  "2260949
*      txgrp     TYPE txgrp,                       "984821  "2260949
DATA:   txgrp     TYPE txgrp,                               "2260949
        gsber_au  TYPE bseg-gsber,                          "2711917
        flg_done  TYPE xfeld,                               "984821
        flg_split TYPE xfeld,                               "1845112
      END OF gt_bas.                                        "984821

* Table for tax items per document                          "984821
DATA: BEGIN OF gt_tax OCCURS 5,                             "984821
        bukrs       TYPE bukrs,                             "984821
        belnr       TYPE belnr_d,                           "984821
        gjahr       TYPE gjahr,                             "984821
        buzei       TYPE buzei,                             "984821
        tax_country TYPE fot_tax_country,    "RITA
        mwskz       TYPE mwskz,                             "984821
        txdat_from  TYPE fot_txdat_from, "TDT
        txgrp       TYPE txgrp,                             "984821
        mwart       TYPE mwart,                             "984821
        stazf       TYPE stazf_007b,                        "984821
        stgrp       TYPE stgrp_007b,                        "984821
        stbkz       TYPE stbkz_007b,                        "984821
        hwste       TYPE hwste,                             "984821
      END OF gt_tax.                                        "984821

* work table for tax amount distribution                    "984821
DATA: BEGIN OF distrib_tab OCCURS 5,                        "984821
        oldpos LIKE sy-tabix,   "Position in the orig. table"984821
        hwbas  TYPE hwaerbas,   "Key for the distribution   "984821
        shkzg  TYPE shkzg,      "Debit/Credit Indicator     "984821
        distr  TYPE hwste,      "Distributed amount         "984821
      END OF distrib_tab.                                   "984821

* Tables to store original document data                    "984821
DATA: gt_bseg TYPE TABLE OF bseg,                           "984821
      gt_bset TYPE TABLE OF bset,                           "984821
      gs_bseg TYPE bseg.                                    "984821

DATA: cnt_lines TYPE i.                                     "984821

DATA: gd_vatdate_active TYPE xvatdate.                      "1023317
* Flag für Zeitabh. Umsatzsteuerkreise                      "N1542782
* X- Aktiv   ' ' - nicht aktiv                              "N1542782
DATA: gd_umkrs_active   TYPE  bkpf-xmwst.                   "N1542782
RANGES: gt_range_bukrs  FOR bkpf-bukrs.                     "N1542782
* Umsatzsteuerkreis Zeitabh. bestimmt                       "N1542782
DATA: gd_umkrs          TYPE  t007f-umkrs.                  "N1542782
DATA: flg_umkrs(1)      TYPE n. "Abgrenzung von USt-Kreisen?"N1542782
DATA: lt_all_bukrs      TYPE fagl_t_bukrs,                  "N1762388
      ls_selected_bukrs TYPE fagl_s_bukrs.                  "N1762388
                                                            "N1762388

DATA flg_txa_active TYPE abap_bool.

DATA: gs_log_handle TYPE balloghndl,      "Log Handle
      gs_log        TYPE bal_s_log.

*--->>> EOL-0083 24.04.2024
CONSTANTS: c_rldnr_01  TYPE fagl_rldnr VALUE '0L'.

TYPES: BEGIN OF gtype_acdoca_key,
         rldnr  TYPE fins_ledger,
         rbukrs TYPE bukrs,
         gjahr  TYPE gjahr,
         belnr  TYPE belnr_d,
         docln  TYPE docln6,
       END OF gtype_acdoca_key.

DATA: gt_acdoa_key TYPE STANDARD TABLE OF gtype_acdoca_key,
      gs_acdoa_key TYPE gtype_acdoca_key.

DATA: gv_buzei       TYPE  acdoca-buzei,
      gv_rbusa       TYPE  acdoca-rbusa,
      gv_prctr       TYPE  acdoca-prctr,
      gv_segment     TYPE  acdoca-segment,
      gv_wsl         TYPE  acdoca-wsl,
      gv_mwskz       TYPE  acdoca-mwskz,
      gv_ktosl       TYPE  acdoca-ktosl,
      gv_delete_bseg TYPE  flag,
      gv_docln       TYPE  docln6.
*---<<<

* ----- begin delete "984821
**----------------------------------------------------------------------*
** Field-Groups                                                         *
**----------------------------------------------------------------------*
*FIELD-GROUPS:
*  header,
*  daten.
*
*INSERT
*  ep-bukrs                             "Buchungskreis
*  ep-mwart                             "Umsatzsteuerart
*  ep-mwskz                             "Umsatzsteuerkennzeichen
*  ep-hkont                             "Sachkonto
*  ep-buper                             "Buchungsperiode
*  ep-budat                             "Buchungsdatum
*  ep-belnr                             "Belegnummer
*  ep-buzei                             "Buchungszeile
*INTO header.
*
*INSERT
*  ep-xblnr                             "Referenz-Belegnummer
*  ep-umsks                             "A - Anzahlung
*  ep-dmbtr                             "Basisbetrag in Hauswährung
*INTO daten.
* ----- end delete "984821

TYPES:
  BEGIN OF ty_external_audit_date,
    date        TYPE datum,
    sacf_result TYPE sy-subrc,
  END OF ty_external_audit_date.

DATA: gv_external_audit_check TYPE abap_bool,
      gt_granted_intv         TYPE RANGE OF dats.

CONSTANTS: gc_external_audit_scenario TYPE scen_name VALUE 'EXTERNAL_AUDIT',
           gc_saisacc_doc             TYPE tabname VALUE '/SAIS/ACC_DOC'.

*----------------------------------------------------------------------*
* Vorbelegung im Selektionsdynpro                                      *
*----------------------------------------------------------------------*
INITIALIZATION.

  TRY .
      cl_fot_tdt_btt_code=>handler->set( iv_btt_code =
      cl_fot_tdt_btt_code=>handler->mc_btt_code-rfumsv10 ).
    CATCH cx_fot_tdt_root INTO DATA(lx_tdt).
      MESSAGE lx_tdt.
  ENDTRY.

  PERFORM check_external_audit.

* make RLDNR invisible
  PERFORM make_rldnr_invisible.                             "871301

* prepare BAdI 01                                           "2260949
  GET BADI g_badi_01. "2260949

* register fields for selection (for future use)            "2260949
  IF NOT g_badi_01 IS INITIAL.                              "2260949
    CALL BADI g_badi_01->register_fields                    "2260949
      CHANGING                                              "2260949
        ct_bkpf_fields = gt_bkpf_cufi                    "2260949
        ct_bseg_fields = gt_bseg_cufi                    "2260949
        ct_bset_fields = gt_bset_cufi.                   "2260949
  ENDIF.                                                    "2260949

  get_frame_title: 1,2.
  par_xsau = 'X'.
  par_xsvo = 'X'.
  br_gjahr-low    = sy-datum(4).
  br_gjahr-option = 'EQ'.
  br_gjahr-sign   = 'I'.
  APPEND br_gjahr.
  CLEAR par_lis5.                                           "984821
                                                            "N1762388
* No Authority-Check for BR_BUKRS in logical Database BRF   "N1762388
  auth_buk = 'X'.                                           "N1762388
                                                            "N1762388
* No Authority-Check for ledger in the logical Database BRF "N1762388
  auth_ldr = 'X'.                                           "N1762388

** Create application Log.
** Values populated in the structure to be used for saving the log
** In the data base.
  gs_log-aldate    = sy-datum.     "Define Date for the Log
  gs_log-altime    = sy-uzeit.
  gs_log-aluser    = sy-uname.
  gs_log-alprog    = 'RFUMSV10'.
  gs_log-object    = 'FIGL'.
  gs_log-subobject = 'FIGL_GL_AUTO_CLR_ADD'.
  gs_log-aldate_del = sy-datum + c_1_year_in_days. "delete logs after 1 year
** Application Log Create.
  PERFORM log_create CHANGING gs_log
                              gs_log_handle.

AT SELECTION-SCREEN OUTPUT.                                 "871301
* make RLDNR invisible
  PERFORM make_rldnr_invisible.                             "871301


* Reading in old report variants can overwrite the already  "2618110
* initialized auth_buk and auth_ldr, because the parameters "2618110
* existed in the LDB before they were implemented here.     "2618110
* VAT group selection was introduced with note 1542782.     "2618110
* No Authority-Check for BR_BUKRS in logical Database BRF   "2618110
  auth_buk = 'X'.                                           "2618110
* No Authority-Check for ledger in the logical Database BRF "2618110
  auth_ldr = 'X'.                                           "2618110
  PERFORM modify_screen_for_tax_abroad.

*----------------------------------------------------------------------*
* F4-Hilfen                                                            *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_var1.
  PERFORM alv_variante_f4 USING c_handle_1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_var2.
  PERFORM alv_variante_f4 USING c_handle_2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_var3.
  PERFORM alv_variante_f4 USING c_handle_3.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_var4.
  PERFORM alv_variante_f4 USING c_handle_4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_var5.          "984821
  PERFORM alv_variante_f4 USING c_handle_5.                 "984821

*----------------------------------------------------------------------*
* Prüfen der Eingabedaten                                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
*                                                            "N1542782
* Wurden Umsatzsteuerkreise abgegrenzt?                      "N1542782
  DESCRIBE TABLE sel_ukrs LINES cnt_lines.                  "N1542782
  IF cnt_lines > 0.                                         "N1542782
    flg_umkrs = 1.  "Es wurden Umsatzsteuerkreise abgegrenzt."N1542782
    CALL FUNCTION 'TAX_UMKRS_TIMEDEP_ACTIVE'                 "N1542782
      IMPORTING                                              "N1542782
        e_umkrs_active = gd_umkrs_active               "N1542782
      TABLES                                                 "N1542782
        t_r_bukrs      = br_bukrs                      "N1542782
        t_r_umkrs      = sel_ukrs                      "N1542782
        t_r_budat      = br_budat                      "N1542782
        t_r_bldat      = sel_bldt                      "N1542782
        t_r_vatdate    = sel_vtdt                      "N1542782
        t_r_gjahr      = br_gjahr                      "2431897
        t_r_monat      = sel_mona                      "2431897
      .                                               "N1542782
    IF gd_umkrs_active = 'X'.                               "N1542782
      flg_umkrs = 2.                                        "N1542782
    ENDIF.                                                  "N1542782
  ELSE.                                                     "N1542782
    flg_umkrs = 0.      "Es wurden Buchungskreise abgegrenzt."N1542782
  ENDIF.                                                    "N1542782
*                                                            "N1542782
* Auf die User-Commands reagieren
  CASE sscrfields-ucomm.
    WHEN 'CON1'.                       "Ausgabeliste konfigurieren
      PERFORM config_list USING sscrfields-ucomm.
    WHEN 'CON2'.                       "Ausgabeliste konfigurieren
      PERFORM config_list USING sscrfields-ucomm.
    WHEN 'CON3'.                       "Ausgabeliste konfigurieren
      PERFORM config_list USING sscrfields-ucomm.
    WHEN 'CON4'.                       "Ausgabeliste konfigurieren
      PERFORM config_list USING sscrfields-ucomm.
    WHEN 'CON5'.                       "Ausgabeliste konfig."984821
      PERFORM config_list USING sscrfields-ucomm.           "984821
    WHEN OTHERS.                       "Input-Validierung
      PERFORM check_selection_screen.
  ENDCASE.

  PERFORM check_tax_abroad_active CHANGING flg_txa_active.
*----------------------------------------------------------------------*
* Vorbereitungen                                                       *
*----------------------------------------------------------------------*
START-OF-SELECTION.
*Exit the execution when the Batch Job is checked in
* UI Application Job
  IF p_check IS NOT INITIAL.
    EXIT.
  ENDIF.

  DATA: ls_dd02v_wa  TYPE dd02v,
        ls_dd02v_wa2 TYPE dd02v.

  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name     = 'BSEG'
    IMPORTING
      dd02v_wa = ls_dd02v_wa.


  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name     = 'BSET'
    IMPORTING
      dd02v_wa = ls_dd02v_wa2.

  IF ls_dd02v_wa-tabclass EQ 'TRANSP' AND ls_dd02v_wa2-tabclass EQ 'TRANSP'.
    xhana = 'E'.
  ELSE.
    xhana = ''.
  ENDIF.


  COMMIT WORK.                         "performance

  gd_via_ldb = abap_true.                                   "2158177
** CLEAR gd_selection_stopped.                    "1066663  "2158177

* Datenbankabgrenzungen aus Select-Options füllen
  copy sel_bldt to br_bldat.
  copy sel_vtdt to br_vatdt.                                "1023317

* Tabelle T007B einlesen
  SELECT * FROM t007b INTO TABLE tab_007b.

* Report-Titel aufbauen
  READ TABLE br_vatdt INDEX 1.                              "1023317
  IF sy-subrc EQ 0.                                         "1023317
    hlp_datum_low    = br_vatdt-low.                        "1023317
    hlp_datum_high   = br_vatdt-high.                       "1023317
  ELSE.                                                     "1023317
    READ TABLE br_budat INDEX 1.
    IF sy-subrc EQ 0.
      hlp_datum_low    = br_budat-low.
      hlp_datum_high   = br_budat-high.
    ELSE.
      READ TABLE br_bldat INDEX 1.
      IF sy-subrc EQ 0.
        hlp_datum_low  = br_bldat-low.
        hlp_datum_high = br_bldat-high.
      ENDIF.
    ENDIF.
  ENDIF.                                                    "1023317

  IF hlp_datum_low NE 0 OR hlp_datum_high NE 0.
    sy-title = TEXT-001.
    WRITE hlp_datum_low TO txt_datum DD/MM/YY.
    REPLACE '&DAT1' WITH txt_datum INTO sy-title.
*   IF br_budat-high NE 0.                                  "822611
    IF hlp_datum_high NE 0.                                 "822611
      WRITE hlp_datum_high TO txt_datum DD/MM/YY.
    ELSE.
      WRITE hlp_datum_low TO txt_datum DD/MM/YY.
    ENDIF.
    REPLACE '&DAT2' WITH txt_datum INTO sy-title.
  ELSE.
    sy-title = TEXT-002.
    WRITE:
      sel_mona-low TO txt_buper(2),
      '/'          TO txt_buper+2(1),
      br_gjahr-low TO txt_buper+3.
    REPLACE '&PER1' WITH txt_buper INTO sy-title.
    IF sel_mona-high NE 0.
      WRITE sel_mona-high TO txt_buper(2).
    ELSE.
      WRITE sel_mona-low TO txt_buper(2).
    ENDIF.
    REPLACE '&PER2' WITH txt_buper INTO sy-title.
  ENDIF.

* Batch-Heading vorbereiten
  bhdgd-lines = sy-linsz.
  bhdgd-uname = sy-uname.
  bhdgd-repid = sy-repid.
  bhdgd-domai = 'BUKRS'.


  IF flg_umkrs = 1.                                         "N1542782
*   Es wurden Umsatzsteuerkreise abgegrenzt.                 "N1542782
    REFRESH br_bukrs.                                       "N1542782
    CLEAR br_bukrs.                                         "N1542782
    br_bukrs-sign = 'I'.                                    "N1542782
    br_bukrs-option = 'EQ'.                                 "N1542782
*   Zugehörige Buchungskreise holen.                         "N1542782

    SELECT * FROM t007f                                     "N1542782
      WHERE umkrs IN sel_ukrs.                              "N1542782
      SELECT * FROM t001                                    "N1542782
        WHERE umkrs = t007f-umkrs.                          "N1542782
        br_bukrs-low = t001-bukrs.                          "N1542782
        APPEND br_bukrs.                                    "N1542782
      ENDSELECT.                                            "N1542782
    ENDSELECT.                                              "N1542782
                                                            "N1542782
    CALL FUNCTION 'BUKRS_AUTHORITY_CHECK'                    "N1542782
      EXPORTING
        xdatabase = 'B'                              "N1542782
      TABLES
        xbukreis  = br_bukrs.                        "N1542782
  ELSE.                                                     "N1542782
                                                            "N1542782
    IF flg_umkrs = '0'.                                     "N1542782
    ELSE.                                                   "N1542782
*     flg_umkrs = 2 -->                                      "N1542782
      br_bukrs[]          = gt_range_bukrs[].               "N1542782
    ENDIF.                                                  "N1542782
  ENDIF.                                                    "N1542782
*----------------------------------------------------------------------*
* Belegkopf                                                            *
*----------------------------------------------------------------------*
GET bkpf.

  DATA: lv_failed_bkpf TYPE abap_bool.                      "2294676

  PERFORM process_bkpf CHANGING lv_failed_bkpf.             "2294676

  IF lv_failed_bkpf EQ abap_true.                           "2294676
    REJECT.                                                 "2294676
  ENDIF.                                                    "2294676

* ----- begin deletion note 2294676 ----                    "2294676
*  CHECK:
*   sel_mona,
*   sel_bldt.
*
** Select only normal documents. This is already done by      "971353
** LDB BRF but that check can fail when reading from archive. "971353
*  CHECK bkpf-bstat EQ space.                                "971353
*
** Prüfen Umsatzsteuerkreis Zeitabh. durchführen              "N1542782
*  IF flg_umkrs = '2'.                                       "N1542782
*    CALL FUNCTION 'TAX_UMKRS_DETERMINE'                     "N1542782
*      EXPORTING                                             "N1542782
*        i_bkpf  = bkpf                                "N1542782
*      IMPORTING                                             "N1542782
*        e_umkrs = gd_umkrs.                           "N1542782
**   Weiterverarb. nur, wenn der UMKRS bestimmt werden konnte "N1542782
*    CHECK: gd_umkrs IS NOT INITIAL.                         "N1542782
*  ENDIF.                                                    "N1542782
*
*  PERFORM read_t001 USING bkpf-bukrs.
*
**  CLEAR ep.                                                "984821
**  ep-bukrs    = bkpf-bukrs.                                "984821
**  ep-buper(4) = bkpf-gjahr.                                "984821
**  ep-buper+4  = bkpf-monat.                                "984821
**  ep-budat    = bkpf-budat.                                "984821
**  ep-belnr    = bkpf-belnr.                                "984821
**  ep-xblnr    = bkpf-xblnr.                                "984821
*
*  REFRESH: gt_bseg,                                         "984821
*           gt_bset.                                         "984821
*
*  gd_distribute_tax = 'X'.                                  "1129096
*  IF tab_001-xtxjcd = 'X'.                                  "1129096
** If jurisdiction codes are active distribution of tax      "1129096
** amounts is turned off. Reasons:                           "1129096
** - Showing tax per tax code regardless of jurisdiction     "1129096
**   structure is meaningless.                               "1129096
** - Proper distrution of tax totals would require deepest   "1129096
**   jurisdiction code txjdp in tax items. This is not       "1129096
**   available in bseg. Accessing bset is not possible       "1129096
**   in general due to compression, and because of missing   "1129096
**   information about relation bseg - bset.                 "1129096
** - Tax recalculation in case of different signs also       "1129096
**   requires txjdp in tax items in bset. Calling tax        "1129096
**   calculation without jurisdiction code causes program    "1129096
**   termination.                                            "1129096
*    CLEAR gd_distribute_tax.                                "1129096
*  ENDIF.                                                    "1129096
* ----- end deletion note 2294676 ----                      "2294676

*----------------------------------------------------------------------*
* Belegposition                                                        *
*----------------------------------------------------------------------*
* Es werden steuerrelevante Sachkontenzeilen oder (bei Anzahlungen)    *
* Personenkontenzeilen selektiert, sofern sie nicht Steuerzeilen sind  *
*----------------------------------------------------------------------*
GET bseg.

  PERFORM process_bseg.

* ----- begin delete "984821
*  CLEAR ep-umsks.                                           "552412
*  IF bkpf-awtyp EQ 'FKKSU'.                                 "OP-01
*    PERFORM change_bseg_for_fica.                           "OP-01
*  ENDIF.                                                    "OP-01
*
*  IF NOT bseg-mwart IS INITIAL.   "Tax posting              "913937
*    PERFORM change_bseg_xauto.                              "913937
*  ENDIF.                                                    "913937
*
*  CHECK:
*    bseg-mwskz IN sel_mwkz,
*    bseg-mwskz NE space,
*    ( ( 'DK' NA bseg-koart )
*    OR ( 'DK' CA bseg-koart AND bseg-ktosl EQ 'BUV'
*                            AND bseg-mwskz NE '**' )        "495069
*    OR ( 'DK' CA bseg-koart AND bseg-umsks EQ 'A' ) ),      "431270
**    bseg-mwart EQ space OR ( bseg-xauto EQ space AND       "903638
**                           bseg-buzid EQ space ),  "OP-03  "903638
*    bseg-mwart EQ space                                     "903638
*      OR ( bseg-mwart NE space AND bseg-xauto EQ space ),   "903638
*    bseg-hkont IN sel_hkon.
*
*  IF  ( NOT bseg-stbuk IS INITIAL )
*  AND ( bseg-stbuk <> bseg-bukrs ).
*    SELECT * FROM  bset
*           UP TO 1 ROWS
*           WHERE  bukrs  = bseg-bukrs
*           AND    belnr  = bseg-belnr
*           AND    gjahr  = bseg-gjahr
*           AND    mwskz  = bseg-mwskz.
*    ENDSELECT.
*    CHECK sy-subrc IS INITIAL.
*  ENDIF.
*
*  IF bseg-mwart NE space.              "Steuerkonto direkt bebucht
*    bseg-dmbtr = bseg-hwbas.           "-> Basisbetrag verwenden
*  ENDIF.
*
*  PERFORM read_t007a USING tab_001-kalsm bseg-mwskz.
*
*  ep-mwart    = tab_007a-mwart.
*  IF ( par_xsau IS INITIAL ).
*    CHECK ep-mwart <> 'A'.
*  ENDIF.
*  IF ( par_xsvo IS INITIAL ).
*    CHECK ep-mwart <> 'V'.
*  ENDIF.
*  ep-hkont    = bseg-hkont.
*  ep-mwskz    = bseg-mwskz.
*  CLEAR ep-umsks.
*  IF bseg-umsks EQ 'A' AND 'DK' CA bseg-koart.
*    SELECT SINGLE * FROM skb1
*      WHERE bukrs EQ tab_001-bukrs
*      AND   saknr EQ bseg-hkont.
*    IF skb1-mwskz+1 EQ 'B'.            "Merker für die Anmerkung, daß
*      ep-umsks  = 'A'.                 "Anzahlung brutto geführt wird
*    ENDIF.
*  ENDIF.
*  IF bseg-ktosl = 'VVA' OR bseg-ktosl = 'MVA'.              "449241
*    ep-umsks = 'A'.                                         "449241
*  ENDIF.                                                    "449241
*
*  tab_konto-bukrs = bkpf-bukrs.
*  tab_konto-hkont = bseg-hkont.
**check if new functionality - link MM for purchasing account neccessary
*  IF NOT par_eink IS INITIAL.
*    CLEAR purch_acc_found.                                  "843610
*    IF bseg-matnr NE space.
*      PERFORM link_mm.
*    ENDIF.                                                  "843610
**   ELSE.                                                  "843610
*    IF purch_acc_found IS INITIAL.                          "843610
*      IF bseg-ebeln NE space.
*        PERFORM link2_mm.
*      ENDIF.
*    ENDIF.
*    IF NOT purch_acc_found IS INITIAL.                      "843610
*      ep-hkont        = bseg-hkont.                         "843610
*      tab_konto-hkont = bseg-hkont.                         "843610
*    ENDIF.                                                  "843610
*    IF ( bseg-matnr NE space                                "843610
*         OR bseg-ebeln NE space )                           "843610
*       AND purch_acc_found IS INITIAL.                      "843610
** F7 271:                                                  "843610
** Einkaufskonto Beleg &1 Buchungskreis &2 nicht gefunden   "843610
*      CLEAR fimsg.                                          "843610
*      fimsg-msort = '0010'.                                 "843610
*      fimsg-msgid = 'F7'.                                   "843610
*      fimsg-msgty = 'S'.                                    "843610
*      fimsg-msgno = '271'.                                  "843610
*      fimsg-msgv1 = bkpf-belnr.                             "843610
*      fimsg-msgv2 = bkpf-bukrs.                             "843610
*      fimsg-msgv3 = bseg-hkont.                             "843610
*      CALL FUNCTION 'FI_MESSAGE_COLLECT'                    "843610
*           EXPORTING                                        "843610
*                i_fimsg = fimsg.                            "843610
*    ENDIF.                                                  "843610
*  ENDIF.
*  READ TABLE tab_konto WITH KEY tab_konto(14) BINARY SEARCH.
*  IF sy-subrc NE 0.
*    hlp_tabix = sy-tabix.
*    IF par_altk NE space.
*      CALL FUNCTION 'READ_SACHKONTO_ALTKT'
*        EXPORTING
*          bukrs           = bkpf-bukrs
*          saknr           = bseg-hkont
*          xmass           = 'X'
*          xskan           = 'X'
*        IMPORTING
*          altkt_not_found = hlp_error
*          altkt_sakan     = tab_konto-sakan
*        EXCEPTIONS
*          saknr_not_found = 04.
*      IF sy-subrc NE 0.
*        CLEAR fimsg.
*        fimsg-msort = '0001'.
*        fimsg-msgid = 'FR'.
*        fimsg-msgty = 'S'.
*        fimsg-msgno = '322'.
*        fimsg-msgv1 = bseg-hkont.
*        fimsg-msgv2 = bkpf-bukrs.
*        CALL FUNCTION 'FI_MESSAGE_COLLECT'
*          EXPORTING
*            i_fimsg = fimsg.
*      ENDIF.
*      IF hlp_error NE space.
*        CLEAR fimsg.
*        fimsg-msort = '0002'.
*        fimsg-msgid = 'FR'.
*        fimsg-msgty = 'S'.
*        fimsg-msgno = '319'.
*        fimsg-msgv1 = bseg-hkont.
*        fimsg-msgv2 = bkpf-bukrs.
*        CALL FUNCTION 'FI_MESSAGE_COLLECT'
*          EXPORTING
*            i_fimsg = fimsg.
*      ENDIF.
*    ELSE.
*      CALL FUNCTION 'READ_SACHKONTO_ALTKT'
*        EXPORTING
*          altkt_i     = bseg-hkont
*          bukrs       = bkpf-bukrs
*          saknr       = bseg-hkont
*          xskan       = 'X'
*        IMPORTING
*          altkt_sakan = tab_konto-sakan.
*    ENDIF.
*    INSERT tab_konto INDEX hlp_tabix.
*  ENDIF.
*  ep-hkont    = tab_konto-sakan.
*  ep-buzei    = bseg-buzei.
*  IF bseg-shkzg EQ 'H'.
*    ep-dmbtr  = - bseg-dmbtr.
*  ELSE.
*    ep-dmbtr  = bseg-dmbtr.
*  ENDIF.
*  EXTRACT daten.
* ----- end delete "984821


*----------------------------------------------------------------------*
* Umsatzsteuerposition                                                 *
*----------------------------------------------------------------------*
GET bset.

  PERFORM process_bset.


*----------------------------------------------------------------------*
* Process the whole document                                "984821               *
*----------------------------------------------------------------------*
GET bkpf LATE.                                              "984821

  PERFORM process_bkpf_late.



*----------------------------------------------------------------------*
* Verarbeitung der extrahierten Daten                                  *
*----------------------------------------------------------------------*
END-OF-SELECTION.

  IF xhana = 'E'.
    gd_via_ldb = abap_false.                                "3291400
    PERFORM read_from_db.

  ENDIF.

* IF xhana <> 'E'.                                          "2158177
*   IF sy-batch <> space                           "1066663 "2158177
*      AND gd_selection_stopped <> space.          "1066663 "2158177
*     MESSAGE a273                                 "1066663 "2158177
*         WITH bkpf-bukrs bkpf-belnr bkpf-gjahr.   "1066663 "2158177
*   ENDIF.                                         "1066663 "2158177
* ENDIF.                                                    "2158177
*  loop at tab_bset_sum.                        "533153     "820861
*    if tab_bset_sum-hwbas > 0.                 "533153     "820861
*      tab_bset_sum-shkzg = 'S'.                "533153     "820861
*      modify tab_bset_sum.                     "533153     "820861
*    else.                                      "533153     "820861
*      tab_bset_sum-shkzg = 'H'.                "533153     "820861
*      modify tab_bset_sum.                     "533153     "820861
*    endif.                                     "533153     "820861
*                                               "533153     "820861
*  endloop.                                     "533153     "820861

*  SORT.                                " Extrakt           "984821

  SORT tab_bset_sum.

* ----- begin insert "984821
  LOOP AT gt_master_table
       ASSIGNING <s_master_table>.

    PERFORM read_t001 USING <s_master_table>-bukrs.

    IF tab_001-xtxjcd = space.                              "1761953
      LOOP AT ep_sum                                        "2526464
           WHERE bukrs = <s_master_table>-bukrs             "2526464
             AND ktosl = space.                             "2526464
        PERFORM check_ep_sum                                "2526464
                USING sy-tabix.                             "2526464
      ENDLOOP.                                              "2526464
      IF sy-subrc = 0.                                      "2878204
        PERFORM compress_ep_sum.                            "2878204
      ENDIF.
      LOOP AT ep_sum                                        "1761953
           WHERE bukrs = <s_master_table>-bukrs.            "1761953
        PERFORM check_bset_sum.                             "1761953
      ENDLOOP.                                              "1761953
    ENDIF.                                                  "1761953

    LOOP AT tab_bset_sum
         WHERE bukrs = <s_master_table>-bukrs.
      PERFORM append_bset.
    ENDLOOP.

    SORT <s_master_table>-t_output_item
         BY tax_country
            mwskz
            txdat_from "TDT
            hkont
            gjahr
            monat
            budat
            belnr
            buzei.

    SORT <s_master_table>-t_input_item
         BY tax_country
            mwskz
            txdat_from  "TDT
            hkont
            gjahr
            monat
            budat
            belnr
            buzei.

    SORT <s_master_table>-t_totals
         BY mwart
            hkont
            tax_country
            mwskz
            txdat_from "TDT
            flg_dir
            flg_dp
            flg_dpg
            flg_buv.

  ENDLOOP.
* ----- end insert "984821

* ----- begin delete "984821
*  LOOP.                                " Extrakt
*
*    AT NEW ep-bukrs.
*      REFRESH ep_sum.
*      CLEAR gt_master_table.
*      gt_master_table-bukrs = ep-bukrs.
*      PERFORM read_t001 USING ep-bukrs.
*    ENDAT.
*
*    PERFORM append_bseg.
*    MOVE-CORRESPONDING ep TO ep_sum.
*    COLLECT ep_sum.                    " Calculate HWBAS
*
*    AT END OF ep-bukrs.
*      LOOP AT tab_bset_sum WHERE bukrs EQ ep-bukrs.
*        PERFORM append_bset.
*      ENDLOOP.                         " at tab_bset_sum
*      APPEND gt_master_table.
*
*
*    ENDAT.
*
*  ENDLOOP.                             " Extrakt
* ----- end delete "984821


* create all fieldcats                                      "984821
  PERFORM create_fieldcat                                   "984821
          USING:    c_struc_name_12,                        "984821
                    c_struc_name_3,                         "984821
                    c_struc_name_4,                         "984821
                    c_struc_name_5.                         "984821

* LOOP: Field-Symbol <s_master_table> is a pointer
  LOOP AT gt_master_table ASSIGNING <s_master_table>.
    PERFORM append_pointer USING:
    <s_master_table>-t_output_item
    'RFUMS_ALV_VAT'
    c_handle_1 par_var1 par_lis1 TEXT-301 <s_master_table>-bukrs,"OP-02

    <s_master_table>-t_input_item
    'RFUMS_ALV_VAT'
    c_handle_2 par_var2 par_lis2 TEXT-302 <s_master_table>-bukrs,"OP-02

    <s_master_table>-t_output_sum
    'RFUMS_ALV_OUTPUT_VAT'
    c_handle_3 par_var3 par_lis3 TEXT-303 <s_master_table>-bukrs,"OP-02

    <s_master_table>-t_input_sum
    'RFUMS_ALV_INPUT_VAT'
    c_handle_4 par_var4 par_lis4 TEXT-304 <s_master_table>-bukrs,"OP-02

    <s_master_table>-t_totals                               "984821
    c_struc_name_5                                          "984821
    c_handle_5 par_var5 par_lis5 TEXT-305 <s_master_table>-bukrs. "984821
  ENDLOOP.

  IF NOT sel_hkon IS INITIAL.                               "975820
    PERFORM suppress_tax_totals.                            "975820
  ENDIF.                                                    "975820

*---------------------------------------------------------------------*
*       Fehlerprotokoll                                               *
*---------------------------------------------------------------------*
* add message about deleted items due to authorization      "2711917
  IF gd_cnt_no_auth > 0.                                    "2711917
    DATA:ldummy.
    MESSAGE s398(f5a) WITH gd_cnt_no_auth
            INTO ldummy.
    CALL FUNCTION 'LDB_LOG_WRITE'.
  ENDIF.                                                    "2711917

  CALL FUNCTION 'FI_MESSAGE_CHECK'
    EXCEPTIONS
      no_message = 4.
  IF sy-subrc = 0.
    CALL FUNCTION 'FI_MESSAGE_GET'
      TABLES
        t_fimsg = tfimsg.
    PERFORM append_pointer
         USING:
              tfimsg[] 'FIMSG'
              space space 'X' TEXT-129 space.
  ENDIF.


*---------------------------------------------------------------------*
*       Ausgabe                                                       *
*---------------------------------------------------------------------*
  hlp_repid = sy-repid.
  CALL FUNCTION 'TAX_REP_PRINT_N_ALV_LISTS'
    EXPORTING
      im_batch_heading = 'X'
      im_bh_extra_line = par_line
      im_repid         = hlp_repid
    TABLES
      tb_alv_table     = gt_pointer_master_table.

  PERFORM log_add_msg USING gs_log_handle.         "Log Handle.


*----------------------------------------------------------------------*
* FORM COMPRESS_EP_SUM                                         "2878204
*----------------------------------------------------------------------*
* With additional records created in EP_SUM, the key might no longer
* be unique. Therefore we compress again.
*----------------------------------------------------------------------*
FORM compress_ep_sum.                                       "2878204

  DATA: lt_ep_sum LIKE ep_sum OCCURS 0.

  lt_ep_sum[] = ep_sum[].
  CLEAR ep_sum[].

  LOOP AT lt_ep_sum INTO ep_sum.
    COLLECT ep_sum.
  ENDLOOP.
  FREE lt_ep_sum.

ENDFORM.           "compress_ep_sum                            "2878204
************************************************************************
* Unterprogramme                                                       *
*----------------------------------------------------------------------*
* READ_T001                  Buchungskreisdaten lesen                  *
* READ_T007A                 Umsatzsteuerdaten lesen                   *
* READ_T007B                 Verrechnungsschlüsseldaten lesen          *
* RAHMEN                     Rahmen vorbereiten                        *
* LIST_HEADER                List-Überschrift aufbauen                 *
* PRINT_BSEG                 Zeile der Einzelpostenliste               *
* PRINT_BSET_SUM             Zeile der Steuersummenliste               *
************************************************************************



*----------------------------------------------------------------------*
* FORM READ_T001                                                       *
*----------------------------------------------------------------------*
* Lesen der Buchungskreisdaten aus TAB_001 oder T001 / T005            *
*----------------------------------------------------------------------*
* Parameter BUKRS ist Leseargument                                     *
*----------------------------------------------------------------------*
FORM read_t001 USING bukrs.

  DATA: ls_ttxd TYPE ttxd.                                  "1129096

  CLEAR tab_001.
  READ TABLE tab_001 WITH KEY bukrs = bukrs.

  IF sy-subrc NE 0.
    SELECT SINGLE * FROM t001
      WHERE bukrs EQ bukrs.
    IF sy-subrc NE 0.
      IF sy-batch <> space.
        MESSAGE s100 WITH bukrs.
        APPEND VALUE #( id = sy-msgid type = sy-msgty number = sy-msgno  ) TO gt_message_all.
        MESSAGE s207 WITH sy-repid.
        APPEND VALUE #( id = sy-msgid type = sy-msgty number = sy-msgno  ) TO gt_message_all.
**      gd_selection_stopped = 'X'.                "1066663 "2158177
        MESSAGE a273                                        "2158177
                WITH bkpf-bukrs bkpf-belnr bkpf-gjahr.      "2158177
        APPEND VALUE #( id = sy-msgid type = sy-msgty number = sy-msgno  ) TO gt_message_all.

*        IF xhana = 'E'.                                    "2158177
*          RETURN.                                          "2158177
*        ELSE.                                              "2158177
*          STOP.                                            "2158177
*        ENDIF.                                             "2158177

      ELSE.
        MESSAGE a100 WITH bukrs.
        APPEND VALUE #( id = sy-msgid type = sy-msgty number = sy-msgno  ) TO gt_message_all.
      ENDIF.
    ELSE.
      MOVE-CORRESPONDING t001 TO tab_001.
      IF alcur EQ 'X'.
*       IF xhana = 'E'.                                     "2158177
        IF gd_via_ldb = abap_false.                         "2158177
          PERFORM read_taltwar USING bukrs.
        ENDIF.
        tab_001-waers = taltwar-alwar.
      ENDIF.  "<<< euro
      SELECT SINGLE * FROM t005
        WHERE land1 EQ t001-land1.
      IF sy-subrc NE 0.
        IF sy-batch <> space.
          MESSAGE s223 WITH t001-land1.
          APPEND VALUE #( id = sy-msgid type = sy-msgty number = sy-msgno  ) TO gt_message_all.
          MESSAGE s207 WITH sy-repid.
          APPEND VALUE #( id = sy-msgid type = sy-msgty number = sy-msgno  ) TO gt_message_all.
**        gd_selection_stopped = 'X'.              "1066663 "2158177
          MESSAGE a273                                      "2158177
                  WITH bkpf-bukrs bkpf-belnr bkpf-gjahr.    "2158177
          APPEND VALUE #( id = sy-msgid type = sy-msgty number = sy-msgno  ) TO gt_message_all.

*          IF xhana = 'E'.                                  "2158177
*            RETURN.                                        "2158177
*          ELSE.                                            "2158177
*            STOP.                                          "2158177
*          ENDIF.                                           "2158177
        ELSE.
          MESSAGE a223 WITH t001-land1.
          APPEND VALUE #( id = sy-msgid type = sy-msgty number = sy-msgno  ) TO gt_message_all.
        ENDIF.
      ELSE.
        tab_001-kalsm = t005-kalsm.
      ENDIF.
      CLEAR tab_001-xtxjcd.                                 "1129096
      SELECT SINGLE * FROM ttxd INTO ls_ttxd                "1129096
             WHERE kalsm = tab_001-kalsm.                   "1129096
      IF sy-subrc = 0.                                      "1129096
        tab_001-xtxjcd = 'X'.                               "1129096
      ENDIF.                                                "1129096

      APPEND tab_001.
    ENDIF.
  ENDIF.

ENDFORM.                                                    "read_t001



*----------------------------------------------------------------------*
* FORM READ_T007A                                                      *
*----------------------------------------------------------------------*
* Lesen der Umsatzsteuerdaten aus TAB_007A oder T007A /T007S           *
*----------------------------------------------------------------------*
* Parameter KALSM und MWSKZ sind Leseargument                          *
*----------------------------------------------------------------------*
FORM read_t007a USING kalsm mwskz.

  CLEAR tab_007a.
  READ TABLE tab_007a WITH KEY kalsm = kalsm
                               mwskz = mwskz.

  IF sy-subrc NE 0.
    SELECT SINGLE * FROM t007a
      WHERE kalsm EQ kalsm
      AND   mwskz EQ mwskz.
    IF sy-subrc NE 0.
      IF sy-batch <> space.
        MESSAGE s224 WITH kalsm mwskz.
        MESSAGE s207 WITH sy-repid.
*        gd_selection_stopped = 'X'.               "1066663 "2158177
*        IF xhana = 'E'.                                    "2158177
*          RETURN.                                          "2158177
*        ELSE.                                              "2158177
*          STOP.                                            "2158177
*        ENDIF.                                             "2158177
        MESSAGE a273                                        "2158177
                WITH bkpf-bukrs bkpf-belnr bkpf-gjahr.      "2158177
      ELSE.
        MESSAGE a224 WITH kalsm mwskz.
      ENDIF.
    ELSE.
      MOVE-CORRESPONDING t007a TO tab_007a.
      SELECT SINGLE * FROM t007s
        WHERE spras EQ sy-langu
        AND   kalsm EQ kalsm
        AND   mwskz EQ mwskz.
      IF sy-subrc NE 0.
        IF sy-batch NE space.
          MESSAGE s225 WITH mwskz kalsm sy-langu.
        ENDIF.
      ELSE.
        tab_007a-text1 = t007s-text1.
      ENDIF.
    ENDIF.
    APPEND tab_007a.
  ENDIF.

ENDFORM.                                                    "read_t007a



*----------------------------------------------------------------------*
* FORM READ_T007B                                                      *
*----------------------------------------------------------------------*
* Lesen der Verrechnungsschlüsseldaten aus TAB_007B                    *
*----------------------------------------------------------------------*
* Parameter KTOSL ist Leseargument                                     *
*----------------------------------------------------------------------*
FORM read_t007b USING ktosl.

  CLEAR tab_007b.
  READ TABLE tab_007b WITH KEY ktosl = ktosl.
  IF sy-subrc NE 0.
    IF sy-batch <> space.
      MESSAGE s226 WITH ktosl.
      MESSAGE s207 WITH sy-repid.
*      gd_selection_stopped = 'X'.                 "1066663 "2158177
*      IF xhana = 'E'.                                      "2158177
*        RETURN.                                            "2158177
*      ELSE.                                                "2158177
*        STOP.                                              "2158177
*      ENDIF.                                               "2158177
      MESSAGE a273                                          "2158177
              WITH bkpf-bukrs bkpf-belnr bkpf-gjahr.        "2158177
    ELSE.
      MESSAGE a226 WITH ktosl.
    ENDIF.
  ENDIF.

ENDFORM.                                                    "read_t007b



* ----- begin delete "984821
**----------------------------------------------------------------------*
** FORM APPEND_BSEG                                                     *
**----------------------------------------------------------------------*
** ToDo: Kommentar                                                      *
**----------------------------------------------------------------------*
*FORM append_bseg.
*  DATA: l_vat_item TYPE rfums_alv_vat.
*  MOVE-CORRESPONDING ep TO l_vat_item.
*  l_vat_item-hwbas = ep-dmbtr.
*  l_vat_item-mldwaer = tab_001-waers.
*  l_vat_item-gjahr = ep-buper(4).
*  l_vat_item-monat = ep-buper+4.
*  IF ep-mwart = 'A' AND par_lis1 = 'X'.
*    APPEND l_vat_item TO gt_master_table-t_output_item.
*  ELSEIF ep-mwart = 'V' AND par_lis2 = 'X'.
*    APPEND l_vat_item TO gt_master_table-t_input_item.
*  ENDIF.
*ENDFORM.                    "append_bseg
* ----- end delete "984821




*----------------------------------------------------------------------*
* FORM APPEND_BSET                                                     *
*----------------------------------------------------------------------*
* ToDo: Kommentar                                                      *
*----------------------------------------------------------------------*
FORM append_bset.
  DATA: l_vat_sum TYPE rfums_alv_output_vat.
  DATA(lv_kalsm) = COND #( WHEN flg_txa_active = abap_true
                             THEN cl_fot_common_dao=>agent->get_country_data(
                                         tab_bset_sum-tax_country )-kalsm
                           ELSE tab_001-kalsm ).

  MOVE-CORRESPONDING tab_bset_sum TO l_vat_sum.
  CLEAR l_vat_sum-hwbas.                                    "552412
  l_vat_sum-mldwaer = tab_001-waers.


  PERFORM read_t007a USING lv_kalsm tab_bset_sum-mwskz.
  l_vat_sum-text1 = tab_007a-text1.

  LOOP AT ep_sum WHERE tax_country = tab_bset_sum-tax_country "RITA
                   AND mwskz = tab_bset_sum-mwskz           "552412
                   AND txdat_from = tab_bset_sum-txdat_from "TDT
                   AND ktosl = tab_bset_sum-ktosl           "2526464
                   AND bukrs = tab_bset_sum-bukrs.          "984821
    l_vat_sum-hwbas = l_vat_sum-hwbas + ep_sum-dmbtr.       "552412
  ENDLOOP.                                                  "552412

  CHECK sy-subrc = 0.                                       "652766

  READ TABLE ep_sum WITH KEY tax_country = tab_bset_sum-tax_country "RITA
                             mwskz = tab_bset_sum-mwskz
                             txdat_from = tab_bset_sum-txdat_from "TDT
                             ktosl = tab_bset_sum-ktosl     "2526464
                             bukrs = tab_bset_sum-bukrs     "984821
                        umsks = 'A'.                        "552412
  IF sy-subrc EQ 0.
    l_vat_sum-hwbasdp = ep_sum-dmbtr.
  ENDIF.

  IF tab_bset_sum-stbkz EQ 3.
    IF tab_bset_sum-stgrp NE 4.
      l_vat_sum-remark = TEXT-126.
    ELSE.
      l_vat_sum-remark = TEXT-127.
    ENDIF.
  ENDIF.

* ----- begin of deletion -----                             "820861
*  if  ( ( l_vat_sum-hwbasdp >= 0 ) and ( l_vat_sum-hwbas >= 0 ) )
*  or  ( ( l_vat_sum-hwbasdp < 0 ) and ( l_vat_sum-hwbas < 0 ) )."552412
*    if tab_bset_sum-shkzg = 'S'.                            "533153
*      l_vat_sum-hwbas = abs( l_vat_sum-hwbas ).             "499476
*      l_vat_sum-hwbasdp = abs( l_vat_sum-hwbasdp ).
*    ELSE.                          .                        "499476
*      l_vat_sum-hwbasdp = abs( l_vat_sum-hwbasdp ).
*      l_vat_sum-hwbasdp = - l_vat_sum-hwbasdp.
*      l_vat_sum-hwbas = abs( l_vat_sum-hwbas ).             "499476
*      l_vat_sum-hwbas = - l_vat_sum-hwbas.                  "499476
*    ENDIF.                                                  "499476
*  else.
*    if tab_bset_sum-shkzg = 'S'.                            "533153
*      l_vat_sum-hwbas = abs( l_vat_sum-hwbas ).             "499476
*      l_vat_sum-hwbasdp = abs( l_vat_sum-hwbasdp ).
*      l_vat_sum-hwbasdp = - l_vat_sum-hwbasdp.
*    ELSE.                          .                        "499476
*      l_vat_sum-hwbasdp = abs( l_vat_sum-hwbasdp ).
*      l_vat_sum-hwbas = abs( l_vat_sum-hwbas ).             "499476
*      l_vat_sum-hwbas = - l_vat_sum-hwbas.                  "499476
*    ENDIF.                                                  "499476
*  endif.
* ----- end of deletion -----                               "820861
* If output tax is calculated on input base (i.e. ESA)      "820861
* or vice versa reverse the sign of the base amounts.       "820861
  IF tab_007a-mwart EQ 'V'                                  "820861
     AND tab_bset_sum-mwart EQ 'A'                          "820861
     OR  tab_007a-mwart EQ 'A'                              "820861
     AND tab_bset_sum-mwart EQ 'V'.                         "820861
    l_vat_sum-hwbasdp = - l_vat_sum-hwbasdp.                "820861
    l_vat_sum-hwbas   = - l_vat_sum-hwbas.                  "820861
  ENDIF.                                                    "820861

  IF tab_bset_sum-mwart = 'A' AND par_lis3 = 'X'.
*   APPEND l_vat_sum TO gt_master_table-t_output_sum.       "984821
    APPEND l_vat_sum TO <s_master_table>-t_output_sum.      "984821
  ELSEIF tab_bset_sum-mwart = 'V' AND par_lis4 = 'X'.
*   APPEND l_vat_sum TO gt_master_table-t_input_sum.        "984821
    APPEND l_vat_sum TO <s_master_table>-t_input_sum.       "984821
  ENDIF.
ENDFORM.                    "append_bset



*---------------------------------------------------------------------*
*       FORM LINK_MM                                                  *
*---------------------------------------------------------------------*
*       Based on the material number, the valuation class, the whole  *
*       accountdetermination will be read in order to replace the     *
*       the WRX and freight-accounts by the correct account           *
*       The search of the accountdetermination is done in form        *
*       MM_ACCOUNT                                                    *
*---------------------------------------------------------------------*
FORM link_mm.
  READ TABLE mm_table WITH KEY matnr = bseg-matnr.
  IF sy-subrc NE 0.
    PERFORM read_mm_account."look into mm-configuration + fill mm_table
  ENDIF.
  IF bseg-hkont EQ mm_table-wrxs OR bseg-hkont EQ mm_table-wrxh.
    IF bseg-shkzg EQ 'S'.
      IF mm_table-eins NE space.                            "843610
        purch_acc_found = 'X'.                              "843610
*       ep-hkont = mm_table-eins.                           "984821
*       tab_konto-hkont = mm_table-eins.                    "984821
        bseg-hkont = mm_table-eins.
      ENDIF.                                                "843610
    ELSE.
      IF mm_table-einh NE space.                            "843610
        purch_acc_found = 'X'.                              "843610
*       ep-hkont = mm_table-einh.                           "984821
*       tab_konto-hkont = mm_table-einh.                    "984821
        bseg-hkont = mm_table-einh.
      ENDIF.                                                "843610
    ENDIF.
  ELSEIF bseg-hkont EQ mm_table-fr1s OR bseg-hkont EQ mm_table-fr1h
      OR bseg-hkont EQ mm_table-fr2s OR bseg-hkont EQ mm_table-fr2h
      OR bseg-hkont EQ mm_table-fr3s OR bseg-hkont EQ mm_table-fr3h
      OR bseg-hkont EQ mm_table-fr4s OR bseg-hkont EQ mm_table-fr4h
      OR bseg-hkont EQ mm_table-rues OR bseg-hkont EQ mm_table-rueh.
    IF bseg-shkzg EQ 'S'.
      IF mm_table-fres NE space.                            "843610
        purch_acc_found = 'X'.                              "843610
        bseg-hkont = mm_table-fres.
      ENDIF.                                                "843610
    ELSE.
      IF mm_table-freh NE space.                            "843610
        purch_acc_found = 'X'.                              "843610
        bseg-hkont = mm_table-freh.
      ENDIF.                                                "843610
    ENDIF.
  ENDIF.
* Check if the account is already the purchase account        "945304
  IF purch_acc_found IS INITIAL.                            "945304
    IF bseg-hkont EQ mm_table-eins OR                       "945304
       bseg-hkont EQ mm_table-einh OR                       "945304
       bseg-hkont EQ mm_table-fres OR                       "945304
       bseg-hkont EQ mm_table-freh.                         "945304
      purch_acc_found = 'X'.                                "945304
    ENDIF.                                                  "945304
  ENDIF.                                                    "945304
ENDFORM.                    "link_mm
*---------------------------------------------------------------------*
*       FORM MM_ACCOUNT                                               *
*---------------------------------------------------------------------*
*       MM-logic to retreive the accountdetermination based on the    *
*       value-class                                                   *
*       Once found - accounts are stored in an internal table mm_table*
*---------------------------------------------------------------------*
FORM read_mm_account.
  DATA: BEGIN OF mm_determination,     " 8 possible mm detreminations
          wrx(3) VALUE 'WRX',
          ein(3) VALUE 'EIN',
          fr1(3) VALUE 'FR1',
          fr2(3) VALUE 'FR2',
          fr3(3) VALUE 'FR3',
          fr4(3) VALUE 'FR4',
          rue(3) VALUE 'RUE',
          fre(3) VALUE 'FRE',
        END OF mm_determination,

        BEGIN OF mm_account_structure ,      "used for m-corr to mm_table
          wrxs LIKE t030-konts,            "G/R I/R -g/l-account D
          wrxh LIKE t030-konth,            "G/R I/R -g/l-account C
          eins LIKE t030-konts,            "purchasing g/l-account D
          einh LIKE t030-konth,            "purchasing g/l-account c
          fr1s LIKE t030-konts,            "freight g/l-account D
          fr1h LIKE t030-konth,            "freight g/l-account c
          fr2s LIKE t030-konts,            "freight 2 g/l-account D
          fr2h LIKE t030-konth,            "freight 2 g/l-account c
          fr3s LIKE t030-konts,            "freight 3 g/l-account d
          fr3h LIKE t030-konth,            "freight 4 g/l-account c
          fr4s LIKE t030-konts,            "freight 4 g/l-account d
          fr4h LIKE t030-konth,            "freight 4 g/l-account c
          rues LIKE t030-konts,            "provisions g/l-account d
          rueh LIKE t030-konth,            "provisions g/l-account c
          fres LIKE t030-konts,            "offset for FR1-RUE D
          freh LIKE t030-konth,            "offset for FR1-RUE D
        END OF mm_account_structure,
        mm_account LIKE bseg-hkont,   "receives account from call function
        index      LIKE sy-index.               "index for mm_account_structure

  FIELD-SYMBOLS: <p_determination>,    "pointer for call function
                 <p_account>.          "pointer mm_account_structure

* search for bwmod  - determine how accountdetermination is set up
* based on plant or company code ?
  SELECT SINGLE * FROM t001k
         WHERE bwkey = bseg-bwkey.

  hlp_bwmod = t001k-bwmod.

* search for value class - reading the table of the materials to find
* out the value class
  SELECT SINGLE * FROM mbew
       WHERE matnr = bseg-matnr
       AND   bwkey = bseg-bwkey
       AND   bwtar = bseg-bwtar.
  hlp_bklas = mbew-bklas.

  DO 8 TIMES.                          "all mm_determinations
    ASSIGN COMPONENT sy-index OF
           STRUCTURE mm_determination TO <p_determination>.
* first debit
    CLEAR mm_account.
    l_wrxmod-ebeln = bseg-ebeln.                            "OP-05
    l_wrxmod-ebelp = bseg-ebelp.                            "OP-05
    CALL FUNCTION 'MR_ACCOUNT_ASSIGNMENT'
      EXPORTING
        kontenplan             = t001-ktopl
        vorgangsschluessel     = <p_determination>
        bewertung_modif        = hlp_bwmod
        konto_modif            = ' '
        bewertungsklasse       = hlp_bklas
        soll_haben_kennzeichen = 'S'
        i_wrxmod               = l_wrxmod                   "OP-05
      IMPORTING
        konto                  = mm_account
        buchungsschluessel     = bseg-bschl
      EXCEPTIONS
        not_found_t030         = 1
        not_found_t030r        = 2
        not_found_t030b        = 3
        not_found_t030s        = 4.

    IF sy-subrc = 0.                   "anything to fill in structure ?
      index = ( sy-index - 1 ) * 2 + 1."index for insert in structure
      ASSIGN COMPONENT index
             OF STRUCTURE mm_account_structure TO <p_account>.
      <p_account> = mm_account.        "fill structure mm_account
    ENDIF.
* next credit
    CLEAR mm_account.
    CALL FUNCTION 'MR_ACCOUNT_ASSIGNMENT'
      EXPORTING
        kontenplan             = t001-ktopl
        vorgangsschluessel     = <p_determination>
        bewertung_modif        = hlp_bwmod
        konto_modif            = ' '
        bewertungsklasse       = hlp_bklas
        soll_haben_kennzeichen = 'H'
        i_wrxmod               = l_wrxmod                   "OP-05
      IMPORTING
        konto                  = mm_account
        buchungsschluessel     = bseg-bschl
      EXCEPTIONS
        not_found_t030         = 1
        not_found_t030r        = 2
        not_found_t030b        = 3
        not_found_t030s        = 4.

    IF sy-subrc = 0.                   "anything to fill in structure ?
      index = sy-index * 2   .         " index for insert in structure
      ASSIGN COMPONENT index
             OF STRUCTURE mm_account_structure TO <p_account>.
      <p_account> = mm_account.        "fill structure mm_account
    ENDIF.

  ENDDO.

  MOVE-CORRESPONDING mm_account_structure TO mm_table. "fill table
  APPEND mm_table.
ENDFORM.                    "read_mm_account


*---------------------------------------------------------------------*
*       FORM LINK2_MM                                                 *
*---------------------------------------------------------------------*
*       WHEN NO STOCK IS KEPT - MATERIAL NUMBER IS NOT KNOWN          *
*       in that case the account to be replaced can be found in table *
*       ekkn                                                          *
*---------------------------------------------------------------------*
FORM link2_mm.
  DATA: ls_rbco       TYPE rbco,                            "1152275
        ls_ekpo       TYPE ekpo,                            "1152275
        ls_essr       TYPE essr,                            "1152275
        ls_eskn       TYPE eskn,                            "1152275
        ls_rseg       TYPE rseg,                            "1164660
        ld_rseg_ok    TYPE xfeld,                           "1164660
        ld_lfgja      TYPE lfgja,                           "1164660
        ld_lfbnr      TYPE lfbnr,                           "1164660
        ld_lfpos      TYPE lfpos,                           "1164660
        ld_belnr      TYPE belnr_d,                         "1164660
        ld_gjahr      TYPE gjahr,                           "1164660
        ld_rbco_saknr TYPE saknr.                           "1164660

* check for services.                                       "1152275
  SELECT SINGLE * FROM ekpo INTO ls_ekpo                    "1152275
         WHERE ebeln = bseg-ebeln                           "1152275
           AND ebelp = bseg-ebelp.                          "1152275
  IF sy-subrc = 0                                           "1152275
     AND ls_ekpo-pstyp = '9'.                               "1152275
    IF bkpf-awtyp = 'RMRP '                                 "1152275
       AND bseg-zekkn <> 0.                                 "1152275
      ld_belnr = bkpf-awkey+0(10).                          "1164660
      ld_gjahr = bkpf-awkey+10(4).                          "1164660
      CLEAR ld_rseg_ok.                                     "1164660
* Access rseg using the reference document in bseg-xref3.   "1164660
* This access should be unique.                             "1164660
      IF bseg-xref3+00(04) CO '0123456789' AND              "1164660
         bseg-xref3+04(10) NE space        AND              "1164660
         bseg-xref3+14(04) CO '0123456789' AND              "1164660
         bseg-xref3+18 EQ space.                            "1164660
        ld_lfgja = bseg-xref3+00(04).                       "1164660
        ld_lfbnr = bseg-xref3+04(10).                       "1164660
        ld_lfpos = bseg-xref3+14(04).                       "1164660
        SELECT SINGLE * FROM rseg INTO ls_rseg              "1164660
               WHERE belnr = ld_belnr                       "1164660
                 AND gjahr = ld_gjahr                       "1164660
                 AND ebeln = bseg-ebeln                     "1164660
                 AND ebelp = bseg-ebelp                     "1164660
                 AND lfbnr = ld_lfbnr                       "1164660
                 AND lfgja = ld_lfgja                       "1164660
                 AND lfpos = ld_lfpos.                      "1164660
        IF sy-subrc = 0.                                    "1164660
          ld_rseg_ok = 'X'.                                 "1164660
        ENDIF.                                              "1164660
      ENDIF.                                                "1164660
* If xref3 does not prove useful (maybe because there is    "1164660
* a substitution active) we try to do without it.           "1164660
      IF ld_rseg_ok IS INITIAL.                             "1164660
        SELECT * FROM rseg INTO ls_rseg                     "1164660
               WHERE belnr = ld_belnr                       "1164660
                 AND gjahr = ld_gjahr                       "1164660
                 AND ebeln = bseg-ebeln                     "1164660
                 AND ebelp = bseg-ebelp.                    "1164660
        ENDSELECT.                                          "1164660
        IF sy-subrc = 0 AND                                 "1164660
           sy-dbcnt = 1.                                    "1164660
          ld_rseg_ok = 'X'.                                 "1164660
        ENDIF.                                              "1164660
      ENDIF.                                                "1164660
      CLEAR ld_rbco_saknr.                                  "1164660
      IF ld_rseg_ok = 'X'..                                 "1164660
* If access to rseg was sucessful use buzei for a more      "1164660
* specific access to rbco. This is not always unique.       "1164660
* Therefore we take the account only if it is unique.       "1164660
        SELECT * FROM rbco INTO ls_rbco                     "1164660
               WHERE belnr = ld_belnr                       "1164660
                 AND gjahr = ld_gjahr                       "1164660
                 AND buzei = ls_rseg-buzei                  "1164660
                 AND zekkn = bseg-zekkn.                    "1164660
          IF NOT ls_rbco-saknr IS INITIAL.                  "1164660
            IF ld_rbco_saknr IS INITIAL.                    "1164660
              ld_rbco_saknr = ls_rbco-saknr.                "1164660
            ELSEIF ld_rbco_saknr NE ls_rbco-saknr.          "1164660
              CLEAR ld_rbco_saknr.                          "1164660
              EXIT.                                         "1164660
            ENDIF.                                          "1164660
          ENDIF.                                            "1164660
        ENDSELECT.                                          "1164660
      ELSE.                                                 "1164660
* General access to rbco. This is not always unique.        "1164660
* Therefore we take the account only if it is unique.       "1164660
        SELECT * FROM rbco INTO ls_rbco                     "1164660
               WHERE belnr = ld_belnr                       "1164660
                 AND gjahr = ld_gjahr                       "1164660
                 AND zekkn = bseg-zekkn.                    "1164660
          IF NOT ls_rbco-saknr IS INITIAL.                  "1164660
            IF ld_rbco_saknr IS INITIAL.                    "1164660
              ld_rbco_saknr = ls_rbco-saknr.                "1164660
            ELSEIF ld_rbco_saknr NE ls_rbco-saknr.          "1164660
              CLEAR ld_rbco_saknr.                          "1164660
              EXIT.                                         "1164660
            ENDIF.                                          "1164660
          ENDIF.                                            "1164660
        ENDSELECT.                                          "1164660
      ENDIF.                                                "1164660
      IF ld_rbco_saknr NE space.                            "1164660
        purch_acc_found = 'X'.                              "1164660
        bseg-hkont = ld_rbco_saknr.                         "1164660
      ELSE.                                                 "1174132
* Last trial using amounts. Check for unique account.       "1174132
        SELECT * FROM rbco INTO ls_rbco                     "1174132
               WHERE belnr = ld_belnr                       "1174132
                 AND gjahr = ld_gjahr                       "1174132
                 AND zekkn = bseg-zekkn                     "1174132
                 AND wrbtr = bseg-wrbtr.                    "1174132
          IF NOT ls_rbco-saknr IS INITIAL.                  "1174132
            IF ld_rbco_saknr IS INITIAL.                    "1174132
              ld_rbco_saknr = ls_rbco-saknr.                "1174132
            ELSEIF ld_rbco_saknr NE ls_rbco-saknr.          "1174132
              CLEAR ld_rbco_saknr.                          "1174132
              EXIT.                                         "1174132
            ENDIF.                                          "1174132
          ENDIF.                                            "1174132
        ENDSELECT.                                          "1174132
        IF ld_rbco_saknr NE space.                          "1174132
          purch_acc_found = 'X'.                            "1174132
          bseg-hkont = ld_rbco_saknr.                       "1174132
        ENDIF.                                              "1174132
      ENDIF.                                                "1164660
*      SELECT SINGLE * FROM rbco INTO ls_rbco    "1152275   "1164660
*             WHERE belnr = bkpf-awkey+0(10)     "1152275   "1164660
*               AND gjahr = bkpf-awkey+10(4)     "1152275   "1164660
*               AND zekkn = bseg-zekkn.          "1152275   "1164660
*      IF sy-subrc = 0                           "1152275   "1164660
*         AND ls_rbco-saknr NE space.            "1152275   "1164660
*        purch_acc_found = 'X'.                  "1152275   "1164660
*        bseg-hkont = ls_rbco-saknr.             "1152275   "1164660
*      ENDIF.                                    "1152275   "1164660
    ENDIF.                                                  "1152275

    CHECK purch_acc_found IS INITIAL.                       "1152275

    SELECT SINGLE * FROM essr INTO ls_essr                  "1152275
           WHERE ebeln = bseg-ebeln                         "1152275
             AND ebelp = bseg-ebelp.                        "1152275
    IF sy-subrc = 0.                                        "1152275
      SELECT SINGLE * FROM eskn INTO ls_eskn                "1152275
             WHERE packno = ls_essr-lblni                   "1152275
               AND zekkn  = bseg-zekkn.                     "1152275
      IF sy-subrc = 0.                                      "1152275
        SELECT SINGLE * FROM ekkn                           "1152275
               WHERE ebeln = bseg-ebeln                     "1152275
                 AND ebelp = bseg-ebelp                     "1152275
                 AND zekkn = ls_eskn-bekkn.                 "1152275
        IF sy-subrc = 0                                     "1152275
           AND ekkn-sakto NE space.                         "1152275
          purch_acc_found = 'X'.                            "1152275
          bseg-hkont = ekkn-sakto.                          "1152275
        ELSEIF ls_eskn-sakto NE space.                      "1152275
          purch_acc_found = 'X'.                            "1152275
          bseg-hkont = ls_eskn-sakto.                       "1152275
        ENDIF.                                              "1152275
      ENDIF.                                                "1152275
    ENDIF.                                                  "1152275
  ENDIF.                                                    "1152275

  CHECK purch_acc_found IS INITIAL.                         "1152275

  SELECT SINGLE * FROM ekkn
           WHERE ebeln = bseg-ebeln
            AND  ebelp = bseg-ebelp
            AND  zekkn = bseg-zekkn.
  IF sy-subrc = 0                                           "843610
     AND ekkn-sakto NE space.                               "843610
    purch_acc_found = 'X'.                                  "843610
    bseg-hkont = ekkn-sakto.                                "843610
  ENDIF.                                                    "843610
*  bseg-hkont = ekkn-sakto.                       "843610
*  ep-hkont = ekkn-sakto.               "OP-05    "843610
*  tab_konto-hkont = ekkn-sakto.        "OP-05    "843610
ENDFORM.                                                    "link2_mm


*---------------------------------------------------------------------*
*       FORM check_selection_screen                                   *
*---------------------------------------------------------------------*
FORM check_selection_screen.
*
*DATA: lt_all_bukrs TYPE fagl_t_bukrs,                      "N1542782 "N1762388
*      ls_selected_bukrs               TYPE fagl_s_bukrs.   "N1542782 "N1762388
*
  IF    sel_mona-low EQ 0 AND sel_mona-high EQ 0
    AND sel_bldt-low EQ 0 AND sel_bldt-high EQ 0
    AND sel_vtdt-low EQ 0 AND sel_vtdt-high EQ 0            "1023317
    AND br_budat-low EQ 0 AND br_budat-high EQ 0.
    MESSAGE e239.
  ENDIF.
*                                                           "N1542782
* Prüfen Selektion Umsatzsteuerkreis oder BUKRS prüfen      "N1542782
  IF ( sel_ukrs-low <> space OR sel_ukrs-high <> space ) AND "N1542782
     ( br_bukrs-low <> space OR br_bukrs-high <> space ).   "N1542782
    MESSAGE e236.                                           "N1542782
  ENDIF.                                                    "N1542782
                                                            "N1542782
  IF ( flg_umkrs = 0 ).                                     "N1542782
*  Berechtigungsprüfung Buchungskreis durchführen.          "N1762388
    CALL FUNCTION 'BUKRS_AUTHORITY_CHECK'                   "N1762388
      EXPORTING
        xdatabase = 'B'             "N1762388
      TABLES
        xbukreis  = br_bukrs.       "N1762388
*                                                           "N1762388
    gd_vatdate_active = 'X'. "active in all company codes     "1023317
    SELECT * FROM t001 WHERE bukrs IN br_bukrs.             "1023317
      IF t001-xvatdate IS INITIAL.                          "1023317
        CLEAR gd_vatdate_active.                            "1023317
      ENDIF.                                                "1023317
    ENDSELECT.                                              "1023317

* Selection by vat date is only allowed if vat date is      "1023317
* active in all selected company codes.                     "1023317
    IF gd_vatdate_active IS INITIAL.                        "1023317
      IF NOT sel_vtdt IS INITIAL.                           "1023317
        MESSAGE e275.                                       "1023317
      ENDIF.                                                "1023317
    ENDIF.                                                  "1023317
  ENDIF.                                                    "N1542782
*                                                           "N1542782
  IF flg_umkrs = 1.                                         "N1542782
    SET CURSOR FIELD 'SEL_UKRS-LOW'.                        "N1542782
*   Es wurden Umsatzsteuerkreise abgegrenzt.                "N1542782
*     Existenz zugehöriger Buchungskreise prüfen.           "N1542782
*     Keine Buchungskreise mit Jurisdictionscode.           "N1542782
*     Ggf. Existenz des angegebenen Zahllastkontos prüfen.  "N1542782
    SELECT * FROM t007f                                     "N1542782
      WHERE umkrs IN sel_ukrs.                              "N1542782
      SELECT * FROM t001                                    "N1542782
        WHERE umkrs = t007f-umkrs.                          "N1542782
        SELECT SINGLE * FROM t005 WHERE land1 EQ t001-land1. "N1542782
        IF sy-subrc NE 0.                                   "N1542782
          MESSAGE e256 WITH t001-land1 t001-bukrs.          "N1542782
        ELSE.                                               "N1542782
          SELECT SINGLE * FROM ttxd WHERE kalsm EQ t005-kalsm. "N1542782
          IF sy-subrc EQ 0.                                 "N1542782
            MESSAGE e229.                                   "N1542782
          ENDIF.                                            "N1542782
        ENDIF.                                              "N1542782
        IF t001-xvatdate IS INITIAL.                        "N1542782
          CLEAR gd_vatdate_active.                          "N1542782
        ENDIF.                                              "N1542782
      ENDSELECT.                                            "N1542782
      IF sy-subrc <> 0.                                     "N1542782
        MESSAGE e158 WITH t007f-umkrs.                      "N1542782
        EXIT.                                               "N1542782
      ENDIF.                                                "N1542782
    ENDSELECT.                                              "N1542782
    IF sy-subrc <> 0.                                       "N1542782
      MESSAGE e217.                                         "N1542782
    ENDIF.                                                  "N1542782
    CALL FUNCTION 'TAX_REP_UMKRS_AUTHORITY_CHECK'           "N1542782
      EXPORTING                                             "N1542782
        i_database  = 'B'                                   "N1542782
      TABLES                                                "N1542782
        t_ran_umkrs = sel_ukrs[].                           "N1542782
* Zeitabh. Umsatzsteuerkreise                               "N1542782
  ELSEIF flg_umkrs = '2'.                                   "N1542782
    CALL FUNCTION 'TAX_UMKRS_BUKRS_SELECTED'                "N1542782
      TABLES                                                "N1542782
        t_bukrs       = lt_all_bukrs                  "N1542782
        t_range_bukrs = gt_range_bukrs.               "N1542782
*                                                           "N1542782
    LOOP AT lt_all_bukrs INTO ls_selected_bukrs.            "N1542782
      SELECT SINGLE * FROM t001                             "N1542782
          WHERE bukrs  = ls_selected_bukrs-bukrs.           "N1542782
      IF sy-subrc = 0.                                      "N1542782
        SELECT SINGLE * FROM t005 WHERE land1 EQ t001-land1. "N1542782
        IF sy-subrc NE 0.                                   "N1542782
          MESSAGE e256 WITH t001-land1 t001-bukrs.          "N1542782
        ELSE.                                               "N1542782
                                                            "N1542782
          SELECT SINGLE * FROM ttxd                         "N1542782
            WHERE kalsm EQ t005-kalsm.                      "N1542782
          IF sy-subrc EQ 0.                                 "N1542782
            MESSAGE e229.                                   "N1542782
          ENDIF.                                            "N1542782
        ENDIF.                                              "N1542782
        IF t001-xvatdate IS INITIAL.                        "N1542782
          CLEAR gd_vatdate_active.                          "N1542782
        ENDIF.                                              "N1542782
      ENDIF.                                                "N1542782
    ENDLOOP.                                                "N1542782
*   Berechtigungsprüfung                                    "N1542782
    CALL FUNCTION 'BUKRS_AUTHORITY_CHECK'                   "N1542782
      EXPORTING
        xdatabase = 'B'                             "N1542782
      TABLES
        xbukreis  = gt_range_bukrs.                 "N1542782
  ENDIF.                                                    "N1542782
                                                            "N1762388
* check authority for the leading ledger                    "N1762388
  PERFORM check_ledger_authority                            "N1762388
          USING     flg_umkrs.                              "N1762388
                                                            "N1762388

  IF alcur EQ 'X' AND excdt IS INITIAL."euro
    MESSAGE e144.
  ENDIF.
*                                                  Start of713336 KS-01
* No summation for Input tax when Hkont is selected
  IF NOT sel_hkon IS INITIAL.
    IF par_lis3 = 'X' OR par_lis4 = 'X'.
*     MESSAGE w576.                                         "975820
      MESSAGE w272.                                         "975820
    ENDIF.
  ENDIF.                                            "End of  713336 KS-01

* If par_eink was set: Check against T001-XEINK
  IF NOT par_eink IS INITIAL.
    SELECT * FROM t001 WHERE bukrs IN br_bukrs.
      IF t001-xeink IS INITIAL.
        MESSAGE e249 WITH t001-bukrs.
      ENDIF.
    ENDSELECT.
  ENDIF.
ENDFORM.                    "check_selection_screen


*---------------------------------------------------------------------*
*       FORM config_list                                              *
*---------------------------------------------------------------------*
*       Configure the layout of one ALV output list.                  *
*---------------------------------------------------------------------*
*  -->  u_ucomm                                                       *
*---------------------------------------------------------------------*
FORM config_list USING u_ucomm TYPE sscrfields-ucomm.

  DATA: l_repid      TYPE sy-repid,
        l_struc_name TYPE dd02l-tabname,
        l_variant    TYPE disvariant,
        l_layout     TYPE slis_layout_alv,
        lt_vat_sum   TYPE TABLE OF rfums_alv_output_vat,
        lt_vat_items TYPE TABLE OF rfums_alv_vat,
        lt_totals    TYPE TABLE OF rfums_alv_total_vat.     "984821

  FIELD-SYMBOLS: <table> TYPE STANDARD TABLE.

  l_repid = sy-repid.
  l_layout-group_change_edit = 'X'.

  CASE u_ucomm.
    WHEN 'CON1'.
      l_struc_name = c_struc_name_12.
      ASSIGN lt_vat_items[] TO <table>.
      l_variant-variant = par_var1.
      l_variant-handle = c_handle_1.
    WHEN 'CON2'.
      l_struc_name = c_struc_name_12.
      ASSIGN lt_vat_items[] TO <table>.
      l_variant-variant = par_var2.
      l_variant-handle = c_handle_2.
    WHEN 'CON3'.
      l_struc_name = c_struc_name_3.
      ASSIGN lt_vat_sum[] TO <table>.
      l_variant-variant = par_var3.
      l_variant-handle = c_handle_3.
    WHEN 'CON4'.
      l_struc_name = c_struc_name_4.
      ASSIGN lt_vat_sum[] TO <table>.
      l_variant-variant = par_var4.
      l_variant-handle = c_handle_4.
    WHEN 'CON5'.                                            "984821
      l_struc_name = c_struc_name_5.                        "984821
      ASSIGN lt_totals[] TO <table>.                        "984821
      l_variant-variant = par_var5.                         "984821
      l_variant-handle = c_handle_5.                        "984821
  ENDCASE.

  PERFORM create_fieldcat                                   "984821
          USING l_struc_name.                               "984821

  PERFORM fill_table TABLES <table>.
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = l_repid
*     i_structure_name   = l_struc_name                     "984821
      i_save             = 'A'
      is_layout          = l_layout
      is_variant         = l_variant
      it_fieldcat        = <gt_fieldcat>                    "984821
    TABLES
      t_outtab           = <table>.

ENDFORM.                    "config_list


*&---------------------------------------------------------------------*
*&      Form  FILL_TABLE
*&---------------------------------------------------------------------*
*       Fill Table lt_table with some stupid data
*----------------------------------------------------------------------*
*  -->  lt_table   filled with stupid data
*----------------------------------------------------------------------*
FORM fill_table TABLES lt_table.
  DO 3 TIMES.
    CALL FUNCTION 'INITIALIZE_STRUCTURE'
      EXPORTING
        i_n_fill   = 1
      CHANGING
        c_workarea = lt_table.
    APPEND lt_table.
  ENDDO.
ENDFORM.                               " FILL_TABLE



*---------------------------------------------------------------------*
*       FORM append_pointer                                           *
*---------------------------------------------------------------------*
*       Append a reference and some further information of table      *
*       u_table to table gt_pointer_master_table                      *
*---------------------------------------------------------------------*
*  -->  u_table                                                       *
*  -->  u_structure                                                   *
*  -->  u_handle                                                      *
*  -->  u_variant                                                     *
*  -->  u_append              Append the table u_table                *
*  -->  u_list_title                                                  *
*  -->  u_bukrs                                                       *
*---------------------------------------------------------------------*
FORM append_pointer USING u_table TYPE table
                          u_structure TYPE tabname
                          u_handle TYPE disvariant-handle
                          u_variant TYPE disvariant-variant
                          u_append
                          u_list_title TYPE normtitel
                          u_bukrs TYPE bukrs.
  DATA: l_pointer              TYPE REF TO data,
        l_pointer_fieldcat     TYPE REF TO data,            "984821
        l_variant              TYPE disvariant,
        l_pointer_master_table TYPE tax_alv_table.

  IF u_append = 'X'.

    CLEAR l_pointer_fieldcat.                               "984821
    CASE u_structure.                                       "984821
      WHEN c_struc_name_12.                                 "984821
        GET REFERENCE OF gt_fieldcat_12                     "984821
            INTO l_pointer_fieldcat.                        "984821
      WHEN c_struc_name_3.                                  "984821
        GET REFERENCE OF gt_fieldcat_3                      "984821
            INTO l_pointer_fieldcat.                        "984821
      WHEN c_struc_name_4.                                  "984821
        GET REFERENCE OF gt_fieldcat_4                      "984821
            INTO l_pointer_fieldcat.                        "984821
      WHEN c_struc_name_5.                                  "984821
        GET REFERENCE OF gt_fieldcat_5                      "984821
            INTO l_pointer_fieldcat.                        "984821
    ENDCASE.                                                "984821

    l_variant-report = sy-repid.
    l_variant-handle = u_handle.
    l_variant-variant = u_variant.

    GET REFERENCE OF u_table[] INTO l_pointer.
    l_pointer_master_table-pointer = l_pointer.
*    l_pointer_master_table-structure_name = u_structure.   "984821
    l_pointer_master_table-layout_variant = l_variant.
    l_pointer_master_table-list_title = u_list_title.
    l_pointer_master_table-bukrs = u_bukrs.
    l_pointer_master_table-pointer_fieldcat                 "984821
                       = l_pointer_fieldcat.                "984821
    IF l_pointer_fieldcat IS INITIAL.                       "1115279
      l_pointer_master_table-structure_name = u_structure.  "1115279
    ENDIF.                                                  "1115279

    APPEND l_pointer_master_table TO gt_pointer_master_table.
  ENDIF.

ENDFORM.                    "append_pointer



*---------------------------------------------------------------------*
*       FORM alv_variante_f4                                          *
*---------------------------------------------------------------------*
*       F4 Help for the Display-Variants                              *
*---------------------------------------------------------------------*
FORM alv_variante_f4 USING u_handle TYPE slis_handl.
  DATA: l_variant_help TYPE disvariant,
        l_variant      TYPE disvariant.
  DATA: l_exit TYPE c.                 "User-Exit while F4-Help

  DATA nof4 TYPE c.                                         "522947

  CLEAR nof4.                                               "522947
  LOOP AT SCREEN.                                           "522947
    CASE u_handle.                                          "522947
      WHEN 'HAN1'.                                          "522947
        IF screen-name = 'PAR_VAR1'.                        "522947
          IF screen-input = 0.                              "522947
            nof4 = 'X'.                                     "522947
          ENDIF.                                            "522947
        ENDIF.                                              "522947
      WHEN 'HAN2'.                                          "522947
        IF screen-name = 'PAR_VAR2'.                        "522947
          IF screen-input = 0.                              "522947
            nof4 = 'X'.                                     "522947
          ENDIF.                                            "522947
        ENDIF.                                              "522947
      WHEN 'HAN3'.                                          "522947
        IF screen-name = 'PAR_VAR3'.                        "522947
          IF screen-input = 0.                              "522947
            nof4 = 'X'.                                     "522947
          ENDIF.                                            "522947
        ENDIF.                                              "522947
      WHEN 'HAN4'.                                          "522947
        IF screen-name = 'PAR_VAR4'.                        "522947
          IF screen-input = 0.                              "522947
            nof4 = 'X'.                                     "522947
          ENDIF.                                            "522947
        ENDIF.                                              "522947
      WHEN 'HAN5'.                                          "522947
        IF screen-name = 'PAR_VAR5'.                        "522947
          IF screen-input = 0.                              "522947
            nof4 = 'X'.                                     "522947
          ENDIF.                                            "522947
        ENDIF.                                              "522947
      WHEN 'HAN6'.                                          "522947
        IF screen-name = 'PAR_VAR6'.                        "522947
          IF screen-input = 0.                              "522947
            nof4 = 'X'.                                     "522947
          ENDIF.                                            "522947
        ENDIF.                                              "522947
      WHEN 'HAN7'.                                          "522947
        IF screen-name = 'PAR_VAR7'.                        "522947
          IF screen-input = 0.                              "522947
            nof4 = 'X'.                                     "522947
          ENDIF.                                            "522947
        ENDIF.                                              "522947
    ENDCASE.                                                "522947

  ENDLOOP.                                                  "522947

  l_variant-handle = u_handle.
  l_variant-report = sy-repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = l_variant
      i_save     = 'A'
    IMPORTING
      e_exit     = l_exit
      es_variant = l_variant_help.

  IF l_exit = space AND nof4 EQ space.    "No User-Exit
                                                            "522947
    CASE u_handle.
      WHEN c_handle_1.
        par_var1 = l_variant_help-variant.
      WHEN c_handle_2.
        par_var2 = l_variant_help-variant.
      WHEN c_handle_3.
        par_var3 = l_variant_help-variant.
      WHEN c_handle_4.
        par_var4 = l_variant_help-variant.
      WHEN c_handle_5.                                      "984821
        par_var5 = l_variant_help-variant.                  "984821
    ENDCASE.
  ENDIF.

ENDFORM.                    "alv_variante_f4
*&---------------------------------------------------------------------*
*&      Form  change_bseg_for_fica
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_bseg_for_fica.
  STATICS: BEGIN OF loct_s OCCURS 0,                        "OP-01
             bukrs LIKE skb1-bukrs,                      "OP-01
             saknr LIKE skb1-saknr,                      "OP-01
             mitkz LIKE skb1-mitkz,                      "OP-01
             mwskz LIKE skb1-mwskz,                      "OP-01
           END OF loct_s.                                   "OP-01
  DATA: loc_tabix LIKE sy-tabix.                            "OP-01
  READ TABLE loct_s WITH KEY bukrs = bseg-bukrs             "OP-01
                             saknr = bseg-hkont             "OP-01
                        BINARY SEARCH.                      "OP-01
  loc_tabix = sy-tabix.                                     "OP-01
  IF sy-subrc NE 0.                                         "OP-01
    SELECT SINGLE * FROM skb1                               "OP-01
                    INTO CORRESPONDING FIELDS OF loct_s     "OP-01
                    WHERE bukrs = bseg-bukrs                "OP-01
                    AND saknr = bseg-hkont.                 "OP-01
    INSERT loct_s INDEX loc_tabix.                          "OP-01
  ENDIF.                                                    "OP-01

*------- Simulate account type 'D' customer ----------------------------
  IF loct_s-mitkz = 'V'.
    bseg-koart = 'D'.

*------- Check, that account is used for down payments -----------------
*               (in FI_CA allowed only with +B and -B)
* Simulate UMSKS = 'A' for this case
    CHECK loct_s-mwskz = '+B'
    OR    loct_s-mwskz = '-B'.
    bseg-umsks = 'A'.

*------ Simulate KTOSL 'MVA' and UMSKS = 'A' for tax clearing account --
  ELSEIF bseg-mwskz NE space
  AND    bseg-ktosl EQ space.
    PERFORM rfumsv10_mva IN PROGRAM rfkk_services
            USING    bseg-bukrs bseg-hkont bseg-mwskz bseg-tax_country
            CHANGING bseg-ktosl
            IF FOUND.
    IF bseg-ktosl = 'MVA' OR bseg-ktosl = 'VVA'.            "449241
      bseg-umsks = 'A'.
    ENDIF.
  ENDIF.
ENDFORM.                    " change_bseg_for_fica

INCLUDE make_rldnr_invisible.                               "871301
*&---------------------------------------------------------------------*
*&      Form  change_bseg_xauto                             "913937
*&---------------------------------------------------------------------*
*       Correct BSEG-XAUTO for some applications so that direct
*       tax postings are properly interpreted.
*       This routine is called only for tax postings.
*----------------------------------------------------------------------*
*  -->  bkpf, bseg
*  <--  bseg-xauto
*----------------------------------------------------------------------*
FORM change_bseg_xauto.                                     "913937

* Travel management can only create automatic tax postings,
* but does not set XAUTO.
* IF bkpf-awtyp EQ 'TRAVL' AND bkpf-TCODE EQ 'PRRW'.        "939459
  IF bkpf-awtyp EQ 'TRAVL'.                                 "939459
    bseg-xauto = 'X'.
  ENDIF.

ENDFORM.                    " change_bseg_xauto             "913937
*&---------------------------------------------------------------------*
*&      Form  suppress_tax_totals                           "975820
*&---------------------------------------------------------------------*
* Delete the tax amount column from the totals lists when
* G/L accounts are selected. The tax amounts from BSET are
* not reliable when not all G/L items from a document are
* selcted.
* Technically this is done by passing a fieldcat to the ALV
* and no reference structure name. The tax amount field
* is deleted from the fieldcat.
*----------------------------------------------------------------------*
*  Changes global internal table gt_pointer_master_table
*----------------------------------------------------------------------*
FORM suppress_tax_totals.                                   "975820

* ----- begin of insert "984821
  IF par_lis3 = 'X'.
* Output VAT
    DELETE gt_fieldcat_3
           WHERE fieldname = 'HWSTE '.
  ENDIF.

  IF par_lis4 = 'X'.
* Input VAT
    DELETE gt_fieldcat_4
           WHERE fieldname = 'HWSTE '.
  ENDIF.
* ----- end of insert "984821


* ----- begin of deletion "984821
*  DATA:
*    ls_tax_alv_table TYPE tax_alv_table.
*  STATICS:
*    lt_fieldcat_out TYPE slis_t_fieldcat_alv,
*    lt_fieldcat_inp TYPE slis_t_fieldcat_alv.
*
*  IF par_lis3 = 'X'.
** Output VAT
*
*    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*         EXPORTING
*              i_structure_name = c_struc_name_3
*         CHANGING
*              ct_fieldcat      = lt_fieldcat_out
*         EXCEPTIONS
*              OTHERS           = 3.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*    DELETE lt_fieldcat_out
*           WHERE fieldname = 'HWSTE '.
*
*    LOOP AT gt_pointer_master_table
*         INTO ls_tax_alv_table
*         WHERE structure_name = c_struc_name_3.
*
*      GET REFERENCE OF lt_fieldcat_out[]
*          INTO ls_tax_alv_table-pointer_fieldcat.
*
*      CLEAR ls_tax_alv_table-structure_name.
*
*      MODIFY gt_pointer_master_table
*             FROM ls_tax_alv_table.
*
*    ENDLOOP.
*
*  ENDIF.
*
*  IF par_lis4 = 'X'.
** Input VAT
*
*    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*         EXPORTING
*              i_structure_name = c_struc_name_4
*         CHANGING
*              ct_fieldcat      = lt_fieldcat_inp
*         EXCEPTIONS
*              OTHERS           = 3.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*    DELETE lt_fieldcat_inp
*           WHERE fieldname = 'HWSTE '.
*
*    LOOP AT gt_pointer_master_table
*         INTO ls_tax_alv_table
*         WHERE structure_name = c_struc_name_4.
*
*      GET REFERENCE OF lt_fieldcat_inp[]
*          INTO ls_tax_alv_table-pointer_fieldcat.
*
*      CLEAR ls_tax_alv_table-structure_name.
*
*      MODIFY gt_pointer_master_table
*             FROM ls_tax_alv_table.
*
*    ENDLOOP.
*
*  ENDIF.
* ----- end of deletion "984821

ENDFORM.                    " suppress_tax_totals           "975820
*&---------------------------------------------------------------------*
*&      Form  analyse_bseg                                  "984821
*&---------------------------------------------------------------------*
*  stored in gt_bas
*       items with base amount
*       direct tax postings are manipulated accordingly
*       down payment items
*       tax clearings for down payments are slightly maniputated
*  stored in gt_tax
*       automatic tax postings
*  rejected
*       items without tax code
*       items with non-selected tax codes
*       customer or vendor items which are not down payments
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM analyse_bseg.                                          "984821

  REFRESH: gt_bas,
           gt_tax.

  DATA(lo_fot_common_dao) = cl_fot_common_dao=>agent.
  DATA lv_kalsm TYPE t005-kalsm.

  LOOP AT gt_bseg INTO gs_bseg.

    CHECK:
    gs_bseg-mwskz IN sel_mwkz,
    gs_bseg-mwskz NE space,
    gs_bseg-tax_country IN sel_taxc,
    ( ( 'DK' NA gs_bseg-koart )
    OR ( 'DK' CA gs_bseg-koart AND gs_bseg-ktosl EQ 'BUV'
                            AND gs_bseg-mwskz NE '**' )
    OR ( 'DK' CA gs_bseg-koart AND gs_bseg-umsks EQ 'A' ) ).

    lv_kalsm = COND #( WHEN flg_txa_active = abap_true
                         THEN cl_fot_common_dao=>agent->get_country_data(
                                    gs_bseg-tax_country )-kalsm
                       ELSE tab_001-kalsm ).

    PERFORM read_t007a USING lv_kalsm gs_bseg-mwskz.

    IF ( par_xsau IS INITIAL ).
      CHECK tab_007a-mwart <> 'A'.
    ENDIF.
    IF ( par_xsvo IS INITIAL ).
      CHECK tab_007a-mwart <> 'V'.
    ENDIF.

* Exclude MOSS tax codes unless explicitly selected.        "2101269
    IF ( par_moss IS INITIAL ).                             "2101269
      CHECK tab_007a-mossc IS INITIAL.                      "2101269
    ENDIF.                                                  "2101269

* Initialize headers of gt_bas and gt_tax with
* key field values from bkpf and bseg etc.
    CLEAR: gt_bas,
           gt_tax.
*  The following two moves are important if structure
*  rfums_alv_vat is extended. Here values from
*  bkpf and bseg are inserted automatically.
    MOVE-CORRESPONDING bkpf    TO gt_bas.
    MOVE-CORRESPONDING gs_bseg TO gt_bas.

    gt_bas-gsber_au = gs_bseg-gsber.                        "2711917
    IF gs_bseg-augbl = 'SPLIT'.                             "1845112
      gt_bas-flg_split = 'X'.                               "1845112
    ENDIF.                                                  "1845112
    gt_bas-mldwaer = tab_001-waers.
    gt_bas-mwart   = tab_007a-mwart.
    MOVE-CORRESPONDING gt_bas  TO gt_tax.
    CLEAR: gt_bas-hwbas,
           gt_tax-hwste.

* Set sign of amount fields in bseg which are used here.
    IF gs_bseg-shkzg = 'H'.
      gs_bseg-dmbtr = - gs_bseg-dmbtr.
      gs_bseg-hwbas = - gs_bseg-hwbas.
    ENDIF.

* customer/vendor items
    IF 'DK' CA gs_bseg-koart.

      IF     gs_bseg-ktosl EQ 'BUV'.
        gt_bas-hwbas   = gs_bseg-dmbtr.
        gt_bas-flg_buv = 'X'.
        APPEND gt_bas.
        CONTINUE.
      ENDIF.

* down payment items are used as tax base.
      IF gs_bseg-umsks EQ 'A'.
        PERFORM read_skb1
*               USING    tab_001-bukrs                      "1132306
                USING    gs_bseg-bukrs                      "1132306
                         gs_bseg-hkont
                CHANGING skb1.
        IF skb1-mwskz+1 EQ 'B'.        "Merker für die Anmerkung, daß
          gt_bas-flg_dpg  = 'X'.       "Anzahlung brutto geführt wird
        ENDIF.
        gt_bas-hwbas   = gs_bseg-dmbtr.
        gt_bas-flg_dp = 'X'.
        APPEND gt_bas.
        CONTINUE.
      ENDIF.

      CONTINUE.   "all other customer/vendor items are rejected
    ENDIF.

* anything that's left should be included
* tax postings
    IF NOT gs_bseg-mwart IS INITIAL.
      IF gs_bseg-xauto = 'X'.
*  automatic tax item is processed as tax item --> gt_tax
        IF gd_distribute_tax IS INITIAL.                    "1129096
*      avoid accessing t007b if tax distribution is off.    "1129096
          CONTINUE.                                         "1129096
        ENDIF.                                              "1129096
*   In some old documents ktosl may be missing. Read it     "1461777
*   from BSET. Archived documents can be affected.          "1461777

*       IF xhana <> 'E'.                                    "2158177
        IF gs_bseg-ktosl = space.                           "1461777
*          READ TABLE gt_bset INTO bset WITH KEY   "1461777 "1609989
*               mwskz = gs_bseg-mwskz              "1461777 "1609989
*               hkont = gs_bseg-hkont.             "1461777 "1609989
*          IF sy-subrc = 0 AND NOT bset-ktosl IS INITIAL. "1"1609989
*            gs_bseg-ktosl = bset-ktosl.           "1461777 "1609989
*          ENDIF.                                  "1461777 "1609989
          LOOP AT gt_bset INTO bset                         "1609989
               WHERE tax_country = gs_bseg-tax_country "RITA
                 AND mwskz = gs_bseg-mwskz                  "1609989
                 AND txdat_from = gs_bseg-txdat_from  "TDT
                 AND hkont = gs_bseg-hkont                  "1609989
                 AND ktosl NE space.                        "1609989
            gs_bseg-ktosl = bset-ktosl.                     "1609989
            EXIT.                                           "1609989
          ENDLOOP.                                          "1609989
        ENDIF.
*       ENDIF.                                              "2158177
        PERFORM read_t007b USING gs_bseg-ktosl.
        MOVE-CORRESPONDING tab_007b TO gt_tax.
        IF tab_007b-stgrp = '2'.
          gt_tax-mwart = 'V'.
*       ELSE.                                               "1371996
        ELSEIF tab_007b-stgrp = '1'.                        "1371996
          gt_tax-mwart = 'A'.
        ELSE.                                               "1371996
          gt_tax-mwart = gs_bseg-mwart.                     "1371996
        ENDIF.
        gt_tax-hwste = gs_bseg-dmbtr.
        APPEND gt_tax.
        CONTINUE.
      ELSE.
*  direct tax item is processed as base amount--> gt_bas
        gt_bas-flg_dir  = 'X'.
        gt_bas-flg_done = 'X'.
        gt_bas-hwbas    = gs_bseg-hwbas.
        IF gd_distribute_tax IS NOT INITIAL.                "3028017
          IF gt_bas-mwart = 'A'.
            gt_bas-hwaus = gs_bseg-dmbtr.
          ELSE.
            gt_bas-hwvor = gs_bseg-dmbtr.
          ENDIF.
        ENDIF.                                              "3028017
        APPEND gt_bas.
        CONTINUE.
      ENDIF.
    ENDIF.

*  normal base amounts
    IF gs_bseg-ktosl EQ 'BUV'.
      gt_bas-flg_buv = 'X'.
    ENDIF.
    IF NOT par_rbuv IS INITIAL                              "1132306
       AND gt_bas-bukrs NE bkpf-bukrs.                      "1132306
      gt_bas-flg_buv = 'X'.                                 "1132306
    ENDIF.                                                  "1132306

    IF    gs_bseg-ktosl = 'VVA'
       OR gs_bseg-ktosl = 'MVA'.                            "449241
      gt_bas-flg_dp  ='X'.
      gt_bas-flg_dpg ='X'.
    ENDIF.

    gt_bas-hwbas = gs_bseg-dmbtr.
    APPEND gt_bas.

  ENDLOOP.

ENDFORM.                    " analyse_bseg                   "984821
*&---------------------------------------------------------------------*
*&      Form  distribute_tax                                 "984821
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM distribute_tax.                                        "984821

  DATA: ls_tax      LIKE LINE OF gt_bas,
        ls_tax_s    LIKE LINE OF gt_bas,
        ls_tax_h    LIKE LINE OF gt_bas,
        ld_totbas_s TYPE hwaerbas,
        ld_totbas_h TYPE hwaerbas,
        ld_init     TYPE xfeld.

  DATA: BEGIN OF ls_group,
          tax_country TYPE fot_tax_country,
          mwskz       TYPE mwskz,
          txdat_from  TYPE fot_txdat_from, "TDT
          txgrp(3)    TYPE c,
        END OF ls_group.
  DATA: lt_group LIKE TABLE OF ls_group.

  CONSTANTS:
      lc_big_amount TYPE hwaerbas VALUE '5000000000000'.    "1532387
*   fit to CURR 13 + room for bas + nvv 50.000.000.000,00   "1532387

  PERFORM check_txgrp.

* built list of tax codes, txgrp
  LOOP AT gt_bas
       WHERE flg_done IS INITIAL.
    ls_group-tax_country = gt_bas-tax_country.
    ls_group-mwskz = gt_bas-mwskz.
    ls_group-txdat_from = gt_bas-txdat_from. "TDT
    ls_group-txgrp = gt_bas-txgrp.
    APPEND ls_group TO lt_group.
  ENDLOOP.
  SORT lt_group.
  DELETE ADJACENT DUPLICATES FROM lt_group.

* for all groups ...
  LOOP AT lt_group INTO ls_group.

*  accumulate all tax amounts for a tax code, txgrp
    CLEAR ls_tax.
    LOOP AT gt_tax
         WHERE tax_country = ls_group-tax_country
           AND mwskz = ls_group-mwskz
           AND txdat_from = ls_group-txdat_from  "TDT
           AND txgrp = ls_group-txgrp.

      IF gt_tax-stazf IS INITIAL.
        IF gt_tax-mwart = 'A'.
          ADD gt_tax-hwste TO ls_tax-hwaus.
        ELSE.
          ADD gt_tax-hwste TO ls_tax-hwvor.
        ENDIF.
      ELSE.
        IF gt_tax-mwart = 'A'.
          ADD gt_tax-hwste TO ls_tax-hwanaf.
        ELSE.
          ADD gt_tax-hwste TO ls_tax-hwvnaf.
        ENDIF.
      ENDIF.

    ENDLOOP.

* get the total base amount per tax code, txgrp
* and build up distrib_tab
    CLEAR: ld_totbas_s,
           ld_totbas_h.
    REFRESH distrib_tab.
    LOOP AT gt_bas
         WHERE flg_done IS INITIAL
           AND tax_country = ls_group-tax_country
           AND mwskz = ls_group-mwskz
           AND txdat_from = ls_group-txdat_from "TDT
           AND txgrp = ls_group-txgrp.

      distrib_tab-oldpos  = sy-tabix.
      distrib_tab-hwbas   = abs( gt_bas-hwbas ).
      IF gt_bas-hwbas < 0.
        distrib_tab-shkzg = 'H'.
        ADD gt_bas-hwbas TO ld_totbas_h.
      ELSE.
        distrib_tab-shkzg = 'S'.
        ADD gt_bas-hwbas TO ld_totbas_s.
      ENDIF.

      APPEND distrib_tab.
    ENDLOOP.

* special handling if both debit and credit postings are present
    IF ld_totbas_s <> 0 AND ld_totbas_h <> 0.

      IF abs( ld_totbas_s ) > lc_big_amount.                "1532387
        PERFORM calculate_tax_big                           "1532387
                USING    ld_totbas_s                        "1532387
                         ls_group-tax_country
                         ls_group-mwskz                     "1532387
                         ls_group-txdat_from  "TDT
                         bkpf-bukrs                         "1532387
                         tab_001-waers                      "1532387
                CHANGING ls_tax_s.                          "1532387
      ELSE.                                                 "1532387
        PERFORM calculate_tax
              USING    ld_totbas_s
                       ls_group-tax_country
                       ls_group-mwskz
                       ls_group-txdat_from "TDT
                       bkpf-bukrs
                       tab_001-waers
              CHANGING ls_tax_s.
      ENDIF.                                                "1532387

      IF abs( ld_totbas_h ) > lc_big_amount.                "1532387
        PERFORM calculate_tax_big                           "1532387
                USING    ld_totbas_h                        "1532387
                         ls_group-tax_country
                         ls_group-mwskz                     "1532387
                         ls_group-txdat_from "TDT
                         bkpf-bukrs                         "1532387
                         tab_001-waers                      "1532387
                CHANGING ls_tax_h.                          "1532387
      ELSE.                                                 "1532387
        PERFORM calculate_tax
                USING    ld_totbas_h
                         ls_group-tax_country
                         ls_group-mwskz
                         ls_group-txdat_from "TDT
                         bkpf-bukrs
                         tab_001-waers
                CHANGING ls_tax_h.
      ENDIF.                                                "1532387

* distribute the residual differences
      PERFORM distrib_tax_sh
              USING      ld_totbas_s
                         ld_totbas_h:
                         ls_tax-hwaus
              CHANGING ls_tax_s-hwaus
                       ls_tax_h-hwaus,
                         ls_tax-hwvor
              CHANGING ls_tax_s-hwvor
                       ls_tax_h-hwvor,
                         ls_tax-hwanaf
              CHANGING ls_tax_s-hwanaf
                       ls_tax_h-hwanaf,
                         ls_tax-hwvnaf
              CHANGING ls_tax_s-hwvnaf
                       ls_tax_h-hwvnaf.

* standard case where only debit or credit postings are present
    ELSEIF ld_totbas_s <> 0.
      ls_tax_s = ls_tax.
      CLEAR ls_tax_h.
    ELSE.
      ls_tax_h = ls_tax.
      CLEAR ls_tax_s.
    ENDIF.

* distribute tax amounts
    ld_init = 'X'.
    PERFORM distribute_amount
            USING    ld_totbas_s
                     ld_totbas_h
                     ls_tax_s-hwaus
                     ls_tax_h-hwaus
                     '1'
            CHANGING ld_init.

    PERFORM distribute_amount
            USING    ld_totbas_s
                     ld_totbas_h
                     ls_tax_s-hwvor
                     ls_tax_h-hwvor
                     '2'
            CHANGING ld_init.

    PERFORM distribute_amount
            USING    ld_totbas_s
                     ld_totbas_h
                     ls_tax_s-hwanaf
                     ls_tax_h-hwanaf
                     '3'
            CHANGING ld_init.

    PERFORM distribute_amount
            USING    ld_totbas_s
                     ld_totbas_h
                     ls_tax_s-hwvnaf
                     ls_tax_h-hwvnaf
                     '4'
            CHANGING ld_init.

  ENDLOOP.

ENDFORM.                    " distribute_tax                  "984821
*&---------------------------------------------------------------------*
*&      Form  distribute_amount                               "984821
*&---------------------------------------------------------------------*
FORM distribute_amount                                      "984821
     USING    p_totbas_s TYPE hwaerbas
              p_totbas_h TYPE hwaerbas
              p_amount_s TYPE hwste
              p_amount_h TYPE hwste
              p_taxfield TYPE c
     CHANGING p_init TYPE xfeld.

  DATA: ld_rest_s   TYPE aflex18d2o25s, "AFLE enablement orig (9)type p,
        ld_rest_h   TYPE aflex18d2o25s, "AFLE enablement orig (9)type p,
        ld_weight_s TYPE aflex18d2o25s, "AFLE enablement orig (9)type p,
        ld_weight_h TYPE aflex18d2o25s. "AFLE enablement orig (9)type p,

  IF p_init = 'X'.

    CLEAR: p_init.

    SORT distrib_tab DESCENDING
         BY  shkzg
             hwbas
             oldpos.

  ENDIF.

  IF p_amount_s <> 0 OR p_amount_h <> 0.

    ld_rest_s   = p_amount_s.
    ld_rest_h   = p_amount_h.
    ld_weight_s = p_totbas_s.
    ld_weight_h = abs( p_totbas_h ).

    LOOP AT distrib_tab.
      CLEAR distrib_tab-distr.
      IF distrib_tab-shkzg = 'S'.
        IF ld_weight_s <> 0.
          distrib_tab-distr =
            ld_rest_s * distrib_tab-hwbas / ld_weight_s.
          SUBTRACT distrib_tab-hwbas FROM ld_weight_s.
          SUBTRACT distrib_tab-distr FROM ld_rest_s.
        ENDIF.
      ELSE.
        IF ld_weight_h <> 0.
          distrib_tab-distr =
            ld_rest_h * distrib_tab-hwbas / ld_weight_h.
          SUBTRACT distrib_tab-hwbas FROM ld_weight_h.
          SUBTRACT distrib_tab-distr FROM ld_rest_h.
        ENDIF.
      ENDIF.
      MODIFY distrib_tab.
    ENDLOOP.


    LOOP AT distrib_tab.
      READ TABLE gt_bas
           INDEX distrib_tab-oldpos.
      CASE p_taxfield.
        WHEN '1'.
          gt_bas-hwaus  = distrib_tab-distr.
        WHEN '2'.
          gt_bas-hwvor  = distrib_tab-distr.
        WHEN '3'.
          gt_bas-hwanaf = distrib_tab-distr.
        WHEN '4'.
          gt_bas-hwvnaf = distrib_tab-distr.
      ENDCASE.
      MODIFY gt_bas
           INDEX distrib_tab-oldpos.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " distribute_amount               "984821
*&---------------------------------------------------------------------*
*&      Form  calculate_tax                                   "984821
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TOTBAS      text
*      -->P_MWSKZ       text
*      -->P_BKPF_BUKRS  text
*      -->P_T001_WAERS  text
*      <--PS_TAX        text
*----------------------------------------------------------------------*
FORM calculate_tax                                          "984821
     USING    p_totbas TYPE hwaerbas
              p_tax_country TYPE fot_tax_country
              p_mwskz TYPE mwskz
              p_txdat_from TYPE fot_txdat_from "TDT
              p_bkpf_bukrs TYPE bukrs
              p_t001_waers TYPE waers
     CHANGING ps_tax LIKE LINE OF gt_bas.

  DATA: ld_wrbtr TYPE wrbtr,
        ld_nvv   TYPE aflex18d2o25s, "AFLE enablement orig (9)type p,
        ls_taxes TYPE rtax1u15,
        lt_taxes TYPE TABLE OF rtax1u15,
        ld_mwart TYPE mwart.                                "1371996

  ld_wrbtr = p_totbas.
  CLEAR: ps_tax,
         ld_nvv.

  CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
    EXPORTING
      i_bukrs       = p_bkpf_bukrs
      i_mwskz       = p_mwskz
      i_waers       = p_t001_waers
      i_wrbtr       = ld_wrbtr
      i_prsdt       = p_txdat_from "TDT
      i_tax_country = p_tax_country
    TABLES
      t_mwdat       = lt_taxes
    EXCEPTIONS
      OTHERS        = 13.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  DATA(lv_kalsm) = COND #( WHEN flg_txa_active = abap_true
                  THEN cl_fot_common_dao=>agent->get_country_data(
                              p_tax_country )-kalsm
                ELSE tab_001-kalsm ).

  LOOP AT lt_taxes INTO ls_taxes.
    PERFORM read_t007b
            USING ls_taxes-ktosl.
    CHECK tab_007b-stbkz NE '1'.

    PERFORM read_t007a                                      "1371996
            USING lv_kalsm p_mwskz.                         "1371996
    IF tab_007b-stgrp = '2'.                                "1371996
      ld_mwart = 'V'.                                       "1371996
    ELSEIF tab_007b-stgrp = '1'.                            "1371996
      ld_mwart = 'A'.                                       "1371996
    ELSE.                                                   "1371996
      ld_mwart = tab_007a-mwart.                            "1371996
    ENDIF.                                                  "1371996

    IF tab_007b-stazf IS INITIAL.
*     IF tab_007b-stgrp = '2'.                              "1371996
      IF ld_mwart = 'V'.                                    "1371996
        ADD ls_taxes-wmwst TO ps_tax-hwvor.
      ELSE.
        ADD ls_taxes-wmwst TO ps_tax-hwaus.
      ENDIF.
    ELSEIF tab_007b-stbkz = 2.
*     IF tab_007b-stgrp = '2'.                              "1371996
      IF ld_mwart = 'V'.                                    "1371996
        ADD ls_taxes-wmwst TO ps_tax-hwvnaf.
      ELSE.
        ADD ls_taxes-wmwst TO ps_tax-hwanaf.
      ENDIF.
    ELSE.                           "NVV
      ADD ls_taxes-wmwst TO ld_nvv.
    ENDIF.

  ENDLOOP.

* If there is NVV-tax present it is included in the
* base amount we used. This must be corrected for.
  IF ld_nvv <> 0.
    ld_nvv        = abs( p_totbas + ld_nvv ).
    ld_wrbtr      = abs( p_totbas ).
    ps_tax-hwaus  = ps_tax-hwaus  * ld_wrbtr / ld_nvv.
    ps_tax-hwvor  = ps_tax-hwvor  * ld_wrbtr / ld_nvv.
    ps_tax-hwvnaf = ps_tax-hwvnaf * ld_wrbtr / ld_nvv.
    ps_tax-hwanaf = ps_tax-hwanaf * ld_wrbtr / ld_nvv.
  ENDIF.

ENDFORM.                    " calculate_tax                   "984821
*&---------------------------------------------------------------------*
*&      Form  distrib_tax_sh                                 "984821
*&---------------------------------------------------------------------*
*       Distribute the residual difference between posted tax p_tax
*       and calculated tax ( p_tax_s and p_tax_h ) according to
*       total base in debit ( p_totbas_s )and total base in credit
*       (p_totbas_h ).
*----------------------------------------------------------------------*
*      -->P_TOTBAS_S  text
*      -->P_TOTBAS_H  text
*      -->P_TAX       text
*      <--P_TAX_S     text
*      <--P_TAX_H     text
*----------------------------------------------------------------------*
FORM distrib_tax_sh                                         "984821
     USING    p_totbas_s TYPE hwaerbas
              p_totbas_h TYPE hwaerbas
              p_tax      TYPE hwste
     CHANGING p_tax_s    TYPE hwste
              p_tax_h    TYPE hwste.

  DATA: ld_diff TYPE aflex18d2o25s, "AFLE enablement original (9)type p,
        ld_bas  TYPE aflex18d2o25s. "AFLE enablement original (9)type p,

  ld_diff = p_tax - ( p_tax_s + p_tax_h ).
* ld_bas  = p_totbas_s + p_totbas_h.                        "1411664
  ld_bas  = p_totbas_s - p_totbas_h.                        "1411664
  IF ld_bas <> 0.
    ld_diff = ld_diff * p_totbas_s / ld_bas.
  ELSE.
    ld_diff = ld_diff / 2.
  ENDIF.

  p_tax_s = p_tax_s + ld_diff.
  p_tax_h = p_tax - p_tax_s.

ENDFORM.                    " distrib_tax_sh                 "984821
*&---------------------------------------------------------------------*
*&      Form  check_txgrp                                    "984821
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  eventually changes table gt_bas and gt_tax
*  may use bkpf, gt_bseg and gt_bset
*----------------------------------------------------------------------*
FORM check_txgrp.                                           "984821

  DATA ld_use_txgrp TYPE xfeld VALUE space.

* Field txgrp as currently defined is not useful here. So it is
* used in no case. Maybe in special cases it can be constructed
* from the document. So the logic for using txgrp is implemented.

* delete txgrp if it is not to be used
  IF ld_use_txgrp = space.
    LOOP AT gt_bas.
      CLEAR gt_bas-txgrp.
      MODIFY gt_bas.
    ENDLOOP.
    LOOP AT gt_tax.
      CLEAR gt_tax-txgrp.
      MODIFY gt_tax.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " check_txgrp                    "984821
*&---------------------------------------------------------------------*
*&      Form  purch_acc_process                              "984821
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM purch_acc_process.                                     "984821

  DATA: ld_tabix TYPE i.

  LOOP AT gt_bas.

    READ TABLE gt_bseg INTO bseg                            "984821
         WITH KEY bukrs = gt_bas-bukrs                      "984821
                  belnr = gt_bas-belnr                      "984821
                  gjahr = gt_bas-gjahr                      "984821
                  buzei = gt_bas-buzei.                     "984821
    IF sy-subrc = 0.                                        "984821
      ld_tabix = sy-tabix.                                  "984821

      CLEAR purch_acc_found.                                "843610
      IF bseg-matnr NE space.
        PERFORM link_mm.
      ENDIF.                                                "843610
*   ELSE.                                                  "843610
      IF purch_acc_found IS INITIAL.                        "843610
        IF bseg-ebeln NE space.
          PERFORM link2_mm.
        ENDIF.
      ENDIF.
      IF NOT purch_acc_found IS INITIAL.                    "843610
*       ep-hkont        = bseg-hkont.               "843610 "984821
*       tab_konto-hkont = bseg-hkont.               "843610 "984821
        gt_bas-hkont    = bseg-hkont.                       "984821
        MODIFY gt_bas                                       "984821
               TRANSPORTING hkont.                          "984821
        MODIFY gt_bseg FROM bseg                            "984821
               INDEX ld_tabix                               "984821
               TRANSPORTING hkont.                          "984821
      ENDIF.                                                "843610
      IF ( bseg-matnr NE space                              "843610
           OR bseg-ebeln NE space )                         "843610
         AND purch_acc_found IS INITIAL.                    "843610
* F7 271:                                                  "843610
* Einkaufskonto Beleg &1 Buchungskreis &2 nicht gefunden   "843610
        CLEAR fimsg.                                        "843610
        fimsg-msort = '0010'.                               "843610
        fimsg-msgid = 'F7'.                                 "843610
        fimsg-msgty = 'S'.                                  "843610
        fimsg-msgno = '271'.                                "843610
*       fimsg-msgv1 = bkpf-belnr.                   "843610 "1132306
*       fimsg-msgv2 = bkpf-bukrs.                   "843610 "1132306
        fimsg-msgv1 = bseg-belnr.                           "1132306
        fimsg-msgv2 = bseg-bukrs.                           "1132306
        fimsg-msgv3 = bseg-hkont.                           "843610
        CALL FUNCTION 'FI_MESSAGE_COLLECT'                  "843610
          EXPORTING                                      "843610
            i_fimsg = fimsg.                          "843610
      ENDIF.                                                "843610

    ENDIF.
  ENDLOOP.

ENDFORM.                    " purch_acc_process               "984821
*&---------------------------------------------------------------------*
*&      Form  replace_altkt                                   "984821
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM replace_altkt.                                         "984821

  DATA: ld_tabix TYPE i.

  LOOP AT gt_bas.

    READ TABLE gt_bseg INTO bseg                            "984821
         WITH KEY bukrs = gt_bas-bukrs                      "984821
                  belnr = gt_bas-belnr                      "984821
                  gjahr = gt_bas-gjahr                      "984821
                  buzei = gt_bas-buzei.                     "984821
    IF sy-subrc = 0.                                        "984821
      ld_tabix = sy-tabix.                                  "984821


*     tab_konto-bukrs = bkpf-bukrs.                         "1132306
      tab_konto-bukrs = bseg-bukrs.                         "1132306
      tab_konto-hkont = bseg-hkont.
      READ TABLE tab_konto WITH KEY tab_konto(14) BINARY SEARCH.
      IF sy-subrc NE 0.
        hlp_tabix = sy-tabix.
        IF par_altk NE space.
          CALL FUNCTION 'READ_SACHKONTO_ALTKT'
            EXPORTING
*             bukrs           = bkpf-bukrs                  "1132306
              bukrs           = bseg-bukrs                  "1132306
              saknr           = bseg-hkont
              xmass           = 'X'
              xskan           = 'X'
            IMPORTING
              altkt_not_found = hlp_error
              altkt_sakan     = tab_konto-sakan
            EXCEPTIONS
              saknr_not_found = 04.
          IF sy-subrc NE 0.
            CLEAR fimsg.
            fimsg-msort = '0001'.
            fimsg-msgid = 'FR'.
            fimsg-msgty = 'S'.
            fimsg-msgno = '322'.
            fimsg-msgv1 = bseg-hkont.
*           fimsg-msgv2 = bkpf-bukrs.                       "1132306
            fimsg-msgv2 = bseg-bukrs.                       "1132306
            CALL FUNCTION 'FI_MESSAGE_COLLECT'
              EXPORTING
                i_fimsg = fimsg.
          ENDIF.
          IF hlp_error NE space.
            CLEAR fimsg.
            fimsg-msort = '0002'.
            fimsg-msgid = 'FR'.
            fimsg-msgty = 'S'.
            fimsg-msgno = '319'.
            fimsg-msgv1 = bseg-hkont.
*           fimsg-msgv2 = bkpf-bukrs.                       "1132306
            fimsg-msgv2 = bseg-bukrs.                       "1132306
            CALL FUNCTION 'FI_MESSAGE_COLLECT'
              EXPORTING
                i_fimsg = fimsg.
          ENDIF.
        ELSE.
          CALL FUNCTION 'READ_SACHKONTO_ALTKT'
            EXPORTING
              altkt_i     = bseg-hkont
*             bukrs       = bkpf-bukrs                      "1132306
              bukrs       = bseg-bukrs                      "1132306
              saknr       = bseg-hkont
              xskan       = 'X'
            IMPORTING
              altkt_sakan = tab_konto-sakan.
        ENDIF.
        INSERT tab_konto INDEX hlp_tabix.
      ENDIF.

      bseg-hkont    = tab_konto-sakan.                      "984821
      gt_bas-hkont    = bseg-hkont.                         "984821
      MODIFY gt_bas                                         "984821
             TRANSPORTING hkont.                            "984821
      MODIFY gt_bseg FROM bseg                              "984821
             INDEX ld_tabix                                 "984821
             TRANSPORTING hkont.                            "984821

    ENDIF.
  ENDLOOP.

ENDFORM.                    " replace_altkt                   "984821
*&---------------------------------------------------------------------*
*&      Form  append_item                                    "984821
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_item.                                           "984821

  DATA: l_vat_item TYPE rfums_alv_vat,
        ls_totals  TYPE rfums_alv_total_vat.
  DATA lv_kalsm TYPE t005-kalsm.

  READ TABLE gt_master_table
             ASSIGNING <s_master_table>
             WITH KEY bukrs = bkpf-bukrs.
  IF sy-subrc <> 0.
* create a new entry in master_table for the current company code
    CLEAR gt_master_table.
    gt_master_table-bukrs = bkpf-bukrs.
    APPEND gt_master_table.
    READ TABLE gt_master_table
               ASSIGNING <s_master_table>
               INDEX sy-tabix.
  ENDIF.


  LOOP AT gt_bas.

* append single items lists
    MOVE-CORRESPONDING gt_bas TO l_vat_item.

*  If par_rbuv is active gt_bas can still contain belnr     "1132306
*  of the target company code. But we always show belnr     "1132306
*  of the current company code. I.e the document number     "1132306
*  in the target company code is discarded here. It can     "1132306
*  be found in FB03.                                        "1132306
*  Also fill current company code into traditional bukrs    "1132306
*  and target company code into new field ccbuk             "1132306
    l_vat_item-bukrs = bkpf-bukrs.                          "1132306
    l_vat_item-belnr = bkpf-belnr.                          "1132306
    l_vat_item-gjahr = bkpf-gjahr.                          "1132306
    l_vat_item-pbukr = gt_bas-bukrs.                        "1132306

    IF gt_bas-mwart = 'A' AND par_lis1 = 'X'.
      APPEND l_vat_item TO <s_master_table>-t_output_item.
    ELSEIF gt_bas-mwart = 'V' AND par_lis2 = 'X'.
      APPEND l_vat_item TO <s_master_table>-t_input_item.
    ENDIF.

* collect the 'new' totals lists (with taxes)
*  The following move is important if structures
*  are extended. If structures rfums_alv_vat and
*  rfums_alv_total_vat are extended by the same
*  fields, these values can be transferred to the
*  totals lists and are taken into account by the
*  table collect statement.
    MOVE-CORRESPONDING gt_bas TO ls_totals.
    ls_totals-bukrs = bkpf-bukrs.                           "1132306
    ls_totals-pbukr = gt_bas-bukrs.                         "1132306
    lv_kalsm = COND #( WHEN flg_txa_active = abap_true
                             THEN cl_fot_common_dao=>agent->get_country_data(
                                         gt_bas-tax_country )-kalsm
                           ELSE tab_001-kalsm ).
    PERFORM read_t007a
            USING lv_kalsm
                  gt_bas-mwskz.
    ls_totals-text1 = tab_007a-text1.
    COLLECT ls_totals INTO <s_master_table>-t_totals.

* collect the 'old' totals list (merged with bset_sum later)
*   ep_sum-bukrs = gt_bas-bukrs.                            "1132306
    ep_sum-bukrs = bkpf-bukrs.                              "1132306
    ep_sum-mwskz = gt_bas-mwskz.
    ep_sum-txdat_from = gt_bas-txdat_from. "TDT
    ep_sum-tax_country = gt_bas-tax_country.
    IF gt_bas-flg_dp = 'X'
       AND gt_bas-flg_dpg = 'X'.
* to check flg_dpg here seems wrong, but it had been this way
* for a long time now: only down payments gross are shown separately.
      ep_sum-umsks = 'A'.
    ELSE.
      ep_sum-umsks = space.
    ENDIF.
    ep_sum-dmbtr = gt_bas-hwbas.

*   COLLECT ep_sum.                                         "2526464
    LOOP AT bset_ktosl                                      "2526464
         WHERE tax_country = ep_sum-tax_country
           AND mwskz = ep_sum-mwskz                         "2526464
           AND txdat_from = ep_sum-txdat_from. "TDT
      ep_sum-ktosl = bset_ktosl-ktosl.                      "2526464
      COLLECT ep_sum.                                       "2526464
    ENDLOOP.                                                "2526464
    IF sy-subrc NE 0. "there was no bset for this mwskz     "2526464
      CLEAR ep_sum-ktosl.                                   "2526464
      COLLECT ep_sum.                                       "2526464
    ENDIF.                                                  "2526464

  ENDLOOP.

ENDFORM.                    " append_item                     "984821
*&---------------------------------------------------------------------*
*&      Form  create_fieldcat                                 "984821
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_STRUC_NAME  text
*----------------------------------------------------------------------*
FORM create_fieldcat                                        "984821
     USING    p_struc_name TYPE dd02l-tabname.

  DATA: ls_fieldcat       TYPE slis_fieldcat_alv,
        ld_col_pos_no_out TYPE i.

  CASE p_struc_name.
    WHEN c_struc_name_12.
      ASSIGN gt_fieldcat_12 TO <gt_fieldcat>.
    WHEN c_struc_name_3.
      ASSIGN gt_fieldcat_3  TO <gt_fieldcat>.
    WHEN c_struc_name_4.
      ASSIGN gt_fieldcat_4  TO <gt_fieldcat>.
    WHEN c_struc_name_5.
      ASSIGN gt_fieldcat_5  TO <gt_fieldcat>.
  ENDCASE.

  REFRESH <gt_fieldcat>.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = p_struc_name
    CHANGING
      ct_fieldcat      = <gt_fieldcat>
    EXCEPTIONS
      OTHERS           = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* modifications to retain 'old' default layouts, and apply
* some special settings for the new totals list.
  ld_col_pos_no_out = 99.
  CASE p_struc_name.
    WHEN c_struc_name_12.
*     ld_col_pos_no_out = 12. "include up to MLDWAER        "2933377
*     ld_col_pos_no_out = 13. "+TDT                         "2933377
      ld_col_pos_no_out = 14. "+RITA                        "2933377
    WHEN c_struc_name_3.
*     ld_col_pos_no_out = 10. "include up to MLDWAER        "2933377
*     ld_col_pos_no_out = 11. "+TDT                         "2933377
      ld_col_pos_no_out = 12. "+RITA                        "2933377
    WHEN c_struc_name_4.
*     ld_col_pos_no_out = 10. "include up to MLDWAER        "2933377
*     ld_col_pos_no_out = 11. "+TDT                         "2933377
      ld_col_pos_no_out = 12. "+RITA                        "2933377
    WHEN c_struc_name_5.
*     ld_col_pos_no_out = 12. "include up to MLDWAER        "2933377
*     ld_col_pos_no_out = 13. "+TDT                         "2933377
      ld_col_pos_no_out = 14. "+RITA                        "2933377
  ENDCASE.
  LOOP AT <gt_fieldcat> INTO ls_fieldcat.
    IF ls_fieldcat-col_pos >= ld_col_pos_no_out.
      ls_fieldcat-no_out = 'X'.
    ENDIF.
    IF p_struc_name = c_struc_name_5.
      IF    ls_fieldcat-fieldname = 'TEXT1 '
         OR ls_fieldcat-fieldname = 'HWANAF '
         OR ls_fieldcat-fieldname = 'HWVNAF '. "TDT
        ls_fieldcat-no_out = 'X'.
      ENDIF.
    ENDIF.

    IF ls_fieldcat-fieldname = 'TXDAT_FROM '. "TDT
      ls_fieldcat-no_out = 'X'.  "TDT
    ENDIF. "TDT

    IF ls_fieldcat-fieldname = 'TAX_COUNTRY '. "RITA
      ls_fieldcat-no_out = 'X'.                "RITA
    ENDIF.

    IF p_struc_name = c_struc_name_12.                      "2260949
      IF    ls_fieldcat-fieldname = 'MWART '.               "2260949
        ls_fieldcat-no_out = 'X'.                           "2260949
        ls_fieldcat-tech   = 'X'.                           "2260949
      ENDIF.                                                "2260949
    ENDIF.                                                  "2260949
    MODIFY <gt_fieldcat> FROM ls_fieldcat.
  ENDLOOP.

* BAdI to modify fieldcat for customer-specific columns     "2260949
  IF NOT g_badi_01 IS INITIAL                               "2260949
     AND ( p_struc_name = c_struc_name_12                   "2260949
        OR p_struc_name = c_struc_name_5 ).                 "2260949

    CALL BADI g_badi_01->modify_fieldcat                    "2260949
      EXPORTING                                             "2260949
        i_struc_name    = p_struc_name                      "2260949
      CHANGING                                              "2260949
        ch_tab_fieldcat = <gt_fieldcat>.                    "2260949

  ENDIF.                                                    "2260949


ENDFORM.                    " create_fieldcat                 "984821
*&---------------------------------------------------------------------*
*&      Form  read_skb1                                     "984821
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS  text
*      -->P_SAKNR  text
*      <--P_SKB1   text
*----------------------------------------------------------------------*
FORM read_skb1                                              "984821
     USING    p_bukrs TYPE bukrs
              p_saknr TYPE saknr
     CHANGING p_skb1 TYPE skb1.

  CALL FUNCTION 'SKB1_SINGLE_READ'
    EXPORTING
      i_bukrs   = p_bukrs
      i_saknr   = p_saknr
    IMPORTING
      o_skb1    = p_skb1
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

  IF sy-subrc <> 0.
    CLEAR p_skb1.
    CLEAR fimsg.
    fimsg-msort = '0020'.
    fimsg-msgid = sy-msgid.
    fimsg-msgty = sy-msgty.
    fimsg-msgno = sy-msgno.
    fimsg-msgv1 = sy-msgv1.
    fimsg-msgv2 = sy-msgv2.
    fimsg-msgv3 = sy-msgv3.
    fimsg-msgv4 = sy-msgv4.
    CALL FUNCTION 'FI_MESSAGE_COLLECT'
      EXPORTING
        i_fimsg = fimsg.
  ENDIF.

ENDFORM.                    " read_skb1                     "984821
*&---------------------------------------------------------------------*
*&      Form  REPLACE_BUV                                   "1132306
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM replace_buv.                                           "1132306

  DATA: BEGIN OF lt_buv OCCURS 2,
          bukrs TYPE bukrs,
          belnr TYPE belnr_d,
          gjahr TYPE gjahr,
          hwaer TYPE hwaer,
        END OF lt_buv.
  DATA: lt_bvor TYPE TABLE OF bvor
                WITH HEADER LINE,
        lt_bseg TYPE TABLE OF bseg
                WITH HEADER LINE,
        ls_bseg TYPE bseg.
  DATA: ls_bkpf_rev TYPE bkpf.                              "1608035

  IF bkpf-bvorg NE space.                                   "1608035
    SELECT * FROM bvor INTO TABLE lt_bvor
             WHERE bvorg =  bkpf-bvorg
               AND bukrs <> bkpf-bukrs.
  ELSE.                                                     "1608035
*  reversal transaction                                     "1608035
*  Reversals created by FBU8 do not contain a               "1608035
*  BVOR (nor a BVORG-entry). So we take the data            "1608035
*  from the original document and reverse signs.            "1608035
    SELECT SINGLE * FROM bkpf INTO ls_bkpf_rev              "1608035
           WHERE bukrs = bkpf-bukrs                         "1608035
             AND belnr = bkpf-stblg                         "1608035
             AND gjahr = bkpf-stjah.                        "1608035
    IF sy-subrc = 0                                         "1608035
       AND ls_bkpf_rev-bvorg NE space.                      "1608035
      SELECT * FROM bvor INTO TABLE lt_bvor                 "1608035
               WHERE bvorg =  ls_bkpf_rev-bvorg             "1608035
                 AND bukrs <> bkpf-bukrs.                   "1608035
    ENDIF.                                                  "1608035
  ENDIF.                                                    "1608035

  CHECK NOT lt_bvor[] IS INITIAL.                           "1608035

  SELECT bukrs belnr gjahr hwaer
         FROM bkpf
         INTO TABLE lt_buv
         FOR ALL ENTRIES IN lt_bvor
         WHERE bukrs = lt_bvor-bukrs
           AND belnr = lt_bvor-belnr
           AND gjahr = lt_bvor-gjahr.

* ensure consistent tax distribution results                "1845112
  SORT lt_buv BY bukrs belnr gjahr.                         "1845112

  DELETE gt_bseg
         WHERE ktosl = 'BUV'.

  LOOP AT lt_buv.
    SELECT * FROM bseg INTO TABLE lt_bseg
             WHERE bukrs = lt_buv-bukrs
               AND belnr = lt_buv-belnr
               AND gjahr = lt_buv-gjahr
               AND mwskz NE space
               AND mwart EQ space
               AND ktosl NE 'BUV'
             ORDER BY PRIMARY KEY.                          "1845112
    LOOP AT lt_bseg INTO ls_bseg.
      IF ls_bseg-koart CA 'SAM'
         AND ls_bseg-stbuk = bkpf-bukrs.
* Exclude items for which tax is not transferred to         "1703988
* the leading company code:                                 "1703988
* - tax recon for down payment gross                        "1703988
* - automatic cash discount                                 "1703988
* - (direct tax posting is already excluded)                "1703988
        IF ls_bseg-ktosl EQ 'MVA' OR                        "1703988
           ls_bseg-ktosl EQ 'VVA' OR                        "1703988
           ls_bseg-ktosl EQ 'SKT' OR                        "1703988
           ls_bseg-ktosl EQ 'SKE' OR                        "1703988
           ls_bseg-ktosl EQ 'VSK' OR                        "1703988
           ( ls_bseg-ktosl EQ 'SKV' AND                     "1703988
             bkpf-xnetb NE 'X' ).                           "1703988
          CONTINUE.                                         "1703988
        ENDIF.                                              "1703988
* convert amounts to alternative local currency
        IF NOT alcur IS INITIAL.
          PERFORM convert_to_alt_curr
                  USING    bkpf-bukrs
                           lt_buv-hwaer
                           bkpf-waers
                  CHANGING ls_bseg.
        ELSEIF lt_buv-hwaer <> bkpf-hwaer.                  "2929088
          PERFORM convert_to_lead_hwaer                     "2929088
            CHANGING ls_bseg.
        ENDIF.
        IF bkpf-bvorg EQ space.                             "1608035
*        reversal transaction: change signs                 "1608035
          TRANSLATE ls_bseg-shkzg USING 'SHHS'.             "1608035
        ENDIF.                                              "1608035
        APPEND ls_bseg TO gt_bseg.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " REPLACE_BUV                   "1132306
*&---------------------------------------------------------------------*
*&      Form  CONVERT_TO_LEAD_HWAER
*&---------------------------------------------------------------------*
*       Conversion with rate, like fallback in CREATE_BSET_ITEM
*----------------------------------------------------------------------*
FORM convert_to_lead_hwaer CHANGING cs_bseg STRUCTURE bseg. "2929088

  DATA: l_kurst LIKE t003-kurst VALUE 'M',
        ls_t003 LIKE t003.

* KURST like in SAPLTAX1 FORM determine_type_of_rate
  IF bkpf-kurst IS INITIAL.
    IF bkpf-tcode(1) <> 'M' AND bkpf-awtyp <> 'RMRP'.
      CALL FUNCTION 'FI_DOCUMENT_TYPE_DATA'
        EXPORTING
          i_blart = bkpf-blart
        IMPORTING
          e_t003  = ls_t003.
      IF NOT ls_t003-kurst IS INITIAL.
        l_kurst = ls_t003-kurst.
      ENDIF.
    ENDIF.
  ELSE.
    l_kurst = bkpf-kurst.
  ENDIF.

  PERFORM convert_to_lead_hwaer1 USING cs_bseg-wrbtr l_kurst
                                 CHANGING cs_bseg-dmbtr.

  PERFORM convert_to_lead_hwaer1 USING cs_bseg-wmwst l_kurst
                                 CHANGING cs_bseg-mwsts.

  PERFORM convert_to_lead_hwaer1 USING cs_bseg-fwbas l_kurst
                                 CHANGING cs_bseg-hwbas.

ENDFORM.                    "CONVERT_TO_LEAD_HWAER "2929088
*&---------------------------------------------------------------------*
*&      Form  CONVERT_TO_LEAD_HWAER1
*&---------------------------------------------------------------------*
FORM convert_to_lead_hwaer1  USING    p_wrbtr               "2929088
                                      p_kurst
                             CHANGING c_dmbtr.

  CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
    EXPORTING
      local_currency   = bkpf-hwaer
      foreign_currency = bkpf-waers
      foreign_amount   = p_wrbtr
      date             = bkpf-wwert
      rate             = bkpf-kursf
      type_of_rate     = p_kurst
    IMPORTING
      local_amount     = c_dmbtr.

ENDFORM.                    " CONVERT_TO_LEAD_HWAER1 "2929088
*&---------------------------------------------------------------------*
*&      Form  CONVERT_TO_ALT_CURR                           "1132306
*&---------------------------------------------------------------------*
*       Do conversion to alternative local currency in exactly the
*       same way as logical database BRF does it.
*----------------------------------------------------------------------*
*      -->ID_BUKRS  leading company code
*      -->ID_HWAER  local currency of posting company code
*      -->ID_WAERS  document currency
*      <--CS_BSEG  text
*----------------------------------------------------------------------*
FORM convert_to_alt_curr                                    "1132306
     USING    id_bukrs TYPE bukrs
              id_hwaer TYPE waers
              id_waers TYPE waers
     CHANGING cs_bseg TYPE bseg.

  STATICS: st_teurb TYPE TABLE OF teurb WITH HEADER LINE.

  READ TABLE st_teurb
       WITH KEY bukrs = id_bukrs.
  IF sy-subrc <> 0.
    SELECT SINGLE * FROM teurb INTO st_teurb
                    WHERE bukrs = id_bukrs
                      AND cprog = sy-cprog
                      AND land1 = space.
    IF sy-subrc <> 0.
      CLEAR st_teurb.
      st_teurb-bukrs = id_bukrs.
    ENDIF.
    APPEND st_teurb.
  ENDIF.


  IF st_teurb-waers NE id_hwaer.
    IF st_teurb-waers EQ id_waers.
      cs_bseg-dmbtr = cs_bseg-wrbtr.
      cs_bseg-mwsts = cs_bseg-wmwst.
      cs_bseg-hwbas = cs_bseg-fwbas.
    ELSE.
      PERFORM convert_currency_val
              USING     id_hwaer
                        st_teurb-waers
                        st_teurb-kurst
                        excdt
              CHANGING:
                        cs_bseg-dmbtr,
                        cs_bseg-mwsts,
                        cs_bseg-hwbas.
    ENDIF.
  ENDIF.

ENDFORM.                    " CONVERT_TO_ALT_CURR           "1132306


*&---------------------------------------------------------------------*
*&      Form  CONVERT_CURRENCY_VAL                          "1132306
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ID_HWAER  text
*      -->ID_WAERS  text
*      -->ID_KURST  text
*      -->ID_EXCDT  text
*      <--CD_DMBTR  text
*----------------------------------------------------------------------*
FORM convert_currency_val                                   "1132306
     USING    id_hwaer TYPE waers
              id_waers TYPE waers
              id_kurst TYPE kurst
              id_excdt TYPE wwert_d
     CHANGING cd_dmbtr.

  DATA ld_dmbtr TYPE dmbtr.

  CHECK cd_dmbtr NE 0.

  CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
    EXPORTING
      date             = id_excdt
      foreign_currency = id_waers
      local_amount     = cd_dmbtr
      local_currency   = id_hwaer
      type_of_rate     = id_kurst
    IMPORTING
      foreign_amount   = ld_dmbtr.

  cd_dmbtr = ld_dmbtr.

ENDFORM.                    " CONVERT_CURRENCY_VAL          "1132306
*&---------------------------------------------------------------------*
*&      Form  ADD_BSEG_FROM_SPLIT_DOC                       "1464213
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IS_BKPF  header of currently processed dcoument
*      <-> gt_bseg  appends entries to global table gt_bseg
*----------------------------------------------------------------------*
FORM add_bseg_from_split_doc                                "1464213
     USING    is_bkpf TYPE bkpf.

  DATA: ls_bkpf TYPE bkpf,
        lt_bkpf TYPE TABLE OF bkpf,
        ls_bseg TYPE bseg,
        lt_bseg TYPE TABLE OF bseg.
  DATA: dum_lo TYPE awkey,                                  "2090841
        dum_hi TYPE awkey.                                  "2090841

  DATA: lv_join TYPE string.

* Any further processing can only be relevant when          "2621255
* there are items with tax code in the current document.    "2621255
  LOOP AT gt_bseg TRANSPORTING NO FIELDS                    "2621255
       WHERE ( mwskz <> space AND                           "2621255
               mwskz IN sel_mwkz )                          "2621255
          OR ktosl = 'BUV'.                                 "2621255
    EXIT.                                                   "2621255
  ENDLOOP.                                                  "2621255
  CHECK sy-subrc = 0.                                       "2621255

* IF xhana = 'E'.                                           "2158177                 "3291400
*  IF gd_via_ldb = abap_false.                               "2158177                "3291400
*                                                                                    "3291400
*    IF is_bkpf-glvor = 'HRP1' OR                                                    "3291400
*       is_bkpf-glvor = 'RFT1' AND                                                   "3291400
*       is_bkpf-awtyp <> 'CTE'.                              "3129278                "3291400
*                                                                                    "3291400
*      CONCATENATE  'BKPF INNER JOIN BSEG ON BKPF~BUKRS = BSEG~BUKRS AND'  ##no_text "3291400
*         ' BKPF~BELNR = BSEG~BELNR AND BKPF~GJAHR = BSEG~GJAHR'   ##no_text         "3291400
*       INTO lv_join SEPARATED BY space.                                             "3291400
*                                                                                    "3291400
*      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_bseg FROM (lv_join)            "3291400
*             WHERE bkpf~awtyp =  is_bkpf-awtyp                                      "3291400
*                 AND bkpf~awkey =  is_bkpf-awkey                                    "3291400
*                 AND bkpf~awsys =  is_bkpf-awsys                                    "3291400
*                 AND bkpf~bukrs =  is_bkpf-bukrs                                    "3291400
*                 AND bkpf~gjahr =  is_bkpf-gjahr                                    "3291400
*                 AND bkpf~belnr <> is_bkpf-belnr.                                   "3291400
*                                                                                    "3291400
**** ENDIF.                                                  "2339735                "3291400
*      CHECK NOT lt_bseg[] IS INITIAL.                                               "3291400
*                                                                                    "3291400
*    ENDIF.  "GLVOR                                          "2339735                "3291400
*                                                                                    "3291400
*  ELSE.                                                                             "3291400
* check for splitting of HR-documents (HRPAY)
  IF is_bkpf-glvor = 'HRP1' OR
     is_bkpf-glvor = 'RFT1' AND
     is_bkpf-awtyp <> 'CTE'.                                "3129278
    SELECT * FROM bkpf INTO TABLE lt_bkpf
           WHERE awtyp =  is_bkpf-awtyp
             AND awkey =  is_bkpf-awkey
             AND awsys =  is_bkpf-awsys
             AND bukrs =  is_bkpf-bukrs
             AND gjahr =  is_bkpf-gjahr
             AND belnr <> is_bkpf-belnr.
*** ENDIF.                                                  "2339735

    CHECK NOT lt_bkpf[] IS INITIAL.

    SELECT * FROM bseg INTO TABLE lt_bseg
             FOR ALL ENTRIES IN lt_bkpf
             WHERE bukrs = lt_bkpf-bukrs
               AND belnr = lt_bkpf-belnr
               AND gjahr = lt_bkpf-gjahr
               AND ( mwskz NE space OR                      "2621255
                     ktosl EQ 'BUV' OR                      "2621255
                     ktosl EQ 'SPL' ).                      "2621255


  ENDIF.  "GLVOR                                          "2339735

*  ENDIF.                                                                            "3291400


* Check for splitting of FI-CA-documents (FKKSU):           "2090841
* FI-CA can create several documents per reconciliation key."2090841
* There is no safe way to recognize what belongs to one     "2090841
* splitted FI document. Processing a splitted document plus "2090841
* (for ex.) its reversal will still lead to a meaningful    "2090841
* tax re-distribution result.                               "2090841
  IF is_bkpf-awtyp = 'FKKSU'                                "2090841
    AND is_bkpf-awkey+13(7) CO '0123456789'.                "2621255

    dum_lo       = is_bkpf-awkey.                           "2090841
    dum_lo+13(7) = '0000001'.                               "2090841
    dum_hi       = is_bkpf-awkey.                           "2090841
    dum_hi+13(7) = '9999999'.                               "2090841

*   Get all documents that belong to the recon. key.        "2090841
    SELECT * FROM bkpf INTO TABLE lt_bkpf                   "2090841
           WHERE awtyp = is_bkpf-awtyp                      "2090841
             AND awkey BETWEEN dum_lo AND dum_hi.           "2090841

*   Try to remove all recognizeable other documents         "2090841
*   (thereby remove the current document from the list).    "2090841
    LOOP AT lt_bkpf INTO ls_bkpf.                           "2090841
      IF ls_bkpf-belnr =  is_bkpf-belnr OR                  "2090841
         ls_bkpf-awsys <> is_bkpf-awsys OR                  "2090841
         ls_bkpf-bukrs <> is_bkpf-bukrs OR                  "2090841
         ls_bkpf-gjahr <> is_bkpf-gjahr OR                  "2090841
         ls_bkpf-budat <> is_bkpf-budat OR                  "2090841
         ls_bkpf-bldat <> is_bkpf-bldat.                    "2090841
        DELETE lt_bkpf.                                     "2090841
      ENDIF.                                                "2090841
    ENDLOOP.                                                "2090841

    CHECK NOT lt_bkpf[] IS INITIAL.                         "2090841

    SELECT * FROM bseg INTO TABLE lt_bseg                   "2090841
             FOR ALL ENTRIES IN lt_bkpf                     "2090841
             WHERE bukrs = lt_bkpf-bukrs                    "2090841
               AND belnr = lt_bkpf-belnr                    "2090841
               AND gjahr = lt_bkpf-gjahr                    "2090841
               AND ( mwskz NE space OR                      "2621255
                     ktosl EQ 'BUV' OR                      "2621255
                     ktosl EQ 'SPL' ).                      "2621255

* Check for occurences of KTOSL 'SPL' in FI-CA documents.   "2090841
* If there is no such line we assume that this is           "2090841
* not a splitted document.                                  "2090841
    LOOP AT gt_bseg TRANSPORTING NO FIELDS                  "2090841
         WHERE ktosl = 'SPL'.                               "2090841
    ENDLOOP.                                                "2090841
    IF sy-subrc <> 0.                                       "2090841
      LOOP AT lt_bseg TRANSPORTING NO FIELDS                "2090841
           WHERE ktosl = 'SPL'.                             "2090841
      ENDLOOP.                                              "2090841
      IF sy-subrc <> 0.                                     "2090841
        RETURN.                                             "2090841
      ENDIF.                                                "2090841
    ENDIF.                                                  "2090841

  ENDIF.     "FKKSU                                         "2090841


  CHECK NOT lt_bseg[] IS INITIAL.                           "2339735

  LOOP AT lt_bseg INTO ls_bseg.

* convert amounts to alternative local currency
    IF NOT alcur IS INITIAL.
      PERFORM convert_to_alt_curr
              USING    is_bkpf-bukrs
                       is_bkpf-hwaer
                       is_bkpf-waers
              CHANGING ls_bseg.
    ENDIF.

*   ls_bseg-belnr = 'SPLIT'.                                "1845112
    ls_bseg-augbl = 'SPLIT'.                                "1845112

    MODIFY lt_bseg FROM ls_bseg.

  ENDLOOP.


  APPEND LINES OF lt_bseg TO gt_bseg.

* assure equal sort order for consistent tax distribution   "1845112
  SORT gt_bseg                                              "1845112
       BY bukrs belnr gjahr buzei.                          "1845112

ENDFORM.                    " ADD_BSEG_FROM_SPLIT_DOC       "1464213
*&---------------------------------------------------------------------*
*&      Form  REMOVE_BSEG_FROM_SPLIT_DOC                    "1464213
*&---------------------------------------------------------------------*
*       text
*      <-> gt_bas  deletes entries from global table gt_bas
*----------------------------------------------------------------------*
FORM remove_bseg_from_split_doc.                            "1464213

  DELETE gt_bas
         WHERE flg_split EQ 'X'.                            "1845112
*        WHERE belnr EQ 'SPLIT'.                            "1845112

ENDFORM.                    " REMOVE_BSEG_FROM_SPLIT_DOC    "1464213
*&---------------------------------------------------------------------*
*&      Form  calculate_tax_big                             "1532387
*&---------------------------------------------------------------------*
*       Workround solution for very large tax base amounts.
*       The tax base is split into
*         a devided smaller value and
*         and the residual amount.
*       Tax amount are then re-combined from results.
*       We still get dumps if the resulting tax does not fit
*       into CURR 13.
*----------------------------------------------------------------------*
*      -->P_TOTBAS      text
*      -->P_MWSKZ       text
*      -->P_BKPF_BUKRS  text
*      -->P_T001_WAERS  text
*      <--PS_TAX        text
*----------------------------------------------------------------------*
FORM calculate_tax_big                                      "1532387
     USING    p_totbas TYPE hwaerbas
              p_tax_country TYPE fot_tax_country
              p_mwskz TYPE mwskz
              p_txdat_from TYPE fot_txdat_from "TDT
              p_bkpf_bukrs TYPE bukrs
              p_t001_waers TYPE waers
     CHANGING ps_tax LIKE LINE OF gt_bas.

  DATA: ls_tax_bg    LIKE LINE OF gt_bas,
        ls_tax_sm    LIKE LINE OF gt_bas,
        ld_totbas_bg TYPE hwaerbas,
        ld_totbas_sm TYPE hwaerbas.

  CONSTANTS: lc_factor(9) TYPE p VALUE '10000',
             lc_facnul(9) TYPE p VALUE '100000'.
* lc_factor reduces the big base amount.
* lc_facnul ensures that the reduced base ends with
*           many zeroes to avoid rounding differences.

  CLEAR ps_tax.
  ld_totbas_bg = p_totbas / ( lc_facnul * lc_factor ).
  ld_totbas_bg = ld_totbas_bg * lc_facnul.
  ld_totbas_sm = p_totbas - ( ld_totbas_bg * lc_factor ).

  PERFORM calculate_tax
          USING    ld_totbas_bg
                   p_tax_country
                   p_mwskz
                   p_txdat_from "TDT
                   p_bkpf_bukrs
                   p_t001_waers
          CHANGING ls_tax_bg.

  IF ld_totbas_sm NE 0.
    PERFORM calculate_tax
            USING    ld_totbas_sm
                     p_tax_country
                     p_mwskz
                     p_txdat_from "TDT
                     p_bkpf_bukrs
                     p_t001_waers
            CHANGING ls_tax_sm.
  ENDIF.

  ps_tax-hwaus  = ls_tax_bg-hwaus  * lc_factor + ls_tax_sm-hwaus.
  ps_tax-hwvor  = ls_tax_bg-hwvor  * lc_factor + ls_tax_sm-hwvor.
  ps_tax-hwvnaf = ls_tax_bg-hwvnaf * lc_factor + ls_tax_sm-hwvnaf.
  ps_tax-hwanaf = ls_tax_bg-hwanaf * lc_factor + ls_tax_sm-hwanaf.

ENDFORM.                    " calculate_tax_big             "1532387


*----------------------------------------------------------------------*
* FORM CHECK_BSET_SUM                                       "1761953
*----------------------------------------------------------------------*
* Create dummy entries in tab_bset_sum for cases where BSET is missing.                                                      *
*----------------------------------------------------------------------*
FORM check_bset_sum.                                        "1761953

  DATA: ld_wrbtr TYPE wrbtr VALUE '1000000',
        ls_taxes TYPE rtax1u15,
        lt_taxes TYPE TABLE OF rtax1u15,
        ld_mwart TYPE mwart.

* check if there are already entries with the current tax code
  READ TABLE tab_bset_sum
       TRANSPORTING NO FIELDS
       WITH KEY bukrs = ep_sum-bukrs
                mwart = 'V'
                tax_country = ep_sum-tax_country
                mwskz = ep_sum-mwskz
                txdat_from = ep_sum-txdat_from "TDT
       BINARY SEARCH.
  CHECK sy-subrc <> 0.

  READ TABLE tab_bset_sum
       TRANSPORTING NO FIELDS
       WITH KEY bukrs = ep_sum-bukrs
                mwart = 'A'
                tax_country = ep_sum-tax_country
                mwskz = ep_sum-mwskz
                txdat_from = ep_sum-txdat_from "TDT
       BINARY SEARCH.
  CHECK sy-subrc <> 0.

* if not, create dummy bset entries
  IF ep_sum-mwskz NE space.

    CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
      EXPORTING
        i_bukrs       = ep_sum-bukrs
        i_mwskz       = ep_sum-mwskz
        i_waers       = tab_001-waers
        i_wrbtr       = ld_wrbtr
        i_prsdt       = ep_sum-txdat_from "TDT
        i_tax_country = ep_sum-tax_country
      TABLES
        t_mwdat       = lt_taxes
      EXCEPTIONS
        OTHERS        = 13.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CLEAR tab_bset_sum.
    tab_bset_sum-bukrs = ep_sum-bukrs.
    tab_bset_sum-mwskz = ep_sum-mwskz.
    tab_bset_sum-txdat_from = ep_sum-txdat_from. "TDT
    tab_bset_sum-tax_country = ep_sum-tax_country.

    DATA(lv_kalsm) = COND #( WHEN flg_txa_active = abap_true
                THEN cl_fot_common_dao=>agent->get_country_data(
                            ep_sum-tax_country )-kalsm
              ELSE tab_001-kalsm ).

    LOOP AT lt_taxes INTO ls_taxes
         WHERE kawrt <> 0.

      PERFORM read_t007b
            USING ls_taxes-ktosl.

      IF tab_007b-stgrp EQ 4.
        CHECK tab_007b-stbkz EQ 3.
      ENDIF.

      IF tab_007b-stgrp = '2'.
        ld_mwart = 'V'.
      ELSEIF tab_007b-stgrp = '1'.
        ld_mwart = 'A'.
      ELSE.
        PERFORM read_t007a
                USING lv_kalsm ep_sum-mwskz.
        ld_mwart = tab_007a-mwart.
      ENDIF.

      IF ( par_xsau IS INITIAL ).
        CHECK ld_mwart <> 'A'.
      ENDIF.
      IF ( par_xsvo IS INITIAL ).
        CHECK ld_mwart <> 'V'.
      ENDIF.

      tab_bset_sum-mwart = ld_mwart.
      tab_bset_sum-ktosl = ls_taxes-ktosl.
      tab_bset_sum-stgrp = tab_007b-stgrp.
      tab_bset_sum-stbkz = tab_007b-stbkz.

      COLLECT tab_bset_sum.

    ENDLOOP.

    SORT tab_bset_sum.

  ENDIF.

ENDFORM.                    "check_bset_sum                 "1761953
*---------------------------------------------------------------------*
*       FORM check_ledger_authority                         "N1762388 *
*---------------------------------------------------------------------*
*       Check authority for leading ledger                            *
*---------------------------------------------------------------------*
FORM check_ledger_authority                                 "N1762388
     USING      p_flg_umkrs  TYPE numc1.

  DATA:
    ld_glflex_active TYPE boole_d,
    ld_glflex_act_cc TYPE boole_d,
    ld_lead_rldnr    TYPE rldnr,
    ld_chk_bukrs     TYPE bukrs.


  CALL FUNCTION 'FAGL_CHECK_GLFLEX_ACTIVE'
    IMPORTING
      e_glflex_active = ld_glflex_active
    EXCEPTIONS
      error_in_setup  = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF ld_glflex_active IS INITIAL.
    CALL FUNCTION 'FAGL_BUKRS_ACTIVE_IN_CLIENT'
      IMPORTING
        e_glflex_active = ld_glflex_active.
  ENDIF.

  CHECK NOT ld_glflex_active IS INITIAL.

  CALL FUNCTION 'FAGL_GET_LEADING_LEDGER'
    IMPORTING
      e_rldnr   = ld_lead_rldnr
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  IF p_flg_umkrs = 0.
    SELECT bukrs FROM t001 INTO ld_chk_bukrs
           WHERE bukrs IN br_bukrs.

      CALL FUNCTION 'FAGL_AUTHORITY_LEDGER'
        EXPORTING
          i_bukrs = ld_chk_bukrs
          i_rldnr = ld_lead_rldnr
          i_actvt = '03'.

    ENDSELECT.
  ENDIF.

  IF p_flg_umkrs = 1.
    SELECT * FROM t007f
           WHERE umkrs IN sel_ukrs.
      SELECT bukrs FROM t001 INTO ld_chk_bukrs
             WHERE umkrs = t007f-umkrs.

        CALL FUNCTION 'FAGL_AUTHORITY_LEDGER'
          EXPORTING
            i_bukrs = ld_chk_bukrs
            i_rldnr = ld_lead_rldnr
            i_actvt = '03'.

      ENDSELECT.
    ENDSELECT.
  ENDIF.
*
  IF p_flg_umkrs = 2.
    LOOP AT lt_all_bukrs INTO ls_selected_bukrs.

      CALL FUNCTION 'FAGL_AUTHORITY_LEDGER'
        EXPORTING
          i_bukrs = ls_selected_bukrs-bukrs
          i_rldnr = ld_lead_rldnr
          i_actvt = '03'.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " check_ledger_authority        "N1762388


*
*&---------------------------------------------------------------------*
*&      Form  process_bkpf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM process_bkpf CHANGING lv_failed_bkpf.

* lv_failed_bkpf: true = reject, do not process document    "2294676
  lv_failed_bkpf = abap_true.                               "2294676

*  IF xhana <> 'E'.                                         "2158177
  CHECK:
  sel_mona,
  sel_bldt.
*  ENDIF.                                                   "2158177

* Select only normal documents. This is already done by      "971353
* LDB BRF but that check can fail when reading from archive. "971353
  CHECK bkpf-bstat EQ space.                                "971353

* Prüfen Umsatzsteuerkreis Zeitabh. durchführen              "N1542782
  IF flg_umkrs = '2'.                                       "N1542782
    CALL FUNCTION 'TAX_UMKRS_DETERMINE'                     "N1542782
      EXPORTING                                             "N1542782
        i_bkpf  = bkpf                                "N1542782
      IMPORTING                                             "N1542782
        e_umkrs = gd_umkrs.                           "N1542782
*   Weiterverarb. nur, wenn der UMKRS bestimmt werden konnte "N1542782
    CHECK gd_umkrs IS NOT INITIAL.                          "2294676
*    IF gd_umkrs IS NOT INITIAL.                            "2294676
*      lv_check = abap_false.                               "2294676
*      RETURN.                                              "2294676
*    ENDIF.                                                 "2294676
  ENDIF.                                                    "N1542782

* survived all checks:                                      "2294676
* lv_failed_bkpf: false = bkpf o.k, continue processing     "2294676
  lv_failed_bkpf = abap_false.                              "2294676


  PERFORM read_t001 USING bkpf-bukrs.

  PERFORM time_restriction_check CHANGING lv_failed_bkpf.
  IF lv_failed_bkpf = abap_true.
    RETURN.
  ENDIF.

*  IF sy-batch <> space                           "1066663  "2158177
* AND gd_selection_stopped <> space.              "1066663  "2158177
*    MESSAGE a273                                 "1066663  "2158177
*      WITH bkpf-bukrs bkpf-belnr bkpf-gjahr.     "1066663  "2158177
*  ENDIF.                                         "1066663  "2158177


*  CLEAR ep.                                                "984821
*  ep-bukrs    = bkpf-bukrs.                                "984821
*  ep-buper(4) = bkpf-gjahr.                                "984821
*  ep-buper+4  = bkpf-monat.                                "984821
*  ep-budat    = bkpf-budat.                                "984821
*  ep-belnr    = bkpf-belnr.                                "984821
*  ep-xblnr    = bkpf-xblnr.                                "984821

  REFRESH: gt_bseg,                                         "984821
           gt_bset.                                         "984821

  REFRESH: bset_ktosl.                                      "2526464

  gd_distribute_tax = 'X'.                                  "1129096
  IF tab_001-xtxjcd = 'X' OR par_dist IS INITIAL.           "1129096 "3028017
* If jurisdiction codes are active distribution of tax      "1129096
* amounts is turned off. Reasons:                           "1129096
* - Showing tax per tax code regardless of jurisdiction     "1129096
*   structure is meaningless.                               "1129096
* - Proper distrution of tax totals would require deepest   "1129096
*   jurisdiction code txjdp in tax items. This is not       "1129096
*   available in bseg. Accessing bset is not possible       "1129096
*   in general due to compression, and because of missing   "1129096
*   information about relation bseg - bset.                 "1129096
* - Tax recalculation in case of different signs also       "1129096
*   requires txjdp in tax items in bset. Calling tax        "1129096
*   calculation without jurisdiction code causes program    "1129096
*   termination.                                            "1129096
    CLEAR gd_distribute_tax.                                "1129096
  ENDIF.                                                    "1129096
ENDFORM.                    "process_bkpf

*&---------------------------------------------------------------------*
*&      Form  process_bseg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM process_bseg.
  APPEND bseg TO gt_bseg.                                   "984821
ENDFORM.                    "process_bseg

*&---------------------------------------------------------------------*
*&      Form  process_bset
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->KTOSL_BSET text
*      -->MWSKZ_BSET text
*      -->SHKZG_BSET text
*      -->HWBAS_BSET text
*----------------------------------------------------------------------*
FORM process_bset.
*  IF xhana <> 'E'.                                         "2158177
  CHECK:
   sel_mwkz,
   bset-hwbas NE 0.
*  ENDIF.                                                   "2158177

  APPEND bset TO gt_bset.                                   "1609989

  DATA(lv_kalsm) = COND #( WHEN flg_txa_active = abap_true
                THEN cl_fot_common_dao=>agent->get_country_data(
                            bset-tax_country )-kalsm
              ELSE tab_001-kalsm ).
  PERFORM:
    read_t007a USING lv_kalsm bset-mwskz,
    read_t007b USING bset-ktosl.

*  IF xhana = 'E'.                                          "2158177
*                                                           "2158177
*    IF sy-batch <> space                         "1066663  "2158177
*     AND gd_selection_stopped <> space.          "1066663  "2158177
*      MESSAGE a273                               "1066663  "2158177
*        WITH bkpf-bukrs bkpf-belnr bkpf-gjahr.   "1066663  "2158177
*    ENDIF.                                       "1066663  "2158177
*  ENDIF.                                                   "2158177


  IF tab_007b-stgrp EQ 4.              "nicht steuerrelevante Gegenpos.
    CHECK tab_007b-stbkz EQ 3.         "selektieren, sofern sie im
  ENDIF.                               "Basisbetrag enthalten ist

* Exclude MOSS tax codes unless explicitly selected.        "2101269
  IF ( par_moss IS INITIAL ).                               "2101269
    CHECK tab_007a-mossc IS INITIAL.                        "2101269
  ENDIF.                                                    "2101269

  CLEAR tab_bset_sum.

* IF sel_hkon IS INITIAL.                  "713336 KS-01    "975820

  tab_bset_sum-bukrs   = bkpf-bukrs.                        "552412
  IF tab_007b-stgrp EQ 2.
    tab_bset_sum-mwart = 'V'.                               "552412
*   ELSE.                                                   "1371996
  ELSEIF tab_007b-stgrp EQ 1.                               "1371996
    tab_bset_sum-mwart = 'A'.       "1 - Ausgangssteuer  "552412
  ELSE.                                                     "1371996
    tab_bset_sum-mwart = tab_007a-mwart.                    "1371996
  ENDIF.                               "3 / 4 - Investitionssteuer

  IF ( par_xsau IS INITIAL ).                             " OT-01
    CHECK tab_bset_sum-mwart <> 'A'." OT-01     "552412
  ENDIF.                                                  " OT-01
  IF ( par_xsvo IS INITIAL ).                             " OT-01
    CHECK tab_bset_sum-mwart <> 'V'." OT-01     "552412
  ENDIF.                                                  " OT-01

  tab_bset_sum-mwskz   = bset-mwskz.                        "552412
  tab_bset_sum-txdat_from = bset-txdat_from. "TDT
  tab_bset_sum-tax_country = bset-tax_country. "RITA

  tab_bset_sum-hwbas   = bset-hwbas.                        "552412
  tab_bset_sum-ktosl   = bset-ktosl.                        "552412
  IF bset-shkzg EQ 'H'.
    tab_bset_sum-hwste = - bset-hwste.                      "552412
  ELSE.
    tab_bset_sum-hwste = bset-hwste.                        "552412
  ENDIF.

  IF tab_bset_sum-hwste < 0 AND tab_bset_sum-hwbas > 0.     "552412
    tab_bset_sum-hwbas = - tab_bset_sum-hwbas.
  ENDIF.

  IF tab_bset_sum-hwste > 0 AND tab_bset_sum-hwbas < 0.     "552412
    tab_bset_sum-hwbas = - tab_bset_sum-hwbas.
  ENDIF.

  IF tab_bset_sum-hwste = 0
  AND bset-shkzg = 'S'
  AND tab_bset_sum-hwbas < 0.                               "552412
    tab_bset_sum-hwbas = - tab_bset_sum-hwbas.
  ENDIF.

  IF tab_bset_sum-hwste = 0
  AND bset-shkzg = 'H'
  AND tab_bset_sum-hwbas > 0.                               "552412
    tab_bset_sum-hwbas = - tab_bset_sum-hwbas.
  ENDIF.

  tab_bset_sum-stgrp = tab_007b-stgrp.                      "552412
  "Merken für die Anmerkung, daß
  tab_bset_sum-stbkz = tab_007b-stbkz.                      "552412
  "Steuer im Basisbetrag enthalten
  COLLECT tab_bset_sum.

  bset_ktosl-mwskz = bset-mwskz.                            "2526464
  bset_ktosl-txdat_from = bset-txdat_from. "TDT
  bset_ktosl-tax_country = bset-tax_country. "RITA
  bset_ktosl-ktosl = bset-ktosl.                            "2526464
  COLLECT bset_ktosl.                                       "2526464

ENDFORM.                    "process_bset


*----------------------------------------------------------------------*
* FORM CHECK_EP_SUM                                         "2526464
*----------------------------------------------------------------------*
* Create dummy entries in table ep_sum for cases where no BSET was
* in the document. These were created with empty ktosl in ep_sum.
* Entries with empty KTOSL are updated with current calculation result.                                                       *
*----------------------------------------------------------------------*
FORM check_ep_sum                                           "2526464
     USING VALUE(p_ep_sum_idx) TYPE i.

  DATA: ld_wrbtr TYPE wrbtr VALUE '1000000',
        ls_taxes TYPE rtax1u15,
        lt_taxes TYPE TABLE OF rtax1u15,
        ld_mwart TYPE mwart,
        sy_tabix LIKE sy-tabix.

  CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
    EXPORTING
      i_bukrs       = ep_sum-bukrs
      i_mwskz       = ep_sum-mwskz
      i_waers       = tab_001-waers
      i_wrbtr       = ld_wrbtr
      i_prsdt       = ep_sum-txdat_from "TDT
      i_tax_country = ep_sum-tax_country
    TABLES
      t_mwdat       = lt_taxes
    EXCEPTIONS
      OTHERS        = 13.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  DATA(lv_kalsm) = COND #( WHEN flg_txa_active = abap_true
              THEN cl_fot_common_dao=>agent->get_country_data(
                            ep_sum-tax_country )-kalsm
              ELSE tab_001-kalsm ).

  LOOP AT lt_taxes INTO ls_taxes
       WHERE kawrt <> 0.
    sy_tabix = sy-tabix.

    PERFORM read_t007b
          USING ls_taxes-ktosl.

    IF tab_007b-stgrp EQ 4.
      CHECK tab_007b-stbkz EQ 3.
    ENDIF.

    IF tab_007b-stgrp = '2'.
      ld_mwart = 'V'.
    ELSEIF tab_007b-stgrp = '1'.
      ld_mwart = 'A'.
    ELSE.
      PERFORM read_t007a
              USING lv_kalsm ep_sum-mwskz.
      ld_mwart = tab_007a-mwart.
    ENDIF.

    IF ( par_xsau IS INITIAL ).
      CHECK ld_mwart <> 'A'.
    ENDIF.
    IF ( par_xsvo IS INITIAL ).
      CHECK ld_mwart <> 'V'.
    ENDIF.

    ep_sum-ktosl = ls_taxes-ktosl.
    IF sy_tabix = 1.
      MODIFY ep_sum INDEX p_ep_sum_idx.
    ELSE.
      APPEND ep_sum.
    ENDIF.

  ENDLOOP.

ENDFORM.                    "check_ep_sum                   "2526464
*&---------------------------------------------------------------------*
*&      Form  process_bkpf_late
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM process_bkpf_late.
* Add bseg-items from splitted documents to gt_bseg         "1464213
* This ensures that all tax items are included and          "1464213
* consistently distributed to all G/L items.                "1464213
* Lines from other documents will removed at the end.       "1464213
  IF NOT gd_distribute_tax IS INITIAL.                      "3028017
    PERFORM add_bseg_from_split_doc                         "1464213
            USING bkpf.                                     "1464213
  ENDIF.                                                    "3028017

* Replace cross company clearing items in the leading cc    "1132306
* by corresponding items from the other cc.                 "1132306
* gt_bseg may then contain items from other company codes.  "1132306
  IF NOT par_rbuv IS INITIAL.                               "1132306
    IF bkpf-bvorg NE space                                  "1132306
       AND ( bkpf-ausbk EQ bkpf-bukrs OR                    "1132306
             bkpf-ausbk EQ space ).                         "1132306
      PERFORM replace_buv.                                  "1132306
    ELSEIF bkpf-bvorg EQ space                              "1608035
       AND bkpf-stblg NE space                              "1608035
       AND bkpf-tcode EQ 'FB08'                             "1608035
       AND ( bkpf-ausbk EQ bkpf-bukrs OR                    "1608035
             bkpf-ausbk EQ space ).                         "1608035
      PERFORM replace_buv.                                  "1608035
    ENDIF.                                                  "1132306
  ENDIF.                                                    "1132306

* modify the original BSEG data
  LOOP AT gt_bseg INTO bseg.

*   IF xhana <> 'E'.                                        "2158177
*   IF gd_via_ldb = abap_true.                      "2158177"2747095
* process only the leading company in cross company documents
    IF  ( NOT bseg-stbuk IS INITIAL )
    AND ( bseg-bukrs = bkpf-bukrs )                         "1132306
    AND ( bseg-stbuk <> bseg-bukrs ).
*      DESCRIBE TABLE gt_bset LINES cnt_lines.              "1118066
*      IF cnt_lines = 0.                                    "1118066
      READ TABLE gt_bset INTO bset                          "1118066
           WITH KEY tax_country = bseg-tax_country
                    mwskz = bseg-mwskz                      "1118066
                    txdat_from = bseg-txdat_from  "TDT
                    txgrp = bseg-txgrp.                     "1118066
      IF sy-subrc <> 0.                                     "1118066
        DELETE gt_bseg.
        CONTINUE.
      ENDIF.
    ENDIF.
*    ENDIF.
*--->>> EOL-0083 24.04.2024
    CLEAR gv_delete_bseg.
*---<<<

* change account types etc.in documents from FI-CA
    IF bkpf-awtyp EQ 'FKKSU'.                               "OP-01
      PERFORM change_bseg_for_fica.                         "OP-01
    ENDIF.                                                  "OP-01

* eventually correct bseg-xauto
    IF NOT bseg-mwart IS INITIAL.   "Tax posting              "913937
      PERFORM change_bseg_xauto.                            "913937
    ENDIF.                                                  "913937

    MODIFY gt_bseg FROM bseg
           TRANSPORTING koart
                        umsks
                        ktosl
                        xauto.

  ENDLOOP.

* create internal tables gt_bas and gt_tax
  PERFORM analyse_bseg.

* distribute tax amounts
  IF NOT gd_distribute_tax IS INITIAL.                      "1129096
    PERFORM distribute_tax.
  ENDIF.                                                    "1129096

* Remove lines from other parts of splitted documents       "1464213
  PERFORM remove_bseg_from_split_doc.                       "1464213

* apply sel_hkon (selection by account)
  IF NOT sel_hkon IS INITIAL.
    LOOP AT gt_bas.
      IF NOT gt_bas-hkont IN sel_hkon.
        DELETE gt_bas.
      ENDIF.
    ENDLOOP.
  ENDIF.

* apply authority checks late, only for selected items.     "2711917
  DESCRIBE TABLE gt_bas LINES cnt_lines.
  IF cnt_lines > 0.
    IF NOT bkpf-blart IN gr_auth_blart.
      ADD cnt_lines TO gd_cnt_no_auth.
      CLEAR gt_bas[].
    ENDIF.
    LOOP AT gt_bas.
      IF NOT gt_bas-gsber_au IN gr_auth_gsber.
        ADD 1 TO gd_cnt_no_auth.
        DELETE gt_bas.
      ENDIF.
    ENDLOOP.
  ENDIF.

  DESCRIBE TABLE gt_bas LINES cnt_lines.
  CHECK cnt_lines > 0.

* purchasing account processing
  IF NOT par_eink IS INITIAL.
    PERFORM purch_acc_process.
  ENDIF.

* alternative account number and account editing
  PERFORM replace_altkt.

* Call BAdI FI_TAX_UMSV10_01, method append_item            "2260949
  IF NOT g_badi_01 IS INITIAL.                              "2260949
    PERFORM badi_append_item.                               "2260949
  ENDIF.                                                    "2260949

* append the items to the ALV lists
  PERFORM append_item.
ENDFORM.                    "process_bkpf_late





*&---------------------------------------------------------------------*
*&      Form  process_result
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->C          text
*----------------------------------------------------------------------*
FORM process_result USING c .

  TYPES: BEGIN OF ty_data_bset_key,
*          belnr TYPE belnr_d,                                        "2581741
           buzei TYPE buzei,
         END OF ty_data_bset_key.


  DATA:
    lo_ldb_brf               TYPE REF TO cl_fin_ldb_brf,
*   lt_bset_key              TYPE STANDARD TABLE OF ty_data_bset_key  "2747095
*                                 WITH NON-UNIQUE KEY buzei,          "2581741
    ls_bset_key              TYPE ty_data_bset_key,
    lv_failed_bkpf           TYPE abap_bool,
    lv_failed_bseg           TYPE abap_bool,
    lv_empty_result          TYPE abap_bool VALUE abap_false,
**  lv_check                 TYPE abap_bool VALUE abap_true,"2294676
    lv_exit                  TYPE abap_bool,
    lv_bukrs                 TYPE bukrs,
    lv_gjahr                 TYPE gjahr,
    lv_belnr                 TYPE belnr_d,
*   lv_belnr_bset            TYPE belnr_d,                            "2581741
    lv_buzei                 TYPE buzei,
    lt_bkpf_list             TYPE STANDARD TABLE OF rsfs_struc,
    lt_bseg_list             TYPE STANDARD TABLE OF rsfs_struc,
    ls_field                 TYPE rsfs_struc,
    lt_bkpf_bseg_bset_fields TYPE if_fin_selection_types=>tt_selection_fields,
    l_tablename              TYPE string,
    l_fieldname              TYPE string,
    lt_component             TYPE abap_component_tab,
*   lt_component_bkpf        TYPE abap_component_tab,                 "2594946
*   lt_component_bseg        TYPE abap_component_tab,                 "2594946
    lt_component_bkpf        TYPE abap_component_view_tab,  "2594946
    lt_component_bseg        TYPE abap_component_view_tab,  "2594946
    ls_component_view        TYPE abap_simple_componentdescr, "2594946
    lt_component_bset        TYPE abap_component_tab,
    ls_component             TYPE abap_componentdescr,
    lo_bseg_sdesc            TYPE REF TO cl_abap_structdescr,
    lo_bkpf_sdesc            TYPE REF TO cl_abap_structdescr,
    lo_bset_sdesc            TYPE REF TO cl_abap_structdescr,
    lo_itab_sdesc            TYPE REF TO cl_abap_structdescr,
    lo_tdescr                TYPE REF TO cl_abap_tabledescr,
    lr_data                  TYPE REF TO data.
  DATA:
    BEGIN OF lt_doc_for_bset OCCURS 0,                      "2747095
      bukrs LIKE bset-bukrs,
      belnr LIKE bset-belnr,
      gjahr LIKE bset-gjahr,
    END OF lt_doc_for_bset.

  FIELD-SYMBOLS:
    <lt_bkpf_bseg_bset> TYPE ANY TABLE,
    <fs_bkpf_bseg_bset> TYPE any,
    <bukrs>             TYPE any,
    <belnr>             TYPE any,
    <gjahr>             TYPE any,
    <buzei>             TYPE any,
    <ktosl>             TYPE any,
    <mwskz>             TYPE any,
    <txdat_from>        TYPE any, "TDT
    <tax_country>       TYPE any, "RITA
    <hkont>             TYPE any,
    <stbuk>             TYPE any,
    <txgrp>             TYPE any.
*    <mwskz_bset>        TYPE any,                    "no longer used "2747095
*    <txdat_from_bset>   TYPE any, "TDT
*    <hkont_bset>        TYPE any,
*    <txgrp_bset>        TYPE any,
*    <buzei_bset>        TYPE any,
*    <hwbas_bset>        TYPE any,
*    <shkzg_bset>        TYPE any,
*    <ktosl_bset>        TYPE any.

  CREATE OBJECT lo_ldb_brf
    EXPORTING
*     iv_join        = abap_true  "3031241
      it_range_bukrs = br_bukrs[]
      it_range_blart = br_blart[]
      it_range_gjahr = br_gjahr[]
      it_range_rldnr = br_rldnr[]
      it_range_ldgrp = br_ldgrp[]
      it_bkpf_list   = lt_bkpf_list
      it_bseg_list   = lt_bseg_list.

  lo_bkpf_sdesc ?=  cl_abap_structdescr=>describe_by_name( EXPORTING p_name = 'BKPF' ).
* lt_component_bkpf = lo_bkpf_sdesc->get_components( ).               "2594946
  lt_component_bkpf = lo_bkpf_sdesc->get_included_view( ).  "2594946

  lo_bseg_sdesc ?= cl_abap_structdescr=>describe_by_name( EXPORTING p_name = 'BSEG' ).
* lt_component_bseg = lo_bseg_sdesc->get_components( ).               "2594946
  lt_component_bseg = lo_bseg_sdesc->get_included_view( ).  "2594946

  lo_bset_sdesc ?= cl_abap_structdescr=>describe_by_name( EXPORTING p_name = 'BSET' ).
  lt_component_bset = lo_bset_sdesc->get_components( ).

  APPEND LINES OF lo_ldb_brf->gt_bkpf_bseg_fields TO lt_bkpf_bseg_bset_fields.

  LOOP AT lt_bkpf_bseg_bset_fields INTO ls_field.
*   SPLIT ls_field-line AT '~' INTO l_tablename l_fieldname.          "3031241
    l_fieldname = ls_field-line.                            "3031241

*     Read technical properties for component for data creation
*   READ TABLE lt_component_bkpf INTO ls_component                    "2594946
    READ TABLE lt_component_bkpf INTO ls_component_view     "2594946
               WITH KEY name = l_fieldname.
    IF sy-subrc EQ 0.

      READ TABLE lt_component TRANSPORTING NO FIELDS
             WITH KEY name = l_fieldname.

      IF sy-subrc <> 0.
        CLEAR ls_component.                                 "2594946
        MOVE-CORRESPONDING ls_component_view TO ls_component. "2594946
        INSERT ls_component INTO TABLE lt_component.
      ENDIF.

    ELSE.
*     READ TABLE lt_component_bseg INTO ls_component                  "2594946
      READ TABLE lt_component_bseg INTO ls_component_view   "2594946
                 WITH KEY name = l_fieldname.
      IF sy-subrc EQ 0.

        READ TABLE lt_component TRANSPORTING NO FIELDS
               WITH KEY name = l_fieldname.

        IF sy-subrc <> 0.
          CLEAR ls_component.                               "2594946
          MOVE-CORRESPONDING ls_component_view TO ls_component. "2594946
          INSERT ls_component INTO TABLE lt_component.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

*  CLEAR ls_component.             "BSET Fields no longer needed here "2747095
*  READ TABLE lt_component_bset INTO ls_component
*                 WITH KEY name = 'BUZEI'.
*  ls_component-name = 'BUZEI_BSET'.
*  INSERT ls_component INTO TABLE lt_component.
*
*  CLEAR ls_component.
*  READ TABLE lt_component_bset INTO ls_component
*                WITH KEY name = 'MWSKZ'.
*  ls_component-name = 'MWSKZ_BSET'.
*  INSERT ls_component INTO TABLE lt_component.
*
** begin of TDT
*  CLEAR ls_component.
*  READ TABLE lt_component_bset INTO ls_component
*                WITH KEY name = 'TXDAT_FROM'.
*  ls_component-name = 'TXDAT_FROM_BSET'.
*  INSERT ls_component INTO TABLE lt_component.
** end of TDT
*
*  CLEAR ls_component.
*  READ TABLE lt_component_bset INTO ls_component
*                WITH KEY name = 'HKONT'.
*  ls_component-name = 'HKONT_BSET'.
*  INSERT ls_component INTO TABLE lt_component.
*
*  CLEAR ls_component.
*  READ TABLE lt_component_bset INTO ls_component
*                WITH KEY name = 'TXGRP'.
*  ls_component-name = 'TXGRP_BSET'.
*  INSERT ls_component INTO TABLE lt_component.
*
*  CLEAR ls_component.
*  READ TABLE lt_component_bset INTO ls_component
*                WITH KEY name = 'HWBAS'.
*  ls_component-name = 'HWBAS_BSET'.
*  INSERT ls_component INTO TABLE lt_component.
*  CLEAR ls_component.
*  READ TABLE lt_component_bset INTO ls_component
*                WITH KEY name = 'SHKZG'.
*  ls_component-name = 'SHKZG_BSET'.
*  INSERT ls_component INTO TABLE lt_component.
*  CLEAR ls_component.
*  READ TABLE lt_component_bset INTO ls_component
*                WITH KEY name = 'HWSTE'.
*  ls_component-name = 'HWSTE'.
*  INSERT ls_component INTO TABLE lt_component.
*  CLEAR ls_component.
*  READ TABLE lt_component_bset INTO ls_component
*                WITH KEY name = 'FWSTE'.
*  ls_component-name = 'FWSTE'.
*  INSERT ls_component INTO TABLE lt_component.
*  CLEAR ls_component.
*  READ TABLE lt_component_bset INTO ls_component
*                WITH KEY name = 'KTOSL'.
*  ls_component-name = 'KTOSL_BSET'.
*  INSERT ls_component INTO TABLE lt_component.
*  CLEAR ls_component.
*  READ TABLE lt_component_bset INTO ls_component
*                WITH KEY name = 'KSCHL'.
*  ls_component-name = 'KSCHL'.
*  INSERT ls_component INTO TABLE lt_component.

  lo_itab_sdesc  = cl_abap_structdescr=>create( lt_component ).
  lo_tdescr      = cl_abap_tabledescr=>create( lo_itab_sdesc  ).

  CREATE DATA lr_data TYPE HANDLE lo_tdescr.
  ASSIGN lr_data->* TO <lt_bkpf_bseg_bset>.
  CREATE DATA lr_data LIKE LINE OF <lt_bkpf_bseg_bset>.
  ASSIGN lr_data->* TO <fs_bkpf_bseg_bset>.

  lv_empty_result = abap_true.                              "2158177
  lv_failed_bkpf  = abap_true.                              "2294676

  WHILE lv_exit = abap_false.

    CLEAR <lt_bkpf_bseg_bset>.

    FETCH NEXT CURSOR c INTO CORRESPONDING FIELDS OF TABLE
          <lt_bkpf_bseg_bset> PACKAGE SIZE 10000.

    IF sy-subrc <> 0.
      lv_exit = abap_true.
      EXIT.
    ENDIF.
*--->>> EOL-0083 24.04.2024
    TRY.
        CALL FUNCTION '/THKR/CHK_NEW_GL_10'
          EXPORTING
            it_gjahr   = br_gjahr[]
            it_belnr   = br_belnr[]
            it_bukrs   = lo_ldb_brf->gt_range_bukrs
            it_gsber   = s_gsber[]
            it_prctr   = s_prctr[]
            it_segment = s_segmt[]
          CHANGING
            ct_new_gl  = <lt_bkpf_bseg_bset>.
      CATCH cx_root.
    ENDTRY.
*---<<<
****** Mass selection BSET start                            "2747095
    CLEAR: gt_bset_pack[], lt_doc_for_bset[].

* The last document in a package is always processed with the next package
* to ensure completeness. So we need BSET for it in next package too.
    IF lv_bukrs <> space. "1st package, no need to look back
      lt_doc_for_bset-bukrs = lv_bukrs.
      lt_doc_for_bset-belnr = lv_belnr.
      lt_doc_for_bset-gjahr = lv_gjahr.
      APPEND lt_doc_for_bset.
    ENDIF.

    LOOP AT <lt_bkpf_bseg_bset> ASSIGNING <fs_bkpf_bseg_bset>.
      ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_bkpf_bseg_bset> TO <bukrs>.
      ASSIGN COMPONENT 'BELNR' OF STRUCTURE <fs_bkpf_bseg_bset> TO <belnr>.
      ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <fs_bkpf_bseg_bset> TO <gjahr>.
      lt_doc_for_bset-bukrs = <bukrs>.
      lt_doc_for_bset-belnr = <belnr>.
      lt_doc_for_bset-gjahr = <gjahr>.
      COLLECT lt_doc_for_bset.
    ENDLOOP.

* Select package / we know LT_doc_for_bset is not empty
    SELECT bukrs belnr gjahr buzei hwste fwste kschl tax_country
          mwskz txdat_from hkont txgrp shkzg hwbas fwbas ktosl FROM  bset    "2747095 "3042725
          INTO CORRESPONDING FIELDS OF TABLE gt_bset_pack
          FOR ALL ENTRIES IN lt_doc_for_bset
          WHERE  bukrs  = lt_doc_for_bset-bukrs
          AND    belnr  = lt_doc_for_bset-belnr
          AND    gjahr  = lt_doc_for_bset-gjahr
          AND    mwskz  IN sel_mwkz
          AND    tax_country IN sel_taxc
          ORDER BY PRIMARY KEY.                             "3075765
****** Mass selection BSET end                              "2747095
*** Check for empty result set                              "2158177
*    IF <lt_bkpf_bseg_bset>[] IS INITIAL.                   "2158177
*      lv_empty_result = abap_true.                         "2158177
*    ENDIF.                                                 "2158177
    lv_empty_result = abap_false.                           "2158177

    LOOP AT <lt_bkpf_bseg_bset> ASSIGNING <fs_bkpf_bseg_bset>.

**    lv_check = abap_true.                                 "2294676

      ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_bkpf_bseg_bset> TO <bukrs>.
      ASSIGN COMPONENT 'BELNR' OF STRUCTURE <fs_bkpf_bseg_bset> TO <belnr>.
      ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <fs_bkpf_bseg_bset> TO <gjahr>.
      ASSIGN COMPONENT 'BUZEI' OF STRUCTURE <fs_bkpf_bseg_bset> TO <buzei>.
      ASSIGN COMPONENT 'KTOSL' OF STRUCTURE <fs_bkpf_bseg_bset> TO <ktosl>.
      ASSIGN COMPONENT 'MWSKZ' OF STRUCTURE <fs_bkpf_bseg_bset> TO <mwskz>.
      ASSIGN COMPONENT 'TXDAT_FROM' OF STRUCTURE <fs_bkpf_bseg_bset> TO <txdat_from>. "TDT
      ASSIGN COMPONENT 'TAX_COUNTRY' OF STRUCTURE <fs_bkpf_bseg_bset> TO <tax_country>. "RITA
      ASSIGN COMPONENT 'HKONT' OF STRUCTURE <fs_bkpf_bseg_bset> TO <hkont>.
      ASSIGN COMPONENT 'STBUK' OF STRUCTURE <fs_bkpf_bseg_bset> TO <stbuk>.
      ASSIGN COMPONENT 'TXGRP' OF STRUCTURE <fs_bkpf_bseg_bset> TO <txgrp>.


      MOVE-CORRESPONDING <fs_bkpf_bseg_bset> TO bseg.

      IF lv_bukrs <> <bukrs>
           OR lv_belnr <>  <belnr>
           OR lv_gjahr <> <gjahr>.

        lv_bukrs = <bukrs>.                                 "2294676
        lv_belnr = <belnr>.                                 "2294676
        lv_gjahr = <gjahr>.                                 "2294676
        CLEAR lv_buzei.                                     "2294676

**      IF lv_bukrs IS NOT INITIAL.                         "2294676
        IF lv_failed_bkpf = abap_false.                     "2294676
          PERFORM bset_one_document USING bkpf.             "2747095
          PERFORM process_bkpf_late.
        ENDIF.

        MOVE-CORRESPONDING <fs_bkpf_bseg_bset> TO bkpf.
        lv_failed_bkpf = abap_false.                        "2294676

        lo_ldb_brf->bkpf( IMPORTING ev_failed = lv_failed_bkpf
                         CHANGING cs_bkpf = bkpf ).

        CHECK lv_failed_bkpf = abap_false.

**      PERFORM process_bkpf CHANGING lv_check.             "2294676
        PERFORM process_bkpf CHANGING lv_failed_bkpf.       "2294676

**      CLEAR lt_bset_key[].                        "2581714"2747095

**      CHECK lv_check EQ abap_true.                        "2294676

      ENDIF.

      CHECK lv_failed_bkpf = abap_false.                    "2294676

*      ASSIGN COMPONENT 'MWSKZ_BSET' OF STRUCTURE <fs_bkpf_bseg_bset> TO <mwskz_bset>. "2747095
*      ASSIGN COMPONENT 'TXDAT_FROM_BSET' OF STRUCTURE <fs_bkpf_bseg_bset> TO <txdat_from_bset>. "TDT
*      ASSIGN COMPONENT 'HKONT_BSET' OF STRUCTURE <fs_bkpf_bseg_bset> TO <hkont_bset>.
*      ASSIGN COMPONENT 'KTOSL_BSET' OF STRUCTURE <fs_bkpf_bseg_bset> TO <ktosl_bset>.
*      ASSIGN COMPONENT 'TXGRP_BSET' OF STRUCTURE <fs_bkpf_bseg_bset> TO <txgrp_bset>.
*      ASSIGN COMPONENT 'BUZEI_BSET' OF STRUCTURE <fs_bkpf_bseg_bset> TO <buzei_bset>.
*      ASSIGN COMPONENT 'HWBAS_BSET' OF STRUCTURE <fs_bkpf_bseg_bset> TO <hwbas_bset>.

* According to analyse_bseg method
* In some old documents ktosl may be missing. Read it     "1461777
*   from BSET. Archived documents can be affected.          "1461777
*      IF  <ktosl> = space. "Already done in Analyse_BSEG   "2747095
*        AND  <mwskz> = <mwskz_bset>
*        AND  <txdat_from> = <txdat_from_bset> "TDT
*        AND  <hkont> = <hkont_bset>
*        AND <ktosl_bset> <> space.
*        <ktosl> = <ktosl_bset>.
*      ENDIF.

** process only the leading company in cross company documents ( According to 'get bkpf late' )
*      IF <stbuk> IS NOT INITIAL "Already done in FORM process_bkpf_late. "2747095
*        AND <bukrs> <> <stbuk>.
*
*        IF <mwskz> <> <mwskz_bset>
*          OR <txgrp> <> <txgrp_bset>.
*          CONTINUE.
*        ENDIF.
*      ENDIF.

***** Check for duplicate bseg


**    IF <bukrs> <> lv_bukrs                                "2294676
**        OR <belnr> <> lv_belnr                            "2294676
**        OR <gjahr> <> lv_gjahr                            "2294676
**        OR <buzei> <> lv_buzei.                           "2294676
**                                                          "2294676
**      lv_bukrs = <bukrs>.                                 "2294676
**      lv_belnr = <belnr>.                                 "2294676
**      lv_gjahr = <gjahr>.                                 "2294676
      IF <buzei> <> lv_buzei.                               "2294676

        lv_buzei = <buzei>.

        MOVE-CORRESPONDING <fs_bkpf_bseg_bset> TO bseg.

        lo_ldb_brf->bseg( EXPORTING is_bkpf   = bkpf
                           IMPORTING ev_failed = lv_failed_bseg
                           CHANGING  cs_bseg   = bseg ).
        CHECK lv_failed_bseg  = abap_false.

        IF NOT alcur IS INITIAL.
          PERFORM convert_to_alt_curr
                  USING    bkpf-bukrs
                           bkpf-hwaer
                           bkpf-waers
                  CHANGING bseg.
        ENDIF.

        APPEND bseg TO gt_bseg.

      ENDIF.
***** End of check.

***** BSET selection and move: Complete redesign with note "2747095
    ENDLOOP.

  ENDWHILE.

** Perform last 'get bkpf late' if lt_bkpf_bseg_bset is not empty
  IF lv_empty_result = abap_false
    AND lv_failed_bkpf = abap_false.                        "2294676
    PERFORM bset_one_document USING bkpf.                   "2747095
    PERFORM process_bkpf_late.
  ENDIF.

  CLOSE CURSOR c.

ENDFORM.                    "process_result
*&---------------------------------------------------------------------*
*&      Form  convert_to_alt_curr_bset
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ID_BUKRS   text
*      -->ID_HWAER   text
*      -->ID_WAERS   text
*      -->CS_BSET    text
*----------------------------------------------------------------------*
FORM convert_to_alt_curr_bset                               "1132306
     USING    id_bukrs TYPE bukrs
              id_hwaer TYPE waers
              id_waers TYPE waers
     CHANGING cs_bset TYPE bset.

  STATICS: st_teurb TYPE TABLE OF teurb WITH HEADER LINE.

  READ TABLE st_teurb
       WITH KEY bukrs = id_bukrs.
  IF sy-subrc <> 0.
    SELECT SINGLE * FROM teurb INTO st_teurb
                    WHERE bukrs = id_bukrs
                      AND cprog = sy-cprog
                      AND land1 = space.
    IF sy-subrc <> 0.
      CLEAR st_teurb.
      st_teurb-bukrs = id_bukrs.
    ENDIF.
    APPEND st_teurb.
  ENDIF.


  IF st_teurb-waers NE id_hwaer.
    IF st_teurb-waers EQ id_waers.
      cs_bset-hwste = cs_bset-fwste.
      cs_bset-hwbas = cs_bset-fwbas.
    ELSE.
      PERFORM convert_currency_val
              USING     id_hwaer
                        st_teurb-waers
                        st_teurb-kurst
                        excdt
              CHANGING:
                        cs_bset-hwste,
                        cs_bset-hwbas.
    ENDIF.
  ENDIF.

ENDFORM.                    " CONVERT_TO_ALT_CURR           "1132306




*&---------------------------------------------------------------------*
*&      Form  READ_TALTWAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->BUKRS      text
*----------------------------------------------------------------------*
FORM read_taltwar USING bukrs.

  STATICS: st_teurb_taltwar TYPE TABLE OF teurb WITH HEADER LINE.

  READ TABLE st_teurb_taltwar
       WITH KEY bukrs = bukrs.
  IF sy-subrc <> 0.
    SELECT SINGLE * FROM teurb INTO st_teurb_taltwar
                    WHERE bukrs = bukrs
                      AND cprog = sy-cprog
                      AND land1 = space.                    "3291400
    IF sy-subrc <> 0.
      CLEAR st_teurb_taltwar.
      st_teurb_taltwar-bukrs = bukrs.
    ENDIF.
    APPEND st_teurb_taltwar.
  ENDIF.
  taltwar-alwar = st_teurb_taltwar-waers.
ENDFORM.                    "READ_TALTWAR

*&---------------------------------------------------------------------*
*&      Form  BSET_ONE_DOCUMENT   "2747095
*&---------------------------------------------------------------------*
*& Move BSET data for one document into corresponding structures
*&---------------------------------------------------------------------*
FORM bset_one_document USING bkpf TYPE bkpf.

  LOOP AT gt_bset_pack INTO bset
     WHERE bukrs  = bkpf-bukrs
       AND belnr  = bkpf-belnr
       AND gjahr  = bkpf-gjahr.

    IF NOT alcur IS INITIAL.
      PERFORM convert_to_alt_curr_bset
              USING    bkpf-bukrs
                       bkpf-hwaer
                       bkpf-waers
              CHANGING bset.
    ENDIF.

    PERFORM process_bset.
  ENDLOOP.

ENDFORM.   "BSET_ONE_DOCUMENT    "2747095

*&---------------------------------------------------------------------*
*&      Form  read_from_db
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_from_db.

  DATA:
    lo_ldb_brf TYPE REF TO cl_fin_ldb_brf,
    c          TYPE cursor.

  FIELD-SYMBOLS:
        <fs_bkpf_bseg_bset_fields> TYPE rsfs_struc.


  DATA:
    lv_join        TYPE string,
    lv_column      TYPE string,
    lv_column_list TYPE string.

  DATA:
    lt_bkpf_list TYPE STANDARD TABLE OF rsfs_struc,
    lt_bseg_list TYPE STANDARD TABLE OF rsfs_struc.

  DATA:
    ls_field           TYPE rsfs_struc,
    lt_bseg_fields     TYPE if_fin_selection_types=>tt_selection_fields,
    lt_bkpf_fields     TYPE if_fin_selection_types=>tt_selection_fields,
    ls_bkpf_bseg_field TYPE LINE OF if_fin_selection_types=>tt_selection_fields. "3031241


  CREATE OBJECT lo_ldb_brf
    EXPORTING
*     iv_join        = abap_true  "3031241
      it_range_bukrs = br_bukrs[]
      it_range_blart = br_blart[]
      it_range_gjahr = br_gjahr[]
      it_range_rldnr = br_rldnr[]
      it_range_ldgrp = br_ldgrp[]
      it_bkpf_list   = lt_bkpf_list
      it_bseg_list   = lt_bseg_list.

  gr_auth_blart[] = lo_ldb_brf->gt_range_blart[].           "2711917
  gr_auth_gsber[] = lo_ldb_brf->gt_range_gsber[].           "2711917

* APPEND LINES OF lo_ldb_brf->gt_bkpf_bseg_fields TO lt_bkpf_bseg_bset_fields."3031241
  APPEND LINES OF lo_ldb_brf->gt_bseg_fields TO lt_bseg_fields. "3031241
  APPEND LINES OF lo_ldb_brf->gt_bkpf_fields TO lt_bkpf_fields. "3031241

*  ls_field-line = 'BSET~HWSTE'.                                      "2747095
*  APPEND ls_field-line TO lt_bkpf_bseg_bset_fields.
*  ls_field-line = 'BSET~FWSTE'.
*  APPEND ls_field-line TO lt_bkpf_bseg_bset_fields.
*  ls_field-line = 'BSET~KSCHL'.
*  APPEND ls_field-line TO lt_bkpf_bseg_bset_fields.


*  CONCATENATE 'bkpf INNER JOIN bseg ON bkpf~bukrs = bseg~bukrs AND bkpf~belnr = bseg~belnr AND bkpf~gjahr = bseg~gjahr' ##NO_TEXT
*       'LEFT OUTER JOIN bset ON bseg~bukrs = bset~bukrs AND bseg~belnr = bset~belnr AND bseg~gjahr = bset~gjahr' ##NO_TEXT
*       INTO lv_join SEPARATED BY space.
  lv_join = 'bkpf INNER JOIN bseg ON bkpf~bukrs = bseg~bukrs AND bkpf~belnr = bseg~belnr AND bkpf~gjahr = bseg~gjahr' ##NO_TEXT. "2747095

  TRY.

*     LOOP AT lt_bkpf_bseg_bset_fields ASSIGNING <fs_bkpf_bseg_bset_fields>.  "3031241
*       lv_column = <fs_bkpf_bseg_bset_fields>-line.                          "3031241
      LOOP AT lt_bkpf_fields ASSIGNING <fs_bkpf_bseg_bset_fields>. "3031241
        CONCATENATE 'BKPF~' <fs_bkpf_bseg_bset_fields>-line INTO lv_column. "3031241
        lv_column = cl_abap_dyn_prg=>check_column_name( lv_column ).
        CONCATENATE lv_column_list lv_column '' INTO lv_column_list SEPARATED BY space.
      ENDLOOP.
      LOOP AT lt_bseg_fields ASSIGNING <fs_bkpf_bseg_bset_fields>. "3031241
        CONCATENATE 'BSEG~' <fs_bkpf_bseg_bset_fields>-line INTO lv_column. "3031241
        lv_column = cl_abap_dyn_prg=>check_column_name( lv_column ).
        CONCATENATE lv_column_list lv_column '' INTO lv_column_list SEPARATED BY space.
      ENDLOOP.

    CATCH cx_abap_invalid_name.
      RETURN.
  ENDTRY.

*  CONCATENATE lv_column_list 'BSET~BUZEI AS BUZEI_BSET BSET~MWSKZ AS MWSKZ_BSET BSET~TXDAT_FROM AS TXDAT_FROM_BSET' ##NO_TEXT "TDT"2747095
*              ' BSET~HKONT AS HKONT_BSET BSET~TXGRP AS TXGRP_BSET' ##NO_TEXT
*              ' BSET~SHKZG AS SHKZG_BSET BSET~HWBAS AS HWBAS_BSET ' ##NO_TEXT
*              'BSET~KTOSL AS KTOSL_BSET ' INTO lv_column_list SEPARATED BY space.

  OPEN CURSOR c FOR SELECT (lv_column_list)

      FROM (lv_join)
   WHERE bkpf~bukrs IN br_bukrs
        AND bkpf~gjahr IN br_gjahr
        AND bkpf~belnr IN br_belnr
        AND bkpf~xblnr IN br_xblnr
        AND bkpf~budat IN br_budat
        AND bkpf~usnam IN br_usnam
        AND bkpf~ldgrp IN br_ldgrp
        AND bkpf~awtyp IN br_awtyp
        AND bkpf~awsys IN br_awsys
        AND bkpf~cpudt IN br_cpudt
        AND bkpf~awkey IN br_awkey
        AND bkpf~blart IN br_blart
        AND   ( bkpf~ldgrp IN lo_ldb_brf->gt_range_ldgrp OR bkpf~ldgrp IS NULL )      " modified by NewGL Customizing
        AND   ( bkpf~rldnr IN lo_ldb_brf->gt_range_rldnr OR bkpf~rldnr IS NULL )      " modified by NewGL Customizing
        AND   ( bkpf~vatdate IN br_vatdt OR bkpf~vatdate IS NULL )
        AND bkpf~bstat = space
        AND bkpf~monat IN sel_mona
        AND bkpf~bldat IN sel_bldt
*        Selet all bseg item of a document, filter hkont later
*        AND bseg~hkont IN  sel_hkon
        AND ( ( bseg~mwskz IN sel_mwkz AND bseg~mwskz <> space ) "2788318
              OR bseg~ktosl = 'BUV' )                       "2788318
        AND bseg~tax_country IN sel_taxc
        AND (lo_ldb_brf->gt_where) " Free selection, already did input check by FREE_SELECTIONS_RANGE_2_WHERE
        AND
         ( ( bseg~koart <> 'D' AND bseg~koart <> 'K')
          OR (  ( bseg~koart = 'D' OR bseg~koart = 'K' ) AND bseg~ktosl = 'BUV' )
*                                  AND bseg~mwskz <> '**' )                      "2788318
          OR ( ( bseg~koart = 'D' OR bseg~koart = 'K' ) AND bseg~umsks = 'A' ) )

          ORDER BY bkpf~bukrs bkpf~belnr bkpf~gjahr bseg~buzei.

  IF c IS NOT INITIAL.
    PERFORM process_result USING c.

  ENDIF.

ENDFORM.                    "read_from_db
*&---------------------------------------------------------------------*
*&      Form  BADI_APPEND_ITEM                              "2260949
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM badi_append_item.                                      "2260949
  DATA:
    lt_items TYPE rfums_alv_vat_t.

  FIELD-SYMBOLS:
    <f_bas>  LIKE LINE OF gt_bas,
    <f_item> TYPE rfums_alv_vat.


  LOOP AT gt_bas ASSIGNING <f_bas>.
    APPEND INITIAL LINE TO lt_items ASSIGNING <f_item>.
    MOVE-CORRESPONDING <f_bas> TO <f_item>.
  ENDLOOP.


  CALL BADI g_badi_01->append_item
    EXPORTING
      it_bseg       = gt_bseg[]
      it_bset       = gt_bset[]
      is_bkpf       = bkpf
    CHANGING
      ct_items_base = lt_items.

* Copy back the changed data from the BAdI.
* Here it is assumed that no items are added or deleted,
* and that the sequence is not changed. Still we do some
* additional checks to verify this.
  LOOP AT gt_bas ASSIGNING <f_bas>.
    READ TABLE lt_items ASSIGNING <f_item>
         INDEX sy-tabix.
    IF sy-subrc = 0
       AND <f_bas>-bukrs = <f_item>-bukrs
       AND <f_bas>-belnr = <f_item>-belnr
       AND <f_bas>-gjahr = <f_item>-gjahr
       AND <f_bas>-buzei = <f_item>-buzei.
      MOVE-CORRESPONDING <f_item> TO <f_bas>.
    ENDIF.
  ENDLOOP.


ENDFORM.     "badi_append_item                              "2260949
** Forms for Conversion to Application LOG.
*&---------------------------------------------------------------------*
*&      Form  log_create
*&---------------------------------------------------------------------*
*   Creates Log file
*----------------------------------------------------------------------*
*      <--XS_LOG         Log Name
*      <--ES_LOG_HANDLE  Log Handle
*----------------------------------------------------------------------*
FORM log_create  CHANGING xs_log TYPE bal_s_log
                          es_log_handle TYPE balloghndl.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log                 = xs_log
    IMPORTING
      e_log_handle            = es_log_handle
    EXCEPTIONS
      log_header_inconsistent = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " log_create
*&---------------------------------------------------------------------*
*&      Form  log_add_msg
*&---------------------------------------------------------------------*
*       Append application log with the Message.
*----------------------------------------------------------------------*
*      -->IS_LOG_HANDLE  Application log handle
*----------------------------------------------------------------------*
FORM log_add_msg  USING  is_log_handle TYPE balloghndl.


  DATA : ls_message TYPE bal_s_msg,
         ls_messtab TYPE bapiret2.

  DATA: lt_log_handle TYPE  bal_t_logh.

  SORT gt_message_all BY id number.

  LOOP AT gt_message_all INTO ls_messtab.
    ls_message-msgty = ls_messtab-type.
    ls_message-msgid = ls_messtab-id.
    ls_message-msgno = ls_messtab-number.
    ls_message-msgv1 = ls_messtab-message_v1.
    ls_message-msgv2 = ls_messtab-message_v2.
    ls_message-msgv3 = ls_messtab-message_v3.
    ls_message-msgv4 = ls_messtab-message_v4.
* Messages added to the application Log
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = is_log_handle
        i_s_msg          = ls_message
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDLOOP.

* save application log in database
  APPEND is_log_handle TO lt_log_handle.
  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_save_all       = ' '
      i_t_log_handle   = lt_log_handle
    EXCEPTIONS
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      OTHERS           = 4.

  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSEIF sy-subrc > 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " log_add_msg
FORM check_tax_abroad_active CHANGING p_txa_active TYPE abap_bool.
  TYPES: BEGIN OF ty_bukrs,
           bukrs TYPE bukrs,
         END OF ty_bukrs.
  DATA: lt_bukrs TYPE STANDARD TABLE OF ty_bukrs.

  CLEAR p_txa_active.

*  CHECK ( sel_ukrs[] IS NOT INITIAL OR
*          br_bukrs[] IS NOT INITIAL ).

  IF sel_ukrs[] IS NOT INITIAL.
    SELECT bukrs FROM t001 INTO TABLE lt_bukrs WHERE umkrs IN sel_ukrs.
  ELSE.
    SELECT bukrs FROM t001 INTO TABLE lt_bukrs WHERE bukrs IN br_bukrs.

  ENDIF.
  IF sel_ukrs[] IS INITIAL AND
     br_bukrs[] IS INITIAL.
    MESSAGE w063(fot_txa).
  ENDIF.
  LOOP AT lt_bukrs INTO DATA(ls_bukrs).
    DATA(lv_tabix) = sy-tabix.
    TRY.
        DATA(lv_txa_active) = cl_fot_txa_utilities=>agent->is_tax_abroad_active( i_company_code = ls_bukrs-bukrs
              i_do_not_dump  = abap_true ).
      CATCH cx_fot_txa_procedure_call_err.
    ENDTRY.
    IF lv_tabix = 1.
      p_txa_active = lv_txa_active.
    ELSE.
      IF lv_txa_active <> p_txa_active.
        DATA(lv_error) = abap_true.
        EXIT.
      ELSE.
        flg_txa_active = lv_txa_active.
      ENDIF.
    ENDIF.
  ENDLOOP.
  PERFORM modify_screen_for_tax_abroad.
  IF lv_error = abap_true.
    MESSAGE e053(fot_txa).
  ENDIF.
ENDFORM.

FORM modify_screen_for_tax_abroad.

  IF sel_ukrs[] IS INITIAL AND
     br_bukrs[] IS INITIAL AND
     cl_fot_txa_utilities=>agent->is_txa_active_for_any_cocd( ).
    flg_txa_active = abap_true.
  ENDIF.

  LOOP AT SCREEN INTO DATA(ls_screen).

    IF ls_screen-group1 = 'TXA'.
      IF flg_txa_active = abap_true.
        ls_screen-input = '1'.
        ls_screen-invisible = '0'.
      ELSE.
        ls_screen-input = '0'.
        ls_screen-invisible = '1'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN FROM ls_screen.
  ENDLOOP.
ENDFORM.

FORM check_external_audit.
  DATA(lr_head) = cl_sacf=>get_check_settings( id_name = gc_external_audit_scenario ).

  IF lr_head->chk_hmode = cl_sacf_tools=>gc_hmode_a OR
     lr_head->chk_hmode = cl_sacf_tools=>gc_hmode_d.
    gv_external_audit_check = abap_true.
    gt_granted_intv = cl_sais_table_auth=>get_granted_intv_for_dobj(
                           id_dobj = gc_saisacc_doc
                           id_scen = gc_external_audit_scenario ).
    IF line_exists( gt_granted_intv[ 1 ] ) AND
       NOT ( gt_granted_intv[ 1 ]-low = '00000000' AND
             gt_granted_intv[ 1 ]-high = '99991231' ).
      MESSAGE i009(fot_common).
    ENDIF.
  ELSE.
    gv_external_audit_check = abap_false.
  ENDIF.
ENDFORM.

FORM time_restriction_check
        CHANGING lv_reject TYPE abap_bool.
  lv_reject = abap_false.

  IF gv_external_audit_check = abap_true.
    IF t001-xvatdate = abap_true.
      DATA(lv_date) = bkpf-vatdate.
    ELSE.
      lv_date = bkpf-budat.
    ENDIF.
    IF lv_date NOT IN gt_granted_intv.
      lv_reject = abap_true.
    ENDIF.
  ENDIF.
ENDFORM.

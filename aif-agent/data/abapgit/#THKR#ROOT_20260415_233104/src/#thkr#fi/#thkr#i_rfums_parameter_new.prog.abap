*----------------------------------------------------------------------*
*   INCLUDE I_RFUMS_PARAMETER                                          *
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
*   Macros                                                             *
*----------------------------------------------------------------------*
DEFINE selection_screen_line.
  SELECTION-SCREEN: BEGIN OF LINE.
  SELECTION-SCREEN: COMMENT 1(31) &1 FOR FIELD &3 MODIF ID mc4. "2065903
  PARAMETERS &3 LIKE &4 DEFAULT 'X' MODIF ID mc4.
* selection-screen: comment (30) &1 for field &3 modif id mc4."2065903
SELECTION-SCREEN: COMMENT 47(10) TEXT-019
                  FOR FIELD &2 MODIF ID mc4.  "neu

  PARAMETERS &2 LIKE rfums_alv-variante MODIF ID mc4.
*SELECTION-SCREEN:
*    POSITION POS_HIGH.

  SELECTION-SCREEN: PUSHBUTTON 72(15) TEXT-028
                    USER-COMMAND &5 MODIF ID mc4.
  SELECTION-SCREEN END OF LINE.
END-OF-DEFINITION.


*----------------------------------------------------------------------*
* Selektionsparameter                                                  *
*----------------------------------------------------------------------*

***************** Block 01 *** Weiter Abgrenzungen
*SELECTION-SCREEN: PUSHBUTTON /1(30) pushb_o1         "Open Block 01
*                    USER-COMMAND ucomm_o1 MODIF ID mo1,     "#EC NEEDED
*                  PUSHBUTTON /1(30) pushb_c1         "Close Block 01
*                    USER-COMMAND ucomm_c1 MODIF ID mc1.     "#EC NEEDED
*Accessibility:
SELECTION-SCREEN: PUSHBUTTON /1(79) pushb_o1         "Open Block 01
  USER-COMMAND ucomm_o1 MODIF ID mo1 VISIBLE LENGTH 30,
                                                            "#EC NEEDED
PUSHBUTTON /1(79) pushb_c1         "Close Block 01

  USER-COMMAND ucomm_c1 MODIF ID mc1 VISIBLE LENGTH 30.
                                                            "#EC NEEDED

SELECTION-SCREEN BEGIN OF BLOCK b9 WITH FRAME TITLE TEXT-004.
  SELECT-OPTIONS: so_gsber     FOR ls_gsber   MODIF ID mc1 OBLIGATORY
                , so_prctr     FOR ls_prctr   MODIF ID mc1
                , so_segmt     FOR ls_segment MODIF ID mc1
                .
SELECTION-SCREEN END OF BLOCK b9.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-051.
  PARAMETERS:
    par_xstw LIKE rfpdo2-umsvxstw        "Landeswährung statt HW
                         MODIF ID wia,
    par_xalw TYPE fot_lw_to_alw                             "3296651
                         MODIF ID alw.                      "3296651

  SELECT-OPTIONS:
   sel_lstm FOR bset-lstml               "Steuermeldeland
     NO-EXTENSION NO INTERVALS MODIF ID wia,
   sel_taxc FOR bset-tax_country
     NO-EXTENSION NO INTERVALS MODIF ID txa,
   sel_ukrs FOR t007f-umkrs MODIF ID mc1,"Umsatzsteuerkreise
   sel_mona FOR bkpf-monat MODIF ID mc1, "Geschäftsmonate
   sel_cpud FOR bkpf-cpudt MODIF ID mc1, "CPU-Datum
   sel_bldt FOR bkpf-bldat MODIF ID mc1, "Belegdatum
   sel_vtdt FOR bkpf-vatdate MODIF ID mc1, "VAT Due date           "N1023317
   sel_mwkz FOR bset-mwskz MODIF ID mc1, "Umsatzsteuerkennzeichen
   sel_ktos FOR bset-ktosl MODIF ID mc1, "Vorgangsschlüssel
   sel_umsk FOR bseg-umskz MODIF ID mc1, "Sonderhauptbuchkennzeichen
   sel_bupl FOR bseg-bupla MODIF ID mc1, "Geschaeftsort   "OP-01
   skonto FOR bset-hkont MODIF ID mc1.   "Hauptbuchkonto  "OP-09
  PARAMETERS:
* p_bupla  LIKE bseg-bupla MODIF ID mc1, "Geschaeftsort  "OP-01
    par_xsau LIKE rfpdo1-umsvxart MODIF ID mc1, "Ausgangsst. selektieren
    par_xsvo LIKE rfpdo1-umsvxart MODIF ID mc1. "Vorsteuer selektieren
  PARAMETERS:                                               "1948319
    par_def LIKE rfpdo1-taxdefer AS CHECKBOX  "sel. deferred tax   "1948319
                                 MODIF ID mc1.              "1948319
  PARAMETERS:                                               "2101269
    par_moss LIKE rfpdo1-sel_moss AS CHECKBOX  "sel. MOSS-taxcodes "2101269
                                 MODIF ID mc1.              "2101269
  SELECTION-SCREEN:
  SKIP,
  BEGIN OF LINE,
  COMMENT 01(50) TEXT-006 FOR FIELD sel_tmdt MODIF ID mc1,  "#EC NEEDED
  END OF LINE.
  DATA:
    time_help LIKE rfpdo-umsvtime.       "Dummy für SEL_TMTI
  SELECT-OPTIONS:
    sel_tmdt FOR bset-stmdt NO-EXTENSION MODIF ID mc1, "Datum Steuermeld.
    sel_tmti FOR time_help NO-EXTENSION MODIF ID mc1. "Füllt RAN_TMTI
  RANGES:
    ran_tmti FOR bset-stmti.             "Uhrzeit Programml. Steuermeld.
SELECTION-SCREEN END OF BLOCK b01.

****************** Block 06 *** Joint Venture Abgrenzungen
*SELECTION-SCREEN: PUSHBUTTON /1(30) pushb_o6         "Open Block 06
*                    USER-COMMAND ucomm_o6 MODIF ID mo6,     "#EC NEEDED
*                  PUSHBUTTON /1(30) pushb_c6         "Close Block 06
*                    USER-COMMAND ucomm_c6 MODIF ID mc6.     "#EC NEEDED
*Accessibility:
SELECTION-SCREEN: PUSHBUTTON /1(79) pushb_o6         "Open Block 02
  USER-COMMAND ucomm_o6 MODIF ID mo6 VISIBLE LENGTH 30,
                                                            "#EC NEEDED
PUSHBUTTON /1(79) pushb_c6         "Close Block 03
  USER-COMMAND ucomm_c6 MODIF ID mc6 VISIBLE LENGTH 30.
                                                            "#EC NEEDED

SELECTION-SCREEN BEGIN OF BLOCK b06 WITH FRAME TITLE TEXT-060.
  PARAMETERS:
    par_xjvs TYPE fot_jva_split_act MODIF ID mc6.
  SELECT-OPTIONS:
    sel_vnam FOR bseg-vname MODIF ID mc6,
    sel_grou FOR bseg-egrup MODIF ID mc6.
  PARAMETERS:
    par_cori TYPE fot_jva_recind MODIF ID mc6,   "Substitute cost object RI
    par_orig TYPE fot_jva_orig_cost_object_act MODIF ID mc6.
SELECTION-SCREEN END OF BLOCK b06.

****************** Block 02 *** Zahllast-Buchung
*SELECTION-SCREEN: PUSHBUTTON /1(30) pushb_o2         "Open Block 02
*                    USER-COMMAND ucomm_o2 MODIF ID mo2,     "#EC NEEDED
*                  PUSHBUTTON /1(30) pushb_c2         "Close Block 03
*                    USER-COMMAND ucomm_c2 MODIF ID mc2.     "#EC NEEDED
*Accessibility:
SELECTION-SCREEN: PUSHBUTTON /1(79) pushb_o2         "Open Block 02
  USER-COMMAND ucomm_o2 MODIF ID mo2 VISIBLE LENGTH 30,
                                                            "#EC NEEDED
PUSHBUTTON /1(79) pushb_c2         "Close Block 03
  USER-COMMAND ucomm_c2 MODIF ID mc2 VISIBLE LENGTH 30.
                                                            "#EC NEEDED

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-057.
  PARAMETERS:
    par_binp LIKE rfpdo-umsvbaip MODIF ID mc2, "Batch-Input gewünscht
    par_blar LIKE rfpdo-allgblar MODIF ID mc2, "Belegart für BI
    par_bdat LIKE rfpdo-allgbdat MODIF ID mc2, "Buchungsdatum für BI
    par_mona LIKE rfpdo-allgbupe MODIF ID mc2, "Periode für BI
    par_zkto LIKE rfpdo1-umsvzkto MODIF ID mc2, "Abweichend. Zahllastkonto
    par_fdat LIKE rfpdo-allgfdat MODIF ID mc2, "Fälligkeitsdatum für
    " Abführen der Zahllast an das Finanzamt
    par_bina LIKE rfpdo-allgbina MODIF ID mc2, "Name der BI-Mappe
    par_sofa LIKE rfipi-bdcimmed MODIF ID mc2, "Mappe sofort abspielen
*                                             Mappe halten par_keep  "N1917485
    par_keep LIKE rfpdo1-f120keep DEFAULT ' ' MODIF ID mc2, "N1917485
    par_adat LIKE tbtcjob-sdlstrtdt MODIF ID mc2, "Datum: Abspielen BI
    par_zeit LIKE tbtcjob-sdlstrttm MODIF ID mc2. "Uhrzeit: Abspielen BI
SELECTION-SCREEN END OF BLOCK b02.

***************** Block 03 *** Ausgabesteuerung
*SELECTION-SCREEN: PUSHBUTTON /1(30) pushb_o3         "Open Block 03
*                    USER-COMMAND ucomm_o3 MODIF ID mo3,     "#EC NEEDED
*                  PUSHBUTTON /1(30) pushb_c3         "Close Block 03
*                    USER-COMMAND ucomm_c3 MODIF ID mc3.     "#EC NEEDED
*Accessibility:
SELECTION-SCREEN: PUSHBUTTON /1(79) pushb_o3         "Open Block 03
  USER-COMMAND ucomm_o3 MODIF ID mo3 VISIBLE LENGTH 30,
                                                            "#EC NEEDED
PUSHBUTTON /1(79) pushb_c3         "Close Block 03
  USER-COMMAND ucomm_c3 MODIF ID mc3 VISIBLE LENGTH 30.
                                                            "#EC NEEDED

SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-053.
* These Parameters are used, for
  PARAMETERS:
* Performance & Selection-Criterion
    par_xcas LIKE rfums_alv-umsvxcas MODIF ID mc3, "Quittungsnummer lesen
* Performance
    par_xadr LIKE rfums_alv-umsvxadr MODIF ID mc3, "Anschriftsdaten lesen
    par_stru TYPE rfums_alv-r_mwskz MODIF ID mc3,  "Steuern runden
    par_rcty TYPE fot_r_tax_country MODIF ID tx2,
* Modification of some Data
    par_xsht LIKE rfpdo-umsvxsht MODIF ID mc3,   "Summen nach S/H trennen
    par_nava LIKE rfpdo2-umsvnava MODIF ID mc3,  "Basisbetrag um NAV
    "erhöhen
    par_bodo LIKE rfpdo2-umsvboll MODIF ID mc3,  "Bolle Doganali
* Layout
    par_lsep LIKE rfpdo-allglsep MODIF ID mc3,   "Listseparation gewünscht
    par_xfwa TYPE rfums_alv-umsvxfwa MODIF ID mc3, "Fremdwährung lesen
    par_nohe LIKE rfpdo2-umsvhead DEFAULT ' ' MODIF ID mc3,   "OP-08
    par_stat LIKE rfpdo2-statistik DEFAULT ' ' MODIF ID mc3,  "OP-08
    par_sort LIKE rfpdo1-umsvsokz00 DEFAULT '1' MODIF ID mc3, "OP-18
    par_lang TYPE umsvspras VALUE CHECK MODIF ID mc3,       "1263340
    par_aver LIKE tsadv-nation MODIF ID mc3.                "1551245
  DATA help_diac TYPE umsv_discacc.                         "1868787
  SELECT-OPTIONS:
    so_diac FOR help_diac MODIF ID mc3                      "1868787
            MATCHCODE OBJECT sako.                          "1868787
  SELECTION-SCREEN SKIP.
  PARAMETERS:
    par_mikf LIKE rfpdo-allgmikf MODIF ID mc3,
    "Mikrofiche-Information "429158
    par_line LIKE rfpdo1-allgline MODIF ID mc3.  "Zusatzüberschrift

  PARAMETERS:                                                       "xml
    par_xml  TYPE umsvxml MODIF ID mc3.                             "xml

SELECTION-SCREEN: END OF BLOCK b03.

***************** Block 04 *** Ausgabelisten
*SELECTION-SCREEN: PUSHBUTTON /1(30) pushb_o4         "Open Block 04
*                    USER-COMMAND ucomm_o4 MODIF ID mo4,     "#EC NEEDED
*                  PUSHBUTTON /1(30) pushb_c4         "Close Block 04
*                    USER-COMMAND ucomm_c4 MODIF ID mc4.     "#EC NEEDED
*Accessibility:
SELECTION-SCREEN: PUSHBUTTON /1(79) pushb_o4         "Open Block 04
  USER-COMMAND ucomm_o4 MODIF ID mo4 VISIBLE LENGTH 30,
                                                            "#EC NEEDED
PUSHBUTTON /1(79) pushb_c4         "Close Block 04
  USER-COMMAND ucomm_c4 MODIF ID mc4 VISIBLE LENGTH 30.
                                                            "#EC NEEDED
SELECTION-SCREEN BEGIN OF BLOCK b04 WITH FRAME TITLE TEXT-054.
*SELECTION-SCREEN: BEGIN OF LINE,
*                  COMMENT 1(20) text-020 MODIF ID mc4, "Output Lists
*                  COMMENT pos_low(20) text-019         "Display variant
*                    FOR FIELD par_var1 MODIF ID mc4,        "#EC NEEDED
*                  END OF LINE.
* Macro: Text   Variant  Display? Reference           USER-Command
  selection_screen_line:
         TEXT-021 par_var1 par_lis1 rfpdo-umsvxaus      con1, "#EC NEEDED
         TEXT-022 par_var2 par_lis2 rfums_alv-umsvxasu  con2, "#EC NEEDED
         TEXT-023 par_var3 par_lis3 rfpdo-umsvxvor      con3, "#EC NEEDED
         TEXT-024 par_var4 par_lis4 rfums_alv-umsvxvsu  con4, "#EC NEEDED
         TEXT-025 par_var5 par_lis5 rfums_alv-umsvxsep  con5, "#EC NEEDED
         TEXT-026 par_var6 par_lis6 rfums_alv-umsvxbsu  con6, "#EC NEEDED
         TEXT-027 par_var7 par_lis7 rfums_alv-umsvxhsu  con7. "#EC NEEDED
SELECTION-SCREEN END OF BLOCK b04.

***************** Block 05 ***  Buchungsparameter
*SELECTION-SCREEN: PUSHBUTTON /1(30) pushb_o5         "Open Block 05
*                    USER-COMMAND ucomm_o5 MODIF ID mo5,     "#EC NEEDED
*                  PUSHBUTTON /1(30) pushb_c5         "Close Block 05
*                    USER-COMMAND ucomm_c5 MODIF ID mc5.     "#EC NEEDED
*Accessibility:
SELECTION-SCREEN: PUSHBUTTON /1(79) pushb_o5         "Open Block 05
  USER-COMMAND ucomm_o5 MODIF ID mo5 VISIBLE LENGTH 30,
                                                            "#EC NEEDED
PUSHBUTTON /1(79) pushb_c5         "Close Block 05
  USER-COMMAND ucomm_c5 MODIF ID mc5 VISIBLE LENGTH 30.
                                                            "#EC NEEDED
SELECTION-SCREEN BEGIN OF BLOCK b05 WITH FRAME TITLE TEXT-052.
  PARAMETERS:
    par_kukp LIKE rfpdo2-umsvkukp
      RADIOBUTTON GROUP upd1 MODIF ID mc5, "Belege nicht aktualieren
    par_bsud LIKE rfpdo2-umsvbsud
      RADIOBUTTON GROUP upd1 MODIF ID mc5, "Belege aktualisieren: Echtlauf
    par_bupl LIKE rfpdo2-umsvbupl
      RADIOBUTTON GROUP upd1 MODIF ID mc5. "Belege aktual.: Testlauf

  SELECTION-SCREEN: SKIP,                                   "751603
  BEGIN OF BLOCK c04
  WITH FRAME TITLE TEXT-059. "Elektronische Voranmeldung
  PARAMETERS:
    parpeuva LIKE rfpdo2-umsveuva MODIF ID mc5, "Meldedaten erzeugen
                                                            "803670
    parpcorr LIKE rfpdo2-umsvcorr MODIF ID mc5, "Berichtigte Voranmeldung
                                                            "803670
    parpdyea LIKE rfpdo2-umsvdyea MODIF ID mc5, "Meldejahr
                                                            "803670
    parpdper LIKE rfpdo2-umsvdper MODIF ID mc5. "Meldeperiode
                                                            "803670
  SELECTION-SCREEN: END OF BLOCK c04.
  SELECTION-SCREEN: SKIP,
  BEGIN OF BLOCK c01
  WITH FRAME TITLE TEXT-056. "Formulardruck
  PARAMETERS:
    par_caos LIKE rfpdo1-umsvcaos MODIF ID mc5, "No BSET compress   "OT-07
    par_umsv LIKE rfpdo1-umsvumsv MODIF ID mc5, "Formulardruck vorbereiten
    par_laud LIKE umsv-laufd MODIF ID mc5, "Laufdatum des Reports
    par_laui LIKE umsv-laufi MODIF ID mc5. "Zusätzl. Laufidentifikation

  SELECTION-SCREEN: END OF BLOCK c01,
  SKIP,
  BEGIN OF BLOCK c02
  WITH FRAME TITLE TEXT-058. "DTA File
  PARAMETERS:
    par_xdta LIKE rfpdo2-umsvxdta USER-COMMAND ucomm_dmee MODIF ID mc5, "Note 2420374    "Create DTA File
    par_trty LIKE dmee_tree_head-tree_type DEFAULT 'UMS1'  NO-DISPLAY,
    par_trid LIKE dmee_tree_head-tree_id MODIF ID mc5. "DME Tree ID
*SELECTION-SCREEN PUSHBUTTON /31(30) push_dme           "899205 "931482
  SELECTION-SCREEN PUSHBUTTON /31(30) pushpdme              "931482
    USER-COMMAND act_dmee_button                            "899205
    MODIF ID mc5.                                           "899205
  PARAMETERS:                                               "899205
* par_dmea TYPE fpm_selpar-param MODIF ID mc5 NO-DISPLAY,"899205"931482
    parpdmea TYPE fpm_selpar-param MODIF ID mc5 NO-DISPLAY, "931482
    par_tems LIKE regut-tsnam MODIF ID mc5 NO-DISPLAY,     "Temse Name
    par_file LIKE rfpdo1-allgunix MODIF ID mc5.            "File Name

  SELECTION-SCREEN: END OF BLOCK c02,
  SKIP,
  BEGIN OF BLOCK c03
  WITH FRAME TITLE TEXT-055. "Belegnummerierung
  PARAMETERS:
    par_udtr LIKE rfpdo1-umsvtrud MODIF ID mc5, "Update Table TRVOR
    par_reid LIKE rfpdo1-umsvname MODIF ID mc5,               "OP-12
    par_snou LIKE rfpdo1-umsvstno MODIF ID mc5, "Starting Number Output
    par_snin LIKE rfpdo1-umsvstni MODIF ID mc5. "Starting Number Input
  SELECTION-SCREEN END OF BLOCK c03.
SELECTION-SCREEN END OF BLOCK b05.

*********** No Display Parameters
PARAMETERS: par_avpn(1) TYPE c NO-DISPLAY,  "Anzeig.Variant.Pfleg.Nummer
            par_cb1(1)  TYPE c NO-DISPLAY,   "Close Block 1
            par_cb2(1)  TYPE c NO-DISPLAY,   "Close Block 2
            par_cb3(1)  TYPE c NO-DISPLAY,   "Close Block 3
            par_cb4(1)  TYPE c NO-DISPLAY,   "Close Block 4
            par_cb5(1)  TYPE c NO-DISPLAY,   "Close Block 5
            par_cb6(1)  TYPE c NO-DISPLAY.   "Close Block 6
* p_nowarn: suppress certain warning messages on the        "1987887
* seelction screen when called from other programs.         "1987887
PARAMETERS: p_nowarn TYPE xfeld NO-DISPLAY.                 "1987887
* Application Job Check mode Parameter
PARAMETERS: p_check TYPE xfeld NO-DISPLAY.
PARAMETERS: p_srftsk TYPE /bobf/conf_key NO-DISPLAY. "SRF-rep "2434847

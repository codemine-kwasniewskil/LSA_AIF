*&---------------------------------------------------------------------*
*& Report /THKR/BCS_RFFMREP_LDB_PT01_V02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/bcs_rffmrep_ldb_pt01_v02 MESSAGE-ID fi_e.

*---Purpose:
*   This report is used to display annual budget versus commitment/
*   actual totals for period-based encumbrance/actual tracking.

*---Algorithm:
*   1. Get information about FM area, FM Account assignment, Fiscal Year
*      Budget category, Value type, etc. from the selection screen
*      as input by the user.
*   2. Give a warning if PBET is inactive.
*   3. Get the Budget totals and Commitment/Actual totals using the
*      logical database and fill the internal table g_t_item.
*   4. If there are no records in g_t_item for the selection criteria,
*      then, exit the program.
*   5. Sort the list by FM account assignment, Budget category,
*      Version, Fiscal year, Process, Budget type
*   6. Classify the amounts to payments, invoices or open items,
*      budget depending on the value type of the total and
*      calculate budget - payment, budget - invoice, and available
*      budget for these per account assignment per fiscal year.
*   7. Display the list using the information in g_t_item.
*   8. Display the line items on the drilldown of a list line.

*--------------------------------------------------------------------*
* Historie
*--------------------------------------------------------------------*
*
* 20230303  - Stübing TSI - Erstellung
* 20241111  - Lehmann TSI - Übernahme HKR / Optimierung
*
*--------------------------------------------------------------------*


TABLES: fkrs, fmaa_ba, fmaa_pa, bvsn, budt, conval, sscrfields,
        fctr, fpos, ffnd, fmas.

*--------------------------------------------------------------------*
* DS 20210503
TABLES: /thkr/sbcs_ifmrkbhh, fmtox, fmoix,  budp, avct.
*--------------------------------------------------------------------*

TYPE-POOLS: slis, sdydo, rsds.

CONSTANTS: con_repid            TYPE sy-cprog       VALUE  '/THKR/BCS_RFFMREP_LDB_PT01_V02',
           con_tcode            TYPE sy-tcode       VALUE  '/THKR/BCS_REPORTING',
           con_output_tname     TYPE slis_tabname   VALUE  'G_T_ITEM',            " orig. BCS Report
           con_output_tname_lbb TYPE slis_tabname   VALUE  'G_T_ITAB',            " new
           con_struct           TYPE dd03l-tabname  VALUE  '/THKR/SBCS_IFMRKBHH'.

*---------------- Include-Block ----------------------------------------
* "/ Initialisierungsroutine der dynamischen HHStelle.
"  Entnommen aus RFFMKBHH , Zeile 6 + 141
INCLUDE /thkr/ihhpldyh.
INCLUDE:
*        Parameters for Schedule manager
         rkasmawf,
*        FM Value types
         ififmcon_value_types,
*        BCS constants
         ibukucon.

*--------------------------------------------------------------------*
* "/ Bewirtschaftung
DATA: g_t_itab      LIKE /thkr/sbcs_ifmrkbhh  OCCURS 0 WITH HEADER LINE."type SORTED TABLE OF /thkr/sbcs_ifmrkbhh WITH HEADER LINE with UNIQUE KEY rfundsctr rcmmtitem. "OCCURS 0 WITH HEADER LINE.
DATA: ls_g_t_itab   TYPE /thkr/sbcs_ifmrkbhh.

* Datenquelle gemäß Customizing: Tabelle ZCBB_BUKF_DSRC
CONSTANTS:
  fmkf_fmbdt  TYPE bukf_datasource VALUE '0001',  " Budgetierungsdaten (logDB: BUDT ->  SAPTab:  FMBDT)
  fmkf_fmtox  TYPE bukf_datasource VALUE '0002',  " Summensätze Obligo & Ist
  fmkf_fmavct TYPE bukf_datasource VALUE '0003'.  " VbK-Daten (logDB: AVCT ->  SAPTab:  FMAVCT)

*--------------------------------------------------------------------*

*--- FM dimensions activity info
TYPES: BEGIN OF s_fmdim_activity_info,
         grant_nbr TYPE flag,
         fund      TYPE flag,
         budget_pd TYPE flag,
         fundsctr  TYPE flag,
         cmmtitem  TYPE flag,
         funcarea  TYPE flag,
         measure   TYPE flag,
         userdim   TYPE flag,
       END   OF s_fmdim_activity_info.

DATA:  g_flg_fmdimactive TYPE s_fmdim_activity_info.

*--- Indication of single value occurence
TYPES: BEGIN OF s_sngl_value_info,
         fikrs     TYPE flag,
         fwaer     TYPE flag,
         fyear     TYPE flag,
         budcat    TYPE flag,
         version   TYPE flag,
         ceffyear  TYPE flag,
         grant_nbr TYPE flag,
         fund      TYPE flag,
         budget_pd TYPE flag,
         fundsctr  TYPE flag,
         cmmtitem  TYPE flag,
         funcarea  TYPE flag,
         measure   TYPE flag,
         userdim   TYPE flag,
         valtype   TYPE flag,
         process   TYPE flag,
         budtype   TYPE flag,
         notsngl   TYPE flag,  " dummy flag; always space

         fictr     TYPE flag,  " Finanzstelle
         fipex     TYPE flag,  " Finazposition
         ryear     TYPE flag,

       END   OF s_sngl_value_info.

DATA:  g_flg_sngl_value TYPE s_sngl_value_info.


TYPES: BEGIN OF s_header_data,
         fikrs     TYPE fm01-fikrs,
         fwaer     TYPE fm_waers,   "FM Area currency
         fyear     TYPE budt-ryear,       "!
         budcat    TYPE bubudcat-budcat,
         version   TYPE tkvs-versi,
         ceffyear  TYPE budt-ceffyear_9,  "!
         grant_nbr TYPE gmgr-grant_nbr,
         fund      TYPE fmfincode-fincode,
         budget_pd TYPE fm_budget_period,
         fundsctr  TYPE fmfctr-fictr,
         cmmtitem  TYPE fmci-fipex,
         funcarea  TYPE tfkb-fkber,
         measure   TYPE fmmeasure-measure,
         userdim   TYPE budt-ruserdim,    "!
         valtype   TYPE buvaltype-valtype,
         process   TYPE buprocess-process,
         budtype   TYPE fmbudtype-budtype,

         fictr     TYPE fm_fictr,  " Finanzstelle
         fipex     TYPE fm_fipex,  " Finazposition
         ryear     TYPE gjahr,     " Geschäftsjahr

       END   OF s_header_data.

DATA:  g_f_header TYPE s_header_data.

*--- Internal table with Master data
DATA:  g_t_master_data LIKE fmaa_ba OCCURS 100 WITH HEADER LINE.

*--- Internal table with mixed Budget/Commt+Actuals Data
DATA: BEGIN OF g_t_item OCCURS 100,
*        "Header Fields
        rgrant_nbr LIKE budt-rgrant_nbr,
        rfund      LIKE budt-rfund,
        rbudget_pd LIKE budt-budget_pd_9,
        rfundsctr  LIKE budt-rfundsctr,  " Finanzstelle
        rcmmtitem  LIKE budt-rcmmtitem,  " Finanzposition
        rfuncarea  LIKE budt-rfuncarea,
        rmeasure   LIKE budt-rmeasure,
        ruserdim   LIKE budt-ruserdim,
        fwaer      LIKE budt-fwaer,
*        "Item Fields
        fikrs      LIKE budt-rfikrs,
        budcat     LIKE budt-rldnr,
        version    LIKE budt-rvers,
        fyear      LIKE budt-ryear,
        process    LIKE budt-process_9,
        budtype    LIKE budt-budtype_9,
        budget     LIKE budt-hamount,
        payment    LIKE conval-fkbtrp,
        bud_pmt    LIKE budt-hamount,
        invoice    LIKE conval-fkbtrp,
        bud_inv    LIKE budt-hamount,
        opitems    LIKE conval-fkbtrp,
        rs_budget  LIKE budt-hamount,
        cname      LIKE fmaa_ba-cname,
        cdscr      LIKE fmaa_ba-cdscr,
      END OF g_t_item.


" interne Puffertabelle für die Deckungsgruppen
DATA: BEGIN OF g_t_deckungsgrp OCCURS 100,
*        "Header Fields
        rfundsctr    LIKE avct-rfundsctr,  " Finanzstelle
        rcmmtitem    LIKE avct-rcmmtitem,  " Finanzposition
        rldnr        LIKE avct-rldnr,      " Ledger
        ryear        LIKE avct-ryear,      " Geschäftsjahr
        rcvrgrp_9_9h LIKE avct-rcvrgrp_9,  " Deckungsgruppe
      END OF g_t_deckungsgrp.

DATA: ls_g_t_deckungsgrp LIKE LINE OF g_t_deckungsgrp.

DATA: lv_index_dgrp    LIKE sy-index.

*--- ALV Meta Data
DATA: g_t_fieldcat     TYPE slis_t_fieldcat_alv,
      g_f_layout       TYPE slis_layout_alv,
      g_t_sort         TYPE slis_t_sortinfo_alv,
      g_t_filt         TYPE slis_t_filter_alv,
      g_t_sel_crit     TYPE slis_sel_hide_alv,
      g_t_events       TYPE slis_t_event,
      g_t_sp_groups    TYPE slis_t_sp_group_alv,
      g_f_print        TYPE slis_print_alv,
      g_title          TYPE lvc_title,
      g_background_id  TYPE sdydo_key,
      g_t_object_info  TYPE fm_t_listheader_data,
      g_t_top_messages TYPE fm_t_top_messages.

DATA: g_f_disvariant   TYPE disvariant.

*--- Year of Cash Effectivity active for given single Budget Category
DATA:  g_flg_ceffyear_used TYPE flag.

* Signs of revenues/expenditures in the reporting
DATA: g_flg_expsign,        " Sign for expenditures " Vorzeichen Ausgaben
      g_flg_revsign.        " Sign for revenues      " Vorzeichen Einnahmen


DATA:    g_flg_komm.        " Kommunen Flag


*--- Data for Schedule manager
DATA: g_aplstat        TYPE smmain-aplstat,
      g_f_schedman_key TYPE schedman_key.

*--------------------------------------------------------------------*
TYPES: BEGIN OF ty_conval,
         fikrs TYPE fikrs.   " Finanzkreis
         INCLUDE STRUCTURE conval.
TYPES END OF ty_conval.

DATA  g_t_conval TYPE STANDARD TABLE OF ty_conval.
DATA: l_s_conval TYPE ty_conval.
FIELD-SYMBOLS: <ls_g_t_conval> TYPE ty_conval.

TYPES: BEGIN OF ty_fmtox,
         fikrs TYPE fikrs.   " Finanzkreis
         INCLUDE STRUCTURE fmtox.
TYPES END OF ty_fmtox.

DATA: g_t_fmtox   TYPE STANDARD TABLE OF ty_fmtox.
DATA: l_s_fmtox   TYPE ty_fmtox.
FIELD-SYMBOLS: <ls_g_t_fmtox> TYPE ty_fmtox.



DATA: g_t_avct   LIKE avct   OCCURS 0 WITH HEADER LINE.
DATA: g_t_fmoix  LIKE fmtox  OCCURS 0 WITH HEADER LINE.
DATA: g_t_budt   LIKE budt   OCCURS 0 WITH HEADER LINE.

DATA: ls_budt    TYPE budt.


DATA: g_t_budp   LIKE budp   OCCURS 0 WITH HEADER LINE.


* neue Ausgabetabelle
DATA: lt_ifmrkbhh TYPE STANDARD TABLE OF ifmrkbhh.
DATA: ls_ifmrkbhh TYPE ifmrkbhh.

DATA: ls_g_t_item LIKE LINE OF g_t_item.

FIELD-SYMBOLS: <ls_g_t_item> LIKE LINE OF g_t_item.

DATA:  ls_fctr TYPE fctr.
DATA:  lt_fctr TYPE STANDARD TABLE OF fctr.

DATA:  ls_fpos TYPE fpos.
DATA:  lt_fpos TYPE STANDARD TABLE OF fpos.

DATA:  lv_fctr TYPE flag.
DATA:  lv_fpos TYPE flag.

* neue Stammdatenkombinationstabelle
TYPES: BEGIN OF ty_masterdata_bcs,
         fonds   TYPE  bp_geber,   "  Fonds
         fictr   TYPE  fm_fictr,   "  Finanzstelle
         fipex   TYPE  fm_fipex,   "  Finanzposition
         measure TYPE  fm_measure. " Haushaltsprogramm   - * DS20230308 - Anpassung Haushaltsprogramm, Fonds
TYPES END OF ty_masterdata_bcs.

DATA: lt_masterdata_bcs TYPE STANDARD TABLE OF ty_masterdata_bcs.
DATA: ls_masterdata_bcs TYPE ty_masterdata_bcs.

DATA: ls_g_t_master_data TYPE fmaa_ba.

* Relation Kennzahl zu Datenquelle holen
DATA: lt_zcbb_bukf_kfdsrc   TYPE STANDARD TABLE OF /thkr/kf_kfdsrc. " zcbb_bukf_kfdsrc.
DATA: ls_zcbb_bukf_kfdsrc   TYPE /thkr/kf_kfdsrc.                   " zcbb_bukf_kfdsrc.


DATA: lv_rcvrgrp_9_9h TYPE /thkr/dtel_fmce_cvrgrp_9h.  " zdebb_fmce_cvrgrp_9h.
***DATA: lv_rcvrgrp_9_9i TYPE zdebb_fmce_cvrgrp_9i.


DATA: ls_g_t_fieldcat LIKE LINE OF g_t_fieldcat.

" Selektion Geschäftsjahr von
DATA: lv_pgjahr LIKE fmtox-gjahr.
DATA: l_hamount LIKE g_t_item-payment.


*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsstellen, Fonds
* Fonds
DATA:  ls_ffnd TYPE ffnd.
DATA:  lt_ffnd TYPE STANDARD TABLE OF ffnd.

* Haushaltsprogramm
DATA:  ls_fmas TYPE fmas.
DATA:  lt_fmas TYPE STANDARD TABLE OF fmas.

DATA:  lv_ffnd TYPE flag.
DATA:  lv_fmas TYPE flag.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
*--- Selection Screen Definition

SELECT-OPTIONS: s_potyp FOR fmaa_ba-potyp
                        NO-DISPLAY.

* "/ Parameter for display variant
SELECTION-SCREEN BEGIN OF BLOCK dispvar WITH FRAME TITLE TEXT-100.
  PARAMETERS: p_disvar   LIKE  disvariant-variant DEFAULT '/TÜ' OBLIGATORY.
SELECTION-SCREEN END   OF BLOCK dispvar.
************************************************************************



*---------------------------------------------------------------------*
*      INITIALIZATION                                                 *
*---------------------------------------------------------------------*
INITIALIZATION.
* "/ Modifikation des Selektionsbildes

* "/ Initialisierungsroutine der dynamischen HHStelle.
  PERFORM init_dyn_hhst.
*--------------------------------------------------------------------*




*---------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
*---------------------------------------------------------------------

* Logische Datenbank
*   include DBFMBSEL

* Selections not displayed on the screen
  LOOP AT SCREEN.
    IF screen-group1 = 'FIK'.

      IF screen-group3 = 'TOT'
      OR screen-group3 = 'HGH'
      OR screen-group3 = 'VPU'.
*       "/ No High range and multiple selection for Fikrs
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.


      IF screen-group3 = 'LOW'.
*       "/ No High range and multiple selection for Fikrs
        screen-required = 1.
        MODIFY SCREEN.
      ENDIF.

    ENDIF.


    IF screen-group1 = 'LV1'
    OR screen-group1 = 'LV2'
    OR screen-group1 = 'LV3'.
*       "/ No Level radio buttons
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.


    IF screen-group1 = 'TCM'
    OR screen-group1 = 'TUS'
    OR screen-group1 = 'TCO'
    OR screen-group1 = 'TBA'
    OR screen-group1 = 'TPA'.
*       "/ No 'Type of AA address' radio buttons
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.


    IF screen-group1 = 'LDG'.
*       "/ No AVC ledger
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.


    IF screen-group1 = 'FDR'.
*       "/ No cover pool
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.


*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsprogramm, Fonds
*   "/ Gruppe der Fonds ausschalten
    IF screen-group1 = 'FIC'.
      IF screen-group2 = 'DBS'.
        IF screen-group3 = 'PAR' OR screen-group3 = 'COF'.
          IF screen-group4 = '060'.
            screen-active = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF. " IF screen-group1 = 'FIC'.


*   "/ Gruppe der Fonds ausschalten
    IF screen-group1 = 'MAS'.
      IF screen-group2 = 'DBS'.
        IF screen-group3 = 'PAR' OR screen-group3 = 'COF'.
          IF screen-group4 = '129'.
            screen-active = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF. " IF screen-group1 = 'FIC'.

*   "/ Gruppe der Finanzstellen ausschalten
    IF screen-group1 = 'FST'.
      IF screen-group2 = 'DBS'.
        IF    screen-group4 = '081'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDIF. " IF screen-group1 = 'FST'.

*   "/ Gruppe der Finanzposition ausschalten
    IF screen-group1 = 'FPX'.
      IF screen-group2 = 'DBS'.
        IF    screen-group4 = '101'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDIF. " IF screen-group1 = 'FPX'.

*   "/ Fiscal year of commitment items
*   Geschäftsjahr der Verpflichtungspositionen
**    IF screen-group1 = 'FVJ'.
**      screen-active = 0.
**      MODIFY SCREEN.
**    ENDIF. " IF screen-group1 = 'FVJ'.

*   "/ Commitment item variant
*   Variante der Verpflichtungspositionen
    IF screen-group1 = 'FVA'.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF. " IF screen-group1 = 'FVA'.

*---    DS 20210830
    IF screen-group1 = 'BCT'    " Budget category
    OR screen-group1 = 'BTY'.   "  Budget type
*       "/ no Budget category +  Budget type
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
* Budgetversion - Budget version
    IF screen-group1 = 'BVS'.
*      "/ No Budget version
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF. " IF screen-group1 = 'VBS'.

* Werttype - Value type
    IF screen-group1 = 'VTY'.
*      "/ No Value type high range
***      IF screen-group3 = 'TOT'
***      OR screen-group3 = 'HGH'
***      OR screen-group3 = 'VPU'.
*      "/ No High range and multiple selection for Fikrs
      screen-active = 0.
      MODIFY SCREEN.
***      ENDIF.
    ENDIF. " IF screen-group1 = 'VTY'.

    IF screen-group1 = 'PRC'.
*       "/ No Process
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.

    IF screen-group1 = 'DTY'.
*       "/ No Document type
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.

    IF screen-group1 = 'STA'.
*       "/ No P_STAMM
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.

*--------------------------------------------------------------------*
* GJAHR -
* entweder hier ausblenden und das "Jahr bis" vorbelegen, oder einblenden

***    IF screen-group1 = 'FYR'.
****      "/ No GJAHR high range
***      IF screen-group2 = 'DBS'.
***        IF screen-group4 = '154'.
***          screen-active = 0.
***          MODIFY SCREEN.
***        ENDIF.
***      ENDIF.
***    ENDIF. " IF screen-group1 = 'FYR'.
*--------------------------------------------------------------------*

* Geschäftsjahr - Perioden geöffnet
    IF screen-group1 = 'PER'.
*       "/ No Periods
***      screen-active = 0.    " DS 20210830 - Periode kann geöffnet werden
      MODIFY SCREEN.
    ENDIF.

    IF screen-group1 = 'OP1'
    OR screen-group1 = 'OPT'.
*       "/ No P_MAXSEL
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP. "   LOOP AT SCREEN.

  " DS20210922 aus SAPDBFMB - ca.Zeile 332 ff.
* Inaktivieren Druck und Hintergrundsverarbeitung auf Selektionsbild
  PERFORM insert_into_excl IN PROGRAM rsdbrunt USING 'DYNS'.  " freie Abgrenzungen ausblenden
  PERFORM insert_into_excl IN PROGRAM rsdbrunt USING 'FC01'. "  "/ Classification
  PERFORM insert_into_excl IN PROGRAM rsdbrunt USING 'FC02'. "  "/ Hidden selection crit.
  PERFORM insert_into_excl IN PROGRAM rsdbrunt USING 'FC05'. "  "/ Selection of datasources.
*--------------------------------------------------------------------*

*-----------------------------------------------------------------------
AT SELECTION-SCREEN.
*-----------------------------------------------------------------------
  CHECK sscrfields-ucomm = 'ONLI' OR
        sscrfields-ucomm = 'PRIN'.

  PERFORM manipulate_selection_values.
*--------------------------------------------------------------------*

*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_disvar.
*-----------------------------------------------------------------------
* Read display variants
  PERFORM f4_display_variant.
*--------------------------------------------------------------------*

*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON BLOCK dispvar.
*-----------------------------------------------------------------------
* Check if display variant exists
  PERFORM check_display_variant.
*--------------------------------------------------------------------*

*-----------------------------------------------------------------------
START-OF-SELECTION.
*-----------------------------------------------------------------------

*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsprogramm, Fonds
  REFRESH: lt_ffnd, lt_fmas.
*--------------------------------------------------------------------*


  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      text = 'Standardwerte holen'(d01).


*  "/ Initialize Schedman monitor
  PERFORM init_schedman.

*  "/ Flags fuer LDB und Vorzeichen setzen
  PERFORM set_flags.

*  "/ Defaultwerte holen
  PERFORM  get_defaults.


* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* DS TODO
* Performance-Steigerung
* Anzeigevariante ermitteln -> Ergebnis: Welche Kennzahlen müssen berechnet werden?
* nur angefragte Kennzahlen berechnen
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*--- neu: Ermittlung der Kennzahlen ---*
**** "/ Selektionskriterien ermitteln
***  PERFORM get_selcrit TABLES g_t_selcrit.


**** "/ Kennzahlen initialisieren
***  PERFORM init_keyfigures TABLES g_t_selcrit
***                           USING p_pgjahr
***                                 vari-variant
***                                 '10'.

*** Keep all selections for resetting afterwards:
  FINAL(bu_fonds)    = s_fonds.
  FINAL(bu_fictr)   = s_fictr.
  FINAL(bu_keydate) = p_kdate.
  FINAL(bu_fipex)   = s_fipex.
  FINAL(bu_farea)   = s_farea.
  FINAL(bu_hhm)     = s_meas.




*-----------------------------------------*
*-- Referenzjahr für die Generierung der Kennzahlen
*   aus Selektionsoptionen belegen ---*
*-----------------------------------------*
  lv_pgjahr = p_fyr_fr. " Selektion Geschäftsjahr von



*-----------------------------------------*

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      text = 'Kennzahlen initialisieren'(d02).

* / Kennzahlen initialisieren - Kurzversion
  PERFORM init_keyfigures USING lv_pgjahr.


* "/ Initialisierungsroutine der dynamischen HHStelle.
  "  Entnommen aus RFFMKBHH , Zeile 6 + 141
  PERFORM init_dyn_hhst.
*--------------------------------------*




*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      text = 'Werte lesen'(d03).


*--- Finanzkreis
* Read FM area from FMB
GET fkrs FIELDS fikrs waers.
  REFRESH g_t_master_data.
  g_f_header-fwaer = fkrs-waers.


*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsprogramm, Fonds
*-- Fonds
GET ffnd.
  CLEAR: ls_ffnd.
  MOVE-CORRESPONDING ffnd TO ls_ffnd.
  COLLECT ls_ffnd INTO lt_ffnd.
  SORT lt_ffnd BY fincode.
*--------------------------------------------------------------------*

*--- Finanzstellen
GET fctr.
  CLEAR: ls_fctr.
  MOVE-CORRESPONDING fctr TO ls_fctr.
  COLLECT ls_fctr INTO lt_fctr.
  SORT lt_fctr BY fictr.

** Performance is completly bad for > 50k entries: Replacment with direct DB call:
** Just the hierarchy part is missing, must be added if required!
*--- Finanzpositionen
*GET fpos.
*  CLEAR: ls_fpos.
*  MOVE-CORRESPONDING fpos TO ls_fpos.
*  COLLECT ls_fpos INTO lt_fpos.
*  SORT lt_fpos BY fipex.
  IF lt_fpos IS INITIAL.
    SELECT FROM fmci AS f
          INNER JOIN fmcit AS t ON t~spras = @sy-langu
                               AND t~fikrs = f~fikrs
                               AND t~gjahr = f~gjahr
                               AND f~fipex = t~fipex
      FIELDS *
      WHERE f~gjahr = @lv_pgjahr
      ORDER BY f~fipex
      INTO CORRESPONDING FIELDS OF TABLE @lt_fpos.
  ENDIF.


*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsprogramm, Fonds
*-- Haushaltsprogramm
GET fmas.
  CLEAR: ls_fmas.
  MOVE-CORRESPONDING fmas TO ls_fmas.
  ls_fmas-fmarea = fkrs-fikrs.          " Finanzkreis eintragen, da leer (wichtig für die Selektion der Belege)
  COLLECT ls_fmas INTO lt_fmas.

  SORT lt_fmas BY fmarea
                  measure.
*--------------------------------------------------------------------*

* Orig
*-- Stammdaten ---
***GET fmaa_ba.
***  CLEAR g_t_master_data.
***  MOVE-CORRESPONDING fmaa_ba TO g_t_master_data.
***  COLLECT g_t_master_data.

*--------------------------------------------------------------------*
***GET fmaa_pa.
***  CLEAR g_t_master_data.
***  MOVE-CORRESPONDING fmaa_pa TO g_t_master_data.
***  COLLECT g_t_master_data.
*--------------------------------------------------------------------*

* Budget- / Planversion
GET bvsn.


*--------------------------------------------------------------------*
* AVK-Summen (BCS)
GET avct.
* Die AVCT Werte werden aus der logischen Datenbank nicht richtig übergeben
* Es ist daher notwendig, die Werte selbst zu holen.
  DATA: ls_avct_da TYPE  avct.
  FIELD-SYMBOLS <avct> TYPE ANY TABLE.

  ASSIGN ('(SAPDBZBCS_FMB)G_T_AVCT[]') TO <avct>.

  LOOP AT <avct> INTO ls_avct_da.
    COLLECT ls_avct_da INTO g_t_avct.
  ENDLOOP.



  CLEAR: lv_rcvrgrp_9_9h.
**       lv_rcvrgrp_9_9i.


  LOOP AT <avct> INTO ls_avct_da.



*-- Stammdatenprüfung
    CLEAR: ls_fctr.
    CLEAR: lv_fctr.
    READ TABLE lt_fctr INTO ls_fctr WITH KEY fictr     = ls_avct_da-rfundsctr   " Finanzstelle
    BINARY SEARCH.
    IF sy-subrc = 0.
      lv_fctr = 'X'.
    ENDIF.


    CLEAR: ls_fpos.
    CLEAR: lv_fpos.
    READ TABLE lt_fpos INTO ls_fpos WITH KEY fipex     = ls_avct_da-rcmmtitem  " Finanzposition
    BINARY SEARCH.
    IF sy-subrc = 0.
      lv_fpos = 'X'.
    ENDIF.


*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsprogramm, Fonds
    CLEAR: ls_ffnd.
    CLEAR: lv_ffnd.
    READ TABLE lt_ffnd INTO ls_ffnd WITH KEY fincode     = ls_avct_da-rfund   " Fonds
    BINARY SEARCH.
    IF sy-subrc = 0.
      lv_ffnd = 'X'.
    ENDIF.


    CLEAR: ls_fmas.
    CLEAR: lv_fmas.
    READ TABLE lt_fmas INTO ls_fmas WITH KEY  fmarea    = ls_avct_da-rfikrs   "  Finanzkreis
                                              measure   = ls_avct_da-rmeasure "  Haushaltsprogramm
    BINARY SEARCH.
    IF sy-subrc = 0.
      lv_fmas = 'X'.
    ENDIF.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsprogramm, Fonds
***    IF lv_fctr = 'X' AND lv_fpos = 'X'.  " nur wenn die Berechtigung vorliegt, dürfen Werte verwendet werden.
    IF lv_fctr = 'X' AND lv_fpos = 'X' AND lv_ffnd = 'X' AND lv_fmas = 'X'.  " nur wenn die Berechtigung vorliegt, dürfen Werte verwendet werden.
*--------------------------------------------------------------------*


*-- Ende Stammdatenprüfung  -----*




*    Nutzung der Daten und füllen der Felder der Struktur
*    Schlüssel für Tabelle setzen
      CLEAR g_t_itab.
      g_t_itab-fikrs = fkrs-fikrs.              " Finanzkreis
      g_t_itab-fipex = ls_avct_da-rcmmtitem.    " Finanzposition
      g_t_itab-fictr = ls_avct_da-rfundsctr.    " Finanzstelle
      g_t_itab-fonds = ls_avct_da-rfund.        " Fond
      g_t_itab-farea = ls_avct_da-rfuncarea.    " Funktionsbereich

*--------------------------------------------------------------------*
*     DS20230308 - Anpassung Haushaltsprogramm, Fonds
      g_t_itab-rmeasure = ls_avct_da-rmeasure.  " Haushaltsprogramm
*      g_t_itab-rcvrgrp_9_9h = ls_avct_da-rcvrgrp_9.
*--------------------------------------------------------------------*
*
** hier kommen alle Werte für die Selektion an
*      " Deckungsgruppe 9H - Zahlungsbudget
*      IF ls_avct_da-rldnr = '9H' AND ls_avct_da-ryear = lv_pgjahr AND ls_avct_da-rcvrgrp_9 IS NOT INITIAL.
*
****      IF   lv_rcvrgrp_9_9h IS INITIAL. " Wenn leer, dann zuweisen
****        lv_rcvrgrp_9_9h =  ls_avct_da-rcvrgrp_9.
****      ELSE.
****        " Prüfung, ob Wert nicht identisch
****        IF lv_rcvrgrp_9_9h <>  ls_avct_da-rcvrgrp_9.
****          lv_rcvrgrp_9_9h = '*'.
****        ENDIF.
****      ENDIF.
*
*
*        ls_g_t_deckungsgrp-rfundsctr     = ls_avct_da-rfundsctr.  " Finanzstelle
*        ls_g_t_deckungsgrp-rcmmtitem     = ls_avct_da-rcmmtitem.  " Finanzposition
*        ls_g_t_deckungsgrp-rldnr         = ls_avct_da-rldnr.      " Ledger
*        ls_g_t_deckungsgrp-ryear         = ls_avct_da-ryear.      " Geschäftsjahr
*        ls_g_t_deckungsgrp-rcvrgrp_9_9h  = ls_avct_da-rcvrgrp_9.  " Deckungsgruppe
*
*        READ TABLE g_t_deckungsgrp WITH KEY rfundsctr = ls_avct_da-rfundsctr
*                                            rcmmtitem = ls_avct_da-rcmmtitem
*                                            rldnr     = ls_avct_da-rldnr
*                                            ryear     = ls_avct_da-ryear
*                                            BINARY SEARCH.
*        CLEAR: lv_index_dgrp.
*        lv_index_dgrp = sy-tabix.
*        IF sy-subrc = 0.
*
*          MODIFY g_t_deckungsgrp FROM ls_g_t_deckungsgrp INDEX lv_index_dgrp TRANSPORTING rcvrgrp_9_9h .
*
*        ELSE.
*          APPEND ls_g_t_deckungsgrp TO g_t_deckungsgrp.
*          SORT  g_t_deckungsgrp.
*        ENDIF.
*
*
*      ENDIF. " IF ls_avct_da-rldnr = '9H' AND ls_avct_da-ryear = lv_pgjahr.
*
*
****    " Deckungsgruppe 9I - Verpflichtungsbudget
****    IF ls_avct_da-rldnr = '9I' AND ls_avct_da-ryear = lv_pgjahr.
****
****      IF   lv_rcvrgrp_9_9i IS INITIAL. " Wenn leer, dann zuweisen
****        lv_rcvrgrp_9_9i =  ls_avct_da-rcvrgrp_9.
****      ELSE.
****        " Prüfung, ob Wert nicht identisch
****        IF lv_rcvrgrp_9_9i <>  ls_avct_da-rcvrgrp_9.
****          lv_rcvrgrp_9_9i = '*'.
****        ENDIF.
***      ENDIF.
***
***    ENDIF. " IF ls_avct_da-rldnr = '9H' AND ls_avct_da-ryear = lv_pgjahr.


*   Berechnung der Werte über Kennzahlen
      PERFORM change_value USING    fmkf_fmavct
                                    ls_avct_da
                           CHANGING g_t_itab.

*   Aggregation in der Zieltabelle
      COLLECT g_t_itab.

*   Stammdaten sammeln
      CLEAR: ls_masterdata_bcs.
      ls_masterdata_bcs-fonds     = ls_avct_da-rfund.     " Fond
      ls_masterdata_bcs-fipex     = ls_avct_da-rcmmtitem. " Finanzposition
      ls_masterdata_bcs-fictr     = ls_avct_da-rfundsctr. " Finanzstelle
*--------------------------------------------------------------------*
*     DS20230308 - Anpassung Haushaltsprogramm, Fonds
      ls_masterdata_bcs-measure  = ls_avct_da-rmeasure.   " Haushaltsprogramm
*--------------------------------------------------------------------*

      COLLECT ls_masterdata_bcs INTO lt_masterdata_bcs.


    ENDIF. " IF lv_fctr = 'X' AND lv_fpos = 'X'.

  ENDLOOP. "  LOOP AT <avct> INTO ls_avct_da.


* dann Tabelle leeren
  REFRESH <avct>.
*--------------------------------------------------------------------*


* Budget Line items - Budgetsummen (BCS)
GET budt.
*--------------------------------------------------------------------*
* DS 20210503 - für Fehleranalyse
  MOVE-CORRESPONDING budt TO g_t_budt.
  COLLECT g_t_budt.
*--------------------------------------------------------------------*


*-- Stammdatenprüfung
  CLEAR:  ls_fctr.
  CLEAR:  lv_fctr.
  READ TABLE lt_fctr INTO ls_fctr WITH KEY  fictr  = budt-rfundsctr
    BINARY SEARCH.
  IF sy-subrc = 0.
    lv_fctr = 'X'.
  ENDIF.


  CLEAR: ls_fpos.
  CLEAR: lv_fpos.
  READ TABLE lt_fpos INTO ls_fpos WITH KEY  fipex  = budt-rcmmtitem
    BINARY SEARCH.
  IF sy-subrc = 0.
    lv_fpos = 'X'.
  ENDIF.

*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsprogramm, Fonds
  CLEAR: ls_ffnd.
  CLEAR: lv_ffnd.
  READ TABLE lt_ffnd INTO ls_ffnd WITH KEY fincode     = budt-rfund   " Fonds
  BINARY SEARCH.
  IF sy-subrc = 0.
    lv_ffnd = 'X'.
  ENDIF.


  CLEAR: ls_fmas.
  CLEAR: lv_fmas.
  READ TABLE lt_fmas INTO ls_fmas WITH KEY  fmarea    = budt-rfikrs    " Finanzkreis
                                            measure   = budt-rmeasure  " Haushaltsprogramm
  BINARY SEARCH.
  IF sy-subrc = 0.
    lv_fmas = 'X'.
  ENDIF.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsprogramm, Fonds
***    check lv_fctr = 'X' AND lv_fpos = 'X'.  " nur wenn die Berechtigung vorliegt, dürfen Werte verwendet werden.
  CHECK lv_fctr = 'X' AND lv_fpos = 'X' AND lv_ffnd = 'X' AND lv_fmas = 'X'.  " nur wenn die Berechtigung vorliegt, dürfen Werte verwendet werden.
*--------------------------------------------------------------------*

*-- Ende Stammdatenprüfung  -----*

*   Stammdaten sammeln
  CLEAR: ls_masterdata_bcs.
  ls_masterdata_bcs-fonds     = budt-rfund.       " Fond
  ls_masterdata_bcs-fipex     = budt-rcmmtitem.   " Finanzposition
  ls_masterdata_bcs-fictr     = budt-rfundsctr.   " Finanzstelle
*--------------------------------------------------------------------*
*     DS20230308 - Anpassung Haushaltsprogramm, Fonds
  ls_masterdata_bcs-measure   = budt-rmeasure.    " Haushaltsprogramm
*--------------------------------------------------------------------*

  COLLECT ls_masterdata_bcs INTO lt_masterdata_bcs.

*   Initialize (incl. Commt/Actuals amounts)
  CLEAR g_t_item.

*   Move budget data
  MOVE-CORRESPONDING budt TO g_t_item.
  g_t_item-rbudget_pd = cl_fm_budper_utilities_appl=>set_value_switched( budt-budget_pd_9 ).
  g_t_item-fikrs     =  budt-rfikrs.
  g_t_item-budcat    =  budt-rldnr.
  g_t_item-version   =  budt-rvers.
  g_t_item-fyear     =  budt-ryear.
  g_t_item-process   =  budt-process_9.
  g_t_item-budtype   =  budt-budtype_9.
  g_t_item-budget    =
  g_t_item-bud_pmt   =
  g_t_item-bud_inv   =
  g_t_item-rs_budget =  budt-hamount.
  g_t_item-fwaer     =  fkrs-waers.

  COLLECT g_t_item.

*--------------------------------------------------------------------*
*    Nutzung der Daten und füllen der Felder der Struktur
*    Schlüssel für Tabelle setzen

  CLEAR g_t_itab.

*  MOVE-CORRESPONDING budt TO g_t_itab.
  g_t_itab-fikrs = budt-rfikrs.
  g_t_itab-fipex = budt-rcmmtitem.
  g_t_itab-fictr = budt-rfundsctr.
  g_t_itab-fonds = budt-rfund.
  g_t_itab-farea = budt-rfuncarea.

*--------------------------------------------------------------------*
*     DS20230308 - Anpassung Haushaltsprogramm, Fonds
  g_t_itab-rmeasure   = budt-rmeasure.    " Haushaltsprogramm
*--------------------------------------------------------------------*


*   Berechnung der Werte über Kennzahlen
  PERFORM change_value USING    fmkf_fmbdt
                                budt
                       CHANGING g_t_itab.

*   Aggregation in der Zieltabelle
  COLLECT g_t_itab.
*--------------------------------------------------------------------*

* Commitment/Actual totals - Verfügte Werte (BCS)
GET conval.

*--------------------------------------------------------------------*
* DS 20210503 - für Fehleranalyse
  CLEAR: l_s_conval.
  MOVE-CORRESPONDING conval TO l_s_conval.
  l_s_conval-fikrs = fkrs-fikrs.
  COLLECT l_s_conval INTO  g_t_conval.
*--------------------------------------------------------------------*

*-- Stammdatenprüfung  -----*
  CLEAR:  ls_fctr.
  CLEAR:  lv_fctr.
  READ TABLE lt_fctr INTO ls_fctr WITH KEY  fictr     = l_s_conval-fictr
    BINARY SEARCH.
  IF sy-subrc = 0.
    lv_fctr = 'X'.
  ENDIF.

  CLEAR: ls_fpos.
  CLEAR: lv_fpos.
  READ TABLE lt_fpos INTO ls_fpos WITH KEY  fipex     = l_s_conval-fipex
    BINARY SEARCH.
  IF sy-subrc = 0.
    lv_fpos = 'X'.
  ENDIF.

*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsprogramm, Fonds
  CLEAR: ls_ffnd.
  CLEAR: lv_ffnd.
  READ TABLE lt_ffnd INTO ls_ffnd WITH KEY fincode     = l_s_conval-fonds   " Fonds
  BINARY SEARCH.
  IF sy-subrc = 0.
    lv_ffnd = 'X'.
  ENDIF.


  CLEAR: ls_fmas.
  CLEAR: lv_fmas.
  READ TABLE lt_fmas INTO ls_fmas WITH KEY  fmarea    = l_s_conval-fikrs    " Finanzkreis
                                            measure   = l_s_conval-measure  " Haushaltsprogramm
  BINARY SEARCH.
  IF sy-subrc = 0.
    lv_fmas = 'X'.
  ENDIF.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsprogramm, Fonds
***   check lv_fctr = 'X' AND lv_fpos = 'X'.  " nur wenn die Berechtigung vorliegt, dürfen Werte verwendet werden.
  CHECK lv_fctr = 'X' AND lv_fpos = 'X' AND lv_ffnd = 'X' AND lv_fmas = 'X'.  " nur wenn die Berechtigung vorliegt, dürfen Werte verwendet werden.
*--------------------------------------------------------------------*

*-- Ende Stammdatenprüfung  -----*

*   Stammdaten sammeln
  CLEAR: ls_masterdata_bcs.
  ls_masterdata_bcs-fonds     = l_s_conval-fonds.         " Fond
  ls_masterdata_bcs-fipex     = l_s_conval-fipex.         " Finanzposition
  ls_masterdata_bcs-fictr     = l_s_conval-fictr.         " Finanzstelle
*--------------------------------------------------------------------*
*     DS20230308 - Anpassung Haushaltsprogramm, Fonds
  ls_masterdata_bcs-measure   = l_s_conval-measure.       " Haushaltsprogramm
*--------------------------------------------------------------------*

  COLLECT ls_masterdata_bcs INTO lt_masterdata_bcs.

*   Initialize (incl. budget related fields)
  CLEAR g_t_item.
  CLEAR l_hamount.

  IF conval-fkbtrp <> 0.
    IF con_payment IN s_budcat.
*       Only if payment budget fits to sel.criteria
      l_hamount = conval-fkbtrp.
      g_t_item-budcat = con_payment.
    ENDIF.
  ELSEIF conval-fkbtrc <> 0.
    IF con_cmmtitem IN s_budcat.
*       Only if comitment budget fits to sel.criteria
      l_hamount = conval-fkbtrc.
      g_t_item-budcat = con_cmmtitem.
    ENDIF.
  ELSE.
*     Reject workflow CO ledgers (9C, 9D) from processing
  ENDIF.

  CHECK l_hamount <> 0.

*   Get displayed sign of Commitment line items
  PERFORM set_sign_actuals_rep
    USING    g_t_master_data-potyp
    CHANGING l_hamount.

*   Distinguish Commitment totals via Value type
  CASE conval-wrttp.
    WHEN wrttp9
      OR wrttpzu
      OR wrttp3
      OR wrttp9a
      OR wrttpfco.
      g_t_item-payment = l_hamount.
    WHEN wrttp6
      OR wrttp7a.
      g_t_item-invoice = l_hamount.
    WHEN OTHERS.
      g_t_item-opitems = l_hamount.
  ENDCASE.

  g_t_item-bud_pmt   =  - g_t_item-payment.
  g_t_item-bud_inv   =  - g_t_item-invoice - g_t_item-payment.
  g_t_item-rs_budget =  - g_t_item-invoice - g_t_item-payment - g_t_item-opitems.

*   Move further Commitment total data (incl. master data)
  g_t_item-rgrant_nbr = conval-grant_nbr.
  g_t_item-rfund      = conval-fonds.
  g_t_item-rbudget_pd = cl_fm_budper_utilities_appl=>set_value_switched( conval-budget_pd ).
  g_t_item-rfundsctr  = conval-fictr.
  g_t_item-rcmmtitem  = conval-fipex.
  g_t_item-rfuncarea  = conval-farea.
  g_t_item-rmeasure   = conval-measure.
  g_t_item-fyear      = conval-gjahr.
  g_t_item-fikrs      = fkrs-fikrs.
  g_t_item-fwaer      = fkrs-waers.
  g_t_item-version    = '000'.

  COLLECT g_t_item.

*--------------------------------------------------------------------*
* DS 20210503 - -> Fehler in der logischen Datenbank
* Summensätze: Obligo und Ist
GET fmtox.

*--------------------------------------------------------------------*
* DS 20210503 - für Fehleranalyse
  MOVE-CORRESPONDING fmtox TO l_s_fmtox.
  l_s_fmtox-fikrs = fkrs-fikrs.
  COLLECT l_s_fmtox INTO g_t_fmtox.
*--------------------------------------------------------------------*

*-- Stammdatenprüfung
  CLEAR: ls_fctr.
  CLEAR: lv_fctr.
  READ TABLE lt_fctr INTO ls_fctr WITH KEY fictr     = l_s_fmtox-fictr       " Finanzstelle
    BINARY SEARCH.
  IF sy-subrc = 0.
    lv_fctr = 'X'.
  ENDIF.

  CLEAR: ls_fpos.
  CLEAR: lv_fpos.
  READ TABLE lt_fpos INTO ls_fpos WITH KEY fipex     = l_s_fmtox-fipex       " Finanzposition
    BINARY SEARCH.
  IF sy-subrc = 0.
    lv_fpos = 'X'.
  ENDIF.

*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsprogramm, Fonds
  CLEAR: ls_ffnd.
  CLEAR: lv_ffnd.
  READ TABLE lt_ffnd INTO ls_ffnd WITH KEY fincode     = l_s_fmtox-fonds   " Fonds
  BINARY SEARCH.
  IF sy-subrc = 0.
    lv_ffnd = 'X'.
  ENDIF.

  CLEAR: ls_fmas.
  CLEAR: lv_fmas.
  READ TABLE lt_fmas INTO ls_fmas WITH KEY  fmarea    = l_s_fmtox-fikrs    "  Finanzkreis
                                            measure   = l_s_fmtox-measure  "  Haushaltsprogramm
  BINARY SEARCH.
  IF sy-subrc = 0.
    lv_fmas = 'X'.
  ENDIF.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsprogramm, Fonds
***    check lv_fctr = 'X' AND lv_fpos = 'X'.  " nur wenn die Berechtigung vorliegt, dürfen Werte verwendet werden.
  CHECK lv_fctr = 'X' AND lv_fpos = 'X' AND lv_ffnd = 'X' AND lv_fmas = 'X'.  " nur wenn die Berechtigung vorliegt, dürfen Werte verwendet werden.
*--------------------------------------------------------------------*


*-- Ende Stammdatenprüfung  -----*

*   Stammdaten sammeln
  CLEAR: ls_masterdata_bcs.
  ls_masterdata_bcs-fonds     = l_s_fmtox-fonds.       " Fonds
  ls_masterdata_bcs-fipex     = l_s_fmtox-fipex.       " Finanzposition
  ls_masterdata_bcs-fictr     = l_s_fmtox-fictr.       " Finanzstelle
*--------------------------------------------------------------------*
*     DS20230308 - Anpassung Haushaltsprogramm, Fonds
  ls_masterdata_bcs-measure  = l_s_fmtox-measure.   " Haushaltsprogramm
*--------------------------------------------------------------------*

  COLLECT ls_masterdata_bcs INTO lt_masterdata_bcs.


* Schlüssel für Tabelle setzen
  CLEAR g_t_itab.
  g_t_itab-fikrs = fkrs-fikrs.            " Finanzkreis
  g_t_itab-fipex = l_s_fmtox-fipex.       " Finanzposition
  g_t_itab-fictr = l_s_fmtox-fictr.       " Finanzstelle
  g_t_itab-fonds = l_s_fmtox-fonds.       " Fonds
  g_t_itab-farea = l_s_fmtox-farea.       " Funktionsbereich
*--------------------------------------------------------------------*
*     DS20230308 - Anpassung Haushaltsprogramm, Fonds
  g_t_itab-rmeasure = l_s_fmtox-measure.  " Haushaltsprogramm
*--------------------------------------------------------------------*


* Berechnung der Werte über Kennzahlen - Logik aus RFFMKBHH
  PERFORM change_value USING    fmkf_fmtox
                                fmtox
                       CHANGING g_t_itab.

* Aggregation in der Zieltabelle
  COLLECT g_t_itab.



GET fkrs LATE.


  SORT g_t_item BY  rgrant_nbr
                    rfund rbudget_pd
                    rfundsctr
                    rcmmtitem
                    rfuncarea
                    rmeasure
                    budcat
                    version
                    fyear
                    process
                    budtype.

* DS2021 ToDo: Sortierung der Tabelle g_t_itab. notwendig ??????
  SORT g_t_itab.
*-----------------------------------------------------------------------
END-OF-SELECTION.
*-----------------------------------------------------------------------

*--------------------------------------------------------------------*
* Finale Stammdatentabelle vorbereiten
*--------------------------------------------------------------------*

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      text = 'Stammdaten aufbereiten'(d04).


  SORT lt_masterdata_bcs.

  REFRESH: g_t_master_data.
  LOOP AT lt_masterdata_bcs INTO ls_masterdata_bcs.

*-- Stammdatenanreicherung

*--------------------------------------------------------------------*
*     DS20230308 - Anpassung Haushaltsprogramm, Fonds
*  Nachlesen
    CLEAR: ls_ffnd.
    READ TABLE lt_ffnd INTO ls_ffnd WITH KEY fincode     = ls_masterdata_bcs-fonds   " Fonds
    BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_ffnd TO ls_g_t_master_data.

      ls_g_t_master_data-fonds = ls_ffnd-fincode.

    ENDIF.


    CLEAR: ls_fmas.
    READ TABLE lt_fmas INTO ls_fmas WITH KEY
*                                             fmarea    = ls_avct_da-RFIKRS           "  Finanzkreis
                                              measure   = ls_masterdata_bcs-measure   "  Haushaltsprogramm
    BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_fmas TO ls_g_t_master_data.
      ls_g_t_master_data-me_short_desc   = ls_fmas-short_desc.
      ls_g_t_master_data-me_description  = ls_fmas-description.

      ls_g_t_master_data-me_valid_from  = ls_fmas-valid_from.
      ls_g_t_master_data-me_valid_to    = ls_fmas-valid_to.
      ls_g_t_master_data-me_authgrp     = ls_fmas-authgrp.

    ENDIF.
*--------------------------------------------------------------------*


    CLEAR:  ls_fctr.
    READ TABLE lt_fctr INTO ls_fctr WITH KEY fictr     = ls_masterdata_bcs-fictr       " Finanzstelle
      BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_fctr TO ls_g_t_master_data.
    ENDIF.


    CLEAR: ls_fpos.
    READ TABLE lt_fpos INTO ls_fpos WITH KEY fipex     = ls_masterdata_bcs-fipex       " Finanzposition
      BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_fpos TO ls_g_t_master_data.
      ls_g_t_master_data-augrp_fipex = ls_fpos-augrp.
    ENDIF.


    ls_g_t_master_data-fonds    = ls_masterdata_bcs-fonds.
    ls_g_t_master_data-fictr    = ls_masterdata_bcs-fictr.
    ls_g_t_master_data-fipex    = ls_masterdata_bcs-fipex.
*--------------------------------------------------------------------*
*     DS20230308 - Anpassung Haushaltsprogramm, Fonds
    ls_g_t_master_data-measure  = ls_masterdata_bcs-measure.
*--------------------------------------------------------------------*

    APPEND ls_g_t_master_data TO g_t_master_data.

    CLEAR: ls_masterdata_bcs, ls_g_t_master_data.
  ENDLOOP. " LOOP AT lt_masterdata_bcs INTO ls_masterdata_bcs.
*--------------------------------------------------------------------*
* Ende: Finale Stammdatentabelle vorbereiten
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
*  Finanzpositionsdaten nachlesen und Kennzeichen drehen
*--------------------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      text = 'Daten anteichern + Kennzeichen drehen'(d05).

  PERFORM set_fipex_element TABLES g_t_itab.
*--------------------------------------------------------------------*
*  Ende: Finanzpositionsdaten nachlesen
*--------------------------------------------------------------------*

** Read information about cover groups:
  SELECT FROM /thkr/bcs_cvgrp_desc
    FIELDS *
    FOR ALL ENTRIES IN @g_t_item
    WHERE fund      = @g_t_item-rfund
      AND cmmtitem  = @g_t_item-rcmmtitem
      AND fundsctr  = @g_t_item-rfundsctr
      AND budgetcat = @g_t_item-budcat
    INTO TABLE @DATA(cvgrps).

*--------------------------------------------------------------------*
* Zusammenfassung und Neuberechnung der Werte
*--------------------------------------------------------------------*

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      text = 'Weitere Kennzahlen berechnen '(d06).

  "** CUSTOM CODING
**********************************************************************
  LOOP AT g_t_itab ASSIGNING FIELD-SYMBOL(<line>).
**********************************************************************
** Übernahme
    <line>-farea = <line>-uabsch.
** Map values to leading number for sorting reasons
    CASE <line>-zz_funddistr_lvl.
      WHEN 'BFH'.
        <line>-zz_funddistr_lvl = '2BF'.
      WHEN 'MFH'.
        <line>-zz_funddistr_lvl = '1MF'.
    ENDCASE.

    <line>-untergrp =  <line>-fipex+4(3).
    <line>-obergrp  =  <line>-fipex+4(2).
**********************************************************************
** Berechnete Spalten
    <line>-ve_verfuegsoll = abs( <line>-ve_lasthhj_1 + <line>-ve_lasthhj_2 + <line>-ve_lasthhj_3 + <line>-ve_lasthhj_4 + <line>-ve_lasthhj_5f + <line>-ve_lasthhj_6 + <line>-ve_lasthhj_7 + <line>-ve_lasthhj_8 +
      <line>-ve_lasthhj_9 + <line>-ve_lasthhj_10f ).
    <line>-ve_verteilt = abs( <line>-ve_vertlt_hhj_1 + <line>-ve_vertlt_hhj_2 + <line>-ve_vertlt_hhj_3 + <line>-ve_vertlt_hhj_4 + <line>-ve_vertlt_hhj5f + <line>-ve_vertlt_hhj_6 + <line>-ve_vertlt_hhj_7 + <line>-ve_vertlt_hhj_8 +
      <line>-ve_vertlt_hhj_9 + <line>-ve_vertlt_hhj10 ).
    <line>-ve_hhplan = abs( <line>-ve_hhplan_hhj_1 + <line>-ve_hhplan_hhj_2 + <line>-ve_hhplan_hhj_3 + <line>-ve_hhplan_hhj_4 + <line>-ve_hhplan_hhj5f + <line>-ve_hhplan_hhj_6 + <line>-ve_hhplan_hhj_7 + <line>-ve_hhplan_hhj_8 +
      <line>-ve_hhplan_hhj_9 + <line>-ve_hhplan_hhj10 ).
    <line>-soll_gesamt    = abs( <line>-zb_hhsoll + <line>-zb_verfuegbar ).
    <line>-dif_kasse_ist  = abs( <line>-zb_hhsoll - <line>-mb ).
    <line>-diff_ist       = abs( <line>-soll_gesamt - <line>-ist_gesamt ).
    <line>-diff_offen     = abs( <line>-zb_hhsoll - <line>-ist_gesamt ).

*********************************************************************
** Immer abs. Wert AUßER bei Typ Ausgabe!!
    <line>-ve_nverfb_hhj_1 = <line>-ve_lasthhj_1 - <line>-ve_inansp_hhj1.
    <line>-ve_nverfb_hhj_2 = <line>-ve_lasthhj_2 - <line>-ve_inansp_hhj2.
    <line>-ve_nverfb_hhj_3 = <line>-ve_lasthhj_3 - <line>-ve_inansp_hhj3.
    <line>-ve_nverfb_hhj_4 = <line>-ve_lasthhj_4 - <line>-ve_inansp_hhj4.
    <line>-ve_nverfb_hhj5f = <line>-ve_lasthhj_5f - <line>-ve_inansp_hhj5.
    <line>-ve_nverfb_hhj_6 = <line>-ve_lasthhj_6 - <line>-ve_inansp_hhj6.
    <line>-ve_nverfb_hhj_7 = <line>-ve_lasthhj_7 - <line>-ve_inansp_hhj7.
    <line>-ve_nverfb_hhj_8 = <line>-ve_lasthhj_8 - <line>-ve_inansp_hhj8.
    <line>-ve_nverfb_hhj_9 = <line>-ve_lasthhj_9 - <line>-ve_inansp_hhj9.
    <line>-ve_nverfb_hhj10 = <line>-ve_lasthhj_10f - <line>-ve_inansp_hhj10.

    <line>-ve_noch_verfgba  = <line>-ve_nverfb_hhj_1 + <line>-ve_nverfb_hhj_2 + <line>-ve_nverfb_hhj_3 + <line>-ve_nverfb_hhj_4 + <line>-ve_nverfb_hhj5f + <line>-ve_nverfb_hhj_6 + <line>-ve_nverfb_hhj_7 + <line>-ve_nverfb_hhj_8 + <line>-ve_nverfb_hhj_9
      + <line>-ve_nverfb_hhj10.
    <line>-ve_inansp_stat   = <line>-ve_inansta_hhj1 + <line>-ve_inansta_hhj2 + <line>-ve_inansta_hhj3 + <line>-ve_inansta_hhj4 + <line>-ve_inanstahhj5f + <line>-ve_inansta_hhj6 + <line>-ve_inansta_hhj7 + <line>-ve_inansta_hhj8 + <line>-ve_inansta_hhj9
      + <line>-ve_inanstahhj10.
    <line>-zb_diffhh_soll   = <line>-zb_hhsoll_verf - <line>-zb_verfuegt.
    <line>-dif_diff_ao      = <line>-vb_inansp_mb - <line>-ao_soll.
    <line>-dif_verfueg_ist  = <line>-mb - <line>-ist_gesamt.
    <line>-ve_inansp_vorj   = <line>-ve_inanspvjhhj1 + <line>-ve_inanspvjhhj2 + <line>-ve_inanspvjhhj3 + <line>-ve_inanspvjhhj4 + <line>-ve_inanspvjhhj5.
    <line>-diff_ges_saldo   = <line>-zb_hh_zuwachs - <line>-ist_gesamt.

    IF <line>-potyp <> 3.
*      PERFORM change_value_to_positive CHANGING <line>-zb_verfuegbar.
      PERFORM change_value_to_positive CHANGING <line>-ve_noch_verfgba.
      PERFORM change_value_to_positive CHANGING <line>-ve_inansp_stat.
      PERFORM change_value_to_positive CHANGING <line>-zb_diffhh_soll.
      PERFORM change_value_to_positive CHANGING <line>-dif_diff_ao.
      PERFORM change_value_to_positive CHANGING <line>-dif_verfueg_ist.
      PERFORM change_value_to_positive CHANGING <line>-ve_inansp_vorj.
      PERFORM change_value_to_positive CHANGING <line>-diff_ges_saldo.
    ENDIF.

**********************************************************************
** Immer abs. Wert ( ohne Berechnung )
    PERFORM change_value_to_positive CHANGING <line>-mb.
    PERFORM change_value_to_positive CHANGING <line>-ist_month.
*    PERFORM change_value_to_positive CHANGING <line>-ao_soll.
    PERFORM change_value_to_positive CHANGING <line>-vormerk.
    PERFORM change_value_to_positive CHANGING <line>-mb_vorjahr.
    PERFORM change_value_to_positive CHANGING <line>-vb_ao_bez_mb.
    PERFORM change_value_to_positive CHANGING <line>-soll_gesamt.
    PERFORM change_value_to_positive CHANGING <line>-dif_kasse_ist.
    PERFORM change_value_to_positive CHANGING <line>-diff_ist.
    PERFORM change_value_to_positive CHANGING <line>-diff_offen.
*    PERFORM change_value_to_positive CHANGING <line>-zb_verfuegt.
    PERFORM change_value_to_positive CHANGING <line>-zb_verteilt_hh.
    PERFORM change_value_to_positive CHANGING <line>-ve_verfuegsoll.
    PERFORM change_value_to_positive CHANGING <line>-ve_verteilt.
    PERFORM change_value_to_positive CHANGING <line>-ve_lasthhj_1.
    PERFORM change_value_to_positive CHANGING <line>-ve_lasthhj_2.
    PERFORM change_value_to_positive CHANGING <line>-ve_lasthhj_3.
    PERFORM change_value_to_positive CHANGING <line>-ve_lasthhj_4.
    PERFORM change_value_to_positive CHANGING <line>-ve_lasthhj_5f.
    PERFORM change_value_to_positive CHANGING <line>-ve_lasthhj_6.
    PERFORM change_value_to_positive CHANGING <line>-ve_lasthhj_7.
    PERFORM change_value_to_positive CHANGING <line>-ve_lasthhj_8.
    PERFORM change_value_to_positive CHANGING <line>-ve_lasthhj_9.
    PERFORM change_value_to_positive CHANGING <line>-ve_lasthhj_10f.
    PERFORM change_value_to_positive CHANGING <line>-ve_vertlt_hhj_1.
    PERFORM change_value_to_positive CHANGING <line>-ve_vertlt_hhj_2.
    PERFORM change_value_to_positive CHANGING <line>-ve_vertlt_hhj_3.
    PERFORM change_value_to_positive CHANGING <line>-ve_vertlt_hhj_4.
    PERFORM change_value_to_positive CHANGING <line>-ve_vertlt_hhj5f.
    PERFORM change_value_to_positive CHANGING <line>-ve_vertlt_hhj_6.
    PERFORM change_value_to_positive CHANGING <line>-ve_vertlt_hhj_7.
    PERFORM change_value_to_positive CHANGING <line>-ve_vertlt_hhj_8.
    PERFORM change_value_to_positive CHANGING <line>-ve_vertlt_hhj_9.
    PERFORM change_value_to_positive CHANGING <line>-ve_vertlt_hhj10.
    PERFORM change_value_to_positive CHANGING <line>-ve_hhplan_hhj_1.
    PERFORM change_value_to_positive CHANGING <line>-ve_hhplan_hhj_2.
    PERFORM change_value_to_positive CHANGING <line>-ve_hhplan_hhj_3.
    PERFORM change_value_to_positive CHANGING <line>-ve_hhplan_hhj_4.
    PERFORM change_value_to_positive CHANGING <line>-ve_hhplan_hhj5f.
    PERFORM change_value_to_positive CHANGING <line>-ve_hhplan_hhj_6.
    PERFORM change_value_to_positive CHANGING <line>-ve_hhplan_hhj_7.
    PERFORM change_value_to_positive CHANGING <line>-ve_hhplan_hhj_8.
    PERFORM change_value_to_positive CHANGING <line>-ve_hhplan_hhj_9.
    PERFORM change_value_to_positive CHANGING <line>-ve_hhplan_hhj10.
    PERFORM change_value_to_positive CHANGING <line>-ve_hhplan.

*    PERFORM change_value_to_positive CHANGING <line>-zb_hhsoll.

**********************************************************************
** Ohne Anpassung
    <line>-ve_apl_uepl      = <line>-ve_apluepl_hhj1 + <line>-ve_apluepl_hhj2 + <line>-ve_apluepl_hhj3 + <line>-ve_apluepl_hhj4 + <line>-ve_aplueplhhj5f.
    <line>-ve_deckfaeh      = <line>-ve_df_last_hhj1 + <line>-ve_df_last_hhj2 + <line>-ve_df_last_hhj3 + <line>-ve_df_last_hhj4 + <line>-ve_df_lasthhj5f.
** AVK Status   AG -> Icon Alert
    <line>-zb_avk_status = COND #( WHEN <line>-zb_diffhh_soll < 0 THEN '@AG@' ).

**********************************************************************
** Weitere Berechnung / Ermittlungen
    IF <line>-zb_verbrauchbar <> 0.
      <line>-zb_verfuegung_prozent =  ( <line>-zb_verfuegt * 100 ) / <line>-zb_verbrauchbar.
    ENDIF.
    "**Für Unterkonten
    IF strlen( <line>-fipex ) > 9.
      <line>-zb_verfuegt_uk = <line>-ao_soll + <line>-mb.
      "**Ausgabe muss korrigiert
      IF <line>-potyp = '3'.
        <line>-zb_verfuegbaruk = <line>-zb_hhsoll + ( <line>-zb_verfuegt_uk * -1 ).
      ELSEIF <line>-potyp = '2'.
        <line>-zb_verfuegbaruk = <line>-zb_hhsoll - <line>-ao_soll.
        CLEAR <line>-zb_verfuegt.
      ELSEIF <line>-potyp = '1'.
        <line>-zb_verfuegbaruk  = <line>-zb_hhsoll + <line>-zb_verfuegt_uk.
      ENDIF.
      "** Für Titel
    ELSE.
      "**Ausgabe muss korrigiert
      IF <line>-potyp = '3'.
        <line>-zb_verfuegbar = <line>-zb_hhsoll + ( <line>-zb_verfuegt * -1 ).
      ELSEIF <line>-potyp = '2'.
        <line>-zb_verfuegbar = <line>-zb_hhsoll - <line>-ao_soll.
        CLEAR <line>-zb_verfuegt.
      ELSEIF <line>-potyp = '1'.
        <line>-zb_verfuegbar  = <line>-zb_hhsoll + <line>-zb_verfuegt.
      ENDIF.
    ENDIF.
*--------------------------------------------------------------------*
* Geschäftsjahr zuweisen
    IF <line>-gjahr IS INITIAL.
      <line>-gjahr =  lv_pgjahr.
    ENDIF.
    " Deckungsgruppe nachlesen
    CLEAR: ls_g_t_deckungsgrp.
    READ TABLE g_t_deckungsgrp INTO  ls_g_t_deckungsgrp
                               WITH KEY rfundsctr = <line>-fictr
                                        rcmmtitem = <line>-fipex
                                        rldnr     = '9H'
                                        ryear     = lv_pgjahr
                                        BINARY SEARCH.
    IF sy-subrc = 0.
      <line>-rcvrgrp_9_9h  = <line>-rcvrgrp_9_9h.
    ENDIF.
    LOOP AT g_t_item INTO DATA(item) WHERE rfund = <line>-epl
                                   AND rfundsctr = <line>-fictr
                                   AND rcmmtitem = <line>-fipex
                                   AND   budtype <> ''.
      <line>-budtype_9 = item-budtype.
      EXIT.
    ENDLOOP.

    DATA(postyp_txt) = CAST cl_abap_elemdescr( cl_abap_elemdescr=>describe_by_name( 'FM_POTYP' ) )->get_ddic_fixed_values( ).
    <line>-fipotyp_text = postyp_txt[ low = <line>-potyp ]-ddtext.
**********************************************************************
** Read CGr  Manual / Einnahme  and Descriptions
    TRY.
*        item = g_t_item[ rfund = <line>-epl rfundsctr = <line>-fictr rcmmtitem = <line>-fipex ].
        LOOP AT cvgrps INTO DATA(cvgr) WHERE fund = <line>-epl
                                         AND fundsctr  = <line>-fictr
                                         AND cmmtitem  = <line>-fipex.

*                                         AND budgetcat = <line>-epl.
          CASE cvgr-cvgrptype.
            WHEN 'A'. " Automatic
              <line>-rcvrgrp_9_9h     = COND #( WHEN <line>-rcvrgrp_9_9h IS INITIAL THEN cvgr-cvgrp
                                                  ELSE |{ <line>-rcvrgrp_9_9h },{ cvgr-cvgrp }| ).
              <line>-zb_desc_deckgr_aut = COND #( WHEN <line>-zb_desc_deckgr_aut IS INITIAL THEN cvgr-text
                                                  ELSE |{ <line>-zb_desc_deckgr_aut },{ cvgr-text }| ).
            WHEN 'M'. " Manual
              <line>-zb_deckgr_manu     = COND #( WHEN <line>-zb_deckgr_manu IS INITIAL THEN cvgr-cvgrp
                                                  ELSE |{ <line>-zb_deckgr_manu },{ cvgr-cvgrp }| ).
              <line>-zb_desc_deckgr_man = COND #( WHEN <line>-zb_desc_deckgr_man IS INITIAL THEN cvgr-text
                                                  ELSE |{ <line>-zb_desc_deckgr_man },{ cvgr-text }| ).
            WHEN 'R'. " Einnahme
              <line>-zb_deckgr_ea      = COND #( WHEN <line>-zb_deckgr_ea IS INITIAL THEN cvgr-cvgrp
                                                 ELSE |{ <line>-zb_deckgr_ea },{ cvgr-cvgrp }| ).
              <line>-zb_desc_deckgr_ea = COND #( WHEN <line>-zb_desc_deckgr_ea IS INITIAL THEN cvgr-text
                                                 ELSE |{ <line>-zb_desc_deckgr_ea },{ cvgr-text }| ).
          ENDCASE.
        ENDLOOP.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDLOOP.


*--------------------------------------------------------------------*
* Ende: Zusammenfassung und Neuberechnung der Werte
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Transaktion beenden, wenn keine Daten selektiert wurden - orig
*--------------------------------------------------------------------*
  IF g_t_itab[] IS INITIAL.
*   No records found
    MESSAGE s850(kw).
*   "/ Flag for schedman
    g_aplstat = '2'.    "warning
*   "/ send info to schedman monitor
    PERFORM close_schedman.
    IF sy-tcode = con_tcode.
      LEAVE TO TRANSACTION sy-tcode.
    ELSE.
      LEAVE PROGRAM.
    ENDIF.
  ENDIF. "   IF g_t_itab[] IS INITIAL.


*--------------------------------------------------------------------*
* Aufbereitung für die Anzeige - LBB
*--------------------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      text = 'Ausgabe vorbereiten '(d07).



* them in the header storage structure
  PERFORM determine_header_fields TABLES   g_t_itab
                                  CHANGING g_flg_sngl_value
                                           g_f_header.

*------------------
* Build Meta Data
***  PERFORM fill_fieldcat CHANGING g_t_fieldcat
***                                 g_t_sp_groups.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     I_PROGRAM_NAME         =
*     I_INTERNAL_TABNAME     =
      i_structure_name       = '/THKR/SBCS_IFMRKBHH'  " 'ZSBB_BCS_IFMRKBHH'
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_INCLNAME             =
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      ct_fieldcat            = g_t_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
*    write: / text-003.
  ENDIF.



*---------------------------------------*
* Jahr der Kassenwirksamkeit anpassen
**  DATA: lv_jahr_txt TYPE string.
**  LOOP AT g_t_fieldcat INTO ls_g_t_fieldcat WHERE seltext_m CS '+'.
**
**
**
**    IF ls_g_t_fieldcat-seltext_l CS '+10'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 10.
**      REPLACE '+10' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+10' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+10' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+11'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 11.
**      REPLACE '+11' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+11' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+11' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+12'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 12.
**      REPLACE '+12' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+12' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+12' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+13'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 13.
**      REPLACE '+13' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+13' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+13' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+14'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 14.
**      REPLACE '+14' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+14' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+14' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+15'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 15.
**      REPLACE '+15' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+15' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+15' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+16'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 16.
**      REPLACE '+16' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+16' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+16' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+17'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 17.
**      REPLACE '+17' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+17' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+17' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+18'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 18.
**      REPLACE '+18' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+18' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+18' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+19'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 19.
**      REPLACE '+19' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+19' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+19' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+20'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 20.
**      REPLACE '+20' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+20' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+20' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+1'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 1.
**      REPLACE '+1' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+1' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+1' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+2'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 2.
**      REPLACE '+2' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+2' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+2' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+3'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 3.
**      REPLACE '+3' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+3' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+3' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+4'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 4.
**      REPLACE '+4' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+4' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+4' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+5'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 5.
**      REPLACE '+5' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+5' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+5' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+6'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 6.
**      REPLACE '+6' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+6' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+6' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+7'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 7.
**      REPLACE '+7' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+7' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+7' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+8'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 8.
**      REPLACE '+8' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+8' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+8' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ELSEIF ls_g_t_fieldcat-seltext_l CS '+9'.
**      CLEAR: lv_jahr_txt.
**      lv_jahr_txt = lv_pgjahr + 9.
**      REPLACE '+9' INTO ls_g_t_fieldcat-seltext_l WITH lv_jahr_txt+2(2).
**      REPLACE '+9' INTO ls_g_t_fieldcat-seltext_m WITH lv_jahr_txt+2(2).
**      REPLACE '+9' INTO ls_g_t_fieldcat-seltext_s WITH lv_jahr_txt+2(2).
**
**
**    ENDIF.  " IF ls_g_t_fieldcat-seltext_l CS ...
**
**
**    MODIFY g_t_fieldcat FROM ls_g_t_fieldcat TRANSPORTING seltext_s
**                                                          seltext_m
**                                                          seltext_l.
**
**  ENDLOOP. "   LOOP AT g_t_fieldcat INTO ls_g_t_fieldcat WHERE seltext_m CS '+'.



*--------------------------------------------------------------------*
* Anzeige vorbereiten
*--------------------------------------------------------------------*

  PERFORM fill_layout   CHANGING g_f_layout.

  PERFORM fill_header   CHANGING g_title
                                 g_background_id
                                 g_t_object_info
                                 g_t_top_messages.

  PERFORM fill_sort     CHANGING g_t_sort.

  PERFORM fill_sel_crit CHANGING g_t_sel_crit.

  PERFORM fill_events   CHANGING g_t_events.

* Set other options
  g_f_print-prnt_info = 'X'.

* Call List Viewer tool to display list
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program          = con_repid
      i_callback_pf_status_set    = 'PF_STATUS_SET'
      i_callback_user_command     = 'USER_COMMAND'
      i_callback_top_of_page      = 'TOP_OF_PAGE'
      i_callback_html_top_of_page = 'HTML_TOP_OF_PAGE'
      i_structure_name            = con_output_tname_lbb     " DS20210527
      i_background_id             = g_background_id
      is_layout                   = g_f_layout
      is_variant                  = g_f_disvariant
      is_print                    = g_f_print
      it_fieldcat                 = g_t_fieldcat
      it_special_groups           = g_t_sp_groups
      it_sort                     = g_t_sort
      it_filter                   = g_t_filt
      is_sel_hide                 = g_t_sel_crit
      i_default                   = 'X'
      i_save                      = 'A'
      it_events                   = g_t_events
    TABLES
      t_outtab                    = g_t_itab
    EXCEPTIONS
      program_error               = 1
      OTHERS                      = 2.



*  "/ Set flags for schedman
  IF sy-subrc = 0.
    g_aplstat = '0'.    "success
  ELSE.
    g_aplstat = '4'.    "error
  ENDIF.
*  "/ send info to schedman monitor
  PERFORM close_schedman.

**********************************************************************
*** An error occurs that all selection are filled w/o direct input.
*** Reset parameter with already entered once here
  SET PARAMETER ID 'FIC' FIELD bu_fonds.
  SET PARAMETER ID 'FIS' FIELD bu_fictr.
  SET PARAMETER ID 'FPS' FIELD bu_fipex.
  SET PARAMETER ID 'FBE' FIELD bu_farea.
  SET PARAMETER ID 'FM_MEASURE' FIELD bu_hhm.

************************************************************************
* Ende Hauptprogramm
************************************************************************
************************************************************************


*&---------------------------------------------------------------------*
*&      Form  CHECK_UPDATE_PROFILE
*&---------------------------------------------------------------------*
FORM check_update_profile CHANGING c_flag_invoices   TYPE flag
                                   c_flag_payments   TYPE flag.

  DATA: l_t_fmup01 LIKE fmup01 OCCURS 0 WITH HEADER LINE.

*--- Get FS Profile information
  CALL FUNCTION 'FM_FSPROFILE_GET'
    EXPORTING
      i_fikrs  = s_fikrs-low
    TABLES
      t_fmup01 = l_t_fmup01.

  LOOP AT l_t_fmup01.

*--- Check if profile supports invoices
    IF l_t_fmup01-wrttp = '54' AND l_t_fmup01-vrgng IS INITIAL.
      IF l_t_fmup01-paybudget = 'X'
      OR l_t_fmup01-combudget = 'X'.
        c_flag_invoices = 'X'.
      ENDIF.
    ENDIF.

*--- Check if profile supports payments
    IF l_t_fmup01-wrttp = '57' AND l_t_fmup01-vrgng IS INITIAL.
      IF l_t_fmup01-paybudget = 'X'
      OR l_t_fmup01-combudget = 'X'.
        c_flag_payments = 'X'.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                               " CHECK_UPDATE_PROFILE



*&---------------------------------------------------------------------*
*&      Form  FIND_PBET_ACTIVE
*&---------------------------------------------------------------------*
*       Find if Period-based encumbrance tracking is active
*----------------------------------------------------------------------*
FORM find_pbet_active USING u_fikrs.

  DATA: l_t_fmup01 LIKE fmup01 OCCURS 0 WITH HEADER LINE,
        l_f_fmup00 LIKE fmup00.

*--- Get Update profile information for user-input FM Area
  CALL FUNCTION 'FM_FSPROFILE_GET'
    EXPORTING
      i_fikrs    = u_fikrs
    CHANGING
      e_f_fmup00 = l_f_fmup00.

*--- Find if PBET is active
  CALL FUNCTION 'FM_CONTROL_DATA_GET'
    EXPORTING
      i_profil   = l_f_fmup00-profil
    IMPORTING
      e_f_fmup00 = l_f_fmup00.

  IF s_budcat-low = con_payment.
*--- Payment budget
    IF l_f_fmup00-vasfund IS INITIAL.
      MESSAGE w090.
    ENDIF.
  ELSEIF s_budcat-low = con_cmmtitem.
*--- Commitment Budget
    IF l_f_fmup00-cvasfund IS INITIAL.
      MESSAGE w090.
    ENDIF.
  ENDIF.

ENDFORM.                               " FIND_PBET_ACTIVE



*&---------------------------------------------------------------------*
*&      Form  MANIPULATE_SELECTION_VALUES
*&---------------------------------------------------------------------*
*       Manipulate selection values to retrieve data from the
*       database before retrieving line items according to the user
*       selection input
*----------------------------------------------------------------------*
FORM manipulate_selection_values.
  CHECK sscrfields-ucomm = 'ONLI' OR
        sscrfields-ucomm = 'PRIN'.

*--- Check if PBET is active
  PERFORM find_pbet_active USING s_fikrs-low.

*--- Expenditure commitment item category
  REFRESH s_potyp.
  CLEAR s_potyp.
  s_potyp-sign    = 'I'.
  s_potyp-option  = 'EQ'.
  s_potyp-low     = 3.
  APPEND s_potyp.

ENDFORM.                               " MANIPULATE_SELECTION_VALUES



*&---------------------------------------------------------------------*
*&      Form  SET_FLAGS
*&---------------------------------------------------------------------*
*       Set general flags (FM dim activity, ...)
*----------------------------------------------------------------------*
FORM set_flags.

  DATA: u_grant_nbr_state TYPE fmcu_dimstate,
        u_fund_state      TYPE fmcu_dimstate,
        u_budget_pd_state TYPE fmcu_dimstate,
        u_fundsctr_state  TYPE fmcu_dimstate,
        u_cmmtitem_state  TYPE fmcu_dimstate,
        u_funcarea_state  TYPE fmcu_dimstate,
        u_measure_state   TYPE fmcu_dimstate,
        u_userdim_state   TYPE fmcu_dimstate.

  CLEAR: g_flg_fmdimactive-grant_nbr,
         g_flg_fmdimactive-fund,
         g_flg_fmdimactive-budget_pd,
         g_flg_fmdimactive-fundsctr,
         g_flg_fmdimactive-cmmtitem,
         g_flg_fmdimactive-funcarea,
         g_flg_fmdimactive-measure,
         g_flg_fmdimactive-userdim.

* Get dimensions + state
  CALL FUNCTION 'FMCU_GET_DIMENSIONS'
    EXPORTING
      i_fm_area         = s_fikrs-low
    IMPORTING
      e_fund_state      = u_fund_state
      e_fundsctr_state  = u_fundsctr_state
      e_cmmtitem_state  = u_cmmtitem_state
      e_funcarea_state  = u_funcarea_state
      e_measure_state   = u_measure_state
      e_grant_nbr_state = u_grant_nbr_state
      e_userdim_state   = u_userdim_state
      e_budget_pd_state = u_budget_pd_state
    EXCEPTIONS
      OTHERS            = 1.

  IF sy-subrc IS INITIAL.
    IF u_grant_nbr_state > '0'.
      g_flg_fmdimactive-grant_nbr = 'X'.
    ENDIF.
    IF u_fund_state > '0'.
      g_flg_fmdimactive-fund      = 'X'.
    ENDIF.
    IF u_budget_pd_state > '0'.
      g_flg_fmdimactive-budget_pd = 'X'.
    ENDIF.
    IF u_fundsctr_state > '0'.
      g_flg_fmdimactive-fundsctr  = 'X'.
    ENDIF.
    IF u_cmmtitem_state > '0'.
      g_flg_fmdimactive-cmmtitem  = 'X'.
    ENDIF.
    IF u_funcarea_state > '0'.
      g_flg_fmdimactive-funcarea  = 'X'.
    ENDIF.
    IF u_measure_state > '0'.
      g_flg_fmdimactive-measure  = 'X'.
    ENDIF.
    IF u_userdim_state > '0'.
      g_flg_fmdimactive-userdim  = 'X'.
    ENDIF.
  ENDIF.

* Check if YCE is active for Budget category (single value)
  CALL FUNCTION 'FMCU_CHECK_BUDCAT'
    EXPORTING
      i_fm_area           = s_fikrs-low
      i_budcat            = s_budcat-low
    IMPORTING
      e_flg_ceffyear_used = g_flg_ceffyear_used
    EXCEPTIONS
      OTHERS              = 1.

* Determine the sign of revenues in the reporting
  CALL FUNCTION 'FM_SIGN_GET_FOR_EXPENDITURE'
    IMPORTING
      e_sign          = g_flg_expsign
      e_sign_revenues = g_flg_revsign.

* Report scenario (level)
  p_rb_bud = 'X'.
  CLEAR: p_rb_avc, p_rb_pst.

* Type of AA addres
  p_ba = 'X'.
  CLEAR: p_co, p_pa.


  " DS20210920
* "/ Kommunenflag ermitteln
  CALL FUNCTION 'FM00_CHECK_ISPS'
    IMPORTING
      e_kom_activ = g_flg_komm.


ENDFORM.                  "SET_FLAGS



*&---------------------------------------------------------------------*
*&      Form  SET_SIGN_ACTUALS
*&---------------------------------------------------------------------*
FORM set_sign_actuals_rep  USING    u_potyp TYPE fm_potyp
                           CHANGING c_value.

  IF u_potyp = '3' AND g_flg_expsign = '+'.
*   Expenditures are displayed with sign '+'
    c_value = c_value * -1.
  ELSEIF u_potyp = '2' AND g_flg_revsign = '-'.
*   Revenues are displayed with sign '-'
    c_value = c_value * -1.
  ENDIF.

ENDFORM.                    " SET_SIGN_ACTUALS



*&---------------------------------------------------------------------*
*&      Form  GET_PERIODS_FOR_FYEAR
*&---------------------------------------------------------------------*
*       Determines valid period range FROM - TO for the given fiscal
*       year combining the selection criteria and fiscal year variant
*       settings.
*----------------------------------------------------------------------*
FORM get_periods_for_fyear USING u_fyear  TYPE gjahr
                        CHANGING c_per_fr TYPE fm_periode
                                 c_per_to TYPE fm_periode.

  DATA: l_special_periods TYPE anzsp.

* Get the defaults according to the fiscal year variant
  c_per_fr = '001'.

  CALL FUNCTION 'FMKU_GET_PERIOD_INFO'
    EXPORTING
      i_fm_area            = s_fikrs-low
    IMPORTING
      e_nb_periods         = c_per_to
      e_nb_special_periods = l_special_periods.

* Also Special Periods need to be selected (e.g. Carry-Forward posting)
  c_per_to = c_per_to + l_special_periods.

  IF p_fyr_fr = p_fyr_to.
*   Only one fiscal year -> take over the selection screen periods
    c_per_fr = p_per_fr.
    c_per_to = p_per_to.
  ELSEIF u_fyear = p_fyr_fr.
*   First fiscal year of the range -> adjust FROM
    c_per_fr = p_per_fr.
  ELSEIF u_fyear = p_fyr_to.
*   Last fiscal year of the range -> adjust TO
    c_per_to = p_per_to.
  ELSE.
*   'Inner' fiscal year -> leave the defaults
  ENDIF.

ENDFORM.                               " GET_PERIODS_FOR_FYEAR



*&---------------------------------------------------------------------*
*&      Form  DETERMINE_HEADER_FIELDS
*&---------------------------------------------------------------------*
FORM determine_header_fields
          TABLES   u_t_items STRUCTURE g_t_itab
          CHANGING c_flg_sngl_value TYPE s_sngl_value_info
                   c_f_header TYPE s_header_data.

***          TABLES   u_t_items STRUCTURE g_t_item
***          CHANGING c_flg_sngl_value TYPE s_sngl_value_info
***                   c_f_header TYPE s_header_data.

* Use some macro:
  DEFINE m_def_sngl_value_check.
    IF c_flg_sngl_value-&1 IS INITIAL.
*     Don't check anymore -> already more then one value found
    ELSEIF  c_flg_sngl_value-&1 = 'I'.
*     First round; initiate the header value
      c_flg_sngl_value-&1 = 'X'.
      c_f_header-&2 = u_t_items-&3.
    ELSEIF c_f_header-&2 <> u_t_items-&3.
*     2nd value found -> stop searching
      CLEAR c_flg_sngl_value-&1.
      CLEAR c_f_header-&2.
    ENDIF.
  END-OF-DEFINITION.


* Initial flag 'I'
  c_flg_sngl_value-fikrs     =
  c_flg_sngl_value-fyear     =
  c_flg_sngl_value-budcat    =
  c_flg_sngl_value-version   =
  c_flg_sngl_value-ceffyear  =
  c_flg_sngl_value-grant_nbr =
  c_flg_sngl_value-fund      =
  c_flg_sngl_value-fundsctr  =
  c_flg_sngl_value-cmmtitem  =
  c_flg_sngl_value-funcarea  =
  c_flg_sngl_value-measure   =
  c_flg_sngl_value-userdim   =
  c_flg_sngl_value-process   =

* DS20210916
  c_flg_sngl_value-fictr     =
  c_flg_sngl_value-fipex     =
  c_flg_sngl_value-ryear     =

  c_flg_sngl_value-budtype   =   'I'.

* budget period: only initialize to i if active:
  IF cl_psm_switch_check=>psm_fm_bud_per_rev_1( ) = con_on.
    c_flg_sngl_value-budget_pd = 'I'.
  ENDIF.

* FM area currency, Value type always single
  c_flg_sngl_value-fwaer     =   'X'.
  c_flg_sngl_value-valtype   =   'X'.
  c_f_header-valtype = s_valtyp-low.
* Dummy flag - always space
  c_flg_sngl_value-notsngl   =   ' '.

  LOOP AT u_t_items.

*   DS20210916

    u_t_items-rfundsctr = u_t_items-fictr.  " Finanzstelle
    u_t_items-rcmmtitem = u_t_items-fipex.  " Finanzstelle
    u_t_items-rfuncarea = u_t_items-farea.  " Funktionsbereich
    u_t_items-ryear     = u_t_items-gjahr.  " Geschäftsjahr



    m_def_sngl_value_check fikrs fikrs fikrs.
    m_def_sngl_value_check  ryear   ryear ryear.


*** m_def_sngl_value_check  fyear   fyear fyear.

*** m_def_sngl_value_check  budcat    budcat    budcat.
*** m_def_sngl_value_check  version   version   version.
*** m_def_sngl_value_check  grant_nbr grant_nbr rgrant_nbr.

    m_def_sngl_value_check fund fund rfund.

***    IF cl_psm_switch_check=>psm_fm_bud_per_rev_1( ) = con_on.
***      m_def_sngl_value_check budget_pd budget_pd rbudget_pd.
***    ENDIF.

    m_def_sngl_value_check  fundsctr    fundsctr    rfundsctr.

    m_def_sngl_value_check  cmmtitem    cmmtitem    rcmmtitem.

    m_def_sngl_value_check  funcarea    funcarea    rfuncarea.

*** m_def_sngl_value_check  measure     measure     rmeasure.
*** m_def_sngl_value_check  userdim     userdim     ruserdim.
    m_def_sngl_value_check  process     process     process_9.
    m_def_sngl_value_check  budtype     budtype     budtype_9.

* DS20210916
    m_def_sngl_value_check  fictr       fictr       fictr.
    m_def_sngl_value_check  fipex       fipex       fipex.



  ENDLOOP.

* Header fields (= FM dimensions)
  IF c_flg_sngl_value-grant_nbr IS INITIAL
  OR c_flg_sngl_value-fund      IS INITIAL
  OR c_flg_sngl_value-fundsctr  IS INITIAL
  OR c_flg_sngl_value-cmmtitem  IS INITIAL
  OR c_flg_sngl_value-funcarea  IS INITIAL
  OR c_flg_sngl_value-measure   IS INITIAL
  OR c_flg_sngl_value-userdim   IS INITIAL

* DS20210916
  OR c_flg_sngl_value-fictr     IS INITIAL
  OR c_flg_sngl_value-fipex     IS INITIAL
  OR c_flg_sngl_value-ryear     IS INITIAL

* Subtotal fields
  OR c_flg_sngl_value-fikrs     IS INITIAL
  OR c_flg_sngl_value-budcat    IS INITIAL
  OR c_flg_sngl_value-version   IS INITIAL
  OR c_flg_sngl_value-fyear     IS INITIAL.
  ELSE.
*   Display at least one subtotal column (with general FM area), if all
*   other header/subtotals fields are hidden because of single values
    CLEAR c_flg_sngl_value-fikrs.
  ENDIF.

ENDFORM.                    " DETERMINE_HEADER_FIELDS



*&---------------------------------------------------------------------*
*&      Form  FILL_HEADER
*&---------------------------------------------------------------------*
FORM fill_header CHANGING  c_title          TYPE lvc_title
                           c_background_id  TYPE sdydo_key
                           c_t_object_info  TYPE fm_t_listheader_data
                           c_t_top_messages TYPE fm_t_top_messages.


* Use some macro:
  DEFINE m_def_header_line.
    IF NOT g_flg_sngl_value-&2 IS INITIAL.
      CLEAR l_f_top_data.
      l_f_top_data-column    = &1.
      MESSAGE i&4(fmis) INTO l_f_top_data-data_key.
      l_f_top_data-data_info = g_f_header-&3.
      APPEND l_f_top_data TO c_t_object_info.
    ENDIF.
  END-OF-DEFINITION.


  DEFINE m_def_header_fmdim_line.
    IF NOT g_flg_fmdimactive-&2 IS INITIAL
    AND NOT g_flg_sngl_value-&2 IS INITIAL.
      CLEAR l_f_top_data.
      l_f_top_data-column    = &1.
      MESSAGE i&4(fmis) INTO l_f_top_data-data_key.
      IF NOT g_f_header-&3 IS INITIAL.
        l_f_top_data-data_info = g_f_header-&3.
      ELSE.
        MESSAGE i004(fmis) INTO l_f_top_data-data_info.
      ENDIF.
      APPEND l_f_top_data TO c_t_object_info.
    ENDIF.
  END-OF-DEFINITION.


  DEFINE m_def_skip_line.
    CLEAR l_f_top_data.
    l_f_top_data-column    = &1.
    APPEND l_f_top_data TO c_t_object_info.
  END-OF-DEFINITION.


  DATA:
    l_date(20)   TYPE c,
    l_time(20)   TYPE c,
    l_sav_title  LIKE sy-title,
    l_f_top_data TYPE ifm_listheader_data.

  CONSTANTS: con_exitname TYPE exit_def VALUE 'FM_LIST_HEADER_ADDIN'.

  STATICS:
    st_ref_header_exit TYPE REF TO if_ex_fm_list_header_addin.

*----- instanciate/initiate user exit for wallpaper
  IF st_ref_header_exit IS INITIAL.
    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name              = con_exitname
        null_instance_accepted = 'X'
      CHANGING
        instance               = st_ref_header_exit.
  ENDIF.

*----- get wallpaper according to user requirements and implementation
  IF NOT st_ref_header_exit IS INITIAL.
    CALL METHOD st_ref_header_exit->change_background
      CHANGING
        c_background_id = c_background_id.
  ENDIF.

*  "/ List-Titel holen, falls vorhanden
*  CALL FUNCTION 'FM_REPORT_TITLE_SET'
*      IMPORTING
*            e_title = l_sav_title.

  IF NOT l_sav_title IS INITIAL.
    c_title = l_sav_title.
  ELSE.
    c_title = sy-title.
  ENDIF.

* FM area
  CLEAR l_f_top_data.
  l_f_top_data-column = 1.
  MESSAGE i020(fmis) INTO l_f_top_data-data_key.
  CONCATENATE g_f_header-fikrs ' (' g_f_header-fwaer ')'
    INTO l_f_top_data-data_info.
  APPEND l_f_top_data TO c_t_object_info.

***  m_def_header_line 1 budcat budcat 022.

***  m_def_header_line 1 version version 023.
***  m_def_header_line 1 fyear fyear 024.

* DS20210916
  m_def_header_line 1 ryear ryear 024.

  IF NOT g_flg_ceffyear_used IS INITIAL.
***    m_def_header_line 1 ceffyear ceffyear 025.
  ENDIF.

***  m_def_header_fmdim_line 2 grant_nbr grant_nbr 050.

***  m_def_header_fmdim_line 2 fund fund 051.

  IF cl_psm_core_switch_check=>psm_fm_core_bud_per_rev_1( ) IS NOT INITIAL.
***    m_def_header_fmdim_line 2 budget_pd budget_pd 057.
  ENDIF.

  m_def_header_fmdim_line   2   fundsctr  fundsctr  052.

  m_def_header_fmdim_line   2   cmmtitem  cmmtitem  053.

  m_def_header_fmdim_line   2   funcarea  funcarea  054.


*** *DS20210916
***  m_def_header_fmdim_line   2   measure   measure   055.
***
***  m_def_header_fmdim_line   2   userdim   userdim   056.
***
***  m_def_header_line         1   valtype   valtype   026.
***
***  m_def_header_line         1   process   process   029.
***
***  m_def_header_line         1   budtype   budtype   027.

* Skip line
  m_def_skip_line 1.

* User
  CLEAR l_f_top_data.
  l_f_top_data-column = 1.
  MESSAGE i000(fmis) INTO l_f_top_data-data_key.
  l_f_top_data-data_info = sy-uname.
  APPEND l_f_top_data TO c_t_object_info.

* Date/time
  CLEAR l_f_top_data.
  l_f_top_data-column = 1.
  MESSAGE i001(fmis) INTO l_f_top_data-data_key.
  WRITE sy-datlo TO l_date.
  WRITE sy-uzeit TO l_time.
  CONCATENATE l_date l_time
    INTO  l_f_top_data-data_info
    SEPARATED BY '   '.
  APPEND l_f_top_data TO c_t_object_info.

ENDFORM.                    " FILL_HEADER



*&---------------------------------------------------------------------*
*&      Form  PF_STATUS_SET
*&---------------------------------------------------------------------*
*        Set GUI Status of list
*----------------------------------------------------------------------*
FORM pf_status_set CHANGING c_t_extab TYPE slis_t_extab.    "#EC CALLED

  DATA: l_f_extab TYPE slis_extab.
* DS20210928
**** Remove sort icons from the application toolbar to disable user
**** from sorting the list
***  l_f_extab-fcode = '&OUP'.
***  APPEND l_f_extab TO c_t_extab.
***
***  l_f_extab-fcode = '&ODN'.
***  APPEND l_f_extab TO c_t_extab.
***
**** Remove the filter icon from the application toolbar to disable user
**** from filtering records
***  l_f_extab-fcode = '&ILT'.
***  APPEND l_f_extab TO c_t_extab.

  SET PF-STATUS 'FULLSCREEN' EXCLUDING c_t_extab.

ENDFORM.                               " PF_STATUS_SET



*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       Define Callback User Command
*----------------------------------------------------------------------*
FORM user_command USING u_ucomm    LIKE sy-ucomm
                        u_selfield TYPE slis_selfield.      "#EC CALLED

  DATA: l_per_fr  TYPE  fm_periode,
        l_per_to  TYPE  fm_periode,
        l_process TYPE  buku_process,
        l_budtype TYPE  buku_budtype,
        l_nocomm  TYPE  flag.

  RANGES:
    l_r_grant_nbr FOR   gmgr-grant_nbr,
    l_r_fund      FOR   fmfincode-fincode,
    l_r_budget_pd FOR   fmbudgetpd-budget_pd,
    l_r_funcarea  FOR   tfkb-fkber,
    l_r_measure   FOR   fmmeasure-measure,
    l_r_process   FOR   g_t_item-process,
    l_r_budtype   FOR   g_t_item-budtype.


*---------------------------------------------------------------*
* User Command abfangen
*---------------------------------------------------------------*
  CASE u_ucomm.

    WHEN 'HINT'.
      "** Display some hints for calculation
      DATA(body) = `<table> `
            && `<tr><td><h3>Spalte HH-Ansatz + Gesamt-Soll:</td></tr> `
            && `<tr><td>Einnahmetitel: veranschlagte Einnahmen, werden in SAP negativ dargestellt</td></tr>`
            && `<tr><td>&nbsp;</td></tr> `
            && `<tr><td><h3>Spalte AO-Soll + Ist Gesamt:</td></tr> `
            && `<tr><td>Einnahmetitel negativ = Erwartete bzw. tatsächliche IST-Einnahme</td></tr>`
            && `<tr><td>Einnahmentitel positiv = Ausgaben höher als Einnahmen</td></tr>`
            && `<tr><td>&nbsp;</td></tr> `
            && `<tr><td>Ausgabetitel positiv  = Erwartete bzw. tatsächliche IST-Ausgabe</td></tr>`
            && `<tr><td>Ausgabetitel negativ  = Einnahmen höher als Ausgaben</td></tr>`
            && `</table>`.

      cl_demo_output=>new(
        )->begin_section( 'Spalten-Erläuterungen:'
        )->write_html( body
        )->display( name = 'Hinweise' ).

    WHEN 'ISEL'.
*     "/ Display of select-options
      CALL FUNCTION 'FMRP_UT_GET_SELECTIONS'
        EXPORTING
          i_report_name = con_repid
          i_dialog      = 'X'
        EXCEPTIONS
          no_entries    = 1.


    WHEN 'PIC1'.

      READ TABLE g_t_itab INDEX u_selfield-tabindex.

      CHECK sy-subrc = 0.

      CASE u_selfield-fieldname.

*       "/ Sprung zu Finanzpositionen-Stammdaten
        WHEN 'FIPEX' OR 'PNAME' OR 'TEXT1'  OR 'TEXT2'  OR 'TEXT3' OR 'FIPOS'.
          SET PARAMETER ID 'FPS' FIELD g_t_itab-fipex.
*         SET PARAMETER ID 'GJR' FIELD p_gjahr.
          SET PARAMETER ID 'GJR' FIELD p_fyr_fr.
          SET PARAMETER ID 'FIK' FIELD g_t_itab-fikrs.

          CALL TRANSACTION 'FMCIA' AND SKIP FIRST SCREEN.


*       "/ Sprung zu Finanzstellen-Stammdaten
        WHEN 'FICTR' OR 'CNAME' OR 'CDSCR'.
          SET PARAMETER ID 'FIS' FIELD g_t_itab-fictr.
          SET PARAMETER ID 'FIK' FIELD g_t_itab-fikrs.

          CALL TRANSACTION 'FMSC' AND SKIP FIRST SCREEN.


*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsstellen, Fonds
*       "/ Sprung zu Fonds-Stammdaten
        WHEN 'FONDS'.
          SET PARAMETER ID 'FIC' FIELD g_t_itab-fonds.
          SET PARAMETER ID 'FIK' FIELD g_t_itab-fikrs.

          CALL TRANSACTION 'FM5S' AND SKIP FIRST SCREEN.


*       "/ Sprung zu Haushaltsprogramm-Stammdaten
        WHEN 'RMEASURE'.
          SET PARAMETER ID 'FM_MEASURE' FIELD g_t_itab-rmeasure.
          SET PARAMETER ID 'FIK' FIELD g_t_itab-fikrs.

          CALL TRANSACTION 'FMMEASURED' AND SKIP FIRST SCREEN.
*--------------------------------------------------------------------*
        WHEN 'ZB_DECKGR_MANU' OR 'ZB_DECKGR_EA'.
          " Call FMCRUL
          TRY.
              CASE u_selfield-fieldname.
                WHEN 'ZB_DECKGR_MANU'.
                  DATA(line_cvgrp) = g_t_itab-zb_deckgr_manu.
                WHEN 'ZB_DECKGR_EA'.
                  line_cvgrp = g_t_itab-zb_deckgr_ea.
              ENDCASE.

              "" Popup for Multi-Assignment
              IF count( val = line_cvgrp sub = ',' ) > 0.
                SPLIT line_cvgrp AT ',' INTO TABLE DATA(lines_cvgrp).
                DATA field_desc TYPE TABLE OF rsvbfidesc.
                DATA(sel_line) = 0.
                DATA(sel_list) = VALUE /thkr/tbcs_popup( FOR line_item IN lines_cvgrp ( val = line_item ) ).
                field_desc = VALUE #( ( fieldnum = 1  display = abap_true ) ).
                CALL FUNCTION 'RS_VALUES_BOX'
                  EXPORTING
                    cursor_field   = 1
                    cursor_line    = 1
                    left_upper_col = 5
                    left_upper_row = 5
                    title          = 'Auswahl'
                  IMPORTING
                    linenumber     = sel_line
                  TABLES
                    field_desc     = field_desc
                    value_tab      = sel_list
                  EXCEPTIONS
                    OTHERS         = 10.
                DATA(target_cvgrp_info) = cvgrps[ cvgrp = sel_list[ sel_line ]-val ].
              ELSE.
                target_cvgrp_info = cvgrps[ cvgrp = line_cvgrp ].
              ENDIF.

              DATA(ta) = NEW /thkr/cl_call_transaction( 'FMCERULE' ).
              ta->set_program( program = 'SAPLFMCE_OPEN_RULE' dynpro = '0900' ).
              ta->set_cursor( value = 'FMCE_S_MAINT_SCREEN-CGAUTOIND' )->set_okcode( value = '=CHG_CAT' ).
              ta->set_field( field = 'FMCE_S_MAINT_SCREEN-FISCYEAR' value = target_cvgrp_info-fiscyear
               )->set_field( field = 'FMCE_S_MAINT_SCREEN-CGAUTOIND' value = target_cvgrp_info-cvgrptype
               )->set_program( program = 'SAPLFMCE_OPEN_RULE' dynpro = '0900' ).
              "" Dynamic GUI: Select field depends
              CASE target_cvgrp_info-cvgrptype.
                WHEN 'M'. ta->set_field( field = 'FMCE_S_MAINT_SCREEN-BUDCAT' value = target_cvgrp_info-target_ledger ).
                WHEN 'R'. ta->set_field( field = 'FMCE_S_MAINT_SCREEN-RBBLDNR' value = target_cvgrp_info-target_ledger ).
              ENDCASE.
              ta->set_field( field = 'FMCE_S_MAINT_SCREEN-CVRGRP' value = target_cvgrp_info-cvgrp )->set_okcode( value = 'DISP' ).
              ta->call( ).
            CATCH cx_sy_itab_line_not_found.
          ENDTRY.

*       "/ Sprung zu Deckungsgrupen
        WHEN 'RCVRGRP_9_9H'. "   OR 'RCVRGRP_9_9I'.
*          FMCEMON01 - Deckungsgruppen- Monitor (Report: RFFMCE_HIER_VIEW)

          DATA: l_t_seltab_dg     LIKE rsparams OCCURS 10 WITH HEADER LINE.
          DATA: ls_l_t_seltab_dg  TYPE rsparams.


          IF g_t_itab-rcvrgrp_9_9h IS NOT INITIAL.
            CLEAR:    ls_l_t_seltab_dg.
            REFRESH:  l_t_seltab_dg.


            " Finanzkreis
            CLEAR: ls_l_t_seltab_dg.
            ls_l_t_seltab_dg-selname = 'P_FKRS'.
            ls_l_t_seltab_dg-kind    = 'P'.
            ls_l_t_seltab_dg-sign    = 'I'.
            ls_l_t_seltab_dg-option  = 'EQ'.
            ls_l_t_seltab_dg-low     = g_t_itab-fikrs.
*           ls_l_t_seltab_dg-high    =
            APPEND ls_l_t_seltab_dg TO  l_t_seltab_dg.

            " Jahr
            CLEAR: ls_l_t_seltab_dg.
            ls_l_t_seltab_dg-selname = 'P_YEAR'.
            ls_l_t_seltab_dg-kind    = 'P'.
            ls_l_t_seltab_dg-sign    = 'I'.
            ls_l_t_seltab_dg-option  = 'EQ'.
            ls_l_t_seltab_dg-low     = p_fyr_fr.
*           ls_l_t_seltab_dg-high    =
            APPEND ls_l_t_seltab_dg TO  l_t_seltab_dg.


            " Deckungsgruppe
            CLEAR: ls_l_t_seltab_dg.
            ls_l_t_seltab_dg-selname = 'S_CVGR'.
            ls_l_t_seltab_dg-kind    = 'S'.
            ls_l_t_seltab_dg-sign    = 'I'.
            ls_l_t_seltab_dg-option  = 'EQ'.
            ls_l_t_seltab_dg-low     = g_t_itab-rcvrgrp_9_9h.
*           ls_l_t_seltab_dg-high    =
            APPEND ls_l_t_seltab_dg TO  l_t_seltab_dg.


            CLEAR: ls_l_t_seltab_dg.
            ls_l_t_seltab_dg-selname = 'P_CVGRBU'.
            ls_l_t_seltab_dg-kind    = 'P'.
            ls_l_t_seltab_dg-sign    = 'I'.
            ls_l_t_seltab_dg-option  = 'EQ'.
            ls_l_t_seltab_dg-low     = ' '.
*           ls_l_t_seltab_dg-high    =
            APPEND ls_l_t_seltab_dg TO  l_t_seltab_dg.


            CLEAR: ls_l_t_seltab_dg.
            ls_l_t_seltab_dg-selname = 'P_ADDRBU'.
            ls_l_t_seltab_dg-kind    = 'P'.
            ls_l_t_seltab_dg-sign    = 'I'.
            ls_l_t_seltab_dg-option  = 'EQ'.
            ls_l_t_seltab_dg-low     = ' '.
*           ls_l_t_seltab_dg-high    =
            APPEND ls_l_t_seltab_dg TO  l_t_seltab_dg.


            SUBMIT rffmce_hier_view
                   WITH SELECTION-TABLE l_t_seltab_dg
                   AND RETURN.

          ENDIF. " IF g_t_itab-rcvrgrp_9_9h IS NOT INITIAL.



        WHEN OTHERS.

*       "/ Behandlung der restlichen Felder

          PERFORM get_periods_for_fyear USING g_t_item-fyear
                                     CHANGING l_per_fr
                                              l_per_to.

*--------------------------------------------------------------------*
          CALL FUNCTION '/THKR/BCS_FB_FMKO_READ_ITEMS'    " 'ZBB_BCS_FMKO_READ_ITEMS' " 'FMKO_READ_ITEMS' aus  Report RFFMKBHH Zeile 667
            EXPORTING
              repid      = con_repid
              ref_struct = con_struct
              cfield     = u_selfield-fieldname
              fipex      = g_t_itab-fipex
              fictr      = g_t_itab-fictr
              fonds      = g_t_itab-fonds
              gjahr      = p_fyr_fr
              measure    = g_t_itab-rmeasure
            EXCEPTIONS
              not_found  = 1
              OTHERS     = 2.
          IF sy-subrc <> 0.
*             Implement suitable error handling here
          ENDIF.
*--------------------------------------------------------------------*

      ENDCASE. " CASE u_selfield-fieldname.

  ENDCASE. "   CASE u_ucomm.

ENDFORM.                               " USER_COMMAND



*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.                                           "#EC CALLED

  CALL METHOD cl_fm_listheader_create=>top_of_page
    EXPORTING
      i_title         = g_title           "Title
      i_t_object_info = g_t_object_info.  "Object information

ENDFORM.                    "top_of_page



*&---------------------------------------------------------------------*
*&      Form  HTML_TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM html_top_of_page USING r_top TYPE REF TO cl_dd_document. "#EC CALLED

  DATA:
    l_f_attributes TYPE ifm_lh_object_attributes.

*----- prepare attributes for list header
  l_f_attributes-header_width    = '100%'.
  l_f_attributes-width_col1_key  = '20%'.
  l_f_attributes-width_col1_info = '30%'.
  l_f_attributes-width_col2_key  = '20%'.
  l_f_attributes-width_col2_info = '30%'.

  CALL METHOD cl_fm_listheader_create=>html_top_of_page
    EXPORTING
      i_ref_top       = r_top             "Reference to header area
      i_title         = g_title           "Title
      i_f_width       = l_f_attributes    "Attributes
      i_t_object_info = g_t_object_info.  "Object information

ENDFORM.                    "html_top_of_page



*&---------------------------------------------------------------------*
*&      Form  FILL_EVENTS
*&---------------------------------------------------------------------*
*       Define Callback Events
*----------------------------------------------------------------------*
FORM fill_events CHANGING c_t_events TYPE slis_t_event.

*--- Work Area
  DATA: l_f_events LIKE LINE OF c_t_events.

*--- Callback events
  l_f_events-name = 'TOP_OF_PAGE'.
  l_f_events-form = 'TOP_OF_PAGE'.
  APPEND l_f_events TO c_t_events.

  l_f_events-name = 'HTML_TOP_OF_PAGE'.
  l_f_events-form = 'HTML_TOP_OF_PAGE'.
  APPEND l_f_events TO c_t_events.

ENDFORM.                               " FILL_EVENTS



*&---------------------------------------------------------------------*
*&      Form  FILL_LAYOUT
*&---------------------------------------------------------------------*
*       Define List Layout
*----------------------------------------------------------------------*
FORM fill_layout
          CHANGING c_f_layout TYPE slis_layout_alv.

  CALL FUNCTION 'FM_ALV_LAYOUT'
    CHANGING
      c_f_layout = c_f_layout.

  c_f_layout-cell_merge           = 'X'.
  c_f_layout-group_buttons        = 'X'.
  c_f_layout-no_subtotals         = space.
  c_f_layout-no_totalline         = 'X'.
  c_f_layout-totals_before_items  = 'X'.

ENDFORM.                               " FILL_LAYOUT



*&---------------------------------------------------------------------*
*&      Form  FILL_FIELDCAT
*&---------------------------------------------------------------------*
*       Transfer of fields into field catalog
*----------------------------------------------------------------------*
FORM fill_fieldcat
          CHANGING c_t_fieldcat TYPE slis_t_fieldcat_alv
                   c_t_sp_groups TYPE slis_t_sp_group_alv.

*--- Work Area
  DATA: l_f_fieldcat    LIKE LINE OF c_t_fieldcat,
        l_f_sp_groups   LIKE LINE OF c_t_sp_groups,
        l_cnt_colpos    LIKE sy-cucol,
        l_flag_payments,
        l_flag_invoices.

*--- Add 'header' FM dimension field to the fieldcatalog
  DEFINE add_header.
    CLEAR l_f_fieldcat.
    l_f_fieldcat-row_pos         = 1.
    IF NOT g_flg_fmdimactive-&2 IS INITIAL.
      IF &1 <> 0.
        l_f_fieldcat-col_pos     = &1.
      ELSE.
        ADD 10 TO l_cnt_colpos.
        l_f_fieldcat-col_pos     = l_cnt_colpos.
      ENDIF.
      l_f_fieldcat-sp_group      = 'HEAD'.
      l_f_fieldcat-tabname       = con_output_tname.
      l_f_fieldcat-fieldname     = &3.
      l_f_fieldcat-ref_tabname   = &4.
      l_f_fieldcat-ref_fieldname = &5.
      l_f_fieldcat-key           = &6.
      l_f_fieldcat-hotspot       = &8.
      l_f_fieldcat-no_sum        = 'X'.
      l_f_fieldcat-outputlen     = 15.
      IF NOT g_flg_sngl_value-&2 IS INITIAL.
*       Single value - hide by default
        l_f_fieldcat-no_out      = 'X'.
      ELSE.
        l_f_fieldcat-no_out      = &7.
      ENDIF.
      APPEND l_f_fieldcat TO c_t_fieldcat.
    ENDIF.
  END-OF-DEFINITION.

*--- Add 'item' field to the fieldcatalog
  DEFINE add_item.
    CLEAR l_f_fieldcat.
    l_f_fieldcat-row_pos         = 1.
    IF &1 <> 0.
      l_f_fieldcat-col_pos     = &1.
    ELSE.
      ADD 10 TO l_cnt_colpos.
      l_f_fieldcat-col_pos     = l_cnt_colpos.
    ENDIF.
    l_f_fieldcat-sp_group      = 'ITEM'.
    l_f_fieldcat-tabname       = con_output_tname.
    l_f_fieldcat-fieldname     = &3.
    l_f_fieldcat-ref_tabname   = &4.
    l_f_fieldcat-ref_fieldname = &5.
    l_f_fieldcat-key           = &6.
    l_f_fieldcat-hotspot       = &8.
    l_f_fieldcat-no_sum        = 'X'.
    l_f_fieldcat-outputlen     = 15.
    IF NOT g_flg_sngl_value-&2 IS INITIAL.
*     Single value - hide by default
      l_f_fieldcat-no_out      = 'X'.
    ELSE.
      l_f_fieldcat-no_out      = &7.
    ENDIF.
    APPEND l_f_fieldcat TO c_t_fieldcat.
  END-OF-DEFINITION.

*--- Add 'amount item' field to the fieldcatalog
  DEFINE add_amount_item.
    CLEAR l_f_fieldcat.
    l_f_fieldcat-row_pos        = 1.
    IF &1 <> 0.
      l_f_fieldcat-col_pos      = &1.
    ELSE.
      ADD 10 TO l_cnt_colpos.
      l_f_fieldcat-col_pos      = l_cnt_colpos.
    ENDIF.
    l_f_fieldcat-sp_group       = 'ITEM'.
    l_f_fieldcat-tabname        = con_output_tname.
    l_f_fieldcat-fieldname      = &2.
    l_f_fieldcat-ref_tabname    = &3.
    l_f_fieldcat-ref_fieldname  = &4.
    l_f_fieldcat-seltext_s      = &5.
    l_f_fieldcat-seltext_m      = &5.
    l_f_fieldcat-seltext_l      = &5.
    l_f_fieldcat-reptext_ddic   = &5.
    l_f_fieldcat-emphasize      = &6.
    l_f_fieldcat-cfieldname     = 'FWAER'.
    l_f_fieldcat-no_zero        = 'X'.
    l_f_fieldcat-no_out         = ' '.
    l_f_fieldcat-hotspot        = ' '.
    l_f_fieldcat-no_sum         = ' '.
    l_f_fieldcat-do_sum         = &7.
    l_f_fieldcat-outputlen      = 15.
    APPEND l_f_fieldcat TO c_t_fieldcat.
  END-OF-DEFINITION.

  PERFORM check_update_profile CHANGING l_flag_invoices
                                        l_flag_payments.

*--- H E A D E R   F I E L D S
*--- Fields which are output in default variant of header
  add_header 0 grant_nbr 'RGRANT_NBR' 'FMAA_BA' 'GRANT_NBR' ' ' ' ' 'X'.
  add_header 0 fund      'RFUND'      'FMAA_BA' 'FONDS'     ' ' ' ' 'X'.
  IF cl_psm_switch_check=>psm_fm_bud_per_rev_1( ) IS NOT INITIAL.
    add_header 0 budget_pd 'RBUDGET_PD' 'FMAA_BA' 'BUDGET_PD' ' ' ' ' 'X'.
  ENDIF.
  add_header 0 fundsctr  'RFUNDSCTR'  'FMAA_BA' 'FICTR'     ' ' ' ' 'X'.
  add_header 0 cmmtitem  'RCMMTITEM'  'FMAA_BA' 'FIPEX'     ' ' ' ' 'X'.
  add_header 0 funcarea  'RFUNCAREA'  'FMAA_BA' 'FAREA'     ' ' ' ' 'X'.
  add_header 0 measure   'RMEASURE'   'FMAA_BA' 'MEASURE'   ' ' ' ' 'X'.
  add_header 0 userdim   'RUSERDIM'   'FMAA_BA' 'USERDIM'   ' ' ' ' 'X'.

*---  I T E M   F I E L D S
*---  Fields which are output in default variant of items
  add_item  0 fikrs   'FIKRS'    'BUDT' 'RFIKRS'     ' ' ' ' 'X'.
  add_item  0 budcat  'BUDCAT'   'BUDT' 'RLDNR'      ' ' ' ' 'X'.
  add_item  0 version 'VERSION'  'BUDT' 'RVERS'      ' ' ' ' 'X'.
  add_item  0 fyear   'FYEAR'    'BUDT' 'RYEAR'      ' ' ' ' 'X'.

  add_item  0 process 'PROCESS'  'BUDT' 'PROCESS_9'  ' ' ' ' 'X'.
  add_item  0 budtype 'BUDTYPE'  'BUDT' 'BUDTYPE_9'  ' ' ' ' 'X'.

***  add_amount_item  0  'BUDGET'   'BUDT' 'HAMOUNT' TEXT-001 'C410' 'X'.
  add_amount_item  0  'BUDGET'   'BUDT' 'HAMOUNT' TEXT-001 'C410' ''.


* Add invoice-related fields to the items default variant
  IF l_flag_payments = 'X'.
    add_amount_item  0 'PAYMENT' 'BUDT' 'HAMOUNT' TEXT-002 'C400' ' '.
***    add_amount_item  0 'BUD_PMT' 'BUDT' 'HAMOUNT' TEXT-003 'C410' 'X'.
    add_amount_item  0 'BUD_PMT' 'BUDT' 'HAMOUNT' TEXT-003 'C410' ' '.
  ENDIF.

* Add payment-related fields to the items default variant
  IF l_flag_invoices = 'X'.
    add_amount_item  0 'INVOICE' 'BUDT' 'HAMOUNT' TEXT-004 'C400' ' '.
***    add_amount_item  0 'BUD_INV' 'BUDT' 'HAMOUNT' TEXT-005 'C410' 'X'.
    add_amount_item  0 'BUD_INV' 'BUDT' 'HAMOUNT' TEXT-005 'C410' ' '.
  ENDIF.

* Add open item-related fields to the items default variant
  add_amount_item  0 'OPITEMS'   'BUDT' 'HAMOUNT' TEXT-006 'C400' ' '.
***  add_amount_item  0 'RS_BUDGET' 'BUDT' 'HAMOUNT' TEXT-007 'C410' 'X'.
  add_amount_item  0 'RS_BUDGET' 'BUDT' 'HAMOUNT' TEXT-007 'C410' ' '.

* add_header  0 fwaer 'FWAER' 'FKRS' 'FIKRS'  ' '  ' '  ' '.

*--- Load Special Groups`
  CLEAR  l_f_sp_groups.
  l_f_sp_groups-sp_group = 'HEAD'.
  l_f_sp_groups-text = TEXT-501.
  APPEND l_f_sp_groups TO c_t_sp_groups.
  CLEAR  l_f_sp_groups.
  l_f_sp_groups-sp_group = 'ITEM'.
  l_f_sp_groups-text = TEXT-502.
  APPEND l_f_sp_groups TO c_t_sp_groups.

  CALL METHOD cl_fm_switch_field_util_appl=>adjust_fieldcat_slis
    CHANGING
      ct_fieldcat = c_t_fieldcat.

ENDFORM.                               " FILL_FIELDCAT



*&---------------------------------------------------------------------*
*&      Form  FILL_SEL_CRIT                                            *
*&---------------------------------------------------------------------*
*       Define Selective Hide Criteria                                 *
*----------------------------------------------------------------------*
FORM fill_sel_crit
               CHANGING c_t_sel_crit TYPE slis_sel_hide_alv.

*--- Workarea
  DATA: l_f_entries LIKE LINE OF c_t_sel_crit-t_entries.

*--- Delete selections from the display selections
  DEFINE delete_from_selection_display.
    l_f_entries-mode    = 'D'.
    l_f_entries-selname = &1.
    APPEND l_f_entries TO c_t_sel_crit-t_entries.
  END-OF-DEFINITION.

*--- Modify the selection Criterion
  c_t_sel_crit-mode = 'C'.

*--- Delete the following fields from the Display Selections in the list

*  Only master data posted to parameter
  delete_from_selection_display 'P_STAMM'.

* No 'reading order' flags
  delete_from_selection_display 'P_FMBUD'.
  delete_from_selection_display 'P_BUDFM'.

ENDFORM.                    "fill_sel_crit



*&---------------------------------------------------------------------*
*&      Form  FILL_SORT
*&---------------------------------------------------------------------*
*       Define sort information for the standart list
*----------------------------------------------------------------------*
FORM fill_sort CHANGING c_t_sort TYPE slis_t_sortinfo_alv.

  DATA: l_f_sort   LIKE LINE OF  c_t_sort,
        l_cnt_spos LIKE alvdynp-sortpos.

  FIELD-SYMBOLS:
        <fs_sortinfo> TYPE slis_sortinfo_alv.

  DEFINE set_sort_fmdim_param.
    IF NOT g_flg_fmdimactive-&1 IS INITIAL
    AND g_flg_sngl_value-&1 IS INITIAL.
*     Field active and not moved to header
      CLEAR l_f_sort.
      ADD 1 TO l_cnt_spos.
      l_f_sort-spos      = l_cnt_spos.
      l_f_sort-tabname   = con_output_tname.
      l_f_sort-fieldname = &2.
      l_f_sort-up        = 'X'.
      l_f_sort-subtot    = &3.
      l_f_sort-comp      = &4.
      APPEND l_f_sort TO c_t_sort.
    ENDIF.
  END-OF-DEFINITION.

  DEFINE set_sort_param.
    IF g_flg_sngl_value-&1 IS INITIAL.
*     Field not moved to header
      CLEAR l_f_sort.
      ADD 1 TO l_cnt_spos.
      l_f_sort-spos      = l_cnt_spos.
      l_f_sort-tabname   = con_output_tname.
      l_f_sort-fieldname = &2.
      l_f_sort-up        = 'X'.
      l_f_sort-subtot    = &3.
      l_f_sort-comp      = &4.
      APPEND l_f_sort TO c_t_sort.
    ENDIF.
  END-OF-DEFINITION.

  set_sort_fmdim_param  grant_nbr  'RGRANT_NBR'  ' '  ' '.
  set_sort_fmdim_param  fund       'RFUND'       ' '  ' '.
  IF cl_psm_switch_check=>psm_fm_bud_per_rev_1( ) IS NOT INITIAL.
    set_sort_fmdim_param  budget_pd    'RBUDGET_PD'       ' '  ' '.
  ENDIF.
  set_sort_fmdim_param  fundsctr   'RFUNDSCTR'   ' '  ' '.
  set_sort_fmdim_param  cmmtitem   'RCMMTITEM'   ' '  ' '.
  set_sort_fmdim_param  funcarea   'RFUNCAREA'   ' '  ' '.
  set_sort_fmdim_param  measure    'RMEASURE'    ' '  ' '.
  set_sort_fmdim_param  userdim    'RUSERDIM'    ' '  ' '.
* Default subtotal columns
  set_sort_param        fikrs      'FIKRS'       'X'  'X'.
  set_sort_param        budcat     'BUDCAT'      'X ' 'X'.
  set_sort_param        version    'VERSION'     'X'  'X'.
  set_sort_param        fyear      'FYEAR'       'X'  'X'.

* Get the last entry of sort table
  READ TABLE c_t_sort
    INDEX sy-tfill
    ASSIGNING <fs_sortinfo>.

  IF sy-subrc = 0.
*   There must be at least one 'subtotal' column !
*   (if all default subtotal columns were hidden because of single
*   values, then set the subtotals flag on last FM dimension column)
    <fs_sortinfo>-subtot = 'X'.
  ENDIF.

ENDFORM.                               " FILL_SORT



*&---------------------------------------------------------------------*
*&      Form  FILL_FILTER_TABLE
*&---------------------------------------------------------------------*
*       Define sort information for the standart list
*----------------------------------------------------------------------*
FORM fill_filter_table
                 CHANGING c_t_filt TYPE slis_t_filter_alv.  "#EC CALLED

  DATA: l_f_filt   LIKE LINE OF  c_t_filt.

  DEFINE set_filt_option.
    CLEAR l_f_filt.
    l_f_filt-fieldname = &1.
    l_f_filt-sign0     = &2.
    l_f_filt-optio     = &3.
*   l_f_filt-low       = &4.
*   l_f_filt-high      = &5.
    APPEND l_f_filt TO c_t_filt.
  END-OF-DEFINITION.

*  set_filt_option 'BUDTYPE'  'E' 'EQ' SPACE SPACE.

ENDFORM.                               " FILL_FILTER_TABLE



*&---------------------------------------------------------------------*
*&      Form  FILL_VARIANT
*&---------------------------------------------------------------------*
*       Define default Display Variant                                 *
*----------------------------------------------------------------------*
FORM fill_variant CHANGING c_f_variant LIKE disvariant.     "#EC CALLED

  CLEAR c_f_variant.
  c_f_variant-report = sy-repid.

* Define Default Variant
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = 'A'
    CHANGING
      cs_variant = c_f_variant
    EXCEPTIONS
      not_found  = 2.
ENDFORM.                               " FILL_VARIANT



*&---------------------------------------------------------------------*
*&      Form F4_DISPLAY_VARIANT
*&---------------------------------------------------------------------*
*&      F4 Help for display variant
*&---------------------------------------------------------------------*
FORM f4_display_variant.

  CLEAR g_f_disvariant.
  g_f_disvariant-report   =  sy-cprog.
  g_f_disvariant-username =  sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = g_f_disvariant
      i_save     = 'A'
    IMPORTING
      es_variant = g_f_disvariant.
  p_disvar = g_f_disvariant-variant.

ENDFORM.                     " F4_DISPLAY_VARIANT



*&---------------------------------------------------------------------*
*&   Form CHECK_DISPLAY_VARIANT
*&---------------------------------------------------------------------*
*&   Check of display variant
*&---------------------------------------------------------------------*
FORM check_display_variant.

* Dummy structures
  DATA: l_t_fieldcat TYPE slis_t_fieldcat_alv,
        l_f_layout   TYPE slis_layout_alv.

  CLEAR g_f_disvariant.

  CHECK NOT p_disvar IS INITIAL.

  g_f_disvariant-report   =  sy-cprog.
  g_f_disvariant-username =  sy-uname.
  g_f_disvariant-variant  =  p_disvar.
* "/ Read the variant
  CALL FUNCTION 'REUSE_ALV_VARIANT_SELECT'
    EXPORTING
      i_dialog            = space
      i_user_specific     = 'X'
      it_default_fieldcat = l_t_fieldcat
      i_layout            = l_f_layout
    CHANGING
      cs_variant          = g_f_disvariant
    EXCEPTIONS
      wrong_input         = 1
      fc_not_complete     = 2
      not_found           = 3
      program_error       = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.
*   "/ Variant doesn't exist
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                           " CHECK_DISPLAY_VARIANT



*&---------------------------------------------------------------------*
*&   Form INIT_SCHEDMAN
*&---------------------------------------------------------------------*
*&   initialize schedman monitor
*&   note: commit work executed
*&---------------------------------------------------------------------*
FORM init_schedman.

*----- initialize schedman monitor
  CALL FUNCTION 'FM_FYC_SCHEDMAN_INIT'
    EXPORTING
      i_repid          = con_repid
      i_wfitem         = wf_witem
      i_wflist         = wf_wlist
    IMPORTING
      e_f_schedman_key = g_f_schedman_key.

ENDFORM.                           " INIT_SCHEDMAN


*&---------------------------------------------------------------------*
*&   Form CLOSE_SCHEDMAN
*&---------------------------------------------------------------------*
*&   send info to schedman monitor
*&   note: commit work executed
*&---------------------------------------------------------------------*
FORM close_schedman.

  DATA: l_f_lines LIKE sy-tfill.

  DESCRIBE TABLE g_t_item LINES l_f_lines.

*----- send info to schedman monitor
  CALL FUNCTION 'FM_FYC_SCHEDMAN_CLOSE'
    EXPORTING
      i_f_schedman_key = g_f_schedman_key
      i_wfitem         = wf_witem
      i_wfokey         = wf_okey
      i_aplstat        = g_aplstat
      i_cnt_obj        = l_f_lines.

ENDFORM.                           " CLOSE_SCHEDMAN





*&---------------------------------------------------------------------*
*&      Form  INIT_KEYFIGURES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_PGJAHR  text
*----------------------------------------------------------------------*
FORM init_keyfigures  USING    p_lv_pgjahr TYPE gjahr.

  DATA: l_t_keyfigs TYPE fmkf_kftab WITH HEADER LINE.

* Kennzahlen initialisieren
  CALL FUNCTION '/THKR/BCS_INIT'    " 'ZBB_BCS_INIT'
    EXPORTING
      i_gjahr     = p_lv_pgjahr
      i_t_keyfigs = l_t_keyfigs[].


ENDFORM.




*&---------------------------------------------------------------------*
*&      Form  CHANGE_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FMKF_FMTOX  text
*      -->P_FMTOX  text
*      <--P_G_T_ITAB  text
*----------------------------------------------------------------------*
FORM change_value      USING u_tabname
                             u_f_data
                    CHANGING c_t_fmrkhpl.


*------------------- Konstanten ------------------------
  CONSTANTS con_itab LIKE dd03l-tabname VALUE 'G_T_ITAB'.


  DATA: l_t_keyfigs  TYPE fmrkf_t_keyfig,
        l_wa_keyfigs LIKE fmrkf_s_keyfig.

  DATA: l_valuename(64) TYPE c.
  FIELD-SYMBOLS : <field>.


* /THKR/BCS_KEYFIGURES_GET Ermitteln der Kennzahlen für einen Datensatz
  CALL FUNCTION '/THKR/BCS_KEYFIGURES_GET'  " 'ZBB_BCS_KEYFIGURES_GET'
    EXPORTING
      i_f_data    = u_f_data
      i_datatype  = u_tabname
    IMPORTING
      e_t_keyfigs = l_t_keyfigs.



  LOOP AT l_t_keyfigs INTO l_wa_keyfigs
               WHERE NOT value IS INITIAL.

    CONCATENATE con_itab '-' l_wa_keyfigs-keyfig INTO l_valuename.
    ASSIGN (l_valuename) TO <field>.

    IF sy-subrc = 0.

      <field> = <field> + l_wa_keyfigs-value.

    ENDIF.

  ENDLOOP.


ENDFORM.



*&---------------------------------------------------------------------*
*&      Form  SET_FIPEX_ELEMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_T_ITAB  text
*----------------------------------------------------------------------*
FORM set_fipex_element TABLES c_t_fmrkbhh STRUCTURE g_t_itab.

  DATA: ls_master_data TYPE fmaa_ba.



  SORT g_t_master_data BY fipex fictr fonds farea.

  LOOP AT c_t_fmrkbhh.


    CLEAR: ls_master_data.
    READ TABLE g_t_master_data INTO ls_master_data
                               WITH KEY fipex = g_t_itab-fipex
                                        fictr = g_t_itab-fictr
                                        fonds = g_t_itab-fonds
                                BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_master_data TO c_t_fmrkbhh.
      c_t_fmrkbhh-augrp = ls_master_data-augrp_fipex.
    ENDIF.

    g_fsfipex = g_t_itab-fipex.

    MOVE <praefix>  TO c_t_fmrkbhh-praefix.
    MOVE <gld>      TO c_t_fmrkbhh-gld.
    MOVE <epl>      TO c_t_fmrkbhh-epl.
    MOVE <abschn>   TO c_t_fmrkbhh-abschn.
    MOVE <uabsch>   TO c_t_fmrkbhh-uabsch.
    MOVE <gruppe>   TO c_t_fmrkbhh-gruppe.
    MOVE <hgr>      TO c_t_fmrkbhh-hgr.
    MOVE <grp>      TO c_t_fmrkbhh-grp.
    MOVE <ugr>      TO c_t_fmrkbhh-ugr.
    MOVE <mass>     TO c_t_fmrkbhh-mass.
    MOVE <hmass>    TO c_t_fmrkbhh-hmass.
    MOVE <massn>    TO c_t_fmrkbhh-massn.
    MOVE <umass>    TO c_t_fmrkbhh-umass.
    MOVE <obj>      TO c_t_fmrkbhh-obj.
    MOVE <pruefz>   TO c_t_fmrkbhh-pruefz.


* DS20210827 ****>>> Include IHHPLNRUX in RFFMKBHH
    PERFORM set_value_sign USING con_struct
                                 ls_master_data-potyp
                        CHANGING c_t_fmrkbhh.

    MODIFY c_t_fmrkbhh.

  ENDLOOP. "   LOOP AT c_t_fmrkbhh.


ENDFORM.




*&---------------------------------------------------------------------*
*&      Form  GET_DEFAULTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_defaults .


* Kennzahlen holen
  SELECT * FROM /thkr/kf_kfdsrc INTO CORRESPONDING FIELDS OF TABLE lt_zcbb_bukf_kfdsrc
    WHERE applic = 'ZB'.


*Datenquelle
*  0001 - Budgetierungsdaten (logDB: BUDT ->  SAPTab:  FMBDT)
*  0002 - Summensätze Obligo & Ist - FMTOX
*  0003 - VbK-Daten (logDB: AVCT ->  SAPTab:  FMAVCT)

ENDFORM.



*&---------------------------------------------------------------------*
*&      Form  SET_VALUE_SIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CON_STRUCT  text
*      -->P_G_T_STAMM_POTYP  text
*      <--P_G_T_ITAB  text
*----------------------------------------------------------------------*
FORM set_value_sign  USING u_structname
                           u_f_potyp TYPE fmaa-potyp
                    CHANGING c_f_struct.


**** Positionstypen
***----------------------
*** 1	  Bestand
*** 2	  Einnahmen
*** 3	  Ausgaben
*** 4	  Salden
*** 5	  Klärungsbestand

  " DS20210920

*--- 3    Ausgaben ----*
  IF u_f_potyp = '3'.
    IF g_flg_expsign = '+'.
*        "/ Ausgaben positiv anzeigen
      CALL FUNCTION '/THKR/BCS_FB_FMKBO_SET_SIGN'   " 'ZBB_BCS_FMKBO_SET_SIGN'   " 'FMKBO_SET_SIGN'
        EXPORTING
          tabname      = u_structname
          i_budget     = ' '
          i_com_act    = 'X'
        CHANGING
          value_struct = c_f_struct.
    ELSE.
*        "/ Ausgaben negativ anzeigen
      CALL FUNCTION '/THKR/BCS_FB_FMKBO_SET_SIGN'   " 'ZBB_BCS_FMKBO_SET_SIGN'   " 'FMKBO_SET_SIGN'
        EXPORTING
          tabname      = u_structname
          i_budget     = 'X'
          i_com_act    = ' '
        CHANGING
          value_struct = c_f_struct.
    ENDIF.
  ENDIF. "  IF u_f_potyp = '3'.



*--- 2    Einnahmen ----*
  IF u_f_potyp = '2'.
    IF g_flg_revsign = '-'.
*        "/ Einnahmen negativ anzeigen
      CALL FUNCTION '/THKR/BCS_FB_FMKBO_SET_SIGN'     " 'ZBB_BCS_FMKBO_SET_SIGN'   " 'FMKBO_SET_SIGN'
        EXPORTING
          tabname      = u_structname
          i_budget     = ' '
          i_com_act    = 'X'
        CHANGING
          value_struct = c_f_struct.
    ENDIF.
  ENDIF. "  IF u_f_potyp = '2'.


*--- 5    Klärungsbestand -----*
  IF u_f_potyp = '5'.
    IF g_flg_revsign = '-'.
*        "/ Einnahmen negativ anzeigen
      CALL FUNCTION '/THKR/BCS_FB_FMKBO_SET_SIGN'     " 'ZBB_BCS_FMKBO_SET_SIGN'   " 'FMKBO_SET_SIGN'
        EXPORTING
          tabname      = u_structname
          i_budget     = 'X'
          i_com_act    = 'X'
        CHANGING
          value_struct = c_f_struct.
    ENDIF.
  ENDIF. "   IF u_f_potyp = '5'.

ENDFORM.

INCLUDE /thkr/_rffmrep_ldb_pt01_v02f01.

************************************************************************
*                                                                      *
*           Umsatzsteuer-Voranmeldung RFUMSV00 mit dem ALV             *
*                                                                      *
*----------------------------------------------------------------------*
* Dieser Report basiert auf der alten Umsatzsteuer-Voranmeldung,       *
* welche nun den Namen RFUMSV00_P trägt.                               *
*----------------------------------------------------------------------*
* Korrekturen:                                                         *
*  OT-07  Note 204972   Australische Steuermeldung BAS braucht Paramet.*
*----------------------------------------------------------------------*
*  OP-01  Note 339121   Legal Requirement Thailand                     *
*----------------------------------------------------------------------*
*  OP-02  Note 356441   falsche laufende Nummer                        *
*----------------------------------------------------------------------*
*  OP-03  Note 374145   Legal Requirements Italien                     *
*----------------------------------------------------------------------*
*  OP-04  Note 375429   gestundete Steuern selektieren                 *
*----------------------------------------------------------------------*
*  OP-05  Note 351280   Fiskalische Anschrift berücksichtigen          *
*----------------------------------------------------------------------*
*  OP-06  Note 379155  Änderungen für DME Engine Anschluß              *
*----------------------------------------------------------------------*
*  OP-07  Note 335539    Formulardruck                                 *
*----------------------------------------------------------------------*
*  OP-08  Note 380868   short header, MWSKZ-Text, TRVOR und Druckeinst.*
*----------------------------------------------------------------------*
*  OP-09  Note 381346   Selektion von Hauptbuchkonten                  *
*----------------------------------------------------------------------*
*  OP-10  Note 380004   Vorzeichen von HWGROSS                         *
*----------------------------------------------------------------------*
*  OP-11  Note 377276   Reihenfolge der Vergabe der laufende Nr.       *
*----------------------------------------------------------------------*
*  OP-12  Note 362762   parallele laufende Nummern                     *
*----------------------------------------------------------------------*
*  OP-13  Note 384192   tax account number in the sum lists            *
*----------------------------------------------------------------------*
*  OP-14  Note 385260   handling update TRVOR and BSET                 *
*----------------------------------------------------------------------*
*  OP-15  Note 385378   nur eine fortlaufende Nr. pro Dokument         *
*----------------------------------------------------------------------*
*  OP-16  Note 385679   Echtlauf und Beleg speichern für Italien       *
*----------------------------------------------------------------------*
*  OP-17  Note 386165   Felder im header                               *
*----------------------------------------------------------------------*
*  OP-18  Note 386627   mehrere Sortierungen der lfd. Nummer           *
*----------------------------------------------------------------------*
*  OP-19  Note 394073   Umrechnungskurs anzeigen                       *
*----------------------------------------------------------------------*
*  OP-20  Note 400886   FI ALE FIDCC1: fehlerhaft in Zentrale          *
*----------------------------------------------------------------------*
*  OP-21  Note 408237   Fehler in Batch Input Mappe sofort abspielen   *
*----------------------------------------------------------------------*
*  OP-22  Note 407474   abzf. Vorsteuer in der Summenliste             *
*----------------------------------------------------------------------*
*  OP-23  Note 417018   Überschrift für Name1                          *
*----------------------------------------------------------------------*
*  OP-24  Note 401661   Ausgabe des Bolle Doganali Kontentextes        *
*----------------------------------------------------------------------*
*  OP-25  Note 417687   Werke im Ausland und Alternative Hauswährung   *
*----------------------------------------------------------------------*
*  OP-26  Note 422816   fehlehnder Steuerprozentsatz                   *
*----------------------------------------------------------------------*
*  OP-27  Note 422066   FI_TAX_BADI_012 ist nicht filterabhängig       *
*----------------------------------------------------------------------*
*  OP-28  Note 418476   falsches Vorzeichen des Bruttobetrages         *
*----------------------------------------------------------------------*
*  OP-29  Note 425071  Zuordnungsnummer wird nicht ausgegeben          *
*----------------------------------------------------------------------*
*  OP-30  Note 412860   falsches Hauptbuchkonto                        *
*----------------------------------------------------------------------*
*  Note 429158 Ausgabe Mikrofiche-Information                          *
*----------------------------------------------------------------------*
*  Note 736203 Fehlende USt-Identnummern in Einzelpostenliste          *
************************************************************************

REPORT rfumsv00
  LINE-COUNT (1)
  LINE-SIZE 132
  NO STANDARD PAGE HEADING
  MESSAGE-ID f7.


*----------------------------------------------------------------------*
* BADI                                                                 *
*----------------------------------------------------------------------*
* "Vorwärtsdeklaration der "Factory"
CLASS cl_exithandler DEFINITION LOAD.
* "Interfacereferenz
DATA: g_ref_to_exit_010 TYPE REF TO if_ex_fi_tax_badi_010,
      g_ref_to_exit_011 TYPE REF TO if_ex_fi_tax_badi_011,
      g_ref_to_exit_012 TYPE REF TO if_ex_fi_tax_badi_012,
      g_ref_to_exit_013 TYPE REF TO if_ex_fi_tax_badi_013,
      g_ref_to_exit_014 TYPE REF TO if_ex_fi_tax_badi_014,  "OP-06
      g_ref_to_exit_015 TYPE REF TO if_ex_fi_tax_badi_015,  "OP-06
      g_ref_to_exit_016 TYPE REF TO if_ex_fi_tax_badi_016.  "500308



*----------------------------------------------------------------------*
* Type-Pools                                                           *
*----------------------------------------------------------------------*
* ABAP List-Viewer (ALV)
TYPE-POOLS: slis.


*----------------------------------------------------------------------*
* Includes                                                             *
*----------------------------------------------------------------------*
* Icons
INCLUDE <icon>.
* Tabellen und Feldleisten
INCLUDE /thkr/i_rfums_tables.
* Parameter
INCLUDE /thkr/i_rfums_parameter.
* Die übrigen Variablen
INCLUDE i_rfums_data.
* Tabelle mit Buchungskreisen, aus denen Belege zu 4.0 umgesetzt wurden
INCLUDE fiuums40.

*----------------------------------------------------------------------*
* Macros                                                               *
*----------------------------------------------------------------------*
DEFINE heading_hw_lw.
  IF par_xstw <> space.
    &1 = &2.
  ENDIF.
END-OF-DEFINITION.


*----------------------------------------------------------------------*
* Field-Groups                                                         *
*----------------------------------------------------------------------*
FIELD-GROUPS:
  header,
  daten.

INSERT
  ep-bukrs                             "Buchungskreis
  ep-mwart                             "Umsatzsteuerart
*  ep-mwskz                             "Umsatzsteuerkennzeichen "OP-11
  ep-tax_country
  ep-mwskz                                                  "OP-17
  ep-txdat_from
  ep-bldat                                                  "OP-18
  ep-ktosl                             "Vorgangsschlüssel
  ep-buper                             "Buchungsperiode
*  ep-waers                             "Währungsschlüssel  "OP-02
  ep-waers                                                  "OP-17
  ep-budat                             "Buchungsdatum
  ep-belnr                             "Belegnummer
  hlp_sort                             "Hilfsfeld für die Sortierung
INTO header.

INSERT ep INTO daten.

*----------------------------------------------------------------------*
* Vorbelegung im Selektionsdynpro                                      *
*----------------------------------------------------------------------*
INITIALIZATION.

  TRY .
      cl_fot_tdt_btt_code=>handler->set( iv_btt_code =
      cl_fot_tdt_btt_code=>handler->mc_btt_code-rfumsv00 ).
    CATCH cx_fot_tdt_root INTO DATA(lx_tdt).
      MESSAGE lx_tdt.
  ENDTRY.

  IF cl_fot_txa_utilities=>agent->is_txa_active_for_any_cocd( ).
    flg_txa_active = abap_true.
  ENDIF.
  is_cloud = cl_cos_utilities=>is_cloud( ).

  PERFORM check_external_audit.

* suppress menu item 'Execute in background' for cloud edition "2420374
*  PERFORM suppress_bk_exec_for_cloud.   "20190830: Internal Incident: 1780055912

* make RLDNR invisible
  PERFORM make_rldnr_invisible.                             "871301

* Selection-Screen
  par_xsau = 'X'.
  par_xsvo = 'X'.
  CLEAR: par_lis5.                     "No list: Tax Difference
  "par_bina = sy-repid.

* Constants
  CLEAR hlp_vline_space.
  hlp_vline_space+0(1) = sy-vline.
  g_repid = sy-repid.

* No Authority-Check for BR_BUKRS in the logical Database BRF
  auth_buk = 'X'.

* No Authority-Check for ledger in the logical Database BRF "1036175
  auth_ldr = 'X'.                                           "1036175

* Close Selection-Screen Block 1 - 5
  par_cb1 = 'X'.
  par_cb2 = 'X'.
  par_cb3 = 'X'.
  par_cb4 = 'X'.
  par_cb5 = 'X'.
  par_cb6 = 'X'.

* Set Text & Icon for Pushbutton c1 - c5, o1 - o5
*  CONCATENATE icon_collapse: text-051 INTO pushb_c1,
*                             text-057 INTO pushb_c2,
*                             text-053 INTO pushb_c3,
*                             text-054 INTO pushb_c4,
*                             text-052 INTO pushb_c5.
*  CONCATENATE icon_expand:   text-051 INTO pushb_o1,
*                             text-057 INTO pushb_o2,
*                             text-053 INTO pushb_o3,
*                             text-054 INTO pushb_o4,
*                             text-052 INTO pushb_o5.
*Accessibility:

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_collapse
      text   = TEXT-051
*     INFO   = ' '
    IMPORTING
      result = pushb_c1
    EXCEPTIONS
      OTHERS = 3.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_collapse
      text   = TEXT-057
*     INFO   = ' '
    IMPORTING
      result = pushb_c2
    EXCEPTIONS
      OTHERS = 3.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_collapse
      text   = TEXT-053
*     INFO   = ' '
    IMPORTING
      result = pushb_c3
    EXCEPTIONS
      OTHERS = 3.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_collapse
      text   = TEXT-054
*     INFO   = ' '
    IMPORTING
      result = pushb_c4
    EXCEPTIONS
      OTHERS = 3.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_collapse
      text   = TEXT-052
*     INFO   = ' '
    IMPORTING
      result = pushb_c5
    EXCEPTIONS
      OTHERS = 3.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_collapse
      text   = TEXT-060
*     INFO   = ' '
    IMPORTING
      result = pushb_c6
    EXCEPTIONS
      OTHERS = 3.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_expand
      text   = TEXT-051
*     INFO   = ' '
    IMPORTING
      result = pushb_o1
    EXCEPTIONS
      OTHERS = 3.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_expand
      text   = TEXT-057
*     INFO   = ' '
    IMPORTING
      result = pushb_o2
    EXCEPTIONS
      OTHERS = 3.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_expand
      text   = TEXT-053
*     INFO   = ' '
    IMPORTING
      result = pushb_o3
    EXCEPTIONS
      OTHERS = 3.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_expand
      text   = TEXT-054
*     INFO   = ' '
    IMPORTING
      result = pushb_o4
    EXCEPTIONS
      OTHERS = 3.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_expand
      text   = TEXT-052
*     INFO   = ' '
    IMPORTING
      result = pushb_o5
    EXCEPTIONS
      OTHERS = 3.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_expand
      text   = TEXT-060
*     INFO   = ' '
    IMPORTING
      result = pushb_o6
    EXCEPTIONS
      OTHERS = 3.
* Check if the user is a tax auditor                        "925217
  PERFORM check_tax_audit                                   "925217
          CHANGING gd_tax_auditor.                          "925217

* Check if personal data can be blocked                     "2073571
  PERFORM check_cvp_ilm_1                                   "2073571
          CHANGING gd_cvp_active.                           "2073571

  CALL FUNCTION 'JV_ACTIVE'
    IMPORTING
      active = gd_jva_active.

*----------------------------------------------------------------------*
* Aufbereitung des Selektionsbildes im PBO                             *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

* SRF reporting task key: Align input parameter with global "2434847
  IF p_srftsk IS NOT INITIAL AND gv_srf_reporting_task_id IS INITIAL.
    gv_srf_reporting_task_id = p_srftsk. "Copy parameter to global
  ENDIF.
  IF gv_srf_reporting_task_id IS NOT INITIAL.
    p_srftsk = gv_srf_reporting_task_id. "move back
  ENDIF.

  IF gv_srf_reporting_task_id IS NOT INITIAL. "Begin of SRF "2445729
    LOOP AT SCREEN.
      IF ( screen-name = 'PAR_FILE' OR screen-name = '%_PAR_FILE_%_APP_%-TEXT' ).
        screen-invisible = '1'.
        screen-active = '0'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF. "End of SRF                                        "2445729

* check DMEE-tree for additional parameters structure       "899205
  par_dmea = parpdmea.                                      "931482
  push_dme = pushpdme.                                      "931482
  PERFORM check_dmee_param_struc.                           "899205
  parpdmea = par_dmea.                                      "931482
  pushpdme = push_dme.                                      "931482

* make RLDNR invisible
  PERFORM make_rldnr_invisible.                             "871301

  CLEAR: par_euva, par_corr, par_dyea, par_dper.            "803670
  par_euva = parpeuva.                                      "803670
  par_corr = parpcorr.                                      "803670
  par_dyea = parpdyea.                                      "803670
  par_dper = parpdper.                                      "803670

* form routines use a copy of sel_vtdt because of rgjvtax2  "1100622
  CLEAR: dso_vtdt[], dso_vtdt.                              "1100622
  dso_vtdt[] = sel_vtdt[].                                  "1100622
  READ TABLE dso_vtdt INDEX 1.                              "1100622

  IF gd_tax_auditor = 'X'.                                  "925217
    par_cb2 = 'X'.      "turn off batch input block         "925217
    par_cb5 = 'X'.      "turn off posting block             "925217
    PERFORM tax_audit_clear.                                "925217
  ENDIF.                                                    "925217

  IF gd_jva_active = abap_false.
    par_cb6 = 'X'.
  ENDIF.

  check_wia_and_modify_screen flg_xwia.

  PERFORM modify_screen_for_tax_abroad.
  PERFORM modify_screen_for_alt_rep_curr.                   "3296651

  LOOP AT SCREEN.
    PERFORM close_block USING: par_cb1 'MC1' space,
                               par_cb1 'WIA' space,
                               par_cb1 'TXA' space,
                               par_cb1 'ALW' space,         "3296651
                               par_cb1 'MO1' 'X'  ,
                               par_cb2 'MC2' space,
                               par_cb2 'MO2' 'X'  ,
                               par_cb3 'MC3' space,
                               par_cb3 'TX2' space,
                               par_cb3 'MO3' 'X'  ,
                               par_cb4 'MC4' space,
                               par_cb4 'MO4' 'X'  ,
                               par_cb5 'MC5' space,
                               par_cb5 'MO5' 'X'  ,
                               par_cb6 'MC6' space,
                               par_cb6 'MO6' 'X'  .

    IF gd_jva_active = abap_false.
      PERFORM close_block USING: par_cb6 'MO6' space.
    ENDIF.
    IF gd_tax_auditor = 'X'.                                "925217
*   turn off buttons for batch input block MO2              "925217
*   and for posting block MO5 completely                    "925217
      PERFORM close_block USING: par_cb2 'MO2' space,       "925217
                                 par_cb5 'MO5' space.       "925217
    ENDIF.                                                  "N1576305
*   XML-Erzeugung ausbauen                                  "N1576305
*   turn off par_xml                                        "925217
    IF screen-name = 'PAR_XML'.                             "925217
      screen-active = '0'.                                  "925217
      MODIFY SCREEN.                                        "925217
    ENDIF.                                                  "925217
*    ENDIF.                                      "925217    "N1576305

    IF is_cloud = abap_true.
      CLEAR: par_sofa, par_adat, par_zeit.
      IF screen-name = 'PAR_SOFA' OR
         screen-name = '%_PAR_SOFA_%_APP_%-TEXT' OR
         screen-name = 'PAR_ADAT' OR
         screen-name = '%_PAR_ADAT_%_APP_%-TEXT' OR
         screen-name = 'PAR_ZEIT' OR
         screen-name = '%_PAR_ZEIT_%_APP_%-TEXT'.
        screen-invisible = '1'.
        screen-active    = '0'.
        screen-input     = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

  ENDLOOP.
  CASE g_sscr_ucomm.
    WHEN 'UCOMM_O1'.                   "Open Block 1
      SET CURSOR FIELD 'SEL_TMTI-LOW'.
    WHEN 'UCOMM_O2'.                   "Open Block 2
      SET CURSOR FIELD 'PAR_ZEIT'.
    WHEN 'UCOMM_O3'.                   "Open Block 3
      SET CURSOR FIELD 'PAR_LINE'.
    WHEN 'UCOMM_O4'.                   "Open Block 4
      SET CURSOR FIELD 'PAR_VAR7'.
    WHEN 'UCOMM_O5'.                   "Open Block 5
      SET CURSOR FIELD 'PAR_SNIN'.
    WHEN 'UCOMM_O6'.                   "Open Block 6
      SET CURSOR FIELD 'SEL_VNAM-LOW'.
    WHEN OTHERS.
      SET CURSOR FIELD g_cursor_field.
  ENDCASE.

*----------------------------------------------------------------------*
* Prüfung der Eingaben in den Selektionsdynpro "ON sel_field"          *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON sel_bupl.                            "OP-01
* perform check_selction_variable using 'B_BUPLA'.  "OP-01
  PERFORM check_selection_variable.
**        TABLES sel_bupl.         "OP-01                   "2171571

AT SELECTION-SCREEN ON par_var1.
  PERFORM alv_variante_exist USING c_auste_ep
                                   par_var1.

AT SELECTION-SCREEN ON par_var2.
  PERFORM alv_variante_exist USING c_auste_sum
                                   par_var2.

AT SELECTION-SCREEN ON par_var3.
  PERFORM alv_variante_exist USING c_voste_ep
                                   par_var3.

AT SELECTION-SCREEN ON par_var4.
  PERFORM alv_variante_exist USING c_voste_sum
                                   par_var4.

AT SELECTION-SCREEN ON par_var5.
  PERFORM alv_variante_exist USING c_sdiff_ep
                                   par_var5.

AT SELECTION-SCREEN ON par_var6.
  PERFORM alv_variante_exist USING c_bukrs
                                   par_var6.

AT SELECTION-SCREEN ON par_var7.
  PERFORM alv_variante_exist USING c_bukrs_sum
                                   par_var7.

AT SELECTION-SCREEN.
*--->>> EOL-0083 24.04.2024
  IF so_gsber[] IS NOT INITIAL AND par_bina IS INITIAL.     "gaa240122
    READ TABLE so_gsber INDEX 1.                            "gaa240122
    CONCATENATE '242' so_gsber-low INTO par_bina.           "gaa240122
  ENDIF.                                                    "gaa240122
*---<<<
* SRF reporting task key: Align input parameter with global "2434847
  IF gv_srf_reporting_task_id IS NOT INITIAL.
    p_srftsk = gv_srf_reporting_task_id.
  ENDIF.
  IF sy-ucomm = 'SPOS'. "creating screen variant            "2434847
    CLEAR: p_srftsk. "always w/o SRF-rep parameter          "2434847
  ENDIF.

  CLEAR: par_euva, par_corr, par_dyea, par_dper.            "803670
  par_euva = parpeuva.                                      "803670
  par_corr = parpcorr.                                      "803670
  par_dyea = parpdyea.                                      "803670
  par_dper = parpdper.                                      "803670

  IF br_bukrs[] IS NOT INITIAL.
    PERFORM check_jva_active
          USING br_bukrs[]
          CHANGING gd_jva_active.
    IF gd_jva_active = abap_false.
      CLEAR: par_xjvs, sel_vnam, sel_grou.
    ENDIF.
  ENDIF.

  " Electronic Advance Return is not allowed with active Joint Venture split
  IF par_xjvs = abap_true AND
     parpeuva = abap_true.
    MESSAGE e285.
  ENDIF.
* form routines use a copy of sel_vtdt because of rgjvtax2  "1100622
  CLEAR: dso_vtdt[], dso_vtdt.                              "1100622
  dso_vtdt[] = sel_vtdt[].                                  "1100622
  READ TABLE dso_vtdt INDEX 1.                              "1100622

  GET CURSOR FIELD g_cursor_field.

  IF flg_xwia = space.
    CLEAR: par_xstw, sel_lstm, sel_taxc, par_rcty.
    REFRESH: sel_lstm, sel_taxc.
  ENDIF.

* Wurden Umsatzsteuerkreise abgegrenzt?
  DESCRIBE TABLE sel_ukrs LINES cnt_lines.
  IF cnt_lines > 0.
    flg_umkrs = 1.             "Es wurden Umsatzsteuerkreise abgegrenzt.
    CALL FUNCTION 'TAX_UMKRS_TIMEDEP_ACTIVE'                 "N1542782
      IMPORTING                                              "N1542782
        e_umkrs_active = gd_umkrs_active               "N1542782
      TABLES                                                 "N1542782
        t_r_bukrs      = br_bukrs                      "N1542782
        t_r_umkrs      = sel_ukrs                      "N1542782
        t_r_budat      = br_budat                      "N1542782
        t_r_bldat      = sel_bldt                      "N1542782
        t_r_vatdate    = dso_vtdt                      "N1542782
        t_r_gjahr      = br_gjahr                      "2431897
        t_r_monat      = sel_mona                      "2431897
      .                                               "N1542782
    IF gd_umkrs_active = 'X'.                               "N1542782
      flg_umkrs = 2.                                        "N1542782
    ENDIF.                                                  "N1542782
  ELSE.
    flg_umkrs = 0.             "Es wurden Buchungskreise abgegrenzt.
  ENDIF.

  g_sscr_ucomm = sscrfields-ucomm.
* Auf die User-Commands reagieren
  CASE sscrfields-ucomm.
    WHEN 'UCOMM_O1'.                   "Open Block 1
      CLEAR par_cb1.
    WHEN 'UCOMM_C1'.                   "Close Block 1
      par_cb1 = 'X'.
    WHEN 'UCOMM_O2'.                   "Open Block 2
      CLEAR par_cb2.
    WHEN 'UCOMM_C2'.                   "Close Block 2
      par_cb2 = 'X'.
    WHEN 'UCOMM_O3'.                   "Open Block 3
      CLEAR par_cb3.
    WHEN 'UCOMM_C3'.                   "Close Block 3
      par_cb3 = 'X'.
    WHEN 'UCOMM_O4'.                   "Open Block 4
      CLEAR par_cb4.
    WHEN 'UCOMM_C4'.                   "Close Block 4
      par_cb4 = 'X'.
    WHEN 'UCOMM_O5'.                   "Open Block 5
      CLEAR par_cb5.
    WHEN 'UCOMM_C5'.                   "Close Block 5
      par_cb5 = 'X'.
    WHEN 'UCOMM_O6'.                   "Open Block 6
      CLEAR par_cb6.
    WHEN 'UCOMM_C6'.                   "Close Block 6
      par_cb6 = 'X'.
    WHEN 'CON1'.                       "Ausgabeliste konfigurieren
      PERFORM config_list USING '1'.
    WHEN 'CON2'.                       "Ausgabeliste konfigurieren
      PERFORM config_list USING '2'.
    WHEN 'CON3'.                       "Ausgabeliste konfigurieren
      PERFORM config_list USING '3'.
    WHEN 'CON4'.                       "Ausgabeliste konfigurieren
      PERFORM config_list USING '4'.
    WHEN 'CON5'.                       "Ausgabeliste konfigurieren
      PERFORM config_list USING '5'.
    WHEN 'CON6'.                       "Ausgabeliste konfigurieren
      PERFORM config_list USING '6'.
    WHEN 'CON7'.                       "Ausgabeliste konfigurieren
      PERFORM config_list USING '7'.
    WHEN 'UCOMM_DMEE'.
*      PERFORM suppress_bk_exec_for_cloud.   " NOTE 2420374   "20190830: Internal Incident: 1780055912
    WHEN OTHERS.                       "Input-Validierung
      PERFORM check_selection_screen.
*--->>> EOL-0083 24.04.2024
      PERFORM check_gsber.
*---<<<
  ENDCASE.

* This must be the last action in selection screen          "1307450
* processing. Events like sending of a message              "1307450
* can cause changes of -ucomm by giving the user a          "1307450
* chance to press another button.                           "1307450
  CLEAR gd_exec_and_print.                                  "1307450
  IF sscrfields-ucomm = 'PRIN'.                             "1307450
    gd_exec_and_print = 'X'.                                "1307450
  ENDIF.                                                    "1307450

*----------------------------------------------------------------------*
* F4-Hilfe für die Anzeigevarianten (ALV)                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_var1.
  PERFORM alv_variante_f4 USING c_auste_ep.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_var2.
  PERFORM alv_variante_f4 USING c_auste_sum.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_var3.
  PERFORM alv_variante_f4 USING c_voste_ep.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_var4.
  PERFORM alv_variante_f4 USING c_voste_sum.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_var5.
  PERFORM alv_variante_f4 USING c_sdiff_ep.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_var6.
  PERFORM alv_variante_f4 USING c_bukrs.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_var7.
  PERFORM alv_variante_f4 USING c_bukrs_sum.


*----------------------------------------------------------------------*
* F4-Hilfe für den Lauf                                                *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_laud.
  PERFORM f4_lauf(rfuvde00) USING 'D' par_laud par_laui.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_laui.
  PERFORM f4_lauf(rfuvde00) USING 'I' par_laud par_laui.



*----------------------------------------------------------------------*
* Vorbereitungen                                                       *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM scma_init.                                        "2768541


  IF gv_srf_reporting_task_id IS NOT INITIAL. "Begin of SRF   "2445729
    CALL METHOD cl_srf_wrapper=>get_instance
      EXPORTING
        iv_task_key = gv_srf_reporting_task_id
      RECEIVING
        ro_wrapper  = DATA(lo_wrapper).
  ENDIF.

  IF lo_wrapper IS BOUND.
    DATA: lt_report_run_parameter TYPE TABLE OF srfs_rep_run_par_d.
    DATA: ls_report_run_parameter TYPE srfs_rep_run_par_d.

    LOOP AT br_bukrs INTO DATA(ls).
      MOVE-CORRESPONDING ls TO  ls_report_run_parameter.
      ls_report_run_parameter-selopt_option = ls-option.
      ls_report_run_parameter-param_id = 'BR_BUKRS'.
      APPEND ls_report_run_parameter TO lt_report_run_parameter.
      CLEAR ls_report_run_parameter.
    ENDLOOP.

    LOOP AT br_budat INTO DATA(lsdata).
      MOVE-CORRESPONDING lsdata TO  ls_report_run_parameter.
      ls_report_run_parameter-selopt_option = lsdata-option.
      ls_report_run_parameter-param_id = 'BR_BUDAT'.
      APPEND ls_report_run_parameter TO lt_report_run_parameter.
      CLEAR ls_report_run_parameter.
    ENDLOOP.

    LOOP AT sel_ukrs INTO DATA(ls_ukrs).
      MOVE-CORRESPONDING ls_ukrs TO ls_report_run_parameter.
      ls_report_run_parameter-selopt_option = ls_ukrs-option.
      ls_report_run_parameter-param_id = 'SEL_UKRS'.
      APPEND ls_report_run_parameter TO lt_report_run_parameter.
      CLEAR ls_report_run_parameter.
    ENDLOOP.

    CALL METHOD lo_wrapper->create_srf_report_run
      EXPORTING
        it_rep_run_par = lt_report_run_parameter.
  ENDIF. "End of SRF                                          "2445729

* Exit the execution when the Batch Job is checked in
* UI Application Job
  IF p_check IS NOT INITIAL.
    EXIT.
  ENDIF.
  " check if bseg has been declustered or not
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name     = 'BSEG'
    IMPORTING
      dd02v_wa = ls_dd02v_wa_bseg.
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name     = 'BSET'
    IMPORTING
      dd02v_wa = ls_dd02v_wa_bset.
  "use external optimization if bseg has been declustered
  IF ls_dd02v_wa_bseg-tabclass EQ 'TRANSP' AND ls_dd02v_wa_bset-tabclass EQ 'TRANSP'.
    "PERFORM process_result.
    xhana = 'E'.
  ENDIF.
  b0sg-xcurr = 'X'.                                         "455755

  CLEAR gd_selection_stopped.                               "1066663

  CLEAR: par_euva, par_corr, par_dyea, par_dper.            "803670
  par_euva = parpeuva.                                      "803670
  par_corr = parpcorr.                                      "803670
  par_dyea = parpdyea.                                      "803670
  par_dper = parpdper.                                      "803670

* form routines use a copy of sel_vtdt because of rgjvtax2  "1100622
  CLEAR: dso_vtdt[], dso_vtdt.                              "1100622
  dso_vtdt[] = sel_vtdt[].                                  "1100622
  READ TABLE dso_vtdt INDEX 1.                              "1100622

* Internal table tab_001 can only be built correctly after   "893630
* processing get bkpf. If it has been used during parameter  "893630
* checks it needs to be refreshed here.                      "893630
* It may be created incomplete in form routine check_euva.   "893630
  REFRESH tab_001.                                          "893630
* XML-Erezugung ausbauen, deshlab PAR_XML löschen           "N1576305
  CLEAR par_xml.                                            "N1576305

  PERFORM badi_preparation.

  CASE par_avpn.
    WHEN '1'. var_avp1 = 'X'.
    WHEN '2'. var_avp2 = 'X'.
    WHEN '3'. var_avp3 = 'X'.
    WHEN '4'. var_avp4 = 'X'.
    WHEN '5'. var_avp5 = 'X'.
    WHEN '6'. var_avp6 = 'X'.
    WHEN '7'. var_avp7 = 'X'.
    WHEN OTHERS. flg_notp = 'X'.
  ENDCASE.

* Last Check
  IF flg_xwia = 'X' AND par_xstw = 'X'.
    IF flg_txa_active = abap_true.
      PERFORM wia_tax_decl_country(sapdbbrf) USING sel_taxc-low.
      " Fill G_WAERS
      PERFORM wia_tax_decl_country USING sel_taxc-low.      "3296651
    ELSE.
      PERFORM wia_tax_decl_country(sapdbbrf) USING sel_lstm-low.
      " Fill G_WAERS
      PERFORM wia_tax_decl_country USING sel_lstm-low.      "3296651
    ENDIF.
  ENDIF.

* Set output language                                       "1263340
  IF NOT par_lang IS INITIAL.                               "1263340
    IF NOT sy-batch IS INITIAL                              "1263340
       OR NOT gd_exec_and_print IS INITIAL.                 "1307450
      GET LOCALE LANGUAGE gd_locale_language                "1263340
                 COUNTRY  gd_locale_country                 "1263340
                 MODIFIER gd_locale_modifier.               "1263340
      TRY.                                                  "1263340
          SET LOCALE LANGUAGE par_lang.                     "1263340
          SET LANGUAGE sy-langu.                            "1263340
          IF NOT g_bukrs_land IS INITIAL.                   "1263340
            SET COUNTRY g_bukrs_land.                       "1263340
          ENDIF.                                            "1263340
        CATCH cx_sy_localization_error.                     "1263340
          CLEAR: gd_locale_language,                        "1263340
                 gd_locale_country.                         "1263340
          MESSAGE s146                                      "1263340
                  WITH par_lang g_bukrs_land.               "1263340
          APPEND VALUE #( id = sy-msgid type = sy-msgty number = sy-msgno ) TO gt_message_all.
      ENDTRY.                                               "1263340
    ENDIF.                                                  "1263340
  ENDIF.                                                    "1263340

  COMMIT WORK.
  IF NOT ( sel_tmti IS INITIAL ).
    ran_tmti[] = sel_tmti[].
  ENDIF.
  copy sel_cpud to br_cpudt.
  copy sel_bldt to br_bldat.
  copy sel_vtdt to br_vatdt.                                "N1023317
  READ TABLE br_bldat INDEX 1.
  READ TABLE br_vatdt INDEX 1.                              "N1023317
  hlp_stmdt = sy-datum.
  hlp_stmti = sy-uzeit.
  REFRESH tab_bset_key.

  IF flg_umkrs = 1.
*   Es wurden Umsatzsteuerkreise abgegrenzt.
    REFRESH br_bukrs.
    CLEAR br_bukrs.
    br_bukrs-sign = 'I'.
    br_bukrs-option = 'EQ'.
*   Zugehörige Buchungskreise holen.
    SELECT * FROM t007f
      WHERE umkrs IN sel_ukrs.
      SELECT * FROM t001
        WHERE umkrs = t007f-umkrs.
        br_bukrs-low = t001-bukrs.
        APPEND br_bukrs.
*note 877045: feststellen, für welche Buchungskreise der Splitter aktiv ist.
        APPEND t001-bukrs TO lt_bukrs_hlp.

        CALL METHOD cl_fagl_split_services=>check_activity
          EXPORTING
            it_bukrs  = lt_bukrs_hlp          "time-dep split
            id_budat  = par_bdat
          RECEIVING
            rb_active = ld_active_split
          EXCEPTIONS
            OTHERS    = 1.

        IF ld_active_split = abap_true.
          APPEND t001-bukrs TO gt_bukrs_split_act.
        ENDIF.
        CLEAR ld_active_split.
        REFRESH lt_bukrs_hlp.
*end of note 877045
      ENDSELECT.
    ENDSELECT.

    CALL FUNCTION 'BUKRS_AUTHORITY_CHECK'                   "<<<< 31H
      EXPORTING
        xdatabase = 'B'                             "<<<< 31H
      TABLES
        xbukreis  = br_bukrs.                       "<<<< 31H
  ELSE.
* note 877045: wenn Buchungskreise abgegrenzt wurden muss ermittelt werden, welche
* Bukrs den splitter nutzen
    IF flg_umkrs = '0'.                                     "N1542782
      SELECT bukrs FROM t001 INTO TABLE lt_selected_bukrs
                        WHERE bukrs IN br_bukrs.
    ELSE.                                                   "N1542782
*     flg_umkrs = 2 -->                                      "N1542782
      lt_selected_bukrs[] = lt_all_bukrs[].                 "N1542782
      br_bukrs[]          = gt_range_bukrs[].               "N1542782
    ENDIF.                                                  "N1542782
    LOOP AT lt_selected_bukrs INTO ls_selected_bukrs.

      APPEND ls_selected_bukrs TO lt_bukrs_hlp.

      CALL METHOD cl_fagl_split_services=>check_activity
        EXPORTING
          it_bukrs  = lt_bukrs_hlp            "time-dep split
          id_budat  = par_bdat
        RECEIVING
          rb_active = ld_active_split
        EXCEPTIONS
          OTHERS    = 1.

      IF ld_active_split = abap_true.
        APPEND ls_selected_bukrs TO gt_bukrs_split_act.
      ENDIF.

      CLEAR ld_active_split.
      REFRESH lt_bukrs_hlp.

    ENDLOOP.
*   end note 877045
  ENDIF.


* Tabelle T007B einlesen
  SELECT * FROM t007b INTO TABLE tab_007b.

* Report-Titel aufbauen; FLG_PERSEL setzen
  PERFORM create_report_title.

* Batch-Heading vorbereiten
  bhdgd-inifl = 0.
  bhdgd-lines = sy-linsz.
  bhdgd-uname = sy-uname.
  bhdgd-repid = sy-repid.
  bhdgd-line1 = sy-title.
  bhdgd-line2 = par_line.
  bhdgd-separ = par_lsep.
  bhdgd-domai = 'BUKRS'.

*  IF NOT p_bupla IS INITIAL.           " TP-01   "OP-01
*   Add the value <P_BUPLA> into the second line of the header "TP-01
*   bhdgd-line2 = 'Geschäftsort ist &1'(008).        "TP-01  "OP-01
*   REPLACE '&1' WITH p_bupla INTO bhdgd-line2.      "TP-01  "OP-01
*   CONCATENATE '(' bhdgd-line2 ')'  INTO bhdgd-line2."TP-01 "OP-01
*   CONCATENATE bhdgd-line2 par_line INTO bhdgd-line2 "TP-01  "OP-01
*     SEPARATED BY ' '.                " TP-01
* ENDIF. " not p_bupla is initial     "TP-01  "OP-01

* Mikrofiche-Zeile vorbereiten
  bhdgd-miffl = par_mikf.                                   "429158

  IF par_lis5 = 'X'.
*   Erlaubte Rundungsdifferenzen pro Buchungskreis holen
    REFRESH tab_001r.
    SELECT * FROM t001
      WHERE bukrs IN br_bukrs.
*     Rundungsdifferenzen nur für die Hauswährung merken
      SELECT SINGLE * FROM t001r
        WHERE bukrs = t001-bukrs
          AND waers = t001-waers.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING t001r TO tab_001r.
        APPEND tab_001r.
      ELSE.
        MOVE-CORRESPONDING t001 TO tab_001r.
        tab_001r-reinh = 1.
        APPEND tab_001r.
      ENDIF.
    ENDSELECT.
  ENDIF.

* Tabelle mit Buchungskreisen, aus denen Belege zu 4.0 umgesetzt wurden
  IMPORT ums40 FROM DATABASE rfdt(fu) ID 'UMS40'.


* enqueue status records for electronic tax declaration     "751603
* (entries for table gt_foteclsta have been created         "751603
* at selection screen in form check_euva)                   "751603
  IF par_euva = 'X'.                                        "751603
    CALL FUNCTION 'FOT_ENQUEUE_DECLSTA'                     "751603
      EXPORTING                                             "751603
        it_fotdeclsta = gt_fotdeclsta                       "751603
        id_enqmod     = 'ENQ'.                              "751603
  ENDIF.                                                    "751603


GET bosg.
  " Optimization
  IF xhana EQ 'E'.
    IF alcur EQ 'X'.
      PERFORM read_teurb TABLES br_bukrs.
    ENDIF. "<<<<euro
    PERFORM process_result.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  srf_file
*&---------------------------------------------------------------------*
FORM srf_file USING lt_file TYPE table.
  DATA: lv_doc_id  TYPE srf_document_id VALUE 'BODY',
        lt_message TYPE symsg_tab,
        lv_string  TYPE string,
        ls_file    TYPE  dmee_output_file.

  LOOP AT lt_file INTO ls_file.
    IF  ls_file-x_cr IS NOT INITIAL                   "Check for Carriage Return
    AND ls_file-x_lf IS NOT INITIAL.                  "Check for Line Feed

      IF sy-tabix EQ 1.
        lv_string = ls_file-line(ls_file-length).
      ELSE.
        CONCATENATE lv_string
                    cl_abap_char_utilities=>cr_lf
                    ls_file-line(ls_file-length)
                    INTO lv_string
                    RESPECTING BLANKS.
      ENDIF.
    ELSE.
      CONCATENATE lv_string ls_file-line(ls_file-length) INTO lv_string
      RESPECTING BLANKS.
    ENDIF.
  ENDLOOP.

  IF lo_wrapper IS BOUND.
    TRY.
        CALL METHOD lo_wrapper->store_file_to_srf
          EXPORTING
            iv_file_content = lv_string
            iv_document_id  = lv_doc_id
            iv_status       = 'GEN'.
      CATCH cx_srf_error .
    ENDTRY.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  process_bkpf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM process_bkpf
     CHANGING lv_reject TYPE abap_bool.                     "2103962
  lv_reject = abap_false.                                   "2103962

*  IF xhana <> 'E'.                                         "2103962
*    CHECK:                                                 "2103962
*     sel_mona.                                             "2103962
*  ENDIF.                                                   "2103962
  IF NOT bkpf-monat IN sel_mona.                            "2103962
    lv_reject = abap_true.                                  "2103962
    RETURN.                                                 "2103962
  ENDIF.                                                    "2103962

* Prüfen Umsatzsteuerkreis Zeitabh. durchführen              "N1542782
  IF flg_umkrs = '2'.                                       "N1542782
    CALL FUNCTION 'TAX_UMKRS_DETERMINE'                      "N1542782
      EXPORTING                                              "N1542782
        i_bkpf  = bkpf                                 "N1542782
      IMPORTING                                              "N1542782
        e_umkrs = gd_umkrs.                            "N1542782
*   Weiterverarb. nur, wenn der UMKRS bestimt werden konnte  "N1542782
*   CHECK: gd_umkrs IS NOT INITIAL.               "N1542782 "2103962
*   IF gd_umkrs IS NOT INITIAL.                   "2103962  "2125886
    IF gd_umkrs IS INITIAL.                       "2103962  "2125886
      lv_reject = abap_true.                                "2103962
      RETURN.                                               "2103962
    ENDIF.                                                  "2103962
  ENDIF.                                                    "N1542782
*
  REFRESH:
    tab_diff,
    tab_ep.
  CLEAR:
    ep,
    tab_diff,
    tab_ep,
    g_linewise,                                             "1584037
    hlp_umskz,
    hlp_zuonr,                                              "938627
    hlp_gl_account.
  CLEAR gd_flg_auth_gsber.                                  "2715311
  IF NOT par_bodo IS INITIAL.          "Bolle Doganle
    flg_bd_only_gl = 'X'.
    REFRESH tab_bd_gl_accounts.
    CLEAR hlp_bodo_accnt.                                   "1014836
  ENDIF.
  IF par_xsht EQ 'X'.                                       "2290231
    REFRESH gt_bseg_doc.                                    "2290231
  ENDIF.                                                    "2290231
  CLEAR gs_any_bseg.                                        "1120571
  REFRESH gt_ese_bset.                                      "859167
  REFRESH gt_wia_adrnr.                                     "1686870
  REFRESH gt_discounts.                                     "1868787
  CLEAR: gd_hwbas,                                          "1868787
         gd_lwbas.                                          "1868787

  PERFORM read_t001 USING bkpf-bukrs.

  PERFORM time_restriction_check CHANGING lv_reject.
  IF lv_reject = abap_true.
    RETURN.
  ENDIF.

*  IF par_bsud = 'X'.                                       "2061805
**   Bukrs, Belegnummer und Geschäftsjahr für BSET-Update   "2061805
**     mit den aus TAB_EP gelöschten Zeilen merken          "2061805
*    CLEAR tab_bset_key.                                    "2061805
*    MOVE-CORRESPONDING bkpf TO tab_bset_key.               "2061805
*  ENDIF.                                                   "2061805

* Erlaubte Rundungsdifferenz für Buchungskreis bzgl. Hauswährung
  IF par_lis5 = 'X'.
    READ TABLE tab_001r WITH KEY bukrs = bkpf-bukrs
                                 waers = tab_001-waers.     "1104702
    IF sy-subrc <> 0.                                       "1104702
      SELECT SINGLE * FROM t001r                            "1104702
             WHERE bukrs = bkpf-bukrs                       "1104702
               AND waers = tab_001-waers.                   "1104702
      IF sy-subrc = 0.                                      "1104702
        MOVE-CORRESPONDING t001r TO tab_001r.               "1104702
        APPEND tab_001r.                                    "1104702
      ELSE.                                                 "1104702
        MOVE-CORRESPONDING tab_001 TO tab_001r.             "1104702
        tab_001r-reinh = 1.                                 "1104702
        APPEND tab_001r.                                    "1104702
      ENDIF.                                                "1104702
    ENDIF.                                                  "1104702

*   Erlaubte Rundungsdifferenz  bzgl. Belegwaehrung         "1104702
    IF bkpf-waers <> tab_001-waers.                         "1104702
      READ TABLE tab_001r INTO gs_t001r_fc                  "1104702
           WITH KEY bukrs = bkpf-bukrs                      "1104702
                    waers = bkpf-waers.                     "1104702
      IF sy-subrc <> 0.                                     "1104702
        SELECT SINGLE * FROM t001r INTO gs_t001r_fc         "1104702
               WHERE bukrs = bkpf-bukrs                     "1104702
                 AND waers = bkpf-waers.                    "1104702
        IF sy-subrc = 0.                                    "1104702
          APPEND gs_t001r_fc TO tab_001r.                   "1104702
        ELSE.                                               "1104702
          gs_t001r_fc-bukrs = bkpf-bukrs.                   "1104702
          gs_t001r_fc-waers = bkpf-waers.                   "1104702
          gs_t001r_fc-reinh = 1.                            "1104702
          APPEND gs_t001r_fc TO tab_001r.                   "1104702
        ENDIF.                                              "1104702
      ENDIF.                                                "1104702
    ENDIF.                                                  "1104702

  ENDIF.
ENDFORM.                    "process_bkpf

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

*----------------------------------------------------------------------*
* Belegkopf                                                            *
*----------------------------------------------------------------------*
GET bkpf.
  DATA lv_reject TYPE abap_bool.                            "2103962

  PERFORM process_bkpf
          CHANGING lv_reject.                               "2103962
  IF lv_reject = abap_true.                                 "2103962
    REJECT.                                                 "2103962
  ENDIF.                                                    "2103962


*&---------------------------------------------------------------------*
*&      Form  process_bseg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM process_bseg.
* Flag Negativbuchung setzen                    "OP-07
*  ep-negp = bseg-xnegp.                "OP-07            "2290231
  IF par_xsht EQ 'X'.                                       "2290231
    MOVE-CORRESPONDING bseg TO gs_bseg_doc.                 "2290231
    APPEND gs_bseg_doc TO gt_bseg_doc.                      "2290231
  ENDIF.                                                    "2290231

* Steuerkontrolle: Zulässige Rundungsdifferenz ermitteln
  IF par_lis5 EQ 'X'.                  "Steuerkontrolle
*   Merken der zulässigen Rundungsdifferenz pro Steuerkz. im Beleg,
*     abhängig von der Anzahl der Beleg- und Steuerzeilen mit diesem Kz
*   Kontokorrentzeilen und durch Steuerbeträge erzeugte automatische
*     Zeilen werden nicht berücksichtigt
    IF bseg-koart <> 'D' AND bseg-koart <> 'K'
      AND ( bseg-mwart = space OR bseg-xauto = space )
      OR ( bseg-umsks = 'A' AND bseg-mwskz <> space ).      "1134305
      tab_diff-flg_fc = space.                              "1104702
      tab_diff-tax_country = bseg-tax_country.
      tab_diff-mwskz = bseg-mwskz.
      tab_diff-txdat_from = bseg-txdat_from.
      tab_diff-rndbl = tab_001r-reinh.
      tab_diff-rndst = 0.
      COLLECT tab_diff.
      IF bkpf-waers <> tab_001-waers.                       "1104702
        tab_diff-flg_fc = 'X'.                              "1104702
        tab_diff-rndbl = gs_t001r_fc-reinh.                 "1104702
        COLLECT tab_diff.                                   "1104702
      ENDIF.                                                "1104702
    ENDIF.
  ENDIF.

* Authority check for gsber is done here, so that content   "2715311
* will not be picked from this item if no authorization.    "2715311
* The respective warning will be created only if the        "2715311
* document has selected BSET entries.                       "2715311
  IF NOT bseg-gsber IN gr_auth_gsber.                       "2715311
    gd_flg_auth_gsber = 'X'.                                "2715311
    RETURN.                                                 "2715311
  ENDIF.                                                    "2715311

* Read tax-relevant Account with KOART <> K, D, S
  IF ( 'KDS' NA bseg-koart ) AND ( NOT bseg-txgrp IS INITIAL ).
    IF hlp_gl_account IS INITIAL.
      hlp_gl_account = bseg-hkont.
    ENDIF.
  ENDIF.

* Account number of the first G/L-Account of each tax code  "992241
  IF ( bseg-koart CA 'SAM' )                                "992241
     AND ( NOT bseg-mwskz IS INITIAL )                      "992241
     AND ( bseg-mwart IS INITIAL ).                         "992241
    READ TABLE it_glaccount INTO is_glaccount WITH KEY      "992241
                          tax_country = bseg-tax_country
                          mwskz = bseg-mwskz                "992241
                          txdat_from = bseg-txdat_from
                          koart = bseg-koart.               "992241
    IF sy-subrc NE space.                                   "992241
      is_glaccount-hkont = bseg-hkont.                      "992241
      is_glaccount-tax_country = bseg-tax_country.
      is_glaccount-mwskz = bseg-mwskz.                      "992241
      is_glaccount-txdat_from = bseg-txdat_from.
      is_glaccount-koart = bseg-koart.                      "992241
      APPEND is_glaccount TO it_glaccount.                  "992241
    ENDIF.                                                  "992241
  ENDIF.

* Read tax-relevant G/L-Accounts
*  IF ( ep-zuonr IS INITIAL ) AND ( bseg-koart = 'S' )
*                              AND ( ( ( NOT bseg-mwskz IS INITIAL ) AND
*                              ( bseg-mwart IS INITIAL ) ) OR
*                              ( NOT bseg-txgrp IS INITIAL ) )."435455
*
**   Allocation number of one G/L-Account
*    IF ( ep-zuonr IS INITIAL ).
*      ep-zuonr = bseg-zuonr.
*    ENDIF.

* get discount amounts per tax code                         "1868787
  IF NOT so_diac[] IS INITIAL                               "1868787
     AND NOT bseg-mwskz IS INITIAL.                         "1868787
    IF bseg-koart CA 'SAM'                                  "1868787
       AND bseg-hkont IN so_diac.                           "1868787
      gs_discounts-tax_country = bseg-tax_country.
      gs_discounts-mwskz = bseg-mwskz.                      "1868787
      gs_discounts-txdat_from = bseg-txdat_from.
      gs_discounts-ktosl = space.                           "1868787
      IF bseg-shkzg = 'S'.                                  "1868787
        gs_discounts-dmbtr = bseg-dmbtr.                    "1868787
        gs_discounts-wrbtr = bseg-wrbtr.                    "1868787
      ELSE.                                                 "1868787
        gs_discounts-dmbtr = - bseg-dmbtr.                  "1868787
        gs_discounts-wrbtr = - bseg-wrbtr.                  "1868787
      ENDIF.                                                "1868787
      COLLECT gs_discounts INTO gt_discounts.               "1868787
    ENDIF.                                                  "1868787
  ENDIF.                                                    "1868787

* get zuonr from tax postings as fallback value                 "938627
  IF NOT bseg-mwart IS INITIAL.                             "938627
    IF hlp_zuonr IS INITIAL                                 "938627
       AND NOT bseg-zuonr IS INITIAL.                       "938627
      hlp_zuonr = bseg-zuonr.                               "938627
    ENDIF.                                                  "938627
  ENDIF.                                                    "938627

  IF ( bseg-koart = 'S' ) AND ( NOT bseg-mwskz IS INITIAL )
                          AND ( bseg-mwart IS INITIAL ).    "545812

*   EU-Ident number from first G/L-Account                      "736203
*   An EU-Ident number in the first personal account will       "736203
*   override this.                                              "736203
    IF ( ep-stceg IS INITIAL ) AND ( NOT bseg-stceg IS INITIAL ). "736203
      ep-stceg = bseg-stceg.                                "640269
    ENDIF.                                                  "736203

*   Allocation number of one G/L-Account
    IF ( ep-zuonr IS INITIAL ) AND ( bseg-koart = 'S' )
                              AND ( ( ( NOT bseg-mwskz IS INITIAL ) AND
                                ( bseg-mwart IS INITIAL ) ) OR
                                ( NOT bseg-txgrp IS INITIAL ) ). "545812
      ep-zuonr = bseg-zuonr.
    ENDIF.


*   Account number of the first G/L-Account
*   Account number of the first G/L-Account of each tax code
*    READ TABLE it_glaccount INTO is_glaccount WITH KEY     "992241
*                          mwskz = bseg-mwskz.              "992241
*
*    IF sy-subrc NE space.                                  "992241
*      is_glaccount-hkont = bseg-hkont.                     "992241
*      is_glaccount-mwskz = bseg-mwskz.                     "992241
*      APPEND is_glaccount TO it_glaccount.                 "992241
*    ENDIF.                                                 "992241

    IF ( ep-hkont IS INITIAL ).
      ep-hkont = bseg-hkont.
      IF NOT g_read_bseg IS INITIAL.
        PERFORM append_bseg.
      ENDIF.
    ENDIF.
*   Bolle Doganali: Save all tax-relevant G/L-Accounts
    IF ( NOT par_bodo IS INITIAL ).
      APPEND bseg-hkont TO tab_bd_gl_accounts.
    ENDIF.
  ENDIF.

* Bolle Doganali: Save the first non-tax-relevant G/L-account
  IF ( NOT par_bodo IS INITIAL ).                           "1014836
    IF bseg-koart = 'S' AND bseg-mwskz IS INITIAL.          "1014836
      IF hlp_bodo_accnt IS INITIAL.                         "1014836
        hlp_bodo_accnt = bseg-hkont.                        "1014836
      ENDIF.                                                "1014836
    ENDIF.                                                  "1014836
  ENDIF.                                                    "1014836

* G/L-item for BADI_011 in case no bette item is available. "1120571
  IF NOT g_read_bseg IS INITIAL.                            "1120571
    IF bseg-koart CA 'SAM'.                                 "1120571
      IF bseg-mwskz IS INITIAL                              "1120571
         OR NOT bseg-mwart IS INITIAL.                      "1120571
        MOVE bseg TO gs_any_bseg.                           "1120571
      ENDIF.                                                "1120571
    ENDIF.                                                  "1120571
  ENDIF.                                                    "1120571

***********************************************************************
* Special treatment for personal accounts                             *
***********************************************************************
  CHECK bseg-koart EQ 'D' OR bseg-koart EQ 'K'
   OR ( bseg-koart EQ 'S' AND NOT bseg-lifnr EQ space ).      "Impact on
  "Aquisition Accrual Tax
  "Note 831532

* First special G/L indicator
  IF NOT bseg-umskz IS INITIAL.
    IF hlp_umskz IS INITIAL.
      hlp_umskz = bseg-umskz.
    ENDIF.
  ENDIF.

* Bolle Doganali
  IF NOT par_bodo IS INITIAL.          "Bolle Doganali
    CLEAR flg_bd_only_gl.              "There are not only G/L-Accounts
  ENDIF.

* Account number of the first personal account
  IF ep-ktnra EQ space
     OR ( ep-koart EQ 'S' AND bseg-koart CA 'DK' ).         "2248927
    ep-koart = bseg-koart.
*   EU-Ident number from first personal account                 "736203
    IF ( NOT bseg-stceg IS INITIAL ).                       "736203
      ep-stceg = bseg-stceg.
    ENDIF.                                                  "736203
    IF bseg-koart EQ 'D'.
      ep-ktnra = bseg-kunnr.
    ELSE.                              "bseg-koart = 'K' or 'S'
      ep-ktnra = bseg-lifnr.
    ENDIF.
    ep-bcode = bseg-j_1tpbupl.         "BP Branch Code TH   "2097858
    IF NOT g_read_bseg IS INITIAL.
      PERFORM append_bseg.
    ENDIF.
  ENDIF.

* check again for 'D' or 'K' because there are              "1299120
* G/L items with LIFNR filled ( MM and note 831532).        "1299120
  IF bseg-koart CA 'DK'.                                    "1299120
    ep-augdt = bseg-augdt.
    IF bseg-augdt EQ space.
      CLEAR ep-augdt.
    ENDIF.
  ENDIF.                                                    "1299120
ENDFORM.                    "process_bseg


*----------------------------------------------------------------------*
* Belegposition (Adressdaten, Skonto, Fortschreiben Anzahl der         *
*   Sachkontenzeilen pro Steuerkennzeichen)                            *
*----------------------------------------------------------------------*
GET bseg.
  PERFORM process_bseg.

*&---------------------------------------------------------------------*
*&      Form  PROCESS_BSET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM process_bset CHANGING lv_reject TYPE abap_bool.

* save some bset data for 100%-ESE correction               "859167
  PERFORM append_ese_bset.                                  "859167

  IF NOT sel_ktos IS INITIAL.                               "400505
    CHECK bset-ktosl IN sel_ktos.                           "400505
  ENDIF.                                                    "400505

  IF NOT skonto IS INITIAL.                                 "OP-09
    CHECK bset-hkont IN skonto.                             "OP-09
  ENDIF.                                                    "OP-09

  IF NOT sel_bupl IS INITIAL.                               "OP-01
    CHECK bset-bupla IN sel_bupl.                           "OP-01
  ENDIF.                                                    "OP-01
*  IF bset-bupla <> p_bupla AND NOT p_bupla IS INITIAL."OP-01
*   There may be at most one business place in each document."OP-01
*   The business place of the current document does not match"OP-01
*   the input <p_bupla> ==> Go to the next document          "OP-01
*    REJECT 'BKPF'.                     "OP-01
*  ENDIF.                               "OP-01
  lv_reject = abap_false.
  IF NOT hlp_umskz IN sel_umsk.
*   There may be at most one special G/L indicator in each document.
*   The special G/L indicator of the current document does not match
*   the input <sel_umsk> ==> Go to the next document
    "for external optimization, simulating logic is introduced for the REJECT statement related to the LDB in the original report
*    IF xhana = 'E'.                                        "2103962
    lv_reject = abap_true.
    EXIT.
*    ELSE.                                                  "2103962
*      REJECT 'BKPF'.                                       "2103962
*    ENDIF.                                                 "2103962
  ENDIF.

  CHECK:
    sel_mwkz, sel_lstm, sel_taxc,
    bset-hwbas NE 0 OR                                      "1632983
    bset-fwbas NE 0 OR                                      "3237677
    ( par_xstw = 'X' AND bset-lwbas NE 0 ).                 "1632983

  DATA(lv_kalsm) = COND #( WHEN flg_txa_active = abap_true
                             THEN cl_fot_common_dao=>agent->get_country_data(
                                         bset-tax_country )-kalsm
                           ELSE tab_001-kalsm ).

*  Begin of Note 1359126
*  When the tax code is relevant for refund of VAT then it shall
*  not be processed here
  DATA:
    ls_tax_rfd_codes TYPE tax_rfd_codes.
  CLEAR ls_tax_rfd_codes.
  CALL FUNCTION 'GET_TAX_RFD_CODE'
    EXPORTING
      iv_kalsm         = lv_kalsm
      iv_mwskz         = bset-mwskz
    IMPORTING
      es_tax_rfd_codes = ls_tax_rfd_codes
    EXCEPTIONS
      not_found        = 1
      OTHERS           = 2.
  CHECK ls_tax_rfd_codes IS INITIAL.
*  End of Note 1359126

* Überprüfen, ob Steuerzeile für aktuellen Lauf relevant ist
  IF ( NOT sel_tmdt IS INITIAL ) AND ( sel_tmti IS INITIAL ).
    CHECK sel_tmdt.
  ELSEIF ( NOT sel_tmti IS INITIAL ).
    CHECK sel_tmdt.
    CHECK bset-stmti IN ran_tmti.
  ELSEIF par_bsud = 'X' OR par_bupl = 'X'.
    CHECK:
      bset-stmdt IS INITIAL,
      bset-stmti IS INITIAL.
  ENDIF.

  PERFORM:
    read_t007a USING lv_kalsm bset-mwskz,
    read_t007b USING bset-ktosl.

* Exclude MOSS tax codes unless explicitly selected.        "2101269
  IF ( par_moss IS INITIAL ).                               "2101269
    CHECK tab_007a-mossc IS INITIAL.                        "2101269
  ENDIF.                                                    "2101269

  PERFORM check_read_konp?.                                 "447075
  IF read_konp? = 'y'.                                      "447075
    READ TABLE it_coco_calcproc WITH KEY bukrs = bset-bukrs. "481176
    DATA(lv_tax_country) = COND #( WHEN flg_txa_active = abap_true
                                     THEN bset-tax_country
                                   ELSE it_coco_calcproc-land1 ).
    PERFORM                                                 "447075
     read_konp
     USING bset-mwskz bset-txdat_from bset-kschl
           bset-ktosl lv_tax_country lv_kalsm.
    "481176 "OP-20
  ENDIF.                                                    "447075

  CHECK tab_007b-stgrp NE 4.

** if it is a Russian company code, tax line items with deferred taxes
** will be handled different                       "566949  "1948319
*  READ TABLE gt_isocodes INTO s_isocodes          "566949  "1948319
*       WITH KEY bukrs = bset-bukrs.               "566949  "1948319
*                                                  "566949  "1948319
*  IF sy-subrc = 0.                                "566949  "1948319
*    IF s_isocodes-intca = 'RU' OR                          "1948319
*       s_isocodes-intca = 'UA'.           "566949 "595718  "1948319
*      IF NOT par_binp = space.                    "566949  "1948319
** No deferred tax with tax amount <> 0                     "1948319
*        IF ( NOT tab_007a-zmwsk IS INITIAL ).     "566949  "1948319
*          CHECK ( bset-kbetr IS INITIAL ).        "566949  "1948319
*        ENDIF.                                    "566949  "1948319
*      ENDIF.                                      "566949  "1948319
*    ELSE.                                         "566949  "1948319
** No deferred tax with tax amount <> 0                     "1948319
*      IF ( NOT tab_007a-zmwsk IS INITIAL ).       "566949  "1948319
*        CHECK ( bset-kbetr IS INITIAL ).          "566949  "1948319
*      ENDIF.                                      "566949  "1948319
*    ENDIF.                                        "566949  "1948319
*  ENDIF.                                          "566949  "1948319
* -----Begin insert Note 1948319 -----                      "1948319
*  check if deferred tax code is to be processed            "1948319
  IF NOT tab_007a-zmwsk IS INITIAL.                         "1948319
    DATA: ld_def_type   TYPE c,
          ld_def_show   TYPE xfeld,
          ld_def_show_0 TYPE xfeld.
    PERFORM check_def_ctry_option
            USING      bset-bukrs
                       space
            CHANGING   ld_def_type
                       ld_def_show
                       ld_def_show_0.
    IF ld_def_show_0 = 'X' AND
       bset-kbetr IS INITIAL.
      ld_def_show = 'X'.     "show 0% deferred tax codes
    ENDIF.
    CHECK ld_def_show = 'X'.
  ENDIF.                                                    "1948319
* -----End insert Note 1948319 -----                        "1948319

* Check if linewise tax calculation has been activated.     "1584037
* for this document. A filled taxps is a safe indicator.    "1584037
* This information is used when merging non-deductible tax. "1584037
  IF NOT bset-taxps IS INITIAL.                             "1584037
    g_linewise = 'X'.                                       "1584037
  ENDIF.                                                    "1584037

  IF par_lis5 EQ 'X'.                  "Steuerkontrolle
*   Merken der zulässigen Rundungsdifferenz pro Steuerkz. im Beleg,
*     abhängig von der Anzahl der Beleg- und Steuerzeilen mit diesem Kz
    tab_diff-flg_fc = space.                                "1104702
    tab_diff-tax_country = bset-tax_country.
    tab_diff-mwskz = bset-mwskz.
    tab_diff-txdat_from = bset-txdat_from.
    tab_diff-rndbl = 0.
    tab_diff-rndst = tab_001r-reinh.
    COLLECT tab_diff.
    IF bkpf-waers <> tab_001-waers.                         "1104702
      tab_diff-flg_fc = 'X'.                                "1104702
      tab_diff-rndst = gs_t001r_fc-reinh.                   "1104702
      COLLECT tab_diff.                                     "1104702
    ENDIF.                                                  "1104702
  ENDIF.

* Einzelpostentabelle füllen -------------------------------------------
  MOVE-CORRESPONDING bset TO tab_ep.
  tab_ep-mwskz_and_txdat_from = |{ tab_ep-mwskz }{ tab_ep-txdat_from }|.
  tab_ep-tkont = bset-hkont.
*  IF par_xstw = 'X' AND alcur NE 'X'.                       "OP-25
  IF par_xstw = 'X' AND ( alcur NE 'X' OR par_xalw = 'X' ). "3296651
    tab_ep-hwbas = bset-lwbas.
    tab_ep-hwste = bset-lwste.
  ENDIF.
  IF bset-shkzg EQ 'H'.
    tab_ep-hwbas = tab_ep-hwbas * -1.
    tab_ep-fwbas = tab_ep-fwbas * -1.
    tab_ep-hwste = tab_ep-hwste * -1.
    tab_ep-fwste = tab_ep-fwste * -1.
  ENDIF.
  tab_ep-mwart = tab_007a-mwart.
  tab_ep-text1 = tab_007a-text1.                            "OP-08
  tab_ep-stgrp = tab_007b-stgrp.
  tab_ep-stazf = tab_007b-stazf.
  IF read_konp? = 'y'.                                      "447075
    tab_ep-kbetr = tab_konp-kbetr.                          "OP-26
  ENDIF.                                                    "447075
*                                                           "720567
* Bei ESA/ESA wenn ESA negativ und nur Basisbetrag ausgewiesen wird,
* dann muss beim Basisbetrag noch mal mit -1 multipliziert werden
* da beim Buchen der Betrag nicht negativ wird
  IF tab_ep-hwste = 0   AND                                 "720567
     tab_ep-kbetr < 0.                                      "720567
    tab_ep-hwbas = - tab_ep-hwbas.                          "720567
    tab_ep-fwbas = - tab_ep-fwbas.                          "720567
  ENDIF.                                                    "720567
  APPEND tab_ep.

  gd_hwbas = gd_hwbas + abs( bset-hwbas ).                  "1868787
  gd_lwbas = gd_lwbas + abs( bset-lwbas ).                  "1868787
  i_lwbas = bset-lwbas.                                     "455681
  i_fwbas = bset-fwbas.                                     "455681
ENDFORM.                    " GET_BSET


*----------------------------------------------------------------------*
* Umsatzsteuerposition                                                 *
*----------------------------------------------------------------------*
GET bset.
  " create a local data object to reuse the subroutine process_bset for syntax check, no other meaning here.
  DATA lv_reject TYPE abap_bool.
  PERFORM process_bset CHANGING lv_reject.
  IF lv_reject = abap_true.                                 "2103962
    REJECT 'BKPF'.                                          "2103962
  ENDIF.                                                    "2103962


*&---------------------------------------------------------------------*
*&      Form  PROCESS_BKPF_LATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM process_bkpf_late .
  DATA lv_jva_active TYPE abap_bool.
* Belegkopf-Felder zum Extrahieren füllen ------------------------------
  ep-bukrs    = bkpf-bukrs.
  ep-buper(4) = bkpf-gjahr.
  ep-buper+4  = bkpf-monat.
  ep-bktxt    = bkpf-bktxt.
  ep-blart    = bkpf-blart.
  ep-bldat    = bkpf-bldat.
  ep-xmwst    = bkpf-xmwst.
  ep-waers    = bkpf-waers.
  ep-budat    = bkpf-budat.
  ep-belnr    = bkpf-belnr.
  ep-xblnr    = bkpf-xblnr.
  ep-xblnr_alt = bkpf-xblnr_alt.                            "792331
  ep-vatdate  = bkpf-vatdate.                               "1023317
  ep-fulfilldate = bkpf-fulfilldate.
  ep-awtyp    = bkpf-awtyp.                                 "2277019
  ep-awkey    = bkpf-awkey.                                 "2277019
  ep-reindat  = bkpf-reindat.                               "2438600

  IF par_xstw NE space.                                     "455681
    DATA   floatvalue TYPE f.                               "665165
    CLEAR  floatvalue.
    DATA(lv_tax_country) = COND #( WHEN flg_txa_active = abap_true
                                     THEN sel_taxc-low
                                   ELSE sel_lstm-low ).
    SELECT SINGLE * FROM t005
                      WHERE land1 = lv_tax_country.         "455681

    IF bkpf-waers EQ t005-waers                             "1747902
       OR i_fwbas = 0.                                      "1747902
      CLEAR ep-ex_rate.                                     "1747902
    ELSE.                                                   "1747902

      LOOP AT it_tcurf INTO is_tcurf WHERE
                         kurst = t005-kurst AND
                         fcurr = bkpf-waers AND
                         tcurr = t005-waers.                "455681
      ENDLOOP.                                              "455681
      IF sy-subrc NE 0.                                     "455681
        SELECT SINGLE * FROM tcurf
                            WHERE kurst = t005-kurst AND
                                  fcurr = bkpf-waers AND
                                tcurr = t005-waers.         "455681
        IF sy-subrc = 0.
          is_tcurf = tcurf.                                 "455681
          PERFORM adapt_tcurf_decimals                      "1963595
                  CHANGING is_tcurf.                        "1963595
          APPEND is_tcurf TO it_tcurf.                      "455681
* ----- Begin Delete 1747902 -----                          "1747902
*        i_helpamount = ( i_lwbas * tcurf-ffact ) * 100000. "455681
*        floatvalue = i_helpamount / ( i_fwbas * tcurf-tfact ).
**       if floatvalue < 10000.                             "1015278
*        if floatvalue < 1000000000                         "1015278
*           and floatvalue > 0.                             "1617293
*          move floatvalue to ep-ex_rate.
*        else.
*          clear ep-ex_rate.
*        endif.
* ----- End Delete 1747902 -----                            "1747902
        ELSE.                                               "455681
          is_tcurf-kurst = t005-kurst.                      "1747902
          is_tcurf-fcurr = bkpf-waers.                      "1747902
          is_tcurf-tcurr = t005-waers.                      "1747902
          is_tcurf-ffact = 1.                               "1747902
          is_tcurf-tfact = 1.                               "1747902
*      also put not-found entry to buffer                   "1747902
          PERFORM adapt_tcurf_decimals                      "1963595
                  CHANGING is_tcurf.                        "1963595
          APPEND is_tcurf TO it_tcurf.                      "1747902
* ----- Begin Delete 1747902 -----                          "1747902
*        i_helpamount = i_lwbas * 100000.                   "455681
*        floatvalue = i_helpamount / i_fwbas.               "455681
**       if floatvalue < 10000.                             "1015278
*        if floatvalue < 1000000000                         "1015278
*           and floatvalue > 0.                             "1617293
*          move floatvalue to ep-ex_rate.
*        else.
*          clear ep-ex_rate.
*        endif.
* ----- End Delete 1747902 -----                            "1747902
        ENDIF.
*   ELSE.                                                   "1747902
      ENDIF.                                                "1747902
      i_helpamount = ( i_lwbas * is_tcurf-ffact ) * 100000. "455681
      floatvalue = i_helpamount / ( i_fwbas * is_tcurf-tfact ).
*     if floatvalue < 10000.                                "1015278
      IF floatvalue < 1000000000                            "1015278
         AND floatvalue > 0.                                "1617293
        MOVE floatvalue TO ep-ex_rate.
      ELSE.
        CLEAR ep-ex_rate.
      ENDIF.
*   ENDIF.                                        "455681   "1747902
    ENDIF.                                                  "1747902

  ELSE.                                                     "455681
    ep-ex_rate = bkpf-kursf.                                "OP-19
  ENDIF.                                                    "455681

  FIELD-SYMBOLS <ctxkrs> TYPE txkrs_bkpf.                   "2586837
  IF par_xstw NE space.                                     "2586837
    ASSIGN COMPONENT 'CTXKRS' OF STRUCTURE bkpf TO <ctxkrs>. "2586837
    IF sy-subrc = 0.                                        "2586837
      ep-tx_rate = <ctxkrs>.                                "2586837
    ENDIF.                                                  "2586837
  ELSE.                                                     "2586837
    ep-tx_rate = bkpf-txkrs.                                "2586837
  ENDIF.

  CLEAR i_lwbas.                                            "561608
  CLEAR i_fwbas.                                            "561608

  IF par_xcas = 'X'.                   "Quittungsdaten lesen
    CONDENSE bkpf-bktxt.
    SPLIT bkpf-bktxt AT space INTO ep-qunum ep-qutyp ep-qudat.
    CHECK ep-qunum NE space.
    IF ep-qudat IS INITIAL.
      WRITE bkpf-bldat TO ep-qudat DD/MM/YYYY.
    ENDIF.
    hlp_sort = ep-qunum.
  ENDIF.

* Steuerkontrolle ------------------------------------------------------
  IF par_lis5 EQ 'X'.                  "Steuerkontrolle
    LOOP AT tab_ep.
*      PERFORM read_tax_amount          "Steuerbetrag berechnen "825186
*        USING tab_ep-mwskz tab_ep-kschl tab_ep-hwbas           "825186
*        CHANGING hlp_hwste2.                                   "825186
      PERFORM calculate_tax_amount     "Steuerbetrag berechnen  "825186
        USING tab_ep-mwskz tab_ep-tax_country tab_ep-txdat_from tab_ep-kschl
              tab_ep-ktosl tab_ep-hwbas                     "825186
        CHANGING hlp_hwste2.                                "825186
      tab_ep-sdiff = hlp_hwste2 - tab_ep-hwste.
      IF bkpf-waers <> tab_001-waers.                       "1104702
        PERFORM calculate_tax_amount                        "1104702
        USING tab_ep-mwskz tab_ep-tax_country tab_ep-txdat_from tab_ep-kschl
              tab_ep-ktosl tab_ep-fwbas                     "1104702
        CHANGING hlp_hwste2.                                "1104702
        tab_ep-sdiff_fc = hlp_hwste2 - tab_ep-fwste.        "1104702
      ENDIF.                                                "1104702
      MODIFY tab_ep.                   "Differenz merken
    ENDLOOP.
  ENDIF.

* Get Address data for stock transfer documents from SD     "1035054
* (creates internal table gt_wia_adrnr)                     "1686870
  IF NOT flg_xwia IS INITIAL.                               "1035054
    IF ep-koart IS INITIAL                                  "1035054
       AND ( bkpf-awtyp = 'VBRK '                           "1035054
       OR bkpf-awtyp = 'TXGM ' ).
*      PERFORM stock_transfer_address              "1035054 "1686870
*              CHANGING ep-wia_adrnr               "1035054 "1686870
*                       ep-stceg.                  "1035054 "1686870
      PERFORM stock_transfer_address.                       "1686870
    ENDIF.                                                  "1035054
  ENDIF.                                                    "1035054

* Get customer account for gift invoices                    "1233225
* (SD-dicument with output tax but no customer item)        "1233225
  IF ep-koart IS INITIAL                                    "1233225
     AND bkpf-awtyp = 'VBRK '                               "1233225
*     AND ep-wia_adrnr IS initial.              "1233225    "1686870
     AND gt_wia_adrnr[] IS INITIAL.                         "1686870
    PERFORM gift_invoice_customer                           "1233225
            CHANGING ep-koart                               "1233225
                     ep-ktnra                               "1233225
                     ep-foc_invoice.                        "2277019
  ENDIF.                                                    "1233225


* Change table TAB_EP with BADI 'fi_tax_badi_012'
  IF NOT g_use_badi_12 IS INITIAL.
    PERFORM badi_get_bkpf_late.
  ENDIF.

* Nicht abzugsfähige Steuer auf zugehörige Zeilen verteilen ------------
  IF  par_caos IS INITIAL.                                  "OT-07
    CLEAR g_use_txgrp.                                      "1125117
    READ TABLE gt_isocodes INTO s_isocodes                  "1125117
               WITH KEY bukrs = bkpf-bukrs.                 "1125117
    IF s_isocodes-intca EQ 'IN'.                            "1125117
* In India tax calculation is line-wise. Only the logic     "1125117
* using txgrp can work correctly.                           "1125117
      g_use_txgrp = 'X'.                                    "1125117
    ENDIF.                                                  "1125117
    IF g_linewise EQ 'X'.                                   "1584037
* g_linewise means that bset-taxps is filled. We can safely "1584037
* rely on correct txgrp in this case.                       "1584037
      g_use_txgrp = 'X'.                                    "1584037
    ENDIF.                                                  "1584037
    CLEAR g_use_txdat.                                      "3127428
    PERFORM check_plausi_txgrp_txdat   "reads tab_ep bkpf   "3127428
            CHANGING g_use_txgrp                            "3127428
                     g_use_txdat.                           "3127428
    IF bkpf-awtyp EQ 'FKKSU'.                               "1584037
* TXGRP is guaranteed to be useless in documents from FI-CA."1584037
      CLEAR g_use_txgrp.                                    "1584037
    ENDIF.                                                  "1584037

    LOOP AT tab_ep.
      tab_ep-hwnaf  = 0.
      tab_ep-fwnaf  = 0.
      IF tab_ep-stazf EQ 'X'.
*       hlp_txgrp   = tab_ep-txgrp.                         "994295
        hlp_txgrp   = tab_ep-txgrp.                         "1125117
        gv_tax_country = tab_ep-tax_country.
        hlp_mwskz   = tab_ep-mwskz.                         "994295
        gv_txdat_from = tab_ep-txdat_from.
        hlp_txdat   = tab_ep-txdat.                         "3127428
        hlp_hwbas   = tab_ep-hwbas.                         "994295
        hlp_kschl   = tab_ep-kschl.                         "1584037
        hlp_shkzg   = tab_ep-shkzg.
        hlp_hwnaf   = tab_ep-hwste.
        hlp_fwnaf   = tab_ep-fwste.
        hlp_kbetr   = tab_ep-kbetr.
        hlp_sdiff   = tab_ep-sdiff.
        hlp_sdiff_fc = tab_ep-sdiff_fc.                     "1104702
        hlp_tabix   = sy-tabix.                             "2494287
        IF tab_ep-stgrp CA '12'.                            "2550999
          hlp_stgrp = tab_ep-stgrp.     "comes from T007B   "2550999
        ELSE.                                               "2550999
          hlp_stgrp = tab_ep-mwart.     "comes from T007A   "2550999
          TRANSLATE hlp_stgrp USING 'A1V2'.                 "2550999
        ENDIF.                                              "2550999
        flg_modify  = 0.
        DATA(lv_kalsm) = COND #( WHEN flg_txa_active = abap_true
                                   THEN cl_fot_common_dao=>agent->get_country_data( tab_ep-tax_country )-kalsm
                                 ELSE tab_001-kalsm ).
        PERFORM read_t007a USING lv_kalsm tab_ep-mwskz.     "2430624
        LOOP AT tab_ep.                "Zugehörige Zeile suchen
*         IF tab_ep-txgrp EQ hlp_txgrp                      "994295
          IF tab_ep-tax_country EQ gv_tax_country
            AND tab_ep-mwskz EQ hlp_mwskz                   "994295
            AND tab_ep-txdat_from EQ gv_txdat_from
*           AND tab_ep-hwbas EQ hlp_hwbas          "994295  "1125117
            AND (                                           "1125117
                  ( g_use_txgrp = space AND                 "1125117
                    g_use_txdat = space                     "3127428
                    AND ( tab_ep-hwbas EQ hlp_hwbas OR      "1125117
                    ( tab_007a-egrkz CA '56789A' "reverse charge    "2430624
                    AND abs( tab_ep-hwbas ) = abs( hlp_hwbas ) ) ) ) "2430624
               OR ( g_use_txgrp = 'X'                       "1125117
                    AND tab_ep-txgrp EQ hlp_txgrp )         "1125117
               OR ( g_use_txdat = 'X'                       "3127428
                    AND tab_ep-txdat EQ hlp_txdat )         "3127428
                )                                           "1125117
            AND tab_ep-kschl NE hlp_kschl                   "1584037
            AND tab_ep-shkzg EQ hlp_shkzg
            AND tab_ep-stgrp NE 3
            AND tab_ep-stgrp EQ hlp_stgrp                   "2550999
            AND tab_ep-stazf EQ space.
            tab_ep-hwste = tab_ep-hwste + hlp_hwnaf.
            tab_ep-fwste = tab_ep-fwste + hlp_fwnaf.
            tab_ep-hwnaf = tab_ep-hwnaf + hlp_hwnaf.
            tab_ep-fwnaf = tab_ep-fwnaf + hlp_fwnaf.
            tab_ep-kbetr = tab_ep-kbetr + hlp_kbetr.
            tab_ep-sdiff = tab_ep-sdiff + hlp_sdiff.
            tab_ep-sdiff_fc = tab_ep-sdiff_fc               "1104702
                            + hlp_sdiff_fc.                 "1104702
            MODIFY tab_ep.
            flg_modify = 1.
            EXIT.
          ENDIF.
        ENDLOOP.
***     READ TABLE tab_ep INDEX sy-tabix.                   "2494287
        READ TABLE tab_ep INDEX hlp_tabix.                  "2494287
        IF flg_modify EQ 1.
          IF par_bsud = 'X'
             AND par_xsvo = 'X'.                            "859167
*           MOVE-CORRESPONDING tab_ep TO tab_bset_key.      "2061805
            tab_bset_key-bukrs = bkpf-bukrs.                "2061805
            tab_bset_key-belnr = bkpf-belnr.                "2061805
            tab_bset_key-gjahr = bkpf-gjahr.                "2061805
            tab_bset_key-buzei = tab_ep-buzei.              "2061805
            APPEND tab_bset_key.       "Zeile merken für BSET-Update
          ENDIF.
          DELETE tab_ep.               "Zeile mit n.abzugsf. löschen
        ELSE.                            "Zugehörige Zeile fehlte (dh 100%
          "n.abzugsf.) => Zeile generieren
          tab_ep-stazf = space.
          tab_ep-hwnaf = tab_ep-hwste.
          tab_ep-fwnaf = tab_ep-fwste.
          MODIFY tab_ep.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.                               "par_caos IS INITIAL.     "OT-07
  LOOP AT tab_ep.                                           "OP-01
    tab_ep-hwsteaa = tab_ep-hwste - tab_ep-hwnaf.           "OP-01
    tab_ep-fwsteaa = tab_ep-fwste - tab_ep-fwnaf.           "783666
    MODIFY tab_ep.                                          "OP-01
  ENDLOOP.                                                  "OP-01

* Erwerbsteuer korrigieren ---------------------------------------------
* ----- begin of deletion ----- "853491
*  LOOP AT tab_ep.
*    WRITE tab_ep-kbetr TO hlp_psatz NO-SIGN CURRENCY '3'.
*    IF hlp_psatz(3) EQ '100'.          "vermutlich Erwerbsteuer
*      hlp_hwste  = - tab_ep-hwste.
*      hlp_txgrp  =   tab_ep-txgrp.
*      flg_modify = 0.
*      LOOP AT tab_ep.
*        IF tab_ep-hwste EQ hlp_hwste   "Erwerbsteuer!
*          AND tab_ep-txgrp EQ hlp_txgrp.
*          hlp_hwbas  = tab_ep-hwbas.   "Basisbetrag und Prozentsatz
*          hlp_fwbas  = tab_ep-fwbas.   "merken
*          hlp_kbetr  = tab_ep-kbetr.
*          flg_modify = 1.
*          EXIT.
*        ENDIF.
*      ENDLOOP.
*      IF flg_modify = 1.
*        LOOP AT tab_ep
*          WHERE txgrp EQ hlp_txgrp.
*          WRITE tab_ep-kbetr TO hlp_psatz NO-SIGN CURRENCY '3'.
*          IF hlp_psatz(3) EQ '100'.    "100%-Zeile modifizieren:
*            tab_ep-hwbas = - hlp_hwbas."  Basisbetrag mit umgekehrtem
*            tab_ep-fwbas = - hlp_fwbas."  Vorzeichen und
*            tab_ep-kbetr =   hlp_kbetr."  Partnerzeile übernehmen
*            MODIFY tab_ep.
*            EXIT.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
* ----- end of deletion -----  "853491

* With some unusual calculation procedures it is possible   "1017516
* to have -100% reference for output tax and non-deductible "1017516
* input tax at the same time. In this case we must first    "1017516
* merge deductible and non-deductible input tax in table    "1017516
* gt_ese_bset.                                              "1017516
  PERFORM merge_ese_bset.                                   "1017516

* ----- begin of insertion ----- "853491
* Erwerbsteuer korrigieren ---------------------------------------------
  LOOP AT tab_ep.
*   WRITE tab_ep-kbetr TO hlp_psatz NO-SIGN CURRENCY '3'.   "2620541
*   IF hlp_psatz(3) EQ '100'.     "vermutlich Erwerbsteuer  "2620541
    IF fi_tax_services4=>kbetr_eq_100(                      "2620541
       i_kschl = tab_ep-kschl                               "2620541
       i_kbetr = CONV #( tab_ep-kbetr ) ) = 0.     "100%-Reference    "2620541
      hlp_hwste  = - tab_ep-hwste.
      hlp_txgrp  =   tab_ep-txgrp.
      gv_tax_country = tab_ep-tax_country.
      hlp_mwskz  =   tab_ep-mwskz.
      gv_txdat_from = tab_ep-txdat_from.
      hlp_kschl  =   tab_ep-kschl.                          "912777
      hlp_tabix  =   sy-tabix.
      flg_modify = 0.
*     LOOP AT tab_ep                                           "859167
      LOOP AT gt_ese_bset                                   "859167
           WHERE tax_country = gv_tax_country AND
                 mwskz = hlp_mwskz AND
                 txdat_from = gv_txdat_from.
*       IF tab_ep-hwste EQ hlp_hwste.          "Erwerbsteuer!  "859167
        IF gt_ese_bset-hwste EQ hlp_hwste      "Erwerbsteuer!  "859167
           AND gt_ese_bset-kschl NE hlp_kschl.              "912777
          IF bkpf-awtyp EQ 'FKKSU'.            "document from FI-CA
            lv_kalsm = COND #( WHEN flg_txa_active = abap_true
                                 THEN cl_fot_common_dao=>agent->get_country_data( gv_tax_country )-kalsm
                               ELSE tab_001-kalsm ).
            PERFORM read_t007a USING lv_kalsm hlp_mwskz.
*(DEL)      IF tab_007a-egrkz EQ '9'.                      "1489130
*(DEL)      IF tab_007a-egrkz CA '56789'.         "1489130 "1543271
            IF tab_007a-egrkz CA '56789A'.                  "1543271
              flg_modify = 1.
            ENDIF.
          ELSE.                                "all other documents
*           IF tab_ep-txgrp EQ hlp_txgrp.                      "859167
            IF gt_ese_bset-txgrp EQ hlp_txgrp.              "859167
              flg_modify = 1.
            ENDIF.
          ENDIF.
        ENDIF.
        IF flg_modify = 1.
*         hlp_hwbas  = tab_ep-hwbas.   "Basisbetrag und        "859167
*         hlp_fwbas  = tab_ep-fwbas.   "merken                 "859167
*         hlp_kbetr  = tab_ep-kbetr.                           "859167
          hlp_hwbas  = gt_ese_bset-hwbas. "Basisbetrag und     "859167
          hlp_fwbas  = gt_ese_bset-fwbas.                   "859167
          hlp_kbetr  = gt_ese_bset-kbetr. "Prozentsatz merken  "859167
          EXIT.
        ENDIF.
      ENDLOOP.
      IF flg_modify = 1.
        tab_ep-hwbas = - hlp_hwbas."  Basisbetrag mit umgekehrtem
        tab_ep-fwbas = - hlp_fwbas."  Vorzeichen und
        tab_ep-kbetr =   hlp_kbetr."  Prozentsatz übernehmen
        MODIFY tab_ep INDEX hlp_tabix
               TRANSPORTING hwbas
                            fwbas
                            kbetr.
      ENDIF.
    ENDIF.
  ENDLOOP.
* ----- end of insertion ----- "853491


* ----- Begin Note 2265999 -----                            "2265999
* Correct sign of base for 0% reverserse charge:            "2265999
* Output tax rate should be negative, but there is no -0%.
* Nevertheless this may have been posted correctly.
* It is not wrong in the database in all cases.
* So we find the corresponding input tax item and assure
* that both items have different sign.
* Remark: with "German" calculation procedure
*  -100% reference on ESE we have only the ESA entry
*  which also has a wrong sign. Here this logic will fail.
  LOOP AT tab_ep
       WHERE kbetr = 0
         AND hwste = 0
         AND fwste = 0
         AND mwart = 'V'   "tax code is input tax
         AND stgrp = '1'.  "item is output tax base
    lv_kalsm = COND #( WHEN flg_txa_active = abap_true
                         THEN cl_fot_common_dao=>agent->get_country_data( tab_ep-tax_country )-kalsm
                       ELSE tab_001-kalsm ).
    LOOP AT gt_ese_bset
         WHERE tax_country = tab_ep-tax_country
           AND mwskz  = tab_ep-mwskz
           AND txdat_from = tab_ep-txdat_from
           AND kbetr  = 0
           AND hwste  = 0
           AND fwste  = 0
           AND kschl NE tab_ep-kschl.
      PERFORM read_t007b USING gt_ese_bset-ktosl.
      IF tab_007b-stgrp EQ '2'. "other item is input tax

        PERFORM read_t007a USING lv_kalsm tab_ep-mwskz.
        IF tab_007a-egrkz CA '56789A' AND
          ( gt_ese_bset-txgrp EQ tab_ep-txgrp
            OR bkpf-awtyp EQ 'FKKSU' ).

          IF gt_ese_bset-shkzg EQ 'S'.
            tab_ep-shkzg = 'H'.
            tab_ep-hwbas = - abs( tab_ep-hwbas ).
            tab_ep-fwbas = - abs( tab_ep-fwbas ).
          ELSE.
            tab_ep-shkzg = 'S'.
            tab_ep-hwbas = abs( tab_ep-hwbas ).
            tab_ep-fwbas = abs( tab_ep-fwbas ).
          ENDIF.
          MODIFY tab_ep
                 TRANSPORTING hwbas
                              fwbas
                              shkzg.
          EXIT.   "from loop at gt_ese_bset

        ENDIF.

      ENDIF.
    ENDLOOP.    "at gt-ese_bset
  ENDLOOP.      "at tab_ep
* ----- End Note 2265999 -----                              "2265999


* No Tax-Relevant G/L-Account found: Take another Account from BSEG
  IF ep-hkont IS INITIAL.
    ep-hkont = hlp_gl_account.
  ENDIF.
  CLEAR hlp_gl_account.

* No ZUONR found on G/L-items: Take it from a tax item      "938627
  IF ep-zuonr IS INITIAL.                                   "938627
    ep-zuonr = hlp_zuonr.                                   "938627
  ENDIF.                                                    "938627

* Bolle Doganali: If there are only G/L-Accounts, it's a Bo.Do.Document
  IF ( NOT par_bodo IS INITIAL ) AND ( NOT flg_bd_only_gl IS INITIAL ).
*   Get first G/L Account not in the BSET --> Should be Bo. Do. Account
    LOOP AT tab_ep.
      DELETE tab_bd_gl_accounts WHERE hkont = tab_ep-tkont.
    ENDLOOP.
    READ TABLE tab_bd_gl_accounts INDEX 1 INTO hlp_gl_account.
  ENDIF.

* Adapt debit/credit indicator shkzg to xnegp-flag.         "2290231
* tab_ep-shkzg is used (and changed) in previous sections.  "2290231
* Here tab_ep-shkzg may again be changed for final output,  "2290231
* taking into account xnegp.                                "2290231
* This can only be relevant if debit/credit separation.     "2290231
  IF par_xsht EQ 'X'.                                       "2290231
    PERFORM negative_posting.                               "2290231
  ENDIF.                                                    "2290231

  IF NOT g_read_bseg IS INITIAL                             "1120571
     AND NOT gs_any_bseg-bukrs IS INITIAL.                  "1120571
    READ TABLE gt_more_bseg INTO wa_more_bseg               "1120571
         WITH TABLE KEY                                     "1120571
              bukrs = bkpf-bukrs                            "1120571
              belnr = bkpf-belnr                            "1120571
              gjahr = bkpf-gjahr                            "1120571
              koart = 'S'.                                  "1120571
    IF sy-subrc <> 0.                                       "1120571
      MOVE gs_any_bseg TO bseg.                             "1120571
      PERFORM append_bseg.                                  "1120571
    ENDIF.                                                  "1120571
  ENDIF.                                                    "1120571

  "JVA in RFUMSV00
  PERFORM check_jva_active_for_bukrs
          USING bkpf-bukrs
       CHANGING lv_jva_active.
  IF lv_jva_active = abap_true.
    cl_jva_enrich_tax_lines=>get_instance( )->split(
      EXPORTING
        iv_post_date         = par_bdat
        iv_use_country_curr  = par_xstw
        iv_batch_input       = par_binp
        iv_subst_cost_obj_ri = par_cori
        iv_use_orig_cost_obj = par_orig
        is_document_header   = bkpf
        it_venture_range     = sel_vnam[]
        it_eq_group_range    = sel_grou[]
      IMPORTING
        et_split_tax        = gt_splitted_inf_doc
      CHANGING
        ct_tax_item_extract = tab_ep[] ).
  ENDIF.

* Selektierte Daten extrahieren ----------------------------------------
  LOOP AT tab_ep.

    AT NEW mwskz_and_txdat_from.
*      IF par_lis5 EQ 'X'.                                  "1104702
*        READ TABLE tab_diff WITH KEY mwskz = tab_ep-mwskz. "1104702
*      ENDIF.                                               "1104702
* G/L-Account
      LOOP AT it_glaccount INTO is_glaccount
              WHERE tax_country = tab_ep-tax_country
                AND mwskz = tab_ep-mwskz                    "OP-30
                AND txdat_from = tab_ep-txdat_from
                AND koart = 'S'.                            "992241
        ep-hkont = is_glaccount-hkont.                      "OP-30
      ENDLOOP.                                              "OP-30
      IF sy-subrc <> 0.                                     "992241
        LOOP AT it_glaccount INTO is_glaccount              "992241
                WHERE tax_country = tab_ep-tax_country
                  AND mwskz = tab_ep-mwskz                  "992241
                  AND txdat_from = tab_ep-txdat_from
                  AND koart <> 'S'.                         "992241
          ep-hkont = is_glaccount-hkont.                    "992241
        ENDLOOP.                                            "992241
      ENDIF.                                                "992241

* In case of a stock transfer take adress data from T001(N) "1686870
* (determined in form stock_transfer_address)               "1686870
      IF NOT gt_wia_adrnr[] IS INITIAL.                     "1686870
        READ TABLE gt_wia_adrnr INTO gs_wia_adrnr           "1686870
             WITH KEY tax_country = tab_ep-tax_country
                      mwskz = tab_ep-mwskz.                 "1686870
        IF sy-subrc = 0.                                    "1686870
          ep-wia_adrnr = gs_wia_adrnr-adrnr.                "1686870
          IF gs_wia_adrnr-stceg NE space.                   "1686870
            ep-stceg = gs_wia_adrnr-stceg.                  "1686870
          ENDIF.                                            "1686870
        ELSE.                                               "1686870
          CLEAR ep-wia_adrnr.                               "1686870
        ENDIF.                                              "1686870
      ENDIF.                                                "1686870

* Copy discount amounts to respective line items            "1868787
* Done only once per (mwskz, ktosl).                        "1868787
      ep-disco_hw = 0.                                      "1868787
      ep-disco_fw = 0.                                      "1868787
      READ TABLE gt_discounts INTO gs_discounts             "1868787
           WITH KEY tax_country = tab_ep-tax_country
                    mwskz = tab_ep-mwskz                    "1868787
                    txdat_from = tab_ep-txdat_from
                    ktosl = tab_ep-ktosl.                   "1868787
      IF sy-subrc <> 0.                                     "1868787
        READ TABLE gt_discounts INTO gs_discounts           "1868787
             WITH KEY tax_country = tab_ep-tax_country
                      mwskz = tab_ep-mwskz                  "1868787
                      txdat_from = tab_ep-txdat_from
                      ktosl = space.                        "1868787
        IF sy-subrc = 0.                                    "1868787
          ep-disco_hw = gs_discounts-dmbtr.                 "1868787
          ep-disco_fw = gs_discounts-wrbtr.                 "1868787
*   convert amount to reporting currency if needed          "1868787
          IF gd_lwbas NE 0.                                 "1868787
            IF gd_lwbas NE gd_hwbas AND                     "1868787
               gd_hwbas NE 0.                               "1868787
              ep-disco_hw = ep-disco_hw                     "1868787
                          * gd_lwbas / gd_hwbas.            "1868787
            ENDIF.                                          "1868787
          ENDIF.                                            "1868787
*        mark (mwskz, ktosl) as used                        "1868787
          gs_discounts-ktosl = tab_ep-ktosl.                "1868787
          APPEND gs_discounts TO gt_discounts.              "1868787
        ENDIF.                                              "1868787
      ENDIF.                                                "1868787

    ENDAT.

* --- begin delete note 2344727 ---                         "2344727
*    tab_ep-hwgross = abs( tab_ep-hwbas ) + abs( tab_ep-hwste )."OP-03
*    IF ( tab_ep-hwbas < 0 ).                                "OP-10
*      tab_ep-hwgross = tab_ep-hwgross * -1.                 "OP-10
*    ENDIF.                                                  "OP-10
**    if ( tab_ep-mwart = 'A' ) or
**   ( ( tab_ep-mwart = 'V' ) and ( tab_ep-ktosl = 'ESA' ) ).  "OP-03
**       tab_ep-hwgross = tab_ep-hwgross * -1.                 "OP-03
**    endif.                                                   "OP-03
*    MODIFY tab_ep.                                          "OP-03
* --- end delete note 2344727 ---                           "2344727


    MOVE-CORRESPONDING tab_ep TO ep.
    IF flg_xwia IS INITIAL.                                 "2670940
      CLEAR: ep-lstml.                                      "2670940
    ENDIF.

    IF ( NOT par_bodo IS INITIAL )     "Bolle Doganali
    AND ( NOT flg_bd_only_gl IS INITIAL ). "Bolle Doganali Document
      ep-tkont = hlp_gl_account.       "Even if it is initial
      IF hlp_gl_account IS INITIAL.                         "1014836
        ep-tkont = hlp_bodo_accnt.                          "1014836
        IF ep-hkont IS INITIAL.                             "1014836
          ep-hkont = hlp_bodo_accnt.                        "1014836
        ENDIF.                                              "1014836
      ENDIF.                                                "1014836
    ENDIF.

    ep-gjahr = bkpf-gjahr.
    DATA: l_kbetr TYPE kbetr_tax.                           "2860148
    l_kbetr = tab_ep-kbetr.                                 "2860148
*   WRITE tab_ep-kbetr TO ep-psatz NO-SIGN CURRENCY '3'.    "2620541
    ep-psatz = fi_tax_services4=>kbetr_conv_to_char(        "2620541
               i_kschl = tab_ep-kschl                       "2620541
               i_kbetr = l_kbetr ).                         "2860148

    IF par_lis5 EQ 'X'.                "Steuerkontrolle
      READ TABLE tab_diff WITH KEY tax_country = tab_ep-tax_country
                                   mwskz = tab_ep-mwskz     "1104702
                                   txdat_from = tab_ep-txdat_from
                                  flg_fc = space.           "1104702
      IF tab_diff-rndbl GE tab_diff-rndst.
        hlp_sdiff = tab_diff-rndbl.
      ELSE.
        hlp_sdiff = tab_diff-rndst.
      ENDIF.
      IF ep-sdiff GE 0.
        IF ep-sdiff LE hlp_sdiff.
          ep-sdiff = 0.
        ENDIF.
      ELSE.
        ep-sdiff = - ep-sdiff.
        IF ep-sdiff LE hlp_sdiff.
          ep-sdiff = 0.
        ENDIF.
        ep-sdiff = - ep-sdiff.
      ENDIF.
* Steuerkontrolle in Fremdwaehrung                          "1104702
      CLEAR ep-sdiff_fc.                                    "1104702
      IF ep-sdiff NE 0.                                     "1104702
        IF bkpf-waers = tab_001-waers.                      "1104702
          ep-sdiff_fc = ep-sdiff.                           "1104702
        ELSE.                                               "1104702
          READ TABLE tab_diff                               "1104702
               WITH KEY tax_country = tab_ep-tax_country
                        mwskz = tab_ep-mwskz                "1104702
                        txdat_from = tab_ep-txdat_from
                       flg_fc = 'X'.                        "1104702
          IF tab_diff-rndbl GE tab_diff-rndst.              "1104702
            hlp_sdiff_fc = tab_diff-rndbl.                  "1104702
          ELSE.                                             "1104702
            hlp_sdiff_fc = tab_diff-rndst.                  "1104702
          ENDIF.                                            "1104702
          hlp_hwste2 = abs( tab_ep-sdiff_fc ).              "1104702
          IF hlp_hwste2 GT hlp_sdiff_fc.                    "1104702
            ep-sdiff_fc = tab_ep-sdiff_fc.                  "1104702
          ENDIF.                                            "1104702
        ENDIF.                                              "1104702
      ENDIF.                                                "1104702
* ----- Begin deletion note 1104702 -----                   "1104702
** Steuerkontrolle für SD-Fakturen in Fremdwährung
*      IF ( bkpf-glvor = 'SD00' ) AND
*         ( ep-sdiff NE 0 ) AND
*        ( bkpf-waers NE bkpf-hwaer ) AND                    "442284
*        ( bkpf-txkrs IS INITIAL OR                          "838230
*          bkpf-txkrs EQ bkpf-kursf ).                       "838230
** hlp_sdiff umrechnen in Fremdwährung.
*        CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
*          EXPORTING
*            local_currency   = bkpf-hwaer
*            foreign_currency = bkpf-waers
*            local_amount     = hlp_sdiff
*            date             = bkpf-wwert
*            rate             = bkpf-kursf
*          IMPORTING
*            foreign_amount   = hlp_sdiff_fc.
*
** Ist Differenz neu berechnen
**        PERFORM read_tax_amount        "Steuerbetrag berechnen "825186
**          USING ep-mwskz tab_ep-kschl ep-fwbas                 "825186
**           CHANGING hlp_hwste2.                                "825186
*        PERFORM calculate_tax_amount   "Steuerbetrag berechnen  "825186
*          USING ep-mwskz tab_ep-kschl ep-ktosl              "825186
*                ep-fwbas                                    "825186
*          CHANGING hlp_hwste2.                              "825186
**        ep-sdiff = hlp_hwste2 - ep-fwste.                  "900597
***vergleich soll/ist in Fremdwährung                        "900597
**        ep-sdiff = abs( ep-sdiff ).                        "900597
**        IF ep-sdiff < hlp_sdiff_fc.                        "900597
*        hlp_hwste2 = abs( hlp_hwste2 - ep-fwste ).          "900597
**vergleich soll/ist in Fremdwährung                         "900597
*        IF hlp_hwste2 < hlp_sdiff_fc.                       "900597
*          ep-sdiff = 0.
*        ENDIF.
*      ENDIF.                                                "442284
* ----- End deletion note 1104702 -----                     "1104702

    ENDIF.
    CASE tab_ep-stgrp.
      WHEN 1.
        ep-mwart = 'A'.
      WHEN 2.
        ep-mwart = 'V'.
    ENDCASE.
    IF ( par_xsau NE space AND ep-mwart EQ 'A' ) OR
       ( par_xsvo NE space AND ep-mwart EQ 'V' ).
      IF ( ep-hwbas GT 0 AND ep-hwste LT 0 ) OR
         ( ep-hwbas LT 0 AND ep-hwste GT 0 ).
        ep-hwbas = - ep-hwbas.
        ep-fwbas = - ep-fwbas.
      ENDIF.

* --- begin delete note 2344727 ---                         "2344727
*      IF ( ep-hwbas GT 0 AND ep-hwgross LT 0 ) OR
*         ( ep-hwbas LT 0 AND ep-hwgross GT 0 ).             "OP-28
*        ep-hwgross = - ep-hwgross.                          "OP-28
*      ENDIF.                                                "OP-28
* --- end delete note 2344727 ---                           "2344727
      ep-hwgross = ep-hwbas + ep-hwste.                     "2344727

* Authority check for blart is done very late here, so the  "2715311
* warning will be issued only if items were skipped that    "2715311
* would otherwise have been reported.                       "2715311
* Range gr_auth_blart is only filled if optimized code is   "2715311
* executed. It is initial if selection is via LDB.          "2715311
      IF NOT ep-blart IN gr_auth_blart.                     "2715311
        ADD 1 TO gd_cnt_no_auth.                            "2715311
        CONTINUE.                                           "2715311
      ENDIF.                                                "2715311
* Authority check for gsber is recognized very late here.   "2715311
* This means only that data that should have been picked    "2715311
* from BSEG (hkont, zuonr, etc.) may be missing or altered. "2715311
      IF NOT gd_flg_auth_gsber IS INITIAL.                  "2715311
        ADD 1 TO gd_cnt_no_auth.                            "2715311
      ENDIF.                                                "2715311

      EXTRACT daten.

      IF par_binp = 'X'                "Batch-Input gewuenscht
        AND lv_jva_active = abap_false
        AND tab_ep-stazf IS INITIAL                         "2163848
        AND tab_ep-hwste NE tab_ep-hwnaf.                   "2163848
*       begin of note 877045
        READ TABLE gt_bukrs_split_act WITH KEY bukrs = bkpf-bukrs
        TRANSPORTING NO FIELDS.
*       wenn der buchungskreis keine BA nutzt, bleibt alles beim alten
        IF sy-subrc NE 0.
          CLEAR tab_bi.
          tab_bi-bukrs = bkpf-bukrs.     "Buchungskreis
          tab_bi-hkont = tab_ep-tkont.   "Hauptbuchkonto (Steuerkonto)
          tab_bi-saldo = tab_ep-hwste - tab_ep-hwnaf.
          "abzugsfÃ¤hige bzw. abzufÃ¼hrende
          "  Steuer in HauswÃ¤hrung
          COLLECT tab_bi.
        ELSE.
*         Aufbau der Tabelle, mit der die Kontierungen ermittelt werden
          MOVE-CORRESPONDING bkpf TO gs_unsplitted_information.
          gs_unsplitted_information-buzei = 0.              "1566235
          gs_unsplitted_information-tkont = tab_ep-tkont.
          gs_unsplitted_information-tax_country = tab_ep-tax_country.
          gs_unsplitted_information-mwskz = tab_ep-mwskz.
          gs_unsplitted_information-txdat_from = tab_ep-txdat_from.
          gs_unsplitted_information-dmbtr = tab_ep-hwste - tab_ep-hwnaf.
          COLLECT gs_unsplitted_information INTO gt_unsplitted_information.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

* begin of note 877045
  IF par_binp = 'X'.               "Batch-Input gewÃ¼nscht
    IF lv_jva_active = abap_false.
      READ TABLE gt_bukrs_split_act WITH KEY bukrs = bkpf-bukrs
      TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.

        PERFORM check_and_treat_zero                        "1566235
                USING    bkpf-awtyp                         "1566235
                CHANGING gt_unsplitted_information.         "1566235

*       Melden in LW nutze Belegwährung für Belegaufteilung, falls LW = FW     "3164515
        IF par_xstw EQ 'X' AND tab_001-waers EQ bkpf-waers. "3164515
          LOOP AT gt_unsplitted_information INTO gs_unsplitted_information. "3164515
            gs_unsplitted_information-wrbtr = gs_unsplitted_information-dmbtr. "3164515
            CLEAR gs_unsplitted_information-dmbtr.          "3164515
            MODIFY gt_unsplitted_information FROM gs_unsplitted_information "3164515
                                             TRANSPORTING wrbtr dmbtr. "3164515
          ENDLOOP.                                          "3164515
        ENDIF.                                              "3164515

        LOOP AT gt_unsplitted_information INTO gs_unsplitted_information.

          REFRESH gt_splitted_inf_single_line.
          CALL FUNCTION 'FI_SPLIT_TAX'
            EXPORTING
              is_vat_amount  = gs_unsplitted_information
              id_budat       = par_bdat                        "time-dep split
            IMPORTING
              et_vat_amounts = gt_splitted_inf_single_line
            EXCEPTIONS
              internal_error = 1
              OTHERS         = 2.

          IF sy-subrc NE 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
*--->>> EOL-0083 24.04.2024
          IF NOT so_prctr IS INITIAL OR NOT so_gsber IS INITIAL.
            LOOP AT gt_splitted_inf_single_line ASSIGNING FIELD-SYMBOL(<fs_splitt>).
              DATA(lv_tabix) = sy-tabix.
              IF NOT so_prctr IS INITIAL.
                IF <fs_splitt>-addaa-split+154(10) IN so_prctr.
                  <fs_splitt>-dmbtr = gs_unsplitted_information-dmbtr.
                ELSE.
                  DELETE gt_splitted_inf_single_line INDEX lv_tabix.
                  CONTINUE.
                ENDIF.
              ENDIF.
              IF NOT so_gsber IS INITIAL.
                IF <fs_splitt>-addaa-split+95(4) IN so_gsber.
                  <fs_splitt>-dmbtr = gs_unsplitted_information-dmbtr.
                ELSE.
                  DELETE gt_splitted_inf_single_line INDEX lv_tabix.
                  CONTINUE.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
*---<<<
          INSERT LINES OF gt_splitted_inf_single_line INTO TABLE gt_splitted_inf_doc.
        ENDLOOP.
      ENDIF.
    ENDIF.

    LOOP AT gt_splitted_inf_doc INTO gs_splitted_inf_doc.
      tab_bi-bukrs = gs_splitted_inf_doc-bukrs.
      tab_bi-hkont = gs_splitted_inf_doc-tkont.
      IF par_xstw EQ 'X' AND tab_001-waers EQ bkpf-waers.   "3164515
        tab_bi-saldo = gs_splitted_inf_doc-wrbtr.           "3164515
      ELSE.                                                 "3164515
        tab_bi-saldo = gs_splitted_inf_doc-dmbtr.
      ENDIF.                                                "3164515
      tab_bi-adaa = gs_splitted_inf_doc-addaa.
*       no MWSKZ in table tab_bi!
      COLLECT tab_bi.  "globale Tabelle mit Verbuchungsdaten f. BI
    ENDLOOP.
  ENDIF.
* end of note 877045
  REFRESH it_glaccount.                                     "OP-30
  CLEAR is_glaccount.                                       "OP-30
  REFRESH: gt_unsplitted_information, gt_splitted_inf_doc, gt_splitted_inf_single_line. "877045
ENDFORM.                    " GET_BKPF_LATE

*----------------------------------------------------------------------*
* Extrahieren der Daten je Beleg                                       *
*----------------------------------------------------------------------*
GET bkpf LATE.
  PERFORM process_bkpf_late.



*----------------------------------------------------------------------*
* Verarbeitung der extrahierten Daten                                  *
*----------------------------------------------------------------------*
END-OF-SELECTION.

  IF sy-batch <> space                                      "1066663
     AND gd_selection_stopped <> space.                     "1066663
    ld_aplstat = 'A'.                                       "2768541
    PERFORM scma_close.                                     "2768541
    MESSAGE a273                                            "1066663
            WITH bkpf-bukrs bkpf-belnr bkpf-gjahr.          "1066663
  ENDIF.                                                    "1066663

  IF ( par_xcas IS INITIAL ).
    IF ( NOT par_sort = '2' ).                              "OP-18
      SORT STABLE BY                                        "3260620
        ep-bukrs                         "Buchungskreis
        ep-mwart                         "Umsatzsteuerart
*      ep-mwskz                         "Umsatzsteuerkennzeichen "OP-11
        ep-buper                         "Buchungsperiode
*     ep-waers                         "Währungsschlüssel    "OP-02
        ep-budat                         "Buchungsdatum
        ep-belnr                         "Belegnummer
        ep-ktosl.                        "Vorgangsschlüssel
    ELSE.                                                   "OP-18
      SORT STABLE BY                                        "OP-18 "3260620
        ep-bukrs                         "Buchungskreis     "OP-18
        ep-mwart                         "Umsatzsteuerart   "OP-18
*        ep-buper                         "Buchungsperiode   "OP-18
        ep-bldat                         "Belegdatum        "OP-18
        ep-belnr                         "Belegnummer       "OP-18
        ep-ktosl.                        "Vorgangsschlüssel "OP-18
    ENDIF.                                                  "OP-18
  ELSE.
    SORT STABLE BY                                          "3260620
      ep-bukrs                         "Buchungskreis
      ep-mwart                         "Umsatzsteuerart
      hlp_sort                         "Quittungsnr. (numerischer Teil)
      ep-belnr                         "Belegnummer
      ep-tax_country
      ep-mwskz                         "Umsatzsteuerkennzeichen
      ep-txdat_from
      ep-ktosl.                        "Vorgangsschlüssel
  ENDIF.


  IF par_umsv = 'X'.
    REFRESH tab_umsv.
    CLEAR fle_umsvz.
    fle_umsvz-mandt = sy-mandt.
    fle_umsvz-laufd = par_laud.
    fle_umsvz-laufi = par_laui.
    fle_umsvz-budt1 = br_budat-low.
    fle_umsvz-budt2 = br_budat-high.
    fle_umsvz-mona1 = sel_mona-low.
    fle_umsvz-mona2 = sel_mona-high.
    fle_umsvz-gjahr = br_gjahr-low.
    fle_umsvz-bldt1 = br_bldat-low.
    fle_umsvz-bldt2 = br_bldat-high.
    IF gd_vatdate_active = 'X'.                             "1023317
      IF     fle_umsvz-budt1 IS INITIAL                     "1023317
         AND fle_umsvz-budt2 IS INITIAL.                    "1023317
        fle_umsvz-budt1 = dso_vtdt-low.                     "1023317
        fle_umsvz-budt2 = dso_vtdt-high.                    "1023317
      ENDIF.                                                "1023317
    ENDIF.                                                  "1023317
  ENDIF.


  LOOP.

    AT FIRST.
      REFRESH tab_hwaer.
    ENDAT.


    AT NEW ep-bukrs.
      CLEAR gt_alv.
      gt_alv-bukrs = ep-bukrs.
      APPEND gt_alv.                                        "928371
      READ TABLE gt_alv INDEX sy-tabix ASSIGNING <gt_alv>.  "928371
      CLEAR gd_tabalv_cnt.                                  "928371
      REFRESH tab_bukrs.
      PERFORM read_t001 USING ep-bukrs.
      IF par_xcas = 'X'.
        CLEAR t001z.
        SELECT SINGLE * FROM t001z
          WHERE bukrs EQ ep-bukrs
            AND party EQ 'SAPC01'.
      ENDIF.
      bhdgd-bukrs   = ep-bukrs.
      bhdgd-werte   = ep-bukrs.
      PERFORM new-section(rsbtchh0).
    ENDAT.


    AT NEW ep-mwart.
      REFRESH tab_mwart.
      PERFORM set_lfdnr USING ep-bukrs
                              ep-gjahr
                              ep-mwart
                        CHANGING hlp_lfdnr.
    ENDAT.


    IF par_bsud = 'X'.                                      "2061805
*  Save BSET-key for later update on stmdt, stmti           "2061805
      tab_bset_key-bukrs = ep-bukrs.                        "2061805
      tab_bset_key-belnr = ep-belnr.                        "2061805
      tab_bset_key-gjahr = ep-gjahr.                        "2061805
      tab_bset_key-buzei = ep-buzei.                        "2061805
      APPEND tab_bset_key.                                  "2061805
    ENDIF.                                                  "2061805

    IF par_bsud = 'X'.
*      UPDATE bset                                          "2061805
*        SET stmdt = hlp_stmdt                              "2061805
*            stmti = hlp_stmti                              "2061805
*        WHERE bukrs EQ ep-bukrs                            "2061805
*          AND belnr EQ ep-belnr                            "2061805
*          AND gjahr EQ ep-gjahr                            "2061805
*          AND buzei EQ ep-buzei.                           "2061805

*     Bereits zu 4.0 umgesetzte Belege markieren
      LOOP AT ums40 WHERE bukrs EQ ep-bukrs.
        UPDATE bkpf
          SET duefl = 'A'
          WHERE belnr EQ ep-belnr
            AND bukrs EQ ep-bukrs
            AND gjahr EQ ep-gjahr
            AND duefl EQ 'X'.
        cnt_updatecalls = cnt_updatecalls + 1.              "2061805
        EXIT.
      ENDLOOP.
*     cnt_updatecalls = cnt_updatecalls + 1.                "2061805
      IF cnt_updatecalls >= 100.
        COMMIT WORK.
        cnt_updatecalls = 0.
      ENDIF.
    ENDIF.
    IF NOT par_stru IS INITIAL.        "Rounding VAT in local currency
      PERFORM round_taxes USING    ep-waers
                                   tab_001-waers
                                   ep-bukrs
                                   ep-budat
                                   ep-hwste
                                   ep-hwnaf
                          CHANGING ep-hwste_r
                                   ep-hwnaf_r.
    ENDIF.
    PERFORM:
      append_ep,
      append_sdiff USING ep-sdiff,
      collect_tab_mwart,
      collect_tab_bukrs.

    IF par_lis1 NE space                                    "928371
       OR par_lis3 NE space.                                "928371
      ADD 1 TO gd_tabalv_cnt.                               "928371
      IF gd_tabalv_cnt GE 100.                              "928371
        APPEND LINES OF gt_alv-t_auste_ep                   "928371
                   TO <gt_alv>-t_auste_ep.                  "928371
        APPEND LINES OF gt_alv-t_voste_ep                   "928371
                   TO <gt_alv>-t_voste_ep.                  "928371
        REFRESH: gt_alv-t_auste_ep,                         "928371
                 gt_alv-t_voste_ep.                         "928371
        CLEAR gd_tabalv_cnt.                                "928371
      ENDIF.                                                "928371
    ENDIF.                                                  "928371


    AT END OF ep-mwart.
      SORT tab_mwart.
      LOOP AT tab_mwart.
        PERFORM append_mwart.
      ENDLOOP.
      PERFORM append_trvor USING  ep
                                  hlp_lfdnr
                           CHANGING tab_trvor[].
    ENDAT.


    AT END OF ep-bukrs.
      SORT tab_bukrs.
      LOOP AT tab_bukrs.
        IF par_umsv = 'X'
           OR par_euva = 'X'.                               "751603
          PERFORM collect_tab_umsv.
        ENDIF.
        PERFORM:
          append_bukrs,
          collect_tab_hwaer.
      ENDLOOP.
*     APPEND gt_alv.                                         "928371
*  This somewhat clumsy way to create table gt_alv saves     "928371
*  a lot of memory compared to the old method when single    "928371
*  items lists are selected.                                 "928371
*  More elegant solutions would have implicitly changed the  "928371
*  interfaces to forms apend_ep, etc.                        "928371
*  which is not allowed because the includes are used by     "928371
*  other reports like old versions of RGJVTAX2.              "928371
      IF gd_tabalv_cnt NE 0.                                "928371
        APPEND LINES OF gt_alv-t_auste_ep                   "928371
                   TO <gt_alv>-t_auste_ep.                  "928371
        APPEND LINES OF gt_alv-t_voste_ep                   "928371
                   TO <gt_alv>-t_voste_ep.                  "928371
      ENDIF.                                                "928371
      APPEND LINES OF gt_alv-t_auste_sum                    "928371
                 TO <gt_alv>-t_auste_sum.                   "928371
      APPEND LINES OF gt_alv-t_voste_sum                    "928371
                 TO <gt_alv>-t_voste_sum.                   "928371
      APPEND LINES OF gt_alv-t_sdiff_ep                     "928371
                 TO <gt_alv>-t_sdiff_ep.                    "928371
      APPEND LINES OF gt_alv-t_bukrs                        "928371
                 TO <gt_alv>-t_bukrs.                       "928371
      CLEAR gt_alv.                                         "928371
    ENDAT.


    AT LAST.
      SORT tab_hwaer.

      LOOP AT tab_hwaer.
        AT FIRST.
          bhdgd-bukrs   = space.
          bhdgd-werte   = space.
          PERFORM new-section(rsbtchh0).
        ENDAT.

        AT NEW hwaer.
          cnt_bukrs_pro_hwaer = 0.
        ENDAT.

        AT NEW bukrs.
          PERFORM read_t001 USING tab_hwaer-bukrs.
          cnt_bukrs_pro_hwaer = cnt_bukrs_pro_hwaer + 1.
        ENDAT.

        PERFORM append_bukrs_sum.
      ENDLOOP.

* ----- Begin Delete Note 2061805 -----                     "2061805
*      IF par_bsud = 'X'.
**        BSET-Update für aus TAB_EP gelöschte Zeilen
*        cnt_updatecalls = 0.
*        LOOP AT tab_bset_key.
*          UPDATE bset
*            SET stmdt = hlp_stmdt
*              stmti = hlp_stmti
*            WHERE bukrs = tab_bset_key-bukrs
*              AND belnr = tab_bset_key-belnr
*              AND gjahr = tab_bset_key-gjahr
*              AND buzei = tab_bset_key-buzei.
*          cnt_updatecalls = cnt_updatecalls + 1.
*          IF cnt_updatecalls >= 100.
*            COMMIT WORK.
*            cnt_updatecalls = 0.
*          ENDIF.
*        ENDLOOP.
*        COMMIT WORK.
*      ENDIF.
* ----- End Delete Note 2061805 -----                       "2061805
*LOOP AT gt_alv.                                        "OP-02
*   lfd_number = 0.                                     "OP-02
*   sort gt_alv-t_auste_ep by belnr.                    "OP-02
*   LOOP AT gt_alv-t_auste_ep INTO ls_modify_lfdnr.     "OP-02
*       add 1 to lfd_number.                            "OP-02
*       ls_modify_lfdnr-lfdnr = lfd_number.             "OP-02
*       modify gt_alv-t_auste_ep from ls_modify_lfdnr   "OP-02
*       transporting lfdnr.                             "OP-02
*   ENDLOOP.                                            "OP-02
*   lfd_number = 0.                                     "OP-02
*   sort gt_alv-t_voste_ep by belnr.                    "OP-02
*   LOOP AT gt_alv-t_voste_ep INTO ls_modify_lfdnr.     "OP-02
*       add 1 to lfd_number.                            "OP-02
*       ls_modify_lfdnr-lfdnr = lfd_number.             "OP-02
*       modify gt_alv-t_voste_ep from ls_modify_lfdnr   "OP-02
*       transporting lfdnr.                             "OP-02
*   ENDLOOP.                                            "OP-02
*ENDLOOP.

    ENDAT.

  ENDLOOP.

  ASSIGN gt_alv TO <gt_alv>.           "Für die Anzeigenvariantepflege

  FREE gt_more_bseg.                                        "1557535
  PERFORM kna1_lfa1_read                                    "1557535
*         USING ep-koart ep-ktnra 'X'             "1557535  "2199372
          USING ep-koart ep-ktnra ep-bukrs 'X'              "2199372
          CHANGING ep-xcpdk sy-subrc.                       "1557535

  PERFORM badis_for_gt_alv.                                 "500308
  PERFORM create_batch_input_mappe.
*--->>> EOL-0083 24.04.2024
* beim Sachkonto 48000199 wird durch die FMDERIVE eine Ableitung der FIPOS (in 8000.60030) vorgenommen
* dies soll auch im Protokoll so dargestellt werden
  LOOP AT gt_bi_items_split ASSIGNING FIELD-SYMBOL(<fs_split>).
    IF <fs_split>-account  = '0048000199'.
      <fs_split>-fipos    = '800060030'.
    ENDIF.
  ENDLOOP.
  LOOP AT gt_bi_items_split INTO DATA(gs_bi_items_split).
    DATA(lv_tabix) = sy-tabix.
    IF NOT so_gsber IS INITIAL.
      IF NOT gs_bi_items_split-gsber IN so_gsber.
        DELETE gt_bi_items_split INDEX lv_tabix.
      ENDIF.
    ENDIF.

    IF NOT so_prctr IS INITIAL.
      IF NOT gs_bi_items_split-prctr IN so_prctr.
        DELETE gt_bi_items_split INDEX lv_tabix.
      ENDIF.
    ENDIF.
  ENDLOOP.
*---<<<

  PERFORM insert_umsv.
  PERFORM insert_trvor.
  PERFORM create_dta_file.
  PERFORM output_euva.                                      "751603
  PERFORM update_bset.                                      "2061805

* add message about deleted items due to authorization      "2715311
  IF gd_cnt_no_auth > 0.                                    "2715311
    DATA: ldummy.                                           "2715311
    MESSAGE s398(f5a) WITH gd_cnt_no_auth                   "2715311
            INTO ldummy.                                    "2715311
    CALL FUNCTION 'LDB_LOG_WRITE'.                          "2715311
  ENDIF.                                                    "2715311

* Ausgabe
  IF par_xml EQ space.                 "xml
    PERFORM create_gt_excluding.
    IF flg_notp = 'X'.                   "Keine Anzeigenvariantenpflege
      PERFORM print.
    ELSEIF var_avp1 = 'X'.             "Anzeigenvariantenpflege AUSTE_EP
      PERFORM print_auste_ep.
    ELSEIF var_avp2 = 'X'.            "Anzeigenvariantenpflege AUSTE_SUM
      PERFORM print_auste_sum.
    ELSEIF var_avp3 = 'X'.             "Anzeigenvariantenpflege VOSTE_EP
      PERFORM print_voste_ep.
    ELSEIF var_avp4 = 'X'.            "Anzeigenvariantenpflege VOSTE_SUM
      PERFORM print_voste_sum.
    ELSEIF var_avp5 = 'X'.             "Anzeigenvariantenpflege SDIFF_EP
      PERFORM print_sdiff_ep.
    ELSEIF var_avp6 = 'X'.             "Anzeigenvariantenpflege BUKRS
      PERFORM print_bukrs.
    ELSEIF var_avp7 = 'X'.            "Anzeigenvariantenpflege BUKRS_SUM
      PERFORM print_bukrs_sum.
    ENDIF.
  ELSE.                                "xml
    PERFORM xml_output.                "xml
  ENDIF.                               "xml

* Set back output language                                  "1263340
  IF NOT par_lang IS INITIAL.                               "1263340
    IF NOT sy-batch IS INITIAL                              "1263340
       OR NOT gd_exec_and_print IS INITIAL.                 "1307450
      SET LOCALE LANGUAGE gd_locale_language                "1263340
                 COUNTRY  gd_locale_country.                "1263340
      SET LANGUAGE sy-langu.                                "1263340
      IF NOT g_bukrs_land IS INITIAL.                       "1263340
        SET COUNTRY space.                                  "1263340
      ENDIF.                                                "1263340
    ENDIF.                                                  "1263340
  ENDIF.                                                    "1263340

  PERFORM no_display.
  PERFORM scma_close.                                       "2768541
* Update application log for SFIN
  IF sy-batch IS NOT INITIAL.
    PERFORM update_app_log.
  ENDIF.
*----------------------------------------------------------------------*
* Includes                                                             *
*----------------------------------------------------------------------*
* Selection
  INCLUDE i_rfums_selection_forms.
* Output (ABAP List Viewer)
  INCLUDE i_rfums_alv_forms.
* DTA File (DME-Tool)
  INCLUDE i_rfums_dme_forms.

  INCLUDE i_rfums_xml_forms.
* Electronic Tax Declaration
  INCLUDE i_rfums_euva_forms.                               "751603
* SRF Classic mode
  INCLUDE i_rfums_srf_forms.                                "2445729

  INCLUDE make_rldnr_invisible.                             "871301

*&---------------------------------------------------------------------*
*&      Form  FILL_SCMA_SELKRIT "2768541
*&---------------------------------------------------------------------*
FORM fill_scma_selkrit  TABLES   ct_selkrit STRUCTURE schedman_selkrit.

  DATA: lt_rsparams TYPE TABLE OF rsparams,
        ls_selkrit  TYPE schedman_selkrit.
  FIELD-SYMBOLS: <spara> TYPE rsparams.

  CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
    EXPORTING
      curr_report     = ls_detail-repid
    TABLES
      selection_table = lt_rsparams.

  LOOP AT lt_rsparams ASSIGNING <spara>.

    CASE <spara>-selname.
      WHEN 'ALCUR'.
        ls_selkrit-structure = 'T000F'.
        ls_selkrit-field     = 'XALHW'.
      WHEN 'ARCH_SEL'.
        ls_selkrit-structure = 'ARCH_USR'.
        ls_selkrit-field     = 'READARCSYS'.

      WHEN 'BR_BUKRS'.
        ls_selkrit-structure = 'BKPF'.
        ls_selkrit-field     = 'BUKRS'.
      WHEN 'BR_BELNR'.
        ls_selkrit-structure = 'BKPF'.
        ls_selkrit-field     = 'BELNR'.
      WHEN 'BR_GJAHR'.
        ls_selkrit-structure = 'BKPF'.
        ls_selkrit-field     = 'GJAHR'.
      WHEN 'BR_BUDAT'.
        ls_selkrit-structure = 'BKPF'.
        ls_selkrit-field     = 'BUDAT'.
      WHEN 'BR_XBLNR'.
        ls_selkrit-structure = 'BKPF'.
        ls_selkrit-field     = 'XBLNR'.

      WHEN 'PAR_XSTW'.
        ls_selkrit-structure = 'RFPDO2'.
        ls_selkrit-field     = 'UMSVXSTW'.
      WHEN 'SEL_LSTM'.
        ls_selkrit-structure = 'BSET'.
        ls_selkrit-field     = 'LSTML'.
      WHEN 'SEL_TAXC'.
        ls_selkrit-structure = 'BSET'.
        ls_selkrit-field     = 'TAX_COUNTRY'.
      WHEN 'SEL_UKRS'.
        ls_selkrit-structure = 'T007F'.
        ls_selkrit-field     = 'UMKRS'.
      WHEN 'SEL_MONA'.
        ls_selkrit-structure = 'BKPF'.
        ls_selkrit-field     = 'MONAT'.
      WHEN 'SEL_CPUD'.
        ls_selkrit-structure = 'BKPF'.
        ls_selkrit-field     = 'CPUDT'.
      WHEN 'SEL_BLDT'.
        ls_selkrit-structure = 'BKPF'.
        ls_selkrit-field     = 'BLDAT'.
      WHEN 'SEL_VTDT'.
        ls_selkrit-structure = 'BKPF'.
        ls_selkrit-field     = 'VATDATE'.
      WHEN 'SEL_MWKZ'.
        ls_selkrit-structure = 'BSET'.
        ls_selkrit-field     = 'MWSKZ'.
      WHEN 'SEL_KTOS'.
        ls_selkrit-structure = 'BSET'.
        ls_selkrit-field     = 'KTOSL'.
      WHEN 'SEL_UMSK'.
        ls_selkrit-structure = 'BSEG'.
        ls_selkrit-field     = 'UMSKZ'.
      WHEN 'SEL_BUPL'.
        ls_selkrit-structure = 'BSEG'.
        ls_selkrit-field     = 'BUPLA'.
      WHEN 'SKONTO'.
        ls_selkrit-structure = 'BSET'.
        ls_selkrit-field     = 'HKONT'.

      WHEN 'PAR_XSAU'.
        ls_selkrit-structure = 'RFPDO1'.
        ls_selkrit-field     = 'UMSVXARU'. "U = Umsatzsteuer
      WHEN 'PAR_XSVO'.
        ls_selkrit-structure = 'RFPDO1'.
        ls_selkrit-field     = 'UMSVXARV'. "V = Vorsteuer
      WHEN 'PAR_DEF'.
        ls_selkrit-structure = 'RFPDO1'.
        ls_selkrit-field     = 'TAXDEFER'.
      WHEN 'PAR_MOSS'.
        ls_selkrit-structure = 'RFPDO1'.
        ls_selkrit-field     = 'SEL_MOSS'.

      WHEN 'PAR_BINP'."create batch input session
        ls_selkrit-structure = 'RFPDO'.
        ls_selkrit-field     = 'UMSVBAIP'.
      WHEN 'PAR_BINA'."name of batch input session
        ls_selkrit-structure = 'RFPDO'.
        ls_selkrit-field     = 'ALLGBINA'.

      WHEN 'PAR_BSUD'."update run BSET-STMDT
        ls_selkrit-structure = 'RFPDO2'.
        ls_selkrit-field     = 'UMSVBSUD'.
      WHEN 'PAR_BUPL'. "test run BSET-STMDT
        ls_selkrit-structure = 'RFPDO2'.
        ls_selkrit-field     = 'UMSVBUPL'.

      WHEN 'PARPEUVA'. "electronic -> FOTV
        ls_selkrit-structure = 'RFPDO2'.
        ls_selkrit-field     = 'UMSVEUVA'.
      WHEN 'PARPCORR'. "correction electronic -> FOTV
        ls_selkrit-structure = 'RFPDO2'.
        ls_selkrit-field     = 'UMSVCORR'.

      WHEN 'PAR_XDTA'. "generate DTA
        ls_selkrit-structure = 'RFPDO2'.
        ls_selkrit-field     = 'UMSVXDTA'.

      WHEN 'PAR_UDTR'. "Tax document numbering
        ls_selkrit-structure = 'RFPDO2'.
        ls_selkrit-field     = 'UMSVTRUD'.

      WHEN OTHERS.
        CONTINUE.
    ENDCASE.

    CHECK <spara>-low <> space OR <spara>-high <> space. "something entered
    ls_selkrit-low       = <spara>-low.
    IF <spara>-kind = 'S'.
      ls_selkrit-sign      = <spara>-sign.
      ls_selkrit-optio     = <spara>-option.
      ls_selkrit-high      = <spara>-high.
    ELSE.
      CLEAR ls_selkrit-high.
      ls_selkrit-sign      = 'I'.
      ls_selkrit-optio     = 'EQ'.
    ENDIF.

    APPEND ls_selkrit TO ct_selkrit .
  ENDLOOP.

* Special Logic: Keep Batch-Input related info only if we create session
  READ TABLE ct_selkrit TRANSPORTING NO FIELDS WITH KEY
   structure = 'RFPDO'
   field     = 'UMSVBAIP'
   low       = 'X'.
  IF sy-subrc <> 0.
    DELETE ct_selkrit WHERE
     structure = 'RFPDO' AND field = 'ALLGBINA'.
  ENDIF.

ENDFORM. "FILL_SCMA_SELKRIT "2768541
*&---------------------------------------------------------------------*
*&      Form  SCMA_CLOSE "2768541
*&---------------------------------------------------------------------*
FORM scma_close.

  CHECK par_avpn = space. "do not record change of Display-Variants
* Tell workflow to stop or to go on
  CLEAR ls_scma_event.
  IF ld_aplstat = '4' OR ld_aplstat = 'A'.
    ls_scma_event-wf_event = cs_wf_events-error.
  ELSE.
    ls_scma_event-wf_event = cs_wf_events-finished.
  ENDIF.
  ls_scma_event-wf_witem = wf_witem.
  ls_scma_event-wf_okey  = wf_okey.

  CALL FUNCTION 'KPEP_MONI_CLOSE_RECORD'
    EXPORTING
      ls_key        = gs_key
      ls_scma_event = ls_scma_event
    CHANGING
      ld_aplstat    = ld_aplstat
    EXCEPTIONS
      OTHERS        = 0.

  COMMIT WORK.

ENDFORM.  "SCMA_CLOSE "2768541
*&---------------------------------------------------------------------*
*&      Form  SCMA_INIT "2768541
*&---------------------------------------------------------------------*
*       For Schedule Manager SCMA / Financial Closing Cockpit
*----------------------------------------------------------------------*
FORM scma_init .

  CHECK par_avpn = space. "do not record change of Display-Variants
  CLEAR: lt_selkrit[], lt_selkrit, ls_detail, ls_witem.

  ls_detail-application = 'FI-GL'.
  ls_detail-repid       = sy-repid.
  IF par_binp = space AND par_bsud = space AND par_umsv = space
    AND parpeuva = space AND par_xdta = space AND par_udtr = space.
    ls_detail-testflag    = 'X'.
  ENDIF.

  ls_witem-wf_witem     = wf_witem.
  ls_witem-wf_wlist     = wf_wlist.

  PERFORM fill_scma_selkrit TABLES lt_selkrit.

  CALL FUNCTION 'KPEP_MONI_INIT_RECORD'
    EXPORTING
      ls_detail  = ls_detail
      ls_witem   = ls_witem
    IMPORTING
      ls_key     = gs_key
    TABLES
      lt_selkrit = lt_selkrit.

  COMMIT WORK.

ENDFORM. "SCMA_INIT "2768541

AT SELECTION-SCREEN ON par_trid.                            "899205
  par_dmea = parpdmea.                                      "931482
  PERFORM check_dmee_button.                                "899205
  parpdmea = par_dmea.                                      "931482


*----------------------------------------------------------------------*
* PAI für das Selektionsdynpro                                         *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  check_jva_active
*&---------------------------------------------------------------------*
*       Check if the joint venture accounting is active
*----------------------------------------------------------------------*
*      <--P_JVA_ACTIVE  'X' = JVA is active
*----------------------------------------------------------------------*
FORM check_jva_active
     USING p_bukrs TYPE tt_range_bukrs
     CHANGING p_jva_active TYPE xfeld.

  TYPES: BEGIN OF ty_bukrs,
           bukrs TYPE bukrs,
         END OF ty_bukrs.
  DATA: lt_bukrs TYPE STANDARD TABLE OF ty_bukrs.

  CLEAR p_jva_active.

  SELECT bukrs FROM t001 INTO TABLE lt_bukrs WHERE bukrs IN p_bukrs.
  LOOP AT lt_bukrs INTO DATA(ls_bukrs).
    CALL FUNCTION 'JV_BUKRS_ACTIVE'
      EXPORTING
        bukrs  = ls_bukrs-bukrs
      IMPORTING
        active = p_jva_active.
    IF p_jva_active = abap_true.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  check_jva_active
*&---------------------------------------------------------------------*
*       Check if the joint venture accounting
*       is active for a company code
*----------------------------------------------------------------------*
*      <--P_JVA_ACTIVE  'X' = JVA is active
*----------------------------------------------------------------------*
FORM check_jva_active_for_bukrs
     USING p_bukrs TYPE bukrs
     CHANGING p_jva_active TYPE xfeld.
  CLEAR p_jva_active.
  IF par_xjvs = abap_true.
    CALL FUNCTION 'JV_BUKRS_ACTIVE'
      EXPORTING
        bukrs  = p_bukrs
      IMPORTING
        active = p_jva_active.
  ENDIF.
ENDFORM.
*----------------------------------------------------------------------*
* PAI für das Selektionsdynpro                                         *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  check_tax_audit                                  "925217
*&---------------------------------------------------------------------*
*       Check if the current user is a tax auditor
*       According to German law tax auditors must be granted
*       system access.
*       If the user is tax auditor
*       - access is restricted to a certain fiscal years
*         (this is handled by the logical database BRF)
*       - update functions are turned off
*       - selection parameters are written to an action log.
*         (this is handled by the logical database BRF)
*----------------------------------------------------------------------*
*      <--P_TAX_AUDITOR  'X' = user is a tax autitor
*----------------------------------------------------------------------*
FORM check_tax_audit
     CHANGING p_tax_auditor TYPE xfeld.                     "925217

  CALL FUNCTION 'CA_USER_EXISTS'
    EXPORTING
      i_user       = sy-uname
    EXCEPTIONS
      user_missing = 1
      OTHERS       = 2.

  IF sy-subrc = 0.
    p_tax_auditor = 'X'.
  ELSEIF sy-subrc = 1.
    CLEAR p_tax_auditor.
  ELSE.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " check_tax_audit                  "925217
*&---------------------------------------------------------------------*
*&      Form  tax_audit_clear                                  "925217
*&---------------------------------------------------------------------*
*       If the user is tax auditor update functions are turned off
*       Here the parameters are explicitly turned off because they
*       may be active due to selection of a report variant.
*       New update parameters should be included here.
*----------------------------------------------------------------------*
FORM tax_audit_clear.                                       "925217

* batch input parameters (block 2)
  CLEAR:
        par_binp,                     "Batch-Input gewünscht
        par_blar,                     "Belegart für BI
        par_bdat,                     "Buchungsdatum für BI
        par_mona,                     "Periode für BI
        par_zkto,                     "Abweichend. Zahllastkonto
        par_fdat,                     "Fälligkeitsdatum für Zahllast
        par_bina,                     "Name der BI-Mappe
        par_sofa,                     "Mappe sofort abspielen
        par_adat,                     "Datum: Abspielen BI
        par_zeit.                     "Uhrzeit: Abspielen BI

* output options
  CLEAR par_xml.                      "Ausgabe im XML-Format

* posting parameters     (block 5)
  par_kukp = 'X'.                     "Belege nicht aktualieren
  par_bsud = space.                   "Belege aktualisieren: Echtlauf
  par_bupl = space.                   "Belege aktual.: Testlauf
  CLEAR:
        par_euva,                     "Meldedaten erzeugen
        par_corr,                     "Berichtigte Voranmeldung
        par_dyea,                     "Meldejahr
        par_dper,                     "Meldeperiode

        par_caos,                     "No BSET compress
        par_umsv,                     "Formulardruck vorbereiten
        par_laud,                     "Laufdatum des Reports
        par_laui,                     "Zusätzl. Laufidentifikation

        par_xdta,                     "Create DTA File
        par_trty,                     "DME tree type
        par_trid,                     "DME Tree ID
        par_dmea,                     "DME additional parameters
        par_tems,                     "Temse Name
        par_file,                     "File Name

        par_udtr,                     "Update Table TRVOR
        par_reid,
        par_snou,                     "Starting Number Output
        par_snin.                     "Starting Number Input

ENDFORM.                    " tax_audit_clear                  "925217

"Optimization
*&---------------------------------------------------------------------*
*&      Form  process_result
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->C          text
*----------------------------------------------------------------------*
FORM process_result.
**  Start note 2157141
  IF 1 = 1.
    PERFORM process_result2.
    RETURN.
  ENDIF.
** End note 2157141
  DATA:
    lt_umsv00_bseg_bset  TYPE STANDARD TABLE OF ty_umsv00_bseg_bset,
    lv_exit              TYPE abap_bool,
    lv_index             TYPE i,
    lt_docs_by_belnr     LIKE lt_umsv00_bseg_bset,
    lt_tmp_docs_by_belnr LIKE lt_umsv00_bseg_bset,
    lv_bukrs             TYPE bukrs,
    lv_belnr             TYPE belnr_d,
    lv_gjahr             TYPE gjahr,
    lv_failed_bkpf       TYPE abap_bool,
    lv_failed_bseg       TYPE abap_bool,
    lv_reject            TYPE abap_bool,
    lo_ldb_brf           TYPE REF TO cl_fin_ldb_brf,
    lt_bkpf_list         TYPE STANDARD TABLE OF rsfs_struc,
    lt_bseg_list         TYPE STANDARD TABLE OF rsfs_struc,
    lt_bkpf_fields       TYPE if_fin_selection_types=>tt_selection_fields,
    lv_column            TYPE string,
    lv_column_sql        TYPE string,
    lv_column_list       TYPE string,
    lv_table             TYPE string VALUE 'bkpf',
    lv_join              TYPE string,
    lt_trange            TYPE rsds_trange,
    lt_where             TYPE rsds_where_tab,
    lt_twhere            TYPE rsds_twhere,
    c                    TYPE cursor.


  FIELD-SYMBOLS:
    <f_bseg_bset>        TYPE ty_umsv00_bseg_bset,
    <f_bseg_bset_line>   TYPE ty_umsv00_bseg_bset,
    <fs_bkpf_fields>     TYPE rsfs_struc,
    <ls_tab_field_range> TYPE rsds_range,
    <ls_field_range>     TYPE rsds_frange,
    <ls_tab_where>       TYPE rsds_where.


  CREATE OBJECT lo_ldb_brf
    EXPORTING
      iv_join        = abap_true
      it_range_bukrs = br_bukrs[]
      it_range_blart = br_blart[]
      it_range_gjahr = br_gjahr[]
      it_range_rldnr = br_rldnr[]
      it_range_ldgrp = br_ldgrp[]
      it_bkpf_list   = lt_bkpf_list
      it_bseg_list   = lt_bseg_list.

*   APPEND LINES OF lo_ldb_brf->gt_bkpf_fields TO lt_bkpf_fields.                                    "1980423
*                                                                                                    "1980423
*    TRY.                                                                                            "1980423
*                                                                                                    "1980423
*        LOOP AT lt_bkpf_fields ASSIGNING <fs_bkpf_fields>.                                          "1980423
*          lv_column = <fs_bkpf_fields>-line.                                                        "1980423
*          lv_column = cl_abap_dyn_prg=>check_column_name( lv_column ).                              "1980423
*          CONCATENATE lv_column_list lv_column '' INTO lv_column_list SEPARATED BY space.           "1980423
*        ENDLOOP.                                                                                    "1980423
*                                                                                                    "1980423
*      CATCH cx_abap_invalid_name.                                                                   "1980423
*        RETURN.                                                                                     "1980423
*    ENDTRY.                                                                                         "1980423


  CONCATENATE 'bkpf~bktxt bkpf~xmwst bkpf~xblnr bkpf~kursf bkpf~xblnr_alt bkpf~vatdate bkpf~monat bkpf~awtyp bkpf~awkey bkpf~awsys' "1980423  "#EC NOTEXT
  'bkpf~stblg bkpf~stjah bkpf~tcode bkpf~stgrd bkpf~numpg bkpf~xref1_hd bkpf~bukrs bkpf~belnr bkpf~gjahr bkpf~blart bkpf~budat bkpf~bldat bkpf~waers'  "1980423  "#EC NOTEXT
  'bset~buzei bset~mwskz bset~hkont bset~txgrp bset~shkzg'                                                                    "1980423  "#EC NOTEXT
  'bset~egbld bset~eglld'                                                                                                     "2101269  "#EC NOTEXT
  'bset~hwbas bset~fwbas bset~hwste bset~fwste bset~ktosl bset~stceg bset~kschl bset~stmdt bset~stmti bset~kbetr bset~lstml'  "1980423  "#EC NOTEXT
  'bset~lwste bset~bupla bset~taxps bset~lwbas'                                                                    "1980423  "#EC NOTEXT
  'bseg~buzei AS buzei_g bseg~augdt bseg~koart bseg~umskz bseg~umsks bseg~mwskz AS mwskz_g' "#EC NOTEXT
  'bseg~zuonr bseg~xref1 bseg~xref2 bseg~xref3 bseg~kidno bseg~xnegp bseg~mwart bseg~xauto bseg~txgrp AS txgrp_g bseg~hkont AS hkont_g' "#EC NOTEXT
  'bseg~shkzg AS shkzg_g'                                                                                                     "1868787  "#EC_NOTEXT
  'bseg~j_1tpbupl'                                                                                                            "2097858  "#EC_NOTEXT
  'bseg~stceg AS stceg_g bseg~lifnr bseg~kunnr bseg~dmbtr bseg~gsber bseg~wrbtr' INTO lv_column_list SEPARATED BY space.      "1980423  "#EC NOTEXT

  CONCATENATE '( ( (' lv_table ' AS bkpf '                  "#EC NOTEXT
       'INNER JOIN bset as bset ON bkpf~bukrs = bset~bukrs AND bkpf~belnr = bset~belnr AND bkpf~gjahr = bset~gjahr )' "#EC NOTEXT
       'INNER JOIN bseg as bseg ON bkpf~bukrs = bseg~bukrs AND bkpf~belnr = bseg~belnr AND bkpf~gjahr = bseg~gjahr ) )' "#EC NOTEXT
       INTO lv_join SEPARATED BY space.



*  "get free selections from report                                                   "1980423
*  CALL FUNCTION 'RS_REFRESH_FROM_DYNAMICAL_SEL'                                      "1980423
*    EXPORTING                                                                        "1980423
*      curr_report        = sy-repid                                                  "1980423
*      mode_write_or_move = 'M'                                                       "1980423
*    IMPORTING                                                                        "1980423
*      p_trange           = lt_trange                                                 "1980423
*    EXCEPTIONS                                                                       "1980423
*      OTHERS             = 1.                                                        "1980423
*                                                                                     "1980423
**  everything is ok and there is dynamic selection                                   "1980423
*   IF sy-subrc = 0 AND lt_trange IS NOT INITIAL.                                     "1980423
*        LOOP AT lt_trange ASSIGNING <ls_tab_field_range>.                            "1980423
*           LOOP AT <ls_tab_field_range>-frange_t ASSIGNING <ls_field_range>.         "1980423
*             CONCATENATE                                                             "1980423
*               <ls_tab_field_range>-tablename                                        "1980423
*               '~'                                                                   "1980423
*               <ls_field_range>-fieldname                                            "1980423
*             INTO                                                                    "1980423
*               <ls_field_range>-fieldname.                                           "1980423
*           ENDLOOP.                                                                  "1980423
*         ENDLOOP.                                                                    "1980423
*                                                                                     "1980423
**      convert ranges to WHERE condition                                             "1980423
*        CALL FUNCTION 'FREE_SELECTIONS_RANGE_2_WHERE'                                "1980423
*          EXPORTING                                                                  "1980423
*            field_ranges  = lt_trange                                                "1980423
*          IMPORTING                                                                  "1980423
*            where_clauses = lt_twhere.                                               "1980423
*                                                                                     "1980423
**      prepare WHERE clause for SELECT statement                                     "1980423
*          LOOP AT lt_twhere ASSIGNING <ls_tab_where>.                                "1980423
*            APPEND LINES OF <ls_tab_where>-where_tab TO lt_where.                    "1980423
*          ENDLOOP.                                                                   "1980423
*    ENDIF.                                                                           "1980423

  OPEN CURSOR c FOR
  SELECT (lv_column_list)
   FROM (lv_join)
     WHERE
         bkpf~bukrs IN lo_ldb_brf->gt_range_bukrs            " modified by authority check bukrs
         AND   bkpf~blart IN lo_ldb_brf->gt_range_blart      "1980423          " modified by authority check blart
         AND   bkpf~budat IN br_budat[]                     "1980423
         AND   bkpf~belnr IN br_belnr[]
         AND   bkpf~gjahr IN br_gjahr[]
         AND   bkpf~bstat IN gr_bstat[]                     "1980423
         AND   bkpf~awtyp IN br_awtyp[]                     "1980423
         AND   bkpf~awkey IN br_awkey[]                     "1980423
         AND   bkpf~awsys IN br_awsys[]                     "1980423
         AND   bkpf~cpudt IN br_cpudt[]                     "1980423
         AND   bkpf~xblnr IN br_xblnr[]                     "1980423
         AND   bkpf~bldat IN br_bldat[]                     "1980423
         AND   bkpf~usnam IN br_usnam[]                     "1980423
         AND   ( bkpf~ldgrp IN lo_ldb_brf->gt_range_ldgrp OR bkpf~ldgrp IS NULL )   "1980423   " modified by NewGL Customizing
         AND   ( bkpf~rldnr IN lo_ldb_brf->gt_range_rldnr OR bkpf~rldnr IS NULL )   "1980423   " modified by NewGL Customizing
         AND   ( bkpf~vatdate IN br_vatdt[] OR bkpf~vatdate IS NULL ) "1023317      "1980423
         AND   (lo_ldb_brf->gt_where)                    " free selections          "1980423
        " AND   gsber IN lo_ldb_brf->gt_range_gsber                                 "1980423
         AND   bkpf~monat IN sel_mona[]
      ORDER BY bkpf~bukrs bkpf~gjahr bkpf~belnr.

  WHILE lv_exit = abap_false.
    FETCH NEXT CURSOR c INTO CORRESPONDING FIELDS OF TABLE lt_umsv00_bseg_bset
                       PACKAGE SIZE 10000.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    LOOP AT lt_umsv00_bseg_bset ASSIGNING <f_bseg_bset>.

      " first doc
      IF lv_bukrs IS INITIAL AND lv_gjahr IS INITIAL AND lv_belnr IS INITIAL.
        lv_bukrs = <f_bseg_bset>-bukrs.
        lv_gjahr = <f_bseg_bset>-gjahr.
        lv_belnr = <f_bseg_bset>-belnr.
      ENDIF.

      " the same doc as previous
      IF <f_bseg_bset>-bukrs = lv_bukrs AND <f_bseg_bset>-gjahr = lv_gjahr AND <f_bseg_bset>-belnr = lv_belnr.
        APPEND <f_bseg_bset> TO lt_docs_by_belnr.
      ELSE.
        "moving to next doc, process the current doc
        lt_tmp_docs_by_belnr = lt_docs_by_belnr.
        SORT lt_tmp_docs_by_belnr BY buzei_g.
        DELETE ADJACENT DUPLICATES FROM lt_tmp_docs_by_belnr COMPARING buzei_g.
        LOOP AT lt_tmp_docs_by_belnr ASSIGNING <f_bseg_bset_line>.
          AT FIRST.
            MOVE-CORRESPONDING <f_bseg_bset_line> TO bkpf.
            "Authority Check
            lo_ldb_brf->bkpf( IMPORTING ev_failed = lv_failed_bkpf
                           CHANGING cs_bkpf = bkpf ).
            CHECK lv_failed_bkpf = abap_false.
            PERFORM t001_read USING bkpf-bukrs.
            PERFORM process_bkpf
                    CHANGING lv_failed_bkpf.                "2103962
            CHECK lv_failed_bkpf = abap_false.              "2103962
          ENDAT.
          IF lv_failed_bkpf = abap_true.                    "2103962
            EXIT.                                           "2103962
          ENDIF.                                            "2103962
          MOVE-CORRESPONDING <f_bseg_bset_line> TO bseg.
          bseg-buzei = <f_bseg_bset_line>-buzei_g.
          bseg-mwskz = <f_bseg_bset_line>-mwskz_g.
          bseg-hkont = <f_bseg_bset_line>-hkont_g.
          bseg-shkzg = <f_bseg_bset_line>-shkzg_g.          "1868787
          bseg-txgrp = <f_bseg_bset_line>-txgrp_g.
          bseg-stceg = <f_bseg_bset_line>-stceg_g.
          " Authority Check
          lo_ldb_brf->bseg( EXPORTING is_bkpf   = bkpf
                        IMPORTING ev_failed = lv_failed_bseg
                        CHANGING  cs_bseg   = bseg ).
          CHECK lv_failed_bseg  = abap_false.
          MOVE-CORRESPONDING bseg TO bsegh.
          PERFORM got_bsega(sapbsega).
          IF alcur EQ 'X'.
            PERFORM convert_alt        "euro
            USING 'BSEG' bkpf-waers.
          ENDIF.

          PERFORM process_bseg.
        ENDLOOP.
        lv_reject = abap_false.                             "2103962
        IF lv_failed_bkpf = abap_false.
          lt_tmp_docs_by_belnr = lt_docs_by_belnr.
          SORT lt_tmp_docs_by_belnr BY buzei.               "1980423
          DELETE ADJACENT DUPLICATES FROM lt_tmp_docs_by_belnr COMPARING buzei. "1980423
          LOOP AT lt_tmp_docs_by_belnr ASSIGNING <f_bseg_bset_line>.
            MOVE-CORRESPONDING <f_bseg_bset_line> TO bset.
*            bset-buzei = <f_bseg_bset_line>-buzei_t.                                     "1980423
*            bset-mwskz = <f_bseg_bset_line>-mwskz_t.                                     "1980423
*            bset-hkont = <f_bseg_bset_line>-hkont_t.                                     "1980423
*            bset-txgrp = <f_bseg_bset_line>-txgrp_t.                                     "1980423
*            bset-stceg = <f_bseg_bset_line>-stceg_t.                                     "1980423
            IF alcur EQ 'X'.
              PERFORM convert_alt        "euro
              USING 'BSET' bkpf-waers.
            ENDIF.
            PERFORM process_bset CHANGING lv_reject.
            IF lv_reject = abap_true.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
        IF lv_reject = abap_true
          OR lv_failed_bkpf = abap_true.                    "2103962
          CLEAR lt_docs_by_belnr.
          APPEND <f_bseg_bset> TO lt_docs_by_belnr.
          lv_bukrs = <f_bseg_bset>-bukrs.
          lv_gjahr = <f_bseg_bset>-gjahr.
          lv_belnr = <f_bseg_bset>-belnr.
          CONTINUE.
        ENDIF.
        PERFORM process_bkpf_late.

        CLEAR lt_docs_by_belnr.
        APPEND <f_bseg_bset> TO lt_docs_by_belnr.
        lv_bukrs = <f_bseg_bset>-bukrs.
        lv_gjahr = <f_bseg_bset>-gjahr.
        lv_belnr = <f_bseg_bset>-belnr.
      ENDIF.
    ENDLOOP.
  ENDWHILE.

  " process last doc

  lt_tmp_docs_by_belnr = lt_docs_by_belnr.
  SORT lt_tmp_docs_by_belnr BY buzei_g.
  DELETE ADJACENT DUPLICATES FROM lt_tmp_docs_by_belnr COMPARING buzei_g.
  LOOP AT lt_tmp_docs_by_belnr ASSIGNING <f_bseg_bset_line>.
    AT FIRST.
      MOVE-CORRESPONDING <f_bseg_bset_line> TO bkpf.
      "Authority Check
      lo_ldb_brf->bkpf( IMPORTING ev_failed = lv_failed_bkpf
                     CHANGING cs_bkpf = bkpf ).
      CHECK lv_failed_bkpf = abap_false.
      PERFORM t001_read USING bkpf-bukrs.
      PERFORM process_bkpf
              CHANGING lv_failed_bkpf.                      "2103962
      CHECK lv_failed_bkpf = abap_false.                    "2103962
    ENDAT.
    IF lv_failed_bkpf = abap_true.                          "2103962
      EXIT.                                                 "2103962
    ENDIF.                                                  "2103962
    MOVE-CORRESPONDING <f_bseg_bset_line> TO bseg.
    bseg-buzei = <f_bseg_bset_line>-buzei_g.
    bseg-mwskz = <f_bseg_bset_line>-mwskz_g.
    bseg-hkont = <f_bseg_bset_line>-hkont_g.
    bseg-shkzg = <f_bseg_bset_line>-shkzg_g.                "1868787
    bseg-txgrp = <f_bseg_bset_line>-txgrp_g.
    bseg-stceg = <f_bseg_bset_line>-stceg_g.
    " Authority Check
    lo_ldb_brf->bseg( EXPORTING is_bkpf   = bkpf
                  IMPORTING ev_failed = lv_failed_bseg
                  CHANGING  cs_bseg   = bseg ).
    CHECK lv_failed_bseg  = abap_false.

    MOVE-CORRESPONDING bseg TO bsegh.
    PERFORM got_bsega(sapbsega).
    IF alcur EQ 'X'.
      PERFORM convert_alt        "euro
      USING 'BSEG' bkpf-waers.
    ENDIF.

    PERFORM process_bseg.
  ENDLOOP.
  lv_reject = abap_false.                                   "2103962
  IF lv_failed_bkpf = abap_false.
    lt_tmp_docs_by_belnr = lt_docs_by_belnr.
    SORT lt_tmp_docs_by_belnr BY buzei.                     "1980423
    DELETE ADJACENT DUPLICATES FROM lt_tmp_docs_by_belnr COMPARING buzei. "1980423
    LOOP AT lt_tmp_docs_by_belnr ASSIGNING <f_bseg_bset_line>.
      MOVE-CORRESPONDING <f_bseg_bset_line> TO bset.
*      bset-buzei = <f_bseg_bset_line>-buzei_t.                                        "1980423
*      bset-mwskz = <f_bseg_bset_line>-mwskz_t.                                        "1980423
*      bset-hkont = <f_bseg_bset_line>-hkont_t.                                        "1980423
*      bset-txgrp = <f_bseg_bset_line>-txgrp_t.                                        "1980423
*      bset-stceg = <f_bseg_bset_line>-stceg_t.                                        "1980423
      IF alcur EQ 'X'.
        PERFORM convert_alt        "euro
        USING 'BSET' bkpf-waers.
      ENDIF.
      PERFORM process_bset CHANGING lv_reject.
      IF lv_reject = abap_true.
        CLOSE CURSOR c.                                     "2103962
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lv_failed_bkpf = abap_false.                           "2103962
    PERFORM process_bkpf_late.
  ENDIF.                                                    "2103962

  CLOSE CURSOR c.

ENDFORM.                    "process_result

**** Start note 2157141
FORM process_result2.
  DATA:
    lv_exit        TYPE abap_bool,
    lv_index       TYPE i,
    lv_bukrs       TYPE bukrs,
    lv_belnr       TYPE belnr_d,
    lv_gjahr       TYPE gjahr,
    lv_failed_bkpf TYPE abap_bool,
    lv_failed_bseg TYPE abap_bool,
    lv_reject      TYPE abap_bool,
    lo_ldb_brf     TYPE REF TO cl_fin_ldb_brf,
    lt_bkpf_list   TYPE STANDARD TABLE OF rsfs_struc,
    lt_bseg_list   TYPE STANDARD TABLE OF rsfs_struc,
    lt_bkpf_fields TYPE if_fin_selection_types=>tt_selection_fields,
    lv_column      TYPE string,
    lv_column_list TYPE string,
    lv_table       TYPE string VALUE 'bkpf',
    lv_join        TYPE string,
    lt_trange      TYPE rsds_trange,
    lt_where       TYPE rsds_where_tab,
    lt_twhere      TYPE rsds_twhere,
    c              TYPE cursor.

  DATA: lv_rate_colums(25) VALUE 'bkpf~txkrs'.              "2616036
  FIELD-SYMBOLS: <c> TYPE any.

  ASSIGN COMPONENT 'CTXKRS' OF STRUCTURE bkpf TO <c>.       "2616036
  IF sy-subrc = 0.
    CONCATENATE lv_rate_colums 'bkpf~ctxkrs' INTO lv_rate_colums SEPARATED BY space.
  ENDIF.

  CREATE OBJECT lo_ldb_brf
    EXPORTING
      iv_join        = abap_true
      it_range_bukrs = br_bukrs[]
      it_range_blart = br_blart[]
      it_range_gjahr = br_gjahr[]
      it_range_rldnr = br_rldnr[]
      it_range_ldgrp = br_ldgrp[]
      it_bkpf_list   = lt_bkpf_list
      it_bseg_list   = lt_bseg_list.
*--->>> EOL-0083 24.04.2024
  PERFORM authority_check_gsber.
  IF lines( so_gsber ) = 0.
    ADD 1 TO gd_cnt_no_auth.
    RETURN.
  ENDIF.
*---<<<
  gr_auth_gsber = lo_ldb_brf->gt_range_gsber.               "2715311
  gr_auth_blart = lo_ldb_brf->gt_range_blart.               "2715311

  CONCATENATE 'bkpf~bktxt bkpf~xmwst bkpf~xblnr bkpf~kursf bkpf~xblnr_alt bkpf~vatdate bkpf~fulfilldate bkpf~monat bkpf~awtyp bkpf~awkey bkpf~awsys' "1980423  "#EC NOTEXT
'bkpf~reindat'                                                                                                   "2438600  "#EC NOTEXT
lv_rate_colums                                                                                                  "2616036  "#EC NOTEXT
'bkpf~stblg bkpf~stjah bkpf~tcode bkpf~stgrd bkpf~numpg bkpf~xref1_hd bkpf~bukrs bkpf~belnr bkpf~gjahr bkpf~blart bkpf~budat bkpf~bldat bkpf~waers'  "1980423  "#EC NOTEXT
'bset~buzei bset~tax_country bset~mwskz bset~hkont bset~txgrp bset~shkzg'                                                                    "1980423  "#EC NOTEXT
'bset~egbld bset~eglld'                                                                                                     "2101269  "#EC NOTEXT
'bset~hwbas bset~fwbas bset~hwste bset~fwste bset~ktosl bset~stceg bset~kschl bset~stmdt bset~stmti bset~kbetr bset~lstml'  "1980423  "#EC NOTEXT
'bset~lwste bset~bupla bset~taxps bset~lwbas'                                                                    "1980423  "#EC NOTEXT
'bset~txdat bset~txdat_from'

  INTO lv_column_list SEPARATED BY space.      "1980423  "#EC NOTEXT

  CONCATENATE '(' lv_table ' AS bkpf '                      "#EC NOTEXT
       'INNER JOIN bset as bset ON bkpf~bukrs = bset~bukrs AND bkpf~belnr = bset~belnr AND bkpf~gjahr = bset~gjahr )' "#EC NOTEXT
       INTO lv_join SEPARATED BY space.

  OPEN CURSOR c FOR
  SELECT (lv_column_list)
   FROM (lv_join)
     WHERE
         bkpf~bukrs IN lo_ldb_brf->gt_range_bukrs            " modified by authority check bukrs
***               AND   bkpf~blart IN lo_ldb_brf->gt_range_blart    "1980423 "2715311
                  AND   bkpf~blart IN br_blart[]            "2715311
         AND   bkpf~budat IN br_budat[]                     "1980423
         AND   bkpf~belnr IN br_belnr[]
         AND   bkpf~gjahr IN br_gjahr[]
         AND   bkpf~bstat IN gr_bstat[]                     "1980423
         AND   bkpf~awtyp IN br_awtyp[]                     "1980423
         AND   bkpf~awkey IN br_awkey[]                     "1980423
         AND   bkpf~awsys IN br_awsys[]                     "1980423
         AND   bkpf~cpudt IN br_cpudt[]                     "1980423
         AND   bkpf~xblnr IN br_xblnr[]                     "1980423
         AND   bkpf~bldat IN br_bldat[]                     "1980423
         AND   bkpf~usnam IN br_usnam[]                     "1980423
         AND   ( bkpf~ldgrp IN lo_ldb_brf->gt_range_ldgrp OR bkpf~ldgrp IS NULL )   "1980423   " modified by NewGL Customizing
         AND   ( bkpf~rldnr IN lo_ldb_brf->gt_range_rldnr OR bkpf~rldnr IS NULL )   "1980423   " modified by NewGL Customizing
         AND   ( bkpf~vatdate IN br_vatdt[] OR bkpf~vatdate IS NULL ) "1023317      "1980423
         AND   (lo_ldb_brf->gt_where)                    " free selections          "1980423
        " AND   gsber IN lo_ldb_brf->gt_range_gsber                                 "1980423
         AND   bkpf~monat IN sel_mona[]
      ORDER BY bkpf~bukrs bkpf~belnr bkpf~gjahr bset~buzei.

  TYPES:

  BEGIN OF ty_bkpf_bset.
  TYPES:
    bktxt       TYPE bktxt,
    xmwst       TYPE xmwst,
    xblnr       TYPE xblnr1,
    kursf       TYPE kursf,
    xblnr_alt   TYPE xblnr_alt,
    vatdate     TYPE vatdate,
    fulfilldate TYPE fot_fulfilldate,
    reindat     TYPE reindat,                               "2438600
    txkrs       TYPE txkrs_bkpf,                            "2616036
    ctxkrs      TYPE txkrs_bkpf,                            "2616036
    monat       TYPE monat,
    awtyp       TYPE awtyp,
    awkey       TYPE awkey,
    awsys       TYPE logsystem,
    stblg       TYPE stblg,
    stjah       TYPE stjah,
    tcode       TYPE tcode,
    stgrd       TYPE stgrd,
    numpg       TYPE j_1anopg,
    xref1_hd    TYPE xref1_hd,
    blart       TYPE blart,
    budat       TYPE budat,
    bldat       TYPE bldat,
    waers       TYPE waers,
    bukrs       TYPE bset-bukrs,
    belnr       TYPE  bset-belnr,
    gjahr       TYPE  bset-gjahr,
    buzei       TYPE  bset-buzei,
    tax_country TYPE bset-tax_country,
    mwskz       TYPE  bset-mwskz,
    txdat       TYPE  bset-txdat,
    txdat_from  TYPE bset-txdat_from,
    hkont       TYPE  bset-hkont,
    txgrp       TYPE  bset-txgrp,
    shkzg       TYPE  bset-shkzg,
    egbld       TYPE  bset-egbld,
    eglld       TYPE  bset-eglld,
    hwbas       TYPE  bset-hwbas,
    fwbas       TYPE  bset-fwbas,
    hwste       TYPE  bset-hwste,
    fwste       TYPE  bset-fwste,
    ktosl       TYPE  bset-ktosl,
    stceg       TYPE  bset-stceg,
    kschl       TYPE  bset-kschl,
    stmdt       TYPE  bset-stmdt,
    stmti       TYPE  bset-stmti,
    kbetr       TYPE  bset-kbetr,
    lstml       TYPE  bset-lstml,
    lwste       TYPE  bset-lwste,
    bupla       TYPE  bset-bupla,
    taxps       TYPE  bset-taxps,
    lwbas       TYPE  bset-lwbas.
*              INCLUDE STRUCTURE bset.
  TYPES END OF ty_bkpf_bset.

  TYPES:
  BEGIN OF ty_new_bseg.
  TYPES:
    augdt       TYPE augdt,
    umskz       TYPE umskz,
    umsks       TYPE umsks,
    tax_country TYPE fot_tax_country,
    mwskz       TYPE mwskz,
    txdat       TYPE txdat,
    txdat_from  TYPE fot_txdat_from,
    xnegp       TYPE xnegp,
    mwart       TYPE mwart,
    xauto       TYPE xauto,
    txgrp       TYPE txgrp,
    hkont       TYPE hkont,
    shkzg       TYPE shkzg,
    j_1tpbupl   TYPE bcode,
    stceg       TYPE stceg,
    lifnr       TYPE lifnr,
    kunnr       TYPE kunnr,
    dmbtr       TYPE dmbtr,
    gsber       TYPE gsber,
    wmwst       TYPE wmwst,
    mwsts       TYPE mwsts,
    wrbtr       TYPE wrbtr.
    INCLUDE STRUCTURE rfums_bseg .
  TYPES END OF ty_new_bseg.

  DATA:
    lt_bkpf_bset   TYPE STANDARD TABLE OF ty_bkpf_bset,
    lt_bkpf_unique TYPE STANDARD TABLE OF ty_bkpf_bset,

    lt_bseg        TYPE SORTED TABLE OF ty_new_bseg WITH UNIQUE KEY bukrs belnr gjahr buzei,
    lt_docs        LIKE lt_bkpf_bset.


  FIELD-SYMBOLS:
    <f_bseg>           TYPE ty_new_bseg,
    <f_bkpf_bset>      TYPE ty_bkpf_bset,
    <f_bkpf_bset_line> TYPE ty_bkpf_bset.

  DATA:
    lv_bseg_column_list TYPE string,
    lt_component_bseg   TYPE abap_component_tab,
    ls_component        TYPE abap_compdescr,
    lo_bseg_sdesc       TYPE REF TO cl_abap_structdescr.

  lo_bseg_sdesc ?= cl_abap_structdescr=>describe_by_name( EXPORTING p_name = 'ty_new_bseg' ).

  LOOP AT lo_bseg_sdesc->components INTO ls_component.
    CHECK ls_component-name IS NOT INITIAL.
    TRY.
        lv_column = cl_abap_dyn_prg=>check_column_name( ls_component-name ).
        CONCATENATE lv_bseg_column_list lv_column '' INTO lv_bseg_column_list SEPARATED BY space.
      CATCH cx_abap_invalid_name INTO DATA(lx_ex).
**                  Continue
    ENDTRY.
  ENDLOOP.

  WHILE lv_exit = abap_false.
    FETCH NEXT CURSOR c INTO CORRESPONDING FIELDS OF TABLE lt_bkpf_bset
                       PACKAGE SIZE 10000.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
*--->>> EOL-0083 24.04.2024
    TRY.
        CALL FUNCTION '/THKR/CHK_NEW_GL'
          EXPORTING
            it_gjahr   = br_gjahr[]
            it_belnr   = br_belnr[]
            it_bukrs   = lo_ldb_brf->gt_range_bukrs
            it_gsber   = so_gsber[]
            it_prctr   = so_prctr[]
            it_segment = so_segmt[]
            sel_ktos   = sel_ktos[]
          CHANGING
            ct_new_gl  = lt_bkpf_bset.
      CATCH cx_root.
    ENDTRY.
*---<<<

    lt_bkpf_unique = lt_bkpf_bset.
    INSERT LINES OF lt_docs INTO lt_bkpf_unique INDEX 1.
    DELETE ADJACENT DUPLICATES FROM lt_bkpf_unique COMPARING bukrs belnr gjahr.

    CLEAR lt_bseg.
    SELECT (lv_bseg_column_list) FROM bseg
             INTO CORRESPONDING FIELDS OF TABLE lt_bseg
             FOR ALL ENTRIES IN lt_bkpf_unique
             WHERE bukrs = lt_bkpf_unique-bukrs
               AND belnr = lt_bkpf_unique-belnr
               AND gjahr = lt_bkpf_unique-gjahr
*--->>> EOL-0083 24.04.2024
               AND gsber IN so_gsber
               AND prctr IN so_prctr
*---<<<
               ORDER BY PRIMARY KEY  .

    LOOP AT lt_bkpf_bset ASSIGNING <f_bkpf_bset>.
      IF lv_bukrs IS INITIAL AND lv_gjahr IS INITIAL AND lv_belnr IS INITIAL.
        lv_bukrs = <f_bkpf_bset>-bukrs.
        lv_gjahr = <f_bkpf_bset>-gjahr.
        lv_belnr = <f_bkpf_bset>-belnr.
      ENDIF.

      IF <f_bkpf_bset>-bukrs = lv_bukrs AND <f_bkpf_bset>-gjahr = lv_gjahr AND <f_bkpf_bset>-belnr = lv_belnr.
        APPEND <f_bkpf_bset> TO lt_docs.
      ELSE.
        READ TABLE lt_docs INDEX 1 ASSIGNING <f_bkpf_bset_line>.
        MOVE-CORRESPONDING <f_bkpf_bset_line> TO bkpf.
        lo_ldb_brf->bkpf( IMPORTING ev_failed = lv_failed_bkpf
                         CHANGING cs_bkpf = bkpf ).
        IF lv_failed_bkpf = abap_true.
          CLEAR lt_docs.
          APPEND <f_bkpf_bset> TO lt_docs.
          lv_bukrs = <f_bkpf_bset>-bukrs.
          lv_gjahr = <f_bkpf_bset>-gjahr.
          lv_belnr = <f_bkpf_bset>-belnr.
          CONTINUE.
        ENDIF.
        PERFORM t001_read USING bkpf-bukrs.
        PERFORM process_bkpf
                CHANGING lv_failed_bkpf.
        IF lv_failed_bkpf = abap_true.
          CLEAR lt_docs.
          APPEND <f_bkpf_bset> TO lt_docs.
          lv_bukrs = <f_bkpf_bset>-bukrs.
          lv_gjahr = <f_bkpf_bset>-gjahr.
          lv_belnr = <f_bkpf_bset>-belnr.
          CONTINUE.
        ENDIF.
        LOOP AT lt_bseg ASSIGNING <f_bseg> WHERE bukrs = <f_bkpf_bset_line>-bukrs AND
          belnr = <f_bkpf_bset_line>-belnr AND gjahr = <f_bkpf_bset_line>-gjahr.

          MOVE-CORRESPONDING <f_bseg> TO bseg.
          lo_ldb_brf->bseg( EXPORTING is_bkpf   = bkpf
                        IMPORTING ev_failed = lv_failed_bseg
                        CHANGING  cs_bseg   = bseg ).
          CHECK lv_failed_bseg  = abap_false.
          MOVE-CORRESPONDING bseg TO bsegh.
          PERFORM got_bsega(sapbsega).
          IF alcur EQ 'X'.
            PERFORM convert_alt        "euro
            USING 'BSEG' bkpf-waers.
          ENDIF.

          PERFORM process_bseg.

        ENDLOOP.

        lv_reject = abap_false.                             "2103962
        IF lv_failed_bkpf = abap_false.

          LOOP AT lt_docs ASSIGNING <f_bkpf_bset_line>.
            MOVE-CORRESPONDING <f_bkpf_bset_line> TO bset.
            IF alcur EQ 'X'.
              PERFORM convert_alt        "euro
              USING 'BSET' bkpf-waers.
            ENDIF.
            PERFORM process_bset CHANGING lv_reject.
            IF lv_reject = abap_true.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
        IF lv_reject = abap_true.
          CLEAR lt_docs.
          APPEND <f_bkpf_bset> TO lt_docs.
          lv_bukrs = <f_bkpf_bset>-bukrs.
          lv_gjahr = <f_bkpf_bset>-gjahr.
          lv_belnr = <f_bkpf_bset>-belnr.
          CONTINUE.
        ENDIF.
        PERFORM process_bkpf_late.

        CLEAR lt_docs.
        APPEND <f_bkpf_bset> TO lt_docs.
        lv_bukrs = <f_bkpf_bset>-bukrs.
        lv_gjahr = <f_bkpf_bset>-gjahr.
        lv_belnr = <f_bkpf_bset>-belnr.

      ENDIF.

    ENDLOOP.

  ENDWHILE.
*          ** Process last document
  IF lt_docs IS INITIAL.
    CLOSE CURSOR c.
    RETURN.
  ENDIF.
  READ TABLE lt_docs INDEX 1 ASSIGNING <f_bkpf_bset_line>.
  MOVE-CORRESPONDING <f_bkpf_bset_line> TO bkpf.
  lo_ldb_brf->bkpf( IMPORTING ev_failed = lv_failed_bkpf
                   CHANGING cs_bkpf = bkpf ).
  IF lv_failed_bkpf = abap_true.
    CLOSE CURSOR c.
    RETURN.
  ENDIF.

  PERFORM t001_read USING bkpf-bukrs.
  PERFORM process_bkpf
          CHANGING lv_failed_bkpf.                          "2103962
  IF lv_failed_bkpf = abap_true.
    CLOSE CURSOR c.
    RETURN.
  ENDIF.

  LOOP AT lt_bseg ASSIGNING <f_bseg> WHERE bukrs = <f_bkpf_bset_line>-bukrs AND
               belnr = <f_bkpf_bset_line>-belnr AND gjahr = <f_bkpf_bset_line>-gjahr.

    MOVE-CORRESPONDING <f_bseg> TO bseg.
    lo_ldb_brf->bseg( EXPORTING is_bkpf   = bkpf
                  IMPORTING ev_failed = lv_failed_bseg
                  CHANGING  cs_bseg   = bseg ).
    CHECK lv_failed_bseg  = abap_false.
    MOVE-CORRESPONDING bseg TO bsegh.
    PERFORM got_bsega(sapbsega).
    IF alcur EQ 'X'.
      PERFORM convert_alt        "euro
      USING 'BSEG' bkpf-waers.
    ENDIF.

    PERFORM process_bseg.

  ENDLOOP.

  IF lv_failed_bkpf = abap_false.

    LOOP AT lt_docs ASSIGNING <f_bkpf_bset_line>.
      MOVE-CORRESPONDING <f_bkpf_bset_line> TO bset.
      IF alcur EQ 'X'.
        PERFORM convert_alt        "euro
        USING 'BSET' bkpf-waers.
      ENDIF.
      PERFORM process_bset CHANGING lv_reject.
      IF lv_reject = abap_true.
        CLOSE CURSOR c.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  PERFORM process_bkpf_late.

  CLOSE CURSOR c.

ENDFORM.
**** End note 2157141

*&---------------------------------------------------------------------*
*&      Form  READ_TEURB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DD_BUKRS   text
*----------------------------------------------------------------------*
FORM read_teurb TABLES dd_bukrs.
  DATA: nobukrs    TYPE p,
        save_waers LIKE t001-waers.

  nobukrs = 0.
  IF flg_xwia EQ 'X' AND par_xstw EQ 'X'.                   "2475335
    IF flg_txa_active = abap_true.
      g_land = sel_taxc-low.
    ELSE.
      g_land = sel_lstm-low.                                "2475335
    ENDIF.
  ELSE.                                                     "2475335
    g_land = space.                                         "2475335
  ENDIF.                                                    "2475335

  SELECT * FROM t001 WHERE bukrs IN dd_bukrs.
    nobukrs = nobukrs + 1.
    CALL FUNCTION 'CHECK_PLANTS_ABROAD_ACTIVE'
      EXPORTING
        i_bukrs       = t001-bukrs
      IMPORTING
        e_fi_isactive = xwia.
*   IF xwia IS INITIAL.                                         "2475335
*     PERFORM append_int_teurb USING nobukrs save_waers space.  "2475335
*   ELSE.                                                       "2475335
    PERFORM append_int_teurb USING nobukrs save_waers g_land.
*   ENDIF.                                                      "2475335
  ENDSELECT.
  SORT int_teurb.
ENDFORM.                    "READ_TEURB


*&---------------------------------------------------------------------*
*&      Form  APPEND_INT_TEURB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->NOBUKRS    text
*      -->SAVE_WAERS text
*      -->ZLAND      text
*----------------------------------------------------------------------*
FORM append_int_teurb USING nobukrs save_waers zland LIKE t005-land1.
  SELECT SINGLE * FROM teurb INTO CORRESPONDING FIELDS
            OF int_teurb WHERE cprog = sy-cprog
                           AND bukrs = t001-bukrs
  AND land1 = zland.
  IF sy-subrc NE 0.
    IF zland IS INITIAL.
      MESSAGE e442(fr) WITH t001-bukrs sy-cprog.
    ELSE.
      MESSAGE e465(fr) WITH t001-bukrs sy-cprog zland.
    ENDIF.
  ELSE.
    IF nobukrs EQ 1.
      save_waers = teurb-waers.
    ELSE.
      IF teurb-waers NE save_waers.
        MESSAGE e443(fr).
      ENDIF.
    ENDIF.

    int_teurb-hwaer = t001-waers.
    APPEND int_teurb.
  ENDIF.
ENDFORM.                    "APPEND_INT_TEURB

*&---------------------------------------------------------------------*
*&      Form  READ_TALTWAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_taltwar.
  READ TABLE int_teurb WITH KEY bukrs = t001-bukrs
                                cprog = sy-cprog.
  IF sy-subrc EQ 0.
    taltwar-alwar = int_teurb-waers.
  ENDIF.
ENDFORM.                    "READ_TALTWAR

*&---------------------------------------------------------------------*
*&      Form  CONV_TO_ALT_CURR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ZBUKRS     text
*      -->EXCDT      text
*      -->TWAERS     text
*      -->ZDMBTR     text
*----------------------------------------------------------------------*
FORM conv_to_alt_curr USING zbukrs excdt twaers CHANGING zdmbtr.
  DATA: e_dmbtr LIKE bseg-dmbtr.

  READ TABLE int_teurb WITH KEY bukrs = zbukrs cprog = sy-cprog
               BINARY SEARCH.

  IF sy-subrc EQ 0.
*  alternative Hauswährung ungleich Belegwährung
    IF twaers NE int_teurb-waers.
      CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
        EXPORTING
          date             = excdt
          foreign_currency = int_teurb-waers
          local_amount     = zdmbtr
          local_currency   = int_teurb-hwaer
*         RATE             = 0
          type_of_rate     = int_teurb-kurst
        IMPORTING
*         EXCHANGE_RATE    =
          foreign_amount   = e_dmbtr.
      zdmbtr = e_dmbtr.

    ENDIF.
  ENDIF.
ENDFORM.                    "CONV_TO_ALT_CURR

*&---------------------------------------------------------------------*
*&      Form  CONV_TO_ALT_CURR_WIA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ZBUKRS     text
*      -->EXCDT      text
*      -->ZDMBTR     text
*----------------------------------------------------------------------*
FORM conv_to_alt_curr_wia USING zbukrs excdt CHANGING zdmbtr.
  DATA: e_dmbtr LIKE bseg-dmbtr.

  READ TABLE int_teurb WITH KEY bukrs = zbukrs cprog = sy-cprog
               BINARY SEARCH.

  IF sy-subrc EQ 0.
*  alternative Hauswährung ungleich Belegwährung
*     if twaers ne int_teurb-waers.
    CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
      EXPORTING
        date             = excdt
        foreign_currency = int_teurb-waers
        local_amount     = zdmbtr
        local_currency   = g_waers
        type_of_rate     = int_teurb-kurst
      IMPORTING
        foreign_amount   = e_dmbtr.
    zdmbtr = e_dmbtr.
*     endif.
  ENDIF.
ENDFORM.                    "CONV_TO_ALT_CURR_WIA


*&---------------------------------------------------------------------*
*&      Form  convert_alt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TABNAME    text
*      -->BL_WAERS   text
*----------------------------------------------------------------------*
FORM convert_alt USING tabname bl_waers.                          "euro
  CASE tabname.
    WHEN 'BSEG'.
      READ TABLE int_teurb WITH KEY bukrs = bseg-bukrs cprog = sy-cprog
                BINARY SEARCH.
      IF int_teurb-waers NE sp_waers.
        IF int_teurb-waers EQ bl_waers.
          bseg-dmbtr = bseg-wrbtr.
          bseg-mwsts = bseg-wmwst.
          bseg-hwbas = bseg-fwbas.
          bsega-dmsol = bsega-wrsol.
          bsega-dmhab = bsega-wrhab.
          bsega-dmshb = bsega-wrshb.
        ELSE.
          PERFORM conv_to_alt_curr USING    bseg-bukrs excdt sp_waers
                             CHANGING bseg-dmbtr.
          PERFORM conv_to_alt_curr USING    bseg-bukrs excdt sp_waers
                             CHANGING bseg-mwsts.
          PERFORM conv_to_alt_curr USING    bseg-bukrs excdt sp_waers
                             CHANGING bseg-hwbas.
          PERFORM conv_to_alt_curr USING    bseg-bukrs excdt sp_waers
                             CHANGING bsega-dmsol.
          PERFORM conv_to_alt_curr USING    bseg-bukrs excdt sp_waers
                             CHANGING bsega-dmhab.
          PERFORM conv_to_alt_curr USING    bseg-bukrs excdt sp_waers
                             CHANGING bsega-dmshb.
        ENDIF.
      ENDIF.
    WHEN 'BSET'.
      READ TABLE int_teurb WITH KEY bukrs = bset-bukrs cprog = sy-cprog
                BINARY SEARCH.
      IF int_teurb-waers NE sp_waers.
        IF int_teurb-waers EQ bl_waers.
          bset-hwste = bset-fwste.
          bset-hwbas = bset-fwbas.
        ELSE.
          PERFORM conv_to_alt_curr USING    bset-bukrs excdt sp_waers
                             CHANGING bset-hwste.
          PERFORM conv_to_alt_curr USING    bset-bukrs excdt sp_waers
                             CHANGING bset-hwbas.
        ENDIF.
      ENDIF.
      IF xwia EQ 'X' AND NOT g_waers IS INITIAL.
        IF int_teurb-waers NE g_waers. "LW wurde umgesetzt
          IF int_teurb-waers EQ bl_waers.
            bset-lwste = bset-fwste.
            bset-lwbas = bset-fwbas.
          ELSE.
            PERFORM conv_to_alt_curr_wia USING bset-bukrs excdt
                             CHANGING bset-lwste.
            PERFORM conv_to_alt_curr_wia USING bset-bukrs excdt
                             CHANGING bset-lwbas.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    "convert_alt

*----------------------------------------------------------------------*
* FORM T001_READ                                                       *
* Buchungskreisdaten                                                   *
*----------------------------------------------------------------------*
FORM t001_read USING save_bukrs TYPE bukrs.
* IF T001-BUKRS NE SAVE_BUKRS.
*   SELECT SINGLE * FROM T001
*     WHERE BUKRS = SAVE_BUKRS.
* ENDIF.
  CALL FUNCTION 'READ_T001'
    EXPORTING
      xbukrs = save_bukrs
    IMPORTING
      struct = t001.
  IF alcur EQ 'X'. PERFORM read_taltwar.  ENDIF.            "<<<< euro
  sp_waers = t001-waers.               "<<<< euro
ENDFORM.                                                    "T001_READ
*&---------------------------------------------------------------------*
*&      Form  CHECK_DEF_CTRY_OPTION                         "1948319
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS  text
*      -->P_CHECK  text
*      <--P_DEF_SHOW    X = show all deferred tax codes
*      <--P_DEF_SHOW_0  X = show 0% deferred tax codes
*----------------------------------------------------------------------*
FORM check_def_ctry_option                                  "1948319
     USING    p_bukrs      TYPE bukrs
              p_check      TYPE xfeld
     CHANGING p_def_type   TYPE c
              p_def_show   TYPE xfeld
              p_def_show_0 TYPE xfeld.

  STATICS: ls_t005        TYPE t005,
           ld_f7_582_type TYPE msgts.                       "2249537
  DATA:    ld_ctry_iso TYPE intca.

  CLEAR p_def_type.    "par_def not allowed

* First get company code country, esp. for RU, UA.
  READ TABLE gt_isocodes INTO s_isocodes
       WITH KEY bukrs = p_bukrs.
  IF sy-subrc = 0.
    ld_ctry_iso = s_isocodes-intca.
* Note:
* p_def_type 2 exists for reasons of history.
* The function to always show deferred tax codes in RU, UA
* existed since note 595718 and cannot be simply replaced
* by a new parameter par_def. Here country was always
* determioned directly from company code.
    IF ld_ctry_iso EQ 'RU' OR
       ld_ctry_iso EQ 'UA'.
      p_def_type = '2'.    "always show def'd tax codes
    ENDIF.
  ENDIF.


  IF p_def_type EQ space.

* If reporting country is specified we use it
    DATA(lv_tax_country) = COND #( WHEN flg_txa_active = abap_true
                                     THEN sel_taxc-low
                                   ELSE sel_lstm-low ).
    IF NOT lv_tax_country IS INITIAL.
***   IF ls_t005-land1 IS INITIAL.                          "2249537
      IF ls_t005-land1 NE lv_tax_country.                   "2249537
        SELECT SINGLE * FROM t005 INTO ls_t005
        WHERE land1 = lv_tax_country.
      ENDIF.
      ld_ctry_iso = ls_t005-intca.
    ENDIF.
* evaluate country
    CASE ld_ctry_iso.
      WHEN 'IT'
        OR 'HR'
        OR 'RO'
        OR 'BG'                                             "2129529
        OR 'RS'                                             "2129529
        OR 'PL'                                             "2129529
        OR 'ES'.
        p_def_type = '1'.      "optional via par_def
    ENDCASE.

  ENDIF.

* Check once for customization of message F7 582.           "2249537
* This can be used to generally allow the function.         "2249537
  IF ld_f7_582_type IS INITIAL.                             "2249537
    CALL FUNCTION 'READ_CUSTOMIZED_MESSAGE'                 "2249537
      EXPORTING                                             "2249537
        i_arbgb = 'F7'                                "2249537
        i_dtype = 'E'                                 "2249537
        i_msgnr = '582'                               "2249537
      IMPORTING                                             "2249537
        e_msgty = ld_f7_582_type.                     "2249537
  ENDIF.                                                    "2249537


* Checks performed on selection screen
  IF p_check = 'X'.

    IF p_def_type EQ space AND
       NOT par_def IS INITIAL.
*   def tax codes are not allowed in the country
***   MESSAGE e582 WITH ld_ctry_iso.                        "2249537
      IF ld_f7_582_type NE '-'.                             "2249537
        MESSAGE ID 'F7' TYPE ld_f7_582_type NUMBER '582'    "2249537
                WITH ld_ctry_iso.                           "2249537
      ENDIF.                                                "2249537
    ENDIF.

    IF NOT par_def IS INITIAL AND
       NOT par_binp IS INITIAL.
*   def tax codes not allowed together with batch input
      MESSAGE e581.
    ENDIF.

  ENDIF.

* If F7582 is set to no error: allow the function.          "2249537
  IF p_def_type EQ space AND                                "2249537
     ld_f7_582_type CA 'WIS-'.                              "2249537
    p_def_type = '1'.      "optional via par_def            "2249537
  ENDIF.                                                    "2249537


* evaluate parameters and def_type to get a result
  p_def_show = space.
  IF p_def_type = '1' AND par_def = 'X'.
    p_def_show = 'X'.        "def tax optional
  ELSEIF p_def_type = '2'.
    p_def_show = 'X'.        "def tax always
  ENDIF.
  IF par_binp = 'X'.         "but never with batch input
    p_def_show = space.
  ENDIF.

* 0% deferred tax codes are shown in all countries
* irrespective of par_def or par_binp.
* This is required for the 0% deferred tax workaround
* implemented in RFUMSV25 and J_1HDTAX (updates on BSET).
  p_def_show_0 = 'X'.

ENDFORM.                    " CHECK_DEF_CTRY_OPTION         "1948319
*&---------------------------------------------------------------------*
*&      Form  ADAPT_TCURF_DECIMALS                          "1963595
*&---------------------------------------------------------------------*
*       Decimal places of the involved currencies are taken
*       into account by changing the factors ffact, tfact in tcurf.
*----------------------------------------------------------------------*
*      <--PS_TCURF  text
*----------------------------------------------------------------------*
FORM adapt_tcurf_decimals                                   "1963595
     CHANGING ps_tcurf TYPE tcurf.
  DATA: currdec_f TYPE currdec,
        currdec_t TYPE currdec.

  SELECT SINGLE currdec FROM tcurx INTO currdec_f
  WHERE currkey = ps_tcurf-fcurr.
  IF sy-subrc <> 0.
    currdec_f = 2.
  ENDIF.

  SELECT SINGLE currdec FROM tcurx INTO currdec_t
  WHERE currkey = ps_tcurf-tcurr.
  IF sy-subrc <> 0.
    currdec_t = 2.
  ENDIF.

* only required if decimals are different
  IF currdec_f <> currdec_t.

* reduce number of decimals to difference
    IF currdec_f > currdec_t.
      currdec_f = currdec_f - currdec_t.
      currdec_t = 0.
    ELSE.
      currdec_t = currdec_t - currdec_f.
      currdec_f = 0.
    ENDIF.

* adapt factors avoiding overflows or underflows
    IF currdec_f > 0.
      DO currdec_f TIMES.
        IF ps_tcurf-tfact >= 10.
          ps_tcurf-tfact = ps_tcurf-tfact / 10.
        ELSEIF ps_tcurf-ffact < '10000000'.
          ps_tcurf-ffact = ps_tcurf-ffact * 10.
        ENDIF.
      ENDDO.
    ENDIF.

    IF currdec_t > 0.
      DO currdec_t TIMES.
        IF ps_tcurf-ffact >= 10.
          ps_tcurf-ffact = ps_tcurf-ffact / 10.
        ELSEIF ps_tcurf-tfact < '10000000'.
          ps_tcurf-tfact = ps_tcurf-tfact * 10.
        ENDIF.
      ENDDO.
    ENDIF.

  ENDIF.

ENDFORM.                    " ADAPT_TCURF_DECIMALS          "1963595
*&---------------------------------------------------------------------*
*&      Form  UPDATE_BSET                                   "2061805
*&---------------------------------------------------------------------*
*       Update fields BSET-STMDT and BSET-STMTI
*       with execution date and time.
*----------------------------------------------------------------------*
*  -->  using global internal table tab_bset_key
*             hlp_stmdt, hlp_stmti
*----------------------------------------------------------------------*
FORM update_bset.                                           "2061805

  DATA: ld_counter TYPE i.

  IF par_bsud = 'X'.   "if in update mode ...

    LOOP AT tab_bset_key.
      UPDATE bset
             SET stmdt = hlp_stmdt
                 stmti = hlp_stmti
             WHERE bukrs = tab_bset_key-bukrs
               AND belnr = tab_bset_key-belnr
               AND gjahr = tab_bset_key-gjahr
               AND buzei = tab_bset_key-buzei.
      ld_counter = ld_counter + 1.
      IF ld_counter >= 100.
        COMMIT WORK.
        ld_counter = 0.
      ENDIF.
    ENDLOOP.

    IF ld_counter > 0.
      COMMIT WORK.
    ENDIF.

  ENDIF.

  FREE tab_bset_key.

ENDFORM.                    " update_bset                   "2061805
*&---------------------------------------------------------------------*
*&      Form  CHECK_CVP_ILM_1                               "2073571
*&---------------------------------------------------------------------*
*       Check if BF ERP_CVP_ILM_1 is active
*----------------------------------------------------------------------*
*      <--P_CVP_ACTIVE  text
*----------------------------------------------------------------------*
FORM check_cvp_ilm_1                                        "2073571
     CHANGING p_cvp_active TYPE xfeld.

  CLEAR p_cvp_active.

  IF cl_vs_switch_check=>cmd_vmd_cvp_ilm_sfw_01( ) IS NOT INITIAL.
    p_cvp_active = 'X'.
  ENDIF.

ENDFORM.  "check_cvp_ilm_1                                  "2073571
*&---------------------------------------------------------------------*
*&      Form  NEGATIVE_POSTING                              "2290231
*&---------------------------------------------------------------------*
*       Adapt declaration to xnegp flag.
*       This is only called if par_xsht (seperate deb/cred) is active.
*----------------------------------------------------------------------*
*  -->         table tab_ep
*  -->         table gt_bseg_doc
*  -->         field bkpf-bukrs
*  -->         table s_isocodes for company code country
*  <->         table tab_ep
*----------------------------------------------------------------------*
FORM negative_posting.                                      "2290231

  DATA:
    ld_spec_proc TYPE xfeld VALUE space,
    ld_xnegp     TYPE xfeld,
    ld_all_xnegp TYPE xfeld,
    ld_any_xnegp TYPE xfeld.


  ld_all_xnegp = 'X'.
  ld_any_xnegp = space.
  LOOP AT gt_bseg_doc INTO gs_bseg_doc.
    IF gs_bseg_doc-xnegp EQ 'X'.
      ld_any_xnegp = 'X'.
    ELSE.
      ld_all_xnegp = space.
    ENDIF.
  ENDLOOP.

  IF ld_any_xnegp EQ space.
    RETURN.
  ENDIF.

* special processing is currently only used in Russia:
  READ TABLE gt_isocodes INTO s_isocodes
       WITH KEY bukrs = bkpf-bukrs.
  IF sy-subrc = 0.
    IF s_isocodes-intca EQ 'RU'.
      ld_spec_proc = 'X'.
    ENDIF.
  ENDIF.

* process all tax items
  LOOP AT tab_ep.

    IF ld_all_xnegp EQ 'X'.
* If all lines have xnegp set no further checks are needed.
* This also ensures that the procedure always works where
* negative posting is used only in reversal documents.
      ld_xnegp = 'X'.
    ELSE.
      ld_xnegp = space.

* Special process: xnegp is set manually on single tax items
* (for ex.) in down payment clearing documents. We need to
* relate bset item and the corresponding tax posting.
      IF ld_spec_proc EQ 'X'.
        IF tab_ep-hwste NE 0
          OR tab_ep-fwste NE 0.
* tax posting should exist:
* get xnegp directly from the tax line
          LOOP AT gt_bseg_doc INTO gs_bseg_doc
               WHERE hkont = tab_ep-tkont
                 AND txgrp = tab_ep-txgrp
                 AND tax_country = tab_ep-tax_country
                 AND mwskz = tab_ep-mwskz
                 AND txdat_from = tab_ep-txdat_from
                 AND shkzg = tab_ep-shkzg
                 AND mwart NE space.
            ld_xnegp = gs_bseg_doc-xnegp.
            EXIT.
          ENDLOOP.
        ELSE.
* processing for 0% tax rate:
* check if all matching base items have xnegp set
          ld_xnegp = 'X'.
          LOOP AT gt_bseg_doc INTO gs_bseg_doc
               WHERE txgrp = tab_ep-txgrp
                 AND tax_country = tab_ep-tax_country
                 AND mwskz = tab_ep-mwskz
                 AND txdat_from = tab_ep-txdat_from
                 AND shkzg = tab_ep-shkzg
                 AND mwart EQ space
                 AND ( koart CA 'SAM' OR
                       umsks = 'A' ).
            IF gs_bseg_doc-xnegp IS INITIAL.
              CLEAR ld_xnegp.
            ENDIF.
          ENDLOOP.
          IF sy-subrc <> 0.
            CLEAR ld_xnegp.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

* If xnegp is found to be active shkzg is reversed.
* The signs of amounts have been fitted to shkzg already,
* so they are not to be changed any more.
    IF ld_xnegp EQ 'X'.
      TRANSLATE tab_ep-shkzg USING 'SHHS'.
      MODIFY tab_ep
             TRANSPORTING shkzg.
    ENDIF.

  ENDLOOP.  "at tab_ep

ENDFORM.    "negative_posting                               "2290231
*&---------------------------------------------------------------------*
*& Form UPDATE_APP_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_app_log .

  DATA: ls_ballog           TYPE bal_s_log,
        ls_appl_log_message TYPE bal_s_msg,
        ls_message          TYPE bapiret2,
        lv_log_handle       TYPE balloghndl,
        lt_log_handle       TYPE bal_t_logh.

* Creation of Application Log
  IF gt_message_all IS NOT INITIAL.

    ls_ballog-aldate    = sy-datum.
    ls_ballog-altime    = sy-uzeit.
    ls_ballog-aluser    = sy-uname.
    ls_ballog-alprog    = sy-repid.
    ls_ballog-object    = 'FIGL'.
    ls_ballog-subobject = 'FIGL_GL_AUTO_CLR'.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = ls_ballog
      IMPORTING
        e_log_handle            = lv_log_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    IF sy-batch = abap_true.
      CALL FUNCTION 'BP_ADD_APPL_LOG_HANDLE'
        EXPORTING
          loghandle                  = lv_log_handle
        EXCEPTIONS
          could_not_set_handle       = 1
          not_running_in_batch       = 2
          could_not_get_runtime_info = 3
          handle_already_exists      = 4
          locking_error              = 5
          OTHERS                     = 6.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

* Add Messages to the Log
    LOOP AT gt_message_all INTO ls_message.
      CLEAR ls_appl_log_message.
      ls_appl_log_message-msgid = ls_message-id.
      ls_appl_log_message-msgty = ls_message-type.
      ls_appl_log_message-msgno = ls_message-number.
      ls_appl_log_message-msgv1 = ls_message-message_v1.
      ls_appl_log_message-msgv2 = ls_message-message_v2.
      ls_appl_log_message-msgv3 = ls_message-message_v3.
      ls_appl_log_message-msgv4 = ls_message-message_v4.

* Determine problem class
      CASE ls_message-type.
        WHEN 'A' OR 'E' OR 'X'.
          ls_appl_log_message-probclass = '1'.
        WHEN 'W'.
          ls_appl_log_message-probclass = '2'.
        WHEN 'I' OR 'S'.
          ls_appl_log_message-probclass = '3'.
      ENDCASE.

      CALL FUNCTION 'BAL_LOG_MSG_ADD'
        EXPORTING
          i_log_handle = lv_log_handle
          i_s_msg      = ls_appl_log_message.
    ENDLOOP.

* Save the log in database
    APPEND lv_log_handle TO lt_log_handle.

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_t_log_handle   = lt_log_handle
      EXCEPTIONS
        log_not_found    = 1
        save_not_allowed = 2
        numbering_error  = 3
        OTHERS           = 4.
    IF sy-subrc IS INITIAL.
      COMMIT WORK.
    ELSE.
      MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDFORM.

INCLUDE i_rfums_menu_item_in_cloud.
*&---------------------------------------------------------------------*
*&      Form  WIA_TAX_DECL_COUNTRY "3296651
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  ZLAND                                                         *
*---------------------------------------------------------------------*
FORM wia_tax_decl_country USING zland.                      "3296651
  g_land = zland.
  SELECT SINGLE * FROM t005 WHERE land1 = g_land.
  IF sy-subrc NE 0.
    IF sy-batch <> space.
      MESSAGE s223(f7) WITH g_land.
      MESSAGE s207(f7) WITH sy-repid.
      STOP.
    ELSE.
      MESSAGE a223(f7) WITH g_land.
    ENDIF.
  ELSE.
    g_waers =  t005-waers.
  ENDIF.
ENDFORM. "WIA_TAX_DECL_COUNTRY                              "3296651

*--->>> EOL-0083 24.04.2024
*&---------------------------------------------------------------------*
*& Form check_gsber
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_gsber .
  IF so_gsber IS INITIAL.
    MESSAGE 'Bitte den Geschäftsbereich eingeben.' TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form authority_check_gsber
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM authority_check_gsber .
  DATA: lt_gsber TYPE TABLE OF tgsb,
        ls_gsber TYPE tgsb.

  SELECT *
    FROM tgsb
    INTO TABLE lt_gsber
    WHERE gsber IN so_gsber.

  CLEAR: so_gsber, so_gsber[].

  LOOP AT lt_gsber INTO ls_gsber.
    AUTHORITY-CHECK OBJECT 'F_BKPF_GSB'
      ID 'ACTVT' FIELD '03'
      ID 'GSBER' FIELD ls_gsber-gsber.
    IF sy-subrc = 0.
      so_gsber-sign = 'I'.
      so_gsber-option = 'EQ'.
      so_gsber-low    = ls_gsber-gsber.
      APPEND so_gsber.
    ENDIF.
  ENDLOOP.
ENDFORM.
*---<<<

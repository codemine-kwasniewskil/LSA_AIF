*&---------------------------------------------------------------------*
*& Report /THKR/BCS_CHECK_BSP_FOR_YEAR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/bcs_check_bsp_for_year.


TABLES: fmci, fmfctr.
* FMCI    - Finanzpositionen
* FMCIT   - Finanzpositionen Texte
* FMFCTR  - Stammsatz der Finanzstelle
* FMFCTRT - Text der Finanzstelle
*--------------------------------------------------------------------*
* DATA
*--------------------------------------------------------------------*
" Tabellen für select - Rohdaten
TYPES: BEGIN OF ty_bsp_raw,
         fm_area  TYPE fikrs,       " Finanzkreis
         fiscyear TYPE gjahr,       " Geschäftsjahr,
         objnr    TYPE bubas_objnr, " Objektnummer für HHM-Budgetierung und AVK
         budcat   TYPE buku_budcat, " Budgetkategorie
         fundsctr TYPE fistl,       " Finanzstelle
         cmmtitem TYPE fm_fipex,    " Finanzposition
       END OF ty_bsp_raw.

DATA: lt_bsp_raw TYPE STANDARD TABLE OF ty_bsp_raw.
DATA: ls_bsp_raw TYPE ty_bsp_raw.

FIELD-SYMBOLS: <fs__bsp_raw> TYPE ty_bsp_raw.



" Tabellen für Aufbereitung - Ergebnistabelle - sorted table + standard table
TYPES: BEGIN OF ty_bsp_result,
         fm_area              TYPE fikrs,       " Finanzkreis
         fiscyear             TYPE gjahr,       " Geschäftsjahr,
         objnr                TYPE bubas_objnr, " Objektnummer für HHM-Budgetierung und AVK
         fundsctr             TYPE fistl,       " Finanzstelle
         cmmtitem             TYPE fm_fipex,    " Finanzposition

         potyp                TYPE fm_potyp,    " Finanzpositionstyp

         fipos_text1          TYPE fm_beschr0,  " Text der Finanzposition Länge 50
         fistl_bezeich        TYPE text65,      " Kombination aus den Feldern BEZEICH + BESCHR

         flag_9a_zahl_buch    TYPE flag,        " Flag - Zahlungsbudget Buchungsledger 9A
         flag_9b_verpf_buch   TYPE flag,        " Flag - Verpflichtungsbudget Buchungsledger 9B

         flag_9f_zahl_budget  TYPE flag,        " Flag - Zahlungsbudget Budgetledger 9F
         flag_9g_verpf_budget TYPE flag,        " Flag - Verpflichtungsbudget Budgetledger  9G

         error                TYPE flag,        " Es ist eine Unstimmigkeit aufgetreten
       END OF ty_bsp_result.



DATA: lt_bsp_result_sort TYPE SORTED TABLE OF ty_bsp_result WITH NON-UNIQUE KEY fm_area fiscyear objnr.
DATA: ls_bsp_result_sort TYPE ty_bsp_result.

FIELD-SYMBOLS: <fs__bsp_result_sort> TYPE ty_bsp_result.


DATA: lt_bsp_result_alv TYPE STANDARD TABLE OF ty_bsp_result.
DATA: ls_bsp_result_alv TYPE ty_bsp_result.

FIELD-SYMBOLS: <fs__bsp_result_alv> TYPE ty_bsp_result.



TYPES: BEGIN OF ty_fmci_plus,
         fikrs TYPE fikrs,       " Finanzkreis
         gjahr TYPE gjahr,       " Geschäftsjahr,
         fipex TYPE fm_fipex,    " Finanzposition
         potyp TYPE fm_potyp,    " Finanzpositionstyp
         text1 TYPE fm_beschr0,  " Bezeichnung Finanzstelle
       END OF ty_fmci_plus.



DATA: lt_fmci TYPE STANDARD TABLE OF ty_fmci_plus.
DATA: ls_fmci TYPE ty_fmci_plus.

FIELD-SYMBOLS: <fs__fmci> TYPE ty_fmci_plus.


DATA: lt_fmcit  TYPE STANDARD TABLE OF fmcit.
DATA: ls_fmcit  TYPE fmcit.

FIELD-SYMBOLS: <fs__fmcit> TYPE fmcit.



* Bezeichnung der Finanzstellen
TYPES: BEGIN OF ty_fistl_plus,
         fikrs         TYPE fikrs,       " Finanzkreis
         fictr         TYPE fm_fictr,    " Finanzstelle,
         fistl_bezeich TYPE text65,      " Kombination aus den Feldern BEZEICH + BESCHR
       END OF ty_fistl_plus.


DATA: ls_fmfctrt TYPE fmfctrt.


DATA: lt_fistl TYPE SORTED TABLE OF ty_fistl_plus WITH NON-UNIQUE KEY fikrs  fictr.
DATA: ls_fistl TYPE ty_fistl_plus.

FIELD-SYMBOLS: <fs__fistl> TYPE ty_fistl_plus.



DATA: lv_index            TYPE sy-index.

" Cursor für Datenbankzugriff
DATA: gv_cursor           TYPE cursor.

" Paketgröße
DATA: gv_package_size     TYPE i.


*--------------------------------------------------------------------*
* Ausgabe
*--------------------------------------------------------------------*
DATA: lr_salv             TYPE REF TO cl_salv_table.
DATA: go_functions        TYPE REF TO cl_salv_functions.        "Symbolleiste
DATA: go_display          TYPE REF TO cl_salv_display_settings. "Displayeinstellungen
DATA: go_columns          TYPE REF TO cl_salv_columns_table.    "Spaltenmanipulation
DATA: go_column           TYPE REF TO cl_salv_column_table.
DATA: go_events           TYPE REF TO cl_salv_events_table.     " Events
DATA: go_selections       TYPE REF TO cl_salv_selections.       " ausgewählte Zeilen


DATA: color               TYPE lvc_s_colo.                      "Farbe
DATA: go_sorts            TYPE REF TO cl_salv_sorts.            "Sortierung
DATA: go_agg              TYPE REF TO cl_salv_aggregations.     "Aggregation
DATA: go_filter           TYPE REF TO cl_salv_filters.          "Filter
DATA: go_layout           TYPE REF TO cl_salv_layout.           "Layout
DATA: key                 TYPE salv_s_layout_key.

* Fehlerhandling
DATA: gr_err_salv         TYPE REF TO cx_salv_msg.
DATA: gr_err_salv_exist   TYPE REF TO cx_salv_existing.
DATA: gr_err_wrong_call   TYPE REF TO cx_salv_wrong_call.
DATA: gv_string           TYPE string.

* Info in der oberen Leiste
DATA: lv_counter          TYPE i.
DATA: lv_counter_string   TYPE string.
DATA: lv_info             TYPE lvc_title.
*--------------------------------------------------------------------*






*--------------------------------------------------------------------*
* Selektionsbedingungen
*--------------------------------------------------------------------*
PARAMETERS: p_fikrs TYPE fm01-fikrs OBLIGATORY DEFAULT 'F100',          " Finanzkreis
            p_gjahr TYPE gjahr      OBLIGATORY.                         " Geschäftsjahr


SELECT-OPTIONS: s_fistl FOR fmfctr-fictr,                               " Finanzstelle

                s_fipex FOR fmci-fipex,                                 " Finanzposition
                s_potyp FOR fmci-potyp.                                 " Positionstyp der Finanzposition 2 = Einnahmen, 3 = Ausgaben


PARAMETERS: p_filter AS CHECKBOX MODIF ID usr.                          " nur Einträge mit Prüfvermerk

PARAMETERS: p_all   RADIOBUTTON GROUP g1 DEFAULT 'X' MODIF ID usr,      " alle Daten lesen
            p_delta RADIOBUTTON GROUP g1  MODIF ID usr.                 " fehlende Finanzposition ermitteln

*--------------------------------------------------------------------*



**********************************************************************
* START-OF-SELECTION.
**********************************************************************
START-OF-SELECTION.


*--------------------------------------------------------------------*
* Check der Eingaben
*--------------------------------------------------------------------*
  IF p_delta IS NOT INITIAL.

    IF s_fistl IS NOT INITIAL.
      WRITE:/ 'Bei der Ermittlung der fehlenden Kontierungen darf nicht auf Finanzstellen eingeschränkt werden.'.
      EXIT.
    ENDIF.

  ENDIF.


* Finanzpositionen lesen

*--------------------------------------------*
* Info
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text = 'Finanzpositionen lesen'.
*--------------------------------------------*

* Gibt es zu jeder Finanzposition (Tabelle FMCI- 2021 ca. 18.300 Einträge) einen Eintrag im Budgetstrukturplan (FMBS_BO bzw. FMBASIDX)-
  SELECT * FROM fmci INTO CORRESPONDING FIELDS OF TABLE lt_fmci
    WHERE fikrs   = p_fikrs     " Finanzkreis
      AND gjahr   = p_gjahr     " Geschäftsjahr
      AND fipex   IN s_fipex    " Finanzposition
      AND potyp   IN s_potyp    " Positionstyp der Finanzposition 2 = Einnahmen, 3 = Ausgaben
    ORDER BY PRIMARY KEY.

  IF sy-subrc <> 0.
    WRITE:/ 'Keine Finanzpositionen zur Selektion gefunden. Verarbeitung wird beendet.'.
    EXIT.

  ELSE.

* Texte für Finanzposition anreichern
    SELECT * FROM fmcit INTO CORRESPONDING FIELDS OF TABLE lt_fmcit
         FOR ALL ENTRIES IN lt_fmci
         WHERE spras = 'D'
           AND fikrs = lt_fmci-fikrs
           AND gjahr = lt_fmci-gjahr
           AND fipex = lt_fmci-fipex
          ORDER BY PRIMARY KEY.
    IF sy-subrc = 0.

      LOOP AT lt_fmci ASSIGNING <fs__fmci>.

        READ TABLE lt_fmcit ASSIGNING <fs__fmcit> BINARY SEARCH
          WITH KEY spras = 'D'
                   fikrs = <fs__fmci>-fikrs
                   gjahr = <fs__fmci>-gjahr
                   fipex = <fs__fmci>-fipex.
        IF sy-subrc = 0.
          <fs__fmci>-text1 = <fs__fmcit>-text1.
        ENDIF.

      ENDLOOP.

    ENDIF. " IF sy-subrc = 0.
  ENDIF. " IF sy-subrc <> 0.


*-- Set Defaults
  " Blockgröße = Größe der Verarbeitungblöcke
  gv_package_size = 10000.



*--------------------------------------------------------------------*
* Zahlungsbudget holen
*--------------------------------------------------------------------*

  OPEN CURSOR WITH HOLD  gv_cursor  FOR

* Budgetledger - Zahlungsbudget + Verpflichtungsbudget holen
SELECT
  fm_area   AS fm_area      " Finanzkreis
  fiscyear  AS fiscyear     " Geschäftsjahr,
  objnr     AS objnr        " Objektnummer für HHM-Budgetierung und AVK
  budcat    AS budcat       " Budgetkategorie
  fundsctr  AS fundsctr     " Finanzstelle
  cmmtitem  AS cmmtitem     " Finanzposition

FROM /thkr/vfmbs_bo

WHERE fm_area  = p_fikrs
  AND fiscyear = p_gjahr
  AND fundsctr IN s_fistl
  AND cmmtitem IN s_fipex
  ORDER BY  client
            fm_area
            bs
            fiscyear
            budcat
            objnr
            fundsctr
            cmmtitem.


  DO.


*--------------------------------------------*
* Info
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = 'Budgetledger lesen'.
*--------------------------------------------*


    REFRESH lt_bsp_raw.

    FETCH NEXT CURSOR  gv_cursor
    INTO CORRESPONDING FIELDS OF TABLE lt_bsp_raw
    PACKAGE SIZE gv_package_size.
    IF sy-subrc NE 0.
      CLOSE CURSOR gv_cursor.
      EXIT.
    ENDIF.


* Ergebnistabelle aufbauen
    IF lt_bsp_raw IS NOT INITIAL.

      LOOP AT lt_bsp_raw ASSIGNING <fs__bsp_raw>.

*        CLEAR: lv_index.
        READ TABLE lt_bsp_result_sort ASSIGNING <fs__bsp_result_sort> BINARY SEARCH
         WITH KEY  fm_area   =  <fs__bsp_raw>-fm_area
                   fiscyear  =  <fs__bsp_raw>-fiscyear
                   objnr     =  <fs__bsp_raw>-objnr .
*        lv_index = sy-tabix.
        IF sy-subrc = 0.
          " Eintrag ist bekannt -> ergänzen
          IF <fs__bsp_raw>-budcat = '9F'.
            " Flag - Zahlungsbudget Budgetledger 9F
            <fs__bsp_result_sort>-flag_9f_zahl_budget = 'X'.

          ELSEIF <fs__bsp_raw>-budcat = '9G'.
            " Flag - Verpflichtungsbudget Budgetledger  9G
            <fs__bsp_result_sort>-flag_9g_verpf_budget = 'X'.
          ENDIF.

        ELSE.
          " Eintrag ist unbekannt -> neu einfügen

          CLEAR: ls_bsp_result_sort.

          ls_bsp_result_sort-fm_area    =  <fs__bsp_raw>-fm_area.    " Finanzkreis
          ls_bsp_result_sort-fiscyear   =  <fs__bsp_raw>-fiscyear.   " Geschäftsjahr,
          ls_bsp_result_sort-objnr      =  <fs__bsp_raw>-objnr.      " Objektnummer für HHM-Budgetierung und AVK
          ls_bsp_result_sort-fundsctr   =  <fs__bsp_raw>-fundsctr.   " Finanzstelle
          ls_bsp_result_sort-cmmtitem   =  <fs__bsp_raw>-cmmtitem.   " Finanzposition


          IF <fs__bsp_raw>-budcat = '9F'.
            " Flag - Zahlungsbudget Budgetledger 9F
            ls_bsp_result_sort-flag_9f_zahl_budget = 'X'.

          ELSEIF <fs__bsp_raw>-budcat = '9G'.
            " Flag - Verpflichtungsbudget Budgetledger  9G
            ls_bsp_result_sort-flag_9g_verpf_budget = 'X'.
          ENDIF.


*--       Texte für Finanzpositionen nachlesen
          READ TABLE lt_fmci ASSIGNING <fs__fmci> BINARY SEARCH
                   WITH KEY  fikrs   =  <fs__bsp_raw>-fm_area
                             gjahr   =  <fs__bsp_raw>-fiscyear
                             fipex   =  <fs__bsp_raw>-cmmtitem.
          IF sy-subrc = 0.
            ls_bsp_result_sort-potyp       = <fs__fmci>-potyp.
            ls_bsp_result_sort-fipos_text1 = <fs__fmci>-text1.
          ENDIF.



*--       Texte für Finanzstellen nachlesen
          READ TABLE lt_fistl ASSIGNING <fs__fistl> BINARY SEARCH
                   WITH KEY  fikrs   =  <fs__bsp_raw>-fm_area
                             fictr   =  <fs__bsp_raw>-fundsctr.
          IF sy-subrc = 0.
            ls_bsp_result_sort-fistl_bezeich = <fs__fistl>-fistl_bezeich.
          ELSE.
            CLEAR: ls_fmfctrt.
            SELECT SINGLE * FROM fmfctrt INTO ls_fmfctrt
               WHERE spras  =  'D'
                 AND fikrs  =  <fs__bsp_raw>-fm_area
                 AND fictr  =  <fs__bsp_raw>-fundsctr
                 AND ( datbis >= sy-datum
                    AND datab  <= sy-datum ).
            IF sy-subrc = 0.
              CLEAR: ls_fistl.

              ls_fistl-fikrs =  <fs__bsp_raw>-fm_area.
              ls_fistl-fictr =  <fs__bsp_raw>-fundsctr.

              CONCATENATE ls_fmfctrt-bezeich  ls_fmfctrt-beschr
                 INTO ls_fistl-fistl_bezeich
                 SEPARATED BY ' - '.

              INSERT ls_fistl INTO TABLE lt_fistl.
              ls_bsp_result_sort-fistl_bezeich = ls_fistl-fistl_bezeich.

            ENDIF. " IF sy-subrc = 0.


          ENDIF.  "READ TABLE lt_fistl ..IF sy-subrc = 0.



          INSERT ls_bsp_result_sort INTO TABLE lt_bsp_result_sort.


        ENDIF. " " Eintrag ist bekannt -> ergänzen

      ENDLOOP. " LOOP AT lt_bsp_raw ASSIGNING <fs__bsp_raw>.

    ENDIF. " IF lt_bsp_raw IS NOT INITIAL.


  ENDDO. " Cursor für Zahlungsbudget holen
*--------------------------------------------------------------------*
* Ende: Zahlungsbudget holen
*--------------------------------------------------------------------*




*--------------------------------------------------------------------*
* Zahlungsbudget holen
*--------------------------------------------------------------------*


  OPEN CURSOR WITH HOLD  gv_cursor  FOR

* Buchungsledger - Zahlungsbudget + Verpflichtungsbudget holen
SELECT
  fm_area     AS fm_area      " Finanzkreis
  s_fiscyear  AS fiscyear     " Geschäftsjahr,
  s_objnr     AS objnr        " Objektnummer für HHM-Budgetierung und AVK
  s_ldnr      AS budcat       " Budgetkategorie
  fundsctr    AS fundsctr     " Finanzstelle
  cmmtitem    AS cmmtitem     " Finanzposition

FROM /thkr/vfmbasidx

WHERE fm_area  = p_fikrs
  AND s_fiscyear = p_gjahr
  AND fundsctr IN s_fistl
  AND cmmtitem IN s_fipex
  ORDER BY  client
            fm_area
            s_objnr
            s_ldnr
            r_ldnr
            s_fiscyear
            fundsctr
            cmmtitem .

  DO.

*--------------------------------------------*
* Info
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = 'Buchungsledger lesen'.
*--------------------------------------------*


    REFRESH lt_bsp_raw.

    FETCH NEXT CURSOR  gv_cursor
    INTO CORRESPONDING FIELDS OF TABLE lt_bsp_raw
    PACKAGE SIZE gv_package_size.
    IF sy-subrc NE 0.
      CLOSE CURSOR gv_cursor.
      EXIT.
    ENDIF.


* Ergebnistabelle aufbauen
    IF lt_bsp_raw IS NOT INITIAL.

      LOOP AT lt_bsp_raw ASSIGNING <fs__bsp_raw>.

*        CLEAR: lv_index.
        READ TABLE lt_bsp_result_sort ASSIGNING <fs__bsp_result_sort> BINARY SEARCH
         WITH KEY  fm_area   =  <fs__bsp_raw>-fm_area
                   fiscyear  =  <fs__bsp_raw>-fiscyear
                   objnr     =  <fs__bsp_raw>-objnr .
*        lv_index = sy-tabix.
        IF sy-subrc = 0.
          " Eintrag ist bekannt -> ergänzen
          IF <fs__bsp_raw>-budcat = '9A'.
            " Flag - Zahlungsbudget Buchungsledger 9A
            <fs__bsp_result_sort>-flag_9a_zahl_buch = 'X'.

          ELSEIF <fs__bsp_raw>-budcat = '9B'.
            " Flag - Verpflichtungsbudget Buchungsledger 9B
            <fs__bsp_result_sort>-flag_9b_verpf_buch = 'X'.
          ENDIF.

        ELSE.
          " Eintrag ist unbekannt -> neu einfügen

          CLEAR: ls_bsp_result_sort.

          ls_bsp_result_sort-fm_area    =  <fs__bsp_raw>-fm_area.    " Finanzkreis
          ls_bsp_result_sort-fiscyear   =  <fs__bsp_raw>-fiscyear.   " Geschäftsjahr,
          ls_bsp_result_sort-objnr      =  <fs__bsp_raw>-objnr.      " Objektnummer für HHM-Budgetierung und AVK
          ls_bsp_result_sort-fundsctr   =  <fs__bsp_raw>-fundsctr.   " Finanzstelle
          ls_bsp_result_sort-cmmtitem   =  <fs__bsp_raw>-cmmtitem.   " Finanzposition


          IF <fs__bsp_raw>-budcat = '9A'.
            " Flag - Zahlungsbudget Buchungsledger 9A
            ls_bsp_result_sort-flag_9a_zahl_buch = 'X'.

          ELSEIF <fs__bsp_raw>-budcat = '9B'.
            " Flag - Verpflichtungsbudget Buchungsledger 9B
            ls_bsp_result_sort-flag_9b_verpf_buch = 'X'.
          ENDIF.


*--       Texte für Finanzpositionen nachlesen
          READ TABLE lt_fmci ASSIGNING <fs__fmci> BINARY SEARCH
                   WITH KEY  fikrs   =  <fs__bsp_raw>-fm_area
                             gjahr   =  <fs__bsp_raw>-fiscyear
                             fipex   =  <fs__bsp_raw>-cmmtitem.
          IF sy-subrc = 0.
            ls_bsp_result_sort-potyp        = <fs__fmci>-potyp.
            ls_bsp_result_sort-fipos_text1  = <fs__fmci>-text1.
          ENDIF.



*--       Texte für Finanzstellen nachlesen
          READ TABLE lt_fistl ASSIGNING <fs__fistl> BINARY SEARCH
                   WITH KEY  fikrs   =  <fs__bsp_raw>-fm_area
                             fictr   =  <fs__bsp_raw>-fundsctr.
          IF sy-subrc = 0.
            ls_bsp_result_sort-fistl_bezeich = <fs__fistl>-fistl_bezeich.
          ELSE.
            CLEAR: ls_fmfctrt.
            SELECT SINGLE * FROM fmfctrt INTO ls_fmfctrt
               WHERE spras  =  'D'
                 AND fikrs  =  <fs__bsp_raw>-fm_area
                 AND fictr  =  <fs__bsp_raw>-fundsctr
                 AND ( datbis >= sy-datum
                    AND datab  <= sy-datum ).
            IF sy-subrc = 0.
              CLEAR: ls_fistl.

              ls_fistl-fikrs =  <fs__bsp_raw>-fm_area.
              ls_fistl-fictr =  <fs__bsp_raw>-fundsctr.

              CONCATENATE ls_fmfctrt-bezeich  ls_fmfctrt-beschr
                 INTO ls_fistl-fistl_bezeich
                 SEPARATED BY ' - '.

              INSERT ls_fistl INTO TABLE lt_fistl.
              ls_bsp_result_sort-fistl_bezeich = ls_fistl-fistl_bezeich.

            ENDIF. " IF sy-subrc = 0.


          ENDIF.  "READ TABLE lt_fistl ..IF sy-subrc = 0.




          INSERT ls_bsp_result_sort INTO TABLE lt_bsp_result_sort.


        ENDIF. " " Eintrag ist bekannt -> ergänzen

      ENDLOOP. " LOOP AT lt_bsp_raw ASSIGNING <fs__bsp_raw>.

    ENDIF. " IF lt_bsp_raw IS NOT INITIAL.


  ENDDO. " Cursor für Zahlungsbudget holen
*--------------------------------------------------------------------*
* Ende: Zahlungsbudget holen
*--------------------------------------------------------------------*




*--------------------------------------------------------------------*
* Ergebnisse nachbearbeiten
*--------------------------------------------------------------------*

*--------------------------------------------*
* Info
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text = 'Ergebnisse nachbearbeiten'.
*--------------------------------------------*


* Wenn kein PoTYP ermittelt werden konnte, dann aus der Anzeige entfernen
  DELETE lt_bsp_result_sort WHERE potyp IS INITIAL.


  LOOP AT lt_bsp_result_sort ASSIGNING <fs__bsp_result_sort>.

*   Alle Finanzpositionen ermitteln, die keinen Eintrag im BSP haben
    CLEAR: lv_index.
    READ TABLE lt_fmci ASSIGNING <fs__fmci> BINARY SEARCH
        WITH KEY  fikrs   =  <fs__bsp_result_sort>-fm_area
                  gjahr   =  <fs__bsp_result_sort>-fiscyear
                  fipex   =  <fs__bsp_result_sort>-cmmtitem.
    lv_index = sy-tabix.
    IF sy-subrc = 0.
      DELETE lt_fmci INDEX lv_index.
    ENDIF.



*--
* Haben alle Finanzpositionen mit dem Finanzpositionstyp 2 oder 3 (Selektion) einen Eintrag als Buchungsträger bzw. Budgetträger


    IF <fs__bsp_result_sort>-potyp = '2' OR <fs__bsp_result_sort>-potyp = '3'.

      IF <fs__bsp_result_sort>-flag_9a_zahl_buch IS INITIAL AND <fs__bsp_result_sort>-flag_9b_verpf_buch IS INITIAL.
        <fs__bsp_result_sort>-error = 'X'.
      ENDIF.

    ENDIF.


  ENDLOOP.


* Nur Einträge mit Prüfvermerk anzeigen
  IF p_filter IS NOT INITIAL.

    DELETE lt_bsp_result_sort WHERE error IS INITIAL.

  ENDIF.
*--------------------------------------------------------------------*











* Ausgabe steuern ja Ergebnisabfrage


  IF p_delta IS NOT INITIAL.


*--------------------------------------------*
* Info
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = 'Ausgabe aufbereiten'.
*--------------------------------------------*

*--  Ausgabe 2
    TRY.
        cl_salv_table=>factory(
         EXPORTING                                                   " Zusätzlich, um eigene Funktionen zu implementieren
              list_display = if_salv_c_bool_sap=>false               " s.o.
*              r_container  = cl_gui_container=>default_screen     " s.o.
         IMPORTING
            r_salv_table   = lr_salv
         CHANGING
            t_table        = lt_fmci ).
      CATCH cx_salv_msg INTO gr_err_salv.
*     Fehler anzeigen
        gv_string = gr_err_salv->get_text( ).
        MESSAGE gv_string TYPE 'E'.
    ENDTRY.

**********************************************************************
* Anzeige Parameter setzen
**********************************************************************
*-- Selection zulassen
    go_selections = lr_salv->get_selections( ).
    go_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).


*-- events
***go_events = lr_salv->get_event( ).
***CREATE OBJECT event_handler.
***SET HANDLER event_handler->on_click FOR go_events.



*   Symbolleiste wird eingeblendet
    go_functions = lr_salv->get_functions( ).
    go_functions->set_all( abap_true ).


    go_display = lr_salv->get_display_settings( ).
    go_display->set_striped_pattern( cl_salv_display_settings=>true ).
*   GO_DISPLAY->SET_LIST_HEADER( 'Debitorenliste' ).



    go_display->set_list_header( lv_info ).


* Sortierung
    go_sorts = lr_salv->get_sorts( ).
    "gr_sorts->add_sort( 'SPALTENNAME' ).



**** Überschriften ändern
***    go_columns = lr_salv->get_columns( ).
***
**** 1. Spalte
***    go_column ?= go_columns->get_column( 'FLAG_9A_ZAHL_BUCH' ).
***    go_column->set_long_text( '9A - Zahlungsbudget Buchungsledger' ).
***    go_column->set_medium_text( '9A-Zahlung. Buchung' ).
***    go_column->set_short_text( '9A-ZahlBu' ).



* Layout (Layoutänderungen abspeicherbar)
    go_layout   = lr_salv->get_layout( ).
    key-report  = sy-repid.
    go_layout->set_key( key ).
    go_layout->set_save_restriction( cl_salv_layout=>restrict_none ).

    go_layout->set_initial_layout( '/DEFAULT_2' ).

  ENDIF. " IF p_delta IS NOT INITIAL.









  IF p_all IS NOT INITIAL.
*--------------------------------------------------------------------*
* Ausgabe vorbereiten
*--------------------------------------------------------------------*
*--------------------------------------------*
* Info
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = 'Ausgabe aufbereiten'.
*--------------------------------------------*

    REFRESH lt_bsp_result_alv.
    lt_bsp_result_alv[] = lt_bsp_result_sort[].

    FREE lt_bsp_result_sort.

*--  Ausgabe 1
    TRY.
        cl_salv_table=>factory(
         EXPORTING                                                   " Zusätzlich, um eigene Funktionen zu implementieren
              list_display = if_salv_c_bool_sap=>false               " s.o.
*              r_container  = cl_gui_container=>default_screen     " s.o.
         IMPORTING
            r_salv_table   = lr_salv
         CHANGING
            t_table        = lt_bsp_result_alv ).
      CATCH cx_salv_msg INTO gr_err_salv.
*     Fehler anzeigen
        gv_string = gr_err_salv->get_text( ).
        MESSAGE gv_string TYPE 'E'.
    ENDTRY.

**********************************************************************
* Anzeige Parameter setzen
**********************************************************************
*-- Selection zulassen
    go_selections = lr_salv->get_selections( ).
    go_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).


*-- events
***go_events = lr_salv->get_event( ).
***CREATE OBJECT event_handler.
***SET HANDLER event_handler->on_click FOR go_events.



*   Symbolleiste wird eingeblendet
    go_functions = lr_salv->get_functions( ).
    go_functions->set_all( abap_true ).


    go_display = lr_salv->get_display_settings( ).
    go_display->set_striped_pattern( cl_salv_display_settings=>true ).
*   GO_DISPLAY->SET_LIST_HEADER( 'Debitorenliste' ).



    go_display->set_list_header( lv_info ).


* Sortierung
    go_sorts = lr_salv->get_sorts( ).
    "gr_sorts->add_sort( 'SPALTENNAME' ).



* Überschriften ändern
    go_columns = lr_salv->get_columns( ).

* 1. Spalte
    go_column ?= go_columns->get_column( 'FLAG_9A_ZAHL_BUCH' ).
    go_column->set_long_text( '9A - Zahlungsbudget Buchungsledger' ).
    go_column->set_medium_text( '9A-Zahlung. Buchung' ).
    go_column->set_short_text( '9A-ZahlBu' ).

* 2. Spalte
    go_column ?= go_columns->get_column( 'FLAG_9B_VERPF_BUCH' ).
    go_column->set_long_text( '9B - Verpflichtungsbudget Buchungsledger' ).
    go_column->set_medium_text( '9B-Verpfli. Buchung' ).
    go_column->set_short_text( '9B-VerpfBu' ).


* 3. Spalte
    go_column ?= go_columns->get_column( 'FLAG_9F_ZAHL_BUDGET' ).
    go_column->set_long_text( '9F - Zahlungsbudget Budgetledger' ).
    go_column->set_medium_text( '9F-Zahlung. Budget' ).
    go_column->set_short_text( '9F-ZahlBu' ).

* 4. Spalte
    go_column ?= go_columns->get_column( 'FLAG_9G_VERPF_BUDGET' ).
    go_column->set_long_text( '9G - Verpflichtungsbudget Budgetledger' ).
    go_column->set_medium_text( '9G-Verpfli. Budget' ).
    go_column->set_short_text( '9G-VerpfBu' ).



* 5. Spalte
    go_column ?= go_columns->get_column( 'FISTL_BEZEICH' ).
    go_column->set_long_text( 'Bezeichnung Finanzstelle' ).
    go_column->set_medium_text( 'Bez. Finanzstelle' ).
    go_column->set_short_text( 'Bez. FISTL' ).


* 6. Spalte
    go_column ?= go_columns->get_column( 'ERROR' ).
    go_column->set_long_text( 'Kombination prüfen' ).
    go_column->set_medium_text( 'Kombinat. prüfen' ).
    go_column->set_short_text( 'prüfen' ).


* Layout (Layoutänderungen abspeicherbar)
    go_layout   = lr_salv->get_layout( ).
    key-report  = sy-repid.
    go_layout->set_key( key ).
    go_layout->set_save_restriction( cl_salv_layout=>restrict_none ).

    go_layout->set_initial_layout( '/DEFAULT' ).

  ENDIF. " IF p_all IS NOT INITIAL.





**********************************************************************
* Anzeige Tabelle
**********************************************************************
  lr_salv->display( ).

* "Trägerbildschirm" für Container rufen
* ist nur notwendig, da bei CL_SALV_TABLE=>FACTORY ein Container angegeben wurde
***  WRITE space.





*--------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT.
* Felder für Enduser ausblenden
*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  IF sy-tcode = '/THKR/BCS_CHECK_BSP'.
    LOOP AT SCREEN.
      IF screen-group1 = 'USR'.
        screen-invisible = '1'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

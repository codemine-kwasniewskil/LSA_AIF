*&---------------------------------------------------------------------*
*& Report /THKR/R_LSA_PSM_TABS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/R_LSA_PSM_TABS MESSAGE-ID /thkr/lsa_ta

                    LINE-COUNT 65
                    LINE-SIZE  80.
************************************************************************
* Automatischer Tagesabschluss
*
************************************************************************
* Beschreibung:
*
* Das Programm ermöglicht den batch-basierten Tagesabschluss auf Basis
* der Transaktion F845. (Tagesabschluss PSM)
*
* Dazu werden zunächst die Kassenistbestände der einzelnen Konten-
* schlüssel ermittelt. Dies erfolgt entweder durch Lesen des Endsaldos
* des letzten Kontoauszuges eines Bankkontos oder durch Lesen des
* akuellen Saldos eines Bankverrechnungskontos.
* Diese Kassenistbestände werden anschließend über das ABAP-Memory
* an den Tagesabschluss (F845) übertragen und dort gespeichert.
*
* Die Funktionalität des PSM-Tagesabschlusses wird dabei nicht
* verändert
*
************************************************************************
" 2025-02-07 jseifert   input_format 53 wurde nicht gefunden

*----------------------------------------------------------------------*
*        I N T E R N E  D A T E N F E L D E R                          *
*----------------------------------------------------------------------*

*.................. Include's für Daten und Makros ................... *

*.................. Tabellen Typen    ................................ *
TYPES: BEGIN OF ty_f845_best,
         abschlgrp TYPE fm_abschlgrp,
         psov1     TYPE psov1,
         ibest     TYPE esbtr_eb,
         waers     TYPE waers,
       END OF ty_f845_best.

*.................. interne Tabellen  ................................ *
DATA: bdcdata LIKE bdcdata OCCURS 0 WITH HEADER LINE.
DATA: lt_f845_best TYPE TABLE OF ty_f845_best.
DATA: lt_konten TYPE /THKR/T_LSA_PSM_TA.

*.................. interne Arbeitsbereiche .......................... *
DATA:
*      lf_f845_cust  TYPE zfi_cu_ta_f845,
  lf_f845_best  TYPE ty_f845_best,
  lf_febko      TYPE febko,
  lf_skb1       TYPE skb1,
  lf_balance    LIKE bapi1028_3,
  lf_return     LIKE bapireturn,
  ls_konten     TYPE /THKR/s_LSA_PSM_TA,
  ls_pso23      TYPE pso23,
  l_msg         TYPE char20,
  lt_param_f845 TYPE rsparams_tt,
  ls_param_f845 TYPE rsparams.

*.................. globale Variablen ................................ *
*DATA: g_map LIKE apqi-groupid.
DATA:
*      g_count TYPE num02,
  g_cnt TYPE num03,
  g_sum TYPE wrbtr.

*.................. lokale Variablen ................................ *
*********************************
DATA: l_bukrs TYPE bukrs,
      l_line  TYPE string.
*      l_ibest TYPE string,
*      lines   TYPE i,
*      l_anz   TYPE i,
*      anz_15  TYPE i,
*      mod_15  TYPE i.


*.................. Konstanten....... ................................ *
CONSTANTS:
*  c_nodata    TYPE char1 VALUE '/',
  c_std_waers TYPE char3 VALUE 'EUR'.

*----------------------------------------------------------------------*


SELECTION-SCREEN: BEGIN OF BLOCK def WITH FRAME TITLE TEXT-001.
  PARAMETERS:
*----- Abschlussgruppe
    p_abgru LIKE fmpso_tagrp-abschlgrp OBLIGATORY DEFAULT 'LHK',
*----- Buchungstag
    p_aktbt LIKE bkpf-psobt. " OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK def.
SELECTION-SCREEN: BEGIN OF BLOCK mod WITH FRAME TITLE TEXT-002.
  PARAMETERS:
*----- Abschluss durchführen
*    p_abschl AS CHECKBOX DEFAULT 'X',
*    p_konten AS CHECKBOX DEFAULT ' '.
    p_abschl RADIOBUTTON GROUP ta DEFAULT 'X',
    p_konten RADIOBUTTON GROUP ta.
SELECTION-SCREEN: END OF BLOCK mod.

*&---------------------------------------------------------------------*
INITIALIZATION.
*&---------------------------------------------------------------------*

*  GET PARAMETER ID 'ABSCHLGRP' FIELD p_abgru.

* Aktuellen Buchungstag vorbelegen
  PERFORM init_param.

*&---------------------------------------------------------------------*
START-OF-SELECTION.
*&---------------------------------------------------------------------*

  PERFORM init_param.

  IF p_abschl IS INITIAL.
    WRITE /.
    WRITE AT /5 TEXT-024.
    IF p_konten IS INITIAL.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_abgru  IS INITIAL.
    WRITE /.
    WRITE AT /5 TEXT-023.
    RETURN.
  ENDIF.
  IF p_aktbt IS INITIAL.
    WRITE /.
    WRITE AT /5 TEXT-022.
    RETURN.
  ENDIF.

* zu Kontenschlüssel (Verdichtungsgruppen), Bankdaten und Sachkonten zusammenstellen
* ersetzt Tabelle zfi_cu_ta_f845

  SELECT f~abschlgrp, p~psov_art, p~psov1, s~bukrs, s~saknr, t~hbkid, t~hktid
    FROM pso23 AS p
      INNER JOIN pso26 AS s ON p~psov1   = s~psov1
                           AND s~tabtype = 'B'
      INNER JOIN fmpso_zgrp AS f ON f~bukrs = s~bukrs
      LEFT OUTER JOIN t012k AS t ON t~hkont = s~saknr
                           AND t~bukrs = s~bukrs
    ORDER BY p~psov_art, p~psov1, s~bukrs
    INTO CORRESPONDING FIELDS OF TABLE @lt_konten.

**  IF p_konten = 'X' AND p_abschl IS INITIAL.
**    WRITE /.
**    WRITE AT /5 TEXT-025.
**
**    SORT lt_konten BY psov_art psov1 bukrs.
**    LOOP AT lt_konten ASSIGNING FIELD-SYMBOL(<k>).
**      WRITE: AT /5 <k>-abschlgrp, <k>-psov_art, <k>-psov1, <k>-bukrs,
**                   <k>-hbkid, <k>-hktid, <k>-saknr.
**    ENDLOOP.
**    RETURN.
**  ENDIF.

  IF p_konten = 'X'.
    WRITE /.
    WRITE: AT /5 TEXT-025, p_aktbt COLOR 4, space.
    WRITE /.
  ENDIF.

  IF p_abschl = 'X'.
    WRITE /.
* Automatischer Tagesabschluss wurde gestartet für den: xx.xx.xxxx
    WRITE: AT /7 TEXT-010, p_aktbt COLOR 4, space.
    WRITE /.
  ENDIF.

  LOOP AT lt_konten ASSIGNING FIELD-SYMBOL(<ko>).
*   Lesen der Kassenistbestände je Kontenschlüssel
    CLEAR lf_f845_best.
    MOVE-CORRESPONDING <ko> TO lf_f845_best.
    MOVE c_std_waers TO lf_f845_best-waers.
    MOVE lf_f845_best-psov1 TO l_line.
    WRITE: AT /7 TEXT-003, l_line COLOR 4. "Kontenschlüssel

*   Wenn Bankkonto, dann Lesen aus letztem FEBKO MT940
    IF  <ko>-bukrs IS NOT INITIAL
    AND <ko>-hbkid IS NOT INITIAL
    AND <ko>-hktid IS NOT INITIAL.

      SELECT * FROM febko
      WHERE  anwnd = '0001'
      AND    bukrs = @<ko>-bukrs
      AND    hbkid = @<ko>-hbkid
      AND    hktid = @<ko>-hktid
      AND    ( input_format IS INITIAL OR input_format = '53' )  " 2025-02-07 jseifert
      ORDER BY kukey DESCENDING
      INTO @lf_febko.
        EXIT.
      ENDSELECT.
      IF sy-subrc = 0.
        MOVE lf_febko-esbtr TO lf_f845_best-ibest.
        IF lf_febko-esvoz = 'S'. "Soll
          MULTIPLY lf_f845_best-ibest BY -1.
        ENDIF.
        MOVE lf_febko-waers TO lf_f845_best-waers.
*   Protokollausgabe
        WRITE: AT /10 TEXT-006, lf_febko-hbkid,
                                lf_febko-hktid, lf_febko-aznum,
                                '(', lf_febko-kukey, ')'.
        "Gelesen aus Kontoauszug
      ELSE.
*   Fehlerausgabe
        CONCATENATE '(' <ko>-saknr '/' <ko>-bukrs ')' INTO l_msg.
        WRITE: AT /10 TEXT-007, <ko>-hbkid,
                                <ko>-hktid,
                                l_msg.
        "Fehler beim Lesen aus Kontoauszug
        "Neu: Kein Kontoauszug vorhanden
      ENDIF.
    ENDIF.

*   Wenn Sachkonto, dann Lesen des aktuellen Saldos...
    IF <ko>-hbkid IS INITIAL AND
       <ko>-hktid IS INITIAL AND
       <ko>-psov_art(1) <> 'B' AND
       <ko>-saknr IS NOT INITIAL.
*     ... für genau einen Buchungskreis
      IF  <ko>-bukrs IS NOT INITIAL.
        l_bukrs = <ko>-bukrs.
*     ... über alle Buchungskreise
      ELSE.
        l_bukrs = '%'.
      ENDIF.

      SELECT * FROM skb1 INTO lf_skb1
      WHERE bukrs LIKE l_bukrs
      AND   saknr = <ko>-saknr
      ORDER BY PRIMARY KEY.

        CLEAR: lf_balance, lf_return.
        CALL FUNCTION 'BAPI_GL_GETGLACCCURRENTBALANCE'
          EXPORTING
            companycode     = lf_skb1-bukrs
            glacct          = <ko>-saknr
            currencytype    = '10'
          IMPORTING
            account_balance = lf_balance
            return          = lf_return.
        IF lf_return IS INITIAL.
          ADD lf_balance-balance TO lf_f845_best-ibest.
          MOVE lf_balance-currency TO lf_f845_best-waers.
*   Protokollausgabe
          WRITE: AT /10 TEXT-008, lf_skb1-saknr NO-GAP, '/' NO-GAP,
                                  lf_skb1-bukrs,
                        TEXT-009, lf_balance-fisc_year.
          "Gelesen aus Sachkontensaldo ... im Jahr ...
        ELSE.
*   Meldungsausgabe lf_return
          WRITE AT /10 lf_return-type.
          WRITE AT 12 lf_return-message.
          "Info oder Fehler beim Lesen aus Sachkonto
        ENDIF.
      ENDSELECT.

    ENDIF.
    APPEND lf_f845_best TO lt_f845_best.
*   Protokollausgabe
    WRITE AT /7 TEXT-004.                   "Kassenistbestand
    WRITE: AT 35 lf_f845_best-ibest COLOR 4 CURRENCY lf_f845_best-waers,
                 lf_f845_best-waers.
    WRITE /.

  ENDLOOP.


  LOOP AT lt_f845_best INTO lf_f845_best.

*   Protokoll-Summen
    g_cnt = g_cnt + 1.
    g_sum = g_sum + lf_f845_best-ibest.

  ENDLOOP.

* Tagesabschluss starten
  IF p_abschl = 'X'.

    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal            = p_aktbt
      IMPORTING
        date_external            = l_line
      EXCEPTIONS
        date_internal_is_invalid = 0
        OTHERS                   = 0.

* In ECC 6.0 wird der nächste Buchungstag nicht mehr automatisch gefüllt
    DATA: l_facid  TYPE wfcid,
          ls_tagrp TYPE fmpso_tagrp,
          l_nxtbt  TYPE psobt,
          l_next   TYPE string.

    SELECT SINGLE * FROM fmpso_tagrp
    INTO ls_tagrp  " FabrikKalenderID
    WHERE abschlgrp = p_abgru.

*--- nächsten Buchungstag ermitteln
    CALL FUNCTION 'END_TIME_DETERMINE'
      EXPORTING
        duration         = 1
        factory_calendar = ls_tagrp-facid
      IMPORTING
        end_date         = l_nxtbt
      CHANGING
        start_date       = p_aktbt
      EXCEPTIONS
        OTHERS           = 1.
*  IF sy-subrc = 0.
*    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*      EXPORTING
*        date_internal            = l_nxtbt
*      IMPORTING
*        date_external            = l_next
*      EXCEPTIONS
*        date_internal_is_invalid = 0
*        OTHERS                   = 0.
*  ENDIF.

* Programm RFFMFITABS aufrufen
* ohne Vorgabe 'SO_FIKRS' und 'SO_BUKRS' - werden im Programm ermittelt!
    CLEAR ls_param_f845.
    ls_param_f845-selname = 'P_ABGR'.
    ls_param_f845-kind    = 'P'.
    ls_param_f845-low     = p_abgru.
    APPEND ls_param_f845 TO lt_param_f845.
    ls_param_f845-selname = 'P_AKTBT'.
    ls_param_f845-kind    = 'P'.
    ls_param_f845-low     = p_aktbt.
    APPEND ls_param_f845 TO lt_param_f845.
    ls_param_f845-selname = 'P_PREBT'.
    ls_param_f845-kind    = 'P'.
    ls_param_f845-low     = ls_tagrp-psobt_vor.
    APPEND ls_param_f845 TO lt_param_f845.
    ls_param_f845-selname = 'P_NXTBT'.
    ls_param_f845-kind    = 'P'.
    ls_param_f845-low     = l_nxtbt. "l_next.
    APPEND ls_param_f845 TO lt_param_f845.
    ls_param_f845-selname = 'P_ABSCHL'.
    ls_param_f845-kind    = 'P'.
    ls_param_f845-low     = 'X'.
    APPEND ls_param_f845 TO lt_param_f845.
    ls_param_f845-selname = 'P_ANZ'.
    ls_param_f845-kind    = 'P'.
    ls_param_f845-low     = ' '.
    APPEND ls_param_f845 TO lt_param_f845.

* Tabelle der Bestände exportieren
    EXPORT lt_best FROM lt_f845_best TO MEMORY ID 'F845_BEST'.

* Tagesabschluss aufrufen
    SUBMIT rffmfitabs WITH SELECTION-TABLE lt_param_f845 AND RETURN.

    COMMIT WORK.
    IF sy-subrc <> 0.
      WRITE: AT /3 '!    ', TEXT-018.  "Fehler bei COMMIT WORK
      WRITE: AT /3 '!    ', TEXT-005.  "Abbruch der Verarbeitung
      ROLLBACK WORK.
    ENDIF.

  ENDIF.

  WRITE AT /7 TEXT-016.
  WRITE AT 54 g_cnt.
  WRITE AT /7 TEXT-017.
  WRITE: AT 41 g_sum COLOR 4 CURRENCY lf_f845_best-waers,
               lf_f845_best-waers.


*&---------------------------------------------------------------------*
*& Form init_param
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_param .

  DATA: l_count TYPE i,
        l_tagrp TYPE fmpso_tagrp,
        l_aktbt TYPE dats.

  l_aktbt = p_aktbt.

  IF NOT p_abgru IS INITIAL.

    SELECT SINGLE psobt FROM fmpso_tagrp
    INTO p_aktbt
    WHERE abschlgrp = p_abgru.

  ELSE.

    SELECT COUNT(*) FROM fmpso_tagrp INTO l_count.
    IF l_count = 1.
      SELECT SINGLE * FROM fmpso_tagrp INTO l_tagrp.
      IF sy-subrc = 0.
        p_abgru = l_tagrp-abschlgrp.
        p_aktbt = l_tagrp-psobt.
      ENDIF.
    ENDIF.

  ENDIF.

  IF l_aktbt <> p_aktbt AND l_aktbt IS NOT INITIAL.
    CLEAR p_aktbt.
  ENDIF.

ENDFORM.

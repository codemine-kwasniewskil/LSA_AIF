FUNCTION z_fi_bn_bte_ev_00001040.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_XVBUP) LIKE  OFIWA-XVBUP DEFAULT 'X'
*"     REFERENCE(I_RF05R) LIKE  RF05R STRUCTURE  RF05R
*"  TABLES
*"      T_XRAGL STRUCTURE  RAGL1
*"----------------------------------------------------------------------
* Folgende Frage ist zu klären:
* wird das Gjahr von der Zahlung für einzelne Fälle gebraucht
* wird der Ausgleichsbeleg für einzelne Fälle gebraucht
*----------------------------------------------------------------------
* Änderung REPRO-GANZ 17.08.2022  Solman 2000002717
* Bei Zahlungsanzeigen dürfen, bei Aufnahme eines 210er Eintrages,
* die bestehnden Einträge nicht gelöscht werden, damit der Sacharbeiter
* alle Zahlungsanzeigen(PDF) später noch einsehen kann.
*----------------------------------------------------------------------
  CONSTANTS:
    c_on     TYPE xfeld VALUE 'X',
    c_off    TYPE xfeld VALUE ' ',
    c_char_y TYPE xfeld VALUE 'Y',
    c_f_200  TYPE char03 VALUE '200',
    c_f_201  TYPE char03 VALUE '201',
    c_f_211  TYPE char03 VALUE '211',
    c_f_210  TYPE char03 VALUE '210'.

  FIELD-SYMBOLS: <fs_nachricht>   TYPE zfi_bn_nachricht.
  DATA: ls_bn_nachricht TYPE zfi_bn_nachricht.

  DATA: lt_bn_nachricht TYPE STANDARD TABLE OF  zfi_bn_nachricht.
  DATA: lt_bn_nachricht_del TYPE STANDARD TABLE OF  zfi_bn_nachricht.

  IF i_rf05r-bvorg IS NOT INITIAL.
    SELECT * FROM zfi_bn_nachricht INTO TABLE lt_bn_nachricht
     WHERE herk     = c_char_y
     AND (  fehlernr =  c_f_200 OR
            fehlernr =  c_f_201 )
     AND   bvorg   = i_rf05r-bvorg
     AND   inaktiv = c_off.

  ELSE.
    IF t_xragl[] IS NOT INITIAL.
      SELECT * FROM zfi_bn_nachricht INTO TABLE lt_bn_nachricht
        FOR ALL ENTRIES IN t_xragl
         WHERE herk     = c_char_y
         AND (  fehlernr =  c_f_200 OR fehlernr =  c_f_201 )
         AND  bukrs   = t_xragl-bukrs
         AND  ( vblnr   = t_xragl-belnr  OR  belnr = t_xragl-belnr )
         AND   gjahr   = t_xragl-gjahr
         AND   inaktiv = c_off.
    ENDIF.
  ENDIF.

  CHECK lt_bn_nachricht[] IS NOT INITIAL.

*----------------------------------------------------------------------
* Änderung der Nachrichtentabelle:
*----------------------------------------------------------------------

  LOOP AT lt_bn_nachricht ASSIGNING <fs_nachricht> WHERE ( fehlernr = c_f_200   OR  fehlernr = c_f_201 ).
*--------------------------------------------------------------------------
* ohne VERSDAT --> Löschen
*--------------------------------------------------------------------------
    IF <fs_nachricht>-versdat IS INITIAL.
      ls_bn_nachricht =  <fs_nachricht>.
      APPEND ls_bn_nachricht TO lt_bn_nachricht_del.
      DELETE lt_bn_nachricht .
*--------------------------------------------------------------------------
* neuer Satz anlegen falls notwendig
* Laut Testdokument 09/2020 Lauf 2-3
* ursprünglicher Satz gelöscht, Satz mit Fehlernummer 210 oder 211  und Betrag*(-1)
* erscheint (keine Nutzung von "inaktiv")
*--------------------------------------------------------------------------
    ELSE.

*      <fs_nachricht>-inaktiv = c_on.
*      modify lt_bn_nachricht from <fs_nachricht> transporting inaktiv.
***** begin REPRO-GANZ 17.08.2022  Solman 2000002717
*     nicht löschen bei Zahlungsanzeigen
      ls_bn_nachricht =  <fs_nachricht>.
      IF <fs_nachricht>-herk <> c_char_y.
* Originalsatz löschen
        APPEND ls_bn_nachricht TO lt_bn_nachricht_del.
      ENDIF.
***** end REPRO-GANZ 17.08.2022  Solman 2000002717

*--------------------------------------------------------------------------
* neuer Satz anlegen falls notwendig
*--------------------------------------------------------------------------
      CLEAR: ls_bn_nachricht-bnkey.
      CLEAR: ls_bn_nachricht-versdat,
             ls_bn_nachricht-verstim,
             ls_bn_nachricht-kzbnart,
             ls_bn_nachricht-empf,
             ls_bn_nachricht-bnwdh,
             ls_bn_nachricht-inaktiv.
      IF ls_bn_nachricht-fehlernr =  c_f_200.
        ls_bn_nachricht-fehlernr =  c_f_210.
      ELSEIF ls_bn_nachricht-fehlernr =  c_f_201.
        ls_bn_nachricht-fehlernr =  c_f_211.
      ENDIF.

      ls_bn_nachricht-wrbtr =  ls_bn_nachricht-wrbtr * ( -1 ).
      MODIFY lt_bn_nachricht FROM ls_bn_nachricht .
    ENDIF.
  ENDLOOP.
*--------------------------------------------------------------------------
* UPDATE
*--------------------------------------------------------------------------
  IF lt_bn_nachricht[] IS NOT INITIAL OR lt_bn_nachricht_del[] IS NOT INITIAL.
    CALL FUNCTION 'Z_FI_BN_NACHRICHT_UPDATE' IN UPDATE TASK
      TABLES
        t_fi_bn_nachricht     = lt_bn_nachricht
        t_fi_bn_nachricht_del = lt_bn_nachricht_del
* EXCEPTIONS
*       FEHLER                = 1
*       OTHERS                = 2
      .
* bei update task - gibt es keine Rückmeldung
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.


ENDFUNCTION.

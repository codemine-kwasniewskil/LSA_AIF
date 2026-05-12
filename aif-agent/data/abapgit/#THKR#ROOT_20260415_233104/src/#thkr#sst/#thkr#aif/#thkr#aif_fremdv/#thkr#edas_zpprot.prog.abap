*&---------------------------------------------------------------------*
*& Report /THKR/EDAS_ZPPROT
*&---------------------------------------------------------------------*
*& Maximilian Kleissl
*&---------------------------------------------------------------------*
REPORT /thkr/edas_zpprot.

DATA:
  lt_table  TYPE TABLE OF string,
  lv_datum  TYPE sy-datum,
  lv_sytime TYPE t,
  lv_time   TYPE char8.

lv_datum = |{ sy-datum DATE = USER }|.
lv_sytime = sy-uzeit.
lv_time = |{ lv_sytime+0(2) }:{ lv_sytime+2(2) }:{ lv_sytime+4(2) }|.

APPEND '' TO lt_table.
APPEND '' TO lt_table.
APPEND |    Datum: { lv_datum } { lv_time }   Datenbank: SAP| TO lt_table.
APPEND '' TO lt_table.
APPEND '    Verarbeitungsprotokoll des Abgleichs der ZP-Daten' TO lt_table.
APPEND '    -------------------------------------------------' TO lt_table.

APPEND '' TO lt_table.
PERFORM add_number_of_cases_info USING '1. Korrektur der vorhandenen ZP' '' 12087.
PERFORM add_number_of_cases_info USING '2. Deaktivieren vorhandener ZP' '' 1.
PERFORM add_number_of_cases_info USING '3. Aufnahme neuer ZP' '' 4.
PERFORM add_number_of_cases_info USING '4. Eintrag des Vermerks "SEPA-Bankverbindung geprueft"' 'bei ZP mit vorhandener SEPA-Bankverbindung' 1.
PERFORM add_number_of_cases_info USING '5. Eintrag des Vermerks "Bankverbindung mit BLZ geprueft"' 'bei ZP mit vorhandener Bankverbindung ohen SEPA' 1.
PERFORM add_number_of_cases_info USING '6. Eintrag der Bankbezeichnung laut Bankleitzahlen-Tabelle' '' 0.
PERFORM add_number_of_cases_info USING '7. Listung der ZP mit Bankleitzahl und ohne Bankbezeichnung' '' 0.
APPEND |    8. Liste der { 0 WIDTH = 3 ALIGN = RIGHT } ungültigen Postleitzahl-Ort-Kombinationen| TO lt_table.
APPEND '' TO lt_table.
APPEND '' TO lt_table.
APPEND |    Ende des Protokolls zum Zahlungspartner-Abgleich : { lv_datum }; { lv_time }| TO lt_table.
APPEND '' TO lt_table.

LOOP AT lt_table INTO DATA(ls_result).
  WRITE: / ls_result.
ENDLOOP.

FORM add_number_of_cases_info USING p_art1 TYPE string
                                    p_art2 TYPE string
                                    p_anzahl TYPE i.
  APPEND |    { p_art1 }| TO lt_table.
  APPEND '' TO lt_table.
  IF p_art2 <> ''.
    APPEND |       { p_art2 }| TO lt_table.
  ENDIF.
  APPEND |       Anzahl der Faelle : { p_anzahl }| TO lt_table.
  APPEND '' TO lt_table.
  APPEND '' TO lt_table.
ENDFORM.

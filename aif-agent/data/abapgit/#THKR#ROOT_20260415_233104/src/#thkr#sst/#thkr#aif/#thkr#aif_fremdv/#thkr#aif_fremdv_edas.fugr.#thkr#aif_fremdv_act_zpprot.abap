FUNCTION /thkr/aif_fremdv_act_zpprot.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C OPTIONAL
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_AIF_EDAS_ZP OPTIONAL
*"     REFERENCE(LINE) OPTIONAL
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG OPTIONAL
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG OPTIONAL
*"----------------------------------------------------------------------


  DATA: lt_table            TYPE TABLE OF string,
        lv_ns               TYPE /aif/ns,
        lv_ifname           TYPE /aif/ifname,
        lv_ifversion        TYPE /aif/ifversion,
        lv_logical_filename TYPE filename-fileintern,
        lo_protokoll        TYPE REF TO /thkr/cl_aif_file_basics,
        lt_adrc             TYPE TABLE OF adrc,
        lv_output_filename  TYPE string,
        lv_sytime           TYPE t,
        lv_time             TYPE char8.

  DATA(lv_datum) = |{ sy-datum DATE = USER }|.
  lv_sytime = sy-uzeit.
  lv_time = |{ lv_sytime+0(2) }:{ lv_sytime+2(2) }:{ lv_sytime+4(2) }|.

  APPEND '' TO lt_table.
  APPEND '' TO lt_table.
  APPEND |    Datum: { lv_datum } { lv_time }   Datenbank: SAP| TO lt_table.
  APPEND '' TO lt_table.
  APPEND '    Verarbeitungsprotokoll des Abgleichs der ZP-Daten' TO lt_table.
  APPEND '    -------------------------------------------------' TO lt_table.

  APPEND '' TO lt_table.

  DATA(lv_count_update) = 0.
  DATA(lv_count_insert) = 0.

  LOOP AT data-gp INTO DATA(ls_row).
    IF ls_row-bp_action = 'U'.
      lv_count_update += 1.
    ENDIF.
    IF ls_row-bp_action = 'I'.
      lv_count_insert += 1.
    ENDIF.
  ENDLOOP.
  PERFORM add_number_of_cases_info USING '1. Korrektur der vorhandenen ZP' '' lv_count_update lt_table.
  PERFORM add_number_of_cases_info USING '2. Deaktivieren vorhandener ZP' '' 0 lt_table.
  PERFORM add_number_of_cases_info USING '3. Aufnahme neuer ZP' '' lv_count_insert lt_table.
  PERFORM add_number_of_cases_info USING '4. Eintrag des Vermerks "SEPA-Bankverbindung geprueft"' 'bei ZP mit vorhandener SEPA-Bankverbindung' 0 lt_table.
  PERFORM add_number_of_cases_info USING '5. Eintrag des Vermerks "Bankverbindung mit BLZ geprueft"' 'bei ZP mit vorhandener Bankverbindung ohen SEPA' 0 lt_table.
  PERFORM add_number_of_cases_info USING '6. Eintrag der Bankbezeichnung laut Bankleitzahlen-Tabelle' '' 0 lt_table.
  PERFORM add_number_of_cases_info USING '7. Listung der ZP mit Bankleitzahl und ohne Bankbezeichnung' '' 0 lt_table.
  APPEND |    8. Liste der { 0 WIDTH = 3 ALIGN = RIGHT } ungültigen Postleitzahl-Ort-Kombinationen| TO lt_table.
  APPEND '' TO lt_table.
  APPEND '' TO lt_table.
  APPEND |    Ende des Protokolls zum Zahlungspartner-Abgleich : { lv_datum }; { lv_time }| TO lt_table.
  APPEND '' TO lt_table.

  LOOP AT lt_table INTO DATA(ls_result).
    WRITE: / ls_result.
  ENDLOOP.

  CREATE OBJECT lo_protokoll.

  CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
    IMPORTING
      ns     = lv_ns
      ifname = lv_ifname
      ifversion = lv_ifversion.

  lv_logical_filename = |/THKR/AIF_{ lv_ifname }_ZPPROT|.
  DATA(lv_date) = sy-datum.
  DATA(lv_datumJJMMDD) = lv_date+2(2) && lv_date+4(2) && lv_date+6(2).
  DATA(lv_dateiname) = |zpprot_{ lv_datumJJMMDD }.txt|.
  lv_output_filename = lo_protokoll->get_filepath( iv_logical_filename = lv_logical_filename iv_filename = lv_dateiname ).

  CALL METHOD lo_protokoll->write_and_send_file
    EXPORTING
      iv_output_filename = lv_output_filename
      it_rows            = lt_table[]
      iv_ns              = lv_ns
      iv_ifname          = lv_ifname
      iv_ifversion       = lv_ifversion
      iv_eol             = conv string( cl_abap_char_utilities=>newline )
    CHANGING
      cv_success         = success
      ct_return_tab      = return_tab[].


ENDFUNCTION.

FORM add_number_of_cases_info USING p_art1 TYPE string
                                    p_art2 TYPE string
                                    p_anzahl TYPE i
                            CHANGING lt_table TYPE string_table.
  APPEND |    { p_art1 }| TO lt_table.
  APPEND '' TO lt_table.
  IF p_art2 <> ''.
    APPEND |       { p_art2 }| TO lt_table.
  ENDIF.
  APPEND |       Anzahl der Faelle : { p_anzahl }| TO lt_table.
  APPEND '' TO lt_table.
  APPEND '' TO lt_table.
ENDFORM.

FUNCTION /thkr/aif_fremdv_act_zahl_ein.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/T_ZAHL_EIN
*"     REFERENCE(LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------


  DATA: lt_table            TYPE TABLE OF string,
        lv_ns               TYPE /aif/ns,
        lv_ifname           TYPE /aif/ifname,
        lv_ifversion        TYPE /aif/ifversion,
        lv_logical_filename TYPE filename-fileintern,
        lo_protokoll        TYPE REF TO /thkr/cl_aif_file_basics,
        lv_buchungsart      TYPE char3,
        lv_output_filename  TYPE string.


  ASSIGN data TO FIELD-SYMBOL(<ls_data>).

  LOOP AT <ls_data> INTO DATA(ls_beleg).
    APPEND ls_beleg-kassenzeichen+3(7)  TO lt_table. "Betriebsnummer
    APPEND ls_beleg-kassenzeichen+12(4) TO lt_table. "Erhebungsjahr
    CASE ls_beleg-kassenzeichen+11(1).
      WHEN '-'.
        lv_buchungsart = '210'.
      WHEN 'S'.
        lv_buchungsart = '220'.
      WHEN 'Z'.
        lv_buchungsart = '230'.
      WHEN OTHERS.
        " TODO FEHLER WERFEN
        lv_buchungsart = '000'.
    ENDCASE.
    APPEND lv_buchungsart TO lt_table. "Buchungsart
    APPEND lv_buchungsart+ls_beleg-buchungsschluessel TO lt_table. "Buchungsschlüssel
    APPEND ls_beleg-einzahlungsdatum TO lt_table. "Einzahlungsdatum
    APPEND ls_beleg-kassenzeichen TO lt_table. "Einzahlungsbeleg
    APPEND ls_beleg-betrag * 100 TO lt_table. "Betrag
    APPEND 'EUR' TO lt_table. "Währung
    APPEND '%%__WP_SATZ_ENDE__%%' TO lt_table. "Satzende
  ENDLOOP.

  CREATE OBJECT lo_protokoll.

  CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
    IMPORTING
      ns     = lv_ns
      ifname = lv_ifname
      ifversion = lv_ifversion.

  lv_logical_filename = |/THKR/AIF_{ lv_ifname }_ASC|.
  DATA(lv_datum) = sy-datum+2(2) && sy-datum+4(2) && sy-datum+6(2).
  DATA(lv_dateiname) = |zahl_ein_{ lv_datum }.asc|.
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

*"----------------------------------------------------------------------
* Maximilian Kleissl  tsi  4.9.2024
*"----------------------------------------------------------------------
* action erstellt APN Protokoll
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_apn .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_AIF_SAP
*"     REFERENCE(CURR_LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  DATA: lt_table                    TYPE TABLE OF string,
        lt_apn_zeilen               TYPE /thkr/t_apn_zeilen,
        lv_last_buchungstyp         TYPE string,
        lv_anzahl_zeilen            TYPE i,
        lv_anzahl_zeilen_fehlerhaft TYPE i,
        lt_result_per_btyp          TYPE /thkr/cl_aif_file_basics=>ty_t_result_per_btyp,
        lv_output_filename          TYPE string,
        lv_ns                       TYPE /AIF/ns,
        lv_ifname                   TYPE /aif/ifname,
        lv_ifversion                TYPE /aif/ifversion,
        lv_logical_filename         TYPE filename-fileintern,
        lo_protokoll                TYPE REF TO /thkr/cl_aif_file_basics.

  APPEND VALUE #( id         = 'KM'
              number     = 418
              type       = 'I'
              message_v1 = '/THKR/AIF_ZALLGE_ACT_APN' ) TO return_tab.

  ASSIGN data TO FIELD-SYMBOL(<ls_data>).

  CREATE OBJECT lo_protokoll.

  "Einmal durch die Verarbeitungszeilen gehen und Statistischen Daten ermitteln
  lt_apn_zeilen = lo_protokoll->set_apn_status(
                    EXPORTING
                      it_apn_zeilen = <ls_data>-apn_zeilen
                      is_data         = <ls_data>
                    IMPORTING
                      ev_failed_records  = Lv_anzahl_zeilen_fehlerhaft
                      ev_count_records   = Lv_anzahl_zeilen
                      et_result_per_btyp = lt_result_per_btyp
                  ).

  CLEAR lt_table.
* Header
  lo_protokoll->create_apn_header(
    EXPORTING
      is_apn_header     = <ls_data>-apn_kopf
      iv_failed_records = Lv_anzahl_zeilen_fehlerhaft
      iv_count_records  = Lv_anzahl_zeilen
      iv_filename       =  <ls_data>-common-dateiname
      iv_beginn_datum   = <ls_data>-common-beginndatum
      iv_beginn_uzeit   = <ls_data>-common-beginnuzeit
    CHANGING
      ct_prot_table     = lt_table                 " Tabelle von Strings
  ).


* Body
  "AO-Nummern aus Verarbeitung ermitteln (1. und letzte).
  lo_protokoll->get_apn_get_number_ranges( is_data = <ls_data> ).
  lo_protokoll->create_apn_body(
    EXPORTING
      it_result_per_btyp = lt_result_per_btyp
    CHANGING
      ct_prot_table      = lt_table                 " Tabelle von Strings
  ).

* Footer
  lo_protokoll->create_apn_footer(
    EXPORTING
      iv_beginn_datum = <ls_data>-common-beginndatum
      iv_beginn_uzeit = <ls_data>-common-beginnuzeit                 " Zeitpunkt im CHAR-Format
      iv_filename     =  <ls_data>-common-dateiname
    CHANGING
      ct_prot_table   = lt_table                 " Tabelle von Strings
  ).



  CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
    IMPORTING
      ns        = lv_ns
      ifname    = lv_ifname
      ifversion = lv_ifversion.

  Lv_logical_filename = |/THKR/AIF_{ lv_ifname }_APN|.
  lv_output_filename = lo_protokoll->get_filepath( iv_logical_filename = lv_logical_filename iv_filename = CONV string( <ls_data>-common-dateiname ) ).

  " ifname pattern I_NNNN_VVV — offset 2 length 4 gives the interface number
  DATA(lv_dienstnr) = COND char4(
    WHEN lv_ifname+2(4) = '0008'
      OR lv_ifname+2(4) = '0009'
      OR lv_ifname+2(4) = '0010'
    THEN <ls_data>-apn_kopf-dienststelle ).

  CALL METHOD lo_protokoll->write_and_send_file
    EXPORTING
      iv_output_filename = lv_output_filename
      it_rows            = lt_table[]
      iv_ns              = lv_ns
      iv_ifname          = lv_ifname
      iv_ifversion       = lv_ifversion
      iv_width           = 80
      iv_eol             = CONV string( cl_abap_char_utilities=>newline )
      iv_rec_tabname     = COND #( WHEN lv_dienstnr IS NOT INITIAL THEN '/THKR/T_AIF_REC' )
      iv_keyfield        = COND #( WHEN lv_dienstnr IS NOT INITIAL THEN 'DIENSTNR' )
      iv_keyvalue        = lv_dienstnr
    CHANGING
      cv_success         = success
      ct_return_tab      = return_tab[].

ENDFUNCTION.

FUNCTION /thkr/aif_fremdv_act_send_dept .
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

  DATA: lt_apn_table                TYPE STRING_TABLE,
        lt_csv_rows                 TYPE STRING_TABLE,
        lt_apn_zeilen               TYPE /thkr/t_apn_zeilen,
        lv_anzahl_zeilen            TYPE i,
        lv_anzahl_zeilen_fehlerhaft TYPE i,
        lt_result_per_btyp          TYPE /thkr/cl_aif_file_basics=>ty_t_result_per_btyp,
        lv_output_filename          TYPE string,
        lv_ns                       TYPE /aif/ns,
        lv_ifname                   TYPE /aif/ifname,
        lv_ifversion                TYPE /aif/ifversion,
        lv_logical_filename         TYPE filename-fileintern,
        lv_dienstnr                 TYPE char4,
        lo_protokoll                TYPE REF TO /thkr/cl_aif_file_basics.

  APPEND VALUE #( id         = 'KM'
                  number     = 418
                  type       = 'I'
                  message_v1 = '/THKR/AIF_FREMDV_ACT_SEND_DEPT' ) TO return_tab.

  ASSIGN data TO FIELD-SYMBOL(<ls_data>).

  IF <ls_data> IS NOT ASSIGNED OR <ls_data> IS INITIAL.
    APPEND VALUE #( id = '/THKR/SST' number = 0 type = 'E' ) TO return_tab.
    RETURN.
  ENDIF.

  IF <ls_data>-apn_zeilen IS INITIAL AND <ls_data>-lst IS INITIAL.
    success = 'Y'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_protokoll.
  lv_dienstnr = <ls_data>-bic_struc-header-dienstnr.

  CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
    IMPORTING
      ns        = lv_ns
      ifname    = lv_ifname
      ifversion = lv_ifversion.

  " ─── APN file ───────────────────────────────────────────────────────
  IF <ls_data>-apn_zeilen IS NOT INITIAL.
    lt_apn_zeilen = lo_protokoll->set_apn_status(
      EXPORTING
        it_apn_zeilen      = <ls_data>-apn_zeilen
        is_data            = <ls_data>
      IMPORTING
        ev_failed_records  = lv_anzahl_zeilen_fehlerhaft
        ev_count_records   = lv_anzahl_zeilen
        et_result_per_btyp = lt_result_per_btyp ).

    lo_protokoll->create_apn_header(
      EXPORTING
        is_apn_header     = <ls_data>-apn_kopf
        iv_failed_records = lv_anzahl_zeilen_fehlerhaft
        iv_count_records  = lv_anzahl_zeilen
        iv_filename       = <ls_data>-common-dateiname
        iv_beginn_datum   = <ls_data>-common-beginndatum
        iv_beginn_uzeit   = <ls_data>-common-beginnuzeit
      CHANGING
        ct_prot_table     = lt_apn_table ).

    lo_protokoll->get_apn_get_number_ranges( is_data = <ls_data> ).

    lo_protokoll->create_apn_body(
      EXPORTING
        it_result_per_btyp = lt_result_per_btyp
      CHANGING
        ct_prot_table      = lt_apn_table ).

    lo_protokoll->create_apn_footer(
      EXPORTING
        iv_beginn_datum = <ls_data>-common-beginndatum
        iv_beginn_uzeit = <ls_data>-common-beginnuzeit
        iv_filename     = <ls_data>-common-dateiname
      CHANGING
        ct_prot_table   = lt_apn_table ).

    lv_logical_filename = |/THKR/AIF_{ lv_ifname }_APN|.
    lv_output_filename  = lo_protokoll->get_filepath(
      iv_logical_filename = lv_logical_filename
      iv_filename         = CONV string( <ls_data>-common-dateiname ) ).

    CALL METHOD lo_protokoll->write_and_send_file_by_dept
      EXPORTING
        iv_output_filename = lv_output_filename
        it_rows            = lt_apn_table[]
        iv_dienstnr        = lv_dienstnr
        iv_width           = 80
        iv_eol             = CONV string( cl_abap_char_utilities=>newline )
      CHANGING
        cv_success         = success
        ct_return_tab      = return_tab[].

    IF success <> 'Y'.
      RETURN.
    ENDIF.
  ENDIF.

  " ─── CSV error file ─────────────────────────────────────────────────
  IF <ls_data>-lst IS NOT INITIAL.
    APPEND 'TYP;QUELLE;SATZNR;POS;KAP;TITEL;UKTO;OEH;FAELLIG;SOLL;FEHLERNUMMER;FEHLERTEXT'
      TO lt_csv_rows.

    DATA(lv_has_errors) = lo_protokoll->create_csv_err_body(
      EXPORTING
        it_lst       = <ls_data>-lst
        is_data      = <ls_data>
      CHANGING
        ct_csv_table = lt_csv_rows ).

    IF lv_has_errors = abap_true.
      lv_logical_filename = |/THKR/AIF_{ lv_ifname }_LST|.
      lv_output_filename  = lo_protokoll->get_filepath(
        iv_logical_filename = lv_logical_filename
        iv_filename         = CONV string( <ls_data>-common-dateiname ) && '_ERR.csv' ).

      CALL METHOD lo_protokoll->write_and_send_file_csv_by_dept
        EXPORTING
          iv_output_filename = lv_output_filename
          it_rows            = lt_csv_rows[]
          iv_dienstnr        = lv_dienstnr
          iv_eol             = CONV string( cl_abap_char_utilities=>newline )
        CHANGING
          cv_success         = success
          ct_return_tab      = return_tab[].

      IF success <> 'Y'.
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

  success = 'Y'.

ENDFUNCTION.

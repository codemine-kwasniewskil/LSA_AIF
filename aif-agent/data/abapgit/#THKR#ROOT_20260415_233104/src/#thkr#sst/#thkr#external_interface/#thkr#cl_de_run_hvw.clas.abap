CLASS /thkr/cl_de_run_hvw DEFINITION
  PUBLIC
  INHERITING FROM /thkr/cl_de_run_base
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !i_process_type TYPE /thkr/process_type
        !i_fremdverf    TYPE /thkr/fremdverf OPTIONAL
        !i_process_id   TYPE /thkr/process_id OPTIONAL
        !i_path         TYPE pathextern OPTIONAL
        !i_test         TYPE xfeld OPTIONAL
        !i_test_suffix  TYPE /thkr/test_suffix OPTIONAL .

    METHODS process
        REDEFINITION .
    METHODS read
        REDEFINITION .
    METHODS save
        REDEFINITION .
protected section.

  types:
    tp_fbr_t TYPE STANDARD TABLE OF /thkr/de_run_fpo .

  data T_HVW type /THKR/T_DE_RUN_HVW .
  data T_FIPOS type TP_FBR_T .
private section.

  methods PROCESS_FUNKTIONEN
    importing
      !I_FUNKTIONEN type /THKR/T_DE_HVW_FUNKTION .
  methods PROCESS_GRUPPEN
    importing
      !I_GRUPPEN type /THKR/T_DE_HVW_GRUPPE .
  methods PROCESS_IMPORT
    importing
      !I_DE_SATZ_ID type /THKR/DE_SATZ_ID
      !I_IMPORT_ONLY type XFELD
    exceptions
      /THKR/CX_EXT_IF .
  methods PROCESS_IMP_EINZELPLAN
    importing
      !I_EINELPLAN type /THKR/T_DE_HVW_EINZELPLAN
      !I_BASISJAHR type NUMC4
      !I_HHMODUS type CHAR6 .
  methods PROCESS_IMP_KAPITEL
    importing
      !I_KAPITEL type /THKR/T_DE_HVW_KAPITEL
      !I_FOND_KEY type /THKR/DTO_PSM_FO_KEY
      !I_BASISJAHR type NUMC4
      !I_HHMODUS type CHAR6 .
  methods PROCESS_IMP_TITELGRP
    importing
      !I_TITELGRP type /THKR/T_DE_HVW_TITEL_GR
      !I_FBER_KEY type /THKR/DTO_PSM_FB_KEY
      !I_FOND_KEY type /THKR/DTO_PSM_FO_KEY
      !I_BASISJAHR type NUMC4
      !I_HHMODUS type CHAR6 .
  methods PROCESS_IMP_TITEL
    importing
      !I_TITEL type /THKR/T_DE_HVW_TITEL
      !I_TGRP_KEY type /THKR/DTO_PSM_TG_KEY
      !I_FBER_KEY type /THKR/DTO_PSM_FB_KEY
      !I_FOND_KEY type /THKR/DTO_PSM_FO_KEY
      !I_KZ_AE type CHAR1 .
ENDCLASS.



CLASS /THKR/CL_DE_RUN_HVW IMPLEMENTATION.


  METHOD constructor.

    super->constructor(
      EXPORTING
        i_process_type = i_process_type
        i_fremdverf    = i_fremdverf
        i_process_id   = i_process_id
        i_path         = i_path
        i_test         = i_test
        i_test_suffix  = i_test_suffix ).

    CASE process_type.
*      WHEN 'HVW_I'.
*        kz_ie = 'I'.
*        type_handle_header ?= cl_abap_typedescr=>describe_by_name('/THKR/S_DE_HVW_FILE').
      WHEN 'FKT_I'.
        kz_ie = 'I'.
        type_handle_header ?= cl_abap_typedescr=>describe_by_name('/THKR/S_DE_HVW_FILE_FKT').
      WHEN OTHERS.
    ENDCASE.

    IF i_process_id IS NOT INITIAL.
      read( ).
    ENDIF.


  ENDMETHOD.


  METHOD process.

    DATA: l_is_new_run TYPE abap_bool.

    CLEAR: e_another_file_exists.

    TRY.
        IF process_id IS INITIAL.
          l_is_new_run = abap_true.
          save( ).  "Prozess-ID ermitteln lassen (falls noch nicht vergeben)
        ENDIF.

        DO 1 TIMES.
          CASE process_type.
            WHEN def->c_process_type-funktionsplan
              OR def->c_process_type-gruppierungsplan
              OR def->c_process_type-einzelplan. "Importe aus HAVWeb
              IF l_is_new_run = abap_true.

                fill_filename_import(
                  EXPORTING
                    i_filename            = i_filename
                    i_frontend            = i_frontend
                  IMPORTING
                    e_another_file_exists = e_another_file_exists ).
              ENDIF.

              process_import(
                EXPORTING
                  i_de_satz_id  = i_de_satz_id
                  i_import_only = i_import_only ).

              IF l_is_new_run = abap_true.
*                do_file_actions(
*                  EXPORTING
*                    i_dont_move_files = i_dont_move_files ).
*                IF i_dont_move_files IS NOT INITIAL.
*                  "Damit es bei mehreren Dateien nicht zur Endlosschleife kommmt:
*                  CLEAR e_another_file_exists.
*                ENDIF.
              ENDIF.

            WHEN OTHERS.
              ASSERT 1 = 2.
          ENDCASE.
        ENDDO.

      CATCH cx_root INTO DATA(l_oerror).
        add_event(
          EXPORTING
            i_exception = l_oerror ).

    ENDTRY.

    save( ).

  ENDMETHOD.


  METHOD process_funktionen.
*
*    TYPES: BEGIN OF lty_param_funktion,
*             funktion TYPE REF TO /thkr/s_de_hvw_funktion,
*             gjahr    TYPE gjahr,
*           END OF lty_param_funktion.
*    DATA: l_param_funktion TYPE lty_param_funktion,
*          l_cr_funktion    TYPE /thkr/s_dto_psm_funktion,
*          l_oerror         TYPE REF TO cx_root,
*          l_oerror1        TYPE REF TO cx_root,
*
*          l_ln_key         TYPE /thkr/event_ln_key,
*          l_ln_art         TYPE /thkr/event_ln_art,
*          lt_ln_evt        TYPE /thkr/t_ln_evt,
*          l_line_key_value TYPE string.
*
*    FIELD-SYMBOLS: <hvw>  TYPE /thkr/s_de_run_hvw_k.
*
*    LOOP AT i_funktionen INTO DATA(l_funktion).
*      TRY.
*          CLEAR: l_cr_funktion.
*          GET REFERENCE OF l_funktion INTO l_param_funktion-funktion.
*
*          "Eventuell vorhandene Meldungen zur Zeile löschen
*          "Das soll auch für Zeilen geschehen, die mit diesem Lauf nicht mehr verarbeitet
*          "werden, da sie schon mit einem anderen Lauf verarbeitet wurden.
*
*          "Daten für Verknüpfung von Ereignissen mit Zeile
*          appl->get_key_ln_evt_by_imp_line(
*            EXPORTING
*              i_process_type   = process_type
*              i_process_id     = process_id
*              i_imp_line_ref   = l_param_funktion-funktion
*            IMPORTING
*              e_line_key_value = l_line_key_value
*              e_ln_art         = l_ln_art
*              e_ln_key         = l_ln_key
*              et_ln_evt        = lt_ln_evt ).
*
*          "Bisherige Meldungen zur Zeile löschen
*          /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
*              i_ln_art         = l_ln_art
*              i_ln_key         = l_ln_key ).
*
*          COMMIT WORK.
*
*          "Prüfen, ob Funktion schon vorhanden
*          appl->get_dto_fremdver_hvw(
*            EXPORTING
*              i_fremdverf  = fremdverf
*              i_de_satz_id = CONV #( l_param_funktion-funktion->funktion )
**                      i_process_type =
**                      i_struktur   = '/THKR/DE_RUN_HVW'
*            IMPORTING
*              e_dto        = DATA(l_dto_fremdverf_funktion) ) .
*
*          IF l_dto_fremdverf_funktion IS NOT INITIAL AND l_dto_fremdverf_funktion-process_id <> process_id.
*            "Fehler: Datensatz bereits mit anderem Lauf verarbeitet
*
*            CREATE OBJECT l_oerror TYPE /thkr/cx_ext_if
*              EXPORTING
*                textid     = /thkr/cx_ext_if=>record_already_processed
*                satz_id    = CONV #( l_param_funktion-funktion->funktion )
*                process_id = l_dto_fremdverf_funktion-process_id.
*
*            add_event(
*              EXPORTING
*                i_event_category = 'E'
**                        i_event_category2 = ''
*                i_exception      = l_oerror
*                i_ln_art         = l_ln_art
*                i_ln_key         = l_ln_key ).
*            CONTINUE.
*
*          ELSEIF l_dto_fremdverf_funktion IS INITIAL.
*            "Datensatz zur erstmaligen Verarbeitung
*            APPEND INITIAL LINE TO t_hvw ASSIGNING <hvw>.
*            <hvw>-de_satz_id = l_param_funktion-funktion->funktion.
*          ELSE.
*            "Datensatz bereits (teilweise) verarbeitet
*            READ TABLE t_hvw WITH KEY de_satz_id = l_param_funktion-funktion->funktion ASSIGNING <hvw>.
*          ENDIF.
*
*          IF <hvw>-run2_status < '10'.  "Funktionen noch nicht erzeugt
*            "Funktionen anlegen
*            <hvw>-run2_status = '09'.   "Fehler: Funktionen
*
*            l_param_funktion-gjahr = '2024'.
*            gi_appl->get_data_by_gi(
*              EXPORTING
*                i_gi_id = 'FV_HVW_FKT'
*                i_para  = l_param_funktion
*              CHANGING
*                c_data  = l_cr_funktion ).
*
*
*            /thkr/cl_psm_int=>get_instance( )->create_psm_funktion(
*              EXPORTING
*                i_dto_funktion_create = l_cr_funktion ).
*          ENDIF.
*
*          <hvw>-run2_status = '10'.   "Funktionen angelegt
*        CATCH cx_root INTO l_oerror1.
*          ROLLBACK WORK.
*
*          CREATE OBJECT l_oerror TYPE /thkr/cx_ext_if
*            EXPORTING
*              textid   = /thkr/cx_ext_if=>record_processing_error
*              satz_id  = CONV #( l_param_funktion-funktion->funktion )
*              previous = l_oerror1.
*
*          add_event(
*            EXPORTING
*              i_event_category = 'E'
**                 i_event_category2 = ''
*              i_exception      = l_oerror
*              i_ln_art         = l_ln_art
*              i_ln_key         = l_ln_key ).
*
*      ENDTRY.
*    ENDLOOP.
  ENDMETHOD.


  METHOD process_gruppen.

    TYPES: BEGIN OF lty_param_gruppe,
             gruppe TYPE REF TO /thkr/s_de_hvw_gruppe,
           END OF lty_param_gruppe.

    DATA: l_param_gruppe   TYPE lty_param_gruppe,
          l_cr_gruppe      TYPE /thkr/s_dto_psm_gruppe,
          l_oerror         TYPE REF TO cx_root,
          l_oerror1        TYPE REF TO cx_root,

          l_ln_key         TYPE /thkr/event_ln_key,
          l_ln_art         TYPE /thkr/event_ln_art,
          lt_ln_evt        TYPE /thkr/t_ln_evt,
          l_line_key_value TYPE string.

    FIELD-SYMBOLS: <hvw>  TYPE /thkr/s_de_run_hvw_k.

    LOOP AT i_gruppen INTO DATA(l_gruppe).
      TRY.
          CLEAR: l_cr_gruppe.
*                  IF test_suffix IS NOT INITIAL.
*                    CONCATENATE l_gruppe-gruppe test_suffix INTO l_funkion-gruppe.
*                  ENDIF.
          GET REFERENCE OF l_gruppe INTO l_param_gruppe-gruppe.

          "Eventuell vorhandene Meldungen zur Zeile löschen
          "Das soll auch für Zeilen geschehen, die mit diesem Lauf nicht mehr verarbeitet
          "werden, da sie schon mit einem anderen Lauf verarbeitet wurden.

          "Daten für Verknüpfung von Ereignissen mit Zeile
          appl->get_key_ln_evt_by_imp_line(
            EXPORTING
              i_process_type   = process_type
              i_process_id     = process_id
              i_imp_line_ref   = l_param_gruppe-gruppe
            IMPORTING
              e_line_key_value = l_line_key_value
              e_ln_art         = l_ln_art
              e_ln_key         = l_ln_key
              et_ln_evt        = lt_ln_evt ).

          "Bisherige Meldungen zur Zeile löschen
          /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
              i_ln_art         = l_ln_art
              i_ln_key         = l_ln_key ).

          COMMIT WORK.

          "Prüfen, ob gruppe schon vorhanden
          appl->get_dto_fremdver_hvw(
            EXPORTING
              i_fremdverf  = fremdverf
              i_de_satz_id = CONV #( l_param_gruppe-gruppe->gruppe )
*                      i_process_type =
*                      i_struktur   = '/THKR/DE_RUN_HVW'
            IMPORTING
              e_dto        = DATA(l_dto_fremdverf_gruppe) ) .

          IF l_dto_fremdverf_gruppe IS NOT INITIAL AND l_dto_fremdverf_gruppe-process_id <> process_id.
            "Fehler: Datensatz bereits mit anderem Lauf verarbeitet

            CREATE OBJECT l_oerror TYPE /thkr/cx_ext_if
              EXPORTING
                textid     = /thkr/cx_ext_if=>record_already_processed
                satz_id    = CONV #( l_param_gruppe-gruppe->gruppe )
                process_id = l_dto_fremdverf_gruppe-process_id.

            add_event(
              EXPORTING
                i_event_category = 'E'
*                        i_event_category2 = ''
                i_exception      = l_oerror
                i_ln_art         = l_ln_art
                i_ln_key         = l_ln_key ).
            CONTINUE.

          ELSEIF l_dto_fremdverf_gruppe IS INITIAL.
            "Datensatz zur erstmaligen Verarbeitung
            APPEND INITIAL LINE TO t_hvw ASSIGNING <hvw>.
            <hvw>-de_satz_id = l_param_gruppe-gruppe->gruppe.
          ELSE.
            "Datensatz bereits (teilweise) verarbeitet
            READ TABLE t_hvw WITH KEY de_satz_id = l_param_gruppe-gruppe->gruppe ASSIGNING <hvw>.
          ENDIF.

          IF <hvw>-run2_status < '20'.  "Gruppe noch nicht erzeugt
            "Gruppe anlegen
            <hvw>-run2_status = '19'.   "Fehler: Funktionen

*                    l_param_gruppe-gjahr = '2024'.
            gi_appl->get_data_by_gi(
              EXPORTING
                i_gi_id = 'FV_HVW_GRP'
                i_para  = l_param_gruppe
              CHANGING
                c_data  = l_cr_gruppe ).


*                    /thkr/cl_psm_int=>get_instance( )->create_psm_gruppe(
*                      EXPORTING
*                        i_dto_funktion_create = l_cr_gruppe ).
          ENDIF.

          <hvw>-run2_status = '20'.   "Funktionen angelegt
        CATCH cx_root INTO l_oerror1.
          ROLLBACK WORK.

          CREATE OBJECT l_oerror TYPE /thkr/cx_ext_if
            EXPORTING
              textid   = /thkr/cx_ext_if=>record_processing_error
              satz_id  = CONV #( l_param_gruppe-gruppe->gruppe )
              previous = l_oerror1.

          add_event(
            EXPORTING
              i_event_category = 'E'
*                 i_event_category2 = ''
              i_exception      = l_oerror
              i_ln_art         = l_ln_art
              i_ln_key         = l_ln_key ).

      ENDTRY.
    ENDLOOP.
  ENDMETHOD.


  METHOD process_import.
*
*
*    TYPES: BEGIN OF lty_param_einzelplan,
*             einzelplan TYPE REF TO /thkr/s_de_hvw_einzelplan,
*           END OF lty_param_einzelplan.
*
*    DATA:
*      l_param_einzelplan TYPE lty_param_einzelplan,
**      l_cr_inzelplan     TYPE /thkr/s_dto_psm_funktion,
*      l_oerror           TYPE REF TO cx_root,
*      l_oerror1          TYPE REF TO cx_root,
*
*      l_ln_key           TYPE /thkr/event_ln_key,
*      l_ln_art           TYPE /thkr/event_ln_art,
*      lt_ln_evt          TYPE /thkr/t_ln_evt,
*      l_line_key_value   TYPE string.
*
*    FIELD-SYMBOLS: <hvw_file_fkt> TYPE /thkr/s_de_hvw_file_fkt.
*    FIELD-SYMBOLS: <hvw_file_grp> TYPE /thkr/s_de_hvw_file_grp.
*    FIELD-SYMBOLS: <hvw_file_ep>     TYPE /thkr/s_de_hvw_file.
*
*    FIELD-SYMBOLS: <proc_data> TYPE any.
*    FIELD-SYMBOLS: <hvw>  TYPE /thkr/s_de_run_hvw_k.
*
*    IF exch_data-status < def->c_run_status-daten_importiert. "Daten noch nicht importiert
*      TRY.
*          IF sy-uname = 'ZHM000000053'.
*            BREAK-POINT.
*          ENDIF.
*          read_file( ).
*
*          CASE process_type.
*            WHEN def->c_process_type-funktionsplan.
*              CREATE DATA exch_data-proc_data TYPE /thkr/s_de_hvw_file_fkt.
*              ASSIGN exch_data-proc_data->* TO <proc_data>.
*              CALL TRANSFORMATION /thkr/hvw_fkt_to_abap
*                SOURCE XML xml_string
*                RESULT file = <proc_data>.
*
*              ASSIGN exch_data-proc_data->* TO <hvw_file_fkt>.
**                IF test_suffix IS NOT INITIAL.
**                  <hvw_file_EP>-test_suffix = test_suffix.
**                ENDIF.
*
*              exch_data-status = def->c_run_status-daten_importiert.  "Daten importiert
*            WHEN def->c_process_type-gruppierungsplan.
*              CREATE DATA exch_data-proc_data TYPE /thkr/s_de_hvw_file_grp.
*
*              ASSIGN exch_data-proc_data->* TO <proc_data>.
*              CALL TRANSFORMATION /thkr/hvw_grp_to_abap
*                SOURCE XML xml_string
*                RESULT file = <proc_data>.
*
*              ASSIGN exch_data-proc_data->* TO <hvw_file_grp>.
**                IF test_suffix IS NOT INITIAL.
**                  <hvw_file_EP>-test_suffix = test_suffix.
**                ENDIF.
*
*              exch_data-status = def->c_run_status-daten_importiert.  "Daten importiert
*            WHEN def->c_process_type-einzelplan.
*              CREATE DATA exch_data-proc_data TYPE /thkr/s_de_hvw_file.
*
*              ASSIGN exch_data-proc_data->* TO <proc_data>.
*              CALL TRANSFORMATION /thkr/hvw_gp_to_abap
*                SOURCE XML xml_string
*                RESULT file = <proc_data>.
*
*              ASSIGN exch_data-proc_data->* TO <hvw_file_ep>.
*              IF test_suffix IS NOT INITIAL.
*                <hvw_file_ep>-test_suffix = test_suffix.
*              ENDIF.
*
*              exch_data-status = def->c_run_status-daten_importiert.  "Daten importiert
*            WHEN  OTHERS.
*          ENDCASE.
*
*          save( ).
*          COMMIT WORK.
*        CATCH cx_root INTO l_oerror.
*
*          add_event(
*            EXPORTING
*              i_exception = l_oerror ).
*      ENDTRY.
*
*    ENDIF.
*    IF exch_data-status >= def->c_run_status-daten_importiert AND is_test IS INITIAL.  "Daten sollen verarbeitet werden.
*
*      IF i_import_only IS NOT INITIAL.
*        RETURN.
*      ENDIF.
*      CASE process_type.
*        WHEN def->c_process_type-funktionsplan.
***********************************************************************
**       Funktionenpläne anlegen
***********************************************************************
*          ASSIGN exch_data-proc_data->* TO <hvw_file_fkt>.
*
*          IF NOT <hvw_file_fkt>-t_funktion[] IS INITIAL.
*            SORT <hvw_file_fkt>-t_funktion BY funktion.
*
*            process_funktionen(
*              EXPORTING
*                i_funktionen = <hvw_file_fkt>-t_funktion[] ).
*
*          ENDIF.
*        WHEN def->c_process_type-gruppierungsplan.
***********************************************************************
**       Gruppierungspläne anlegen
***********************************************************************
*          ASSIGN exch_data-proc_data->* TO <hvw_file_grp>.
**          IF <hvw_file_EP>-test_suffix IS NOT INITIAL.
**            test_suffix = <hvw_file_EP>-test_suffix.
**          ENDIF.
*
*          IF NOT <hvw_file_grp>-t_gruppe[] IS INITIAL.
*            SORT <hvw_file_grp>-t_gruppe BY gruppe.
*
*            process_gruppen(
*              EXPORTING
*                i_gruppen = <hvw_file_grp>-t_gruppe[] ).
*
*          ENDIF.
*        WHEN def->c_process_type-einzelplan.
***********************************************************************
**       Einzelplan (+Kapitel, Titelgruppen, Titel) anlegen
***********************************************************************
*          ASSIGN exch_data-proc_data->* TO <hvw_file_ep>.
*
*
*          """NUR ZUM TEST!!!, bis Daten richtig aus XML kommen.
*          IF <hvw_file_ep>-basisjahr IS INITIAL.
*            <hvw_file_ep>-basisjahr = '2024'.
*          ENDIF.
*          IF <hvw_file_ep>-hhmodus IS INITIAL.
*            <hvw_file_ep>-hhmodus = def->c_hhmodus-einzelhh_original..
*          ENDIF.
*
*          process_imp_einzelplan( i_einelplan = <hvw_file_ep>-t_einzelplan
*                                  i_basisjahr = <hvw_file_ep>-basisjahr
*                                  i_hhmodus  = <hvw_file_ep>-hhmodus ).
*        WHEN  OTHERS.
*      ENDCASE.
*
*    ENDIF.
  ENDMETHOD.


  METHOD process_imp_einzelplan.
*
*    "Diese Struktur wird im Customizing der generischen Schnittstelle
*    "verwendet.
*    DATA: BEGIN OF ls_param,
*            einzelplan   TYPE REF TO /thkr/s_de_hvw_einzelplan,
*            hhmodus(6)   TYPE c,
*            basisjahr(4) TYPE n,
*          END OF ls_param.
*
*    DATA ls_fo_create TYPE /thkr/dto_create_psm_fo.
*    DATA ls_fond_key  TYPE /thkr/dto_psm_fo_key.
*    DATA l_ln_key         TYPE /thkr/event_ln_key.
*    DATA l_ln_art         TYPE /thkr/event_ln_art.
*    DATA lt_ln_evt        TYPE /thkr/t_ln_evt.
*    DATA l_line_key_value TYPE string.
*    DATA l_error         TYPE REF TO cx_root.
*
*    LOOP AT i_einelplan REFERENCE INTO DATA(wa_einzelplan).
*
*      "Einzelplan anlegen
*      TRY.
*          "Daten für Verknüpfung von Ereignissen mit Zeile
*          appl->get_key_ln_evt_by_imp_line(
*                  EXPORTING
*                    i_process_type   = process_type
*                    i_process_subtype = def->c_process_subtype-einzelplan
*                    i_process_id     = process_id
*                    i_imp_line_ref   = wa_einzelplan "???
*                  IMPORTING
*                    e_line_key_value = l_line_key_value
*                    e_ln_art         = l_ln_art
*                    e_ln_key         = l_ln_key
*                    et_ln_evt        = lt_ln_evt ).
*
*          "Bisherige Meldungen zur Zeile löschen
*          /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
*              i_ln_art         = l_ln_art
*              i_ln_key         = l_ln_key ).
*
*          COMMIT WORK.
*
*          ls_param-einzelplan = wa_einzelplan.
*          ls_param-basisjahr = i_basisjahr.
*          ls_param-hhmodus = i_hhmodus.
*
*          gi_appl->get_data_by_gi(
*            EXPORTING
*              i_gi_id  = def->cde-gi_id_ep
*              i_para   = ls_param
*            CHANGING
**              c_para   = ???
*              c_data   = ls_fo_create
*          ).
*
*          "Prüfen, ob Einzelplan/Fond schon vorhanden
*          TRY.
*              /thkr/cl_psm_int=>get_instance( )->get_dto_psm_fo(
*                EXPORTING
*                  i_fond_id =  VALUE #( fikrs   = ls_fo_create-fikrs
*                                        fincode = ls_fo_create-fincode )
*                IMPORTING
*                  e_fond    =   DATA(ls_fo_data_read) ).
*              "Einzelplan als Fond bereits angelegt.
*              ls_fond_key-fikrs = ls_fo_data_read-fikrs.
*              ls_fond_key-fincode = ls_fo_data_read-fincode.
*
*            CATCH /thkr/cx_psm_int_fi.
*              "Einzelplan nicht vorhanden.
*              /thkr/cl_psm_int=>get_instance( )->create_psm_fo(
*                EXPORTING
*                  i_fo_create = ls_fo_create
*                IMPORTING
*                  e_fond      = ls_fond_key ).
*
*              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*                EXPORTING
*                  wait = abap_true.
*          ENDTRY.
*        CATCH cx_root INTO DATA(l_error_prev).
*          ROLLBACK WORK.
*
*          CREATE OBJECT l_error TYPE /thkr/cx_ext_if
*            EXPORTING
*              textid   = /thkr/cx_ext_if=>record_processing_error
*              satz_id  = CONV /thkr/de_satz_id( wa_einzelplan->einzelplan )
*              previous = l_error_prev.
*
*          add_event(
*            EXPORTING
*              i_event_category = 'E'
**                 i_event_category2 = ''
*              i_exception      = l_error
*              i_ln_art         = l_ln_art
*              i_ln_key         = l_ln_key ).
*
*          CONTINUE. "Keine Nachfolge-Prozesse verarbeiten.
*
*      ENDTRY.
*
*      "...wenn ohne Fehler,
*      "Kapitel anlegen
*      process_imp_kapitel( i_kapitel = wa_einzelplan->t_kapitel
*                           i_fond_key = ls_fond_key
*                           i_basisjahr = i_basisjahr
*                           i_hhmodus = i_hhmodus ).
*    ENDLOOP.

  ENDMETHOD.


  METHOD process_imp_kapitel.
*    "Diese Struktur wird im Customizing der generischen Schnittstelle
*    "verwendet.
*    DATA: BEGIN OF ls_param,
*            kapitel      TYPE REF TO /thkr/s_de_hvw_kapitel,
*            hhmodus(6)   TYPE c,
*            basisjahr(4) TYPE n,
*          END OF ls_param.
*
*    DATA ls_fb_create      TYPE /thkr/dto_create_psm_fb.
*    DATA ls_fb_key        TYPE /thkr/dto_psm_fb_key.
*    DATA l_ln_key         TYPE /thkr/event_ln_key.
*    DATA l_ln_art         TYPE /thkr/event_ln_art.
*    DATA lt_ln_evt        TYPE /thkr/t_ln_evt.
*    DATA l_line_key_value TYPE string.
*    DATA l_error         TYPE REF TO cx_root.
*
*    LOOP AT i_kapitel REFERENCE INTO DATA(wa_kapitel).
*      "Kapitel anlegen...
*      TRY.
*          "Daten für Verknüpfung von Ereignissen mit Zeile
*          appl->get_key_ln_evt_by_imp_line(
*                  EXPORTING
*                    i_process_type   = process_type
*                    i_process_subtype = def->c_process_subtype-kapitel
*                    i_process_id     = process_id
*                    i_imp_line_ref   = wa_kapitel
*                  IMPORTING
*                    e_line_key_value = l_line_key_value
*                    e_ln_art         = l_ln_art
*                    e_ln_key         = l_ln_key
*                    et_ln_evt        = lt_ln_evt ).
*
*          "Bisherige Meldungen zur Zeile löschen
*          /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
*              i_ln_art         = l_ln_art
*              i_ln_key         = l_ln_key ).
*
*          COMMIT WORK.
*
*          ls_param-kapitel = wa_kapitel.
*          ls_param-basisjahr = i_basisjahr.
*          ls_param-hhmodus = i_hhmodus.
*
*          "Kapitel/Funktionsbereich anlegen.
*          IF NOT wa_kapitel->kapitel IS INITIAL.
*            gi_appl->get_data_by_gi(
*                  EXPORTING
*                    i_gi_id = def->cde-gi_id_ka
*                    i_para  = ls_param
*                  CHANGING
*                    c_data  = ls_fb_create ).
*          ENDIF.
*
*          "Prüfen, ob Funktionsbereich schon existiert.
*          TRY.
*              /thkr/cl_psm_int=>get_instance( )->get_dto_psm_fb(
*                EXPORTING
*                  i_fkber_id = VALUE #( fkber = ls_fb_create-fkber )
*                IMPORTING
*                  e_fkber    = DATA(ls_fb_read) ).
*              ls_fb_key-fkber = ls_fb_read-fkber.
*            CATCH /thkr/cx_psm_int_fi.
*              "Funktionsbereich nicht vorhanden.
*              ls_fb_key = /thkr/cl_psm_int=>get_instance( )->create_psm_fb(
*                EXPORTING
*                  i_fb_create = ls_fb_create ).
*
*              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*                EXPORTING
*                  wait = abap_true.
*          ENDTRY.
*        CATCH cx_root INTO DATA(l_error_prev).
*          ROLLBACK WORK.
*
*          CREATE OBJECT l_error TYPE /thkr/cx_ext_if
*            EXPORTING
*              textid   = /thkr/cx_ext_if=>record_processing_error
*              satz_id  = CONV /thkr/de_satz_id( wa_kapitel->kapitel )
*              previous = l_error_prev.
*
*          add_event(
*            EXPORTING
*              i_event_category = 'E'
*              i_exception      = l_error
*              i_ln_art         = l_ln_art
*              i_ln_key         = l_ln_key ).
*          CONTINUE.
*      ENDTRY.
*
*      "...wenn erfolgreich
*      "TitelGruppen anlegen
*      process_imp_titelgrp( i_titelgrp = wa_kapitel->t_titel_gr
*                            i_fber_key = ls_fb_key
*                            i_fond_key = i_fond_key
*                            i_basisjahr = i_basisjahr
*                            i_hhmodus = i_hhmodus ).
*    ENDLOOP.

  ENDMETHOD.


  METHOD process_imp_titel.
    "Diese Struktur wird im Customizing der generischen Schnittstelle
    "verwendet.
*    DATA: BEGIN OF ls_param,
*            titel TYPE REF TO /thkr/s_de_hvw_titel,
*            tgrp  TYPE /thkr/dto_psm_tg_key,
*            fber  TYPE /thkr/dto_psm_fb_key,
*            fond  TYPE /thkr/dto_psm_fo_key,
*            kz_ae  TYPE char1,
*          END OF ls_param.
*
*    DATA ls_fipos_create  TYPE /thkr/dto_create_fp.
*    DATA ls_fipos_key     TYPE /thkr/dto_fp_key.
*
*    DATA l_ln_key         TYPE /thkr/event_ln_key.
*    DATA l_ln_art         TYPE /thkr/event_ln_art.
*    DATA lt_ln_evt        TYPE /thkr/t_ln_evt.
*    DATA l_line_key_value TYPE string.
*    DATA l_error         TYPE REF TO cx_root.
*
*    LOOP AT i_titel REFERENCE INTO DATA(wa_titel).
*
*      "Titel = Finanzposition anlegen
*      TRY.
*          "Daten für Verknüpfung von Ereignissen mit Zeile
*          appl->get_key_ln_evt_by_imp_line(
*                  EXPORTING
*                    i_process_type   = process_type
*                    i_process_subtype = def->c_process_subtype-titel
*                    i_process_id     = process_id
*                    i_imp_line_ref   = wa_titel
*                  IMPORTING
*                    e_line_key_value = l_line_key_value
*                    e_ln_art         = l_ln_art
*                    e_ln_key         = l_ln_key
*                    et_ln_evt        = lt_ln_evt ).
*
*          "Bisherige Meldungen zur Zeile löschen
*          /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
*              i_ln_art         = l_ln_art
*              i_ln_key         = l_ln_key ).
*          COMMIT WORK.
*
*          ls_param-fber = i_fber_key.
*          ls_param-fond = i_fond_key.
*          ls_param-kz_ae = i_kz_ae.
*          ls_param-tgrp = i_tgrp_key.
*          ls_param-titel = wa_titel.
*
*          "Daten via Customizing auf DTO-Struktur mappen.
*          gi_appl->get_data_by_gi(
*                  EXPORTING
*                    i_gi_id = def->cde-gi_id_tl
*                    i_para  = ls_param
*                  CHANGING
*                    c_data  = ls_fipos_create ).
*          IF NOT test_suffix IS INITIAL.
*            ls_fipos_create-fipex = ls_fipos_create-fipex && test_suffix.
*          ENDIF.
*
*          "Prüfen, ob Titel/FiPos  schon (teil-)verarbeitet wurde.
*          appl->get_dto_fremdver_fipos(
*            EXPORTING
*              i_fremdverf    = fremdverf
*              i_fipex        = ls_fipos_create-fipex
*              i_process_type = process_type
*            IMPORTING
*              e_dto          = DATA(l_dto_fremdverf_fipos) ).
*
*          IF l_dto_fremdverf_fipos IS NOT INITIAL AND l_dto_fremdverf_fipos-process_id <> process_id.
*            "Fehler: Datensatz bereits mit anderem Lauf verarbeitet
*            CREATE OBJECT l_error TYPE /thkr/cx_ext_if
*              EXPORTING
*                textid     = /thkr/cx_ext_if=>record_already_processed
*                satz_id    = CONV /thkr/de_satz_id( wa_titel->titel )
*                process_id = l_dto_fremdverf_fipos-process_id.
*
*            add_event(
*              EXPORTING
*                i_event_category = 'I'
*                i_exception      = l_error
*                i_ln_art         = l_ln_art
*                i_ln_key         = l_ln_key ).
*
*            CONTINUE.
*          ELSEIF l_dto_fremdverf_fipos IS INITIAL.
*            "Datensatz zur erstmaligen Verarbeitung
*            APPEND INITIAL LINE TO t_fipos REFERENCE INTO DATA(wa_fipos).
*            wa_fipos->fipex = ls_fipos_create-fipex.
*          ELSE.
*            READ TABLE t_fipos WITH KEY fipex = ls_fipos_create-fipex REFERENCE INTO wa_fipos.
*            "Datensatz bereits (teilweise) verarbeitet
*          ENDIF.
*
*          IF wa_fipos IS BOUND AND wa_fipos->run2_status NE def->c_run_status2-fp_angelegt.
*
*            "Zunächst pesimistisch auf Fehler setzen.
*            wa_fipos->run2_status = def->c_run_status2-fp_fehler.
*
*            TRY.
*
*                "Prüfen, ob FiPos schon existiert
*                /thkr/cl_psm_int=>get_instance( )->get_dto_psm_fp(
*                  EXPORTING
*                    i_dto_psm_fp = VALUE #( fikrs  = ls_fipos_create-fikrs
*                                            gjahr  = ls_fipos_create-gjahr
*                                            fipex  = ls_fipos_create-fipex )
*                  IMPORTING
*                    e_dto        =  DATA(ls_fipo_read) ).
*                "Fipos vorhanden, dann Schlüsselfelder merken.
*                ls_fipos_key-fikrs = ls_fipo_read-fikrs.
*                ls_fipos_key-fipex = ls_fipo_read-fipex.
*                ls_fipos_key-gjahr = ls_fipo_read-gjahr.
*              CATCH /thkr/cx_psm_int_fi.
*                "Existiert nicht, also neue FiPos anlegen
*                /thkr/cl_psm_int=>get_instance( )->create_psm_fp(
*                        EXPORTING
*                          i_dto_psm_fp_create = ls_fipos_create
*                        IMPORTING
*                          e_fipos             = ls_fipos_key ).
*
*                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*                  EXPORTING
*                    wait = abap_true.
*                wa_fipos->run2_status = def->c_run_status2-fp_angelegt.
*            ENDTRY.
*          ENDIF.
*
*        CATCH cx_root INTO DATA(l_error_prev).
*          ROLLBACK WORK.
*
*          CREATE OBJECT l_error TYPE /thkr/cx_ext_if
*            EXPORTING
*              textid   = /thkr/cx_ext_if=>record_processing_error
*              satz_id  = CONV /thkr/de_satz_id( wa_titel->titel )
*              previous = l_error_prev.
*
*          add_event(
*            EXPORTING
*              i_event_category = 'E'
**                 i_event_category2 = ''
*              i_exception      = l_error
*              i_ln_art         = l_ln_art
*              i_ln_key         = l_ln_key ).
*
*          CONTINUE. "Keine Nachfolge-Prozesse verarbeiten.
*
*      ENDTRY.
*
*    ENDLOOP.

  ENDMETHOD.


  METHOD process_imp_titelgrp.
    "Diese Struktur wird im Customizing der generischen Schnittstelle
    "verwendet.
*    DATA: BEGIN OF ls_param,
*            titelgrp  TYPE REF TO /thkr/s_de_hvw_titel_gr,
*            fber      TYPE /thkr/dto_psm_fb_key,
*            fond      TYPE /thkr/dto_psm_fo_key,
*            basisjahr TYPE numc4,
*          END OF ls_param.
*
*    DATA ls_tg_create TYPE  /thkr/dto_create_psm_tg.
*    DATA ls_tg_read   TYPE /thkr/dto_psm_tg.
*    DATA ls_tg_key    TYPE /thkr/dto_psm_tg_key.
*
*
*    DATA l_ln_key         TYPE /thkr/event_ln_key.
*    DATA l_ln_art         TYPE /thkr/event_ln_art.
*    DATA lt_ln_evt        TYPE /thkr/t_ln_evt.
*    DATA l_line_key_value TYPE string.
*    DATA l_error
*            TYPE REF TO cx_root.
*
*
*    LOOP AT i_titelgrp REFERENCE INTO DATA(wa_titelgrp).
*      CLEAR ls_tg_key.
*
*      "Titelgruppe anlegen
*      TRY.
*          "Daten für Verknüpfung von Ereignissen mit Zeile
*          appl->get_key_ln_evt_by_imp_line(
*                  EXPORTING
*                    i_process_type   = process_type
*                    i_process_subtype = def->c_process_subtype-titelgruppe
*                    i_process_id     = process_id
*                    i_imp_line_ref   = wa_titelgrp
*                  IMPORTING
*                    e_line_key_value = l_line_key_value
*                    e_ln_art         = l_ln_art
*                    e_ln_key         = l_ln_key
*                    et_ln_evt        = lt_ln_evt ).
*
*          "Bisherige Meldungen zur Zeile löschen
*          /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
*              i_ln_art         = l_ln_art
*              i_ln_key         = l_ln_key ).
*
*          COMMIT WORK.
*
*
*          ls_param-titelgrp = wa_titelgrp.
*          ls_param-basisjahr = i_basisjahr.
*          ls_param-fond = i_fond_key.
*          ls_param-fber = i_fber_key.
*
*          "Wenn Titelgruppe initial ist, dann wir auch
*          "gemappt, um u.a. den Fikrs zu übernehmen.
*          gi_appl->get_data_by_gi(
*                  EXPORTING
*                    i_gi_id = def->cde-gi_id_tg
*                    i_para  = ls_param
*                  CHANGING
*                    c_data  = ls_tg_create ).
*
*
*          "00 = "Titel ohne Titelgruppe
*          "=> Nur die wichtigsten Felder übernehmen
*          "Sonst
*          "=> Titelgruppe anlegen.
*          IF wa_titelgrp->titel_gr EQ '00'.
*            ls_tg_key-fikrs = ls_tg_create-fikrs.
*            ls_tg_key-fkber = ls_tg_create-fkber.
*            ls_tg_key-gjahr = ls_tg_create-gjahr.
*            ls_tg_key-titelgrp = ls_tg_create-titelgrp.
*          ELSE.
*            CLEAR ls_tg_read.
*            TRY.
*                /thkr/cl_psm_int=>get_instance( )->get_dto_psm_tg(
*                  EXPORTING
*                    i_dto_psm_tg = VALUE #( fikrs = ls_tg_create-fikrs
*                                            gjahr = ls_tg_create-gjahr
*                                            fkber = ls_tg_create-fkber
*                                            titelgrp = ls_tg_create-titelgrp )
*                  IMPORTING
*                    e_dto        =  ls_tg_read ).
*                ls_tg_key-fikrs = ls_tg_read-fikrs.
*                ls_tg_key-fkber = ls_tg_read-fkber.
*                ls_tg_key-gjahr = ls_tg_read-gjahr.
*                ls_tg_key-titelgrp = ls_tg_read-titelgrp.
*
*              CATCH /thkr/cx_psm_int_fi.
*                /thkr/cl_psm_int=>get_instance( )->create_psm_tg(
*                  EXPORTING
*                    i_dto_psm_tg_create = ls_tg_create
*                  IMPORTING
*                    e_psm_tg            = ls_tg_key ).
*                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*                  EXPORTING
*                    wait = 'X'.
*            ENDTRY.
*          ENDIF.
*
*        CATCH cx_root INTO DATA(l_error_prev).
*          ROLLBACK WORK.
*
*          CREATE OBJECT l_error TYPE /thkr/cx_ext_if
*            EXPORTING
*              textid   = /thkr/cx_ext_if=>record_processing_error
*              satz_id  = CONV /thkr/de_satz_id( wa_titelgrp->titel_gr )
*              previous = l_error_prev.
*
*          add_event(
*            EXPORTING
*              i_event_category = 'E'
**                 i_event_category2 = ''
*              i_exception      = l_error
*              i_ln_art         = l_ln_art
*              i_ln_key         = l_ln_key ).
*          CONTINUE.
*      ENDTRY.
*
*      process_imp_titel(    i_kz_ae    = wa_titelgrp->kz_ea
*                            i_tgrp_key = ls_tg_key
*                            i_fond_key = i_fond_key
*                            i_fber_key = i_fber_key
*                            i_titel = wa_titelgrp->t_titel ).
*    ENDLOOP.
  ENDMETHOD.


  METHOD read.
    super->read( ).

    SELECT * INTO CORRESPONDING FIELDS OF TABLE @t_hvw
      FROM /thkr/de_run_hvw
      WHERE process_type = @process_type
        AND process_id   = @process_id.

    "Titel/Finanzposition
    SELECT * FROM /thkr/de_run_fpo INTO TABLE @t_fipos
            WHERE process_type = @process_type
              AND process_id   = @process_id.

  ENDMETHOD.


  METHOD save.

    DATA: l_de_run_hvw TYPE /thkr/de_run_hvw.

    super->save( ).

    IF is_test IS INITIAL.
      LOOP AT t_hvw INTO DATA(l_hvw).
        CLEAR: l_de_run_hvw.
        MOVE-CORRESPONDING l_hvw TO l_de_run_hvw.
        l_de_run_hvw-process_type = process_type.
        l_de_run_hvw-process_id   = process_id.

        MODIFY /thkr/de_run_hvw FROM l_de_run_hvw.

      ENDLOOP.

      LOOP AT t_fipos INTO DATA(l_fipos).
        l_fipos-process_id = process_id.
        l_fipos-process_type = process_type.
        "Titel/Finanzposition
        MODIFY /thkr/de_run_fpo FROM l_fipos.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.
ENDCLASS.

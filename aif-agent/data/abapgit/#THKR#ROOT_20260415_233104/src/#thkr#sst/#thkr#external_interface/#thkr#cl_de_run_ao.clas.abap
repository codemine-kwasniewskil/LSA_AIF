class /THKR/CL_DE_RUN_AO definition
  public
  inheriting from /THKR/CL_DE_RUN_BASE
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE
      !I_FREMDVERF type /THKR/FREMDVERF optional
      !I_PROCESS_ID type /THKR/PROCESS_ID optional
      !I_PATH type PATHEXTERN optional
      !I_TEST type XFELD optional
      !I_TEST_SUFFIX type /THKR/TEST_SUFFIX optional .
  methods GET_DE_FILE
    exporting
      !E_DE_FILE type /THKR/S_DE_FILE .
  methods GET_T_INPDB
    exporting
      !ET_INPDB type /THKR/T_DE_INPDB .

  methods PROCESS
    redefinition .
  methods READ
    redefinition .
  methods SAVE
    redefinition .
protected section.

  data T_AO1 type /THKR/T_DE_RUN_AO1 .
  data T_INPDB type /THKR/T_DE_INPDB .
private section.

  methods CONVERT_INPDB_TO_DE_FILE
    raising
      /THKR/CX_LSA1 .
  methods CONVERT_TXT_TO_INPDB
    raising
      /THKR/CX_LSA1 .
  methods PROCESS_IMPORT
    importing
      !I_DE_SATZ_ID type /THKR/DE_SATZ_ID optional
      !I_IMPORT_ONLY type XFELD
    raising
      /THKR/CX_EXT_IF .
ENDCLASS.



CLASS /THKR/CL_DE_RUN_AO IMPLEMENTATION.


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
      WHEN 'AO_I'.
        kz_ie = 'I'.
        type_handle_header ?= cl_abap_typedescr=>describe_by_name('/THKR/S_DE_FILE').

      WHEN OTHERS.
    ENDCASE.

    IF i_process_id IS NOT INITIAL.
      read( ).
    ENDIF.


  ENDMETHOD.


  METHOD convert_inpdb_to_de_file.

    TYPES: BEGIN OF lty_bc_param,
             inpdb TYPE /thkr/s_de_inpdb,
           END OF lty_bc_param.

    DATA: l_param     TYPE lty_bc_param,
          l_ref_beleg TYPE /thkr/s_de_beleg_key_fields.

    FIELD-SYMBOLS: <de_file> TYPE /thkr/s_de_file.

    "Feld für die Sortierung nach Verarbeitungsreihenfolge belegen:
    LOOP AT t_inpdb ASSIGNING FIELD-SYMBOL(<inpdb>).
      READ TABLE def->t_inpdb_btyp_options WITH KEY btyp = <inpdb>-btyp
        INTO DATA(l_btyp_options).
      <inpdb>-onum = l_btyp_options-onum.
    ENDLOOP.

    SORT t_inpdb BY onum quelle qbelnr qposnr.

    CREATE DATA exch_data-proc_data TYPE /thkr/s_de_file.
    ASSIGN exch_data-proc_data->* TO <de_file>.

    LOOP AT t_inpdb INTO l_param-inpdb.
      READ TABLE def->t_inpdb_btyp_options WITH KEY btyp = l_param-inpdb-btyp
        INTO l_btyp_options.

      CASE l_param-inpdb-btyp.
        WHEN 'FUA' OR 'SST'.   "Festlegung und Anordnung.
          APPEND INITIAL LINE TO <de_file>-t_ao ASSIGNING FIELD-SYMBOL(<ao>).
          APPEND INITIAL LINE TO <ao>-t_beleg ASSIGNING FIELD-SYMBOL(<beleg>).

          IF l_btyp_options-gi_id_beleg0 IS NOT INITIAL.
            gi_appl->get_data_by_gi(
              EXPORTING
                i_gi_id = l_btyp_options-gi_id_beleg0
                i_para  = l_param
              CHANGING
*               c_para  =
                c_data  = <beleg> ).
          ENDIF.

          IF l_btyp_options-gi_id_beleg1 IS NOT INITIAL.
            gi_appl->get_data_by_gi(
              EXPORTING
                i_gi_id = l_btyp_options-gi_id_beleg1
                i_para  = l_param
              CHANGING
*               c_para  =
                c_data  = <beleg> ).
            <ao>-de_ao_id = <beleg>-de_beleg_id.
          ENDIF.

        WHEN 'KOR'.   "Umbuchung Auszahlung
          "Folgevorgang: Referenzierten Datensatz ermitteln
          gi_appl->get_data_by_gi(
            EXPORTING
              i_gi_id = l_btyp_options-gi_id_ref_key
              i_para  = l_param
            CHANGING
*             c_para  =
              c_data  = l_ref_beleg ).

          "Referenzierten Datensatz finden
          UNASSIGN <beleg>.
          LOOP AT <de_file>-t_ao ASSIGNING <ao>.
            LOOP AT <ao>-t_beleg REFERENCE INTO DATA(lr_beleg).
              IF lr_beleg->de_beleg_id = l_ref_beleg-de_beleg_id.
                ASSIGN lr_beleg->* TO <beleg>.
                EXIT.
              ENDIF.
            ENDLOOP.
            IF <beleg> IS ASSIGNED.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF <beleg> IS ASSIGNED.

            IF l_btyp_options-gi_id_beleg0 IS NOT INITIAL.
              gi_appl->get_data_by_gi(
                EXPORTING
                  i_gi_id = l_btyp_options-gi_id_beleg0
                  i_para  = l_param
                CHANGING
*                 c_para  =
                  c_data  = <beleg> ).
            ENDIF.

            IF l_btyp_options-gi_id_beleg1 IS NOT INITIAL.
              gi_appl->get_data_by_gi(
                EXPORTING
                  i_gi_id = l_btyp_options-gi_id_beleg1
                  i_para  = l_param
                CHANGING
*                 c_para  =
                  c_data  = <beleg> ).
              <ao>-de_ao_id = <beleg>-de_beleg_id.
            ENDIF.

          ENDIF.

        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.

    IF test_suffix IS NOT INITIAL.
      <de_file>-test_suffix = test_suffix.
    ENDIF.

    exch_data-status = '25'.  "Daten importiert

  ENDMETHOD.


  METHOD convert_txt_to_inpdb.

    DATA: l_delimiter TYPE c,
          lr_inpdb    TYPE REF TO /thkr/s_de_inpdb,
          lt_values   TYPE STANDARD TABLE OF string.

    l_delimiter = '|'.

    helpers->get_fieldlist_from_struct(
      EXPORTING
        i_structure  = '/THKR/S_DE_INPDB'
*       i_include_fields_type_s =
      IMPORTING
        et_fieldlist = DATA(lt_fieldlist) ).

    LOOP AT t_string INTO DATA(l_line).
      IF l_line(3) = '000'.    "Vorsatz
        CONTINUE.
      ELSEIF l_line(3) = '999'. "Nachsatz
        EXIT.
      ENDIF.

      SPLIT l_line AT l_delimiter INTO TABLE lt_values.
      CREATE DATA lr_inpdb.

      LOOP AT lt_fieldlist INTO DATA(l_field).
        "Felder inpdb der Reihe nach belegen
        READ TABLE lt_values INDEX sy-tabix INTO DATA(l_value).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        lr_inpdb->(l_field-fieldname) = l_value.
      ENDLOOP.

      APPEND lr_inpdb->* TO t_inpdb.

    ENDLOOP.

    exch_data-status = '12'.    "Textdaten wurden interpretiert

  ENDMETHOD.


  METHOD get_de_file.

    ASSIGN exch_data-proc_data->* TO FIELD-SYMBOL(<proc_data>).
    e_de_file = <proc_data>.

  ENDMETHOD.


  METHOD get_t_inpdb.

    et_inpdb = t_inpdb.

  ENDMETHOD.


  METHOD process.

    DATA: l_is_new_run TYPE xfeld.

    CLEAR: e_another_file_exists.

    TRY.
        IF process_id IS INITIAL.
          l_is_new_run = 'X'.
          save( ).  "Prozess-ID ermitteln lassen (falls noch nicht vergeben)
        ENDIF.

        DO 1 TIMES.
          CASE process_type.
            WHEN 'AO_I'.      "Import Anordnungen
              IF l_is_new_run = 'X'.

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

              IF l_is_new_run = 'X'.
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


  METHOD process_import.

* obsolet
    ASSERT 1 = 2.

*
*    TYPES: BEGIN OF lty_param,
*             beleg   TYPE REF TO /thkr/s_de_beleg,
*             partner TYPE bu_partner,
*             lotkz   TYPE lotkz,
*           END OF lty_param.
*
*    TYPES: BEGIN OF lty_param_gp,
*             beleg TYPE REF TO /thkr/s_de_beleg,
*             gp    TYPE REF TO /thkr/s_de_gp,
*           END OF lty_param_gp.
*
*    DATA: l_param          TYPE lty_param,
*          l_param_gp       TYPE lty_param_gp,
*          l_cr_beleg       TYPE /thkr/s_dto_psm_ao_bel_create,
*          l_cr_gp          TYPE /thkr/s_dto_bp_create,
*          l_lotkz          TYPE lotkz,
*          l_oerror         TYPE REF TO cx_root,
*
*          l_ln_key         TYPE /thkr/event_ln_key,
*          l_ln_art         TYPE /thkr/event_ln_art,
*          lt_ln_evt        TYPE /thkr/t_ln_evt,
*          l_line_key_value TYPE string.
*
*    FIELD-SYMBOLS: <de_file> TYPE /thkr/s_de_file.
*
*    IF exch_data-status < '25'. "Daten noch nicht importiert
*      TRY.
*          read_file( ).
*
*          IF exch_data-status = '10'. "Daten liegen im txt-Format vor
*
*            convert_txt_to_inpdb( ).
*
*          ENDIF.
*
*          IF exch_data-status = '12'. "Textdaten wurden interpretiert
*
*            convert_inpdb_to_de_file( ).
*
*          ENDIF.
*
*          IF exch_data-status = '15'. "Daten liegen im Binärformat vor
*            CREATE DATA exch_data-proc_data TYPE /thkr/s_de_file.
*            ASSIGN exch_data-proc_data->* TO FIELD-SYMBOL(<proc_data>).
*
*            CALL TRANSFORMATION (dto_fv_pr_art-de_xslt)
*              SOURCE XML xml_string
*              RESULT file = <proc_data>.
*
*            ASSIGN exch_data-proc_data->* TO <de_file>.
*            IF test_suffix IS NOT INITIAL.
*              <de_file>-test_suffix = test_suffix.
*            ENDIF.
*
*            exch_data-status = '25'.  "Daten importiert
*          ENDIF.
*        CATCH cx_root INTO l_oerror.
*
*          add_event(
*            EXPORTING
*              i_exception = l_oerror ).
*
*      ENDTRY.
*      save( ).
*      COMMIT WORK.
*
*    ENDIF.
*
*    "    BREAK-POINT.
*
*    IF exch_data-status >= 25 AND is_test IS INITIAL.  "Daten sollen verarbeitet werden.
*
*      IF i_import_only IS NOT INITIAL.
*        RETURN.
*      ENDIF.
*
*      ASSIGN exch_data-proc_data->* TO <de_file>.
*      IF <de_file>-test_suffix IS NOT INITIAL.
*        test_suffix = <de_file>-test_suffix.
*      ENDIF.
*
*      SORT <de_file>-t_ao BY de_ao_id.
*      LOOP AT <de_file>-t_ao INTO DATA(l_ao).
*
*        IF test_suffix IS NOT INITIAL.
*          CONCATENATE l_ao-de_ao_id test_suffix INTO l_ao-de_ao_id.
*        ENDIF.
*
*        CLEAR: l_lotkz.
*        "Prüfen, ob schon ein Beleg der Anordnung erzeugt wurde.
*        READ TABLE t_ao1 WITH KEY de_ao_id = l_ao-de_ao_id INTO DATA(l_ao1).
*        IF sy-subrc = 0.
*          "Vorhandenes Bündelungskennzeichen verwenden.
*          l_lotkz = l_ao1-lotkz.
*        ENDIF.
*
*        CLEAR: l_cr_gp, l_cr_beleg.
*
*        LOOP AT l_ao-t_beleg REFERENCE INTO l_param-beleg.
*
*          IF test_suffix IS NOT INITIAL.
*            CONCATENATE l_param-beleg->de_beleg_id test_suffix INTO l_param-beleg->de_beleg_id.
*            CONCATENATE l_param-beleg->gp-de_gp_id test_suffix INTO l_param-beleg->gp-de_gp_id.
*          ENDIF.
*
*          IF i_de_satz_id IS NOT INITIAL AND l_param-beleg->de_beleg_id <> i_de_satz_id.
*            "Falls nur eine Zeile verarbeitet werden soll.
*            CONTINUE.
*          ENDIF.
*
*          TRY.
*              "Eventuell vorhandene Meldungen zur Zeile löschen
*              "Das soll auch für Zeilen geschehen, die mit diesem Lauf nicht mehr verarbeitet
*              "werden, da sie schon mit einem anderen Lauf verarbeitet wurden.
*
*              "Daten für Verknüpfung von Ereignissen mit Zeile
*              appl->get_key_ln_evt_by_imp_line(
*                EXPORTING
*                  i_process_type   = process_type
*                  i_process_id     = process_id
*                  i_imp_line_ref   = l_param-beleg
*                IMPORTING
*                  e_line_key_value = l_line_key_value
*                  e_ln_art         = l_ln_art
*                  e_ln_key         = l_ln_key
*                  et_ln_evt        = lt_ln_evt ).
*
*              "Bisherige Meldungen zur Zeile löschen
*              /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
*                  i_ln_art         = l_ln_art
*                  i_ln_key         = l_ln_key ).
*
*              COMMIT WORK.
*
*              "Prüfen, ob Beleg schon vorhanden
*              appl->get_dto_fremdver_beleg(
*                EXPORTING
*                  i_fremdverf  = fremdverf
*                  i_de_satz_id = l_param-beleg->de_beleg_id
**                 i_process_type =
*                IMPORTING
*                  e_dto        = DATA(l_dto_fremdverf_beleg) ).
*
*              IF l_dto_fremdverf_beleg IS NOT INITIAL AND l_dto_fremdverf_beleg-process_id <> process_id.
*                "Fehler: Datensatz bereits mit anderem Lauf verarbeitet
*
*                CREATE OBJECT l_oerror TYPE /thkr/cx_ext_if
*                  EXPORTING
*                    textid     = /thkr/cx_ext_if=>record_already_processed
*                    satz_id    = l_param-beleg->de_beleg_id
*                    process_id = l_dto_fremdverf_beleg-process_id.
*
*                add_event(
*                  EXPORTING
*                    i_event_category = 'E'
**                   i_event_category2 = ''
*                    i_exception      = l_oerror
*                    i_ln_art         = l_ln_art
*                    i_ln_key         = l_ln_key ).
*                CONTINUE.
*
*              ELSEIF l_dto_fremdverf_beleg IS INITIAL.
*                "Datensatz zur erstmaligen Verarbeitung
*                APPEND INITIAL LINE TO t_ao1 ASSIGNING FIELD-SYMBOL(<ao1>).
*                <ao1>-de_satz_id = l_param-beleg->de_beleg_id.
*                <ao1>-de_ao_id   = l_ao-de_ao_id.
*                <ao1>-de_gp_id   = l_param-beleg->gp-de_gp_id.
*              ELSE.
*                "Datensatz bereits (teilweise) verarbeitet
*                READ TABLE t_ao1 WITH KEY de_satz_id = l_param-beleg->de_beleg_id ASSIGNING <ao1>.
*              ENDIF.
*
*              IF <ao1>-run1_status < '10'.  "Geschäftspartner noch nicht erzeugt
*                "Geschäftspartner anlegen
*                <ao1>-run1_status = '09'.   "Fehler: Geschäftspartner
*
*                GET REFERENCE OF l_param-beleg->gp INTO l_param_gp-gp.
*                l_param_gp-beleg = l_param-beleg.
*
*                IF dto_fv_pr_art-gi_id_partner IS NOT INITIAL.
*                  gi_appl->get_data_by_gi(
*                    EXPORTING
*                      i_gi_id = dto_fv_pr_art-gi_id_partner
*                      i_para  = l_param_gp
*                    CHANGING
*                      c_data  = l_cr_gp ).
*                ENDIF.
*
*                IF dto_fv_pr_art-gi_id_partner2 IS NOT INITIAL.
*                  gi_appl->get_data_by_gi(
*                    EXPORTING
*                      i_gi_id = dto_fv_pr_art-gi_id_partner2
*                      i_para  = l_param_gp
*                    CHANGING
*                      c_data  = l_cr_gp ).
*                ENDIF.
*
*                /thkr/cl_bp_appl=>get_instance( )->create_partner(
*                  EXPORTING
*                    i_dto_bp_create = l_cr_gp
*                  IMPORTING
*                    e_partner       = <ao1>-partner ).
*
*
*                " mit nur COMMIT WORK AND WAIT  funktioniert das GP Update ab dem 2. Aufruf nicht
*                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*                  EXPORTING
*                    wait = abap_true
**                 IMPORTING
**                   RETURN        =
*                  .
*
** Aktuell werden Partner immer gesperrt, daher Sperre entfernen
** Wenn Ticket gelöst kann das wieder raus
*                WAIT UP TO 2 SECONDS.
*                /thkr/cl_bp_appl=>get_instance( )->release_partner(
*                  i_partner  = <ao1>-partner        " Geschäftspartnernummer
*                  i_test_run = l_cr_gp-test_run                 " Flag Testlauf Ja/nein
*                ).
*                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*                  EXPORTING
*                    wait = abap_true
**                 IMPORTING
**                   RETURN        =
*                  .
*
*                <ao1>-run1_status = '10'.   "Geschäftspartner angelegt
*
*              ENDIF.
*
*              IF <ao1>-run1_status < '20'.  "Anordnungsbeleg noch nicht erzeugt
*                "Anordnungsbeleg erzeugen
*                <ao1>-run1_status = '19'.   "Fehler Anordnungsbeleg
*                l_param-partner = <ao1>-partner.
*                l_param-lotkz   = l_lotkz.
*
*                IF dto_fv_pr_art-gi_id_psm_ao IS NOT INITIAL.
*                  gi_appl->get_data_by_gi(
*                    EXPORTING
*                      i_gi_id = dto_fv_pr_art-gi_id_psm_ao
*                      i_para  = l_param
*                    CHANGING
*                      c_data  = l_cr_beleg ).
*                ENDIF.
*
*                IF dto_fv_pr_art-gi_id_psm_ao2 IS NOT INITIAL.
*                  gi_appl->get_data_by_gi(
*                    EXPORTING
*                      i_gi_id = dto_fv_pr_art-gi_id_psm_ao2
*                      i_para  = l_param
*                    CHANGING
*                      c_data  = l_cr_beleg ).
*                ENDIF.
*
*                /thkr/cl_psm_ao_appl=>get_instance( )->create_psm_ao_beleg(
*                  EXPORTING
*                    i_dto_psm_ao_bel_create = l_cr_beleg
*                  IMPORTING
*                    e_psm_ao_document_number = DATA(ls_psm_ao_document_number) ).
*
**                COMMIT WORK AND WAIT.
*                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*                  EXPORTING
*                    wait = abap_true
**                 IMPORTING
**                   RETURN        =
*                  .
*                MOVE-CORRESPONDING ls_psm_ao_document_number TO <ao1>.
*
*                <ao1>-run1_status = '20'.   "Anordnungsbeleg erzeugt
*
*              ENDIF.
*
*            CATCH cx_root INTO DATA(l_oerror1).
*              ROLLBACK WORK.
*
*              CREATE OBJECT l_oerror TYPE /thkr/cx_ext_if
*                EXPORTING
*                  textid   = /thkr/cx_ext_if=>record_processing_error
*                  satz_id  = l_param-beleg->de_beleg_id
*                  previous = l_oerror1.
*
*              add_event(
*                EXPORTING
*                  i_event_category = 'E'
**                 i_event_category2 = ''
*                  i_exception      = l_oerror
*                  i_ln_art         = l_ln_art
*                  i_ln_key         = l_ln_key ).
*
*          ENDTRY.
*
*        ENDLOOP.
*
*      ENDLOOP.
*
*    ENDIF.
*
  ENDMETHOD.


  METHOD read.
    super->read( ).

    SELECT * INTO CORRESPONDING FIELDS OF TABLE @t_ao1
      FROM /thkr/de_run_ao1
      WHERE process_type = @process_type
        AND process_id   = @process_id.

  ENDMETHOD.


  METHOD save.

    DATA: l_de_run_ao1 TYPE /thkr/de_run_ao1.

    super->save( ).

    IF is_test IS INITIAL.
      LOOP AT t_ao1 INTO DATA(l_ao1).
        CLEAR: l_de_run_ao1.
        MOVE-CORRESPONDING l_ao1 TO l_de_run_ao1.
        l_de_run_ao1-process_type = process_type.
        l_de_run_ao1-process_id   = process_id.

        MODIFY /thkr/de_run_ao1 FROM l_de_run_ao1.

      ENDLOOP.
    ENDIF.

  ENDMETHOD.
ENDCLASS.

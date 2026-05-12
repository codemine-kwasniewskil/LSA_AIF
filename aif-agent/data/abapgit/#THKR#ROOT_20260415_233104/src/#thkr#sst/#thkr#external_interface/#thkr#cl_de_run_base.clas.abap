class /THKR/CL_DE_RUN_BASE definition
  public
  inheriting from /THKR/CL_BFW_PROCESS
  abstract
  create public .

public section.

  data FREMDVERF type /THKR/FREMDVERF read-only .

  methods CONSTRUCTOR
    importing
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE
      !I_FREMDVERF type /THKR/FREMDVERF optional
      !I_PROCESS_ID type /THKR/PROCESS_ID optional
      !I_PATH type PATHEXTERN optional
      !I_TEST type XFELD optional
      !I_TEST_SUFFIX type /THKR/TEST_SUFFIX optional .
  methods GET_PROC_DATA
    exporting
      !E_XMLSTR type XSTRING .
  methods PROCESS
  abstract
    importing
      !I_FILENAME type /THKR/FILE_W_PATH optional
      !I_FRONTEND type XFELD optional
      !I_IMPORT_ONLY type XFELD optional
      !I_DONT_MOVE_FILES type XFELD optional
      !I_DE_SATZ_ID type /THKR/DE_SATZ_ID optional
    exporting
      !E_ANOTHER_FILE_EXISTS type XFELD .

  methods READ
    redefinition .
  methods SAVE
    redefinition .
protected section.

  types:
    tty_string TYPE STANDARD TABLE OF string .
  types:
    BEGIN OF ty_exch_data,
      filename     TYPE file_name,      "Dateiname mit Pfad
      filename_wop TYPE file_name,      "Nur Dateiname
      frontend     TYPE xfeld,
      proc_data    TYPE REF TO data,
      status       TYPE /THKR/DE_RUN_STATUS,
      flag_saved   TYPE xfeld,
    END OF ty_exch_data .

  data APPL type ref to /THKR/CL_EXT_IF_APPL .
  data DTO_FV_PR_ART type /THKR/S_DTO_FV_PR_ART .
  data EXCH_DATA type TY_EXCH_DATA .
  data GI_APPL type ref to /THKR/CL_GI_APPL .
  data IS_TEST type XFELD .
  data KZ_IE type /THKR/KZ_IE .
  data PATH type PATHEXTERN .
  data TEST_SUFFIX type /THKR/TEST_SUFFIX .
  data TYPE_HANDLE_HEADER type ref to CL_ABAP_STRUCTDESCR .
  data TYPE_HANDLE_ITEM type ref to CL_ABAP_STRUCTDESCR .
  data TYPE_HANDLE_T_ITEM type ref to CL_ABAP_TABLEDESCR .
  data TYPE_HANDLE_T_ITEM_SORTED type ref to CL_ABAP_TABLEDESCR .
  data:
    t_string TYPE STANDARD TABLE OF string .
  data XML_STRING type XSTRING .
  data FI_DOC_SELECTION type /THKR/S_FI_DOCUMENT_SELECTION .

  methods CREATE_EXPORT_FILE
    raising
      /THKR/CX_LSA1 .
  methods FILL_FILENAME_IMPORT
    importing
      !I_FILENAME type /THKR/FILE_W_PATH optional
      !I_FRONTEND type XFELD optional
    exporting
      !E_ANOTHER_FILE_EXISTS type XFELD
    raising
      /THKR/CX_LSA1 .
  methods GENERATE_FILENAME
    exporting
      !E_FILENAME type FILE_NAME .
  methods READ_FILE
    raising
      /THKR/CX_EXT_IF .
private section.

  methods FILL_FILENAME_EXPORT .
ENDCLASS.



CLASS /THKR/CL_DE_RUN_BASE IMPLEMENTATION.


  METHOD constructor.

    DATA: l_save_proc    TYPE xfeld.

    IF i_test IS INITIAL.
      l_save_proc = 'X'.
    ENDIF.

    super->constructor(
      EXPORTING
        i_process_type = i_process_type
        i_process_id   = i_process_id
        i_save_proc    = l_save_proc ).

    IF i_test_suffix IS NOT INITIAL.
      test_suffix = i_test_suffix.
    ENDIF.

    IF i_process_id IS NOT INITIAL.
      "Für bereits gespeicherte Prozesse: Daten lesen
      SELECT SINGLE * INTO @DATA(ls_run_data)
        FROM /thkr/de_run
        WHERE process_type = @i_process_type
          AND process_id   = @i_process_id.
      MOVE-CORRESPONDING ls_run_data TO exch_data.
      fremdverf    = ls_run_data-fremdverf.
    ELSE.
      ASSERT i_fremdverf IS NOT INITIAL.
      fremdverf    = i_fremdverf.
    ENDIF.


    is_test = i_test.

    appl    = /thkr/cl_ext_if_appl=>get_instance( ).
    def     = /thkr/cl_ext_if_def=>get_instance( ).
    gi_appl = /thkr/cl_gi_appl=>get_instance( ).

    appl->get_dto_fv_pr_art(
      EXPORTING
        i_process_type = process_type
        i_fremdverf    = fremdverf
      IMPORTING
        e_dto          = dto_fv_pr_art ).

    "Abweichendes Ablageverzeichnis (Testlauf)
    path = i_path.

    IF dto_fv_pr_art-record_id_header IS NOT INITIAL.
      gi_appl->get_record_type_handles(
        EXPORTING
          i_record_id    = dto_fv_pr_art-record_id_header
        IMPORTING
          e_struct_descr = type_handle_header ).
    ENDIF.

    IF dto_fv_pr_art-record_id_item IS NOT INITIAL.
      gi_appl->get_record_type_handles(
        EXPORTING
          i_record_id          = dto_fv_pr_art-record_id_item
        IMPORTING
          e_struct_descr       = type_handle_item
          e_table_descr        = type_handle_t_item
          e_table_descr_sorted = type_handle_t_item_sorted ).
    ENDIF.

    IF type_handle_header IS NOT INITIAL.
      "Bei Importen oder XML-Exporten: Speicherbereich für Austauschdaten reservieren
      CREATE DATA exch_data-proc_data TYPE HANDLE type_handle_header.
    ENDIF.


  ENDMETHOD.


  METHOD create_export_file.

    DATA: l_xstring TYPE xstring,
          l_string  TYPE string,
          l_string1 TYPE string.

    FIELD-SYMBOLS: <file> TYPE any.

    fill_filename_export( ).

    ASSERT exch_data-filename IS NOT INITIAL.

    DATA(l_lf) = cl_abap_char_utilities=>cr_lf.

    IF dto_fv_pr_art-de_format = 'TXT'.  "Export als Text-Datei

      "Zeilen der String-Tabelle mit Zeilenumbruch zu Einzel-String verknüpfen
      LOOP AT t_string INTO l_string.
        IF l_string1 IS INITIAL.
          l_string1 = l_string.
        ELSE.
          CONCATENATE l_string1 l_string INTO l_string1 SEPARATED BY l_lf RESPECTING BLANKS.
        ENDIF.
      ENDLOOP.

      "Unicode-String in Zielformat konvertieren
      helpers->conv_cstring_to_xstring(
        EXPORTING
          i_string      = l_string1
          i_encoding    = '1100'                               "ISO 8859-1
          i_ignore_cerr = 'X'
        IMPORTING
          e_xstring     = l_xstring ).

      IF path IS NOT INITIAL. "Ablage auf dem Frontend - für Testzwecke

        helpers->gui_download_xstring(
          i_xstring  = l_xstring
          i_filename = CONV #( exch_data-filename ) ).

      ELSE. "Ablage auf dem Applikationsserver

        helpers->download_xstring(
          i_xstring  = l_xstring
          i_filename = CONV #( exch_data-filename ) ).

      ENDIF.

    ELSEIF dto_fv_pr_art-de_format = 'XML'.

      IF NOT path IS INITIAL.
        "Ablage auf dem Frontendserver (Testlauf)
        helpers->gui_download_xstring(
          i_xstring  = xml_string
          i_filename = CONV #( exch_data-filename ) ).
      ELSE.
        "Ablage auf dem Applikationsserver
        helpers->download_xstring(
          i_xstring  = xml_string
          i_filename = CONV #( exch_data-filename ) ).
      ENDIF.
    ENDIF.

*    GET TIME STAMP FIELD cr_file_time_stamp.

  ENDMETHOD.


  METHOD fill_filename_export.

    generate_filename(
      IMPORTING
        e_filename     = exch_data-filename_wop ).

    IF NOT path IS INITIAL.
      "Pfad extern über die Anwendung vergeben ->Ablage auf dem Frontend (Testlauf)
      CONCATENATE path '\' exch_data-filename_wop INTO exch_data-filename.
    ELSE.
      "Ablage auf dem Applikationsserver
      "In diesem Fall gleiche Aufbereitung
      CONCATENATE dto_fv_pr_art-pathextern exch_data-filename INTO exch_data-filename.
    ENDIF.

    CONDENSE exch_data-filename NO-GAPS.


  ENDMETHOD.


  METHOD FILL_FILENAME_IMPORT.

    IF i_filename IS INITIAL.
      "ToDo:
      "Ermittlung der nächsten im Übergabeverzeichnis zum Import anstehenden Datei
      "Falls weitere Dateien vorhanden sind, muss e_another_file_exists belegt werden.
      ASSERT 1 = 2.
    ELSE.
      exch_data-filename = i_filename.    "Dateiname inkl. Pfad
      exch_data-frontend = i_frontend.
    ENDIF.

  ENDMETHOD.


  METHOD generate_filename.

    DATA: l_extension TYPE c LENGTH 4.

    CLEAR e_filename.

    CASE dto_fv_pr_art-de_format.
      WHEN 'TXT'.
        l_extension = '.txt'.
      WHEN 'XML'.
        l_extension = '.xml'.
    ENDCASE.

    e_filename = process_id.
    CONDENSE e_filename.

    CONCATENATE 'E_' dto_fv_pr_art-fremdverf '_' process_type '_' def->md-system_prefix e_filename l_extension INTO e_filename.


  ENDMETHOD.


  METHOD get_proc_data.
* Für Testfunktionen können die Daten des Prozesses als XML bereitgestellt werden

    ASSIGN exch_data-proc_data->* TO FIELD-SYMBOL(<proc_data>).

    IF <proc_data> IS ASSIGNED AND <proc_data> IS NOT INITIAL.

      CALL TRANSFORMATION id
        SOURCE file = <proc_data>
        RESULT XML e_xmlstr.

    ENDIF.


  ENDMETHOD.


  METHOD read.

    DATA: lt_x255  TYPE /thkr/t_x255,
          l_xmlstr TYPE xstring.

    super->read( ).

    SELECT SINGLE fremdverf, filename, de_run_status AS status
      INTO ( @fremdverf, @exch_data-filename, @exch_data-status )
      FROM /thkr/de_run
      WHERE process_type = @process_type
        AND process_id   = @process_id.

    IF kz_ie = 'I'.  "Importschnittstelle

      CREATE DATA exch_data-proc_data TYPE HANDLE type_handle_header.


      SELECT x255 INTO TABLE @lt_x255
        FROM /thkr/proc_data
        WHERE process_type = @process_type
          AND process_id   = @process_id
        ORDER BY line_nr.

      IF lt_x255 IS NOT INITIAL.

        helpers->uncompress_xstring(
          EXPORTING
            it_x255   = lt_x255
          IMPORTING
            e_xstring = l_xmlstr ).

        ASSIGN exch_data-proc_data->* TO FIELD-SYMBOL(<proc_data>).

        CALL TRANSFORMATION id
          SOURCE XML l_xmlstr
          RESULT file = <proc_data>.

        exch_data-status     = '25'.  "Daten importiert
        exch_data-flag_saved = 'X'.   "Daten wurden mit dem Lauf bereits gespeichert.

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD read_file.

    TYPES lty_result TYPE x LENGTH 1024.

    DATA: lt_result TYPE STANDARD TABLE OF lty_result,
          l_file    TYPE /thkr/file_w_path,
          l_cstring TYPE string.

    l_file = exch_data-filename.

    IF exch_data-frontend IS NOT INITIAL.           "Testlauf

      cl_gui_frontend_services=>gui_upload(
        EXPORTING
          filename = CONV #( l_file )
          filetype = 'BIN'
        CHANGING
          data_tab = lt_result ).

      LOOP AT lt_result INTO DATA(l_result).
        CONCATENATE xml_string l_result INTO xml_string IN BYTE MODE.
      ENDLOOP.

    ELSE.

      OPEN DATASET l_file IN BINARY MODE FOR INPUT.

      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_ext_if
          MESSAGE e001(/thkr/eif) WITH l_file.
      ENDIF.

      READ DATASET l_file INTO xml_string.

      CLOSE DATASET l_file.

    ENDIF.

    IF dto_fv_pr_art-de_format = 'TXT'.
      "Binär eingelesene Textdatei in Text umwandeln
      /thkr/cl_helpers=>get_instance( )->conv_xstring_to_cstring(
        EXPORTING
          i_xstring = xml_string
          i_encoding = '1100'                               "ISO 8859-1
        IMPORTING
          e_string  = l_cstring ).

      SPLIT l_cstring AT cl_abap_char_utilities=>cr_lf INTO TABLE t_string.
      exch_data-status = '10'.  "Daten liegen im txt-Format vor
    ELSE.

      exch_data-status = '15'.  "Daten liegen im Binärformat vor
    ENDIF.

  ENDMETHOD.


  METHOD save.

    IF is_test IS NOT INITIAL.
      RETURN.
    ENDIF.

    super->save( ).

    DATA: l_xmlstr    TYPE xstring,
          l_gzipstr   TYPE xstring,
          l_de_run    TYPE /thkr/de_run,
          l_proc_data TYPE /thkr/proc_data.

    IF kz_ie = 'I'.  "Importschnittstelle
      IF exch_data-flag_saved IS INITIAL.

        ASSIGN exch_data-proc_data->* TO FIELD-SYMBOL(<proc_data>).

        IF <proc_data> IS ASSIGNED AND <proc_data> IS NOT INITIAL.

          CALL TRANSFORMATION id
            SOURCE file = <proc_data>
            RESULT XML l_xmlstr.

          helpers->compress_xstring(
            EXPORTING
              i_xstring = l_xmlstr
            IMPORTING
              et_x255   = DATA(lt_x255) ).

          DELETE FROM /thkr/proc_data
          WHERE process_type = @process_type
            AND process_id   = @process_id.

          CLEAR l_proc_data.
          l_proc_data-process_type = process_type.
          l_proc_data-process_id   = process_id.

          LOOP AT lt_x255 INTO l_proc_data-x255.
            ADD 1 TO l_proc_data-line_nr.
            INSERT /thkr/proc_data FROM l_proc_data.
          ENDLOOP.

          exch_data-flag_saved = 'X'.

        ENDIF.
      ENDIF.
    ENDIF.

    MOVE-CORRESPONDING exch_data TO l_de_run.
    l_de_run-process_type  = process_type.
    l_de_run-process_id    = process_id.
    l_de_run-de_run_status = exch_data-status.
    l_de_run-fremdverf = fremdverf.

    MODIFY /thkr/de_run FROM l_de_run.

  ENDMETHOD.
ENDCLASS.

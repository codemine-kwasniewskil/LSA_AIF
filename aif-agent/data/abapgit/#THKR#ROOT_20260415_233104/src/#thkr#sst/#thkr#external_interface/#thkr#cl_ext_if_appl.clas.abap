class /THKR/CL_EXT_IF_APPL definition
  public
  final
  create public .

public section.

  data DEF type ref to /THKR/CL_EXT_IF_DEF read-only .

  class-methods GET_INSTANCE
    exporting
      !E_INSTANCE type ref to /THKR/CL_EXT_IF_APPL
    returning
      value(R_INSTANCE) type ref to /THKR/CL_EXT_IF_APPL .
  methods CONSTRUCTOR .
  methods DELETE_RUN
    importing
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE
      !I_PROCESS_ID type /THKR/PROCESS_ID .
  methods GET_DE_FILE
    exporting
      !E_DE_FILE type /THKR/S_DE_FILE .
  methods GET_DTO_FREMDVER_BELEG
    importing
      !I_FREMDVERF type /THKR/FREMDVERF
      !I_DE_SATZ_ID type /THKR/DE_SATZ_ID
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE optional
    exporting
      !E_DTO type /THKR/S_DTO_FREMDVERF_BELEG .
  methods GET_DTO_FREMDVER_FIPOS
    importing
      !I_FREMDVERF type /THKR/FREMDVERF
      !I_FIPEX type FM_FIPEX
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE
    exporting
      !E_DTO type /THKR/S_DTO_FREMDVERF_PROCID .
  methods GET_DTO_FREMDVER_HVW
    importing
      !I_FREMDVERF type /THKR/FREMDVERF
      !I_DE_SATZ_ID type /THKR/DE_SATZ_ID
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE optional
    exporting
      !E_DTO type /THKR/S_DTO_FREMDVERF_PROCID .
  methods GET_DTO_FV_PR_ART
    importing
      !I_FREMDVERF type /THKR/FREMDVERF
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE
    exporting
      !E_DTO type /THKR/S_DTO_FV_PR_ART .
  methods GET_ID_FI_DOCUMENT
    importing
      !I_BUKRS type BUKRS
      !I_GJAHR type GJAHR
      !I_BELNR type BELNR_D
    exporting
      !E_ID type /THKR/ID_FI_DOCUMENT .
  methods GET_KEY_LN_EVT_BY_IMP_LINE
    importing
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE
      !I_PROCESS_ID type /THKR/PROCESS_ID
      !I_PROCESS_SUBTYPE type /THKR/PROCESS_SUBTYPE optional
      !I_IMP_LINE_REF type ref to DATA optional
      !I_LINE_KEY_VALUE type STRING optional
    exporting
      !E_LINE_KEY_VALUE type STRING
      !E_LN_ART type /THKR/EVENT_LN_ART
      !E_LN_KEY type /THKR/EVENT_LN_KEY
      !ET_LN_EVT type /THKR/T_LN_EVT .
  methods GET_KEY_LN_EVT_BY_PROCESS_DE
    importing
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE
      !I_PROCESS_ID type /THKR/PROCESS_ID
    exporting
      !E_LN_ART type /THKR/EVENT_LN_ART
      !E_LN_KEY type /THKR/EVENT_LN_KEY .
  methods GET_TDTO_DE_RUN
    importing
      !I_SELECTION type /THKR/S_DE_RUN_SELECTION
    exporting
      !ET_DTO type /THKR/T_DTO_DE_RUN .
  methods GET_TDTO_DE_RUN_AO1
    importing
      !I_SELECTION type /THKR/S_DE_RUN_AO1_SELECTION
    exporting
      !ET_DTO type /THKR/T_DTO_DE_RUN_AO1 .
  methods GET_TDTO_DE_RUN_FPO
    importing
      !I_SELECTION type /THKR/S_DE_RUN_FPO_SELECTION
    exporting
      !ET_DTO type /THKR/T_DTO_DE_RUN_FPO .
  methods GET_TDTO_DE_RUN_HVW
    importing
      !I_SELECTION type /THKR/S_DE_RUN_SELECTION
    exporting
      !ET_DTO type /THKR/T_DTO_DE_RUN_HVW .
  methods GET_T_INPBD
    exporting
      !ET_INPDB type /THKR/T_DE_INPDB .
  methods GET_XML_DATA_BY_RUN
    importing
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE
      !I_PROCESS_ID type /THKR/PROCESS_ID
    exporting
      !E_XMLSTR type XSTRING .
  methods PROCESS_EXPORT
    importing
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE
      !I_FREMDVERF type /THKR/FREMDVERF
      !I_FILENAME type /THKR/FILE_W_PATH
      !I_FRONTEND type XFELD
      !I_TEST_SUFFIX type /THKR/TEST_SUFFIX optional
      !I_TEST type XFELD optional
      !I_FI_DOC_SELECTION type /THKR/S_FI_DOCUMENT_SELECTION optional .
  methods PROCESS_IMPORT
    importing
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE
      !I_FREMDVERF type /THKR/FREMDVERF
      !I_FILENAME type /THKR/FILE_W_PATH
      !I_FRONTEND type XFELD
      !I_IMPORT_ONLY type XFELD
      !I_DONT_MOVE_FILES type XFELD
      !I_TEST_SUFFIX type /THKR/TEST_SUFFIX optional
      !I_TEST type XFELD optional .
  methods PROCESS_RUN
    importing
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE
      !I_PROCESS_ID type /THKR/PROCESS_ID
      !I_DE_SATZ_ID type /THKR/DE_SATZ_ID optional
      !I_FREMDVERF type /THKR/FREMDVERF optional .
  methods RESOLVE_ID_FI_DOCUMENT
    importing
      !I_ID type /THKR/ID_FI_DOCUMENT
    exporting
      !E_BUKRS type BUKRS
      !E_GJAHR type GJAHR
      !E_BELNR type BELNR_D .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA instance TYPE REF TO /thkr/cl_ext_if_appl .
    DATA de_run TYPE REF TO /thkr/cl_de_run_base .
    DATA helpers TYPE REF TO /thkr/cl_helpers .

    METHODS get_de_run
      IMPORTING
        !i_process_type     TYPE /thkr/process_type
        !i_process_id       TYPE /thkr/process_id OPTIONAL
        !i_fremdverf        TYPE /thkr/fremdverf OPTIONAL
        !i_test_suffix      TYPE /thkr/test_suffix OPTIONAL
        !i_test             TYPE xfeld OPTIONAL
        !i_fi_doc_selection TYPE /thkr/s_fi_document_selection OPTIONAL
      EXPORTING
        !e_de_run           TYPE REF TO /thkr/cl_de_run_base .
ENDCLASS.



CLASS /THKR/CL_EXT_IF_APPL IMPLEMENTATION.


  METHOD constructor.

    def = /thkr/cl_ext_if_def=>get_instance( ).
    helpers = /thkr/cl_helpers=>get_instance( ).

  ENDMETHOD.


  METHOD delete_run.
* Alle mit dem Prozess in Verbindung stehenden Daten werden gelöscht.
* Diese Methode nimmt keine Prüfungen vor, ob der übergebene Prozess gelöscht werden darf!

    DATA: l_evt_selection TYPE /thkr/s_event_selection.

* Ereignisse löschen
    l_evt_selection-process_type = i_process_type.
    l_evt_selection-process_id   = i_process_id.

    /thkr/cl_bfw_appl=>get_instance( )->get_tdto_event(
      EXPORTING
        i_selection = l_evt_selection
      IMPORTING
       e_tdto_event = DATA(lt_event) ).

    LOOP AT lt_event INTO DATA(l_event).

      DELETE FROM /thkr/ln_evt
      WHERE id = @l_event-id.

      DELETE FROM /thkr/evt_blob
      WHERE id = @l_event-id.

      DELETE FROM /thkr/event
      WHERE id = @l_event-id.

    ENDLOOP.

    DELETE FROM /thkr/de_run
    WHERE process_type = @i_process_type
      AND process_id   = @i_process_id.

    DELETE FROM /thkr/de_run_ao1
    WHERE process_type = @i_process_type
      AND process_id   = @i_process_id.

    DELETE FROM /thkr/process
    WHERE process_type = @i_process_type
      AND process_id   = @i_process_id.

    DELETE FROM /thkr/proc_data
    WHERE process_type = @i_process_type
      AND process_id   = @i_process_id.



  ENDMETHOD.


  METHOD get_de_file.

    DATA: l_de_run_ao TYPE REF TO /thkr/cl_de_run_ao.

    IF de_run IS NOT INITIAL.
      l_de_run_ao ?= de_run.

      l_de_run_ao->get_de_file(
        IMPORTING
          e_de_file = e_de_file ).
    ENDIF.

  ENDMETHOD.


  METHOD get_de_run.

    IF i_process_id = def->c_process_id-current_process
      AND de_run IS NOT INITIAL.
      "Es wird der gerade geladene Lauf angefragt
      e_de_run = de_run.

    ELSEIF i_process_id IS NOT INITIAL
      AND de_run IS NOT INITIAL
      AND de_run->process_type = i_process_type
      AND de_run->process_id   = i_process_id.
      "Wenn ein vorhandener Lauf angefragt ist, dann prüfen, ob es sich um die aktuell
      "geladene Instanz handelt und diese ggf. zurückgeben.

      e_de_run = de_run.
    ELSE.

      CASE i_process_type.
        WHEN def->c_process_type-anordnung.      "Import Anordnungen
          CREATE OBJECT e_de_run TYPE /thkr/cl_de_run_ao
            EXPORTING
              i_process_type = i_process_type
              i_fremdverf    = i_fremdverf
              i_process_id   = i_process_id
              i_test_suffix  = i_test_suffix
              i_test         = i_test.

        WHEN def->c_process_type-ist_rueckmeldng.      "Export Ist-Rückmeldungen
          CREATE OBJECT e_de_run TYPE /thkr/cl_de_run_rm
            EXPORTING
              i_process_type     = i_process_type
              i_fremdverf        = i_fremdverf
              i_process_id       = i_process_id
              i_test_suffix      = i_test_suffix
              i_test             = i_test
              i_fi_doc_selection = i_fi_doc_selection.

        WHEN def->c_process_type-funktionsplan
          OR def->c_process_type-gruppierungsplan
          OR def->c_process_type-einzelplan.   "Importe aus HAVWeb
          CREATE OBJECT e_de_run TYPE /thkr/cl_de_run_hvw
            EXPORTING
              i_process_type = i_process_type
              i_fremdverf    = i_fremdverf
*             i_path         =
              i_process_id   = i_process_id
              i_test_suffix  = i_test_suffix
              i_test         = i_test.

        WHEN OTHERS.
          ASSERT 1 = 2.
      ENDCASE.
    ENDIF.


  ENDMETHOD.


  METHOD get_dto_fremdver_beleg.

    DATA: l_select_clause TYPE string,
          l_where_clause  TYPE string.

    CLEAR: e_dto.

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_DE_RUN_AO1_K'
        i_prefix           = 'a'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    CONCATENATE 'b~process_id, b~fremdverf,' l_select_clause
      INTO l_select_clause SEPARATED BY space.

    l_where_clause = 'b~fremdverf  = @i_fremdverf AND a~de_satz_id = @i_de_satz_id'.
    IF i_process_type IS NOT INITIAL.
      CONCATENATE l_where_clause 'and a~process_type = @i_process_type'
        INTO l_where_clause SEPARATED BY space.
    ENDIF.

    SELECT SINGLE (l_select_clause) INTO CORRESPONDING FIELDS OF @e_dto
      FROM /thkr/de_run_ao1 AS a
        INNER JOIN /thkr/de_run AS b ON a~process_type = b~process_type AND a~process_id = b~process_id
      WHERE (l_where_clause).

  ENDMETHOD.


  METHOD get_dto_fremdver_hvw.

    DATA: l_select_clause TYPE string,
          l_where_clause  TYPE string.

    CLEAR: e_dto.

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_DE_RUN_HVW_K'
        i_prefix           = 'a'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    CONCATENATE 'b~process_id, b~fremdverf,' l_select_clause
      INTO l_select_clause SEPARATED BY space.

    l_where_clause = 'b~fremdverf  = @i_fremdverf AND a~de_satz_id = @i_de_satz_id'.
    IF i_process_type IS NOT INITIAL.
      CONCATENATE l_where_clause 'and a~process_type = @i_process_type'
        INTO l_where_clause SEPARATED BY space.
    ENDIF.

    SELECT SINGLE (l_select_clause) INTO CORRESPONDING FIELDS OF @e_dto
      FROM /thkr/de_run_hvw AS a
        INNER JOIN /thkr/de_run AS b ON a~process_type = b~process_type AND a~process_id = b~process_id
      WHERE (l_where_clause).

  ENDMETHOD.


  METHOD get_dto_fv_pr_art.

    CLEAR: e_dto.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF @e_dto
      FROM /thkr/cfv_pr_art
      WHERE fremdverf    = @i_fremdverf
        AND process_type = @i_process_type.

    ASSERT sy-subrc = 0.

    IF i_process_type = 'IR_E'. "Export Ist-Rückmeldungen
      e_dto-record_id_header = def->ir_e_rec_id_header.
      e_dto-record_id_item   = def->ir_e_rec_id_item.
    ENDIF.

  ENDMETHOD.


  METHOD get_id_fi_document.

    CLEAR: e_id.

    e_id(4)    = i_bukrs.
    e_id+4(4)  = i_gjahr.
    e_id+8(10) = i_belnr.

  ENDMETHOD.


  METHOD get_instance.

    IF instance IS INITIAL.

      CREATE OBJECT instance.

    ENDIF.

    e_instance = instance.
    r_instance = instance.

  ENDMETHOD.


  METHOD get_key_ln_evt_by_imp_line.

    FIELD-SYMBOLS: <line_key> TYPE any.

    CLEAR: e_line_key_value, e_ln_art, e_ln_key, et_ln_evt.

    get_key_ln_evt_by_process_de(
      EXPORTING
        i_process_type = i_process_type
        i_process_id   = i_process_id
      IMPORTING
        e_ln_art       = DATA(l_ln_art_proc)
        e_ln_key       = DATA(l_ln_key_proc) ).


    IF i_process_type = 'AO_I'.
      IF i_line_key_value IS NOT INITIAL.
        e_line_key_value = i_line_key_value.
      ELSE.
        ASSERT i_imp_line_ref IS NOT INITIAL.
        ASSIGN i_imp_line_ref->('DE_BELEG_ID') TO <line_key>.
        e_line_key_value = <line_key>.
      ENDIF.
      CONCATENATE l_ln_key_proc e_line_key_value INTO e_ln_key.

      e_ln_art = def->c_ln_art-anordnungsbeleg.
    ELSEIF i_process_type = def->c_process_type-funktionsplan
        OR i_process_type = def->c_process_type-gruppierungsplan
        OR i_process_type = def->c_process_type-einzelplan.
      IF i_line_key_value IS NOT INITIAL.
        e_line_key_value = i_line_key_value.
      ELSE.
        ASSERT i_imp_line_ref IS NOT INITIAL.
        CASE i_process_type.
          WHEN def->c_process_type-funktionsplan.
            ASSIGN i_imp_line_ref->('FUNKTION') TO <line_key>.
            e_ln_art = def->c_ln_art-funktionen.

          WHEN def->c_process_type-gruppierungsplan.
          WHEN def->c_process_type-einzelplan.
            CASE i_process_subtype.
              WHEN def->c_process_subtype-einzelplan.
                ASSIGN i_imp_line_ref->('EINZELPLAN') TO <line_key>.
                e_ln_art = def->c_ln_art-einzelplan.
              WHEN def->c_process_subtype-kapitel.
                ASSIGN i_imp_line_ref->('KAPITEL') TO <line_key>.
                e_ln_art = def->c_ln_art-kapitel.
              WHEN def->c_process_subtype-titelgruppe.
                ASSIGN i_imp_line_ref->('TITEL_GR') TO <line_key>.
                e_ln_art = def->c_ln_art-titel_gruppe.
              WHEN def->c_process_subtype-titel.
                ASSIGN i_imp_line_ref->('TITEL') TO <line_key>.
                e_ln_art = def->c_ln_art-titel.
            ENDCASE.

          WHEN OTHERS.
        ENDCASE.
        e_line_key_value = <line_key>.
      ENDIF.
      CONCATENATE l_ln_key_proc e_line_key_value INTO e_ln_key.
    ENDIF.

    IF e_ln_art IS NOT INITIAL AND e_ln_key IS NOT INITIAL.
      APPEND INITIAL LINE TO et_ln_evt ASSIGNING FIELD-SYMBOL(<ln_evt>).
      <ln_evt>-ln_art = e_ln_art.
      <ln_evt>-ln_key = e_ln_key.
    ENDIF.

  ENDMETHOD.


  METHOD get_key_ln_evt_by_process_de.

    DATA: l_process_id TYPE n LENGTH 8.

    FIELD-SYMBOLS: <line_key> TYPE string.

    e_ln_art = def->c_ln_art-process_type.

    l_process_id = i_process_id.

    e_ln_key(6)     = i_process_type.
    e_ln_key+6(8)   = l_process_id.

  ENDMETHOD.


  METHOD get_tdto_de_run.

    DATA: l_select_clause TYPE string,
          l_where_clause  TYPE string,
          l_and           TYPE string,
          l_x             TYPE xfeld.

    FIELD-SYMBOLS <dto> LIKE LINE OF et_dto.

    CLEAR: et_dto.

    l_x = 'X'.

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_PROCESS_K'
        i_prefix           = 'a'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_DE_RUN'
        i_prefix           = 'b'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).


    IF i_selection-process_type IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~process_type = @i_selection-process_type'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-r_process_id IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~process_id in @i_selection-r_process_id'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-fremdverf IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'b~fremdverf = @i_selection-fremdverf'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-r_datum IS NOT INITIAL.

      helpers->convert_range_datum_to_tmstmp(
        EXPORTING
          i_rdatum     = i_selection-r_datum
        IMPORTING
          e_rtimestamp = DATA(l_rtimestamp) ).


      CONCATENATE l_where_clause l_and
        'a~cr_time_stamp in @l_rtimestamp'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    SELECT (l_select_clause)
      INTO CORRESPONDING FIELDS OF TABLE @et_dto
      FROM /thkr/process AS a
      INNER JOIN /thkr/de_run AS b
        ON a~process_type = b~process_type AND a~process_id = b~process_id
      WHERE (l_where_clause).

    LOOP AT et_dto ASSIGNING <dto>.

      CONVERT TIME STAMP <dto>-cr_time_stamp TIME ZONE sy-zonlo
        INTO DATE <dto>-cr_date TIME <dto>-cr_time.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_tdto_de_run_ao1.

    DATA: l_select_clause TYPE string,
          l_where_clause  TYPE string,
          l_and           TYPE string,
          l_x             TYPE xfeld.

    FIELD-SYMBOLS <dto> LIKE LINE OF et_dto.

    CLEAR: et_dto.

    l_x = 'X'.

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_DE_RUN_AO1_K'
        i_prefix           = 'a'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    CONCATENATE 'a~process_type, a~process_id,' l_select_clause
      INTO l_select_clause SEPARATED BY space.

    IF i_selection-process_type IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~process_type = @i_selection-process_type'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-process_id IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~process_id = @i_selection-process_id'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    SELECT (l_select_clause)
      INTO CORRESPONDING FIELDS OF TABLE @et_dto
      FROM /thkr/de_run_ao1 AS a
      WHERE (l_where_clause).

  ENDMETHOD.


  METHOD get_tdto_de_run_hvw.

    DATA: l_select_clause TYPE string,
          l_where_clause  TYPE string,
          l_and           TYPE string,
          l_x             TYPE xfeld.

    FIELD-SYMBOLS <dto> LIKE LINE OF et_dto.

    CLEAR: et_dto.

    l_x = 'X'.

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_DE_RUN_HVW_K'
        i_prefix           = 'a'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    CONCATENATE 'a~process_type, a~process_id,' l_select_clause
      INTO l_select_clause SEPARATED BY space.

    IF i_selection-process_type IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~process_type = @i_selection-process_type'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-r_process_id IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~process_id in @i_selection-r_process_id'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    SELECT (l_select_clause)
      INTO CORRESPONDING FIELDS OF TABLE @et_dto
      FROM /thkr/de_run_hvw AS a
      WHERE (l_where_clause).

  ENDMETHOD.


  METHOD get_t_inpbd.

    DATA: l_de_run_ao TYPE REF TO /thkr/cl_de_run_ao.

    IF de_run IS NOT INITIAL.
      l_de_run_ao ?= de_run.

      l_de_run_ao->get_t_inpdb(
        IMPORTING
          et_inpdb = et_inpdb ).
    ENDIF.

  ENDMETHOD.


  METHOD get_xml_data_by_run.
    "Wenn I_PROCESS_ID = -1, dann aktuelle geladenen Prozess

    get_de_run(
      EXPORTING
        i_process_type = i_process_type
        i_process_id   = i_process_id
      IMPORTING
        e_de_run       = de_run ).

    de_run->get_proc_data(
      IMPORTING
        e_xmlstr = e_xmlstr ).


  ENDMETHOD.


  METHOD process_export.

    get_de_run(
      EXPORTING
        i_process_type = i_process_type
        i_fremdverf    = i_fremdverf
        i_test_suffix  = i_test_suffix
        i_test         = i_test
        i_fi_doc_selection = i_fi_doc_selection
      IMPORTING
        e_de_run       = de_run ).

    de_run->process(
      EXPORTING
        i_filename = i_filename
        i_frontend = i_frontend ).


    LOOP AT de_run->t_event INTO DATA(l_event).
      WRITE: / l_event-mess.

    ENDLOOP.

  ENDMETHOD.


  METHOD process_import.

    get_de_run(
      EXPORTING
        i_process_type = i_process_type
        i_fremdverf    = i_fremdverf
        i_test_suffix  = i_test_suffix
        i_test         = i_test
*        I_FI_DOC_SELECTION = I_FI_DOC_SELECTION
      IMPORTING
        e_de_run       = de_run ).

    de_run->process(
      EXPORTING
        i_filename        = i_filename
        i_frontend        = i_frontend
        i_import_only     = i_import_only
        i_dont_move_files = i_dont_move_files ).

    LOOP AT de_run->t_event INTO DATA(l_event).
      WRITE: / l_event-mess.

    ENDLOOP.

  ENDMETHOD.


  METHOD process_run.

    DATA: l_de_run TYPE REF TO /thkr/cl_de_run_base.

    get_de_run(
      EXPORTING
        i_process_type = i_process_type
        i_process_id   = i_process_id
        i_fremdverf    = i_fremdverf
      IMPORTING
        e_de_run       = l_de_run ).

    l_de_run->process(
      EXPORTING
        i_de_satz_id = i_de_satz_id ).

  ENDMETHOD.


  METHOD resolve_id_fi_document.

    CLEAR: e_bukrs, e_gjahr, e_belnr.

    e_bukrs = i_id(4).
    e_gjahr = i_id+4(4).
    e_belnr = i_id+8(10).

  ENDMETHOD.


  METHOD get_dto_fremdver_fipos.

    DATA: "l_select_clause TYPE string,
          l_where_clause  TYPE string.

    CLEAR: e_dto.

*    helpers->get_select_clause_from_struct(
*      EXPORTING
*        i_structure        = '/THKR/S_DE_RUN_HVW_K'
*        i_prefix           = 'a'
*        i_comma_separation = 'X'
*      CHANGING
*        c_select_clause    = l_select_clause ).

*    CONCATENATE 'b~process_id, b~fremdverf,' l_select_clause
*      INTO l_select_clause SEPARATED BY space.

    l_where_clause = 'b~fremdverf  = @i_fremdverf AND a~fipex = @i_fipex'.
    IF i_process_type IS NOT INITIAL.
      CONCATENATE l_where_clause 'and a~process_type = @i_process_type'
        INTO l_where_clause SEPARATED BY space.
    ENDIF.

    SELECT SINGLE a~RUN2_STATUS, b~process_id, b~fremdverf, a~fipex AS de_satz_id INTO CORRESPONDING FIELDS OF @e_dto
      FROM /thkr/de_run_fpo AS a
        INNER JOIN /thkr/de_run AS b ON a~process_type = b~process_type AND a~process_id = b~process_id
      WHERE (l_where_clause).

  ENDMETHOD.


  METHOD GET_TDTO_DE_RUN_FPO.

    DATA: l_select_clause TYPE string,
          l_where_clause  TYPE string,
          l_and           TYPE string,
          l_x             TYPE xfeld.

    FIELD-SYMBOLS <dto> LIKE LINE OF et_dto.

    CLEAR: et_dto.

    l_x = 'X'.

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_DE_RUN_FPO_K'
        i_prefix           = 'a'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    CONCATENATE 'a~process_type, a~process_id,' l_select_clause
      INTO l_select_clause SEPARATED BY space.

    IF i_selection-process_type IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~process_type = @i_selection-process_type'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-process_id IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~process_id = @i_selection-process_id'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    SELECT (l_select_clause)
      INTO CORRESPONDING FIELDS OF TABLE @et_dto
      FROM /thkr/de_run_FPO AS a
      WHERE (l_where_clause).

  ENDMETHOD.
ENDCLASS.

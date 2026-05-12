CLASS /thkr/cl_easy_alv DEFINITION
  PUBLIC
  INHERITING FROM cl_gui_alv_grid
  ABSTRACT
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA flag_changed TYPE xfeld READ-ONLY .

    EVENTS save_request .

    METHODS check_inputfield
      IMPORTING
        !i_fieldname     TYPE fieldname
        !i_status        TYPE string
      EXPORTING
        !e_is_inputfield TYPE xfeld .
    METHODS constructor
      IMPORTING
        VALUE(i_parent)      TYPE REF TO cl_gui_container
        VALUE(i_appl_events) TYPE char01 DEFAULT space
      EXCEPTIONS
        error_cntl_create
        error_cntl_init
        error_cntl_link
        error_dp_create .
    METHODS get_inputfields
      EXPORTING
        !et_inputfields TYPE /thkr/t_fieldname_with_status .
    METHODS initialize
      IMPORTING
        !is_variant       TYPE disvariant
        !i_editable       TYPE xfeld OPTIONAL
        !i_allow_new_line TYPE xfeld OPTIONAL
        !i_allow_del_line TYPE xfeld OPTIONAL
        !i_display_only   TYPE xfeld OPTIONAL
        !i_data_ref       TYPE REF TO data OPTIONAL
      CHANGING
        !cs_layout        TYPE lvc_s_layo
        !ct_data          TYPE data OPTIONAL .
    METHODS refresh_data
      IMPORTING
        !i_data_ref TYPE REF TO data OPTIONAL .
    METHODS set_inputfields
      IMPORTING
        !it_inputfields TYPE /thkr/t_fieldname_with_status .

    METHODS refresh_table_display
        REDEFINITION .
  PROTECTED SECTION.

    TYPES:
      BEGIN OF ty_labels,
        fieldname TYPE lvc_fname,
        scrtext_s TYPE scrtext_s,
        scrtext_m TYPE scrtext_m,
        scrtext_l TYPE scrtext_l,
      END OF ty_labels .
    TYPES:
      tty_labels TYPE STANDARD TABLE OF ty_labels .

    DATA allow_del_line TYPE xfeld .
    DATA allow_new_line TYPE xfeld .
    DATA uc_events TYPE xfeld .
    DATA checkboxfields TYPE fieldname_table .
    DATA current_row_index TYPE lvc_index .
    DATA editable TYPE xfeld .
    DATA fieldcat TYPE lvc_t_fcat .
    DATA fieldname_record_type TYPE fieldname VALUE 'überschreiben !' ##NO_TEXT.
    DATA fieldname_status TYPE fieldname VALUE 'überschreiben !' ##NO_TEXT.
    DATA fieldname_t_style TYPE fieldname VALUE 'T_STYLE' ##NO_TEXT.
    DATA inputfields TYPE /thkr/t_fieldname_with_status .
    DATA structure_name TYPE dd02l-tabname VALUE 'ZSBAU_DTO_SICHH_D' ##NO_TEXT.
    DATA sumfields TYPE fieldname_table .
    DATA tdto_ref TYPE REF TO data .
    DATA techfields TYPE fieldname_table .
    DATA t_data_ref TYPE REF TO data .
    DATA f4fields TYPE fieldname_table .
    DATA display_only TYPE xfeld .
    DATA mandatory_fields TYPE fieldname_table .
    DATA hotspots TYPE fieldname_table .
    DATA t_labels TYPE tty_labels .
    DATA t_fieldlist TYPE /thkr/t_structure_field .
    DATA t_fcat TYPE lvc_t_fcat .

    METHODS build_tdto_ref .
    METHODS build_t_data_ref
        ABSTRACT .
    METHODS get_inputfields_by_line_ref
      IMPORTING
        !i_line_ref         TYPE REF TO data
      EXPORTING
        !et_inputfields     TYPE fieldname_table
        !et_mandatoryfields TYPE fieldname_table .
    METHODS get_inputfields_current_row
      EXPORTING
        !et_inputfields TYPE fieldname_table .
    METHODS get_ln_event_by_line
      EXPORTING
        !et_ln_event TYPE /thkr/t_ln_evt .
    METHODS handle_data_changed
          FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING
          !er_data_changed
          !e_onf4
          !e_onf4_before
          !e_onf4_after
          !e_ucomm .
    METHODS handle_data_changed_finished
        FOR EVENT data_changed_finished OF cl_gui_alv_grid .
    METHODS handle_toolbar
          FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING
          !e_object
          !e_interactive .
    METHODS handle_user_command
          FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING
          !e_ucomm .
    METHODS modify_fieldcatalog_entry
      CHANGING
        !c_entry TYPE lvc_s_fcat .
    METHODS set_current_row_index .
    METHODS set_event_handler .
    METHODS set_fieldcatalog .
    METHODS set_styles .
  PRIVATE SECTION.

    METHODS show_events .
ENDCLASS.



CLASS /THKR/CL_EASY_ALV IMPLEMENTATION.


  METHOD build_tdto_ref.
*   Wenn der Methode initialize keine Datentabelle übergeben wurde, dann muss
*   in dieser Methode die Referenz auf die Datentabelle gesetzt werden.

*   Es darf nur die überschriebene Methode aufgerufen werden, daher:
    ASSERT 1 = 2.

  ENDMETHOD.


  METHOD check_inputfield.

    READ TABLE inputfields TRANSPORTING NO FIELDS
      WITH KEY status = i_status
            fieldname = i_fieldname.
    IF sy-subrc = 0.
      e_is_inputfield = 'X'.
    ELSE.
      CLEAR e_is_inputfield.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.
* Der Parameter i_appl_envents muss gesetzt werden, um PAI nach Eingaben im ALV auszulösen!

    super->constructor(
      EXPORTING
        i_parent          = i_parent
        i_appl_events     = i_appl_events
        ).

    CLEAR: structure_name, fieldname_status.

  ENDMETHOD.


  METHOD get_inputfields.

    et_inputfields = inputfields.

  ENDMETHOD.


  METHOD get_inputfields_by_line_ref.

    DATA: l_use_record_type TYPE xfeld,
          l_use_status      TYPE xfeld.

    FIELD-SYMBOLS: <status>      TYPE data,
                   <record_type> TYPE data.

    CLEAR et_inputfields.
    l_use_record_type = 'X'.
    l_use_status      = 'X'.

*   Status der Datenzeile ermitteln
    ASSIGN i_line_ref->(fieldname_status) TO <status>.
    IF sy-subrc <> 0.
*     Es gibt keine Abhängigkeit der Eingabefelder vom Status
      CLEAR: l_use_status.
    ENDIF.

*   Satzart ermitteln
    ASSIGN i_line_ref->(fieldname_record_type) TO <record_type>.
    IF sy-subrc <> 0.
      CLEAR l_use_record_type.
    ENDIF.

    IF l_use_status IS INITIAL AND l_use_record_type IS INITIAL.
*     Es wird weder mit Status, noch mit Satzart gearbeitet: alle Inputfields zurückgeben
      MOVE-CORRESPONDING inputfields TO et_inputfields.
      LOOP AT inputfields ASSIGNING FIELD-SYMBOL(<inputfield>) WHERE mandatory = 'X'.
        APPEND <inputfield>-fieldname TO et_mandatoryfields.
      ENDLOOP.
    ELSEIF l_use_record_type IS INITIAL.
*     Es wird ohne Satzart gearbeitet, nur mit Status
      LOOP AT inputfields ASSIGNING <inputfield> WHERE status = <status>.
        APPEND <inputfield>-fieldname TO et_inputfields.
        IF <inputfield>-mandatory = 'X'.
          APPEND <inputfield>-fieldname TO et_mandatoryfields.
        ENDIF.
      ENDLOOP.
    ELSEIF l_use_status IS INITIAL.
*     Es wird ohne Status gearbeitet, nur mit Satzart.
      LOOP AT inputfields ASSIGNING <inputfield> WHERE record_type = ''.
*       record_type = '': gilt für alle Satzarten
        APPEND <inputfield>-fieldname TO et_inputfields.
        IF <inputfield>-mandatory = 'X'.
          APPEND <inputfield>-fieldname TO et_mandatoryfields.
        ENDIF.
      ENDLOOP.
      LOOP AT inputfields ASSIGNING <inputfield> WHERE record_type = <record_type>.
        APPEND <inputfield>-fieldname TO et_inputfields.
        IF <inputfield>-mandatory = 'X'.
          APPEND <inputfield>-fieldname TO et_mandatoryfields.
        ENDIF.
      ENDLOOP.

    ELSE.
      LOOP AT inputfields ASSIGNING <inputfield> WHERE status = <status> AND record_type = ''.
*       record_type = '': gilt für alle Satzarten
        APPEND <inputfield>-fieldname TO et_inputfields.
        IF <inputfield>-mandatory = 'X'.
          APPEND <inputfield>-fieldname TO et_mandatoryfields.
        ENDIF.
      ENDLOOP.
      LOOP AT inputfields ASSIGNING <inputfield> WHERE status = <status> AND record_type = <record_type>.
        APPEND <inputfield>-fieldname TO et_inputfields.
        IF <inputfield>-mandatory = 'X'.
          APPEND <inputfield>-fieldname TO et_mandatoryfields.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD get_inputfields_current_row.

    DATA: l_fieldcatalog TYPE lvc_t_fcat,
          l_fcat_line    LIKE LINE OF l_fieldcatalog,
          l_styl         TYPE lvc_s_styl,
          l_line_ref     TYPE REF TO data.

    FIELD-SYMBOLS: <t_data>  TYPE STANDARD TABLE,
                   <status>  TYPE data,
                   <t_style> TYPE lvc_t_styl.

    ASSIGN t_data_ref->* TO <t_data>.

    IF current_row_index IS NOT INITIAL.
*     Es ist eine aktuelle Zeile bestimmt
      READ TABLE <t_data> INDEX current_row_index REFERENCE INTO l_line_ref.

      get_inputfields_by_line_ref(
        EXPORTING
          i_line_ref     = l_line_ref
        IMPORTING
          et_inputfields = et_inputfields ).

    ENDIF.
  ENDMETHOD.


  METHOD get_ln_event_by_line.
  ENDMETHOD.


  METHOD handle_data_changed.


    LOOP AT mandatory_fields INTO DATA(l_fieldname).

      LOOP AT er_data_changed->mt_good_cells ASSIGNING FIELD-SYMBOL(<cell>)
        WHERE fieldname = l_fieldname.

        IF <cell>-value IS INITIAL OR <cell>-value CO ' 0'.

*DATA I_MSGID     TYPE SYMSGID.
*DATA I_MSGTY     TYPE SYMSGTY.
*DATA I_MSGNO     TYPE SYMSGNO.
*DATA I_MSGV1     TYPE ANY.
*DATA I_MSGV2     TYPE ANY.
*DATA I_MSGV3     TYPE ANY.
*DATA I_MSGV4     TYPE ANY.
*DATA I_FIELDNAME TYPE LVC_FNAME.
*DATA I_ROW_ID    TYPE INT4.
*DATA I_TABIX     TYPE INT4.

          er_data_changed->add_protocol_entry(
              i_msgid     = 'OK'
              i_msgty     = 'E'
              i_msgno     = '001'
*    i_msgv1     = i_msgv1
*    i_msgv2     = i_msgv2
*    i_msgv3     = i_msgv3
*    i_msgv4     = i_msgv4
              i_fieldname = <cell>-fieldname
              i_row_id    = <cell>-row_id
*    i_tabix     = i_tabix
                 ).


        ENDIF.


      ENDLOOP.


    ENDLOOP.



  ENDMETHOD.


  METHOD handle_data_changed_finished.
*   Die Daten werden von der Tabelle des ALV (mit Style-Feldern)
*   auf die vom ALV zu ändernde tdto-Tabelle geschrieben. Hierbei
*   wird ein FLAG gesetzt, ob sich Daten geändert haben.

    DATA: l_tdto_old TYPE REF TO data,
          l_tdto_new TYPE REF TO data,
          l_line_ref TYPE REF TO data.

    FIELD-SYMBOLS: <t_data>      TYPE STANDARD TABLE,
                   <tdto>        TYPE STANDARD TABLE,
                   <tdto_old>    TYPE STANDARD TABLE,
                   <tdto_new>    TYPE STANDARD TABLE,
                   <field_value> TYPE data,
                   <table>       TYPE STANDARD TABLE,
                   <selected>    TYPE xfeld.


    ASSIGN t_data_ref->* TO <t_data>.
    ASSIGN tdto_ref->*   TO <tdto>.

    "Feld-Symbole für alten und neunen Stand initialisieren
    CREATE DATA l_tdto_old LIKE <tdto>.
    ASSIGN l_tdto_old->* TO <tdto_old>.
    CREATE DATA l_tdto_new LIKE <tdto>.
    ASSIGN l_tdto_new->* TO <tdto_new>.

    "alten Stand des DTOs merken.
    <tdto_old> = <tdto>.

    "DTO aus aktuellen Tabellendaten neu befüllen
    CLEAR <tdto>.
    MOVE-CORRESPONDING <t_data> TO <tdto>.

    "Beim Vergleich, ob sich Daten geändert haben, sollen bestimmte Felder ignoriert werden. Das
    "wird erreicht, indem diese Felder in den zu vergleichenden Tabellen <tdto> und <tdto_old>
    "gleichermaßen gelöscht werden.
    "Das sind die ev. vorhanden 'selected'-Felder, die nur zum markieren von Zeilen für bestimmte Aktionen
    "verwendet werden.

    "DTO mit neuem Stand befüllen (für Vergleich)
    <tdto_new> = <tdto>.

*   'selected'-Felder sollen beim Vergleich ignoriert werden
    LOOP AT <tdto_new> REFERENCE INTO l_line_ref.
      ASSIGN l_line_ref->('SELECTED') TO <selected>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      CLEAR: <selected>.
    ENDLOOP.

    LOOP AT <tdto_old> REFERENCE INTO l_line_ref.
      ASSIGN l_line_ref->('SELECTED') TO <selected>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      CLEAR: <selected>.
    ENDLOOP.

    "Tabellen, die in den Tabellenzeilen enthalten sind, müssen vor dem Vergleich sortiert werden
    LOOP AT t_fieldlist INTO DATA(l_fieldlist)
      WHERE datatype = 'TTYP'.

      LOOP AT <tdto_new> REFERENCE INTO l_line_ref.
        ASSIGN l_line_ref->(l_fieldlist-fieldname) TO <table>.
        SORT <table>.
      ENDLOOP.

      LOOP AT <tdto_old> REFERENCE INTO l_line_ref.
        ASSIGN l_line_ref->(l_fieldlist-fieldname) TO <table>.
        SORT <table>.
      ENDLOOP.

    ENDLOOP.

    SORT <tdto_new>.
    SORT <tdto_old>.

    IF <tdto_new> <> <tdto_old>.
      flag_changed = 'X'.

*     set_fieldcatalog( ).
      set_styles( ).

      refresh_table_display(
*        EXPORTING
*          is_stable      = is_stable
*          i_soft_refresh = i_soft_refresh
*        EXCEPTIONS
*          finished       = 1
*          others         = 2
             ).
      IF sy-subrc <> 0.
*       Implement suitable error handling here
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD handle_toolbar.

*   Default-Toolbar - ggf. überschreiben, die auskommentierten bleiben

    DATA: l_stb_button_wa TYPE stb_button,
          l_dummy         TYPE i.

    LOOP AT e_object->mt_toolbar  INTO l_stb_button_wa.
      IF  l_stb_button_wa-function = '&DETAIL'
       OR l_stb_button_wa-function = '&REFRESH'
       OR l_stb_button_wa-function = '&MB_SUM'
       OR l_stb_button_wa-function = '&MB_SUBTOT'
       OR l_stb_button_wa-function = '&PRINT_BACK'
       OR l_stb_button_wa-function = '&MB_EXPORT'
       OR l_stb_button_wa-function = '&INFO'
       OR l_stb_button_wa-function = '&MB_VIEW'
*       OR l_stb_button_wa-function = '&LOCAL&CUT'
*       OR l_stb_button_wa-function = '&LOCAL&COPY'
*       OR l_stb_button_wa-function = '&LOCAL&PASTE'
*       OR l_stb_button_wa-function = '&LOCAL&UNDO'
*       OR l_stb_button_wa-function = '&LOCAL&APPEND'
*       OR l_stb_button_wa-function = '&LOCAL&INSERT_ROW'
*       OR l_stb_button_wa-function = '&LOCAL&DELETE_ROW'
       OR l_stb_button_wa-function = '&CHECK'
*       OR l_stb_button_wa-function = '&LOCAL&COPY_ROW'
       OR l_stb_button_wa-function = '&GRAPH'.

        DELETE e_object->mt_toolbar.

      ENDIF.

      IF editable IS INITIAL AND (
           l_stb_button_wa-function = '&LOCAL&CUT'
        OR l_stb_button_wa-function = '&LOCAL&COPY'
        OR l_stb_button_wa-function = '&LOCAL&PASTE'
        OR l_stb_button_wa-function = '&LOCAL&UNDO'
        OR l_stb_button_wa-function = '&LOCAL&APPEND'
        OR l_stb_button_wa-function = '&LOCAL&INSERT_ROW'
        OR l_stb_button_wa-function = '&LOCAL&COPY_ROW').

        DELETE e_object->mt_toolbar.

      ENDIF.

      IF allow_new_line IS INITIAL AND (
           l_stb_button_wa-function = '&LOCAL&COPY'
        OR l_stb_button_wa-function = '&LOCAL&PASTE'
        OR l_stb_button_wa-function = '&LOCAL&APPEND'
        OR l_stb_button_wa-function = '&LOCAL&INSERT_ROW'
        OR l_stb_button_wa-function = '&LOCAL&COPY_ROW' ).
        DELETE e_object->mt_toolbar.
      ENDIF.

      IF allow_del_line IS INITIAL AND editable IS INITIAL AND
        l_stb_button_wa-function = '&LOCAL&DELETE_ROW'.
        DELETE e_object->mt_toolbar.
      ENDIF.

    ENDLOOP.

    IF uc_events IS NOT INITIAL.
*     Button für Ereignisanzeige einfügen
      CLEAR l_stb_button_wa.
      l_stb_button_wa-function = 'EVENTS'.
      l_stb_button_wa-icon     = icon_history.
      l_stb_button_wa-butn_type = 0.
*     l_stb_button_wa-text = text-001.
      "MOVE space TO l_stb_button_wa-disabled.
      APPEND l_stb_button_wa TO e_object->mt_toolbar.

    ENDIF.

    IF editable IS INITIAL AND allow_new_line IS NOT INITIAL.
*     Bei nicht editierbaren ALV Neu-Button einfügen
      CLEAR l_stb_button_wa.
      l_stb_button_wa-function = 'NEW_LINE'.
      l_stb_button_wa-icon     = icon_create.
      l_stb_button_wa-butn_type = 0.
*      l_stb_button_wa-text = text-001.
      "  MOVE space TO l_stb_button_wa-disabled.
      APPEND l_stb_button_wa TO e_object->mt_toolbar.

    ENDIF.

  ENDMETHOD.


  METHOD handle_user_command.

    DATA: lt_ln_event TYPE /thkr/t_ln_evt,
          l_oerror    TYPE REF TO cx_root.

    set_current_row_index( ).
    CASE e_ucomm.
      WHEN 'EVENTS'.
        show_events( ).
    ENDCASE.

  ENDMETHOD.


  METHOD initialize.

    DATA: l_fieldcatalog TYPE lvc_t_fcat,
          l_fcat_line    LIKE LINE OF l_fieldcatalog,
          l_styl         TYPE lvc_s_styl,
          l_descr_ref    TYPE REF TO cl_abap_typedescr.

    FIELD-SYMBOLS: <lvc_fcat> LIKE LINE OF l_fieldcatalog,
                   <t_data>   TYPE STANDARD TABLE.

    IF i_data_ref IS NOT INITIAL.
      tdto_ref = i_data_ref.
*    ELSEIF ct_data IS NOT INITIAL.
    ELSE.

      l_descr_ref = cl_abap_typedescr=>describe_by_data( p_data = ct_data ).
      IF l_descr_ref->kind = cl_abap_typedescr=>kind_table.
*       Auf ct_data wurde eine Tabelle übergeben
        GET REFERENCE OF ct_data INTO tdto_ref.
      ELSE.
*       ct_data wurde nicht übergeben
        build_tdto_ref( ).
      ENDIF.

    ENDIF.
    build_t_data_ref( ).
    ASSIGN t_data_ref->* TO <t_data>.

    cs_layout-stylefname = fieldname_t_style.

    IF i_display_only IS NOT INITIAL.
      display_only   = i_display_only.
    ELSE.
      editable       = i_editable.
      allow_new_line = i_allow_new_line.
      allow_del_line = i_allow_del_line.
    ENDIF.


    IF allow_del_line IS NOT INITIAL.
      set_ready_for_input(
          i_ready_for_input = 1 ).

    ENDIF.

    IF t_fcat IS INITIAL.
      ASSERT structure_name IS NOT INITIAL.

      /thkr/cl_helpers=>get_instance( )->get_fieldlist_from_struct(
        EXPORTING
          i_structure             = structure_name
        IMPORTING
          et_fieldlist            = t_fieldlist ).
    ENDIF.

    set_table_for_first_display(
       EXPORTING
         i_structure_name              = structure_name
         is_variant                    = is_variant
         i_save                        = 'A'
         is_layout                     = cs_layout
       CHANGING
         it_fieldcatalog               = t_fcat
         it_outtab                     = <t_data> ).

    set_event_handler( ).

    refresh_data( ).

  ENDMETHOD.


  METHOD modify_fieldcatalog_entry.

    READ TABLE t_labels WITH KEY fieldname = c_entry-fieldname INTO DATA(l_label).
    IF sy-subrc = 0.
      c_entry-scrtext_s = l_label-scrtext_s.
      c_entry-scrtext_m = l_label-scrtext_m.
      c_entry-scrtext_l = l_label-scrtext_l.
      c_entry-seltext   = l_label-scrtext_l.
      c_entry-tooltip   = l_label-scrtext_l.
      c_entry-reptext   = l_label-scrtext_l.
    ENDIF.

  ENDMETHOD.


  METHOD refresh_data.
*   Die Daten des ALV wurden von aussen geändert. Das ALV soll diese Daten
*   anzeigen.

    DATA: l_fieldcatalog TYPE lvc_t_fcat,
          l_fcat_line    LIKE LINE OF l_fieldcatalog,
          l_styl         TYPE lvc_s_styl,
          l_line_ref     TYPE REF TO data.

    FIELD-SYMBOLS: <lvc_fcat> LIKE LINE OF l_fieldcatalog,


                   <tdto>     TYPE STANDARD TABLE,
                   <t_data>   TYPE STANDARD TABLE,
                   <status>   TYPE data,
                   <t_style>  TYPE lvc_t_styl.

*                   <line>     LIKE LINE OF <t_data>.

    IF i_data_ref IS NOT INITIAL.
      tdto_ref = i_data_ref.
    ENDIF.

    ASSIGN tdto_ref->* TO <tdto>.
    ASSIGN t_data_ref->* TO <t_data>.
    MOVE-CORRESPONDING <tdto> TO <t_data>.

    set_styles( ).

    CLEAR flag_changed.

    refresh_table_display( ).

  ENDMETHOD.


  METHOD refresh_table_display.

    DATA: l_row_no TYPE lvc_s_roid,
          l_row_id TYPE lvc_s_row,
          l_col_id TYPE lvc_s_col.


    get_current_cell(
      IMPORTING
        es_row_id = l_row_id
        es_col_id = l_col_id
        es_row_no = l_row_no
        ).

    set_fieldcatalog( ).

    super->refresh_table_display(
      EXPORTING
        is_stable      = is_stable
        i_soft_refresh = i_soft_refresh
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2
        ).

    set_current_cell_via_id(
      EXPORTING
        is_row_id    = l_row_id
        is_column_id = l_col_id
        is_row_no    = l_row_no
        ).

  ENDMETHOD.


  METHOD set_current_row_index.

    DATA: lt_rows  TYPE lvc_t_row,
          lt_roid  TYPE lvc_t_roid,
          l_row_id TYPE lvc_s_row.

    "aktuelle Ziele ermitteln
    get_selected_rows(
      IMPORTING
        et_index_rows = lt_rows
        et_row_no     = lt_roid ).

    READ TABLE lt_rows ASSIGNING FIELD-SYMBOL(<row>) INDEX 1.
    IF sy-subrc = 0.
      current_row_index = <row>-index.
    ELSE.
      "oder einfach dort, wo der Cursor steht
      get_current_cell(
           IMPORTING
             es_row_id =  l_row_id ).

      current_row_index = l_row_id-index.
    ENDIF.

  ENDMETHOD.


  METHOD set_event_handler.

    SET HANDLER handle_data_changed_finished FOR me.
    SET HANDLER handle_toolbar FOR me.
    SET HANDLER handle_user_command FOR me.
    SET HANDLER handle_data_changed FOR me.

  ENDMETHOD.


  METHOD set_fieldcatalog.

    DATA: l_fieldcatalog TYPE lvc_t_fcat,
          l_fcat_line    LIKE LINE OF l_fieldcatalog,
          l_styl         TYPE lvc_s_styl,
          l_line_ref     TYPE REF TO data.

    FIELD-SYMBOLS: <fcat>    LIKE LINE OF l_fieldcatalog,
                   <t_data>  TYPE STANDARD TABLE,
                   <status>  TYPE data,
                   <t_style> TYPE lvc_t_styl.


    get_frontend_fieldcatalog(
      IMPORTING
        et_fieldcatalog = l_fieldcatalog ).

    LOOP AT l_fieldcatalog ASSIGNING <fcat>.

      READ TABLE techfields WITH KEY fieldname = <fcat>-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        <fcat>-tech = 'X'.
      ENDIF.

      READ TABLE hotspots WITH KEY fieldname = <fcat>-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        <fcat>-hotspot = 'X'.
      ENDIF.

      IF editable IS NOT INITIAL.
        READ TABLE inputfields WITH KEY fieldname = <fcat>-fieldname TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          <fcat>-edit = 'X'.
        ELSE.
          CLEAR <fcat>-edit.
        ENDIF.
      ENDIF.

      READ TABLE checkboxfields WITH KEY fieldname = <fcat>-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        <fcat>-checkbox = 'X'.
      ENDIF.

      READ TABLE sumfields WITH KEY fieldname = <fcat>-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        <fcat>-do_sum = 'X'.
      ENDIF.

      READ TABLE f4fields WITH KEY fieldname = <fcat>-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        <fcat>-f4availabl = 'X'.
      ENDIF.

      modify_fieldcatalog_entry( CHANGING c_entry = <fcat> ).

    ENDLOOP.

    set_frontend_fieldcatalog(
      EXPORTING
        it_fieldcatalog = l_fieldcatalog ).

  ENDMETHOD.


  METHOD set_inputfields.

    inputfields = it_inputfields.

  ENDMETHOD.


  METHOD set_styles.

    DATA: l_fieldcatalog    TYPE lvc_t_fcat,
          l_fcat_line       LIKE LINE OF l_fieldcatalog,
          l_styl            TYPE lvc_s_styl,
          l_line_ref        TYPE REF TO data,
          l_use_record_type TYPE xfeld,
          lt_inputfields    TYPE fieldname_table.

    FIELD-SYMBOLS: <t_data>      TYPE STANDARD TABLE,
                   <status>      TYPE data,
                   <record_type> TYPE data,
                   <t_style>     TYPE lvc_t_styl.

    l_use_record_type = 'X'.

    IF editable IS NOT INITIAL.

      get_frontend_fieldcatalog(
        IMPORTING
          et_fieldcatalog = l_fieldcatalog ).

*   Änderbarkeit auf Feldebene setzen
      ASSIGN t_data_ref->* TO <t_data>.

      LOOP AT <t_data> REFERENCE INTO l_line_ref.
*     Über alle Zeilen der Datentabelle des ALV iterieren.

*       Style-Feld der Datenzeile ermitteln
        ASSIGN l_line_ref->(fieldname_t_style) TO <t_style>.
        IF sy-subrc <> 0.
*         Es wird nicht mit Style gearbeitet, daher:
          EXIT.
        ENDIF.

        CLEAR <t_style>.

        get_inputfields_by_line_ref(
          EXPORTING
            i_line_ref     = l_line_ref
          IMPORTING
            et_inputfields = lt_inputfields ).


        LOOP AT l_fieldcatalog INTO l_fcat_line.
          IF l_fcat_line-fieldname = fieldname_t_style.
            CONTINUE.
          ENDIF.

          READ TABLE lt_inputfields WITH KEY fieldname = l_fcat_line-fieldname TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
*           Das Feld soll eingabebereit sein.
          ELSE.
*           Eingabebereitschaft entfernen
            l_styl-fieldname = l_fcat_line-fieldname.
            l_styl-style = cl_gui_alv_grid=>mc_style_disabled.
            INSERT l_styl INTO TABLE <t_style>.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD show_events.

    DATA: l_salv_event TYPE REF TO /thkr/cl_salv_event,
          lt_ln_event  TYPE /thkr/t_ln_evt,
          l_ln_event   LIKE LINE OF lt_ln_event,
          l_selection  TYPE /thkr/s_event_selection.

    CREATE OBJECT l_salv_event.

    get_ln_event_by_line(
      IMPORTING
        et_ln_event = lt_ln_event ).

    l_selection-t_ln_event = lt_ln_event.
    TRY.
        l_salv_event->display(
          EXPORTING
            i_selection = l_selection ).

      CATCH cx_root INTO DATA(l_oerror).
        /thkr/cl_helpers=>get_instance( )->display_exception( i_oerror = l_oerror ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.

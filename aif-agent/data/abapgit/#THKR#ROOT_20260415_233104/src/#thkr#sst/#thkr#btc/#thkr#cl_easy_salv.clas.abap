class /THKR/CL_EASY_SALV definition
  public
  abstract
  create public .

public section.
  type-pools ICON .
  interface IF_SALV_C_REFRESH load .

  events DATA_CHANGED
    exporting
      value(ET_DATA_REF) type ref to DATA .

  methods CONSTRUCTOR .
  methods DISPLAY
    importing
      !I_SELECTION type DATA optional
      !I_VARI type SLIS_VARI optional
      !I_CONTAINER type ref to CL_GUI_CONTAINER optional
    raising
      /THKR/CX_LSA1 .
  methods REFRESH
    importing
      !S_STABLE type LVC_S_STBL optional
      !REFRESH_MODE type SALV_DE_CONSTANT default IF_SALV_C_REFRESH=>SOFT
    raising
      /THKR/CX_LSA1 .
  methods GET_CURRENT_CELL
    exporting
      !E_CURRENT_CELL type SALV_S_CELL .
  methods SET_CURRENT_CELL
    importing
      !I_ROW type INT4 default 1 .
protected section.

  types:
    fieldname_table TYPE STANDARD TABLE OF lvc_fname .

  data COLOR_COLUMN type LVC_FNAME .
  data T_DATA_REF type ref to DATA .
  data SALV type ref to CL_SALV_TABLE .
  data SELECTION type ref to DATA .
  data NAME_FUGR type SYREPID value 'Zuweisen!' ##NO_TEXT.
  data GUI_STATUS type SYPFKEY value 'Zuweisen!' ##NO_TEXT.
  data GUI_TITLE type LVC_TITLE value 'Zuweisen!' ##NO_TEXT.
  data HOTSPOTS type FIELDNAME_TABLE .
  data REPORT_NAME type REPID .
  data TECHFIELDS type FIELDNAME_TABLE .
  data LEADING_ZERO type FIELDNAME_TABLE .
  data IS_CHANGEABLE type XFELD .
  data IS_FULLSCREEN type XFELD .
  data F4_FIELDS type FIELDNAME_TABLE .
  data CHECKBOXFIELDS type FIELDNAME_TABLE .
  data CHECKBOXES_AS_HOTSPOTS type XFELD value 'X' ##NO_TEXT.
  data POPUP_START_COLUMN type I .
  data POPUP_END_COLUMN type I .
  data POPUP_START_LINE type I .
  data POPUP_END_LINE type I .

  methods GET_SELECTED_ROWS
    exporting
      !ET_ROWS type SALV_T_ROW .
  methods SET_COLOR .
  methods SET_SELECTION .
  methods HANDLE_ADDED_FUNCTION
    for event ADDED_FUNCTION of CL_SALV_EVENTS_TABLE
    importing
      !E_SALV_FUNCTION .
  methods FILL_DATA
  abstract
    raising
      /THKR/CX_LSA1 .
  methods HANDLE_SALV_FUNCTIONS .
  methods SET_EVENT_HANDLING .
  methods HANDLE_COLUMNS .
private section.

  data CURRENT_CELL type SALV_S_CELL .
ENDCLASS.



CLASS /THKR/CL_EASY_SALV IMPLEMENTATION.


  METHOD CONSTRUCTOR.

  ENDMETHOD.


  METHOD DISPLAY.

    DATA: l_salv_functions TYPE REF TO cl_salv_functions_list,
          l_layout         TYPE REF TO cl_salv_layout,
          l_display        TYPE REF TO cl_salv_display_settings,
          l_columns        TYPE REF TO cl_salv_columns_table,
          l_column         TYPE REF TO cl_salv_column_table,
          l_layout_key     TYPE salv_s_layout_key,
          l_fieldname      TYPE LINE OF fieldname_table.

    IF i_selection IS SUPPLIED.
      GET REFERENCE OF i_selection INTO selection.
    ENDIF.

    FIELD-SYMBOLS <t_data> TYPE STANDARD TABLE.

* Anzuzeigenden Daten beschaffen
    fill_data( ).

    ASSIGN t_data_ref->* TO <t_data>.

    IF i_container IS INITIAL.

* ALV erzeugen lassen
      TRY.
          cl_salv_table=>factory(
            IMPORTING
              r_salv_table = salv
            CHANGING
              t_table = <t_data> ).
        CATCH cx_salv_msg.
      ENDTRY.

      salv->set_screen_status(
          report        = name_fugr
          pfstatus      = gui_status ).

      is_fullscreen = 'X'.

    ELSE.

*   ALV erzeugen lassen
      TRY.
          cl_salv_table=>factory(
            EXPORTING
              r_container = i_container
            IMPORTING
              r_salv_table = salv
            CHANGING
              t_table = <t_data> ).

        CATCH cx_salv_msg.
      ENDTRY.

      CLEAR is_fullscreen.

    ENDIF.

    TRY.
*       Funktionen bearbeiten
        l_salv_functions = salv->get_functions( ).
        l_salv_functions->set_all( abap_true ).

        handle_salv_functions( ).

        l_display = salv->get_display_settings( ).
        l_display->set_list_header( gui_title ).

*       Spalteneinstellungen anpassen
        l_columns = salv->get_columns( ).

*       technische Felder ausblenden
        LOOP AT techfields INTO l_fieldname.

          l_column ?= l_columns->get_column( l_fieldname ).
          l_column->set_technical( ).

        ENDLOOP.

*       Checkbox als solche markieren
        LOOP AT checkboxfields INTO l_fieldname.

          l_column ?= l_columns->get_column( l_fieldname ).
          IF checkboxes_as_hotspots IS NOT INITIAL.
            l_column->set_cell_type(
              EXPORTING
                value = if_salv_c_cell_type=>checkbox_hotspot ).
          ELSE.
            l_column->set_cell_type(
              EXPORTING
                value = if_salv_c_cell_type=>checkbox ).
          ENDIF.

        ENDLOOP.

*       Hot Spots definieren
        LOOP AT hotspots INTO l_fieldname.

          l_column ?= l_columns->get_column( l_fieldname ).
          l_column->set_cell_type(
            EXPORTING
                value = if_salv_c_cell_type=>hotspot ).
        ENDLOOP.

*       Führende Nullen anzeigen
        LOOP AT leading_zero INTO l_fieldname.

          l_column ?= l_columns->get_column( l_fieldname ).
          l_column->set_leading_zero( ).

        ENDLOOP.



*       Eventverarbeitung festlegen
        set_event_handling( ).

*       Layout anpassen
        l_layout = salv->get_layout( ).

        l_layout_key-report = report_name.
        l_layout->set_key( l_layout_key ).
        l_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
*       Speichern als Voreinstellung erlauben
        l_layout->set_default( 'X' ).

        IF i_vari IS NOT INITIAL.
          l_layout->set_initial_layout( i_vari ).
        ENDIF.

*       Selektion anpassen
        set_selection( ).

*       Farben behandeln
        IF color_column IS NOT INITIAL.
*         Spalte mit Farbcodierung definieren (setzt Spalte auch "technisch",
*         sonst Probleme, da Farbfeld Tabelle ist
          TRY.
              l_columns->set_color_column( color_column ).
            CATCH cx_salv_data_error.                   "#EC NO_HANDLER
          ENDTRY.
*         Farben konkret setzen
          set_color( ).
        ENDIF.

        handle_columns( ).

*       SALV aus PopUp
        IF popup_end_column IS NOT INITIAL AND is_fullscreen = 'X'.
          salv->set_screen_popup(
            start_column = popup_start_column
            end_column   = popup_end_column
            start_line   = popup_start_line
            end_line     = popup_end_line ).
        ENDIF.

      CATCH cx_salv_not_found INTO DATA(l_oerror).
        ASSERT 1 = 2.
    ENDTRY.

    salv->display( ).

  ENDMETHOD.


  METHOD GET_CURRENT_CELL.
* aktuelle Cursorposition bestimmen

    DATA: l_selections  TYPE REF TO cl_salv_selections.

    l_selections = salv->get_selections( ).

    IF l_selections IS NOT INITIAL.
      e_current_cell = l_selections->get_current_cell( ).
      current_cell = e_current_cell.
    ENDIF.

  ENDMETHOD.


  METHOD GET_SELECTED_ROWS.

    DATA: l_selections        TYPE REF TO cl_salv_selections.

    l_selections = salv->get_selections( ).
    et_rows = l_selections->get_selected_rows( ).

  ENDMETHOD.


  METHOD HANDLE_ADDED_FUNCTION.


  ENDMETHOD.


  method HANDLE_COLUMNS.
  endmethod.


  METHOD HANDLE_SALV_FUNCTIONS.
  ENDMETHOD.


  METHOD REFRESH.

    fill_data( ).

    set_color( ).
    salv->refresh(
      EXPORTING
        s_stable = s_stable
        refresh_mode = refresh_mode
        ).

  ENDMETHOD.


  METHOD SET_COLOR.
* generische Methode zum Färben von Spalten, Zeilen oder Zellen

* eigentliche Einfärbung muss in der Redefinition implementiert werden!

  ENDMETHOD.


  METHOD SET_CURRENT_CELL.
* aktuelle Cursorposition setzen
* aktuelle Varianten:
*  - ohne Parameter auf Klassenattribut
*  - mit übergebner Zeile auf diese

    DATA: l_value      TYPE salv_s_cell,
          l_selections TYPE REF TO cl_salv_selections.

    l_selections = salv->get_selections( ).

    IF i_row <> 1.
      l_value-row = i_row.
    ELSE.
      l_value = current_cell.
    ENDIF.

    IF l_selections IS NOT INITIAL.
      l_selections->set_current_cell(
      EXPORTING
         value = l_value  ).
    ENDIF.

  ENDMETHOD.


  METHOD SET_EVENT_HANDLING.

    DATA: l_events         TYPE REF TO cl_salv_events_table.

* Eventverarbeitung festlegen
    l_events = salv->get_event( ).
    SET HANDLER handle_added_function FOR l_events.


  ENDMETHOD.


  METHOD SET_SELECTION.
* leer, nur für Redefinition
  ENDMETHOD.
ENDCLASS.

*----------------------------------------------------------------------*
***INCLUDE LZLSA_GI_SHLPF01.
*----------------------------------------------------------------------*

FORM set_tabname_filter USING p_filter_id
                              p_field.

  IF g_filter_id <> p_filter_id OR g_field <> p_field.
*   Nur bei geänderten Parametern

    CLEAR: g_tabname, g_record_id.

    IF g_gi IS INITIAL.

      /thkr/cl_gi_appl=>get_instance(
        IMPORTING
          e_instance = g_gi ).

    ENDIF.

    IF p_field = 'RECORD_FLD' OR p_field = 'RECORD_FLD2'.

      g_gi->get_dto_filter(
        EXPORTING
          i_filter_id = p_filter_id
        IMPORTING
          e_dto       = DATA(l_dto_filter) ).

      CLEAR: g_tabname, g_record_id.

      IF l_dto_filter-record_id IS NOT INITIAL.
        g_record_id = l_dto_filter-record_id.
      ELSE.
        g_tabname = l_dto_filter-gi_structure.
      ENDIF.

    ENDIF.

    g_filter_id = p_filter_id.
    g_field     = p_field.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form set_tabname
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> L_GI_ID
*&      --> L_GI_MC
*&      --> L_GI_MP_TAB
*&      --> L_FIELD
*&---------------------------------------------------------------------*
FORM set_tabname  USING    p_gi_id
                           p_gi_mc
                           p_gi_mp_tab
                           p_field.

  IF g_gi_id <> p_gi_id OR g_gi_mc <> p_gi_mc OR g_gi_mp_tab <> p_gi_mp_tab OR g_field <> p_field.
*   Nur bei geänderten Parametern

    CLEAR: g_tabname, g_record_id, g_gi_mp_tab_type.

    IF g_gi IS INITIAL.

      /thkr/cl_gi_appl=>get_instance(
        IMPORTING
          e_instance = g_gi ).

    ENDIF.

    IF p_field = 'GI_FIELD'
      OR p_field = 'TABLE_FIELD'. "Trägerstruktur-Feld vom Typ Tabelle


      IF p_field = 'TABLE_FIELD' AND g_record_id IS INITIAL.
*       Abfrage eines Feldes der Schnittstellen-Trägerstruktur
        g_gi->get_structure_gi(
          EXPORTING
            i_gi_id        = p_gi_id
          IMPORTING
            e_structure_if = g_tabname
            e_record_id    = g_record_id ).

      ELSEIF p_gi_mp_tab IS NOT INITIAL.
*       Abfrage eines Feldes der Schnittstellentabelle-Trägerstruktur
        g_gi->get_structure_gi_tab(
          EXPORTING
            i_gi_id            = p_gi_id
            i_gi_mc            = p_gi_mc
            i_gi_mp_tab        = p_gi_mp_tab
          IMPORTING
            e_if_tab_structure = g_tabname
            e_record_id        = g_record_id
            e_gi_mp_tab_type   = g_gi_mp_tab_type ).
*       g_tabname und g_record_id leer? -> auf die normale Trägerstruktur mappen
      ENDIF.

      IF g_tabname IS INITIAL AND g_record_id IS INITIAL.
*       Abfrage eines Feldes der Schnittstellen-Trägerstruktur
        g_gi->get_structure_gi(
          EXPORTING
            i_gi_id        = p_gi_id
          IMPORTING
            e_structure_if = g_tabname
            e_record_id    = g_record_id ).

      ENDIF.

    ELSEIF p_field = 'DTO_FIELD'.

      IF p_gi_mp_tab IS INITIAL.
*     Abfrage eines Feldes der DTO-Struktur der Zuordnungsgruppe

        g_gi->get_structure_mc_dto(
          EXPORTING
            i_gi_id             = p_gi_id
            i_gi_mc             = p_gi_mc
          IMPORTING
            e_structure_dto     = g_tabname
            e_record_id         = g_record_id
            e_gi_mc_data_source = g_gi_mc_data_source ).

      ELSE.
*       Abfrage eines Feldes der TDTO-Zeilenstruktur

        g_gi->get_structure_tab_dto(
          EXPORTING
            i_gi_id             = p_gi_id
            i_gi_mc             = p_gi_mc
            i_gi_mp_tab         = p_gi_mp_tab
          IMPORTING
            e_tab_dto_structure = g_tabname
            e_record_id         = g_record_id
            e_gi_mc_data_source = g_gi_mc_data_source ).

      ENDIF.

    ELSEIF p_field = 'COMPARISION_VALUE' OR p_field = 'VALUE_TRUE' OR p_field = 'VALUE_FALSE'
      OR p_field = 'LINE_KEY_VALUE' OR p_field = 'LINE_KEY_VALUE2' OR p_field = 'LINE_KEY_VALUE3'.
      g_tabname = '{PARAM}'.

    ENDIF.

    g_gi_id     = p_gi_id.
    g_gi_mc     = p_gi_mc.
    g_gi_mp_tab = p_gi_mp_tab.
    g_field     = p_field.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form step_select
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> RECORD_TAB
*&      --> SHLP_TAB
*&      <-- SHLP
*&      <-- CALLCONTROL
*&      <-- RC
*&---------------------------------------------------------------------*
FORM step_select  TABLES   p_record_tab
                           p_shlp_tab
                  CHANGING p_shlp
                           p_callcontrol
                           p_rc.

  DATA: lt_fieldlist       TYPE /thkr/t_f4_structure,
        lt_structure_field TYPE /thkr/t_structure_field.

  IF g_tabname IS NOT INITIAL.

    IF g_tabname = '{PARAM}'.

      /thkr/cl_gi_appl=>get_instance( )->get_fieldlist_from_params(
        EXPORTING
          i_gi_id      = g_gi_id
          i_deep       = 'X'
          i_no_prefix  = g_no_prefix
        CHANGING
          ct_fieldlist = lt_structure_field ).

    ELSE.

      /thkr/cl_helpers=>get_instance( )->get_fieldlist_from_struct(
        EXPORTING
          i_structure  = g_tabname
        IMPORTING
          et_fieldlist = lt_structure_field ).
    ENDIF.

    IF g_tables_only IS NOT INITIAL.
      LOOP AT lt_structure_field INTO DATA(l_line)
        WHERE datatype <> 'TTYP'.
        DELETE lt_structure_field.
      ENDLOOP.
    ENDIF.

  ELSEIF g_record_id IS NOT INITIAL.

    /thkr/cl_gi_appl=>get_instance( )->get_fieldlist_from_record(
      EXPORTING
        i_record_id          = g_record_id
        i_resolve_structures = 'X'
      IMPORTING
        et_fieldlist = lt_structure_field  ).
  ENDIF.

  IF g_gi_id IS NOT INITIAL
    AND ( g_field = 'GI_FIELD' OR g_field = 'DTO_FIELD' )
    AND g_tabname <> '{PARAM}'
                                    "In folgenden Fällen die Parameterliste nicht hinzufügen:
    AND g_gi_mp_tab_type <> '3'     "Trägerstruktur-Tabellenzeile aus Quellzeile
    AND g_gi_mc_data_source <> '2'. "Datenquelle ist die Schnittstellenträgerstruktur
    /thkr/cl_gi_appl=>get_instance( )->get_fieldlist_from_params(
      EXPORTING
        i_gi_id      = g_gi_id
      CHANGING
        ct_fieldlist = lt_structure_field ).

  ENDIF.

  IF g_field = 'VALUE_TRUE' OR g_field = 'VALUE_FALSE'.
    "Weitere Auswahlmöglichkeit für Vergleichswert-Ergebniszuordnung ist das DTO-Feld
    APPEND INITIAL LINE TO lt_structure_field ASSIGNING FIELD-SYMBOL(<fld>).
    <fld>-fieldname = '{DTO_FIELD}'.
    <fld>-scrtext_m = 'Wert aus DTO-Feld'.
  ENDIF.

  MOVE-CORRESPONDING lt_structure_field TO lt_fieldlist.

  CALL FUNCTION 'F4UT_RESULTS_MAP'
*    EXPORTING
*      source_structure  = 'ZSBAU_F4_STRUCTURE'
*     APPLY_RESTRICTIONS       = ' '
    TABLES
      shlp_tab          = p_shlp_tab
      record_tab        = p_record_tab
      source_tab        = lt_fieldlist
    CHANGING
      shlp              = p_shlp
      callcontrol       = p_callcontrol
    EXCEPTIONS
      illegal_structure = 1
      OTHERS            = 2.
  .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

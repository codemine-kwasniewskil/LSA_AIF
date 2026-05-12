class /THKR/CL_GI_APPL definition
  public
  final
  create public .

public section.

  data GI_MC type /THKR/GI_MC .
  data NEW_FUNCTION type XFELD .

  class-methods GET_INSTANCE
    exporting
      !E_INSTANCE type ref to /THKR/CL_GI_APPL
    returning
      value(R_INSTANCE) type ref to /THKR/CL_GI_APPL .
  methods APPLY_FILTER
    importing
      !I_FILTER_ID type /THKR/GI_FILTER_ID optional
      !I_DTO_FILTER type /THKR/S_DTO_FILTER optional
    changing
      !C_DATA type DATA
    raising
      /THKR/CX_GI .
  methods CHECK_IF_CUST
    exporting
      !ET_MESSAGE type /THKR/T_MESSAGE .
  methods CONSTRUCTOR .
  methods COPY_IF
    importing
      !I_GI_ID_SOURCE type /THKR/GI_ID
      !I_GI_ID_TARGET type /THKR/GI_ID .
  methods GET_DATA_BY_GI
    importing
      !I_GI_ID type /THKR/GI_ID
      !I_PARA type DATA optional
      !I_USRID type USRID optional
      !I_SHM_ID type /THKR/GI_SHM_OBJ_ID optional
    changing
      !C_PARA type DATA optional
      !C_DATA type DATA
    raising
      /THKR/CX_GI .
  methods GET_DTO_FILTER
    importing
      !I_FILTER_ID type /THKR/GI_FILTER_ID
    exporting
      !E_DTO type /THKR/S_DTO_FILTER .
  methods GET_FIELDLIST_FROM_PARAMS
    importing
      !I_GI_ID type /THKR/GI_ID
      !I_DEEP type XFELD optional
      !I_NO_PREFIX type XFELD optional
    changing
      !CT_FIELDLIST type /THKR/T_STRUCTURE_FIELD .
  methods GET_FIELDLIST_FROM_RECORD
    importing
      !I_RECORD_ID type /THKR/GI_RECORD_ID
      !I_RESOLVE_STRUCTURES type XFELD optional
    exporting
      !ET_FIELDLIST type /THKR/T_STRUCTURE_FIELD
      !ET_GI_REC_FLD type /THKR/T_GI_REC_FLD .
  methods GET_GI_ID_BY_STRUCTURE
    importing
      !I_STRUCTURE type /THKR/GI_STRUCTURE
    exporting
      !E_GI_ID type /THKR/GI_ID
      !E_IF type /THKR/C_GI
    raising
      /THKR/CX_GI .
  methods GET_IF_CUST
    importing
      !I_GI_ID type /THKR/GI_ID
    exporting
      !E_IF_CUST type /THKR/S_GI_D
    raising
      /THKR/CX_LSA1 .
  methods GET_KEY_BY_RECORD_ID
    importing
      !I_RECORD_ID type /THKR/GI_RECORD_ID
    exporting
      !E_RECORD_FLD_KEY type /THKR/GI_RECORD_FLD .
  methods GET_RECORD_DEFINITION
    importing
      !I_RECORD_ID type /THKR/GI_RECORD_ID
    exporting
      !E_RECORD type /THKR/S_GI_REC_D .
  methods GET_RECORD_TYPE_HANDLES
    importing
      !I_RECORD_ID type /THKR/GI_RECORD_ID
      !I_INCL_STRUCTURE type TABNAME optional
    exporting
      !E_STRUCT_DESCR type ref to CL_ABAP_STRUCTDESCR
      !E_TABLE_DESCR type ref to CL_ABAP_TABLEDESCR
      !E_TABLE_DESCR_SORTED type ref to CL_ABAP_TABLEDESCR .
  methods GET_STRUCTURE_GI
    importing
      !I_GI_ID type /THKR/GI_ID
    exporting
      !E_STRUCTURE_IF type /THKR/GI_STRUCTURE
      !E_RECORD_ID type /THKR/GI_RECORD_ID .
  methods GET_STRUCTURE_GI_TAB
    importing
      !I_GI_ID type /THKR/GI_ID
      !I_GI_MC type /THKR/GI_MC
      !I_GI_MP_TAB type /THKR/GI_MP_TAB
    exporting
      !E_IF_TAB_STRUCTURE type /THKR/GI_STRUCTURE
      !E_RECORD_ID type /THKR/GI_RECORD_ID
      !E_GI_MP_TAB_TYPE type /THKR/GI_MP_TAB_TYPE .
  methods GET_STRUCTURE_MC_DTO
    importing
      !I_GI_ID type /THKR/GI_ID
      !I_GI_MC type /THKR/GI_MC
    exporting
      !E_STRUCTURE_DTO type /THKR/GI_STRUCTURE
      !E_RECORD_ID type /THKR/GI_RECORD_ID
      !E_GI_MC_DATA_SOURCE type /THKR/GI_MC_DATA_SOURCE .
  methods GET_STRUCTURE_TAB_DTO
    importing
      !I_GI_ID type /THKR/GI_ID
      !I_GI_MC type /THKR/GI_MC
      !I_GI_MP_TAB type /THKR/GI_MP_TAB
    exporting
      !E_TAB_DTO_STRUCTURE type /THKR/GI_DTO_LINE_STRUCT
      !E_RECORD_ID type /THKR/GI_RECORD_ID
      !E_GI_MC_DATA_SOURCE type /THKR/GI_MC_DATA_SOURCE
    raising
      /THKR/CX_LSA1 .
  methods TEST_CONVERSION
    importing
      !I_CONVERSION type /THKR/GI_CONVERSION
      !I_VALUE type STRING
      !I_COMPARISION_VALUE type /THKR/GI_COMPARISION_VALUE
      !I_VALUE_TRUE type /THKR/GI_VALUE_TRUE
      !I_VALUE_FALSE type /THKR/GI_VALUE_FALSE
      !IT_VALUE_MAP type /THKR/T_GI_MP_VAL optional
      !I_MAP_TABLE type /THKR/GI_MAP_TABLE optional
      !I_FDNAME_FROM type /THKR/GI_FDNAME_FROM optional
      !I_FDNAME_TO type /THKR/GI_FDNAME_TO optional
      !I_GI_FIELD type /THKR/GI_FIELD
      !I_GI_ID type /THKR/GI_ID
    changing
      !C_FIELD type STRING
    raising
      /THKR/CX_GI .
  methods WRITE_GI_MAPPING_TO_LINE
    importing
      !IT_MAPPING type /THKR/T_GI_MAPPING_LINE
      !I_RECORD_ID type /THKR/GI_RECORD_ID
    exporting
      !E_LINE type STRING
    raising
      /THKR/CX_GI .
  methods WRITE_GI_MAPPING_TO_RECORD
    importing
      !IT_MAPPING type /THKR/T_GI_MAPPING_LINE
      !I_RECORD_ID type /THKR/GI_RECORD_ID
    changing
      !C_RECORD type DATA
    raising
      /THKR/CX_GI .
  methods WRITE_LINE_TO_GI_MAPPING
    importing
      !I_RECORD_ID type /THKR/GI_RECORD_ID
      !I_LINE type STRING
    exporting
      !ET_MAPPING type /THKR/T_GI_MAPPING_LINE
    raising
      /THKR/CX_LSA1 .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF ty_text_field,
        gi_field      TYPE /thkr/gi_field,
        table_field   TYPE /thkr/gi_table_field,
        fixed_line_nr TYPE /thkr/gi_fixed_line_nr,
        lfd_nr        TYPE /thkr/gi_lfd_nr,
        value         TYPE /thkr/gi_value_true,
        text_id       TYPE /thkr/gi_text_id,
      END OF ty_text_field .
  types:
    ty_separator TYPE c LENGTH 1 .
  types:
    BEGIN OF ty_type_handle,
        record_id          TYPE /thkr/gi_record_id,
        incl_structure     TYPE tabname,
        struct_descr       TYPE REF TO cl_abap_structdescr,
        table_descr        TYPE REF TO cl_abap_tabledescr,
        table_descr_sorted TYPE REF TO cl_abap_tabledescr,
      END OF ty_type_handle .

  class-data INSTANCE type ref to /THKR/CL_GI_APPL .
  data DATA_REF type ref to DATA .
  data DUMMY_COUNT type I .
  data DUMMY_DATE type DATS .
  data GI_CUST type /THKR/S_GI_D .
  data GI_FIELD_REF type ref to DATA .
  data GI_MP_TAB type /THKR/S_GI_MP_TAB_D .
  data HELPERS type ref to /THKR/CL_HELPERS .
  data MAPPING_LINE type /THKR/S_GI_MAPPING_LINE .
  data PARAM_REF type ref to DATA .
  data:
    t_gi_cust  TYPE STANDARD TABLE OF /thkr/s_gi_d .
  data T_MAPPING_REF type ref to /THKR/T_GI_MAPPING_LINE .
  data:
    t_text_field TYPE STANDARD TABLE OF ty_text_field .
  data:
    t_type_handle TYPE STANDARD TABLE OF ty_type_handle .
  data USRID type USRID .
  constants PREFIX_PARAM type /THKR/STRUCTURE_FIELD value '{PARAM}' ##NO_TEXT.
  data GI_DATA_REF type ref to DATA .

  methods DO_CONVERSIONS
    importing
      !I_CONVERSION type /THKR/GI_CONVERSION
      value(I_VALUE) type DATA
      !I_COMPARISION_VALUE type /THKR/GI_COMPARISION_VALUE
      !I_VALUE_TRUE type /THKR/GI_VALUE_TRUE
      !I_VALUE_FALSE type /THKR/GI_VALUE_FALSE
      !IT_VALUE_MAP type /THKR/T_GI_MP_VAL optional
      !I_MAP_TABLE type /THKR/GI_MAP_TABLE optional
      !I_FDNAME_FROM type /THKR/GI_FDNAME_FROM optional
      !I_FDNAME_TO type /THKR/GI_FDNAME_TO optional
      !I_GI_FIELD type /THKR/GI_FIELD
      !I_GI_ID type /THKR/GI_ID
      !I_CONVERSION_2 type /THKR/GI_CONVERSION_2 optional
      !I_COMPARISION_VALUE2 type /THKR/GI_COMPARISION_VALUE2 optional
    changing
      !C_FIELD type DATA
    raising
      /THKR/CX_GI .
  methods DO_CONVERSION
    importing
      !I_CONVERSION type /THKR/GI_CONVERSION
      !I_VALUE type DATA
      !I_COMPARISION_VALUE type /THKR/GI_COMPARISION_VALUE optional
      !I_VALUE_TRUE type /THKR/GI_VALUE_TRUE optional
      !I_VALUE_FALSE type /THKR/GI_VALUE_FALSE optional
      !IT_VALUE_MAP type /THKR/T_GI_MP_VAL optional
      !I_MAP_TABLE type /THKR/GI_MAP_TABLE optional
      !I_FDNAME_FROM type /THKR/GI_FDNAME_FROM optional
      !I_FDNAME_TO type /THKR/GI_FDNAME_TO optional
      !I_GI_FIELD type /THKR/GI_FIELD
      !I_GI_ID type /THKR/GI_ID
    changing
      !C_FIELD type DATA
    raising
      /THKR/CX_GI .
  methods FILL_GI_FIELD_REF
    importing
      !I_GI_FIELD type /THKR/GI_FIELD
      !I_LINE_NR type /THKR/GI_LINE_NR optional
      !I_TABLE_FIELD type /THKR/GI_TABLE_FIELD optional
      !I_FIXED_LINE_NR type /THKR/GI_FIXED_LINE_NR optional
    raising
      /THKR/CX_GI .
  methods FILL_RETURN_PARAM
    changing
      !C_PARA type DATA .
  methods GET_DATA_BY_MC
    importing
      value(I_MC) type /THKR/S_GI_MC_D
      value(I_MP_TAB) type /THKR/S_GI_MP_TAB_D optional
    changing
      !C_DATA type DATA
    raising
      /THKR/CX_GI .
  methods GET_DATA_FIXED_VALUES
    importing
      !I_IF type /THKR/S_GI_D
      !IT_MAP_FIELD type /THKR/T_GI_MP_FLD
    changing
      !C_DATA type DATA
    raising
      /THKR/CX_GI .
  methods GET_FIELD_SEPARATOR
    importing
      !I_FIELD_SEPARATION type /THKR/GI_FIELD_SEPARATION
    returning
      value(R_SEPARATOR) type TY_SEPARATOR .
  methods GET_MAX_LINE_NR
    importing
      !I_TABLE_NAME type /THKR/GI_MP_TAB
      !IT_MAPPING type /THKR/T_GI_MAPPING_LINE
    returning
      value(R_LINE_NR) type /THKR/GI_LINE_NR .
  methods GET_PARAM_REF
    importing
      !I_IF_CUST type /THKR/S_GI_D
      !I_PARA type DATA
    exporting
      !E_PARAM_REF type ref to DATA
    changing
      !C_PARA type DATA .
  methods GET_USE_FIELD_BY_RESTRICTION
    importing
      !I_IF type /THKR/S_GI_D
      !I_MC type /THKR/S_GI_MC_D
      !I_MAP_FIELD type /THKR/S_GI_MP_FLD_D
    returning
      value(R_USE_FIELD) type XFELD
    raising
      /THKR/CX_GI .
  methods GET_USE_MC_BY_RESTRICTION
    importing
      !I_IF type /THKR/S_GI_D
      !I_MC type /THKR/S_GI_MC_D
    returning
      value(R_USE_MC) type XFELD
    raising
      /THKR/CX_GI .
  methods HANDLE_TEXT_FIELDS
    importing
      !I_IF type /THKR/S_GI_D
    changing
      !C_DATA type DATA
    raising
      /THKR/CX_GI .
  methods READ_BUFFER
    importing
      !I_GI_ID type /THKR/GI_ID
      !I_PARA type DATA
      !I_SHM_ID type /THKR/GI_SHM_OBJ_ID
    changing
      !C_DATA type DATA
    returning
      value(RETVAL) type I .
  methods WRITE_BUFFER
    importing
      !I_GI_ID type /THKR/GI_ID
      !I_PARA type DATA
      !I_SHM_ID type /THKR/GI_SHM_OBJ_ID
      !I_DATA type DATA .
  methods GET_LINE_KEY_VALUE
    importing
      !I_LINE_KEY_VALUE type /THKR/GI_LINE_KEY_VALUE2
    returning
      value(R_LINE_KEY_VALUE) type /THKR/GI_LINE_KEY_VALUE2 .
  methods CHECK_FILTER_RULES
    importing
      !I_DTO_FILTER type /THKR/S_DTO_FILTER
    raising
      /THKR/CX_GI .
ENDCLASS.



CLASS /THKR/CL_GI_APPL IMPLEMENTATION.


  METHOD apply_filter.

* nicht umgesetzt

  ENDMETHOD.


  METHOD check_filter_rules.
* Bestimmte Werte in Filterregeln führen bei der Ausführung des Filters zu harten Abbrüchen. Diese
* Konstellationen müssen in dieser Methode mit Ausnahmen abgefangen werden.
* Beispiel: 0,01 lässt sich nicht als Dezimalzahl interpetieren (korrekt ist: 0.01)

    DATA: l_dec TYPE p LENGTH 16 DECIMALS 4.

    IF i_dto_filter-record_id IS NOT INITIAL.
      get_fieldlist_from_record(
        EXPORTING
          i_record_id   = i_dto_filter-record_id
        IMPORTING
          et_fieldlist  = DATA(lt_fieldlist) ).
    ELSEIF i_dto_filter-gi_structure IS NOT INITIAL.
      helpers->get_fieldlist_from_struct(
        EXPORTING
          i_structure  = i_dto_filter-gi_structure
        IMPORTING
          et_fieldlist = lt_fieldlist ).
    ENDIF.

    LOOP AT i_dto_filter-t_rule INTO DATA(l_rule).
      IF l_rule-rule_type = 'C'. "Vergleich
        READ TABLE lt_fieldlist WITH KEY fieldname = l_rule-record_fld INTO DATA(l_field).
        IF sy-subrc = 0.
          IF l_field-datatype = 'DEC'.
            TRY.
                l_dec = l_rule-fixed_value.
              CATCH cx_root INTO DATA(l_oerror).
                RAISE EXCEPTION TYPE /thkr/cx_gi
                  EXPORTING
                    textid         = /thkr/cx_gi=>rule_value_not_a_number
                    filter_id      = i_dto_filter-filter_id
                    filter_rule_id = l_rule-rule_id
                    previous       = l_oerror.

            ENDTRY.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.


  METHOD check_if_cust.

    DATA: lt_if        TYPE STANDARD TABLE OF /thkr/c_gi,
          l_if         TYPE /thkr/c_gi,
          l_if_cust    TYPE /thkr/s_gi_d,
          l_struct_ref TYPE REF TO data,
          l_map_field  TYPE /thkr/s_gi_mp_fld_d,
          l_message    LIKE LINE OF et_message,
          l_fieldname  TYPE string.

    FIELD-SYMBOLS <field> TYPE data.

    SELECT * INTO TABLE lt_if
      FROM /thkr/c_gi.

    LOOP AT lt_if INTO l_if.

      TRY.
          get_if_cust(
            EXPORTING
              i_gi_id   = l_if-gi_id
            IMPORTING
              e_if_cust = l_if_cust ).
        CATCH cx_root INTO DATA(l_oerror).
          l_message-message = l_oerror->get_text( ).
          APPEND l_message TO et_message.
      ENDTRY.

*     Schnittstellen-Trägerstruktur prüfen
      IF l_if-gi_structure IS NOT INITIAL AND l_if-is_mapping IS INITIAL.
        TRY.
            CREATE DATA l_struct_ref TYPE (l_if-gi_structure).
          CATCH cx_root.

            CONCATENATE l_if-gi_id ': Trägerstruktur ' l_if-gi_structure ' nicht vorhanden' INTO
              l_message-message SEPARATED BY space.
            APPEND l_message TO et_message.
        ENDTRY.

        LOOP AT l_if_cust-t_all_fields INTO l_map_field.
*          IF l_map_field-if_table IS NOT INITIAL.
*            CONTINUE.
*          ENDIF.

          ASSIGN l_struct_ref->(l_map_field-gi_field) TO <field>.

          IF sy-subrc <> 0.
            CONCATENATE l_if-gi_id ': Trägerstrukturfeld ' l_if-gi_structure '-' l_map_field-gi_field '(' l_map_field-gi_mc
            ') nicht vorhanden' INTO
              l_message-message SEPARATED BY space.
            APPEND l_message TO et_message.
          ENDIF.

        ENDLOOP.
      ENDIF.

    ENDLOOP.

    IF et_message IS INITIAL.
      l_message-message = 'Keine Fehler gefunden!'.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.

*    bau_def = zcl_bau_def=>get_bau_def( ).
    helpers = /thkr/cl_helpers=>get_instance( ).



  ENDMETHOD.


  METHOD copy_if.

    DATA: l_if         TYPE /thkr/c_gi,
          lt_if_mg     TYPE STANDARD TABLE OF /thkr/c_gi_mc,
          lt_if_mp_fld TYPE STANDARD TABLE OF /thkr/c_gimpfld,
          lt_if_mp_par TYPE STANDARD TABLE OF /thkr/c_gimcpar,
          lt_if_mp_tab TYPE STANDARD TABLE OF /thkr/c_gimptab.

    FIELD-SYMBOLS: <if_mg>     TYPE /thkr/c_gi_mc,
                   <if_mp_fld> TYPE /thkr/c_gimpfld,
                   <if_mp_par> TYPE /thkr/c_gimcpar,
                   <if_mp_tab> TYPE /thkr/c_gimptab.

    SELECT SINGLE * INTO l_if
      FROM /thkr/c_gi
      WHERE gi_id = i_gi_id_source.

    ASSERT sy-subrc = 0.

    l_if-gi_id = i_gi_id_target.

    INSERT /thkr/c_gi FROM l_if.

    ASSERT sy-subrc = 0.

    SELECT * INTO TABLE lt_if_mg
      FROM /thkr/c_gi_mc
      WHERE gi_id = i_gi_id_source.

    SELECT * INTO TABLE lt_if_mp_par
      FROM /thkr/c_gimcpar
      WHERE gi_id = i_gi_id_source.

    SELECT * INTO TABLE lt_if_mp_tab
      FROM /thkr/c_gimptab
      WHERE gi_id = i_gi_id_source.

    SELECT * INTO TABLE lt_if_mp_fld
      FROM /thkr/c_gimpfld
      WHERE gi_id = i_gi_id_source.

    LOOP AT lt_if_mg ASSIGNING <if_mg>.
      <if_mg>-gi_id = i_gi_id_target.
    ENDLOOP.
    INSERT /thkr/c_gi_mc FROM TABLE lt_if_mg.
    ASSERT sy-subrc = 0.

    LOOP AT lt_if_mp_par ASSIGNING <if_mp_par>.
      <if_mp_par>-gi_id = i_gi_id_target.
    ENDLOOP.
    INSERT /thkr/c_gimcpar FROM TABLE lt_if_mp_par.
    ASSERT sy-subrc = 0.

    LOOP AT lt_if_mp_tab ASSIGNING <if_mp_tab>.
      <if_mp_tab>-gi_id = i_gi_id_target.
    ENDLOOP.
    INSERT /thkr/c_gimptab FROM TABLE lt_if_mp_tab.
    ASSERT sy-subrc = 0.

    LOOP AT lt_if_mp_fld ASSIGNING <if_mp_fld>.
      <if_mp_fld>-gi_id = i_gi_id_target.
    ENDLOOP.
    INSERT /thkr/c_gimpfld FROM TABLE lt_if_mp_fld.
    ASSERT sy-subrc = 0.

    COMMIT WORK.

  ENDMETHOD.


  METHOD do_conversion.

    DATA: l_value_map         LIKE LINE OF it_value_map,
          l_typedescr         TYPE REF TO cl_abap_typedescr,
          l_structure         TYPE /thkr/gi_structure,
          l_gi_id             TYPE /thkr/gi_id,
          l_if                TYPE /thkr/c_gi,
          l_pos               TYPE i,
          l_ind               TYPE i,
          l_len               TYPE i,
          l_val_len           TYPE i,
          l_times             TYPE i,
          l_date              TYPE d,
          l_npos              TYPE n LENGTH 3,
          l_nlen              TYPE n LENGTH 3,
          l_uzeit             TYPE string,
          l_where_clause      TYPE string,
          l_select_clause     TYPE string,
          l_string            TYPE string,
          l_result            TYPE string,
          l_char              TYPE c,
          l_char30            TYPE c LENGTH 30,
          l_float             TYPE decfloat34,
          l_betrag(14),
          l_comparision_value TYPE /thkr/gi_comparision_value,
          l_value_true        TYPE /thkr/gi_value_true,
          l_value_false       TYPE /thkr/gi_value_false,
          l_param_name        TYPE string,
          l_oerror            TYPE REF TO cx_root.

    FIELD-SYMBOLS: <param_value> TYPE any.

    IF i_comparision_value(8) = '{PARAM}-'.
      "Vergleichswert ist Parameter
      l_param_name = i_comparision_value+8(22).
      ASSIGN param_ref->(l_param_name) TO <param_value>.
      l_comparision_value = <param_value>.
    ELSE.
      l_comparision_value = i_comparision_value.
    ENDIF.

    IF i_value_true = '{DTO_FIELD}'.
      "Eingabewert
      l_value_true = i_value.
    ELSEIF i_value_true(8) = '{PARAM}-'.
      "Parameter
      l_param_name = i_value_true+8(22).
      ASSIGN param_ref->(l_param_name) TO <param_value>.
      l_value_true = <param_value>.
    ELSE.
      l_value_true = i_value_true.
    ENDIF.

    IF i_value_false = '{DTO_FIELD}'.
      "Eingabewert
      l_value_false = i_value.
    ELSEIF i_value_false(8) = '{PARAM}-'.
      "Parameter
      l_param_name = i_value_false+8(22).
      ASSIGN param_ref->(l_param_name) TO <param_value>.
      l_value_false = <param_value>.
    ELSE.
      l_value_false = i_value_false.
    ENDIF.

    CONDENSE l_value_true.
    CONDENSE l_value_false.

    TRY.

        CASE i_conversion.
          WHEN '01'.  "XFELD zu ja/nein
            IF i_value = 'X'.
              c_field = 'ja'.
            ELSE.
              c_field = 'nein'.
            ENDIF.

          WHEN '02'.  "Ohne führende Nullen
            l_string = i_value.
            helpers->remove_leading_zeros( CHANGING c_value = l_string ).
            c_field = l_string.
          WHEN '03'.  "Leer, wenn '0'
            c_field = i_value.
            IF c_field = '0'.
              CLEAR c_field.
            ENDIF.
          WHEN '04'.  "gleich vergleichswert
            IF i_value = l_comparision_value.
              c_field = l_value_true.
            ELSE.
              c_field = l_value_false.
            ENDIF.
          WHEN '05'.  "ungleich vergleichswert
            IF i_value <> l_comparision_value.
              c_field = l_value_true.
            ELSE.
              c_field = l_value_false.
            ENDIF.
          WHEN '06'.  "gleich Vergleichswert (nur Wert 'Wahr')
            IF i_value = l_comparision_value.
              c_field = l_value_true.
            ENDIF.
          WHEN '07'.  "größer Vergeichswert
            IF i_value > l_comparision_value.
              c_field = l_value_true.
            ELSE.
              c_field = l_value_false.
            ENDIF.
          WHEN '08'. "Substring von,Länge (aus Para.: z.B. 1,7)
            SPLIT i_comparision_value AT ',' INTO l_npos l_nlen.
            l_pos = l_npos.
            l_pos = l_pos - 1.
            l_len = l_nlen.
            l_val_len = strlen( i_value ).
            IF l_pos GE l_val_len.
              " Wenn Anfang schon größer als Gesamtlänge dann nichts tun
            ELSEIF l_pos + l_len > l_val_len AND l_val_len > 0.
              " Wenn Länge größer als Länge Wert dann bis Ende Wert übernehmen
              l_len   = l_val_len - l_pos.
              c_field = i_value+l_pos(l_len).
            ELSE.
              c_field = i_value+l_pos(l_len).
            ENDIF.

          WHEN '09'.
            c_field = abs( i_value ).
          WHEN '10'.  "Gefüllt? -> yes/no
            IF i_value IS INITIAL.
              c_field = 'no'.
            ELSE.
              c_field = 'yes'.
            ENDIF.
          WHEN '11'.  "SEPA: erlaubte Zeichen
            c_field = i_value.
            TRANSLATE c_field USING '§ = \ @ € # < > | ; _ ° ^ '.

          WHEN '12'.  "Betrag addieren
            c_field = c_field + i_value.

          WHEN '13'.  "Vorzeichen tauschen (Zahl * -1)
            c_field = i_value * -1.

          WHEN '14'.  "Betrag subtrahieren
            c_field = c_field - i_value.

          WHEN '18'.  "Ziffern aus Zeichenkette extrahieren.
            l_string = i_value.
            CONDENSE l_string.
            l_len = strlen( l_string ).
            DO l_len TIMES.
              IF l_string+l_pos(1) CO '0123456789'.
                CONCATENATE l_result l_string+l_pos(1) INTO l_result.
              ENDIF.
              l_pos = l_pos + 1.
            ENDDO.
            c_field = l_result.
          WHEN '19'.  "Division d. Parameter (Para.: z.B. 100, f. Dezimalpunkt)
            l_float = i_value.
            l_float = l_float / i_comparision_value.
            c_field = l_float.
          WHEN '20'.  "XFELD zu yes/no
            IF i_value = 'X'.
              c_field = 'yes'.
            ELSE.
              c_field = 'no'.
            ENDIF.
          WHEN '21'  "Zahl: nur signifikante Stellen
            OR '22'. "Zahl: mind. 1 Nachkommastelle


            l_typedescr = cl_abap_typedescr=>describe_by_data( i_value ).
            IF i_value CA sy-abcde.
              l_char30 = ''.
            ELSEIF l_typedescr->type_kind = cl_abap_typedescr=>typekind_packed.
              WRITE i_value TO l_char30.
            ELSE.
              l_char30 = i_value.
            ENDIF.

            CONDENSE l_char30.

            l_pos = 0.
            FIND ',' IN l_char30 MATCH OFFSET l_pos.
            IF l_pos = 0.   "kein Komma enthalten
              l_times = 29.
            ELSE.
              l_times = l_pos - 1.
            ENDIF.
            l_ind = 0.
            DO l_times TIMES.
*         Vornullen abtrennen
              IF l_char30+l_ind(1) = '0'.
                l_char30+l_ind(1) = ' '.
              ELSE.
                EXIT.
              ENDIF.
              l_ind = l_ind + 1.
            ENDDO.

            IF l_pos > 0.
              IF i_conversion = '21'.
                l_times = 30 - l_pos.
              ELSE.
                l_times = 28 - l_pos.
              ENDIF.

              l_ind = 29.
              DO l_times TIMES.
*           Nachnullen abtrennen
                IF l_char30+l_ind(1) = ',' OR l_char30+l_ind = '0'.
                  l_char30+l_ind(1) = ' '.
                ENDIF.
                IF l_char30+l_ind(1) > '0'.
                  EXIT.
                ENDIF.
                l_ind = l_ind - 1.
              ENDDO.
            ENDIF.
            CONDENSE l_char30.
            c_field = l_char30.
          WHEN '23'.   "Datum: YYYYMMDD -> DD.MM.YYYY
            l_date = i_value.
            IF l_date IS NOT INITIAL.
              CONCATENATE l_date+6(2) '.' l_date+4(2) '.' l_date+0(4) INTO c_field.
            ELSE.
              CLEAR c_field.
            ENDIF.
          WHEN '24'.   "Datum -> YYYY-MM-DD
            l_date = i_value.
            IF l_date IS NOT INITIAL.
              CONCATENATE l_date+0(4) '-' l_date+4(2) '-' l_date+6(2) INTO c_field.
            ELSE.
              CLEAR c_field.
            ENDIF.
          WHEN '25'.   "Uhrzeit: ss:mm -> ss:mm:00+01:00
            l_uzeit = i_value.
            IF strlen( l_uzeit ) > 4.
              CONCATENATE l_uzeit+0(5) ':00+01:00' INTO c_field.
            ELSEIF strlen( l_uzeit ) = 4.
              IF l_uzeit+1(1) = ':'.  "Angabe ist z.B.: '9:00'
                CONCATENATE '0' l_uzeit ':00+01:00' INTO c_field.
              ENDIF.
            ENDIF.
          WHEN '26'.  "Dezimalzahl (auch aus Gleitkommazahl)
            l_float = i_value.    "Das funktioniert bei i_value: 123000400.45 und 1.2300040045E7
            WRITE l_float TO l_char30 NO-GROUPING DECIMALS 2.
            CONDENSE l_char30.
            REPLACE ',' IN l_char30 WITH '.'.
            c_field = l_char30.
          WHEN '27'.  "Bis Länge lt. Parameter mit Vornullen auffüllen
            c_field = i_value.
            CONDENSE c_field.
            WHILE strlen( c_field ) < i_comparision_value.
              CONCATENATE '0' c_field INTO c_field.
            ENDWHILE.

          WHEN '30'.  "Mapping
            READ TABLE it_value_map WITH KEY source_value = i_value INTO l_value_map.
            IF sy-subrc = 0.
              c_field = l_value_map-target_value.
            ELSE.
              READ TABLE it_value_map WITH KEY source_value = '*' INTO l_value_map.
              IF sy-subrc = 0.
                c_field = l_value_map-target_value.
              ENDIF.
            ENDIF.
          WHEN '31'. "Mapping mit Parameter
            ASSIGN param_ref->(i_comparision_value) TO <param_value>.
            READ TABLE it_value_map WITH KEY source_value = <param_value> INTO l_value_map.
            IF sy-subrc = 0.
              c_field = l_value_map-target_value.
            ELSE.
              READ TABLE it_value_map WITH KEY source_value = '*' INTO l_value_map.
              IF sy-subrc = 0.
                c_field = l_value_map-target_value.
              ENDIF.
            ENDIF.
          WHEN '32'. "Mapping mit Tabelle
            CONCATENATE i_fdname_from '= @i_value' INTO l_where_clause SEPARATED BY space.

            SELECT (i_fdname_to) INTO @c_field
              FROM (i_map_table)
              WHERE (l_where_clause).
            ENDSELECT.
          WHEN '33'.  "Methodenparameter
            ASSIGN param_ref->(i_comparision_value) TO <param_value>.
            IF sy-subrc = 0.
              c_field = <param_value>.
            ENDIF.
          WHEN '34'.  "Konvertierungsbaustein
            CALL FUNCTION i_comparision_value
              EXPORTING
                input  = i_value
              IMPORTING
                output = c_field.

          WHEN '35'.
            l_betrag = i_value.
            IF l_betrag CS '-'.    "Negativer Betrag
              CLEAR c_field.
            ELSE.
              SHIFT l_betrag RIGHT DELETING TRAILING space.
              OVERLAY l_betrag WITH '+0000000000000'.
              c_field = l_betrag.
            ENDIF.

          WHEN '36'.
            l_betrag = i_value.
            IF l_betrag CO '/0., '.
              CLEAR c_field.
            ELSE.
              TRANSLATE l_betrag USING '- '.
              SHIFT l_betrag RIGHT DELETING TRAILING '/'.
              SHIFT l_betrag RIGHT DELETING TRAILING space.
              CONDENSE l_betrag NO-GAPS.
              c_field = l_betrag.
            ENDIF.


          WHEN '40'.  "Ref. auf Struktur zu Struktur
            ASSIGN i_value->* TO FIELD-SYMBOL(<value>).
            MOVE-CORRESPONDING <value> TO c_field.

          WHEN '41'.  "Concatenate mit Leerzeichen
            CONCATENATE c_field i_value INTO c_field SEPARATED BY space.

          WHEN '42'. "gleich Wert wenn Zielfeld leer
            IF c_field IS INITIAL.
              c_field = i_value.
            ENDIF.

          WHEN '43'. " Upper Case
            c_field = i_value.
            TRANSLATE c_field TO UPPER CASE.

          WHEN '44'. " Lower Case
            c_field = i_value.
            TRANSLATE c_field TO LOWER CASE.

          WHEN '45'. " nur überschreiben wenn nicht leer
            IF i_value is NOT INITIAL.
              c_field = i_value.
            ENDIF.

          WHEN '46'. "Mappingtabelle mit Zielfeld Parameter
             READ TABLE it_value_map WITH KEY source_value = i_value INTO l_value_map.
            IF sy-subrc = 0.
              ASSIGN param_ref->(l_value_map-target_value) TO <param_value>.
              c_field = <param_value>.
            ELSE.
              READ TABLE it_value_map WITH KEY source_value = '*' INTO l_value_map.
              IF sy-subrc = 0.
                ASSIGN param_ref->(l_value_map-target_value) TO <param_value>.
                c_field = <param_value>.
              ENDIF.
            ENDIF.

          WHEN OTHERS.
            ASSERT 1 = 2.
        ENDCASE.

      CATCH cx_root INTO l_oerror.
        " Wenn beim Schreiben des bearbeiteten Wertes in die Rückgabevariable c_field ein Fehler auftritt,
        " weil der bearbeitete Wert nicht in den Typ von c_field umgewandelt werden kann, dann muss hier
        " der Fehler abgefangen werden und statt dessen eine eigene Exception geworfen werden:
        RAISE EXCEPTION TYPE /thkr/cx_gi
          EXPORTING
            textid   = /thkr/cx_gi=>error_in_conversion
            previous = l_oerror
            gi_id    = i_gi_id
            gi_field = i_gi_field.

    ENDTRY.

  ENDMETHOD.


  METHOD do_conversions.

    do_conversion(
      EXPORTING
        i_conversion        = i_conversion
        i_value             = i_value
        i_comparision_value = i_comparision_value
        i_value_true        = i_value_true
        i_value_false       = i_value_false
        it_value_map        = it_value_map
        i_map_table         = i_map_table
        i_fdname_from       = i_fdname_from
        i_fdname_to         = i_fdname_to
        i_gi_field          = i_gi_field
        i_gi_id             = i_gi_id
      CHANGING
        c_field             = c_field ).

    IF i_conversion_2 IS NOT INITIAL.

      i_value = c_field.

      do_conversion(
        EXPORTING
          i_conversion        = i_conversion_2
          i_comparision_value = i_comparision_value2
          i_value             = i_value
          i_gi_field          = i_gi_field
          i_gi_id             = i_gi_id
        CHANGING
          c_field             = c_field ).

    ENDIF.

  ENDMETHOD.


  METHOD fill_gi_field_ref.

    DATA: l_param_name TYPE string,
          l_line_ref   TYPE REF TO data.

    FIELD-SYMBOLS: <gi_field> TYPE any,
                   <table>    TYPE STANDARD TABLE.

    IF i_gi_field(8) = '{PARAM}-'.
      "Feldinhalt soll auf Parameter geschrieben werden

      l_param_name = i_gi_field+8(22).
      ASSIGN param_ref->(l_param_name) TO <gi_field>.
      GET REFERENCE OF <gi_field> INTO gi_field_ref.

    ELSEIF gi_cust-is_mapping IS INITIAL.

      IF i_table_field IS INITIAL.

        ASSIGN data_ref->(i_gi_field) TO <gi_field>.

        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE /thkr/cx_gi
            EXPORTING
              textid       = /thkr/cx_gi=>if_field_not_exists
              gi_id        = gi_cust-gi_id
              gi_field     = i_gi_field
              gi_structure = gi_cust-gi_structure.
        ENDIF.
      ELSE.
        "Feld aus Tabellenzeile der Trägerstruktur
        ASSIGN data_ref->(i_table_field) TO <table>.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE /thkr/cx_gi
            EXPORTING
              textid       = /thkr/cx_gi=>if_field_not_exists
              gi_id        = gi_cust-gi_id
              gi_field     = i_table_field
              gi_structure = gi_cust-gi_structure.
        ENDIF.

        READ TABLE <table> INDEX i_fixed_line_nr REFERENCE INTO l_line_ref.
        IF sy-subrc <> 0.
          "Zeile nicht vorhanden: Zeile(n) hinzufügen
          DO i_fixed_line_nr TIMES.
            READ TABLE <table> INDEX sy-index TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0.
              APPEND INITIAL LINE TO <table>.
            ENDIF.
          ENDDO.
          READ TABLE <table> INDEX i_fixed_line_nr REFERENCE INTO l_line_ref.
        ENDIF.
        ASSIGN l_line_ref->(i_gi_field) TO <gi_field>.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE /thkr/cx_gi
            EXPORTING
              textid    = /thkr/cx_gi=>if_line_field_not_exists
              gi_id     = gi_cust-gi_id
              gi_field  = i_gi_field
              gi_mc     = gi_mc
              gi_mp_tab = gi_mp_tab-gi_mp_tab.

        ENDIF.

      ENDIF.

      GET REFERENCE OF <gi_field> INTO gi_field_ref.

    ELSE.

      READ TABLE t_mapping_ref->* WITH KEY
          key       = i_gi_field
          tablename = gi_mp_tab-table_field
          line_nr   = i_line_nr
        ASSIGNING FIELD-SYMBOL(<mapping_line>).

      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO t_mapping_ref->* ASSIGNING <mapping_line>.
        <mapping_line>-key       = i_gi_field.
        <mapping_line>-tablename = gi_mp_tab-table_field.
        <mapping_line>-line_nr   = i_line_nr.
      ENDIF.

      GET REFERENCE OF <mapping_line>-value INTO gi_field_ref.

    ENDIF.

  ENDMETHOD.


  METHOD fill_return_param.


    DATA: l_ipara_ref    TYPE REF TO data.

    FIELD-SYMBOLS: <value>     TYPE any,
                   <src_value> TYPE any.

    GET REFERENCE OF c_para INTO l_ipara_ref.

    LOOP AT gi_cust-t_par INTO DATA(l_par).

      ASSIGN l_ipara_ref->(l_par-gi_param) TO <src_value>.

      IF sy-subrc <> 0.
        "Parameter wurde nicht übergeben
        CONTINUE.
      ENDIF.

      ASSIGN param_ref->(l_par-gi_param) TO <value>.
      <src_value> = <value>.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_data_by_gi.

    DATA: l_gi_mc      LIKE LINE OF gi_cust-t_mc,
          l_oerror     TYPE REF TO cx_root,
          l_map_table  TYPE /thkr/s_gi_mp_tab_d,
          l_c_data_ref TYPE REF TO data,
          l_mess       TYPE string,
          l_retval     TYPE i.

    FIELD-SYMBOLS: <value>   TYPE any,
                   <mapping> TYPE /thkr/t_gi_mapping_line.

    IF i_usrid IS INITIAL.
      usrid = sy-uname.
    ELSE.
      usrid = i_usrid.
    ENDIF.

    FIELD-SYMBOLS: <c_data_tab> TYPE data,
                   <c_data>     TYPE data.

    IF i_shm_id IS NOT INITIAL.
      IF c_para IS INITIAL.
        "Keine Rückgabe von Parameter-Werten
        l_retval = read_buffer(
          EXPORTING
            i_gi_id  = i_gi_id
            i_para   = i_para
            i_shm_id = i_shm_id
          CHANGING
            c_data   = c_data ).
      ENDIF.

      IF l_retval = 0.
        RETURN.
      ENDIF.

    ENDIF.

    CLEAR: t_text_field.

    get_if_cust(
      EXPORTING
        i_gi_id   = i_gi_id
      IMPORTING
        e_if_cust = gi_cust ).

    get_param_ref(
      EXPORTING
        i_if_cust   = gi_cust
        i_para      = i_para
      IMPORTING
        e_param_ref = param_ref
      CHANGING
        c_para      = c_para ).

    IF gi_cust-is_mapping IS NOT INITIAL.
      GET REFERENCE OF c_data INTO t_mapping_ref.
    ENDIF.

    GET REFERENCE OF c_data INTO gi_data_ref.

    SORT gi_cust-t_mc BY seq_no gi_mc.

    LOOP AT gi_cust-t_mc INTO l_gi_mc.

      TRY.

          IF l_gi_mc-t_map_field IS NOT INITIAL.
*           Trägerstrukturfelder durch Methodenaufruf füllen

            get_data_by_mc(
              EXPORTING
                i_mc        = l_gi_mc
              CHANGING
                c_data      = c_data ).

          ENDIF.

          LOOP AT l_gi_mc-t_map_table INTO l_map_table.
            "Die Verarbeitungsreihenfolge wurde beim Lesen des Customizings beachtet
            IF l_map_table-mp_tab_type = 1          "Trägerstrukturfelder aus Tabellenzeile(n)
              OR l_map_table-mp_tab_type = 4        "Feste Trägerstruktur-Tabellenzeile
              OR gi_cust-is_mapping IS NOT INITIAL. "Es wird nur die Mapping-Tabelle befüllt
*             Die Trägerstrukturfelder oder die Mappingtabelle mit Tabellendaten befüllen

              get_data_by_mc(
                EXPORTING
                  i_mc        = l_gi_mc
                  i_mp_tab    = l_map_table
                CHANGING
                  c_data   = c_data ).

            ELSE.
*             Trägerstrukturfeld vom Typ Tabelle mit Tabellendaten füllen
              IF l_gi_mc-data_source = '2'.    "Daten aus Schnittstellenträgerstuktur auf Parameter
                ASSIGN param_ref->(l_map_table-table_field) TO <c_data_tab>.
                IF sy-subrc <> 0.
                  RAISE EXCEPTION TYPE /thkr/cx_gi
                    EXPORTING
                      textid = /thkr/cx_gi=>param_field_not_exists
                      gi_id  = i_gi_id
                      gi_mc  = l_gi_mc-gi_mc
                      param  = CONV #( l_map_table-table_field ).

                ENDIF.

              ELSE.
                GET REFERENCE OF c_data INTO l_c_data_ref.
                ASSIGN l_c_data_ref->(l_map_table-table_field) TO <c_data_tab>.

                IF sy-subrc <> 0.
                  RAISE EXCEPTION TYPE /thkr/cx_gi
                    EXPORTING
                      textid       = /thkr/cx_gi=>if_field_not_exists
                      gi_id        = i_gi_id
                      gi_field     = l_map_table-table_field
                      gi_structure = gi_cust-gi_structure.
                ENDIF.
              ENDIF.

              get_data_by_mc(
                EXPORTING
                  i_mc        = l_gi_mc
                  i_mp_tab    = l_map_table
                CHANGING
                  c_data      = <c_data_tab> ).
            ENDIF.
          ENDLOOP.

        CATCH cx_root INTO l_oerror.

*          IF bau_def->testmode_is_set( zcl_bau_def=>tmbin_breakpoint ) IS NOT INITIAL.
*            l_mess = l_oerror->get_text( ).
*            BREAK-POINT.
*          ENDIF.
          RAISE EXCEPTION l_oerror.

      ENDTRY.


    ENDLOOP.

    get_data_fixed_values(
      EXPORTING
        i_if         = gi_cust
        it_map_field = gi_cust-t_map_field
      CHANGING
        c_data       = c_data ).

    IF t_text_field IS NOT INITIAL.
      handle_text_fields(
        EXPORTING
          i_if   = gi_cust
        CHANGING
          c_data = c_data ).
    ENDIF.

    IF gi_cust-is_mapping IS NOT INITIAL.
      ASSIGN c_data TO <mapping>.
      SORT <mapping> BY tablename line_nr key.
    ENDIF.

    IF c_para IS NOT INITIAL.

      fill_return_param(
        CHANGING
          c_para    = c_para ).

    ENDIF.

    IF i_shm_id IS NOT INITIAL AND c_para IS INITIAL.

      write_buffer(
        EXPORTING
          i_gi_id  = i_gi_id
          i_para   = i_para
          i_shm_id = i_shm_id
          i_data   = c_data ).

    ENDIF.

  ENDMETHOD.


  METHOD get_data_by_mc.

    DATA: l_map_param      LIKE LINE OF i_mc-t_map_param,
          l_parameter      TYPE abap_parmbind,
          lt_parameter     TYPE abap_parmbind_tab,
          l_cls_int        TYPE REF TO object,
          l_dto_ref        TYPE REF TO data,
          l_table_line_ref TYPE REF TO data,
          l_map_field      LIKE LINE OF i_mc-t_map_field,
          l_fieldname      TYPE /thkr/gi_field,
          l_index          TYPE n LENGTH 2,
          l_line_count     TYPE i,
          l_oerror         TYPE REF TO cx_root,
          l_message        TYPE string,
          l_length         TYPE i,
          l_start          TYPE i,
          l_value_string   TYPE string,
          l_dummy          TYPE c,
          l_text_field     TYPE ty_text_field.

    FIELD-SYMBOLS: <cls_int>     TYPE any,
                   <value>       TYPE any,
                   <param>       TYPE any,
                   <param_value> TYPE any,
                   <gi_field>    TYPE any,
                   <value_table> TYPE STANDARD TABLE,
                   <line>        TYPE any,
                   <data_tab>    TYPE STANDARD TABLE.

    IF gi_cust-is_mapping IS INITIAL.
      GET REFERENCE OF c_data INTO data_ref.
    ENDIF.

*   Globale Daten initialisieren
    gi_mp_tab = i_mp_tab.
    gi_mc     = i_mc-gi_mc.

    IF get_use_mc_by_restriction(
        i_if     = gi_cust
        i_mc     = i_mc ) IS INITIAL.
      RETURN.
    ENDIF.

    IF i_mc-data_source = '2'.    "Daten aus Schnittstellenträgerstuktur

      l_dto_ref = gi_data_ref.

    ELSEIF i_mc-int_cls IS INITIAL.
      "Das Mapping soll nicht auf Basis der Ergebnisse eines Methodenaufrufes erfolgen,
      "sondern auf Basis der übergebenen Parameter.
      l_dto_ref = param_ref.

    ELSE.

*   Zugriffsreferenz auf INT-Klasse holen
      l_parameter-kind = cl_abap_objectdescr=>importing.
      l_parameter-name = 'E_INSTANCE'.
      CREATE DATA l_parameter-value TYPE REF TO (i_mc-int_cls).
      INSERT l_parameter INTO TABLE lt_parameter.

      CALL METHOD (i_mc-int_cls)=>get_instance
        PARAMETER-TABLE
        lt_parameter.

      ASSIGN l_parameter-value->* TO <cls_int>.
      l_cls_int ?= <cls_int>.

*   Übergabeparameter für get_dto-Aufruf erstellen
      CLEAR lt_parameter.

      LOOP AT i_mc-t_map_param INTO l_map_param.

*     Parameterwert belegen
        IF l_map_param-src_param IS NOT INITIAL.
*         Belegung mit Parameter
          ASSIGN param_ref->(l_map_param-src_param) TO <param_value>.
        ELSE.
*       Belegung des Parameters mit Festwert
          ASSIGN l_map_param-fixed_value TO <param_value>.
        ENDIF.

        IF l_map_param-pos_from IS NOT INITIAL.
          l_start  = l_map_param-pos_from - 1.
          l_length = l_map_param-pos_to - l_start.
          l_value_string = <param_value>.
          l_value_string = l_value_string+l_start(l_length).
          ASSIGN l_value_string TO <param_value>.
        ENDIF.

        l_parameter-kind = cl_abap_objectdescr=>exporting.
        l_parameter-name = l_map_param-param.
        CREATE DATA l_parameter-value TYPE (l_map_param-param_type).

        ASSIGN l_parameter-value->* TO <param>.
        <param> = <param_value>.

        INSERT l_parameter INTO TABLE lt_parameter.

      ENDLOOP.

*   Rückgabeparameter für get_dto-Aufruf erstellen
      l_parameter-kind = cl_abap_objectdescr=>importing.
      l_parameter-name = 'E_DTO'.
      CREATE DATA l_parameter-value TYPE (i_mc-int_dto).
      l_dto_ref = l_parameter-value.

      INSERT l_parameter INTO TABLE lt_parameter.

      TRY.

          CALL METHOD l_cls_int->(i_mc-int_methode)
            PARAMETER-TABLE
            lt_parameter.

        CATCH cx_root INTO l_oerror.

          l_message = l_oerror->get_text( ).
          RAISE EXCEPTION TYPE /thkr/cx_gi
            EXPORTING
              textid     = /thkr/cx_gi=>error_in_call_method
              int_method = i_mc-int_methode
              int_cls    = i_mc-int_cls
              mess       = l_message
              previous   = l_oerror.

      ENDTRY.
    ENDIF.

    IF i_mp_tab IS INITIAL  "Rückgabewerte auf Rückgabestruktur schreiben (kein Tabellen-Mapping)
      OR ( i_mp_tab-mp_tab_type = 4 AND i_mp_tab-dto_field IS INITIAL ).  "Feste Zeile der Rückgabetabelle mit DTO-Feldern belegen

      IF i_mp_tab IS INITIAL.
        ASSIGN i_mc-t_map_field TO FIELD-SYMBOL(<t_map_field>).
      ELSE.
        ASSIGN i_mp_tab-t_map_field TO <t_map_field>.
      ENDIF.

      SORT <t_map_field> BY lfd_nr.
      LOOP AT <t_map_field> INTO l_map_field.  "zu belegende Felder

        fill_gi_field_ref(
          EXPORTING
            i_gi_field      = l_map_field-gi_field
            i_table_field   = i_mp_tab-table_field
            i_fixed_line_nr = i_mp_tab-fixed_line_nr ).
        ASSIGN gi_field_ref->* TO <gi_field>.

        IF <gi_field> IS NOT INITIAL
          AND l_map_field-overwrite IS INITIAL
          AND l_map_field-text_id IS INITIAL. "Text-Felder immer überschreiben
*         Feld soll nicht überschrieben werden
          CONTINUE.
        ENDIF.

*       Ausschluss der Zeilen, die der Regel Parameter = <Wert> widersprechen
        IF get_use_field_by_restriction(
            i_if          = gi_cust
            i_mc          = i_mc
            i_map_field   = l_map_field ) IS INITIAL.
          CONTINUE.
        ENDIF.

        IF l_map_field-use_param_for_dto IS NOT INITIAL.
          ASSIGN param_ref->(l_map_field-dto_field) TO <value>.
        ELSEIF l_map_field-dto_field IS NOT INITIAL.
          ASSIGN l_dto_ref->(l_map_field-dto_field) TO <value>.
        ELSEIF l_map_field-fixed_value IS NOT INITIAL.
          ASSIGN l_map_field-fixed_value TO <value>.
        ELSE.
          ASSIGN l_dummy TO <value>.
        ENDIF.

        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE /thkr/cx_gi
            EXPORTING
              textid    = /thkr/cx_gi=>dto_field_not_exists
              gi_id     = gi_cust-gi_id
              gi_mc     = i_mc-gi_mc
              dto_field = l_map_field-dto_field.
        ENDIF.

        IF l_map_field-conversion IS NOT INITIAL.

          do_conversions(
            EXPORTING
              i_conversion         = l_map_field-conversion
              i_value              = <value>
              i_comparision_value  = l_map_field-comparision_value
              i_value_true         = l_map_field-value_true
              i_value_false        = l_map_field-value_false
              it_value_map         = l_map_field-t_map_value
              i_map_table          = l_map_field-map_table
              i_fdname_from        = l_map_field-fdname_from
              i_fdname_to          = l_map_field-fdname_to
              i_gi_field           = l_map_field-gi_field
              i_gi_id              = gi_cust-gi_id
              i_conversion_2       = l_map_field-conversion_2
              i_comparision_value2 = l_map_field-comparision_value2
            CHANGING
              c_field              = <gi_field> ).

        ELSE.
          <gi_field> = <value>.
        ENDIF.

        IF l_map_field-text_id IS NOT INITIAL AND <gi_field> IS NOT INITIAL.
*         Zielfeld mit SAP-Nachricht mit Argumenten aus mehreren Quell-Feldern befüllen
          APPEND INITIAL LINE TO t_text_field ASSIGNING FIELD-SYMBOL(<text_field>).
          <text_field>-gi_field      = l_map_field-gi_field.
          <text_field>-table_field   = i_mp_tab-table_field.
          <text_field>-fixed_line_nr = i_mp_tab-fixed_line_nr.
          <text_field>-lfd_nr        = l_map_field-lfd_nr.
          <text_field>-value         = <gi_field>.
          <text_field>-text_id = l_map_field-text_id.
        ENDIF.

        IF l_map_field-exception_if_empty IS NOT INITIAL AND <gi_field> IS INITIAL.
          "Für das Feld &gi_field& der Schnittstelle &gi_id&/&IF_TABLE& konnte kein Wert bestimmt werden!
          RAISE EXCEPTION TYPE /thkr/cx_gi
            EXPORTING
              textid   = /thkr/cx_gi=>mandatory_field_not_filled
              gi_field = l_map_field-gi_field
              gi_id    = gi_cust-gi_id.
        ENDIF.

      ENDLOOP.

    ELSE.   "Tabellen-Mapping

      ASSIGN l_dto_ref->(i_mp_tab-dto_field) TO <value_table>.  "Ausgangstabelle
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_gi
          EXPORTING
            textid    = /thkr/cx_gi=>dto_field_not_exists
            gi_id     = gi_cust-gi_id
            gi_mc     = i_mc-gi_mc
            dto_field = i_mp_tab-dto_field.
      ENDIF.

      DESCRIBE TABLE <value_table> LINES l_line_count.

      IF i_mp_tab-mp_tab_type = '1'     "Trägerstrukturfelder aus Tabellenzeile(n)
        OR i_mp_tab-mp_tab_type = '4'.  "Feste Zeile der Rückgabetabelle mit DTO-Feldern belegen
*       Aus einer Tabelle wird eine Zeile gelesen, aus der Felder auf Trägerstrukturfelder oder eine feste
*       Zeile einer Ziel-Tabelle gemappt werden.
*       GGf. können auch mehrere Zeilen nacheinander gelesen werden, in diesem Fall zählen Eingenschaften wie
*       'überschreiben', 'Einschränkung nach Parameter', etc.


*************************************************
*       Felder, die auf Basis von Tabellenzeilen gefüllt werden sollen, mit Initialwerten belegen.
*       Das ist notwendig, wenn eine Zeile mit dem betreffenden Zeilenschlüssel nicht gefunden wird.
*       Ausserdem Prüfung ob alle Felder vorhanden sind (sonst schlägt assign fehl)
        LOOP AT i_mp_tab-t_map_field INTO l_map_field.

          fill_gi_field_ref(
            EXPORTING
              i_gi_field      = l_map_field-gi_field
              i_table_field   = i_mp_tab-table_field
              i_fixed_line_nr = i_mp_tab-fixed_line_nr ).

          ASSIGN gi_field_ref->* TO <gi_field>.

          IF <gi_field> IS NOT INITIAL AND l_map_field-overwrite IS INITIAL.
*             Feld soll nicht überschrieben werden
            CONTINUE.
          ENDIF.

          IF l_map_field-fixed_value IS NOT INITIAL.
            <gi_field> = l_map_field-fixed_value.
          ELSEIF l_map_field-is_line_count IS NOT INITIAL. "Feld für Zeilenanzahl
            <gi_field> = l_line_count.
          ENDIF.

        ENDLOOP.

        LOOP AT <value_table> REFERENCE INTO l_dto_ref.
*         Über die Zeilen der Datentabelle iterieren
          l_index = l_index + 1.

          LOOP AT i_mp_tab-t_map_field INTO l_map_field
            WHERE is_line_count IS INITIAL. "Felder für Zeilenzahl auslassen
*           Für jede Zeile der Datentabelle das field mapping durchgehen

            IF l_map_field-line_key_value IS NOT INITIAL. "Zeilenauswahl gemäß Zeilenschlüssel 1

              ASSIGN l_dto_ref->(i_mp_tab-dto_field_line_key) TO <value>.

              IF sy-subrc <> 0.
                RAISE EXCEPTION TYPE /thkr/cx_gi
                  EXPORTING
                    textid    = /thkr/cx_gi=>table_map_key_field_not_exists
                    dto_field = CONV #( i_mp_tab-dto_field_line_key )
                    gi_mp_tab = i_mp_tab-gi_mp_tab
                    gi_mc     = i_mc-gi_mc.
              ENDIF.

              IF <value> <> get_line_key_value( CONV #( l_map_field-line_key_value ) ).
*               Es handelt sich nicht um die interessante Zeile
                CONTINUE.
              ENDIF.
            ENDIF.

            IF l_map_field-line_key_value2 IS NOT INITIAL. "Zeilenauswahl gemäß Zeilenschlüssel 2
              ASSIGN l_dto_ref->(i_mp_tab-dto_field_line_key2) TO <value>.

              IF sy-subrc <> 0.
                RAISE EXCEPTION TYPE /thkr/cx_gi
                  EXPORTING
                    textid    = /thkr/cx_gi=>table_map_key_field_not_exists
                    dto_field = CONV #( i_mp_tab-dto_field_line_key2 )
                    gi_mp_tab = i_mp_tab-gi_mp_tab
                    gi_mc     = i_mc-gi_mc.
              ENDIF.

              IF <value> <> get_line_key_value( l_map_field-line_key_value2 ).
*               Es handelt sich nicht um die interessante Zeile
                CONTINUE.
              ENDIF.
            ENDIF.

            IF l_map_field-line_key_value3 IS NOT INITIAL. "Zeilenauswahl gemäß Zeilenschlüssel 3
              ASSIGN l_dto_ref->(i_mp_tab-dto_field_line_key3) TO <value>.

              IF sy-subrc <> 0.
                RAISE EXCEPTION TYPE /thkr/cx_gi
                  EXPORTING
                    textid    = /thkr/cx_gi=>table_map_key_field_not_exists
                    dto_field = CONV #( i_mp_tab-dto_field_line_key3 )
                    gi_mp_tab = i_mp_tab-gi_mp_tab
                    gi_mc     = i_mc-gi_mc.
              ENDIF.

              IF <value> <> get_line_key_value( l_map_field-line_key_value3 ).
*               Es handelt sich nicht um die interessante Zeile
                CONTINUE.
              ENDIF.
            ENDIF.

            IF l_map_field-line_key_param3 IS NOT INITIAL. "Zeilenauswahl gemäße Parameter für Zeilenschlüssel 3

              ASSIGN param_ref->(l_map_field-line_key_param3) TO <param_value>.

              IF sy-subrc <> 0.
                RAISE EXCEPTION TYPE /thkr/cx_gi
                  EXPORTING
                    textid   = /thkr/cx_gi=>param_not_exists
                    param    = l_map_field-line_key_param3
                    gi_id    = gi_cust-gi_id
                    gi_mc    = i_mc-gi_mc
                    gi_field = l_map_field-gi_field.
              ENDIF.

              ASSIGN l_dto_ref->(i_mp_tab-dto_field_line_key3) TO <value>.

              IF sy-subrc <> 0.
                RAISE EXCEPTION TYPE /thkr/cx_gi
                  EXPORTING
                    textid    = /thkr/cx_gi=>table_map_key_field_not_exists
                    dto_field = CONV #( i_mp_tab-dto_field_line_key3 )
                    gi_mp_tab = i_mp_tab-gi_mp_tab
                    gi_mc     = i_mc-gi_mc.
              ENDIF.

              IF <value> <> <param_value>.
*               Es handelt sich nicht um die interessante Zeile
                CONTINUE.
              ENDIF.
            ENDIF.

*         Kein Mapping, wenn das Feld, die der Regel Parameter = <Wert> widersprechen
            IF get_use_field_by_restriction(
                i_if          = gi_cust
                i_mc          = i_mc
                i_map_field   = l_map_field ) IS INITIAL.
              CONTINUE.
            ENDIF.

            fill_gi_field_ref(
              EXPORTING
                i_gi_field      = l_map_field-gi_field
                i_table_field   = i_mp_tab-table_field
                i_fixed_line_nr = i_mp_tab-fixed_line_nr ).

            ASSIGN gi_field_ref->* TO <gi_field>.

            IF l_map_field-is_line_index IS NOT INITIAL.
*           Feld für Zeilennummer
              <gi_field> = l_index.
              CONTINUE.
            ENDIF.

            IF l_map_field-dto_field IS INITIAL.
              ASSIGN l_map_field-fixed_value TO <value>.
            ELSEIF l_map_field-use_param_for_dto IS NOT INITIAL.
              ASSIGN param_ref->(l_map_field-dto_field) TO <value>.
            ELSE.
              ASSIGN l_dto_ref->(l_map_field-dto_field) TO <value>.
            ENDIF.

            IF sy-subrc <> 0.
              RAISE EXCEPTION TYPE /thkr/cx_gi
                EXPORTING
                  textid    = /thkr/cx_gi=>dto_field_not_exists
                  gi_id     = gi_cust-gi_id
                  gi_mc     = i_mc-gi_mc
                  dto_field = l_map_field-dto_field.
            ENDIF.

            IF l_map_field-text_id IS NOT INITIAL.  "Feld soll durch Text ersetzt werden
              CLEAR l_text_field.

              IF l_map_field-conversion IS NOT INITIAL.

                do_conversions(
                  EXPORTING
                    i_conversion         = l_map_field-conversion
                    i_value              = <value>
                    i_comparision_value  = l_map_field-comparision_value
                    i_value_true         = l_map_field-value_true
                    i_value_false        = l_map_field-value_false
                    it_value_map         = l_map_field-t_map_value
                    i_map_table          = l_map_field-map_table
                    i_fdname_from        = l_map_field-fdname_from
                    i_fdname_to          = l_map_field-fdname_to
                    i_gi_field           = l_map_field-gi_field
                    i_gi_id              = gi_cust-gi_id
                    i_conversion_2       = l_map_field-conversion_2
                    i_comparision_value2 = l_map_field-comparision_value2
                  CHANGING
                    c_field              = l_text_field-value ).

              ELSE.
                l_text_field-value = <value>.
              ENDIF.

              IF l_text_field-value IS NOT INITIAL.
*               Zielfeld mit Text und Argumenten aus mehreren Quell-Feldern befüllen
                l_text_field-gi_field      = l_map_field-gi_field.
                l_text_field-lfd_nr        = l_map_field-lfd_nr.
                l_text_field-text_id       = l_map_field-text_id.
                l_text_field-table_field   = i_mp_tab-table_field.
                l_text_field-fixed_line_nr = i_mp_tab-fixed_line_nr.
                APPEND l_text_field TO t_text_field.
              ENDIF.

            ELSEIF <gi_field> IS NOT INITIAL
              AND l_map_field-overwrite IS INITIAL. "Feld soll gemäß Customizing nicht überschrieben werden
*           -- Nichts tun ---

            ELSEIF l_map_field-conversion IS NOT INITIAL.

              do_conversions(
                EXPORTING
                  i_conversion         = l_map_field-conversion
                  i_value              = <value>
                  i_comparision_value  = l_map_field-comparision_value
                  i_value_true         = l_map_field-value_true
                  i_value_false        = l_map_field-value_false
                  it_value_map         = l_map_field-t_map_value
                  i_map_table          = l_map_field-map_table
                  i_fdname_from        = l_map_field-fdname_from
                  i_fdname_to          = l_map_field-fdname_to
                  i_gi_field           = l_map_field-gi_field
                  i_gi_id              = gi_cust-gi_id
                  i_conversion_2       = l_map_field-conversion_2
                  i_comparision_value2 = l_map_field-comparision_value2
                CHANGING
                  c_field              = <gi_field> ).

            ELSE.
              <gi_field> = <value>.
            ENDIF.

          ENDLOOP.

        ENDLOOP.
*       Pflichtfelder Prüfen
        LOOP AT i_mp_tab-t_map_field INTO l_map_field WHERE exception_if_empty IS NOT INITIAL.
          fill_gi_field_ref( l_map_field-gi_field ).
          ASSIGN gi_field_ref->* TO <gi_field>.

          IF <gi_field> IS INITIAL.
            "Für das Feld &gi_field& der Schnittstelle &gi_id&/&IF_TABLE& konnte kein Wert bestimmt werden!
            RAISE EXCEPTION TYPE /thkr/cx_gi
              EXPORTING
                textid    = /thkr/cx_gi=>mandatory_field_not_filled
                gi_field  = l_map_field-gi_field
                gi_id     = gi_cust-gi_id
                gi_mp_tab = i_mp_tab-gi_mp_tab.

          ENDIF.
        ENDLOOP.

      ELSE.
        "Trägerstruktur-Tabellenzeile aus Feldmapping
        "Trägerstruktur-Tabellenzeile aus Quellzeile

*       Wenn das Ziel nicht die Mappingtabelle ist, dann Zeilenvariable erstellen
        IF gi_cust-is_mapping IS INITIAL.
          "Ziel-Tabelle/Zeile zuweisen
          ASSIGN c_data TO <data_tab>.          "Zieltabelle

          IF i_mp_tab-table_field_struct IS NOT INITIAL. "Ziel-Zeilenstruktur ist angegeben
            CREATE DATA data_ref TYPE (i_mp_tab-table_field_struct).
          ELSE.
            CREATE DATA data_ref LIKE LINE OF <data_tab>.
          ENDIF.
          ASSIGN data_ref->* TO <line>. "Zeile der Zielstruktur

        ENDIF.

        IF i_mp_tab-mp_tab_type = 2.  "Trägerstruktur-Tabellenzeile aus Feldmapping
****      IF i_mp_tab-dto_field_line_nr IS NOT INITIAL.

          ASSERT gi_cust-is_mapping IS INITIAL.  "Dieser Zweig ist nicht implementiert

          LOOP AT <value_table> REFERENCE INTO l_dto_ref.
*           Alle Einträge ohne Zeilennummer löschen
            ASSIGN l_dto_ref->(i_mp_tab-dto_field_line_nr) TO <value>.
            IF <value> IS INITIAL.
              DELETE <value_table>.
              CONTINUE.
            ENDIF.
          ENDLOOP.

          LOOP AT <value_table> REFERENCE INTO l_dto_ref.
*           Prüfen, ob die Zeile der Ausgangstabelle für die Zietabelle relevant ist:
            ASSIGN l_dto_ref->(i_mp_tab-dto_field_line_key) TO FIELD-SYMBOL(<line_key_field>).
            READ TABLE i_mp_tab-t_map_field WITH KEY line_key_value = <line_key_field> TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0.
*             Zeile nicht interessant
              DELETE <value_table>.
              CONTINUE.
            ENDIF.

          ENDLOOP.

          SORT <value_table> BY (i_mp_tab-dto_field_line_nr).

          LOOP AT <value_table> REFERENCE INTO l_dto_ref.
*           Prüfen, ob neue Zeile erforderlich
            ASSIGN l_dto_ref->(i_mp_tab-dto_field_line_nr) TO FIELD-SYMBOL(<line_nr>).
            IF <line_nr> > l_index.
*             Daten für neue Zeile
              l_index = <line_nr>.
              IF <line> IS NOT INITIAL.
                APPEND <line> TO <data_tab>.
                CLEAR <line>.
              ENDIF.
            ENDIF.

            ASSIGN l_dto_ref->(i_mp_tab-dto_field_line_key) TO <line_key_field>.
            ASSIGN l_dto_ref->(i_mp_tab-dto_field_line_key2) TO FIELD-SYMBOL(<line_key_field2>).

            LOOP AT i_mp_tab-t_map_field INTO l_map_field
              WHERE line_key_value  = <line_key_field>
                AND line_key_value2 = <line_key_field2>.

*             Ausschluss der Zeilen, die der Regel Parameter = <Wert> widersprechen
              IF get_use_field_by_restriction(
                  i_if          = gi_cust
                  i_mc          = i_mc
                  i_map_field   = l_map_field ) IS INITIAL.
                CONTINUE.
              ENDIF.

              fill_gi_field_ref( l_map_field-gi_field ).
              ASSIGN gi_field_ref->* TO <gi_field>.

              ASSIGN l_dto_ref->(l_map_field-dto_field) TO <value>.

              IF sy-subrc <> 0.
                RAISE EXCEPTION TYPE /thkr/cx_gi
                  EXPORTING
                    textid    = /thkr/cx_gi=>dto_field_not_exists
                    gi_id     = gi_cust-gi_id
                    gi_mc     = i_mc-gi_mc
                    dto_field = l_map_field-dto_field.
              ENDIF.

              IF l_map_field-conversion IS NOT INITIAL.

                do_conversions(
                  EXPORTING
                    i_conversion         = l_map_field-conversion
                    i_value              = <value>
                    i_comparision_value  = l_map_field-comparision_value
                    i_value_true         = l_map_field-value_true
                    i_value_false        = l_map_field-value_false
                    it_value_map         = l_map_field-t_map_value
                    i_map_table          = l_map_field-map_table
                    i_fdname_from        = l_map_field-fdname_from
                    i_fdname_to          = l_map_field-fdname_to
                    i_gi_field           = l_map_field-gi_field
                    i_gi_id              = gi_cust-gi_id
                    i_conversion_2       = l_map_field-conversion_2
                    i_comparision_value2 = l_map_field-comparision_value2
                  CHANGING
                    c_field              = <gi_field> ).

              ELSE.
                <gi_field> = <value>.
              ENDIF.

            ENDLOOP.
          ENDLOOP.

          IF <line> IS NOT INITIAL.
            APPEND <line> TO <data_tab>.
            CLEAR <line>.
          ENDIF.

        ELSE. ""Trägerstruktur-Tabellenzeile aus Quellzeile

          LOOP AT <value_table> REFERENCE INTO l_dto_ref.
            l_index = l_index + 1.

            LOOP AT i_mp_tab-t_map_field INTO l_map_field.  "where gruppe.. ´

*             Ausschluss der Zeilen, die der Regel Parameter = <Wert> widersprechen
              IF get_use_field_by_restriction(
                  i_if          = gi_cust
                  i_mc          = i_mc
                  i_map_field   = l_map_field ) IS INITIAL.
                CONTINUE.
              ENDIF.

              fill_gi_field_ref(
                EXPORTING
                  i_gi_field = l_map_field-gi_field
                  i_line_nr  = CONV #( l_index ) ).
              ASSIGN gi_field_ref->* TO <gi_field>.

              IF l_map_field-is_line_index IS NOT INITIAL.
*               Feld für Zeilennummer
                <gi_field> = l_index.
                CONTINUE.
              ENDIF.

              IF <gi_field> IS NOT INITIAL
                AND l_map_field-overwrite IS INITIAL
                AND l_map_field-text_id IS INITIAL. "Text-Felder immer überschreiben
*               Feld soll nicht überschrieben werden
                CONTINUE.
              ENDIF.

              IF l_map_field-dto_field IS INITIAL.
                ASSIGN l_map_field-fixed_value TO <value>.
              ELSEIF l_map_field-use_param_for_dto IS NOT INITIAL.
                ASSIGN param_ref->(l_map_field-dto_field) TO <value>.
              ELSE.
                ASSIGN l_dto_ref->(l_map_field-dto_field) TO <value>.
              ENDIF.

              IF sy-subrc <> 0.
                RAISE EXCEPTION TYPE /thkr/cx_gi
                  EXPORTING
                    textid    = /thkr/cx_gi=>dto_field_not_exists
                    gi_id     = gi_cust-gi_id
                    gi_mc     = i_mc-gi_mc
                    dto_field = l_map_field-dto_field.
              ENDIF.

              IF l_map_field-conversion IS NOT INITIAL.

                do_conversions(
                  EXPORTING
                    i_conversion         = l_map_field-conversion
                    i_value              = <value>
                    i_comparision_value  = l_map_field-comparision_value
                    i_value_true         = l_map_field-value_true
                    i_value_false        = l_map_field-value_false
                    it_value_map         = l_map_field-t_map_value
                    i_map_table          = l_map_field-map_table
                    i_fdname_from        = l_map_field-fdname_from
                    i_fdname_to          = l_map_field-fdname_to
                    i_gi_field           = l_map_field-gi_field
                    i_gi_id              = gi_cust-gi_id
                    i_conversion_2       = l_map_field-conversion_2
                    i_comparision_value2 = l_map_field-comparision_value2
                  CHANGING
                    c_field              = <gi_field> ).

              ELSE.
                <gi_field> = <value>.
              ENDIF.

            ENDLOOP.

            IF gi_cust-is_mapping IS INITIAL.
              APPEND <line> TO <data_tab>.
              CLEAR <line>.
            ENDIF.

          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_data_fixed_values.

    DATA: l_data_ref     TYPE REF TO data,
          l_dto_ref      TYPE REF TO data,
          l_mapping_line TYPE /thkr/s_gi_mapping_line,
          l_map_field    LIKE LINE OF it_map_field.

    FIELD-SYMBOLS: <gi_field> TYPE any,
                   <mapping>  TYPE /thkr/t_gi_mapping_line.

    IF gi_cust-is_mapping IS INITIAL.
      GET REFERENCE OF c_data INTO data_ref.
    ENDIF.

*   Festwerte auf Rückgabestruktur schreiben
    LOOP AT it_map_field INTO l_map_field WHERE gi_mc IS INITIAL.

      fill_gi_field_ref( l_map_field-gi_field ).
      ASSIGN gi_field_ref->* TO <gi_field>.

      IF <gi_field> IS NOT INITIAL AND l_map_field-overwrite IS INITIAL.
*         Feld soll nicht überschrieben werden
        CONTINUE.
      ENDIF.

      <gi_field> = l_map_field-fixed_value.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_dto_filter.

* nicht umgsetzt

  ENDMETHOD.


  METHOD get_fieldlist_from_params.

    DATA: l_if_cust TYPE /thkr/s_gi_d,
          l_prefix  TYPE string.

    IF i_no_prefix IS INITIAL.
      l_prefix = '{PARAM}-'.
    ENDIF.

    TRY.
        get_if_cust(
          EXPORTING
            i_gi_id   = i_gi_id
          IMPORTING
            e_if_cust = l_if_cust ).
      CATCH /thkr/cx_lsa1.
    ENDTRY.

    LOOP AT l_if_cust-t_par INTO DATA(l_par).

      IF i_deep IS INITIAL OR ( l_par-record_id IS INITIAL AND l_par-structure IS INITIAL ).
        APPEND INITIAL LINE TO ct_fieldlist ASSIGNING FIELD-SYMBOL(<entry>).
        CONCATENATE l_prefix l_par-gi_param INTO <entry>-fieldname.
        <entry>-scrtext_m = l_par-description.
      ELSE.
        IF l_par-record_id IS NOT INITIAL.
          get_fieldlist_from_record(
            EXPORTING
              i_record_id  = l_par-record_id
            IMPORTING
              et_fieldlist = DATA(lt_fieldlist) ).
        ELSEIF l_par-structure IS NOT INITIAL.
          helpers->get_fieldlist_from_struct(
            EXPORTING
              i_structure  = l_par-structure
            IMPORTING
              et_fieldlist = lt_fieldlist ).
        ENDIF.

        LOOP AT lt_fieldlist INTO DATA(l_field).

          APPEND INITIAL LINE TO ct_fieldlist ASSIGNING <entry>.
          IF l_par-datatype = 'S'.  "Struktur
            CONCATENATE l_prefix l_par-gi_param '-' l_field-fieldname INTO <entry>-fieldname.
          ELSE.
            "Datentyp Referenz
            CONCATENATE l_prefix l_par-gi_param '->' l_field-fieldname INTO <entry>-fieldname.
          ENDIF.
          <entry>-scrtext_m = l_field-scrtext_m.
          <entry>-datatype  = l_field-datatype.
          <entry>-rollname  = l_field-rollname.

        ENDLOOP.


      ENDIF.
    ENDLOOP.

    SORT ct_fieldlist BY fieldname.

  ENDMETHOD.


  METHOD get_fieldlist_from_record.

    DATA: l_fieldname TYPE c LENGTH 30,
          l_nr        TYPE i,
          l_nr_c      TYPE string,
          l_nr_n      TYPE n LENGTH 3,
          l_nr_c1     TYPE string.

    CLEAR: et_fieldlist, et_gi_rec_fld.

    SELECT * INTO TABLE @DATA(lt_fld)
      FROM /thkr/c_girecfld
      WHERE record_id = @i_record_id
      ORDER BY lfd_nr.

    LOOP AT lt_fld INTO DATA(l_fld).

      l_nr = l_fld-lfd_nr.
      l_nr_c = l_nr.
      l_nr_n = l_nr.
      CONDENSE l_nr_c.

      IF l_fld-datatype <> 'STRU' OR i_resolve_structures IS INITIAL.
        APPEND INITIAL LINE TO et_fieldlist ASSIGNING FIELD-SYMBOL(<entry>).
        <entry>-fieldname = l_fld-record_fld.
        <entry>-lfd_nr = l_nr_n.
        CONCATENATE l_nr_n l_fld-record_fld
          INTO <entry>-scrtext_m SEPARATED BY space.
        <entry>-datatype    = l_fld-datatype.
      ELSE.
        "Struktur auflösen
        l_fieldname = l_fld-record_fld.
        get_fieldlist_from_record(
          EXPORTING
            i_record_id          = l_fld-table_record_id
            i_resolve_structures = 'X'
          IMPORTING
            et_fieldlist        = DATA(lt_fl_sub) ).

        LOOP AT lt_fl_sub INTO DATA(l_fl_sub).

          APPEND INITIAL LINE TO et_fieldlist ASSIGNING <entry>.

          CONCATENATE l_fieldname l_fl_sub-fieldname
            INTO <entry>-fieldname SEPARATED BY '-'.

          CONCATENATE l_nr_n '-' l_fl_sub-lfd_nr
            INTO <entry>-lfd_nr.

          CONCATENATE <entry>-lfd_nr l_fl_sub-fieldname
            INTO <entry>-scrtext_m SEPARATED BY space.

          <entry>-datatype = l_fl_sub-datatype.

        ENDLOOP.

      ENDIF.

      APPEND INITIAL LINE TO et_gi_rec_fld ASSIGNING FIELD-SYMBOL(<rec_fld>).
      MOVE-CORRESPONDING l_fld TO <rec_fld>.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_field_separator.

    DATA: l_sep TYPE ty_separator.

    FIELD-SYMBOLS <f> TYPE x.

    CASE i_field_separation.
      WHEN 'CS'.
        l_sep = ';'.
      WHEN 'PI'.
        l_sep = '|'.
      WHEN 'CG'.
        ASSIGN l_sep TO <f> CASTING TYPE x.
        <f> = '0700'.
    ENDCASE.

    r_separator = l_sep.

    RETURN.

  ENDMETHOD.


  METHOD get_gi_id_by_structure.

    CLEAR e_gi_id.

    SELECT * INTO e_if
      FROM /thkr/c_gi
      WHERE gi_structure = i_structure.

      IF e_gi_id IS NOT INITIAL.

        RAISE EXCEPTION TYPE /thkr/cx_gi
          EXPORTING
            textid       = /thkr/cx_gi=>if_by_structure_not_unique
            gi_structure = i_structure.

      ENDIF.

      e_gi_id = e_if-gi_id.

    ENDSELECT.

    IF sy-subrc <> 0.

      RAISE EXCEPTION TYPE /thkr/cx_gi
        EXPORTING
          textid       = /thkr/cx_gi=>if_by_structure_not_exists
          gi_structure = i_structure.

    ENDIF.

  ENDMETHOD.


  METHOD get_if_cust.

    DATA: l_helpers TYPE REF TO /thkr/cl_helpers,
          l_type    TYPE rs38l_typ.

    FIELD-SYMBOLS: <mc>        LIKE LINE OF e_if_cust-t_mc,
                   <map_table> LIKE LINE OF <mc>-t_map_table,
                   <map_param> LIKE LINE OF <mc>-t_map_param,
                   <map_field> LIKE LINE OF <mc>-t_map_field.

    READ TABLE t_gi_cust WITH KEY gi_id = i_gi_id INTO e_if_cust.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.


    l_helpers = /thkr/cl_helpers=>get_instance( ).

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF e_if_cust
      FROM /thkr/c_gi
      WHERE gi_id = i_gi_id.

    ASSERT sy-subrc = 0.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE e_if_cust-t_par
      FROM /thkr/c_gi_par
      WHERE gi_id = i_gi_id.

    READ TABLE e_if_cust-t_par WITH KEY gi_param = 'USRID' TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      APPEND INITIAL LINE TO e_if_cust-t_par ASSIGNING FIELD-SYMBOL(<par>).
      <par>-gi_param = 'USRID'.
      <par>-datatype = 'C'.
      <par>-length   = 12.
    ENDIF.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE e_if_cust-t_mc
      FROM /thkr/c_gi_mc
      WHERE gi_id = i_gi_id
      ORDER BY seq_no gi_mc.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE e_if_cust-t_map_field
      FROM /thkr/c_gimpfld
      WHERE gi_id = i_gi_id
      AND   gi_mc = ''
      ORDER BY gi_field lfd_nr.

*    SELECT * INTO CORRESPONDING FIELDS OF TABLE e_if_cust-t_all_fields
*      FROM /thkr/c_gimpfld
*      WHERE gi_id = i_gi_id.

    LOOP AT e_if_cust-t_mc ASSIGNING <mc>.

      IF <mc>-int_cls IS NOT INITIAL.
        l_helpers->get_type_of_parameter(
          EXPORTING
            i_clsname   = <mc>-int_cls
            i_method    = CONV #( <mc>-int_methode )
            i_parameter = 'E_DTO'
          IMPORTING
            e_type      = l_type ).

        <mc>-int_dto = l_type.
      ENDIF.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE <mc>-t_map_param
        FROM /thkr/c_gimcpar
        WHERE gi_id      = i_gi_id
        AND   gi_mc      = <mc>-gi_mc.

      LOOP AT <mc>-t_map_param ASSIGNING <map_param>.

        l_helpers->get_type_of_parameter(
          EXPORTING
            i_clsname   = <mc>-int_cls
            i_method    = CONV #( <mc>-int_methode )
            i_parameter = CONV #( <map_param>-param )
          IMPORTING
            e_type      = l_type ).

        <map_param>-param_type = l_type.

      ENDLOOP.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE <mc>-t_map_field
        FROM /thkr/c_gimpfld
        WHERE gi_id     = i_gi_id
        AND   gi_mc     = <mc>-gi_mc
        AND   gi_mp_tab = ''
        ORDER BY gi_field lfd_nr.

      LOOP AT <mc>-t_map_field ASSIGNING <map_field>.

        SELECT * INTO CORRESPONDING FIELDS OF TABLE <map_field>-t_map_value
          FROM /thkr/c_gimpval
          WHERE gi_id   = i_gi_id
          AND gi_field  = <map_field>-gi_field
          AND gi_mc     = <map_field>-gi_mc
          AND gi_mp_tab = ''
          AND lfd_nr    = <map_field>-lfd_nr.

        IF <map_field>-dto_field(8) = '{PARAM}-'.
          "Mapping auf Basis von Parametern, d.h. an Stelle eines DTO-Feldes soll ein Parameter verwendet werden
          <map_field>-dto_field = <map_field>-dto_field+8.
          <map_field>-use_param_for_dto = 'X'.
        ENDIF.

      ENDLOOP.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE <mc>-t_map_table
        FROM /thkr/c_gimptab
        WHERE gi_id = i_gi_id
        AND   gi_mc = <mc>-gi_mc
        ORDER BY seq_no.

      LOOP AT <mc>-t_map_table ASSIGNING <map_table>.

        SELECT * INTO CORRESPONDING FIELDS OF TABLE <map_table>-t_map_field
          FROM /thkr/c_gimpfld
          WHERE gi_id      = i_gi_id
          AND   gi_mc      = <mc>-gi_mc
          AND   gi_mp_tab  = <map_table>-gi_mp_tab
          ORDER BY gi_field lfd_nr.

        LOOP AT <map_table>-t_map_field ASSIGNING <map_field>.

          SELECT * INTO CORRESPONDING FIELDS OF TABLE <map_field>-t_map_value
            FROM /thkr/c_gimpval
            WHERE gi_id        = i_gi_id
            AND gi_field       = <map_field>-gi_field
            AND gi_mc          = <map_field>-gi_mc
            AND gi_mp_tab      = <map_table>-gi_mp_tab
            AND line_key_value = <map_field>-line_key_value
            AND lfd_nr         = <map_field>-lfd_nr.

          IF <map_field>-dto_field(8) = '{PARAM}-'.
            "an Stelle eines DTO-Feldes soll ein Parameter verwendet werden
            <map_field>-dto_field = <map_field>-dto_field+8.
            <map_field>-use_param_for_dto = 'X'.
          ENDIF.

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    APPEND e_if_cust TO t_gi_cust.

  ENDMETHOD.


  METHOD get_instance.

    IF instance IS INITIAL.

      CREATE OBJECT instance.

    ENDIF.

    e_instance = instance.
    r_instance = instance.

  ENDMETHOD.


  METHOD get_key_by_record_id.

    CLEAR e_record_fld_key.

    SELECT record_fld INTO @DATA(l_record_fld_key)
      FROM /thkr/c_girecfld
      WHERE record_id = @i_record_id
        AND is_key    = 'X'.

      IF e_record_fld_key IS NOT INITIAL.
        ASSERT 1 = 2.   "Es ist z.Z. nur ein Schlüsselfeld vorgesehen (bei Bedarf ausprogrammieren)
      ENDIF.
      e_record_fld_key = l_record_fld_key.
    ENDSELECT.


  ENDMETHOD.


  METHOD get_line_key_value.

    DATA: l_param_name TYPE string.

    FIELD-SYMBOLS: <param_value> TYPE any.

    IF i_line_key_value(8) = '{PARAM}-'.
      l_param_name = i_line_key_value+8(22).
      ASSIGN param_ref->(l_param_name) TO <param_value>.
      r_line_key_value = <param_value>.
    ELSE.
      r_line_key_value = i_line_key_value.
    ENDIF.

  ENDMETHOD.


  METHOD get_max_line_nr.

    LOOP AT it_mapping INTO DATA(l_line) WHERE tablename = i_table_name.
      IF l_line-line_nr > r_line_nr.
        r_line_nr = l_line-line_nr.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_param_ref.
*   Parameterstruktur aus übergebenen Parametern und definierter Parameterstruktur zusammenstellen

    DATA: l_param_ref    TYPE REF TO data,
          l_ipara_ref    TYPE REF TO data,
          l_struct_descr TYPE REF TO cl_abap_structdescr,
          lt_components  TYPE abap_component_tab,
          l_fld_ref      TYPE REF TO data,
          l_data_ref     TYPE REF TO data.

    FIELD-SYMBOLS: <value>     TYPE any,
                   <src_value> TYPE any.

    IF c_para IS NOT INITIAL.
      GET REFERENCE OF c_para INTO l_ipara_ref.
    ELSE.
      GET REFERENCE OF i_para INTO l_ipara_ref.
    ENDIF.

    APPEND INITIAL LINE TO lt_components ASSIGNING FIELD-SYMBOL(<component>).
    <component>-type ?= cl_abap_datadescr=>describe_by_data_ref( l_ipara_ref ).
    <component>-as_include = 'X'.

    LOOP AT i_if_cust-t_par INTO DATA(l_par).
      CLEAR l_fld_ref.

      ASSIGN l_ipara_ref->(l_par-gi_param) TO <value>.

      IF sy-subrc <> 0.
        "Parameter wurde nicht übergeben
        APPEND INITIAL LINE TO lt_components ASSIGNING <component>.
        <component>-name = l_par-gi_param.

        IF  l_par-datatype = 'R'. " AND l_par-record_id IS NOT INITIAL. "Referenz auf Struktur lt. Satzdefinition
          "Referenz auf Datensatz-Definition
          GET REFERENCE OF l_fld_ref INTO l_data_ref.
          <component>-type ?= cl_abap_datadescr=>describe_by_data_ref( l_data_ref ).

        ELSE.
          IF l_par-datatype = 'S'.  "Struktur

            IF l_par-record_id IS NOT INITIAL.
              "Referenz auf Datensatz-Definition
              get_record_type_handles(
                EXPORTING
                  i_record_id      = l_par-record_id
                IMPORTING
                  e_struct_descr   = l_struct_descr ).

              CREATE DATA l_fld_ref TYPE HANDLE l_struct_descr.
            ELSE.
              "Referenz auf Struktur
              CREATE DATA l_fld_ref TYPE (l_par-structure).
            ENDIF.

          ELSE.
            CREATE DATA l_fld_ref TYPE (l_par-datatype) LENGTH l_par-length.

          ENDIF.

          <component>-type ?= cl_abap_datadescr=>describe_by_data_ref( l_fld_ref ).
        ENDIF.
      ENDIF.
    ENDLOOP.

    TRY.
        l_struct_descr = cl_abap_structdescr=>create(
            p_components = lt_components ).

      CATCH cx_root INTO DATA(l_oerror).
        ASSERT 1 = 2.
    ENDTRY.

    CREATE DATA e_param_ref TYPE HANDLE l_struct_descr.

    LOOP AT i_if_cust-t_par INTO l_par.

      ASSIGN l_ipara_ref->(l_par-gi_param) TO <src_value>.

      IF sy-subrc <> 0.
        "Parameter wurde nicht übergeben
        IF l_par-gi_param = 'USRID'.
          ASSIGN usrid TO <src_value>.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.

      ASSIGN e_param_ref->(l_par-gi_param) TO <value>.
      <value> = <src_value>.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_record_definition.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF e_record
      FROM /thkr/c_gi_rec
      WHERE record_id = i_record_id.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE e_record-t_fld
      FROM /thkr/c_girecfld
      WHERE record_id = i_record_id
      AND record_fld > ''.

    e_record-separator = get_field_separator( e_record-field_separation ).

  ENDMETHOD.


  METHOD get_record_type_handles.

    DATA: lt_components TYPE abap_component_tab,
          l_dref        TYPE REF TO data,
          lt_table_key  TYPE abap_keydescr_tab,
          l_table_key   TYPE  abap_keydescr.

    READ TABLE t_type_handle INTO DATA(l_type_handle) WITH KEY record_id = i_record_id incl_structure = i_incl_structure.
    IF sy-subrc = 0.
      e_struct_descr       = l_type_handle-struct_descr.
      e_table_descr        = l_type_handle-table_descr.
      e_table_descr_sorted = l_type_handle-table_descr_sorted.
      RETURN.
    ENDIF.

    IF i_incl_structure IS NOT INITIAL.
      helpers->get_fieldlist_from_struct(
        EXPORTING
          i_structure  = i_incl_structure
        IMPORTING
          et_fieldlist = DATA(lt_fieldlist) ).

      LOOP AT lt_fieldlist INTO DATA(l_field).

        APPEND INITIAL LINE TO lt_components ASSIGNING FIELD-SYMBOL(<component>).
        <component>-name = l_field-fieldname.
        CREATE DATA l_dref TYPE (l_field-rollname).
        <component>-type ?= cl_abap_datadescr=>describe_by_data_ref( l_dref ).

      ENDLOOP.

    ENDIF.


    get_record_definition(
      EXPORTING
        i_record_id = i_record_id
      IMPORTING
        e_record    = DATA(l_record) ).

    SORT l_record-t_fld BY lfd_nr.

    LOOP AT l_record-t_fld INTO DATA(l_fld).

      APPEND INITIAL LINE TO lt_components ASSIGNING <component>.
      <component>-name = l_fld-record_fld.

      CASE l_fld-datatype.
        WHEN 'CHAR'.
          IF l_fld-length IS NOT INITIAL.
            CREATE DATA l_dref TYPE c LENGTH l_fld-length.
          ELSE.
            CREATE DATA l_dref TYPE string.
          ENDIF.
        WHEN 'DATS'.
          CREATE DATA l_dref TYPE dats.
        WHEN 'DEC'.
          CREATE DATA l_dref TYPE decfloat34.
        WHEN 'NUMC'.
          CREATE DATA l_dref TYPE n LENGTH l_fld-length.
        WHEN 'LONG'.
          CREATE DATA l_dref TYPE int8.
        WHEN 'TAB'.
          get_record_type_handles(
            EXPORTING
              i_record_id    = l_fld-table_record_id
            IMPORTING
              e_table_descr  = DATA(l_table_descr)  ).
          CREATE DATA l_dref TYPE HANDLE l_table_descr.
        WHEN 'STRU'.
          get_record_type_handles(
            EXPORTING
              i_record_id    = l_fld-table_record_id
            IMPORTING
              e_struct_descr  = DATA(l_struct_descr)  ).
          CREATE DATA l_dref TYPE HANDLE l_struct_descr.
      ENDCASE.

      <component>-type ?= cl_abap_datadescr=>describe_by_data_ref( l_dref ).

    ENDLOOP.

    READ TABLE l_record-t_fld WITH KEY is_key = 'X' INTO l_fld.
    IF sy-subrc = 0.
      "Wenn ein Schlüsselfeld definiert ist
      l_table_key-name = l_fld-record_fld.
      APPEND l_table_key TO lt_table_key.
    ENDIF.

    TRY.
        e_struct_descr = cl_abap_structdescr=>create(
            p_components = lt_components ).

        IF lt_table_key IS NOT INITIAL.
          e_table_descr = cl_abap_tabledescr=>create(
            EXPORTING
              p_line_type = e_struct_descr
              p_key       = lt_table_key ).
        ELSE.
          e_table_descr = cl_abap_tabledescr=>create(
            EXPORTING
              p_line_type = e_struct_descr ).
        ENDIF.

      CATCH cx_root INTO DATA(l_oerror).
    ENDTRY.

    IF lt_table_key IS NOT INITIAL.
      TRY.
          e_table_descr_sorted = cl_abap_tabledescr=>create(
            EXPORTING
              p_line_type  = e_struct_descr
              p_table_kind = 'O'
              p_key        = lt_table_key ).
        CATCH cx_root INTO l_oerror.
      ENDTRY.
    ENDIF.

    l_type_handle-struct_descr       = e_struct_descr.
    l_type_handle-table_descr        = e_table_descr.
    l_type_handle-table_descr_sorted = e_table_descr_sorted.
    l_type_handle-record_id          = i_record_id.
    l_type_handle-incl_structure     = i_incl_structure.
    APPEND l_type_handle TO t_type_handle.

  ENDMETHOD.


  METHOD get_structure_gi.

    SELECT SINGLE gi_structure record_id INTO (e_structure_if, e_record_id)
      FROM /thkr/c_gi
      WHERE gi_id = i_gi_id.

    ASSERT sy-subrc = 0.

  ENDMETHOD.


  METHOD get_structure_gi_tab.

    DATA: l_fieldname TYPE /thkr/structure_field,
          lt_params   TYPE /thkr/t_structure_field.

    CLEAR: e_if_tab_structure, e_record_id.

***    SELECT SINGLE table_field_struct INTO e_if_tab_structure
    SELECT SINGLE * INTO @DATA(l_mp_tab)
      FROM /thkr/c_gimptab
      WHERE gi_id     = @i_gi_id
      AND   gi_mc     = @i_gi_mc
      AND   gi_mp_tab = @i_gi_mp_tab.

    ASSERT sy-subrc = 0.
    e_gi_mp_tab_type = l_mp_tab-mp_tab_type.

    IF l_mp_tab-table_field_struct IS NOT INITIAL.
      "Zeilenstruktur wurde angegeben
      e_if_tab_structure = l_mp_tab-table_field_struct.

    ELSE.
      "Zeilenstruktur anderweitig ermitteln
      get_if_cust(
        EXPORTING
          i_gi_id   = i_gi_id
        IMPORTING
          e_if_cust = DATA(l_if_cust) ).

      "Customizing zum Methodenaufruf lesen
      READ TABLE l_if_cust-t_mc WITH KEY gi_mc = i_gi_mc INTO DATA(l_mc).

      IF l_mc-data_source = '2'.    "Daten aus Schnittstellenträgerstuktur
        IF l_mp_tab-table_field IS NOT INITIAL.
          "Es soll auf einen Parameter gemappt werden

          "Parameterliste ermitteln
          get_fieldlist_from_params(
            EXPORTING
              i_gi_id      = i_gi_id
              i_deep       = 'X'
            CHANGING
              ct_fieldlist = lt_params ).

          CONCATENATE prefix_param '-' l_mp_tab-table_field INTO l_fieldname.

          READ TABLE lt_params WITH KEY fieldname = l_fieldname INTO DATA(l_param).

          IF l_param-datatype = 'TTYP' AND l_param-rollname IS NOT INITIAL.
            TRY.
                helpers->get_rowtype_by_tabletype(
                  EXPORTING
                    i_tabletype = l_param-rollname
                  IMPORTING
                    e_rowtype   = e_if_tab_structure ).
              CATCH /thkr/cx_lsa1.
                "Kein Abbruch bei Ausnahme
            ENDTRY.
          ENDIF.

        ENDIF.
      ELSEIF l_if_cust-record_id IS NOT INITIAL AND l_mp_tab-table_field IS NOT INITIAL.
        "Es soll auf ein Feld vom Typ Tabelle eines einen definierten Datensatzes gemappt werden

        "Datensatzbeschreibung holen
        get_record_definition(
          EXPORTING
            i_record_id = l_if_cust-record_id
          IMPORTING
            e_record    = DATA(l_record_definition) ).

        READ TABLE l_record_definition-t_fld WITH KEY record_fld = l_mp_tab-table_field
          INTO DATA(l_rec_fld).

        e_record_id = l_rec_fld-table_record_id.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD get_structure_mc_dto.

    DATA: l_if_mg TYPE /thkr/c_gi_mc,
          l_type  TYPE rs38l_typ.

    CLEAR: e_structure_dto, e_record_id, e_gi_mc_data_source.

    SELECT SINGLE * INTO l_if_mg
      FROM /thkr/c_gi_mc
      WHERE gi_id = i_gi_id
      AND   gi_mc = i_gi_mc.

    ASSERT sy-subrc = 0.

    e_gi_mc_data_source = l_if_mg-data_source.
    IF l_if_mg-data_source = '2'.   "Schnittstellenträgerstruktur
      "Als Datenquelle soll die Schnittstellenträgerstruktur dienen

      get_if_cust(
        EXPORTING
          i_gi_id   = i_gi_id
        IMPORTING
          e_if_cust = DATA(l_if_cust) ).

      IF l_if_cust-is_mapping IS INITIAL.
        e_structure_dto = l_if_cust-gi_structure.
        e_record_id     = l_if_cust-record_id.
      ENDIF.

    ELSEIF l_if_mg-data_source = '1'.   "Schnittstellenparameter

      e_structure_dto = '{PARAM}'.

    ELSE.

      helpers->get_type_of_parameter(
        EXPORTING
          i_clsname     = CONV #( l_if_mg-int_cls )
          i_method      = CONV #( l_if_mg-int_methode ) ##OPERATOR
          i_parameter   = 'E_DTO'
        IMPORTING
          e_type        = l_type ).

      e_structure_dto = l_type.

    ENDIF.

  ENDMETHOD.


  METHOD get_structure_tab_dto.

    DATA: l_structure_dto TYPE /thkr/gi_structure,
          l_if_mp_tab     TYPE /thkr/c_gimptab,
          l_tabletype     TYPE ttypename,
          l_datatype      TYPE datatype_d,
          l_rowtype       TYPE ttrowtype.

    CLEAR: e_tab_dto_structure, e_record_id, e_gi_mc_data_source.

    SELECT SINGLE * INTO l_if_mp_tab
      FROM /thkr/c_gimptab
      WHERE gi_id     = i_gi_id
      AND   gi_mc     = i_gi_mc
      AND   gi_mp_tab = i_gi_mp_tab.

    IF l_if_mp_tab-dto_field_struct IS NOT INITIAL.
      "Wenn eine Zeilenstruktur für das DTO-Feld der Tabelle angegeben ist:
      e_tab_dto_structure = l_if_mp_tab-dto_field_struct.
    ELSE.
      "Zeilenstruktur des DTO-Feldes der Tabelle ermitteln
      get_structure_mc_dto(
        EXPORTING
          i_gi_id             = i_gi_id
          i_gi_mc             = i_gi_mc
        IMPORTING
          e_structure_dto     = l_structure_dto
          e_record_id         = DATA(l_mc_record_id)
          e_gi_mc_data_source = e_gi_mc_data_source ).

      IF l_if_mp_tab-dto_field IS NOT INITIAL.
        "Es ist ein DTO-Feld vom Typ Tabelle vorhanden -> dessen Struktur ermitteln
        IF l_structure_dto IS NOT INITIAL.
          helpers->get_type_by_structure_field(
            EXPORTING
              i_structure = l_structure_dto
              i_fieldname = CONV #( l_if_mp_tab-dto_field )
            IMPORTING
              e_rollname  = l_tabletype
              e_datatype  = l_datatype ).

          helpers->get_rowtype_by_tabletype(
            EXPORTING
              i_tabletype = l_tabletype
            IMPORTING
              e_rowtype   = e_tab_dto_structure ).
        ELSEIF l_mc_record_id IS NOT INITIAL.
          "Das DTO ist ein im GI-Customing Definierter Datensatz

          get_record_definition(
            EXPORTING
              i_record_id = l_mc_record_id
            IMPORTING
              e_record    = DATA(l_record_definition) ).
          READ TABLE l_record_definition-t_fld WITH KEY record_fld = l_if_mp_tab-dto_field INTO DATA(l_record_fld).
          e_record_id = l_record_fld-table_record_id.

        ENDIF.
      ELSE.
        "Das Mapping soll nicht mit Zeilen einer DTO-Tabelle erfolgen, sondern mit den
        "einfachen DTO-Feldern
        e_tab_dto_structure = l_structure_dto.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD get_use_field_by_restriction.

    DATA: l_bin_param_value       TYPE x LENGTH 2,
          l_bin_restriction_value TYPE x LENGTH 2,
          l_num                   TYPE i.

    r_use_field = 'X'.
    IF i_map_field-restriction_param IS NOT INITIAL.

      ASSIGN param_ref->(i_map_field-restriction_param) TO FIELD-SYMBOL(<param_value>).

      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_gi
          EXPORTING
            textid   = /thkr/cx_gi=>param_not_exists
            param    = i_map_field-restriction_param
            gi_id    = i_if-gi_id
            gi_mc    = i_mc-gi_mc
            gi_field = i_map_field-gi_field.
      ENDIF.

      IF i_map_field-restriction_param_opt = 'BAND'.  "Bit-And
        TRY.
            l_num             = <param_value>.
            l_bin_param_value = l_num.
          CATCH cx_sy_conversion_no_number.
            RAISE EXCEPTION TYPE /thkr/cx_gi
              EXPORTING
                textid = /thkr/cx_gi=>param_value_not_a_number
                gi_id  = i_if-gi_id
                gi_mc  = i_mc-gi_mc
                param  = i_map_field-restriction_param
                value  = <param_value>.
        ENDTRY.
        TRY.
            l_num                   = i_map_field-restriction_value.
            l_bin_restriction_value = l_num.
          CATCH cx_sy_conversion_no_number.
            RAISE EXCEPTION TYPE /thkr/cx_gi
              EXPORTING
                textid   = /thkr/cx_gi=>param_value_field_not_a_number
                gi_id    = i_if-gi_id
                gi_field = i_map_field-gi_field
                param    = i_map_field-restriction_param
                value    = <param_value>.
        ENDTRY.

        l_bin_param_value = l_bin_param_value BIT-AND l_bin_restriction_value.
        IF l_bin_param_value IS INITIAL.
          CLEAR r_use_field.
        ENDIF.
      ELSEIF i_map_field-restriction_param_opt = 'NEQ'. "Ungleich
        IF <param_value> = i_map_field-restriction_value.
          CLEAR r_use_field.
        ENDIF.
      ELSEIF i_map_field-restriction_param_opt = 'BTW'. "zwischen
        SPLIT i_map_field-restriction_value AT '-' INTO DATA(lv_low) DATA(lv_high).
        IF lv_low IS INITIAL OR lv_high IS INITIAL.
          RAISE EXCEPTION TYPE /thkr/cx_gi
            EXPORTING
              textid = /thkr/cx_gi=>param_value_between_error
              gi_id  = i_if-gi_id
              param  = i_mc-restriction_param
              value  = <param_value>.
        ELSE.
          IF NOT <param_value> BETWEEN lv_low AND lv_high.
            CLEAR r_use_field.
          ENDIF.
        ENDIF.
      ELSE.
        IF <param_value> <> i_map_field-restriction_value.
          CLEAR r_use_field.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_use_mc_by_restriction.

    DATA: l_bin_param_value       TYPE x LENGTH 2,
          l_bin_restriction_value TYPE x LENGTH 2,
          l_num                   TYPE i.

    r_use_mc = 'X'.
    IF i_mc-restriction_param IS NOT INITIAL.

      ASSIGN param_ref->(i_mc-restriction_param) TO FIELD-SYMBOL(<param_value>).

      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_gi
          EXPORTING
            textid = /thkr/cx_gi=>param_not_exists_mc
            param  = i_mc-restriction_param
            gi_id  = i_if-gi_id
            gi_mc  = i_mc-gi_mc.
      ENDIF.

      IF i_mc-restriction_param_opt = 'BAND'.  "Bit-And
        TRY.
            l_num             = <param_value>.
            l_bin_param_value = l_num.
          CATCH cx_sy_conversion_no_number.
            RAISE EXCEPTION TYPE /thkr/cx_gi
              EXPORTING
                textid = /thkr/cx_gi=>param_value_not_a_number
                gi_id  = i_if-gi_id
                gi_mc  = i_mc-gi_mc
                param  = i_mc-restriction_param
                value  = <param_value>.
        ENDTRY.
        TRY.
            l_num                   = i_mc-restriction_value.
            l_bin_restriction_value = l_num.
          CATCH cx_sy_conversion_no_number.
            RAISE EXCEPTION TYPE /thkr/cx_gi
              EXPORTING
                textid = /thkr/cx_gi=>param_value_mc_not_a_number
                gi_id  = i_if-gi_id
                gi_mc  = i_mc-gi_mc
                param  = i_mc-restriction_param
                value  = <param_value>.
        ENDTRY.

        l_bin_param_value = l_bin_param_value BIT-AND l_bin_restriction_value.
        IF l_bin_param_value IS INITIAL.
          CLEAR r_use_mc.
        ENDIF.
      ELSEIF i_mc-restriction_param_opt = 'NEQ'. "Ungleich
        IF <param_value> = i_mc-restriction_value.
          CLEAR r_use_mc.
        ENDIF.
      ELSEIF i_mc-restriction_param_opt = 'BTW'. "zwischen
        SPLIT i_mc-restriction_value AT '-' INTO DATA(lv_low) DATA(lv_high).
        IF lv_low IS INITIAL OR lv_high IS INITIAL.
          RAISE EXCEPTION TYPE /thkr/cx_gi
            EXPORTING
              textid = /thkr/cx_gi=>param_value_between_error
              gi_id  = i_if-gi_id
              param  = i_mc-restriction_param
              value  = <param_value>.
        ELSE.
          IF NOT <param_value> BETWEEN lv_low AND lv_high.
            CLEAR r_use_mc.
          ENDIF.
        ENDIF.
      ELSE.
        IF <param_value> <> i_mc-restriction_value.
          CLEAR r_use_mc.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD handle_text_fields.

    DATA: l_data_ref         TYPE REF TO data,
          l_gi_field         TYPE /thkr/gi_field,
          l_gi_table_field   TYPE /thkr/gi_table_field,
          l_gi_fixed_line_nr TYPE /thkr/gi_fixed_line_nr,
          l_value1           TYPE string,
          l_value2           TYPE string,
          l_value3           TYPE string,
          l_value4           TYPE string,
          l_value5           TYPE string,
          l_text_id          TYPE /thkr/gi_text_id,
          l_mapping_line     TYPE LINE OF /thkr/t_gi_mapping_line,
          l_text             TYPE string.

    FIELD-SYMBOLS: <gi_field> TYPE any,
                   <mapping>  TYPE /thkr/t_gi_mapping_line.
*                   <mapping_line> LIKE LINE OF <mapping>.

    IF i_if-is_mapping IS INITIAL.
      GET REFERENCE OF c_data INTO l_data_ref.
    ELSE.
      ASSIGN c_data TO <mapping>.
*      ASSERT sy-subrc = 0.
    ENDIF.

    "Die Tabelle t_text_field enthält Einträge zu Feldern, die mit Texten gemäß ZCBAU_TEXT/ ZCBAU_TEXT_LINE
    "gefüllt werden sollen. In den Texten können die Platzhalter $1, $2 und $3 enthalten sein.
    "D.h. um den Text mit der ID 'TEXT1' und der Zeile:
    "     'in der $1. KW $2, spätestens am letzten Werktag dieser KW'
    "in das Zielfeld 'FELD1' zu übertragen, muss t_text_field die folgenden Einträge enthalten:
    " FELD1 | 01 | 28   | TEXT1
    " FELD1 | 02 | 2019 | TEXT1
    "
    "Ergebnis: FELD1 enthält den Wert: 'in der 28. KW 2019, spätestens am letzten Werktag dieser KW'

    "Tabelle nach Zielfeld und laufender Nummer sortieren
    SORT t_text_field BY gi_field table_field fixed_line_nr lfd_nr.

*   Letzten Gruppenwechsel erzwingen:
    APPEND INITIAL LINE TO t_text_field ASSIGNING FIELD-SYMBOL(<text_field>).

    LOOP AT t_text_field ASSIGNING <text_field>.

      IF l_gi_field IS NOT INITIAL                  "nicht beim 1. Satz
        AND ( l_gi_field <> <text_field>-gi_field
          OR l_gi_table_field <> <text_field>-table_field
          OR l_gi_fixed_line_nr <> <text_field>-fixed_line_nr ).
*       Gruppenwechsel

        " Textzeile zusammensetzen
        SELECT * INTO @DATA(l_text_line)
          FROM /thkr/c_gitextl
          WHERE text_id = @l_text_id
          ORDER BY line_nr.
          CONCATENATE l_text l_text_line-text_line INTO l_text. " SEPARATED BY space.

          IF l_text_line-lf IS NOT INITIAL.
            CONCATENATE l_text cl_abap_char_utilities=>cr_lf INTO l_text.
          ENDIF.

        ENDSELECT.
        " Platzhalter mit Werten füllen
        REPLACE '$1' IN l_text WITH l_value1.
        REPLACE '$2' IN l_text WITH l_value2.
        REPLACE '$3' IN l_text WITH l_value3.
        REPLACE '$4' IN l_text WITH l_value4.
        REPLACE '$5' IN l_text WITH l_value5.

        fill_gi_field_ref(
            i_gi_field      = l_gi_field
            i_table_field   = l_gi_table_field
            i_fixed_line_nr = l_gi_fixed_line_nr ).

        ASSIGN gi_field_ref->* TO <gi_field>.

        <gi_field> = l_text.

        CLEAR: l_value1, l_value2, l_value3, l_value4, l_value5, l_text, l_gi_field, l_text_id, l_gi_table_field, l_gi_fixed_line_nr.
      ENDIF.

      l_gi_field         = <text_field>-gi_field.
      l_gi_table_field   = <text_field>-table_field.
      l_gi_fixed_line_nr = <text_field>-fixed_line_nr.
      l_text_id  = <text_field>-text_id.

      IF <text_field>-lfd_nr = '01' OR <text_field>-lfd_nr IS INITIAL.
        l_value1 = <text_field>-value.
      ELSEIF <text_field>-lfd_nr = '02'.
        l_value2 = <text_field>-value.
      ELSEIF <text_field>-lfd_nr = '03'.
        l_value3 = <text_field>-value.
      ELSEIF <text_field>-lfd_nr = '04'.
        l_value4 = <text_field>-value.
      ELSEIF <text_field>-lfd_nr = '05'.
        l_value5 = <text_field>-value.
      ENDIF.

    ENDLOOP.

    CLEAR t_text_field.

  ENDMETHOD.


  METHOD read_buffer.

    DATA: l_area_handle TYPE REF TO /thkr/cl_gi_shm,
          l_oerror      TYPE REF TO cx_root.

    TRY.
        l_area_handle = /thkr/cl_gi_shm=>attach_for_read(
          EXPORTING
            inst_name = CONV #( i_shm_id ) ).

        retval = l_area_handle->root->get_entry_from_buffer(
          EXPORTING
            i_gi_id         = i_gi_id
            i_para          = i_para
          CHANGING
            c_data          = c_data ).

        l_area_handle->detach( ).

      CATCH cx_root INTO l_oerror.
        retval = -1.
    ENDTRY.


  ENDMETHOD.


  METHOD test_conversion.

    do_conversion(
      EXPORTING
        i_conversion        = i_conversion
        i_value             = i_value
        i_comparision_value = i_comparision_value
        i_value_true        = i_value_true
        i_value_false       = i_value_false
        it_value_map        = it_value_map
        i_map_table         = i_map_table
        i_fdname_from       = i_fdname_from
        i_fdname_to         = i_fdname_to
        i_gi_field          = i_gi_field
        i_gi_id             = i_gi_id
      CHANGING
        c_field             = c_field
           ).

  ENDMETHOD.


  METHOD write_buffer.

    DATA: l_area_handle TYPE REF TO /thkr/cl_gi_shm,
          l_buffer      TYPE REF TO /thkr/cl_gi_shm_buffer,
          l_oerror      TYPE REF TO cx_root.

    TRY.

        l_area_handle = /thkr/cl_gi_shm=>attach_for_update( CONV #( i_shm_id ) ).

      CATCH cx_shm_attach_error INTO l_oerror.

    ENDTRY.

    TRY.

        IF l_area_handle IS INITIAL.

          l_area_handle = /thkr/cl_gi_shm=>attach_for_write( CONV #( i_shm_id ) ).
          CREATE OBJECT l_buffer AREA HANDLE l_area_handle.
          l_area_handle->set_root( l_buffer ).

        ENDIF.

        l_area_handle->root->put_entry_to_buffer(
          EXPORTING
            i_gi_id         = i_gi_id
            i_para          = i_para
            i_data          = i_data ).

        l_area_handle->detach_commit( ).

      CATCH cx_root INTO l_oerror.

    ENDTRY.

  ENDMETHOD.


  METHOD write_gi_mapping_to_line.

    DATA: l_last_pos     TYPE i,
          l_offset       TYPE i,
          l_cstring      TYPE c LENGTH 1000,
          l_string       TYPE string,
          l_sep          TYPE c,
          l_end_pos      TYPE i,
          l_mapping_line LIKE LINE OF it_mapping.

    get_record_definition(
      EXPORTING
        i_record_id = i_record_id
      IMPORTING
        e_record    = DATA(l_record) ).

    SORT l_record-t_fld BY lfd_nr.

    l_offset = -1.
    LOOP AT l_record-t_fld INTO DATA(l_fld).
      "Feldwert lesen
      CLEAR l_mapping_line.
      READ TABLE it_mapping WITH KEY key = l_fld-record_fld INTO l_mapping_line.

      IF sy-subrc <> 0.
        "Feldwert nicht gefunden.
        IF l_fld-mandatory IS NOT INITIAL.
          RAISE EXCEPTION TYPE /thkr/cx_gi
            EXPORTING
              textid    = /thkr/cx_gi=>record_field_not_filled
              record_id = i_record_id
              gi_field  = l_fld-record_fld.
        ELSEIF l_record-field_separation <> 'FX'. "Keine feste Satzlänge, d.h. mit Feldseparator
          CONCATENATE l_string l_sep INTO l_string.
          l_sep = l_record-separator.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF l_record-field_separation <> 'FX'. "Keine feste Satzlänge, d.h. mit Feldseparator
        CONCATENATE l_string l_sep l_mapping_line-value INTO l_string.
        l_sep = l_record-separator.
        CONTINUE.
      ENDIF.

      l_string = l_mapping_line-value.

      ADD l_offset TO l_fld-start_pos.  "Für Position 1001-2000 ist Offset -1000, usw.
      IF l_fld-start_pos >= 1000.
        "Neuer Teilstring notwendig
        CONCATENATE e_line l_cstring INTO e_line RESPECTING BLANKS.
        CLEAR l_cstring.
        l_offset        = l_offset - 1000.
        l_fld-start_pos = l_fld-start_pos - 1000.
      ENDIF.

      IF l_fld-start_pos + l_fld-length <= 1000.  "Wert passt auf den String
        l_cstring+l_fld-start_pos(l_fld-length) = l_mapping_line-value.
      ELSE.
        "Positionen bis 1000 auffüllen
        l_cstring+l_fld-start_pos = l_mapping_line-value.

        "Neuen Teilstring initialisieren
        CONCATENATE e_line l_cstring INTO e_line RESPECTING BLANKS.
        CLEAR l_cstring.
        l_offset = l_offset - 1000.
        ADD l_offset TO l_fld-start_pos.
        ADD l_fld-start_pos TO l_fld-length.
        IF l_mapping_line-value IS NOT INITIAL.
          l_cstring = l_mapping_line-value(l_fld-length).
        ENDIF.

      ENDIF.

    ENDLOOP.

    IF l_record-field_separation = 'FX'. "Fixen Positionen
      l_end_pos = l_fld-start_pos + l_fld-length.
      CONCATENATE e_line l_cstring(l_end_pos) INTO e_line RESPECTING BLANKS.
    ELSE.
      e_line = l_string.
    ENDIF.

  ENDMETHOD.


  METHOD write_gi_mapping_to_record.

    FIELD-SYMBOLS: <gi_field> TYPE any.

    get_record_definition(
      EXPORTING
        i_record_id = i_record_id
      IMPORTING
        e_record    = DATA(l_record) ).

    GET REFERENCE OF c_record INTO DATA(l_dref).

    SORT l_record-t_fld BY lfd_nr.

    LOOP AT l_record-t_fld INTO DATA(l_fld).
      IF l_fld-datatype = 'TAB'.
        CONTINUE.
        "Bisher nicht implementiert. Implementierung möglich; hierzu müssten im Mapping
        "Tabellenname/Zeile angegeben werden, dann könnte ein Mapping auf die Zielstruktur
        "erfolgen.
        "loop at it_mapping where tablename = l_fld-table_record_id ...
      ENDIF.


      "Feldwert lesen
      READ TABLE it_mapping WITH KEY key = l_fld-record_fld INTO DATA(l_line).

      IF sy-subrc <> 0.
        "Feldwert nicht gefunden.
        IF l_fld-mandatory IS INITIAL.
          CONTINUE.
        ELSE.
          RAISE EXCEPTION TYPE /thkr/cx_gi
            EXPORTING
              textid    = /thkr/cx_gi=>record_field_not_filled
              record_id = i_record_id
              gi_field  = l_fld-record_fld.
        ENDIF.
      ENDIF.

      ASSIGN l_dref->(l_fld-record_fld) TO <gi_field>.
      ASSERT sy-subrc = 0.

      <gi_field> = l_line-value.

    ENDLOOP.

  ENDMETHOD.


  METHOD write_line_to_gi_mapping.

    CLEAR: et_mapping.

    DATA: l_act_pos TYPE i,
          l_string  TYPE string.

    get_record_definition(
      EXPORTING
        i_record_id = i_record_id
      IMPORTING
        e_record    = DATA(l_record) ).

    SORT l_record-t_fld BY lfd_nr.

    DATA(l_len) = strlen( i_line ).
    LOOP AT l_record-t_fld INTO DATA(l_fld).

      APPEND INITIAL LINE TO et_mapping ASSIGNING FIELD-SYMBOL(<line>).
      <line>-key = l_fld-record_fld.

      IF l_record-field_separation <> 'FX'. "Keine fixen Positionen

        DATA(l_len1) = l_len - l_act_pos.
        DATA(l_pos)  = find( val = i_line+l_act_pos(l_len1)
                             sub = l_record-separator ).

        IF l_pos > 0.
          <line>-value = i_line+l_act_pos(l_pos).
        ELSEIF l_pos < 0.
          "Keine weitere Position gefunden.
          <line>-value = i_line+l_act_pos(l_len1).
          EXIT.
        ENDIF.

        l_act_pos = l_act_pos + l_pos + 1.

      ELSE.
        "Fixe Positionen
        l_act_pos = l_fld-start_pos - 1.
        <line>-value = i_line+l_act_pos(l_fld-length).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.

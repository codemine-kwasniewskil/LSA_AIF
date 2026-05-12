class /THKR/CL_INIT_ACTION_FIELD_OVW definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR .
  methods OVERWRITE_FIELDS
    changing
      !CS_DATA type ANY
      !CT_RETURN type BAPIRET2_TT .
  methods GET_FIELDS_FOR_OVERWRITE
    returning
      value(RT_FIELDS_FOR_OVERWRITE) type /AIF/T_VMAPVAL5_TT .
protected section.
private section.

  types:
    BEGIN OF ty_s_run_info,
      ximsgguid      TYPE  /aif/sxmssmguid,
      msgdate        TYPE  sydatum,
      msgtime        TYPE  syuzeit,
      variant        TYPE  /aif/t_variant,
      trace_level    TYPE  /aif/trace_level,
      sending_system TYPE  /aif/aif_business_system_key,
      log_handle     TYPE  balloghndl,
      testrun        TYPE  /aif/iftestrun,
      ns             TYPE  /aif/ns,
      ifname         TYPE  /aif/ifname,
      ifversion      TYPE  /aif/ifversion,
      finf           TYPE  /aif/t_finf,
      process_id     TYPE  /aif/process_id_e,
    END OF ty_s_run_info .

  data MS_AIF_GLOBALES type TY_S_RUN_INFO .
  constants GC_VMAPNAME_OVERWRITE type /AIF/VMAPNAME value 'MAP_FIELDS_OVERWRITE' ##NO_TEXT.
  constants GC_VMAPNS_OVERWRITE type /AIF/NS value 'ZALLGE' ##NO_TEXT.

  methods CHANGE_FIELD_CONTENT
    importing
      !IT_OVERWRITE_FIELDS type /AIF/T_VMAPVAL5_TT
    changing
      !CS_DATA type ANY
      !CT_RETURN type BAPIRET2_TT .
  methods GET_COMPONENT_OF_STRUCTURE
    importing
      !IV_STRUCNAME type STRUKNAME
    exporting
      !ET_COMP type ABAP_COMPDESCR_TAB
      !EV_STRUC_NAME type STRUKNAME .
  methods CHANGE_FIELD_IN_STRUCTURE
    importing
      !IT_OVERWRITE_FIELDS type /AIF/T_VMAPVAL5_TT
      !IS_STRUCNAME type STRUKNAME
      !IT_COMP type ABAP_COMPDESCR_TAB
    changing
      !CS_DATA type ANY
      !CT_RETURN type BAPIRET2_TT .
ENDCLASS.



CLASS /THKR/CL_INIT_ACTION_FIELD_OVW IMPLEMENTATION.


  METHOD CHANGE_FIELD_CONTENT.
    DATA: lo_struc TYPE REF TO cl_abap_structdescr.
    DATA: ls_strukname TYPE strukname.
    DATA: lt_comp_root TYPE ABAP_COMPDESCR_TAB.


    lo_struc ?= cl_abap_structdescr=>describe_by_data( p_data = cs_data ).

    get_component_of_structure(
      EXPORTING
        iv_strucname       = conv strukname( lo_struc->absolute_name )
      IMPORTING
        et_comp       = lt_comp_root
        ev_struc_name = ls_strukname
    ).

    "Feldänderung auf Root-Ebene
    change_field_in_structure(
      EXPORTING
        it_overwrite_fields = it_overwrite_fields
        is_strucname        = ls_strukname                 " Name einer Struktur
        it_comp             = lt_comp_root
      CHANGING
        cs_data             = cs_data
        ct_return           = ct_return
    ).

  ENDMETHOD.


  METHOD change_field_in_structure.

    DATA: lt_comp_sub TYPE abap_compdescr_tab.
    DATA: lv_sub_struc TYPE strukname.
    DATA: lo_type TYPE REF TO cl_abap_typedescr.
    DATA: lo_table TYPE REF TO cl_abap_tabledescr.

    "Feld für eigene Struktur überschreiben
    LOOP AT it_overwrite_fields ASSIGNING FIELD-SYMBOL(<ls_fields_for_ovwr>) WHERE ext_value4 = is_strucname
                                                                 OR ext_value4 = '*'.
      ASSIGN COMPONENT <ls_fields_for_ovwr>-ext_value5 OF STRUCTURE cs_data TO FIELD-SYMBOL(<lv_field>).
      "Daten nur ändern, wenn in Struktur vorhanden
      IF <lv_field> IS ASSIGNED and sy-subrc = 0.
        <lv_field> = <ls_fields_for_ovwr>-int_value.
        if 1 = 0. MESSAGE w069(/THKR/SST) with <ls_fields_for_ovwr>-ext_value5 is_strucname <ls_fields_for_ovwr>-int_value.endif.
        Append VALUE bapiret2( id = '/THKR/SST'
                                number = 069
                                type = 'W'
                                message_v1 = <ls_fields_for_ovwr>-ext_value5
                                message_v2 = is_strucname
                                message_v3 = <ls_fields_for_ovwr>-int_value ) To ct_return.
      ENDIF.
    ENDLOOP.

    "Feld für Unterstrukturen ersetzen.
    "In der Struktur gibt es das Feld nicht. Also in den Unterkomponenten suchen.
    LOOP AT it_comp ASSIGNING FIELD-SYMBOL(<ls_comp>) WHERE type_kind = 'h' OR type_kind = 'v'.

      CASE: <ls_comp>-type_kind.
        WHEN: 'h'. "Tabelle
          "Abarbeiten von Tabellen
          ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE cs_data TO FIELD-SYMBOL(<lt_sub_tab>).
          IF <lt_sub_tab> IS ASSIGNED.
            LOOP AT <lt_sub_tab> ASSIGNING FIELD-SYMBOL(<ls_sub_struc>).
              "Datentyp der Zeile ermitteln
              lo_type ?= cl_abap_typedescr=>describe_by_data( p_data = <ls_sub_struc> ).
              DATA(lv_type) = lo_type->absolute_name.
              "Componenten der Struktur abholen.
              get_component_of_structure(
            EXPORTING
              iv_strucname  = CONV strukname( lv_type+6 )
            IMPORTING
              et_comp       = lt_comp_sub
              ev_struc_name = lv_sub_struc                 " Name einer Struktur
          ).

              change_field_in_structure(
                  EXPORTING
                    it_overwrite_fields = it_overwrite_fields
                    is_strucname        =  conv strukname( lv_type+6 )                 " Name einer Struktur
                    it_comp             = lt_comp_sub
                  CHANGING
                    cs_data             = <ls_sub_struc>
                    ct_return           = ct_return
                ).
            ENDLOOP.
          ENDIF.
        WHEN: 'v'. "Struktur
          "Prüfung, ob es eine Unterstruktur gibt.
          CLEAR: lt_comp_sub.
          "Durch die einzelnen Komponenten der Struktur gehen.
          ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE cs_data TO <ls_sub_struc>.
          lo_type ?= cl_abap_typedescr=>describe_by_data( p_data = <ls_sub_struc> ).
          lv_type = lo_type->absolute_name.
          get_component_of_structure(
            EXPORTING
              iv_strucname  = CONV strukname( lv_type+6 )
            IMPORTING
              et_comp       = lt_comp_sub
              ev_struc_name = lv_sub_struc                 " Name einer Struktur
          ).
          "Unterkomponenten der Unterstruktur ermitteln.
          change_field_in_structure(
            EXPORTING
              it_overwrite_fields = it_overwrite_fields
              is_strucname        = conv strukname( lv_type+6 )                  " Name einer Struktur
              it_comp             = lt_comp_sub
            CHANGING
              cs_data             = <ls_sub_struc>
              ct_return           = ct_return
          ).

      ENDCASE.
*
*          "Prüfen, ob auf dieser Ebene Feldinhalte ausgetauscht werden sollen.
*          LOOP AT it_overwrite_fields ASSIGNING <ls_fields_for_ovwr> WHERE ext_value4 = is_strucname
*                                                                     OR ext_value4 = '*'.
*            ASSIGN COMPONENT <ls_fields_for_ovwr>-ext_value5 OF STRUCTURE <ls_sub_struc> TO <lv_field>.
*            IF <lv_field> IS ASSIGNED.
*              <lv_field> = <ls_fields_for_ovwr>-int_value.
*            ENDIF.
*          ENDLOOP.
*          ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE cs_data TO FIELD-SYMBOL(<ls_data>).
*          get_component_of_structure(
*            EXPORTING
*              is_data       = <ls_comp>-name
*            IMPORTING
*              et_comp       = lt_comp_sub
*              ev_struc_name = is_strukname
*          ).
*
*          "Felder in Unterstruktur mappen.
*          change_field_in_structure(
*            EXPORTING
*              it_overwrite_fields = it_overwrite_fields
*              is_strucname        = ls_strukname                 " Name einer Struktur
*            CHANGING
*              cs_data             = <ls_data>
*          ).

    ENDLOOP.

  ENDMETHOD.


  method CONSTRUCTOR.
        CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
      IMPORTING
        ximsgguid      = ms_aif_globales-ximsgguid
        msgdate        = ms_aif_globales-msgdate
        msgtime        = ms_aif_globales-msgtime
        variant        = ms_aif_globales-variant
        trace_level    = ms_aif_globales-trace_level
        sending_system = ms_aif_globales-sending_system
        log_handle     = ms_aif_globales-log_handle
        testrun        = ms_aif_globales-testrun
        ns             = ms_aif_globales-ns
        ifname         = ms_aif_globales-ifname
        ifversion      = ms_aif_globales-ifversion
        finf           = ms_aif_globales-finf
        process_id     = ms_aif_globales-process_id.
  endmethod.


  method GET_COMPONENT_OF_STRUCTURE.
    DATA: lo_struc TYPE REF TO cl_abap_structdescr.

    lo_struc ?= cl_abap_structdescr=>describe_by_name( p_name = iv_strucname ).
    ev_struc_name = lo_struc->get_relative_name( ).
    et_comp = lo_struc->components.
  endmethod.


  method GET_FIELDS_FOR_OVERWRITE.

    SELECT *
      FROM /AIF/T_MVMAPVAL5
     WHERE ns = @gc_vmapns_overwrite
       AND vmapname = @gc_vmapname_overwrite
       AND ( ext_value1 = '*' or ext_value1 = @ms_aif_globales-ns )
       AND ( ext_value2 = '*' or ext_value2 = @ms_aif_globales-ifname )
       AND ( ext_value3 = '*' or ext_value3 = @ms_aif_globales-ifversion )
    INTO TABLE @rt_fields_for_overwrite.

  endmethod.


  METHOD OVERWRITE_FIELDS.
    DATA: lt_overwrite_fields TYPE STANDARD TABLE OF /aif/t_mvmapval5.

    "Konfiguration lesen.
    lt_overwrite_fields = get_fields_for_overwrite( ).

    IF lt_overwrite_fields IS INITIAL.
      "Es gibt keine Überschreibungswünsche
      RETURN.
    ELSE.
      "Feldinhalte sollen überschrieben werden.
      change_field_content(
        EXPORTING
          it_overwrite_fields = lt_overwrite_fields
        CHANGING
          cs_data             = cs_data
          ct_return           = ct_return
      ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

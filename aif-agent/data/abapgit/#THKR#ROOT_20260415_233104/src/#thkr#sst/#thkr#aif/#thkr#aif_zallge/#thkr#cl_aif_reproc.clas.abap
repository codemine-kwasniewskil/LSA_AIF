class /THKR/CL_AIF_REPROC definition
  public
  final
  create public .

public section.

  types:
    TY_RNG_KEYS TYPE RANGE OF rsecadmval .
  types:
    TY_RNG_LINES TYPE RANGE OF i .
  types:
    BEGIN OF TY_S_MSG,
      msg_guid_old TYPE /aif/sxmssmguid,
      msg_guid_new TYPE /aif/sxmssmguid,
      msg_content TYPE REF TO data,
    END OF ty_s_msg .
  types:
    TY_T_MSGS TYPE STANDARD TABLE OF ty_s_msg .

  data MT_MSG_FOR_PROT type TY_T_MSGS .

  methods CONSTRUCTOR .
  methods MAP_PROC_STAT
    importing
      !IV_OBJTYP type /THKR/AIF_OBJTYP
      !IV_OBJID type CHAR26
    returning
      value(RV_PROC_STAT) type /AIF/PROC_STATUS .
  methods UPDATE_PROC_STAT_SINGLE
    importing
      !IS_CURR_LINE type ANY
      !IV_ABSOLUTE_NAME type STRING
    returning
      value(RV_SUCCESS) type /AIF/SUCCESSFLAG
    raising
      /THKR/CX_AIF .
  methods UPDATE_PROC_STAT_MULTI
    changing
      !CS_CURR_LINE type ANY
    returning
      value(RV_SUCCESS) type /AIF/SUCCESSFLAG
    raising
      /THKR/CX_AIF .
  methods DELETE_SUCCESSFULL_MSGS
    changing
      !CT_RETURN_TAB type BAPIRET2_T
    returning
      value(RV_SUCCESS) type /AIF/SUCCESSFLAG .
  methods DELTET_CANCELED_MSGS
    changing
      value(CT_RETURN_TAB) type BAPIRET2_T .
  methods CHECK_REPROC_IS_ACTIVE
    returning
      value(RV_REPROC_IS_ACTIVE) type FLAG .
  methods GET_TYPE_OF_PROCESSING
    importing
      !IV_ABSOLUTE_NAME type STRING
    returning
      value(RV_TYPE_OF_PROCESSING) type /THKR/AIF_OBJTYP
    raising
      /THKR/CX_AIF .
  methods SET_STATUS_E_FOR_BLANK
    importing
      !IV_ABSOLUTE_NAME type STRING
    changing
      !CS_CURR_LINE type ANY .
  methods DELETET_SUCCESSFUL_AIF_MSGS
    changing
      value(CT_RETURN_TAB) type BAPIRET2_T .
  methods GET_AIF_MESSAGE
    returning
      value(RS_XMLPARSE) type /AIF/XMLPARSE_DATA
    raising
      /AIF/CX_ERROR_HANDLING_GENERAL
      /AIF/CX_AIF_ENGINE_NOT_FOUND .
  methods CHECK_AIF_MESSAGE_STATUS
    importing
      !IV_MSG_IN_PROCESS type FLAG
    exporting
      !ET_RETURN type BAPIRET2_TT
    returning
      value(RV_MSG_HAS_ERRORS) type FLAG .
  methods SET_AIF_PROPERTIES
    importing
      !IV_NS type /AIF/NS
      !IV_IFNAME type /AIF/IFNAME
      !IV_IFVERS type /AIF/IFVERSION
      !IV_MSG_GUID type /AIF/SXMSSMGUID .
  methods REDUCE_MESSAGE
    importing
      !IT_SEL_LINES type TY_RNG_LINES
      !IV_STRUC type TYPENAME
      !IT_SEL_KEYS1 type TY_RNG_KEYS
      !IV_SEL_KEYNAME1 type STRING
      !IV_SEL_TYPE type CHAR1
      !IT_SEL_KEYS2 type TY_RNG_KEYS
      !IV_SEL_KEYNAME2 type STRING
      !IT_SEL_KEYS3 type TY_RNG_KEYS
      !IV_SEL_KEYNAME3 type STRING
    changing
      !CV_RESEND_MESSAGE type FLAG
      !CS_DATA type ANY
      !CT_RETURN type BAPIRET2_TT .
  methods CANCEL_OLD_MESSAGE
    importing
      !IV_MSG_GUID type /AIF/SXMSSMGUID
    raising
      /AIF/CX_MESSAGE_STATISTICS
      /AIF/CX_ERROR_HANDLING_GENERAL .
  methods UPDATE_PERS_CGR
    importing
      !IV_USER type /AIF/BTCAUTHNAM
      !IV_QNS type /AIF/PERS_RTCFGR_NS
      !IV_QNAME type /AIF/PERS_RTCFGR_NAME
    changing
      !CT_RETURN type BAPIRET2_TT .
  methods SET_SEL_TYPYE
    importing
      !IV_LINES type FLAG
      !IV_KEYS type FLAG
    returning
      value(RV_SEL_TYPE) type CHAR1 .
  methods SHOW_REDUCED_MESSAGE
    importing
      !IV_SHOW_STRUC type FLAG
      !IV_SHOW_FIELDS type FLAG .
  methods GET_FAILED_MSGS_FOR_INTERFACE
    importing
      !IV_MSG_GUID type GUID
      !IV_MSG_IN_PROCESS type FLAG
    changing
      !CT_RETURN_TAB type BAPIRET2_T
    returning
      value(RT_MSGS) type /AIF/TT_MSGGUID .
protected section.
private section.

  types:
    BEGIN OF ty_s_msgguid,
        msgguid TYPE guid_32,
      END OF ty_s_msgguid .
  types:
    ty_t_msgguid TYPE STANDARD TABLE OF ty_s_msgguid .
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
  types:
    BEGIN OF TY_S_SHOW_MSG,
    comp_name TYPE typename,
    content TYPE string,
  END OF ty_s_show_msg .
  types:
    TY_T_SHOW_MSG TYPE STANDARD TABLE OF ty_s_show_msg .

  data MS_AIF_GLOBALES type TY_S_RUN_INFO .
  constants GC_SEL_TYPE_LINES type CHAR1 value 'L' ##NO_TEXT.
  constants GC_SEL_TYPE_KEYS type CHAR1 value 'K' ##NO_TEXT.
  data MV_REPROC_IS_ACTIVE type FLAG .

  methods GET_OBJECT_TYPE
    importing
      !IV_ABSOLUTE_NAME type STRING
    returning
      value(RV_OBJTYPE) type /THKR/AIF_OBJTYP
    raising
      /THKR/CX_AIF .
  methods GET_OBJEC_ID
    importing
      !IS_CURR_LINE type ANY
      !IV_ABSOLUTE_NAME type STRING
    returning
      value(RV_OBJID) type CHAR26
    raising
      /THKR/CX_AIF .
  methods GET_PROC_STAT
    importing
      !IS_CURR_LINE type ANY
      !IV_ABSOLUTE_NAME type STRING
    returning
      value(RV_OBJID) type CHAR26
    raising
      /THKR/CX_AIF .
  methods WRITE_STATUS
    importing
      !IV_COMPONENT type /THKR/AIF_OBJTYP
    changing
      !CS_CURR_LINE type ANY
    returning
      value(RV_SUCCESS) type /AIF/SUCCESSFLAG
    raising
      /THKR/CX_AIF .
  methods GET_SINGLE_INDEX_TABLE
    returning
      value(RV_INDEX_TABLE) type /AIF/MSG_TBL .
  methods GET_CANCELED_MSGS
    importing
      !IV_INDEX_TABLE type /AIF/MSG_TBL
    changing
      !CT_RETURN_TAB type BAPIRET2_T
    returning
      value(RT_CANCELED_MSGS) type /AIF/TT_MSGGUID .
  methods GET_SUCCESSFUL_MSGS
    importing
      !IV_INDEX_TABLE type /AIF/MSG_TBL
      !IT_RNG_ERR_MSGS type STANDARD TABLE
    changing
      !CT_RETURN_TAB type BAPIRET2_T
    returning
      value(RT_SUCCESS_MSGS) type /AIF/TT_MSGGUID .
  methods GET_ERROR_MSG_FROM_OBJ
    exporting
      !ET_RNG_ERR_MSG type STANDARD TABLE .
  methods GET_COMPONENT_OF_STRUCTURE
    importing
      !IV_STRUCNAME type STRUKNAME
    exporting
      !ET_COMP type ABAP_COMPDESCR_TAB
      !EV_STRUC_NAME type STRUKNAME .
  methods CHANGE_FIELD_IN_STRUCTURE
    importing
      !IV_COMPNAME type TYPENAME
      !IS_STRUCNAME type STRUKNAME
      !IT_COMP type ABAP_COMPDESCR_TAB
      !IT_SEL_LINES type TY_RNG_LINES
      !IV_SEL_KEYNAME1 type STRING
      !IT_SEL_KEYS1 type TY_RNG_KEYS
      !IV_SEL_TYPE type CHAR1
      !IV_SEL_KEYNAME2 type STRING
      !IT_SEL_KEYS2 type TY_RNG_KEYS
      !IV_SEL_KEYNAME3 type STRING
      !IT_SEL_KEYS3 type TY_RNG_KEYS
    changing
      !CV_RESEND_MESSAGE type FLAG
      !CS_DATA type ANY
      !CT_RETURN type BAPIRET2_TT .
  methods REDUCE_BY_LINES
    importing
      !IV_COMPNAME type TYPENAME
      !IT_SEL_LINES type TY_RNG_LINES
    changing
      !CV_RESEND_MESSAGE type FLAG
      !CS_DATA type ANY
      !CT_RETURN type BAPIRET2_TT .
  methods REDUCE_BY_KEYS
    importing
      !IV_COMPNAME type TYPENAME
      !IV_SEL_KEYNAME1 type STRING
      !IT_SEL_KEYS1 type TY_RNG_KEYS
      !IV_SEL_KEYNAME2 type STRING
      !IT_SEL_KEYS2 type TY_RNG_KEYS
      !IV_SEL_KEYNAME3 type STRING
      !IT_SEL_KEYS3 type TY_RNG_KEYS
    changing
      !CV_RESEND_MESSAGE type FLAG
      !CS_DATA type ANY
      !CT_RETURN type BAPIRET2_TT .
  methods CHECK_OBJECT_STATUS_FOR_MSG
    importing
      !IS_LINE type ANY
      value(IV_LINE_NUMBER) type I optional
      value(IV_KEY1) type STRING optional
      value(IV_KEY2) type STRING optional
      value(IV_KEY3) type STRING optional
    changing
      !CT_RETURN type BAPIRET2_TT
    returning
      value(RV_HAS_ERROR) type FLAG .
  methods GET_OBJKEY
    importing
      !LS_LINE type ANY
    exporting
      !EV_BU_BPEXT type BU_BPEXT
      !EV_GLBILD type /THKR/AIF_GLBLID .
  methods GET_GLBLID
    importing
      !IS_LINE type ANY
    returning
      value(RV_GLBLID) type /THKR/AIF_GLBLID .
  methods GET_BPEXT .
  methods CREATE_STRING_TABLE
    importing
      !IS_DATA type ANY
      !IV_SHOW_FIELDS type FLAG
    changing
      !CT_MESSAGE type TY_T_SHOW_MSG .
  methods GET_LINE_FOR_STRUCTURE
    importing
      !IV_COMPNAME type TYPENAME
      !IS_STRUCNAME type STRUKNAME
      !IT_COMP type ABAP_COMPDESCR_TAB
      !IS_DATA type ANY
      !IV_SHOW_FIELDS type FLAG
    changing
      !CT_MESSAGE type TY_T_SHOW_MSG .
ENDCLASS.



CLASS /THKR/CL_AIF_REPROC IMPLEMENTATION.


  method CANCEL_OLD_MESSAGE.

*    try.
    /AIF/CL_AIF_GLOBAL_TOOLS=>set_msg_state_in_idx_table(
      EXPORTING
*        im_msgstate   = '021'
        im_msgguid    = iv_msg_guid
*        iv_type       = 'M'
*        iv_limit_intf = ''
*        iv_save       = 'X'
*        iv_pid        = 'RECEIVER'
        iv_ns         = ms_aif_globales-ns
        iv_ifname     = ms_aif_globales-ifname
        iv_ifver      = ms_aif_globales-ifversion
        iv_status     = /aif/if_globals=>gc_eh_file_status-canceled
*      IMPORTING
*        ev_corr       =
    ).
*    CATCH /aif/cx_message_statistics.
*    CATCH /aif/cx_error_handling_general.
*
*    ENDTRY.
  endmethod.


  METHOD change_field_in_structure.

    DATA: lt_comp_sub TYPE abap_compdescr_tab.
    DATA: lv_sub_struc TYPE strukname.
    DATA: lo_type TYPE REF TO cl_abap_typedescr.
    DATA: lo_table TYPE REF TO cl_abap_tabledescr.

    "Strukturen Reduzieren
    CASE iv_sel_type.
      WHEN: 'L'.
        "nach Zeilen
        reduce_by_lines(
          EXPORTING
            iv_compname  = iv_compname
            it_sel_lines = it_sel_lines
          CHANGING
           cv_resend_message = cv_resend_message
            cs_data      = cs_data
            ct_return    = ct_return
        ).
      WHEN: 'K'.
        "nach Schlüsseln
        reduce_by_keys(
          EXPORTING
            iv_compname    = iv_compname
            iv_sel_keyname1 = iv_sel_keyname1
            it_sel_keys1    = it_sel_keys1
            iv_sel_keyname2 = iv_sel_keyname2
            it_sel_keys2    = it_sel_keys2
            iv_sel_keyname3 = iv_sel_keyname3
            it_sel_keys3    = it_sel_keys3
          CHANGING
            cv_resend_message = cv_resend_message
            cs_data        = cs_data
            ct_return      = ct_return
        ).
    ENDCASE.
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
                    iv_compname         = iv_compname
                    is_strucname        =  CONV strukname( lv_type+6 )                 " Name einer Struktur
                    it_comp             = lt_comp_sub
                    it_sel_lines        = it_sel_lines
                    it_sel_keys1         = it_sel_keys1
                    iv_sel_keyname1      = iv_sel_keyname1
                    it_sel_keys2         = it_sel_keys2
                    iv_sel_keyname2      = iv_sel_keyname2
                    it_sel_keys3         = it_sel_keys3
                    iv_sel_keyname3      = iv_sel_keyname3
                    iv_sel_type         = iv_sel_type
                  CHANGING
                    cv_resend_message   = cv_resend_message
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
              iv_compname         = iv_compname
              is_strucname        = CONV strukname( lv_type+6 )                  " Name einer Struktur
              it_comp             = lt_comp_sub
              it_sel_lines        = it_sel_lines
              it_sel_keys1         = it_sel_keys1
              iv_sel_keyname1      = iv_sel_keyname1
              it_sel_keys2         = it_sel_keys2
              iv_sel_keyname2      = iv_sel_keyname2
              it_sel_keys3         = it_sel_keys3
              iv_sel_keyname3      = iv_sel_keyname3
              iv_sel_type         = iv_sel_type
            CHANGING
              cv_resend_message   = cv_resend_message
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


  METHOD check_aif_message_status.
    DATA: lv_status TYPE /aif/proc_status.
    DATA(lv_idx_tab) = get_single_index_table( ).
    SELECT single status
    FROM (lv_idx_tab)
    WHERE ns = @ms_aif_globales-ns
      AND ifname = @ms_aif_globales-ifname
      AND ifver = @ms_aif_globales-ifversion
      AND msgguid = @ms_aif_globales-ximsgguid
      INTO @lv_status.
      IF sy-subrc <> 0.
        "Kein Datensatz gefunden.
        "Verarbeitung nicht vorsetzen.
        rv_msg_has_errors = abap_false.
        IF 1 = 0. MESSAGE i100(/thkr/sst) WITH ms_aif_globales-ximsgguid.ENDIF.
        APPEND VALUE bapiret2( id = '/THKR/SST'
                               type = 'I'
                               number = 100
                               message_v1 = ms_aif_globales-ximsgguid ) TO et_return.
      ELSE.
        IF lv_status = 'E' OR lv_status = 'A'.
          "Nachrichten nur neustarten, wenn es Fehler gab.
          rv_msg_has_errors = abap_true.
        elseif iv_msg_in_process = abap_true and lv_status = 'I'.
          "Nachricht im Status "in Bearbeitung". -> System Dump
          rv_msg_has_errors = abap_true.
        ELSE.
          "nachricht nicht fehlerhaft. Kann nicht neugestartet werden.
          rv_msg_has_errors = abap_false.
          IF 1 = 0. MESSAGE i101(/thkr/sst) WITH ms_aif_globales-ximsgguid.ENDIF.
          APPEND VALUE bapiret2( id = '/THKR/SST'
                                 type = 'I'
                                 number = 101
                                 message_v1 = ms_aif_globales-ximsgguid ) TO et_return.
        ENDIF.
      ENDIF.
    ENDMETHOD.


  METHOD check_object_status_for_msg.
    IF check_reproc_is_active( ) = abap_true.
      get_objkey(
        EXPORTING
          ls_line     = is_line
       IMPORTING
*        ev_bu_bpext =                  " Geschäftspartnernummer im externen System
          ev_glbild   = DATA(lv_gblid)                 " Globale Beleg ID (Konkatenation aus dstnr,hhj,quelle,qbelnr)
      ).

      SELECT msg_id, object, objpos_id, status
        FROM /thkr/t_aif_obj
        WHERE msg_id = @ms_aif_globales-ximsgguid
        AND ns = @ms_aif_globales-ns
        AND ifname = @ms_aif_globales-ifname
        AND ifver = @ms_aif_globales-ifversion
        INTO TABLE @DATA(lt_status).
      IF sy-subrc = 0.
        READ TABLE lt_status ASSIGNING FIELD-SYMBOL(<ls_status>) WITH KEY objpos_id = lv_gblid.
        IF sy-subrc = 0.
          "Geschäftspartner konnte angelegt werden, da hier mit dem Schlüssel der Datenzeile gearbeitet wird
          IF <ls_status>-status = 'E' OR <ls_status>-status = 'A'.
            rv_has_error = abap_true.
          ELSE.
            IF iv_line_number IS SUPPLIED.
              IF 1 = 0. MESSAGE i103(/thkr/sst) WITH lv_gblid.ENDIF.
              APPEND VALUE bapiret2( id = '/THKR/SST'
                                     number = 103
                                     type = 'I'
                                     message_v1 = iv_line_number ) TO ct_return.
            ENDIF.
            IF iv_key1 IS SUPPLIED.
              IF 1 = 0. MESSAGE i104(/thkr/sst) WITH lv_gblid.ENDIF.
              APPEND VALUE bapiret2( id = '/THKR/SST'
                                     number = 104
                                     type = 'I'
                                     message_v1 = |{ iv_key1 } { iv_key2 } { iv_key3 }| ) TO ct_return.
            ENDIF.
            rv_has_error = abap_false.
          ENDIF.
        ELSE.
          "Es konnte keine Anordnung oder Mittelbindung angelegt werden. Es trat ein Fehler beim Geschäftspartner auf.
          rv_has_error = abap_true.
        ENDIF.
      ELSE.
        "Es wurde gar keine Nachricht in der Objekttabelle gespeichert.
        "Fehlerbewertung nicht möglich.
        "Keine erneute Verarbeitung
        rv_has_error = abap_false.
        IF 1 = 0. MESSAGE e100(/thkr/sst) WITH ms_aif_globales-ximsgguid. ENDIF.
        APPEND VALUE bapiret2( id = '/THKR/SST'
                             type = 'E'
                             number = 100
                             message_v1 = ms_aif_globales-ximsgguid ) TO ct_return.
      ENDIF.
    ELSE.
      "kundenindividuelle SAP Objektstatusmitzeichnung nicht aktiv (/AIF/VMAP -> MAP_RUN_CONFIG -> Parameter REPROC <> X)
      "Daher keine Aussage zum Status möglich
      "Das System Log wird regelmäßig gelöscht. Bietet also keine stabile Entscheidungsfindung für den Neustart von Nachrichten.
      rv_has_error = abap_false.
      IF 1 = 0. MESSAGE e102(/thkr/sst) WITH ms_aif_globales-ns ms_aif_globales-ifname. ENDIF.
      APPEND VALUE bapiret2( id = '/THKR/SST'
                             type = 'E'
                             number = 102
                             message_v1 = ms_aif_globales-ns
                             message_v2 = ms_aif_globales-ifname ) TO ct_return.
    ENDIF.

  ENDMETHOD.


  METHOD check_reproc_is_active.
    CONSTANTS: lc_vmap_run_conf TYPE /AIF/vmapname VALUE 'MAP_RUN_CONFIG'.
    CONSTANTS: lc_vmap_ns_zallge TYPE /AIF/ns VALUE 'ZALLGE'.
    CONSTANTS: lc_reproc TYPE /aif/vmap_extval VALUE 'REPROC'.
    CONSTANTS: lc_asterisk TYPE char1 VALUE '*'.

    "Lese Konfigurationsparameter aus Tabelle
    IF mv_reproc_is_active IS INITIAL.
      SELECT *
        FROM /aif/t_mvmapval5
       WHERE ns = @lc_vmap_ns_zallge
         AND vmapname = @lc_vmap_run_conf
         AND ext_value3 = @lc_reproc
      INTO TABLE @DATA(lt_reproc).
      IF sy-subrc = 0.
        "Prüfe ob eine Schnittstellenspezifische Konfiguration vorliegt
        READ TABLE lt_reproc WITH KEY ext_value1 = ms_aif_globales-ns
                                      ext_value2 = ms_aif_globales-ifname
                             ASSIGNING FIELD-SYMBOL(<ls_reproc>).
        IF sy-subrc = 0.
          "Schnittstellenspezifische Konfiguration
          "Nimm Wert aus Tabelle
          rv_reproc_is_active = mv_reproc_is_active = <ls_reproc>-int_value.
        ELSE.
          "Keine Schnittstellenspezifische Konfiguration
          "Prüfe ob allgemeine Konfiguration vorliegt.
          READ TABLE lt_reproc WITH KEY ext_value1 = lc_asterisk
                                        ext_value2 = lc_asterisk
                               ASSIGNING <ls_reproc>.
          IF sy-subrc = 0.
            "Allgemeine Konfiguration liegt vor
            "Nimn Wert aus Tabelle
            rv_reproc_is_active = mv_reproc_is_active = <ls_reproc>-int_value.
          ELSE.
            "Es liegt weder eine Schnittstellenspezifische noch eine
            "allgeimeine Konfiguration vor
            "Wiederanlaufverfahren ist inaktiv
            rv_reproc_is_active = mv_reproc_is_active = abap_false.
          ENDIF.
        ENDIF.
      ELSE.
        "Es gibt keinen Konfigurationsparameter für Wiederanlaufverfahren
        "also inaktiv
        rv_reproc_is_active = mv_reproc_is_active = abap_false.
      ENDIF.
    ELSE.
      rv_reproc_is_active = mv_reproc_is_active.
    ENDIF.
  ENDMETHOD.


  method CONSTRUCTOR.
     CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
      IMPORTING
        XIMSGGUID            = ms_aif_globales-ximsgguid
        MSGDATE              = ms_aif_globales-msgdate
        MSGTIME              = ms_aif_globales-msgtime
        VARIANT              = ms_aif_globales-variant
        TRACE_LEVEL          = ms_aif_globales-trace_level
        SENDING_SYSTEM       = ms_aif_globales-sending_system
        LOG_HANDLE           = ms_aif_globales-log_handle
        TESTRUN              = ms_aif_globales-testrun
        NS                   = ms_aif_globales-ns
        IFNAME               = ms_aif_globales-ifname
        IFVERSION            = ms_aif_globales-ifversion
        FINF                 = ms_aif_globales-finf
        PROCESS_ID           = ms_aif_globales-process_id
               .

  endmethod.


  METHOD create_string_table.
    DATA: lo_struc TYPE REF TO cl_abap_structdescr.
    DATA: ls_strucname TYPE strukname.
    DATA: lt_comp_root TYPE abap_compdescr_tab.

    lo_struc ?= cl_abap_structdescr=>describe_by_data( p_data = is_data ).

    get_component_of_structure(
      EXPORTING
        iv_strucname       = CONV strukname( lo_struc->absolute_name )
      IMPORTING
        et_comp       = lt_comp_root
        ev_struc_name = ls_strucname
    ).

    get_line_for_structure(
      EXPORTING
        iv_compname  = CONV strukname( lo_struc->absolute_name )                " Name des Dictionary Typs
        is_strucname = ls_strucname                  " Name einer Struktur
        it_comp      = lt_comp_root
        is_data      = is_data
        iv_show_fields = iv_show_fields
      CHANGING
        ct_message   = ct_message                 " Tabelle von Strings
    ).

  ENDMETHOD.


  METHOD DELETET_SUCCESSFUL_AIF_MSGS.
    "Löschung von fehlerhaften Nachrichen aus der Statsutabelle /THKR/T_AIF_OBJ
    "Bei denen der Verarbeitungsstatus im AIF auf erfolgreich gesetzt ist.
    "Erfolgreiche Nachrichten lassen sich nicht neu starten.
    "Daher kann der Status aus der Tabelle /THKR/T_AIF_OBJ gelöscht werden.
    DATA: lt_error_msgs TYPE RANGE OF /aif/sxmssmguid.
    DATA: lt_successful_msgs TYPE ty_t_msgguid.

    "Single Index Tabelle ermitteln.
    DATA(lv_index_table) = get_single_index_table( ).

    get_error_msg_from_obj(
      IMPORTING
        et_rng_err_msg = lt_error_msgs
    ).
    "Prüfen, ob die fehlerhaften Nachrichten
    "im AIF-Nachrichten bereits erfolgreich verarbeitet wurden
    "kann passieren durch Neustarten der Nachricht im AIF-Monitor.
    lt_successful_msgs = get_successful_msgs(
                         EXPORTING
                           iv_index_table = lv_index_table                " Name Nachrichtenindextabelle
                           it_rng_err_msgs = lt_error_msgs
                         CHANGING
                           ct_return_tab  = ct_return_tab                 " Returntabelle
                       ).
    IF lt_successful_msgs IS NOT INITIAL.
      "Abgebrochene Nachrichten aus Statustabelle löschen
      LOOP AT lt_successful_msgs ASSIGNING FIELD-SYMBOL(<ls_successful_msgs>).
        DELETE FROM /thkr/t_aif_obj
              WHERE msg_id = @<ls_successful_msgs>-msgguid
                AND ns = @ms_aif_globales-ns
                AND ifname = @ms_aif_globales-ifname
                AND ifver = @ms_aif_globales-ifversion.
        IF sy-subrc = 0.
          data(lv_if_info) = |NS: { ms_aif_globales-ns } IFNAME: { ms_aif_globales-ifname } IFVER: { ms_aif_globales-ifversion }|.
          IF 1 = 0.MESSAGE i053(/thkr/sst) WITH <ls_successful_msgs>-msgguid lv_if_info '/THKR/T_AIF_OBJ'.ENDIF.
          APPEND VALUE bapiret2(  id         = '/THKR/SST'
                      number     = 053
                      type       = 'I'
                      message_v1 = <ls_successful_msgs>-msgguid
                      message_v2 = lv_if_info
                      message_v3 = '/THKR/T_AIF_OBJ'
                      ) TO ct_return_tab.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD delete_successfull_msgs.
    DATA: lv_del_flag TYPE flag VALUE abap_true.

    SELECT msg_id, status
      FROM /thkr/t_aif_obj
     WHERE msg_id = @ms_aif_globales-ximsgguid
     INTO TABLE @DATA(lt_msgs).
    IF sy-subrc = 0.
      READ TABLE lt_msgs WITH KEY status = 'E' TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        lv_del_flag = abap_false.
      ENDIF.
      READ TABLE lt_msgs WITH KEY status = 'A' TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        lv_del_flag = abap_false.
      ENDIF.

      IF lv_del_flag = abap_true.
        DELETE FROM /thkr/t_aif_obj
         WHERE msg_id = @ms_aif_globales-ximsgguid.
        IF sy-subrc = 0.
          rv_success = 'Y'.
          IF 1 = 0. MESSAGE i003(/thkr/sst) WITH '/THKR/T_AIF_OBJ'. ENDIF.
          APPEND VALUE #( id         = '/THKR/SST'
                           number     = 003
                           type       = 'I'
                           message_v1 = '/THKR/T_AIF_OBJ' ) TO ct_return_tab.
        ELSE.
          rv_success = 'N'.
          IF 1 = 0. MESSAGE e710(ka) WITH '/THKR/T_AIF_OBJ'. ENDIF.
          APPEND VALUE #( id         = 'KA'
                           number     = 710
                           type       = 'E'
                           message_v1 = '/THKR/T_AIF_OBJ' ) TO ct_return_tab.
        ENDIF.
      ELSE.
        rv_success = 'Y'.
        IF 1 = 0. MESSAGE i004(/thkr/sst) WITH '/THKR/T_AIF_OBJ'. ENDIF.
        APPEND VALUE #( id         = '/THKR/SST'
                         number     = 004
                         type       = 'I'
                         message_v1 = '/THKR/T_AIF_OBJ' ) TO ct_return_tab.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD deltet_canceled_msgs.

    DATA: lt_canceled_msgs TYPE ty_t_msgguid.

    "Single Index Tabelle ermitteln.
    DATA(lv_index_table) = get_single_index_table( ).

    "Prüfen, ob es abgebrochene Nachrichten gibt.
    lt_canceled_msgs = get_canceled_msgs(
                         EXPORTING
                           iv_index_table = lv_index_table                " Name Nachrichtenindextabelle
                         CHANGING
                           ct_return_tab  = ct_return_tab                 " Returntabelle
                       ).
    IF lt_canceled_msgs IS not INITIAL.
      "Abgebrochene Nachrichten aus Statustabelle löschen
      LOOP AT lt_canceled_msgs ASSIGNING FIELD-SYMBOL(<ls_canceled_msgs>).
        DELETE FROM /thkr/t_aif_obj
              WHERE msg_id = @<ls_canceled_msgs>-msgguid
                AND ns = @ms_aif_globales-ns
                AND ifname = @ms_aif_globales-ifname
                AND ifver = @ms_aif_globales-ifversion.
        IF sy-subrc = 0.
          data(lv_if_info) = |NS: { ms_aif_globales-ns } IFNAME: { ms_aif_globales-ifname } IFVER: { ms_aif_globales-ifversion }|.
          IF 1 = 0.MESSAGE i006(/thkr/sst) WITH <ls_canceled_msgs>-msgguid lv_if_info '/THKR/T_AIF_OBJ'.ENDIF.
          APPEND VALUE bapiret2(  id         = '/THKR/SST'
                      number     = 006
                      type       = 'I'
                      message_v1 = <ls_canceled_msgs>-msgguid
                      message_v2 = lv_if_info
                      message_v3 = '/THKR/T_AIF_OBJ'
                      ) TO ct_return_tab.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD get_aif_message.
DATA: lr_aif_engine TYPE REF TO /AIF/IF_APPLICATION_ENGINE.

    lr_aif_engine = /aif/cl_aif_engine_factory=>get_engine(
          iv_ns            = ms_aif_globales-ns
          iv_ifname        = ms_aif_globales-ifname
          iv_ifversion     = ms_aif_globales-ifversion
             ).

* Nachrichten zur GUID lesen
    CALL METHOD lr_aif_engine->read_msg_from_persistency
      EXPORTING
        iv_msgguid  = ms_aif_globales-ximsgguid
        iv_ns       = ms_aif_globales-ns
        iv_ifname   = ms_aif_globales-ifname
        iv_ifver    = ms_aif_globales-ifversion
      CHANGING
        cs_xmlparse = rs_xmlparse.
  ENDMETHOD.


  method GET_BPEXT.
  endmethod.


  METHOD get_canceled_msgs.
    SELECT msgguid
  FROM (iv_index_table)
  WHERE ns = @ms_aif_globales-ns
    AND ifname = @ms_aif_globales-ifname
    AND ifver = @ms_aif_globales-ifversion
    AND status = 'C'
  INTO TABLE @rt_canceled_msgs.
    IF sy-subrc <> 0.
      IF 1 = 0.MESSAGE i005(/thkr/sst) WITH ms_aif_globales-ns ms_aif_globales-ifname ms_aif_globales-ifversion.ENDIF.
      APPEND VALUE bapiret2(  id         = '/THKR/SST'
                              number     = 005
                              type       = 'I'
                              message_v1 = ms_aif_globales-ns
                              message_v2 = ms_aif_globales-ifname
                              message_v3 = ms_aif_globales-ifversion
                              ) TO ct_return_tab.
    ENDIF.
  ENDMETHOD.


  method GET_COMPONENT_OF_STRUCTURE.
    DATA: lo_struc TYPE REF TO cl_abap_structdescr.

    lo_struc ?= cl_abap_structdescr=>describe_by_name( p_name = iv_strucname ).
    ev_struc_name = lo_struc->get_relative_name( ).
    et_comp = lo_struc->components.
  endmethod.


  METHOD get_error_msg_from_obj.
    DATA: lt_rng_err TYPE RANGE OF /aif/sxmssmguid.

    SELECT msg_id
      FROM /thkr/t_aif_obj
      WHERE ns = @ms_aif_globales-ns
        AND ifname = @ms_aif_globales-ifname
        AND ifver = @ms_aif_globales-ifversion
        AND status = 'E' OR status = 'A'
      GROUP BY msg_id
     INTO TABLE @DATA(lt_msgs).
    IF sy-subrc = 0.
      LOOP AT lt_msgs ASSIGNING FIELD-SYMBOL(<ls_msgs>).
        APPEND INITIAL LINE TO lt_rng_err ASSIGNING FIELD-SYMBOL(<ls_rng>).
        <ls_rng>-sign = 'I'.
        <ls_rng>-option = 'EQ'.
        <ls_rng>-low = <ls_msgs>-msg_id.
      ENDLOOP.
    ENDIF.
    et_rng_err_msg = lt_rng_err.
  ENDMETHOD.


  METHOD get_failed_msgs_for_interface.
    IF iv_msg_guid IS NOT INITIAL.
      APPEND iv_msg_guid TO rt_msgs.
    ELSE.
      DATA(lv_index_table) = get_single_index_table( ).
      IF iv_msg_in_process = abap_true.
        "Es sollen auch stehen gebliebene Nachrichten neu gestartet werden.
        SELECT msgguid
        FROM (lv_index_table)
        WHERE ( ns = @ms_aif_globales-ns
        AND ifname = @ms_aif_globales-ifname
        AND ifver = @ms_aif_globales-ifversion )
        AND ( status = 'E' OR status = 'A' OR status = 'I' )
        INTO TABLE @rt_msgs.
      ELSE.
        "Nur fehlerhafte Nachrichten.
        SELECT msgguid
      FROM (lv_index_table)
      WHERE ( ns = @ms_aif_globales-ns
        AND ifname = @ms_aif_globales-ifname
        AND ifver = @ms_aif_globales-ifversion )
        AND ( status = 'E' OR status = 'A' )
      INTO TABLE @rt_msgs.
      ENDIF.
      IF sy-subrc <> 0.
        IF 1 = 0.MESSAGE i109(/thkr/sst) WITH ms_aif_globales-ns ms_aif_globales-ifname ms_aif_globales-ifversion.ENDIF.
        APPEND VALUE bapiret2(  id         = '/THKR/SST'
                                number     = 109
                                type       = 'I'
                                message_v1 = ms_aif_globales-ns
                                message_v2 = ms_aif_globales-ifname
                                message_v3 = ms_aif_globales-ifversion
                                ) TO ct_return_tab.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_glblid.
    DATA: lv_field1 TYPE /AIF/LFIELDNAME.
    DATA: lv_field2 TYPE /AIF/LFIELDNAME.
    DATA: lv_field3 TYPE /AIF/LFIELDNAME.
    DATA: lv_field4 TYPE /AIF/LFIELDNAME.
    DATA: lv_field5 TYPE /AIF/LFIELDNAME.
    "Auslesen der Globalen ID
    SELECT SINGLE *
      FROM /aif/t_fmap
     WHERE ns = @ms_aif_globales-ns
       AND ifname = @ms_aif_globales-ifname
       AND ifversion = @ms_aif_globales-ifversion
       AND fieldname = 'GLBLID'
      INTO @DATA(ls_fmap).

    ASSIGN COMPONENT ls_fmap-sap_fieldname1 OF STRUCTURE is_line TO FIELD-SYMBOL(<lv_field1>).
    IF <lv_field1> IS ASSIGNED.
     lv_field1 = <lv_field1>.
    ENDIF.
    ASSIGN COMPONENT ls_fmap-sap_fieldname2 OF STRUCTURE is_line TO FIELD-SYMBOL(<lv_field2>).
    IF <lv_field2> IS ASSIGNED.
      lv_field2 = <lv_field2>.
    ENDIF.
    ASSIGN COMPONENT ls_fmap-sap_fieldname3 OF STRUCTURE is_line TO FIELD-SYMBOL(<lv_field3>).
    IF <lv_field3> IS ASSIGNED.
      lv_field3 = <lv_field3>.
    ENDIF.
    ASSIGN COMPONENT ls_fmap-sap_fieldname4 OF STRUCTURE is_line TO FIELD-SYMBOL(<lv_field4>).
    IF <lv_field4> IS ASSIGNED.
      lv_field4 = <lv_field4>.
    ENDIF.
    ASSIGN COMPONENT ls_fmap-sap_fieldname5 OF STRUCTURE is_line TO FIELD-SYMBOL(<lv_field5>).
    IF <lv_field5> IS ASSIGNED.
      lv_field5 = <lv_field5>.
    ENDIF.
    IF ls_fmap-valmapfunction IS NOT INITIAL.
      "Funktionsbaustein fürs Mapping
      CALL FUNCTION ls_fmap-valmapfunction
        EXPORTING
          value_in  = lv_field1
          value_in2 = lv_field2
          value_in3 = lv_field3
          value_in4 = lv_field4
          value_in5 = lv_field5
*         SENDING_SYSTEM       =
*         VALUE_FOUND          =
*         TABLES
*         RETURN_TAB           =
        CHANGING
          value_out = rv_glblid
*         EXCEPTIONS
*         NO_VALUE_FOUND       = 1
*         OTHERS    = 2
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
    ELSE.
      "Zeichenverkettung
      if ls_fmap-separatorstring is INITIAL.
      rv_glblid = |{ lv_field1 }{ lv_field2 }{ lv_field3 }{ lv_field4 }{ lv_field5 }|.
      else.
      rv_glblid = |{ lv_field1 }{ ls_fmap-separatorstring }{ lv_field2 }{ ls_fmap-separatorstring }{ lv_field3 }{ ls_fmap-separatorstring }{ lv_field4 }{ ls_fmap-separatorstring }{ lv_field5 }|.
      endif.
    ENDIF.


  ENDMETHOD.


  METHOD get_line_for_structure.
    CONSTANTS lc_pipe TYPE char1 VALUE '|'.
    DATA: lt_comp_sub TYPE abap_compdescr_tab.
    DATA: lv_sub_struc TYPE strukname.
    DATA: lo_type TYPE REF TO cl_abap_typedescr.
    DATA: lo_table TYPE REF TO cl_abap_tabledescr.
    DATA: lv_line_fieldname TYPE string.
    DATA: lv_line_fieldvalue TYPE string.

    CLEAR: lv_line_fieldname, lv_line_fieldvalue.
    "In der Struktur gibt es das Feld nicht. Also in den Unterkomponenten suchen.
    IF iv_show_fields = abap_true.
      APPEND INITIAL LINE TO ct_message ASSIGNING FIELD-SYMBOL(<lv_line_fieldname>).
      <lv_line_fieldname>-comp_name = iv_compname.
    ENDIF.
    APPEND INITIAL LINE TO ct_message ASSIGNING FIELD-SYMBOL(<lv_line_fieldvalue>).
    <lv_line_fieldvalue>-comp_name = iv_compname.
    LOOP AT it_comp ASSIGNING FIELD-SYMBOL(<ls_comp>).

      CASE: <ls_comp>-type_kind.
        WHEN: 'h'. "Tabelle
          "Abarbeiten von Tabellen
          ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE is_data TO FIELD-SYMBOL(<lt_sub_tab>).
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

              get_line_for_structure(
                EXPORTING
                  iv_compname  = <ls_comp>-name                " Name des Dictionary Typs
                  is_strucname = CONV strukname( lv_type+6 )                 " Name einer Struktur
                  it_comp      = lt_comp_sub
                  is_data      = <ls_sub_struc>
                  iv_show_fields = iv_show_fields
                CHANGING
                  ct_message   = ct_message                 " Tabelle von Strings
              ).
            ENDLOOP.
          ENDIF.
        WHEN: 'v' OR 'u'. "Struktur

          "Prüfung, ob es eine Unterstruktur gibt.
          CLEAR: lt_comp_sub.
          "Durch die einzelnen Komponenten der Struktur gehen.
          ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE is_data TO <ls_sub_struc>.
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
          get_line_for_structure(
            EXPORTING
              iv_compname  = <ls_comp>-name                 " Name des Dictionary Typs
              is_strucname = CONV strukname( lv_type+6 )                 " Name einer Struktur
              it_comp      = lt_comp_sub
              is_data      = <ls_sub_struc>
              iv_show_fields = iv_show_fields
            CHANGING
              ct_message   = ct_message                 " Tabelle von Strings
          ).
        WHEN: OTHERS. "Felder
          "Felder haben unterschiedliche Typen
          "C = CHAR
          "p = gepackte Zahl
          "g = string
          "i = Zahl
          "Felder und Feldinhalte wegschreiben.
          IF <lv_line_fieldvalue> IS ASSIGNED.
            ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE is_data TO FIELD-SYMBOL(<lv_fieldvalue>).
            IF iv_show_fields = abap_true.
              IF <lv_line_fieldname> IS ASSIGNED.
                <lv_line_fieldname>-content = |{ <lv_line_fieldname>-content }{ lc_pipe }{ <ls_comp>-name }|.
              ENDIF.
            ENDIF.
            <lv_line_fieldvalue>-content = |{ <lv_line_fieldvalue>-content }{ lc_pipe }{ <lv_fieldvalue> }|.
          ENDIF.
      ENDCASE.
    ENDLOOP.
    "Es wird die Tabelle mit jedem Schleifendurchlauf gefüllt.
    "Lösche alle EInträge, die nur den Komponentenname beinhalten.
    DELETE ct_message WHERE content IS INITIAL.
  ENDMETHOD.


  method GET_OBJECT_TYPE.

  CONSTANTS: lc_vmap_name TYPE /AIF/vmapname VALUE 'MAP_REPROC_STRUC_2_O'.
  CONSTANTS: lc_vmap_ns_zallge TYPE /AIF/ns VALUE 'ZALLGE'.
  CONSTANTS: lc_reproc TYPE /aif/vmap_extval VALUE 'REPROC'.

  SELECT single INT_VALUE
    FROM /AIF/T_VMAPVAL
   WHERE ns = @lc_vmap_ns_zallge
     AND vmapname = @lc_vmap_name
     AND ext_value = @iv_absolute_name
    into @rv_objtype.

    if sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_aif MESSAGE e007(/THKR/SST) with iv_absolute_name lc_vmap_name.
    endif.
  endmethod.


  METHOD get_objec_id.
    CONSTANTS: lc_vmap_name TYPE /AIF/vmapname VALUE 'MAP_REPROC_STRUC_2_F'.
    CONSTANTS: lc_vmap_ns_zallge TYPE /AIF/ns VALUE 'ZALLGE'.
    CONSTANTS: lc_reproc TYPE /aif/vmap_extval VALUE 'REPROC'.

    SELECT SINGLE int_value
      FROM /aif/t_vmapval
     WHERE ns = @lc_vmap_ns_zallge
       AND vmapname = @lc_vmap_name
       AND ext_value = @iv_absolute_name
      INTO @DATA(lv_component).

    IF sy-subrc = 0.
      ASSIGN COMPONENT lv_component OF STRUCTURE is_curr_line TO FIELD-SYMBOL(<lv_objid>).
      IF <lv_objid> IS ASSIGNED.
        rv_objid = <lv_objid>.
      ELSE.
        RAISE EXCEPTION TYPE /thkr/cx_aif MESSAGE e008(/thkr/sst) with lv_component iv_absolute_name.
      ENDIF.
    ELSE.
      RAISE EXCEPTION TYPE /thkr/cx_aif MESSAGE e009(/thkr/sst) with iv_absolute_name lc_vmap_name.
    ENDIF.


  ENDMETHOD.


  method GET_OBJKEY.

    ev_glbild = get_glblid( is_line = ls_line ).
  endmethod.


  METHOD get_proc_stat.
    CONSTANTS: lc_vmap_name TYPE /AIF/vmapname VALUE 'MAP_REPROC_STRUC_2_S'.
    CONSTANTS: lc_vmap_ns_zallge TYPE /AIF/ns VALUE 'ZALLGE'.

    SELECT SINGLE int_value
      FROM /aif/t_vmapval
     WHERE ns = @lc_vmap_ns_zallge
       AND vmapname = @lc_vmap_name
       AND ext_value = @iv_absolute_name
      INTO @DATA(lv_component).
    IF sy-subrc = 0.
      ASSIGN COMPONENT lv_component OF STRUCTURE is_curr_line TO FIELD-SYMBOL(<lv_status>).

      IF <lv_status> IS ASSIGNED.
        rv_objid = <lv_status>.
      ELSE.
        RAISE EXCEPTION TYPE /thkr/cx_aif MESSAGE e008(/thkr/sst) with lv_component iv_absolute_name.
      ENDIF.
    ELSE.
     RAISE EXCEPTION TYPE /thkr/cx_aif MESSAGE e018(/thkr/sst) with iv_absolute_name lc_vmap_name.
    ENDIF.
  ENDMETHOD.


  method GET_SINGLE_INDEX_TABLE.
    SELECT SINGLE MSG_TBL
      FROM /AIF/T_INF_TBL
      WHERE ns = @ms_aif_globales-ns
        AND ifname = @ms_aif_globales-ifname
        AND ifver = @ms_aif_globales-ifversion
      INTO @rv_index_table.
      if sy-subrc = 0.
        "Einrag gefunden, allerdings keine Single-Index-Tabelle hinterlegt.
        "Verwendung der Standard-Index-Tabelle
        if rv_index_table is INITIAL.
          rv_index_table = '/AIF/STD_IDX_TBL'.
        endif.
      else.
        "keinen Eintrag gefunden
        "Verwendung der Standard-Index Tabelle
        rv_index_table = '/AIF/STD_IDX_TBL'.
      endif.

  endmethod.


  METHOD GET_SUCCESSFUL_MSGS.
    SELECT msgguid
  FROM (iv_index_table)
  WHERE msgguid in @it_rng_err_msgs
    and ns = @ms_aif_globales-ns
    AND ifname = @ms_aif_globales-ifname
    AND ifver = @ms_aif_globales-ifversion
    AND status = 'S'
  INTO TABLE @rt_success_msgs.
    IF sy-subrc <> 0.
      IF 1 = 0.MESSAGE i052(/thkr/sst) WITH ms_aif_globales-ns ms_aif_globales-ifname ms_aif_globales-ifversion.ENDIF.
      APPEND VALUE bapiret2(  id         = '/THKR/SST'
                              number     = 052
                              type       = 'I'
                              message_v1 = ms_aif_globales-ns
                              message_v2 = ms_aif_globales-ifname
                              message_v3 = ms_aif_globales-ifversion
                              ) TO ct_return_tab.
    ENDIF.
  ENDMETHOD.


  method GET_TYPE_OF_PROCESSING.

  CONSTANTS: lc_vmap_name TYPE /AIF/vmapname VALUE 'MAP_REPROC_STRUC_2_T'.
  CONSTANTS: lc_vmap_ns_zallge TYPE /AIF/ns VALUE 'ZALLGE'.

  SELECT single INT_VALUE
    FROM /AIF/T_VMAPVAL
   WHERE ns = @lc_vmap_ns_zallge
     AND vmapname = @lc_vmap_name
     AND ext_value = @iv_absolute_name
    into @rv_type_of_processing.

    if sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_aif MESSAGE e010(/THKR/SST) with iv_absolute_name lc_vmap_name.
    endif.
  endmethod.


  METHOD map_proc_stat.

    SELECT SINGLE status FROM /thkr/t_aif_obj
    WHERE msg_id = @ms_aif_globales-ximsgguid
    AND ns = @ms_aif_globales-ns
    AND ifname = @ms_aif_globales-ifname
    AND ifver = @ms_aif_globales-ifversion
    AND object = @iv_objtyp
    AND objpos_id = @iv_objid
      INTO @rv_proc_stat.

    IF sy-subrc <> 0.
      CLEAR rv_proc_stat.

    ENDIF.
  ENDMETHOD.


  METHOD reduce_by_keys.
    DATA: lr_trg_tab TYPE REF TO data.
    DATA: lv_case_Key TYPE i VALUE 0.
    FIELD-SYMBOLS: <lt_trg_tab> TYPE STANDARD TABLE.

    IF iv_sel_keyname1 IS NOT INITIAL.
      lv_case_key += 1.
    ENDIF.
    IF iv_sel_keyname2 IS NOT INITIAL.
      lv_case_key += 1.
    ENDIF.
    IF iv_sel_keyname3 IS NOT INITIAL.
      lv_case_key += 1.
    ENDIF.

    ASSIGN COMPONENT iv_compname OF STRUCTURE cs_data TO FIELD-SYMBOL(<lt_tab>).
    IF <lt_tab> IS ASSIGNED.
      CREATE DATA lr_trg_tab LIKE <lt_tab>.
      ASSIGN lr_trg_tab->* TO <lt_trg_tab>.
      LOOP AT <lt_tab> ASSIGNING FIELD-SYMBOL(<ls_line>).
        CASE lv_case_key.
          WHEN: 0.
            "Keine Schlüssel spezifiziert
            IF check_object_status_for_msg(
                 EXPORTING
                   is_line = <ls_line>
                 CHANGING
                   ct_return = ct_return
               ) = abap_true.
              APPEND INITIAL LINE TO <lt_trg_tab> ASSIGNING FIELD-SYMBOL(<ls_new_line>).
              <ls_new_line> = <ls_line>.
            ENDIF.
          WHEN: 1.
            ASSIGN COMPONENT iv_sel_keyname1 OF STRUCTURE <ls_line> TO FIELD-SYMBOL(<lv_key1>).
            IF <lv_key1> IS ASSIGNED AND <lv_key1> IN it_sel_keys1.
              IF check_object_status_for_msg(
                     EXPORTING
                       is_line = <ls_line>
                       iv_key1 = CONV string( <lv_key1> )
                     CHANGING
                       ct_return = ct_return
                   ) = abap_true.
                APPEND INITIAL LINE TO <lt_trg_tab> ASSIGNING <ls_new_line>.
                <ls_new_line> = <ls_line>.
              ENDIF.
            ENDIF.
          WHEN: 2.
            ASSIGN COMPONENT iv_sel_keyname1 OF STRUCTURE <ls_line> TO <lv_key1>.
            ASSIGN COMPONENT iv_sel_keyname2 OF STRUCTURE <ls_line> TO FIELD-SYMBOL(<lv_key2>).
            IF <lv_key1> IS ASSIGNED AND <lv_key1> IN it_sel_keys1
            AND <lv_key2> IS ASSIGNED AND <lv_key2> IN it_sel_keys2.
              IF check_object_status_for_msg(
                     EXPORTING
                       is_line = <ls_line>
                       iv_key1 = CONV string( <lv_key1> )
                       iv_key2 = CONV string( <lv_key2> )
                     CHANGING
                       ct_return = ct_return
                   ) = abap_true.
                APPEND INITIAL LINE TO <lt_trg_tab> ASSIGNING <ls_new_line>.
                <ls_new_line> = <ls_line>.
              ENDIF.
            ENDIF.
          WHEN: 3.
            ASSIGN COMPONENT iv_sel_keyname1 OF STRUCTURE <ls_line> TO <lv_key1>.
            ASSIGN COMPONENT iv_sel_keyname2 OF STRUCTURE <ls_line> TO <lv_key2>.
            ASSIGN COMPONENT iv_sel_keyname3 OF STRUCTURE <ls_line> TO FIELD-SYMBOL(<lv_key3>).
            IF <lv_key1> IS ASSIGNED AND <lv_key1> IN it_sel_keys1
            AND <lv_key2> IS ASSIGNED AND <lv_key2> IN it_sel_keys2
            AND <lv_key3> IS ASSIGNED AND <lv_key3> IN it_sel_keys3.
              IF check_object_status_for_msg(
                     EXPORTING
                       is_line = <ls_line>
                       iv_key1 = CONV string( <lv_key1> )
                       iv_key2 = CONV string( <lv_key2> )
                       iv_key3 = CONV string( <lv_key3> )
                     CHANGING
                       ct_return = ct_return
                   ) = abap_true.
                APPEND INITIAL LINE TO <lt_trg_tab> ASSIGNING <ls_new_line>.
                <ls_new_line> = <ls_line>.
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDLOOP.
      CLEAR: <lt_tab>.
      <lt_tab> = <lt_trg_tab>.
      IF <lt_tab> IS INITIAL.
        IF 1 = 0. MESSAGE i105(/thkr/sst).ENDIF.
        APPEND VALUE bapiret2( id = '/THKR/SST'
                               number = 105
                               type = 'I' ) TO ct_return.

        "Es wurde bereits eine relevante Zeile identifiziert.
        "Status zum Neusenden beibehalten
        cv_resend_message = COND flag( WHEN cv_resend_message = abap_true THEN abap_true
                                       ELSE abap_false ).
      ELSE.
        cv_resend_message = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD reduce_by_lines.
    DATA: lr_trg_tab TYPE REF TO data.
    FIELD-SYMBOLS: <lt_trg_tab> TYPE STANDARD TABLE.

    ASSIGN COMPONENT iv_compname OF STRUCTURE cs_data TO FIELD-SYMBOL(<lt_tab>).
    IF <lt_tab> IS ASSIGNED.
      CREATE DATA lr_trg_tab LIKE <lt_tab>.
      ASSIGN lr_trg_tab->* TO <lt_trg_tab>.
      LOOP AT <lt_tab> ASSIGNING FIELD-SYMBOL(<ls_line>).
        IF sy-tabix IN it_sel_lines.
          IF check_object_status_for_msg(
               EXPORTING
                 is_line = <ls_line>
                 iv_line_number = sy-tabix
               CHANGING
                 ct_return = ct_return
             ) = abap_true.
            "Zeile nur im Fehlerfall hinzufügen.
            APPEND INITIAL LINE TO <lt_trg_tab> ASSIGNING FIELD-SYMBOL(<ls_new_line>).
            <ls_new_line> = <ls_line>.
          ENDIF.
        ENDIF.
      ENDLOOP.
      CLEAR: <lt_tab>.
      <lt_tab> = <lt_trg_tab>.
      IF <lt_tab> IS INITIAL.
        IF 1 = 0. MESSAGE i105(/thkr/sst).ENDIF.
        APPEND VALUE bapiret2( id = '/THKR/SST'
                               number = 105
                               type = 'I' ) TO ct_return.

        "Es gab bereits eine Zeile, die relevant war.
        "Also Status beibehalten.

        cv_resend_message = COND Flag( WHEN cv_resend_message = abap_true THEN abap_true
                                       ELSE abap_false ).
      ELSE.
        cv_resend_message = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD reduce_message.
    DATA: lo_struc TYPE REF TO cl_abap_structdescr.
    DATA: ls_strucname TYPE strukname.
    DATA: lt_comp_root TYPE abap_compdescr_tab.

    lo_struc ?= cl_abap_structdescr=>describe_by_data( p_data = cs_data ).

    get_component_of_structure(
      EXPORTING
        iv_strucname       = CONV strukname( lo_struc->absolute_name )
      IMPORTING
        et_comp       = lt_comp_root
        ev_struc_name = ls_strucname
    ).

    change_field_in_structure(
      EXPORTING
        iv_compname         = iv_struc
        is_strucname        = ls_strucname                 " Name einer Struktur
        it_comp             = lt_comp_root
        it_sel_lines        = it_sel_lines
        it_sel_keys1         = it_sel_keys1
        iv_sel_keyname1      = iv_sel_keyname1
        it_sel_keys2         = it_sel_keys2
        iv_sel_keyname2      = iv_sel_keyname2
        it_sel_keys3         = it_sel_keys3
        iv_sel_keyname3      = iv_sel_keyname3
        iv_sel_type         = iv_sel_type
      CHANGING
        cv_resend_message = cv_resend_message
        cs_data             = cs_data
        ct_return           = ct_return
    ).


  ENDMETHOD.


  METHOD set_aif_properties.
    ms_aif_globales-ximsgguid = iv_msg_guid.
    ms_aif_globales-ns = iv_ns.
    ms_aif_globales-ifname = iv_ifname.
    ms_aif_globales-ifversion = iv_ifvers.
  ENDMETHOD.


  METHOD set_sel_typye.
    IF iv_lines = abap_true.
      rv_sel_type = gc_sel_type_lines.
    ENDIF.
    IF iv_keys = abap_true.
      rv_sel_type = gc_sel_type_keys.
    ENDIF.
  ENDMETHOD.


  method SET_STATUS_E_FOR_BLANK.

" Der Status wird in der Buchungsaktion gesetzt.
" Er kann drei Status annehmen:
    "S = Success = Erfolgreich
    "E = Error = Fehler
    "leer = fehlerhafte Aktionsprüfung hat Ausführung der Buchung verhindert
"in solchen Fällen wird der Status auf Fehler gesetzt (E)
  CONSTANTS: lc_vmap_name TYPE /AIF/vmapname VALUE 'MAP_REPROC_STRUC_2_S'.
  CONSTANTS: lc_vmap_ns_zallge TYPE /AIF/ns VALUE 'ZALLGE'.

"Ermittlung des Statusfeld für die jeweilige Struktur
  SELECT single INT_VALUE
    FROM /AIF/T_VMAPVAL
   WHERE ns = @lc_vmap_ns_zallge
     AND vmapname = @lc_vmap_name
     AND ext_value = @iv_absolute_name
    into @DATA(lv_field).

    if sy-subrc = 0.
      "Feld aus Struktur ermitteln
      ASSIGN COMPONENT lv_field of STRUCTURE cs_curr_line to FIELD-SYMBOL(<lv_status>).
      if sy-subrc = 0.
        if <lv_status> is INITIAL.
          "Status-Feld ist leer -> Aktionsprüfung fehlgeschlagen -> Buchung nicht ausgeführt -> Setze Verabeitung auf Fehler
          <lv_status> = 'E'.
        endif.
      endif.
    endif.

  endmethod.


  METHOD show_reduced_message.
    DATA: lt_message TYPE TY_T_SHOW_MSG.

    LOOP at mt_msg_for_prot ASSIGNING FIELD-SYMBOL(<ls_msg>).
      clear: lt_message.
      ASSIGN <ls_msg>-msg_content->* to FIELD-SYMBOL(<ls_content>).
    create_string_table(
          EXPORTING
            is_data  = <ls_content>
            iv_show_fields = iv_show_fields
          CHANGING
            ct_message     = lt_message                " Tabelle von Strings
        ).
    NEW-PAGE LINE-SIZE 2000.
    WRITE: 'Nachrichteninhalt: ' && <ls_msg>-msg_guid_old.
    ULINE.
    IF iv_show_struc = abap_true.
      "Anzeige mit Strukturnamen
      LOOP AT lt_message ASSIGNING FIELD-SYMBOL(<ls_line>).
        WRITE: <ls_line>-comp_name, <ls_line>-content.
        NEW-LINE.
      ENDLOOP.
    ELSE.
      LOOP AT lt_message ASSIGNING <ls_line>.
        WRITE: <ls_line>-content.
        NEW-LINE.
      ENDLOOP.
    ENDIF.

    ULINE.
    ENDLOOP.
  ENDMETHOD.


  method UPDATE_PERS_CGR.

    Update /AIF/PERS_RTCFGR
    SET job_user_exec = iv_user
*        schedule_run = abap_true
    where queue_ns = iv_qns
      and queue_name = iv_qname.
    if sy-subrc <> 0.
      if 1 = 0. MESSAGE e006(/AIF/RUNTIME) with iv_qns iv_qname.endif.
      APPEND VALUE bapiret2( id = '/AIF/RUNTIME'
                             type = 'E'
                             number = 006
                             message_v1 = iv_qns
                             message_v2 = iv_qname  ) to ct_return.
    endif.
  endmethod.


  METHOD update_proc_stat_multi.

    rv_success = write_status(
                   EXPORTING
                     iv_component = 'GP'                  " Komponente der Versionsnummer
                   CHANGING
                     cs_curr_line = cs_curr_line
                 ).

    rv_success = write_status(
      EXPORTING
        iv_component = 'AO'                 " Komponente der Versionsnummer
        CHANGING
                     cs_curr_line = cs_curr_line

    ).

    rv_success = write_status(
      EXPORTING
        iv_component = 'MB'                 " Komponente der Versionsnummer
        CHANGING
                     cs_curr_line = cs_curr_line

    ).

    rv_success = write_status(
      EXPORTING
        iv_component = 'MB_UP'                 " Komponente der Versionsnummer
        CHANGING
                     cs_curr_line = cs_curr_line

    ).
    rv_success = write_status(
      EXPORTING
        iv_component = 'VR'                 " Komponente der Versionsnummer
        CHANGING
                     cs_curr_line = cs_curr_line

    ).

  ENDMETHOD.


  method UPDATE_PROC_STAT_SINGLE.
DATA: ls_aif_obj TYPE /thkr/t_aif_obj.


      ls_aif_obj-msg_id = ms_aif_globales-ximsgguid.
      ls_aif_obj-ns = ms_aif_globales-ns.
      ls_aif_obj-ifname = ms_aif_globales-ifname.
      ls_aif_obj-ifver = ms_aif_globales-ifversion.
      ls_aif_obj-object = get_object_type( iv_absolute_name = iv_absolute_name ).
      ls_aif_obj-objpos_id = get_objec_id(
                               is_curr_line     = is_curr_line
                               iv_absolute_name = iv_absolute_name
                             ).
      ls_aif_obj-status = get_proc_stat(
                            is_curr_line     = is_curr_line
                            iv_absolute_name = iv_absolute_name
                          ).

      MODIFY /thkr/t_aif_obj FROM ls_aif_obj.
      IF sy-subrc <> 0.
        rv_success = 'N'.
      else.
        rv_success = 'Y'.
      ENDIF.
  endmethod.


  METHOD write_status.
    DATA: lo_struc   TYPE REF TO cl_abap_structdescr.
    DATA: lv_offset  TYPE i.

    FIELD-SYMBOLS: <lt_table> TYPE ANY TABLE.

    ASSIGN COMPONENT iv_component OF STRUCTURE cs_curr_line TO <lt_table>.
    IF <lt_table> IS ASSIGNED.
      LOOP AT <lt_table> ASSIGNING FIELD-SYMBOL(<ls_tab_line>).

        lo_struc ?= cl_abap_structdescr=>describe_by_data( <ls_tab_line> ).
        lv_offset = strlen( lo_struc->absolute_name ) - 6.
        "Setzen des Fehlerstatus auf E, wenn leer.
        set_status_e_for_blank(
           EXPORTING
             iv_absolute_name = CONV string( lo_struc->absolute_name+6(lv_offset) )
           CHANGING
             cs_curr_line     = <ls_tab_line>
         ).
        rv_success = update_proc_stat_single(
          EXPORTING
            is_curr_line     = <ls_tab_line>
            iv_absolute_name = CONV string( lo_struc->absolute_name+6(lv_offset) )
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

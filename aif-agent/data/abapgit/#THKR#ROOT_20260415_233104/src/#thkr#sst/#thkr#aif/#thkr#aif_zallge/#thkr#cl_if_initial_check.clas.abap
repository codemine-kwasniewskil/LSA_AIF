class /THKR/CL_IF_INITIAL_CHECK definition
  public
  final
  create public .

public section.

  methods CHECK_QBELNR
    importing
      !IT_LINES type /THKR/T_AIF_BIC_ZEILE
    changing
      !CT_RETURN type BAPIRET2_TT .
  methods CHECK_BTYP
    importing
      !IT_LINES type /THKR/T_AIF_BIC_ZEILE
      !IV_EMPF type CHAR3
    changing
      !CT_RETURN type BAPIRET2_TT .
  methods CHECK_FILE_ORDER
    importing
      !IV_GENNR type NUM4
    changing
      !CT_RETURN type BAPIRET2_TT .
  methods CONSTRUCTOR .
  methods GEN_CHECK
    importing
      !I_DATA_STRING type CHAR17
    exporting
      !E_ERROR type CHAR1
      !ET_RETURN type BAPIRETTAB .
  methods GEN_GEN
    importing
      !I_VERFAHREN type /THKR/DTE_VERFAHREN
    returning
      value(R_GENNR) type /THKR/DTE_GENNR
    exceptions
      ERROR .
protected section.
private section.

  types:
    BEGIN OF TY_S_BTYP,
          BTYP TYPE /THKR/AIF_BTYP,
         END OF ty_s_btyp .
  types:
    TY_T_BTYP TYPE STANDARD TABLE OF TY_S_BTYP .
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
    BEGIN OF TY_S_SI_TAB_VAL,
      guid        TYPE GUID_32,
      create_date TYPE /AIF/CREATE_DATE,
      gennr      TYPE /THKR/BIC_GENNR,
    End of ty_s_si_tab_val .
  types:
    TY_T_SI_TAB_VAL TYPE STANDARD TABLE OF ty_s_si_tab_val .

  data MS_AIF_GLOBALES type TY_S_RUN_INFO .

  methods CHECK_IGNORE_FILE_ORDER
    returning
      value(RV_IGNORE_GENNR) type FLAG .
  methods GET_SST
    importing
      !IV_EMPF type CHAR3
    returning
      value(RV_SST) type CHAR4 .
  methods GEN_SAVE
    importing
      !I_PATH type DXLPATH
      !I_VARIANTE type CHAR1 .
  methods GET_BTYP_FOR_SST
    importing
      !IV_SST type CHAR4
    exporting
      value(ET_BTYP) type TY_T_BTYP .
  methods GET_UNSUPPORTED_BTYP_FROM_IF
    importing
      !IT_LINES type /THKR/T_AIF_BIC_ZEILE
      !IT_BTYP_ALLOWED type TY_T_BTYP
    exporting
      !ET_BTYP type TY_T_BTYP .
  methods GET_SINGLE_INDEX_TAB
    returning
      value(RV_INDEX_TABLE) type /AIF/MSG_TBL .
ENDCLASS.



CLASS /THKR/CL_IF_INITIAL_CHECK IMPLEMENTATION.


METHOD check_btyp.
*"----------------------------------------------------------------------
  DATA: lt_btyp_allowed             TYPE ty_t_btyp.
  DATA: lt_unsupported_btyp_if      TYPE ty_t_btyp.
  DATA: ls_string                   TYPE string.
*"----------------------------------------------------------------------
  DATA(lv_sst) = get_sst( iv_empf = iv_empf ).
*"----------------------------------------------------------------------
  "Erlaubte Buchungstypen aus Konfiguration
  get_btyp_for_sst(
    EXPORTING
      iv_sst  = lv_sst                 " Nicht näher def. Bereich, evtl. für Patchlevels verwendbar
    IMPORTING
      et_btyp = lt_btyp_allowed
  ).
*"----------------------------------------------------------------------
  "nicht unterstütze Buchungstypen aus Schnittstelle
  get_unsupported_btyp_from_if(
    EXPORTING
      it_lines        = it_lines
      it_btyp_allowed = lt_btyp_allowed
    IMPORTING
      et_btyp         = lt_unsupported_btyp_if
  ).
*"----------------------------------------------------------------------
* Alle Buchungstypen anzeigen, die in der Datei enthalten sind, aber
* nicht erlaubt sind.
  LOOP AT lt_unsupported_btyp_if ASSIGNING FIELD-SYMBOL(<ls_btyp_if>).
* Exit
    APPEND VALUE bapiret2( type   = 'W'
                           id     = '/THKR/SST'
                           number = 001
                           message_v1 = |Zur Schnittstelle { lv_sst }|
                           message_v2 = | ist der Buchungsschlüssel { <ls_btyp_if>-btyp }|
                           message_v3 = | nicht vorgesehen und kann|
                           message_v4 = | nicht verarbeitet werden.| ) TO ct_return.
  ENDLOOP.
*"----------------------------------------------------------------------
ENDMETHOD.


  METHOD check_file_order.
*"----------------------------------------------------------------------
* Prüfung der Dateienreihenfolge
* Erfolgt anhand der Generierungsnummer
*
* Das Feld QUELLE in der Single Index-Tabelle kennt die Generierungsnummer (EP + GENIERUNGSNUMMER)
* Voraussetzung:
* Generationsnummer wird um 1 hochgezählt
*
* Ablauf:
* 1.) Ermittlung Single Index Tabelle pro Schnittstelle
* 2.) lesen der letzten verwendeten Generierungsnummer
* 3.) Abgleich mit Datei
*     a.) Generierungsnummer darf nicht gleich sein -> Fehlermeldung
*     b.) Generierungsnummer darf nicht kleiner sein -> Fehlermeldung
*     c.) Generierungsnummer darf keine Lücken haben -> Fehlermeldung
*"----------------------------------------------------------------------
    "Ermittlung Single Index Tabelle
    DATA: ls_si_tab TYPE ty_s_si_tab_val .
    DATA: lv_gennr_successor TYPE num4.

    IF check_ignore_file_order( ) = abap_false.
      "1. Ermittlung der Single Index Tabelle
      DATA(lv_si_tab) = get_single_index_tab( ).

      "2. letzten Wert für Quelle ermitteln
      "Lese die Generationsnummer der letzten Nachricht (MSGGUID darf nicht der eigenen Nachricht entsprechen).
      "Wenn zwei Dateien verarbeitet werden, haben beide den Status I (in Bearbeitung). Daher Reicht der Status alleine nicht aus, um die Reihenfolge zu identifizieren.
      TRY.
          SELECT msgguid , create_date,  gennr
            FROM (lv_si_tab)
            WHERE msgguid <> @ms_aif_globales-ximsgguid
            ORDER BY create_date DESCENDING, create_time DESCENDING
            INTO @ls_si_tab
            UP TO 1 ROWS.
          ENDSELECT.
          "Wenn kein Datensatz in der Single-Index-Tabelle gefunden wurde, ist es die Erstübertragung.
          "Keine Prüfung auf Dateireihenfolge notwendig.
          IF sy-subrc = 0.
            lv_gennr_successor = ls_si_tab-gennr + 1.
            "3. Abgleich
            If ls_si_tab-gennr is INITIAL.
              "a)Eintrag gefunden, Generationsnummer leer. Übernehme aus Datei
              "Kann nur passieren, wenn Nachrichten bereits übertragen wurden und anschließend Änderungen
              "an der Single-Index-Tabelle vorgenommen wurde
              RETURN.
            ElseIF ls_si_tab-gennr = iv_gennr.
              "b) Generierungsnummer darf nicht gleich sein
              IF 1 = 0. MESSAGE e023(/thkr/sst) WITH iv_gennr ls_si_tab-guid ls_si_tab-create_date.ENDIF.
              APPEND VALUE bapiret2( id   = '/THKR/SST'
                                     type = 'E'
                                     number = 023
                                     message_v1 = iv_gennr
                                     message_v2 = ls_si_tab-guid
                                     message_v3 = ls_si_tab-create_date ) TO ct_return.
            ELSEIF ls_si_tab-gennr > iv_gennr.
              "c) Generierungsnummer darf nicht kleiner sein
              IF 1 = 0. MESSAGE e024(/thkr/sst) WITH iv_gennr ls_si_tab-gennr ls_si_tab-create_date.ENDIF.
              APPEND VALUE bapiret2( id   = '/THKR/SST'
                               type = 'E'
                               number = 024
                               message_v1 = iv_gennr
                               message_v2 = ls_si_tab-gennr
                               message_v3 = ls_si_tab-create_date ) TO ct_return.
            ELSEIF iv_gennr <> lv_gennr_successor.
              "d) Generierungsnummer darf keine Lücken haben -> letzte Generationsnummer + 1 = gelieferte Generationsnummer
              IF 1 = 0. MESSAGE e025(/thkr/sst) WITH iv_gennr ls_si_tab-guid ls_si_tab-create_date.ENDIF.
              APPEND VALUE bapiret2( id   = '/THKR/SST'
                          type = 'E'
                          number = 025
                          message_v1 = iv_gennr
                          message_v2 = ls_si_tab-gennr ) TO ct_return.
            ENDIF.
          ENDIF.
        CATCH cx_sy_dynamic_osql_semantics.
          IF 1 = 0. MESSAGE e028(/thkr/sst) WITH lv_si_tab.ENDIF.
          APPEND VALUE bapiret2( id   = '/THKR/SST'
                      type = 'E'
                      number = 028
                      message_v1 = lv_si_tab ) TO ct_return.
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  method CHECK_IGNORE_FILE_ORDER.
  CONSTANTS: lc_vmap_run_conf TYPE /AIF/vmapname VALUE 'MAP_RUN_CONFIG'.
  CONSTANTS: lc_vmap_ns_zallge TYPE /AIF/ns VALUE 'ZALLGE'.
  CONSTANTS: lc_ignore_gennr TYPE /aif/vmap_extval VALUE 'IGNORE_GENNR'.
  CONSTANTS: lc_asterisk TYPE char1 VALUE '*'.

  "Lese Konfigurationsparameter aus Tabelle
  SELECT *
    FROM /aif/t_mvmapval5
   WHERE ns = @lc_vmap_ns_zallge
     AND vmapname = @lc_vmap_run_conf
     AND ext_value3 = @lc_ignore_gennr
  INTO TABLE @DATA(lt_ignore_gennr).
    if sy-subrc = 0.
      "Prüfe ob eine Schnittstellenspezifische Konfiguration vorliegt
      read TABLE lt_ignore_gennr with KEY ext_value1 = ms_aif_globales-ns
                                    ext_value2 = ms_aif_globales-ifname
                           ASSIGNING FIELD-SYMBOL(<ls_reproc>).
      if sy-subrc = 0.
        "Schnittstellenspezifische Konfiguration
        "Nimm Wert aus Tabelle
        rv_ignore_gennr = <ls_reproc>-int_value.
      else.
        "Keine Schnittstellenspezifische Konfiguration
        "Prüfe ob allgemeine Konfiguration vorliegt.
        READ TABLE lt_ignore_gennr with KEY ext_value1 = lc_asterisk
                                      ext_value2 = lc_asterisk
                             ASSIGNING <ls_reproc>.
        if sy-subrc = 0.
          "Allgemeine Konfiguration liegt vor
          "Nimn Wert aus Tabelle
          rv_ignore_gennr = <ls_reproc>-int_value.
        else.
          "Es liegt weder eine Schnittstellenspezifische noch eine
          "allgeimeine Konfiguration vor
          "Wiederanlaufverfahren ist inaktiv
          rv_ignore_gennr = abap_false.
        endif.
      endif.
    else.
      "Es gibt keinen Konfigurationsparameter für Wiederanlaufverfahren
      "also inaktiv
      rv_ignore_gennr = abap_false.
    endif.
  endmethod.


METHOD check_qbelnr.
*"----------------------------------------------------------------------
* Gereon Koks  T-Systems  9.5.2025
*"----------------------------------------------------------------------
* Doubletten-Suche 06_QBELNR
*"----------------------------------------------------------------------
*"----------------------------------------------------------------------
  DATA: ls_line        TYPE /thkr/s_aif_bic_zeile,
        ls_line_old    TYPE /thkr/s_aif_bic_zeile,
        it_lines_local TYPE /thkr/t_aif_bic_zeile.
*"----------------------------------------------------------------------
  it_lines_local[] = it_lines[].

  SORT it_lines_local ASCENDING BY 06_qbelnr.

  LOOP AT it_lines_local INTO ls_line WHERE 01_btyp <> 'KRK'.
    IF ls_line-06_qbelnr = ls_line_old-06_qbelnr.
      APPEND VALUE bapiret2( type   = 'E'
                             id     = '/THKR/SST'
                             number = 001
                             message_v1 = |Der Schlüssel 06_QBELNR { ls_line-06_qbelnr }|
                             message_v2 = | tritt mehrfach auf.|
                             message_v3 = | Unter den Buchungsschlüsseln: { ls_line_old-01_btyp } { ls_line-01_btyp }| ) TO ct_return.
    ENDIF.

    ls_line_old = ls_line.
  ENDLOOP.
*"----------------------------------------------------------------------
ENDMETHOD.


  METHOD constructor.
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
  ENDMETHOD.


METHOD gen_check.
*"----------------------------------------------------------------------
* Gereon Koks  T-Systems  3.6.2025
*"----------------------------------------------------------------------
* Generations-Nummer finden und vergleichen.
*"----------------------------------------------------------------------
*"----------------------------------------------------------------------
  DATA: ls_/thkr/generation_einst TYPE /thkr/generation,
        ls_/thkr/generation       TYPE /thkr/generation,
        lv_path                   TYPE dxlpath,
        lv_gennr                  TYPE num4,
        lv_gennr_prev             TYPE num4,
        lv_gennr_tab              TYPE num4.
*"----------------------------------------------------------------------
  IF sy-cprog = '/AIF/CHECK_AND_SEND_FILES' OR
     sy-cprog = 'SETS_CLASS_TEST_ENTRY'.
    lv_path = i_data_string.
  ELSE.
    ASSIGN ('(/AIF/UPLOAD_FILES_LFA)P_PATH') TO FIELD-SYMBOL(<v>).
    lv_path = <v>.
*  lv_path   = i_path.
    REPLACE ALL OCCURRENCES OF REGEX '.txt' IN lv_path WITH ''.
    DATA lv_length TYPE i.
    lv_length = strlen( lv_path ).
    lv_length = lv_length - 17.
    lv_path   = lv_path+lv_length(17).
  ENDIF.
*"----------------------------------------------------------------------
* Einstellung holen (in VARIANTE)
  SELECT SINGLE * FROM /thkr/generation INTO ls_/thkr/generation_einst
    WHERE bibo = 'X'.
*"----------------------------------------------------------------------
* Generationennummer holen
  "Das Datenelement ist ein CHAR ohne Kleinbuchstaben.
  "Bei Änderungen über die SM30 wird das Verfahren dann immer Großgeschrieben
  DATA(lv_verfahren) = to_upper(  lv_path+9(3) ).
  CASE ls_/thkr/generation_einst-variante.

* Zugriff mit Verfahren
    WHEN '1'.
      SELECT SINGLE * FROM /thkr/generation INTO ls_/thkr/generation
        WHERE bibo      = 'I'
          AND verfahren = lv_verfahren
          AND dienst    = '****'
          AND ep        = '**'.
* Zugriff mit Verfahren + Dienststelle
    WHEN '2'.
      SELECT SINGLE * FROM /thkr/generation INTO ls_/thkr/generation
        WHERE bibo      = 'I'
          AND verfahren = lv_verfahren
          AND dienst    = lv_path+13(4)
          AND ep        = '**'.
* Zugriff mit Verfahren + Dienststelle + Einzelplan
    WHEN '3'.
      SELECT SINGLE * FROM /thkr/generation INTO ls_/thkr/generation
        WHERE bibo      = 'I'
          AND verfahren = lv_verfahren
          AND dienst    = lv_path+13(4)
          AND ep        = lv_path+2(2).
* Deaktiviert (keine Prüfung)
    WHEN 'D'.
      CLEAR e_error.
      APPEND VALUE #( id         = '/THKR/SST'
                 number     = 001
* Error führt zu Abbruch. Verarbeitung soll aber weiter laufen: daher nur Information
                 type       = 'I'
                 message_v1 = 'Generationsnummernprüfung ist deaktiviert.' ) TO et_return.
      RETURN.
    WHEN OTHERS.
  ENDCASE.
*"----------------------------------------------------------------------
* Generations-Nummer gefunden und
* prüfen gegen neue Generations-Nummer aus der Datei
  IF sy-subrc = 0.
    "Umwandlung Test in Zahlen, damit der Vergleich auch funktioniert.
    "Es gab Probleme beim Textvergleich und der führenden Null.
    "Aus 0613 wurde 613. Das führte dann dazu dass 613 größer war als 0613.
    "Daher war es notwendig, auf Zahlen zu wechseln.
    "Eine Änderung des Datenelements führt dazu, dass in der SM30 die führenden
    "Nullen nicht mehr da sind und ein optischer Vergleich schwieriger ist.
    lv_gennr = lv_path+4(4).
    lv_gennr_prev = lv_path+4(4) - 1.
    lv_gennr_tab  = ls_/thkr/generation-gennr.

    IF lv_gennr = lv_gennr_tab.
      APPEND VALUE #( id         = '/THKR/SST'
                 number     = 001
                 type       = 'E'
                 message_v1 = 'Datei mit Generationsnummer'
                 message_v2 = ls_/thkr/generation-gennr
                 message_v3 = 'wurde schon einmal geschickt.' ) TO et_return.
      e_error = 'X'.
    ELSEIF lv_gennr < lv_gennr_tab.
      APPEND VALUE #( id         = '/THKR/SST'
                 number     = 001
                 type       = 'E'
                 message_v1 = 'Datei hat kleinere Generationsnummer'
                 message_v2 = lv_path+4(4)
                 message_v3 = 'als frühere Datei'
                 message_v4 = ls_/thkr/generation-gennr ) TO et_return.
      e_error = 'X'.
    ELSEIF lv_gennr_prev > lv_gennr_tab.
      APPEND VALUE #( id         = '/THKR/SST'
                 number     = 001
                 type       = 'E'
                 message_v1 = |Zwischen der aktuellen Datei { lv_path+4(4) }|
                 message_v2 = | und einer früheren Datei { ls_/thkr/generation-gennr }|
                 message_v3 = | liegt eine Lücke.| ) TO et_return.
      e_error = 'X'.
    ELSE.
* Alles OK: Speichern
      CALL METHOD me->gen_save
        EXPORTING
          i_path     = lv_path
          i_variante = ls_/thkr/generation_einst-variante.
    ENDIF.
  ELSE.
* Noch keine Generations-Nummer gefunden: Ersten Satz anlegen
    CALL METHOD me->gen_save
      EXPORTING
        i_path     = lv_path
        i_variante = ls_/thkr/generation_einst-variante.
  ENDIF.
*"----------------------------------------------------------------------
*"----------------------------------------------------------------------
ENDMETHOD.


METHOD gen_gen.
*"----------------------------------------------------------------------
* Gereon Koks  T-Systems  6.6.2025
*"----------------------------------------------------------------------
* Nächste Generations-Nummer zum Verfahren erzeugen.
*"----------------------------------------------------------------------
*"----------------------------------------------------------------------
  DATA: ls_/thkr/generation TYPE /thkr/generation.

  SELECT * FROM /thkr/generation INTO ls_/thkr/generation
    WHERE bibo      = 'O'
      AND verfahren = i_verfahren.

    r_gennr = ls_/thkr/generation-gennr + 1.

    ls_/thkr/generation-gennr = r_gennr.
    MODIFY /thkr/generation FROM ls_/thkr/generation.
  ENDSELECT.

  IF sy-subrc <> 0.
    r_gennr = '0001'.
    ls_/thkr/generation-bibo      = 'O'.
    ls_/thkr/generation-verfahren = i_verfahren.
    ls_/thkr/generation-dienst    = '****'.
    ls_/thkr/generation-ep        = '**'.
    ls_/thkr/generation-gennr     = r_gennr.
    ls_/thkr/generation-variante  = '1'.

    MODIFY /thkr/generation FROM ls_/thkr/generation.
  ENDIF.
*"----------------------------------------------------------------------
ENDMETHOD.


METHOD gen_save.
*"----------------------------------------------------------------------
* Gereon Koks  T-Systems  4.6.2025
*"----------------------------------------------------------------------
* Generations-Nummer speichern.
*"----------------------------------------------------------------------
*"----------------------------------------------------------------------
  DATA: ls_/thkr/generation TYPE /thkr/generation.
  DATA: lv_verfahren TYPE /THKR/DTE_VERFAHREN.
*"----------------------------------------------------------------------
  CLEAR ls_/thkr/generation.
  lv_verfahren = to_upper( i_path+9(3) ).
*"----------------------------------------------------------------------
  CASE i_variante.
    WHEN '1'.
      ls_/thkr/generation-bibo      = 'I'.
      ls_/thkr/generation-verfahren = lv_verfahren.
      ls_/thkr/generation-dienst    = '****'.
      ls_/thkr/generation-ep        = '**'.
      ls_/thkr/generation-gennr     = i_path+4(4).
    WHEN '2'.
      ls_/thkr/generation-bibo      = 'I'.
      ls_/thkr/generation-verfahren = lv_verfahren.
      ls_/thkr/generation-dienst    = i_path+13(4).
      ls_/thkr/generation-ep        = '**'.
      ls_/thkr/generation-gennr     = i_path+4(4).
    WHEN '3'.
      ls_/thkr/generation-bibo      = 'I'.
      ls_/thkr/generation-verfahren = lv_verfahren.
      ls_/thkr/generation-dienst    = i_path+13(4).
      ls_/thkr/generation-ep        = i_path+2(2).
      ls_/thkr/generation-gennr     = i_path+4(4).
    WHEN OTHERS.
  ENDCASE.
*"----------------------------------------------------------------------
  MODIFY /thkr/generation FROM ls_/thkr/generation.
*"----------------------------------------------------------------------
ENDMETHOD.


  method GET_BTYP_FOR_SST.
    SELECT BTYP FROM /thkr/chk_btyp INTO TABLE @et_btyp
        WHERE sst  = @iv_sst.
  endmethod.


  method GET_SINGLE_INDEX_TAB.
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


  METHOD get_sst.
    SELECT SINGLE int_value FROM /aif/t_vmapval5
      WHERE ns        = 'ZALLGE'
        AND vmapname  = 'MAP_/THKR/SST'
        AND ext_value1 = @iv_empf
      INTO @rv_sst.
  ENDMETHOD.


  METHOD GET_UNSUPPORTED_BTYP_FROM_IF.
    DATA: lt_lines TYPE /THKR/T_AIF_BIC_ZEILE.

    lt_lines = it_lines.

    "Lösche alle erlaubten Buchungstypen aus interner Schnittstelle
    LOOP AT it_btyp_allowed ASSIGNING FIELD-SYMBOL(<ls_btyp_allowed>).
      Delete lt_lines where 01_btyp = <ls_btyp_allowed>-btyp.
    ENDLOOP.

    if lt_lines is INITIAL.
      "Es sind in der Datei nur erlaubte Buchungstypen enthalten.
      Clear et_btyp.
    else.
      "Es gibt Buchungstypen in der Schnittstelle, die nicht vorgesehen sind
      loop at lt_lines ASSIGNING FIELD-SYMBOL(<ls_line>).
        APPEND value ty_s_btyp( btyp = <ls_line>-01_btyp ) to et_btyp.
      ENDLOOP.
    endif.
  ENDMETHOD.
ENDCLASS.

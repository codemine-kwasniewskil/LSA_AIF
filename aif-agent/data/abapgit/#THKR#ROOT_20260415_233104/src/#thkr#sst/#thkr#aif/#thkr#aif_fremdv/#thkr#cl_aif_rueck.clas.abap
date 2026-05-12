class /THKR/CL_AIF_RUECK definition
  public
  final
  create public .

public section.

  data MS_PPROP type /THKR/FILE_PPROP .

  methods MODIFY_OUTPUT_TAB
    importing
      !IT_RUECK_LINES type ANY
      !IS_HEADER type /THKR/S_AIF_BIC_HEADER optional
      !IS_FOOTER type /THKR/S_AIF_BIC_FOOTER optional
    returning
      value(RT_RUECK_TABLE) type STRING_TABLE .
  methods CONSTRUCTOR .
  methods CHK_RECORD_SHOULD_BE_SENT
    importing
      !IV_RESEND type FLAG
      !IV_BUKRS type BUKRS
      !IV_GJAHR type GJAHR
      !IV_LOTKZ type LOTKZ
      !IV_BELNR type BELNR_D
      !IV_GEZAHLT type FM_TRBTR
    returning
      value(RV_ERROR) type FLAG
    raising
      /THKR/CX_AIF .
  methods GET_IST_TYPE
    importing
      !IV_SST type /THKR/DTE_BU_SST
    returning
      value(RV_IST_TYPE) type /THKR/IST_RUECK_TYPE .
  methods GET_GENNR_FROM_SI_TAB
    returning
      value(RV_GENNR) type STRING .
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

  constants GC_SEPARATOR_SEMI type CHAR1 value ';' ##NO_TEXT.
  constants GC_SEPARATOR_PIPE type CHAR1 value '|' ##NO_TEXT.
  data MS_AIF_GLOBALES type TY_S_RUN_INFO .
  data:
    MT_fields TYPE STANDARD TABLE OF /THKR/FILE_flds .

  methods GET_IST_TYPE_DEFAULT
    returning
      value(RV_DEFAULT) type /AIF/VMAP_DEFVAL .
  methods MODIFY_DEFAULT
    importing
      !IS_ROW type ANY
    returning
      value(RV_STRING) type STRING .
  methods GET_MULTI_INDEX_TABLE
    returning
      value(RV_IDX_TAB) type /AIF/MSG_TBL
    raising
      /THKR/CX_AIF .
  methods GET_FILE_PROPERTIY .
  methods ADD_HEADER_LINE
    importing
      !IT_RUECK type ANY
    returning
      value(RT_RUECK_TAB) type STRING_TABLE .
  methods MODIFY_ROW
    importing
      !IS_ROW type ANY
      !IV_IS_LAST type FLAG
    returning
      value(RV_STRING) type STRING .
  methods GET_SEPARATOR
    returning
      value(RV_SEPARATOR) type CHAR1 .
  methods GET_SINGLE_INDEX_TAB
    returning
      value(RV_INDEX_TABLE) type /AIF/MSG_TBL .
ENDCLASS.



CLASS /THKR/CL_AIF_RUECK IMPLEMENTATION.


  METHOD add_header_line.
    DATA: lo_tab TYPE REF TO cl_abap_tabledescr.
    DATA: lo_struc TYPE REF TO cl_abap_structdescr.
    DATA: lv_header TYPE string.
    DATA: lv_separator(1) TYPE c.

    lv_separator = get_separator( ).

    IF ms_pprop-header = abap_false.
      "Keine Kopfzeile
      RETURN.
    ELSE.
      "Kopfzeile hinzufügen
      IF mt_fields IS NOT INITIAL.
        lo_tab ?= cl_abap_tabledescr=>describe_by_data( it_rueck ).
        DATA(lv_name) = lo_tab->get_table_line_type( )->absolute_name.
        DATA(lv_length) = strlen( lv_name ) - 6.
        lo_struc ?= cl_abap_structdescr=>describe_by_name( lo_tab->get_table_line_type( )->absolute_name+6(lv_length) ).
        LOOP AT mt_fields ASSIGNING FIELD-SYMBOL(<ls_header>).
          "Prüfung, ob Feld in Ausgabeformat vorhanden ist
          READ TABLE lo_struc->components WITH KEY name = <ls_header>-fieldname TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            "Kopfzeile zusammenbauen
            lv_header = lv_header && |{ <ls_header>-header WIDTH = <ls_header>-outputlength PAD = <ls_header>-filler }| && lv_separator.
          ENDIF.
          AT LAST.
            DATA(lv_len) = strlen( lv_header ) - 1.
            lv_header = lv_header(lv_len) .
          ENDAT.
        ENDLOOP.
        "Zeilenvorschub hinzufügen
        IF ms_pprop-cr_lf IS NOT INITIAL.
          lv_header = lv_header && COND #( WHEN ms_pprop-cr_lf = 1 THEN cl_abap_char_utilities=>cr_lf(1)
                                           WHEN ms_pprop-cr_lf = 2 THEN cl_abap_char_utilities=>newline
                                           WHEN ms_pprop-cr_lf = 3 THEN cl_abap_char_utilities=>cr_lf ).
        ENDIF.
        INSERT INITIAL LINE INTO rt_rueck_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<ls_add_header>).
        <ls_add_header> = lv_header.
      ELSE.
        RETURN.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD chk_record_should_be_sent.

    "RV_ERROR = ABAP_FALSE = Datensatz wird übertragen
    "RV_EROOR = ABAP_TRUE = Datensatz wird nicht übertragen

    DATA: lv_tab_exists TYPE sy-subrc.
    DATA: lv_msgid TYPE guid_32.
    DATA(lv_idx_table) = get_multi_index_table( ).

    "IV_RESEND = ABAP_TRUE = Datensatz erneut übertragen (unabhängig von Daten in Multi-Index-Tabelle)
    "IV_RESEND = ABAP_FALSE = Datensatz nur übertragen, wenn er nicht bereits übertragen wurde (Auslesen der Multi-Index-Tabelle)
    IF lv_idx_table IS NOT INITIAL.
      IF iv_resend = abap_false.
        SELECT SINGLE msgguid
          FROM (lv_idx_table)
         WHERE bukrs = @iv_bukrs
           AND gjahr = @iv_gjahr
           AND lotkz = @iv_lotkz
           AND belnr = @iv_belnr
           AND GEZAHLT = @iv_gezahlt
        INTO @lv_msgid.
        IF sy-subrc = 0.
          "Es wurde bereits dieser Datensatz übertragen
          "Prüfung ob eine erneute Übertragung gewünscht ist.
          rv_error = COND flag( WHEN iv_resend = abap_true THEN abap_false
                               ELSE abap_true ).
        ELSE.
          "Datensatz noch nicht übertragen.
          rv_error = abap_false.
        ENDIF.
      ELSE.
        "Datensatz soll neu übertragen werden.
        "Abfrage auf Index-Tabelle nicht notwendig.
        rv_error = abap_false.
      ENDIF.
    ELSE.
      "Es konnte keine Multi-Index-Tabelle ermittelt werden
      "Es werden dann immer die Datensätze übertragen.
      "Datensatz übertragen
      rv_error = abap_false.
    ENDIF.


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

    get_file_propertiy( ).
  ENDMETHOD.


  METHOD get_file_propertiy.

    SELECT SINGLE *
      FROM /thkr/file_pprop
     WHERE ns = @ms_aif_globales-ns
       AND ifname = @ms_aif_globales-ifname
       AND ifversion = @ms_aif_globales-ifversion
    INTO CORRESPONDING FIELDS OF @ms_pprop.

      SELECT *
        FROM /thkr/file_flds
       WHERE ns = @ms_aif_globales-ns
         AND ifname = @ms_aif_globales-ifname
         AND ifversion = @ms_aif_globales-ifversion
       ORDER BY outputorder ASCENDING
      INTO TABLE @mt_fields.

    ENDMETHOD.


  METHOD get_gennr_from_si_tab.
    DATA(lv_si_tab) = get_single_index_tab( ).

    "Letzen Datensatz aus Single Index-Tabelle ermitteln
    SELECT gennr
      FROM (lv_si_tab)
      WHERE status <> 'I' "in Bearbeitung
      ORDER BY create_date DESCENDING, create_time DESCENDING
      INTO @rv_gennr
      UP TO 1 ROWS.
    ENDSELECT.

    IF sy-subrc = 0.
      IF rv_gennr IS INITIAL.
        "Feld ist leer
        "Generationsnummer auf 1 setzen
        rv_gennr = '0001'.
      ELSE.
        "Wert um 1 hochzählen und zurückgeben.
        rv_gennr += 1.
        rv_gennr = |{ rv_gennr  ALPHA = IN WIDTH = 4 }|.
      ENDIF.
    ELSE.
      "Es gibt noch keinen Eintrag.
      "Generationsnummer auf 1 setzen
      rv_gennr = '0001'.
    ENDIF.
  ENDMETHOD.


  method GET_IST_TYPE.
        CONSTANTS: lc_ns_map  TYPE /aif/ns VALUE 'ZALLGE'.
    CONSTANTS: lc_vmap    TYPE /aif/vmapname VALUE 'MAP_IST_RUECK_TYPE'.

    SELECT SINGLE INT_VALUE
      FROM /AIF/T_MVMAPVAL
     WHERE ns = @lc_ns_map
       AND vmapname = @lc_vmap
       AND ext_value = @iv_sst
       INTO @rv_ist_type.
    if sy-subrc <> 0.
      rv_ist_type = get_ist_type_default( ).
    endif.
  endmethod.


  method GET_IST_TYPE_DEFAULT.

    CONSTANTS: lc_ns_map  TYPE /aif/ns VALUE 'ZALLGE'.
    CONSTANTS: lc_vmap    TYPE /aif/vmapname VALUE 'MAP_IST_RUECK_TYPE'.

    SELECT SINGLE DEFAULTVALUE
      FROM /AIF/T_VMAP
     WHERE ns = @lc_ns_map
       AND vmapname = @lc_vmap
      into @rv_default.
  endmethod.


  method GET_MULTI_INDEX_TABLE.
    SELECT SINGLE IDX_TABLE
      FROM /aif/t_inf_kflds
     WHERE ns = @ms_aif_globales-ns
       AND ifname = @ms_aif_globales-ifname
       aND ifver = @ms_aif_globales-ifversion
       AND is_multi = 'M'
       AND fieldname = 'BUKRS'
     INTO @rv_idx_tab.
      if sy-subrc <> 0.
        raise EXCEPTION TYPE /thkr/cx_aif MESSAGE e014(/AIF/ERROR_HANDLING) with ms_aif_globales-ns ms_aif_globales-ifname ms_aif_globales-ifversion.
      ENDIF.
  endmethod.


  METHOD get_separator.
    DATA: lv_ascii TYPE x.
    DATA: lo_ascii_con TYPE REF TO cl_abap_conv_in_ce.

    IF ms_pprop-separator_hex is not INITIAL.
      lv_ascii = ms_pprop-separator_hex.
      lo_ascii_con = cl_abap_conv_in_ce=>create( encoding = 'UTF-8' ).
      lo_ascii_con->convert(
        EXPORTING
          input           =  lv_ascii                " Zu konvertierende Bytefolge
*          n               = -1               " Anzahl einzulesender Einheiten
        IMPORTING
          data            = rv_separator                 " Zu füllendes Feld
*          len             =                  " Anzahl konvertierter Einheiten
*          input_too_short =                  " Eingabepuffer war zu kurz
      ).

    ELSEIF ms_pprop-separator IS INITIAL.
      rv_separator = gc_separator_semi.
    ELSE.
      rv_separator = ms_pprop-separator.
    ENDIF.
  ENDMETHOD.


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


  METHOD modify_default.
    DATA(lv_separator) = get_separator( ).
    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE is_row TO FIELD-SYMBOL(<lv_field>).
      IF sy-subrc <> 0.
        EXIT.
      ELSE.
        IF sy-index = 1.
          rv_string = <lv_field> && lv_separator.
        ELSE.
          rv_string = rv_string && <lv_field> && lv_separator.
        ENDIF.
      ENDIF.
    ENDDO.
    "Letztes Feld ohne Trernner
    "Letztes Feld ohne Feldtrenner
    IF ms_pprop-separator_as_last = abap_false.
      DATA(lv_len) = strlen( rv_string ) - 1.
      rv_string = rv_string(lv_len) .
    ENDIF.
  ENDMETHOD.


  METHOD modify_output_tab.
    "Kopfzeile hinzufügen
    rt_rueck_table = add_header_line( it_rueck = it_rueck_lines ).

    "Leerzeile zu Beginn einfügen
    IF ms_pprop-init_start_line = abap_true.
      APPEND INITIAL LINE TO rt_rueck_table.
    ENDIF.

    "Zeilen formatieren
    LOOP AT it_rueck_lines ASSIGNING FIELD-SYMBOL(<ls_lines>).
      IF sy-tabix = lines( it_rueck_lines ).
        DATA(lv_is_last) = abap_true.
      ELSE.
        lv_is_last = abap_false.
      ENDIF.
      APPEND INITIAL LINE TO rt_rueck_table ASSIGNING FIELD-SYMBOL(<ls_rueck>).
      <ls_rueck> = modify_row( is_row = <ls_lines>
                               iv_is_last = lv_is_last ).
    ENDLOOP.
    IF ms_pprop-bic_header = abap_true.
      INSERT is_header INTO rt_rueck_table INDEX 1.
    ENDIF.
    IF ms_pprop-bic_footer = abap_true.
      APPEND is_footer TO rt_rueck_table.
    ENDIF.

*    CASE ms_aif_globales-ifname.
*      WHEN: 'O_0037_002'.
*        "Sachkundenachweis
*        "Zusatzzeilen
*        Data: lr_data_tab type REF TO data.
*
*        FIELD-SYMBOLS <lt_data_tab> type /THKR/T_AIF_SAP_RUECK_SKNW.
*        CREATE DATA lr_data_tab TYPE STANDARD TABLE OF /thkr/s_aif_sap_rueck_sknw_row.
*        ASSIGN lr_data_tab->* to <lt_data_tab>.
*        <lt_data_tab> = it_rueck_lines.
*        Sort <lt_data_tab> by BANKDATUM ASCENDING.
*
*        INSERT INITIAL LINE INTO rt_rueck_table INDEX 1 ASSIGNING FIELD-SYMBOL(<lv_header>).
*        <lv_header> = |Auswertung für Zeitraum { <lt_data_tab>[ 1 ]-kassendatum } bis { <lt_data_tab>[ lines( <lt_data_tab> ) ]-kassendatum }: { sy-datum Date = USER } { sy-uzeit(2) }:{ sy-uzeit+2(2) } |.
*        Append INITIAL LINE to rt_rueck_table ASSIGNING FIELD-SYMBOL(<lv_footer>).
*        <lv_footer> = |Ermittelte Einzahlungen:     { lines( <lt_data_tab> ) }|.
*    ENDCASE.
  ENDMETHOD.


  METHOD modify_row.
    DATA: lv_separator(1) TYPE c.

    lv_separator = get_separator( ).

    IF mt_fields IS NOT INITIAL.
      "Feldkonfiguration hinterlegt
      LOOP AT mt_fields ASSIGNING FIELD-SYMBOL(<ls_fields>).
        DATA(lv_filler) = COND #( WHEN <ls_fields>-filler IS INITIAL THEN space
                            ELSE <ls_fields>-filler ).
        ASSIGN COMPONENT <ls_fields>-fieldname OF STRUCTURE is_row TO FIELD-SYMBOL(<lv_field>).
        rv_string = rv_string && |{ <lv_field> WIDTH = <ls_fields>-outputlength PAD = lv_filler ALIGN = COND #( WHEN <ls_fields>-align = 'L' THEN cl_abap_format=>a_left
                                                                                                                 WHEN <ls_fields>-align = 'M' THEN cl_abap_format=>a_center
                                                                                                                 WHEN <ls_fields>-align = 'R' THEN cl_abap_format=>a_right
                                                                                                                 ELSE cl_abap_format=>a_left ) }| && lv_separator.
        AT LAST.
          "Letztes Feld ohne Feldtrenner
          IF ms_pprop-separator_as_last = abap_false.
            DATA(lv_len) = strlen( rv_string ) - 1.
            rv_string = rv_string(lv_len) .
          ENDIF.
        ENDAT.
      ENDLOOP.
    ELSE.
      "Keine Feldkonfiguration hinterlegt
      "Standard-Datei-Erstellung
      rv_string = modify_default( is_row = is_row ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

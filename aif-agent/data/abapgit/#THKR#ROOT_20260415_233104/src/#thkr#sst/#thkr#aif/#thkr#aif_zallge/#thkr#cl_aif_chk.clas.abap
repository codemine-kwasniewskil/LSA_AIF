class /THKR/CL_AIF_CHK definition
  public
  final
  create public .

public section.

  methods CHECK_BUKRS_IS_INITIAL
    importing
      !IS_CURR_LINE type ANY
    changing
      !CT_RETURN_TAB type TT_BAPIRET2
      !CT_DATA type ANY
    returning
      value(RV_ERROR) type FLAG .
  methods CHECK_PROCESS_CHAIN
    importing
      !IS_DATA_STRUC type ANY
      !IS_CURR_LINE type ANY
    changing
      !CT_RETURN_TAB type TT_BAPIRET2
      !CT_DATA type ANY
    returning
      value(RV_ERROR) type FLAG .
  methods CHECK_AO_REF_EXISTS
    importing
      !IV_URKASS type XBLNR
    returning
      value(RV_EXISTS) type FLAG .
  methods CHECK_MANDATORY_BLART
    importing
      !IS_RAW_LINE type PSO02
      !IS_RAW_STRUC type /THKR/S_DE_PSO_XML_FILE
    changing
      !CS_DEST_LINE type /THKR/S_AIF_SAP_AO .
  methods CHECK_BP_DOES_NOT_EXIST
    importing
      !IS_CURR_LINE type /THKR/S_AIF_SAP_GP
    changing
      !CT_RETURN_TAB type TT_BAPIRET2
      !CT_DATA type /THKR/T_DTO_BP_CREATE
    returning
      value(RV_ERROR) type FLAG .
protected section.
private section.

  constants GC_MSGTY_E type MSGTY value 'E' ##NO_TEXT.
  constants GC_CENTRAL_MAP_TAB type TABNAME value '/THKR/CENTRALMAP' ##NO_TEXT.
  constants GC_GP type SYMSGV value 'Geschäftspartner' ##NO_TEXT.
  constants GC_MB type SYMSGV value 'Mittelbindung' ##NO_TEXT.
  constants GC_AO type SYMSGV value 'Anordnung' ##NO_TEXT.
  constants GC_VR type SYMSGV value 'Verrechnungsanordnung' ##NO_TEXT.
  constants GC_AIF_NS_ZALLGE type /AIF/NS value 'ZALLGE' ##NO_TEXT.

  methods CHECK_BUKRS_FOR_GP
    importing
      !IS_CURR_LINE type /THKR/S_AIF_SAP_GP
      !IV_STRUC_NAME type TYPENAME
    changing
      !CT_RETURN_TAB type TT_BAPIRET2
      !CT_DATA type /THKR/T_DTO_BP_CREATE
    returning
      value(RV_ERROR) type FLAG .
  methods CHECK_BUKRS_FOR_AO
    importing
      !IS_CURR_LINE type /THKR/S_AIF_SAP_AO
      !IV_STRUC_NAME type TYPENAME
    changing
      !CT_RETURN_TAB type TT_BAPIRET2
      !CT_DATA type /THKR/T_DTO_PSM_AO_BEL_CREATE
    returning
      value(RV_ERROR) type FLAG .
  methods CHECK_BUKRS_FOR_MV
    importing
      !IS_CURR_LINE type /THKR/S_AIF_SAP_MV
      !IV_STRUC_NAME type TYPENAME
    changing
      !CT_RETURN_TAB type TT_BAPIRET2
      !CT_DATA type /THKR/T_DTO_PSM_MV_CREATE
    returning
      value(RV_ERROR) type FLAG .
  methods CHECK_BUKRS_FOR_VR
    importing
      !IS_CURR_LINE type /THKR/S_AIF_SAP_VR
      !IV_STRUC_NAME type TYPENAME
    changing
      !CT_RETURN_TAB type TT_BAPIRET2
      !CT_DATA type /THKR/T_DTO_PSM_VR_CREATE
    returning
      value(RV_ERROR) type FLAG .
  methods CHECK_BUKRS_FOR_AO_SAB
    importing
      !IS_CURR_LINE type /THKR/S_AIF_SAP_AO_SAB
      !IV_STRUC_NAME type TYPENAME
    changing
      !CT_RETURN_TAB type TT_BAPIRET2
      !CT_DATA type /THKR/T_DTO_AO_SAB
    returning
      value(RV_ERROR) type FLAG .
  methods CHECK_BUKRS_EXISTS
    importing
      !IV_BUKRS type BUKRS
    changing
      !CT_RETURN_TAB type TT_BAPIRET2
    returning
      value(RV_ERROR) type FLAG .
  methods CHECK_PROCESS_CHAIN_GP
    importing
      !IV_BU_BPEXT type BU_BPEXT
      !IV_BUSINESS_OBJECT type SYMSGV
      !IT_GP type /THKR/T_DTO_BP_CREATE
    changing
      !CT_RETURN_TAB type TT_BAPIRET2
    returning
      value(RV_ERROR) type FLAG .
  methods CHECK_PROCESS_CHAIN_MV
    importing
      !IV_GLBLID type /THKR/AIF_GLBLID
      !IV_BUSINESS_OBJECT type SYMSGV
      !IT_MV type /THKR/T_DTO_PSM_MV_CREATE
    changing
      !CT_RETURN_TAB type TT_BAPIRET2
    returning
      value(RV_ERROR) type FLAG .
  methods CHECK_PROCESS_CHAIN_AO
    importing
      !IV_GLBLID type /THKR/AIF_GLBLID
      !IV_BUSINESS_OBJECT type SYMSGV
      !IT_AO type /THKR/T_DTO_PSM_AO_BEL_CREATE
    changing
      !CT_RETURN_TAB type TT_BAPIRET2
    returning
      value(RV_ERROR) type FLAG .
  methods CHECK_AO_EXISTS
    importing
      !IV_URKASS type XBLNR
    returning
      value(RV_EXISTS) type FLAG .
  methods CHECK_MB_EXISTS
    importing
      !IV_URKASS type XBLNR
    returning
      value(RV_EXISTS) type FLAG .
  methods GET_MANDATORY_BLART
    returning
      value(RT_VMAP) type /AIF/T_VMAPVAL_TT .
ENDCLASS.



CLASS /THKR/CL_AIF_CHK IMPLEMENTATION.


  METHOD check_ao_exists.
    SELECT COUNT( belnr )
  FROM bkpf
 WHERE xblnr = @iv_urkass
  INTO @DATA(lv_count).
    IF sy-subrc = 0.
      IF lv_count > 0.
        rv_exists = abap_true.
      ELSE.
        rv_exists = abap_false.
      ENDIF.
    ELSE.
      rv_exists = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_ao_ref_exists.
    FIELD-SYMBOLS: <lt_msg> TYPE bapiret2_tt.
    "Prüfen, ob Anordnung existiert.
    rv_exists = check_ao_exists( iv_urkass = iv_urkass ).
    "Prügen, ob allgemeine Anordung existiert.
    if rv_exists IS INITIAL.
      rv_exists = check_mb_exists( iv_urkass = iv_urkass ).
    endif.

  ENDMETHOD.


  METHOD check_bp_does_not_exist.

    SELECT SINGLE partner
      FROM but000
      WHERE /thkr/sst = @is_curr_line-/thkr/sst
       AND bpext = @is_curr_line-bu_bpext
       AND type = @is_curr_line-bu_type
      INTO @DATA(lv_parnter).
    IF sy-subrc = 0.
      "Geschäftspartner existiert bereits.
      "Also nicht erneut anlegen
      rv_error = abap_true.
      "Lese Status des Vorgängersatzes
      LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<ls_data_prev>) WHERE bu_bpext = is_curr_line-bu_bpext
                                                          AND bp_proc_status IS NOT INITIAL .
        "Datensatz gefunden,
        EXIT.
      ENDLOOP.
      IF <ls_data_prev> IS ASSIGNED.
        "Übernehme Verarbeitungsstatus des Vorgängersatzes für alle gleichen Geschäftspartner
        LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<ls_data_new_stat>) WHERE bu_bpext = is_curr_line-bu_bpext
                                                                     AND bp_proc_status IS INITIAL .
          <ls_data_new_stat>-bp_proc_status = <ls_data_prev>-bp_proc_status.
        ENDLOOP.
      ENDIF.

      READ TABLE ct_data WITH KEY bu_bpext = is_curr_line-bu_bpext ASSIGNING FIELD-SYMBOL(<ls_data>).
      IF sy-subrc = 0.
        IF <ls_data>-bp_proc_status IS INITIAL.
          "Kein GP in der Nachrichten.
          "GP existiert dennoch auf der Datenkbank.
          <ls_data>-bp_proc_status = 'S'.
        ENDIF.
        IF 1 = 0. MESSAGE e047(/thkr/sst) WITH is_curr_line-bu_bpext. ENDIF.
        APPEND VALUE bapiret2( type = 'I'
                               id = '/THKR/SST'
                               number = 047
                               message_v1 = is_curr_line-bu_bpext ) TO <ls_data>-msg.
        APPEND LINES OF <ls_data>-msg TO ct_return_tab.
      ENDIF.
    ELSE.
      rv_error = abap_false.
    ENDIF.
  ENDMETHOD.


  method CHECK_BUKRS_EXISTS.

    SELECT single BUKRS
      FROM T001
      WHERE bukrs = @iv_bukrs
      into @DATA(lv_bukrs).
      if sy-subrc = 0.
        rv_error = abap_false.
      else.
        "Keine Kontierung in der Anordnung
        if 1 = 0. Message e468(62) with iv_bukrs. endif.
        APPEND VALUE bapiret2( type = gc_msgty_e
               id = '62'
               number = 468
               message_v1 = iv_bukrs ) TO ct_return_tab.
        rv_error = abap_true.
      endif.
  endmethod.


  METHOD check_bukrs_for_ao.
    "Fehlermeldung an Anordnung anhängen
    READ TABLE ct_data WITH KEY glblid = is_curr_line-glblid
                        ASSIGNING FIELD-SYMBOL(<ls_data>).
    "Buchungskreis direkt auf AO-Ebene
    IF is_curr_line-bukrs IS NOT INITIAL.
      rv_error = check_bukrs_exists(
        EXPORTING
          iv_bukrs      = is_curr_line-bukrs                 " Buchungskreis
        CHANGING
          ct_return_tab = ct_return_tab                 " Tabellentyp für BAPIRET2
      ).
      APPEND LINES OF ct_return_tab TO <ls_data>-msg.
    ELSE.

      IF sy-subrc = 0.
        "Geschäftsbereich = Dienststelle
        READ TABLE is_curr_line-t_kont ASSIGNING FIELD-SYMBOL(<ls_kont>) INDEX 1.
        IF sy-subrc = 0.

          "Fehlermeldung nicht in Returntab schreiben.
          "Wird in der Aktion beim Buchen der Anordung durchgeführt.
*          APPEND VALUE bapiret2( type = gc_msgty_e
*                           id = '/THKR/SST'
*                           number = 012
*                           message_v1 = is_curr_line-dst_old
*                       message_v2 = is_curr_line-ep
*                       message_v3 = gc_central_map_tab ) TO ct_return_tab.

          "Finanzwerte sollen aus Mittelbindung gezogen werden.
          "Es existiert nur keine.
          "Das Feld KBLNR ist dann gefüllt (Entweder mit Belegnumemr SAP oder mit Urkassenzeichen aus der Schnittstelle
          IF <ls_kont>-kblnr IS NOT INITIAL.
            "AO mit Bezug zur Mittelbidnung.
            IF 1 = 0. MESSAGE e041(/thkr/sst) WITH <ls_kont>-gsber gc_central_map_tab.ENDIF.
            APPEND VALUE bapiret2( type = gc_msgty_e
                           id = '/THKR/SST'
                           number = 041 ) TO <ls_data>-msg.
          ELSE.
            IF 1 = 0. MESSAGE e012(/thkr/sst) WITH <ls_kont>-gsber gc_central_map_tab.ENDIF.
            APPEND VALUE bapiret2( type = gc_msgty_e
                           id = '/THKR/SST'
                           number = 012
                           message_v1 = is_curr_line-dst_old
                         message_v2 = is_curr_line-ep
                         message_v3 = gc_central_map_tab ) TO <ls_data>-msg.
*          rv_error = abap_true.
          ENDIF.
          rv_error = abap_false.
        ELSE.
          "Keine Kontierung in der Anordnung
          IF 1 = 0. MESSAGE e013(/thkr/sst) WITH <ls_kont>-gsber.ENDIF.
          "Fehlermeldung nicht in Returntab schreiben.
          "Wird in der Aktion beim Buchen der Anordung durchgeführt.
*          APPEND VALUE bapiret2( type = gc_msgty_e
*                 id = '/THKR/SST'
*                 number = 013
*                 message_v1 = 'T_KONT'
*                 message_v2 = iv_struc_name ) TO ct_return_tab.

          APPEND VALUE bapiret2( type = gc_msgty_e
                         id = '/THKR/SST'
                         number = 013
                         message_v1 = iv_struc_name ) TO <ls_data>-msg.

*          rv_error = abap_true.
          rv_error = abap_false.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD check_bukrs_for_ao_sab.
    "Fehlermeldung an Anordnung anhängen
    READ TABLE ct_data WITH KEY glblid = is_curr_line-glblid
                        ASSIGNING FIELD-SYMBOL(<ls_data>).

    "Buchungskreis direkt auf AO-Ebene
    IF is_curr_line-bukrs IS NOT INITIAL.
      rv_error = check_bukrs_exists(
                   EXPORTING
                     iv_bukrs      = is_curr_line-bukrs                  " Buchungskreis
                   CHANGING
                     ct_return_tab = ct_return_tab                  " Tabellentyp für BAPIRET2
                 ).
      APPEND LINES OF ct_return_tab TO <ls_data>-msg.
    ELSE.

      IF sy-subrc = 0.
        "Geschäftsbereich = Dienststelle
        READ TABLE is_curr_line-t_kont ASSIGNING FIELD-SYMBOL(<ls_kont>) INDEX 1.
        IF sy-subrc = 0.
          IF 1 = 0. MESSAGE e012(/thkr/sst) WITH <ls_kont>-gsber gc_central_map_tab.ENDIF.
          APPEND VALUE bapiret2( type = gc_msgty_e
                           id = '/THKR/SST'
                           number = 012
                           message_v1 = is_curr_line-dst_old
                       message_v2 = is_curr_line-ep
                       message_v3 = gc_central_map_tab ) TO ct_return_tab.

          APPEND VALUE bapiret2( type = gc_msgty_e
                         id = '/THKR/SST'
                         number = 012
                         message_v1 = is_curr_line-dst_old
                       message_v2 = is_curr_line-ep
                       message_v3 = gc_central_map_tab ) TO <ls_data>-msg.
          rv_error = abap_true.

        ELSE.
          "Keine Kontierung in der Anordnung
          IF 1 = 0. MESSAGE e013(/thkr/sst) WITH 'T_KONT' iv_struc_name.ENDIF.
          APPEND VALUE bapiret2( type = gc_msgty_e
                 id = '/THKR/SST'
                 number = 013
                 message_v1 = 'T_KONT'
                 message_v2 = iv_struc_name ) TO ct_return_tab.

          APPEND VALUE bapiret2( type = gc_msgty_e
                         id = '/THKR/SST'
                         number = 013
                         message_v1 = iv_struc_name ) TO <ls_data>-msg.

          rv_error = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD check_bukrs_for_gp.
    "Fehlermeldung an Geschäftspartner anhängen
    READ TABLE ct_data WITH KEY bu_bpext = is_curr_line-bu_bpext
                        ASSIGNING FIELD-SYMBOL(<ls_data>).

    "Es gibt immer nur einen Datensatz im Debitorenstammsatz
    READ TABLE is_curr_line-customer-t_customer_company ASSIGNING FIELD-SYMBOL(<ls_company>) INDEX 1.
    IF sy-subrc = 0.
      IF <ls_company>-bukrs IS INITIAL.
        IF 1 = 0. MESSAGE e012(/thkr/sst) WITH is_curr_line-/thkr/gsber gc_central_map_tab.ENDIF.
        APPEND VALUE bapiret2( type = gc_msgty_e
                         id = '/THKR/SST'
                         number = 012
                         message_v1 = is_curr_line-dst_old
                         message_v2 = is_curr_line-ep
                         message_v3 = gc_central_map_tab ) TO ct_return_tab.
        rv_error = abap_true.
      ELSE.
        rv_error = check_bukrs_exists(
                     EXPORTING
                       iv_bukrs      = <ls_company>-bukrs                 " Buchungskreis
                     CHANGING
                       ct_return_tab = ct_return_tab                 " Tabellentyp für BAPIRET2
                   ).
        APPEND LINES OF ct_return_tab TO <ls_data>-msg.

      ENDIF.

    ELSE.
      "Kein Debitorenstammsatz mit Buchungskreis.
      IF 1 = 0. MESSAGE e013(/thkr/sst) WITH 'T_CUSTOMER_COMPANY' 'CUSTOMER'. ENDIF.
      APPEND VALUE bapiret2( type = gc_msgty_e
                 id = '/THKR/SST'
                 number = 013
                 message_v1 = 'T_CUSTOMER_COMPANY'
                 message_v2 = 'CUSTOMER' ) TO ct_return_tab.


      IF sy-subrc = 0.
        APPEND VALUE bapiret2( type = gc_msgty_e
                 id = '/THKR/SST'
                 number = 013
                 message_v1 = 'T_CUSTOMER_COMPANY'
                 message_v2 = 'CUSTOMER' ) TO <ls_data>-msg.
      ENDIF.

      rv_error = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD check_bukrs_for_mv.
    READ TABLE ct_data WITH KEY glblid = is_curr_line-glblid ASSIGNING FIELD-SYMBOL(<ls_mv>).

    "Buchungskreis direkt auf AO-Ebene
    IF is_curr_line-bukrs IS NOT INITIAL.
      rv_error = check_bukrs_exists(
                   EXPORTING
                     iv_bukrs      = is_curr_line-bukrs                 " Buchungskreis
                   CHANGING
                     ct_return_tab = ct_return_tab                 " Tabellentyp für BAPIRET2
                 ).

      APPEND LINES OF ct_return_tab TO <ls_mv>-msg.
    ELSE.
      "Geschäftsbereich = Dienststelle

      IF sy-subrc = 0.
        READ TABLE is_curr_line-t_kont ASSIGNING FIELD-SYMBOL(<ls_kont>) INDEX 1.
        IF sy-subrc = 0.
          IF 1 = 0. MESSAGE e012(/thkr/sst) WITH <ls_kont>-gsber gc_central_map_tab. ENDIF.
          APPEND VALUE bapiret2( type = gc_msgty_e
                           id = '/THKR/SST'
                           number = 012
                           message_v1 = is_curr_line-dst_old
                       message_v2 = is_curr_line-ep
                       message_v3 = gc_central_map_tab ) TO ct_return_tab.
          APPEND VALUE bapiret2( type = gc_msgty_e
                           id = '/THKR/SST'
                           number = 012
                           message_v1 = is_curr_line-dst_old
                       message_v2 = is_curr_line-ep
                       message_v3 = gc_central_map_tab ) TO <ls_mv>-msg.
          rv_error = abap_true.
        ELSE.
          "Keine Kontierung in der Mittelbindung
          IF 1 = 0. MESSAGE e013(/thkr/sst) WITH 'T_KONT' iv_struc_name. ENDIF.
          APPEND VALUE bapiret2( type = gc_msgty_e
                 id = '/THKR/SST'
                 number = 013
                 message_v1 = 'T_KONT'
                 message_v2 = iv_struc_name ) TO ct_return_tab.
          APPEND VALUE bapiret2( type = gc_msgty_e
                           id = '/THKR/SST'
                           number = 013
                           message_v1 = ''
                           message_v2 = gc_central_map_tab ) TO <ls_mv>-msg.
          rv_error = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD check_bukrs_for_vr.
    READ TABLE ct_data WITH KEY glblid = is_curr_line-glblid ASSIGNING FIELD-SYMBOL(<ls_vr>).
    "Buchungskreis direkt auf AO-Ebene
    IF is_curr_line-bukrs IS NOT INITIAL.
      rv_error = check_bukrs_exists(
                   EXPORTING
                     iv_bukrs      = is_curr_line-bukrs                 " Buchungskreis
                   CHANGING
                     ct_return_tab = ct_return_tab                 " Tabellentyp für BAPIRET2
                 ).
      APPEND LINES OF ct_return_tab to <ls_vr>-msg.
    ELSE.
      "Geschäftsbereich = Dienststelle
      IF 1 = 0. MESSAGE e012(/thkr/sst) WITH '' gc_central_map_tab. ENDIF.
      APPEND VALUE bapiret2( type = gc_msgty_e
                       id = '/THKR/SST'
                       number = 012
                       message_v1 = is_curr_line-dst_old
                       message_v2 = is_curr_line-ep
                       message_v3 = gc_central_map_tab ) TO ct_return_tab.

      IF sy-subrc = 0.
        APPEND VALUE bapiret2( type = gc_msgty_e
                       id = '/THKR/SST'
                       number = 012
                       message_v1 = is_curr_line-dst_old
                       message_v2 = is_curr_line-ep
                       message_v3 = gc_central_map_tab ) TO <ls_vr>-msg.
      ENDIF.
      rv_error = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD check_bukrs_is_initial.

    DATA: lo_struc     TYPE REF TO cl_abap_structdescr.

    ASSIGN is_curr_line  TO FIELD-SYMBOL(<ls_curr_line>).


    lo_struc ?= cl_abap_structdescr=>describe_by_data( <ls_curr_line> ).
    DATA(lv_offset) = strlen( lo_struc->absolute_name ) - 6.

    CASE lo_struc->absolute_name+6(lv_offset).
      WHEN: '/THKR/S_AIF_SAP_GP'.
        "Prüfung für Geschäftspartner
        rv_error = check_bukrs_for_gp(
                     EXPORTING
                       is_curr_line  = is_curr_line                 " AIF SAP Struktur für Geschäftspartner
                       iv_struc_name = 'GP'                 " Name des Dictionary Typs
                     CHANGING
                       ct_return_tab = ct_return_tab                 " Tabellentyp für BAPIRET2
                       ct_data = ct_data
                   ).
      WHEN: '/THKR/S_AIF_SAP_AO'.
        "Prüfung für Anordnung
        rv_error = check_bukrs_for_ao(
                     EXPORTING
                       is_curr_line  = is_curr_line                 " AIF SAP Struktur für Anordnungen
                       iv_struc_name = 'AO'                 " Name des Dictionary Typs
                     CHANGING
                       ct_return_tab = ct_return_tab                 " Tabellentyp für BAPIRET2
                       ct_data = ct_data
                   ).

      WHEN: '/THKR/S_AIF_SAP_AO_SAB'.
        "Prüfung für Anordnung (Sollabgang)
        rv_error = check_bukrs_for_ao_sab(
                     EXPORTING
                       is_curr_line  = is_curr_line                   " AIF SAP Struktur für Anordnungen
                       iv_struc_name = 'AO_SAB'                 " Name des Dictionary Typs
                     CHANGING
                       ct_return_tab = ct_return_tab                 " Tabellentyp für BAPIRET2
                       ct_data = ct_data
                   ).

      WHEN: '/THKR/S_AIF_SAP_MV'.
        "Prüfung für Mittelvormerkung
        rv_error = check_bukrs_for_mv(
                     EXPORTING
                       is_curr_line  = is_curr_line                  " AIF SAP Struktur für Geschäftspartner
                       iv_struc_name = 'MB'                 " Name des Dictionary Typs
                     CHANGING
                       ct_return_tab = ct_return_tab                 " Tabellentyp für BAPIRET2
                       ct_data = ct_data
                   ).

      WHEN: '/THKR/S_AIF_SAP_VR'.
        "Prüfung für Verrechnungsanordnung
        rv_error = check_bukrs_for_vr(
                     EXPORTING
                       is_curr_line  = is_curr_line                 " AIF SAP Struktur für Geschäftspartner
                       iv_struc_name = 'VR'                 " Name des Dictionary Typs
                     CHANGING
                       ct_return_tab = ct_return_tab                 " Tabellentyp für BAPIRET2
                       ct_data = ct_data
                   ).
    ENDCASE.
  ENDMETHOD.


  METHOD check_mandatory_blart.

    DATA: lv_blart_ok           TYPE flag VALUE abap_false.
    DATA: lv_blart_mandatory    TYPE flag VALUE abap_false.

    DATA(lt_aif_vmap) = get_mandatory_blart( ).

    "Prüfung, ob zu der eigenen Belegnummer, eine andere zwingend vorhanden sein muss
    "Prüfung über AIF-Werte-Mapping.
    IF lt_aif_vmap IS NOT INITIAL.

      LOOP AT lt_aif_vmap ASSIGNING FIELD-SYMBOL(<ls_aif_vmap>) WHERE ext_value = is_raw_line-blart.
        "Es wurde eine Belegart gefunden, die eine andere Belegart in der Datenlieferung erwartet
        lv_blart_mandatory = abap_true.
        LOOP AT is_raw_struc-values-items ASSIGNING FIELD-SYMBOL(<ls_item>).
        "Prüfen, ob zwingend notwendige Belegnummer in Datenlieferung vorhanden ist.
        "Geht nur über das Urkassenzeichen.
          READ TABLE <ls_item>-lt_pso02 WITH KEY blart = <ls_aif_vmap>-int_value
                                                 zuonr = cs_dest_line-bktxt TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            " es gibt in der Datenlieferung die zwingend notwendige Belegart
            lv_blart_ok = abap_true.
            EXIT.
          ELSE.
            lv_blart_ok = abap_false.
          ENDIF.
        ENDLOOP.
        IF lv_blart_ok = abap_true.
          "Es wurde eine Belegart gefunden. Es muss nicht weiter gesucht werden.
          EXIT.
        ELSE.
          "Es wurde keine passende Belegart gefunden. Weitersuchen, ob es noch weitere Belegarten gibt, die zwingend vorhanden sein müssen.
          CONTINUE.
        ENDIF.
      ENDLOOP.
       "Schreibe Fehlermeldung, wenn eine andere zwingende Belegart in der Datenlieferung fehlt.
       "lv_blart_mandatory = abap_true & lv_blart_ok = abap_false  -> es wird eine andere zwingende Belegart erwartet, aber existiert nicht in Datenlieferung
       "lv_blart_mandatory = abap_false & lv_blart_ok = abap_false -> Es gibt keine zwingend notwendige Belegarten
      IF lv_blart_ok = abap_false and lv_blart_mandatory = abap_true.
        "Fehlermeldung wegen fehlender Belegart erzeugen
        IF 1 = 0. MESSAGE e037(/thkr/sst) WITH cs_dest_line-bktxt <ls_aif_vmap>-ext_value.ENDIF.
        APPEND VALUE bapiret2( id = '/THKR/SST'
                         number = 037
                         type = gc_msgty_e
                         message_v1 = cs_dest_line-bktxt
                         message_v2 = <ls_aif_vmap>-ext_value ) TO cs_dest_line-msg.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD check_mb_exists.

    SELECT COUNT( belnr )
      FROM kblk
     WHERE xblnr = @iv_urkass
      INTO @DATA(lv_count).
    IF sy-subrc = 0.
      IF lv_count > 0.
        rv_exists = abap_true.
      ELSE.
        rv_exists = abap_false.
      ENDIF.
    ELSE.
      rv_exists = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_process_chain.

    DATA: lo_struc     TYPE REF TO cl_abap_structdescr.

    lo_struc ?= cl_abap_structdescr=>describe_by_data( is_curr_line ).
    DATA(lv_offset) = strlen( lo_struc->absolute_name ) - 6.

    ASSIGN COMPONENT 'GP' OF STRUCTURE is_data_struc TO FIELD-SYMBOL(<lt_gp>).
    ASSIGN COMPONENT 'MB' OF STRUCTURE is_data_struc TO FIELD-SYMBOL(<lt_mb>).
    ASSIGN COMPONENT 'AO' OF STRUCTURE is_data_struc TO FIELD-SYMBOL(<lt_ao>).

    CASE lo_struc->absolute_name+6(lv_offset).
      WHEN: '/THKR/S_AIF_SAP_GP'.
        "Prüfung für Geschäftspartner
        "Nichts machen.
        RETURN.
      WHEN: '/THKR/S_AIF_SAP_MV'.
        "Prüfung für Mittelvormerkung
        "Hat keine Geschäftspartner
        "nichts machen
        RETURN.
      WHEN: '/THKR/S_AIF_SAP_AO'.
        "Prüfung für Anordnung

        "1. Prüfe Geschäftspartner
        ASSIGN COMPONENT 'AO_BPEXT' OF STRUCTURE is_curr_line TO FIELD-SYMBOL(<lv_bpext>).
        IF sy-subrc = 0 AND <lt_gp> IS ASSIGNED.
          rv_error = check_process_chain_gp(
                       EXPORTING
                         iv_bu_bpext        = <lv_bpext>                 " Geschäftspartnernummer im externen System
                         iv_business_object = gc_ao                  " Nachrichtenvariable
                         it_gp              = <lt_gp>
                       CHANGING
                         ct_return_tab      = ct_return_tab                 " Tabellentyp für BAPIRET2

                     ).
        ENDIF.
        IF rv_error = abap_false.
          "Es gab keine Fehler mit dem Geschäftspartner, gehe zur nächsten Prüfung.
          "2. Prüfe Mittelvormerkung
          ASSIGN COMPONENT 'GLBLID' OF STRUCTURE is_curr_line TO FIELD-SYMBOL(<lv_glblid>).
          IF sy-subrc = 0 AND <lt_mb> IS ASSIGNED.
            rv_error = check_process_chain_mv(
                         EXPORTING
                           iv_glblid          = <lv_glblid>                 " AIF SAP Struktur für Geschäftspartner
                           iv_business_object = gc_ao                 " Nachrichtenvariable
                           it_mv              = <lt_mb>             " Mittelvormerkung Tabellen Typ
                         CHANGING
                           ct_return_tab      = ct_return_tab                 " Tabellentyp für BAPIRET2

                       ).
          ENDIF.
        ENDIF.


      WHEN: '/THKR/S_AIF_SAP_VR'.
        "Prüfung für Verrechnungsanordnung
        "1. Prüfe Geschäftspartner
        ASSIGN COMPONENT 'VR_BPEXT' OF STRUCTURE is_curr_line TO <lv_bpext>.
        IF sy-subrc = 0 AND <lt_gp> IS ASSIGNED.
          rv_error = check_process_chain_gp(
                       EXPORTING
                         iv_bu_bpext        = <lv_bpext>                 " Geschäftspartnernummer im externen System
                         iv_business_object = gc_vr                 " Nachrichtenvariable
                         it_gp              = <lt_gp>
                       CHANGING
                         ct_return_tab      = ct_return_tab                 " Tabellentyp für BAPIRET2

                     ).
        ENDIF.
        IF rv_error = abap_false.
          "Es gab keine Fehler mit dem Geschäftspartner, gehe zur nächsten Prüfung.
          "2. Prüfe Mittelvormerkung
          ASSIGN COMPONENT 'GLBLID' OF STRUCTURE is_curr_line TO <lv_glblid>.
          IF sy-subrc = 0 AND <lt_mb> IS ASSIGNED.
            rv_error = check_process_chain_mv(
                         EXPORTING
                           iv_glblid          = <lv_glblid>                 " AIF SAP Struktur für Geschäftspartner
                           iv_business_object = gc_vr                 " Nachrichtenvariable
                           it_mv              = <lt_mb>                 " Mittelvormerkung Tabellen Typ
                         CHANGING
                           ct_return_tab      = ct_return_tab                 " Tabellentyp für BAPIRET2

                       ).
          ENDIF.
        ENDIF.
        IF rv_error = abap_false.
          "Es gab keine Fehler mit Mittelvormerkung, gehe zur nächsten Prüfung.
          "3. Prüfe Anordnung
          IF <lv_glblid> IS ASSIGNED  AND <lt_ao> IS ASSIGNED.
            rv_error = check_process_chain_ao(
                         EXPORTING
                           iv_glblid          = <lv_glblid>                 " AIF SAP Struktur für Geschäftspartner
                           iv_business_object = gc_vr                 " Nachrichtenvariable
                           it_ao              = <lt_ao>                 " Anordnung Tabellen Typ
                         CHANGING
                           ct_return_tab      = ct_return_tab                 " Tabellentyp für BAPIRET2

                       ).
          ENDIF.
        ENDIF.
    ENDCASE.
    IF ct_return_tab IS NOT  INITIAL.
      "Fehlermeldung in Verarbeitungsstruktur für Protokoll übernehmen.
      ASSIGN COMPONENT 'GLBLID' OF STRUCTURE is_curr_line TO <lv_glblid>.
      LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<ls_data>).
        ASSIGN COMPONENT 'GLBLID' OF STRUCTURE <ls_data> TO FIELD-SYMBOL(<lv_glblid_data>).
        "Finde die richtige Zeile aus der aktuellen Verarbeitung.
        "<lv_glblid> = aktuelle Verarbeitung
        "<lv_glblid_data> = Anordnungsdaten nach dem Mapping
        IF <lv_glblid> = <lv_glblid_data>.
          ASSIGN COMPONENT 'MSG' OF STRUCTURE <ls_data> TO FIELD-SYMBOL(<lt_msg>).
          <lt_msg> = ct_return_tab.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD CHECK_PROCESS_CHAIN_AO.
    Try.
      rv_error = cond /AIF/successflag( WHEN it_ao[ glblid = iv_glblid ]-ao_proc_status = 'E' then abap_true
                                        WHEN it_ao[ glblid = iv_glblid ]-ao_proc_status = 'A' then abap_true
                                        ELSE abap_false ).
      if rv_error = abap_true.
        if 1 = 0. Message e032(/THKR/SST) with gc_gp iv_business_object.endif.
        Append value bapiret2( id = '/THKR/SST'
                               number = 032
                               type = gc_msgty_e
                               message_v1 = gc_ao
                               message_v2 = iv_business_object ) to ct_return_tab.
      endif.
    catch cx_sy_itab_line_not_found.
      "Es gibt keine Mittelvormerkung.
      "Demnach auch keine Fehlermeldung.
      rv_error = abap_false.
    ENDTRY.
  ENDMETHOD.


  METHOD CHECK_PROCESS_CHAIN_GP.
    "Fehlermeldung beim Geschäftspartner prüfen
    Try.
      rv_error = cond /AIF/successflag( WHEN it_gp[ bu_bpext = iv_bu_bpext ]-bp_proc_status = 'E' then abap_true
                                        WHEN it_gp[ bu_bpext = iv_bu_bpext ]-bp_proc_status = 'A' then abap_true
                                        ELSE abap_false ).
      if rv_error = abap_true.
        if 1 = 0. Message e032(/THKR/SST) with gc_gp iv_business_object.endif.
        Append value bapiret2( id = '/THKR/SST'
                               number = 032
                               type = gc_msgty_e
                               message_v1 = gc_gp
                               message_v2 = iv_business_object ) to ct_return_tab.
      endif.
    catch cx_sy_itab_line_not_found.
      "Es gibt keinen Geschäftspartner.
      "Demnach auch keine Fehlermeldung.
      rv_error = abap_false.
    ENDTRY.
  ENDMETHOD.


  METHOD CHECK_PROCESS_CHAIN_MV.
    Try.
      rv_error = cond /AIF/successflag( WHEN it_mv[ glblid = iv_glblid ]-mv_proc_status = 'E' then abap_true
                                        WHEN it_mv[ glblid = iv_glblid ]-mv_proc_status = 'A' then abap_true
                                        ELSE abap_false ).
      if rv_error = abap_true.
        if 1 = 0. Message e032(/THKR/SST) with gc_gp iv_business_object.endif.
        Append value bapiret2( id = '/THKR/SST'
                               number = 032
                               type = gc_msgty_e
                               message_v1 = gc_mb
                               message_v2 = iv_business_object ) to ct_return_tab.
      endif.
    catch cx_sy_itab_line_not_found.
      "Es gibt keine Mittelvormerkung.
      "Demnach auch keine Fehlermeldung.
      rv_error = abap_false.
    ENDTRY.
  ENDMETHOD.


  method GET_MANDATORY_BLART.
    CONSTANTS: lc_vmap_mand_blart TYPE /aif/vmapname VALUE 'MAP_MANDATORY_BLART'.

    "Werte aus AIF-Konfig herauslesen
    "EXT_VALUE = aktuelle Belegart
    "INT_VALUE = Belegart, die zusätzlich in Datenlieferung vorhanden sein muss
    SELECT *
      FROM /aif/t_vmapval
     WHERE ns = @gc_aif_ns_zallge
       AND vmapname = @lc_vmap_mand_blart
      into TABLE @rt_vmap.
      if sy-subrc <> 0.
        clear rt_vmap.
      endif.
  endmethod.
ENDCLASS.

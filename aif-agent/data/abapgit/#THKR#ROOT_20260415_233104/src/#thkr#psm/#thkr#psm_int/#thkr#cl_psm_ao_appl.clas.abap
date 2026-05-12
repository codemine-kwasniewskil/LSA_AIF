class /THKR/CL_PSM_AO_APPL definition
  public
  create public .

public section.

  types:
    tty_pso50 TYPE TABLE OF pso50 .
  types:
    BEGIN OF ty_due_dates,
        dzfbdt TYPE  dzfbdt,
        wrbtr  TYPE  wrbtr_cs,
      END OF ty_due_dates .
  types:
    tty_due_dates         TYPE TABLE OF ty_due_dates .
  types:
    tty_fmr_interface_det TYPE TABLE OF fmr_interface_det .

  constants C_PSOTY_STUNDUNG_06 type PSOTY_D value '06' ##NO_TEXT.
  constants C_PSOTY_ERLASS_08 type PSOTY_D value '08' ##NO_TEXT.
  constants C_PSOTY_NIEDERSCHL_07 type PSOTY_D value '07' ##NO_TEXT.
  constants C_PSOTY_ANN_ABS_05 type PSOTY_D value '05' ##NO_TEXT.
  constants C_PSOTY_AUSZ_ABS_04 type PSOTY_D value '04' ##NO_TEXT.
  constants C_PSOTY_VERR_03 type PSOTY_D value '03' ##NO_TEXT.
  constants C_PSOTY_ANN_02 type PSOTY_D value '02' ##NO_TEXT.
  constants C_PSOTY_AUSZ_01 type PSOTY_D value '01' ##NO_TEXT.
  constants C_KONTO_KREDITOR type KOART value 'K' ##NO_TEXT.
  constants C_KONTO_DEBITOR type KOART value 'D' ##NO_TEXT.
  constants C_KONTO_SACH type KOART value 'S' ##NO_TEXT.
  constants C_SHKZ_S type C value 'S' ##NO_TEXT.
  constants C_SHKZ_H type C value 'H' ##NO_TEXT.

  methods CONSTRUCTOR .
  class-methods GET_INSTANCE
    returning
      value(R_INSTANCE) type ref to /THKR/CL_PSM_AO_APPL .
  methods GET_DTO_PSM_AO
    importing
      !I_LOTKZ type LOTKZ
      !I_BUKRS type BUKRS
      !I_GJAHR type GJAHR
      !I_BELNR type BELNR_D optional
    exporting
      !E_DTO type /THKR/S_DTO_PSM_AO
    returning
      value(R_DTO_PS_FM_ORDER) type /THKR/S_DTO_PSM_AO
    raising
      /THKR/CX_PSM_INT_FI .
  methods CREATE_PSM_AO_BELEG
    importing
      !I_DTO_PSM_AO_BEL_CREATE type /THKR/S_DTO_PSM_AO_BEL_CREATE
    exporting
      !E_PSM_AO_DOCUMENT_NUMBER type /THKR/S_PSM_AO_DOCUMENT_NUMBER
    raising
      /THKR/CX_PSM_INT_FI .
  methods CHANGE_PSM_AO_BELEG
    importing
      !I_DTO_PSM_AO_BEL_CHANGE type /THKR/S_DTO_PSM_AO_BEL_CHANGE
    exporting
      !E_PSM_AO_DOCUMENT_NUMBER type /THKR/S_PSM_AO_DOCUMENT_NUMBER
    raising
      /THKR/CX_PSM_INT_FI .
  methods CREATE_PSM_AO_VERRECHNUNG
    importing
      !I_PSM_AO_VERRECHNUNG type /THKR/S_DTO_PSM_AO_VERRECHNUNG
    exporting
      !E_PSM_AO_DOCUMENT_NUMBER type /THKR/S_PSM_AO_DOCUMENT_NUMBER
    raising
      /THKR/CX_PSM_INT_FI .
  methods CREATE_DUE_DATE_DEFERRAL
    importing
      !I_DTO_PSM_AO_BEL_CREATE type /THKR/S_DTO_PSM_AO_BEL_CREATE
    exporting
      !E_PSM_AO_DOCUMENT_NUMBER type /THKR/S_PSM_AO_DOCUMENT_NUMBER
    raising
      /THKR/CX_PSM_INT_FI .
protected section.

  data MV_DUE_DATE_DEFERRAL type FLAG .
  data MT_PSO50 type TTY_PSO50 .
  data MT_DUE_DATES type TTY_DUE_DATES .
  data MS_PSM_AO_DOCUMENT_NUMBER type /THKR/S_PSM_AO_DOCUMENT_NUMBER .
  data MV_KOART type KOART .
  data MV_KOART_TBNAM type TABNAME .
  data MV_SHKZG type SHKZG .
  data MV_BLART type BLART .
  data MV_BLTYP type KBLTYP .
  data MS_AO_HEADER type /THKR/S_DTO_PSM_AO_HEADER .
  data MS_AO_BELEG type /THKR/S_DTO_PSM_AO_BELEG .
  data MS_AO_PARAM type /THKR/S_DTO_PSM_AO_PARAM .
  data MV_BELNR_IN type BELNR_D .
  data MS_AO_SETTINGS type /THKR/S_DTO_PSM_AO_SETTINGS .
  data MS_AO_BELEG_KONT type /THKR/S_DTO_PSM_AO_KONT .
  data MT_AO_BELEG type /THKR/T_DTO_PSM_AO_BELEG .

  methods CHECK_COBL
    changing
      !CH_VBKPF type VBKPF
      !CH_VBSEG type VBSEG
    raising
      /THKR/CX_PSM_INT_FI .
  methods CHECK_HKONT
    changing
      !CH_KONT type /THKR/S_DTO_PSM_AO_KONT
    raising
      /THKR/CX_PSM_INT_FI .
  methods CHECK_DAUER_AO_DATES
    raising
      /THKR/CX_PSM_INT_FI .
  methods CREATE_PSM_DAUER_AO
    raising
      /THKR/CX_PSM_INT_FI .
  methods BUILD_AND_POST_PSO_DI_DATA
    raising
      /THKR/CX_PSM_INT_FI .
  methods CHANGE_PSO_DUE_DATES_DATA
    importing
      !I_DUE_DATES type TY_DUE_DATES .
  methods FI_PSO_DUE_DATES_GENERATE
    raising
      /THKR/CX_PSM_INT_FI .
  methods FI_PSO_DUE_DATE_CREATE
    importing
      !I_PSOSU_WAERS_PA type FMDY-PSOSU
      !I_PSODT_PA type PSO02-ZFBDT
      !I_SCHEMA type C
      !I_P_ANZAHL type I
      !I_INTERVALL type I
      !I_NUMBER type I
      !I_AO_HEADER type /THKR/S_DTO_PSM_AO_HEADER
    changing
      !C_FAELLIGKEIT type PSO02-ZFBDT
      !C_P_BETRAG type PSO02-WRBTR
    exceptions
      NO_INSTALMENT .
  methods CHECK_FIPEX
    importing
      !I_BSEG type FM_T_BBSEG
    raising
      /THKR/CX_PSM_INT_FI .
  methods MAP_PSOTY_DATA
    raising
      /THKR/CX_PSM_INT_FI .
  methods PSO_DOCUMENT_CHECK
    changing
      !C_BKPF type FM_T_BBKPF
      !C_BSEG type FM_T_BBSEG
      !C_BTAX type FM_T_BBTAX
    raising
      /THKR/CX_PSM_INT_FI .
  methods PSO_DOCUMENT_POST
    changing
      !C_BKPF type FM_T_BBKPF
      !C_BSEG type FM_T_BBSEG
      !C_BTAX type FM_T_BBTAX
    raising
      /THKR/CX_PSM_INT_FI .
  methods MAP_DTO_BELEG_TO_BTAX
    changing
      !C_BKPF type FM_T_BBKPF
      !C_BSEG type FM_T_BBSEG
      !C_BTAX type FM_T_BBTAX .
  methods MAP_PSO_FI_TO_DTO
    importing
      !I_HEAD type FIPSO_HEADER_TAB
      !I_VBSEG type FM_VBSEG_TAB
      !I_VBSEC type FM_VBSEC_TAB
      !I_VBSET type FM_VBSET_TAB
    returning
      value(R_DTO_PS_FM_ORDER) type /THKR/S_DTO_PSM_AO .
  methods DETERMINE_SIGN_FOR_ACC
    importing
      !I_PSOTY type PSOTY_D
      !I_KOART type KOART default 'K'
      !I_XUMVZ type PSO_XUMVZ optional
    returning
      value(R_SHKZG) type SHKZG .
  methods MAP_DTO_HDR_TO_BKPF
    changing
      !C_BKPF type FM_T_BBKPF
      !C_BSEG type FM_T_BBSEG
      !C_BTAX type FM_T_BBTAX .
  methods MAP_DTO_BELEG_TO_BSEG
    changing
      !C_BKPF type FM_T_BBKPF
      !C_BSEG type FM_T_BBSEG
      !C_BTAX type FM_T_BBTAX .
private section.

  class-data INSTANCE type ref to /THKR/CL_PSM_AO_APPL .
ENDCLASS.



CLASS /THKR/CL_PSM_AO_APPL IMPLEMENTATION.


METHOD build_and_post_pso_di_data.
*"----------------------------------------------------------------------
  DATA:
    lt_bkpf	TYPE fm_t_bbkpf,
    lt_bseg	TYPE fm_t_bbseg,
    lt_btax	TYPE fm_t_bbtax.
*"----------------------------------------------------------------------
* Aufbau FI Kopfdaten
  map_dto_hdr_to_bkpf(
    CHANGING
      c_bkpf = lt_bkpf
      c_bseg = lt_bseg
      c_btax = lt_btax
  ).
*"----------------------------------------------------------------------
* Aufbau FI Belegzeilen
* Kreditor/Debitor Zeile und Sachkontozeile
  map_dto_beleg_to_bseg(
    CHANGING
      c_bkpf = lt_bkpf
      c_bseg = lt_bseg
      c_btax = lt_btax
    ).

*"----------------------------------------------------------------------
* Aufbau FI Belegzeilen Steuern
  map_dto_beleg_to_btax(
    CHANGING
      c_bkpf = lt_bkpf
      c_bseg = lt_bseg
      c_btax = lt_btax
  ).
*"----------------------------------------------------------------------
* Check FI CREATE Data
  pso_document_check(
    CHANGING
      c_bkpf = lt_bkpf
      c_bseg = lt_bseg
      c_btax = lt_btax
  ).
*"----------------------------------------------------------------------
* Post FI Create Data
  pso_document_post(
    CHANGING
      c_bkpf = lt_bkpf
      c_bseg = lt_bseg
      c_btax = lt_btax
  ).
*"----------------------------------------------------------------------
ENDMETHOD.


  METHOD change_psm_ao_beleg.


    MOVE-CORRESPONDING i_dto_psm_ao_bel_change TO ms_ao_header.
    MOVE-CORRESPONDING i_dto_psm_ao_bel_change TO ms_ao_beleg.
    MOVE-CORRESPONDING i_dto_psm_ao_bel_change TO ms_ao_param.
    MOVE-CORRESPONDING i_dto_psm_ao_bel_change TO ms_ao_settings.
    mv_belnr_in = i_dto_psm_ao_bel_change-belnr.

* nur Vorerfasset Belege können noch geändert werden
    IF ms_ao_beleg-bstat <> 'V'.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e002(/thkr/psm_ao).
    ENDIF.

* Mapping Daten abhängig vom PSOTYP
    map_psoty_data( ).


* FI Daten aufbauen und verbuchen
    build_and_post_pso_di_data( ).


    e_psm_ao_document_number = ms_psm_ao_document_number.

  ENDMETHOD.


  METHOD change_pso_due_dates_data.

    IF i_due_dates IS INITIAL.
* Dann keine Änderng notwendig
      RETURN.
    ENDIF.

* Fälligkeitsdatum setzen
    ms_ao_beleg-zfbdt = i_due_dates-dzfbdt.

* Betrag auf Kontierung anpassen unter Beachtung Mehrfachkontierung
    DATA(lv_wrbtr) = round( val = i_due_dates-wrbtr / lines( ms_ao_beleg-t_kont ) dec = 2 ).
    LOOP AT ms_ao_beleg-t_kont ASSIGNING FIELD-SYMBOL(<fs_kont>).
      <fs_kont>-wrbtr = lv_wrbtr.
    ENDLOOP.

* Wenn zu einem Beleg schon eine AO angelegt wurden, alle weiteren Belege zu dieser AO hinzufügen
    IF ms_psm_ao_document_number IS NOT INITIAL.
      ms_ao_header-lotkz = ms_psm_ao_document_number-lotkz.
      ms_ao_header-gjahr = ms_psm_ao_document_number-gjahr.
      ms_ao_header-bukrs = ms_psm_ao_document_number-bukrs.
    ENDIF.

  ENDMETHOD.


  METHOD check_cobl.
* beim Aufruf von Dauer AO notwendig, da der Std. Baustein zur Ableitung des Profitcenter  nicht im
* SAP FUBA zur Anlage der Dauer AO aufgerufen wird

    DATA:
      ls_header   TYPE vbkpf,
      ls_position TYPE vbsegs. "Achtung s

    IF ch_vbseg-pprctr = '00000000'.
      CLEAR ch_vbseg-pprctr. " sonst kommt es zum Fehler
    ENDIF.

    MOVE-CORRESPONDING ch_vbseg TO ls_position.
    MOVE-CORRESPONDING ch_vbkpf TO ls_header.

    CALL FUNCTION 'FI_GL_ACCOUNT_MAINTAIN'
      EXPORTING
        i_position = ls_position
        i_header   = ls_header
        i_mand     = space
        i_display  = space
        i_suppress = abap_true
      IMPORTING
        e_position = ls_position
        e_header   = ls_header
      EXCEPTIONS
        cancelled  = 1
        finished   = 2
        OTHERS     = 3.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ch_vbseg-prctr = ls_position-prctr.
    ch_vbseg-measure = ls_position-measure.

  ENDMETHOD.


  METHOD check_dauer_ao_dates.

* Prüfungen analog  Dialog LF0KGI01 MODULE (PAI)    / DAUERBUCHUNG_PRUEFEN

    DATA:
      lv_monat_period TYPE t001b-frpe1,
      lv_monat        TYPE pso02-monat,
      lv_gjahr        TYPE pso02-gjahr.

    IF  ms_ao_settings-dbbdt IS INITIAL.
      ms_ao_settings-dbbdt = '00000000'.
    ENDIF.
    IF  ms_ao_settings-dbedt IS INITIAL.
      ms_ao_settings-dbedt = '00000000'.
    ENDIF.

    " Datumsangaben pruefen
    CALL FUNCTION 'FI_PERIOD_DETERMINE'
      EXPORTING
        i_budat        = ms_ao_settings-dbbdt
        i_bukrs        = ms_ao_header-bukrs
      IMPORTING
        e_gjahr        = lv_gjahr
        e_monat        = lv_monat
      EXCEPTIONS
        fiscal_year    = 1
        period         = 2
        period_version = 3
        posting_period = 4
        special_period = 5
        version        = 6
        posting_date   = 7
        OTHERS         = 8.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi USING MESSAGE.
    ENDIF.

    lv_monat_period  = lv_monat.                 "damit Typ stimmt

    CALL FUNCTION 'FI_PERIOD_CHECK'
      EXPORTING
        i_bukrs = ms_ao_header-bukrs
        i_gjahr = lv_gjahr
        i_koart = '+'
        i_konto = '+'
        i_monat = lv_monat_period
      EXCEPTIONS
        OTHERS  = 4.

    " Vergangene Periode: Periode muß jetzt noch geöffnet sein
    IF ms_ao_settings-dbbdt < sy-datlo.
      IF sy-subrc NE 0.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID 'F5' NUMBER 454.
      ENDIF.
    ENDIF.

    " Letzte Ausführung liegt vor der ersten Ausführung,
    IF ms_ao_settings-dbedt LT ms_ao_settings-dbbdt.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID 'F5' NUMBER 315.
    ENDIF.
    "Abrechnungskennzeichen oder Monate und Tag angegeben? ---------
    IF ms_ao_settings-dbakz NE space AND ( ms_ao_settings-dbtag > '00' OR ms_ao_settings-dbmon > '00' ).
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID 'F5' NUMBER 447.
    ENDIF.
    IF ms_ao_settings-dbakz EQ space AND ms_ao_settings-dbtag LE '00' AND ms_ao_settings-dbmon LE '00'.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID 'F5' NUMBER 447.
    ENDIF.
    IF ms_ao_settings-dbmon LE '00' AND ms_ao_settings-dbtag GT '00'.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID 'F5' NUMBER 449.
    ENDIF.


  ENDMETHOD.


  METHOD check_fipex.

    DATA:
      lv_year_check TYPE gjahr,
      lv_date_check TYPE budat,
      ls_t001       TYPE t001,
      lt_return     TYPE bapiret2_t.

* Aktuell wird im SAP STD. im FI_PSO_DOC_DIRECT_INPUT bei der FIPEX Prüfung
* die Exception nicht abgefangen. Dadurch werden Fehlermeldungen direkt ausgegeben.
* Um das zu vermeiden hier zusätzlich die Prüfung.

* Analog Dialog FORM posting_address in LF0KEF02
*       determine the correct year & date for checkings.
    IF ms_ao_param-recurring IS INITIAL.
      lv_year_check = ms_ao_header-gjahr.
      lv_date_check = ms_ao_beleg-budat.
    ELSE.
*         get the right year & date for SR from "next run date"
      lv_date_check = ms_ao_settings-dbatr.
      CALL FUNCTION 'FI_PERIOD_DETERMINE'
        EXPORTING
          i_budat = ms_ao_settings-dbatr
          i_bukrs = ms_ao_header-bukrs
        IMPORTING
          e_gjahr = lv_year_check
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc <> 0.
        APPEND VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                        message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ) TO lt_return.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          EXPORTING bapiret2_tab = lt_return.
      ENDIF.
    ENDIF.

*   get fikrs:
    CALL FUNCTION 'COMPANY_CODE_READ'
      EXPORTING
        i_bukrs = ms_ao_header-bukrs
      IMPORTING
        e_t001  = ls_t001.
    DATA(lv_fikrs) = ls_t001-fikrs.

    LOOP AT i_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>) WHERE fipex IS NOT INITIAL.

      IF <fs_bseg>-fipex IS NOT INITIAL.
        CALL FUNCTION 'FM_FIPEX_READ_SINGLE_DATA'
          EXPORTING
            i_fikrs                  = lv_fikrs
            i_gjahr                  = lv_year_check
            i_fipex                  = <fs_bseg>-fipex
          EXCEPTIONS
            master_data_not_found    = 1
            hierarchy_data_not_found = 2
            input_error              = 3
            OTHERS                   = 4.
        IF sy-subrc <> 0.
          APPEND VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                          message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ) TO lt_return.
          RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            EXPORTING bapiret2_tab = lt_return.
        ENDIF.
      ENDIF.

      IF <fs_bseg>-fistl IS NOT INITIAL.
        CALL FUNCTION 'FMFCTR_READ_QUICK'
          EXPORTING
            ip_fikrs              = lv_fikrs
            ip_fictr              = <fs_bseg>-fistl
            ip_date               = lv_date_check
            ip_gjahr              = lv_year_check
            ip_flg_buffer_all     = abap_true
          EXCEPTIONS
            master_data_not_found = 1
            input_error           = 2
            OTHERS                = 3.
        IF sy-subrc <> 0.
          APPEND VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                          message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ) TO lt_return.
          RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            EXPORTING bapiret2_tab = lt_return.
        ENDIF.
      ENDIF.

      IF <fs_bseg>-geber IS NOT INITIAL.
        CALL FUNCTION 'FINCODE_READ'
          EXPORTING
            ip_fikrs              = lv_fikrs
            ip_fincode            = <fs_bseg>-geber
            ip_date               = lv_date_check
            ip_gjahr              = lv_year_check
          EXCEPTIONS
            customer_invalid      = 1
            input_error           = 2
            master_data_not_found = 3
            finuse_not_defined    = 4
            date_not_found        = 5
            OTHERS                = 6.
        IF sy-subrc <> 0.
          APPEND VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                          message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ) TO lt_return.
          RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            EXPORTING bapiret2_tab = lt_return.
        ENDIF.
      ENDIF.

    ENDLOOP.




  ENDMETHOD.


  METHOD check_hkont.
* beim Aufruf von Dauer AO notwendig, da der Std. Baustein zur Ableitung des Sachkonto nicht im
* SAP FUBA zur Anlage der Dauer AO aufgerufen wird
    " Aufruf THKR Baustein wegen Popup unterdrückung in SST/Mig
    IF ch_kont-hkont IS INITIAL.

      CALL FUNCTION '/THKR/MIG_FI_FM_ACCOUNT_DETERM'
        EXPORTING
          i_gjahr                 = ms_ao_beleg-budat+0(4)
          i_bukrs                 = ms_ao_header-bukrs
          i_fipex                 = ch_kont-fipex
        IMPORTING
          e_saknr                 = ch_kont-hkont
        EXCEPTIONS
          account_not_found       = 1
          account_free_assignable = 2
          account_not_possible    = 3
          fipex_multible_saknr    = 4
          OTHERS                  = 5.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
          MESSAGE ID sy-msgid NUMBER sy-msgno
          EXPORTING
            bapiret2 = VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                                message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ).
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD CONSTRUCTOR.
  ENDMETHOD.


METHOD create_due_date_deferral.
*"----------------------------------------------------------------------
* Herausforderung bei der Ratenstundung
* wird der Betrag auf mehrere Belege in eine Anordnung übernommen
* Pro Aufteilung wird eine PSO Zeile/Beleg erzeugt, Feld Basisdatum  PSO02-ZFBDT steht die jeweilige Fälligkeit
* Anpassungen in den verwendeten Buchungsbausteinen /THKR/FI_PSO_DOC_DIRECT_INPUT notwendig


* Es wird in den Schritten vorgegangen
* 1. Fälligkeiten berechnen
* 2. Buchungsdaten Daten pro Fälligkeit aufbauen


  MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ms_ao_header.
  MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ms_ao_beleg.
  MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ms_ao_param.
  MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ms_ao_settings.
  mv_belnr_in = i_dto_psm_ao_bel_create-belnr.

  "Es gibt Fremdverfahren, die vorerasste Belege liegern.
  "Da darf es kein 4-Augen-Prinzip geben. Direkt buchen.
  " CLEAR ms_ao_param-psoxb. " nur vorerfassen ohne Freigabe, sonst Fehler bei Freigabeprüfung 4-Augen
*"----------------------------------------------------------------------
*PSOAC Ratenbetrag oder PSOMO	Anzahl der Raten muss gefüllt sein
*PSODT 1. Fälligkeitstag und PSOIN  Intervall zw. Raten in Monaten muss gefüllt sein
  IF ms_ao_settings-psoac IS INITIAL AND
     ms_ao_settings-psomo IS INITIAL OR
     ms_ao_settings-psodt IS INITIAL OR
     ms_ao_settings-psoin IS INITIAL.
    RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE e003(/thkr/psm_ao).
  ENDIF.
*"----------------------------------------------------------------------
* Methode nur für Ratenstundung zu verwenden
  IF ms_ao_header-psoty <> c_psoty_stundung_06.
    RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE e004(/thkr/psm_ao).
  ENDIF.

  mv_due_date_deferral = abap_true.
*"----------------------------------------------------------------------
* Mapping Daten abhängig vom PSOTYP
  map_psoty_data( ).
*"----------------------------------------------------------------------
  "Prüfung, ob Fälligkeiten berechnet oder übernommen werden
  " gen_due_date = abap_true -> Fälligkeiten berechnen
  " gen_due_date = abap_false -> Fälligkeiten übernehmen
  IF i_dto_psm_ao_bel_create-gen_due_date = abap_true.

* ermittle Fälligkeiten und Werte pro Fälligkeit
    fi_pso_due_dates_generate( ).
  ELSE.
    IF i_dto_psm_ao_bel_create-t_due_date IS INITIAL.
      "Raten sollen nicht gebildet werden, sondern übernommen werden.
      "Es wurden aber keine Raten übergeben.
      fi_pso_due_dates_generate( ).
    ELSE.
      "Datum und Rate kommen vom Fremdverfahren. Einfach übernehmen.
      mt_due_dates = i_dto_psm_ao_bel_create-t_due_date.
    ENDIF.

  ENDIF.
*"----------------------------------------------------------------------
  LOOP AT mt_due_dates ASSIGNING FIELD-SYMBOL(<fs_due_date>).
    " seze Betrag und Fälligkeit für aktuellen Beleg
    change_pso_due_dates_data( i_due_dates = <fs_due_date> ).

    " Buche Daten
    build_and_post_pso_di_data( ).

  ENDLOOP.
*  ELSE.
**Polizei liefert Buchungszeilen. Eine Berechnung der Fälligkeit führt zu Abweichungen.
** übernehme Daten der Polizei.
*
*
*    "Merke T_KONT
*    DATA(lt_t_kont) =  ms_ao_beleg-t_kont.
*
*    LOOP AT lt_t_kont ASSIGNING FIELD-SYMBOL(<ls_t_cont>).
*      "Es darf immer nur eine Zeile in T_KONT verbucht werden.
*      "Lösche T_KONT und füge immer nur eine Zeile hinzu
*      CLEAR ms_ao_beleg-t_kont.
*      "Datum Fälligkeit in ZUONR gespeichert.
*      "Wird beim Verbuchen nicht benötigt. Wieder Löschen.
*      ms_ao_beleg-zfbdt = <ls_t_cont>-zuonr.
*      CLEAR <ls_t_cont>-zuonr.
*      APPEND <ls_t_cont> TO ms_ao_beleg-t_kont.
*      IF ms_psm_ao_document_number IS NOT INITIAL.
*        ms_ao_header-lotkz = ms_psm_ao_document_number-lotkz.
*        ms_ao_header-gjahr = ms_psm_ao_document_number-gjahr.
*        ms_ao_header-bukrs = ms_psm_ao_document_number-bukrs.
*      ENDIF.
*      " Buche Daten
*      build_and_post_pso_di_data( ).
*    ENDLOOP.
*
*  ENDIF.
*"----------------------------------------------------------------------
  e_psm_ao_document_number = ms_psm_ao_document_number.
*"----------------------------------------------------------------------
ENDMETHOD.


  METHOD create_psm_ao_beleg.


    MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ms_ao_header.
    MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ms_ao_beleg.
    MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ms_ao_param.
    MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ms_ao_settings.
    mv_belnr_in = i_dto_psm_ao_bel_create-belnr.



* Mapping Daten abhängig vom PSOTYP
    map_psoty_data( ).


* FI Daten aufbauen und verbuchen
    IF ms_ao_param-recurring = abap_true.
      " Daueranordnung buchen
      create_psm_dauer_ao( ).
    ELSE.

      " AO normal buchen
      build_and_post_pso_di_data( ).

    ENDIF.

    e_psm_ao_document_number = ms_psm_ao_document_number.

  ENDMETHOD.


  METHOD CREATE_PSM_AO_VERRECHNUNG.


    MOVE-CORRESPONDING i_psm_ao_verrechnung TO ms_ao_header.
    MOVE-CORRESPONDING i_psm_ao_verrechnung TO ms_ao_beleg.
    MOVE-CORRESPONDING i_psm_ao_verrechnung-t_sender_kont TO ms_ao_beleg-t_kont.
    MOVE-CORRESPONDING i_psm_ao_verrechnung TO ms_ao_beleg_kont.
    MOVE-CORRESPONDING i_psm_ao_verrechnung TO ms_ao_param.
    MOVE-CORRESPONDING i_psm_ao_verrechnung TO ms_ao_settings.
    mv_belnr_in = i_psm_ao_verrechnung-belnr.



* Mapping Daten abhängig vom PSOTYP
    map_psoty_data( ).


* FI Daten aufbauen und verbuchen
    build_and_post_pso_di_data( ).


    e_psm_ao_document_number = ms_psm_ao_document_number.

  ENDMETHOD.


  METHOD create_psm_dauer_ao.
    DATA:
      lv_fipos  TYPE fipos,
      lt_return TYPE bapiret2_t,
      lt_mesg   TYPE tsmesg.

    DATA:
      ls_pso52        TYPE pso52,
      lv_bschl        TYPE pso02-bschl,
      c_xprfg         TYPE  boole-boole VALUE 'X',
      c_check         TYPE  boole-boole VALUE 'X',
      c_save          TYPE  boole-boole VALUE 'X',
      c_xfrge         TYPE  boole-boole,
      lt_item_old     TYPE TABLE OF pso02s,
      lt_pssec        TYPE fipso_bsec_tab,
      lt_pssec_old    TYPE fipso_bsec_tab,
      lt_fieldmod     TYPE fipso_t_fieldmod,
      lt_vbkpf        TYPE TABLE OF vbkpf,
      lt_vbkpf_old    TYPE TABLE OF vbkpf,
      lt_vbseg        TYPE TABLE OF vbseg,
      lt_vbseg_old    TYPE TABLE OF vbseg,
      lt_vbsec        TYPE TABLE OF vbsec,
      lt_vbsec_old    TYPE TABLE OF vbsec,
      lt_vbset        TYPE TABLE OF vbset,
      lt_vbset_old    TYPE TABLE OF vbset,
      lv_tax_mode     TYPE c,
      lv_count        TYPE  sy-tabix,
      lv_max_severity TYPE  sy-subrc,
      lv_subrc_check  TYPE sy-subrc,
      ls_pso          TYPE pso02,
      ls_pso_old      TYPE pso02,
      lt_pso          TYPE TABLE OF  pso02, " l_t_pso       LIKE pso02 OCCURS   0 WITH HEADER LINE,
      lt_pso_old      TYPE TABLE OF  pso02,
      ls_pssec        TYPE  fipso_bsec,
      ls_pssec_old    TYPE  fipso_bsec,
      lt_item         TYPE TABLE OF  pso02s.

* Prüfung ob die Daueranordnungsspezifischen Daten gefüllt sind
    check_dauer_ao_dates( ).



    DATA(lv_wrbtr) =  CONV wrbtr( REDUCE #( INIT x TYPE wrbtr FOR wa IN ms_ao_beleg-t_kont NEXT x += wa-wrbtr ) + ms_ao_beleg-wmwst ).

    CALL FUNCTION 'MESSAGES_INITIALIZE'.

    CALL FUNCTION 'FI_PERIOD_DETERMINE'
      EXPORTING
        i_budat = ms_ao_beleg-budat
        i_bukrs = ms_ao_header-bukrs
      IMPORTING
        e_gjahr = ms_ao_header-gjahr
        e_monat = ms_ao_beleg-monat.

* Buchungsschlüssel
    CALL FUNCTION 'FI_PSO_POSTING_KEY_DETERMINE'
      EXPORTING
        i_koart = mv_koart
        i_umskz = ''
        i_shkzg = mv_shkzg
      CHANGING
        c_bschl = lv_bschl.

* Strukturen füllen
    ls_pso = VALUE #(
       mandt   = sy-mandt
       itabkey = 1
       ausbk   = ms_ao_header-bukrs
       bukrs   = ms_ao_header-bukrs
*     BELNR
       gjahr   = ms_ao_header-gjahr
       bstat   = 'V'
       blart   = ms_ao_beleg-blart
       bldat   = ms_ao_beleg-bldat
       budat   = ms_ao_beleg-budat
       monat   = ms_ao_beleg-monat
       usnam   = sy-uname
       tcode   = COND tcode( WHEN ms_ao_header-psoty = c_psoty_ausz_01 THEN 'F8Q1' WHEN ms_ao_header-psoty = c_psoty_ann_02 THEN 'F8Q2' )
       xblnr   = ms_ao_beleg-xblnr
       bktxt   = ms_ao_beleg-bktxt
       fikrs   = '1000'
       xbwae   = abap_true
       waers   = ms_ao_header-waers
       hwaer   = ms_ao_header-waers
       zlsch   = ms_ao_beleg-zlsch
       buzei   = '001'
       bzkey   = '000'
       koart   = mv_koart
       bzalt   = '000'
       bschl   = lv_bschl
       shkzg   = mv_shkzg "'H' "Ann S
       gsber   = ms_ao_beleg-t_kont[ 1 ]-gsber
       mwskz   = ms_ao_beleg-mwskz
       kursf   = 1
       wrbtr   = lv_wrbtr
       dmbtr   = lv_wrbtr
       hkont   = ms_ao_beleg-t_kont[ 1 ]-hkont
       kunnr   = COND #( WHEN     mv_koart           = c_konto_debitor THEN ms_ao_beleg-partner )
       lifnr   = COND #( WHEN     mv_koart           = c_konto_kreditor THEN ms_ao_beleg-partner )
       bvtyp   = ms_ao_beleg-bvtyp
       maber   = ms_ao_beleg-maber
       psofn   = ms_ao_beleg-psofn
       psoty   = ms_ao_header-psoty
       swaer   = ms_ao_header-waers
       dbmon   = ms_ao_settings-dbmon
       dbtag   = ms_ao_settings-dbtag
       dbbdt   = ms_ao_settings-dbbdt
       dbatr   = ms_ao_settings-dbatr
       dbedt   = ms_ao_settings-dbedt
       xdelt   = ms_ao_settings-xdelt
       dbzhl   = ms_ao_settings-dbzhl
       dbakz   = ms_ao_settings-dbakz
    ).



*   is it necessary to create a earmarked funds?
    CALL FUNCTION 'FI_PSO_PSO52_READ'
      EXPORTING
        i_bukrs   = ms_ao_header-bukrs
        i_blart   = ms_ao_beleg-blart
      IMPORTING
        e_f_pso52 = ls_pso52
      EXCEPTIONS
        not_found = 1.

    IF sy-subrc <> 0.
      CLEAR ls_pso52.
    ENDIF.


    DATA(lv_shkzg) = mv_shkzg.

    CALL FUNCTION 'FI_PSO_SHKZG_INVERS'
      CHANGING
        c_shkzg = lv_shkzg.

* Buchungsschlüssel 2 immer Sachkonto
    CALL FUNCTION 'FI_PSO_POSTING_KEY_DETERMINE'
      EXPORTING
        i_koart = c_konto_sach
        i_umskz = ''
        i_shkzg = lv_shkzg
      CHANGING
        c_bschl = lv_bschl.



    LOOP AT ms_ao_beleg-t_kont INTO DATA(ls_kont).
      CALL FUNCTION 'FI_PSO_FIPOS_GET_FROM_FIPEX'
        EXPORTING
          i_fipex = ls_kont-fipex
        IMPORTING
          e_fipos = lv_fipos.


      check_hkont( CHANGING ch_kont = ls_kont ).
      APPEND VALUE #(
        mandt   = sy-mandt
        lotkz   = ms_ao_header-lotkz
        bukrs   = ms_ao_header-bukrs
        itabkey = sy-tabix
        gjahr   = ms_ao_header-gjahr
        bzkey   = sy-tabix
        ausbk   = ms_ao_header-bukrs
        buzei   = sy-tabix + 1
        bschl   = lv_bschl
        shkzg   = lv_shkzg
        sgtxt   = ls_kont-sgtxt
        gsber   = ls_kont-gsber
        mwskz   = ls_kont-mwskz
        wrbtr   = ls_kont-wrbtr
        dmbtr   = ls_kont-wrbtr
        kokrs   = '1000'
        kostl   = ls_kont-kostl
        aufnr   = ls_kont-aufnr
        pprctr  = ls_kont-ps_psp_pnr
        saknr   = ls_kont-hkont
*    PRCTR = ''
        fipos   = lv_fipos
        koart   = c_konto_sach
        swaer   = ms_ao_header-waers
        geber   = ls_kont-geber
        fistl   = ls_kont-fistl
        fkber   = ls_kont-fkber
        fipex   = ls_kont-fipex
        measure = ls_kont-measure
      ) TO lt_item.
    ENDLOOP.

    APPEND ls_pso TO lt_pso.

* Daten nur prüfen
    CALL FUNCTION 'FI_PSO_WHOLE_ORDER_PRE_CHECK'
      EXPORTING
        i_okcode      = 'CHEC'
        i_psotyp      = ms_ao_header-psoty
        i_who_activ   = VALUE pso43( )
        i_xonlycom    = space
        i_recurring   = abap_true
      TABLES
        u_t_pso       = lt_pso
        u_t_item      = lt_item
        u_t_pssec     = lt_pssec
      EXCEPTIONS
        error_message = 1.
    IF sy-subrc = 1.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE e001(/thkr/psm_ao) WITH sy-msgid sy-msgno sy-msgv1 sy-msgv2.
    ENDIF.


* Daten prüfen und BKPF und BESEG Tabellen füllen
    CALL FUNCTION 'FI_PSO_ORDER_CHECK'
      EXPORTING
        i_psosu_pa       = 0
        i_okcode         = 'VOLL'
        i_psotyp         = ms_ao_header-psoty
        i_who_activ      = VALUE pso43( psoet = abap_true addfields = abap_true uname = sy-uname )
        i_xonlycom       = '' "automatisch genehmigen
        i_psoxb          = ms_ao_param-psoxb
        i_recurring      = abap_true "(X) = Daueranordnung
        i_psotm          = ls_pso-psotm
        i_psodt          = ls_pso-psodt
        i_tax_mode       = 'B'
        i_f_pso52        = ls_pso52
      IMPORTING
        e_subrc_check    = lv_subrc_check
      TABLES
        u_t_pso_old      = lt_pso_old "
        u_t_item         = lt_item
        u_t_item_old     = lt_item_old
        u_t_pssec        = lt_pssec
        u_t_pssec_old    = lt_pssec_old
        u_t_fieldmod     = lt_fieldmod
        e_t_vbkpf        = lt_vbkpf
        e_t_vbkpf_old    = lt_vbkpf_old
        e_t_vbseg        = lt_vbseg
        e_t_vbseg_old    = lt_vbseg_old
        e_t_vbsec        = lt_vbsec
        e_t_vbsec_old    = lt_vbsec_old
        e_t_vbset        = lt_vbset
        e_t_vbset_old    = lt_vbset_old
*       u_t_with         = u_t_with
      CHANGING
        c_f_pso          = ls_pso
        c_f_pso_old      = ls_pso_old
        c_xprfg          = c_xprfg
        c_check          = c_check
        c_save           = c_save
        c_xfrge          = c_xfrge
      EXCEPTIONS
        vbkpf_not_filled = 1
        error_message    = 2
        OTHERS           = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE e001(/thkr/psm_ao) WITH sy-msgid sy-msgno sy-msgv1 sy-msgv2.
    ENDIF.


* Sachkontozeilen extra Prüfungen notwendig
    LOOP AT lt_vbseg ASSIGNING FIELD-SYMBOL(<fs_vbseg>) WHERE koart = c_konto_sach.
* COBL Prüfung und Ableitung Profitenter wird im Std. Baustein der Dauer AO nicht automatisch aufgerufen.
* Daher hier einzeln.
      check_cobl(
        CHANGING
          ch_vbseg = <fs_vbseg>
          ch_vbkpf = lt_vbkpf[ 1 ]
      ).

* Steuerkennzeichen prüfen analog dialog
      CALL FUNCTION 'FI_TAX_INDICATOR_CHECK'
        EXPORTING
          i_bukrs           = ms_ao_header-bukrs
          i_hkont           = <fs_vbseg>-saknr
          i_koart           = <fs_vbseg>-koart
          i_mwskz           = <fs_vbseg>-mwskz
          i_stbuk           = ms_ao_header-bukrs
          i_umsks           = space
          x_dialog          = space
        EXCEPTIONS
          input_tax_code    = 1
          no_tax_code       = 2
          output_tax_code   = 3
          tax_code          = 4
          country_not_found = 5
          OTHERS            = 6.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
          MESSAGE e001(/thkr/psm_ao) WITH sy-msgid sy-msgno sy-msgv1 sy-msgv2.
      ENDIF.
    ENDLOOP.


* Positionstext von Sachkontozeile in D/K Zeile übernehmen
    TRY.
        IF lt_vbseg[ 1 ]-sgtxt IS INITIAL.
          lt_vbseg[ 1 ]-sgtxt = lt_vbseg[ 2 ]-sgtxt.
        ENDIF.
      CATCH cx_sy_itab_line_not_found.
        " dann bleibt das Feld so
    ENDTRY.


* In dem SAP Std Baustein FI_PSO_ORDER_CHECK und auch FI_PSO_RECURRING_ORDER_POST
* werden die Daten nicht wie im Dialog geprüft daher hier noch einmal analog
    DATA(lt_bseg) = CORRESPONDING fm_t_bbseg( lt_vbseg  ).
    check_fipex(
      EXPORTING
        i_bseg = lt_bseg                  " Table Type for BBSEG
    ).

    CLEAR lt_mesg.
    CALL FUNCTION 'MESSAGES_GIVE'
      TABLES
        t_mesg = lt_mesg.

    LOOP AT lt_mesg TRANSPORTING NO FIELDS WHERE msgty CA 'EA'.
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0.

* ermitteln AO Nummer
      CALL FUNCTION 'FI_PSO_LOTKZ_DETERMINE'
        EXPORTING
          i_psotyp      = ms_ao_header-psoty
          i_recurring   = abap_true
          i_bukrs       = ms_ao_header-bukrs
        TABLES
          t_pso         = lt_pso
          t_item        = lt_item
        EXCEPTIONS
          error_message = 1.
      IF sy-subrc EQ 1.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi USING MESSAGE.
      ENDIF.

      LOOP AT lt_vbkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>).
        <fs_bkpf>-lotkz = ms_psm_ao_document_number-lotkz.
      ENDLOOP.

* Erwiterungsprüfungen durchlaufen (z.b. Kassenzeichen Prüfung)
      CALL FUNCTION 'FM_FI_PROCESS_00107040_CALL'
        TABLES
          c_t_pso02     = lt_pso
          c_t_pso02s    = lt_item
        EXCEPTIONS
          error_message = 1.
      IF sy-subrc EQ 1.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi USING MESSAGE.
      ENDIF.

* Bestimme die Art der Steuerfortschreibung anhand des Bukreises:
      CALL FUNCTION 'FI_PSO_TAX_MODE_DETERMINE'
        EXPORTING
          i_bukrs    = ms_ao_header-bukrs
        IMPORTING
          e_tax_mode = lv_tax_mode.

* der Funktionsbaustein FI_PSO_RECURRING_ORDER_WRITE benötigt die Daten in der Kopfzeile
* da dies im ABAP/OO nicht möglich ist, muss der Aufruf ausgelagert werden
      CALL FUNCTION '/THKR/PSO_RECURRING_ORDER_POST'
        EXPORTING
          t_pso_old     = ls_pso_old "leer
          i_okcode      = 'POST' " POST = Buchen
        TABLES
          t_pso_new     = lt_pso
          t_vbkpf_new   = lt_vbkpf
          t_vbsec_new   = lt_vbsec "leer
          t_vbseg_new   = lt_vbseg
          t_vbset_new   = lt_vbset "leer
        EXCEPTIONS
          error_message = 1.
      IF sy-subrc EQ 1.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi USING MESSAGE.
      ENDIF.

    ENDIF.


    CLEAR lt_mesg.
    CALL FUNCTION 'MESSAGES_GIVE'
      TABLES
        t_mesg = lt_mesg.

    CALL FUNCTION 'MESSAGES_STOP'
      EXPORTING
        i_reset_messages  = abap_true
      EXCEPTIONS
        a_message         = 1
        e_message         = 2
        w_message         = 3
        i_message         = 4
        s_message         = 5
        deactivated_by_md = 6
        OTHERS            = 7.
    IF sy-subrc <> 0.
*      RAISE EXCEPTION TYPE /thkr/cx_psm_ao MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT lt_mesg ASSIGNING FIELD-SYMBOL(<fs_mesg>).
      APPEND VALUE #( type       = <fs_mesg>-msgty id         = <fs_mesg>-arbgb number     = <fs_mesg>-txtnr message    = <fs_mesg>-text
                      message_v1 = <fs_mesg>-msgv1 message_v2 = <fs_mesg>-msgv2 message_v3 = <fs_mesg>-msgv3 message_v4 = <fs_mesg>-msgv4 ) TO lt_return.
    ENDLOOP.

    IF lt_return IS NOT INITIAL AND line_exists( lt_return[ type = 'E' ] ).
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE e001(/thkr/psm_ao) WITH lt_return[ 1 ]-message
        EXPORTING bapiret2_tab = lt_return.
    ENDIF.

* wenn kein Fehler dann AO Nummer zurückgeben
    ms_psm_ao_document_number-lotkz = lt_pso[ 1 ]-lotkz.
    ms_psm_ao_document_number-bukrs = ms_ao_header-bukrs.

  ENDMETHOD.


  METHOD determine_sign_for_acc.
*    aus SAP Standard Dialogtransaktion nutzen
*      PERFORM sign_indicator_determine IN PROGRAM saplf0ka USING lv_abse lv_koart lv_xumvz CHANGING lv_shkzg.


    DATA: l_vorgang1(2) TYPE c,   "Kreditor-, Debitor-, Sachkonten-Vorgang
          l_vorgang2(2) TYPE c.   "Stundung, Niederschlag oder Erlass



* ---- Ableitung des Soll/Haben-Kennzeichens nach Kontoart:
    CASE i_koart.
      WHEN c_konto_kreditor.
        r_shkzg = c_shkz_h.
      WHEN c_konto_debitor.
        r_shkzg = c_shkz_s.
      WHEN c_konto_sach.
        r_shkzg = c_shkz_h.
      WHEN OTHERS.
    ENDCASE.

* ---- wenn kreditorischer Beleg und Debitor gegeben bzw. umgekehrt
* ---- dann umgekehrtes Vorzeichen!
    CALL FUNCTION 'FI_PSO_REQUEST_PROCESS_PSOTYP'
      EXPORTING
        i_psotyp   = i_psoty
      IMPORTING
        e_vorgang1 = l_vorgang1
        e_vorgang2 = l_vorgang2.

    IF ( i_koart EQ c_konto_kreditor AND l_vorgang1 EQ '02' ) OR
       ( i_koart EQ c_konto_debitor AND l_vorgang1 EQ '01' ).
      CALL FUNCTION 'FI_PSO_SHKZG_INVERS'
        CHANGING
          c_shkzg = r_shkzg.
    ENDIF.

* ---- wenn Absetzung: umgekehrtes Vorzeichen!
    IF i_psoty = c_psoty_ausz_abs_04 OR i_psoty = c_psoty_ann_abs_05 OR i_psoty = c_psoty_niederschl_07 OR i_psoty = c_psoty_erlass_08.
      CALL FUNCTION 'FI_PSO_SHKZG_INVERS'
        CHANGING
          c_shkzg = r_shkzg.
    ENDIF.

* ---- wenn umgekehrtes Vorzeichen in der Zeile:
*      nochmals umgekehrtes Vorzeichen!
    IF i_xumvz EQ abap_true.
      CALL FUNCTION 'FI_PSO_SHKZG_INVERS'
        CHANGING
          c_shkzg = r_shkzg.
    ENDIF.



  ENDMETHOD.


METHOD fi_pso_due_dates_generate.
*"----------------------------------------------------------------------
  DATA:
    lt_days      TYPE TABLE OF casdayattr,
    lt_pso       TYPE TABLE OF pso02,
    lv_nummer    TYPE i,
    lv_anzahl    TYPE i,
    lv_facid     TYPE fabkl,
    lt_001w      TYPE TABLE OF t001w,
    lv_schema(1) TYPE c.
*"----------------------------------------------------------------------
* Coding siehe FI_PSO_DUE_DATES_GENERATE_2 teiweise übernommen, da SAP Baustein mit Dialogeingabe arbeitet

* Raten gibt es nicht bei Niederschlagung und Erlaß und nicht bei Daueranordnungen (haben wir aktuell nicht vorgesehen)
  IF ms_ao_header-psoty = c_psoty_niederschl_07 OR ms_ao_header-psoty = c_psoty_erlass_08.
    " Keine Änderung an den Daten vornehmen lassen
    APPEND VALUE #( ) TO mt_due_dates.
    RETURN.
  ENDIF.
*"----------------------------------------------------------------------
  " Gesamtbetrag errechnen
  DATA(lv_wrbtr) = CONV wrbtr( REDUCE #( INIT x TYPE wrbtr FOR wa IN ms_ao_beleg-t_kont NEXT x += wa-wrbtr ) + ms_ao_beleg-wmwst ).
*"----------------------------------------------------------------------
* Anzahl Belege errechnen
  IF ms_ao_settings-psoac IS NOT INITIAL.
    " Ratenbetrag vorgegeben
    " Wenn der Ratenbetrag groesse als der Orginalbetrag ist: Fehler!
    IF lv_wrbtr LT ms_ao_settings-psoac.
      MESSAGE e745(fq) WITH lv_wrbtr ms_ao_settings-psoac INTO DATA(lv_msg).
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*      DATA(lv_anzahl) = CONV wrbtr( lv_wrbtr / ms_ao_settings-psoac ).
    lv_anzahl = CONV wrbtr( lv_wrbtr / ms_ao_settings-psoac ).
    lv_schema = '1'.
  ELSEIF ms_ao_settings-psomo IS NOT INITIAL.
    " Anzahl Raten vorgegeben
    lv_anzahl = ms_ao_settings-psomo.
    lv_schema = '2'.
  ELSE.
    " Keine Änderung an den Daten vornehmen lassen
    APPEND VALUE #( ) TO mt_due_dates.
    RETURN.
  ENDIF.
*"----------------------------------------------------------------------
* Gereon Koks  TSI  31.3.2025
* Fälligkeiten der Rate muss nach Fälligkeit der ursprünglichen Anordnung liegen.
* PSODT := 17_FDATUM
  DATA(lv_faelligkeit)     = ms_ao_settings-psodt.
  DATA(lv_faelligkeit_day) = lv_faelligkeit.
* Rate
* Beispiel:
* Summe die gestundet wird: 133
* Rate:                      40
* 1. Rate                    40
* 2. Rate                    40
* 3. Rate                    40
* 4. Rate                    13
  DATA(lv_betrag)          = ms_ao_settings-psoac.
*"----------------------------------------------------------------------
* Fabrikkalender ermitteln
  CALL FUNCTION 'K_WERKS_OF_BUKRS_FIND'
    EXPORTING
      bukrs             = ms_ao_header-bukrs
    TABLES
      itab_001w         = lt_001w
    EXCEPTIONS
      no_entry_in_t001k = 1
      no_entry_in_t001w = 2
      OTHERS            = 3.

  IF sy-subrc IS INITIAL.
    READ TABLE lt_001w INTO DATA(ls_001w) INDEX 1.
    IF sy-subrc = 0.
      lv_facid = ls_001w-fabkl.
    ENDIF.
  ELSE.
    SELECT SINGLE facid FROM tbkfk INTO lv_facid WHERE waers = ms_ao_header-waers.
  ENDIF.
*"----------------------------------------------------------------------
*  WHILE lv_nummer <= lv_anzahl.

  DATA: lv_rest TYPE psoac.
* Zu Beginn ist die Gesamtsumme der Rest
  lv_rest = lv_wrbtr.

* Solange es noch einen Rest gibt.
  WHILE lv_rest > 0.
*"----------------------------------------------------------------------
* Die Zahlungszeitpunkte durchzählen
*"----------------------------------------------------------------------
    ADD 1 TO lv_nummer.
    DATA(lv_duedate) = ms_ao_settings-psodt.

* Immer gleichen Tag waehlen, ansonsten Probleme beim Monatsende
    lv_faelligkeit+6(2) = lv_faelligkeit_day+6(2).

    fi_pso_due_date_create(
      EXPORTING
        i_ao_header      = ms_ao_header
        i_psosu_waers_pa = CONV fm_psosu( lv_wrbtr )
        i_psodt_pa       = sy-datum "Datum wird intern nicht verwendet aber pflicht
*          i_schema         = '2'
        i_schema         = lv_schema
*          i_p_anzahl       = CONV i( lv_anzahl )
        i_p_anzahl       = lv_anzahl
        i_intervall      = CONV i( ms_ao_settings-psoin )
        i_number         = lv_nummer
      CHANGING
        c_faelligkeit    = lv_faelligkeit
        c_p_betrag       = lv_betrag
      EXCEPTIONS
        no_instalment    = 1
    ).

    IF sy-subrc = 1.
      EXIT.
    ENDIF.

* Rest ?
    lv_rest = lv_wrbtr - sy-tabix * lv_betrag.
*"----------------------------------------------------------------------
    "Hier werden die Fälligkeiten der Raten überprüft ob Sie auf einen
    " Feiertag ( Samstag, Sonntag oder Feiertag) liegen und gegebenenfalls verschoben auf den nächsten Werktag

    IF NOT lv_facid IS INITIAL.
* duedate überprüfen und evtl. korrigieren.
* Eigenschaften der nächsten 10 Tage von DUE Date an gerechnet lesen

      DATA(lv_end_date) = CONV scdatum( lv_faelligkeit + 10 ).

      CALL FUNCTION 'DAY_ATTRIBUTES_GET'
        EXPORTING
          factory_calendar           = lv_facid
          date_from                  = lv_faelligkeit
          date_to                    = lv_end_date
          language                   = sy-langu
        TABLES
          day_attributes             = lt_days
        EXCEPTIONS
          factory_calendar_not_found = 1
          holiday_calendar_not_found = 2
          date_has_invalid_format    = 3
          date_inconsistency         = 4
          OTHERS                     = 5.

      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        READ TABLE lt_days INTO DATA(ls_days) WITH KEY freeday = ' '.

        IF sy-subrc = 0.
          lv_faelligkeit = ls_days-date.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_rest < 0.
* Nur der Rest kommt zum Schluß in die Fälligkeitstabelle
      lv_betrag = lv_betrag + lv_rest.
    ENDIF.

    APPEND VALUE #( dzfbdt = lv_faelligkeit wrbtr = lv_betrag ) TO mt_due_dates.
*"----------------------------------------------------------------------
  ENDWHILE.
*"----------------------------------------------------------------------
** zusätzliche Rate, falls noch ein Rest offen ist
*  lv_betrag = lv_wrbtr - lv_betrag * sy-tabix.
*  IF lv_schema EQ '1' AND lv_betrag > 0.
*    APPEND VALUE #( dzfbdt = lv_faelligkeit wrbtr = lv_betrag ) TO mt_due_dates.
*  ENDIF.
*"----------------------------------------------------------------------
* Bei Raten muss noch die Gesamtsumme über alle Belege bekannt sein, da die Belege einzeln gebucht werden
  APPEND VALUE #( bukrs  = ms_ao_header-bukrs
                  psoty  = ms_ao_header-lotkz
                  belnr  = mv_belnr_in
                  gjahr  = ms_ao_header-gjahr
*                 FIPEX	=
*                 FISTL	=
*                GEBER  =
*                BSTAT  =
                  psosum = lv_wrbtr
                  hwaer  = ms_ao_header-waers
  ) TO mt_pso50.
*"----------------------------------------------------------------------
ENDMETHOD.


  METHOD fi_pso_due_date_create.

** Original kopiert aus FUBA 'FI_PSO_DUE_DATE_CREATE'
** dieser nutzt aber Tabellen mit Kopfzeilen die im OO Kontext nicht mehr unterstützt werden
*      CALL FUNCTION 'FI_PSO_DUE_DATE_CREATE'
*        EXPORTING
*          i_psosu_waers_pa = CONV fm_psosu( lv_wrbtr )
*          i_psodt_pa       = sy-datum "Datum wird intern nicht verwendet aber pflicht
*          i_schema         = '1'
*          i_p_anzahl       = CONV i( lv_anzahl )
*          i_intervall      = CONV i( ms_ao_param-psoin )
*          i_number         = lv_nummer
*        TABLES
*          t_pso            = lt_pso
*        CHANGING
*          c_faelligkeit    = lv_faelligkeit
*          c_p_betrag       = lv_betrag
*        EXCEPTIONS
*          no_instalment    = 1.
*      IF sy-subrc EQ 1.
*        EXIT.
*      ENDIF.

    DATA: l_month_pa   TYPE i,
          l_year_pa    TYPE i,
          l_months     TYPE i,
          l_years      TYPE i,
          l_zw_betrag  TYPE pso02-wrbtr,
          l_zahl       TYPE pso02-wrbtr,
          l_psore      TYPE pso40-psore,
          l_f_payac07  TYPE payac07,
          l_betrag(50) TYPE c,
          l_datum      TYPE pso02-zfbdt.

* bestimme Buchungskreisvariante:
    CALL FUNCTION 'FI_PSO_PAYAC07_READ3'
      EXPORTING
        i_bukrs   = i_ao_header-bukrs
      IMPORTING
        e_payac07 = l_f_payac07.

* bestimme Rundungseinheit:
    CALL FUNCTION 'FI_PSO_PSO40_READ'
      EXPORTING
        i_bukfm   = l_f_payac07-bukfm
        i_waers   = i_ao_header-waers
      IMPORTING
        e_psore   = l_psore
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

* Falls keine Rundungseinheit hinter legt wurde, Warnung nur einmal
* aufrufen:
    IF sy-subrc EQ 1 AND i_number EQ 2.
      MESSAGE w766(fq) WITH l_f_payac07-bukfm i_ao_header-waers.
    ENDIF.

    IF l_zahl IS INITIAL.
      l_zahl = 1.
    ENDIF.

* Datum berechnen:
    l_year_pa  = c_faelligkeit(4).
    l_month_pa = c_faelligkeit+4(2).

    l_years  = i_intervall DIV 12.  " Anzahl der ganzen Jahre
    l_months = i_intervall MOD 12.  " Anzahl Monate (ohne ganze Jahre)

    IF l_months = 0.
      l_year_pa  = l_year_pa + l_years.
    ELSE.
      l_month_pa = l_month_pa + l_months.
      l_year_pa  = l_year_pa  + l_years.
      IF l_month_pa GT 12.
        l_month_pa = l_month_pa - 12.
        l_year_pa  = l_year_pa  + 1.
      ENDIF.
    ENDIF.

    c_faelligkeit(4)   = l_year_pa.
    c_faelligkeit+4(2) = l_month_pa.

* LETZTEN TAG DES MONATS ERMITTELN -------------------------------
    l_datum      = c_faelligkeit.
    l_datum+6(2) = '01'.
    l_datum      = l_datum + 31.
    l_datum+6(2) = '01'.
    l_datum      = l_datum - 1.

* PRÜFEN OB ERSTE "nächste Ausführung" zulässig und ggf. ändern --
    IF c_faelligkeit GT l_datum.
      c_faelligkeit = l_datum.
    ENDIF.

* Betrag berechnen:
    IF i_schema EQ '2'.
      l_zw_betrag = i_psosu_waers_pa / i_p_anzahl.
*    L_DEC       = L_ZW_BETRAG DIV L_ZAHL.                  "ganze Zahl!
*    IF L_DEC LT '1'.
**    message
*    ENDIF.
*    C_P_BETRAG = L_ZAHL * L_DEC.
* Betrag runden:
      CALL FUNCTION 'FI_PSO_ROUND_VALUE'
        EXPORTING
          i_rtype = '-'
          i_runit = l_psore
          i_value = l_zw_betrag
        IMPORTING
          e_value = c_p_betrag.

* Betrag kleiner als Rundungseinheit
* => C_P_BETRAG ist nach obigen Perform gleich Null
      IF c_p_betrag IS INITIAL AND i_number EQ 2.
        WRITE l_zw_betrag TO l_betrag CURRENCY i_ao_header-waers LEFT-JUSTIFIED.
        MESSAGE w765(fq) WITH l_betrag l_psore.
        RAISE no_instalment.
      ENDIF.

    ENDIF.



  ENDMETHOD.


  METHOD GET_DTO_PSM_AO.
* Liest alle Daten einer AO aus und mappt sie auf die DTO Retrun Struktur
* Mind. Anforderungen sind LOTKZ, BUKRS, GJAHR die anderen Parameter sind optional

    DATA:
      lt_head	 TYPE fipso_header_tab,
      lt_vbseg TYPE fm_vbseg_tab,
      lt_vbsec TYPE fm_vbsec_tab,
      lt_vbset TYPE fm_vbset_tab,
      lv_act   TYPE activ_auth,
      lv_calld TYPE syst_calld.

* Lesen der FI Daten mit und ohne Vorerfassung
    CALL FUNCTION 'FI_PSO_FI_VIA_LOTKZ'
      EXPORTING
        i_bukrs   = i_bukrs
        i_lotkz   = i_lotkz
        i_belnr   = i_belnr
        i_gjahr   = i_gjahr
        i_act     = lv_act
*       i_psotyp  = lv_psotyp
      TABLES
        c_t_head  = lt_head
        c_t_vbseg = lt_vbseg
        c_t_vbsec = lt_vbsec
        c_t_vbset = lt_vbset
      CHANGING
        c_calld   = lv_calld
      EXCEPTIONS
        exit_all  = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi USING MESSAGE.
    ENDIF.

* Mapping auf DTO
    r_dto_ps_fm_order = map_pso_fi_to_dto( i_head = lt_head  i_vbseg = lt_vbseg i_vbsec = lt_vbsec i_vbset = lt_vbset ).

  ENDMETHOD.


  METHOD GET_INSTANCE.

    IF instance IS INITIAL.
      instance = NEW #( ).
    ENDIF.

    r_instance = instance.

  ENDMETHOD.


 METHOD map_dto_beleg_to_bseg.
*"----------------------------------------------------------------------
   DATA:
     ls_xsako TYPE xsako,
     ls_bseg  TYPE bbseg_fm.
*"----------------------------------------------------------------------
* Prüfen ob Steuerkennzeichen bekannt, wenn Steuerbetrag vorhanden
   IF ms_ao_beleg-wmwst IS NOT INITIAL AND ms_ao_beleg-mwskz IS INITIAL.
     " Wenn Steuer vorhanden aber kein Steuerkennzeichen, dieses aus Sachkonto ableiten
     CALL FUNCTION 'FI_GL_ACCOUNT_DATA'
       EXPORTING
         i_bukrs = ms_ao_header-bukrs
         i_saknr = ms_ao_beleg-t_kont[ 1 ]-hkont
       IMPORTING
         e_sako  = ls_xsako
       EXCEPTIONS                                             "1596752
         OTHERS  = 4.
     IF sy-subrc = 0  AND NOT ls_xsako-mwskz IS INITIAL AND ls_xsako-xmwno IS INITIAL. "Kennzeichen: Steuerkennzeichen kein Mussfeld.
       IF ls_xsako-mwskz CA '><+*-.'.
         ms_ao_beleg-mwskz = 'V1'."Default da nicht eindeutig
       ELSE.
         ms_ao_beleg-mwskz = ls_xsako-mwskz .
       ENDIF.
     ELSE.
       ms_ao_beleg-mwskz = 'V1'. "Default
     ENDIF.
   ENDIF.
*"----------------------------------------------------------------------
* Debitor/Kreditor Datenzeile muss immer Zeile 1 sein
* Bei Verrechnungsanordnung ist die 1. Zeile der Empfänger

   ls_bseg-tbnam = mv_koart_tbnam.

* Buchungsschlüssel
   CALL FUNCTION 'FI_PSO_POSTING_KEY_DETERMINE'
     EXPORTING
       i_koart = mv_koart
       i_umskz = ''
       i_shkzg = mv_shkzg
     CHANGING
       c_bschl = ls_bseg-newbs.

   ls_bseg-newbk = ms_ao_header-bukrs.
   ls_bseg-newko = ms_ao_beleg-partner.
   ls_bseg-bvtyp = ms_ao_beleg-bvtyp.

   " Summe der Beträge aller Zeilen bilden
   ls_bseg-wrbtr =  CONV wrbtr( REDUCE #( INIT x TYPE wrbtr FOR wa IN ms_ao_beleg-t_kont NEXT x += wa-wrbtr ) + ms_ao_beleg-wmwst ).
   ls_bseg-wmwst = ms_ao_beleg-wmwst.
   ls_bseg-mwskz = ms_ao_beleg-mwskz.
   ls_bseg-sgtxt = ms_ao_beleg-t_kont[ 1 ]-sgtxt. "Positionszeilentext soll laut Kasse in allen Zeilen identisch sein
   ls_bseg-mansp = ms_ao_beleg-mansp.
   ls_bseg-maber = ms_ao_beleg-maber.
   ls_bseg-madat = ms_ao_beleg-madat.
   ls_bseg-zlsch = ms_ao_beleg-zlsch.
   ls_bseg-zterm = ms_ao_beleg-zterm.
   ls_bseg-zbd1t = ms_ao_beleg-zbd1t.
   ls_bseg-zfbdt = ms_ao_beleg-zfbdt.
   ls_bseg-lzbkz = ms_ao_beleg-lzbkz.
   ls_bseg-landl = ms_ao_beleg-landl.

   IF ms_ao_beleg_kont-gsber IS INITIAL.
     ls_bseg-gsber = ms_ao_beleg-t_kont[ 1 ]-gsber.
   ENDIF.
*"----------------------------------------------------------------------
* Gereon Koks  T-Systems 16.5.2025
*"----------------------------------------------------------------------
* Da Mapping jetzt aus AIF kommt (/THKR/AIF_BMAP_REFERENCE),
* kann hier direkt zugeordnet werden.
*"----------------------------------------------------------------------
   ls_bseg-rebzg = ms_ao_beleg-rebzg.
   ls_bseg-rebzj = ms_ao_beleg-rebzj.
   ls_bseg-rebzz = ms_ao_beleg-rebzz.
   ls_bseg-rebzt = ms_ao_beleg-rebzt.
*"----------------------------------------------------------------------
* Beim Buchen einer Stundung, einer Niederschlagung, eines Erlasses oder eines Sollzuganges
* muss über die Felder REBZG, REBZJ und REBZZ auf den Ursprungsbeleg verwiesen werden.
*   IF ms_ao_header-psoty = c_psoty_stundung_06 OR ms_ao_header-psoty = c_psoty_niederschl_07 OR ms_ao_header-psoty = c_psoty_erlass_08
*     OR ( ms_ao_header-psoty = c_psoty_ann_02 AND ms_ao_beleg-blart = 'DE' ).
*     ls_bseg-rebzg = mv_belnr_in.
*     ls_bseg-rebzj = ms_ao_header-gjahr.
*     ls_bseg-rebzz = COND #( WHEN ms_ao_header-psoty = c_psoty_ann_02 AND ms_ao_beleg-blart = 'DE' THEN '1'
*                             ELSE '')."Buchungsposition
*     IF ms_ao_header-psoty = c_psoty_ann_02 AND ms_ao_beleg-blart = 'DE'.
*       "Sollzugänge müssen mit dem Origignalbeleg verknüpft werden
*       "und müssen zusätzlich vom Typ F (Folgebeleg), G (Gutschrift) oder leer sein.
*       ls_bseg-rebzt = 'F'.  "Folgebeleg
*     ENDIF.
*   ENDIF.
*"----------------------------------------------------------------------
* bei Verrechnungs AO müssen die Empfängerkontierungsdaten übernommen werden.
   IF ms_ao_header-psoty = c_psoty_verr_03.
     MOVE-CORRESPONDING ms_ao_beleg_kont TO ls_bseg.
   ENDIF.

   APPEND ls_bseg TO c_bseg.



** Positionen / Sachkontozeilen
   LOOP AT ms_ao_beleg-t_kont ASSIGNING FIELD-SYMBOL(<fs_kont>).
     CLEAR ls_bseg.

     ls_bseg-tbnam = 'VBSEGS'.
     ls_bseg-newko = <fs_kont>-hkont.
     ls_bseg-newbk = ms_ao_header-bukrs.

     DATA(lv_shkzg) = mv_shkzg.

     CALL FUNCTION 'FI_PSO_SHKZG_INVERS'
       CHANGING
         c_shkzg = lv_shkzg.

     CALL FUNCTION 'FI_PSO_POSTING_KEY_DETERMINE'
       EXPORTING
         i_koart = 'S'
         i_umskz = ''
         i_shkzg = lv_shkzg
       CHANGING
         c_bschl = ls_bseg-newbs.

     ls_bseg-wrbtr = <fs_kont>-wrbtr.
     ls_bseg-mwskz = COND #( WHEN <fs_kont>-mwskz IS INITIAL THEN ms_ao_beleg-mwskz ELSE <fs_kont>-mwskz ).

     ls_bseg-geber = <fs_kont>-geber.
     ls_bseg-zuonr = <fs_kont>-zuonr.
     ls_bseg-sgtxt = <fs_kont>-sgtxt.
     ls_bseg-kostl = <fs_kont>-kostl.
     ls_bseg-fistl = <fs_kont>-fistl.
     ls_bseg-fipex = <fs_kont>-fipex." es darf im DI nur fipex gefüllt sein, nicht fipos
     ls_bseg-fkber = <fs_kont>-fkber.
     ls_bseg-kblnr = <fs_kont>-kblnr. "Mittelvormerkung
     ls_bseg-kblpos = <fs_kont>-kblpos. "Mittelvormerkungsposition
     ls_bseg-gsber = <fs_kont>-gsber.
     ls_bseg-zfbdt = ms_ao_beleg-zfbdt.
     ls_bseg-aufnr = <fs_kont>-aufnr.
     ls_bseg-erlkz = <fs_kont>-erlkz.


     CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
       EXPORTING
         input  = <fs_kont>-ps_psp_pnr
       IMPORTING
         output = ls_bseg-projn.

     ls_bseg-projk = <fs_kont>-ps_psp_pnr.

     APPEND ls_bseg TO c_bseg.

   ENDLOOP.



 ENDMETHOD.


  METHOD MAP_DTO_BELEG_TO_BTAX.

    DATA:
      lt_bkpf   TYPE TABLE OF bkpf,
      lt_bseg   TYPE TABLE OF bseg,
      ls_itxdat TYPE itxdat,
*      lt_mwdat  TYPE TABLE OF rtax1u15,
      lv_wmwst  TYPE wmwst,
      lv_shkzg  TYPE shkzg,
      ls_btax   TYPE bbtax_fm.


    lv_shkzg = mv_shkzg.
    CLEAR: ls_btax.

* wenn Steuer bekannt oder nur Steuerkennzeichen vorgegebenm dann Steuerzeile aufbauen

* Wenn Steuer schon bekannt
    IF ms_ao_beleg-wmwst IS NOT INITIAL .
      lv_wmwst = ms_ao_beleg-wmwst.

* wenn nur Steuerkennzeichen bekannt, dann Steuer errechnen lassen
    ELSEIF ms_ao_beleg-wmwst IS INITIAL AND ms_ao_beleg-mwskz IS NOT INITIAL.

* Steuer rechnen
      DATA(lv_wrbtr) =  CONV wrbtr( REDUCE #( INIT x TYPE wrbtr FOR wa IN ms_ao_beleg-t_kont NEXT x += wa-wrbtr ) ).

      lt_bkpf = CORRESPONDING #( c_bkpf ).
      LOOP AT c_bseg INTO DATA(ls_c_bseg).
        APPEND INITIAL LINE TO lt_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>).
        MOVE-CORRESPONDING ls_c_bseg TO <fs_bseg>.
        IF ls_c_bseg-tbnam = mv_koart_tbnam.
          <fs_bseg>-koart = mv_koart.
        ENDIF.
        <fs_bseg>-bschl = ls_c_bseg-newbs .
        <fs_bseg>-mwskz = ls_c_bseg-mwskz.
        <fs_bseg>-bukrs = ls_c_bseg-newbk.

      ENDLOOP.

      CALL FUNCTION 'CALCULATE_TAX_DOCUMENT'
        EXPORTING
          i_bukrs                    = ms_ao_header-bukrs
          i_xsimu                    = abap_true
        IMPORTING
          e_itxdat                   = ls_itxdat
        TABLES
          t_bkpf                     = lt_bkpf
          t_bseg                     = lt_bseg
        EXCEPTIONS
          error_calculate_discountb  = 1
          mwskz_not_defined          = 2
          user_exit                  = 3
          mwskz_einheitlich_vorgeben = 4
          steuerbetrag_falsch        = 5
          amounts_too_large_for_tax  = 6
          OTHERS                     = 7.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      lv_wmwst = ls_itxdat-fwste .

* Steuer noch auf die D/K Belegzeile hinzufügen
      READ TABLE c_bseg ASSIGNING FIELD-SYMBOL(<fs_c_bseg>) WITH KEY tbnam = mv_koart_tbnam.
      <fs_c_bseg>-hwbas = <fs_c_bseg>-wrbtr.
      <fs_c_bseg>-fwbas = <fs_c_bseg>-wrbtr.
      <fs_c_bseg>-wmwst = lv_wmwst.
      <fs_c_bseg>-xstba = abap_true.
      <fs_c_bseg>-wrbtr = <fs_c_bseg>-wrbtr + lv_wmwst.
      <fs_c_bseg>-mwskz = ms_ao_beleg-mwskz.
    ENDIF.

    IF lv_wmwst IS NOT INITIAL.

* Tax Item
      ls_btax-tbnam = mv_koart_tbnam.
      ls_btax-fwste = lv_wmwst.
      ls_btax-mwskz = ms_ao_beleg-mwskz.

* Da Sachkostenzeile Vorzeichen drehen
      CALL FUNCTION 'FI_PSO_SHKZG_INVERS'
        CHANGING
          c_shkzg = lv_shkzg.

      CALL FUNCTION 'FI_PSO_POSTING_KEY_DETERMINE'
        EXPORTING
          i_koart = 'S'
          i_umskz = ''
          i_shkzg = lv_shkzg
        CHANGING
          c_bschl = ls_btax-bschl.

      APPEND ls_btax TO c_btax .

    ENDIF.


*    CALL FUNCTION 'CALCULATE_TAX_FROM_GROSSAMOUNT'
*      EXPORTING
*        i_bukrs                   = c_dto_psm_ao_bel_create-bukrs
*        i_mwskz                   = c_dto_psm_ao_bel_create-mwskz
**       I_TXJCD                   = ' '
*        i_waers                   = c_dto_psm_ao_bel_create-waers
*        i_wrbtr                   = lv_wrbtr
**       I_ZBD1P                   = 0
**       I_PRSDT                   =
**       I_TAX_RELEVANT_DATES      =
**       I_PROTOKOLL               =
**       I_TAXPS                   =
**       I_ACCNT_EXT               =
**       I_ACCDATA                 =
**       IS_ENHANCEMENT            =
**       I_PRICING_REFRESH_TX      = ' '
**       I_TAX_COUNTRY             =
** IMPORTING
**       E_FWNAV                   =
**       E_FWNVV                   =
**       E_FWSTE                   =
**       E_FWAST                   =
*      TABLES
*        t_mwdat                   = lt_mwdat
*      EXCEPTIONS
*        bukrs_not_found           = 1
*        country_not_found         = 2
*        mwskz_not_defined         = 3
*        mwskz_not_valid           = 4
*        account_not_found         = 5
*        different_discount_base   = 6
*        different_tax_base        = 7
*        txjcd_not_valid           = 8
*        not_found                 = 9
*        ktosl_not_found           = 10
*        kalsm_not_found           = 11
*        parameter_error           = 12
*        knumh_not_found           = 13
*        kschl_not_found           = 14
*        unknown_error             = 15
*        amounts_too_large_for_tax = 16
*        tdt_error                 = 17
*        txa_error                 = 18
*        OTHERS                    = 19.
*    IF sy-subrc <> 0.
** Implement suitable error handling here
*    ENDIF.
*
*    LOOP AT lt_mwdat INTO DATA(ls_mwdat).
*      ADD ls_mwdat-wmwst TO c_dto_psm_ao_bel_create-wmwst.
*    ENDLOOP.
  ENDMETHOD.


  METHOD MAP_DTO_HDR_TO_BKPF.
* pro Beleg in AO DTO ein BKPF
    DATA:
          ls_bkpf  TYPE bbkpf_fm.


* Head Data
    MOVE-CORRESPONDING ms_ao_header TO ls_bkpf.
    MOVE-CORRESPONDING ms_ao_beleg TO ls_bkpf.

    IF ls_bkpf-blart IS INITIAL.
      ls_bkpf-blart = mv_blart.
    ENDIF.

    IF ls_bkpf-lotkz IS NOT INITIAL.
      ls_bkpf-xlote = abap_true.
    ENDIF.

    IF ls_bkpf-budat = '00000000'.
      ls_bkpf-budat = sy-datum.
    ENDIF.

    IF ls_bkpf-bldat = '00000000'.
      ls_bkpf-bldat = sy-datum.
    ENDIF.

    IF ls_bkpf-monat = '00'.
      ls_bkpf-monat = ls_bkpf-budat+4(2).
    ENDIF.

    IF ls_bkpf-waers IS INITIAL.
      ls_bkpf-waers = 'EUR'.
    ENDIF.

*    IF i_dto_psm_ao_bel_create-mwskz IS NOT INITIAL AND i_dto_psm_ao_bel_create-wmwst IS INITIAL.
*      ls_bkpf-xmwst = abap_true. " im PSO Direct Input wird das nicht unterstützt
*    ENDIF.

* PSOXB Vorerfassung ja/nein.
    IF ms_ao_param-psoxb IS INITIAL.
      ls_bkpf-tcode = 'FBV1'. " Beleg vorerfassen
    ELSE.
      ls_bkpf-tcode = 'FB01'. " Beleg direkt buchen
    ENDIF.

    APPEND ls_bkpf TO c_bkpf.


  ENDMETHOD.


METHOD map_psoty_data.
*"----------------------------------------------------------------------
*01	Auszahlungsanordnung
*02	Annahmeanordnung
*03	Verrechnungsanordnung
*04	Auszahlungs-Absetzungsanordnung
*05	Annahme-Absetzungsanordnung
*06	Stundungsanordnung
* folgende AO Typen werden nicht unterstützt:
*07	Niederschlagungsanordnung --> Die originale Ao wird via Ändern geöffnet und eine Mahnsperre (befristet / unbefristet) gesetzt.
*08	Erlaß --> Es wird eine neue AbsetzungsAo mit Referenz auf die zuerlassende Ao mit Angabe des Erlaßgrundes erfaßt; Belegart ER	- HBW Erlass

*09	Pauschale Restebereinigung
*"----------------------------------------------------------------------
  DATA:
         lv_blart TYPE blart.
*"----------------------------------------------------------------------
* Ggf. gepflegte Std. Vorbelegung lesen
  CALL FUNCTION 'FI_PSO_BLART_SUGGEST'
    EXPORTING
      i_psotyp      = ms_ao_header-psoty
    IMPORTING
      e_blart       = lv_blart
    EXCEPTIONS
      nothing_found = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    CLEAR lv_blart.
  ENDIF.
*"----------------------------------------------------------------------
* Übergebene Belegart hat Vorrang vor Std. Belegung
  mv_blart = ms_ao_beleg-blart.

  IF mv_blart IS INITIAL AND lv_blart IS NOT INITIAL.
    mv_blart =  lv_blart.
  ENDIF.
*"----------------------------------------------------------------------
** Abhängigkeiten vom AO Typ
  CASE ms_ao_header-psoty.
*"----------------------------------------------------------------------
    WHEN  c_psoty_ausz_01. " Auszahlungsanordnung
      mv_blart = COND #( WHEN mv_blart IS INITIAL  THEN 'KR' ELSE mv_blart ).
      mv_koart = c_konto_kreditor.
      mv_koart_tbnam = 'VBSEGK'.
*"----------------------------------------------------------------------
    WHEN  c_psoty_ann_02. " Annahmeanordnung
      mv_blart = COND #( WHEN mv_blart IS INITIAL THEN 'DR' ELSE mv_blart ).
      mv_koart = c_konto_debitor.
      mv_koart_tbnam = 'VBSEGD'.
      "Wenn Sollzugang
      If mv_blart = 'DE'.
        "Belegnummer muss in Referenzbeleg übernommen werden
        "Aber neu gebildet werden
        CLEAR: ms_ao_beleg-belnr, ms_ao_header-lotkz.
      endif.
*"----------------------------------------------------------------------
    WHEN c_psoty_verr_03. " Verrechnungsanordnung
      mv_blart = COND #( WHEN mv_blart IS INITIAL THEN 'SA' ELSE mv_blart ).
      mv_koart = c_konto_sach. " Es gibt nur Sachkontobuchungen
*"----------------------------------------------------------------------
    WHEN c_psoty_ausz_abs_04. " Auszahlungs-Absetzungsanordnung
      mv_blart = COND #( WHEN mv_blart IS INITIAL THEN 'KG' ELSE mv_blart ).
      mv_koart = c_konto_kreditor.
      mv_koart_tbnam = 'VBSEGK'.
*"----------------------------------------------------------------------
    WHEN c_psoty_ann_abs_05. " Annahme-Absetzungsanordnung
      mv_blart = COND #( WHEN mv_blart IS INITIAL THEN 'DG' ELSE mv_blart ).
      mv_koart = c_konto_debitor.
      CLEAR: ms_ao_beleg-belnr, ms_ao_header-lotkz.
      mv_koart_tbnam = 'VBSEGD'.
*"----------------------------------------------------------------------
    WHEN c_psoty_stundung_06. " Stundungsanordnung
      mv_blart = COND #( WHEN mv_blart IS INITIAL THEN 'SD' ELSE mv_blart ).
      CLEAR: ms_ao_beleg-belnr, ms_ao_header-lotkz.
      mv_koart =  c_konto_debitor.
      mv_koart_tbnam = 'VBSEGD'.
*"----------------------------------------------------------------------
    WHEN c_psoty_niederschl_07. " Niederschlagungsanordnung
      MESSAGE e022(/thkr/psm_int_fi) WITH ms_ao_header-psoty INTO DATA(lv_msg).
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        mv_blart = COND #( WHEN mv_blart IS INITIAL THEN 'NU' ELSE mv_blart ).
*        mv_koart = c_konto_debitor.
*        mv_koart_tbnam = 'VBSEGD'.
*        mv_belnr_in = ms_ao_beleg-belnr.
*        CLEAR: ms_ao_beleg-belnr, ms_ao_header-lotkz.
*"----------------------------------------------------------------------
    WHEN c_psoty_erlass_08. " Erlaß
      MESSAGE e022(/thkr/psm_int_fi) WITH ms_ao_header-psoty INTO lv_msg.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        mv_blart = COND #( WHEN mv_blart IS INITIAL THEN 'ER' ELSE mv_blart ).
*        mv_koart = c_konto_debitor.
*        mv_koart_tbnam = 'VBSEGD'.
*        mv_belnr_in = ms_ao_beleg-belnr.
*        CLEAR: ms_ao_beleg-belnr, ms_ao_header-lotkz.
*"----------------------------------------------------------------------
    WHEN OTHERS.
*"----------------------------------------------------------------------
  ENDCASE.
*"----------------------------------------------------------------------
** S/H Ermittlung für 1. Buchungszeile
  mv_shkzg = determine_sign_for_acc(
    i_psoty = ms_ao_header-psoty                " Belegtyp Zahlungsanordnungen
    i_koart = mv_koart              " Kontoart
    i_xumvz = ms_ao_param-xumvz     " Kennzeichen: Buchung mit umgekehrtem Vorzeichen
  ).
*"----------------------------------------------------------------------
ENDMETHOD.


  METHOD map_pso_fi_to_dto.

    LOOP AT i_head ASSIGNING FIELD-SYMBOL(<fs_head>).
      MOVE-CORRESPONDING <fs_head>-vbkpf TO r_dto_ps_fm_order.
      APPEND INITIAL LINE TO r_dto_ps_fm_order-t_beleg ASSIGNING FIELD-SYMBOL(<fs_beleg>).
      MOVE-CORRESPONDING <fs_head>-vbkpf TO <fs_beleg>.


      LOOP AT i_vbseg ASSIGNING FIELD-SYMBOL(<fs_vbseg>)
                          WHERE ausbk = <fs_head>-vbkpf-bukrs AND belnr = <fs_head>-vbkpf-belnr AND gjahr = <fs_head>-vbkpf-gjahr.

        IF <fs_vbseg>-koart <> 'S'. " GP Nummer setzen
          <fs_beleg>-partner = COND #( WHEN <fs_vbseg>-lifnr IS NOT INITIAL THEN <fs_vbseg>-lifnr ELSE <fs_vbseg>-kunnr ).
          <fs_beleg>-maber = <fs_vbseg>-maber.
          <fs_beleg>-mansp = <fs_vbseg>-mansp.
          <fs_beleg>-zfbdt = <fs_vbseg>-zfbdt.
          <fs_beleg>-manst = <fs_vbseg>-manst.
          CONTINUE.
        ENDIF.

        " Steuerzeilen
        IF <fs_vbseg>-buzid = 'T'.
          <fs_beleg>-mwskz = <fs_vbseg>-mwskz.
          <fs_beleg>-wmwst = <fs_vbseg>-wrbtr.
          CONTINUE.
        ENDIF.

        " Kontierung setzen
        APPEND INITIAL LINE TO <fs_beleg>-t_kont ASSIGNING FIELD-SYMBOL(<fs_kont>).
        MOVE-CORRESPONDING <fs_vbseg> TO <fs_kont>.
        CALL FUNCTION 'FI_PSO_FIPEX_GET_FROM_FIPOS'
          EXPORTING
            i_fipos = <fs_vbseg>-fipos
          IMPORTING
            e_fipex = <fs_kont>-fipex.

      ENDLOOP.

    ENDLOOP.


  ENDMETHOD.


METHOD pso_document_check.
*"----------------------------------------------------------------------
  DATA:
    lt_return TYPE bapiret2_t,
    lt_mesg   TYPE tsmesg.
*"----------------------------------------------------------------------
  IF mv_koart = c_konto_kreditor.
    CALL FUNCTION 'VENDOR_READ'
      EXPORTING
        i_bukrs       = ms_ao_header-bukrs
        i_lifnr       = ms_ao_beleg-partner
      EXCEPTIONS
        not_found     = 1
        lifnr_blocked = 2
        OTHERS        = 3.
    IF sy-subrc <> 0.
      APPEND VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                      message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ) TO lt_return.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        EXPORTING bapiret2_tab = lt_return.
    ENDIF.
  ELSEIF  mv_koart = c_konto_debitor.
    CALL FUNCTION 'CUSTOMER_READ'
      EXPORTING
        i_bukrs       = ms_ao_header-bukrs
        i_kunnr       = ms_ao_beleg-partner
      EXCEPTIONS
        not_found     = 1
        kunnr_blocked = 2
        OTHERS        = 3.

    IF sy-subrc <> 0.
      APPEND VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                      message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ) TO lt_return.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        EXPORTING bapiret2_tab = lt_return.
    ENDIF.
  ENDIF.
*"----------------------------------------------------------------------
  check_fipex( EXPORTING i_bseg = c_bseg  ).
*"----------------------------------------------------------------------
  CALL FUNCTION 'MESSAGES_INITIALIZE'
    EXPORTING
      collect_and_send     = ' '
      reset                = 'X'
      i_store_duplicates   = 'X'
      i_no_duplicate_count = 0
      check_on_commit      = ' '
    EXCEPTIONS
      log_not_active       = 1
      wrong_identification = 2
      OTHERS               = 3.

  IF sy-subrc <> 0.
    APPEND VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                    message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ) TO lt_return.
    RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      EXPORTING bapiret2_tab = lt_return.
  ENDIF.
*"----------------------------------------------------------------------
* first check
  CALL FUNCTION '/THKR/FI_PSO_DOC_DIRECT_INPUT'
    EXPORTING
      i_nodata            = '/'
* Gereon Koks  T-Systems  19.5.2025
* Damit wird das NODATA-Zeichen '/' nicht entfernt
      i_del_nodata        = ''
      i_intlot            = abap_true "Interne Nummernvergabe für Bündelungsnr.
      i_check             = abap_true
      i_due_date_deferral = mv_due_date_deferral
    TABLES
      t_bbkpf             = c_bkpf
      t_bbseg             = c_bseg
      t_bbtax             = c_btax
      t_pso50             = mt_pso50
    EXCEPTIONS
      error_message       = 1.

  IF sy-subrc = 1.
    RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
      MESSAGE e001(/thkr/psm_ao) WITH sy-msgid sy-msgno sy-msgv1 sy-msgv2.
  ENDIF.
*"----------------------------------------------------------------------
  CALL FUNCTION 'MESSAGES_GIVE'
    TABLES
      t_mesg = lt_mesg.
*"----------------------------------------------------------------------
  CALL FUNCTION 'MESSAGES_STOP'
    EXPORTING
      i_reset_messages  = abap_true
    EXCEPTIONS
      a_message         = 1
      e_message         = 2
      w_message         = 3
      i_message         = 4
      s_message         = 5
      deactivated_by_md = 6
      OTHERS            = 7.

  IF sy-subrc <> 0.
*      RAISE EXCEPTION TYPE /thkr/cx_psm_ao MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*"----------------------------------------------------------------------
  LOOP AT lt_mesg ASSIGNING FIELD-SYMBOL(<fs_mesg>).
    APPEND VALUE #( type       = <fs_mesg>-msgty id         = <fs_mesg>-arbgb number     = <fs_mesg>-txtnr message    = <fs_mesg>-text
                    message_v1 = <fs_mesg>-msgv1 message_v2 = <fs_mesg>-msgv2 message_v3 = <fs_mesg>-msgv3 message_v4 = <fs_mesg>-msgv4 ) TO lt_return.
  ENDLOOP.

  IF lt_return IS NOT INITIAL AND line_exists( lt_return[ type = 'E' ] ).
    RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
      MESSAGE e001(/thkr/psm_ao) WITH lt_return[ type = 'E' ]-message
      EXPORTING bapiret2_tab = lt_return.
  ENDIF.
*"----------------------------------------------------------------------
ENDMETHOD.


  METHOD pso_document_post.

    DATA:
      lt_return TYPE bapiret2_t,
      lt_mesg   TYPE tsmesg.


    CALL FUNCTION 'MESSAGES_INITIALIZE'
      EXPORTING
        collect_and_send     = ' '
        reset                = 'X'
        i_store_duplicates   = 'X'
        i_no_duplicate_count = 0
        check_on_commit      = ' '
      EXCEPTIONS
        log_not_active       = 1
        wrong_identification = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
* save
    CALL FUNCTION '/THKR/FI_PSO_DOC_DIRECT_INPUT'
      EXPORTING
        i_nodata            = '/'
* Gereon Koks  T-Systems  19.5.2025
* Damit wird das NODATA-Zeichen '/' nicht entfernt
        i_del_nodata        = ''
        i_intlot            = abap_true "Interne Nummernvergabe für Bündelungsnr.
        i_check             = ms_ao_param-test_run
        i_due_date_deferral = mv_due_date_deferral
      IMPORTING
        e_bukrs             = ms_psm_ao_document_number-bukrs
        e_gjahr             = ms_psm_ao_document_number-gjahr
        e_belnr             = ms_psm_ao_document_number-belnr
        e_lotkz             = ms_psm_ao_document_number-lotkz
      TABLES
        t_bbkpf             = c_bkpf
        t_bbseg             = c_bseg
        t_bbtax             = c_btax
        t_pso50             = mt_pso50
      EXCEPTIONS
        error_message       = 1.
    IF sy-subrc = 1.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE e001(/thkr/psm_ao) WITH sy-msgid sy-msgno sy-msgv1 sy-msgv2.
    ENDIF..


    CALL FUNCTION 'MESSAGES_GIVE'
      TABLES
        t_mesg = lt_mesg.

    CALL FUNCTION 'MESSAGES_STOP'
      EXPORTING
        i_reset_messages  = abap_true
      EXCEPTIONS
        a_message         = 1
        e_message         = 2
        w_message         = 3
        i_message         = 4
        s_message         = 5
        deactivated_by_md = 6
        OTHERS            = 7.
    IF sy-subrc <> 0.
*      RAISE EXCEPTION TYPE /thkr/cx_psm_ao MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT lt_mesg ASSIGNING FIELD-SYMBOL(<fs_mesg>).
      APPEND VALUE #( type       = <fs_mesg>-msgty id         = <fs_mesg>-arbgb number     = <fs_mesg>-txtnr message    = <fs_mesg>-text
                      message_v1 = <fs_mesg>-msgv1 message_v2 = <fs_mesg>-msgv2 message_v3 = <fs_mesg>-msgv3 message_v4 = <fs_mesg>-msgv4 ) TO lt_return.
    ENDLOOP.



    IF lt_return IS NOT INITIAL AND line_exists( lt_return[ type = 'E' ] ).
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE e001(/thkr/psm_ao) WITH lt_return[ type = 'E' ]-message
        EXPORTING bapiret2_tab = lt_return.
    ENDIF.



  ENDMETHOD.
ENDCLASS.

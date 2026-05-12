class /THKR/CL_MIG_APPL definition
  public
  final
  create private .

public section.

  types:
    BEGIN OF ty_mig_gi,
        mig_obj   TYPE /thkr/mig_obj_ao,
        gi_id_bp  TYPE /thkr/gi_id,
        gi_id_ao1 TYPE /thkr/gi_id,
        gi_id_ao2 TYPE /thkr/gi_id,
        ao_type   TYPE c LENGTH 2, "AO-Anordnung, MV-Mittelvormerkung
      END OF ty_mig_gi .

  data DEF type ref to /THKR/CL_MIG_DEF read-only .
  data:
    t_mig_gi TYPE STANDARD TABLE OF ty_mig_gi read-only .

  class-methods GET_INSTANCE
    exporting
      !E_INSTANCE type ref to /THKR/CL_MIG_APPL
    returning
      value(R_INSTANCE) type ref to /THKR/CL_MIG_APPL .
  methods CHECK_MANDAT
    importing
      !I_MANDAT type SEPA_MNDID
    exporting
      !E_FLAG type /THKR/S_DTO_MIG_MANDAT_FLAG
      !E_DTO type /THKR/S_DTO_MIG_LIF
    raising
      /THKR/CX_PSM_INT_FI .
  methods CHECK_BIC
    importing
      !I_LAND type BANKS
      !I_BIC type BANKL
      !I_BLZ type BLZ optional
    exporting
      value(E_DTO) type /THKR/S_DTO_MIG_BANKL
    raising
      /THKR/CX_PSM_INT_FI .
  methods CHECK_PARTNER
    importing
      !I_EPL type /THKR/MIG_EPL
      !I_ZP_NR type /THKR/MIG_ZP_NUMMER
      !I_ZP_LFD_NR type /THKR/MIG_ZP_LFD_NUMMER
      !I_GSBER type GSBER optional
      !I_XBLNR type XBLNR
      !I_MANDAT type CHAR35 optional
    exporting
      value(E_PARTNER) type BU_PARTNER
    raising
      /THKR/CX_PSM_INT_FI .
  methods CONSTRUCTOR .
  methods CREATE_PSM_AO_BELEG
    importing
      !I_DTO_PSM_AO_BEL_CREATE type /THKR/S_DTO_MIG_AO_BEL_CREATE
      !I_MIGRATIONSOBJEKT type /THKR/MIGRATIONSOBJEKT optional
    exporting
      !E_PSM_AO_DOCUMENT_NUMBER type /THKR/S_PSM_AO_DOCUMENT_NUMBER
    raising
      /THKR/CX_PSM_INT_FI
      /THKR/CX_MIG .
  methods CREATE_RATENSTUNDUNG
    importing
      !I_SATZ_ID type /THKR/DE_SATZ_ID
    exporting
      !E_PSM_AO_DOCUMENT_NUMBER type /THKR/S_PSM_AO_DOCUMENT_NUMBER
    raising
      /THKR/CX_PSM_INT_FI
      /THKR/CX_MIG .
  methods CREATE_FM_DOCUMENT_CLEAR
    importing
      !I_SATZ_ID type /THKR/DE_SATZ_ID
    exporting
      !E_PSM_AO_DOCUMENT_NUMBER type /THKR/S_PSM_AO_DOCUMENT_NUMBER
      !E_ERROR_CLEAR type FLAG
    raising
      /THKR/CX_PSM_INT_FI
      /THKR/CX_MIG .
  methods CREATE_STUNDUNG
    importing
      !I_SATZ_ID type /THKR/DE_SATZ_ID
    exporting
      !E_PSM_AO_DOCUMENT_NUMBER type /THKR/S_PSM_AO_DOCUMENT_NUMBER
      !E_ERROR_CLEAR type FLAG
    raising
      /THKR/CX_PSM_INT_FI
      /THKR/CX_MIG .
  methods DELETE_MIG_AO
    importing
      !I_SATZ_ID type /THKR/DE_SATZ_ID .
  methods DELETE_MIG_AOS
    importing
      !I_SELECTION type /THKR/S_MIG_AO_SAP_SELECTION
      !I_MAX_STATUS type /THKR/MIG_AO_SAP_STATUS optional .
  methods RESET_MIG_AOS
    importing
      !I_SELECTION type /THKR/S_MIG_AO_SAP_SELECTION
      !I_ONLY_AO type XFELD optional .
  methods DELETE_MIG_MANDAT
    importing
      !I_EPL type /THKR/MIG_EPL
      !I_SCHLUESSEL type /THKR/MIG_MVW_SCHLUESSEL
      !I_UCI type /THKR/MIG_MVW_UCI .
  methods DELETE_MIG_RK
    importing
      !I_SATZ_ID type /THKR/DE_SATZ_ID .
  methods DISPLAY_MB
    importing
      !I_BELNR type KBLNR_DY
      !I_BLPOS type KBLPOS_DY optional .
  methods DISPLAY_FSEPA_M3
    importing
      !I_MNDID type SEPA_MNDID .
  methods DISPLAY_SSTA
    importing
      !I_BELNR type KBLNR_DY
      !I_BLPOS type KBLPOS_DY optional .
  methods GET_BUKRS_BY_EPL
    importing
      !I_DIENSTSTELLE type /THKR/MIG_RK_DIENSTSTELLE
    exporting
      !E_BUKRS type BUKRS
    raising
      /THKR/CX_MIG .
  methods GET_DTO_EPL
    importing
      value(I_EPL) type /THKR/MIG_EPL
    exporting
      value(E_DTO) type /THKR/S_DTO_MIG_EPL
    raising
      /THKR/CX_MIG .
  methods DELETE_MIG_RKS
    importing
      !I_SELECTION type /THKR/S_MIG_RK_SAP_SELECTION .
  methods GET_DTO_FINANZSTELLE
    importing
      value(I_DIENSTSTELLE) type /THKR/MIG_DIENSTSTELLE optional
      value(I_ORGEINHEIT) type /THKR/MIG_ORGEINHEIT optional
      value(I_MIGRATIONSOBJEKT) type /THKR/MIGRATIONSOBJEKT optional
    exporting
      value(E_DTO) type /THKR/S_DTO_MIG_FINANZSTELLE
    raising
      /THKR/CX_MIG .
  methods GET_DTO_MIGOBJ_PARA
    importing
      !I_MIG_OBJ type /THKR/MIGRATIONSOBJEKT
    exporting
      !E_DTO type /THKR/S_DTO_MIG_MIGOBJ_PARA
    raising
      /THKR/CX_MIG .
  methods GET_DTO_MIG_AO
    importing
      !I_SATZ_ID type /THKR/DE_SATZ_ID optional
      !I_XBLNR type XBLNR optional
      !I_XBLNR_POS_NR type /THKR/RK_POS_NR optional
      !I_HAUPT_NEBENFORDERUNG type /THKR/MIG_HF_NF optional
    exporting
      !E_DTO type /THKR/S_DTO_MIG_AO_SAP .
  methods GET_DTO_MIG_LIF
    importing
      !I_ZP_NR type /THKR/MIG_ZP_NUMMER optional
      !I_ZP_LFD_NR type /THKR/MIG_ZP_LFD_NUMMER optional
    exporting
      !E_DTO type /THKR/S_DTO_MIG_LIF .
  methods GET_DTO_MIG_MD
    exporting
      !E_DTO type /THKR/S_DTO_MIG_MD
    raising
      /THKR/CX_MIG .
  methods GET_DTO_MIG_MVW_ME
    importing
      !I_SELECTION type /THKR/S_MIG_MVW_SAP_SELECTION
    exporting
      !E_DTO type /THKR/S_DTO_MIG_MVW .
  methods GET_DTO_MIG_MVW
    importing
      !I_SCHLUESSEL type /THKR/MIG_MVW_SCHLUESSEL
      !I_UCI type /THKR/MIG_MVW_UCI
      !I_EPL type /THKR/MIG_EPL
    exporting
      !E_DTO type /THKR/S_DTO_MIG_MVW .
  methods GET_DTO_MIG_PROC_EXP_CAMT
    importing
      !I_PROCESS_ID type /THKR/PROCESS_ID
    exporting
      !E_DTO type /THKR/S_DTO_MIG_PROC_EXP_CAMT .
  methods GET_DTO_FIPOS_SAKNR
    importing
      value(I_EPL) type /THKR/MIG_EPL
      value(I_KAPITEL) type /THKR/MIG_KAPITEL
      value(I_TITEL) type /THKR/MIG_TITEL_PROFISKAL
      value(I_UNTERKONTO) type /THKR/MIG_UNTERKONTO optional
      value(I_BUKRS) type BUKRS optional
      value(I_GJHID) type GJHID optional
      value(I_DIENSTSTELLE) type /THKR/MIG_DIENSTSTELLE optional
      value(I_ORGEINHEIT) type /THKR/MIG_ORGEINHEIT optional
      !I_MIGRATIONSOBJEKT type /THKR/MIGRATIONSOBJEKT optional
    exporting
      value(E_DTO) type /THKR/S_DTO_MIG_FIPOS_SAKNR
    raising
      /THKR/CX_MIG .
  methods GET_DTO_OEH
    importing
      value(I_EPL) type /THKR/MIG_EPL optional
      value(I_DIENSTSTELLE) type /THKR/MIG_DIENSTSTELLE optional
      value(I_ORGEINHEIT) type /THKR/MIG_ORGEINHEIT optional
      value(I_KAPITEL) type /THKR/MIG_KAPITEL optional
      value(I_TITEL) type /THKR/MIG_TITEL_PROFISKAL optional
      value(I_UNTERKONTO) type /THKR/MIG_UNTERKONTO optional
      value(I_MIGRATIONSOBJEKT) type /THKR/MIGRATIONSOBJEKT optional
    exporting
      value(E_DTO) type /THKR/S_DTO_MIG_ORGEINHEIT
    raising
      /THKR/CX_MIG .
  methods GET_EXECUTE_DAY
    importing
      value(I_ZAHLWEISE) type CHAR01
      value(I_DATE) type SY-DATUM
      value(I_FACTORY_CALENDAR_ID) type SCAL-FCALID
    exporting
      value(E_DAY) type CHAR02 .
  methods GET_LASTUSE_DATE
    importing
      value(I_DAT_GUELTIGKEIT) type SY-DATUM
    exporting
      value(E_DTO) type /THKR/S_DTO_MIG_LASTUSE_DATE .
  methods GET_IMPORT_FILES
    importing
      !I_FILENAME type /THKR/FILE_W_PATH
      !I_FRONTEND type XFELD
    exporting
      !E_DIRECTORY type STRING
      !E_FILES type /THKR/T_MIG_FILE_W_PATH .
  methods GET_LN_KEY_MIG_MANDAT
    importing
      !I_EPL type /THKR/MIG_EPL
      !I_SCHLUESSEL type /THKR/MIG_MVW_SCHLUESSEL
      !I_UCI type /THKR/MIG_MVW_UCI
    exporting
      !E_LN_KEY type /THKR/EVENT_LN_KEY .
  methods GET_MIG_AO_SATZ_ID
    importing
      !I_MIG_AO type /THKR/S_DTO_MIG_AO optional
      !I_MIG_VSA_SVZ type /THKR/S_MIG_VSA_SVZ optional
    exporting
      !E_SATZ_ID type /THKR/DE_SATZ_ID .
  methods GET_MIG_RK_SATZ_ID
    importing
      !I_MIG_RK type /THKR/S_DTO_MIG_RK optional
      !I_MIG_RKN type /THKR/S_MIG_RKN_K optional
      !I_MIG_RKV type /THKR/S_MIG_RKV_K optional
      !I_MIG_AHE type /THKR/S_MIG_AHE_K optional
      !I_MIG_RKA type /THKR/S_MIG_RKA_K optional
      !I_MIG_BORE type /THKR/S_MIG_BORE_K optional
    exporting
      !E_SATZ_ID type /THKR/DE_SATZ_ID .
  methods GET_TDTO_MIG_LIF
    importing
      !I_SELECTION type /THKR/S_MIG_LIF_SAP_SELECTION
    exporting
      !ET_DTO type /THKR/T_DTO_MIG_LIF .
  methods GET_TDTO_MIG_MVW
    importing
      !I_SELECTION type /THKR/S_MIG_MVW_SAP_SELECTION
    exporting
      !ET_DTO type /THKR/T_DTO_MIG_MVW .
  methods GET_TDTO_MIG_RUN
    importing
      !I_SELECTION type /THKR/S_MIG_RUN_SELECTION
    exporting
      !ET_DTO type /THKR/T_DTO_MIG_IMP .
  methods INITIALIZE_MVW
    importing
      !I_EPL type /THKR/MIG_EPL optional
      !I_SCHLUESSEL type /THKR/MIG_MVW_SCHLUESSEL optional
      !I_UCI type /THKR/MIG_MVW_UCI optional
      !I_SELECTION type /THKR/S_MIG_MVW_SAP_SELECTION .
  methods INIT_DTO_MIG_PROC_EXP_CAMT
    importing
      !I_PROCESS_ID type /THKR/PROCESS_ID
      !I_BOOKG_DT type BUDAT
    exporting
      !E_DTO type /THKR/S_MIG_CAMT_HEADER .
  methods PROCESS_EXPORT_CAMT
    importing
      !I_SELECTION type /THKR/S_MIG_AO_SAP_SELECTION
      !I_PATH type /THKR/FILE_W_PATH optional
      !I_FRONTEND type XFELD optional
      !I_TEST type XFELD optional .
  methods PROCESS_IMPORT
    importing
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE
      !I_OBJEKT_TYPE type /THKR/MIGRATIONSOBJEKT
      !I_FILENAME type /THKR/FILE_W_PATH
      !I_FRONTEND type XFELD
      !I_IMPORT_ONLY type XFELD optional
      !I_MOVE_ARCHIV type XFELD optional
      !I_TEST_SUFFIX type /THKR/TEST_SUFFIX optional
      !I_TEST type XFELD optional
      !I_EPL type /THKR/MIG_EPL optional
      !I_ARCHIV_DIRECTORY type /THKR/FILE_W_PATH optional
      !I_PROT_DETAIL type XFELD optional
      !I_UPDATE_ALLOWED type XFELD optional .
  methods PROCESS_MIG_AO
    importing
      !I_SATZ_ID type /THKR/DE_SATZ_ID
      !I_MAX_STATUS type /THKR/MIG_AO_SAP_STATUS optional
      !I_IGNORE_RK_ERROR type XFELD optional
      !I_BETRAG_0 type XFELD optional .
  methods PROCESS_MIG_AOS
    importing
      value(I_SELECTION) type /THKR/S_MIG_AO_SAP_SELECTION
      !I_MAX_STATUS type /THKR/MIG_AO_SAP_STATUS optional
      !I_IGNORE_RK_ERROR type XFELD optional .
  methods PROCESS_MIG_MANDAT
    importing
      !I_EPL type /THKR/MIG_EPL
      !I_SCHLUESSEL type /THKR/MIG_MVW_SCHLUESSEL
      !I_UCI type /THKR/MIG_MVW_UCI .
  methods PROCESS_MIG_MANDATS
    importing
      !I_SELECTION type /THKR/S_MIG_MVW_SAP_SELECTION .
  methods PROCESS_MIG_RK
    importing
      !I_SATZ_ID type /THKR/DE_SATZ_ID
    raising
      /THKR/CX_MIG .
  methods RESET_MIG_AO
    importing
      !I_SATZ_ID type /THKR/DE_SATZ_ID
      !I_ONLY_AO type XFELD optional .
  methods SET_FLAG_NO_MS2
    importing
      !I_FLAG_NO_MS2 type /THKR/MIG_FLAG_NO_MS2 .
  methods PROCESS_MIG_ABSETZUNG_BTR0
    importing
      !I_SELECTION type /THKR/S_MIG_AO_SAP_SELECTION .
  methods PROCESS_MIG_ABSETZUNG_RK
    importing
      !I_SELECTION type /THKR/S_MIG_AO_SAP_SELECTION .
  methods PROCESS_MIG_ABSETZUNG_UEZ
    importing
      !I_SELECTION type /THKR/S_MIG_AO_SAP_SELECTION .
protected section.

  data PAYAC_SAKNR_HIT_FIRST type /THKR/MIG_PAYACSAKNR_HIT_FIRST .

  methods START_PROCESS_MIG_AO_AS_JOB
    importing
      !IT_DTO_MIG_AO_SAP type /THKR/T_DTO_MIG_AO_SAP
      !I_SELECTION type /THKR/S_MIG_AO_SAP_SELECTION
      !I_IGNORE_RK_ERROR type XFELD
      !I_MAX_STATUS type /THKR/MIG_AO_SAP_STATUS
    exporting
      !E_BTCJOB type BTCJOB
      !E_BTCJOBCNT type BTCJOBCNT .
  methods CREATE_ACC_DOC_POST
    importing
      !I_DTO_PSM_AO_BEL_CREATE type /THKR/S_DTO_MIG_AO_BEL_CREATE
    exporting
      !E_PSM_AO_DOCUMENT_NUMBER type /THKR/S_PSM_AO_DOCUMENT_NUMBER
    raising
      /THKR/CX_PSM_INT_FI .
  methods CREATE_EDAS_DATA
    importing
      !I_DTO_MIG_AO_SAP type /THKR/S_DTO_MIG_AO_SAP
    returning
      value(R_SUBRC) type SYST_SUBRC .
private section.

  class-data INSTANCE type ref to /THKR/CL_MIG_APPL .
  data FLAG_NO_MS2 type /THKR/MIG_FLAG_NO_MS2 .
  data HELPERS type ref to /THKR/CL_HELPERS .
  data MIG_EXPORT type ref to /THKR/CL_MIG_EXPORT_CAMT .
  data MIG_IMPORT type ref to /THKR/CL_MIG_IMPORT .
  data MIG_RK type ref to /THKR/CL_MIG_RK .
ENDCLASS.



CLASS /THKR/CL_MIG_APPL IMPLEMENTATION.


  METHOD check_bic.

* Prüfen ob die BIC in den Bankenstammdaten vorhanden ist. Nur bei ausländischen Banken!
* Variante 1: Mit 11 Stellen
* Variante 2: mit  8 Stellen

*    BREAK zhm000000144.

    DATA: lv_bankl TYPE bankk.

    CLEAR:  e_dto.


    IF NOT i_land IS INITIAL AND NOT i_bic IS INITIAL AND NOT i_land = 'DE'.

      lv_bankl = i_bic.

      CASE  i_land.

        WHEN 'BE'.
* Sonderfall BE
          SELECT SINGLE bankl FROM bnka WHERE banks = @i_land
                                          AND bankl = @lv_bankl+0(03)
                                         INTO @e_dto.


        WHEN OTHERS .
* ausländischen Banken ohne Sonderfälle ( 1. Versuch vollständig, 2.Versuch ohne die letzen "XXX".
          SHIFT lv_bankl LEFT DELETING LEADING space.

          SELECT SINGLE bankl FROM bnka WHERE banks = @i_land
                                          AND bankl = @lv_bankl
                                         INTO @e_dto.

          IF sy-subrc NE 0.
            SELECT SINGLE bankl FROM bnka WHERE banks   = @i_land
                                            AND bankl   = @lv_bankl+0(08)
                                           INTO @e_dto.
          ENDIF.

      ENDCASE.

    ENDIF.

  ENDMETHOD.


  METHOD check_mandat.
*I_MANDAT
*E_FLAG

*******E_FLAG  Type /THKR/S_DTO_MIG_MANDAT_FLAG

* Prüfen ob ein Mandat bereits, angelegt wurde.

    e_flag = space. "nicht angelegt

    DATA: i_sel_criteria       TYPE sepa_get_criteria_mandate.
    DATA: lt_mandate TYPE sepa_tab_data_mandate_data.

    CALL FUNCTION 'SEPA_GET_MANDAT_BY_MNDID'
      EXPORTING
        i_mndid             = i_mandat
        i_mvers             = '0000'
        i_anwnd             = 'F'
        i_flg_ignore_buffer = ' '
        i_flg_old_state     = ' '
        i_flg_ignore_db     = ' '
      IMPORTING
        et_mandates         = lt_mandate.

    IF NOT lt_mandate[] IS INITIAL.
* Mandat ist bereits angelegt
      e_flag =  'X'.
    ENDIF.

  ENDMETHOD.


  METHOD check_partner.

*  Prüfen ob ein GP bereits angelegt wurde.
*  Eindeutigkeit ist über Einzelplan und Zahlungspartnernummer hergestellt. Beide Werte werden 1:1 aus der XML übernommen.
*  Laufende Nummer ZP_LFD_NR wird nicht berückdichtigt!

    CLEAR:  e_partner.

    IF i_xblnr IS NOT INITIAL.
      "Prüfen, ob zum Kassenzeichen bereits ein ZP angelegt wurde
      SELECT SINGLE *
        FROM /thkr/mig_ao_sap
        WHERE xblnr   = @i_xblnr
          AND partner IS NOT INITIAL
        INTO @DATA(l_mig_ao_sap).

      IF sy-subrc = 0.
        "Partner gefunden
        e_partner = l_mig_ao_sap-partner.
        RETURN.
      ENDIF.
    ENDIF.

    ASSERT i_epl   IS NOT INITIAL.
    ASSERT i_zp_nr IS NOT INITIAL.

*Keine Prüfug bei Einmal LIF <ZP_NUMMER>001</ZP_NUMMER>
*   l_dto_mig_ao-ZP_NUMMER       = '001'.
*   l_dto_mig_ao-KURZBEZEICHNUNG = 'EINMAL-LIF'.
    IF i_zp_nr NE '001' AND i_zp_nr NE '1' AND i_zp_nr NE '0001'.

* GP pro Geschäftbereich / Dienststelle nur einmal anlegen
      SELECT SINGLE *
        FROM /thkr/mig_ao_sap
        WHERE epl              = @i_epl          " Einzelplan
          AND zp_nr            = @i_zp_nr        " Zahlungspartnernummer
          AND zp_lfd_nr        = @i_zp_lfd_nr    " Zahlungspartner laufende Nummer
          AND zp_gsber         = @i_gsber " Geschäftsbereich /Dienststelle
          AND partner IS NOT INITIAL
        INTO @l_mig_ao_sap.

      IF sy-subrc = 0.
        e_partner = l_mig_ao_sap-partner.
      ELSE.
* Da bereits über die Stammdaten Einzelmandate migriert werden,
* welche zu einem späteren Zeitpunkt nochmal über die offenen Posten geliefert werden können, soll folgende Logik umgesetzt werden:
* Prüfung, ob Geschäftsbereich zwischen Mandat und offenem Posten übereinstimmt
* Prüfung, ob Kassenzeichen zwischen Mandat und offenem Posten übereinstimmt
* Lesen ob es Mandant schon gibt.
        IF i_xblnr IS NOT INITIAL AND i_mandat IS NOT INITIAL.
          SELECT SINGLE snd_id, /thkr/gsber, /thkr/xblnr FROM sepa_mandate INTO @DATA(ls_sepa_mandate)
            WHERE anwnd = 'F' AND mndid = @i_mandat.
          IF sy-subrc = 0 AND
* Wenn der Geschäftsbereich und das Kassenzeichen übereinstimmt
             ( ls_sepa_mandate-/thkr/gsber = i_gsber AND ls_sepa_mandate-/thkr/xblnr = i_xblnr ) OR
* oder der Geschäftsbereich übereinstimmt und das Kassenzeichen im Mandat nicht gefüllt ist,
            ( ls_sepa_mandate-/thkr/gsber = i_gsber AND ls_sepa_mandate-/thkr/xblnr = '' )
* soll die Anordnung dem Geschäftspartner mit diesem Mandat zugewiesen werden.
* Wenn der Geschäftsbereich oder das Kassenzeichen nicht übereinstimmt soll der offene Posten auf Fehler laufen.
            .
            e_partner = ls_sepa_mandate-snd_id.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD constructor.

    def = /thkr/cl_mig_def=>get_instance( ).
    helpers = /thkr/cl_helpers=>get_instance( ).
    mig_rk = /thkr/cl_mig_rk=>get_instance( ).

    t_mig_gi = VALUE #(
      ( mig_obj = 'NF'    gi_id_bp = 'MIG_GP_RK'  gi_id_ao1 = 'MIG_AO_NF'   ao_type = 'AO' )
      ( mig_obj = 'SSTE'  gi_id_bp = 'MIG_GP'     gi_id_ao1 = 'MIG_AO'      ao_type = 'AO' )
      ( mig_obj = 'IOS'   gi_id_bp = 'MIG_GP_IOS' gi_id_ao1 = 'MIG_AO_IOS'  ao_type = 'AO' )
      ( mig_obj = 'VSA'   gi_id_bp = 'MIG_GP_VSA' gi_id_ao1 = 'MIG_AO_VSA'  ao_type = 'AO' )
      ( mig_obj = 'SSTA'  gi_id_bp = 'MIG_GP'     gi_id_ao1 = 'MIG_MV'      ao_type = 'MV' )
      ( mig_obj = 'ALL'   gi_id_bp = 'MIG_GP'     gi_id_ao1 = 'MIG_AO_ALL'  ao_type = 'MV' )
      ( mig_obj = 'SSTW'  gi_id_bp = 'MIG_GP'     gi_id_ao1 = 'MIG_AO_SSTW' ao_type = 'AO' )
      ( mig_obj = 'AWD'   gi_id_bp = 'MIG_GP'     gi_id_ao1 = 'MIG_AO_AWD'  ao_type = 'AO' )
      ( mig_obj = 'SEE_E' gi_id_bp = 'MIG_GP'     gi_id_ao1 = 'MIG_AO'      ao_type = 'AO' )
      ( mig_obj = 'SEE_A' gi_id_bp = 'MIG_GP'     gi_id_ao1 = 'MIG_AO_ALL'  ao_type = 'MV' )
      ( mig_obj = 'SEA_A' gi_id_bp = 'MIG_GP'     gi_id_ao1 = 'MIG_MV'      ao_type = 'MV' )
      ( mig_obj = 'SSTS'  gi_id_bp = 'MIG_GP'     gi_id_ao1 = 'MIG_AO'      ao_type = 'AO' )
                        ).

  ENDMETHOD.


  METHOD create_acc_doc_post.
* Buchungsszenario für die EDAS-SST (Fall 5; Vollzahlung, soll aber nicht ausgeglichen werden wg Einspruchsfrist des Zahlungspflichtigen)
*-  Belegart für die Zahlung ist DZ
*-  Das Verrechnungskonto ist 4893000100


    DATA:
      lv_obj_type          TYPE awtyp,
      lv_obj_key           TYPE awkey,
      ls_accountgl         TYPE bapiacgl09,
      ls_accountreceivable TYPE bapiacar09,
      lv_itemno            TYPE posnr_acc,
      lt_return            TYPE TABLE OF bapiret2,
      lt_currencyamount    TYPE TABLE OF bapiaccr09,
      ls_currencyamount    TYPE  bapiaccr09,
      lt_accountgl         TYPE TABLE OF bapiacgl09,
      lt_accountreceivable TYPE TABLE OF bapiacar09,
      ls_documentheader    TYPE bapiache09.


* Header füllen
    ls_documentheader-obj_type    = 'BKPFF'.
    ls_documentheader-obj_sys     = sy-mandt.
    ls_documentheader-bus_act     = 'RFBU'. "Betriebswirtschaftlicher Vorgang
    ls_documentheader-username    = sy-uname.
    ls_documentheader-header_txt  = i_dto_psm_ao_bel_create-bktxt.
    ls_documentheader-doc_type    = 'DZ'. "i_dto_psm_ao_bel_create-blart.
    ls_documentheader-doc_date    = i_dto_psm_ao_bel_create-bldat.
    ls_documentheader-pstng_date  = i_dto_psm_ao_bel_create-budat.
    ls_documentheader-comp_code   = i_dto_psm_ao_bel_create-bukrs.
    ls_documentheader-ref_doc_no  = i_dto_psm_ao_bel_create-xblnr.



* Debitorposition
    ADD 1 TO lv_itemno.
    ls_accountreceivable-itemno_acc = lv_itemno.
    ls_accountreceivable-ref_key_1  = i_dto_psm_ao_bel_create-rebzg. " Rechnungsbezug
    ls_accountreceivable-ref_key_2  = i_dto_psm_ao_bel_create-rebzj. " Rechnungsbezug
    ls_accountreceivable-ref_key_3  = i_dto_psm_ao_bel_create-rebzz. " Rechnungsbezug
    ls_accountreceivable-comp_code = i_dto_psm_ao_bel_create-bukrs.
    ls_accountreceivable-customer   = i_dto_psm_ao_bel_create-partner.
    ls_accountreceivable-partner_bk = i_dto_psm_ao_bel_create-bvtyp.
    ls_accountreceivable-item_text  = i_dto_psm_ao_bel_create-t_kont[ 1 ]-sgtxt.
    ls_accountreceivable-bline_date = i_dto_psm_ao_bel_create-zfbdt. "Basisdatum
    ls_accountreceivable-dunn_key   = i_dto_psm_ao_bel_create-mansp.
    ls_accountreceivable-dunn_area   = i_dto_psm_ao_bel_create-maber.
    ls_accountreceivable-pymt_meth   = i_dto_psm_ao_bel_create-zlsch.
    ls_accountreceivable-pmnttrms  = i_dto_psm_ao_bel_create-zterm.
    ls_accountreceivable-dsct_days1  = i_dto_psm_ao_bel_create-zbd1t.
    ls_accountreceivable-scbank_ind  = i_dto_psm_ao_bel_create-lzbkz.
    ls_accountreceivable-supcountry  = i_dto_psm_ao_bel_create-landl.
    ls_accountreceivable-bus_area  = i_dto_psm_ao_bel_create-t_kont[ 1 ]-gsber.
    APPEND ls_accountreceivable TO lt_accountreceivable.

    ls_currencyamount-itemno_acc = lv_itemno.
    ls_currencyamount-currency = i_dto_psm_ao_bel_create-waers.
    ls_currencyamount-currency_iso = i_dto_psm_ao_bel_create-waers.
    ls_currencyamount-amt_doccur = -1 * CONV wrbtr( REDUCE #( INIT x TYPE wrbtr FOR wa IN i_dto_psm_ao_bel_create-t_kont NEXT x += wa-wrbtr ) ).
    APPEND ls_currencyamount TO lt_currencyamount.

* Sachkontenzeile
*    LOOP AT i_dto_psm_ao_bel_create-t_kont INTO DATA(ls_kont).
    ADD 1 TO lv_itemno.
    ls_accountgl-itemno_acc = lv_itemno.
    ls_accountgl-acct_type  = 'S'.
    ls_accountgl-gl_account = '4893000100'.
    ls_accountgl-doc_type  = 'DZ'.
    ls_accountgl-comp_code = i_dto_psm_ao_bel_create-bukrs.
    ls_accountgl-item_text = ls_accountreceivable-item_text."ls_kont-sgtxt.
    APPEND ls_accountgl TO lt_accountgl.

    ls_currencyamount-itemno_acc = lv_itemno.
    ls_currencyamount-currency = i_dto_psm_ao_bel_create-waers.
    ls_currencyamount-currency_iso = i_dto_psm_ao_bel_create-waers.
    ls_currencyamount-amt_doccur = ls_currencyamount-amt_doccur * -1. "ls_kont-wrbtr.
    APPEND ls_currencyamount TO lt_currencyamount.
*    ENDLOOP.


* Buchungs BAPI aufrufen
    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader    = ls_documentheader
      IMPORTING
        obj_type          = lv_obj_type
        obj_key           = lv_obj_key
      TABLES
        accountgl         = lt_accountgl
        accountreceivable = lt_accountreceivable
        currencyamount    = lt_currencyamount
        return            = lt_return.


    IF lt_return IS NOT INITIAL AND line_exists( lt_return[ type = 'E' ] ).
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE e001(/thkr/psm_ao) WITH lt_return[ type = 'E' ]-message
          EXPORTING bapiret2_tab = lt_return.
    ENDIF.

    e_psm_ao_document_number-bukrs  =  lv_obj_key+10(4).
    e_psm_ao_document_number-belnr  =  lv_obj_key+0(10).
    e_psm_ao_document_number-gjahr  =  lv_obj_key+14(4).

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.


  ENDMETHOD.


  METHOD create_edas_data.

    DATA:
          lv_qbelnr_n(8) TYPE n.

    SELECT SINGLE MAX( qbelnr ) FROM /thkr/t_edas_0 INTO @DATA(lv_qbelnr).

    lv_qbelnr_n = lv_qbelnr.
    ADD 1 TO lv_qbelnr_n.

    DATA(ls_edas) = VALUE /thkr/t_edas_0(
                                        mandt    = sy-mandt
                                        filename = 'Migration'
                                        btyp     = 'SST' "SST / SSR 01_BTYP
                                        merkm    = 'A' " 02-Merkmal
                                        hhj      = i_dto_mig_ao_sap-haushaltsjahr "04-Haushaltsjahr
                                        quelle   = '000000' " 05-Kennzeichen Quelle
                                        qbelnr   = lv_qbelnr_n " 06-Quell-Belegnr.
                                        aob      = i_dto_mig_ao_sap-einzelplan " 09-Bereich
                                        kap      = i_dto_mig_ao_sap-kapitel " 10-Kapitel /Gliederung
                                        titel    = i_dto_mig_ao_sap-titel " 11-Titel / Gruppierung
                                        oeh      = i_dto_mig_ao_sap-organisationseinheit " 12-OrgEinheit
                                        msn      = i_dto_mig_ao_sap-unterkonto " 13-Unterkonto
                                        fdatum   = i_dto_mig_ao_sap-fealligkeit " 17-Fälligkeitsdatum
                                        betr2    = '                  E' "16-Zusatzfeld, var. belegt "18 Blanks + „E“.
                                        txtsl    = i_dto_mig_ao_sap-adfschluessel " 19-Zusatzschlüssel
                                        bkz      = 'E' " 21-Belastung/Entlastung
                                        lifnr    = i_dto_mig_ao_sap-zp_nr " 23-Zahlungspartner-Nr.
                                        bvnr     = '1' "25-Lfd. Nr. Bankadresse beim ZP
                                        zweg     = '4' " 27-Kassen-Nr.
                                        aktz     = i_dto_mig_ao_sap-aktenzeichen " 28-Aktenzeichen
                                        grund    = i_dto_mig_ao_sap-verwendungszweck "  29-Zahlungsgrund
                                        kassz    = i_dto_mig_ao_sap-kassenzeichen " 32-In/Output Kassenzeichen
                                        ).

    MODIFY /thkr/t_edas_0 FROM ls_edas.
    r_subrc = sy-subrc.

  ENDMETHOD.


  METHOD create_fm_document_clear.


    ASSERT i_satz_id IS NOT INITIAL.

    DATA: ls_dto_act   TYPE /thkr/s_dto_psm_ao,
          ls_ao_create TYPE /thkr/s_dto_mig_ao_bel_create,
          inst_appl    TYPE REF TO /thkr/cl_mig_psm_ao_appl.




    get_dto_mig_ao(
      EXPORTING
        i_satz_id = i_satz_id
      IMPORTING
        e_dto     = DATA(l_dto_mig_ao) ).


    inst_appl = /thkr/cl_mig_psm_ao_appl=>mig_get_instance( ).

    ls_dto_act = inst_appl->get_dto_psm_ao(
      EXPORTING
        i_lotkz = l_dto_mig_ao-lotkz
        i_bukrs = l_dto_mig_ao-bukrs
        i_gjahr = l_dto_mig_ao-gjahr
        i_belnr = l_dto_mig_ao-belnr
    ).


    MOVE-CORRESPONDING ls_dto_act TO ls_ao_create EXPANDING NESTED TABLES.
    ls_ao_create-psoty ='06'. "Stundung

    LOOP AT ls_dto_act-t_beleg ASSIGNING FIELD-SYMBOL(<fs_beleg>).
      MOVE-CORRESPONDING  <fs_beleg> TO ls_ao_create EXPANDING NESTED TABLES.
    ENDLOOP.
    ls_ao_create-blart ='SD'.


    /thkr/cl_mig_psm_ao_appl=>mig_get_instance( )->create_psm_ao_beleg1(
      EXPORTING
         i_dto_psm_ao_bel_create = ls_ao_create
         i_fm_document_clear = abap_true
      IMPORTING
        e_psm_ao_document_number = DATA(l_psm_ao_document_number)
        e_error_clear = e_error_clear ).



    e_psm_ao_document_number = l_psm_ao_document_number.


  ENDMETHOD.


  METHOD create_psm_ao_beleg.



    DATA: lv_fikrs  TYPE fikrs,
          lv_fipex  TYPE fm_fipex,
          l_message TYPE string.

    DATA: l_proc   TYPE REF TO /thkr/cl_bfw_process,
          l_ln_art TYPE /thkr/event_ln_art,
          l_ln_key TYPE /thkr/event_ln_key.




* 1. Prüfen ob die Finanzstelle vorhanden ist, wenn nicht Fehler und Abbruch (für jeder Position)

    LOOP AT i_dto_psm_ao_bel_create-t_kont INTO DATA(t_kont).

      lv_fikrs = t_kont-fikrs.
      lv_fipex = t_kont-fistl.

      SELECT SINGLE * INTO @DATA(ls_fmfctr)
        FROM fmfctr
        WHERE fikrs = @lv_fikrs
        AND   fictr = @lv_fipex
        AND  datbis >= @sy-datum.


      IF ls_fmfctr IS INITIAL.
        RAISE EXCEPTION TYPE /thkr/cx_mig
             MESSAGE e001(/thkr/mig) WITH lv_fipex.
      ENDIF.

    ENDLOOP.


* 2. Beleg erstellen

    /thkr/cl_mig_psm_ao_appl=>mig_get_instance( )->create_psm_ao_beleg1(
      EXPORTING
         i_dto_psm_ao_bel_create = i_dto_psm_ao_bel_create
         i_mig_obj = i_migrationsobjekt
      IMPORTING
        e_psm_ao_document_number = e_psm_ao_document_number ).

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true
*     IMPORTING
*       RETURN        =
      .


  ENDMETHOD.


  METHOD create_ratenstundung.


    ASSERT i_satz_id IS NOT INITIAL.

    DATA: ls_dto_act   TYPE /thkr/s_dto_psm_ao,
          ls_ao_create TYPE /thkr/s_dto_psm_ao_bel_create,
          inst_appl    TYPE REF TO /thkr/cl_mig_psm_ao_appl.




* 1. Daten Beschaffen

* 1.1 Migrationstabelle
    get_dto_mig_ao(
      EXPORTING
        i_satz_id = i_satz_id
      IMPORTING
        e_dto     = DATA(l_dto_mig_ao) ).

* 1.2 für die Stundung
    inst_appl = /thkr/cl_mig_psm_ao_appl=>mig_get_instance( ).


    ls_dto_act = inst_appl->get_dto_psm_ao(
      EXPORTING
        i_lotkz = l_dto_mig_ao-lotkz
        i_bukrs = l_dto_mig_ao-bukrs
        i_gjahr = l_dto_mig_ao-gjahr
        i_belnr = l_dto_mig_ao-belnr
    ).




* 2. Container Belegen


    MOVE-CORRESPONDING ls_dto_act TO ls_ao_create EXPANDING NESTED TABLES.
    ls_ao_create-psoty ='06'. "Stundung

    LOOP AT ls_dto_act-t_beleg ASSIGNING FIELD-SYMBOL(<fs_beleg>).
      MOVE-CORRESPONDING  <fs_beleg> TO ls_ao_create EXPANDING NESTED TABLES.
    ENDLOOP.
    ls_ao_create-blart ='SD'.

* Neu DF-1305 Stundung SD Beleg mit Mahnsperre 5
    ls_ao_create-mansp = '5'.

* mit i_dto_psm_ao_bel_create-gen_due_date = '' können die Raten direkt in T_KONT übergeben werden
* mit gen_due_date = abap_true werden die Raten von der Methode selbst berechnet
* Wir nehmen die Raten aus dem RK

    /thkr/cl_mig_rk=>get_instance( )->get_dto_mig_rk(
      EXPORTING
        i_xblnr   = ls_ao_create-xblnr
        IMPORTING
         e_dto    = DATA(lt_rk_dto) ).

* Pro Rate wird immer die gleiche Kontierung verwendet
* Es muss die DTO Tabelle für Rate/Datum aufgebaut werden
* Es werden nur die HF gestundet, NF werden separat gebucht
    SORT lt_rk_dto-t_rk_faell BY faellig_dtu.
    LOOP AT lt_rk_dto-t_rk_faell ASSIGNING FIELD-SYMBOL(<fs_rk_faell>) WHERE offen > 0 AND soll_hf > 0.
      DATA(lv_lines) = lines( ls_ao_create-t_due_date ).

* Rate + Datum ermitteln
      LOOP AT <fs_rk_faell>-t_rk_pos ASSIGNING FIELD-SYMBOL(<fs_rk_pos>) WHERE sollhf > 0.
        DATA(lv_betr) = CONV wrbtr( CONV wrbtr( <fs_rk_pos>-sollhf ) + CONV wrbtr( <fs_rk_pos>-sollnf ) - CONV wrbtr( <fs_rk_pos>-ist ) ).
        IF lv_betr > 0.
          APPEND VALUE #( dzfbdt = <fs_rk_faell>-faellig_dtu wrbtr  = lv_betr ) TO ls_ao_create-t_due_date.
        ENDIF.
      ENDLOOP.

* Wenn neue Rate ermittelt dann Intervall ermitteln.
      IF lv_lines < lines( ls_ao_create-t_due_date ).
        " aus Differenz zw. 1. und 2. Rate das Intervall bestimmen
        IF ls_ao_create-psoin IS INITIAL AND ls_ao_create-psodt IS NOT INITIAL.
          ls_ao_create-psoin = ( CONV datum( <fs_rk_faell>-faellig_dtu ) - ls_ao_create-psodt ) DIV 28.  "  Intervall zw. Raten in Monaten
        ENDIF.
        " kleinsten Tag merken
        IF ls_ao_create-psodt IS INITIAL.
          ls_ao_create-psodt = <fs_rk_faell>-faellig_dtu.  "  1. Fälligkeitstag
        ENDIF.
      ENDIF.
    ENDLOOP.
    " wenn nur 1. Rate vorhanden, dann = 1 setzen
    IF ls_ao_create-psoin IS INITIAL AND ls_ao_create-psodt IS NOT INITIAL.
      ls_ao_create-psoin = 1.
    ENDIF.

*     ls_ao_create-psoac = ''. "  Ratenbetrag
    ls_ao_create-psomo = lines( ls_ao_create-t_due_date ).  "  Anzahl der Raten

    ls_ao_create-psoxb = abap_true. " immer direkt buchen


    IF ls_ao_create-psodt IS INITIAL.
      " wenn keine Raten dann mit Meldung beenden
      RAISE EXCEPTION TYPE /thkr/cx_mig
           MESSAGE e041(/thkr/mig) WITH i_satz_id.
    ENDIF.

* 3. Stundung Anlegen

    /thkr/cl_mig_psm_ao_appl=>mig_get_instance( )->create_due_date_deferral(
      EXPORTING
        i_dto_psm_ao_bel_create  = ls_ao_create                 " DTO: Anlegen eines Beleges zu einer PSM-Anordnung
      IMPORTING
        e_psm_ao_document_number = DATA(l_psm_ao_document_number)                 " Beleg Nummer zu AO
    ).




    e_psm_ao_document_number = l_psm_ao_document_number.


  ENDMETHOD.


  METHOD create_stundung.


    ASSERT i_satz_id IS NOT INITIAL.

    DATA: ls_dto_act   TYPE /thkr/s_dto_psm_ao,
          ls_ao_create TYPE /thkr/s_dto_mig_ao_bel_create,
          inst_appl    TYPE REF TO /thkr/cl_mig_psm_ao_appl.




* 1. Daten Beschaffen

* 1.1 Migrationstabelle
    get_dto_mig_ao(
      EXPORTING
        i_satz_id = i_satz_id
      IMPORTING
        e_dto     = DATA(l_dto_mig_ao) ).

* 1.2 für die Stundung
    inst_appl = /thkr/cl_mig_psm_ao_appl=>mig_get_instance( ).


    ls_dto_act = inst_appl->get_dto_psm_ao(
      EXPORTING
        i_lotkz = l_dto_mig_ao-lotkz
        i_bukrs = l_dto_mig_ao-bukrs
        i_gjahr = l_dto_mig_ao-gjahr
        i_belnr = l_dto_mig_ao-belnr
    ).


* 2. Container Belegen

    MOVE-CORRESPONDING ls_dto_act TO ls_ao_create EXPANDING NESTED TABLES.
    ls_ao_create-psoty ='06'. "Stundung

    LOOP AT ls_dto_act-t_beleg ASSIGNING FIELD-SYMBOL(<fs_beleg>).
      MOVE-CORRESPONDING  <fs_beleg> TO ls_ao_create EXPANDING NESTED TABLES.
    ENDLOOP.
    ls_ao_create-blart ='SD'.

* Neu DF-1305 Stundung SD Beleg mit Fälligkeit = Stundungsende
* DF DF-1734 wen kein Stundungsenede an dem OP vorhanden, dann aus RK nehmen
    IF l_dto_mig_ao-stundungsende IS NOT INITIAL.
      ls_ao_create-bldat = l_dto_mig_ao-stundungsende.
      ls_ao_create-zfbdt = l_dto_mig_ao-stundungsende.
    ELSE.
      /thkr/cl_mig_rk=>get_instance( )->get_dto_mig_rkfael_pos(
             EXPORTING
               i_xblnr   = l_dto_mig_ao-xblnr
               i_faellig = CONV #( l_dto_mig_ao-fealligkeit )
               i_hf_nf   = 'H'
             IMPORTING
               e_dto     = DATA(l_dto_mig_rkfael_pos) ).
      ls_ao_create-bldat = l_dto_mig_rkfael_pos-dat_stundung_ende.
      ls_ao_create-zfbdt = l_dto_mig_rkfael_pos-dat_stundung_ende.
    ENDIF.

* und SD Beleg mit Mahnsperre 5
    ls_ao_create-mansp = '5'.

* 3. Stundung Anlegen

    /thkr/cl_mig_psm_ao_appl=>mig_get_instance( )->create_psm_ao_beleg1(
      EXPORTING
         i_dto_psm_ao_bel_create = ls_ao_create
      IMPORTING
        e_psm_ao_document_number = DATA(l_psm_ao_document_number)
        e_error_clear = e_error_clear ).



    e_psm_ao_document_number = l_psm_ao_document_number.


  ENDMETHOD.


  METHOD DELETE_MIG_AO.

    ASSERT i_satz_id IS NOT INITIAL.

    DATA: l_ln_key TYPE /thkr/event_ln_key,
          l_ln_art TYPE /thkr/event_ln_art.

*       "Eventuell vorhandene Meldungen zur Zeile löschen
    l_ln_art = 'MIG_AO'.
    l_ln_key = i_satz_id.  "Satz_ID

    /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
        i_ln_art         = l_ln_art
        i_ln_key         = l_ln_key ).

    DELETE FROM /thkr/migdao     WHERE satz_id = @i_satz_id.
    DELETE FROM /thkr/migdaos    WHERE satz_id = @i_satz_id.
    DELETE FROM /thkr/migdaor    WHERE satz_id = @i_satz_id.
    DELETE FROM /thkr/migdzp     WHERE satz_id = @i_satz_id.
    DELETE FROM /thkr/mig_ao_sap WHERE satz_id = @i_satz_id.
    DELETE FROM /thkr/migd_camt  WHERE satz_id = @i_satz_id.

  ENDMETHOD.


  METHOD delete_mig_aos.

    ASSERT i_selection-migrationsobjekt IS NOT INITIAL.

    DATA: l_count TYPE i.

    mig_rk->get_tdto_mig_ao(
      EXPORTING
        i_selection = i_selection
      IMPORTING
        et_dto      = DATA(lt_dto) ).

    LOOP AT lt_dto INTO DATA(l_dto).

      delete_mig_ao(
        EXPORTING
          i_satz_id = l_dto-satz_id ).

      l_count += 1.
      IF l_count = 1000.
        COMMIT WORK.
        CLEAR l_count.
      ENDIF.

    ENDLOOP.

    COMMIT WORK.

  ENDMETHOD.


  METHOD delete_mig_mandat.

*    ASSERT i_epl IS NOT INITIAL.
    ASSERT i_schluessel IS NOT INITIAL.
    ASSERT i_uci IS NOT INITIAL.

    TYPES: BEGIN OF lty_param,
             epl        TYPE /thkr/mig_epl,
             schluessel TYPE /thkr/mig_mvw_schluessel,
             uci        TYPE /thkr/mig_mvw_uci,
           END OF lty_param.

    DATA: l_param  TYPE lty_param,
          l_ln_key TYPE /thkr/event_ln_key,
          l_ln_art TYPE /thkr/event_ln_art.

    l_param-epl        = i_epl.
    l_param-schluessel = i_schluessel.
    l_param-uci        = i_uci.

    get_ln_key_mig_mandat(
      EXPORTING
        i_epl        = i_epl
        i_schluessel = i_schluessel
        i_uci        = i_uci
      IMPORTING
        e_ln_key     = l_ln_key ).

    l_ln_art = 'MIG_MN'.

    "Eventuell vorhandene Meldungen zur Zeile löschen
    /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
        i_ln_art         = l_ln_art
        i_ln_key         = l_ln_key ).


    DELETE FROM /thkr/migd_mvw
      WHERE epl        = @i_epl
      AND schluessel = @i_schluessel
      AND uci        = @i_uci.

    DELETE FROM /thkr/mig_mvw_sp
      WHERE epl        = @i_epl
      AND schluessel = @i_schluessel
      AND uci        = @i_uci.

  ENDMETHOD.


  METHOD delete_mig_rk.

    ASSERT i_satz_id IS NOT INITIAL.

    DATA: l_ln_key TYPE /thkr/event_ln_key,
          l_ln_art TYPE /thkr/event_ln_art.

*   "Eventuell vorhandene Meldungen zur Zeile löschen
    l_ln_art = 'MIG_RK'.
    l_ln_key = i_satz_id.  "Satz_ID

    /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
        i_ln_art         = l_ln_art
        i_ln_key         = l_ln_key ).

    DELETE FROM /thkr/migd_rk    WHERE satz_id = @i_satz_id.
    DELETE FROM /thkr/migd_rka   WHERE satz_id = @i_satz_id.
    DELETE FROM /thkr/migd_rkfap WHERE satz_id = @i_satz_id.
    DELETE FROM /thkr/migd_rkn   WHERE satz_id = @i_satz_id.
    DELETE FROM /thkr/migd_rkv   WHERE satz_id = @i_satz_id.
    DELETE FROM /thkr/migd_rk_fa WHERE satz_id = @i_satz_id.
    DELETE FROM /thkr/migd_rk_si WHERE satz_id = @i_satz_id.
    DELETE FROM /thkr/migd_rk_zp WHERE satz_id = @i_satz_id.

    DELETE FROM /thkr/migd_ahe   WHERE satz_id = @i_satz_id.
    DELETE FROM /thkr/migd_bore  WHERE satz_id = @i_satz_id.

    DELETE FROM /thkr/mig_rk_sap WHERE satz_id = @i_satz_id.

  ENDMETHOD.


  METHOD delete_mig_rks.

    DATA: l_count TYPE i.

    mig_rk->get_tdto_mig_rk(
      EXPORTING
        i_selection = i_selection
      IMPORTING
        et_dto      = DATA(lt_dto) ).

    LOOP AT lt_dto INTO DATA(l_dto).

      delete_mig_rk(
        EXPORTING
          i_satz_id = l_dto-satz_id ).

      l_count += 1.
      IF l_count = 1000.
        COMMIT WORK.
        CLEAR l_count.
      ENDIF.

    ENDLOOP.

    COMMIT WORK.

  ENDMETHOD.


  METHOD display_fsepa_m3.

    DATA: lt_bdcdata TYPE TABLE OF bdcdata,
          l_bdcdata  TYPE bdcdata,
          l_opt      TYPE ctu_params,
          l_lotkz    TYPE pso_lotkz,
          l_x        TYPE xfeld VALUE 'X'.

*   Startdialog: Programm und Dynpro für Hintergrund
    l_bdcdata-program  = 'SAPLSEPA_MANDATE_UI_TRANS'.
    l_bdcdata-dynpro   = '100'.
    l_bdcdata-dynbegin = 'X'.

    APPEND l_bdcdata TO lt_bdcdata.

    CLEAR l_bdcdata.

*   Felder der Startmaske belegen
    l_bdcdata-fnam     = 'RFSEPA_SEL-MNDID'.
    l_bdcdata-fval     = i_mndid.
    APPEND l_bdcdata TO lt_bdcdata.


    l_bdcdata-fnam     = 'BDC_OKCODE'.
    l_bdcdata-fval     = '=ENTR'.
    APPEND l_bdcdata TO lt_bdcdata.

*   l_opt-dismode = 'A'.    "Alles anzeigen
    l_opt-dismode = 'N'.    "No Display
    l_opt-updmode = 'L'.  "Locales Update

*   Dialoagbetrieb
    l_opt-nobinpt = 'X'.
    l_opt-dismode = 'E'.

    CALL TRANSACTION 'FSEPA_M3' USING lt_bdcdata
          OPTIONS FROM l_opt.

  ENDMETHOD.


  METHOD display_mb.

    DATA: lt_bdcdata TYPE TABLE OF bdcdata,
          l_bdcdata  TYPE bdcdata,
          l_opt      TYPE ctu_params,
          l_lotkz    TYPE pso_lotkz,
          l_x        TYPE xfeld VALUE 'X'.

*   Startdialog: Programm und Dynpro für Hintergrund
    l_bdcdata-program  = 'SAPLFMFR'.
    l_bdcdata-dynpro   = '0511'.
    l_bdcdata-dynbegin = 'X'.

    APPEND l_bdcdata TO lt_bdcdata.

    CLEAR l_bdcdata.

*   Felder der Startmaske belegen
    l_bdcdata-fnam     = 'KBLD-BELNR'.
    l_bdcdata-fval     = i_belnr.
    APPEND l_bdcdata TO lt_bdcdata.

    IF i_blpos IS NOT INITIAL.
      l_bdcdata-fnam     = 'KBLD-BLPOS'.
      l_bdcdata-fval     = i_blpos.
      APPEND l_bdcdata TO lt_bdcdata.
    ENDIF.

    l_bdcdata-fnam     = 'BDC_OKCODE'.
    l_bdcdata-fval     = '=ENTE'.
    APPEND l_bdcdata TO lt_bdcdata.

*   l_opt-dismode = 'A'.    "Alles anzeigen
    l_opt-dismode = 'N'.    "No Display
    l_opt-updmode = 'L'.  "Locales Update

*   Dialoagbetrieb
    l_opt-nobinpt = 'X'.
    l_opt-dismode = 'E'.

    CALL TRANSACTION 'FMZ3' USING lt_bdcdata
          OPTIONS FROM l_opt.

  ENDMETHOD.


  METHOD DISPLAY_SSTA.

    DATA: lt_bdcdata TYPE TABLE OF bdcdata,
          l_bdcdata  TYPE bdcdata,
          l_opt      TYPE ctu_params,
          l_lotkz    TYPE pso_lotkz,
          l_x        TYPE xfeld VALUE 'X'.

*   Startdialog: Programm und Dynpro für Hintergrund
    l_bdcdata-program  = 'SAPLFMFR'.
    l_bdcdata-dynpro   = '0511'.
    l_bdcdata-dynbegin = 'X'.

    APPEND l_bdcdata TO lt_bdcdata.

    CLEAR l_bdcdata.

*   Felder der Startmaske belegen
    l_bdcdata-fnam     = 'KBLD-BELNR'.
    l_bdcdata-fval     = i_belnr.
    APPEND l_bdcdata TO lt_bdcdata.

    IF i_blpos IS NOT INITIAL.
      l_bdcdata-fnam     = 'KBLD-BLPOS'.
      l_bdcdata-fval     = i_blpos.
      APPEND l_bdcdata TO lt_bdcdata.
    ENDIF.

    l_bdcdata-fnam     = 'BDC_OKCODE'.
    l_bdcdata-fval     = '=ENTE'.
    APPEND l_bdcdata TO lt_bdcdata.

*   l_opt-dismode = 'A'.    "Alles anzeigen
    l_opt-dismode = 'N'.    "No Display
    l_opt-updmode = 'L'.  "Locales Update

*   Dialoagbetrieb
    l_opt-nobinpt = 'X'.
    l_opt-dismode = 'E'.

    CALL TRANSACTION 'FMV3' USING lt_bdcdata
          OPTIONS FROM l_opt.

  ENDMETHOD.


  METHOD get_bukrs_by_epl.

    CLEAR e_bukrs.

    SELECT SINGLE bukrs INTO @e_bukrs
      FROM /thkr/mig_map_01
      WHERE gsber = @I_DIENSTSTELLE.

    IF sy-subrc <> 0.

      RAISE EXCEPTION TYPE /thkr/cx_mig
        MESSAGE e002(/thkr/mig) WITH I_DIENSTSTELLE.

    ENDIF.


  ENDMETHOD.


  METHOD get_dto_epl.

    DATA: l_centralmap TYPE /thkr/centralmap.

*    BREAK zhm000000057.

    CLEAR: e_dto.

    ASSERT i_epl IS NOT INITIAL.             " Einzelplan

    "Tabelle mit Dummy Werten lesen
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF @l_centralmap
         FROM /thkr/centralmap
          WHERE ep EQ @i_epl.

    IF sy-subrc = 0.

    ELSE.
*zentrale Mapping Tabelle lesen, 1. Eintrag!
      SELECT * INTO @l_centralmap
         FROM /thkr/centralmap
        WHERE ep EQ @i_epl.
* Hinweis:  es wird nur der 1. Satz zum Einzelplan gelesen.
* Es wird davon ausgegangen, dass der Buchungskreis in allen Sätzen zum Einzelplan
* identisch ist!

        EXIT.

      ENDSELECT.

    ENDIF.

    IF NOT l_centralmap IS INITIAL.
      e_dto-bukrs  = l_centralmap-bukrs.    " Buchungskreis

    ELSE.
* wenn kein Eintrag gefunden wird
      RAISE EXCEPTION TYPE /thkr/cx_mig
            MESSAGE e017(/thkr/mig) WITH i_epl.
    ENDIF.

  ENDMETHOD.


  METHOD get_dto_finanzstelle.

    DATA: ls_centralmap TYPE /thkr/centralmap.

    CLEAR: e_dto.

*   BREAK zhm000000144.





* Sonderfall IOS und VSA, dort ist nicht immer eine Organisationseinheit vorhanden
* (Dienstelle muss vorhanden sein, wird in der gen.Schnittstelle geprüft! )
    IF   i_migrationsobjekt EQ 'IOS' AND i_orgeinheit IS INITIAL
      OR i_migrationsobjekt EQ 'VSA' AND i_orgeinheit IS INITIAL.

      e_dto-fistl+0(04) = i_dienststelle.
      e_dto-fistl+4(06) = '000102'.
    ELSE.


** Finanzstelle aus Dienststelle (Geschäftsbereich) und Organisationseinheit bestimmen
*        SELECT SINGLE * INTO CORRESPONDING FIELDS OF e_dto
*          FROM /thkr/mig_map_03
*          WHERE    orgeinh      EQ i_orgeinheit.
**      WHERE dienststelle EQ i_dienststelle
**      AND   orgeinh      EQ i_orgeinheit.


* Umstellung auf zentrale Mappingtabelle

      SELECT SINGLE * INTO ls_centralmap
        FROM /thkr/centralmap
        WHERE    oeh_old     EQ i_orgeinheit.


* Fnanzstelle FICTR  in /thkr/centralmap  =>  FISTL
      IF sy-subrc = 0.
        e_dto-fistl = ls_centralmap-fictr.
      ELSE.

* Tabelle mit Dummy Werten
        SELECT SINGLE * INTO ls_centralmap
           FROM /thkr/cmap_mig
           WHERE oeh_old EQ i_orgeinheit.

        IF sy-subrc = 0.
          e_dto-fistl = ls_centralmap-fictr.
        ELSE.
          RAISE EXCEPTION TYPE /thkr/cx_mig
            MESSAGE e013(/thkr/mig) WITH i_dienststelle i_orgeinheit.
        ENDIF.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD get_dto_fipos_saknr.


** Bei EPL 93-96 muss auch der Funktionsbereich aus der Centralmap gelesen werden


    DATA:
      lv_fipos_check TYPE fm_fipex,
      ls_payac07     TYPE payac07,
      lt_centralmap  TYPE TABLE OF /thkr/centralmap,
      ls_centralmap  TYPE /thkr/centralmap.

    IF   ( i_migrationsobjekt EQ 'IOS' AND i_orgeinheit IS INITIAL )
        OR ( i_migrationsobjekt EQ 'VSA' AND i_orgeinheit IS INITIAL ).
      i_orgeinheit = '20000001'.
    ENDIF.

    CONDENSE i_titel NO-GAPS.

    e_dto-kapitel = i_kapitel.
    e_dto-titel = i_titel.
    e_dto-unterkonto = i_unterkonto.
    e_dto-bukrs = i_bukrs.
    e_dto-gjhid = i_gjhid.

    CONDENSE i_unterkonto NO-GAPS.
    DATA(lv_offset) = strlen( i_unterkonto ) - 1. "offset letztes Zeichen

* zuerst Fipos ermitteln und danach Sachkonto dazu
    IF i_epl = '93' OR i_epl = '94' OR i_epl = '95' OR i_epl = '96'.
      SELECT * FROM /thkr/centralmap INTO TABLE @lt_centralmap
                 WHERE ep              = @i_epl
                   AND kapitel         = @i_kapitel
                   AND titel           = @i_titel.
      IF sy-subrc = 0.
        e_dto-fipex = lt_centralmap[ 1 ]-fipex.
        e_dto-fkber = lt_centralmap[ 1 ]-fkber.
      ENDIF.

      IF lines( lt_centralmap ) GE 1.
        e_dto-saknr = lt_centralmap[ 1 ]-saknr.
      ENDIF.

    ELSEIF i_epl <> '11'.
      e_dto-fipex = i_kapitel && i_titel.
*      e_dto-saknr =  kommt aus der PAYAC1
      IF i_unterkonto IS NOT INITIAL AND i_unterkonto <> '00'.
        lv_fipos_check = e_dto-fipex && i_unterkonto.
        TRANSLATE lv_fipos_check TO UPPER CASE. "FIPEX akzeptiert nur Großbuchstaben
        CALL FUNCTION 'FM_FIPEX_READ_SINGLE_DATA'
          EXPORTING
            i_fikrs                  = '1000'
            i_gjahr                  = CONV gjahr( COND #( WHEN i_gjhid IS INITIAL THEN sy-datum+0(4) ELSE e_dto-gjhid ) )
            i_fipex                  = lv_fipos_check
          EXCEPTIONS
            master_data_not_found    = 1
            hierarchy_data_not_found = 2
            input_error              = 3
            OTHERS                   = 4.
        IF sy-subrc <> 0.
          " wenn nicht vorhanden originären Titel verwenden
          e_dto-fipex = e_dto-fipex.
        ELSE.
          e_dto-fipex = lv_fipos_check.
        ENDIF.
      ENDIF.

    ELSEIF i_epl = '11'.
      SELECT SINGLE * INTO @ls_centralmap
       FROM /thkr/centralmap
       WHERE ep              = @i_epl
         AND dst_old         = @i_dienststelle
         AND oeh_old         = @i_orgeinheit
         AND kapitel         = @i_kapitel
         AND titel           = @i_titel
         AND kam_sub_acc_old = @i_unterkonto.
      IF sy-subrc = 0.
        e_dto-fipex = ls_centralmap-fipex.
        e_dto-saknr = ls_centralmap-saknr.

        IF  e_dto-fipex IS INITIAL .
          e_dto-fipex = i_kapitel && i_titel.
*      e_dto-saknr =  kommt aus der PAYAC1
          IF i_unterkonto IS NOT INITIAL AND i_unterkonto <> '00'.
            lv_fipos_check = e_dto-fipex && i_unterkonto.
            TRANSLATE lv_fipos_check TO UPPER CASE. "FIPEX akzeptiert nur Großbuchstaben
            CALL FUNCTION 'FM_FIPEX_READ_SINGLE_DATA'
              EXPORTING
                i_fikrs                  = '1000'
                i_gjahr                  = CONV gjahr( COND #( WHEN i_gjhid IS INITIAL THEN sy-datum+0(4) ELSE e_dto-gjhid ) )
                i_fipex                  = lv_fipos_check
              EXCEPTIONS
                master_data_not_found    = 1
                hierarchy_data_not_found = 2
                input_error              = 3
                OTHERS                   = 4.
            IF sy-subrc <> 0.
              " wenn nicht vorhanden originären Titel verwenden
              e_dto-fipex = e_dto-fipex.
            ELSE.
              e_dto-fipex = lv_fipos_check.
            ENDIF.
          ENDIF.
        ENDIF.


      ENDIF.

    ENDIF.

    REPLACE ALL OCCURRENCES OF '.' IN e_dto-fipex WITH ''.

    IF e_dto-fipex IS INITIAL.
* Ohne Finanzposition geht nichts
      RAISE EXCEPTION TYPE /thkr/cx_mig
             MESSAGE e035(/thkr/mig) WITH i_epl i_kapitel i_titel i_unterkonto.
    ENDIF. " Prüfung Fipex


* Sachkonto
    IF e_dto-saknr IS INITIAL.

* Buchungskreisgruppe zum Buchungskreis lesen
      CALL FUNCTION 'FI_PSO_PAYAC07_READ3'
        EXPORTING
          i_bukrs   = i_bukrs
        IMPORTING
          e_payac07 = ls_payac07.

      SELECT * FROM payac01 INTO TABLE @DATA(lt_payac)
        WHERE gjhid = @i_gjhid AND bukfm = @ls_payac07-bukfm AND fipex = @e_dto-fipex.
      IF sy-subrc = 0.
        " Sachkonto aus 1. Eintrag der Payac nutzen
        " wenn SAKNR mit 2 anfängt dann nächsten <> 2 Treffer nutzen
        LOOP AT lt_payac ASSIGNING FIELD-SYMBOL(<fs_payac>).
          IF <fs_payac>-saknr IS NOT INITIAL AND <fs_payac>-saknr+0(1) <> '2'.
            e_dto-saknr = <fs_payac>-saknr.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF e_dto-saknr IS INITIAL.
          " Sonst einfach immer 1. Eintrag nehmen
          e_dto-saknr = lt_payac[ 1 ]-saknr.
        ENDIF.

        IF lines( lt_payac ) > 1.
          payac_saknr_hit_first = 1.
        ENDIF.
      ENDIF.
    ENDIF.



  ENDMETHOD.


  METHOD get_dto_migobj_para.


    CLEAR: e_dto.
* Parameter zum Migrationsobjekt.
*MWSKZ
*BLART
*PSOTY
*BLTYP

* Verwendungsnachweis generische Schnittstelle:
* MIG_MV

*    BREAK zhm000000144.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF e_dto FROM /thkr/mig_map_02
                     WHERE migrationsobjekt EQ i_mig_obj.

   IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_mig
        MESSAGE e005(/thkr/mig) WITH i_mig_obj.
    ENDIF.

  ENDMETHOD.


  METHOD get_dto_mig_ao.

    mig_rk->get_dto_mig_ao(
      EXPORTING
        i_satz_id              = i_satz_id
        i_xblnr                = i_xblnr
        i_xblnr_pos_nr         = i_xblnr_pos_nr
        i_haupt_nebenforderung = i_haupt_nebenforderung
      IMPORTING
        e_dto                  = e_dto ).

    e_dto-flag_no_ms2 = flag_no_ms2.

  ENDMETHOD.


  METHOD get_dto_mig_lif.

* Verwendungsnachweis: u.a. Singel Selektion aus gen.Schnittstelle (MIG_MVW)

    DATA: l_selection TYPE /thkr/s_mig_lif_sap_selection,
          lv_date     TYPE sy-datum.

    CLEAR: e_dto.


    IF i_zp_nr IS NOT INITIAL.
      l_selection-zp_nummer = i_zp_nr.
      l_selection-zp_lfd_nummer = i_zp_lfd_nr.

      get_tdto_mig_lif(
        EXPORTING
          i_selection = l_selection
        IMPORTING
          et_dto      = DATA(lt_dto) ).

      READ TABLE lt_dto INDEX 1 INTO e_dto.

    ENDIF.


  ENDMETHOD.


  METHOD get_dto_mig_md.

    CLEAR: e_dto.

    MOVE-CORRESPONDING def->mig_md TO e_dto.
    e_dto-flag_no_ms2 = flag_no_ms2.

  ENDMETHOD.


  METHOD get_dto_mig_mvw.

* Verwendungsnachweis: Singel Selektion aus gen.Schnittstelle (MIG_MVW) / ohne Einzelplan

    DATA: l_selection  TYPE /thkr/s_mig_mvw_sap_selection.


    IF i_schluessel IS NOT INITIAL.
      l_selection-schluessel = i_schluessel.
      l_selection-uci = i_uci.
      l_selection-epl = i_epl.


      get_tdto_mig_mvw(
        EXPORTING
          i_selection = l_selection
        IMPORTING
         et_dto      =  DATA(lt_dto)  ).

      READ TABLE lt_dto INDEX 1 INTO e_dto.

    ENDIF.

  ENDMETHOD.


  METHOD get_dto_mig_mvw_me.

* Selektion mit Einzelplan

    get_tdto_mig_mvw(
      EXPORTING
        i_selection = i_selection
      IMPORTING
       et_dto      =  DATA(lt_dto)  ).

    READ TABLE lt_dto INDEX 1 INTO e_dto.

  ENDMETHOD.


  METHOD get_dto_mig_proc_exp_camt.

    IF mig_export IS INITIAL.
      ASSERT i_process_id IS NOT INITIAL.
      CREATE OBJECT mig_export
        EXPORTING
          i_process_id = i_process_id.
    ENDIF.

    mig_export->get_attr(
      IMPORTING
        e_attr         = DATA(l_attr)
        e_attr_process = DATA(l_attr_process) ).

    MOVE-CORRESPONDING l_attr         TO e_dto.
    MOVE-CORRESPONDING l_attr_process TO e_dto.

    e_dto-process_id   = mig_export->process_id.
    e_dto-process_type = mig_export->process_type.

  ENDMETHOD.


  METHOD get_dto_oeh.

    DATA: l_centralmap TYPE /thkr/centralmap.



    CLEAR: e_dto.

    CONDENSE i_titel NO-GAPS.


    DATA(l_orgeinheit) = i_orgeinheit.


* Sonderfall IOS und VSA, dort ist nicht immer eine Organisationseinheit vorhanden, dann mit Konstante vorbelegen
* (Dienstelle muss vorhanden sein, wird in der gen.Schnittstelle geprüft! )
    IF   ( i_migrationsobjekt EQ 'IOS' AND i_orgeinheit IS INITIAL )
      OR ( i_migrationsobjekt EQ 'VSA' AND i_orgeinheit IS INITIAL ).

      ASSERT i_dienststelle IS NOT INITIAL. "Dienststelle / Geschäftsbereich

      l_orgeinheit = '20000001'.

    ENDIF.

    IF i_migrationsobjekt NE 'MVW'.
      ASSERT l_orgeinheit IS NOT INITIAL.
    ENDIF.

* Tabelle mit Dummy Werten lesen
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF @l_centralmap
       FROM /thkr/cmap_mig
       WHERE dst_old EQ @i_dienststelle
         AND oeh_old EQ @l_orgeinheit.

    IF sy-subrc = 0.
      e_dto-gsber  = l_centralmap-gsber.            "Geschäftsbereich / Dienststelle
      e_dto-oeh    = l_centralmap-oeh_old.          "Organisationseinheit
      e_dto-bukrs  = l_centralmap-bukrs.            "Buchungskreis
      e_dto-kostl  = l_centralmap-kostl.            "Kostenstelle
      e_dto-fistl  = l_centralmap-fictr.            "Finanzstelle.

    ELSE.

* zentrale Mapping Tabelle lesen
      IF i_epl = '93' OR i_epl = '94' OR i_epl = '95' OR i_epl = '96'.
        SELECT SINGLE * FROM /thkr/centralmap INTO @l_centralmap
                   WHERE ep              = @i_epl
                     AND kapitel         = @i_kapitel
                     AND titel           = @i_titel.
      ELSE.
        SELECT SINGLE * INTO @l_centralmap
          FROM /thkr/centralmap
          WHERE ep              = @i_epl
            AND dst_old         = @i_dienststelle
            AND oeh_old         = @l_orgeinheit
            AND kapitel         = @i_kapitel
            AND titel           = @i_titel
            AND kam_sub_acc_old = @i_unterkonto.
      ENDIF.
      IF sy-subrc <> 0 AND NOT ( i_epl = '93' OR i_epl = '94' OR i_epl = '95' OR i_epl = '96' ).
* Wenn keine Eintrag gefunden, dann nur mit Dienststelle und OEH lesen
        SELECT SINGLE * INTO @l_centralmap
          FROM /thkr/centralmap
          WHERE dst_old = @i_dienststelle
            AND oeh_old = @l_orgeinheit.

        IF sy-subrc <> 0.
          IF i_migrationsobjekt EQ 'MVW'.
* Bei MVW ist die Orgeinheit nicht immer vorhanden
            SELECT SINGLE * INTO @l_centralmap
              FROM /thkr/centralmap
              WHERE dst_old = @i_dienststelle.
          ENDIF.
        ENDIF.
      ENDIF.
      IF sy-subrc = 0 .
        e_dto-gsber  = l_centralmap-gsber.        "Geschäftsbereich / Dienststelle
        e_dto-oeh    = l_centralmap-oeh_old.      "Organisationseinheit
        e_dto-bukrs  = l_centralmap-bukrs.        "Buchungskreis
        e_dto-kostl  = l_centralmap-kostl.        "Kostenstelle
        e_dto-fistl  = l_centralmap-fictr.        "Finanzstelle.
        " Feld "Innenauftrag" - Ableitung aus Central-Map bei EPL 11 und EPL 14 da nur Geschäftsbereich 0420
        IF i_epl = '11' OR ( i_epl = '14' AND l_centralmap-gsber = '0420' ).
          e_dto-aufnr  = l_centralmap-aufnr.        "Finanzstelle.
        ENDIF.

      ELSE.
* Fehler, kein Eintrag vorhanden
        RAISE EXCEPTION TYPE /thkr/cx_mig
        MESSAGE e013(/thkr/mig) WITH i_dienststelle i_orgeinheit.
      ENDIF.
    ENDIF.



* Info: BUDAT (Buchungsdatum) ist als globaler Parameter vorhanden
    MOVE-CORRESPONDING def->mig_md TO e_dto. "Kennzeichen use_dummys

  ENDMETHOD.


  METHOD get_execute_day.


* Umgesetzte Zahlweisen:
* V    gleiche Kalendertag
* 1-9, Werktag des Monats
* P    5 Tage vor Monatsende
* Q    4 Tage vor Monatsende
* R    3 Tage vor Monatsende
* S    2 Tage vor Monatsende
* T    1 Tag vor Monatsende
* U    am Monatsende
* H    füngletzter Arbeitstag im Monat
* I    viertletzter Arbeitstag im Monat
* J    drittletzter Arbeitstag im Monat
* K    vorletzter Arbeitstag im Monat
* L    letzter Arbeitstag im Monat




    DATA: lv_datum    TYPE sydatum,
          lv_count    TYPE n,
          lv_ende     TYPE n,
          lv_last_day TYPE sydatum.


    CONSTANTS: c_h TYPE n VALUE '5',
               c_i TYPE n VALUE '4',
               c_j TYPE n VALUE '3',
               c_k TYPE n VALUE '2',
               c_l TYPE n VALUE '1'.





*    BREAK zhm000000144.
    lv_datum = i_date.


    TRANSLATE i_zahlweise TO UPPER CASE.


    CASE i_zahlweise.
      WHEN '1' OR '2' OR '3' OR '4' OR '5' OR '6' OR '7' OR '8' OR '9'.
* 1-9 Werktag des Monats ******************************************************

* Start am 1. hochzählen entsprechend der Zahlweise und prüfen ob es ein Werktag/Arbeitstag ist
        lv_datum+6(2) = '01'.

        DO.
          CALL FUNCTION 'DATE_CHECK_WORKINGDAY'
            EXPORTING
              date                = lv_datum
              factory_calendar_id = i_factory_calendar_id
              message_type        = 'I'
            EXCEPTIONS
              OTHERS              = 1.

          IF sy-subrc NE 0.
*           keine Arbeitstag
          ELSE.
*           Arbeitstag
*           Anzahl Werktage ab dem 1. :
            ADD 1 TO lv_count.
          ENDIF.

          IF lv_count = i_zahlweise.
*           Zahlweise erreicht
            EXIT.
          ENDIF.

*         Tage hochzählen
          ADD  1 TO lv_datum.
        ENDDO.

        e_day = lv_datum+6(2).


      WHEN 'V' OR 'v'.
* gleicher Kalendertag ********************************************************
        e_day = lv_datum+6(2).


      WHEN 'P' OR 'Q' OR 'R' OR 'S' OR 'T' OR 'U' .
* x Tage vor Monatsende *******************************************************

* Monatsende bestimmen
        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
          EXPORTING
            day_in            = lv_datum
          IMPORTING
            last_day_of_month = lv_last_day
          EXCEPTIONS
            day_in_no_date    = 1
            OTHERS            = 2.

        IF sy-subrc = 0.
* Tage abziehen entsprechend dem Parameter (Monatstage)
          IF i_zahlweise  EQ 'P'.
            SUBTRACT 5 FROM lv_last_day.
            e_day = lv_last_day+6(2).
          ELSEIF
             i_zahlweise  EQ 'Q'.
            SUBTRACT 4 FROM lv_last_day.
            e_day = lv_last_day+6(2).
          ELSEIF
             i_zahlweise  EQ 'R'.
            SUBTRACT 3 FROM lv_last_day.
            e_day = lv_last_day+6(2).
          ELSEIF
             i_zahlweise  EQ 'S'.
            SUBTRACT 2 FROM lv_last_day.
            e_day = lv_last_day+6(2).
          ELSEIF
             i_zahlweise  EQ 'T'.
            SUBTRACT 1 FROM lv_last_day.
            e_day = lv_last_day+6(2).
          ELSEIF
             i_zahlweise  EQ 'U'.
            e_day = lv_last_day+6(2).
          ENDIF.
        ENDIF.


      WHEN 'H' OR 'I' OR 'J' OR 'K' OR'L'.
* Tage abziehen entsprechend dem Parameter (Werktage) *************************

        IF i_zahlweise  EQ 'H'.
          lv_ende = c_h.
        ELSEIF
           i_zahlweise  EQ 'I'.
          lv_ende = c_i.
        ELSEIF
           i_zahlweise  EQ 'J'.
          lv_ende = c_j.
        ELSEIF
          i_zahlweise  EQ 'K'.
          lv_ende = c_k.
        ELSEIF
          i_zahlweise  EQ 'L'.
          lv_ende = c_l.
        ENDIF.
        CHECK lv_ende IS NOT INITIAL.

* Monatsende bestimmen
        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
          EXPORTING
            day_in            = lv_datum
          IMPORTING
            last_day_of_month = lv_last_day
          EXCEPTIONS
            day_in_no_date    = 1
            OTHERS            = 2.

        IF sy-subrc = 0.
          DO.
* prüfen ob es ein Werktag ist
            CALL FUNCTION 'DATE_CHECK_WORKINGDAY'
              EXPORTING
                date                = lv_last_day
                factory_calendar_id = i_factory_calendar_id
                message_type        = 'I'
              EXCEPTIONS
                OTHERS              = 1.

            IF sy-subrc NE 0.
*           keine Arbeitstag
            ELSE.
*           Arbeitstag
*           Anzahl Werktage ab dem 1. :
              ADD 1 TO lv_count.
            ENDIF.

            IF lv_count = lv_ende.
*           Zahlweise erreicht
              EXIT.
            ENDIF.

*           Tage runter zählen
            SUBTRACT  1 FROM  lv_last_day.

          ENDDO.

          e_day = lv_last_day+6(2).
        ENDIF.


      WHEN OTHERS.
        e_day = space.

    ENDCASE.


  ENDMETHOD.


  METHOD get_import_files.

    DATA:
      lt_dir_list   TYPE TABLE OF eps2fili,
      lv_cnt        TYPE i,
      lt_file_table TYPE TABLE OF file_info.


* nur das Verzeichnis ermitteln
    IF i_frontend = abap_true .
      FIND ALL OCCURRENCES OF SUBSTRING '\' IN i_filename RESULTS DATA(lt_result).
    ELSE.
      FIND ALL OCCURRENCES OF SUBSTRING '/' IN i_filename RESULTS lt_result.
    ENDIF.
    IF lt_result IS NOT INITIAL.
      SORT lt_result BY offset DESCENDING.
      DATA(lv_offset) = lt_result[ 1 ]-offset.
      e_directory = CONV string( i_filename+0(lv_offset) ).

* Dateinamen ist der Filter
      DATA(lv_end) = strlen( i_filename ).
      ADD 1 TO lv_offset.
      lv_end = lv_end - lv_offset.
      DATA(lv_filter) = CONV string( i_filename+lv_offset(lv_end) ).
    ELSE.
      e_directory = i_filename.
      lv_filter = '*.*'. "Default Wert in directory_list_files
    ENDIF.

* passende Dateien im Verzeichnis ermitteln
    IF i_frontend = abap_true.
* Alle Dateien die dem Suchmuster entsprechen vom Frontend laden
      cl_gui_frontend_services=>directory_list_files(
        EXPORTING
          directory                   = e_directory                 " Suchverzeichnis
          filter                      = lv_filter            " Dateifilter
          files_only                  = abap_true                " Gibt nur Dateien zurück, keine Verzeichnisse
        CHANGING
          file_table                  = lt_file_table                 " Zurückgegebene Tabelle mit gefundenen Dateinamen
          count                       = lv_cnt                " Anzahl Dateien / Verzeichnisse gefunden
        EXCEPTIONS
          cntl_error                  = 1                " Controlfehler
          directory_list_files_failed = 2                " Auflisten der Dateien im Verzeichnis fehlgeschlagen
          wrong_parameter             = 3                " Falsche Parameterkombination
          error_no_gui                = 4                " Kein GUI verfügbar
          not_supported_by_gui        = 5                " Nicht unterstützt von GUI
          OTHERS                      = 6
      ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      LOOP AT lt_file_table ASSIGNING FIELD-SYMBOL(<fs_file>).
        APPEND |{ e_directory }\\{ <fs_file>-filename }| TO e_files.
      ENDLOOP.

    ELSE.
      IF lv_filter CS '*'.
* Alle Dateien die dem Suchmuster entsprechen vom Server laden
        CALL FUNCTION 'EPS2_GET_DIRECTORY_LISTING'
          EXPORTING
            iv_dir_name            = CONV eps2filnam( e_directory )
            file_mask              = CONV epsfilnam( lv_filter )
          TABLES
            dir_list               = lt_dir_list
          EXCEPTIONS
            invalid_eps_subdir     = 1
            sapgparam_failed       = 2
            build_directory_failed = 3
            no_authorization       = 4
            read_directory_failed  = 5
            too_many_read_errors   = 6
            empty_directory_list   = 7
            OTHERS                 = 8.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        LOOP AT lt_dir_list ASSIGNING FIELD-SYMBOL(<fs_dir_file>).
          APPEND |{ e_directory }/{ <fs_dir_file>-name }| TO e_files.
        ENDLOOP.
      ELSE.
        " Die Suche nach direktem Dateiname funktioniert mit dem Baustein EPS2_GE* nicht
        " daher dann den Namen direkt verwenden
        APPEND i_filename TO e_files.
      ENDIF.

    ENDIF.

    IF e_files IS INITIAL.
      MESSAGE i019(/thkr/mig) WITH i_filename.
    ENDIF.

  ENDMETHOD.


  METHOD GET_INSTANCE.

    IF instance IS INITIAL.

      CREATE OBJECT instance.

    ENDIF.

    e_instance = instance.
    r_instance = instance.

  ENDMETHOD.


  METHOD get_lastuse_date.

    DATA:  lv_datum TYPE sydatum.
* Drei Jahre von "Datum gültig bis" abziehen

*I_DAT_GUELTIGKEIT
*e_dto-lastuse_day

  clear e_dto-lastuse_day.

    IF NOT i_dat_gueltigkeit IS INITIAL.

      CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
        EXPORTING
          date      = i_dat_gueltigkeit
          years     = '03'
          days      = 0
          months    = 0
          signum    = '-'
        IMPORTING
          calc_date = lv_datum.


      e_dto-lastuse_day = lv_datum.

    ENDIF.


  ENDMETHOD.


  method GET_LN_KEY_MIG_MANDAT.

    CONCATENATE i_epl '#' i_schluessel '#' i_uci INTO e_ln_key.

  endmethod.


  METHOD get_mig_ao_satz_id.

    CLEAR e_satz_id.

    IF i_mig_ao IS SUPPLIED.

      ASSERT i_mig_ao-haushaltsjahr IS NOT INITIAL.

      CASE i_mig_ao-migrationsobjekt.
        WHEN 'VSA' OR 'IOS'.
          CONCATENATE i_mig_ao-kassenzeichen i_mig_ao-positionsnummer INTO e_satz_id SEPARATED BY '_'.

        WHEN 'SEE_A' OR 'SEA_A'.
          CONCATENATE i_mig_ao-kassenzeichen i_mig_ao-positionsnummer i_mig_ao-migrationsobjekt  INTO e_satz_id SEPARATED BY '_'.
        WHEN 'SEE_E'.
          CONCATENATE i_mig_ao-einzelplan i_mig_ao-haushaltsjahr i_mig_ao-kassenzeichen INTO e_satz_id SEPARATED BY '_'.
        WHEN OTHERS.
          CONCATENATE i_mig_ao-einzelplan i_mig_ao-haushaltsjahr i_mig_ao-buchungsnummer INTO e_satz_id SEPARATED BY '_'.
      ENDCASE.

    ELSEIF i_mig_vsa_svz IS SUPPLIED.

      CONCATENATE i_mig_vsa_svz-kassenzeichen i_mig_vsa_svz-positionsnummer INTO e_satz_id SEPARATED BY '_'.

    ENDIF.

  ENDMETHOD.


  METHOD get_mig_rk_satz_id.


    CLEAR e_satz_id.

    IF i_mig_rk-kassenzeichen IS NOT INITIAL.

*      CONCATENATE i_mig_rk-kassenzeichen i_mig_rk-dienststelle INTO e_satz_id SEPARATED BY '_'.
      e_satz_id = i_mig_rk-kassenzeichen.

    ELSEIF i_mig_rkn-kassenzeichen IS NOT INITIAL.

*      CONCATENATE i_mig_rkn-kassenzeichen i_mig_rkn-dienststelle INTO e_satz_id SEPARATED BY '_'.
      e_satz_id = i_mig_rkn-kassenzeichen.

    ELSEIF i_mig_rkv-kassenzeichen IS NOT INITIAL.

*      CONCATENATE i_mig_rkv-kassenzeichen i_mig_rkv-dienststelle INTO e_satz_id SEPARATED BY '_'.
      e_satz_id = i_mig_rkv-kassenzeichen.

    ELSEIF i_mig_ahe-kassenzeichen IS NOT INITIAL.

*      CONCATENATE i_mig_ahe-kassenzeichen i_mig_ahe-dienststelle INTO e_satz_id SEPARATED BY '_'.
      e_satz_id = i_mig_ahe-kassenzeichen.

    ELSEIF i_mig_rka-kassenzeichen IS NOT INITIAL.

*      CONCATENATE i_mig_rka-kassenzeichen i_mig_rka-dienststelle INTO e_satz_id SEPARATED BY '_'.
      e_satz_id = i_mig_rka-kassenzeichen.

    ELSE.

      e_satz_id = i_mig_bore-kassenzeichen.

    ENDIF.


  ENDMETHOD.


  METHOD get_tdto_mig_lif.


    DATA: l_select_clause TYPE string,
          l_where_clause  TYPE string,
          l_and           TYPE string,
          l_x             TYPE xfeld.

    FIELD-SYMBOLS <dto> LIKE LINE OF et_dto.

    CLEAR: et_dto.

    l_x = 'X'.

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_MIG_LIF_K'
        i_prefix           = 'a'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    CONCATENATE l_select_clause
     ', b~schluessel, b~uci, b~status_mvw'
      INTO l_select_clause SEPARATED BY space.

    IF i_selection-epl IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~epl = @i_selection-epl'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-zp_nummer IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~zp_nummer = @i_selection-zp_nummer'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-zp_lfd_nummer IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~zp_lfd_nummer = @i_selection-zp_lfd_nummer'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-status_mvw IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~status_mvw = @i_selection-status_mvw'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

* Ranges
    IF i_selection-r_zp_nummer IS NOT INITIAL.
      CONCATENATE l_where_clause l_and
           'a~zp_nummer in @i_selection-r_zp_nummer'
          INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.
    ENDIF.

    IF i_selection-r_zp_lfd_nummer IS NOT INITIAL.
      CONCATENATE l_where_clause l_and
            'a~zp_lfd_nummer in @i_selection-r_zp_lfd_nummer'
          INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.
    ENDIF.

    IF i_selection-r_status IS NOT INITIAL.
      CONCATENATE l_where_clause l_and
        'b~STATUS_MVW in @i_selection-r_status'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.
    ENDIF.



    SELECT (l_select_clause)
      INTO CORRESPONDING FIELDS OF TABLE @et_dto
      FROM /thkr/migd_lif AS a
      LEFT OUTER JOIN /thkr/mig_mvw_sp AS b
        ON a~zp_nummer = b~zp_nummer
        AND  a~zp_lfd_nummer = b~zp_lfd_nummer
        AND a~epl = b~epl
      WHERE (l_where_clause).

  ENDMETHOD.


  METHOD get_tdto_mig_mvw.

    DATA: l_select_clause TYPE string,
          l_where_clause  TYPE string,
          l_and           TYPE string,
          l_x             TYPE xfeld.

    FIELD-SYMBOLS <dto> LIKE LINE OF et_dto.

    CLEAR: et_dto.

    l_x = 'X'.

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_MIG_MVW_SAP_K'
        i_prefix           = 'a'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_MIG_MVW'
        i_prefix           = 'b'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    IF i_selection-epl IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~epl = @i_selection-epl'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-schluessel IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~schluessel = @i_selection-schluessel'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-uci IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~uci = @i_selection-uci'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

* Ranges

    IF i_selection-r_uci IS NOT INITIAL.
      CONCATENATE l_where_clause l_and
          'a~uci in @i_selection-r_uci'
          INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.
    ENDIF.

    IF i_selection-r_schluessel IS NOT INITIAL.
      CONCATENATE l_where_clause l_and
        'a~schluessel in @i_selection-r_schluessel'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.
    ENDIF.

    IF i_selection-r_status IS NOT INITIAL.
      CONCATENATE l_where_clause l_and
        'a~STATUS_MVW in @i_selection-r_status'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.
    ENDIF.



    SELECT (l_select_clause)
      INTO CORRESPONDING FIELDS OF TABLE @et_dto
      FROM /thkr/mig_mvw_sp AS a
      INNER JOIN /thkr/migd_mvw AS b
        ON a~epl = b~epl AND a~schluessel = b~schluessel AND  a~uci = b~uci
      WHERE (l_where_clause).

  ENDMETHOD.


  METHOD get_tdto_mig_run.

    DATA: l_select_clause TYPE string,
          l_where_clause  TYPE string,
          l_and           TYPE string,
          l_x             TYPE xfeld.

    FIELD-SYMBOLS <dto> LIKE LINE OF et_dto.

    CLEAR: et_dto.

    l_x = 'X'.

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_PROCESS_K'
        i_prefix           = 'a'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_MIG_IMP'
        i_prefix           = 'b'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).


    IF i_selection-process_type IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~process_type = @i_selection-process_type'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

*    IF i_selection-r_process_id IS NOT INITIAL.
*
*      CONCATENATE l_where_clause l_and
*        'a~process_id in @i_selection-r_process_id'
*        INTO l_where_clause SEPARATED BY space.
*
*      l_and = 'and'.
*
*    ENDIF.

    IF i_selection-migrationsobjekt IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'b~migrationsobjekt = @i_selection-migrationsobjekt'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-r_datum IS NOT INITIAL.

      helpers->convert_range_datum_to_tmstmp(
        EXPORTING
          i_rdatum     = i_selection-r_datum
        IMPORTING
          e_rtimestamp = DATA(l_rtimestamp) ).


      CONCATENATE l_where_clause l_and
        'a~cr_time_stamp in @l_rtimestamp'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    SELECT (l_select_clause)
      INTO CORRESPONDING FIELDS OF TABLE @et_dto
      FROM /thkr/process AS a
      INNER JOIN /thkr/mig_imp AS b
        ON a~process_type = b~process_type AND a~process_id = b~process_id
      WHERE (l_where_clause).

    LOOP AT et_dto ASSIGNING <dto>.

      CONVERT TIME STAMP <dto>-cr_time_stamp TIME ZONE sy-zonlo
        INTO DATE <dto>-cr_date TIME <dto>-cr_time.

    ENDLOOP.

  ENDMETHOD.


  METHOD initialize_mvw.




*  wird nicht mehr benötigt wenn es ohne ZP nummer  funktioiert







    DATA: l_selection     TYPE /thkr/s_mig_mvw_sap_selection,
          l_mig_mvw_sp_wa TYPE /thkr/mig_mvw_sp.

*    IF i_schluessel IS NOT INITIAL.
*      l_selection-schluessel = i_schluessel.
*      l_selection-uci = i_uci.
*    ENDIF.
*
*    IF i_epl IS NOT INITIAL.
*      l_selection-epl = i_epl.
*    ENDIF.

    l_selection = i_selection.

    get_tdto_mig_mvw(
      EXPORTING
        i_selection = l_selection
      IMPORTING
        et_dto      = DATA(lt_dto) ).

    LOOP AT lt_dto ASSIGNING FIELD-SYMBOL(<dto>)
      WHERE status_mvw < '39'.

      SELECT * INTO @DATA(l_lif)
        FROM /thkr/migd_lif
        WHERE iban = @<dto>-iban
          AND epl  = @<dto>-epl.

        IF <dto>-zp_nummer = l_lif-zp_nummer AND <dto>-zp_lfd_nummer = l_lif-zp_lfd_nummer.
          CONTINUE.

        ELSEIF <dto>-zp_nummer IS NOT INITIAL.
          <dto>-status_mvw = '20'. "n.r. - mehrere GP

        ELSE.
          <dto>-status_mvw = '30'. "GP gefunden

          <dto>-zp_nummer = l_lif-zp_nummer.
          <dto>-zp_lfd_nummer = l_lif-zp_lfd_nummer.

        ENDIF.

      ENDSELECT.

      IF sy-subrc <> 0.
        <dto>-status_mvw = '10'. "n.r. - kein GP
*        CONTINUE.
      ENDIF.

      MOVE-CORRESPONDING <dto> TO l_mig_mvw_sp_wa.
      MODIFY /thkr/mig_mvw_sp FROM l_mig_mvw_sp_wa.

    ENDLOOP.

    COMMIT WORK.


  "MVW_Status
*00	Initial
*10	n.r. - kein GP
*20	n.r. - mehrere GP
*30	GP gefunden
*39	Fehler GP
*40	GP angelegt
  ENDMETHOD.


  METHOD init_dto_mig_proc_exp_camt.

    IF mig_export IS INITIAL.
      ASSERT i_process_id IS NOT INITIAL.
      CREATE OBJECT mig_export
        EXPORTING
          i_process_id = i_process_id.
    ENDIF.


    mig_export->init_header(
      EXPORTING
        i_bookg_dt                 =         i_bookg_dt
      IMPORTING
        e_iso_current_datetime_utc =         DATA(l_current_dttm_utc)
        e_iso_current_date         =         DATA(l_current_dt)
        e_iso_current_datetime     =         DATA(l_current_dttm)
        e_iso_bookgdttm_utc        =         DATA(l_booking_dttm_utc)
        e_iso_bookgdt              =         DATA(l_booking_dt)
        e_iso_bookgdttm            =         DATA(l_booking_dttm) ).

*    Migrations-Buchungsdatum ist 31.12.2025
*    CAMT-Áttribute BookgDt und CreDtTm zuweisen
    e_dto-credttm   = l_booking_dttm.
    e_dto-msgid     = l_current_dttm_utc.
    e_dto-frdttm    = l_current_dttm_utc.
    e_dto-todttm    = l_current_dttm_utc.
    e_dto-bookg_dt  = l_booking_dt.
    e_dto-val_dt    = l_current_dt.

  ENDMETHOD.


  METHOD process_export_camt.

    mig_export = NEW /thkr/cl_mig_export_camt(
      i_selection = i_selection
      i_test      = i_test ).

    mig_export->process(
      EXPORTING
        i_path     = i_path
        i_frontend = i_frontend ).


    LOOP AT mig_export->t_event INTO DATA(l_event).
      WRITE: / l_event-mess.

    ENDLOOP.

  ENDMETHOD.


  METHOD process_import.


* Alle Dateim zum übergebenen Pfad inkl. Datei + Suchmuster ermitteln
    get_import_files( EXPORTING i_filename  = i_filename
                                i_frontend  = i_frontend
                      IMPORTING e_directory = DATA(lv_directory)
                                e_files     = DATA(lt_files) ).

* Jede Datei in einem Prozess verareiten
    LOOP AT lt_files INTO DATA(lv_file).
      " Fortschrittanzeige
      IF sy-batch = abap_true.
        MESSAGE |Datei { lv_file }| TYPE 'I'.
      ELSE.
        cl_progress_indicator=>progress_indicate( i_text               = |Fortschritt { sy-tabix } / { lines( lt_files ) }|
                                                  i_processed          = sy-tabix     " Wert
                                                  i_total              = lines( lt_files )     " Maximum
                                                  i_output_immediately = abap_true ).
      ENDIF.

*    CREATE OBJECT mig_import.
      mig_import = NEW /thkr/cl_mig_import( i_process_type = i_process_type ).

      mig_import->process(
        EXPORTING
          i_migrationsobjekt = i_objekt_type
          i_filename         = lv_file
          i_directory        = lv_directory
          i_frontend         = i_frontend
          i_epl              = i_epl
          i_move_archiv      = i_move_archiv
          i_archiv_directory = i_archiv_directory
          i_prot_detail      = i_prot_detail
          i_update_allowed   = i_update_allowed
      ).

      mig_import->save( ).
      COMMIT WORK.

      LOOP AT mig_import->t_event INTO DATA(l_event).
        WRITE: / l_event-mess.

      ENDLOOP.


    ENDLOOP.




  ENDMETHOD.


  METHOD process_mig_absetzung_btr0.
    TYPES: BEGIN OF lty_param,
             satz_id TYPE /thkr/de_satz_id,
           END OF lty_param.

    DATA:
      ls_dto_psm_ao_bel_create TYPE /thkr/s_dto_mig_ao_bel_create,
      ls_mig_ao_sap            TYPE /thkr/mig_ao_sap,
      ls_created_document      TYPE /thkr/s_psm_ao_document_number.


* Daten zur Selektion holen
    mig_rk->get_tdto_mig_ao(
      EXPORTING
        i_selection = i_selection
      IMPORTING
        et_dto      = DATA(lt_dto) ).

* Alle EPL <> 50 und  SSTE/SEE_E/SSTS mit Betrag Offen = 0, werden bei der 1. AO Buchung
* auf Soll = 0,01 gesetzt. Hier muss eine Absetzung AO des 1 Cent erstellt werden.

* ab Status 40  AO-Beleg erzeugt ( hier gibt es keine Kontoauszugsdatei für den Fall)
    LOOP AT lt_dto ASSIGNING FIELD-SYMBOL(<fs_dto_ao>) WHERE ( status = '40' AND betragoffen = 0 AND einzelplan <> '50' ) OR ( sstw_ueberzahlung = 'X' ).
      TRY.
          CLEAR ls_dto_psm_ao_bel_create.

          DATA(ls_param) = VALUE lty_param( satz_id = <fs_dto_ao>-satz_id ).

* AO Mapping
          IF <fs_dto_ao>-migrationsobjekt = 'NF'.
            /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
              EXPORTING
                i_gi_id = 'MIG_AO_NF'
                i_para  = ls_param
              CHANGING
                c_data  = ls_dto_psm_ao_bel_create  ).
          ELSE.
            /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
              EXPORTING
                i_gi_id = 'MIG_AO'
                i_para  = ls_param
              CHANGING
                c_data  = ls_dto_psm_ao_bel_create  ).
          ENDIF.

          " falls nicht schon im Mapping passiert
          ls_dto_psm_ao_bel_create-t_kont[ 1 ]-wrbtr = '0.01'.
          IF <fs_dto_ao>-sstw_ueberzahlung = 'X' AND <fs_dto_ao>-sstw_ueberzahlung_datum IS NOT INITIAL.
            ls_dto_psm_ao_bel_create-bldat = <fs_dto_ao>-sstw_ueberzahlung_datum.
          ENDIF.

* Nach Absprache mit Kasse und Mittelbewirtschaftung
          ls_dto_psm_ao_bel_create-psoty = '05'.
          ls_dto_psm_ao_bel_create-blart = 'DG'.
          ls_dto_psm_ao_bel_create-psoak = 'S'.
          ls_dto_psm_ao_bel_create-belnr = <fs_dto_ao>-belnr. " Rechnungsbezug aus 1. AO herstellen
          ls_dto_psm_ao_bel_create-gjahr = <fs_dto_ao>-gjahr. " Muss zum Beleg passen

* AO anlegen
          create_psm_ao_beleg(
            EXPORTING
              i_dto_psm_ao_bel_create  = ls_dto_psm_ao_bel_create
              i_migrationsobjekt       = <fs_dto_ao>-migrationsobjekt
            IMPORTING
              e_psm_ao_document_number = ls_created_document ).

* Daten und Status übernehmen

          <fs_dto_ao>-status = '52'. "  Absetzung AO erstellt
          <fs_dto_ao>-lotkz_fb = ls_created_document-lotkz.
          <fs_dto_ao>-belnr_fb = ls_created_document-belnr.

          MOVE-CORRESPONDING <fs_dto_ao> TO ls_mig_ao_sap.
          MODIFY /thkr/mig_ao_sap FROM ls_mig_ao_sap.

          COMMIT WORK.

        CATCH cx_root INTO DATA(lx_root).
          ROLLBACK WORK.

          DATA(lo_proc) = NEW /thkr/cl_bfw_process( i_process_type = 'MIG_AO' ).

          lo_proc->add_event(
            EXPORTING
              i_event_category = 'E'
              i_exception      = lx_root
              i_ln_art         = 'MIG_AO'
              i_ln_key         = CONV #( <fs_dto_ao>-satz_id ) ).

          lo_proc->save( ).
          COMMIT WORK.

      ENDTRY.


    ENDLOOP.




  ENDMETHOD.


  METHOD PROCESS_MIG_ABSETZUNG_RK.
    TYPES: BEGIN OF lty_param,
             satz_id TYPE /thkr/de_satz_id,
           END OF lty_param.

    DATA:
      ls_dto_psm_ao_bel_create TYPE /thkr/s_dto_mig_ao_bel_create,
      ls_mig_ao_sap            TYPE /thkr/mig_ao_sap,
      ls_created_document      TYPE /thkr/s_psm_ao_document_number.


* Daten zur Selektion holen
    mig_rk->get_tdto_mig_ao(
      EXPORTING
        i_selection = i_selection
      IMPORTING
        et_dto      = DATA(lt_dto) ).

* Alle RK Überzahlungen sollen hier abgesetzt werden.

    LOOP AT lt_dto ASSIGNING FIELD-SYMBOL(<fs_dto_ao>) WHERE status < '40' AND rk_abs = 'X'.
      TRY.
          CLEAR ls_dto_psm_ao_bel_create.

          DATA(ls_param) = VALUE lty_param( satz_id = <fs_dto_ao>-satz_id ).

* AO Mapping
          /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
            EXPORTING
              i_gi_id = 'MIG_AO_NF'
              i_para  = ls_param
            CHANGING
              c_data  = ls_dto_psm_ao_bel_create  ).
          ls_dto_psm_ao_bel_create-t_kont[ 1 ]-wrbtr = ls_dto_psm_ao_bel_create-t_kont[ 1 ]-wrbtr * -1.
* Nach Absprache mit Kasse und Mittelbewirtschaftung
          ls_dto_psm_ao_bel_create-psoty = '05'.
          ls_dto_psm_ao_bel_create-blart = 'DG'.
          ls_dto_psm_ao_bel_create-psoak = 'S'.
          "Rechnungsbezug gibt es nicht, da mehrere Absetzungen gleichberechtigt nebeneiander ex.
*          ls_dto_psm_ao_bel_create-belnr = <fs_dto_ao>-belnr. " Rechnungsbezug aus 1. AO herstellen
*          ls_dto_psm_ao_bel_create-gjahr = <fs_dto_ao>-gjahr. " Muss zum Beleg passen

* AO anlegen
          create_psm_ao_beleg(
            EXPORTING
              i_dto_psm_ao_bel_create  = ls_dto_psm_ao_bel_create
              i_migrationsobjekt       = <fs_dto_ao>-migrationsobjekt
            IMPORTING
              e_psm_ao_document_number = ls_created_document ).

* Daten und Status übernehmen

          <fs_dto_ao>-status = '52'. "  Absetzung AO erstellt
          <fs_dto_ao>-bukrs    = ls_created_document-bukrs.
          <fs_dto_ao>-lotkz_fb = ls_created_document-lotkz.
          <fs_dto_ao>-belnr_fb = ls_created_document-belnr.

          MOVE-CORRESPONDING <fs_dto_ao> TO ls_mig_ao_sap.
          MODIFY /thkr/mig_ao_sap FROM ls_mig_ao_sap.

          COMMIT WORK.

        CATCH cx_root INTO DATA(lx_root).
          ROLLBACK WORK.

          DATA(lo_proc) = NEW /thkr/cl_bfw_process( i_process_type = 'MIG_AO' ).

          lo_proc->add_event(
            EXPORTING
              i_event_category = 'E'
              i_exception      = lx_root
              i_ln_art         = 'MIG_AO'
              i_ln_key         = CONV #( <fs_dto_ao>-satz_id ) ).

          lo_proc->save( ).
          COMMIT WORK.

      ENDTRY.


    ENDLOOP.




  ENDMETHOD.


  METHOD process_mig_absetzung_uez.
    TYPES: BEGIN OF lty_param,
             satz_id TYPE /thkr/de_satz_id,
           END OF lty_param.

    DATA:
      ls_dto_psm_ao_bel_create TYPE /thkr/s_dto_mig_ao_bel_create,
      ls_mig_ao_sap            TYPE /thkr/mig_ao_sap,
      ls_created_document      TYPE /thkr/s_psm_ao_document_number.


* Daten zur Selektion holen
    mig_rk->get_tdto_mig_ao(
      EXPORTING
        i_selection = i_selection
      IMPORTING
        et_dto      = DATA(lt_dto) ).

* Alle SSTE Überzahlte Forderungen, die ein Sollbetrag von 0 haben, werden bei der 1. AO Buchung
* auf Soll = 0,01 gesetzt. Hier muss eine Absetzung AO des 1 Cent erstellt werden.

* ab Status Kontoauszugsdatei erstellt
    LOOP AT lt_dto ASSIGNING FIELD-SYMBOL(<fs_dto_ao>) WHERE status = '43' AND sollbetrag = 0.
      TRY.
          CLEAR ls_dto_psm_ao_bel_create.

          DATA(ls_param) = VALUE lty_param( satz_id = <fs_dto_ao>-satz_id ).

* AO Mapping
          IF <fs_dto_ao>-migrationsobjekt = 'NF'.
            /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
              EXPORTING
                i_gi_id = 'MIG_AO_NF'
                i_para  = ls_param
              CHANGING
                c_data  = ls_dto_psm_ao_bel_create  ).

          ELSE.
            /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
              EXPORTING
                i_gi_id = 'MIG_AO'
                i_para  = ls_param
              CHANGING
                c_data  = ls_dto_psm_ao_bel_create  ).
          ENDIF.

* Nach Absprache mit Kasse und Mittelbewirtschaftung
          ls_dto_psm_ao_bel_create-psoty = '05'.
          ls_dto_psm_ao_bel_create-blart = 'DG'.
          ls_dto_psm_ao_bel_create-psoak = 'S'.
          ls_dto_psm_ao_bel_create-belnr = <fs_dto_ao>-belnr. " Rechnungsbezug aus 1. AO herstellen
          ls_dto_psm_ao_bel_create-gjahr = <fs_dto_ao>-gjahr. " Muss zum Beleg passen

* AO anlegen
          create_psm_ao_beleg(
            EXPORTING
              i_dto_psm_ao_bel_create  = ls_dto_psm_ao_bel_create
              i_migrationsobjekt       = <fs_dto_ao>-migrationsobjekt
            IMPORTING
              e_psm_ao_document_number = ls_created_document ).

* Daten und Status übernehmen

          <fs_dto_ao>-status = '52'. "  Absetzung AO erstellt
          <fs_dto_ao>-lotkz_fb = ls_created_document-lotkz.
          <fs_dto_ao>-belnr_fb = ls_created_document-belnr.

          MOVE-CORRESPONDING <fs_dto_ao> TO ls_mig_ao_sap.
          MODIFY /thkr/mig_ao_sap FROM ls_mig_ao_sap.

          COMMIT WORK.

        CATCH cx_root INTO DATA(lx_root).
          ROLLBACK WORK.

          DATA(lo_proc) = NEW /thkr/cl_bfw_process( i_process_type = 'MIG_AO' ).

          lo_proc->add_event(
            EXPORTING
              i_event_category = 'E'
              i_exception      = lx_root
              i_ln_art         = 'MIG_AO'
              i_ln_key         = CONV #( <fs_dto_ao>-satz_id ) ).

          lo_proc->save( ).
          COMMIT WORK.

      ENDTRY.


    ENDLOOP.




  ENDMETHOD.


  METHOD process_mig_ao.

    TYPES: BEGIN OF lty_param,
             satz_id TYPE /thkr/de_satz_id,
           END OF lty_param.

    DATA: l_param                 TYPE lty_param,
          l_cr_beleg              TYPE /thkr/s_dto_psm_ao_bel_create,   "Anordnung
          l_dto_bp_create         TYPE /thkr/s_dto_bp_create,
          l_dto_psm_ao_bel_create TYPE /thkr/s_dto_mig_ao_bel_create,
          l_dto_split             TYPE /thkr/s_dto_mig_ao_bel_create,
          l_dto_psm_ao_create     TYPE /thkr/s_dto_mig_ao_bel_create,   "Stundung
          l_dto_psm_mv_create     TYPE /thkr/s_dto_psm_mv_create,       "Allgemeine Anordnungen / Mittelvormerkung
          l_created_document      TYPE /thkr/s_psm_ao_document_number,
          l_lotkz                 TYPE lotkz,
          l_oerror                TYPE REF TO cx_root,
          l_ln_key                TYPE /thkr/event_ln_key,
          l_ln_art                TYPE /thkr/event_ln_art,
          lt_ln_evt               TYPE /thkr/t_ln_evt,
          l_line_key_value        TYPE string,
          l_mig_ao_sap_wa         TYPE /thkr/mig_ao_sap,
          l_proc                  TYPE REF TO /thkr/cl_bfw_process,
          l_mig_gi                TYPE ty_mig_gi,
          l_check_partner         TYPE bu_partner,
          ls_rk_pos               TYPE /thkr/s_mig_rk_fap_k,
          l_count_bkvid           TYPE syst_tfill.

    DATA: lt_bankdetails TYPE TABLE OF bapibus1006_bankdetails,
          ls_bankdetails TYPE bapibus1006_bankdetails,
          lt_return      TYPE TABLE OF bapiret2.



    "Prozess-Objekt erstellen, um Fehlermeldungen speichern zu lassen
    CREATE OBJECT l_proc
      EXPORTING
        i_process_type = 'MIG_AO'.



**** Verarbeitung  *************************************************************

* Objekte Übersicht:
* 0.   Eventuell vorhandene Meldungen löschen
* 0.1  Prüfen ob GP bereits angelegt ist
* 1.   BP (Geschäftspartner mir Debitor und Kreditor (bei IOS Dummy)
* 1.5  Mandat zu vorhandenen GP ergänzen
* 2.   Mapping Anordnungen
* 2.1. 'SSTE'  Einzel Annahmeanordnung
*      'SEE_E' für Kasse
* 2.2. 'SSTA'  Allgemeine Annahmeanordnung - Einnahmen
*      'SEE_A' für Kasse
* 2.3. 'ALL'   Allgemeine Annahmeanordnung - Auszahlung
*      'SEA_A' für Kasse
* 2.4. 'IOS'  offene Einzelverwahrungen
* 2.5. 'VSA'  offene Einzelvorschüsse
* 2.6. 'SSTW' Dauer Annahmeanordnungen
* 2.7. 'AWD'  Dauer Anodrnungen
* 3. Daten und Verarbeitungsstatus Mig-AO-SAP speichern
* 4. Stundungen / Ratenstundungen
* 5. Meldungen speichern

    TRY.

        "Migrationsdaten lesen
        get_dto_mig_ao(
          EXPORTING
            i_satz_id = i_satz_id
          IMPORTING
            e_dto     = DATA(l_dto_mig_ao) ).

        IF i_max_status IS NOT INITIAL AND l_dto_mig_ao-status >= i_max_status.

          RETURN.
        ENDIF.


*  0. Eventuell vorhandene Meldungen löschen **********************************
        l_param-satz_id = i_satz_id.
        l_ln_art = 'MIG_AO'.
        l_ln_key = i_satz_id.

        /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
            i_ln_art         = l_ln_art
            i_ln_key         = l_ln_key ).

        COMMIT WORK.

* temporäres Attriobut für Mapping bei AO Anlage
        CLEAR: payac_saknr_hit_first.


        READ TABLE t_mig_gi WITH KEY mig_obj = l_dto_mig_ao-migrationsobjekt INTO l_mig_gi.


        IF (   l_dto_mig_ao-migrationsobjekt = 'SSTE'
            OR l_dto_mig_ao-migrationsobjekt = 'SSTS'
            OR l_dto_mig_ao-migrationsobjekt = 'SEE_E'
            OR l_dto_mig_ao-migrationsobjekt = 'SSTW'
            OR l_dto_mig_ao-migrationsobjekt = 'NF' )
*           AND l_dto_mig_ao-status < '06'.                  "RK noch nicht geprüft
            AND l_dto_mig_ao-status < '10'.                  "GP noch nicht angelegt
*                                                            "Wenn ein Fehler keim Anlegen "hoch kommt", ist der
*                                                            "letze Status = 9 und es erfolgt keine erneute Prüfung auf RK
*                                                            "beim erneuten Versuch den GP anzulegen!


* Prüfen, ob Rückstandskonto vorhanden ist.
          l_dto_mig_ao-status = '04'.                       "RK fehlt



          TRY.
* RK muss vorhanden sein
              /thkr/cl_mig_rk=>get_instance( )->get_dto_mig_rk(
                EXPORTING
                  i_xblnr   = l_dto_mig_ao-xblnr
                  IMPORTING
                   e_dto    = DATA(lt_rk_dto) ).



* wenn vorhanden, auf POS prüfen (SSTE)
              IF ( l_dto_mig_ao-migrationsobjekt = 'SSTE'
                   OR l_dto_mig_ao-migrationsobjekt = 'SSTS'
                   OR l_dto_mig_ao-migrationsobjekt = 'SEE_E' )
                 AND NOT lt_rk_dto IS INITIAL.

                l_dto_mig_ao-status = '05'.                    "RK-Pos. nicht gefunden

                /thkr/cl_mig_rk=>get_instance( )->get_dto_mig_rkfael_pos(
                  EXPORTING
                    i_xblnr   = l_dto_mig_ao-xblnr
                    i_faellig = CONV #( l_dto_mig_ao-fealligkeit )                 " !
                    i_hf_nf   = 'H'
                  IMPORTING
                    e_dto     = DATA(l_dto_mig_rkfael_pos) ).

                IF NOT l_dto_mig_rkfael_pos-pos_nr IS INITIAL.
                  l_dto_mig_ao-rk_pos_nr = l_dto_mig_rkfael_pos-pos_nr.
                  l_dto_mig_ao-status = '06'.
                ENDIF.

              ENDIF.


              IF l_dto_mig_ao-migrationsobjekt = 'SSTW' AND NOT lt_rk_dto IS INITIAL.
* RK PositionNr übernehmen
                READ TABLE lt_rk_dto-t_rk_pos INDEX 1 INTO ls_rk_pos.
                l_dto_mig_ao-rk_pos_nr = ls_rk_pos-pos_nr.
                l_dto_mig_ao-status = '06'.
              ENDIF.

* wenn vorhanden, auf POS prüfen (SSTW) => hier nicht notwendig!
*                l_dto_mig_ao-status = '05'.                    "RK-Pos. nicht gefunden
*
*                /thkr/cl_mig_rk=>get_instance( )->get_dto_mig_rkfael_pos(
*                  EXPORTING
*                    i_xblnr   = l_dto_mig_ao-xblnr
*                    i_faellig = CONV #( l_dto_mig_ao-erstefaelligkeit )
*                    i_hf_nf   = 'H'
*                  IMPORTING
*                    e_dto     = DATA(l_dto_mig_rkfael_pos_sstw) ).
*
*                IF NOT l_dto_mig_rkfael_pos_sstw-pos_nr IS INITIAL.
*                  l_dto_mig_ao-rk_pos_nr = l_dto_mig_rkfael_pos_sstw-pos_nr.
*                  l_dto_mig_ao-status = '06'.
*                ENDIF.
*
*              ENDIF.

            CATCH cx_root INTO DATA(l_oerror1).
              " RK Prüfung nicht aktiv gesetzt
              IF i_ignore_rk_error = abap_true OR
                 " Kassenzeichen mit 0004* + Dienststelle 2000
               ( l_dto_mig_ao-xblnr+0(4) CO '0004' AND l_dto_mig_ao-dienststelle = '2000' ) OR
                 " Art Der Forderung ohne Mahnung/Vollstreckung
               ( l_dto_mig_ao-adfschluessel = 'MA' OR l_dto_mig_ao-adfschluessel = 'SO' OR l_dto_mig_ao-adfschluessel = 'S1' OR
                l_dto_mig_ao-adfschluessel = 'S2' OR l_dto_mig_ao-adfschluessel = 'KM' OR l_dto_mig_ao-adfschluessel = 'KO' OR
                l_dto_mig_ao-adfschluessel = 'TS' OR l_dto_mig_ao-adfschluessel = 'B2' OR l_dto_mig_ao-adfschluessel = 'B3' OR
                l_dto_mig_ao-adfschluessel = 'BN' OR l_dto_mig_ao-adfschluessel = 'BS' ).
                l_dto_mig_ao-kz_ignore_rk_error = 'X'.  " Kennzeichen setzen RK Prüfung wurde deaktiviert
              ELSE.  "RK Prüfung aktiv
                " In dem Fall echter Fehler kein RK vorhanden
                RAISE EXCEPTION l_oerror1.
              ENDIF.

          ENDTRY.


*         Verarbeitungsstatus speichern
          MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
          MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
          COMMIT WORK.

        ENDIF.

* Aus Defect "Bei ALL oder SSTA mit Kapitel 0320,0321,1908 diese Daten dürfen nicht migriert werden
* wohl obsolete Daten der Landespolizei
        IF ( l_dto_mig_ao-migrationsobjekt = 'ALL' OR l_dto_mig_ao-migrationsobjekt = 'SSTA' ) AND
           ( l_dto_mig_ao-kapitel = '0320' OR l_dto_mig_ao-kapitel = '0321' OR l_dto_mig_ao-kapitel = '1908' ).

          l_proc->add_event(
            EXPORTING
              i_event_category = 'E'
              i_mess           = |Nicht relevante ALL/SSTA der Landespolizei.|
              i_ln_art         = 'MIG_AO'
              i_ln_key         = CONV #( i_satz_id ) ).

          MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
          l_mig_ao_sap_wa-status = '09'. "Fehler GP setzen, da eigentlich Feld Name fehlt
          MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
          l_proc->save( ).

          COMMIT WORK.
          RETURN.

        ENDIF.


* 0.1  Prüfen ob GP bereits angelegt ist

        IF l_dto_mig_ao-partner IS INITIAL.

          l_dto_mig_ao-status = '09'.                      "Fehler Geschäftspartner (Vorbelegung)

* Geschäftsbereich / Dienststelle (gsber) bestimmen
          get_dto_oeh(
            EXPORTING
              i_epl              = l_dto_mig_ao-epl
              i_dienststelle     = CONV #( l_dto_mig_ao-dienststelle )
              i_orgeinheit       = l_dto_mig_ao-organisationseinheit
              i_kapitel          = CONV #( l_dto_mig_ao-kapitel )
              i_titel            = l_dto_mig_ao-titel
              i_unterkonto       = l_dto_mig_ao-unterkonto
              i_migrationsobjekt = l_dto_mig_ao-migrationsobjekt
            IMPORTING
              e_dto              = DATA(l_dto_oeh) ).

* Check mit Geschäftsbreich aus zentraler Mappingtabelle
          check_partner(
            EXPORTING
              i_xblnr     = l_dto_mig_ao-xblnr
              i_epl       = l_dto_mig_ao-epl
              i_zp_nr     = l_dto_mig_ao-zp_nr
              i_zp_lfd_nr = l_dto_mig_ao-zp_lfd_nr
              i_gsber     = l_dto_oeh-gsber                "Erweiterung GP pro Dienststelle / Geschäftsbereich
              i_mandat    = l_dto_mig_ao-mandat
            IMPORTING
              e_partner   = l_check_partner ).

          CLEAR l_dto_mig_ao-bkvid.
          IF NOT l_check_partner IS INITIAL.
* Prüfen ob die IBAN identsich ist, sonst 2. Bankverbindung anlegen!

* IBAN Bankdaten einlesen
            IF NOT l_dto_mig_ao-iban IS INITIAL.

              CALL FUNCTION 'BAPI_BUPA_BANKDETAILS_GET'
                EXPORTING
                  businesspartner = l_check_partner
*                 VALID_DATE      = SY-DATLO
                TABLES
                  bankdetails     = lt_bankdetails
                  return          = lt_return.


* Vergleichen

              LOOP AT lt_bankdetails INTO ls_bankdetails WHERE iban = l_dto_mig_ao-iban.
              ENDLOOP.
              IF sy-subrc = 0.
* Bankverbindung ist vorhanden.

* Bank Verbindungs ID merken!, falls nicht 0001
                l_dto_mig_ao-bkvid = ls_bankdetails-bankdetailid.

              ELSE.
* Bankverbindung ergänzen

* Anzahl vorhandenen Bankverbindugen
                DESCRIBE TABLE lt_bankdetails.
                l_count_bkvid = sy-tfill.

* GP Daten einlesen
*                 DATA(ls_partner_data_iban) = /thkr/cl_bp_appl=>get_instance( )->get_partner_data( i_partner = l_check_partner ).
                DATA(ls_partner_data_iban) = /thkr/cl_mig_bp_appl=>mig_get_instance( )->get_partner_data( i_partner = l_check_partner ).


* Neue Bankverbindung
                ADD 1 TO l_count_bkvid .

                ls_partner_data_iban-bankn = space.
                ls_partner_data_iban-bankk = COND #( WHEN l_dto_mig_ao-bic IS NOT INITIAL THEN l_dto_mig_ao-bic ELSE l_dto_mig_ao-blz ).
                ls_partner_data_iban-banks = l_dto_mig_ao-iban+0(2).

                ls_partner_data_iban-bkvid = l_count_bkvid .
                ls_partner_data_iban-bkvid  = |{ ls_partner_data_iban-bkvid  ALPHA = IN WIDTH = 4 }|.  "mit 0 auffüllen
                ls_partner_data_iban-iban  = l_dto_mig_ao-iban.


* Änderungen übernehmen
                DATA ls_dto_bp_modify_iban TYPE /thkr/s_dto_bp_modify.
                MOVE-CORRESPONDING ls_partner_data_iban TO ls_dto_bp_modify_iban .
                TRY.
*                     /thkr/cl_bp_appl=>get_instance( )->modify_partner( i_dto_bp_modify = ls_dto_bp_modify_iban ).
                    /thkr/cl_mig_bp_appl=>mig_get_instance( )->modify_partner( i_dto_bp_modify = ls_dto_bp_modify_iban ).
                    IF NOT /thkr/cl_mig_bp_appl=>mig_get_instance( )->m_clear_bkvid IS INITIAL.
                      "             Zahlweg "M" bzw. Zahlweg "D" - In diesen Fällen wird die Bankverbindung benötigt.
                      " dann Fehler
                      IF l_dto_mig_ao-zahlart = 'M' OR l_dto_mig_ao-zahlart = 'D' AND NOT ( l_dto_mig_ao-einzelplan = '94' OR l_dto_mig_ao-einzelplan = '95').
                        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                        l_proc->add_event(
                          EXPORTING
                            i_event_category = 'E'
                            i_mess           = |Zahlweg { l_dto_mig_ao-zahlart } ohne gültige BV.|
                            i_ln_art         = 'MIG_AO'
                            i_ln_key         = CONV #( i_satz_id ) ).

                        CLEAR l_dto_mig_ao-partner.
                        MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
                        MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
                        l_proc->save( ).

                        COMMIT WORK.
                        RETURN.

                      ELSEIF l_dto_mig_ao-zahlart = 'M' OR l_dto_mig_ao-zahlart = 'D' AND ( l_dto_mig_ao-einzelplan = '94' OR l_dto_mig_ao-einzelplan = '95').
                        " DF-1624 bei EPL 94/05 kann der GP ohne BV und die AO ohne Zahlweg angelegt werden
                        CLEAR l_dto_mig_ao-zahlart.
                        l_dto_mig_ao-clear_zlsch = abap_true.
                        " bei VSA ist ea aber Pflichtfeld, daher Festwert = N setzen
                        IF l_dto_mig_ao-migrationsobjekt = 'VSA'.
                          l_dto_mig_ao-zahlart = 'N'.
                          l_dto_mig_ao-clear_zlsch = 'N'.
                        ENDIF.
                        CLEAR ls_partner_data_iban-bkvid.

                        l_proc->add_event(
                          EXPORTING
                            i_event_category = 'I'
                            i_mess           = 'GP wurde ohne BV und AO ohne Zahlweg angelegt'
                            i_ln_art         = 'MIG_AO'
                            i_ln_key         = CONV #( i_satz_id ) ).
                      ELSE.
                        CLEAR ls_partner_data_iban-bkvid.
                        l_proc->add_event(
                          EXPORTING
                            i_event_category = 'I'
                            i_mess           = 'GP wurde ohne BV angelegt'
                            i_ln_art         = 'MIG_AO'
                            i_ln_key         = CONV #( i_satz_id ) ).
                      ENDIF.
                    ENDIF.
                    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
                  CATCH /thkr/cx_bp INTO DATA(lxc_bp_iban).
                    RAISE EXCEPTION lxc_bp_iban.
                ENDTRY.

* Bankverbindungs ID übernehmen
                l_dto_mig_ao-bkvid  = ls_partner_data_iban-bkvid.

              ENDIF.
            ENDIF.


* Kontonummer Bankdaten einlesen
            IF NOT l_dto_mig_ao-kontonummer IS INITIAL AND l_dto_mig_ao-iban IS INITIAL.
              CALL FUNCTION 'BAPI_BUPA_BANKDETAILS_GET'
                EXPORTING
                  businesspartner = l_check_partner
*                 VALID_DATE      = SY-DATLO
                TABLES
                  bankdetails     = lt_bankdetails
                  return          = lt_return.

* Vergleichen

              LOOP AT lt_bankdetails INTO ls_bankdetails WHERE bank_acct = l_dto_mig_ao-kontonummer.
              ENDLOOP.
              IF sy-subrc = 0.
* Bankverbindung ist vorhanden.

* Bank Verbindungs ID merken!, falls nicht 0001
                l_dto_mig_ao-bkvid = ls_bankdetails-bankdetailid.

              ELSE.
* Bankverbindung ergänzen

* Anzahl vorhandenen Bankverbindugen
                DESCRIBE TABLE lt_bankdetails.
                l_count_bkvid = sy-tfill.

* GP Daten einlesen
*                 DATA(ls_partner_data_blz) = /thkr/cl_bp_appl=>get_instance( )->get_partner_data( i_partner = l_check_partner ).
                DATA(ls_partner_data_blz) = /thkr/cl_mig_bp_appl=>mig_get_instance( )->get_partner_data( i_partner = l_check_partner ).

* Neue Bankverbindung
                ADD 1 TO l_count_bkvid .

                ls_partner_data_blz-bankn = l_dto_mig_ao-kontonummer.
                ls_partner_data_blz-bankk = l_dto_mig_ao-blz.
                ls_partner_data_blz-banks = 'DE'.


                ls_partner_data_blz-bkvid = l_count_bkvid .
                ls_partner_data_blz-bkvid  = |{ ls_partner_data_blz-bkvid  ALPHA = IN WIDTH = 4 }|.  "mit 0 auffüllen
                ls_partner_data_blz-iban  = space.


* Änderungen übernehmen
                DATA ls_dto_bp_modify_blz TYPE /thkr/s_dto_bp_modify.
                MOVE-CORRESPONDING ls_partner_data_blz TO ls_dto_bp_modify_blz .

                TRY.
*                     /thkr/cl_bp_appl=>get_instance( )->modify_partner( i_dto_bp_modify = ls_dto_bp_modify_blz ).
                    /thkr/cl_mig_bp_appl=>mig_get_instance( )->modify_partner( i_dto_bp_modify = ls_dto_bp_modify_blz ).
                    IF NOT /thkr/cl_mig_bp_appl=>mig_get_instance( )->m_clear_bkvid IS INITIAL.
                      "             Zahlweg "M" bzw. Zahlweg "D" - In diesen Fällen wird die Bankverbindung benötigt.
                      " dann Fehler
                      IF l_dto_mig_ao-zahlart = 'M' OR l_dto_mig_ao-zahlart = 'D' AND NOT ( l_dto_mig_ao-einzelplan = '94' OR l_dto_mig_ao-einzelplan = '95').
                        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                        l_proc->add_event(
                          EXPORTING
                            i_event_category = 'E'
                            i_mess           = |Zahlweg { l_dto_mig_ao-zahlart } ohne gültige BV.|
                            i_ln_art         = 'MIG_AO'
                            i_ln_key         = CONV #( i_satz_id ) ).

                        CLEAR l_dto_mig_ao-partner.
                        MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
                        MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
                        l_proc->save( ).

                        COMMIT WORK.
                        RETURN.
                      ELSEIF l_dto_mig_ao-zahlart = 'M' OR l_dto_mig_ao-zahlart = 'D' AND ( l_dto_mig_ao-einzelplan = '94' OR l_dto_mig_ao-einzelplan = '95').
                        " DF-1624 bei EPL 94/05 kann der GP ohne BV und die AO ohne Zahlweg angelegt werden
                        CLEAR l_dto_mig_ao-zahlart.
                        l_dto_mig_ao-clear_zlsch = abap_true.
                        " bei VSA ist ea aber Pflichtfeld, daher Festwert = N setzen
                        IF l_dto_mig_ao-migrationsobjekt = 'VSA'.
                          l_dto_mig_ao-zahlart = 'N'.
                          l_dto_mig_ao-clear_zlsch = 'N'.
                        ENDIF.
                        CLEAR ls_partner_data_iban-bkvid.

                        l_proc->add_event(
                          EXPORTING
                            i_event_category = 'I'
                            i_mess           = 'GP wurde ohne BV und AO ohne Zahlweg angelegt'
                            i_ln_art         = 'MIG_AO'
                            i_ln_key         = CONV #( i_satz_id ) ).

                      ELSE.
                        CLEAR ls_partner_data_blz-bkvid.
                        l_proc->add_event(
                          EXPORTING
                            i_event_category = 'I'
                            i_mess           = 'GP wurde ohne BV angelegt'
                            i_ln_art         = 'MIG_AO'
                            i_ln_key         = CONV #( i_satz_id ) ).
                      ENDIF.
                    ENDIF.
                    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
                  CATCH /thkr/cx_bp INTO DATA(lxc_bp_blz).
                    RAISE EXCEPTION lxc_bp_blz.
                ENDTRY.

* Bankverbindungs ID übernehmen
                l_dto_mig_ao-bkvid  = ls_partner_data_blz-bkvid.

              ENDIF.
            ENDIF.

************************************
* prüfen ob der Partner bereits den Buchungsbereich des Satzes hat, wenn nicht, diesen ergänzen
            DATA(lv_bukrs) = COND #( WHEN l_dto_mig_ao-bukrs IS NOT INITIAL THEN l_dto_mig_ao-bukrs ELSE l_dto_oeh-bukrs ).
            IF lv_bukrs IS NOT INITIAL AND l_check_partner IS NOT INITIAL.
              SELECT SINGLE bukrs FROM knb1 INTO @DATA(lv_knb1) WHERE bukrs = @lv_bukrs AND kunnr = @l_check_partner.
              IF sy-subrc <> 0.
                /thkr/cl_mig_bp_appl=>mig_get_instance( )->create_new_bukrs(
                  i_partner =   l_check_partner               " Geschäftspartnernummer
                  i_bukrs   =   lv_bukrs               " Buchungskreis
                ).
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
              ENDIF.
            ENDIF.
**********************************************************************


* ist bereits angelegt, Partner übernehmen
            l_dto_mig_ao-partner         = l_check_partner.
            l_dto_mig_ao-status          = '20'.           " Status = angelegt.
            l_dto_mig_ao-partner_created = space.          " BP wurde in diesem Satz nicht angelegt
* Verarbeitungsstatus speichern
            MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
            MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
            COMMIT WORK.
          ENDIF.



          IF l_dto_mig_ao-status < '10'.                   " Noch kein GP angelegt
            l_dto_mig_ao-status = '09'.                    " Fehler Geschäftspartner (Vorbelegung)

* 1.0 Mapping BP **************************************************************

* Rückstandskonto vorhanden, Mapping (GP) mit Daten aus dem Rückstandskonto
            IF ( l_dto_mig_ao-migrationsobjekt = 'SSTE' OR l_dto_mig_ao-migrationsobjekt = 'SEE_E' )
                AND NOT lt_rk_dto IS INITIAL.
* Anppassung GP Mapping
              l_mig_gi-gi_id_bp = 'MIG_GP_RK'.
            ENDIF.

            IF l_dto_mig_ao-migrationsobjekt = 'SSTW' AND NOT lt_rk_dto IS INITIAL.
* Anppassung GP Mapping
              l_mig_gi-gi_id_bp = 'MIG_GP_RK'.
            ENDIF.

* Kein Rückstandskonto vorhanden, Mapping wie im CONSTRUCTOR definiert

            IF l_dto_mig_ao-migrationsobjekt EQ 'IOS'
              OR l_dto_mig_ao-migrationsobjekt EQ 'VSA'
              OR l_dto_mig_ao-migrationsobjekt EQ 'NF'.    " Offene Posten der Kasse

              /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                 EXPORTING
                   i_gi_id = l_mig_gi-gi_id_bp
                   i_para  = l_param
                 CHANGING
                   c_data  = l_dto_bp_create ).

            ELSE.

              /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
              EXPORTING
                i_gi_id = l_mig_gi-gi_id_bp
                i_para  = l_param
              CHANGING
                c_data  = l_dto_bp_create ).

            ENDIF.

            IF l_dto_bp_create-bu_bpext IS INITIAL AND l_dto_mig_ao-xblnr IS NOT INITIAL AND l_dto_mig_ao-gjahr IS NOT INITIAL.
              l_dto_bp_create-bu_bpext = |{ l_dto_mig_ao-xblnr } { l_dto_mig_ao-gjahr }|.
            ELSEIF l_dto_bp_create-bu_bpext IS INITIAL AND l_dto_mig_ao-migrationsobjekt = 'NF'.
              TRY.
                  DATA(lv_haushaltsjahr) = lt_rk_dto-t_rk_pos[ pos_nr = l_dto_mig_ao-rk_pos_nr ]-haushaltsjahr.
                CATCH cx_sy_itab_line_not_found.
              ENDTRY.
              l_dto_bp_create-bu_bpext = |{ lt_rk_dto-kassenzeichen } { lv_haushaltsjahr }|.
            ENDIF.

            " gewollte Vorbelegung bei den GP aus OP
            l_dto_bp_create-bu_augrp = '0009'. "Migration

* 1.1. BP anlegen (mit Debitor und Kreditor)
            /thkr/cl_mig_bp_appl=>mig_get_instance( )->create_partner(
              EXPORTING
                i_dto_bp_create = l_dto_bp_create
              IMPORTING
                e_partner       = l_dto_mig_ao-partner ).



            l_dto_mig_ao-zp_gsber         = l_dto_oeh-gsber.         " für GP pro Geschäftsbereich anlegen
            IF /thkr/cl_mig_bp_appl=>mig_get_instance( )->m_clear_bkvid IS INITIAL.
              l_dto_mig_ao-bkvid            = l_dto_bp_create-bkvid.   " BankenID (für GP und AO)
            ELSE.
*              Zahlweg "M" bzw. Zahlweg "D" - In diesen Fällen wird die Bankverbindung benötigt.
              " dann Fehler
              IF l_dto_mig_ao-zahlart = 'M' OR l_dto_mig_ao-zahlart = 'D' AND NOT ( l_dto_mig_ao-einzelplan = '94' OR l_dto_mig_ao-einzelplan = '95').
                CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                l_proc->add_event(
                  EXPORTING
                    i_event_category = 'E'
                    i_mess           = |Zahlweg { l_dto_mig_ao-zahlart } ohne gültige BV.|
                    i_ln_art         = 'MIG_AO'
                    i_ln_key         = CONV #( i_satz_id ) ).

                CLEAR l_dto_mig_ao-partner.
                MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
                MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
                l_proc->save( ).

                COMMIT WORK.
                RETURN.

              ELSEIF l_dto_mig_ao-zahlart = 'M' OR l_dto_mig_ao-zahlart = 'D' AND ( l_dto_mig_ao-einzelplan = '94' OR l_dto_mig_ao-einzelplan = '95').
                " DF-1624 bei EPL 94/05 kann der GP ohne BV und die AO ohne Zahlweg angelegt werden
                CLEAR l_dto_mig_ao-zahlart.
                l_dto_mig_ao-clear_zlsch = abap_true.
                " bei VSA ist ea aber Pflichtfeld, daher Festwert = N setzen
                IF l_dto_mig_ao-migrationsobjekt = 'VSA'.
                  l_dto_mig_ao-zahlart = 'N'.
                  l_dto_mig_ao-clear_zlsch = 'N'.
                ENDIF.
                CLEAR ls_partner_data_iban-bkvid.

                l_proc->add_event(
                  EXPORTING
                    i_event_category = 'I'
                    i_mess           = 'GP wurde ohne BV und AO ohne Zahlweg angelegt'
                    i_ln_art         = 'MIG_AO'
                    i_ln_key         = CONV #( i_satz_id ) ).
              ELSE.
                CLEAR l_dto_mig_ao-bkvid.
                l_proc->add_event(
                  EXPORTING
                    i_event_category = 'I'
                    i_mess           = 'GP wurde ohne BV angelegt'
                    i_ln_art         = 'MIG_AO'
                    i_ln_key         = CONV #( i_satz_id ) ).
              ENDIF.
            ENDIF.

            l_dto_mig_ao-status           = '10'.                    " angelegt
            l_dto_mig_ao-partner_created  = 'X'.                     " BP mit diesem Satz angelegt

* 1.2. Verarbeitungsstatus speichern
            MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
            MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

          ENDIF.

* 1.3. Warten, wird nicht sofort angelegt
          IF l_dto_mig_ao-status < '20'.                             " Noch kein BP angelegt
            IF i_max_status = '20'.
              "Kein Wait erforderlich, da nicht sofort die Anordung gebucht werden soll.
            ELSE.
*            l_dto_mig_ao-status = '19'.                             " Nacharbeit GP fehlerhaft
              WAIT UP TO 1 SECONDS.
            ENDIF.
            l_dto_mig_ao-status = '20'.                              " GP freigegeben

* 1.4. Verarbeitungsstatus speichern
            MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
            MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
            COMMIT WORK AND WAIT.
          ENDIF.


        ELSE.

* 1.5  Mandat zu vorhandenen GP ergänzen

* GP ist bereits angelegt.
* Im Satz ist das Kennzeichen Zahlart = "M" vorhanden => SEPA Mandat ist anzulegen
* Die Regel ist normal, dass GP und Mandat zusammen angelegt werden.
* Hier die Ausnahme (ohne GP anzulegen)
* Vorgehen:
* A. GP Daten auslesen
* B. Mandat ergänzen (das Mapping für GP wird aufgerufen, aber nur die Mandatszeile wird übernommen)
* C. Änderungen speichern


          IF l_dto_mig_ao-zahlart EQ 'M'.  " Kennzeichen Mandat und GP war bereits angelegt => dann nur Mandat ergänzen

            DATA t_mandate        TYPE /thkr/s_dto_bp_sepa_mandate.  """"" nur das erste Fled?????????
            DATA ls_dto_bp_modify TYPE /thkr/s_dto_bp_modify.
            DATA return_tab       TYPE TABLE OF bapiret2.


* A. GP Daten einlesen
*           DATA(ls_partner_data) = /thkr/cl_bp_appl=>get_instance( )->get_partner_data( i_partner = l_dto_mig_ao-partner ).
            DATA(ls_partner_data) = /thkr/cl_mig_bp_appl=>mig_get_instance( )->get_partner_data( i_partner = l_dto_mig_ao-partner ).


* Überprüfung ob ein Rahmenmandat vorhanden ist erfolgt in 'MIG_GP'!, wenn ja wird kein Einzelmandat angelegt.

* B. Mapping, nur T_mandate übernehmen
            /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
              EXPORTING
                i_gi_id = 'MIG_GP'
                i_para  = l_param                                    " Satz ID
              CHANGING
                c_data  = l_dto_bp_create ).

            READ TABLE l_dto_bp_create-t_mandate INDEX 1 INTO t_mandate.

            IF NOT t_mandate IS INITIAL.

* Prüfen ob das Mandat bereits vorhanden ist !
              READ TABLE ls_partner_data-t_mandate WITH KEY sepa_mndid = t_mandate-sepa_mndid TRANSPORTING NO FIELDS.

              IF sy-subrc NE 0.

                APPEND t_mandate TO ls_partner_data-t_mandate.

* C. GP Änderungen übernehmen
                MOVE-CORRESPONDING ls_partner_data TO ls_dto_bp_modify.

                TRY.


*                   /thkr/cl_bp_appl=>get_instance( )->modify_partner( i_dto_bp_modify = ls_dto_bp_modify ).
                    /thkr/cl_mig_bp_appl=>mig_get_instance( )->modify_partner( i_dto_bp_modify = ls_dto_bp_modify ).

                  CATCH /thkr/cx_bp INTO DATA(lxc_bp).

                    l_ln_art = 'MIG_AO'.
                    l_ln_key = i_satz_id.

                    l_proc->add_event(
                      EXPORTING
                        i_event_category = 'E'
                        i_exception      = lxc_bp
                        i_ln_art         = l_ln_art
                        i_ln_key         = l_ln_key ).

                ENDTRY.

                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    wait = abap_true
*                 IMPORTING
*                   RETURN        =
                  .

              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.



        IF i_max_status IS NOT INITIAL AND l_dto_mig_ao-status = i_max_status.
          "Nur GP anlegen
          l_proc->save( ).
          COMMIT WORK.
          RETURN.
        ENDIF.



* 2.01. Bei SSTE und EPL50 und Betrag = 0 soll eine SST Tabelle gefüllt werden
* DF-1698
        IF l_dto_mig_ao-migrationsobjekt = 'SSTE' AND l_dto_mig_ao-einzelplan = '50' AND l_dto_mig_ao-status < '60' AND
          l_dto_mig_ao-betragoffen = '0.00' AND l_dto_mig_ao-sollbetrag = '0.00' AND l_dto_mig_ao-istbetrag = '0.00'.

          IF create_edas_data( l_dto_mig_ao ) = 0.
            l_dto_mig_ao-status = '61'.  " EDAS Tabelle gefüllt
          ELSE.
            l_dto_mig_ao-status = '60'.  " Fehler EDAS
            l_proc->add_event(
              i_mess   = 'Fehler beim Schreiben der EADS Tabelle'
              i_ln_art = 'MIG_AO'
              i_ln_key = CONV #( i_satz_id )
            ).
          ENDIF.

          MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.

          MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
          COMMIT WORK.


        ELSE.
* 2.1. Erzeugung Anordnung ******************************************************
          IF l_dto_mig_ao-status < '40'. "Noch keine AO angelegt
            l_dto_mig_ao-status = '39'.  "Fehler Anordnung (Vorbelegung)

            IF   l_dto_mig_ao-migrationsobjekt = 'SSTA' "Allgemeine Annahmeanordnung - Einnahmen
              OR l_dto_mig_ao-migrationsobjekt = 'SEE_A' "Allgemeine Annahmeanordnung - Einnahmen Kasse
              OR l_dto_mig_ao-migrationsobjekt = 'ALL'  "Allgemeine Annahmeanordnung - Auszahlung
              OR l_dto_mig_ao-migrationsobjekt = 'SEA_A'.  "Allgemeine Annahmeanordnung - Auszahlung Kasse            " Zielbeleg ist Mittelvormerkung

              IF    l_dto_mig_ao-migrationsobjekt = 'SSTA'  "Allgemeine Annahmeanordnung
                 OR l_dto_mig_ao-migrationsobjekt = 'SEE_A'. "Allgemeine Annahmeanordnung Kasse

                /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                  EXPORTING
                    i_gi_id = 'MIG_MV'
                    i_para  = l_param
                  CHANGING
                    c_data  = l_dto_psm_mv_create  ).

              ELSEIF    l_dto_mig_ao-migrationsobjekt = 'ALL'  "Allgemeine Auszahlungsanordnung
                     OR l_dto_mig_ao-migrationsobjekt = 'SEA_A'.  "Allgemeine Auszahlungsanordnung Kasse

                /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                  EXPORTING
                    i_gi_id = 'MIG_AO_ALL'
                    i_para  = l_param
                  CHANGING
                    c_data  = l_dto_psm_mv_create  ).

              ENDIF.

              /thkr/cl_mig_psm_mv_appl=>mig_get_instance( )->create_psm_mv(     "Mittelvormerkung
                 EXPORTING
                   i_dto_psm_mv_bel_create = l_dto_psm_mv_create
                 IMPORTING
                   e_kblnr                 = DATA(l_kblnr) ). "Beleg Nummer zu AO


              l_dto_mig_ao-bukrs = l_dto_psm_mv_create-bukrs.
              l_dto_mig_ao-lotkz = l_kblnr.

            ELSE.
              " Wenn DTO Satz Betrag = 0 Kennzeichen, darf es nur mit dem Parameter nach extra Aufruf gebucht werden
              IF i_betrag_0 IS INITIAL AND l_dto_mig_ao-betrag_0 = abap_true AND
                ( l_dto_mig_ao-migrationsobjekt = 'SSTE' OR l_dto_mig_ao-migrationsobjekt = 'SEE_E' OR l_dto_mig_ao-migrationsobjekt = 'SSTS' ).
                MESSAGE e777(fq) INTO DATA(lv_msg).
                RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ENDIF.
              "Ziel ist Anordnung
              IF    l_dto_mig_ao-migrationsobjekt = 'SSTE'  "Einzel Annahmeanordnung
                 OR l_dto_mig_ao-migrationsobjekt = 'SEE_E'.

                /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                  EXPORTING
                    i_gi_id = 'MIG_AO'
                    i_para  = l_param
                  CHANGING
                    c_data  = l_dto_psm_ao_bel_create  ).
              ELSEIF l_dto_mig_ao-migrationsobjekt = 'SSTS'.  "Split Annahmeanordnung
                " das Mapping muss pro Split gemacht werden
                /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                 EXPORTING
                   i_gi_id = 'MIG_AO'
                   i_para  = l_param
                 CHANGING
                   c_data  = l_dto_psm_ao_bel_create  ).
                LOOP AT l_dto_mig_ao-t_split ASSIGNING FIELD-SYMBOL(<fs_split>) WHERE splittbetragoffen > 0.
                  APPEND INITIAL LINE TO l_dto_psm_ao_bel_create-t_kont ASSIGNING FIELD-SYMBOL(<fs_split_kont>).
                  " allgemeine Daten übernehmen
                  <fs_split_kont> = l_dto_psm_ao_bel_create-t_kont[ 1 ].
                  " Split spezifische Daten überschreiben
                  <fs_split_kont>-wrbtr = <fs_split>-splittbetragoffen. "Betrag
                  <fs_split_kont>-fkber = <fs_split>-kapitel. "MIG_AO KAPITEL.

                  get_dto_fipos_saknr(
                    EXPORTING
                      i_epl              = CONV #( <fs_split>-einzelplan )                " Einzelplan
                      i_kapitel          = CONV #( <fs_split>-kapitel )               " Kapitel
                      i_titel            = <fs_split>-titel                 " Titel aus Profiskal
                      i_unterkonto       = <fs_split>-unterkonto                 " Unterkonto
                      i_bukrs            = l_dto_psm_ao_bel_create-bukrs                 " Buchungskreis
                      i_gjhid            = CONV #( l_dto_psm_ao_bel_create-gjahr )                " Identifikation Geschäftjahr
                      i_migrationsobjekt = l_dto_mig_ao-migrationsobjekt
                      i_orgeinheit       = l_dto_mig_ao-organisationseinheit
                      i_dienststelle     = CONV #( l_dto_mig_ao-dienststelle )
                    IMPORTING
                      e_dto              = DATA(ls_dto_fipos)                " Finanzposition und Sachkonto für Migration
                  ).
                  <fs_split_kont>-hkont =  ls_dto_fipos-saknr.
                  IF <fs_split>-einzelplan BETWEEN '93' AND '96'.
                    <fs_split_kont>-fkber =  CONV #( ls_dto_fipos-fkber ).
                  ENDIF.
                  <fs_split_kont>-fipex = ls_dto_fipos-fipex.

                  get_dto_oeh(
                    EXPORTING
                      i_epl              = CONV #( <fs_split>-einzelplan )                " Einzelplan
                      i_dienststelle     = CONV #( <fs_split>-dienststelle )                " Geschäftsbereich
                      i_orgeinheit       = <fs_split>-organisationseinheit                 " Organisationseinheit (XML)
                      i_kapitel          = CONV #( <fs_split>-kapitel )                 " Kapitel
                      i_titel            = <fs_split>-titel                 " Titel aus Profiskal
                      i_unterkonto       = <fs_split>-unterkonto                 " Unterkonto
                      i_migrationsobjekt = 'SSTS'                 " Migrationsobjekt
                    IMPORTING
                      e_dto              = DATA(ls_dto_oeh)                   " DTO: Dienststelle (Geschäftsbereich) weitere Daten
                  ).

                  <fs_split_kont>-fistl = ls_dto_oeh-fistl.
                  <fs_split_kont>-gsber = ls_dto_oeh-gsber.
                  <fs_split_kont>-kostl = ls_dto_oeh-kostl.

                ENDLOOP.


              ELSEIF  l_dto_mig_ao-migrationsobjekt = 'IOS'.  "offene Einzelverwahrungen

                /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                  EXPORTING
                    i_gi_id = 'MIG_AO_IOS'
                    i_para  = l_param
                  CHANGING
                     c_data  = l_dto_psm_ao_bel_create  ).

                l_dto_psm_ao_bel_create-partner = l_dto_mig_ao-partner.

              ELSEIF  l_dto_mig_ao-migrationsobjekt = 'VSA'.  "offene Einzelvorschüsse


* 2.5.1 Mapping

                /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                  EXPORTING
                    i_gi_id = 'MIG_AO_VSA'
                    i_para  = l_param
                  CHANGING
                     c_data  = l_dto_psm_ao_bel_create  ).

                l_dto_psm_ao_bel_create-partner = l_dto_mig_ao-partner.

              ELSEIF l_dto_mig_ao-migrationsobjekt = 'SSTW'.  "Dauer Annahmeanordnungen

                /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                  EXPORTING
                    i_gi_id = 'MIG_AO_SSTW'
                    i_para  = l_param
                  CHANGING
                    c_data  = l_dto_psm_ao_bel_create  ).

                IF l_dto_mig_ao-sstw_ueberzahlung = abap_true.
                  " 1 Cent buchen
                  l_dto_psm_ao_bel_create-t_kont[ 1 ]-wrbtr = '0.01'.
                  l_dto_psm_ao_bel_create-bldat = l_dto_mig_ao-sstw_ueberzahlung_datum.
                  " als normale ANNAO
                  l_dto_psm_ao_bel_create-psoty = '02'.
                  CLEAR: l_dto_psm_ao_bel_create-recurring, l_dto_psm_ao_bel_create-dbmon, l_dto_psm_ao_bel_create-dbtag,
                  l_dto_psm_ao_bel_create-dbbdt, l_dto_psm_ao_bel_create-dbatr, l_dto_psm_ao_bel_create-dbedt.
                ELSE.

                  IF l_dto_psm_ao_bel_create-dbatr > 0.
* Bei SSTW, AO nur anlegen wenn Rate ab dem Strichtag vorhanden ist (aus XLM, nicht Rückstandskonto).
                  ELSE.
* DBATR = naehsterabrechtermin
* AO nicht anlegen (Rate ab Stichtag ist nicht vorhanden)
                    l_dto_mig_ao-status = '51'.  "AO wird nicht angelegt, weil keine Rate nach Stichtag vorhanden ist
                    MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
                    l_mig_ao_sap_wa-payac01_saknr_hit_first = payac_saknr_hit_first.

                    MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
                    l_proc->save( ).
                    COMMIT WORK.
                    RETURN.
                  ENDIF.
                ENDIF.

              ELSEIF l_dto_mig_ao-migrationsobjekt = 'AWD'. "Dauer Auszahlungsanordnungen

                /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                  EXPORTING
                    i_gi_id = 'MIG_AO_AWD'
                    i_para  = l_param
                  CHANGING
                    c_data  = l_dto_psm_ao_bel_create  ).

              ELSEIF l_dto_mig_ao-migrationsobjekt = 'NF'.

                /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                  EXPORTING
                    i_gi_id = 'MIG_AO_NF'
                    i_para  = l_param
                  CHANGING
                    c_data  = l_dto_psm_ao_bel_create  ).

                IF l_dto_mig_ao-sstw_ueberzahlung = 'X'.
                  l_dto_psm_ao_bel_create-t_kont[ 1 ]-wrbtr = '0.01'.
                  l_dto_psm_ao_bel_create-bldat = l_dto_mig_ao-sstw_ueberzahlung_datum.
                ENDIF.

              ELSE.
                ASSERT 1 = 2.

              ENDIF.
* Ende Mapping je Migrationsobjekt

* Neu DF-1305 Stundung DR Beleg ohne Mahnsperre
              IF l_dto_mig_ao-kennzeichenstundung CA 'SR' AND l_dto_mig_ao-einzelplan <> '11'.
                CLEAR l_dto_psm_ao_bel_create-mansp.
              ENDIF.


* AO anlegen
              create_psm_ao_beleg(
                EXPORTING
                  i_dto_psm_ao_bel_create  = l_dto_psm_ao_bel_create
                  i_migrationsobjekt       = l_dto_mig_ao-migrationsobjekt
                IMPORTING
                  e_psm_ao_document_number = l_created_document ).

* Daten und Status übernehmen
              MOVE-CORRESPONDING l_created_document TO l_dto_mig_ao.

            ENDIF.


            l_dto_mig_ao-status = '40'.  "Anordnungsbeleg erzeugt,
            MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
            l_mig_ao_sap_wa-payac01_saknr_hit_first = payac_saknr_hit_first.

            MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
            COMMIT WORK.

          ENDIF.




* 4.  Stundungen / Ratenstundungen

*  Prüfen ob Kennzeichen Stundung gesetzt ist!, nur dann diesen Schritt durchlaufen!
          IF l_dto_mig_ao-kennzeichenstundung = 'S' AND l_dto_mig_ao-epl <> 11.  "Stundung vorhanden

            IF l_dto_mig_ao-status  = '53'.
*nur ausgleichsbeleg erzeugen
              me->create_fm_document_clear(
                EXPORTING
                  i_satz_id     = i_satz_id
                IMPORTING
                  e_error_clear = DATA(lv_error_clear)
              ).

              IF lv_error_clear = abap_true.
                l_dto_mig_ao-status = '53'. "Fehler Ausgleichsbeleg

              ELSE.
                l_dto_mig_ao-status = '50'.           "Stundung und Folgebeleg angelegt

                " Verarbeitungsstatus Mig-AO-SAP speichern
                MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.

                MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
                COMMIT WORK.
              ENDIF.

* 4.1 Stundung
            ELSEIF l_dto_mig_ao-status < '50'. "Noch kein Folgebeleg angelegt
              l_dto_mig_ao-status = '49'.  "Fehler Folgebeleg (Vorbelegung)

              CALL METHOD me->create_stundung
                EXPORTING
                  i_satz_id                = i_satz_id
                IMPORTING
                  e_psm_ao_document_number = DATA(ls_dto)
                  e_error_clear            = lv_error_clear.

* 4.1.1 Neue Anordnungsnummer und neuen Belg übernehmen (Folgebeleg)
              l_dto_mig_ao-lotkz_fb = ls_dto-lotkz.
              l_dto_mig_ao-belnr_fb = ls_dto-belnr.
* Hinweis, Buchungskreis und Geschäftsjahr werden nicht übernommen, geprüft !
              IF NOT ls_dto-lotkz IS INITIAL AND NOT ls_dto-belnr IS INITIAL.
                l_dto_mig_ao-status = '50'.           "Stundung und Folgebeleg angelegt

                IF lv_error_clear = abap_true.
                  l_dto_mig_ao-status = '53'. "Fehler Ausgleichsbeleg
                ENDIF.

* 4.1.2 Verarbeitungsstatus Mig-AO-SAP speichern
                MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
                l_mig_ao_sap_wa-payac01_saknr_hit_first = payac_saknr_hit_first.

                MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
                COMMIT WORK.

              ENDIF.

            ENDIF.
          ENDIF.

**** DF-1727 bei VSA kein Folgebeleg
***          IF l_dto_mig_ao-migrationsobjekt = 'VSA'.
***
***            IF l_dto_mig_ao-status < '50'.    " Noch kein Folgebeleg angelegt
***              l_dto_mig_ao-status = '49'.     " Fehler Folgebeleg (Vorbelegung)
***
**** Mapping noch einmal ausführen
***              /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
***                EXPORTING
***                  i_gi_id = 'MIG_AO_VSA'      " 'MIG_AO_VSA_F' wenn noch mehr geändert werden muss!
***                  i_para  = l_param
***                CHANGING
***                   c_data  = l_dto_psm_ao_bel_create  ).
***
***              l_dto_psm_ao_bel_create-partner = l_dto_mig_ao-partner.
***
**** Anpassungen
***              l_dto_psm_ao_bel_create-psoty ='02'.
***              l_dto_psm_ao_bel_create-blart ='DR'.
***
***              create_psm_ao_beleg(
***                EXPORTING
***                  i_dto_psm_ao_bel_create  = l_dto_psm_ao_bel_create
***                  i_migrationsobjekt       = l_dto_mig_ao-migrationsobjekt
***                IMPORTING
***                  e_psm_ao_document_number = l_created_document ).
***
***
***              IF NOT l_created_document-lotkz IS INITIAL AND NOT l_created_document-belnr IS INITIAL.
***                l_dto_mig_ao-status = '50'.           "Foge AO und Folgebeleg angelegt
***
****      Neue Anordnungsnummer und neuen Beleg übernehmen (Folgebeleg)
***                l_dto_mig_ao-lotkz_fb = l_created_document-lotkz.
***                l_dto_mig_ao-belnr_fb = l_created_document-belnr.
***
**** 4.1.2 Verarbeitungsstatus Mig-AO-SAP speichern
***                MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
***                l_mig_ao_sap_wa-payac01_saknr_hit_first = payac_saknr_hit_first.
***
***                MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
***                COMMIT WORK.
***
***              ENDIF.
***            ENDIF.
***          ENDIF.

          " Raten Stundung verarbeiten
          " Wenn noch kein Folgebeleg angelegt
          " außer EP11 = Justiz, hier keine weitere Verarbeitung
          IF l_dto_mig_ao-kennzeichenstundung = 'R' AND l_dto_mig_ao-status < '50' AND l_dto_mig_ao-epl <> 11.
* 4.2 Ratenstundungen
            l_dto_mig_ao-status = '49'.  "Fehler Folgebeleg (Vorbelegung)

            CALL METHOD me->create_ratenstundung
              EXPORTING
                i_satz_id                = i_satz_id
              IMPORTING
                e_psm_ao_document_number = DATA(ls_dto_rs).

* 4.2.1 Neue Anordnungsnummer und neuen Belg übernehmen (Folgebeleg)
            l_dto_mig_ao-lotkz_fb = ls_dto_rs-lotkz.
            l_dto_mig_ao-belnr_fb = ls_dto_rs-belnr.

            IF NOT ls_dto_rs-lotkz IS INITIAL AND NOT ls_dto_rs-belnr IS INITIAL.
              l_dto_mig_ao-status = '50'.           "Stundung und Folgebeleg angelegt

* 4.2.2 Verarbeitungsstatus Mig-AO-SAP speichern
              MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
              l_mig_ao_sap_wa-payac01_saknr_hit_first = payac_saknr_hit_first.

              MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
              COMMIT WORK.

            ENDIF.

          ENDIF.

**** nach neuer Lösung entfällt die Zahlung und wird durch Kontoauszug ersetzt
**** Bei SSTE und EPL50 und Betragoffen <> 0 und Soll = Ist <> = soll eine AnnAO + Zahlung gebucht werden
**** DF-1700
**          IF l_dto_mig_ao-status < '50' AND l_dto_mig_ao-migrationsobjekt = 'SSTE' AND l_dto_mig_ao-einzelplan = '50' AND
**            l_dto_mig_ao-betragoffen = '0.00' AND l_dto_mig_ao-sollbetrag = l_dto_mig_ao-istbetrag AND l_dto_mig_ao-sollbetrag <> '0.00'.
**
**            l_dto_mig_ao-status = '49'. " Fehler Folgebeleg
**
**            CLEAR: l_dto_psm_ao_bel_create, l_created_document.
**            /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
**                             EXPORTING
**                               i_gi_id = 'MIG_AO'
**                               i_para  = l_param
**                             CHANGING
**                               c_data  = l_dto_psm_ao_bel_create  ).
**
**            l_dto_psm_ao_bel_create-t_kont[ 1 ]-wrbtr = l_dto_mig_ao-sollbetrag.
**            l_dto_psm_ao_bel_create-rebzg = l_dto_mig_ao-belnr.
**            l_dto_psm_ao_bel_create-rebzj = l_dto_mig_ao-gjahr.
**
**            " zahlungsbeleg erstellen
**            create_acc_doc_post(
**              EXPORTING
**                i_dto_psm_ao_bel_create  = l_dto_psm_ao_bel_create                 " DTO: Anlegen eines Beleges zu einer PSM-Anordnung
**              IMPORTING
**                e_psm_ao_document_number = l_created_document                " Beleg Nummer zu AO
**            ).
**
**            MOVE-CORRESPONDING l_created_document TO l_dto_mig_ao.
**            l_dto_mig_ao-status = '50'. " folgebeleg erstellt
**            MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
**
**            MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
**            COMMIT WORK.
**
**          ENDIF.
        ENDIF.


* 5.0 Meldungen

* Fehler abfangen und aktuellen Status ablegen
      CATCH cx_root INTO l_oerror1.
        ROLLBACK WORK.

        l_ln_art = 'MIG_AO'.
        l_ln_key = i_satz_id.  "Satz_ID

        l_proc->add_event(
          EXPORTING
            i_event_category = 'E'
*           i_event_category2 = ''
            i_exception      = l_oerror1
            i_ln_art         = l_ln_art
            i_ln_key         = l_ln_key ).


* Letzten Status übernehmen
        MOVE-CORRESPONDING l_dto_mig_ao TO l_mig_ao_sap_wa.
        MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap_wa.
        COMMIT WORK.

    ENDTRY.


* 5. Meldungen speichern
    l_proc->save( ).

    COMMIT WORK.

  ENDMETHOD.


  METHOD process_mig_aos.

    DATA:
      lt_joblist         TYPE TABLE OF tbtcjob,
      ls_jobsel_param_in TYPE btcselect,
      lv_job_aktive      TYPE i,
      lt_dto_mig_ao_sap  TYPE /thkr/t_dto_mig_ao_sap.

    IF i_max_status = '20' AND i_selection-migrationsobjekt IS INITIAL.
      "Für offene Posten der Kassen sollen beim allgemeinen Durchlauf (keine Einschränkung auf Migrationsobjekt)
      "keine Geschäftspartner erzeugt werden.
      i_selection-flag_no_kass_ops = 'X'.
    ENDIF.


* I_IGNORE_RK_ERROR   übergeben !


    mig_rk->get_tdto_mig_ao(
      EXPORTING
        i_selection = i_selection
      IMPORTING
        et_dto      = DATA(lt_dto) ).

* sortieren nach Buchungsnummer absteigend, GP wird nur einmal (pro Dienststelle) angelegt. Der neuste Eintrag
* (= höchste Buchungsnummer) ist die Grundlage

    SORT lt_dto BY buchungsnummer DESCENDING satz_id.
    DATA(lv_cnt_dto) = lines( lt_dto ).
    IF sy-batch = abap_true.
      "Start EPL &1 Migrationsobjekt &2 für &3 Datensätze.
      MESSAGE i030(/thkr/mig) WITH i_selection-einzelplan i_selection-migrationsobjekt lv_cnt_dto.
    ENDIF.


    IF i_selection-flag_start_as_job = abap_true.
      LOOP AT lt_dto INTO DATA(ls_dto).
        IF sy-tabix MOD i_selection-package_size = 0.
          " prüfen wie viele aktive Jobs noch laufen
          IF lv_job_aktive = i_selection-job_count.
            ls_jobsel_param_in-jobname = 'MIG_AO*'.
            ls_jobsel_param_in-running = abap_true.
            CLEAR lt_joblist.
            DO.
              CALL FUNCTION 'BP_JOB_SELECT'
                EXPORTING
                  jobselect_dialog    = 'N'
                  jobsel_param_in     = ls_jobsel_param_in
                TABLES
                  jobselect_joblist   = lt_joblist
                EXCEPTIONS
                  invalid_dialog_type = 1
                  jobname_missing     = 2
                  no_jobs_found       = 3
                  selection_canceled  = 4
                  username_missing    = 5
                  OTHERS              = 6.
              IF sy-subrc <> 0.
                " dann gibt es kein Job
               ENDIF.
              IF  i_selection-job_count > lines( lt_joblist ).
                lv_job_aktive = lines( lt_joblist ).
                EXIT.
              ELSE.
                WAIT UP TO 20 SECONDS.
              ENDIF.
            ENDDO.
          ENDIF.

          ADD 1 TO lv_job_aktive.
          start_process_mig_ao_as_job(
            EXPORTING
              i_selection       = i_selection
              it_dto_mig_ao_sap = lt_dto_mig_ao_sap
              i_ignore_rk_error = i_ignore_rk_error
              i_max_status      = i_max_status
          ).
          CLEAR lt_dto_mig_ao_sap.
        ENDIF.
        APPEND ls_dto TO lt_dto_mig_ao_sap.

      ENDLOOP.
      IF sy-subrc = 0 AND lt_dto_mig_ao_sap IS NOT INITIAL.
        start_process_mig_ao_as_job(
          i_selection       = i_selection
          it_dto_mig_ao_sap = lt_dto_mig_ao_sap
          i_ignore_rk_error = i_ignore_rk_error
          i_max_status      = i_max_status
        ).
        CLEAR lt_dto_mig_ao_sap.
      ENDIF.
    ELSE.

      LOOP AT lt_dto INTO DATA(l_dto).
        IF sy-batch = abap_true AND sy-index MOD 1000 = 0.
          MESSAGE i032(/thkr/mig) WITH sy-tabix lv_cnt_dto.
        ENDIF.

        process_mig_ao(
          i_satz_id         = l_dto-satz_id
          i_betrag_0        = i_selection-flag_force_betrag_0
          i_ignore_rk_error = i_ignore_rk_error
          i_max_status      = i_max_status ).

      ENDLOOP.


    ENDIF.

  ENDMETHOD.


  METHOD process_mig_mandat.

    TYPES: BEGIN OF lty_param,
             epl        TYPE /thkr/mig_epl,
             schluessel TYPE /thkr/mig_mvw_schluessel,
             uci        TYPE /thkr/mig_mvw_uci,
           END OF lty_param.

    DATA: l_proc              TYPE REF TO /thkr/cl_bfw_process,
          l_dto_bp_create     TYPE  /thkr/s_dto_bp_create,
          l_dto_bp_create_neu TYPE  /thkr/s_dto_bp_create,      "zum Testen Vergleichen
          l_param             TYPE lty_param,
          l_oerror            TYPE REF TO cx_root,
          l_ln_key            TYPE /thkr/event_ln_key,
          l_ln_art            TYPE /thkr/event_ln_art,
          l_mvw_sp            TYPE /thkr/mig_mvw_sp.

    DATA: t_customer TYPE /thkr/s_dto_bp_cust_company.

    DATA: i_selection TYPE /thkr/s_mig_mvw_sap_selection.

*  /THKR/MIG_MVW_SAP_STATUS => Status Werte:

*     Initial
*  10	n.r. - kein GP
*  20	n.r. - mehrere GP
*  30	GP gefunden
*  39	Fehler GP
*  40	GP angelegt
*  50 Gültigkeitsdatum vor 01.11.2025


    "Prozess-Objekt erstellen, um Fehlermeldungen speichern zu lassen
    CREATE OBJECT l_proc
      EXPORTING
        i_process_type = 'MIG_MN'.


    i_selection-epl         = i_epl.
    i_selection-schluessel  = i_schluessel.
    i_selection-uci         = i_uci.


    TRY.

* Vorhandene Meldung löschen
        get_ln_key_mig_mandat(
          EXPORTING
            i_epl        = i_epl
            i_schluessel = i_schluessel
            i_uci        = i_uci
          IMPORTING
           e_ln_key     = l_ln_key ).

        l_ln_art = 'MIG_MN'. "Art unbedingt vor dem Löschen setzen!

        /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
            i_ln_art         = l_ln_art
            i_ln_key         = l_ln_key ).

        COMMIT WORK.

* Migrationsdaten lesen
        get_dto_mig_mvw_me(
          EXPORTING
            i_selection  = i_selection
          IMPORTING
            e_dto        = DATA(l_dto_mig_mvw) ).

**** DEL05112025 START ******************************************************************
        " Verarbeitung abbrechen, wenn Status leer ist
*        IF l_dto_mig_mvw-status_mvw IS INITIAL.
*          RETURN.
*        ENDIF.

** Es werden nur Rahmenmandate berücksichtigt
*        IF l_dto_mig_mvw-kennz_mandatsart NE 'R'.
*          RETURN.
*        ENDIF.

** GP darf nur angelegt werden, wenn nur eins gefunden íst oder auch Fehler gibt!
*        IF l_dto_mig_mvw-status_mvw = '30'                 "GP-Gefunden
*        OR l_dto_mig_mvw-status_mvw = '39'.                "Fehler-GP
**** DEL05112025 ENDE  ******************************************************************


**** INS05112025 START ******************************************************************
* Gültigkeit muss ab / nach dem 01.11.2025 liegen, wenn nicht dann Status 50 und nicht berücksichtigen
        IF l_dto_mig_mvw-dat_gueltigkeit < '20251101'.
          l_dto_mig_mvw-status_mvw = '50'.
* Verarbeitungsstatus speichern
          MOVE-CORRESPONDING l_dto_mig_mvw TO l_mvw_sp.
          MODIFY /thkr/mig_mvw_sp FROM l_mvw_sp.
        ENDIF.
**** INS05112025 ENDE  ******************************************************************

        IF l_dto_mig_mvw-status_mvw  < '40'.
          l_dto_mig_mvw-status_mvw = '39'.                  "Fehler-GP

          l_param-epl        = i_epl.
          l_param-schluessel = i_schluessel.
          l_param-uci        = i_uci.



          "Mapping  für GP anlegen und SEPA Mandat

* MIG_MVW     =  Gen.Schnittstelle Mapping  aus LIF Daten  zum Vergleichen, später raus !
* MIG_MVW_neu =  Gen.Schnittstelle Mapping  aus MCV Daten

**** DEL05112025 START  ******************************************************************
*          /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
*            EXPORTING
*              i_gi_id = 'MIG_MVW'
*              i_para  = l_param
*            CHANGING
*              c_data  = l_dto_bp_create ).
**** DEL05112025 ENDE  ******************************************************************


          /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
             EXPORTING
               i_gi_id = 'MIG_MVW_NEU'
               i_para  = l_param
             CHANGING
               c_data  = l_dto_bp_create_neu ).


          "GP anlegen
          /thkr/cl_mig_bp_appl=>mig_get_instance( )->create_partner(
              EXPORTING
*               i_dto_bp_create = l_dto_bp_create
                i_dto_bp_create = l_dto_bp_create_neu
              IMPORTING
                e_partner       = l_dto_mig_mvw-partner ). " Parnernummer übernehmen

          l_dto_mig_mvw-status_mvw = '40'.                 " Staus angelegt

* Buchungskreis übernehmen (Aus Mapping)
          READ TABLE l_dto_bp_create-customer-t_customer_company INDEX 1 INTO t_customer.
          l_dto_mig_mvw-bukrs = t_customer-bukrs.

* Verarbeitungsstatus speichern
          MOVE-CORRESPONDING l_dto_mig_mvw TO l_mvw_sp.
          MODIFY /thkr/mig_mvw_sp FROM l_mvw_sp.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

        ENDIF.


      CATCH cx_root INTO DATA(l_oerror1).
        ROLLBACK WORK.

        l_ln_art = 'MIG_MN'.

        l_proc->add_event(
          EXPORTING
            i_event_category = 'E'
*           i_event_category2 = ''
            i_exception      = l_oerror1
            i_ln_art         = l_ln_art
            i_ln_key         = l_ln_key ).


* Letzten Status übernehmen
        MOVE-CORRESPONDING l_dto_mig_mvw TO l_mvw_sp.
        MODIFY /thkr/mig_mvw_sp FROM l_mvw_sp.
        COMMIT WORK.

    ENDTRY.

    "Meldung speichern
    l_proc->save( ).


    COMMIT WORK.



  ENDMETHOD.


  METHOD process_mig_mandats.

*Verarbeitung alle selktierten Einträge

* Datenen einlesen
    get_tdto_mig_mvw(
       EXPORTING
         i_selection = i_selection
       IMPORTING
        et_dto      =  DATA(lt_dto)  ).

* Sätze verarbeiten
    LOOP AT lt_dto INTO DATA(l_dto).

      process_mig_mandat(
       EXPORTING
       i_epl        = l_dto-epl
       i_schluessel = l_dto-schluessel
       i_uci        = l_dto-uci ).

    ENDLOOP.


  ENDMETHOD.


  METHOD process_mig_rk.

    TYPES: BEGIN OF lty_param,
             satz_id TYPE /thkr/de_satz_id,
           END OF lty_param.

    DATA: l_param          TYPE lty_param,
*          l_cr_beleg              TYPE /thkr/s_dto_psm_ao_bel_create, "DTO: Kopf PSM-Anordnung, DTO: Beleg einer Anordnung, Übergabeparmeter für AO APPL Methoden
*          l_dto_bp_create         TYPE /thkr/s_dto_bp_create,
*          l_dto_psm_ao_bel_create TYPE /thkr/s_dto_psm_ao_bel_create,
          l_oerror         TYPE REF TO cx_root,

          l_ln_key         TYPE /thkr/event_ln_key,
          l_ln_art         TYPE /thkr/event_ln_art,
          lt_ln_evt        TYPE /thkr/t_ln_evt,
          l_line_key_value TYPE string,
          l_mig_rk_sap_wa  TYPE /thkr/mig_rk_sap,


          l_proc           TYPE REF TO /thkr/cl_bfw_process.

    "Prozess-Objekt erstellen, um Fehlermeldungen speichern zu lassen
    CREATE OBJECT l_proc
      EXPORTING
        i_process_type = 'MIG_RK'.

    mig_rk->get_dto_mig_rk(
      EXPORTING
        i_satz_id = i_satz_id
      IMPORTING
        e_dto     = DATA(l_dto_mig_rk) ).

    MOVE-CORRESPONDING l_dto_mig_rk TO l_mig_rk_sap_wa.

****  Meldungen ****************************************************************

    TRY.

        l_param-satz_id = i_satz_id.
*       "Eventuell vorhandene Meldungen zur Zeile löschen
        l_ln_art = 'MIG_RK'.
        l_ln_key = i_satz_id.  "Satz_ID

        /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
            i_ln_art         = l_ln_art
            i_ln_key         = l_ln_key ).

        COMMIT WORK.

        IF l_dto_mig_rk-status < '10'.    "Noch nicht initialisiert

          l_dto_mig_rk-status = '09'.     "Fehler Initialisierung



*          get_bukrs_by_epl(
*            EXPORTING
*              i_epl   = l_dto_mig_rk-einzelplan
*            IMPORTING
*              e_bukrs = l_dto_mig_rk-bukrs ).

          MOVE-CORRESPONDING l_dto_mig_rk TO l_mig_rk_sap_wa.
          MODIFY /thkr/mig_rk_sap FROM l_mig_rk_sap_wa.
          COMMIT WORK.

        ENDIF.

      CATCH cx_root INTO DATA(l_oerror1).

        ROLLBACK WORK.

*        CREATE OBJECT l_oerror TYPE /thkr/cx_ext_if
*          EXPORTING
*            textid   = /thkr/cx_ext_if=>record_processing_error
*            satz_id  = l_param-beleg->de_beleg_id
*            previous = l_oerror1.
*
        l_proc->add_event(
          EXPORTING
            i_event_category = 'E'
*           i_event_category2 = ''
            i_exception      = l_oerror1
            i_ln_art         = l_ln_art
            i_ln_key         = l_ln_key ).
*
    ENDTRY.


***** 5. Verarbeitungsstatus Mig-RK speichern
****    MOVE-CORRESPONDING l_dto_mig_rk TO l_mig_rk_sap_wa.
****    MODIFY /thkr/mig_ao_sap FROM l_mig_rk_sap_wa.


* 6. Meldungen speichern
    l_proc->save( ).

    COMMIT WORK.

  ENDMETHOD.


  METHOD reset_mig_ao.

    ASSERT i_satz_id IS NOT INITIAL.

    DATA: l_ln_key TYPE /thkr/event_ln_key,
          l_ln_art TYPE /thkr/event_ln_art.

*       "Eventuell vorhandene Meldungen zur Zeile löschen
    l_ln_art = 'MIG_AO'.
    l_ln_key = i_satz_id.  "Satz_ID

    /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
        i_ln_art         = l_ln_art
        i_ln_key         = l_ln_key ).

    SELECT SINGLE * INTO @DATA(l_mig_ao)
      FROM /thkr/mig_ao_sap
      WHERE satz_id = @i_satz_id.

    ASSERT sy-subrc = 0.

    CLEAR: l_mig_ao-bukrs, l_mig_ao-gjahr, l_mig_ao-lotkz, l_mig_ao-belnr, l_mig_ao-lotkz_fb, l_mig_ao-belnr_fb.

    IF i_only_ao IS INITIAL.
      CLEAR: l_mig_ao-partner, l_mig_ao-partner_created, l_mig_ao-kz_piud, l_mig_ao-status, l_mig_ao-bkvid.
    ELSE.
      IF l_mig_ao-partner IS NOT INITIAL.
        l_mig_ao-status = '20'. "GP freigegeben
      ELSE.
        CLEAR l_mig_ao-status.
      ENDIF.
    ENDIF.

    MODIFY /thkr/mig_ao_sap FROM l_mig_ao.
    COMMIT WORK.

  ENDMETHOD.


  METHOD reset_mig_aos.

    ASSERT i_selection-migrationsobjekt IS NOT INITIAL.
    IF i_selection-r_satz_id IS INITIAL AND i_selection-r_kassenzeichen IS INITIAL.
      ASSERT i_selection-einzelplan IS NOT INITIAL.
    ENDIF.

    mig_rk->get_tdto_mig_ao(
      EXPORTING
        i_selection = i_selection
      IMPORTING
        et_dto      = DATA(lt_dto) ).

    LOOP AT lt_dto INTO DATA(l_dto).

      reset_mig_ao(
        i_satz_id = l_dto-satz_id
        i_only_ao = i_only_ao
      ).

    ENDLOOP.

    COMMIT WORK.

  ENDMETHOD.


  METHOD set_flag_no_ms2.

    flag_no_ms2 = i_flag_no_ms2.

  ENDMETHOD.


  METHOD start_process_mig_ao_as_job.

    DATA: so_dtoao  TYPE RANGE OF /thkr/de_satz_id,
          lv_number TYPE tbtcjob-jobcount,
          lv_name   TYPE tbtcjob-jobname VALUE 'MIG_AO'.


    LOOP AT it_dto_mig_ao_sap ASSIGNING FIELD-SYMBOL(<fs_satz_id>).
      APPEND INITIAL LINE TO so_dtoao ASSIGNING FIELD-SYMBOL(<fs_selopt>).
      <fs_selopt>-sign = 'I'.
      <fs_selopt>-option = 'EQ'.
      <fs_selopt>-low  = <fs_satz_id>-satz_id.
    ENDLOOP.
    IF sy-subrc <> 0.
      MESSAGE 'Keine Daten zu verarbeiten.' TYPE 'I'.
      RETURN.
    ENDIF.

    lv_name = lv_name && '_' && <fs_satz_id>-satz_id.

    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = lv_name
      IMPORTING
        jobcount         = lv_number
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.
    IF sy-subrc = 0.

      SUBMIT /thkr/mig_ao_job
        WITH p_max    = i_max_status
        WITH p_rk_p   = i_ignore_rk_error
        WITH p_btr0_b = i_selection-flag_force_betrag_0
        WITH so_dtoao IN so_dtoao
        VIA JOB lv_name NUMBER lv_number AND RETURN.

      IF sy-subrc = 0.
        CALL FUNCTION 'JOB_CLOSE'
          EXPORTING
            jobcount             = lv_number
            jobname              = lv_name
            strtimmed            = 'X'
          EXCEPTIONS
            cant_start_immediate = 1
            invalid_startdate    = 2
            jobname_missing      = 3
            job_close_failed     = 4
            job_nosteps          = 5
            job_notex            = 6
            lock_failed          = 7
            OTHERS               = 8.
        IF sy-subrc = 0.
          IF sy-batch = abap_true.
            MESSAGE |Job  { lv_name } gestartet. | TYPE 'I'.
          ENDIF.

        ELSE.
          MESSAGE ID sy-msgid
              TYPE 'I'
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              DISPLAY LIKE sy-msgty.
        ENDIF.
      ELSE.

        MESSAGE ID sy-msgid
                TYPE 'I'
                NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                DISPLAY LIKE sy-msgty.
      ENDIF.
    ENDIF.






  ENDMETHOD.
ENDCLASS.

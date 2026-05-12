class /THKR/CL_PSO_XML_PROCESSING definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_s_instance,
        key   TYPE /aif/sxmssmguid,
        value TYPE REF TO /thkr/cl_pso_xml_processing,
      END OF ty_s_instance .
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
    ty_t_instances TYPE STANDARD TABLE OF ty_s_instance .
  types:
    BEGIN OF ty_s_finance_data,
        belnr    TYPE kblnr,
        bukrs    TYPE bukrs,
        fikrs    TYPE fikrs,
        fistl    TYPE fistl,
        fipex    TYPE fipex,
        gsber    TYPE gsber,
        saknr    TYPE saknr,
        kostl    TYPE kostl,
        zz_mwskz TYPE mwskz,
        sgtxt    TYPE sgtxt,
        wrbtr    TYPE wrbtr,
        kunnr    TYPE kunnr,
        lifnr    TYPE lifnr,
        augdt    TYPE augdt,
        augbl    TYPE augbl,
* Gereon Koks  TSI  24.2.2026
        gjahr    TYPE gjahr,
      END OF ty_s_finance_data .
  types:
    BEGIN OF ty_s_meta,
        lotkz TYPE lotkz,
        belnr TYPE belnr_d,
        xblnr TYPE xblnr,
      END OF ty_s_meta .
  types:
    BEGIN OF ty_s_mb_data,
        belnr    TYPE kblnr,
        blpos    TYPE kblpos,
        bukrs    TYPE bukrs,
        fikrs    TYPE fikrs,
        fistl    TYPE fistl,
        fipex    TYPE fipex,
        gsber    TYPE gsber,
        saknr    TYPE saknr,
        kostl    TYPE kostl,
        zz_mwskz TYPE mwskz,
        wtges    TYPE kblwtg,
        wtorig   TYPE fmwtorig,
      END OF ty_s_mb_data .

  class-data MO_INSTANCE type ref to /THKR/CL_PSO_XML_PROCESSING .
  data MS_MB_DATA type TY_S_MB_DATA .
  data MS_AO_REF type TY_S_FINANCE_DATA .
  constants GC_MSGID type SYMSGID value '/THKR/SST' ##NO_TEXT.
  class-data MT_INSTANCES type TY_T_INSTANCES .
  data MV_RANDOM type NUM4 .

  class-methods GET_INSTANCE
    returning
      value(RO_INSTANCE) type ref to /THKR/CL_PSO_XML_PROCESSING .
  methods GET_BUKRS
    importing
      !IV_EP type /THKR/MIG_EPL
      !IV_DST_OLD type /THKR/MIG_DST_OLD
    returning
      value(RV_BUKRS) type BUKRS .
  methods GET_MWSKZ
    importing
      !IV_BLART type BLART
      !IV_BUKRS type BUKRS
      !IV_SAKNR type SAKNR
      !IV_BTYP type STRING
      !IV_BKZ type STRING
    returning
      value(RV_MWSKZ) type STRING .
  methods GET_AKONT
    importing
      !IV_/THKR/SST type /THKR/DTE_BU_SST
      !IV_KOART type KOART
    returning
      value(RV_AKONT) type AKONT .
  methods GET_/THKR/SST
    importing
      !IS_RAW_STRUCT type /THKR/S_DE_PSO_XML_FILE
      value(IS_RAW_LINE) type /THKR/S_DE_PSO_FMBSEC
    returning
      value(RV_/THKR/SST) type /THKR/DTE_BU_SST .
  methods GET_/THKR/GSBER
    importing
      !IV_EP type /THKR/MIG_EPL
      !IV_DST_OLD type /THKR/MIG_DST_OLD
    returning
      value(RV_GSBER) type /THKR/DTE_BU_GSBER .
  methods GET_BU_BPEXT_WITHOUT_KEY
    importing
      !IS_RAW_STRUCT type /THKR/S_DE_PSO_XML_FILE
      !IS_RAW_LINE type /THKR/S_DE_PSO_FMBSEC
    returning
      value(RV_BU_BPEXT) type BU_BPEXT .
  methods GET_BU_BPEXT_FOR_KBLK
    importing
      !IS_RAW_STRUCT type /THKR/S_DE_PSO_XML_FILE
      !IS_RAW_LINE type /THKR/S_DE_PSO_FMBSEC
    returning
      value(RV_BU_BPEXT) type BU_BPEXT .
  methods GET_PARTNER
    importing
      !IV_BLART type BLART
      !IV_KUNNR type KUNNR
      !IV_LIFNR type LIFNR
      !IV_SST type /THKR/DTE_BU_SST
      !IV_BELNR type BELNR_D
      !IV_GJAHR type GJAHR
    exporting
      !EV_BPEXT type BU_BPEXT
    returning
      value(RV_PARTNER) type PARTNER .
  methods GET_MB_DATA
    importing
      !IV_KBLNR type KBLNR
      !IS_KBLK type KBLK
      !IV_FIPEX type FM_FIPEX
      !IV_FISTL type FISTL
      !IV_BLPOS type KBLPOS optional
    exporting
      !EV_MB_IN_FILE type FLAG
    changing
      !CT_MSGS type BAPIRET2_TT .
  methods GET_AO_DATA
    importing
      !IV_KASSZ type XBLNR
      !IS_OUT_STRUCT type /THKR/S_PSO_XML_SAP
      !I_NS type /AIF/NS optional
      !I_IFNAME type /AIF/IFNAME optional
      !I_IFVERSION type /AIF/IFVERSION optional
    exporting
      !IV_BELNR type BELNR_D
    changing
      !CT_MSGS type BAPIRET2_TT .
  methods PROCESS_AO
    importing
      !IT_GP type /THKR/T_DTO_BP_CREATE
      !IT_ANORDNUNGEN type /THKR/T_PSO_XML_ANORDNUNGEN
    changing
      !CT_AO type /THKR/T_DTO_PSM_AO_BEL_CREATE
      !CT_RETURN type BAPIRET2_TT
      !CV_SUCCESS type /AIF/SUCCESSFLAG .
  methods GET_PROCESSING_STATUS
    importing
      !IS_DATA type /THKR/S_PSO_XML_SAP_OBJECTS
      !IV_GLBLID type /THKR/AIF_GLBLID
      !IV_MSGTY type SYMSGTY
    exporting
      !ET_MSGS type BAPIRET2_TT
      !ES_META type TY_S_META
      !ET_BP_MSGS type BAPIRET2_TT
    returning
      value(RV_STATUS) type /AIF/PROC_STATUS .
  methods PROCESS_MV
    importing
      !IT_GP type /THKR/T_DTO_BP_CREATE
    changing
      !CT_MV type /THKR/T_DTO_PSM_MV_CREATE
      !CT_RETURN type BAPIRET2_TT
      !CV_SUCCESS type /AIF/SUCCESSFLAG .
  methods PROCESS_BP
    changing
      !CT_BP type /THKR/T_DTO_BP_CREATE
      !CT_RETURN type BAPIRET2_TT
      !CV_SUCCESS type /AIF/SUCCESSFLAG
      !CT_ANORDNUNGEN type /THKR/T_PSO_XML_ANORDNUNGEN .
  methods GET_WAERS
    importing
      !IV_WAERS type WAERS
      !IV_BUKRS type BUKRS
    returning
      value(RV_WAERS) type STRING .
  methods PROCESS_STU
    changing
      !CT_AO type /THKR/T_DTO_PSM_AO_BEL_CREATE
      !CT_RETURN type BAPIRET2_TT
      !CV_SUCCESS type /AIF/SUCCESSFLAG .
  methods GET_HKONT
    importing
      !IV_GJAHR type PAYAC02-GJAHR
      !IV_BUKRS type PAYAC07-BUKRS
      !IV_FIPEX type FMCI-FIPEX
      !IV_FISTL type PAYAC01-FISTL
      !IV_PSOTY type PAYAC01-PSOTY
      !IV_BLART type PSO02-BLART
    returning
      value(RV_SAKNR) type PAYAC01-SAKNR .
  methods PROCESS_STORNO
    changing
      !CT_STORNO type /THKR/T_DTO_PSM_STORNO
      !CT_RETURN type BAPIRET2_TT
      !CV_SUCCESS type /AIF/SUCCESSFLAG .
  methods UPD_XREF1_HD
    importing
      !IT_AO type /THKR/T_DTO_PSM_AO_BEL_CREATE
    changing
      !CT_RETURN type BAPIRET2_TT
      !CV_SUCCESS type /AIF/SUCCESSFLAG .
  methods MAP_DEST_LINE_AO_WITH_DB
    changing
      !CS_DEST_LINE type /THKR/S_AIF_SAP_AO .
  methods MAP_DEST_LINE_AO_WITH_FILE
    importing
      !IT_KBLP type /THKR/TT_KBLP
      !IV_KBLNR type KBLNR
      !IS_KBLK type KBLK
      !IV_KBLPOS type KBLPOS
    changing
      !CS_DEST_LINE type /THKR/S_AIF_SAP_AO .
  methods MAP_DEST_LINE_VR_SENDER
    importing
      !IS_PSO02S type PSO02S
    changing
      !CS_DEST_LINE type /THKR/S_AIF_SAP_VR .
  methods MAP_DEST_LINE_VR_RECEIVER
    importing
      !IS_PSO02S type PSO02S
      !IV_PSOTY type PSOTY_D
      !IV_BLART type BLART
    changing
      !CS_DEST_LINE type /THKR/S_DTO_PSM_AO_KONT .
  methods PROCESS_VR
    changing
      !CT_VR type /THKR/T_DTO_PSM_VR_CREATE
      !CT_RETURN type BAPIRET2_TT
      !CV_SUCCESS type /AIF/SUCCESSFLAG .
  methods CHECK_AO_REF_EXISTS
    importing
      !IV_URKASS type XBLNR
    returning
      value(RV_EXISTS) type FLAG .
  methods GET_FIPOS
    importing
      !IV_FIPEX type FM_FIPEX
    returning
      value(RV_FIPOS) type FIPOS_XPO .
  methods CHECK_GJHR
    importing
      !IV_GJAHR type GJAHR
    returning
      value(RV_OK) type FLAG .
  methods CHECK_BUKRS
    importing
      !IV_BURKS type BUKRS
    returning
      value(RV_OK) type FLAG .
  methods PROCESS_MV_UP
    changing
      !CT_MV_UP type /THKR/T_DTO_PSM_MV_UP_CREATE
      !CT_RETURN type BAPIRET2_TT
      !CV_SUCCESS type /AIF/SUCCESSFLAG .
  methods CHECK_APPEND_VA
    importing
      !IV_BELNR type BELNR_D
      !IV_BLPOS type FMR_SBLPOS
      !IV_BPENT type FMSUPPNR
    returning
      value(RV_APPEND_OK) type FLAG .
  methods MAP_MV_UP_BY_KBLE
    importing
      !IS_KBLE type KBLE
    changing
      !CS_DEST_LINE type /THKR/S_AIF_SAP_MV_UP .
  methods MAP_MV_UP_BY_KBLP
    importing
      !IS_KBLP type KBLP
      !IV_BOOKED_KBLE_WTAPP_GES type FMWTSUPP
    changing
      !CS_DEST_LINE type /THKR/S_AIF_SAP_MV_UP .
  methods MAP_BLART_FOR_MB
    importing
      !IV_BANKS type BANKS
      !IV_PSOTY type PSOTY_D
      !IV_BLART type BLART
    returning
      value(RV_BLART) type BLART .
  methods GET_FIPEX
    importing
      !IV_KAPITEL type STRING
      !IV_TITEL type STRING
      !IV_EP type STRING
      !IV_UK type STRING
    changing
      value(CV_FIPEX) type FM_FIPEX .
  methods CHECK_MB_BPOS_EXISTS
    importing
      !IS_DATA_STRUCT type /THKR/S_DE_PSO_XML_FILE
      !IS_DATA_LINE type KBLK
      !IV_BELNR type BELNR_D optional
      !IV_BPOS type KBLPOS optional
      !IV_FISTL type FISTL optional
      !IV_FIPEX type FM_FIPEX optional
    returning
      value(RV_ERROR) type FLAG .
  methods CHECK_MB_BPOS_DOES_NOT_EXIST
    importing
      !IS_DATA_STRUCT type /THKR/S_DE_PSO_XML_FILE
      !IS_DATA_LINE type KBLK
      !IV_BELNR type BELNR_D optional
      !IV_BPOS type KBLPOS optional
      !IV_FISTL type FISTL optional
      !IV_FIPEX type FM_FIPEX optional
      !IV_PARTNER type PARTNER optional
      !IV_ZZ_MWSKZ type MWSKZ optional
      !IV_CONSUMEKZ type FMCONSUME optional
      !IV_BLART type BLART optional
    changing
      !CT_RETURN type BAPIRET2_TT
    returning
      value(RV_ERROR) type FLAG .
  methods MAP_BU_TYPE
    importing
      !IV_STKZN type STKZN
    returning
      value(RV_BU_TYPE) type BU_TYPE .
  methods CHECK_FILE_ORDER
    importing
      !IV_TSTMP type TIMESTAMP
    changing
      !CT_RETURN type BAPIRET2_TT .
  methods SAVE_LONGTEXT
    importing
      !IS_DATA_STRUCT type ANY
      !IV_INSERT type FLAG
    changing
      !CT_RETURN type BAPIRET2_TT
    returning
      value(RV_SUCCESS) type /AIF/SUCCESSFLAG .
  methods GET_BPOS
    importing
      !IV_FIPEX type FM_FIPEX
      !IV_FISTL type FISTL
      !IV_BELNR type BELNR_D
      !IV_BPOS type KBLPOS
    returning
      value(RV_BLPOS) type KBLPOS .
  methods GET_FIELD_FORM_BUFFER
    importing
      !IV_TYPE type CHAR2
      !IV_KASSZ type XBLNR
      !IV_FIELDNAME type FIELDNAME
    returning
      value(RV_FIELDVALUE) type STRING .
  methods FILL_INSTANCE_INFORMATION
    changing
      !CT_RETURN type BAPIRET2_TT .
  methods CONSTRUCTOR
    importing
      !IS_RUN_INFO type TY_S_RUN_INFO .
  methods CHECK_BP_IS_CPD
    importing
      !IV_BPEX type BU_BPEXT
    exporting
      !EV_IS_CPD type FLAG
    returning
      value(RV_IS_CPD) type FLAG .
  methods CHECK_BP_FOR_MB
    importing
      !IV_BLART type BLART
      !IS_DATA_LINE type ANY
      !IS_DATA_FIELD type STRING
      !IS_DATA type ANY
    changing
      !CT_RETURN type BAPIRET2_TT
    returning
      value(RV_ADD_BP_TO_MB) type FLAG .
  methods CREATE_CPD_BPEXT_ID
    importing
      !IV_BELNR type BELNR_D
      !IV_GJAHR type GJAHR
    returning
      value(RV_BU_BPEXT) type BU_BPEXT .
protected section.
private section.

  types:
    BEGIN OF ty_s_finance_buffer,
      kassz        TYPE xblnr,
      finance_data TYPE ty_s_finance_data,
    END OF ty_s_finance_buffer .
  types:
    ty_t_finance_buffer TYPE STANDARD TABLE OF ty_s_finance_buffer .
  types:
    BEGIN OF ty_s_mb_buffer,
      kblnr        TYPE kblnr,
      finance_data TYPE ty_s_mb_data,
    END OF ty_s_mB_buffer .
  types:
    ty_t_mb_buffer TYPE STANDARD TABLE OF ty_s_mb_buffer .
  types:
    BEGIN OF ty_s_si_tab_val,
      guid        TYPE guid_32,
      create_date TYPE /aif/create_date,
      tstmp       TYPE timestamp,
    END OF ty_s_si_tab_val .

  data MT_FINANCE_BUFFER type TY_T_FINANCE_BUFFER .
  data MT_MB_BUFFER type TY_T_MB_BUFFER .
  data MT_BELNR_GP_BA type TDT_BELNR_D .
  data MT_/THKR/SST_GP_BA type TDT_BELNR_D .
  data MS_AIF_GLOBALES type TY_S_RUN_INFO .
  data MO_AO_APPL type ref to /THKR/CL_PSM_AO_APPL .
  data MO_MV_APPL type ref to /THKR/CL_PSM_MV_APPL .
  data MO_BP_APPL type ref to /THKR/CL_BP_APPL .

  methods GET_MWSKZ_VIA_AIF
    importing
      !IV_BLART type BLART
      !IV_BTYP type STRING
      !IV_BKZ type STRING
    returning
      value(RV_MWSKZ) type STRING .
  methods GET_SAP_BP_AFTER_ACTION
    importing
      !IT_GP type /THKR/T_DTO_BP_CREATE
    changing
      !CV_SUCCESS type /AIF/SUCCESSFLAG
      !CT_RETURN type BAPIRET2_TT
      value(CS_AO) type /THKR/S_AIF_SAP_AO
      !CV_PROCESS_AO type FLAG .
  methods CHECK_MB_PROCESSING
    importing
      !IS_AO type /THKR/S_AIF_SAP_AO
      !IT_ANORDNUNGEN type /THKR/T_PSO_XML_ANORDNUNGEN
    changing
      !CT_RETURN type BAPIRET2_TT
      !CV_PROCESS_AO type FLAG
      !CV_SUCCESS type /AIF/SUCCESSFLAG
    returning
      value(RS_DTO_PSM_AO) type /THKR/S_DTO_PSM_AO_BEL_CREATE .
  methods UPD_AUSAO_WITH_KASSZ_ANAO
    importing
      !IS_AO type /THKR/S_AIF_SAP_AO
    changing
      !CT_AO type /THKR/T_DTO_PSM_AO_BEL_CREATE .
  methods CALC_MV_UP_AMOUNT_FOR_KBLP
    importing
      !IV_BTEXT type FMSUPPTEXT
      !IV_WTSUPP type FMWTSUPP
      !IV_BELNR type FMR_SBELNR
      !IV_BLPOS type FMR_SBLPOS
      !IV_WTORIG type FMWTORIG
    returning
      value(RV_WTSUPP) type FMWTSUPP .
  methods CALC_MV_UP_AMOUNT_FOR_KBLE
    importing
      !IV_BTEXT type FMSUPPTEXT
      !IV_WTSUPP type FMWTSUPP
      !IV_BELNR type FMR_SBELNR
      !IV_BLPOS type FMR_SBLPOS
    returning
      value(RV_WTSUPP) type FMWTSUPP .
  methods GET_SINGLE_INDEX_TAB
    returning
      value(RV_INDEX_TABLE) type /AIF/MSG_TBL .
  methods CHECK_BP_ALREADY_ON_DB
    importing
      !IV_BU_TYPE type BU_TYPE
      !IV_BU_BPEXT type BU_BPEXT
      !IV_SST type /THKR/AIF_SST
    changing
      !CV_PARTNER type BU_PARTNER
    returning
      value(RV_EXISTS) type FLAG .
  methods CHECK_CONSUMEKZ_FOR_MB
    importing
      !IV_BLART type BLART
    returning
      value(RV_CONSUMEKZ_NEEDED) type FLAG .
  methods CHECK_ZZ_MWSKZ_FOR_MB
    importing
      !IV_BLART type BLART
    returning
      value(RV_ZZ_MWSKZ_NEEDED) type FLAG .
  methods GET_SAP_BP_AFTER_ACT_MB
    importing
      !IT_GP type /THKR/T_DTO_BP_CREATE
    changing
      !CV_SUCCESS type /AIF/SUCCESSFLAG
      !CT_RETURN type BAPIRET2_TT
      value(CS_MV) type /THKR/S_AIF_SAP_MV
      !CV_PROCESS_MV type FLAG .
ENDCLASS.



CLASS /THKR/CL_PSO_XML_PROCESSING IMPLEMENTATION.


  METHOD calc_mv_up_amount_for_kble.
    "KBLE
    "Liefert neuen Abbausatz
    "Daher: Berechnung:
    "neuer Betrag = Abbaubetrag + ermittelte Differenz aus KBLPS
    DATA: lv_diff TYPE fmwtsupp.
    SELECT xPLUS, xminus, wtsupp
      FROM kblps
     WHERE belnr = @iv_belnr
       AND blpos = @iv_blpos
       AND btext = @iv_btext
      INTO TABLE @DATA(lt_kblps).
    IF sy-subrc = 0.
      LOOP AT lt_kblps ASSIGNING FIELD-SYMBOL(<ls_kblps>).
        DATA(lv_operator) = COND char1( WHEN <ls_kblps>-xplus = abap_true THEN '+'
                                        WHEN <ls_kblps>-xminus = abap_true THEN '-' ).
        CASE lv_operator.
          WHEN: '+'.
            lv_diff = lv_diff + <ls_kblps>-wtsupp.
          WHEN: '-'.
            lv_diff = lv_diff - <ls_kblps>-wtsupp.
        ENDCASE.
      ENDLOOP.
      rv_wtsupp = iv_wtsupp + lv_diff.
    ELSE.
      rv_wtsupp = iv_wtsupp.
    ENDIF.
  ENDMETHOD.


  METHOD calc_mv_up_amount_for_kblp.
    "KBLP
    "Liefert neuen Gesamtbetrag
    "Daher: Berechnung:
    "neuer Betrag = gelieferter Gesamtbetrag - Originalbetrag + ermittelte Differenz aus KBLPS
    DATA: lv_diff TYPE fmwtsupp.
    SELECT xPLUS, xminus, wtsupp
      FROM kblps
     WHERE belnr = @iv_belnr
       AND blpos = @iv_blpos
       AND btext = @iv_btext
      INTO TABLE @DATA(lt_kblps).
    IF sy-subrc = 0.
      LOOP AT lt_kblps ASSIGNING FIELD-SYMBOL(<ls_kblps>).
        DATA(lv_operator) = COND char1( WHEN <ls_kblps>-xplus = abap_true THEN '+'
                                        WHEN <ls_kblps>-xminus = abap_true THEN '-' ).
        CASE lv_operator.
          WHEN: '+'.
            lv_diff = lv_diff + <ls_kblps>-wtsupp.
          WHEN: '-'.
            lv_diff = lv_diff - <ls_kblps>-wtsupp.
        ENDCASE.
      ENDLOOP.
      rv_wtsupp = iv_wtorig + lv_diff.
      if rv_wtsupp is INITIAL.
        "Kompletter Abbau
        CLEAR:rv_wtsupp.
      else.
        "Betrag wurde erhöht oder verringert.
        rv_wtsupp = iv_wtsupp - ( iv_wtorig + lv_diff ).
      endif.
    ELSE.
      "Es gab noch gar keine Wertanpassung.
      "Berechnung fortsetzen.
      rv_wtsupp = iv_wtsupp.
    ENDIF.

  ENDMETHOD.


  method CHECK_AO_REF_EXISTS.

    DATA: lo_chk TYPE Ref TO /thkr/cl_aif_chk.

    lo_chk = new /thkr/cl_aif_chk( ).

    rv_exists = lo_chk->check_ao_ref_exists( iv_urkass = iv_urkass ).
  endmethod.


  method CHECK_APPEND_VA.
    SELECT SINGLE belnr
      FROM KBLPS
      WHERE belnr = @iv_belnr
        AND blpos = @iv_blpos
        and bpent = @iv_bpent
     INTO @DATA(lv_belnr).
      if sy-subrc = 0.
        rv_append_ok = abap_false.
      else.
        rv_append_ok = abap_true.
      endif.
  endmethod.


METHOD check_bp_already_on_db.
*"----------------------------------------------------------------------
  "Es kann passieren, dass zwei Dateien mit dem selben Geschäftspartner verarbeitet werden sollen.
  "Wenn der Geschäftspartner noch nicht exisitert, dann die Prozedure des Anlegens durchlaufen.
  "Da in beiden Fällen der GP nicht existiert, würde das System einen neuen Anlegen und neue Partner-IDs erzeugen.
  "Für das System bedeutet das, zwei neue Geschäftspartner.
  "Bei Verwendung von SEPA Mandaten ist es nicht möglich, das gleiche Mandat an zwei unterschiedliche Personen zu hinterlegen.
  "Daher muss vor dem Anlegen geprüft werden, ob der Partner nicht doch schon existiert.
  SELECT SINGLE partner
    FROM but000
* Gereon Koks  2.2.2026 TSI
* Reihenfolge des SELECT an Index Z01 angepasst
*    WHERE bpext = @iv_bu_bpext
*      AND type = @iv_bu_type
*      AND /thkr/sst = @iv_sst
    WHERE type      = @iv_bu_type
      AND bpext     = @iv_bu_bpext
      AND /thkr/sst = @iv_sst

    INTO @cv_partner.
  IF sy-subrc = 0.
    "Partner wurde bereits angelegt.
    "Also ändern
    rv_exists = abap_true.
  ELSE.
    "Partner existiert wirklich nicht
    "Neu anlegen.
    "Es kann keine Partnernummer existieren.
    CLEAR cv_partner.
    rv_exists = abap_false.
  ENDIF.
*"----------------------------------------------------------------------
ENDMETHOD.


  METHOD check_bp_for_mb.

    "Prüfung, ob für eine bestimmte Belegart definiert ist,
    "dass der Geschäftspartner vorhanden sein muss.

    DATA: ls_CHECK TYPE  /aif/t_check.
    DATA: ls_TABCHK TYPE  /aif/t_tabchk.
    DATA: lr_data TYPE REF TO data.
    ls_check-mandt = ls_tabchk-mandt = sy-mandt.
    ls_check-aifcheck = ls_tabchk-aifcheck = ''.
    ls_check-ns = ls_tabchk-ns = 'ZALLGE'.
    ls_tabchk-fuba_check = '/THKR/AIF_ZALLGE_CHK_BP_FOR_MB'.

    FIELD-SYMBOLS: <lt_data> TYPE STANDARD TABLE.
    CREATE DATA lr_data like TABLE OF is_data_line.
    ASSIGN lr_data->* To <lt_data>.
    APPEND is_data_line TO <lt_data>.
    CALL FUNCTION '/THKR/AIF_ZALLGE_CHK_BP_FOR_MB'
      EXPORTING
        data_struct = is_data
        data_line   = is_data_line
        data_field  = is_data_field
*       MSGTY       = 'E'
        value1      = conv string( iv_blart )
        value2      = ''
        value3      = ''
        value4      = ''
        value5      = ''
*       T_IFCHECK   =
*       T_IFACT     =
*       T_ACCHECK   =
*       T_FUNC      =
*       T_FMAPCOND  =
        t_check     = ls_check
        t_tabchk    = ls_tabchk
*       SENDING_SYSTEM       =
      TABLES
        return_tab  = ct_return
        data_table  = <lt_data>
      CHANGING
        error       = rv_add_bp_to_mb.

  ENDMETHOD.


  METHOD CHECK_BP_IS_CPD.
    TYPES: lrn_bu_bpext TYPE RANGE OF bu_bpext.
    DATA: lt_bu_bpext TYPE lrn_bu_bpext.
    DATA: ls_bu_bpext TYPE LINE OF lrn_bu_bpext.

    CONSTANTS: lc_ns_zallge TYPE /aif/ns VALUE 'ZALLGE'.
    CONSTANTS: lc_vmap      TYPE /aif/vmapname VALUE 'MAP_PSO_XML_CPD'.

    "auslesen AIF-Mapping für Nummernkreis CPD

    SELECT *
      FROM /aif/t_vmapval
      WHERE ns = @lc_ns_zallge
      AND vmapname = @lc_vmap
    INTO TABLE @DATA(lt_select_option).

    LOOP AT lt_select_option ASSIGNING FIELD-SYMBOL(<ls_so>).
      ASSIGN COMPONENT <ls_so>-ext_value OF STRUCTURE ls_bu_bpext TO FIELD-SYMBOL(<lv_value>).
      <lv_value> = <ls_so>-int_value.
    ENDLOOP.
    APPEND ls_bu_bpext TO lt_bu_bpext.

    IF iv_bpex IN lt_bu_bpext.
      rv_is_cpd = ev_is_cpd = abap_true.
    ELSE.
      rv_is_cpd = ev_is_cpd = abap_false.
    ENDIF.

  ENDMETHOD.


  method CHECK_BUKRS.
    SELECT SINGLE BUKFM
      FRom payac07
     WHERE BUKRS = @iv_burks
      into @DATA(lv_bukrs).
      if sy-subrc = 0.
        rv_ok = abap_true.
      else.
        rv_ok = abap_false.
      endif.
  endmethod.


METHOD check_consumekz_for_mb.
*"----------------------------------------------------------------------
  SELECT single int_value
    FROM /aif/t_vmapval
   WHERE ns = 'ZALLGE'
    AND vmapname = 'MAP_CONSUMEKZ'
    AND ext_value = @iv_BLArt
    INTO @rv_consumekz_needed.
  IF sy-subrc <> 0.
    CLEAR: rv_consumekz_needed.
  ENDIF.
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


  fill_instance_information(
    CHANGING
      ct_return = ct_return
  ).
    "Dateiprüfung aktiviert?
    SELECT SINGLE * FROM /thkr/generation INTO @DATA(ls_/thkr/generation_einst)
      WHERE bibo = 'X'.

    "Satz gefunden und Prüfung ist aktiviert.
    IF sy-subrc = 0 AND ls_/thkr/generation_einst-variante <> 'D'.
      "1. Ermittlung der Single Index Tabelle
      DATA(lv_si_tab) = get_single_index_tab( ).

      SELECT msgguid , create_date,  tstmp
         FROM (lv_si_tab)
         WHERE msgguid <> @ms_aif_globales-ximsgguid
         ORDER BY tstmp DESCENDING
         INTO @ls_si_tab
         UP TO 1 ROWS.
      ENDSELECT.

      IF sy-subrc = 0.
        "Zeitstempel gelieferter Datei muss größer sein, als zuletzt gespeichert.
        IF ls_si_tab-tstmp = iv_tstmp OR ls_si_tab-tstmp > iv_tstmp.
          IF 1 = 0. MESSAGE e056(/thkr/sst) WITH ls_si_tab-guid ls_si_tab-tstmp.ENDIF.
          APPEND VALUE bapiret2( id   = '/THKR/SST'
                                 type = 'E'
                                 number = 056
                                 message_v1 = ls_si_tab-guid
                                 message_v2 = |{ ls_si_tab-tstmp ALIGN = LEFT }| ) TO ct_return.
        ELSE.
          "gelieferter Zeitstempel größer als letzter
          RETURN.
        ENDIF.
      ELSE.
        "Noch kein Eintrag in Single-Index gefunden.
        "Weiterarbeiten.
        RETURN.
      ENDIF.
    ELSE.
      " Error führt zu Abbruch. Verarbeitung soll aber weiter laufen: daher nur Information
      IF 1 = 0. MESSAGE i001(/thkr/sst) WITH 'Generationsnummernprüfung ist deaktiviert.'.ENDIF.
      APPEND VALUE #( id         = '/THKR/SST'
                 number     = 001
                 type       = 'I'
                 message_v1 = 'Generationsnummernprüfung ist deaktiviert.' ) TO ct_return.
      RETURN.
    ENDIF.

  ENDMETHOD.


  method CHECK_GJHR.
    SELECT SINGLE GJHID
      FROM PAYAc02
     WHERE gjahr = @iv_gjahr
      into @DATA(lv_gjahr).
      if sy-subrc = 0.
        rv_ok = abap_true.
      else.
        rv_ok = abap_false.
      endif.
  endmethod.


  METHOD check_mb_bpos_does_not_exist.
    DATA: lv_fipex_mb TYPE fm_fipex.
    DATA: lv_blart TYPE blart.
    DATA: lv_blart_string TYPE string.
    IF iv_belnr IS SUPPLIED AND iv_bpos IS SUPPLIED.
      "Diese Stelle wird durch den AMAP-Funktionsbaustein angesteuert.
      "Im AMAP sind die Felder belegnummer, Finanzstelle, Finanzposition bereits ermittelt.
      "Prüfe für eine konkrete Belegpositionc, ob sie nicht existiert.
      SELECT SINGLE p~belnr, p~lifnr, p~kunnr, p~zz_mwskz, p~consumekz
    FROM kblp AS p
    INNER JOIN kblk AS k
    ON k~belnr = p~belnr
   WHERE k~ktext = @iv_belnr
    AND p~blpos = @iv_bpos
    AND p~fistl = @iv_fistl
    AND p~fipex = @iv_fipex
   INTO @DATA(ls_kblp).
      IF sy-subrc <> 0.
        "Belegposition existiert nicht.
        "Neuanlage erlaubt.
        "Änderung nicht erlaubt
        "Schleife verlassen.
        rv_error = abap_false.
        EXIT.
      ELSE.
        "Belegposition existiert.
        "Neuanlage nicht erlaubt
        "Änderung erlaubt
        rv_error = abap_true.
        "Die Felder Parnter, Steuerkennzeichen und Unbegrenzt überziehbar sind verpflichtend.
        "Daher müssen bestehende allg. Anordnungen aktualisiert werden

        "Prüfung, ob bei der Belegart ein GP vorhanden sein muss.
        DATA(lv_gp_needed) = me->check_bp_for_mb(
                          EXPORTING
                            iv_blart      = iv_blart                " Belegart
                            is_data_line  = is_data_line                 " AIF SAP Struktur für Mittelbindung
                            is_data_field = 'PARTNER'                 " allgemeines flag
                            is_data       = is_data_struct                 " Output Struktur
                          CHANGING
                            ct_return     = ct_return
                        ).

        "Prüfung, ob Verbrauchskennzeichen für Belegart benötigt wird
        DATA(lv_consumekz_needed) = me->check_consumekz_for_mb( iv_blart = iv_blart ).

        "Prüfung, ob Mehrwehrtsteuerkennzeichen benötigt wird.
        DATA(lv_zz_mwskz_needed) = me->check_zz_mwskz_for_mb( iv_blart = iv_blart ).
        IF
          ( lv_zz_mwskz_needed = abap_true AND ls_kblp-zz_mwskz <> iv_zz_mwskz )                                  "MWST-Kennzeichen für allg. AO. -> Pflichtfeld
          OR ( lv_gp_needed = abap_true AND ( ( ls_kblp-lifnr <> iv_partner AND ls_kblp-kunnr IS INITIAL ) OR ( ls_kblp-kunnr <> iv_partner AND ls_kblp-lifnr IS INITIAL ) ) )  "Geschäftspartner muss hinterlegt sein
          OR ( lv_consumekz_needed = abap_true AND ls_kblp-consumekz <> iv_consumekz ).                              "
          rv_error = abap_false.
        ELSE.
          rv_error = abap_true.
        ENDIF.
      ENDIF.
    ELSE.
      "Diese Stelle wird durch die Prüfung angesteuert.
      "Die Prüfung findet vor dem Mapping statt und hat somit nur die Quellwerte verfügbar.
      "Prüfe für jede Belegposition, ob sie nicht existiert.
      "inklusive Finanzposition und Finanzstelle, die dazu erstmal gemappt werden müssen.
      "Finanzstelle und Finanzposition für Mittelbildung ermitteln
      "Bei Mittelbindungen mit mehreren Kontierungen, muss die richtige Zeile rausgesucht werden.

      LOOP AT is_data_struct-values-items[ key-belnr = is_data_line-belnr ]-lt_kblp ASSIGNING FIELD-SYMBOL(<ls_kblp>).

        "zentrale Mappingtabelle lesen
        /thkr/cl_fi_central_mapping=>get_instance( )->read_central_mapping(
            iv_ep  = <ls_kblp>-fipex(2)                 " Einzelplan
            iv_oeh = CONV /thkr/mig_oeh_old( <ls_kblp>-fistl )                " OEH  alt
            iv_kapitel = CONV /thkr/mig_kapitel( <ls_kblp>-fipex+2(4) )
            iv_titel = CONV /thkr/mig_titel( <ls_kblp>-fipex+6(5) )
          ).

        "Finanzstelle
        DATA(lv_fistl_mb) = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-fistl.

        "Finanzposition
        me->get_fipex(
          EXPORTING
            iv_kapitel =  CONV string( <ls_kblp>-fipex+2(4) )                " Kapitel
            iv_titel   =  CONV string( <ls_kblp>-fipex+6(5) )               " Titel
            iv_ep      =  CONV string( <ls_kblp>-fipex(2) )                " Einzelplan
            iv_uk      =  CONV string( <ls_kblp>-fipex+11 )               " Unterkonto
          CHANGING
            cv_fipex   = lv_fipex_mb                 " Finanzposition
        ).

        "Belegart
        CALL FUNCTION '/THKR/AIF_VMAP_PSO_XML_KBLART'
          EXPORTING
            value_in   = ''
*           VALUE_IN2  =
*           VALUE_IN3  =
*           VALUE_IN4  =
*           VALUE_IN5  =
*           SENDING_SYSTEM       =
*           VALUE_FOUND          =
            raw_line   = is_data_line
            raw_struct = is_data_struct
*         TABLES
*           RETURN_TAB =
          CHANGING
            value_out  = lv_blart_string
*         EXCEPTIONS
*           NO_VALUE_FOUND       = 1
*           OTHERS     = 2
          .
        lv_blart = lv_blart_string.

        "Buchungskreis
        DATA(lv_burks) = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-bukrs.

        DATA(lv_saknr) = me->get_hkont(
                           iv_gjahr = is_data_struct-values-items[ key-belnr = is_data_line-belnr ]-key-gjahr                 " Geschäftsjahr
                           iv_bukrs = lv_burks                 " Buchungskreis
                           iv_fipex = lv_fipex_mb                 " Finanzposition
                           iv_fistl = lv_fistl_mb                 " Finanzstelle
                           iv_psoty = ''                 " Belegtyp Zahlungsanordnungen
                           iv_blart = lv_blart                 " Belegart
                         ).

        "Mehrwertsteuerkennzeichen
        DATA(lv_zz_mwskz) = me->get_mwskz(
          EXPORTING
            iv_blart = lv_blart                 " Belegart
            iv_bukrs = lv_burks                " Buchungskreis
            iv_saknr = lv_saknr                 " Nummer des Sachkontos
            iv_btyp  = ''
            iv_bkz   = ''
        ).


        SELECT SINGLE p~belnr, p~lifnr, p~kunnr, p~zz_mwskz, p~consumekz
          FROM kblp AS p
          INNER JOIN kblk AS k
          ON k~belnr = p~belnr
         WHERE k~ktext = @is_data_line-belnr
          AND p~blpos = @<ls_kblp>-blpos
          AND p~fipex = @lv_fipex_mb
          AND p~fistl = @lv_fistl_mb
         INTO @ls_kblp.
        IF sy-subrc <> 0.
          "Belegposition existiert nicht.
          "Neuanlage erlaubt.
          "Änderung nicht erlaubt
          "Schleife verlassen.
          rv_error = abap_false.
          EXIT.
        ELSE.
          "Belegposition existiert.
          "Neuanlage nicht erlaubt
          "Änderung erlaubt
          rv_error = abap_true.
          "Die Felder Parnter, Steuerkennzeichen und Unbegrenzt überziehbar sind verpflichtend.
          "Daher müssen bestehende allg. Anordnungen aktualisiert werden

          "Prüfung, ob bei der Belegart ein GP vorhanden sein muss.
          lv_gp_needed = me->check_bp_for_mb(
                            EXPORTING
                              iv_blart      = lv_blart                " Belegart
                              is_data_line  = is_data_line                 " AIF SAP Struktur für Mittelbindung
                              is_data_field = 'PARTNER'                 " allgemeines flag
                              is_data       = is_data_struct                 " Output Struktur
                            CHANGING
                              ct_return     = ct_return
                          ).
          IF lv_gp_needed = abap_true.
            "Partner
            TRY.
                DATA(lv_bp_ext) = me->get_bu_bpext_for_kblk(
                                     is_raw_struct = is_data_struct
                                     is_raw_line   = is_data_struct-values-items[ key-belnr = is_data_line-belnr ]-lt_pssec[ bsec-belnr = <ls_kblp>-belnr ]                  " FMBEC mit Kundenfeldern
                                   ).
                DATA(lv_partner) = me->get_partner(
                                     EXPORTING
                                       iv_blart = lv_blart                 " Belegart
                                       iv_kunnr = <ls_kblp>-kunnr                 " Debitorennummer
                                       iv_lifnr = <ls_kblp>-lifnr                 " Kontonummer des Lieferanten bzw. Kreditors
                                       iv_sst   = 'KLRP'                 " BP: Schnittstellenpartner
                                       iv_belnr = <ls_kblp>-belnr
                                       iv_gjahr = is_data_struct-values-items[ key-belnr = is_data_line-belnr ]-key-gjahr
*                               IMPORTING
*                                 ev_bpext =                  " Geschäftspartnernummer im externen System
                                   ).
              CATCH cx_sy_itab_line_not_found.
                IF 1 = 0. MESSAGE e001(/thkr/sst) WITH is_data_line-belnr.ENDIF.
                APPEND VALUE bapiret2( id = '/THKR/SST'
                                       number = 001
                                       type = 'E'
                                       message_v1 = 'Keinen Geschäftspartner zur Belegnummer'
                                       message_v2 = is_data_line-belnr
                                       message_v3 = 'im Segment BSEC gefunden' ) TO ct_return.
            ENDTRY.
          ENDIF.

          "Prüfung, ob Verbrauchskennzeichen für Belegart benötigt wird
          lv_consumekz_needed = me->check_consumekz_for_mb( iv_blart = lv_blart ).

          "Prüfung, ob Mehrwehrtsteuerkennzeichen benötigt wird.
          lv_zz_mwskz_needed = me->check_zz_mwskz_for_mb( iv_blart = lv_blart ).
          IF
            ( lv_zz_mwskz_needed = abap_true AND ls_kblp-zz_mwskz <> lv_zz_mwskz )                                  "MWST-Kennzeichen für allg. AO. -> Pflichtfeld
          OR ( lv_gp_needed = abap_true AND ( ( ls_kblp-lifnr <> lv_partner AND ls_kblp-kunnr IS INITIAL ) OR ( ls_kblp-kunnr <> lv_partner AND ls_kblp-lifnr IS INITIAL ) ) )  "Geschäftspartner muss hinterlegt sein
          OR ( lv_consumekz_needed = abap_true AND ls_kblp-consumekz <> <ls_kblp>-consumekz ).                                  "
            rv_error = abap_false.
          ELSE.
            rv_error = abap_true.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD check_mb_bpos_exists.
    DATA: lv_fipex_mb TYPE fm_fipex.

    IF iv_belnr IS SUPPLIED AND iv_bpos IS SUPPLIED.
      "Prüfung einer bestimmten Belegposition
      SELECT SINGLE p~belnr
      FROM kblp AS p
      INNER JOIN kblk AS k
      ON k~belnr = p~belnr
     WHERE k~ktext = @iv_belnr
      AND p~blpos = @iv_bpos
      and p~fistl = @iv_fistl
      and p~fipex = @iv_fipex
     INTO @DATA(lv_belnr).
      IF sy-subrc = 0.
        "Belegposition existiert
        "Neuanlage nicht erlaubt.
        "Änderung erlaubt
        "Schleife verlassen.
        rv_error = abap_false.
        EXIT.
      ELSE.
        "Belegposition existiert nicht.
        "Neuanlage erlaubt
        "Änderung nicht erlaubt
        rv_error = abap_true.
      ENDIF.
    ELSE.
      "Prüfung für jede einzelne Belegposition.
      LOOP AT is_data_struct-values-items[ key-belnr = is_data_line-belnr ]-lt_kblp ASSIGNING FIELD-SYMBOL(<ls_kblp>).
                "zentrale Mappingtabelle lesen
        /thkr/cl_fi_central_mapping=>get_instance( )->read_central_mapping(
            iv_ep  = <ls_kblp>-fipex(2)                 " Einzelplan
            iv_oeh = CONV /thkr/mig_oeh_old( <ls_kblp>-fistl )                " OEH  alt
            iv_kapitel = CONV /thkr/mig_kapitel( <ls_kblp>-fipex+2(4) )
            iv_titel = CONV /thkr/mig_titel( <ls_kblp>-fipex+6(5) )
          ).

        "Finanzstelle
        DATA(lv_fistl_mb) = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-fistl.

        "Finanzposition
        me->get_fipex(
          EXPORTING
            iv_kapitel =  CONV string( <ls_kblp>-fipex+2(4) )                " Kapitel
            iv_titel   =  CONV string( <ls_kblp>-fipex+6(5) )               " Titel
            iv_ep      =  CONV string( <ls_kblp>-fipex(2) )                " Einzelplan
            iv_uk      =  CONV string( <ls_kblp>-fipex+11 )               " Unterkonto
          CHANGING
            cv_fipex   = lv_fipex_mb                 " Finanzposition
        ).
        SELECT SINGLE p~belnr
          FROM kblp AS p
          INNER JOIN kblk AS k
          ON k~belnr = p~belnr
         WHERE k~ktext = @is_data_line-belnr
          AND p~blpos = @<ls_kblp>-blpos
          and p~fipex = @lv_fipex_mb
          and p~fistl = @lv_fistl_mb
         INTO @lv_belnr.
        IF sy-subrc = 0.
          "Belegposition existiert
          "Neuanlage nicht erlaubt.
          "Änderung erlaubt
          "Schleife verlassen.
          rv_error = abap_false.
          EXIT.
        ELSE.
          "Belegposition existiert nicht.
          "Neuanlage erlaubt
          "Änderung nicht erlaubt
          rv_error = abap_true.
        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD check_mb_processing.
    MOVE-CORRESPONDING is_ao TO rs_dto_psm_ao.
    TRY.
        IF rs_dto_psm_ao-t_kont[ 1 ]-kblnr IS NOT INITIAL.
          "SAP Belegnummer der Mittelbindung ermitteln.
          LOOP AT it_anordnungen ASSIGNING FIELD-SYMBOL(<ls_anordnungen>).

            rs_dto_psm_ao-t_kont[ 1 ]-kblnr = <ls_anordnungen>-mb[ ktxt = is_ao-t_kont[ 1 ]-kblnr ]-belnr.
            IF rs_dto_psm_ao-t_kont[ 1 ]-kblnr IS INITIAL
           AND ( <ls_anordnungen>-mb[ ktxt = is_ao-t_kont[ 1 ]-kblnr ]-mv_proc_status = 'E' ).
              "Mittelbindung hat Fehlerverursacht. Keine Buchung der Anordnung
              IF 1 = 0. MESSAGE e032(/thkr/sst) WITH 'Mittelbindung' 'Anordnung'. ENDIF.
              APPEND VALUE #( id         = '/THKR/SST'
                               number     = 032
                               type       = 'E'
                               message_v1 = 'Mittelbindung'
                               message_v2 = 'Anordnung' ) TO ct_return.
              cv_process_ao = abap_false.
              cv_success = 'N'.
              EXIT.
            ENDIF.


          ENDLOOP.
        ENDIF.
      CATCH cx_sy_itab_line_not_found.
        "Mittelbindung nicht in der Datei.
        "Feld KBLNR kommt von der Datenbank und ist somit schon korrekt.
        RETURN.
    ENDTRY.
  ENDMETHOD.


METHOD CHECK_ZZ_MWSKZ_FOR_MB.
*"----------------------------------------------------------------------
  SELECT single int_value
    FROM /aif/t_vmapval
   WHERE ns = 'ZALLGE'
    AND vmapname = 'MAP_ZZ_MWSKZ_FOR_MB'
    AND ext_value = @iv_BLArt
    INTO @rv_zz_mwskz_needed.
  IF sy-subrc <> 0.
    CLEAR: rv_zz_mwskz_needed.
  ENDIF.
*"----------------------------------------------------------------------
ENDMETHOD.


  METHOD constructor.
    "Umgebungsvariablen für Schnittselle ermitteln

    ms_aif_globales = is_run_info.

    "Instanziierung der Verarbeitungsklassen.
    mo_ao_appl = NEW /thkr/cl_psm_ao_appl( ).
    mo_mv_appl = NEW /thkr/cl_psm_mv_appl( ).
    mo_bp_appl = NEW /thkr/cl_pso_bp_appl( ).

    "Zufallszahl generieren, um Klasseninstanziierung nachzuverfolgen.
    "Mit jeder neuen Klasseninstanz gibt es eine Zufallszahl.
    "Diese Zufallszahl wird bei höhreren Trace-Level ausgegeben.
    DATA: lv_random TYPE qf00-ran_int.
    CALL FUNCTION 'QF05_RANDOM_INTEGER'
      EXPORTING
        ran_int_max   = 9999
        ran_int_min   = 1
      IMPORTING
        ran_int       = lv_random
      EXCEPTIONS
        invalid_input = 1
        OTHERS        = 2.
    mv_random = lv_random.
  ENDMETHOD.


  method CREATE_CPD_BPEXT_ID.
    DATA: lv_hash TYPE xstring.

            DATA(lv_string) = ms_aif_globales-ximsgguid && iv_belnr && iv_gjahr.
          cl_abap_message_digest=>calculate_hash_for_char(
            EXPORTING
              if_data          = lv_string
            IMPORTING
              ef_hashx         = lv_hash
          ).

          rv_bu_bpext = 'CPD_' && lv_hash.
          rv_bu_bpext = rv_bu_bpext+0(20).
  endmethod.


  METHOD fill_instance_information.

    IF ms_aif_globales-trace_level > 0.
      IF 1 = 0. MESSAGE i068(/thkr/sst) WITH mv_random ms_aif_globales-ximsgguid.ENDIF.
      APPEND VALUE bapiret2( id   = '/THKR/SST'
                 type = 'I'
                 number = 068
                 message_v1 = mv_random
                 message_v2 = ms_aif_globales-ximsgguid ) TO ct_return.
    ENDIF.
  ENDMETHOD.


  method GET_/THKR/GSBER.

    SELECT single GSBER
      FRom /thkr/centralmap
      WHERE ep = @iv_ep
        AND dst_old = @iv_dst_old
      into @rv_gsber.
      if sy-subrc <> 0.
        clear rv_gsber.
      endif.
  endmethod.


  METHOD get_/thkr/sst.

    "Geschäftspartner ohne BLART, BELNR, GJAHR oder LOTKZ
    "Es gibt keinen Bezug zwischen Geschäftspartner und Betragsloser Anordnung.
    LOOP AT is_raw_struct-values-items ASSIGNING FIELD-SYMBOL(<ls_items>) WHERE key-blart = 'BA'.
      "Prüfen, ob Belegnummer bereits verwendet wurde
      READ TABLE mt_/thkr/sst_gp_ba WITH KEY table_line = <ls_items>-key-belnr TRANSPORTING NO FIELDS BINARY SEARCH.
      IF sy-subrc = 0.
        "Belegnummer bereits übernommen.
        "gehe zum nächsten Datensatz.
        CONTINUE.
      ELSE.
        "Belegnummer ist noch nicht übernommen.
        "Zeile in Datenlieferung Identifiziert
        TRY.
            INSERT <ls_items>-key-belnr INTO mt_/thkr/sst_gp_ba INDEX sy-tabix.
            rv_/thkr/sst = <ls_items>-key-bukrs.
            "Belegnummer speichern und Schleife Verlassen
          CATCH cx_sy_itab_line_not_found.
            CLEAR: rv_/thkr/sst.
        ENDTRY.
        "Belegnummer gefunden.
        "Schleife verlassen
        exit.
      ENDIF.
    ENDLOOP.

    CONSTANTS: lc_ns  TYPE /aif/ns VALUE 'ZALLGE'.
    CONSTANTS: lc_vmap TYPE /aif/vmapname VALUE 'MAP_/THKR/SST'.

    SELECT SINGLE int_value
      FROM /aif/t_vmapval5
     WHERE ns = @lc_ns
       AND vmapname = @lc_vmap
       AND ext_value1 = @<ls_items>-key-bukrs
     INTO @rv_/thkr/sst.
    IF sy-subrc <> 0.
      CLEAR rv_/thkr/sst.
    ENDIF.
  ENDMETHOD.


  method GET_AKONT.
    SELECT SINGLE AKONT
      FROM /thkr/cgeb2akto
     WHERE sst = @iv_/thkr/sst
       AND koart = @iv_koart
      into @rv_akont .
      IF sy-subrc <> 0.
        clear: rv_akont.
      endif.
  endmethod.


METHOD get_ao_data.
*"----------------------------------------------------------------------
* Gereon Koks  TSI  23.2.2026
*"----------------------------------------------------------------------
  DATA: rg_blart            TYPE RANGE OF blart,
        ls_blart            LIKE LINE OF rg_blart,
        ls_/thkr/ao_ref_bla TYPE /thkr/ao_ref_bla.

  SELECT * FROM /thkr/ao_ref_bla INTO ls_/thkr/ao_ref_bla
    WHERE ns        = i_ns
      AND ifname    = i_ifname
      AND ifversion = i_ifversion.

    ls_blart-sign   = 'I'.
    ls_blart-option = 'EQ'.
    ls_blart-low    = ls_/thkr/ao_ref_bla-blart.

    APPEND ls_blart TO rg_blart.
  ENDSELECT.
*"----------------------------------------------------------------------
  "Prüfen, ob sich zum Kassenzeichen die Finanzdaten im Speicher befinden.
  READ TABLE mt_finance_buffer ASSIGNING FIELD-SYMBOL(<ls_finance_buffer>) WITH KEY kassz = iv_kassz.

  IF sy-subrc = 0.
    MOVE-CORRESPONDING <ls_finance_buffer>-finance_data TO ms_ao_ref.
  ELSE.
* Suche der Referenz.
* 1.) BKTXT = ZUONR
* Wenn nicht gefunden
* 2.) XBLNR = ZUONR
* ZUONR wird über IV_KASSZ übergeben
* Die Attribute müssen in der Reihenfolge zu TY_S_FINANCE_DATA passen

* 1.) BKTXT = ZUONR
    SELECT k~belnr,
           k~bukrs,
           k~fikrs,
           s~fistl,
           s~fipos,
           s~gsber,
           s~hkont,
           s~kostl,
           s~mwskz,
           s~sgtxt,
           s~wrbtr,
           dk~kunnr,
           dk~lifnr,
           dk~augdt,
           dk~augbl,
* Gereon Koks  TSI  24.2.2026
           k~gjahr
     FROM bkpf AS k

     INNER JOIN bseg AS s
     ON  s~belnr = k~belnr
     AND s~bukrs = k~bukrs
     AND s~gjahr = k~gjahr
     AND s~koart = 'S'

     INNER JOIN bseg AS dk
     ON  dk~belnr = k~belnr
     AND dk~bukrs = k~bukrs
     AND dk~gjahr = k~gjahr
     AND ( dk~koart = 'K' OR dk~koart = 'D' )
* Gereon Koks  TSI  11.3.2026
*         WHERE k~xblnr = @iv_kassz
         WHERE k~bktxt = @iv_kassz
* Gereon Koks  TSI  23.2.2026
         AND   k~blart IN @rg_blart
* Gereon Koks  TSI  11.3.2026
*     ORDER BY k~cpudt ASCENDING, k~cputm ASCENDING
     ORDER BY k~belnr ASCENDING, k~cpudt ASCENDING, k~cputm ASCENDING
     INTO @ms_ao_ref.
* den letzten finden
*      UP TO 1 ROWS.

    ENDSELECT.

* 2.) XBLNR = ZUONR
    IF sy-subrc <> 0.
      SELECT k~belnr,
             k~bukrs,
             k~fikrs,
             s~fistl,
             s~fipos,
             s~gsber,
             s~hkont,
             s~kostl,
             s~mwskz,
             s~sgtxt,
             s~wrbtr,
             dk~kunnr,
             dk~lifnr,
             dk~augdt,
             dk~augbl,
* Gereon Koks  TSI  24.2.2026
             k~gjahr
       FROM bkpf AS k

       INNER JOIN bseg AS s
       ON  s~belnr = k~belnr
       AND s~bukrs = k~bukrs
       AND s~gjahr = k~gjahr
       AND s~koart = 'S'

       INNER JOIN bseg AS dk
       ON  dk~belnr = k~belnr
       AND dk~bukrs = k~bukrs
       AND dk~gjahr = k~gjahr
       AND ( dk~koart = 'K' OR dk~koart = 'D' )
* Gereon Koks  TSI  11.3.2026
           WHERE k~xblnr = @iv_kassz
* Gereon Koks  TSI  23.2.2026
           AND   k~blart IN @rg_blart
* Gereon Koks  TSI  11.3.2026
*     ORDER BY k~cpudt ASCENDING, k~cputm ASCENDING
       ORDER BY k~belnr ASCENDING, k~cpudt ASCENDING, k~cputm ASCENDING
       INTO @ms_ao_ref.
* den letzten finden
*      UP TO 1 ROWS.

      ENDSELECT.
    ENDIF.

    IF sy-subrc <> 0.
      APPEND VALUE bapiret2( id         = '/THKR/SST'
                             number     = 001
                             type       = 'E'
                             message_v1 = |Keine Anordnung zum Kassenzeichen |
                             message_v2 = iv_kassz
                             message_v3  = |gefunden.| ) TO ct_msgs.
    ENDIF.
*"----------------------------------------------------------------------
    IF sy-subrc = 0.
      UNASSIGN <ls_finance_buffer>.
      APPEND INITIAL LINE TO mt_finance_buffer ASSIGNING <ls_finance_buffer>.
      <ls_finance_buffer>-kassz = iv_kassz.
      MOVE-CORRESPONDING ms_ao_ref TO <ls_finance_buffer>-finance_data.
      "FIPOS <> FIPEX
      "In BSEG wird FIPOS gespeichert
      "Schnittstelle benötigt FIPEX
      "Muss daher nachgelesen werden.
      SELECT SINGLE fipex FROM fmfxpo
             WHERE fipos = @<ls_finance_buffer>-finance_data-fipex
             INTO @DATA(lv_fipex).

      IF sy-subrc = 0.
        ms_ao_ref-fipex = <ls_finance_buffer>-finance_data-fipex = lv_fipex.
      ENDIF.
* Gereon Koks  T-Systems  7.5.2025
* Nummer des Belegs auf den referenziert wird.
      iv_belnr = ms_ao_ref-belnr.
    ELSE.
      "Anordnung nicht auf der Datenbank.
      "Lese Anordung aus gemappter Datei.
      LOOP AT is_out_struct-werte-anordnungen ASSIGNING FIELD-SYMBOL(<ls_ao>).
        TRY.
            DATA(ls_mapped_ao_from_file) = <ls_ao>-ao[ xblnr = iv_kassz ].

            MOVE-CORRESPONDING ls_mapped_ao_from_file TO ms_ao_ref.
            MOVE-CORRESPONDING ls_mapped_ao_from_file-t_kont[ 1 ] TO ms_ao_ref.

            ms_ao_ref-saknr = ls_mapped_ao_from_file-t_kont[ 1 ]-hkont.
            ms_ao_ref-zz_mwskz = ls_mapped_ao_from_file-t_kont[ 1 ]-mwskz.
            "Datensatz in gemappter Datenlieferung gefunden.
            "Schleife kann verlassen werden.
            EXIT.
          CATCH cx_sy_itab_line_not_found.
            "Keine Anordnung in Datei gefunden.
            APPEND VALUE bapiret2( id         = '/THKR/SST'
                                   number     = 001
                                   type       = 'E'
                                   message_v1 = |Keine Anordnung zum Kassenzeichen |
                                   message_v2 = iv_kassz
                                   message_v3  = |gefunden.| ) TO ct_msgs.
        ENDTRY.
      ENDLOOP.
    ENDIF.
  ENDIF.
*"----------------------------------------------------------------------
ENDMETHOD.


  METHOD get_bpos.
    SELECT SINGLE blpos
  FROM  kblp
 WHERE belnr = @iv_belnr
  AND fistl = @iv_fistl
  AND fipex = @iv_fipex
 INTO @rv_blpos.
    IF sy-subrc <> 0.
      "Belegposition ist neu.
      "Letzte Position suchen und
      SELECT MAX( blpos )
      FROM kblp
     WHERE belnr = @iv_belnr
      INTO @rv_blpos.
      rv_blpos += 1.
      IF sy-subrc <> 0.
        rv_blpos = iv_bpos.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  method GET_BUKRS.

    SELECT single BUKRS
      FRom /thkr/centralmap
      WHERE ep = @iv_ep
        AND dst_old = @iv_dst_old
      into @rv_bukrs.
      if sy-subrc <> 0.
        clear rv_bukrs.
      endif.
  endmethod.


  METHOD get_bu_bpext_for_kblk.

    TRY.
        "Ermittlung Kreditor / Lieferant
        rv_bu_bpext = is_raw_struct-values-items[ key-belnr = is_raw_line-bsec-belnr key-gjahr = is_raw_line-bsec-gjahr ]-lt_kblp[ belnr = is_raw_line-bsec-belnr blpos = is_raw_line-bsec-buzei ]-lifnr.
        IF rv_bu_bpext IS INITIAL.
          "Keine Lieferanten ID vorhanden
          "Dann lese Debitor / Kundennummer
          rv_bu_bpext = is_raw_struct-values-items[ key-belnr = is_raw_line-bsec-belnr key-gjahr = is_raw_line-bsec-gjahr ]-lt_kblp[ belnr = is_raw_line-bsec-belnr blpos = is_raw_line-bsec-buzei ]-kunnr.
        ENDIF.
        DATA(lv_bp_is_cpd) =  me->check_bp_is_cpd(
                                EXPORTING
                                  iv_bpex   = rv_bu_bpext                 " Geschäftspartnernummer im externen System
*                             IMPORTING
*                               ev_is_cpd =                  " allgemeines flag
                              ).

        IF lv_bp_is_cpd = abap_true.
          ASSIGN COMPONENT 'BELNR' OF STRUCTURE is_raw_line-bsec TO FIELD-SYMBOL(<ls_belnr>).
          ASSIGN COMPONENT 'GJAHR' OF STRUCTURE is_raw_line-bsec  TO FIELD-SYMBOL(<ls_gjahr>).

         rv_bu_bpext = me->create_cpd_bpext_id(
                         iv_belnr = <ls_belnr>                 " Belegnummer eines Buchhaltungsbeleges
                         iv_gjahr = <ls_gjahr>                 " Geschäftsjahr
                       ).
        ENDIF.

      CATCH cx_sy_itab_line_not_found.
        CLEAR: rv_bu_bpext.
    ENDTRY.

  ENDMETHOD.


  METHOD GET_BU_BPEXT_WITHOUT_KEY.

    DATA: lv_BA_found TYPE flag.

    lv_BA_found = abap_false.
    "Geschäftspartner ohne BLART, BELNR, GJAHR oder LOTKZ
    "Es gibt keinen Bezug zwischen Geschäftspartner und Betragsloser Anordnung.
    LOOP AT is_raw_struct-values-items ASSIGNING FIELD-SYMBOL(<ls_items>) .

      "Positionen der Bargeldlosen Anordnung im Datensatz ermitteln
      LOOP AT  <ls_items>-lt_kblk ASSIGNING FIELD-SYMBOL(<ls_kblk>) WHERE blart = 'BA'.

        "Prüfen, ob Belegnummer bereits verwendet wurde
        READ TABLE mt_belnr_gp_ba WITH KEY table_line = <ls_kblk>-belnr TRANSPORTING NO FIELDS BINARY SEARCH.
        IF sy-subrc = 0.
          "Belegnummer bereits übernommen.
          "gehe zum nächsten Datensatz.
          lv_BA_found = abap_false.
          CONTINUE.
        ELSE.
          "Belegnummer ist noch nicht übernommen.
          READ TABLE is_raw_struct-values-items WITH KEY key-belnr = <ls_kblk>-belnr ASSIGNING <ls_items>.
          IF sy-subrc = 0.
            "Zeile in Datenlieferung Identifiziert
            TRY.

                rv_bu_bpext = <ls_items>-lt_kblp[ belnr = <ls_items>-key-belnr ]-lifnr.
                "Belegnummer speichern und Schleife Verlassen
              READ TABLE mt_belnr_gp_ba WITH KEY table_line = <ls_kblk>-belnr TRANSPORTING NO FIELDS BINARY SEARCH.
                INSERT <ls_kblk>-belnr INTO mt_belnr_gp_ba INDEX sy-tabix.
                lv_BA_found = abap_true.
              CATCH cx_sy_itab_line_not_found.
                CLEAR: rv_bu_bpext.
            ENDTRY.
          ENDIF.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_ba_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_field_form_buffer.
    CASE: iv_type.
      WHEN: 'AO'.
        READ TABLE mt_finance_buffer WITH KEY kassz = iv_kassz ASSIGNING FIELD-SYMBOL(<ls_ao>).
        IF sy-subrc = 0.
          ASSIGN COMPONENT iv_fieldname OF STRUCTURE <ls_ao> TO FIELD-SYMBOL(<ls_ao_field_value>).
          IF <ls_ao_field_value> IS ASSIGNED.
            rv_fieldvalue = <ls_ao_field_value>.
          ENDIF.
        ENDIF.
      WHEN: 'MB'.
      WHEN: OTHERS.
        CLEAR: rv_fieldvalue.
    ENDCASE.
  ENDMETHOD.


  method GET_FIPEX.
    DATA: lv_fipex TYPE string.
    CALL FUNCTION '/THKR/AIF_VMAP_FIPEX'
      EXPORTING
        value_in             = iv_kapitel
       VALUE_IN2            = iv_titel
       VALUE_IN3            = iv_uk
       VALUE_IN4            = iv_ep
*       VALUE_IN5            =
*       SENDING_SYSTEM       =
*       VALUE_FOUND          =
*     TABLES
*       RETURN_TAB           =
      changing
        value_out            = lv_fipex
*     EXCEPTIONS
*       NO_VALUE_FOUND       = 1
*       OTHERS               = 2
              .
    cv_fipex = lv_fipex.
  endmethod.


  method GET_FIPOS.

    SELECT single FIPOS
      FRom FMFXPO
      WHERE fipex = @iv_fipex
      INTO @rv_fipos.
     if sy-subrc <> 0.
       clear rv_fipos.
     endif.
  endmethod.


  METHOD get_hkont.
    IF me->check_bukrs( iv_burks = iv_bukrs ) = abap_true
    AND
      me->check_gjhr( iv_gjahr = iv_gjahr ) = abap_true.

      CALL FUNCTION 'FI_FM_ACCOUNT_DETERMINE'
        EXPORTING
          i_gjahr                 = iv_gjahr
          i_bukrs                 = iv_bukrs
*         I_ACIND                 = ' '
          i_fipex                 = iv_fipex
*         I_GEBER                 =
*         I_BUDGET_PD             =
          i_fistl                 = iv_fistl
*         I_FKBER                 =
          i_psoty                 = iv_psoty
*         I_POPUP                 =
*         I_SRTYPE                =
*         I_SAKNR                 = ' '
          i_blart                 = iv_blart
        IMPORTING
          e_saknr                 = rv_saknr
* TABLES
*         T_PAYAC01               =
        EXCEPTIONS
          account_not_found       = 1
          account_free_assignable = 2
          account_not_possible    = 3
          OTHERS                  = 4.
      IF sy-subrc <> 0.
        CLEAR: rv_saknr.
      ENDIF.
    ELSE.
      CLEAR: rv_saknr.
    ENDIF.

  ENDMETHOD.


  METHOD get_instance.
*
*    IF mo_instance IS INITIAL.
*      mo_instance = NEW #( ).
*
*      APPEND VALUE ty_s_instance( key = mo_instance->ms_aif_globales-ximsgguid
*                                  value = mo_instance ) TO mt_instances.
*    ENDIF.

    TRY.
        DATA: ls_run_info TYPE ty_s_run_info.
    CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
      IMPORTING
        ximsgguid      = ls_run_info-ximsgguid
        msgdate        = ls_run_info-msgdate
        msgtime        = ls_run_info-msgtime
        variant        = ls_run_info-variant
        trace_level    = ls_run_info-trace_level
        sending_system = ls_run_info-sending_system
        log_handle     = ls_run_info-log_handle
        testrun        = ls_run_info-testrun
        ns             = ls_run_info-ns
        ifname         = ls_run_info-ifname
        ifversion      = ls_run_info-ifversion
        finf           = ls_run_info-finf
        process_id     = ls_run_info-process_id.
        ro_instance = mt_instances[ key =  ls_run_info-ximsgguid ]-value.
      CATCH cx_sy_itab_line_not_found.
        mo_instance = NEW #( is_run_info = ls_run_info ).
        APPEND VALUE ty_s_instance( key =  ls_run_info-ximsgguid
                                    value = mo_instance ) TO mt_instances.
        ro_instance = mo_instance.
    ENDTRY.


  ENDMETHOD.


  METHOD get_mb_data.
    DATA: lv_fipex_mb TYPE fm_fipex.


      "Finanzstelle und Finanzposition für Mittelbildung ermitteln
      "Bei Mittelbindungen mit mehreren Kontierungen, muss die richtige Zeile rausgesucht werden.

      /thkr/cl_fi_central_mapping=>get_instance( )->read_central_mapping(
          iv_ep  = iv_fipex(2)                 " Einzelplan
          iv_oeh = CONV /thkr/mig_oeh_old( iv_fistl )                " OEH  alt
          iv_kapitel = CONV /thkr/mig_kapitel( iv_fipex+2(4) )
          iv_titel = CONV /thkr/mig_titel( iv_fipex+6(5) )
        ).

      "Finanzstelle
      DATA(lv_fistl_mb) = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-fistl.

      "Finanzposition
      me->get_fipex(
        EXPORTING
          iv_kapitel =  CONV string( iv_fipex+2(4) )                " Kapitel
          iv_titel   =  CONV string( iv_fipex+6(5) )               " Titel
          iv_ep      =  CONV string( iv_fipex(2) )                " Einzelplan
          iv_uk      =  CONV string( iv_fipex+11 )               " Unterkonto
        CHANGING
          cv_fipex   = lv_fipex_mb                 " Finanzposition
      ).

          "Prüfen, ob sich zum Kassenzeichen die Finanzdaten im Speicher befinden.
    IF iv_blpos IS SUPPLIED.
      "Mittelbindung.
      READ TABLE mt_mb_buffer ASSIGNING FIELD-SYMBOL(<ls_mb_buffer>) WITH KEY kblnr = iv_kblnr
                                                                              finance_data-blpos = iv_blpos
                                                                               finance_data-fipex = lv_fipex_mb
                                                                               finance_data-fistl = lv_fistl_mb.
    ELSE.
      "Keine Belegposition aus Mittelbindung
      "Auszahlungsanordnung mit Referenz auf Mittelbindung.
      "Daher Belegpostion unbekannt und nur über Finanzstelle und Finanzposition möglich.
      READ TABLE mt_mb_buffer ASSIGNING <ls_mb_buffer> WITH KEY kblnr = iv_kblnr
                                                                              finance_data-fipex = lv_fipex_mb
                                                                              finance_data-fistl = lv_fistl_mb.
    ENDIF.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING <ls_mb_buffer>-finance_data TO ms_mb_data.
    ELSE.

      SELECT k~belnr, p~blpos, k~bukrs, k~fikrs, p~fistl, p~fipex, p~gsber, p~saknr, p~kostl, p~zz_mwskz, p~wtges, p~wtorig
        FROM kblk AS k
        INNER JOIN kblp AS p
        ON p~belnr = k~belnr
        WHERE k~ktext = @iv_kblnr
         AND p~fistl = @lv_fistl_mb
         AND p~fipex = @lv_fipex_mb
        INTO TABLE @DATA(lt_mb_data).
      IF sy-subrc = 0.
        UNASSIGN <ls_mb_buffer>.
        LOOP AT lt_mb_data ASSIGNING FIELD-SYMBOL(<ls_mb_data>).
          IF iv_blpos is SUPPLIED
          and <ls_mb_data>-fipex = lv_fipex_mb
          and <ls_mb_data>-fistl = lv_fistl_mb.
            "Fülle Mittelbindung aus Mittelbindung.
            MOVE-CORRESPONDING <ls_mb_data> TO ms_mb_data.
          ENDIF.

          if iv_blpos is not SUPPLIED
          and <ls_mb_data>-fipex = lv_fipex_mb
          and <ls_mb_data>-fistl = lv_fistl_mb.
            "Fülle Mittelbindung aus AO.
            MOVE-CORRESPONDING <ls_mb_data> TO ms_mb_data.
          endif.

          APPEND INITIAL LINE TO mt_mb_buffer ASSIGNING <ls_mb_buffer>.
          <ls_mb_buffer>-kblnr = iv_kblnr.
          MOVE-CORRESPONDING <ls_mb_data> TO <ls_mb_buffer>-finance_data.
        ENDLOOP.
        ev_mb_in_file = abap_false.
      ELSE.
        IF is_kblk IS INITIAL.
          "Mittelbindung ist auch nicht in der Datei
          APPEND VALUE bapiret2( id         = '/THKR/SST'
                   number     = 001
                   type       = 'E'
                   message_v1 = |Keine Mittelbindung für |
                   message_v2 = iv_kblnr
                   message_v3  = |gefunden.| ) TO ct_msgs.
        ELSE.
          "Mittelbindung befindet sich in der Datei
          ev_mb_in_file = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_mwskz.

    IF iv_saknr IS INITIAL.
      "Kein Sachkonto mitgegeben
      "Nutze AIF Lösung
      rv_mwskz = get_mwskz_via_aif(
                   iv_blart = iv_blart                  " Belegart
                   iv_btyp  = iv_btyp
                   iv_bkz   = iv_bkz
                 ).
    ELSE.
      "Mehrwertsteuerkennzeichen ist vom Sachkonto abhängig, nicht von der Belegart.
      "Daher zuerst Sachkonto prüfen.
      "Da das Steuerkennzeichen Pflicht ist, muss ein Standardwert zurückgemeldet werden.
      SELECT SINGLE mwskz
        FROM skb1
       WHERE bukrs = @iv_bukrs
         AND saknr = @iv_saknr
        INTO @rv_mwskz.
      IF sy-subrc = 0.
        "Vergleiche Funktionsbaustein FI_TAX_INDICATOR_CHECK.
        "Daher die Ableitung.
        IF rv_mwskz IS INITIAL.
          "Konto erlaubt keine Umsatzsteuer
          CLEAR: rv_mwskz.
        ELSE.
          CASE: rv_mwskz(1).
            WHEN:'-' OR '<'.
              rv_mwskz = 'V0'.
            WHEN:'+' OR '>'.
              rv_mwskz = 'A0'.
            WHEN:'*'.
              rv_mwskz = get_mwskz_via_aif(
               iv_blart = iv_blart                  " Belegart
               iv_btyp  = iv_btyp
               iv_bkz   = iv_bkz
             ).
            WHEN: ' '.
              "Konto erlaubt keine Umsatzsteuer
              CLEAR: rv_mwskz.
            WHEN:OTHERS.
              "nicht. Nimm Wert aus Datenbank SKB1.
          ENDCASE.
        ENDIF.
      ELSE.
        "Kein Ergebnis für Buchungskreis und Sachkonto
        "Nutze AIF Lösung
        rv_mwskz = get_mwskz_via_aif(
             iv_blart = iv_blart                  " Belegart
             iv_btyp  = iv_btyp
             iv_bkz   = iv_bkz
           ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  method GET_MWSKZ_VIA_AIF.
    CALL FUNCTION '/THKR/AIF_VMAP_MWSKZ_NEU'
      EXPORTING
        value_in            = iv_btyp                 "Buchungstyp (BIC - 01_BTYP)
       VALUE_IN2            = CONV string( iv_blart ) "Belegart
       VALUE_IN3            =  iv_bkz                 "Be- / Entlastungskennzeichen (BIC - 021_BZG)
*       VALUE_IN4            =
*       VALUE_IN5            =
*       SENDING_SYSTEM       =
*       VALUE_FOUND          =
*     TABLES
*       RETURN_TAB           =
      changing
        value_out            = rv_mwskz
*     EXCEPTIONS
*       NO_VALUE_FOUND       = 1
*       OTHERS               = 2
              .
  endmethod.


  METHOD GET_PARTNER.

    "1. Stufe: Ermittlung anhand Belegart
    ev_bpext = COND bu_bpext( WHEN iv_blart = 'AE' THEN iv_kunnr
                                    WHEN iv_blart = 'BA' THEN iv_lifnr
                                    ELSE '' ).

    "2. Stufe: Wenn nicht erkannt durch Belegart, dann Auswertung über gesendete Information
    IF ev_bpext = ''.
      IF iv_kunnr IS INITIAL AND iv_lifnr IS NOT INITIAL.
        ev_bpext = iv_lifnr.
      ENDIF.
      IF iv_kunnr IS NOT INITIAL AND iv_lifnr IS INITIAL.
        ev_bpext = iv_kunnr.
      ENDIF.
    ENDIF.

    "3. Prüfung auf CPD.
    DATA(lv_is_cpd) = me->check_bp_is_cpd(
                        EXPORTING
                          iv_bpex   = ev_bpext                 " Geschäftspartnernummer im externen System
*                        IMPORTING
*                          ev_is_cpd =                  " allgemeines flag
                      ).
    if lv_is_cpd = abap_true.

          ev_bpext = me->create_cpd_bpext_id(
                       iv_belnr = iv_belnr                 " Belegnummer eines Buchhaltungsbeleges
                       iv_gjahr = iv_gjahr                 " Geschäftsjahr
                     ).
    endif.

    SELECT SINGLE partner
      FROM but000
     WHERE /thkr/sst = @iv_sst
       AND bpext = @ev_bpext
      INTO @rv_partner.
    IF sy-subrc <> 0.
      CLEAR:rv_partner.
    ENDIF.
  ENDMETHOD.


  METHOD get_processing_status.
    "Loop über interne Tabelle anstatt Read Table, weil es passieren kann,
    "dass zu einer globalen Kennung (GLBLID) mehere Datensätze erzeugt werden
    "zum Beispiel bei Auszahlungen mit Referenz auf Einnahmesollstellungen (Allerdings existiert nur die Auszahlung in der BIC-Datei)
    "1. Datensatz = Annahmeanordnung
    "2. Datensatz = Auszahlungsanordnung

    CLEAR: rv_status.
*********************************************************************
*                         Lese Anordnungen                          *
*********************************************************************
    LOOP AT is_data-ao ASSIGNING FIELD-SYMBOL(<ls_ao>) WHERE glblid = iv_glblid.
      MOVE-CORRESPONDING <ls_ao> TO es_meta.
      "Meldungen für Geschäftspartner ermitteln
      TRY.
          et_bp_msgs = is_data-gp[ bu_bpext = <ls_ao>-ao_bpext /thkr/sst = <ls_ao>-ao_sst ]-msg.
        CATCH cx_sy_itab_line_not_found.
          CLEAR et_bp_msgs.
      ENDTRY.
      IF <ls_ao>-ao_proc_status = 'E' OR
         <ls_ao>-ao_proc_status = 'A' OR
         <ls_ao>-ao_proc_status IS INITIAL.
        rv_status = <ls_ao>-ao_proc_status.
        et_msgs = is_data-ao[ glblid = iv_glblid ]-msg.
        EXIT.
      ELSE.
        rv_status = <ls_ao>-ao_proc_status.
        CONTINUE.
      ENDIF.
    ENDLOOP.
    IF rv_status IS INITIAL.
*********************************************************************
*              Keine AO - Lese Anordnung Referenz                   *
*********************************************************************
      LOOP AT is_data-ao_reference ASSIGNING <ls_ao> WHERE glblid = iv_glblid.
        MOVE-CORRESPONDING <ls_ao> TO es_meta.
        "Meldungen für Geschäftspartner ermitteln
        TRY.
            et_bp_msgs = is_data-gp[ bu_bpext = <ls_ao>-ao_bpext /thkr/sst = <ls_ao>-ao_sst ]-msg.
          CATCH cx_sy_itab_line_not_found.
            CLEAR et_bp_msgs.
        ENDTRY.
        IF <ls_ao>-ao_proc_status = 'E' OR
           <ls_ao>-ao_proc_status = 'A' OR
           <ls_ao>-ao_proc_status IS INITIAL.
          rv_status = <ls_ao>-ao_proc_status.
          et_msgs = is_data-ao_reference[ glblid = iv_glblid ]-msg.
          EXIT.
        ELSE.
          rv_status = <ls_ao>-ao_proc_status.
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF rv_status IS INITIAL.
*********************************************************************
*                keine AO Referenz - Lese Stundung             *
*********************************************************************
      LOOP AT is_data-ao_stu ASSIGNING <ls_ao> WHERE glblid = iv_glblid.
        MOVE-CORRESPONDING <ls_ao> TO es_meta.
        "Meldungen für Geschäftspartner ermitteln
        TRY.
            et_bp_msgs = is_data-gp[ bu_bpext = <ls_ao>-ao_bpext /thkr/sst = <ls_ao>-ao_sst ]-msg.
          CATCH cx_sy_itab_line_not_found.
            CLEAR et_bp_msgs.
        ENDTRY.
        IF <ls_ao>-ao_proc_status = 'E' OR
           <ls_ao>-ao_proc_status = 'A' OR
           <ls_ao>-ao_proc_status IS INITIAL.
          rv_status = <ls_ao>-ao_proc_status.
          et_msgs = is_data-ao_stu[ glblid = iv_glblid ]-msg.
          EXIT.
        ELSE.
          rv_status = <ls_ao>-ao_proc_status.
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF rv_status IS INITIAL.
*********************************************************************
*                keine AO Referenz - Lese Mittelbindung             *
*********************************************************************
      LOOP AT is_data-mb ASSIGNING FIELD-SYMBOL(<ls_mb>) WHERE glblid = iv_glblid.
        MOVE-CORRESPONDING <ls_mb> TO es_meta.
        "Meldungen für Geschäftspartner ermitteln
        TRY.
            et_bp_msgs = is_data-gp[ bu_bpext = <ls_mb>-mv_bpext /thkr/sst = <ls_mb>-mv_sst ]-msg.
          CATCH cx_sy_itab_line_not_found.
            CLEAR et_bp_msgs.
        ENDTRY.
        IF <ls_mb>-mv_proc_status = 'E' OR
           <ls_mb>-mv_proc_status = 'A' OR
           <ls_mb>-mv_proc_status IS INITIAL.
          rv_status = <ls_mb>-mv_proc_status.
          et_msgs = is_data-mb[ glblid = iv_glblid ]-msg.
          EXIT.
        ELSE.
          rv_status = <ls_mb>-mv_proc_status.
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF rv_status IS INITIAL.
*********************************************************************
*               Keine MB - Lese MB Änderung                         *
*********************************************************************
      LOOP AT is_data-mb_up ASSIGNING FIELD-SYMBOL(<ls_mb_up>) WHERE glblid = iv_glblid.
        MOVE-CORRESPONDING <ls_mb_up> TO es_meta.
        IF <ls_mb_up>-mv_up_proc_status = 'E' OR
           <ls_mb_up>-mv_up_proc_status = 'A' OR
           <ls_mb_up>-mv_up_proc_status IS INITIAL.
          rv_status = <ls_mb_up>-mv_up_proc_status.
          et_msgs = is_data-mb_up[ glblid = iv_glblid ]-msg.
          EXIT.
        ELSE.
          rv_status = <ls_mb_up>-mv_up_proc_status.
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF rv_status IS INITIAL.
*********************************************************************
*             Keine MB Änderung - Lese Verrechnungsanordnung        *
*********************************************************************
      LOOP AT is_data-vr ASSIGNING FIELD-SYMBOL(<ls_vr>) WHERE glblid = iv_glblid.
        MOVE-CORRESPONDING <ls_vr> TO es_meta.
        "Meldungen für Geschäftspartner ermitteln
        TRY.
            et_bp_msgs = is_data-gp[ bu_bpext = <ls_vr>-vr_bpext /thkr/sst = <ls_vr>-vr_sst ]-msg.
          CATCH cx_sy_itab_line_not_found.
            CLEAR et_bp_msgs.
        ENDTRY.
        IF <ls_vr>-vr_proc_status = 'E' OR
           <ls_vr>-vr_proc_status = 'A' OR
           <ls_vr>-vr_proc_status IS INITIAL.
          rv_status = <ls_vr>-vr_proc_status.
          et_msgs = is_data-vr[ glblid = iv_glblid ]-msg.
          EXIT.
        ELSE.
          rv_status = <ls_vr>-vr_proc_status.
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF rv_status IS INITIAL.
*********************************************************************
*            Keine VR - Lese Storno                                 *
*********************************************************************
      LOOP AT is_data-storno ASSIGNING FIELD-SYMBOL(<ls_storno>) WHERE glblid = iv_glblid.
        MOVE-CORRESPONDING <ls_storno> TO es_meta.
        IF <ls_storno>-proc_status = 'E' OR
           <ls_storno>-proc_status = 'A' OR
           <ls_storno>-proc_status IS INITIAL.
          rv_status = <ls_storno>-proc_status.
          et_msgs = is_data-storno[ glblid = iv_glblid ]-msg.
          EXIT.
        ELSE.
          rv_status = <ls_storno>-proc_status.
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF iv_msgty IS NOT INITIAL.
      rv_status = iv_msgty.
    ENDIF.
  ENDMETHOD.


  METHOD get_sap_bp_after_action.
    IF cs_ao-partner IS INITIAL.
      TRY.
          cs_ao-partner = it_gp[ bu_bpext = cs_ao-ao_bpext src_belnr = cs_ao-glblid+14 ]-partner.
        CATCH cx_sy_itab_line_not_found.
          IF 1 = 0. MESSAGE e346(/cpd/ss_messages) WITH cs_ao-ao_bpext.ENDIF.
          APPEND VALUE #( id         = '/CPD/SS_MESSAGES'
                          number     = 346
                          type       = 'E'
                          message_v1 = cs_ao-ao_bpext ) TO ct_return.
          cs_ao-ao_proc_status = 'E'.
          cs_ao-msg = ct_return.
          cv_process_ao = abap_false.
      ENDTRY.
    ENDIF.
    TRY.
        IF it_gp[ bu_bpext = cs_ao-ao_bpext ]-bp_proc_status = 'E'.
          "Fehler beim Anlegen des Geschäftspartners. Keine Verarbeitung der Anordnung
          IF 1 = 0. MESSAGE e032(/thkr/sst) WITH 'Geschäftspartner' 'Anordnung'. ENDIF.
          APPEND VALUE #( id         = '/THKR/SST'
                           number     = 032
                           type       = 'E'
                           message_v1 = 'Geschäftspartner'
                           message_v2 = 'Anordnung' ) TO ct_return.
          cv_process_ao = abap_false.
        ENDIF.
      CATCH cx_sy_itab_line_not_found.
        IF 1 = 0. MESSAGE e346(/cpd/ss_messages) WITH cs_ao-ao_bpext.ENDIF.
        APPEND VALUE #( id         = '/CPD/SS_MESSAGES'
                        number     = 346
                        type       = 'E'
                        message_v1 = cs_ao-ao_bpext ) TO ct_return.
        cs_ao-ao_proc_status = 'E'.
        cs_ao-msg = ct_return.
        cv_process_ao = abap_false.
    ENDTRY.
  ENDMETHOD.


  METHOD get_sap_bp_after_act_mb.
    LOOP AT cs_mv-t_kont ASSIGNING FIELD-SYMBOL(<ls_t_kont>).
      IF <ls_t_kont>-partner IS INITIAL.
        TRY.
            <ls_t_kont>-partner = it_gp[ bu_bpext = <ls_t_kont>-mv_bpext ]-partner.
          CATCH cx_sy_itab_line_not_found.
            IF 1 = 0. MESSAGE e346(/cpd/ss_messages) WITH <ls_t_kont>-mv_bpext.ENDIF.
            APPEND VALUE #( id         = '/CPD/SS_MESSAGES'
                            number     = 346
                            type       = 'E'
                            message_v1 = <ls_t_kont>-mv_bpext ) TO ct_return.
            cs_mv-mv_proc_status = 'E'.
            cs_mv-msg = ct_return.
            cv_process_mv = abap_false.
        ENDTRY.
      ENDIF.
      TRY.
          IF it_gp[ bu_bpext = <ls_t_kont>-mv_bpext  ]-bp_proc_status = 'E'.
            "Fehler beim Anlegen des Geschäftspartners. Keine Verarbeitung der Anordnung
            IF 1 = 0. MESSAGE e032(/thkr/sst) WITH 'Geschäftspartner' 'Anordnung'. ENDIF.
            APPEND VALUE #( id         = '/THKR/SST'
                             number     = 032
                             type       = 'E'
                             message_v1 = 'Geschäftspartner'
                             message_v2 = 'Anordnung' ) TO ct_return.
            cv_process_mv = abap_false.
          ENDIF.
        CATCH cx_sy_itab_line_not_found.
          IF 1 = 0. MESSAGE e346(/cpd/ss_messages) WITH <ls_t_kont>-mv_bpext.ENDIF.
          APPEND VALUE #( id         = '/CPD/SS_MESSAGES'
                          number     = 346
                          type       = 'E'
                          message_v1 = <ls_t_kont>-mv_bpext ) TO ct_return.
          cs_mv-mv_proc_status = 'E'.
          cs_mv-msg = ct_return.
          cv_process_mv = abap_false.
      ENDTRY.
    ENDLOOP.
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


  METHOD get_waers.
CALL FUNCTION '/THKR/AIF_VMAP_WAERS'
  EXPORTING
    value_in             = conv string( iv_waers )
    VALUE_IN2            = conv string( iv_bukrs )
*   VALUE_IN3            =
*   VALUE_IN4            =
*   VALUE_IN5            =
*   SENDING_SYSTEM       =
*   VALUE_FOUND          =
* TABLES
*   RETURN_TAB           =
  changing
    value_out            = rv_waers
* EXCEPTIONS
*   NO_VALUE_FOUND       = 1
*   OTHERS               = 2
          .

  ENDMETHOD.


  METHOD map_blart_for_mb.
    CONSTANTS: lc_ns TYPE /aif/ns VALUE 'ZALLGE'.
    CONSTANTS: lc_vname TYPE /aif/vmapname VALUE 'MAP_PSO_XML_BLART'.


    SELECT SINGLE int_value
      FROM /aif/t_vmapval5
     WHERE ns = @lc_ns
      AND vmapname = @lc_vname
      AND ext_value1 = @iv_blart
      AND ext_value2 = @iv_psoty
      AND ext_value3 = @iv_banks
      INTO @rv_blart.
    IF sy-subrc <> 0.
      "Es konnte kein Bankland ermittelt werden.
      "Mit Asterisk probieren (Auslandzahlung)
      CLEAR: rv_blart.
      SELECT SINGLE int_value
      FROM /aif/t_vmapval5
      WHERE ns = @lc_ns
      AND vmapname = @lc_vname
      AND ext_value1 = @iv_blart
      AND ext_value2 = @iv_psoty
      AND ext_value3 = '*'
      INTO @rv_blart.
      IF sy-subrc <> 0.
        CLEAR: rv_blart.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  method MAP_BU_TYPE.

    SELECT single INT_VALUE
      FROM /AIF/T_VMAPVAL
      WHERE ns = 'ZALLGE'
      AND   vmapname = 'MAP_PSO_XML_BU_TYPE'
      and ext_value = @iv_stkzn
     into @rv_bu_type.
      if sy-subrc <> 0.
        clear: rv_bu_type.
      endif.
  endmethod.


  METHOD map_dest_line_ao_with_db.
***************************************************************************
*                   BUKRS - Buchungskreis                                 *
***************************************************************************
    cs_dest_line-bukrs = ms_mb_data-bukrs.
    "Aufbau Sachkonto-Zeile in AO-Struktur.
    APPEND INITIAL LINE TO cs_dest_line-t_kont ASSIGNING FIELD-SYMBOL(<ls_t_cont>).
***************************************************************************
*                   FIKRS - Finanzkreis                                   *
***************************************************************************
    <ls_t_cont>-fikrs = ms_mb_data-fikrs.
***************************************************************************
*                   FIPEX - Finanzposition                                *
***************************************************************************
    <ls_t_cont>-fipex = ms_mb_data-fipex.

***************************************************************************
*                   FISTL - Finanzstelle                                  *
***************************************************************************
    <ls_t_cont>-fistl = ms_mb_data-fistl.
***************************************************************************
*                   HKONT - Sachkonto                                     *
***************************************************************************
    <ls_t_cont>-hkont = ms_mb_data-saknr.
***************************************************************************
*                   MSKZ - Mehrwehrtsteuerkennzeichen                     *
***************************************************************************
    <ls_t_cont>-mwskz = /thkr/cl_pso_xml_processing=>get_instance( )->get_mwskz(
                                                                    iv_blart = cs_dest_line-blart                  " Belegart
                                                                    iv_bukrs = cs_dest_line-bukrs                 " Buchungskreis
                                                                    iv_saknr = <ls_t_cont>-hkont                 " Nummer des Sachkontos
                                                                    iv_btyp = ''
                                                                    iv_bkz = ''
                                                                  ).
***************************************************************************
*                   KBLNR - Belegnummer der Mittelbindung                 *
***************************************************************************
    <ls_t_cont>-kblnr = ms_mb_data-belnr.
***************************************************************************
*                   KBLPOS - Belegposition der Mittelbindung              *
***************************************************************************
    <ls_t_cont>-kblpos = ms_mb_data-blpos.
***************************************************************************
*                   KOSTL - Kostenstelle                                  *
***************************************************************************
    <ls_t_cont>-kostl = ms_mb_data-kostl.
***************************************************************************
*                   GSBER - Geschäftsbereich                              *
***************************************************************************
    <ls_t_cont>-gsber = ms_mb_data-gsber.

  ENDMETHOD.


  METHOD map_dest_line_ao_with_file.

    LOOP AT it_kblp ASSIGNING FIELD-SYMBOL(<ls_kblp>) WHERE belnr = iv_kblnr.

***************************************************************************
*                   EP - Einzelplan                                       *
***************************************************************************
      cs_dest_line-ep = <ls_kblp>-fipos(2).
***************************************************************************
*                   DST_OLD - Dienststelle                                *
***************************************************************************
      cs_dest_line-dst_old = <ls_kblp>-fistl(4).
***************************************************************************
*                   BUKRS - Buchungskreis                                 *
***************************************************************************

      /thkr/cl_fi_central_mapping=>get_instance( )->read_central_mapping(
        iv_ep  = cs_dest_line-ep                 " Einzelplan
        iv_oeh = CONV /thkr/mig_oeh_old( <ls_kblp>-fistl )                " OEH  alt
        iv_kapitel = conv /thkr/mig_kapitel( <ls_kblp>-fipex+2(4) )
        iv_titel = conv /thkr/mig_titel( <ls_kblp>-fipex+6(5) )
      ).


      cs_dest_line-bukrs = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-bukrs.
***************************************************************************
*                   WAERS - Währungsschlüssel                             *
***************************************************************************
      cs_dest_line-waers = /thkr/cl_pso_xml_processing=>get_instance( )->get_waers(
                                                                     iv_waers = is_kblk-waers                 " Währungsschlüssel
                                                                     iv_bukrs = cs_dest_line-bukrs                 " Buchungskreis
                                                                   ) .
***************************************************************************
*                   FIKRS - Finanzkreis                                   *
***************************************************************************

      APPEND INITIAL LINE TO cs_dest_line-t_kont ASSIGNING FIELD-SYMBOL(<ls_t_cont>).
      <ls_t_cont>-fikrs = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-fikrs.
***************************************************************************
*                   FIPEX - Finanzposition                                *
***************************************************************************
              "<ls_t_cont>-fipex = <ls_kblp>-fipos+2(9).
        <ls_t_cont>-fipex = <ls_kblp>-fipos+2.
***************************************************************************
*                   FISTL - Finanzstelle                                  *
***************************************************************************
      <ls_t_cont>-fistl = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-fistl.
***************************************************************************
*                   HKONT - Sachkonto                                     *
***************************************************************************
      <ls_t_cont>-hkont = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-saknr.
      IF <ls_t_cont>-hkont IS INITIAL.
        "Ableitung Sachkonto für HHM-Kontierung
        <ls_t_cont>-hkont = /thkr/cl_pso_xml_processing=>get_instance( )->get_hkont(
                                                                         iv_gjahr = cs_dest_line-budat(4)                 " Geschäftsjahr
                                                                         iv_bukrs = cs_dest_line-bukrs                 " Buchungskreis
                                                                         iv_fipex = <ls_t_cont>-fipex                 " Finanzposition
                                                                         iv_fistl = <ls_t_cont>-fistl                 " Finanzstelle
                                                                         iv_psoty = cs_dest_line-blart                 " Belegtyp Zahlungsanordnungen
                                                                         iv_blart = cs_dest_line-blart                 " Belegart
                                                                       ).
      ENDIF.
***************************************************************************
*                   MSKZ - Mehrwehrtsteuerkennzeichen                     *
***************************************************************************
      <ls_t_cont>-mwskz = /thkr/cl_pso_xml_processing=>get_instance( )->get_mwskz(
                                                                          iv_blart = cs_dest_line-blart                  " Belegart
                                                                          iv_bukrs = cs_dest_line-bukrs                 " Buchungskreis
                                                                          iv_saknr = <ls_t_cont>-hkont                 " Nummer des Sachkontos
                                                                          iv_btyp = ''
                                                                          iv_bkz = ''
                                                                        ).
***************************************************************************
*                   GSBER - Geschäftsbereich                              *
***************************************************************************
      <ls_t_cont>-gsber = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-gsber.
***************************************************************************
*                   AUFNR - Innenauftrag                                  *
***************************************************************************
*      <ls_t_cont>-aufnr = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-aufnr.
***************************************************************************
*                   KOSTL - Kostenstelle                                  *
***************************************************************************
      <ls_t_cont>-kostl = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-kostl.
***************************************************************************
*                   KBLNR - Belegnummer der Mittelbindung                 *
***************************************************************************
      <ls_t_cont>-kblnr = iv_kblnr.
***************************************************************************
*                   KBLPPOS - Belegposition der Mittelbindung             *
***************************************************************************
      <ls_t_cont>-kblpos = iv_kblpos.
    ENDLOOP.
  ENDMETHOD.


  METHOD MAP_DEST_LINE_VR_RECEIVER.

***************************************************************************
*                   FIKRS - Finanzkreis                                   *
***************************************************************************
        /thkr/cl_fi_central_mapping=>get_instance( )->read_central_mapping(
      iv_ep  = is_pso02s-fipex(2)                 " Einzelplan
      iv_oeh = CONV /thkr/mig_oeh_old( is_pso02s-fistl )                " OEH  alt
      iv_kapitel = CONV /thkr/mig_kapitel( is_pso02s-fipex+2(4) )
      iv_titel = CONV /thkr/mig_titel( is_pso02s-fipex+6(5) )
    ).
    cs_dest_line-fikrs = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-fikrs.
***************************************************************************
*                   FIPEX - Finanzposition                                *
***************************************************************************
    "cs_dest_line-fipex = is_pso02s-fipex+2(9).
        /thkr/cl_pso_xml_processing=>get_instance( )->get_fipex(
EXPORTING
iv_kapitel = CONV string( is_pso02s-fipex+2(4) )                " Kapitel
iv_titel   = CONV string( is_pso02s-fipex+6(5) )                " Titel
iv_ep      = CONV string( is_pso02s-fipex(2) )                  " Einzelplan
iv_uk      = CONV string( is_pso02s-fipex+11 )                  " Unterkonto
CHANGING
cv_fipex   = cs_dest_line-fipex
).
***************************************************************************
*                   FISTL - Finanzstelle                                  *
***************************************************************************
    cs_dest_line-fistl = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-fistl.
***************************************************************************
*                   HKONT - Sachkonto                                     *
***************************************************************************
    cs_dest_line-hkont = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-saknr.
    IF cs_dest_line-hkont IS INITIAL.
      "Ableitung Sachkonto für HHM-Kontierung
      DATA(lv_burks) = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-bukrs.
      cs_dest_line-hkont = /thkr/cl_pso_xml_processing=>get_instance( )->get_hkont(
                                                                       iv_gjahr = is_pso02s-gjahr                " Geschäftsjahr
                                                                       iv_bukrs = lv_burks                 " Buchungskreis
                                                                       iv_fipex = cs_dest_line-fipex                 " Finanzposition
                                                                       iv_fistl = cs_dest_line-fistl                 " Finanzstelle
                                                                       iv_psoty = iv_psoty                 " Belegtyp Zahlungsanordnungen
                                                                       iv_blart = iv_blart                 " Belegart
                                                                     ).
    ENDIF.
***************************************************************************
*                   MSKZ - Mehrwehrtsteuerkennzeichen                     *
***************************************************************************
    cs_dest_line-mwskz = /thkr/cl_pso_xml_processing=>get_instance( )->get_mwskz(
                                                                        iv_blart = iv_blart                  " Belegart
                                                                        iv_bukrs = lv_burks                 " Buchungskreis
                                                                        iv_saknr = cs_dest_line-hkont                 " Nummer des Sachkontos
                                                                        iv_btyp = ''
                                                                        iv_bkz = ''
                                                                      ).
***************************************************************************
*                   GSBER - Geschäftsbereich                              *
***************************************************************************
    cs_dest_line-gsber = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-gsber.
***************************************************************************
*                   AUFNR - Innenauftrag                                  *
***************************************************************************
    cs_dest_line-aufnr = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-aufnr.
***************************************************************************
*                   KOSTL - Kostenstelle                                  *
***************************************************************************
    cs_dest_line-kostl = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-kostl.
***************************************************************************
*                   SGTXT - Positionstext                                 *
***************************************************************************
    cs_dest_line-sgtxt = |*{ is_pso02s-sgtxt }|.
***************************************************************************
*                   WRBTR - Betrag in Belegwährung                        *
***************************************************************************
    cs_dest_line-wrbtr = is_pso02s-wrbtr.
ENDMETHOD.


  METHOD map_dest_line_vr_sender.

***************************************************************************
*                   EP - Einzelplan                                       *
***************************************************************************
    cs_dest_line-ep = is_pso02s-fipex(2).
***************************************************************************
*                   DST_OLD - Dienststelle                                *
***************************************************************************
    cs_dest_line-dst_old = is_pso02s-fistl(4).
***************************************************************************
*                   BUKRS - Buchungskreis                                 *
***************************************************************************

    /thkr/cl_fi_central_mapping=>get_instance( )->read_central_mapping(
      iv_ep  = cs_dest_line-ep                 " Einzelplan
      iv_oeh = CONV /thkr/mig_oeh_old( is_pso02s-fistl )                " OEH  alt
      iv_kapitel = CONV /thkr/mig_kapitel( is_pso02s-fipex+2(4) )
      iv_titel = CONV /thkr/mig_titel( is_pso02s-fipex+6(5) )
    ).


    cs_dest_line-bukrs = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-bukrs.
***************************************************************************
*                   WAERS - Währungsschlüssel                             *
***************************************************************************
    cs_dest_line-waers = /thkr/cl_pso_xml_processing=>get_instance( )->get_waers(
                                                                   iv_waers = cs_dest_line-waers                 " Währungsschlüssel
                                                                   iv_bukrs = cs_dest_line-bukrs                 " Buchungskreis
                                                                 ) .
***************************************************************************
*                   FIKRS - Finanzkreis                                   *
***************************************************************************
    cs_dest_line-fikrs = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-fikrs.
***************************************************************************
*                   FIPEX - Finanzposition                                *
***************************************************************************
    "cs_dest_line-fipex = is_pso02s-fipex+2(9).
    /thkr/cl_pso_xml_processing=>get_instance( )->get_fipex(
EXPORTING
iv_kapitel = CONV string( is_pso02s-fipex+2(4) )                " Kapitel
iv_titel   = CONV string( is_pso02s-fipex+6(5) )                " Titel
iv_ep      = CONV string( is_pso02s-fipex(2) )                  " Einzelplan
iv_uk      = CONV string( is_pso02s-fipex+11 )                  " Unterkonto
CHANGING
cv_fipex   = cs_dest_line-fipex
).
***************************************************************************
*                   FISTL - Finanzstelle                                  *
***************************************************************************
    cs_dest_line-fistl = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-fistl.
***************************************************************************
*                   HKONT - Sachkonto                                     *
***************************************************************************
    cs_dest_line-hkont = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-saknr.
    IF cs_dest_line-hkont IS INITIAL.
      "Ableitung Sachkonto für HHM-Kontierung
      cs_dest_line-hkont = /thkr/cl_pso_xml_processing=>get_instance( )->get_hkont(
                                                                       iv_gjahr = cs_dest_line-gjahr                 " Geschäftsjahr
                                                                       iv_bukrs = cs_dest_line-bukrs                 " Buchungskreis
                                                                       iv_fipex = cs_dest_line-fipex                 " Finanzposition
                                                                       iv_fistl = cs_dest_line-fistl                 " Finanzstelle
                                                                       iv_psoty = cs_dest_line-blart                 " Belegtyp Zahlungsanordnungen
                                                                       iv_blart = cs_dest_line-blart                 " Belegart
                                                                     ).
    ENDIF.
***************************************************************************
*                   MSKZ - Mehrwehrtsteuerkennzeichen                     *
***************************************************************************
    cs_dest_line-mwskz = /thkr/cl_pso_xml_processing=>get_instance( )->get_mwskz(
                                                                        iv_blart = cs_dest_line-blart                  " Belegart
                                                                        iv_bukrs = cs_dest_line-bukrs                 " Buchungskreis
                                                                        iv_saknr = cs_dest_line-hkont                 " Nummer des Sachkontos
                                                                        iv_btyp = ''
                                                                        iv_bkz = ''
                                                                      ).
***************************************************************************
*                   GSBER - Geschäftsbereich                              *
***************************************************************************
    cs_dest_line-gsber = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-gsber.
***************************************************************************
*                   AUFNR - Innenauftrag                                  *
***************************************************************************
    cs_dest_line-aufnr = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-aufnr.
***************************************************************************
*                   KOSTL - Kostenstelle                                  *
***************************************************************************
    cs_dest_line-kostl = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-kostl.
***************************************************************************
*                   SGTXT - Positionstext                                 *
***************************************************************************
    cs_dest_line-sgtxt = |*{ is_pso02s-sgtxt }|.
***************************************************************************
*                   WRBTR - Betrag in Belegwährung                        *
***************************************************************************
    cs_dest_line-wrbtr = is_pso02s-wrbtr.
  ENDMETHOD.


  METHOD map_mv_up_by_kble.
*****************************************************************************
*                   BLPOS - Belegposition Mittelvormerkung der Wertanpassung*
*****************************************************************************
    cs_dest_line-blpos = is_kble-blpos.
*****************************************************************************
*                   BTEXT - Wertanpassungsbeleg: Beschreibung               *
*****************************************************************************
    cs_dest_line-btext = is_kble-belnr && is_kble-blpos && is_kble-bpent.
*****************************************************************************************
*                   WTSUPP - Wertanpassungsbeleg: Änderungsbetrag in Transaktionswährung*
*****************************************************************************************
    cs_dest_line-wtsupp =  calc_mv_up_amount_for_kble(
                             iv_btext  = cs_dest_line-btext                 " Wertanpassungsbeleg: Beschreibung
                             iv_wtsupp = is_kble-wtabb                 " Wertanpassungsbeleg: Änderungsbetrag in Transaktionswährung
                             iv_belnr  = cs_dest_line-belnr                 " Belegnummer Mittelvormerkung Wertanpassung
                             iv_blpos  = cs_dest_line-blpos                 " Belegposition Mittelvormerkung der Wertanpassung
                           ).
*****************************************************************************************
*                   XMINUS - Kennzeichen: Wertanpassungsbeleg ist eine Wertminderung    *
*****************************************************************************************
    IF cs_dest_line-wtsupp = 0.
      "Keine Änderung zwischen den Beträgen
      "Keine Wertänderung erzeugen
      CLEAR: cs_dest_line-wtsupp.
      IF 1 = 0. MESSAGE i049(/thkr/sst).ENDIF.
      APPEND VALUE bapiret2( id = GC_MSGID
                             number = 049
                             type = 'I' ) TO cs_dest_line-msg.
    ELSEIF cs_dest_line-wtsupp < 0.
      "Erhöhung der Mittelbindung
      cs_dest_line-xminus = abap_false.
      cs_dest_line-wtsupp = cs_dest_line-wtsupp * -1.
    ELSE.
      "Senkung der Mittelbindung
      cs_dest_line-xminus = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD map_mv_up_by_kblp.
*****************************************************************************
*                   BLPOS - Belegposition Mittelvormerkung der Wertanpassung*
*****************************************************************************
*    cs_dest_line-blpos = is_kblp-blpos.
*****************************************************************************
*                   BTEXT - Wertanpassungsbeleg: Beschreibung               *
*****************************************************************************
    cs_dest_line-btext = is_kblp-belnr && is_kblp-blpos.
*****************************************************************************************
*                   WTSUPP - Wertanpassungsbeleg: Änderungsbetrag in Transaktionswährung*
    DATA(lv_wtsupp) = calc_mv_up_amount_for_kblp(
                        iv_btext  = cs_dest_line-btext                 " Wertanpassungsbeleg: Beschreibung
                        iv_wtsupp = is_kblp-wtges                      " Wertanpassungsbeleg: Änderungsbetrag in Transaktionswährung
                        iv_belnr  = cs_dest_line-belnr                 " Belegnummer Mittelvormerkung Wertanpassung
                        iv_blpos  = cs_dest_line-blpos                 " Belegposition Mittelvormerkung der Wertanpassung
                        iv_wtorig = ms_mb_data-wtorig
                      ).
*****************************************************************************************
*                   XMINUS - Kennzeichen: Wertanpassungsbeleg ist eine Wertminderung    *
*****************************************************************************************
    "wertänderung wurde bereits übertragen. Keine Anpassung.
    IF lv_wtsupp IS NOT INITIAL.
      cs_dest_line-wtsupp = ms_mb_data-wtges - ( is_kblp-wtges - iv_booked_kble_wtapp_ges ).
      IF cs_dest_line-wtsupp = 0.
        "komplettabbau:
        cs_dest_line-xminus = abap_true.
        cs_dest_line-wtsupp = is_kblp-wtges.
      ELSEIF cs_dest_line-wtsupp < 0.
        "Erhöhung der Mittelbindung
        cs_dest_line-xminus = abap_false.
        cs_dest_line-wtsupp = cs_dest_line-wtsupp * -1.
      ELSE.
        "Senkung der Mittelbindung
        cs_dest_line-xminus = abap_true.
      ENDIF.
    ELSE.

      IF /thkr/cl_pso_xml_processing=>get_instance( )->ms_mb_data-wtges <> is_kblp-wtges.
        "Zeile wurde im Quellsystem gelöscht bzw. auf Null gesetzt.
        "Wert abziehen
        cs_dest_line-xminus = abap_true.
        cs_dest_line-wtsupp = /thkr/cl_pso_xml_processing=>get_instance( )->ms_mb_data-wtges.
      ELSE.
        "Keine Wertanpassung notwendig.
        CLEAR: cs_dest_line-wtsupp.
        IF 1 = 0. MESSAGE i050(/thkr/sst).ENDIF.
        APPEND VALUE bapiret2( id = gc_msgid
                               number = 050
                               type = 'I' ) TO cs_dest_line-msg.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD process_ao.
    DATA:
      ls_document_number TYPE /thkr/s_psm_ao_document_number,
      ls_dto_psm_ao      TYPE /thkr/s_dto_psm_ao_bel_create,
      ls_gp              TYPE /thkr/s_aif_sap_gp,
      lv_process_ao      TYPE flag VALUE abap_true.

    LOOP AT ct_ao ASSIGNING FIELD-SYMBOL(<ls_ao>).
      TRY.
          "Prüfung, ob es aus dem Mapping Fehler gibt. (Zum Beispiel Anordnung oder Mittelbindung nicht gefunden)
          READ TABLE <ls_ao>-msg WITH KEY type = 'E' TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            "Es fehlen relvante Daten für die Buchung.
            "Fehlermeldungen ans AIF - Log übergeben
            APPEND LINES OF <ls_ao>-msg TO ct_return.
          ELSE.
            "Prüfung, ob Beträge 0.00 sind.
            "SAP meldet eine erfolgreiche Buchung von Anordnungen mit Betrag 0.
            "Es zieht auch aus dem Nummernkreis für Anordnungen und FI-Belege Nummern.
            "Aber am Ende speichert SAP diese Anordnung nicht.
            LOOP AT <ls_ao>-t_kont TRANSPORTING NO FIELDS WHERE wrbtr IS INITIAL.
              IF 1 = 0. MESSAGE e045(/thkr/sst).ENDIF.
              APPEND VALUE bapiret2( id = '/THKR/SST'
                                     number = 45
                                     type = 'E' ) TO <ls_ao>-msg.
              APPEND LINES OF <ls_ao>-msg TO ct_return.
            ENDLOOP.
            IF sy-subrc <> 0.
              "Keine Fehler während des Mappings. Verarbeitung starten
              IF  ( <ls_ao>-ao_proc_status IS INITIAL OR <ls_ao>-ao_proc_status = 'E' OR <ls_ao>-ao_proc_status = 'A' ).
                "Geschäftspartnernummer aus GP Struktur lesen, sofern nicht leer.
                "Wenn leer, dann ist der Geschäftspartner neu und muss aus den Daten gelesen werden.
                get_sap_bp_after_action(
                  EXPORTING
                    it_gp         = it_gp
                  CHANGING
                    cv_success    = cv_success                 " Erfolgskennzeichen
                    ct_return     = ct_return
                    cs_ao         = <ls_ao>                 " Geschäftspartnernummer
                    cv_process_ao = lv_process_ao                 " allgemeines flag
                ).

                "Prüfen, ob es Probleme bei der Mittelbindung gab.
                "Wenn nicht, dann kann die Buchungsstruktur ls_dto_psm_ao gemappt werden.
                ls_dto_psm_ao = check_mb_processing(
                  EXPORTING
                    is_ao          = <ls_ao>                 " DTO: Anlegen eines Beleges zu einer PSM-Anordnung
                    it_anordnungen = it_anordnungen                 " Anordnung
                  CHANGING
                    ct_return      = ct_return
                    cv_process_ao  = lv_process_ao                 " allgemeines flag
                    cv_success     = cv_success                 " Erfolgskennzeichen

                ).
                "kein ordentliches Fehlerhandling in AO-Anlage
                "Daher wird der Status im Vorfeld auf Fehler gesetzt.
                "Ist die Buchung erfolgreich, dann wird später der Status auf S gesetzt.
                IF lv_process_ao = abap_true.
                  <ls_ao>-ao_proc_status = 'E'.

                  "Für Sollzugang mit Dateibezug (Datensatz nicht auf der Datenbank, sondern in der Datei)
                  "Belegnummer wäre sonst gefüllt (Datensatz würde von der Datenbank gelesen werden)
                  IF ls_dto_psm_ao-rebzg IS INITIAL
                 AND ls_dto_psm_ao-psoty = '02' "Annahmeanordnung
                 AND ls_dto_psm_ao-blart = 'DE'."Sollzugang
                    TRY.
                        "Lese Belegnummer aus Anordnung.
                        LOOP AT it_anordnungen ASSIGNING FIELD-SYMBOL(<ls_anordnungen>).

                          ls_dto_psm_ao-rebzg = <ls_anordnungen>-ao[ xblnr = ls_dto_psm_ao-bktxt psoty = '02' ]-belnr.
                          "Prüfen ob Belegnummer immer noch leer ist.
                          "Denn dann konnte die Anordnung zum Sollzugang nicht erzeugt werden.
                          "Fehlermeldung schreiben.
                          IF ls_dto_psm_ao-rebzg IS INITIAL.
                            IF 1 = 0. MESSAGE e039(/thkr/sst) WITH ls_dto_psm_ao-bktxt.ENDIF.
                            APPEND VALUE #( id         = '/THKR/SST'
                                         number     = 039
                                         type       = 'E'
                                         message_v1 = ls_dto_psm_ao-bktxt ) TO ct_return.
                          ELSE.
                            "Belegnummer gefunden. Schleife verlassen.
                            "Referenz zur Anordnung kann in der internen Schnittstelle erstellt werden.
                            EXIT.
                          ENDIF.
                        ENDLOOP.
                      CATCH cx_sy_itab_line_not_found.
                        IF 1 = 0. MESSAGE e038(/thkr/sst) WITH ls_dto_psm_ao-bktxt.ENDIF.
                        APPEND VALUE #( id         = '/THKR/SST'
                                     number     = 038
                                     type       = 'E'
                                     message_v1 = ls_dto_psm_ao-bktxt ) TO ct_return.
                    ENDTRY.

                  ENDIF.
                   mo_ao_appl->create_psm_ao_beleg(
                               EXPORTING
                                 i_dto_psm_ao_bel_create = ls_dto_psm_ao
                               IMPORTING
                                 e_psm_ao_document_number = DATA(ls_psm_ao_document_number) ).
*                  /thkr/cl_psm_ao_appl=>get_instance( )->create_psm_ao_beleg(
*                               EXPORTING
*                                 i_dto_psm_ao_bel_create = ls_dto_psm_ao
*                               IMPORTING
*                                 e_psm_ao_document_number = DATA(ls_psm_ao_document_number) ).
                  MOVE-CORRESPONDING ls_psm_ao_document_number TO <ls_ao>.
                  IF  <ls_ao>-long_text-lines IS NOT INITIAL.
                    "Hinzfügen des Schlüssels für Langtexte.
                    "Belegnummer erst nach Buchung im System.
                     <ls_ao>-long_text-header-tdname = |{  <ls_ao>-bukrs }{  <ls_ao>-belnr }{  <ls_ao>-gjahr }|.
                  ENDIF.

                  "Split-AO
                  "Beleg muss in gleicher AO erscheinen
                  "Setzen des Bündelungskennzeichen (LOTKZ) für zusammgehörende Belege
                  "GLBID(14) = Geschäftsjahr (4 zeichen) + Bündelungskennzeichen (10 Zeichen) aus Quelle
                  LOOP AT ct_ao ASSIGNING FIELD-SYMBOL(<ls_upd_lotkz>) WHERE glblid(14) = <ls_ao>-glblid(14).
                    <ls_upd_lotkz>-lotkz = ls_psm_ao_document_number-lotkz.
                  ENDLOOP.
                  <ls_ao>-ao_proc_status = 'S'.
                  cv_success = 'Y'.

                  "Commit Work notwendig, damit bei einer Split-AO der zweite Beleg hinzugefügt werden kann
                  "Anderfalls erscheint eine Fehlermeldung mit (FQ 840 Anordnung nicht vorhanden)
                  COMMIT WORK AND WAIT.
                  "Verrechnungen. Anorndung mit Zahlschlüssel X
*                upd_ausao_with_kassz_anao(
*                  EXPORTING
*                    is_ao = <ls_ao>                  " AIF SAP Struktur für Anordnungen
*                  CHANGING
*                    ct_ao = CT_AO
*                ).


                  IF 1 = 0. MESSAGE s823(fq) WITH ls_psm_ao_document_number-lotkz ls_psm_ao_document_number-belnr. ENDIF.
                  APPEND VALUE #( id         = 'FQ'
                                   number     = 823
                                   type       = 'S'
                                   message_v1 = ls_psm_ao_document_number-lotkz
                                   message_v2 = ls_psm_ao_document_number-belnr ) TO ct_return.
                ELSE.
                  "Die Verarbeitung der Anordnung kann nicht durchgeführt werden, weil in der Verarbeitungskette
                  "Fehler aufgetreten sind.
                  "1.) Geschäftspartner
                  "2.) Mittelbindung
                  <ls_ao>-ao_proc_status = 'E'.
                  cv_success = 'N'.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        CATCH /thkr/cx_psm_int_fi INTO DATA(lxc_ao).
          <ls_ao>-ao_proc_status = 'E'.
          IF lxc_ao->bapiret2_tab IS NOT INITIAL.
            APPEND LINES OF lxc_ao->bapiret2_tab TO ct_return.
          ELSE.
            APPEND VALUE #( id         = lxc_ao->if_t100_message~t100key-msgid
                            number     = lxc_ao->if_t100_message~t100key-msgno
                            type       = lxc_ao->if_t100_dyn_msg~msgty
                            message_v1 = lxc_ao->if_t100_dyn_msg~msgv1
                            message_v2 = lxc_ao->if_t100_dyn_msg~msgv2
                            message_v3 = lxc_ao->if_t100_dyn_msg~msgv3
                            message_v4 = lxc_ao->if_t100_dyn_msg~msgv4 ) TO ct_return.
          ENDIF.
          cv_success = 'N'.
      ENDTRY.
      <ls_ao>-msg = ct_return.
    ENDLOOP.

  ENDMETHOD.


  METHOD process_bp.

    DATA: lv_partner         TYPE bu_partner,
          lt_bpext_processed TYPE STANDARD TABLE OF bu_bpext,
          ls_dto_bp_modify   TYPE /thkr/s_dto_bp_modify,
          lv_idx_table       TYPE string,
          ls_dto_gp          TYPE /thkr/s_dto_bp_create,
          lv_is_cpd          TYPE flag.



    LOOP AT ct_bp ASSIGNING FIELD-SYMBOL(<ls_gp>).
      TRY.
          "Prüfung, ob es aus dem Mapping Fehler gibt. (Zum Beispiel Anordnung oder Mittelbindung nicht gefunden)
          READ TABLE <ls_gp>-msg WITH KEY type = 'E' TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            "Es fehlen relvante Daten für die Buchung.
            "Fehlermeldungen ans AIF - Log übergeben
            APPEND LINES OF <ls_gp>-msg TO ct_return.
          ELSE.

            IF  ( <ls_gp>-bp_proc_status IS INITIAL OR <ls_gp>-bp_proc_status = 'E' OR <ls_gp>-bp_proc_status = 'A' ).
              "Bedingungen
              "1. Entweder das Feld Partner ist leer und existiert noch nicht auf der Datenbank
              "oder
              "2. es handelt sich um einen CPD.
              IF ( <ls_gp>-partner IS INITIAL AND me->check_bp_already_on_db(
                                                  EXPORTING
                                                   iv_bu_type  = <ls_gp>-bu_type                 " Geschäftspartnertyp
                                                   iv_bu_bpext = <ls_gp>-bu_bpext                 " Geschäftspartnernummer im externen System
                                                   iv_sst = <ls_gp>-/thkr/sst
                                                  CHANGING
                                                    cv_partner  = <ls_gp>-partner                 " Partnernummer
                                                ) = abap_false )
                OR <ls_gp>-bu_bpext(4) = 'CPD_'.
                "durch die Prüfung auf Existenz wird gleichzeitig die Partnernummer gefüllt.
                "Das ist notwendig, um dann in die Änderung des Geschäftspartners zu kommen.
                "Bei der Anlage des Geschäftspartner wird die Partnernummer nicht benötigt.
                "Es folgt ansonsten die Fehlermeldung "Business Partner with GUID <GUID> already exists
                "das passiert vor allem bei CPDs. Denn die Partnernummer mit 0000000001 existiert auf dem Sysetm
                CLEAR: <ls_gp>-partner.
                "Jeden Geschäftspartner nur einmal anlegen.
                "gleicher Geschäftspartner taucht mehrmals in der Datenlieferung auf, existiert aber noch nicht auf der Datenbank.
                "D.h. die haben alle die gleiche externe ID, aber keine Partnernummer.
                READ TABLE lt_bpext_processed WITH KEY table_line = <ls_gp>-bu_bpext TRANSPORTING NO FIELDS.
                "Create BP
                IF sy-subrc <> 0 OR lv_is_cpd = abap_true.
                  MOVE-CORRESPONDING <ls_gp> TO ls_dto_gp.
                  mo_bp_appl->create_partner(
                    EXPORTING
                      i_dto_bp_create = ls_dto_gp
                    IMPORTING
                      e_partner       =  lv_partner ).
                  <ls_gp>-partner = lv_partner.
                  "Verarbeitete externe Nummer merken, damit der gleiche Geschäftspartner nicht zweimal angelegt wird.
                  APPEND <ls_gp>-bu_bpext TO lt_bpext_processed.

                  "Setzen der Parnter-ID für gleiche Parnter in der Lieferung.
                  "allerdings nicht bei CPDs. Die sollen immer einzeln betrachtet werden
                  IF  lv_is_cpd = abap_false.
                    LOOP AT ct_anordnungen ASSIGNING FIELD-SYMBOL(<ls_anord>).
                      TRY.
*                        IF  lv_is_cpd = abap_true.
                          "CPD
                          "Also muss der Geschäftspartner für jeden CPD neu angelegt werden
                          "Referenz über die Quell-Belegnummer
*                          <ls_anord>-gp[ bu_bpext = <ls_gp>-bu_bpext /thkr/sst = <ls_gp>-/thkr/sst bu_type = <ls_gp>-bu_type src_belnr = <ls_gp>-src_belnr ]-partner = lv_partner.
*                        ELSE.
*                        IF  lv_is_cpd = abap_false.
                          "Normale Geschäftspartner
                          "diese haben unterschiedliche Kunden- bzw. Lieferantennummern im Partnersystem
                          "also können diese für alle Anordnungen übernommen werden.
                          LOOP AT <ls_anord>-gp ASSIGNING FIELD-SYMBOL(<ls_ao_gp>) WHERE bu_bpext = <ls_gp>-bu_bpext
                                                                                    AND /thkr/sst = <ls_gp>-/thkr/sst
                                                                                    AND bu_type = <ls_gp>-bu_type.
                            <ls_ao_gp>-partner = lv_partner.
                          ENDLOOP.
*                        ENDIF.
                        CATCH cx_sy_itab_line_not_found.
                          CONTINUE.
                      ENDTRY.
                    ENDLOOP.
                  ENDIF.

                  IF 0 = 1. MESSAGE s111(b0). ENDIF.
                  APPEND VALUE #( id         = 'B0'
                                    number     = 111
                                    type       = 'S'
                                    message_v1 = lv_partner  ) TO ct_return.
                ENDIF.
              ELSE.
                "Change BP
                MOVE-CORRESPONDING <ls_gp> TO ls_dto_bp_modify EXPANDING NESTED TABLES.
                mo_bp_appl->modify_partner( i_dto_bp_modify = ls_dto_bp_modify ).
                IF 0 = 1. MESSAGE s112(b0). ENDIF.
                APPEND VALUE #( id         = 'B0'
                                  number     = 112
                                  type       = 'S'
                                  message_v1 = <ls_gp>-partner  ) TO ct_return.
              ENDIF.
              <ls_gp>-bp_proc_status = 'S'.
              "Usually AIF handle the commit work.
              "But in this case the business partner which was created successfully
              "should be commited. Otherwise a success message occurs in the monitoring
              "But a roll back happends after an error in another business partner
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = abap_true
*                 IMPORTING
*                 RETURN        =
                .

            ENDIF.
          ENDIF.
        CATCH /thkr/cx_bp INTO DATA(lxc_bp).
          IF lxc_bp->bapiret2_tab IS NOT INITIAL.
            APPEND LINES OF lxc_bp->bapiret2_tab TO ct_return.
          ELSE.
            APPEND VALUE #( id = lxc_bp->if_t100_message~t100key-msgid
                            number = lxc_bp->if_t100_message~t100key-msgno
                            type = lxc_bp->if_t100_dyn_msg~msgty
                            message_v1 = lxc_bp->if_t100_dyn_msg~msgv1
                            message_v2 = lxc_bp->if_t100_dyn_msg~msgv2
                            message_v3 = lxc_bp->if_t100_dyn_msg~msgv3
                            message_v4 = lxc_bp->if_t100_dyn_msg~msgv4 ) TO ct_return.
          ENDIF.
          "Processing not successful
          "Set AIF sucess to no
          cv_success = 'N'.
          <ls_gp>-bp_proc_status = 'E'.
          <ls_gp>-msg = ct_return.
          "Start with next business partner
          CONTINUE.

      ENDTRY.
      <ls_gp>-msg = ct_return.

    ENDLOOP.

  ENDMETHOD.


  METHOD process_mv.

    DATA: l_dto_psm_mv_create TYPE /thkr/s_dto_psm_mv_create.
    DATA:    ls_aif_obj       TYPE /thkr/t_aif_obj.
    DATA: lv_process_mv TYPE flag.

    LOOP AT ct_mv ASSIGNING FIELD-SYMBOL(<ls_mv>).
      TRY.
          READ TABLE <ls_mv>-msg WITH KEY type = 'E' TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            "Es fehlen relvante Daten für die Buchung.
            "Fehlermeldungen ans AIF - Log übergeben
            APPEND LINES OF <ls_mv>-msg TO ct_return.
            cv_success = 'N'.
          ELSE.
            "Geschäftspartner ermitteln, sofern neu angelegt.
            "nur wenn notwendig
            "Wird über die Belegart bestimmt.
            if me->check_bp_for_mb(
                 EXPORTING
                   iv_blart      = <ls_mv>-blart                 " Belegart
                   is_data_line  = <ls_mv>                 " AIF SAP Struktur für Mittelbindung
                   is_data_field = 'PARTNER'                 " allgemeines flag
                   is_data       = <ls_mv>                  " Output Struktur
                 CHANGING
                   ct_return     = ct_return
               ) = abap_true.
            GET_SAP_BP_AFTER_ACT_MB(
            EXPORTING
              it_gp         = it_gp
            CHANGING
              cv_success    = cv_success                 " Erfolgskennzeichen
              ct_return     = ct_return
              cs_mv         = <ls_mv>                 " Geschäftspartnernummer
              cv_process_mv = lv_process_mv                 " allgemeines flag
          ).
            endif.

            "Starte nur fehlerhafte bzw. Erstanlage von Datensätzen.
            "bereits erfolgreich gebuchte Datensätze überspringen.
            IF  ( <ls_mv>-mv_proc_status IS INITIAL OR <ls_mv>-mv_proc_status = 'E' OR <ls_mv>-mv_proc_status = 'A' ).
              cv_success = 'Y'.
              <ls_mv>-mv_proc_status = 'E'.
              MOVE-CORRESPONDING <ls_mv> TO l_dto_psm_mv_create.
              CASE <ls_mv>-mv_action.
                WHEN: 'I'. "Insert.
                  mo_mv_appl->create_psm_mv(
                     EXPORTING
                       i_dto_psm_mv_bel_create = l_dto_psm_mv_create
                     IMPORTING
                       e_kblnr                 = DATA(lv_blnr)               "Beleg Nummer zu AO
                   ).
                  <ls_mv>-mv_proc_status = 'S'.
                  <ls_mv>-belnr = lv_blnr.
                  IF <ls_mv>-long_text-lines IS NOT INITIAL.
                    "Hinzfügen des Schlüssels für Langtexte.
                    "Belegnummer erst nach Buchung im System.
                    <ls_mv>-long_text-header-tdname = |{ sy-mandt }{ <ls_mv>-belnr }000|.
                  ENDIF.
                  IF 1 = 0. MESSAGE s241(fkkorder) WITH lv_blnr. ENDIF.
                  APPEND VALUE #( id         = 'FKKORDER'
                   number     = 241
                   type       = 'S'
                   message_v1 = lv_blnr ) TO ct_return.

                WHEN: 'U'. "Update
                  mo_mv_appl->change_psm_mv(
                     EXPORTING
                       i_dto_psm_mv_bel_create = l_dto_psm_mv_create                  " DTO: PSM-Mittelvormerkungen für Anlage
                     IMPORTING
                       e_kblnr                 =  lv_blnr                " Belegnummer Mittelvormerkung
*                  RECEIVING
*                    r_kblnr                 =                  " Belegnummer Mittelvormerkung
                   ).
                  <ls_mv>-mv_proc_status = 'S'.
                  <ls_mv>-belnr = lv_blnr.
                  IF <ls_mv>-long_text-lines IS NOT INITIAL.
                    "Hinzfügen des Schlüssels für Langtexte.
                    "Belegnummer erst nach Buchung im System.
                    <ls_mv>-long_text-header-tdname = |{ sy-mandt }{ <ls_mv>-belnr }000|.
                  ENDIF.
                  IF 1 = 0. MESSAGE s241(fkkorder) WITH lv_blnr. ENDIF.
                  APPEND VALUE #( id         = 'FQ'
                                   number     = 681
                                   type       = 'S'
                                   message_v1 = <ls_mv>-belnr ) TO ct_return.
              ENDCASE.

            ENDIF.

          ENDIF.
        CATCH /thkr/cx_psm_int_fi INTO DATA(lxc_psm_mb).
          IF lxc_psm_mb->bapiret2_tab IS NOT INITIAL.
            APPEND LINES OF lxc_psm_mb->bapiret2_tab TO ct_return.
          ELSE.
            APPEND VALUE #( id         = lxc_psm_mb->if_t100_message~t100key-msgid
                            number     = lxc_psm_mb->if_t100_message~t100key-msgno
                            type       = lxc_psm_mb->if_t100_dyn_msg~msgty
                            message_v1 = lxc_psm_mb->if_t100_dyn_msg~msgv1
                            message_v2 = lxc_psm_mb->if_t100_dyn_msg~msgv2
                            message_v3 = lxc_psm_mb->if_t100_dyn_msg~msgv3
                            message_v4 = lxc_psm_mb->if_t100_dyn_msg~msgv4 ) TO ct_return.
          ENDIF.
          cv_success = 'N'.
          <ls_mv>-msg = ct_return.
      ENDTRY.
*----------------------------------------------------------------------
      <ls_mv>-msg = ct_return.
    ENDLOOP.

  ENDMETHOD.


  METHOD process_mv_up.

    DATA: l_dto_psm_mv_update_val TYPE /thkr/s_dto_psm_mv_update_val,
          ls_aif_obj              TYPE /thkr/t_aif_obj.

    LOOP AT ct_mv_up ASSIGNING FIELD-SYMBOL(<ls_mv_up>).
      TRY.
          READ TABLE <ls_mv_up>-msg WITH KEY type = 'E' TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            "Es fehlen relvante Daten für die Buchung.
            "Fehlermeldungen ans AIF - Log übergeben
            APPEND LINES OF <ls_mv_up>-msg TO ct_return.
            cv_success = 'N'.
          ELSE.
            LOOP AT <ls_mv_up>-msg TRANSPORTING NO FIELDS WHERE id = gc_msgid
                                                             AND type = 'I'
                                                             AND ( number = 049
                                                              OR   number = 050 ) .
            ENDLOOP.
            IF sy-subrc = 0.
              "Die Beträge in den Wertanpassungen sind identisch. Keine neue Wertanpassung durchführen.
              APPEND LINES OF <ls_mv_up>-msg TO ct_return.
              cv_success = 'Y'.
              <ls_mv_up>-mv_up_proc_status = 'S'.
            ELSE.
              "Starte nur fehlerhafte bzw. Erstanlage von Datensätzen.
              "bereits erfolgreich gebuchte Datensätze überspringen.
              IF  ( <ls_mv_up>-mv_up_proc_status IS INITIAL OR <ls_mv_up>-mv_up_proc_status = 'E' OR <ls_mv_up>-mv_up_proc_status = 'A' ).
                MOVE-CORRESPONDING <ls_mv_up> TO l_dto_psm_mv_update_val.
*"----------------------------------------------------------------------
                mo_mv_appl->update_psm_mv_value(
                   EXPORTING
                     i_dto_psm_mv_update_val = l_dto_psm_mv_update_val
                 ).
*"----------------------------------------------------------------------
                <ls_mv_up>-mv_up_proc_status = 'S'.
                COMMIT WORK AND WAIT.
                IF <ls_mv_up>-long_text-lines IS NOT INITIAL.
                  "Hinzfügen des Schlüssels für Langtexte.
                  "Belegnummer erst nach Buchung im System.
                  <ls_mv_up>-long_text-header-tdname = |{ sy-mandt }{ <ls_mv_up>-belnr }000|.
                ENDIF.
*"----------------------------------------------------------------------
                APPEND VALUE #( id         = '/THKR/SST'
                                 number     = 001
                                 type       = 'I'
                                 message_v1 = 'Wertanpassung für Mittelbindung'
                                 message_v2 = l_dto_psm_mv_update_val-belnr
                                 message_v3  = 'wurde durchgeführt.' ) TO ct_return.
              ENDIF.
            ENDIF.
          ENDIF.
*"----------------------------------------------------------------------
        CATCH /thkr/cx_psm_int_fi INTO DATA(lxc_psm_mb).
          IF lxc_psm_mb->bapiret2_tab IS NOT INITIAL.
            APPEND LINES OF lxc_psm_mb->bapiret2_tab TO ct_return.
          ELSE.
            APPEND VALUE #( id         = lxc_psm_mb->if_t100_message~t100key-msgid
                            number     = lxc_psm_mb->if_t100_message~t100key-msgno
                            type       = lxc_psm_mb->if_t100_dyn_msg~msgty
                            message_v1 = lxc_psm_mb->if_t100_dyn_msg~msgv1
                            message_v2 = lxc_psm_mb->if_t100_dyn_msg~msgv2
                            message_v3 = lxc_psm_mb->if_t100_dyn_msg~msgv3
                            message_v4 = lxc_psm_mb->if_t100_dyn_msg~msgv4 ) TO ct_return.
          ENDIF.

          ls_aif_obj-status = 'E'.
          MODIFY /thkr/t_aif_obj FROM ls_aif_obj.
          cv_success = 'N'.
      ENDTRY.

*----------------------------------------------------------------------
      <ls_mv_up>-msg = ct_return.
    ENDLOOP.

  ENDMETHOD.


  METHOD process_storno.
    DATA: lo_storno  TYPE REF TO /thkr/cl_fi_storno.
    DATA: ls_storno  TYPE /thkr/s_fi_key_storno_data.

    LOOP AT ct_storno ASSIGNING FIELD-SYMBOL(<ls_storno>).
*"----------------------------------------------------------------------
      TRY.
          "Prüfung, ob es aus dem Mapping Fehler gibt. (Zum Beispiel Anordnung oder Mittelbindung nicht gefunden)
          READ TABLE <ls_storno>-msg WITH KEY type = 'E' TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            "Es fehlen relvante Daten für die Buchung.
            "Fehlermeldungen ans AIF - Log übergeben
            APPEND LINES OF <ls_storno>-msg to ct_return.
          ELSE.
            MOVE-CORRESPONDING <ls_storno> TO ls_storno.
            lo_storno = NEW /thkr/cl_fi_storno( i_fi_beleg_storno_data = ls_storno ).

            lo_storno->start_fi_storno(
              CHANGING
                ct_return_tab = ct_return[]
            ).
            <ls_storno>-proc_status = 'S'.
            cv_success = 'Y'.
            APPEND VALUE #( id         = '/THKR/SST'
                           number     = 017
                           type       = 'S'
                           message_v1 = <ls_storno>-lotkz
                           message_v2 = <ls_storno>-belnr ) TO ct_return.
          ENDIF.
        CATCH /thkr/cx_fi INTO DATA(lxc_storno). " Ausnahmeklasse für FI
          IF lxc_storno->bapiret2_tab IS NOT INITIAL.
            APPEND LINES OF lxc_storno->bapiret2_tab TO ct_return.
          ELSE.
            APPEND VALUE #( id         = lxc_storno->if_t100_message~t100key-msgid
                            number     = lxc_storno->if_t100_message~t100key-msgno
                            type       = lxc_storno->if_t100_dyn_msg~msgty
                            message_v1 = lxc_storno->if_t100_dyn_msg~msgv1
                            message_v2 = lxc_storno->if_t100_dyn_msg~msgv2
                            message_v3 = lxc_storno->if_t100_dyn_msg~msgv3
                            message_v4 = lxc_storno->if_t100_dyn_msg~msgv4 ) TO ct_return.
          ENDIF.
          cv_success = 'N'.
          <ls_storno>-proc_status = 'E'.
      ENDTRY.
      APPEND LINES OF ct_return TO <ls_storno>-msg.
    ENDLOOP.

  ENDMETHOD.


METHOD process_stu.
*"----------------------------------------------------------------------
  DATA:
    ls_document_number TYPE /thkr/s_psm_ao_document_number,
    ls_dto_psm_stu     TYPE /thkr/s_dto_psm_ao_bel_create,
    ls_gp              TYPE /thkr/s_aif_sap_gp.
*"----------------------------------------------------------------------
  LOOP AT ct_ao ASSIGNING FIELD-SYMBOL(<ls_ao>).
*"----------------------------------------------------------------------
    TRY.
        "Prüfung, ob es aus dem Mapping Fehler gibt. (Zum Beispiel Anordnung oder Mittelbindung nicht gefunden)
        READ TABLE <ls_ao>-msg WITH KEY type = 'E' TRANSPORTING NO FIELDS.

        IF sy-subrc = 0.
          "Es fehlen relvante Daten für die Buchung.
          "Fehlermeldungen ans AIF - Log übergeben
          APPEND LINES OF <ls_ao>-msg TO ct_return.
        ELSE.
          "Keine Fehler während des Mappings. Verarbeitung starten
          "Prüfung Reprocessing (Status wird während des Mappings gesetzt)
          IF  ( <ls_ao>-ao_proc_status IS INITIAL OR <ls_ao>-ao_proc_status = 'E' OR <ls_ao>-ao_proc_status = 'A' ).

            MOVE-CORRESPONDING <ls_ao> TO ls_dto_psm_stu.
            "kein ordentliches Fehlerhandling in AO-Anlage
            "Daher wird der Status im Vorfeld auf Fehler gesetzt.
            "Ist die Buchung erfolgreich, dann wird später der Status auf S gesetzt.
            <ls_ao>-ao_proc_status = 'E'.

            mo_ao_appl->create_due_date_deferral(
              EXPORTING
                i_dto_psm_ao_bel_create  = ls_dto_psm_stu
              IMPORTING
                e_psm_ao_document_number = ls_document_number ).
            MOVE-CORRESPONDING ls_document_number TO <ls_ao>.
            IF  <ls_ao>-long_text-lines IS NOT INITIAL.
              "Hinzfügen des Schlüssels für Langtexte.
              "Belegnummer erst nach Buchung im System.
              <ls_ao>-long_text-header-tdname = |{  <ls_ao>-bukrs }{  <ls_ao>-belnr }{  <ls_ao>-gjahr }|.
            ENDIF.
            <ls_ao>-ao_proc_status = 'S'.
            cv_success = 'Y'.
            IF 1 = 0. MESSAGE s823(fq) WITH ls_document_number-lotkz ls_document_number-belnr. ENDIF.
            APPEND VALUE #( id         = 'FQ'
                             number     = 823
                             type       = 'S'
                             message_v1 = ls_document_number-lotkz
                             message_v2 = ls_document_number-belnr ) TO ct_return.
          ENDIF.
        ENDIF.
*"----------------------------------------------------------------------
      CATCH /thkr/cx_psm_int_fi INTO DATA(lxc_ao).
        <ls_ao>-ao_proc_status = 'E'.

        IF lxc_ao->bapiret2_tab IS NOT INITIAL.
          APPEND LINES OF lxc_ao->bapiret2_tab TO ct_return.
        ELSE.
          APPEND VALUE #( id         = lxc_ao->if_t100_message~t100key-msgid
                          number     = lxc_ao->if_t100_message~t100key-msgno
                          type       = lxc_ao->if_t100_dyn_msg~msgty
                          message_v1 = lxc_ao->if_t100_dyn_msg~msgv1
                          message_v2 = lxc_ao->if_t100_dyn_msg~msgv2
                          message_v3 = lxc_ao->if_t100_dyn_msg~msgv3
                          message_v4 = lxc_ao->if_t100_dyn_msg~msgv4 ) TO ct_return.
        ENDIF.

        cv_success = 'N'.
*"----------------------------------------------------------------------
    ENDTRY.
*"----------------------------------------------------------------------
    APPEND LINES OF ct_return TO <ls_ao>-msg.
*"----------------------------------------------------------------------
  ENDLOOP.
*"----------------------------------------------------------------------
ENDMETHOD.


  METHOD process_vr.
    DATA: l_dto_psm_vr       TYPE /thkr/s_dto_psm_ao_verrechnung,
          ls_document_number TYPE /thkr/s_psm_ao_document_number.

    LOOP AT ct_vr ASSIGNING FIELD-SYMBOL(<ls_vr>).

*"----------------------------------------------------------------------
      TRY.
          READ TABLE <ls_vr>-msg WITH KEY type = 'E' TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            "Es fehlen relvante Daten für die Buchung.
            "Fehlermeldungen ans AIF - Log übergeben
            APPEND LINES OF <ls_vr>-msg TO ct_return.
            cv_success = 'N'.
          ELSE.
            "Starte nur fehlerhafte bzw. Erstanlage von Datensätzen.
            "bereits erfolgreich gebuchte Datensätze überspringen.
            IF  ( <ls_vr>-vr_proc_status IS INITIAL OR <ls_vr>-vr_proc_status = 'E' OR <ls_vr>-vr_proc_status = 'A' ).
              cv_success = 'Y'.
              <ls_vr>-vr_proc_status = 'E'.
              MOVE-CORRESPONDING <ls_vr> TO l_dto_psm_vr.
              mo_ao_appl->create_psm_ao_verrechnung(
                EXPORTING
                  i_psm_ao_verrechnung     =  l_dto_psm_vr     " VErrechnungsanordnung
                IMPORTING
                  e_psm_ao_document_number =  ls_document_number  " Beleg Nummer zu AO
              ).
              <ls_vr>-vr_proc_status = 'S'.
              <ls_vr>-belnr = ls_document_number-belnr.
              <ls_vr>-lotkz = ls_document_number-lotkz.
              IF  <ls_vr>-long_text-lines IS NOT INITIAL.
                "Hinzfügen des Schlüssels für Langtexte.
                "Belegnummer erst nach Buchung im System.
                <ls_vr>-long_text-header-tdname = |{  <ls_vr>-bukrs }{  <ls_vr>-belnr }{  <ls_vr>-gjahr }|.
              ENDIF.
              IF 1 = 0. MESSAGE s823(fq) WITH ls_document_number-lotkz ls_document_number-belnr. ENDIF.
              APPEND VALUE #( id         = 'FQ'
                               number     = 823
                               type       = 'S'
                               message_v1 = ls_document_number-lotkz
                               message_v2 = ls_document_number-belnr ) TO ct_return.
            ENDIF.
          ENDIF.
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_ao).
          IF lx_psm_ao->bapiret2_tab IS NOT INITIAL.
            APPEND LINES OF lx_psm_ao->bapiret2_tab TO ct_return.
          ELSE.
            APPEND VALUE #( id         = lx_psm_ao->if_t100_message~t100key-msgid
                            number     = lx_psm_ao->if_t100_message~t100key-msgno
                            type       = lx_psm_ao->if_t100_dyn_msg~msgty
                            message_v1 = lx_psm_ao->if_t100_dyn_msg~msgv1
                            message_v2 = lx_psm_ao->if_t100_dyn_msg~msgv2
                            message_v3 = lx_psm_ao->if_t100_dyn_msg~msgv3
                            message_v4 = lx_psm_ao->if_t100_dyn_msg~msgv4 ) TO ct_return.
          ENDIF.
          <ls_vr>-vr_proc_status = 'E'.
          cv_success = 'N'.
*"----------------------------------------------------------------------
      ENDTRY.
*----------------------------------------------------------------------
      <ls_vr>-msg = ct_return.
*----------------------------------------------------------------------
    ENDLOOP.

  ENDMETHOD.


  METHOD save_longtext.

*"----------------------------------------------------------------------
    FIELD-SYMBOLS: <ls_longtext> TYPE /thkr/s_aif_longtext.

    "Longtext aus Struktur ermitteln
    ASSIGN COMPONENT 'LONG_TEXT' OF STRUCTURE is_data_struct TO <ls_longtext>.
    IF <ls_longtext> IS ASSIGNED.
      IF <ls_longtext>-lines IS NOT INITIAL.
        "Es gibt Zeilen für Langtexte.
        "Also Speichern.
        CALL FUNCTION 'SAVE_TEXT'
          EXPORTING
*           CLIENT          = SY-MANDT
            header          = <ls_longtext>-header
            insert          = iv_insert
            savemode_direct = 'X'
*           OWNER_SPECIFIED = ' '
*           LOCAL_CAT       = ' '
*           KEEP_LAST_CHANGED       = ' '
*       IMPORTING
*           FUNCTION        =
*           NEWHEADER       =
          TABLES
            lines           = <ls_longtext>-lines
          EXCEPTIONS
            id              = 1
            language        = 2
            name            = 3
            object          = 4
            OTHERS          = 5.
        IF sy-subrc <> 0.
          rv_success = 'N'.
          IF 1 = 0. MESSAGE e064(/thkr/sst) WITH <ls_longtext>-header-tdname.ENDIF.
          APPEND VALUE bapiret2( id = '/THKR/SST'
                       number = 064
                       type = 'E'
                       message_v1 = <ls_longtext>-header-tdname ) TO ct_return.
        ELSE.
          IF 1 = 0. MESSAGE s063(/thkr/sst) WITH <ls_longtext>-header-tdname.ENDIF.
          APPEND VALUE bapiret2( id = '/THKR/SST'
                                 number = 063
                                 type = 'S'
                                 message_v1 = <ls_longtext>-header-tdname ) TO ct_return.
          rv_success = 'Y'.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD upd_ausao_with_kassz_anao.
    "Für Auszahlungsanordnung mit Referenz auf Einnahmesollstellung
    " Es wird aus einem FUA Datensatz sowohl die Annahme- als auch die Auszahlungsanordnung erzeugt
    " Nach Anlage der Annahmeanordnung muss die Referenz in die entsprechende Auszahlungsanordnung geschrieben werden.
    LOOP AT ct_ao ASSIGNING FIELD-SYMBOL(<ls_ausao>)
                       WHERE glblid = is_ao-glblid
                       AND   psoty = 01
                       AND   zlsch = 'X'.
      SELECT SINGLE xblnr
         FROM bkpf
         WHERE bukrs = @is_ao-bukrs
           AND belnr = @is_ao-belnr
           AND gjahr = @is_ao-gjahr
           INTO @<ls_ausao>-bktxt.
    ENDLOOP.
  ENDMETHOD.


  METHOD upd_xref1_hd.
    LOOP AT it_ao ASSIGNING FIELD-SYMBOL(<ls_ao>).
      IF <ls_ao>-ao_proc_status = 'S'.
        "Update nur erlauben, wenn vorher eine erfolgreiche Verarbeitung stattgefunden hat.
        UPDATE bkpf
           SET xref1_hd = <ls_ao>-xref1_hd
         WHERE bukrs = <ls_ao>-bukrs
           AND belnr = <ls_ao>-belnr
           AND gjahr = <ls_ao>-gjahr
           AND lotkz = <ls_ao>-lotkz.

        IF sy-subrc = 0.
          cv_success = 'Y'.
        ELSE.
          cv_success = 'N'.
          IF 1 = 0. MESSAGE e030(/thkr/sst) WITH <ls_ao>-bukrs <ls_ao>-gjahr <ls_ao>-belnr.ENDIF.
          APPEND VALUE bapiret2( id = '/THKR/SST'
                                 number = 030
                                 type = 'E'
                                 message_v1 = <ls_ao>-bukrs
                                 message_v2 = <ls_ao>-gjahr
                                 message_v3 = <ls_ao>-belnr ) TO ct_return.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*& Include          /THKR/TEST
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSST_SAP_DHB_LCL
*&---------------------------------------------------------------------*
**********************************************************************
* CLASS LCL_MAIN [DEFINITION]
**********************************************************************
CLASS lcl_main DEFINITION FINAL.

  PUBLIC SECTION.

    CLASS-METHODS:  load_of_program,

                    at_sel_screen,

                    sel_screen_output,

                    start_of_selection,

                    pbo_1100.

  PRIVATE SECTION.

    TYPES:  BEGIN OF ts_prot,
              gjahr  TYPE gjahr,
              btyp   TYPE zbtyp,
              refbn  TYPE co_refbn,
              fipex  TYPE fm_fipex,
              fistl  TYPE fistl,
              aufkz  TYPE z_aufkz,
              blart  TYPE blart,
              brtwr  TYPE brtwr,
              msgtxt TYPE zmsgtxt,
              color  TYPE zcolor,
              status TYPE icon_d,
              errkz  TYPE ck_error,
            END OF ts_prot.

    TYPES:  BEGIN OF ts_sst_data,
              mandt     TYPE mandt,
              gjahr     TYPE gjahr,
              refbn     TYPE co_refbn,
              fipex     TYPE fm_fipex,
              fistl     TYPE fistl,
              aufkz     TYPE z_aufkz,
              blart     TYPE blart,
              xblnr     TYPE xblnr1,
              btyp      TYPE zbtyp,
              brtwr_sap TYPE brtwr,
              brtwr_dhb TYPE brtwr,
              belnr_dhb TYPE zbelnr,
              exdat     TYPE ltexdate,
            END OF ts_sst_data.

    TYPES:  tr_belnr TYPE RANGE OF belnr_d,
            tr_docnr TYPE RANGE OF bp_docnr,
            tr_kblnr TYPE RANGE OF kblnr,
            tr_ebeln TYPE RANGE OF ebeln,
            tr_cpudt TYPE RANGE OF cpudt,
            tr_aedat TYPE RANGE OF aedat,
            tr_lotkz TYPE RANGE OF pso_lotkz,
            tr_btart TYPE RANGE OF fm_btart.

    TYPES:  ts_feb_data   TYPE ts_sst_data,
            ts_ano_data   TYPE ts_sst_data,
            ts_sst_export TYPE ztpa_s_sap_dhb,
            tt_sst_data   TYPE STANDARD TABLE OF ts_sst_data
                               WITH DEFAULT KEY,
            tt_feb_data   TYPE STANDARD TABLE OF ts_feb_data
                               WITH DEFAULT KEY,
            tt_ano_data   TYPE STANDARD TABLE OF ts_ano_data
                               WITH DEFAULT KEY,
            tt_sst_export TYPE STANDARD TABLE OF ts_sst_export
                               WITH DEFAULT KEY,
            tt_sst_prot   TYPE STANDARD TABLE OF ts_prot
                               WITH DEFAULT KEY.

    TYPES:  BEGIN OF ts_ano_spl.
            INCLUDE TYPE ts_ano_data.
    TYPES:    lotkz   TYPE pso_lotkz,
            END OF ts_ano_spl.

    TYPES:  tt_ano_spl TYPE STANDARD TABLE OF ts_ano_spl
                       WITH DEFAULT KEY.

    TYPES:  tt_bpdj TYPE STANDARD TABLE OF bpdj,
            tt_bpdz TYPE STANDARD TABLE OF bpdz,
            tt_kble TYPE STANDARD TABLE OF kble.

    CONSTANTS:  c_blart_nb TYPE blart VALUE 'NB',
                c_blart_fe TYPE blart VALUE 'FE',
                c_blart_ve TYPE blart VALUE 'VE',
                c_blart_mv TYPE blart VALUE 'MV',
                c_blart_ba TYPE blart VALUE 'BA',
                c_blart_ae TYPE blart VALUE 'AE',
                c_blart_01 TYPE blart VALUE '01',
                c_blart_02 TYPE blart VALUE '02',
                c_blart_03 TYPE blart VALUE '03',
                c_blart_07 TYPE blart VALUE '07',
                c_blart_09 TYPE blart VALUE '09',
                c_blart_10 TYPE blart VALUE '10',
                c_blart_11 TYPE blart VALUE '11',
                c_blart_12 TYPE blart VALUE '12',
                c_blart_13 TYPE blart VALUE '13',
                c_blart_14 TYPE blart VALUE '14',
                c_blart_17 TYPE blart VALUE '17',
                c_blart_18 TYPE blart VALUE '18',
                c_blart_19 TYPE blart VALUE '19',
                c_blart_20 TYPE blart VALUE '20',
                c_blart_21 TYPE blart VALUE '21',
                c_blart_22 TYPE blart VALUE '22',
                c_blart_23 TYPE blart VALUE '23',
                c_blart_24 TYPE blart VALUE '24',
                c_blart_25 TYPE blart VALUE '25',
                c_blart_30 TYPE blart VALUE '30',
                c_blart_31 TYPE blart VALUE '31',
                c_blart_32 TYPE blart VALUE '32',
                c_blart_rn TYPE blart VALUE 'RN',
                c_blart_st TYPE blart VALUE 'ST',
                c_blart_un TYPE blart VALUE 'UN'.

    CONSTANTS:  c_btyp_feb TYPE zbtyp VALUE 'FEB',
                c_btyp_fae TYPE zbtyp VALUE 'FAE',
                c_btyp_auf TYPE zbtyp VALUE 'AUF',
                c_btyp_all TYPE zbtyp VALUE 'ALL',
                c_btyp_aea TYPE zbtyp VALUE 'AEA',
                c_btyp_kor TYPE zbtyp VALUE 'KOR',
                c_btyp_umb TYPE zbtyp VALUE 'UMB',
                c_btyp_sst TYPE zbtyp VALUE 'SST',
                c_btyp_ssr TYPE zbtyp VALUE 'SSR',
                c_btyp_stu TYPE zbtyp VALUE 'STU',
                c_btyp_sab TYPE zbtyp VALUE 'SAB',
                c_btyp_szu TYPE zbtyp VALUE 'SZU',
                c_btyp_aes TYPE zbtyp VALUE 'AES',
                c_btyp_aoe TYPE zbtyp VALUE 'AOE',
                c_btyp_fua TYPE zbtyp VALUE 'FUA',
                c_btyp_ane TYPE zbtyp VALUE 'ANE',
                c_btyp_apu TYPE zbtyp VALUE 'APU',
                c_btyp_epu TYPE zbtyp VALUE 'EPU',
                c_btyp_dao TYPE zbtyp VALUE 'DAO',
                c_btyp_spl TYPE zbtyp VALUE 'SPL',
                c_btyp_mer TYPE zbtyp VALUE 'MER',
                c_btyp_mae TYPE zbtyp VALUE 'MAE'.

    CONSTANTS:  c_errkz_1    TYPE c LENGTH 1 VALUE '1',
                c_ktokd_pers TYPE kna1-ktokd VALUE 'PERS',
                c_sep_name   TYPE c LENGTH 2 VALUE ', '.

    CONSTANTS:  c_refbt_020  TYPE fm_refbtyp VALUE '020',
                c_refbt_110  TYPE fm_refbtyp VALUE '110',
                c_btart_0100 TYPE fm_btart VALUE '0100'.

    CONSTANTS:  c_sst_feb TYPE c LENGTH 3 VALUE 'FEB',
                c_sst_ano TYPE c LENGTH 3 VALUE 'ANO'.

    CONSTANTS:  c_sst_tabn_feb TYPE tabname VALUE 'ZSST_SAP_DHB_FEB',
                c_sst_tabn_ano TYPE tabname VALUE 'ZSST_SAP_DHB_ANO'.

    CONSTANTS:  c_wrttp_43 TYPE co_wrttp VALUE '43',
                c_wrttp_70 TYPE co_wrttp VALUE '70'.

    CONSTANTS:  c_dynnr_1100 TYPE sydynnr VALUE '1100',
                c_ucomm_onli TYPE syucomm VALUE 'ONLI',
                c_ucomm_sjob TYPE syucomm VALUE 'SJOB'.

    CONSTANTS:  c_count      TYPE n LENGTH 3 VALUE '001',
                c_colon      TYPE c LENGTH 1 VALUE ',',
                c_minus      TYPE c LENGTH 1 VALUE '-',
                c_semicolon  TYPE c LENGTH 1 VALUE ';',
                c_point      TYPE c LENGTH 1 VALUE '.',
                c_joker      TYPE c LENGTH 1 VALUE '*',
                c_kz_a       TYPE c LENGTH 1 VALUE 'A',
                c_kz_b       TYPE c LENGTH 1 VALUE 'B',
                c_kz_e       TYPE c LENGTH 1 VALUE 'E',
                c_kz_r       TYPE c LENGTH 1 VALUE 'R',
                c_unkto_00   TYPE c LENGTH 2 VALUE '00',
                c_lifnr_001  TYPE c LENGTH 3 VALUE '001',
                c_bnknr_1    TYPE c LENGTH 1 VALUE '1',
                c_usrkz      TYPE zusrkz VALUE 'KLR_POL',
                c_bnstat_0   TYPE c LENGTH 1 VALUE '0',
                c_dstnr_3101 TYPE c LENGTH 4 VALUE '3101',
                c_verkz_sap  TYPE c LENGTH 3 VALUE 'SAP',
                c_kunnr_cpd  TYPE kunnr VALUE '0000000001'.

    CLASS-DATA:  r_dstl   TYPE RANGE OF fistl,
                 r_eplkap TYPE RANGE OF fm_fipex.

    CLASS-DATA:  v_progr_txt TYPE string,
                 v_path_save TYPE pathintern.

    CLASS-DATA:  ref_help  TYPE REF TO zcl_help_tools,
                 ref_const TYPE REF TO zcl_tpa_const,
                 ref_alv   TYPE REF TO zcl_tpa_alv_grid,
                 ref_expo  TYPE REF TO data,
                 ref_data  TYPE REF TO data.

    CLASS-METHODS:  save_data_tables
                      IMPORTING iv_xsave TYPE xfeld
                                iv_gjahr TYPE gjahr,

                    delete_saved_tables
                      IMPORTING iv_xdele TYPE xfeld
                                iv_datum TYPE datum,

                    read_fi_data
                      IMPORTING iv_bukrs  TYPE bukrs
                                iv_gjahr  TYPE gjahr
                                iv_xerror TYPE xfeld
                                ir_belnr  TYPE tr_belnr
                                ir_bkpdt  TYPE tr_cpudt
                      RETURNING VALUE(rt_data) TYPE tt_ano_data,

                    read_ao_data
                      IMPORTING iv_bukrs TYPE bukrs
                                iv_gjahr TYPE gjahr
                                iv_xinit TYPE xfeld
                                ir_lotkz TYPE tr_lotkz
                                ir_psodt TYPE tr_cpudt
                      RETURNING VALUE(rt_data) TYPE tt_ano_data,

                    read_me_data
                      IMPORTING iv_gjahr TYPE gjahr
                                iv_xgjw  TYPE xfeld
                                iv_xinit TYPE xfeld
                                ir_ebeln TYPE tr_ebeln
                                ir_aedat TYPE tr_aedat
                      RETURNING VALUE(rt_data) TYPE tt_feb_data,

                    read_mb_data
                      IMPORTING iv_gjahr TYPE gjahr OPTIONAL
                                iv_xgjw  TYPE xfeld
                                iv_xinit TYPE xfeld
                                ir_kblnr TYPE tr_kblnr
                                ir_kbldt TYPE tr_cpudt
                      RETURNING VALUE(rt_data) TYPE tt_feb_data,

                    read_aa_data
                      IMPORTING ir_aaonr TYPE tr_kblnr
                                ir_kbldt TYPE tr_cpudt
                      RETURNING VALUE(rt_data) TYPE tt_feb_data,

                    read_mv_data
                      IMPORTING ir_docnr TYPE tr_docnr
                                ir_bpddt TYPE tr_aedat
                      RETURNING VALUE(rt_data) TYPE tt_ano_data,

*&---------------------------------------------------------------------*
                    build_export_data
                      IMPORTING iv_gjahr    TYPE gjahr       OPTIONAL
                                iv_xerror   TYPE xfeld
                                iv_xeowi    TYPE xfeld       OPTIONAL
                                iv_xsepa    TYPE xfeld       OPTIONAL
                                it_feb_data TYPE tt_feb_data OPTIONAL
                                it_ano_data TYPE tt_ano_data OPTIONAL
                      EXPORTING et_export   TYPE tt_sst_export         "BIC
                                et_prot     TYPE tt_sst_prot,
*&---------------------------------------------------------------------*
                    maintain_data_xgjw
                      IMPORTING iv_xgjw     TYPE xfeld
                                iv_gjahr    TYPE gjahr
                                it_feb_data TYPE tt_feb_data
                       CHANGING ct_export   TYPE tt_sst_export
                                ct_prot     TYPE tt_sst_prot,

                    create_save_files
                      IMPORTING iv_xtest  TYPE xfeld
                                it_export TYPE tt_sst_export
                       CHANGING ct_prot   TYPE tt_sst_prot,

                    read_document_data
                      IMPORTING iv_bukrs  TYPE bukrs OPTIONAL
                                iv_gjahr  TYPE gjahr OPTIONAL
                                iv_refbn  TYPE any
                                iv_blart  TYPE blart
                                iv_lotkz  TYPE pso_lotkz OPTIONAL
                                iv_butyp  TYPE zbtyp     OPTIONAL
                      EXPORTING es_ekko   TYPE ekko
                                es_kblk   TYPE kblk
                                et_ekpo   TYPE meout_t_ekpo
                                et_ekkn   TYPE meout_t_ekkn
                                et_kbld   TYPE fm_t_kbld
                                et_kble   TYPE tt_kble
                                et_bpdj   TYPE tt_bpdj
                                et_bpdz   TYPE tt_bpdz
                                et_pso02  TYPE fm_pso02
                                et_pso02s TYPE fm_pso02s
                                et_pssec  TYPE fm_bsec,

                    build_pso_from_document
                      IMPORTING is_bkpf   TYPE bkpf
                      EXPORTING et_pso02  TYPE fm_pso02
                                et_pso02s TYPE fm_pso02s
                                et_pssec  TYPE fm_bsec,

                    get_fmioi_values
                      IMPORTING iv_refbt TYPE fm_refbtyp
                                iv_refbn TYPE co_refbn
                                iv_rfpos TYPE cc_rfpos
                                iv_rfknt TYPE cc_rfknt OPTIONAL
                                iv_gjahr TYPE gjahr    OPTIONAL
                                iv_gnjhr TYPE gjahr    OPTIONAL
                                ir_btart TYPE tr_btart OPTIONAL
                      RETURNING VALUE(rv_brtwr) TYPE brtwr,

                    get_aufkz_btyp
                      IMPORTING iv_sst_type TYPE char3
                                is_sst_data TYPE ts_sst_data
                      EXPORTING ev_btyp     TYPE zbtyp
                                es_sst_save TYPE ts_sst_data,

                    read_changes
                      IMPORTING iv_objcl TYPE cdobjectcl
                                iv_objid TYPE cdobjectv
                      RETURNING VALUE(rt_cdred) TYPE sa_cdred_t,

                    get_epl_number
                      IMPORTING iv_xtest TYPE xfeld
                                iv_eplan TYPE zepl
                      RETURNING VALUE(rv_number) TYPE p011_dfnum,

                    check_existence
                      IMPORTING it_feb_data TYPE tt_feb_data
                      RETURNING VALUE(rt_feb_dele) TYPE tt_feb_data,

                    read_reference_data
                      IMPORTING iv_bukrs TYPE bukrs
                                iv_belnr TYPE belnr_d
                                iv_gjahr TYPE gjahr
                                iv_zuonr TYPE dzuonr
                                iv_blart TYPE blart
                                iv_xeowi TYPE xfeld OPTIONAL
                      RETURNING VALUE(rv_wrbtr) TYPE wrbtr,

                    create_kassz
                      IMPORTING iv_fistl TYPE fistl
                      RETURNING VALUE(rv_kassz) TYPE xblnr1,

                    update_kassz
                      IMPORTING iv_bukrs TYPE bukrs
                                iv_belnr TYPE belnr_d
                                iv_gjahr TYPE gjahr
                                iv_xblnr TYPE xblnr1,

                    check_btyp
                      IMPORTING it_pso02s TYPE fm_pso02s OPTIONAL
                                it_kbld   TYPE fm_t_kbld OPTIONAL
                       CHANGING cv_btyp   TYPE zbtyp,

                    get_iban_swift_data
                      IMPORTING iv_banks  TYPE banks
                                iv_bankl  TYPE bankk
                                iv_bankn  TYPE bankn
                                iv_bkont  TYPE bkont
                      EXPORTING es_iban   TYPE tiban
                                es_bnka   TYPE bnka,

                    build_bic_key
                      IMPORTING iv_swift  TYPE swift
                      RETURNING VALUE(rv_biczp) TYPE a9_fr,

                    get_txtsl
                      IMPORTING iv_awkey TYPE awkey
                                iv_ebeln TYPE ebeln
                                iv_fistl TYPE fistl
                                iv_fipex TYPE fm_fipex
                      RETURNING VALUE(rv_txtsl) TYPE char2,

                    check_mb_fae
                      IMPORTING is_ano_data TYPE ts_ano_data
                                iv_xblnr    TYPE xblnr1
                       CHANGING cref_export TYPE REF TO data
                                ct_feb_save TYPE tt_feb_data,

                    reduce_mb
                      IMPORTING is_ano_data TYPE ts_ano_data
                                iv_xblnr    TYPE xblnr1
                                iv_txtsl    TYPE char2
                       CHANGING ct_feb_save TYPE tt_feb_data,

                    compare_me_mb_data
                      IMPORTING it_me_data  TYPE tt_feb_data
                      EXPORTING et_export   TYPE tt_sst_export
                       CHANGING ct_feb_save TYPE tt_feb_data,

                    map_feb_data
                      IMPORTING iv_btyp    TYPE zbtyp
                                iv_gjahr   TYPE gjahr        OPTIONAL
                                is_data    TYPE ts_feb_data
                                it_ekpo    TYPE meout_t_ekpo
                                it_ekkn    TYPE meout_t_ekkn
                                it_kbld    TYPE fm_t_kbld
                      RETURNING VALUE(rs_export) TYPE ts_sst_export,

                    map_fae_data
                      IMPORTING iv_btyp    TYPE zbtyp
                                iv_gjahr   TYPE gjahr        OPTIONAL
                                iv_diff    TYPE wrbtr        OPTIONAL
                                is_data    TYPE ts_feb_data
                                it_ekpo    TYPE meout_t_ekpo OPTIONAL
                                it_ekkn    TYPE meout_t_ekkn OPTIONAL
                                it_kbld    TYPE fm_t_kbld    OPTIONAL
                      RETURNING VALUE(rs_export) TYPE ts_sst_export,

                    map_auf_data
                      IMPORTING iv_btyp  TYPE zbtyp
                                is_data  TYPE ts_ano_data
                                it_bpdj  TYPE tt_bpdj
                                it_bpdz  TYPE tt_bpdz
                      RETURNING VALUE(rs_export) TYPE ts_sst_export,
*&---------------------------------------------------------------------*
                    map_sst_data
                      IMPORTING iv_btyp   TYPE zbtyp
                                is_data   TYPE ts_ano_data
                                it_pso02  TYPE fm_pso02
                                it_pssec  TYPE fm_bsec
                      RETURNING VALUE(rs_export) TYPE ts_sst_export,
*&---------------------------------------------------------------------*
                    map_sab_szu_data
                      IMPORTING iv_btyp   TYPE zbtyp
                                iv_xeowi  TYPE xfeld OPTIONAL
                                is_data   TYPE ts_ano_data
                                it_pso02  TYPE fm_pso02
                                it_pssec  TYPE fm_bsec
                      RETURNING VALUE(rs_export) TYPE ts_sst_export,

                    map_aes_data
                      IMPORTING iv_btyp   TYPE zbtyp
                                iv_xeowi  TYPE xfeld OPTIONAL
                                is_data   TYPE ts_ano_data
                                it_pso02  TYPE fm_pso02
                                it_pssec  TYPE fm_bsec
                      RETURNING VALUE(rs_export) TYPE ts_sst_export,

                    map_stu_data
                      IMPORTING iv_btyp   TYPE zbtyp
                                is_data   TYPE ts_ano_data
                                it_pso02  TYPE fm_pso02
                                it_pso02s TYPE fm_pso02s
                      RETURNING VALUE(rs_export) TYPE ts_sst_export,

                    map_apu_epu_data
                      IMPORTING iv_btyp   TYPE zbtyp
                                is_data   TYPE ts_ano_data
                                it_pso02  TYPE fm_pso02
                                it_pso02s TYPE fm_pso02s
                      RETURNING VALUE(rs_export) TYPE ts_sst_export,

                    map_dao_data
                      IMPORTING is_data   TYPE ts_ano_data
                                it_pso02  TYPE fm_pso02
                                it_pssec  TYPE fm_bsec
                      RETURNING VALUE(rs_export) TYPE ts_sst_export,

                    map_ane_data
                      IMPORTING iv_btyp   TYPE zbtyp
                                iv_x_spl  TYPE xfeld DEFAULT abap_off
                                is_data   TYPE ts_ano_data
                                it_pso02  TYPE fm_pso02
                                it_pso02s TYPE fm_pso02s
                                it_pssec  TYPE fm_bsec
                      RETURNING VALUE(rs_export) TYPE ts_sst_export,

                    map_fua_data
                      IMPORTING iv_btyp   TYPE zbtyp
                                is_data   TYPE ts_ano_data
                                it_ano    TYPE tt_ano_data
                                it_pso02  TYPE fm_pso02
                                it_pso02s TYPE fm_pso02s
                                it_pssec  TYPE fm_bsec
                      RETURNING VALUE(rs_export) TYPE ts_sst_export,

                    map_kor_data
                      IMPORTING iv_btyp   TYPE zbtyp
                                iv_refspl TYPE text20 OPTIONAL
                                is_data   TYPE ts_ano_data
                                it_pso02  TYPE fm_pso02
                                it_pso02s TYPE fm_pso02s
                      RETURNING VALUE(rs_export) TYPE ts_sst_export,

                    map_all_data
                      IMPORTING iv_btyp    TYPE zbtyp
                                is_data    TYPE ts_ano_data
                                it_pso02   TYPE fm_pso02
                                it_pssec   TYPE fm_bsec
                      RETURNING VALUE(rs_export) TYPE ts_sst_export,

                    map_mer_mae_data
                      IMPORTING iv_btyp   TYPE zbtyp
                                is_data   TYPE ts_ano_data
                                it_pso02  TYPE fm_pso02
                                it_pssec  TYPE fm_bsec
                      RETURNING VALUE(rs_export) TYPE ts_sst_export,

                    check_changes_mandat
                      IMPORTING is_pso02 TYPE pso02
                       CHANGING cv_btyp  TYPE zbtyp.

ENDCLASS.                   "LCL_MAIN DEFINITION

**********************************************************************
* CLASS LCL_MAIN [IMPLEMENTATION]
**********************************************************************
CLASS lcl_main IMPLEMENTATION.
*----------------------------------------------------------------------*
* Methode LOAD_OF_PROGRAM
*----------------------------------------------------------------------*
METHOD load_of_program.

* lokale Datendeklaration
  CONSTANTS: lc_path_ent TYPE pathintern VALUE 'Z_SST_AUSTAUSCH',
             lc_path_qas TYPE pathintern VALUE 'Z_SST_HAMTRANS_Q',
             lc_path_prd TYPE pathintern VALUE 'Z_SST_HAMTRANS'.

  DATA: l_range_value TYPE string.

  DATA: lr_datum TYPE RANGE OF datum.

  DATA: lt_dstl     TYPE STANDARD TABLE OF zdkw_sap_fistl,
        lt_epl_kap  TYPE STANDARD TABLE OF ztpa_sst_epl_kap,
        ls_dstl     LIKE LINE OF lt_dstl,
        ls_epl_kap  LIKE LINE OF lt_epl_kap,
        ls_sst_path TYPE ztpa_bc_sst_path.

* Instanzen der Klassen erzeugen
  ref_help = NEW #( ). ref_const = NEW #( ).

* Vorbelegung von Parametern
  MOVE ref_const->c_bukrs_1000 TO pa_bukrs.

  IF lines( so_cpudt ) IS INITIAL.
    ref_help->set_range_value( EXPORTING iv_value_low = sy-datum
                                CHANGING ct_range     = lr_datum ).

    APPEND LINES OF lr_datum TO: so_cpudt.
  ENDIF.

* Ermitteln der zulässigen Dienststellen, Einzelpläne und Kapitel
  SELECT * FROM zdkw_sap_fistl INTO TABLE lt_dstl.
  SELECT * FROM ztpa_sst_epl_kap INTO TABLE lt_epl_kap.

* Ranges zusammensetzen
*-- Dienststellen
    LOOP AT lt_dstl INTO ls_dstl.
      CONCATENATE ls_dstl-dstl c_joker INTO l_range_value.
      ref_help->set_range_value( EXPORTING iv_value_low = l_range_value
                                  CHANGING ct_range     = r_dstl ).
    ENDLOOP.

*-- Einzelplan und Kapitel
    LOOP AT lt_epl_kap INTO ls_epl_kap.
      CONCATENATE ls_epl_kap-epl ls_epl_kap-kap c_joker
             INTO l_range_value.
      ref_help->set_range_value( EXPORTING iv_value_low = l_range_value
                                  CHANGING ct_range     = r_eplkap ).
    ENDLOOP.

* Vorbelegung Parameter Dateipfad
  SELECT SINGLE * FROM ztpa_bc_sst_path
                  INTO ls_sst_path
                 WHERE repid EQ sy-repid AND
                       sysid EQ sy-sysid.
  IF sy-subrc IS INITIAL.
    MOVE ls_sst_path-path_src TO v_path_save.
  ELSE.
    CASE sy-sysid.
*---- Entwicklungssystem
      WHEN ref_const->c_sysid_ent OR ref_const->c_sysid_pze.
        MOVE lc_path_ent TO v_path_save.
*---- Qualitätssicherungssystem
      WHEN ref_const->c_sysid_qas OR ref_const->c_sysid_pzq.
        MOVE lc_path_qas TO v_path_save.
*---- Produktivsystem
      WHEN ref_const->c_sysid_prd OR ref_const->c_sysid_pzp.
        MOVE lc_path_prd TO v_path_save.
*---- andere Systeme
      WHEN OTHERS.
        MOVE lc_path_ent TO v_path_save.
    ENDCASE.
  ENDIF.

ENDMETHOD.                    "load_of_program


*----------------------------------------------------------------------*
* Methode AT_SEL_SCREEN
*----------------------------------------------------------------------*
METHOD at_sel_screen.

* lokale Datendeklaration
  DATA: l_ucomm TYPE syucomm.

* Abfangen User-Command
  l_ucomm = sy-ucomm.

  CASE l_ucomm.
*-- Onlineverarbeitung
    WHEN c_ucomm_onli.
      IF pa_xgjw EQ abap_on.
        IF lines( so_ebeln ) IS INITIAL AND
           lines( so_kblnr ) IS INITIAL.
          MESSAGE e512(>3).
        ENDIF.
      ELSE.
        IF pa_gjahr IS INITIAL.
          MESSAGE e224(fi).
        ENDIF.
      ENDIF.
*-- Hintergrundverarbeitung
    WHEN c_ucomm_sjob.
      IF pa_xgjw EQ abap_on.
        IF lines( so_ebeln ) IS INITIAL AND
           lines( so_kblnr ) IS INITIAL.
          MESSAGE e512(>3).
        ENDIF.
      ELSE.
        IF pa_gjahr IS INITIAL.
          MESSAGE e224(fi).
        ENDIF.
      ENDIF.

  ENDCASE.

ENDMETHOD.                    "at_sel_screen


*----------------------------------------------------------------------*
* Methode SEL_SCREEN_OUTPUT
*----------------------------------------------------------------------*
METHOD sel_screen_output.

* lokale Datendeklaration
  CONSTANTS: lc_assign  TYPE string VALUE '(&1)&2',
             lc_len_8   TYPE i VALUE 8.

  DATA: l_assign TYPE string,
        l_len    TYPE i.

  FIELD-SYMBOLS: <fval> TYPE any.

* Bildschirmanpassungen
  LOOP AT SCREEN.
    l_len = strlen( screen-name ).
*-- keine Eingabemöglichkeit
    IF screen-group1 EQ 'NIP'.
      screen-input = 0.
    ENDIF.
*-- keine Anzeige
    IF screen-group1 EQ 'NDP'.
      IF pa_xgjw EQ abap_on.
        l_assign = lc_assign.
        REPLACE: '&1' WITH sy-repid INTO l_assign,
                 '&2' WITH screen-name INTO l_assign.
        CONDENSE l_assign NO-GAPS.
        ASSIGN (l_assign) TO <fval>.
        IF sy-subrc IS INITIAL AND l_len LE lc_len_8.
          CLEAR <fval>.
        ENDIF.
        screen-active = 0.
      ENDIF.
    ENDIF.
*-- Geschäftsjahreswechsel
    IF screen-group1 EQ 'GJW'.
      IF pa_xgjw EQ abap_on.
        CLEAR: pa_gjahr, so_cpudt, so_cpudt[].
        pa_gjahr = sy-datum(4) + 1.
        screen-input = 0.
      ELSE.
        screen-required = 2.

        IF lines( so_cpudt ) IS INITIAL.
          IF pa_xerr EQ abap_on.
            CLEAR so_cpudt. REFRESH so_cpudt.
          ELSE.
            ref_help->set_range_value(
                        EXPORTING iv_value_low = sy-datum
                         CHANGING ct_range     = so_cpudt[] ).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY SCREEN. CLEAR screen.
  ENDLOOP.

ENDMETHOD.                    "sel_screen_output


*----------------------------------------------------------------------*
* Methode START_OF_SELECTION
*----------------------------------------------------------------------*
METHOD start_of_selection.
*----------------------------------------------------------------------*
* lokale Datendeklaration
  DATA: lt_me_data  TYPE tt_feb_data,
        lt_mb_data  TYPE tt_feb_data,
        lt_mv_data  TYPE tt_ano_data,
        lt_fi_data  TYPE tt_ano_data,
        lt_ao_data  TYPE tt_ano_data,
        lt_aa_data  TYPE tt_ano_data.

  DATA: ls_ao_data LIKE LINE OF lt_ao_data.

  DATA: lt_ano_data   TYPE tt_ano_data,
        lt_feb_data   TYPE tt_feb_data,
        lt_sst_export TYPE tt_sst_export,
        lt_sst_prot   TYPE tt_sst_prot.

  STATICS: st_sst_prot   TYPE tt_sst_prot,
           st_sst_export TYPE tt_sst_export.

  FIELD-SYMBOLS: <s_prot> LIKE LINE OF lt_sst_prot.

* Sicherung der Tabellen
  save_data_tables( iv_xsave = pa_xsave
                    iv_gjahr = pa_gjahr ).

* ggf. alte Sicherungsdateien löschen
  delete_saved_tables( iv_xdele = pa_xdele
                       iv_datum = sy-datum ).
*----------------------------------------------------------------------*
* Daten der FI-Belege lesen
  IF pa_xfib EQ abap_on.
    lt_fi_data = read_fi_data( iv_bukrs  = pa_bukrs
                               iv_gjahr  = pa_gjahr
                               iv_xerror = pa_xerr
                               ir_belnr  = so_belnr[]
                               ir_bkpdt  = so_cpudt[] ).
    APPEND LINES OF lt_fi_data TO lt_ano_data.
  ENDIF.
*----------------------------------------------------------------------*
* Daten der Daueranordnungen lesen
  IF pa_xdab EQ abap_on.
    lt_ao_data = read_ao_data( iv_bukrs = pa_bukrs
                               iv_gjahr = pa_gjahr
                               iv_xinit = pa_xinit
                               ir_lotkz = so_lotkz[]
                               ir_psodt = so_cpudt[] ).
*-- Sonderfall Dauerauszahlung sind als FEB-Daten zu übergeben
    LOOP AT lt_ao_data INTO ls_ao_data.
      CASE ls_ao_data-blart.
        WHEN c_blart_02.
          APPEND ls_ao_data TO lt_ano_data.
        WHEN c_blart_12 OR c_blart_fe.
          APPEND ls_ao_data TO lt_feb_data.
      ENDCASE.
    ENDLOOP.
  ENDIF.
*----------------------------------------------------------------------*
* Daten der Mittelverteilung lesen
  IF pa_xmvb EQ abap_on.
    lt_mv_data = read_mv_data( ir_docnr = so_docnr[]
                               ir_bpddt = so_cpudt[] ).
    APPEND LINES OF lt_mv_data TO lt_ano_data.
  ENDIF.
*----------------------------------------------------------------------*
* Daten der Mittelbindungen (FEB) lesen
  IF pa_xmbb EQ abap_on.
    lt_mb_data = read_mb_data( iv_gjahr = pa_gjahr
                               iv_xgjw  = pa_xgjw
                               iv_xinit = pa_xinit
                               ir_kblnr = so_kblnr[]
                               ir_kbldt = so_cpudt[] ).
    APPEND LINES OF lt_mb_data TO lt_feb_data.
  ENDIF.
*----------------------------------------------------------------------*
* Daten der allg. Anordnungen lesen
  IF pa_xaao EQ abap_on.
    lt_aa_data = read_aa_data( ir_aaonr = so_aabln[]
                               ir_kbldt = so_cpudt[] ).
    APPEND LINES OF lt_aa_data TO lt_ano_data.
  ENDIF.
*----------------------------------------------------------------------*
* Daten der Bestellungen lesen
  IF pa_xmeb EQ abap_on.
    lt_me_data = read_me_data( iv_gjahr = pa_gjahr
                               iv_xgjw  = pa_xgjw
                               iv_xinit = pa_xinit
                               ir_ebeln = so_ebeln[]
                               ir_aedat = so_cpudt[] ).
    APPEND LINES OF lt_me_data TO lt_feb_data.
  ENDIF.
*----------------------------------------------------------------------*
* Festlegungen verarbeiten, Ausgabestruktur erzeugen
  build_export_data( EXPORTING iv_gjahr    = pa_gjahr
                               iv_xerror   = pa_xerr
                               iv_xsepa    = pa_xsepa
                               it_feb_data = lt_feb_data
                     IMPORTING et_export   = lt_sst_export
                               et_prot     = lt_sst_prot ).
*----------------------------------------------------------------------*
* Anpassungen für Jahreswechsel vornehmen
  maintain_data_xgjw( EXPORTING iv_xgjw     = pa_xgjw
                                iv_gjahr    = pa_gjahr
                                it_feb_data = lt_feb_data
                       CHANGING ct_export   = lt_sst_export
                                ct_prot     = lt_sst_prot ).

  APPEND LINES OF: lt_sst_export TO st_sst_export,
                   lt_sst_prot   TO st_sst_prot.
  ref_expo = REF #( st_sst_export ).
  CLEAR: lt_sst_export, lt_sst_prot.
*----------------------------------------------------------------------*
* Anordnungen verarbeiten
  build_export_data( EXPORTING iv_xerror   = pa_xerr
                               iv_xeowi    = pa_xeowi
                               iv_xsepa    = pa_xsepa
                               it_ano_data = lt_ano_data
                     IMPORTING et_export   = lt_sst_export
                               et_prot     = lt_sst_prot ).
  APPEND LINES OF: lt_sst_export TO st_sst_export,
                   lt_sst_prot   TO st_sst_prot.
  ref_expo = REF #( st_sst_export ).
  CLEAR: lt_sst_export, lt_sst_prot.
*----------------------------------------------------------------------*
* Daten auf Applikationsserver sichern
  create_save_files( EXPORTING iv_xtest  = pa_xtest
                               it_export = st_sst_export
                      CHANGING ct_prot   = st_sst_prot ).
*----------------------------------------------------------------------*
* Icon setzen und Protokoll ausgeben
  LOOP AT st_sst_prot ASSIGNING <s_prot>.
    CASE <s_prot>-color.
      WHEN ref_const->c_color_green.
        <s_prot>-status = icon_led_green.
      WHEN ref_const->c_color_yellow.
        <s_prot>-status = icon_led_yellow.
      WHEN ref_const->c_color_red.
        <s_prot>-status = icon_led_red.
        <s_prot>-errkz  = abap_on.
    ENDCASE.
  ENDLOOP.

  ref_data = REF #( st_sst_prot ).
  CALL SCREEN c_dynnr_1100.
*----------------------------------------------------------------------*
ENDMETHOD.                    "start_of_selection


*----------------------------------------------------------------------*
* Methode PBO_1100
*----------------------------------------------------------------------*
METHOD pbo_1100.

* lokale Datendeklaration
  DATA: l_struc   TYPE ts_prot,
        l_coltxt  TYPE lvc_txtcol,
        lref_cont TYPE REF TO cl_gui_custom_container.

* Status und Titel setzen
  SET: PF-STATUS 'ST_LIST',
       TITLEBAR 'TI_LIST'.

* Instanz der Klasse 'ZCL_TPA_ALV_GRID' erzeugen
  IF ref_alv IS NOT BOUND.
*-- im Offline-Modus keine GUI-Controls erzeugen
    IF cl_gui_alv_grid=>offline( ) IS INITIAL.

      CREATE OBJECT lref_cont
        EXPORTING   container_name = 'CTR_ALV'
                    lifetime       = lref_cont->lifetime_dynpro
        EXCEPTIONS  OTHERS         = 3.

      IF NOT sy-subrc IS INITIAL.
        RETURN.
      ENDIF.
    ENDIF.

    CREATE OBJECT ref_alv
      EXPORTING   iref_container = lref_cont
                  is_structure   = l_struc
      EXCEPTIONS  OTHERS         = 3.

    IF NOT sy-subrc IS INITIAL.
      RETURN.
    ENDIF.

*-- Layoutstruktur anpassen
    ref_alv->set_zebra( ).
    ref_alv->set_no_rowmark( ).
    ref_alv->set_opt_colwidth( ).
    ref_alv->set_row_color( l_struc-color ).

*-- Feldkatalog anpassen
    ref_alv->set_sortierung( iv_feld         = l_struc-errkz
                             iv_reihenfolge  = 1
                             iv_absteigend   = abap_on ).
    ref_alv->set_sortierung( iv_feld         = l_struc-refbn
                             iv_reihenfolge  = 2 ).
    ref_alv->set_sortierung( iv_feld         = l_struc-fistl
                             iv_reihenfolge  = 3 ).
    ref_alv->set_sortierung( iv_feld         = l_struc-fipex
                             iv_reihenfolge  = 4 ).

    ref_alv->set_fcat_sum( l_struc-brtwr ).
    ref_alv->set_fcat_tech( l_struc-color ).
    ref_alv->set_fcat_checkbox( l_struc-errkz ).
    ref_alv->set_fcat_no_output( l_struc-errkz ).
    ref_alv->set_fcat_icon( l_struc-status ).

    l_coltxt = TEXT-sta.
    ref_alv->set_fcat_texte( iv_feld    = l_struc-status
                             iv_coltext = l_coltxt ).

*-- Ausgabe der Tabelle Protokolltabelle
    ref_alv->display( CHANGING cref_outtab = ref_data ).

  ELSE.
    ref_alv->refresh( ).
  ENDIF.

ENDMETHOD.                                                "pbo_1100


*----------------------------------------------------------------------*
* Methode SAVE_DATA_TABLES
*----------------------------------------------------------------------*
METHOD save_data_tables.

* lokale Datendeklaration
  CONSTANTS: lc_path_save TYPE pathintern VALUE 'Z_SST_SAVE',
             lc_separate  TYPE c LENGTH 1 VALUE '|',
             lc_uline     TYPE c LENGTH 1 VALUE '_',
             lc_exten     TYPE sign_stype VALUE '.txt'.

  DATA: l_file      TYPE localfile,
        l_tabname   TYPE tabname.

  DATA: lt_ano_data TYPE tt_ano_data,
        lt_feb_data TYPE tt_feb_data,
        lt_save     TYPE tt_sst_data.

* Prüfen, ob gesichert werden soll
  CHECK iv_xsave EQ abap_on AND
  ( sy-sysid EQ ref_const->c_sysid_pzp OR
    sy-sysid EQ ref_const->c_sysid_prd ).

* Daten aus Tabellen ermitteln
  SELECT * FROM (c_sst_tabn_feb) INTO TABLE lt_feb_data
          WHERE gjahr EQ iv_gjahr.

  SELECT * FROM (c_sst_tabn_ano) INTO TABLE lt_ano_data
          WHERE gjahr EQ iv_gjahr.

* Daten auf Applikationserver schreiben
  DO 2 TIMES.
    CASE sy-index.
      WHEN '1'.
        lt_save = lt_ano_data.
        l_tabname = c_sst_tabn_ano.
      WHEN '2'.
        lt_save = lt_feb_data.
        l_tabname = c_sst_tabn_feb.
    ENDCASE.

    CONCATENATE sy-datum sy-uzeit lc_uline
                l_tabname lc_exten INTO l_file.

*-- Datei auf Appl.server ablegen
    ref_help->write_itab_to_applsrv(
                EXPORTING   iv_struc     = l_tabname
                            iv_path      = lc_path_save
                            iv_file      = l_file
                            iv_separate  = lc_separate
                            it_data      = lt_save
                EXCEPTIONS  OTHERS       = 2 ).

    IF NOT sy-subrc IS INITIAL.
      MESSAGE e153(14) WITH l_file
                       DISPLAY LIKE ref_const->c_msgty_w.
    ENDIF.

    CLEAR lt_save.
  ENDDO.

ENDMETHOD.                    "save_data_tables


*----------------------------------------------------------------------*
* Methode DELETE_SAVED_TABLES
*----------------------------------------------------------------------*
METHOD delete_saved_tables.

* lokale Datendeklaration
  CONSTANTS: lc_path_dele TYPE pathintern VALUE 'Z_SST_SAVE',
             lc_val_back  TYPE i VALUE 30,
             lc_number    TYPE c LENGTH 10 VALUE '0123456789'.

  DATA: l_deldat   TYPE datum,
        l_filename TYPE localfile,
        l_filepath TYPE pathintern,
        l_length   TYPE i,
        lr_dldat   TYPE RANGE OF datum.

  DATA: lt_files TYPE STANDARD TABLE OF eps2fili,
        ls_files LIKE LINE OF lt_files.

* Prüfen, ob gelöscht werden soll
  CHECK iv_xdele EQ abap_on.

* alle Daten löschen, die älter als 30 Tage sind
  l_deldat = iv_datum - lc_val_back.
  ref_help->set_range_value(
              EXPORTING iv_value_low = l_deldat
                        iv_option    = ref_const->c_option_le
               CHANGING ct_range     = lr_dldat ).

* Daten aus Verzeichnis einlesen
  lt_files = ref_help->read_directory_local( lc_path_dele ).

* Dateien enthalten Datum; prüfen und Datei ggf. löschen
  LOOP AT lt_files INTO ls_files.
    DESCRIBE FIELD l_deldat LENGTH l_length IN CHARACTER MODE.
    l_deldat = ls_files-name(l_length).
    IF l_deldat CO lc_number.
      IF l_deldat IN lr_dldat.
        l_filename = ls_files-name.
        l_filepath = lc_path_dele.

        ref_help->delete_appl_file( im_file = l_filename
                                    im_path = l_filepath ).

      ENDIF.
    ENDIF.
    CLEAR: l_deldat, l_filename, l_filepath.
  ENDLOOP.

ENDMETHOD.


*----------------------------------------------------------------------*
* Methode READ_FI_DATA
*----------------------------------------------------------------------*
METHOD read_fi_data.

* lokale Datendeklaration
  CONSTANTS: lc_bstat_init TYPE bstat_d VALUE IS INITIAL,
             lc_stblg_init TYPE stblg VALUE IS INITIAL,
             lc_awkey_init TYPE awkey VALUE IS INITIAL,
             lc_awtyp_rmrp TYPE awtyp VALUE 'RMRP',
             lc_psosg_1    TYPE psosg VALUE '1',
             lc_psosg_4    TYPE psosg VALUE '4',
             lc_stgrd_z3   TYPE stgrd VALUE 'Z3',
             lc_stgrd_z4   TYPE stgrd VALUE 'Z4',
             lc_xblnr_37   TYPE char2 VALUE '37',
             lc_xblnr_38   TYPE char2 VALUE '38',
             lc_xblnr_num  TYPE char10 VALUE '0123456789',
             lc_value_4    TYPE char1 VALUE '4',
             lc_wrbtr_init TYPE wrbtr VALUE IS INITIAL.

  CONSTANTS: lc_usnam_finbat TYPE xubname VALUE 'FINBAT',
             lc_usnam_dogro  TYPE xubname VALUE 'DOGRO'.

  TYPES: BEGIN OF ts_header,
           bukrs TYPE bukrs,
           belnr TYPE belnr_d,
           blart TYPE blart,
           cpudt TYPE cpudt,
           xblnr TYPE xblnr1,
           lotkz TYPE pso_lotkz,
           tcode TYPE tcode,
           awtyp TYPE awtyp,
           awkey TYPE awkey,
           zuonr TYPE dzuonr,
           wrbtr TYPE wrbtr,
         END OF ts_header.

  DATA: l_belnr TYPE belnr_d,
        l_gjahr TYPE gjahr,
        l_awkey TYPE awkey,
        l_len   TYPE i,
        l_x_apu TYPE xfeld,
        l_x_epu TYPE xfeld.

  DATA: lr_blart TYPE RANGE OF blart,
        lr_psosg TYPE RANGE OF psosg,
        lr_xblnr TYPE RANGE OF xblnr1,
        lr_usnam TYPE RANGE OF xubname.

  DATA: lt_header TYPE STANDARD TABLE OF ts_header,
        lt_memo   TYPE STANDARD TABLE OF ts_header,
        lt_stundg TYPE STANDARD TABLE OF ts_header,
        lt_save   TYPE tt_ano_data,
        ls_header LIKE LINE OF lt_header,
        ls_search LIKE LINE OF lt_header,
        ls_memo   LIKE LINE OF lt_memo.

  DATA: ls_rbkp   TYPE rbkp,
        ls_bkpf   TYPE bkpf,
        lt_pso02  TYPE fm_pso02,
        lt_pso02s TYPE fm_pso02s,
        ls_pso02  LIKE LINE OF lt_pso02,
        ls_pso02s LIKE LINE OF lt_pso02s.

  FIELD-SYMBOLS: <s_save>    LIKE LINE OF lt_save,
                 <s_memo>    LIKE LINE OF lt_memo,
                 <s_collect> LIKE LINE OF rt_data.

* Range der zulässigen Belegarten füllen
  ref_help->set_range_value( EXPORTING iv_value_low  = c_blart_01
                              CHANGING ct_range      = lr_blart ).
  ref_help->set_range_value( EXPORTING iv_value_low  = c_blart_03
                              CHANGING ct_range      = lr_blart ).
  ref_help->set_range_value( EXPORTING iv_value_low  = c_blart_07
                              CHANGING ct_range      = lr_blart ).
  ref_help->set_range_value( EXPORTING iv_value_low  = c_blart_09
                                       iv_value_high = c_blart_14
                              CHANGING ct_range      = lr_blart ).
  ref_help->set_range_value( EXPORTING iv_value_low  = c_blart_17
                                       iv_value_high = c_blart_25
                              CHANGING ct_range      = lr_blart ).
  ref_help->set_range_value( EXPORTING iv_value_low  = c_blart_30
                                       iv_value_high = c_blart_32
                              CHANGING ct_range      = lr_blart ).
  ref_help->set_range_value( EXPORTING iv_value_low  = c_blart_rn
                              CHANGING ct_range      = lr_blart ).
  ref_help->set_range_value( EXPORTING iv_value_low  = c_blart_un
                              CHANGING ct_range      = lr_blart ).
  ref_help->set_range_value( EXPORTING iv_value_low  = c_blart_st
                              CHANGING ct_range      = lr_blart ).

* Range für besondere Benutzer
  ref_help->set_range_value( EXPORTING iv_value_low  = lc_usnam_finbat
                              CHANGING ct_range      = lr_usnam ).
  ref_help->set_range_value( EXPORTING iv_value_low  = lc_usnam_dogro
                              CHANGING ct_range      = lr_usnam ).

* FI-Belege über Tab. BKPF ermitteln
  SELECT bukrs belnr blart cpudt xblnr lotkz tcode awtyp awkey
                     INTO CORRESPONDING FIELDS OF TABLE lt_header
                     FROM bkpf
                    WHERE bukrs EQ iv_bukrs      AND
                          belnr IN ir_belnr      AND
                          gjahr EQ iv_gjahr      AND
                          cpudt IN ir_bkpdt      AND
                          blart IN lr_blart      AND
                          bstat EQ lc_bstat_init AND
                          stblg EQ lc_stblg_init.

* Daten bereinigen
*-- Belegart '20' und '31' löschen, Daten werden später nachgelesen
  lt_memo = lt_header.
  DELETE lt_header: WHERE blart EQ c_blart_20,
                    WHERE blart EQ c_blart_31.

  DELETE lt_memo WHERE NOT blart EQ c_blart_20.
  LOOP AT lt_memo ASSIGNING <s_memo>.
    SELECT SINGLE wrbtr zuonr
             INTO (<s_memo>-wrbtr, <s_memo>-zuonr)
             FROM bseg
            WHERE bukrs EQ iv_bukrs       AND
                  belnr EQ <s_memo>-belnr AND
                  gjahr EQ iv_gjahr       AND
                  koart EQ ref_const->c_koart_d.
    IF NOT sy-subrc IS INITIAL.
      CLEAR: <s_memo>-zuonr, <s_memo>-wrbtr.
    ELSE.
      MULTIPLY <s_memo>-wrbtr BY -1.
    ENDIF.
  ENDLOOP.

*-- Belegart '07, '18' und 'UN', nur ersten Beleg je Anordnungsnr.
*-- weiterverarbeiten
    CLEAR lr_blart. lt_stundg = lt_header.
    ref_help->set_range_value( EXPORTING iv_value_low  = c_blart_07
                                CHANGING ct_range      = lr_blart ).
    ref_help->set_range_value( EXPORTING iv_value_low  = c_blart_18
                                CHANGING ct_range      = lr_blart ).
    ref_help->set_range_value( EXPORTING iv_value_low  = c_blart_un
                                CHANGING ct_range      = lr_blart ).

    ref_help->set_range_value( EXPORTING iv_value_low  = lc_psosg_1
                                CHANGING ct_range      = lr_psosg ).
    ref_help->set_range_value( EXPORTING iv_value_low  = lc_psosg_4
                                CHANGING ct_range      = lr_psosg ).
    DELETE: lt_stundg WHERE NOT blart IN lr_blart,
            lt_header WHERE blart IN lr_blart.
    SORT lt_stundg BY belnr lotkz.
    DELETE ADJACENT DUPLICATES FROM lt_stundg COMPARING lotkz.
    LOOP AT lt_stundg INTO ls_header.
      SELECT COUNT(*) FROM bkpf UP TO 1 ROWS
                     WHERE bukrs EQ ls_header-bukrs AND
                           belnr EQ ls_header-belnr AND
                           gjahr EQ iv_gjahr        AND
                           psosg IN lr_psosg.
      IF sy-subrc IS INITIAL.
        DELETE lt_stundg.
      ENDIF.
    ENDLOOP.
    APPEND LINES OF lt_stundg TO lt_header.

*-- Bereinigung Feld XBLNR
    ref_help->set_range_value( EXPORTING iv_value_low  = lc_xblnr_37
                                CHANGING ct_range      = lr_xblnr ).
    ref_help->set_range_value( EXPORTING iv_value_low  = lc_xblnr_38
                                CHANGING ct_range      = lr_xblnr ).

    LOOP AT lt_header INTO ls_header
                     WHERE NOT xblnr(2) IN lr_xblnr.
      IF ls_header-xblnr+5(1) CA lc_xblnr_num.
*        or ls_header-xblnr+5(1) CA lc_xblnr_ltr.
        DELETE lt_header.
      ENDIF.
    ENDLOOP.

*-- Belegart 'RN', Rechnungsbeleg auf Storno prüfen
    LOOP AT lt_header INTO ls_header
                     WHERE blart EQ c_blart_rn AND NOT
                           awkey EQ lc_awkey_init.

      IF ls_header-awtyp EQ lc_awtyp_rmrp.
        DESCRIBE FIELD l_belnr LENGTH l_len IN CHARACTER MODE.
        l_belnr = ls_header-awkey(l_len).
        l_gjahr = ls_header-awkey+l_len.

        CALL FUNCTION 'MRM_RBKP_SINGLE_READ'
          EXPORTING  i_belnr = l_belnr
                     i_gjahr = l_gjahr
          IMPORTING  e_rbkp  = ls_rbkp
          EXCEPTIONS OTHERS  = 2.

        IF sy-subrc IS INITIAL.
          IF NOT ls_rbkp-stblg IS INITIAL.
            DELETE lt_header.

            CONCATENATE ls_rbkp-stblg ls_rbkp-stjah INTO l_awkey.
            SELECT SINGLE * FROM bkpf INTO ls_bkpf
                           WHERE bukrs EQ ls_header-bukrs AND
                                 awtyp EQ lc_awtyp_rmrp   AND
                                 awkey EQ l_awkey.
            IF sy-subrc IS INITIAL.
              READ TABLE lt_header INTO ls_search
                                   WITH KEY bukrs = ls_bkpf-bukrs
                                            belnr = ls_bkpf-belnr
                                            blart = ls_bkpf-blart.
              IF sy-subrc IS INITIAL.
                DELETE lt_header.
              ENDIF.
            ENDIF.

          ENDIF.
        ENDIF.
      ENDIF.

      CLEAR: l_belnr, l_gjahr, ls_rbkp.
    ENDLOOP.

*-- Belegart 'UN'; Belege mit Nutzer "FINBAT" und "DOGRO" dürfen nicht
*-- weiterverarbeitet werden
    LOOP AT lt_header INTO ls_header
                     WHERE blart EQ c_blart_un.
      SELECT COUNT(*) FROM bkpf UP TO 1 ROWS
                     WHERE bukrs EQ ls_header-bukrs AND
                           belnr EQ ls_header-belnr AND
                           gjahr EQ iv_gjahr        AND
                           usnam IN lr_usnam.
      IF sy-subrc IS INITIAL.
        DELETE lt_header. CLEAR ls_header.
      ENDIF.
    ENDLOOP.

* weitere Daten ermitteln
  LOOP AT lt_header INTO ls_header.
*-- ... Daten zu FI-Beleg werden ermittelt
    CLEAR v_progr_txt. v_progr_txt = TEXT-tdr.
    REPLACE: '&1' WITH TEXT-bkp INTO v_progr_txt,
             '&2' WITH ls_header-belnr INTO v_progr_txt.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING  percentage = 45
                 text       = v_progr_txt.

    read_document_data( EXPORTING iv_bukrs  = iv_bukrs
                                  iv_gjahr  = iv_gjahr
                                  iv_blart  = ls_header-blart
                                  iv_refbn  = ls_header-belnr
                                  iv_lotkz  = ls_header-lotkz
                        IMPORTING et_pso02  = lt_pso02
                                  et_pso02s = lt_pso02s ).

*-- ggf. Positionsdaten nachträglich bereinigen
    CASE ls_header-blart.
      WHEN c_blart_30.
        READ TABLE lt_pso02s INTO ls_pso02s INDEX 1.
        IF sy-subrc IS INITIAL.
          IF ls_pso02s-fipex+6(1) GE lc_value_4.
            l_x_apu = abap_on.
            l_x_epu = abap_off.
          ELSE.
            l_x_epu = abap_on.
            l_x_apu = abap_off.
          ENDIF.
        ENDIF.
        CASE abap_on.
          WHEN l_x_apu.
            DELETE lt_pso02s WHERE shkzg EQ ref_const->c_shkzg_h.
          WHEN l_x_epu.
            DELETE lt_pso02s WHERE shkzg EQ ref_const->c_shkzg_s.
          WHEN OTHERS.
            DELETE ADJACENT DUPLICATES FROM lt_pso02s
                   COMPARING belnr lotkz.
        ENDCASE.

      WHEN c_blart_st.
        READ TABLE lt_pso02 INTO ls_pso02
                            WITH KEY bukrs = ls_header-bukrs
                                     belnr = ls_header-belnr.
        IF NOT ls_pso02-stgrd EQ lc_stgrd_z3 AND
           NOT ls_pso02-stgrd EQ lc_stgrd_z4.
          CLEAR: lt_pso02, lt_pso02s.
          CONTINUE.
        ENDIF.
    ENDCASE.

*-- Daten aufbereiten
    LOOP AT lt_pso02s INTO ls_pso02s.
      READ TABLE lt_pso02 INTO ls_pso02
                          WITH KEY bukrs = ls_pso02s-bukrs
                                   belnr = ls_pso02s-belnr
                                   gjahr = ls_pso02s-gjahr.
      CHECK NOT ls_pso02-psosg EQ lc_psosg_4.

      APPEND INITIAL LINE TO lt_save ASSIGNING <s_save>.
      MOVE: sy-mandt        TO <s_save>-mandt,
            ls_pso02-gjahr  TO <s_save>-gjahr,
            ls_pso02-blart  TO <s_save>-blart,
            ls_pso02-belnr  TO <s_save>-refbn,
            ls_pso02s-fistl TO <s_save>-fistl,
            ls_pso02s-fipex TO <s_save>-fipex,
            ls_pso02s-wrbtr TO <s_save>-brtwr_sap,
            sy-datum        TO <s_save>-exdat.

      IF NOT ls_pso02s-ebeln IS INITIAL.
        MOVE ls_pso02s-ebeln TO <s_save>-aufkz.
      ELSEIF NOT ls_pso02s-kblnr IS INITIAL.
        MOVE ls_pso02s-kblnr TO <s_save>-aufkz.
      ENDIF.

      IF NOT ls_pso02s-ebeln IS INITIAL AND
         NOT ls_pso02s-ebelp IS INITIAL.
        SELECT COUNT(*) FROM ekpo UP TO 1 ROWS
                       WHERE ebeln EQ ls_pso02s-ebeln AND
                             ebelp EQ ls_pso02s-ebelp AND
                             retpo EQ abap_on.
        IF sy-subrc IS INITIAL.
          MULTIPLY <s_save>-brtwr_sap BY -1.
        ENDIF.
      ENDIF.

*---- Umsortieren der Tabelle lt_memo erforderlich, damit immer der
*---- letze 20er zuerst gelesen wird
      IF ls_pso02-blart EQ c_blart_21.
        SORT lt_memo DESCENDING BY blart zuonr belnr.

        CASE iv_xerror.
          WHEN abap_off.
            LOOP AT lt_memo INTO ls_memo
                           WHERE bukrs EQ ls_pso02-bukrs AND
                                 belnr LT ls_pso02-belnr AND
                                 cpudt EQ ls_pso02-cpudt AND
                                 blart EQ c_blart_20     AND
                                 zuonr EQ ls_pso02-zuonr.
              EXIT.
            ENDLOOP.
          WHEN abap_on.
            LOOP AT lt_memo INTO ls_memo
                           WHERE bukrs EQ ls_pso02-bukrs AND
                                 belnr LT ls_pso02-belnr AND
                                 blart EQ c_blart_20     AND
                                 zuonr EQ ls_pso02-zuonr.
              EXIT.
            ENDLOOP.
        ENDCASE.
        IF sy-subrc IS INITIAL.
          <s_save>-brtwr_sap = <s_save>-brtwr_sap +
                               ls_memo-wrbtr.
          IF <s_save>-brtwr_sap LT lc_wrbtr_init.
            MULTIPLY <s_save>-brtwr_sap BY -1.
          ENDIF.
        ELSE.
          CLEAR <s_save>-brtwr_sap.
        ENDIF.
      ENDIF.
      CLEAR: ls_pso02, ls_pso02s.
    ENDLOOP.

*-- Initialsierung
    CLEAR: ls_header, lt_pso02, lt_pso02s.

  ENDLOOP.

  DELETE lt_save WHERE NOT: fistl IN r_dstl,
                            fipex IN r_eplkap.

* Zusammenfassung der Positionen (pro Beleg und Fistl sowie Fipos)
  SORT lt_save BY gjahr refbn fistl fipex.
  LOOP AT lt_save ASSIGNING <s_collect>.
    COLLECT <s_collect> INTO rt_data.
  ENDLOOP.

  LOOP AT rt_data ASSIGNING <s_save>
                  WHERE brtwr_sap LT lc_wrbtr_init.
    MULTIPLY <s_save>-brtwr_sap BY -1.
  ENDLOOP.

ENDMETHOD.                    "read_fi_data


*----------------------------------------------------------------------*
* Methode READ_AO_DATA
*----------------------------------------------------------------------*
METHOD read_ao_data.

* lokale Datendeklaration
  CONSTANTS: lc_bstat_init TYPE bstat_d VALUE IS INITIAL,
             lc_xfrge_on   TYPE xfrge VALUE abap_on,
             lc_objcl_dao  TYPE cdobjectcl VALUE 'PSODAUERAO',
             lc_number     TYPE string VALUE '0123456789',
             lc_wtabb_init TYPE kblwta VALUE IS INITIAL.

  TYPES: BEGIN OF ts_header,
           lotkz TYPE pso_lotkz,
           bukrs TYPE bukrs,
           gjahr TYPE gjahr,
           blart TYPE blart,
           aedat TYPE aedat,
           tcode TYPE tcode,
         END OF ts_header.

  DATA: lr_blart TYPE RANGE OF blart,
        lr_gjahr TYPE RANGE OF gjahr,
        l_objid  TYPE cdobjectv,
        l_refbn  TYPE belnr_d,
        l_gjahr  TYPE gjahr,
        l_xblnr  TYPE xblnr1,
        l_len    TYPE i.

  DATA: lt_header TYPE STANDARD TABLE OF ts_header,
        lt_save   TYPE tt_ano_data,
        ls_header LIKE LINE OF lt_header.

  DATA: lt_pso02  TYPE fm_pso02,
        lt_pso02s TYPE fm_pso02s,
        ls_pso02  LIKE LINE OF lt_pso02,
        ls_pso02s LIKE LINE OF lt_pso02s.

  DATA: lt_cdred TYPE sa_cdred_t,
        lt_kbld  TYPE fm_t_kbld,
        ls_kbld  LIKE LINE OF lt_kbld.

  FIELD-SYMBOLS: <s_save>    LIKE LINE OF lt_save,
                 <s_collect> LIKE LINE OF rt_data.

* Range der zulässigen Belegarten füllen
  ref_help->set_range_value( EXPORTING iv_value_low  = c_blart_02
                              CHANGING ct_range      = lr_blart ).
  ref_help->set_range_value( EXPORTING iv_value_low  = c_blart_12
                              CHANGING ct_range      = lr_blart ).

* Range für Geschäftsjahr
  IF iv_xinit EQ abap_on.
    CLEAR: lr_gjahr, l_gjahr.
  ELSE.
    CLEAR: lr_gjahr, l_gjahr.
  ENDIF.

* Daueranordnungen über Tab. PSOKPF ermitteln
  SELECT lotkz bukrs gjahr blart aedat tcode
                     INTO CORRESPONDING FIELDS OF TABLE lt_header
                     FROM psokpf
                    WHERE lotkz IN ir_lotkz      AND
                          bukrs EQ iv_bukrs      AND
                          gjahr IN lr_gjahr      AND
                          aedat IN ir_psodt      AND
                          blart IN lr_blart      AND
                          bstat EQ lc_bstat_init AND
                          xfrge EQ lc_xfrge_on
                    ORDER BY blart lotkz.

* weitere Daten ermitteln
  LOOP AT lt_header INTO ls_header.
*-- ... Daten zu Daueranordnung werden ermittelt
    CLEAR v_progr_txt. v_progr_txt = TEXT-tdr.
    REPLACE: '&1' WITH TEXT-pso INTO v_progr_txt,
             '&2' WITH ls_header-lotkz INTO v_progr_txt.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING  percentage = 45
                 text       = v_progr_txt.

*-- Daten bereinigen
    CLEAR l_objid.
    CONCATENATE sy-mandt ls_header-lotkz c_joker INTO l_objid.
    lt_cdred = read_changes( iv_objcl = lc_objcl_dao
                             iv_objid = l_objid ).

    IF lines( lt_cdred ) IS INITIAL.
*---- Prüfen, ob Eintrag in Tab. ZSST_SAP_DHB_ANO vorhanden
      SELECT COUNT(*) FROM zsst_sap_dhb_ano UP TO 1 ROWS
                     WHERE gjahr EQ iv_gjahr AND
                           refbn EQ ls_header-lotkz.
      IF sy-subrc IS INITIAL.
*------ Eintrag vorhanden (Änderung aus Zahllauf)
        DELETE lt_header. CONTINUE.
      ENDIF.
    ENDIF.

*-- Detail ermitteln
    read_document_data( EXPORTING iv_bukrs  = iv_bukrs
                                  iv_gjahr  = ls_header-gjahr
                                  iv_blart  = ls_header-blart
                                  iv_refbn  = l_refbn
                                  iv_lotkz  = ls_header-lotkz
                        IMPORTING et_pso02  = lt_pso02
                                  et_pso02s = lt_pso02s ).

*-- Daten aufbereiten
    LOOP AT lt_pso02s INTO ls_pso02s.
      READ TABLE lt_pso02 INTO ls_pso02
                          WITH KEY bukrs = ls_pso02s-bukrs
                                   belnr = ls_pso02s-belnr
                                   gjahr = ls_pso02s-gjahr.
      APPEND INITIAL LINE TO lt_save ASSIGNING <s_save>.
*---- Trennung in Dauerannahme- und Dauerauszahlunganordnung
*---- bei Dauerauszahlung ist eine Mittelbindung zu übergeben
      IF ls_pso02-blart EQ c_blart_12.
        read_document_data( EXPORTING iv_blart = c_blart_fe
                                      iv_refbn = ls_pso02s-kblnr
                            IMPORTING et_kbld  = lt_kbld ).

        READ TABLE lt_kbld INTO ls_kbld WITH KEY belnr = ls_pso02s-kblnr
                                                 blpos = ls_pso02s-kblpos.
        MOVE: sy-mandt         TO <s_save>-mandt,
              ls_kbld-budat(4) TO <s_save>-gjahr,
              ls_kbld-blart    TO <s_save>-blart,
              ls_kbld-belnr    TO <s_save>-refbn,
              ls_pso02s-fistl  TO <s_save>-fistl,
              ls_pso02s-fipex  TO <s_save>-fipex,
              ls_kbld-wtges    TO <s_save>-brtwr_sap,
              sy-datum         TO <s_save>-exdat.

        IF iv_xinit EQ abap_on.
          SUBTRACT ls_kbld-wtabb FROM <s_save>-brtwr_sap.
          MOVE iv_gjahr TO <s_save>-gjahr.
        ELSEIF ls_kbld-wtabb GT lc_wtabb_init.
          SUBTRACT ls_kbld-wtabb FROM <s_save>-brtwr_sap.
        ENDIF.
        IF ls_kbld-ktext CO lc_number.
          DESCRIBE FIELD l_xblnr LENGTH l_len IN CHARACTER MODE.
          <s_save>-xblnr = l_xblnr = ls_kbld-ktext(l_len).
        ENDIF.
      ELSE.
        MOVE: sy-mandt        TO <s_save>-mandt,
              ls_pso02-gjahr  TO <s_save>-gjahr,
              ls_pso02-blart  TO <s_save>-blart,
              ls_pso02-lotkz  TO <s_save>-refbn,
              ls_pso02s-fistl TO <s_save>-fistl,
              ls_pso02s-fipex TO <s_save>-fipex,
              ls_pso02s-wrbtr TO <s_save>-brtwr_sap,
              sy-datum        TO <s_save>-exdat.
      ENDIF.
      CLEAR: ls_pso02, ls_pso02s.
    ENDLOOP.

*-- Initialsierung
    CLEAR: ls_header, lt_pso02, lt_pso02s, lt_cdred.

  ENDLOOP.

  DELETE lt_save WHERE NOT: fistl IN r_dstl,
                            fipex IN r_eplkap.

* Zusammenfassung der Positionen (pro Beleg und Fistl sowie Fipos
  SORT lt_save BY gjahr refbn fistl fipex.
  LOOP AT lt_save ASSIGNING <s_collect>.
    COLLECT <s_collect> INTO rt_data.
  ENDLOOP.

ENDMETHOD.                    "read_ao_data


*----------------------------------------------------------------------*
* Methode READ_ME_DATA
*----------------------------------------------------------------------*
METHOD read_me_data.

* lokale Datendeklaration
  TYPES: BEGIN OF ts_header,
           ebeln TYPE ebeln,
         END OF ts_header.

  CONSTANTS: lc_bsart_nb    TYPE esart VALUE 'NB',
             lc_bstyp_f     TYPE ebstyp VALUE 'F',
             lc_memory_init TYPE memer VALUE IS INITIAL,
             lc_loekz_init  TYPE eloek VALUE IS INITIAL,
             lc_wrbtr_init  TYPE wrbtr VALUE IS INITIAL,
             lc_dat_low     TYPE char4 VALUE '0101',
             lc_dat_high    TYPE char4 VALUE '1231'.

  DATA: lr_bedat     TYPE RANGE OF bedat,
        lr_btart     TYPE RANGE OF fm_btart,
        l_bedat_low  TYPE datum,
        l_bedat_high TYPE datum,
        l_rfknt      TYPE cc_rfknt,
        l_gjahr      TYPE gjahr,
        l_vjahr      TYPE vjahr.

  DATA: lt_header  TYPE STANDARD TABLE OF ts_header,
        lt_save    TYPE tt_feb_data,
        ls_header  LIKE LINE OF lt_header.

  DATA: lt_ekpo TYPE meout_t_ekpo,
        lt_ekkn TYPE meout_t_ekkn,
        ls_ekko TYPE ekko,
        ls_ekpo LIKE LINE OF lt_ekpo,
        ls_ekkn LIKE LINE OF lt_ekkn.

  FIELD-SYMBOLS: <s_save>    LIKE LINE OF lt_save,
                 <s_collect> LIKE LINE OF rt_data.

* Range für Bestelldatum setzen
  IF iv_gjahr IS INITIAL.
    l_gjahr = pa_gjahr.
    l_vjahr = l_gjahr - 1.
  ELSE.
    l_gjahr = iv_gjahr.
    l_vjahr = l_gjahr - 1.
  ENDIF.

* Range für Bestelldatum
  CONCATENATE: l_vjahr lc_dat_low  INTO l_bedat_low,
               l_gjahr lc_dat_high INTO l_bedat_high.
  ref_help->set_range_value( EXPORTING iv_value_low  = l_bedat_low
                                       iv_value_high = l_bedat_high
                              CHANGING ct_range      = lr_bedat ).

* keine Range bilden bei Geschäftsjahreswechsel oder Initialübernahme
  IF iv_xgjw EQ abap_on OR iv_xinit EQ abap_on.
    CLEAR lr_bedat.
  ENDIF.

* Bestellungen ermitteln
  SELECT DISTINCT tk~ebeln
             INTO CORRESPONDING FIELDS OF TABLE lt_header
             FROM ekko AS tk
             JOIN ekpo AS tp
               ON tk~ebeln EQ tp~ebeln
            WHERE tk~ebeln  IN ir_ebeln    AND
                  tk~bsart  EQ lc_bsart_nb AND
                  tk~bstyp  EQ lc_bstyp_f  AND
                  tk~bedat  IN lr_bedat    AND
                  tk~memory EQ lc_memory_init AND
                ( tk~aedat  IN ir_aedat OR
                  tp~aedat  IN ir_aedat ).

* weitere Daten ermitteln
  LOOP AT lt_header INTO ls_header.
*-- ... Daten zu Einkaufsbeleg werden ermittelt
    CLEAR v_progr_txt. v_progr_txt = TEXT-tdr.
    REPLACE: '&1' WITH TEXT-eko INTO v_progr_txt,
             '&2' WITH ls_header-ebeln INTO v_progr_txt.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING  percentage = 45
                 text       = v_progr_txt.

    read_document_data( EXPORTING iv_blart = c_blart_nb
                                  iv_refbn = ls_header-ebeln
                        IMPORTING es_ekko  = ls_ekko
                                  et_ekpo  = lt_ekpo
                                  et_ekkn  = lt_ekkn ).

    IF NOT lines( lt_ekpo ) IS INITIAL.
*---- sofern Position am gleichen Tag angelegt und wieder gelöscht
*---- wurde, soll diese nicht als leerer Datensatz übergeben werden
      DELETE lt_ekpo WHERE aedat EQ ls_ekko-aedat AND NOT
                           loekz EQ lc_loekz_init.

*---- Daten für weitere Verarbeitung aufbereiten
      LOOP AT lt_ekpo INTO ls_ekpo
                     WHERE ebeln = ls_ekko-ebeln.
        CASE ls_ekpo-knttp.
          WHEN abap_off.
            APPEND INITIAL LINE TO lt_save ASSIGNING <s_save>.
            MOVE: sy-mandt      TO <s_save>-mandt,
                  l_gjahr       TO <s_save>-gjahr,
                  c_blart_nb    TO <s_save>-blart,
                  ls_ekpo-ebeln TO <s_save>-refbn,
                  ls_ekpo-fistl TO <s_save>-fistl,
                  sy-datum      TO <s_save>-exdat.

            CALL FUNCTION 'FI_PSO_FIPEX_GET_FROM_FIPOS'
              EXPORTING  i_fipos = ls_ekpo-fipos
              IMPORTING  e_fipex = <s_save>-fipex.

            CLEAR l_rfknt.
            SELECT COUNT(*) FROM zsst_sap_dhb_feb
                              UP TO 1 ROWS
                           WHERE gjahr EQ <s_save>-gjahr AND
                                 refbn EQ <s_save>-refbn AND
                                 fistl EQ <s_save>-fistl AND
                                 fipex EQ <s_save>-fipex.
            IF NOT sy-subrc IS INITIAL.
              IF iv_xgjw EQ abap_on OR iv_xinit EQ abap_on.
                CLEAR lr_btart.
              ELSE.
                CLEAR lr_btart.
                ref_help->set_range_value(
                            EXPORTING iv_value_low = c_btart_0100
                             CHANGING ct_range     = lr_btart ).
              ENDIF.
            ELSE.
              CLEAR lr_btart.
            ENDIF.

            <s_save>-brtwr_sap = get_fmioi_values( iv_refbt = c_refbt_020
                                                   iv_refbn = ls_ekpo-ebeln
                                                   iv_rfpos = ls_ekpo-ebelp
                                                   iv_rfknt = l_rfknt
                                                   ir_btart = lr_btart ).

            IF ls_ekpo-retpo EQ abap_on.
              MULTIPLY <s_save>-brtwr_sap BY -1.
            ENDIF.

          WHEN OTHERS.
            LOOP AT lt_ekkn INTO ls_ekkn WHERE ebeln = ls_ekpo-ebeln AND
                                               ebelp = ls_ekpo-ebelp.

              APPEND INITIAL LINE TO lt_save ASSIGNING <s_save>.
              MOVE: sy-mandt      TO <s_save>-mandt,
                    l_gjahr       TO <s_save>-gjahr,
                    c_blart_nb    TO <s_save>-blart,
                    ls_ekkn-ebeln TO <s_save>-refbn,
                    ls_ekkn-fistl TO <s_save>-fistl,
                    sy-datum      TO <s_save>-exdat.

              CALL FUNCTION 'FI_PSO_FIPEX_GET_FROM_FIPOS'
                EXPORTING  i_fipos = ls_ekkn-fipos
                IMPORTING  e_fipex = <s_save>-fipex.

              CLEAR l_rfknt. l_rfknt = ls_ekkn-zekkn.
              SELECT COUNT(*) FROM zsst_sap_dhb_feb
                                UP TO 1 ROWS
                             WHERE gjahr EQ <s_save>-gjahr AND
                                   refbn EQ <s_save>-refbn AND
                                   fistl EQ <s_save>-fistl AND
                                   fipex EQ <s_save>-fipex.
              IF NOT sy-subrc IS INITIAL.
                IF iv_xgjw EQ abap_on OR iv_xinit EQ abap_on.
                  CLEAR lr_btart.
                ELSE.
                  CLEAR lr_btart.
                  ref_help->set_range_value(
                              EXPORTING iv_value_low = c_btart_0100
                               CHANGING ct_range     = lr_btart ).
                ENDIF.
              ELSE.
                CLEAR lr_btart.
              ENDIF.

              <s_save>-brtwr_sap = get_fmioi_values( iv_refbt = c_refbt_020
                                                     iv_refbn = ls_ekkn-ebeln
                                                     iv_rfpos = ls_ekkn-ebelp
                                                     iv_rfknt = l_rfknt
                                                     ir_btart = lr_btart ).

              IF ls_ekpo-retpo EQ abap_on.
                MULTIPLY <s_save>-brtwr_sap BY -1.
              ENDIF.

            ENDLOOP.
        ENDCASE.
      ENDLOOP.
    ENDIF.

*-- Initialisierung
    CLEAR: ls_ekko, lt_ekkn, lt_ekpo.
  ENDLOOP.

* Bereinigen Datentabelle; Bestellungen mit Betrag Null und keinem
* Eintrag in der Tabelle ZSST_SAP_DHB_FEB werden nicht übertragen
  DELETE lt_save WHERE NOT: fistl IN r_dstl,
                            fipex IN r_eplkap.

  LOOP AT lt_save ASSIGNING <s_save>
                  WHERE brtwr_sap EQ lc_wrbtr_init.
    SELECT COUNT(*) FROM zsst_sap_dhb_feb
                      UP TO 1 ROWS
                   WHERE gjahr EQ <s_save>-gjahr AND
                         refbn EQ <s_save>-refbn AND
                         fistl EQ <s_save>-fistl AND
                         fipex EQ <s_save>-fipex.
    IF NOT sy-subrc IS INITIAL.
      DELETE lt_save. CONTINUE.
    ENDIF.
  ENDLOOP.

* Zusammenfassung der Positionen (pro Bestellung und Finanzstelle so-
* wie Finanzposition)
  SORT lt_save BY gjahr refbn fistl fipex.
  LOOP AT lt_save ASSIGNING <s_collect>.
    COLLECT <s_collect> INTO rt_data.
  ENDLOOP.

ENDMETHOD.                    "read_me_data


*----------------------------------------------------------------------*
* Methode READ_MB_DATA
*----------------------------------------------------------------------*
METHOD read_mb_data.

* lokale Datendeklaration
  CONSTANTS: lc_mvstat_init TYPE fmr_mvstat VALUE IS INITIAL,
             lc_num_val     TYPE string VALUE '0123456789',
             lc_lines_1     TYPE i VALUE 1,
             lc_value_eoj   TYPE c LENGTH 4 VALUE '1231'.

  TYPES: BEGIN OF ts_header,
           belnr TYPE kblnr,
           blart TYPE kblart,
         END OF ts_header.

  DATA: l_lotkz      TYPE pso_lotkz,
        l_gjahr      TYPE gjahr,
        l_len        TYPE i,
        l_wtabb_rfbu TYPE kblwta,
        l_eojdt      TYPE datum.

  DATA: lr_blart TYPE RANGE OF kblart,
        lr_btart TYPE RANGE OF fm_btart.

  DATA: lt_header    TYPE STANDARD TABLE OF ts_header,
        lt_kbld      TYPE fm_t_kbld,
        lt_kble      TYPE STANDARD TABLE OF kble,
        lt_psokpf    TYPE STANDARD TABLE OF psokpf,
        lt_save      TYPE tt_feb_data,
        lt_save_mjve TYPE tt_feb_data,
        ls_header    LIKE LINE OF lt_header,
        ls_kblk      TYPE kblk,
        ls_kbld      LIKE LINE OF lt_kbld.

  FIELD-SYMBOLS: <s_save>    LIKE LINE OF lt_save,
                 <s_collect> LIKE LINE OF rt_data.

* Range für Belegart setzen
  ref_help->set_range_value( EXPORTING iv_value_low = c_blart_fe
                              CHANGING ct_range     = lr_blart ).
  ref_help->set_range_value( EXPORTING iv_value_low = c_blart_ve
                              CHANGING ct_range     = lr_blart ).

* Mittelbindungen ermitteln
  SELECT DISTINCT tk~belnr tk~blart
                  INTO CORRESPONDING FIELDS OF TABLE lt_header
                  FROM kblk AS tk
                  JOIN kblp AS tp
                    ON tk~belnr EQ tp~belnr
                 WHERE tk~belnr IN ir_kblnr AND
                       tk~blart IN lr_blart AND
                   ( ( tk~kerdat IN ir_kbldt OR tk~kaedat IN ir_kbldt ) OR
                     ( tp~erdat IN ir_kbldt OR tp~aedat IN ir_kbldt ) ) AND
                       tk~mvstat EQ lc_mvstat_init.

* Daten bereinigen
  LOOP AT lt_header INTO ls_header.
*-- ... Daten zu Mittelbindung werden ermittelt
    CLEAR v_progr_txt. v_progr_txt = TEXT-tdr.
    REPLACE: '&1' WITH TEXT-kbl INTO v_progr_txt,
             '&2' WITH ls_header-belnr INTO v_progr_txt.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING  percentage = 45
                 text       = v_progr_txt.

    read_document_data( EXPORTING iv_blart = ls_header-blart
                                  iv_refbn = ls_header-belnr
                        IMPORTING es_kblk  = ls_kblk
                                  et_kbld  = lt_kbld
                                  et_kble  = lt_kble ).

*-- Erfassungsdatum gleich Änderungsdatum u. Erledigtkennzeichen ist
*-- gesetzt --> DS löschen
    IF ls_kblk-blart EQ c_blart_fe AND ls_kblk-fexec EQ abap_on AND
       ls_kblk-kerdat EQ ls_kblk-kaedat.
      DELETE lt_header. CONTINUE.
    ENDIF.
*-- ist Mittelbindung aus Daueranordnung --> DS löschen; gilt nicht
*-- wenn Kennzeichen 'Jahreswechsel' gesetzt ist
    DESCRIBE FIELD l_lotkz LENGTH l_len IN CHARACTER MODE.
    CLEAR l_lotkz. l_lotkz = ls_kblk-ktext(l_len).

    IF l_lotkz CO lc_num_val.
      SELECT * FROM psokpf INTO TABLE lt_psokpf
              WHERE bukrs EQ ls_kblk-bukrs AND
                    lotkz EQ l_lotkz.

      IF NOT lines( lt_psokpf ) IS INITIAL AND iv_xgjw EQ abap_off.
        DELETE lt_header. CONTINUE.
      ENDIF.
    ENDIF.

*-- Daten ggf. nochmals bereinigen
    IF NOT lines( lt_kbld ) IS INITIAL.
      LOOP AT lt_kbld INTO ls_kbld
                     WHERE blart EQ c_blart_fe.
        IF NOT ls_kbld-erlkz IS INITIAL.
          IF ls_kbld-kerdat EQ ls_kbld-kaedat.
            DELETE lt_kbld.
          ENDIF.
        ELSE.
          IF ls_kbld-kerdat EQ ls_kbld-kaedat AND
             ls_kbld-wtges EQ ls_kbld-wtabb.
            DELETE lt_kbld.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

*-- Positionen für Zusammenfassen aufbereiten; Betrag der durch Rech-
*-- nungen entstanden ist (l_wtabb_rfbu) muss wieder zum aus Tab. FMIOI
*-- ermittelten Betrag aufaddiert werden
*-- Anpassung Ermittlung Beträge für Mittelbindungen; Beträge der Rech-
*-- nungen dürfen nicht mehr auf abgebauten Betrag aufaddiert werden,
*-- sind bereits im aus Tab. FMIOI ermittelten Betrag enthalten
*-- Anpassung Ermittlung Beträge für Mittelbindungen; bei Anlegen und
*-- Änderung am gleichen Tag muss nur der noch offene Betrag der MB
*-- übergeben werden
    LOOP AT lt_kbld INTO ls_kbld
         WHERE ( ( kerdat IN ir_kbldt OR kaedat IN ir_kbldt ) OR
                 ( erdat  IN ir_kbldt OR aedat IN ir_kbldt ) ).
      APPEND INITIAL LINE TO lt_save ASSIGNING <s_save>.
      MOVE: sy-mandt       TO <s_save>-mandt,
            ls_kbld-belnr  TO <s_save>-refbn,
            ls_kbld-blart  TO <s_save>-blart,
            ls_kbld-fistl  TO <s_save>-fistl,
            sy-datum       TO <s_save>-exdat.

      IF ls_kbld-ktext CO lc_num_val.
        DESCRIBE FIELD <s_save>-xblnr LENGTH l_len
                    IN CHARACTER MODE.
        <s_save>-xblnr = ls_kbld-ktext(l_len).
      ENDIF.

      IF iv_xgjw EQ abap_on OR iv_xinit EQ abap_on.
        MOVE iv_gjahr TO <s_save>-gjahr.
        IF ls_kbld-blart EQ c_blart_ve.
          MOVE ls_kbld-belnr TO <s_save>-belnr_dhb.
        ENDIF.
      ELSE.
        IF ls_kbld-kaedat IS INITIAL.
          ref_help->get_date_components(
                      EXPORTING iv_datum = ls_kbld-budat
                      IMPORTING ev_ayear = <s_save>-gjahr ).
        ELSE.
          ref_help->get_date_components(
                      EXPORTING iv_datum = ls_kbld-kaedat
                      IMPORTING ev_ayear = <s_save>-gjahr ).
        ENDIF.
      ENDIF.

      CALL FUNCTION 'FI_PSO_FIPEX_GET_FROM_FIPOS'
        EXPORTING  i_fipos = ls_kbld-fipos
        IMPORTING  e_fipex = <s_save>-fipex.

      SELECT COUNT(*) FROM zsst_sap_dhb_feb
                        UP TO 1 ROWS
                     WHERE gjahr EQ <s_save>-gjahr AND
                           refbn EQ <s_save>-refbn AND
                           fistl EQ <s_save>-fistl AND
                           fipex EQ <s_save>-fipex.
      IF NOT sy-subrc IS INITIAL.
        IF iv_xgjw EQ abap_on OR iv_xinit EQ abap_on.
          CLEAR lr_btart.
        ELSE.
          IF ls_kbld-kerdat EQ ls_kbld-kaedat.
            CLEAR lr_btart.
          ELSE.
            CLEAR lr_btart.
            ref_help->set_range_value(
                        EXPORTING iv_value_low = c_btart_0100
                         CHANGING ct_range     = lr_btart ).
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR lr_btart.
      ENDIF.

      <s_save>-brtwr_sap = get_fmioi_values(
                             iv_refbt = c_refbt_110
                             iv_refbn = ls_kbld-belnr
                             iv_rfpos = CONV #( ls_kbld-blpos )
                             iv_gjahr = <s_save>-gjahr
                             iv_gnjhr = <s_save>-gjahr
                             ir_btart = lr_btart ).

      IF iv_xgjw EQ abap_off AND iv_xinit EQ abap_off.
        ADD l_wtabb_rfbu TO <s_save>-brtwr_sap.
        CLEAR l_wtabb_rfbu.
      ELSE.
        IF ls_kbld-blart EQ c_blart_ve.
          MOVE <s_save>-brtwr_sap TO <s_save>-brtwr_dhb.
        ENDIF.
      ENDIF.

      CLEAR: ls_kbld, l_gjahr, l_wtabb_rfbu, lr_btart.
    ENDLOOP.

*-- bei mehrjährigen VE's muss für die Folgejahre auch ein Eintrag in
*-- der Tabelle ZSST_SAP_DHB_FEB erfolgen (Ableitung des GJahrs aus
*-- dem Fälligkeitsdatum); Überleitung nach DHB darf nicht zum Jahres-
*-- wechsel erfolgen
    IF lines( lt_kbld ) GE lc_lines_1 AND
      iv_xgjw EQ abap_off AND iv_xinit EQ abap_off.
      CONCATENATE iv_gjahr lc_value_eoj INTO l_eojdt.
      LOOP AT lt_kbld INTO ls_kbld
           WHERE blart EQ c_blart_ve AND
             ( ( kerdat IN ir_kbldt OR kaedat IN ir_kbldt ) OR
               ( erdat  IN ir_kbldt OR aedat IN ir_kbldt ) ) AND
                 fdatk GT l_eojdt.
        APPEND INITIAL LINE TO lt_save_mjve ASSIGNING <s_save>.
        MOVE: sy-mandt       TO <s_save>-mandt,
              ls_kbld-belnr  TO <s_save>-refbn,
              ls_kbld-blart  TO <s_save>-blart,
              ls_kbld-fistl  TO <s_save>-fistl,
              sy-datum       TO <s_save>-exdat.

        ref_help->get_date_components(
                    EXPORTING iv_datum = ls_kbld-fdatk
                    IMPORTING ev_ayear = <s_save>-gjahr ).

        CALL FUNCTION 'FI_PSO_FIPEX_GET_FROM_FIPOS'
          EXPORTING  i_fipos = ls_kbld-fipos
          IMPORTING  e_fipex = <s_save>-fipex.

        ref_help->get_date_components(
                    EXPORTING iv_datum = ls_kbld-budat
                    IMPORTING ev_ayear = l_gjahr ).

        <s_save>-brtwr_sap = get_fmioi_values(
                               iv_refbt = c_refbt_110
                               iv_refbn = ls_kbld-belnr
                               iv_rfpos = CONV #( ls_kbld-blpos )
                               iv_gjahr = l_gjahr
                               iv_gnjhr = <s_save>-gjahr
                               ir_btart = lr_btart ).

      ENDLOOP.
    ENDIF.

*-- Initialisieren
    CLEAR: ls_kblk, lt_kbld, lt_kble, l_wtabb_rfbu.
  ENDLOOP.

* Bereinigen Datentabelle; mehrjährige VE`s anhängen, in der Verar-
* beitung wird später sichergestellt, dass nur Datensätze des aktu-
* ellen Geschäftsjahres an die Schnittstelle übergeben werden
  APPEND LINES OF lt_save_mjve TO lt_save.

  DELETE lt_save WHERE NOT: fistl IN r_dstl,
                            fipex IN r_eplkap.

* Zusammenfassung der Positionen (pro Mittelbindung und Finanzstelle
* sowie Finanzposition)
  SORT lt_save BY gjahr refbn fistl fipex.
  LOOP AT lt_save ASSIGNING <s_collect>.
    COLLECT <s_collect> INTO rt_data.
  ENDLOOP.

ENDMETHOD.                    "read_mb_data


*----------------------------------------------------------------------*
* Methode READ_AA_DATA
*----------------------------------------------------------------------*
METHOD read_aa_data.

* lokale Datendeklaration
  CONSTANTS: lc_mvstat_init TYPE fmr_mvstat VALUE IS INITIAL.

  TYPES: BEGIN OF ts_header,
           belnr TYPE kblnr,
           blart TYPE kblart,
         END OF ts_header.

  DATA: lr_blart TYPE RANGE OF kblart.

  DATA: lt_header TYPE STANDARD TABLE OF ts_header,
        lt_kbld   TYPE fm_t_kbld,
        ls_header LIKE LINE OF lt_header,
        ls_kbld   LIKE LINE OF lt_kbld.

  FIELD-SYMBOLS: <s_save> LIKE LINE OF rt_data.

* Range für Belegart setzen
  ref_help->set_range_value( EXPORTING iv_value_low = c_blart_ba
                              CHANGING ct_range     = lr_blart ).
  ref_help->set_range_value( EXPORTING iv_value_low = c_blart_ae
                              CHANGING ct_range     = lr_blart ).

* allgemeine Anordnungen ermitteln
  SELECT DISTINCT tk~belnr tk~blart
                  INTO CORRESPONDING FIELDS OF TABLE lt_header
                  FROM kblk AS tk
                  JOIN kblp AS tp
                    ON tk~belnr EQ tp~belnr
                 WHERE tk~belnr IN ir_aaonr AND
                       tk~blart IN lr_blart AND
                   ( ( tk~kerdat IN ir_kbldt OR tk~kaedat IN ir_kbldt ) OR
                     ( tp~erdat IN ir_kbldt OR tp~aedat IN ir_kbldt ) ) AND
                       tk~mvstat EQ lc_mvstat_init.

* Daten bereinigen
  LOOP AT lt_header INTO ls_header.
*-- ... Daten zu allg. Anordnungen werden ermittelt
    CLEAR v_progr_txt. v_progr_txt = TEXT-tdr.
    REPLACE: '&1' WITH TEXT-aao INTO v_progr_txt,
             '&2' WITH ls_header-belnr INTO v_progr_txt.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING percentage = 45
                text       = v_progr_txt.

    read_document_data( EXPORTING iv_blart = ls_header-blart
                                  iv_refbn = ls_header-belnr
                        IMPORTING et_kbld  = lt_kbld ).

*-- Positionen für Zusammenfassen aufbereiten
    LOOP AT lt_kbld INTO ls_kbld.
      APPEND INITIAL LINE TO rt_data ASSIGNING <s_save>.
      MOVE: sy-mandt       TO <s_save>-mandt,
            ls_kbld-belnr  TO <s_save>-refbn,
            ls_kbld-blart  TO <s_save>-blart,
            ls_kbld-fistl  TO <s_save>-fistl,
            sy-datum       TO <s_save>-exdat.

      IF ls_kbld-kaedat IS INITIAL.
        MOVE ls_kbld-budat(4) TO <s_save>-gjahr.
      ELSE.
        MOVE ls_kbld-kaedat(4) TO <s_save>-gjahr.
      ENDIF.

      CALL FUNCTION 'FI_PSO_FIPEX_GET_FROM_FIPOS'
        EXPORTING  i_fipos = ls_kbld-fipos
        IMPORTING  e_fipex = <s_save>-fipex.

    ENDLOOP.

*-- Initialisieren
    CLEAR: lt_kbld, ls_kbld.
  ENDLOOP.

* Bereinigen Datentabelle
  DELETE rt_data WHERE NOT: fistl IN r_dstl,
                            fipex IN r_eplkap.

ENDMETHOD.                    "read_aa_data


*----------------------------------------------------------------------*
* Methode READ_MV_DATA
*----------------------------------------------------------------------*
METHOD read_mv_data.

* lokale Datendeklaration
  CONSTANTS: lc_fcode_bmeuu  TYPE bpdk-fcode VALUE 'BMEUU',
             lc_fcode_bmebs  TYPE bpdk-fcode VALUE 'BMEBS',
             lc_verant_dogro TYPE bpdk-verant VALUE 'DOGRO'.

  TYPES: BEGIN OF ts_header,
           belnr TYPE bpdk-belnr,
           cpudt TYPE bpdk-cpudt,
           budat TYPE bpdk-budat,
           fcode TYPE bpdk-fcode,
         END OF ts_header.

  TYPES: BEGIN OF ts_pos,
           belnr TYPE bp_docnr,
           buzei TYPE co_buzei,
           vorga TYPE bp_vorgang,
           wtjhr TYPE bp_wjt,
           fistl TYPE fistl,
           fipex TYPE fm_fipex,
         END OF ts_pos.

  DATA: lr_fcode TYPE RANGE OF bpdk-fcode.

  DATA: lt_header  TYPE STANDARD TABLE OF ts_header,
        lt_pos     TYPE STANDARD TABLE OF ts_pos,
        ls_header  LIKE LINE OF lt_header.

  DATA: lt_bpdj  TYPE STANDARD TABLE OF bpdj,
        lt_bpdz  TYPE STANDARD TABLE OF bpdz,
        ls_bpdj  LIKE LINE OF lt_bpdj,
        ls_bpdz  LIKE LINE OF lt_bpdz,
        ls_fmfpo TYPE fmfpo.

  FIELD-SYMBOLS: <s_pos>  LIKE LINE OF lt_pos,
                 <s_data> LIKE LINE OF rt_data.

* Range für FCODE
  ref_help->set_range_value(
            EXPORTING iv_value_low = lc_fcode_bmeuu
             CHANGING ct_range      = lr_fcode ).
  ref_help->set_range_value(
            EXPORTING iv_value_low = lc_fcode_bmebs
             CHANGING ct_range     = lr_fcode ).

* Mittelverteilungen auslesen
  SELECT belnr cpudt budat fcode
         INTO CORRESPONDING FIELDS OF TABLE lt_header
         FROM bpdk
         WHERE  belnr  IN ir_docnr  AND
                cpudt  IN ir_bpddt  AND
                fcode  IN lr_fcode  AND
            NOT verant EQ lc_verant_dogro.

* weitere Daten ermitteln
  LOOP AT lt_header INTO ls_header.
*-- ... Daten zu Mittelbindung werden ermittelt
    CLEAR v_progr_txt. v_progr_txt = TEXT-tdr.
    REPLACE: '&1' WITH TEXT-mvt INTO v_progr_txt,
             '&2' WITH ls_header-belnr INTO v_progr_txt.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING  percentage = 45
                 text       = v_progr_txt.

    read_document_data( EXPORTING iv_blart = c_blart_mv
                                  iv_refbn = ls_header-belnr
                        IMPORTING et_bpdj  = lt_bpdj
                                  et_bpdz  = lt_bpdz ).

*-- Daten zusammenführen
    LOOP AT lt_bpdj INTO ls_bpdj.
      APPEND INITIAL LINE TO lt_pos ASSIGNING <s_pos>.
      MOVE: ls_bpdj-belnr TO <s_pos>-belnr,
            ls_bpdj-buzei TO <s_pos>-buzei,
            ls_bpdj-vorga TO <s_pos>-vorga,
            ls_bpdj-wtjhr TO <s_pos>-wtjhr.
      READ TABLE lt_bpdz INTO ls_bpdz
                         WITH KEY belnr = ls_bpdj-belnr
                                  buzei = ls_bpdj-buzei.
      IF sy-subrc IS INITIAL.
        <s_pos>-fistl = ls_bpdz-objnr+6(8).

        CALL FUNCTION 'FM_FIPOS_READ_SINGLE'
          EXPORTING  i_fikrs = ref_const->c_fikrs_1000
                     i_posit = ls_bpdz-posit
                     i_gjahr = ls_bpdj-gjahr
          IMPORTING  f_fmfpo = ls_fmfpo
          EXCEPTIONS OTHERS  = 3.

        IF sy-subrc IS INITIAL.
          <s_pos>-fipex = ls_fmfpo-fipex.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-- Positionen umsortieren und übergeben
    IF NOT ls_header-fcode EQ lc_fcode_bmebs.
      SORT lt_pos BY vorga ASCENDING.
    ENDIF.

    LOOP AT lt_pos ASSIGNING <s_pos>.
      APPEND INITIAL LINE TO rt_data ASSIGNING <s_data>.
      MOVE: sy-mandt             TO <s_data>-mandt,
            ls_header-cpudt(4)   TO <s_data>-gjahr,
            ls_header-belnr      TO <s_data>-refbn,
            c_blart_mv           TO <s_data>-blart,
            <s_pos>-fistl        TO <s_data>-fistl,
            <s_pos>-fipex        TO <s_data>-fipex,
            abs( <s_pos>-wtjhr ) TO <s_data>-brtwr_sap,
            sy-datum             TO <s_data>-exdat.
      CONCATENATE <s_pos>-belnr <s_pos>-buzei INTO <s_data>-aufkz.
    ENDLOOP.

*-- Initialisierung
    CLEAR: lt_pos, lt_bpdj, lt_bpdz.
  ENDLOOP.

* Bereinigen Datentabelle
  DELETE rt_data WHERE NOT: fistl IN r_dstl,
                            fipex IN r_eplkap.

ENDMETHOD.                    "read_mv_data


*----------------------------------------------------------------------*
* Methode BUILD_EXPORT_DATA
*----------------------------------------------------------------------*
METHOD build_export_data.

* lokale Datendeklaration
  CONSTANTS: lc_index_1   TYPE i VALUE 1,
             lc_value_3   TYPE i VALUE 3,
             lc_maber_so  TYPE maber VALUE 'SO',
             lc_zlsch_m   TYPE pso02-zlsch VALUE 'M',
             lc_tabix_999 TYPE i VALUE 999.

  DATA: l_len        TYPE i,
        l_btyp       TYPE zbtyp,
        l_blpos      TYPE c LENGTH 3,
        l_blpos_c4   TYPE c LENGTH 4,
        l_tabix      TYPE i,
        l_xblnr      TYPE xblnr1,
        l_ebeln      TYPE ebeln,
        l_flg_export TYPE xfeld,
        l_x_mer      TYPE xfeld,
        l_kor_refspl TYPE text20.

  DATA: lr_ebeln TYPE RANGE OF ebeln,
        lr_cpudt TYPE RANGE OF cpudt.

  DATA: lt_feb_save TYPE tt_feb_data,
        lt_ano_save TYPE tt_ano_data,
        ls_feb_save LIKE LINE OF lt_feb_save,
        ls_ano_save LIKE LINE OF lt_ano_save,
        ls_feb_data LIKE LINE OF it_feb_data,
        ls_ano_data LIKE LINE OF it_ano_data.

  DATA: lt_ano_spl TYPE tt_ano_spl,
        lt_ano_mm  TYPE tt_ano_spl,
        ls_ano_spl LIKE LINE OF lt_ano_spl,
        ls_ano_mm  LIKE LINE OF lt_ano_mm.

  DATA: lt_ekpo   TYPE meout_t_ekpo,
        lt_ekkn   TYPE meout_t_ekkn,
        lt_kbld   TYPE fm_t_kbld,
        lt_bpdj   TYPE tt_bpdj,
        lt_bpdz   TYPE tt_bpdz,
        lt_pso02  TYPE fm_pso02,
        lt_pso02s TYPE fm_pso02s,
        lt_pssec  TYPE fm_bsec,
        ls_kbld   LIKE LINE OF lt_kbld,
        ls_pso02  LIKE LINE OF lt_pso02,
        ls_pso02s LIKE LINE OF lt_pso02s.

  DATA: lt_pso02_spl  TYPE fm_pso02,
        lt_pso02s_spl TYPE fm_pso02s,
        lt_pssec_spl  TYPE fm_bsec.

  DATA: lt_feb_data TYPE tt_feb_data,
        lt_feb_dele TYPE tt_feb_data,
        lt_ano_data TYPE tt_ano_data,
        lt_me_data  TYPE tt_feb_data.

  DATA: lt_export  TYPE tt_sst_export,
        ls_export  LIKE LINE OF et_export.

  FIELD-SYMBOLS: <s_export>   LIKE LINE OF et_export,
                 <s_prot>     LIKE LINE OF et_prot,
                 <s_ano_spl>  LIKE LINE OF lt_ano_spl,
                 <s_ano_save> LIKE LINE OF lt_ano_data,
                 <s_pso02>    LIKE LINE OF lt_pso02,
                 <s_pssec>    LIKE LINE OF lt_pssec.

* Übergabe Daten
  APPEND LINES OF: it_feb_data TO lt_feb_data,
                   it_ano_data TO lt_ano_data.

* Prüfen auf nicht mehr existierende Kombinationen
  lt_feb_dele = check_existence( it_feb_data ).
  APPEND LINES OF lt_feb_dele TO lt_feb_data.
*&---------------------------------------------------------------------*
* Exportstruktur für Festlegungen erstellen
  LOOP AT lt_feb_data INTO ls_feb_data.
*&---------------------------------------------------------------------*
*-- Auftragskennzeichen und Buchungstyp ermitteln; im Vorfeld in der
*-- Tabelle lt_feb_dele suchen
    READ TABLE lt_feb_dele FROM ls_feb_data
                           TRANSPORTING NO FIELDS.

    IF sy-subrc IS INITIAL.
      l_btyp     = c_btyp_fae.
      ls_feb_save = ls_feb_data.
    ELSE.
      get_aufkz_btyp( EXPORTING iv_sst_type   = c_sst_feb
                                is_sst_data   = ls_feb_data
                      IMPORTING ev_btyp       = l_btyp
                                es_sst_save   = ls_feb_save ).
    ENDIF.


    IF NOT ls_feb_save IS INITIAL.
      ls_feb_save-btyp = l_btyp.
      APPEND ls_feb_save TO lt_feb_save.
    ENDIF.

*-- mehrjährige VE's dürfen nicht als Einzelsätze FEB über die
*-- Schnittstelle übertragen werden
    IF ls_feb_data-blart EQ c_blart_ve AND
       ls_feb_data-gjahr GT iv_gjahr   AND
       ls_feb_save-btyp EQ c_btyp_feb.
      CLEAR ls_feb_save.
      CONTINUE.
    ENDIF.

*-- Daten zum Beleg ermitteln
    read_document_data( EXPORTING iv_blart = ls_feb_data-blart
                                  iv_refbn = ls_feb_data-refbn
                        IMPORTING et_ekpo  = lt_ekpo
                                  et_ekkn  = lt_ekkn
                                  et_kbld  = lt_kbld ).

*-- Mapping durchführen
    CASE l_btyp.
*---- Buchungstyp 'FEB'
      WHEN c_btyp_feb.
        ls_export = map_feb_data( iv_btyp  = l_btyp
                                  iv_gjahr = iv_gjahr
                                  is_data  = ls_feb_save
                                  it_ekpo  = lt_ekpo
                                  it_ekkn  = lt_ekkn
                                  it_kbld  = lt_kbld ).

*---- Buchungstyp 'FAE'
      WHEN c_btyp_fae.
        ls_export = map_fae_data( iv_btyp   = l_btyp
                                  iv_gjahr  = iv_gjahr
                                  is_data   = ls_feb_save
                                  it_ekpo   = lt_ekpo
                                  it_ekkn   = lt_ekkn
                                  it_kbld   = lt_kbld ).

    ENDCASE.

    IF ls_export-bnstat EQ c_bnstat_0.
      APPEND ls_export TO et_export.
      l_flg_export = abap_on.
    ELSE.
      l_flg_export = abap_off.
      READ TABLE lt_feb_save FROM ls_feb_save
                             TRANSPORTING NO FIELDS.
      IF sy-subrc IS INITIAL.
        DELETE TABLE lt_feb_save FROM ls_feb_save.
      ENDIF.
    ENDIF.

*-- Auswertung Flag 'Export'
    APPEND INITIAL LINE TO et_prot ASSIGNING <s_prot>.
    MOVE-CORRESPONDING ls_feb_save TO <s_prot>.
    MOVE ls_feb_save-brtwr_sap TO <s_prot>-brtwr.
    CASE l_flg_export.
      WHEN abap_on.
        <s_prot>-msgtxt = TEXT-dts.
        <s_prot>-color  = ref_const->c_color_green.
      WHEN abap_off.
        CASE ls_export-bnstat.
          WHEN c_errkz_1.
            <s_prot>-msgtxt = TEXT-de1.
            <s_prot>-color  = ref_const->c_color_yellow.
          WHEN OTHERS.
            <s_prot>-msgtxt = TEXT-dte.
            <s_prot>-color  = ref_const->c_color_red.
        ENDCASE.
    ENDCASE.
    REPLACE: '&1' WITH ls_feb_save-refbn INTO <s_prot>-msgtxt,
             '&2' WITH ls_feb_save-blart INTO <s_prot>-msgtxt.

*-- Initialisierung
    CLEAR: ls_feb_data, ls_export, ls_feb_save, lt_ekpo, lt_ekkn,
           lt_kbld, l_flg_export.
*&---------------------------------------------------------------------*
  ENDLOOP.
*&---------------------------------------------------------------------*
* Exportstruktur für Anordnungen erstellen
  LOOP AT lt_ano_data INTO ls_ano_data.
*&---------------------------------------------------------------------*
*-- Auftragskennzeichen und Buchungstyp ermitteln
    get_aufkz_btyp( EXPORTING iv_sst_type   = c_sst_ano
                              is_sst_data   = ls_ano_data
                    IMPORTING ev_btyp       = l_btyp
                              es_sst_save   = ls_ano_save ).

    IF NOT ls_ano_save IS INITIAL.
      IF l_btyp EQ c_btyp_umb.
        ls_ano_save-btyp = c_btyp_kor.
      ELSE.
        ls_ano_save-btyp = l_btyp.
      ENDIF.
      IF ls_ano_save-blart EQ c_blart_22.
        CLEAR ls_ano_save-brtwr_sap.
      ENDIF.
      APPEND ls_ano_save TO lt_ano_save.
    ENDIF.

*-- Daten zum Beleg ermitteln
    read_document_data( EXPORTING iv_bukrs  = ref_const->c_bukrs_1000
                                  iv_gjahr  = ls_ano_data-gjahr
                                  iv_blart  = ls_ano_data-blart
                                  iv_refbn  = ls_ano_data-refbn
                                  iv_lotkz  = ls_ano_data-refbn
                                  iv_butyp  = l_btyp
                        IMPORTING et_bpdj   = lt_bpdj
                                  et_bpdz   = lt_bpdz
                                  et_kbld   = lt_kbld
                                  et_pso02  = lt_pso02
                                  et_pso02s = lt_pso02s
                                  et_pssec  = lt_pssec ).

*-- für Buchungstypen FUA, ANE und ALL Überprüfung durchführen und ggf.
*-- Buchungstyp neu setzen
    IF l_btyp EQ c_btyp_fua OR l_btyp EQ c_btyp_ane.
      check_btyp( EXPORTING it_pso02s = lt_pso02s
                   CHANGING cv_btyp   = l_btyp ).
    ELSEIF l_btyp EQ c_btyp_all.
      check_btyp( EXPORTING it_kbld = lt_kbld
                   CHANGING cv_btyp = l_btyp ).

      LOOP AT lt_kbld INTO ls_kbld.
        APPEND INITIAL LINE TO lt_pso02 ASSIGNING <s_pso02>.
        MOVE-CORRESPONDING ls_kbld TO <s_pso02>.
        MOVE: ls_kbld-fdatk TO <s_pso02>-zfbdt,
              lc_maber_so   TO <s_pso02>-maber,
              ls_kbld-ktext TO <s_pso02>-bktxt,
              ls_kbld-ptext TO <s_pso02>-sgtxt.

        IF NOT ls_kbld-kunnr IS INITIAL.
          APPEND INITIAL LINE TO lt_pssec ASSIGNING <s_pssec>.
          SELECT SINGLE * FROM kna1
                          INTO CORRESPONDING FIELDS OF <s_pssec>-bsec
                         WHERE kunnr EQ ls_kbld-kunnr.
          SELECT SINGLE * FROM knbk
                          INTO CORRESPONDING FIELDS OF <s_pssec>-bsec
                         WHERE kunnr EQ ls_kbld-kunnr.

        ELSE.
          APPEND INITIAL LINE TO lt_pssec ASSIGNING <s_pssec>.
          SELECT SINGLE * FROM lfa1
                          INTO CORRESPONDING FIELDS OF <s_pssec>-bsec
                         WHERE lifnr EQ ls_kbld-lifnr.
          SELECT SINGLE * FROM lfbk
                          INTO CORRESPONDING FIELDS OF <s_pssec>-bsec
                         WHERE lifnr EQ ls_kbld-lifnr.
        ENDIF.

      ENDLOOP.
    ENDIF.

*-- Datensätze vom Buchungstyp SPL in separate Tabelle schreiben
    IF l_btyp EQ c_btyp_spl.
      APPEND INITIAL LINE TO lt_ano_spl ASSIGNING <s_ano_spl>.
      MOVE-CORRESPONDING ls_ano_data TO <s_ano_spl>.
      READ TABLE lt_pso02 INTO ls_pso02
                          WITH KEY gjahr = ls_ano_data-gjahr
                                   belnr = ls_ano_data-refbn.
      IF sy-subrc IS INITIAL.
        <s_ano_spl>-lotkz = ls_pso02-lotkz.
      ENDIF.
      CONTINUE.
    ENDIF.

*&---------------------------------------------------------------------*
*-- Mapping durchführen
    CASE l_btyp.
*&---------------------------------------------------------------------*
*---- Buchungstyp 'AUF'
      WHEN c_btyp_auf.
        ls_export = map_auf_data( iv_btyp  = l_btyp
                                  is_data  = ls_ano_save
                                  it_bpdj  = lt_bpdj
                                  it_bpdz  = lt_bpdz ).
*&---------------------------------------------------------------------*
*---- Buchungstyp 'SST' oder 'SSR'; ggf. muss hier im Nachgang
*---- noch ein Datensatz vom Buchungstyp 'MER' erzeugt werden
*---- lt. Stand vom 12.12.2022 nicht notwendig (Flag gleich leer)
      WHEN c_btyp_sst.
        ls_export = map_sst_data( iv_btyp   = l_btyp
                                  is_data   = ls_ano_save
                                  it_pso02  = lt_pso02
                                  it_pssec  = lt_pssec ).

        READ TABLE lt_pso02 INTO ls_pso02 INDEX 1.
        IF sy-subrc IS INITIAL.
          IF ls_pso02-zlsch EQ lc_zlsch_m AND
            NOT ls_pso02-kunnr EQ c_kunnr_cpd.
            SELECT COUNT(*) FROM ztpa_pcharge_md UP TO 1 ROWS
             WHERE pernr EQ ( SELECT pernr FROM knb1
                               WHERE bukrs EQ ls_pso02-bukrs AND
                                     kunnr EQ ls_pso02-kunnr ) AND
                   kunnr EQ ls_pso02-kunnr AND
                   begda LE ls_pso02-budat AND
                   endda GE ls_pso02-budat.
            IF sy-subrc IS INITIAL.
              l_x_mer = abap_on.
            ELSE.
              CLEAR l_x_mer.
            ENDIF.
          ENDIF.
        ENDIF.
*&---------------------------------------------------------------------*
*---- Buchungstyp 'SAB' oder 'SZU'
      WHEN c_btyp_sab OR c_btyp_szu.
        ls_export = map_sab_szu_data( iv_btyp   = l_btyp
                                      iv_xeowi  = iv_xeowi
                                      is_data   = ls_ano_save
                                      it_pso02  = lt_pso02
                                      it_pssec  = lt_pssec ).
*&---------------------------------------------------------------------*
*---- Buchungstyp 'AES'
      WHEN c_btyp_aes.
        ls_export = map_aes_data( iv_btyp   = l_btyp
                                  iv_xeowi  = iv_xeowi
                                  is_data   = ls_ano_save
                                  it_pso02  = lt_pso02
                                  it_pssec  = lt_pssec ).
*&---------------------------------------------------------------------*
*---- Buchungstyp 'STU'
      WHEN c_btyp_stu.
        ls_export = map_stu_data( iv_btyp   = l_btyp
                                  is_data   = ls_ano_save
                                  it_pso02  = lt_pso02
                                  it_pso02s = lt_pso02s ).
*&---------------------------------------------------------------------*
*---- Buchungstyp 'APU' oder 'EPU'
      WHEN c_btyp_apu.
        ls_export = map_apu_epu_data( iv_btyp   = l_btyp
                                      is_data   = ls_ano_save
                                      it_pso02  = lt_pso02
                                      it_pso02s = lt_pso02s ).
*&---------------------------------------------------------------------*
*---- Buchungstyp 'DAO'
      WHEN c_btyp_dao.
        ls_export = map_dao_data( is_data   = ls_ano_save
                                  it_pso02  = lt_pso02
                                  it_pssec  = lt_pssec ).
*&---------------------------------------------------------------------*
*---- Buchungstyp 'ANE'
      WHEN c_btyp_ane.
        ls_export = map_ane_data( iv_btyp   = l_btyp
                                  is_data   = ls_ano_save
                                  it_pso02  = lt_pso02
                                  it_pso02s = lt_pso02s
                                  it_pssec  = lt_pssec ).

*------ Prüfen, ob es tagesgleiche Änderungen an der zugehörigen
*------ Bestellung gibt (FAE-Satz)
        check_mb_fae( EXPORTING is_ano_data = ls_ano_save
                                iv_xblnr    = ls_export-xblnr
                       CHANGING cref_export = ref_expo
                                ct_feb_save = lt_feb_save ).

*------ Abbau der Mittelbindung (Anpassung Betrag) in Tabelle
*------ ZSST_SAP_DHB_FEB
        reduce_mb( EXPORTING is_ano_data = ls_ano_save
                             iv_xblnr    = ls_export-xblnr
                             iv_txtsl    = ls_export-txtsl
                    CHANGING ct_feb_save = lt_feb_save ).

*------ Füllen der Range für Bestellungen, um später ggf. noch
*------ die notwendigen FAE-Sätze zu bilden (nur bei Teilzahlung)
        IF ls_ano_save-blart EQ c_blart_rn AND
           ls_export-txtsl EQ lc_value_3.
          DESCRIBE FIELD l_ebeln LENGTH l_len IN CHARACTER MODE.
          CLEAR l_ebeln. l_ebeln = ls_ano_save-aufkz(l_len).
          ref_help->set_range_value( EXPORTING iv_value_low = l_ebeln
                                      CHANGING ct_range     = lr_ebeln ).
        ENDIF.
*&---------------------------------------------------------------------*
*---- Buchungstyp 'FUA'
      WHEN c_btyp_fua.
        ls_export = map_fua_data( iv_btyp   = l_btyp
                                  is_data   = ls_ano_save
                                  it_ano    = it_ano_data
                                  it_pso02  = lt_pso02
                                  it_pso02s = lt_pso02s
                                  it_pssec  = lt_pssec ).
*&---------------------------------------------------------------------*
*---- Buchungstyp 'ALL'
      WHEN c_btyp_all.
        ls_export = map_all_data( iv_btyp   = l_btyp
                                  is_data   = ls_ano_save
                                  it_pso02  = lt_pso02
                                  it_pssec  = lt_pssec ).
*&---------------------------------------------------------------------*
*---- Buchungstyp 'UMB' (KOR)
      WHEN c_btyp_umb.
        ls_export = map_kor_data( iv_btyp   = c_btyp_kor
                                  is_data   = ls_ano_save
                                  it_pso02  = lt_pso02
                                  it_pso02s = lt_pso02s ).
*&---------------------------------------------------------------------*
    ENDCASE.
*&---------------------------------------------------------------------*
    IF ls_export-bnstat EQ c_bnstat_0.
      APPEND ls_export TO et_export.
      l_flg_export = abap_on.
    ELSE.
      l_flg_export = abap_off.
      READ TABLE lt_ano_save FROM ls_ano_save
                             TRANSPORTING NO FIELDS.
      IF sy-subrc IS INITIAL.
        DELETE TABLE lt_ano_save FROM ls_ano_save.
      ENDIF.
    ENDIF.

*-- ggf. nachträglich noch den MER-Buchungssatz zum SST-Satz erzeugen
    IF ls_export-btyp   EQ c_btyp_sst AND
       ls_export-bnstat EQ c_bnstat_0 AND
       l_x_mer          EQ abap_on.

      ls_export = map_mer_mae_data( iv_btyp   = c_btyp_mer
                                    is_data   = ls_ano_save
                                    it_pso02  = lt_pso02
                                    it_pssec  = lt_pssec ).
      IF ls_export-bnstat EQ c_bnstat_0.
        APPEND ls_export TO et_export. CLEAR l_x_mer.
      ENDIF.
    ENDIF.

*-- Auswertung Flag 'Export'
    APPEND INITIAL LINE TO et_prot ASSIGNING <s_prot>.
    MOVE-CORRESPONDING ls_ano_save TO <s_prot>.
    MOVE: ls_ano_save-brtwr_sap TO <s_prot>-brtwr,
          l_btyp                TO <s_prot>-btyp.
    CASE l_flg_export.
      WHEN abap_on.
        <s_prot>-msgtxt = TEXT-dts.
        <s_prot>-color  = ref_const->c_color_green.
      WHEN abap_off.
        CASE ls_export-bnstat.
          WHEN c_errkz_1.
            <s_prot>-msgtxt = TEXT-de1.
            <s_prot>-color  = ref_const->c_color_yellow.
          WHEN OTHERS.
            <s_prot>-msgtxt = TEXT-dte.
            <s_prot>-color  = ref_const->c_color_red.
        ENDCASE.
    ENDCASE.
    REPLACE: '&1' WITH ls_ano_save-refbn INTO <s_prot>-msgtxt,
             '&2' WITH ls_ano_save-blart INTO <s_prot>-msgtxt.

*-- Buchungstyp und Kassenzeichen in lt_ano_save aktualisieren;
*-- keine Aktualisierung wenn MER-/MAE-Sätze
    IF NOT ( ls_export-btyp EQ c_btyp_mer OR
             ls_export-btyp EQ c_btyp_mae ).
      READ TABLE lt_ano_save FROM ls_ano_save
                             ASSIGNING <s_ano_save>.
      IF sy-subrc IS INITIAL.
        <s_ano_save>-xblnr = ls_export-kassz.
        <s_ano_save>-btyp  = ls_export-btyp.
      ENDIF.
    ENDIF.

*-- Initialisierung
    CLEAR: ls_ano_data, ls_export, ls_ano_save, lt_bpdj, lt_bpdz,
           lt_pso02, lt_pso02s, lt_pssec, lt_kbld, l_flg_export,
           l_x_mer.
*&---------------------------------------------------------------------*
  ENDLOOP.
*&---------------------------------------------------------------------*

* Exportstruktur(en) für Splitt-Anordnungen PSM erstellen
  lt_ano_mm = lt_ano_spl.
  DELETE: lt_ano_mm  WHERE NOT blart EQ c_blart_rn,
          lt_ano_spl WHERE blart EQ c_blart_rn.
  SORT lt_ano_spl BY lotkz refbn.
  DELETE ADJACENT DUPLICATES FROM lt_ano_spl COMPARING lotkz.
*&---------------------------------------------------------------------*
  LOOP AT lt_ano_spl INTO ls_ano_spl.
*&---------------------------------------------------------------------*
*-- Daten zur Anordnung ermitteln
    read_document_data( EXPORTING iv_bukrs  = ref_const->c_bukrs_1000
                                  iv_gjahr  = ls_ano_spl-gjahr
                                  iv_blart  = ls_ano_spl-blart
                                  iv_refbn  = ls_ano_spl-refbn
                                  iv_lotkz  = ls_ano_spl-lotkz
                                  iv_butyp  = c_btyp_spl
                        IMPORTING et_pso02  = lt_pso02
                                  et_pso02s = lt_pso02s
                                  et_pssec  = lt_pssec ).

*-- Mapping durchführen
    LOOP AT lt_pso02 INTO ls_pso02.
      CLEAR l_tabix. l_tabix = sy-tabix.
*---- Füllen der zu übergebenden Tabellen
      lt_pso02_spl  = lt_pso02.
      lt_pso02s_spl = lt_pso02s.
      lt_pssec_spl  = lt_pssec.
      DELETE: lt_pso02_spl  WHERE NOT belnr EQ ls_pso02-belnr,
              lt_pso02s_spl WHERE NOT itabkey EQ ls_pso02-itabkey,
              lt_pssec_spl  WHERE NOT itabkey EQ ls_pso02-itabkey.

      READ TABLE lt_ano_save INTO ls_ano_save
                             WITH KEY gjahr = ls_pso02-gjahr
                                      refbn = ls_pso02-belnr.
*---- in Abhängingkeit von SY-TABIX muss der Buchungstyp gesetzt
*---- werden und die Gesamtsumme der Anordnung ermittelt werden
      CASE l_tabix.
        WHEN lc_index_1.
          LOOP AT lt_pso02s_spl INTO ls_pso02s
                               WHERE NOT kblnr IS INITIAL OR
                                     NOT ebeln IS INITIAL.
            EXIT.
          ENDLOOP.
          IF NOT sy-subrc IS INITIAL.
            l_btyp = c_btyp_fua.
          ELSE.
            l_btyp = c_btyp_ane.
          ENDIF.

          READ TABLE lt_pso02_spl ASSIGNING <s_pso02>
                                  WITH KEY bukrs = ls_pso02-bukrs
                                           belnr = ls_pso02-belnr
                                           gjahr = ls_pso02-gjahr.
          LOOP AT lt_pso02 INTO ls_pso02
                          WHERE bukrs EQ <s_pso02>-bukrs AND
                                gjahr EQ <s_pso02>-gjahr AND
                                lotkz EQ <s_pso02>-lotkz AND NOT
                                belnr EQ <s_pso02>-belnr.
            ADD: ls_pso02-wrbtr TO <s_pso02>-wrbtr,
                 ls_pso02-dmbtr TO <s_pso02>-dmbtr,
                 ls_pso02-mwsts TO <s_pso02>-mwsts,
                 ls_pso02-wmwst TO <s_pso02>-wmwst.
          ENDLOOP.

        WHEN OTHERS.
          l_btyp = c_btyp_kor.
      ENDCASE.

*---- Mapping je Buchungstyp
      CASE l_btyp.
*------ Buchungstyp 'FUA'
        WHEN c_btyp_fua.
          ls_export = map_fua_data( iv_btyp   = l_btyp
                                    is_data   = ls_ano_save
                                    it_ano    = it_ano_data
                                    it_pso02  = lt_pso02_spl
                                    it_pso02s = lt_pso02s_spl
                                    it_pssec  = lt_pssec_spl ).

          CLEAR l_kor_refspl.
          CONCATENATE ls_export-belnr ls_export-blpos INTO l_kor_refspl.

*------ Buchungstyp 'ANE'
        WHEN c_btyp_ane.
          ls_export = map_ane_data( iv_btyp   = l_btyp
                                    iv_x_spl  = abap_on
                                    is_data   = ls_ano_save
                                    it_pso02  = lt_pso02_spl
                                    it_pso02s = lt_pso02s_spl
                                    it_pssec  = lt_pssec_spl ).

          CLEAR l_kor_refspl.
          CONCATENATE ls_export-belnr ls_export-blpos INTO l_kor_refspl.

*-------- Prüfen, ob es tagesgleiche Änderungen an der zugehörigen
*-------- Bestellung gibt (FAE-Satz)
          CLEAR l_xblnr. l_xblnr = ls_export-xblnr.
          check_mb_fae( EXPORTING is_ano_data = ls_ano_save
                                  iv_xblnr    = l_xblnr
                         CHANGING cref_export = ref_expo
                                  ct_feb_save = lt_feb_save ).

*-------- Abbau der Mittelbindung (Anpassung Betrag) in Tabelle
*-------- ZSST_SAP_DHB_FEB
          CLEAR l_xblnr. l_xblnr = ls_export-xblnr.
          reduce_mb( EXPORTING is_ano_data = ls_ano_save
                               iv_xblnr    = l_xblnr
                               iv_txtsl    = ls_export-txtsl
                      CHANGING ct_feb_save = lt_feb_save ).

*------ Buchungstyp 'KOR'
          WHEN c_btyp_kor.
            ls_export = map_kor_data( iv_btyp   = l_btyp
                                      iv_refspl = l_kor_refspl
                                      is_data   = ls_ano_save
                                      it_pso02  = lt_pso02_spl
                                      it_pso02s = lt_pso02s_spl ).

*-------- Abbau der Mittelbindung (Anpassung Betrag) in Tabelle
*-------- ZSST_SAP_DHB_FEB
          CLEAR l_xblnr. l_xblnr = ls_export-rese4.
          reduce_mb( EXPORTING is_ano_data = ls_ano_save
                               iv_xblnr    = l_xblnr
                               iv_txtsl    = ls_export-txtsl
                      CHANGING ct_feb_save = lt_feb_save ).

      ENDCASE.

      IF ls_export-bnstat EQ c_bnstat_0.
        APPEND ls_export TO et_export.
        l_flg_export = abap_on.
      ELSE.
        l_flg_export = abap_off.
        READ TABLE lt_ano_save FROM ls_ano_save
                               TRANSPORTING NO FIELDS.
        IF sy-subrc IS INITIAL.
          DELETE TABLE lt_ano_save FROM ls_ano_save.
        ENDIF.
      ENDIF.

*---- Auswertung Flag 'Export'
      APPEND INITIAL LINE TO et_prot ASSIGNING <s_prot>.
      MOVE-CORRESPONDING ls_ano_save TO <s_prot>.
      MOVE: ls_ano_save-brtwr_sap TO <s_prot>-brtwr,
            l_btyp                TO <s_prot>-btyp.
      CASE l_flg_export.
        WHEN abap_on.
          <s_prot>-msgtxt = TEXT-dts.
          <s_prot>-color  = ref_const->c_color_green.
        WHEN abap_off.
          CASE ls_export-bnstat.
            WHEN c_errkz_1.
              <s_prot>-msgtxt = TEXT-de1.
              <s_prot>-color  = ref_const->c_color_yellow.
            WHEN OTHERS.
              <s_prot>-msgtxt = TEXT-dte.
              <s_prot>-color  = ref_const->c_color_red.
          ENDCASE.
      ENDCASE.
      REPLACE: '&1' WITH ls_ano_save-refbn INTO <s_prot>-msgtxt,
               '&2' WITH ls_ano_save-blart INTO <s_prot>-msgtxt.

*---- Buchungstyp und Kassenzeichen in lt_ano_save aktualisieren
      READ TABLE lt_ano_save FROM ls_ano_save
                             ASSIGNING <s_ano_save>.
      IF sy-subrc IS INITIAL.
        <s_ano_save>-xblnr = ls_export-kassz.
        <s_ano_save>-btyp  = ls_export-btyp.
      ENDIF.

*---- Initialisierung
      CLEAR: ls_ano_save, ls_export, lt_pso02_spl, lt_pso02s_spl,
             lt_pssec_spl, l_flg_export.

    ENDLOOP.

*-- Initialisierung
    CLEAR: ls_ano_save, ls_export, lt_pso02, lt_pso02s, lt_pssec,
           l_flg_export, ls_ano_spl, l_tabix.
*&---------------------------------------------------------------------*
  ENDLOOP.
*&---------------------------------------------------------------------*

* Exportstruktur für Splitt-Anordnungen MM erzeugen
  SORT lt_ano_mm BY lotkz refbn.
*&---------------------------------------------------------------------*
  LOOP AT lt_ano_mm INTO ls_ano_mm.
*&---------------------------------------------------------------------*
    CLEAR lt_ano_spl. lt_ano_spl = lt_ano_mm.
    DELETE lt_ano_spl WHERE: NOT lotkz EQ ls_ano_mm-lotkz,
                             NOT refbn EQ ls_ano_mm-refbn.

*-- Mapping durchführen
    LOOP AT lt_ano_spl INTO ls_ano_spl.
      CLEAR l_tabix. l_tabix = sy-tabix.
*---- Daten zur Anordnung ermitteln
      read_document_data( EXPORTING iv_bukrs  = ref_const->c_bukrs_1000
                                    iv_gjahr  = ls_ano_spl-gjahr
                                    iv_blart  = ls_ano_spl-blart
                                    iv_refbn  = ls_ano_spl-refbn
                                    iv_lotkz  = ls_ano_spl-lotkz
                                    iv_butyp  = c_btyp_spl
                          IMPORTING et_pso02  = lt_pso02
                                    et_pso02s = lt_pso02s
                                    et_pssec  = lt_pssec ).

      READ TABLE lt_ano_save INTO ls_ano_save
                             WITH KEY gjahr = ls_ano_spl-gjahr
                                      refbn = ls_ano_spl-refbn
                                      fistl = ls_ano_spl-fistl
                                      fipex = ls_ano_spl-fipex
                                      aufkz = ls_ano_spl-aufkz.
*---- in Abhängingkeit von SY-TABIX muss der Buchungstyp gesetzt
*---- werden und die Gesamtsumme der Anordnung ermittelt werden
      CASE l_tabix.
        WHEN lc_index_1.
          l_btyp = c_btyp_ane.
        WHEN OTHERS.
          l_btyp = c_btyp_kor.
      ENDCASE.

*---- Mapping je Buchungstyp
      CASE l_btyp.
*------ Buchungstyp 'ANE'
        WHEN c_btyp_ane.
          ls_export = map_ane_data( iv_btyp   = l_btyp
                                    iv_x_spl  = abap_on
                                    is_data   = ls_ano_save
                                    it_pso02  = lt_pso02
                                    it_pso02s = lt_pso02s
                                    it_pssec  = lt_pssec ).

          CLEAR l_kor_refspl.
          CONCATENATE ls_export-belnr ls_export-blpos INTO l_kor_refspl.

*-------- Prüfen, ob es tagesgleiche Änderungen an der zugehörigen
*-------- Bestellung gibt (FAE-Satz)
          CLEAR l_xblnr. l_xblnr = ls_export-xblnr.
          check_mb_fae( EXPORTING is_ano_data = ls_ano_save
                                  iv_xblnr    = l_xblnr
                         CHANGING cref_export = ref_expo
                                  ct_feb_save = lt_feb_save ).

*-------- Abbau der Mittelbindung (Anpassung Betrag) in Tabelle
*-------- ZSST_SAP_DHB_FEB
          CLEAR l_xblnr. l_xblnr = ls_export-xblnr.
          reduce_mb( EXPORTING is_ano_data = ls_ano_save
                               iv_xblnr    = l_xblnr
                               iv_txtsl    = ls_export-txtsl
                      CHANGING ct_feb_save = lt_feb_save ).

*------ Buchungstyp 'KOR'
        WHEN c_btyp_kor.
          ls_export = map_kor_data( iv_btyp   = l_btyp
                                    iv_refspl = l_kor_refspl
                                    is_data   = ls_ano_save
                                    it_pso02  = lt_pso02
                                    it_pso02s = lt_pso02s ).

*-------- Prüfen, ob es tagesgleiche Änderungen an der zugehörigen
*-------- Bestellung gibt (FAE-Satz o. FEB-Satz)
          CLEAR l_xblnr. l_xblnr = ls_export-rese4.
          check_mb_fae( EXPORTING is_ano_data = ls_ano_save
                                  iv_xblnr    = l_xblnr
                         CHANGING cref_export = ref_expo
                                  ct_feb_save = lt_feb_save ).

*-------- Abbau der Mittelbindung (Anpassung Betrag) in Tabelle
*-------- ZSST_SAP_DHB_FEB
          CLEAR l_xblnr. l_xblnr = ls_export-rese4.
          reduce_mb( EXPORTING is_ano_data = ls_ano_save
                               iv_xblnr    = l_xblnr
                               iv_txtsl    = ls_export-txtsl
                      CHANGING ct_feb_save = lt_feb_save ).

      ENDCASE.

      IF ls_export-bnstat EQ c_bnstat_0.
        APPEND ls_export TO et_export.
        l_flg_export = abap_on.
      ELSE.
        l_flg_export = abap_off.
        READ TABLE lt_ano_save FROM ls_ano_save
                               TRANSPORTING NO FIELDS.
        IF sy-subrc IS INITIAL.
          DELETE TABLE lt_ano_save FROM ls_ano_save.
        ENDIF.
      ENDIF.

*---- Auswertung Flag 'Export'
      APPEND INITIAL LINE TO et_prot ASSIGNING <s_prot>.
      MOVE-CORRESPONDING ls_ano_save TO <s_prot>.
      MOVE: ls_ano_save-brtwr_sap TO <s_prot>-brtwr,
            l_btyp                TO <s_prot>-btyp.
      CASE l_flg_export.
        WHEN abap_on.
          <s_prot>-msgtxt = TEXT-dts.
          <s_prot>-color  = ref_const->c_color_green.
        WHEN abap_off.
          CASE ls_export-bnstat.
            WHEN c_errkz_1.
              <s_prot>-msgtxt = TEXT-de1.
              <s_prot>-color  = ref_const->c_color_yellow.
            WHEN OTHERS.
              <s_prot>-msgtxt = TEXT-dte.
              <s_prot>-color  = ref_const->c_color_red.
          ENDCASE.
      ENDCASE.
      REPLACE: '&1' WITH ls_ano_save-refbn INTO <s_prot>-msgtxt,
               '&2' WITH ls_ano_save-blart INTO <s_prot>-msgtxt.

*---- Range für Bestellnummern aufbauen
      DESCRIBE FIELD l_ebeln LENGTH l_len IN CHARACTER MODE.
      CLEAR l_ebeln. l_ebeln = ls_ano_save-aufkz(l_len).
      ref_help->set_range_value( EXPORTING iv_value_low = l_ebeln
                                  CHANGING ct_range     = lr_ebeln ).

*---- Buchungstyp und Kassenzeichen in lt_ano_save aktualisieren
      READ TABLE lt_ano_save FROM ls_ano_save
                             ASSIGNING <s_ano_save>.
      IF sy-subrc IS INITIAL.
        <s_ano_save>-xblnr = ls_export-kassz.
        <s_ano_save>-btyp  = ls_export-btyp.
      ENDIF.

*---- Initialisierung
      CLEAR: ls_ano_save, ls_export, lt_pso02, lt_pso02s, lt_pssec,
             l_flg_export.
    ENDLOOP.

*-- Löschen der Tabelle lt_ano_mm
    DELETE lt_ano_mm WHERE: lotkz EQ ls_ano_mm-lotkz,
                            refbn EQ ls_ano_mm-refbn.

*-- Initialisierung
    CLEAR: ls_ano_save, ls_export, lt_pso02, lt_pso02s, lt_pssec,
           l_flg_export, lt_export.

*&---------------------------------------------------------------------*
  ENDLOOP.
*&---------------------------------------------------------------------*

* Daten zu Bestellungen (aktuellen Stand) nachlesen, um ggf. FAE-
* Sätze zu generieren (z.B. Schlussrechnung, Skonto)
  SORT lr_ebeln BY low.
  DELETE ADJACENT DUPLICATES FROM lr_ebeln COMPARING ALL FIELDS.

  IF NOT lines( lr_ebeln ) IS INITIAL AND iv_xerror EQ abap_off.
    lt_me_data = read_me_data( iv_gjahr = pa_gjahr
                               iv_xgjw  = pa_xgjw
                               iv_xinit = pa_xinit
                               ir_ebeln = lr_ebeln[]
                               ir_aedat = lr_cpudt[] ).

    compare_me_mb_data( EXPORTING it_me_data  = lt_me_data
                        IMPORTING et_export   = lt_export
                         CHANGING ct_feb_save = lt_feb_save ).

    IF NOT lines( lt_export ) IS INITIAL.
      APPEND LINES OF lt_export TO et_export. CLEAR lt_export.
    ENDIF.
  ENDIF.

* Positionen neu nummerieren
  LOOP AT et_export ASSIGNING <s_export>.
    IF sy-tabix LT lc_tabix_999.
      l_blpos = sy-tabix.
    ELSE.
      l_blpos_c4 = sy-tabix.
      l_blpos    = l_blpos_c4+1(3).
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING  input  = l_blpos
      IMPORTING  output = <s_export>-blpos.
  ENDLOOP.

* Fortschreiben der Tabelle ZSST_SAP_DHB_FEB / ZSST_SAP_DHB_ANO
  MODIFY: (c_sst_tabn_feb) FROM TABLE lt_feb_save,
          (c_sst_tabn_ano) FROM TABLE lt_ano_save.
  IF sy-subrc IS INITIAL. COMMIT WORK AND WAIT. ENDIF.
*&---------------------------------------------------------------------*
ENDMETHOD.                    "build_export_data


*----------------------------------------------------------------------*
* Methode MAINTAIN_DATA_XGJW
*----------------------------------------------------------------------*
METHOD maintain_data_xgjw.

* lokale Datendeklaration
  CONSTANTS: lc_faedt_from TYPE char4 VALUE '0101',
             lc_wrbtr_init TYPE wrbtr VALUE IS INITIAL,
             lc_offset_2   TYPE i VALUE 2,
             lc_number     TYPE c LENGTH 10 VALUE '0123456789',
             lc_blart_12   TYPE blart VALUE '12'.

  DATA: lt_feb_save   TYPE tt_feb_data,
        lt_export_tmp TYPE tt_sst_export,
        lt_prot_tmp   TYPE tt_sst_prot,
        ls_feb_data   LIKE LINE OF it_feb_data,
        ls_feb_search LIKE LINE OF lt_feb_save.

  DATA: l_gjahr  TYPE gjahr,
        l_faedt  TYPE datum,
        l_wrbtr  TYPE wrbtr,
        l_belnr  TYPE zbelnr,
        l_lotkz  TYPE pso_lotkz,
        l_len    TYPE i.

  DATA: ls_kblk TYPE kblk.

  DATA: lr_belnr_dao TYPE RANGE OF zbelnr.

  FIELD-SYMBOLS: <s_export>   LIKE LINE OF lt_export_tmp,
                 <s_feb_save> LIKE LINE OF lt_feb_save,
                 <s_prot>     LIKE LINE OF lt_prot_tmp.

* Prüfen, ob Kennzeichen JW gesetzt ist
  IF NOT iv_xgjw EQ abap_on.
    RETURN.
  ENDIF.

* temporäres Fälligkeitsdatum erstellen
  l_gjahr = iv_gjahr - 1.
  CONCATENATE l_gjahr lc_faedt_from INTO l_faedt.

* Fälligkeitsdatum prüfen und ggf. anpassen
  LOOP AT ct_export ASSIGNING <s_export>.
    IF <s_export>-faedt LT l_faedt.
      <s_export>-faedt = l_faedt.
    ENDIF.
    CLEAR l_wrbtr. l_wrbtr = <s_export>-betr1.
    IF l_wrbtr EQ lc_wrbtr_init.
      DELETE ct_export.
    ENDIF.
  ENDLOOP.

* VE's dürfen nicht übertragen werden
  LOOP AT it_feb_data INTO ls_feb_data
                     WHERE gjahr EQ iv_gjahr AND
                           blart EQ c_blart_ve.
    DESCRIBE FIELD l_belnr LENGTH l_len IN CHARACTER MODE.
    CLEAR l_belnr. l_belnr = ls_feb_data-refbn+lc_offset_2(l_len).
    LOOP AT ct_export ASSIGNING <s_export>
                      WHERE btyp  EQ c_btyp_feb AND
                            hhj   EQ iv_gjahr   AND
                            belnr EQ l_belnr.
      DELETE ct_export.
    ENDLOOP.

  ENDLOOP.

* FE zu DAO aus Vorjahr dürfen nicht als FAE übergeben werden
  LOOP AT it_feb_data INTO ls_feb_data
                     WHERE gjahr EQ iv_gjahr AND
                           blart EQ c_blart_fe.

    SELECT SINGLE * FROM kblk INTO ls_kblk
                   WHERE belnr EQ ls_feb_data-refbn.
    IF sy-subrc IS INITIAL.
      DESCRIBE FIELD l_lotkz LENGTH l_len IN CHARACTER MODE.
      l_lotkz = ls_kblk-ktext(l_len).
      IF l_lotkz CO lc_number.
        SELECT COUNT(*) FROM psokpf UP TO 1 ROWS
                       WHERE lotkz EQ l_lotkz                 AND
                             bukrs EQ ref_const->c_bukrs_1000 AND
                             blart EQ lc_blart_12             AND
                             gjahr LT iv_gjahr.
        IF sy-subrc IS INITIAL.
          DESCRIBE FIELD l_belnr LENGTH l_len IN CHARACTER MODE.
          CLEAR l_belnr.
          l_belnr = ls_feb_data-refbn+lc_offset_2(l_len).
          ref_help->set_range_value(
                      EXPORTING iv_value_low = l_belnr
                       CHANGING ct_range     = lr_belnr_dao ).

        ENDIF.
        CLEAR: l_lotkz, ls_kblk.
      ENDIF.
    ENDIF.
    CLEAR: l_lotkz, ls_kblk, l_belnr.
  ENDLOOP.

* Exportdatei duplizieren und anhängen; ggf. im Vorfeld ermittelte
* Belegnummern zu DAO aus Vorjahr entfernen
  lt_export_tmp = ct_export.

  IF NOT lines( lr_belnr_dao ) IS INITIAL.
    DELETE lt_export_tmp WHERE btyp  EQ c_btyp_feb AND
                               hhj   EQ iv_gjahr   AND
                               belnr IN lr_belnr_dao.
  ENDIF.

  LOOP AT lt_export_tmp ASSIGNING <s_export>.
*-- Änderung von Daten
    <s_export>-btyp  = c_btyp_fae.
    <s_export>-hhj   = <s_export>-hhj - 1.
    <s_export>-xblnr = <s_export>-rese1.
    CLEAR: <s_export>-faedt, <s_export>-txtsl.
    <s_export>-belkz = c_kz_e.
    CLEAR: <s_export>-rese1, <s_export>-lifnr, <s_export>-bnknr.
    <s_export>-grund = TEXT-ajw.
  ENDLOOP.

  APPEND LINES OF lt_export_tmp TO ct_export.

* FEB-Daten anpassen und Tab. ZSST_SAP_DHB_FEB modifizieren sowie
* Protokolldatei anpassen
  LOOP AT it_feb_data INTO ls_feb_data.
    l_gjahr = ls_feb_data-gjahr - 1.
    SELECT SINGLE * FROM zsst_sap_dhb_feb
                    INTO ls_feb_search
                   WHERE gjahr EQ l_gjahr           AND
                         refbn EQ ls_feb_data-refbn AND
                         fistl EQ ls_feb_data-fistl AND
                         fipex EQ ls_feb_data-fipex AND
                         blart EQ ls_feb_data-blart.
    IF sy-subrc IS INITIAL.
      APPEND INITIAL LINE TO lt_feb_save ASSIGNING <s_feb_save>.
      <s_feb_save> = ls_feb_search.
      <s_feb_save>-brtwr_sap = <s_feb_save>-brtwr_sap -
                               ls_feb_data-brtwr_sap.

      APPEND INITIAL LINE TO lt_prot_tmp ASSIGNING <s_prot>.
      MOVE-CORRESPONDING ls_feb_search TO <s_prot>.
      MOVE: c_btyp_fae               TO <s_prot>-btyp,
            ref_const->c_color_green TO <s_prot>-color,
            TEXT-djw                 TO <s_prot>-msgtxt.
      MULTIPLY <s_prot>-brtwr BY -1.
    ENDIF.
  ENDLOOP.

  MODIFY (c_sst_tabn_feb) FROM TABLE lt_feb_save.
  IF sy-subrc IS INITIAL. COMMIT WORK AND WAIT. ENDIF.

  APPEND LINES OF lt_prot_tmp TO ct_prot.

ENDMETHOD.                    "maintain_data_xgjw


*----------------------------------------------------------------------*
* Methode CREATE_SAVE_FILES
*----------------------------------------------------------------------*
METHOD create_save_files.

* lokale Datendeklaration
  CONSTANTS: lc_path_prd TYPE pathintern VALUE 'Z_SST_HAMTRANS',
             lc_path_tmp TYPE pathintern VALUE 'Z_SST_HAMTRANS_TEST'.

  CONSTANTS: lc_belkz_b      TYPE zbelkz VALUE 'B',
             lc_txtsl_3      TYPE c LENGTH 1 VALUE '3',
             lc_txtsl_4      TYPE c LENGTH 1 VALUE '4',
             lc_lines_1      TYPE i VALUE 1,
             lc_refbt_110    TYPE fm_refbtyp VALUE '110',
             lc_btart_0500   TYPE fm_btart VALUE '0500',
             lc_fkbtr_init   TYPE fm_fkbtr VALUE IS INITIAL,
             lc_string_sap   TYPE string VALUE '.SAP.&1',
             lc_value_3101   TYPE c LENGTH 4 VALUE '3101',
             lc_fileext_init TYPE n2file_ext VALUE IS INITIAL.

  TYPES: ts_export TYPE ztpa_s_sap_dhb,
         tt_export TYPE STANDARD TABLE OF ts_export.

  DATA: l_vorsatz   TYPE char255,
        l_nachsatz  TYPE char255,
        l_file      TYPE localfile.

  DATA: l_checksum(21)  TYPE n,
        l_anzahl(8)     TYPE n,
        l_len           TYPE i,
        l_lines         TYPE i,
        l_tabix         TYPE i,
        l_struc         TYPE tabname VALUE 'ZTPA_S_SAP_DHB',
        l_refbn         TYPE co_refbn,
        l_belnr         TYPE zbelnr,
        l_kblnr         TYPE kblnr,
        l_gennr         TYPE p011_dfnum,
        l_string_bi_vor TYPE string VALUE '000BI',
        l_string_bi_end TYPE string VALUE '999BI',
        l_string_sap    TYPE string VALUE '.SAP.3101',
        l_separator     TYPE char1 VALUE '|'.

  DATA: lr_eplan TYPE RANGE OF numc2,
        lr_btyp  TYPE RANGE OF zbtyp,
        lr_xblnr TYPE RANGE OF xblnr,
        ls_eplan LIKE LINE OF lr_eplan.

  DATA: lt_data_fae TYPE tt_export,
        lt_ane_mb   TYPE tt_export,
        lt_ane_tmp  TYPE tt_export,
        lt_eplan    TYPE tt_export,
        lt_merge    TYPE tt_export,
        ls_data     LIKE LINE OF it_export,
        ls_merge    LIKE LINE OF lt_merge,
        ls_export   LIKE LINE OF it_export,
        ls_feb_data TYPE zsst_sap_dhb_feb,
        ls_epl_kap  TYPE ztpa_sst_epl_kap.

  FIELD-SYMBOLS: <s_merge> LIKE LINE OF lt_merge,
                 <s_fae>   LIKE LINE OF lt_data_fae.

* Übernahme Importparameter
  lt_eplan = it_export.

* Trennen der Datei in Einzelpläne;
  SORT lt_eplan BY berei.

  DELETE ADJACENT DUPLICATES FROM lt_eplan COMPARING berei.

  LOOP AT lt_eplan INTO ls_data.
    ref_help->set_range_value( EXPORTING iv_value_low = ls_data-berei
                                CHANGING ct_range     = lr_eplan ).
  ENDLOOP.

* Range für spezielle Buchungstypen
  ref_help->set_range_value( EXPORTING iv_value_low = c_btyp_fua
                              CHANGING ct_range     = lr_btyp ).
  ref_help->set_range_value( EXPORTING iv_value_low = c_btyp_ane
                              CHANGING ct_range     = lr_btyp ).

  LOOP AT lr_eplan INTO ls_eplan.
    CLEAR: l_checksum, l_vorsatz, l_nachsatz, l_file.

    lt_merge = it_export.
    DELETE lt_merge WHERE NOT berei EQ ls_eplan-low.

*-- die ANE-Sätze mit Bezug zu einer Mittelbindung, die das Kennzei-
*-- chen TXTSL = 4 haben müssen untersucht und ggf. angepasst werden;
*-- bei gleicher Mittelbindung darf nur der letzte Satz den Wert 4
*-- haben, die anderen Sätze müssen die 3 bekommen
    CLEAR lt_ane_mb. APPEND LINES OF lt_merge TO lt_ane_mb.
    DELETE lt_ane_mb WHERE: NOT btyp  EQ c_btyp_ane,
                            NOT txtsl EQ lc_txtsl_4.
    SORT lt_ane_mb BY btyp xblnr blpos.
    CLEAR lr_xblnr.

    LOOP AT lt_ane_mb INTO ls_export.
      ref_help->set_range_value(
                  EXPORTING iv_value_low = ls_export-xblnr
                   CHANGING ct_range     = lr_xblnr ).
    ENDLOOP.
    SORT lr_xblnr BY low.
    DELETE ADJACENT DUPLICATES FROM lr_xblnr COMPARING low.
    LOOP AT lr_xblnr ASSIGNING FIELD-SYMBOL(<ls_xblnr>).
      CLEAR lt_ane_tmp. APPEND LINES OF lt_ane_mb TO lt_ane_tmp.
      DELETE lt_ane_tmp WHERE NOT xblnr EQ <ls_xblnr>-low.
      IF lines( lt_ane_tmp ) GT lc_lines_1.
        DESCRIBE FIELD l_kblnr LENGTH l_len IN CHARACTER MODE.
        l_kblnr = <ls_xblnr>-low(l_len).

        SELECT COUNT(*) FROM kblk UP TO 1 ROWS
                       WHERE belnr EQ l_kblnr.
        IF NOT sy-subrc IS INITIAL.
          DELETE lt_ane_mb WHERE xblnr EQ <ls_xblnr>-low.
        ELSE.
          l_lines = lines( lt_ane_tmp ).
          LOOP AT lt_ane_tmp INTO ls_export.
            l_tabix = sy-tabix.
            LOOP AT lt_merge ASSIGNING <s_merge>
                             WHERE btyp EQ ls_export-btyp   AND
                                   hhj  EQ ls_export-hhj    AND
                                   belnr EQ ls_export-belnr AND
                                   blpos EQ ls_export-blpos AND
                                   xblnr EQ ls_export-xblnr.
              IF NOT l_tabix EQ l_lines.
                <s_merge>-txtsl = lc_txtsl_3.
              ELSE.
                <s_merge>-txtsl = lc_txtsl_4.
              ENDIF.
            ENDLOOP.
          ENDLOOP.
        ENDIF.
      ENDIF.

    ENDLOOP.


*-- die FAE-Sätze sollen separiert und neu sortiert werden
    CLEAR lt_data_fae. APPEND LINES OF lt_merge TO lt_data_fae.
    DELETE: lt_data_fae WHERE NOT btyp EQ c_btyp_fae,
            lt_merge WHERE btyp EQ c_btyp_fae.

    SORT lt_data_fae BY belkz DESCENDING.

*-- FAE-Sätze mit Belkz 'B' überprüfen; sofern in Tabelle FMIOI ein
*-- Eintrag mit Betragsart '0500' und negativem Betrag steht und
*-- gleichzeitig eine Rechnung mit dem Auftragskennzeichen der MB
*-- übergeben wurde, muss FAE-Satz gelöscht werden und in Tabelle
*-- ZSST_SAP_DHB_FEB auf Null gesetzt werden sowie Protokoll ange-
*-- passt werden
*-- ist kein zugehöriger ANE-Satz vorhanden, darf auch der FAE-Satz
*-- nicht übergeben werden, zusätzlich muss der DHB-Betrag in der
*-- Tab. ZSST_SAP_DHB_FEB auf Null gesetzt werden
    LOOP AT lt_data_fae ASSIGNING <s_fae>
                        WHERE belkz EQ lc_belkz_b.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING   input    = <s_fae>-belnr
        IMPORTING   output   = l_refbn.

      SELECT COUNT(*) FROM fmioi UP TO 1 ROWS
                     WHERE refbn EQ l_refbn       AND
                           refbt EQ lc_refbt_110  AND
                           btart EQ lc_btart_0500 AND
                           gjahr EQ <s_fae>-hhj   AND
                           fkbtr LT lc_fkbtr_init.
      IF sy-subrc IS INITIAL.
        READ TABLE it_export TRANSPORTING NO FIELDS
                       WITH KEY btyp  = c_btyp_ane
                                xblnr = <s_fae>-xblnr.
        IF sy-subrc IS INITIAL.
          SELECT SINGLE * FROM zsst_sap_dhb_feb
                          INTO ls_feb_data
                         WHERE gjahr EQ <s_fae>-hhj AND
                               refbn EQ l_refbn     AND
                               aufkz EQ <s_fae>-xblnr.
          IF sy-subrc IS INITIAL.
            CLEAR ls_feb_data-brtwr_sap.
            MODIFY zsst_sap_dhb_feb FROM ls_feb_data.
            COMMIT WORK AND WAIT.
          ENDIF.

          DELETE ct_prot WHERE gjahr EQ <s_fae>-hhj AND
                               btyp  EQ <s_fae>-btyp AND
                               refbn EQ l_refbn.

          DELETE lt_data_fae WHERE btyp  EQ <s_fae>-btyp AND
                                   hhj   EQ <s_fae>-hhj  AND
                                   belnr EQ <s_fae>-belnr.
        ELSE.
          SELECT SINGLE * FROM zsst_sap_dhb_feb
                          INTO ls_feb_data
                         WHERE gjahr EQ <s_fae>-hhj AND
                               refbn EQ l_refbn     AND
                               aufkz EQ <s_fae>-xblnr.
          IF sy-subrc IS INITIAL.
            CLEAR: ls_feb_data-brtwr_sap, ls_feb_data-brtwr_dhb.
            MODIFY zsst_sap_dhb_feb FROM ls_feb_data.
            COMMIT WORK AND WAIT.
          ENDIF.
          DELETE lt_data_fae WHERE btyp  EQ <s_fae>-btyp AND
                                   hhj   EQ <s_fae>-hhj  AND
                                   belnr EQ <s_fae>-belnr.
        ENDIF.
      ENDIF.

      CLEAR ls_feb_data.
    ENDLOOP.

    APPEND LINES OF lt_data_fae TO lt_merge.

*-- Ablage der Datei auf Applikationsserver
    l_gennr = get_epl_number( iv_xtest = iv_xtest
                              iv_eplan = ls_eplan-low ).

*-- Dateiendung aus Tab. ZTPA_SST_EPL_KAP ermitteln
    SELECT SINGLE * FROM ztpa_sst_epl_kap INTO ls_epl_kap
                   WHERE epl      EQ ls_eplan-low AND
                         file_ext GT lc_fileext_init.
    IF NOT sy-subrc IS INITIAL.
      CONCATENATE l_string_bi_vor l_gennr l_string_sap TEXT-vst
                  INTO l_vorsatz.
    ELSE.
      CONCATENATE l_string_bi_vor l_gennr lc_string_sap TEXT-vst
                  INTO l_vorsatz.
      REPLACE '&1' WITH ls_epl_kap-file_ext INTO l_vorsatz.
      CONDENSE l_vorsatz NO-GAPS.
    ENDIF.

    l_anzahl = lines( lt_merge ).
    LOOP AT lt_merge ASSIGNING <s_merge>.
      <s_merge>-quelle = l_gennr.
      CASE <s_merge>-btyp.
        WHEN c_btyp_kor.
          CLEAR l_belnr. l_belnr = <s_merge>-betr3(8).
          LOOP AT it_export INTO ls_merge
                           WHERE btyp  IN lr_btyp AND
                                 belnr EQ l_belnr.
            EXIT.
          ENDLOOP.
          IF sy-subrc IS INITIAL.
            CONCATENATE <s_merge>-quelle ls_merge-belnr ls_merge-blpos
                        INTO <s_merge>-betr3.
          ENDIF.
        WHEN c_btyp_mer OR c_btyp_mae.
          CLEAR <s_merge>-berei.
      ENDCASE.
      ADD <s_merge>-betr1 TO l_checksum.
    ENDLOOP.

    CONCATENATE l_string_bi_end l_anzahl 'B' l_checksum
                INTO l_nachsatz.
    l_file = TEXT-fna. REPLACE '&1' INTO l_file WITH l_gennr.
    IF NOT ls_epl_kap-file_ext IS INITIAL.
      REPLACE '&2' WITH ls_epl_kap-file_ext INTO l_file.
    ELSE.
      REPLACE '&2' WITH lc_value_3101 INTO l_file.
    ENDIF.
    CONDENSE l_file NO-GAPS.

*-- ggf. Pfadname für Dateiablage umbenennen
    IF iv_xtest EQ abap_on AND v_path_save EQ lc_path_prd.
      v_path_save = lc_path_tmp.
    ENDIF.

*-- Datei auf Appl.server ablegen
    ref_help->write_itab_to_applsrv(
                EXPORTING   iv_struc         = l_struc
                            iv_path          = v_path_save
                            iv_file          = l_file
                            iv_separate      = l_separator
                            iv_vorsatz       = l_vorsatz
                            iv_nachsatz      = l_nachsatz
                            it_data          = lt_merge
                EXCEPTIONS  error_open_file = 1
                            OTHERS          = 2 ).

    IF NOT sy-subrc IS INITIAL.
      MESSAGE e153(14) WITH l_file.
    ELSE.
*---- zur Sicherheit nochmals die Unicodekonvertierung
*---- laufen lassen
      ref_help->convert_file_unicode(
                  iv_fpath  = CONV #( v_path_save )
                  iv_sfile  = CONV #( l_file ) ).
      MESSAGE s656(rsan_rt) WITH abap_off l_anzahl.
    ENDIF.

*-- Initialisierung
    CLEAR: lt_merge, lt_data_fae.
  ENDLOOP.

ENDMETHOD.                    "create_save_files


*----------------------------------------------------------------------*
* Methode READ_DOCUMENT_DATA
*----------------------------------------------------------------------*
METHOD read_document_data.

* lokale Datendeklaration
  CONSTANTS: lc_tcode_me23  TYPE tcode VALUE 'ME23',
             lc_trtyp_a     TYPE trtyp VALUE 'A'.

  DATA: l_docnr    TYPE bp_docnr,
        lt_bpdk    TYPE STANDARD TABLE OF bpdk,
        lt_psokpf  TYPE STANDARD TABLE OF psokpf,
        ls_psokpf  LIKE LINE OF lt_psokpf,
        ls_bkpf    TYPE bkpf,
        ls_del_dao TYPE ztpa_del_dao.

  DATA: lr_wrttp TYPE RANGE OF co_wrttp,
        lr_belnr TYPE RANGE OF belnr_d.

  DATA: lref_help TYPE REF TO zcl_tpa_psm_functions.

  FIELD-SYMBOLS: <s_pso02>  LIKE LINE OF et_pso02,
                 <s_pso02s> LIKE LINE OF et_pso02s.

* Initialisierung
  CLEAR: es_ekko, et_ekpo, et_ekkn, es_kblk, et_kbld, et_kble,
         et_bpdz, et_bpdj, et_pso02, et_pso02s, et_pssec.

* Prüfung, dass eine Belegnummer bzw. Anordnungsnummer übergeben
* wurde
  IF iv_refbn IS INITIAL AND iv_lotkz IS INITIAL.
    RETURN.
  ENDIF.

* entsprechend Belegart Daten ermitteln
  CASE iv_blart.
*-- Einkaufsbelege
    WHEN c_blart_nb.
*---- FuBa 'ME_PURCHASE_DOCUMENT_DATA_READ' aufrufen
      CALL FUNCTION 'ME_PURCHASE_DOCUMENT_DATA_READ'
        EXPORTING  i_ebeln        = iv_refbn
                   i_tcode        = lc_tcode_me23
                   i_trtyp        = lc_trtyp_a
        IMPORTING  e_ekko         = es_ekko
        TABLES     t_ekpo         = et_ekpo
                   t_ekkn         = et_ekkn
        EXCEPTIONS error_message  = 7.

      IF NOT sy-subrc IS INITIAL.
        RETURN.
      ENDIF.

*-- Mittelbindungen und allg. Anordnungen
    WHEN c_blart_fe OR c_blart_ve OR c_blart_ba OR c_blart_ae.
*---- FuBa 'FMR2_READ_KBLX_INTO_KBLD' aufrufen
      CALL FUNCTION 'FMR2_READ_KBLX_INTO_KBLD'
        EXPORTING  i_belnr        = iv_refbn
        IMPORTING  e_kblk         = es_kblk
        TABLES     t_kbld         = et_kbld
                   t_kble         = et_kble
        EXCEPTIONS error_message  = 3.

      IF NOT sy-subrc IS INITIAL.
        RETURN.
      ENDIF.

*-- Mittelverteilungen
    WHEN c_blart_mv.
      CLEAR l_docnr. l_docnr = iv_refbn.

      ref_help->set_range_value( EXPORTING iv_value_low = c_wrttp_43
                                  CHANGING ct_range     = lr_wrttp ).
      ref_help->set_range_value( EXPORTING iv_value_low = c_wrttp_70
                                  CHANGING ct_range     = lr_wrttp ).


*---- FuBa 'KBPR_READ_BPDX' aufrufen
      CALL FUNCTION 'KBPR_READ_BPDX'
        EXPORTING  i_belnr        = l_docnr
        TABLES     t_bpdk         = lt_bpdk
                   t_bpdz         = et_bpdz
                   t_bpdj         = et_bpdj
        EXCEPTIONS error_message  = 2.

      IF NOT sy-subrc IS INITIAL.
        RETURN.
      ELSE.
        DELETE et_bpdj WHERE NOT wrttp IN lr_wrttp.
      ENDIF.

*-- Rechnungen
    WHEN c_blart_rn OR c_blart_st.
      SELECT SINGLE * FROM bkpf INTO ls_bkpf
                     WHERE belnr EQ iv_refbn AND
                           bukrs EQ iv_bukrs AND
                           gjahr EQ iv_gjahr.

      IF sy-subrc IS INITIAL.
        build_pso_from_document( EXPORTING is_bkpf   = ls_bkpf
                                 IMPORTING et_pso02  = et_pso02
                                           et_pso02s = et_pso02s
                                           et_pssec  = et_pssec ).
      ENDIF.

*-- Daueranordnungen
    WHEN c_blart_02 OR c_blart_12.
      IF NOT lref_help IS BOUND. lref_help = NEW #( ). ENDIF.

      SELECT SINGLE * FROM bkpf INTO ls_bkpf
                     WHERE bukrs EQ iv_bukrs AND
                           gjahr EQ iv_gjahr AND
                           belnr EQ iv_refbn.

      IF sy-subrc IS INITIAL AND NOT ls_bkpf-lotkz IS INITIAL.
        lref_help->get_fi_pso_data( EXPORTING im_bukrs   = ls_bkpf-bukrs
                                              im_lotkz   = ls_bkpf-lotkz
                                              im_belnr   = ls_bkpf-belnr
                                              im_gjahr   = ls_bkpf-gjahr
                                    IMPORTING et_pso02   = et_pso02
                                              et_pso02s  = et_pso02s
                                              et_pssec   = et_pssec ).

      ELSE.
        CALL FUNCTION 'FI_PSO_PSOKPF_READ'
          EXPORTING  i_lotkz    = iv_lotkz
                     i_bukrs    = iv_bukrs
                     i_gjahr    = iv_gjahr
          TABLES     e_t_psokpf = lt_psokpf.

        READ TABLE lt_psokpf INTO ls_psokpf INDEX 1.
        IF sy-subrc IS INITIAL.
          IF ls_psokpf-xdelt EQ abap_off.
            lref_help->get_fi_pso_data( EXPORTING im_bukrs     = ls_psokpf-bukrs
                                                  im_lotkz     = ls_psokpf-lotkz
                                                  im_gjahr     = ls_psokpf-gjahr
                                                  im_recurring = abap_on
                                        IMPORTING et_pso02     = et_pso02
                                                  et_pso02s    = et_pso02s
                                                  et_pssec     = et_pssec ).

          ELSE.
            SELECT SINGLE * FROM ztpa_del_dao INTO ls_del_dao
                           WHERE lotkz EQ ls_psokpf-lotkz AND
                                 bukrs EQ ls_psokpf-bukrs AND
                                 belnr IN lr_belnr AND
                                 gjahr EQ ls_psokpf-gjahr.
            IF sy-subrc IS INITIAL.
              APPEND INITIAL LINE TO: et_pso02  ASSIGNING <s_pso02>,
                                      et_pso02s ASSIGNING <s_pso02s>.
              MOVE-CORRESPONDING ls_del_dao TO: <s_pso02>,
                                                <s_pso02s>.
            ENDIF.
          ENDIF.
        ELSE.
          RETURN.
        ENDIF.
      ENDIF.
*-- PSM-Belege
    WHEN OTHERS.
      IF NOT lref_help IS BOUND. lref_help = NEW #( ). ENDIF.

      SELECT SINGLE * FROM bkpf INTO ls_bkpf
                     WHERE bukrs EQ iv_bukrs AND
                           gjahr EQ iv_gjahr AND
                           belnr EQ iv_refbn.

      IF NOT sy-subrc IS INITIAL.
        CLEAR ls_bkpf.
      ELSE.
*------ Abfrage des Buchungstyps
        CASE iv_butyp.
          WHEN c_btyp_stu OR c_btyp_spl.
            CLEAR ls_bkpf-belnr.
        ENDCASE.
      ENDIF.

      lref_help->get_fi_pso_data( EXPORTING im_bukrs   = ls_bkpf-bukrs
                                            im_lotkz   = ls_bkpf-lotkz
                                            im_belnr   = ls_bkpf-belnr
                                            im_gjahr   = ls_bkpf-gjahr
                                  IMPORTING et_pso02   = et_pso02
                                            et_pso02s  = et_pso02s
                                            et_pssec   = et_pssec ).

  ENDCASE.

ENDMETHOD.                    "read_document_data


*----------------------------------------------------------------------*
* Methode BUILD_PSO_FROM_DOCUMENT
*----------------------------------------------------------------------*
METHOD build_pso_from_document.

* lokale Datendeklaration
  CONSTANTS: lc_buzid_t  TYPE buzid VALUE 'T',
             lc_buzid_p  TYPE buzid VALUE 'P',
             lc_buzid_z  TYPE buzid VALUE 'Z'.

  DATA: lt_bseg TYPE bseg_t,
        lt_bset TYPE fm_bset,
        lt_bsec TYPE STANDARD TABLE OF bsec,
        ls_bseg LIKE LINE OF lt_bseg,
        ls_bset LIKE LINE OF lt_bset,
        ls_bsec LIKE LINE OF lt_bsec.

  DATA: ls_kna1 TYPE kna1,
        ls_lfa1 TYPE lfa1,
        lt_lfbk TYPE STANDARD TABLE OF lfbk,
        ls_lfbk LIKE LINE OF lt_lfbk.

  FIELD-SYMBOLS: <s_pso02>  LIKE LINE OF et_pso02,
                 <s_pso02s> LIKE LINE OF et_pso02s,
                 <s_pssec>  LIKE LINE OF et_pssec.

* PSO-Strukturen über FI-Beleg aufbauen
  CALL FUNCTION 'FI_DOCUMENT_READ1'
    EXPORTING  i_docno       = is_bkpf-belnr
               i_byear       = is_bkpf-gjahr
               i_compy       = is_bkpf-bukrs
    TABLES     t_bseg        = lt_bseg
               t_bsec        = lt_bsec
               t_bset        = lt_bset
    EXCEPTIONS error_message = 1.

  IF NOT sy-subrc IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT lt_bseg INTO ls_bseg.
    CASE ls_bseg-koart.
      WHEN ref_const->c_koart_d OR ref_const->c_koart_k.
        APPEND INITIAL LINE TO et_pso02 ASSIGNING <s_pso02>.
        MOVE-CORRESPONDING: is_bkpf TO <s_pso02>,
                            ls_bseg TO <s_pso02>.
      WHEN ref_const->c_koart_s.
        IF NOT ls_bseg-buzid EQ lc_buzid_t AND
           NOT ls_bseg-buzid EQ lc_buzid_z.
          APPEND INITIAL LINE TO et_pso02s ASSIGNING <s_pso02s>.
          MOVE-CORRESPONDING ls_bseg TO <s_pso02s>.
          CALL FUNCTION 'FI_PSO_FIPEX_GET_FROM_FIPOS'
            EXPORTING  i_fipos = <s_pso02s>-fipos
            IMPORTING  e_fipex = <s_pso02s>-fipex.

          IF ls_bseg-buzid EQ lc_buzid_p AND
             ls_bseg-shkzg EQ ref_const->c_shkzg_h.
            MULTIPLY: <s_pso02s>-dmbtr BY -1,
                      <s_pso02s>-wrbtr BY -1.
          ENDIF.
        ELSE.
          IF ls_bseg-buzid EQ lc_buzid_z.
            READ TABLE et_pso02 ASSIGNING <s_pso02>
                                WITH KEY bukrs = is_bkpf-bukrs
                                         belnr = is_bkpf-belnr
                                         gjahr = is_bkpf-gjahr.
            IF sy-subrc IS INITIAL.
              SUBTRACT: ls_bseg-dmbtr FROM <s_pso02>-dmbtr,
                        ls_bseg-wrbtr FROM <s_pso02>-wrbtr.
            ENDIF.
          ENDIF.
        ENDIF.
      WHEN ref_const->c_koart_m.
        APPEND INITIAL LINE TO et_pso02s ASSIGNING <s_pso02s>.
        MOVE-CORRESPONDING ls_bseg TO <s_pso02s>.
        IF ls_bseg-shkzg EQ ref_const->c_shkzg_h.
          MULTIPLY: <s_pso02s>-dmbtr BY -1,
                    <s_pso02s>-wrbtr BY -1.
        ENDIF.
        CALL FUNCTION 'FI_PSO_FIPEX_GET_FROM_FIPOS'
          EXPORTING  i_fipos = <s_pso02s>-fipos
          IMPORTING  e_fipex = <s_pso02s>-fipex.
    ENDCASE.
  ENDLOOP.

  LOOP AT lt_bset INTO ls_bset.
    READ TABLE et_pso02 ASSIGNING <s_pso02>
                        WITH KEY bukrs = ls_bset-bukrs
                                 belnr = ls_bset-belnr
                                 gjahr = ls_bset-gjahr.
    IF sy-subrc IS INITIAL.
      <s_pso02>-mwsts = <s_pso02>-wmwst = ls_bset-hwste.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_bsec INTO ls_bsec.
    APPEND INITIAL LINE TO et_pssec ASSIGNING <s_pssec>.
    <s_pssec>-bsec = ls_bsec.
  ENDLOOP.
  IF NOT sy-subrc IS INITIAL.
    LOOP AT lt_bseg INTO ls_bseg
                   WHERE koart EQ ref_const->c_koart_d OR
                         koart EQ ref_const->c_koart_k.

      CASE ls_bseg-koart.
        WHEN ref_const->c_koart_d.
          CALL FUNCTION 'CUSTOMER_READ'
            EXPORTING  i_bukrs        = is_bkpf-bukrs
                       i_kunnr        = ls_bseg-kunnr
            IMPORTING  e_kna1         = ls_kna1
            EXCEPTIONS error_message  = 2.

          IF NOT sy-subrc IS INITIAL.
            CLEAR ls_kna1.
          ELSE.
            APPEND INITIAL LINE TO et_pssec ASSIGNING <s_pssec>.
            MOVE-CORRESPONDING ls_kna1 TO <s_pssec>-bsec.
          ENDIF.

        WHEN ref_const->c_koart_k.
          CALL FUNCTION 'VENDOR_READ'
            EXPORTING  i_bukrs        = is_bkpf-bukrs
                       i_lifnr        = ls_bseg-lifnr
            IMPORTING  e_lfa1         = ls_lfa1
            EXCEPTIONS error_message  = 2.

          IF NOT sy-subrc IS INITIAL.
            CLEAR ls_lfa1.
          ELSE.
            APPEND INITIAL LINE TO et_pssec ASSIGNING <s_pssec>.
            MOVE-CORRESPONDING ls_lfa1 TO <s_pssec>-bsec.

            CALL FUNCTION 'FOR_ALL_LFBK'
              EXPORTING  xlifnr        = ls_bseg-lifnr
              TABLES     xlfbk         = lt_lfbk
              EXCEPTIONS error_message = 4.

            IF sy-subrc IS INITIAL.
              DELETE lt_lfbk WHERE NOT bvtyp EQ ls_bseg-bvtyp.
              READ TABLE lt_lfbk INTO ls_lfbk
                                 WITH KEY lifnr = ls_bseg-lifnr
                                          bvtyp = ls_bseg-bvtyp.
              IF sy-subrc IS INITIAL.
                MOVE-CORRESPONDING ls_lfbk TO <s_pssec>-bsec.
              ENDIF.
            ENDIF.

          ENDIF.

      ENDCASE.
    ENDLOOP.
  ENDIF.

ENDMETHOD.                    "build_pso_from_document


*----------------------------------------------------------------------*
* Methode GET_FMIOI_VALUES
*----------------------------------------------------------------------*
METHOD get_fmioi_values.

* lokale Datendeklaration
  CONSTANTS: lc_fkbtr_init TYPE fm_fkbtr VALUE IS INITIAL,
             lc_rldnr_9a   TYPE rldnr VALUE '9A',
             lc_rldnr_9b   TYPE rldnr VALUE '9B'.

  DATA: lr_gjahr TYPE RANGE OF gjahr,
        lr_gnjhr TYPE RANGE OF gjahr,
        lr_rldnr TYPE RANGE OF rldnr.

* Übergabe des Geschäftsjahres
  IF iv_gjahr IS SUPPLIED AND NOT iv_gjahr IS INITIAL.
    ref_help->set_range_value(
                EXPORTING iv_value_low = iv_gjahr
                 CHANGING ct_range     = lr_gjahr ).
  ENDIF.

* Übergabe Jahr der Kassenwirksamkeit
  IF iv_gnjhr IS SUPPLIED AND NOT iv_gnjhr IS INITIAL.
    ref_help->set_range_value(
                EXPORTING iv_value_low  = iv_gjahr
                          iv_value_high = iv_gnjhr
                 CHANGING ct_range      = lr_gjahr ).
    ref_help->set_range_value(
                EXPORTING iv_value_low = iv_gnjhr
                 CHANGING ct_range     = lr_gnjhr ).
  ENDIF.

* Range für Ledger
  ref_help->set_range_value(
              EXPORTING iv_value_low = lc_rldnr_9a
               CHANGING ct_range     = lr_rldnr ).
  ref_help->set_range_value(
              EXPORTING iv_value_low = lc_rldnr_9b
               CHANGING ct_range     = lr_rldnr ).

* Daten aus Tabelle FMIOI ermitteln
  SELECT SUM( fkbtr ) INTO rv_brtwr
                      FROM fmioi
                     WHERE refbt EQ iv_refbt AND
                           refbn EQ iv_refbn AND
                           rfpos EQ iv_rfpos AND
                           rfknt EQ iv_rfknt AND
                           rldnr IN lr_rldnr AND
                           gjahr IN lr_gjahr AND
                           gnjhr IN lr_gnjhr AND
                           btart IN ir_btart.

  IF sy-subrc IS INITIAL.
    IF rv_brtwr LT lc_fkbtr_init.
      MULTIPLY rv_brtwr BY -1.
    ENDIF.
  ENDIF.

ENDMETHOD.                    "get_fmioi_values


*----------------------------------------------------------------------*
* Methode GET_AUFKZ_BTYP
*----------------------------------------------------------------------*
METHOD get_aufkz_btyp.

* lokale Datendeklaration
  DATA: l_tabname TYPE tabname.

  DATA: l_count_1   TYPE i VALUE 1,
        l_count_pos TYPE n LENGTH 6,
        l_count_max TYPE n LENGTH 6.

  DATA: lt_sst_data  TYPE tt_feb_data.

  FIELD-SYMBOLS: <s_sst_data> LIKE LINE OF lt_sst_data.

* Initialisierung Exportparameter
  CLEAR: ev_btyp, es_sst_save.

* Daten aus Tab. ZSST_SAP_DHB_FEB bzw. ZSST_SAP_DHB_ANO ermitteln
  CASE iv_sst_type.
*-- Festlegungen
    WHEN c_sst_feb.
      l_tabname = c_sst_tabn_feb.

      SELECT * FROM (l_tabname) INTO TABLE lt_sst_data
              WHERE gjahr EQ is_sst_data-gjahr AND
                    refbn EQ is_sst_data-refbn.
*-- Anordnungen
    WHEN c_sst_ano.
      l_tabname = c_sst_tabn_ano.

      SELECT * FROM (l_tabname) INTO TABLE lt_sst_data
              WHERE gjahr EQ is_sst_data-gjahr AND
                    refbn EQ is_sst_data-refbn.
  ENDCASE.

* Buchungstyp vorläufig festlegen
  CASE is_sst_data-blart.
    WHEN c_blart_nb OR c_blart_ve OR c_blart_fe.
      ev_btyp = c_btyp_feb.
    WHEN c_blart_mv.
      ev_btyp = c_btyp_auf.
    WHEN c_blart_ba OR c_blart_ae.
      ev_btyp = c_btyp_all.
    WHEN c_blart_01 OR c_blart_03.
      ev_btyp = c_btyp_sst.
    WHEN c_blart_02.
      ev_btyp = c_btyp_dao.
    WHEN c_blart_12.
      IF iv_sst_type EQ c_sst_feb.
        ev_btyp = c_btyp_feb.
      ELSE.
        ev_btyp = c_btyp_ane.
      ENDIF.
    WHEN c_blart_07 OR c_blart_18 OR c_blart_un.
      ev_btyp = c_btyp_stu.
    WHEN c_blart_09 OR c_blart_10 OR c_blart_19 OR c_blart_21 OR
         c_blart_23 OR c_blart_24.
      ev_btyp = c_btyp_sab.
    WHEN c_blart_11 OR c_blart_13 OR c_blart_17.
      ev_btyp = c_btyp_fua.
    WHEN c_blart_14.
      ev_btyp = c_btyp_spl.
    WHEN c_blart_rn OR c_blart_st.
      ev_btyp = c_btyp_ane.
    WHEN c_blart_22.
      ev_btyp = c_btyp_aes.
    WHEN c_blart_25.
      ev_btyp = c_btyp_szu.
    WHEN c_blart_30.
      ev_btyp = c_btyp_apu.
    WHEN c_blart_32.
      ev_btyp = c_btyp_umb.
  ENDCASE.

  SORT lt_sst_data BY aufkz DESCENDING.

* Auftragskennzeichen zur Kombination aus Finanzstelle und -position
* ermitteln
  CASE iv_sst_type.
*-- Festlegungen
    WHEN c_sst_feb.
      READ TABLE lt_sst_data INTO es_sst_save
                            WITH KEY gjahr = is_sst_data-gjahr
                                     refbn = is_sst_data-refbn
                                     fistl = is_sst_data-fistl
                                     fipex = is_sst_data-fipex.
      IF NOT sy-subrc IS INITIAL.
        es_sst_save = is_sst_data.
*------ letzten vergebenen Schlüssel ermitteln
        IF NOT lines( lt_sst_data ) IS INITIAL.
          READ TABLE lt_sst_data ASSIGNING <s_sst_data> INDEX l_count_1.
          l_count_max = <s_sst_data>-aufkz+10(6).
        ENDIF.

        APPEND INITIAL LINE TO lt_sst_data ASSIGNING <s_sst_data>.
        <s_sst_data> = is_sst_data.
        IF l_count_max IS INITIAL.
          ADD l_count_1 TO l_count_pos.

          CONCATENATE is_sst_data-refbn l_count_pos
                 INTO <s_sst_data>-aufkz.

          es_sst_save-aufkz = <s_sst_data>-aufkz.
        ELSE.
          ADD l_count_1 TO l_count_max.
          CONCATENATE is_sst_data-refbn l_count_max
                 INTO <s_sst_data>-aufkz.

          es_sst_save-aufkz = <s_sst_data>-aufkz.
        ENDIF.
      ELSE.
*------ aktuellen Wert für Betrag SAP fortschreiben
        es_sst_save-brtwr_sap = is_sst_data-brtwr_sap.

        IF NOT es_sst_save-belnr_dhb IS INITIAL.
          ev_btyp = c_btyp_fae.
        ENDIF.
      ENDIF.
*---- Datenbanktabelle modifizieren
      MODIFY: TABLE lt_sst_data FROM es_sst_save,
              (l_tabname) FROM TABLE lt_sst_data.

      COMMIT WORK AND WAIT.

*-- Anordnungen
    WHEN c_sst_ano.
      es_sst_save = is_sst_data.
  ENDCASE.

ENDMETHOD.                    "get_aufkz_btyp


*----------------------------------------------------------------------*
* METHOD READ_CHANGES
*----------------------------------------------------------------------*
METHOD read_changes.

* lokale Datendeklaration
  CONSTANTS: lc_tabname_psokpf TYPE tabname VALUE 'PSOKPF',
             lc_uname_finbat   TYPE cdusername VALUE 'FINBAT',
             lc_fname_dbatr    TYPE fieldname VALUE 'DBATR',
             lc_fname_xfrge    TYPE fieldname VALUE 'XFRGE',
             lc_fname_dbzhl    TYPE fieldname VALUE 'DBZHL',
             lc_fname_bstat    TYPE fieldname VALUE 'BSTAT',
             lc_tcode_f8q4     TYPE tcode VALUE 'F8Q4',
             lc_tcode_f8q5     TYPE tcode VALUE 'F8Q5',
             lc_tcode_f8q8     TYPE tcode VALUE 'F8Q8'.

  DATA: l_chgnr_low  TYPE cdchangenr,
        l_chgnr_high TYPE cdchangenr.

  DATA: lr_fname TYPE RANGE OF fieldname,
        lr_tcode TYPE RANGE OF tcode,
        lr_chgnr TYPE RANGE OF cdchangenr.

  DATA: ls_cdred LIKE LINE OF rt_cdred.

  FIELD-SYMBOLS: <s_cdred> LIKE LINE OF rt_cdred.

* FuBa 'CHANGEDOCUMENT_READ' aufrufen
  CALL FUNCTION 'CHANGEDOCUMENT_READ'
    EXPORTING  objectclass       = iv_objcl
               objectid          = iv_objid
    TABLES     editpos           = rt_cdred
    EXCEPTIONS no_position_found = 1
               error_message     = 4.

  IF NOT sy-subrc IS INITIAL.
    CLEAR rt_cdred.
  ELSE.
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_dbatr
                                CHANGING ct_range     = lr_fname ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_xfrge
                                CHANGING ct_range     = lr_fname ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_dbzhl
                                CHANGING ct_range     = lr_fname ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_bstat
                                CHANGING ct_range     = lr_fname ).

    ref_help->set_range_value( EXPORTING iv_value_low = lc_tcode_f8q4
                                CHANGING ct_range     = lr_tcode ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_tcode_f8q5
                                CHANGING ct_range     = lr_tcode ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_tcode_f8q8
                                CHANGING ct_range     = lr_tcode ).

    SORT rt_cdred BY changenr DESCENDING.
    LOOP AT rt_cdred ASSIGNING <s_cdred>.
      ls_cdred = <s_cdred>.
      AT NEW changenr.
        IF ls_cdred-tcode EQ lc_tcode_f8q5.
          IF l_chgnr_high IS INITIAL.
            l_chgnr_high = ls_cdred-changenr.
          ELSE.
            l_chgnr_low = ls_cdred-changenr.
            EXIT.
          ENDIF.
        ENDIF.
      ENDAT.
    ENDLOOP.

    ref_help->set_range_value( EXPORTING iv_value_low  = l_chgnr_low
                                         iv_value_high = l_chgnr_high
                                CHANGING ct_range      = lr_chgnr ).

    DELETE rt_cdred: WHERE NOT changenr IN lr_chgnr,
                     WHERE username EQ lc_uname_finbat,
                     WHERE tcode    IN lr_tcode,
                     WHERE tabname  EQ lc_tabname_psokpf AND
                           fname    IN lr_fname.
  ENDIF.

ENDMETHOD.                    "read_changes


*----------------------------------------------------------------------*
* METHOD GET_EPL_NUMBER
*----------------------------------------------------------------------*
METHOD get_epl_number.

* lokale Datendeklaration
  CONSTANTS: lc_nrobj_sap TYPE nrobj VALUE 'ZSSGEN_SAP',
             lc_nrobj_tmp TYPE nrobj VALUE 'ZSSGEN_TMP'.

  DATA: l_nrnr  TYPE nrnr,
        l_nrobj TYPE nrobj.

* Übernahme Importparameter
  l_nrnr = iv_eplan.

  CASE iv_xtest.
    WHEN abap_on.
      l_nrobj = lc_nrobj_tmp.
    WHEN abap_off.
      l_nrobj = lc_nrobj_sap.
  ENDCASE.

* Aufruf FuBa 'NUMBER_GET_NEXT'
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING  nr_range_nr   = l_nrnr
               object        = l_nrobj
    IMPORTING  number        = rv_number
    EXCEPTIONS error_message = 8.

  IF NOT sy-subrc IS INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMETHOD.                    "get_epl_number


*----------------------------------------------------------------------*
* METHOD CHECK_EXISTENCE
*----------------------------------------------------------------------*
METHOD check_existence.

* lokale Datendeklaration
  DATA: lt_feb_data  TYPE tt_feb_data.

  FIELD-SYMBOLS: <s_feb_data> LIKE LINE OF it_feb_data.

* Prüfen in Tab. FMIOI, ob Kombination aus Finanzstelle und Finanzpo-
* sition noch vorhanden ist
  APPEND LINES OF it_feb_data TO lt_feb_data.

  LOOP AT lt_feb_data ASSIGNING <s_feb_data>.
    SELECT COUNT(*) FROM fmioi UP TO 1 ROWS
            WHERE refbn EQ <s_feb_data>-refbn   AND
                ( gjahr EQ <s_feb_data>-gjahr OR
                  gnjhr EQ <s_feb_data>-gjahr ) AND
                  fistl EQ <s_feb_data>-fistl   AND
                  fipex EQ <s_feb_data>-fipex.

    IF NOT sy-subrc IS INITIAL.
      CLEAR <s_feb_data>-brtwr_sap.
      APPEND <s_feb_data> TO rt_feb_dele.
    ENDIF.
  ENDLOOP.

* Fortschreiben der Tab. ZSAP_DHB_ME_DATA
  IF NOT lines( rt_feb_dele ) IS INITIAL.
    MODIFY (c_sst_tabn_feb) FROM TABLE rt_feb_dele.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDMETHOD.                    "check_existence


*----------------------------------------------------------------------*
* METHOD READ_REFERENCE_DATA
*----------------------------------------------------------------------*
METHOD read_reference_data.

* lokale Datendeklaration
  CONSTANTS: lc_lines_1 TYPE i VALUE 1.

  TYPES: BEGIN OF ts_sele,
           bukrs TYPE bukrs,
           belnr TYPE belnr_d,
           gjahr TYPE gjahr,
           zuonr TYPE dzuonr,
           blart TYPE blart,
           cpudt TYPE cpudt,
           wrbtr TYPE wrbtr,
         END OF ts_sele.

  DATA: lr_cpudt TYPE RANGE OF datum.

  DATA: lt_sele TYPE STANDARD TABLE OF ts_sele,
        ls_sele LIKE LINE OF lt_sele,
        ls_bkpf TYPE bkpf.

* Daten zum übergebenen Beleg ermitteln
  SELECT SINGLE * FROM bkpf INTO ls_bkpf
                 WHERE belnr EQ iv_belnr AND
                       bukrs EQ iv_bukrs AND
                       gjahr EQ iv_gjahr.

  IF NOT sy-subrc IS INITIAL.
    RETURN.
  ENDIF.

* in Abhängigkeit vom Flag XEOWI das CPUDT als Range setzen
  CASE iv_xeowi.
    WHEN abap_on.
      ref_help->set_range_value(
                  EXPORTING iv_value_low  = ls_bkpf-cpudt
                            iv_option     = ref_const->c_option_le
                   CHANGING ct_range      = lr_cpudt ).
      ref_help->set_range_value(
                  EXPORTING iv_value_low  = ls_bkpf-cpudt
                            iv_option     = ref_const->c_option_ge
                   CHANGING ct_range      = lr_cpudt ).
    WHEN abap_off.
      ref_help->set_range_value(
                  EXPORTING iv_value_low  = ls_bkpf-cpudt
                   CHANGING ct_range      = lr_cpudt ).
    WHEN OTHERS.
  ENDCASE.

* Daten in der Tabelle BSID suchen
  SELECT bukrs belnr gjahr zuonr blart cpudt wrbtr
               FROM bsid
               INTO CORRESPONDING FIELDS OF TABLE lt_sele
              WHERE bukrs EQ ls_bkpf-bukrs AND
                    gjahr EQ ls_bkpf-gjahr AND
                    cpudt IN lr_cpudt      AND
                    zuonr EQ iv_zuonr      AND
                    blart EQ iv_blart.

  IF lines( lt_sele ) IS INITIAL.
*-- ggf. in Tab. BSAD suchen
    SELECT bukrs belnr gjahr zuonr blart cpudt wrbtr
                 FROM bsad
                 INTO CORRESPONDING FIELDS OF TABLE lt_sele
                WHERE bukrs EQ ls_bkpf-bukrs AND
                      gjahr EQ ls_bkpf-gjahr AND
                      cpudt IN lr_cpudt      AND
                      zuonr EQ iv_zuonr      AND
                      blart EQ iv_blart.
  ENDIF.

* Auswertung der Ergebnisse
  IF lines( lt_sele ) IS INITIAL.
    RETURN.
  ELSE.
    IF lines( lt_sele ) GT lc_lines_1.
*---- sofern mehrere Belege gefunden wurden, muss in Abhängigkeit
*---- vom Flag XEOWI unterschiedlich gesucht werden
      CASE iv_xeowi.
        WHEN abap_on.
          DELETE lt_sele WHERE belnr GT iv_belnr.
          SORT lt_sele BY belnr DESCENDING cpudt DESCENDING.
          LOOP AT lt_sele INTO ls_sele
                         WHERE belnr LT iv_belnr AND
                               cpudt IN lr_cpudt.
            EXIT.
          ENDLOOP.
          IF sy-subrc IS INITIAL.
            rv_wrbtr = ls_sele-wrbtr.
          ENDIF.
        WHEN abap_off.
          DELETE lt_sele WHERE belnr GT iv_belnr.
          SORT lt_sele BY belnr DESCENDING.
          READ TABLE lt_sele INTO ls_sele INDEX lc_lines_1.
          rv_wrbtr = ls_sele-wrbtr.
        WHEN OTHERS.
      ENDCASE.
    ELSE.
      READ TABLE lt_sele INTO ls_sele INDEX lc_lines_1.
      rv_wrbtr = ls_sele-wrbtr.
    ENDIF.
  ENDIF.

ENDMETHOD.                    "read_reference_data


*----------------------------------------------------------------------*
* METHOD CREATE_KASSZ
*----------------------------------------------------------------------*
METHOD create_kassz.

* lokale Datendeklaration
  DATA: lref_psm TYPE REF TO zcl_tpa_psm_functions.

* Kassenzeichen erzeugen
  IF lref_psm IS BOUND.
    CLEAR lref_psm. lref_psm = NEW #( ).
  ELSE.
    lref_psm = NEW #( ).
  ENDIF.

  rv_kassz = lref_psm->create_kassz( iv_fistl ).

ENDMETHOD.                    "create_kassz


*----------------------------------------------------------------------*
* METHOD UPDATE_KASSZ
*----------------------------------------------------------------------*
METHOD update_kassz.

* lokale Datendeklaration
  DATA: lref_psm TYPE REF TO zcl_tpa_psm_functions.

* Kassenzeichen erzeugen
  IF lref_psm IS BOUND.
    CLEAR lref_psm. lref_psm = NEW #( ).
  ELSE.
    lref_psm = NEW #( ).
  ENDIF.

  lref_psm->update_kassz( iv_bukrs = iv_bukrs
                          iv_belnr = iv_belnr
                          iv_gjahr = iv_gjahr
                          iv_xblnr = iv_xblnr ).

ENDMETHOD.                    "update_kassz


*----------------------------------------------------------------------*
* METHOD CHECK_BTYP
*----------------------------------------------------------------------*
METHOD check_btyp.

* lokale Datendeklaration
  CONSTANTS: lc_lines_1    TYPE i VALUE 1,
             lc_belnr_init TYPE zbelnr VALUE IS INITIAL.

  DATA: l_x_kblnr     TYPE xfeld,
        l_x_exist     TYPE xfeld,
        l_gjahr       TYPE gjahr,
        l_lines_fistl TYPE i,
        l_lines_fipex TYPE i,
        l_lines_ebeln TYPE i.

  DATA: lr_fistl TYPE RANGE OF fistl,
        lr_fipex TYPE RANGE OF fm_fipex,
        lr_ebeln TYPE RANGE OF ebeln.

  DATA: ls_pso02s LIKE LINE OF it_pso02s,
        ls_kbld   LIKE LINE OF it_kbld.

* Abfrage des Buchungstypes
  CASE cv_btyp.
*-- Buchungstyp ANE und FUA
    WHEN c_btyp_ane OR c_btyp_fua.
*---- Ermitteln, ob Mittelbindung oder Bestellung (Auftrag)
*---- vorhanden
      LOOP AT it_pso02s INTO ls_pso02s
                       WHERE NOT kblnr IS INITIAL OR
                             NOT ebeln IS INITIAL.
        l_x_kblnr = abap_on.
        EXIT.
      ENDLOOP.

*---- Ranges für Finanzstelle, Finanzposition und Bestellungen bilden
      LOOP AT it_pso02s INTO ls_pso02s.
        ref_help->set_range_value(
                    EXPORTING iv_value_low = ls_pso02s-fistl
                     CHANGING ct_range     = lr_fistl ).

        ref_help->set_range_value(
                     EXPORTING iv_value_low = ls_pso02s-fipex
                      CHANGING ct_range     = lr_fipex ).

        ref_help->set_range_value(
                     EXPORTING iv_value_low = ls_pso02s-ebeln
                      CHANGING ct_range     = lr_ebeln ).
      ENDLOOP.

      SORT: lr_fistl BY low,
            lr_fipex BY low,
            lr_ebeln BY low.

      DELETE ADJACENT DUPLICATES FROM: lr_fistl COMPARING ALL FIELDS,
                                       lr_fipex COMPARING ALL FIELDS,
                                       lr_ebeln COMPARING ALL FIELDS.

      l_lines_fistl = lines( lr_fistl ).
      l_lines_fipex = lines( lr_fipex ).
      l_lines_ebeln = lines( lr_ebeln ).

*---- Auswertung
      IF l_x_kblnr EQ abap_on.
        IF l_lines_fistl EQ lc_lines_1 AND
           l_lines_fipex EQ lc_lines_1 AND
           l_lines_ebeln EQ lc_lines_1.
          cv_btyp = c_btyp_ane.
        ELSE.
          cv_btyp = c_btyp_spl.
        ENDIF.
      ELSE.
        IF l_lines_fistl EQ lc_lines_1 AND
           l_lines_fipex EQ lc_lines_1 AND
           l_lines_ebeln EQ lc_lines_1.
          cv_btyp = c_btyp_fua.
        ELSE.
          cv_btyp = c_btyp_spl.
        ENDIF.
      ENDIF.

*-- Buchungstyp ALL
    WHEN c_btyp_all.
      LOOP AT it_kbld INTO ls_kbld.
        EXIT.
      ENDLOOP.
      IF NOT sy-subrc IS INITIAL.
        RETURN.
      ENDIF.
*---- Prüfen, ob in Tab. ZSST_SAP_DHB_ANO vorhanden
      CLEAR l_gjahr. l_gjahr = ls_kbld-kerdat(4).
      SELECT COUNT(*) FROM zsst_sap_dhb_ano UP TO 1 ROWS
                     WHERE gjahr     EQ l_gjahr       AND
                           refbn     EQ ls_kbld-belnr AND
                       NOT belnr_dhb EQ lc_belnr_init.
      IF NOT sy-subrc IS INITIAL.
        CLEAR l_x_exist.
      ELSE.
        MOVE abap_on TO l_x_exist.
      ENDIF.

      CASE ls_kbld-blart.
        WHEN c_blart_ba.
          IF l_x_exist EQ abap_on.
            CLEAR cv_btyp.
          ELSE.
            cv_btyp = c_btyp_all.
          ENDIF.
        WHEN c_blart_ae.
          IF l_x_exist EQ abap_on.
            cv_btyp = c_btyp_aea.
          ELSE.
            cv_btyp = c_btyp_sst.
          ENDIF.
      ENDCASE.

  ENDCASE.

ENDMETHOD.                    "check_btyp


*----------------------------------------------------------------------*
* METHOD GET_IBAN_SWIFT_DATA
*----------------------------------------------------------------------*
METHOD get_iban_swift_data.

* lokale Datendeklaration
  DATA: l_bankn35 TYPE bankn35.

* Ermitteln der IBAN-Daten
  IF es_iban IS REQUESTED.
    l_bankn35 = iv_bankn.

    CALL FUNCTION 'READ_IBAN_INT'
      EXPORTING  i_banks   = iv_banks
                 i_bankl   = iv_bankl
                 i_bankn   = l_bankn35
                 i_bkont   = iv_bkont
      IMPORTING  e_iban_wa = es_iban.
  ENDIF.

* Ermitteln der SWIFT-Daten
  IF es_bnka IS REQUESTED.
    CALL FUNCTION 'READ_BANK_ADDRESS'
      EXPORTING  bank_country  = iv_banks
                 bank_number   = iv_bankl
      IMPORTING  bnka_wa       = es_bnka
      EXCEPTIONS error_message = 2.

    IF NOT sy-subrc IS INITIAL.
      CLEAR es_bnka.
    ENDIF.
  ENDIF.

ENDMETHOD.                    "get_iban_swift_data


*----------------------------------------------------------------------*
* METHOD BUILD_BIC_KEY
*----------------------------------------------------------------------*
METHOD build_bic_key.

* lokale Datendeklaration
  CONSTANTS: lc_char_x TYPE c VALUE 'X',
             lc_len_11 TYPE i VALUE 11.

  DATA: l_len_swift TYPE i,
        l_times     TYPE i.

* Übernahme des Importwertes
  rv_biczp = iv_swift.

* Berechnen Länge und Anzahl Ersetzungen
  l_len_swift = strlen( iv_swift ).

  l_times = lc_len_11 - l_len_swift.

  DO l_times TIMES.
    CONCATENATE rv_biczp lc_char_x INTO rv_biczp.
  ENDDO.

ENDMETHOD.                    "build_bic_key


*----------------------------------------------------------------------*
* METHOD GET_TXTSL
*----------------------------------------------------------------------*
METHOD get_txtsl.

* lokale Datendeklaration
  TYPE-POOLS: mmcr.

  CONSTANTS: lc_value_1    TYPE i VALUE 1,
             lc_value_3    TYPE i VALUE 3,
             lc_value_4    TYPE i VALUE 4,
             lc_knttp_init TYPE knttp VALUE IS INITIAL,
             lc_vgabe_2    TYPE vgabe VALUE '2'.

  DATA: l_len   TYPE i,
        l_belnr TYPE re_belnr,
        l_gjahr TYPE gjahr,
        l_fipos TYPE fipos,
        l_rfpos TYPE cc_rfpos,
        l_erekz TYPE erekz.

  DATA: lt_drseg  TYPE mmcr_tdrseg,
        ls_drseg  LIKE LINE OF lt_drseg,
        ls_rbkpv  TYPE mrm_rbkpv.

  DATA: lr_ebelp TYPE RANGE OF ebelp,
        lr_rfpos TYPE RANGE OF cc_rfpos,
        lr_erekz TYPE RANGE OF erekz,
        ls_erekz LIKE LINE OF lr_erekz.

* Daten zum Rechnungsbeleg ermitteln
  DESCRIBE FIELD l_belnr LENGTH l_len IN CHARACTER MODE.
  IF NOT iv_awkey IS INITIAL.
    l_belnr = iv_awkey(l_len).
    l_gjahr = iv_awkey+l_len.

    CALL FUNCTION 'MRM_PUFFER_REFRESH'.

    CALL FUNCTION 'MRM_INVOICE_READ'
      EXPORTING  i_belnr        = l_belnr
                 i_gjahr        = l_gjahr
                 i_xselk        = abap_on
      IMPORTING  e_rbkpv        = ls_rbkpv
      TABLES     t_drseg        = lt_drseg
      EXCEPTIONS error_message  = 3.

    IF NOT sy-subrc IS INITIAL.
      CLEAR lt_drseg. rv_txtsl = lc_value_3.
    ELSE.
      CALL FUNCTION 'FM_FIPOS_GET_FROM_FIPEX'
        EXPORTING  i_fipex = iv_fipex
        IMPORTING  e_fipos = l_fipos
        EXCEPTIONS OTHERS  = 3.

      IF NOT sy-subrc IS INITIAL.
        l_fipos = iv_fipex.
      ENDIF.

      DELETE lt_drseg WHERE NOT ebeln EQ iv_ebeln.
      LOOP AT lt_drseg INTO ls_drseg.
        CASE ls_drseg-knttp.
          WHEN lc_knttp_init.
          WHEN OTHERS.
            DELETE lt_drseg WHERE: NOT fistl EQ iv_fistl,
                                   NOT fipos EQ l_fipos.
        ENDCASE.
      ENDLOOP.

    ENDIF.
  ENDIF.

* Daten mit Tabelle FMIOI abgleichen, um zu ermitteln, ob es weitere
* Positionen mit der gleichen Kontierung gibt, die aber nicht in der
* Rechnung enthalten waren
  LOOP AT lt_drseg INTO ls_drseg.
    ref_help->set_range_value( EXPORTING iv_value_low = ls_drseg-ebelp
                                CHANGING ct_range     = lr_ebelp ).
  ENDLOOP.

  SELECT rfpos INTO l_rfpos FROM fmioi
              WHERE refbn EQ iv_ebeln AND
                    fistl EQ iv_fistl AND
                    fipex EQ iv_fipex AND NOT
                    rfpos IN lr_ebelp.
    ref_help->set_range_value( EXPORTING iv_value_low = l_rfpos
                                CHANGING ct_range     = lr_rfpos ).
  ENDSELECT.
  SORT lr_rfpos BY low.
  DELETE ADJACENT DUPLICATES FROM lr_rfpos COMPARING ALL FIELDS.

  IF lines( lr_rfpos ) IS INITIAL.
    SORT lt_drseg  BY erekz.
    DELETE ADJACENT DUPLICATES FROM lt_drseg COMPARING erekz.
    CASE lines( lt_drseg ).
      WHEN lc_value_1.
        READ TABLE lt_drseg INTO ls_drseg INDEX lc_value_1.
        IF ls_drseg-erekz EQ abap_on.
          rv_txtsl = lc_value_4.
        ELSE.
          rv_txtsl = lc_value_3.
        ENDIF.
      WHEN OTHERS.
        rv_txtsl = lc_value_3.
    ENDCASE.
  ELSE.
    APPEND LINES OF lr_rfpos TO lr_ebelp.
    SELECT erekz INTO l_erekz FROM ekpo
                WHERE ebeln EQ iv_ebeln AND
                      ebelp IN lr_ebelp.
      ref_help->set_range_value( EXPORTING iv_value_low = l_erekz
                                  CHANGING ct_range     = lr_erekz ).
    ENDSELECT.
    SORT lr_erekz BY low.
    DELETE ADJACENT DUPLICATES FROM lr_erekz COMPARING ALL FIELDS.
    CASE lines( lr_erekz ).
      WHEN lc_value_1.
        READ TABLE lr_erekz INTO ls_erekz INDEX lc_value_1.
        IF ls_erekz-low EQ abap_on.
          SELECT COUNT(*) FROM ekbe UP TO 1 ROWS
                         WHERE ebeln EQ iv_ebeln       AND
                               ebelp IN lr_ebelp       AND
                               vgabe EQ lc_vgabe_2     AND
                               budat EQ ls_rbkpv-budat AND
                               gjahr EQ ls_rbkpv-gjahr AND
                           NOT belnr EQ ls_rbkpv-belnr.
          IF sy-subrc IS INITIAL.
            rv_txtsl = lc_value_3.
          ELSE.
            rv_txtsl = lc_value_4.
          ENDIF.
        ELSE.
          rv_txtsl = lc_value_3.
        ENDIF.
      WHEN OTHERS.
        rv_txtsl = lc_value_3.
    ENDCASE.
  ENDIF.

ENDMETHOD.                    "get_txtsl


*----------------------------------------------------------------------*
* METHOD CHECK_MB_FAE
*----------------------------------------------------------------------*
METHOD check_mb_fae.

* lokale Datendeklaration
  CONSTANTS: lc_divide_100 TYPE wrbtr VALUE '100',
             lc_wrbtr_init TYPE wrbtr VALUE IS INITIAL,
             lc_xblnr_init TYPE xblnr1 VALUE IS INITIAL.

  DATA: l_wrbtr     TYPE wrbtr,
        l_x_chg_feb TYPE xfeld,
        lr_btyp     TYPE RANGE OF zbtyp.

  DATA: ls_feb_data LIKE LINE OF ct_feb_save.

  FIELD-SYMBOLS: <t_export>   TYPE tt_sst_export,
                 <s_export>   LIKE LINE OF <t_export>,
                 <s_feb_save> LIKE LINE OF ct_feb_save.

* Range für zu prüfende Buchungstypen
  ref_help->set_range_value( EXPORTING iv_value_low = c_btyp_fae
                              CHANGING ct_range     = lr_btyp ).

* Prüfen, ob es in der Tabelle CT_EXPORT zur Bestellung einen FAE-Satz
* gibt; übergebene Referenz darf nicht leer sein
  ASSIGN cref_export->* TO <t_export>.
  IF iv_xblnr EQ lc_xblnr_init.
    RETURN.
  ENDIF.

  LOOP AT <t_export> ASSIGNING <s_export>
                     WHERE btyp  IN lr_btyp AND
                         ( xblnr EQ iv_xblnr OR
                           rese1 EQ iv_xblnr ).
*-- Anpassen der Beträge
    l_wrbtr = <s_export>-betr1.
    DIVIDE l_wrbtr BY lc_divide_100.

*-- Abziehen des Rechnungsbetrages; wenn Null kann die Zeile gelöscht
*-- werden
    l_wrbtr = l_wrbtr - is_ano_data-brtwr_sap.
    IF l_wrbtr EQ lc_wrbtr_init.
      DELETE <t_export>.
      l_x_chg_feb = abap_on.
    ELSE.
      IF l_wrbtr LT lc_wrbtr_init.
        MULTIPLY l_wrbtr BY -1.
        <s_export>-belkz = c_kz_b.
      ENDIF.
*---- Zurückschreiben des aktualisierten Betrages
      <s_export>-betr1 = l_wrbtr.
      REPLACE ALL OCCURRENCES OF: c_colon IN <s_export>-betr1 WITH space,
                                  c_point IN <s_export>-betr1 WITH space.
      CONDENSE <s_export>-betr1 NO-GAPS.
    ENDIF.

*-- Anpassen der FEB-Save-Tabelle im Falle, dass eine Änderung der Be-
*-- stellung durch die Rechnung verursacht wurde nicht aber durch eine
*-- Änderung an ihr selbst
    IF l_x_chg_feb EQ abap_on.
      LOOP AT ct_feb_save ASSIGNING <s_feb_save>
                          WHERE gjahr EQ is_ano_data-gjahr AND
                                fipex EQ is_ano_data-fipex AND
                                fistl EQ is_ano_data-fistl AND
                                aufkz EQ iv_xblnr.
        EXIT.
      ENDLOOP.
      IF NOT sy-subrc IS INITIAL.
        SELECT SINGLE * FROM (c_sst_tabn_feb) INTO ls_feb_data
                       WHERE gjahr EQ is_ano_data-gjahr AND
                             fipex EQ is_ano_data-fipex AND
                             fistl EQ is_ano_data-fistl AND
                             aufkz EQ iv_xblnr.
        IF sy-subrc IS INITIAL.
          APPEND INITIAL LINE TO ct_feb_save ASSIGNING <s_feb_save>.
          MOVE-CORRESPONDING ls_feb_data TO <s_feb_save>.
        ENDIF.
      ENDIF.
      IF <s_feb_save> IS ASSIGNED.
        ADD is_ano_data-brtwr_sap TO <s_feb_save>-brtwr_sap.
      ENDIF.
    ENDIF.

    CLEAR l_x_chg_feb.
  ENDLOOP.


ENDMETHOD.                    "check_mb_fae


*----------------------------------------------------------------------*
* METHOD REDUCE_MB
*----------------------------------------------------------------------*
METHOD reduce_mb.

* lokale Datendeklaration
  CONSTANTS: lc_value_3    TYPE i VALUE 3,
             lc_value_4    TYPE i VALUE 4,
             lc_xblnr_init TYPE xblnr1 VALUE IS INITIAL.

  DATA: lt_kbld     TYPE fm_t_kbld,
        lt_ekpo     TYPE meout_t_ekpo,
        ls_kbld     LIKE LINE OF lt_kbld,
        ls_feb_data LIKE LINE OF ct_feb_save.

  FIELD-SYMBOLS: <s_feb_save> LIKE LINE OF ct_feb_save.

* Prüfen, dass übergebene Referenz ungleich leer ist
  IF iv_xblnr EQ lc_xblnr_init.
    RETURN.
  ENDIF.

* Anpassung der Tabelle ZSST_SAP_DHB_FEB
  LOOP AT ct_feb_save ASSIGNING <s_feb_save>
                      WHERE gjahr EQ is_ano_data-gjahr AND
                            fipex EQ is_ano_data-fipex AND
                            fistl EQ is_ano_data-fistl AND
                            aufkz EQ iv_xblnr.
    EXIT.
  ENDLOOP.
  IF NOT sy-subrc IS INITIAL.
    SELECT SINGLE * FROM (c_sst_tabn_feb) INTO ls_feb_data
                   WHERE gjahr EQ is_ano_data-gjahr AND
                         fipex EQ is_ano_data-fipex AND
                         fistl EQ is_ano_data-fistl AND
                         aufkz EQ iv_xblnr.
    IF sy-subrc IS INITIAL.
      APPEND INITIAL LINE TO ct_feb_save ASSIGNING <s_feb_save>.
      MOVE-CORRESPONDING ls_feb_data TO <s_feb_save>.
    ENDIF.
  ENDIF.

* Lesen der Mittelbindungs- bzw. Bestelldaten
  IF <s_feb_save> IS ASSIGNED AND NOT <s_feb_save>-refbn IS INITIAL.
    read_document_data( EXPORTING iv_blart = <s_feb_save>-blart
                                  iv_refbn = <s_feb_save>-refbn
                        IMPORTING et_kbld  = lt_kbld
                                  et_ekpo  = lt_ekpo ).

    IF NOT lines( lt_kbld ) IS INITIAL.
      READ TABLE lt_kbld INTO ls_kbld
                         WITH KEY belnr = <s_feb_save>-refbn.
      IF sy-subrc IS INITIAL.
        IF ls_kbld-fexec EQ abap_on.
          CLEAR <s_feb_save>-brtwr_sap.
        ELSE.
          <s_feb_save>-brtwr_sap = <s_feb_save>-brtwr_sap -
                                   is_ano_data-brtwr_sap.
        ENDIF.
      ENDIF.
    ENDIF.

    IF NOT lines( lt_ekpo ) IS INITIAL.
      CASE iv_txtsl.
        WHEN lc_value_3.
          <s_feb_save>-brtwr_sap = <s_feb_save>-brtwr_sap -
                                   is_ano_data-brtwr_sap.
        WHEN lc_value_4.
          CLEAR <s_feb_save>-brtwr_sap.
      ENDCASE.
    ENDIF.

  ENDIF.

ENDMETHOD.                    "reduce_mb


*----------------------------------------------------------------------*
* METHOD COMPARE_ME_MB_DATA
*----------------------------------------------------------------------*
METHOD compare_me_mb_data.

* lokale Datendeklaration
  DATA: l_diff TYPE wrbtr.

  DATA: ls_me_data  LIKE LINE OF it_me_data,
        ls_export   LIKE LINE OF et_export.

  DATA: lt_ekpo TYPE meout_t_ekpo,
        lt_ekkn TYPE meout_t_ekkn.

  FIELD-SYMBOLS: <s_feb_save> LIKE LINE OF ct_feb_save.

* Abgleich der Beträge zwischen Bestellung und übergebenen Daten
  LOOP AT it_me_data INTO ls_me_data.
    LOOP AT ct_feb_save ASSIGNING <s_feb_save>
                        WHERE gjahr EQ ls_me_data-gjahr AND
                              refbn EQ ls_me_data-refbn AND
                              fipex EQ ls_me_data-fipex AND
                              fistl EQ ls_me_data-fistl.
      EXIT.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
      IF NOT ls_me_data-brtwr_sap EQ <s_feb_save>-brtwr_sap.
*------ Differenz berechnen
        l_diff = ls_me_data-brtwr_sap - <s_feb_save>-brtwr_sap.

*------ Daten zur Bestellung lesen
        read_document_data( EXPORTING iv_blart = <s_feb_save>-blart
                                      iv_refbn = <s_feb_save>-refbn
                            IMPORTING et_ekpo  = lt_ekpo
                                      et_ekkn  = lt_ekkn ).

*------ FAE-Satz erzeugen
        ls_export = map_fae_data( iv_btyp  = c_btyp_fae
                                  iv_diff  = l_diff
                                  is_data  = <s_feb_save>
                                  it_ekpo  = lt_ekpo
                                  it_ekkn  = lt_ekkn ).
        IF NOT ls_export IS INITIAL.
          APPEND ls_export TO et_export.
        ENDIF.

*------ Anpassung der Tab. ZSST_SAP_DHB_FEB
        <s_feb_save>-brtwr_sap = ls_me_data-brtwr_sap.
      ENDIF.
    ENDIF.
*-- Initialisierung
    CLEAR: ls_me_data, lt_ekpo, lt_ekkn, ls_export.
  ENDLOOP.


ENDMETHOD.                    "compare_me_mb_data


*----------------------------------------------------------------------*
* Methode MAP_FEB_DATA
*----------------------------------------------------------------------*
METHOD map_feb_data.

* lokale Datendeklaration
  CONSTANTS: lc_datend  TYPE c LENGTH 4 VALUE '1231',
             lc_datbeg  TYPE c LENGTH 4 VALUE '0101',
             lc_lines_1 TYPE i VALUE 1,
             lc_index_1 TYPE i VALUE 1,
             lc_times_5 TYPE i VALUE 5.

  TYPES: BEGIN OF ts_mjve_values,
          belnr TYPE kblnr,
          value TYPE i,
          gjahr TYPE gjahr,
          wrbtr TYPE wrbtr,
         END OF ts_mjve_values.

  TYPES: tt_mjve_values TYPE STANDARD TABLE OF ts_mjve_values
                                          WITH DEFAULT KEY.

  DATA: l_len      TYPE i,
        l_gjahr    TYPE gjahr,
        l_gjahr_ve TYPE gjahr,
        l_fipos    TYPE fipos,
        l_ebelp    TYPE ebelp,
        l_datum    TYPE datum,
        l_fojdt    TYPE datum,
        l_eojdt    TYPE datum,
        l_wgbez    TYPE wgbez,
        lr_btart   TYPE RANGE OF fm_btart.

  DATA: lt_mjve_values TYPE tt_mjve_values,
        ls_mjve_values LIKE LINE OF lt_mjve_values.

  DATA: ls_ekpo LIKE LINE OF it_ekpo,
        ls_ekkn LIKE LINE OF it_ekkn,
        lt_eket TYPE meout_t_eket,
        ls_eket LIKE LINE OF lt_eket,
        ls_kbld LIKE LINE OF it_kbld.

  FIELD-SYMBOLS: <lv_value> TYPE any.

* im Vorfeld der Aufbereitung die Tabellen lesen
  CASE is_data-blart.
*-- Bestellungen
    WHEN c_blart_nb.
      CALL FUNCTION 'FI_PSO_FIPOS_GET_FROM_FIPEX'
        EXPORTING  i_fipex = is_data-fipex
        IMPORTING  e_fipos = l_fipos.

      READ TABLE it_ekkn INTO ls_ekkn WITH KEY ebeln = is_data-refbn
                                               fistl = is_data-fistl
                                               fipos = l_fipos.
      IF NOT sy-subrc IS INITIAL.
        READ TABLE it_ekpo INTO ls_ekpo WITH KEY ebeln = is_data-refbn
                                                 fistl = is_data-fistl
                                                 fipos = l_fipos.
        IF sy-subrc IS INITIAL.
          l_ebelp = ls_ekpo-ebelp.
        ENDIF.
      ELSE.
        l_ebelp = ls_ekkn-ebelp.
        READ TABLE it_ekpo INTO ls_ekpo WITH KEY ebeln = is_data-refbn
                                                 ebelp = l_ebelp.
      ENDIF.

      CALL FUNCTION 'ME_EKET_SINGLE_READ_ITEM'
        EXPORTING  pi_ebeln      = is_data-refbn
                   pi_ebelp      = l_ebelp
        TABLES     pto_eket      = lt_eket
        EXCEPTIONS error_message = 2.

      IF NOT sy-subrc IS INITIAL.
        CLEAR lt_eket.
      ELSE.
        READ TABLE lt_eket INTO ls_eket WITH KEY ebeln = is_data-refbn
                                                 ebelp = l_ebelp.
      ENDIF.

      CALL FUNCTION 'T023_READ'
        EXPORTING  matkl         = ls_ekpo-matkl
                   spras         = sy-langu
        IMPORTING  text          = l_wgbez
        EXCEPTIONS error_message = 2.

      IF NOT sy-subrc IS INITIAL.
        CLEAR l_wgbez.
      ENDIF.

*-- Mittelbindung
    WHEN c_blart_fe OR c_blart_ve.
      READ TABLE it_kbld INTO ls_kbld WITH KEY belnr = is_data-refbn
                                               fipex = is_data-fipex
                                               fistl = is_data-fistl.

      IF iv_gjahr IS SUPPLIED AND NOT iv_gjahr IS INITIAL.
        l_gjahr = iv_gjahr.
      ELSE.
        l_gjahr = is_data-gjahr.
      ENDIF.

      IF is_data-blart EQ c_blart_ve AND
        lines( it_kbld ) GE lc_lines_1.
        DO lc_times_5 TIMES.
          CASE sy-index.
            WHEN lc_index_1.
              l_gjahr_ve = l_gjahr.
            WHEN OTHERS.
              l_gjahr_ve = l_gjahr + sy-index - lc_index_1.
          ENDCASE.
          CONCATENATE: l_gjahr_ve lc_datbeg INTO l_fojdt,
                       l_gjahr_ve lc_datend INTO l_eojdt.

          LOOP AT it_kbld INTO ls_kbld
                         WHERE belnr EQ is_data-refbn AND
                               blart EQ c_blart_ve    AND
                               fdatk GE l_fojdt       AND
                               fdatk LE l_eojdt.
            EXIT.
          ENDLOOP.
          IF sy-subrc IS INITIAL.
            APPEND INITIAL LINE TO lt_mjve_values
                         ASSIGNING FIELD-SYMBOL(<ls_values>).
            <ls_values>-belnr = ls_kbld-belnr.
            <ls_values>-gjahr = l_gjahr_ve.
            <ls_values>-value = l_gjahr_ve - l_gjahr.

            <ls_values>-wrbtr = get_fmioi_values(
                                  iv_refbt = c_refbt_110
                                  iv_refbn = ls_kbld-belnr
                                  iv_rfpos = CONV #( ls_kbld-blpos )
                                  iv_gnjhr = l_gjahr_ve
                                  ir_btart = lr_btart ).
          ENDIF.
        ENDDO.
      ENDIF.
  ENDCASE.

* Feld 1 - Buchungstyp
  rs_export-btyp = iv_btyp.
* Feld 2 - Merkmal
  rs_export-merkm = abap_off.
* Feld 3 - Firma
  rs_export-firma = abap_off.
* Feld 4 - HHJ
  rs_export-hhj = is_data-gjahr.
* Feld 5 - Quelle
  rs_export-quelle = abap_off.
* Feld 6 - Belegnummer
  rs_export-belnr = is_data-refbn+2(8).
* Feld 7 - Belegposition
  rs_export-blpos = c_count.
* Feld 8 - Userkennzeichen
  rs_export-kerfas = c_usrkz.
* Feld 9 - Bereich
  rs_export-berei = is_data-fipex(2).
* Feld 10 - Kapitel
  rs_export-kapit = is_data-fipex+2(4).
* Feld 11 - Titel
  CONCATENATE is_data-fipex+6(3) is_data-fipex+9(2)
         INTO rs_export-titel SEPARATED BY abap_off.
* Feld 12 - Org.einheit
  rs_export-orgeh = is_data-fistl(8).
* Feld 13 - Unterkonto
  IF is_data-fipex+11(6) IS INITIAL.
    rs_export-unkto = c_unkto_00.
  ELSE.
    rs_export-unkto = is_data-fipex+11(6).
  ENDIF.
* Feld 14 - Referenznummer
  rs_export-refnr = abap_off.
* Feld 15 - Betrag (nur für Belegart 'FE' und 'NB')
  IF is_data-blart EQ c_blart_fe OR is_data-blart EQ c_blart_nb.
    rs_export-betr1 = is_data-brtwr_sap.
    REPLACE ALL OCCURRENCES OF: c_colon IN rs_export-betr1 WITH space,
                                c_point IN rs_export-betr1 WITH space.
    CONDENSE rs_export-betr1 NO-GAPS.
  ENDIF.
* Feld 16 - BETR2 - Betrag (nur für Belegart 'VE' und HH-Jahr + 1)
* Feld 18 - BETR3 - Betrag (nur für Belegart 'VE' und HH-Jahr + 2)
* Feld 20 - BETR4 - Betrag (nur für Belegart 'VE' und HH-Jahr + 3)
* Feld 24 - RESE2 - Betrag (nur für Belegart 'VE' und HH-Jahr + 4)
* Feld 26 - RESE3 - Betrag (nur für Belegart 'VE' und HH-Jahr + 5)
  IF is_data-blart EQ c_blart_ve AND
    NOT lines( lt_mjve_values ) IS INITIAL.

    LOOP AT lt_mjve_values INTO ls_mjve_values.
      CASE ls_mjve_values-value.
        WHEN 0.
          ASSIGN rs_export-betr1 TO <lv_value>.
        WHEN 1.
          ASSIGN rs_export-betr2 TO <lv_value>.
        WHEN 2.
          ASSIGN rs_export-betr3 TO <lv_value>.
        WHEN 3.
          ASSIGN rs_export-betr4 TO <lv_value>.
        WHEN 4.
          ASSIGN rs_export-rese2 TO <lv_value>.
        WHEN 5.
          ASSIGN rs_export-rese3 TO <lv_value>.
        WHEN OTHERS.
      ENDCASE.
      IF <lv_value> IS ASSIGNED.
        <lv_value> = ls_mjve_values-wrbtr.
        REPLACE ALL OCCURRENCES OF: c_colon IN <lv_value>
                                    WITH space,
                                    c_point IN <lv_value>
                                    WITH space.
        CONDENSE <lv_value> NO-GAPS.
      ENDIF.
    ENDLOOP.
  ENDIF.
* Feld 17 - Fälligkeitsdatum
  CASE is_data-blart.
*-- Bestellungen
    WHEN c_blart_nb.
      rs_export-faedt = ls_eket-eindt.
*-- Mittelbindungen FE
    WHEN c_blart_fe.
      IF ls_kbld-fdatk IS INITIAL.
        CONCATENATE is_data-gjahr lc_datend INTO l_datum.
        rs_export-faedt = l_datum.
      ELSE.
        rs_export-faedt = ls_kbld-fdatk.
      ENDIF.
*-- Mittelbindungen VE
    WHEN c_blart_ve.
      IF lines( it_kbld ) GT lc_lines_1.
        rs_export-faedt = abap_off.
      ELSE.
        rs_export-faedt = ls_kbld-fdatk.
      ENDIF.
  ENDCASE.
* Feld 19 - Textschlüssel
  rs_export-txtsl = abap_off.
* Feld 21 - Be-/Entlastungskennzeichen
  rs_export-belkz = c_kz_b.
* Feld 22 - Auftragskennzeichen
  rs_export-rese1 = is_data-aufkz.
* Feld 23 - Einmallieferant
  rs_export-lifnr = c_lifnr_001.
* Feld 25 - lfd. Nummer Bankverbindung
  rs_export-bnknr = c_bnknr_1.
* Feld 27 - Kasse
  rs_export-kasse = abap_off.
* Feld 28 - Aktenzeichen
  rs_export-aktkz = abap_off.
* Feld 29 - Begründung
  CASE is_data-blart.
    WHEN c_blart_nb.
      rs_export-grund = TEXT-tfg.
      IF NOT l_wgbez IS INITIAL.
        l_len = strlen( l_wgbez ).
        IF NOT l_len IS INITIAL.
          REPLACE '&1' WITH l_wgbez(l_len) INTO rs_export-grund.
        ELSE.
          REPLACE '&1' WITH abap_off INTO rs_export-grund.
        ENDIF.
      ELSE.
        l_len = strlen( ls_ekpo-matkl ).
        IF NOT l_len IS INITIAL.
          REPLACE '&1' WITH ls_ekpo-matkl(l_len) INTO rs_export-grund.
        ELSE.
          REPLACE '&1' WITH abap_off INTO rs_export-grund.
        ENDIF.
      ENDIF.
    WHEN c_blart_fe OR c_blart_ve.
      rs_export-grund = ls_kbld-ktext.
  ENDCASE.
* Feld 30 - Begründung
  rs_export-buchn = abap_off.
* Feld 31 - Währung
  rs_export-lfdnr = abap_off.
* Feld 32 - Belegkassenzeichen
  rs_export-kassz = abap_off.
* Feld 33 - Status der Übernahme
  rs_export-bnstat = c_bnstat_0.
* Feld 34 - Übernahme-User
  rs_export-bnuser = abap_off.
* Feld 35 - Übernahmedatum
  rs_export-bndat = abap_off.
* Feld 36 - Übernahmezeit
  rs_export-bnzeit = abap_off.
* Feld 37 - DHB-Fehlercode
  rs_export-bnerr = abap_off.
* Feld 38 - Leerfeld
  rs_export-rese4 = abap_off.
* Feld 39 - Leerfeld
  rs_export-rese5 = abap_off.
* Feld 40 - Zahlstelle
  rs_export-zhlst = abap_off.
* Feld 41 - Referenzbelgnummer
  rs_export-xblnr = abap_off.
* Feld 42 - Begründung
  rs_export-rese6 = abap_off.
* Feld 43 - leer
  rs_export-rese7 = abap_off.
* Feld 44 - leer
  rs_export-dnstl = abap_off.
* Feld 45 - leer
  rs_export-ftext = abap_off.
* Feld 46 - leer
  rs_export-name2 = abap_off.
* Feld 47 - leer
   rs_export-buchz = abap_off.
* Feld 48 - leer
  rs_export-vehhj = abap_off.
* Feld 49 - Dienststelle
  rs_export-dstnr = c_dstnr_3101.
* Feld 50 - Verfahrenskennzeichen
  rs_export-verkz = c_verkz_sap.
* Feld 51 - Länderschlüssel
  rs_export-land1 = abap_off.
* Feld 52 - Postleitzahl
  rs_export-pstlz = abap_off.
* Feld 53 - Betrag
  rs_export-fbetr = abap_off.
* Feld 54 - Umrechnungskurs
  rs_export-kursf = abap_off.
* Feld 55 - Gesamtbetrag
  rs_export-gbbtr = abap_off.
* Feld 56 - Währung
  rs_export-pstlz = abap_off.
* Feld 57 - Bankname 1
  rs_export-bnknm1 = abap_off.
* Feld 58 - Bankname 2
  rs_export-bnknm2 = abap_off.
* Feld 59 - Straße der Bank
  rs_export-bnkstr = abap_off.
* Feld 60 - Ort der Bank
  rs_export-bnkort = abap_off.
* Feld 61 - Weisungscode
  rs_export-wsgkey = abap_off.
* Feld 62 - Text
  rs_export-kvkey = abap_off.
* Feld 63 - BIC
  rs_export-biczp = abap_off.
* Feld 64 - BEI
  rs_export-beizp = abap_off.
* Feld 65 - IBAN
  rs_export-iban = abap_off.
* Feld 66 - Anzahl
  rs_export-anzms = abap_off.
* Feld 67 - Straße der Bank
  rs_export-vtrag = abap_off.
* Feld 68 - Ort Unterschrift
  rs_export-osign = abap_off.
* Feld 69 - Datum Unterschrift
  rs_export-dsign = abap_off.
* Feld 70 - Identifier
  rs_export-ident = abap_off.
* Feld 71 - Status Mandat
  rs_export-mstat = abap_off.
* Feld 72 - Ursprungsmandat
  rs_export-mgaen = abap_off.
* Feld 73 - Druckdatum
  rs_export-prdat = abap_off.
* Feld 74 - Druckertyp
  rs_export-vtrag = abap_off.

ENDMETHOD.                    "map_feb_data


*----------------------------------------------------------------------*
* Methode MAP_FAE_DATA
*----------------------------------------------------------------------*
METHOD map_fae_data.

* lokale Datendeklaration
  CONSTANTS: lc_value_init TYPE wrbtr VALUE IS INITIAL,
             lc_number     TYPE c LENGTH 10 VALUE '0123456789'.

  CONSTANTS: lc_datend  TYPE c LENGTH 4 VALUE '1231',
             lc_datbeg  TYPE c LENGTH 4 VALUE '0101',
             lc_lines_1 TYPE i VALUE 1,
             lc_index_1 TYPE i VALUE 1,
             lc_times_5 TYPE i VALUE 5.

  TYPES: BEGIN OF ts_mjve_values,
          belnr TYPE kblnr,
          value TYPE i,
          gjahr TYPE gjahr,
          wrbtr TYPE wrbtr,
          diff  TYPE wrbtr,
         END OF ts_mjve_values.

  TYPES: tt_mjve_values TYPE STANDARD TABLE OF ts_mjve_values
                                          WITH DEFAULT KEY.

  DATA: l_len       TYPE i,
        l_gjahr     TYPE gjahr,
        l_gjahr_ve  TYPE gjahr,
        l_fojdt     TYPE datum,
        l_eojdt     TYPE datum,
        l_fipos     TYPE fipos,
        l_ebelp     TYPE ebelp,
        l_wgbez     TYPE wgbez,
        l_diff      TYPE brtwr,
        l_brtwr     TYPE brtwr,
        l_brtwr_abs TYPE brtwr,
        l_lotkz     TYPE pso_lotkz,
        lr_btart    TYPE RANGE OF fm_btart.

  DATA: lt_mjve_values TYPE tt_mjve_values,
        ls_mjve_values LIKE LINE OF lt_mjve_values.

  DATA: ls_ekpo     LIKE LINE OF it_ekpo,
        ls_ekkn     LIKE LINE OF it_ekkn,
        ls_kbld     LIKE LINE OF it_kbld,
        ls_feb_data TYPE ts_feb_data,
        ls_feb_mvj  TYPE ts_feb_data.

  FIELD-SYMBOLS: <lv_value> TYPE any.

* im Vorfeld der Aufbereitung die Tabellen lesen
  CASE is_data-blart.
*-- Bestellungen
    WHEN c_blart_nb.
      CALL FUNCTION 'FI_PSO_FIPOS_GET_FROM_FIPEX'
        EXPORTING i_fipex = is_data-fipex
        IMPORTING e_fipos = l_fipos.

      READ TABLE it_ekkn INTO ls_ekkn WITH KEY ebeln = is_data-refbn
                                               fistl = is_data-fistl
                                               fipos = l_fipos.
      IF NOT sy-subrc IS INITIAL.
        READ TABLE it_ekpo INTO ls_ekpo WITH KEY ebeln = is_data-refbn
                                                 fistl = is_data-fistl
                                                 fipos = l_fipos.
        IF sy-subrc IS INITIAL.
          l_ebelp = ls_ekpo-ebelp.
        ENDIF.
      ELSE.
        l_ebelp = ls_ekkn-ebelp.
        READ TABLE it_ekpo INTO ls_ekpo WITH KEY ebeln = is_data-refbn
                                                 ebelp = l_ebelp.
      ENDIF.

      CALL FUNCTION 'T023_READ'
        EXPORTING   matkl         = ls_ekpo-matkl
                    spras         = sy-langu
        IMPORTING   text          = l_wgbez
        EXCEPTIONS  error_message = 2.

      IF NOT sy-subrc IS INITIAL.
        CLEAR l_wgbez.
      ENDIF.

      IF NOT iv_diff IS SUPPLIED.
        SELECT SINGLE * FROM (c_sst_tabn_feb) INTO ls_feb_data
                       WHERE gjahr EQ is_data-gjahr AND
                             refbn EQ is_data-refbn AND
                             fistl EQ is_data-fistl AND
                             fipex EQ is_data-fipex.

        IF sy-subrc IS INITIAL.
          l_brtwr = l_diff = ls_feb_data-brtwr_sap - ls_feb_data-brtwr_dhb.

          IF l_diff EQ lc_value_init.
            rs_export-bnstat = c_errkz_1.
            RETURN.
          ENDIF.
        ENDIF.
      ELSE.
        l_brtwr = l_diff = iv_diff.
      ENDIF.

*-- Mittelbindung
    WHEN c_blart_fe OR c_blart_ve.
      READ TABLE it_kbld INTO ls_kbld WITH KEY belnr = is_data-refbn
                                               fipex = is_data-fipex
                                               fistl = is_data-fistl.

      SELECT SINGLE * FROM (c_sst_tabn_feb) INTO ls_feb_data
                     WHERE gjahr EQ is_data-gjahr AND
                           refbn EQ is_data-refbn AND
                           fistl EQ is_data-fistl AND
                           fipex EQ is_data-fipex.

*---- sofern es sich um eine Änderung einer Mittelbindung, die aus
*---- einer DAO stammt handelt, muss die Differenz aus Basis der über-
*---- gebenen Beträge ermittelt werden
      IF sy-subrc IS INITIAL.
        l_brtwr = l_diff = ls_feb_data-brtwr_sap -
                           ls_feb_data-brtwr_dhb.

        IF l_diff EQ lc_value_init.
          IF NOT ls_kbld-ktext IS INITIAL AND
                 ls_kbld-ktext CO lc_number.
            DESCRIBE FIELD l_lotkz LENGTH l_len IN CHARACTER MODE.
            l_lotkz = ls_kbld-ktext(l_len).

            SELECT COUNT(*) FROM psokpf UP TO 1 ROWS
                           WHERE bukrs EQ ls_kbld-bukrs AND
                                 lotkz EQ l_lotkz.
            IF sy-subrc IS INITIAL.
              l_brtwr = l_diff = is_data-brtwr_sap -
                                 is_data-brtwr_dhb.
            ENDIF.
          ENDIF.
          IF l_diff EQ lc_value_init.
            rs_export-bnstat = c_errkz_1.
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.

      IF iv_gjahr IS SUPPLIED AND NOT iv_gjahr IS INITIAL.
        l_gjahr = iv_gjahr.
      ELSE.
        l_gjahr = is_data-gjahr.
      ENDIF.

      IF is_data-blart EQ c_blart_ve AND
        lines( it_kbld ) GE lc_lines_1.
        DO lc_times_5 TIMES.
          CASE sy-index.
            WHEN lc_index_1.
              l_gjahr_ve = l_gjahr.
            WHEN OTHERS.
              l_gjahr_ve = l_gjahr + sy-index - lc_index_1.
          ENDCASE.
          CONCATENATE: l_gjahr_ve lc_datbeg INTO l_fojdt,
                       l_gjahr_ve lc_datend INTO l_eojdt.

          LOOP AT it_kbld INTO ls_kbld
                         WHERE belnr EQ is_data-refbn AND
                               blart EQ c_blart_ve    AND
                               fdatk GE l_fojdt       AND
                               fdatk LE l_eojdt.
            EXIT.
          ENDLOOP.
          IF sy-subrc IS INITIAL.
            APPEND INITIAL LINE TO lt_mjve_values
                         ASSIGNING FIELD-SYMBOL(<ls_values>).
            <ls_values>-belnr = ls_kbld-belnr.
            <ls_values>-gjahr = l_gjahr_ve.
            <ls_values>-value = l_gjahr_ve - l_gjahr.

            <ls_values>-wrbtr = get_fmioi_values(
                                  iv_refbt = c_refbt_110
                                  iv_refbn = ls_kbld-belnr
                                  iv_rfpos = CONV #( ls_kbld-blpos )
                                  iv_gnjhr = l_gjahr_ve
                                  ir_btart = lr_btart ).

            SELECT SINGLE * FROM zsst_sap_dhb_feb INTO ls_feb_mvj
                           WHERE gjahr EQ l_gjahr_ve    AND
                                 refbn EQ is_data-refbn AND
                                 fistl EQ is_data-fistl AND
                                 fipex EQ is_data-fipex.
            IF sy-subrc IS INITIAL.
              <ls_values>-diff = <ls_values>-wrbtr -
                                 ls_feb_mvj-brtwr_dhb.
            ENDIF.
          ENDIF.
        ENDDO.
      ENDIF.

  ENDCASE.

* Feld 1 - Buchungstyp
  rs_export-btyp = iv_btyp.
* Feld 2 - Merkmal
  rs_export-merkm = abap_off.
* Feld 3 - Firma
  rs_export-firma = abap_off.
* Feld 4 - HHJ
  CASE is_data-blart.
    WHEN c_blart_ve.
      rs_export-hhj = iv_gjahr.
    WHEN OTHERS.
      rs_export-hhj = is_data-gjahr.
  ENDCASE.
* Feld 5 - Quelle
  rs_export-quelle = abap_off.
* Feld 6 - Belegnummer
  rs_export-belnr = is_data-refbn+2(8).
* Feld 7 - Belegposition
  rs_export-blpos = c_count.
* Feld 8 - Userkennzeichen
  rs_export-kerfas = c_usrkz.
* Feld 9 - Bereich
  rs_export-berei = is_data-fipex(2).
* Feld 10 - Kapitel
  rs_export-kapit = abap_off.
* Feld 11 - Titel
  rs_export-titel = abap_off.
* Feld 12 - Org.einheit
  rs_export-orgeh = abap_off.
* Feld 13 - Unterkonto
  rs_export-unkto = abap_off.
* Feld 14 - Referenznummer
  rs_export-refnr = abap_off.
* Feld 15 - Betrag (nur für Belegart 'FE' und 'NB')
  IF is_data-blart EQ c_blart_fe OR is_data-blart EQ c_blart_nb.
    rs_export-betr1 = l_diff = abs( l_diff ).
    REPLACE ALL OCCURRENCES OF: c_colon IN rs_export-betr1 WITH space,
                                c_point IN rs_export-betr1 WITH space.
    CONDENSE rs_export-betr1 NO-GAPS.
  ENDIF.
* Feld 16 - Betrag (nur für Belegart 'VE' und HH-Jahr + 1)
* Feld 18 - Betrag (nur für Belegart 'VE' und HH-Jahr + 2)
* Feld 20 - Betrag (nur für Belegart 'VE' und HH-Jahr + 3)
* Feld 24 - Betrag (nur für Belegart 'VE' und HH-Jahr + 4)
* Feld 26 - Betrag (nur für Belegart 'VE' und HH-Jahr + 5)
  IF is_data-blart EQ c_blart_ve AND
    NOT lines( lt_mjve_values ) IS INITIAL.

    LOOP AT lt_mjve_values INTO ls_mjve_values
         WHERE gjahr EQ is_data-gjahr.
      CLEAR: l_brtwr, l_brtwr_abs.
      l_brtwr = ls_mjve_values-diff.
      l_brtwr_abs = abs( ls_mjve_values-diff ).

      CASE ls_mjve_values-value.
        WHEN 0.
          ASSIGN rs_export-betr1 TO <lv_value>.
        WHEN 1.
          ASSIGN rs_export-betr2 TO <lv_value>.
        WHEN 2.
          ASSIGN rs_export-betr3 TO <lv_value>.
        WHEN 3.
          ASSIGN rs_export-betr4 TO <lv_value>.
        WHEN 4.
          ASSIGN rs_export-rese2 TO <lv_value>.
        WHEN 5.
          ASSIGN rs_export-rese3 TO <lv_value>.
        WHEN OTHERS.
      ENDCASE.
      IF <lv_value> IS ASSIGNED.
        <lv_value> = l_brtwr_abs.
        REPLACE ALL OCCURRENCES OF: c_colon IN <lv_value>
                                    WITH space,
                                    c_point IN <lv_value>
                                    WITH space.
        CONDENSE <lv_value> NO-GAPS.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Feld 17 - Fälligkeitsdatum
  rs_export-faedt = abap_off.
* Feld 19 - Textschlüssel
  rs_export-txtsl = abap_off.
* Feld 21 - Be-/Entlastungskennzeichen
  IF l_brtwr LT lc_value_init.
    rs_export-belkz = c_kz_e.
  ELSE.
    rs_export-belkz = c_kz_b.
  ENDIF.
* Feld 22 - Auftragskennzeichen
  rs_export-rese1 = abap_off.
* Feld 23 - Einmallieferant
  rs_export-lifnr = abap_off.
* Feld 25 - lfd. Nummer Bankverbindung
  rs_export-bnknr = abap_off.
* Feld 27 - Kasse
  rs_export-kasse = abap_off.
* Feld 28 - Aktenzeichen
  rs_export-aktkz = abap_off.
* Feld 29 - Begründung
  CASE is_data-blart.
    WHEN c_blart_nb.
      rs_export-grund = TEXT-tfg.
      IF NOT l_wgbez IS INITIAL.
        l_len = strlen( l_wgbez ).
        IF NOT l_len IS INITIAL.
          REPLACE '&1' WITH l_wgbez(l_len) INTO rs_export-grund.
        ELSE.
          REPLACE '&1' WITH abap_off INTO rs_export-grund.
        ENDIF.
      ELSE.
        l_len = strlen( ls_ekpo-matkl ).
        IF NOT l_len IS INITIAL.
          REPLACE '&1' WITH ls_ekpo-matkl(l_len) INTO rs_export-grund.
        ELSE.
          REPLACE '&1' WITH abap_off INTO rs_export-grund.
        ENDIF.
      ENDIF.
    WHEN c_blart_fe OR c_blart_ve.
      rs_export-grund = ls_kbld-ktext.
  ENDCASE.
* Feld 30 - Begründung
  rs_export-buchn = abap_off.
* Feld 31 - Währung
  rs_export-lfdnr = abap_off.
* Feld 32 - Belegkassenzeichen
  rs_export-kassz = abap_off.
* Feld 33 - Status der Übernahme
  rs_export-bnstat = c_bnstat_0.
* Feld 34 - Übernahme-User
  rs_export-bnuser = abap_off.
* Feld 35 - Übernahmedatum
  rs_export-bndat = abap_off.
* Feld 36 - Übernahmezeit
  rs_export-bnzeit = abap_off.
* Feld 37 - DHB-Fehlercode
  rs_export-bnerr = abap_off.
* Feld 38 - Leerfeld
  rs_export-rese4 = abap_off.
* Feld 39 - Leerfeld
  rs_export-rese5 = abap_off.
* Feld 40 - Zahlstelle
  rs_export-zhlst = abap_off.
* Feld 41 - Referenzbelgnummer
  rs_export-xblnr = is_data-aufkz.
* Feld 42 - Begründung
  rs_export-rese6 = abap_off.
* Feld 43 - leer
  rs_export-rese7 = abap_off.
* Feld 44 - leer
  rs_export-dnstl = abap_off.
* Feld 45 - leer
  rs_export-ftext = abap_off.
* Feld 46 - leer
  rs_export-name2 = abap_off.
* Feld 47 - leer
  rs_export-buchz = abap_off.
* Feld 48 - leer
  rs_export-vehhj = abap_off.
* Feld 49 - Dienststelle
  rs_export-dstnr = c_dstnr_3101.
* Feld 50 - Verfahrenskennzeichen
  rs_export-verkz = c_verkz_sap.
* Feld 51 - Länderschlüssel
  rs_export-land1 = abap_off.
* Feld 52 - Postleitzahl
  rs_export-pstlz = abap_off.
* Feld 53 - Betrag
  rs_export-fbetr = abap_off.
* Feld 54 - Umrechnungskurs
  rs_export-kursf = abap_off.
* Feld 55 - Gesamtbetrag
  rs_export-gbbtr = abap_off.
* Feld 56 - Währung
  rs_export-pstlz = abap_off.
* Feld 57 - Bankname 1
  rs_export-bnknm1 = abap_off.
* Feld 58 - Bankname 2
  rs_export-bnknm2 = abap_off.
* Feld 59 - Straße der Bank
  rs_export-bnkstr = abap_off.
* Feld 60 - Ort der Bank
  rs_export-bnkort = abap_off.
* Feld 61 - Weisungscode
  rs_export-wsgkey = abap_off.
* Feld 62 - Text
  rs_export-kvkey = abap_off.
* Feld 63 - BIC
  rs_export-biczp = abap_off.
* Feld 64 - BEI
  rs_export-beizp = abap_off.
* Feld 65 - IBAN
  rs_export-iban = abap_off.
* Feld 66 - Anzahl
  rs_export-anzms = abap_off.
* Feld 67 - Straße der Bank
  rs_export-vtrag = abap_off.
* Feld 68 - Ort Unterschrift
  rs_export-osign = abap_off.
* Feld 69 - Datum Unterschrift
  rs_export-dsign = abap_off.
* Feld 70 - Identifier
  rs_export-ident = abap_off.
* Feld 71 - Status Mandat
  rs_export-mstat = abap_off.
* Feld 72 - Ursprungsmandat
  rs_export-mgaen = abap_off.
* Feld 73 - Druckdatum
  rs_export-prdat = abap_off.
* Feld 74 - Druckertyp
  rs_export-vtrag = abap_off.


ENDMETHOD.                    "map_fae_data


*----------------------------------------------------------------------*
* Methode MAP_AUF_DATA
*----------------------------------------------------------------------*
METHOD map_auf_data.

* lokale Datendeklaration
  CONSTANTS: lc_zeiat_1     TYPE bp_zeilart VALUE '1',
             lc_fcode_bmebs TYPE bpdk-fcode VALUE 'BMEBS'.

  DATA: l_belnr TYPE bpdk-belnr,
        l_buzei TYPE bpdj-buzei,
        l_len   TYPE i.

  DATA: ls_bpdk      TYPE bpdk,
        ls_bpdj      LIKE LINE OF it_bpdj,
        ls_bpdz      LIKE LINE OF it_bpdz,
        ls_sst_subvo TYPE ztpa_sst_subvo.

* Importtabellen lesen
  DESCRIBE FIELD l_belnr LENGTH l_len IN CHARACTER MODE.
  l_belnr = is_data-aufkz(l_len).
  l_buzei = is_data-aufkz+l_len.

  SELECT SINGLE * FROM bpdk INTO ls_bpdk
                 WHERE belnr EQ l_belnr.

  READ TABLE: it_bpdj INTO ls_bpdj WITH KEY belnr = l_belnr
                                            buzei = l_buzei,
              it_bpdz INTO ls_bpdz WITH KEY belnr = l_belnr
                                            buzei = l_buzei.

* Feld 1 - Buchungstyp
  rs_export-btyp = iv_btyp.
* Feld 2 - Merkmal
  rs_export-merkm = abap_off.
* Feld 3 - Firma
  rs_export-firma = abap_off.
* Feld 4 - HHJ
  rs_export-hhj = is_data-gjahr.
* Feld 5 - Quelle
  rs_export-quelle = abap_off.
* Feld 6 - Belegnummer
  rs_export-belnr = is_data-refbn+2(8).
* Feld 7 - Belegposition
  rs_export-blpos = c_count.
* Feld 8 - Userkennzeichen
  rs_export-kerfas = c_usrkz.
* Feld 9 - Bereich
  rs_export-berei = is_data-fipex(2).
* Feld 10 - Kapitel
  rs_export-kapit = is_data-fipex+2(4).
* Feld 11 - Titel
  CONCATENATE is_data-fipex+6(3) is_data-fipex+9(2)
         INTO rs_export-titel SEPARATED BY abap_off.
* Feld 12 - Org.einheit
  rs_export-orgeh = is_data-fistl(8).
* Feld 13 - Unterkonto
  IF is_data-fipex+11(6) IS INITIAL.
    rs_export-unkto = c_unkto_00.
  ELSE.
    rs_export-unkto = is_data-fipex+11(6).
  ENDIF.
* Feld 14 - Referenznummer
  rs_export-refnr = abap_off.
* Feld 15 - Betrag
  IF ls_bpdj-wrttp EQ c_wrttp_43.
    rs_export-betr1 = is_data-brtwr_sap.
    REPLACE ALL OCCURRENCES OF: c_colon IN rs_export-betr1 WITH space,
                                c_point IN rs_export-betr1 WITH space,
                                c_minus IN rs_export-betr1 WITH space.
    CONDENSE rs_export-betr1 NO-GAPS.
  ENDIF.
* Feld 16 - Betrag (nur für 'VE' und HH-Jahr + 1)
  IF ls_bpdj-wrttp EQ c_wrttp_70.
    rs_export-betr2 = is_data-brtwr_sap.
    REPLACE ALL OCCURRENCES OF: c_colon IN rs_export-betr2 WITH space,
                                c_point IN rs_export-betr2 WITH space,
                                c_minus IN rs_export-betr2 WITH space.
    CONDENSE rs_export-betr2 NO-GAPS.
  ENDIF.
* Feld 17 - Fälligkeitsdatum
  rs_export-faedt = abap_off.
* Feld 18 - Betrag (nur für 'VE' und HH-Jahr + 2)
  rs_export-betr3 = abap_off.
* Feld 19 - Textschlüssel
  rs_export-txtsl = abap_off.
* Feld 20 - Betrag (nur für 'VE' und HH-Jahr + 3)
  rs_export-betr4 = abap_off.
* Feld 21 - Be-/Entlastungskennzeichen
  IF ls_bpdz-zeiat EQ lc_zeiat_1.
    IF ls_bpdk-fcode EQ lc_fcode_bmebs.
      rs_export-belkz = c_kz_b.
    ELSE.
      rs_export-belkz = c_kz_e.
    ENDIF.
  ELSE.
    IF ls_bpdk-fcode EQ lc_fcode_bmebs.
      rs_export-belkz = c_kz_e.
    ELSE.
      rs_export-belkz = c_kz_b.
    ENDIF.
  ENDIF.
* Feld 22 - Reserve 1
  rs_export-rese1 = abap_off.
* Feld 23 - Einmallieferant
  rs_export-lifnr = abap_off.
* Feld 24 - Reserve 2
  rs_export-rese2 = abap_off.
* Feld 25 - lfd. Nummer Bankverbindung
  SELECT SINGLE * FROM ztpa_sst_subvo
                  INTO ls_sst_subvo
                 WHERE subvo EQ ls_bpdj-subvo.
  IF sy-subrc IS INITIAL.
    rs_export-bnknr = ls_sst_subvo-keymv.
  ELSE.
    CLEAR rs_export-bnknr.
  ENDIF.
* Feld 26 - Reserve 3
  rs_export-rese3 = abap_off.
* Feld 27 - Kasse
  rs_export-kasse = abap_off.
* Feld 28 - Aktenzeichen
  rs_export-aktkz = abap_off.
* Feld 29 - Begründung
  rs_export-grund = abap_off.
* Feld 30 - Begründung
  rs_export-buchn = abap_off.
* Feld 31 - Währung
  rs_export-lfdnr = abap_off.
* Feld 32 - Belegkassenzeichen
  rs_export-kassz = abap_off.
* Feld 33 - Status der Übernahme
  rs_export-bnstat = c_bnstat_0.
* Feld 34 - Übernahme-User
  rs_export-bnuser = abap_off.
* Feld 35 - Übernahmedatum
  rs_export-bndat = abap_off.
* Feld 36 - Übernahmezeit
  rs_export-bnzeit = abap_off.
* Feld 37 - DHB-Fehlercode
  rs_export-bnerr = abap_off.
* Feld 38 - Leerfeld
  rs_export-rese4 = abap_off.
* Feld 39 - Leerfeld
  rs_export-rese5 = abap_off.
* Feld 40 - Zahlstelle
  rs_export-zhlst = abap_off.
* Feld 41 - Referenzbelgnummer
  rs_export-xblnr = abap_off.
* Feld 42 - Betrag (nur für 'VE' und HH-Jahr + 4)
  rs_export-rese6 = abap_off.
* Feld 43 - Betrag (nur für 'VE' und HH-Jahr + 5)
  rs_export-rese7 = abap_off.
* Feld 44 - leer
  rs_export-dnstl = abap_off.
* Feld 45 - leer
  rs_export-ftext = abap_off.
* Feld 46 - leer
  rs_export-name2 = abap_off.
* Feld 47 - leer
  rs_export-buchz = abap_off.
* Feld 48 - leer
  rs_export-vehhj = abap_off.
* Feld 49 - Dienststelle
  rs_export-dstnr = c_dstnr_3101.
* Feld 50 - Verfahrenskennzeichen
  rs_export-verkz = c_verkz_sap.
* Feld 51 - Länderschlüssel
  rs_export-land1 = abap_off.
* Feld 52 - Postleitzahl
  rs_export-pstlz = abap_off.
* Feld 53 - Betrag
  rs_export-fbetr = abap_off.
* Feld 54 - Umrechnungskurs
  rs_export-kursf = abap_off.
* Feld 55 - Gesamtbetrag
  rs_export-gbbtr = abap_off.
* Feld 56 - Währung
  rs_export-pstlz = abap_off.
* Feld 57 - Bankname 1
  rs_export-bnknm1 = abap_off.
* Feld 58 - Bankname 2
  rs_export-bnknm2 = abap_off.
* Feld 59 - Straße der Bank
  rs_export-bnkstr = abap_off.
* Feld 60 - Ort der Bank
  rs_export-bnkort = abap_off.
* Feld 61 - Weisungscode
  rs_export-wsgkey = abap_off.
* Feld 62 - Text
  rs_export-kvkey = abap_off.
* Feld 63 - BIC
  rs_export-biczp = abap_off.
* Feld 64 - BEI
  rs_export-beizp = abap_off.
* Feld 65 - IBAN
  rs_export-iban = abap_off.
* Feld 66 - Anzahl
  rs_export-anzms = abap_off.
* Feld 67 - Straße der Bank
  rs_export-vtrag = abap_off.
* Feld 68 - Ort Unterschrift
  rs_export-osign = abap_off.
* Feld 69 - Datum Unterschrift
  rs_export-dsign = abap_off.
* Feld 70 - Identifier
  rs_export-ident = abap_off.
* Feld 71 - Status Mandat
  rs_export-mstat = abap_off.
* Feld 72 - Ursprungsmandat
  rs_export-mgaen = abap_off.
* Feld 73 - Druckdatum
  rs_export-prdat = abap_off.
* Feld 74 - Druckertyp
  rs_export-vtrag = abap_off.

ENDMETHOD.                    "map_auf_data


*----------------------------------------------------------------------*
* Methode MAP_SST_DATA
*----------------------------------------------------------------------*
METHOD map_sst_data.

* lokale Datendeklaration
  CONSTANTS: lc_index_1    TYPE i VALUE 1,
             lc_value_4    TYPE i VALUE 4,
             lc_len_1      TYPE i VALUE 1,
             lc_len_10     TYPE i VALUE 10,
             lc_offset_1   TYPE i VALUE 1,
             lc_offset_12  TYPE i VALUE 12,
             lc_merkm_s    TYPE c LENGTH 1 VALUE 'S',
             lc_merkm_a    TYPE c LENGTH 1 VALUE 'A',
             lc_land_de    TYPE land1 VALUE 'DE',
             lc_blart_ae   TYPE blart VALUE 'AE',
             lc_pseudo_p   TYPE string VALUE '95  99999 D',
             lc_kasse_4    TYPE c LENGTH 1 VALUE '4',
             lc_zlsch_m    TYPE pso02-zlsch VALUE 'M',
             lc_loevm_init TYPE knb1-loevm VALUE IS INITIAL,
             lc_init_c18   TYPE c LENGTH 18 VALUE IS INITIAL,
             lc_par_glinr  TYPE zlsa_parameter-z_key VALUE 'GLINR',
             lc_bvafr_2    TYPE c LENGTH 1 VALUE '2'.

  DATA: l_field_c10 TYPE c LENGTH 10,
        l_len       TYPE i.

  DATA: ls_pso02  LIKE LINE OF it_pso02,
        ls_pssec  LIKE LINE OF it_pssec,
        ls_iban   TYPE tiban,
        ls_bnka   TYPE bnka,
        ls_t500p  TYPE t500p,
        ls_p0002  TYPE p0002.

  DATA: ls_laenderkz  TYPE zfin_laenderkz,
        ls_cpd_gbdat  TYPE zpsm_cpd_gbdat,
        ls_pcharge_md TYPE ztpa_pcharge_md,
        ls_parameter  TYPE zlsa_parameter.

* Importtabellen lesen
  READ TABLE: it_pso02 INTO ls_pso02 INDEX lc_index_1,
              it_pssec INTO ls_pssec INDEX lc_index_1.

* Daten zu IBAN und SWIFT ermitteln
  IF NOT ls_pssec-bsec-bankl IS INITIAL.
    get_iban_swift_data( EXPORTING iv_banks  = ls_pssec-bsec-banks
                                   iv_bankl  = ls_pssec-bsec-bankl
                                   iv_bankn  = ls_pssec-bsec-bankn
                                   iv_bkont  = ls_pssec-bsec-bkont
                         IMPORTING es_iban   = ls_iban
                                   es_bnka   = ls_bnka ).
  ENDIF.

* Stammdaten zur Buchung von Gebühren lesen
  IF NOT ls_pso02-kunnr IS INITIAL AND
     NOT ls_pso02-kunnr EQ c_kunnr_cpd.
    SELECT SINGLE * FROM ztpa_pcharge_md INTO ls_pcharge_md
     WHERE pernr EQ ( SELECT pernr FROM knb1
                       WHERE bukrs EQ ls_pso02-bukrs AND
                             kunnr EQ ls_pso02-kunnr ) AND
           kunnr EQ ls_pso02-kunnr AND
           begda LE ls_pso02-budat AND
           endda GE ls_pso02-budat.
  ENDIF.

* Feld 1 - Buchungstyp
  IF is_data-fipex+6(1) LT lc_value_4.
    rs_export-btyp = iv_btyp.
  ELSE.
    rs_export-btyp = c_btyp_ssr.
  ENDIF.
* Feld 2 - Merkmal
  CASE ls_pso02-blart.
    WHEN c_blart_03.
      rs_export-merkm = lc_merkm_s.
    WHEN OTHERS.
      rs_export-merkm = lc_merkm_a.
  ENDCASE.
* Feld 3 - Firma
  rs_export-firma = abap_off.
* Feld 4 - HHJ
  rs_export-hhj = is_data-gjahr.
* Feld 5 - Quelle
  rs_export-quelle = abap_off.
* Feld 6 - Belegnummer
  rs_export-belnr = is_data-refbn+2(8).
* Feld 7 - Belegposition
  rs_export-blpos = c_count.
* Feld 8 - Userkennzeichen
  rs_export-kerfas = c_usrkz.
* Feld 9 - Bereich
  rs_export-berei = is_data-fipex(2).
* Feld 10 - Kapitel
  rs_export-kapit = is_data-fipex+2(4).
* Feld 11 - Titel
  CONCATENATE is_data-fipex+6(3) is_data-fipex+9(2)
         INTO rs_export-titel SEPARATED BY abap_off.
* Feld 12 - Org.einheit
  rs_export-orgeh = is_data-fistl(8).
* Feld 13 - Unterkonto
  IF is_data-fipex+11(6) IS INITIAL.
    rs_export-unkto = c_unkto_00.
  ELSE.
    rs_export-unkto = is_data-fipex+11(6).
  ENDIF.
* Feld 14 - Referenznummer
  rs_export-refnr = abap_off.
* Feld 15 - Betrag
  rs_export-betr1 = is_data-brtwr_sap.
  REPLACE ALL OCCURRENCES OF: c_colon IN rs_export-betr1 WITH space,
                              c_point IN rs_export-betr1 WITH space.
  CONDENSE rs_export-betr1 NO-GAPS.
* Feld 16 - Kombinationsfeld
  CASE ls_pso02-zlsch.
    WHEN 'U' OR 'L' OR 'R' OR 'S'.
      rs_export-betr2+18 = 'E'.
    WHEN 'A' OR 'E' OR 'F'.
      rs_export-betr2+18 = 'D'.
    WHEN 'N' OR 'M'.
      rs_export-betr2+18 = ls_pso02-zlsch.
    WHEN OTHERS.
      rs_export-betr2+18 = 'E'.
  ENDCASE.
  IF rs_export-btyp EQ c_btyp_ssr.
    rs_export-betr2+19 = 'N'.
  ENDIF.
* Feld 17 - Fälligkeitsdatum
  IF ls_pso02-zfbdt IS INITIAL.
    CLEAR rs_export-faedt.
  ELSE.
    rs_export-faedt = ls_pso02-zfbdt.
  ENDIF.
* Feld 18 - Referenz SST
  rs_export-betr3 = abap_off.
* Feld 19 - Art der Forderung (Mahnschlüssel)
  rs_export-txtsl = ls_pso02-maber.
* Feld 20 - Betrag
  rs_export-betr4 = abap_off.
* Feld 21 - Be-/Entlastungskennzeichen
  CASE ls_pso02-blart.
    WHEN lc_blart_ae.
      rs_export-belkz = c_kz_a.
    WHEN OTHERS.
      rs_export-belkz = c_kz_e.
  ENDCASE.
* Feld 22 - Land u. PSTLZ
  IF ls_pssec-bsec-land1 EQ lc_land_de.
    SELECT SINGLE * FROM zfin_laenderkz INTO ls_laenderkz
                   WHERE sapland     EQ ls_pssec-bsec-land1 AND
                         sapbankland EQ ls_pssec-bsec-land1.
    IF sy-subrc IS INITIAL.
      rs_export-rese1(4) = ls_laenderkz-dhbland.
    ELSE.
      rs_export-rese1(4) = ls_pssec-bsec-land1.
    ENDIF.
    IF ls_pssec-bsec-pstlz IS INITIAL.
      rs_export-rese1+4(6) = ls_pssec-bsec-pstl2.
    ELSE.
      rs_export-rese1+4(6) = ls_pssec-bsec-pstlz.
    ENDIF.
  ELSE.
    rs_export-rese1 = lc_pseudo_p.
  ENDIF.

  IF rs_export-btyp EQ c_btyp_ssr.
    rs_export-rese1+10(1) = 'n'.
  ENDIF.
* Feld 23 - Einmallieferant
  rs_export-lifnr = c_lifnr_001.
* Feld 24 - Ort
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    rs_export-rese2 = TEXT-poa.
  ELSE.
    rs_export-rese2 = ls_pssec-bsec-ort01.
  ENDIF.
* Feld 25 - lfd. Nummer Bankverbindung
  rs_export-bnknr = c_bnknr_1.
* Feld 26 - Bankleitzahl und Kontonr.
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    rs_export-rese3 = abap_off.
  ELSE.
    rs_export-rese3(8) = ls_pssec-bsec-bankl.

    IF strlen( ls_pssec-bsec-bankn ) LE lc_len_10.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING  input  = ls_pssec-bsec-bankn
        IMPORTING  output = l_field_c10.

      rs_export-rese3+8(10) = l_field_c10.
    ELSE.
      l_len = strlen( ls_pssec-bsec-bankn ).
      IF NOT l_len IS INITIAL.
        rs_export-rese3+8 = ls_pssec-bsec-bankn(l_len).
      ELSE.
        rs_export-rese3+8 = ls_pssec-bsec-bankn.
      ENDIF.
    ENDIF.
    IF ls_pso02-zlsch EQ 'E'.
      rs_export-rese3+18(1) = 'j'.
    ELSE.
      IF NOT ls_pssec-bsec-bankn IS INITIAL.
        rs_export-rese3+18(1) = 'n'.
      ENDIF.
    ENDIF.
  ENDIF.
* Feld 27 - Kasse
  rs_export-kasse = lc_kasse_4.
* Feld 28 - Aktenzeichen
  rs_export-aktkz = ls_pso02-psofn.
* Feld 29 - Begründung
  rs_export-grund = ls_pso02-sgtxt.
* Feld 30 - Begründung
  rs_export-buchn = abap_off.
* Feld 31 - Währung
  rs_export-lfdnr = abap_off.
* Feld 32 - Belegkassenzeichen
  rs_export-kassz = ls_pso02-xblnr.
* Feld 33 - Status der Übernahme
  rs_export-bnstat = c_bnstat_0.
* Feld 34 - Übernahme-User
  rs_export-bnuser = abap_off.
* Feld 35 - Übernahmedatum
  rs_export-bndat = abap_off.
* Feld 36 - Übernahmezeit
  rs_export-bnzeit = abap_off.
* Feld 37 - DHB-Fehlercode
  rs_export-bnerr = abap_off.
* Feld 38 - Name 1
  SELECT COUNT(*) FROM kna1 UP TO 1 ROWS
                 WHERE kunnr EQ ls_pso02-kunnr AND
                       ktokd EQ c_ktokd_pers.
  IF sy-subrc IS INITIAL.
    SELECT SINGLE * FROM pa0002
      INTO CORRESPONDING FIELDS OF ls_p0002
     WHERE pernr EQ ( SELECT pernr FROM knb1
                       WHERE kunnr EQ ls_pso02-kunnr AND
                             bukrs EQ ls_pso02-bukrs AND
                             loevm EQ lc_loevm_init ) AND
           begda LE ls_pso02-budat AND
           endda GE ls_pso02-budat.
    IF sy-subrc IS INITIAL.
      CONCATENATE ls_p0002-nachn ls_p0002-vorna
             INTO rs_export-rese4 SEPARATED BY c_sep_name.
    ELSE.
      rs_export-rese4 = ls_pssec-bsec-name1.
    ENDIF.
  ELSE.
    rs_export-rese4 = ls_pssec-bsec-name1.
  ENDIF.
* Feld 39 - Strasse
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    CONCATENATE ls_pssec-bsec-land1 ls_pssec-bsec-pstlz
                ls_pssec-bsec-ort01
           INTO rs_export-rese5 SEPARATED BY c_semicolon.
  ELSE.
    rs_export-rese5 = ls_pssec-bsec-stras.
  ENDIF.
* Feld 40 - Zahlstelle
  rs_export-zhlst = abap_off.
* Feld 41 - Urkassenzeichen
  IF rs_export-merkm = lc_merkm_s.
    rs_export-xblnr = ls_pso02-zuonr.
  ELSE.
    rs_export-xblnr = abap_off.
  ENDIF.
* Feld 42 - Begründung
  rs_export-rese6 = ls_pso02-bktxt.
* Feld 43 - Begründung
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    CONCATENATE ls_pssec-bsec-name1 ls_pssec-bsec-land1
                ls_pssec-bsec-pstlz ls_pssec-bsec-ort01
           INTO rs_export-rese7 SEPARATED BY c_semicolon.
  ENDIF.
* Feld 44 - Begründung
  rs_export-dnstl = abap_off.
* Feld 45 - leer
  rs_export-ftext = abap_off.
* Feld 46 - Name 2
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    MOVE ls_pssec-bsec-stras TO rs_export-name2(27).
  ELSE.
    MOVE: ls_pssec-bsec-name2 TO rs_export-name2(27),
          ls_pssec-bsec-name3 TO rs_export-name2+27(27).
  ENDIF.
  IF NOT ls_pssec-bsec-anred IS INITIAL.
    CASE ls_pssec-bsec-anred.
      WHEN 'Herr'.
        rs_export-name2+54(1) = '1'.
      WHEN 'Frau'.
        rs_export-name2+54(1) = '2'.
      WHEN 'Firma'.
        rs_export-name2+54(1) = '3'.
      WHEN 'Herr und Frau'.
        rs_export-name2+54(1) = '4'.
      WHEN 'Eheleute'.
        rs_export-name2+54(1) = '5'.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.
  SELECT SINGLE * FROM zpsm_cpd_gbdat INTO ls_cpd_gbdat
                 WHERE bukrs EQ ls_pso02-bukrs AND
                       zuonr EQ ls_pso02-zuonr.
  IF sy-subrc IS INITIAL.
    MOVE ls_cpd_gbdat-gbdat TO rs_export-name2+55(8).
  ENDIF.
* Feld 47 - leer
  rs_export-buchz = abap_off.
* Feld 48 - leer
  rs_export-vehhj = abap_off.
* Feld 49 - Dienststelle
  rs_export-dstnr = c_dstnr_3101.
* Feld 50 - Verfahrenskennzeichen
  rs_export-verkz = c_verkz_sap.
* Feld 51 - Länderschlüssel
  rs_export-land1 = abap_off.
* Feld 52 - Postleitzahl
  rs_export-pstlz = abap_off.
* Feld 53 - Betrag
  rs_export-fbetr = abap_off.
* Feld 54 - Umrechnungskurs
  rs_export-kursf = abap_off.
* Feld 55 - Gesamtbetrag
  rs_export-gbbtr = abap_off.
* Feld 56 - Währung
  rs_export-pstlz = abap_off.
* Feld 57 - Bankname 1
  rs_export-bnknm1 = abap_off.
* Feld 58 - Bankname 2
  rs_export-bnknm2 = abap_off.
* Feld 59 - Straße der Bank
  rs_export-bnkstr = abap_off.
* Feld 60 - Ort der Bank
  rs_export-bnkort = abap_off.
* Feld 61 - Weisungscode
  rs_export-wsgkey = abap_off.
* Feld 62 - Text
  rs_export-kvkey = abap_off.
* Feld 63 - BIC (SWIFT)
  IF NOT ls_bnka-swift IS INITIAL AND
     NOT ls_iban-iban IS INITIAL  AND
     NOT rs_export-rese3+18(1) EQ 'j'.
    rs_export-biczp = build_bic_key( ls_bnka-swift ).
    MOVE lc_init_c18 TO rs_export-rese3(18).
  ENDIF.
* Feld 64 - BEI
  rs_export-beizp = abap_off.
* Feld 65 - IBAN
  IF NOT ls_iban-iban IS INITIAL  AND
     NOT ls_bnka-swift IS INITIAL AND
     NOT rs_export-rese3+18(1) EQ 'j'.
    rs_export-iban = ls_iban-iban.
    MOVE lc_init_c18 TO rs_export-rese3(18).
  ENDIF.
* Feld 66 - Anzahl
  rs_export-anzms = abap_off.
* Feld 67 - Beschreibung Vertrag
  IF ls_pso02-zlsch EQ lc_zlsch_m AND
    NOT ls_pcharge_md-mndid IS INITIAL.
    rs_export-vtrag = ls_pcharge_md-mndid.
  ELSE.
    rs_export-vtrag = abap_off.
  ENDIF.
* Feld 68 - Ort Unterschrift
  IF ls_pso02-zlsch EQ lc_zlsch_m AND
    NOT ls_pcharge_md-pernr IS INITIAL.
    SELECT SINGLE * FROM t500p INTO ls_t500p
     WHERE persa EQ ( SELECT werks FROM pa0001
                       WHERE pernr EQ ls_pcharge_md-pernr AND
                             begda LE ls_pso02-cpudt      AND
                             endda GE ls_pso02-cpudt ).
    IF sy-subrc IS INITIAL.
      rs_export-osign = ls_t500p-ort01.
    ENDIF.
  ELSEIF ls_pso02-zlsch EQ lc_zlsch_m AND
     NOT ls_pcharge_md-kunnr IS INITIAL.
    SELECT SINGLE * FROM t500p INTO ls_t500p
     WHERE persa EQ ( SELECT begru FROM kna1
                       WHERE kunnr EQ ls_pcharge_md-kunnr ).
    IF sy-subrc IS INITIAL.
      rs_export-osign = ls_t500p-ort01.
    ENDIF.
  ELSE.
    rs_export-osign = abap_off.
  ENDIF.
* Feld 69 - Datum Unterschrift
  IF ls_pso02-zlsch EQ lc_zlsch_m AND
    NOT ls_pcharge_md-mnddt IS INITIAL.
    rs_export-dsign = ls_pcharge_md-mnddt.
  ELSE.
    rs_export-dsign = abap_off.
  ENDIF.
* Feld 70 - Identifier
  IF ls_pso02-zlsch EQ lc_zlsch_m.
    SELECT SINGLE * FROM zlsa_parameter INTO ls_parameter
                   WHERE bukrs EQ ls_pso02-bukrs AND
                         fikrs EQ ref_const->c_fikrs_tpa AND
                         z_key EQ lc_par_glinr.
    IF sy-subrc IS INITIAL.
      rs_export-ident = ls_parameter-z_wert.
    ELSE.
      rs_export-ident = abap_off.
    ENDIF.
  ELSE.
    rs_export-ident = abap_off.
  ENDIF.
* Feld 71 - Status Mandat
  rs_export-mstat = abap_off.
* Feld 72 - Ursprungsmandat
  rs_export-mgaen = abap_off.
* Feld 73 - Druckdatum (gleich Erfassungsdatum)
  IF ls_pso02-zlsch EQ lc_zlsch_m.
    rs_export-prdat = ls_pso02-cpudt.
  ELSE.
    rs_export-prdat = abap_off.
  ENDIF.
* Feld 74 - Nutzer des Drucks
  IF ls_pso02-zlsch EQ lc_zlsch_m.
    rs_export-drusr = c_usrkz.
  ELSE.
    rs_export-drusr = abap_off.
  ENDIF.
* Feld 75 - Mandatsreferenz
  IF ls_pso02-zlsch EQ lc_zlsch_m AND
    NOT ls_pcharge_md-mndid IS INITIAL.
    rs_export-mndid = ls_pcharge_md-mndid.
  ELSE.
    rs_export-mndid = abap_off.
  ENDIF.
* Feld 76 - Steuerungskennzeichen Mandat
  IF ls_pso02-zlsch EQ lc_zlsch_m AND
    NOT ls_pcharge_md-mndid IS INITIAL.
    rs_export-strkz = c_kz_r.
  ELSE.
    rs_export-strkz = abap_off.
  ENDIF.
* Feld 77 - Frist BVA
  IF ls_pso02-zlsch EQ lc_zlsch_m AND
    NOT ls_pcharge_md-mndid IS INITIAL.
    rs_export-bvafr = lc_bvafr_2.
  ELSE.
    rs_export-bvafr = abap_off.
  ENDIF.
* Feld 78 - Mandatgeber Name
  IF ls_pso02-zlsch EQ lc_zlsch_m AND
    NOT ls_pcharge_md-mndid IS INITIAL.
    rs_export-mndnm+lc_offset_1 = ls_pssec-bsec-name1.
  ELSE.
    rs_export-mndnm = abap_off.
  ENDIF.
* Feld 79 - Mandatgeber Ort
  IF ls_pso02-zlsch EQ lc_zlsch_m AND
    NOT ls_pcharge_md-kunnr IS INITIAL.
    CONCATENATE ls_pssec-bsec-land1(lc_len_1)
                ls_pssec-bsec-pstlz
          INTO rs_export-mndort SEPARATED BY space.
    rs_export-mndort+lc_offset_12 = ls_pssec-bsec-ort01.
  ELSE.
    rs_export-mndort = abap_off.
  ENDIF.
* Feld 80 - Mandatgeber Straße
  IF ls_pso02-zlsch EQ lc_zlsch_m AND
    NOT ls_pcharge_md-kunnr IS INITIAL.
    rs_export-mndstr = ls_pssec-bsec-stras.
  ELSE.
    rs_export-mndstr = abap_off.
  ENDIF.
* Feld 81 - Leerfeld
  rs_export-leer81 = abap_off.
* Feld 82 - Mandatgeber Straße
  rs_export-leer82 = abap_off.

ENDMETHOD.                    "map_sst_data


*----------------------------------------------------------------------*
* Methode MAP_SAB_SZU_DATA
*----------------------------------------------------------------------*
METHOD map_sab_szu_data.

* lokale Datendeklaration
  CONSTANTS: lc_index_1    TYPE i VALUE 1,
             lc_merkm_a    TYPE char1 VALUE 'A',
             lc_txtsl_ez   TYPE string VALUE 'EZ',
             lc_wrbtr_init TYPE wrbtr VALUE IS INITIAL.

  DATA: l_ref_wrbtr TYPE wrbtr,
        l_diff_btr  TYPE wrbtr.

  DATA: ls_pso02 LIKE LINE OF it_pso02,
        ls_pssec LIKE LINE OF it_pssec,
        ls_iban  TYPE tiban,
        ls_bnka  TYPE bnka.

* Importtabelle(n) lesen
  READ TABLE: it_pso02 INTO ls_pso02 INDEX lc_index_1,
              it_pssec INTO ls_pssec INDEX lc_index_1.

* Daten zu IBAN und SWIFT ermitteln
  IF NOT ls_pssec-bsec-bankl IS INITIAL.
    get_iban_swift_data( EXPORTING iv_banks  = ls_pssec-bsec-banks
                                   iv_bankl  = ls_pssec-bsec-bankl
                                   iv_bankn  = ls_pssec-bsec-bankn
                                   iv_bkont  = ls_pssec-bsec-bkont
                         IMPORTING es_iban   = ls_iban
                                   es_bnka   = ls_bnka ).
  ENDIF.

* Feld 1 - Buchungstyp
  IF ls_pso02-blart EQ c_blart_21.
    l_ref_wrbtr = read_reference_data( iv_bukrs = ls_pso02-bukrs
                                       iv_belnr = ls_pso02-belnr
                                       iv_gjahr = ls_pso02-gjahr
                                       iv_zuonr = ls_pso02-zuonr
                                       iv_xeowi = iv_xeowi
                                       iv_blart = c_blart_20 ).
    IF l_ref_wrbtr IS INITIAL.
      RETURN.
    ELSE.
      l_diff_btr = ls_pso02-wrbtr - l_ref_wrbtr.
*---- Sollabgang Null
      IF l_diff_btr EQ lc_wrbtr_init.
        rs_export-btyp = c_btyp_sab.
*---- normaler Sollabgang
      ELSEIF l_diff_btr LT lc_wrbtr_init.
        rs_export-btyp = c_btyp_sab.
*---- Sollzugang
      ELSEIF l_diff_btr GT lc_wrbtr_init.
        rs_export-btyp = c_btyp_szu.
      ENDIF.
    ENDIF.
  ELSE.
    rs_export-btyp = iv_btyp.
    l_diff_btr = ls_pso02-wrbtr.
  ENDIF.
* Feld 2 - Merkmal
  rs_export-merkm = lc_merkm_a.
* Feld 3 - Firma
  rs_export-firma = abap_off.
* Feld 4 - HHJ
  rs_export-hhj = is_data-gjahr.
* Feld 5 - Quelle
  rs_export-quelle = abap_off.
* Feld 6 - Belegnummer
  rs_export-belnr = is_data-refbn+2(8).
* Feld 7 - Belegposition
  rs_export-blpos = c_count.
* Feld 8 - Userkennzeichen
  rs_export-kerfas = c_usrkz.
* Feld 9 - Bereich
  rs_export-berei = is_data-fipex(2).
* Feld 10 - Kapitel
  rs_export-kapit = is_data-fipex+2(4).
* Feld 11 - Titel
  CONCATENATE is_data-fipex+6(3) is_data-fipex+9(2)
         INTO rs_export-titel SEPARATED BY abap_off.
* Feld 12 - Org.einheit
  rs_export-orgeh = is_data-fistl(8).
* Feld 13 - Unterkonto
  IF is_data-fipex+11(6) IS INITIAL.
    rs_export-unkto = c_unkto_00.
  ELSE.
    rs_export-unkto = is_data-fipex+11(6).
  ENDIF.
* Feld 14 - Referenznummer
  rs_export-refnr = abap_off.
* Feld 15 - Betrag
  IF l_diff_btr LT lc_wrbtr_init.
    MULTIPLY l_diff_btr BY -1.
  ENDIF.
  rs_export-betr1 = l_diff_btr.
  REPLACE ALL OCCURRENCES OF: c_colon IN rs_export-betr1 WITH space,
                              c_point IN rs_export-betr1 WITH space.
  CONDENSE rs_export-betr1 NO-GAPS.
* Feld 16 - Kombinationsfeld
  rs_export-betr2 = abap_off.
* Feld 17 - Fälligkeitsdatum
  rs_export-faedt = ls_pso02-zfbdt.
* Feld 18 - Abgangsgrund (nur bei 'SAB')
  IF rs_export-btyp EQ c_btyp_sab.
    CASE ls_pso02-blart.
      WHEN c_blart_09.
        rs_export-betr3 = 'E'.
      WHEN c_blart_10.
        rs_export-betr3 = 'F'.
      WHEN c_blart_19.
        rs_export-betr3 = 'UN'.
      WHEN c_blart_21.
        rs_export-betr3 = 'A'.
      WHEN OTHERS.
        rs_export-betr3 = 'A'.
    ENDCASE.
  ELSE.
    rs_export-betr3 = abap_off.
  ENDIF.
* Feld 19 - Zusatzschlüssel
  rs_export-txtsl = lc_txtsl_ez.
* Feld 20 - Betrag
  rs_export-betr4 = abap_off.
* Feld 21 - Zahlart
  IF rs_export-btyp EQ c_btyp_sab.
    IF l_diff_btr EQ lc_wrbtr_init.
      rs_export-belkz = 'R'.
    ELSE.
      rs_export-belkz = 'N'.
    ENDIF.
  ELSE.
    rs_export-belkz = 'A'.
  ENDIF.
* Feld 22 - Land u. PSTLZ
  rs_export-rese1 = abap_off.
* Feld 23 - Einmallieferant
  rs_export-lifnr = abap_off.
* Feld 24 - Ort
  rs_export-rese2 = abap_off.
* Feld 25 - lfd. Nummer Bankverbindung
  rs_export-bnknr = abap_off.
* Feld 26 - Bankleitzahl und Kontonr.
  rs_export-rese3 = abap_off.
* Feld 27 - Kasse
  rs_export-kasse = abap_off.
* Feld 28 - Aktenzeichen
  rs_export-aktkz = ls_pso02-psofn.
* Feld 29 - Begründung
  rs_export-grund = ls_pso02-sgtxt.
* Feld 30 - Begründung
  rs_export-buchn = abap_off.
* Feld 31 - Währung
  rs_export-lfdnr = abap_off.
* Feld 32 - Belegkassenzeichen
  rs_export-kassz = ls_pso02-xblnr.
* Feld 33 - Status der Übernahme
  rs_export-bnstat = c_bnstat_0.
* Feld 34 - Übernahme-User
  rs_export-bnuser = abap_off.
* Feld 35 - Übernahmedatum
  rs_export-bndat = abap_off.
* Feld 36 - Übernahmezeit
  rs_export-bnzeit = abap_off.
* Feld 37 - DHB-Fehlercode
  rs_export-bnerr = abap_off.
* Feld 38 - Name 1
  rs_export-rese4 = abap_off.
* Feld 39 - Strasse
  rs_export-rese5 = abap_off.
* Feld 40 - Zahlstelle
  rs_export-zhlst = abap_off.
* Feld 41 - Urkassenzeichen
  rs_export-xblnr = ls_pso02-zuonr.
* Feld 42 - Begründung
  rs_export-rese6 = ls_pso02-bktxt.
* Feld 43 - Begründung
  rs_export-rese7 = abap_off.
* Feld 44 - Begründung
  rs_export-dnstl = abap_off.
* Feld 45 - leer
  rs_export-ftext = abap_off.
* Feld 46 - Name 2
  rs_export-name2 = abap_off.
* Feld 47 - leer
  rs_export-buchz = abap_off.
* Feld 48 - leer
  rs_export-vehhj = abap_off.
* Feld 49 - Dienststelle
  rs_export-dstnr = c_dstnr_3101.
* Feld 50 - Verfahrenskennzeichen
  rs_export-verkz = c_verkz_sap.
* Feld 51 - Länderschlüssel
  rs_export-land1 = abap_off.
* Feld 52 - Postleitzahl
  rs_export-pstlz = abap_off.
* Feld 53 - Betrag
  rs_export-fbetr = abap_off.
* Feld 54 - Umrechnungskurs
  rs_export-kursf = abap_off.
* Feld 55 - Gesamtbetrag
  rs_export-gbbtr = abap_off.
* Feld 56 - Währung
  rs_export-gwaer = abap_off.
* Feld 57 - Bankname 1
  rs_export-bnknm1 = abap_off.
* Feld 58 - Bankname 2
  rs_export-bnknm2 = abap_off.
* Feld 59 - Straße der Bank
  rs_export-bnkstr = abap_off.
* Feld 60 - Ort der Bank
  rs_export-bnkort = abap_off.
* Feld 61 - Weisungscode
  rs_export-wsgkey = abap_off.
* Feld 62 - Text
  rs_export-kvkey = abap_off.
* Feld 63 - BIC (SWIFT)
  IF NOT ls_bnka-swift IS INITIAL AND
     NOT ls_iban-iban IS INITIAL  AND
     rs_export-btyp EQ c_btyp_sab.
    rs_export-biczp = build_bic_key( ls_bnka-swift ).
  ENDIF.
* Feld 64 - BEI
  rs_export-beizp = abap_off.
* Feld 65 - IBAN
  IF NOT ls_iban-iban IS INITIAL  AND
     NOT ls_bnka-swift IS INITIAL AND
     rs_export-btyp EQ c_btyp_sab.
    rs_export-iban = ls_iban-iban.
  ENDIF.
* Feld 66 - Anzahl
  rs_export-anzms = abap_off.
* Feld 67 - Straße der Bank
  rs_export-vtrag = abap_off.
* Feld 68 - Ort Unterschrift
  rs_export-osign = abap_off.
* Feld 69 - Datum Unterschrift
  rs_export-dsign = abap_off.
* Feld 70 - Identifier
  rs_export-ident = abap_off.
* Feld 71 - Status Mandat
  rs_export-mstat = abap_off.
* Feld 72 - Ursprungsmandat
  rs_export-mgaen = abap_off.
* Feld 73 - Druckdatum
  rs_export-prdat = abap_off.
* Feld 74 - Druckertyp
  rs_export-vtrag = abap_off.

ENDMETHOD.                    "map_sab_szu_data


*----------------------------------------------------------------------*
* Methode MAP_AES_DATA
*----------------------------------------------------------------------*
METHOD map_aes_data.

* lokale Datendeklaration
  CONSTANTS: lc_index_1    TYPE i VALUE 1,
             lc_len_10     TYPE i VALUE 10,
             lc_merkm_a    TYPE c LENGTH 1 VALUE 'A',
             lc_land_de    TYPE land1 VALUE 'DE',
             lc_percent    TYPE c LENGTH 1 VALUE '%',
             lc_pseudo_p   TYPE string VALUE '95  99999 D',
             lc_loevm_init TYPE knb1-loevm VALUE IS INITIAL,
             lc_init_c18   TYPE c LENGTH 18 VALUE IS INITIAL.

  DATA: l_field_c10 TYPE char10,
        l_ref_wrbtr TYPE wrbtr,
        l_len       TYPE i.

  DATA: ls_pso02  LIKE LINE OF it_pso02,
        ls_pssec  LIKE LINE OF it_pssec,
        ls_iban   TYPE tiban,
        ls_bnka   TYPE bnka,
        ls_p0002  TYPE p0002.

  DATA: ls_laenderkz TYPE zfin_laenderkz,
        ls_cpd_gbdat TYPE zpsm_cpd_gbdat.

* Importtabellen lesen
  READ TABLE: it_pso02  INTO ls_pso02 INDEX lc_index_1,
              it_pssec  INTO ls_pssec INDEX lc_index_1.

* Prüfen, ob es einen zugehörigen 20er-Beleg gibt
  l_ref_wrbtr = read_reference_data( iv_bukrs = ls_pso02-bukrs
                                     iv_belnr = ls_pso02-belnr
                                     iv_gjahr = ls_pso02-gjahr
                                     iv_zuonr = ls_pso02-zuonr
                                     iv_blart = c_blart_20
                                     iv_xeowi = iv_xeowi ).
  IF l_ref_wrbtr IS INITIAL.
    RETURN.
  ENDIF.

* Daten zu IBAN und SWIFT ermitteln
  IF NOT ls_pssec-bsec-bankl IS INITIAL.
    get_iban_swift_data( EXPORTING iv_banks  = ls_pssec-bsec-banks
                                   iv_bankl  = ls_pssec-bsec-bankl
                                   iv_bankn  = ls_pssec-bsec-bankn
                                   iv_bkont  = ls_pssec-bsec-bkont
                         IMPORTING es_iban   = ls_iban
                                   es_bnka   = ls_bnka ).
  ENDIF.

* Feld 1 - Buchungstyp
  rs_export-btyp = iv_btyp.
* Feld 2 - Merkmal
  rs_export-merkm = lc_merkm_a.
* Feld 3 - Firma
  rs_export-firma = abap_off.
* Feld 4 - HHJ
  rs_export-hhj = is_data-gjahr.
* Feld 5 - Quelle
  rs_export-quelle = abap_off.
* Feld 6 - Belegnummer
  rs_export-belnr = is_data-refbn+2(8).
* Feld 7 - Belegposition
  rs_export-blpos = c_count.
* Feld 8 - Userkennzeichen
  rs_export-kerfas = c_usrkz.
* Feld 9 - Bereich
  rs_export-berei = is_data-fipex(2).
* Feld 10 - Kapitel
  rs_export-kapit = is_data-fipex+2(4).
* Feld 11 - Titel
  CONCATENATE is_data-fipex+6(3) is_data-fipex+9(2)
         INTO rs_export-titel SEPARATED BY abap_off.
* Feld 12 - Org.einheit
  rs_export-orgeh = is_data-fistl(8).
* Feld 13 - Unterkonto
  IF is_data-fipex+11(6) IS INITIAL.
    rs_export-unkto = c_unkto_00.
  ELSE.
    rs_export-unkto = is_data-fipex+11(6).
  ENDIF.
* Feld 14 - Referenznummer
  rs_export-refnr = abap_off.
* Feld 15 - Betrag
  rs_export-betr1 = abap_off.
* Feld 16 - Kombinationsfeld
  rs_export-betr2+9(1) = 'n'.
  CASE ls_pso02-zlsch.
    WHEN 'U' OR 'L' OR 'M' OR 'R' OR 'S'.
      rs_export-betr2+18 = 'E'.
    WHEN 'A' OR 'E' OR 'F'.
      rs_export-betr2+18 = 'D'.
    WHEN 'N' .
      rs_export-betr2+18 = 'N'.
    WHEN OTHERS.
      rs_export-betr2+18 = 'E'.
  ENDCASE.
* Feld 17 - Fälligkeitsdatum
  rs_export-faedt = ls_pso02-zfbdt.
* Feld 18 - Referenz
  rs_export-betr3 = abap_off.
* Feld 19 - Art der Forderung (Mahnschlüssel)
  rs_export-txtsl = ls_pso02-maber.
* Feld 20 - Betrag
  rs_export-betr4 = abap_off.
* Feld 21 - Be-/Entlastungskennzeichen
  rs_export-belkz = abap_off.
* Feld 22 - Land u. PSTLZ
  IF ls_pssec-bsec-land1 EQ lc_land_de.
    SELECT SINGLE * FROM zfin_laenderkz INTO ls_laenderkz
                   WHERE sapland     EQ ls_pssec-bsec-land1 AND
                         sapbankland EQ ls_pssec-bsec-land1.
    IF sy-subrc IS INITIAL.
      rs_export-rese1(4) = ls_laenderkz-dhbland.
    ELSE.
      rs_export-rese1(4) = ls_pssec-bsec-land1.
    ENDIF.
    IF ls_pssec-bsec-pstlz IS INITIAL.
      rs_export-rese1+4(6) = ls_pssec-bsec-pstl2.
    ELSE.
      rs_export-rese1+4(6) = ls_pssec-bsec-pstlz.
    ENDIF.
  ELSE.
    rs_export-rese1 = lc_pseudo_p.
  ENDIF.
* Feld 23 - Einmallieferant
  rs_export-lifnr = c_lifnr_001.
* Feld 24 - Ort
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    rs_export-rese2 = TEXT-poa.
  ELSE.
    rs_export-rese2 = ls_pssec-bsec-ort01.
  ENDIF.
* Feld 25 - lfd. Nummer Bankverbindung
  rs_export-bnknr = c_bnknr_1.
* Feld 26 - Bankleitzahl und Kontonr.
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    rs_export-rese3 = abap_off.
  ELSE.
    rs_export-rese3(8) = ls_pssec-bsec-bankl.
    IF strlen( ls_pssec-bsec-bankn ) LE lc_len_10.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING  input  = ls_pssec-bsec-bankn
        IMPORTING  output = l_field_c10.

      rs_export-rese3+8(10) = l_field_c10.
    ELSE.
      l_len = strlen( ls_pssec-bsec-bankn ).
      IF NOT l_len IS INITIAL.
        rs_export-rese3+8 = ls_pssec-bsec-bankn(l_len).
      ELSE.
        rs_export-rese3+8 = ls_pssec-bsec-bankn.
      ENDIF.
    ENDIF.
    IF ls_pso02-zlsch EQ 'E'.
      rs_export-rese3+18(1) = 'j'.
    ELSE.
      IF NOT ls_pssec-bsec-bankn IS INITIAL.
        rs_export-rese3+18(1) = 'n'.
      ENDIF.
    ENDIF.
  ENDIF.
* Feld 27 - Kasse
  rs_export-kasse = abap_off.
* Feld 28 - Aktenzeichen
  rs_export-aktkz = ls_pso02-psofn.
* Feld 29 - Begründung
  rs_export-grund = ls_pso02-sgtxt.
* Feld 30 - Begründung
  rs_export-buchn = abap_off.
* Feld 31 - Währung
  rs_export-lfdnr = abap_off.
* Feld 32 - Belegkassenzeichen
  rs_export-kassz = ls_pso02-xblnr.
* Feld 33 - Status der Übernahme
  rs_export-bnstat = c_bnstat_0.
* Feld 34 - Übernahme-User
  rs_export-bnuser = abap_off.
* Feld 35 - Übernahmedatum
  rs_export-bndat = abap_off.
* Feld 36 - Übernahmezeit
  rs_export-bnzeit = abap_off.
* Feld 37 - DHB-Fehlercode
  rs_export-bnerr = abap_off.
* Feld 38 - Name 1
  SELECT COUNT(*) FROM kna1 UP TO 1 ROWS
                 WHERE kunnr EQ ls_pso02-kunnr AND
                       ktokd EQ c_ktokd_pers.
  IF sy-subrc IS INITIAL.
    SELECT SINGLE * FROM pa0002
      INTO CORRESPONDING FIELDS OF ls_p0002
     WHERE pernr EQ ( SELECT pernr FROM knb1
                       WHERE kunnr EQ ls_pso02-kunnr AND
                             bukrs EQ ls_pso02-bukrs AND
                             loevm EQ lc_loevm_init ) AND
           begda LE ls_pso02-budat AND
           endda GE ls_pso02-budat.
    IF sy-subrc IS INITIAL.
      CONCATENATE ls_p0002-nachn ls_p0002-vorna
             INTO rs_export-rese4 SEPARATED BY c_sep_name.
    ELSE.
      rs_export-rese4 = ls_pssec-bsec-name1.
    ENDIF.
  ELSE.
    rs_export-rese4 = ls_pssec-bsec-name1.
  ENDIF.
* Feld 39 - Strasse
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    CONCATENATE ls_pssec-bsec-land1 ls_pssec-bsec-pstlz
                ls_pssec-bsec-ort01
           INTO rs_export-rese5 SEPARATED BY c_semicolon.
  ELSE.
    rs_export-rese5 = ls_pssec-bsec-stras.
  ENDIF.
* Feld 40 - Zahlstelle
  rs_export-zhlst = abap_off.
* Feld 41 - Urkassenzeichen
  rs_export-xblnr = ls_pso02-zuonr.
* Feld 42 - Begründung
  rs_export-rese6 = ls_pso02-bktxt.
* Feld 43 - Begründung
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    CONCATENATE ls_pssec-bsec-name1 ls_pssec-bsec-land1
                ls_pssec-bsec-pstlz ls_pssec-bsec-ort01
           INTO rs_export-rese7 SEPARATED BY c_semicolon.
  ENDIF.
* Feld 44 - Begründung
  rs_export-dnstl = abap_off.
* Feld 45 - leer
  rs_export-ftext = abap_off.
* Feld 46 - Name 2
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    MOVE ls_pssec-bsec-stras TO rs_export-name2(27).
  ELSE.
    IF ls_pssec-bsec-name2 IS INITIAL.
      ls_pssec-bsec-name2 = lc_percent.
    ENDIF.
    IF ls_pssec-bsec-name3 IS INITIAL.
      ls_pssec-bsec-name3 = lc_percent.
    ENDIF.
    MOVE: ls_pssec-bsec-name2 TO rs_export-name2(27),
          ls_pssec-bsec-name3 TO rs_export-name2+27(27).
  ENDIF.
  IF NOT ls_pssec-bsec-anred IS INITIAL.
    CASE ls_pssec-bsec-anred.
      WHEN 'Herr'.
        rs_export-name2+54(1) = '1'.
      WHEN 'Frau'.
        rs_export-name2+54(1) = '2'.
      WHEN 'Firma'.
        rs_export-name2+54(1) = '3'.
      WHEN 'Herr und Frau'.
        rs_export-name2+54(1) = '4'.
      WHEN 'Eheleute'.
        rs_export-name2+54(1) = '5'.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.
  SELECT SINGLE * FROM zpsm_cpd_gbdat INTO ls_cpd_gbdat
                 WHERE bukrs EQ ls_pso02-bukrs AND
                       zuonr EQ ls_pso02-zuonr.
  IF sy-subrc IS INITIAL.
    MOVE ls_cpd_gbdat-gbdat TO rs_export-name2+55(8).
  ENDIF.
* Feld 47 - leer
  rs_export-buchz = abap_off.
* Feld 48 - leer
  rs_export-vehhj = abap_off.
* Feld 49 - Dienststelle
  rs_export-dstnr = c_dstnr_3101.
* Feld 50 - Verfahrenskennzeichen
  rs_export-verkz = c_verkz_sap.
* Feld 51 - Länderschlüssel
  rs_export-land1 = abap_off.
* Feld 52 - Postleitzahl
  rs_export-pstlz = abap_off.
* Feld 53 - Betrag
  rs_export-fbetr = abap_off.
* Feld 54 - Umrechnungskurs
  rs_export-kursf = abap_off.
* Feld 55 - Gesamtbetrag
  rs_export-gbbtr = abap_off.
* Feld 56 - Währung
  rs_export-gwaer = abap_off.
* Feld 57 - Bankname 1
  rs_export-bnknm1 = abap_off.
* Feld 58 - Bankname 2
  rs_export-bnknm2 = abap_off.
* Feld 59 - Straße der Bank
  rs_export-bnkstr = abap_off.
* Feld 60 - Ort der Bank
  rs_export-bnkort = abap_off.
* Feld 61 - Weisungscode
  rs_export-wsgkey = abap_off.
* Feld 62 - Text
  rs_export-kvkey = abap_off.
* Feld 63 - BIC (SWIFT)
  IF NOT ls_bnka-swift IS INITIAL AND
     NOT ls_iban-iban IS INITIAL  AND
     NOT rs_export-rese3+18(1) EQ 'j'.
    rs_export-biczp = build_bic_key( ls_bnka-swift ).
    MOVE lc_init_c18 TO rs_export-rese3(18).
  ENDIF.
* Feld 64 - BEI
  rs_export-beizp = abap_off.
* Feld 65 - IBAN
  IF NOT ls_iban-iban IS INITIAL  AND
     NOT ls_bnka-swift IS INITIAL AND
     NOT rs_export-rese3+18(1) EQ 'j'.
    rs_export-iban = ls_iban-iban.
    MOVE lc_init_c18 TO rs_export-rese3(18).
  ENDIF.
* Feld 66 - Anzahl
  rs_export-anzms = abap_off.
* Feld 67 - Straße der Bank
  rs_export-vtrag = abap_off.
* Feld 68 - Ort Unterschrift
  rs_export-osign = abap_off.
* Feld 69 - Datum Unterschrift
  rs_export-dsign = abap_off.
* Feld 70 - Identifier
  rs_export-ident = abap_off.
* Feld 71 - Status Mandat
  rs_export-mstat = abap_off.
* Feld 72 - Ursprungsmandat
  rs_export-mgaen = abap_off.
* Feld 73 - Druckdatum
  rs_export-prdat = abap_off.
* Feld 74 - Druckertyp
  rs_export-vtrag = abap_off.

ENDMETHOD.                    "map_aes_data


*----------------------------------------------------------------------*
* Methode MAP_STU_DATA
*----------------------------------------------------------------------*
METHOD map_stu_data.

* lokale Datendeklaration
  CONSTANTS: lc_index_1      TYPE i VALUE 1,
             lc_index_2      TYPE i VALUE 2,
             lc_merkm_a      TYPE char1 VALUE 'A',
             lc_intform_init TYPE fm_intform VALUE IS INITIAL.

  DATA: l_zfbdt_1 TYPE dzfbdt,
        l_zfbdt_2 TYPE dzfbdt,
        l_days    TYPE tfmatage,
        l_month   TYPE tfmatage.

  DATA: ls_pso02  LIKE LINE OF it_pso02,
        ls_pso02s LIKE LINE OF it_pso02s.

  DATA: ls_pso02_tmp TYPE pso02.

* Importtabellen lesen
  READ TABLE: it_pso02  INTO ls_pso02 INDEX lc_index_1,
              it_pso02s INTO ls_pso02s WITH KEY belnr = ls_pso02-belnr.

* Feld 1 - Buchungstyp
  rs_export-btyp = iv_btyp.
* Feld 2 - Merkmal
  rs_export-merkm = lc_merkm_a.
* Feld 3 - Firma
  rs_export-firma = abap_off.
* Feld 4 - HHJ
  rs_export-hhj = is_data-gjahr.
* Feld 5 - Quelle
  rs_export-quelle = abap_off.
* Feld 6 - Belegnummer
  rs_export-belnr = is_data-refbn+2(8).
* Feld 7 - Belegposition
  rs_export-blpos = c_count.
* Feld 8 - Userkennzeichen
  rs_export-kerfas = c_usrkz.
* Feld 9 - Bereich
  rs_export-berei = is_data-fipex(2).
* Feld 10 - Kapitel
  rs_export-kapit = is_data-fipex+2(4).
* Feld 11 - Titel
  CONCATENATE is_data-fipex+6(3) is_data-fipex+9(2)
         INTO rs_export-titel SEPARATED BY abap_off.
* Feld 12 - Org.einheit
  rs_export-orgeh = is_data-fistl(8).
* Feld 13 - Unterkonto
  IF is_data-fipex+11(6) IS INITIAL.
    rs_export-unkto = c_unkto_00.
  ELSE.
    rs_export-unkto = is_data-fipex+11(6).
  ENDIF.
* Feld 14 - Referenznummer
  rs_export-refnr = abap_off.
* Feld 15 - Betrag (sofern nur eine Pos.zeile wird der PSO02-WRBTR
* übergeben, andernfalls der PSO02S-WRBTR)
  IF lines( it_pso02s ) EQ lc_index_1.
    rs_export-betr1 = ls_pso02-wrbtr.
  ELSE.
    rs_export-betr1 = ls_pso02s-wrbtr.
  ENDIF.
  REPLACE ALL OCCURRENCES OF: c_colon IN rs_export-betr1 WITH space,
                              c_point IN rs_export-betr1 WITH space.
  CONDENSE rs_export-betr1 NO-GAPS.
* Feld 16 - Kombinationsfeld
  rs_export-betr2 = abap_off.
* Feld 17 - Fälligkeitsdatum
  rs_export-faedt = ls_pso02-budat.
* Feld 18 - Zinsschlüssel
  LOOP AT it_pso02 INTO ls_pso02_tmp
                  WHERE NOT intform EQ lc_intform_init.
    EXIT.
  ENDLOOP.
  IF NOT ls_pso02_tmp-intform IS INITIAL.
    rs_export-betr3 = ls_pso02_tmp-intform.
  ELSE.
    rs_export-betr3 = '0'.
  ENDIF.
* Feld 19 - Zusatzschlüssel
  IF NOT ls_pso02-psosg IS INITIAL.
    CASE ls_pso02-blart.
      WHEN c_blart_07.
        rs_export-txtsl = 'W'.
      WHEN c_blart_18 OR c_blart_un.
        rs_export-txtsl = 'WN'.
    ENDCASE.
  ELSE.
    CASE ls_pso02-blart.
      WHEN c_blart_07.
        IF lines( it_pso02s ) EQ lc_index_1.
          rs_export-txtsl = 'S'.
        ELSE.
          rs_export-txtsl = 'R'.
        ENDIF.
      WHEN c_blart_18.
        rs_export-txtsl = 'N'.
      WHEN c_blart_un.
        rs_export-txtsl = 'U'.
    ENDCASE.
  ENDIF.
* Feld 20 - Fälligkeit der Rate(n);
* wenn Feld '19' = 'R' ---> Fälligkeit erste Rate
* wenn Feld '19' = 'S' oder 'N' ---> Fälligkeit letzte Rate (ZFBDT) ab
* der 9.Stelle bis 16. Stelle
  CASE rs_export-txtsl.
    WHEN 'R'.
      rs_export-betr4 = ls_pso02-zfbdt.
    WHEN 'S' OR 'N'.
      rs_export-betr4+8(8) = ls_pso02-zfbdt.
    WHEN OTHERS.
      rs_export-betr4 = abap_off.
  ENDCASE.
* Feld 21 - Zahlungsrythmus; nur wenn Feld '19' = 'R'
*   '1' --> Jährlich
*   '2' --> Halbjährlich
*   '3' --> Vierteljährlich
*   '4' --> zweimonatlich
*   '5' --> monatlich
  IF rs_export-txtsl EQ 'R'.
    DO lc_index_2 TIMES.
      READ TABLE it_pso02 INTO ls_pso02 INDEX sy-index
                          TRANSPORTING zfbdt.
      CASE sy-index.
        WHEN lc_index_1.
          l_zfbdt_1 = ls_pso02-zfbdt.
        WHEN lc_index_2.
          l_zfbdt_2 = ls_pso02-zfbdt.
      ENDCASE.
    ENDDO.
    CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
      EXPORTING i_date_from = l_zfbdt_1
                i_date_to   = l_zfbdt_2
      IMPORTING e_days      = l_days
                e_months    = l_month.

    CASE l_month.
      WHEN '12' OR '13'.
        rs_export-belkz = '1'.
      WHEN '6' OR '7'.
        rs_export-belkz = '2'.
      WHEN '3' OR '4'.
        IF l_days LT '70'.
          rs_export-belkz = '4'.
        ELSE.
          rs_export-belkz = '3'.
        ENDIF.
      WHEN '2'.
        IF l_days LT '40'.
          rs_export-belkz = '5'.
        ELSE.
          rs_export-belkz = '4'.
        ENDIF.
      WHEN '1'.
        rs_export-belkz = '5'.
      WHEN OTHERS.
        rs_export-belkz = abap_off.
    ENDCASE.
  ENDIF.
* Feld 22 - Reserve 1
  rs_export-rese1 = abap_off.
* Feld 23 - Einmallieferant
  rs_export-lifnr = abap_off.
* Feld 24 - Ort
  rs_export-rese2 = abap_off.
* Feld 25 - lfd. Nummer Bankverbindung
  rs_export-bnknr = abap_off.
* Feld 26 - Bankleitzahl und Kontonr.
  rs_export-rese3 = abap_off.
* Feld 27 - Kasse
  rs_export-kasse = abap_off.
* Feld 28 - Aktenzeichen
  rs_export-aktkz = ls_pso02-psofn.
* Feld 29 - Begründung
  rs_export-grund = ls_pso02-sgtxt.
* Feld 30 - Begründung
  rs_export-buchn = abap_off.
* Feld 31 - Währung
  rs_export-lfdnr = abap_off.
* Feld 32 - Belegkassenzeichen
  rs_export-kassz = ls_pso02-xblnr.
* Feld 33 - Status der Übernahme
  rs_export-bnstat = c_bnstat_0.
* Feld 34 - Übernahme-User
  rs_export-bnuser = abap_off.
* Feld 35 - Übernahmedatum
  rs_export-bndat = abap_off.
* Feld 36 - Übernahmezeit
  rs_export-bnzeit = abap_off.
* Feld 37 - DHB-Fehlercode
  rs_export-bnerr = abap_off.
* Feld 38 - Name 1
  rs_export-rese4 = abap_off.
* Feld 39 - Strasse
  rs_export-rese5 = abap_off.
* Feld 40 - Zahlstelle
  rs_export-zhlst = abap_off.
* Feld 41 - Urkassenzeichen
    rs_export-xblnr = ls_pso02-zuonr.
* Feld 42 - Begründung
    rs_export-rese6 = ls_pso02-bktxt.
* Feld 43 - Begründung
    rs_export-rese7 = abap_off.
* Feld 44 - Begründung
    rs_export-dnstl = abap_off.
* Feld 45 - leer
    rs_export-ftext = abap_off.
* Feld 46 - Name 2
    rs_export-name2 = abap_off.
* Feld 47 - leer
    rs_export-buchz = abap_off.
* Feld 48 - leer
    rs_export-vehhj = abap_off.
* Feld 49 - Dienststelle
    rs_export-dstnr = c_dstnr_3101.
* Feld 50 - Verfahrenskennzeichen
    rs_export-verkz = c_verkz_sap.
* Feld 51 - Länderschlüssel
    rs_export-land1 = abap_off.
* Feld 52 - Postleitzahl
    rs_export-pstlz = abap_off.
* Feld 53 - Betrag
    rs_export-fbetr = abap_off.
* Feld 54 - Umrechnungskurs
    rs_export-kursf = abap_off.
* Feld 55 - Gesamtbetrag
    rs_export-gbbtr = abap_off.
* Feld 56 - Währung
    rs_export-gwaer = abap_off.
* Feld 57 - Bankname 1
    rs_export-bnknm1 = abap_off.
* Feld 58 - Bankname 2
    rs_export-bnknm2 = abap_off.
* Feld 59 - Straße der Bank
    rs_export-bnkstr = abap_off.
* Feld 60 - Ort der Bank
    rs_export-bnkort = abap_off.
* Feld 61 - Weisungscode
  rs_export-wsgkey = abap_off.
* Feld 62 - Text
  rs_export-kvkey = abap_off.
* Feld 63 - BIC
  rs_export-biczp = abap_off.
* Feld 64 - BEI
  rs_export-beizp = abap_off.
* Feld 65 - IBAN
  rs_export-iban = abap_off.
* Feld 66 - Anzahl
  rs_export-anzms = abap_off.
* Feld 67 - Straße der Bank
  rs_export-vtrag = abap_off.
* Feld 68 - Ort Unterschrift
  rs_export-osign = abap_off.
* Feld 69 - Datum Unterschrift
  rs_export-dsign = abap_off.
* Feld 70 - Identifier
  rs_export-ident = abap_off.
* Feld 71 - Status Mandat
  rs_export-mstat = abap_off.
* Feld 72 - Ursprungsmandat
  rs_export-mgaen = abap_off.
* Feld 73 - Druckdatum
  rs_export-prdat = abap_off.
* Feld 74 - Druckertyp
  rs_export-vtrag = abap_off.

ENDMETHOD.                    "map_stu_data


*----------------------------------------------------------------------*
* Methode MAP_APU_EPU_DATA
*----------------------------------------------------------------------*
METHOD map_apu_epu_data.

* lokale Datendeklaration
  CONSTANTS: lc_index_1   TYPE i VALUE 1,
             lc_shkzg_s   TYPE shkzg VALUE 'S',
             lc_shkzg_h   TYPE shkzg VALUE 'H',
             lc_lifnr_002 TYPE string VALUE '002',
             lc_value_4   TYPE i VALUE 4,
             lc_kasse_4   TYPE char1 VALUE '4',
             lc_merkm_a   TYPE char1 VALUE 'A'.

  DATA: ls_pso02    LIKE LINE OF it_pso02,
        ls_pso02s_s LIKE LINE OF it_pso02s,
        ls_pso02s_e LIKE LINE OF it_pso02s.

* Importtabellen lesen
  READ TABLE it_pso02 INTO ls_pso02 INDEX lc_index_1.

* Feld 1 - Buchungstyp
  IF is_data-fipex+6(1) GE lc_value_4.
    rs_export-btyp = iv_btyp.
    READ TABLE: it_pso02s INTO ls_pso02s_s WITH KEY shkzg = lc_shkzg_s,
                it_pso02s INTO ls_pso02s_e WITH KEY shkzg = lc_shkzg_h.
  ELSE.
    rs_export-btyp = c_btyp_epu.
    READ TABLE: it_pso02s INTO ls_pso02s_s WITH KEY shkzg = lc_shkzg_h,
                it_pso02s INTO ls_pso02s_e WITH KEY shkzg = lc_shkzg_s.
  ENDIF.
* Feld 2 - Merkmal
  rs_export-merkm = lc_merkm_a.
* Feld 3 - Firma
  rs_export-firma = abap_off.
* Feld 4 - HHJ
  rs_export-hhj = is_data-gjahr.
* Feld 5 - Quelle
  rs_export-quelle = abap_off.
* Feld 6 - Belegnummer
  rs_export-belnr = is_data-refbn+2(8).
* Feld 7 - Belegposition
  rs_export-blpos = c_count.
* Feld 8 - Userkennzeichen
  rs_export-kerfas = c_usrkz.
* Feld 9 - Bereich
  rs_export-berei = ls_pso02s_s-fipex(2).
* Feld 10 - Kapitel
  rs_export-kapit = ls_pso02s_s-fipex+2(4).
* Feld 11 - Titel
  CONCATENATE ls_pso02s_s-fipex+6(3) ls_pso02s_s-fipex+9(2)
         INTO rs_export-titel SEPARATED BY abap_off.
* Feld 12 - Org.einheit
  rs_export-orgeh = ls_pso02s_s-fistl(8).
* Feld 13 - Unterkonto
  IF ls_pso02s_s-fipex+11(6) IS INITIAL.
    rs_export-unkto = c_unkto_00.
  ELSE.
    rs_export-unkto = ls_pso02s_s-fipex+11(6).
  ENDIF.
* Feld 14 - Referenznummer
  rs_export-refnr = abap_off.
* Feld 15 - Betrag
  rs_export-betr1 = ls_pso02s_s-wrbtr.
  REPLACE ALL OCCURRENCES OF: c_colon IN rs_export-betr1 WITH space,
                              c_point IN rs_export-betr1 WITH space.
  CONDENSE rs_export-betr1 NO-GAPS.
* Feld 16 - Kombinationsfeld
  rs_export-betr2 = abap_off.
* Feld 17 - Fälligkeitsdatum
  rs_export-faedt = abap_off.
* Feld 18 - Zinsschlüssel
  rs_export-betr3 = abap_off.
* Feld 19 - Zusatzschlüssel
  rs_export-txtsl = abap_off.
* Feld 20 - Fälligkeit
  rs_export-betr4 = abap_off.
* Feld 21 - Be-/Entlastungskennzeichen
  rs_export-belkz = abap_off.
* Feld 22 - Kombinationsfeld (VON-Buchungsstelle)
  CONCATENATE ls_pso02s_e-fipex(9) ls_pso02s_e-fipex+9(2)
              INTO rs_export-rese1 SEPARATED BY abap_off.
  IF ls_pso02s_e-fipex+11(6) IS INITIAL.
    CONCATENATE rs_export-rese1 c_unkto_00 INTO rs_export-rese1.
  ELSE.
    CONCATENATE rs_export-rese1 ls_pso02s_e-fipex+11(6)
                INTO rs_export-rese1.
  ENDIF.
* Feld 23 - Einmallieferant
  rs_export-lifnr = lc_lifnr_002.
* Feld 24 - VON-Buchungsstelle
  rs_export-rese2 = ls_pso02s_e-fistl.
* Feld 25 - lfd. Nummer Bankverbindung
  rs_export-bnknr = c_bnknr_1.
* Feld 26 - Bankleitzahl und Kontonr.
  rs_export-rese3 = abap_off.
* Feld 27 - Kasse
  rs_export-kasse = lc_kasse_4.
* Feld 28 - Aktenzeichen
  rs_export-aktkz = abap_off.
* Feld 29 - Begründung
  rs_export-grund = abap_off.
* Feld 30 - Begründung
  rs_export-buchn = abap_off.
* Feld 31 - Währung
  rs_export-lfdnr = abap_off.
* Feld 32 - Belegkassenzeichen
  rs_export-kassz = ls_pso02-xblnr.
* Feld 33 - Status der Übernahme
  rs_export-bnstat = c_bnstat_0.
* Feld 34 - Übernahme-User
  rs_export-bnuser = abap_off.
* Feld 35 - Übernahmedatum
  rs_export-bndat = abap_off.
* Feld 36 - Übernahmezeit
  rs_export-bnzeit = abap_off.
* Feld 37 - DHB-Fehlercode
  rs_export-bnerr = abap_off.
* Feld 38 - Name 1
  rs_export-rese4 = abap_off.
* Feld 39 - Strasse
  rs_export-rese5 = abap_off.
* Feld 40 - Zahlstelle
  rs_export-zhlst = abap_off.
* Feld 41 - Urkassenzeichen
  rs_export-xblnr = abap_off.
* Feld 42 - Begründung
  rs_export-rese6 = ls_pso02-bktxt.
* Feld 43 - Begründung
    rs_export-rese7 = abap_off.
* Feld 44 - Begründung
    rs_export-dnstl = abap_off.
* Feld 45 - leer
    rs_export-ftext = abap_off.
* Feld 46 - Name 2
    rs_export-name2 = abap_off.
* Feld 47 - leer
    rs_export-buchz = abap_off.
* Feld 48 - leer
    rs_export-vehhj = abap_off.
* Feld 49 - Dienststelle
    rs_export-dstnr = c_dstnr_3101.
* Feld 50 - Verfahrenskennzeichen
    rs_export-verkz = c_verkz_sap.
* Feld 51 - Länderschlüssel
    rs_export-land1 = abap_off.
* Feld 52 - Postleitzahl
    rs_export-pstlz = abap_off.
* Feld 53 - Betrag
    rs_export-fbetr = abap_off.
* Feld 54 - Umrechnungskurs
    rs_export-kursf = abap_off.
* Feld 55 - Gesamtbetrag
    rs_export-gbbtr = abap_off.
* Feld 56 - Währung
    rs_export-gwaer = abap_off.
* Feld 57 - Bankname 1
    rs_export-bnknm1 = abap_off.
* Feld 58 - Bankname 2
    rs_export-bnknm2 = abap_off.
* Feld 59 - Straße der Bank
    rs_export-bnkstr = abap_off.
* Feld 60 - Ort der Bank
    rs_export-bnkort = abap_off.
* Feld 61 - Weisungscode
    rs_export-wsgkey = abap_off.
* Feld 62 - Text
    rs_export-kvkey = abap_off.
* Feld 63 - BIC
  rs_export-biczp = abap_off.
* Feld 64 - BEI
  rs_export-beizp = abap_off.
* Feld 65 - IBAN
  rs_export-iban = abap_off.
* Feld 66 - Anzahl
  rs_export-anzms = abap_off.
* Feld 67 - Straße der Bank
  rs_export-vtrag = abap_off.
* Feld 68 - Ort Unterschrift
  rs_export-osign = abap_off.
* Feld 69 - Datum Unterschrift
  rs_export-dsign = abap_off.
* Feld 70 - Identifier
  rs_export-ident = abap_off.
* Feld 71 - Status Mandat
  rs_export-mstat = abap_off.
* Feld 72 - Ursprungsmandat
  rs_export-mgaen = abap_off.
* Feld 73 - Druckdatum
  rs_export-prdat = abap_off.
* Feld 74 - Druckertyp
  rs_export-vtrag = abap_off.

ENDMETHOD.                    "map_apu_epu_data


*----------------------------------------------------------------------*
* Methode MAP_DAO_DATA
*----------------------------------------------------------------------*
METHOD map_dao_data.

* lokale Datendeklaration
  CONSTANTS: lc_index_1    TYPE i VALUE 1,
             lc_value_4    TYPE i VALUE 4,
             lc_len_10     TYPE i VALUE 10,
             lc_merkm_a    TYPE char1 VALUE 'A',
             lc_land_de    TYPE land1 VALUE 'DE',
             lc_percent    TYPE char1 VALUE '%',
             lc_pseudo_p   TYPE string VALUE '95  99999 D',
             lc_kasse_4    TYPE char1 VALUE '4',
             lc_init_c18   TYPE c LENGTH 18 VALUE IS INITIAL.

  CONSTANTS: lc_objcl_dao  TYPE cdobjectcl VALUE 'PSODAUERAO',
             lc_fname_fistl    TYPE fieldname VALUE 'FISTL',
             lc_fname_fipos    TYPE fieldname VALUE 'FIPOS',
             lc_fname_psofn    TYPE fieldname VALUE 'PSOFN',
             lc_fname_dbedt    TYPE fieldname VALUE 'DBEDT',
             lc_fname_zlsch    TYPE fieldname VALUE 'ZLSCH',
             lc_fname_maber    TYPE fieldname VALUE 'MABER',
             lc_fname_bktxt    TYPE fieldname VALUE 'BKTXT',
             lc_fname_name1    TYPE fieldname VALUE 'NAME1',
             lc_fname_name2    TYPE fieldname VALUE 'NAME2',
             lc_fname_name3    TYPE fieldname VALUE 'NAME3',
             lc_fname_stras    TYPE fieldname VALUE 'STRAS',
             lc_fname_pstlz    TYPE fieldname VALUE 'PSTLZ',
             lc_fname_ort01    TYPE fieldname VALUE 'ORT01',
             lc_fname_land1    TYPE fieldname VALUE 'LAND1',
             lc_fname_pstl2    TYPE fieldname VALUE 'PSTL2',
             lc_fname_bankn    TYPE fieldname VALUE 'BANKN',
             lc_fname_bankl    TYPE fieldname VALUE 'BANKL',
             lc_fname_banks    TYPE fieldname VALUE 'BANKS',
             lc_fname_wrbtr    TYPE fieldname VALUE 'WRBTR',
             lc_fname_xdelt    TYPE fieldname VALUE 'XDELT'.

  STATICS: sr_fld_fda TYPE RANGE OF fieldname,
           sr_fld_btr TYPE RANGE OF fieldname,
           sr_fld_del TYPE RANGE OF fieldname.

  DATA: l_field_c10 TYPE char10,
        l_objid     TYPE cdobjectv,
        l_diff_btr  TYPE wrbtr,
        l_len       TYPE i.

  DATA: ls_pso02  LIKE LINE OF it_pso02,
        ls_pssec  LIKE LINE OF it_pssec,
        ls_iban   TYPE tiban,
        ls_bnka   TYPE bnka.

  DATA: lt_cdred     TYPE sa_cdred_t,
        ls_cdred     LIKE LINE OF lt_cdred,
        ls_laenderkz TYPE zfin_laenderkz,
        ls_cpd_gbdat TYPE zpsm_cpd_gbdat,
        ls_dhb_ano   TYPE ts_ano_data.

* Importtabellen lesen
  READ TABLE: it_pso02 INTO ls_pso02 INDEX lc_index_1,
              it_pssec INTO ls_pssec INDEX lc_index_1.

* Änderungen zur Daueranodnung lesen
  CONCATENATE sy-mandt is_data-refbn c_joker INTO l_objid.
  lt_cdred = read_changes( iv_objcl = lc_objcl_dao
                           iv_objid = l_objid ).

* Lesen der Tab. ZSST_SAP_DHB_ANO
  SELECT SINGLE * FROM zsst_sap_dhb_ano INTO ls_dhb_ano
                 WHERE gjahr EQ is_data-gjahr AND
                       refbn EQ is_data-refbn.

* Daten zu IBAN und SWIFT ermitteln
  IF NOT ls_pssec-bsec-bankl IS INITIAL.
    get_iban_swift_data( EXPORTING iv_banks  = ls_pssec-bsec-banks
                                   iv_bankl  = ls_pssec-bsec-bankl
                                   iv_bankn  = ls_pssec-bsec-bankn
                                   iv_bkont  = ls_pssec-bsec-bkont
                         IMPORTING es_iban   = ls_iban
                                   es_bnka   = ls_bnka ).
  ENDIF.

* Ranges für Prüfungen zusammensetzen
  IF lines( sr_fld_fda ) IS INITIAL.
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_fistl
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_fipos
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_psofn
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_dbedt
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_zlsch
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_maber
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_bktxt
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_name1
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_name2
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_name3
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_pstlz
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_stras
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_ort01
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_land1
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_pstl2
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_bankn
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_bankl
                                CHANGING ct_range     = sr_fld_fda ).
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_banks
                                CHANGING ct_range     = sr_fld_fda ).
  ENDIF.
  IF lines( sr_fld_btr ) IS INITIAL.
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_wrbtr
                                CHANGING ct_range     = sr_fld_btr ).
  ENDIF.
  IF lines( sr_fld_del ) IS INITIAL.
    ref_help->set_range_value( EXPORTING iv_value_low = lc_fname_xdelt
                                CHANGING ct_range     = sr_fld_del ).
  ENDIF.


* Feld 1 - Buchungstyp
  IF lines( lt_cdred ) IS INITIAL AND ls_dhb_ano IS INITIAL.
    IF is_data-fipex+6(1) LT lc_value_4.
      rs_export-btyp = c_btyp_sst.
    ELSE.
      rs_export-btyp = c_btyp_ssr.
    ENDIF.
  ELSEIF NOT lines( lt_cdred ) IS INITIAL AND NOT ls_dhb_ano IS INITIAL.
    LOOP AT lt_cdred INTO ls_cdred
                    WHERE fname IN sr_fld_fda.
      EXIT.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
      rs_export-btyp = c_btyp_aes.
    ENDIF.

    LOOP AT lt_cdred INTO ls_cdred
                    WHERE fname IN sr_fld_btr.
      EXIT.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
      IF ls_pso02-wrbtr GT ls_dhb_ano-brtwr_dhb.
        l_diff_btr = ls_pso02-wrbtr - ls_dhb_ano-brtwr_dhb.
        rs_export-btyp = c_btyp_szu.
      ELSEIF ls_pso02-wrbtr LT ls_dhb_ano-brtwr_dhb.
        l_diff_btr = ls_dhb_ano-brtwr_dhb - ls_pso02-wrbtr.
        rs_export-btyp = c_btyp_sab.
      ENDIF.
    ENDIF.

    LOOP AT lt_cdred INTO ls_cdred
                    WHERE fname IN sr_fld_del.
      EXIT.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
      rs_export-btyp = c_btyp_aes.
    ENDIF.
  ENDIF.
* Feld 2 - Merkmal
  rs_export-merkm = lc_merkm_a.
* Feld 3 - Firma
  rs_export-firma = abap_off.
* Feld 4 - HHJ
  rs_export-hhj = is_data-gjahr.
* Feld 5 - Quelle
  rs_export-quelle = abap_off.
* Feld 6 - Belegnummer
  rs_export-belnr = is_data-refbn+2(8).
* Feld 7 - Belegposition
  rs_export-blpos = c_count.
* Feld 8 - Userkennzeichen
  rs_export-kerfas = c_usrkz.
* Feld 9 - Bereich
  rs_export-berei = is_data-fipex(2).
* Feld 10 - Kapitel
  rs_export-kapit = is_data-fipex+2(4).
* Feld 11 - Titel
  CONCATENATE is_data-fipex+6(3) is_data-fipex+9(2)
         INTO rs_export-titel SEPARATED BY abap_off.
* Feld 12 - Org.einheit
  rs_export-orgeh = is_data-fistl(8).
* Feld 13 - Unterkonto
  IF is_data-fipex+11(6) IS INITIAL.
    rs_export-unkto = c_unkto_00.
  ELSE.
    rs_export-unkto = is_data-fipex+11(6).
  ENDIF.
* Feld 14 - Referenznummer
  rs_export-refnr = abap_off.
* Feld 15 - Betrag
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr.
      rs_export-betr1 = is_data-brtwr_sap.
    WHEN c_btyp_aes.
      rs_export-betr1 = abap_off.
    WHEN c_btyp_szu OR c_btyp_sab.
      rs_export-betr1 = l_diff_btr.
  ENDCASE.
  REPLACE ALL OCCURRENCES OF: c_colon IN rs_export-betr1 WITH space,
                              c_point IN rs_export-betr1 WITH space.
  CONDENSE rs_export-betr1 NO-GAPS.
* Feld 16 - Kombinationsfeld
  CASE rs_export-btyp.
    WHEN c_btyp_szu OR c_btyp_sab.
      rs_export-betr2 = abap_off.
    WHEN c_btyp_sst OR c_btyp_ssr.
      CASE ls_pso02-zlsch.
        WHEN 'U' OR 'L' OR 'M' OR 'R' OR 'S'.
          rs_export-betr2+18(1) = 'E'.
        WHEN 'A' OR 'E' OR 'F'.
          rs_export-betr2+18(1) = 'D'.
        WHEN 'N' .
          rs_export-betr2+18(1) = 'N'.
        WHEN OTHERS.
          rs_export-betr2+18(1) = 'E'.
      ENDCASE.
      CASE ls_pso02-dbmon.
        WHEN '01'.
          rs_export-betr2+8(1) = '5'.
        WHEN '02'.
          rs_export-betr2+8(1) = '4'.
        WHEN '03'.
          rs_export-betr2+8(1) = '3'.
        WHEN '06'.
          rs_export-betr2+8(1) = '2'.
        WHEN '12'.
          rs_export-betr2+8(1) = '1'.
      ENDCASE.
      rs_export-betr2+9(1) = 'V'.
      rs_export-betr2+10(8) = ls_pso02-dbedt.

      IF rs_export-btyp EQ c_btyp_ssr.
        rs_export-betr2+19(1) = 'N'.
      ENDIF.
    WHEN c_btyp_aes.
      CASE ls_pso02-zlsch.
        WHEN 'U' OR 'L' OR 'M' OR 'R' OR 'S'.
          rs_export-betr2+18(1) = 'E'.
        WHEN 'A' OR 'E' OR 'F'.
          rs_export-betr2+18(1) = 'D'.
        WHEN 'N' .
          rs_export-betr2+18(1) = 'N'.
        WHEN OTHERS.
          rs_export-betr2+18(1) = 'E'.
      ENDCASE.
      rs_export-betr2+9(1) = 'n'.
  ENDCASE.
* Feld 17 - Fälligkeitsdatum
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr.
      rs_export-faedt = ls_pso02-dbbdt.
    WHEN c_btyp_aes.
      rs_export-faedt = ls_pso02-dbedt.
    WHEN c_btyp_szu OR c_btyp_sab.
      rs_export-faedt = ls_pso02-zfbdt.
  ENDCASE.
* Feld 18 - Referenz SST
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr OR c_btyp_szu OR c_btyp_aes.
      rs_export-betr3 = abap_off.
    WHEN c_btyp_sab.
      rs_export-betr3 = 'A'.
  ENDCASE.
* Feld 19 - Art der Forderung (Mahnschlüssel)
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr.
      rs_export-txtsl = ls_pso02-maber.
    WHEN c_btyp_aes.
      SELECT COUNT(*) FROM ztpa_del_dao UP TO 1 ROWS
                     WHERE lotkz EQ ls_pso02-lotkz.
      IF NOT sy-subrc IS INITIAL.
        rs_export-txtsl = ls_pso02-maber.
      ENDIF.
    WHEN c_btyp_szu OR c_btyp_sab.
      rs_export-txtsl = 'TB'.
  ENDCASE.
* Feld 20 - Betrag
  rs_export-betr4 = abap_off.
* Feld 21 - Be-/Entlastungskennzeichen
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr.
      rs_export-belkz = 'W'.
    WHEN c_btyp_aes.
      rs_export-belkz = abap_off.
    WHEN c_btyp_szu.
      rs_export-belkz = 'A'.
    WHEN c_btyp_sab.
      rs_export-belkz = 'N'.
  ENDCASE.
* Feld 22 - Land u. PSTLZ
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr OR c_btyp_aes.
      IF ls_pssec-bsec-land1 EQ lc_land_de.
        SELECT SINGLE * FROM zfin_laenderkz INTO ls_laenderkz
                       WHERE sapland     EQ ls_pssec-bsec-land1 AND
                             sapbankland EQ ls_pssec-bsec-land1.
        IF sy-subrc IS INITIAL.
          rs_export-rese1(4) = ls_laenderkz-dhbland.
        ELSE.
          rs_export-rese1(4) = ls_pssec-bsec-land1.
        ENDIF.
        IF ls_pssec-bsec-pstlz IS INITIAL.
          rs_export-rese1+4(6) = ls_pssec-bsec-pstl2.
        ELSE.
          rs_export-rese1+4(6) = ls_pssec-bsec-pstlz.
        ENDIF.
      ELSE.
        rs_export-rese1 = lc_pseudo_p.
      ENDIF.
      IF rs_export-btyp EQ c_btyp_ssr.
        rs_export-rese1+10(1) = 'n'.
      ENDIF.
    WHEN c_btyp_szu OR c_btyp_sab.
      rs_export-rese1 = abap_off.
  ENDCASE.
* Feld 23 - Einmallieferant
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr OR c_btyp_aes.
      rs_export-lifnr = c_lifnr_001.
    WHEN c_btyp_szu OR c_btyp_sab.
      rs_export-lifnr = abap_off.
  ENDCASE.
* Feld 24 - Ort
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr OR c_btyp_aes.
      IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
        rs_export-rese2 = TEXT-poa.
      ELSE.
        rs_export-rese2 = ls_pssec-bsec-ort01.
      ENDIF.
    WHEN c_btyp_szu OR c_btyp_sab.
      rs_export-rese2 = abap_off.
  ENDCASE.
* Feld 25 - lfd. Nummer Bankverbindung
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr OR c_btyp_aes.
      rs_export-bnknr = c_bnknr_1.
    WHEN c_btyp_szu OR c_btyp_sab.
      rs_export-bnknr = abap_off.
  ENDCASE.
* Feld 26 - Bankleitzahl und Kontonr.
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr OR c_btyp_aes.
      IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
        rs_export-rese3 = abap_off.
      ELSE.
        rs_export-rese3(8) = ls_pssec-bsec-bankl.
        IF strlen( ls_pssec-bsec-bankn ) LE lc_len_10.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING  input  = ls_pssec-bsec-bankn
            IMPORTING  output = l_field_c10.

          rs_export-rese3+8(10) = l_field_c10.
        ELSE.
          l_len = strlen( ls_pssec-bsec-bankn ).
          IF NOT l_len IS INITIAL.
            rs_export-rese3+8 = ls_pssec-bsec-bankn(l_len).
          ELSE.
            rs_export-rese3+8 = ls_pssec-bsec-bankn.
          ENDIF.
        ENDIF.
        IF ls_pso02-zlsch EQ 'E'.
          rs_export-rese3+18(1) = 'j'.
        ELSE.
          IF NOT ls_pssec-bsec-bankn IS INITIAL.
            rs_export-rese3+18(1) = 'n'.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN c_btyp_szu OR c_btyp_sab.
      rs_export-rese3 = abap_off.
  ENDCASE.
* Feld 27 - Kasse
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr.
      rs_export-kasse = lc_kasse_4.
    WHEN c_btyp_aes OR c_btyp_szu OR c_btyp_sab.
      rs_export-kasse = abap_off.
  ENDCASE.
* Feld 28 - Aktenzeichen
  rs_export-aktkz = ls_pso02-psofn.
* Feld 29 - Begründung
  rs_export-grund = ls_pso02-sgtxt.
* Feld 30 - Begründung
  rs_export-buchn = abap_off.
* Feld 31 - Währung
  rs_export-lfdnr = abap_off.
* Feld 32 - Belegkassenzeichen
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr.
      rs_export-kassz = ls_pso02-xblnr.
    WHEN c_btyp_aes OR c_btyp_szu OR c_btyp_sab.
      rs_export-kassz = ls_pso02-xblnr.
  ENDCASE.
* Feld 33 - Status der Übernahme
  rs_export-bnstat = c_bnstat_0.
* Feld 34 - Übernahme-User
  rs_export-bnuser = abap_off.
* Feld 35 - Übernahmedatum
  rs_export-bndat = abap_off.
* Feld 36 - Übernahmezeit
  rs_export-bnzeit = abap_off.
* Feld 37 - DHB-Fehlercode
  rs_export-bnerr = abap_off.
* Feld 38 - Name 1
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr OR c_btyp_aes.
      rs_export-rese4 = ls_pssec-bsec-name1.
    WHEN c_btyp_szu OR c_btyp_sab.
      rs_export-rese4 = abap_off.
  ENDCASE.
* Feld 39 - Strasse
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr OR c_btyp_aes.
      IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
        CONCATENATE ls_pssec-bsec-land1 ls_pssec-bsec-pstlz
                    ls_pssec-bsec-ort01
               INTO rs_export-rese5 SEPARATED BY c_semicolon.
      ELSE.
        rs_export-rese5 = ls_pssec-bsec-stras.
      ENDIF.
    WHEN c_btyp_szu OR c_btyp_sab.
      rs_export-rese5 = abap_off.
  ENDCASE.
* Feld 40 - Zahlstelle
  rs_export-zhlst = abap_off.
* Feld 41 - Urkassenzeichen
  CASE rs_export-btyp.
    WHEN c_btyp_sab OR c_btyp_szu OR c_btyp_aes.
      rs_export-xblnr = ls_pso02-zuonr.
    WHEN c_btyp_sst OR c_btyp_ssr.
      rs_export-xblnr = abap_off.
  ENDCASE.
* Feld 42 - Begründung
  rs_export-rese6 = ls_pso02-bktxt.
* Feld 43 - Begründung
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr OR c_btyp_aes.
      IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
        CONCATENATE ls_pssec-bsec-name1 ls_pssec-bsec-land1
                    ls_pssec-bsec-pstlz ls_pssec-bsec-ort01
               INTO rs_export-rese7 SEPARATED BY c_semicolon.
      ENDIF.
    WHEN c_btyp_szu OR c_btyp_sab.
      rs_export-rese7 = abap_off.
  ENDCASE.
* Feld 44 - Begründung
  rs_export-dnstl = abap_off.
* Feld 45 - leer
  rs_export-ftext = abap_off.
* Feld 46 - Name 2
  CASE rs_export-btyp.
    WHEN c_btyp_sst OR c_btyp_ssr.
      IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
        MOVE ls_pssec-bsec-stras TO rs_export-name2(27).
      ELSE.
        MOVE: ls_pssec-bsec-name2 TO rs_export-name2(27),
              ls_pssec-bsec-name3 TO rs_export-name2+27(27).
      ENDIF.
      SELECT SINGLE * FROM zpsm_cpd_gbdat INTO ls_cpd_gbdat
                     WHERE bukrs EQ ls_pso02-bukrs AND
                           zuonr EQ ls_pso02-zuonr.
      IF sy-subrc IS INITIAL.
        MOVE ls_cpd_gbdat-gbdat TO rs_export-name2+55(8).
      ENDIF.
    WHEN c_btyp_aes.
      IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
        MOVE ls_pssec-bsec-stras TO rs_export-name2(27).
      ELSE.
        IF ls_pssec-bsec-name2 IS INITIAL.
          ls_pssec-bsec-name2 = lc_percent.
        ENDIF.
        IF ls_pssec-bsec-name3 IS INITIAL.
          ls_pssec-bsec-name3 = lc_percent.
        ENDIF.
        MOVE: ls_pssec-bsec-name2 TO rs_export-name2(27),
              ls_pssec-bsec-name3 TO rs_export-name2+27(27).
      ENDIF.
      SELECT SINGLE * FROM zpsm_cpd_gbdat INTO ls_cpd_gbdat
                     WHERE bukrs EQ ls_pso02-bukrs AND
                           zuonr EQ ls_pso02-zuonr.
      IF sy-subrc IS INITIAL.
        MOVE ls_cpd_gbdat-gbdat TO rs_export-name2+55(8).
      ENDIF.
    WHEN c_btyp_szu OR c_btyp_sab.
      rs_export-name2 = abap_off.
  ENDCASE.
* Feld 47 - leer
  rs_export-buchz = abap_off.
* Feld 48 - leer
  rs_export-vehhj = abap_off.
* Feld 49 - Dienststelle
  rs_export-dstnr = c_dstnr_3101.
* Feld 50 - Verfahrenskennzeichen
  rs_export-verkz = c_verkz_sap.
* Feld 51 - Länderschlüssel
  rs_export-land1 = abap_off.
* Feld 52 - Postleitzahl
  rs_export-pstlz = abap_off.
* Feld 53 - Betrag
  rs_export-fbetr = abap_off.
* Feld 54 - Umrechnungskurs
  rs_export-kursf = abap_off.
* Feld 55 - Gesamtbetrag
  rs_export-gbbtr = abap_off.
* Feld 56 - Währung
  rs_export-gwaer = abap_off.
* Feld 57 - Bankname 1
  rs_export-bnknm1 = abap_off.
* Feld 58 - Bankname 2
  rs_export-bnknm2 = abap_off.
* Feld 59 - Straße der Bank
  rs_export-bnkstr = abap_off.
* Feld 60 - Ort der Bank
  rs_export-bnkort = abap_off.
* Feld 61 - Weisungscode
  rs_export-wsgkey = abap_off.
* Feld 62 - Text
  rs_export-kvkey = abap_off.
* Feld 63 - BIC (SWIFT)
  IF NOT ls_bnka-swift IS INITIAL AND
     NOT ls_iban-iban IS INITIAL  AND
     NOT rs_export-rese3+18(1) EQ 'j'.
    rs_export-biczp = build_bic_key( ls_bnka-swift ).
    MOVE lc_init_c18 TO rs_export-rese3(18).
  ENDIF.
* Feld 64 - BEI
  rs_export-beizp = abap_off.
* Feld 65 - IBAN
  IF NOT ls_iban-iban IS INITIAL  AND
     NOT ls_bnka-swift IS INITIAL AND
     NOT rs_export-rese3+18(1) EQ 'j'.
    rs_export-iban = ls_iban-iban.
    MOVE lc_init_c18 TO rs_export-rese3(18).
  ENDIF.
* Feld 66 - Anzahl
  rs_export-anzms = abap_off.
* Feld 67 - Straße der Bank
  rs_export-vtrag = abap_off.
* Feld 68 - Ort Unterschrift
  rs_export-osign = abap_off.
* Feld 69 - Datum Unterschrift
  rs_export-dsign = abap_off.
* Feld 70 - Identifier
  rs_export-ident = abap_off.
* Feld 71 - Status Mandat
  rs_export-mstat = abap_off.
* Feld 72 - Ursprungsmandat
  rs_export-mgaen = abap_off.
* Feld 73 - Druckdatum
  rs_export-prdat = abap_off.
* Feld 74 - Druckertyp
  rs_export-vtrag = abap_off.

ENDMETHOD.                    "map_dao_data


*----------------------------------------------------------------------*
* Methode MAP_ANE_DATA
*----------------------------------------------------------------------*
METHOD map_ane_data.

* lokale Datendeklaration
  CONSTANTS: lc_index_1  TYPE i VALUE 1,
             lc_value_1  TYPE i VALUE 1,
             lc_value_3  TYPE i VALUE 3,
             lc_value_4  TYPE i VALUE 4,
             lc_len_10   TYPE i VALUE 10,
             lc_merkm_a  TYPE c LENGTH 1 VALUE 'A',
             lc_merkm_s  TYPE c LENGTH 1 VALUE 'S',
             lc_zltyp_x  TYPE c LENGTH 1 VALUE 'X',
             lc_zltyp_s  TYPE c LENGTH 1 VALUE 'S',
             lc_zltyp_z  TYPE c LENGTH 1 VALUE 'Z',
             lc_land_de  TYPE land1 VALUE 'DE',
             lc_pseudo_p TYPE string VALUE '95  99999 D',
             lc_kasse_4  TYPE c LENGTH 1 VALUE '4',
             lc_separate TYPE c LENGTH 1 VALUE '-',
             lc_init_c18 TYPE c LENGTH 18 VALUE IS INITIAL.

  DATA: l_field_c10 TYPE char10,
        l_btyp      TYPE zbtyp,
        l_ebeln     TYPE ebeln,
        l_kblnr     TYPE kblnr,
        l_date_bi   TYPE date_bi,
        l_date_ex   TYPE datum,
        l_len       TYPE i.

  DATA: ls_pso02  LIKE LINE OF it_pso02,
        ls_pso02s LIKE LINE OF it_pso02s,
        ls_pssec  LIKE LINE OF it_pssec.

  DATA: ls_laenderkz TYPE zfin_laenderkz,
        ls_feb_data  TYPE ts_feb_data,
        ls_iban      TYPE tiban,
        ls_bnka      TYPE bnka,
        ls_ekko      TYPE ekko,
        ls_ekpo      TYPE ekpo.

  DATA: lt_kbld   TYPE fm_t_kbld,
        lt_psokpf TYPE STANDARD TABLE OF psokpf,
        ls_kbld   LIKE LINE OF lt_kbld,
        ls_psokpf LIKE LINE OF lt_psokpf.

* Importtabellen lesen
  READ TABLE: it_pso02  INTO ls_pso02  INDEX lc_index_1,
              it_pssec  INTO ls_pssec  INDEX lc_index_1.
  CASE ls_pso02-blart.
    WHEN c_blart_14.
      l_kblnr = is_data-aufkz.
      READ TABLE it_pso02s INTO ls_pso02s
                           WITH KEY fistl = is_data-fistl
                                    fipex = is_data-fipex
                                    kblnr = l_kblnr.
    WHEN c_blart_rn.
      l_ebeln = is_data-aufkz.
      READ TABLE it_pso02s INTO ls_pso02s
                           WITH KEY fistl = is_data-fistl
                                    fipex = is_data-fipex
                                    ebeln = l_ebeln.

    WHEN OTHERS.
      READ TABLE it_pso02s INTO ls_pso02s
                           WITH KEY fistl = is_data-fistl
                                    fipex = is_data-fipex.
  ENDCASE.

* Daten zur Mittelbindung lesen
  IF NOT ls_pso02s-kblnr IS INITIAL.
    SELECT SINGLE * FROM (c_sst_tabn_feb) INTO ls_feb_data
                   WHERE gjahr EQ ls_pso02-gjahr  AND
                         refbn EQ ls_pso02s-kblnr AND
                         fistl EQ ls_pso02s-fistl AND
                         fipex EQ ls_pso02s-fipex.

    IF sy-subrc IS INITIAL.
      read_document_data( EXPORTING iv_blart = ls_feb_data-blart
                                    iv_refbn = ls_feb_data-refbn
                          IMPORTING et_kbld  = lt_kbld ).
    ENDIF.
  ENDIF.

* Daten zur Bestellung / Rechnung lesen
  IF ls_pso02-blart EQ c_blart_rn AND NOT ls_pso02s-ebeln IS INITIAL.
    SELECT SINGLE * FROM (c_sst_tabn_feb) INTO ls_feb_data
                   WHERE gjahr EQ is_data-gjahr   AND
                         refbn EQ ls_pso02s-ebeln AND
                         fistl EQ is_data-fistl   AND
                         fipex EQ is_data-fipex.

    SELECT SINGLE * FROM ekko INTO ls_ekko
                   WHERE ebeln EQ ls_pso02s-ebeln.
    IF sy-subrc IS INITIAL.
      SELECT SINGLE * FROM ekpo INTO ls_ekpo
                     WHERE ebeln EQ ls_pso02s-ebeln AND
                           ebelp EQ ls_pso02s-ebelp.
    ENDIF.
  ENDIF.

* Daten zur Daueranordnung lesen
  IF NOT ls_pso02-dbblg IS INITIAL.
    SELECT * FROM psokpf INTO TABLE lt_psokpf
                        WHERE lotkz EQ ls_pso02-dbblg AND
                              bukrs EQ ls_pso02-bukrs.

    READ TABLE lt_psokpf INTO ls_psokpf
                         WITH KEY lotkz = ls_pso02-dbblg.
  ENDIF.

* Daten zu IBAN und SWIFT ermitteln
  IF NOT ls_pssec-bsec-bankl IS INITIAL.
    get_iban_swift_data( EXPORTING iv_banks  = ls_pssec-bsec-banks
                                   iv_bankl  = ls_pssec-bsec-bankl
                                   iv_bankn  = ls_pssec-bsec-bankn
                                   iv_bkont  = ls_pssec-bsec-bkont
                         IMPORTING es_iban   = ls_iban
                                   es_bnka   = ls_bnka ).
  ENDIF.

* Daten zur Festlegung prüfen
  IF NOT ls_feb_data IS INITIAL.
    l_btyp = iv_btyp.
  ELSE.
    l_btyp = c_btyp_fua.
  ENDIF.

* Feld 1 - Buchungstyp
  rs_export-btyp = l_btyp.
* Feld 2 - Merkmal
  CASE ls_pso02-blart.
    WHEN c_blart_17 OR c_blart_st.
      rs_export-merkm = lc_merkm_s.
    WHEN OTHERS.
      rs_export-merkm = lc_merkm_a.
  ENDCASE.
* Feld 3 - Firma
  rs_export-firma = abap_off.
* Feld 4 - HHJ
  rs_export-hhj = is_data-gjahr.
* Feld 5 - Quelle
  rs_export-quelle = abap_off.
* Feld 6 - Belegnummer
  CASE ls_pso02-blart.
    WHEN c_blart_rn OR c_blart_st.
      CONCATENATE is_data-refbn(2) is_data-refbn+4(6)
             INTO rs_export-belnr.
    WHEN OTHERS.
      rs_export-belnr = is_data-refbn+2(8).
  ENDCASE.
* Feld 7 - Belegposition
  rs_export-blpos = c_count.
* Feld 8 - Userkennzeichen
  rs_export-kerfas = c_usrkz.
* Feld 9 - Bereich
  rs_export-berei = is_data-fipex(2).
* Feld 10 - Kapitel
  CASE rs_export-btyp.
    WHEN c_btyp_fua.
      rs_export-kapit = is_data-fipex+2(4).
    WHEN c_btyp_ane.
      rs_export-kapit = abap_off.
    WHEN OTHERS.
  ENDCASE.
* Feld 11 - Titel
  CASE rs_export-btyp.
    WHEN c_btyp_fua.
      CONCATENATE is_data-fipex+6(3) is_data-fipex+9(2)
             INTO rs_export-titel SEPARATED BY abap_off.
    WHEN c_btyp_ane.
      rs_export-titel = abap_off.
    WHEN OTHERS.
  ENDCASE.
* Feld 12 - Org.einheit
  CASE rs_export-btyp.
    WHEN c_btyp_fua.
      rs_export-orgeh = is_data-fistl(8).
    WHEN c_btyp_ane.
      rs_export-orgeh = abap_off.
    WHEN OTHERS.
  ENDCASE.
* Feld 13 - Unterkonto
  CASE rs_export-btyp.
    WHEN c_btyp_fua.
      IF is_data-fipex+11(6) IS INITIAL.
        rs_export-unkto = c_unkto_00.
      ELSE.
        rs_export-unkto = is_data-fipex+11(6).
      ENDIF.
    WHEN c_btyp_ane.
      rs_export-unkto = abap_off.
    WHEN OTHERS.
  ENDCASE.
* Feld 14 - Referenznummer
  rs_export-refnr = abap_off.
* Feld 15 - Betrag
  IF ls_pso02-blart EQ c_blart_14 OR ls_pso02-blart EQ c_blart_rn.
    rs_export-betr1 = ls_pso02-wrbtr.
  ELSE.
    rs_export-betr1 = is_data-brtwr_sap.
  ENDIF.
  REPLACE ALL OCCURRENCES OF: c_colon IN rs_export-betr1 WITH space,
                              c_point IN rs_export-betr1 WITH space.
  CONDENSE rs_export-betr1 NO-GAPS.
* Feld 16 - Kombinationsfeld
  rs_export-betr2 = abap_off.
* Feld 17 - Fälligkeitsdatum
  IF NOT ls_pso02-zbd1t IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_MODAT_OUTPUT'
      EXPORTING  input         = ls_pso02-zfbdt
      IMPORTING  output        = l_date_bi
      EXCEPTIONS error_message = 2.

    IF NOT sy-subrc IS INITIAL.
      WRITE ls_pso02-zfbdt TO l_date_bi DD/MM/YYYY.
    ENDIF.

    CALL FUNCTION 'DATE_IN_FUTURE'
      EXPORTING  anzahl_tage             = ls_pso02-zbd1t
                 import_datum            = l_date_bi
      IMPORTING  export_datum_int_format = l_date_ex.

    rs_export-faedt = l_date_ex.
  ELSE.
    rs_export-faedt = ls_pso02-zfbdt.
  ENDIF.
* Feld 18 - Referenz SST
  rs_export-betr3 = abap_off.
* Feld 19 - Rechnungsart
  CASE ls_pso02-blart.
    WHEN c_blart_12.
      IF ls_psokpf-xdelt EQ abap_on.
        rs_export-txtsl = lc_value_4.
      ELSE.
        rs_export-txtsl = lc_value_3.
      ENDIF.
    WHEN c_blart_rn.
      rs_export-txtsl = get_txtsl( iv_awkey = ls_pso02-awkey
                                   iv_ebeln = ls_pso02s-ebeln
                                   iv_fistl = is_data-fistl
                                   iv_fipex = is_data-fipex ).
    WHEN OTHERS.
      READ TABLE lt_kbld INTO ls_kbld
                         WITH KEY belnr = ls_pso02s-kblnr
                                  blpos = ls_pso02s-kblpos.
      IF ls_kbld-fexec EQ abap_on OR
         ls_kbld-erlkz EQ abap_on.
        rs_export-txtsl = lc_value_4.
      ELSE.
        rs_export-txtsl = lc_value_3.
      ENDIF.
  ENDCASE.
  IF l_btyp EQ c_btyp_fua.
    rs_export-txtsl = lc_value_1.
  ENDIF.
* Feld 20 - Kombinationsfeld
  rs_export-betr4 = abap_off.
* Feld 21 - Zahltyp
  CASE ls_pso02-blart.
    WHEN c_blart_11 OR c_blart_12.
      rs_export-belkz = lc_zltyp_z.
    WHEN c_blart_rn  OR c_blart_14.
      IF iv_x_spl EQ abap_off.
        rs_export-belkz = lc_zltyp_z.
      ELSE.
        rs_export-belkz = lc_zltyp_s.
      ENDIF.
    WHEN c_blart_13.
      rs_export-belkz = lc_zltyp_x.
      rs_export-betr4 = ls_pso02-zuonr.
  ENDCASE.
* Feld 22 - Land u. PSTLZ
  CASE rs_export-belkz.
    WHEN lc_zltyp_z OR lc_zltyp_s.
      IF ls_pssec-bsec-land1 EQ lc_land_de.
        SELECT SINGLE * FROM zfin_laenderkz INTO ls_laenderkz
                       WHERE sapland     EQ ls_pssec-bsec-land1 AND
                             sapbankland EQ ls_pssec-bsec-land1.
        IF sy-subrc IS INITIAL.
          rs_export-rese1(4) = ls_laenderkz-dhbland.
        ELSE.
          rs_export-rese1(4) = ls_pssec-bsec-land1.
        ENDIF.
        IF ls_pssec-bsec-pstlz IS INITIAL.
          rs_export-rese1+4(6) = ls_pssec-bsec-pstl2.
        ELSE.
          rs_export-rese1+4(6) = ls_pssec-bsec-pstlz.
        ENDIF.
      ELSE.
        rs_export-rese1 = lc_pseudo_p.
        IF ls_iban IS INITIAL.
          rs_export-rese1+10(1) = 'N'.
        ENDIF.
      ENDIF.
  ENDCASE.
  CASE ls_pso02-zlsch.
    WHEN 'S' OR 'B'.
      rs_export-rese1+10(1) = 'V'.
    WHEN 'A'.
      rs_export-rese1+10(1) = 'L'.
    WHEN 'N'.
      rs_export-rese1+10(1) = 'N'.
    WHEN OTHERS.
      rs_export-rese1+10(1) = 'D'.
  ENDCASE.
* Feld 23 - Einmallieferant
  rs_export-lifnr = c_lifnr_001.
* Feld 24 - Ort
  IF rs_export-belkz EQ lc_zltyp_z OR rs_export-belkz EQ lc_zltyp_s.
    IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
      rs_export-rese2 = TEXT-poa.
    ELSE.
      rs_export-rese2 = ls_pssec-bsec-ort01.
    ENDIF.
  ELSE.
    rs_export-rese2 = abap_off.
  ENDIF.
* Feld 25 - lfd. Nummer Bankverbindung
  rs_export-bnknr = c_bnknr_1.
* Feld 26 - Bankleitzahl und Kontonr.
  IF rs_export-belkz EQ lc_zltyp_z OR rs_export-belkz EQ lc_zltyp_s.
    IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
      rs_export-rese3 = abap_off.
    ELSE.
      rs_export-rese3(8) = ls_pssec-bsec-bankl.
      IF strlen( ls_pssec-bsec-bankn ) LE lc_len_10.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING  input  = ls_pssec-bsec-bankn
          IMPORTING  output = l_field_c10.

        rs_export-rese3+8(10) = l_field_c10.
      ELSE.
        l_len = strlen( ls_pssec-bsec-bankn ).
        IF NOT l_len IS INITIAL.
          rs_export-rese3+8 = ls_pssec-bsec-bankn(l_len).
        ELSE.
          rs_export-rese3+8 = ls_pssec-bsec-bankn.
        ENDIF.
      ENDIF.
      IF ls_pso02-zlsch EQ 'E'.
        rs_export-rese3+18(1) = 'j'.
      ELSE.
        IF NOT ls_pssec-bsec-bankn IS INITIAL.
          rs_export-rese3+18(1) = 'n'.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    rs_export-rese3 = abap_off.
  ENDIF.
* Feld 27 - Kasse
  rs_export-kasse = lc_kasse_4.
* Feld 28 - Aktenzeichen
  IF NOT ls_pso02-psofn IS INITIAL.
    rs_export-aktkz = ls_pso02-psofn.
  ELSE.
    IF ls_pso02-blart EQ c_blart_rn AND NOT ls_ekko IS INITIAL.
      CONCATENATE ls_ekko-unsez ls_ekpo-bednr
                  INTO rs_export-aktkz SEPARATED BY lc_separate.
    ENDIF.
  ENDIF.
* Feld 29 - Begründung
  rs_export-grund = ls_pso02-sgtxt.
* Feld 30 - Begründung
  rs_export-buchn = abap_off.
* Feld 31 - Währung
  rs_export-lfdnr = abap_off.
* Feld 32 - Belegkassenzeichen
  CASE ls_pso02-blart.
    WHEN c_blart_12.
      rs_export-kassz = create_kassz( is_data-fistl ).
      IF NOT rs_export-kassz IS INITIAL.
        update_kassz( iv_bukrs = ls_pso02-bukrs
                      iv_belnr = ls_pso02-belnr
                      iv_gjahr = ls_pso02-gjahr
                      iv_xblnr = rs_export-kassz ).
      ENDIF.
    WHEN c_blart_rn.
      rs_export-kassz = ls_pso02s-zuonr.
    WHEN OTHERS.
      rs_export-kassz = ls_pso02-xblnr.
  ENDCASE.
* Feld 33 - Status der Übernahme
  rs_export-bnstat = c_bnstat_0.
* Feld 34 - Übernahme-User
  rs_export-bnuser = abap_off.
* Feld 35 - Übernahmedatum
  rs_export-bndat = abap_off.
* Feld 36 - Übernahmezeit
  rs_export-bnzeit = abap_off.
* Feld 37 - DHB-Fehlercode
  rs_export-bnerr = abap_off.
* Feld 38 - Name 1
  CASE rs_export-belkz.
    WHEN lc_zltyp_z OR lc_zltyp_s.
      rs_export-rese4 = ls_pssec-bsec-name1.
    WHEN OTHERS.
      rs_export-rese4 = abap_off.
  ENDCASE.
* Feld 39 - Strasse
  IF rs_export-belkz EQ lc_zltyp_z OR rs_export-belkz EQ lc_zltyp_s.
    IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
      CONCATENATE ls_pssec-bsec-land1 ls_pssec-bsec-pstlz
                  ls_pssec-bsec-ort01
             INTO rs_export-rese5 SEPARATED BY c_semicolon.
    ELSE.
      rs_export-rese5 = ls_pssec-bsec-stras.
    ENDIF.
  ELSE.
    rs_export-rese5 = abap_off.
  ENDIF.
* Feld 40 - Zahlstelle
  rs_export-zhlst = abap_off.
* Feld 41 - Urkassenzeichen
  CASE ls_pso02-blart.
    WHEN c_blart_17.
      rs_export-xblnr = ls_pso02-zuonr.
    WHEN  c_blart_st.
      rs_export-xblnr = ls_pso02s-zuonr.
    WHEN OTHERS.
      rs_export-xblnr = ls_feb_data-aufkz.
  ENDCASE.
* Feld 42 - Begründung
  rs_export-rese6 = ls_pso02-bktxt.
* Feld 43 - Begründung
  IF rs_export-belkz EQ lc_zltyp_z OR rs_export-belkz EQ lc_zltyp_s.
    IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
      CONCATENATE ls_pssec-bsec-name1 ls_pssec-bsec-land1
                  ls_pssec-bsec-pstlz ls_pssec-bsec-ort01
             INTO rs_export-rese7 SEPARATED BY c_semicolon.
    ENDIF.
  ELSE.
    rs_export-rese7 = abap_off.
  ENDIF.
* Feld 44 - Begründung
  rs_export-dnstl = abap_off.
* Feld 45 - leer
  rs_export-ftext = abap_off.
* Feld 46 - Name 2
  IF rs_export-belkz EQ lc_zltyp_z OR rs_export-belkz EQ lc_zltyp_s.
    IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
      MOVE ls_pssec-bsec-stras TO rs_export-name2(27).
    ELSE.
      MOVE: ls_pssec-bsec-name2 TO rs_export-name2(27),
            ls_pssec-bsec-name3 TO rs_export-name2+27(27).
    ENDIF.
  ELSE.
    rs_export-name2 = abap_off.
  ENDIF.
* Feld 47 - leer
  rs_export-buchz = abap_off.
* Feld 48 - leer
  rs_export-vehhj = abap_off.
* Feld 49 - Dienststelle
  rs_export-dstnr = c_dstnr_3101.
* Feld 50 - Verfahrenskennzeichen
  rs_export-verkz = c_verkz_sap.
* Feld 51 - Länderschlüssel
  rs_export-land1 = abap_off.
* Feld 52 - Postleitzahl
  rs_export-pstlz = abap_off.
* Feld 53 - Betrag
  rs_export-fbetr = abap_off.
* Feld 54 - Umrechnungskurs
  rs_export-kursf = abap_off.
* Feld 55 - Gesamtbetrag
  rs_export-gbbtr = abap_off.
* Feld 56 - Währung
  rs_export-gwaer = abap_off.
* Feld 57 - Bankname 1
  rs_export-bnknm1 = abap_off.
* Feld 58 - Bankname 2
  rs_export-bnknm2 = abap_off.
* Feld 59 - Straße der Bank
  rs_export-bnkstr = abap_off.
* Feld 60 - Ort der Bank
  rs_export-bnkort = abap_off.
* Feld 61 - Weisungscode
  rs_export-wsgkey = abap_off.
* Feld 62 - Text
  rs_export-kvkey = abap_off.
* Feld 63 - BIC (SWIFT)
  IF NOT ls_bnka-swift IS INITIAL AND
     NOT ls_iban-iban IS INITIAL.
    rs_export-biczp = build_bic_key( ls_bnka-swift ).
    MOVE lc_init_c18 TO rs_export-rese3(18).
  ENDIF.
* Feld 64 - BEI
  rs_export-beizp = abap_off.
* Feld 65 - IBAN
  IF NOT ls_iban-iban IS INITIAL AND
     NOT ls_bnka-swift IS INITIAL.
    rs_export-iban = ls_iban-iban.
    MOVE lc_init_c18 TO rs_export-rese3(18).
  ENDIF.
* Feld 66 - Anzahl
  rs_export-anzms = abap_off.
* Feld 67 - Straße der Bank
  rs_export-vtrag = abap_off.
* Feld 68 - Ort Unterschrift
  rs_export-osign = abap_off.
* Feld 69 - Datum Unterschrift
  rs_export-dsign = abap_off.
* Feld 70 - Identifier
  rs_export-ident = abap_off.
* Feld 71 - Status Mandat
  rs_export-mstat = abap_off.
* Feld 72 - Ursprungsmandat
  rs_export-mgaen = abap_off.
* Feld 73 - Druckdatum
  rs_export-prdat = abap_off.
* Feld 74 - Druckertyp
  rs_export-vtrag = abap_off.

ENDMETHOD.                    "map_ane_data


*----------------------------------------------------------------------*
* Methode MAP_FUA_DATA
*----------------------------------------------------------------------*
METHOD map_fua_data.

* lokale Datendeklaration
  CONSTANTS: lc_index_1  TYPE i VALUE 1,
             lc_value_1  TYPE i VALUE 1,
             lc_value_4  TYPE i VALUE 4,
             lc_len_10   TYPE i VALUE 10,
             lc_merkm_a  TYPE c LENGTH 1 VALUE 'A',
             lc_merkm_s  TYPE c LENGTH 1 VALUE 'S',
             lc_zltyp_x  TYPE c LENGTH 1 VALUE 'X',
             lc_zltyp_s  TYPE c LENGTH 1 VALUE 'S',
             lc_zltyp_z  TYPE c LENGTH 1 VALUE 'Z',
             lc_land_de  TYPE land1 VALUE 'DE',
             lc_pseudo_p TYPE string VALUE '95  99999 D',
             lc_kasse_4  TYPE c LENGTH 1 VALUE '4',
             lc_init_c18 TYPE c LENGTH 18 VALUE IS INITIAL.

  DATA: l_field_c10 TYPE char10,
        l_len       TYPE i.

  DATA: ls_pso02  LIKE LINE OF it_pso02,
        ls_pso02s LIKE LINE OF it_pso02s,
        ls_pssec  LIKE LINE OF it_pssec.

  DATA: ls_laenderkz TYPE zfin_laenderkz,
        ls_ano_data  TYPE ts_ano_data,
        ls_iban      TYPE tiban,
        ls_bnka      TYPE bnka.

* Importtabellen lesen
  READ TABLE: it_pso02  INTO ls_pso02  INDEX lc_index_1,
              it_pssec  INTO ls_pssec  INDEX lc_index_1,
              it_pso02s INTO ls_pso02s WITH KEY fistl = is_data-fistl
                                                fipex = is_data-fipex.

* Daten zu IBAN und SWIFT ermitteln
  IF NOT ls_pssec-bsec-bankl IS INITIAL.
    get_iban_swift_data( EXPORTING iv_banks  = ls_pssec-bsec-banks
                                   iv_bankl  = ls_pssec-bsec-bankl
                                   iv_bankn  = ls_pssec-bsec-bankn
                                   iv_bkont  = ls_pssec-bsec-bkont
                         IMPORTING es_iban   = ls_iban
                                   es_bnka   = ls_bnka ).
  ENDIF.

* bei Belgart 17 oder ST prüfen, ob Bezugsbeleg ausgegeben wurde
  IF ls_pso02-blart EQ c_blart_17 OR ls_pso02-blart EQ c_blart_st.
    SELECT SINGLE * FROM (c_sst_tabn_ano) INTO ls_ano_data
                   WHERE gjahr EQ ls_pso02-rebzj AND
                         refbn EQ ls_pso02-rebzg.
    IF NOT sy-subrc IS INITIAL.
      READ TABLE it_ano INTO ls_ano_data
                        WITH KEY gjahr = ls_pso02-rebzj
                                 refbn = ls_pso02-rebzg.
      IF NOT sy-subrc IS INITIAL.
        rs_export-bnstat = c_errkz_1.
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

* Feld 1 - Buchungstyp
  IF ls_pso02s-fipex+6(1) LT lc_value_4.
    rs_export-btyp = c_btyp_aoe.
  ELSE.
    rs_export-btyp = iv_btyp.
  ENDIF.
* Feld 2 - Merkmal
  CASE ls_pso02-blart.
    WHEN c_blart_17 OR c_blart_st.
      rs_export-merkm = lc_merkm_s.
    WHEN OTHERS.
      rs_export-merkm = lc_merkm_a.
  ENDCASE.
* Feld 3 - Firma
  rs_export-firma = abap_off.
* Feld 4 - HHJ
  rs_export-hhj = is_data-gjahr.
* Feld 5 - Quelle
  rs_export-quelle = abap_off.
* Feld 6 - Belegnummer
  rs_export-belnr = is_data-refbn+2(8).
* Feld 7 - Belegposition
  rs_export-blpos = c_count.
* Feld 8 - Userkennzeichen
  rs_export-kerfas = c_usrkz.
* Feld 9 - Bereich
  rs_export-berei = is_data-fipex(2).
* Feld 10 - Kapitel
  rs_export-kapit = is_data-fipex+2(4).
* Feld 11 - Titel
  CONCATENATE is_data-fipex+6(3) is_data-fipex+9(2)
         INTO rs_export-titel SEPARATED BY abap_off.
* Feld 12 - Org.einheit
  rs_export-orgeh = is_data-fistl(8).
* Feld 13 - Unterkonto
  IF is_data-fipex+11(6) IS INITIAL.
    rs_export-unkto = c_unkto_00.
  ELSE.
    rs_export-unkto = is_data-fipex+11(6).
  ENDIF.
* Feld 14 - Referenznummer
  IF rs_export-btyp EQ c_btyp_aoe AND
     rs_export-merkm EQ lc_merkm_s.
    rs_export-refnr = ls_ano_data-belnr_dhb.
  ELSE.
    rs_export-refnr = abap_off.
  ENDIF.
* Feld 15 - Betrag
  IF ls_pso02-blart EQ c_blart_14.
    rs_export-betr1 = ls_pso02-wrbtr.
  ELSE.
    rs_export-betr1 = is_data-brtwr_sap.
  ENDIF.
  REPLACE ALL OCCURRENCES OF: c_colon IN rs_export-betr1 WITH space,
                              c_point IN rs_export-betr1 WITH space.
  CONDENSE rs_export-betr1 NO-GAPS.
* Feld 16 - Kombinationsfeld
  rs_export-betr2 = abap_off.
* Feld 17 - Fälligkeitsdatum
  rs_export-faedt = ls_pso02-zfbdt.
* Feld 18 - Referenz
  rs_export-betr3 = abap_off.
* Feld 19 - Rechnungsart
  IF rs_export-btyp EQ c_btyp_aoe.
    rs_export-txtsl = abap_off.
  ELSE.
    rs_export-txtsl = lc_value_1.
  ENDIF.
* Feld 20 - Kombinationsfeld
    rs_export-betr4 = abap_off.
* Feld 21 - Zahltyp
  CASE ls_pso02-blart.
    WHEN c_blart_11.
      rs_export-belkz = lc_zltyp_z.
    WHEN c_blart_13.
      rs_export-belkz = lc_zltyp_x.
      rs_export-betr4 = ls_pso02-zuonr.
    WHEN c_blart_14.
      rs_export-belkz = lc_zltyp_s.
  ENDCASE.
* Feld 22 - Land u. PSTLZ
  CASE rs_export-belkz.
    WHEN lc_zltyp_z OR lc_zltyp_s.
      IF ls_pssec-bsec-land1 EQ lc_land_de.
        SELECT SINGLE * FROM zfin_laenderkz INTO ls_laenderkz
                       WHERE sapland     EQ ls_pssec-bsec-land1 AND
                             sapbankland EQ ls_pssec-bsec-land1.
        IF sy-subrc IS INITIAL.
          rs_export-rese1(4) = ls_laenderkz-dhbland.
        ELSE.
          rs_export-rese1(4) = ls_pssec-bsec-land1.
        ENDIF.
        IF ls_pssec-bsec-pstlz IS INITIAL.
          rs_export-rese1+4(6) = ls_pssec-bsec-pstl2.
        ELSE.
          rs_export-rese1+4(6) = ls_pssec-bsec-pstlz.
        ENDIF.
      ELSE.
        rs_export-rese1 = lc_pseudo_p.
        IF ls_iban IS INITIAL.
          rs_export-rese1+10(1) = 'N'.
        ENDIF.
      ENDIF.
  ENDCASE.
  CASE ls_pso02-zlsch.
    WHEN 'S' OR 'B'.
      rs_export-rese1+10(1) = 'V'.
    WHEN 'A'.
      rs_export-rese1+10(1) = 'L'.
    WHEN 'N'.
      rs_export-rese1+10(1) = 'N'.
    WHEN OTHERS.
      rs_export-rese1+10(1) = 'D'.
  ENDCASE.
* Feld 23 - Einmallieferant
  rs_export-lifnr = c_lifnr_001.
* Feld 24 - Ort
  IF rs_export-belkz EQ lc_zltyp_z OR rs_export-belkz EQ lc_zltyp_s.
    IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
      rs_export-rese2 = TEXT-poa.
    ELSE.
      rs_export-rese2 = ls_pssec-bsec-ort01.
    ENDIF.
  ELSE.
    rs_export-rese2 = abap_off.
  ENDIF.
* Feld 25 - lfd. Nummer Bankverbindung
  rs_export-bnknr = c_bnknr_1.
* Feld 26 - Bankleitzahl und Kontonr.
  IF rs_export-belkz EQ lc_zltyp_z OR rs_export-belkz EQ lc_zltyp_s.
    IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
      rs_export-rese3 = abap_off.
    ELSE.
      rs_export-rese3(8) = ls_pssec-bsec-bankl.
      IF strlen( ls_pssec-bsec-bankn ) LE lc_len_10.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING  input  = ls_pssec-bsec-bankn
          IMPORTING  output = l_field_c10.

        rs_export-rese3+8(10) = l_field_c10.
      ELSE.
        l_len = strlen( ls_pssec-bsec-bankn ).
        IF NOT l_len IS INITIAL.
          rs_export-rese3+8 = ls_pssec-bsec-bankn(l_len).
        ELSE.
          rs_export-rese3+8 = ls_pssec-bsec-bankn.
        ENDIF.
      ENDIF.
      IF ls_pso02-zlsch EQ 'E'.
        rs_export-rese3+18(1) = 'j'.
      ELSE.
        IF NOT ls_pssec-bsec-bankn IS INITIAL.
          rs_export-rese3+18(1) = 'n'.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    rs_export-rese3 = abap_off.
  ENDIF.
* Feld 27 - Kasse
  rs_export-kasse = lc_kasse_4.
* Feld 28 - Aktenzeichen
  rs_export-aktkz = ls_pso02-psofn.
* Feld 29 - Begründung
  rs_export-grund = ls_pso02-sgtxt.
* Feld 30 - Begründung
  rs_export-buchn = abap_off.
* Feld 31 - Währung
  rs_export-lfdnr = abap_off.
* Feld 32 - Belegkassenzeichen
  rs_export-kassz = ls_pso02-xblnr.
* Feld 33 - Status der Übernahme
  rs_export-bnstat = c_bnstat_0.
* Feld 34 - Übernahme-User
  rs_export-bnuser = abap_off.
* Feld 35 - Übernahmedatum
  rs_export-bndat = abap_off.
* Feld 36 - Übernahmezeit
  rs_export-bnzeit = abap_off.
* Feld 37 - DHB-Fehlercode
  rs_export-bnerr = abap_off.
* Feld 38 - Name 1
  IF rs_export-belkz EQ lc_zltyp_z OR rs_export-belkz EQ lc_zltyp_s.
    rs_export-rese4 = ls_pssec-bsec-name1.
  ELSE.
    rs_export-rese4 = abap_off.
  ENDIF.
* Feld 39 - Strasse
  IF rs_export-belkz EQ lc_zltyp_z OR rs_export-belkz EQ lc_zltyp_s.
    IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
      CONCATENATE ls_pssec-bsec-land1 ls_pssec-bsec-pstlz
                  ls_pssec-bsec-ort01
             INTO rs_export-rese5 SEPARATED BY c_semicolon.
    ELSE.
      rs_export-rese5 = ls_pssec-bsec-stras.
    ENDIF.
  ELSE.
    rs_export-rese5 = abap_off.
  ENDIF.
* Feld 40 - Zahlstelle
  rs_export-zhlst = abap_off.
* Feld 41 - Urkassenzeichen
  CASE ls_pso02-blart.
    WHEN c_blart_17 OR c_blart_st.
      rs_export-xblnr = ls_pso02-zuonr.
    WHEN OTHERS.
      rs_export-xblnr = abap_off.
  ENDCASE.
* Feld 42 - Begründung
  rs_export-rese6 = ls_pso02-bktxt.
* Feld 43 - Begründung
  IF rs_export-belkz EQ lc_zltyp_z OR rs_export-belkz EQ lc_zltyp_s.
    IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
      CONCATENATE ls_pssec-bsec-name1 ls_pssec-bsec-land1
                  ls_pssec-bsec-pstlz ls_pssec-bsec-ort01
             INTO rs_export-rese7 SEPARATED BY c_semicolon.
    ENDIF.
  ELSE.
    rs_export-rese7 = abap_off.
  ENDIF.
* Feld 44 - Begründung
  rs_export-dnstl = abap_off.
* Feld 45 - leer
  rs_export-ftext = abap_off.
* Feld 46 - Name 2
  IF rs_export-belkz EQ lc_zltyp_z OR rs_export-belkz EQ lc_zltyp_s.
    IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
      MOVE ls_pssec-bsec-stras TO rs_export-name2(27).
    ELSE.
      MOVE: ls_pssec-bsec-name2 TO rs_export-name2(27),
            ls_pssec-bsec-name3 TO rs_export-name2+27(27).
    ENDIF.
  ELSE.
    rs_export-name2 = abap_off.
  ENDIF.
* Feld 47 - leer
  rs_export-buchz = abap_off.
* Feld 48 - leer
  rs_export-vehhj = abap_off.
* Feld 49 - Dienststelle
  rs_export-dstnr = c_dstnr_3101.
* Feld 50 - Verfahrenskennzeichen
  rs_export-verkz = c_verkz_sap.
* Feld 51 - Länderschlüssel
  rs_export-land1 = abap_off.
* Feld 52 - Postleitzahl
  rs_export-pstlz = abap_off.
* Feld 53 - Betrag
  rs_export-fbetr = abap_off.
* Feld 54 - Umrechnungskurs
  rs_export-kursf = abap_off.
* Feld 55 - Gesamtbetrag
  rs_export-gbbtr = abap_off.
* Feld 56 - Währung
  rs_export-gwaer = abap_off.
* Feld 57 - Bankname 1
  rs_export-bnknm1 = abap_off.
* Feld 58 - Bankname 2
  rs_export-bnknm2 = abap_off.
* Feld 59 - Straße der Bank
  rs_export-bnkstr = abap_off.
* Feld 60 - Ort der Bank
  rs_export-bnkort = abap_off.
* Feld 61 - Weisungscode
  rs_export-wsgkey = abap_off.
* Feld 62 - Text
  rs_export-kvkey = abap_off.
* Feld 63 - BIC (SWIFT)
  IF NOT ls_bnka-swift IS INITIAL AND
     NOT ls_iban-iban IS INITIAL.
    rs_export-biczp = build_bic_key( ls_bnka-swift ).
    MOVE lc_init_c18 TO rs_export-rese3(18).
  ENDIF.
* Feld 64 - BEI
  rs_export-beizp = abap_off.
* Feld 65 - IBAN
  IF NOT ls_iban-iban IS INITIAL AND
     NOT ls_bnka-swift IS INITIAL.
    rs_export-iban = ls_iban-iban.
    MOVE lc_init_c18 TO rs_export-rese3(18).
  ENDIF.
* Feld 66 - Anzahl
  rs_export-anzms = abap_off.
* Feld 67 - Straße der Bank
  rs_export-vtrag = abap_off.
* Feld 68 - Ort Unterschrift
  rs_export-osign = abap_off.
* Feld 69 - Datum Unterschrift
  rs_export-dsign = abap_off.
* Feld 70 - Identifier
  rs_export-ident = abap_off.
* Feld 71 - Status Mandat
  rs_export-mstat = abap_off.
* Feld 72 - Ursprungsmandat
  rs_export-mgaen = abap_off.
* Feld 73 - Druckdatum
  rs_export-prdat = abap_off.
* Feld 74 - Druckertyp
  rs_export-vtrag = abap_off.

ENDMETHOD.                    "map_fua_data


*----------------------------------------------------------------------*
* Methode MAP_KOR_DATA
*----------------------------------------------------------------------*
METHOD map_kor_data.

* lokale Datendeklaration
  CONSTANTS: lc_index_1  TYPE i VALUE 1,
             lc_merkm_a  TYPE char1 VALUE 'A',
             lc_kasse_4  TYPE char1 VALUE '4'.

  DATA: l_refbn TYPE co_refbn,
        l_ebeln TYPE ebeln,
        l_len   TYPE i.

  DATA: ls_pso02  LIKE LINE OF it_pso02,
        ls_pso02s LIKE LINE OF it_pso02s.

  DATA: ls_feb_data TYPE ts_feb_data.

* Importtabellen lesen
  READ TABLE it_pso02  INTO ls_pso02  INDEX lc_index_1.
  CASE ls_pso02-blart.
    WHEN c_blart_rn.
      DESCRIBE FIELD l_ebeln LENGTH l_len IN CHARACTER MODE.
      IF NOT is_data-aufkz IS INITIAL.
        l_ebeln = is_data-aufkz(l_len).
      ENDIF.
      READ TABLE it_pso02s INTO ls_pso02s
                           WITH KEY fistl = is_data-fistl
                                    fipex = is_data-fipex
                                    ebeln = l_ebeln.
    WHEN OTHERS.
      READ TABLE it_pso02s INTO ls_pso02s
                           WITH KEY fistl = is_data-fistl
                                    fipex = is_data-fipex.
  ENDCASE.

* Feld 1 - Buchungstyp
  rs_export-btyp = iv_btyp.
* Feld 2 - Merkmal
  rs_export-merkm = lc_merkm_a.
* Feld 3 - Firma
  rs_export-firma = abap_off.
* Feld 4 - HHJ
  rs_export-hhj = is_data-gjahr.
* Feld 5 - Quelle
  rs_export-quelle = abap_off.
* Feld 6 - Belegnummer
  rs_export-belnr = is_data-refbn+2(8).
* Feld 7 - Belegposition
  rs_export-blpos = c_count.
* Feld 8 - Userkennzeichen
  rs_export-kerfas = c_usrkz.
* Feld 9 - Bereich
  rs_export-berei = is_data-fipex(2).
* Feld 10 - Kapitel
  rs_export-kapit = is_data-fipex+2(4).
* Feld 11 - Titel
  CONCATENATE is_data-fipex+6(3) is_data-fipex+9(2)
         INTO rs_export-titel SEPARATED BY abap_off.
* Feld 12 - Org.einheit
  rs_export-orgeh = is_data-fistl(8).
* Feld 13 - Unterkonto
  IF is_data-fipex+11(6) IS INITIAL.
    rs_export-unkto = c_unkto_00.
  ELSE.
    rs_export-unkto = is_data-fipex+11(6).
  ENDIF.
* Feld 14 - Referenznummer
  rs_export-refnr = abap_off.
* Feld 15 - Betrag
  rs_export-betr1 = is_data-brtwr_sap.
  REPLACE ALL OCCURRENCES OF: c_colon IN rs_export-betr1 WITH space,
                              c_point IN rs_export-betr1 WITH space.
  CONDENSE rs_export-betr1 NO-GAPS.
* Feld 16 - Kombinationsfeld
  rs_export-betr2 = abap_off.
* Feld 17 - Fälligkeitsdatum
  rs_export-faedt = abap_off.
* Feld 18 - Referenz
  IF ls_pso02-blart EQ c_blart_14 OR ls_pso02-blart EQ c_blart_rn.
    rs_export-betr3 = iv_refspl.
  ELSE.
    rs_export-betr3 = abap_off.
  ENDIF.
* Feld 19 - Rechnungsart
  CASE ls_pso02-blart.
    WHEN c_blart_rn.
      rs_export-txtsl = get_txtsl( iv_awkey = ls_pso02-awkey
                                   iv_ebeln = ls_pso02s-ebeln
                                   iv_fistl = is_data-fistl
                                   iv_fipex = is_data-fipex ).

    WHEN OTHERS.
      rs_export-txtsl = abap_off.
  ENDCASE.
* Feld 20 - Kombinationsfeld
  rs_export-betr4 = abap_off.
* Feld 21 - Zahltyp
  rs_export-belkz = abap_off.
* Feld 22 - Land u. PSTLZ
  rs_export-rese1 = abap_off.
* Feld 23 - Einmallieferant
  rs_export-lifnr = abap_off.
* Feld 24 - Ort
  rs_export-rese2 = abap_off.
* Feld 25 - lfd. Nummer Bankverbindung
  rs_export-bnknr = abap_off.
* Feld 26 - Bankleitzahl und Kontonr.
  rs_export-rese3 = abap_off.
* Feld 27 - Kasse
  rs_export-kasse = lc_kasse_4.
* Feld 28 - Aktenzeichen
  rs_export-aktkz = abap_off.
* Feld 29 - Begründung
  rs_export-grund = abap_off.
* Feld 30 - Begründung
  rs_export-buchn = abap_off.
* Feld 31 - Währung
  rs_export-lfdnr = abap_off.
* Feld 32 - Belegkassenzeichen
  CASE ls_pso02-blart.
    WHEN c_blart_rn.
      rs_export-kassz = ls_pso02s-zuonr.
    WHEN OTHERS.
      rs_export-kassz = ls_pso02-xblnr.
  ENDCASE.
* Feld 33 - Status der Übernahme
  rs_export-bnstat = c_bnstat_0.
* Feld 34 - Übernahme-User
  rs_export-bnuser = abap_off.
* Feld 35 - Übernahmedatum
  rs_export-bndat = abap_off.
* Feld 36 - Übernahmezeit
  rs_export-bnzeit = abap_off.
* Feld 37 - DHB-Fehlercode
  rs_export-bnerr = abap_off.
* Feld 38 - an Auftragskennz./Festlegung
  IF ls_pso02-blart EQ c_blart_14 AND NOT ls_pso02s-kblnr IS INITIAL.
    SELECT SINGLE * FROM (c_sst_tabn_feb) INTO ls_feb_data
                   WHERE gjahr EQ ls_pso02-gjahr  AND
                         refbn EQ ls_pso02s-kblnr AND
                         fistl EQ ls_pso02s-fistl AND
                         fipex EQ ls_pso02s-fipex.
    IF sy-subrc IS INITIAL.
      rs_export-rese4 = ls_feb_data-aufkz.
    ENDIF.
  ELSEIF ls_pso02-blart EQ c_blart_rn AND NOT is_data-aufkz IS INITIAL.
    CLEAR l_refbn. l_refbn = is_data-aufkz(10).
    SELECT SINGLE * FROM (c_sst_tabn_feb) INTO ls_feb_data
                   WHERE gjahr EQ is_data-gjahr AND
                         refbn EQ l_refbn       AND
                         fistl EQ is_data-fistl AND
                         fipex EQ is_data-fipex.
    IF sy-subrc IS INITIAL.
      rs_export-rese4 = ls_feb_data-aufkz.
    ENDIF.
  ELSE.
    rs_export-rese4 = abap_off.
  ENDIF.
* Feld 39 - Strasse
  rs_export-rese5 = abap_off.
* Feld 40 - Zahlstelle
  rs_export-zhlst = abap_off.
* Feld 41 - Urkassenzeichen
  CASE ls_pso02-blart.
    WHEN c_blart_32.
      rs_export-xblnr = ls_pso02-zuonr.
    WHEN OTHERS.
      rs_export-xblnr = abap_off.
  ENDCASE.
* Feld 42 - Begründung
  rs_export-rese6 = ls_pso02-bktxt.
* Feld 43 - Begründung
  rs_export-rese7 = abap_off.
* Feld 44 - Begründung
  rs_export-dnstl = abap_off.
* Feld 45 - leer
  rs_export-ftext = abap_off.
* Feld 46 - Name 2
  rs_export-name2 = abap_off.
* Feld 47 - leer
  rs_export-buchz = abap_off.
* Feld 48 - leer
  rs_export-vehhj = abap_off.
* Feld 49 - Dienststelle
  rs_export-dstnr = c_dstnr_3101.
* Feld 50 - Verfahrenskennzeichen
  rs_export-verkz = c_verkz_sap.
* Feld 51 - Länderschlüssel
  rs_export-land1 = abap_off.
* Feld 52 - Postleitzahl
  rs_export-pstlz = abap_off.
* Feld 53 - Betrag
  rs_export-fbetr = abap_off.
* Feld 54 - Umrechnungskurs
  rs_export-kursf = abap_off.
* Feld 55 - Gesamtbetrag
  rs_export-gbbtr = abap_off.
* Feld 56 - Währung
  rs_export-gwaer = abap_off.
* Feld 57 - Bankname 1
  rs_export-bnknm1 = abap_off.
* Feld 58 - Bankname 2
  rs_export-bnknm2 = abap_off.
* Feld 59 - Straße der Bank
  rs_export-bnkstr = abap_off.
* Feld 60 - Ort der Bank
  rs_export-bnkort = abap_off.
* Feld 61 - Weisungscode
  rs_export-wsgkey = abap_off.
* Feld 62 - Text
  rs_export-kvkey = abap_off.
* Feld 63 - BIC (SWIFT)
  rs_export-biczp = abap_off.
* Feld 64 - BEI
  rs_export-beizp = abap_off.
* Feld 65 - IBAN
  rs_export-iban = abap_off.
* Feld 66 - Anzahl
  rs_export-anzms = abap_off.
* Feld 67 - Straße der Bank
  rs_export-vtrag = abap_off.
* Feld 68 - Ort Unterschrift
  rs_export-osign = abap_off.
* Feld 69 - Datum Unterschrift
  rs_export-dsign = abap_off.
* Feld 70 - Identifier
  rs_export-ident = abap_off.
* Feld 71 - Status Mandat
  rs_export-mstat = abap_off.
* Feld 72 - Ursprungsmandat
  rs_export-mgaen = abap_off.
* Feld 73 - Druckdatum
  rs_export-prdat = abap_off.
* Feld 74 - Druckertyp
  rs_export-vtrag = abap_off.

ENDMETHOD.                    "map_kor_data


*----------------------------------------------------------------------*
* Methode MAP_ALL_DATA
*----------------------------------------------------------------------*
METHOD map_all_data.

* lokale Datendeklaration
  CONSTANTS: lc_index_1  TYPE i VALUE 1,
             lc_value_1  TYPE i VALUE 1,
             lc_len_10   TYPE i VALUE 10,
             lc_merkm_a  TYPE c LENGTH 1 VALUE 'A',
             lc_land_de  TYPE land1 VALUE 'DE',
             lc_pseudo_p TYPE string VALUE '95  99999 D',
             lc_kasse_4  TYPE c LENGTH 1 VALUE '4',
             lc_init_c18 TYPE c LENGTH 18 VALUE IS INITIAL.

  DATA: l_field_c10 TYPE c LENGTH 10,
        l_len       TYPE i.

  DATA: ls_pso02 LIKE LINE OF it_pso02,
        ls_pssec LIKE LINE OF it_pssec.

  DATA: ls_laenderkz TYPE zfin_laenderkz,
        ls_iban      TYPE tiban,
        ls_bnka      TYPE bnka.

* Importtabellen lesen
  READ TABLE: it_pso02 INTO ls_pso02 INDEX lc_index_1,
              it_pssec INTO ls_pssec INDEX lc_index_1.

* Daten zu IBAN und SWIFT ermitteln
  IF NOT ls_pssec-bsec-bankl IS INITIAL.
    get_iban_swift_data( EXPORTING iv_banks  = ls_pssec-bsec-banks
                                   iv_bankl  = ls_pssec-bsec-bankl
                                   iv_bankn  = ls_pssec-bsec-bankn
                                   iv_bkont  = ls_pssec-bsec-bkont
                         IMPORTING es_iban   = ls_iban
                                   es_bnka   = ls_bnka ).
  ENDIF.

* Feld 1 - Buchungstyp
  rs_export-btyp = iv_btyp.
* Feld 2 - Merkmal
  rs_export-merkm = lc_merkm_a.
* Feld 3 - Firma
  rs_export-firma = abap_off.
* Feld 4 - HHJ
  rs_export-hhj = is_data-gjahr.
* Feld 5 - Quelle
  rs_export-quelle = abap_off.
* Feld 6 - Belegnummer
  rs_export-belnr = is_data-refbn+2(8).
* Feld 7 - Belegposition
  rs_export-blpos = c_count.
* Feld 8 - Userkennzeichen
  rs_export-kerfas = c_usrkz.
* Feld 9 - Bereich
  rs_export-berei = is_data-fipex(2).
* Feld 10 - Kapitel
  rs_export-kapit = is_data-fipex+2(4).
* Feld 11 - Titel
  CONCATENATE is_data-fipex+6(3) is_data-fipex+9(2)
         INTO rs_export-titel SEPARATED BY abap_off.
* Feld 12 - Org.einheit
  rs_export-orgeh = is_data-fistl(8).
* Feld 13 - Unterkonto
  IF is_data-fipex+11(6) IS INITIAL.
    rs_export-unkto = c_unkto_00.
  ELSE.
    rs_export-unkto = is_data-fipex+11(6).
  ENDIF.
* Feld 14 - Referenznummer
  rs_export-refnr = abap_off.
* Feld 15 - Betrag
  rs_export-betr1 = abap_off.
* Feld 16 - Kombinationsfeld
  rs_export-betr2 = abap_off.
* Feld 17 - Fälligkeitsdatum
  IF NOT ls_pso02-zfbdt IS INITIAL.
    rs_export-faedt = ls_pso02-zfbdt.
  ELSE.
    rs_export-faedt = abap_off.
  ENDIF.
* Feld 18 - Referenz
  rs_export-betr3 = abap_off.
* Feld 19 - Rechnungsart
  rs_export-txtsl = lc_value_1.
* Feld 20 - Kombinationsfeld
  rs_export-betr4 = abap_off.
* Feld 21 - Zahltyp
  rs_export-belkz = abap_off.
* Feld 22 - Land u. PSTLZ
  IF ls_pssec-bsec-land1 EQ lc_land_de.
    SELECT SINGLE * FROM zfin_laenderkz INTO ls_laenderkz
                   WHERE sapland     EQ ls_pssec-bsec-land1 AND
                         sapbankland EQ ls_pssec-bsec-land1.
    IF sy-subrc IS INITIAL.
      rs_export-rese1(4) = ls_laenderkz-dhbland.
    ELSE.
      rs_export-rese1(4) = ls_pssec-bsec-land1.
    ENDIF.
    IF ls_pssec-bsec-pstlz IS INITIAL.
      rs_export-rese1+4(6) = ls_pssec-bsec-pstl2.
    ELSE.
      rs_export-rese1+4(6) = ls_pssec-bsec-pstlz.
    ENDIF.
    rs_export-rese1+10(1) = 'L'.
  ELSE.
    rs_export-rese1 = lc_pseudo_p.
    rs_export-rese1+10(1) = 'N'.
  ENDIF.
* Feld 23 - Einmallieferant
  rs_export-lifnr = c_lifnr_001.
* Feld 24 - Ort
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    rs_export-rese2 = TEXT-poa.
  ELSE.
    rs_export-rese2 = ls_pssec-bsec-ort01.
  ENDIF.
* Feld 25 - lfd. Nummer Bankverbindung
  rs_export-bnknr = c_bnknr_1.
* Feld 26 - Bankleitzahl und Kontonr.
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    rs_export-rese3 = abap_off.
  ELSE.
    rs_export-rese3(8) = ls_pssec-bsec-bankl.
    IF strlen( ls_pssec-bsec-bankn ) LE lc_len_10.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING  input  = ls_pssec-bsec-bankn
        IMPORTING  output = l_field_c10.

      rs_export-rese3+8(10) = l_field_c10.
    ELSE.
      l_len = strlen( ls_pssec-bsec-bankn ).
      IF NOT l_len IS INITIAL.
        rs_export-rese3+8 = ls_pssec-bsec-bankn(l_len).
      ELSE.
        rs_export-rese3+8 = ls_pssec-bsec-bankn.
      ENDIF.
    ENDIF.
    rs_export-rese3+18(1) = 'j'.
  ENDIF.
* Feld 27 - Kasse
  rs_export-kasse = lc_kasse_4.
* Feld 28 - Aktenzeichen
  rs_export-aktkz = ls_pso02-psofn.
* Feld 29 - Begründung
  rs_export-grund = ls_pso02-sgtxt.
* Feld 30 - Begründung
  rs_export-buchn = abap_off.
* Feld 31 - Währung
  rs_export-lfdnr = abap_off.
* Feld 32 - Belegkassenzeichen
  rs_export-kassz = ls_pso02-xblnr.
* Feld 33 - Status der Übernahme
  rs_export-bnstat = c_bnstat_0.
* Feld 34 - Übernahme-User
  rs_export-bnuser = abap_off.
* Feld 35 - Übernahmedatum
  rs_export-bndat = abap_off.
* Feld 36 - Übernahmezeit
  rs_export-bnzeit = abap_off.
* Feld 37 - DHB-Fehlercode
  rs_export-bnerr = abap_off.
* Feld 38 - Name 1
  rs_export-rese4 = ls_pssec-bsec-name1.
* Feld 39 - Strasse
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    CONCATENATE ls_pssec-bsec-land1 ls_pssec-bsec-pstlz
                ls_pssec-bsec-ort01
           INTO rs_export-rese5 SEPARATED BY c_semicolon.
  ELSE.
    rs_export-rese5 = ls_pssec-bsec-stras.
  ENDIF.
* Feld 40 - Zahlstelle
  rs_export-zhlst = abap_off.
* Feld 41 - Urkassenzeichen
  rs_export-xblnr = abap_off.
* Feld 42 - Begründung
  rs_export-rese6 = ls_pso02-bktxt.
* Feld 43 - Begründung
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    CONCATENATE ls_pssec-bsec-name1 ls_pssec-bsec-land1
                ls_pssec-bsec-pstlz ls_pssec-bsec-ort01
           INTO rs_export-rese7 SEPARATED BY c_semicolon.
  ENDIF.
* Feld 44 - Begründung
  rs_export-dnstl = abap_off.
* Feld 45 - leer
  rs_export-ftext = abap_off.
* Feld 46 - Name 2
  IF NOT ls_pssec-bsec-land1 EQ lc_land_de.
    MOVE ls_pssec-bsec-stras TO rs_export-name2(27).
  ELSE.
    MOVE: ls_pssec-bsec-name2 TO rs_export-name2(27),
          ls_pssec-bsec-name3 TO rs_export-name2+27(27).
  ENDIF.
* Feld 47 - leer
  rs_export-buchz = abap_off.
* Feld 48 - leer
  rs_export-vehhj = abap_off.
* Feld 49 - Dienststelle
  rs_export-dstnr = c_dstnr_3101.
* Feld 50 - Verfahrenskennzeichen
  rs_export-verkz = c_verkz_sap.
* Feld 51 - Länderschlüssel
  rs_export-land1 = abap_off.
* Feld 52 - Postleitzahl
  rs_export-pstlz = abap_off.
* Feld 53 - Betrag
  rs_export-fbetr = abap_off.
* Feld 54 - Umrechnungskurs
  rs_export-kursf = abap_off.
* Feld 55 - Gesamtbetrag
  rs_export-gbbtr = abap_off.
* Feld 56 - Währung
  rs_export-gwaer = abap_off.
* Feld 57 - Bankname 1
  rs_export-bnknm1 = abap_off.
* Feld 58 - Bankname 2
  rs_export-bnknm2 = abap_off.
* Feld 59 - Straße der Bank
  rs_export-bnkstr = abap_off.
* Feld 60 - Ort der Bank
  rs_export-bnkort = abap_off.
* Feld 61 - Weisungscode
  rs_export-wsgkey = abap_off.
* Feld 62 - Text
  rs_export-kvkey = abap_off.
* Feld 63 - BIC (SWIFT) - z.Z. nicht von HAMISSA (Einnahmen)
* unterstützt
  CASE iv_btyp.
    WHEN c_btyp_all.
      IF NOT ls_bnka-swift IS INITIAL AND
         NOT ls_iban-iban IS INITIAL.
        rs_export-biczp = build_bic_key( ls_bnka-swift ).
        MOVE lc_init_c18 TO rs_export-rese3(18).
      ENDIF.
  ENDCASE.
* Feld 64 - BEI
  rs_export-beizp = abap_off.
* Feld 65 - IBAN - z.Z. nicht von HAMISSA (Einnahmen)
* unterstützt
  CASE iv_btyp.
    WHEN c_btyp_all.
      IF NOT ls_iban-iban IS INITIAL AND
         NOT ls_bnka-swift IS INITIAL.
        rs_export-iban = ls_iban-iban.
        MOVE lc_init_c18 TO rs_export-rese3(18).
      ENDIF.
  ENDCASE.
* Feld 66 - Anzahl
  rs_export-anzms = abap_off.
* Feld 67 - Straße der Bank
  rs_export-vtrag = abap_off.
* Feld 68 - Ort Unterschrift
  rs_export-osign = abap_off.
* Feld 69 - Datum Unterschrift
  rs_export-dsign = abap_off.
* Feld 70 - Identifier
  rs_export-ident = abap_off.
* Feld 71 - Status Mandat
  rs_export-mstat = abap_off.
* Feld 72 - Ursprungsmandat
  rs_export-mgaen = abap_off.
* Feld 73 - Druckdatum
  rs_export-prdat = abap_off.
* Feld 74 - Druckertyp
  rs_export-vtrag = abap_off.

ENDMETHOD.                    "map_all_data


*----------------------------------------------------------------------*
* Methode MAP_MER_MAE_DATA
*----------------------------------------------------------------------*
METHOD map_mer_mae_data.

* lokale Datendeklaration
  CONSTANTS: lc_index_1   TYPE i VALUE 1,
             lc_len_1     TYPE i VALUE 1,
             lc_len_2     TYPE i VALUE 2,
             lc_len_4     TYPE i VALUE 4,
             lc_len_8     TYPE i VALUE 8,
             lc_offset_1  TYPE i VALUE 1,
             lc_offset_12 TYPE i VALUE 12,
             lc_merkm_a   TYPE c LENGTH 1 VALUE 'A',
             lc_init_c18  TYPE c LENGTH 18 VALUE IS INITIAL,
             lc_par_glinr TYPE zlsa_parameter-z_key VALUE 'GLINR'.

  DATA: l_btyp  TYPE zbtyp.

  DATA: ls_pso02  LIKE LINE OF it_pso02,
        ls_pssec  LIKE LINE OF it_pssec,
        ls_iban   TYPE tiban,
        ls_bnka   TYPE bnka,
        ls_t500p  TYPE t500p.

  DATA: ls_pcharge_md TYPE ztpa_pcharge_md,
        ls_parameter  TYPE zlsa_parameter.

* Importtabellen lesen
  READ TABLE: it_pso02 INTO ls_pso02 INDEX lc_index_1,
              it_pssec INTO ls_pssec INDEX lc_index_1.

* Daten zu IBAN und SWIFT ermitteln
  IF NOT ls_pssec-bsec-bankl IS INITIAL.
    get_iban_swift_data( EXPORTING iv_banks  = ls_pssec-bsec-banks
                                   iv_bankl  = ls_pssec-bsec-bankl
                                   iv_bankn  = ls_pssec-bsec-bankn
                                   iv_bkont  = ls_pssec-bsec-bkont
                         IMPORTING es_iban   = ls_iban
                                   es_bnka   = ls_bnka ).
  ENDIF.

* Stammdaten zur Buchung von Gebühren lesen
  IF NOT ls_pso02-kunnr IS INITIAL AND
     NOT ls_pso02-kunnr EQ c_kunnr_cpd.
    SELECT SINGLE * FROM ztpa_pcharge_md INTO ls_pcharge_md
     WHERE pernr EQ ( SELECT pernr FROM knb1
                       WHERE bukrs EQ ls_pso02-bukrs AND
                             kunnr EQ ls_pso02-kunnr ) AND
           kunnr EQ ls_pso02-kunnr AND
           begda LE ls_pso02-budat AND
           endda GE ls_pso02-budat.
  ENDIF.

* im Vorfeld Prüfen des Buchungstyps (MER-Satz darf nur erzeugt wer-
* den, wenn noch kein Export des Mandats erfolgt ist; MAE-Satz ist
* zu erstellen, wenn es eine Änderung an den Stammdaten des Mandats
* (IBAN) oder Debitors (Adressdaten) gibt
  SELECT COUNT(*) FROM ztpa_pcharge_md UP TO 1 ROWS
   WHERE pernr EQ ( SELECT pernr FROM knb1
                     WHERE bukrs EQ ls_pso02-bukrs AND
                           kunnr EQ ls_pso02-kunnr ) AND
         kunnr EQ ls_pso02-kunnr AND
         xexpo EQ abap_on.
  IF NOT sy-subrc IS INITIAL.
    l_btyp = c_btyp_mer.
  ELSE.
    l_btyp = c_btyp_mae.
    check_changes_mandat( EXPORTING is_pso02 = ls_pso02
                           CHANGING cv_btyp  = l_btyp ).
  ENDIF.
  IF l_btyp IS INITIAL.
*-- es gab keine relevante Änderung oder Neuanlage, trotzdem soll
*-- das Export-Kennz. gesetzt werden
    IF NOT ls_pcharge_md IS INITIAL.
      ls_pcharge_md-xexpo = abap_on.
      ls_pcharge_md-expdt = ls_pso02-cpudt.

      MODIFY ztpa_pcharge_md FROM ls_pcharge_md.
      IF sy-subrc IS INITIAL.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.
    RETURN.
  ELSE.
    IF NOT ls_pcharge_md IS INITIAL.
      ls_pcharge_md-xexpo = abap_on.
      ls_pcharge_md-expdt = ls_pso02-cpudt.

      MODIFY ztpa_pcharge_md FROM ls_pcharge_md.
      IF sy-subrc IS INITIAL.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.
  ENDIF.

* Feld 1 - Buchungstyp
  rs_export-btyp = l_btyp.
* Feld 2 - Merkmal
  rs_export-merkm = lc_merkm_a.
* Feld 3 - Firma
  rs_export-firma = abap_off.
* Feld 4 - HHJ
  rs_export-hhj = is_data-gjahr.
* Feld 5 - Quelle
  rs_export-quelle = abap_off.
* Feld 6 - Belegnummer
  rs_export-belnr = is_data-refbn+2(lc_len_8).
* Feld 7 - Belegposition
  rs_export-blpos = c_count.
* Feld 8 - Userkennzeichen
  rs_export-kerfas = c_usrkz.
* Feld 9 - Bereich (Feld temporär füllen)
  rs_export-berei = is_data-fipex(lc_len_2).
* Feld 10 - Kapitel
  rs_export-kapit = abap_off.
* Feld 11 - Titel
  rs_export-titel = abap_off.
* Feld 12 - Org.einheit
  rs_export-orgeh = is_data-fistl(lc_len_8).
* Feld 13 - Unterkonto
  rs_export-unkto = abap_off.
* Feld 14 - Referenznummer
  rs_export-refnr = abap_off.
* Feld 15 - Betrag
  rs_export-betr1 = abap_off.
* Feld 16 - Kombinationsfeld
  rs_export-betr2 = abap_off.
* Feld 17 - Fälligkeitsdatum
  rs_export-faedt = abap_off.
* Feld 18 - Referenz SST
  rs_export-betr3 = abap_off.
* Feld 19 - Art der Forderung (Mahnschlüssel)
  rs_export-txtsl = abap_off.
* Feld 20 - Betrag
  rs_export-betr4 = abap_off.
* Feld 21 - Be-/Entlastungskennzeichen
  rs_export-belkz = abap_off.
* Feld 22 - Land u. PSTLZ
  rs_export-rese1 = abap_off.
* Feld 23 - Einmallieferant
  rs_export-lifnr = abap_off.
* Feld 24 - Ort
  rs_export-rese2 = abap_off.
* Feld 25 - lfd. Nummer Bankverbindung
  rs_export-bnknr = abap_off.
* Feld 26 - Bankleitzahl und Kontonr.
  rs_export-rese3 = abap_off.
* Feld 27 - Kasse
  rs_export-kasse = abap_off.
* Feld 28 - Aktenzeichen
  rs_export-aktkz = abap_off.
* Feld 29 - Begründung
  rs_export-grund = ls_pso02-sgtxt.
* Feld 30 - Begründung
  rs_export-buchn = abap_off.
* Feld 31 - Währung
  rs_export-lfdnr = abap_off.
* Feld 32 - Belegkassenzeichen
  rs_export-kassz = abap_off.
* Feld 33 - Status der Übernahme
  rs_export-bnstat = c_bnstat_0.
* Feld 34 - Übernahme-User
  rs_export-bnuser = abap_off.
* Feld 35 - Übernahmedatum
  rs_export-bndat = abap_off.
* Feld 36 - Übernahmezeit
  rs_export-bnzeit = abap_off.
* Feld 37 - DHB-Fehlercode
  rs_export-bnerr = abap_off.
* Feld 38 - Name 1
  rs_export-rese4 = abap_off.
* Feld 39 - Strasse
  rs_export-rese5 = abap_off.
* Feld 40 - Zahlstelle
  rs_export-zhlst = abap_off.
* Feld 41 - Urkassenzeichen
  rs_export-xblnr = abap_off.
* Feld 42 - Begründung
  rs_export-rese6 = abap_off.
* Feld 43 - Begründung
  rs_export-rese7 = abap_off.
* Feld 44 - Begründung
  rs_export-dnstl = is_data-fistl(lc_len_4).
* Feld 45 - leer
  rs_export-ftext = abap_off.
* Feld 46 - Name 2
  rs_export-name2 = abap_off.
* Feld 47 - leer
  rs_export-buchz = abap_off.
* Feld 48 - leer
  rs_export-vehhj = abap_off.
* Feld 49 - Dienststelle
  rs_export-dstnr = c_dstnr_3101.
* Feld 50 - Verfahrenskennzeichen
  rs_export-verkz = c_verkz_sap.
* Feld 51 - Länderschlüssel
  rs_export-land1 = abap_off.
* Feld 52 - Postleitzahl
  rs_export-pstlz = abap_off.
* Feld 53 - Betrag
  rs_export-fbetr = abap_off.
* Feld 54 - Umrechnungskurs
  rs_export-kursf = abap_off.
* Feld 55 - Gesamtbetrag
  rs_export-gbbtr = abap_off.
* Feld 56 - Währung
  rs_export-pstlz = abap_off.
* Feld 57 - Bankname 1
  rs_export-bnknm1 = abap_off.
* Feld 58 - Bankname 2
  rs_export-bnknm2 = abap_off.
* Feld 59 - Straße der Bank
  rs_export-bnkstr = abap_off.
* Feld 60 - Ort der Bank
  rs_export-bnkort = abap_off.
* Feld 61 - Weisungscode
  rs_export-wsgkey = abap_off.
* Feld 62 - Text
  rs_export-kvkey = abap_off.
* Feld 63 - BIC (SWIFT)
  IF NOT ls_bnka-swift IS INITIAL AND
     NOT ls_iban-iban IS INITIAL  AND
     NOT rs_export-rese3+18(1) EQ 'j'.
    rs_export-biczp = build_bic_key( ls_bnka-swift ).
    MOVE lc_init_c18 TO rs_export-rese3(18).
  ENDIF.
* Feld 64 - BEI
  rs_export-beizp = abap_off.
* Feld 65 - IBAN
  IF NOT ls_iban-iban IS INITIAL  AND
     NOT ls_bnka-swift IS INITIAL AND
     NOT rs_export-rese3+18(1) EQ 'j'.
    rs_export-iban = ls_iban-iban.
    MOVE lc_init_c18 TO rs_export-rese3(18).
  ENDIF.
* Feld 66 - Anzahl
  rs_export-anzms = abap_off.
* Feld 67 - Beschreibung Vertrag
  IF NOT ls_pcharge_md-mndid IS INITIAL.
    rs_export-vtrag = ls_pcharge_md-mndid.
  ELSE.
    rs_export-vtrag = abap_off.
  ENDIF.
* Feld 68 - Ort Unterschrift
  IF NOT ls_pcharge_md-pernr IS INITIAL.
    SELECT SINGLE * FROM t500p INTO ls_t500p
     WHERE persa EQ ( SELECT werks FROM pa0001
                       WHERE pernr EQ ls_pcharge_md-pernr AND
                             begda LE ls_pso02-cpudt      AND
                             endda GE ls_pso02-cpudt ).
    IF sy-subrc IS INITIAL.
      rs_export-osign = ls_t500p-ort01.
    ENDIF.
  ELSEIF NOT ls_pcharge_md-kunnr IS INITIAL.
    SELECT SINGLE * FROM t500p INTO ls_t500p
     WHERE persa EQ ( SELECT begru FROM kna1
                       WHERE kunnr EQ ls_pcharge_md-kunnr ).
    IF sy-subrc IS INITIAL.
      rs_export-osign = ls_t500p-ort01.
    ENDIF.

  ELSE.
    rs_export-osign = abap_off.
  ENDIF.
* Feld 69 - Datum Unterschrift
  IF NOT ls_pcharge_md-mnddt IS INITIAL.
    IF rs_export-btyp EQ c_btyp_mer.
      rs_export-dsign = ls_pcharge_md-mnddt.
    ELSE.
      rs_export-dsign = abap_off.
    ENDIF.
  ELSE.
    rs_export-dsign = abap_off.
  ENDIF.
* Feld 70 - Identifier
  SELECT SINGLE * FROM zlsa_parameter INTO ls_parameter
                 WHERE bukrs EQ ls_pso02-bukrs AND
                       fikrs EQ ref_const->c_fikrs_tpa AND
                       z_key EQ lc_par_glinr.
  IF sy-subrc IS INITIAL.
    rs_export-ident = ls_parameter-z_wert.
  ELSE.
    rs_export-ident = abap_off.
  ENDIF.
* Feld 71 - Status Mandat
  rs_export-mstat = abap_off.
* Feld 72 - Ursprungsmandat
  rs_export-mgaen = abap_off.
* Feld 73 - Druckdatum
  rs_export-prdat = abap_off.
* Feld 74 - Nutzer des Drucks
  rs_export-drusr = abap_off.
* Feld 75 - Mandatsreferenz
  IF NOT ls_pcharge_md-mndid IS INITIAL.
    rs_export-mndid = ls_pcharge_md-mndid.
  ELSE.
    rs_export-mndid = abap_off.
  ENDIF.
* Feld 76 - Steuerungskennzeichen Mandat
  rs_export-strkz = c_kz_r.
* Feld 77 - Frist BVA
  rs_export-bvafr = abap_off.
* Feld 78 - Mandatgeber Name (siehe Feld 38 SST-Satz)
  rs_export-mndnm = ls_pssec-bsec-name1.
* Feld 79 - Mandatgeber Ort
  IF NOT ls_pcharge_md-kunnr IS INITIAL.
    CONCATENATE ls_pssec-bsec-land1(lc_len_1)
                ls_pssec-bsec-pstlz
          INTO rs_export-mndort SEPARATED BY space.
    rs_export-mndort+lc_offset_12 = ls_pssec-bsec-ort01.
  ELSE.
    rs_export-mndort = abap_off.
  ENDIF.
* Feld 80 - Mandatgeber Straße
  IF NOT ls_pcharge_md-kunnr IS INITIAL.
    rs_export-mndstr = ls_pssec-bsec-stras.
  ELSE.
    rs_export-mndstr = abap_off.
  ENDIF.
* Feld 81 - Leerfeld
  rs_export-leer81 = abap_off.
* Feld 82 - Mandatgeber Straße
  rs_export-leer82 = abap_off.

ENDMETHOD.                    "map_mer_mae_data


*----------------------------------------------------------------------*
* Methode CHECK_CHANGES_MANDAT
*----------------------------------------------------------------------*
METHOD check_changes_mandat.

* lokale Datendeklaration
  CONSTANTS: lc_objcl_debi   TYPE cdhdr-objectclas VALUE 'DEBI',
             lc_tabn_kna1    TYPE cdpos-tabname VALUE 'KNA1',
             lc_fdname_name1 TYPE cdpos-fname VALUE 'NAME1',
             lc_fdname_stras TYPE cdpos-fname VALUE 'STRAS',
             lc_fdname_pstlz TYPE cdpos-fname VALUE 'PSTLZ',
             lc_fdname_ort01 TYPE cdpos-fname VALUE 'ORT01',
             lc_lines_1      TYPE i VALUE 1.

  DATA: l_objid   TYPE cdhdr-objectid,
        lr_udate  TYPE RANGE OF cdhdr-udate,
        lr_fdname TYPE RANGE OF cdpos-fname.

  DATA: lt_pcharge_md  TYPE STANDARD TABLE OF ztpa_pcharge_md,
        lt_cdred       TYPE STANDARD TABLE OF cdred,
        ls_pcharge_md  LIKE LINE OF lt_pcharge_md,
        ls_pcharge_prv LIKE LINE OF lt_pcharge_md,
        ls_pcharge_itm TYPE ztpa_pcharge_itm.

* Mandatsdaten nachlesen
  SELECT * FROM ztpa_pcharge_md
    INTO CORRESPONDING FIELDS OF TABLE lt_pcharge_md
   WHERE pernr EQ ( SELECT pernr FROM knb1
                     WHERE bukrs EQ is_pso02-bukrs AND
                           kunnr EQ is_pso02-kunnr ) AND
         kunnr EQ is_pso02-kunnr
   ORDER BY begda endda.

* gibt es Änderungen hinsichtlich der IBAN oder der Mandatsreferenz
* zwischen dem aktuellen Satz und dem Vorgängersatz
  IF lines( lt_pcharge_md ) GT lc_lines_1.
    LOOP AT lt_pcharge_md INTO ls_pcharge_md
         WHERE kunnr EQ is_pso02-kunnr AND
               begda LE is_pso02-budat AND
               endda GE is_pso02-budat.
      EXIT.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
      LOOP AT lt_pcharge_md INTO ls_pcharge_prv
           WHERE kunnr EQ ls_pcharge_md-kunnr AND
                 pernr EQ ls_pcharge_md-pernr AND
                 endda LT ls_pcharge_md-begda AND
                 begda LT ls_pcharge_md-endda.
        EXIT.
      ENDLOOP.
      IF sy-subrc IS INITIAL.
        IF NOT ls_pcharge_prv-iban EQ ls_pcharge_md-iban.
          cv_btyp = c_btyp_mae.
        ELSE.
          CLEAR cv_btyp.
        ENDIF.
        IF NOT ls_pcharge_prv-mndid EQ ls_pcharge_md-mndid.
          cv_btyp = c_btyp_mer.
          RETURN.
        ENDIF.
      ELSE.
        CLEAR cv_btyp.
      ENDIF.
    ENDIF.

    IF NOT cv_btyp IS INITIAL.
      RETURN.
    ENDIF.
  ENDIF.

* gab es Änderungen am Debitor im Zeitraum zwischen der aktuellen
* Buchung und dem letzten Schnittstellenlauf
  SELECT * FROM ztpa_pcharge_itm
           INTO CORRESPONDING FIELDS OF ls_pcharge_itm
           UP TO 1 ROWS
           WHERE pernr EQ ( SELECT pernr FROM knb1
                             WHERE bukrs EQ is_pso02-bukrs AND
                                   kunnr EQ is_pso02-kunnr ) AND
                 kunnr EQ is_pso02-kunnr AND
                 budat LT is_pso02-budat
           ORDER BY budat DESCENDING.
   ENDSELECT.
   IF sy-subrc IS INITIAL.
*---- ObjektId setzen
      l_objid = is_pso02-kunnr.

*---- Range für Prüfung Änderungen
      ref_help->set_range_value(
                  EXPORTING iv_value_low  = ls_pcharge_itm-budat
                            iv_value_high = is_pso02-budat
                   CHANGING ct_range      = lr_udate ).

*---- Range für zu prüfende Felder
      ref_help->set_range_value(
                  EXPORTING iv_value_low = lc_fdname_name1
                   CHANGING ct_range     = lr_fdname ).
      ref_help->set_range_value(
                  EXPORTING iv_value_low = lc_fdname_stras
                   CHANGING ct_range     = lr_fdname ).
      ref_help->set_range_value(
                  EXPORTING iv_value_low = lc_fdname_pstlz
                   CHANGING ct_range     = lr_fdname ).
      ref_help->set_range_value(
                  EXPORTING iv_value_low = lc_fdname_ort01
                   CHANGING ct_range     = lr_fdname ).

      CALL FUNCTION 'CHANGEDOCUMENT_READ'
        EXPORTING   date_of_change  = ls_pcharge_itm-budat
                    objectclass     = lc_objcl_debi
                    objectid        = l_objid
                    tablename       = lc_tabn_kna1
                    date_until      = is_pso02-budat
        TABLES      editpos         = lt_cdred
        EXCEPTIONS  error_message   = 4
                    OTHERS          = 5.

      IF NOT sy-subrc IS INITIAL.
        CLEAR cv_btyp. RETURN.
      ELSE.
        LOOP AT lt_cdred TRANSPORTING NO FIELDS
             WHERE objectid EQ l_objid AND
                   udate    IN lr_udate AND
                   tabname  EQ lc_tabn_kna1 AND
                   fname    IN lr_fdname.
          EXIT.
        ENDLOOP.
        IF sy-subrc IS INITIAL.
          cv_btyp = c_btyp_mae.
          RETURN.
        ELSE.
          CLEAR cv_btyp.
        ENDIF.
      ENDIF.
   ELSE.
     CLEAR cv_btyp. RETURN.
   ENDIF.

ENDMETHOD.


ENDCLASS.                   "LCL_MAIN IMPLEMENTATION.

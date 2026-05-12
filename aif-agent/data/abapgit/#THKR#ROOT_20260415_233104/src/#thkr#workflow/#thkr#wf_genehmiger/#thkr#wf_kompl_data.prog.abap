*&---------------------------------------------------------------------*
*& Include          /THKR/WF_KOMPL_DATA
*&---------------------------------------------------------------------*

TABLES: hrp1001, hrrhas, hrp1000, t777o, hrp9805, hrp9808, pa0001, sscrfields.
TYPE-POOLS icon.

DATA ls_textfield LIKE smp_dyntxt.

TYPES: lt_agr_1251 TYPE STANDARD TABLE OF agr_1251 WITH DEFAULT KEY,
       lt_agr_1252 TYPE STANDARD TABLE OF agr_1252 WITH DEFAULT KEY,
       ty_ur12c    TYPE STANDARD TABLE OF znsi_agr_ur12c WITH DEFAULT KEY.



TYPES: BEGIN OF struct_hrp_join_s.                    " 'S'-Struktur-Join
         INCLUDE STRUCTURE hrp1001.
TYPES:   short TYPE hrp1000-short,
         plsty TYPE hrp9808-plsty,
         "kz_virtuell TYPE hrp9805-kz_virtuell,
       END OF struct_hrp_join_s.

TYPES: BEGIN OF struct_hrp_join_p.                   " 'P'-Struktur-Join
         INCLUDE STRUCTURE hrp1001.
TYPES:
         usrid TYPE pa0105-usrid,
       END OF struct_hrp_join_p.

TYPES: BEGIN OF struct_hrp_join_o.                   " 'O'-Struktur-Join
         INCLUDE STRUCTURE hrp1001.
TYPES:   short           TYPE hrp1000-short,
         ort01           TYPE hrp1028-ort01,
         stras           TYPE hrp1028-stras,
         pstlz           TYPE hrp1028-pstlz,
         telnr           TYPE hrp1028-telnr,
         land1           TYPE hrp1028-land1,
         adrnr           TYPE hrp1028-adrnr,
         strs2           TYPE hrp1028-strs2,
         smtp_addr_forms TYPE hrp9814-smtp_addr_forms,
         "zzmail  TYPE hrp1032-zzmail,
       END OF struct_hrp_join_o.

TYPES: BEGIN OF struct_ber_om,
         otype TYPE otype,
         objid TYPE hrobjid,
         bukrs TYPE bukrs,
         persa TYPE persa,
         btrtl TYPE btrtl,
       END OF struct_ber_om.

DATA  lv_typ_bez    TYPE t777o-otext.
DATA: lt_hrp_join_o        TYPE TABLE OF struct_hrp_join_o,
      lt_hrp_cds_o         TYPE TABLE OF struct_hrp_join_o,
      ls_hrp_join_o        TYPE struct_hrp_join_o,
      lt_hrp_join_o_gesamt TYPE TABLE OF struct_hrp_join_o.

DATA: ls_hrp_join_s        TYPE struct_hrp_join_s,
      lt_hrp_join_s        TYPE TABLE OF struct_hrp_join_s,
      lt_hrp_join_s_gesamt TYPE TABLE OF struct_hrp_join_s.

DATA: lt_hrp_join_p        TYPE TABLE OF struct_hrp_join_p,
      ls_hrp_join_p        TYPE struct_hrp_join_p,
      lt_hrp_join_p_gesamt TYPE TABLE OF struct_hrp_join_p.

CONSTANTS: k_icon_green(4) VALUE icon_led_green,  " @5B@                  " Icons-Ampel(Rot,Grün,Gelb)
           k_icon_red(4)   VALUE icon_led_red,    " @5C@
           k_icon_yellow   TYPE  icon_d VALUE '@5D@'.

DATA: lref_table        TYPE REF TO cl_salv_table,
      lref_message      TYPE REF TO cx_salv_msg,
      display_settings  TYPE REF TO cl_salv_display_settings,
      o_col             TYPE REF TO cl_salv_column,
      lref_table2       TYPE REF TO cl_salv_table,
      lref_message2     TYPE REF TO cx_salv_msg,
      display_settings2 TYPE REF TO cl_salv_display_settings,
      o_col2            TYPE REF TO cl_salv_column.

DATA: gr_funct       TYPE REF TO cl_salv_table,
      gr_funct_extra TYPE REF TO cl_salv_functions.
DATA: it_org_str_tab TYPE TABLE OF objec,
      it_struc_tab   TYPE TABLE OF struc,
      it_gdstr_tab   TYPE TABLE OF gdstr.

DATA: lt_hrp1001_o        TYPE TABLE OF hrp1001,
      lt_hrp1001_o_gesamt TYPE TABLE OF hrp1001,
      lt_hrp1028_o        TYPE TABLE OF hrp1028,
      lt_hrp1028_o_gesamt TYPE TABLE OF hrp1028,
      lt_hrp1032_o        TYPE TABLE OF hrp1032,
      lt_hrp1032_o_gesamt TYPE TABLE OF hrp1032,
      lt_hrp1001_s        TYPE TABLE OF hrp1001,
      lt_hrp1001_s_gesamt TYPE TABLE OF hrp1001,
      lt_hrp1001_p        TYPE TABLE OF hrp1001,
      lt_hrp1001_p_gesamt TYPE TABLE OF hrp1001.

DATA: ls_selectopt       TYPE hrp1001-objid,
      lt_selectopt       TYPE TABLE OF hrp1001-objid,
      ls_selectopt2      TYPE hrp1001-objid,
      ls_selectopt3      TYPE hrp1001-objid,
      lt_selectopt2      TYPE TABLE OF hrp1001-objid,
      lt_selectopt_fehlt TYPE TABLE OF hrp1001-objid,
      ls_selectopt_pers  TYPE pa0105-pernr,
      lt_selectopt_pers  TYPE TABLE OF pa0105-pernr.

DATA  lv_top_down TYPE t777v-rinvt.
DATA: it_attrib      TYPE STANDARD TABLE OF pt1222,
      it_attrib_ext  TYPE STANDARD TABLE OF omattvalrt,
      it_attrb       TYPE STANDARD TABLE OF pt1222,
      it_attrb_ext   TYPE STANDARD TABLE OF omattvalrt,
      lt_attrib2     TYPE STANDARD TABLE OF pt1222,
      lt_attrib_ext2 TYPE STANDARD TABLE OF omattvalrt,
      ls_attrib_ext2 TYPE omattvalrt,
      lt_attrib3     TYPE STANDARD TABLE OF pt1222,
      lt_attrb4      TYPE STANDARD TABLE OF pt1222,
      lt_attrib_ext3 TYPE STANDARD TABLE OF omattvalrt,
      ls_attrib_ext3 TYPE omattvalrt.

DATA: lt_rolle_name_table  TYPE TABLE OF znsi_agr_ur12c,
      lt_rolle_name_table2 TYPE TABLE OF znsi_agr_ur12c.

TYPES: BEGIN OF struc_type_attr,
         nummer         TYPE i,
         objekttyp      TYPE hrp1001-otype,
         objektid       TYPE hrp1001-objid.
         INCLUDE STRUCTURE ls_attrib_ext2.
TYPES:   zfunk_no_exist TYPE kreuz,
         condition      TYPE z_om_dte_attr_cond,
       END OF struc_type_attr.

TYPES: BEGIN OF struc_pr_zpgsbr_werks,
         nummer    TYPE i,
         objekttyp TYPE hrp1001-otype,
         objektid  TYPE hrp1001-objid,
         attrib    TYPE om_attrib,
         low       TYPE om_attrval,
         high      TYPE om_attrvto,
       END OF struc_pr_zpgsbr_werks.

DATA: ls_pr_zpgsbr_werks  TYPE struc_pr_zpgsbr_werks,
      lt_pr_zpgsbr_werks  TYPE TABLE OF struc_pr_zpgsbr_werks,
      ls_pr_zpgsbr_werks2 TYPE struc_pr_zpgsbr_werks,
      lt_pr_zpgsbr_werks2 TYPE TABLE OF struc_pr_zpgsbr_werks.

TYPES: BEGIN OF struc_type_attr_erw.
         INCLUDE TYPE struc_type_attr.
TYPES:   vorhanden TYPE kreuz,
         status    TYPE icon_d,
         text      TYPE text200,
       END OF struc_type_attr_erw.

TYPES: BEGIN OF struc_type_attr_tmp,
         attrib    TYPE  om_attrib,
         condition TYPE /THKR/DTE_WF_ATTR_COND,
         funktion  TYPE /THKR/DTE_WF_FUNKTION,
       END OF struc_type_attr_tmp.

TYPES struc_attr_tmp TYPE STANDARD TABLE OF struc_type_attr_tmp WITH DEFAULT KEY.

DATA lv_nummer TYPE int4.
DATA lt_r1_wrt_attr  TYPE TABLE OF struc_type_attr_tmp.

DATA:
  " ls_struc_attr                TYPE struc_type_attr,
  ls_struc_attr                  TYPE /THKR/S_struc_type_attr_erw,
  lt_struc_attr                  TYPE TABLE OF struc_type_attr,
  lt_struc_attr_gesamt           TYPE TABLE OF struc_type_attr,
  ls_struc_attr_erw              TYPE struc_type_attr_erw,
  " lt_struc_attr_erw TYPE TABLE OF struc_type_attr_erw,
*      lt_struc_attr_gesamt_erw       TYPE TABLE OF struc_type_attr_erw,
*      ls_struc_attr_gesamt_erw       TYPE  struc_type_attr_erw,
  "
  lt_struc_attr_gesamt_erw       TYPE /THKR/T_struc_type_attr_erw_tt,
  ls_struc_attr_gesamt_erw       TYPE /THKR/S_struc_type_attr_erw,
  "
*  lt_struc_attr_gesamt_erw_end   TYPE TABLE OF struc_type_attr_erw,
  "
  lt_struc_attr_gesamt_erw_end   TYPE /THKR/T_struc_type_attr_erw_tt,
  "
  lt_struc_attr_gesamt_erw2      TYPE /THKR/T_struc_type_attr_erw_tt,
  ls_struc_attr_gesamt_erw2      TYPE /THKR/S_struc_type_attr_erw,
  "
*  lt_struc_attr_gesamt_erw_end2  TYPE TABLE OF struc_type_attr_erw,
  "
  lt_struc_attr_gesamt_erw_end2  TYPE /THKR/T_struc_type_attr_erw_tt,
  "
*  lt_struc_attr_erw_end_pr       TYPE TABLE OF struc_type_attr_erw,
  "
  lt_struc_attr_erw_end_pr       TYPE  /THKR/T_struc_type_attr_erw_tt,
  "
  lt_struc_attr_erw_end2_pr      TYPE /THKR/T_struc_type_attr_erw_tt,
  ls_struc_attr2                 TYPE /THKR/S_struc_type_attr_erw,
  lt_struc_attr2                 TYPE TABLE OF struc_type_attr,
  lt_struc_attr_gesamt2          TYPE TABLE OF struc_type_attr,
  "
*  lt_struc_attr_gesamt_erw_end_f TYPE TABLE OF struc_type_attr_erw.
  "
  lt_struc_attr_gesamt_erw_end_f TYPE /THKR/T_struc_type_attr_erw_tt.
"
FIELD-SYMBOLS <fs_tabelle> TYPE table.
DATA: ld_act_plvar     TYPE objec-plvar,
      lt_result_tab    TYPE TABLE OF swhactor,
      lt_result_objec  TYPE TABLE OF objec,
      lt_result_struc  TYPE TABLE OF struc,
      ld_act_plvar2    TYPE objec-plvar,
      lt_result_tab2   TYPE TABLE OF swhactor,
      lt_result_objec2 TYPE TABLE OF objec,
      lt_result_struc2 TYPE TABLE OF struc.

DATA: ld_act_plvar_pr     TYPE objec-plvar,
      lt_result_tab_pr    TYPE TABLE OF swhactor,
      lt_result_objec_rp  TYPE TABLE OF objec,
      lt_result_struc_pr  TYPE TABLE OF struc,
      lt_result_tab_pr2   TYPE TABLE OF swhactor,
      lt_result_objec_rp2 TYPE TABLE OF objec,
      lt_result_struc_pr2 TYPE TABLE OF struc,
      lt_result_tab_pr3   TYPE TABLE OF swhactor,
      lt_result_objec_rp3 TYPE TABLE OF objec,
      lt_result_struc_pr3 TYPE TABLE OF struc,
      lt_result_tab_pr4   TYPE TABLE OF swhactor,
      lt_result_objec_rp4 TYPE TABLE OF objec,
      lt_result_struc_pr4 TYPE TABLE OF struc.

DATA: lt_attr_om_st      TYPE TABLE OF pt1222,
      lt_attr_om_gesamt  TYPE TABLE OF pt1222,
      lt_attr_om_st2     TYPE TABLE OF pt1222,
      lt_attr_om_gesamt2 TYPE TABLE OF pt1222.

" Type für Prüfungsausgabe
TYPES: BEGIN OF struct_verif,
         abfrageindex  TYPE i,
         otype         TYPE hrp1001-otype,
         objid         TYPE hrp1001-objid,
         short         TYPE hrp1000-short,
         verb          TYPE t777v-rinvt,
         verkn_t_b     TYPE hrp1001-rsign,
         verkn_nr      TYPE hrp1001-relat,
         typ_des_obj   TYPE hrp1001-sclas,
         pruef_element TYPE hrp1001-sobid,
         subtyp        TYPE hrp1001-subty,
         plsty         TYPE hrp9808-plsty,
         "typ_bezeich  TYPE t777o-otext,
         vorhanden     TYPE kreuz,
         status        TYPE icon_d,
         text          TYPE text200,
       END OF struct_verif.


DATA: text_tpm          TYPE text200.

DATA: ls_struct_verif TYPE struct_verif,
      lt_struct_verif TYPE TABLE OF struct_verif.
DATA: lt_result_zom       TYPE TABLE OF struc_type_attr_tmp,
      ls_result_zom_tmp   TYPE struc_type_attr_tmp,
      lt_result_zom_tmp   TYPE TABLE OF struc_type_attr_tmp,
      lt_result_zom_tmp2s TYPE TABLE OF struc_type_attr_tmp.
DATA  lt_result_zom2 TYPE TABLE OF struc_type_attr_tmp.

DATA: id_old TYPE hrp1001-objid,
      index  TYPE struct_verif-abfrageindex VALUE 1.
DATA: lt_tab       TYPE TABLE OF struct_verif-pruef_element,
      lt_tab_rolle TYPE TABLE OF  struct_verif-pruef_element.

DATA: lt_options            TYPE TABLE OF rfc_db_opt,
      lt_fields             TYPE TABLE OF rfc_db_fld,
      lt_data_tb            TYPE TABLE OF tab512,
      lt_options_c13        TYPE TABLE OF rfc_db_opt,
      lt_fields_c13         TYPE TABLE OF rfc_db_fld,
      lt_data_tb_c13        TYPE TABLE OF tab512,
      lt_options_02xxl      TYPE TABLE OF rfc_db_opt,
      lt_fields_02xxl       TYPE TABLE OF rfc_db_fld,
      lt_data_tb_02xxl      TYPE TABLE OF tab512,
      lt_options_05xxl      TYPE TABLE OF rfc_db_opt,
      lt_fields_05xxl       TYPE TABLE OF rfc_db_fld,
      lt_data_tb_05xxl      TYPE TABLE OF tab512,
      lt_options_06xxl      TYPE TABLE OF rfc_db_opt,
      lt_fields_06xxl       TYPE TABLE OF rfc_db_fld,
      lt_data_tb_06xxl      TYPE TABLE OF tab512,
      lt_options_11xxl      TYPE TABLE OF rfc_db_opt,
      lt_fields_11xxl       TYPE TABLE OF rfc_db_fld,
      lt_data_tb_11xxl      TYPE TABLE OF tab512,

      lt_data_soll_str      TYPE TABLE OF stxh,
      lv_separator          TYPE char1 VALUE ';',
      lt_data_values        TYPE TABLE OF string,
      lt_options_rgsb       TYPE TABLE OF rfc_db_opt,
      lt_fields_rgsb        TYPE TABLE OF rfc_db_fld,
      lt_data_tb_rgsb       TYPE TABLE OF tab512,
      lt_data_soll_str_rgsb TYPE TABLE OF stxh,
      lv_separator_rgsb     TYPE char1 VALUE ';',
      lt_data_values_rgsb   TYPE TABLE OF string,

      ls_tab_result         TYPE znsi_agr_ur12c,
      lt_tab_result         TYPE TABLE OF znsi_agr_ur12c,
      ls_tab_result_13c     TYPE znsi_agr_ur13c,
      lt_tab_result_13c     TYPE TABLE OF znsi_agr_ur13c,
      ls_tab_result_02xxl   TYPE znsi_agr_02xxl,
      lt_tab_result_02xxl   TYPE TABLE OF znsi_agr_02xxl,
      ls_tab_result_05xxl   TYPE znsi_agr_05xxl,
      lt_tab_result_05xxl   TYPE TABLE OF znsi_agr_05xxl,
            ls_tab_result_06xxl_2   TYPE znsi_Agr_06xxl,
      lt_tab_result_06xxl_2   TYPE TABLE OF  znsi_Agr_06xxl,
      ls_tab_result_06xxl   TYPE /THKR/S_check_attrib_06xxl,
      lt_tab_result_06xxl   TYPE /THKR/T_CHECK_ATTRIB_06XXL,
      ls_tab_result_11xxl   TYPE znsi_agr_11xxl,
      lt_tab_result_11xxl   TYPE TABLE OF znsi_agr_11xxl.


DATA: lt_agr1252_tmp  TYPE TABLE OF agr_1252,
      lt_agr1252      TYPE TABLE OF agr_1252,
      lt_agr1252_tmp2 TYPE TABLE OF agr_1252,
      lt_agr12522     TYPE TABLE OF agr_1252.

DATA: lv_err_msg        TYPE char255,
*      lt_check_cust_o   TYPE TABLE OF zom_check_cust,
*      lt_check_cust_s   TYPE TABLE OF zom_check_cust,
*      lt_check_cust_p   TYPE TABLE OF zom_check_cust,
      lt_check_cust_a_o TYPE TABLE OF /THKR/OM_C_CUS_A.

DATA: lo_util  TYPE REF TO /THKR/CL_WF_UTIL,
      lv_btrg  TYPE rlwrt,
      lv_btrg2 TYPE rlwrt.

CONSTANTS: gc_tcode TYPE sytcode VALUE '/THKR/CHECK_KOMPL'.

*"reiter 3
TYPES: BEGIN OF ty_struc_comb,
         objid  TYPE hrp1001-objid,
         bukrs  TYPE char100,
         zpgsbr TYPE char100,
         zdstun TYPE char100,
       END OF ty_struc_comb.
*
*
*TYPES: BEGIN OF ty_lwids_tab,
*         mandt           TYPE  mandt,
*         lwid_logsys     TYPE  logsys,
*         leitweg_id      TYPE  /opt/route_id,
*         lwid_from       TYPE  dats,
*         lwid_to         TYPE  dats,
*         lwid_bukrs      TYPE  bukrs,
*         lwid_lvl_1      TYPE  zom_st_lwids-lwid_lvl_1,
*         lwid_lvl_2      TYPE  zom_st_lwids-lwid_lvl_2,
*         lwid_lvl_3      TYPE  zom_st_lwids-lwid_lvl_3,
*         lwid_lvl_4      TYPE  text50,
*         lwid_lvl_5      TYPE  text50,
*         lwid_sperr_kz   TYPE  boolean,
*         lwid_loesh_kz   TYPE  boolean,
*         lwid_linked     TYPE  boolean,
*         lwid_activated  TYPE  boolean,
*         lwid_uname      TYPE  syst_uname,
*         lwid_date       TYPE  dats,
*         lwid_time       TYPE  tims,
*         sbw_id          TYPE  string,
*         sbw_serko_uname TYPE  text20,
*         peppol_id       TYPE  string,
*         lwid_s          TYPE  zom_virt_s,
*       END OF ty_lwids_tab.
*
*
DATA: ls_ty_struc_comb     TYPE ty_struc_comb,
      lt_ty_struc_comb     TYPE STANDARD TABLE OF ty_struc_comb,

      o_salv               TYPE REF TO cl_salv_table,
      o_struct             TYPE REF TO cl_abap_structdescr,
      o_comp_tab           TYPE abap_component_tab,
      lv_col               TYPE REF TO cl_salv_column,

      it_att               TYPE STANDARD TABLE OF pt1222,
      it_att_ext           TYPE STANDARD TABLE OF omattvalrt,
      it_att_comb          TYPE STANDARD TABLE OF pt1222,
      it_att_ext_comb      TYPE STANDARD TABLE OF omattvalrt,
      lt_s_virt_with_rsgb  TYPE TABLE OF hrp1000-objid,
      lt_s_virt_with_combi TYPE TABLE OF hrp1000-objid,
*
*      ls_zbit_im_lwids     TYPE ty_lwids_tab,
*      lt_zbit_im_lwids     TYPE STANDARD TABLE OF ty_lwids_tab,
*      lt_lwids             TYPE STANDARD TABLE OF zom_st_lwids,
*      ls_lwids             TYPE  zom_st_lwids,
      lo_check_kompl       TYPE REF TO /THKR/CL_check_kompl,
      exc_ref              TYPE REF TO cx_root,
*
*
      rt_values            TYPE /THKR/T_OM_STRUC_TEXT,
      rt_values_erw        TYPE /THKR/T_OM_STRUC_TEXT_ERW,
      lt_range             TYPE RANGE OF om_attrib,
      tmp_plsty            TYPE text200,
    lv_attr_txt          TYPE t77omattrt-atext,
      arg_text             TYPE agr_title,
*
*
: lv_text  TYPE text200,
      lv_text2 TYPE text200.

FIELD-SYMBOLS: <fs_rt_values>  LIKE LINE OF rt_values,
               <fs_w_e>        TYPE icon_d,
               <fs_w_e2>       TYPE icon_d,
               <fs_text_plsty> TYPE text50,
               <fs_sndprn>     TYPE any.

DATA: lv_exist            TYPE abap_bool,
      lv_rfc_agr          TYPE text200,
      lv_dest             TYPE rfcdest,
      lv_muss             TYPE string,
      lv_kann             TYPE string,
*
      lv_ber_otype        TYPE otype,
      lt_ber_objid        TYPE RANGE OF hrp1001-objid,
      lt_sel_p_s_o        TYPE STANDARD TABLE OF hrobjid,
      lt_objid_ber        TYPE STANDARD TABLE OF objec,
      lt_objid_ber_s      TYPE STANDARD TABLE OF objec,
      lt_objid_ber2       TYPE STANDARD TABLE OF objec,
      lt_ber_om           TYPE STANDARD TABLE OF struct_ber_om,
      lt_ber_om_gesamt    TYPE STANDARD TABLE OF struct_ber_om,
      ls_ber_om           TYPE struct_ber_om,
      lv_wegid            TYPE gdstr-wegid,
      lt_hrp1008          TYPE STANDARD TABLE OF p1008,
      lt_hrp1008_g        TYPE STANDARD TABLE OF p1008,
      lv_distl_ok         TYPE abap_bool VALUE IS INITIAL,
      lv_objid            TYPE hrobjid,
*
      result_tab_ac       TYPE STANDARD TABLE OF swhactor,
      result_tab_ac2      TYPE STANDARD TABLE OF swhactor,
*

      lt_field_values     TYPE STANDARD TABLE OF pt1251,
      lt_field_values_tmp TYPE STANDARD TABLE OF agr_1251,
      lt_field_values_end TYPE STANDARD TABLE OF agr_1251,
      lt_znsi_agr_02xxl   TYPE TABLE OF znsi_agr_02xxl,
      ls_znsi_agr_02xxl   TYPE znsi_agr_02xxl,

      option              TYPE ddoption,
      attr_rng            TYPE rseloption.
*
*
*" Reiter 3
*
*
*
DATA: ls_selectopt_r3              TYPE hrp1001-objid,
      lt_selectopt_r3              TYPE TABLE OF hrp1001-objid,

      lt_attr_ext_r3               TYPE STANDARD TABLE OF omattvalrt,
*
      lt_struc_attr_gesamt_erw_r3  TYPE /THKR/T_STRUC_TYPE_ATTR_ERW_TT,
      lt_r3_gesamt                 TYPE /THKR/T_STRUC_TYPE_ATTR_ERW_TT,
      ls_struc_attr_gesamt_erw_r3  TYPE /THKR/S_STRUC_TYPE_ATTR_ERW,
*
      lt_agrs_r3                   TYPE STANDARD TABLE OF sobid,
      lt_agr1252_tmp_r3            TYPE TABLE OF agr_1252,
      lt_agr1252_r3                TYPE TABLE OF agr_1252,
      lt_field_values_r3           TYPE STANDARD TABLE OF pt1251,
      lt_field_values_tmp_r3       TYPE STANDARD TABLE OF pt1251,
      lt_field_values_end_r3       TYPE STANDARD TABLE OF /THKR/S_OM_AGR_1251_ERW,
      lt_field_values_end_r3_tmp   TYPE STANDARD TABLE OF /THKR/S_OM_AGR_1251_ERW,
*
      lt_field_values_r3_2         TYPE STANDARD TABLE OF pt1251,
      lt_field_values_tmp_r3_2     TYPE STANDARD TABLE OF pt1251,
      lt_field_values_end_r3_2     TYPE STANDARD TABLE OF /THKR/S_OM_AGR_1251_ERW,
      lt_field_values_end_r3_tmp_2 TYPE STANDARD TABLE OF /THKR/S_OM_AGR_1251_ERW,
*
      lt_typ_org                   TYPE /THKR/T_OM_AGR_TYP_ORG,
      ls_typ_org                   TYPE /THKR/S_TYP_ORGEBENE_RANGE,
      lt_typ_ber                   TYPE /THKR/T_OM_AGR_TYP_BER,
      ls_typ_ber                   TYPE /THKR/S_TYP_BERECHT_RANGE,
*
      lt_t77omattot                TYPE /THKR/T_AGR_T77OMATTOT,

      lt_org_data                  TYPE /THKR/T_OM_AGR_1252_ERW,
      lt_org_data_tmp              TYPE /THKR/T_OM_AGR_1252_ERW,
      lt_org_data_2                TYPE /THKR/T_OM_AGR_1252_ERW,
      lt_org_data_tmp_2            TYPE /THKR/T_OM_AGR_1252_ERW,

      lt_result_objec3             TYPE TABLE OF objec.
*
FIELD-SYMBOLS <fs_org_data> TYPE p1008.
*
DATA: f_rc          TYPE sy-subrc,
      it_values     TYPE STANDARD TABLE OF ddshretval,
      lf_dynpfields TYPE dynpread,
      lt_dynpfields TYPE dynpread_tabtype,
      lv_shlp       TYPE shlp_descr.

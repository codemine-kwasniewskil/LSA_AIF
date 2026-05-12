FUNCTION-POOL /THKR/BP_FMOD.                "MESSAGE-ID ..

* INCLUDE /THKR/LBP_FMODD...                 " Local class definition
"Kreditor
* INCLUDE LCVI_FS_UI_VENDOR_ENHD...          " Local class definitionconstants:
CONSTANTS : table_name_lfa1     TYPE fsbp_table_name    VALUE 'LFA1',
            table_name_kna1     TYPE fsbp_table_name    VALUE 'KNA1',
            table_name_lfb1     TYPE fsbp_table_name    VALUE 'LFB1',
            table_name_lfb5     TYPE fsbp_table_name    VALUE 'LFB5',
            table_name_lfm2     TYPE fsbp_table_name    VALUE 'LFM2',
            table_name_lfza     TYPE fsbp_table_name    VALUE 'LFZA',
            table_name_lfm1     TYPE fsbp_table_name    VALUE 'LFM1',
            table_name_t001w    TYPE fsbp_table_name    VALUE 'T001W',
            table_name_lfas     TYPE fsbp_table_name    VALUE 'LFAS',
            table_name_lfat     TYPE fsbp_table_name    VALUE 'LFAT',
            table_name_wrf02k   TYPE fsbp_table_name    VALUE 'WRF02K',
            table_name_wyt1t    TYPE fsbp_table_name    VALUE 'WYT1T',
            table_name_wyt1     TYPE fsbp_table_name    VALUE 'WYT1',
            table_name_wyt3     TYPE fsbp_table_name    VALUE 'WYT3',
            table_name_knvv     TYPE fsbp_table_name    VALUE 'KNVV',
            table_name_knvp     TYPE fsbp_table_name    VALUE 'KNVP',
            true                TYPE boole-boole        VALUE 'X',
            false               TYPE boole-boole        VALUE ' ',
            fstat_optional      TYPE bus000flds-fldstat VALUE '.',
            fstat_required      TYPE bus000flds-fldstat VALUE '+',
            fstat_display       TYPE bus000flds-fldstat VALUE '*',
            fstat_suppressed    TYPE bus000flds-fldstat VALUE '-',
            msg_class_cviv_ui   TYPE mesg-arbgb         VALUE 'CVIV_UI',
            msg_error           TYPE mesg-msgty         VALUE 'E',
            koart_kreditor      TYPE koart              VALUE 'K',
            fcode_vtax_dele     TYPE tbz4-fcode         VALUE 'CVIV_TAX_DELE',
            fcode_vend_create   TYPE tbz4-fcode         VALUE 'CVIV_VENDOR_CREATE',

*** constants for table control********
            fcode_indicator     TYPE tbz4-fcode         VALUE 'CVIC_IND',
            gc_fldgr_cvis       TYPE bu_fldgr           VALUE '3407',
            gc_fldstat_suppress TYPE bu_fldstat         VALUE '-',
            gc_xmark            TYPE scrfname           VALUE 'GC_XMARK', "'FSBP_CC_INFO_DYNPRO-XMARK',
            gc_cviv_payee_cc    TYPE bus000cuas         VALUE 'CVIV_PAYEE_CC',
            gc_rvendor_check    TYPE bus000cuas         VALUE 'CHK1',
            gc_classification   TYPE bus000cuas         VALUE 'KLAS'.

DATA :cvis_vend_functions_dynpro1 TYPE cvis_vend_functions_dynpro.
*DATA : fsbp_cc_info_dynpro-xmark TYPE scrfname.
DATA: gs_lfa1                     TYPE lfa1,
      gv_lfa1                     TYPE lfa1,
      gs_rf02d                    TYPE rf02d,
      gs_lfb5                     TYPE lfb5,
      gs_lfm2                     TYPE lfm2,
      gs_lfas                     TYPE lfas,
      gs_lfza                     TYPE lfza,
      gs_lfm1                     TYPE lfm1,
      gv_lfm1                     TYPE lfm1,
      gs_lfb1                     TYPE lfb1,
      gs_wyt1t                    TYPE wyt1t,
      gs_wrf02k                   TYPE wrf02k,
      gs_wyt1                     TYPE wyt1,
      gv_cust_assign              TYPE boole_d,
      gv_flag                     TYPE char1,
      gs_kzret_flag               TYPE c,
      gv_count                    TYPE i VALUE '-1',
      gv_count_wo_cc              TYPE i VALUE '-1',
      exist                       TYPE c,
      gv_activity_type            TYPE bu_aktyp,
      gs_kunnr                    TYPE kunnr,
      gv_kunnr                    TYPE kunnr,
      gv_clr_slctd_plnt_vsr(1)    TYPE c,
      gv_dlt_part_fxn_entry(1)    TYPE c,
      gv_current_table_line       TYPE i,
      gv_purchs_data_dbl_click(1) TYPE c, " flag to indicate purchase data is selected and double click is called
      new                         TYPE c,
      mem_kzret                   TYPE kzret,
      same_bp                     TYPE c,
      default_flag                TYPE c, " flag to default current customer in returns supplier pop-up
      creation_group              TYPE bu_group,
      gv_but000                   TYPE but000,
      button_status               TYPE bus000flds-fldstat,
      gv_sort_partner_func        TYPE boole-boole. "for PArtner Functions
DATA: gv_currency_old TYPE lfa1-j_sc_currency, "The previous input currency  "Add for note 2944616
      gv_calltimes63 TYPE i. "Counter of calling FM CVIV_BUPA_PAI_CVIV63



TYPES: BEGIN OF gt_cc,
         empfk       TYPE lfza-empfk,
         name1       TYPE lfa1-name1,
         ort01       TYPE lfa1-ort01,
         bukrs       TYPE bukrs,
         gc_xmark(1) TYPE c,
       END OF gt_cc.

DATA : gt_cc_info                    TYPE TABLE OF gt_cc  WITH HEADER LINE,
       gt_cc_info_wo_cc              TYPE TABLE OF gt_cc  WITH HEADER LINE,
       fsbp_cc_info_dynpro           LIKE LINE OF gt_cc_info,
       fsbp_cc_info_dynpro_wo_cc     LIKE LINE OF gt_cc_info_wo_cc,
       fsbp_cc_info_dynpro_tty       TYPE TABLE OF gt_cc  WITH HEADER LINE,
       fsbp_cc_info_dynpro_tty_wo_cc TYPE TABLE OF gt_cc  WITH HEADER LINE.

TYPES: BEGIN OF gs_pv ,
         gc_xmark    TYPE boole_d,
         ltsnr       TYPE wyt1-ltsnr, "VSR
         ltsbz       TYPE wyt1t-ltsbz, "VSR description
         werks       TYPE lfm2-werks,  "Plant
         name1       TYPE t001w-name1, "plant description
         hinze       TYPE wrf02k-hinze,
         hinzp       TYPE wrf02k-hinzp,
         ekorg       TYPE lfm2-ekorg,
       END OF gs_pv.

DATA : gt_pv_info              TYPE TABLE OF gs_pv WITH HEADER LINE,
       gt_pv_info_copy         TYPE TABLE OF gs_pv WITH HEADER LINE,
       fsbp_pv_info_dynpro     TYPE gs_pv.


DATA: gt_cc_details_name_city TYPE TABLE OF lfa1 WITH HEADER LINE.

CONTROLS : tctrl_plant_code TYPE TABLEVIEW USING SCREEN '0037'.

data: gv_pbo25_processed    type boole-boole.

DATA:
  gt_cc_info_old            LIKE gt_cc_info,
  gv_error_in_new_cc        TYPE boole-boole,
  gv_error_in_cc            TYPE boole-boole,
  gv_errors_in_ccs          TYPE boole-boole,
  gv_add_line               TYPE boole-boole,
  gv_cc_run_once            TYPE boole-boole,
  gv_new_cc                 TYPE bukrs,
  gv_cc_old                 TYPE bukrs,
  gv_last_cc                TYPE bukrs,        " no clear @ DLVE1
  gv_cc_new_line            TYPE sy-tabix,
  push_cviv_payee_cc        LIKE icons-text,
  gv_lfza_flag              TYPE i VALUE '0',
  gv_lfza_flag_wo_cc        TYPE i VALUE '0'.

CONTROLS : tctrl_comp_code       TYPE TABLEVIEW USING SCREEN '0012',
           tctrl_comp_code_wo_cc TYPE TABLEVIEW USING SCREEN '0058',
           tctrl1_wyt3           TYPE TABLEVIEW USING SCREEN '0039'.

TABLES:
  cvis_vend_functions_dynpro.

* tables, structures and fields for dynpros
DATA:
  gv_parvw_wyt3_pos TYPE wyt3-parvw,
  gv_ktonr_wyt3_pos TYPE cvis_vend_functions_dynpro-ktonr.

DATA : gv_wyt3_linact        TYPE sy-index.

DATA: vendor                TYPE koart_z            VALUE 'K'. "Zterm f4 help


******controls and variables for VSR Multi Lingual*******
TYPES: BEGIN OF gs_po,
         gc_xmark(1) TYPE c,
         spras       TYPE spras,
         lifnr       TYPE lifnr,
         ltsnr       TYPE ltsnr,
         ltsbz       TYPE bezeilts,
       END OF gs_po.

DATA : gt_po_final TYPE TABLE OF wyt1t WITH HEADER LINE.

DATA : gt_po_info1     TYPE TABLE OF gs_po  WITH HEADER LINE,
       gt_po_spras     TYPE TABLE OF gs_po  WITH HEADER LINE,
       gt_po_info1_old TYPE TABLE OF gs_po.

DATA : fsbp_po_multi_lingual LIKE LINE OF gt_po_info1.

CONTROLS :  tctrl_multi_lingual       TYPE TABLEVIEW USING SCREEN '0061'.

DATA : gv_subrange TYPE ltsnr.
DATA : check_f4 TYPE boole_d.

data: gv_ssr_pos type wyt1-ltsnr,
      gv_plant_pos type lfm2-werks.

******controls and variables for VSR Multi Lingual*******


******controls and variables for plant*******

CONSTANTS : fcode_indicator1     TYPE tbz4-fcode        VALUE 'CVIC_IND',
            gc_fldgr_cvis1       TYPE bu_fldgr      VALUE '3331',
            gc_fldstat_suppress1 TYPE bu_fldstat    VALUE '-',
            gc_xmark1            TYPE scrfname VALUE 'GC_XMARK', "'FSBP_CC_INFO_DYNPRO-XMARK',
            gc_cua_sepa1         TYPE bus000cuas     VALUE 'CVIV_SEPA_PLANT'.
.
*DATA : fsbp_cc_info_dynpro1-xmark TYPE scrfname.

DATA:
*      gv_flag1                   TYPE char1,
      gv_empfk_delete_flag       TYPE char1,
      gv_empfk_delete_flag_wo_cc TYPE char1.


TYPES: BEGIN OF gt_cc1,
         gc_xmark(1) TYPE c,
         werks       TYPE lfm2-werks,
         name1       TYPE t001w-name1,
       END OF gt_cc1.

DATA : gt_cc_info1              TYPE TABLE OF gt_cc1  WITH HEADER LINE,
       gt_cc_details_desc       TYPE TABLE OF gt_cc1  WITH HEADER LINE,
       fsbp_cc_info_dynpro1     LIKE LINE OF gt_cc_info1,
       fsbp_cc_info_dynpro_tty1 TYPE TABLE OF gt_cc1  WITH HEADER LINE.



DATA:
  "gt_cc_info             type fsbp_cc_info_dynpro_tty,
  gt_cc_info_old1      LIKE gt_cc_info1,
  gv_cc_new_line1      TYPE sy-tabix,
  push_cviv_sepa_plant LIKE          icons-text,
  gv_lfza_flag1        TYPE i VALUE '0'.

CONTROLS : tctrl_comp_code1 TYPE TABLEVIEW USING SCREEN '0035'.

* WYT3 related data (partnerfunctions)
DATA:
  gt_wyt3_dynpro        TYPE TABLE OF cvis_vend_functions_dynpro WITH HEADER LINE.


TYPES: BEGIN OF gs_cc_rng_plt_cviv09,
         gc_xmark(1) TYPE c,
         werks       TYPE lfm2-werks,
         ltsnr       TYPE lfm2-ltsnr,
         hinze       TYPE wrf02k-hinze,
         hinzp       TYPE wrf02k-hinzp,
       END OF gs_cc_rng_plt_cviv09.

data: gs_cc_rng_plt      type gs_cc_rng_plt_cviv09,
      gs_cc_rng_plt_copy type gs_cc_rng_plt_cviv09.   "for retaining the previous values of werks and ltsnr after double clicking


TABLES : lfa1.


DATA : gv_compcode                TYPE bukrs,
       gv_cc_holding_no_alt_payee TYPE bukrs.
DATA : gc_cua_payee         TYPE bus000cuas         VALUE 'CVIV_PAYEE'.

DATA : gt_check_sy TYPE c.
DATA : gt_check_sy_both TYPE c.
DATA : gv_line_num TYPE i VALUE 0.
DATA : gv_empfk_error TYPE empfk.

DATA : gt_check_sy_wo_cc TYPE c.
DATA : gt_check_sy_both_wo_cc TYPE c.
DATA : gv_line_num_wo_cc TYPE i VALUE 0.
DATA : gv_empfk_error_wo_cc TYPE empfk.

DATA : gv_save_from_gen TYPE c.

DATA : gt_t001 TYPE TABLE OF t001.

* text fields for dynpros
DATA: sperq_txt           TYPE qkurztext,
      werks_txt           TYPE name1,
      plkal_txt           TYPE fktext,
      kzret_cust_no_txt   TYPE kunnr,
      kzret_cust_name_txt TYPE name1_gp,
      gv_paprf_txt        TYPE bezei20,
      gv_sfrgr_txt        TYPE bezei20,
      gv_stgdl_txt        TYPE bezei20,
      gv_podkzb_txt       TYPE string,
      gv_carrier_conf_txt TYPE string,
      gv_ktock_txt        TYPE txt30_077t,
      gv_stcdt_txt        TYPE text30,
      gv_qssys_txt        TYPE qkurztext,
      gv_expvz_txt        TYPE /ecrs/mottx,
      GV_RETURN_SUPPLIER_INFO TYPE string.

* LFM2 Incoterms2010
DATA:
  gv_inco2l_processed    TYPE xo_boole.

** Declarations required for Environment menu options >> Purchase orders, Inquiries, Purch. info records, outline agreements
TABLES : eina,
         eine,
         makt,
         fwyt1t,
         fwyt1,
         t024e.

DATA : gs_rf02k TYPE rf02k.
*         RF02K.

DATA : lfa1_int  TYPE lfa1.

DATA : gs_lmat_header TYPE foap_s_sapmf02k_list2,
       gt_lmat_header TYPE STANDARD TABLE OF foap_s_sapmf02k_list2,
       gs_lmat_items  TYPE foap_s_sapmf02k_list3,
       gt_lmat_items  TYPE STANDARD TABLE OF foap_s_sapmf02k_list3.

DATA: BEGIN OF xeina OCCURS 50.
    INCLUDE STRUCTURE eina.
DATA: END OF xeina.

DATA: BEGIN OF xwyt1t OCCURS 20.
    INCLUDE STRUCTURE fwyt1t.
DATA: END OF xwyt1t.

DATA: BEGIN OF ywyt1 OCCURS 20.
    INCLUDE STRUCTURE fwyt1.
DATA: END OF ywyt1.

DATA : textfill(100).

DATA: BEGIN OF xeine OCCURS 50.
    INCLUDE STRUCTURE eine.
DATA: END OF xeine.

DATA: BEGIN OF xmakt OCCURS 100,
        matnr LIKE makt-matnr,
        maktx LIKE makt-maktx,
      END OF xmakt.

DATA :o_ekorg  LIKE lfm1-ekorg,
      ol_ekorg LIKE lfm1-ekorg,
      o_werks  LIKE lfm2-werks,
      ol_werks LIKE lfm2-werks.

data gv_index type int8.
data: gv_kalsk_txt type kalsb,
      gv_meprf_txt type string,
      gv_skrit_txt type string,
      gv_bstae_txt type bsbez.

* LFM2 related data: TM Location
data gs_tminco_loc_lfm2 TYPE tminco_loc_data.
constants:
  incoterms_dynpro        type d020s-dnum       value '0055',
  vendor_porg_program     type d020s-prog       value 'SAPLCVI_FS_UI_VENDOR_ENH'.

"Debitor

tables:
   cvis_knb5,
   cvis_knbw.

types:
  begin of gty_t042z_in,
    xmark like boole-boole,
    zlsch like t042z-zlsch,
    text1 like t042z-text1,
  end   of gty_t042z_in,

  begin of gty_t042z_out,
    xmark like boole-boole,
    zlsch like t042z-zlsch,
    text1 like t042z-text1,
  end   of gty_t042z_out.

controls:
  tctrl_knb5          type tableview using screen '0053',
  tctrl_knbw          type tableview using screen '0054',
  tctrl_t042z_in      type tableview using screen '1000',
  tctrl_t042z_out     type tableview using screen '1000',
  tctrl_texts         type tableview using screen '0018'.

constants:
  fcode_continue      type tbz4-fcode         value 'CONTINUE',
  fcode_cancel        type tbz4-fcode         value 'CANCEL',
  table_name_knb1     type fsbp_table_name    value 'KNB1',
  table_name_knb5     type fsbp_table_name    value 'KNB5',
  table_name_knbw     type fsbp_table_name    value 'KNBW',
  bupa_objap          type tbz1-objap         value 'BUPA',
  field_grp_clerk     type tbz3w-fldgr        value '1895',
  field_grp_dunning   type tbz3w-fldgr        value '1896',
  field_grp_wth_tax   type tbz3w-fldgr        value '1897',
  field_grp_reconacc  type tbz3w-fldgr        value '1848',
  field_grp_pay_term  type tbz3w-fldgr        value '1861',
  field_grp_pay_cred  type tbz3w-fldgr        value '1862',
  field_grp_pay_exch  type tbz3w-fldgr        value '1864',
  fcode_dunn_dele     type tbz4-fcode         value 'CVIC_DUNN_DELE',
  fcode_dunn_area     type tbz4-fcode         value 'CVIC_DUNN_AREA',
  fcode_wth_dele      type tbz4-fcode         value 'CVIC_WTH_DELE',
  fcode_lock_all_cc   type tbz4-fcode         value 'CVIC_LOCKCC',
  customer            type koart_z            value 'D',
  fcode_maintain_text type tbz4-fcode         value 'CVIC_TMAINT_B',
  fcode_delete_text   type tbz4-fcode         value 'CVIC_TDELE_B',
  fcode_selall_text   type tbz4-fcode         value 'CVIC_TSELALL_B',
  fcode_dselall_text  type tbz4-fcode         value 'CVIC_TDSELALL_B',
  text_object         type tdobject           value 'KNB1',
  auobj_debitor       type bu_auobj           value 'CUST'.

* tables, structures and fields for dynpros
data:
  gv_fcode              like sy-tcode,
  gv_t042z_in_linact    like sy-index,
  gv_t042z_in_text(30)  type c,
  gv_t042z_out_linact   like sy-index,
  gv_t042z_out_text(30) type c,
  gv_knb5_linact        type sy-index,
  gv_knbw_linact        type sy-index,
  gv_default_language_b type spras,
  gs_kna1               type kna1,
  gs_knb1               type knb1,
  gs_knb1_dynp          type cvis_knb1_dynp,
  gs_knb5               type knb5,
  gs_knb5_dynp          type cvis_knb5,
  gs_knb5_tc            type cvis_knb5,
  gs_knbw_tc            like cvis_knbw,
  gt_knb5               type table of cvis_knb5,
  gt_knbw               type table of cvis_knbw,
  gt_rtext_b            type cvis_texts_dynpro_t with header line,
  gt_t042z_in           type table of gty_t042z_in  with header line,
  gt_t042z_out          type table of gty_t042z_out with header line,
  gv_ebpp_active(1)     type c value '-'.

* text fields for dynpros
data:
  recaccount_txt        type txt50_skat,
  head_office_txt       type text40,
  sortkey_txt           type text1_zun,
  preference_txt        type prftx,
  cashmgmt_txt          type ltxt1,
  relgroup_txt          type frgrt,
  interest_txt          type t056x-vtext,
  activitycode_txt      type j_1agicdu-text,
  distrib_type_txt      type j_1adtypt-text30,
  gv_c_hbkid_txt        type banka,
  tolerancegrp_txt      type txt30_043t,
  leave_txt             type text30,
  paymentblock_txt      type textl_008,
  grouping_key_txt      type text30,
  pmt_meth_suppl_txt    type txt30,
  currency_txt          type waers,
  reasoncode_txt        type vrstx,
  selectionrule_txt     type txt25,
  accclerk_txt          type text30,
  bankstatement_txt     type text1_048l,
  vrspr_txt             type char1,
  currency_ins_txt      type waers,
  knb1_zterm_txt        type dzterm_bez,
  knb1_guzte_txt        type dzterm_bez,
  knb1_wakon_txt        type dzterm_bez,
  dunn_procedure_txt    type textm_047t,
  dunn_block_txt        type text1_040t,
  dunn_recipient_txt    type text50,
  dunn_grouping_txt     type text50,
  dunn_clerk_txt        type t001s-sname,
  gv_text_title(132)    type c.

* object references
data:
  gt_text_adapter type table of cvis_text_adapter_cc.

data:
  push_cvic_tmaint_b(20).

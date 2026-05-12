FUNCTION-POOL /THKR/BP_EXT_FIELDS.          "MESSAGE-ID ..


data gv_posnr type bu_posnr.
DATA g_current_type type but000-type.
Data g_current_partner type but000-partner.

*===============================================================================================
* Funktion: Feldgruppen kundeneigene Felder BP
*===============================================================================================
CONSTANTS:
  gc_action_delete     TYPE c       "Aktion: Löschen
                       VALUE 'D',
  gc_action_insert     TYPE c        "Aktion: Einfügen
                       VALUE 'I',
  gc_action_modify     TYPE c        "Aktion: Modifizieren (I,U)
                       VALUE 'M',
  gc_action_update     TYPE c        "Aktion: Ändern
                       VALUE 'U',
  gc_aktyp_change      LIKE tbz0k-aktyp    "Aktivität Ändern
                       VALUE '02',
  gc_aktyp_create      LIKE tbz0k-aktyp    "Aktivität Anlegen
                       VALUE '01',
  gc_aktyp_display     LIKE tbz0k-aktyp    "Aktivität Anzeigen
                       VALUE '03',
  gc_aktyp_modify      LIKE tbz0k-aktyp    "Aktivität Anzeigen
                       VALUE '04',
  gc_cdobjclas         LIKE cdhdr-objectclas "Änd.bel.objekt MKK_BPTAX
                       VALUE 'MKK_BPTAX',
  gc_cdobjid_max       TYPE i        "ÄndBelege: Max. Objekt-IDs
                       VALUE '50',
  gc_msg_cancel        LIKE mesg-msgty       "Meldungen: Abbruch
                       VALUE 'A',
  gc_msg_error(1)      TYPE c        "Meldungen: Fehler
                       VALUE 'E',
  gc_msg_info          LIKE mesg-msgty       "Meldungen: Information
                       VALUE 'I',
  gc_msg_success       LIKE mesg-msgty       "Meldungen: Erfolg
                       VALUE 'S',
  gc_msg_warning       LIKE mesg-msgty       "Meldungen: Warnung
                       VALUE 'W',
  gc_msg_arbgb         LIKE mesg-arbgb       "Meldungen: Arbeitsgebiet
                       VALUE 'FKBPIDT',
* Displaying types for dynpro-field-modification (BP-Technique)
  gc_fstat_optional    LIKE bus000flds-fldstat  "Feldstatus: Kann
                         VALUE '.',
  gc_fstat_required    LIKE bus000flds-fldstat  "Feldstatus: Muß
                         VALUE '+',
  gc_fstat_display     LIKE bus000flds-fldstat  "Feldstatus: Anzeigen
                         VALUE '*',
  gc_fstat_nonspecif   LIKE bus000flds-fldstat "Feldstatus: Nicht
                         VALUE ' ',    "         spezifiziert
  gc_fstat_suppressed  LIKE bus000flds-fldstat "Feldstatus: Ausgebl.
                         VALUE '-',
* BOOLEAN
  true                 LIKE boole-boole VALUE 'X',
  false                LIKE boole-boole VALUE space,
* FIELD-GROUPS:
  gc_fldgr_idtnums     LIKE tbz3w-fldgr "Fieldgr. Ident.Numbers
                       VALUE '293',
* FCODES:
  gc_fcode_idtnum_dele LIKE tbz4-fcode   "delete IDnumber*
              VALUE 'FS_ID_DELETE'.

*---------------------------global variable--------------------------*
DATA: gv_aktyp    LIKE tbz0k-aktyp,
      gv_partner  LIKE but000-partner,
      gv_zzgsber    type gsber ,
      gv_zzsst      type /THKR/DTE_BU_SST,
      gv_gsberold type gsber ,
      gv_group_d_t  type BP_GRP_D_T. "(Tabelle bpib0)
*---------------------------Workarea---------------------------------*
DATA: return_tab      LIKE ddshretval OCCURS 0 WITH HEADER LINE,
      gt_fieldcatalog TYPE lvc_t_fcat, "Fieldcatalog
      ll_but000       LIKE but000.

*---------------------------Tables-----------------------------------*
TABLES: bpid001, bpid002_t,           "DNYPFIELDS.
        tp13,tp13t, bpib0 ,
        bp001, /THKR/S_INC1_BUT, /THKR/S_INC1_BUT_TXT.
*---------ZWFS_-------------------Internal Tables-------------------------*
DATA: gt_bp001_new LIKE bp001 OCCURS 0 WITH HEADER LINE,
      gt_bp001_old LIKE bp001 OCCURS 0 WITH HEADER LINE.

*-----types and datastructures for the current instance of Partner---*
TYPES: BEGIN OF bpidt_disptype.
         INCLUDE STRUCTURE bpid001.
         TYPES:   xmark LIKE boole-boole,
       END   OF bpidt_disptype.
TYPES: bpidt_dispttype TYPE bpidt_disptype OCCURS 0.
TYPES: BEGIN OF bpidt_storetype.
         INCLUDE STRUCTURE bpid001.
       TYPES  END   OF bpidt_storetype.
TYPES:  bpidt_storettype TYPE bpidt_storetype OCCURS 0.
DATA: gt_bpidt     TYPE bpidt_dispttype WITH HEADER LINE,
      gt_bpidt_old TYPE bpidt_storettype WITH HEADER LINE.
DATA:       lx_mark           LIKE boole-boole.
**--------------------------Tablecontrols-----------------------------*
CONTROLS: tctrl_bpidt TYPE TABLEVIEW USING SCREEN '0100'.   "#EC *
DATA: gv_idt_crsline    LIKE sy-stepl, " Cursorzeile
      gv_idt_linact     LIKE sy-index, " aktueller Eintrag
      gv_idt_linact_old LIKE sy-index, " aktueller Eintrag
      gv_idt_indexdi    LIKE sy-index, " Akt. Eintrag (DI)
      gv_idt_loopc      LIKE sy-loopc. " Anzahl LOOP-Zeilen

* Control-Structure of the current instance
TYPES: BEGIN OF bpidt_control,
         aktyp    LIKE  tbz0k-aktyp,
         xsave    LIKE  bus000flds-xsave,
         xinit    LIKE  bus000flds-char1,
         xupdtask LIKE  boole-boole,
         xdinp    LIKE  bus000flds-char1,
         nodata   LIKE  bus000flds-char1,
         valdt    LIKE  bus_istat-valdt,
       END OF bpidt_control.
DATA: gs_current_control TYPE bpidt_control.
TYPES: BEGIN OF bpidt_control_lm,
         aktyp      LIKE  tbz0k-aktyp,
         valdt      LIKE  bus_istat-valdt,
         planchngnr LIKE  pcdhdr-planchngnr,
       END OF bpidt_control_lm.

* local memory of all instances of partners
TYPES: BEGIN OF bpidt_localmem_type,
         partner LIKE but000-partner,
         bpidt   TYPE bpidt_storettype,
         control TYPE bpidt_control_lm,
       END OF bpidt_localmem_type.
TYPES  bpidt_localmem_ttype TYPE  bpidt_localmem_type OCCURS 0.
DATA: gt_local_mem     TYPE bpidt_localmem_ttype WITH HEADER LINE,
      gt_local_mem_old TYPE bpidt_localmem_ttype WITH HEADER LINE.
* Data of all changed and locked instances.
DATA gt_global_locks       TYPE bu_partner_guid_t.
************** Change - Docs *******************************************
DATA: gv_cd_xglobal LIKE boole-boole.  "Kennz: allgem. Daten relev

TYPE-POOLS:
  SHLP, abap.
DATA  gt_selopt  LIKE bussrch_selopt OCCURS 0 WITH HEADER LINE.
*--------------------------Includes------------------------------------*

DATA: gv_group_d LIKE bp001-group_d.
*--------------------------Tables--------------------------------------*
TABLES:
         fsbp_search_fields,
         bpa001_di,
         bus0diinit.
*--------------------------Global variables----------------------------*
DATA: gv_sel_tabix(1) TYPE c,
      gv_crsline      LIKE sy-stepl,   "Cursorzeile
      gv_diff0(1)     TYPE c,          "Kz.: allgem. Daten relev.
      gv_dsave(1)     TYPE c,          "Kz.: DSAVE wurde durchl.
      gv_fstat        LIKE bus000flds-fldstat, "Feldstatus
      gv_handleno     TYPE i,          "lfd. Nr. f. Adresshandle
      gv_itab_lines   LIKE sy-tabix,   "AdrÜbersicht: Anz. Zeilen
      gv_by_indexdi   LIKE sy-index,   "BP021: Akt. Eintrag DI
      gv_loopc        LIKE sy-loopc,   "AdrÜbersicht: LOOPC
      gv_ok_code      LIKE sy-ucomm,
      gv_tab_index    LIKE sy-index,   "AdrÜbersicht: Akt. Index
      gv_xchng(1)     TYPE c,
      gv_xinit        LIKE  bus000flds-char1,
      gv_xdinp        LIKE bus000flds-char1,
      gv_xupdtask     LIKE boole-boole,
      gv_parallel,
      gv_xf2(1)       TYPE c,          "Selektion durch F2
      gv_xsave        LIKE bus000flds-xsave,
      gv_timestamp    TYPE timestamp,
      gv_tzone        TYPE tznzone,
      gv_status(1),                    "Feldstatus eines Feldes
      gv_zgp,
      gv_dialog,
      gv_si_message,
      gv_flg_fs01_active LIKE boole-boole,
      gv_flg_fs01_dsave_processed LIKE boole-boole,
      gv_country_rep_text         type t005t-landx,
      gv_psearch_active           LIKE fsbp_steuerung_search-phon_suche,
      gv_person                   LIKE fsbp_steuerung_search-person,
      gv_org                      LIKE fsbp_steuerung_search-organisation,
      gv_gruppe                   LIKE fsbp_steuerung_search-group.

*Jüristische Daten
DATA:  gv_tcurt_ltext LIKE tcurt-ltext,
       gv_t005u_bezei LIKE t005u-bezei,
       gv_T005T_LANDX like T005T-LANDX.
*Ext. Nummern
data  GV_EXNR like BUT000-BPext.
DATA: gv_changes_actual(1),
      gv_cvaldt      LIKE sy-datlo,
      gv_cvaldt_old  LIKE sy-datlo,
      gv_valdt       LIKE bus000flds-valdt,
      gv_noact(1),
      gv_cdpartner LIKE cdhdr-objectid,
      gv_flag_partner,

*     Kennz.: Änd.bel. schreiben
      gv_xchdoc        LIKE boole-boole.
* Änderungsbelegkopf:
DATA BEGIN OF hlp_cdhdr.
        INCLUDE STRUCTURE cdhdr.
DATA:  object_change_indicator LIKE cdhdr-change_ind,
       planned_or_real_changes LIKE cdhdr-change_ind,
       no_change_pointers      LIKE cdhdr-change_ind,
      END OF hlp_cdhdr.
DATA  display.
*--------------------------Internal Table------------------------------*
DATA: gt_partners LIKE bus_partnr OCCURS 0 WITH HEADER LINE.
DATA: gt_person LIKE bus_person OCCURS 0 WITH HEADER LINE.
TYPES:
  BEGIN OF lty_badi_ref,
    badi_name TYPE tabname,
    reference TYPE REF TO object,
  END OF lty_badi_ref.
data: gv_badi_bp001_loaded  TYPE boole_d.
*      gr_badi_bp001         TYPE REF TO if_ex_bptime_bp001.
DATA: BEGIN OF gt_suppl OCCURS 0,
        fldgr LIKE tbz3w-fldgr,
      END   OF gt_suppl.
DATA: t_roles         TYPE TABLE OF bup_bprole,
      s_roles         LIKE LINE OF t_roles,
      t_fldvl         LIKE bus0fldval OCCURS 0 WITH HEADER LINE,
      gt_aend         LIKE bus0aend   OCCURS 0 WITH HEADER LINE.

* Organisation
DATA: mem_bp001_old LIKE bp001 OCCURS 10 WITH HEADER LINE,
      mem_bp001_new LIKE bp001 OCCURS 10 WITH HEADER LINE.

* Rollendaten
DATA: gt_but100_temp LIKE but100 OCCURS 10 WITH HEADER LINE.

DATA: BEGIN OF mem_partner OCCURS 0,
        partner LIKE but000-partner,
        partnr  LIKE but000-partner,
        valdt   LIKE bus000flds-valdt,
      END   OF mem_partner.



DATA: n_bp001_cd  LIKE bp001_upd  OCCURS 0 WITH HEADER LINE,
      o_bp001_cd  LIKE bp001_upd  OCCURS 0 WITH HEADER LINE.
DATA: icdtxt_bupa_fs01 LIKE cdtxt OCCURS 0 WITH HEADER LINE,
      xbpid001 LIKE vbpid001 OCCURS 0 WITH HEADER LINE,
      ybpid001 LIKE vbpid001 OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF gt_partner OCCURS 0,
        partner    LIKE but000-partner,
        valdt      LIKE bus000flds-valdt,
      END OF gt_partner.
DATA:    BEGIN OF phonet_tab OCCURS 0.
        INCLUDE STRUCTURE tpz1.
DATA:    END OF phonet_tab.
*data: gt_bpfrg    LIKE bpfrg      OCCURS 0 WITH HEADER LINE.
*--------------------------Workarea------------------------------------*
DATA: gl_busdata     LIKE busdata,
      but000_stat    LIKE bus_istat.      "Aktueller Status
DATA: BEGIN OF gt_pchngnr OCCURS 1,
        partner   LIKE but000-partner,
        pchngnr LIKE pcdhdr-planchngnr,
        valdt   LIKE sy-datlo,
      END OF gt_pchngnr.
DATA: gl_tp18t       LIKE tp18t.
DATA  gv_global_locks TYPE bu_partner_guid.
*--------------------------constants-----------------------------------*
CONSTANTS: const_tabname_sta1 LIKE sval-tabname VALUE 'VTB_STA1_COPY',
           const_tabname_sta2 LIKE sval-tabname VALUE 'VTB_STA2_COPY',
           const_tabname_sta3 LIKE sval-tabname VALUE 'VTB_STA3_COPY',
           const_tabname_sta4 LIKE sval-tabname VALUE 'VTB_STA4_COPY',
           c_actvt_change(2)   VALUE '02',  "Anlegen/Ändern
           c_actvt_display(2)  VALUE '03'.                  "Anzeigen
CONSTANTS: gc_objap_bupa LIKE tbz1-objap  "Anwendungsobjekt BUPA
                         VALUE 'BUPA'.

DATA: gv_trading_partner TYPE name_1.

DATA: c_insert(1) VALUE 'I',
      c_update(1) VALUE 'U',
      c_delete(1) VALUE 'D'.
* Änderungskennzeichen:
DATA: BEGIN OF hlp_cd_update,
        bp001  LIKE cdpos-chngind VALUE 'U',
      END OF hlp_cd_update.
* Hilfsvariable:
DATA:
  ok_code     LIKE sy-ucomm.

* INCLUDE /THKR/LBP_EXT_FIELDSD...           " Local class definition

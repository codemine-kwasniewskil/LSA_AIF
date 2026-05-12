*&---------------------------------------------------------------------*
*& Include Z_FI_AUSANN_VERR_TOP                  - Report Z_FI_AUSANN_VERR
*&---------------------------------------------------------------------*
report z_fi_ausann_verr message-id z_fi_nachr
       no standard page heading
       line-size 132.

tables: zfi_verr_head, zfi_verr_item,
        bsik,
        bkpf,
        rfpdo,
        adrs.


* das ist dann eine Struktur für AnnahmeAO und
* AuszahlungsAO; sonst ggf. Unterschied bei kunnr und
* lifnr
types: begin of ty_beleg,
         bukrs  type bkpf-bukrs,
         belnr  type bkpf-belnr,
         gjahr  type bkpf-gjahr,
         blart  type bkpf-blart,
         bldat  type bkpf-bldat,
         budat  type bkpf-budat,
         cpudt  type bkpf-cpudt,
         cputm  type bkpf-cputm,
         bvorg  type bkpf-bvorg,
         xblnr  type bkpf-xblnr,
         stblg  type bkpf-stblg,
         bktxt  type bkpf-bktxt,
         waers  type bkpf-waers,
         hwaer  type bkpf-hwaer,
         kunnr  type bseg-kunnr,
         lifnr  type bseg-lifnr,
         augdt  type bseg-augdt,
         augbl  type bseg-augbl,
         buzei  type bseg-buzei,
         shkzg  type bseg-shkzg,
         wrbtr  type bseg-wrbtr,
         dmbtr  type bseg-dmbtr,
         zfbdt  type bseg-zfbdt,
         zterm  type bseg-zterm,
         zlsch  type bseg-zlsch,
         zlspr  type bseg-zlspr,  "001 Änderung
         rebzg  type bsid-rebzg,
         rebzj  type bsid-rebzj,
         rebzz  type bsid-rebzz,
*         xblnr_ann type bkpf-xblnr,
         number type i,
         msgnr  type msgnr.
types:      end of ty_beleg.


*das sind die ermittelteten Referenznummern
types: begin of ty_xblnr,
         xblnr type xblnr.
types:  end of ty_xblnr .


* im Zahllauf über "FORM before_line_output"???
* behalten das in diesem Feld
types: begin of ty_lifnr,
*         xblnr_ann  type xblnr,
         xblnr      type xblnr,
         bukrs      type bukrs,
         lifnr      type lifnr,
         addr_short type ad_line_s. "Einzeilige Kurzform der aufbereiteten Adresse
types:  end of ty_lifnr .

types: begin of ty_kunnr,
         xblnr      type xblnr,
         bukrs      type bukrs,
         kunnr      type kunnr,
         addr_short type ad_line_s. "Einzeilige Kurzform der aufbereiteten Adresse
types:  end of ty_kunnr .

* Buchungskreise für die Berechtigung
types: begin of ty_bukrs,
         bukrs type bukrs.
types:  end of ty_bukrs .


types: begin of ty_sum,
         bukrs type bukrs,
         kz    type char1,
         waers type bkpf-waers,
         wrbtr type bseg-wrbtr.
types:      end of ty_sum.

types: begin of ty_sum_list,
         bukrs  type bukrs,
         wrbtra type bseg-wrbtr,
         wrbtre type bseg-wrbtr.
types:      end of ty_sum_list.
*
types: begin of ty_msg,
         msgid      like  sy-msgid,
         msgno      like  sy-msgno,
         msgty      like  sy-msgty,
         msgv1      like  sy-msgv1,
         msgv2      like  sy-msgv2,
         msgv3      like  sy-msgv3,
         msgv4      like  sy-msgv4,
         msgtx(300) type c.
types: end of ty_msg.

data: begin of gt_messages occurs 0,
        xblnr    type xblnr,
        messages type standard table of ty_msg.
data: end of gt_messages.

data: gv_number_error type i,
      gv_number       type i.


constants:
  gc_off type c value ' ',
  gc_on  type c value 'X'.

constants:
  gc_char_h type c value 'H',
  gc_char_s type c value 'S',
  gc_char_d type c value 'D',
  gc_char_k type c value 'K',
  gc_char_e type c value 'E',
  gc_char_a type c value 'A',
  gc_char_b type c value 'B',
  gc_char_c type c value 'C'.
constants:
  gc_blart_zi   type blart value 'ZI',
  gc_fikrs      type fikrs value '1000',
  gc_psoty_01   type psoty value '01',
  gc_init_zlspr type dzlspr value ' ',
  gc_arbgb      type arbgb value 'Z_FI_NACHR',
  c_auth_activ_03  type fm_authact value '03',
  c_auth_activ_10  type fm_authact value '10'.

*----------------------------------------------------------------------*
* das ist die durchgeführte Transaktion
*----------------------------------------------------------------------*
data: gv_tcode type tcode value 'F-30',
  gv_waers      type waers,
  gv_periv      type periv,
  gv_gjahr      type gjahr.

data: gv_once  type c,
      gv_linsz like sy-linsz.



data: gt_beleg     type standard table of ty_beleg,
      gt_beleg_ann type standard table of ty_beleg,
      gt_xblnr     type standard table of ty_xblnr,
      gt_xblnr_ann type standard table of ty_xblnr,
      gt_lifnr     type standard table of ty_lifnr,
      gt_kunnr     type standard table of ty_kunnr,
      gt_item      type standard table of zfi_verr_item,
      gt_head      type standard table of zfi_verr_head,
      gt_sum       type standard table of ty_sum_list,
      gt_bukrs     type standard table of ty_bukrs.
*
* ---------------------- listtool -----------------------------------
* es wird von einer Hierarisch seq. Liste ausgegangen
* und von einer Summenliste diese muss "statisch"ausgegeben werden
* keine Änderungen / keine Umsortierungen oder sonstiges
*
*--------------------------------------------------------------------

data: gt_events       type slis_t_event,
      gt_event_exit   type slis_t_event_exit,
      gt_events_sum   type slis_t_event,
      gt_fieldcat     type slis_t_fieldcat_alv with header line,
      gt_fieldcat_sum type slis_t_fieldcat_alv,
      gs_layout       type slis_layout_alv,
      gs_layout_sum   type slis_layout_alv,
      gt_sort_main    type slis_t_sortinfo_alv with header line,
      gs_keyinfo      type slis_keyinfo_alv,
      gs_print        type slis_print_alv,
      gt_extab        type  slis_t_extab with header line.




data: g_repid              like sy-repid,
      g_inclname           like sy-repid     value 'Z_FI_AUSANN_VERR_TOP',
      g_save(1)            type c            value 'A',
      g_tabname_header     type slis_tabname value 'GT_HEAD',
      g_tabname_item       type slis_tabname value 'GT_ITEM',
      g_tabname_sum        type slis_tabname
                          value 'GT_SUM',
      g_variant_main       like disvariant,
      g_variant_sum        like disvariant,
      g_user_command       type slis_formname value 'USER_COMMAND',
      g_adrlen             type i,
      gc_answer(1)         type c,
      gc_text              like t100-text,
      gc_type_of_list(2)   type c,
      gc_icon_prin_ok(120) type c,
      gc_icon_prin_no(120) type c,
      gn_wabzg_width(3)    type n.

data: gc_icon_select_all(120)   type c,
      gc_icon_deselect_all(120) type c.

data: gx_firstadrsout(1) type c,
      gx_showpoken(1)    type c,
      gx_topskip(1)      type c,
      gx_noexpa(1)       type c,
      gx_hrflag(1)       type c,
      gx_entries(1)      type c.

*---BDC-Data
data: gt_bdctab       type table of bdcdata,
      gv_bci_mappe    type boole_d,
      gv_bi_cnt_tcode type i,
      gv_groupid      type apq_grpn.
data:
      lt_messtab  type table of bdcmsgcoll.




*----------------------------------------------------------------------*
*        A U S W A H L K R I T E R I E N  SELEKTIONSBILD FESTLEGEN     *
*----------------------------------------------------------------------*
* AuszahlungsAO
*----------------------------------------------------------------------*
selection-screen begin of block b1 with frame title text-b01.
  select-options: s_bukrs  for  bsik-bukrs,
                  s_gjahr  for bsik-gjahr,
                  s_budat for bsik-budat,
                  s_cpudt for bsik-cpudt,
                  s_zfbdt for bsik-zfbdt,
                  s_lifnr for bsik-lifnr,
*                s_belnr for bsik-belnr.
                  s_xblnr for bsik-xblnr.
selection-screen end of block b1.
* FM_CF_CHECK_FI_DOC - als Ansatz für die Selektion nach HHJ
* Fortschreibungsthema
*----------------------------------------------------------------------*
* AnnahmeAO
*----------------------------------------------------------------------*
* laut Sitzung 9.10.2019 keine vorgesehen
*----------------------------------------------------------------------*
parameters:     p_zlsch type bsik-zlsch default 'I' no-display.
*----------------------------------------------------------------------*
* Ausgleichsbeleg
*----------------------------------------------------------------------*
selection-screen begin of block b3 with frame title text-b03.
  parameters: p_bldat type bkpf-bldat,
              p_budat type bkpf-budat,
              p_waers type bkpf-waers.
  parameters: p_blart type bkpf-blart.
* werden automatisch vergeben pro Beleg vergeben
*parameters: p_xblnr type bkpf-xblnr,
*            p_bktxt type bkpf-bktxt.
selection-screen end of block b3.
*----------------------------------------------------------------------*
* Verarbeitungsmodus
*----------------------------------------------------------------------*
selection-screen begin of block b4 with frame title text-b04.
* hier noch einmal prüfen, ob wir Direct-Input nutzen wollen
* das kommt aus RFBIBLxx
  parameters: p_mode    like rfpdo-rfbifunct  default 'C' no-display.
* hier könnte auch prinzipiell BI stehen
  parameters: p_list type xfeld radiobutton group doit.
  parameters: p_buch type xfeld radiobutton group doit.
  parameters: p_test type xfeld default gc_on.
selection-screen end of block b4.

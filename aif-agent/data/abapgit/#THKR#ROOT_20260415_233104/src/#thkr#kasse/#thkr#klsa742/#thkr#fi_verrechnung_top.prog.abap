*&---------------------------------------------------------------------*
*& Include /THKR/FI_VERRECHNUNG_TOP
*&---------------------------------------------------------------------*
REPORT /thkr/fi_verrechnung MESSAGE-ID /THKR/FI_NACHR
       NO STANDARD PAGE HEADING
       LINE-SIZE 132.

TABLES: /thkr/fi_verr_head,
        /thkr/fi_verr_item,
        bsik,
        bkpf,
        rfpdo,
        adrs.


* das ist dann eine Struktur für AnnahmeAO und
* AuszahlungsAO; sonst ggf. Unterschied bei kunnr und
* lifnr
TYPES: BEGIN OF ty_beleg,
         bukrs  TYPE bkpf-bukrs,
         belnr  TYPE bkpf-belnr,
         gjahr  TYPE bkpf-gjahr,
         blart  TYPE bkpf-blart,
         bldat  TYPE bkpf-bldat,
         budat  TYPE bkpf-budat,
         cpudt  TYPE bkpf-cpudt,
         cputm  TYPE bkpf-cputm,
         bvorg  TYPE bkpf-bvorg,
         xblnr  TYPE bkpf-xblnr,
         xblnr_ann  TYPE bkpf-xblnr,  "geä. js
         stblg  TYPE bkpf-stblg,
         bktxt  TYPE bkpf-bktxt,
         waers  TYPE bkpf-waers,
         hwaer  TYPE bkpf-hwaer,
         kunnr  TYPE bseg-kunnr,
         lifnr  TYPE bseg-lifnr,
         augdt  TYPE bseg-augdt,
         augbl  TYPE bseg-augbl,
         buzei  TYPE bseg-buzei,
         shkzg  TYPE bseg-shkzg,
         wrbtr  TYPE bseg-wrbtr,
         dmbtr  TYPE bseg-dmbtr,
         zfbdt  TYPE bseg-zfbdt,
         zterm  TYPE bseg-zterm,
         zlsch  TYPE bseg-zlsch,
         zlspr  TYPE bseg-zlspr,  "001 Änderung
         rebzg  TYPE bsid-rebzg,
         rebzj  TYPE bsid-rebzj,
         rebzz  TYPE bsid-rebzz,
         number TYPE i,
         msgnr  TYPE msgnr.
TYPES:      END OF ty_beleg.


*das sind die ermittelteten Referenznummern
TYPES: BEGIN OF ty_xblnr,
         xblnr TYPE xblnr.
TYPES:  END OF ty_xblnr .


* im Zahllauf über "FORM before_line_output"???
* behalten das in diesem Feld
TYPES: BEGIN OF ty_lifnr,
         xblnr      TYPE xblnr,
         bukrs      TYPE bukrs,
         lifnr      TYPE lifnr,
         addr_short TYPE ad_line_s. "Einzeilige Kurzform der aufbereiteten Adresse
TYPES:  END OF ty_lifnr .

TYPES: BEGIN OF ty_kunnr,
         xblnr      TYPE xblnr,
         bukrs      TYPE bukrs,
         kunnr      TYPE kunnr,
         addr_short TYPE ad_line_s. "Einzeilige Kurzform der aufbereiteten Adresse
TYPES:  END OF ty_kunnr .

* Buchungskreise für die Berechtigung
TYPES: BEGIN OF ty_bukrs,
         bukrs TYPE bukrs.
TYPES:  END OF ty_bukrs .


TYPES: BEGIN OF ty_sum,
         bukrs TYPE bukrs,
         kz    TYPE char1,
         waers TYPE bkpf-waers,
         wrbtr TYPE bseg-wrbtr.
TYPES:      END OF ty_sum.

TYPES: BEGIN OF ty_sum_list,
         bukrs  TYPE bukrs,
         wrbtra TYPE bseg-wrbtr,
         wrbtre TYPE bseg-wrbtr.
TYPES:      END OF ty_sum_list.
*
TYPES: BEGIN OF ty_msg,
         msgid      LIKE  sy-msgid,
         msgno      LIKE  sy-msgno,
         msgty      LIKE  sy-msgty,
         msgv1      LIKE  sy-msgv1,
         msgv2      LIKE  sy-msgv2,
         msgv3      LIKE  sy-msgv3,
         msgv4      LIKE  sy-msgv4,
         msgtx(300) TYPE c.
TYPES: END OF ty_msg.

DATA: BEGIN OF gt_messages OCCURS 0,
        xblnr    TYPE xblnr,
        messages TYPE STANDARD TABLE OF ty_msg.
DATA: END OF gt_messages.

DATA: gv_number_error TYPE i,
      gv_number       TYPE i.


CONSTANTS:
  gc_off TYPE c VALUE ' ',
  gc_on  TYPE c VALUE 'X'.

CONSTANTS:
  gc_char_h TYPE c VALUE 'H',
  gc_char_s TYPE c VALUE 'S',
  gc_char_d TYPE c VALUE 'D',
  gc_char_k TYPE c VALUE 'K',
  gc_char_e TYPE c VALUE 'E',
  gc_char_a TYPE c VALUE 'A',
  gc_char_b TYPE c VALUE 'B',
  gc_char_c TYPE c VALUE 'C'.
CONSTANTS:
  gc_blart_zi     TYPE blart VALUE 'ZX',  "geä. js
  gc_fikrs        TYPE fikrs VALUE '1000',
  gc_psoty_01     TYPE psoty VALUE '01',
  gc_init_zlspr   TYPE dzlspr VALUE ' ',
  gc_arbgb        TYPE arbgb VALUE '/THKR/FI_NACHR', "geä. js
  c_auth_activ_03 TYPE fm_authact VALUE '03',
  c_auth_activ_10 TYPE fm_authact VALUE '10'.

*----------------------------------------------------------------------*
* das ist die durchgeführte Transaktion
*----------------------------------------------------------------------*
DATA: gv_tcode TYPE tcode VALUE 'F-30',
      gv_waers TYPE waers,
      gv_periv TYPE periv,
      gv_gjahr TYPE gjahr.

DATA: gv_once  TYPE c,
      gv_linsz LIKE sy-linsz.



DATA: gt_beleg     TYPE STANDARD TABLE OF ty_beleg,
      gt_beleg_ann TYPE STANDARD TABLE OF ty_beleg,
      gt_xblnr     TYPE STANDARD TABLE OF ty_xblnr,
      gt_xblnr_ann TYPE STANDARD TABLE OF ty_xblnr,
      gt_lifnr     TYPE STANDARD TABLE OF ty_lifnr,
      gt_kunnr     TYPE STANDARD TABLE OF ty_kunnr,
      gt_item      TYPE STANDARD TABLE OF /thkr/fi_verr_item,
      gt_head      TYPE STANDARD TABLE OF /thkr/fi_verr_head,
      gt_sum       TYPE STANDARD TABLE OF ty_sum_list,
      gt_bukrs     TYPE STANDARD TABLE OF ty_bukrs.
*
* ---------------------- listtool -----------------------------------
* es wird von einer Hierarisch seq. Liste ausgegangen
* und von einer Summenliste diese muss "statisch"ausgegeben werden
* keine Änderungen / keine Umsortierungen oder sonstiges
*
*--------------------------------------------------------------------

DATA: gt_events       TYPE slis_t_event,
      gt_event_exit   TYPE slis_t_event_exit,
      gt_events_sum   TYPE slis_t_event,
      gt_fieldcat     TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gt_fieldcat_sum TYPE slis_t_fieldcat_alv,
      gs_layout       TYPE slis_layout_alv,
      gs_layout_sum   TYPE slis_layout_alv,
      gt_sort_main    TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      gs_keyinfo      TYPE slis_keyinfo_alv,
      gs_print        TYPE slis_print_alv,
      gt_extab        TYPE  slis_t_extab WITH HEADER LINE.

DATA: g_repid              LIKE sy-repid,
      g_inclname           LIKE sy-repid     VALUE 'Z_FI_AUSANN_VERR_TOP',
      g_save(1)            TYPE c            VALUE 'A',
      g_tabname_header     TYPE slis_tabname VALUE 'GT_HEAD',
      g_tabname_item       TYPE slis_tabname VALUE 'GT_ITEM',
      g_tabname_sum        TYPE slis_tabname
                          VALUE 'GT_SUM',
      g_variant_main       LIKE disvariant,
      g_variant_sum        LIKE disvariant,
      g_user_command       TYPE slis_formname VALUE 'USER_COMMAND',
      g_adrlen             TYPE i,
      gc_answer(1)         TYPE c,
      gc_text              LIKE t100-text,
      gc_type_of_list(2)   TYPE c,
      gc_icon_prin_ok(120) TYPE c,
      gc_icon_prin_no(120) TYPE c,
      gn_wabzg_width(3)    TYPE n.

DATA: gc_icon_select_all(120)   TYPE c,
      gc_icon_deselect_all(120) TYPE c.

DATA: gx_firstadrsout(1) TYPE c,
      gx_showpoken(1)    TYPE c,
      gx_topskip(1)      TYPE c,
      gx_noexpa(1)       TYPE c,
      gx_hrflag(1)       TYPE c,
      gx_entries(1)      TYPE c.

*---BDC-Data
DATA: gt_bdctab       TYPE TABLE OF bdcdata,
      gv_bci_mappe    TYPE boole_d,
      gv_bi_cnt_tcode TYPE i,
      gv_groupid      TYPE apq_grpn.
DATA:
      lt_messtab  TYPE TABLE OF bdcmsgcoll.




*----------------------------------------------------------------------*
*        A U S W A H L K R I T E R I E N  SELEKTIONSBILD FESTLEGEN     *
*----------------------------------------------------------------------*
* AuszahlungsAO
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
  SELECT-OPTIONS: s_bukrs  FOR  bsik-bukrs,
                  s_gjahr  FOR bsik-gjahr,
                  s_budat FOR bsik-budat,
                  s_cpudt FOR bsik-cpudt,
                  s_zfbdt FOR bsik-zfbdt,
                  s_lifnr FOR bsik-lifnr,
*                s_belnr for bsik-belnr.
                  s_xblnr FOR bsik-xblnr.
SELECTION-SCREEN END OF BLOCK b1.
* FM_CF_CHECK_FI_DOC - als Ansatz für die Selektion nach HHJ
* Fortschreibungsthema
*----------------------------------------------------------------------*
* AnnahmeAO
*----------------------------------------------------------------------*
* laut Sitzung 9.10.2019 keine vorgesehen
*----------------------------------------------------------------------*
PARAMETERS:     p_zlsch TYPE bsik-zlsch DEFAULT 'X' NO-DISPLAY. "geä. js
*----------------------------------------------------------------------*
* Ausgleichsbeleg
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-b03.
  PARAMETERS: p_bldat TYPE bkpf-bldat,
              p_budat TYPE bkpf-budat,
              p_waers TYPE bkpf-waers.
  PARAMETERS: p_blart TYPE bkpf-blart.
SELECTION-SCREEN END OF BLOCK b3.
*----------------------------------------------------------------------*
* Verarbeitungsmodus
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-b04.
* hier noch einmal prüfen, ob wir Direct-Input nutzen wollen
* das kommt aus RFBIBLxx
  PARAMETERS: p_mode    LIKE rfpdo-rfbifunct  DEFAULT 'C' NO-DISPLAY.
* hier könnte auch prinzipiell BI stehen
  PARAMETERS: p_list TYPE xfeld RADIOBUTTON GROUP doit.
  PARAMETERS: p_buch TYPE xfeld RADIOBUTTON GROUP doit.
  PARAMETERS: p_test TYPE xfeld DEFAULT gc_on.
SELECTION-SCREEN END OF BLOCK b4.

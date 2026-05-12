*&---------------------------------------------------------------------*
*& Include          /THKR/WF_TEST_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS: icon.

TABLES sscrfields.

TYPES: BEGIN OF lty_funktion,
         funktion TYPE z_om_dte_funktion,
       END OF lty_funktion.

*TYPES: BEGIN OF lty_zfi,
*         bukrs TYPE zfi_storno-bukrs,
*         belnr TYPE zfi_storno-belnr,
*         gjahr TYPE zfi_storno-gjahr,
*         modul TYPE zfi_storno-modul,
*         lfdnr TYPE zfi_storno-lfdnr,
*       END OF lty_zfi.

TYPES: BEGIN OF lty_head,
         wi_text TYPE swwwihead-wi_text,
         wi_stat TYPE swwwihead-wi_stat,
         wi_cd   TYPE swwwihead-wi_cd,
         wi_ct   TYPE swwwihead-wi_ct,
       END OF lty_head.

DATA: lt_attr       TYPE hrtb_attvalue,
      lt_return     LIKE ddshretval OCCURS 0 WITH HEADER LINE,
      lt_step       TYPE TABLE OF lty_funktion,
      lv_wi_text    TYPE sww_witext,
      lt_pos        TYPE TABLE OF plans,
      lt_plans      TYPE TABLE OF swhactor,
      lt_container  TYPE TABLE OF swcont,
      lv_storno     TYPE string,
      lv_active_tab TYPE string,
*      lt_zfi        TYPE TABLE OF lty_zfi,
      lt_head       TYPE TABLE OF lty_head,
      lt_selopt     TYPE TABLE OF selopt.
DATA: lv_tab_save   type string.

DATA: lo_wf TYPE REF TO /thkr/cl_wf_funktion_srv.

DATA: ld_subrc type SYST_SUBRC.

CONSTANTS: gc_tcode_all  TYPE sytcode VALUE '/THKR/WF_TEST',
           gc_tcode_opek TYPE sytcode VALUE 'ZOM_WF_CHECKUSER'.

CONSTANTS: gv_tbl_memory TYPE c LENGTH 10 VALUE 'ZOM_WF_TES'.

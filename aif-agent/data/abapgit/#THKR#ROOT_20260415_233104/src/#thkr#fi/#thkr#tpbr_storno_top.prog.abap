*&---------------------------------------------------------------------*
*& Include          /THKR/TPBR_STORNO_TOP
*&---------------------------------------------------------------------*

TABLES: uf05a, vbrk.

TYPES: BEGIN OF gty_s_storno,
         gsber   TYPE gsber,
         buzei   TYPE buzei,
         fikrs   TYPE fikrs,
         geber   TYPE bp_geber,
         measure TYPE fm_measure,
         fistl   TYPE fistl,
         fipos   TYPE fipos,
         rbstat  TYPE rbstat,
         blart   TYPE blart,
         buchk   TYPE buchk.
         INCLUDE TYPE /THKR/STORNOC.
TYPES: END OF gty_s_storno.

TYPES: BEGIN OF gty_s_referenz,
         refnr TYPE awkey,
       END OF gty_s_referenz.

DATA: gv_fehler   TYPE xfeld,
      gv_modus    TYPE char2,
      gv_referr   TYPE boolean,
      gv_kstl_cho TYPE boolean.      " 002


DATA: ok-code(5) TYPE c,             "OK Code (Funktionscode)
      okcode_t   TYPE syucomm.       " OK Code Tabelle Referenz

DATA: gs_storno TYPE /THKR/STORNOC.
*      gs_refnr  TYPE zfi_refx_refnr.


*DATA: gt_refnr    TYPE STANDARD TABLE OF zfi_refx_refnr.

*" Daten für Tablecontrol
*DATA: gt_referenz TYPE STANDARD TABLE OF gty_s_referenz,
*      gs_referenz LIKE LINE OF gt_referenz.

**&SPWIZARD: DECLARATION OF TABLECONTROL 'REFERENZEN' ITSELF
*CONTROLS: referenzen TYPE TABLEVIEW USING SCREEN 0905.

*&SPWIZARD: LINES OF TABLECONTROL 'REFERENZEN'
*DATA:     g_referenzen_lines  LIKE sy-loopc.

*** 001 ***
CONSTANTS: gc_tcode   TYPE sytcode VALUE '/THKR/STORNO',
           gc_tcode_k TYPE sytcode VALUE 'Z_FI_STORNO_LOK'.

*&---------------------------------------------------------------------*
*& Include Z_FI_BN_AUSGEBEN_TOP                     - Report Z_FI_BN_AUSGEBEN
*&---------------------------------------------------------------------*
REPORT z_fi_bn_ausgeben MESSAGE-ID z_fi_nachr.

TABLES: zfi_cu_bn_ftext, zfi_bn_nachricht, bkpf.
DATA: gv_tcode   TYPE char50 VALUE 'Z_FI_BN_SENDEN'.

CONSTANTS: gc_auth_activ TYPE fm_authact VALUE '03',
           gc_fikrs      TYPE fikrs      VALUE '1000'.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
    PARAMETERS: p_herk TYPE zfi_bn_herk OBLIGATORY DEFAULT 'Y'.
    SELECT-OPTIONS: s_fnr  FOR zfi_cu_bn_ftext-fehlernr. " NO INTERVALS.
    SELECT-OPTIONS: s_erfd FOR zfi_bn_nachricht-erfdat.
    SELECT-OPTIONS: s_unam FOR zfi_bn_nachricht-uname.
  SELECTION-SCREEN END OF BLOCK b2.
  SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-b03.
    PARAMETERS: p_laufd TYPE laufd NO-DISPLAY.
    PARAMETERS: p_laufi TYPE laufi NO-DISPLAY.
    PARAMETERS: p_zbukr LIKE zfi_f_bnbel-zbukr NO-DISPLAY.
  SELECTION-SCREEN END OF BLOCK b3.
  SELECTION-SCREEN BEGIN OF BLOCK b6 WITH FRAME TITLE TEXT-b06.
    PARAMETERS: p_hbkid TYPE febko-hbkid NO-DISPLAY.
    PARAMETERS: p_hktid TYPE febko-hktid  NO-DISPLAY.
    PARAMETERS: p_kukey TYPE kukey_eb  NO-DISPLAY.
    PARAMETERS: p_esnum TYPE esnum_eb  NO-DISPLAY.
    PARAMETERS: p_vgext TYPE vgext_eb NO-DISPLAY..
  SELECTION-SCREEN END OF BLOCK b6.

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-b04.
SELECT-OPTIONS: s_fistl FOR zfi_bn_nachricht-fistl.
SELECT-OPTIONS: s_blart FOR bkpf-blart. " 2025-08-19 js: Belegart ergänzt
SELECT-OPTIONS: s_fipos FOR zfi_bn_nachricht-fipos. " 2025-08-19 js: Finanzposition ergänzt
SELECTION-SCREEN END OF BLOCK b4.

SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN BEGIN OF BLOCK b7 WITH FRAME TITLE TEXT-b07.
  PARAMETERS: p_test TYPE xfeld DEFAULT 'X'.
  PARAMETERS: p_prot TYPE xfeld.
SELECTION-SCREEN END OF BLOCK b7.

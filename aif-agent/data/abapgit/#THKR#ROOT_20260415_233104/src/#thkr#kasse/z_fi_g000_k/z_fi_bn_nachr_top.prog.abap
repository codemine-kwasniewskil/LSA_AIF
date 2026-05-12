*&---------------------------------------------------------------------*
*& Include Z_FI_BN_NACHR_TOP                        - Report Z_FI_BN_NACHR
*&---------------------------------------------------------------------*
REPORT z_fi_bn_nachr MESSAGE-ID z_fi_nachr.

TYPES: BEGIN OF lty_belege,
         bukrs TYPE bukrs,
         gjahr TYPE gjahr,
         belnr TYPE belnr_d,
       END OF lty_belege.

TABLES: zfi_cu_bn_ftext, zfi_bn_nachricht, bkpf, febko.

DATA: gv_tcode        TYPE char50 VALUE 'Z_FI_BN_DISPL',
      g_repid         TYPE sy-repid VALUE 'ZCL_FI_BN_NACHR_SALV',
      gv_vari         TYPE slis_vari VALUE '/STANDARD',
      gv_variant_help TYPE disvariant,
      gv_variant      TYPE disvariant,
      gt_retval       TYPE TABLE OF ddshretval,
      gt_belege       TYPE TABLE OF lty_belege.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
PARAMETERS: p_herk TYPE zfi_bn_herk OBLIGATORY DEFAULT 'Y'.
SELECT-OPTIONS: s_fnr  FOR zfi_cu_bn_ftext-fehlernr. " NO INTERVALS.
SELECT-OPTIONS: s_erfd FOR zfi_bn_nachricht-erfdat.
***SELECTION-SCREEN BEGIN OF line.
***SELECTION-SCREEN: COMMENT 15(17) text-s01 for field p_ak.
***SELECTION-SCREEN position 32.
***PARAMETERS p_ak TYPE ZFI_BN_INAKTIV as checkbox default 'X'.
***SELECTION-SCREEN: comment 33(11) text-s02 for field p_inak.
***parameters  p_inak TYPE ZFI_BN_INAKTIV as checkbox.
*** SELECTION-SCREEN:                 END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-b03.
PARAMETERS: p_laufd TYPE laufd  NO-DISPLAY.
PARAMETERS: p_laufi TYPE laufi  NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b3.
SELECTION-SCREEN BEGIN OF BLOCK b5 WITH FRAME TITLE TEXT-b05.
PARAMETERS: p_hbkid TYPE febko-hbkid  NO-DISPLAY.
PARAMETERS: p_hktid TYPE febko-hktid  NO-DISPLAY.
PARAMETERS: p_kukey TYPE kukey_eb     NO-DISPLAY.
PARAMETERS: p_esnum TYPE esnum_eb     NO-DISPLAY.
PARAMETERS: p_vgext TYPE vgext_eb     NO-DISPLAY.
PARAMETERS: p_vblnr TYPE vblnr        NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b5.
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-b04.
SELECT-OPTIONS: s_bukrs FOR bkpf-bukrs.
SELECT-OPTIONS: s_fistl FOR zfi_bn_nachricht-fistl.
SELECT-OPTIONS: s_gjahr FOR bkpf-gjahr. " DEFAULT sy-datum(4). "2025-08-20 js: keine Vorbelegung de Jahres
SELECT-OPTIONS: s_belnr FOR bkpf-belnr.
SELECT-OPTIONS: s_blart FOR bkpf-blart. " 2025-08-19 js: Belegart ergänzt
SELECT-OPTIONS: s_xblnr FOR bkpf-xblnr.
SELECT-OPTIONS: s_unam  FOR zfi_bn_nachricht-uname.
SELECT-OPTIONS: s_fipos FOR zfi_bn_nachricht-fipos. " 2025-08-19 js: Finanzposition ergänzt
SELECT-OPTIONS: s_lifnr FOR zfi_bn_nachricht-lifnr.
SELECT-OPTIONS: s_kunnr FOR zfi_bn_nachricht-kunnr.
SELECTION-SCREEN END OF BLOCK b4.
PARAMETERS: p_vari TYPE slis_vari.
SELECTION-SCREEN END OF BLOCK b1.

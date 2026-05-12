*&---------------------------------------------------------------------*
*& Include          /THKR/R_SEND_IST_RUECK_SSC
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      SELECTION SCREEN
*&---------------------------------------------------------------------*
  " Selection criterias
  SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-f01.
    PARAMETERS: p_fikrs  TYPE fikrs DEFAULT 1000.
    SELECT-OPTIONS: so_bukrs FOR kblk-bukrs,
                    so_gjahr FOR fmci-gjahr,
                    so_belnr FOR kblk-belnr,
                    so_blart FOR kblk-blart,
                    so_budat FOR kblk-budat,
                    so_lotkz FOR kblk-lotkz,
                    so_fipex FOR fmci-fipex,
                    so_fictr FOR fmfctr-fictr,
                    so_xblnr FOR kblk-xblnr.
  SELECTION-SCREEN END OF BLOCK bl1.

  SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-f03.
    PARAMETERS: p_disp TYPE flag AS CHECKBOX.
  SELECTION-SCREEN END OF BLOCK bl3.

  SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-f02.
    PARAMETERS: p_send   TYPE flag AS CHECKBOX,
                p_q_ns   TYPE /aif/ns DEFAULT 'FREMDV', "/aif/pers_rtcfgr_ns,
                p_q_name TYPE /aif/pers_rtcfgr_name,
                p_sst    TYPE /thkr/dte_bu_sst,
                p_resend TYPE flag AS CHECKBOX DEFAULT abap_false.
  SELECTION-SCREEN END OF BLOCK bl2.

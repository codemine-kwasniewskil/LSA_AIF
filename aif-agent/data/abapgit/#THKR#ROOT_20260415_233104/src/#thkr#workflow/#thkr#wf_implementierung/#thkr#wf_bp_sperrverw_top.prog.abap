*&---------------------------------------------------------------------*
*& Include          /THKR/WF_BP_SPERRVERW_TOP
*&---------------------------------------------------------------------*
TYPES: BEGIN OF gty_log,
         partner TYPE bu_partner,
         gp      TYPE flag,
         debi    TYPE flag,
         kred    TYPE flag,
       END OF gty_log.

DATA: gv_bp TYPE bu_partner.
DATA: gt_bp TYPE STANDARD TABLE OF bu_partner.
DATA: gt_log TYPE STANDARD TABLE OF gty_log,
      gs_log TYPE gty_log,
      gv_fehler TYPE flag.

FIELD-SYMBOLS: <gf_bp> TYPE bu_partner.

SELECT-OPTIONS: so_bp FOR gv_bp.

SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME.
  PARAMETERS: pa_sperr RADIOBUTTON GROUP sper,
              pa_entsp RADIOBUTTON GROUP sper.

  SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME.

    PARAMETERS: pa_debi AS CHECKBOX,
                pa_kred AS CHECKBOX,
                pa_gp   AS CHECKBOX.
  SELECTION-SCREEN: END OF BLOCK b1.
  PARAMETERS: pa_test AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN: END OF BLOCK b2.

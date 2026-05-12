*&---------------------------------------------------------------------*
*& Include Z_FI_LVM_BNKA_TOP         - Report Z_FI_LVM_BNKA
*&---------------------------------------------------------------------*
REPORT z_fi_lvm_bnka MESSAGE-ID z_fi_nachr.

CONSTANTS:
  gc_loevm  TYPE  c VALUE 'X'.

DATA:
  gt_zbnka  TYPE STANDARD TABLE OF zfi_bnka,
  gt_bnka_n TYPE TABLE OF bnka,
  gv_actvt  TYPE activ_auth,
  gv_lock   TYPE c,
  gt_result TYPE zfi_t_bnka_result,
  gs_result TYPE zfi_f_bnka_result.

*DATA: BEGIN OF gs_result.
*        INCLUDE STRUCTURE zfi_bnka.
*        DATA    status(1).
*DATA: END OF gs_result.
*DATA: gt_result LIKE TABLE OF gs_result.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.

PARAMETERS: p_test TYPE xfeld DEFAULT 'X'.
PARAMETERS: p_lock TYPE xfeld DEFAULT 'X'.
PARAMETERS: p_cdoc TYPE xfeld DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK b1.

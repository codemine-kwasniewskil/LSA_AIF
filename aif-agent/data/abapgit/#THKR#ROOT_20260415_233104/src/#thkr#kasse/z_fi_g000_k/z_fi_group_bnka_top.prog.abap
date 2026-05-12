*&---------------------------------------------------------------------*
*& Include Z_FI_LVM_BNKA_TOP         - Report Z_FI_LVM_BNKA
*&---------------------------------------------------------------------*
REPORT z_fi_lvm_bnka MESSAGE-ID z_fi_nachr.
TABLES: bnka.


DATA:
  gt_bnka  TYPE STANDARD TABLE OF bnka,
  gt_bnka_change type standard table of bnka,
  gt_bnka_n TYPE TABLE OF bnka,
  gv_actvt  TYPE activ_auth,
  gv_lock   TYPE c,
  gt_result TYPE  standard table of bnka,
  gs_result TYPE bnka.

DATA: go_functions TYPE REF TO cl_salv_functions.        "Symbolleiste

DATA: go_table     TYPE REF TO cl_salv_table.            "Klasse

DATA: go_display   TYPE REF TO cl_salv_display_settings. "Displayeinstellungen

DATA: go_columns   TYPE REF TO cl_salv_columns_table.    "Spaltenmanipulation
DATA: go_column    TYPE REF TO cl_salv_column_table.

DATA: color        TYPE lvc_s_colo.                      "Farbe

DATA: go_sorts     TYPE REF TO cl_salv_sorts.            "Sortierung
DATA: go_agg       TYPE REF TO cl_salv_aggregations.     "Aggregation

DATA: go_filter    TYPE REF TO cl_salv_filters.          "Filter

DATA: go_layout    TYPE REF TO cl_salv_layout.           "Layout

DATA: key          TYPE salv_s_layout_key.












*DATA: BEGIN OF gs_result.
*        INCLUDE STRUCTURE zfi_bnka.
*        DATA    status(1).
*DATA: END OF gs_result.
*DATA: gt_result LIKE TABLE OF gs_result.
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-a01.
SELECT-OPTIONS: so_banks FOR bnka-banks,
                so_bankl FOR bnka-bankl.

SELECTION-SCREEN END OF  BLOCK a1.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.

PARAMETERS: p_test TYPE xfeld DEFAULT 'X'.
PARAMETERS: p_cdoc TYPE xfeld DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK b1.

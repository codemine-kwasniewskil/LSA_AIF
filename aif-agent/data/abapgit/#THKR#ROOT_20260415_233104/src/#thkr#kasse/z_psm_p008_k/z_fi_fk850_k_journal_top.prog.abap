*&---------------------------------------------------------------------*
*& Include          Z_FI_FK850_K_JOURNAL_TOP
*&---------------------------------------------------------------------*
REPORT z_fi_fk850_k_journal MESSAGE-ID z_fi_ea_forms.


DATA: gs_fmifiit      TYPE fmifiit,
      gv_xblnr        TYPE bkpf-xblnr,
      gv_no_auth_flag type xfeld,
      gs_bseg         TYPE bseg.

  DATA: col_tab  TYPE REF TO cl_salv_columns_table,
        col      TYPE REF TO cl_salv_column_table,
        lv_txt_l TYPE scrtext_l,
        lv_txt_m TYPE scrtext_m,
        lv_txt_s TYPE scrtext_s.

  DATA: col_ref TYPE   salv_t_column_ref,
        wa      LIKE LINE OF col_ref.

  DATA: o_alv_layout TYPE REF TO cl_salv_layout.

  DATA: lv_variant TYPE slis_vari.

  DATA: lo_columns    TYPE REF TO  cl_salv_columns_table,
        lo_column     TYPE REF TO  cl_salv_column_list,
        lt_cols       TYPE         salv_t_column_ref,
        ls_cols       LIKE LINE OF lt_cols,
        lv_bukrs_temp TYPE bukrs,
        lv_gsber_temp TYPE gsber.

  DATA: o_salv TYPE REF TO cl_salv_table.

  DATA: lv_layout_key TYPE salv_s_layout_key.

* Eventhandler
CLASS lcl_events DEFINITION FINAL.
  PUBLIC SECTION.
** Doppelklick
*    CLASS-METHODS: on_double_click FOR EVENT double_click OF cl_salv_events_table
*      IMPORTING
*        row
*        column.

* Link Klick
    CLASS-METHODS : on_link_click FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row
                column.
ENDCLASS.

* Selektionsbild

PARAMETERS: p_fikrs TYPE fikrs DEFAULT '1000' OBLIGATORY.

SELECTION-SCREEN SKIP 1.

PARAMETERS: p_stdat TYPE fmifiit-zhldt OBLIGATORY DEFAULT sy-datum.

SELECTION-SCREEN SKIP 1.

SELECT-OPTIONS: s_xblnr FOR gv_xblnr,
                s_sgtxt FOR gs_bseg-sgtxt,
                s_zhldt FOR gs_fmifiit-zhldt.

SELECTION-SCREEN SKIP 2.
PARAMETERS: p_alvlay TYPE slis_vari.

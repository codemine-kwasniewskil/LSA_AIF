*&---------------------------------------------------------------------*
*& Report /THKR/KASSE_GESAMT_HL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/bericht_bp_overview.

DATA bpsearch TYPE /thkr/b_bp_search.
SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
           s_bpid FOR bpsearch-partner
          ,s_grp  FOR bpsearch-bpgroup
          ,s_kind FOR bpsearch-kind
          ,s_name FOR bpsearch-name
          ,s_idtp FOR bpsearch-idtype
          ,s_idnm FOR bpsearch-idnumbe
          ,s_bank FOR bpsearch-bank
          ,s_gsbr FOR bpsearch-gsber MATCHCODE OBJECT h_tgsb
          ,s_sst  FOR bpsearch-sst   MATCHCODE OBJECT /thkr/aif_sst
          ,s_blbd FOR bpsearch-blk_deb_bukrs
          ,s_blbk FOR bpsearch-blk_kred_bukrs.
  .
SELECTION-SCREEN END OF BLOCK part1.
SELECTION-SCREEN BEGIN OF BLOCK part2 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
          s_str  FOR bpsearch-street MATCHCODE OBJECT clstrtname
         ,s_plz  FOR bpsearch-post_code
         ,s_city FOR bpsearch-city MATCHCODE OBJECT clcityname.
SELECTION-SCREEN END OF BLOCK part2.
SELECTION-SCREEN BEGIN OF BLOCK part3 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_bdal AS CHECKBOX,
*              p_bkal AS CHECKBOX,
              p_arv  AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK part3.

START-OF-SELECTION.

** Fill and show ALV
  TRY.
      DATA(alv) = NEW /thkr/cl_b_bp_alv_ctr(
        partner        = s_bpid[]
        group          = s_grp[]
        kind           = s_kind[]
        name           = s_name[]
        idtype         = s_idtp[]
        idnumber       = s_idnm[]
        bank           = s_bank[]
        gsber          = s_gsbr[]
        sst            = s_sst[]
        blk_deb_bukrs  = s_blbd[]
        blk_kred_bukrs = s_blbk[]
        block_deb_all  = p_bdal
*        block_kred_all = p_bkal
        archived       = p_arv
        street         = s_str[]
        plz            = s_plz[]
        city           = s_city[]
      ).
      alv->display_data( ).
    CATCH cx_salv_error INTO DATA(err).
      MESSAGE err->get_text( ) TYPE 'E'.
  ENDTRY.

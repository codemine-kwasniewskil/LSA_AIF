*&---------------------------------------------------------------------*
*& Report /THKR/KASSE_GESAMT_HL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/budget_report_mv.

DATA(search_fields) = VALUE /thkr/bud_mv_search( ).

* Selektionsbild
SELECTION-SCREEN BEGIN OF BLOCK d1 WITH FRAME TITLE TEXT-001.
  PARAMETERS     p_fstl   LIKE search_fields-fistl OBLIGATORY.
  SELECT-OPTIONS: s_fpos  FOR search_fields-fipos
                 ,s_hhp   FOR search_fields-hhp
                 ,s_fund  FOR search_fields-fund
                 ,s_far   FOR search_fields-funcarea
                 ,s_bud   FOR search_fields-budtype
                 ,s_gjahr FOR search_fields-sgjahr.
  PARAMETERS     p_budcat LIKE search_fields-budcat DEFAULT '9F' OBLIGATORY.

*  SELECTION-SCREEN COMMENT /1(79) TEXT-002.
SELECTION-SCREEN END OF BLOCK d1.

SELECTION-SCREEN BEGIN OF BLOCK v1 WITH FRAME.
  PARAMETERS: p_alvlay TYPE slis_vari.
SELECTION-SCREEN END OF BLOCK v1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_alvlay.
  p_alvlay = cl_salv_layout_service=>f4_layouts( VALUE #( report = |/THKR/CL_B_BUD_MV_ZB_ALV_CTR==CP| ) )-layout.


START-OF-SELECTION.
** Fill and show ALV
  TRY.
      DATA(alv) = NEW /thkr/cl_b_bud_mv_zb_alv_ctr( p_fistl    = p_fstl
                                                    s_fipos    = s_fpos[]
                                                    p_variant  = p_alvlay
                                                    s_hhp      = s_hhp[]
                                                    s_fund     = s_fund[]
                                                    s_funcarea = s_far[]
                                                    s_budtype  = s_bud[]
                                                    s_gjahr    = s_gjahr[]
                                                    p_budcat   = p_budcat ).
      alv->display_data( ).
    CATCH cx_salv_error INTO DATA(err).
      MESSAGE err->get_text( ) TYPE 'E'.
  ENDTRY.

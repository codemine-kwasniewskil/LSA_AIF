*&---------------------------------------------------------------------*
*& Report /thkr/kasse_cashpool_lb_hs
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/kasse_cashpool_lb_hs.

DATA: lv_kapitel      TYPE /thkr/psm_fipos_kapitel.

SELECTION-SCREEN BEGIN OF BLOCK d1 WITH FRAME TITLE TEXT-001.
* Selektionsbild.
  SELECT-OPTIONS:  s_cap   FOR lv_kapitel  DEFAULT '4000'.

SELECTION-SCREEN END OF BLOCK d1.

INITIALIZATION.
  s_cap[] = VALUE #( ( sign = if_fsbp_const_range=>sign_include option = if_fsbp_const_range=>option_equal low = '4640' )
                     ( sign = if_fsbp_const_range=>sign_include option = if_fsbp_const_range=>option_equal low = '4650' ) ).

START-OF-SELECTION.
** Fill and show ALV
  TRY.
      DATA(alv) = NEW /thkr/cl_b_cashpool_lb_alv_ctr( s_kapitel = s_cap[] ).
      alv->display_data( ).
    CATCH cx_salv_error INTO DATA(err).
      MESSAGE err->get_text( ) TYPE 'E'.
  ENDTRY.

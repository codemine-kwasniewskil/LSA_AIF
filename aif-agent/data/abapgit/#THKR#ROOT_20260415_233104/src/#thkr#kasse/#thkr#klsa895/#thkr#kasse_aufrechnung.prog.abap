*&---------------------------------------------------------------------*
*& Report /THKR/KASSE_GESAMT_HL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/kasse_aufrechnung.

DATA:   lv_name TYPE bu_name
       ,lv_plz  TYPE post_code
       ,lv_epl  TYPE fm_fonds.

"" EPL des Einzahlers
* Selektionsbild
SELECTION-SCREEN BEGIN OF BLOCK d1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_name FOR lv_name
                 ,s_plz  FOR lv_plz
                 ,s_epl  FOR lv_epl.
  SELECTION-SCREEN COMMENT /1(79) TEXT-002.
SELECTION-SCREEN END OF BLOCK d1.

START-OF-SELECTION.
** Fill and show ALV
  TRY.
      DATA(alv) = NEW /thkr/cl_b_aufrech_alv_ctr( s_bpname = s_name[] s_plz = s_plz[] s_epl = s_epl[] ).
      alv->display_data( ).
    CATCH cx_salv_error INTO DATA(err).
      MESSAGE err->get_text( ) TYPE 'E'.
  ENDTRY.

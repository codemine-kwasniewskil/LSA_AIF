*&---------------------------------------------------------------------*
*& Report /THKR/FI_KASSENZEICHEN_GEN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/FI_KASSENZEICHEN_GEN.

types: begin of ty_output,
        zaehler(3) type n,
        kaz type xblnr,
       end of ty_output.
data: ls_output type ty_output.
data: lt_output type table of ty_output.
data: lv_kaz type /THKR/D_KASSENZEICHEN.
data: lv_rc type NRRETURN.

selection-screen: begin of block b01 with frame title text-t01.
parameters: p_fonds type FM_FONDS obligatory.
parameters: p_gsber type gsber obligatory.
parameters: p_nrnr type nrnr obligatory.
selection-screen: end of block b01.
selection-screen: begin of block b02 with frame title text-t02.
parameters: p_anzahl(3) type n obligatory.
selection-screen: end of block b02.

clear lt_output.
do p_anzahl times.
  clear ls_output.
  ls_output-zaehler = sy-index.
  CALL METHOD /thkr/cl_kassenzeichen=>create
    EXPORTING
      i_fonds = p_fonds
      i_gsber = p_gsber
      i_nrnr  = p_nrnr
     IMPORTING
       e_kaz   = lv_kaz
       e_rc    = lv_rc
      .
  if lv_rc = 0.
    ls_output-kaz = lv_kaz.
    append ls_output to lt_output.
  endif.
enddo.

*do.
if lt_output is not initial.
  data(o_alv) = new cl_gui_alv_grid( i_parent = cl_gui_container=>default_screen
                                     i_appl_events = abap_true ).
  data: o_salv type ref to cl_salv_table.
  cl_salv_table=>factory( importing r_salv_table = o_salv
                          changing  t_table = lt_output ).
  data(it_fcat) = cl_salv_controller_metadata=>get_lvc_fieldcatalog( r_columns = o_salv->get_columns( )
                                                                     r_aggregations = o_salv->get_aggregations( ) ).
  data(lv_layout) = value lvc_s_layo( zebra = abap_true
                                      cwidth_opt = 'A'
                                      grid_title = 'Generierte Kassenzeichen' ).
  o_alv->set_table_for_first_display( exporting i_bypassing_buffer = abap_false
                                                i_save = 'A'
                                                is_layout = lv_layout
                                      changing  it_fieldcatalog = it_fcat
                                                it_outtab = lt_output ).
  cl_gui_alv_grid=>set_focus( control = o_alv ).
  cl_abap_list_layout=>suppress_toolbar( ).
  write: space.
else.
  write: / 'Es konnten keine Kassenzeichen ermittelt werden'.
endif.

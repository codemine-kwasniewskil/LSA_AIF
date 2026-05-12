"Name: \FU:FI_PSO_ORDER_CHECK\SE:END\EI
ENHANCEMENT 0 ZFI_PSO_ORDER_CHECK.

DATA: ls_klsa966_incl TYPE /thkr/s_klsa966_incl,
      lv_ok           TYPE char1.

FIELD-SYMBOLS: <lf_vbkpf> TYPE vbkpf.

READ TABLE e_t_vbkpf ASSIGNING <lf_vbkpf> INDEX 1.

CALL FUNCTION '/THKR/KLSA966_GET_INCL'
  EXPORTING
    iv_bukrs        = <lf_vbkpf>-bukrs
    iv_belnr        = <lf_vbkpf>-belnr
    iv_gjahr        = <lf_vbkpf>-gjahr
    iv_lotkz        = c_f_pso-lotkz
  IMPORTING
    es_klsa966_incl = ls_klsa966_incl.

LOOP AT e_t_vbkpf ASSIGNING <lf_vbkpf>.
*    replace all OCCURRENCES OF '.' in lv_z_intrate with ''.
*    replace all OCCURRENCES OF ',' in lv_z_intrate with '.'.
  <lf_vbkpf>-z_intrate = ls_klsa966_incl-z_intrate.
  <lf_vbkpf>-z_vzskz = ls_klsa966_incl-z_vzskz.
  CLEAR: lv_ok.
  IMPORT zahlanz TO lv_ok FROM MEMORY ID 'ZAHLANZ'.
  IF lv_ok EQ abap_true.
    <lf_vbkpf>-z_009  = '1'.
  ENDIF.
ENDLOOP.
ENDENHANCEMENT.

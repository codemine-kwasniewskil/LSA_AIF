FUNCTION /thkr/klsa966_call_screen_9010.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_BUKRS) TYPE  BUKRS
*"     VALUE(IV_BELNR) TYPE  BELNR_D
*"     VALUE(IV_GJAHR) TYPE  GJAHR
*"     VALUE(IV_ACTIVITY) TYPE  ACTIV_AUTH
*"     VALUE(IV_DBBDT) TYPE  PSO02-DBBDT OPTIONAL
*"     VALUE(IV_LOTKZ) TYPE  PSO02-LOTKZ OPTIONAL
*"----------------------------------------------------------------------
*data: lv_z_intrate(10).

  DATA: ls_klsa966_incl TYPE /thkr/s_klsa966_incl.

  CALL FUNCTION '/THKR/KLSA966_GET_INCL'
    EXPORTING
      iv_bukrs        = iv_bukrs
      iv_belnr        = iv_belnr
      iv_gjahr        = iv_gjahr
      iv_lotkz        = iv_lotkz
    IMPORTING
      es_klsa966_incl = ls_klsa966_incl.
  IF ( iv_activity = gc_activity_01 OR
       iv_activity = gc_activity_02 ).
    gv_zins_input_flag = abap_true.
  ELSE.
    gv_zins_input_flag = abap_false.
  ENDIF.

  CALL SCREEN 9010 STARTING AT 3 3 ENDING AT 30 5.

ENDFUNCTION.

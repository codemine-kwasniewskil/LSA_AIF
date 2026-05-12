*&---------------------------------------------------------------------*
*& Include          /THKR/TPBR_STORNO_F02
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Include          Z_TPBR_STORNO_WF_F02
*&---------------------------------------------------------------------*
FORM build_bdc_screen TABLES   bdctab STRUCTURE bdcdata
                      USING    VALUE(program)
                               VALUE(dynpro).

  DATA bdctab_wa TYPE bdcdata.

  CLEAR bdctab_wa.
  bdctab_wa-program = program.
  bdctab_wa-dynpro = dynpro.
  bdctab_wa-dynbegin = 'X'.
  APPEND bdctab_wa TO bdctab.

ENDFORM.                    " build_bdc_screen

FORM build_bdc_value TABLES   bdctab STRUCTURE bdcdata
                     USING    fnam  fval.

  DATA: bdctab_wa TYPE bdcdata.

  CLEAR bdctab_wa.
  bdctab_wa-fnam = fnam.
  bdctab_wa-fval = fval.
  APPEND bdctab_wa TO bdctab.

ENDFORM.                    " build_bdc_value

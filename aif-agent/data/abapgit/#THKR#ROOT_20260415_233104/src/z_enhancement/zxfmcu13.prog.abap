*&---------------------------------------------------------------------*
*& Include          ZXFMCU13
*&---------------------------------------------------------------------*

CLEAR t_screen_fldpr.

IF f_kbld-erlkz = 'X'.
  APPEND INITIAL LINE TO t_screen_fldpr ASSIGNING FIELD-SYMBOL(<lf_line>).
  <lf_line>-fname = 'F_KBLD-ERLKZ'.
  <lf_line>-kennz = '*'.

*   APPEND INITIAL LINE TO t_screen_fldpr ASSIGNING <lf_line>.
*  <lf_line>-fname = 'F_KBLD-PTEXT'.
*  <lf_line>-kennz = '*'.


ENDIF.

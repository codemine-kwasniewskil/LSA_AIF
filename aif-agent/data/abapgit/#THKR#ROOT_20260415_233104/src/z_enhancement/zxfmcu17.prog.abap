*&---------------------------------------------------------------------*
*& Include          ZXFMCU17
*&---------------------------------------------------------------------*

if f_kbld-erlkz = 'X'.

  READ TABLE t_line_fldpr ASSIGNING FIELD-SYMBOL(<fs_screen>)
  with key fname = 'KBLD-ERLKZ'.
  if sy-subrc = 0.
    <fs_screen>-kennz = '*'.
    ENDIF.

  ENDIF.

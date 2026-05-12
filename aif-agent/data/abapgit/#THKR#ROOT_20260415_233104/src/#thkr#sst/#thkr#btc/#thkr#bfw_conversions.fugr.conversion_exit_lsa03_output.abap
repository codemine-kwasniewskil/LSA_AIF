FUNCTION conversion_exit_lsa03_output.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"----------------------------------------------------------------------

  PERFORM init_de_run1_status.

  READ TABLE de_run1_status_texts INTO DATA(l_line)
  WITH KEY domvalue_l = input .
  IF sy-subrc = 0.
    output = l_line-ddtext.
  ELSE.
    output = input.
  ENDIF.

ENDFUNCTION.

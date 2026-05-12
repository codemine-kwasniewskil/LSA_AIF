FUNCTION conversion_exit_mig03_input.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"----------------------------------------------------------------------
  PERFORM init_mig_ao_status.

  READ TABLE mig_ao_status_texts INTO DATA(l_line)
  WITH KEY ddtext = input .
  IF sy-subrc = 0.
    output = l_line-domvalue_l.
  ELSE.
    output = input.
  ENDIF.

ENDFUNCTION.

FUNCTION CONVERSION_EXIT_LSA04_INPUT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"----------------------------------------------------------------------
  PERFORM init_de_run2_status.

  READ TABLE de_run2_status_texts INTO DATA(l_line)
  WITH KEY ddtext = input .
  IF sy-subrc = 0.
    output = l_line-domvalue_l.
  ELSE.
    output = input.
  ENDIF.

ENDFUNCTION.

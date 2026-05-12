FUNCTION CONVERSION_EXIT_LSA02_INPUT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"----------------------------------------------------------------------
  PERFORM init_gi_field_separation.

  READ TABLE gi_field_separation_texts INTO DATA(l_line)
  WITH KEY ddtext = input .
  IF sy-subrc = 0.
    output = l_line-domvalue_l.
  ELSE.
    output = input.
  ENDIF.

ENDFUNCTION.

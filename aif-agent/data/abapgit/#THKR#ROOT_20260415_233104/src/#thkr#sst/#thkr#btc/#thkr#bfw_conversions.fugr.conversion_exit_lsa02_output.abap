FUNCTION CONVERSION_EXIT_LSA02_OUTPUT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"----------------------------------------------------------------------

  PERFORM init_gi_field_separation.

  READ TABLE gi_field_separation_texts INTO data(l_line)
  WITH KEY domvalue_l = input .
  IF sy-subrc = 0.
    output = l_line-ddtext.
  ELSE.
    output = input.
  ENDIF.

ENDFUNCTION.
